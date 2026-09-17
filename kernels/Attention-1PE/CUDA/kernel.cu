/*
 * CUDA dense scaled-dot-product attention (one head, no mask):
 *   scores[i][j] = (Q[i] . K[j]) / sqrt(d)
 *   P[i][:]      = softmax(scores[i][:])            (numerically stable)
 *   O[i]         = sum_j P[i][j] * V[j]
 *
 * Q, K, V, O are row-major [S, d] fp32. One thread computes one query row:
 * it scores that row against every key into a per-row scratch buffer,
 * normalizes the row with a max-shifted softmax, then accumulates the
 * weighted sum of value rows. Rows are independent, so blocks of rows can be
 * distributed freely; keys and values are read by every row.
 */

#include <cuda_runtime.h>
#include <math.h>
#include <float.h>

__global__ void attention_kernel(const float *Q, const float *K, const float *V,
                                 float *O, float *scores, int S, int d) {
    int i = blockIdx.x * blockDim.x + threadIdx.x;   /* query row */
    if (i >= S) return;

    const float inv_sqrt_d = rsqrtf((float)d);
    float *p = scores + (size_t)i * S;              /* this row's scratch */

    /* 1) scores for row i against all keys */
    float mx = -FLT_MAX;
    for (int j = 0; j < S; j++) {
        float acc = 0.0f;
        for (int k = 0; k < d; k++) acc += Q[i * d + k] * K[j * d + k];
        acc *= inv_sqrt_d;
        p[j] = acc;
        if (acc > mx) mx = acc;
    }

    /* 2) stable softmax over the row */
    float sum = 0.0f;
    for (int j = 0; j < S; j++) {
        p[j] = expf(p[j] - mx);
        sum += p[j];
    }
    const float inv_sum = 1.0f / sum;
    for (int j = 0; j < S; j++) p[j] *= inv_sum;

    /* 3) O[i] = P[i] @ V */
    for (int k = 0; k < d; k++) {
        float acc = 0.0f;
        for (int j = 0; j < S; j++) acc += p[j] * V[j * d + k];
        O[i * d + k] = acc;
    }
}

int main(void) { return 0; }
