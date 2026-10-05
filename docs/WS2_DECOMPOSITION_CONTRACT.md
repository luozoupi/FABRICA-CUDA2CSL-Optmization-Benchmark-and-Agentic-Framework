# WS2 — Free the decomposition: the logical-contract run.py design

**Status:** design + GEMV proof (2026-06-20). Gate: justified by the WS1.2
crossover (GEMM/GEMV overflow at small mesh → decomposition is mandatory at the
large size, so letting the AGENT choose the decomposition is now meaningful).

## Problem (what the current run.py leaks)
Today's `run.py` hard-codes the PHYSICAL distribution. Example — GEMV
`run.py:99-110` reshuffles the logical matrix into the reference's exact 4×4
cliff/cliff PE layout:
```python
data = np.stack(np.split(np.stack(np.split(A, kernel_cols, 1)), kernel_rows, 1)).ravel()
runner.memcpy_h2d(symbol_A, data, 0,0, kernel_cols, kernel_rows, per_pe_rows*per_pe_cols, ...)
```
The agent's CSL must match THIS distribution, so it cannot explore a different
decomposition (e.g. 2-hop systolic vs SUMMA, or a different tile shape). At tiny
sizes that's invisible; at the large size it's the whole game.

## Design: split run.py into LOGICAL contract + PHYSICAL adapter
- **Logical contract (IMMUTABLE, harness-owned):** build the logical tensors,
  compute the NumPy reference, launch the fixed entrypoints in the timed window,
  verify (multi-seed), read worst-PE cycles. The ONLY contract is:
  - fixed host-visible symbol names: `A`, `x`, `b`, `y`, `time_buf_u16`
  - fixed launch entrypoints: `f_enable_timer, f_tic, main, f_toc, f_memcpy_timestamps`
  - logical shapes (matrix_rows × matrix_cols etc.) — NOT the PE mapping.
- **Physical adapter (AGENT-GENERATED, one coupled unit with layout+compute):**
  a module `distribution.py` exposing:
  ```python
  def grid() -> tuple[int,int]:                 # (kernel_cols, kernel_rows) the agent chose
      ...
  def distribute(name, host_array, dims) -> (flat, w, h, elems_per_pe):
      # logical tensor -> the flat h2d payload + memcpy geometry for THIS decomposition
  def collect(name, dims) -> (out_w, out_h, out_x, out_y, elems):
      # where/how to read the result back for THIS decomposition
  ```
  `run.py` imports this adapter and calls it instead of hard-coding the reshuffle.
  The agent emits `distribution.py` + `layout.csl` + the compute file together —
  they're one decomposition. WS5 multi-seed verification lives in the logical
  contract (loop N seeds, re-h2d via adapter, re-launch main, re-d2h+verify).

## layout.csl templating (holes, not whole-cloth)
Pre-fill the CONTRACT parts (memcpy reservations, reserved-color rules, the
host-visible `@export_name` symbol decls, the timer entrypoints); expose the
ALGORITHMIC parts as labeled holes: `// <<HOLE: user_colors>>`,
`// <<HOLE: routing>>`, `// <<HOLE: grid set_rectangle>>`,
`// <<HOLE: tile_code>>`. Generating a full layout from zero is where deadlocks
+ SRAM overflow live; holes keep pass-rate survivable while still removing the
decomposition leak (the agent fills grid/routing/tile-code = its decomposition).

## Rollout
1. GEMV proof: extract the cliff-distribution into `distribution.py` (reference
   decomposition), make run.py call it, confirm small+large still SUCCESS — this
   proves the seam without changing behavior.
2. Then the agent-generated path: in W1 translate at `--size large`, the agent
   emits distribution.py + holed-layout + compute; run.py (logical) drives it.
3. Generalize to the other valid-large kernels (GEMM, 7pt, Laplacian).

## GEMV proof result (2026-06-20)
The seam works and is behavior-preserving:
- Extracted the cliff-distribution into `kernels/GEMV/CSL/distribution.py`
  (distribute/collect/grid); `run.py` now imports it instead of hard-coding the
  reshuffle. Logical contract = build A/x/b, reference y=A@x+b, verify, read
  worst-PE cycles; only symbols (A,x,b,y,time_buf_u16) + entrypoints are fixed.
- GEMV small: SUCCESS 4007 (== original). Different seed (99), fresh program:
  SUCCESS 4007 — so the kernel is genuinely correct across inputs, not overfit.

## MULTI-SEED LESSON (WS5.3, learned here)
First attempt looped N seeds in ONE program load (re-launching `main`). It FAILED
100% of elements on seed 2+ — collective kernels' `main()` is NON-IDEMPOTENT
(scatter/DSR state is consumed by the first launch and not re-armed). The WS5
multi-seed discipline CAUGHT this. Correct design: multi-seed = run the whole
program once PER SEED (fresh load), driven from the commands script
(`run.py --seed 7/8/9`), with run.py doing a single timed launch. This is now
the GEMV pattern and the template for the other kernels.

## WS2b — agent-generated decomposition (end-to-end proof, GEMV-large)
Driver: code_translation/_ws2b_agent_decomp.py. One real opus-4-7 call,
FIREWALLED (sees CUDA + task + the HOLED template + the logical run.py +
library signatures; NOT the reference pe.csl/layout.csl/distribution.py). It
emits THREE artifacts — its OWN decomposition:
  ```distribution (host distribute/collect/grid)  ```layout (filled template)  ```pe
Staged + compiled + run at the LARGE size (512x256, 8x8) via the logical run.py,
multi-seed, scored vs the human reference (10309). This is the decisive test:
can the agent freely choose a decomposition that compiles, verifies, and competes
at a size where decomposition is mandatory? (Result appended once the run lands.)
NOTE: keep the driver OUT of /tmp — a stray /tmp/inspect.py shadows stdlib when
Python adds the script dir to sys.path[0].

## Firewall note
The reference `distribution.py` (extracted in step 1) is part of the bundle the
W1 agent does NOT see (same status as the reference pe.csl) — it's the reference
decomposition. The agent writes its OWN distribution.py. The logical contract
run.py IS shown (it's the launch protocol, like today).
