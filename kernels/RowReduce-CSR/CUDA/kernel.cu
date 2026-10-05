// RowReduce-CSR: plus-monoid reductions of a sparse matrix in CSR (nrows x ncols):
//   y[r]  = sum of the stored values of row r        (reduce to a vector = A * ones)
//   total = sum of all stored values                 (reduce to a scalar)
//
// Concretized from SuiteSparse:GraphBLAS v10.5.x, github.com/DrTimothyAldenDavis/GraphBLAS @ afbe9aaefe5df7632ca82b478d65d0f6c1e14db0 (stable, 2026-09-13).
// reduce_to_scalar follows CUDA/reduce/template/GB_jit_kernel_cuda_reduce.cu: every thread
// strides over the stored values, the thread block reduces with a tile reduction and one
// atomic per block folds into the result (GB_ADD = fp32 plus). rowsum_csr is GraphBLAS'
// reduce-to-vector (GrB_reduce with a vector result, computed as mxv with a vector of
// ones through the dot3 "spdn" kernel): one warp per row, lanes stride the row's
// nonzeros, a shuffle reduction finishes the row. Fixed: fp32, int indices, no iso, no
// zombies, no bitmap/full variants, no JIT macros.

#define BLOCK_SIZE 256
#define WARP 32

__global__ void rowsum_csr(int nrows,
                           const int*   __restrict__ row_ptr,   // [nrows+1]
                           const float* __restrict__ val,       // [nnz]
                           float*       __restrict__ y)         // [nrows]
{
    const int lane = threadIdx.x & (WARP - 1);
    const int warp_id = (blockIdx.x * blockDim.x + threadIdx.x) / WARP;   // one warp per row
    if (warp_id >= nrows) return;
    const int start = row_ptr[warp_id], end = row_ptr[warp_id + 1];
    float acc = 0.0f;
    for (int p = start + lane; p < end; p += WARP) acc += val[p];          // GB_GETA + GB_ADD (plus)
    for (int off = WARP / 2; off > 0; off >>= 1)                            // tile reduction
        acc += __shfl_down_sync(0xffffffff, acc, off);
    if (lane == 0) y[warp_id] = acc;
}

__global__ void reduce_to_scalar(int nnz,
                                 const float* __restrict__ val,   // [nnz]
                                 float*       __restrict__ total) // [1], zero-initialised by the host
{
    __shared__ float partial[BLOCK_SIZE];
    float acc = 0.0f;
    for (int p = blockIdx.x * blockDim.x + threadIdx.x; p < nnz; p += gridDim.x * blockDim.x)
        acc += val[p];                                                     // grid-stride, GB_ADD
    partial[threadIdx.x] = acc;
    __syncthreads();
    for (int s = BLOCK_SIZE / 2; s > 0; s >>= 1) {                          // GB_cuda_threadblock reduce
        if (threadIdx.x < s) partial[threadIdx.x] += partial[threadIdx.x + s];
        __syncthreads();
    }
    if (threadIdx.x == 0) atomicAdd(total, partial[0]);                     // one atomic per block
}

int main() {
    // Host driver omitted for brevity; the two kernels above are the translation target.
    // Inputs: CSR row_ptr[nrows+1] (nnz = row_ptr[nrows]), val[nnz]; outputs y[nrows], total[1].
    return 0;
}
