# Compile-only CSL probe: do LLMs understand CSL?

An operationalisation, not a benchmark: 48 items in four groups, 12 each, scored without the
simulator (the SDK compiler for group A and C, exact keys for B and D). Items are toy kernels,
synthetic defects and documented rules: never the reference code of a benchmark task, never a
held-out matrix. Methodology positioned after arXiv 2606.16827 (compile-based evaluation of
no-resource languages) and the LRPL/DSL survey arXiv 2410.03981.

| group | question | scoring |
|---|---|---|
| A_syntax | write a 1-PE `pe.csl` for a fixed layout from a one-paragraph spec, no knowledge in the prompt | `cslc` compiles (compile only) |
| B_semantics | what does this 20-40-line CSL snippet compute / output on a tiny input? (incl. the f32 register-reduction hazard item) | value / choice against simulator ground truth |
| C_repair | one injected defect + the real `cslc` stderr -> fixed file | compiles and <= 6 changed lines |
| D_api | documented WSE-3 / CSL rules, 4 options | letter equals the key |

```bash
# ask (one sample per item, temperature default), one model at a time
~/bin/micromamba run -n xkernel-agent python csl_probe/run_probe.py --model claude-opus-4-8 --api-key-file ~/claude-api-key.txt --out results/probe_opus48
# score (group A/C compile through the SDK 2.10 toolchain; serial SDK job)
XKERNEL_SDK_FLAVOR=2.10 ~/bin/micromamba run -n xkernel-agent python csl_probe/score_probe.py results/probe_opus48 --out docs/data/csl_probe_results.csv
```

Groups B and C are added once their ground truth (12 simulator runs) and real compiler
messages (12 deliberately broken files) have been produced on the SDK.
