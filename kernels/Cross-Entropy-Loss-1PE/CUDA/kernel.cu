/*
 * CUDA Cross-Entropy Loss (single-thread):
 *   loss = -sum(target[i] * log(softmax(logits)[i]))
 *
 * Combines softmax + log + weighted sum. Core classification loss.
 * Numerically stable: uses log-sum-exp trick.
 */

#include <cuda_runtime.h>
#include <math.h>
#include <float.h>

__global__ void cross_entropy_kernel(const float *logits, const int *labels,
                                      float *out, int n, int n_classes) {
    float loss = 0.0f;
    for (int s = 0; s < n; s++) {
        const float *row = logits + s * n_classes;
        int label = labels[s];
        float mx = -FLT_MAX;
        for (int c = 0; c < n_classes; c++) if (row[c] > mx) mx = row[c];
        float log_sum = 0.0f;
        for (int c = 0; c < n_classes; c++) log_sum += expf(row[c] - mx);
        loss += -(row[label] - mx - logf(log_sum));
    }
    out[0] = loss / (float)n;
}

int main(void) { return 0; }
