# CS-3 replay of the strong-scaling fixtures -- 26 September 2026

Run from the WSE-3 node through the appliance client (`code_translation/hw_spgemm_dist.py`): each case's
frozen `pe.csl`, `layout.csl`, `single_collective.csl`, `host.py`, `inputs.py` and `case.json` unchanged
(host.py's source-hash check passed), compiled with the study's own `cslc` line (`commands_wse3.example.sh`),
driven by the unchanged `host.py` through a thin `run.py` wrapper (`run_wrapper.py`) that reports the
UNIFORM unchanged-input broadcast session's median root interval as the headline. Both arms -- the
appliance simulator and silicon -- ran the same artifact; every launch's numerical output, received B
words and acknowledgement counts were validated by host.py (`observations.{sim,hw}.json` keep the raw
per-PE timestamps, hashes and host timings for every session). Timing scope is the study's: root-clock
start-to-acknowledged-completion, device-internal. No clock conversion.

## Headline: uniform input, broadcast mode, unchanged session, median of three

| case | local simulator (study) | appliance simulator | CS-3 | hw / sim |
|---|---:|---:|---:|---:|
| strong-m16-k16-n16-p4-d3-full | 7,684 | 7,684 | 7,411 | 0.964 |
| strong-m16-k16-n16-p16-d3-full | 3,649 | 3,649 | 3,680 | 1.008 |
| strong-m64-k64-n64-p4-d3-full | 50,464 | 50,464 | 45,333 | 0.898 |
| strong-m64-k64-n64-p16-d3-full | 14,853 | 14,853 | 13,772 | 0.927 |
| strong-m64-k64-n64-p64-d3-full | 6,017 | 6,017 | 5,961 | 0.991 |

The appliance simulator reproduces the study's local simulator counts **exactly** on all five cases.
Silicon runs 0.90-1.01x of the simulator: the compute-heavy 64x64 four-PE case is 10% faster on hardware
(the same direction and size as the suite's scalar one-PE references, 0.90-0.91 in HW-S1), the
protocol-dominated 16x16 cases are within 4% either way. The simulator's error is on local scalar
compute, not on the collective protocol.

## Every session on silicon (median root interval, cycles)

| case | banded bcast | banded resident | uniform bcast | uniform resident | skewed equal-blocks bcast | skewed balanced bcast | balanced gain | comm-only control |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| strong-m16-k16-n16-p4-d3-full | 7,129 | 6,867 | 7,411 | 7,149 | 10,881 | 7,692 | 1.41x | 2,315 |
| strong-m16-k16-n16-p16-d3-full | 3,597 | 3,335 | 3,680 | 3,418 | 6,158 | 6,158 | 1.00x | 2,374 |
| strong-m64-k64-n64-p4-d3-full | 43,985 | 42,919 | 45,333 | 44,267 | 64,175 | 45,195 | 1.42x | 3,119 |
| strong-m64-k64-n64-p16-d3-full | 13,430 | 12,364 | 13,772 | 12,706 | 26,201 | 14,795 | 1.77x | 3,187 |
| strong-m64-k64-n64-p64-d3-full | 5,876 | 4,810 | 5,961 | 4,895 | 9,060 | 9,060 | 1.00x | 3,294 |

Row balancing on the skewed input transfers to silicon at the simulator's ratios (64x64 on 16 PEs: 1.77x on
hardware against 1.74x in the study); resident mode (B already delivered) saves 1,066 cycles at 64x64
and 262 at 16x16 on every PE count -- the B broadcast's cost, invariant in P here because B is
replicated to all PEs regardless; the communication-only control is 2,315-3,294 cycles.

## Two failed attempts, kept

1. `hw_spgemm_dist.port_attempt_failed.json`: the appliance driver's mechanical SDK-1.4-to-2.10 port rewrote
   the typed `param X: u16;` lines (`param X;` in pe.csl, `param X = 1;` in layout.csl); host.py's source-hash
   check refused to run every case. The port is now disabled for 2.10-native bundles. The same rewrite is
   applied silently to the suite's own references in HW-S1/S2 (their run.py checks no hashes); their
   `--params` override every default, so no measured number is affected, but it is recorded here.
2. `hw_spgemm_dist.banded_session_attempt.json`: the first wrapper reported the BANDED session (first in
   `case.json`) and let the hardware arm overwrite the simulator arm's observations; those five cases ran
   and validated, and their banded numbers agree with the per-session table above.

Predictions (docs/IPDPS_PREREG.md, 2026-09-26): hw/sim within 0.90-1.05 for 64x64 held for 16 and 64 PEs and
missed by 0.002 at 4 PEs; "below 0.90 for 16x16" was wrong in direction -- the protocol-bound cases are the
closest to the simulator. Not done: the one-PE cases (the study's local callback adapter), the tiled
accumulator, weak scaling and density controls; the 256x256 cases were pending on the NVIDIA node.
