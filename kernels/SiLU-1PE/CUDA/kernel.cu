/*
 * CUDA SiLU/Swish (single-thread): out[i] = x[i] * sigmoid(x[i]).
 *
 * Modern activation used in LLMs (Llama, etc). x * (1/(1+exp(-x))).
 */

#include <cuda_runtime.h>
#include <math.h>

__global__ void silu_kernel(const float *x, float *out, int n) {
    for (int i = 0; i < n; i++) {
        out[i] = x[i] / (1.0f + expf(-x[i]));
    }
}

int main(void) { return 0; }
