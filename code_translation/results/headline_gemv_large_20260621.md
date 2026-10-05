# Headline experiment — GEMV-large agent decomposition + repair loop (2026-06-21)

**Question:** Can the agent, firewalled from the reference, translate CUDA into a
WORKING wafer-scale decomposition at a size where decomposition is MANDATORY
(512×256 GEMV, which overflows a small PE mesh), and does it beat the human
reference (10,309 cycles)?

**Setup:** `code_translation/_ws2b_repair.py` — multi-artifact generation
(distribution.py + filled holed-layout + pe.csl) with a REPAIR LOOP (≤8 attempts,
compiler/runtime errors fed back), opus-4-7. Firewalled: CUDA + task + holed
template + logical run.py + REAL library signatures (incl. SDK
`<collectives_2d/pe>` extracted from the container); NEVER the reference
pe.csl/layout.csl/distribution.py. Run + verified at 512×256 (8×8) via the
logical run.py.

## Result
| metric | value |
|---|---|
| attempts to a PASSING decomposition | **2** (attempt 1 fail → attempt 2 SUCCESS) |
| agent cycles | **58,610** |
| human reference | 10,309 |
| vs reference | **+468.5% (≈5.7× slower)** |

## Interpretation (the paper narrative)
1. **YES — the agent discovers a CORRECT decomposition at scale.** Firewalled,
   from CUDA, it produced a coherent 8×8 GEMV: A row/col-tiled per PE, `c2d_x`/
   `c2d_y` collectives (broadcast x, reduce partial products, broadcast b), y
   gathered from the last column. It compiles AND verifies at 512×256 — a size
   the single-small-mesh reference physically cannot run. The repair loop fixed
   the one-shot idiom error (`c2d_params.x_dim_params`→`.x`) in ONE iteration,
   exactly as predicted from the compiler note.
2. **NO — it does not beat the expert at scale.** 5.7× slower. The cause is
   visible in the agent's pe.csl: the inner product is a SCALAR double loop
   (`while i<Mt { while j<Nt { ... } }`) instead of bulk `@fmacs` over DSDs.
   The agent got the hard STRUCTURAL part (the decomposition) right but left the
   IDIOM-level compute unoptimized.
3. **This is the realistic ceiling the plan predicted:** at large sizes, the
   agent can find a working decomposition (fast_0); beating expert hand-tuned
   references (fast_1+) is frontier-hard for translation alone. The natural
   closer is the translate→OPTIMIZE pipeline: run W2 on this correct-but-slow
   decomposition. W2 has shown it recovers exactly this class of idiom win
   (fmac_bulk etc., 14/14 at small sizes) — the open question is how much of the
   5.7× it recovers at scale.

## What this validates
- The Phase-2 benchmark works as intended: a decomposition-mandatory size that
  the agent must solve structurally, scored honestly against the expert.
- The full agent-distribution + holed-layout + repair-loop pipeline runs
  end-to-end and produces correct, verified, scored wafer-scale kernels.
- The translation-vs-optimization story is now legible and separable: W1 finds
  the decomposition; W2 closes the idiom gap.

Winning artifacts: /tmp/ws2b_repair_artifacts/{distribution.py,layout.csl,pe.csl}.

## Closer: W2 on the agent's decomposition (translate→optimize at scale)
Ran the cycle-reduction optimizer on the agent's 58,610-cycle pe.csl (keeping its
distribution + layout), to see how much of the 5.7× the pipeline recovers.
- First W2 driver (single-shot per attempt, NO error feedback): 0/6 accepts —
  but all 6 FAILED TO COMPILE with i16/u16 operand-type errors at the @fmacs/DSD
  rewrite sites. The optimizer reached for the RIGHT idiom (bulk DSD @fmacs) but
  couldn't land the strict CSL types without feedback. This 0% is an artifact of
  the no-repair driver, NOT the pipeline (cf. W2's 14/14 at small sizes with its
  real loop).
- Repair-enabled W2 driver (feeds the cslc error back each attempt, cap 8):
  **58,610 → 36,853 → 14,002 → 7,861 (3 accepts).** The final 7,861 cycles
  **BEATS the human expert reference (10,309) by 24%.** Independently re-verified
  in a clean bundle: 7,861 cycles, SUCCESS.

This itself is a finding: optimization at scale needs the repair loop just as
translation does — single-shot can't land the strict-typed bulk-DSD idiom.

## FULL ARC RESULT (the paper's large-size headline)
| stage | cycles | vs expert (10,309) |
|---|---:|---|
| human expert reference | 10,309 | — |
| agent W1 decomposition (from CUDA, firewalled, repair loop) | 58,610 | +468% (5.7× slower) |
| + agent W2 optimization (repair loop) | **7,861** | **−24% (BEATS expert)** ✅ verified |

**End-to-end, firewalled from the reference, at a decomposition-MANDATORY size,
the translate→optimize pipeline produces a correct kernel that beats the human
expert.** What W2 changed: replaced the scalar `while j { s += A[i*Nt+j]*xv[j] }`
inner product with a strided `mem1d_dsd` column view + `@fmacs` +
`@increment_dsd_offset` (the `column_gather_via_strided_dsd` / `fmac_bulk`
idiom) — O(Mt·Nt) scalar ops → O(Nt) bulk DSD issues.

### The clean separation the paper wants
- **Translation** finds the wafer-scale DECOMPOSITION (the hard structural step
  a naive GPU port can't do) but writes naive idioms.
- **Optimization** closes the IDIOM gap and surpasses the expert.
- Both need their repair loop; both validated firewalled + correctness-checked.
Winning kernel: /tmp/ws2opt_best_pe.csl (+ the agent's distribution.py/layout).

### Preserved artifacts (version-controlled, reproducible)
`results/headline_gemv_large_artifacts/`:
- `agent_w1_distribution.py`, `agent_w1_layout.csl`, `agent_w1_pe.csl` — the
  firewalled W1 decomposition (58,610 cyc).
- `agent_w2_optimized_pe.csl` — the W2-optimized compute (7,861 cyc, verified).
W2 changed **39 lines** of pe.csl (the scalar inner loop → bulk-DSD `@fmacs`),
leaving the agent's decomposition (distribution + layout) UNTOUCHED — the clean
translate-vs-optimize separation, made auditable.
