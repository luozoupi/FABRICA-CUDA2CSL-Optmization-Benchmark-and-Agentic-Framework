# jacobi2d_5pt — manual CSL validation bundle

Manual translation of the `jacobi2d_5pt` 5-point Jacobi PDE stencil into CSL
for the Cerebras WSE-3 simulator. Built by hand; no agent involvement.

## Algorithm

One iteration per `step()` invocation:

```
interior  (1 <= i <= H-2, 1 <= j <= W-2):
    B[i,j] = 0.25 * (A[i-1,j] + A[i+1,j] + A[i,j-1] + A[i,j+1])

boundary  (i in {0, H-1} or j in {0, W-1}):
    B[i,j] = A[i,j]    (preserved verbatim)
```

This is the textbook Jacobi PDE iteration form. The boundary policy is
**preserved**: outer-rim values are inputs, not computed.

## Decomposition (matches the issue's "plan")

| Aspect | Value |
|---|---|
| Mesh | 2 x 2 PE rectangle |
| Tile per PE | 4 x 4 cells |
| Global grid | 8 x 8 |
| Halo width | 1 |
| Communication | 4-color cardinal exchange (N / S / E / W) |
| Boundary | preserved (no compute on global edge rows/cols) |
| Iteration count | configurable; default 1 |

## Files

- `layout.csl` — PE grid, fabric color allocation, color routing (4 cardinal
  colors C_N / C_S / C_E / C_W; sentinel color 15 for edge PEs' missing
  neighbors).
- `pe.csl` — per-PE compute file. Tasks: `f_send` (stage halos + async fabric
  send/recv), `f_rx_done` (counter-based completion), `f_compute` (5-pt
  stencil with preserved-boundary policy), `f_exit` (cmd-stream unblock).
- `run.py` — host driver: builds deterministic input (`np.random.seed(7)`),
  computes numpy reference, cliff-distributes onto the mesh, launches
  `step(iters)`, reads back, compares.
- `commands_wse3.sh` — compile + simulator-run incantation.

## How to run

```bash
PATH="/home/USER/cs_sdk-1.4.0:$PATH" bash commands_wse3.sh
```

Pass `--iters N` (must edit the script or invoke `cs_python run.py --name out
--iters N` directly) for multiple Jacobi steps.

## Cerebras-side validation summary

See `../REPORT.md` for the canonical PASS/FAIL table.
