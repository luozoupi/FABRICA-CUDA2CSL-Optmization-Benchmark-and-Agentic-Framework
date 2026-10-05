# Replay and evidence checks

The committed `fixtures/` directories are the final executed source/configuration sets. Each `case.json` records source hashes that the host checks before launch. Use a fresh directory for a new run so the published observations remain unchanged. The preparation and orchestration scripts document the original experiment and contain paths specific to this node; they are not a portable package installer.

## Run one full-product fixture on this SDK node

The SDK wrappers below refer to the image identified in `sdk-identity.json`. This runs all six input families and the capacity/reset checks for the sixteen-slot implementation. Substitute `tile4` for `full_row` to test the four-slot version. Complete suites take several minutes of wall time; simulator cycle counts do not measure host runtime.

```bash
STUDY=/home/USER/xkernel-profiling-review-20260924/studies/spgemm-followup-20260924
RUN=$(mktemp -d /home/USER/spgemm-replay-XXXXXX)
cp -a "$STUDY/fixtures/general/full_row" "$RUN/full_row"
cd "$RUN/full_row"
flock /tmp/xkernel_singularity.lock flock "/tmp/xkernel_singularity_$(id -u).lock" bash -eu -c '
  export OMP_NUM_THREADS=1 OPENBLAS_NUM_THREADS=1
  export APPTAINERENV_CSL_SUPPRESS_SIMFAB_TRACE=1
  /home/USER/cs_sdk/cslc layout.csl --arch=wse3 --fabric-dims=8,3 --fabric-offsets=4,1 --memcpy --channels=1 --width-west-buf=0 --width-east-buf=0 --out-routes -o out
  /home/USER/cs_sdk/cs_python host.py
'
```

Read `observations.json` for every recorded sample, numerical/structural checks, capacity responses, input hashes, and new ELF hashes. This is a new compilation; compare its ELF identities to `measurements.json.gz` before associating it with the published instruction analysis. Source/debug paths can affect binary identity. For replay of the exact measured build, transfer the local `replay-bundles.tar.gz`, verify its manifest hash, and use the included `out/` directory instead of compiling again. The binary must remain paired with its own host, layout, inputs, and case definition.

Masked-product fixtures are under `fixtures/selection/` and `fixtures/final/`. Use the same compile flags and host command. The final group has nine families and includes changed/restored sessions. Use `selection-decision.json` for the frozen choice; do not choose again using final-test performance.

## Check compact evidence without the SDK

```bash
python3 - <<'PY'
import gzip, hashlib, json
from pathlib import Path
root = Path('/home/USER/xkernel-profiling-review-20260924/studies/spgemm-followup-20260924')
manifest = json.loads((root / 'evidence-manifest.json').read_text())
for name, expected in manifest['compact_sha256'].items():
    assert hashlib.sha256((root / name).read_bytes()).hexdigest() == expected, name
trace = json.loads(gzip.decompress((root / 'trace-audit.json.gz').read_bytes()))
assert all(case['passed'] for case in trace['results'])
windows = [window for case in trace['results'] for window in case['windows']]
assert len(windows) == 16
assert sum(window['products'] for window in windows) == 1712
print('Published hashes and trace-audit summary verified')
PY
```

The manifest also indexes the original local evidence. Raw CTF traces and complete build/IR files remain in `/home/USER/spgemm-followup-20260924`; their hashes do not make those large files available through Git. The local replay archive includes full accepted IR and measured build bundles, but not raw CTF traces. Request those separately when rerunning the full instruction audit on another node. Kernel-only IR excerpts in Git are for inspection and omit declarations/debug metadata.

Physical WSE execution needs the hardware node's runtime/launcher adaptation. Record any layout or host changes, check correctness again, and inspect the exact binary measured on hardware. Simulator cycles and the model fitted here are not hardware latency measurements.
