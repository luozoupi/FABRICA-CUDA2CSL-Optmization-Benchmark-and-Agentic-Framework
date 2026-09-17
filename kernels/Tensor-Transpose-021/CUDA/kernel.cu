/*
 * CUDA 3D tensor transpose, permutation 021 (abc -> acb).
 *
 * Faithful port of the `_transpose_021` GPU kernel from the GPU-accelerated
 * quantum-chemistry package MatthewRHermes/mrh (gpu/src/pm/device_cuda.cpp),
 * where it is one of a family of tensor-permutation kernels used to reshape
 * density-fitting / AO2MO intermediates between contraction steps.
 *
 * Operation: given A with logical shape [ax1][ax2][ax3] (row-major), produce
 *   B[i][k][j] = A[i][j][k]    for all i<ax1, j<ax2, k<ax3
 * i.e. swap the last two axes. The exact index arithmetic mirrors the source:
 *   inputIndex  = (i*ax3 + k)*ax2 + j   // NOTE: source reads A as [ax1][ax3][ax2]
 *   outputIndex = (i*ax2 + j)*ax3 + k
 * Here we keep the standard row-major reading A[i][j][k] = A[(i*ax2+j)*ax3+k]
 * and write B[i][k][j] = B[(i*ax3+k)*ax2+j], which is the same permutation
 * (numpy: B = A.transpose(0, 2, 1)).
 *
 * This is a pure data-movement / index-permutation kernel: no arithmetic, every
 * element copied to a permuted location. It is a new operation family for the
 * benchmark (no transpose kernel existed before).
 */

#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

// 3D grid: one thread per (i,j,k) element. Mirrors mrh's _transpose_021 which
// guards i<ax1, j<ax2, k<ax3 and copies one element.
__global__ void transpose_021(
    const float* __restrict__ A,   // [ax1][ax2][ax3]
    float* __restrict__ B,         // [ax1][ax3][ax2]
    int ax1, int ax2, int ax3)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    int j = blockIdx.y * blockDim.y + threadIdx.y;
    int k = blockIdx.z * blockDim.z + threadIdx.z;
    if (i >= ax1 || j >= ax2 || k >= ax3) return;

    int inputIndex  = (i * ax2 + j) * ax3 + k;   // A[i][j][k]
    int outputIndex = (i * ax3 + k) * ax2 + j;   // B[i][k][j]
    B[outputIndex] = A[inputIndex];
}

int main(int argc, char** argv) {
    int ax1 = 8, ax2 = 8, ax3 = 8;
    if (argc > 3) { ax1 = atoi(argv[1]); ax2 = atoi(argv[2]); ax3 = atoi(argv[3]); }

    printf("Tensor transpose 021 (abc->acb): [%d][%d][%d] -> [%d][%d][%d]\n",
           ax1, ax2, ax3, ax1, ax3, ax2);

    int n = ax1 * ax2 * ax3;
    size_t bytes = n * sizeof(float);

    float *h_A = (float*)malloc(bytes);
    float *h_B = (float*)malloc(bytes);
    float *h_ref = (float*)malloc(bytes);

    srand(42);
    for (int idx = 0; idx < n; idx++) h_A[idx] = (float)rand() / RAND_MAX - 0.5f;

    // Host reference
    for (int i = 0; i < ax1; i++)
        for (int j = 0; j < ax2; j++)
            for (int k = 0; k < ax3; k++)
                h_ref[(i * ax3 + k) * ax2 + j] = h_A[(i * ax2 + j) * ax3 + k];

    float *d_A, *d_B;
    cudaMalloc(&d_A, bytes);
    cudaMalloc(&d_B, bytes);
    cudaMemcpy(d_A, h_A, bytes, cudaMemcpyHostToDevice);

    dim3 block(4, 4, 4);
    dim3 grid((ax1 + block.x - 1) / block.x,
              (ax2 + block.y - 1) / block.y,
              (ax3 + block.z - 1) / block.z);
    transpose_021<<<grid, block>>>(d_A, d_B, ax1, ax2, ax3);
    cudaMemcpy(h_B, d_B, bytes, cudaMemcpyDeviceToHost);

    // Verify
    float max_err = 0.0f;
    for (int idx = 0; idx < n; idx++) {
        float e = fabsf(h_B[idx] - h_ref[idx]);
        if (e > max_err) max_err = e;
    }
    printf("max_err=%e -> %s\n", max_err, (max_err == 0.0f) ? "PASS" : "FAIL");

    // Benchmark
    cudaEvent_t start, stop;
    cudaEventCreate(&start); cudaEventCreate(&stop);
    int niter = 200;
    for (int i = 0; i < 10; i++) transpose_021<<<grid, block>>>(d_A, d_B, ax1, ax2, ax3);
    cudaEventRecord(start);
    for (int i = 0; i < niter; i++) transpose_021<<<grid, block>>>(d_A, d_B, ax1, ax2, ax3);
    cudaEventRecord(stop); cudaEventSynchronize(stop);
    float ms; cudaEventElapsedTime(&ms, start, stop);
    printf("Benchmark: %.3f us (avg over %d iters)\n", ms / niter * 1000, niter);

    cudaFree(d_A); cudaFree(d_B);
    free(h_A); free(h_B); free(h_ref);
    cudaEventDestroy(start); cudaEventDestroy(stop);
    return 0;
}
