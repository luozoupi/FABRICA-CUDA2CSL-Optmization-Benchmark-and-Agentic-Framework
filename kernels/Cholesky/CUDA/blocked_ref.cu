/*
 * Cholesky Factorization Reference: GPU-only blocked Cholesky
 * Based on the algorithmic structure from:
 *   - Volkov & Demmel, "LU, QR and Cholesky Factorizations using Vector
 *     Capabilities of GPUs" (UCB/EECS-2008-49)
 *   - MAGMA project (UTK ICL)
 *
 * A = L * L^T, where A is symmetric positive definite.
 *
 * Entirely GPU-resident: panel factorization, TRSM, and SYRK all run on GPU.
 * No CPU-GPU transfers during factorization (unlike hybrid MAGMA approach).
 * Uses shared memory for the panel factorization step.
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <cuda_runtime.h>

#define NB 32  /* Block size */

/*
 * GPU panel factorization: unblocked Cholesky on NB x NB diagonal block.
 * Single thread block, sequential columns but parallel updates.
 */
__global__ void gpu_panel_potrf(float *A, int lda, int j0, int jb) {
    __shared__ float col[NB];

    for (int j = 0; j < jb; j++) {
        /* Compute diagonal element (single thread) */
        if (threadIdx.x == 0) {
            float s = A[(j0 + j) * lda + (j0 + j)];
            for (int k = 0; k < j; k++)
                s -= A[(j0 + j) * lda + (j0 + k)] * A[(j0 + j) * lda + (j0 + k)];
            A[(j0 + j) * lda + (j0 + j)] = sqrtf(s);
            col[j] = A[(j0 + j) * lda + (j0 + j)];
        }
        __syncthreads();

        /* Update sub-diagonal elements in parallel */
        int i = j + 1 + threadIdx.x;
        while (i < jb) {
            float s = A[(j0 + i) * lda + (j0 + j)];
            for (int k = 0; k < j; k++)
                s -= A[(j0 + i) * lda + (j0 + k)] * A[(j0 + j) * lda + (j0 + k)];
            A[(j0 + i) * lda + (j0 + j)] = s / col[j];
            i += blockDim.x;
        }
        __syncthreads();
    }
}

/*
 * GPU TRSM: For each row i (i >= j0+jb), solve for L[i, j0:j0+jb]
 * L[i,col] = (A[i,col] - sum_{k<col} L[i,k]*L[col,k]) / L[col,col]
 */
__global__ void gpu_trsm(float *A, int lda, int j0, int jb, int N) {
    int i = j0 + jb + blockIdx.x * blockDim.x + threadIdx.x;
    if (i >= N) return;

    for (int col = 0; col < jb; col++) {
        float s = A[i * lda + (j0 + col)];
        for (int k = 0; k < col; k++)
            s -= A[i * lda + (j0 + k)] * A[(j0 + col) * lda + (j0 + k)];
        A[i * lda + (j0 + col)] = s / A[(j0 + col) * lda + (j0 + col)];
    }
}

/*
 * GPU SYRK: Update trailing submatrix
 * A[i,k] -= sum_{j=0..jb-1} L[i, j0+j] * L[k, j0+j], for i >= k >= j0+jb
 */
__global__ void gpu_syrk(float *A, int lda, int j0, int jb, int N) {
    int ti = blockIdx.x * blockDim.x + threadIdx.x;
    int tk = blockIdx.y * blockDim.y + threadIdx.y;
    int remaining = N - j0 - jb;
    if (ti >= remaining || tk >= remaining) return;

    int i = j0 + jb + ti;
    int k = j0 + jb + tk;
    if (i < k) return;  /* lower triangle only */

    float s = 0.0f;
    for (int j = 0; j < jb; j++)
        s += A[i * lda + (j0 + j)] * A[k * lda + (j0 + j)];
    A[i * lda + k] -= s;
}

int main(int argc, char **argv) {
    int N = 512;
    if (argc > 1) N = atoi(argv[1]);

    printf("Blocked GPU Cholesky (Volkov/MAGMA-style): A = L*L^T, N=%d, NB=%d\n", N, NB);

    /* Generate SPD matrix: A = B^T * B + N*I */
    float *h_A = (float *)malloc(N * N * sizeof(float));
    float *h_A_orig = (float *)malloc(N * N * sizeof(float));

    srand(42);
    float *B = (float *)malloc(N * N * sizeof(float));
    for (int i = 0; i < N * N; i++) B[i] = (float)rand() / RAND_MAX - 0.5f;
    for (int i = 0; i < N; i++)
        for (int j = 0; j < N; j++) {
            float s = (i == j) ? (float)N : 0.0f;
            for (int k = 0; k < N; k++) s += B[k * N + i] * B[k * N + j];
            h_A[i * N + j] = s;
            h_A_orig[i * N + j] = s;
        }
    free(B);

    float *d_A;
    cudaMalloc(&d_A, N * N * sizeof(float));
    cudaMemcpy(d_A, h_A, N * N * sizeof(float), cudaMemcpyHostToDevice);

    /* Warmup */
    cudaDeviceSynchronize();

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);
    for (int j = 0; j < N; j += NB) {
        int jb = (j + NB <= N) ? NB : (N - j);
        int remaining = N - j - jb;

        /* 1. Panel factorization on GPU */
        gpu_panel_potrf<<<1, min(jb, 256)>>>(d_A, N, j, jb);

        if (remaining > 0) {
            /* 2. TRSM */
            int threads = 256;
            int blocks = (remaining + threads - 1) / threads;
            gpu_trsm<<<blocks, threads>>>(d_A, N, j, jb, N);

            /* 3. SYRK */
            dim3 syrk_block(16, 16);
            dim3 syrk_grid((remaining + 15) / 16, (remaining + 15) / 16);
            gpu_syrk<<<syrk_grid, syrk_block>>>(d_A, N, j, jb, N);
        }
    }
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float ms;
    cudaEventElapsedTime(&ms, start, stop);
    printf("Factorization time: %.3f ms\n", ms);

    /* Verify: reconstruct A' = L * L^T */
    cudaMemcpy(h_A, d_A, N * N * sizeof(float), cudaMemcpyDeviceToHost);

    for (int i = 0; i < N; i++)
        for (int j = i + 1; j < N; j++)
            h_A[i * N + j] = 0.0f;

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
