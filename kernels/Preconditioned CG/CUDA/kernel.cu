/*
 * CUDA Preconditioned Conjugate Gradient: solve Ax = b with Jacobi preconditioner
 *
 * Translates the CSL kernel from:
 *   sdk-examples/benchmarks/preconditioned-conjugate-gradient/src/kernel_pcg.csl
 *
 * CSL approach:
 *   - State machine: SpMV -> residual -> precond_solve -> update_p -> SpMV -> eta -> update
 *   - Jacobi preconditioner M = diag(A), z = M^{-1}*r
 *   - 7-point stencil SpMV on 2D PE grid with allreduce
 *
 * CUDA approach:
 *   - Dense GEMV for A*x
 *   - Element-wise division for Jacobi preconditioning (z = D^{-1} * r)
 *   - Parallel dot products and AXPY kernels
 *   - Standard PCG iteration loop
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
    for (int i = threadIdx.x; i < N; i += blockDim.x) sum += a[i] * b[i];
    s[threadIdx.x] = sum;
    __syncthreads();
    for (int k = blockDim.x/2; k > 0; k >>= 1) {
        if (threadIdx.x < k) s[threadIdx.x] += s[threadIdx.x + k];
        __syncthreads();
    }
    if (threadIdx.x == 0) result[0] = s[0];
}

__global__ void axpy_kernel(float* y, const float* x, float alpha, int N) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < N) y[i] += alpha * x[i];
}

__global__ void update_p_kernel(float* p, const float* z, float beta, int N) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < N) p[i] = z[i] + beta * p[i];
}

// Jacobi preconditioner: z = D^{-1} * r
__global__ void jacobi_precond_kernel(
    float* z, const float* r, const float* inv_diag, int N)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < N) z[i] = inv_diag[i] * r[i];
}

int main(int argc, char** argv) {
    int N = 256, max_iter = 500;
    float tol = 1e-6f;
    if (argc > 1) N = atoi(argv[1]);
    if (argc > 2) max_iter = atoi(argv[2]);

    printf("Preconditioned CG (Jacobi): N=%d, max_iter=%d, tol=%e\n", N, max_iter, tol);

    float *h_A = (float*)malloc(N * N * sizeof(float));
    float *h_b = (float*)malloc(N * sizeof(float));
    float *h_x_sol = (float*)malloc(N * sizeof(float));
    float *h_inv_diag = (float*)malloc(N * sizeof(float));

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

    // Precompute inverse diagonal for Jacobi
    for (int i = 0; i < N; i++) h_inv_diag[i] = 1.0f / h_A[i*N+i];

    // True solution and RHS
    for (int i = 0; i < N; i++) h_x_sol[i] = (float)rand() / RAND_MAX;
    for (int i = 0; i < N; i++) {
        float s = 0.0f;
        for (int j = 0; j < N; j++) s += h_A[i*N+j] * h_x_sol[j];
        h_b[i] = s;
    }

    float *d_A, *d_b, *d_x, *d_r, *d_z, *d_p, *d_w, *d_inv_diag, *d_tmp;
    cudaMalloc(&d_A, N*N*sizeof(float));
    cudaMalloc(&d_b, N*sizeof(float));
    cudaMalloc(&d_x, N*sizeof(float));
    cudaMalloc(&d_r, N*sizeof(float));
    cudaMalloc(&d_z, N*sizeof(float));
    cudaMalloc(&d_p, N*sizeof(float));
    cudaMalloc(&d_w, N*sizeof(float));
    cudaMalloc(&d_inv_diag, N*sizeof(float));
    cudaMalloc(&d_tmp, sizeof(float));

    cudaMemcpy(d_A, h_A, N*N*sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b, N*sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_inv_diag, h_inv_diag, N*sizeof(float), cudaMemcpyHostToDevice);
    cudaMemset(d_x, 0, N*sizeof(float));

    dim3 vgrid((N + BLOCK_SIZE - 1) / BLOCK_SIZE);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start);

    // r = b (since x0 = 0)
    cudaMemcpy(d_r, d_b, N*sizeof(float), cudaMemcpyDeviceToDevice);

    // z = M^{-1} r
    jacobi_precond_kernel<<<vgrid, BLOCK_SIZE>>>(d_z, d_r, d_inv_diag, N);

    // p = z
    cudaMemcpy(d_p, d_z, N*sizeof(float), cudaMemcpyDeviceToDevice);

    float rho, rho_old, eta, alpha, beta, xi;

    // rho = r^T z
    dot_kernel<<<1, BLOCK_SIZE>>>(d_r, d_z, d_tmp, N);
    cudaMemcpy(&rho, d_tmp, sizeof(float), cudaMemcpyDeviceToHost);

    // xi = r^T r (for convergence check)
    dot_kernel<<<1, BLOCK_SIZE>>>(d_r, d_r, d_tmp, N);
    cudaMemcpy(&xi, d_tmp, sizeof(float), cudaMemcpyDeviceToHost);

    int iter;
    for (iter = 0; iter < max_iter; iter++) {
        if (sqrtf(xi) < tol) break;

        // w = A*p
        gemv_kernel<<<N, BLOCK_SIZE>>>(d_A, d_p, d_w, N);

        // eta = p^T w
        dot_kernel<<<1, BLOCK_SIZE>>>(d_p, d_w, d_tmp, N);
        cudaMemcpy(&eta, d_tmp, sizeof(float), cudaMemcpyDeviceToHost);

        alpha = rho / eta;

        // x += alpha*p
        axpy_kernel<<<vgrid, BLOCK_SIZE>>>(d_x, d_p, alpha, N);
        // r -= alpha*w
        axpy_kernel<<<vgrid, BLOCK_SIZE>>>(d_r, d_w, -alpha, N);

        // z = M^{-1} r
        jacobi_precond_kernel<<<vgrid, BLOCK_SIZE>>>(d_z, d_r, d_inv_diag, N);

        rho_old = rho;
        // rho = r^T z
        dot_kernel<<<1, BLOCK_SIZE>>>(d_r, d_z, d_tmp, N);
        cudaMemcpy(&rho, d_tmp, sizeof(float), cudaMemcpyDeviceToHost);

        // xi = r^T r
        dot_kernel<<<1, BLOCK_SIZE>>>(d_r, d_r, d_tmp, N);
        cudaMemcpy(&xi, d_tmp, sizeof(float), cudaMemcpyDeviceToHost);

        beta = rho / rho_old;
        update_p_kernel<<<vgrid, BLOCK_SIZE>>>(d_p, d_z, beta, N);
    }

    cudaEventRecord(stop);
    cudaEventSynchronize(stop);
    float ms;
    cudaEventElapsedTime(&ms, start, stop);

    printf("Converged in %d iterations, ||r||_2 = %e\n", iter, sqrtf(xi));
    printf("Total time: %.3f ms\n", ms);

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
    cudaFree(d_z); cudaFree(d_p); cudaFree(d_w);
    cudaFree(d_inv_diag); cudaFree(d_tmp);
    free(h_A); free(h_b); free(h_x_sol); free(h_x); free(h_inv_diag);
    cudaEventDestroy(start); cudaEventDestroy(stop);
    return (rel_err < 1e-3) ? 0 : 1;
}
