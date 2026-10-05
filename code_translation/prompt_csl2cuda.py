"""
Prompts and constants for CSL <-> CUDA kernel translation and verification.
"""

# ── System instruction ──────────────────────────────────────────────────
Instruction_system = """You are an expert in Cerebras CSL (Cerebras Software Language) and CUDA GPU programming.
Your task is to translate HPC kernels between CSL and CUDA, debug compilation/runtime issues,
and verify functional equivalence. Always provide complete, self-contained programs in code fences."""

# ── Phase A: Validate / wrap source CSL code ────────────────────────────
# CSL cannot be compiled locally, so Phase A asks the LLM to analyse the
# CSL kernel and produce a description of what it computes, its inputs /
# outputs, and the expected numerical behaviour.

q_analyse_csl_source = """Analyse the following Cerebras CSL kernel code.
Provide:
1. A concise summary of the computation it performs (e.g., GEMV, stencil, CG iteration …).
2. The mathematical formula or algorithm (use LaTeX-style notation).
3. The inputs and outputs (name, type, shape).
4. Any data-movement / communication patterns (fabric colours, memcpy, allreduce).

CSL kernel:
```csl
{csl_code}
```

Answer in a structured format."""

# ── Phase B: Translate CSL → CUDA ───────────────────────────────────────
q_translate_csl_to_cuda = """Translate the following Cerebras CSL kernel into an equivalent,
self-contained CUDA C++ program (.cu file). Requirements:
1. Implement the SAME algorithm / computation as the CSL kernel.
2. Include a `main()` that allocates data, runs the kernel, and **prints
   numerical results** so correctness can be verified.
3. Include a CPU reference implementation and compare GPU vs CPU results,
   printing PASS or FAIL.
4. Use standard CUDA (no external libraries beyond cuBLAS if needed).
5. The program must compile with `nvcc -O3` and run correctly.

Provide the complete code in a ```cuda code fence.

CSL kernel:
```csl
{csl_code}
```

CSL analysis:
{csl_analysis}
"""

# ── Phase B: Translate CUDA → CSL ───────────────────────────────────────
q_translate_cuda_to_csl = """Translate the following CUDA kernel into an equivalent
Cerebras CSL kernel. Requirements:
1. Implement the SAME algorithm / computation as the CUDA kernel.
2. Use appropriate CSL constructs: fabric colours for communication,
   memcpy for host transfers, task-based execution.
3. Provide the pe.csl (or kernel.csl) file with the core computation.
4. Add comments explaining the data layout and communication pattern.

Provide the code in a ```csl code fence.

CUDA kernel:
```cuda
{cuda_code}
```

CUDA analysis:
{cuda_analysis}
"""

# ── Debug: CUDA compile / runtime errors ────────────────────────────────
cuda_compile_fix = """The CUDA program has compilation or runtime issues:

{compile_result}

Please fix the CUDA code and provide the corrected version in a ```cuda code fence.
Do NOT change the algorithm — only fix compilation/runtime bugs."""

cuda_link_fix = """The CUDA code has missing headers or undefined references:

{compile_result}

Please provide a single, self-contained .cu file that includes all necessary code
inline without external dependencies (except standard CUDA headers).
Use a ```cuda code fence."""

# ── Debug: output mismatch ──────────────────────────────────────────────
cuda_output_mismatch_fix = """The CUDA program compiles and runs but produces
incorrect results compared to the CPU reference.

CUDA code:
```cuda
{cuda_code}
```

Program output:
{cuda_output}

Please fix the CUDA kernel so that it produces correct results matching the
CPU reference. Provide the corrected code in a ```cuda code fence."""

# ── Output comparison (AI judge) ────────────────────────────────────────
output_comparison_analysis = """Examine the program output below and determine if
the CUDA kernel produced correct results.

Source code:
```cuda
{cuda_code}
```

Program output:
{cuda_output}

Answer with YES if the output indicates the kernel passed correctness checks
(look for "PASS", small error values, or matching results), or NO if it
indicates failure. Start your response with YES or NO on the first line,
then explain your reasoning."""

# ── End / summary prompt ────────────────────────────────────────────────
end_prompt = """Great! The translation is successful. Please provide the final,
cleaned-up version of the CUDA code in a ```cuda code fence, with clear comments
explaining the correspondence to the original CSL constructs."""

# ============================================================================
# Multi-step CUDA optimization prompts
# ============================================================================

Instruction_system_multistep = """You are an expert in CUDA GPU programming and performance optimization.
You apply CUDA optimizations incrementally, one technique at a time, to systematically improve kernel performance.

Key optimization techniques (in typical order):
1. **Shared memory tiling**: Cache global memory data in shared memory to reduce global memory bandwidth pressure and exploit data reuse.
2. **Memory coalescing**: Reorganize access patterns so threads in a warp access consecutive memory addresses for maximum memory throughput.
3. **Warp-level primitives**: Use `__shfl_down_sync`, `__shfl_xor_sync`, warp-level reductions, and cooperative groups to reduce shared memory traffic and synchronization overhead.
4. **Loop unrolling**: Use `#pragma unroll` on inner loops to increase ILP (instruction-level parallelism) and reduce loop overhead.
5. **Vectorized memory access**: Use `float4`/`int4` vector loads/stores to issue wider memory transactions (128-bit) and reduce the number of memory instructions.
6. **Occupancy tuning**: Adjust block dimensions, use `__launch_bounds__`, and minimize register pressure to maximize SM occupancy.

Rules:
- Preserve the algorithm's correctness at each step — the program must still print PASS.
- Keep the `main()` function with CPU reference comparison and PASS/FAIL output.
- Each step should build on the previous code, adding ONE optimization technique.
- Always provide complete, self-contained code in a ```cuda code fence.
- Do NOT add optimizations beyond the one requested.
- The code must compile with `nvcc -O3` and run correctly."""

# Step-specific optimization prompts
# Each takes {current_code} and optionally {cuda_output} (timing from previous run)

q_optimize_shared_memory = """Apply SHARED MEMORY TILING optimization to the following CUDA code.

Shared memory tiling means:
- Identify data accessed by multiple threads within a block and cache it in `__shared__` memory
- Load tiles of input data from global memory into shared memory cooperatively (each thread loads one or a few elements)
- Use `__syncthreads()` between load and compute phases
- Compute from shared memory instead of global memory
- Choose a tile size that fits in shared memory (e.g., 32x32 for 2D, 256-1024 for 1D)

Do NOT change the algorithm or the correctness check. Only add shared memory usage.

Previous run output (for reference):
{cuda_output}

Current CUDA code:
```cuda
{current_code}
```

Provide the complete shared-memory-optimized code in a ```cuda code fence."""

q_optimize_coalescing = """Apply MEMORY COALESCING optimization to the following CUDA code.

Memory coalescing means:
- Ensure that consecutive threads (threadIdx.x, threadIdx.x+1, ...) access consecutive memory addresses
- For 2D data, use row-major layout with threadIdx.x mapped to the column dimension
- Avoid strided access patterns (e.g., column-major access in row-major arrays)
- If the data layout prevents coalescing, transpose the data or change the thread mapping
- Pad shared memory arrays to avoid bank conflicts: `__shared__ float tile[N][N+1]`

Do NOT change the algorithm or the correctness check.

Previous run output (for reference):
{cuda_output}

Current CUDA code:
```cuda
{current_code}
```

Provide the complete coalescing-optimized code in a ```cuda code fence."""

q_optimize_warp = """Apply WARP-LEVEL PRIMITIVES optimization to the following CUDA code.

Warp-level optimization means:
- Replace shared-memory reductions with warp shuffle intrinsics:
  `__shfl_down_sync(0xffffffff, val, offset)` for warp-level reduction
  `__shfl_xor_sync(0xffffffff, val, mask)` for butterfly reduction
- Use `__ballot_sync()` and `__popc()` for warp-level voting
- Eliminate `__syncthreads()` within a single warp (32 threads execute in lockstep)
- For reductions across multiple warps, combine warp shuffle (intra-warp) with shared memory (inter-warp)
- Use cooperative groups for flexible thread grouping if needed

Do NOT change the algorithm or the correctness check.

Previous run output (for reference):
{cuda_output}

Current CUDA code:
```cuda
{current_code}
```

Provide the complete warp-optimized code in a ```cuda code fence."""

q_optimize_unroll = """Apply LOOP UNROLLING optimization to the following CUDA code.

Loop unrolling means:
- Add `#pragma unroll` or `#pragma unroll N` before inner loops with known trip counts
- For loops with compile-time-known bounds, use full unrolling: `#pragma unroll`
- For loops with large/variable bounds, use partial unrolling: `#pragma unroll 4` or `#pragma unroll 8`
- Focus on the innermost compute loops (dot products, accumulations, stencil neighbors)
- Manually unroll small loops (2-4 iterations) if the compiler hint is insufficient
- Increase ILP by computing multiple output elements per thread when appropriate

Do NOT change the algorithm or the correctness check.

Previous run output (for reference):
{cuda_output}

Current CUDA code:
```cuda
{current_code}
```

Provide the complete unroll-optimized code in a ```cuda code fence."""

q_optimize_vectorized = """Apply VECTORIZED MEMORY ACCESS optimization to the following CUDA code.

Vectorized memory access means:
- Use `float4` (128-bit) loads/stores instead of `float` (32-bit) for consecutive memory accesses
- Cast pointers: `const float4* A4 = reinterpret_cast<const float4*>(A);`
- Each `float4` load fetches 4 floats in a single memory transaction
- Adjust loop bounds: iterate over N/4 elements instead of N
- Handle remainder elements (when N is not divisible by 4) with scalar loads
- Ensure input pointers are 16-byte aligned for optimal performance
- For shared memory, load `float4` from global, then scatter into `float` shared arrays

Do NOT change the algorithm or the correctness check.

Previous run output (for reference):
{cuda_output}

Current CUDA code:
```cuda
{current_code}
```

Provide the complete vectorized-access-optimized code in a ```cuda code fence."""

q_optimize_occupancy = """Apply OCCUPANCY TUNING optimization to the following CUDA code.

Occupancy tuning means:
- Use `__launch_bounds__(maxThreadsPerBlock, minBlocksPerMultiprocessor)` on the kernel
- Tune block dimensions to maximize SM occupancy (typical sweet spots: 128, 256, or 512 threads)
- Reduce register usage if needed: use `__launch_bounds__` or `-maxrregcount` flag
- Use `cudaOccupancyMaxPotentialBlockSize()` to dynamically pick optimal block size
- Add CUDA event timing around the kernel launch to measure actual performance:
  ```
  cudaEvent_t start, stop;
  cudaEventCreate(&start); cudaEventCreate(&stop);
  cudaEventRecord(start);
  kernel<<<grid, block>>>(...);
  cudaEventRecord(stop);
  cudaEventSynchronize(stop);
  float ms; cudaEventElapsedTime(&ms, start, stop);
  printf("Kernel time: %.3f ms\\n", ms);
  ```
- Report effective bandwidth: `printf("Bandwidth: %.1f GB/s\\n", bytes / ms / 1e6);`

Do NOT change the algorithm or the correctness check.

Previous run output (for reference):
{cuda_output}

Current CUDA code:
```cuda
{current_code}
```

Provide the complete occupancy-tuned code in a ```cuda code fence."""

# Generic optimization prompt (for custom step names)
q_optimize_cuda_generic = """Apply the following optimization to the CUDA code: **{optimization_name}**

{optimization_description}

Keep the algorithm, correctness check, and PASS/FAIL output intact.

Previous run output (for reference):
{cuda_output}

Current CUDA code:
```cuda
{current_code}
```

Provide the complete optimized code in a ```cuda code fence."""

# Map step names to prompts
CUDA_OPTIMIZATION_PROMPTS = {
    "shared_memory": q_optimize_shared_memory,
    "coalescing": q_optimize_coalescing,
    "warp": q_optimize_warp,
    "unroll": q_optimize_unroll,
    "vectorized": q_optimize_vectorized,
    "occupancy": q_optimize_occupancy,
}

# Default CUDA optimization order
DEFAULT_CUDA_OPT_STEPS = ["shared_memory", "coalescing", "warp", "unroll", "vectorized", "occupancy"]
