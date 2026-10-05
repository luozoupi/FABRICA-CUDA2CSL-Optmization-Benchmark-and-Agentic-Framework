# Excluded-Task Audit and Port (2026-08-06)

## Why this exists

`kernels/` holds 59 entries → 55 directories → **54 kernel tasks** (`benchmark-libs`
is the shared CSL library, not a task). Of those, **50** are addressable by the
harness (`KERNEL_REGISTRY` in `code_translation/cuda2csl.py`) and **46** appeared in
the 2026-07-22 full template sweep. This document accounts for the 8-task gap and
records what was done about it.

The gap is **not** neutral with respect to difficulty: 7 of the 8 excluded tasks are
multi-PE or library-delegated. The instrumentation requirement ("does this kernel
have a WSE-3 build with a working timer and an enabled verifier?") systematically
removes the hardest fabric-routing work from the denominator, which biases any
suite-level pass rate upward. That caveat belongs in any write-up of the 35/46
headline.

## Status after this session

| Kernel | Prior blocker | Now |
|---|---|---|
| GEMM-1PE | none — omission | **Enabled.** 119,197 cycles |
| Laplacian2D-Reduce | `VERIFY=False` skeleton | **Enabled.** Fixed + instrumented, 1,950 cycles |
| LorenzoPredictor-Tile | `VERIFY=False` skeleton | **Enabled.** Rewritten + instrumented, 1,315 cycles |
| MC-Particle-Transport | missing build deps, WSE-2, non-reproducible RNG | Still excluded |
| 25-Point Stencil | WSE-2 only | Compiles on WSE-3; blocked on queue exhaustion |
| SpMV | WSE-2 only | Compiles on WSE-3; blocked on switch/control wavelets |
| SpMV Hypersparse | WSE-2 only | Byte-identical to SpMV — same blocker |
| 3D FFT | no compute surface | Still excluded (by design) |

Suite is now **49 registered / 49 swept** for the template sweep list
(`run_full_template_sweep.sh`), up from 50 registered / 46 swept.

---

## Enabled

### GEMM-1PE — was never actually broken

`commands_wse3.sh`, a `run.py` that prints `cycles_send`, and a `spec.yaml` carrying a
validated WSE-3 reference of 119,197 cycles (`difficulty: 1`, `task_class:
real-translation`, TEST split). Authored 2026-06-24 as the leak-free single-PE
counterpart to the SUMMA GEMM, and then never added to a sweep list —
`grep -l GEMM-1PE run_*.sh` returned nothing. Rebuilt this session and reproduced
119,197 cycles exactly.

### Laplacian2D-Reduce — inverted reduction predicate

`layout.csl` assigns the NRM transmit color to every PE that is **not** on the north
edge (`tx_nrm_c = if (is_n) none else NRM`) and the receive color to every PE not on
the south edge. `pe.csl` keyed the send off `!is_s_edge` and the merge off `is_s_edge`
— exactly inverted. On the 2×2 mesh that meant the sending PE had no TX color and the
receiving PE had no RX color, so the cross-PE max reduction never ran. That is why the
kernel shipped with `VERIFY=False`.

Fixed by keying both off `is_n_edge` to match the layout, then adding the standard TSC
instrumentation (`f_tic`/`f_toc`/`f_memcpy_timestamps`/`f_enable_timer` + `time_buf_u16`
export, same idiom as the sibling Laplacian2D-Halo). `run.py` now draws its input from
a seeded RNG (`XKERNEL_EVAL_SEED`) and asserts against numpy.

Verified exact (abs err = 0.000e+00) on the train seed and all three held-out seeds;
cycles 1,950–1,952 (±2 run-to-run).

### LorenzoPredictor-Tile — two independent defects

Lorenzo prediction is `residual[i,j] = A[i,j] - (A[i-1,j] + A[i,j-1] - A[i-1,j-1])`,
which needs the west neighbour's rightmost column, the north neighbour's bottom row,
and the northwest neighbour's bottom-right scalar.

1. **Row color routed backwards.** `layout.csl` routed `C_N` as `(px,1) rx RAMP → tx
   NORTH` / `(px,0) rx SOUTH → tx RAMP` — data travelling *north*. Lorenzo needs the
   north neighbour's data to reach the south PE, i.e. data travelling *south*. The
   source comments admit the confusion in place ("Skeleton-level: don't try to be too
   clever… this is wrong direction").
2. **NW scalar hard-wired to zero.** `halo_nw` was never exchanged, so PE(1,1)'s (0,0)
   cell used 0 instead of PE(0,0)'s bottom-right element.

Rewritten as a two-phase exchange. Phase 1 sends columns east; phase 2 sends
`[nw_scalar, bottom_row]` south, where the prefix scalar is `halo_w[Mt-1]` — the last
entry of the sender's own west halo, which *is* the NW corner the receiver needs. No
third color required; phase 2 must follow phase 1 because the sender cannot build its
buffer until its column halo has landed.

Verified on the train seed and all three held-out seeds (max abs err ≤ 9.5e-7);
1,315 cycles, deterministic across seeds.

**Verifier note:** the original `run.py` used `np.arange` as input. Lorenzo's residual
is identically zero on the interior of a linear field, so an all-zeros kernel would
have passed. Switched to a seeded random field so the interior actually discriminates.
This is the same class of weak-verifier problem as the Cholesky `decimal=2` false pass.

---

## Still excluded, with the specific blocker

### 3D FFT — no compute surface (by design)

`CSL/layout.csl` is 24 lines and its entire body is
`fft_helper.FFT_kernel(WIDTH, N, tensor_type)` against `<kernels/fft/fft3d_layout>`.
There is no per-PE compute file for an agent to author, so as a translation task it is
degenerate. The project already made this call: DFT-1PE is documented in
`KERNEL_REGISTRY` as "the real-translation counterpart to the FFT-library-delegated
3D-FFT / FFT-1D-2D". Keep excluded; it is a library-binding exercise, not a
translation task.

### SpMV and SpMV Hypersparse — one kernel, two directories

`diff -rq "SpMV/CSL/src" "SpMV Hypersparse/CSL/src"` is empty: the CSL trees are
**byte-identical**, and the two `run.py` files differ only in an assert message. Only
the CUDA sources differ. They are the same kernel under two names, and both delegate
their compute to `hypersparse_spmv/pe.csl` + `allreduce2R1E/pe.csl` — SpMV-CSR is
already the hand-written translation counterpart.

WSE-3 port progress: two blockers found, one fixed.

1. **Fixed** — `src/kernel.csl:84` set `input_queues = {4, 1, 6, 7}`; queue 1 is
   memcpy's reserved command queue on WSE-3 (`memcpy.csl` asserts
   `input_queue_cmd_id == 1`). Remapping to `{4, 3, 6, 7}` compiles.
2. **Blocking** — the library deliberately multiplexes **two colors onto one output
   queue**: queue 2 carries both `north_train` (TX_NORTH_Q) and `tx_west_train`
   (TX_WEST_Q); queue 3 carries `south_train` and `tx_east_train`. Legal on WSE-2,
   where the color rides in the wavelet. On WSE-3 `@initialize_queue` statically binds
   one queue to one color, so a 2-color queue is not expressible. Splitting into four
   queues (2,3,4,6) with per-color init compiles but still stalls at runtime, because
   the send path also uses **switch/control wavelets** (`tx_*_ctrl_adv_dsd` with
   `pos1`/`pos2`/`pos3` and `pop_on_advance`), whose semantics changed on WSE-3.

Finishing this is a re-architecture of the vendored collective, not a config change.

### 25-Point Stencil — fabric queue exhaustion

Two blockers cleared, one hard.

1. **Fixed** — task IDs must be in `[8,31)` on WSE-3; `layout.csl` used 3 (`send`) and
   2 (`COMP`). Probing showed memcpy reserves 21, 27, 28, 30 and that 29 is the
   teardown ID; 22 and 23 are free. With `COMP=22`, `send=23` the bundle **compiles
   cleanly on WSE-3**.
2. **Fixed** — `oned_exch.csl` used `output_queue = queueId` with `queueId ∈ {0,1,2,3}`;
   0 and 1 are memcpy-reserved on WSE-3. Remapped to `2 + queueId` and added the
   required comptime `@initialize_queue` for both directions.
3. **Blocking** — runtime dies with
   `P5.8: trying to term ut_instr[4], but it's not ours`. The four direction buses need
   4 input + 4 output fabric queues = 8, and the async microthread space is shared
   between them. After memcpy takes 0 and 1, only 6 are available. Sharing a queue
   across two directions is not possible for the same reason as SpMV:
   `@initialize_queue` binds one color per queue.

Resolving this means restructuring the 4-direction exchange into phases that reuse
queues (changing the kernel's performance characteristics, and therefore its value as
a *reference* baseline).

### MC-Particle-Transport — missing deps and non-reproducible results

- `CSL/` ships `device_code.csl` (1126 lines), `device_layout.csl`, `host_code.py`
  (856 lines), and `commands_wse3.sh`, but **not** `compile.py` or the `sdkwrapper`
  module that `host_code.py` imports — neither was ever vendored.
- `KERNEL_REGISTRY` pins `"arch": "wse2"`.
- `VALIDATE_RESULTS = False`, and the README notes validation additionally requires
  uncommenting several blocks and can take up to an hour.
- Stochastic interpolation uses the Cerebras hardware PRNG, which the README states is
  "not reproducible on the host" — so a host-side reference cannot be computed for the
  default configuration.

The last point is the real one: without host-reproducible output there is no verifier,
and without a verifier the task cannot be scored under this benchmark's rules.

---

## Suite bookkeeping updated

- `kernels/Laplacian2D-Reduce/spec.yaml`, `kernels/LorenzoPredictor-Tile/spec.yaml` — created
- `kernels/baselines_wse3.json` — added GEMM-1PE, Laplacian2D-Reduce, LorenzoPredictor-Tile;
  refreshed the stale `kernels_without_cycle_instrumentation` list, which still named
  FFT 1D-2D, GEMV Checkerboard, Histogram, Mandelbrot, and Single Tile Matvec — all five
  were instrumented in earlier sessions and are in the active sweep
- `run_full_template_sweep.sh` — 46 → 49 kernels

Still stale and worth fixing separately: `kernels/BENCHMARK.md` says "**27 kernels**"
and is stamped v1.0 / 2026-06-01.

## Addendum (2026-08-07): five kernels cannot reach the cluster at all

Separate from the WSE-2 porting issue above, five kernels that run fine on the
local SDK 1.4.0 simulator cannot be compiled on the cluster, because the
appliance uses SDK 2.10 and they depend on `kernels/benchmark-libs`:

    7pt-Stencil, BiCGSTAB, CG, Preconditioned-CG, GEMM-Collectives-2D

Two independent blockers, both in the shared library rather than the kernels:

1. **Return-type syntax.** The libraries declare
   `fn get_params(px:i16, py:i16) comptime_struct { ... }`. SDK 2.10 rejects
   `comptime_struct` there ("use of undeclared identifier"), and the mechanical
   porter's substitution to `anytype` is *also* rejected ("Unexpected character
   at this location"). The correct 2.10 spelling was not determinable from any
   locally available source -- the appliance venv ships no CSL, and the 1.4.0
   container naturally still uses the old form. Establishing it needs the
   cluster toolchain's own libraries or vendor documentation.
2. **`@concat_structs` removed.** `GEMM-Collectives-2D/pe.csl` calls it; the
   porter only inlines that builtin inside *layout* files, and in `pe.csl` its
   arguments are params rather than in-file consts, so the existing inliner
   cannot resolve them anyway.

**This costs the hardware study nothing.** All five use the
`host_launched_tic_toc` timing pattern, so their hardware measurements would
have been excluded from the comparable population regardless (see
[`HW_VS_SIM_20260806.md`](HW_VS_SIM_20260806.md)). The comparable set is
complete at n=25 with or without them.

Fixing this is a genuine SDK 1.4.0 -> 2.10 migration of `benchmark-libs`, not a
regex pass. It only matters if these kernels are ever to be measured on
hardware -- which additionally requires re-instrumenting them to time inside a
single device launch.

## Reproducing

The Cerebras SDK runs under apptainer, which refuses to start when the calling uid has
no `/etc/passwd` entry. `unshare -r` maps the caller to uid 0 inside a new user
namespace, which resolves; it creates only a USER namespace, so networking is
unaffected. `run_cuda2csl_anthropic.sh` applies it automatically when needed.

```bash
cd "kernels/Laplacian2D-Reduce/CSL"
unshare -r bash -c 'export PATH=$HOME/cs_sdk-1.4.0:$PATH; bash commands_wse3.sh'
```
