/*
 * CUDA Prefix Sum / Cumulative Sum (single-thread):
 *   out[i] = sum(x[0..i])
 *
 * Classic parallel algorithm challenge. Sequential baseline here.
 */

#include <cuda_runtime.h>

__global__ void prefix_sum_kernel(const float *x, float *out, int n) {
    float acc = 0.0f;
    for (int i = 0; i < n; i++) {
        acc += x[i];
        out[i] = acc;
    }
}

int main(void) { return 0; }
