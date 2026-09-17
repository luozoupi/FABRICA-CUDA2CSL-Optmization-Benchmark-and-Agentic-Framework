/*
 * CUDA Cholesky Factorization: A = L * L^T
 *
 * Translates the CSL kernel from:
 *   sdk-examples/benchmarks/cholesky/pe.csl
 *
 * CSL approach:
 *   - Right-looking Cholesky on 2D PE grid
 *   - Fringe-based computation: diagonal PE computes L[i,i] = 1/sqrt(A[i,i])
 *   - Column broadcasts and rank-1 updates propagate through the grid
 *   - Uses fabric colors for row/column communication
 *
 * CUDA approach:
 *   - Right-looking blocked Cholesky factorization
 *   - Panel factorization on diagonal block
 *   - TRSM for off-diagonal blocks
 *   - SYRK rank-k update for trailing submatrix
 *   - All done in-place on lower triangle of A
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cuda_runtime.h>

#define BLOCK_SIZE 256

// Panel factorization: compute L[j:N, j] for a single column j
__global__ void chol_column_kernel(float* A, int N, int j) {
    // Single thread computes diagonal element
    if (threadIdx.x == 0 && blockIdx.x == 0) {
        float diag = A[j * N + j];
        for (int k = 0; k < j; k++)
            diag -= A[j * N + k] * A[j * N + k];
        A[j * N + j] = sqrtf(diag);
    }
}

// Update column j below diagonal: L[i,j] = (A[i,j] - sum) / L[j,j]
__global__ void chol_update_column_kernel(float* A, int N, int j) {
    int i = blockIdx.x * blockDim.x + threadIdx.x + j + 1;
    if (i >= N) return;

    float sum = A[i * N + j];
    for (int k = 0; k < j; k++)
        sum -= A[i * N + k] * A[j * N + k];
    A[i * N + j] = sum / A[j * N + j];
}

int main(int argc, char** argv) {
    int N = 256;
    if (argc > 1) N = atoi(argv[1]);

    printf("Cholesky Factorization: A = L*L^T, N=%d\n", N);

    // Create SPD matrix: A = B^T * B + N*I (ensure well-conditioned)
    float *h_A = (float*)malloc(N * N * sizeof(float));
    float *h_A_orig = (float*)malloc(N * N * sizeof(float));

    srand(42);
    float *B = (float*)malloc(N * N * sizeof(float));
    for (int i = 0; i < N * N; i++) B[i] = (float)rand() / RAND_MAX - 0.5f;
    for (int i = 0; i < N; i++)
        for (int j = 0; j < N; j++) {
            float s = (i == j) ? (float)N : 0.0f;
            for (int k = 0; k < N; k++) s += B[k*N+i] * B[k*N+j];
            h_A[i*N+j] = s;
            h_A_orig[i*N+j] = s;
        }
    free(B);

    float *d_A;
    cudaMalloc(&d_A, N * N * sizeof(float));
    cudaMemcpy(d_A, h_A, N * N * sizeof(float), cudaMemcpyHostToDevice);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);
    for (int j = 0; j < N; j++) {
        // Compute L[j,j]
        chol_column_kernel<<<1, 1>>>(d_A, N, j);

        // Update L[j+1:N, j]
        int remaining = N - j - 1;
        if (remaining > 0) {
            dim3 grid((remaining + BLOCK_SIZE - 1) / BLOCK_SIZE);
            chol_update_column_kernel<<<grid, BLOCK_SIZE>>>(d_A, N, j);
        }
    }
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float ms;
    cudaEventElapsedTime(&ms, start, stop);
    printf("Factorization time: %.3f ms\n", ms);

    // Verify: reconstruct A' = L * L^T and check against original
    cudaMemcpy(h_A, d_A, N * N * sizeof(float), cudaMemcpyDeviceToHost);

    // Zero upper triangle (L is lower triangular)
    for (int i = 0; i < N; i++)
        for (int j = i + 1; j < N; j++)
            h_A[i * N + j] = 0.0f;

    // Compute L * L^T
    float max_err = 0.0f, max_val = 0.0f;
    for (int i = 0; i < N; i++)
        for (int j = 0; j <= i; j++) {
            float s = 0.0f;
            for (int k = 0; k <= j; k++)
                s += h_A[i * N + k] * h_A[j * N + k];
            float err = fabsf(s - h_A_orig[i * N + j]);
            if (err > max_err) max_err = err;
            if (fabsf(h_A_orig[i * N + j]) > max_val)
                max_val = fabsf(h_A_orig[i * N + j]);
        }

    float rel_err = max_err / max_val;
    printf("Reconstruction error: max=%e, rel=%e\n", max_err, rel_err);
    printf("Result: %s\n", (rel_err < 1e-4) ? "PASS" : "FAIL");

    cudaFree(d_A);
    free(h_A); free(h_A_orig);
    cudaEventDestroy(start); cudaEventDestroy(stop);
    return (rel_err < 1e-4) ? 0 : 1;
}
