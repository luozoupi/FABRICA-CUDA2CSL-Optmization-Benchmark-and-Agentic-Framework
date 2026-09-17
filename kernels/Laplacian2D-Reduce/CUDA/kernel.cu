/*
 * CUDA Laplacian2D-Reduce: 5-point 2D Laplacian with zero-boundary, plus a
 * global max-norm reduction at the end:
 *
 *   new[i,j] = 0.25 * (old[i-1,j] + old[i+1,j] + old[i,j-1] + old[i,j+1])
 *   nrm      = max over all cells of |new[i,j] - old[i,j]|
 *
 * CSL approach (in this kernel's CSL bundle):
 *   - 2D PE mesh (2x2 default); each PE owns a contiguous Mt x Nt tile.
 *   - 4-cardinal halo exchange (NORTH/SOUTH/EAST/WEST colors); same as
 *     Laplacian2D-Halo.
 *   - After local compute, each PE holds a per-tile max(|new - old|).
 *   - Column-direction reduction on NRM color: south PE sends its local
 *     max north; north PE takes max(self, recv).
 *   - The two py=0 PEs end up holding per-column maxes; the host takes the
 *     max of those two values on D2H.
 *
 * CUDA approach (this file): a single stencil kernel plus a max-reduce
 * kernel, like the existing Residual reference.
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cuda_runtime.h>

#define BLOCK_X 16
#define BLOCK_Y 16
#define BLOCK_SIZE 256

__global__ void laplacian_5pt_kernel(
    const float* __restrict__ old_tile,
    float* __restrict__ new_tile,
    int M, int N)
{
  int j = blockIdx.x * blockDim.x + threadIdx.x;
  int i = blockIdx.y * blockDim.y + threadIdx.y;
  if (i >= M || j >= N) return;
  float up    = (i > 0)     ? old_tile[(i - 1) * N + j] : 0.0f;
  float down  = (i < M - 1) ? old_tile[(i + 1) * N + j] : 0.0f;
  float left  = (j > 0)     ? old_tile[i * N + (j - 1)] : 0.0f;
  float right = (j < N - 1) ? old_tile[i * N + (j + 1)] : 0.0f;
  new_tile[i * N + j] = 0.25f * (up + down + left + right);
}

__global__ void abs_diff_kernel(
    const float* __restrict__ a, const float* __restrict__ b,
    float* __restrict__ out, int n)
{
  int i = blockIdx.x * blockDim.x + threadIdx.x;
  if (i < n) out[i] = fabsf(a[i] - b[i]);
}

__global__ void max_reduce_kernel(const float* x, float* result, int n) {
  __shared__ float sdata[BLOCK_SIZE];
  float local_max = 0.0f;
  for (int i = threadIdx.x; i < n; i += blockDim.x) {
    if (x[i] > local_max) local_max = x[i];
  }
  sdata[threadIdx.x] = local_max;
  __syncthreads();
  for (int s = blockDim.x / 2; s > 0; s >>= 1) {
    if (threadIdx.x < s && sdata[threadIdx.x + s] > sdata[threadIdx.x])
      sdata[threadIdx.x] = sdata[threadIdx.x + s];
    __syncthreads();
  }
  if (threadIdx.x == 0) result[0] = sdata[0];
}

int main(int argc, char** argv) {
  int M = 8, N = 8, iters = 1;
  if (argc > 1) M = atoi(argv[1]);
  if (argc > 2) N = atoi(argv[2]);
  if (argc > 3) iters = atoi(argv[3]);

  size_t bytes = (size_t)M * N * sizeof(float);
  float *h_a = (float*)malloc(bytes);
  for (int i = 0; i < M * N; i++) h_a[i] = (float)i;

  float *d_a, *d_b, *d_diff, *d_result;
  cudaMalloc(&d_a, bytes); cudaMalloc(&d_b, bytes);
  cudaMalloc(&d_diff, bytes); cudaMalloc(&d_result, sizeof(float));
  cudaMemcpy(d_a, h_a, bytes, cudaMemcpyHostToDevice);

  dim3 block(BLOCK_X, BLOCK_Y);
  dim3 grid((N + BLOCK_X - 1) / BLOCK_X, (M + BLOCK_Y - 1) / BLOCK_Y);
  float last_nrm = 0.0f;
  for (int t = 0; t < iters; t++) {
    laplacian_5pt_kernel<<<grid, block>>>(d_a, d_b, M, N);
    abs_diff_kernel<<<(M*N + BLOCK_SIZE - 1)/BLOCK_SIZE, BLOCK_SIZE>>>(d_a, d_b, d_diff, M*N);
    max_reduce_kernel<<<1, BLOCK_SIZE>>>(d_diff, d_result, M*N);
    cudaMemcpy(&last_nrm, d_result, sizeof(float), cudaMemcpyDeviceToHost);
    float *tmp = d_a; d_a = d_b; d_b = tmp;
  }
  printf("Laplacian2D-Reduce: M=%d N=%d iters=%d final nrm = %e\n", M, N, iters, last_nrm);

  cudaFree(d_a); cudaFree(d_b); cudaFree(d_diff); cudaFree(d_result);
  free(h_a);
  return 0;
}
