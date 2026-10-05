# Lever-1 at cap-20, multi-seed A/B — report (2026-06-20)

E2: 5 DSR-arity kernels × {lib-sigs OFF, ON} × 3 seeds = 30 W1-from-CUDA runs at
--reviewer-max-attempts 20. opus-4-7. "ON" = library signatures (lever-1) + the
WSE-3 queue/ut_id discipline note (E1, added 2026-06-19). This is the multi-seed,
higher-cap follow-up the methodology required after the single-seed cap-8 A/B.

## Pass-rate: NO improvement (directionally negative)
| Kernel | A (off) seeds | A pass | B (on) seeds | B pass |
|---|---|---|---|---|
| 7pt-Stencil | T5 F20 T13 | 2/3 | T11 T8 T18 | 3/3 |
| Power-Method | T8 T16 F20 | 2/3 | F20 F20 F20 | **0/3** |
| CG | F20 F20 F20 | 0/3 | F20 F20 F20 | 0/3 |
| Preconditioned-CG | F20 F20 T6 | 1/3 | F20 F20 F20 | **0/3** |
| BiCGSTAB | T20 F20 T16 | 2/3 | T18 T11 F20 | 2/3 |
| **TOTAL** | | **7/15** | | **5/15** |

Fisher exact p ≈ 0.45 — NOT significant; the 7 vs 5 difference is within noise on
N=3 seeds. Mean attempts-on-pass: A=12.0, B=13.2 (no speed benefit either).

## Error-family (mechanism level), per-attempt-normalized
| family | A(off) /att | B(on) /att | change |
|---|---:|---:|---|
| **dsr_arity+uninit** | 0.332 | 0.271 | **−18%** |
| queue_or_ut_id | 0.102 | 0.188 | **+84%** |
| shadow_or_decl | 0.184 | 0.241 | + |
| contract_entrypoint | 0.061 | 0.034 | − |

## Honest interpretation — the cap-8 win does NOT replicate at cap-20
1. **dsr-arity reduction collapsed from −67% (cap-8) to −18% (cap-20).** At cap-20
   the agent has 244–266 attempts of budget and rediscovers arities on its own,
   so the signature injection's marginal value shrinks. The lever's benefit is
   CAP-DEPENDENT: large at cap-8 (information is the binding constraint), small at
   cap-20 (budget substitutes for information).
2. **The queue/ut_id discipline note (E1) appears to BACKFIRE: queue errors +84%.**
   Injecting the queue discipline may be pulling the agent into queue setup it
   would otherwise leave to library defaults, or the longer prompt degrades
   attention. This is a negative signal for E1 as a default.
3. **Power-Method (2/3→0/3) and PCG (1/3→0/3) regressed** under the lever —
   consistent with injection adding noise that hurts thin-dispatcher kernels
   where library-signature detail is NOT the binding constraint (their compute is
   mostly library calls; the heavy detail is distraction).
4. **CG is robustly unsolvable** at cap-20 either way (0/6) — its failures are
   deeper than the injected layers.

## Decision (paper-honest)
- DO NOT ship lib-signatures + queue note as an unconditional default. The
  evidence says the lever helps at LOW cap (information-bound regime) and is
  neutral-to-negative at HIGH cap (budget-bound regime).
- The E1 queue note specifically shows a +84% queue-error signal — REVERT it as a
  default (keep behind XKERNEL_LIB_SIGNATURES but consider splitting the queue
  note into its own gate, default OFF, pending a cleaner test).
- This is a genuine, reportable result: a context-injection lever's value is
  cap-dependent and can invert. It strengthens the paper (honest negative +
  the regime distinction) rather than weakening it.

## Caveats
- N=3 seeds; pass-rate differences are not significant. The error-family rates
  (244/266 attempts) are the more robust signal and still show the lever's
  dsr-arity effect SHRANK, not grew, at cap-20.
- Single model (opus-4-7). A weaker model might be more information-bound (lever
  helps more) — a model×cap interaction worth testing.
- "ON" bundles lib-sigs AND the queue note; their effects are confounded here.
  A clean 3-arm test (off / sigs-only / sigs+queue) would disentangle them.
