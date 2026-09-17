/*
 * CUDA Conway's Game of Life
 *
 * Translates the CSL Game of Life kernel from:
 *   sdk-examples/benchmarks/game-of-life/pe_program.csl
 *
 * CSL approach:
 *   - 2D toroidal PE grid, each PE holds one cell
 *   - Each PE exchanges state with 8 neighbors via fabric
 *   - Neighbor count accumulated, then rules applied
 *   - Synchronization between generations via control wavelets
 *
 * CUDA approach:
 *   - 2D grid stored in global memory
 *   - Each thread computes one cell's next state
 *   - Toroidal (periodic) boundary conditions
 *   - Double-buffered: read from current, write to next
 */

#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

#define BLOCK_SIZE 16

__global__ void game_of_life_kernel(
    const int* __restrict__ grid,
    int* __restrict__ next,
    int width, int height)
{
    int x = blockIdx.x * blockDim.x + threadIdx.x;
    int y = blockIdx.y * blockDim.y + threadIdx.y;

    if (x >= width || y >= height) return;

    // Count neighbors with toroidal boundary
    int count = 0;
    for (int dy = -1; dy <= 1; dy++) {
        for (int dx = -1; dx <= 1; dx++) {
            if (dx == 0 && dy == 0) continue;
            int nx = (x + dx + width) % width;
            int ny = (y + dy + height) % height;
            count += grid[ny * width + nx];
        }
    }

    int cell = grid[y * width + x];
    // Conway's rules
    int alive = (cell && (count == 2 || count == 3)) || (!cell && count == 3);
    next[y * width + x] = alive;
}

void game_of_life_reference(const int* grid, int* next, int w, int h) {
    for (int y = 0; y < h; y++)
        for (int x = 0; x < w; x++) {
            int count = 0;
            for (int dy = -1; dy <= 1; dy++)
                for (int dx = -1; dx <= 1; dx++) {
                    if (dx == 0 && dy == 0) continue;
                    int nx = (x + dx + w) % w;
                    int ny = (y + dy + h) % h;
                    count += grid[ny * w + nx];
                }
            int cell = grid[y * w + x];
            next[y * w + x] = (cell && (count == 2 || count == 3)) || (!cell && count == 3);
        }
}

void print_grid(const int* grid, int w, int h) {
    for (int y = 0; y < h && y < 20; y++) {
        for (int x = 0; x < w && x < 40; x++)
            printf("%c", grid[y * w + x] ? '#' : '.');
        printf("\n");
    }
}

int main(int argc, char** argv) {
    int width = 64, height = 64, ngen = 100;
    if (argc > 1) width = height = atoi(argv[1]);
    if (argc > 2) ngen = atoi(argv[2]);

    printf("Game of Life: %dx%d, %d generations\n", width, height, ngen);

    size_t nbytes = width * height * sizeof(int);
    int *h_grid = (int*)calloc(width * height, sizeof(int));
    int *h_ref = (int*)calloc(width * height, sizeof(int));
    int *h_ref_tmp = (int*)calloc(width * height, sizeof(int));
    int *h_result = (int*)malloc(nbytes);

    // Initialize with glider pattern (same as CSL benchmark)
    // Glider at position (1,0):
    //   .#.
    //   ..#
    //   ###
    if (width >= 5 && height >= 5) {
        h_grid[0 * width + 1] = 1;
        h_grid[1 * width + 2] = 1;
        h_grid[2 * width + 0] = 1;
        h_grid[2 * width + 1] = 1;
        h_grid[2 * width + 2] = 1;
    }

    // Copy for reference
    memcpy(h_ref, h_grid, nbytes);

    printf("Initial state:\n");
    print_grid(h_grid, width, height);

    // Device
    int *d_grid, *d_next;
    cudaMalloc(&d_grid, nbytes);
    cudaMalloc(&d_next, nbytes);
    cudaMemcpy(d_grid, h_grid, nbytes, cudaMemcpyHostToDevice);

    dim3 block(BLOCK_SIZE, BLOCK_SIZE);
    dim3 grid_dim((width + BLOCK_SIZE - 1) / BLOCK_SIZE,
                  (height + BLOCK_SIZE - 1) / BLOCK_SIZE);

    // Warmup
    game_of_life_kernel<<<grid_dim, block>>>(d_grid, d_next, width, height);
    cudaDeviceSynchronize();

    // Reset
    cudaMemcpy(d_grid, h_grid, nbytes, cudaMemcpyHostToDevice);

    cudaEvent_t start, stop;
    cudaEventCreate(&start);
    cudaEventCreate(&stop);

    cudaEventRecord(start);
    for (int g = 0; g < ngen; g++) {
        game_of_life_kernel<<<grid_dim, block>>>(d_grid, d_next, width, height);
        int* tmp = d_grid;
        d_grid = d_next;
        d_next = tmp;
    }
    cudaEventRecord(stop);
    cudaEventSynchronize(stop);

    float ms;
    cudaEventElapsedTime(&ms, start, stop);
    printf("Total time: %.3f ms (%.4f ms/generation)\n", ms, ms / ngen);

    // Get result
    cudaMemcpy(h_result, d_grid, nbytes, cudaMemcpyDeviceToHost);

    printf("\nFinal state:\n");
    print_grid(h_result, width, height);

    // Verify against CPU reference
    for (int g = 0; g < ngen; g++) {
        game_of_life_reference(h_ref, h_ref_tmp, width, height);
        int* tmp = h_ref;
        h_ref = h_ref_tmp;
        h_ref_tmp = tmp;
    }

    int match = 1;
    for (int i = 0; i < width * height; i++) {
        if (h_result[i] != h_ref[i]) { match = 0; break; }
    }
    printf("Result: %s\n", match ? "PASS" : "FAIL");

    cudaFree(d_grid); cudaFree(d_next);
    free(h_grid); free(h_result); free(h_ref); free(h_ref_tmp);
    cudaEventDestroy(start); cudaEventDestroy(stop);

    return match ? 0 : 1;
}
