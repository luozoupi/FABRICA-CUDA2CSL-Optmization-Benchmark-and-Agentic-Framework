# Registered SDK follow-up: experiment contract

This study runs on the NVIDIA GPU node with Cerebras SDK 2.10.1 and targets one WSE-3 PE. Framework base: `196523eb1e25b832d9f6fa8a665838c042c751e3`. Other reviewed tips: sparse branch `7413ed46fa0f572f4b46e7fd9b7056462a31a770`; paper `bb7f61ad30873f64ebca758101f5e03d313c37d9`. The manuscript is not edited. No models or external inference APIs are called.

## Masked-product transformation experiment

The numerical and structural contract matches the previous trace pilot: compute A-transpose×A at positions where A is nonzero. Output values and presence are stored in fixed 16×16 buffers. All six candidate sources were frozen before compilation or measurement:

1. Original merge implementation.
2. Name the two end offsets outside the loop.
3. Separate the two cursor-update paths with explicit continuation.
4. Name end offsets and split the two loop-bound checks.
5. Combine the changes in candidates 3 and 4.
6. Nested matching, retained as a stronger comparison and excluded from merge-candidate selection.

Select the correct merge candidate with the smallest geometric mean of original-input cycle ratios across banded, uniform, and skewed families. Tie-breaking follows the registered candidate order. The decision is written before any final-test execution. Final tests use nine separate families: empty, diagonal, wider banded, higher-degree uniform, block structured, long rows with empty rows, two fixed random densities, and fully dense. No source changes follow final-test feedback.

Every case has original, changed, and restored input sessions. Each session includes one warmup and three timing repetitions. The host poisons numerical output and structural presence before each session. Every launch must match both the FP64 numerical oracle and the Boolean-product structural oracle. All values are small integers, so exact comparison is required. Final-test matrices remain 16×16; they test structural transfer, not size scaling or large real applications.

Time includes output initialization, local synchronous computation, and timestamp reads. Host packing/transfers and allocation are excluded. New baseline and nested binaries are rebuilt under the same compiler configuration; all final and trace replays reuse those measured builds exactly. The original and rebuilt baseline text sections are compared separately.

## Full SpGEMM accumulator experiment

This is a different operation and is reported separately: arbitrary sparse A times sparse B, producing sorted CSR output without a supplied output mask. Matrices are 16×16, with sorted unique 32-bit input indices and FP32 values. Local offsets fit in 16 bits and host conversion checks enforce this bound. Structurally occupied output entries are retained even when their numerical value cancels to zero.

The two implementations use the same row-wise product traversal. For every stored A[i,k], they visit stored B[k,j] values and accumulate into output row i. One implementation provides sixteen accumulator slots; the other processes four output columns at a time and repeats traversal for four tiles. The declared accumulation and presence arrays occupy 96 and 24 bytes, respectively. This is not a claim of a fourfold reduction in total PE memory: input, output, library, descriptor, and stack storage also contribute.

The output capacity is preallocated to the worst-case 256 entries, with four guard entries. The timed operation initializes scratch, discovers output presence, performs accumulation, checks capacity, and emits sorted CSR values/indices/row pointers. There is no separately measured symbolic phase or dynamic allocation. Packing, transfers, and output allocation are outside the measured interval.

Six input families run original/changed/restored sessions, one warmup plus three measurements each. Dense products additionally test output limits 0, 64, 255, and 256. Empty output tests limit zero; a final diagonal case checks recovery after the capacity-test sequence. Insufficient capacity must return a failure status and a correct bounded output prefix, leaving all unused/guard entries intact. Capacity-failure timing does not enter successful full-product performance comparisons.

An initial host-program error reversed the destination and symbol arguments to `memcpy_d2h`. Both invocations failed before the first result validation. Those runs are retained under `development-failures/host-copy-order`. The corrected host reuses the unchanged compiled ELFs. The amendment and hashes are in `general-host-fix.json`; this was a harness error, not a compiler or kernel failure.

Independent structural counting identified equal-product/different-output-size cases: banded and uniform both generate 144 products but produce 80 and 144 output positions. Before inspecting general-product timings, `general-trace-amendment.json` added banded to the originally planned uniform trace comparison.

## Trace validation and interpretation

Short traces replay the baseline and selected merge implementation on banded/uniform inputs, and both general-product accumulator variants on those inputs. Each trace uses the exact measured ELF and one warmup plus one timing repetition. The auditor matches original input hashes, output hashes, and cycle counts; verifies timer anchors and instruction encodings; and checks every traced scalar multiplication/addition result against its operands. Arithmetic counts must equal independently counted useful products.

Branch successors are checked against the compiled control flow, including static unconditional jumps that may have no separate dispatch event. Dispatch-to-next-dispatch intervals partition elapsed time. They do not measure instruction retirement, hardware CPI, universal instruction latency, or hardware stall percentages.

All SDK work uses both local lock conventions and runs serially. The image name, SHA-256, simulator revision, compile command, source hashes, ELF hashes, raw observations, and failure records are retained. The automated runner uses a 420-second per-phase timeout and a 600-second lock-wait timeout. Before final-test execution, a recorded amendment gives every nine-family final suite the same 900-second timeout: dense nested matching performs 65,536 comparisons per launch, versus 432 in selection. No device timing, input, source candidate, repetition, or selection rule changes. No measurement is silently replaced after a failure.

These experiments do not measure inter-PE communication or load balance, physical WSE latency, CUDA/cuSPARSE performance, or an agent's optimization capability. They supply small controlled mechanisms and replay artifacts for those later studies.

## Independent check of an output-size cost model

After the full-row measurements, the banded/uniform pair suggested 25 extra cycles per emitted output position with candidate-product count fixed at 144. Two fresh matrix pairs were registered before simulation, keeping A fixed and three entries in each B row. Seeds 928 and 930 produce 121 and 115 structural output positions; the fixed-ELF predictions are 21,011 and 20,861 cycles. The saved registration includes input and ELF hashes. These probes test the conditional explanation; they do not change the selected merge candidate or enter its final-test results.

A later tiled-accumulator invocation exceeded the initial 420-second watchdog (430 seconds including termination grace). Its logs and result remain under `development-failures/tile4-watchdog`. A recorded amendment retries the unchanged ELF with a general-suite limit of 1,800 seconds and adds per-session result checkpoints outside all device timing windows. All final suites retain the same 900-second limit; the selected merge and baseline run before the nested comparison. These are harness resource limits, not WSE capacity or correctness failures.

## Accepted LLVM IR capture

After the measured experiments, the existing SDK-version-specific `cslc_ir.py` interceptor captured backend-input IR through isolated shadow compilation. Full application ELF SHA-256 equality is required, and both baseline and selected captures satisfy it. The first selected-kernel collection was rejected because shadow output outside the source cwd caused application/routing basenames to collide. That collection is retained; relocating only the shadow output under the source cwd fixed collection without changing the measured CSL or binaries. See `IR_NOTES.md` and the capture amendment. This adds three shadow compiler invocations, with two accepted application IR artifacts.
