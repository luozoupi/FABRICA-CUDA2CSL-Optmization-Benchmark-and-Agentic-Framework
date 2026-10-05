# Cerebras SDK Compiler & Runtime Tools Inventory

## Overview

The Cerebras SDK provides tools for compiling CSL programs, inspecting compiled ELFs,
debugging execution, and retrieving hardware artifacts. This document catalogs every
tool available at `/home/USER/cs_sdk-1.4.0/` (SDK 1.4.0 simulator) and
`~/cs_appliance_sdk/` (SDK 2.10 appliance/hardware).

---

## 1. Compiler Tools

### 1.1 cslc (CSL Compiler Frontend)

**Location:** `/home/USER/cs_sdk-1.4.0/cslc`

**Usage:** `cslc layout.csl --arch=wse3 --fabric-dims=W,H --fabric-offsets=X,Y --params=k:v -o out --memcpy --channels=1`

**Flags:**
| Flag | Purpose |
|------|---------|
| `--arch=wse3` | Target WSE-3 architecture |
| `--fabric-dims=W,H` | Fabric rectangle dimensions |
| `--fabric-offsets=X,Y` | Fabric placement offset |
| `--params=k:v,...` | Compile-time parameter values |
| `--memcpy` | Enable memcpy support for H2D/D2H |
| `--channels=N` | Number of memcpy I/O channels |
| `--verbose` | Show compilation stages with timestamps |
| `--import-path=DIR` | Additional CSL module search path |
| `--width-west-buf=N` | West buffer width (mitigate slow input) |
| `--width-east-buf=N` | East buffer width (mitigate slow output) |

**Verbose output reveals:**
```
Parsing...
Performing layout evaluation and semantic analysis...
Produced N distinct PE programs.
Generating Object Files...
Execute 'cslc-backend' 'schrodinger' 'cs_sdr-cerebras-csos'
Linking...
Execute 'cslc-linker' '-v'
```

**Backend:** `cslc-driver` (forwarded unrecognized flags) → `cslc-backend` (codegen) → `cslc-linker` (ELF linking)

**Output directory structure:**
```
out/
├── bin/
│   ├── out_0_0.elf          # Per-PE compiled ELF (one per distinct PE program)
│   ├── out_1_0.elf          # PE at column 1, row 0
│   └── out_rpc.json         # RPC symbol table (exported names, types, IDs)
├── east/
│   ├── bin/out_*.elf        # East I/O channel ELFs
│   └── out.json
├── west/
│   ├── bin/out_*.elf        # West I/O channel ELFs
│   └── out.json
├── generated/               # memcpy-generated CSL code (when --memcpy used)
└── out.json                 # Compilation parameters
```

### 1.2 cslc-driver (Backend Compiler)

Called internally by `cslc`. Unknown flags from `cslc` are forwarded here.
Located at `/cb/toolchains/cslang/.../bin/cslc-driver` inside the SIF container.

### 1.3 Compilation Metadata (out_rpc.json)

Maps exported symbols to their types and IDs:
```json
{"rpc_symbols": [
  {"id": 1, "kind": "Var", "name": "x", "sym_name": "ptr_x", "type": "[*]f32"},
  {"id": 4, "kind": "Func", "name": "compute", "sym_name": "compute"}
]}
```

---

## 2. ELF Inspection Tools

### 2.1 cs_readelf

**Location:** `/home/USER/cs_sdk-1.4.0/cs_readelf`

**Usage:** `cs_readelf [flags] FILE.elf`

| Flag | What it Shows | Example Output |
|------|--------------|----------------|
| `--ms` | **Memory size** — bytes used per PE | `(4,1): 5808 bytes (2904 words)` |
| `-s, --fs` | **Fabric size** — PE rectangle dimensions | `Fabric: 4x1` |
| `--sym` | **Symbol table** — all variables with addresses, sizes, memory banks | `local_sum_arr.0: addr=0x11a4, size=4, banks=[2,3]` |
| `--routing` | **Fabric routing** — per-color routing config per tile | `[8] (EAST) → (RAMP)` = color 8 receives from EAST, delivers to RAMP |
| `--switching` | **Switch config** — per-color switch positions | Shows ring mode, ctrl pop mode, routing details |
| `--rect` | **PE rectangle** info | Rectangle dimensions and offsets |
| `--mbase=B --mlen=L` | **Memory dump** — read PE memory at address | Raw memory content |
| `--minr X,Y --maxr X,Y` | **Tile range** — limit dumps to specific PEs | Filter output to tiles within range |
| `--units=words` | Change memory addressing to words (vs bytes) | |

**Symbol table details:**
- Shows memory bank assignment per variable (banks 0-7)
- Shows address, size, and type (OBJECT, FUNC, NOTYPE)
- Enables correlation between CSL variables and their physical memory layout

**Routing table details:**
- Shows per-color routing on each tile: `[color_id] (rx_dirs) → (tx_dirs)`
- Includes teardown markers for one-shot transfers
- Colors 21-23 typically used by memcpy infrastructure

### 2.2 csdb (Interactive Debugger)

**Location:** `/home/USER/cs_sdk-1.4.0/csdb`

**Subcommands:**
| Command | Purpose |
|---------|---------|
| `context` | View/set compilation context |
| `image` | Inspect ELF images, symbol tables |
| `memory` | Read/write PE memory at runtime or post-mortem |
| `rectangle` | Select PE rectangle for operations |
| `register` | Read PE configuration registers |
| `settings` | Session settings |
| `target` | Connect to CM (Connection Manager) for live debugging or examine core files |
| `trace` | Select and examine trace data |
| `wavelet` | Dump wavelets to file |
| `workdir` | Set working directory |

**Status:** Unexplored in the agent workflow. Most powerful for diagnosing multi-PE deadlocks
and wavelet routing issues.

---

## 3. Cluster Management Tools

### 3.1 csctl

**Location:** `/usr/local/bin/csctl`

**Job management:**
```bash
csctl get jobs              # List all jobs
csctl get jobs -a           # Include completed jobs
csctl cancel <wsjob-ID>     # Cancel a running job
csctl job get <wsjob-ID>    # Get job details
csctl job set-priority      # Change job priority
```

**Log export (most important for profiling):**
```bash
csctl log-export <wsjob-ID>                    # Export all logs
csctl log-export <wsjob-ID> -b                 # Include binary debug artifacts
csctl log-export <wsjob-ID> -c                 # Include compile artifacts (ELFs)
csctl log-export <wsjob-ID> -b -c -p ./jobs    # Full export to local directory
csctl log-export <wsjob-ID> --tasks coordinator-0,chief-0  # Filter by task
csctl log-export <wsjob-ID> --timeout 3600     # Set timeout (default 3600s)
csctl log-export <wsjob-ID> --num-lines 1000   # Last N lines only
```

**Debug artifact retention:**
```bash
csctl debug-artifact get <wsjob-ID>                           # Check retention status
csctl debug-artifact update <wsjob-ID> --retention-deadline 2026-12-31  # Extend retention
csctl debug-artifact update <wsjob-ID> --mark-delete          # Mark for deletion
```

**Cluster info:**
```bash
csctl cluster                # Cluster status
csctl types                  # Available resource types
csctl get systems            # List WSE systems
```

**Each job has a Grafana dashboard:**
```
https://grafana.REDACTED.cerebras.internal/d/WebHNShVz/wsjob-REDACTED?orgId=1&var-wsjob=<JOB_ID>
```
Access via SSH SOCKS proxy: `ssh -D5555 ${USER}@cerebras.alcf.anl.gov`

---

## 4. Appliance SDK Python APIs

### 4.1 SdkCompiler

```python
from cerebras.sdk.client import SdkCompiler

with SdkCompiler(disable_version_check=True) as compiler:
    # Compile CSL to artifact (runs on cluster management node)
    artifact = compiler.compile(app_path, "layout.csl", cslc_args, out_path)
    
    # Upload additional files to the compilation workspace
    compiler.upload_artifact(local_path, dest_rel_path)
    
    # Download compilation artifacts (ELFs, logs)
    compiler.download_artifact(artifact_name, local_out_path)
```

### 4.2 SdkRuntime

```python
from cerebras.sdk.client import SdkRuntime

with SdkRuntime(artifact, simulator=False, disable_version_check=True) as runner:
    runner.load()
    runner.run()
    
    # Data transfer
    runner.memcpy_h2d(symbol_id, data, col, row, w, h, n, ...)
    runner.memcpy_d2h(data, symbol_id, col, row, w, h, n, ...)
    
    # Execution
    runner.call("func", args)      # Call on PE(0,0) only
    runner.launch("func", args)    # Broadcast to ALL PEs
    
    # Async task management
    task = runner.Task()
    runner.is_task_done(task)
    runner.task_wait(task)
    
    # Artifact download (post-execution)
    runner.download_artifact(name, path)
    
    # Upload additional data
    runner.upload_artifact(path, dest_rel_path)
    
    runner.stop()
```

### 4.3 SdkLauncher (Staged Execution)

For more control over compilation and execution on worker nodes:

```python
from cerebras.sdk.client import SdkLauncher

with SdkLauncher() as launcher:
    # Stage compiled artifact on worker
    launcher.stage(artifact_path)
    
    # Run with %CMADDR% template (replaced by cluster)
    launcher.run("cs_python", "run.py", "--cmaddr", "%CMADDR%")
    
    # Download results
    launcher.download_artifact(name, path)
    
    # Upload files to worker
    launcher.upload_artifact(path, dest_rel_path)
```

### 4.4 debug_util (Post-Mortem Symbol Reader)

**Simulator only** (asserts `is_simulator()`).

```python
from cerebras.sdk.client.debug_util import debug_util

# After SdkRuntime.stop():
dbg = debug_util(artifact_path, sdk_runtime_instance)

# Read a variable from any PE
val = dbg.get_symbol(col, row, "my_variable", np.float32)

# Read across a PE rectangle
vals = dbg.get_symbol_rect(((col0,row0), (col1,row1)), "var", np.float32)

# Read CSL <debug> module trace buffer
trace = dbg.read_trace(col, row, "trace_key")
```

### 4.5 Global Performance View

```python
from cerebras.appliance.utils.global_perf_view import GPVTraceWriter
# Generates Perfetto-format traces for ML training workflows
# (Requires tabulate package; ML-training oriented, uncertain value for CSL kernel profiling)
```

---

## 5. Simulator-Specific Outputs

### 5.1 sim.log

Generated automatically by the simulator. Contains aggregate statistics:
```
num_inst_dispatch: 15234
num_stalls_stall: 2031
num_wavelets: 48
dimX: 4
dimY: 1
```

### 5.2 simfab_traces/stream0

Binary CTF traces (barectf v3.0.1). 7 event types parsed by `ctf_trace_parser.py`:
backpressure, dispatch, pipe, switch_pos, wavelet_entry, wavelet_trace, debug_counters_wavelet.

### 5.3 sim_stats.json

JSON-formatted simulation statistics (same data as sim.log in structured form).

---

## 6. Unexplored Opportunities

### Priority 1: Hardware Debug Artifacts
```bash
# Export ELFs + binary debug data from a real WSE-3 job
csctl log-export wsjob-XXXX -b -c -p ./hw_debug/

# Then inspect with cs_readelf
cs_readelf --sym ./hw_debug/.../out_0_0.elf
cs_readelf --routing ./hw_debug/.../out_0_0.elf
```

### Priority 2: SdkRuntime.download_artifact()
After hardware execution, retrieve per-PE debug data, trace buffers, or custom artifacts.

### Priority 3: csdb Post-Mortem
After a deadlocking kernel, use `csdb target` to examine PE state, memory contents,
and pending wavelets to diagnose the root cause.

### Priority 4: debug_util for Multi-PE Diagnostics
After simulator runs, read per-PE variable values to verify data distribution,
check intermediate computation results, and trace wavelet delivery.
