# Proposed evidence note for the manuscript integrator

Prepared against paper commit `bb7f61ad30873f64ebca758101f5e03d313c37d9`. The manuscript itself is unchanged. Use these results as a controlled simulator case study or motivation for hardware tests. They do not establish an improvement from a model, sparse guidance, or compiler-feedback condition.

## Candidate text

We used controlled CSL rewrites to test a mechanism identified in instruction traces. In a masked sparse product, the original merge loop updated one of two cursors through an indirectly selected stack address. Expressing the updates as separate control-flow paths changed the emitted loop to use conditional register increments. The candidate was selected on three matrix families before evaluation on nine different families, all with 16×16 inputs. It reduced simulator cycles on all nine final families, with a geometric mean speedup of 1.216 over the original merge implementation. Both programs passed 108 final numerical and structural checks. Byte-identical compiler captures show a matching IR difference: the original program joins the two cursor addresses before a shared update, whereas the selected program keeps their updates separate. Its captured IR has more branch instructions, demonstrating why static branch counts alone do not predict the measured cost. The other source changes did not provide additive benefits: naming loop end offsets alone did not improve the selection cases, and combining it with additional bounds changes was slower than the selected rewrite.

A separate full sparse-product experiment generated sorted CSR output without a supplied output mask. Reducing the accumulator from sixteen slots to four reduced its declared value and presence storage from 96 to 24 bytes. The smaller form had lower fixed overhead on empty and diagonal inputs: the compiler emitted two stores for clearing the presence array and unrolled the output checks. For larger product counts, repeated traversal for the four output tiles outweighed that advantage. The storage figure concerns the accumulator arrays, not total PE memory. Both implementations use preallocated output capacity and return an explicit failure status when that capacity is insufficient.

Output construction also affected time independently of product count. Two full-row cases each generated 144 intermediate products but emitted 80 and 144 output entries, with a difference of 1,600 cycles. A conditional model derived from that comparison predicted 21,011 and 20,861 cycles for two new sparse matrix pairs. All eight new launches matched those predictions exactly. This model describes one compiled program under fixed dimensions and row degrees; it is not a general instruction-latency or hardware-throughput model.

## Qualification and integration checks

- All measurements above are SDK 2.10.1 simulator cycles from one application PE. Hardware replay is required before using these mechanisms to explain CS-3 speedups.
- These are deterministic reference and control programs. They are separate from the frozen agent experiment conditions and their train/validation/final-test splits.
- Retain the unsuccessful source rewrites and the accumulator crossover. Reporting only the selected rewrite would hide the compiler sensitivity that motivated this experiment.
- All three final suites, including nested matching, completed within the amended common limit. Retain the earlier harness failures and rejected IR collection when describing resource costs. Expected output-capacity failures test the contract and are not complete-product performance samples.
- Input packing, host transfers, and allocation are outside the timed scope. Local scratch reset, arithmetic, and declared output construction are included.
- The numerical inputs are small exactly representable integers with signs and cancellation. Larger real matrices, general floating-point error, output expansion, and inter-PE communication remain to be tested.
- Candidate next measurements are output-tile indexing with preparation/metadata costs, product-count-based partitioning, communication, and physical hardware replay. The proposed mechanisms do not by themselves establish favorable scaling.

Use the committed README, numerical tables, ELF/source manifests, and trace audit as the evidence references. Select final claims after the hardware node checks the same contracts and exact measured builds.
