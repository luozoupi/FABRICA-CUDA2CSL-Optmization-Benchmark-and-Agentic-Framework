/*
 * Conjugate Gradient Reference: CG-CUDA by Tim Lebailly
 * Source: https://github.com/tileb1/CG-CUDA
 * Author: Tim Lebailly
 *
 * Optimizations over naive:
 *   - Shared-memory tiled matVec2: coalesced access via symmetric matrix transpose trick
 *   - Parallel dot product (vecVec2): per-block shared-memory reduction + atomicAdd
 *   - All scalar operations done on-device (divide kernel) to avoid CPU-GPU transfers
 *   - Separate kernel for each CG operation
 *
 * Solves Ax = b where A is symmetric positive definite.
 * Made standalone: no external headers, configurable N, cudaEvent timing, PASS/FAIL.
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cuda_runtime.h>

/* CG-CUDA constants */
#define BLOCK_DIM_VEC 32
#define NB_ELEM_MAT 32
#define BLOCK_SIZE_MAT 32

#define EPS 1e-14f
#define MAX_ITER 1000

/*
 * Efficient symmetric matVec: shared memory for vector tile,
 * atomicAdd partial results. Exploits symmetry for coalesced access.
 * From CG-CUDA matVec2.
 */
__global__ void matVec2(float *A, float *b, float *out, int N) {
    __shared__ float b_shared[NB_ELEM_MAT];
    int effective_block_width;
    if ((blockIdx.x + 1) * NB_ELEM_MAT <= N)
        effective_block_width = NB_ELEM_MAT;
    else
        effective_block_width = N % NB_ELEM_MAT;

    if (threadIdx.x < effective_block_width)
        b_shared[threadIdx.x] = b[blockIdx.x * NB_ELEM_MAT + threadIdx.x];
    __syncthreads();

    int idy = blockIdx.y * BLOCK_SIZE_MAT + threadIdx.x;
    float tmp_scal = 0.0f;
    if (idy < N) {
        for (int i = 0; i < effective_block_width; i++)
            tmp_scal += b_shared[i] * A[(blockIdx.x * NB_ELEM_MAT + i) * N + idy];
        atomicAdd(out + idy, tmp_scal);
    }
}

/*
 * Parallel dot product with per-block reduction + atomicAdd.
 * From CG-CUDA vecVec2.
 */
__global__ void vecVec2(float *a, float *b, float *out, int N) {
    __shared__ float shared_tmp[BLOCK_DIM_VEC];
    if (threadIdx.x + blockDim.x * blockIdx.x == 0)
        *out = 0.0f;

    if (blockIdx.x * blockDim.x + threadIdx.x < N)
        shared_tmp[threadIdx.x] = a[blockIdx.x * blockDim.x + threadIdx.x]
                                  * b[blockIdx.x * blockDim.x + threadIdx.x];
    else
        shared_tmp[threadIdx.x] = 0.0f;

    for (int i = blockDim.x / 2; i >= 1; i /= 2) {
        __syncthreads();
        if (threadIdx.x < i)
            shared_tmp[threadIdx.x] += shared_tmp[threadIdx.x + i];
    }
    if (threadIdx.x == 0)
        atomicAdd(out, shared_tmp[0]);
}

__global__ void vecPlusVec(float *a, float *b, float *out, int N) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < N) out[i] = b[i] + a[i];
}

__global__ void vecPlusVec2(float *a, float *b, float *out, int N) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < N) { out[i] = b[i] + a[i]; b[i] = 0.0f; }
}

__global__ void vecMinVec(float *a, float *b, float *out, int N) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < N) out[i] = a[i] - b[i];
}

__global__ void scalarVec(float *scalar, float *a, float *out, int N) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < N) out[i] = a[i] * (*scalar);
}

__global__ void memCopy(float *in, float *out, int N) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < N) out[i] = in[i];
}

__global__ void divide(float *num, float *den, float *out) {
    if (threadIdx.x == 0 && blockIdx.x == 0)
        *out = *num / *den;
}

/* Generate SPD matrix A = random symmetric + N*I */
void generateSPD(float *A, int N) {
    for (int i = 0; i < N; i++) {
        for (int j = 0; j <= i; j++) {
            float val = (float)rand() / RAND_MAX;
            if (i == j)
                A[i * N + j] = val + N;
            else {
                A[i * N + j] = val;
                A[j * N + i] = val;
            }
        }
    }
}

int main(int argc, char **argv) {
    int N = 512;
    if (argc > 1) N = atoi(argv[1]);

    printf("CG-CUDA (Tim Lebailly): Solve Ax=b, N=%d\n", N);

    srand(42);
    float *h_A = (float *)malloc(N * N * sizeof(float));
    float *h_b = (float *)malloc(N * sizeof(float));
    float *h_x = (float *)calloc(N, sizeof(float));
    float h_r_norm = 1.0f;

    generateSPD(h_A, N);
    for (int i = 0; i < N; i++)
        h_b[i] = (float)rand() / RAND_MAX;

    /* CPU reference solution (sequential CG) */
    float *x_ref = (float *)calloc(N, sizeof(float));
    float *r_cpu = (float *)malloc(N * sizeof(float));
    float *p_cpu = (float *)malloc(N * sizeof(float));
    float *tmp_cpu = (float *)malloc(N * sizeof(float));

    /* r = b - A*x0 = b (since x0=0) */
    for (int i = 0; i < N; i++) { r_cpu[i] = h_b[i]; p_cpu[i] = h_b[i]; }
    float rNormOld = 0.0f;
    for (int i = 0; i < N; i++) rNormOld += r_cpu[i] * r_cpu[i];
    float rNorm = 1.0f;
    int cpu_iters = 0;
    while (rNorm > EPS && cpu_iters < MAX_ITER) {
        /* tmp = A*p */
        for (int i = 0; i < N; i++) {
            tmp_cpu[i] = 0;
            for (int j = 0; j < N; j++) tmp_cpu[i] += h_A[i * N + j] * p_cpu[j];
        }
        float pAp = 0;
        for (int i = 0; i < N; i++) pAp += p_cpu[i] * tmp_cpu[i];
        float alpha = rNormOld / pAp;
        for (int i = 0; i < N; i++) { r_cpu[i] -= alpha * tmp_cpu[i]; x_ref[i] += alpha * p_cpu[i]; }
        rNorm = 0;
        for (int i = 0; i < N; i++) rNorm += r_cpu[i] * r_cpu[i];
        float beta = rNorm / rNormOld;
        for (int i = 0; i < N; i++) p_cpu[i] = r_cpu[i] + beta * p_cpu[i];
        rNormOld = rNorm;
        cpu_iters++;
    }
    free(r_cpu); free(p_cpu); free(tmp_cpu);

    /* GPU CG */
    float *d_A, *d_b, *d_x, *d_p, *d_r, *d_temp;
    float *d_alpha, *d_beta, *d_r_norm, *d_r_norm_old, *d_temp_scal;
    cudaMalloc(&d_A, N * N * sizeof(float));
    cudaMalloc(&d_b, N * sizeof(float));
    cudaMalloc(&d_x, N * sizeof(float));
    cudaMalloc(&d_p, N * sizeof(float));
    cudaMalloc(&d_r, N * sizeof(float));
    cudaMalloc(&d_temp, N * sizeof(float));
    cudaMalloc(&d_alpha, sizeof(float));
    cudaMalloc(&d_beta, sizeof(float));
    cudaMalloc(&d_r_norm, sizeof(float));
    cudaMalloc(&d_r_norm_old, sizeof(float));
    cudaMalloc(&d_temp_scal, sizeof(float));

    cudaMemcpy(d_A, h_A, N * N * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b, N * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemset(d_x, 0, N * sizeof(float));
    cudaMemcpy(d_p, h_b, N * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_r, h_b, N * sizeof(float), cudaMemcpyHostToDevice);

    dim3 vec_block(BLOCK_DIM_VEC);
    dim3 vec_grid((N + BLOCK_DIM_VEC - 1) / BLOCK_DIM_VEC);
    dim3 mat_grid((N + NB_ELEM_MAT - 1) / NB_ELEM_MAT, (N + BLOCK_SIZE_MAT - 1) / BLOCK_SIZE_MAT);
    dim3 mat_block(BLOCK_SIZE_MAT);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    vecVec2<<<vec_grid, vec_block>>>(d_r, d_r, d_r_norm_old, N);

    h_r_norm = 1.0f;
    int k = 0;

    cudaEventRecord(start);
    while ((k < MAX_ITER) && (h_r_norm > EPS)) {
        /* temp = A*p (zero temp first) */
        cudaMemset(d_temp, 0, N * sizeof(float));
        matVec2<<<mat_grid, mat_block>>>(d_A, d_p, d_temp, N);

        vecVec2<<<vec_grid, vec_block>>>(d_p, d_temp, d_temp_scal, N);
        divide<<<1, 1>>>(d_r_norm_old, d_temp_scal, d_alpha);

        scalarVec<<<vec_grid, vec_block>>>(d_alpha, d_temp, d_temp, N);
        vecMinVec<<<vec_grid, vec_block>>>(d_r, d_temp, d_r, N);

        scalarVec<<<vec_grid, vec_block>>>(d_alpha, d_p, d_temp, N);
        vecPlusVec<<<vec_grid, vec_block>>>(d_x, d_temp, d_x, N);

        vecVec2<<<vec_grid, vec_block>>>(d_r, d_r, d_r_norm, N);
        divide<<<1, 1>>>(d_r_norm, d_r_norm_old, d_beta);

        scalarVec<<<vec_grid, vec_block>>>(d_beta, d_p, d_temp, N);
        vecPlusVec2<<<vec_grid, vec_block>>>(d_r, d_temp, d_p, N);

        memCopy<<<1, 1>>>(d_r_norm, d_r_norm_old, 1);
        cudaMemcpy(&h_r_norm, d_r_norm, sizeof(float), cudaMemcpyDeviceToHost);
        k++;
    }
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float ms;
    cudaEventElapsedTime(&ms, start, stop);
    printf("GPU converged in %d iterations, ||r||^2 = %e\n", k, h_r_norm);
    printf("Kernel time: %.4f ms\n", ms);

    /* Verify against CPU solution */
    cudaMemcpy(h_x, d_x, N * sizeof(float), cudaMemcpyDeviceToHost);
    float max_err = 0.0f, max_val = 0.0f;
    for (int i = 0; i < N; i++) {
        float err = fabsf(h_x[i] - x_ref[i]);
        if (err > max_err) max_err = err;
        if (fabsf(x_ref[i]) > max_val) max_val = fabsf(x_ref[i]);
    }
    float rel = (max_val > 0) ? max_err / max_val : max_err;
    printf("Max error vs CPU CG: %e, relative: %e\n", max_err, rel);
    printf("Result: %s\n", (rel < 1e-3) ? "PASS" : "FAIL");

    cudaFree(d_A); cudaFree(d_b); cudaFree(d_x); cudaFree(d_p);
    cudaFree(d_r); cudaFree(d_temp);
    cudaFree(d_alpha); cudaFree(d_beta);
    cudaFree(d_r_norm); cudaFree(d_r_norm_old); cudaFree(d_temp_scal);
    free(h_A); free(h_b); free(h_x); free(x_ref);
    cudaEventDestroy(start); cudaEventDestroy(stop);
    return (rel < 1e-3) ? 0 : 1;
}
