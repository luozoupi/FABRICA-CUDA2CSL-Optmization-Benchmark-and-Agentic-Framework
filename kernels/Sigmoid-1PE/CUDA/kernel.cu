/*
 * CUDA Sigmoid (single-thread reference): out[i] = 1 / (1 + exp(-x[i])).
 *
 * Elementwise activation exercising exp() transcendental on f32.
 */

#include <cuda_runtime.h>
#include <math.h>

__global__ void sigmoid_kernel(const float *x, float *out, int n) {
    for (int i = 0; i < n; i++) {
        out[i] = 1.0f / (1.0f + expf(-x[i]));
    }
}

int main(void) { return 0; }
