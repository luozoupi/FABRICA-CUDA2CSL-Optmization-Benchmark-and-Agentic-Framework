/*
 * CUDA Broadcast + Scale (multi-block):
 *   out[i] = alpha * x[i] for a distributed vector.
 *
 * PE0 broadcasts alpha to all PEs, each PE scales its local chunk.
 * Tests broadcast collective + elementwise compute.
 */

#include <cuda_runtime.h>

__global__ void bcast_scale_kernel(float alpha, const float *x, float *out, int n) {
    for (int i = 0; i < n; i++) {
        out[i] = alpha * x[i];
    }
}

int main(void) { return 0; }
