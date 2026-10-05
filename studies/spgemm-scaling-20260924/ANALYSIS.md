# What the sweep can explain

These are controlled simulator measurements of full CSR SpGEMM. Interpret improvements as effects of the chosen implementation and data placement, not as model-generation gains or physical WSE speedups. The final tables and completion counts are generated from audited observations.

## Local parallelism and protocol cost

For the completed 16×16 uniform case, the full-row root interval falls from 21,718 cycles on one PE to 7,684 on four and 3,649 on sixteen. The slowest local compute intervals are 21,673, 5,510, and 1,430 cycles. Local computation scales more closely to the PE count than the complete protocol. The difference is not assigned to a single instruction class: the root interval includes starting the computation, distributing B, waiting, and collecting completion acknowledgements.

At size 64, the uniform full-row interval is 190,071 / 50,464 / 14,853 cycles on 1 / 4 / 16 PEs (3.77× and 12.80× speedups). Increasing degree from three to eight gives 415,976 / 108,266 / 30,368 cycles (3.84× and 13.70×). More arithmetic and output work can amortize the collective protocol, but the degree control also changes input storage and output cardinality. It is not a pure arithmetic-intensity experiment.

The communication controls distinguish a full B broadcast from a one-word start token. Reusing B can remove payload transfer, but retains collective setup and completion work. If those fixed costs dominate small jobs, larger local row batches or multiple operations per collective epoch are candidate solutions. Such batching has not been implemented here and must preserve output and reuse semantics.

## Whole-row assignment has an explicit limit

At size 16 on four PEs, changing only the assignment of skewed rows reduces the full-row root interval from 11,187 to 7,942 cycles. The compute max/mean ratio falls from 1.75 to 1.12. At sixteen PEs it changes neither the 6,172-cycle interval nor the 2.95 compute imbalance: each PE has one row, and moving rows cannot divide the most expensive one.

At size 64 on sixteen PEs, row balancing reduces the skewed full-row interval from 27,607 to 15,911 cycles and the compute max/mean ratio from 2.08 to 1.09. Here multiple rows per PE still permit useful redistribution.

Splitting a heavy row across PEs could address this limit, but requires combining partial output entries and measuring additional communication and storage. This differs from merely redistributing whole rows. B has uniform row degree in this sweep, so balancing candidate-product counts here is equivalent to balancing A-row nonzero counts; the experiment does not establish an advantage over nonzero balancing. A further control should vary B-row degree while holding A-row degree fixed.

## Sparse arithmetic can still require dense scans

The full-row accumulator clears and examines all output columns for every assigned row. Its source therefore visits M×N accumulator positions even when input row degrees stay fixed and useful candidate products grow approximately as M×degree(A)×degree(B). The bounded accumulator still covers the same output-column range and additionally repeats sparse traversal for each tile. These are source-level work counts, not measured runtime percentages.

For uniform size 64, bounded accumulation is 1.46× slower on one PE and 1.47× slower on four PEs, while reducing the two accumulator arrays from 384 to 96 bytes. Whether that saving is useful depends on total compiled allocation and what otherwise fails to fit.

Two candidate alternatives deserve a separate frozen comparison: a list of touched columns with first-touch initialization, followed by sorting to preserve canonical CSR; and a merge of the already sorted B-row streams, with equal-column products combined as they are visited. Both avoid assuming a full output-row scan is necessary. Their index, sorting/heap, branch, and scratch costs must be measured. Neither is implemented in this sweep.

SpGEMM also needs both candidate-product counts and output cardinality: different products can accumulate into the same output position. The banded and uniform inputs help distinguish traversal from output construction. An output count alone is not a work estimate; an input nonzero count alone does not describe fill-in.

## More PEs do not remove replicated-input limits

Every PE stores B. Increasing the number of row owners reduces local A and C but leaves B unchanged per PE. The analytical extension in MEMORY.md shows cases where B alone exceeds 48 KiB under this representation, independently of PE count. Those larger points are not measured performance results.

A column partition or staged B distribution can remove that placement limit. A two-dimensional row/column decomposition gives each PE a subset of C rows and columns, at the cost of input preparation, remote B access or broadcast stages, and final CSR assembly. Sparse block occupancy and row/output imbalance should determine whether this added structure pays off. Smaller accumulators alone cannot solve an input-replication limit.

## Evidence still needed

Use the larger size, density, weak-scaling, and preregistered communication-model results to qualify these mechanisms once their runs complete. No static assembly count is converted to a runtime percentage. Physical WSE replay, real matrices, floating-point sensitivity, and an optimized sparse-library comparison remain separate validation steps. Preserve failed cases and partial timing status in any paper table.
