/*
 * CUDA GEMM: C = A * B (tiled, shared memory)
 *
 * Translates the CSL GEMM kernel from:
 *   sdk-examples/benchmarks/gemm-collectives_2d/pe.csl
 *
 * CSL approach (SUMMA algorithm):
 *   - P x P PE grid, P steps
 *   - Step i: PE column i broadcasts A tiles along rows,
 *             PE row i broadcasts B tiles along columns
 *   - Each PE accumulates C_tile += A_panel * B_panel via @fmacs
 *
 * CUDA approach (tiled GEMM):
 *   - Mirrors SUMMA: iterate over K in tiles
 *   - Each tile step: load A and B sub-tiles into shared memory
 *     (analogous to broadcast in CSL)
 *   - Compute partial product from shared memory tiles
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cuda_runtime.h>

#define TILE_SIZE 32

__global__ void gemm_kernel(
    const float* __restrict__ A,
    const float* __restrict__ B,
    float* __restrict__ C,
    int M, int K, int N)
{
    __shared__ float As[TILE_SIZE][TILE_SIZE];
    __shared__ float Bs[TILE_SIZE][TILE_SIZE];

    int row = blockIdx.y * TILE_SIZE + threadIdx.y;
    int col = blockIdx.x * TILE_SIZE + threadIdx.x;

    float sum = 0.0f;

    for (int t = 0; t < (K + TILE_SIZE - 1) / TILE_SIZE; t++) {
        int a_col = t * TILE_SIZE + threadIdx.x;
        As[threadIdx.y][threadIdx.x] = (row < M && a_col < K)
            ? A[row * K + a_col] : 0.0f;

        int b_row = t * TILE_SIZE + threadIdx.y;
        Bs[threadIdx.y][threadIdx.x] = (b_row < K && col < N)
            ? B[b_row * N + col] : 0.0f;

        __syncthreads();

        for (int k = 0; k < TILE_SIZE; k++)
            sum += As[threadIdx.y][k] * Bs[k][threadIdx.x];

        __syncthreads();
    }

    if (row < M && col < N)
        C[row * N + col] = sum;
}

int main(int argc, char** argv) {
    int M = 512, K = 512, N = 512;
    if (argc > 1) M = atoi(argv[1]);
    if (argc > 2) K = atoi(argv[2]);
    if (argc > 3) N = atoi(argv[3]);

    printf("GEMM: C = A*B, M=%d, K=%d, N=%d\n", M, K, N);

    size_t size_A = M * K * sizeof(float);
    size_t size_B = K * N * sizeof(float);
    size_t size_C = M * N * sizeof(float);

    float *h_A = (float*)malloc(size_A);
    float *h_B = (float*)malloc(size_B);
    float *h_C = (float*)malloc(size_C);
    float *h_ref = (float*)malloc(size_C);

    srand(42);
    for (int i = 0; i < M * K; i++) h_A[i] = (float)rand() / RAND_MAX - 0.5f;
    for (int i = 0; i < K * N; i++) h_B[i] = (float)rand() / RAND_MAX - 0.5f;

    // Reference
    for (int i = 0; i < M; i++)
        for (int j = 0; j < N; j++) {
            float s = 0.0f;
            for (int k = 0; k < K; k++)
                s += h_A[i * K + k] * h_B[k * N + j];
            h_ref[i * N + j] = s;
        }

    float *d_A, *d_B, *d_C;
    cudaMalloc(&d_A, size_A);
    cudaMalloc(&d_B, size_B);
    cudaMalloc(&d_C, size_C);

    cudaMemcpy(d_A, h_A, size_A, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, size_B, cudaMemcpyHostToDevice);

    dim3 block(TILE_SIZE, TILE_SIZE);
    dim3 grid((N + TILE_SIZE - 1) / TILE_SIZE, (M + TILE_SIZE - 1) / TILE_SIZE);

    // Warmup
    gemm_kernel<<<grid, block>>>(d_A, d_B, d_C, M, K, N);
    cudaDeviceSynchronize();

    // Benchmark
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    int niter = 50;
    cudaEventRecord(start);
    for (int i = 0; i < niter; i++)
        gemm_kernel<<<grid, block>>>(d_A, d_B, d_C, M, K, N);
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float ms;
    cudaEventElapsedTime(&ms, start, stop);
    printf("Kernel time: %.4f ms (avg over %d iterations)\n", ms / niter, niter);
    double gflops = 2.0 * M * K * N / (ms / niter * 1e6);
    printf("Performance: %.2f GFLOPS\n", gflops);

    // Verify
    cudaMemcpy(h_C, d_C, size_C, cudaMemcpyDeviceToHost);

    float max_err = 0.0f;
    for (int i = 0; i < M * N; i++) {
        float err = fabsf(h_C[i] - h_ref[i]);
        if (err > max_err) max_err = err;
    }
    float max_val = 0.0f;
    for (int i = 0; i < M * N; i++)
        if (fabsf(h_ref[i]) > max_val) max_val = fabsf(h_ref[i]);
    float rel_err = max_err / max_val;
    printf("Max absolute error: %e, relative: %e\n", max_err, rel_err);
    printf("Result: %s\n", (rel_err < 1e-4) ? "PASS" : "FAIL");

    cudaFree(d_A); cudaFree(d_B); cudaFree(d_C);
    free(h_A); free(h_B); free(h_C); free(h_ref);
    cudaEventDestroy(start); cudaEventDestroy(stop);

    return (rel_err < 1e-4) ? 0 : 1;
}
