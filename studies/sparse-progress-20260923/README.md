# Sparse-study progress and next contributions — 23 September 2026

The next useful work is to **close the validation and hardware gaps, then run the matched DeepSeek study on a reconciled framework revision**. More exploratory optimizer runs on the current small inputs would leave the main gaps unresolved.

This review comes from the **NVIDIA RTX PRO 6000 node with Cerebras SDK 2.10.1**. It independently checks arithmetic and coverage in online summaries and local records. Hardware measurements below were made by the other node. This audit launches no API, simulator or hardware jobs and does not edit the paper.

## Latest checked state

| Repository / checkout | Revision | Role |
|---|---|---|
| `v2_0` | `313e8ab01919298527d4f069bed3419c9eb6541e` | Published NVIDIA sparse characterization; base of this contribution |
| `sparse_ipdps` | `7413ed46fa0f572f4b46e7fd9b7056462a31a770` | New compiler-feedback, hardware and transfer summaries; second-account handoff |
| Paper `main` | `bb7f61ad30873f64ebca758101f5e03d313c37d9` | Integrates those results in RQ2/RQ3 |
| Local NVIDIA framework | `c7ad437d80de5b3f077a15576cfbaca18112e657` | Provider, artifact retention, validation and scaling changes await reconciliation |
| Frozen DeepSeek smoke | `db482cd6e4b2d3f8b8e28465fbc72e1dbf45f1b0` | Four older smoke workflows, now complete |
| Frozen local measurement worker | `84553eef29952ea909490a031a2dc517231d4772` | Scaling measurements and training export, now complete |

The old local handoff says the smoke and follow-up worker are running. Their durable records now say they completed. [RESULTS.md](RESULTS.md) supplies the updated tables. The original `xkernel` checkout also contains uncommitted SDK/provider work; it was preserved. Other SDK/simulator jobs are active on this node, so this review uses CPU-only checks.

## What advanced, and what the evidence supports

- The WSE node added **27 Luna optimizer cells and 309 candidate records**, covering three tasks, three arms and three seeds. All retained a passing program. Per-task median ratios give **1.012×** for sparse guidance over existing feedback and **0.972×** for added compiler feedback over sparse guidance. The paper's reported intervals include one; no overall guidance benefit is established at this size.
- Compiler feedback produced the first improvements for distributed SpMV in that cohort: **35,396 and 33,823 simulator cycles** in two seeds, against a 37,012-cycle frozen start. This is a concrete case to explain and replay on hardware. Its correctness, instruction differences and time window matter more than the name of the selected optimization.
- The hardware table covers **21 of the 30 expected cell/start records**: three starts and eighteen O0/O1 cells. **All nine O1I cells are absent.** Nineteen records have full 3/3 success. Two SpMV records are marked failed with 2/3 successful trials, giving **61/63 reported passing trials**. The table alone cannot assign the failure cause.
- The **81/81 transfer results** match between code and paper. They evaluate the same matrix sets used by the retained-pass acceptance gate. They support transfer within that acceptance set, not a claim about untouched final-test matrices.
- The local DeepSeek smoke finished **4/4 independently audited correct final programs**; **one of four** improved over its own first correct program. The identity recorded by this cohort is `deepseek-flash`. Do not relabel it as a separately verified API model version or compare its three-attempt budget directly with Luna's 10–12 attempts.
- The local scaling worker completed **17 passing configurations out of 20**. Two one-PE strong-scaling builds exceeded PE memory. Weak SpMM at 256 PEs compiled but produced no numerical success marker. Clock alignment and timing scopes still need validation before publishing scaling efficiencies.
- The model-data export retained **44 calls**, including two truncated responses; five examples matched the old development validation records. File hashes verify. These examples need the current contract checked before SFT admission; exported prompts and outcomes do not constitute a completed GRPO training run.

The audit matches optimizer rows, hardware rows, transfer rows and eleven selected manuscript macros to their source tables. It also computes tie-aware rank agreement: 0.9048 for SpGEMM, 1.0 for SpMM, undefined for tied SpMV observations. The current paper code discards tied pairs; that gives the same values here, but a tie-aware formula should be used for future datasets with one-sided ties.

## Ordered next commits

| Priority | Contribution | Owner | Completion evidence |
|---|---|---|---|
| 1 | Reconcile the DeepSeek provider, call/candidate archive, terminal-artifact fix and validation support with the latest sparse framework | NVIDIA node | Isolated integration from `7413ed4`; overlapping edits reviewed; provider/contract/timeout/archive tests and current framework tests pass; new frozen experiment revision |
| 2 | Independently replay retained programs, especially the two improved O1I SpMV candidates | NVIDIA simulator replay; WSE node hardware replay | Exact bundles and source/build/input hashes; nine missing hardware records resolved; partial trials investigated; repeated launches and unchanged timing window verified |
| 3 | Replace provisional scaling spans with audited timing and communication measurements | NVIDIA measurement support; WSE clock calibration and hardware runs | Aligned clock reference or same-PE intervals separated from fabric makespan; operand distribution/preparation accounted for; failed 256-PE case resolved or retained |
| 4 | Run the fixed-budget matched DeepSeek study and fresh matching Luna cells | DeepSeek here; Luna on WSE node | Shared configuration and starts; API-returned identities; three-attempt smoke first, then ten tested translation candidates/ten optimization proposals, three timing repeats and three-hour limit; failures retained |
| 5 | Evaluate frozen selected programs on untouched final matrices and release a gated training export | NVIDIA validation/export; WSE hardware audit | Reference adapter validated first; candidate list sealed before scoring; no final-test feedback reaches optimization or training; exact code/cell/build matches for SFT and executable verifier for future GRPO |

Priority 1 must preserve the upstream optimizer contract correction (`80c9407` and later), local truncation rejection and call-accounting protections. The local branch also changes reference timers and sparse input handling; review those separately and version any re-baseline. Do not merge the whole branch into an active experiment or reinterpret old results under a new gate.

There is a concrete SDK coordination issue: the newest upstream benchmark uses `/tmp/xkernel_singularity_<uid>.lock`, while this node's frozen tools use `/tmp/xkernel_singularity.lock`. Those locks do not exclude one another. Before launching the integrated SDK batch, make its lock choice compatible with active local tools and confirm the node is available. Do not change running jobs or their frozen configuration.

For priority 2, the remote summaries contain no source/ELF hashes or raw per-trial hardware records. The other node should provide retained bundles, actual returned model identities, launch configuration, numerical outputs and raw timestamps through the established user-mediated handoff. Join them by task, arm, seed and artifact hash. Identical programs still count as separate attempted cell records; do not treat those rows as independent unique programs when interpreting hardware variability.

For priority 3, begin with existing SpMV/SpMM configurations. The possible insight is specific: increasing vector-distribution cost in weak SpMV versus replicated local computation in weak SpMM, and row imbalance/locality tradeoffs on skewed inputs. Test these explanations with separate preparation, communication and compute intervals. SpMM currently preloads replicated operands from the host and times no fabric exchange, so its flat local-compute curve is not an end-to-end weak-scaling result. Keep 1, 10 and 100 reuse cases for preprocessing comparisons.

For priority 4, the user's model ownership remains DeepSeek here and Luna on the WSE node. The new `HANDOFF_COLLABORATOR_20260923.md` is for a second Cerebras login account: it requests Opus translation and Luna optimization through a remote SDK relay. That is a different cohort and deployment. This node should not silently adopt that relay, invoke a different model or pool the results. The original two-model fixed-budget study and the newer three-seed exploratory cohort need separate experiment identifiers. Record any design change before launch.

## Proposed paper corrections and additions

Against paper commit `bb7f61a`, the manuscript integrator should:

1. Identify the 21 hardware records as **O0/O1 plus frozen starts**, with compiler-feedback replay pending. Report 19 full-success and two partial-trial records rather than letting “all programs pass” hide incomplete trials.
2. Describe the current transfer inputs as **acceptance-validation matrices**. Retain those findings, then add independent final-test results after selection is sealed.
3. Describe the optimizer cohort and its actual budgets accurately. Keep it separate from the forthcoming fixed ten-proposal comparison; no retroactive pooling or relabeling.
4. Add an architectural case study of the improved compiler-feedback SpMV candidates when exact artifacts and hardware measurements are available. Compare instructions, correctness, resource use and the complete declared timing interval.
5. Incorporate the NVIDIA characterization as a separate input-width/locality study. Keep GPU microseconds, simulator cycles and measured CS-3 cycles distinct, with resource counts and timing scopes.

No paper file is changed by this contribution. The WSE node remains the manuscript integrator.

## Reproduce this audit

From the repository root, using Python 3.10 or newer and only its standard library:

```bash
python3 studies/sparse-progress-20260923/audit.py --out /tmp/sparse-progress-audit.json
python3 -m unittest discover -s studies/sparse-progress-20260923 -p 'test_*.py' -v
```

[evidence-manifest.json](evidence-manifest.json) pins original Git revisions, paths and byte hashes. Local excerpts also record parent-summary hashes and locations. The snapshot contains curated tables and aggregate export statistics; no raw model prompts/replies, keys, SDK container or bulk device outputs are included. [audit.json](audit.json) is the checked result. Passing means these summaries agree; it does not establish remote binary identity, rerun numerical correctness or replace missing hardware observations.
