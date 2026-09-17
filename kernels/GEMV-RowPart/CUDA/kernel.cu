// GEMV: y = A * x
// Row-partitioned across PEs — each PE computes its local rows.

__global__ void gemv(const float* A, const float* x, float* y,
                     int M, int N) {
    int row = blockIdx.x * blockDim.x + threadIdx.x;
    if (row < M) {
        float sum = 0.0f;
        for (int j = 0; j < N; j++) {
            sum += A[row * N + j] * x[j];
        }
        y[row] = sum;
    }
}
