/*
 * CUDA Max Reduction (single-thread reference): out = max(x[0..n-1]).
 *
 * Reduces a float32 vector to the scalar maximum. Comparison-based
 * reduction (vs arithmetic in Sum-Reduction).
 */

#include <cuda_runtime.h>
#include <float.h>

__global__ void max_reduce_kernel(const float *x, float *out, int n) {
    float mx = -FLT_MAX;
    for (int i = 0; i < n; i++) {
        if (x[i] > mx) mx = x[i];
    }
    out[0] = mx;
}

int main(void) { return 0; }
