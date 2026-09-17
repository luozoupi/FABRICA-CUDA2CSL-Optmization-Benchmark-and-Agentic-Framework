/*
 * CUDA Mandelbrot Set Computation
 *
 * Translates the CSL kernel from:
 *   sdk-examples/benchmarks/mandelbrot/common.csl, left.csl
 *
 * CSL approach:
 *   - 2D PE grid, each PE computes rows_per_pe rows
 *   - For each pixel (row, col): map to complex plane c = (x + yi)
 *   - Iterate z = z^2 + c until |z| > 2 or max_iters
 *   - Results passed east via fabric colors for collection
 *
 * CUDA approach:
 *   - One thread per pixel
 *   - Same iteration: z = z^2 + c, check |z| > 2
 *   - Output iteration count per pixel
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cuda_runtime.h>

#define BLOCK_DIM 16

__global__ void mandelbrot_kernel(int *output, int width, int height, int max_iters,
                                   float x_lo, float x_hi, float y_lo, float y_hi) {
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    int row = blockIdx.y * blockDim.y + threadIdx.y;
    if (col >= width || row >= height) return;

    float cx = (float)col * (x_hi - x_lo) / (float)(width - 1) + x_lo;
    float cy = (float)row * (y_hi - y_lo) / (float)(height - 1) + y_lo;

    float zr = cx, zi = cy;
    int iter = 0;
    for (int i = 0; i < max_iters; i++) {
        float mag = sqrtf(zr * zr + zi * zi);
        if (mag > 2.0f) break;
        float nr = zr * zr - zi * zi;
        float ni = zr * zi + zr * zi;
        zr = nr + cx;
        zi = ni + cy;
        iter++;
    }
    output[row * width + col] = iter;
}

// CPU reference
void mandelbrot_cpu(int *output, int width, int height, int max_iters,
                    float x_lo, float x_hi, float y_lo, float y_hi) {
    for (int row = 0; row < height; row++) {
        for (int col = 0; col < width; col++) {
            float cx = (float)col * (x_hi - x_lo) / (float)(width - 1) + x_lo;
            float cy = (float)row * (y_hi - y_lo) / (float)(height - 1) + y_lo;
            float zr = cx, zi = cy;
            int iter = 0;
            for (int i = 0; i < max_iters; i++) {
                float mag = sqrtf(zr * zr + zi * zi);
                if (mag > 2.0f) break;
                float nr = zr * zr - zi * zi;
                float ni = zr * zi + zr * zi;
                zr = nr + cx;
                zi = ni + cy;
                iter++;
            }
            output[row * width + col] = iter;
        }
    }
}

int main(int argc, char **argv) {
    int width = 1024, height = 1024, max_iters = 256;
    if (argc > 1) width = height = atoi(argv[1]);
    if (argc > 2) max_iters = atoi(argv[2]);

    float x_lo = -2.0f, x_hi = 1.0f, y_lo = -1.5f, y_hi = 1.5f;

    printf("Mandelbrot: %dx%d, max_iters=%d\n", width, height, max_iters);

    int n = width * height;
    int *h_gpu = (int*)malloc(n * sizeof(int));
    int *h_cpu = (int*)malloc(n * sizeof(int));

    int *d_out;
    cudaMalloc(&d_out, n * sizeof(int));

    dim3 block(BLOCK_DIM, BLOCK_DIM);
    dim3 grid((width + BLOCK_DIM - 1) / BLOCK_DIM, (height + BLOCK_DIM - 1) / BLOCK_DIM);

    // Warmup
    mandelbrot_kernel<<<grid, block>>>(d_out, width, height, max_iters, x_lo, x_hi, y_lo, y_hi);
    cudaDeviceSynchronize();

    cudaEvent_t start, stop;
    cudaEventCreate(&start); cudaEventCreate(&stop);
    int iters = 10;
    cudaEventRecord(start);
    for (int i = 0; i < iters; i++)
        mandelbrot_kernel<<<grid, block>>>(d_out, width, height, max_iters, x_lo, x_hi, y_lo, y_hi);
    cudaEventRecord(stop); cudaEventSynchronize(stop);
    float ms; cudaEventElapsedTime(&ms, start, stop);
    printf("Kernel time: %.3f ms (avg over %d iterations)\n", ms / iters, iters);
    printf("Pixels/sec: %.2f Gpix/s\n", (double)n * iters / (ms * 1e6));

    cudaMemcpy(h_gpu, d_out, n * sizeof(int), cudaMemcpyDeviceToHost);

    // CPU reference
    mandelbrot_cpu(h_cpu, width, height, max_iters, x_lo, x_hi, y_lo, y_hi);

    int mismatches = 0;
    for (int i = 0; i < n; i++) {
        if (h_gpu[i] != h_cpu[i]) mismatches++;
    }
    printf("Mismatches: %d / %d\n", mismatches, n);
    printf("Result: %s\n", (mismatches == 0) ? "PASS" : "FAIL");

    free(h_gpu); free(h_cpu);
    cudaFree(d_out);
    cudaEventDestroy(start); cudaEventDestroy(stop);
    return (mismatches == 0) ? 0 : 1;
}
