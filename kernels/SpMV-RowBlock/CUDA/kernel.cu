// SpMV-RowBlock: y = A * x with A in CSR (nrows x ncols), the classic CSR-vector kernel
// (one warp per row, lanes stride the row's nonzeros, warp-shuffle reduction).
//
// Concretized from SuiteSparse:GraphBLAS v10.5.x, github.com/DrTimothyAldenDavis/GraphBLAS @ afbe9aaefe5df7632ca82b478d65d0f6c1e14db0 (stable, 2026-09-13),
// CUDA/mxm/template/GB_cuda_jit_AxB_dot3_phase3_spdn.cuh with A sparse and B := x a full
// n x 1 matrix (GraphBLAS' mxv is dot3 with a one-column B): "one entire thread tile
// computes one dot product; threads stride over the sparse column's nonzeros, gather from
// the dense operand by index and accumulate; GB_cuda_tile_reduce_ztype finishes the tile".
// Read in CSR terms that is exactly the warp-per-row CSR-vector SpMV (Bell & Garland,
// SC'09). Fixed here: fp32 plus-times, int indices, full structural mask (every row), no
// zombies, no iso values, no JIT macros.
//
// Multi-device deployment (the layout the CSL port must fit): the rows are split into P
// consecutive blocks, one block per device; every device holds its rows' CSR slice and a
// complete copy of x (x is broadcast), and owns the corresponding slice of y.

#define BLOCK_SIZE 256
#define WARP 32

__global__ void spmv_csr_vector(int nrows,
                                const int*   __restrict__ row_ptr,   // [nrows+1]
                                const int*   __restrict__ col_idx,   // [nnz]
                                const float* __restrict__ val,       // [nnz]
                                const float* __restrict__ x,         // [ncols], replicated
                                float*       __restrict__ y)         // [nrows]
{
    const int lane = threadIdx.x & (WARP - 1);
    const int row = (blockIdx.x * blockDim.x + threadIdx.x) / WARP;    // one warp per row
    if (row >= nrows) return;
    const int start = row_ptr[row], end = row_ptr[row + 1];
    float sum = 0.0f;
    for (int p = start + lane; p < end; p += WARP)                        // lanes stride the row
        sum += val[p] * x[col_idx[p]];                                    // GB_GETA/GB_GETB gather + GB_MULTADD
    for (int off = WARP / 2; off > 0; off >>= 1)                          // tile reduction
        sum += __shfl_down_sync(0xffffffff, sum, off);
    if (lane == 0) y[row] = sum;
}

int main() {
    // Host driver omitted for brevity; the kernel above is the translation target.
    // Inputs: CSR row_ptr[nrows+1], col_idx[nnz], val[nnz], dense x[ncols]; output y[nrows].
    return 0;
}
