# Post-training open models for CSL (SFT, DPO, GRPO) from the recorded agent runs

Written 1 Oct 2026. Code: `code_translation/posttrain/`, `run_cuda2csl_local.sh`; tests:
`code_translation/test_posttrain.py`. Target machine: one NVIDIA RTX Pro 6000 (96 GB) with the
Cerebras SDK 2.10.0, models served with vLLM or SGLang.

## 1. What the artifacts give us

| source (under `code_translation/results/`) | what it holds | used for |
|---|---|---|
| `translation_log.json` (2,029 runs, 16 models) | the full agent conversation: task prompt, analysis, template request, every code reply, every compiler/contract/benchmark feedback turn | SFT translate, trajectories, repair pairs, DPO translate pairs, GRPO prompts |
| `final_result.json` | per attempt: status, failure reason, compile/run transcript | outcome labels, compiler errors for repair pairs |
| `benchmark.json` + the run's final program | the final verdict and cycles | the "chosen"/target program |
| `candidates/*/{pe.csl,meta.json}` (1,547 candidates) | every benchmarked optimizer candidate with cycles, status, accepted flag | SFT optimize, DPO optimize pairs (sparse study only) |
| `first_correct/<tag>/<kernel>/` | the optimizer's frozen start programs | GRPO optimize prompts |
| `kernels/<task>/CSL/` (repo) | reference bundles: layout, host `run.py`, data, build scripts | the GRPO reward (compile + simulate + verify) |
| `csl_probe/` (48 items) | compile-only CSL knowledge test | evaluation only |

Not recoverable from the logs: the prompts of optimizer steps (rebuilt from the candidate's strategy
and base program, see 3.3) and the code of optimizer attempts in runs before 21 Sep (it lives in the
archived staging folders, `code_translation/sandbox/cuda2csl_archive_older_than_7d_20260930.tar.gz`,
and can be mined later with the attempt records' `translated_path`).

## 2. Build (or download)

The 1 Oct 2026 build (SDK-2.10-filtered and re-verified) is in the repository as
`datasets/posttrain_20261001.tar.xz` (7.9 MB, 296 MB unpacked; checksum and file list in
`datasets/README.md`): `tar -xJf datasets/posttrain_20261001.tar.xz -C code_translation/results/`.
To rebuild from the recorded runs instead:

```bash
cd ~/xkernel/code_translation
python -m posttrain.build_datasets --out results/posttrain_<date>            # ~2 min, CPU only
python -m posttrain.reference_check --out results/posttrain_<date>/sdk_reference_check.json   # needs the SDK
python -m posttrain.build_datasets --out results/posttrain_<date> --sdk-ok results/posttrain_<date>/sdk_reference_check.json
#   --target-sdk 2.10.0        port SDK 1.x code (comptime_struct, @concat_structs) to 2.x (default)
#   --exclude-models a,b       skip runs whose model name contains a or b
#   --max-prompts-per-kernel 8 GRPO prompt variants kept per kernel
```

Built 1 Oct 2026 (`results/posttrain_20261001`, training split; the evaluation splits are listed in
`manifest.json`):

| file | records | records without Claude/GPT outputs |
|---|---:|---:|
| `sft/translate.train.jsonl` | 835 | 87 |
| `sft/translate_compact.train.jsonl` | 834 | 86 |
| `sft/repair.train.jsonl` (1,743 compile + 160 run repairs) | 1,903 | 186 |
| `sft/trajectories.train.jsonl` | 766 | 82 |
| `dpo/translate_pairs.train.jsonl` | 457 | 19 |
| `grpo/translate_prompts.train.jsonl` (42 kernels) | 304 | 304 (no model output in the prompt) |
| `grpo/translate_compact_prompts.train.jsonl` | 304 | 304 |
| `grpo/optimize_prompts.train.jsonl` | 28 | start programs were written by Claude |
| `sft/optimize`, `dpo/optimize_pairs` | 0 train (204 / 557 eval) | all optimizer candidates are from the sparse study |

Median lengths: translate prompts ~20k tokens (p90 ~30k), compact prompts ~7k, repair records ~5k,
responses 1-2k tokens.

### Record formats

```json
// sft/*.jsonl
{"messages": [{"role": "system", ...}, {"role": "user", ...}, {"role": "assistant", "content": "```csl\n...\n```"}],
 "meta": {"kernel", "split", "source_model", "run_sdk", "sweep", "kind", "cycles", "sdk_port_edits", "hash", ...}}
// sft/trajectories.jsonl adds "train_turns": [index of the assistant turn(s) to put loss on]
// dpo/*.jsonl
{"prompt": [messages], "chosen": [assistant message], "rejected": [assistant message], "meta": {...}}
// grpo/*_prompts.jsonl: the prompt plus what the reward needs
{"prompt": [messages], "kernel", "reference_dir": "kernels/<dir>/CSL", "target_relpath", "commands_script",
 "split", ["base_cycles", "base_code", "base_cycles_sdk"], "meta": {...}}
```

## 3. How the records are made

1. **Translate.** For each run whose final program passed (visible and held-out inputs), the record
   pairs the request that asked for the first code reply (the template-completion or translation
   prompt, with the retrieved documentation and the reference bundle's interface) with the final
   program. `translate_compact` removes the retrieved documentation and the model-written sections.
2. **Repair.** Code replies are matched to attempts by line count, in order. A pair is kept when
   attempt *k* failed and attempt *k+1* got further: `compile_repair` (k did not compile, k+1 did; the
   prompt carries the cleaned `cslc` output) or `run_repair` (k compiled but failed on the simulator,
   k+1 passed; the prompt carries the failure reason and the run output).
3. **Optimize.** Candidates of an optimizer run are replayed in order from the baseline; a candidate
   that the harness accepted (faster and correct on the held-out inputs) becomes an SFT record whose
   prompt is rebuilt from its base program, cycles and strategy description (the harness's real prompt
   also carried profiler feedback, which was not logged). DPO pairs compare the fastest correct
   candidate of a base program with failed or ≥2% slower ones from the same base.
4. **GRPO prompts.** One per distinct request per kernel (at most 8), with the analyst's
   `CUDA analysis:` and the architect's `# DESIGN.md` removed, so the prompt contains only the harness's
   template, rules, documentation, interface and the CUDA source.

**Splits are by kernel** (`posttrain/common.py`): `eval_sparse` = the IPDPS 2027 sparse benchmark
(SpMV-CSR, RowScale-CSR, ColScale-CSR, RowReduce-CSR, SpGEMM-Masked-Dot, SpMV-RowBlock, SpMM-CSR-Dense,
SpMV-RowBlock-Iter); `eval_general` = one kernel per earlier family (GELU-1PE, Sum-Reduction-1PE,
Prefix-Sum-1PE, DFT-1PE, ParReduce-Sum, Laplacian2D-Halo, GEMV-Collectives-2D, Attention-QP); everything
else trains. A leak guard drops training records that contain three or more reference lines that occur
only in evaluation kernels (68 trajectories dropped in the 1 Oct build); the probe's items are new toy
kernels and never enter training.

**Redaction.** Local paths, host names, job ids, e-mail addresses and key-like strings are replaced
(`<repo>`, `<host>`, `<job>`, `<email>`, `<key>`); records that still look like they hold a secret are
dropped. The 1 Oct build has no such string (checked by grep).

## 4. Read before training

* **Terms of use.** About 6,000 of the ~7,500 records contain outputs of Claude (Anthropic) or GPT
  (OpenAI) models. Their terms restrict using outputs to develop competing models; check them before
  training on those records or sharing the datasets. `--exclude-models claude,gpt-4,gpt-5` (or the
  training scripts' `--exclude-models`) keeps open-weight-model and harness-only data. The GRPO
  translation prompts contain no model output; GRPO with the SDK reward needs no proprietary data.
* **Kernels whose reference fails on the target SDK.** Several kernels of the earlier study do not
  compile under SDK 2.10 (BiCGSTAB, CG, Preconditioned-CG, 7pt-Stencil) or have host-launched timers
  that read zero there. Check every reference once on the training machine and rebuild with the list:
  `python -m posttrain.reference_check --out D/sdk_reference_check.json` (~1-2 h), then
  `python -m posttrain.build_datasets --out D --sdk-ok D/sdk_reference_check.json`. On 1 Oct (SDK
  2.10.1 simulator) 46 of 58 references passed; the 12 that do not are 7pt-Stencil, BiCGSTAB, CG,
  Cholesky, FFT-1D-2D, GEMV-Checkerboard, Game-of-Life, Histogram, Mandelbrot, Power-Method,
  Preconditioned-CG and Wide-Multiplication. With the filter, the training split keeps 459 translate,
  626 repair, 457 trajectory and 207 DPO records, 208 GRPO translation prompts (30 kernels) and 24
  optimize prompts. (Before the filter, a sample of one ported translation record per kernel for 12
  kernels passed in 4 of 12, the failures being mostly those kernels.)
* **Re-verify the programs** that survive the filter, then train on the `.verified.jsonl` files:
  `python -m posttrain.csl_reward --check D/sft/translate.train.jsonl --out D/translate.verified.jsonl`,
  then `python -m posttrain.apply_verification --data D --verified D/translate.verified.jsonl`, which
  writes `sft/{translate,translate_compact,trajectories}.train.verified.jsonl` and
  `dpo/translate_pairs.train.verified.jsonl` and `verification.json`. **Result on 1 Oct (SDK 2.10.1
  simulator, held-out inputs included): 350 of 459 translate programs pass** (76%; 350 translate and
  350 compact records, 156 of 207 DPO pairs). The failures concentrate in GEMM (0/22) and
  GEMM-Collectives-2D (0/25), whose agent programs time with host-launched timers that read zero on
  2.10, and GEMV (5/27); every other kernel keeps most of its records. Trajectories end at the
  translation-phase reply, not at the run's final program, so they were checked separately (2 Oct):
  346 of 457 pass.
* **SDK version.** Every `sft/translate*` training record comes from an SDK 1.4.0 run; the code is
  ported mechanically to 2.x (`sdk_port_edits`) but was verified on 1.4. Re-verify on the training
  machine before SFT and keep the records that pass:
  `python -m posttrain.csl_reward --check results/posttrain_<date>/sft/translate.train.jsonl --workers 8`
  (writes `.verified.jsonl` with `meta.verified_reward`; keep `>= 1.0`). The full prompts also still
  contain an "SDK Release Notes (target SDK 1.4.0)" section; the compact prompts do not.
* **Optimize prompts' `base_cycles`** come from the run's SDK. Re-measure them once:
  `python -m posttrain.csl_reward --remeasure-base .../grpo/optimize_prompts.train.jsonl`.
* **Data are small.** 42 training kernels; expect SFT to teach format, interface and the common
  repairs, and RL to do the rest.

## 5. The reward (`posttrain/csl_reward.py`)

A completion is scored by the study's own harness (`benchmark_csl.benchmark_translated_compute_file`):
the first ```csl block is overlaid on the task's reference bundle, compiled with `cslc`, run on the SDK
simulator and checked by the bundle's `run.py`; at the `run` level the held-out inputs are checked too.

| outcome | translation reward | optimization reward (`base_cycles` given) |
|---|---:|---:|
| no ```csl block | 0.00 | 0.00 |
| fails the static check or the frozen-function contract | 0.05 | 0.05 |
| does not compile | 0.10 | 0.10 |
| compiles (compile level) / compiles, wrong or crashes (run level) | 0.30 | 0.30 |
| correct on the visible input, wrong on a held-out input | 0.60 | 0.60 |
| correct | 1.0 (+0.25·clip(log2(ref/cycles), ±1) with `ref_cycles`) | 1 + clip(log2(base/cycles), ±1) |

Results are cached in SQLite by (kernel, level, held-out, sha256(code)). The harness's own
anti-gaming checks apply: a dead or empty timer window is rejected, held-out inputs catch hard-coded
outputs, and the contract check rejects edits to frozen timing functions. Cost per completion: compile
5-30 s; simulation 2-60 s; held-out adds 1-3 simulations. Environment: `XKERNEL_SDK_ROOT` (the SDK 2.10.0
directory with `cslc`/`cs_python` wrappers and the container runtime they need), `XKERNEL_REWARD_CACHE`,
`XKERNEL_REWARD_TMP`. Smoke test: `python -m posttrain.csl_reward --smoke SAXPY-1PE` must print reward 1.0.

## 6. Sizing on one RTX Pro 6000 (96 GB)

| method | fits | notes |
|---|---|---|
| LoRA SFT, 7-14B dense, bf16 | yes | 16-28 GB weights; 16k-token sequences with gradient checkpointing; use compact prompts for >16k |
| QLoRA SFT, 27-35B dense | yes | 4-bit base ~18-20 GB; `--load-in-4bit` |
| LoRA SFT, ~20B MoE (e.g. gpt-oss-20b) | yes | ~42 GB in bf16 |
| full SFT | ≤ ~4B | Adam states need ~16 B/parameter |
| GRPO, colocated vLLM, ≤ 8B | yes | policy + rollout engine + KV cache; `--vllm-gpu-memory-utilization 0.35`, 8 generations, compact prompts |
| GRPO, 14B | tight | LoRA policy, 4 generations, compact prompts, or a second GPU for `trl vllm-serve` |

The reward is CPU-bound (one SDK process per completion): with 8 prompts × 8 generations per step, 16
reward workers give roughly 1 minute per step at the compile level and 3-5 minutes at the run level.

## 7. Serving the model (vLLM or SGLang) for evaluation and data collection

```bash
vllm serve <model-or-merged-checkpoint> --served-model-name csl-model --max-model-len 32768 --port 8000
# or
python -m sglang.launch_server --model-path <model> --served-model-name csl-model --context-length 32768 --port 8000
```

* **Probe** (48 items, groups syntax / semantics / repair / API):
  `python code_translation/csl_probe/run_probe.py --model csl-model --base-url http://localhost:8000/v1 ...`
  then `score_probe.py` (see `csl_probe/README.md`).
* **pass@k on held-out kernels** (single turn, SDK-verified):
  `python -m posttrain.eval_passk --data results/posttrain_<date> --split eval_sparse --sets translate_compact --base-url http://localhost:8000/v1 --model csl-model --k 4`
* **The full agent loop with the served model** (multi-turn, the study's harness):
  `XKERNEL_LAUNCHER=$PWD/run_cuda2csl_local.sh XKERNEL_MODEL=csl-model bash run_sparse_translate_sweep.sh --kernels <K1,K2> --seeds 3 --arms T0 --sdk 2.10 --tag local_<model>`

## 8. Recipes

**R0 baseline.** Serve the base model; run the probe and `eval_passk` on `eval_sparse` and
`eval_general` (compact prompts, k = 4, temperature 0.8). Record compile@1, pass@1, pass@4.

**R1 SFT (LoRA).** After re-verification (section 4):
```bash
python -m posttrain.train_sft --data D --model <base> --out runs/sft --sets translate_compact,repair --verified \
    [--exclude-models claude,gpt-4,gpt-5] --epochs 2 --lr 1e-4 --max-length 16384
```
Merge the adapter, serve, repeat R0. Expected: fewer syntax and interface errors (the open models'
dominant failure, Sec. RQ4 of the paper), higher compile@1.

**R2 DPO (optional).** From the SFT checkpoint:
`python -m posttrain.train_dpo --data D --model runs/sft-merged --out runs/dpo --sets translate_pairs --verified`.

**R3 GRPO with TRL + vLLM (one GPU).**
```bash
python -m posttrain.train_grpo --data D --model runs/sft-merged --out runs/grpo-c --sets translate \
    --level compile --vllm-mode colocate --num-generations 8 --reward-workers 16 --max-steps 300
python -m posttrain.train_grpo --data D --model runs/grpo-c --out runs/grpo-r --sets translate,optimize \
    --level run --vllm-mode colocate --num-generations 8 --reward-workers 16 --max-steps 300
```
Use `grpo/translate_compact_prompts` via `--sets translate_compact` when memory is tight. Stage 1
(compile reward) is cheap and teaches the language; stage 2 adds correctness and speed.

**R4 GRPO with veRL (SGLang or vLLM rollouts).** Convert, then point veRL's custom reward at the module:
```bash
python -m posttrain.to_verl --data D --out D/verl --level run
python -m verl.trainer.main_ppo algorithm.adv_estimator=grpo \
  data.train_files=D/verl/train.parquet data.val_files=D/verl/eval_general.parquet \
  data.max_prompt_length=12288 data.max_response_length=4096 data.train_batch_size=16 \
  actor_rollout_ref.model.path=runs/sft-merged actor_rollout_ref.rollout.name=sglang \
  actor_rollout_ref.rollout.n=8 actor_rollout_ref.rollout.gpu_memory_utilization=0.4 \
  actor_rollout_ref.actor.optim.lr=1e-6 actor_rollout_ref.actor.use_kl_loss=False \
  custom_reward_function.path=code_translation/posttrain/csl_reward.py \
  custom_reward_function.name=verl_compute_score \
  trainer.n_gpus_per_node=1 trainer.nnodes=1 trainer.total_epochs=2
```
(Key names as of veRL 0.4-0.5; check them against the installed version. `rollout.name=vllm` swaps
the engine.)

**R5 on-policy data (rejection-sampling fine-tuning).** Serve the current model, run the agent loop on
the training kernels with `run_cuda2csl_local.sh` (section 7), rebuild the datasets
(`--exclude-models` everything except the served model's name, or keep all), and fine-tune on its own
passing runs and repairs. This needs no proprietary data and uses the multi-turn compile-and-repair
loop that the single-turn GRPO prompts do not model.

## 9. What to report

Per split (eval_sparse, eval_general) and per model: compile@1, pass@1 and pass@k from `eval_passk`
(same k, temperature and max tokens for every model), probe accuracy per group with Wilson intervals,
and for the agent loop the paper's metrics (success in the attempt budget, attempts to first correct).
Keep the base model, the SFT model and the RL model on the same decoding settings; report which
records were excluded (`--exclude-models`) and the build's `manifest.json` hash.
