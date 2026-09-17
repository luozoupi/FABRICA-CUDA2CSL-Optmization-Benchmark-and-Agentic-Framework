/*
 * CUDA SpMV (CSR): y = A * x for a sparse matrix A in Compressed Sparse Row format.
 *
 * This is the HAND-WRITTEN-COMPUTE variant of SpMV: instead of delegating to a
 * vendored hypersparse-SpMV dataflow library (see kernels/SpMV-Hypersparse), the
 * compute is the explicit textbook CSR matvec, so a CSL translation must express the
 * actual arithmetic (a per-row reduction with a gathered/indexed load of x). The
 * single-PE layout keeps it a clean, cycle-scoreable translation task.
 *
 * CSR layout:
 *   row_ptr[nrows+1] : row r occupies val/col_idx in [row_ptr[r], row_ptr[r+1])
 *   col_idx[nnz]     : column index of each nonzero
 *   val[nnz]         : value of each nonzero
 *   x[ncols]         : dense input vector
 *   y[nrows]         : dense output vector
 *
 * Core compute (one thread per row):
 *   for j in [row_ptr[row], row_ptr[row+1]):
 *     sum += val[j] * x[col_idx[j]]
 *   y[row] = sum
 */

#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

#define BLOCK_SIZE 256

// Scalar CSR SpMV: one thread per row.
__global__ void spmv_csr(
    const int*   __restrict__ row_ptr,
    const int*   __restrict__ col_idx,
    const float* __restrict__ val,
    const float* __restrict__ x,
    float*       __restrict__ y,
    int nrows)
{
    int row = blockIdx.x * blockDim.x + threadIdx.x;
    if (row >= nrows) return;

    float sum = 0.0f;
    int start = row_ptr[row];
    int end   = row_ptr[row + 1];
    for (int j = start; j < end; j++) {
        sum += val[j] * x[col_idx[j]];   // indexed (gathered) load of x
    }
    y[row] = sum;
}

int main(void) {
    // Host driver omitted for brevity; the kernel above is the translation target.
    // Reference verification (y == A*x) is performed in the CSL bundle's run.py.
    return 0;
}
