/*
 * CUDA GELU (single-thread reference, tanh approximation):
 *   out[i] = 0.5 * x * (1 + tanh(sqrt(2/pi) * (x + 0.044715*x^3)))
 *
 * Standard transformer activation. Exercises polynomial + transcendental.
 */

#include <cuda_runtime.h>
#include <math.h>

__global__ void gelu_kernel(const float *x, float *out, int n) {
    const float sqrt_2_over_pi = 0.7978845608f;  // sqrt(2/pi)
    const float coeff = 0.044715f;
    for (int i = 0; i < n; i++) {
        float v = x[i];
        float inner = sqrt_2_over_pi * (v + coeff * v * v * v);
        out[i] = 0.5f * v * (1.0f + tanhf(inner));
    }
}

int main(void) { return 0; }
