/*
 * CUDA GEMV: y = A * x + b
 *
 * Translates the CSL GEMV kernel from:
 *   sdk-examples/benchmarks/gemv-collectives_2d/pe.csl
 *
 * CSL approach:
 *   - Distributes A across a 2D PE grid (kernel_rows x kernel_cols)
 *   - Scatters x across top row, b down left column
 *   - Each PE computes local_prod = A_tile * x_tile via @fmacs
 *   - Row reduction (reduce_fadds) sums partial products
 *   - Gathers final y into bottom-right PE
 *
 * CUDA approach:
 *   - Each block handles one row of A
 *   - Threads cooperatively compute dot product via shared memory reduction
 *   - Bias b is added at the end
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cuda_runtime.h>

#define BLOCK_SIZE 256

__global__ void gemv_kernel(
    const float* __restrict__ A,
    const float* __restrict__ x,
    const float* __restrict__ b,
    float* __restrict__ y,
    int M, int N)
{
    int row = blockIdx.x;
    if (row >= M) return;

    __shared__ float sdata[BLOCK_SIZE];

    float sum = 0.0f;
    for (int j = threadIdx.x; j < N; j += blockDim.x) {
        sum += A[row * N + j] * x[j];
    }

    sdata[threadIdx.x] = sum;
    __syncthreads();

    // Parallel reduction
    for (int s = blockDim.x / 2; s > 0; s >>= 1) {
        if (threadIdx.x < s)
            sdata[threadIdx.x] += sdata[threadIdx.x + s];
        __syncthreads();
    }

    if (threadIdx.x == 0) {
        y[row] = sdata[0] + b[row];
    }
}

void gemv_reference(const float* A, const float* x, const float* b,
                    float* y, int M, int N) {
    for (int i = 0; i < M; i++) {
        float sum = 0.0f;
        for (int j = 0; j < N; j++)
            sum += A[i * N + j] * x[j];
        y[i] = sum + b[i];
    }
}

int main(int argc, char** argv) {
    int M = 512, N = 1024;
    if (argc > 1) M = atoi(argv[1]);
    if (argc > 2) N = atoi(argv[2]);

    printf("GEMV: y = A*x + b, M=%d, N=%d\n", M, N);

    size_t size_A = M * N * sizeof(float);
    size_t size_x = N * sizeof(float);
    size_t size_y = M * sizeof(float);

    // Allocate host
    float *h_A = (float*)malloc(size_A);
    float *h_x = (float*)malloc(size_x);
    float *h_b = (float*)malloc(size_y);
    float *h_y = (float*)malloc(size_y);
    float *h_ref = (float*)malloc(size_y);

    // Initialize
    srand(42);
    for (int i = 0; i < M * N; i++) h_A[i] = (float)rand() / RAND_MAX - 0.5f;
    for (int i = 0; i < N; i++) h_x[i] = (float)rand() / RAND_MAX - 0.5f;
    for (int i = 0; i < M; i++) h_b[i] = (float)rand() / RAND_MAX - 0.5f;

    // Reference
    gemv_reference(h_A, h_x, h_b, h_ref, M, N);

    // Device
    float *d_A, *d_x, *d_b, *d_y;
    cudaMalloc(&d_A, size_A);
    cudaMalloc(&d_x, size_x);
    cudaMalloc(&d_b, size_y);
    cudaMalloc(&d_y, size_y);

    cudaMemcpy(d_A, h_A, size_A, cudaMemcpyHostToDevice);
    cudaMemcpy(d_x, h_x, size_x, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b, size_y, cudaMemcpyHostToDevice);

    // Warmup
    gemv_kernel<<<M, BLOCK_SIZE>>>(d_A, d_x, d_b, d_y, M, N);
    cudaDeviceSynchronize();

    // Benchmark
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    int niter = 100;
    cudaEventRecord(start);
    for (int i = 0; i < niter; i++)
        gemv_kernel<<<M, BLOCK_SIZE>>>(d_A, d_x, d_b, d_y, M, N);
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float ms;
    cudaEventElapsedTime(&ms, start, stop);
    printf("Kernel time: %.4f ms (avg over %d iterations)\n", ms / niter, niter);

    // Verify
    cudaMemcpy(h_y, d_y, size_y, cudaMemcpyDeviceToHost);

    float max_err = 0.0f;
    for (int i = 0; i < M; i++) {
        float err = fabsf(h_y[i] - h_ref[i]);
        if (err > max_err) max_err = err;
    }
    float max_val = 0.0f;
    for (int i = 0; i < M; i++)
        if (fabsf(h_ref[i]) > max_val) max_val = fabsf(h_ref[i]);
    float rel_err = max_err / max_val;
    printf("Max absolute error: %e, relative: %e\n", max_err, rel_err);
    printf("Result: %s\n", (rel_err < 1e-4) ? "PASS" : "FAIL");

    // Cleanup
    cudaFree(d_A); cudaFree(d_x); cudaFree(d_b); cudaFree(d_y);
    free(h_A); free(h_x); free(h_b); free(h_y); free(h_ref);
    cudaEventDestroy(start); cudaEventDestroy(stop);

    return (rel_err < 1e-4) ? 0 : 1;
}
