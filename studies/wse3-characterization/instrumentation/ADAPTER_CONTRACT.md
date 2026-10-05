# Generated kernel adapter contract

The campaign never edits a canonical `kernels/<task>/CSL` bundle. It ports the
bundle to a campaign work directory, then installs a small adapter around the
original device computation.

Each adapter must provide one device-internal profiled operation. A host-side
`f_tic` call, a separate compute launch, and a later `f_toc` call is explicitly
invalid because the interval contains appliance RPC latency. The generated
endpoint adapter relocates both samples into PE code and disables the later
`f_toc` write; otherwise that host launch would silently overwrite the real
`compute_end` sample.

The required sequence is:

1. Enable the TSC on every application PE.
2. Run the unmodified SDK 2.10 bandwidth-test synchronization module and retain
   its three-word reference timestamp per PE.
3. Within one launched device task, mark `compute_start`, execute the original
   computation, and mark `compute_end` and `exit`.
4. Communication kernels additionally mark the first send, first receive, and
   last receive in their existing fabric tasks. Missing phases are represented
   as absent records, never zero timestamps.
5. Export timestamp, reference, and raw performance-counter buffers with D2H.
6. Run the original host correctness verification before accepting the trial.

Phase indices are fixed:

| Index | Phase |
|---:|---|
| 0 | `sync_reference` |
| 1 | `compute_start` |
| 2 | `first_send` |
| 3 | `first_receive` |
| 4 | `last_receive` |
| 5 | `compute_end` |
| 6 | `exit` |

`profile_timestamp.csl` only captures local counters; it does not pretend to
synchronize them. The generator must vendor the `sync/` module from the exact
SDK 2.10 `bandwidth-test` example used by the campaign and record its source
hash. Queue/color collisions are checked against the compiled route inventory
before insertion. If no collision-free queues/colors exist, adapter generation
fails visibly and requires a kernel-specific override.

The public `<time>` API exposes performance-counter IDs 0 and 1 but does not
identify their events. They remain `perf_counter_0_raw` and
`perf_counter_1_raw` in all study artifacts.

## Generated endpoint adapter

`reinstrument_host_bracketed_bundle` is transactional and operates on every PE
program that implements the timed launcher. It will not inject parent timer
names into imported callback libraries, and it leaves the whole bundle
unchanged if any PE program cannot prove its timer or completion contract.

Existing one-launch timers are accepted only when the source audit proves TSC
enable-before-start, a distinct end buffer on every visible completion path,
timestamp packing, host D2H, and `cycles_send` output. Merely lacking `f_tic`
does not count as proof.

Endpoint manifests honestly report:

- `compute_start` and `compute_end`: source-instrumented or source-verified;
- official cross-PE synchronization: false;
- raw performance counters: not sampled;
- communication phase sites: `needs_override`;
- original `run.py` and correctness logic: byte-identical.

Therefore endpoint telemetry can supply low-intrusion local elapsed cycles, but
it cannot supply cross-PE skew, synchronized first/last event times, or raw
counter values. Those claims require the full adapter below.

## Full adapter override

`full_telemetry_override_template` creates a fail-closed work item for a staged
kernel. `validate_full_telemetry_override` only returns `ready_for_compile` when
all of the following are explicit and present in source:

- all non-omittable phase marks and justified absence of communication phases;
- byte-identical SDK 2.10 bandwidth-test sync files;
- a compiled-inventory hash and a passed color/queue/task collision audit;
- phase words, phase-valid flags, sync reference, and raw-counter D2H symbols;
- counter IDs exactly `[0, 1]` with unknown semantics;
- the unchanged original correctness program.

A source audit is still `inferred` evidence. It must compile, pass correctness,
and complete the endpoint-versus-full hardware comparison before producing a
silicon result. If full telemetry changes cycles by more than 5%, only endpoint
timing is eligible for headline use.

### Full adapter materialization

`materialize_full_telemetry_adapter(endpoint_bundle, override, destination)`
turns a completed override into a new, versioned study copy. It refuses an
in-place or ancestor/descendant destination. The endpoint bundle and its
endpoint request identity remain byte-identical; the full copy receives a new
source hash and a request with `telemetry_level=full`. The destination name used
by `run-suite` contains endpoint-source, canonical-override, and materializer-
generator hashes, so a transformer change never overwrites an older study copy.

The materializer does not infer CSL structure. Each phase and raw-counter site
must name a relative file, a CSL function, a unique literal anchor, whether the
mark goes before or after it, and the imported profile-module alias.
`sync_reference` additionally names the exact reference-buffer expression.
The generator emits the fixed phase indices and the fixed raw-slot `0,1` call;
an override cannot substitute counter names or event meanings.

Layout-specific work is supplied as exact-anchor integration edits. The six
roles are mandatory: profile import, sync layout wiring, sync PE import, the
single synchronized host entry-point launch, CSL telemetry exports, and host
D2H. Integration edits are insertion-only except for an explicitly anchored
`replace`, which is needed to replace the old host compute-launch sequence with
one synchronized entry point. Every edited input file has a pre-edit SHA-256,
every anchor must occur exactly once, and edits may not overlap a protected
marker-bounded correctness region. When two genuine phase/counter samples share
one callback boundary, each site supplies a distinct integer `sequence`; the
materializer uses that explicit ordering and rejects an ambiguous tie.

The collision gate is computed, not accepted as a free-form assertion. The
override contains a canonical hash of the campaign-qualified compiled-layout
snapshot. Reserved sync colors, input queues, output queues, and local task IDs
must be disjoint from the snapshot's resolved resource sets, and the override's
covered PE programs must exactly equal the compiled application-program set.
An unqualified layout or an unresolved resource set remains a blocker.

Materialization happens in a sibling temporary directory. Only after vendored
module hashes, generated file hashes, phase/counter markers, D2H symbols,
per-PE geometry attestations, and protected correctness-region hashes pass a
second audit is the directory atomically renamed into place. The retained files
are:

- `.wse3study_full_override.json`: the exact canonical override;
- `.wse3study_full_adapter.json`: source/parent/override hashes, all edit and
  output hashes, phase sites, sync resources, export schema, and open gates;
- `wse3study/profile_timestamp.csl` and byte-identical
  `wse3study/sync/{layout,pe}.csl`.

`ready_for_compile` is deliberately not `ready_for_execution`. The campaign's
full-adapter validator revalidates the endpoint parent and all generated
artifacts, while leaving the endpoint validator unchanged. Execution remains
closed until three hashed JSON records under `.wse3study_evidence/` bind the
same full source hash and independently pass compile, original numerical
correctness, and D2H schema validation. This prevents a source-only audit from
being mistaken for a runnable or silicon-validated adapter.

When a newly versioned endpoint parent makes an untouched blocker template
stale, `run-suite` archives that blank template under the override `history/`
directory and emits a fresh one. Any template containing a phase, resource,
integration edit, or correctness attestation is operator work and is never
rewritten; a stale source hash remains a visible blocker.

## Compiler validation

The compile-only probe in `compile_probe/` exercises timestamp capture, phase
validity, official reference copying, raw counter IDs 0/1, and pointer export
storage. It passed the ALCF SDK 2.10 compiler as job
`wsjob-REDACTED` on 2026-08-17. This is `compiled` evidence only;
the probe was not executed on the WSE and supplies no silicon measurements.
