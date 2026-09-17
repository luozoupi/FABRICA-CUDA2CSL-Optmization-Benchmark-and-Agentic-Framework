/*
 * CUDA Single-Tile MATVEC: y = A * x
 *
 * Translates the CSL single-tile matvec kernel from:
 *   sdk-examples/benchmarks/single-tile-matvec/src/pe_matvec.csl
 *
 * CSL approach:
 *   - Single PE computes full GEMV
 *   - Uses @map(gemv_static_step_A, x_dsd) to iterate over x elements
 *   - For each x[j], @fmacs accumulates y += A[:,j] * x[j]
 *   - This is a column-wise outer-product style accumulation
 *
 * CUDA approach:
 *   Two variants provided:
 *   1. Column-wise: mirrors the CSL @map pattern (each thread = one row)
 *   2. Shared-memory: caches x in shmem for bandwidth optimization
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cuda_runtime.h>

#define BLOCK_SIZE 256

// Mirrors CSL @map + @fmacs pattern: each thread handles one row
__global__ void matvec_colwise(
    const float* __restrict__ A,
    const float* __restrict__ x,
    float* __restrict__ y,
    int nb)
{
    int row = blockIdx.x * blockDim.x + threadIdx.x;
    if (row >= nb) return;

    float acc = 0.0f;
    for (int j = 0; j < nb; j++)
        acc += A[row * nb + j] * x[j];
    y[row] = acc;
}

// Shared-memory optimized variant
__global__ void matvec_shmem(
    const float* __restrict__ A,
    const float* __restrict__ x,
    float* __restrict__ y,
    int nb)
{
    extern __shared__ float sx[];
    int row = blockIdx.x;
    if (row >= nb) return;

    // Cooperatively load x into shared memory
    for (int i = threadIdx.x; i < nb; i += blockDim.x)
        sx[i] = x[i];
    __syncthreads();

    __shared__ float sdata[BLOCK_SIZE];
    float sum = 0.0f;
    for (int j = threadIdx.x; j < nb; j += blockDim.x)
        sum += A[row * nb + j] * sx[j];

    sdata[threadIdx.x] = sum;
    __syncthreads();

    for (int s = blockDim.x / 2; s > 0; s >>= 1) {
        if (threadIdx.x < s)
            sdata[threadIdx.x] += sdata[threadIdx.x + s];
        __syncthreads();
    }

    if (threadIdx.x == 0)
        y[row] = sdata[0];
}

int main(int argc, char** argv) {
    int nb = 256;
    if (argc > 1) nb = atoi(argv[1]);

    printf("Single-Tile MATVEC: y = A*x, nb=%d\n", nb);

    size_t size_A = nb * nb * sizeof(float);
    size_t size_v = nb * sizeof(float);

    float *h_A = (float*)malloc(size_A);
    float *h_x = (float*)malloc(size_v);
    float *h_y1 = (float*)malloc(size_v);
    float *h_y2 = (float*)malloc(size_v);
    float *h_ref = (float*)malloc(size_v);

    srand(42);
    for (int i = 0; i < nb * nb; i++) h_A[i] = (float)rand() / RAND_MAX - 0.5f;
    for (int i = 0; i < nb; i++) h_x[i] = (float)rand() / RAND_MAX - 0.5f;

    // Reference
    for (int i = 0; i < nb; i++) {
        float s = 0.0f;
        for (int j = 0; j < nb; j++) s += h_A[i * nb + j] * h_x[j];
        h_ref[i] = s;
    }

    float *d_A, *d_x, *d_y;
    cudaMalloc(&d_A, size_A);
    cudaMalloc(&d_x, size_v);
    cudaMalloc(&d_y, size_v);

    cudaMemcpy(d_A, h_A, size_A, cudaMemcpyHostToDevice);
    cudaMemcpy(d_x, h_x, size_v, cudaMemcpyHostToDevice);

    // Test column-wise variant
    int grid1 = (nb + BLOCK_SIZE - 1) / BLOCK_SIZE;
    matvec_colwise<<<grid1, BLOCK_SIZE>>>(d_A, d_x, d_y, nb);
    cudaMemcpy(h_y1, d_y, size_v, cudaMemcpyDeviceToHost);

    // Test shmem variant
    cudaMemset(d_y, 0, size_v);
    matvec_shmem<<<nb, BLOCK_SIZE, nb * sizeof(float)>>>(d_A, d_x, d_y, nb);
    cudaMemcpy(h_y2, d_y, size_v, cudaMemcpyDeviceToHost);

    // Verify both
    float max_err1 = 0, max_err2 = 0, max_val = 0;
    for (int i = 0; i < nb; i++) {
        float e1 = fabsf(h_y1[i] - h_ref[i]);
        float e2 = fabsf(h_y2[i] - h_ref[i]);
        if (e1 > max_err1) max_err1 = e1;
        if (e2 > max_err2) max_err2 = e2;
        if (fabsf(h_ref[i]) > max_val) max_val = fabsf(h_ref[i]);
    }
    printf("Column-wise: max_err=%e, rel=%e -> %s\n",
           max_err1, max_err1/max_val, (max_err1/max_val < 1e-5) ? "PASS" : "FAIL");
    printf("Shared-mem:  max_err=%e, rel=%e -> %s\n",
           max_err2, max_err2/max_val, (max_err2/max_val < 1e-5) ? "PASS" : "FAIL");

    // Benchmark
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    int niter = 200;

    // Warmup + bench colwise
    for (int i = 0; i < 10; i++)
        matvec_colwise<<<grid1, BLOCK_SIZE>>>(d_A, d_x, d_y, nb);
    cudaEventRecord(start);
    for (int i = 0; i < niter; i++)
        matvec_colwise<<<grid1, BLOCK_SIZE>>>(d_A, d_x, d_y, nb);
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    float ms1;
    cudaEventElapsedTime(&ms1, start, stop);

    // Warmup + bench shmem
    for (int i = 0; i < 10; i++)
        matvec_shmem<<<nb, BLOCK_SIZE, nb * sizeof(float)>>>(d_A, d_x, d_y, nb);
    cudaEventRecord(start);
    for (int i = 0; i < niter; i++)
        matvec_shmem<<<nb, BLOCK_SIZE, nb * sizeof(float)>>>(d_A, d_x, d_y, nb);
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    float ms2;
    cudaEventElapsedTime(&ms2, start, stop);

    printf("Benchmark: colwise=%.3f us, shmem=%.3f us (avg over %d iters)\n",
           ms1 / niter * 1000, ms2 / niter * 1000, niter);

    cudaFree(d_A); cudaFree(d_x); cudaFree(d_y);
    free(h_A); free(h_x); free(h_y1); free(h_y2); free(h_ref);
    cudaEventDestroy(start); cudaEventDestroy(stop);

    return 0;
}
