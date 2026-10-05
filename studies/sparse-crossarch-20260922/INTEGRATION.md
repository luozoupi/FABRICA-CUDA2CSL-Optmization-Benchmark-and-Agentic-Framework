# NVIDIA-node integration and handoff — 2026-09-22

## Origin and branch reconciliation

This work was produced on the NVIDIA RTX PRO 6000 Blackwell Server Edition node with Cerebras SDK 2.10.1. CUDA/cuSPARSE/GE-SpMM times are measured GPU results; all new CSL results are WSE-3 **simulator** results. No new CS-3 hardware evidence or API-model experiment is claimed.

Fetched before preparing this contribution:

| Repository / branch | Checked remote commit |
|---|---|
| xkernel `v2_0` — integration base | `a6397750c1f2a00bfd47d829206b5865c1f87a05` |
| xkernel `sparse_ipdps` — other node's current experiment work | `04e83a442b7041481a7c8972ee559c0dec9e3b75` |
| Paper `main` | `d1f9e720642fd030f0a7e1ec8334975ceeb4a99e` |

The integration uses a new worktree and branch based on the current `origin/v2_0`. The existing local worktree and its uncommitted SDK/provider changes are preserved. The contribution adds a standalone study and a README entry; it does not merge the divergent sparse-study framework or modify the manuscript, frozen reference kernels, optimizer budgets or model outputs. The framework checkout used when collecting the study was `c7ad437d80de5b3f077a15576cfbaca18112e657`; the protocol and original handoff retain that historical identity.

The final pre-push fetch found new sparse-branch commit `04e83a4`, which adds the Luna repeat results to `docs/IPDPS_PREREG.md`, `docs/SPARSE_ON_WSE.md`, and three curated CSVs. Its five changed paths do not overlap this contribution. That report is acknowledged here; its artifacts were not independently audited in this packaging task. The current sparse branch's optimizer repeats and contract corrections remain its own work. This study's deterministic implementation comparisons cannot be pooled with those model experiments. The user requested publication to `v2_0`; the other node can incorporate this additive study in its usual reconciliation without replacing its framework changes.

## What this commit preserves

- Protocol and capacity amendment; input manifests and original Matrix Market sources.
- GPU and CSL source/host/layout files, unchanged from measured builds; exact official GE kernel extraction with its upstream commit and MIT license.
- Curated results, timing samples, fixed-gate failures, independent audit summary and offline explorer.
- Compiler comparison and profiler counter evidence, including failed/unsupported counter diagnostics.
- Hashes and locations of raw outputs, exact ELFs and the compact hardware replay archive retained on the NVIDIA node.

No credentials, API response corpus, SDK distribution, bulk binary output or generated executable is included. This batch made no model API calls. The requested retention of model-generated artifacts for later SFT/GRPO remains a separate framework requirement; this deterministic characterization is not such a training corpus.

## Packaging changes

The original study outside Git remains unchanged. `packaging-manifest.json` records the original and packaged hashes, with reasons for modified files. Scientific kernel bodies, validation hosts, fixed tolerances, recorded counts and the frozen protocol have not changed.

The package updates documentation and explorer navigation, makes the original input source path local to the study, and permits `CEREBRAS_SDK_DIR` / `NVCC` configuration. GPU build provenance comes from a hash-checked pinned source record rather than a nested vendor Git checkout. The disassembly parser is copied from the existing `v2_0` tool so fresh replays can find it without this node's worktree paths. Its source hash is recorded. Original profiler logs are included as `.txt` evidence under the same subdirectories, avoiding the repository's generic log exclusion. Local Git attributes preserve original byte sequences and exempt only the six frozen files with pre-existing whitespace from whitespace cleanup.

`prepare_replay.py` reconstructs inputs from the frozen manifests, verifies their byte hashes, and verifies the regenerated CSL source/configuration hashes before any device run. `verify_snapshot.py` provides a CPU-only integrity check. Fresh output directories prevent accidental replacement of the recorded snapshot. Historical export scripts and absolute paths in recorded result metadata describe the original run, not portable commands.

## Handoff to the WSE-3 node

Completed here: 124 primary GPU workloads; 804 accepted and 41 rejected implementation cases; 14 additional workload runs; 12 compiled CSL configurations, 8 fully accepted and 4 timed out. The independent audit covers 2,706 GPU outputs and 576 simulator launches. No jobs from this characterization are pending or running.

Next actions on the hardware node:

1. Replay the width-1/4/16 accepted CSL cases with the unchanged validation sessions, using the retained exact archive where supported or recording a new build.
2. Resolve the width-64 and scalar-width-16 simulator timeouts with hardware measurements; retain failures instead of inferring correctness from compilation.
3. Test distributed SpMV/SpMM with capacity, load balance and operand locality considered together. The partition tables here are static predictions, not fabric measurements.
4. Return source/build/input hashes, outputs, timestamps, clock identity, timing scope and all failed/infeasible points for independent audit.
5. Integrate manuscript claims only after hardware evidence is available. The paper base for this handoff is the commit above; manuscript integration remains with the other node.

The most useful current findings are width-dependent descriptor benefit, a source-level descriptor-hoisting change that leaves the compiled loop and timing unchanged, GPU row-cache overhead despite reduced load requests, and the tradeoff between nonzero balance and operand replication. These motivate controlled hardware experiments; they do not establish a general WSE-versus-GPU speedup.

## Integration validation

The snapshot check passed. Fresh reconstruction matched every frozen input hash for all 124 workloads and all 12 CSL source/configuration records; the 24-case shared-only preparation also passed. The packaged CUDA harness rebuilt successfully for `sm_120` with CUDA 13.0.88. Python syntax, local Markdown links, staged inventory and the repository secret scan passed. See [packaging-validation.json](packaging-validation.json). These are packaging checks; they do not add performance observations or rerun the full numerical audit.
