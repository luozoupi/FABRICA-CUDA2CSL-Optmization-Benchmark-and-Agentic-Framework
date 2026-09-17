/*
 * CUDA 25-Point Stencil (3D Finite Difference)
 *
 * Translates the CSL 25-point stencil kernel from:
 *   sdk-examples/benchmarks/25-pt-stencil/task.csl
 *
 * CSL approach:
 *   - 2D grid of PEs, each PE holds a vertical column (z-dimension)
 *   - Neighbor exchange via fabric (NORTH/SOUTH/EAST/WEST) for halo data
 *   - Each PE computes 25-point FD stencil using local + neighbor data
 *   - Time-marching with source injection
 *
 * CUDA approach:
 *   - 3D grid stored in global memory
 *   - Each thread computes one grid point
 *   - 25-point stencil: 5 points along each axis (±1, ±2 in x, y, z)
 *     plus cross-terms for 4th-order accuracy
 *   - Time-marching loop on host
 *
 * Stencil coefficients for 4th-order accurate 3D Laplacian:
 *   25 points = center + 4 per axis (±1, ±2) × 3 axes + 12 cross-terms
 *   Simplified here to a standard 25-point isotropic stencil.
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cuda_runtime.h>

#define BLOCK_X 8
#define BLOCK_Y 8
#define BLOCK_Z 8

// 25-point stencil: center + 4 per axis (3 axes) + 12 edge terms = 25
__global__ void stencil25_kernel(
    const float* __restrict__ u,
    float* __restrict__ u_next,
    const float* __restrict__ vp2,  // velocity^2 * dt^2
    const float* __restrict__ u_prev,
    int nx, int ny, int nz,
    float c0, float c1, float c2)
{
    int ix = blockIdx.x * blockDim.x + threadIdx.x;
    int iy = blockIdx.y * blockDim.y + threadIdx.y;
    int iz = blockIdx.z * blockDim.z + threadIdx.z;

    if (ix < 2 || ix >= nx - 2 || iy < 2 || iy >= ny - 2 || iz < 2 || iz >= nz - 2)
        return;

    int idx = ix * ny * nz + iy * nz + iz;

    // 25-point stencil for 3D Laplacian (4th order)
    float lap = c0 * u[idx];

    // ±1 and ±2 along each axis
    lap += c1 * (u[idx + ny*nz] + u[idx - ny*nz]);      // x ± 1
    lap += c2 * (u[idx + 2*ny*nz] + u[idx - 2*ny*nz]);  // x ± 2
    lap += c1 * (u[idx + nz] + u[idx - nz]);             // y ± 1
    lap += c2 * (u[idx + 2*nz] + u[idx - 2*nz]);         // y ± 2
    lap += c1 * (u[idx + 1] + u[idx - 1]);               // z ± 1
    lap += c2 * (u[idx + 2] + u[idx - 2]);               // z ± 2

    // Cross-terms (xy, xz, yz planes) for higher accuracy
    // xy cross: (±1, ±1, 0) — 4 points
    lap += (c1 * c1 / c0) * 0.25f * (
        u[(ix+1)*ny*nz + (iy+1)*nz + iz] +
        u[(ix+1)*ny*nz + (iy-1)*nz + iz] +
        u[(ix-1)*ny*nz + (iy+1)*nz + iz] +
        u[(ix-1)*ny*nz + (iy-1)*nz + iz]);

    // xz cross: (±1, 0, ±1) — 4 points
    lap += (c1 * c1 / c0) * 0.25f * (
        u[(ix+1)*ny*nz + iy*nz + iz+1] +
        u[(ix+1)*ny*nz + iy*nz + iz-1] +
        u[(ix-1)*ny*nz + iy*nz + iz+1] +
        u[(ix-1)*ny*nz + iy*nz + iz-1]);

    // yz cross: (0, ±1, ±1) — 4 points
    lap += (c1 * c1 / c0) * 0.25f * (
        u[ix*ny*nz + (iy+1)*nz + iz+1] +
        u[ix*ny*nz + (iy+1)*nz + iz-1] +
        u[ix*ny*nz + (iy-1)*nz + iz+1] +
        u[ix*ny*nz + (iy-1)*nz + iz-1]);

    // Time update: u_next = 2*u - u_prev + vp2 * lap
    u_next[idx] = 2.0f * u[idx] - u_prev[idx] + vp2[idx] * lap;
}

int main(int argc, char** argv) {
    int nx = 64, ny = 64, nz = 64;
    int nt = 10;
    if (argc > 1) nx = ny = nz = atoi(argv[1]);
    if (argc > 2) nt = atoi(argv[2]);

    printf("25-Point Stencil: %dx%dx%d, %d timesteps\n", nx, ny, nz, nt);

    size_t n = nx * ny * nz;
    size_t nbytes = n * sizeof(float);

    // 4th-order FD coefficients for d^2/dx^2
    float c0 = -5.0f;    // center
    float c1 =  4.0f/3;  // ±1
    float c2 = -1.0f/12; // ±2

    float *h_u = (float*)calloc(n, sizeof(float));
    float *h_vp2 = (float*)malloc(nbytes);

    // Constant velocity field
    for (size_t i = 0; i < n; i++) h_vp2[i] = 0.01f;

    // Initial pulse at center
    int cx = nx/2, cy = ny/2, cz = nz/2;
    h_u[cx*ny*nz + cy*nz + cz] = 1.0f;

    float *d_u, *d_u_next, *d_u_prev, *d_vp2;
    cudaMalloc(&d_u, nbytes);
    cudaMalloc(&d_u_next, nbytes);
    cudaMalloc(&d_u_prev, nbytes);
    cudaMalloc(&d_vp2, nbytes);

    cudaMemcpy(d_u, h_u, nbytes, cudaMemcpyHostToDevice);
    cudaMemset(d_u_prev, 0, nbytes);
    cudaMemset(d_u_next, 0, nbytes);
    cudaMemcpy(d_vp2, h_vp2, nbytes, cudaMemcpyHostToDevice);

    dim3 block(BLOCK_X, BLOCK_Y, BLOCK_Z);
    dim3 grid((nx + BLOCK_X - 1) / BLOCK_X,
              (ny + BLOCK_Y - 1) / BLOCK_Y,
              (nz + BLOCK_Z - 1) / BLOCK_Z);

    // Warmup
    stencil25_kernel<<<grid, block>>>(d_u, d_u_next, d_vp2, d_u_prev, nx, ny, nz, c0, c1, c2);
    cudaDeviceSynchronize();

    // Reset
    cudaMemcpy(d_u, h_u, nbytes, cudaMemcpyHostToDevice);
    cudaMemset(d_u_prev, 0, nbytes);
    cudaMemset(d_u_next, 0, nbytes);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);
    for (int t = 0; t < nt; t++) {
        stencil25_kernel<<<grid, block>>>(d_u, d_u_next, d_vp2, d_u_prev,
                                          nx, ny, nz, c0, c1, c2);
        // Rotate pointers: prev <- u, u <- next
        float* tmp = d_u_prev;
        d_u_prev = d_u;
        d_u = d_u_next;
        d_u_next = tmp;
    }
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float ms;
    cudaEventElapsedTime(&ms, start, stop);
    printf("Total time: %.3f ms (%.4f ms/step)\n", ms, ms / nt);

    double points = (double)n * nt;
    double bw = points * sizeof(float) * 4.0 / (ms * 1e6);  // 4 arrays read/written
    printf("Effective bandwidth: %.2f GB/s\n", bw);

    // Check output is finite
    float *h_result = (float*)malloc(nbytes);
    cudaMemcpy(h_result, d_u, nbytes, cudaMemcpyDeviceToHost);
    int ok = 1;
    for (size_t i = 0; i < n; i++) {
        if (!isfinite(h_result[i])) { ok = 0; break; }
    }
    printf("Result: %s\n", ok ? "PASS (all finite)" : "FAIL (NaN/Inf detected)");

    cudaFree(d_u); cudaFree(d_u_next); cudaFree(d_u_prev); cudaFree(d_vp2);
    free(h_u); free(h_vp2); free(h_result);
    cudaEventDestroy(start); cudaEventDestroy(stop);

    return ok ? 0 : 1;
}
