/*
 * CUDA Dot Product (single-thread): result = sum(x[i] * y[i]).
 *
 * Fundamental BLAS-1 inner product. Exercises multiply-accumulate.
 */

#include <cuda_runtime.h>

__global__ void dot_kernel(const float *x, const float *y, float *out, int n) {
    float acc = 0.0f;
    for (int i = 0; i < n; i++) {
        acc += x[i] * y[i];
    }
    out[0] = acc;
}

int main(void) { return 0; }
