/*
 * CUDA Histogram (single-block reference): hist[(val/bucket_size) % n_buckets]++.
 *
 * This is the HAND-WRITTEN-COMPUTE variant of Histogram: instead of delegating the
 * cross-PE tally to the SDK <kernels/tally> library (see kernels/Histogram), the
 * compute is the explicit per-element bucket index + increment, so a CSL translation
 * must express the actual binning arithmetic. Single-PE layout keeps it a clean,
 * cycle-scoreable translation task: one PE bins its local input array into a local
 * histogram.
 *
 *   for i in [0, n):
 *     bucket = (input[i] / bucket_size) % n_buckets
 *     hist[bucket] += 1
 */

#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

// One thread bins the whole local array (single-PE-equivalent reference).
__global__ void histogram_local(const unsigned int *input, unsigned int *hist,
                                 int n, int n_buckets, unsigned int bucket_size) {
    for (int b = 0; b < n_buckets; b++) hist[b] = 0;
    for (int i = 0; i < n; i++) {
        unsigned int bucket = (input[i] / bucket_size) % (unsigned int)n_buckets;
        hist[bucket] += 1;
    }
}

int main(void) {
    // Host driver omitted; the kernel above is the translation target.
    // Reference verification (hist == numpy bincount) is in the CSL bundle's run.py.
    return 0;
}
