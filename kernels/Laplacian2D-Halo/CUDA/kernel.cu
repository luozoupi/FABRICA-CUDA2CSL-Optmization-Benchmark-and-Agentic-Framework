/*
 * CUDA Laplacian2D-Halo: one iteration of the 5-point Laplacian stencil with
 * zero-boundary conditions.
 *
 *   new[i,j] = 0.25f * ( old[i-1,j] + old[i+1,j] + old[i,j-1] + old[i,j+1] )
 *
 * with old[i,j] = 0 for i,j outside [0, M-1] x [0, N-1].
 *
 * CSL approach (in this kernel's CSL bundle):
 *   - 2D PE mesh (2x2 default); each PE owns a contiguous Mt x Nt tile of the
 *     global M x N grid.
 *   - Each PE exchanges its top/bottom rows and left/right columns with its 4
 *     cardinal neighbors via 4 fabric colors (NORTH, SOUTH, EAST, WEST). Edge
 *     PEs leave the missing-neighbor halo arrays zero-filled.
 *   - After all halos arrive (counter-driven), each PE computes its tile's new
 *     state locally using the halo arrays for cells that touch the tile border.
 *   - Optional in-kernel iteration loop (`iters` parameter) repeats the
 *     send-receive-compute cycle without returning to the host.
 *
 * CUDA approach:
 *   - Single kernel; one thread per cell; reads from a global old[] buffer and
 *     writes to a global new[] buffer.
 *   - Boundary cells use 0 for missing neighbors (no shared-memory tiling, no
 *     bank-conflict optimization — keeping the reference simple).
 *   - Host runs `iters` kernel invocations, swapping old/new pointers each step.
 *
 * The CSL bundle uses Mt = Nt = 4 and a 2x2 mesh by default, giving a global
 * grid of M = N = 8. This CUDA reference accepts arbitrary M, N (CPU CPU
 * reference loop) so it can be used to generate test data for larger grids.
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <cuda_runtime.h>

#define BLOCK_X 16
#define BLOCK_Y 16

__global__ void laplacian_5pt_kernel(
    const float* __restrict__ old_tile,
    float* __restrict__ new_tile,
    int M, int N)
{
    int j = blockIdx.x * blockDim.x + threadIdx.x;  // column
    int i = blockIdx.y * blockDim.y + threadIdx.y;  // row
    if (i >= M || j >= N) return;

    float up    = (i > 0)       ? old_tile[(i - 1) * N + j] : 0.0f;
    float down  = (i < M - 1)   ? old_tile[(i + 1) * N + j] : 0.0f;
    float left  = (j > 0)       ? old_tile[i * N + (j - 1)] : 0.0f;
    float right = (j < N - 1)   ? old_tile[i * N + (j + 1)] : 0.0f;

    new_tile[i * N + j] = 0.25f * (up + down + left + right);
}

static void laplacian_cpu(const float* old_tile, float* new_tile, int M, int N) {
    for (int i = 0; i < M; i++) {
        for (int j = 0; j < N; j++) {
            float up    = (i > 0)     ? old_tile[(i - 1) * N + j] : 0.0f;
            float down  = (i < M - 1) ? old_tile[(i + 1) * N + j] : 0.0f;
            float left  = (j > 0)     ? old_tile[i * N + (j - 1)] : 0.0f;
            float right = (j < N - 1) ? old_tile[i * N + (j + 1)] : 0.0f;
            new_tile[i * N + j] = 0.25f * (up + down + left + right);
        }
    }
}

int main(int argc, char** argv) {
    int M = 8, N = 8, iters = 1;
    if (argc > 1) M = atoi(argv[1]);
    if (argc > 2) N = atoi(argv[2]);
    if (argc > 3) iters = atoi(argv[3]);

    printf("Laplacian2D-Halo (5-point, zero boundary): M=%d, N=%d, iters=%d\n",
           M, N, iters);

    size_t bytes = (size_t)M * N * sizeof(float);
    float *h_a = (float*)malloc(bytes);
    float *h_b = (float*)malloc(bytes);
    float *h_ref_a = (float*)malloc(bytes);
    float *h_ref_b = (float*)malloc(bytes);

    // Deterministic input: A[i,j] = i*N + j.
    for (int i = 0; i < M * N; i++) {
        h_a[i] = (float)i;
        h_ref_a[i] = (float)i;
    }

    // CPU reference: iterate ping-pong.
    for (int t = 0; t < iters; t++) {
        laplacian_cpu(h_ref_a, h_ref_b, M, N);
        float* tmp = h_ref_a; h_ref_a = h_ref_b; h_ref_b = tmp;
    }
    // h_ref_a now holds the final state.

    float *d_a, *d_b;
    cudaMalloc(&d_a, bytes);
    cudaMalloc(&d_b, bytes);
    cudaMemcpy(d_a, h_a, bytes, cudaMemcpyHostToDevice);

    dim3 block(BLOCK_X, BLOCK_Y);
    dim3 grid((N + BLOCK_X - 1) / BLOCK_X, (M + BLOCK_Y - 1) / BLOCK_Y);
    for (int t = 0; t < iters; t++) {
        laplacian_5pt_kernel<<<grid, block>>>(d_a, d_b, M, N);
        float *tmp = d_a; d_a = d_b; d_b = tmp;
    }
    cudaDeviceSynchronize();
    cudaMemcpy(h_b, d_a, bytes, cudaMemcpyDeviceToHost);

    // Compare
    double max_diff = 0.0;
    for (int i = 0; i < M * N; i++) {
        double d = fabs((double)h_b[i] - (double)h_ref_a[i]);
        if (d > max_diff) max_diff = d;
    }
    int pass = (max_diff < 1e-5);
    printf("max abs diff = %e\n", max_diff);
    printf("Result: %s\n", pass ? "PASS" : "FAIL");

    cudaFree(d_a); cudaFree(d_b);
    free(h_a); free(h_b); free(h_ref_a); free(h_ref_b);
    return pass ? 0 : 1;
}
