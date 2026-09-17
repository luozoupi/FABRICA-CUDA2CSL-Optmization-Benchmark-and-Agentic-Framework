/*
 * CUDA SAXPY (single-thread reference): y[i] = a*x[i] + y[i].
 *
 * The classic BLAS-1 "hello world" of GPU computing.
 * Tests fused multiply-add on f32.
 */

#include <cuda_runtime.h>

__global__ void saxpy_kernel(float a, const float *x, float *y, int n) {
    for (int i = 0; i < n; i++) {
        y[i] = a * x[i] + y[i];
    }
}

int main(void) { return 0; }
