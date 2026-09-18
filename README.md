# FABRICA

**Agentic CUDA-to-CSL translation and optimization for Cerebras wafer-scale systems.**

FABRICA combines a paired CUDA/CSL benchmark suite with an agent that analyzes CUDA,
designs a CSL implementation, repairs compiler and correctness failures, and optimizes
passing programs using device-cycle and profiling feedback.

Paper: [Fabrica: Agentic CUDA-to-CSL Translation and Optimization for Wafer-Scale Systems](https://arxiv.org/abs/2608.25124).

## Quick start

Use Python 3.11. Translation and execution require a Linux host with the Cerebras SDK
(`cslc`, `cs_python`) and its supported container runtime. The SDK is installed separately.
CPU tests and source inspection work without the SDK or an API key.

```bash
git clone https://github.com/luozoupi/FABRICA-CUDA2CSL-Optmization-Benchmark-and-Agentic-Framework.git Fabrica
cd Fabrica
python3.11 -m venv .venv
source .venv/bin/activate
python -m pip install -r code_translation/requirements.txt
python -m unittest discover -s code_translation -p 'test_*.py'

export XKERNEL_SDK_ROOT=/path/to/cerebras/sdk
export OPENAI_API_KEY=your-key
bash run_cuda2csl.sh --check-env
bash run_cuda2csl.sh --kernel ReLU-1PE --turns 4 --reviewer-max-attempts 10
```

To optimize after translation, add `--auto-optimize`. For Anthropic, Argo,
OpenAI-compatible endpoints, optional hardware replay, and batch runs, see [SETUP.md](SETUP.md).
The `XKERNEL_*` configuration names remain supported for compatibility.

## Repository layout

| Path | Purpose |
| --- | --- |
| `kernels/` | CUDA sources, CSL reference bundles, task specifications, input data, and shared libraries |
| `code_translation/` | Translation, repair, optimization, benchmarking, profiling, hardware replay, and CPU regression tests |
| `code_translation/performance_model/` | Trace readers, performance models, and compact calibration coefficients |
| `knowledge/` | Version-aware retrieval corpus and ingestion utilities |
| `run_cuda2csl*.sh` | Provider launchers |
| `fabrica_env.sh` | Portable environment selection |

This is a source release of the working codebase, with **52 registered tasks**.
The paper evaluates a **49-task subset**; the current checkout includes later additions
and additional reference examples. See [the benchmark guide](kernels/BENCHMARK.md)
and [task catalog](kernels/CATALOG.md) for exact local coverage.
This release does not contain the paper's run logs or frozen generated candidates.

Generated runs, simulator output, local credentials, and virtual environments are
Git-ignored. The original BSD 3-Clause license and third-party notices are preserved:
[LICENSE](LICENSE), [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).
