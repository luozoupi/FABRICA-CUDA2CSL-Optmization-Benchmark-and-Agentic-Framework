# Runbook: the model-guided optimization study

This is the operating manual for running cells of the current experiment on your
own ALCF account with your own Argo key. Follow it top to bottom. `SETUP.md`
gets the software working; this document says **what to run, in what order, what
it should print, and what to send back**.

Read [`IPDPS_PREREG.md`](IPDPS_PREREG.md) once before you start: it fixes the
arms, the estimators and what will not be claimed. Nothing here overrides it.

---

## 0. What the experiment is, in one page

Every task in the benchmark has a **frozen first-correct program**: the first
translation the agent ever got past correctness, saved verbatim under
`code_translation/results/first_correct/template_20260722/<kernel>/` and tracked
in git. Every optimizer arm starts from that identical program, so differences
between arms cannot come from translation luck.

The arms differ only in what feedback the optimizer sees:

| Arm | `XKERNEL_MODEL_GUIDED` | `XKERNEL_MODEL_ANGLES` | What it is |
|---|:--:|:--:|---|
| **O0** | 0 | 0 | the published optimizer: heuristic profiler feedback (baseline) |
| **O1** | 1 | 1 | + silicon-model readout, model-derived angles, model-guided selection |
| O1A | 0 | 1 | ablation: new angles, old selector |
| O1S | 1 | 0 | ablation: old angle catalogue, model selector |

The headline is **O0 versus O1**, paired per task, five seeds each. O1A and O1S
are ablations on a subset and are only run when asked for.

A **cell** is one kernel × one arm × N seeds. An account runs whole cells: all
arms and all seeds of the kernels it owns. Never split the arms of one kernel
across accounts, or the arm difference gets confounded with the node.

Task sets (`code_translation/task_sets.py` is the authoritative machine-readable
copy; `--verify` checks it against the repository):

| Set | N | What |
|---|--:|---|
| H | 27 | single-PE operators; short runs, all hardware-comparable |
| M | 4 | multi-PE kernels with the device-internal timing protocol |
| A | 2 | attention tasks, expert-written references |

33 tasks in the study. Four further kernels have frozen programs but are
deliberately excluded, each with a recorded reason (see `EXCLUDED` in
`task_sets.py`).

---

## 1. Get the code

```bash
cd $HOME                                  # NOT /tmp: the SDK container cannot bind /tmp
git clone --branch sparse-csl-kernels <repo url> xkernel && cd xkernel
git log --oneline -1                      # record this commit; it goes in every result
git rev-parse --abbrev-ref HEAD           # must print v2_0
```

**The branch matters.** `v2_0` is the collaboration branch and carries the study.
The repository's default branch is far behind it and has none of the tooling this
runbook uses, so cloning without `--branch v2_0` gets you code that cannot run the
experiment. The reliable test is not the branch name but the files: if your
checkout lacks `docs/EXPERIMENT_RUNBOOK.md` or `code_translation/task_sets.py`,
you are on the wrong branch.

```bash
git checkout v2_0 && git pull
```

(`v1_0` is the earlier snapshot of the same line of work and is kept for
reference; new commits go to `v2_0`.)

Both accounts must run the **same commit**. It is recorded per run in
`bundle_metadata.json`, so a mismatch is detectable afterwards, but it is much
cheaper to agree beforehand.

Then follow `SETUP.md` sections 1-3 (micromamba environment, `xkernel_env.sh`
site paths). Come back here when `bash run_cuda2csl_argo.sh --check-env` is the
next thing you would run.

## 2. Point the agent at Argo

```bash
pip install argo-shim                     # github.com/n-getty/argo-shim
argo-shim                                 # prints a local base URL; keep it running
# on a compute node with no outbound SSH:
#   argo-shim --tunnel              on a UAN, then
#   argo-shim --tunnel-host <uan>   on the compute node
# if your ALCF and CELS usernames differ:  export CELS_USERNAME=<cels-user>
```

argo-shim writes `ANTHROPIC_BASE_URL` and an `apiKeyHelper` into
`~/.claude/settings.json`, and `run_cuda2csl_argo.sh` reads both from there. To
be explicit instead:

```bash
export ANTHROPIC_BASE_URL=http://127.0.0.1:<port>/argoapi
export ANTHROPIC_API_KEY=<your Argo key>       # or ARGO_API_KEY_FILE=/path/to/keyfile
```

**Set the model explicitly.** The launcher's default is *not* the study's model,
so an unset variable silently produces a cell that cannot be pooled:

```bash
export ARGO_MODEL=claude-opus-4-8              # the study's model; launcher default is claude-opus-4-7
```

Put these four lines in a file you `source` before every sweep, so a new shell
cannot forget them.

### Which node you run on, and why it decides whether the held-out gate is real

The anti-gaming gate re-runs a passing kernel on held-out inputs by setting
`SINGULARITYENV_`/`APPTAINERENV_XKERNEL_EVAL_SEED`: `singularity exec -C` contains the
environment, and only those prefixed forms cross into the container. On this branch that is
the *only* channel the seed has.

On a **Cerebras user node** (`user-node-*`) `singularity` is local and the seed arrives. On a
**login node** (`login-node-*`) `~/bin/singularity` is typically an ssh relay to a user node,
and ssh forwards no environment at all: the container sees no seed, every held-out re-run
silently re-uses the train seed, and the run still reports `heldout: passed`. Every held-out
claim made through such a relay between 2026-09-07 and 2026-09-16 on the first account was
void for this reason; nothing in the output said so.

If your `singularity` is a relay, install the forwarding one before any sweep:

```bash
cp ~/bin/singularity ~/bin/singularity.bak          # keep the original
cp scripts/singularity_relay_env.sh ~/bin/singularity
grep -c 'fwd+=' ~/bin/singularity                   # must print 1
```

Preflight check 5 probes this directly, so you do not have to reason about it: it sets a
marker variable, asks the container to print it back, and FAILs if the container sees
`None`. Hardware replay is a separate matter -- the SDK 2.10 appliance client only works on
a user node.

## 3. Preflight: prove this node's results are poolable

```bash
XKERNEL_LAUNCHER=$PWD/run_cuda2csl_argo.sh \
  bash scripts/preflight_study.sh --partition B
```

Six checks, about three minutes. It must end with `PREFLIGHT OK`. Do not start a
sweep otherwise: every FAIL below is something that would quietly invalidate the
cells you are about to pay for.

1. **environment** - SDK and micromamba resolve; the repo is not under `/tmp`.
2. **unit tests** - all green (CPU only, ~10 s).
3. **task sets** - the frozen start programs your partition needs all exist.
4. **calibration** - two committed reference bundles are compiled and run here,
   and their cycle counts must equal `kernels/baselines_wse3.json` **exactly**.
   Simulator cycles are deterministic, so a difference means a different SDK
   build, a different container, or an edited reference bundle, and results from
   this node could not be compared with the others.
5. **held-out gate integrity** - a marker variable is sent into the SDK container
   and must come back. If it does not, your `singularity` drops the environment
   and the held-out gate would be a no-op that still reports "passed" (see
   section 2, "Which node you run on").
6. **LLM route** - one real request through your launcher, and the model id it
   reports must be the study's.

## 4. Run your cells

Ask which partition is yours, then let the tooling name the kernels:

```bash
MINE=$(cd code_translation && ~/bin/micromamba run -n xkernel-agent python task_sets.py --partition B)
echo "$MINE"

XKERNEL_LAUNCHER=$PWD/run_cuda2csl_argo.sh ARGO_MODEL=claude-opus-4-8 \
  nohup bash run_model_guided_ab.sh --kernels "$MINE" --seeds 5 --arms O0,O1 \
        --tag mg_partB > /dev/null 2>&1 &
```

The sweep is **serial by design** (the SDK container is a serial resource per
node), interleaves the arm order per seed, and applies a 90-minute watchdog per
run. It creates
`code_translation/results/mg_partB_<UTC>/<kernel>/<arm>/seed_<n>/`.

Watch it:

```bash
tail -f code_translation/results/mg_partB_*/sweep.log
```

**One SDK job at a time.** Before launching anything else on this node:

```bash
pgrep -u $USER -af 'cslc|cs_python' || echo idle
```

Never `pkill -f cslc` - it matches other users' jobs. Kill your own sweep's PID.

### The bounded insurance cell (16-19 Sep 2026)

While the sparse task suite for the pivoted paper is being built, node B runs one
bounded cell of this study as insurance: **O0 versus O1, 3 seeds, the 11-task
stratified subset**, 66 runs, about 14 serial hours.

```bash
INS="GELU-1PE,Softmax-1PE,Cross-Entropy-Loss-1PE,ReLU-1PE,SAXPY-1PE,Prefix-Sum-1PE,Sum-Reduction-1PE,Dot-Product-1PE,ParReduce-Sum,Laplacian2D-Halo,Attention-QP"
XKERNEL_LAUNCHER=$PWD/run_cuda2csl_argo.sh ARGO_MODEL=claude-opus-4-8 \
  nohup bash run_model_guided_ab.sh --kernels "$INS" --seeds 3 --arms O0,O1 \
        --tag mg_insurance > /dev/null 2>&1 &
```

Rules: start no earlier than **16 Sep 09:00**, and **stop it by 19 Sep 18:00
whatever its state** (kill your sweep's PID; the sweep is resumable, so nothing
is lost). From 20 Sep the node is needed for the sparse study, which lives on the
branch `sparse_ipdps` and has its own runbook section. Check the results with
section 5 and ship them with section 6 exactly as for any other cell.

### If it stops

The sweep is resumable by directory: a `(kernel, arm, seed)` whose output holds
`optimization_summary.json` is skipped.

```bash
XKERNEL_LAUNCHER=$PWD/run_cuda2csl_argo.sh ARGO_MODEL=claude-opus-4-8 \
  bash run_model_guided_ab.sh --resume code_translation/results/mg_partB_<UTC> \
       --kernels "$MINE" --seeds 5 --arms O0,O1
```

A killed run can leave an NFS lock (`.nfs*`) in its sandbox directory, which
makes the next attempt fail with `Device or resource busy`. Delete the stale
sandbox directory (`code_translation/sandbox/cuda2csl/<kernel>_*`) or let the
next run use a fresh one.

### Running the whole study on one account

If one account carries everything rather than half:

```bash
ALL=$(cd code_translation && ~/bin/micromamba run -n xkernel-agent python task_sets.py --kernels all)
XKERNEL_LAUNCHER=$PWD/run_cuda2csl_argo.sh ARGO_MODEL=claude-opus-4-8 \
  nohup bash run_model_guided_ab.sh --kernels "$ALL" --seeds 5 --arms O0,O1 \
        --tag mg_full > /dev/null 2>&1 &
```

33 tasks × 5 seeds × 2 arms = 330 runs. At the measured 10-15 minutes per
optimize-only run that is **60-80 serial hours**, so plan for three to four
days of wall clock on one node and roughly 8,000 requests. Because the sweep is
resumable and interleaves arms per seed, it is safe to stop and restart it
across days, and a partial sweep is still analysable: the aggregator reports a
task only when both arms have at least two passing seeds.

To shorten it, drop seeds before dropping tasks (`--seeds 3` gives 198 runs and
about 40 hours); the paired statistic survives three seeds, whereas a missing
task disappears from the comparison entirely.

### Budget

Measured on this harness: an optimize-only run is roughly 25 requests and 10-15
minutes; a full translate-and-repair run is about 40 requests. One pilot
translate run recorded 988k input and 43k output tokens. A 13-kernel partition
at 5 seeds × 2 arms is 130 runs, so plan for a few thousand requests and 25-35
serial hours. Per-run token usage is written to `usage_log.json` in every run
directory; `code_translation/cost_report.py` turns a results tree into per-run
tokens, dollars and wall clock.

## 5. Check your own results before shipping them

```bash
source xkernel_env.sh
xk_python code_translation/aggregate_model_guided.py \
  code_translation/results/mg_partB_<UTC> \
  --fc code_translation/results/first_correct/template_20260722 \
  --paired-csv code_translation/results/mg_partB_<UTC>/ipdps_paired.csv
```

This also runs automatically when the sweep finishes, and writes
`model_guided_runs.csv` (one row per run), `model_guided_tasks.csv` (one row per
task) and `VERDICT.txt`.

Sanity checks before you send anything:

- **Retained pass** means `status == "pass"` **and** `success_marker == true`
  **and** the held-out inputs passed. A `cycles_send` reading alone is not a
  pass - `PROFILER_AB_RECOUNT_20260806.md` explains what that mistake cost.
- The per-task cycle estimator needs **at least two passing seeds in both arms**,
  otherwise the task prints `NoData` and is excluded from the paired statistic.
  That is expected for a few tasks, not a bug.
- Any attempt with `failure_reason: missing_transcript` and roughly 20 ms
  elapsed is an **infrastructure failure**, never a property of the kernel.
  Report those; do not count them.
- `angles_denied` in `optimization_summary.json` should be non-empty for O1 on
  tasks whose precision contract forbids fp16. Empty everywhere suggests the
  gates did not take effect.
- Spot-check one O1 run's log for a line naming `dsd_width_flatten_l0` or
  `f16_precision`: those angles exist only in the model-guided arm, so seeing
  them confirms the arm really was O1.

## 6. Send the results back

Raw results never enter git (`code_translation/results/**` is ignored).

```bash
cd code_translation/results
tar czf mg_partB_<UTC>.tgz mg_partB_<UTC>          # includes candidates/ for the hardware replay
sha256sum mg_partB_<UTC>.tgz
```

Ship the **whole sweep directory**: the per-run `candidates/` subdirectories hold
every benchmarked optimizer candidate, which the hardware-replay and fidelity
analyses need. Expect roughly 1-2 GB for a large partition. Send it through the
shared project directory or as a tarball, together with:

- the commit you ran (`git rev-parse HEAD`),
- the model id and launcher you used,
- your `preflight_study.sh` output,
- anything you had to work around.

Only aggregated `docs/data/*.csv` and curated `docs/*.md` write-ups are
committed, and the repository owner does that.

---

## 7. Optional: hardware replay

Only with the allocation owner's explicit go-ahead - the jobs consume a shared
ALCF allocation. The plan, job counts and cut ladder are in
[`HW_CAMPAIGN_20260908.md`](HW_CAMPAIGN_20260908.md). Hardware needs the
separate SDK 2.10 appliance client, not the agent environment.

## 8. Which scripts matter

The repository root holds many `run_*.sh` from earlier studies. For this one:

| Script | Use |
|---|---|
| `run_model_guided_ab.sh` | **the study**: O0/O1 (+O1A/O1S) from the frozen programs |
| `run_cuda2csl_argo.sh` | the launcher you point it at (`XKERNEL_LAUNCHER`) |
| `scripts/preflight_study.sh` | run this before every sweep on a new node |
| `code_translation/task_sets.py` | which kernels are in which set and partition |
| `code_translation/aggregate_model_guided.py` | O0/O1 aggregate + the paper's paired CSV |
| `code_translation/cost_report.py` | tokens, dollars, simulator seconds per run |
| `code_translation/error_family.py` | per-attempt failure families over a results tree |
| `code_translation/scale_retained.py` | re-runs retained programs at every problem size (RQ3) |

Everything else at the root reproduces an earlier experiment and is not part of
this study.

## 10. The v2 sparse study (branch `sparse_ipdps`, from 20 Sep 2026)

The IPDPS paper pivoted to a sparse-only study on 15 Sep 2026 (`docs/IPDPS_PREREG.md`,
"v2"; suite: `docs/SPARSE_SUITE.md`). It lives on the branch **`sparse_ipdps`** and runs on
**SDK 2.10 end to end**. Everything above still applies (Argo route, one SDK job per node,
shipping results); the differences:

```bash
git clone --branch sparse_ipdps <repo url> xkernel && cd xkernel     # or: git fetch && git checkout sparse_ipdps
export XKERNEL_SDK_FLAVOR=2.10                                       # SDK 2.10 root, target SDK, syntax fix-up
XKERNEL_LAUNCHER=$PWD/run_cuda2csl_argo.sh ARGO_MODEL=claude-opus-4-8 \
  bash scripts/preflight_study.sh --partition S-B                    # calibration = RowScale-CSR + SpMV-RowBlock on 2.10
MINE=$(cd code_translation && ~/bin/micromamba run -n xkernel-agent python task_sets.py --partition S-B)

# W1 (from 22 Sep): translation arms T0/T1, 5 repeats, translate only
XKERNEL_LAUNCHER=$PWD/run_cuda2csl_argo.sh ARGO_MODEL=claude-opus-4-8 \
  nohup bash run_sparse_translate_sweep.sh --kernels "$MINE" --seeds 5 --tag sparse_t_partB > /dev/null 2>&1 &

# optimize arms (from 24 Sep, after the frozen programs sparse_20260924 are pushed)
XKERNEL_LAUNCHER=$PWD/run_cuda2csl_argo.sh ARGO_MODEL=claude-opus-4-8 \
  nohup bash run_model_guided_ab.sh --sdk 2.10 --fc code_translation/results/first_correct/sparse_20260924 \
        --kernels "$MINE" --seeds 5 --arms O0,O1,O1I --tag sparse_o_partB > /dev/null 2>&1 &
```

Partition `S-B` is the four 1-PE tasks (SpMV-CSR, RowScale-CSR, ColScale-CSR,
RowReduce-CSR); `S-A` (SpMV-RowBlock, SpMM-CSR-Dense, SpGEMM-Masked-Dot) stays with the
hardware allocation. Every optimize arm carries the disassembly hazard scan and the
held-out hazard policy; `O1I` additionally captures the LLVM IR of accepted winners
(`XKERNEL_IR_CAPTURE=best`), which re-compiles each of them once (about a minute more
per accepted step over the relay).

**If your `singularity` is an ssh relay** (login nodes), install
`scripts/singularity_relay_env.sh` as `~/bin/singularity` (keep a backup): the plain relay
forwards no environment, and the v1 runners read the held-out seed from the environment.
The v2 runners are safe either way (file hand-off + echo check). **One account per SDK node:**
the relay's target is `XKERNEL_RELAY_HOST` (default `user-node-1`); a second account on the same
login node sets `XKERNEL_RELAY_HOST=user-node-2`. Preflight check 5 proves the container sees
`XKERNEL_*`. The current job list, commands and the model-pooling rule for the optimiser arms are
in `docs/HANDOFF_COLLABORATOR_20260923.md`; the frozen-program root there is
`first_correct/sparse_sb_<date>` (S-B), not the placeholder `sparse_20260924` above.

## 9. Troubleshooting

| Symptom | Cause and fix |
|---|---|
| `--check-env` not ready, LLM section failing | argo-shim not running, or the tunnel died. Restart it; check `ANTHROPIC_BASE_URL`. |
| `--check-env` SDK probes fail | repo cloned under `/tmp` (container cannot bind it) or `XKERNEL_SDK_ROOT` wrong. |
| `Device or resource busy: .nfs...` | a killed run still holds a file. Remove the stale sandbox directory. |
| every attempt `missing_transcript` in ~20 ms | a shell error before the first command. The build script's `--params` must be literal; `test_commands_scripts.py` enforces it. |
| `heldout` always passes, and preflight check 5 FAILs | your `singularity` drops the environment (login-node ssh relay), so the gate never changed the input. Install `scripts/singularity_relay_env.sh` as `~/bin/singularity`, or sweep from a user node. |
| runs pass but `heldout` failing | the program is input-dependent on the shown seed only. This is the anti-gaming gate working; see `SPLIT_AND_LEAKAGE.md`. |
| calibration FAILs on a reference | different SDK build or an edited `kernels/` bundle. Do not sweep; reconcile first. |
| two `cslc` at once | the container wedges. One SDK job per node, always. |
