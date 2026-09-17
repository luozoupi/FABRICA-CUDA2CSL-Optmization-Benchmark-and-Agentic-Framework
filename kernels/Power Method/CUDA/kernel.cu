/*
 * CUDA Power Method: find dominant eigenvalue/eigenvector
 *
 * Translates the CSL kernel from:
 *   sdk-examples/benchmarks/power-method/src/kernel_power.csl
 *
 * CSL approach:
 *   - State machine: SpMV -> nrm2 -> scale -> repeat
 *   - Uses 7-point stencil SpMV on 2D PE grid
 *   - Allreduce for global norm computation
 *
 * CUDA approach:
 *   - Dense SpMV kernel (y = A*x)
 *   - Parallel norm reduction (||y||_2)
 *   - Scaling kernel (x = y / ||y||_2)
 *   - Iterate until convergence
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cuda_runtime.h>

#define BLOCK_SIZE 256

__global__ void spmv_dense_kernel(
    const float* __restrict__ A,
    const float* __restrict__ x,
    float* __restrict__ y,
    int N)
{
    int row = blockIdx.x;
    if (row >= N) return;

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
    if (threadIdx.x == 0)
        y[row] = sdata[0];
}

__global__ void dot_product_kernel(
    const float* __restrict__ x,
    float* __restrict__ result,
    int N)
{
    __shared__ float sdata[BLOCK_SIZE];
    float sum = 0.0f;
    for (int i = threadIdx.x; i < N; i += blockDim.x)
        sum += x[i] * x[i];

    sdata[threadIdx.x] = sum;
    __syncthreads();

    for (int s = blockDim.x / 2; s > 0; s >>= 1) {
        if (threadIdx.x < s)
            sdata[threadIdx.x] += sdata[threadIdx.x + s];
        __syncthreads();
    }
    if (threadIdx.x == 0)
        result[0] = sdata[0];
}

__global__ void scale_kernel(
    const float* __restrict__ y,
    float* __restrict__ x,
    float inv_norm,
    int N)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < N) x[i] = y[i] * inv_norm;
}

int main(int argc, char** argv) {
    int N = 256, max_iter = 100;
    if (argc > 1) N = atoi(argv[1]);
    if (argc > 2) max_iter = atoi(argv[2]);

    printf("Power Method: N=%d, max_iter=%d\n", N, max_iter);

    // Create a symmetric positive definite matrix
    float *h_A = (float*)malloc(N * N * sizeof(float));
    float *h_x = (float*)malloc(N * sizeof(float));

    srand(42);
    // A = B^T * B + I (guaranteed SPD)
    float *B = (float*)malloc(N * N * sizeof(float));
    for (int i = 0; i < N * N; i++) B[i] = (float)rand() / RAND_MAX - 0.5f;
    for (int i = 0; i < N; i++)
        for (int j = 0; j < N; j++) {
            float s = (i == j) ? 1.0f : 0.0f;
            for (int k = 0; k < N; k++)
                s += B[k * N + i] * B[k * N + j];
            h_A[i * N + j] = s;
        }
    free(B);

    // Initial vector
    float norm = 0.0f;
    for (int i = 0; i < N; i++) {
        h_x[i] = 1.0f;
        norm += 1.0f;
    }
    norm = sqrtf(norm);
    for (int i = 0; i < N; i++) h_x[i] /= norm;

    float *d_A, *d_x, *d_y, *d_norm_sq;
    cudaMalloc(&d_A, N * N * sizeof(float));
    cudaMalloc(&d_x, N * sizeof(float));
    cudaMalloc(&d_y, N * sizeof(float));
    cudaMalloc(&d_norm_sq, sizeof(float));

    cudaMemcpy(d_A, h_A, N * N * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_x, h_x, N * sizeof(float), cudaMemcpyHostToDevice);

    dim3 scale_grid((N + BLOCK_SIZE - 1) / BLOCK_SIZE);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);
    float eigenvalue = 0.0f;
    for (int it = 0; it < max_iter; it++) {
        // y = A * x
        spmv_dense_kernel<<<N, BLOCK_SIZE>>>(d_A, d_x, d_y, N);

        // ||y||_2
        dot_product_kernel<<<1, BLOCK_SIZE>>>(d_y, d_norm_sq, N);

        float norm_sq;
        cudaMemcpy(&norm_sq, d_norm_sq, sizeof(float), cudaMemcpyDeviceToHost);
        float nrm = sqrtf(norm_sq);
        eigenvalue = nrm;

        // x = y / ||y||
        scale_kernel<<<scale_grid, BLOCK_SIZE>>>(d_y, d_x, 1.0f / nrm, N);
    }
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float ms;
    cudaEventElapsedTime(&ms, start, stop);
    printf("Total time: %.3f ms (%d iterations)\n", ms, max_iter);
    printf("Estimated dominant eigenvalue: %f\n", eigenvalue);

    // Verify: compute Rayleigh quotient x^T A x / x^T x
    cudaMemcpy(h_x, d_x, N * sizeof(float), cudaMemcpyDeviceToHost);
    float rayleigh_num = 0.0f, rayleigh_den = 0.0f;
    for (int i = 0; i < N; i++) {
        float ax = 0.0f;
        for (int j = 0; j < N; j++) ax += h_A[i * N + j] * h_x[j];
        rayleigh_num += h_x[i] * ax;
        rayleigh_den += h_x[i] * h_x[i];
    }
    float rayleigh = rayleigh_num / rayleigh_den;
    float rel_err = fabsf(rayleigh - eigenvalue) / fabsf(rayleigh);
    printf("Rayleigh quotient: %f, rel_err: %e\n", rayleigh, rel_err);
    printf("Result: %s\n", (rel_err < 1e-3) ? "PASS" : "FAIL");

    cudaFree(d_A); cudaFree(d_x); cudaFree(d_y); cudaFree(d_norm_sq);
    free(h_A); free(h_x);
    cudaEventDestroy(start); cudaEventDestroy(stop);
    return (rel_err < 1e-3) ? 0 : 1;
}
