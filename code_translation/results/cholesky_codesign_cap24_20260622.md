# Cholesky co-design — higher cap (24) + collectives_2d exemplar (2026-06-22)

**Setup.** Follow-up to the cap-12 co-design run. Added a firewall-safe
cross-file `collectives_2d` wiring exemplar to the KB (sourced from TRAIN
collectives kernels + SDK, 0 Cholesky-reference leak markers) and raised the cap
to 24. `XKERNEL_CODESIGN_LAYOUT=1 XKERNEL_CODESIGN_EXEMPLAR=1`, hints + splice on.
Reference baseline 12,479 (hidden). Both env flags confirmed in the live process;
exemplar + factorization hint both confirmed reaching the implementer.

## Result: still 0 pass — but the blocker moved to the ALGORITHMIC CRUX (big progress)
The run terminated at **attempt 9** (hit the architect re-spin cap of 2, not the
24 attempt cap). The failure profile transformed vs cap-12:

| metric | cap-12 (no exemplar) | cap-24 + exemplar |
|---|---|---|
| collectives-wiring desync errors | dominant (most attempts) | **2** (exemplar fixed it) |
| abandonment (prose / stub) | present early | **0 pure-prose; 0 no-op stubs** |
| compile-fail attempts | most | **3** (early, loop-fixed) |
| **ran-but-numerically-wrong** | rare | **5** — kernel COMPILES + RUNS + reaches the correctness check |
| final artifact | partial | **383-line complete co-design** (compiles, runs) |

**The decisive shift:** from attempt 5 onward the failure is ONE consistent,
semantic error: *"output is diagonal-only (off-diagonals zero) while expected L is
dense lower-triangular; PE(0,0) tile correct on its diagonal."* The agent now
produces a **complete, compiling, running** distributed-Cholesky co-design that
gets the **diagonal-block factorization right** and fails ONLY on **delivering the
off-diagonal panel / trailing-update (TRSM + Schur) operands** across the mesh.

## What this localizes (the real finding)
Cholesky's difficulty has now been peeled to its core, one layer at a time:
1. cap-12 single-file: STRUCTURAL — can't author routing → rational abandonment.
2. cap-12 co-design: abandonment gone, but stuck on cross-file collectives WIRING.
3. **cap-24 co-design + exemplar: wiring SOLVED → stuck on the ALGORITHMIC CRUX —
   the off-diagonal Schur/TRSM data flow.** This is the genuine mathematical heart
   of distributed blocked Cholesky (the diagonal is the easy part; the trailing
   update is what makes it hard), and it is now the *only* thing standing between
   the agent and a pass.

This is a textbook "diagonal-only" partial Cholesky — exactly the classic failure
of getting the local factorization but not the distributed Schur complement. The
agent reaches it from CUDA, firewalled, having co-designed the whole compute +
collectives routing itself.

## Why it didn't cross to a pass
- The **architect re-spin cap (2)** ended the run at attempt 9, well before the
  24 attempt budget — the reviewer classified the diagonal-only result as a design
  (bucket A) problem, re-spun the architect twice, then demoted to B and ran out.
  The off-diagonal data flow is a DESIGN fix (which PE sends which panel block to
  which PE for the trailing update), and the design-respin budget, not the attempt
  budget, was the binding limit.
- The remaining gap is real algorithm-on-fabric difficulty: routing the
  rank-Nt trailing update so every interior PE receives BOTH its row-panel and
  column-panel operand each step. The reference solves this with the diagonal-PE
  row→column relay; the agent's collectives-based design hasn't reproduced an
  equivalent.

## Conclusions
- **Two firewall-safe levers (co-design + collectives exemplar) peeled Cholesky
  from "can't even write routing" to "complete kernel, correct diagonal, missing
  only the off-diagonal Schur routing."** That is substantial, measurable progress
  on the hardest kernel — and it keeps localizing the difficulty honestly.
- The next lever is NOT more attempts or more wiring help — it's the **architect
  re-spin cap** (raise it for co-design) and/or a firewall-safe hint about the
  trailing-update data-flow pattern (every interior PE needs row-panel AND
  column-panel each step). Both deferred — this is now a design-search-depth
  problem, not a knowledge or abandonment problem.

Artifacts: final 383-line pe.csl at
`results/cholesky_codesign_cap24_20260622/run_20260622_151026/Cholesky/pe.csl`.
Exemplar: `csl_knowledge_base.COLLECTIVES_2D_CODESIGN_EXEMPLAR`.
