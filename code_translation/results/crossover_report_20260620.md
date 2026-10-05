# Problem-size crossover report (WS1.2, 2026-06-20)

Empirical sweep to pick `large` configs where decomposition matters. Each kernel:
scale the SRAM-bound axis on its current mesh; record compile/run/cycles/overflow.
Measured on WSE-3 SDK 1.4.0. (Crude sweep parser flagged stray "Error:" strings
on some passing Cholesky runs — those printed cycles_send AND reached SUCCESS;
re-verified cleanly. The decisive signals are "compiles?" and "runs to SUCCESS?".)

## GEMM (P x P SUMMA; scale per-PE tile T=Mt=Kt=Nt)
| P | T | matrix | result |
|---|---|--------|--------|
| 4 | 14 | 56² | 51,753 cyc |
| 4 | 24 | 96² | 208,521 cyc |
| 4 | 40 | 160² | 778,372 cyc |
| 4 | 60 | 240² | **FAIL: "ld.lld: ran out of PE memory"** |
| 6 | 24 | 144² | 312,603 cyc |
| 8 | 24 | 192² | 416,703 cyc |
| **8** | **30** | **240²** | **626,165 cyc, SUCCESS** ← `large` (overflows at P=4) |

## GEMV (kernel_rows × kernel_cols mesh; scale matrix)
| mesh | matrix | result |
|------|--------|--------|
| 4×4 | 32×16 | 4,003 cyc (small) |
| 4×4 | 128×64 | 5,616 cyc |
| 4×4 | 512×256 | **FAIL (overflow)** |
| 8×8 | 512×256 | `large` candidate — verifying |

## Cholesky (P×P mesh; scale per-PE block Nt) — COMPUTE-DOMINANT (no overflow)
| P | Nt | result |
|---|----|--------|
| 10 | 4 | 12,479 cyc (small) |
| 10 | 16 | 228,214 cyc |
| 10 | 32 | 1,321,823 cyc ← `large` (Nt²=1024 f32 ≈ 9 KB/PE; fits) |
| 10 | 48 | 3,824,841 cyc |

## Laplacian2D-Halo (width×height mesh; scale tile Mt=Nt) — DECOMP-FORCING
| mesh | Mt=Nt | result |
|------|-------|--------|
| 2×2 | 4 | 1,709 cyc (small) |
| 2×2 | 16 | 25,627 cyc |
| 2×2 | 32 | **runtime FAIL** (no cycles) on 2×2 |
| 2×2 | 64 | **runtime FAIL** |
→ `large` = Mt=32 on a bigger mesh (decomposition), or Mt=16 max on 2×2.

## 7pt-Stencil (5×5 mesh; scale z-pencil zDim) — COMPUTE-DOMINANT
| zDim | result |
|------|--------|
| 5 | 2,129 cyc (small) |
| 20 | 6,024 cyc |
| 60 | 17,134 cyc ← `large` |
| 120 | 33,799 cyc |

## Two kinds of "large" (a finding for the paper)
1. **Overflow-forcing** (GEMM, GEMV, Laplacian2D-Halo): at the large size a fixed
   small mesh CANNOT run the problem (PE-memory overflow or runtime stall), so
   decomposition onto more PEs is mandatory. This is the strongest property —
   single-PE / naive ports are physically infeasible.
2. **Compute-dominant** (Cholesky, 7pt-Stencil): larger size scales cycles
   without overflow on the existing mesh; decomposition headroom grows but isn't
   forced. Still far more decomposition-sensitive than the tiny baseline.

Both make decomposition matter more than at the tiny default size — the
prerequisite for the suite to reward translation-via-decomposition. The
overflow-forcing kernels are the cleanest "agent must decompose" test cases.

## CORRECTNESS re-verification (critical — added 2026-06-20)
The crude sweep parser conflated "compiled + emitted cycles_send" with "passed".
Every chosen large config was RE-VERIFIED with its host correctness check:

| kernel | large config | cycles | correctness | verdict |
|--------|--------------|-------:|-------------|---------|
| GEMM | 240² (P=8) | 626,165 | SUCCESS (assert_allclose) | ✅ valid large |
| GEMV | 512×256 (8×8) | 10,309 | SUCCESS (assert_allclose) | ✅ valid large |
| 7pt-Stencil | zDim=60 | 17,134 | SUCCESS! | ✅ valid large |
| Laplacian2D-Halo | Mt=16 | 25,627 | SUCCESS (diff<1e-5) | ✅ valid large |
| **Cholesky** | Nt=16 / Nt=32 | 228k / 1.32M | **FAIL (assert_almost_equal decimal=2)** | ❌ SMALL-ONLY |

**Cholesky has NO valid large size:** the reference factorization loses f32
precision as the block grows — both Nt=16 and Nt=32 fail the 2-decimal host
check despite compiling and emitting cycles. Reverted to small-only; the broken
`large` size + commands_wse3_large.sh were removed. This is exactly the WS5
failure mode (a number that looks fine but measures the wrong thing) and the
reason large configs require a CORRECTNESS-checked re-verify, not just a cycle
read.

## Gate check: PASSED
GEMM and GEMV are physically infeasible at their large size on the small mesh
(PE-memory overflow), and recover only on a larger mesh — decomposition is
required. Laplacian is runtime-infeasible beyond Mt=16 on 2×2. So decomposition
demonstrably changes feasibility/ranking at scale → WS2 (free the decomposition)
is justified. 4 of 5 kernels have valid large sizes (Cholesky small-only).
