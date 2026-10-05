# Debugger sub-agent — design + scaffold

**Status:** design + minimal scaffold landed; full implementation deferred until
the whitelist A/B (task #69) returns signal. If the whitelist clears the
recurring `@my_pe_x` failures on Residual, the debugger's scope shrinks. If it
doesn't, this is the next thing to build.

## Why

The reviewer already classifies failures into bucket A/B/C and emits a
`SUGGESTED_DEBUG_ACTION` (e.g. *"run `cslc --list-builtins`"*, *"insert a
`<debug>.print_u32` after the `@allocate_fifo` call"*). Those actions are
*advisory* — the implementer reads them in the fix prompt but, judging from
the logs, treats them as optional hints rather than next steps.

The result is the failure modes we've measured on the 4 hard kernels:

- **Residual** repeats `@my_pe_x` hallucinations across 4+ repair attempts
- **Game-of-Life** wires fabric IDs wrong, gets 0 bytes back, no diagnostic gets run
- **FFT-1D-2D** executes but numerical mismatch — no one ever inserts a `<debug>` trace to localize where the divergence starts

The reviewer can describe these diagnostics; nobody runs them. The debugger
agent's job is to *actually run* the diagnostic the reviewer prescribes and
emit a minimal diff back to the implementer (or in some cases, directly land
the patch itself).

## When the debugger fires

In the existing repair loop (`cuda2csl.py:repair_loop` after each reviewer
verdict), the new routing logic is:

```
reviewer verdict -> bucket
  A -> architect respin   (unchanged)
  C -> contract repair    (unchanged)
  B -> DEBUGGER PATH? -> implementer fix
```

Routed to debugger when ALL of:

1. `bucket == "B"` (compile or runtime fail, no contract violation)
2. `verdict["debug_action"]` is non-empty (reviewer suggested something concrete)
3. Either:
   - **Repeat condition**: the same `failure_reason` substring (the first 80
     chars after normalization) appeared in the previous attempt's benchmark,
     OR
   - **Specific debug action verbs**: action starts with one of `run`, `grep`,
     `cslc`, `compile`, `trace`, `inspect`, `cs_readelf`
4. Debugger has fired ≤ 1 time on this kernel already (cap at 1 — debugger
   itself can fail and we don't want it monopolizing the attempt budget)

Otherwise the existing bucket-B path runs unchanged. The debugger is purely
additive — `XKERNEL_DEBUGGER=0` (the default until proven out) skips it.

## What the debugger does

Input (assembled by `cuda2csl.py`):
- `current_csl` (the failing compute file)
- `stderr_tail` (last 2 KB of compile/run output)
- `reviewer_rationale` + `debug_action` (the reviewer's verdict)
- `reference_contract` (the bundle the CSL has to plug into)
- `kernel_dir` (read-only — debugger may inspect layout.csl, run.py, etc.)

Output (emitted as JSON via prompt-and-parse, NOT real tool use over the wire
in v1 — see "Implementation strategy" below):

```json
{
  "diagnostic_run": "cslc --list-builtins | grep my_pe",
  "diagnostic_output": "<truncated stdout of the diagnostic, up to 1 KB>",
  "diagnosis": "@my_pe_x is not a builtin; the layout module exposes get_x_coord() instead",
  "recommended_patch": "REPLACE: const px = @my_pe_x();  WITH: const px: u16 = layout_mod.get_x_coord();",
  "confidence": "high" | "medium" | "low"
}
```

The orchestrator then injects this debugger report into the bucket-B fix
prompt as a *new* slot `{debugger_report}`, sitting between
`{reviewer_rationale}` and `{builtin_whitelist}`. The implementer now sees:
- The reviewer's classification (high-level)
- The debugger's actual diagnostic run + result (concrete)
- The hard whitelist (constraint)

## Implementation strategy — v1 is prompt-based, v2 is tool-use

**v1 (this scaffold).** No real tool use. The debugger is a third role —
same LLM, separate conversation thread, given:

- The 4 inputs above
- A **read-only static knowledge bundle** assembled inline by the
  orchestrator: `cslc --version` output (cached), the actual builtins
  whitelist (same constant from `prompt_cuda2csl.py`), the kernel's
  `layout.csl` body, the relevant `csl_skill_*` chunks retrieved by
  `cerebras_docs` query

- A system prompt that frames it as *"you are running a diagnostic; do NOT
  hallucinate. If the requested diagnostic isn't available in the read-only
  bundle, say so explicitly in `diagnosis` and lower confidence"*

The debugger emits the JSON above. The orchestrator parses it, injects into
the next implementer fix prompt, and proceeds. **Cost:** one extra LLM call
per qualifying B-bucket attempt; ~3-5 KB context. ETA: ~6 hours to
implement + wire + smoke.

**v2 (deferred).** Real tool use: the debugger gets a tool surface
(`cslc_dry_compile(code, args)`, `grep_corpus(pattern, corpus_path)`,
`read_kernel_file(relpath)`) and a multi-turn loop. The diagnostic_run /
diagnostic_output fields become the actual command + actual stdout, not
LLM-generated. ETA: ~2-3 days. Block v2 until v1 shows net positive on the
A/B — otherwise we're building a tool-use harness for a path that doesn't
help.

## Files to add (v1)

- **NEW** `code_translation/debugger_agent.py` (~150 LOC)
  - `class DebuggerAgent` with one entry point `diagnose(failure_input) -> DebuggerReport`
  - Static knowledge bundle assembly (cached per-orchestrator)
  - JSON-output prompt template + robust parser (falls back to empty report
    on parse failure — same fail-soft pattern as `_parse_reviewer_verdict`)
- **NEW** `q_debugger_diagnose` prompt template in `prompt_cuda2csl.py`
- **EDIT** `cuda2csl.py:repair_loop` — debugger invocation between the
  reviewer verdict and the bucket-B fix prompt
- **EDIT** `csl_bundle_fix_with_review` — new `{debugger_report}` slot
  (defaults to empty string when debugger didn't fire)

## Out of scope for v1

- Editing CSL files directly (debugger ONLY emits suggestions; implementer is
  the only writer)
- Spawning csdb / running the simulator from the debugger
- Multi-turn debugger conversations (one shot per fire)
- Architect/reviewer A-bucket debugger paths (B only)

## Verification plan

1. **Unit tests** (no LLM): force a synthetic failure with `@my_pe_x` in the
   CSL, run `DebuggerAgent.diagnose()`, assert the recommended_patch field
   names the layout module idiom.

2. **Single-kernel smoke**: Residual on gpt-oss-120b with debugger ON.
   Compare against today's whitelist-on smoke (which should land while this
   doc is being read). Look for: (a) debugger fires at least once, (b) the
   recommended_patch is non-trivial, (c) the next implementer attempt
   produces CSL that doesn't repeat the original error.

3. **Full A/B** if smoke is positive: 4 hard kernels × 2 configs
   (debugger-OFF vs debugger-ON) × 3 models. Same harness shape as
   `run_ab_skills.sh` / `run_ab_whitelist.sh`.

## Risk + cost

| Risk | Mitigation |
|---|---|
| Extra LLM call adds wall time | Cap at 1 fire/kernel; gate by repeat-condition so non-degenerate runs skip it |
| Debugger hallucinates a "diagnostic run" that wasn't actually executed | v1 system prompt explicitly frames the bundle as read-only — confidence required to be "low" if action wasn't in the bundle. v2 fixes this fully with real tool use. |
| Debugger report contradicts reviewer rationale | Implementer fix prompt instructs: "trust the debugger's recommended_patch when both are present" |
| Implementation accidentally breaks current pipeline | `XKERNEL_DEBUGGER=0` default; this is a pure-add wire, no edit to existing reviewer/bucket-B path |
