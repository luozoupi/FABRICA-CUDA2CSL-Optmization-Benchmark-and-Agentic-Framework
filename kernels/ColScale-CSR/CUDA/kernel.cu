// ColScale-CSR: C = A * D with A in CSR (nrows x nrows) and D the diagonal matrix of d[nrows].
//
// Concretized from SuiteSparse:GraphBLAS v10.5.x, github.com/DrTimothyAldenDavis/GraphBLAS @ afbe9aaefe5df7632ca82b478d65d0f6c1e14db0 (stable, 2026-09-13),
// CUDA/mxm/template/GB_jit_kernel_cuda_rowscale.cu. GraphBLAS stores matrices by column, so
// its "rowscale" C = D*B reads, for every stored entry p, the row index Bi[p] and multiplies by
// D[Bi[p]] -- a gathered load per nonzero. Read in CSR terms the identical kernel scales
// COLUMNS: the gathered index is col_idx[p]. Fixed here: fp32 values, int indices,
// plus-times multiply, no iso values, no bitmap/full variants, no JIT macros.

#define BLOCK_SIZE 256

__global__ void colscale_csr(int nnz,
                             const int*   __restrict__ col_idx,   // [nnz]
                             const float* __restrict__ val,       // [nnz]
                             const float* __restrict__ d,         // [ncols]
                             float*       __restrict__ c_val)     // [nnz], same pattern as A
{
    const int ntasks = gridDim.x * blockDim.x;
    for (int p = blockIdx.x * blockDim.x + threadIdx.x; p < nnz; p += ntasks) {   // grid-stride over nonzeros
        const int j = col_idx[p];                                                  // GBi_B (Bi, p, bvlen)
        c_val[p] = val[p] * d[j];                                                  // GB_EWISEOP (Cx, p, aij, djj)
    }
}

int main() {
    // Host driver omitted for brevity; the kernel above is the translation target.
    // Inputs: CSR row_ptr[nrows+1] (nnz = row_ptr[nrows]), col_idx[nnz], val[nnz], vector d[ncols];
    // output c_val[nnz].
    return 0;
}
