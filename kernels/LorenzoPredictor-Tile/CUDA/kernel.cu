/*
 * CUDA LorenzoPredictor-Tile: simplest piece of the CereSZ-style lossy
 * compression pipeline. Per-cell Lorenzo prediction residual:
 *
 *   residual[i,j] = A[i,j] - (A[i-1,j] + A[i,j-1] - A[i-1,j-1])
 *
 * with A[i,j] = 0 for i,j < 0. The Lorenzo predictor's intuition: the
 * top-left neighbor cancels the "double counting" of A[i-1,j-1] that would
 * otherwise appear in both the left and up contributions.
 *
 * CSL approach (in this kernel's CSL bundle):
 *   - 2D PE mesh (2x2); each PE owns an Mt x Nt tile.
 *   - 3 halos needed: top row from north neighbor, left column from west
 *     neighbor, top-left scalar from NW neighbor. The NW scalar is the
 *     trickiest: there's no fabric diagonal, so either (a) the NW
 *     neighbor sends it explicitly via an extra hop, (b) it piggybacks on
 *     the north halo's leftmost element, or (c) the host pre-computes it
 *     and includes it in the per-PE memcpy. The skeleton pe.csl wires
 *     N and W halos and leaves the NW scalar as a zero placeholder.
 *
 * CUDA approach (this file): single kernel; one thread per cell; reads
 * the global A[] buffer with boundary checks. Sequential semantics — the
 * Lorenzo predictor is independent per cell since it only reads A, not
 * the in-progress residual.
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cuda_runtime.h>

#define BLOCK_X 16
#define BLOCK_Y 16

__global__ void lorenzo_kernel(
    const float* __restrict__ A,
    float* __restrict__ residual,
    int M, int N)
{
  int j = blockIdx.x * blockDim.x + threadIdx.x;
  int i = blockIdx.y * blockDim.y + threadIdx.y;
  if (i >= M || j >= N) return;
  float up   = (i > 0)             ? A[(i - 1) * N + j]      : 0.0f;
  float left = (j > 0)             ? A[i * N + (j - 1)]      : 0.0f;
  float nw   = (i > 0 && j > 0)    ? A[(i - 1) * N + (j - 1)] : 0.0f;
  residual[i * N + j] = A[i * N + j] - (up + left - nw);
}

int main(int argc, char** argv) {
  int M = 8, N = 8;
  if (argc > 1) M = atoi(argv[1]);
  if (argc > 2) N = atoi(argv[2]);

  size_t bytes = (size_t)M * N * sizeof(float);
  float *h_a = (float*)malloc(bytes);
  float *h_r = (float*)malloc(bytes);
  for (int i = 0; i < M * N; i++) h_a[i] = (float)i;

  float *d_a, *d_r;
  cudaMalloc(&d_a, bytes); cudaMalloc(&d_r, bytes);
  cudaMemcpy(d_a, h_a, bytes, cudaMemcpyHostToDevice);

  dim3 block(BLOCK_X, BLOCK_Y);
  dim3 grid((N + BLOCK_X - 1) / BLOCK_X, (M + BLOCK_Y - 1) / BLOCK_Y);
  lorenzo_kernel<<<grid, block>>>(d_a, d_r, M, N);
  cudaMemcpy(h_r, d_r, bytes, cudaMemcpyDeviceToHost);
  printf("LorenzoPredictor-Tile: M=%d N=%d residual[0,0]=%g residual[%d,%d]=%g\n",
         M, N, h_r[0], M-1, N-1, h_r[(M-1)*N + (N-1)]);

  cudaFree(d_a); cudaFree(d_r);
  free(h_a); free(h_r);
  return 0;
}
