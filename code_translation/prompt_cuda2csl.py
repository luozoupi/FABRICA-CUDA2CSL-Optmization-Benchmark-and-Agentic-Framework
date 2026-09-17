"""
Prompts for the CUDA -> CSL workflow and staged CSL optimization.
"""

import os

# CSL @-builtin whitelist injected at the END of every implementer prompt
# (initial translation + both fix prompts). The intent is to stop recurring
# hallucinations like `@my_pe_x` / `@get_pe_id` / `@write_to_neighbor` that
# show up in failed Residual / Game-of-Life runs.
#
# Source: union of (a) every @-builtin actually used across csl-examples
# tutorials + benchmarks (62 builtins, ground-truth), and (b) additional builtins
# documented in cerebras-csl-skills SKILL-BUILTINS.md that are stable in SDK 1.4.0.
# Anti-patterns are explicit fixes for the failures we've seen in this codebase's
# own translation logs.
#
# Env-gated by XKERNEL_BUILTIN_WHITELIST (default "1"). Set to "0" for A/B
# baseline runs.
_BUILTIN_WHITELIST_BLOCK = """============================================================
HARD CONSTRAINT — CSL @-BUILTIN WHITELIST
============================================================
Use ONLY @-builtins from the list below. If you need something that is NOT
on this list, that capability comes from an imported module (e.g.
`layout_mod`, `memcpy`, `<math>`, `<debug>`), NOT from a @-builtin. Calling
an unknown @-builtin is the #1 failure mode of this pipeline.

Allowed @-builtins (SDK 1.4.0, WSE-3):
  Tasks / events:
    @activate, @block, @unblock, @bind_local_task, @bind_data_task,
    @bind_control_task, @bind_rotating_tasks, @set_teardown_handler,
    @get_local_task_id, @get_data_task_id, @get_control_task_id, @get_ut_id
  Colors / queues / fabric / config:
    @get_color, @get_input_queue, @get_output_queue, @initialize_queue,
    @set_color_config, @set_local_color_config, @set_rectangle,
    @get_rectangle, @set_tile_code, @get_filter_id, @set_empty_queue_handler,
    @queue_flush
  DSDs:
    @get_dsd, @get_dsr, @get_xdsr, @load_to_dsr, @set_dsd_base_addr,
    @set_dsd_length, @set_dsd_stride, @increment_dsd_offset
  DSD ops (integer):
    @add16, @mov16, @mov32, @sll, @slr, @sar, @and, @or, @xor, @popcnt,
    @clz, @ctz
  DSD ops (float):
    @faddh, @fadds, @faddhs, @fsubh, @fsubs, @fmach, @fmacs, @fmachs,
    @fmulh, @fmuls, @fmovh, @fmovs, @fnegh, @fnegs, @fabsh, @fabss,
    @fmaxh, @fmaxs, @fnormh, @fnorms, @fscaleh, @fscales
  Modules / symbols / RPC:
    @import_module, @export_name, @export_symbol, @get_symbol_id,
    @get_symbol_value, @get_tensor_ptr, @has_exported_tensors
  Type / introspection / generics:
    @as, @bitcast, @ptrcast, @type_of, @is_same_type, @is_comptime,
    @element_type, @element_count, @dimensions, @rank, @field, @has_field
  Comptime / utility:
    @assert, @comptime_assert, @comptime_print, @constants, @get_int,
    @as_string, @get_string_from_byte, @strcat, @strlen, @range,
    @range_start, @range_step, @range_stop, @zeros, @concat_structs,
    @is_arch, @get_array, @get_config, @set_config
  Higher-order:
    @map
  Random:
    @random, @set_active_prng

PE COORDINATE IDIOM (a common failure point):
  WRONG:   `@my_pe_x()`, `@get_pe_x()`, `@pe_id_x()`
  RIGHT:   import the layout module, then call get_x_coord()/get_y_coord()
           ONLY from INSIDE an fn or task body (i.e. at RUNTIME):
           ```
           const layout_mod = @import_module("<layout>");
           fn is_left_col() bool { return layout_mod.get_x_coord() == 0; }
           fn is_top_row()  bool { return layout_mod.get_y_coord() == 0; }
           // ... and call these helpers from inside tasks / the entrypoint fn.
           ```
  WRONG (real, recurring failure in this pipeline — do NOT do either):
           ```
           const px: u16 = layout_mod.get_x_coord();   // top-level const  -> ERROR
           const py: i16 = @as(i16, layout_mod.get_y_coord()); // use-site cast at
                                                    // module scope        -> ERROR
           var _px: i16 = 0;
           comptime { _px = layout_mod.get_x_coord(); } // comptime block   -> ERROR
           ```
           get_x_coord()/get_y_coord() bottom out in tile_config's @get_config,
           which the compiler rejects outside a top-level comptime block:
             "comptime evaluation of this expression is only valid while
              evaluating a top level comptime block"
           A module-scope `const` initializer is evaluated at comptime but NOT
           inside that top-level comptime block, so it always fails. The fabric
           coordinate config registers are simply not readable at module scope.
  If you need the coordinate at COMPTIME (to select a route, gate a
  @bind_data_task, pick a @get_dsd, or specialize a const): you CANNOT read it
  on-device. Take it in as a `param` plumbed from layout.csl via
  @set_tile_code, e.g. `param px: i16;` / `param is_first_row: bool;` and the
  layout sets `.px = x` / `.is_first_row = (x == 0)` per tile. Check the GIVEN
  layout.csl for the param names it already passes down before inventing new
  ones.

ANTI-PATTERNS (have caused real failures in this pipeline):
  - `@my_pe_x` / `@my_pe_y` — do not exist; use `layout_mod.get_{x,y}_coord()`.
  - `@send_to_neighbor` / `@recv_from_neighbor` — fabric I/O happens via
    `fabin_dsd` / `fabout_dsd` DSDs bound to colors/queues, not builtins.
  - `@allocate_fifo` exists; `@allocate_circbuf` does NOT — use `@get_dsd`
    with `mem4d_dsd` for a circular buffer pattern.
  - `@get_pe_id` / `@get_my_id` — same as `@my_pe_x`: use layout module.
  - Anything named `@cuda_*` / `@cuda_blockIdx` etc. — CUDA semantics
    don't map to @-builtins; they map to the wafer-scale decomposition
    decided by the architect.

If your draft contains an `@` token NOT on the list above, you are
hallucinating. Either replace it with the correct module call, or restructure
the code to not need it."""


def builtin_whitelist_block() -> str:
    """Return the builtin whitelist block, or empty string if disabled.

    Env-gated by XKERNEL_BUILTIN_WHITELIST (default "1"). Set to "0" to
    disable for A/B baseline comparisons.
    """
    if os.getenv("XKERNEL_BUILTIN_WHITELIST", "1") == "0":
        return ""
    return _BUILTIN_WHITELIST_BLOCK


def default_frozen_callout_block(spec=None) -> str:
    """Render the frozen-symbol callout used by every optimize-style
    prompt. Honors a per-kernel override in ``spec.yaml`` (via
    ``contract_check.spec_frozen_lists``) and falls back to the
    catalog defaults (f_tic / f_toc / f_memcpy_timestamps /
    f_reference_timestamps for functions; BLOCK_SIZE / MAX_ZDIM /
    STARTUP / width / height / m / n / k / memcpyParams /
    reduceParams / stencilParams for params).

    Centralised here so cuda2csl.py, rl_*_optimizer.py, and
    optimize_explore.py all render the same structured block — the
    BiCGSTAB/CG live runs showed the prior static prose ("function
    bodies must match verbatim") was not specific enough to stop the
    LLM tripping the guard on f_reference_timestamps.
    """
    try:
        from contract_check import spec_frozen_lists  # type: ignore
    except Exception:
        # Defensive: if contract_check can't import, return a static
        # block rather than failing the whole optimization run.
        ff = ("f_tic", "f_toc", "f_memcpy_timestamps",
              "f_reference_timestamps")
        fp = ("BLOCK_SIZE", "MAX_ZDIM", "STARTUP", "width", "height",
              "m", "n", "k", "memcpyParams", "reduceParams",
              "stencilParams")
    else:
        ff, fp = spec_frozen_lists(spec)
    fn_lines = "\n".join(f"  - `{f}`" for f in ff) if ff else "  (none)"
    param_lines = "\n".join(f"  - `{p}`" for p in fp) if fp else "  (none)"
    return (
        "============================================================\n"
        "FROZEN SYMBOLS — DO NOT EDIT (auto-rejected if changed)\n"
        "============================================================\n"
        "Editing any of these triggers a contract violation before\n"
        "the candidate even reaches cslc. Leave them verbatim.\n"
        "\n"
        "Frozen function bodies (must match the reference exactly):\n"
        f"{fn_lines}\n"
        "\n"
        "Frozen top-level `param NAME: TYPE;` declarations (must not\n"
        "be redeclared, shadowed by `const NAME = ...`, or re-named\n"
        "as `NAME_LOCAL` / `NAME_OVERRIDE` / `NAME_TMP` / `NAME_FIXED`):\n"
        f"{param_lines}"
    )


Instruction_system_cuda_to_csl = """You are an expert in CUDA GPU programming, Cerebras CSL,
and distributed accelerator runtime interfaces.

You are translating CUDA kernels into a CSL compute file that must plug into an
existing reference Cerebras bundle. Preserve the reference bundle contract exactly.
Only change the requested compute file, keep the exported symbols and entrypoint
compatible with the provided layout/run scripts, and favor simple, correct CSL over
inventing new host-side protocols."""


q_analyse_cuda_source = """Analyse the following CUDA kernel.
Provide:
1. A concise summary of the computation.
2. The mathematical formula or algorithm.
3. The logical inputs and outputs.
4. The CUDA execution strategy that must be mapped into Cerebras semantics.
5. The main translation constraints to preserve correctness in CSL.

CUDA source:
```cuda
{cuda_code}
```
"""


q_design_architecture = """You are the ARCHITECT. Your job is to decide how this CUDA kernel
maps onto the Cerebras Wafer-Scale Engine before any CSL is written. You do NOT write
CSL in this step — you produce a one-page design memo (DESIGN.md) that the IMPLEMENTER
will follow.

Treat the reference bundle's `layout.csl` and `run.py` (summarised in the contract
below) as immutable: the mesh shape, the exported symbols, and the H2D/D2H tensor
shapes are already fixed. Your design must respect them. Your job is to fill in the
INTERIOR of the kernel — how data flows between PEs, what each PE computes, what gets
reduced where.

Your DESIGN.md should be in plain markdown and cover (in your own words, not as a
schema):

1. **Mesh and tensor layout** — what's the mesh shape (from layout.csl)? For each
   input/output tensor named in the contract, which decomposition (replicated /
   1d-along-x / 1d-along-y / row-tiled / col-tiled / 2d-block /
   replicated-with-halo) does it use? Give concrete per-PE tile dimensions, not just
   names.
2. **Algorithm and data flow** — describe the step-by-step compute and communication.
   "Step 1: each PE loads its A-tile and the broadcast x. Step 2: local FMA over
   Mt rows × Nt cols. Step 3: reduce partial sums along Y. Step 4: gather to host."
   Be specific about which mesh axis carries which traffic.
3. **Memory budget** — sum the per-PE buffers. Per PE has ~48 KB SRAM total; aim
   for ≤ 40 KB to leave room for stacks and instruction memory. Show the
   arithmetic. If the budget is tight, say what you'd retile.
4. **Bandwidth accounting** — what's the dominant cost? A reduction down a column
   of P PEs of K elements costs ~K · log₂(P) cycles. A row-broadcast of an Mt·Nt
   tile costs ~(P-1) · Mt · Nt cycles on the slowest edge. Estimate the largest
   one. (Rough order of magnitude is enough.)
5. **Collective library choice** — `<collectives_2d>` (easier, ~10–20% latency
   tax) or custom fabric colors (tighter, more work). Justify in one sentence.
6. **Patterns you'll use** — name 1–3 entries from the Wafer-scale CSL patterns
   catalog below that the implementer should adapt. If none fit (e.g., this is a
   single-PE kernel), say so explicitly.
7. **Edge cases / determinism hazards** — name at least one input shape or value
   pattern that might break the design (uneven shard, all-equal values, tie in
   reduction, K=1, K=N). Say how the design handles it, or flag it as a known
   risk.
8. **Trade-offs and what you'd revisit** — one sentence: if this design didn't
   meet the perf budget, what would you change?
9. **Resource allocation table** — list each user color, task ID, and queue ID
   you intend the compute file to use. Note which are already taken by
   layout.csl (you can see them in the layout below). Format as a table:
   `| Resource | ID | Purpose | Owner |`. Remember: task IDs valid in [8,31),
   queues 0-1 reserved by memcpy, colors 0-7 reserved by system.
10. **Per-PE buffer inventory** — for each array the compute file will declare,
    give: name, element type, element count expression, and purpose. Sum the
    total bytes and compare to the 40 KB safe budget.

Hard rules:
- If the reference layout is 1×1 (single-PE kernel), say so in section 1 and skip
  sections 4–6 — but still cover 2 (compute steps), 3 (memory), and 7 (edge cases).
- Be specific. "Tile A is row-tiled" is not enough; say "A is row-tiled; each PE
  owns Mt = matrix_rows / kernel_rows = 256 rows of length 32".
- Don't invent new exported symbols, new files, or host-side protocol changes.
- Don't write CSL code. The implementer needs your reasoning, not a half-finished
  kernel.

Architecture context and patterns catalog (use these to ground your reasoning):
{knowledge_base}

## layout.csl — the immutable interface (read this carefully)
This is the layout your design must accept as a fixed constraint: the
mesh shape, the exported task IDs, the struct param fields, and the
compute-file symbols layout.csl references by name are all already
decided. Your design fills in the COMPUTE that consumes them.

```csl
{layout_text}
```

Reference bundle contract (run.py + command script):
{reference_contract}

CUDA analysis:
{cuda_analysis}

CUDA source:
```cuda
{cuda_code}
```

Emit the DESIGN.md as plain markdown. No JSON, no code fences around the whole
output. Section headers (`### 1. Mesh and tensor layout`, etc.) are encouraged.
"""

# Backward-compat alias for any caller still using the old name.
q_plan_mesh_decomposition = q_design_architecture


q_translate_from_template = """Complete the CSL template below to translate the given
CUDA kernel. The template contains pre-verified boilerplate (imports, memcpy,
timestamps, exit task, and for multi-PE kernels: the full send/recv/sync machinery).
You fill in ONLY the marked SLOT sections with kernel-specific computation.

CRITICAL RULES:
1. Do NOT modify, remove, or rewrite any code outside the SLOT markers.
2. Do NOT add new @import_module, @get_local_task_id, @get_output_queue, or
   @get_input_queue declarations outside the designated slots.
3. Use DSD bulk operations (@fmuls, @fadds, @fmacs, @fmovs) instead of scalar
   loops wherever possible — they are 10-100x faster on WSE.
4. Match the host contract exactly: check run.py for expected symbol names.
5. Return the COMPLETE file (template + your filled slots) in a ```csl fence.

{csl_template}

{task_summary}

CUDA analysis:
{cuda_analysis}

CUDA source:
```cuda
{cuda_code}
```

{builtin_whitelist}
"""


q_translate_cuda_to_csl_bundle = """Translate the following CUDA kernel into a CSL compute file
that replaces `{target_relpath}` inside an existing reference bundle.

You are NOT shown the reference CSL — only the CUDA source, the task
description, and the launch contract (layout.csl + run.py + command script,
all of which your CSL must plug into unchanged). Write the CSL from first
principles based on the task description and the CUDA algorithm.

Hard requirements:
1. Only return the contents of `{target_relpath}`.
2. Keep the external contract compatible with the existing `layout.csl`, `run.py`,
   and command script.
3. Preserve the exported symbols, entrypoint name, compile-time params, and data layout
   expectations described in the reference contract.
4. Match the CUDA algorithm semantically.
5. Do not invent new host-side setup, new exported symbols, or new files.
6. If the launch contract exports `f_tic` and `f_toc`, define them with the
   canonical bodies `timestamp.get_timestamp(&tscStartBuffer); sys_mod.unblock_cmd_stream();`
   and `timestamp.get_timestamp(&tscEndBuffer); sys_mod.unblock_cmd_stream();`
   respectively (so the host's tic()/toc() measurement matches the canonical
   pattern). A post-translate validator will reject the CSL if these bodies
   are non-canonical.
   **CRITICAL — enable the timestamp counter:** `get_timestamp()` reads a
   hardware counter that is OFF until you call `timestamp.enable_tsc()` exactly
   once, in the startup task (the task bound to `STARTUP`), BEFORE any tic/toc
   fires. If you write a startup task, its body MUST call
   `timestamp.enable_tsc();`. Omitting it does NOT fail correctness — the kernel
   still computes the right answer — but the timer stays frozen and reports an
   absurd cycles_send (single digits). A measurement guard will REJECT any run
   whose cycles_send is implausibly small, so a kernel without enable_tsc()
   scores as a failure even though its output is correct.

CSL structural idioms you must follow (these are the rules the reference
CSL bundles encode by example; without the reference shown, you must apply
them yourself):

  a. **`@export_symbol`, `@bind_*_task`, `@activate`, `@set_*_color_config`,
     `@set_tile_code` must appear INSIDE a top-level `comptime {{ ... }}`
     block**, NOT at file top level. Multiple comptime blocks per file are
     fine; conventionally one for task bindings + activations, another for
     symbol exports.

  b. **To export a host-visible buffer**: declare backing storage first,
     then a pointer, then export the pointer. Pattern:
        ```
        var x = @zeros([MAX_ZDIM]f32);          // backing storage
        var ptr_x: [*]f32 = &x;                 // pointer
        comptime {{ @export_symbol(ptr_x, "x"); }}
        ```
     Do NOT write `var x: [*]f32;` (forward-declared pointer with no storage).

  c. **Use the helpers the imported modules expose**, do NOT roll your own.
     In particular, if you import `<memcpy/memcpy>` as `sys_mod`, release
     the cmd stream with `sys_mod.unblock_cmd_stream()`, not with a
     hand-written `fn unblock_cmd_stream() {{ @unblock(0); }}`.

  d. **Exported entry-point functions** named in the launch contract (e.g.
     `f_spmv`, `f_sync`) must each end with `sys_mod.unblock_cmd_stream();`
     so the host can chain the next `simulator.launch(...)` call.

{knowledge_base}

{task_summary}

Architecture decision (from the architect agent — apply this design; deviate only
if the reference contract makes it impossible, and note any deviation in a brief
comment at the top of the file):
{decomposition_plan}

## layout.csl — the EXACT interface your CSL must integrate with
Read this carefully BEFORE writing any compute code. The names and types
below are the hard contract:
  - which task IDs `layout.csl` exports (these are the entrypoints your
    compute file must @bind_*_task / @export_symbol with the EXACT same
    names)
  - what fields its struct params contain (e.g. `stencilParams.fabin_dsd`,
    `memcpyParams.x_config`) — your code must reference these fields verbatim
  - which compile-time params get passed through (so don't introduce a new
    one or rename one)
  - which compute-file symbols `layout.csl` references by name (these must
    exist in your output with matching types)
If you reference a field or symbol that isn't here, the compile will fail
with "undeclared identifier" — a contract violation, not a translation bug.

```csl
{layout_text}
```

{translation_facts}

Reference bundle contract (= launch protocol; run.py + command script that
your CSL must plug into unchanged):
{reference_contract}

CUDA analysis:
{cuda_analysis}

CUDA source:
```cuda
{cuda_code}
```

{builtin_whitelist}

Return the final compute file in a ```csl code fence.
"""


q_translate_cuda_to_csl_codesign = """Translate the following CUDA kernel into a COMPLETE
two-file CSL program: the per-PE compute file `{target_relpath}` AND the wafer
`layout.csl`. This is full CO-DESIGN — you author the routing and the compute
together, because for some kernels the data movement and the compute must be
designed as one system.

You are NOT shown any reference CSL (neither the compute file NOR layout.csl).
Design both from first principles, from the CUDA algorithm + the task
description + the launch contract (run.py + command script) below.

You MUST emit EXACTLY TWO fenced code blocks, each tagged with its path:
```csl:{target_relpath}
// per-PE compute
```
```csl:layout.csl
// wafer layout + routing
```
Emit nothing else outside the two fences.

### Division of responsibility
`layout.csl` owns the wafer-level design and MUST:
  - `@set_rectangle(W, H)` the PE grid (sized from the compile params P/Nt etc.);
  - import `<memcpy/get_params>` and pass each PE its `memcpy.get_params(x)`;
  - `@set_tile_code(x, y, "{target_relpath}", params)` to place compute on PEs
    (you MAY place a different file on some PEs — if so, emit that file as a third
    `csl:<name>` fence; simplest is to make EVERY PE run `{target_relpath}` and
    branch on its (px,py) role internally);
  - define colors via `@get_color(...)` and configure ALL inter-PE routing with
    `@set_color_config(x, y, color, .{{ .routes = ..., .switches = ... }})` — this
    is the data-movement plan the compute relies on; design it so every wavelet a
    PE receives is sent by exactly one PE (a receive with no matching send
    deadlocks → host D2H reads 0 bytes);
  - `@export_name(...)` every host-visible symbol + entrypoint the launch
    contract calls (see contract below).

`{target_relpath}` owns the per-PE compute and MUST:
  - take the params layout.csl passes it (memcpy params, px/py, sizes, colors,
    task ids) as `param` declarations;
  - implement the algorithm using fabric DSDs over the colors layout.csl routes;
  - define and export the entrypoints the launch contract calls.

### The interface contract (from run.py + the command script — honor EXACTLY)
The host (run.py) memcpy's data to/from named symbols and launches named RPC
entrypoints. Your two files MUST export, with these EXACT names, whatever the
contract below references (symbol names, entrypoint fns, and the compile-time
`--params=` names). Read the contract carefully; a missing/renamed export is a
contract violation, not a translation bug.

### Hard requirements
1. Emit BOTH files complete and compilable — never pseudocode, prose, "step(k):"
   sketches, or `...` placeholders. cslc fails on line 1 of any such file.
2. Never ship a knowingly-partial kernel — the host verifies the FULL result.
3. Resource discipline (platform facts, true for all kernels): with `<memcpy>`
   active, input-queue 0 (H2D) and output-queue 0 (D2H) plus a low task-id band
   (~21-31) are reserved — start user queues at 2+ and user/colored task ids at
   8+. local task ids valid only in [8,31). DSD `.extent` must be comptime-known.
4. Timer: `get_timestamp()` reads a counter that is OFF until `timestamp.enable_tsc()`
   is called once (in the startup task) before any tic/toc. A run whose
   cycles_send is implausibly small is REJECTED as a dead timer.
5. `@export_symbol`/`@bind_*_task`/`@activate`/`@set_*` go INSIDE top-level
   `comptime {{ }}` blocks. Export a host buffer via backing-storage → pointer →
   `@export_symbol(ptr, "name")`, with a matching `@export_name` in layout.csl.

{knowledge_base}

{task_summary}

Architecture decision (from the architect agent — apply this design; it covers
BOTH the decomposition and the routing):
{decomposition_plan}

Reference bundle contract (= launch protocol; run.py + command script that your
two files must plug into unchanged — this is your interface spec):
{reference_contract}

CUDA analysis:
{cuda_analysis}

CUDA source:
```cuda
{cuda_code}
```

{builtin_whitelist}

Return EXACTLY two fenced blocks: ```csl:{target_relpath} and ```csl:layout.csl.
"""


csl_bundle_fix = """The translated CSL compute file did not pass the staged bundle benchmark.

You must repair only the compute file while preserving compatibility with the
reference bundle.

Current compute file:
```csl
{current_code}
```

Reference contract:
{reference_contract}

Benchmark status: {benchmark_status}
Failure reason: {failure_reason}

Command transcript:
{command_transcript}

Return the corrected compute file in a ```csl code fence.
"""


Instruction_system_csl_optimization = """You are optimizing a CSL compute file inside an existing
reference bundle. Preserve the bundle contract exactly. Do not change exported symbols,
entrypoint names, parameter names, or host-visible data layout assumptions.

Your changes must stay local to the compute file and keep the same numerical behavior."""


# =============================================================================
# CSL_OPTIMIZATION_STEPS — the angle catalog
# =============================================================================
# Each entry is a dict with: description, applicable_groups, source_skill,
# knowledge_query_hint. The optimizer's per-round selector picks ONE angle
# name from the kernel's spec.yaml whitelist; the description goes into
# the optimizer prompt; the knowledge_query_hint is passed to
# csl_knowledge_base.for_optimization() so the right tutorial/skill chunks
# surface in the retrieval window.
#
# Provenance: angles are sourced from the cerebras-csl-skills SKILL-*.md
# files (specific file:line refs in `source_skill`) and from the
# csl-examples/tutorials/ progression (gemv-00→09, topic-09 FIFOs,
# topic-10 @map, topic-15 WSE-3 microthreads). NOT invented — every
# angle maps onto a documented Cerebras-blessed lever.
#
# applicable_groups uses the same vocabulary as kernels/SPEC_SCHEMA.md's
# `group` field: gemv | gemm | stencil | linalg | fft | reduction | app | sparse
# Use "all" if the lever applies kernel-agnostically.
#
# Backward compat: CSL_OPTIMIZATION_STEPS.get(name, name) is used in two
# places to extract a description, so we expose a __getitem__ on the catalog
# that returns the description string. See CSL_OPTIMIZATION_STEPS_DESC below.

# `applicable_bottlenecks` — the structural signals (detected by the
# static profiler in cuda2csl._profile_bottleneck_signature) that this
# angle is designed to address. The deterministic matcher prefers angles
# whose applicable_bottlenecks INTERSECT the current kernel's bottleneck
# signature. When no intersection, the selector falls back to free-form
# reasoning over the whole whitelist (the "widen the search" path the user
# called for, rather than firing in the dark).
CSL_OPTIMIZATION_STEPS_CATALOG = {
    "task_simplify": {
        "description": (
            "Simplify and tighten the task/dataflow structure while preserving the existing "
            "entrypoint sequence and collective behavior."
        ),
        "applicable_groups": ["all"],
        "applicable_bottlenecks": ["task_proliferation", "polling_async"],
        "source_skill": "SKILL-TASKS.md (general)",
        "knowledge_query_hint": "task dataflow simplify entrypoint",
    },
    "buffer_cleanup": {
        "description": (
            "Clean up local buffer, DSD, and temporary storage usage to reduce unnecessary "
            "state while keeping the same interface and computation."
        ),
        "applicable_groups": ["all"],
        "applicable_bottlenecks": ["redundant_buffer", "dsd_rebuild_in_loop", "large_runtime_table"],
        "source_skill": "SKILL-STORAGE.md (general)",
        "knowledge_query_hint": "buffer dsd storage cleanup",
    },
    "comptime_cleanup": {
        "description": (
            "Improve comptime/constants usage and remove avoidable runtime overhead without "
            "changing the external contract."
        ),
        "applicable_groups": ["all"],
        "applicable_bottlenecks": ["runtime_size_in_inner_loop", "redundant_runtime_const"],
        "source_skill": "SKILL-COMPTIME.md (general)",
        "knowledge_query_hint": "comptime constant cleanup",
    },
    "dsd_offset_chaining": {
        "description": (
            "Replace per-iteration DSD construction inside loops with @increment_dsd_offset. "
            "In matrix column loops, offset a pre-built mem1d_dsd by the loop index rather than "
            "constructing a new DSD each iteration. "
            "Example pattern:\n"
            "  const dsd_A_tile = @get_dsd(mem1d_dsd, .{ .tensor_access = |i|{Mt} -> A_tile[i*@as(i16,Nt)] });\n"
            "  for (@range(i16, Nt)) |j| {\n"
            "    const dsd_col = @increment_dsd_offset(dsd_A_tile, j, f32);\n"
            "    @fmacs(dsd_result, dsd_result, dsd_col, x_tile[j]);\n"
            "  }"
        ),
        "applicable_groups": ["gemv", "gemm", "stencil", "linalg", "fft", "reduction"],
        "applicable_bottlenecks": ["dsd_rebuild_in_loop"],
        "source_skill": "SKILL-DSDS.md:209-219",
        "knowledge_query_hint": "increment_dsd_offset mem1d_dsd matrix column loop",
    },
    "fmac_bulk": {
        "description": (
            "Replace scalar element-wise loops with @fmacs / @fadds operating on full mem1d_dsd arrays. "
            "Build a mem1d_dsd for each array once using tensor_access, then pass DSDs directly to "
            "@fmacs(dst_dsd, accum_dsd, src_dsd, scalar) to process all Mt or Nt elements in one call "
            "instead of a Python-style element loop. "
            "Example: @fadds(dsd_local_prod, dsd_local_prod, dsd_b_tile) replaces a for-loop add."
        ),
        "applicable_groups": ["gemv", "gemm", "linalg", "reduction", "fft"],
        "applicable_bottlenecks": ["scalar_loops_over_arrays", "separate_mul_then_add"],
        "source_skill": "SKILL-BUILTINS.md:151-165, SKILL-DSDS.md:259-263",
        "knowledge_query_hint": "@fmacs @fadds bulk mem1d_dsd fused multiply add",
    },
    # --------------------------------------------------------------------
    # Angles distilled from the 2026-06-04 Laplacian2D-Halo run (6/15
    # accepts, 1709 → 671 cycles, 2.55x). Five of those six accepts
    # independently rediscovered the same pattern: replace per-row scalar
    # `while` loops that stage halo columns into send buffers with strided
    # mem1d_dsd + @fmovs. Promoting it to a named angle so the scheduler
    # tries it directly on future stencil kernels instead of waiting for
    # comptime_cleanup / dsd_offset_chaining / stride_optimization to all
    # discover the same thing one at a time.
    # --------------------------------------------------------------------
    "column_gather_via_strided_dsd": {
        "description": (
            "Replace a per-row scalar `while` loop that stages east/west boundary columns "
            "into a contiguous send buffer with two `@fmovs` calls over stride-Nt "
            "`mem1d_dsd`s, wrapped in an `extract_columns()` helper. The DSD hardware "
            "streams Mt elements without per-iteration loop overhead (index increment, "
            "compare, branch, address recompute) — collapsing dozens of scalar "
            "instructions into one issue each.\n"
            "Pattern:\n"
            "  const tile_col_w_dsd = @get_dsd(mem1d_dsd, .{ .tensor_access = |i|{Mt} -> tile[i*Nt] });\n"
            "  const tile_col_e_dsd = @get_dsd(mem1d_dsd, .{ .tensor_access = |i|{Mt} -> tile[i*Nt + (Nt-1)] });\n"
            "  fn extract_columns() void {\n"
            "      @fmovs(col_send_w_dsd, tile_col_w_dsd);\n"
            "      @fmovs(col_send_e_dsd, tile_col_e_dsd);\n"
            "  }\n"
            "Discovered 5/6 times in the Laplacian2D-Halo run via comptime_cleanup, "
            "dsd_offset_chaining, stride_optimization, comptime_value_tuning, "
            "circbuf_save_address (each rediscovered the same fix)."
        ),
        "applicable_groups": ["stencil", "halo_exchange", "linalg"],
        "applicable_bottlenecks": [
            "scalar_loops_over_arrays", "dsd_rebuild_in_loop",
            "runtime_size_in_inner_loop",
        ],
        "source_skill": "explored/Laplacian2D-Halo accepts (2026-06-04)",
        "knowledge_query_hint": (
            "column stage halo strided mem1d_dsd @fmovs extract_columns "
            "boundary pack stencil send buffer"
        ),
    },
    "per_row_dsd_unroll": {
        "description": (
            "Issue per-row stencil contributions via `@increment_dsd_offset(base_row_dsd, "
            "i*Nt, f32)` inside an `inline for` over comptime `Mt`, reusing one base "
            "DSD instead of re-issuing descriptors each iteration. The compiler folds "
            "extents and strides at compile time and the hardware streams contiguous "
            "spans instead of executing per-element address arithmetic.\n"
            "Pattern:\n"
            "  const tile_row0_dsd = @get_dsd(mem1d_dsd, .{ .tensor_access = |j|{Nt} -> tile[j] });\n"
            "  inline for (@range(i16, Mt)) |i| {\n"
            "      const row_dsd = @increment_dsd_offset(tile_row0_dsd, i*Nt, f32);\n"
            "      @fmacs(new_row_dsd, new_row_dsd, row_dsd, weight);\n"
            "  }\n"
            "Best applied when Mt is a small comptime constant; for large Mt the "
            "unroll cost dominates and a runtime for-loop with DSD chaining wins."
        ),
        "applicable_groups": ["stencil", "linalg", "gemm"],
        "applicable_bottlenecks": [
            "scalar_loops_over_arrays", "dsd_rebuild_in_loop",
        ],
        "source_skill": (
            "explored/Laplacian2D-Halo:comptime_value_tuning + "
            "Cholesky:comptime_value_tuning + "
            "GEMM_Collectives_2D:per_row_dsd_unroll (2026-06-04); "
            "auto-detected as cross-kernel pattern by "
            "optimization_tree.detect_patterns (3 kernels)"
        ),
        "knowledge_query_hint": (
            "increment_dsd_offset inline for comptime Mt Nt row stencil unroll "
            "base row dsd reuse linalg gemm tile traversal"
        ),
    },
    # ------------------------------------------------------------------
    # Promoted 2026-06-04 from optimization_tree.promotion_candidates:
    # hoist_comptime_constants — detected on Cholesky (buffer_cleanup +
    # comptime_value_tuning), GEMM (comptime_value_tuning), and
    # Laplacian2D-Halo (comptime_cleanup + comptime_value_tuning).
    # Distinct from generic comptime_hoist: this one targets explicit
    # derived constants (MN, MN_MINUS_NT, NT_MINUS_1, QUARTER, etc) that
    # let the compiler fold extents/strides at the DSD boundary.
    # ------------------------------------------------------------------
    "hoist_comptime_constants": {
        "description": (
            "Hoist EXPLICIT derived constants (composite of comptime params, "
            "e.g. `MN = Mt*Nt`, `MN_MINUS_NT`, `NT_MINUS_1`, `QUARTER = N/4`) "
            "into `const` declarations at module scope. The compiler folds "
            "them into DSD extents and stride arithmetic at compile time, "
            "eliminating per-iteration recomputation. This is a more "
            "concrete sibling of `comptime_hoist`: rather than 'remove "
            "@as casts', it CREATES new comptime intermediates that make "
            "the DSD descriptors statically sizeable.\n"
            "Pattern:\n"
            "  const MN: i16 = @as(i16, Mt) * @as(i16, Nt);\n"
            "  const MN_MINUS_NT: i16 = MN - @as(i16, Nt);\n"
            "  const NT_MINUS_1: i16 = @as(i16, Nt) - 1;\n"
            "  const tile_full_dsd = @get_dsd(mem1d_dsd, .{ .tensor_access = |i|{MN} -> tile[i] });\n"
            "  const interior_dsd  = @get_dsd(mem1d_dsd, .{ .tensor_access = |i|{MN_MINUS_NT} -> tile[i+Nt] });\n"
            "Pairs naturally with `per_row_dsd_unroll`."
        ),
        "applicable_groups": ["stencil", "linalg", "gemm", "reduction"],
        "applicable_bottlenecks": [
            "runtime_size_in_inner_loop", "redundant_at_cast",
            "dsd_rebuild_in_loop",
        ],
        "source_skill": (
            "explored/Cholesky:buffer_cleanup + Laplacian2D-Halo:comptime_cleanup "
            "+ GEMM:comptime_value_tuning (2026-06-04); auto-detected as "
            "cross-kernel pattern by optimization_tree.detect_patterns "
            "(3 kernels)"
        ),
        "knowledge_query_hint": (
            "hoist comptime const MN MN_MINUS_NT NT_MINUS_1 QUARTER derived "
            "constant fold extent stride dsd tensor_access compile time"
        ),
    },
    "comptime_hoist": {
        "description": (
            "Move bounds and sizes that depend only on comptime params (Mt, Nt, Pw, Ph) out of runtime "
            "expressions. Replace @as(i16, Mt) casts with the param directly where the type already matches. "
            "Use comptime values directly in @range() calls. Remove runtime conditionals whose condition "
            "can be evaluated at compile time from the available comptime params."
        ),
        "applicable_groups": ["all"],
        "applicable_bottlenecks": ["runtime_size_in_inner_loop", "redundant_at_cast"],
        "source_skill": "SKILL-COMPTIME.md:97-104, 244-246",
        "knowledge_query_hint": "comptime hoist param @range runtime to compile time",
    },
    # ----- New angles from cerebras-csl-skills + csl-examples scan -----
    "memory_simd_alignment": {
        "description": (
            "Align array base addresses so SIMD-8 (WSE-3) or SIMD-4 (WSE-2) memory reads "
            "satisfy the bank-pair rule: (src0_addr % 8) == ((src1_addr + 4) % 8). "
            "Misaligned operands collapse SIMD throughput to SIMD-1/2, ~2-4x slower. "
            "Fix by applying align(8) on hot arrays or by reshaping the data layout so "
            "the inner loop hits operands whose lower 3 bits cooperate."
        ),
        "applicable_groups": ["gemm", "linalg", "fft", "stencil"],
        "applicable_bottlenecks": ["bad_stride_hint", "narrow_simd_use"],
        "source_skill": "SKILL-SIMD.md:36-46",
        "knowledge_query_hint": "SIMD alignment bank conflict memory pair align(8)",
    },
    "stride_optimization": {
        "description": (
            "Ensure inner-loop access strides hit (stride mod 8) ∈ {0,1,2,3,5,6} — these "
            "preserve full SIMD width. Strides of {4,7} mod 8 force serialization. "
            "If a column walk over row-major data has bad stride, transpose the data upfront "
            "(cost amortizes over many iterations) or reshape the access pattern."
        ),
        "applicable_groups": ["gemm", "stencil", "linalg", "fft"],
        "applicable_bottlenecks": ["bad_stride_hint", "narrow_simd_use"],
        "source_skill": "SKILL-SIMD.md:48-57",
        "knowledge_query_hint": "stride SIMD mod 8 column row major transpose",
    },
    "fabric_simd_packing": {
        "description": (
            "Pack multiple 16-bit ops per fabric wavelet via explicit .simd_mode on fabout_dsd. "
            "Doubles wavelet bandwidth by packing 2 (simd_32) or 4 (simd_64) ops per wavelet. "
            "Example: const out_dsd = @get_dsd(fabout_dsd, .{ .extent = 10, .fabric_color = c, "
            ".simd_mode = .{ .simd_32 = true } }); — extent must be divisible by the packing factor."
        ),
        "applicable_groups": ["reduction", "app", "sparse", "stencil"],
        "applicable_bottlenecks": ["unpacked_fabric_out", "many_small_wavelets"],
        "source_skill": "SKILL-SIMD.md:68-91",
        "knowledge_query_hint": "fabric SIMD packing simd_32 simd_64 fabout_dsd wavelet bandwidth",
    },
    "comptime_hoisting_tables": {
        "description": (
            "Move table/lookup builds from runtime to compile time: "
            "const T: [256]f16 = comptime build_table(N); — baked into the ELF, zero runtime "
            "init cycles. Costs PE memory (48 KiB SRAM limit), so use for tables that are "
            "smaller than ~few KiB. Especially useful for FFT twiddle factors, sin/cos LUTs, "
            "and precomputed basis vectors in iterative solvers."
        ),
        "applicable_groups": ["fft", "linalg", "reduction", "app"],
        "applicable_bottlenecks": ["large_runtime_table", "runtime_const_init"],
        "source_skill": "SKILL-COMPTIME.md:244-246",
        "knowledge_query_hint": "comptime const table precompute twiddle LUT ELF baked",
    },
    "param_specialization": {
        "description": (
            "Prefer comptime `param` over runtime `var` for dimensions and small constants "
            "the host already knows (M, N, tile sizes). Each distinct param binding spawns a "
            "specialized binary with optimal unrolling and zero-cost dispatch. Cost: larger "
            "binaries per parameterization set."
        ),
        "applicable_groups": ["gemm", "gemv", "linalg", "stencil"],
        "applicable_bottlenecks": ["runtime_size_in_inner_loop", "var_used_where_param_works"],
        "source_skill": "SKILL-COMPTIME.md:22-32",
        "knowledge_query_hint": "param comptime specialization unrolling dimension",
    },
    "task_chaining_unblock_activate": {
        "description": (
            "Replace polling/busy-wait completion checks with .activate or .unblock "
            "options on async DSD ops. The scheduler wakes the next task on completion; "
            "polling from inside a task wastes cycles. "
            "Pattern: @mov16(dst, src, .{ .async = true, .activate = next_task });"
        ),
        "applicable_groups": ["all"],
        "applicable_bottlenecks": ["polling_async", "sync_fabric_ops"],
        "source_skill": "SKILL-TASKS.md:95-107",
        "knowledge_query_hint": "task chaining activate unblock async DSD polling waste",
    },
    "async_detach_overlap": {
        "description": (
            "Add .async = true to fabric send/recv DSD ops so the task body continues while "
            "the op runs on a microthread. Lets you overlap compute and communication. "
            "Pattern: @fadds(fifo, in_dsd, ten_dsd, .{ .async = true }); — task body advances "
            "while the add streams data through the FIFO."
        ),
        "applicable_groups": ["all"],
        "applicable_bottlenecks": ["sync_fabric_ops", "serialized_compute_and_comm",
                                   "model_stalled", "model_low_ut_occupancy"],
        "source_skill": "SKILL-DSDS.md:276-303; FINDINGS.md §6, §10k (a DSD op holds the issue slot: "
                        "overlap is between ASYNC DSD ops on distinct microthreads, not scalar work)",
        "knowledge_query_hint": "async detach overlap fabric compute microthread FIFO",
    },
    "microthread_explicit_wse3": {
        "description": (
            "On WSE-3, use explicit .ut_id = @get_ut_id(N) to decouple microthread identity "
            "from queue id. Same queue can drive two concurrent microthreads; same microthread "
            "can serve multiple queues. Conserves microthread resources. "
            "WSE-3 ONLY — WSE-2 derives microthread from queue id implicitly."
        ),
        "applicable_groups": ["all"],
        "applicable_bottlenecks": ["microthread_collision_hint", "many_async_same_queue",
                                   "model_stalled", "model_low_ut_occupancy"],
        "source_skill": "SKILL-MICROTHREADS.md:5-90, topic-15-wse3-microthreads; FINDINGS.md §6/§11 "
                        "(IPC < 0.35 means the core is waiting; the corpus uses <= 2 microthreads, "
                        "expert code ids 0-5; concurrent async DSD ops need DISTINCT ut_ids)",
        "knowledge_query_hint": "microthread ut_id WSE-3 explicit queue concurrent",
    },
    "circbuf_save_address": {
        "description": (
            "For sequential chunk processing through a sliding window, use @load_to_dsr with "
            ".save_address = true. Hardware auto-advances the DSR base on each op; no explicit "
            "DSD rebuild or pointer math needed. Common in 3D stencils, streaming convolutions, "
            "and sliding-window predictors."
        ),
        "applicable_groups": ["stencil", "fft", "app"],
        "applicable_bottlenecks": ["circular_buffer_manual", "dsd_rebuild_in_loop"],
        "source_skill": "SKILL-DSRS.md:125-138",
        "knowledge_query_hint": "circular buffer DSR save_address sliding window stencil",
    },
    "data_layout_transpose": {
        "description": (
            "When the inner loop hits a bad stride (mod 8 ∈ {4,7}), transpose the data layout "
            "upfront so the inner loop walks at stride 1 (or another SIMD-friendly stride). "
            "Trade-off: transpose has its own cost; only wins if the loop runs enough iterations "
            "to amortize. Common in dense linalg and 2D FFT stages."
        ),
        "applicable_groups": ["gemm", "linalg", "fft"],
        "applicable_bottlenecks": ["bad_stride_hint"],
        "source_skill": "SKILL-SIMD.md:57",
        "knowledge_query_hint": "transpose data layout stride row major column major reshape",
    },
    "prefetch_fabric_async": {
        "description": (
            "Hide fabric receive latency (10-20+ cycles) by issuing async @load_to_dsr with "
            ".activate = compute_task BEFORE the compute that needs the data. The activate "
            "wakes the compute task only when the fabric receive completes — meanwhile the "
            "current task body keeps running. Useful for streaming receive-heavy kernels."
        ),
        "applicable_groups": ["reduction", "app", "linalg"],
        "applicable_bottlenecks": ["sync_fabric_ops", "serialized_compute_and_comm"],
        "source_skill": "SKILL-DSRS.md:118-123",
        "knowledge_query_hint": "prefetch fabric receive async activate compute overlap latency",
    },
    "fifo_smoothing": {
        "description": (
            "Insert a FIFO between a producer and consumer with mismatched rates (e.g. H2D "
            "burst into a slow compute) to prevent fabric stalls. FIFO costs two microthreads "
            "and a scratch buffer but lets the producer push all data without waiting for the "
            "consumer. Pattern: topic-09-fifos and pipeline-02-fifo tutorial."
        ),
        "applicable_groups": ["app", "reduction", "stencil"],
        "applicable_bottlenecks": ["serialized_compute_and_comm", "burst_rate_mismatch"],
        "source_skill": "csl-examples/tutorials/topic-09-fifos/README.rst, pipeline-02-fifo",
        "knowledge_query_hint": "FIFO smoothing burst producer consumer fabric stall H2D",
    },
    "comptime_value_tuning": {
        "description": (
            "Try alternate values for the kernel's comptime parameters where doing so changes "
            "INTERNAL trade-offs without changing the EXTERNAL contract. Common levers: "
            "setting struct field overrides at imported-module entry, e.g. "
            "`.{ .BLOCK_SIZE = MAX_ZDIM }` in a `stencil_mod` import collapses an inner "
            "chunk loop. This is how 7pt-Stencil reached 1076 cycles (1.98× the reference). "
            "Look for: imported modules whose comptime_struct accepts a block/tile size; "
            "internal const that could be raised to take advantage of available registers/SRAM; "
            "loop unroll factors. Do NOT change host-supplied params (those are frozen by the "
            "contract validator), only INTERNAL comptime values."
        ),
        "applicable_groups": ["all"],
        "applicable_bottlenecks": ["unexplored_comptime_config"],
        "source_skill": "REPIVOT_CYCLES.md (7pt-Stencil smoke #2 finding)",
        "knowledge_query_hint": "comptime struct BLOCK_SIZE module import override tile",
    },
    "iterative_phase_fusion": {
        "description": (
            "Iterative solvers (CG, PCG, BiCGSTAB, Power-Method) launch many separate "
            "f_dot / f_axpy / f_spmv functions PER ITERATION from the host runner. Each "
            "host->device launch costs ~10-20 cycles of dispatch + a fabric-level barrier "
            "between launches. Reduce the launch count by FUSING phases that don't need "
            "host interaction between them: chain compute tasks on completion via "
            ".activate / .unblock, so one host launch triggers a sequence of "
            "device-side phases (e.g. spmv→dot→axpy) that complete without returning to "
            "the host. The exported entrypoint stays callable (contract preserved); the "
            "function's body now does the work that previously required N launches.\n"
            "\n"
            "Pattern:\n"
            "  // Before: host calls f_spmv, then f_dot, then f_axpy separately.\n"
            "  fn f_spmv() void { stencil_mod.spmv(...); sys_mod.unblock_cmd_stream(); }\n"
            "  fn f_dot()  void { reduce_mod.allreduce(...); sys_mod.unblock_cmd_stream(); }\n"
            "  fn f_axpy() void { @fmacs(...); sys_mod.unblock_cmd_stream(); }\n"
            "\n"
            "  // After: f_spmv chains the next two phases via task activation.\n"
            "  task t_dot()  void { reduce_mod.allreduce(..., t_axpy_id); }\n"
            "  task t_axpy() void { @fmacs(...); sys_mod.unblock_cmd_stream(); }\n"
            "  fn f_spmv() void { stencil_mod.spmv(..., .f_callback = t_dot); }\n"
            "  // f_dot/f_axpy still exported for host callability but are now thin "
            "  // wrappers — host only calls f_spmv to advance the whole iteration.\n"
            "\n"
            "Saves: (N-1) × dispatch_cost per iteration, where N is the number of\n"
            "fused phases. For BiCGSTAB's 17 launches/iter, fusing 3-4 phases per group\n"
            "could save ~30-60 cycles/iter, which compounds across max_ite iterations.\n"
            "\n"
            "Note: DOES NOT change the exported entrypoint NAMES (contract preserved).\n"
            "DOES change what each fn does internally: lighter phases delegate to the\n"
            "heavier one, which triggers them via activate/unblock."
        ),
        "applicable_groups": ["linalg", "reduction", "app"],
        "applicable_bottlenecks": ["many_launch_dispatched_fns", "serialized_compute_and_comm"],
        "source_skill": "SKILL-TASKS.md:95-107 (task chaining), inferred from progress_summary.md",
        "knowledge_query_hint": "task chain activate unblock fuse phases dispatch host launch",
    },

    # --------------------------------------------------------------------
    # Model-derived angles (IPDPS 2027 study). Every number below is a
    # MEASUREMENT from docs/PERFORMANCE_MODEL.md (silicon unless
    # stated); the angle text quotes the measurement rather than a rule of thumb.
    # Trigger keys `model_*` are produced by wse3_model.model_keys() from the
    # trace of the current best candidate. Flags: requires_precision_ok (only
    # when the task contract admits f16), hardware_validated (the simulator
    # cannot see the effect; admitted only with hardware acceptance),
    # codesign_only (needs an editable layout.csl).
    # --------------------------------------------------------------------
    "dsd_width_flatten_l0": {
        "description": (
            "Rewrite tile loops as ONE wide DSD operation (the 'L0' form). Measured on the "
            "same 4,096-element FMA: one wide @fmach = 1,040 cycles (0.254 cyc/elem, 98.5% of "
            "the f16 FMA peak); a `while` loop over 16-element tiles (L1) = 4,617 cycles, 4.44x "
            "slower; @map over tiles (L2) 2.73x; nested loops (L3) 2.92x. Mechanism: the PE is a "
            "single-issue in-order core with a 9-10 cycle loop back-edge and a 15-17 cycle DSD "
            "setup per dispatch; one dispatch can address up to 7,492 f16 (3,746 f32) elements "
            "per operand for a 3-operand FMA, so the whole array fits in one instruction. "
            "Build a mem1d_dsd/mem4d_dsd whose tensor_access spans the full extent (use "
            "@set_dsd_length / @increment_dsd_offset for the remainder), keep the loop only for "
            "irregular index patterns, and keep vector length far above the DSD setup cost. "
            "Do not confuse with fmac_bulk: this removes the surrounding tile loop itself."
        ),
        "applicable_groups": ["all"],
        "applicable_bottlenecks": ["model_narrow_dsd", "model_overhead_bound", "model_arithmetic_bound",
                                   "scalar_loops_over_arrays", "dsd_rebuild_in_loop"],
        "source_skill": "docs/PERFORMANCE_MODEL.md §10, §10c (loop form); microbench/loopform",
        "knowledge_query_hint": "mem1d_dsd tensor_access full extent single dispatch set_dsd_length @map while loop",
    },
    "f16_precision": {
        "description": (
            "Move INTERNAL arithmetic to f16. Measured on WSE-3 silicon: f16 FMA 2.92 elements/cycle "
            "vs f32 0.50, a 5.84x ceiling (the simulator overstates it as 8x); f16 copies 4.82 vs "
            "f32 2.44 elements/cycle. Keep every exported symbol type and the host I/O exactly as "
            "declared in layout.csl/run.py (the contract), convert once at the boundary "
            "(@f32_to_f16 / @f16_to_f32 or a typed copy), run the streaming operands and "
            "intermediates in f16, and keep accumulators, reductions and softmax statistics in f32 "
            "(the expert convention). Use only where the task's numerical tolerance admits it -- "
            "the held-out-input check decides; IEEE f16 is the default --fp16-format (cb16/bf16 "
            "fail on exported [*]f16)."
        ),
        "applicable_groups": ["all"],
        "applicable_bottlenecks": ["model_f32_arith_only", "model_arithmetic_bound"],
        "source_skill": "docs/PERFORMANCE_MODEL.md §3 (single-PE cost model, silicon), §10c",
        "knowledge_query_hint": "f16 half precision @fmach @faddh convert f32_to_f16 accumulate f32",
        "requires_precision_ok": True,
    },
    "bank_class_offset": {
        "description": (
            "Separate the SRAM bank class of a DSD operation's destination and source. The PE has 8 "
            "banks interleaved every 2 bytes, so an f32 element advances the bank by 2 and alignment "
            "classes have period 4 in the element index; a destination and a source in the SAME class "
            "cost 1.94x on silicon (up to 2.86x). The simulator does NOT model this, so the gain is "
            "invisible in simulation and this angle is admitted only under hardware acceptance. "
            "Declaration-order guard arrays are ignored by the allocator: pad INSIDE the array (allocate "
            "N+1 and index from 1, or offset the DSD base by one element) or use align() on the hot "
            "array so dest and src land in different classes."
        ),
        "applicable_groups": ["all"],
        "applicable_bottlenecks": ["model_bank_conflict_risk", "bad_stride_hint"],
        "source_skill": "docs/PERFORMANCE_MODEL.md §3 (bank conflicts, silicon), §10c",
        "knowledge_query_hint": "SRAM bank conflict alignment class offset pad array align()",
        "hardware_validated": True,
    },
    "turn_free_routing": {
        "description": (
            "Route collectives dimension by dimension so application routes add no turns. Measured "
            "fabric costs: 2.0 cycles per hop (isotropic), ~20 cycles per route turn (a turn is worth "
            "ten hops), 1.125 cycles per wavelet, and two senders sharing a link serialise. The expert "
            "WaferLLM kernels use per-dimension colours with 83-91 straight-through route entries and "
            "only 6 turns in total, all from the memcpy harness. Reduce along one axis first, then the "
            "other; give each direction its own colour; avoid RAMP->turn->RAMP relays. Requires editing "
            "layout.csl (co-design mode)."
        ),
        "applicable_groups": ["stencil", "collective", "gemm", "gemv", "linalg", "reduction", "app"],
        "applicable_bottlenecks": ["model_turns_present", "fabric_comm_dominant"],
        "source_skill": "docs/PERFORMANCE_MODEL.md §4 (fabric, silicon), §5, §7",
        "knowledge_query_hint": "route colour dimension-ordered turn layout.csl set_color_config",
        "codesign_only": True,
    },
}

# Backward-compat: CSL_OPTIMIZATION_STEPS[name] should still return a string
# description. Many call sites do CSL_OPTIMIZATION_STEPS.get(name, name).
# This wrapper preserves that contract.
class _CatalogDescAccess:
    """dict-like view over CSL_OPTIMIZATION_STEPS_CATALOG that returns just
    the description string per name. Lets existing code paths keep working
    while the new catalog carries richer metadata."""
    def __init__(self, catalog):
        self._catalog = catalog
    def __getitem__(self, key):
        return self._catalog[key]["description"]
    def get(self, key, default=None):
        entry = self._catalog.get(key)
        return entry["description"] if entry else default
    def keys(self):
        return self._catalog.keys()
    def __contains__(self, key):
        return key in self._catalog
    def __iter__(self):
        return iter(self._catalog)

CSL_OPTIMIZATION_STEPS = _CatalogDescAccess(CSL_OPTIMIZATION_STEPS_CATALOG)


def angle_metadata(name: str) -> dict:
    """Return the full metadata for an angle (description, applicable_groups,
    source_skill, knowledge_query_hint). Returns a sentinel dict with the
    name as description for unknown angles (so unknown angles degrade
    gracefully without raising)."""
    entry = CSL_OPTIMIZATION_STEPS_CATALOG.get(name)
    if entry is not None:
        return entry
    return {
        "description": name,
        "applicable_groups": ["all"],
        "source_skill": "(unknown — angle name was not in the catalog)",
        "knowledge_query_hint": name,
    }


def angles_for_group(group: str) -> list:
    """Return the list of angle names whose applicable_groups includes the
    given kernel group (or 'all'). Used as the fallback for kernels whose
    spec.yaml doesn't yet have an explicit optimization_angles whitelist."""
    matching = []
    for name, meta in CSL_OPTIMIZATION_STEPS_CATALOG.items():
        groups = meta.get("applicable_groups", ["all"])
        if "all" in groups or group in groups:
            matching.append(name)
    return matching


DEFAULT_CSL_OPT_STEPS = [
    # The 6 original generic angles — preserved as the fallback when a
    # kernel's spec.yaml doesn't supply optimization_angles.
    "task_simplify",
    "buffer_cleanup",
    "comptime_cleanup",
    "dsd_offset_chaining",
    "fmac_bulk",
    "comptime_hoist",
]

# Angles the silicon model adds to any whitelist under XKERNEL_MODEL_ANGLES=1
# (default when XKERNEL_MODEL_GUIDED=1). bank_class_offset and turn_free_routing
# are also here but gated by their flags (hardware acceptance / co-design mode);
# cuda2csl.CUDA2CSLOrchestrator._filter_angles applies the gates.
MODEL_CSL_OPT_STEPS = [
    "dsd_width_flatten_l0",
    "f16_precision",
    "microthread_explicit_wse3",
    "async_detach_overlap",
    "bank_class_offset",
    "turn_free_routing",
]


# =============================================================================
# Per-round angle selector prompt (Task A3)
# =============================================================================
# The optimizer's "selector" — a small LLM call before each optimize attempt
# that picks ONE angle from the kernel's whitelist based on the current
# code, per-fn cycles (if available), and last accepted diff. Single round-
# trip, ~300 tokens out. Output must be a single angle name from the
# whitelist. Falls back to round-robin if parsing fails.

q_optimize_select_angle = """You are picking the next optimization lever for a CSL kernel.

You will be shown:
  - The kernel's current best compute file (the agent's current best variant).
  - The current cycles_send measurement.
  - Optionally, a per-function cycle breakdown (which f_* is the bottleneck).
  - Optionally, the diff that produced the LAST accepted improvement.
  - The whitelist of optimization angles available for THIS kernel.

Your job: pick exactly ONE angle name from the whitelist. The selected
angle will be applied next; one angle per attempt so regressions are
attributable. Avoid repeating the angle that produced the last accepted
change unless the per-fn breakdown shows that function is STILL the
bottleneck.

Output format — strict, parsed by regex:
  ANGLE: <exact_angle_name_from_whitelist>
  REASON: <one short sentence on why this angle fits this code right now>

Whitelist (the only acceptable values for ANGLE):
{whitelist_block}

Kernel context:
  group:               {kernel_group}
  current cycles_send: {current_cycles}
  reference cycles:    {reference_cycles}

{bottleneck_block}

{per_fn_cycles_block}

{last_diff_block}

Current best compute file (excerpt — first {snippet_lines} lines):
```csl
{current_code_snippet}
```

Pick the angle now. Output ONLY the two lines (ANGLE:, REASON:); no preamble, no fences."""


q_optimize_csl_compute = """You are optimizing a CSL compute file to REDUCE its on-WSE cycle count.

============================================================
PRIMARY OBJECTIVE: STRICTLY FEWER cycles_send THAN THE CURRENT BEST
============================================================
Current best `cycles_send`: {current_cycles}
Your variant MUST report a smaller `cycles_send` after running. Any variant
that reports >= {current_cycles} cycles is rejected as no-improvement.

Cycle counts come from the kernel's own `tic()/toc()` interval — they
measure on-WSE compute, NOT host wall-clock. Reducing wall-clock without
reducing cycles_send does not count.

{frozen_callout_block}

Optimize the COMPUTE, not what is measured.

{knowledge_base}

{task_summary}

Optimization angle to try this attempt: `{optimization_name}`
{optimization_description}

Hard rules (correctness is a prerequisite, not a tradeoff):
1. Preserve the bundle contract exactly (exported symbols, entrypoint name,
   parameter types, expected I/O shapes).
2. Do not change which fabric colors are used, the host-runner protocol,
   or any layout.csl-visible structure.
3. The numerical output must match the reference verification exactly.
4. The FROZEN parts above pass an automated diff check against the reference;
   touching them rejects your variant regardless of cycles_send.

Reference contract (the spec you must satisfy):
{reference_contract}

Current compute file (this is what runs in {current_cycles} cycles today):
```csl
{current_code}
```

Previous benchmark summary:
{benchmark_summary}

Profiler feedback (per-PE cycle distribution + critical path hints):
{profiler_feedback}

What to look for when reducing cycles on WSE-3:
- Per-iteration DSD construction inside loops → replace with `@increment_dsd_offset`
- Scalar element-wise loops → replace with bulk `@fmacs`/`@fadds` on full mem1d_dsd
- Runtime expressions over comptime-known values → hoist to comptime
- Sequential fabric send/recv → overlap with on-PE compute via tasks
- Redundant `@as()` casts on already-correct types → remove
- Per-call `@get_dsd` inside a hot loop → cache the DSD once outside the loop
- Single-PE work that can be parallelized → split across the PE rectangle
- Long synchronous task chains → break into independent tasks unblocked in parallel

You MUST return the complete updated compute file in a ```csl code fence.
Do not explain or summarize outside the fence — put all content inside the ```csl block.
"""


# Multi-file optimize prompt — used when the planner says the optimization
# target spans multiple files (typical for "thin dispatcher" kernels like
# BiCGSTAB/CG/PCG/Power Method whose compute lives in blas.csl /
# benchmark-libs/<lib>/pe.csl rather than the root pe.csl).
#
# Differences from q_optimize_csl_compute:
#   - exposed_files_block: ALL files the LLM may see (read-only context
#     for non-focus files, editable context for focus files), each in its
#     own ```csl:relpath fence.
#   - focus_files_block: short reminder listing only the relpaths the LLM
#     is allowed to REWRITE.
#   - response contract: emit one ```csl:relpath fence per focus file.
#     Non-focus files are read-only — touching them is a contract violation.
q_optimize_csl_compute_multifile = """You are optimizing a multi-file CSL kernel to REDUCE its on-WSE cycle count.

============================================================
PRIMARY OBJECTIVE: STRICTLY FEWER cycles_send THAN THE CURRENT BEST
============================================================
Current best `cycles_send`: {current_cycles}
Your variant MUST report a smaller `cycles_send` after running. Any variant
that reports >= {current_cycles} cycles is rejected as no-improvement.

Cycle counts come from the kernel's own `tic()/toc()` interval — they
measure on-WSE compute, NOT host wall-clock. Reducing wall-clock without
reducing cycles_send does not count.

{frozen_callout_block}

Optimize the COMPUTE, not what is measured.

{knowledge_base}

{task_summary}

Optimization angle to try this attempt: `{optimization_name}`
{optimization_description}

============================================================
MULTI-FILE EDIT — important
============================================================
This kernel's compute is spread across multiple files. The planner has
chosen which ones you may rewrite (focus_files) and which are shown for
context only (read-only).

Focus files (you may REWRITE these):
{focus_files_block}

Emit ONE ```csl:<relpath> fence per focus file you ACTUALLY CHANGED.
Use the EXACT relpath shown above (the parser matches it character-for-
character). Each fence holds the complete updated body of that file.

Focus files you do NOT change can be OMITTED — the orchestrator preserves
the current state of any focus file you don't emit. So if your edit only
touches `src/blas.csl`, emit just one fence for `src/blas.csl`; you do
NOT need to echo `src/kernel_*.csl` verbatim. The acceptance gate
(cycles must strictly drop) is what actually defends against phantom
wins, NOT a contract requiring every focus file in the reply.

If you emit NO csl fences at all, the round is rejected (nothing to
benchmark).

Files NOT in the focus list are read-only. If you change a read-only
file, the contract validator rejects the round.

Reference contract (the spec all files must satisfy):
{reference_contract}

Exposed files (current state — focus files you will rewrite, plus
read-only siblings the focus files depend on):
{exposed_files_block}

Previous benchmark summary:
{benchmark_summary}

Profiler feedback:
{profiler_feedback}

What to look for when reducing cycles on WSE-3:
- Per-iteration DSD construction inside loops → replace with `@increment_dsd_offset`
- Scalar element-wise loops → replace with bulk `@fmacs`/`@fadds` on full mem1d_dsd
- Runtime expressions over comptime-known values → hoist to comptime
- Sequential fabric send/recv → overlap with on-PE compute via tasks
- Redundant `@as()` casts on already-correct types → remove
- Per-call `@get_dsd` inside a hot loop → cache the DSD once outside the loop
- Single-PE work that can be parallelized → split across the PE rectangle
- Long synchronous task chains → break into independent tasks unblocked in parallel

Response format — strictly:
- One ```csl:<relpath> fence per focus file YOU CHANGED, in any order.
- Each fence holds the COMPLETE updated body of that file.
- Omit fences for focus files you did NOT change — they are preserved.
- No prose outside the fences.

Example A — kernel whose focus_files are `pe.csl` and `src/blas.csl`,
edit touches BOTH files:

```csl:pe.csl
// complete updated pe.csl here
```

```csl:src/blas.csl
// complete updated blas.csl here
```

Example B — same focus_files, edit only touches `src/blas.csl`
(orchestrator preserves the unchanged `pe.csl` automatically):

```csl:src/blas.csl
// complete updated blas.csl here
```
"""


# =============================================================================
# Reviewer + routed-repair prompts
# =============================================================================
# The reviewer agent classifies a failed benchmark into A/B/C and the next
# repair turn is routed to a different agent based on the bucket.
#   A → architect re-spins the DESIGN.md with failure context, implementer
#       thread is reset, kernel retranslates from scratch
#   B → implementer receives the standard fix prompt enriched with the
#       reviewer's one-line rationale
#   C → implementer receives a tighter "restore the contract" prompt that
#       forbids algorithmic changes

q_review_failure = """You are the REVIEWER. A CSL kernel just failed its staged benchmark.
Your only job is to classify the failure into exactly one bucket so we route the next
fix to the right agent. Be terse — your verdict is parsed by regex.

Buckets (see the triage checklist in your knowledge context for full criteria):
- A = ARCHITECTURAL failure. The decomposition is wrong: wrong tiling, wrong
      reduction direction, memory overflow on a PE, wrong collective topology,
      reduction order produces non-deterministic output, or the design assumed
      a mesh shape that doesn't match `layout.csl`. Cannot be fixed by editing
      CSL alone — requires a new DESIGN.md.
- B = IMPLEMENTATION bug. The decomposition is right; the CSL has a local
      bug: DSD built inside a loop, missing @as(i16) cast, reserved color
      collision, missing edge guard (fabric send into a non-existent
      neighbor), a collective callback bound to the wrong task, etc.
- C = CONTRACT violation. Decomposition and algorithm are correct, but an
      exported symbol got renamed, a task ID changed, or a new file was
      introduced that `layout.csl` / `run.py` doesn't know about.

You MUST emit your verdict in EXACTLY this format. The first line is parsed
verbatim — if it doesn't match `^\\s*BUCKET\\s*:\\s*[ABC]`, we default to bucket B.

    BUCKET: <A|B|C>
    RATIONALE: <one sentence, ≤ 200 chars, naming the concrete symptom you saw>
    MISSING_SYMBOL: <REQUIRED for bucket C: the exact symbol, task ID, or
                    parameter name that the contract expects but the current
                    code does not provide. Quote it verbatim from run.py /
                    layout.csl. Examples: `states` / `task_id 12` /
                    `param Mt`. OMIT for buckets A and B.>
    SUGGESTED_DEBUG_ACTION: <one short, concrete diagnostic step the implementer
                    should take BEFORE rewriting code. Cite a specific debug
                    recipe by chunk_id where applicable (e.g., "see
                    cerebras-debug-symptom-zero-bytes-received"). Examples:
                    "insert `<debug>` library `times.trace_timestamp()` at
                    f_send/f_compute entry to localize the hang", or
                    "`csdb wavelet-trace --x 4 --y 1` on the sending PE to
                    confirm the wavelet was emitted", or "no debug needed —
                    fix is the cited compile-error line directly". Emit
                    "(none)" when stderr alone makes the fix unambiguous.>
    DESIGN_AMENDMENT: <2–4 lines pointing the architect at exactly what to change
                      in the DESIGN.md; OMIT this entire block for buckets B and C>

Reviewer knowledge (failure triage checklist + gotcha catalog):
{knowledge_base}

Original architect DESIGN.md (immutable for B/C; the thing to amend for A):
{decomposition_plan}

Reference bundle contract (any deviation from this is bucket C):
{reference_contract}

Current CSL compute file:
```csl
{current_code}
```

Benchmark status: {benchmark_status}
Failure reason:   {failure_reason}

Command transcript (compile/run stdout+stderr):
{command_transcript}
"""


csl_bundle_fix_with_review = """The translated CSL compute file did not pass the staged bundle benchmark.

REVIEWER NOTE (bucket {verdict_bucket}): {reviewer_rationale}

SUGGESTED DEBUG STEP: {debug_action}

{debugger_report}

You must repair only the compute file while preserving compatibility with the
reference bundle. If the SUGGESTED DEBUG STEP above names a concrete debug
recipe (e.g. inserting `<debug>` library traces or running `csdb wavelet-trace`),
either apply it inline as part of your repair, or — if applying it would require
host-side changes you can't make — explicitly say so in a one-line comment at the
top of the file and proceed with your best repair attempt based on the
reviewer's rationale.

Current compute file:
```csl
{current_code}
```

## layout.csl — the EXACT interface your CSL must integrate with
Re-check this against your current code: any name, task ID, struct field,
or compile-time param mismatch with `layout.csl` is a contract violation,
not a translation bug. If the failure_reason below says "undeclared
identifier", "undefined symbol", "not a member of struct", or similar,
the answer is here.

```csl
{layout_text}
```

{translation_facts}

Reference contract (run.py + command script):
{reference_contract}

Benchmark status: {benchmark_status}
Failure reason: {failure_reason}

Command transcript:
{command_transcript}

{builtin_whitelist}

Return the corrected compute file in a ```csl code fence.
If the fix also requires a custom distribution.py (e.g. to match your
decomposition's D2H collect coordinates), include it in a separate
```python distribution.py fenced block. run.py will load your
distribution.py automatically from the build directory.
"""


csl_bundle_fix_contract = """The translated CSL compute file VIOLATED the reference bundle contract.

============================================================
REQUIRED FIX: {missing_symbol}
============================================================
REVIEWER NOTE (bucket C — contract violation): {reviewer_rationale}

SUGGESTED DEBUG STEP: {debug_action}

The decomposition and algorithm are correct. The failure is that an exported symbol,
task ID, parameter name, or file structure changed away from what `layout.csl` /
`run.py` / `{commands_script}` expect. Fix ONLY the contract violation.

YOUR PRIMARY JOB: restore the symbol/task/param named in the REQUIRED FIX header
above. Read the reference contract below to find its expected name, type, and
export visibility. If the symbol is a `var`, also add the matching
`@export_symbol(&name, "name")` in the comptime block. Don't change anything else.

DO NOT:
- change the algorithm
- change DSD shapes or per-PE tile sizes
- change which fabric colors are used or their direction
- introduce new exported symbols, new task IDs, or new files

DO:
- restore the exported symbol names exactly as the contract requires
- restore task IDs / queue IDs to what the layout expects
- match the entrypoint name and signature

Current compute file:
```csl
{current_code}
```

## layout.csl — the EXACT interface (this is what your CSL must satisfy)
The missing symbol named in the REQUIRED FIX header above is referenced
here. Match its name, type, and exported visibility EXACTLY.

```csl
{layout_text}
```

{translation_facts}

Reference contract (run.py + command script):
{reference_contract}

Benchmark status: {benchmark_status}
Failure reason: {failure_reason}

Command transcript:
{command_transcript}

{builtin_whitelist}

Return the corrected compute file in a ```csl code fence.
If the contract violation is about D2H collection coordinates (e.g.
"dest tensor must be one-dimensional" or collect() geometry mismatch),
you may also need to provide a custom distribution.py. Include it in a
separate ```python distribution.py fenced block with collect() and
distribute() functions that match YOUR decomposition.
"""


# =============================================================================
# EXPLORE_CSL — autonomous CSL kernel exploration
# =============================================================================
#
# These templates power explore_csl.py. They are deliberately SEPARATE from
# the translation templates: explore mode does not have a CUDA reference to
# constrain shapes, and (for Mode B/C) does not have a hand-curated
# layout.csl / run.py reference bundle to plug into either — the implementer
# generates the entire bundle from a brief.

Instruction_system_explore = """You are an expert in Cerebras CSL programming on the WSE-3
wafer-scale engine. You are NOT translating from CUDA verbatim — you are designing and
implementing a fresh CSL kernel that:
  - solves the task described in the brief,
  - compiles cleanly with cslc --arch=wse3,
  - runs to completion in the simulator, AND
  - is numerically verified by its run.py against a host-side reference
    (numpy.testing.assert_allclose).

You will produce a self-contained bundle (pe.csl, layout.csl, run.py, and the
canonical commands_wse3.sh) — no external reference is required. Prefer the
simplest mesh shape that solves the problem; do not over-engineer.

Hard constraints:
  - Stay within the Cerebras builtin whitelist; do not invent @-builtins.
  - run.py must include numpy.testing.assert_allclose against a
    host-computed reference. Self-compares (assert_allclose(out, out)) are
    a deliberate failure.
  - The bundle must compile and verify without manual host-side tweaks.
"""


q_explore_idea = """You are designing a NEW CSL kernel for the Cerebras WSE-3, given a
high-level idea and the existing knowledge corpus. There is NO reference bundle to plug
into — you will emit a self-contained bundle (pe.csl + layout.csl + run.py +
commands_wse3.sh).

## Idea
{idea_title}: {idea_summary}

## Acceptance numerics (REQUIRED in run.py)
{acceptance_numerics}

## Layout requirements
{layout_requirements}

## Mesh hint
{suggested_mesh}

## Knowledge context (skills, tutorials, mesh patterns, prior exploration)
{knowledge_base}

## Prior lessons relevant to this round
{prior_lessons}

{builtin_whitelist}

{cycles_send_recipe}

Output FORMAT (strict — the runner parses it):

```design
<one-page DESIGN.md: mesh, decomposition, compute steps, memory budget,
edge cases. Plain markdown.>
```

```layout
<the full contents of layout.csl>
```

```pe
<the full contents of pe.csl (or the compute file the layout references)>
```

```run
<the full contents of run.py — MUST import numpy AND call
numpy.testing.assert_allclose(device_output, host_reference, ...)>
```

```commands
<the full contents of commands_wse3.sh — typically two lines: a cslc
invocation and a cs_python invocation>
```

No prose outside the fences. Use exactly the fence tags shown.
"""


q_cuda_nl_to_spec = """You are converting a widely-tried CUDA kernel into a high-level
natural-language SPECIFICATION. The downstream architect will design a wafer-native
Cerebras CSL kernel from your SPEC — NEVER from the CUDA source. Your SPEC must
therefore be free of CUDA-isms: no blockIdx/threadIdx talk, no warp/shfl primitives,
no shared-memory tiling syntax. Describe the COMPUTATION in math + data-flow terms.

## CUDA source
```cuda
{cuda_snippet}
```

## Task hint
{nl_target}

## Acceptance notes
{acceptance_notes}

Produce a SPEC in plain markdown. Required sections:

1. **Mathematical statement** — equations or pseudocode in algebraic form.
2. **Tensors** — names, shapes, dtypes, host-vs-device residency.
3. **Parallel axes** — which output dimensions can be computed independently;
   which require reductions; which require all-to-all communication.
4. **Data dependencies** — for each output element, which inputs are needed.
5. **Fusion opportunities** — which sub-passes can collapse on a wafer-scale
   architecture (e.g., online softmax: max + exp + sum into one pass per row).
6. **Numerical hazards** — overflow, underflow, NaN, ordering sensitivity,
   reduction associativity.
7. **Acceptance numerics** — exactly how the test will verify (numpy reference
   recipe + tolerance).

Hard rules:
- DO NOT mention block/thread/warp/shared-memory.
- DO NOT include CUDA code in your output.
- Output is the SPEC alone, plain markdown. No fences around the whole thing.
"""


q_cuda_nl_design_from_spec = """You are the ARCHITECT for a fresh CSL kernel. You receive
only the natural-language SPEC below (NOT the CUDA source) and must design a
wafer-native decomposition.

## SPEC
{spec}

## Mesh hint
{suggested_mesh}

## Knowledge context
{knowledge_base}

Emit a DESIGN.md in plain markdown covering:
1. Mesh shape and tensor placement (which dimension maps to X, which to Y).
2. Per-PE compute steps and reductions.
3. Communication pattern (broadcast, halo, allreduce, ring, etc.).
4. Per-PE memory budget (≤ 40 KB SRAM target).
5. Edge cases (smallest shape, divisibility, all-equal inputs).
6. Trade-offs / what you'd revisit if perf is poor.

No CSL code in this step. Free-form markdown.
"""


q_explore_variation = """You are proposing variants of an EXISTING passing CSL kernel.
The baseline bundle below works and verifies. Your job: propose up to {n_variants}
small variations along ONE permitted axis per variant. Output JSON.

## Baseline bundle (passing)
### layout.csl
```csl
{baseline_layout}
```

### compute file
```csl
{baseline_pe}
```

### run.py (host driver)
```python
{baseline_run_py}
```

## Permitted variation axes
{axes_block}

## Knowledge context
{knowledge_base}

Output strictly:

```json
{{
  "variants": [
    {{
      "id": "<slug>",
      "axis": "<one of the permitted axes>",
      "hypothesis": "<one sentence: why this variant could be faster or cleaner>",
      "design_choice": "<concrete description of what changes>",
      "expected_risk": "<what could go wrong>"
    }}
  ]
}}
```

No prose outside the fence. The implementer will get each variant brief in turn
and produce the full bundle.
"""


csl_explore_bundle_fix = """The exploration candidate did NOT pass the staged bundle benchmark.
Repair the bundle while keeping its general intent. You may amend layout.csl AND run.py
in addition to the compute file (this is exploration, not translation — there is no
fixed reference to defer to).

## Original idea / variant brief
{brief}

## Current bundle
### layout.csl
```csl
{current_layout}
```

### compute file
```csl
{current_pe}
```

### run.py
```python
{current_run_py}
```

## Benchmark outcome
status:        {benchmark_status}
failure reason: {failure_reason}

## Command transcript
{command_transcript}

## Prior-round diagnosis (from debugger / reviewer)
{prior_round_diagnosis}

## Layout requirements
{layout_requirements}

{builtin_whitelist}

{cycles_send_recipe}

Emit the corrected bundle using the same fenced-block format as the original
proposal — `design`, `layout`, `pe`, `run`, `commands` — in that order.
"""


q_tutorialize_explored = """You are turning a successful exploration result into a
TUTORIAL chapter for future learners (or future LLMs). The tutorial will be ingested
into the same knowledge base the translation agents use — therefore it MUST NOT leak
bench-specific answers.

## What you receive
### DESIGN.md
{design_md}

### Lessons
{lessons}

### Mesh / pattern used
{mesh_pattern}

### Knowledge chunks consulted
{chunks_used}

## Hard constraints
- DO NOT copy any verbatim function name, struct field name, comptime param value,
  fabric dimension, or numeric tolerance from the actual bundle.
- DO NOT show the full kernel. Show patterns as ≤10-line CSL skeletons.
- Refer to the kernel generically ("the row-softmax kernel") — never by file name.
- Anti-patterns (what NOT to do) are MORE valuable than worked answers. Lead with
  them when available.
- Tutorial length: 200–600 words of prose + at most 3 short CSL skeletons.

Output: a single Markdown document. Begin with a level-1 heading naming the idiom
(e.g. "# Online-softmax reduction on a single PE"). End with a "What to watch for"
section listing the anti-patterns.

Do not wrap the whole output in a code fence. Just emit the markdown.
"""


# =============================================================================
# CYCLES_SEND_RECIPE — canonical tic/toc instrumentation
# =============================================================================
#
# benchmark_csl._extract_kernel_cycles parses two specific stdout lines:
#   cycles_send = <int> cycles
#   time_send   = <float> us
# Without these, the explored kernel passes correctness but reports
# cycles_send=null which makes per-attempt performance comparisons useless.
#
# This recipe is the SHORTEST self-contained drop-in pattern that produces
# those lines. Implementers are told to follow it verbatim (modulo renaming
# `main` to whatever the kernel's entrypoint is called).

CYCLES_SEND_RECIPE = r"""
## MANDATORY: cycles_send instrumentation

Your bundle MUST emit two specific stdout lines on a successful run, otherwise
the harness records cycles_send=null and the result is non-comparable:

    cycles_send = <int> cycles
    time_send   = <float> us

Copy the following idiom into your bundle, then rename `compute_main` to your
kernel's entrypoint and `compute_main` in the host launch list accordingly.

### IN pe.csl — add at file top
    const timestamp = @import_module("<time>");
    var tscStartBuffer = @zeros([timestamp.tsc_size_words]u16);
    var tscEndBuffer   = @zeros([timestamp.tsc_size_words]u16);
    // u16 storage on device is fine — memcpy_d2h on this kernel uses
    // MEMCPY_16BIT below to read it back. If you see
    // "Internal data type ... should be 32 bit." at the timestamp
    // memcpy, the SDK is rejecting MEMCPY_16BIT because some other
    // memcpy in this run.py is 32-bit; in that case either (a) read
    // EVERY data tensor as 32-bit AND keep timestamps 16-bit (works
    // on most SDK builds, see csl-examples/benchmarks/cholesky/run.py),
    // OR (b) widen the timestamp buffer to u32 by writing each u16
    // word into the low half: time_buf_u32[i] = @as(u32, time_buf_u16[i]).
    var time_buf_u16   = @zeros([timestamp.tsc_size_words * 2]u16);
    var ptr_time_buf_u16: [*]u16 = &time_buf_u16;

### IN pe.csl — four helper fns
    fn f_enable_timer() void { timestamp.enable_tsc();          sys_mod.unblock_cmd_stream(); }
    fn f_tic()          void { timestamp.get_timestamp(&tscStartBuffer); sys_mod.unblock_cmd_stream(); }
    fn f_toc()          void { timestamp.get_timestamp(&tscEndBuffer);   sys_mod.unblock_cmd_stream(); }
    fn f_memcpy_timestamps() void {
        time_buf_u16[0] = tscStartBuffer[0];
        time_buf_u16[1] = tscStartBuffer[1];
        time_buf_u16[2] = tscStartBuffer[2];
        time_buf_u16[3] = tscEndBuffer[0];
        time_buf_u16[4] = tscEndBuffer[1];
        time_buf_u16[5] = tscEndBuffer[2];
        sys_mod.unblock_cmd_stream();
    }

### IN pe.csl — export them
    comptime {
        @export_symbol(ptr_time_buf_u16, "time_buf_u16");
        @export_symbol(f_enable_timer,        "f_enable_timer");
        @export_symbol(f_tic,                 "f_tic");
        @export_symbol(f_toc,                 "f_toc");
        @export_symbol(f_memcpy_timestamps,   "f_memcpy_timestamps");
    }

### IN run.py — launch order + timestamp decode
    # ... after memcpy_h2d of inputs:
    runner.launch("f_enable_timer", nonblock=False)
    runner.launch("f_tic",          nonblock=False)
    runner.launch("compute_main",   nonblock=False)   # <- your kernel entrypoint
    runner.launch("f_toc",          nonblock=False)
    runner.launch("f_memcpy_timestamps", nonblock=False)
    # ... after memcpy_d2h of outputs:
    import numpy as np
    # Use the actual rectangle dims your layout.csl set (e.g. P*P for a 2D mesh,
    # P for a 1D row mesh, 1 for a single-PE kernel).
    width, height = 1, 1   # <- match @set_rectangle in layout.csl
    time_hwl = np.zeros((height, width, 6), dtype=np.uint32)
    runner.memcpy_d2h(time_hwl, runner.get_id("time_buf_u16"),
                      0, 0, width, height, 6,
                      streaming=False,
                      data_type=MemcpyDataType.MEMCPY_16BIT,
                      order=MemcpyOrder.ROW_MAJOR, nonblock=False)
    # Decode u16-triples -> 48-bit start/end cycle counts.
    def _cycles(h):
        return int(h[0]) | (int(h[1]) << 16) | (int(h[2]) << 32)
    starts = np.array([_cycles(time_hwl[r, c, 0:3])
                       for r in range(height) for c in range(width)])
    ends   = np.array([_cycles(time_hwl[r, c, 3:6])
                       for r in range(height) for c in range(width)])
    cycles_send = int(ends.max() - starts.min())
    time_send   = (cycles_send / 0.85) * 1.0e-3   # 0.85 GHz wse-3 fabric clock
    print(f"cycles_send = {cycles_send} cycles")
    print(f"time_send = {time_send} us")

Hard rules:
- The exact strings `cycles_send = N cycles` and `time_send = X us` MUST be
  printed (the harness's regex is anchored on them).
- The `<time>` module is BUILT IN — do not invent a replacement.
- Width/height in the d2h call MUST match `@set_rectangle(W, H)` in layout.csl.
- Tic+toc MUST bracket only the kernel work (not memcpy or verify) so cycles
  measure the kernel itself.
"""


# =============================================================================
# OPTIMIZE-REPAIR — one-shot fix for a failed optimization candidate
# =============================================================================
#
# Mirrors csl_explore_bundle_fix but for the optimization path:
#   - the compute file is what changed (layout.csl + run.py are reused
#     verbatim from the kernel bench, so the LLM only re-emits pe.csl)
#   - the failure may be compile, run, contract violation, or missing
#     cycles_send instrumentation
#   - the angle the agent was trying to apply MUST be preserved (a repair
#     that abandons the angle is just a baseline regression dressed up)
#
# Returns a single ```csl fenced block (matching q_optimize_csl_compute's
# output contract).

csl_optimize_repair = """Your previous optimization attempt FAILED. Repair the compute file
to address the diagnostic below, WITHOUT abandoning the optimization angle you were applying.

============================================================
ANGLE: {angle_name}
{angle_description}
============================================================

The failed candidate either did not compile, did not run, violated the
frozen-functions contract, or did not emit cycles_send. Fix the specific
problem identified in the diagnostic, but the repaired file must still
embody the angle's transformation — do NOT revert to baseline.

## Failure summary
status:         {benchmark_status}
failure reason: {failure_reason}

## Command transcript (head + tail of cslc/cs_python output)
{command_transcript}

## Debugger diagnosis (when available)
{debugger_report}

## Knowledge context (refreshed for THIS angle)
{knowledge_base}

## The previous (broken) candidate compute file
```csl
{previous_pe}
```

## Reference contract (layout.csl + run.py + commands_wse3.sh — UNCHANGED)
{reference_contract}

============================================================
HARD RULES — same as the original attempt; auto-rejected post-run if violated:
- Function bodies of `f_tic`, `f_toc`, `f_memcpy_timestamps`,
  `f_reference_timestamps` must match the reference verbatim.
- Top-level `param NAME: TYPE;` decls must not be redeclared, shadowed by
  `const NAME = ...`, or re-named as `NAME_LOCAL` / `NAME_OVERRIDE` /
  `NAME_TMP` / `NAME_FIXED`.
- Preserve the bundle contract (exported symbols, entrypoint name,
  parameter types, expected I/O shapes).
- Do not change fabric colors, host-runner protocol, or layout.csl-visible
  structure.
- The numerical output must match the reference verification exactly.
============================================================

{builtin_whitelist}

{cycles_send_recipe}

Return the corrected compute file in a single ```csl code fence. Nothing else.
"""


# =============================================================================
# OPEN-MODE OPTIMIZATION — no named angle, just the goal
# =============================================================================
#
# The named-angle catalog enumerates what humans have already noticed. When
# the kernel is already locally optimal for every named angle (preflight
# skips them or rounds keep returning no-improvement), we want a mode that
# tells the LLM "find ANY way to reduce cycles" — algorithmic rewrites,
# cross-cutting changes, micro-patterns not in the catalog.
#
# Same hard contract as named-angle mode (FROZEN funcs, contract preserved,
# numerical output unchanged) — only the search direction is unconstrained.
# Successful open-mode wins should later be distilled into NEW catalog
# entries; until then they're persisted with angle="OPEN" so they show up
# in aggregates without polluting the named-angle reward table.

q_optimize_open_compute = r"""You are optimizing a CSL compute file to REDUCE its on-WSE cycle count.

============================================================
OPEN-MODE OPTIMIZATION
============================================================
There is NO named angle this round. The named-angle catalog (fmac_bulk,
dsd_offset_chaining, comptime_hoist, memory_simd_alignment, ...) has
either been exhausted or repeatedly returned no-improvement for this
kernel. Your job is to find a CYCLE REDUCTION the catalog does not
describe.

Examples of what open-mode is FOR:
  - algorithmic rewrites (different decomposition, different reduction tree
    shape, fuse two passes into one, eliminate a phase by pre-computing on
    host or at comptime)
  - cross-cutting changes (re-order tasks to overlap compute with fabric
    I/O, reuse a buffer across two tasks, hoist a per-iteration setup out
    of a hot path)
  - microthread / async patterns that don't fit one named angle
  - exploiting comptime knowledge that isn't currently used (e.g. when
    the problem dimensions admit a divide-and-conquer the baseline ignores)

Examples of what open-mode is NOT for:
  - retrying the named angles in disguise
  - cosmetic cleanups (var→const, dropping comments) — those are
    buffer_cleanup territory and won't beat its 1% threshold
  - changing the algorithm in a way that the host-side verifier would
    reject (numerical drift, wrong shape)

============================================================
PRIMARY OBJECTIVE: STRICTLY FEWER cycles_send THAN THE CURRENT BEST
============================================================
Current best `cycles_send`: {current_cycles}
Your variant MUST report a smaller `cycles_send` after running. A variant
that reports >= {current_cycles} cycles is rejected.

Cycle counts come from the kernel's own `tic()/toc()` interval — they
measure on-WSE compute, NOT host wall-clock.

{frozen_callout_block}

============================================================
WHAT YOU'RE GIVEN
============================================================

## Kernel task
{task_summary}

## Detected bottlenecks (from static profiler)
{bottleneck_block}

## Prior named-angle outcomes on this kernel (so you don't repeat what failed)
{angle_history_block}

## Reference contract (layout.csl + run.py + commands_wse3.sh — UNCHANGED)
{reference_contract}

## Knowledge context (mesh patterns, prior exploration lessons, skills)
{knowledge_base}

## Current compute file (this is what runs in {current_cycles} cycles today)
```csl
{current_code}
```

{builtin_whitelist}

============================================================
WHAT TO RETURN
============================================================

Two fenced blocks, in order:

```hypothesis
<one short paragraph: in plain English, what concrete change you're making
and why you expect it to reduce cycles. Be specific — "fuse the two reduce
passes" not "improve performance". This is what we'll persist as the
distilled lesson on accept.>
```

```csl
<the full revised compute file. Must compile cleanly with cslc --arch=wse3
against the unchanged layout.csl + run.py.>
```

No prose outside the fences.
"""


# =============================================================================
# OPTIMIZATION_PLANNER — picks which files the optimizer should focus on
# =============================================================================
#
# Round-0 helper for optimize_explore. Reads the bench's structure scan
# (root + editable imports + per-file arithmetic density) and decides:
#   - which file(s) to optimize this kernel against (focus_files)
#   - which file(s) to expose to the LLM as read-only context
#     (expose_in_prompt)
#   - what the first angle should be, and why
#
# Cheap: one call per kernel, cached at
# `optimization/plans/<kernel>.json` so re-runs skip the LLM entirely
# unless the bench structure changed.
#
# The planner does NOT decide which angle to try each round (that's
# still the angle scheduler's job). It decides ONCE which file the
# optimizer should treat as the "primary compute" — for thin-dispatcher
# kernels (BiCGSTAB, Power Method, etc) that's the imported library;
# for self-contained kernels (Cholesky, GoL) it's the root, unchanged
# from current behavior.

q_optimization_planner = r"""You are deciding which file(s) of a Cerebras CSL kernel an
automated optimization loop should focus on. The loop will try to reduce the kernel's
on-WSE cycles_send by applying named optimization angles (catalog below) over multiple
rounds. Your job is to look at the bench's structure ONCE and pick the right primary
file (or files) so subsequent rounds don't waste tokens optimizing scaffolding.

## Kernel
{kernel_id}  (group: {kernel_group})
baseline cycles_send: {baseline_cycles}

## Bench structure (auto-scanned)
Root compute file: `{root_relpath}`
  loc={root_loc}  code_loc={root_code_loc}  compute_loc={root_compute_loc}  density={root_density}
  thin_dispatcher? {root_is_thin}

Editable imports (other .csl files in this kernel's bundle that the optimizer
COULD modify if you say so):
{editable_summary}

Stdlib imports (NOT editable, listed for context): {stdlib_imports}

## Catalog of optimization angles available for this kernel's group
{angle_catalog}

## Pre-flight: already-satisfied angles
{preflight_skipped_block}

## File contents

### Root: `{root_relpath}` (first ~80 lines)
```csl
{root_excerpt}
```

{editable_excerpts}

## Your decision

Output STRICT JSON in a single ```json fence. No prose outside the fence.

```json
{{
  "focus_files": ["<relpath>", ...],
  "expose_in_prompt": ["<relpath>", ...],
  "rationale": "<one-paragraph why these files; cite densities + where the hot
                loops live; ≤120 words>",
  "suggested_first_angle": "<one angle name from the catalog above>",
  "confidence": "high|medium|low"
}}
```

Rules:
- `focus_files` is the list of files the optimizer will REWRITE each round.
- `expose_in_prompt` is the list of files the LLM SEES in each prompt. MUST be
  a superset of `focus_files`. Files in expose_in_prompt but NOT in focus_files
  are read-only context.

Picking focus_files — pick the SHAPE that matches the bench:

  (A) SELF-CONTAINED. No editable imports, OR root density >= 5% with no other
      editable file above 3%. Use `focus_files = [root_relpath]`.

  (B) THIN-DISPATCHER + HOT-HELPER (the typical solver-with-BLAS shape:
      BiCGSTAB / CG / PCG / Power Method calling into blas.csl). Root has
      a state machine + DSD/buffer plumbing but its arithmetic density is
      LOW (< 5%); a sibling editable file (e.g. `blas.csl`) has density
      >= 7% and contains the inner-loop arithmetic the dispatcher calls
      into. Use **`focus_files = [root_relpath, hot_helper_relpath]`** —
      BOTH the root AND the helper. The dispatcher owns DSD lifetimes,
      task chaining, and call-site argument shape; the helper owns the
      bulk arithmetic. Wins on this shape typically need coordinated
      edits across the call boundary (lift a DSD in the root + consume it
      bulk in the helper). DO NOT pick the helper alone — the helper has
      no entry point the runner invokes; the optimizer cannot make a
      standalone edit to it land. DO NOT pick the dispatcher alone — the
      arithmetic the LLM needs to change is not in the dispatcher.
      This rule fires WHENEVER root density < 5% AND any editable file
      density >= 7%. Set confidence="medium" rather than "high" because
      the multi-file shape is more expensive to verify per round.

  (C) HELPER-DOMINANT, ROOT IRRELEVANT. Root density < 1% AND the root file
      reads as pure scaffolding (no compute, no DSD setup — just a few
      `@import_module` + a single entry-task that calls helper.fn(); no
      arithmetic at all). Rare. Use `focus_files = [hot_helper_relpath]`
      ONLY in this case, and ALSO include root in `expose_in_prompt` so
      the optimizer can see how the helper is invoked.

Prefer FEWER files in expose_in_prompt (every file eats prompt budget), BUT
for case (B) always include BOTH the dispatcher and the hot helper — never
expose the helper alone.

`suggested_first_angle` should target the dominant bottleneck visible in the
focus file(s). Pick from the catalog above by name (verbatim).

Sanity checks before you emit JSON:
  * if your rationale names a specific file as "the hot path", that file MUST
    appear in focus_files.
  * if focus_files has exactly one element and it is a helper file (not the
    root), be sure you are in case (C) above — otherwise add the root.
"""
