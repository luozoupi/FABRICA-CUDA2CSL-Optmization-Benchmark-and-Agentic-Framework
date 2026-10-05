# Post-training datasets for CSL code generation

`posttrain_20261001.tar.xz` (7.9 MB; 296 MB unpacked; sha256 `65703304d4e6e171c65dcaaf78be19bfc51bbf72213cbb6eb964365cd8cbf45f`) holds the
SFT, DPO and GRPO datasets built on 1 Oct 2026 from the recorded agent runs by
`code_translation/posttrain/build_datasets.py --sdk-ok` (kernels whose reference passes on SDK 2.10 only),
with the SDK 2.10 re-verification applied (`posttrain.apply_verification`). How the records are made, the
splits, the reward and the training recipes: `docs/POSTTRAINING.md`.

```bash
sha256sum -c <<< "65703304d4e6e171c65dcaaf78be19bfc51bbf72213cbb6eb964365cd8cbf45f  datasets/posttrain_20261001.tar.xz"
mkdir -p code_translation/results && tar -xJf datasets/posttrain_20261001.tar.xz -C code_translation/results/
# -> code_translation/results/posttrain_20261001/{sft,dpo,grpo}/*.jsonl, splits.json, manifest.json,
#    verification.json, sdk_reference_check.json
```

## Files (record counts)

| file | records |
|---|---:|
| `dpo/optimize_pairs.eval_sparse.jsonl` | 557 |
| `dpo/translate_pairs.eval_general.jsonl` | 110 |
| `dpo/translate_pairs.eval_sparse.jsonl` | 49 |
| `dpo/translate_pairs.train.jsonl` | 207 |
| `grpo/optimize_prompts.eval_general.jsonl` | 8 |
| `grpo/optimize_prompts.eval_sparse.jsonl` | 12 |
| `grpo/optimize_prompts.train.jsonl` | 24 |
| `grpo/translate_compact_prompts.eval_general.jsonl` | 50 |
| `grpo/translate_compact_prompts.eval_sparse.jsonl` | 26 |
| `grpo/translate_compact_prompts.train.jsonl` | 208 |
| `grpo/translate_prompts.eval_general.jsonl` | 50 |
| `grpo/translate_prompts.eval_sparse.jsonl` | 26 |
| `grpo/translate_prompts.train.jsonl` | 208 |
| `sft/optimize.eval_sparse.jsonl` | 204 |
| `sft/repair.eval_general.jsonl` | 223 |
| `sft/repair.eval_sparse.jsonl` | 66 |
| `sft/repair.train.jsonl` | 626 |
| `sft/trajectories.eval_general.jsonl` | 159 |
| `sft/trajectories.eval_sparse.jsonl` | 94 |
| `sft/trajectories.train.jsonl` | 457 |
| `sft/translate.eval_general.jsonl` | 159 |
| `sft/translate.eval_sparse.jsonl` | 94 |
| `sft/translate.train.jsonl` | 459 |
| `sft/translate_compact.eval_general.jsonl` | 159 |
| `sft/translate_compact.eval_sparse.jsonl` | 94 |
| `sft/translate_compact.train.jsonl` | 459 |
| `sft/translate.train.verified.jsonl` | 350 (of 459; re-checked on SDK 2.10) |
| `sft/translate_compact.train.verified.jsonl` | 350 (of 459; re-checked on SDK 2.10) |
| `sft/trajectories.train.verified.jsonl` | 346 (of 457; re-checked on SDK 2.10) |
| `dpo/translate_pairs.train.verified.jsonl` | 156 (of 207; re-checked on SDK 2.10) |

Splits are by kernel: `eval_sparse` (the IPDPS 2027 sparse benchmark) and `eval_general` (8 fixed kernels)
are evaluation-only; see `splits.json`.

## Before using or sharing

* **Keep this repository private.** About 95% of the SFT/DPO records (3,967 of 4,176) contain outputs of Claude
  (Anthropic) or GPT (OpenAI) models, whose terms restrict using outputs to develop competing models,
  and the prompts quote Cerebras SDK documentation. `meta.source_model` on every record lets you filter;
  the GRPO translation prompts contain no model output.
* Train on the `*.verified.jsonl` files (`--verified` in `posttrain/train_sft.py` and `train_dpo.py`);
  re-run `posttrain.csl_reward --check` on your own SDK if it is not 2.10.
