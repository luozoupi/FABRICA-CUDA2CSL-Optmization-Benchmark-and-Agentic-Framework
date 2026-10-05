// SpGEMM-Masked-Dot: masked sparse-times-sparse dot products, C<M> = A' * B with B := A and
// M := the pattern of A, so C(i,j) = A(:,i) . A(:,j) for every stored position (i,j) of A.
// A is stored by column (CSC: col_ptr[n+1], row_idx[nnz], val[nnz]), as GraphBLAS stores it.
//
// Concretized from SuiteSparse:GraphBLAS v10.5.x, github.com/DrTimothyAldenDavis/GraphBLAS @ afbe9aaefe5df7632ca82b478d65d0f6c1e14db0 (stable, 2026-09-13),
// CUDA/mxm/template/GB_cuda_jit_AxB_dot3_phase3_vsvs.cuh ("very sparse x very sparse", the
// bucket phase1 assigns when the two columns hold <= 128 entries together): one thread per mask
// entry pair_id, the owning column j found with GB_cuda_ek_slice (binary search over the
// column pointers), a two-pointer merge of the two sorted row-index lists, the product written
// to Cx[pair_id]; an entry whose lists never meet becomes a ZOMBIE (Ci = GB_ZOMBIE(i) = ~i) and
// the zombies are counted with a block reduction and one atomic per block. Fixed here: fp32
// plus-times semiring, int indices, structural mask (no complement, no values), the
// all-in-one bucket (no phase1/phase2), no iso values, no JIT macros.

#define BLOCK_SIZE 256

// GB_cuda_ek_slice: the column j with col_ptr[j] <= p < col_ptr[j+1] (binary search).
__device__ __forceinline__ int owner_col(const int* __restrict__ col_ptr, int n, int p) {
    int lo = 0, hi = n - 1;
    while (lo < hi) {
        int mid = (lo + hi + 1) >> 1;
        if (col_ptr[mid] <= p) lo = mid; else hi = mid - 1;
    }
    return lo;
}

__global__ void spgemm_masked_dot_vsvs(int n, int nnz,
                                       const int*   __restrict__ col_ptr,   // [n+1]   A (and the mask M) by column
                                       const int*   __restrict__ row_idx,   // [nnz]   sorted within each column
                                       const float* __restrict__ val,       // [nnz]
                                       float*       __restrict__ c_val,     // [nnz]   C(i,j) at the mask position
                                       int*         __restrict__ c_row,     // [nnz]   i, or GB_ZOMBIE(i) = ~i
                                       int*         __restrict__ nzombies)  // [1]     zero-initialised by the host
{
    __shared__ int zombies_in_block[BLOCK_SIZE];
    int my_zombies = 0;
    const int ntasks = gridDim.x * blockDim.x;
    for (int pair_id = blockIdx.x * blockDim.x + threadIdx.x; pair_id < nnz; pair_id += ntasks) {
        const int i = row_idx[pair_id];                      // M(i,j): row from Mi ...
        const int j = owner_col(col_ptr, n, pair_id);        // ... column from the pointer search
        int pA = col_ptr[i], pA_end = col_ptr[i + 1];        // A(:,i)
        int pB = col_ptr[j], pB_end = col_ptr[j + 1];        // B(:,j) with B := A
        float cij = 0.0f;
        bool cij_exists = false;
        while (pA < pA_end && pB < pB_end) {                 // two-pointer merge of sorted index lists
            const int ia = row_idx[pA];
            const int ib = row_idx[pB];
            if (ia == ib) {
                cij += val[pA] * val[pB];                    // GB_DOT_MERGE: GB_MULT then GB_ADD
                cij_exists = true;
            }
            pA += (ia <= ib);
            pB += (ib <= ia);
        }
        if (cij_exists) {
            c_val[pair_id] = cij;                            // GB_PUTC
            c_row[pair_id] = i;
        } else {
            c_val[pair_id] = 0.0f;
            c_row[pair_id] = ~i;                             // GB_ZOMBIE(i): entry to be deleted later
            my_zombies++;
        }
    }
    zombies_in_block[threadIdx.x] = my_zombies;              // GB_cuda_threadblock_sum
    __syncthreads();
    for (int s = BLOCK_SIZE / 2; s > 0; s >>= 1) {
        if (threadIdx.x < s) zombies_in_block[threadIdx.x] += zombies_in_block[threadIdx.x + s];
        __syncthreads();
    }
    if (threadIdx.x == 0) atomicAdd(nzombies, zombies_in_block[0]);
}

int main() {
    // Host driver omitted for brevity; the kernel above is the translation target.
    // Inputs: CSC col_ptr[n+1] (nnz = col_ptr[n]), row_idx[nnz], val[nnz]; outputs c_val[nnz],
    // c_row[nnz], nzombies[1].
    return 0;
}
