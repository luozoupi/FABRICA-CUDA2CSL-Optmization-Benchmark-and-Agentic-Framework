/*
 * CUDA Sum Reduction (single-thread reference): out = sum(x[0..n-1]).
 *
 * Reduces a float32 vector to a scalar sum. Single-thread to match
 * the single-PE CSL translation target.
 */

#include <cuda_runtime.h>

__global__ void sum_reduce_kernel(const float *x, float *out, int n) {
    float acc = 0.0f;
    for (int i = 0; i < n; i++) {
        acc += x[i];
    }
    out[0] = acc;
}

int main(void) { return 0; }
