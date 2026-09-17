# FABRICA agent framework

Start with [the setup guide](../SETUP.md).

- `cuda2csl.py`: CUDA analysis, architecture design, implementation, repair, and cycle-gated optimization.
- `benchmark_csl.py`: bundle staging, compilation, simulator execution, correctness checks, and held-out input verification.
- `batch_cuda2csl.py`: sequential multi-kernel execution.
- `profile_csl.py`, `ctf_trace_parser.py`, `wse3_model.py`: profiling feedback and performance-model integration.
- `debugger_agent.py`: the framework's scoped repair agent, required by translation.
- `hw_replay.py`, `hw_vs_sim.py`: optional WSE replay and matched measurements.
- `aggregate_sweep.py`: summarize newly generated run results.
- `test_*.py`: CPU regression tests for the retained runtime and benchmark contracts.

The public release omits development probes, experiment-specific sweeps, legacy reverse
translation and training prototypes, raw run ledgers, and generated candidates.
