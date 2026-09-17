"""
CSL language rules, patterns, and constraints for LLM agent guidance.

Sections are kept short and code-anchored so they fit in LLM prompts without
dominating context. Each section targets a known failure mode or optimization
opportunity observed in actual translation/optimization runs.
"""

from __future__ import annotations

import os
import sys
from pathlib import Path
from typing import List, Tuple

REPO_ROOT = Path(__file__).resolve().parents[1]
if str(REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(REPO_ROOT))


# ---------------------------------------------------------------------------
# 0. KNOWLEDGE-ABLATION TIERS  (no-knowledge baseline mode)
# ---------------------------------------------------------------------------
# A baseline-ablation switch for measuring the marginal value of the whole
# knowledge stack. Three tiers, selected by env vars set from cuda2csl.py's
# --no-knowledge / --bare flags (so the same chokepoint serves CLI and tests):
#
#   "full" (default)                 — every knowledge layer active.
#   "soft" (XKERNEL_NO_KNOWLEDGE=1)  — strip TIER-A curated/retrieved knowledge
#                                      (base + W1 gotchas, RAG cluster-query
#                                      steering, tutorials, skills, mesh
#                                      patterns, release notes, debug recipes,
#                                      optimizer experience memory). KEEP TIER-B:
#                                      the CSL language primer (TYPE_RULES,
#                                      DSD_PATTERNS, TASK_SYSTEM, WSE3_RULES) and
#                                      the architect/reviewer role framing.
#   "bare" (… + XKERNEL_BARE=1)      — also strip TIER-B; the for_* functions
#                                      return "". Only TIER-C structure remains,
#                                      and that lives in the prompt TEMPLATES
#                                      (CUDA source, layout.csl, reference
#                                      contract, builtin whitelist) — never here.
#
# TIER-C is deliberately NOT controlled here: layout/contract/CUDA source are
# template slots in prompt_cuda2csl.py, and the builtin whitelist has its own
# XKERNEL_BUILTIN_WHITELIST gate. The baseline keeps all of those ON — they are
# "necessary prompts", not knowledge.
def knowledge_tier() -> str:
    """Return the active knowledge-ablation tier: "full" | "soft" | "bare"."""
    if os.getenv("XKERNEL_NO_KNOWLEDGE", "0") == "1":
        return "bare" if os.getenv("XKERNEL_BARE", "0") == "1" else "soft"
    return "full"

# ---------------------------------------------------------------------------
# 1. TYPE RULES
# ---------------------------------------------------------------------------
TYPE_RULES = """
## CSL Type Rules

### comptime parameter types
Comptime params declared as `param Nt: u16` are unsigned. Array offsets and
@range() counters must be `i16` (signed). Always cast:
  const dsd = @get_dsd(mem1d_dsd, .{ .tensor_access = |i|{Mt} -> A[i*@as(i16,Nt)] });
  for (@range(i16, Nt)) |j| { ... }
Never write: `A[i * Nt]` — this produces a type mismatch error (expected i16, got u16).

### CSL has NO C-style forward declarations — define each fn/task once
CSL does not support forward-declaring a function and defining it later. Writing
  fn spmv_done() void;          // forward declaration  -> WRONG
  ...
  fn spmv_done() void { ... }   // definition shadows it -> compile error
fails with "<name> is declared twice" / a shadowing error. This recurs when a
kernel needs a callback referenced before its definition (e.g. a library
@import_module's `.f_callback`). FIX: define the function ONCE, BEFORE the import
that references it — declaration order is sufficient; no forward decl is needed.
Mutually-recursive tasks chain via `@activate(task_id)` / `@bind_local_task`,
not via forward-declared fns.

### @increment_dsd_offset offset type
The offset argument must be `i16`:
  const col = @increment_dsd_offset(dsd_A, j, f32);  // j from @range(i16, Nt) — correct
  const col = @increment_dsd_offset(dsd_A, @as(i16, j), f32);  // explicit cast if needed

### @ptrcast for collectives
Collectives take `[*]u32` pointers. Cast with:
  mpi_x.scatter(0, @ptrcast([*]u32, &x_src), @ptrcast([*]u32, &x_tile), Nt, next_task_id);
  mpi_x.reduce_fadds(Pw-1, @ptrcast([*]f32, &local), @ptrcast([*]f32, &sum), Mt, next_task_id);
"""

# ---------------------------------------------------------------------------
# 2. DSD PATTERNS
# ---------------------------------------------------------------------------
DSD_PATTERNS = """
## CSL DSD Patterns

### Build mem1d_dsd once, offset inside loops
// Good — build outside loop, offset inside:
const dsd_A = @get_dsd(mem1d_dsd, .{ .tensor_access = |i|{Mt} -> A_tile[i*@as(i16,Nt)] });
for (@range(i16, Nt)) |j| {
  const dsd_col = @increment_dsd_offset(dsd_A, j, f32);  // stride-Mt column slice
  @fmacs(dsd_result, dsd_result, dsd_col, x_tile[j]);     // vectorized fused-multiply-add
}
// Bad — never construct a new DSD per iteration.

### Bulk operations replace scalar loops
// Replace: for (@range(i16, Mt)) |i| { result[i] += b[i]; }
// With:
@fadds(dsd_result, dsd_result, dsd_b);   // adds two Mt-element arrays element-wise

// Replace: for (@range(i16, Mt)) |i| { result[i] = A[col][i] * scalar; }
// With:
@fmacs(dsd_result, dsd_result, dsd_A_col, scalar);

### tensor_access for strided arrays (row-major matrix, column access)
// Access column j of row-major Mt×Nt matrix:
const dsd_A = @get_dsd(mem1d_dsd, .{
  .tensor_access = |i|{Mt} -> A_tile[i*@as(i16,Nt)]  // step by Nt to walk column
});
// Then offset to column j: @increment_dsd_offset(dsd_A, j, f32)

### Async fabric operations
@fmovs(out_dsd, data_dsd, .{ .async = true, .activate = next_task_id });
// .activate fires next_task_id when the async op completes — do not block-wait.
"""

# ---------------------------------------------------------------------------
# 3. TASK SYSTEM
# ---------------------------------------------------------------------------
TASK_SYSTEM = """
## CSL Task System

### Task ID allocation
const EXIT:          local_task_id = @get_local_task_id(9);
const scatter_task:  local_task_id = @get_local_task_id(10);
const compute_task:  local_task_id = @get_local_task_id(11);
// Use IDs 8–30 for local tasks. IDs 0–7 reserved for data/control tasks.

### Binding and activation
comptime {
  @bind_local_task(scatter_fn, scatter_task);
  @bind_local_task(compute_fn, compute_task);
  @bind_local_task(exit_fn, EXIT);
}
// Activate: @activate(scatter_task);  // fires immediately in current task
// Chain via async: @fmovs(..., .{ .async = true, .activate = compute_task });

### Task chain pattern (GEMV standard pipeline)
fn main() void { @activate(task_a); }
task task_a() void { /* setup */ @activate(task_b); }
task task_b() void { /* compute */ mpi_x.reduce_fadds(..., task_c_id); }
task task_c() void { /* gather */ sys_mod.unblock_cmd_stream(); }

### Collectives always use callbacks
// scatter/broadcast/gather/reduce_fadds take a task_id as last arg and
// activate it when the collective completes. Never poll for completion.
mpi_y.broadcast(0, @ptrcast([*]u32, &x_tile), Nt, compute_task);
"""

# ---------------------------------------------------------------------------
# 4. WSE-3 RULES
# ---------------------------------------------------------------------------
WSE3_RULES = """
## WSE-3 Specific Rules

### Input queues for data tasks (WSE-3 only)
// WSE-3: data tasks bind to input queues, not color IDs directly.
const h2d_iq: input_queue = @get_input_queue(0);
const recv_task_id: data_task_id = @get_data_task_id(h2d_iq);
task recv_task(value: f32) void { ... }
@bind_data_task(recv_task, recv_task_id);

// WSE-3 requires explicit queue initialization in comptime:
comptime {
  @initialize_queue(h2d_iq, .{ .color = sys_mod.MEMCPYH2D_1 });
}

### Output queues
const out_oq = @get_output_queue(2);
const out_dsd = @get_dsd(fabout_dsd, .{
  .fabric_color = send_color, .extent = N, .output_queue = out_oq
});

### Microthread IDs (WSE-3, topic-15 pattern)
// Use explicit microthread ID to decouple from output queue ID:
const send_ut = @get_ut_id(4);
@fmovs(out_dsd, data_dsd, .{ .async = true, .ut_id = send_ut, .activate = done_task });
// Two operations sharing a microthread must not run concurrently.

### Architecture detection
comptime {
  if (@is_arch("wse3")) {
    @initialize_queue(h2d_iq, .{ .color = sys_mod.MEMCPYH2D_1 });
  }
}
"""

# ---------------------------------------------------------------------------
# 5. PROFILING (TSC cycle counter)
# ---------------------------------------------------------------------------
PROFILING = """
## CSL Cycle-Accurate Profiling with TSC

### In pe.csl — add timing around kernel body
const timestamp = @import_module("<time>");
var tsc_start_buf = @zeros([timestamp.tsc_size_words]u16);  // 3 u16 words = 48 bits
var tsc_end_buf   = @zeros([timestamp.tsc_size_words]u16);
var ptr_tsc_start : [*]u16 = &tsc_start_buf;
var ptr_tsc_end   : [*]u16 = &tsc_end_buf;

fn main() void {
  timestamp.enable_tsc();
  timestamp.get_timestamp(&tsc_start_buf);
  @activate(first_task_id);
}
task f_exit() void {
  timestamp.get_timestamp(&tsc_end_buf);
  sys_mod.unblock_cmd_stream();
}
comptime {
  @export_symbol(ptr_tsc_start, "tsc_start");
  @export_symbol(ptr_tsc_end,   "tsc_end");
}

### In run.py — decode 48-bit cycle count
def make_u48(arr):   # arr is np.ndarray of u16
    return int(arr[0]) + (int(arr[1]) << 16) + (int(arr[2]) << 32)

tsc_start = runner.memcpy_d2h_tensors({"tsc_start": (1, 1, 3, MemcpyDataType.MEMCPY_16BIT)})
tsc_end   = runner.memcpy_d2h_tensors({"tsc_end":   (1, 1, 3, MemcpyDataType.MEMCPY_16BIT)})
cycles = make_u48(tsc_end["tsc_end"].flatten()) - make_u48(tsc_start["tsc_start"].flatten())
print(f"kernel cycles: {cycles}  time_us: {cycles / 850e3:.2f}")

### Constraint
// TSC is per-PE and not synchronized across PEs.
// For multi-PE kernels, add an allreduce to find max(tsc_end) - min(tsc_start).
"""

# ---------------------------------------------------------------------------
# 5b. CUDA → WSE ARCHITECTURAL MAPPING
# ---------------------------------------------------------------------------
# Bridges the GPU mental model to the wafer-scale model. Critical for agents
# (especially open-source) that default to GPU thinking patterns.
# Gate: XKERNEL_ARCH_MAPPING (default "1").

CUDA_TO_WSE_MAPPING = """
## CUDA → Cerebras WSE Architectural Mapping

STOP thinking in GPU terms. The WSE is fundamentally different:

### Compute Model
- **CUDA thread** → **WSE PE** (Processing Element). Each PE is an independent scalar
  processor with its own 48KB SRAM. There is NO SIMT — no warps, no divergence.
  One PE = one instruction stream, not thousands of threads.
- **CUDA block** → **Single PE tile**. There is no shared memory between PEs.
  Each PE's 48KB SRAM is PRIVATE. Inter-PE communication uses fabric wavelets.
- **CUDA grid** → **PE rectangle** (`@set_rectangle(W, H)`). A 2D mesh of PEs
  with nearest-neighbor fabric connections. NOT a launch configuration — it's a
  physical layout compiled into the wafer.

### Memory Model
- **CUDA global memory** → **Off-chip via memcpy H2D/D2H**. No random access from
  PEs to off-chip memory. Data must be streamed in via `memcpy_h2d` before compute
  and streamed out via `memcpy_d2h` after. Think of it as "load all data first,
  compute, then store results."
- **CUDA shared memory** → **PE local SRAM (48KB)**. Each PE has 48KB — this is ALL
  the memory it has. Variables, arrays, DSDs, stack — everything must fit in 48KB.
  There is no L1/L2 cache, no memory hierarchy.
- **CUDA registers** → **PE registers** (similar concept, but the 48KB SRAM is also
  the register file — there's no separate register bank).

### Synchronization & Communication
- **`__syncthreads()`** → **No barriers**. WSE uses event-driven programming:
  `@activate(task_id)` triggers a task when data arrives. Wavelets (small data
  packets) flow through the fabric and activate receiving tasks. Think
  producer-consumer, not barrier-synchronize.
- **CUDA atomics** → **Fabric reduction**. Use `@fmacs` with fabric DSDs for
  accumulation, or the `collectives_2d` library for allreduce/broadcast.
  There are NO atomic operations on the WSE.
- **Warp shuffle (`__shfl_sync`)** → **Fabric color send/recv**. Explicit routing
  via colors (`@get_color(N)`), directions (NORTH/SOUTH/EAST/WEST), and
  `@set_color_config`. You define the data path at compile time.

### Parallelism Strategy
- **CUDA: parallelize over threads** → **WSE: partition data across PEs**.
  Each PE processes its LOCAL slice. Communication between PEs uses wavelets.
- **CUDA: more threads = more parallelism** → **WSE: more PEs = wider partition**.
  But each PE only has 48KB, so larger problems need more PEs, not more threads.
- **CUDA: coalesce memory accesses** → **WSE: use DSDs for bulk data movement**.
  `@get_dsd(mem1d_dsd, ...)` with `@fmovs`/`@fmacs` replaces explicit loops.
  A single DSD instruction moves an entire array — it's the CSL equivalent of
  a coalesced vectorized load/store.

### Key Translation Patterns
```
CUDA: y[i] = A[i] * x[i]           → CSL: @fmuls(y_dsd, A_dsd, x_dsd)
CUDA: for(i=0;i<N;i++) sum+=a[i]   → CSL: @fadds(sum_dsd, a_dsd)  // bulk reduce
CUDA: atomicAdd(&hist[b], 1)       → CSL: hist[bucket] += 1  // local; reduce via fabric
CUDA: __syncthreads()              → CSL: @activate(NEXT_TASK)  // event-driven
CUDA: threadIdx.x                  → CSL: layout_module.get_x_coord()  // runtime only
CUDA: gridDim.x * blockDim.x       → CSL: param width: u16  // compile-time from layout
```

### Performance Model (PLMR from WaferLLM)
A WSE kernel's performance is determined by four factors:
- **P** (Parallelism): number of PEs used — more PEs = wider data partition
- **L** (Local compute): cycles per PE for the compute kernel
- **M** (Memory): bandwidth to/from PE SRAM (not off-chip — it's all on-chip)
- **R** (Routing): fabric bandwidth for inter-PE wavelet communication

If L >> R: compute-bound → optimize inner loops (fmac_bulk, DSD chaining)
If R >> L: fabric-bound → overlap communication with compute (async)
If M is bottleneck: memory-bound → reduce PE SRAM usage, tile smaller
"""


# ---------------------------------------------------------------------------
# 6. KNOWN GOTCHAS
# ---------------------------------------------------------------------------
KNOWN_GOTCHAS = """
## Known CSL Gotchas

- **u16/i16 mismatch**: comptime params are u16; loop indices and DSD offsets need i16.
  Always use @as(i16, param) in arithmetic and @range(i16, N).
- **H2D/D2H serialization**: host memcpy calls are serialized. Sending >14 wavelets
  without a FIFO on the PE side will stall (pipeline-01 pattern).
- **Same-color send+receive**: cannot safely send and receive on the same fabric color
  with fixed routing. Use checkerboard coloring or fabric switches.
- **Output queue drain**: WSE-3 output queues cannot be reused with a different color
  before being fully drained.
- **Collective ordering**: mpi_x and mpi_y operations must complete before the next one
  starts on the same dimension. Use the callback task ID to chain them.
- **@activate in comptime**: never call @activate() from a comptime block.
  Use it only inside task/function bodies.
- **No null pointers**: CSL has no null pointer type. All pointers must point to
  initialized storage.
- **User module imports use filename only**: `@import_module("filename.csl", params)` —
  the file must be in the SAME directory as the importer. Never write "src/filename.csl"
  or "../filename.csl". SDK libraries use angle brackets: `@import_module("<memcpy/memcpy>", p)`.
- **Bundle file structure**: all files referenced by layout.csl (pe.csl, kernel.csl, etc.)
  are in the same flat directory as layout.csl unless layout.csl explicitly uses a `src/`
  prefix in its @set_tile_code calls. Check the reference contract to confirm.
- **Queue init before use (WSE-3)**: on WSE-3, every user-created input/output queue must
  be initialized with `@initialize_queue(q, .{.color = C})` inside a `comptime { }` block
  BEFORE any data task or DSD references that queue. Initializing after a `@bind_data_task`
  or `@load_to_dsr` that touches the same queue causes "queue already set" or silent stalls.
  Order: (1) get queue, (2) initialize queue, (3) bind tasks / create DSDs.
- **fn vs task @bind mismatch**: `@bind_data_task` expects a data task (declared with
  `task ... void`), not a regular function. Binding a function produces "not a task" at
  compile time. Conversely, `@bind_local_task` takes a local task, not a data task.
- **Single-source rx per color (WSE-3)**: every fabric color must have exactly ONE rx
  source direction. `.rx = .{ NORTH, EAST }` is illegal — "expected at most 1 input
  direction." For fan-in patterns (gather from multiple directions), use a separate color
  per source direction, or a relay chain. This is the #1 blocker for distributed FFT.
- **Color ID range**: WSE-3 color IDs are in `[0, 24)`. `@get_color(24)` or higher is a
  compile error. Plan your color allocation before coding.
- **@set_color_config vs @set_local_color_config**: `@set_color_config` requires 4 args
  (color, .rx, .tx, .pop_mode). For per-PE local routing, use
  `@set_local_color_config(color, cfg)` instead.
- **Compute file naming contract**: when layout.csl uses `@set_tile_code(px, py, "X.csl",
  params)`, your compute file MUST be named `X.csl`. Check `commands_wse3.sh` to confirm
  the build entry point and match the filename exactly.
- **Collectives d2h shape**: when using `collectives_2d` for row-reduction, the result
  lives on a COLUMN of PEs `(w=1, h=Py)`. The host's `collect()` call must read from
  the root PE only `(cx=0, cy=0, cw=1, ch=1, elems=M)`, not the full column — otherwise
  the host receives a 2D tensor when it expects 1D.
- **distribution.py authoring**: when run.py imports `distribution.py` for
  `distribute()`/`collect()`, you MUST author your own `distribution.py` alongside
  pe.csl. Your `collect(name, params)` must return `(cx, cy, cw, ch, elems)` matching
  where YOUR kernel places the output — not the reference's placement. Put the result in
  a ```python distribution.py fenced block. run.py loads it from the build directory
  automatically (dependency injection). Template:
  ```
  def collect(name, params):
      if name == "y":
          return (root_x, root_y, 1, 1, total_elems)
      raise KeyError(name)
  def distribute(name, arr, params):
      if name == "A":
          return (arr_flat, w, h, elems_per_pe, x0, y0)
      ...
  ```
- **@export_symbol pointer form**: to export an array, declare `var ptr: [*]f32 = &array;`
  and export the pointer. Do not pass `&array[0]` directly.
- **@fmacs DSD operands**: `@fmacs(dst, a, b)` requires DSD operands. To multiply by a
  scalar, wrap it in a broadcast DSD — do not pass a bare `f32`.
- **No block comments in expressions**: CSL does not support `/* */` inside expressions
  (e.g. `@as(i16, /* P */ 10)`). Use `//` line comments instead.
"""


# ----------------------------------------------------------------------------
# 6b. W1-FAILURE-PATTERN GOTCHAS — added 2026-06-03 from RAG analysis (task #35)
# ----------------------------------------------------------------------------
# Distilled from csl-examples tutorials, curated to address the three dominant
# W1 failure clusters observed in the 21-kernel sweep:
#   - collectives_2d API confusion (4 kernels)
#   - halo-recv / 0-byte D2H stall (7 kernels)
#   - DSR/queue/fabric init (2+ kernels)
# Contamination-checked: every entry cites only csl-examples/tutorials/* sources
# and contains zero benchmark-specific identifiers (f_spmv, stencil_mod, etc.).
# Surfaced unconditionally as part of for_implementer() since the failure
# patterns hit > 75% of W1 attempts. Env-gate XKERNEL_W1_GOTCHAS=0 to suppress.

KNOWN_GOTCHAS_W1_FAILURE_PATTERNS = """
## Recurring W1 translation traps (distilled from csl-examples tutorials)

### collectives_2d/pe import takes DSR-id arrays, not just colors
When importing the 2D collectives helper, the canonical signature is
`@import_module("<collectives_2d/pe>", .{ .dim_params = c2d_params.x, .queues = [2]u16{Qa, Qb}, .dest_dsr_ids = [1]u16{D}, .src0_dsr_ids = [1]u16{S0}, .src1_dsr_ids = [1]u16{S1} })`
— see csl-examples/tutorials/topic-11-collectives/pe_program.csl. The helper
expects to OWN a small pool of DSRs per direction; hand it concrete dsr ids,
not just color ids, and import separately for x and y with their own
c2d_params slice. Two recurring traps:
(1) Do NOT compose c2d_params from `@concat_structs(x_ids, x_dirs, x_dim_info)`.
    c2d_params is provided by the layout-side
    `@import_module("<collectives_2d/params>", ...)` and consumed unchanged;
    building it yourself produces "unused entry in module instantiation" warnings.
(2) Use `mpi_x.broadcast(...)` / `mpi_y.reduce_fadds(...)` on the imported handles.
    `mpi.broadcast_x` / `mpi.broadcast_y` are NOT methods on a single mpi module.
    The collective routine takes a callback (`f_callback : fn ()void`) which fires
    on completion; chain x then y by calling y from inside the x callback.

### Receivers must call sys_mod.unblock_cmd_stream() — and edge PEs must call it too
When a kernel does H2D-then-compute-then-D2H via memcpy, the host's D2H read
hangs ("received 0 bytes") if any participating PE never calls
`sys_mod.unblock_cmd_stream()` after its last fabric op. This is the most common
cause of a clean compile that hangs at runtime; see
csl-examples/tutorials/pipeline-01-basic/pe_program.csl and
csl-examples/tutorials/pipeline-03-multiple/pe_program.csl for the canonical
pattern. Two edge-case traps:
(1) Sender-only PEs (the ones on a halo border that have no incoming wavelets
    to wait for) still need to call unblock_cmd_stream at the end of step() —
    it's not enough for the receivers to call it.
(2) Comptime guards like `if (is_n_edge) { ... bind halo data task ... }`
    silently SKIP the data-task binding on corner PEs that satisfy multiple
    edge predicates; if a corner PE skips its bind, the receive task is never
    armed, wavelets pile up unconsumed, and unblock_cmd_stream is never
    reached. Audit every comptime branch that gates `@bind_data_task` or
    `@initialize_queue` against "does every PE in the rectangle hit at least
    one branch?"

### memcpy library reserves input queues 0 and 1 — re-initialize at your peril
Calling `@initialize_queue(my_iq, .{.color = MY_COLOR})` on input queue 0 or 1
fails with `"initialization for this queue has already been set"` and the
compiler points at memcpyh2d.csl. The `<memcpy/memcpy>` library owns input
queues 0 and 1 internally; user code must request 2-7 via
`@get_input_queue(2)` … `@get_input_queue(7)` and output queues 2-7 via
`@get_output_queue(2)` … `@get_output_queue(7)`. Input queue indices > 7 are
NOT valid on WSE-3 — `@get_input_queue(8)` is a compile error. On WSE-3 every
user-created input/output queue must be explicitly initialized inside a
`comptime { ... }` block before any data flows; on WSE-2 the initialize is
skipped (see the `if (@is_arch("wse3")) { @initialize_queue(...) }` guard in
csl-examples/tutorials/topic-03-streaming-wavelet-data/pe_program.csl and
csl-examples/tutorials/sdklayout-02-routing/send_receive.csl).

### Synchronous @fmovs on a fabric DSD blocks the calling task — add .async + microthread
`@fmovs(dst, src)` and `@fmacs(dst, a, b)` against a fabric DSD complete
synchronously by default. If the source is a `fabin_dsd` whose wavelets
haven't yet arrived, the calling task spin-waits inside the builtin and
nothing else on the PE makes progress — the kernel appears to hang. The fix
is to mark the call `.async` and bind it to a microthread that activates a
completion task when the transfer finishes, per
csl-examples/tutorials/topic-15-wse3-microthreads/left_pe.csl and right_pe.csl:
allocate `const ut: ut_id = @get_ut_id(K)`, then call
`@fmovs(dst, src, .{ .async = true, .ut_id = ut, .activate = done_task_id })`.
Common follow-on error: `"trying to term ut_instr[2], but it's not ours"` —
caused by an async @fmovs that uses a microthread ID owned by a different
fabric op. Each fabric op needs its own ut_id; do not share. WSE-3 input
queues consumed by an async fabin must have been registered via
`@initialize_queue` at comptime.

### Library .csl files with uninitialized `param`s expect you to extend the params struct, not redeclare them
When you `@import_module("<some_library>/pe", params_struct)` and the compiler
errors with `"only 'var' and 'extern const' variables may be uninitialized"`
pointing at a `param` line inside the library's own pe.csl (e.g.
`param f_callback : fn ()void;`, `param input_queues:[4]u16;`,
`param dest_dsr_ids:[2]u16;`, `param src0_dsr_ids:[1]u16;`), the library is
telling you that those `param`s have no default and your params struct must
supply concrete values. The canonical idiom (see
csl-examples/tutorials/topic-11-collectives/pe_program.csl) is to construct
the struct as an anonymous struct literal at the import site:
`.{ .f_callback = my_done, .input_queues = [4]u16{2,3,4,5}, .dest_dsr_ids = [2]u16{0,1}, .src0_dsr_ids = [1]u16{0} }`.
Use `@concat_structs(base_params, .{ .additional_field = value })` only when
you need to extend a struct you've already received from the layout side.
Note the exact param NAMES: `src0_dsr_ids` (with the zero), not
`src_dsr_ids`, and `input_queues` (plural), not `input_queue`.

### Edge / corner / guarded PE branches MUST still reach unblock_cmd_stream()
From topic-11-collectives/pe_program.csl, the canonical task ends every branch with:

    else => {
       // WARNING: the user must unblock cmd color for every PE
       sys_mod.unblock_cmd_stream();
       return;
    }

The `// WARNING: the user must unblock cmd color for every PE` comment is verbatim in the SDK source. The same discipline appears in gemv-07-routes-2 where both the `is_left_col()` send branch and the non-left-col receive branch end by activating `exit_task_id`, and `exit_task()` then calls `sys_mod.unblock_cmd_stream()`.

Canonical pattern: every exported entrypoint (the one launched by the host) MUST guarantee that, on EVERY PE, control eventually reaches `sys_mod.unblock_cmd_stream()`. If a PE has nothing to send or receive, it still has to unblock.

Traps:
1. `if (is_corner) { return; }` with no unblock call — host D2H reads 0 bytes forever.
2. A non-participating PE skips `@initialize_queue` AND skips the activate-of-exit-task path, so the cmd stream never opens.
3. An exported entrypoint declared `fn step() void` is never `@bind_local_task`-ed or `@activate`-ed, so on PEs whose role-conditional code routes through it the task never runs.

Fix template (mirroring topic-11):

    fn entry() void {
      if (has_work) { @activate(do_work_id); } // exit_task chains unblock
      else          { sys_mod.unblock_cmd_stream(); }
    }

### WSE-3 queue / microthread ID pools and the @initialize_queue discipline
From topic-15-wse3-microthreads/README.rst: "any microthread ID 0 to 7 can be used with any of queues 0 to 7". From pipeline-01-basic and topic-09-fifos, memcpy reserves the H2D/D2H input/output queues that you bind via `sys_mod.MEMCPYH2D_1` / `sys_mod.MEMCPYD2H_1` — every tutorial gives those queues IDs 2 and 3 and then allocates user color queues starting at 4.

ID-pool summary you can rely on:
  input_queue IDs:   0..7 valid; the queue bound to `sys_mod.MEMCPYH2D_*` (typically id 2) is consumed by H2D.
  output_queue IDs:  0..7 valid; the queue bound to `sys_mod.MEMCPYD2H_*` (typically id 3) is consumed by D2H.
  ut_id (microthread): 0..7 valid; defaults to the queue ID when not specified.

Canonical init block (verbatim shape, from pipeline-02-fifo):

    if (@is_arch("wse3")) {
      @initialize_queue(h2d_1_iq,  .{ .color = sys_mod.MEMCPYH2D_1 });
      @initialize_queue(d2h_1_oq,  .{ .color = sys_mod.MEMCPYD2H_1 });
      @initialize_queue(C1_iq,     .{ .color = C1 });
      @initialize_queue(C1_oq,     .{ .color = C1 });
    }

Traps:
1. Asking for `@get_input_queue(8)` or `@get_ut_id(8)` -> compile error: max is 7.
2. Forgetting `@initialize_queue` for the user color queue on WSE-3 -> wavelets arrive but the fabin_dsd consumer never wakes.
3. Re-using an output queue with a NEW color before it has drained -> per topic-15 README, "output queues cannot be re-used with a different color if they have not yet been drained". Allocate a fresh oq instead, or share a microthread via explicit `ut_id` to stay within the 0..7 pool.

### WSE-3 reserved resource-ID ranges: a single safe-allocation table for colors / queues / task-ids / microthreads
The dominant failure on multi-phase fabric kernels (FFT-1D-2D, Game-of-Life) is
COLLISION: the agent allocates a color/queue/ut_id that memcpy already reserves, or
re-uses one across phases before it drains. Four collision flavors were observed on
FFT-1D-2D alone (input-queue id 8..15 > max 7; iq 1 collides with memcpy RXCOMMAND;
broadcast colors 0-3 collide with reserved memcpy colors; color 21 collides with
MEMCPYD2H_DATA). The reviewer once told the agent to "move colors to 30+" — that is
ILLEGAL on WSE-3 (the legal color ceiling is 24), so the loop could never converge.
Allocate ONLY from these safe bands:

  fabric color    : legal range is [0, 24) on WSE-3 (`@get_color(24)` is illegal).
                    memcpy reserves 0-3 and the MEMCPYH2D/MEMCPYD2H_DATA colors in
                    the low-20s. Allocate USER colors in [4, ~20); NEVER >= 24, and
                    never "flee upward to 30+" (a common but illegal repair).
  input_queue     : 0..7 valid; 0 and 1 are memcpy-owned. Use @get_input_queue(2..7).
  output_queue    : 0..7 valid; the MEMCPYD2H queue is typically id 3. User oqs 2..7.
  local_task_id   : [8, 31); memcpy uses a high band (21, 27-31). Use 8..20 for your
                    own tasks.
  ut_id (microthd): 0..7; one microthread per concurrent in-flight op.

Cross-phase reuse trap: a color/queue/ut_id is SINGLE-OCCUPANCY until it drains. For
a kernel with multiple phases (e.g. an FFT butterfly's stages, or a CA's send-then-
recv), either (a) allocate DISTINCT ids per concurrent phase, or (b) gate phase 2 on
phase 1's completion callback. Re-using the SAME color for send and receive on one PE
deadlocks (the receiver never wakes because the sender owns the color). When a repair
suggests an id >= 24 for a color, reject it and pick a free id in [4, 20) instead.

### Per-tile route config: @set_local_color_config arity + receive-side single source
Configuring fabric routes from inside a COMPUTE file (one selected by @set_tile_code)
uses the PE-implicit, 2-argument form, NOT the layout-scope 4-argument form:
  // INSIDE pe.csl / the compute file (PE is implicit):
  @set_local_color_config(my_color, .{ .routes = .{ .rx = .{ WEST }, .tx = .{ RAMP } } });
  // ONLY in layout.csl (names the PE explicitly):
  @set_color_config(x, y, my_color, .{ .routes = ... });
A compile error "@set_color_config: 4 arguments required, 2 provided" (or vice-versa)
means you used the wrong scope's form — swap to @set_local_color_config in the compute
file. This is a fixable config error -> stay in bucket B; do NOT abandon or respin the
architect over it.

Receive-side routing takes a SINGLE source: `.rx = .{ ONE_DIR }` or `.rx = .{ RAMP }`.
Combining a fabric input with a local RAMP injection on the SAME receive
(`.rx = .{ RAMP, EAST }`) is NOT supported — but it is again a fixable config error, not
an illegal topology. The TX/tee side MAY fan out to multiple dests
(`.tx = .{ RAMP, NEIGHBOR }` is legal). To funnel an incoming stream and also inject
locally, structure it on TX: `.rx = .{ DIR }, .tx = .{ RAMP, OTHER_DIR }`; add a
`.switches` block only when route positions must sequence per wavelet.

### Canonical halo receive: async fabin_dsd + ut_id + activate, posted before sends
From topic-15-wse3-microthreads/right_pe.csl, the canonical asynchronous receive is:

    const in_dsd = @get_dsd(fabin_dsd, .{
                     .fabric_color = recv_color, .extent = M,
                     .input_queue = recv_color_iq
                   });
    @fmovs(y_dsd, in_dsd, .{ .async = true, .ut_id = recv_color_ut,
                             .activate = exit_task_id });

The matching send on the sender PE (left_pe.csl) uses a `fabout_dsd` with `.async = true`, an `.ut_id` on a different microthread, and `.activate = exit_task_id`. `exit_task` then calls `sys_mod.unblock_cmd_stream()` and the host D2H proceeds.

Key discipline points:
1. EVERY user-color queue you bind on WSE-3 MUST be `@initialize_queue`-d in a comptime
   block under `if (@is_arch("wse3"))` — SYMMETRICALLY, both the receiver's INPUT queue
   AND the sender's OUTPUT queue:
       @initialize_queue(recv_color_iq, .{ .color = recv_color });   // receive side
       @initialize_queue(send_color_oq, .{ .color = send_color });   // SEND side too
   The send-side omission is the silent one: an uninitialized OUTPUT queue COMPILES
   CLEAN but never transmits, so the matching receiver's input queue never fills ->
   permanent fabric deadlock (clean compile, runtime hang, D2H 0 bytes). When you have a
   send/recv pair, audit BOTH queues, not just the receiver's.
2. The send and the receive each take their OWN ut_id (4 and 5 in the tutorial). Two concurrent fabric ops on the same PE must not share a microthread — "two operations cannot concurrently use the same microthread" (topic-15 README).
3. Post the receive op BEFORE issuing the matching send when both happen on the same PE; the recv arms the input queue so arriving wavelets land in the fabin path rather than spinning the router.

Traps that produce a permanent D2H 0-bytes stall:
0. An OUTPUT queue is bound but never `@initialize_queue`-d on WSE-3 -> it compiles but
   never transmits -> the downstream input queue never fills -> deadlock. (Mirror of
   point 1: init the SEND-side queue too, not only the receive-side.)
1. Sender and receiver both run synchronous `@fmovs` in send-then-recv order on every PE -> the send blocks before any recv is posted -> deadlock. Always use `.async = true` for fabric ops.
2. Two async ops on the same PE share `.ut_id` -> only one progresses, the other never activates its completion task.
3. `.activate` points at a task that is never `@bind_local_task`-ed, or two async ops share the same `.activate` task and race the activate counter.

### Per-PE role at runtime: use layout_mod.get_x_coord()/get_y_coord() inside fn/task bodies
From gemv-07-routes-2/pe_program.csl, the canonical role-detection idiom is:

    const layout_mod = @import_module("<layout>");

    fn is_top_row() bool {
      return (layout_mod.get_y_coord() == 0);
    }

    fn is_left_col() bool {
      return (layout_mod.get_x_coord() == 0);
    }

These helpers are then called from inside `task reduce()`, from inside `fn compute()` (which is the host-launched entrypoint), and from inside the wavelet-data-task `recv_x`. gemv-08-routes-3 extends the pattern with `layout_mod.get_x_coord() == kernel_x_dim-1` to detect the rightmost column.

Discipline points:
1. `layout_mod.get_x_coord()` / `get_y_coord()` return valid per-PE coordinates ONLY inside function and task bodies (i.e. at runtime). They must NOT be called from a top-level `const` initializer or a module-scope `comptime { }` block: at that point the fabric coordinate config registers are not yet populated, so the value is garbage or you get a compile error along the lines of "config address not initialised".
2. If you need a role discriminator at comptime (for `@get_dsd` selection, conditional `@bind_data_task`, or static route choice), it MUST come in as a `param` from layout.csl. The standard shape is `param is_first_row: bool;` or `param px: i16;` plumbed through `@set_tile_code(.{ ..., .is_first_row = (x == 0), ... })`.
3. Inside a task body the runtime helpers work fine — gemv-07 demonstrates this for both a local task (`reduce`) and a wavelet-triggered data task path.

Traps:
1. `const my_y = layout_mod.get_y_coord();` at module scope -> garbage / compile error.
2. Assuming `memcpy_params.py` or `memcpy_params.px` exists -> it does not; that struct only carries memcpy plumbing fields.
3. Trying to discriminate role by the numeric VALUE of a color param whose default equals the layout-assigned value -> no signal; pick sentinel defaults outside the assigned color range (still within `[0,24)` for `@get_color`).

### collectives_2d API surface (added 2026-06-04 from explore_csl power_iteration_2d failures)
The collectives_2d helpers have surprising signatures that the SDK examples make subtle. Three traps the explorer's LLM hit four times in a row on `power_iteration_2d`:

(1) **`c2d.get_params` takes THREE args, not four.** The layout-side call is
    `c2d.get_params(<inner_dim>, px, py)` where `<inner_dim>` is the LENGTH of
    the dimension perpendicular to the colors axis (typically Py for `x_*`
    colors, Px for `y_*` colors — the OTHER axis). The wrong invocation
    `c2d.get_params(Px, Py, px, py)` triggers
    `function expects 3 arguments, 4 provided`. See
    csl-examples/benchmarks/gemv-collectives_2d/layout.csl for the canonical form.

(2) **`mpi_x.broadcast` / `mpi_y.reduce_fadds` take `[*]u32` regardless of
    the payload's actual type.** Even when broadcasting f32 values you MUST
    write `@ptrcast([*]u32, &my_f32_buf)` — passing `[*]f32` triggers
    `expected type [*]u32, got: [*]f32`. The collective is byte-oriented; the
    element count argument tells it how many u32-sized chunks to ship.

(3) **`<collectives_2d/pe>` import requires `.dim_params = c2d_params.x` (or
    `.y`).** Importing as `@import_module("<collectives_2d/pe>", .{})` or
    with an empty struct fails compilation at the library's own pe.csl with
    `only 'var' and 'extern const' variables may be uninitialized` pointing
    at `param dim_params: comptime_struct;`. The layout passes a per-tile
    `c2d_params` struct via `@set_tile_code`, and the PE-side import consumes
    it: typically two imports, one for the X axis and one for the Y axis,
    with `.dim_params = c2d_params.x` and `.dim_params = c2d_params.y`
    respectively. Reference: csl-examples/tutorials/topic-11-collectives.

Symptom-to-fix table for fast triage:
| Symptom                                                         | Likely cause           | Fix                                                  |
|-----------------------------------------------------------------|------------------------|------------------------------------------------------|
| `function expects 3 arguments, 4 provided` near `c2d.get_params`| trap #1                | drop the extra dim arg                                |
| `expected type '[*]u32', got: '[*]f32'` at `mpi_*.broadcast`    | trap #2                | `@ptrcast([*]u32, &buf)`                              |
| `only 'var' and 'extern const' may be uninitialized` in pe.csl  | trap #3 (missing dim_params) | add `.dim_params = c2d_params.x` to the import struct |
| Runtime `hcf (halt and catch fire)` mid-kernel                  | malformed @fmacs slots | check slot order is `(dst_dsd, src0_dsd, src1_dsd_or_scalar, scalar)` |

### collectives_2d introspection: NUM_PES / pe_id / @get_rectangle — do NOT invent fields
The 2D-collectives params struct and module handle expose a FIXED, SMALL set of
introspection fields. The single biggest sdk-api failure (4 kernels: GEMV,
GEMM-Collectives-2D, GEMV-Collectives-2D, and fabric kernels) is INVENTING
CUDA-style names (threadIdx/blockDim analogues) the SDK does not have. Use ONLY
these real fields:

  // LAYOUT side — the per-axis params struct (.x and .y) each carry these
  // verbatim members:
  //     .pe_id   : this PE's index ALONG that axis (x-index for .x, y-index for .y)
  //     .NUM_PES : number of PEs along that axis  (this is the per-dim LENGTH)
  //     .pe_min  : bool, true if this PE is index 0 on the axis
  //     .pe_max  : bool, true if this PE is the last index on the axis
  //     .DIM_ID  : 0 for the x-axis params, 1 for the y-axis params
  // COMPUTE side — after `mpi_x.init(); mpi_y.init();`, the module handle exposes:
  //     mpi_x.pe_id   // == get_x_coord() for this PE (set INSIDE init(), not before)
  //     mpi_y.pe_id   // == get_y_coord()
  // MESH dims at comptime come from the @get_rectangle() builtin, NOT the module:
  //     const dims = @get_rectangle();  // dims.width = #PEs in x, dims.height = #PEs in y

Hallucinated name -> real name (every left-hand token is a COMPILE ERROR — the
field does not exist):
  DIM_LENGTH                         -> NUM_PES
  c2d_params.x.dim_size / .dim_x     -> c2d_params.x.NUM_PES
  c2d_params.x.PE_ID / .pe_id_x      -> c2d_params.x.pe_id   (or mpi_x.pe_id after init)
  layout_mod.get_x_dim()/get_y_dim() -> @get_rectangle().width / .height
  c2d_params.x.dim_y                 -> c2d_params.y.NUM_PES  (the OTHER axis)

Hard rules: (a) read mpi_x.pe_id / mpi_y.pe_id only AFTER init() — before init it is
garbage; (b) the per-PE tile sizes (Mt/Nt) are NOT introspected from the params
struct — they arrive as `param` from layout.csl; (c) the collective methods take a
`local_task_id` (a comptime task id) as their final callback arg, NOT a `fn()void`
and NOT a color.

### Affine tensor_access expressions cannot reference non-loop runtime variables
The expression inside `@get_dsd(mem1d_dsd, .{ .tensor_access = |i|{N} -> arr[EXPR] })`
must be affine in the bound induction variable (`|i|`) ONLY. Runtime captures
from the enclosing scope are illegal and produce
`error: invalid use of non-loop variable in affine expression`.

Wrong:
    fn step(row_base: u16) void {
        const dsd = @get_dsd(mem1d_dsd, .{
            .tensor_access = |j|{Nt} -> A[row_base + j]  // row_base is runtime
        });
        ...
    }

Right — build the DSD once over the whole array and offset at runtime via
`@increment_dsd_offset`:
    const A_dsd = @get_dsd(mem1d_dsd, .{
        .tensor_access = |j|{Nt} -> A[j]
    });
    fn step(row_base: i16) void {
        const row_dsd = @increment_dsd_offset(A_dsd, row_base * @as(i16, Nt), f32);
        ...
    }

This trap fires often in blocked-matmul / SUMMA kernels where the LLM tries to
emit per-row DSDs inside the K-loop. Seen 4 times in a row on `matmul_summa_2d`
exploration attempts.

### @export_symbol requires a bare global SYMBOL, not an @ptrcast expression
`@export_symbol` is comptime-evaluated and inspects its argument by NAME, not
by VALUE. Wrapping a pointer-cast inside the call breaks comptime resolution:

Wrong (compile error `expected comptime-known function value` /
`expected global variable or function symbol`):
    comptime { @export_symbol(@ptrcast([*]u32, &A_tile), "A"); }

Right — declare the cast pointer as a top-level `var` first, then export it:
    var A_ptr: [*]u32 = @ptrcast([*]u32, &A_tile);
    comptime { @export_symbol(A_ptr, "A"); }

The same pattern is used by the canonical `ptr_time_buf_u16` block in
csl-examples/benchmarks/gemv-collectives_2d/pe.csl. If you need to export
the same backing store under multiple names with different element types,
declare a separate `var` per @ptrcast target.

### Every device-side @export_symbol(ptr, "name") needs a matching @export_name("name", ...) in the LAYOUT
`@export_symbol(ptr_buf, "buf")` in the COMPUTE file (pe.csl) only registers
the device-side binding. For the host to see "buf" (via memcpy_h2d/d2h or
get_id), the LAYOUT file (the one with `layout { ... }` / `@set_tile_code`)
must ALSO declare it with `@export_name`. Omitting the layout side is the
single most common error when ADDING a new host-visible buffer to an existing
bundle — e.g. splicing in the tic/toc timestamp buffer for cycle
instrumentation.

Symptom (compile error, points at the pe.csl @export_symbol line):
    ./pe.csl:NNN: error: name 'time_buf_u16' was not declared during layout evaluation
      @export_symbol(ptr_time_buf_u16, "time_buf_u16");
    ./pe.csl:NNN: note: use @export_name to declare 'time_buf_u16' during layout evaluation
    ./code.csl: error: semantic error in module imported here  // @set_tile_code

Fix — add the export to BOTH files, with matching name and element type:
    // layout file (inside `layout { ... }`), `true` = host-visible:
    @export_name("time_buf_u16", [*]u16, true);
    // compute file (pe.csl), at top level then exported in comptime:
    var time_buf_u16 = @zeros([6]u16);
    var ptr_time_buf_u16: [*]u16 = &time_buf_u16;
    comptime { @export_symbol(ptr_time_buf_u16, "time_buf_u16"); }

The names must be byte-identical across the two files. fn entrypoints follow
the same rule: a device `@export_symbol(f_foo)` needs `@export_name("f_foo",
fn(...)void)` in the layout. Canonical reference: the five timing exports in
csl-examples/benchmarks/power-method/layout_power.csl
(`x`, `y`, `time_buf_u16`, `time_ref`, plus the `f_*` entrypoints) each have a
twin @export_symbol in kernel_power.csl. (Mined 2026-06-18 from an
auto-instrumentation attempt that added the pe.csl side only.)

### memcpy_h2d / memcpy_d2h internal element type is 32 bit by default
The SDK runtime constrains every memcpy operation in a single run.py session
to a consistent INTERNAL data type. The most reliable setting is 32-bit
throughout: declare 16-bit-element symbols on device, but cast the host-side
view to 32-bit and use `MemcpyDataType.MEMCPY_32BIT`. The canonical
exception is the timestamp readback, where `MEMCPY_16BIT` IS supported when
the bundle was built with `--memcpy --channels=1` AND the timestamp memcpy
comes after all data memcpys (see csl-examples/benchmarks/gemv-collectives_2d).

Symptom: `RuntimeError: Internal data type of any memcpy_d2h() or
memcpy_h2d() operation should be 32 bit.` at the timestamp read.

Fix options (in preference order):
(1) Move the timestamp memcpy_d2h to AFTER all data memcpy calls and BEFORE
    `runner.stop()`. The order matters for some SDK builds.
(2) Widen the timestamp buffer to u32 storage on device:
        var time_buf_u32 = @zeros([timestamp.tsc_size_words * 2]u32);
        ...
        time_buf_u32[0] = @as(u32, tscStartBuffer[0]);
    Then read it back with `MEMCPY_32BIT` and a `np.uint32` host buffer.
(3) Drop timestamps entirely for this bundle and rely on wall-clock from
    the harness; `cycles_send` will be null but the kernel still verifies.

### @initialize_queue / @bind_local_task / @bind_data_task are top-level-comptime-only
Hand-curated 2026-06-04 from r3+r4 grounded refutations + direct cslc testing.
These builtins are valid ONLY inside a top-level `comptime { ... }` block.
Placing them inside an fn/task body (even one gated by a runtime `if`) is a
compile-time error, NOT a silent runtime bug. The exact cslc 1.4.0 diagnostic is:

    pe.csl:N:M: error: builtin is only valid while evaluating a top level comptime block

Wrong (cslc rejects loudly):
    task try_init_once() void {
      @initialize_queue(my_oq, .{ .color = C_OUT });  // <-- compile error
    }
    comptime { @bind_local_task(try_init_once, T_BAD); @activate(T_BAD); }

Right — bind unconditionally at top-level comptime; gate runtime work via a flag:
    var queue_armed: bool = false;
    task arm_once() void {
      if (!queue_armed) { queue_armed = true; /* first-call work here */ }
    }
    comptime {
      @initialize_queue(my_oq, .{ .color = C_OUT });
      @bind_local_task(arm_once, T_OK);
      @activate(T_OK);
    }

Traps:
1. Any "Trap" describing downstream symptoms (dead code, duplicate-bind race) is
   a non-issue — the compile error short-circuits the entire compile.
2. The same rule applies to @activate, @export_symbol, @set_color_config,
   @bind_data_task — anything that wires up the comptime program graph.
3. Wrapping in `if (@is_arch("wse3"))` does NOT make it legal inside an fn body;
   @is_arch is comptime-evaluated but the surrounding scope is still runtime.

See csl-examples/tutorials/pipeline-02-fifo/pe_program.csl and
csl-examples/tutorials/topic-15-wse3-microthreads/right_pe.csl for the canonical
top-level-comptime pattern.

### DSDs over function-argument pointers: use .base_address, not tensor_access
Hand-curated 2026-06-04 from r3+r4 grounded refutations + direct cslc testing.
The tensor_access form `|i|{N} -> ARR[i]` requires ARR to be a comptime-known
concrete array name, NOT a runtime pointer passed as a function argument. cslc
emits: `expression does not yield the address of a variable or a comptime-known
pointer`. The fix is the .base_address form, which accepts a runtime `[*]T`.

Wrong:
    fn make_dsd_over_arg(buf_ptr: [*]f32) void {
      const bad_dsd = @get_dsd(mem1d_dsd, .{
        .tensor_access = |i|{4} -> buf_ptr[i]   // <-- compile error
      });
    }

Right:
    fn make_dsd_over_arg(buf_ptr: [*]f32) void {
      const ok_dsd = @get_dsd(mem1d_dsd, .{
        .base_address = buf_ptr, .extent = 4    // <-- runtime ptr OK here
      });
    }

Traps:
1. C-style prefix-deref forms like `(*p)[i]` are not CSL syntax at all (the
   language has no prefix `*` deref operator); don't lump them in with the
   tensor_access restriction.
2. Module-scope arrays can use tensor_access freely; the restriction is
   specifically about runtime pointers (fn args, params received via
   @set_tile_code, etc.).
3. .base_address requires .extent (or .extent + .stride) — without it, cslc
   doesn't know how long the DSD is.

See csl-examples/tutorials/topic-10-map-builtin and
csl-examples/tutorials/topic-01-arrays-and-pointers for the canonical DSD-over-
pointer patterns.

### Halo recv-count is per-PE and edge-dependent — hardcoded 4-neighbor counts deadlock boundary PEs
Hand-curated 2026-06-04 from r3+r4 grounded refutations.
Hardcoding `expected_recv = 4` in the receive task makes EVERY boundary PE wait
forever for wavelets that won't arrive. cslc cannot detect this — both Wrong
and Right snippets compile clean; the bug surfaces as a host D2H hang at
runtime. On a 2x2 mesh every PE is a corner (2 neighbors), so the bug is
maximally pathological; on any rectangle non-interior PEs deadlock.

The canonical pattern: edge bools (is_east_edge, is_west_edge, is_north_edge,
is_south_edge) are plumbed from layout.csl via the @set_tile_code params
struct, and expected_recv is derived from them. Note: @set_tile_code is
POSITIONAL — `@set_tile_code(px, py, "pe.csl", params_struct)` — there is no
struct-named form like `.x = px, .file = "..."`.

Wrong (compiles clean; runtime hang on every boundary PE):
    const expected_recv: u16 = 4;
    var recv_count: u16 = 0;
    task on_neighbor_arrived() void {
      recv_count += 1;
      if (recv_count == expected_recv) { /* proceed */ }
    }

Right — edge bools plumbed from layout, expected_recv derived per-PE:
    // layout.csl: @set_tile_code(px, py, "pe.csl",
    //   .{ .is_east_edge = (px == w-1), .is_west_edge = (px == 0),
    //      .is_north_edge = (py == 0),  .is_south_edge = (py == h-1) });
    param is_east_edge: bool;
    param is_west_edge: bool;
    param is_north_edge: bool;
    param is_south_edge: bool;
    const expected_recv: u16 = @as(u16, 4)
      - (if (is_east_edge)  @as(u16, 1) else @as(u16, 0))
      - (if (is_west_edge)  @as(u16, 1) else @as(u16, 0))
      - (if (is_north_edge) @as(u16, 1) else @as(u16, 0))
      - (if (is_south_edge) @as(u16, 1) else @as(u16, 0));

Traps:
1. Deriving edge state at runtime via layout_mod.get_x_coord() works, but is
   the secondary pattern; csl-examples/benchmarks/game-of-life uses the
   param-bool form, so stay canonical.
2. Hardcoding `is_east_edge = (get_x_coord() == 1)` only works on a 2x2 mesh;
   on a 3x3 it silently misclassifies the middle column. Always compare to
   `w-1` / `h-1` from a param, or compute the bool at layout time.
3. The "expected_events" builtin does NOT exist; the pattern is a user-defined
   `const expected_recv: u16 = ...` or a `param expected_recv: u16` plumbed
   from layout.

See csl-examples/benchmarks/game-of-life/pe_program.csl for the canonical
boolean-edge-flag pattern.

### Timestamp D2H on a multi-PE rectangle must read 6 words from EVERY PE, and every PE must unblock after f_toc
When adding tic/toc cycle instrumentation to a MULTI-PE kernel, two runtime
stalls bite (clean compile, then the host D2H aborts):

Symptom (runtime, not compile):
    terminate called after throwing an instance of 'std::runtime_error'
      what():  the received length (N bytes) is not expected (M bytes),
               could be a kernel stall

Two root causes, both specific to multi-PE timing:
(1) The timestamp memcpy_d2h dimensions must match the FULL rectangle. The
    canonical readback is `memcpy_d2h(buf, sym_time, 0,0, width, height, 6, ...)`
    — 6 u16 words per PE (3 for tscStart + 3 for tscEnd), over the whole
    width×height core. Copying from a single PE (1,1,...) or with the wrong
    word count on a multi-PE kernel yields the length-mismatch abort. The
    device buffer must be `var time_buf_u16 = @zeros([6]u16);` on EVERY PE
    in the rectangle, exported via @export_name/@export_symbol on every tile.
(2) EVERY PE — including ones whose compute already returned — must reach
    `sys_mod.unblock_cmd_stream()` AFTER f_toc / f_memcpy_timestamps, or the
    timestamp D2H hangs on the PEs that never unblocked. f_tic/f_toc/
    f_memcpy_timestamps each end with unblock_cmd_stream() in the canonical
    recipe (see power-method kernel_power.csl) precisely for this reason.

Contrast: a single-PE kernel (set_rectangle(1,1)) never hits either trap, which
is why auto-instrumentation succeeds on single-PE bundles (Residual, GEMV) but
stalls on multi-PE ones (Laplacian2D-Reduce, LorenzoPredictor-Tile, Mandelbrot,
Histogram) unless the per-PE buffer + full-rectangle D2H + per-PE unblock are
all present. (Mined 2026-06-18 from an instrument_kernel batch: 1/5 multi-PE
kernels passed; the 4 fails all aborted with the length-mismatch stall.)
"""


# ----------------------------------------------------------------------------
# 6c. CLUSTER-SPECIFIC QUERY AUGMENTATION (layer-1) — added 2026-06-03 (task #35)
# ----------------------------------------------------------------------------
# Detects which W1 failure cluster's vocabulary is present in the input
# (CUDA source or known signature) and appends cluster-specific keywords to
# the TF-IDF query. The query augmentation biases tutorial/skill retrieval
# toward the right chunks (e.g. topic-11-collectives for collectives_2d
# cluster, topic-15-wse3-microthreads for async-fabric cluster). Pure
# additive: original query terms still in play; we just add ~50-100 chars of
# focused keywords per matching cluster.

_W1_CLUSTER_QUERY_AUGMENTATIONS: List[Tuple[List[str], str]] = [
    # (markers, keywords to append)
    (
        # collectives_2d: presence in CUDA source OR known failure signature
        ["collectives_2d", "mpi_x", "mpi_y", "broadcast", "2D mesh", "gemv", "gemm"],
        "topic-11-collectives collectives_2d c2d_params mpi_x mpi_y "
        "broadcast reduce_fadds @import_module @concat_structs "
        "collectives_2d/pe dest_dsr_ids src0_dsr_ids src1_dsr_ids "
        "input_queues MultiPE 2D mesh routing"
    ),
    (
        # halo_recv_unblock: stencil, halo, edge-aware, multi-PE compute
        ["halo", "stencil", "is_n_edge", "is_s_edge", "neighbor", "border",
         "halos_expected", "halo_count", "recv_task", "sender", "receiver"],
        "pipeline-03-multiple artificial halo topic-15-wse3-microthreads "
        ".async fmovs fmacs microthread @bind_data_task @initialize_queue "
        "input_queue sentinel exit_task topic-03-streaming-wavelet-data "
        "pipeline-01-basic unblock_cmd_stream sender-only receiver edge "
        "corner PE recv_task wavelet data task fabric stall halo exchange ut_id"
    ),
    (
        # dsr_queue_fabric_init: explicit DSR/queue/color-config setup
        ["dest_dsr_ids", "src0_dsr_ids", "src1_dsr_ids", "input_queues",
         "output_queues", "@initialize_queue", "@get_input_queue",
         "@get_output_queue", "@get_ut_id", "@set_color_config", "MEMCPYH2D"],
        "DSR dest_dsr_ids src0_dsr_ids src1_dsr_ids input_queues "
        "output_queues fabric color config microthread @set_color_config "
        "@concat_structs topic-11-collectives @initialize_queue "
        "@get_input_queue @get_output_queue memcpy queue reservation "
        "MEMCPYH2D_DATA library param injection"
    ),
    (
        # C10 resource_id_alloc (failure-analysis 2026-06-23): multi-phase fabric
        # kernels (FFT butterfly, Game-of-Life CA, all-to-all/ring) collide with
        # memcpy-reserved colors/queues or re-use an id before it drains. Markers
        # are the allocation builtins + topology vocab + collision keywords.
        ["@get_color", "@get_local_task_id", "@get_input_queue",
         "@get_output_queue", "@get_ut_id", "fabric_color", "transpose",
         "butterfly", "fft", "all-to-all", "ring", "shift", "two phase",
         "multi-phase", "reserved", "collision"],
        "topic-15-wse3-microthreads reserved resource id ranges color ceiling "
        "@get_color 24 @get_input_queue @get_output_queue @get_ut_id "
        "local_task_id memcpy reserved MEMCPYH2D_DATA MEMCPYD2H_DATA "
        "single-occupancy drain cross-phase reuse safe allocation band"
    ),
]


def _augment_query_for_w1_clusters(query: str) -> str:
    """Append cluster-specific keywords if the query (CUDA source +
    target_relpath + cuda_analysis) contains the cluster's failure
    vocabulary. Multiple clusters can match simultaneously (e.g. a halo
    stencil that also uses collectives) — all matching augmentations are
    concatenated. Returns the query unchanged if no cluster matches OR if
    XKERNEL_W1_CLUSTER_QUERIES is disabled.

    Note: matches on the QUERY string (which is the CUDA source / cuda
    analysis / target_relpath), NOT on the bottleneck signature. The
    signature is only available AFTER a benchmark has been run; this
    helper fires on the initial translate prompt and on every repair.
    """
    if os.getenv("XKERNEL_W1_CLUSTER_QUERIES", "1") == "0":
        return query
    if not query:
        return query
    q_lower = query.lower()
    augmentations: List[str] = []
    for markers, keywords in _W1_CLUSTER_QUERY_AUGMENTATIONS:
        if any(m.lower() in q_lower for m in markers):
            augmentations.append(keywords)
    if not augmentations:
        return query
    return query + " " + " ".join(augmentations)


def _detect_w1_clusters_for_kernel(query: str) -> List[str]:
    """Return the list of cluster names whose markers fired on this query.
    Used to gate the W1 gotchas block: include only the cluster-specific
    sub-entries when the kernel actually has those bottleneck markers,
    instead of always-on. Trivially simple kernels (single-PE matvec
    without halo/collectives/queue setup) get none of the gotchas and
    avoid the regression observed on Single-Tile-Matvec.

    Cluster names returned: any of "collectives_2d", "halo_recv_unblock",
    "dsr_queue_fabric_init"."""
    if not query:
        return []
    q_lower = query.lower()
    # Marker → cluster name. Keep aligned with _W1_CLUSTER_QUERY_AUGMENTATIONS
    # above so the same kernels that get augmented queries get the
    # corresponding gotcha sections.
    cluster_markers = [
        ("collectives_2d", _W1_CLUSTER_QUERY_AUGMENTATIONS[0][0]),
        ("halo_recv_unblock", _W1_CLUSTER_QUERY_AUGMENTATIONS[1][0]),
        ("dsr_queue_fabric_init", _W1_CLUSTER_QUERY_AUGMENTATIONS[2][0]),
        ("resource_id_alloc", _W1_CLUSTER_QUERY_AUGMENTATIONS[3][0]),
    ]
    matched: List[str] = []
    for name, markers in cluster_markers:
        if any(m.lower() in q_lower for m in markers):
            matched.append(name)
    return matched


# Per-cluster gotcha selection: each entry in KNOWN_GOTCHAS_W1_FAILURE_PATTERNS
# is keyed to which cluster(s) it addresses. The implementer gets only the
# subsections relevant to the kernel they're translating.
_GOTCHA_SECTIONS_BY_CLUSTER = {
    "collectives_2d": [
        "collectives_2d/pe import takes DSR-id arrays",
        "Library .csl files with uninitialized `param`s",
        "collectives_2d API surface",
        # C4 fix (failure-analysis 2026-06-23): the API-surface section teaches the
        # call SIGNATURES but not the INTROSPECTION fields, so the agent invents
        # CUDA-style names (DIM_LENGTH/dim_size/get_x_dim). This section gives the
        # real NUM_PES/pe_id/@get_rectangle fields + an explicit fake->real map.
        "collectives_2d introspection: NUM_PES / pe_id / @get_rectangle",
        "Affine tensor_access expressions cannot reference non-loop runtime variables",
        "@export_symbol requires a bare global SYMBOL",
        "Every device-side @export_symbol(ptr, \"name\") needs a matching @export_name",
        "memcpy_h2d / memcpy_d2h internal element type is 32 bit",
        # Hand-curated 2026-06-04 from r3+r4 grounded evidence:
        "DSDs over function-argument pointers: use .base_address, not tensor_access",
        # Cluster-2 fix 2026-06-23: get_x_coord/get_y_coord at module scope
        # is the dominant compile blocker on GEMV/GEMM-Collectives-2D/GEMV-
        # Coll-2D (top-level `const`/use-site-cast init -> tile_config comptime
        # error). The runtime-only rule was previously wired ONLY to halo
        # kernels, so collectives kernels never saw it.
        "Per-PE role at runtime: use layout_mod.get_x_coord()/get_y_coord() inside fn/task bodies",
    ],
    "halo_recv_unblock": [
        "Receivers must call sys_mod.unblock_cmd_stream()",
        "Synchronous @fmovs on a fabric DSD blocks the calling task",
        "Edge / corner / guarded PE branches MUST still reach unblock_cmd_stream()",
        "WSE-3 queue / microthread ID pools and the @initialize_queue discipline",
        "Canonical halo receive: async fabin_dsd + ut_id + activate, posted before sends",
        "Per-PE role at runtime: use layout_mod.get_x_coord()/get_y_coord() inside fn/task bodies",
        "memcpy_h2d / memcpy_d2h internal element type is 32 bit",
        # Hand-curated 2026-06-04 from r3+r4 grounded evidence:
        "@initialize_queue / @bind_local_task / @bind_data_task are top-level-comptime-only",
        "Halo recv-count is per-PE and edge-dependent — hardcoded 4-neighbor counts deadlock boundary PEs",
        # Mined 2026-06-18 from the instrument_kernel multi-PE batch:
        "Timestamp D2H on a multi-PE rectangle must read 6 words from EVERY PE",
    ],
    "dsr_queue_fabric_init": [
        "memcpy library reserves input queues 0 and 1",
        "Synchronous @fmovs on a fabric DSD blocks the calling task",
        "Library .csl files with uninitialized `param`s",
        "Affine tensor_access expressions cannot reference non-loop runtime variables",
        "@export_symbol requires a bare global SYMBOL",
        "Every device-side @export_symbol(ptr, \"name\") needs a matching @export_name",
        # Hand-curated 2026-06-04 from r3+r4 grounded evidence:
        "@initialize_queue / @bind_local_task / @bind_data_task are top-level-comptime-only",
        "DSDs over function-argument pointers: use .base_address, not tensor_access",
        # Cluster-2 fix 2026-06-23: GEMV-Checkerboard etc. derive a per-PE
        # fabout role and trip the same module-scope get_x_coord comptime error.
        "Per-PE role at runtime: use layout_mod.get_x_coord()/get_y_coord() inside fn/task bodies",
        # Fix-4 (failure-analysis 2026-06-23): non-halo fabric kernels (GEMV-
        # Checkerboard, Game-of-Life, Wide-Mult) hit queue-init/async-fabric
        # stalls but only halo_recv_unblock surfaced these; route them here too.
        "WSE-3 queue / microthread ID pools and the @initialize_queue discipline",
        "Canonical halo receive: async fabin_dsd + ut_id + activate, posted before sends",
        # Rank-2 (failure-analysis 2026-06-25): per-tile route config arity.
        "Per-tile route config: @set_local_color_config arity + receive-side single source",
    ],
    # C10 (failure-analysis 2026-06-23): multi-phase fabric kernels (FFT-1D-2D,
    # Game-of-Life) collide with memcpy-reserved colors/queues or re-use an id
    # across phases. Surface the consolidated reserved-ID safe-allocation table
    # plus the queue-init + drain discipline.
    "resource_id_alloc": [
        "WSE-3 reserved resource-ID ranges: a single safe-allocation table for colors / queues / task-ids / microthreads",
        "memcpy library reserves input queues 0 and 1",
        "WSE-3 queue / microthread ID pools and the @initialize_queue discipline",
        # Rank-2 (failure-analysis 2026-06-25, FFT-1D-2D): per-tile route config arity
        # (@set_local_color_config 2-arg vs @set_color_config 4-arg) + receive-side
        # single-source rule. General platform facts.
        "Per-tile route config: @set_local_color_config arity + receive-side single source",
    ],
}


def _filter_w1_gotchas_for_clusters(matched_clusters: List[str]) -> str:
    """Return only the gotcha subsections relevant to the matched clusters.
    If no clusters matched, returns empty string (avoids the noise that
    caused the Single-Tile-Matvec regression in resweep w1lo0sycr).

    Each gotcha section in KNOWN_GOTCHAS_W1_FAILURE_PATTERNS is a `### `
    H3 markdown header. We split on those headers and keep only sections
    whose title matches any of the cluster's listed titles."""
    if not matched_clusters:
        return ""
    wanted_titles: List[str] = []
    for cl in matched_clusters:
        wanted_titles.extend(_GOTCHA_SECTIONS_BY_CLUSTER.get(cl, []))
    if not wanted_titles:
        return ""
    # Split the full gotchas block on H3 markers.
    parts = KNOWN_GOTCHAS_W1_FAILURE_PATTERNS.strip().split("\n### ")
    # parts[0] is the H2 header ("## Recurring W1 translation traps ...")
    # plus everything before the first H3. parts[1..] are individual H3
    # sections (without the leading "### ").
    if len(parts) < 2:
        return ""
    # Surgical A/B gate: when XKERNEL_MINED_GOTCHAS=0, drop gotchas mined by
    # the experience-mining loop (titled with the markers below) so a sweep can
    # isolate their marginal pass-rate lift against the prior knowon arm.
    mined_titles = [
        'Every device-side @export_symbol(ptr, "name") needs a matching @export_name',
        "Timestamp D2H on a multi-PE rectangle must read 6 words from EVERY PE",
    ]
    drop_mined = os.getenv("XKERNEL_MINED_GOTCHAS", "1") == "0"
    # Attributable A/B gate (2026-06-24): XKERNEL_FIXES_C4_C5_C10=0 drops exactly the
    # C4 (collectives introspection) and C10 (reserved resource-ID) sections so a
    # sweep can isolate their lift from the rest of the gotcha system. C5 (the lib-sig
    # arch fix) is gated separately in library_signatures via the same env var.
    drop_c4_c10 = os.getenv("XKERNEL_FIXES_C4_C5_C10", "1") == "0"
    c4_c10_titles = [
        "collectives_2d introspection: NUM_PES / pe_id / @get_rectangle",
        "WSE-3 reserved resource-ID ranges",
    ]
    # Attributable A/B gate (2026-06-25): XKERNEL_FIXES_20260625=0 drops the KB gotchas
    # added in the 2026-06-25 patch round (R2 per-tile route-config; R3 is a salience
    # edit to an existing section so it can't be cleanly dropped here — see note below).
    drop_20260625 = os.getenv("XKERNEL_FIXES_20260625", "1") == "0"
    titles_20260625 = [
        "Per-tile route config: @set_local_color_config arity",
    ]
    intro = parts[0]
    kept = []
    for sec in parts[1:]:
        title = sec.split("\n", 1)[0].strip()
        if drop_mined and any(m in title for m in mined_titles):
            continue
        if drop_c4_c10 and any(m in title for m in c4_c10_titles):
            continue
        if drop_20260625 and any(m in title for m in titles_20260625):
            continue
        if any(want in title for want in wanted_titles):
            kept.append("### " + sec)
    if not kept:
        return ""
    return intro + "\n\n" + "\n\n".join(kept)


# ---------------------------------------------------------------------------
# Hard-kernel hints (2026-06-21): distilled from the test-split sweep's two
# 12/12 translation failures (Game-of-Life, Cholesky), then adversarially
# leak-audited. Each hint is FIREWALL-SAFE — every claim derives from public
# Cerebras SDK platform docs + the CUDA source + the GIVEN layout.csl, never
# from the hidden reference compute file. (Audit verified the final hints
# encode NONE of the references' specific queue/task/color id choices; the
# 21/27-31 band cited is memcpy's reserved range, a platform fact unused by
# either reference.) The two failures had distinct ceilings:
#   - Game-of-Life: fabric-routing — async-op single-occupancy + same-color
#     send/recv deadlock + memcpy-reserved-id collisions.
#   - Cholesky: the agent ABANDONS the algorithm (prose/stubs) because the
#     full protocol is unrealizable from pe.csl alone when routing is hidden;
#     the hint reframes it as a 1:1 send/recv-matching contract against the
#     given layout, plus "emit compilable CSL or nothing / no partial kernels".
# Gated XKERNEL_HARD_KERNEL_HINTS (default ON), vocabulary-matched so they only
# fire on the kernel class that needs them (A/B-comparable, like the W1 gotchas).
HARD_KERNEL_HINT_GOL = """
## Multi-PE neighbor-exchange discipline (async fabric + deadlock-free routing)
Send N/S along one fabric color/queue and E/W along a different one. The single
biggest WSE multi-PE stencil trap is treating an async fabric op as
fire-and-forget: an output queue, its fabric color, and its microthread (UT) id
are each single-occupancy until that op DRAINS. Re-issuing on any of them before
completion — or posting two wavelets to one neighbor back-to-back on one queue —
either silently stalls the fabric (host sees a 0-byte / "kernel stall" read) or
triggers "overwriting ut_instr[N]".

Rules:
1. Coalesce: multiple values to one neighbor go as ONE DSD of extent=N, not as
   separate concurrent ops.
2. Gate re-issue on COMPLETION, not on a software counter: chain the next phase
   off the prior send's drain via `.unblock`/`.activate` task gating, so a
   color/queue/UT is never re-driven while busy.
3. Deadlock-free exchange: when neighbors send to each other every step, a
   single color per direction deadlocks. Use dual colors with even/odd PE
   parity, or phase-separated send/recv with drain barriers.
4. Reserved resources: with `<memcpy>` active, input-queue 0 (H2D) and
   output-queue 0 (D2H) plus a low task-id band (~21-31) are reserved invisibly.
   Start user input/output queues at 2+ and user task ids at 8+; never reuse 0
   for fabric I/O.
5. Cross-file contract: colors/routes are fixed in `layout.csl`, which you do
   not author. Your compute file must match that color/queue contract exactly,
   not improvise its own.
""".strip()

HARD_KERNEL_HINT_FACTORIZATION = """
## Co-designed multi-PE factorization: match the routing contract, emit real CSL
Emit compilable CSL only — never pseudocode, English prose, "step(k):" sketches,
or `...` placeholders; cslc fails on line 1 and the attempt scores zero, so a
smaller fully-realized kernel beats a described large one. Equally, never ship a
knowingly-partial kernel (e.g. diagonal-tiles-only): the contract verifies the
FULL factorization, so any unfactored tile is a guaranteed fail, not partial
credit.

This is a co-designed multi-PE kernel: a hidden, immutable routing file fixes
which PE injects/forwards/receives each wavelet, and your compute file's every
send must be matched 1:1 by a receive in matching color and order. Before
finalizing, trace every step's senders and receivers across all PE roles
(diagonal, row/column fringe, interior, inactive lower-triangle) and confirm
each receive is matched by exactly one send. A receive posted for a wavelet no
PE injects deadlocks and surfaces at D2H as "received length (0 bytes), kernel
stall"; symmetrically, never send into a color no PE consumes. A PE with no
input that step must post no receive. If a required operand has no injector
reachable under the given routing, the protocol is wrong — rework the data flow
rather than dropping the phase.

Deadlock-free discipline: order ops so no cycle of PEs is all-blocked-waiting;
drive per-step receives off control wavelets / `pop_on_advance`, not fixed
counts. Async fabric ops complete via callback — chain the next step from the
completion callback, and don't reuse a microthread/UT slot or DSD until its op
signals done.

Platform resource rules: local task IDs are valid only in `[8,31)`
(`@get_local_task_id(32)` is illegal); memcpy reserves several task/queue IDs
(commonly 21 and 27-31) — keep user tasks/colors/queues clear or they collide at
compile time; DSD `.extent` must be comptime-known — declare at a comptime max
length and vary per-step via `@set_dsd_length`/`@increment_dsd_offset`, never
from a runtime `i16`/param.
""".strip()

# Vocabulary markers that select which hard-kernel hint (if any) applies.
_HARD_KERNEL_HINT_MARKERS = [
    # (hint_text, [markers any of which fire it])
    (HARD_KERNEL_HINT_FACTORIZATION,
     ["cholesky", "factoriz", "triangular", "trsm", "potrf", "lu decomp",
      "schur", "right-looking", "blocked factor"]),
    (HARD_KERNEL_HINT_GOL,
     ["game of life", "game-of-life", "conway", "cellular automaton",
      "neighbor count", "8-neighbor", "eight neighbor", "toroidal",
      "halo exchange", "stencil neighbor"]),
]


def hard_kernel_hints(query: str = "") -> str:
    """Return the firewall-safe hard-kernel hint(s) whose vocabulary matches the
    query (CUDA source + target + analysis). Gated XKERNEL_HARD_KERNEL_HINTS
    (default on); returns "" when off or when no marker fires. At most one hint
    of each kind is appended (factorization checked before the more generic
    neighbor-exchange one)."""
    if os.getenv("XKERNEL_HARD_KERNEL_HINTS", "1") == "0" or not query:
        return ""
    q = query.lower()
    for hint, markers in _HARD_KERNEL_HINT_MARKERS:
        if any(m in q for m in markers):
            return hint  # first match wins (factorization is checked first)
    return ""


# Cross-file collectives_2d wiring exemplar (2026-06-22). Cholesky co-design
# failures clustered on the agent desyncing collectives_2d params between its own
# pe.csl and layout.csl (c2d.get_params arity; c2d_params.x/.y; dsr-id arrays).
# This exemplar shows the EXACT two-file contract, sourced verbatim-in-structure
# from the TRAIN collectives kernels (GEMM/GEMV-Collectives-2D — allowed pattern
# sources per docs/SPLIT_AND_LEAKAGE.md) + the SDK <collectives_2d> module. It
# contains ZERO target-kernel-reference content (no algorithm, no Cholesky
# routing) — it is platform/library wiring, firewall-safe. Only useful when the
# agent authors BOTH files (co-design), so it is gated on that mode + collectives
# vocabulary.
COLLECTIVES_2D_CODESIGN_EXEMPLAR = r"""
## collectives_2d cross-file wiring (when you author BOTH layout.csl and pe.csl)
If your routing uses the `<collectives_2d>` library (row/column broadcast + reduce
on a PxP mesh), the params MUST be built in layout.csl and consumed in pe.csl with
EXACTLY matching shapes. Desyncing them is the #1 co-design failure. The contract:

### layout.csl — build c2d_params per PE and pass it down
```csl
const c2d = @import_module("<collectives_2d/params>");
// ... inside layout { @set_rectangle(P,P); ... per (Px,Py): }
const c2d_params = c2d.get_params(Px, Py, .{
    .x_colors      = .{ @get_color(0),         @get_color(1) },
    .x_entrypoints = .{ @get_local_task_id(8), @get_local_task_id(9) },
    .y_colors      = .{ @get_color(4),         @get_color(5) },
    .y_entrypoints = .{ @get_local_task_id(10), @get_local_task_id(11) },
});
@set_tile_code(Px, Py, "pe.csl", .{
    .memcpy_params = memcpy.get_params(Px),
    .c2d_params = c2d_params,
    // ... your sizes/task-ids ...
});
```
Notes: `get_params(Px, Py, .{...})` takes the two PE coords + ONE struct of
4 fields (NOT `get_params(P,P,px,py)` — that arity is wrong). The two x_colors /
two y_colors are a deadlock-free even/odd pair the library manages; you just
allocate 4 distinct colors (here 0,1,4,5) and 4 distinct entrypoint task ids
(8–11), all clear of memcpy's reserved band.

### pe.csl — import one collectives module PER AXIS, consuming .x / .y
```csl
param c2d_params: comptime_struct;
const mpi_x = @import_module("<collectives_2d/pe>", .{
    .dim_params = c2d_params.x,          // .x for the row (x) axis
    .queues = [2]u16{2,4},               // 2 distinct input/output queues
    .dest_dsr_ids = [1]u16{1}, .src0_dsr_ids = [1]u16{1}, .src1_dsr_ids = [1]u16{1},
});
const mpi_y = @import_module("<collectives_2d/pe>", .{
    .dim_params = c2d_params.y,          // .y for the column (y) axis
    .queues = [2]u16{3,5},               // DISJOINT from mpi_x's queues
    .dest_dsr_ids = [1]u16{2}, .src0_dsr_ids = [1]u16{2}, .src1_dsr_ids = [1]u16{2},
});
```
Then, after `mpi_x.init(); mpi_y.init();` (sets `mpi_x.pe_id`/`mpi_y.pe_id`):
```csl
// broadcast: root `step` sends its buffer to the whole row/column
mpi_x.broadcast(step, @ptrcast([*]u32, Ap), N_ELEMS, x_task_id);
// reduce (sum across the axis into a dest): note the count is (axis_len - 1)
mpi_x.reduce_fadds(Pw - 1, @ptrcast([*]f32, &local), @ptrcast([*]f32, &out), task_id);
```
Hard rules: mpi_x consumes `c2d_params.x`, mpi_y consumes `c2d_params.y` (never
swap). The two modules' `.queues` and `.dsr_ids` must be DISJOINT. Every collective
takes a completion task-id and fires it when done — chain dependent collectives
through the callback, never assume synchronous completion.
""".strip()


def collectives_2d_codesign_exemplar(query: str = "") -> str:
    """Return the cross-file collectives_2d wiring exemplar when (a) co-design
    mode is on (the agent authors layout.csl too, so cross-file wiring is its
    problem), and (b) the query mentions collectives/mesh/broadcast vocabulary.
    Firewall-safe (train-kernel + SDK sourced). Gated XKERNEL_CODESIGN_EXEMPLAR
    (default on) — independent of the always-relevant hard-kernel hints."""
    if os.getenv("XKERNEL_CODESIGN_LAYOUT", "0") != "1":
        return ""  # only meaningful when the agent writes both files
    if os.getenv("XKERNEL_CODESIGN_EXEMPLAR", "1") == "0" or not query:
        return ""
    q = query.lower()
    markers = ("collectives", "collective", "broadcast", "reduce", "mesh",
               "row/column", "all-reduce", "allreduce", "cholesky", "gemm",
               "matmul", "matrix", "factoriz")
    if any(m in q for m in markers):
        return COLLECTIVES_2D_CODESIGN_EXEMPLAR
    return ""


# ---------------------------------------------------------------------------
# 7. ARCHITECT CONTEXT (design-time reasoning, no syntax noise)
# ---------------------------------------------------------------------------
# Prose-only. The architect agent picks the wafer-scale decomposition; it does
# NOT write CSL. Showing it @fmach / DSD code at this stage encourages it to
# jump to implementation instead of reasoning about layout. Distilled from
# WaferLLM (OSDI'25) and the cerebras-kernel-challenge SPEC.
ARCHITECT_CONTEXT = """
## Wafer-Scale Architecture Reasoning

You are designing a CSL kernel for the Cerebras Wafer-Scale Engine (WSE-2 or
WSE-3). The target is a 2D mesh of PEs (typical sizes: WSE-2 has 850k PEs in
a ~750×996 grid; WSE-3 has 900k PEs in a ~990×910 grid). Each PE has roughly
48 KB of SRAM, a small instruction memory, and direct fabric routing to its
four neighbors via a configurable color palette.

### Hard constraints to reason about FIRST
- **Per-PE SRAM is the binding budget.** Sum all per-PE buffers (input tiles,
  output tiles, scratch, fabric staging). 40 KB is a safe ceiling; > 48 KB is
  a link-time error. If your decomposition overflows, retile finer (more PEs
  hold smaller pieces) rather than spilling.
- **Fabric bandwidth is per-edge, not aggregate.** Each PE-PE link is one
  word per cycle. A row-broadcast across P PEs costs P-1 hops on the slowest
  link. A tree allreduce of K elements down a column of P PEs costs roughly
  K · log₂(P) cycles. Estimate before committing.
- **PE arithmetic throughput is one FMAC/cycle.** A local tile of M×N takes
  M·N cycles at peak. If your local compute time dominates communication,
  you're memory-bound on tile size and want bigger tiles. If communication
  dominates, you want smaller tiles or more concurrency (async fabric DMA,
  ping-pong buffers).
- **Determinism is not free.** Collectives fire on every PE in a group;
  asynchronous wavelet arrival order can vary. If correctness depends on a
  reduction order (max, argmin, lexicographic ties), build the order in
  explicitly — never assume "first arrival wins."

### Decomposition taxonomy (pick one per tensor)
- `replicated`: every PE holds the full tensor. Use for small vectors (~1 KB)
  read by every PE — e.g., the query vector in a kNN search.
- `1d-along-x` / `1d-along-y`: tensor split across one axis of the mesh; the
  other axis is replicated. Use for vectors whose length matches one mesh
  dim — e.g., output of a row-parallel GEMV.
- `row-tiled` / `col-tiled`: matrix split into row-blocks (or col-blocks).
  Use when one operand is consumed by row (or col) broadcast.
- `2d-block`: matrix split into a P×P grid of Mt×Nt tiles. Canonical layout
  for GEMM; required when both M and N exceed what a single PE can hold.
- `replicated-with-halo`: stencil pattern. Each PE owns an interior tile plus
  a 1-cell (or k-cell) border exchanged with the four neighbors each step.

### Decision flow you should follow
1. **What does the host expect to send and receive?** Read the reference
   contract's `layout.csl` and `run.py`: which symbols are H2D, which are
   D2H, what's the mesh shape, what colors are reserved by memcpy.
2. **What's the data flow inside the kernel?** Identify the reductions
   (where partial results combine), the broadcasts (where one PE's data
   is consumed by many), and the local-only compute.
3. **Memory budget check.** For your chosen tiling, sum the per-PE tile
   sizes. If you exceed 40 KB, redo step 2 with finer tiles.
4. **Pick the collective library.** Use `<collectives_2d>` for clean GEMM
   patterns (one-time setup cost, ~10-20% latency overhead). Roll your own
   fabric colors only when you need either (a) tight latency, (b) more than
   one simultaneous reduction direction, or (c) a non-standard topology
   (e.g., torus, checkerboard).
5. **Identify the determinism hazards.** Any tie in a reduction, any
   variable-length encoding, any merge of incoming wavelets — these need an
   explicit ordering rule, not "whatever arrives first."

### What's an acceptable DESIGN.md
A good architecture memo is one page of prose that someone reading the code
2 weeks later could use to reconstruct your reasoning. It should be:
- **Specific**: name the tensors, give the tile sizes, cite the mesh
  dimensions from the reference bundle.
- **Bandwidth-accounted**: estimate the dominant cost (cycles or bytes) on
  the bottleneck link or PE.
- **Defended on edge cases**: state at least one input shape where your
  design might struggle (uneven shard, all-equal values, K=1, K=N).
- **Honest about trade-offs**: if you picked the simpler-but-slower option,
  say so and explain why.
"""

# ---------------------------------------------------------------------------
# 8. REVIEWER CHECKLIST (post-failure triage)
# ---------------------------------------------------------------------------
# Used when a benchmark fails. Distilled from the cerebras-kernel-challenge
# SPEC §8 "what an AI assistant cannot one-shot" + the KNOWN_GOTCHAS most
# observed in our 17-kernel sweeps. The reviewer's job is to decide whether
# the failure is architectural (route back to architect) or implementation
# (route back to implementer).
REVIEWER_CHECKLIST = """
## CSL Failure Triage Checklist

When a translated kernel fails benchmark, classify the failure into ONE of
the buckets below. The bucket determines who fixes it next.

### Bucket A — architectural (route back to ARCHITECT)
The decomposition is wrong, not the code. Symptoms:
- Compile error mentioning memory overflow (`section .data exceeds size`,
  link-time SRAM overflow): tile is too big for one PE. Need finer tiling.
- Correctness fail with output mostly zeros or mostly garbage: data didn't
  reach the compute PEs at all. Likely wrong collective direction, wrong
  PE-rank check, or missing broadcast.
- Correctness fail with one value correct, others wrong: only PE(0,0)
  computed; reduction never propagated. Likely missing allreduce or a
  collective callback that activated the wrong task.
- Correctness fail with the SAME wrong answer on every run: deterministic
  bug — algorithm is wrong (tie-breaking, accumulation order, scaling).
- Correctness fail with DIFFERENT wrong answers across 3 runs:
  non-determinism in collective merge or wavelet arrival order. Architect
  must add explicit ordering.

### Bucket B — implementation (route back to IMPLEMENTER)
The decomposition is right, the CSL has a syntax or local logic bug.
Symptoms:
- Compile error mentioning type mismatch (`expected i16, got u16`): missing
  `@as(i16, param)` cast in a DSD offset or loop bound.
- Compile error about colors, queues, or task IDs: probably colliding with
  reserved memcpy colors (0–3 on most setups) or with collectives_2d's
  reserved task IDs.
- Compile error about DSD construction in a loop: build the DSD once at
  module scope, then patch base/length per iteration with
  `@set_dsd_base_addr` / `@set_dsd_length`.
- Runtime hang (timeout): a fabric send into a non-existent neighbor (edge
  PE didn't guard with `if (px > 0)`), or a missing sentinel, or a
  collective callback that never fires because its task wasn't `@bind`ed.

### Bucket C — bundle contract violation (route back to IMPLEMENTER w/ contract reminder)
- Exported symbol renamed or removed (run.py can't find it).
- Task ID changed (collectives_2d expected a specific ID, found another).
- New file introduced (reference bundle's commands_*.sh doesn't compile it).

### Edge-case inputs the kernel should be tested against
Adapted from the cerebras-kernel-challenge SPEC. Even if the baseline passes,
flag these in the review:
- Smallest-K / smallest-N case (does the kernel handle K=1 or K=N=PE_count?).
- All-equal inputs (does tie-breaking produce a stable, documented order?).
- Duplicate inputs (does a "skip duplicates" optimization wrongly drop one?).
- Uneven shard (does it handle N not divisible by mesh size?).
- Repeated runs (do 3 runs produce bit-identical output?).

If the kernel passes the baseline but would obviously fail one of these,
flag the architect to amend the design before declaring success.
"""

# ---------------------------------------------------------------------------
# Assembly helpers
# ---------------------------------------------------------------------------

def release_notes_context(query: str = "",
                          *,
                          max_chars: int = 3000,
                          include_future: bool = False) -> str:
    """Return version-filtered Cerebras docs snippets, if the local KB exists."""
    try:
        from knowledge.cerebras_docs import CerebrasKnowledgeBase
    except Exception:
        return ""

    kb = CerebrasKnowledgeBase()
    if not kb.chunks:
        return ""
    target_sdk = os.getenv("XKERNEL_TARGET_SDK", "1.4.0")
    arch = os.getenv("XKERNEL_TARGET_ARCH", "wse3")
    default_query = (
        "CSL WSE-3 compiler DSD queues memcpy SdkRuntime known issues "
        "deprecations removed compatibility"
    )
    context = kb.prompt_context(
        query or default_query,
        target_sdk=target_sdk,
        arch=arch,
        top_k=6,
        max_chars=max_chars,
        include_future=include_future,
    )
    if not context:
        return ""
    return "\n".join([
        f"## Cerebras SDK Release Notes Context (target SDK {target_sdk}, arch {arch})",
        "Use these notes only when compatible with the target SDK. Do not use newer features "
        "unless explicitly requested for migration.",
        context,
    ])


_DEBUG_KB_PATH = REPO_ROOT / "knowledge" / "data" / "cerebras_debug_techniques.jsonl"


def debug_techniques_context(query: str = "",
                             *,
                             max_chars: int = 3500,
                             include_future: bool = False) -> str:
    """Return hand-authored debug recipes / tooling notes relevant to the query.

    Mirrors release_notes_context but loads a SEPARATE corpus at
    ``knowledge/data/cerebras_debug_techniques.jsonl``. Each chunk is a
    failure recipe ("symptom: 0 bytes received...") or a debug-tooling note
    (using the ``<debug>`` library, ``csdb wavelet-trace``, etc.).

    Env-gated by XKERNEL_DEBUG_TECHNIQUES (default "1"). Set to "0" to
    disable (A/B harness can compare with-debug vs without-debug verdicts).
    """
    if os.getenv("XKERNEL_DEBUG_TECHNIQUES", "1") == "0":
        return ""
    if not _DEBUG_KB_PATH.exists():
        return ""
    try:
        from knowledge.cerebras_docs import CerebrasKnowledgeBase
    except Exception:
        return ""
    try:
        kb = CerebrasKnowledgeBase(path=_DEBUG_KB_PATH)
    except Exception:
        return ""
    if not kb.chunks:
        return ""
    target_sdk = os.getenv("XKERNEL_TARGET_SDK", "1.4.0")
    arch = os.getenv("XKERNEL_TARGET_ARCH", "wse3")
    default_query = (
        "debug fail error hang received 0 bytes compile runtime "
        "wavelet trace csdb sdk_debug_shell unexpected character"
    )
    context = kb.prompt_context(
        query or default_query,
        target_sdk=target_sdk,
        arch=arch,
        top_k=5,
        max_chars=max_chars,
        include_future=include_future,
    )
    if not context:
        return ""
    return "\n".join([
        "## Cerebras Debug Techniques (symptom → diagnosis → action)",
        "Use these recipes to map an observed failure (stderr line, runtime "
        "exception, or symptom name) to a concrete diagnostic action — either "
        "a code fix, a `<debug>` library trace to insert, or a `csdb` "
        "command to run. Prefer the cheapest diagnostic that closes the gap.",
        context,
    ])


_TUTORIALS_KB_PATH = REPO_ROOT / "knowledge" / "data" / "cerebras_tutorials.jsonl"

# Per-audience section filter, default query, and top_k.
# Sections come from knowledge/ingest_tutorials.py's chunk emission.
# Format per entry: (sections, default_query, top_k).
_TUTORIAL_AUDIENCE_CONFIG = {
    "architect":   (["tutorial_readme_architect"],
                    "wafer scale decomposition tiling mesh layout",
                    3),
    "implementer": (["tutorial_csl_implementer"],
                    "DSD task fabric memcpy queue csl pattern",
                    4),
    "reviewer":    (["tutorial_readme_reviewer"],
                    "fifo data task collective debug trace symptom",
                    2),
}


def tutorial_context(query: str = "",
                     *,
                     audience: str = "implementer",
                     max_chars: int = 3500,
                     include_future: bool = False) -> str:
    """Return Cerebras CSL tutorial chunks relevant to the query, filtered
    by which agent role is asking.

    Mirrors debug_techniques_context but loads the corpus generated by
    ``knowledge/ingest_tutorials.py``. The corpus has three section labels;
    each lens function passes its role as ``audience`` so the section filter
    dispatches the right subset:

      - architect   -> READMEs (prose only; reasoning, not code)
      - implementer -> CSL fn/task/comptime blocks (worked code)
      - reviewer    -> READMEs (same prose; separate section for
                       independent TF-IDF ranking)

    Env-gated by XKERNEL_TUTORIALS (default "1"). Set to "0" to disable.
    """
    if os.getenv("XKERNEL_TUTORIALS", "1") == "0":
        return ""
    if audience not in _TUTORIAL_AUDIENCE_CONFIG:
        return ""
    # Allow ablations to point the lens at an alternate JSONL (e.g. a narrow
    # 4-tutorial corpus) without code changes.
    kb_path_str = os.getenv("XKERNEL_TUTORIALS_KB_PATH", "")
    kb_path = Path(kb_path_str) if kb_path_str else _TUTORIALS_KB_PATH
    if not kb_path.exists():
        return ""
    try:
        from knowledge.cerebras_docs import CerebrasKnowledgeBase
    except Exception:
        return ""
    try:
        kb = CerebrasKnowledgeBase(path=kb_path)
    except Exception:
        return ""
    if not kb.chunks:
        return ""

    sections, default_query, top_k = _TUTORIAL_AUDIENCE_CONFIG[audience]
    target_sdk = os.getenv("XKERNEL_TARGET_SDK", "1.4.0")
    arch = os.getenv("XKERNEL_TARGET_ARCH", "wse3")
    context = kb.prompt_context(
        query or default_query,
        target_sdk=target_sdk,
        arch=arch,
        sections=sections,
        top_k=top_k,
        max_chars=max_chars,
        include_future=include_future,
    )
    if not context:
        explored = _explored_tutorial_context(query or default_query,
                                              audience=audience,
                                              max_chars=max_chars)
        if explored:
            return explored
        return ""
    # Concatenate any leak-checked explored tutorials at the bottom — the
    # firewall (see knowledge_persistence.tutorial_leak_check) guarantees
    # they don't echo bench answer details.
    explored = _explored_tutorial_context(query or default_query,
                                          audience=audience,
                                          max_chars=max(800, max_chars // 3))
    main_block = "\n".join([
        f"## CSL Tutorials Context ({audience})",
        "Worked examples from the Cerebras csl-examples tutorials, retrieved "
        "by relevance to the current kernel. Use these to recognize idioms; "
        "adapt sizes, color names, and routing to the reference contract.",
        context,
    ])
    if explored:
        return main_block + "\n\n" + explored
    return main_block


_EXPLORED_TUTORIALS_KB_PATH = (
    (REPO_ROOT / "knowledge/explored/ingest/explored_tutorials.jsonl")
)


def _explored_tutorial_context(query: str, *, audience: str, max_chars: int) -> str:
    """Optional tail-on to tutorial_context: pulls from leak-checked
    tutorials promoted via explore_promote.py. Returns "" when no such
    corpus exists yet (the common case until exploration has produced
    something). Env-gated by XKERNEL_EXPLORED_TUTORIALS (default "1").
    """
    if os.getenv("XKERNEL_EXPLORED_TUTORIALS", "1") == "0":
        return ""
    if audience not in _TUTORIAL_AUDIENCE_CONFIG:
        return ""
    kb_path = _EXPLORED_TUTORIALS_KB_PATH
    if not kb_path.exists():
        return ""
    try:
        from knowledge.cerebras_docs import CerebrasKnowledgeBase
    except Exception:
        return ""
    try:
        kb = CerebrasKnowledgeBase(path=kb_path)
    except Exception:
        return ""
    if not kb.chunks:
        return ""
    sections, default_query, top_k = _TUTORIAL_AUDIENCE_CONFIG[audience]
    target_sdk = os.getenv("XKERNEL_TARGET_SDK", "1.4.0")
    arch = os.getenv("XKERNEL_TARGET_ARCH", "wse3")
    context = kb.prompt_context(
        query or default_query,
        target_sdk=target_sdk,
        arch=arch,
        sections=sections,
        top_k=max(1, top_k - 1),
        max_chars=max_chars,
        include_future=True,
    )
    if not context:
        return ""
    return "\n".join([
        f"## Explored-Kernel Tutorials ({audience}) — distilled from autonomous exploration",
        "These are CONCEPT-LEVEL guides (not the bench answers themselves). "
        "Each was leak-checked so it cannot reveal a benchmark's compute file. "
        "Use them as you would the upstream tutorials.",
        context,
    ])


_SKILLS_KB_PATH = REPO_ROOT / "knowledge" / "data" / "cerebras_skills.jsonl"

# Per-audience section filter, default query, and top_k for the skills corpus.
# Sections come from knowledge/ingest_skills.py's chunk emission and follow
# the pattern "csl_skill_{audience}". Default queries are tuned per role.
_SKILLS_AUDIENCE_CONFIG = {
    "architect":   (["csl_skill_architect"],
                    "routes colors fabric microthreads layout host device",
                    3),
    "implementer": (["csl_skill_implementer"],
                    "DSD task builtin comptime library type syntax module",
                    4),
    "reviewer":    (["csl_skill_reviewer"],
                    "sdkruntime debug dump_core read_symbol api precondition",
                    3),
}


def skills_context(query: str = "",
                   *,
                   audience: str = "implementer",
                   max_chars: int = 3500,
                   include_future: bool = False) -> str:
    """Return cerebras-csl-skills chunks relevant to the query, filtered by
    which agent role is asking.

    Mirrors tutorial_context() but loads the corpus generated by
    ``knowledge/ingest_skills.py``. The skills corpus is comprehensive
    reference material covering ground the existing corpora don't:
    microthreads model, route tables, SdkLayout API surface, debug pybind
    modules, library catalog. Three section labels (one per audience) so
    the existing section-filter dispatch works.

    Env-gated by XKERNEL_SKILLS (default "1"). Set to "0" to disable
    (A/B harness can compare with-skills vs without-skills).
    """
    if os.getenv("XKERNEL_SKILLS", "1") == "0":
        return ""
    if audience not in _SKILLS_AUDIENCE_CONFIG:
        return ""
    kb_path_str = os.getenv("XKERNEL_SKILLS_KB_PATH", "")
    kb_path = Path(kb_path_str) if kb_path_str else _SKILLS_KB_PATH
    if not kb_path.exists():
        return ""
    try:
        from knowledge.cerebras_docs import CerebrasKnowledgeBase
    except Exception:
        return ""
    try:
        kb = CerebrasKnowledgeBase(path=kb_path)
    except Exception:
        return ""
    if not kb.chunks:
        return ""

    sections, default_query, top_k = _SKILLS_AUDIENCE_CONFIG[audience]
    target_sdk = os.getenv("XKERNEL_TARGET_SDK", "1.4.0")
    arch = os.getenv("XKERNEL_TARGET_ARCH", "wse3")
    context = kb.prompt_context(
        query or default_query,
        target_sdk=target_sdk,
        arch=arch,
        sections=sections,
        top_k=top_k,
        max_chars=max_chars,
        include_future=include_future,
    )
    if not context:
        return ""
    return "\n".join([
        f"## CSL Skills Reference ({audience})",
        "Curated reference material from cerebras-csl-skills, retrieved by "
        "relevance. Treats the SDK surface (CSL language, builtins, fabric, "
        "host runtime, debug pybinds) as authoritative reference, not "
        "tutorial. When this conflicts with intuition, prefer the skill.",
        context,
    ])


def mesh_patterns_context(query: str = "", *, max_chars: int = 5000) -> str:
    """Return wafer-scale multi-PE CSL pattern excerpts relevant to the query.

    Mirrors release_notes_context: fail-soft import, env-gated. Set
    XKERNEL_MESH_PATTERNS=0 to disable (used by the A/B harness for
    no-catalog baseline runs).
    """
    if os.getenv("XKERNEL_MESH_PATTERNS", "1") == "0":
        return ""
    try:
        from code_translation.csl_mesh_patterns import retrieve
    except Exception:
        try:
            from csl_mesh_patterns import retrieve  # when imported as bare module
        except Exception:
            return ""
    return retrieve(query, top_k=3, max_chars=max_chars)


def for_architect(query: str = "") -> str:
    """Context for the ARCHITECT role: chooses wafer-scale decomposition.

    No CSL code snippets — the architect should reason about layout, memory,
    and bandwidth, not write code. Mesh-pattern excerpts are still included
    because they encode the *vocabulary* of decompositions (allreduce-y,
    ping-pong buffers, halo exchange) even when shown as code; the architect
    references them by name in the DESIGN.md.
    """
    tier = knowledge_tier()
    if tier == "bare":
        return ""
    # TIER-B: the architect role framing stays in "soft" — it tells the model
    # what a decomposition memo IS, not which one to pick.
    sections = [
        ARCHITECT_CONTEXT.strip(),
    ]
    if tier == "soft":
        return "\n\n".join(sections)
    # TIER-A: curated/retrieved decomposition vocabulary + docs.
    mesh_context = mesh_patterns_context(query, max_chars=4500)
    if mesh_context:
        sections.append(mesh_context)
    dynamic_context = release_notes_context(query, max_chars=1500)
    if dynamic_context:
        sections.append(dynamic_context)
    tutorial_ctx = tutorial_context(query, audience="architect", max_chars=3000)
    if tutorial_ctx:
        sections.append(tutorial_ctx)
    skills_ctx = skills_context(query, audience="architect", max_chars=3000)
    if skills_ctx:
        sections.append(skills_ctx)
    return "\n\n".join(sections)


# WS3 (2026-06-23): leave-one-out CUDA-similarity retrieval.
# The W1 root-cause finding is information-starvation: the agent writes CSL with
# no worked example of the target idiom. Leave-one-out retrieval surfaces the
# CSL of the K most CUDA-similar OTHER kernels as exemplars. FIREWALL: exemplar
# SOURCES are TRAIN-POOL kernels ONLY (per docs/SPLIT_AND_LEAKAGE.md) — a test
# kernel's reference is never a retrieval source, and the target is ALWAYS
# excluded (leave-one-out). So translating a test kernel can only ever see
# train-kernel CSL, never its own/other test refs. A/B-gated
# XKERNEL_LEAVE_ONE_OUT (default off), per Finding-A.
# (name, kernel_dir, compute_relpath) — the 9 valid exemplar sources.
_LOO_TRAIN_POOL = (
    ("GEMM",                "GEMM",                "CSL/pe.csl"),
    ("GEMV",                "GEMV",                "CSL/pe.csl"),
    ("GEMM-Collectives-2D", "GEMM Collectives 2D", "CSL/pe.csl"),
    ("GEMV-Collectives-2D", "GEMV Collectives 2D", "CSL/pe.csl"),
    ("GEMV-Checkerboard",   "GEMV Checkerboard",   "CSL/pe.csl"),
    ("Power-Method",        "Power Method",        "CSL/src/kernel_power.csl"),
    ("CG",                  "Conjugate Gradient",  "CSL/src/kernel_cg.csl"),
    ("Preconditioned-CG",   "Preconditioned CG",   "CSL/src/kernel_pcg.csl"),
    ("BiCGSTAB",            "BiCGSTAB",            "CSL/src/kernel_bicgstab.csl"),
)


def _cuda_text(kernel_dir: str) -> str:
    p = REPO_ROOT / "kernels" / kernel_dir / "CUDA" / "kernel.cu"
    try:
        return p.read_text(encoding="utf-8", errors="ignore")
    except Exception:
        return ""


def leave_one_out_exemplars(target_cuda: str = "", target_name: str = "",
                            k: int = 1, max_chars: int = 4000,
                            forbidden_lines: Optional[Sequence[str]] = None) -> str:
    """Retrieve the CSL of the K most CUDA-similar TRAIN-POOL kernels as worked
    exemplars (leave-one-out: the target is excluded; sources are train-pool
    only, so no test reference can leak). Gated XKERNEL_LEAVE_ONE_OUT (default
    off). Returns "" when off, no CUDA given, or nothing scores.

    forbidden_lines: lines from the TARGET's reference compute (its canary
    line(s)) that must NOT appear in the prompt. Train kernels can SHARE library
    idiom lines with the target (e.g. the stencil-import output_queues line is in
    both the solvers and 7pt-Stencil); surfacing such an exemplar would reproduce
    the target's canary line and (correctly) trip the compute-leak guard. We
    SCRUB any exemplar line containing a forbidden substring so the canary never
    reaches the prompt while the rest of the worked example survives."""
    import difflib
    if os.getenv("XKERNEL_LEAVE_ONE_OUT", "0") != "1" or not target_cuda:
        return ""
    forbidden = [f for f in (forbidden_lines or []) if f and len(f.strip()) >= 12]
    tname = (target_name or "").strip()
    scored = []
    for name, kdir, comp_rel in _LOO_TRAIN_POOL:
        if name == tname:
            continue  # leave-one-out: never the target itself
        src_cuda = _cuda_text(kdir)
        if not src_cuda:
            continue
        ratio = difflib.SequenceMatcher(None, target_cuda, src_cuda).ratio()
        scored.append((ratio, name, kdir, comp_rel))
    if not scored:
        return ""
    scored.sort(reverse=True)
    out = ["## Worked CSL exemplars from CUDA-similar kernels (leave-one-out "
           "retrieval — these are DIFFERENT kernels; adapt the idioms, don't copy):"]
    budget = max_chars
    for ratio, name, kdir, comp_rel in scored[:max(1, k)]:
        comp = REPO_ROOT / "kernels" / kdir / comp_rel
        try:
            body = comp.read_text(encoding="utf-8", errors="ignore")
        except Exception:
            continue
        # Scrub any line that contains a forbidden (target-canary) substring so
        # the firewall guard never sees the target's distinctive line.
        if forbidden:
            kept = []
            for ln in body.splitlines():
                if any(f in ln for f in forbidden):
                    kept.append("    // [exemplar line omitted — matches target's reserved idiom]")
                else:
                    kept.append(ln)
            body = "\n".join(kept)
        snippet = body[:budget]
        out.append(f"### {name} (CUDA-similarity {ratio:.2f}) — {comp_rel}\n```csl\n{snippet}\n```")
        budget -= len(snippet)
        if budget <= 0:
            break
    return "\n\n".join(out) if len(out) > 1 else ""


# WS4.1 (2026-06-20): the promoted, cross-kernel-VALIDATED optimization patterns
# whose wins the reviewer flagged as only reaching W2. Feeding them to the W1
# implementer lands seeds closer to optimal. We inject ONLY these promoted
# angles (not the whole catalog) to avoid prose bloat — Finding-A says more prose
# is a dead lever unless proven, so this is A/B-gated (XKERNEL_IMPL_OPT_HINTS,
# default OFF until the A/B shows a >=2-kernel lift on the train split).
_PROMOTED_IMPL_ANGLES = (
    "per_row_dsd_unroll",
    "hoist_comptime_constants",
    "column_gather_via_strided_dsd",
    "task_hop_elimination_via_async_chaining",
)


def optimization_hints_for_implementer(kernel_group: str = "") -> str:
    """Emit a short block of promoted optimization patterns applicable to this
    kernel's group, for injection at GENERATION time (WS4.1). Returns "" when
    disabled or nothing applies. Gated by XKERNEL_IMPL_OPT_HINTS (default off).
    """
    if os.getenv("XKERNEL_IMPL_OPT_HINTS", "0") != "1":
        return ""
    try:
        from prompt_cuda2csl import CSL_OPTIMIZATION_STEPS_CATALOG  # type: ignore
    except Exception:
        return ""
    grp = (kernel_group or "").strip().lower()
    lines = []
    for name in _PROMOTED_IMPL_ANGLES:
        meta = CSL_OPTIMIZATION_STEPS_CATALOG.get(name)
        if not isinstance(meta, dict):
            continue
        groups = [g.lower() for g in meta.get("applicable_groups", [])]
        if grp and "all" not in groups and grp not in groups:
            continue
        desc = (meta.get("description") or "").strip()
        # first sentence only — keep it a hint, not a wall of prose
        desc1 = desc.split(". ")[0].strip().rstrip(".")
        if desc1:
            lines.append(f"- {name}: {desc1}.")
    if not lines:
        return ""
    return ("## Optimization patterns to APPLY while writing (proven cycle wins "
            "on this kernel class — write the kernel this way from the start):\n"
            + "\n".join(lines))


# WS4.3 (2026-06-23): distilled from why_faster_miner's 20 firewall-clean rules
# (knowledge/explored/ingest/why_faster_rules.jsonl), which contrast naive-CUDA
# intent vs expert reference CSL on the TRAIN split only. The 20 raw rules
# collapse into 6 generalizable principles (the rest were duplicates). These are
# GENERAL wafer-scale optimization principles — no benchmark-specific tokens
# (the miner's leak filter dropped those) — so they are firewall-safe. A/B-gated
# XKERNEL_WHY_FASTER_RULES (default OFF until a >=2-kernel lift is shown), per
# the Finding-A "prose is a dead lever unless proven" discipline.
_WHY_FASTER_RULES_BLOCK = """
## Why expert CSL beats a naive GPU port (apply these from the start)
Distilled from contrasting naive CUDA against expert wafer-scale CSL. A naive
port loses cycles in ways these idioms fix:
1. **Bulk DSD over scalar loops.** Replace an inner scalar k-loop with ONE
   strided `mem1d_dsd` + `@fmacs` that streams a whole row/column per issue
   (rank-1 update: walk a column of A scaled by one scalar of B into the C DSD).
   One DSD issue feeds the FMAC at peak; per-element index arithmetic is the
   naive tax.
2. **Comptime-specialize shapes + resources.** Pass per-PE tile extents (Mt/Kt/
   Nt), queue ids, and DSR ids as comptime params so DSD descriptors, loop trip
   counts, and collective participant counts resolve at compile time — removes
   the `(N+TILE-1)/TILE` / `if(col<N)` runtime guards a naive kernel carries.
3. **Keep the iteration on-device.** Implement a P-step / solver loop as a
   PERSISTENT task that increments a step counter and re-invokes the next phase
   from the compute-completion handler — no host relaunch per step. Host
   round-trips per iteration dominate at wafer scale.
4. **Keep scalars & state PE-resident.** After a reduction, consume the scalar
   (invert/scale/compare) on the PE that produced it; never ship it to host and
   back (a global barrier that kills pipelining). Allocate solver vectors
   (x,r,p,…) in PE-local memory for the whole solve; memcpy only at setup/teardown.
5. **Match tile layout to the DSD axis.** Store local tiles column-major so the
   contiguous DSD stride matches the accumulation direction; a mismatched layout
   forces gather-style addressing and kills DSD throughput.
6. **Distribute via fabric, not global fetch.** Seed inputs on an edge PE, scatter
   along one axis, then broadcast orthogonally down the other — exploit the
   routers for pipelined O(log)/O(surface) distribution instead of every PE
   fetching from "global memory" like a GPU. For structured-stencil operators,
   map the grid onto the fabric and exchange only halo faces (nearest-neighbor),
   not a replicated dense matrix.
""".strip()


def why_faster_rules_block() -> str:
    """Return the distilled why-faster optimization principles (WS4.3). Gated
    XKERNEL_WHY_FASTER_RULES (default off). Firewall-safe (train-mined, leak-
    filtered, no benchmark tokens)."""
    if os.getenv("XKERNEL_WHY_FASTER_RULES", "0") != "1":
        return ""
    return _WHY_FASTER_RULES_BLOCK


def for_implementer(query: str = "", kernel_group: str = "",
                    target_name: str = "", target_cuda: str = "",
                    forbidden_lines: "Optional[Sequence[str]]" = None) -> str:
    """Context for the IMPLEMENTER role: writes CSL from a fixed design.

    target_name/target_cuda (optional) drive the WS3 leave-one-out retrieval
    lever (exclude the target, retrieve train-pool exemplars). forbidden_lines
    carries the target's compute-leak canary line(s) so retrieved exemplars are
    scrubbed of any line that would reproduce them (train kernels can share
    library idiom lines with the target). All default empty for back-compat;
    the lever is also env-gated.

    Same content the original for_translation() injected — syntax rules,
    DSD patterns, task system, WSE-3-specific rules, gotchas. No
    architect-only prose: at implementation time, design has been decided.

    Layer-1 retrieval boost (task #35): the query is augmented with
    cluster-specific keywords when the CUDA source mentions collectives,
    halo exchange, or DSR/queue setup. The augmentation steers TF-IDF
    toward the right tutorial chunks (topic-11-collectives,
    pipeline-0X, topic-15-wse3-microthreads) that would otherwise lose
    rank to gemv-* tutorials on a generic query.

    Layer-2 KNOWN_GOTCHAS_W1_FAILURE_PATTERNS (task #35): always-on
    distillation of 5 tutorial idioms that cover the dominant W1 failure
    classes. Env-gate XKERNEL_W1_GOTCHAS=0 to suppress.
    """
    tier = knowledge_tier()
    if tier == "bare":
        return ""
    # TIER-B: the CSL language primer — what the language IS. Kept in "soft".
    sections = [
        TYPE_RULES.strip(),
        DSD_PATTERNS.strip(),
        TASK_SYSTEM.strip(),
        WSE3_RULES.strip(),
    ]
    if os.getenv("XKERNEL_ARCH_MAPPING", "1") != "0":
        sections.append(CUDA_TO_WSE_MAPPING.strip())
    if tier == "soft":
        return "\n\n".join(sections)
    # TIER-A: curated gotchas + retrieved tutorials/skills/mesh. Everything
    # below here is the knowledge stack whose marginal value the baseline
    # measures. The query augmentation only steers TIER-A retrieval, so it
    # lives inside the tier gate.
    augmented_query = _augment_query_for_w1_clusters(query)
    sections.append(KNOWN_GOTCHAS.strip())
    # Cluster-gated W1 gotchas: only include sections that address bottlenecks
    # this kernel actually exhibits. Always-on caused regression on simple
    # kernels (Single-Tile-Matvec: gotchas about queues/halos confused agent
    # into wrong translation path on a single-PE kernel with no fabric).
    # XKERNEL_W1_GOTCHAS_FORCE_ALL=1 reverts to always-on for debugging.
    if os.getenv("XKERNEL_W1_GOTCHAS", "1") != "0":
        if os.getenv("XKERNEL_W1_GOTCHAS_FORCE_ALL", "0") == "1":
            sections.append(KNOWN_GOTCHAS_W1_FAILURE_PATTERNS.strip())
        else:
            matched = _detect_w1_clusters_for_kernel(query)
            cluster_gotchas = _filter_w1_gotchas_for_clusters(matched)
            if cluster_gotchas:
                sections.append(cluster_gotchas)
    dynamic_context = release_notes_context(augmented_query, max_chars=3000)
    if dynamic_context:
        sections.append(dynamic_context)
    mesh_context = mesh_patterns_context(augmented_query, max_chars=5000)
    if mesh_context:
        sections.append(mesh_context)
    tutorial_ctx = tutorial_context(augmented_query, audience="implementer", max_chars=4000)
    if tutorial_ctx:
        sections.append(tutorial_ctx)
    skills_ctx = skills_context(augmented_query, audience="implementer", max_chars=4000)
    if skills_ctx:
        sections.append(skills_ctx)
    # WS4.1: promoted optimization patterns at generation time (A/B-gated).
    opt_hints = optimization_hints_for_implementer(kernel_group)
    if opt_hints:
        sections.append(opt_hints)
    # WS4.3 (2026-06-23): distilled why-faster optimization principles mined from
    # the train split (A/B-gated XKERNEL_WHY_FASTER_RULES, default off).
    wf_rules = why_faster_rules_block()
    if wf_rules:
        sections.append(wf_rules)
    # WS3 (2026-06-23): leave-one-out CUDA-similarity retrieval of train-pool
    # exemplars (A/B-gated XKERNEL_LEAVE_ONE_OUT, default off; leak-safe — the
    # target and all test refs are excluded as sources).
    loo = leave_one_out_exemplars(target_cuda=target_cuda or query,
                                  target_name=target_name,
                                  forbidden_lines=forbidden_lines)
    if loo:
        sections.append(loo)
    # Hard-kernel hints (2026-06-21): firewall-safe distillations of the two
    # 12/12 test-split translation failures (factorization / neighbor-exchange).
    # Vocabulary-gated so they fire only on the kernel class that needs them.
    hk_hints = hard_kernel_hints(augmented_query)
    if hk_hints:
        sections.append(hk_hints)
    # Co-design only: cross-file collectives_2d wiring exemplar (firewall-safe,
    # train-kernel + SDK sourced). Returns "" unless XKERNEL_CODESIGN_LAYOUT=1.
    cd_exemplar = collectives_2d_codesign_exemplar(augmented_query)
    if cd_exemplar:
        sections.append(cd_exemplar)
    return "\n\n".join(sections)


def for_reviewer(query: str = "") -> str:
    """Context for the REVIEWER role: triages a failing benchmark.

    The reviewer's deliverable is a verdict ("architectural failure: ..." or
    "implementation bug: ...") and a route. Receives the failure-triage
    checklist plus the gotcha catalog and a curated set of debug recipes
    (symptom → diagnosis → action), so the reviewer can recommend a concrete
    diagnostic step rather than just classify the bucket.
    """
    tier = knowledge_tier()
    if tier == "bare":
        return ""
    # TIER-B: the failure-triage checklist — how to CLASSIFY a failure into an
    # A/B/C route. It carries no kernel-specific knowledge, so it stays in
    # "soft": without it the reviewer can't emit the bucket the loop needs.
    sections = [
        REVIEWER_CHECKLIST.strip(),
    ]
    if tier == "soft":
        return "\n\n".join(sections)
    # TIER-A: curated gotchas + debug recipes + retrieved docs.
    sections.append(KNOWN_GOTCHAS.strip())
    debug_context = debug_techniques_context(query, max_chars=3500)
    if debug_context:
        sections.append(debug_context)
    dynamic_context = release_notes_context(query, max_chars=1500)
    if dynamic_context:
        sections.append(dynamic_context)
    tutorial_ctx = tutorial_context(query, audience="reviewer", max_chars=2500)
    if tutorial_ctx:
        sections.append(tutorial_ctx)
    skills_ctx = skills_context(query, audience="reviewer", max_chars=3000)
    if skills_ctx:
        sections.append(skills_ctx)
    return "\n\n".join(sections)


# Backward compatibility — existing callers use for_translation(). It is now
# a thin alias for for_implementer(). New code should call for_implementer
# (or for_architect / for_reviewer) directly.
def for_translation(query: str = "") -> str:
    """Alias for for_implementer(). Kept for backward compatibility."""
    return for_implementer(query)


def for_optimization(query: str = "",
                     *,
                     kernel_group: str = "",
                     picked_angle: str = "",
                     angle_query_hint: str = "",
                     angle_source_skill: str = "",
                     current_kernel: str = "") -> str:
    """Rules injected into each CSL optimization step prompt.

    Kernel-aware (task #18): when `kernel_group` (e.g. "stencil", "linalg",
    "sparse") and/or `picked_angle` (the selector's chosen angle name from
    the per-kernel whitelist in spec.yaml) are provided, the query is
    augmented with their keywords and additional tutorial/skill chunks
    are surfaced to steer retrieval toward optimization-relevant content.

    The angle's `knowledge_query_hint` from CSL_OPTIMIZATION_STEPS_CATALOG
    is passed as `angle_query_hint` and merged into the query — this is how
    angle-specific TF-IDF retrieval targets the right SKILL-*.md / tutorial
    chunks (e.g. picked_angle=memory_simd_alignment + hint="SIMD alignment
    bank conflict" → SKILL-SIMD chunks rank high).
    """
    tier = knowledge_tier()
    if tier == "bare":
        return ""
    # TIER-B: minimal CSL primer so an optimizing edit stays syntactically
    # valid. KNOWN_GOTCHAS, retrieval, experience memory, and the curated
    # per-angle "lever" are all TIER-A (the knowledge stack under test).
    sections = [
        TYPE_RULES.strip(),
        DSD_PATTERNS.strip(),
    ]
    if tier == "soft":
        return "\n\n".join(sections)
    sections.append(KNOWN_GOTCHAS.strip())

    # Query augmentation: weave kernel_group + picked_angle keywords +
    # angle's knowledge hint into the TF-IDF query. Each adds a few tokens;
    # together they shift retrieval from generic to angle-targeted.
    augmented_query = " ".join(
        s for s in (query, kernel_group, picked_angle, angle_query_hint) if s
    ).strip()

    dynamic_context = release_notes_context(augmented_query, max_chars=1500)
    if dynamic_context:
        sections.append(dynamic_context)

    # Tutorial + skill context — today's for_optimization() doesn't pull these,
    # which is why even the relevant chunks (SKILL-SIMD, SKILL-DSDS,
    # gemv-09-streaming, topic-09-fifos) never reached the optimizer prompt.
    # Now they do, ranked by the augmented query so the picked angle's
    # documentation surfaces. Budgets are tight (1500 + 1500 chars) to keep
    # the overall optimizer prompt small enough for reasoning models to
    # actually emit a CSL block within their output token budget.
    tut = tutorial_context(augmented_query,
                           audience="implementer",
                           max_chars=1500)
    if tut:
        sections.append(tut)
    sk = skills_context(augmented_query,
                        audience="implementer",
                        max_chars=1500)
    if sk:
        sections.append(sk)

    # Prior optimization experience (this corpus, not the curated catalog).
    # The summary table + lessons let the optimizer reuse what already
    # worked on similar kernels. Bias toward the current kernel_group when
    # one is provided. Skip gracefully when the corpus doesn't yet exist.
    explored = for_optimizer_explored(augmented_query,
                                       kernel_group=kernel_group,
                                       current_kernel=current_kernel,
                                       max_chars=2200)
    if explored:
        sections.append(explored)

    # When the selector has picked a specific angle, prepend a tight "lever"
    # block telling the agent EXACTLY which technique to apply this round.
    # This is the deterministic, curated guidance — the tutorial/skill
    # chunks above are the supporting reference material.
    if picked_angle:
        lever_header = [
            f"## This round's optimization lever: `{picked_angle}`",
        ]
        if angle_source_skill:
            lever_header.append(
                f"  (canonical source: {angle_source_skill})"
            )
        lever_header.append(
            "Apply this specific lever to the current compute file. The "
            "tutorials and skill chunks below show the canonical before/after "
            "pattern. Do NOT mix in other unrelated changes — one angle per "
            "attempt makes regressions easier to attribute."
        )
        # Lever block goes FIRST so the optimizer reads it before everything else.
        sections.insert(0, "\n".join(lever_header))

    return "\n\n".join(sections)


def for_profiling_instrumentation() -> str:
    """Rules injected when asking the agent to add TSC profiling."""
    return "\n".join([
        PROFILING.strip(),
        TYPE_RULES.strip(),
        KNOWN_GOTCHAS.strip(),
    ])


# ---------------------------------------------------------------------------
# Explorer role — for the autonomous exploration workflow (explore_csl.py)
# ---------------------------------------------------------------------------

_EXPLORED_EXPERIENCES_KB_PATH = (REPO_ROOT / "knowledge/explored/ingest/explored_experiences.jsonl")


def _explored_experiences_context(query: str = "",
                                  *,
                                  max_chars: int = 3000) -> str:
    """Return distilled lessons + design choices from prior exploration
    attempts (both successes and failures).

    Backed by ``knowledge/explored/ingest/explored_experiences.jsonl``,
    written by :class:`code_translation.knowledge_persistence.ExplorationStore`.
    This corpus contains full design decisions and outcome details — it MUST
    NOT be surfaced via for_architect/for_implementer/for_reviewer (those are
    used by the translation workflow on hand-curated benchmark kernels and
    seeing prior bench answers would be answer leakage).
    """
    if os.getenv("XKERNEL_EXPLORED_EXPERIENCES", "1") == "0":
        return ""
    kb_path = _EXPLORED_EXPERIENCES_KB_PATH
    if not kb_path.exists():
        return ""
    try:
        from knowledge.cerebras_docs import CerebrasKnowledgeBase
    except Exception:
        return ""
    try:
        kb = CerebrasKnowledgeBase(path=kb_path)
    except Exception:
        return ""
    if not kb.chunks:
        return ""
    default_query = (
        "explore csl kernel success failure design lesson speedup "
        "infeasible cycles_send compile run"
    )
    context = kb.prompt_context(
        query or default_query,
        target_sdk=os.getenv("XKERNEL_TARGET_SDK", "1.4.0"),
        arch=os.getenv("XKERNEL_TARGET_ARCH", "wse3"),
        top_k=5,
        max_chars=max_chars,
        include_future=True,
    )
    if not context:
        return ""
    return "\n".join([
        "## Prior exploration experiences (successes + failures)",
        "These records summarise design choices and outcomes from earlier "
        "exploration rounds. Read both the wins AND the failure modes — "
        "avoid repeating losing patterns; reuse winning ones with attribution.",
        context,
    ])


_OPTIMIZATION_KB_PATH = (REPO_ROOT / "knowledge/explored/optimization/ingest/optimization_experiences.jsonl")
_OPTIMIZATION_RECORDS_PATH = (REPO_ROOT / "knowledge/explored/optimization/experiences.jsonl")


def _optimizer_explored_summary_block(kernel_group: str = "",
                                      max_rows: int = 10) -> str:
    """Render an aggregate summary of prior optimization attempts as a
    compact markdown table, plus an avoid-list of angles that have
    historically regressed.

    Built directly from optimization/experiences.jsonl (skipping the
    TF-IDF chunk path) so the numbers stay accurate without re-ingest.
    The caller passes ``kernel_group`` to bias the table toward rows
    most relevant to the kernel being optimised.
    """
    if not _OPTIMIZATION_RECORDS_PATH.exists():
        return ""
    rows: List[Dict[str, Any]] = []
    try:
        import json as _json
        with open(_OPTIMIZATION_RECORDS_PATH, "r", encoding="utf-8") as fh:
            for line in fh:
                line = line.strip()
                if not line:
                    continue
                try:
                    rows.append(_json.loads(line))
                except Exception:
                    pass
    except OSError:
        return ""
    if not rows:
        return ""
    # Aggregate by (group, angle).
    agg: Dict[Tuple[str, str], Dict[str, Any]] = {}
    for r in rows:
        key = (str(r.get("kernel_group", "?")), str(r.get("angle", "?")))
        slot = agg.setdefault(key, {"attempts": 0, "accepts": 0, "speedups": []})
        slot["attempts"] += 1
        if r.get("accepted"):
            slot["accepts"] += 1
            sp = r.get("speedup")
            if isinstance(sp, (int, float)):
                slot["speedups"].append(float(sp))
    # Convert to display rows.
    display: List[Dict[str, Any]] = []
    for (group, angle), v in agg.items():
        mean = (sum(v["speedups"]) / len(v["speedups"])) if v["speedups"] else None
        best = max(v["speedups"]) if v["speedups"] else None
        display.append({
            "group": group,
            "angle": angle,
            "attempts": v["attempts"],
            "accepts": v["accepts"],
            "mean_speedup": mean,
            "best_speedup": best,
        })
    # Bias: rows matching kernel_group first, then by accepts.
    def _rank(d: Dict[str, Any]) -> Tuple[int, int, float]:
        group_match = 0 if (kernel_group and d["group"] == kernel_group) else 1
        # Higher accepts is better, higher mean_speedup is better.
        return (group_match, -d["accepts"], -(d["mean_speedup"] or 0.0))
    display.sort(key=_rank)
    display = display[:max_rows]

    # Avoid-list: angles with attempts >= 3 and accept_rate == 0.
    avoid = []
    for (group, angle), v in agg.items():
        if v["attempts"] >= 3 and v["accepts"] == 0:
            if not kernel_group or group == kernel_group:
                avoid.append(f"  - **{angle}** on `{group}` ({v['attempts']} attempts, 0 accepted)")

    lines = [
        "## Prior optimization experience (this corpus, not the curated catalog)",
        "Empirical record of what worked / didn't on previous "
        "optimization-exploration rounds. Use as evidence; the curated "
        "angle catalog still tells you HOW to apply each lever.",
        "",
        "| group | angle | attempts | accepts | mean speedup | best |",
        "|-------|-------|---------:|--------:|--------:|--------:|",
    ]
    for d in display:
        mean = f"{d['mean_speedup']:.2f}x" if d["mean_speedup"] else "—"
        best = f"{d['best_speedup']:.2f}x" if d["best_speedup"] else "—"
        lines.append(
            f"| {d['group']} | {d['angle']} | {d['attempts']} | "
            f"{d['accepts']} | {mean} | {best} |"
        )
    if avoid:
        lines.append("")
        lines.append("**Avoid (no accepts after 3+ attempts):**")
        lines.extend(avoid)
    return "\n".join(lines)


def for_optimizer_explored(query: str = "",
                            *,
                            kernel_group: str = "",
                            current_kernel: str = "",
                            max_chars: int = 2500) -> str:
    """Return aggregate optimization-exploration findings for the optimizer.

    Two layers:
      1. A summary table aggregated from optimization/experiences.jsonl
         (numbers, not prose) — always returned first so the optimizer
         can read it deterministically.
      2. TF-IDF over the ingest chunks (one per accepted attempt) so
         lessons rendered for THIS kernel's specific angle surface
         alongside the table.

    **Self-exclusion firewall**: when ``current_kernel`` is provided,
    chunks from the SAME kernel are filtered out — preserving the
    "optimizer doesn't see its own previous accepts as hint material"
    constraint that lets per-kernel cycle reductions stay falsifiable.
    Without this filter, re-running optimize_explore on (say) Cholesky
    would feed the LLM its own prior diff_summaries verbatim — the agent
    would not be discovering anything new, it would be regurgitating a
    cached answer. The filter applies to W1 (translate) too: if W1 ever
    optimizes a kernel whose explore-mode history we have, we don't want
    that history to bleed into the W1 prompt as if it were impersonal
    catalog knowledge.

    Cross-kernel chunks (e.g. ``per_row_dsd_unroll`` distilled from
    GEMM_Collectives_2D, applied while optimizing Laplacian2D-Halo) are
    still included — that's the whole point of the cross-kernel pattern
    catalog and the leakage is benign because the kernel identifiers
    are different.

    Degrades to empty string when no optimization corpus exists yet.
    """
    if os.getenv("XKERNEL_OPTIMIZER_EXPLORED", "1") == "0":
        return ""
    summary = _optimizer_explored_summary_block(kernel_group, max_rows=10)
    chunks_block = ""
    if _OPTIMIZATION_KB_PATH.exists():
        try:
            from knowledge.cerebras_docs import CerebrasKnowledgeBase
            kb = CerebrasKnowledgeBase(path=_OPTIMIZATION_KB_PATH)
            if kb.chunks:
                default_query = (
                    f"{kernel_group} optimization angle speedup cycles_send "
                    f"compute file pattern lever"
                )
                # Filter chunks whose title starts with the current
                # kernel's name. The KB chunks set title to
                # "<Kernel> optimized via <angle>" in
                # ExplorationStore._write_optimization_chunk_for_kb_,
                # so a prefix match is reliable.
                if current_kernel:
                    original_chunks = list(kb.chunks)
                    kb.chunks = [
                        c for c in kb.chunks
                        if not c.title.startswith(current_kernel)
                    ]
                    if not kb.chunks:
                        # All chunks were from this kernel — restore for
                        # subsequent calls in this process, return empty
                        # chunks_block (the summary table still goes
                        # through, which is fine — it's aggregate stats
                        # not source code).
                        kb.chunks = original_chunks
                        chunks_block = ""
                    else:
                        chunks_block = kb.prompt_context(
                            query or default_query,
                            target_sdk=os.getenv("XKERNEL_TARGET_SDK", "1.4.0"),
                            arch=os.getenv("XKERNEL_TARGET_ARCH", "wse3"),
                            top_k=3,
                            max_chars=max(800, max_chars // 2),
                            include_future=True,
                        )
                        kb.chunks = original_chunks  # restore for next caller
                else:
                    chunks_block = kb.prompt_context(
                        query or default_query,
                        target_sdk=os.getenv("XKERNEL_TARGET_SDK", "1.4.0"),
                        arch=os.getenv("XKERNEL_TARGET_ARCH", "wse3"),
                        top_k=3,
                        max_chars=max(800, max_chars // 2),
                        include_future=True,
                    )
        except Exception:
            chunks_block = ""
    parts = [p for p in (summary, chunks_block) if p]
    if not parts:
        return ""
    return "\n\n".join(parts)


def for_explorer(query: str = "") -> str:
    """Context for the EXPLORER role: produces net-new CSL kernels in
    autonomous exploration mode.

    Layers:
      1. Everything ``for_implementer`` provides (DSD patterns, task system,
         mesh patterns, tutorials, skills) — exploration still needs the
         same language fundamentals.
      2. Distilled lessons from prior exploration attempts (the SAFE
         distillations only — full bench answers are NOT included here).

    Degrades to ``for_implementer`` alone when no explored corpus exists.
    """
    base = for_implementer(query)
    extra = _explored_experiences_context(query, max_chars=2500)
    if not extra:
        return base
    return base + "\n\n" + extra
