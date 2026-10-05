// SpMM-CSR-Dense: C = A * B with A sparse in CSR (M x K) and B dense (K x N, row-major),
// the classic row-split SpMM: one warp per row of A, lanes stride the N output columns,
// every nonzero a_ik scales the dense row B[k,:] into the accumulator row.
//
// Concretized from SuiteSparse:GraphBLAS v10.5.x, github.com/DrTimothyAldenDavis/GraphBLAS @ afbe9aaefe5df7632ca82b478d65d0f6c1e14db0 (stable, 2026-09-13),
// CUDA/mxm/template/GB_cuda_jit_AxB_dot3_phase3_spdn.cuh with A sparse and B full and a
// full structural mask (every C(i,j) is computed): "threads stride over the sparse
// column's nonzeros, gather from the dense operand by index (GB_GETA/GB_GETB) and
// GB_MULTADD into a per-thread accumulator". GraphBLAS stores by column; in CSR terms the
// same per-nonzero gather-and-multiply-add over the dense operand is the row-split SpMM
// below (Bell-Garland style). Fixed here: fp32 plus-times, int indices, no zombies, no iso
// values, no JIT macros. Deviation kept on purpose: B is stored row-major so that B[k,:]
// is a contiguous run (the layout the wafer port relies on).
//
// Multi-device deployment (the layout the CSL port must fit): a P x P mesh; the rows of A
// are split into P tiles (one per mesh row, replicated along the row), the columns of B
// into P slices (one per mesh column, replicated down the column); the device (px, py)
// owns the C tile (rows of tile py, columns of slice px). No communication.

#define BLOCK_SIZE 256
#define WARP 32

__global__ void spmm_csr_dense(int M, int N,
                               const int*   __restrict__ row_ptr,   // [M+1]
                               const int*   __restrict__ col_idx,   // [nnz], < K
                               const float* __restrict__ val,       // [nnz]
                               const float* __restrict__ B,         // [K*N], row-major
                               float*       __restrict__ C)         // [M*N], row-major
{
    const int lane = threadIdx.x & (WARP - 1);
    const int row = (blockIdx.x * blockDim.x + threadIdx.x) / WARP;    // one warp per row of A
    if (row >= M) return;
    const int start = row_ptr[row], end = row_ptr[row + 1];
    for (int j = lane; j < N; j += WARP) {                                // lanes stride the output columns
        float acc = 0.0f;
        for (int p = start; p < end; ++p) {
            const int k = col_idx[p];                                      // GB_GETA index
            acc += val[p] * B[k * N + j];                                  // gather B[k,:] + GB_MULTADD
        }
        C[row * N + j] = acc;
    }
}

int main() {
    // Host driver omitted for brevity; the kernel above is the translation target.
    // Inputs: CSR row_ptr[M+1], col_idx[nnz], val[nnz], dense B[K*N]; output C[M*N].
    return 0;
}
