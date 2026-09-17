# Benchmark knowledge boundaries

CUDA-to-CSL translation uses task specifications, CUDA source, visible host/layout
contracts, SDK documentation, tutorials, and general CSL lessons. The framework
filters reference compute contents from prompts and checks contract constraints.
The repair agent has scoped file access. See the implementation and CPU tests in
`test_no_compute_leak.py`, `test_contract_callsites.py`, and `test_wiring_plan.py`.

The optimizer receives the current candidate plus correctness and profiling feedback.
Fields such as `hidden_from_optimize_only`, `frozen_files`, and `frozen_functions` in
`kernels/*/spec.yaml` define task-specific restrictions. Run scripts and numerical
verification remain part of the trusted benchmark harness.

Held-out seeds are applied by the evaluator after training-input success and are not
provided as optimization feedback. Use only passing held-out results for evaluation.

`knowledge/data/` contains general SDK, tutorial, and skill material.
`knowledge/explored/**/ingest/` contains promoted experiences from the original
exploration workflow. These are retained as provenance-bearing knowledge inputs;
exploration records are not allowed in translation architect/implementer/reviewer
prompts. Raw experience ledgers and generated benchmark answers are omitted.

Do not expose test-task answers through a replacement retrieval corpus, and do not
compare cycle counts from different device timing windows or SDK settings.
