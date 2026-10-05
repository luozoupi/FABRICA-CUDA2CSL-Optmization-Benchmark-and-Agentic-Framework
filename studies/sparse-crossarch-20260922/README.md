# Sparse characterization from the NVIDIA GPU node

This contribution comes from the **NVIDIA RTX PRO 6000 Blackwell Server Edition node with the Cerebras SDK 2.10.1 simulator**. GPU timings were measured on that GPU. CSL timings are **single-PE WSE-3 simulator cycles**. This node has supplied no CS-3 hardware measurements for this study.

Start with [ANALYSIS.md](ANALYSIS.md), [RESULTS.md](RESULTS.md), or download and open [index.html](index.html) for the offline interactive comparison. The [PDF](comparison-figure.pdf) and [SVG](comparison-figure.svg) are exportable figures. [INTEGRATION.md](INTEGRATION.md) records branch reconciliation, provenance, packaging changes and the handoff to the hardware node.

This deterministic study measures scalar/descriptor CSL and cuSPARSE/official GE-SpMM implementations. It is separate from the fixed-budget DeepSeek/Luna experiments and establishes no agent success rate. GE-SpMM performs sparse–dense multiplication; it is not general sparse–sparse multiplication.

## Recorded evidence

| Evidence | Completed result |
|---|---|
| Primary GPU configurations | 124 workloads from 25 matrices |
| Primary GPU implementation cases | 804 accepted; 41 rejected by the fixed numerical gate |
| Extra GPU repetitions | Two further runs of seven selected configurations |
| Independent saved-output audit | 2,706 GPU output checks across 902 accepted implementation cases |
| CSL simulator builds | 12 compile; 8 fully accepted; 4 reach the 360-second run limit |
| Accepted simulator validation | 576 checked launches |

The unsuccessful GPU cases concern HB/bcsstk08 under the original FP32 tolerance. They remain in the completion counts and are excluded from performance comparisons. Simulator timeouts are retained; compilation alone does not prove correctness. [audit.json](audit.json), [results.json](results.json), [GPU CSV](gpu-results.csv), and [WSE CSV](wse-results.csv) preserve the results and sample ranges.

The measured environment used CUDA 13.0.88, driver 595.58.03, and cuSPARSE library 12.6.3.3. GPU operands were warm and resident; clocks were not fixed. CSL operands were resident in one PE's SRAM. Its interval includes output clearing and timestamps, but excludes host launch, transfer and fabric distribution. Do not form a GPU/WSE latency ratio from these two scopes.

## Verify the checkout

Run from the repository root with Python 3.10 or newer:

```bash
python3 studies/sparse-crossarch-20260922/verify_snapshot.py
```

This checks package hashes, measured kernel/host source hashes, the exact GE source extraction, frozen input manifests and summary consistency. It does not rerun device correctness tests. The historical `handoff-manifest.json` records the original node files; `packaging-manifest.json` records the files shipped here and identifies each portability/documentation change. The original protocol and measured kernels are unchanged.

## Prepare a fresh replay

Install NumPy and SciPy in your usual experiment environment. Preparation refuses an existing output directory and checks every reconstructed binary input against its frozen SHA-256. The default reconstructs the 24 small shared workload inputs and all 12 CSL configurations:

```bash
python3 studies/sparse-crossarch-20260922/prepare_replay.py \
  --out /tmp/sparse-replay-20260922 --inputs shared-wse
export CEREBRAS_SDK_DIR=/path/to/directory/containing/cslc-and-cs_python
python3 /tmp/sparse-replay-20260922/run_wse.py --only descriptor-n4
```

`CEREBRAS_SDK_DIR` must contain executable `cslc` and `cs_python` launchers. One SDK job runs at a time through `/tmp/xkernel_singularity.lock`. The run limit remains 360 seconds per phase. A changed limit or validation protocol creates a new experiment version. Replay results belong in the fresh directory; the committed directory is a recorded snapshot. The SDK container is not distributed here.

For a GPU replay, prepare another directory using `--inputs all` (several GB of storage), then:

```bash
python3 /tmp/sparse-gpu-replay/build_gpu.py
python3 /tmp/sparse-gpu-replay/run_gpu.py --device 0 --out gpu
python3 /tmp/sparse-gpu-replay/run_gpu.py --device 0 \
  --manifest inputs/capacity-manifest.json --out gpu-capacity
```

Replace the example directory and GPU ID with the prepared directory and an available GPU. `NVCC` can select the compiler; the recorded `sm_120` target and optimization flags remain explicit. Another GPU architecture requires a documented build configuration change. The pinned GE source and MIT license are included under `vendor/ge-spmm/`; no nested Git checkout or network access is needed to build. Fresh binary hashes must be recorded even with identical sources.

The scripts for collection, plotting and profiling are supplied for new complete runs. Do not regenerate frozen tables from a partial replay. Nsight profiling scripts retain the original `/usr/local/cuda/bin` tool location and require profiling access. Plotting used Matplotlib 3.11.2; browser validation used Chrome, requests and websocket-client. `finalize.py` and `make_hardware_bundle.py` document the original node export and are not copied into fresh replays because their original paths/revisions are historical.

## Raw artifacts and hardware replay

Large GPU outputs, binary profiler reports, compiled ELFs and the SDK image remain outside Git, following the repository's collaboration rules. Their original location is `/home/USER/sparse-crossarch-20260922/` on the NVIDIA node. These files have not been deleted.

The compact `wse-hardware-replay.tar.gz` remains at that location: **1,579,159 bytes**, SHA-256 `cf9b5c1cc0582ebba8799a86d03ab052865c73ce0fc037f5a6d78fedc53eab24`. [hardware-bundle-manifest.json](hardware-bundle-manifest.json) lists all 862 members and their hashes. Transfer it separately when exact measured ELFs and checked output copies are needed. A source rebuild is a new build, even when its source hashes match.

[HANDOFF.md](HANDOFF.md) records the completed study and requested hardware measurements. On the WSE-3 node, use its established hardware launcher in a separate output directory, retain the same correctness sessions, and record compiler, device clock, preparation, communication and launch scope. The host supports `--cmaddr`; access to a CS-3 system and its deployment configuration is still required. Record both accepted and failed cases, then return outputs and build hashes for independent replay. Hardware results are pending.

## Earlier dataflow work

The local interactive lab remains at `/home/USER/matrix-dataflow-lab.html`; its large supporting traces are not part of this commit. The [earlier matmul findings](supporting/earlier-matmul-FINDINGS.md), [tables](supporting/earlier-matmul-RESULTS.md), and [protocol](supporting/earlier-matmul-PROTOCOL.md) are included as separate supporting evidence. Their 16-square inputs must not be substituted into the new 32-by-64 sparse tables. The new explorer reconstructs row computations from recorded inputs; it does not claim those animations are measured fabric traces.
