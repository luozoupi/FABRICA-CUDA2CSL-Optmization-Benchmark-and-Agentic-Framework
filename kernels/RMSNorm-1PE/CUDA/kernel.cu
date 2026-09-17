/*
 * CUDA RMSNorm (single-thread reference):
 *   rms = sqrt(mean(x^2) + eps)
 *   out[i] = (x[i] / rms) * weight[i]
 *
 * Core LLM normalization (Llama, etc). Exercises reduction + elementwise.
 */

#include <cuda_runtime.h>
#include <math.h>

__global__ void rmsnorm_kernel(const float *x, const float *weight,
                                float *out, int n, float eps) {
    float sum_sq = 0.0f;
    for (int i = 0; i < n; i++) {
        sum_sq += x[i] * x[i];
    }
    float rms = sqrtf(sum_sq / (float)n + eps);
    for (int i = 0; i < n; i++) {
        out[i] = (x[i] / rms) * weight[i];
    }
}

int main(void) { return 0; }
