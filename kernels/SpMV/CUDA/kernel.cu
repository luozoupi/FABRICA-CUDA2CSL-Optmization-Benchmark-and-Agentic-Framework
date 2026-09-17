/*
 * CUDA SpMV: y = A * x (Sparse Matrix-Vector Multiplication)
 *
 * Translates the CSL SpMV kernel from:
 *   sdk-examples/benchmarks/spmv-hypersparse/src/hypersparse_spmv/pe.csl
 *
 * CSL approach:
 *   - 2D PE grid, matrix partitioned across PEs
 *   - Each PE holds a local sparse tile in CSR-like format
 *   - Local SpMV followed by allreduce to sum partial results
 *   - Supports hypersparse matrices (many empty rows)
 *
 * CUDA approach:
 *   - CSR format (standard for GPU SpMV)
 *   - One thread-block per row (scalar CSR SpMV)
 *   - Also includes a vector CSR variant (warp per row)
 *
 * Test uses a random sparse matrix generated in CSR format.
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cuda_runtime.h>

#define BLOCK_SIZE 256
#define WARP_SIZE 32

// Scalar CSR SpMV: one thread per row
__global__ void spmv_csr_scalar(
    const int* __restrict__ row_ptr,
    const int* __restrict__ col_idx,
    const float* __restrict__ val,
    const float* __restrict__ x,
    float* __restrict__ y,
    int nrows)
{
    int row = blockIdx.x * blockDim.x + threadIdx.x;
    if (row >= nrows) return;

    float sum = 0.0f;
    int start = row_ptr[row];
    int end = row_ptr[row + 1];
    for (int j = start; j < end; j++)
        sum += val[j] * x[col_idx[j]];
    y[row] = sum;
}

// Vector CSR SpMV: one warp per row (better for long rows)
__global__ void spmv_csr_vector(
    const int* __restrict__ row_ptr,
    const int* __restrict__ col_idx,
    const float* __restrict__ val,
    const float* __restrict__ x,
    float* __restrict__ y,
    int nrows)
{
    int warp_id = (blockIdx.x * blockDim.x + threadIdx.x) / WARP_SIZE;
    int lane = threadIdx.x % WARP_SIZE;

    if (warp_id >= nrows) return;

    float sum = 0.0f;
    int start = row_ptr[warp_id];
    int end = row_ptr[warp_id + 1];

    for (int j = start + lane; j < end; j += WARP_SIZE)
        sum += val[j] * x[col_idx[j]];

    // Warp reduction
    for (int s = WARP_SIZE / 2; s > 0; s >>= 1)
        sum += __shfl_down_sync(0xffffffff, sum, s);

    if (lane == 0)
        y[warp_id] = sum;
}

// Generate random sparse matrix in CSR format
void generate_sparse_csr(int nrows, int ncols, float density,
                         int** row_ptr, int** col_idx, float** val, int* nnz) {
    *row_ptr = (int*)malloc((nrows + 1) * sizeof(int));
    int max_nnz = (int)(nrows * ncols * density * 1.5) + nrows;
    *col_idx = (int*)malloc(max_nnz * sizeof(int));
    *val = (float*)malloc(max_nnz * sizeof(float));

    int count = 0;
    (*row_ptr)[0] = 0;
    for (int i = 0; i < nrows; i++) {
        for (int j = 0; j < ncols; j++) {
            if ((float)rand() / RAND_MAX < density) {
                (*col_idx)[count] = j;
                (*val)[count] = (float)rand() / RAND_MAX - 0.5f;
                count++;
            }
        }
        (*row_ptr)[i + 1] = count;
    }
    *nnz = count;
}

int main(int argc, char** argv) {
    int N = 4096;
    float density = 0.01f;
    if (argc > 1) N = atoi(argv[1]);
    if (argc > 2) density = atof(argv[2]);

    printf("SpMV (CSR): %dx%d, density=%.3f\n", N, N, density);

    srand(42);

    int *h_row_ptr, *h_col_idx;
    float *h_val;
    int nnz;
    generate_sparse_csr(N, N, density, &h_row_ptr, &h_col_idx, &h_val, &nnz);
    printf("NNZ: %d (actual density: %.4f)\n", nnz, (float)nnz / (N * N));

    float *h_x = (float*)malloc(N * sizeof(float));
    float *h_y = (float*)malloc(N * sizeof(float));
    float *h_ref = (float*)malloc(N * sizeof(float));

    for (int i = 0; i < N; i++) h_x[i] = (float)rand() / RAND_MAX - 0.5f;

    // Reference SpMV
    for (int i = 0; i < N; i++) {
        float s = 0.0f;
        for (int j = h_row_ptr[i]; j < h_row_ptr[i + 1]; j++)
            s += h_val[j] * h_x[h_col_idx[j]];
        h_ref[i] = s;
    }

    // Device
    int *d_row_ptr, *d_col_idx;
    float *d_val, *d_x, *d_y;
    cudaMalloc(&d_row_ptr, (N + 1) * sizeof(int));
    cudaMalloc(&d_col_idx, nnz * sizeof(int));
    cudaMalloc(&d_val, nnz * sizeof(float));
    cudaMalloc(&d_x, N * sizeof(float));
    cudaMalloc(&d_y, N * sizeof(float));

    cudaMemcpy(d_row_ptr, h_row_ptr, (N + 1) * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_col_idx, h_col_idx, nnz * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_val, h_val, nnz * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_x, h_x, N * sizeof(float), cudaMemcpyHostToDevice);

    // Test scalar variant
    int grid_scalar = (N + BLOCK_SIZE - 1) / BLOCK_SIZE;
    spmv_csr_scalar<<<grid_scalar, BLOCK_SIZE>>>(d_row_ptr, d_col_idx, d_val, d_x, d_y, N);
    cudaMemcpy(h_y, d_y, N * sizeof(float), cudaMemcpyDeviceToHost);

    float max_err = 0.0f, max_val = 0.0f;
    for (int i = 0; i < N; i++) {
        float err = fabsf(h_y[i] - h_ref[i]);
        if (err > max_err) max_err = err;
        if (fabsf(h_ref[i]) > max_val) max_val = fabsf(h_ref[i]);
    }
    float rel = (max_val > 0) ? max_err / max_val : max_err;
    printf("Scalar CSR: max_err=%e, rel=%e -> %s\n", max_err, rel,
           (rel < 1e-5) ? "PASS" : "FAIL");

    // Test vector variant
    int grid_vector = (N * WARP_SIZE + BLOCK_SIZE - 1) / BLOCK_SIZE;
    cudaMemset(d_y, 0, N * sizeof(float));
    spmv_csr_vector<<<grid_vector, BLOCK_SIZE>>>(d_row_ptr, d_col_idx, d_val, d_x, d_y, N);
    cudaMemcpy(h_y, d_y, N * sizeof(float), cudaMemcpyDeviceToHost);

    max_err = 0.0f;
    for (int i = 0; i < N; i++) {
        float err = fabsf(h_y[i] - h_ref[i]);
        if (err > max_err) max_err = err;
    }
    rel = (max_val > 0) ? max_err / max_val : max_err;
    printf("Vector CSR: max_err=%e, rel=%e -> %s\n", max_err, rel,
           (rel < 1e-5) ? "PASS" : "FAIL");

    // Benchmark both
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    int niter = 200;

    // Scalar
    for (int i = 0; i < 10; i++)
        spmv_csr_scalar<<<grid_scalar, BLOCK_SIZE>>>(d_row_ptr, d_col_idx, d_val, d_x, d_y, N);
    cudaEventRecord(start);
    for (int i = 0; i < niter; i++)
        spmv_csr_scalar<<<grid_scalar, BLOCK_SIZE>>>(d_row_ptr, d_col_idx, d_val, d_x, d_y, N);
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    float ms1;
    cudaEventElapsedTime(&ms1, start, stop);

    // Vector
    for (int i = 0; i < 10; i++)
        spmv_csr_vector<<<grid_vector, BLOCK_SIZE>>>(d_row_ptr, d_col_idx, d_val, d_x, d_y, N);
    cudaEventRecord(start);
    for (int i = 0; i < niter; i++)
        spmv_csr_vector<<<grid_vector, BLOCK_SIZE>>>(d_row_ptr, d_col_idx, d_val, d_x, d_y, N);
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    float ms2;
    cudaEventElapsedTime(&ms2, start, stop);

    printf("Benchmark (%d iters): scalar=%.3f us, vector=%.3f us\n",
           niter, ms1 / niter * 1000, ms2 / niter * 1000);

    cudaFree(d_row_ptr); cudaFree(d_col_idx); cudaFree(d_val);
    cudaFree(d_x); cudaFree(d_y);
    free(h_row_ptr); free(h_col_idx); free(h_val);
    free(h_x); free(h_y); free(h_ref);
    cudaEventDestroy(start); cudaEventDestroy(stop);

    return 0;
}
