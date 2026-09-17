Laplacian2D-Halo
================

Minimal 5-point 2D Laplacian stencil with zero-boundary halo exchange on a
2×2 PE mesh. Designed to be the **smallest** kernel in the xkernel suite that
exercises 4-cardinal fabric halo exchange in isolation, with no reduction,
no library imports, and no checkerboard parity.

Algorithm
---------

One iteration of::

    new[i, j] = 0.25 * (old[i-1, j] + old[i+1, j] +
                        old[i, j-1] + old[i, j+1])

with ``old[i, j] = 0`` for ``i`` or ``j`` outside the global ``M × N`` grid.

Wafer layout
------------

- Mesh: 2 × 2 PEs.
- Per-PE tile: ``Mt × Nt = 4 × 4`` ``f32`` (64 bytes). Global grid: 8 × 8.
- Per-PE halo arrays: ``halo_n[Nt]``, ``halo_s[Nt]``, ``halo_e[Mt]``,
  ``halo_w[Mt]``. Edge PEs leave the missing halos at zero (the kernel's
  initial ``@zeros`` allocation), so boundary cells naturally read zero
  for their missing neighbors.

Colors and routing
------------------

Four cardinal fabric colors. **The color name describes the direction
of data travel**, not the direction the sender faces:

- ``C_N`` (color 8): data travels north. Sender is south of receiver.
- ``C_S`` (color 9): data travels south.
- ``C_E`` (color 10): data travels east.
- ``C_W`` (color 11): data travels west.

So a PE wanting to "send its top row up to its north neighbor" sends on
``C_N``; the north neighbor receives on ``C_N``. Each color is routed
``RAMP → {NORTH|SOUTH|EAST|WEST}`` at the sender row/column and
``{SOUTH|NORTH|WEST|EAST} → RAMP`` at the receiver, matching the route
table in ``layout.csl``.

Per-iteration task flow
-----------------------

1. ``step(iters)`` activates ``SEND`` and sets the iteration counter.
2. ``SEND`` stages the leftmost/rightmost columns into contiguous
   ``col_send_w[Mt]`` / ``col_send_e[Mt]`` scratch buffers, then issues 4
   async fabric sends (one per non-edge direction) plus 4 async fabric
   receives (one per non-edge direction). Each receive ``@fmovs(halo_dsd,
   fab_rx_dsd, .{.async=true, .activate=RX_DONE_TID})`` fires
   ``RX_DONE_TID`` once when all ``extent`` wavelets have landed.
3. ``RX_DONE`` increments ``num_halos_received``; when it equals the
   comptime-derived ``num_halos_expected`` for this PE, it activates
   ``COMPUTE``.
4. ``COMPUTE`` evaluates the stencil into ``new_tile``, copies ``new_tile``
   back into ``tile`` so the next iteration sends the right rows,
   decrements ``remaining_iters``, then re-activates ``SEND`` or activates
   ``EXIT``.
5. ``EXIT`` calls ``sys_mod.unblock_cmd_stream()`` so the host launch
   returns.

Why a 2×2 mesh is the minimum interesting case
----------------------------------------------

- Each PE has exactly 2 neighbors (it's a corner of the mesh), so the
  ``num_halos_expected`` counter is **2** for every PE — the smallest value
  that still requires waiting for any halos at all.
- No PE has all 4 neighbors, so the kernel exercises edge-conditional sends
  and edge-conditional receives in every iteration.
- The total per-PE memory is tiny (~150 bytes), so the kernel fits
  trivially in SRAM and the simulator runs in seconds.

Build and run
-------------

::

   cd CSL
   bash commands_wse3.sh

Expected output (one stencil step on the deterministic
``A = arange(64).reshape(8, 8)`` input)::

   Laplacian2D-Halo: M=8, N=8, mesh=2x2, tile=4x4, iters=1
   max abs diff = 0.000e+00
   SUCCESS!

For ``iters > 1``, pass through ``run.py``::

   cs_python run.py --name out --iters 5

Per-PE memory and queue budget
------------------------------

================================  ============================
  Resource                          Per PE
================================  ============================
  ``tile``, ``new_tile``            ``2 × Mt × Nt × 4`` bytes (= 128 B)
  4 halo arrays                     ``2 × (Mt + Nt) × 4`` bytes (= 64 B)
  2 column-staging buffers          ``2 × Mt × 4`` bytes (= 32 B)
  Output queues used                IDs 2..5 (one per cardinal)
  Input queues used                 IDs 2..5 (one per cardinal)
  Local task IDs used               12..15 (SEND, RX_DONE, COMPUTE, EXIT)
================================  ============================

The kernel is well below the ~48 KB per-PE SRAM ceiling.

Why this kernel exists
----------------------

Prior reviewer A/B sweeps showed the agentic CUDA→CSL translator saturates
at 1/4 pass on the 4 "hard" fabric kernels (Game-of-Life, Residual,
7pt-Stencil, FFT-1D-2D). Each of those combines halo exchange with other
complications (8-color checkerboard, reductions, multi-file bundles).
Laplacian2D-Halo is the **simplest possible halo-exchange kernel** in the
suite: 4 colors, 4 directions, 4-line stencil, NumPy-verifiable.

If the agent passes Laplacian2D-Halo but still fails the others, the gap
is the additional complications — not the halo idiom itself.
If the agent fails even Laplacian2D-Halo, the halo idiom is the bottleneck.

The companion kernels ``Laplacian2D-Reduce`` and ``LorenzoPredictor-Tile``
extend this one with (respectively) a global reduction and an asymmetric
3-direction halo, so the diagnostic can be graded.
