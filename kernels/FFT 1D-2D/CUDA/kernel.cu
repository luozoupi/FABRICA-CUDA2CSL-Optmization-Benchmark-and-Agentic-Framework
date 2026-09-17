/*
 * CUDA 1D/2D FFT (Cooley-Tukey radix-2)
 *
 * Translates the CSL kernel from:
 *   sdk-examples/benchmarks/fft-1d-2d/fft.csl
 *
 * CSL approach:
 *   - Cooley-Tukey decimation-in-frequency FFT
 *   - Twiddle factor multiplication on odd elements
 *   - Butterfly: even = even + odd*tw, odd = even - odd*tw
 *   - Reshape for bit-reversal reordering between stages
 *   - 2D FFT = row-wise 1D FFT + column-wise 1D FFT
 *
 * CUDA approach:
 *   - Iterative Cooley-Tukey radix-2 DIT FFT
 *   - One thread per butterfly operation
 *   - 2D FFT via row-wise then column-wise 1D transforms
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cuda_runtime.h>

#define BLOCK_SIZE 256

// Complex multiply: (a+bi)*(c+di) = (ac-bd) + (ad+bc)i
__device__ void cmul(float ar, float ai, float br, float bi, float *cr, float *ci) {
    *cr = ar * br - ai * bi;
    *ci = ar * bi + ai * br;
}

// In-place radix-2 Cooley-Tukey FFT butterfly kernel
// Each thread handles one butterfly pair per stage
__global__ void fft_butterfly(float *real, float *imag, int N, int half_size, int step) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    if (tid >= N / 2) return;

    // Determine which butterfly group and position within group
    int group = tid / half_size;
    int pos = tid % half_size;

    int i = group * step + pos;
    int j = i + half_size;

    // Twiddle factor: W_N^k = exp(-2*pi*i*k/step)
    float angle = -2.0f * M_PI * pos / step;
    float tw_r = cosf(angle);
    float tw_i = sinf(angle);

    // Multiply odd element by twiddle
    float tr, ti;
    cmul(real[j], imag[j], tw_r, tw_i, &tr, &ti);

    // Butterfly
    float ur = real[i], ui = imag[i];
    real[i] = ur + tr;
    imag[i] = ui + ti;
    real[j] = ur - tr;
    imag[j] = ui - ti;
}

// Bit-reversal permutation kernel
__global__ void bit_reverse(float *real, float *imag, float *real_out, float *imag_out,
                            int N, int log2N) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    if (tid >= N) return;

    int rev = 0;
    int val = tid;
    for (int i = 0; i < log2N; i++) {
        rev = (rev << 1) | (val & 1);
        val >>= 1;
    }

    real_out[rev] = real[tid];
    imag_out[rev] = imag[tid];
}

// Negate imaginary part kernel
__global__ void negate_imag(float *imag, int N) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    if (tid < N) imag[tid] = -imag[tid];
}

// Scale kernel
__global__ void scale_array(float *arr, int N, float s) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    if (tid < N) arr[tid] *= s;
}

// Host-side 1D FFT (forward) or IFFT (inverse)
// IFFT = conjugate, forward FFT, conjugate, scale by 1/N
void fft_1d(float *d_real, float *d_imag, float *d_tmp_r, float *d_tmp_i, int N, int inverse) {
    int log2N = 0;
    for (int t = N; t > 1; t >>= 1) log2N++;
    dim3 grid((N + BLOCK_SIZE - 1) / BLOCK_SIZE);

    // For IFFT: conjugate input (negate imaginary)
    if (inverse)
        negate_imag<<<grid, BLOCK_SIZE>>>(d_imag, N);

    // Bit-reversal
    bit_reverse<<<grid, BLOCK_SIZE>>>(d_real, d_imag, d_tmp_r, d_tmp_i, N, log2N);
    cudaMemcpy(d_real, d_tmp_r, N * sizeof(float), cudaMemcpyDeviceToDevice);
    cudaMemcpy(d_imag, d_tmp_i, N * sizeof(float), cudaMemcpyDeviceToDevice);

    // Butterfly stages
    dim3 grid_half((N / 2 + BLOCK_SIZE - 1) / BLOCK_SIZE);
    for (int s = 1; s <= log2N; s++) {
        int step = 1 << s;
        int half = step >> 1;
        fft_butterfly<<<grid_half, BLOCK_SIZE>>>(d_real, d_imag, N, half, step);
    }

    // For IFFT: conjugate output and scale by 1/N
    if (inverse) {
        negate_imag<<<grid, BLOCK_SIZE>>>(d_imag, N);
        float inv_n = 1.0f / N;
        scale_array<<<grid, BLOCK_SIZE>>>(d_real, N, inv_n);
        scale_array<<<grid, BLOCK_SIZE>>>(d_imag, N, inv_n);
    }
}

int main(int argc, char **argv) {
    int N = 1024;
    int do_2d = 0;
    if (argc > 1) N = atoi(argv[1]);
    if (argc > 2) do_2d = atoi(argv[2]);

    // Ensure power of 2
    int t = N; while (t > 1) { if (t & 1) { printf("N must be power of 2\n"); return 1; } t >>= 1; }

    if (do_2d) {
        printf("2D FFT: %dx%d\n", N, N);

        float *h_real = (float*)malloc(N * N * sizeof(float));
        float *h_imag = (float*)calloc(N * N, sizeof(float));
        float *h_orig = (float*)malloc(N * N * sizeof(float));
        srand(42);
        for (int i = 0; i < N * N; i++) { h_real[i] = (float)rand() / RAND_MAX; h_orig[i] = h_real[i]; }

        float *d_real, *d_imag, *d_tmp_r, *d_tmp_i;
        cudaMalloc(&d_real, N * N * sizeof(float));
        cudaMalloc(&d_imag, N * N * sizeof(float));
        cudaMalloc(&d_tmp_r, N * N * sizeof(float));
        cudaMalloc(&d_tmp_i, N * N * sizeof(float));

        cudaMemcpy(d_real, h_real, N * N * sizeof(float), cudaMemcpyHostToDevice);
        cudaMemcpy(d_imag, h_imag, N * N * sizeof(float), cudaMemcpyHostToDevice);

        cudaEvent_t start, stop;
        cudaEventCreate(&start); cudaEventCreate(&stop);
        cudaEventRecord(start);

        // Row-wise FFT
        for (int r = 0; r < N; r++)
            fft_1d(d_real + r * N, d_imag + r * N, d_tmp_r, d_tmp_i, N, 0);

        // Transpose (simple: copy to host, transpose, copy back)
        cudaMemcpy(h_real, d_real, N*N*sizeof(float), cudaMemcpyDeviceToHost);
        cudaMemcpy(h_imag, d_imag, N*N*sizeof(float), cudaMemcpyDeviceToHost);
        float *tr = (float*)malloc(N*N*sizeof(float));
        float *ti = (float*)malloc(N*N*sizeof(float));
        for (int i = 0; i < N; i++) for (int j = 0; j < N; j++) {
            tr[j*N+i] = h_real[i*N+j]; ti[j*N+i] = h_imag[i*N+j];
        }
        cudaMemcpy(d_real, tr, N*N*sizeof(float), cudaMemcpyHostToDevice);
        cudaMemcpy(d_imag, ti, N*N*sizeof(float), cudaMemcpyHostToDevice);

        // Column-wise FFT (now rows after transpose)
        for (int r = 0; r < N; r++)
            fft_1d(d_real + r * N, d_imag + r * N, d_tmp_r, d_tmp_i, N, 0);

        // Transpose back
        cudaMemcpy(h_real, d_real, N*N*sizeof(float), cudaMemcpyDeviceToHost);
        cudaMemcpy(h_imag, d_imag, N*N*sizeof(float), cudaMemcpyDeviceToHost);
        for (int i = 0; i < N; i++) for (int j = 0; j < N; j++) {
            tr[j*N+i] = h_real[i*N+j]; ti[j*N+i] = h_imag[i*N+j];
        }
        cudaMemcpy(d_real, tr, N*N*sizeof(float), cudaMemcpyHostToDevice);
        cudaMemcpy(d_imag, ti, N*N*sizeof(float), cudaMemcpyHostToDevice);

        // Inverse: row-wise IFFT
        for (int r = 0; r < N; r++)
            fft_1d(d_real + r * N, d_imag + r * N, d_tmp_r, d_tmp_i, N, 1);
        // Transpose
        cudaMemcpy(h_real, d_real, N*N*sizeof(float), cudaMemcpyDeviceToHost);
        cudaMemcpy(h_imag, d_imag, N*N*sizeof(float), cudaMemcpyDeviceToHost);
        for (int i = 0; i < N; i++) for (int j = 0; j < N; j++) {
            tr[j*N+i] = h_real[i*N+j]; ti[j*N+i] = h_imag[i*N+j];
        }
        cudaMemcpy(d_real, tr, N*N*sizeof(float), cudaMemcpyHostToDevice);
        cudaMemcpy(d_imag, ti, N*N*sizeof(float), cudaMemcpyHostToDevice);
        // Column-wise IFFT
        for (int r = 0; r < N; r++)
            fft_1d(d_real + r * N, d_imag + r * N, d_tmp_r, d_tmp_i, N, 1);
        // Transpose back
        cudaMemcpy(h_real, d_real, N*N*sizeof(float), cudaMemcpyDeviceToHost);
        cudaMemcpy(h_imag, d_imag, N*N*sizeof(float), cudaMemcpyDeviceToHost);
        for (int i = 0; i < N; i++) for (int j = 0; j < N; j++) {
            tr[j*N+i] = h_real[i*N+j]; ti[j*N+i] = h_imag[i*N+j];
        }

        cudaEventRecord(stop); cudaEventSynchronize(stop);
        float ms; cudaEventElapsedTime(&ms, start, stop);
        printf("FFT + IFFT time: %.3f ms\n", ms);

        float max_err = 0;
        for (int i = 0; i < N * N; i++) {
            float e = fabsf(tr[i] - h_orig[i]);
            if (e > max_err) max_err = e;
        }
        printf("Roundtrip max error: %e\n", max_err);
        printf("Result: %s\n", (max_err < 1e-3) ? "PASS" : "FAIL");

        free(h_real); free(h_imag); free(h_orig); free(tr); free(ti);
        cudaFree(d_real); cudaFree(d_imag); cudaFree(d_tmp_r); cudaFree(d_tmp_i);
        cudaEventDestroy(start); cudaEventDestroy(stop);
        return (max_err < 1e-3) ? 0 : 1;
    }

    // 1D FFT
    printf("1D FFT: N=%d\n", N);
    float *h_real = (float*)malloc(N * sizeof(float));
    float *h_imag = (float*)calloc(N, sizeof(float));
    float *h_orig = (float*)malloc(N * sizeof(float));
    srand(42);
    for (int i = 0; i < N; i++) { h_real[i] = (float)rand() / RAND_MAX; h_orig[i] = h_real[i]; }

    float *d_real, *d_imag, *d_tmp_r, *d_tmp_i;
    cudaMalloc(&d_real, N * sizeof(float));
    cudaMalloc(&d_imag, N * sizeof(float));
    cudaMalloc(&d_tmp_r, N * sizeof(float));
    cudaMalloc(&d_tmp_i, N * sizeof(float));

    cudaMemcpy(d_real, h_real, N * sizeof(float), cudaMemcpyHostToDevice);
    cudaMemcpy(d_imag, h_imag, N * sizeof(float), cudaMemcpyHostToDevice);

    cudaEvent_t start, stop;
    cudaEventCreate(&start); cudaEventCreate(&stop);
    cudaEventRecord(start);
    fft_1d(d_real, d_imag, d_tmp_r, d_tmp_i, N, 0);
    fft_1d(d_real, d_imag, d_tmp_r, d_tmp_i, N, 1);
    cudaEventRecord(stop); cudaEventSynchronize(stop);
    float ms; cudaEventElapsedTime(&ms, start, stop);
    printf("FFT + IFFT time: %.3f ms\n", ms);

    cudaMemcpy(h_real, d_real, N * sizeof(float), cudaMemcpyDeviceToHost);
    float max_err = 0;
    for (int i = 0; i < N; i++) {
        float e = fabsf(h_real[i] - h_orig[i]);
        if (e > max_err) max_err = e;
    }
    printf("Roundtrip max error: %e\n", max_err);
    printf("Result: %s\n", (max_err < 1e-4) ? "PASS" : "FAIL");

    free(h_real); free(h_imag); free(h_orig);
    cudaFree(d_real); cudaFree(d_imag); cudaFree(d_tmp_r); cudaFree(d_tmp_i);
    cudaEventDestroy(start); cudaEventDestroy(stop);
    return (max_err < 1e-4) ? 0 : 1;
}
