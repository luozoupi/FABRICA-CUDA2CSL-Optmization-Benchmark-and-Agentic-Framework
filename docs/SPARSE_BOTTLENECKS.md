# Where the sparse kernels lose their cycles, and what to do about it

Compiler- and ISA-level analysis of the sparse suite, 20 September 2026. Every number is
either measured here (recompiling each program with disassembly capture, `XKERNEL_IR_CAPTURE=disasm`)
or taken from the silicon characterisation in `studies/wse3-characterization/FINDINGS.md`.
Its purpose is to say precisely what the agent should be optimising, and to justify the angles
it is given.

The method matters for reading the numbers. `cycles_send` is the device-internal count of the
**slowest PE**, so cost per nonzero must be divided by the nonzeros of the *busiest* PE, not by
the matrix total. The runner's own `cycles_per_nnz` divides by the total and therefore reads
4x optimistic on a four-PE strip; the per-PE figures below are the ones to compare against the
cost ladder.

## The cost ladder this suite is measured against

One PE, 16x16 banded matrix, 60 nonzeros, all four verified exactly against numpy
(FINDINGS 10n):

| form | cycles/nnz | against scalar |
|---|---:|---:|
| scalar CSR gather | 36.2 | 1.00x |
| runtime-length DSD per row | 31.8 | 1.14x |
| diagonal, vectorised across rows | 7.3 | **4.96x** |
| *(broken register reduction: wrong answer)* | 18.5 | — |

The rule the study drew from it is not "replace the gather with a descriptor" but **eliminate
the horizontal reduction by choosing the vectorised axis**. Per-row blocking is the consolation
prize, worth 14%.

## Bottleneck 1 — SpMV is on the slowest rung, and its matrix is diagonal

The translated kernels and the reference both write the textbook body,
`sum += val[j] * x[col_idx[j]]`, and the single descriptor operation in the compiled program is
the fabric broadcast of `x`, not the inner product.

| | value |
|---|---|
| busiest PE holds | 1,037 of 3,750 nonzeros |
| cycles | 36,238 |
| **cost** | **34.9 cycles/nonzero** — the scalar rung (36.2) |
| training matrix | HB/sherman1, 1000x1000, row length mean 3.75 |
| **structure** | **6 diagonals hold 90% of the nonzeros**; `struct_few_diagonals` fires |
| implied target | 7.3 cycles/nnz, about **4.8x**, or roughly 7,600 cycles |

This is the clearest headroom in the suite, the trigger key already fires, and neither arm of
the translation sweep took it. Translation does not use angles: the structure readout tells the
agent what the matrix looks like, but the transformation catalogue only runs in the optimiser.
That is what the optimiser arms exist to test. (Until 21 Sep night the optimiser could not test it:
every SpMV/SpMM candidate was rejected by a contract check that compared the template-route start
program with the reference's timing helpers -- `docs/IPDPS_PREREG.md`, correction #2. Fixed; cells re-run.)

## Bottleneck 2 — SpGEMM is deciding, not computing

The masked product is a two-pointer merge of two sorted index lists. The textbook body carries
three branches plus the loop condition:

```csl
if (ia == ib) { cij += val[pa] * val[pb]; exists = true; }
if (ia <= ib) { pa += 1; }
if (ib <= ia) { pb += 1; }
```

| | value |
|---|---|
| mask entries | 834, lists averaging 3.56 each |
| cycles (best translated) | 263,405 |
| cost | **316 cycles per mask entry**, ~44 per merge step |
| branch cost | 9-10 cycles each (FINDINGS 10h), four per step |
| **branch share** | **~38 of 44 cycles, about 86%** |
| compiled evidence | 10-11 branches per floating-point multiply, no descriptor operand |

There is no axis to vectorise here: nothing in a merge is an affine run, which is why the
reference emits no descriptor operand either.

### The obvious remedy does not work, measured three ways

The inference from "86% of the step is branch" was to remove the branches: compare once and
*add the predicate* rather than branch on it, `pa += @as(u32, ia <= ib)`, folding the equality
into the accumulate with a multiply. **That is wrong on this compiler, and the claim is
withdrawn.**

| program | cycles | branches | instrs |
|---|---:|---:|---:|
| reference merge | 260,903 | 11 | 142 |
| hand-written branchless merge | **577,853** | **11** | 179 |

The branch count does not move. `cslc` does not lower a boolean cast into a predicated add: it
keeps the compare-and-jump and *adds* the predicate arithmetic on top, 37 instructions and an
extra multiply and add, for 0.45x. Two independent confirmations: gpt-5.6-luna proposed the same
transformation twice in arm O1 and measured 470,588 and 308,643 cycles, worse than its own
running best each time. Both the hand-written and the model-written versions verify correct on
the held-out matrices, so this is a performance refutation, not a correctness one.

The branch cost itself is still real — a branch is 9-10 cycles and the merge is full of them —
but it is **not reachable from CSL source**. What did pay on the same task, taking 439,009 to
202,106 cycles, was descriptor and compile-time work: stride choice, descriptor-offset chaining,
compile-time hoisting and descriptor-setup hoisting. The lesson for the catalogue is that a
diagnosis licenses an experiment, not a prescription; the `branchless_merge_advance` angle is
withdrawn from the selectable set and kept only as this record.

## Bottleneck 3 — SpMM pays descriptor setup too often

The agent's best SpMM already replaced the inner sweep over the dense operand's columns with
one descriptor multiply-accumulate, which is where its 3.58x over the reference comes from. What
remains is amortisation.

| | value |
|---|---|
| busiest PE holds | 441 nonzeros, each times Nt = 8 columns |
| cycles | 29,807 |
| cost | 8.45 cycles per multiply-add |
| descriptor setup | 15-17 cycles per dispatch, one per row-nonzero |
| **setup share** | **441 x ~16 = ~7,000 cycles, about 24% of the run** |

Eight elements is too short a run to pay for a four-word descriptor rebuild. The levers are the
existing `dsd_setup_hoist` angle (longer runs per descriptor, hoist what does not depend on the
loop variable) and a wider column tile.

## What this changes in the agent

| change | grounded in | outcome |
|---|---|---|
| new angle `branchless_merge_advance` | bottleneck 2: 86% of the merge step is branch | **withdrawn**: measured 0.45x, three ways |
| new IR key `ir_branch_heavy`, branches per floating-point multiply >= 4 | calibrated on this suite: merge 10-11, scalar gather 6-7, arithmetic inner loop 1.0 | kept: it fires where intended, and the diagnosis it encodes is sound even though the remedy was not |
| `vectorise_along_structure` now quotes the suite's own numbers | bottleneck 1: 34.9 cycles/nnz measured against a 6-diagonal matrix | untested: never selected inside the attempt budget |

The key threshold is calibrated rather than chosen: it separates the SpMM reference's
arithmetic inner loop (1.0 branches per multiply, compute-bound) from the merge (10-11,
decision-bound), with the scalar gather between them at 6-7.

## What is not claimed

These are **static** counts over the compiled compute file, not dynamic execution counts. They
are used to compare a program against its own reference under one compiler, and to trigger
angles; they are not a cost model, and the cycles-per-nonzero figures above come from measured
`cycles_send`, not from the instruction counts. Whether the angles actually recover the headroom is an experiment, not a claim, and one of
them has already failed it: see the refutation above. The optimiser arms of 20-21 September
measured gpt-5.6-luna taking SpGEMM from 439,009 to 202,106 cycles, which is 1.29x faster than
the hand-written reference, entirely through descriptor and compile-time transformations; and
finding nothing at all on SpMM and SpMV, where the 4.8x axis change of bottleneck 1 remains
untaken because the angle that encodes it was never selected inside the attempt budget.
