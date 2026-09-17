/*
 * CUDA 7-point stencil: y = A*x where A is the 3D 7-point Laplacian-style operator.
 *
 *   y[i,j,k] = c_center*x[i,j,k]
 *            + c_west*x[i-1,j,k] + c_east*x[i+1,j,k]
 *            + c_south*x[i,j-1,k] + c_north*x[i,j+1,k]
 *            + c_bottom*x[i,j,k-1] + c_top*x[i,j,k+1]
 *   (Dirichlet boundary: out-of-range neighbors contribute 0.)
 *
 * This is the HAND-WRITTEN-COMPUTE variant of 7pt-Stencil: instead of delegating to
 * the stencil_3d_7pts + allreduce libraries (see kernels/7-Point Stencil), the compute
 * is the explicit 7-term weighted sum over a grid held on a single PE, so a CSL
 * translation expresses the actual stencil arithmetic and is cycle-scoreable.
 */

#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>

__global__ void stencil_7pt(const float* __restrict__ in, float* __restrict__ out,
                            int Nx, int Ny, int Nz,
                            float cc, float cw, float ce,
                            float cs, float cn, float cb, float ct) {
    for (int iz = 0; iz < Nz; iz++)
      for (int iy = 0; iy < Ny; iy++)
        for (int ix = 0; ix < Nx; ix++) {
            int idx = iz * Ny * Nx + iy * Nx + ix;
            float v = cc * in[idx];
            if (ix > 0)        v += cw * in[idx - 1];
            if (ix < Nx - 1)   v += ce * in[idx + 1];
            if (iy > 0)        v += cs * in[idx - Nx];
            if (iy < Ny - 1)   v += cn * in[idx + Nx];
            if (iz > 0)        v += cb * in[idx - Ny * Nx];
            if (iz < Nz - 1)   v += ct * in[idx + Ny * Nx];
            out[idx] = v;
        }
}

int main(void) {
    // Host driver omitted; the kernel above is the translation target.
    // Reference verification (out == numpy stencil) is in the CSL bundle's run.py.
    return 0;
}
