/*
 * GEMV Reference: LeetCUDA sgemv_k128_f32x4 (vectorized warp-based GEMV)
 * Source: https://github.com/xlite-dev/LeetCUDA/blob/main/kernels/sgemv/sgemv.cu
 *
 * y = A * x,  A: MxK, x: Kx1, y: Mx1
 * Uses float4 vectorized loads, warp shuffle reduction.
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cuda_runtime.h>

#define WARP_SIZE 32
#define FLOAT4(value) (reinterpret_cast<float4*>(&(value))[0])

template <const int kWarpSize = WARP_SIZE>
__device__ __forceinline__ float warp_reduce_sum_f32(float val) {
#pragma unroll
    for (int mask = kWarpSize >> 1; mask >= 1; mask >>= 1) {
        val += __shfl_xor_sync(0xffffffff, val, mask);
    }
    return val;
}

// Best variant: K128 with float4 vectorization
__global__ void sgemv_k128_f32x4_kernel(float *a, float *x, float *y,
                                         int M, int K) {
    int tx = threadIdx.x;
    int ty = threadIdx.y;
    int bx = blockIdx.x;
    int lane = tx % WARP_SIZE;
    int m = blockDim.y * bx + ty;

    if (m < M) {
        float sum = 0.0f;
        int NUM_WARPS = (((K + WARP_SIZE - 1) / WARP_SIZE) + 4 - 1) / 4;
#pragma unroll
        for (int w = 0; w < NUM_WARPS; ++w) {
            int k = (w * WARP_SIZE + lane) * 4;
            if (k + 3 < K) {
                float4 reg_x = FLOAT4(x[k]);
                float4 reg_a = FLOAT4(a[m * K + k]);
                sum += (reg_a.x * reg_x.x + reg_a.y * reg_x.y +
                        reg_a.z * reg_x.z + reg_a.w * reg_x.w);
            }
        }
        sum = warp_reduce_sum_f32<WARP_SIZE>(sum);
        if (lane == 0) y[m] = sum;
    }
}

int main(int argc, char **argv) {
    int M = 2048, K = 1024;
    if (argc > 1) M = atoi(argv[1]);
    if (argc > 2) K = atoi(argv[2]);
    // K must be multiple of 128
    K = ((K + 127) / 128) * 128;

    printf("LeetCUDA GEMV (k128_f32x4): y = A*x, M=%d, K=%d\n", M, K);

    size_t sA = (size_t)M * K * sizeof(float);
    size_t sX = (size_t)K * sizeof(float);
    size_t sY = (size_t)M * sizeof(float);

    float *h_A = (float*)malloc(sA);
    float *h_x = (float*)malloc(sX);
    float *h_y = (float*)malloc(sY);
    float *h_ref = (float*)malloc(sY);

    srand(42);
    for (int i = 0; i < M * K; i++) h_A[i] = (float)rand() / RAND_MAX - 0.5f;
    for (int i = 0; i < K; i++) h_x[i] = (float)rand() / RAND_MAX - 0.5f;

    // CPU reference
    for (int i = 0; i < M; i++) {
        float s = 0.0f;
        for (int j = 0; j < K; j++) s += h_A[i * K + j] * h_x[j];
        h_ref[i] = s;
    }

    float *d_A, *d_x, *d_y;
    cudaMalloc(&d_A, sA);
    cudaMalloc(&d_x, sX);
    cudaMalloc(&d_y, sY);
    cudaMemcpy(d_A, h_A, sA, cudaMemcpyHostToDevice);
    cudaMemcpy(d_x, h_x, sX, cudaMemcpyHostToDevice);

    dim3 block(32, 4);
    dim3 grid((M + 4 - 1) / 4);

    // Warmup
    sgemv_k128_f32x4_kernel<<<grid, block>>>(d_A, d_x, d_y, M, K);
    cudaDeviceSynchronize();

    // Benchmark
    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    int niter = 100;

    cudaEventRecord(start);
    for (int i = 0; i < niter; i++)
        sgemv_k128_f32x4_kernel<<<grid, block>>>(d_A, d_x, d_y, M, K);
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float ms;
    cudaEventElapsedTime(&ms, start, stop);
    printf("Kernel time: %.4f ms (avg over %d iterations)\n", ms / niter, niter);

    // Verify
    cudaMemcpy(h_y, d_y, sY, cudaMemcpyDeviceToHost);
    float max_err = 0.0f, max_val = 0.0f;
    for (int i = 0; i < M; i++) {
        float err = fabsf(h_y[i] - h_ref[i]);
        if (err > max_err) max_err = err;
        if (fabsf(h_ref[i]) > max_val) max_val = fabsf(h_ref[i]);
    }
    float rel = max_val > 0 ? max_err / max_val : max_err;
    printf("Max error: %e, relative: %e\n", max_err, rel);
    printf("Result: %s\n", (rel < 1e-5) ? "PASS" : "FAIL");

    cudaFree(d_A); cudaFree(d_x); cudaFree(d_y);
    free(h_A); free(h_x); free(h_y); free(h_ref);
    cudaEventDestroy(start); cudaEventDestroy(stop);
    return (rel < 1e-5) ? 0 : 1;
}
