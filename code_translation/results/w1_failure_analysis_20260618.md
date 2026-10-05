# W1 (CUDA→CSL) failure analysis — why the sweep underperformed (2026-06-18)

Mined from all 20 W1 sweep traces (full_sweep_20260618_sweep) by a 21-agent
analysis workflow. Driver model claude-opus-4-7, --reviewer-max-attempts 8.

## Headline
- Sweep W1 pass-rate: **2/20** (GEMM, Single-Tile-Matvec).
- Documented baseline (baseline_ablation_report_20260616, Sonnet, cap-20): **7/15**.
- **5 of the 7 documented passers REGRESSED**: GEMV, GEMV-Collectives-2D,
  GEMM-Collectives-2D, FFT-1D-2D, Laplacian2D-Halo (pass → fail).

## The cap-8 cut is NOT the main cause (this was the surprise)
**18/18 failed kernels scored `was_converging=false` — every failure was
THRASHING, not budget-starved.** Not one failed kernel was on a clean
trajectory that simply ran out of attempts. GEMM (the only non-trivial pass)
was the only converging profile — it passed at attempt 5/8.
=> Raising the cap to 20 alone would help ~0/18 failures. They need
INFORMATION, not iterations.

## The real cause: the firewall hides library *interface* signatures
9/18 failures (50%) have `root_cause_visible_to_agent=false`. The implementer
sees layout.csl/run.py/commands.sh but NOT pe.csl AND NOT benchmark-libs/*.csl.
It thrashes reverse-engineering library module signatures from cslc errors:
- **DSR-arity cluster (5):** 7pt-Stencil, Power-Method, CG, PCG, BiCGSTAB — all
  blocked on the SAME hidden signature: stencil_3d_7pts wants
  `dest_dsr_ids:[2]u16, src0_dsr_ids:[1]u16, src1_dsr_ids:[2]u16` (+ allreduce
  all-[1]u16, output_ut_id, coeff:*[7]f32).
- **collectives_2d cluster (3):** GEMV, GEMV-C2D, GEMM-C2D — blocked on
  `<collectives_2d/pe>` queue/DSR/local_task_id-callback wiring and the
  `[*]u32` (scatter/broadcast/gather) vs `[*]f32` (reduce_fadds) ptrcast split.
- **routing (1):** FFT-1D-2D.

SMOKING GUN: Power-Method and CG traces show `tool_use:0` — the reviewer kept
instructing "open pe.csl and list its params," but the agent had **no
Read/Bash/Grep mechanism** to do so, while the files physically sat in the
sandbox. The loop was structurally unwinnable.

## Failure-mode taxonomy (18 failures)
| Cluster | Count | root_cause_visible |
|---|---|---|
| Hidden benchmark-libs DSR-arity | 5 | false |
| collectives_2d hidden contract | 3 | false |
| Halo unblock / 0-byte D2H stall | 6 | mostly true |
| Self-inflicted visible CSL idiom (ut_id reuse, D2H stall, routing) | 3 | true |
| Halo color-routing (Laplacian2D-Halo) | 1 | true |

Two meta-families: hidden-library-signatures (8, root_cause invisible) and
fabric/halo runtime stalls (10, root_cause mostly visible → needs better
gotchas/diagnostic priors, not library injection).

## TOP 3 LEVERS (ranked, evidence-based)
1. **Pre-flight library-param extractor.** Read benchmark-libs/*.csl `param` +
   `pub fn` signatures and inject into the implementer context. Unblocks the 5
   DSR-arity kernels (one shared signature!) and likely the 3 collectives_2d
   kernels = ~8 kernels. FIREWALL-SAFE: param signatures are library
   *interfaces*, not the bench compute answer. Fixes the "told to read a file it
   can't read" pathology. Effort: medium.
2. **DSR-arity + collectives gotchas.** Hand-authored knowledge facts: the exact
   arities (dest[2]/src0[1]/src1[2], dest[0]==src0[0]) and the ptrcast split
   (all [*]u32 except reduce_fadds=[*]f32; callback = bare local_task_id not
   fn()void). Same 8-kernel reach, low effort, lower ceiling. Stopgap for #1.
3. **Cap-20 + Opus — but ONLY after #1/#2.** Pure budget helps 0/18 alone (all
   thrashing). Becomes a real multiplier once the information gap is closed.

## Caveat on this sweep as a W1 capability measurement
This is W1 at a CONSTRAINED budget (cap-8) AND on a single model (opus-4-7, no
Sonnet→Opus hybrid). The 2/20 understates the framework. But the convergence
analysis shows the headline finding is budget-INDEPENDENT: the failures are
information-starved, not iteration-starved. That conclusion holds regardless of
cap.
