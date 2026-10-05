# xkernel
Agentic Kernel Mapping: LLM-Based Porting from GPUs to Emerging Accelerators

xkernel is an LLM-agent framework that translates CUDA kernels to Cerebras CSL,
verifies them in the Cerebras SDK simulator (and on WSE-3 hardware), and
optimizes correct kernels for device cycles, together with a paired CUDA/CSL
benchmark suite. The workshop paper describing it is
[Fabrica: Agentic CUDA-to-CSL Translation and Optimization for Wafer-Scale Systems](https://arxiv.org/abs/2608.25124)
(AgenticAI4HPC'26 at SC26).

## Quick start

See **[SETUP.md](SETUP.md)** for a fresh account (SDK location, micromamba
environment, Argo / Anthropic / OpenAI routes, smoke run),
**[docs/EXPERIMENT_RUNBOOK.md](docs/EXPERIMENT_RUNBOOK.md)** to run cells of the
current model-guided optimization study on your own account and Argo key, and
**[COLLABORATION.md](COLLABORATION.md)** for the ground rules when two accounts
share the work.

```bash
~/bin/micromamba create -y -n xkernel-agent -f code_translation/environment.micromamba.yml
bash run_cuda2csl_argo.sh --check-env                     # Argo via argo-shim
bash run_cuda2csl_argo.sh --kernel ReLU-1PE --turns 4 --reviewer-max-attempts 10
# Argo-only handoff: generate one unverified CSL candidate without an SDK
bash run_cuda2csl_argo.sh --kernel ReLU-1PE --generate-only \
  --output code_translation/results/argo_handoff
```

`--generate-only` runs the analysis, architecture, and initial implementation
LLM calls, then stops before every Cerebras SDK probe, compile, simulation,
repair, reference measurement, and optimization step. Its `benchmark.json`
status is `unverified`; a collaborator with the SDK must compile and run the
saved compute file before treating it as a result.

All launchers source `xkernel_env.sh`; site paths (`XKERNEL_SDK_ROOT`,
`XKERNEL_MICROMAMBA`, proxies) and credentials (`ANTHROPIC_API_KEY`,
`ARGO_API_KEY_FILE`, `ANTHROPIC_BASE_URL`, `OPENAI_KEY_FILE`) are environment
variables; nothing machine-specific is hard-coded.

## Layout

| Path | Contents |
|---|---|
| `code_translation/` | the agent (`cuda2csl.py`), prompts, knowledge base, benchmark staging (`benchmark_csl.py`), profiling, hardware replay, aggregation and tests |
| `kernels/` | the paired CUDA/CSL benchmark: `spec.yaml`, CUDA source, validated CSL bundle per task; `BENCHMARK.md`, `SPEC_SCHEMA.md`, `baselines_wse3.json` |
| `knowledge/` | retrieval corpus (SDK docs, tutorials, skills; tracked) and the explored-experience ledger |
| `docs/` | methodology (`PAPER_METHODOLOGY.md`), sweep write-ups, hardware-vs-simulator study, audits, `docs/data/*.csv` |
| `studies/wse3-characterization/` | silicon-validated WSE-3 performance model: microbenchmarks, cost models, bottleneck classifier, `FINDINGS.md` |
| [`studies/sparse-crossarch-20260922/`](studies/sparse-crossarch-20260922/README.md) | NVIDIA GPU node study: measured cuSPARSE/GE-SpMM timings, Cerebras SDK 2.10.1 simulator results, dataflow explorer and hardware replay handoff |
| [`studies/sparse-progress-20260923/`](studies/sparse-progress-20260923/README.md) | Reconciled online/local progress, paper-number audit, missing hardware coverage and next contributions |
| `run_*.sh` | sweep entry points (serial, resumable) |
| `scripts/` | maintenance scripts (secret scan, archived A/B drivers) |

Knowledge-access rules for the agent (what it may and may not see) are in
`code_translation/FIREWALL.md`. Results directories are git-ignored.

## License

BSD 3-Clause, see [LICENSE](LICENSE).

---

## Project Description: 
Our project develops and evaluates an LLM agent‑based pipeline that coordinates both traditional HPC kernels and AI kernels across heterogeneous accelerator systems for scientific workloads. ALCF resources are essential because we need access to multiple, architecturally diverse AI accelerators and a high‑performance shared storage system to systematically benchmark, co‑design, and scale this pipeline beyond what is possible on local clusters.

We request Cerebras to explore wafer‑scale execution of large‑batch and sequence‑intensive AI kernels and to study tight coupling between training and inference workflows. Graphcore is needed to investigate fine‑grained model and data parallelism for graph‑like and sparsity‑aware kernels within our agent‑driven workflow. Groq is required for ultra‑low‑latency, high‑throughput inference of LLM agents and downstream scoring models, enabling real‑time decision loops in the pipeline. SambaNova provides a reconfigurable dataflow architecture that we will use to prototype end‑to‑end model+data pipelines and to study how compiler‑driven optimizations interact with our agent‑based orchestration. Finally, Eagle is needed as a high‑capacity, high‑bandwidth shared file system for storing large training corpora, intermediate checkpoints, and cross‑system benchmark results, and for sharing data products with collaborators through Globus‑based data sharing services.
