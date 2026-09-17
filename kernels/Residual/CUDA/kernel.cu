/*
 * CUDA Residual: compute |b - A*x|_inf
 *
 * Translates the CSL kernel from:
 *   sdk-examples/benchmarks/residual/residual.csl
 *
 * CSL approach:
 *   - 2D PE grid distributes A, x, b
 *   - Each PE computes local Ax via outer-product GEMV
 *   - AXPY: r = b - Ax
 *   - Infinity norm via chain reduction across PEs
 *
 * CUDA approach:
 *   - GEMV kernel computes r = b - A*x
 *   - Parallel reduction computes |r|_inf
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cuda_runtime.h>

#define BLOCK_SIZE 256

// Fused kernel: compute r = b - A*x and partial inf-norm
__global__ void residual_kernel(
    const float* __restrict__ A,
    const float* __restrict__ x,
    const float* __restrict__ b,
    float* __restrict__ r,
    float* __restrict__ partial_nrm,
    int M, int N)
{
    int row = blockIdx.x;
    if (row >= M) return;

    __shared__ float sdata[BLOCK_SIZE];

    float sum = 0.0f;
    for (int j = threadIdx.x; j < N; j += blockDim.x)
        sum += A[row * N + j] * x[j];

    sdata[threadIdx.x] = sum;
    __syncthreads();

    for (int s = blockDim.x / 2; s > 0; s >>= 1) {
        if (threadIdx.x < s)
            sdata[threadIdx.x] += sdata[threadIdx.x + s];
        __syncthreads();
    }

    if (threadIdx.x == 0) {
        float residual = b[row] - sdata[0];
        r[row] = residual;
        partial_nrm[row] = fabsf(residual);
    }
}

// Reduction to find max (infinity norm)
__global__ void max_reduce_kernel(
    const float* __restrict__ input,
    float* __restrict__ output,
    int N)
{
    __shared__ float sdata[BLOCK_SIZE];

    float local_max = 0.0f;
    for (int i = threadIdx.x; i < N; i += blockDim.x) {
        float val = input[i];
        if (val > local_max) local_max = val;
    }

    sdata[threadIdx.x] = local_max;
    __syncthreads();

    for (int s = blockDim.x / 2; s > 0; s >>= 1) {
        if (threadIdx.x < s)
            if (sdata[threadIdx.x + s] > sdata[threadIdx.x])
                sdata[threadIdx.x] = sdata[threadIdx.x + s];
        __syncthreads();
    }

    if (threadIdx.x == 0)
        output[0] = sdata[0];
}

int main(int argc, char** argv) {
    int M = 512, N = 512;
    if (argc > 1) M = atoi(argv[1]);
    if (argc > 2) N = atoi(argv[2]);

    printf("Residual: |b - A*x|_inf, M=%d, N=%d\n", M, N);

    float *h_A = (float*)malloc(M * N * sizeof(float));
    float *h_x = (float*)malloc(N * sizeof(float));
    float *h_b = (float*)malloc(M * sizeof(float));

    srand(42);
    for (int i = 0; i < M * N; i++) h_A[i] = (float)rand() / RAND_MAX - 0.5f;
    for (int i = 0; i < N; i++) h_x[i] = (float)rand() / RAND_MAX - 0.5f;

    // b = A*x + small_noise (so residual is small but nonzero)
    for (int i = 0; i < M; i++) {
        float sum = 0.0f;
        for (int j = 0; j < N; j++) sum += h_A[i * N + j] * h_x[j];
        h_b[i] = sum + 0.001f * ((float)rand() / RAND_MAX - 0.5f);
    }

    // CPU reference
    float ref_nrm = 0.0f;
    for (int i = 0; i < M; i++) {
        float sum = 0.0f;
        for (int j = 0; j < N; j++) sum += h_A[i * N + j] * h_x[j];
        float r = fabsf(h_b[i] - sum);
        if (r > ref_nrm) ref_nrm = r;
    }

    float *d_A, *d_x, *d_b, *d_r, *d_nrm, *d_result;
    cudaMalloc(&d_A, M * N * sizeof(float));
    cudaMalloc(&d_x, N * sizeof(float));
    cudaMalloc(&d_b, M * sizeof(float));
    cudaMalloc(&d_r, M * sizeof(float));
    cudaMalloc(&d_nrm, M * sizeof(float));
    cudaMalloc(&d_result, sizeof(float));

    cudaMemcpy(d_A, h_A, M * N * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_x, h_x, N * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b, M * sizeof(float), cudaMemcpyHostToDevice);

    residual_kernel<<<M, BLOCK_SIZE>>>(d_A, d_x, d_b, d_r, d_nrm, M, N);
    max_reduce_kernel<<<1, BLOCK_SIZE>>>(d_nrm, d_result, M);
    cudaDeviceSynchronize();

    float gpu_nrm;
    cudaMemcpy(&gpu_nrm, d_result, sizeof(float), cudaMemcpyDeviceToHost);

    float err = fabsf(gpu_nrm - ref_nrm);
    // Use absolute tolerance since residual values can be very small
    int pass = (err < 1e-5f) || (err / ref_nrm < 1e-3f);
    printf("CPU |b-Ax|_inf = %e, GPU = %e, diff = %e\n", ref_nrm, gpu_nrm, err);
    printf("Result: %s\n", pass ? "PASS" : "FAIL");

    // Benchmark
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    int niter = 100;
    cudaEventRecord(start);
    for (int i = 0; i < niter; i++) {
        residual_kernel<<<M, BLOCK_SIZE>>>(d_A, d_x, d_b, d_r, d_nrm, M, N);
        max_reduce_kernel<<<1, BLOCK_SIZE>>>(d_nrm, d_result, M);
    }
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    float ms;
    cudaEventElapsedTime(&ms, start, stop);
    printf("Kernel time: %.4f ms (avg over %d iterations)\n", ms / niter, niter);

    cudaFree(d_A); cudaFree(d_x); cudaFree(d_b); cudaFree(d_r);
    cudaFree(d_nrm); cudaFree(d_result);
    free(h_A); free(h_x); free(h_b);
    cudaEventDestroy(start); cudaEventDestroy(stop);
    return pass ? 0 : 1;
}
