# Vendored WSE-3 timestamp synchronization module

`layout.csl` and `pe.csl` are copied byte-for-byte from the SDK 2.10
`csl-extras` bandwidth-test example:

`examples/benchmarks/bandwidth-test/src/sync/`

Source archive used for this vendoring:

`csl-extras-202604101435-6-d2f7d96e.tar.gz`

The calibration generator copies these files into every runnable network
bundle (straight, turn, multicast, and supported contention cases). The module
reduces across the PE rectangle, broadcasts from PE (0, 0), enables the TSC at
startup, and exposes a three-u16 reference timestamp on every PE.

Do not edit these files to adapt a calibration case. Any study-specific route,
queue, or timing behavior belongs in the generated layout and PE program.
