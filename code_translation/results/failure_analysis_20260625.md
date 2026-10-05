# Sweep failure analysis + firewall-safe patches (2026-06-25)

Source: 17-agent workflow over the 8 failures in agent sweep
`agent_full_sweep_20260624_205754`. Each failed kernel's repair-loop trace was
root-caused; each proposed fix was adversarially leak-audited (no-hardcode / no-leak)
before landing. Method mirrors the prior C1–C10 round
(failure_analysis_improvements_20260623.md).

## Failures analyzed (8)
test-split: Cholesky, FFT-1D-2D, Game-of-Life, Laplacian2D-Halo, Histogram.
train-split: GEMV, CG, Preconditioned-CG.

## Patches LANDED (4, all audited firewall_safe / narrowed, default-on gated)

| # | cluster | kernels helped | surface | what |
|---|---|---|---|---|
| **R1** | in-place-accumulate DSR | PCG, CG, Power-Method, BiCGSTAB, GEMV-Coll-2D (5) | `library_signatures.py` `_LIB_OVERLAY_NOTE` | state `src0_dsr_ids[0] == dest_dsr_ids[0]` for the in-place reduction libs (stencil_3d_7pts/allreduce/collectives_2d); the note previously *showed distinct ids* — teaching the bug. Scoped to those libs, not universal. |
| **R4** | SDK library-signature gap | Histogram | `library_signatures.py` `discover_imported_libs` | map `<kernels/.../layout>` → sibling `<kernels/.../pe>` (analogue of the collectives_2d remap) so the agent sees the real `<kernels/tally/pe>` interface (`bump_tally`/`send_and_reset_tally`/params), extracted live from the SIF. |
| **R2** | per-tile route config | FFT-1D-2D (+ any multi-PE fabric kernel) | `csl_knowledge_base.py` new gotcha | `@set_local_color_config`(2-arg, compute) vs `@set_color_config`(4-arg, layout) arity; receive routes take a single source; funnel-and-inject on TX. Reference-transcribed `.switches` snippet dropped per audit. |
| **R3** | queue-init salience | Laplacian2D-Halo (+ halo kernels) | `csl_knowledge_base.py` halo-receive discipline | make output-queue `@initialize_queue` explicit + SYMMETRIC (send side, not only receive). Honest: salience bump of an already-shipped fact; evaluate as multi-seed A/B, not a claimed single-draw fix. |

All four: general Cerebras/CSL/SDK platform facts or the SDK library's public interface —
no hidden-reference compute, no per-benchmark hardcoded tactic. Firewall verified (canary
not in contract; no CUDA constructs in the new text). Ride existing default-on gates
(`XKERNEL_LIB_SIGNATURES`/`XKERNEL_LIB_OVERLAY_NOTE`/`XKERNEL_W1_GOTCHAS`). 127 tests green.
Commits: ff82029 (R1+R4), dbff285 (R2+R3).

## Patch DEFERRED (1, partial / leak-risk)
- **R5 GEMV — output-placement / d2h-shape** (`partial`, `needs_narrowing`). The
  firewall-safe core is the SDK shape constraint (a 1-D host dest needs the gather region
  `cw=ch=1`; reduce partials into one contiguous `[full_len]` array before D2H). But the
  audit flagged that the "ONE PE holds the whole output" framing edges toward the hidden
  decomposition (which PE is the residue of C8). Deferred: the residual is a
  hidden-decomposition ceiling, not a clean general fact. The already-shipped C4
  collectives-introspection + R1 DSR fix cover GEMV's *arity/accumulate* errors.

## Honest NON-fixable failures (firewall ceilings / draw-noise)
These are the benchmark working as intended — NOT scoreability defects, NOT patched.

- **CG — not firewall-safely fixable.** Numeric near-miss: an un-converged `max_ite`
  iterate compared at `run.py` rtol=1e-5 leaves a deterministic ~3.6e-3 reduction-order
  mismatch the agent can't cross. The only levers are reference-path/harness decisions
  (calibrated tolerance / higher max_ite), outside agent-side knowledge. No KB patch.
- **Cholesky — firewall-DESIGN ceiling (residual).** R-merge (the right-looking
  3-phase completeness invariant + "use every routing axis the layout provides") was
  audited firewall_safe BUT judged low-to-inert: the agent had the full reference layout
  shown (standard mode) and still dropped the trailing SYRK/Schur update + ignored
  `row_color`. The genuine residual — engineering the row-relay send/recv matching across
  diagonal/fringe/interior/inactive roles on the pop_on_advance fabric — cannot be handed
  over without reproducing the reference's data-flow schedule (leaky). NOT landed as a
  standalone hint (avoids prompt bloat on a fact already ignored 16/20).
- **Game-of-Life — partial / draw-noise dominated.** Audited firewall_safe receive-side
  rules exist (a receiver can't infer a sender's phase from its own; don't multiplex one
  data task across phases via a mutable flag) BUT GoL is a documented ~1/3–1/2 fragile
  fabric kernel — a single-draw miss is often unrelated draw-noise. Not landed standalone;
  would need multi-seed A/B to show signal.
- **GEMV / PCG numeric tails** — hidden-decomposition (C8) + fp-accumulation (C7)
  residues; honest ceilings the R1/R4/R2 patches don't claim to close.

## Recommended next action
Re-run a multi-seed A/B (`XKERNEL_LIB_OVERLAY_NOTE` + `XKERNEL_W1_GOTCHAS` on vs off)
across {PCG, CG, Power-Method, BiCGSTAB, GEMV-Coll-2D, Laplacian, Histogram} to measure
the R1–R4 lift with variance bars — never a single-draw claim on the fragile fabric
kernels (Finding-A discipline).
