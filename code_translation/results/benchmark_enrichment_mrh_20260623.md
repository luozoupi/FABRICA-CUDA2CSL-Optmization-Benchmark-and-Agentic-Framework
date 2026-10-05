# Benchmark enrichment from mrh/gpu — new op family + program-level tier (2026-06-23)

**Source.** `MatthewRHermes/mrh` `gpu/` (GPU-accelerated quantum chemistry:
LASSCF/CASSCF/PDFT via PySCF). Read the real `__global__` kernels from
`gpu/src/pm/device_cuda.cpp` and the op taxonomy from `gpu/src/device.h`. Two
manually-authored (CUDA, CSL) pairs added, both cleared the FULL run+verify bar on
WSE-3 (compile + numpy correctness + cycles_send), same as every existing kernel.
External source — not a WaferLLM/KB pattern source, so no leakage into the agent's
own translation.

## 1. Tensor-Transpose-021 — a NEW single-kernel operation family
- From mrh `_transpose_021` ("abc->acb"): `B[i][k][j] = A[i][j][k]`, pure index
  permutation (`in=(i*ax2+j)*ax3+k`, `out=(i*ax3+k)*ax2+j`). No transpose kernel
  existed in the suite before.
- Single-PE CSL (mirrors Single-Tile-Matvec timing idiom). Verified: **6,183 cyc,
  SUCCESS** (bit-exact `assert_array_equal` vs numpy `A.transpose(0,2,1)`).
- group: tensor, task_class: real-translation, split: test, difficulty 1.

## 2. PDFT-Pi-Pipeline — the FIRST program-level task (harder difficulty tier)
- From mrh PDFT kernels (`_make_gridkern` / `_make_buf_pdft` / `_make_Pi_final`).
  On-top pair density `Pi[g] = k_g^T W k_g`, `k_g = outer(mo_g, mo_g)` — a
  quadratic form computed as THREE data-dependent stages:
  1. gridkern[g][a] = mo[g][j]*mo[g][k]   (outer product)
  2. buf[g][b] = sum_a gridkern[g][a]*cascm2[a][b]   (contraction)
  3. Pi[g] = sum_b gridkern[g][b]*buf[g][b]   (reduction)
- **`task_class: "program-level"`** (new): the CUDA is multiple data-dependent
  kernels; the agent must translate the whole pipeline + its intermediate buffers
  (gridkern, buf), not one kernel. New schema field `stages:` documents the
  data-flow. Verified: **128,308 cyc, SUCCESS** (`assert_allclose` vs numpy einsum
  quadratic form). group: qc-pdft, split: test, difficulty 3.

## 3. Capstone — the full agentic loop works on the new content
Firewalled W1 translate + W2 optimize on Tensor-Transpose-021 (agent never sees
the CSL reference; XKERNEL_HARD_KERNEL_HINTS + frozen-splice on, cap 8/6):
- **Translate (from CUDA):** passed FIRST attempt at 6,183 (parity). Firewall
  held (0 compute-leak trips). code_similarity 0.27 → genuinely independent code.
- **W2 optimize:** 6,183 → 1,760 (`dsd_offset_chaining`) → **700** (`comptime_cleanup`)
  = **8.8× over the human reference**.
- **Independently re-verified** in a clean bundle: 700 cyc, SUCCESS (bit-exact).
  Artifact: results/benchmark_enrichment_artifacts/transpose021_capstone_700cyc_verified_pe.csl.

**This proves the added kernels are well-posed agent tasks, not just files:** the
pipeline translates them correctly from CUDA AND beats the reference — the
complete translate→optimize arc, validated on freshly-added real scientific code.

## Schema / wiring / docs
- SPEC_SCHEMA.md: documented `task_class: "program-level"` + optional `stages:`.
- cuda2csl.py KERNEL_REGISTRY: both kernels registered + smoke-checked.
- SPLIT_AND_LEAKAGE.md: both added to the held-out test split + the mrh external-
  source/leakage-clean note.
- PAPER_METHODOLOGY.md: benchmark-enrichment note (new family + program-level tier).
- Integrity: both pass the timing-integrity linter + dead-timer guard (real
  enable_tsc, cycles ≥ floor); 74 unit tests green.

## Out of scope (next round)
Heavier mrh families: getjk gather/scatter (index-map), full ao2mo
(transpose→gemm→transpose), FCI/RDM kernels; multi-PE / large-size versions of
the two new kernels (started single-PE + small for a clean verify).
