# Improving CUDA→CSL Translation Quality

*Design document for the cuda2csl agentic system · 2026-06-19*

## 1. Problem statement

The cuda2csl pipeline stages a CUDA→CSL port as Analyzer → Architect → Implementer → Reviewer, with a hard firewall: the implementer sees `layout.csl`, `run.py`, and `commands.sh`, but never the reference `pe.csl` or `benchmark-libs/*.csl` source. A compute-leak canary (`cuda2csl.py::_assert_no_compute_leak`, exercised on every `_llm_call` and unit-tested in `test_no_compute_leak.py`) enforces it. Every lever below preserves this invariant — nothing here leaks the answer.

The evidence isolates **translation**, not optimization, as the gap. W2 (optimize-from-visible-reference) is strong: 14/14 kernels beat the human baseline at 1.44× geomean. W1 (translate-from-CUDA) at cap-8 passes only **2/21**, and critically **18/18 failures thrash rather than converge**. The binding constraint is *information starvation*, not iteration budget — agents burn their budget rediscovering facts that are hidden behind the firewall, and 9/18 failures show `root_cause_visible=false`. The smoking gun is `tool_use:0`: reviewers instructed agents to "open pe.csl and list params," but the agent had no tool and no access, producing an unwinnable loop (seen on Power-Method, CG).

Failure is **multi-layered**, and single levers *shift* the bottleneck rather than remove it. The lever-1 A/B (`results/lever1_ab_report_20260619.md`) is the proof: extracting hidden library signatures dropped `dsr_arity_mismatch` errors 67% (21→7 per-attempt), but clearing that layer **exposed** layer 2 (`queue_or_ut_id` +125%) and layer 3 (`contract_entrypoint` +100%, `halo_unblock_stall`). The layered failure families are: `dsr_arity_mismatch`, `uninitialized_param`, `queue_or_ut_id`, `task_id_range`, `halo_unblock_stall` (0-byte D2H hang), `hcf_runtime`, `shadow_or_decl`, `contract_entrypoint`. A correct strategy must clear several layers *additively*, then validate each by its own failure-family delta.

## 2. Intermediate representation — recommendation

Three IR shapes were evaluated: (A) a structured, machine-checkable `DESIGN.md` schema; (B) a typed wafer-dataflow DAG between design and CSL; (C) the CUDA→NL-SPEC→CSL two-hop already prototyped in `code_translation/explore_modes/mode_cuda_nl.py` (`q_cuda_nl_to_spec`, `q_cuda_nl_design_from_spec`, currently wired into W3 explore, *not* W1).

**Recommendation: adopt (A) now; defer (B); keep (C) as the W3 explore default, not a W1 prerequisite.**

The architect→implementer hand-off is where 9/18 invisible-root-cause failures originate. Free-text `DESIGN.md` is lossy: an architect can say "row-tiled A" without committing tile dimensions, and the implementer then invents wrong dimensions and wastes 3–4 attempts. Option (A) replaces the prose with typed fields (`mesh_shape`, `tensor_shards`, `reduction_tree`, `communication_primitives`, `memory_estimate`, `edge_cases`) plus a Python validator that catches architect mistakes *before the implementer sees them* (tile dims that contradict `layout.csl`'s `Px`, a 45 KB estimate against a 40 KB budget, a missing halo edge case). This is the same mechanism lever-1 already proved upward: lever-1 surfaced a *structured fact block* (library signatures) and cut the #1 error family 67%; a DESIGN schema applies that discipline to the decomposition contract itself. It is low-effort (1–2 days, ~250 LOC validator, prompt edits), non-invasive (format only; compute stays hidden), and carries zero firewall risk because the schema is metadata about *how* to decompose, not the compute.

Option (B), the dataflow DAG, is genuinely higher-reach — it makes the decomposition *falsifiable* against the reference contract before a line of CSL is written — but it adds a new schema, an orchestrator change, and a ~300 LOC DAG→CSL binding generator, and risks either verbosity (hundreds of nodes on large meshes) or a subtle canary bypass (reference pseudocode smuggled in a node's `.fn`/`.comment` field). Defer it to a 2-week follow-up, and only for architectures beyond the gemm/stencil cluster.

Option (C) is lossy-but-fresh: stripping `blockIdx`/`warp`/shared-mem out of the SPEC prevents the architect from copying GPU bias (e.g., "one warp per PE," which is nonsense on a wafer). But it can drop precision-sensitive idioms — a `__shfl_down` reduction becomes "reduce in log steps," losing the exact order. That makes (C) the right tool for *architecturally different* kernels (a fallback when direct W1 exhausts its respin cap), **not** for pixel-perfect porting, and not a gate on the W1 path. It is already isolated in `explore_modes/`, so promoting it to the W3 default is cheap.

## 3. What to inject during translation (prioritized, firewall-safe)

The injection stack maps one-to-one onto failure families. Two layers are already shipped this session:

- **[DONE] Layer 1 — library-signature extraction.** `library_signatures.py` reads only `param <name>: <type>` and `pub fn` *interfaces* from the imported `benchmark-libs/*.csl` (headers, never bodies) and injects a compact block into the reference contract via `build_reference_contract` (`cuda2csl.py:584`). Kills `dsr_arity_mismatch`. **Validated: −67%.**
- **[DONE] Layer 2 — queue/ut_id discipline note.** `library_signatures.py:192` fires `_QUEUE_DISCIPLINE_NOTE` when the extracted signatures mention `queues`/`dsr_ids`/`ut_id`: the 0–7 ID range, memcpy's reserved queues, the comptime `@initialize_queue` requirement, and the distinct-ut_id-per-concurrent-op rule. Curated general SDK knowledge, not bench-specific. Targets `queue_or_ut_id` — the family lever-1 *exposed* (+125%). **Not yet A/B-validated; error-family instrumentation is in place.**

Ranked next, by (family coverage × firewall-safety ÷ effort):

1. **[PROPOSED] SDK module schemas (collectives_2d / memcpy), hand-curated.** The extractor skips SDK modules — they live in the cslc container, not on disk — so the agent invents `collectives_2d` field names (`.dim_size` for `NUM_PES`, missing `.c2d_params`). Inject accurate field schemas *extracted from real SDK 1.4.0 csl-examples source* (cite the version). Targets the 3/18 collectives cluster and the `contract_entrypoint`/undefined-symbol rise. Stopgap until container-side extraction lands; flag-gated, one swappable table.
2. **[PROPOSED] Compile-error→gotcha micro-retrieval.** A lookup table (error-regex → gotcha-id) that matches the cslc stderr tail and injects a targeted fix (`expected i16, got u16` → `@as(i16, …)` rule; "queue already set" → reservation gotcha). Stops the agent re-discovering the same syntax bug across 2–3 attempts. Brittle to cslc message-format drift — log a diagnostic on no-match.
3. **[PROPOSED] DSR/queue budget facts at the *architect* stage.** Compute, from `layout.csl` and the library signatures, "8 DSRs per direction; modules claim N; M free" and "memcpy owns queues 0–3; you have 4–7." Many conflicts are *architectural* over-commitments; surfacing the ledger lets the planner avoid them. Preventive, complements injection at the implementer.
4. **[PROPOSED] Halo async-recv micro-example retrieval.** When `is_*_edge` guards + `@bind_data_task` + `fabin_dsd`/async appear *in the implementer's own code*, retrieve a 15–20 line canonical halo-recv idiom **from csl-examples tutorials only** (topic-15, topic-11) — never the bench `pe.csl`. Targets `halo_unblock_stall`. Add a WSE-2/WSE-3 arch guard; the topic-15 microthread idiom is WSE-3-specific.

## 4. Base-design-safe enhancements (additive, ablatable)

- **[PROPOSED, highest leverage] Scoped reader / debugger v2.** `debugger_agent.py` is v1 prompt-only by design (v2 deferred until v1 shows net positive). v2 gives the debugger a **Read tool scoped strictly to firewall-visible files** (`layout.csl`, `run.py`, `commands.sh`, the contract — never `pe.csl`, never lib source, canary-enforced). This directly fixes the `tool_use:0` pathology: when the reviewer says "list the layout-exported symbols," the debugger runs `grep 'pub fn' layout.csl` and returns *real* output instead of hallucination. ~300 LOC, multi-turn loop; smoke-test before enabling.
- **[PROPOSED] Structured-error reviewer + targeted repair routing.** Extend `q_review_failure` to emit JSON with an `error_family` tag, then route bucket-B failures to family-specific fix prompts (queue recipe / halo diagnosis / entrypoint checklist). Today the same generic bucket-B prompt goes to all failures; the classification the reviewer already implies isn't used downstream.
- **[PROPOSED] Compile-only dry-check.** Run `cslc --verbose-errors` (~2 s) before full simulation (~30 s). Rejects non-compiling bundles immediately, freeing budget. No pass-rate change expected — a *speed* lever (~30% faster convergence). `error_family.py` already parses cslc output.
- **[PROPOSED] Progressive layer-clearance memory.** When a family clears (dsr → 0), record it and tell the next repair prompt "Layer 1 cleared in attempt 3; don't regress." Traces show backsliding after clears (Power-Method: `shadow,dsr,queue,queue,…`). Advisory, not a hard constraint.
- **[PROPOSED] Entrypoint contract checklist.** Auto-fill, from `layout.csl`'s `@export_name` list (already parsed in `translation_facts.py::_extract_export_names`), a per-entrypoint checklist (`@export_symbol` present; body ends in `unblock_cmd_stream()` on every path; every PE reaches unblock). Guard against false positives: "unblock only if host-launched" — checkable from the visible `run.py`.

## 5. Evaluation plan

A reviewer will demand each lever be isolated by its own family delta, not a noisy pass counter.

- **Per-lever error-family ablation** (the robust signal). Env-gate each lever (`XKERNEL_LIB_SIGNATURES`, `XKERNEL_QUEUE_UT_ID_GOTCHAS`, …) and count the *targeted* family per attempt, OFF vs ON. Expected: lib-sigs −60±10% (replicate the 67%); queue facts −30±15%; halo retrieval → `halo_unblock_stall`≈0. Verify off-target families don't silently regress.
- **Multi-seed pass-rate** (3–5 seeds, same model). One seed is not evidence — 7pt-Stencil passed in the lever-1 A/B but failed in the full sweep. Report a per-kernel seed×(pass/fail) matrix with CIs, and **separate reliably-converging kernels (steady error-family progression) from lucky-variance winners.**
- **Cap study.** cap-8 vs cap-20 with the full stack. Honest caveat: higher pass-rate may reflect injection *reducing model variance*, not core framework strength — the framework's claim is W1 correctness, not optimization.
- **Cycles vs reference** (only for kernels that pass) — confirms a correct translation, separate from W2's optimization story.
- **Firewall regression.** Unit-test the canary against real `pe.csl` snippets from 10 kernels; audit every new knowledge block for reference-compute patterns; second-stage `final_result.json` audit for stray `.csl`/`.cu` source.

## 6. Paper framing

**Novelty** is the *failure analysis*, not a new translation algorithm: LLM agents fail at spatial compilation because of **information asymmetry** — hidden library contracts behind a firewall — and *recovering that information* is a general principle transferable to other spatial ISAs (Graphcore, Tenstorrent). The layered-bottleneck result (clearing layer 1 *exposes* layers 2–3) is itself a contribution. **Baselines:** one-shot LLM (no repair loop) and agentic cap-8/cap-20, all on the *same* model (Opus), so any gain is attributable to architecture, not model tier. **Threats to validity, stated honestly:** (1) lever-1 is validated at family level, not yet pass-rate; (2) layer-2/3 levers are un-validated and may over- or under-specify; (3) hand-curated SDK schemas are version-specific debt (label SDK 1.4.0, mark as stopgap); (4) W2's 14/14 is unsurprising — the reference is visible, so keep W1 and W2 narratively separate to avoid conflating translation failure with optimization headroom; (5) no single lever converts multi-layered failure to a pass — this is a *necessary-but-insufficient* bundle.

## 7. Ranked roadmap

1. **A/B-validate the queue/ut_id discipline (DONE-but-unproven), multi-seed.** Highest value/effort: the code shipped; only the experiment is missing. `[firewall-safe] [base-additive] [effort: low — orchestration]`
2. **Structured DESIGN.md schema + validator (IR option A).** Closes the architect→implementer gap behind 9/18 invisible failures. `[firewall-safe] [base-additive] [effort: low, 1–2 days]`
3. **Scoped reader / debugger v2.** Kills the `tool_use:0` smoking gun on the hardest kernels. `[firewall-safe] [base-additive] [effort: high, ~300 LOC, 2–3 days]`
4. **Hand-curated collectives_2d / memcpy SDK schemas.** Unblocks the 3-kernel collectives cluster lever-1 can't reach. `[firewall-safe] [base-additive] [effort: low + extraction setup]`
5. **Structured-error reviewer + targeted repair routing.** Makes layer-specific recipes reachable; compounds 1–4. `[firewall-safe] [base-additive] [effort: medium]`
6. **Compile-only dry-check + progressive layer memory.** Speed and anti-regression; multiply the above under fixed cap. `[firewall-safe] [base-additive] [effort: low each]`
7. **Halo async-recv retrieval (arch-guarded).** Attacks `halo_unblock_stall` once layers 1–2 are clear. `[firewall-safe] [base-additive] [effort: medium]`
8. **Multi-seed cap-20 full-stack sweep.** Converts mechanism wins into the paper's pass-rate claim, with per-kernel CIs. `[firewall-safe] [base-additive] [effort: medium — 20–30 GPU-hrs]`
9. **Wire mode_cuda_nl as a W1 fallback on respin-cap exhaustion; make it the W3 default (IR option C).** Orthogonal reach for architecturally-different kernels. `[firewall-safe] [base-additive] [effort: medium, 2–3 days]`
10. **Wafer-dataflow DAG IR (option B).** Deferred; only if layer-3 contract violations remain the bottleneck after 1–9. `[firewall-safe] [base-invasive] [effort: medium-high, 3–5 days]`

---

*Document file (if persisted by caller): the synthesis above is the deliverable; no file was written. Code references: `/home/USER/xkernel/code_translation/cuda2csl.py`, `/home/USER/xkernel/code_translation/prompt_cuda2csl.py`, `/home/USER/xkernel/code_translation/library_signatures.py` (lever-1 + queue discipline, DONE), `/home/USER/xkernel/code_translation/debugger_agent.py` (v1, v2 proposed), `/home/USER/xkernel/code_translation/explore_modes/mode_cuda_nl.py` (NL-IR, W3-only), `/home/USER/xkernel/code_translation/test_no_compute_leak.py` (canary test). Evidence: `/home/USER/xkernel/code_translation/results/w1_failure_analysis_20260618.md`, `/home/USER/xkernel/code_translation/results/lever1_ab_report_20260619.md`.*