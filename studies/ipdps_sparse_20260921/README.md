# Matched sparse study on two nodes

This directory records the new experiment version. The implementation starts from
`72ed7c56f843825b03653db7a8dd0892a48d691f` and integrates the reviewed workload and
expert-reference update `4cb088d8af9eb24fdc78de93fa15d2566d5f38ce`; paper proposals target
`d1f9e720642fd030f0a7e1ec8334975ceeb4a99e`. Do not merge changes into a running
checkout. Use a clean detached worktree at the acknowledged integration commit.

## Running the study

Set `STUDY_OUT` to an absolute persistent results directory. Run from the frozen
checkout, using this node's assigned provider (`deepseek` here, `luna` on WSE-3):

```sh
python3 tools/sparse_study.py --phase preflight --provider deepseek --out "$STUDY_OUT"
python3 tools/sparse_study.py --phase smoke --provider deepseek --out "$STUDY_OUT"
python3 tools/sparse_study.py --phase report --out "$STUDY_OUT"
```

Preflight freezes and hashes the seven source/host/layout/data bundles, protocol,
framework revision and SDK image. `bootstrap-smoke` runs preflight then the four
smoke cells in one resumable command. Reference checks and independent replays use three
timing repetitions plus validation seeds 101, 202 and 303. These are development
validation inputs, not the final-test split. API identity mismatch is an experiment
failure. Every returned call, including truncated attempts, is written immediately.
Truncated responses are rejected after one bounded retry. SDK jobs share the existing
node-wide lock; process cleanup targets only children of the current workflow.

Main phases are `translate`, `freeze-starts`, `optimize`, and `ablate`. Translation
contains 70 cells per model, optimization 105, and ablations 24. A cell is one task,
condition and repetition for one provider. Outcomes, failures and timeouts persist;
resumption does not reroll completed cells. `audit` resumes independent replay.
Missing shared starts are reported. Finalize the four remaining starts only after
both models' T0 outcomes are available, ordered by repetition then model name.

All guidance arms use the same build-capture mode. Only O1I and smoke expose the
instruction-analysis readout. Captured shadow IR is explanatory evidence only when
its ELF matches the measured build. Missing counters remain unavailable; static
instructions are not dynamic CPI. Simulator cycles are reported separately from
CUDA event latency and CS-3 hardware latency. Do not convert cycles to measured
microseconds using an assumed clock.

## Artifact retention and later training

Each cell keeps `model_artifacts/calls/` (visible messages/replies, identity, usage,
hashes), `model_artifacts/candidates/` (every tested source, feedback and build
hashes), complete workflow artifacts, scratch builds and independent `audit/`
results. Failed and slower programs are retained. Credential files, HTTP headers
and hidden reasoning are not archived. These records are local experiment data;
publishing a dataset is a separate action.

After the independent audits, export into a new directory:

```sh
python3 tools/export_model_artifacts.py --archive "$STUDY_OUT/cells" \
  --evaluations "$STUDY_OUT/development_evaluations.jsonl" \
  --out "$STUDY_OUT/training_export_v1"
```

`sft.jsonl` contains chat messages for exactly matched, independently validated
code. `outcomes.jsonl` preserves matching positive and negative evidence;
`grpo_prompts.jsonl` provides prompts for future verifier-based rollouts.
`manifest.json` supplies counts and checksums. Unmatched or mechanically altered
responses remain raw artifacts, not automatically approved training targets.
Final-test feedback is excluded. Future model training should split by task and
matrix family, not individual attempts. vLLM/SGLang serving and a training engine
can consume adapted exports; this change does not run SFT or GRPO.

## Gates and remaining work

Follow-up tools added after the frozen `db482cd` smoke revision:

- `tools/sparse_cuda_baselines.py` executes the frozen host's input-generation
  prefix and measures the original seven CUDA sources. It also measures cuSPARSE
  CSR algorithm 2 for the two SpMV tasks and SpMM. Forty numerical checks passed
  on seed 7 and the three validation seeds. Tables are under `docs/data/`.
- `tools/sparse_repeat_audit.py` reuses one simulator runtime for seeds
  7, 101, 202 and 7. The two multi-PE references needed their timer guard reset.
  The repair makes repeated intervals consistent, but changes the compiled SpMM
  reference to 108,828 cycles. Use a new measured baseline in the next version.
- `tools/sparse_test_matrices.py --include-real` freezes 28 controlled and 20 real
  test cases outside model input bundles. It preserves source values and labels
  pattern-only unit values. Final matrix selection is not based on speed.
- `tools/sparse_final_test.py` checks sealed source/input hashes, rejects overlapping
  matrix patterns, disables model access, and replays final programs independently.
  Its external-matrix SpMV host adapter still needs SDK reference validation.
- `tools/sparse_strong_scaling.py` prepares ten strong-scaling configurations;
  `--kind weak` prepares ten with constant local stored nonzeros and output work.
  `--run compile` records compiler capacity failures; `--run measure` additionally
  validates and times feasible points. Cross-PE clock alignment is still required
  before interpreting combined hardware timestamps.

The terminal-translation fix also ensures an exhausted candidate budget returns
the last tested source, without pairing an untested repair with an earlier result.
These follow-ups do not change the running smoke checkout.

The initial commit supports the matched smoke and resumable experiment execution.
Before admitting the full study:

- Exchange the integration commit, protocol/input hashes, node ownership and active
  cells through the user. The WSE-3 node must acknowledge the same configuration.
- Freeze separate real and controlled final-test matrix manifests; alternate seeds
  selecting the same validation matrices are insufficient. Preserve original matrix
  values where supplied; existing small smoke manifests use generated values.
- Validate repeated launches with changed data in the same runtime; check scratch
  initialization and timer resets. Independent simulator launches do not test this.
- Verify clock alignment before using timestamps from different PEs. The existing
  host calculation alone is not evidence that hardware clocks align.
- Audit the three upstream starts, then obtain the other node's T0 outcomes before
  selecting remaining starts. Obtain raw exploratory Luna artifacts before citing
  its reported 206,319 or 202,106 cycle masked-product results.
- Freeze fixed-matrix strong/weak scaling, PE capacity checks, nonzero-balanced
  partitioning, and SpMM output widths. Existing registered size changes are not
  fixed-matrix strong scaling. Identify host/framework scaffolding separately.
- Add measured CUDA/cuSPARSE and compatible vendor CSL references; obtain expert
  variants and physical WSE-3 replay. Audit preprocessing reuse costs and dynamic
  instruction cases. Hardware conclusions require hardware data.

`full_study_admission.json` in the results directory must record the acknowledged
commit and protocol hash, both node acknowledgements and completed input/validation
gates before main model cells can start. Do not fill it with assumed acknowledgements.
The paper integrator owns manuscript edits. This node supplies tables and proposed
text against the named paper commit, including failures and unsupported claims.
