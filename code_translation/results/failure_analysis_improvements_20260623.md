# Full-suite failure analysis + firewall-safe improvement plan (2026-06-23)

Source: 29-agent workflow over the 13 full-suite failure traces (+ Cholesky false-pass).
Per-kernel root causes, clustered, fixes designed + adversarially leak-audited.

## Clusters (ranked by leverage = #kernels x firewall-safe)
- **get_x_coord/get_y_coord at module-scope comptime** — hits 6, cat=csl-idiom, firewall_safe=True, leverage=high
- **Stale-layout / wrong-build-path export-contract mismatch** — hits 5, cat=contract-export-mismatch, firewall_safe=True, leverage=high
- **WSE-3 queue-init / async-fabric idioms** — hits 5, cat=csl-idiom, firewall_safe=True, leverage=high
- **collectives_2d SDK API arity/hallucination** — hits 4, cat=sdk-api-knowledge, firewall_safe=True, leverage=high
- **Benchmark-libs wrapper param/arity gaps** — hits 3, cat=library-wrapper-nontask, firewall_safe=True, leverage=medium
- **Reviewer misdiagnosis / repair-loop thrash** — hits 5, cat=correctness-check-too-loose, firewall_safe=False, leverage=medium
- **Resource-id collision (queue/ut_id/color reuse)** — hits 2, cat=resource-allocation, firewall_safe=True, leverage=medium
- **Collective-participation / decomposition contract (hidden reference)** — hits 5, cat=collective-participation, firewall_safe=False, leverage=low
- **Numeric / algorithm-decomposition near-miss** — hits 4, cat=numeric-algorithm, firewall_safe=False, leverage=low
- **Skeleton/immune kernel — unreachable success marker (VERIFY=False)** — hits 3, cat=skeleton-incomplete, firewall_safe=False, leverage=low

## Vetted firewall-safe fixes
### get_x_coord/get_y_coord at module-scope comptime (Cluster 2, csl-idiom, 6 kernels)  [translation-prompt]  (helps ~6; audit=safe)
- mechanism: Two-part fix. (1) PRIMARY (translation-prompt): the always-on _BUILTIN_WHITELIST_BLOCK in prompt_cuda2csl.py was teaching the bug — it labeled `const px: u16 = layout_mod.get_x_coord();` at module scope as the RIGHT idiom ("// const, top-level") and suggested the use-site-cast form too. The compiler rejects both: get_x_coord()->layout.csl get_fabric_coord->tile_config @get_config, which errors "comptime evaluation only valid while evaluating a top level comptime block" (a module-scope const initializer is comptime-evaluated but NOT inside that top-level block). Rewrote the block so the RIGHT form is runtime-only (call inside fn/task bodies, e.g. helper fns is_left_col/is_top_row), the top-level const + use-site-cast + comptime-block forms are all flagged WRONG with the exact error string, and the comptime-need case routes to a `param` plumbed from the GIVEN layout.csl via @set_tile_code. (2) SECONDARY (KB gotcha gating): the correct runtime-only gotcha already existed in csl_knowledge_base.py (section "Per-PE role at runtime: use layout_mod.get_x_coord()/get_y_coord() inside fn/task bodies") but _GOTCHA_SECTIONS_BY_CLUSTER wired it ONLY to the halo_recv_unblock cluster, so the 4 collectives/matvec kernels (which match collectives_2d / dsr_queue_fabric_init markers, not halo) never received it. Added the section title to both those cluster lists.
- concrete: FILE 1: /home/USER/xkernel/code_translation/prompt_cuda2csl.py, _BUILTIN_WHITELIST_BLOCK (lines ~64-93, the always-on "PE COORDINATE IDIOM" block). Replaced the RIGHT example `const px: u16 = layout_mod.get_x_coord(); // const, top-level` with the runtime-only idiom (call get_x_coord/get_y_coord only inside fn/task bodies: `fn is_left_col() bool { return layout_mod.get_x_coord() == 0; }`), and added a WRONG block listing the top-level const, the use-site `const py: i16 = @as(i16, layout_mod.get_y_coord());`, and the comptime{} forms, annotated with the real error: "comptime evaluation of this expression is only valid while evaluating a top level comptime block". Added: if you need the coord at COMPTIME, take it as `param px: i16;`/`param is_first_row: bool;` plumbed from the GIVEN layout.csl, and check layout.csl for existing param names first. FILE 2: /home/USER/xkernel/code_translation/csl_knowledge_base.py, _GOTCHA_SECTIONS_BY_CLUSTER (~line 836). Appended the string "Per-PE role at runtime: use layout_mod.get_x_coord()/get_y_coord() inside fn/task bodies" to the "collectives_2d" list (~line 847) and the "dsr_queue_fabric_init" list (~line 872). Verified: post-fix all of GEMV/GEMV-Collectives-2D/GEMM-Collectives-2D/GEMV-Checkerboard/Residual surface the gotcha; Single-Tile-Matvec still gets empty block (no regression); both files py_compile clean.

### C1: Stale-layout / wrong-build-path export-contract mismatch  [harness]  (helps ~5; audit=safe)
- mechanism: Make `_find_layout_csl()` discover the layout from the ACTIVE build script instead of a hardcoded name-list. Parse the `cslc ...` line of the kernel's `commands_script` (already in scope in `build_reference_contract`, and already shown verbatim to the agent) and extract the first positional `*.csl` argument — that is the file the toolchain actually compiles. Thread `commands_script` into `_find_layout_csl(reference_dir, commands_script)`; the existing hardcoded list (`layout.csl`, `src/layout.csl`, `code.csl`, `layout_matvec.csl`) becomes the fallback only when the cslc line cannot be parsed. This makes the layout the agent is shown (its export_name contract: `f_power(i16,i16)` / `f_cg` / `f_pcg` single on-device driver) match the file the build evaluates, so honoring attempts stop failing with "name X was not declared during layout evaluation." Confirmed ground truth in /tmp/vfy2_Power-Method/K/CSL: commands_wse3.sh runs `cslc ./src/layout_power.csl`, whose `@set_tile_code(px,py,"kernel_power.csl",...)` exports only `f_power`, while the stale src/layout.csl (what the current code returns first) exports `f_spmv`/`f_nrm2_y`/`f_scale_x_by_nrm2` and sets tile-code `kernel.csl`. The registry target_relpath is already correct (`src/kernel_power.csl` etc.), so ONLY the shown-layout is wrong — this single fix resolves the whole cluster. Firewall-safe: cslc invocation is in commands.sh which the agent already reads; @set_tile_code is a public SDK layout idiom; no reference pe.csl/compute is touched (build_reference_contract still returns reference_compute separately for the canary guard only).
- concrete: In /home/USER/xkernel/code_translation/cuda2csl.py replace `_find_layout_csl` (lines 498-508) with a build-script-driven resolver and update its one caller (line 599) to pass commands_script:

```python
import re

def _layout_from_commands(reference_dir: str, commands_script: str) -> Optional[str]:
    """Parse the active build script's cslc line for the layout it compiles.

    commands_<arch>.sh is shown verbatim to the agent, so reading its cslc
    invocation injects nothing the agent can't already see. We return the
    first positional *.csl arg on the cslc line (the layout/top file), which
    is the file the toolchain actually evaluates -- NOT necessarily the file
    named 'layout.csl' (e.g. Power-Method/CG/PCG/BiCGSTAB compile
    layout_power.csl / layout_cg.csl etc., whose only entrypoint is a single
    on-device driver f_power/f_cg/...). Returns a reference_dir-relative path
    or None if no cslc line / arg is found.
    """
    cmd_path = os.path.join(reference_dir, commands_script)
    if not os.path.exists(cmd_path):
        return None
    text = load_text(cmd_path)
    # Join backslash-continued lines so the full cslc invocation is one string.
    text = re.sub(r"\\\s*\n", " ", text)
    for line in text.splitlines():
        stripped = line.strip()
        if stripped.startswith("#") or "cslc" not in stripped:
            continue
        # First whitespace-separated token ending in .csl that is NOT a flag.
        for tok in stripped.split():
            if tok.startswith("-"):
                continue
            if tok.endswith(".csl"):
                rel = tok[2:] if tok.startswith("./") else tok
                if os.path.exists(os.path.join(reference_dir, rel)):
                    return rel
        return None  # cslc line found but no resolvable .csl arg
    return None


def _find_layout_csl(reference_dir: str, commands_script: Optional[str] = None) -> str:
    """Return path to the layout/config CSL file the build actually compiles.

    Prefer the layout named on the active build script's cslc line (the file
    the toolchain evaluates); fall back to the legacy name-list only when the
    build script can't be parsed. Fixes the stale-layout export-contract
    mismatch (Power-Method/CG/PCG/BiCGSTAB): commands_wse3.sh compiles
    layout_<algo>.csl but the legacy list returned the stale layout.csl,
    showing the agent a phantom multi-entrypoint contract.
    """
    if commands_script:
        rel = _layout_from_commands(reference_dir, commands_script)
        if rel:
            return os.path.join(reference_dir, rel)
    for candidate in [
        "layout.csl", "src/layout.csl",
        "code.csl",          # Wide Multiplication, Mandelbrot
        "layout_matvec.csl", # Single Tile Matvec
    ]:
        path = os.path.join(reference_dir, candidate)
        if os.path.exists(path):
            return path
    raise FileNotFoundError(f"No layout file found in {reference_dir}")
```

And at line 599 in build_reference_contract change:
`layout_text = load_text(_find_layout_csl(reference_dir))`
to:
`layout_text = load_text(_find_layout_csl(reference_dir, commands_script))`

(commands_script is already a parameter of build_reference_contract.) Optional belt-and-suspenders: add a one-line guard test in /home/USER/xkernel/code_translation/check_timing_integrity.py or a new assertion in test_no_compute_leak.py asserting that for Power-Method/CG/PCG/BiCGSTAB the resolved layout basename matches the cslc arg, so this regression can't silently return.

### C3: WSE-3 queue-init / async-fabric idioms  [knowledge-base-gotcha]  (helps ~5; audit=safe)
- mechanism: The C3 facts ALREADY exist in csl_knowledge_base.py but are gated unreachable for the affected kernels. Two compounding gaps, both firewall-safe to fix:

GAP 1 (primary — the "strengthen surfacing" the cluster detail asks for): for_implementer()'s retrieval query is target_relpath+cuda_code+cuda_analysis ONLY (cuda2csl.py:1576-1577, repeated at the two repair sites :1783-1784 and the bucket-B retranslate). The dsr_queue_fabric_init cluster markers (@initialize_queue, @get_input_queue, @get_output_queue, @get_ut_id, output_queues, MEMCPYH2D, @set_color_config) are CSL-side tokens that NEVER appear in CUDA source — they live only in the code.csl/layout.csl the agent is already given. So _detect_w1_clusters_for_kernel() returns [] for fabric-agnostic CUDA and _filter_w1_gotchas_for_clusters([]) returns "" — the agent gets ZERO queue/async gotchas. Verified empirically: Wide-Multiplication (a pure scalar schoolbook-multiply .cu) detects [] on the CUDA-only query but ['dsr_queue_fabric_init'] when the GIVEN layout is folded in; Game-of-Life gains dsr_queue_fabric_init on top of halo_recv_unblock. FIX: fold the already-available layout_text into the cluster-detection/retrieval query.

GAP 2 (content routing): the section 'WSE-3 queue / microthread ID pools and the @initialize_queue discipline' (canonical H2D+D2H @initialize_queue block + 'forgetting @initialize_queue for the user color queue on WSE-3 -> wavelets arrive but the fabin_dsd consumer never wakes' = Wide-Mult's dominant D2H-0-bytes blocker) and 'Canonical halo receive: async fabin_dsd + ut_id + activate, posted before sends' are mapped only to halo_recv_unblock, not dsr_queue_fabric_init. Add both titles to the dsr cluster so a fabric kernel that is NOT a halo stencil still gets the output-queue-init + async-receive discipline.

Both are firewall-safe: Part-1 feeds the query a file the agent already sees (the given layout) — type (c) given info; the gotchas surfaced are generic SDK platform facts (reserved id ranges, @initialize_queue-on-WSE-3, .async+ut_id discipline) — type (a)/(b). Neither encodes the hidden pe.csl's algorithm or its specific id choices.
- concrete: EDIT 1 (csl_knowledge_base.py:862-872) — route the two missing WSE-3 queue/async sections into the dsr cluster. Add these two list entries to _GOTCHA_SECTIONS_BY_CLUSTER["dsr_queue_fabric_init"]:
        "WSE-3 queue / microthread ID pools and the @initialize_queue discipline",
        "Canonical halo receive: async fabin_dsd + ut_id + activate, posted before sends",
(Both section bodies already exist verbatim in KNOWN_GOTCHAS_W1_FAILURE_PATTERNS; this only widens which cluster surfaces them.)

EDIT 2 (cuda2csl.py) — fold the GIVEN layout into the implementer KB query at all three call sites. The layout is already on self at translate time. At line 1576-1579 change:
        _kb = csl_knowledge_base.for_implementer(
            "\n".join([target_relpath, cuda_code, self.cuda_analysis or "",
                       getattr(self, "_layout_text_for_translate", "") or ""]),
            kernel_group=self.kernel_group,
        )
Apply the identical fourth join element to the repair-site call at :1783-1786 and the initial _kb at the bucket-B retranslate. (In codesign mode _layout_text_for_translate is "" because the reference layout is withheld — the query gracefully degrades to CUDA-only there, preserving the firewall; co-design kernels get their fabric vocab from the COLLECTIVES_2D_CODESIGN_EXEMPLAR path instead.)

Guard rail (optional, recommended): add to test_no_compute_leak.py an assertion that _augment/_detect run on (cuda+layout) never inject any token from the hidden compute file — i.e. the only new query text is the given layout. This keeps Part-1 honest under future layout edits.

Net effect: Wide-Mult, GEMV-Checkerboard, FFT-1D-2D (fabric kernels with CUDA that lacks fabric vocab) now receive the D2H output-queue @initialize_queue fact + .async/ut_id discipline + memcpy-reserved-id ranges they were silently denied; Game-of-Life and Power-Method's stencil-queue face also pick up the dsr block.

### collectives_2d SDK API arity/hallucination (Cluster 4, sdk-api-knowledge, 4 kernels: GEMV, GEMM-Collectives-2D, GEMV-Collectives-2D, FFT-1D-2D)  [knowledge-base-gotcha]  (helps ~4; audit=safe)
- mechanism: Root cause confirmed by reading ground truth from the container: collectives_2d/params.csl exposes per-dim struct fields .pe_id/.pe_min/.pe_max/.NUM_PES/.DIM_ID (get_params at params.csl:34-55 takes Px,Py + ONE ids struct = 3 args), and pe.csl declares `var pe_id: u16` set inside fn init() from coords[DIM_ID], with the verbatim source comment "pe_id is the result of get_x_coord()/get_y_coord()". The agent never sees these files, so it back-fills its CUDA mental model (threadIdx/blockDim) with INVENTED names: DIM_LENGTH (real: NUM_PES), c2d_params.x.dim_size (real: .NUM_PES), .PE_ID/.pe_id_x/.dim_x/.dim_y (real: .pe_id after init()), layout_mod.get_x_dim()/get_y_dim() (real: @get_rectangle().width/.height — @get_rectangle is a real builtin, csl_builtins.yaml:182). The existing KB ("collectives_2d API surface", csl_knowledge_base.py:445-478) teaches the CORRECT call SIGNATURES (get_params arity, [*]u32 vs [*]f32, dim_params=c2d_params.x) but NEVER answers the two questions the agent is actually asking ("what field holds the per-dim PE count?" and "how do I read my own coordinate / the mesh dims?") and NEVER negates the specific fake names. grep confirms zero occurrences of DIM_LENGTH/dim_size/get_x_dim/pe_id_x/.PE_ID anywhere in the KB. The fix injects the real introspection field names plus an explicit fake→real mapping table, so the hallucination is pre-empted rather than discovered through compiler errors. Surfacing is automatic: the new section is added to the collectives_2d entry in _GOTCHA_SECTIONS_BY_CLUSTER, which already fires for exactly these 4 kernels via _detect_w1_clusters_for_kernel markers (gemv/gemm/mpi_x/broadcast/2D mesh).
- concrete: TWO edits, both in csl_knowledge_base.py.

(1) Add a new `### ` subsection inside the KNOWN_GOTCHAS_W1_FAILURE_PATTERNS string (append it right after the existing "### collectives_2d API surface" section, before line ~480 "### Affine tensor_access"):

### collectives_2d introspection: NUM_PES / pe_id / @get_rectangle — do NOT invent fields
The 2D-collectives params struct and module handle expose a FIXED, SMALL set of
introspection fields. The single biggest sdk-api failure is inventing CUDA-style
names (threadIdx/blockDim analogues) the SDK does not have. Use ONLY these:

  // LAYOUT side — c2d.get_params(Px, Py, ids) returns a struct whose per-axis
  // members .x and .y each carry (verbatim field names from the SDK module):
  //     .pe_id   : this PE's index ALONG that axis (an x-index for .x, y-index for .y)
  //     .NUM_PES : number of PEs along that axis  (this is the per-dim LENGTH)
  //     .pe_min  : bool, true if this PE is index 0 on the axis
  //     .pe_max  : bool, true if this PE is the last index on the axis
  //     .DIM_ID  : 0 for the x-axis params, 1 for the y-axis params
  // COMPUTE side — after `mpi_x.init(); mpi_y.init();`, the module handle exposes:
  //     mpi_x.pe_id   // == get_x_coord() for this PE (set inside init(), NOT before)
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

Hard rules: (a) read mpi_x.pe_id/mpi_y.pe_id only AFTER init() — before init it is
garbage; (b) Mt/Nt (per-PE tile sizes) are NOT introspected from c2d_params — they
arrive as `@param` from layout.csl; (c) the collective methods are exactly
`broadcast/scatter/gather(root:u16, ... :[*]u32, count:u16, cb:local_task_id)` and
`reduce_fadds(root:u16, send:[*]f32, recv:[*]f32, count:u16, cb:local_task_id)` — the
last arg is a local_task_id (a comptime task id), NOT a `fn()void` callback and NOT a color.

(2) Register the new section title in the collectives_2d cluster list at csl_knowledge_base.py:837-847 by adding one list entry:
    "collectives_2d": [
        "collectives_2d/pe import takes DSR-id arrays",
        "Library .csl files with uninitialized `param`s",
        "collectives_2d API surface",
        "collectives_2d introspection: NUM_PES / pe_id / @get_rectangle",   # <-- NEW
        "Affine tensor_access expressions cannot reference non-loop runtime variables",
        ... (unchanged) ...
    ],
This makes _filter_w1_gotchas_for_clusters() include the new section for exactly the kernels whose CUDA already triggers the collectives_2d cluster (gemv/gemm/mpi_x/broadcast/2D-mesh markers). No optimizer, harness, or repair-loop change needed; injection rides the existing for_implementer() -> cluster-gating path and the existing XKERNEL_W1_GOTCHAS gate (so it is A/B-ablatable for the paper).

### C5: Benchmark-libs wrapper param/arity gaps (stencil_3d_7pts / allreduce) — CG, PCG, Power-Method, BiCGSTAB  [knowledge-base-gotcha]  (helps ~4; audit=borderline)
- mechanism: Close the residual tail of the EXISTING firewall-safe lever (library_signatures.py), which already extracts library pe.csl param/fn signatures but emits the two arities agents most often miss as untyped `= {}` defaults. Two concrete changes: (1) ARCH-CORRECT RESOLUTION — make the extractor resolve the arch-specific stencil pe.csl (wse3/pe.csl, since the build is `--arch wse3`) instead of the arch-neutral pe.csl. The neutral file declares `param output_queues = {}` and `param output_ut_id = {}` (no type → agent guesses), while wse3/pe.csl declares `param output_queues:[4]u16` and a bare-scalar `param output_ut_id`. This single change supplies the exact two shapes behind the documented 'output_ut_id as [1]u16 instead of scalar u16' and 'omitted required output_queues' failures. (2) OVERLAY-DISCIPLINE NOTE — append a generic instruction that the layout-supplied struct (stencilParams/reduceParams, which the agent SEES in the given layout.csl) already binds the colors/COMM/SEND/RECV/first_px/width/height, so the compute file must wrap them with `@concat_structs(stencilParams, .{ ...only the leaf params... })` and must NOT re-declare the already-bound fields (kills the duplicated-COMM/BLOCK_SIZE errors). Emit which params are layout-provided vs. caller-supplied by diffing the library pe.csl param set against the layout get_params() return keys (both on disk, both firewall-safe). Inject only param TYPES/ARITIES and the @concat_structs idiom — never the reference's id VALUES ({2,3}, [1]u16{2}), which stay the agent's choice under the existing reserved-range queue note.
- concrete: In library_signatures.py: (A) Thread arch into the extractor. Add `arch: str = "wse3"` param to `library_signatures_block(...)` and `_resolve_pe_csl(...)`. In `_resolve_pe_csl`, after computing `rel` (`<mod>/pe.csl`), when `arch` is set and an arch-specific sibling exists, prefer it: build `rel_arch = rel[:-len('/pe.csl')] + f'/{arch}/pe.csl'` and put `ref/rel_arch`, `ref/'src'/rel_arch`, `ref.parent/rel_arch` AHEAD of the neutral candidates; fall back to neutral if absent. This makes the stencil block emit `param output_queues:[4]u16;` and `param output_ut_id;` (scalar) instead of `= {}`. (B) After the per-module signature sections are built, add a generic overlay note to `header` (or as a trailing section): \"// HOW TO INSTANTIATE: the layout-supplied struct (e.g. stencilParams / reduceParams passed to your compute file via @set_tile_code) ALREADY binds a subset of these params — the colors, the COMM/SEND/RECV (or C_ROUTE/C_SEND_*) entrypoints, first_px/last_px/first_py/last_py, width, height. Do NOT re-supply those. Wrap that struct and add ONLY the remaining params with @concat_structs:\\n//   const stencil_mod = @import_module(\\\"../../benchmark-libs/stencil_3d_7pts/pe.csl\\\", @concat_structs(stencilParams, .{ .f_callback=..., .input_queues=[4]u16{...}, .output_queues=[4]u16{...}, .output_ut_id=<scalar u16>, .BLOCK_SIZE=BLOCK_SIZE, .dest_dsr_ids=[2]u16{...}, .src0_dsr_ids=[1]u16{...}, .src1_dsr_ids=[2]u16{...} }));\\n// output_ut_id is a SCALAR u16 (not an array). Choose distinct queue/DSR ids yourself under the reserved-range rules; the values shown are placeholders.\" (Optionally compute the layout-provided key set programmatically by parsing the `return .{ ... }` of each lib's layout.csl get_params() and tag each emitted param as [layout-provided, do not re-supply] vs [you must supply].) (C) At the call site cuda2csl.py:658, forward arch: `library_signatures_block(reference_dir, layout_text, arch=arch)` — `build_reference_contract` already receives `arch` from `self.arch` (passed at lines 1473/1485). Keep behind the existing XKERNEL_LIB_SIGNATURES gate; add a sub-gate XKERNEL_LIB_OVERLAY_NOTE (default on) so the overlay note can be A/B-ablated independently of the arch fix.

### Resource-id collision (queue/ut_id/color reuse) — Cluster 10, 2 kernels (FFT-1D-2D, Game-of-Life)  [knowledge-base-gotcha]  (helps ~2; audit=safe)
- mechanism: Add a 4th vocabulary-gated W1 cluster `resource_id_alloc` to csl_knowledge_base.py, wired through the SAME machinery that already gates the other three W1 gotcha clusters (_W1_CLUSTER_QUERY_AUGMENTATIONS / _detect_w1_clusters_for_kernel / _GOTCHA_SECTIONS_BY_CLUSTER), surfacing a single consolidated 'WSE-3 reserved resource-ID ranges' table. Root cause confirmed in results/full_suite_sweep_20260623_061147/FFT-1D-2D/run_20260623_132353/FFT-1D-2D/final_result.json: 4 distinct collision flavors across attempts [8] iq IDs 8..15 > max 7, [9] iq 1 collides with memcpy RXCOMMAND ('initialization for this queue has already been set'), [13] broadcast colors 0-3 collide with reserved memcpy colors, [14] color 21 collides with MEMCPYD2H_DATA. Verified FFT fires ZERO W1 clusters and ZERO hard-kernel hints today (ran kb._detect_w1_clusters_for_kernel + kb.hard_kernel_hints on the FFT CUDA source), so it gets no reserved-ID help. The load-bearing missing fact: the legal color ceiling [0,24) on WSE-3 — the reviewer in attempt [14] told the agent to 'move to 30+', which is ILLEGAL, so the loop can never converge. The new table prescribes SAFE BANDS only (colors in [4,24) avoiding low-20s memcpy data colors; input/output queues 2..7; local_task_id 8..20; ut_id 0..7 one-per-op; single-occupancy-until-drain for cross-phase reuse).
- concrete: All edits in /home/USER/xkernel/code_translation/csl_knowledge_base.py. (1) Insert a new H3 section in KNOWN_GOTCHAS_W1_FAILURE_PATTERNS (after line 396, before the halo-receive section) titled '### WSE-3 reserved resource-ID ranges: a single safe-allocation table for colors / queues / task-ids / microthreads' giving the band table: fabric color legal [0,24) on WSE-3 (@get_color(24) illegal; memcpy reserves 0-3 + MEMCPYH2D/MEMCPYD2H_DATA in low-20s; allocate user colors below 24, never >=24, never 'flee upward to 30+'); input_queue 0..7 with 0/1 memcpy-owned (use @get_input_queue(2..7)); output_queue user 2..7; local_task_id [8,31) with memcpy high band 21,27-31 (use 8..20); ut_id 0..7 own-per-op; plus a 'cross-phase reuse trap' paragraph (color/queue/ut_id single-occupancy until drain; allocate distinct IDs per concurrent phase or gate phase-2 on phase-1 completion; same-color send+recv on one PE deadlocks). (2) Append a 4th tuple to _W1_CLUSTER_QUERY_AUGMENTATIONS (after line 774) with markers ['@get_color','@get_local_task_id','@get_input_queue','@get_output_queue','@get_ut_id','fabric_color','broadcast','transpose','butterfly','fft','multi-phase','two phase','all-to-all','ring','shift'] and reserved/range/memcpy/topic-15 keywords. (3) Add ('resource_id_alloc', _W1_CLUSTER_QUERY_AUGMENTATIONS[3][0]) to cluster_markers in _detect_w1_clusters_for_kernel (after line 824). (4) Add a 'resource_id_alloc' entry to _GOTCHA_SECTIONS_BY_CLUSTER (after line 872) listing the new table title + 'memcpy library reserves input queues 0 and 1' + 'WSE-3 queue / microthread ID pools and the @initialize_queue discipline' + 'Output queue drain'. No new env gate needed — reuses XKERNEL_W1_GOTCHAS and the existing cluster-filter, so it is A/B-ablatable like the other 3 clusters.

## Synthesized plan
I'll write the final ranked improvement plan. The analysis is thorough and vetted, so I'll synthesize it into an implementation-ready document for the engineer.

# CUDA→CSL Framework: Ranked Improvement Plan

## 1. Failure taxonomy

13 per-kernel root-cause analyses cluster into 10 failure modes. Below, "FW-safe" = fixable without leaking the canaried reference compute file (`pe.csl`); leverage = #kernels × firewall-safe-fixability.

| # | Cluster | Category | #Kernels | FW-safe | Fixable now? |
|---|---------|----------|----------|---------|--------------|
| C1 | Stale-layout / wrong-build-path export-contract mismatch | contract-export | 5 | YES | **Yes — harness** |
| C2 | get_x_coord/get_y_coord at module-scope comptime | csl-idiom | 6 | YES | **Yes — prompt+KB** |
| C3 | WSE-3 queue-init / async-fabric idioms | csl-idiom | 5 (≤3 reachable) | YES | **Yes — KB routing** |
| C4 | collectives_2d API arity / hallucinated introspection | sdk-api | 4 | YES | **Yes — KB** |
| C5 | benchmark-libs wrapper param/arity gaps | library-wrapper | 4 | YES | **Yes — lib-sig** |
| C6 | Reviewer misdiagnosis / repair-loop thrash | check-too-loose | 5 (3 FW-safe) | PARTIAL | Partial — harness |
| C7 | Numeric / algorithm near-miss | numeric | 4 (1 FW-safe) | MOSTLY NO | No (except PM scaling) |
| C8 | Collective-participation decomposition (hidden ref) | collective-participation | 5 (1 FW-safe) | MOSTLY NO | No (descope) |
| C9 | Immune skeleton — `VERIFY=False` success marker | skeleton-incomplete | 3 | NO at agent layer | Harness-only |
| C10 | Resource-id collision (queue/ut_id/color reuse) | resource-alloc | 2 | YES | **Yes — KB** |

**Fixable-now floor:** the 6 vetted fixes below directly target C1, C2, C3, C4, C5, C10 (the C6 reviewer fix is scoped separately as a harness change). **Unfixable floor (~5 kernels):** GEMV, GEMM-Coll-2D, FFT-2D (collective face), Cholesky, Lorenzo — blocked by hidden-reference decomposition (C8) or immune skeletons (C9).

---

## 2. RANKED firewall-safe fixes to implement now

Ordered by leverage, with effort and confidence factored in. All six have passed the leak audit (one borderline, noted).

### Fix 1 — C1: Stale-layout export-contract resolver `[harness]` — DO THIS FIRST
- **Lever:** Harness. Make `_find_layout_csl()` discover the layout from the *active build script* instead of a hardcoded name-list.
- **Concrete change:** `cuda2csl.py:498-508` — replace `_find_layout_csl` with a `commands_script`-driven resolver (`_layout_from_commands` parses the first positional `*.csl` arg on the `cslc` line, joining backslash-continued lines, skipping flags; legacy name-list becomes fallback only). Thread `commands_script` into the call at `cuda2csl.py:599`. `re`/`os` already imported; `commands_script` already a param of `build_reference_contract` (line 584). **Add the belt-and-suspenders regression guard** to `test_no_compute_leak.py`: assert the resolved layout basename == the `cslc` arg for Power-Method/CG/PCG/BiCGSTAB so this can't silently regress.
- **Expected kernels helped:** 5 (Power-Method, CG, PCG, BiCGSTAB, FFT-1D-2D contract face).
- **Leak verdict:** **none.** The layout is an agent-visible artifact by firewall rule; the `cslc` line lives in `commands.sh` which the agent already reads; the `f_power(i16,i16)` driver signature is already disclosed by the given `run.py` (`simulator.launch("f_power", ...)`). The fix only swaps a *stale/wrong* layout for the *correct* one; algorithm/queue-ids/colors stay in the hidden `kernel_power.csl`. Canary path untouched.
- **Why first:** single most-confirmed mechanism (dominant in 3-5 kernels, documented in MEMORY as the v1.0 immune-kernel bug), best effort-to-payoff ratio, and the regression guard makes it durable.

### Fix 2 — C2: get_x_coord runtime-only idiom `[translation-prompt + KB]`
- **Lever:** Translation-prompt (primary) + KB gotcha gating (secondary).
- **Concrete change:** **(1)** `prompt_cuda2csl.py` `_BUILTIN_WHITELIST_BLOCK` (~64-93): the always-on block was *teaching the bug* — it labeled module-scope `const px = layout_mod.get_x_coord()` as RIGHT. Rewrite so the RIGHT form is runtime-only (call inside fn/task bodies, e.g. helper fns `is_left_col`/`is_top_row`); flag the top-level-const, use-site-cast, and `comptime{}` forms as WRONG with the exact error string ("comptime evaluation … only valid while evaluating a top level comptime block"); route the comptime-need case to a `param` plumbed from the GIVEN `layout.csl`. **(2)** `csl_knowledge_base.py` `_GOTCHA_SECTIONS_BY_CLUSTER` (~836): append the existing runtime-only section title to the `collectives_2d` (~847) and `dsr_queue_fabric_init` (~872) cluster lists — it was wired only to `halo_recv_unblock`, so the 4 matvec/collectives kernels never received it.
- **Expected kernels helped:** 6 (GEMV, GEMV-Collectives-2D, GEMM-Collectives-2D, GEMV-Checkerboard, Residual, +adjacent comptime errors). Highest raw kernel count.
- **Leak verdict:** **none.** Helper/param names are generic placeholders; the rule is a general SDK platform fact. The injected H3 body cites `gemv-07-routes-2`/`gemv-08` which are **public Cerebras SDK tutorials** (ingested via `ingest_tutorials.py`), verified to differ from each target's actual reference solution. No regression on Single-Tile-Matvec (still empty block).

### Fix 3 — C4: collectives_2d introspection field names `[KB-gotcha]`
- **Lever:** KB gotcha. Pre-empt the invented-field hallucination (`DIM_LENGTH`, `c2d_params.x.dim_size`, `.PE_ID`/`.pe_id_x`, `get_x_dim()`) with the real names + a fake→real mapping table.
- **Concrete change:** `csl_knowledge_base.py` — **(1)** add a new H3 section "collectives_2d introspection: NUM_PES / pe_id / @get_rectangle" inside `KNOWN_GOTCHAS_W1_FAILURE_PATTERNS`, after the existing "collectives_2d API surface" section. Content: real per-axis fields (`.pe_id`/`.NUM_PES`/`.pe_min`/`.pe_max`/`.DIM_ID`), `mpi_x.pe_id` readable *only after init()*, mesh dims via `@get_rectangle().width/.height`, Mt/Nt as `@param` (not introspected), exact method arities (last arg is a `local_task_id`, not `fn()void`, not a color), and the hallucinated→real mapping table. **(2)** register the new title in `_GOTCHA_SECTIONS_BY_CLUSTER["collectives_2d"]` (~837).
- **Expected kernels helped:** 4 (GEMV, GEMM-Coll-2D, GEMV-Coll-2D, FFT-1D-2D).
- **Leak verdict:** **none.** Every field verified verbatim in the **public SDK module** `collectives_2d/params.csl`/`pe.csl` (not the canaried reference). The method-callback type also **corrects a pre-existing KB error** at line 283 (wrongly `fn()void`). **Implementation note:** the existing KB section at lines 448-454 describes `get_params` as `(inner_dim, px, py)` which contradicts the real SDK `(Px, Py, ids)` — reconcile the two sections while you're in the file so they don't sit inconsistently.

### Fix 4 — C3: WSE-3 queue-init / async-fabric surfacing `[KB-gotcha]`
- **Lever:** KB gotcha. The facts already exist but are gated unreachable for non-halo fabric kernels.
- **Concrete change:** **EDIT 1** `csl_knowledge_base.py` (~862-872): add two existing section titles to `_GOTCHA_SECTIONS_BY_CLUSTER["dsr_queue_fabric_init"]` — "WSE-3 queue / microthread ID pools and the @initialize_queue discipline" and "Canonical halo receive: async fabin_dsd + ut_id + activate, posted before sends" (both currently mapped only to `halo_recv_unblock`). **EDIT 2** `cuda2csl.py`: fold the GIVEN layout into the implementer KB *query* at all three call sites (1576-1579, 1783-1786, bucket-B retranslate) by adding `getattr(self, "_layout_text_for_translate", "") or ""` to the join — fabric markers (`@initialize_queue`, `@get_output_queue`, etc.) are CSL tokens that never appear in CUDA, so the CUDA-only query detected `[]` and surfaced zero queue gotchas.
- **Expected kernels helped:** claimed 5; **demonstrably ~3** (Wide-Mult, Game-of-Life, GEMV-Checkerboard verified by running `_detect_w1_clusters_for_kernel`). FFT-1D-2D empirically stays `[]→[]` — do not count on it here.
- **Leak verdict:** **none.** In codesign mode `_layout_text_for_translate=""` so the query degrades to CUDA-only, preserving the canary; in normal mode the layout is already shown to the agent. The query is a *selector* (cluster-gating + TF-IDF), never echoed into the prompt. Existing compute canary backstops regression. (The proposed extra guard-rail test is redundant with the canary — skip it.)

### Fix 5 — C5: benchmark-libs arch-correct signatures + overlay note `[library-signatures]` — BORDERLINE
- **Lever:** Extend the existing `library_signatures.py` lever to close its residual tail.
- **Concrete change:** `library_signatures.py` — **(A)** thread `arch` (default `"wse3"`) into `library_signatures_block(...)` and `_resolve_pe_csl(...)`; prefer `<mod>/<arch>/pe.csl` ahead of the neutral `pe.csl` so the stencil block emits `param output_queues:[4]u16;` and scalar `param output_ut_id;` instead of untyped `= {}`. **(B)** append a generic `@concat_structs` overlay-discipline note: the layout-supplied struct already binds colors/COMM/SEND/RECV/first_px/width/height — wrap it, add only the remaining leaf params, don't re-declare bound fields; `output_ut_id` is scalar `u16`. **(C)** forward `arch` at the call site `cuda2csl.py:658` (`build_reference_contract` already has `self.arch`). Gate behind existing `XKERNEL_LIB_SIGNATURES`; add sub-gate `XKERNEL_LIB_OVERLAY_NOTE` (default on) for independent A/B.
- **Expected kernels helped:** 4 (CG, PCG, Power-Method, BiCGSTAB).
- **Leak verdict:** **firewall-safe but borderline — action required.** Arch-dependent arities of a *shared library* are rule-(a) platform facts; `@concat_structs` is a generic builtin; the layout-bound key set is derivable from the agent-visible `stencil` `layout.csl get_params()`. **The one thing you must change:** the illustrative note in the proposal reproduces literals (`{2,3}`, `[1]u16{2}`) that *coincide with the reference compute's actual id-value choices* (`kernel_power.csl:41-61`). Ship the note with **obviously-generic placeholders** (e.g. `{qA,qB}`, `[1]u16{q0}`) — never echo the reference's exact values — to remove all appearance of value-leakage. Values stay the agent's choice under the existing reserved-range rule.

### Fix 6 — C10: WSE-3 reserved resource-ID table `[KB-gotcha]`
- **Lever:** KB gotcha. Add a 4th vocabulary-gated W1 cluster `resource_id_alloc`.
- **Concrete change:** `csl_knowledge_base.py` — **(1)** new H3 section in `KNOWN_GOTCHAS_W1_FAILURE_PATTERNS` (after ~396) with the safe-band table: fabric color legal `[0,24)` on WSE-3 (never flee to 30+); input_queue 0..7 (0/1 memcpy-owned → use 2..7); output_queue user 2..7; local_task_id 8..20; ut_id 0..7 one-per-op; plus a cross-phase single-occupancy-until-drain trap. **(2)** append a 4th tuple to `_W1_CLUSTER_QUERY_AUGMENTATIONS` (~774) with allocator-builtin + multi-phase markers. **(3)** add `resource_id_alloc` to `cluster_markers` in `_detect_w1_clusters_for_kernel` (~824). **(4)** add a `resource_id_alloc` entry to `_GOTCHA_SECTIONS_BY_CLUSTER` (~872). Reuses `XKERNEL_W1_GOTCHAS` — no new gate.
- **Expected kernels helped:** 2 (FFT-1D-2D, Game-of-Life).
- **Leak verdict:** **none.** The `[0,24)` ceiling and queue/ut_id ranges are verbatim in public csl-examples / topic-15 README; prescribed bands are *strictly wider* than the reference's actual choices (verified against `ucode_2d.csl`), so nothing is pinned. The reviewer's illegal "move to 30+" advice (which blocks convergence) makes surfacing the real ceiling load-bearing. **Caveat (impact, not leak):** the per-attempt collision annotations are an unverified reading of the JSON; treat the kernel-helped count as a 2-kernel ceiling, not a guarantee.

---

## 3. What is NOT firewall-safe-fixable now

### C6 — Reviewer misdiagnosis / repair-loop thrash (harness change, NOT in the vetted set)
The repair-loop reviewer points at non-bugs and never names the real blocker (Wide-Mult: phantom filename mismatch 8/12; PCG: `f_pcg_init` vs `f_pcg` export thrash; GEMM-Coll-2D: ~8 contradictory theories). This is a **force-multiplier** — Wide-Mult and PCG have firewall-safe root causes the loop never reaches. **It is real and high-value, but it is not a knowledge/prompt injection** — it requires reviewer-verdict-accuracy harness work (verdict grounding against compiler error strings, suppressing red-herring theories), which was not vetted in this round. **Recommendation:** scope it as the next harness task *after* Fixes 1-6 land, because Fix 1 (stale-layout) and Fixes 2-4 (KB) directly remove several of the red herrings the reviewer currently chases, so C6's residual surface shrinks first. Do not attempt it blind.

### C7 — Numeric / algorithm near-miss (correctness-fix, mostly NO)
CG (rho 89692 vs 89168, fails rtol=1e-5), Residual (7923 vs 8529), Cholesky (48.8% mismatch). Per-iteration convergence/accumulation semantics (k==1 special-case, fp accumulation order in dot/allreduce, cross-PE Schur coupling) live in hidden state-machine files and are **not derivable from flat CUDA**. Only Power-Method's ~0.233x scaling bug is firewall-safe (derivable from CUDA semantics). The rest need either a correctness fix in the reference path or a calibrated-tolerance harness decision — neither is a knowledge injection.

### C8 — Collective-participation decomposition (hidden reference, MOSTLY NO)
GEMV (5-stage scatter/gather), GEMM-Coll-2D (SUMMA serialized chain), Game-of-Life (cardinal+relay). The exact distributed decomposition lives only in canaried `pe.csl` and the placement contract (`distribution.py`) is itself hidden. **Highest-impact unfixable cluster.** Exception: **GEMV-Collectives-2D is firewall-safe** — its gating rule generalizes ("every PE a collective spans must call it; a gated-out PE must still `@activate` the same next-task"). If you want one more win here, that single generalizable rule is injectable as a gotcha; the 5-stage/SUMMA decompositions are not. Otherwise descope or build a curated halo/decomposition exemplar (large effort, separate project).

### C9 — Immune skeleton / `VERIFY=False` (harness-only, NO at agent layer)
Laplacian2D-Reduce, Lorenzo, Cholesky: `run.py` ships `VERIFY=False`; "SUCCESS" gated behind `if VERIFY:`, so correct kernels score `missing_success_marker` (11/12 Laplacian compile+run clean). Cholesky inverts it: loose `assert_almost_equal(decimal=2)` lets the agent reverse-engineer the answer key. **Caps these at 0 wins by construction.** Fix is a harness change to `run.py`/`benchmark_csl.py` (not agent-reachable) — trivial at the harness layer, impossible at the agent layer. Worth doing as a separate harness ticket; it is orthogonal to the knowledge stack.

---

## 4. The single highest-leverage change

**Fix 1 — the C1 stale-layout resolver in `cuda2csl.py:_find_layout_csl`.**

It is the best change on every axis simultaneously:
- **Confirmed mechanism, not a theory.** Ground-truth-verified end-to-end (`commands_wse3.sh` compiles `layout_power.csl` exporting `f_power`; the stale `layout.csl` the current code returns exports the phantom `f_spmv`/`f_nrm2_y`/`f_scale_x_by_nrm2`). Already named in MEMORY as the v1.0 immune-kernel bug.
- **5 kernels** (the entire iterative-solver family: Power-Method, CG, PCG, BiCGSTAB, + FFT contract face), every one firewall-safe.
- **Smallest, lowest-risk diff** of the six — one function rewrite + one call-site arg + a regression guard. No new knowledge content to leak-audit per kernel.
- **Force-multiplier on C6.** It removes the export-form red herring (`f_pcg_init` vs `f_pcg`) that the reviewer thrashes on, shrinking the C6 reviewer problem before you ever touch the reviewer.

These were previously the "immune" kernels — currently capped near 0 wins by a build-path visibility bug. One harness fix makes the entire iterative-solver family's export contract self-consistent and converts the cluster from immune to optimizer-reachable.

**Recommended landing order:** Fix 1 → Fix 2 → Fix 4 → Fix 3 → Fix 6 → Fix 5 (apply the placeholder-literal change before shipping Fix 5), then scope C6 (reviewer accuracy) and the C9 `VERIFY=False` harness ticket as the next round. Land each behind its existing env gate and re-baseline per kernel so the wins are independently attributable for the paper.
---
## Fix-1 validation: solver re-run with the corrected layout contract (2026-06-23)
Re-ran the 4 iterative solvers with Fix 1 (commands-driven layout resolver) live:
| solver | buggy full-suite sweep | with Fix 1 | note |
|---|---|---|---|
| Power-Method | fail | fail | contract-error class 4→0 (bucket-C phantom-export GONE); now fails on real compute (1/√10 scaling, queue collision, forward-decl) |
| CG | fail | fail | deeper numeric/state-machine blocker |
| Preconditioned-CG | fail | fail | deeper numeric/state-machine blocker |
| BiCGSTAB | pass 63,054 | **pass 46,594** | improved; rigorous backward-error gate (assert eps > |b-Ax|/(|A||x|+|b|)), code_sim 0.14 — a genuine solve |

**Conclusion:** Fix 1 was a results-integrity correction — it eliminated the
contract-visibility failure class (validated on Power-Method: 4 phantom-export
verdicts → 0) and BiCGSTAB optimized further with the correct contract. The other
3 solvers fail on genuine deeper issues (on-device state-machine numeric
semantics + fabric idioms), correctly classified as NOT contract/idiom-fixable.
The solver family is partially reachable (BiCGSTAB), not a uniform wall, and the
full-suite sweep's solver fails were partly a stale-contract artifact now removed.
