// RowScale-CSR: C = D * A with A in CSR (nrows x nrows) and D the diagonal matrix of d[nrows].
//
// Concretized from SuiteSparse:GraphBLAS v10.5.x, github.com/DrTimothyAldenDavis/GraphBLAS @ afbe9aaefe5df7632ca82b478d65d0f6c1e14db0 (stable, 2026-09-13),
// CUDA/mxm/template/GB_jit_kernel_cuda_colscale.cu. GraphBLAS stores matrices by column, so
// its "colscale" C = A*D visits every stored entry p, finds the column that owns p with
// GB_cuda_ek_slice (a binary search over the column pointers) and multiplies by D[col]. Read
// in CSR terms the identical kernel scales ROWS: the search runs over row_ptr and the factor
// is d[row]. Fixed here: fp32 values, int indices, plus-times semiring's multiply, no iso
// values, no bitmap/full variants, no JIT macros (GB_GETA/GB_GETB/GB_EWISEOP expanded).

#define BLOCK_SIZE 256

// GB_cuda_ek_slice: the row i with row_ptr[i] <= p < row_ptr[i+1] (binary search).
__device__ __forceinline__ int owner_row(const int* __restrict__ row_ptr, int nrows, int p) {
    int lo = 0, hi = nrows - 1;
    while (lo < hi) {
        int mid = (lo + hi + 1) >> 1;
        if (row_ptr[mid] <= p) lo = mid; else hi = mid - 1;
    }
    return lo;
}

__global__ void rowscale_csr(int nrows, int nnz,
                             const int*   __restrict__ row_ptr,   // [nrows+1]
                             const float* __restrict__ val,       // [nnz]
                             const float* __restrict__ d,         // [nrows]
                             float*       __restrict__ c_val)     // [nnz], same pattern as A
{
    const int ntasks = gridDim.x * blockDim.x;
    for (int p = blockIdx.x * blockDim.x + threadIdx.x; p < nnz; p += ntasks) {   // grid-stride over nonzeros
        const int i = owner_row(row_ptr, nrows, p);                                // GB_cuda_ek_slice
        c_val[p] = d[i] * val[p];                                                  // GB_EWISEOP (Cx, p, dii, aip)
    }
}

int main() {
    // Host driver omitted for brevity; the kernel above is the translation target.
    // Inputs: CSR row_ptr[nrows+1], val[nnz], vector d[nrows]; output c_val[nnz].
    return 0;
}
