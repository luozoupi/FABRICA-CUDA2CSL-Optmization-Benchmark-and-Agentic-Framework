/*
 * CUDA GEMM (single-tile dense): C = A * B for dense row-major matrices.
 *
 * This is the SIMPLE, hand-written-compute GEMM: a single PE holds the whole
 * M x K, K x N, M x N tiles and computes the dense triple-loop matmul. It is the
 * TRAIN-tier counterpart to the complex collective SUMMA GEMM
 * (kernels/GEMM-Collectives-2D), which decomposes A*B across a P x P mesh via the
 * collectives_2d broadcast/reduce library. Here there is no library and no
 * decomposition — just the explicit arithmetic, so a CSL translation expresses the
 * real inner product (an fmac accumulation), and cycles_send measures that compute.
 *
 *   for i in [0,M): for j in [0,N): C[i,j] = sum_k A[i,k]*B[k,j]
 */

#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

// One thread computes the whole MxN tile (single-PE-equivalent reference).
__global__ void gemm_dense(const float* __restrict__ A, const float* __restrict__ B,
                           float* __restrict__ C, int M, int K, int N) {
    for (int i = 0; i < M; i++) {
        for (int j = 0; j < N; j++) {
            float acc = 0.0f;
            for (int k = 0; k < K; k++) {
                acc += A[i * K + k] * B[k * N + j];   // inner product (fmac)
            }
            C[i * N + j] = acc;
        }
    }
}

int main(void) {
    // Host driver omitted; the kernel above is the translation target. Reference
    // verification (C == A@B) is performed in the CSL bundle's run.py.
    return 0;
}
