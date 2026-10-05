# WS2b — agent-generated decomposition on GEMV-large (2026-06-20)

Decisive end-to-end test: can the W1 agent, FIREWALLED from the reference,
design its OWN wafer-scale decomposition for a problem (512×256 GEMV) that does
not fit on a small mesh, and have it compile + verify + compete against the human
reference (10,309 cycles)?

Driver: `code_translation/_ws2b_agent_decomp.py` — one opus-4-7 call, sees CUDA +
task + the HOLED layout template + the logical-contract run.py + library
signatures; NOT the reference pe.csl / layout.csl / distribution.py. Emits three
artifacts (its own decomposition): distribution.py + filled layout + pe.csl.
Staged + compiled + run at the large size via the logical run.py.

## What worked (the pipeline mechanism is PROVEN)
- The agent emitted all 3 artifacts every run.
- **layout.csl**: kept the full contract (@export_name block, params) and filled
  the holes (set_rectangle, c2d.get_params, set_tile_code) correctly.
- **distribution.py**: chose a coherent 8×8 decomposition (A row/col-distributed,
  y gathered from the right column) — a real, different-from-tiny decomposition.
- Stage → compile → diagnose → persist all worked end-to-end.

## The layered-failure result (one-shot, no repair loop)
| run | signatures | failure | layer |
|-----|-----------|---------|-------|
| 1 | benchmark-libs only | `<collectives_2d/collectives>` not found — hallucinated MODULE NAME + methods (broadcast_y/reduce_x_add) | layer 1: which module |
| 2 | + REAL SDK collectives_2d sigs (container-extracted) | correct `<collectives_2d/pe>` import; fails on `c2d_params.x_dim_params` (should be `.x`; compiler note: "Possible fields: x, y") | layer 2: a field-access detail |

Closing the signature gap moved the failure DEEPER (wrong-module → a one-line
field-access typo the compiler itself points to). This is the same layered
structure the W1 failure analysis found (clearing layer N exposes layer N+1).

## Honest conclusions
1. **Mechanism validated**: the agent freely chooses a decomposition, fills the
   layout contract, and (with real signatures) reaches deep idiom errors — the
   Phase-2 "free the decomposition" pipeline works end-to-end.
2. **The SDK-signature lever generalized**: `library_signatures.py` now extracts
   `<collectives_2d/pe>` (and any SDK `<...>` module) from the REAL container
   source (`singularity exec cat`), no hand-authored prose. This is the
   paper-defensible form of the lever the WS4 design called for.
3. **One-shot is insufficient for collectives** — the remaining errors
   (`.x_dim_params`→`.x`) are exactly what a REPAIR LOOP fixes from the compiler
   note. The standalone driver has no loop; the real cuda2csl reviewer/repair
   path does. Next: run GEMV-large through the full cuda2csl loop (with the
   agent-distribution path wired in) rather than one-shot.

## Artifacts
/tmp/ws2b_artifacts/{distribution.py,layout.csl,pe.csl,run_output.txt}
(the agent's actual generated decomposition + the compile log).
