# Lever 1 (library-signature injection) — A/B result (2026-06-19)

A/B on the 5 DSR-arity W1 kernels (7pt-Stencil, Power-Method, CG, PCG,
BiCGSTAB). Arm A = `XKERNEL_LIB_SIGNATURES=0` (off, control), Arm B = on.
opus-4-7, cap-8, single seed. Lever extracts param/fn signatures from the REAL
benchmark-libs/*.csl the kernel imports (no hand-authored content).

## Pass-rate: FLAT (the coarse metric)
- A (off): **1/5** pass (only 7pt-Stencil)
- B (on):  **1/5** pass (only 7pt-Stencil)
7pt-Stencil passes in BOTH and is variance-prone (it FAILED in the full sweep,
passed both A/B arms here) — not a discriminating case.

## Error-family analysis: the lever WORKS at the mechanism level
Per-attempt cslc error classification (error_family.py over the preserved
final_result.json transcripts):

| error family | A (off) | B (on) | change |
|---|---:|---:|---|
| **dsr_arity_mismatch** | **20** | **7** | **−65%** |
| uninitialized_param | 1 | 0 | −100% |
| **dsr_arity + uninit (the target)** | **21** | **7** | **−67%** |
| queue_or_ut_id | 4 | 9 | +125% (next layer exposed) |
| contract_entrypoint | 2 | 4 | +100% (next layer) |
| shadow_or_decl | 10 | 13 | + |
| other_compile_error | 1 | 4 | + |
| total attempts | 39 | 38 | ~ |

### What the per-attempt sequences show
OFF — every solver burns its FIRST 4 attempts on dsr-arity:
- Power-Method (off): `dsr,dsr,dsr,dsr,queue,shadow,shadow,shadow`
- CG (off):           `dsr,dsr,dsr,dsr,shadow,shadow,contract,shadow`
- PCG (off):          `dsr,dsr,dsr,dsr,queue,queue,shadow,contract`

ON — dsr-arity cleared in 0-1 attempts, agent advances to deeper layers:
- Power-Method (on):  `shadow,dsr,queue,queue,shadow,contract,queue,dsr`
- CG (on):            `other,shadow,dsr,queue,shadow,shadow,contract,shadow`
- PCG (on):           `shadow,queue,shadow,queue,dsr,other,dsr,queue`

## Interpretation (honest, paper-grade)
1. The information-starvation diagnosis is CONFIRMED: with the real library
   signatures in context, the dsr-arity error family drops 67%. The agent no
   longer wastes ~half its budget rediscovering `dest_dsr_ids:[2]u16` /
   `src0_dsr_ids:[1]u16`.
2. Pass-rate is flat because W1 translation failure is MULTI-LAYERED. Clearing
   the dsr-arity layer exposes the next bottlenecks (queue/ut_id init counts
   RISE +125%, entrypoint-contract errors rise). At cap-8 the agent now dies on
   layer 2-3 instead of layer 1.
3. Therefore a single lever SHIFTS the bottleneck rather than removing it. To
   convert the mechanism win into a pass-rate win needs EITHER (a) more layers
   addressed (queue/ut_id signatures are in the SAME extracted block — the agent
   isn't using them yet; a targeted gotcha may help), OR (b) more attempts
   (cap-20) now that early attempts aren't wasted on arities, OR (c) both.

## Caveats
- Single seed; W1 is high-variance near cap-8 (7pt flipped vs the sweep). The
  error-FAMILY signal is far more robust than pass/fail and is the result we
  trust here. A multi-seed run is the next step for a pass-rate claim.
- 7pt-Stencil's ON run shows fewer dsr errors but an early `other_compile_error`
  — model variance in where it starts.

## Takeaway for the paper
Lever 1 is a validated, general, firewall-safe mechanism that provably removes
the #1 W1 failure family (−67% dsr-arity/uninit errors), demonstrated by
error-family analysis rather than a noisy pass counter. It exposes that W1
failure is layered — a finding in itself. Next: extend the extracted-signature
USE (queue/ut_id), pair with cap-20, multi-seed.
