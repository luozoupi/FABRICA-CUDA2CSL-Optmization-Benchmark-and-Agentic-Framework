/*
 * CUDA Hypersparse SpMV (Sparse Matrix-Vector Multiplication)
 *
 * Translates the CSL kernel from:
 *   sdk-examples/benchmarks/spmv-hypersparse/src/hypersparse_spmv/pe.csl
 *
 * CSL approach:
 *   - Matrix distributed across 2D PE grid in hypersparse format
 *   - Each PE stores only nonzero columns with (col_idx, col_loc, col_len, vals, row_offsets)
 *   - x vector broadcast via north/south trains across PE rows
 *   - Local SpMV: for each nnz column, multiply vals by x[col_idx]
 *   - Results reduced east/west via allreduce to produce final y
 *
 * CUDA approach:
 *   - CSR format SpMV with one warp per row (for hypersparse data)
 *   - Also supports ELL format for regular sparsity patterns
 *   - Warp-level reduction for partial sums
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cuda_runtime.h>

#define WARP_SIZE 32
#define BLOCK_SIZE 256

// CSR SpMV: one warp per row (good for hypersparse)
__global__ void spmv_csr_warp(const int *row_ptr, const int *col_idx,
                               const float *vals, const float *x, float *y, int nrows) {
    int warp_id = (blockIdx.x * blockDim.x + threadIdx.x) / WARP_SIZE;
    int lane = threadIdx.x % WARP_SIZE;

    if (warp_id >= nrows) return;

    int row_start = row_ptr[warp_id];
    int row_end = row_ptr[warp_id + 1];

    float sum = 0.0f;
    for (int j = row_start + lane; j < row_end; j += WARP_SIZE) {
        sum += vals[j] * x[col_idx[j]];
    }

    // Warp-level reduction
    for (int offset = WARP_SIZE / 2; offset > 0; offset >>= 1)
        sum += __shfl_down_sync(0xFFFFFFFF, sum, offset);

    if (lane == 0) y[warp_id] = sum;
}

// Generate a random hypersparse matrix (very few nnz per row)
void gen_hypersparse(int nrows, int ncols, float density,
                     int **row_ptr, int **col_idx, float **vals, int *nnz) {
    int max_nnz = (int)(nrows * ncols * density) + nrows;
    *row_ptr = (int*)malloc((nrows + 1) * sizeof(int));
    *col_idx = (int*)malloc(max_nnz * sizeof(int));
    *vals = (float*)malloc(max_nnz * sizeof(float));

    int count = 0;
    (*row_ptr)[0] = 0;
    for (int i = 0; i < nrows; i++) {
        for (int j = 0; j < ncols; j++) {
            if ((float)rand() / RAND_MAX < density) {
                (*col_idx)[count] = j;
                (*vals)[count] = (float)rand() / RAND_MAX - 0.5f;
                count++;
            }
        }
        (*row_ptr)[i + 1] = count;
    }
    *nnz = count;
}

int main(int argc, char **argv) {
    int N = 4096;
    float density = 0.001f;  // Hypersparse: 0.1% nonzeros
    if (argc > 1) N = atoi(argv[1]);
    if (argc > 2) density = atof(argv[2]);

    printf("Hypersparse SpMV: N=%d, density=%.4f%%\n", N, density * 100);

    int *h_row_ptr, *h_col_idx;
    float *h_vals;
    int nnz;
    srand(42);
    gen_hypersparse(N, N, density, &h_row_ptr, &h_col_idx, &h_vals, &nnz);
    printf("NNZ: %d (avg %.1f per row)\n", nnz, (float)nnz / N);

    float *h_x = (float*)malloc(N * sizeof(float));
    float *h_y = (float*)malloc(N * sizeof(float));
    for (int i = 0; i < N; i++) h_x[i] = (float)rand() / RAND_MAX - 0.5f;

    // Device
    int *d_row_ptr, *d_col_idx;
    float *d_vals, *d_x, *d_y;
    cudaMalloc(&d_row_ptr, (N + 1) * sizeof(int));
    cudaMalloc(&d_col_idx, nnz * sizeof(int));
    cudaMalloc(&d_vals, nnz * sizeof(float));
    cudaMalloc(&d_x, N * sizeof(float));
    cudaMalloc(&d_y, N * sizeof(float));
    cudaMemcpy(d_row_ptr, h_row_ptr, (N + 1) * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_col_idx, h_col_idx, nnz * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_vals, h_vals, nnz * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_x, h_x, N * sizeof(float), cudaMemcpyHostToDevice);

    int warps_needed = N;
    int threads = warps_needed * WARP_SIZE;
    dim3 grid((threads + BLOCK_SIZE - 1) / BLOCK_SIZE);

    // Warmup
    spmv_csr_warp<<<grid, BLOCK_SIZE>>>(d_row_ptr, d_col_idx, d_vals, d_x, d_y, N);
    cudaDeviceSynchronize();

    cudaEvent_t start, stop;
    cudaEventCreate(&start); cudaEventCreate(&stop);
    int iters = 100;
    cudaEventRecord(start);
    for (int i = 0; i < iters; i++)
        spmv_csr_warp<<<grid, BLOCK_SIZE>>>(d_row_ptr, d_col_idx, d_vals, d_x, d_y, N);
    cudaEventRecord(stop); cudaEventSynchronize(stop);
    float ms; cudaEventElapsedTime(&ms, start, stop);
    printf("Kernel time: %.4f ms (avg over %d iterations)\n", ms / iters, iters);

    cudaMemcpy(h_y, d_y, N * sizeof(float), cudaMemcpyDeviceToHost);

    // CPU reference
    float max_err = 0, max_val = 0;
    for (int i = 0; i < N; i++) {
        float ref = 0;
        for (int j = h_row_ptr[i]; j < h_row_ptr[i + 1]; j++)
            ref += h_vals[j] * h_x[h_col_idx[j]];
        float e = fabsf(h_y[i] - ref);
        if (e > max_err) max_err = e;
        if (fabsf(ref) > max_val) max_val = fabsf(ref);
    }
    int pass = (max_val < 1e-10f) ? (max_err < 1e-6f) : (max_err / max_val < 1e-5f);
    printf("Max error: %e, max_val: %e\n", max_err, max_val);
    printf("Result: %s\n", pass ? "PASS" : "FAIL");

    free(h_row_ptr); free(h_col_idx); free(h_vals); free(h_x); free(h_y);
    cudaFree(d_row_ptr); cudaFree(d_col_idx); cudaFree(d_vals); cudaFree(d_x); cudaFree(d_y);
    cudaEventDestroy(start); cudaEventDestroy(stop);
    return pass ? 0 : 1;
}
