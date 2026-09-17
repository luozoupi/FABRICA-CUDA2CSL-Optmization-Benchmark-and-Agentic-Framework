/*
 * CUDA Jacobi 2D 5-point stencil — one iteration.
 *
 *   B[i,j] = 0.25 * ( A[i-1,j] + A[i+1,j] + A[i,j-1] + A[i,j+1] )    for 1 <= i <= H-2 and 1 <= j <= W-2
 *   B[i,j] = A[i,j]                                                  on the boundary (i==0, i==H-1, j==0, or j==W-1)
 *
 * Boundary policy: PRESERVED (Dirichlet-style — boundary cells of B mirror
 * boundary cells of A). This is the textbook Jacobi PDE iteration form;
 * outer-edge values are inputs to the system, not computed.
 *
 * CSL approach (in this kernel's CSL bundle):
 *   - 2D PE mesh (configurable; default 2x2); each PE owns a contiguous
 *     Mt x Nt tile of the global H x W grid (so H = MESH_H * Mt, W = MESH_W * Nt).
 *   - Each PE exchanges its top/bottom rows and left/right columns with its
 *     four cardinal neighbors via 4 fabric colors (NORTH/SOUTH/EAST/WEST).
 *     Edge PEs zero-fill the halo arrays toward the missing neighbor — those
 *     contributions to interior updates were never going to read past the
 *     boundary anyway, since we skip boundary cells.
 *   - After all halos arrive (counter-driven), each PE updates only the
 *     INTERIOR cells of its tile; boundary cells of the global grid (which
 *     are boundary cells of one of the edge PEs' tiles) are left untouched.
 *
 * CUDA approach:
 *   - Single kernel; one thread per cell; reads from a global A[] buffer and
 *     writes to a global B[] buffer.
 *   - Boundary cells are mirrored verbatim from A to B (no compute).
 *   - One iteration only — host does the ping-pong if multiple iterations are
 *     wanted, but the issue specifies one update.
 *
 * Built with: nvcc -O3 -arch=sm_70 -o jacobi2d_5pt jacobi2d_5pt.cu
 * Tested grid: H = W = 8 (matches the CSL bundle's 2x2 mesh of 4x4 tiles).
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <cuda_runtime.h>

#define BLOCK_X 16
#define BLOCK_Y 16

// Device kernel: one Jacobi 2D 5-point stencil iteration.
// Interior cells: B[i,j] = 0.25 * (A[i-1,j] + A[i+1,j] + A[i,j-1] + A[i,j+1])
// Boundary cells (i in {0, H-1} OR j in {0, W-1}): B[i,j] = A[i,j].
__global__ void jacobi2d_5pt_kernel(
    const float* __restrict__ A,
    float* __restrict__ B,
    int H, int W)
{
    int j = blockIdx.x * blockDim.x + threadIdx.x;  // column
    int i = blockIdx.y * blockDim.y + threadIdx.y;  // row
    if (i >= H || j >= W) return;

    if (i == 0 || i == H - 1 || j == 0 || j == W - 1) {
        // Preserve boundary verbatim — Dirichlet-style.
        B[i * W + j] = A[i * W + j];
    } else {
        float up    = A[(i - 1) * W + j];
        float down  = A[(i + 1) * W + j];
        float left  = A[i * W + (j - 1)];
        float right = A[i * W + (j + 1)];
        B[i * W + j] = 0.25f * (up + down + left + right);
    }
}

// CPU/numpy-style reference. Identical semantics to the kernel above; used
// for correctness comparison.
static void jacobi2d_5pt_cpu(const float* A, float* B, int H, int W) {
    for (int i = 0; i < H; i++) {
        for (int j = 0; j < W; j++) {
            if (i == 0 || i == H - 1 || j == 0 || j == W - 1) {
                B[i * W + j] = A[i * W + j];
            } else {
                B[i * W + j] = 0.25f * (
                    A[(i - 1) * W + j] +
                    A[(i + 1) * W + j] +
                    A[i * W + (j - 1)] +
                    A[i * W + (j + 1)]);
            }
        }
    }
}

int main(int argc, char** argv) {
    int H = (argc > 1) ? atoi(argv[1]) : 8;
    int W = (argc > 2) ? atoi(argv[2]) : 8;
    size_t bytes = (size_t)H * W * sizeof(float);

    // Deterministic input — matches numpy seed=7 (used by the CSL bundle's
    // run.py for the agent-side test).
    float* hA = (float*)malloc(bytes);
    float* hB = (float*)malloc(bytes);
    float* hRef = (float*)malloc(bytes);
    srand(7);
    for (int k = 0; k < H * W; k++) {
        hA[k] = (float)rand() / (float)RAND_MAX;
    }

    jacobi2d_5pt_cpu(hA, hRef, H, W);

    float *dA, *dB;
    cudaMalloc(&dA, bytes);
    cudaMalloc(&dB, bytes);
    cudaMemcpy(dA, hA, bytes, cudaMemcpyHostToDevice);

    dim3 block(BLOCK_X, BLOCK_Y);
    dim3 grid((W + BLOCK_X - 1) / BLOCK_X, (H + BLOCK_Y - 1) / BLOCK_Y);
    jacobi2d_5pt_kernel<<<grid, block>>>(dA, dB, H, W);
    cudaDeviceSynchronize();
    cudaMemcpy(hB, dB, bytes, cudaMemcpyDeviceToHost);

    // Verify against CPU reference.
    float max_err = 0.0f;
    for (int k = 0; k < H * W; k++) {
        float e = fabsf(hB[k] - hRef[k]);
        if (e > max_err) max_err = e;
    }
    printf("H=%d W=%d max_abs_err=%g %s\n",
        H, W, max_err, (max_err < 1e-5f ? "SUCCESS" : "FAIL"));

    free(hA); free(hB); free(hRef);
    cudaFree(dA); cudaFree(dB);
    return (max_err < 1e-5f) ? 0 : 1;
}
