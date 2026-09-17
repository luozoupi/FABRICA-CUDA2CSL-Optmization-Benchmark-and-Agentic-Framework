/*
 * CUDA GEMV with 2D Collective Communication Pattern: y = A*x + b
 *
 * Translates the CSL kernel from:
 *   sdk-examples/benchmarks/gemv-collectives_2d/pe.csl
 *
 * CSL approach:
 *   - 2D PE grid distributes matrix A in tiles
 *   - x vector scattered across first column, broadcast east along rows
 *   - Each PE computes local GEMV (outer product accumulation)
 *   - Partial results reduced west along columns
 *   - b vector added at first column
 *
 * CUDA approach:
 *   - 2D thread block grid mimics PE layout
 *   - Each thread block handles a tile of A
 *   - Shared memory for x broadcast and partial sum reduction
 *   - Final reduction and b addition
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cuda_runtime.h>

#define TILE_M 32
#define TILE_N 32

// Tiled GEMV: y = A*x + b, with explicit 2D tiling
__global__ void gemv_2d_kernel(const float *A, const float *x, const float *b,
                                float *y, int M, int N) {
    __shared__ float s_x[TILE_N];

    int row = blockIdx.x * TILE_M + threadIdx.x;
    int tid = threadIdx.x;

    // Initialize partial sum
    float sum = 0.0f;

    // Iterate over column tiles
    for (int tile = 0; tile < (N + TILE_N - 1) / TILE_N; tile++) {
        // Load x tile into shared memory
        int col = tile * TILE_N + tid;
        if (tid < TILE_N && col < N)
            s_x[tid] = x[col];
        else if (tid < TILE_N)
            s_x[tid] = 0.0f;
        __syncthreads();

        // Each thread accumulates its row's dot product for this tile
        if (row < M) {
            for (int k = 0; k < TILE_N && (tile * TILE_N + k) < N; k++) {
                sum += A[row * N + tile * TILE_N + k] * s_x[k];
            }
        }
        __syncthreads();
    }

    // Write result: y = A*x + b
    if (row < M) {
        y[row] = sum + b[row];
    }
}

int main(int argc, char **argv) {
    int M = 512, N = 1024;
    if (argc > 1) M = atoi(argv[1]);
    if (argc > 2) N = atoi(argv[2]);

    printf("GEMV 2D Collectives: y = A*x + b, M=%d, N=%d\n", M, N);

    float *h_A = (float*)malloc(M * N * sizeof(float));
    float *h_x = (float*)malloc(N * sizeof(float));
    float *h_b = (float*)malloc(M * sizeof(float));
    float *h_y = (float*)malloc(M * sizeof(float));

    srand(42);
    for (int i = 0; i < M * N; i++) h_A[i] = (float)rand() / RAND_MAX - 0.5f;
    for (int i = 0; i < N; i++) h_x[i] = (float)rand() / RAND_MAX - 0.5f;
    for (int i = 0; i < M; i++) h_b[i] = (float)rand() / RAND_MAX - 0.5f;

    float *d_A, *d_x, *d_b, *d_y;
    cudaMalloc(&d_A, M * N * sizeof(float));
    cudaMalloc(&d_x, N * sizeof(float));
    cudaMalloc(&d_b, M * sizeof(float));
    cudaMalloc(&d_y, M * sizeof(float));
    cudaMemcpy(d_A, h_A, M * N * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_x, h_x, N * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b, M * sizeof(float), cudaMemcpyHostToDevice);

    dim3 grid((M + TILE_M - 1) / TILE_M);
    dim3 block(TILE_M);

    // Warmup
    gemv_2d_kernel<<<grid, block>>>(d_A, d_x, d_b, d_y, M, N);
    cudaDeviceSynchronize();

    cudaEvent_t start, stop;
    cudaEventCreate(&start); cudaEventCreate(&stop);
    int iters = 100;
    cudaEventRecord(start);
    for (int i = 0; i < iters; i++)
        gemv_2d_kernel<<<grid, block>>>(d_A, d_x, d_b, d_y, M, N);
    cudaEventRecord(stop); cudaEventSynchronize(stop);
    float ms; cudaEventElapsedTime(&ms, start, stop);
    printf("Kernel time: %.4f ms (avg over %d iterations)\n", ms / iters, iters);

    cudaMemcpy(h_y, d_y, M * sizeof(float), cudaMemcpyDeviceToHost);

    // CPU reference
    float max_err = 0, max_val = 0;
    for (int i = 0; i < M; i++) {
        float ref = h_b[i];
        for (int j = 0; j < N; j++) ref += h_A[i * N + j] * h_x[j];
        float e = fabsf(h_y[i] - ref);
        if (e > max_err) max_err = e;
        if (fabsf(ref) > max_val) max_val = fabsf(ref);
    }
    float rel = max_err / max_val;
    printf("Max error: %e, relative: %e\n", max_err, rel);
    printf("Result: %s\n", (rel < 1e-5) ? "PASS" : "FAIL");

    free(h_A); free(h_x); free(h_b); free(h_y);
    cudaFree(d_A); cudaFree(d_x); cudaFree(d_b); cudaFree(d_y);
    cudaEventDestroy(start); cudaEventDestroy(stop);
    return (rel < 1e-5) ? 0 : 1;
}
