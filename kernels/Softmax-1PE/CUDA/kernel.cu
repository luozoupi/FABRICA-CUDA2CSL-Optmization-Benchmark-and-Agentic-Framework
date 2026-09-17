/*
 * CUDA Softmax (single-thread, numerically stable):
 *   m = max(x), out[i] = exp(x[i] - m) / sum(exp(x[j] - m))
 *
 * Three-pass: find max, compute exp(x-max), normalize by sum.
 * Critical ML operation for attention, classification, etc.
 */

#include <cuda_runtime.h>
#include <math.h>
#include <float.h>

__global__ void softmax_kernel(const float *x, float *out, int n) {
    float mx = -FLT_MAX;
    for (int i = 0; i < n; i++) if (x[i] > mx) mx = x[i];

    float sum = 0.0f;
    for (int i = 0; i < n; i++) {
        out[i] = expf(x[i] - mx);
        sum += out[i];
    }
    for (int i = 0; i < n; i++) out[i] /= sum;
}

int main(void) { return 0; }
