/*
 * CUDA Histogram Computation
 *
 * Translates the CSL kernel from:
 *   sdk-examples/benchmarks/histogram-torus/histogram.csl
 *
 * CSL approach:
 *   - Input values distributed across 2D PE grid
 *   - Each PE maps values to (bucket_id, target_PE) and routes via torus
 *   - Wavelets carry packed (y, x, bucket) and route N/S then E/W
 *   - Destination PE increments bucket count
 *
 * CUDA approach:
 *   - Shared-memory histogram with privatization per block
 *   - Atomic adds to shared histogram, then merge to global
 *   - Equivalent bucket mapping: bucket = (value / bucket_size) % n_buckets
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <cuda_runtime.h>

#define BLOCK_SIZE 256

// Per-block shared-memory histogram
__global__ void histogram_kernel(const unsigned int *input, unsigned int *output,
                                  int n, int n_buckets, unsigned int bucket_size) {
    extern __shared__ unsigned int s_hist[];

    int tid = threadIdx.x;
    // Zero shared histogram
    for (int i = tid; i < n_buckets; i += blockDim.x)
        s_hist[i] = 0;
    __syncthreads();

    // Each thread processes multiple elements
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    int stride = blockDim.x * gridDim.x;
    for (int i = idx; i < n; i += stride) {
        unsigned int val = input[i];
        unsigned int bucket = (val / bucket_size) % n_buckets;
        atomicAdd(&s_hist[bucket], 1);
    }
    __syncthreads();

    // Merge shared histogram to global
    for (int i = tid; i < n_buckets; i += blockDim.x)
        atomicAdd(&output[i], s_hist[i]);
}

int main(int argc, char **argv) {
    int n = 1 << 20;  // 1M elements
    int n_buckets = 256;
    unsigned int bucket_size = 16;
    if (argc > 1) n = atoi(argv[1]);
    if (argc > 2) n_buckets = atoi(argv[2]);
    if (argc > 3) bucket_size = (unsigned int)atoi(argv[3]);

    printf("Histogram: %d elements, %d buckets, bucket_size=%u\n", n, n_buckets, bucket_size);

    unsigned int *h_input = (unsigned int*)malloc(n * sizeof(unsigned int));
    unsigned int *h_hist = (unsigned int*)calloc(n_buckets, sizeof(unsigned int));
    unsigned int *h_ref = (unsigned int*)calloc(n_buckets, sizeof(unsigned int));

    srand(42);
    unsigned int max_val = n_buckets * bucket_size;
    for (int i = 0; i < n; i++) h_input[i] = (unsigned int)rand() % max_val;

    // CPU reference
    for (int i = 0; i < n; i++) {
        unsigned int bucket = (h_input[i] / bucket_size) % n_buckets;
        h_ref[bucket]++;
    }

    unsigned int *d_input, *d_hist;
    cudaMalloc(&d_input, n * sizeof(unsigned int));
    cudaMalloc(&d_hist, n_buckets * sizeof(unsigned int));
    cudaMemcpy(d_input, h_input, n * sizeof(unsigned int), cudaMemcpyHostToDevice);
    cudaMemset(d_hist, 0, n_buckets * sizeof(unsigned int));

    int grid = (n + BLOCK_SIZE - 1) / BLOCK_SIZE;
    if (grid > 1024) grid = 1024;

    // Warmup
    histogram_kernel<<<grid, BLOCK_SIZE, n_buckets * sizeof(unsigned int)>>>(
        d_input, d_hist, n, n_buckets, bucket_size);
    cudaMemset(d_hist, 0, n_buckets * sizeof(unsigned int));

    cudaEvent_t start, stop;
    cudaEventCreate(&start); cudaEventCreate(&stop);
    int iters = 100;
    cudaEventRecord(start);
    for (int i = 0; i < iters; i++) {
        cudaMemset(d_hist, 0, n_buckets * sizeof(unsigned int));
        histogram_kernel<<<grid, BLOCK_SIZE, n_buckets * sizeof(unsigned int)>>>(
            d_input, d_hist, n, n_buckets, bucket_size);
    }
    cudaEventRecord(stop); cudaEventSynchronize(stop);
    float ms; cudaEventElapsedTime(&ms, start, stop);
    printf("Kernel time: %.4f ms (avg over %d iterations)\n", ms / iters, iters);
    printf("Throughput: %.2f GB/s\n", (double)n * sizeof(unsigned int) * iters / (ms * 1e6));

    cudaMemcpy(h_hist, d_hist, n_buckets * sizeof(unsigned int), cudaMemcpyDeviceToHost);

    // Verify
    int pass = 1;
    for (int i = 0; i < n_buckets; i++) {
        if (h_hist[i] != h_ref[i]) {
            printf("Mismatch at bucket %d: GPU=%u, CPU=%u\n", i, h_hist[i], h_ref[i]);
            pass = 0;
            break;
        }
    }
    printf("Result: %s\n", pass ? "PASS" : "FAIL");

    free(h_input); free(h_hist); free(h_ref);
    cudaFree(d_input); cudaFree(d_hist);
    cudaEventDestroy(start); cudaEventDestroy(stop);
    return pass ? 0 : 1;
}
