/*
 * CUDA BiCGSTAB: solve Ax = b
 *
 * Translates the CSL kernel from:
 *   sdk-examples/benchmarks/bicgstab/src/kernel_bicgstab.csl
 *
 * CSL approach:
 *   - Complex state machine with ~10 states
 *   - Multiple SpMV operations per iteration (A*p and A*s)
 *   - Multiple allreduce operations for dot products
 *   - 7-point stencil SpMV on 2D PE grid
 *
 * CUDA approach:
 *   - Dense GEMV kernels for A*p and A*s
 *   - Parallel dot product reductions
 *   - AXPY-style vector update kernels
 *   - Standard BiCGSTAB iteration loop
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

// s = r - alpha * v
__global__ void compute_s_kernel(float* s, const float* r, const float* v, float alpha, int N) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < N) s[i] = r[i] - alpha * v[i];
}

// x += alpha*p + omega*s; r = s - omega*t
__global__ void update_x_r_kernel(
    float* x, float* r, const float* p, const float* s, const float* t,
    float alpha, float omega, int N)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < N) {
        x[i] += alpha * p[i] + omega * s[i];
        r[i] = s[i] - omega * t[i];
    }
}

// p = r + beta*(p - omega*v)
__global__ void update_p_kernel(
    float* p, const float* r, const float* v,
    float beta, float omega, int N)
{
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    if (i < N) p[i] = r[i] + beta * (p[i] - omega * v[i]);
}

int main(int argc, char** argv) {
    int N = 256, max_iter = 500;
    float tol = 1e-6f;
    if (argc > 1) N = atoi(argv[1]);
    if (argc > 2) max_iter = atoi(argv[2]);

    printf("BiCGSTAB: N=%d, max_iter=%d, tol=%e\n", N, max_iter, tol);

    float *h_A = (float*)malloc(N * N * sizeof(float));
    float *h_b = (float*)malloc(N * sizeof(float));
    float *h_x_sol = (float*)malloc(N * sizeof(float));

    srand(42);
    // SPD matrix: A = B^T*B + 10*I
    float *B = (float*)malloc(N * N * sizeof(float));
    for (int i = 0; i < N * N; i++) B[i] = (float)rand() / RAND_MAX - 0.5f;
    for (int i = 0; i < N; i++)
        for (int j = 0; j < N; j++) {
            float s = (i == j) ? 10.0f : 0.0f;
            for (int k = 0; k < N; k++) s += B[k*N+i] * B[k*N+j];
            h_A[i*N+j] = s;
        }
    free(B);

    for (int i = 0; i < N; i++) h_x_sol[i] = (float)rand() / RAND_MAX;
    for (int i = 0; i < N; i++) {
        float s = 0.0f;
        for (int j = 0; j < N; j++) s += h_A[i*N+j] * h_x_sol[j];
        h_b[i] = s;
    }

    // Allocate device: A, b, x, r, r0, p, v, s, t, tmp (scalars)
    float *d_A, *d_b, *d_x, *d_r, *d_r0, *d_p, *d_v, *d_s, *d_t, *d_tmp;
    cudaMalloc(&d_A, N*N*sizeof(float));
    cudaMalloc(&d_b, N*sizeof(float));
    cudaMalloc(&d_x, N*sizeof(float));
    cudaMalloc(&d_r, N*sizeof(float));
    cudaMalloc(&d_r0, N*sizeof(float));
    cudaMalloc(&d_p, N*sizeof(float));
    cudaMalloc(&d_v, N*sizeof(float));
    cudaMalloc(&d_s, N*sizeof(float));
    cudaMalloc(&d_t, N*sizeof(float));
    cudaMalloc(&d_tmp, sizeof(float));

    cudaMemcpy(d_A, h_A, N*N*sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_b, h_b, N*sizeof(float), cudaMemcpyHostToDevice);
    cudaMemset(d_x, 0, N*sizeof(float));

    dim3 vgrid((N + BLOCK_SIZE - 1) / BLOCK_SIZE);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);
    cudaEventRecord(start);

    // r = b (x0=0), r0 = r, p = r
    cudaMemcpy(d_r, d_b, N*sizeof(float), cudaMemcpyDeviceToDevice);
    cudaMemcpy(d_r0, d_r, N*sizeof(float), cudaMemcpyDeviceToDevice);
    cudaMemcpy(d_p, d_r, N*sizeof(float), cudaMemcpyDeviceToDevice);

    float rho, rho_old, alpha, omega, r0v, ts, tt, xi;

    // rho = (r0, r)
    dot_kernel<<<1, BLOCK_SIZE>>>(d_r0, d_r, d_tmp, N);
    cudaMemcpy(&rho, d_tmp, sizeof(float), cudaMemcpyDeviceToHost);

    // xi = ||r||^2
    dot_kernel<<<1, BLOCK_SIZE>>>(d_r, d_r, d_tmp, N);
    cudaMemcpy(&xi, d_tmp, sizeof(float), cudaMemcpyDeviceToHost);

    int iter;
    for (iter = 0; iter < max_iter; iter++) {
        if (sqrtf(xi) < tol) break;

        // v = A*p
        gemv_kernel<<<N, BLOCK_SIZE>>>(d_A, d_p, d_v, N);

        // alpha = rho / (r0, v)
        dot_kernel<<<1, BLOCK_SIZE>>>(d_r0, d_v, d_tmp, N);
        cudaMemcpy(&r0v, d_tmp, sizeof(float), cudaMemcpyDeviceToHost);
        alpha = rho / r0v;

        // s = r - alpha*v
        compute_s_kernel<<<vgrid, BLOCK_SIZE>>>(d_s, d_r, d_v, alpha, N);

        // t = A*s
        gemv_kernel<<<N, BLOCK_SIZE>>>(d_A, d_s, d_t, N);

        // omega = (t,s)/(t,t)
        dot_kernel<<<1, BLOCK_SIZE>>>(d_t, d_s, d_tmp, N);
        cudaMemcpy(&ts, d_tmp, sizeof(float), cudaMemcpyDeviceToHost);
        dot_kernel<<<1, BLOCK_SIZE>>>(d_t, d_t, d_tmp, N);
        cudaMemcpy(&tt, d_tmp, sizeof(float), cudaMemcpyDeviceToHost);
        omega = ts / tt;

        // x += alpha*p + omega*s; r = s - omega*t
        update_x_r_kernel<<<vgrid, BLOCK_SIZE>>>(d_x, d_r, d_p, d_s, d_t, alpha, omega, N);

        rho_old = rho;
        // rho = (r0, r)
        dot_kernel<<<1, BLOCK_SIZE>>>(d_r0, d_r, d_tmp, N);
        cudaMemcpy(&rho, d_tmp, sizeof(float), cudaMemcpyDeviceToHost);

        // xi = ||r||^2
        dot_kernel<<<1, BLOCK_SIZE>>>(d_r, d_r, d_tmp, N);
        cudaMemcpy(&xi, d_tmp, sizeof(float), cudaMemcpyDeviceToHost);

        float beta = (rho / rho_old) * (alpha / omega);
        // p = r + beta*(p - omega*v)
        update_p_kernel<<<vgrid, BLOCK_SIZE>>>(d_p, d_r, d_v, beta, omega, N);
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
    cudaFree(d_r0); cudaFree(d_p); cudaFree(d_v); cudaFree(d_s);
    cudaFree(d_t); cudaFree(d_tmp);
    free(h_A); free(h_b); free(h_x_sol); free(h_x);
    cudaEventDestroy(start); cudaEventDestroy(stop);
    return (rel_err < 1e-3) ? 0 : 1;
}
