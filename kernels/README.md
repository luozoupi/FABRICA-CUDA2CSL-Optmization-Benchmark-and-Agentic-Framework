## ✅ Recommended (Direct CUDA Kernel Comparisons)

These examples correspond to well-known HPC kernels that can be implemented
naturally in CUDA and are suitable for kernel-level comparison.

- GEMV (all GEMV compute examples)
- GEMV with Checkerboard Pattern
- GEMV with Collective Communications
- GEMM with Collective Operations
- Single Tile Matvec

- 25-Point Stencil
- 3D 7-Point Stencil

- SpMV (Sparse Matrix-Vector Multiplication)

- Residual
- Power Method

- Conjugate Gradient
- Preconditioned Conjugate Gradient
- BiCGSTAB

- Cholesky

- 3D FFT

- Conway’s Game of Life

These kernels are common in:
- HPC benchmarks
- CUDA programming tutorials
- GPU numerical libraries

They represent good candidates for **CUDA ↔ Cerebras kernel translation experiments**.

---

## ⚠️ Possible but Secondary (Algorithm-Level or Multi-Kernel)

These examples are still CUDA-expressible but represent higher-level algorithms
composed of multiple kernels.

- Power Method
- Conjugate Gradient
- Preconditioned Conjugate Gradient
- BiCGSTAB
- Cholesky
- 3D FFT

They may involve:
- multiple kernels
- reductions
- synchronization
- iterative solver pipelines

These are better suited for **algorithm-level comparisons rather than single kernel translation**.

---

## ❌ Cerebras-Specific Programming Model (Not Direct CUDA Kernel Equivalents)

These examples mainly illustrate Cerebras architecture features such as routing,
fabric communication, or runtime mechanisms. They do not correspond to standalone CUDA kernels.

### Language / Programming Model
- GEMV 0: Basic CSL Syntax
- GEMV 1: A Complete Program
- Topic 1: Arrays and Pointers
- Topic 2: Libraries
- Topic 10: `@map` Builtin

### Runtime / Debugging
- Topic 12: Debug Library
- Topic 13: Simprint Library
- Topic 13: WSE-3 Microthreads

### Memory / Host-Device Transfer
- GEMV 2: Memory DSDs
- GEMV 3: H2D and D2H Memcpy
- GEMV 4: Parameters
- GEMV 9: Memcpy Streaming Mode
- SdkLayout 4: Host-to-device and device-to-host data streaming

### Fabric / Routing / Dataflow
- GEMV 6: Routes and Fabric DSDs, Part I
- GEMV 7: Routes and Fabric DSDs, Part II
- GEMV 8: Routes and Fabric DSDs, Part III

- Topic 5: Sentinels
- Topic 6: Switches
- Topic 7: Switches and Control Entrypoints
- Topic 8: Filters
- Topic 9: FIFOs

- Topic 11: Collective Communications
- Topic 14: Color Swap

### Pipeline / Streaming Infrastructure
- Pipeline 1: Redirect fabin to fabout
- Pipeline 2: Attach a FIFO to H2D
- Pipeline 3: Add an artificial halo

### SDK Layout / Hardware Connectivity
- SdkLayout 1: Introduction
- SdkLayout 2: Basic routing
- SdkLayout 3: Ports and connections

These examples focus on **Cerebras-specific system abstractions** rather than
general-purpose compute kernels.

---

## Summary

| Category | Purpose |
|--------|--------|
| Recommended | Best candidates for CUDA ↔ Cerebras kernel translation |
| Possible | Algorithm-level comparisons involving multiple kernels |
| Cerebras-Specific | Demonstrates architecture/runtime features |

The primary focus of this project is the **Recommended kernel set**.