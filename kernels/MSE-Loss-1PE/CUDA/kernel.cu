/*
 * CUDA MSE Loss (single-thread reference):
 *   out = mean((predictions - targets)^2)
 *
 * Two-input reduction: subtract, square, mean-reduce to scalar.
 */

#include <cuda_runtime.h>

__global__ void mse_loss_kernel(const float *pred, const float *target,
                                 float *out, int n) {
    float sum = 0.0f;
    for (int i = 0; i < n; i++) {
        float d = pred[i] - target[i];
        sum += d * d;
    }
    out[0] = sum / (float)n;
}

int main(void) { return 0; }
