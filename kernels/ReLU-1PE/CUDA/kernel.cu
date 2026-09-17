/*
 * CUDA ReLU (single-thread reference): out[i] = max(0, x[i]).
 *
 * Elementwise activation on a float32 vector. Single-thread to match
 * the single-PE CSL translation target.
 */

#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

__global__ void relu_kernel(const float *x, float *out, int n) {
    for (int i = 0; i < n; i++) {
        out[i] = x[i] > 0.0f ? x[i] : 0.0f;
    }
}

int main(void) {
    return 0;
}
