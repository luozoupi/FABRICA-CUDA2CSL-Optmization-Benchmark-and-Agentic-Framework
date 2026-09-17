/*
 * CUDA GEMM with SUMMA-style 2D Collective Pattern: C = A * B
 *
 * Translates the CSL kernel from:
 *   sdk-examples/benchmarks/gemm-collectives_2d/pe.csl
 *
 * CSL approach:
 *   - SUMMA algorithm on 2D PE grid
 *   - Row broadcast of A panels, column broadcast of B panels
 *   - Each PE accumulates C_tile += A_panel * B_panel
 *
 * CUDA approach:
 *   - Tiled GEMM with shared memory (SUMMA-inspired)
 *   - Each thread block computes a TILE_M x TILE_N tile of C
 *   - Iterates over K dimension in TILE_K chunks
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cuda_runtime.h>

#define TILE 32

__global__ void gemm_summa(const float *A, const float *B, float *C,
                            int M, int N, int K) {
    __shared__ float sA[TILE][TILE];
    __shared__ float sB[TILE][TILE];

    int row = blockIdx.y * TILE + threadIdx.y;
    int col = blockIdx.x * TILE + threadIdx.x;
    float sum = 0.0f;

    for (int t = 0; t < (K + TILE - 1) / TILE; t++) {
        int ak = t * TILE + threadIdx.x;
        int bk = t * TILE + threadIdx.y;
        sA[threadIdx.y][threadIdx.x] = (row < M && ak < K) ? A[row * K + ak] : 0.0f;
        sB[threadIdx.y][threadIdx.x] = (bk < K && col < N) ? B[bk * N + col] : 0.0f;
        __syncthreads();

        for (int k = 0; k < TILE; k++)
            sum += sA[threadIdx.y][k] * sB[k][threadIdx.x];
        __syncthreads();
    }

    if (row < M && col < N)
        C[row * N + col] = sum;
}

int main(int argc, char **argv) {
    int M = 512, N = 512, K = 512;
    if (argc > 1) M = N = K = atoi(argv[1]);
    if (argc > 2) N = atoi(argv[2]);
    if (argc > 3) K = atoi(argv[3]);

    printf("GEMM SUMMA-2D: C[%d,%d] = A[%d,%d] * B[%d,%d]\n", M, N, M, K, K, N);

    size_t szA = M * K * sizeof(float), szB = K * N * sizeof(float), szC = M * N * sizeof(float);
    float *h_A = (float*)malloc(szA), *h_B = (float*)malloc(szB);
    float *h_C = (float*)malloc(szC);

    srand(42);
    for (int i = 0; i < M * K; i++) h_A[i] = (float)rand() / RAND_MAX - 0.5f;
    for (int i = 0; i < K * N; i++) h_B[i] = (float)rand() / RAND_MAX - 0.5f;

    float *d_A, *d_B, *d_C;
    cudaMalloc(&d_A, szA); cudaMalloc(&d_B, szB); cudaMalloc(&d_C, szC);
    cudaMemcpy(d_A, h_A, szA, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, szB, cudaMemcpyHostToDevice);

    dim3 grid((N + TILE - 1) / TILE, (M + TILE - 1) / TILE);
    dim3 block(TILE, TILE);

    // Warmup
    gemm_summa<<<grid, block>>>(d_A, d_B, d_C, M, N, K);
    cudaDeviceSynchronize();

    cudaEvent_t start, stop;
    cudaEventCreate(&start); cudaEventCreate(&stop);
    int iters = 20;
    cudaEventRecord(start);
    for (int i = 0; i < iters; i++)
        gemm_summa<<<grid, block>>>(d_A, d_B, d_C, M, N, K);
    cudaEventRecord(stop); cudaEventSynchronize(stop);
    float ms; cudaEventElapsedTime(&ms, start, stop);

    double gflops = 2.0 * M * N * K * iters / (ms * 1e6);
    printf("Kernel time: %.3f ms (avg), %.1f GFLOPS\n", ms / iters, gflops);

    cudaMemcpy(h_C, d_C, szC, cudaMemcpyDeviceToHost);

    // Verify a few elements
    float max_err = 0, max_val = 0;
    int check = (M * N > 10000) ? 10000 : M * N;
    for (int idx = 0; idx < check; idx++) {
        int i = idx / N, j = idx % N;
        float ref = 0;
        for (int k = 0; k < K; k++) ref += h_A[i * K + k] * h_B[k * N + j];
        float e = fabsf(h_C[i * N + j] - ref);
        if (e > max_err) max_err = e;
        if (fabsf(ref) > max_val) max_val = fabsf(ref);
    }
    float rel = max_err / max_val;
    printf("Max error: %e, relative: %e\n", max_err, rel);
    printf("Result: %s\n", (rel < 1e-4) ? "PASS" : "FAIL");

    free(h_A); free(h_B); free(h_C);
    cudaFree(d_A); cudaFree(d_B); cudaFree(d_C);
    cudaEventDestroy(start); cudaEventDestroy(stop);
    return (rel < 1e-4) ? 0 : 1;
}
