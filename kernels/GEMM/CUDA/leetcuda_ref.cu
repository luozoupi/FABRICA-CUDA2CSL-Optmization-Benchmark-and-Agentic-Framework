/*
 * GEMM Reference: LeetCUDA sgemm_t_8x8_sliced_k_f32x4 (tiled + vectorized)
 * Source: https://github.com/xlite-dev/LeetCUDA/blob/main/kernels/sgemm/sgemm.cu
 *
 * C = A * B,  A: MxK, B: KxN, C: MxN, all row-major
 * Block Tile (128x128) + Thread Tile (8x8) + K Tile (8) + Vec4
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cuda_runtime.h>

#define FLOAT4(value) (reinterpret_cast<float4*>(&(value))[0])

template <const int BM = 128, const int BN = 128, const int BK = 8,
          const int TM = 8, const int TN = 8>
__global__ void sgemm_t_8x8_sliced_k_f32x4_kernel(float *a, float *b, float *c,
                                                    int M, int N, int K) {
    int bx = blockIdx.x;
    int by = blockIdx.y;
    int tx = threadIdx.x;
    int ty = threadIdx.y;
    int tid = threadIdx.y * blockDim.x + tx;
    __shared__ float s_a[BM][BK], s_b[BK][BN];

    int load_smem_a_m = tid / 2;
    int load_smem_a_k = (tid % 2 == 0) ? 0 : 4;
    int load_smem_b_k = tid / 32;
    int load_smem_b_n = (tid % 32) * 4;
    int load_gmem_a_m = by * BM + load_smem_a_m;
    int load_gmem_b_n = bx * BN + load_smem_b_n;

    float r_c[TM][TN] = {0.0};

    for (int bk = 0; bk < (K + BK - 1) / BK; ++bk) {
        int load_gmem_a_k = bk * BK + load_smem_a_k;
        int load_gmem_a_addr = load_gmem_a_m * K + load_gmem_a_k;
        FLOAT4(s_a[load_smem_a_m][load_smem_a_k]) = FLOAT4(a[load_gmem_a_addr]);
        int load_gmem_b_k = bk * BK + load_smem_b_k;
        int load_gmem_b_addr = load_gmem_b_k * N + load_gmem_b_n;
        FLOAT4(s_b[load_smem_b_k][load_smem_b_n]) = FLOAT4(b[load_gmem_b_addr]);
        __syncthreads();
#pragma unroll
        for (int k = 0; k < BK; k++) {
#pragma unroll
            for (int m = 0; m < TM; m++) {
#pragma unroll
                for (int n = 0; n < TN; n++) {
                    int comp_smem_a_m = ty * TM + m;
                    int comp_smem_b_n = tx * TN + n;
                    r_c[m][n] += s_a[comp_smem_a_m][k] * s_b[k][comp_smem_b_n];
                }
            }
        }
        __syncthreads();
    }

#pragma unroll
    for (int m = 0; m < TM; ++m) {
        int store_gmem_c_m = by * BM + ty * TM + m;
#pragma unroll
        for (int n = 0; n < TN; n += 4) {
            int store_gmem_c_n = bx * BN + tx * TN + n;
            int store_gmem_c_addr = store_gmem_c_m * N + store_gmem_c_n;
            FLOAT4(c[store_gmem_c_addr]) = FLOAT4(r_c[m][n]);
        }
    }
}

int main(int argc, char **argv) {
    int M = 1024, N = 1024, K = 1024;
    if (argc > 1) M = N = K = atoi(argv[1]);

    // Sizes must be multiples of 128 for this kernel
    M = ((M + 127) / 128) * 128;
    N = ((N + 127) / 128) * 128;
    K = ((K + 7) / 8) * 8;

    printf("LeetCUDA GEMM (t_8x8_sliced_k_f32x4): C = A*B, M=%d, N=%d, K=%d\n",
           M, N, K);

    size_t sA = (size_t)M * K * sizeof(float);
    size_t sB = (size_t)K * N * sizeof(float);
    size_t sC = (size_t)M * N * sizeof(float);

    float *h_A = (float*)malloc(sA);
    float *h_B = (float*)malloc(sB);
    float *h_C = (float*)malloc(sC);
    float *h_ref = (float*)malloc(sC);

    srand(42);
    for (size_t i = 0; i < (size_t)M * K; i++) h_A[i] = (float)rand() / RAND_MAX - 0.5f;
    for (size_t i = 0; i < (size_t)K * N; i++) h_B[i] = (float)rand() / RAND_MAX - 0.5f;

    // CPU reference (only verify a subset for large matrices)
    int verify_rows = (M > 64) ? 64 : M;
    for (int i = 0; i < verify_rows; i++) {
        for (int j = 0; j < N; j++) {
            float s = 0.0f;
            for (int k = 0; k < K; k++) s += h_A[i * K + k] * h_B[k * N + j];
            h_ref[i * N + j] = s;
        }
    }

    float *d_A, *d_B, *d_C;
    cudaMalloc(&d_A, sA);
    cudaMalloc(&d_B, sB);
    cudaMalloc(&d_C, sC);
    cudaMemcpy(d_A, h_A, sA, cudaMemcpyHostToDevice);
    cudaMemcpy(d_B, h_B, sB, cudaMemcpyHostToDevice);

    constexpr int BM = 128, BN = 128, TM = 8, TN = 8;
    dim3 block(BN / TN, BM / TM);  // 16x16
    dim3 grid((N + BN - 1) / BN, (M + BM - 1) / BM);

    // Warmup
    sgemm_t_8x8_sliced_k_f32x4_kernel<<<grid, block>>>(d_A, d_B, d_C, M, N, K);
    cudaDeviceSynchronize();

    // Benchmark
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    int niter = 20;

    cudaEventRecord(start);
    for (int i = 0; i < niter; i++)
        sgemm_t_8x8_sliced_k_f32x4_kernel<<<grid, block>>>(d_A, d_B, d_C, M, N, K);
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float ms;
    cudaEventElapsedTime(&ms, start, stop);
    float avg_ms = ms / niter;
    double flops = 2.0 * M * N * K;
    double gflops = (flops / (avg_ms * 1e-3)) / 1e9;
    printf("Kernel time: %.4f ms (avg over %d iterations)\n", avg_ms, niter);
    printf("Performance: %.1f GFLOPS\n", gflops);

    // Verify
    cudaMemcpy(h_C, d_C, sC, cudaMemcpyDeviceToHost);
    float max_err = 0.0f, max_val = 0.0f;
    for (int i = 0; i < verify_rows; i++) {
        for (int j = 0; j < N; j++) {
            float err = fabsf(h_C[i * N + j] - h_ref[i * N + j]);
            if (err > max_err) max_err = err;
            if (fabsf(h_ref[i * N + j]) > max_val) max_val = fabsf(h_ref[i * N + j]);
        }
    }
    float rel = max_val > 0 ? max_err / max_val : max_err;
    printf("Max error: %e, relative: %e\n", max_err, rel);
    printf("Result: %s\n", (rel < 1e-4) ? "PASS" : "FAIL");

    cudaFree(d_A); cudaFree(d_B); cudaFree(d_C);
    free(h_A); free(h_B); free(h_C); free(h_ref);
    cudaEventDestroy(start); cudaEventDestroy(stop);
    return (rel < 1e-4) ? 0 : 1;
}
