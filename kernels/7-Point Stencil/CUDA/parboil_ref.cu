/*
 * 7-Point Stencil Reference: Parboil block2D_hybrid_coarsen_x
 * Source: https://github.com/abduld/Parboil/blob/master/benchmarks/stencil/src/cuda/kernels.cu
 * Authors: Li-Wen Chang, I-Jui Sung, Chris Rodrigues (University of Illinois)
 *
 * Optimizations over naive:
 *   - Shared memory for xy-plane data
 *   - Thread coarsening 2x in x-direction (each thread handles 2 cells)
 *   - Register sliding window for z-direction (bottom/top in registers)
 *   - Boundary handling via shared memory vs global memory fallback
 *
 * Stencil: Anext[i,j,k] = (top+bottom+up+down+left+right)*c1 - center*c0
 *   where c0 = 1/6, c1 = 1/36 (standard 7-point Laplacian)
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cuda_runtime.h>

#define Index3D(nx, ny, i, j, k) ((k)*(ny)*(nx) + (j)*(nx) + (i))

/* Parboil stencil kernel: block2D with hybrid coarsening in x
 * Each thread processes 2 x-positions (thread coarsening).
 * Shared memory holds current z-plane; registers hold bottom/top planes.
 */
__global__ void block2D_hybrid_coarsen_x(float c0, float c1,
                                          float *A0, float *Anext,
                                          int nx, int ny, int nz) {
    const int i = blockIdx.x * blockDim.x * 2 + threadIdx.x;
    const int i2 = blockIdx.x * blockDim.x * 2 + threadIdx.x + blockDim.x;
    const int j = blockIdx.y * blockDim.y + threadIdx.y;
    const int sh_id = threadIdx.x + threadIdx.y * blockDim.x * 2;
    const int sh_id2 = threadIdx.x + blockDim.x + threadIdx.y * blockDim.x * 2;

    extern __shared__ float sh_A0[];
    sh_A0[sh_id] = 0.0f;
    sh_A0[sh_id2] = 0.0f;
    __syncthreads();

    const bool w_region = i > 0 && j > 0 && (i < (nx - 1)) && (j < (ny - 1));
    const bool w_region2 = j > 0 && (i2 < nx - 1) && (j < ny - 1);
    const bool x_l_bound = (threadIdx.x == 0);
    const bool x_h_bound = ((threadIdx.x + blockDim.x) == (blockDim.x * 2 - 1));
    const bool y_l_bound = (threadIdx.y == 0);
    const bool y_h_bound = (threadIdx.y == (blockDim.y - 1));

    float bottom = 0.0f, bottom2 = 0.0f, top = 0.0f, top2 = 0.0f;

    if ((i < nx) && (j < ny)) {
        bottom = A0[Index3D(nx, ny, i, j, 0)];
        sh_A0[sh_id] = A0[Index3D(nx, ny, i, j, 1)];
    }
    if ((i2 < nx) && (j < ny)) {
        bottom2 = A0[Index3D(nx, ny, i2, j, 0)];
        sh_A0[sh_id2] = A0[Index3D(nx, ny, i2, j, 1)];
    }
    __syncthreads();

    for (int k = 1; k < nz - 1; k++) {
        float a_left_right, a_up, a_down;

        if ((i < nx) && (j < ny))
            top = A0[Index3D(nx, ny, i, j, k + 1)];

        if (w_region) {
            a_up = y_h_bound ? A0[Index3D(nx, ny, i, j + 1, k)] : sh_A0[sh_id + 2 * blockDim.x];
            a_down = y_l_bound ? A0[Index3D(nx, ny, i, j - 1, k)] : sh_A0[sh_id - 2 * blockDim.x];
            a_left_right = x_l_bound ? A0[Index3D(nx, ny, i - 1, j, k)] : sh_A0[sh_id - 1];
            Anext[Index3D(nx, ny, i, j, k)] = (top + bottom + a_up + a_down + sh_A0[sh_id + 1] + a_left_right) * c1
                                               - sh_A0[sh_id] * c0;
        }

        if ((i2 < nx) && (j < ny))
            top2 = A0[Index3D(nx, ny, i2, j, k + 1)];

        if (w_region2) {
            a_up = y_h_bound ? A0[Index3D(nx, ny, i2, j + 1, k)] : sh_A0[sh_id2 + 2 * blockDim.x];
            a_down = y_l_bound ? A0[Index3D(nx, ny, i2, j - 1, k)] : sh_A0[sh_id2 - 2 * blockDim.x];
            a_left_right = x_h_bound ? A0[Index3D(nx, ny, i2 + 1, j, k)] : sh_A0[sh_id2 + 1];
            Anext[Index3D(nx, ny, i2, j, k)] = (top2 + bottom2 + a_up + a_down + a_left_right + sh_A0[sh_id2 - 1]) * c1
                                                - sh_A0[sh_id2] * c0;
        }

        __syncthreads();
        bottom = sh_A0[sh_id];
        sh_A0[sh_id] = top;
        bottom2 = sh_A0[sh_id2];
        sh_A0[sh_id2] = top2;
        __syncthreads();
    }
}

/* CPU reference for verification */
void stencil_7pt_cpu(const float *A0, float *Anext,
                     float c0, float c1, int nx, int ny, int nz) {
    for (int k = 1; k < nz - 1; k++)
        for (int j = 1; j < ny - 1; j++)
            for (int i = 1; i < nx - 1; i++) {
                Anext[Index3D(nx, ny, i, j, k)] =
                    (A0[Index3D(nx, ny, i, j, k + 1)] +
                     A0[Index3D(nx, ny, i, j, k - 1)] +
                     A0[Index3D(nx, ny, i, j + 1, k)] +
                     A0[Index3D(nx, ny, i, j - 1, k)] +
                     A0[Index3D(nx, ny, i + 1, j, k)] +
                     A0[Index3D(nx, ny, i - 1, j, k)]) * c1
                    - A0[Index3D(nx, ny, i, j, k)] * c0;
            }
}

int main(int argc, char **argv) {
    int N = 128, niter = 10;
    if (argc > 1) N = atoi(argv[1]);
    if (argc > 2) niter = atoi(argv[2]);

    int nx = N, ny = N, nz = N;
    size_t total = (size_t)nx * ny * nz;
    float c0 = 1.0f / 6.0f;
    float c1 = 1.0f / 6.0f / 6.0f;

    printf("Parboil 7-Point Stencil (block2D_hybrid_coarsen_x): %dx%dx%d, %d iterations\n",
           nx, ny, nz, niter);

    float *h_A0 = (float *)malloc(total * sizeof(float));
    float *h_Anext = (float *)malloc(total * sizeof(float));
    float *h_ref = (float *)malloc(total * sizeof(float));

    srand(42);
    for (size_t i = 0; i < total; i++)
        h_A0[i] = (float)rand() / RAND_MAX;
    memcpy(h_Anext, h_A0, total * sizeof(float));
    memcpy(h_ref, h_A0, total * sizeof(float));

    /* CPU reference: single iteration */
    float *cpu_src = (float *)malloc(total * sizeof(float));
    memcpy(cpu_src, h_A0, total * sizeof(float));
    stencil_7pt_cpu(cpu_src, h_ref, c0, c1, nx, ny, nz);

    /* GPU */
    float *d_A0, *d_Anext;
    cudaMalloc(&d_A0, total * sizeof(float));
    cudaMalloc(&d_Anext, total * sizeof(float));
    cudaMemcpy(d_A0, h_A0, total * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_Anext, d_A0, total * sizeof(float), cudaMemcpyDeviceToDevice);

    int tx = 32, ty = 4;
    dim3 block(tx, ty, 1);
    dim3 grid((nx + tx * 2 - 1) / (tx * 2), (ny + ty - 1) / ty, 1);
    int sh_size = tx * 2 * ty * sizeof(float);

    /* Single iteration for correctness */
    block2D_hybrid_coarsen_x<<<grid, block, sh_size>>>(c0, c1, d_A0, d_Anext, nx, ny, nz);
    cudaDeviceSynchronize();

    cudaMemcpy(h_Anext, d_Anext, total * sizeof(float), cudaMemcpyDeviceToHost);

    /* Verify only interior points (boundaries are not updated by stencil) */
    float max_err = 0.0f, max_val = 0.0f;
    for (int k = 1; k < nz - 1; k++)
        for (int j = 1; j < ny - 1; j++)
            for (int i = 1; i < nx - 1; i++) {
                int idx = Index3D(nx, ny, i, j, k);
                float err = fabsf(h_Anext[idx] - h_ref[idx]);
                if (err > max_err) max_err = err;
                if (fabsf(h_ref[idx]) > max_val) max_val = fabsf(h_ref[idx]);
            }
    float rel_err = (max_val > 0) ? max_err / max_val : max_err;
    printf("Correctness: max_err=%e, rel=%e -> %s\n", max_err, rel_err,
           (rel_err < 1e-5) ? "PASS" : "FAIL");

    /* Benchmark: multiple iterations with ping-pong */
    cudaMemcpy(d_A0, h_A0, total * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_Anext, d_A0, total * sizeof(float), cudaMemcpyDeviceToDevice);

    /* Warmup */
    for (int t = 0; t < 3; t++) {
        block2D_hybrid_coarsen_x<<<grid, block, sh_size>>>(c0, c1, d_A0, d_Anext, nx, ny, nz);
        float *tmp = d_A0; d_A0 = d_Anext; d_Anext = tmp;
    }
    cudaDeviceSynchronize();

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);
    for (int t = 0; t < niter; t++) {
        block2D_hybrid_coarsen_x<<<grid, block, sh_size>>>(c0, c1, d_A0, d_Anext, nx, ny, nz);
        float *tmp = d_A0; d_A0 = d_Anext; d_Anext = tmp;
    }
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float ms;
    cudaEventElapsedTime(&ms, start, stop);
    printf("Kernel time: %.4f ms (avg over %d iterations)\n", ms / niter, niter);
    double bytes = 2.0 * total * sizeof(float) * niter;
    printf("Effective bandwidth: %.2f GB/s\n", bytes / (ms * 1e6));

    printf("Result: %s\n", (rel_err < 1e-5) ? "PASS" : "FAIL");

    cudaFree(d_A0); cudaFree(d_Anext);
    free(h_A0); free(h_Anext); free(h_ref); free(cpu_src);
    cudaEventDestroy(start); cudaEventDestroy(stop);
    return (rel_err < 1e-5) ? 0 : 1;
}
