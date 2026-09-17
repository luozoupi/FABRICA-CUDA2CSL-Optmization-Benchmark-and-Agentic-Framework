/*
 * CUDA Conjugate Gradient: solve Ax = b
 *
 * Translates the CSL kernel from:
 *   sdk-examples/benchmarks/conjugate-gradient/src/kernel_cg.csl
 *
 * CSL approach:
 *   - State machine: SpMV -> residual -> update_p -> SpMV -> eta -> update_x_r
 *   - 7-point stencil SpMV on 2D PE grid
 *   - Allreduce for dot products and norms
 *
 * CUDA approach:
 *   - Dense GEMV kernel for A*x
 *   - Parallel dot product and norm reductions
 *   - Vector update kernels (AXPY-style)
 *   - Standard CG iteration loop
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cuda_runtime.h>

#define BLOCK_SIZE 256

__global__ void gemv_kernel(const float* A, const float* x, float* y, int N) {
    int row = blockIdx.x;
    if (row >= N) return;
    __shared__ float s[BLOCK_SIZE];
    float sum = 0.0f;
    for (int j = threadIdx.x; j < N; j += blockDim.x)
        sum += A[row * N + j] * x[j];
    s[threadIdx.x] = sum;
    __syncthreads();
    for (int k = blockDim.x/2; k > 0; k >>= 1) {
        if (threadIdx.x < k) s[threadIdx.x] += s[threadIdx.x + k];
        __syncthreads();
    }
    if (threadIdx.x == 0) y[row] = s[0];
}

__global__ void dot_kernel(const float* a, const float* b, float* result, int N) {
    __shared__ float s[BLOCK_SIZE];
    float sum = 0.0f;
    for (int i = threadIdx.x; i < N; i += blockDim.x)
        sum += a[i] * b[i];
    s[threadIdx.x] = sum;
    __syncthreads();
    for (int k = blockDim.x/2; k > 0; k >>= 1) {
        if (threadIdx.x < k) s[threadIdx.x] += s[threadIdx.x + k];
        __syncthreads();
    }
    if (threadIdx.x == 0) result[0] = s[0];
}

// r = b - A*x (init), or x = x + alpha*p, r = r - alpha*w
__global__ void axpy_kernel(float* y, const float* x, float alpha, int N) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < N) y[i] += alpha * x[i];
}

// p = r + beta*p
__global__ void update_p_kernel(float* p, const float* r, float beta, int N) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < N) p[i] = r[i] + beta * p[i];
}

// copy: dst = src
__global__ void copy_kernel(float* dst, const float* src, int N) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < N) dst[i] = src[i];
}

int main(int argc, char** argv) {
    int N = 256, max_iter = 200;
    float tol = 1e-6f;
    if (argc > 1) N = atoi(argv[1]);
    if (argc > 2) max_iter = atoi(argv[2]);

    printf("Conjugate Gradient: N=%d, max_iter=%d, tol=%e\n", N, max_iter, tol);

    // Create SPD matrix A = B^T*B + 10*I
    float *h_A = (float*)malloc(N * N * sizeof(float));
    float *h_b = (float*)malloc(N * sizeof(float));
    float *h_x_sol = (float*)malloc(N * sizeof(float));

    srand(42);
    float *B = (float*)malloc(N * N * sizeof(float));
    for (int i = 0; i < N * N; i++) B[i] = (float)rand() / RAND_MAX - 0.5f;
    for (int i = 0; i < N; i++)
        for (int j = 0; j < N; j++) {
            float s = (i == j) ? 10.0f : 0.0f;
            for (int k = 0; k < N; k++) s += B[k*N+i] * B[k*N+j];
            h_A[i*N+j] = s;
        }
    free(B);

    // True solution x_sol, then b = A*x_sol
    for (int i = 0; i < N; i++) h_x_sol[i] = (float)rand() / RAND_MAX;
    for (int i = 0; i < N; i++) {
        float s = 0.0f;
        for (int j = 0; j < N; j++) s += h_A[i*N+j] * h_x_sol[j];
        h_b[i] = s;
    }

    float *d_A, *d_b, *d_x, *d_r, *d_p, *d_w, *d_tmp;
    cudaMalloc(&d_A, N*N*sizeof(float));
    cudaMalloc(&d_b, N*sizeof(float));
    cudaMalloc(&d_x, N*sizeof(float));
    cudaMalloc(&d_r, N*sizeof(float));
    cudaMalloc(&d_p, N*sizeof(float));
    cudaMalloc(&d_w, N*sizeof(float));
    cudaMalloc(&d_tmp, sizeof(float));

    cudaMemcpy(d_A, h_A, N*N*sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b, N*sizeof(float), cudaMemcpyHostToDevice);
    cudaMemset(d_x, 0, N*sizeof(float));

    dim3 vgrid((N + BLOCK_SIZE - 1) / BLOCK_SIZE);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start);

    // r = b - A*x0 (x0 = 0 => r = b)
    cudaMemcpy(d_r, d_b, N*sizeof(float), cudaMemcpyDeviceToDevice);
    // p = r
    cudaMemcpy(d_p, d_r, N*sizeof(float), cudaMemcpyDeviceToDevice);

    float rho, rho_old, eta, alpha, beta;
    dot_kernel<<<1, BLOCK_SIZE>>>(d_r, d_r, d_tmp, N);
    cudaMemcpy(&rho, d_tmp, sizeof(float), cudaMemcpyDeviceToHost);

    int iter;
    for (iter = 0; iter < max_iter; iter++) {
        if (sqrtf(rho) < tol) break;

        // w = A*p
        gemv_kernel<<<N, BLOCK_SIZE>>>(d_A, d_p, d_w, N);

        // eta = p^T * w
        dot_kernel<<<1, BLOCK_SIZE>>>(d_p, d_w, d_tmp, N);
        cudaMemcpy(&eta, d_tmp, sizeof(float), cudaMemcpyDeviceToHost);

        alpha = rho / eta;

        // x = x + alpha*p
        axpy_kernel<<<vgrid, BLOCK_SIZE>>>(d_x, d_p, alpha, N);
        // r = r - alpha*w
        axpy_kernel<<<vgrid, BLOCK_SIZE>>>(d_r, d_w, -alpha, N);

        rho_old = rho;
        dot_kernel<<<1, BLOCK_SIZE>>>(d_r, d_r, d_tmp, N);
        cudaMemcpy(&rho, d_tmp, sizeof(float), cudaMemcpyDeviceToHost);

        beta = rho / rho_old;
        // p = r + beta*p
        update_p_kernel<<<vgrid, BLOCK_SIZE>>>(d_p, d_r, beta, N);
    }

    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    float ms;
    cudaEventElapsedTime(&ms, start, stop);

    printf("Converged in %d iterations, ||r||_2 = %e\n", iter, sqrtf(rho));
    printf("Total time: %.3f ms\n", ms);

    // Verify against true solution
    float *h_x = (float*)malloc(N * sizeof(float));
    cudaMemcpy(h_x, d_x, N*sizeof(float), cudaMemcpyDeviceToHost);
    float max_err = 0.0f, max_val = 0.0f;
    for (int i = 0; i < N; i++) {
        float err = fabsf(h_x[i] - h_x_sol[i]);
        if (err > max_err) max_err = err;
        if (fabsf(h_x_sol[i]) > max_val) max_val = fabsf(h_x_sol[i]);
    }
    float rel_err = max_err / max_val;
    printf("Solution error: max=%e, rel=%e\n", max_err, rel_err);
    printf("Result: %s\n", (rel_err < 1e-3) ? "PASS" : "FAIL");

    cudaFree(d_A); cudaFree(d_b); cudaFree(d_x); cudaFree(d_r);
    cudaFree(d_p); cudaFree(d_w); cudaFree(d_tmp);
    free(h_A); free(h_b); free(h_x_sol); free(h_x);
    cudaEventDestroy(start); cudaEventDestroy(stop);
    return (rel_err < 1e-3) ? 0 : 1;
}
