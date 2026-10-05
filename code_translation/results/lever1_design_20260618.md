# Lever 1 — pre-flight library-param extractor: design (2026-06-18)

Goal: stop the W1 implementer thrashing on hidden benchmark-libs module
signatures (the cause of 9/18 sweep failures; see w1_failure_analysis_20260618).
Inject the `param` + `fn` signatures of the library modules a kernel actually
uses, so the agent stops reverse-engineering arities (dest_dsr_ids:[2]u16,
src0_dsr_ids:[1]u16, ...) from compiler errors.

## Firewall-safety (verified)
- The compute-leak canary (_set_compute_canary) stashes a distinctive line from
  the BENCH's OWN reference compute (target_path = kernels/<K>/CSL/.../pe.csl).
  benchmark-libs/*.csl are DIFFERENT, shared library files — injecting their
  signatures does NOT trip the canary.
- `param`/`fn` declarations are library INTERFACES (like a header), not the
  bench's compute solution. The reference pe.csl body stays hidden. This is the
  same category as the SDK <memcpy>/<time> module docs the agent already sees.

## What to extract
For each library module the kernel's layout.csl imports
(`@import_module("../../benchmark-libs/<mod>/layout.csl", ...)`), extract from
the corresponding `<mod>/pe.csl` (the file the COMPUTE must instantiate):
  - every `^param NAME: TYPE;` and `^param NAME = DEFAULT;` line
  - every top-level `^fn NAME(args) ret` / `^pub fn ...` signature (one line,
    drop the body)
Also handle SDK collectives: `@import_module("<collectives_2d/pe>", ...)` /
`<collectives_2d/params>` -> extract from the SDK install
(/home/USER/cs_sdk-1.4.0/...). If the SDK path isn't resolvable, fall back to a
hand-authored signature block for collectives_2d (the 3 collectives kernels).

Example output for stencil_3d_7pts (the signature 5 kernels needed):
```
// <module> ../../benchmark-libs/stencil_3d_7pts/pe.csl — params your import struct MUST supply:
param f_callback : fn ()void;
param input_queues:[4]u16;
param output_queues = {};
param output_ut_id = {};
param BLOCK_SIZE: i16;
param dest_dsr_ids:[2]u16;
param src0_dsr_ids:[1]u16;
param src1_dsr_ids:[2]u16;
// callable helpers:
fn spmv(n: i16, coeff: *[7]f32, x: [*]f32, y: [*]f32) void
```

## Where to inject (code changes, all in cuda2csl.py + a new helper module)
1. NEW `library_signatures.py`:
   - `discover_imported_libs(layout_text) -> [relpath...]` (regex on
     `@import_module("..."` for benchmark-libs + <collectives_2d/*>).
   - `extract_signatures(reference_dir, layout_text) -> str` — resolve each lib's
     pe.csl relative to reference_dir (mirror benchmark_csl's path logic:
     `<ref>/../../benchmark-libs/...`), grep param/fn lines, format the block.
     Cache; return "" if nothing found (no-op for single-PE kernels).
2. `prompt_cuda2csl.py`: add a `{library_signatures}` slot in
   `q_translate_cuda_to_csl_bundle` right after the layout.csl block (~line 342)
   AND in the repair prompts (`csl_bundle_fix*`) — the thrashing happens in the
   repair loop, so the signatures must persist there too.
3. `cuda2csl.py`: compute the block once in translate() and pass it into the
   .format() at 1393 and the repair .format() sites. Gate behind env
   `XKERNEL_LIB_SIGNATURES` (default "1") so it can be A/B'd off.

## Validation plan (after Sweep 2; SDK serial)
Re-run W1 on the 5 DSR-arity kernels (7pt-Stencil, Power-Method, CG, PCG,
BiCGSTAB) at the SAME cap-8, A/B with XKERNEL_LIB_SIGNATURES=0 vs 1. Success =
≥2-kernel pass-rate lift (clears noise floor). These 5 share one signature, so
if the lever works it should flip several at once. Also spot-check it doesn't
regress the 2 current passers (GEMM, Single-Tile-Matvec) or the collectives
kernels.

## Risk / caveats
- Path resolution: layout imports are relative to CSL/src/ or CSL/; the helper
  must try both depths (benchmark_csl._stage_benchmark_libs already encodes the
  `<ref>/../../benchmark-libs` convention — reuse that logic).
- collectives_2d lives in the SDK, not benchmark-libs — needs the SDK path or a
  hand-authored fallback. Ship stencil/allreduce (the 5 DSR kernels) first;
  collectives as a follow-up.
- Token cost: signature blocks are small (~15-40 lines/module); negligible.
