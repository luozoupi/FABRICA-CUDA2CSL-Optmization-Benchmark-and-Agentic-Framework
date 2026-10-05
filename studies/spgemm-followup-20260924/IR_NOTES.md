# LLVM IR and machine-code evidence

The existing `cslc_ir.py` backend interceptor captured LLVM IR for the original and selected merge programs. Both shadow application ELFs have **full SHA-256 equality** with the measured binaries. The original CSL and measured ELF bundles remain unchanged. SDK identity, commands, timing, and full hashes are in `ir-registration.json`, `ir-results.json`, and `ir-analysis.json`.

This is an SDK-version-specific interception of the IR supplied to `cslc-backend`, not a documented stable `cslc` export flag. The selected program has **73 branch instructions** in the captured kernel IR versus **59** in the original, and both contain nine allocation instructions. The original kernel contains four pointer-valued `phi` instructions: two join the alternative cursor addresses before a shared load/increment/store, while two are single-predecessor forwarding nodes. The selected kernel has none. Debug locations associate the incoming addresses with the two cursor variables. Thus the captured IR already exposes the address merge that corresponds to the indirect stack update in the original machine code. The rewrite keeps those updates separate, and the emitted code uses conditional register increments. These artifacts do not identify the particular compiler pass responsible for register promotion or instruction selection.

The selected program nevertheless executes fewer final instructions and takes fewer cycles. On the uniform input, both programs execute **213 equality comparisons and 28 useful products**:

| Metric | Original merge | Selected merge |
|---|---:|---:|
| Simulator cycles | 20,461 | 15,077 |
| Recorded dispatch events | 13,261 | 8,861 |
| Cycles / dispatch event | 1.543 | 1.702 |

The average cycles per dispatch event increases while total time falls. The denominator changes when instructions are removed. This quotient is not hardware retired-instruction CPI and should not be optimized in isolation. Likewise, the greater branch count in the captured IR does not predict the final dynamic cost. The measured execution and unchanged useful work are the relevant evidence.

The baseline emitted unequal-index path computes an address for one of two stack-resident cursors, then performs an indirect load and store. The selected code computes conditional register increments. Other loop and register-allocation changes also occur, so the entire timing difference is not assigned to a single instruction class.

The first selected-kernel capture was rejected: the interceptor collapses filenames to basenames when the shadow output lies outside the source working directory, allowing application and routing `out_0_0` records to collide. The rejected capture is retained under `ir/development-failures`. Moving only the isolated shadow output beneath the source working directory preserves distinct names; the new capture passed the full ELF identity check. The original successful baseline application capture also has the correct application metadata and ELF match. No rejected IR is used for the conclusions above.

The committed `kernel-*.ll.txt` files are kernel-only excerpts; they omit declarations and debug metadata and are not standalone compilation units. Full accepted IR, linker/backend requests, and objects remain in the local archive and replay bundle.

The shared interceptor now has a focused naming fix: external shadow paths use a safe basename plus a path digest, while names beneath the source cwd retain their previous form. Three regression tests cover preserved existing names, distinct application/east/west artifacts, and stable safe external names. This fix was applied after all measurements and accepted captures. The exact interceptor used for those captures is archived under `tools-used/`; `ir-tool-fix.json` links both hashes.
