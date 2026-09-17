/*
 * CUDA GEMV with Checkerboard Pattern: y = A * x + b
 *
 * Translates the CSL kernel from:
 *   sdk-examples/benchmarks/gemv-checkerboard-pattern/pe.csl
 *
 * CSL approach:
 *   - 2D PE grid with checkerboard pattern (even/odd columns)
 *   - x is broadcast southward from first row
 *   - Each PE computes local A_tile * x_tile (outer-product style)
 *   - Chain reduction via checkerboard fabric routing accumulates partial sums
 *   - b is added on the left column PEs
 *
 * CUDA approach:
 *   - Standard GEMV with shared memory
 *   - The "checkerboard" aspect maps to even/odd thread block scheduling,
 *     but on GPU we use a straightforward parallel reduction per row
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cuda_runtime.h>

#define BLOCK_SIZE 256

__global__ void gemv_checkerboard_kernel(
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

    printf("GEMV Checkerboard: y = A*x + b, M=%d, N=%d\n", M, N);

    size_t size_A = M * N * sizeof(float);
    size_t size_x = N * sizeof(float);
    size_t size_y = M * sizeof(float);

    float *h_A = (float*)malloc(size_A);
    float *h_x = (float*)malloc(size_x);
    float *h_b = (float*)malloc(size_y);
    float *h_y = (float*)malloc(size_y);
    float *h_ref = (float*)malloc(size_y);

    srand(42);
    for (int i = 0; i < M * N; i++) h_A[i] = (float)rand() / RAND_MAX - 0.5f;
    for (int i = 0; i < N; i++) h_x[i] = (float)rand() / RAND_MAX - 0.5f;
    for (int i = 0; i < M; i++) h_b[i] = (float)rand() / RAND_MAX - 0.5f;

    gemv_reference(h_A, h_x, h_b, h_ref, M, N);

    float *d_A, *d_x, *d_b, *d_y;
    cudaMalloc(&d_A, size_A);
    cudaMalloc(&d_x, size_x);
    cudaMalloc(&d_b, size_y);
    cudaMalloc(&d_y, size_y);

    cudaMemcpy(d_A, h_A, size_A, cudaMemcpyHostToDevice);
    cudaMemcpy(d_x, h_x, size_x, cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b, size_y, cudaMemcpyHostToDevice);

    gemv_checkerboard_kernel<<<M, BLOCK_SIZE>>>(d_A, d_x, d_b, d_y, M, N);
    cudaDeviceSynchronize();

    // Benchmark
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    int niter = 100;
    cudaEventRecord(start);
    for (int i = 0; i < niter; i++)
        gemv_checkerboard_kernel<<<M, BLOCK_SIZE>>>(d_A, d_x, d_b, d_y, M, N);
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    float ms;
    cudaEventElapsedTime(&ms, start, stop);
    printf("Kernel time: %.4f ms (avg over %d iterations)\n", ms / niter, niter);

    cudaMemcpy(h_y, d_y, size_y, cudaMemcpyDeviceToHost);

    float max_err = 0.0f, max_val = 0.0f;
    for (int i = 0; i < M; i++) {
        float err = fabsf(h_y[i] - h_ref[i]);
        if (err > max_err) max_err = err;
        if (fabsf(h_ref[i]) > max_val) max_val = fabsf(h_ref[i]);
    }
    float rel_err = max_err / max_val;
    printf("Max error: %e, relative: %e\n", max_err, rel_err);
    printf("Result: %s\n", (rel_err < 1e-4) ? "PASS" : "FAIL");

    cudaFree(d_A); cudaFree(d_x); cudaFree(d_b); cudaFree(d_y);
    free(h_A); free(h_x); free(h_b); free(h_y); free(h_ref);
    cudaEventDestroy(start); cudaEventDestroy(stop);
    return (rel_err < 1e-4) ? 0 : 1;
}
