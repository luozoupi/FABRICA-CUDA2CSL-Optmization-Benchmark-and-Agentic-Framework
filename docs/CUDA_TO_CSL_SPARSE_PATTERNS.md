# CUDA -> CSL for sparse kernels: the cross-semantic mapping catalogue

Fifteen idioms that classic GPU sparse code (SuiteSparse:GraphBLAS CUDA, Bell-Garland
CSR-vector, row-split SpMM) relies on, what each becomes on the Cerebras WSE-3, why the
architecture forces that, and the measurement or recorded failure behind it. This is the
knowledge block `SPARSE_CUDA_TO_CSL_MAPPING` (code_translation/csl_knowledge_base.py, gate
`XKERNEL_SPARSE_MAPPING=1`) in long form; the block is the treatment of arm T1 in the v2
study. CSL snippets come from the characterization study's microbenchmarks
(`studies/wse3-characterization/microbench/iremit/pe.csl`), the explore-track SpMM
prototype and SDK idioms -- never from a task's reference program.

Machine facts used below (studies/wse3-characterization/FINDINGS.md): one PE = one in-order
16-bit core, 49,152 B of SRAM (44,976 B usable), no cache, no atomics, no indirect DSDs;
DSD op setup 15-17 cycles, loop back-edge 9-10 cycles; fabric 2 cycles per hop, about 20 per
route turn, 1.125 cycles per wavelet; 8 SRAM banks with an f32 period-4 class law (1.94x
same-class penalty, invisible in the simulator). Sparse crossover on one PE, 16x16 banded,
60 nonzeros: scalar CSR gather 36.2 cycles/nnz; one runtime-length DSD per row 31.8 (1.14x);
diagonal form vectorised across rows 7.3 (4.96x).

| id | CUDA idiom | WSE-3 realisation | why | evidence |
|---|---|---|---|---|
| P1 | thread-per-row (`row = blockIdx.x*blockDim.x + threadIdx.x`) | PE-per-row-block: the host splits rows into P consecutive blocks, each PE loops its local rows with global column indices | a PE is one instruction stream, not thousands of threads; parallelism is data partition | mapping block; SpMV-RowBlock design |
| P2 | warp-per-row, `__shfl_down_sync` reduction | in-PE reduction: memory-destination DSD op + scalar sum (f32) or `@faddh` (f16); cross-PE partials via fabric | no warps; an f32 register-destination DSD reduce can lower with dest != src0 and return the last element (faster, wrong) | FINDINGS 10n, 13 |
| P3 | `atomicAdd(&y[i], v)` scatter | owner-computes: each PE accumulates its own rows in SRAM; one reduction pass along a mesh axis | no atomics; per-element fabric sends cost ~20 cycles per turn | mapping block; ParReduce idioms |
| P4 | dynamic output size, `cudaMalloc`, phase-2 cumsum | static capacity params (`max_nnz`) checked at comptime; two-pass symbolic/numeric when needed; masked dot3 output pattern = mask, so nnz is static | no allocator; SRAM is the whole memory | dot3 semantics; explore `MAX_NNZ` padding |
| P5 | phase-1 bucket dispatch (VSVS / VSSP / MERGEPATH by row lengths) | choose the vectorised axis from the structure: DIA/ELL across rows, per-row DSDs, or scalar; or comptime-specialise one path per class | the cost is decided by which axis is a stream, not by "vectorised or not" | FINDINGS 10n crossover 36.2 / 31.8 / 7.3 |
| P6 | merge-path / binary search over sorted lists | two-pointer merge in a plain scalar loop with the cursor updates as EXPLICIT control-flow paths ending in `continue` (equal: both, continue; less: first, continue; else second): 1.18x / 1.15x on the suite's masked SpGEMM (2026-09-26), 1.216x on nine held-out families (NVIDIA node, 2026-09-24). The cost is the indirectly selected cursor update (a pointer phi in the IR), not the branch count: a branchless predicate advance measured 0.45x (2026-09-21) | in-order core: no divergence tax; branches cost 9-10 cycles but an indirect stack update costs more | studies/spgemm-followup-20260924/IR_NOTES.md; kernels/_sparse_expert/SpGEMM-Masked-Dot/pe_cursor_paths.csl; docs/SPARSE_BOTTLENECKS.md |
| P7 | hash-table accumulator (SpGEMM) | dense f32 accumulator row when n*4 B fits the budget, cleared by one `@fmovs`; sorted merge otherwise | SRAM capacity, not bandwidth, is the constraint | FINDINGS 9 (capacity table) |
| P8 | `__syncthreads()`, grid sync | `@activate(task)` chains; a task runs when its data has arrived | no barriers; event-driven execution | mapping block; W1 gotchas |
| P9 | `__shared__` staging, tiling for L1 | everything SRAM-resident; tile only when capacity forces P > 1 | no cache hierarchy | FINDINGS 9 |
| P10 | coalesced global loads | contiguous `mem1d_dsd` runs with stride; mind the bank class of dest vs source (period 4 for f32) | 8 banks x 2 B interleave; 1.94x same-class penalty, silicon-only | FINDINGS 3 |
| P11 | mask `M(i,j)` tests | the mask's pattern is the work list; owner PE holds its mask tile | output structure known in advance | dot3 |
| P12 | one block per row, hardware scheduler balances | static nnz-balanced row partition, `analyze.cpp`-style reordering; the slowest PE sets the time | no work stealing | spmv-hypersparse README; power-law class |
| P13 | `int` / `int64_t` indices | u16 / i16 indices (n < 65,536): each u32 index costs a scale-and-narrow shift pair, 3.5 per nonzero | 16-bit machine | FINDINGS 10n, 12c rule M5 |
| P14 | `cudaMemcpy` of any element width | memcpy moves 32-bit elements (`MEMCPY_32BIT`); u16 data as 16-bit copies or packed pairs; exports `[*]T` with `var` pointers | memcpy contract | explore failure "should be 32 bit"; export-mutability trap |
| P15 | grid-stride over nonzeros with per-entry row recovery (`GB_cuda_ek_slice`: a binary search over the row pointers for every `p`) | walk the rows: the row is the outer loop variable, `row_ptr[i]..row_ptr[i+1]` bounds the inner loop or one per-row DSD op; nothing is searched | the GPU searches so that every thread has independent work; on one in-order PE the search is about log2(nrows) dependent branches per nonzero on top of the arithmetic | pilot 16 Sep 2026: both translation arms kept the search on RowScale-CSR and ran 9.0x slower than the row walk (411,519 vs 45,868 cycles) |

## P5 in code: the axis decides, not the DSD

CUDA (GraphBLAS `GB_cuda_jit_AxB_dot3_phase1.cuh`, bucket per mask entry):

```cuda
if (ainz + bjnz <= 128)      bucket = GB_BUCKET_VSVS;          // both very sparse: one thread merges
else if (max(ainz,bjnz) >= 8*min(ainz,bjnz)) bucket = GB_BUCKET_VSSP;   // imbalanced: binary search
else                          bucket = GB_BUCKET_MERGEPATH;     // balanced: merge-path
```

The GPU picks a kernel per entry so that warps stay busy. On a PE the analogous decision is
which axis becomes a DSD stream. Per-row descriptors (`spmv_blk`, 1.14x over scalar):

```csl
while (r < NROWS) : (r += 1) {
  const s: u16 = row_ptr[r];  const n: u16 = run_len[r];  const c0: u16 = col_start[r];
  var vd = @set_dsd_length(val_dsd, n);   vd = @increment_dsd_offset(vd, @as(i16, s), f32);
  var xd = @set_dsd_length(x_dsd, n);     xd = @increment_dsd_offset(xd, @as(i16, c0), f32);
  var td = @set_dsd_length(tmp_dsd, n);
  @fmuls(td, vd, xd);                     // one DSD op per row ...
  var acc: f32 = 0.0;  var q: u16 = 0;
  while (q < n) : (q += 1) { acc += tmp[q]; }   // ... but still a horizontal reduction per row
  y_bk[r] = acc;
}
```

Diagonals as streams (`spmv_dia`, 4.96x over scalar): no gather, no horizontal reduction,
two DSD ops per diagonal for the whole matrix.

```csl
@fmovs(ydi_dsd, 0.0);
while (d < NDIA) : (d += 1) {
  const n: u16 = dia_len[d];
  var vd = @set_dsd_length(dv_dsd, n);   vd = @increment_dsd_offset(vd, @as(i16, dia_off[d]), f32);
  var xd = @set_dsd_length(x_dsd, n);    xd = @increment_dsd_offset(xd, @as(i16, dia_xoff[d]), f32);
  var td = @set_dsd_length(tmp_dsd, n);
  var yd = @set_dsd_length(ydi_dsd, n);  yd = @increment_dsd_offset(yd, @as(i16, dia_row0[d]), f32);
  @fmuls(td, vd, xd);
  @fadds(yd, yd, td);                    // memory-destination accumulate: no register hazard
}
```

The structure readout tells which form applies: few diagonals or contiguous rows -> DIA/ELL;
long rows -> per-row descriptors; skewed rows -> balance the partition first.

## P2 in code: the reduction that is correct-looking, faster and wrong

CUDA finishes a warp's partial sums with shuffles:

```cuda
for (int off = 16; off > 0; off >>= 1) sum += __shfl_down_sync(0xffffffff, sum, off);
if (lane == 0) y[row] = sum;
```

The tempting CSL translation reduces a descriptor into a register accumulator:

```csl
@fadds(&acc, acc, td);        // may lower to `fadds d12 = d0, [s1ds1]`: dest != src0
```

On SDK 2.10 the backend sometimes allocates the destination away from source-0; then nothing
accumulates and `acc` receives the LAST element. The broken form is faster (18.5 vs 31.8
cycles per nonzero) and passes a single lucky input. Use the memory-destination form
(`@fadds(yd, yd, td)`) or a scalar sum, and check the disassembly line the readout quotes.

## P6 in code: merge without a divergence tax

CUDA (`GB_cuda_jit_AxB_dot3_phase3_vsvs.cuh`):

```cuda
while (pA < pA_end && pB < pB_end) {
    int64_t ia = Ai[pA], ib = Bi[pB];
    if (ia == ib) { cij += Ax[pA] * Bx[pB]; cij_exists = true; }
    pA += (ia <= ib);  pB += (ib <= ia);
}
```

CSL keeps the same shape, but the cursor updates must be explicit control-flow paths. The
arithmetic form `p += @as(u16, ra <= rb)` measured 0.45x (2026-09-21), and an if/else chain
makes cslc select a stack address for the cursor and update it indirectly; the form below
makes it emit conditional register increments (1.18x on the suite's reference, 26 Sep 2026;
the IR evidence is in studies/spgemm-followup-20260924/IR_NOTES.md):

```csl
while (p < p_end and q < q_end) {
  const ra: u16 = rows16[p];  const rb: u16 = rows16[q];
  if (ra == rb) { prod += vals[p] * vals[q]; hit = true; p += 1; q += 1; continue; }
  if (ra < rb) { p += 1; continue; }
  q += 1;
}
```

When the accumulator row fits (P7), scatter into a dense row and skip the merge entirely.

## P3 in code: owner computes

```cuda
atomicAdd(&y[row], val[p] * x[col_idx[p]]);        // many threads, one destination
```

```csl
// every PE owns rows [r0, r1): accumulate locally, then ONE stream of partials per PE
y_local[r] += v * x_local[c];
...
@fmovs(fab_out, y_dsd, .{ .async = true });          // partial sums leave as a wavelet stream
```

## P15 in code: the row lookup that only a GPU needs

CUDA (GraphBLAS `GB_jit_kernel_cuda_colscale.cu`, read in CSR terms; `GB_cuda_ek_slice` expanded):

```cuda
__device__ int owner_row(const int* row_ptr, int nrows, int p) {      // GB_cuda_ek_slice
    int lo = 0, hi = nrows - 1;
    while (lo < hi) { int mid = (lo + hi + 1) >> 1; if (row_ptr[mid] <= p) lo = mid; else hi = mid - 1; }
    return lo;
}
for (int p = blockIdx.x * blockDim.x + threadIdx.x; p < nnz; p += ntasks)   // grid-stride over nonzeros
    c_val[p] = d[owner_row(row_ptr, nrows, p)] * val[p];
```

Every GraphBLAS per-entry kernel (colscale, rowscale, apply, select, emult, reduce) is written
this way because a thread must know its row without having walked the preceding entries. On
one PE the entries are walked anyway, so the search is pure overhead: about log2(nrows)
dependent compare-and-branch steps (9 for 512 rows, each 9-10 cycles) per nonzero, in u32.
In the 16 Sep pilot the agent reproduced the search faithfully in both arms and the program
ran 9.0x slower than a row walk of the same matrix. The WSE-3 form recovers the row from the
loop structure and, when rows are long enough, turns the inner loop into one descriptor op:

```csl
// one runtime-length descriptor per row: the factor d[i] is a scalar operand
var i: u16 = 0;
while (i < NROWS) : (i += 1) {
  const p0: u16 = rp[i];  const len: u16 = rp[i + 1] - p0;
  var src = @set_dsd_length(vals_dsd, len);  src = @increment_dsd_offset(src, @as(i16, p0), f32);
  var dst = @set_dsd_length(cvals_dsd, len); dst = @increment_dsd_offset(dst, @as(i16, p0), f32);
  @fmuls(dst, src, dvec[i]);                 // no search, no per-nonzero index arithmetic
}
```

Short rows (mean below ~8 nonzeros) pay the 15-17 cycle descriptor setup per row; there the
scalar inner loop over `p0..p0+len` is the right form, still without a search. The structure
readout's row-length mean decides.

## Provenance and firewall

CUDA snippets are concretized GraphBLAS templates (github.com/DrTimothyAldenDavis/GraphBLAS
`stable` @ afbe9aae) or Bell-Garland idioms; CSL snippets are the study's microbenchmarks
(`microbench/iremit/pe.csl`), the explore SpMM prototype and SDK idioms. `test_sparse_mapping_
leak.py` asserts that no line of any S task's reference program appears in this document or
in the knowledge block.
