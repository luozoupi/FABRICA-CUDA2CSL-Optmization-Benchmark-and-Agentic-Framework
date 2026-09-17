/*
 * CUDA Wide (Multi-Word) Integer Multiplication
 *
 * Translates the CSL kernel from:
 *   sdk-examples/benchmarks/wide-multiplication/pe.csl
 *
 * CSL approach:
 *   - Numbers stored as arrays of 16-bit words (little-endian)
 *   - For each bit of y: if set, add (shifted) x to result with carry propagation
 *   - x is left-shifted by 1 after each bit
 *   - Overflow ignored (result truncated to num_bits)
 *
 * CUDA approach:
 *   - Same schoolbook multiplication with multi-word representation
 *   - Uses 32-bit words for efficiency on GPU
 *   - Single thread per multiplication (compute-bound, not parallel within one multiply)
 *   - Batch many multiplications for GPU utilization
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <cuda_runtime.h>

#define MAX_WORDS 16  // Up to 512-bit numbers (16 * 32 bits)

// Wide multiply: result = x * y (both num_words long, result truncated to num_words)
__global__ void wide_mul_kernel(const unsigned int *x_arr, const unsigned int *y_arr,
                                 unsigned int *result_arr, int num_words, int batch_size) {
    int tid = blockIdx.x * blockDim.x + threadIdx.x;
    if (tid >= batch_size) return;

    unsigned int x[MAX_WORDS], result[MAX_WORDS];
    const unsigned int *y = y_arr + tid * num_words;

    // Load x (will be shifted)
    for (int i = 0; i < num_words; i++) {
        x[i] = x_arr[tid * num_words + i];
        result[i] = 0;
    }

    // For each bit of y
    for (int wi = 0; wi < num_words; wi++) {
        for (int bi = 0; bi < 32; bi++) {
            if (y[wi] & (1u << bi)) {
                // Add x to result with carry
                unsigned long long carry = 0;
                for (int k = 0; k < num_words; k++) {
                    unsigned long long sum = (unsigned long long)result[k] + x[k] + carry;
                    result[k] = (unsigned int)sum;
                    carry = sum >> 32;
                }
            }

            // Shift x left by 1
            for (int k = num_words - 1; k > 0; k--) {
                x[k] = (x[k] << 1) | (x[k - 1] >> 31);
            }
            x[0] <<= 1;
        }
    }

    // Store result
    for (int i = 0; i < num_words; i++)
        result_arr[tid * num_words + i] = result[i];
}

// CPU reference (same algorithm)
void wide_mul_cpu(const unsigned int *x, const unsigned int *y,
                  unsigned int *result, int num_words) {
    unsigned int xc[MAX_WORDS];
    memcpy(xc, x, num_words * sizeof(unsigned int));
    memset(result, 0, num_words * sizeof(unsigned int));

    for (int wi = 0; wi < num_words; wi++) {
        for (int bi = 0; bi < 32; bi++) {
            if (y[wi] & (1u << bi)) {
                unsigned long long carry = 0;
                for (int k = 0; k < num_words; k++) {
                    unsigned long long sum = (unsigned long long)result[k] + xc[k] + carry;
                    result[k] = (unsigned int)sum;
                    carry = sum >> 32;
                }
            }
            for (int k = num_words - 1; k > 0; k--)
                xc[k] = (xc[k] << 1) | (xc[k - 1] >> 31);
            xc[0] <<= 1;
        }
    }
}

int main(int argc, char **argv) {
    int num_bits = 256;
    int batch = 1024;
    if (argc > 1) num_bits = atoi(argv[1]);
    if (argc > 2) batch = atoi(argv[2]);

    int num_words = num_bits / 32;
    if (num_words > MAX_WORDS) { printf("Max %d bits\n", MAX_WORDS * 32); return 1; }

    printf("Wide Multiplication: %d-bit x %d-bit, batch=%d\n", num_bits, num_bits, batch);

    size_t sz = batch * num_words * sizeof(unsigned int);
    unsigned int *h_x = (unsigned int*)malloc(sz);
    unsigned int *h_y = (unsigned int*)malloc(sz);
    unsigned int *h_result = (unsigned int*)malloc(sz);
    unsigned int *h_ref = (unsigned int*)malloc(sz);

    srand(42);
    for (int i = 0; i < batch * num_words; i++) {
        h_x[i] = (unsigned int)rand();
        h_y[i] = (unsigned int)rand();
    }

    // CPU reference (just first few for verification)
    int check_count = (batch < 16) ? batch : 16;
    for (int b = 0; b < check_count; b++)
        wide_mul_cpu(h_x + b * num_words, h_y + b * num_words,
                     h_ref + b * num_words, num_words);

    unsigned int *d_x, *d_y, *d_result;
    cudaMalloc(&d_x, sz); cudaMalloc(&d_y, sz); cudaMalloc(&d_result, sz);
    cudaMemcpy(d_x, h_x, sz, cudaMemcpyHostToDevice);
    cudaMemcpy(d_y, h_y, sz, cudaMemcpyHostToDevice);

    int block_size = 256;
    int grid = (batch + block_size - 1) / block_size;

    // Warmup
    wide_mul_kernel<<<grid, block_size>>>(d_x, d_y, d_result, num_words, batch);
    cudaDeviceSynchronize();

    cudaEvent_t start, stop;
    cudaEventCreate(&start); cudaEventCreate(&stop);
    int iters = 10;
    cudaEventRecord(start);
    for (int i = 0; i < iters; i++)
        wide_mul_kernel<<<grid, block_size>>>(d_x, d_y, d_result, num_words, batch);
    cudaEventRecord(stop); cudaEventSynchronize(stop);
    float ms; cudaEventElapsedTime(&ms, start, stop);
    printf("Kernel time: %.3f ms (avg over %d iterations)\n", ms / iters, iters);
    printf("Throughput: %.2f M multiplications/s\n", (double)batch * iters / (ms * 1e3));

    cudaMemcpy(h_result, d_result, sz, cudaMemcpyDeviceToHost);

    // Verify
    int pass = 1;
    for (int b = 0; b < check_count; b++) {
        for (int w = 0; w < num_words; w++) {
            if (h_result[b * num_words + w] != h_ref[b * num_words + w]) {
                printf("Mismatch at batch=%d, word=%d: GPU=0x%08x, CPU=0x%08x\n",
                       b, w, h_result[b * num_words + w], h_ref[b * num_words + w]);
                pass = 0;
                break;
            }
        }
        if (!pass) break;
    }
    printf("Result: %s\n", pass ? "PASS" : "FAIL");

    free(h_x); free(h_y); free(h_result); free(h_ref);
    cudaFree(d_x); cudaFree(d_y); cudaFree(d_result);
    cudaEventDestroy(start); cudaEventDestroy(stop);
    return pass ? 0 : 1;
}
