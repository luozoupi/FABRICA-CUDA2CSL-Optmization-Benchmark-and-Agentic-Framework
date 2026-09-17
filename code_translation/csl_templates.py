"""csl_templates — Pre-verified CSL skeletons for template-based code generation.

Instead of the LLM generating CSL from scratch (including 60-90% boilerplate),
it fills computation slots within a pre-verified skeleton. This constrains
the model's output to kernel-specific math and prevents over-engineering.

Three templates cover ~75% of the kernel catalog:
1. single_pe: elementwise, reduction, scan, histogram, fft (1x1 mesh)
2. halo_exchange: stencil kernels (NxM mesh, nearest-neighbor)
3. collectives: matmul/GEMV with collectives_2d (NxM mesh)

Gate: XKERNEL_TEMPLATE_GEN=1 (default OFF).
"""

from __future__ import annotations

import logging
import re
from typing import Optional

logger = logging.getLogger(__name__)


# ---------------------------------------------------------------------------
# Template: Single-PE
# ---------------------------------------------------------------------------

SINGLE_PE_TEMPLATE = '''\
param memcpy_params: comptime_struct;
// === SLOT: EXTRA_PARAMS ===
// Declare any compile-time params your kernel needs from layout.csl
// (e.g., param n: u16;). Check the layout.csl tile_code params to know
// which params are passed. Do NOT re-declare memcpy_params.

const EXIT: local_task_id = @get_local_task_id(9);
const sys_mod = @import_module("<memcpy/memcpy>", memcpy_params);

// === SLOT: EXTRA_IMPORTS ===
// Add any extra module imports your kernel needs (e.g., const math = @import_module("<math>");)
// Do NOT re-import memcpy or time.

const timestamp = @import_module("<time>");
var tsc_start_buf = @zeros([timestamp.tsc_size_words]u16);
var tsc_end_buf   = @zeros([timestamp.tsc_size_words]u16);
var timer_buf = @zeros([3]f32);
var ptr_timer_buf: [*]f32 = &timer_buf;

// === SLOT: DATA_BUFFERS ===
// Declare your input/output arrays and their pointers. Example:
//   var x_array = @zeros([n]f32);
//   var ptr_x: [*]f32 = &x_array;
// Each buffer the host reads/writes needs a pointer + @export_symbol.

// === SLOT: KERNEL_FUNCTION ===
// Write the computation function. This is the ONLY part that is kernel-specific.
// Use DSD bulk operations (@fmuls, @fadds, @fmacs, @fmovs) where possible
// instead of scalar loops — they are 10-100x faster on WSE.
// Example:
//   fn relu() void {
//     var i: u16 = 0;
//     while (i < n) : (i += 1) {
//       out[i] = if (x[i] > 0.0) x[i] else 0.0;
//     }
//   }

fn compute() void {
    timestamp.enable_tsc();
    timestamp.get_timestamp(&tsc_start_buf);

    // === SLOT: KERNEL_CALL ===
    // Call your kernel function here (e.g., relu();)

    timestamp.get_timestamp(&tsc_end_buf);
    timestamp.disable_tsc();

    var lo_: u16 = 0;
    var hi_: u16 = 0;
    lo_ = tsc_start_buf[0]; hi_ = tsc_start_buf[1];
    timer_buf[0] = @bitcast(f32, (@as(u32, hi_) << @as(u16, 16)) | @as(u32, lo_));
    lo_ = tsc_start_buf[2]; hi_ = tsc_end_buf[0];
    timer_buf[1] = @bitcast(f32, (@as(u32, hi_) << @as(u16, 16)) | @as(u32, lo_));
    lo_ = tsc_end_buf[1]; hi_ = tsc_end_buf[2];
    timer_buf[2] = @bitcast(f32, (@as(u32, hi_) << @as(u16, 16)) | @as(u32, lo_));

    @activate(EXIT);
}

task f_exit() void {
    sys_mod.unblock_cmd_stream();
}

comptime {
    @bind_local_task(f_exit, EXIT);

    // === SLOT: EXPORT_SYMBOLS ===
    // Export each data pointer the host needs. Example:
    //   @export_symbol(ptr_x, "x");
    //   @export_symbol(ptr_out, "out");
    // Check run.py to see which symbol names the host expects.

    @export_symbol(ptr_timer_buf, "maxmin_time");
    @export_symbol(compute);
}
'''


# ---------------------------------------------------------------------------
# Template: Halo-Exchange Stencil
# ---------------------------------------------------------------------------

HALO_EXCHANGE_TEMPLATE = '''\
param memcpy_params: comptime_struct;
param Mt: i16;
param Nt: i16;
param width: i16;
param height: i16;
param px: i16;
param py: i16;
param is_w_edge: bool;
param is_e_edge: bool;
param is_n_edge: bool;
param is_s_edge: bool;

param TX_N: color = @get_color(15);
param RX_N: color = @get_color(15);
param TX_S: color = @get_color(15);
param RX_S: color = @get_color(15);
param TX_E: color = @get_color(15);
param RX_E: color = @get_color(15);
param TX_W: color = @get_color(15);
param RX_W: color = @get_color(15);

const tx_n_oq: output_queue = @get_output_queue(2);
const tx_s_oq: output_queue = @get_output_queue(3);
const tx_e_oq: output_queue = @get_output_queue(4);
const tx_w_oq: output_queue = @get_output_queue(5);

const rx_n_iq: input_queue = @get_input_queue(2);
const rx_s_iq: input_queue = @get_input_queue(3);
const rx_e_iq: input_queue = @get_input_queue(4);
const rx_w_iq: input_queue = @get_input_queue(5);

const SEND_TID:    local_task_id = @get_local_task_id(12);
const RX_DONE_TID: local_task_id = @get_local_task_id(13);
const COMPUTE_TID: local_task_id = @get_local_task_id(14);
const EXIT_TID:    local_task_id = @get_local_task_id(15);

const sys_mod = @import_module("<memcpy/memcpy>", memcpy_params);
const timestamp = @import_module("<time>");

var tile:     [Mt * Nt]f32 = @zeros([Mt * Nt]f32);
var new_tile: [Mt * Nt]f32 = @zeros([Mt * Nt]f32);

var halo_n: [Nt]f32 = @zeros([Nt]f32);
var halo_s: [Nt]f32 = @zeros([Nt]f32);
var halo_e: [Mt]f32 = @zeros([Mt]f32);
var halo_w: [Mt]f32 = @zeros([Mt]f32);

var col_send_e: [Mt]f32 = @zeros([Mt]f32);
var col_send_w: [Mt]f32 = @zeros([Mt]f32);

var tile_ptr:     [*]f32 = &tile;
var new_tile_ptr: [*]f32 = &new_tile;

// === SLOT: EXTRA_STORAGE ===
// Declare any additional per-PE arrays your stencil needs beyond
// tile, new_tile, and the four halo buffers.

var tscStartBuffer = @zeros([timestamp.tsc_size_words]u16);
var tscEndBuffer   = @zeros([timestamp.tsc_size_words]u16);
var time_buf_u16   = @zeros([timestamp.tsc_size_words*2]u16);
var ptr_time_buf_u16: [*]u16 = &time_buf_u16;

const num_halos_expected: i16 =
    (if (is_w_edge) @as(i16, 0) else @as(i16, 1))
  + (if (is_e_edge) @as(i16, 0) else @as(i16, 1))
  + (if (is_n_edge) @as(i16, 0) else @as(i16, 1))
  + (if (is_s_edge) @as(i16, 0) else @as(i16, 1));

var num_halos_received: i16 = 0;
var remaining_iters: u16 = 0;

const top_row_dsd    = @get_dsd(mem1d_dsd, .{ .tensor_access = |j|{Nt} -> tile[j] });
const bot_row_dsd    = @get_dsd(mem1d_dsd, .{ .tensor_access = |j|{Nt} -> tile[(Mt-1)*Nt + j] });
const col_send_e_dsd = @get_dsd(mem1d_dsd, .{ .tensor_access = |i|{Mt} -> col_send_e[i] });
const col_send_w_dsd = @get_dsd(mem1d_dsd, .{ .tensor_access = |i|{Mt} -> col_send_w[i] });

const halo_n_dsd = @get_dsd(mem1d_dsd, .{ .tensor_access = |j|{Nt} -> halo_n[j] });
const halo_s_dsd = @get_dsd(mem1d_dsd, .{ .tensor_access = |j|{Nt} -> halo_s[j] });
const halo_e_dsd = @get_dsd(mem1d_dsd, .{ .tensor_access = |i|{Mt} -> halo_e[i] });
const halo_w_dsd = @get_dsd(mem1d_dsd, .{ .tensor_access = |i|{Mt} -> halo_w[i] });

const fab_tx_n = @get_dsd(fabout_dsd, .{ .extent = Nt, .fabric_color = TX_N, .output_queue = tx_n_oq });
const fab_tx_s = @get_dsd(fabout_dsd, .{ .extent = Nt, .fabric_color = TX_S, .output_queue = tx_s_oq });
const fab_tx_e = @get_dsd(fabout_dsd, .{ .extent = Mt, .fabric_color = TX_E, .output_queue = tx_e_oq });
const fab_tx_w = @get_dsd(fabout_dsd, .{ .extent = Mt, .fabric_color = TX_W, .output_queue = tx_w_oq });

const fab_rx_n = @get_dsd(fabin_dsd, .{ .extent = Nt, .fabric_color = RX_N, .input_queue = rx_n_iq });
const fab_rx_s = @get_dsd(fabin_dsd, .{ .extent = Nt, .fabric_color = RX_S, .input_queue = rx_s_iq });
const fab_rx_e = @get_dsd(fabin_dsd, .{ .extent = Mt, .fabric_color = RX_E, .input_queue = rx_e_iq });
const fab_rx_w = @get_dsd(fabin_dsd, .{ .extent = Mt, .fabric_color = RX_W, .input_queue = rx_w_iq });

task f_send() void {
    num_halos_received = 0;
    var i: i16 = 0;
    while (i < Mt) : (i += 1) {
        col_send_w[i] = tile[i * Nt + 0];
        col_send_e[i] = tile[i * Nt + (Nt - 1)];
    }
    if (!is_n_edge) @fmovs(fab_tx_n, top_row_dsd,    .{ .async = true });
    if (!is_s_edge) @fmovs(fab_tx_s, bot_row_dsd,    .{ .async = true });
    if (!is_w_edge) @fmovs(fab_tx_w, col_send_w_dsd, .{ .async = true });
    if (!is_e_edge) @fmovs(fab_tx_e, col_send_e_dsd, .{ .async = true });
    if (!is_n_edge) @fmovs(halo_n_dsd, fab_rx_n, .{ .async = true, .activate = RX_DONE_TID });
    if (!is_s_edge) @fmovs(halo_s_dsd, fab_rx_s, .{ .async = true, .activate = RX_DONE_TID });
    if (!is_w_edge) @fmovs(halo_w_dsd, fab_rx_w, .{ .async = true, .activate = RX_DONE_TID });
    if (!is_e_edge) @fmovs(halo_e_dsd, fab_rx_e, .{ .async = true, .activate = RX_DONE_TID });
}

task f_rx_done() void {
    num_halos_received += 1;
    if (num_halos_received == num_halos_expected) {
        @activate(COMPUTE_TID);
    }
}

task f_compute() void {
    // === SLOT: STENCIL_BODY ===
    // Write your stencil computation here. You have access to:
    //   tile[i*Nt + j]   -- the current tile (row-major)
    //   halo_n[j]        -- north neighbor's bottom row (or zeros if north edge)
    //   halo_s[j]        -- south neighbor's top row (or zeros if south edge)
    //   halo_e[i]        -- east neighbor's left column (or zeros if east edge)
    //   halo_w[i]        -- west neighbor's right column (or zeros if west edge)
    //   Mt, Nt           -- tile dimensions (i16)
    //   new_tile[i*Nt+j] -- write your result here
    //
    // After the stencil computation, copy new_tile back to tile and handle
    // iteration control:
    //   var k: i16 = 0;
    //   while (k < Mt * Nt) : (k += 1) { tile[k] = new_tile[k]; }
    //   remaining_iters -= 1;
    //   if (remaining_iters > 0) { @activate(SEND_TID); } else { @activate(EXIT_TID); }
}

task f_exit() void {
    sys_mod.unblock_cmd_stream();
}

fn step(iters: u16) void {
    remaining_iters = iters;
    if (iters == 0) {
        @activate(EXIT_TID);
    } else {
        @activate(SEND_TID);
    }
}

fn f_tic() void {
    timestamp.get_timestamp(&tscStartBuffer);
    sys_mod.unblock_cmd_stream();
}

fn f_toc() void {
    timestamp.get_timestamp(&tscEndBuffer);
    sys_mod.unblock_cmd_stream();
}

fn f_memcpy_timestamps() void {
    time_buf_u16[0] = tscStartBuffer[0];
    time_buf_u16[1] = tscStartBuffer[1];
    time_buf_u16[2] = tscStartBuffer[2];
    time_buf_u16[3] = tscEndBuffer[0];
    time_buf_u16[4] = tscEndBuffer[1];
    time_buf_u16[5] = tscEndBuffer[2];
    sys_mod.unblock_cmd_stream();
}

fn f_enable_timer() void {
    timestamp.enable_tsc();
    sys_mod.unblock_cmd_stream();
}

comptime {
    @bind_local_task(f_send,    SEND_TID);
    @bind_local_task(f_rx_done, RX_DONE_TID);
    @bind_local_task(f_compute, COMPUTE_TID);
    @bind_local_task(f_exit,    EXIT_TID);

    if (@is_arch("wse3")) {
        if (@get_int(TX_N) != 15) @initialize_queue(tx_n_oq, .{ .color = TX_N });
        if (@get_int(TX_S) != 15) @initialize_queue(tx_s_oq, .{ .color = TX_S });
        if (@get_int(TX_E) != 15) @initialize_queue(tx_e_oq, .{ .color = TX_E });
        if (@get_int(TX_W) != 15) @initialize_queue(tx_w_oq, .{ .color = TX_W });
        if (@get_int(RX_N) != 15) @initialize_queue(rx_n_iq, .{ .color = RX_N });
        if (@get_int(RX_S) != 15) @initialize_queue(rx_s_iq, .{ .color = RX_S });
        if (@get_int(RX_E) != 15) @initialize_queue(rx_e_iq, .{ .color = RX_E });
        if (@get_int(RX_W) != 15) @initialize_queue(rx_w_iq, .{ .color = RX_W });
    }

    @export_symbol(tile_ptr,     "tile");
    @export_symbol(new_tile_ptr, "new_tile");
    @export_symbol(ptr_time_buf_u16, "time_buf_u16");
    @export_symbol(step);
    @export_symbol(f_tic);
    @export_symbol(f_toc);
    @export_symbol(f_memcpy_timestamps);
    @export_symbol(f_enable_timer);
}
'''


# ---------------------------------------------------------------------------
# Template: Collectives (GEMV / GEMM with collectives_2d)
# ---------------------------------------------------------------------------

COLLECTIVES_TEMPLATE = '''\
param memcpy_params: comptime_struct;
param c2d_params: comptime_struct;

// === SLOT: EXTRA_PARAMS ===
// Tile dimensions from layout.csl (e.g., param Mt: u16; param Nt: u16;)
// Check the layout.csl @set_tile_code params to know which are passed.

// Task IDs for the collective pipeline
const EXIT:             local_task_id = @get_local_task_id(9);
const phase1_task_id:   local_task_id = @get_local_task_id(10);
const phase2_task_id:   local_task_id = @get_local_task_id(11);
const compute_task_id:  local_task_id = @get_local_task_id(12);
const gather_task_id:   local_task_id = @get_local_task_id(13);

const sys_mod = @import_module("<memcpy/memcpy>", memcpy_params);
const timestamp = @import_module("<time>");
var tscStartBuffer = @zeros([timestamp.tsc_size_words]u16);
var tscEndBuffer   = @zeros([timestamp.tsc_size_words]u16);
var time_buf_u16   = @zeros([timestamp.tsc_size_words*2]u16);
var ptr_time_buf_u16: [*]u16 = &time_buf_u16;

// Collectives imports — use default queue/DSR IDs.
const mpi_x = @import_module("<collectives_2d/pe>", .{ .dim_params = c2d_params.x });
const mpi_y = @import_module("<collectives_2d/pe>", .{ .dim_params = c2d_params.y });

const Pw = @get_rectangle().width;
const Ph = @get_rectangle().height;

// Runtime PE coordinates
var pe_x: u16 = 0;
var pe_y: u16 = 0;

// === SLOT: DATA_BUFFERS ===
// Declare per-PE data tiles, temporaries, result buffers and their pointers.
// IMPORTANT: each host-visible buffer needs a pointer for @export_symbol.
// Use @ptrcast([*]u32, &buf) for scatter/gather, @ptrcast([*]f32, &buf) for reduce_fadds.
// Example for GEMV y=Ax+b:
//   var A_tile = @zeros([Mt*Nt]f32);  var ptr_A: [*]f32 = &A_tile;
//   var x_tile = @zeros([Nt]f32);
//   var local_prod = @zeros([Mt]f32);
//   var row_sum = @zeros([Mt]f32);
//   var result = @zeros([Mt*Ph]f32);  var ptr_y: [*]f32 = &result;

// Entrypoint: initialize collectives, then start the pipeline.
// The pipeline pattern is: distribute data → compute locally → reduce → gather.
fn main() void {
    mpi_x.init();
    mpi_y.init();
    pe_x = mpi_x.pe_id;
    pe_y = mpi_y.pe_id;

    // === SLOT: DISTRIBUTE_DATA ===
    // Start the collective pipeline by distributing input data.
    // Typical patterns (pick what fits your algorithm):
    //
    // Scatter a vector from PE(0,0) across one axis, then activate phase1:
    //   if (pe_x == 0) {
    //       mpi_y.scatter(0, @ptrcast([*]u32, &src), @ptrcast([*]u32, &tile), count, phase1_task_id);
    //   } else { @activate(phase1_task_id); }
    //
    // Broadcast a vector from root along one axis:
    //   mpi_x.broadcast(0, @ptrcast([*]u32, &vec), count, compute_task_id);
}

// Phase 1: distribute more data or transform (optional).
task phase1() void {
    // === SLOT: PHASE1 ===
    // Continue distributing data (e.g., scatter along the other axis,
    // broadcast down columns). Activate phase2_task_id or compute_task_id.
    // If not needed, just: @activate(compute_task_id);
    @activate(compute_task_id);
}

// Phase 2: additional distribution step (optional).
task phase2() void {
    // === SLOT: PHASE2 ===
    // If needed for 2-axis distribution. Activate compute_task_id.
    @activate(compute_task_id);
}

// Compute: local per-PE math, then reduce across PEs.
task compute() void {
    // === SLOT: LOCAL_COMPUTE ===
    // This is the KERNEL-SPECIFIC computation. Write the per-PE math here.
    // After computing, reduce and gather the result.
    //
    // Example for GEMV (y = A*x + b):
    //   // DSD-based matrix-vector multiply
    //   const dsd_A = @get_dsd(mem1d_dsd, .{ .tensor_access = |i|{Mt} -> A_tile[i*@as(i16,Nt)] });
    //   for (@range(i16, Nt)) |j| {
    //       const col = @increment_dsd_offset(dsd_A, j, f32);
    //       @fmacs(prod_dsd, prod_dsd, col, x_tile[j]);
    //   }
    //   // Add bias on the root column
    //   if (pe_x == 0) { @fadds(prod_dsd, prod_dsd, b_dsd); }
    //
    //   // Reduce partial products across the row of PEs
    //   mpi_x.reduce_fadds(Pw-1, @ptrcast([*]f32, &local_prod),
    //                      @ptrcast([*]f32, &row_sum), Mt, gather_task_id);
}

// Gather: collect reduced results onto one PE.
task gather() void {
    // === SLOT: GATHER ===
    // Gather the reduced result to the destination PE.
    // Example:
    //   mpi_y.gather(Ph-1, @ptrcast([*]u32, &row_sum),
    //                @ptrcast([*]u32, &result), Mt, EXIT);
    @activate(EXIT);
}

task f_exit() void {
    sys_mod.unblock_cmd_stream();
}

fn f_tic() void {
    timestamp.get_timestamp(&tscStartBuffer);
    sys_mod.unblock_cmd_stream();
}

fn f_toc() void {
    timestamp.get_timestamp(&tscEndBuffer);
    sys_mod.unblock_cmd_stream();
}

fn f_memcpy_timestamps() void {
    time_buf_u16[0] = tscStartBuffer[0];
    time_buf_u16[1] = tscStartBuffer[1];
    time_buf_u16[2] = tscStartBuffer[2];
    time_buf_u16[3] = tscEndBuffer[0];
    time_buf_u16[4] = tscEndBuffer[1];
    time_buf_u16[5] = tscEndBuffer[2];
    sys_mod.unblock_cmd_stream();
}

fn f_enable_timer() void {
    timestamp.enable_tsc();
    sys_mod.unblock_cmd_stream();
}

comptime {
    @bind_local_task(phase1, phase1_task_id);
    @bind_local_task(phase2, phase2_task_id);
    @bind_local_task(compute, compute_task_id);
    @bind_local_task(gather, gather_task_id);
    @bind_local_task(f_exit, EXIT);

    // === SLOT: EXPORT_SYMBOLS ===
    // Export data pointers + entry function. Check run.py for expected names.
    // Example:
    //   @export_symbol(ptr_A, "A");
    //   @export_symbol(ptr_y, "y");
    //   @export_symbol(main);

    @export_symbol(ptr_time_buf_u16, "time_buf_u16");
    @export_symbol(f_tic);
    @export_symbol(f_toc);
    @export_symbol(f_memcpy_timestamps);
    @export_symbol(f_enable_timer);
}
'''


# ---------------------------------------------------------------------------
# Template registry and selection
# ---------------------------------------------------------------------------

_TEMPLATES = {
    "single_pe": SINGLE_PE_TEMPLATE,
    "halo_exchange": HALO_EXCHANGE_TEMPLATE,
    "collectives": COLLECTIVES_TEMPLATE,
}


def select_template(layout_text: str) -> Optional[str]:
    """Select a template based on layout.csl content.

    Returns template name or None if no template fits.
    """
    if not layout_text:
        return None

    mesh_w, mesh_h = 1, 1
    for pat in [r'kernel_rows\s*=\s*(\d+)', r'width\s*[=:]\s*(\d+)']:
        m = re.search(pat, layout_text)
        if m:
            mesh_w = int(m.group(1))
            break
    for pat in [r'kernel_cols\s*=\s*(\d+)', r'height\s*[=:]\s*(\d+)']:
        m = re.search(pat, layout_text)
        if m:
            mesh_h = int(m.group(1))
            break

    is_single_pe = (mesh_w == 1 and mesh_h == 1)

    has_collectives = bool(re.search(r'collectives_2d', layout_text))
    has_halo_colors = bool(re.search(
        r'TX_N|RX_N|tx_north|rx_north|halo.*color|is_[nsew]_edge',
        layout_text, re.IGNORECASE,
    ))

    if is_single_pe:
        return "single_pe"
    if has_collectives:
        return "collectives"
    if has_halo_colors:
        return "halo_exchange"

    return None


def get_template(name: str) -> str:
    """Get a template by name."""
    return _TEMPLATES[name]


def format_template_prompt(template_name: str, template_text: str) -> str:
    """Wrap a template with fill-in instructions for the LLM prompt."""
    slot_names = re.findall(r'// === SLOT: (\w+)', template_text)
    slots_list = "\n".join(f"  - {s}" for s in slot_names)

    return f"""\
## CSL TEMPLATE ({template_name})

Complete the following CSL template by filling in ONLY the marked SLOT sections.
The boilerplate code (imports, memcpy, timestamps, exit task, comptime scaffolding,
and for halo-exchange: the entire send/recv/sync machinery) is PRE-VERIFIED and
correct. Do NOT modify, delete, or duplicate any code outside the SLOT markers.

Your job is to write ONLY the kernel-specific computation in each slot.

Slots to fill:
{slots_list}

Return the COMPLETE file (template + your filled slots) in a ```csl code fence.

```csl
{template_text}
```"""
