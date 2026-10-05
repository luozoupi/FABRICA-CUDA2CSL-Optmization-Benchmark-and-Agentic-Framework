# Profiler A/B: recount from raw run artifacts (2026-08-06)

Supersedes the verdict tallies in
[`PROFILER_AB_RESULTS_20260715.md`](PROFILER_AB_RESULTS_20260715.md) and
[`SWEEP_RESULTS_COMPREHENSIVE_20260720.md`](SWEEP_RESULTS_COMPREHENSIVE_20260720.md)
§2.2 / §5.2.

Data: `docs/data/profiler_ab_recount.csv` (46 kernels).
Reproduce: `code_translation/recount_profiler_ab_tally.py`.

---

## 1. Why a recount was needed

### 1.1 Six different tallies existed for the same 740 runs

| Source | Better / Worse / Same / NoData (original 28) |
|---|---|
| `profiler_ab_full_20260708_214657/VERDICT.txt` (emitted by the sweep itself) | **3 / 6 / 5 / 14** |
| `profiler_ab_full_analysis.json` (`summary`) | 9 / 7 / 7 / 5 |
| `PROFILER_AB_RESULTS_20260715.md` | 9 / 7 / 7 / 5 |
| `SWEEP_..._20260720.md` §2.1, tallied row by row | 6 / 7 / 7 / 8 |
| `SWEEP_..._20260720.md` §2.2 | 9 / 6 / 5 / 8 |
| `SWEEP_..._20260720.md` §5.2 row | 9 / 7 / 5 / 7 |

§5.2's Same/NoData entries are transposed relative to the JSON artifact (5/7
where the JSON says 7/5), which propagates into that row's totals (10/11 rather
than 12/9). §2.2's named kernel lists do not cover its own §2.1 table — it omits
Game-of-Life from "worse" and DFT-1PE / Histogram-1PE from "same". And §2.1's
own Verdict column is not applied by a consistent rule: GEMV-Checkerboard
(2/10 vs 0/10) is `PROF↑` while Single-Tile-Matvec (1/10 vs 0/10) is `NoData`.

**None of the six matches a recount from the raw artifacts.**

### 1.2 The deeper problem: the "pass rate" is not a pass rate

`run_profiler_ab_full.sh:62` extracts each seed's result like this:

```bash
_cyc() { bj=$(ls -t "$1"/run_*/*/benchmark.json | head -1)
         python3 -c "...json.load(open('$bj')).get('cycles_send')..." }
```

No check on `status`, `success_marker`, or correctness — and the analyzer then
counts `len(p_vals)` as the pass count. So the published column is a
**produced-a-timer-reading rate**, not a pass rate. It also takes the *newest*
`benchmark.json`, which after `--auto-optimize` is the last optimizer trial
rather than the best or an accepted one.

The clearest casualty is **GEMV**: published as 10/10 profiled and 9/10
unprofiled, and used as a "profiling worse, +14.1%" datapoint. Recounting with
`status == "pass" AND success_marker == True`:

```
GEMV: 740 attempts across 20 runs -> success_marker=0, real passes=0
```

Every cycle number attributed to it came from `status:fail`,
`success_marker:false` runs whose reviewer notes read *"y is nonzero"*,
*"Output 100% wrong"*, *"rel diff"*. The rest of the project already knows this
— `TEMPLATE_SWEEP_RESULTS_20260723.md` lists GEMV's historical best as 0/10 and
notes "0/25 across all conditions". The profiler A/B table contradicts the
project's own record.

---

## 2. Per-kernel corrections (original 28)

| Kernel | Published | Recounted | Effect |
|---|---|---|---|
| **GEMV** | 10/10 vs 9/10, `UNPROF +14.1%` | **0/10 vs 0/10** | row is phantom |
| FFT-1D-2D | 8/10 vs 8/10, `SAME` | 2/10 vs 1/10 | 1-D stage prints SUCCESS, 2-D stage exits `rc=139` ("received length (0 bytes)… could be a kernel stall") |
| Power-Method | 8/10 vs 8/10, `UNPROF +13.4%` | 5/10 vs 7/10, medians 31407/31320 → `SAME` | verdict flips |
| Mandelbrot | 1/10 vs 1/10 | 0/10 vs 1/10 | |
| GEMV-Checkerboard | 2/10 vs 0/10, `PROF↑` | 1/10 vs 0/10 | |
| Histogram | 0/10 vs 0/10 | 1/10 vs 1/10 | correctness-only kernel, no timer |
| MSE-Loss-1PE | 1/5 vs 2/5, `NoData` | 5/5 vs 5/5 → `SAME` | error in the *under*-counting direction |
| RMSNorm-1PE | 4/5 vs 4/5 | 5/5 vs 4/5 | |

The enrichment sets are largely unaffected: 12 of 14 single-PE and 4 of 4
multi-PE kernels recount identically.

---

## 3. Corrected tallies (all 46 kernels, 740 runs)

Pass = `status == "pass"` **and** `success_marker == True`.

| Rule | Better | Worse | Same | NoData |
|---|---:|---:|---:|---:|
| **Strict** (cycle compare only when both arms have ≥2 real passes) | **7** | **8** | **11** | **20** |
| **Inclusive** (cycle compare, else pass-rate tiebreak) | **18** | **11** | **11** | **6** |

Neither reproduces the published 13/12, 14/11, or 9/7/7/5.

### Passing runs — the robust statistic

| Arm | Passing runs |
|---|---|
| Profiled | **147 / 370 (39.7%)** |
| Unprofiled | **142 / 370 (38.4%)** |

A 1.3-point difference across 740 runs.

---

## 4. The categorical split is not robust

The verdict counts move with the per-seed cycle estimator:

| Estimator | Better | Worse | Same | NoData |
|---|---:|---:|---:|---:|
| best passing cycles | 7 | 8 | 11 | 20 |
| last passing cycles | 9 | 7 | 10 | 20 |

The aggregate sign flips. Only 3 of 26 comparable kernels change verdict
(Residual, SpMV-CSR, Prefix-Sum-1PE), but with 7–9 "better" and 7–8 "worse",
three flips move the headline. **Do not report a better/worse count.**

### What is estimator-stable (23 of 26 kernels)

| Direction | Kernels |
|---|---|
| Profiling better | Jacobi-2D-5pt (−27.9%), Laplacian2D-Halo (−16.4%), PDFT-Pi-Pipeline (−18.9%), Cross-Entropy-Loss-1PE, Max-Reduction-1PE, SiLU-1PE, Sum-Reduction-1PE |
| Profiling worse | Stencil7pt-1PE (+114.7%), Wide-Multiplication (+27.4%), BiCGSTAB, Dot-Product-1PE, L2-Norm-1PE, Softmax-1PE, ParDot-Product |

---

## 5. Recommended wording

> Across 740 runs (46 kernels; 10 seeds for the original 28, 5 for the
> enrichment sets), profiler feedback changed the pass rate by 1.3 points
> (147/370 vs 142/370), within seed noise. Per-kernel cycle effects are
> strongly bimodal and estimator-stable for 23 of 26 comparable kernels:
> profiling improves multi-PE stencils and the program-level pipeline
> (Jacobi −27.9%, Laplacian −16.4%, PDFT −19%) and degrades single-PE
> compute-dense kernels (Stencil7pt +115%, Wide-Mult +27%). Profiling is a
> selective lever, not a universal one.

That claim survives all four rule variants.

---

## 6. Limitation: single-sweep pass rates are unstable

An independent N=10 replicate at `profiler_ab_full_20260706_172841` covers 4 of
the 28 kernels and disagrees materially with the published run:

| Kernel | 0708 (published) | 0706 replicate |
|---|---|---|
| DFT-1PE | 3/10 vs 1/10 | **10/10 vs 10/10, Same** |
| Cholesky | 2/10 vs 0/10 | 3/10 vs 4/10, Better on cycles (−86.6%) |
| FFT-1D-2D | 2/10 vs 1/10 | 4/10 vs 2/10 |
| 7pt-Stencil | 10/10 vs 10/10, Same | 10/10 vs 10/10, Same |

DFT-1PE moving 3/10 → 10/10 between identical-configuration runs is a large
seed/environment effect. Single-sweep pass rates on fragile kernels should be
treated as a lower bound, not a measurement.
