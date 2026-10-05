# Porting WSE-2-only kernels to WSE-3 (2026-06-24)

To be scoreable by the agent track, a kernel needs a `commands_wse3.sh` build (the
agent translates against WSE-3). Six benchmarks were WSE-2-only. This documents the
validated porting template + per-kernel status.

## Why it's not a `sed s/wse2/wse3/`
The WSE-3 fabric resource model differs from WSE-2 in ways that bite at compile AND
runtime. Confirmed empirically (Histogram, 25pt, SpMV-Hypersparse probes):

1. **Task IDs**: `@get_local_task_id(N)` must have N in **[8,31)** on WSE-3 (WSE-2
   allowed low ids 2/3). Pure software tasks remap freely; avoid the memcpy-reserved
   high band (21, 27-31).
2. **Data tasks bind to an INPUT QUEUE, not a color**: `@get_data_task_id(color)`
   (WSE-2) → `@get_data_task_id(@get_input_queue(q))` (WSE-3). Use the
   `if (@is_arch("wse3"))` conditional so the file still builds on WSE-2. (The SDK
   `<kernels/tally>` lib is the canonical reference for this idiom.)
3. **Every user queue must be `@initialize_queue`'d and bound to its color** at
   comptime on WSE-3 — recv INPUT queues, send OUTPUT queues, AND the D2H result
   queue. An uninitialized queue silently: (a) never wakes its consumer data task
   (recv side → stall), or (b) never transmits (send side → wrong/garbage result).
4. **Queue ID map is tight (0-7) and memcpy reserves some**: output queue 0 =
   MEMCPYD2H, input queues 0/1 = memcpy. Input-queue and output-queue ID spaces are
   **independent** (an output queue 2 and an input queue 2 don't collide). Two output
   queues MAY share one color.
5. **Runtime validation is mandatory**: a clean compile does NOT mean correct — each
   queue-init fix uncovers the next layer. Validate with `bash commands_wse3.sh` (the
   harness path) and check the numeric result, not just SUCCESS.

## Template (apply per kernel, validate after each step)
1. `cp commands_wse2.sh commands_wse3.sh`; flip `--arch=wse2` → `--arch=wse3`.
2. Compile; fix illegal task-ids → [8,31).
3. Compile; migrate any `@get_data_task_id(color)` → input-queue form (`@is_arch`).
4. Add `@initialize_queue` for ALL user queues (recv/send/D2H), each bound to its
   color, in an `if (@is_arch("wse3"))` comptime block.
5. Renumber queues off the memcpy-reserved slots; resolve "initialization already set"
   collisions.
6. Run on the simulator; debug stalls/wrong-results layer by layer until the numeric
   result matches the reference.
7. Add `spec.yaml` (with `metric:` per docs/METRICS.md) + register in `KERNEL_REGISTRY`
   (`target_relpath` = the agent-written compute file, NOT the layout).

## Per-kernel status
| kernel | status | metric | notes |
|---|---|---|---|
| **Histogram** | ✅ **PORTED + validated** (commit 0229ec4) | correctness_only | 5 layered fixes (steps 2-6); result=1024 SUCCESS. The worked example. |
| **SpMV-Hypersparse** | ❌ WSE-2-ONLY by upstream design — do NOT port the wrapper | (n/a; see below) | CONCLUSION (2026-06-24): the upstream SDK example (/home/USER/csl-examples/benchmarks/spmv-hypersparse) ships ONLY commands_wse2.sh — no upstream wse3 build. Its vendored libs (hypersparse_spmv 1900 LOC, allreduce2R1E) use wse2-only fabric idioms (teardown-mode C_ROUTE color routing, output queues without wse3 init). Diagnosed far: bundle was missing memory_usage.py/preprocess.py/data (copy from sibling SpMV); queue-collision fixed (input_queues[1] 1→2) so it COMPILES on wse3; but it STALLS at the first D2H because f_sync (allreduce) never completes — the lib's output queue 5 is never @initialize_queue'd on wse3 (the Histogram-class bug, but inside vendored libs). Correctly porting = re-deriving Cerebras's own unported library fabric model. OUT OF SCOPE as a wrapper port. BETTER PATH: replace it with a hand-written SpMV (see HANDWRITTEN_KERNELS below) — the CUDA is a trivial CSR loop. |
| **SpMV** | ⏳ todo | correctness_only | same library family; library-delegated. |
| **3D-FFT** | ⏳ todo | correctness_only | delegates to SDK `<kernels/fft/fft3d_layout>` (wse3-capable, no arch-pin); thin shim, mostly a build flip + queue-init. |
| **25-Point-Stencil** | ⏳ todo (heavier) | cycles | compiles on wse3 after task-id fix, but its run.py uses a bespoke compile/driver flow (stalls even on wse2 in standard staging) — needs a run.py rewrite to the standard SdkRuntime contract, not just the build. |
| **MC-Particle-Transport** | ⏳ todo (heaviest) | normalized_cycles (per particle, rng off) | registered wse3 but build calls a nonexistent compile.py; needs a real cslc build + a from-scratch standard run.py (currently has none). |

## Effort reality
Each port is a focused debugging session (Histogram took 5 distinct fixes across
compile + 3 runtime layers). They are FEASIBLE — the SDK libs support wse3 and the
template is now proven — but they are real co-design, not batch substitutions. Do one
at a time, validate the numeric result, commit.
