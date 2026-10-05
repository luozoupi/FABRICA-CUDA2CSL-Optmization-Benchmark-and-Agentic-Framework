# Exact timing boundaries

The exported operation first resets three acknowledgement buffers. It then records the root start timestamp and begins a causal broadcast. Those three scalar resets precede the timed interval. The clock read defines the boundary; there is no timer-overhead subtraction.

Each top-row PE starts its vertical broadcast after its own horizontal callback. A PE begins the local kernel after its own vertical callback. These dependencies permit overlap across the grid; the logical row/column stages are not global barriers. After local computation, column reductions combine unit completion signals, followed by a reduction across the top row. The root verifies the sum equals the number of application PEs.

The root end timestamp follows the completion-reduction callback. Writing exported telemetry and unblocking the command stream happen after that timestamp. The reported root interval therefore measures the defined broadcast/compute/completion protocol, not complete host-call latency or the moment every PE becomes idle.

Local compute duration includes the mode check, kernel invocation, scratch initialization, sparse traversal, accumulation, output-capacity checks, CSR emission, and timestamp-read boundaries. Local before-compute durations are also recorded. Every duration subtracts two timestamps from the same PE. Raw timestamps from different PEs must not be placed on a common timeline without a separate clock-alignment audit.

The resident-data mode broadcasts a one-word start token using previously verified B data. The communication-only control sends the complete B packet and completion signals but skips the local kernel. Their values are separate experimental scopes. Subtracting a no-compute interval from the full interval does not in general isolate a causal communication percentage, because activity on different PEs can overlap.

Host packing/hashing, sparse-oracle construction, H2D/D2H, initial library setup, and final global CSR gathering are outside the device interval. Preparation subcomponents and outer process wall times are retained. A host API call can return before all simulator work is driven to completion by subsequent readback; its recorded call duration is not device latency or complete simulation time.

One-PE execution uses a local callback adapter for the installed collective library’s unsupported dimension-one case. It retains the same timestamp and completion stages but has no inter-PE transfer. Multi-PE execution uses the installed collective library unchanged. These source and build differences are explicit in each case’s hashes.
