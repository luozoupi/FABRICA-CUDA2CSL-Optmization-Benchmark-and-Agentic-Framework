# Cholesky co-design experiment — let the agent author layout.csl too (2026-06-22)

**Question.** Cholesky is the one held-out test kernel the pipeline can't pass, even
with firewall-safe hints. The hinted-retry finding was that its ceiling is STRUCTURAL:
the hidden, immutable `layout.csl` (single-injector-per-column switch-relay routing)
can't deliver the trailing-update operand, and the agent — forbidden to write the
layout — rationally ABANDONS (prose/stub/diagonal-only). Test that directly: give the
agent the ability to author BOTH `pe.csl` AND `layout.csl` from scratch (full
co-design), firewall STRENGTHENED (both reference files hidden + canaried). Does
Cholesky become translatable?

**Harness.** New gated mode `XKERNEL_CODESIGN_LAYOUT=1` (default off, existing path
byte-identical). Agent emits two fenced blocks (`csl:pe.csl` + `csl:layout.csl`);
reference layout is withheld from all prompts and protected by a second canary
(`_set_layout_canary`, keyed on a routing line); agent's layout overlaid onto the
staged bundle (`extra_overlays`); compile picks it up (`cslc ./layout.csl`). Run:
opus-4-7, hints on, splice on, cap 12. Reference baseline 12,479 (measured, hidden).

## Result: still 0/12 — but the FAILURE CHARACTER CHANGED COMPLETELY (that's the finding)

| | layout-locked (baseline + hint) | co-design (this run) |
|---|---|---|
| outcome | 0/12 fail | 0/12 fail |
| **abandonment** (prose / stub / diagonal-only) | **5+ of 12 attempts** | **0 of 12 attempts** |
| failure class | STRUCTURAL: "the given layout can't route the operand" (agent's own words) | cross-file interface / SDK-API-arity / comptime-type errors — all FIXABLE |
| what the agent did | resigned (can't fix routing it isn't allowed to write) | **actively co-designed** its own routing + compute, iterating to the last attempt |
| final compute file | repeatedly a no-op stub or diagonal-only | **145-line complete pe.csl** (real, full) |
| agent's layout | n/a (immutable reference) | **55-line agent-authored layout** with `@set_rectangle` + `@set_tile_code` + routing |

**The headline finding: removing the firewall constraint ELIMINATED the rational-
abandonment behavior entirely.** Given the ability to author routing, the agent stopped
giving up and started genuinely engineering a compute+routing system — 0 abandonment
markers vs 19 co-design-debugging markers across the run. It even chose a DIFFERENT,
simpler routing strategy than the reference: `<collectives_2d>` broadcast/reduce instead
of the reference's hand-rolled `pop_on_advance` switch relay. This confirms the prior
diagnosis was correct: **the abandonment was caused by the firewall (an unsolvable
constraint), not by an inability to reason about the algorithm.**

## Why it still didn't pass in 12 attempts (failure localized one level deeper)
The 12 verdicts (all bucket B/C, never abandonment) show the agent stuck on the
WIDTH of the co-design problem, not a dead end:
1. **A recurring SDK-syntax gotcha burned ~4 attempts (4–7):** `@ptrcast([*]u32, &tile)`
   uses an old two-arg form; the current SDK signature differs. This is a pure
   knowledge gap (fixable with a KB gotcha), not a reasoning failure — but it consumed a
   third of the repair budget on a syntactic detail.
2. **collectives_2d API integration (2, 7, 8, 10):** the agent committed to a
   collectives-based routing and kept getting the `c2d.get_params` arity / the
   `c2d_x_params`/`c2d_y_params` param wiring between its two files slightly wrong.
3. **Cross-file param contract (1, 9, 11, 12):** pe.csl declared params (Y_panel,
   X_panel, queue/task ids, drive_task_id…) that its own layout didn't pass, or vice
   versa — the two-file interface it must keep consistent is now wider (it owns both
   sides), so there are more places to desync.

Net: co-design turns ONE hard structural wall into a WIDER but TRACTABLE surface of
fixable errors. 12 attempts wasn't enough to converge a from-scratch two-file
collectives-routed distributed Cholesky, especially with ~4 attempts lost to the
`@ptrcast` gotcha. This is a budget/knowledge-gap result, not a structural one.

## Conclusions (for the paper)
- **The structural-ceiling hypothesis is CONFIRMED and now falsifiable-tested.** The
  firewall (compute writable, routing hidden+immutable) was the cause of Cholesky's
  abandonment: lifting it removed the abandonment behavior 5+/12 → 0/12.
- **Co-design is the right harness for compute+routing-coupled kernels**, but it widens
  the problem; passing distributed Cholesky needs more budget and two fixable
  knowledge injections (the `@ptrcast` arity gotcha; a collectives_2d co-design
  exemplar — both firewall-safe).
- **Firewall held throughout** — no canary leak across 12 attempts; the agent's layout
  (55 lines, collectives-based) is demonstrably its own design, structurally unlike the
  113-line reference switch-relay layout.

## Follow-ups (firewall-safe, ranked)
1. **Higher cap (20–24) for co-design runs** — the surface is genuinely wider (the
   agent owns both sides of the pe↔layout interface), and 12 attempts under-samples it.
   Highest-leverage single change.
2. A collectives_2d *co-design* exemplar in the KB (how to wire `c2d_x_params`/
   `c2d_y_params` consistently across pe.csl + layout.csl) — the agent committed to a
   collectives strategy and repeatedly desynced the cross-file params; this is the one
   recurring, fixable, firewall-safe knowledge gap.
3. Re-run Cholesky co-design with 1–2 to see if it crosses to a pass.

**NOTE — corrected a misdiagnosis:** the reviewer blamed a `@ptrcast([*]u32, &tile)`
"old two-arg form" on attempts 4–7, but the reference kernels themselves use exactly
that two-arg form (`@ptrcast([*]u32, &x_tile)` in GEMM-Collectives-2D etc.) — so it is
CORRECT and a `@ptrcast` gotcha would be wrong. The attempts-4–7 errors were elsewhere
in the comptime block (the reviewer's "likely" hypothesis was speculative). Verified
2026-06-22 against the kernel corpus; do NOT add a @ptrcast arity gotcha.

Artifacts: final pe.csl preserved at
`results/cholesky_codesign_20260622/run_20260622_043218/Cholesky/pe.csl` (145 lines).
Mode: `XKERNEL_CODESIGN_LAYOUT=1` (cuda2csl.py + prompt_cuda2csl.py + benchmark_csl.py).
