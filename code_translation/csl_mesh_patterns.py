"""Wafer-scale CSL pattern catalog.

Each MeshPattern captures a canonical multi-PE CSL idiom with a verbatim
snippet from a known-good source (primarily WaferLLM, OSDI'25,
https://arxiv.org/abs/2502.04563). The retrieve() function scores patterns
against a translation query (target_relpath + cuda_code + analysis text)
and returns a markdown block to inject into the translation prompt.

The catalog is intentionally tiny (single-digit entries): the goal is to
seed the agent with the *vocabulary* of wafer-scale idioms it currently
lacks, not to provide a kernel library. When the catalog grows beyond
~30 entries, switch retrieval to TF-IDF (see knowledge/cerebras_docs.py
for the established pattern).
"""

from dataclasses import dataclass
from typing import Tuple


@dataclass(frozen=True)
class MeshPattern:
    """One wafer-scale CSL idiom.

    Fields:
      name              kebab-or-snake identifier the agent can reference
      when_to_use       one-paragraph rule the agent reads first to gate adoption
      trigger_keywords  lowercase substrings scored against the query
      csl_snippet       verbatim CSL, 8-25 lines, original indentation
      source            "path/to/file:line-range" for citation
      gotcha            one-line warning the agent must respect
      inferred          True if the snippet was synthesized rather than copied
                        from a real reference (mark so future audits catch them)
    """
    name: str
    when_to_use: str
    trigger_keywords: Tuple[str, ...]
    csl_snippet: str
    source: str
    gotcha: str
    inferred: bool = False


# =============================================================================
# Pattern 1: ping-pong async buffers (double-buffered tiles + pointer swap)
# Source: WaferLLM/MeshGEMM/WSE-3/src/meshgemm.csl:12-26 + :123-140
# =============================================================================
PING_PONG_ASYNC_BUFFERS = MeshPattern(
    name="ping_pong_async_buffers",
    when_to_use=(
        "Use when the kernel streams data through PEs across multiple compute "
        "steps (e.g., per-step broadcast of A/B tiles in distributed GEMM, or "
        "per-step shift of activations). Allocate TWO tiles per streamed "
        "operand and swap pointers each step so the next async fabric DMA can "
        "fill the recv buffer while the current step's compute consumes the "
        "send buffer. Without this, compute and fabric serialize and you lose "
        "the wafer's main perf lever (compute/comm overlap)."
    ),
    trigger_keywords=(
        "gemm", "matmul", "matrix multiply", "streaming", "pipeline",
        "broadcast", "double buffer", "overlap", "shift",
    ),
    csl_snippet="""\
var X_0_tile: [Mt*Kt]f16 = @zeros([Mt*Kt]f16);
var X_1_tile: [Mt*Kt]f16 = @zeros([Mt*Kt]f16);
var ptr_X: [*]f16 = &X_0_tile;
var X_dsd = @get_dsd(mem1d_dsd, .{ .tensor_access = |i|{Mt} -> X_0_tile[i] });

var W_0_tile: [Kt*Nt]f16 = @zeros([Kt*Nt]f16);
var W_1_tile: [Kt*Nt]f16 = @zeros([Kt*Nt]f16);
var ptr_W: [*]f16 = &W_0_tile;
var W_dsd = @get_dsd(mem1d_dsd, .{ .tensor_access = |i|{Nt} -> W_0_tile[i] });

// Per-step compute swaps send/recv pointers and patches the pre-built DSD:
fn mm_compute() void {
    swap_ptr = ptr_X_send;
    ptr_X_send = ptr_X_recv;
    ptr_X_recv = swap_ptr;
    // ... same swap for W ...
    if (step < P) {
        comm_mod.two_hop_comm(ptr_X_send, ptr_W_send, ptr_X_recv, ptr_W_recv);
        X_dsd = @set_dsd_base_addr(X_dsd, ptr_X_send);
        W_dsd = @set_dsd_base_addr(W_dsd, ptr_W_send);
        // ... per-k @map(gemv_static_step_X, W_dsd) on the send tile ...
    }
}""",
    source="WaferLLM/MeshGEMM/WSE-3/src/meshgemm.csl:12-26,123-159",
    gotcha=(
        "Build the mem1d_dsd ONCE at module scope; only patch the base "
        "address with @set_dsd_base_addr per step. Rebuilding the DSD inside "
        "the loop is the common-mistake performance cliff."
    ),
)


# =============================================================================
# Pattern 2: two-hop async fabric DMA (simultaneous X and Y shifts)
# Source: WaferLLM/MeshGEMM/WSE-3/src/comm_lib/comm_pe.csl:183-200
# =============================================================================
TWO_HOP_ASYNC_FABRIC_DMA = MeshPattern(
    name="two_hop_async_fabric_dma",
    when_to_use=(
        "Use when a step needs to shift one tile along X AND another tile "
        "along Y at the same time (canonical pattern in mesh GEMM / Cannon / "
        "two-hop systolic schemes). The four @mov16 calls below issue both "
        "halves concurrently — `.async=true` returns immediately, "
        "`.unblock=…` releases the next compute task when the send finishes, "
        "`.activate=…` triggers the compute task when the recv lands."
    ),
    trigger_keywords=(
        "shift", "systolic", "cannon", "two-hop", "fabric dma",
        "concurrent", "async", "mov16", "matmul",
    ),
    csl_snippet="""\
fn two_hop_comm(left_matrix_send_buffer_ptr: [*]f16,
                right_matrix_send_buffer_ptr: [*]f16,
                left_matrix_recv_buffer_ptr: [*]f16,
                right_matrix_recv_buffer_ptr: [*]f16) void {

    left_matrix_send_dsd  = @set_dsd_base_addr(left_matrix_send_dsd,  left_matrix_send_buffer_ptr);
    right_matrix_send_dsd = @set_dsd_base_addr(right_matrix_send_dsd, right_matrix_send_buffer_ptr);
    left_matrix_recv_dsd  = @set_dsd_base_addr(left_matrix_recv_dsd,  left_matrix_recv_buffer_ptr);
    right_matrix_recv_dsd = @set_dsd_base_addr(right_matrix_recv_dsd, right_matrix_recv_buffer_ptr);

    @load_to_dsr(left_send_dsr,  left_matrix_send_dsd);
    @load_to_dsr(left_recv_dsr,  left_matrix_recv_dsd);
    @load_to_dsr(right_send_dsr, right_matrix_send_dsd);
    @load_to_dsr(right_recv_dsr, right_matrix_recv_dsd);

    @mov16(x_out_dsr,     left_send_dsr,  .{.async=true, .unblock=x_finish_id});
    @mov16(left_recv_dsr, x_in_dsr,       .{.async=true, .activate=x_finish_id});

    @mov16(y_out_dsr,      right_send_dsr, .{.async=true, .unblock=y_finish_id});
    @mov16(right_recv_dsr, y_in_dsr,       .{.async=true, .activate=y_finish_id});
}""",
    source="WaferLLM/MeshGEMM/WSE-3/src/comm_lib/comm_pe.csl:183-200",
    gotcha=(
        "x_finish_id and y_finish_id must be SEPARATE local task IDs — "
        "sharing one ID causes the X-direction and Y-direction shifts to "
        "race on the same activation. Reserve two distinct task IDs in "
        "[8,30] per layout.csl."
    ),
)


# =============================================================================
# Pattern 3: two-phase tree allreduce along Y
# Source: WaferLLM/MeshGEMV/WSE-3/src/comm_lib/comm_pe.csl:184-241
# =============================================================================
TWO_PHASE_TREE_ALLREDUCE_Y = MeshPattern(
    name="two_phase_tree_allreduce_y",
    when_to_use=(
        "Use when every PE in a column produces a partial vector that must "
        "be summed across the column and broadcast back to every PE in that "
        "column. Examples: distributed GEMV (sum partial products), residual "
        "(sum of squared errors), Cholesky panel reductions, dot products, "
        "any L2-norm. The two-phase scheme splits the column into groups so "
        "phase-1 reductions run in parallel trees, then phase-2 cascades the "
        "group roots to a single root, then broadcast spreads the result. "
        "Tune `group_num` in layout.csl to balance tree depth vs fan-out."
    ),
    trigger_keywords=(
        "reduce", "allreduce", "reduction", "sum", "dot product",
        "residual", "norm", "gemv", "accumulate", "tree", "fadd",
    ),
    csl_snippet="""\
fn two_tree_allreduce_y(vector_buf_ptr: [*]f16) void {
    vector_buf_dsd = @set_dsd_base_addr(vector_buf_dsd, vector_buf_ptr);
    @load_to_dsr(vector_buf_dsr, vector_buf_dsd);

    // Phase 1: parallel reductions inside each group of pe_num_group PEs.
    if (is_group_root_py) {
        if (!is_group_last_py) {
            @faddh(vector_buf_dsd, mv_up_recv,   vector_buf_dsr);
        }
        @faddh(vector_buf_dsd, mv_down_recv, vector_buf_dsr);
    } else if (is_group_first_py) {
        @fmovh(mv_down_send, vector_buf_dsr);
    } else if (is_group_last_py) {
        @fmovh(mv_up_send,   vector_buf_dsr);
    } else {
        if (is_top_half_py) {
            @faddh(mv_down_send, mv_down_recv, vector_buf_dsr);
        } else {
            @faddh(mv_up_send,   mv_up_recv,   vector_buf_dsr);
        }
    }

    // Phase 2: group-roots reduce to a single root (root_2nd_phase).
    // ... mirror structure using up_reduce_*/down_reduce_* colors ...

    // Phase 3: broadcast result from root_2nd_phase back to every PE in the
    // column via up_bd_*/down_bd_* colors.
}""",
    source="WaferLLM/MeshGEMV/WSE-3/src/comm_lib/comm_pe.csl:184-241",
    gotcha=(
        "Allocate SEPARATE fabric color pairs for the three phases "
        "(intra-group reduce, inter-group reduce, broadcast). Reusing one "
        "pair causes the broadcast to collide with stragglers from phase 1."
    ),
)


# =============================================================================
# Pattern 4: scatter-compute-allreduce pipeline (GEMV orchestration)
# Source: WaferLLM/MeshGEMV/WSE-3/src/meshgemv.csl:69-79
# =============================================================================
SCATTER_COMPUTE_ALLREDUCE_PIPELINE = MeshPattern(
    name="scatter_compute_allreduce_pipeline",
    when_to_use=(
        "Canonical orchestration for a distributed GEMV-class kernel: per-PE "
        "local matmul over a row-tile of the matrix, followed immediately by "
        "tree allreduce along Y to assemble the global output vector. The "
        "@map call iterates the X scalar broadcast across each W column; "
        "@fmach inside gemv_static_step accumulates into res via DSR. After "
        "all local work is done, hand off to two_tree_allreduce_y, then "
        "re-arm the entrypoint (`meshgemv_entry()`) so the next host launch "
        "fires the same dataflow."
    ),
    trigger_keywords=(
        "gemv", "matvec", "vector matrix", "distributed gemv",
        "scatter", "reduce", "allreduce", "@map", "fmach",
    ),
    csl_snippet="""\
fn gemv_static_step(curL: f16) void {
    @fmach(res_dest_dsr, res_src0_dsr, W_src1_dsr, curL);
}

// Per-PE: local matmul, then global allreduce.
fn mv_compute() void {
    @load_to_dsr(res_dest_dsr, res_dsd, .{ .save_address = false });
    @load_to_dsr(res_src0_dsr, res_dsd, .{ .save_address = false });
    @load_to_dsr(W_src1_dsr,   W_dsd,   .{ .save_address = true  });

    @map(gemv_static_step, X_dsd);              // local M-by-N FMA pass

    comm_mod.two_tree_allreduce_y(ptr_res);     // sum partial vectors along Y
    meshgemv_entry();                           // re-arm for next launch
}""",
    source="WaferLLM/MeshGEMV/WSE-3/src/meshgemv.csl:64-79",
    gotcha=(
        "two_tree_allreduce_y is BLOCKING from the caller's view (it ends "
        "with the broadcast landing) — only call meshgemv_entry() AFTER it, "
        "never in parallel. The host-side launch counts on this serialization."
    ),
)


# =============================================================================
# Pattern 5: SUMMA broadcast via <collectives_2d>
# Source: WaferLLM/SUMMA/src/summa.csl:99-114 + SUMMA/src/layout.csl:35-45
# =============================================================================
SUMMA_2D_COLLECTIVES_BROADCAST = MeshPattern(
    name="summa_2d_collectives_broadcast",
    when_to_use=(
        "Use when you want the canonical, off-the-shelf 2D GEMM (SUMMA) and "
        "are willing to trade peak performance for code simplicity. Each "
        "step k, the PE column k owns the A panel and broadcasts it along "
        "rows; the PE row k owns the B panel and broadcasts it along "
        "columns; every PE accumulates A_k * B_k into its C tile. Uses the "
        "Cerebras `<collectives_2d>` library — easier than rolling custom "
        "fabric colors (Pattern 2 / 6), but adds ~10-20% latency overhead "
        "vs the two-hop systolic scheme. Prefer this for first-cut "
        "translations; switch to two-hop only when profiling shows "
        "fabric-bound time."
    ),
    trigger_keywords=(
        "summa", "2d gemm", "gemm collectives", "matmul",
        "collectives_2d", "broadcast",
    ),
    csl_snippet="""\
// In layout.csl: configure 2D collectives with separate X/Y color pairs
// and separate X/Y entrypoint task IDs.
const c2d_params = c2d.get_params(Px, Py, .{
    .x_colors      = .{ @get_color(0),          @get_color(1) },
    .x_entrypoints = .{ @get_local_task_id(8),  @get_local_task_id(9)  },
    .y_colors      = .{ @get_color(4),          @get_color(5) },
    .y_entrypoints = .{ @get_local_task_id(10), @get_local_task_id(11) },
});

// In compute file (summa.csl): step-wise simultaneous row+column broadcast.
fn mm() void {
    const Xp = if (px == step) @ptrcast([*]u32, &X_tile) else @ptrcast([*]u32, &X_buffer);
    const Wp = if (py == step) @ptrcast([*]u32, &W_tile) else @ptrcast([*]u32, &W_buffer);
    mpi_x.broadcast(step, Xp, Mt * Kt / 2, x_task_id);   // length in u32 words
    mpi_y.broadcast(step, Wp, Kt * Nt / 2, y_task_id);
}
task x_done() void { @activate(compute_task_id); }
task y_done() void { @unblock(compute_task_id);  }""",
    source="WaferLLM/SUMMA/src/summa.csl:99-114 + SUMMA/src/layout.csl:35-45",
    gotcha=(
        "Broadcast lengths are in u32 WORDS (4 bytes), not f16 elements — "
        "for an Mt*Kt f16 tile, pass `Mt * Kt / 2`. Off-by-2 is the most "
        "common collectives_2d bug."
    ),
)


# =============================================================================
# Pattern 6: fabric color palette declaration
# Source: WaferLLM/MeshGEMM/WSE-3/src/layout.csl:1-22
# =============================================================================
FABRIC_COLOR_PALETTE = MeshPattern(
    name="fabric_color_palette",
    when_to_use=(
        "Use when the kernel needs multiple independent fabric color groups "
        "(e.g., X-shift, Y-shift, reverse-X-shift). Declare the colors at "
        "the TOP of layout.csl with explicit `@get_color(N)` numeric "
        "assignments, then pass them as compile-time params to the comm "
        "module. WSE-3 reserves colors 0,2,3 for memcpy and the LAUNCH "
        "color; user colors should start at 1 (small) or 4+ (safe). Keep "
        "the palette dense and contiguous — gaps are fine but each color "
        "consumes router resources."
    ),
    trigger_keywords=(
        "layout", "color", "fabric color", "routing",
        "@get_color", "palette",
    ),
    csl_snippet="""\
param P: i16;
param Mt: i16;
param Kt: i16;
param Nt: i16;

// Forward X shifts (3 independent streams to allow overlapping waves):
const X_0: color = @get_color(1);
const X_1: color = @get_color(2);
const X_2: color = @get_color(3);

// Forward Y shifts:
const Y_0: color = @get_color(4);
const Y_1: color = @get_color(5);
const Y_2: color = @get_color(6);

// Reverse X shifts (used by every-other step in the two-hop scheme):
const X_shift_re_0: color = @get_color(7);
const X_shift_re_1: color = @get_color(8);
const X_shift_re_2: color = @get_color(9);

const memcpy = @import_module("<memcpy/get_params>", .{ .width = P, .height = P });""",
    source="WaferLLM/MeshGEMM/WSE-3/src/layout.csl:1-27",
    gotcha=(
        "On WSE-3 the memcpy infrastructure reserves specific colors — "
        "consult the SDK's get_params() to see which are taken before "
        "allocating user colors. Collisions silently corrupt fabric traffic."
    ),
)


# =============================================================================
# Pattern 7: DSD base-addr swap in the inner loop (compute kernel)
# Source: WaferLLM/MeshGEMM/WSE-3/src/meshgemm.csl:119-160
# =============================================================================
DSD_BASE_ADDR_SWAP_INNER_LOOP = MeshPattern(
    name="dsd_base_addr_swap_inner_loop",
    when_to_use=(
        "Use whenever an inner loop walks across rows/columns of a tile and "
        "you need to feed each successive row to a vectorized op. Build the "
        "mem1d_dsd ONCE at module scope; in the loop, use "
        "@set_dsd_base_addr to point it at the active tile pointer, then "
        "@increment_dsd_offset to advance row-by-row. Combine with @map and "
        "@fmach for the inner matmul kernel. This is the canonical inner "
        "loop for both mesh GEMM (per-k accumulation) and stencil compute."
    ),
    trigger_keywords=(
        "inner loop", "dsd", "@fmach", "@map", "@increment_dsd_offset",
        "matmul", "inner product", "accumulate", "k loop",
    ),
    csl_snippet="""\
fn gemv_static_step_X(curW: f16) void {
    @fmach(out_dest_dsr, out_src0_dsr, X_src1_dsr, curW);
}

fn mm_compute() void {
    // ... pointer swap + two_hop_comm omitted ...
    X_dsd = @set_dsd_base_addr(X_dsd, ptr_X_send);
    W_dsd = @set_dsd_base_addr(W_dsd, ptr_W_send);
    X_dsd = @set_dsd_length(X_dsd, @bitcast(u16, Mt));
    W_dsd = @set_dsd_length(W_dsd, @bitcast(u16, Nt));

    for (@range(i16, Kt)) |k| {
        out_dsd = @set_dsd_base_addr(out_dsd, ptr_out);
        @load_to_dsr(out_dest_dsr, out_dsd, .{ .save_address = true  });
        @load_to_dsr(out_src0_dsr, out_dsd, .{ .save_address = true  });
        @load_to_dsr(X_src1_dsr,   X_dsd,   .{ .save_address = false });
        @map(gemv_static_step_X, W_dsd);             // outer-product per k

        X_dsd = @increment_dsd_offset(X_dsd, Mt, f16);
        W_dsd = @increment_dsd_offset(W_dsd, Nt, f16);
    }
    step += 1;
    @activate(next_step_id);
}""",
    source="WaferLLM/MeshGEMM/WSE-3/src/meshgemm.csl:119-160",
    gotcha=(
        "After the loop completes, the DSDs' internal offset has advanced "
        "Kt steps — reset with @set_dsd_base_addr at the top of the next "
        "step, or the next iteration walks past the buffer."
    ),
)


# =============================================================================
# Pattern 8: halo exchange for distributed stencils
# Source: INFERRED — no verbatim WaferLLM example; synthesised from Cerebras
# SDK fabric-routing docs and the CereSZ-II compression paper's
# distributed-Lorenzo-predictor approach (HPDC'24, IPDPS'25). Revise once we
# have the CereSZ PDF or a real WSE stencil reference.
# =============================================================================
HALO_EXCHANGE_STENCIL = MeshPattern(
    name="halo_exchange_stencil",
    when_to_use=(
        "Use for any kernel where each PE owns a tile of a 2D/3D grid and "
        "computes an update that depends on neighboring tiles' boundary "
        "rows/columns: finite-difference stencils (7-point, 9-point, 27-pt), "
        "convolution, Game of Life, image filters, distributed Lorenzo "
        "predictors (lossy compression). Each PE owns a `[H+2][W+2]` halo'd "
        "tile; each step exchanges 1-row borders with N/S/E/W neighbors via "
        "four fabric colors, then runs the local stencil kernel on the "
        "interior `[H][W]`. Border PEs supply zeros (or boundary values) "
        "instead of fabric data."
    ),
    trigger_keywords=(
        "stencil", "halo", "ghost cell", "convolution", "finite difference",
        "game of life", "7-point", "9-point", "neighbor",
        "lorenzo", "compression",
    ),
    csl_snippet="""\
// Per-PE tile with 1-cell halo on each side:
var tile: [(H+2)*(W+2)]f16 = @zeros([(H+2)*(W+2)]f16);
var north_send_dsd = @get_dsd(fabout_dsd, .{ .fabric_color = north_color,
                                              .extent = W });
var north_recv_dsd = @get_dsd(fabin_dsd,  .{ .fabric_color = south_color,
                                              .extent = W,
                                              .input_queue = @get_input_queue(1) });
// ... mirror for south/east/west; west/east have extent = H ...

fn exchange_halos() void {
    if (py > 0)        { @mov16(north_send_dsr, interior_top_row_dsd,
                                 .{.async=true, .unblock=halo_done_id}); }
    if (py < P-1)      { @mov16(north_recv_dsr, south_in_dsr,
                                 .{.async=true, .activate=halo_done_id}); }
    // ... south / east / west ...
}

fn stencil_step() void {
    exchange_halos();
    // After all four halos land, apply the local stencil over [1..H][1..W]:
    for (@range(i16, 1, H+1, 1)) |i| {
        for (@range(i16, 1, W+1, 1)) |j| {
            new_tile[i*(W+2)+j] = 0.25 * (tile[(i-1)*(W+2)+j] +
                                            tile[(i+1)*(W+2)+j] +
                                            tile[ i   *(W+2)+j-1] +
                                            tile[ i   *(W+2)+j+1]);
        }
    }
}""",
    source="[inferred] Cerebras SDK fabric-routing docs + CereSZ-II "
           "(HPDC'24 doi:10.1145/3625549.3658691, IPDPS'25)",
    gotcha=(
        "Edge PEs must skip the corresponding @mov16 or supply the boundary "
        "value — issuing a fabric send into a non-existent neighbor stalls "
        "the queue indefinitely. Always guard with `if (py > 0)` etc."
    ),
    inferred=True,
)


# =============================================================================
# Registry + retrieval
# =============================================================================

ALL_PATTERNS: Tuple[MeshPattern, ...] = (
    PING_PONG_ASYNC_BUFFERS,
    TWO_HOP_ASYNC_FABRIC_DMA,
    TWO_PHASE_TREE_ALLREDUCE_Y,
    SCATTER_COMPUTE_ALLREDUCE_PIPELINE,
    SUMMA_2D_COLLECTIVES_BROADCAST,
    FABRIC_COLOR_PALETTE,
    DSD_BASE_ADDR_SWAP_INNER_LOOP,
    HALO_EXCHANGE_STENCIL,
)


def retrieve(query: str, *, top_k: int = 3, max_chars: int = 5000) -> str:
    """Return a markdown block of the top-k patterns matching the query, or
    an empty string if nothing scores above the minimal threshold.

    The top-scoring pattern is ALWAYS included even if it alone exceeds
    `max_chars` — partial wafer-scale guidance is better than none. Lower-
    ranked patterns are dropped when they would push past the budget.
    """
    if not query or not query.strip():
        return ""
    q = query.lower()

    scored: list[tuple[int, MeshPattern]] = []
    for p in ALL_PATTERNS:
        score = sum(2 for kw in p.trigger_keywords if kw in q)
        # Small bonus when fragments of the pattern name appear (helps when
        # an earlier turn already mentioned the pattern by name).
        name_parts = [part for part in p.name.split("_") if len(part) >= 4]
        score += sum(1 for part in name_parts if part in q)
        if score > 0:
            scored.append((score, p))
    if not scored:
        return ""
    scored.sort(key=lambda t: (-t[0], t[1].name))

    lines = [
        "## Wafer-scale CSL patterns relevant to this kernel",
        "Each pattern below is a canonical idiom for multi-PE execution on "
        "the Cerebras WSE. Apply only those that match the kernel's actual "
        "data distribution. Adapt the snippets — variable, color, and tile "
        "names will differ in the reference bundle.",
    ]
    budget = max_chars - sum(len(s) + 1 for s in lines)
    for rank, (_, p) in enumerate(scored[:top_k]):
        marker = " [inferred — not a verbatim source]" if p.inferred else ""
        block = (
            f"\n### {p.name}\n"
            f"**When to use:** {p.when_to_use}\n\n"
            f"```csl\n{p.csl_snippet}\n```\n"
            f"**Source:** `{p.source}`{marker}\n"
            f"**Gotcha:** {p.gotcha}\n"
        )
        # Always include the top-1 pattern even if oversize; budget-gate the rest.
        if rank > 0 and len(block) > budget:
            break
        lines.append(block)
        budget -= len(block)
    return "\n".join(lines)


__all__ = ["MeshPattern", "ALL_PATTERNS", "retrieve"]
