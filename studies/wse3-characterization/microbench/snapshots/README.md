# Simulator SRAM and register snapshots

The 2026-09-18/19 experiment obtains **verified SRAM and named GPR snapshots at
stopped host boundaries**, including a four-PE 4×4 GEMM. It does not obtain
arbitrary-cycle snapshots. This supersedes the earlier claim that csdb memory
and register readers require a live hardware target.

Open the [WebGL presentation](../../results/dataflow/dataflow.html) and scroll to
“SRAM and registers, before and after.” The [summary JSON](../../results/snapshots/summary.json)
contains the values, addresses, register excerpts, and source hashes.

## Results

| Experiment | Before computation | After computation | Result |
|---|---|---|---|
| One PE, u16 load/add/store | A = [7,19,4660,22136], B = [5,23,17,33], C = [0,0,43981,48350] | C = [12,42,43981,48350]; A/B unchanged | Exact match, including untouched sentinels |
| Two PEs, one f32 word | Sender buf = 11; receiver buf = 0, loc = 30, res = 0 | Receiver buf = 11, res = 41 | Exact f32 bits match |
| Four PEs, 4×4 GEMM | Host A/B tiles in local SRAM; C tiles zero | All 16 C elements equal the independently computed A×B | Exact f32 bits match on all four PEs |

For every stopped phase, we read the application symbols from `state.elf` with
Cerebras's `ELFMemory.read_data` using ELF-derived **byte addresses**. We compare
those bytes to `csdb memory read`, whose addresses and lengths use **16-bit words**.
All **38 symbol observations** agree. The **224 named `ce_gpr[0..15]` word
observations** also agree between the ELF core and csdb.

The logs additionally expose destination/source DSR families, XDSRs, stack and
control registers, microthread IPs, queue status and pipeline status. Their
presence does not establish a complete internal pipeline snapshot or validate
every decoded field. The viewer displays retained descriptor/control excerpts.
GPR values at these boundaries include SDK completion code; they should not be
read as the register allocation of a preceding arithmetic instruction.

Native `elf2am` disassembly confirms that each one-PE sum is implemented as
two `ld16` instructions, `add16.nf`, and `st16`. The first sum reads word
addresses `0x5ce` and `0x5d2`, and stores to `0x5d6`; these match the independently
read A/B/C ELF symbol addresses. Listings are retained as
`single/out_0_0.disasm.json` and `relay/out_*_0.disasm.json` in the campaign.

The GEMM uses the exact, hash-checked `g1-history` ELF from
`results/gemm-walkthrough/try-20260914d`. It is an instrumented/optnone teaching
kernel. These new runs have independent timelines; we do not splice their
register values into the older GEMM or GEMV cycle traces.

## What made the dumps work

The public [SdkRuntime API](https://sdk.cerebras.ai/api-docs/sdkruntime-api)
requires the name `corefile.cs1` for csdb. The actual output consists of
`corefile.cs1.idx` and `corefile.cs1_N.cgz` parts. Give csdb the **prefix**, not
the `.idx` file and not the separate ELF core:

```text
csdb <run-directory>
context select out
target create --core-file corefile.cs1
memory read --name A --stdoutput
register read --stdoutput
```

`register read --all` and `pe select` are not valid commands in this installed
version. Some optimized CSL symbols have generated names such as
`$$csl_base_address$$0$$buf`; our extractor requires a unique exact symbol or
generated base-address match rather than guessing its address.

We first called both dump methods after blocking uploads and a blocking kernel
call, before stopping. Those dumps were accepted, but their SRAM values were
stale/zero in the one-PE test. Therefore acceptance is not a sufficient validity
test. We do not infer the exact cause from these observations. The post-stop
dump matched the host readback.

We then repeated each phase in **its own SDK process**:

1. Load program, upload inputs, optionally call the kernel.
2. Call `stop()` without issuing host D2H readback first.
3. Write CGZ and ELF dumps and inspect them independently.
4. Compare every selected SRAM word to the expected phase values.

Both phases passed for all three workloads. The installed simulator aborts if a
second instance is created in the same Python process, so separate processes
are required by this runner. The failed second-instance attempt remains in the
artifact tree as an explicit failed experiment.

Two other SDK issues remain recorded: `SimfabConfig(core_path=Path(...))` failed
its native binding conversion; omitting that optional argument worked.
`SdkRuntime.read_symbol()` failed to locate its symbol table in these bundles.
The vendor ELF reader and csdb provided the independently checked alternative.

## Cycle-level investigation

The generated `simconfig.json` includes empty `memwatch` and `debug` lists and
`savepointInterval: 0`. Register decoding also names breakpoint/suspend
configuration. These are promising leads, **not enabled capabilities**.
The inspected public runtime surface exposes no `step_cycle`/`run_until_cycle`.
The inspected csdb target/register/trace commands expose reading and target
selection, not execution stepping. A bounded search of installed Cerebras Python
sources found no interface for those configuration fields, and the searched bin
directories/PATH had no standalone simfab executable.

Evidence: [capabilities.json](../../results/snapshots/try-20260918b/single/capabilities.json).
The useful next vendor question is how to enable memory-watch/write events or
savepoints in this specific SDK image, with a defined global-cycle boundary and
SRAM/GPR/DSR coverage. No vendor or ALCF messages were sent.

## Reproduce

Run on the SDK node, or with the existing `~/bin/singularity` SSH relay available:

```bash
cd /home/USER/xkernel/studies/wse3-characterization
PATH=/home/USER/bin:$PATH python microbench/snapshots/capture.py \
  --out results/snapshots/<new-run-name> --with-gemm
```

This uses only the SDK simulator. Each destination must be new. The runner
retains compiler output, CTF traces, expected/readback values, all dump formats,
failed reader results and stopped-phase validations. `--with-gemm` stages the
retained g1 ELF and creates a summary within the new run directory.

Recheck the retained campaign without executing a simulator:

```bash
python tools/snapshot_summary.py
python -m unittest discover -s tests -p test_dataflow.py -v
```

Original attempts and corrected experiments are under
[`results/snapshots/try-20260918b`](../../results/snapshots/try-20260918b).
`validation.json` records the running-dump failures; `stopped-validation.json`
records the successful independent stopped runs. The initial constructor failure
is retained separately under `try-20260918a`.
