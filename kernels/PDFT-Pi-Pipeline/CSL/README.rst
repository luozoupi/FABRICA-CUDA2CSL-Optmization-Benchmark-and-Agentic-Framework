PDFT On-Top Pair-Density Pipeline (program-level)
=================================================

Single-PE reference for the on-top pair density used in multiconfiguration
pair-density functional theory (PDFT). Per grid point ``g``::

    k_g[a] = mo_grid[g][j] * mo_grid[g][k]        (a = j*ncas+k, outer product)
    Pi[g]  = sum_{a,b} k_g[a] * cascm2[a][b] * k_g[b]   (quadratic form)

Ported/simplified from the PDFT pair-density kernels in
``MatthewRHermes/mrh`` (``gpu/src/pm/device_cuda.cpp``: ``_make_gridkern``,
``_make_buf_pdft``, ``_make_Pi_final``).

**Program-level task.** The CUDA side is THREE data-dependent kernels launched
in sequence; each stage reads the buffer the previous stage wrote::

    stage 1  make_gridkern : gridkern[g][a] = mo[g][j]*mo[g][k]
    stage 2  make_buf      : buf[g][b] = sum_a gridkern[g][a]*cascm2[a][b]
    stage 3  make_Pi_final : Pi[g] = sum_b gridkern[g][b]*buf[g][b]

The CSL "program" is the orchestration of these three index-math stages plus
their intermediate buffers (``gridkern``, ``buf``) on a single PE. Translating
this task means reproducing the whole pipeline, not one kernel.

Run (WSE-3)::

    bash commands_wse3.sh

Copies ``mo_grid`` + ``cascm2`` to the device, launches ``compute`` (the 3-stage
program), reads back ``Pi`` + the timer, verifies against the numpy einsum
quadratic form, prints ``cycles_send`` and ``SUCCESS!``.
