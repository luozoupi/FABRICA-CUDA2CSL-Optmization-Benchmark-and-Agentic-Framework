# Registered task catalog

Generated from the current registry and task specifications. These entries are
source-complete; SDK and hardware validation must be performed on the target host.

| Registry name | Reference folder | Metric | Split |
| --- | --- | --- | --- |
| GEMV | `GEMV` | unspecified | train |
| GEMM | `GEMM` | unspecified | train |
| GEMM-Collectives-2D | `GEMM Collectives 2D` | unspecified | train |
| GEMV-Checkerboard | `GEMV Checkerboard` | cycles | test |
| GEMV-Collectives-2D | `GEMV Collectives 2D` | unspecified | train |
| Cholesky | `Cholesky` | unspecified | test |
| Wide-Multiplication | `Wide Multiplication` | unspecified | test |
| Single-Tile-Matvec | `Single Tile Matvec` | unspecified | test |
| Game-of-Life | `Game of Life` | unspecified | unspecified |
| Laplacian2D-Halo | `Laplacian2D-Halo` | unspecified | test |
| Laplacian2D-Reduce | `Laplacian2D-Reduce` | unspecified | test |
| LorenzoPredictor-Tile | `LorenzoPredictor-Tile` | unspecified | test |
| Residual | `Residual` | unspecified | test |
| Jacobi-2D-5pt | `Jacobi-2D-5pt` | unspecified | unspecified |
| Histogram | `Histogram` | correctness_only | test |
| SpMV-CSR | `SpMV-CSR` | cycles | test |
| Histogram-1PE | `Histogram-1PE` | cycles | test |
| Histogram-Inline | `Histogram-Inline` | cycles | test |
| GEMV-RowPart | `GEMV-RowPart` | cycles | test |
| Stencil7pt-1PE | `Stencil7pt-1PE` | cycles | test |
| DFT-1PE | `DFT-1PE` | cycles | test |
| GEMM-1PE | `GEMM-1PE` | cycles | test |
| Tensor-Transpose-021 | `Tensor-Transpose-021` | unspecified | test |
| PDFT-Pi-Pipeline | `PDFT-Pi-Pipeline` | unspecified | test |
| ReLU-1PE | `ReLU-1PE` | cycles | test |
| Sum-Reduction-1PE | `Sum-Reduction-1PE` | cycles | test |
| Sigmoid-1PE | `Sigmoid-1PE` | cycles | test |
| Max-Reduction-1PE | `Max-Reduction-1PE` | cycles | test |
| RMSNorm-1PE | `RMSNorm-1PE` | cycles | test |
| GELU-1PE | `GELU-1PE` | cycles | test |
| MSE-Loss-1PE | `MSE-Loss-1PE` | cycles | test |
| SAXPY-1PE | `SAXPY-1PE` | cycles | test |
| Dot-Product-1PE | `Dot-Product-1PE` | cycles | test |
| Softmax-1PE | `Softmax-1PE` | cycles | test |
| Prefix-Sum-1PE | `Prefix-Sum-1PE` | cycles | test |
| SiLU-1PE | `SiLU-1PE` | cycles | test |
| L2-Norm-1PE | `L2-Norm-1PE` | cycles | test |
| Cross-Entropy-Loss-1PE | `Cross-Entropy-Loss-1PE` | cycles | test |
| ParReduce-Sum | `ParReduce-Sum` | cycles | test |
| ParBroadcast-Scale | `ParBroadcast-Scale` | cycles | test |
| ParDot-Product | `ParDot-Product` | cycles | test |
| RowParallel-Softmax | `RowParallel-Softmax` | cycles | test |
| Attention-QP | `Attention-QP` | cycles | test |
| Attention-1PE | `Attention-1PE` | cycles | test |
| 7pt-Stencil | `7-Point Stencil` | unspecified | test |
| BiCGSTAB | `BiCGSTAB` | unspecified | unspecified |
| CG | `Conjugate Gradient` | unspecified | unspecified |
| Power-Method | `Power Method` | unspecified | unspecified |
| Preconditioned-CG | `Preconditioned CG` | unspecified | unspecified |
| Mandelbrot | `Mandelbrot` | cycles | test |
| FFT-1D-2D | `FFT 1D-2D` | cycles | test |
| MC-Particle-Transport | `MC-Particle-Transport` | unspecified | unspecified |

Registry count: **52**.

Additional unregistered reference folders: `25-Point Stencil`, `3D FFT`, `SpMV`, `SpMV Hypersparse`.

`Game-of-Life` and `MC-Particle-Transport` are legacy registry entries without
`spec.yaml`; they use the reference host verifier and framework defaults.
