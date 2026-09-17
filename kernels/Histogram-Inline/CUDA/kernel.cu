// Multi-PE Histogram: each thread bins its elements, atomicAdd to shared histogram.
// The CSL v2 replaces atomics with explicit fabric reduction.

__global__ void histogram(const unsigned int* input, unsigned int* hist,
                          int n, int n_buckets, int bucket_size) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < n) {
        int bucket = (input[idx] / bucket_size) % n_buckets;
        atomicAdd(&hist[bucket], 1);
    }
}
