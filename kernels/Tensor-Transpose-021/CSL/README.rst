Tensor Transpose 021 (abc -> acb)
=================================

Single-PE 3D tensor transpose, permutation 021: ``B[i][k][j] = A[i][j][k]``
(swap the last two axes; numpy ``A.transpose(0, 2, 1)``).

Ported from the GPU-accelerated quantum-chemistry package
``MatthewRHermes/mrh`` (``gpu/src/pm/device_cuda.cpp``, ``_transpose_021``),
one of a family of tensor index-permutation kernels used to reshape
density-fitting / AO2MO intermediates between contraction steps. A pure
data-movement / index-permutation kernel: no arithmetic, every element copied
to a permuted location.

Index arithmetic (row-major)::

    in_idx  = (i*ax2 + j)*ax3 + k     // A[i][j][k]
    out_idx = (i*ax3 + k)*ax2 + j     // B[i][k][j]

Run (WSE-3)::

    bash commands_wse3.sh

Compiles ``layout.csl`` (single PE per the ``width``x``height`` rectangle holds
the whole tensor), launches ``compute``, reads back ``B`` + the timer, verifies
bit-exact against numpy, prints ``cycles_send`` and ``SUCCESS!``.
