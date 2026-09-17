/*
 * CUDA DFT (direct O(N^2) discrete Fourier transform):
 *   X[k] = sum_{n=0..N-1} x[n] * exp(-2*pi*i*k*n / N)
 *
 * This is the HAND-WRITTEN-COMPUTE variant in the FFT family: instead of calling a
 * cuFFT / SDK FFT library (see kernels/3D FFT, kernels/FFT 1D-2D), the transform is the
 * explicit complex multiply-accumulate over all (k, n) pairs, so a CSL translation must
 * express the actual arithmetic. Single PE, real input. The twiddle factors
 * cos(2*pi*k*n/N) / sin(...) are precomputed on the host (no on-device trig) and passed
 * in — the device does the pure complex MAC, which is the compute being measured.
 *
 *   Xre[k] = sum_n x[n] *  cos(2*pi*k*n/N)
 *   Xim[k] = sum_n x[n] * -sin(2*pi*k*n/N)
 */

#include <stdio.h>
#include <math.h>

void dft(const float* x, const float* cosT, const float* sinT,
         float* Xre, float* Xim, int N) {
    for (int k = 0; k < N; k++) {
        float re = 0.0f, im = 0.0f;
        for (int n = 0; n < N; n++) {
            float c = cosT[k * N + n];   //  cos(2*pi*k*n/N)
            float s = sinT[k * N + n];   // -sin(2*pi*k*n/N)
            re += x[n] * c;
            im += x[n] * s;
        }
        Xre[k] = re;
        Xim[k] = im;
    }
}

int main(void) {
    // Host driver omitted; dft() above is the translation target. Reference
    // verification (X == numpy fft) is in the CSL bundle's run.py.
    return 0;
}
