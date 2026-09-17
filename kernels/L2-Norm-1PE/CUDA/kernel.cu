/*
 * CUDA L2 Normalization (single-thread):
 *   out[i] = x[i] / sqrt(sum(x[j]^2) + eps)
 *
 * Normalize vector to unit L2 norm. Two-pass: reduce, then scale.
 */

#include <cuda_runtime.h>
#include <math.h>

__global__ void l2norm_kernel(const float *x, float *out, int n, float eps) {
    float sum_sq = 0.0f;
    for (int i = 0; i < n; i++) sum_sq += x[i] * x[i];
    float inv_norm = 1.0f / sqrtf(sum_sq + eps);
    for (int i = 0; i < n; i++) out[i] = x[i] * inv_norm;
}

int main(void) { return 0; }
