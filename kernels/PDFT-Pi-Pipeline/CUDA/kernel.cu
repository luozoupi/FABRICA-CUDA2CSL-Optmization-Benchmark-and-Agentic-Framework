/*
 * PDFT on-top pair-density pipeline (program-level, 3 chained kernels).
 *
 * Ported/simplified from the PDFT pair-density kernels in the GPU-accelerated
 * quantum-chemistry package MatthewRHermes/mrh (gpu/src/pm/device_cuda.cpp:
 * _make_gridkern, _make_buf_pdft, _make_Pi_final). Multiconfiguration
 * pair-density functional theory needs the on-top pair density Pi at each real-
 * space grid point, which is a quadratic form in the active-space (CAS) molecular
 * orbital values evaluated on the grid, weighted by the CAS two-body cumulant.
 *
 * Self-contained, verifiable core:
 *   inputs:  mo_grid[ngrid][ncas]   (CAS MO values at each grid point)
 *            cascm2 [ncas*ncas][ncas*ncas]  (2-RDM-like weight matrix, here a
 *                                            dense [ncas^2 x ncas^2] for a clean
 *                                            general contraction)
 *   output:  Pi[ngrid]
 *
 * Per grid point g, with the outer-product feature vector
 *   gridkern[g][j*ncas+k] = mo_grid[g][j] * mo_grid[g][k]   (length ncas^2)
 * the on-top pair density is the quadratic form
 *   Pi[g] = sum_{a,b} gridkern[g][a] * cascm2[a][b] * gridkern[g][b]
 *
 * Computed as a PROGRAM of three data-dependent stages (stage N reads the buffer
 * written by stage N-1) — the program-level benchmark axis:
 *   Stage 1 (make_gridkern):  gridkern[g][a] = mo[g][j]*mo[g][k]   (outer product)
 *   Stage 2 (make_buf):       buf[g][b]      = sum_a gridkern[g][a]*cascm2[a][b]
 *   Stage 3 (make_Pi_final):  Pi[g]          = sum_b gridkern[g][b]*buf[g][b]
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cuda_runtime.h>

// Stage 1: per-grid outer product of the MO vector -> gridkern (length ncas^2).
__global__ void make_gridkern(
    const float* __restrict__ mo_grid,  // [ngrid][ncas]
    float* __restrict__ gridkern,       // [ngrid][ncas*ncas]
    int ngrid, int ncas)
{
    int g = blockIdx.x * blockDim.x + threadIdx.x;
    if (g >= ngrid) return;
    const float* mo = mo_grid + g * ncas;
    float* gk = gridkern + g * ncas * ncas;
    for (int j = 0; j < ncas; j++)
        for (int k = 0; k < ncas; k++)
            gk[j * ncas + k] = mo[j] * mo[k];
}

// Stage 2: contract gridkern with the weight matrix -> buf (length ncas^2).
//   buf[g][b] = sum_a gridkern[g][a] * cascm2[a][b]
__global__ void make_buf(
    const float* __restrict__ gridkern, // [ngrid][ncas2]
    const float* __restrict__ cascm2,   // [ncas2][ncas2]
    float* __restrict__ buf,            // [ngrid][ncas2]
    int ngrid, int ncas2)
{
    int g = blockIdx.x * blockDim.x + threadIdx.x;
    if (g >= ngrid) return;
    const float* gk = gridkern + g * ncas2;
    float* bf = buf + g * ncas2;
    for (int b = 0; b < ncas2; b++) {
        float s = 0.0f;
        for (int a = 0; a < ncas2; a++)
            s += gk[a] * cascm2[a * ncas2 + b];
        bf[b] = s;
    }
}

// Stage 3: reduce gridkern . buf -> Pi (scalar per grid point).
//   Pi[g] = sum_b gridkern[g][b] * buf[g][b]
__global__ void make_Pi_final(
    const float* __restrict__ gridkern, // [ngrid][ncas2]
    const float* __restrict__ buf,      // [ngrid][ncas2]
    float* __restrict__ Pi,             // [ngrid]
    int ngrid, int ncas2)
{
    int g = blockIdx.x * blockDim.x + threadIdx.x;
    if (g >= ngrid) return;
    const float* gk = gridkern + g * ncas2;
    const float* bf = buf + g * ncas2;
    float s = 0.0f;
    for (int b = 0; b < ncas2; b++)
        s += gk[b] * bf[b];
    Pi[g] = s;
}

int main(int argc, char** argv) {
    int ngrid = 16, ncas = 4;
    if (argc > 2) { ngrid = atoi(argv[1]); ncas = atoi(argv[2]); }
    int ncas2 = ncas * ncas;

    printf("PDFT Pi pipeline: ngrid=%d ncas=%d (ncas^2=%d)\n", ngrid, ncas, ncas2);

    size_t sz_mo = ngrid * ncas * sizeof(float);
    size_t sz_gk = ngrid * ncas2 * sizeof(float);
    size_t sz_w  = ncas2 * ncas2 * sizeof(float);
    size_t sz_pi = ngrid * sizeof(float);

    float *h_mo = (float*)malloc(sz_mo);
    float *h_w  = (float*)malloc(sz_w);
    float *h_pi = (float*)malloc(sz_pi);
    float *h_ref = (float*)malloc(sz_pi);

    srand(11);
    for (int i = 0; i < ngrid * ncas; i++) h_mo[i] = (float)rand() / RAND_MAX - 0.5f;
    for (int i = 0; i < ncas2 * ncas2; i++) h_w[i] = (float)rand() / RAND_MAX - 0.5f;

    // Host reference: Pi[g] = k_g^T W k_g, k_g = outer(mo_g, mo_g)
    for (int g = 0; g < ngrid; g++) {
        float* k = (float*)malloc(sz_gk / ngrid);
        for (int j = 0; j < ncas; j++)
            for (int kk = 0; kk < ncas; kk++)
                k[j * ncas + kk] = h_mo[g * ncas + j] * h_mo[g * ncas + kk];
        float pi = 0.0f;
        for (int a = 0; a < ncas2; a++)
            for (int b = 0; b < ncas2; b++)
                pi += k[a] * h_w[a * ncas2 + b] * k[b];
        h_ref[g] = pi;
        free(k);
    }

    float *d_mo, *d_gk, *d_w, *d_buf, *d_pi;
    cudaMalloc(&d_mo, sz_mo);
    cudaMalloc(&d_gk, sz_gk);
    cudaMalloc(&d_w, sz_w);
    cudaMalloc(&d_buf, sz_gk);
    cudaMalloc(&d_pi, sz_pi);
    cudaMemcpy(d_mo, h_mo, sz_mo, cudaMemcpyHostToDevice);
    cudaMemcpy(d_w, h_w, sz_w, cudaMemcpyHostToDevice);

    int block = 64;
    int grid = (ngrid + block - 1) / block;
    // The PROGRAM: three data-dependent stages, sharing device buffers.
    make_gridkern<<<grid, block>>>(d_mo, d_gk, ngrid, ncas);
    make_buf<<<grid, block>>>(d_gk, d_w, d_buf, ngrid, ncas2);
    make_Pi_final<<<grid, block>>>(d_gk, d_buf, d_pi, ngrid, ncas2);
    cudaMemcpy(h_pi, d_pi, sz_pi, cudaMemcpyDeviceToHost);

    float max_err = 0, max_val = 0;
    for (int g = 0; g < ngrid; g++) {
        float e = fabsf(h_pi[g] - h_ref[g]);
        if (e > max_err) max_err = e;
        if (fabsf(h_ref[g]) > max_val) max_val = fabsf(h_ref[g]);
    }
    printf("max_err=%e rel=%e -> %s\n", max_err, max_err / max_val,
           (max_err / max_val < 1e-4) ? "PASS" : "FAIL");

    cudaFree(d_mo); cudaFree(d_gk); cudaFree(d_w); cudaFree(d_buf); cudaFree(d_pi);
    free(h_mo); free(h_w); free(h_pi); free(h_ref);
    return 0;
}
