; ModuleID = './layout.csl'
source_filename = "./layout.csl"
target datalayout = "e-ni:0-p:16:16-i1:16-i16:16-i32:32-i64:64-f32:32-f64:64"
target triple = "cs_sdr-cerebras-csos"

@ai = internal global [4 x i16] zeroinitializer, align 4
@bi = internal global [4 x i16] zeroinitializer, align 4
@ci = internal global [16 x i16] zeroinitializer, align 4
@af = internal global [4 x half] zeroinitializer, align 4
@bf = internal global [4 x half] zeroinitializer, align 4
@cf = internal global [16 x half] zeroinitializer, align 4
@"$$csl_base_address$$1$$a" = dso_local global [16 x half] zeroinitializer, align 4
@"$$csl_base_address$$2$$b" = dso_local global [16 x half] zeroinitializer, align 4
@"$$csl_base_address$$0$$c" = dso_local global [64 x half] zeroinitializer, align 4
@"$$csl_base_address$$7$$a32" = dso_local global [8 x float] zeroinitializer, align 4
@"$$csl_base_address$$8$$b32" = dso_local global [8 x float] zeroinitializer, align 4
@"$$csl_base_address$$6$$c32" = dso_local global [16 x float] zeroinitializer, align 4
@"$$csl_base_address$$4$$ia8" = dso_local global [8 x i16] zeroinitializer, align 4
@"$$csl_base_address$$5$$ib8" = dso_local global [8 x i16] zeroinitializer, align 4
@"$$csl_base_address$$3$$ic8" = dso_local global [8 x i16] zeroinitializer, align 4
@mark = internal global [32 x i16] zeroinitializer, align 4
@acc = internal global half 0xH0000, align 4
@ptr_ai = internal global i16* getelementptr inbounds ([4 x i16], [4 x i16]* @ai, i32 0, i32 0), align 4
@ptr_bi = internal global i16* getelementptr inbounds ([4 x i16], [4 x i16]* @bi, i32 0, i32 0), align 4
@ptr_ci = internal global i16* getelementptr inbounds ([16 x i16], [16 x i16]* @ci, i32 0, i32 0), align 4
@ptr_af = internal global half* getelementptr inbounds ([4 x half], [4 x half]* @af, i32 0, i32 0), align 4
@ptr_bf = internal global half* getelementptr inbounds ([4 x half], [4 x half]* @bf, i32 0, i32 0), align 4
@ptr_cf = internal global half* getelementptr inbounds ([16 x half], [16 x half]* @cf, i32 0, i32 0), align 4
@ptr_a = internal global half* getelementptr inbounds ([16 x half], [16 x half]* @"$$csl_base_address$$1$$a", i32 0, i32 0), align 4
@ptr_b = internal global half* getelementptr inbounds ([16 x half], [16 x half]* @"$$csl_base_address$$2$$b", i32 0, i32 0), align 4
@ptr_c = internal global half* getelementptr inbounds ([64 x half], [64 x half]* @"$$csl_base_address$$0$$c", i32 0, i32 0), align 4
@ptr_a32 = internal global float* getelementptr inbounds ([8 x float], [8 x float]* @"$$csl_base_address$$7$$a32", i32 0, i32 0), align 4
@ptr_b32 = internal global float* getelementptr inbounds ([8 x float], [8 x float]* @"$$csl_base_address$$8$$b32", i32 0, i32 0), align 4
@ptr_c32 = internal global float* getelementptr inbounds ([16 x float], [16 x float]* @"$$csl_base_address$$6$$c32", i32 0, i32 0), align 4
@ptr_ia8 = internal global i16* getelementptr inbounds ([8 x i16], [8 x i16]* @"$$csl_base_address$$4$$ia8", i32 0, i32 0), align 4
@ptr_ib8 = internal global i16* getelementptr inbounds ([8 x i16], [8 x i16]* @"$$csl_base_address$$5$$ib8", i32 0, i32 0), align 4
@ptr_ic8 = internal global i16* getelementptr inbounds ([8 x i16], [8 x i16]* @"$$csl_base_address$$3$$ic8", i32 0, i32 0), align 4
@ptr_mark = internal global i16* getelementptr inbounds ([32 x i16], [32 x i16]* @mark, i32 0, i32 0), align 4
@sys_mod.sys_mod.is_h2d_cmd = internal global i1 false, align 4
@sys_mod.sys_mod.memcpyH2D_c = internal global i16 0, align 4
@sys_mod.sys_mod.memcpyH2D_px = internal global i16 0, align 4
@sys_mod.sys_mod.memcpyH2D_py = internal global i16 0, align 4
@sys_mod.sys_mod.memcpyH2D_w = internal global i16 0, align 4
@sys_mod.sys_mod.memcpyH2D_h = internal global i16 0, align 4
@sys_mod.sys_mod.memcpyH2D_addr = internal global i16 0, align 4
@sys_mod.sys_mod.memcpyH2D_pe_length = internal global i16 0, align 4
@sys_mod.sys_mod.memcpyH2D_is_half = internal global i16 0, align 4
@sys_mod.sys_mod.memcpyH2D_memcpy_optype = internal global i16 0, align 4
@sys_mod.sys_mod.memcpyH2D_row_stride = internal global i16 0, align 4
@sys_mod.sys_mod.memcpyH2D_col_stride = internal global i16 0, align 4
@sys_mod.sys_mod.memcpyH2D_one_over_row_stride = internal global float 0.000000e+00, align 4
@sys_mod.sys_mod.memcpyH2D_one_over_col_stride = internal global float 0.000000e+00, align 4
@sys_mod.sys_mod.memcpyD2H_c = internal global i16 0, align 4
@sys_mod.sys_mod.memcpyD2H_px = internal global i16 0, align 4
@sys_mod.sys_mod.memcpyD2H_py = internal global i16 0, align 4
@sys_mod.sys_mod.memcpyD2H_w = internal global i16 0, align 4
@sys_mod.sys_mod.memcpyD2H_h = internal global i16 0, align 4
@sys_mod.sys_mod.memcpyD2H_addr = internal global i16 0, align 4
@sys_mod.sys_mod.memcpyD2H_pe_length = internal global i16 0, align 4
@sys_mod.sys_mod.memcpyD2H_is_half = internal global i16 0, align 4
@sys_mod.sys_mod.sys_mod.stack_u32 = internal global [32 x i32] zeroinitializer, align 4
@sys_mod.sys_mod.sys_mod.stack_last = internal global i16 0, align 4
@sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers = internal global i16 0, align 4
@sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx = internal global i16 -1, align 4
@"$$csl_base_address$$11$$sys_mod.sys_mod.memcpyh2d_mod_1.dummy" = dso_local constant [1 x i16] zeroinitializer, align 4
@sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd = internal global <{ i16, i16, i16, i16 }> <{ i16 1, i16 3999, i16 206, i16 16 }>, align 4
@sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd = internal global <{ i16, i16, i16, i16 }> <{ i16 1, i16 31, i16 206, i16 16 }>, align 4
@sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.filters = internal constant [6 x i16] [i16 -2432, i16 -2416, i16 -2400, i16 -2384, i16 -2368, i16 -2352], align 4
@sys_mod.sys_mod.memcpyd2h_mod.data_buf = internal global [1 x i32] zeroinitializer, align 4
@sys_mod.sys_mod.memcpyd2h_mod.j = internal global i16 0, align 4
@sys_mod.sys_mod.memcpyd2h_mod.pe_length = internal global i16 0, align 4
@sys_mod.sys_mod.memcpyd2h_mod.x_first = internal global i16 0, align 4
@sys_mod.sys_mod.memcpyd2h_mod.x_last = internal global i16 0, align 4
@sys_mod.sys_mod.memcpyd2h_mod.is_active = internal global i1 false, align 4
@sys_mod.sys_mod.memcpyd2h_mod.routing_active = internal global i1 false, align 4
@sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_c = internal global i16 0, align 4
@sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_is_half = internal global i16 0, align 4
@sys_mod.sys_mod.memcpyd2h_mod.is_streaming = internal global i16 1, align 4
@"$$csl_base_address$$10$$sys_mod.sys_mod.memcpyd2h_mod.dummy" = dso_local constant [1 x i16] zeroinitializer, align 4
@sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd = internal global <{ i16, i16, i16, i16 }> <{ i16 1, i16 lshr (i16 ptrtoint ([1 x i16]* @"$$csl_base_address$$10$$sys_mod.sys_mod.memcpyd2h_mod.dummy" to i16), i16 1), i16 143, i16 16 }>, align 4
@"$$csl_base_address$$9$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11" = dso_local global [1 x i32] [i32 190812745], align 4
@sys_mod.sys_mod.memcpyd2h_mod.ctrl_1 = internal global [1 x i32] [i32 157258313], align 4
@sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd = internal global <{ i16, i16, i16, i16 }> <{ i16 1, i16 lshr (i16 ptrtoint ([1 x i32]* @"$$csl_base_address$$9$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11" to i16), i16 1), i16 143, i16 16 }>, align 4
@"$$csl_base_address$$13$$sys_mod.sys_mod.memcpyd2h_mod.sw_td" = dso_local global [2 x i32] zeroinitializer, align 4
@"$$csl_base_address$$12$$sys_mod.sys_mod.memcpyd2h_mod.teardown_buf" = dso_local constant [1 x i32] [i32 165646921], align 4
@__dsr_lowmeminit_ = internal constant <{ i16, i16, i16, i16 }> <{ i16 8, i16 lshr (i16 ptrtoint ([64 x half]* @"$$csl_base_address$$0$$c" to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__0 = internal constant <{ i16, i16, i16, i16 }> <{ i16 8, i16 lshr (i16 ptrtoint ([16 x half]* @"$$csl_base_address$$1$$a" to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__1 = internal constant <{ i16, i16, i16, i16 }> <{ i16 8, i16 lshr (i16 ptrtoint (i16* getelementptr (i16, i16* bitcast ([64 x half]* @"$$csl_base_address$$0$$c" to i16*), i16 8) to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__2 = internal constant <{ i16, i16, i16, i16 }> <{ i16 8, i16 lshr (i16 ptrtoint ([16 x half]* @"$$csl_base_address$$1$$a" to i16), i16 1), i16 271, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__3 = internal constant <{ i16, i16, i16, i16 }> <{ i16 8, i16 lshr (i16 ptrtoint (i16* getelementptr (i16, i16* bitcast ([64 x half]* @"$$csl_base_address$$0$$c" to i16*), i16 16) to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__4 = internal constant <{ i16, i16, i16, i16 }> <{ i16 8, i16 lshr (i16 ptrtoint ([16 x half]* @"$$csl_base_address$$2$$b" to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__5 = internal constant <{ i16, i16, i16, i16 }> <{ i16 8, i16 lshr (i16 ptrtoint (i16* getelementptr (i16, i16* bitcast ([64 x half]* @"$$csl_base_address$$0$$c" to i16*), i16 24) to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__6 = internal constant <{ i16, i16, i16, i16 }> <{ i16 8, i16 lshr (i16 ptrtoint (i16* getelementptr (i16, i16* bitcast ([64 x half]* @"$$csl_base_address$$0$$c" to i16*), i16 32) to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__7 = internal constant <{ i16, i16, i16, i16 }> <{ i16 8, i16 lshr (i16 ptrtoint ([8 x i16]* @"$$csl_base_address$$5$$ib8" to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__8 = internal constant <{ i16, i16, i16, i16 }> <{ i16 8, i16 lshr (i16 ptrtoint ([8 x i16]* @"$$csl_base_address$$3$$ic8" to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__9 = internal constant <{ i16, i16, i16, i16 }> <{ i16 8, i16 lshr (i16 ptrtoint ([8 x i16]* @"$$csl_base_address$$4$$ia8" to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__10 = internal constant <{ i16, i16, i16, i16 }> <{ i16 8, i16 lshr (i16 ptrtoint ([8 x float]* @"$$csl_base_address$$8$$b32" to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__11 = internal constant <{ i16, i16, i16, i16 }> <{ i16 8, i16 lshr (i16 ptrtoint (i16* getelementptr (i16, i16* bitcast ([16 x float]* @"$$csl_base_address$$6$$c32" to i16*), i16 16) to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__12 = internal constant <{ i16, i16, i16, i16 }> <{ i16 8, i16 lshr (i16 ptrtoint ([8 x float]* @"$$csl_base_address$$7$$a32" to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__13 = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 62, i16 142, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__14 = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 4127, i16 142, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__15 = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 lshr (i16 ptrtoint ([1 x i32]* @"$$csl_base_address$$12$$sys_mod.sys_mod.memcpyd2h_mod.teardown_buf" to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__16 = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 4149, i16 142, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__17 = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 4096, i16 142, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__18 = internal constant <{ i16, i16, i16, i16 }> <{ i16 2, i16 4127, i16 142, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__19 = internal constant <{ i16, i16, i16, i16 }> <{ i16 2, i16 lshr (i16 ptrtoint ([2 x i32]* @"$$csl_base_address$$13$$sys_mod.sys_mod.memcpyd2h_mod.sw_td" to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4

declare i8* @malloc(i64)

declare void @free(i8*)

define internal void @compute() !dbg !3 {
  %1 = alloca i16, i16 1, align 2, !dbg !7
  store i16 23040, i16* getelementptr inbounds ([32 x i16], [32 x i16]* @mark, i16 0, i1 false), align 2, !dbg !9
  %2 = load i16, i16* getelementptr inbounds ([4 x i16], [4 x i16]* @ai, i16 0, i1 false), align 2, !dbg !10
  %3 = load i16, i16* getelementptr inbounds ([4 x i16], [4 x i16]* @bi, i16 0, i1 false), align 2, !dbg !11
  %4 = sub i16 %2, %3, !dbg !12
  store i16 %4, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @ci, i16 0, i1 false), align 2, !dbg !13
  store i16 23041, i16* getelementptr inbounds ([32 x i16], [32 x i16]* @mark, i16 0, i2 1), align 2, !dbg !14
  %5 = load i16, i16* getelementptr inbounds ([4 x i16], [4 x i16]* @ai, i16 0, i1 false), align 2, !dbg !15
  %6 = load i16, i16* getelementptr inbounds ([4 x i16], [4 x i16]* @bi, i16 0, i1 false), align 2, !dbg !16
  %7 = mul i16 %5, %6, !dbg !17
  store i16 %7, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @ci, i16 0, i2 1), align 2, !dbg !18
  store i16 23042, i16* getelementptr inbounds ([32 x i16], [32 x i16]* @mark, i16 0, i3 2), align 2, !dbg !19
  %8 = load half, half* getelementptr inbounds ([4 x half], [4 x half]* @af, i16 0, i1 false), align 2, !dbg !20
  %9 = load half, half* getelementptr inbounds ([4 x half], [4 x half]* @bf, i16 0, i1 false), align 2, !dbg !21
  %10 = fmul half %8, %9, !dbg !22
  store half %10, half* getelementptr inbounds ([16 x half], [16 x half]* @cf, i16 0, i1 false), align 2, !dbg !23
  store i16 23043, i16* getelementptr inbounds ([32 x i16], [32 x i16]* @mark, i16 0, i3 3), align 2, !dbg !24
  %11 = load half, half* getelementptr inbounds ([4 x half], [4 x half]* @af, i16 0, i1 false), align 2, !dbg !25
  %12 = load half, half* getelementptr inbounds ([4 x half], [4 x half]* @bf, i16 0, i1 false), align 2, !dbg !26
  %13 = fmul half %11, %12, !dbg !27
  %14 = load half, half* getelementptr inbounds ([4 x half], [4 x half]* @af, i16 0, i2 1), align 2, !dbg !28
  %15 = fadd half %13, %14, !dbg !29
  store half %15, half* getelementptr inbounds ([16 x half], [16 x half]* @cf, i16 0, i2 1), align 2, !dbg !30
  store i16 23044, i16* getelementptr inbounds ([32 x i16], [32 x i16]* @mark, i16 0, i4 4), align 2, !dbg !31
  %16 = load i16, i16* getelementptr inbounds ([4 x i16], [4 x i16]* @ai, i16 0, i1 false), align 2, !dbg !32
  %17 = load i16, i16* getelementptr inbounds ([4 x i16], [4 x i16]* @bi, i16 0, i1 false), align 2, !dbg !33
  %18 = and i16 %16, %17, !dbg !34
  store i16 %18, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @ci, i16 0, i3 2), align 2, !dbg !35
  store i16 23045, i16* getelementptr inbounds ([32 x i16], [32 x i16]* @mark, i16 0, i4 5), align 2, !dbg !36
  %19 = load i16, i16* getelementptr inbounds ([4 x i16], [4 x i16]* @ai, i16 0, i1 false), align 2, !dbg !37
  %20 = load i16, i16* getelementptr inbounds ([4 x i16], [4 x i16]* @bi, i16 0, i1 false), align 2, !dbg !38
  %21 = or i16 %19, %20, !dbg !39
  store i16 %21, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @ci, i16 0, i3 3), align 2, !dbg !40
  store i16 23046, i16* getelementptr inbounds ([32 x i16], [32 x i16]* @mark, i16 0, i4 6), align 2, !dbg !41
  %22 = load i16, i16* getelementptr inbounds ([4 x i16], [4 x i16]* @ai, i16 0, i1 false), align 2, !dbg !42
  %23 = load i16, i16* getelementptr inbounds ([4 x i16], [4 x i16]* @bi, i16 0, i1 false), align 2, !dbg !43
  %24 = xor i16 %22, %23, !dbg !44
  store i16 %24, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @ci, i16 0, i4 4), align 2, !dbg !45
  store i16 23047, i16* getelementptr inbounds ([32 x i16], [32 x i16]* @mark, i16 0, i4 7), align 2, !dbg !46
  %25 = load i16, i16* getelementptr inbounds ([4 x i16], [4 x i16]* @ai, i16 0, i1 false), align 2, !dbg !47
  %26 = shl i16 %25, 3, !dbg !48
  store i16 %26, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @ci, i16 0, i4 5), align 2, !dbg !49
  store i16 23048, i16* getelementptr inbounds ([32 x i16], [32 x i16]* @mark, i16 0, i5 8), align 2, !dbg !50
  %27 = load i16, i16* getelementptr inbounds ([4 x i16], [4 x i16]* @ai, i16 0, i1 false), align 2, !dbg !51
  %28 = ashr i16 %27, 2, !dbg !52
  store i16 %28, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @ci, i16 0, i4 6), align 2, !dbg !53
  store i16 23049, i16* getelementptr inbounds ([32 x i16], [32 x i16]* @mark, i16 0, i5 9), align 2, !dbg !54
  %29 = load i16, i16* getelementptr inbounds ([4 x i16], [4 x i16]* @ai, i16 0, i3 2), align 2, !dbg !55
  %30 = load i16, i16* getelementptr inbounds ([4 x i16], [4 x i16]* @bi, i16 0, i3 2), align 2, !dbg !56
  %31 = icmp slt i16 %29, %30, !dbg !57
  br i1 %31, label %32, label %79, !dbg !58

32:                                               ; preds = %79, %0
  %33 = phi i16 [ %80, %79 ], [ 11, %0 ]
  store i16 %33, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @ci, i16 0, i4 7), align 2, !dbg !59
  br label %34, !dbg !58

34:                                               ; preds = %32
  store i16 23050, i16* getelementptr inbounds ([32 x i16], [32 x i16]* @mark, i16 0, i5 10), align 2, !dbg !60
  %35 = load i16, i16* getelementptr inbounds ([4 x i16], [4 x i16]* @ai, i16 0, i3 3), align 2, !dbg !61
  %36 = load i16, i16* getelementptr inbounds ([4 x i16], [4 x i16]* @bi, i16 0, i3 3), align 2, !dbg !62
  %37 = icmp slt i16 %35, %36, !dbg !63
  br i1 %37, label %38, label %81, !dbg !64

38:                                               ; preds = %81, %34
  %39 = phi i16 [ %82, %81 ], [ 11, %34 ]
  store i16 %39, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @ci, i16 0, i5 8), align 2, !dbg !65
  br label %40, !dbg !64

40:                                               ; preds = %38
  store i16 23051, i16* getelementptr inbounds ([32 x i16], [32 x i16]* @mark, i16 0, i5 11), align 2, !dbg !66
  store i16 0, i16* %1, align 2, !dbg !7
  br label %41, !dbg !67

41:                                               ; preds = %59, %40
  %42 = phi i16 [ 0, %59 ], [ 0, %40 ]
  %43 = icmp sgt i16 %42, 0, !dbg !67
  br i1 %43, label %44, label %46, !dbg !67

44:                                               ; preds = %41
  %45 = sub i16 %42, 1, !dbg !67
  br label %47, !dbg !67

46:                                               ; preds = %41
  br label %47, !dbg !67

47:                                               ; preds = %44, %46
  %48 = phi i16 [ %42, %46 ], [ %45, %44 ]
  br label %49, !dbg !67

49:                                               ; preds = %47
  %50 = icmp ne i16 %42, 0, !dbg !67
  br i1 %50, label %51, label %52, !dbg !67

51:                                               ; preds = %49
  br label %56, !dbg !67

52:                                               ; preds = %49
  %53 = load i16, i16* %1, align 2, !dbg !68
  %54 = load i16, i16* getelementptr inbounds ([4 x i16], [4 x i16]* @bi, i16 0, i2 1), align 2, !dbg !69
  %55 = icmp ult i16 %53, %54, !dbg !70
  br label %56, !dbg !67

56:                                               ; preds = %51, %52
  %57 = phi i1 [ %55, %52 ], [ false, %51 ]
  br label %58, !dbg !67

58:                                               ; preds = %56
  br i1 %57, label %59, label %67, !dbg !67

59:                                               ; preds = %58
  %60 = load i16, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @ci, i16 0, i5 9), align 2, !dbg !71
  %61 = load i16, i16* %1, align 2, !dbg !72
  %62 = getelementptr [4 x i16], [4 x i16]* @ai, i16 0, i16 %61, !dbg !73
  %63 = load i16, i16* %62, align 2, !dbg !73
  %64 = add i16 %60, %63, !dbg !74
  store i16 %64, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @ci, i16 0, i5 9), align 2, !dbg !75
  %65 = load i16, i16* %1, align 2, !dbg !76
  %66 = add i16 %65, 1, !dbg !77
  store i16 %66, i16* %1, align 2, !dbg !77
  br label %41, !dbg !67

67:                                               ; preds = %58
  %68 = icmp ne i16 %48, 0, !dbg !67
  br i1 %68, label %69, label %70, !dbg !67

69:                                               ; preds = %67
  br label %78, !dbg !67

70:                                               ; preds = %67
  store i16 23052, i16* getelementptr inbounds ([32 x i16], [32 x i16]* @mark, i16 0, i5 12), align 2, !dbg !78
  %71 = load half, half* getelementptr inbounds ([4 x half], [4 x half]* @af, i16 0, i1 false), align 2, !dbg !79
  %72 = fpext half %71 to float, !dbg !80
  store float %72, float* getelementptr inbounds ([16 x float], [16 x float]* @"$$csl_base_address$$6$$c32", i16 0, i1 false), align 4, !dbg !81
  store i16 23053, i16* getelementptr inbounds ([32 x i16], [32 x i16]* @mark, i16 0, i5 13), align 2, !dbg !82
  %73 = load float, float* getelementptr inbounds ([8 x float], [8 x float]* @"$$csl_base_address$$7$$a32", i16 0, i1 false), align 4, !dbg !83
  %74 = fptrunc float %73 to half, !dbg !84
  store half %74, half* getelementptr inbounds ([16 x half], [16 x half]* @cf, i16 0, i3 2), align 2, !dbg !85
  store i16 23054, i16* getelementptr inbounds ([32 x i16], [32 x i16]* @mark, i16 0, i5 14), align 2, !dbg !86
  call void @llvm.sdr.lddwds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !87
  call void @llvm.sdr.fmov16.dr.f16(i16 1, half 0xH3E00), !dbg !87
  store i16 23055, i16* getelementptr inbounds ([32 x i16], [32 x i16]* @mark, i16 0, i5 15), align 2, !dbg !88
  call void @llvm.sdr.lds1wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !89
  call void @llvm.sdr.lddwds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__1 to i8*)), !dbg !89
  call void @llvm.sdr.fmov16.ds1(i16 1, i16 1), !dbg !89
  store i16 23056, i16* getelementptr inbounds ([32 x i16], [32 x i16]* @mark, i16 0, i6 16), align 2, !dbg !90
  call void @llvm.sdr.lds1wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__2 to i8*)), !dbg !91
  call void @llvm.sdr.lddwds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__3 to i8*)), !dbg !91
  call void @llvm.sdr.fmov16.ds1(i16 1, i16 1), !dbg !91
  store i16 23057, i16* getelementptr inbounds ([32 x i16], [32 x i16]* @mark, i16 0, i6 17), align 2, !dbg !92
  %75 = load half, half* @acc, align 2, !dbg !93
  call void @llvm.sdr.lds1wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !94
  %76 = call half @llvm.sdr.faddh.rrs1.f16(half %75, i16 1), !dbg !94
  store half %76, half* @acc, align 2, !dbg !94
  %77 = load half, half* @acc, align 2, !dbg !95
  store half %77, half* getelementptr inbounds ([16 x half], [16 x half]* @cf, i16 0, i3 3), align 2, !dbg !96
  store i16 23058, i16* getelementptr inbounds ([32 x i16], [32 x i16]* @mark, i16 0, i6 18), align 2, !dbg !97
  call void @llvm.sdr.lds1wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__4 to i8*)), !dbg !98
  call void @llvm.sdr.lddwds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__5 to i8*)), !dbg !98
  call void @llvm.sdr.lds0wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !98
  call void @llvm.sdr.fmulh.ds0s1(i16 1, i16 1, i16 1), !dbg !98
  store i16 23059, i16* getelementptr inbounds ([32 x i16], [32 x i16]* @mark, i16 0, i6 19), align 2, !dbg !99
  call void @llvm.sdr.lds1wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__4 to i8*)), !dbg !100
  call void @llvm.sdr.lddwds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__6 to i8*)), !dbg !100
  call void @llvm.sdr.lds0wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !100
  call void @llvm.sdr.fmach.ds0s1r.f16(i16 1, i16 1, i16 1, half 0xH3800), !dbg !100
  store i16 23060, i16* getelementptr inbounds ([32 x i16], [32 x i16]* @mark, i16 0, i6 20), align 2, !dbg !101
  call void @llvm.sdr.lds1wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__7 to i8*)), !dbg !102
  call void @llvm.sdr.lddwds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__8 to i8*)), !dbg !102
  call void @llvm.sdr.lds0wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__9 to i8*)), !dbg !102
  call void @llvm.sdr.add16.ds0s1(i16 1, i16 1, i16 1), !dbg !102
  store i16 23061, i16* getelementptr inbounds ([32 x i16], [32 x i16]* @mark, i16 0, i6 21), align 2, !dbg !103
  call void @llvm.sdr.lds1wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__10 to i8*)), !dbg !104
  call void @llvm.sdr.lddwds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__11 to i8*)), !dbg !104
  call void @llvm.sdr.lds0wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__12 to i8*)), !dbg !104
  call void @llvm.sdr.fadds.ds0s1(i16 1, i16 1, i16 1), !dbg !104
  store i16 23062, i16* getelementptr inbounds ([32 x i16], [32 x i16]* @mark, i16 0, i6 22), align 2, !dbg !105
  call void @llvm.sdr.actvt.r(i16 9), !dbg !106
  br label %78, !dbg !67

78:                                               ; preds = %69, %70
  ret void, !dbg !58

79:                                               ; preds = %0
  %80 = phi i16 [ 22, %0 ]
  br label %32, !dbg !58

81:                                               ; preds = %34
  %82 = phi i16 [ 22, %34 ]
  br label %38, !dbg !64
}

define void @f_exit() #0 !dbg !107 {
  call void @sys_mod.unblock_cmd_stream(), !dbg !108
  ret void, !dbg !110
}

define internal void @sys_mod.sys_nop() !dbg !111 {
  ret void, !dbg !113
}

define internal void @sys_mod.unblock_cmd_stream() !dbg !115 {
  call void @sys_mod.sys_mod.unblock_cmd_stream(), !dbg !116
  ret void, !dbg !118
}

define internal void @sys_mod.sys_mod.unblock_cmd_stream() !dbg !119 {
  call void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream(), !dbg !121
  ret void, !dbg !123
}

define internal void @sys_mod.sys_mod.teardown_h2d() !dbg !124 {
  call void @llvm.sdr.actvt.r(i16 27), !dbg !125
  ret void, !dbg !127
}

define void @sys_mod.sys_mod.f_ublk_c22() #1 !dbg !128 {
  call void @sys_mod.sys_mod.unblock_cmd_stream(), !dbg !129
  ret void, !dbg !131
}

define internal void @sys_mod.sys_mod.teardown_d2h() !dbg !132 {
  call void @llvm.sdr.blk.r(i16 0), !dbg !133
  call void @llvm.sdr.actvt.r(i16 28), !dbg !135
  ret void, !dbg !136
}

define void @sys_mod.sys_mod.f_memcpyh2d() #2 !dbg !137 {
  %1 = alloca float, i16 1, align 4, !dbg !138
  %2 = alloca float, i16 1, align 4, !dbg !140
  %3 = alloca i16, i16 1, align 2, !dbg !141
  %4 = alloca i16, i16 1, align 2, !dbg !142
  %5 = alloca i16, i16 1, align 2, !dbg !143
  %6 = alloca i16, i16 1, align 2, !dbg !144
  %7 = alloca i16, i16 1, align 2, !dbg !145
  %8 = alloca i16, i16 1, align 2, !dbg !146
  %9 = alloca i16, i16 1, align 2, !dbg !147
  %10 = alloca i16, i16 1, align 2, !dbg !148
  %11 = alloca i16, i16 1, align 2, !dbg !149
  %12 = alloca i16, i16 1, align 2, !dbg !150
  %13 = alloca i16, i16 1, align 2, !dbg !151
  %14 = alloca i16*, i16 1, align 8, !dbg !152
  %15 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !153
  %16 = icmp eq i16 %15, 15, !dbg !154
  br i1 %16, label %17, label %18, !dbg !155

17:                                               ; preds = %0
  br label %19, !dbg !155

18:                                               ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !155
  br label %19, !dbg !155

19:                                               ; preds = %17, %18
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %14, align 8, !dbg !152
  %20 = load i16*, i16** %14, align 8, !dbg !156
  %21 = load i16, i16* %20, align 2, !dbg !157
  store i16 %21, i16* %13, align 2, !dbg !151
  %22 = load i16*, i16** %14, align 8, !dbg !158
  %23 = getelementptr i16, i16* %22, i16 1, !dbg !159
  %24 = load i16, i16* %23, align 2, !dbg !159
  store i16 %24, i16* %12, align 2, !dbg !150
  %25 = load i16*, i16** %14, align 8, !dbg !160
  %26 = getelementptr i16, i16* %25, i16 2, !dbg !161
  %27 = load i16, i16* %26, align 2, !dbg !161
  store i16 %27, i16* %11, align 2, !dbg !149
  %28 = load i16*, i16** %14, align 8, !dbg !162
  %29 = getelementptr i16, i16* %28, i16 3, !dbg !163
  %30 = load i16, i16* %29, align 2, !dbg !163
  store i16 %30, i16* %10, align 2, !dbg !148
  %31 = load i16*, i16** %14, align 8, !dbg !164
  %32 = getelementptr i16, i16* %31, i16 4, !dbg !165
  %33 = load i16, i16* %32, align 2, !dbg !165
  store i16 %33, i16* %9, align 2, !dbg !147
  %34 = load i16*, i16** %14, align 8, !dbg !166
  %35 = getelementptr i16, i16* %34, i16 5, !dbg !167
  %36 = load i16, i16* %35, align 2, !dbg !167
  store i16 %36, i16* %8, align 2, !dbg !146
  %37 = load i16*, i16** %14, align 8, !dbg !168
  %38 = getelementptr i16, i16* %37, i16 6, !dbg !169
  %39 = load i16, i16* %38, align 2, !dbg !169
  store i16 %39, i16* %7, align 2, !dbg !145
  %40 = load i16*, i16** %14, align 8, !dbg !170
  %41 = getelementptr i16, i16* %40, i16 7, !dbg !171
  %42 = load i16, i16* %41, align 2, !dbg !171
  store i16 %42, i16* %6, align 2, !dbg !144
  %43 = load i16*, i16** %14, align 8, !dbg !172
  %44 = getelementptr i16, i16* %43, i16 8, !dbg !173
  %45 = load i16, i16* %44, align 2, !dbg !173
  store i16 %45, i16* %5, align 2, !dbg !143
  %46 = load i16*, i16** %14, align 8, !dbg !174
  %47 = getelementptr i16, i16* %46, i16 9, !dbg !175
  %48 = load i16, i16* %47, align 2, !dbg !175
  store i16 %48, i16* %4, align 2, !dbg !142
  %49 = load i16*, i16** %14, align 8, !dbg !176
  %50 = getelementptr i16, i16* %49, i16 10, !dbg !177
  %51 = load i16, i16* %50, align 2, !dbg !177
  store i16 %51, i16* %3, align 2, !dbg !141
  %52 = load i16*, i16** %14, align 8, !dbg !178
  %53 = getelementptr i16, i16* %52, i16 12, !dbg !179
  %54 = load i16, i16* %53, align 2, !dbg !179
  %55 = zext i16 %54 to i32, !dbg !180
  %56 = load i16*, i16** %14, align 8, !dbg !181
  %57 = getelementptr i16, i16* %56, i16 11, !dbg !182
  %58 = load i16, i16* %57, align 2, !dbg !182
  %59 = zext i16 %58 to i32, !dbg !183
  %60 = add i32 %59, 16, !dbg !184
  %61 = shl i32 %55, %60, !dbg !185
  %62 = bitcast i32 %61 to float, !dbg !186
  store float %62, float* %2, align 4, !dbg !140
  %63 = load i16*, i16** %14, align 8, !dbg !187
  %64 = getelementptr i16, i16* %63, i16 14, !dbg !188
  %65 = load i16, i16* %64, align 2, !dbg !188
  %66 = zext i16 %65 to i32, !dbg !189
  %67 = load i16*, i16** %14, align 8, !dbg !190
  %68 = getelementptr i16, i16* %67, i16 13, !dbg !191
  %69 = load i16, i16* %68, align 2, !dbg !191
  %70 = zext i16 %69 to i32, !dbg !192
  %71 = add i32 %70, 16, !dbg !193
  %72 = shl i32 %66, %71, !dbg !194
  %73 = bitcast i32 %72 to float, !dbg !195
  store float %73, float* %1, align 4, !dbg !138
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !196
  %74 = load i16, i16* %13, align 2, !dbg !197
  store i16 %74, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !198
  %75 = load i16, i16* %12, align 2, !dbg !199
  store i16 %75, i16* @sys_mod.sys_mod.memcpyH2D_px, align 2, !dbg !200
  %76 = load i16, i16* %11, align 2, !dbg !201
  store i16 %76, i16* @sys_mod.sys_mod.memcpyH2D_py, align 2, !dbg !202
  %77 = load i16, i16* %10, align 2, !dbg !203
  store i16 %77, i16* @sys_mod.sys_mod.memcpyH2D_w, align 2, !dbg !204
  %78 = load i16, i16* %9, align 2, !dbg !205
  store i16 %78, i16* @sys_mod.sys_mod.memcpyH2D_h, align 2, !dbg !206
  %79 = load i16, i16* %8, align 2, !dbg !207
  store i16 %79, i16* @sys_mod.sys_mod.memcpyH2D_addr, align 2, !dbg !208
  %80 = load i16, i16* %7, align 2, !dbg !209
  store i16 %80, i16* @sys_mod.sys_mod.memcpyH2D_pe_length, align 2, !dbg !210
  %81 = load i16, i16* %6, align 2, !dbg !211
  store i16 %81, i16* @sys_mod.sys_mod.memcpyH2D_is_half, align 2, !dbg !212
  %82 = load i16, i16* %5, align 2, !dbg !213
  store i16 %82, i16* @sys_mod.sys_mod.memcpyH2D_memcpy_optype, align 2, !dbg !214
  %83 = load i16, i16* %4, align 2, !dbg !215
  store i16 %83, i16* @sys_mod.sys_mod.memcpyH2D_row_stride, align 2, !dbg !216
  %84 = load i16, i16* %3, align 2, !dbg !217
  store i16 %84, i16* @sys_mod.sys_mod.memcpyH2D_col_stride, align 2, !dbg !218
  %85 = load float, float* %2, align 4, !dbg !219
  store float %85, float* @sys_mod.sys_mod.memcpyH2D_one_over_row_stride, align 4, !dbg !220
  %86 = load float, float* %1, align 4, !dbg !221
  store float %86, float* @sys_mod.sys_mod.memcpyH2D_one_over_col_stride, align 4, !dbg !222
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !223
  call void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 0, i16 23, i1 true), !dbg !224
  call void @llvm.sdr.blk.r(i16 27), !dbg !225
  call void @llvm.sdr.oqflush(i16 0), !dbg !226
  store i1 true, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !227
  call void @llvm.sdr.blk.r(i16 0), !dbg !228
  ret void, !dbg !229
}

define void @sys_mod.sys_mod.f_memcpyd2h() #3 !dbg !230 {
  %1 = alloca i16, i16 1, align 2, !dbg !231
  %2 = alloca i16, i16 1, align 2, !dbg !233
  %3 = alloca i16, i16 1, align 2, !dbg !234
  %4 = alloca i16, i16 1, align 2, !dbg !235
  %5 = alloca i16, i16 1, align 2, !dbg !236
  %6 = alloca i16, i16 1, align 2, !dbg !237
  %7 = alloca i16, i16 1, align 2, !dbg !238
  %8 = alloca i16, i16 1, align 2, !dbg !239
  %9 = alloca i16*, i16 1, align 8, !dbg !240
  %10 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !241
  %11 = icmp eq i16 %10, 8, !dbg !242
  br i1 %11, label %12, label %13, !dbg !243

12:                                               ; preds = %0
  br label %14, !dbg !243

13:                                               ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !243
  br label %14, !dbg !243

14:                                               ; preds = %12, %13
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %9, align 8, !dbg !240
  %15 = load i16*, i16** %9, align 8, !dbg !244
  %16 = load i16, i16* %15, align 2, !dbg !245
  store i16 %16, i16* %8, align 2, !dbg !239
  %17 = load i16*, i16** %9, align 8, !dbg !246
  %18 = getelementptr i16, i16* %17, i16 1, !dbg !247
  %19 = load i16, i16* %18, align 2, !dbg !247
  store i16 %19, i16* %7, align 2, !dbg !238
  %20 = load i16*, i16** %9, align 8, !dbg !248
  %21 = getelementptr i16, i16* %20, i16 2, !dbg !249
  %22 = load i16, i16* %21, align 2, !dbg !249
  store i16 %22, i16* %6, align 2, !dbg !237
  %23 = load i16*, i16** %9, align 8, !dbg !250
  %24 = getelementptr i16, i16* %23, i16 3, !dbg !251
  %25 = load i16, i16* %24, align 2, !dbg !251
  store i16 %25, i16* %5, align 2, !dbg !236
  %26 = load i16*, i16** %9, align 8, !dbg !252
  %27 = getelementptr i16, i16* %26, i16 4, !dbg !253
  %28 = load i16, i16* %27, align 2, !dbg !253
  store i16 %28, i16* %4, align 2, !dbg !235
  %29 = load i16*, i16** %9, align 8, !dbg !254
  %30 = getelementptr i16, i16* %29, i16 5, !dbg !255
  %31 = load i16, i16* %30, align 2, !dbg !255
  store i16 %31, i16* %3, align 2, !dbg !234
  %32 = load i16*, i16** %9, align 8, !dbg !256
  %33 = getelementptr i16, i16* %32, i16 6, !dbg !257
  %34 = load i16, i16* %33, align 2, !dbg !257
  store i16 %34, i16* %2, align 2, !dbg !233
  %35 = load i16*, i16** %9, align 8, !dbg !258
  %36 = getelementptr i16, i16* %35, i16 7, !dbg !259
  %37 = load i16, i16* %36, align 2, !dbg !259
  store i16 %37, i16* %1, align 2, !dbg !231
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !260
  %38 = load i16, i16* %8, align 2, !dbg !261
  store i16 %38, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !262
  %39 = load i16, i16* %7, align 2, !dbg !263
  store i16 %39, i16* @sys_mod.sys_mod.memcpyD2H_px, align 2, !dbg !264
  %40 = load i16, i16* %6, align 2, !dbg !265
  store i16 %40, i16* @sys_mod.sys_mod.memcpyD2H_py, align 2, !dbg !266
  %41 = load i16, i16* %5, align 2, !dbg !267
  store i16 %41, i16* @sys_mod.sys_mod.memcpyD2H_w, align 2, !dbg !268
  %42 = load i16, i16* %4, align 2, !dbg !269
  store i16 %42, i16* @sys_mod.sys_mod.memcpyD2H_h, align 2, !dbg !270
  %43 = load i16, i16* %3, align 2, !dbg !271
  store i16 %43, i16* @sys_mod.sys_mod.memcpyD2H_addr, align 2, !dbg !272
  %44 = load i16, i16* %2, align 2, !dbg !273
  store i16 %44, i16* @sys_mod.sys_mod.memcpyD2H_pe_length, align 2, !dbg !274
  %45 = load i16, i16* %1, align 2, !dbg !275
  store i16 %45, i16* @sys_mod.sys_mod.memcpyD2H_is_half, align 2, !dbg !276
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !277
  %46 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !278
  call void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 0, i16 %46, i1 false), !dbg !279
  call void @llvm.sdr.oqflush(i16 0), !dbg !280
  store i1 false, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !281
  ret void, !dbg !282
}

define internal void @sys_mod.sys_mod.oq0_teardow_handler() !dbg !283 {
  %1 = load i1, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !284
  br i1 %1, label %2, label %17, !dbg !286

2:                                                ; preds = %0
  %3 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !287
  call void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 0, i16 %3), !dbg !288
  %4 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !289
  %5 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_px, align 2, !dbg !290
  %6 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_py, align 2, !dbg !291
  %7 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_w, align 2, !dbg !292
  %8 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_h, align 2, !dbg !293
  %9 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_addr, align 2, !dbg !294
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_pe_length, align 2, !dbg !295
  %11 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_is_half, align 2, !dbg !296
  %12 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_memcpy_optype, align 2, !dbg !297
  %13 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_row_stride, align 2, !dbg !298
  %14 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_col_stride, align 2, !dbg !299
  %15 = load float, float* @sys_mod.sys_mod.memcpyH2D_one_over_row_stride, align 4, !dbg !300
  %16 = load float, float* @sys_mod.sys_mod.memcpyH2D_one_over_col_stride, align 4, !dbg !301
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure(i16 %4, i16 %5, i16 %6, i16 %7, i16 %8, i16 %9, i16 %10, i16 %11, i16 %12, i16 %13, i16 %14, float %15, float %16), !dbg !302
  br label %26, !dbg !286

17:                                               ; preds = %0
  call void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 0, i16 21), !dbg !303
  %18 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !304
  %19 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_px, align 2, !dbg !305
  %20 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_py, align 2, !dbg !306
  %21 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_w, align 2, !dbg !307
  %22 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_h, align 2, !dbg !308
  %23 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_addr, align 2, !dbg !309
  %24 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_pe_length, align 2, !dbg !310
  %25 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_is_half, align 2, !dbg !311
  call void @sys_mod.sys_mod.memcpyd2h_mod.d2h_configure(i16 %18, i16 %19, i16 %20, i16 %21, i16 %22, i16 %23, i16 %24, i16 %25), !dbg !312
  br label %26, !dbg !286

26:                                               ; preds = %2, %17
  call void @__generic0sys_mod.sys_mod.tile_config.queue_flush.exit(), !dbg !313
  ret void, !dbg !286
}

define internal void @rpc_server(i32* %0) {
  %2 = load i32, i32* %0, align 4
  %3 = add i32 %2, 1
  %4 = getelementptr i32, i32* %0, i32 %3
  %5 = load i32, i32* %4, align 4
  switch i32 %5, label %6 [
    i32 17, label %7
  ]

6:                                                ; preds = %1
  br label %12

7:                                                ; preds = %1
  %8 = icmp eq i32 0, %2
  br i1 %8, label %9, label %10

9:                                                ; preds = %7
  br label %11

10:                                               ; preds = %7
  call void asm sideeffect "hcf", ""()
  br label %11

11:                                               ; preds = %9, %10
  call void @compute()
  br label %12

12:                                               ; preds = %6, %11
  ret void
}

define void @sys_mod.sys_mod.f_rpc(i16 %0) #4 !dbg !314 {
  %2 = alloca i16, i16 1, align 2, !dbg !315
  store i16 %0, i16* %2, align 2, !dbg !315
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !317
  %3 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !318
  %4 = icmp sge i16 %3, 4, !dbg !319
  br i1 %4, label %5, label %6, !dbg !320

5:                                                ; preds = %1
  br label %7, !dbg !320

6:                                                ; preds = %1
  call void asm sideeffect "hcf", ""(), !dbg !320
  br label %7, !dbg !320

7:                                                ; preds = %5, %6
  call void @rpc_server(i32* getelementptr inbounds ([32 x i32], [32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32, i32 0, i32 0)), !dbg !321
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !322
  ret void, !dbg !323
}

define internal void @sys_mod.sys_mod.sys_mod.stack_push(i16 %0) !dbg !324 {
  %2 = alloca i16*, i16 1, align 8, !dbg !326
  %3 = alloca i16, i16 1, align 2, !dbg !328
  store i16 %0, i16* %3, align 2, !dbg !328
  %4 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !329
  %5 = icmp slt i16 %4, 32, !dbg !330
  br i1 %5, label %6, label %7, !dbg !331

6:                                                ; preds = %1
  br label %8, !dbg !331

7:                                                ; preds = %1
  call void asm sideeffect "hcf", ""(), !dbg !331
  br label %8, !dbg !331

8:                                                ; preds = %6, %7
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %2, align 8, !dbg !326
  %9 = load i16, i16* %3, align 2, !dbg !332
  %10 = load i16*, i16** %2, align 8, !dbg !333
  %11 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !334
  %12 = getelementptr i16, i16* %10, i16 %11, !dbg !335
  store i16 %9, i16* %12, align 2, !dbg !336
  %13 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !337
  %14 = add i16 %13, 1, !dbg !338
  store i16 %14, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !339
  ret void, !dbg !340
}

define void @sys_mod.sys_mod.sys_mod.f_push(i16 %0, i16 %1) #5 !dbg !341 {
  %3 = alloca i16, i16 1, align 2, !dbg !342
  %4 = alloca i16, i16 1, align 2, !dbg !344
  store i16 %0, i16* %4, align 2, !dbg !344
  store i16 %1, i16* %3, align 2, !dbg !342
  %5 = load i16, i16* %4, align 2, !dbg !345
  call void @sys_mod.sys_mod.sys_mod.stack_push(i16 %5), !dbg !346
  ret void, !dbg !347
}

define internal void @sys_mod.sys_mod.sys_mod.block_cmd_stream() !dbg !348 {
  call void @llvm.sdr.blk.r(i16 1), !dbg !349
  ret void, !dbg !351
}

define internal void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream() !dbg !352 {
  call void @llvm.sdr.ublk.r(i16 1), !dbg !353
  ret void, !dbg !355
}

define void @sys_mod.sys_mod.sys_mod.f_sys_exit() #6 !dbg !356 {
  call void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream(), !dbg !357
  call void @sys_mod.sys_nop(), !dbg !359
  ret void, !dbg !360
}

define void @sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore(i32 %0) #7 !dbg !361 {
  %2 = alloca i32, i16 1, align 4, !dbg !362
  store i32 %0, i32* %2, align 4, !dbg !362
  ret void, !dbg !364
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord() !dbg !365 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord(), !dbg !367
  ret i16 %1, !dbg !369
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord() !dbg !370 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord(), !dbg !371
  ret i16 %1, !dbg !373
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval(i16 %0) !dbg !374 {
  %2 = alloca i16, i16 1, align 2, !dbg !375
  store i16 %0, i16* %2, align 2, !dbg !375
  %3 = load i16, i16* %2, align 2, !dbg !377
  %4 = icmp ult i16 %3, 24, !dbg !378
  br i1 %4, label %5, label %7, !dbg !379

5:                                                ; preds = %10, %11, %1
  %6 = phi i16 [ 0, %10 ], [ 0, %11 ], [ 1, %1 ]
  br label %12, !dbg !379

7:                                                ; preds = %1
  %8 = load i16, i16* %2, align 2, !dbg !380
  %9 = icmp eq i16 31, %8, !dbg !381
  br i1 %9, label %10, label %11, !dbg !382

10:                                               ; preds = %7
  br label %5, !dbg !382

11:                                               ; preds = %7
  call void asm sideeffect "hcf", ""(), !dbg !382
  br label %5, !dbg !382

12:                                               ; preds = %5
  %13 = phi i16 [ %6, %5 ]
  br label %14, !dbg !379

14:                                               ; preds = %12
  ret i16 %13, !dbg !379
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start(i16 %0, i16 %1, i16 %2) !dbg !383 {
  %4 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !384
  %5 = alloca i16, i16 1, align 2, !dbg !386
  %6 = alloca i16, i16 1, align 2, !dbg !387
  %7 = alloca i16, i16 1, align 2, !dbg !388
  store i16 %0, i16* %7, align 2, !dbg !388
  store i16 %1, i16* %6, align 2, !dbg !387
  store i16 %2, i16* %5, align 2, !dbg !386
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !389
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !389
  %10 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !389
  %11 = load i16, i16* %6, align 2, !dbg !390
  store i16 %11, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !391
  store i16 %8, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !391
  store i16 %9, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !391
  store i16 %10, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !391
  %12 = load i16, i16* %7, align 2, !dbg !392
  %13 = call i16* @.get_tensor_ptr(i16 %12), !dbg !393
  %14 = ptrtoint i16* %13 to i16, !dbg !394
  %15 = lshr i16 %14, 1, !dbg !394
  %16 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !384
  store i16 42, i16* %16, align 2, !dbg !384
  %17 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !384
  store i16 %15, i16* %17, align 2, !dbg !384
  %18 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !384
  store i16 143, i16* %18, align 2, !dbg !384
  %19 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !384
  store i16 16, i16* %19, align 2, !dbg !384
  %20 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !395
  %21 = load i16, i16* %20, align 2, !dbg !395
  %22 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !395
  %23 = load i16, i16* %22, align 2, !dbg !395
  %24 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !395
  %25 = load i16, i16* %24, align 2, !dbg !395
  %26 = load i16, i16* %6, align 2, !dbg !396
  %27 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !397
  store i16 %26, i16* %27, align 2, !dbg !397
  %28 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !397
  store i16 %21, i16* %28, align 2, !dbg !397
  %29 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !397
  store i16 %23, i16* %29, align 2, !dbg !397
  %30 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !397
  store i16 %25, i16* %30, align 2, !dbg !397
  %31 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !398
  %32 = load i16, i16* %31, align 2, !dbg !398
  %33 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !398
  %34 = load i16, i16* %33, align 2, !dbg !398
  %35 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !398
  %36 = load i16, i16* %35, align 2, !dbg !398
  %37 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !398
  %38 = load i16, i16* %37, align 2, !dbg !398
  store volatile i16 %32, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !399
  store volatile i16 %34, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !399
  store volatile i16 %36, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !399
  store volatile i16 %38, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !399
  call void asm sideeffect "nop", ""(), !dbg !399
  call void asm sideeffect "nop", ""(), !dbg !399
  %39 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !400
  %40 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !400
  %41 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !400
  %42 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !400
  %43 = and i16 %41, -193, !dbg !400
  %44 = or i16 %43, 128, !dbg !400
  %45 = and i16 %40, -64, !dbg !400
  %46 = or i16 %45, 27, !dbg !400
  store volatile i16 %39, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !401
  store volatile i16 %46, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !401
  store volatile i16 %44, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !401
  store volatile i16 %42, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !401
  call void asm sideeffect "nop", ""(), !dbg !401
  call void asm sideeffect "nop", ""(), !dbg !401
  %47 = load i16, i16* %5, align 2, !dbg !402
  %48 = icmp ult i16 0, %47, !dbg !403
  br i1 %48, label %49, label %50, !dbg !404

49:                                               ; preds = %3
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !405
  br label %51, !dbg !404

50:                                               ; preds = %3
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !406
  br label %51, !dbg !404

51:                                               ; preds = %49, %50
  ret void, !dbg !404
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream() !dbg !407 {
  call void @llvm.sdr.ublk.r(i16 1), !dbg !408
  ret void, !dbg !410
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7, i16 %8, i16 %9, i16 %10, float %11, float %12) !dbg !411 {
  %14 = alloca i16, i16 1, align 2, !dbg !412
  %15 = alloca i16, i16 1, align 2, !dbg !414
  %16 = alloca i16, i16 1, align 2, !dbg !415
  %17 = alloca i16, i16 1, align 2, !dbg !416
  %18 = alloca i16, i16 1, align 2, !dbg !417
  %19 = alloca i1, i16 1, align 1, !dbg !418
  %20 = alloca i16, i16 1, align 2, !dbg !419
  %21 = alloca i16, i16 1, align 2, !dbg !420
  %22 = alloca i16, i16 1, align 2, !dbg !421
  %23 = alloca i16, i16 1, align 2, !dbg !422
  %24 = alloca i16, i16 1, align 2, !dbg !423
  %25 = alloca float, i16 1, align 4, !dbg !424
  %26 = alloca float, i16 1, align 4, !dbg !425
  %27 = alloca i16, i16 1, align 2, !dbg !426
  %28 = alloca i16, i16 1, align 2, !dbg !427
  %29 = alloca i16, i16 1, align 2, !dbg !428
  %30 = alloca i16, i16 1, align 2, !dbg !429
  %31 = alloca i16, i16 1, align 2, !dbg !430
  %32 = alloca i16, i16 1, align 2, !dbg !431
  %33 = alloca i16, i16 1, align 2, !dbg !432
  %34 = alloca i16, i16 1, align 2, !dbg !433
  %35 = alloca i16, i16 1, align 2, !dbg !434
  %36 = alloca i16, i16 1, align 2, !dbg !435
  %37 = alloca i16, i16 1, align 2, !dbg !436
  store i16 %0, i16* %37, align 2, !dbg !436
  store i16 %1, i16* %36, align 2, !dbg !435
  store i16 %2, i16* %35, align 2, !dbg !434
  store i16 %3, i16* %34, align 2, !dbg !433
  store i16 %4, i16* %33, align 2, !dbg !432
  store i16 %5, i16* %32, align 2, !dbg !431
  store i16 %6, i16* %31, align 2, !dbg !430
  store i16 %7, i16* %30, align 2, !dbg !429
  store i16 %8, i16* %29, align 2, !dbg !428
  store i16 %9, i16* %28, align 2, !dbg !427
  store i16 %10, i16* %27, align 2, !dbg !426
  store float %11, float* %26, align 4, !dbg !425
  store float %12, float* %25, align 4, !dbg !424
  %38 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord(), !dbg !437
  store i16 %38, i16* %24, align 2, !dbg !423
  %39 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord(), !dbg !438
  store i16 %39, i16* %23, align 2, !dbg !422
  %40 = load i16, i16* %24, align 2, !dbg !439
  %41 = load i16, i16* %36, align 2, !dbg !440
  %42 = sub i16 %40, %41, !dbg !441
  store i16 %42, i16* %22, align 2, !dbg !421
  %43 = load i16, i16* %22, align 2, !dbg !442
  store i16 %43, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !443
  %44 = load i16, i16* %29, align 2, !dbg !444
  %45 = icmp eq i16 3, %44, !dbg !445
  br i1 %45, label %46, label %63, !dbg !446

46:                                               ; preds = %13
  %47 = load i16, i16* %22, align 2, !dbg !447
  %48 = sitofp i16 %47 to float, !dbg !448
  %49 = load float, float* %26, align 4, !dbg !449
  %50 = fmul float %48, %49, !dbg !450
  %51 = fptosi float %50 to i16, !dbg !451
  store i16 %51, i16* %21, align 2, !dbg !420
  %52 = load i16, i16* %22, align 2, !dbg !452
  %53 = load i16, i16* %21, align 2, !dbg !453
  %54 = load i16, i16* %28, align 2, !dbg !454
  %55 = mul i16 %53, %54, !dbg !455
  %56 = sub i16 %52, %55, !dbg !456
  store i16 %56, i16* %20, align 2, !dbg !419
  %57 = load i16, i16* %20, align 2, !dbg !457
  %58 = icmp ne i16 0, %57, !dbg !458
  br i1 %58, label %59, label %60, !dbg !459

59:                                               ; preds = %46
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !460
  br label %62, !dbg !459

60:                                               ; preds = %46
  %61 = load i16, i16* %21, align 2, !dbg !461
  store i16 %61, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !462
  br label %62, !dbg !459

62:                                               ; preds = %59, %60
  br label %63, !dbg !446

63:                                               ; preds = %62, %13
  %64 = load i16, i16* %22, align 2, !dbg !463
  %65 = icmp slt i16 %64, 0, !dbg !464
  br i1 %65, label %66, label %67, !dbg !465

66:                                               ; preds = %63
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !466
  br label %67, !dbg !465

67:                                               ; preds = %66, %63
  %68 = load i16, i16* %22, align 2, !dbg !467
  %69 = load i16, i16* %34, align 2, !dbg !468
  %70 = icmp sge i16 %68, %69, !dbg !469
  br i1 %70, label %71, label %72, !dbg !470

71:                                               ; preds = %67
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !471
  br label %72, !dbg !470

72:                                               ; preds = %71, %67
  store i1 false, i1* %19, align 1, !dbg !418
  %73 = load i16, i16* %29, align 2, !dbg !472
  %74 = icmp eq i16 3, %73, !dbg !473
  br i1 %74, label %75, label %94, !dbg !474

75:                                               ; preds = %72
  %76 = load i16, i16* %23, align 2, !dbg !475
  %77 = load i16, i16* %35, align 2, !dbg !476
  %78 = sub i16 %76, %77, !dbg !477
  %79 = sitofp i16 %78 to float, !dbg !478
  %80 = load float, float* %25, align 4, !dbg !479
  %81 = fmul float %79, %80, !dbg !480
  %82 = fptosi float %81 to i16, !dbg !481
  store i16 %82, i16* %18, align 2, !dbg !417
  %83 = load i16, i16* %23, align 2, !dbg !482
  %84 = load i16, i16* %35, align 2, !dbg !483
  %85 = sub i16 %83, %84, !dbg !484
  %86 = load i16, i16* %18, align 2, !dbg !485
  %87 = load i16, i16* %27, align 2, !dbg !486
  %88 = mul i16 %86, %87, !dbg !487
  %89 = sub i16 %85, %88, !dbg !488
  store i16 %89, i16* %17, align 2, !dbg !416
  %90 = load i16, i16* %17, align 2, !dbg !489
  %91 = icmp ne i16 0, %90, !dbg !490
  br i1 %91, label %92, label %93, !dbg !491

92:                                               ; preds = %75
  store i1 true, i1* %19, align 1, !dbg !492
  br label %93, !dbg !491

93:                                               ; preds = %92, %75
  br label %94, !dbg !474

94:                                               ; preds = %93, %72
  %95 = load i16, i16* %23, align 2, !dbg !493
  %96 = load i16, i16* %35, align 2, !dbg !494
  %97 = icmp slt i16 %95, %96, !dbg !495
  br i1 %97, label %98, label %99, !dbg !496

98:                                               ; preds = %94
  store i1 true, i1* %19, align 1, !dbg !497
  br label %99, !dbg !496

99:                                               ; preds = %98, %94
  %100 = load i16, i16* %23, align 2, !dbg !498
  %101 = load i16, i16* %35, align 2, !dbg !499
  %102 = load i16, i16* %33, align 2, !dbg !500
  %103 = add i16 %101, %102, !dbg !501
  %104 = icmp sge i16 %100, %103, !dbg !502
  br i1 %104, label %105, label %106, !dbg !503

105:                                              ; preds = %99
  store i1 true, i1* %19, align 1, !dbg !504
  br label %106, !dbg !503

106:                                              ; preds = %105, %99
  %107 = load i1, i1* %19, align 1, !dbg !505
  br i1 %107, label %108, label %109, !dbg !506

108:                                              ; preds = %106
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream(), !dbg !507
  call void @llvm.sdr.ublk.r(i16 27), !dbg !508
  br label %180, !dbg !506

109:                                              ; preds = %106
  %110 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !509
  %111 = icmp eq i16 -1, %110, !dbg !510
  br i1 %111, label %112, label %113, !dbg !511

112:                                              ; preds = %109
  call void @__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction(i16 31767), !dbg !512
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 23), !dbg !513
  call void @llvm.sdr.ublk.r(i16 27), !dbg !514
  br label %179, !dbg !511

113:                                              ; preds = %109
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter(i16 0, i16 0), !dbg !515
  %114 = load i16, i16* %34, align 2, !dbg !516
  store i16 %114, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !517
  %115 = load i16, i16* %29, align 2, !dbg !518
  %116 = icmp eq i16 3, %115, !dbg !519
  br i1 %116, label %117, label %126, !dbg !520

117:                                              ; preds = %113
  %118 = load i16, i16* %34, align 2, !dbg !521
  %119 = sub i16 %118, 1, !dbg !522
  %120 = sitofp i16 %119 to float, !dbg !523
  %121 = load float, float* %26, align 4, !dbg !524
  %122 = fmul float %120, %121, !dbg !525
  %123 = fptosi float %122 to i16, !dbg !526
  %124 = add i16 %123, 1, !dbg !527
  store i16 %124, i16* %16, align 2, !dbg !415
  %125 = load i16, i16* %16, align 2, !dbg !528
  store i16 %125, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !529
  br label %131, !dbg !520

126:                                              ; preds = %113
  %127 = load i16, i16* %29, align 2, !dbg !530
  %128 = icmp eq i16 1, %127, !dbg !531
  br i1 %128, label %129, label %130, !dbg !532

129:                                              ; preds = %126
  store i16 1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !533
  br label %130, !dbg !532

130:                                              ; preds = %129, %126
  br label %131, !dbg !520

131:                                              ; preds = %117, %130
  %132 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !534
  %133 = sub i16 %132, 1, !dbg !535
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit(i16 0, i16 %133), !dbg !536
  %134 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !537
  store i16 %134, i16* %15, align 2, !dbg !414
  %135 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !538
  store i16 %135, i16* %14, align 2, !dbg !412
  %136 = load i16, i16* %15, align 2, !dbg !539
  %137 = load i16, i16* %14, align 2, !dbg !540
  %138 = sub i16 %136, %137, !dbg !541
  store i16 %138, i16* %15, align 2, !dbg !542
  %139 = load i16, i16* %14, align 2, !dbg !543
  %140 = icmp eq i16 0, %139, !dbg !544
  br i1 %140, label %141, label %142, !dbg !545

141:                                              ; preds = %131
  store i16 0, i16* %15, align 2, !dbg !546
  br label %142, !dbg !545

142:                                              ; preds = %141, %131
  %143 = load i16, i16* %29, align 2, !dbg !547
  %144 = icmp eq i16 1, %143, !dbg !548
  br i1 %144, label %145, label %146, !dbg !549

145:                                              ; preds = %142
  store i16 0, i16* %15, align 2, !dbg !550
  br label %146, !dbg !549

146:                                              ; preds = %145, %142
  %147 = load i16, i16* %15, align 2, !dbg !551
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter(i16 0, i16 %147), !dbg !552
  call void @__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction(i16 31767), !dbg !553
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 23), !dbg !554
  %148 = load i16, i16* %37, align 2, !dbg !555
  %149 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval(i16 %148), !dbg !556
  %150 = icmp eq i16 0, %149, !dbg !557
  br i1 %150, label %151, label %155, !dbg !558

151:                                              ; preds = %146
  %152 = load i16, i16* %32, align 2, !dbg !559
  %153 = load i16, i16* %31, align 2, !dbg !560
  %154 = load i16, i16* %30, align 2, !dbg !561
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start(i16 %152, i16 %153, i16 %154), !dbg !562
  br label %178, !dbg !558

155:                                              ; preds = %146
  %156 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !563
  %157 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !563
  %158 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !563
  %159 = load i16, i16* %31, align 2, !dbg !564
  store i16 %159, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !565
  store i16 %156, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !565
  store i16 %157, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !565
  store i16 %158, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !565
  %160 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !566
  %161 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !566
  %162 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !566
  %163 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !566
  %164 = and i16 %162, -193, !dbg !566
  %165 = or i16 %164, 128, !dbg !566
  store volatile i16 %160, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !567
  store volatile i16 %161, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !567
  store volatile i16 %165, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !567
  store volatile i16 %163, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !567
  call void asm sideeffect "nop", ""(), !dbg !567
  call void asm sideeffect "nop", ""(), !dbg !567
  %166 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !568
  %167 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !568
  %168 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !568
  %169 = load i16, i16* %31, align 2, !dbg !569
  store i16 %169, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !570
  store i16 %166, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !570
  store i16 %167, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !570
  store i16 %168, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !570
  %170 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !571
  %171 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !571
  %172 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !571
  %173 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !571
  %174 = and i16 %172, -193, !dbg !571
  %175 = or i16 %174, 128, !dbg !571
  %176 = and i16 %171, -64, !dbg !571
  %177 = or i16 %176, 27, !dbg !571
  store volatile i16 %170, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !572
  store volatile i16 %177, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !572
  store volatile i16 %175, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !572
  store volatile i16 %173, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !572
  call void asm sideeffect "nop", ""(), !dbg !572
  call void asm sideeffect "nop", ""(), !dbg !572
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !573
  br label %178, !dbg !558

178:                                              ; preds = %151, %155
  br label %179, !dbg !511

179:                                              ; preds = %112, %178
  br label %180, !dbg !506

180:                                              ; preds = %108, %179
  ret void, !dbg !446
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit(i16 %0, i16 %1) !dbg !574 {
  %3 = alloca i16, i16 1, align 2, !dbg !576
  %4 = alloca i16, i16 1, align 2, !dbg !578
  %5 = alloca i16, i16 1, align 2, !dbg !579
  %6 = alloca i16, i16 1, align 2, !dbg !580
  %7 = alloca i16, i16 1, align 2, !dbg !581
  %8 = alloca i16, i16 1, align 2, !dbg !582
  store i16 %0, i16* %8, align 2, !dbg !582
  store i16 %1, i16* %7, align 2, !dbg !581
  %9 = load i16, i16* %7, align 2, !dbg !583
  %10 = icmp ult i16 %9, -32768, !dbg !584
  br i1 %10, label %11, label %12, !dbg !585

11:                                               ; preds = %2
  br label %13, !dbg !585

12:                                               ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !585
  br label %13, !dbg !585

13:                                               ; preds = %11, %12
  %14 = load i16, i16* %7, align 2, !dbg !586
  %15 = mul i16 %14, 2, !dbg !587
  store i16 %15, i16* %6, align 2, !dbg !580
  %16 = load i16, i16* %8, align 2, !dbg !588
  %17 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %16, i16 8), !dbg !589
  %18 = sub i16 %17, 1, !dbg !590
  store i16 %18, i16* %5, align 2, !dbg !579
  %19 = load i16, i16* %6, align 2, !dbg !591
  %20 = load i16, i16* %5, align 2, !dbg !592
  %21 = icmp ult i16 %19, %20, !dbg !593
  br i1 %21, label %22, label %23, !dbg !578

22:                                               ; preds = %13
  store i16 0, i16* %4, align 2, !dbg !578
  br label %27, !dbg !578

23:                                               ; preds = %13
  %24 = load i16, i16* %6, align 2, !dbg !594
  %25 = load i16, i16* %5, align 2, !dbg !595
  %26 = sub i16 %24, %25, !dbg !596
  store i16 %26, i16* %4, align 2, !dbg !578
  br label %27, !dbg !578

27:                                               ; preds = %22, %23
  %28 = load i16, i16* %4, align 2, !dbg !578
  store i16 %28, i16* %3, align 2, !dbg !576
  %29 = load i16, i16* %8, align 2, !dbg !597
  %30 = load i16, i16* %3, align 2, !dbg !598
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %29, i16 4, i16 %30), !dbg !599
  ret void, !dbg !578
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter(i16 %0, i16 %1) !dbg !600 {
  %3 = alloca i16, i16 1, align 2, !dbg !601
  %4 = alloca i16, i16 1, align 2, !dbg !603
  store i16 %0, i16* %4, align 2, !dbg !603
  store i16 %1, i16* %3, align 2, !dbg !601
  %5 = load i16, i16* %3, align 2, !dbg !604
  %6 = icmp ult i16 %5, -32768, !dbg !605
  br i1 %6, label %7, label %8, !dbg !606

7:                                                ; preds = %2
  br label %9, !dbg !606

8:                                                ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !606
  br label %9, !dbg !606

9:                                                ; preds = %7, %8
  %10 = load i16, i16* %4, align 2, !dbg !607
  %11 = load i16, i16* %3, align 2, !dbg !608
  %12 = mul i16 %11, 2, !dbg !609
  %13 = add i16 %12, 1, !dbg !610
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %10, i16 8, i16 %13), !dbg !611
  ret void, !dbg !612
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter(i16 %0, i16 %1) !dbg !613 {
  %3 = alloca i16, i16 1, align 2, !dbg !614
  %4 = alloca i16, i16 1, align 2, !dbg !616
  %5 = alloca i1, i16 1, align 1, !dbg !617
  %6 = alloca i16, i16 1, align 2, !dbg !618
  %7 = alloca i16, i16 1, align 2, !dbg !619
  %8 = alloca i16, i16 1, align 2, !dbg !620
  %9 = alloca i16, i16 1, align 2, !dbg !621
  store i16 %0, i16* %9, align 2, !dbg !621
  store i16 %1, i16* %8, align 2, !dbg !620
  %10 = load i16, i16* %8, align 2, !dbg !622
  %11 = icmp ult i16 %10, -32768, !dbg !623
  br i1 %11, label %12, label %13, !dbg !624

12:                                               ; preds = %2
  br label %14, !dbg !624

13:                                               ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !624
  br label %14, !dbg !624

14:                                               ; preds = %12, %13
  %15 = load i16, i16* %9, align 2, !dbg !625
  %16 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %15, i16 8), !dbg !626
  store i16 %16, i16* %7, align 2, !dbg !619
  %17 = load i16, i16* %8, align 2, !dbg !627
  %18 = mul i16 %17, 2, !dbg !628
  store i16 %18, i16* %6, align 2, !dbg !618
  %19 = load i16, i16* %6, align 2, !dbg !629
  %20 = load i16, i16* %7, align 2, !dbg !630
  %21 = icmp ugt i16 %19, %20, !dbg !631
  store i1 %21, i1* %5, align 1, !dbg !617
  %22 = load i16, i16* %9, align 2, !dbg !632
  %23 = load i1, i1* %5, align 1, !dbg !633
  %24 = zext i1 %23 to i16, !dbg !634
  %25 = shl i16 %24, 6, !dbg !635
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %22, i16 14, i16 %25), !dbg !636
  %26 = load i1, i1* %5, align 1, !dbg !637
  br i1 %26, label %27, label %32, !dbg !616

27:                                               ; preds = %14
  %28 = load i16, i16* %6, align 2, !dbg !638
  %29 = load i16, i16* %7, align 2, !dbg !639
  %30 = sub i16 %28, %29, !dbg !640
  %31 = add i16 %30, 1, !dbg !641
  store i16 %31, i16* %4, align 2, !dbg !616
  br label %34, !dbg !616

32:                                               ; preds = %14
  %33 = load i16, i16* %6, align 2, !dbg !642
  store i16 %33, i16* %4, align 2, !dbg !616
  br label %34, !dbg !616

34:                                               ; preds = %27, %32
  %35 = load i16, i16* %4, align 2, !dbg !616
  store i16 %35, i16* %3, align 2, !dbg !614
  %36 = load i16, i16* %9, align 2, !dbg !643
  %37 = load i16, i16* %3, align 2, !dbg !644
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %36, i16 12, i16 %37), !dbg !645
  ret void, !dbg !616
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %0, i16 %1, i16 %2) !dbg !646 {
  %4 = alloca i16, i16 1, align 2, !dbg !648
  %5 = alloca i16, i16 1, align 2, !dbg !650
  %6 = alloca i16, i16 1, align 2, !dbg !651
  store i16 %0, i16* %6, align 2, !dbg !651
  store i16 %1, i16* %5, align 2, !dbg !650
  store i16 %2, i16* %4, align 2, !dbg !648
  %7 = load i16, i16* %6, align 2, !dbg !652
  %8 = getelementptr [6 x i16], [6 x i16]* @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.filters, i16 0, i16 %7, !dbg !653
  %9 = load i16, i16* %8, align 2, !dbg !653
  %10 = load i16, i16* %5, align 2, !dbg !654
  %11 = add i16 %9, %10, !dbg !655
  %12 = lshr i16 %11, 1, !dbg !656
  %13 = load i16, i16* %4, align 2, !dbg !657
  %14 = shl i16 %12, 1, !dbg !658
  %15 = inttoptr i16 %14 to i16*, !dbg !658
  store volatile i16 %13, i16* %15, align 2, !dbg !658
  call void asm sideeffect "nop", ""(), !dbg !658
  call void asm sideeffect "nop", ""(), !dbg !658
  ret void, !dbg !659
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %0, i16 %1) !dbg !660 {
  %3 = alloca i16, i16 1, align 2, !dbg !661
  %4 = alloca i16, i16 1, align 2, !dbg !663
  store i16 %0, i16* %4, align 2, !dbg !663
  store i16 %1, i16* %3, align 2, !dbg !661
  %5 = load i16, i16* %4, align 2, !dbg !664
  %6 = getelementptr [6 x i16], [6 x i16]* @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.filters, i16 0, i16 %5, !dbg !665
  %7 = load i16, i16* %6, align 2, !dbg !665
  %8 = load i16, i16* %3, align 2, !dbg !666
  %9 = add i16 %7, %8, !dbg !667
  %10 = lshr i16 %9, 1, !dbg !668
  %11 = shl i16 %10, 1, !dbg !669
  %12 = inttoptr i16 %11 to i16*, !dbg !669
  call void asm sideeffect "nop", ""(), !dbg !669
  call void asm sideeffect "nop", ""(), !dbg !669
  %13 = load volatile i16, i16* %12, align 2, !dbg !669
  ret i16 %13, !dbg !670
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 %0) !dbg !671 {
  %2 = alloca i16, i16 1, align 2, !dbg !673
  %3 = alloca i16, i16 1, align 2, !dbg !675
  %4 = alloca i16, i16 1, align 2, !dbg !676
  %5 = alloca i16, i16 1, align 2, !dbg !677
  store i16 %0, i16* %5, align 2, !dbg !677
  %6 = load i16, i16* %5, align 2, !dbg !678
  store i16 %6, i16* %4, align 2, !dbg !676
  %7 = load i16, i16* %4, align 2, !dbg !679
  %8 = add i16 %7, 31744, !dbg !680
  store i16 %8, i16* %3, align 2, !dbg !675
  %9 = load i16, i16* %3, align 2, !dbg !681
  %10 = shl i16 %9, 1, !dbg !682
  %11 = inttoptr i16 %10 to i16*, !dbg !682
  call void asm sideeffect "nop", ""(), !dbg !682
  call void asm sideeffect "nop", ""(), !dbg !682
  %12 = load volatile i16, i16* %11, align 2, !dbg !682
  store i16 %12, i16* %2, align 2, !dbg !673
  %13 = load i16, i16* %3, align 2, !dbg !683
  %14 = load i16, i16* %2, align 2, !dbg !684
  %15 = and i16 %14, 32767, !dbg !685
  %16 = shl i16 %13, 1, !dbg !686
  %17 = inttoptr i16 %16 to i16*, !dbg !686
  store volatile i16 %15, i16* %17, align 2, !dbg !686
  call void asm sideeffect "nop", ""(), !dbg !686
  call void asm sideeffect "nop", ""(), !dbg !686
  ret void, !dbg !687
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord() !dbg !688 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 2), !dbg !690
  %2 = sub i16 %1, 4, !dbg !692
  ret i16 %2, !dbg !693
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord() !dbg !694 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 0), !dbg !695
  %2 = sub i16 %1, 1, !dbg !697
  ret i16 %2, !dbg !698
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 %0) !dbg !699 {
  %2 = alloca i16, i16 1, align 2, !dbg !701
  %3 = alloca i16, i16 1, align 2, !dbg !703
  store i16 %0, i16* %3, align 2, !dbg !703
  %4 = load i16, i16* %3, align 2, !dbg !704
  %5 = lshr i16 %4, 1, !dbg !705
  %6 = add i16 %5, 31813, !dbg !706
  %7 = shl i16 %6, 1, !dbg !707
  %8 = inttoptr i16 %7 to i16*, !dbg !707
  call void asm sideeffect "nop", ""(), !dbg !707
  call void asm sideeffect "nop", ""(), !dbg !707
  %9 = load volatile i16, i16* %8, align 2, !dbg !707
  store i16 %9, i16* %2, align 2, !dbg !701
  %10 = load i16, i16* %2, align 2, !dbg !708
  %11 = and i16 %10, 2047, !dbg !709
  ret i16 %11, !dbg !710
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord() !dbg !711 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord(), !dbg !713
  ret i16 %1, !dbg !715
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.get_y_coord() !dbg !716 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord(), !dbg !717
  ret i16 %1, !dbg !719
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval(i16 %0) !dbg !720 {
  %2 = alloca i16, i16 1, align 2, !dbg !721
  store i16 %0, i16* %2, align 2, !dbg !721
  %3 = load i16, i16* %2, align 2, !dbg !723
  %4 = icmp ult i16 %3, 24, !dbg !724
  br i1 %4, label %5, label %7, !dbg !725

5:                                                ; preds = %10, %11, %1
  %6 = phi i16 [ 0, %10 ], [ 0, %11 ], [ 1, %1 ]
  br label %12, !dbg !725

7:                                                ; preds = %1
  %8 = load i16, i16* %2, align 2, !dbg !726
  %9 = icmp eq i16 31, %8, !dbg !727
  br i1 %9, label %10, label %11, !dbg !728

10:                                               ; preds = %7
  br label %5, !dbg !728

11:                                               ; preds = %7
  call void asm sideeffect "hcf", ""(), !dbg !728
  br label %5, !dbg !728

12:                                               ; preds = %5
  %13 = phi i16 [ %6, %5 ]
  br label %14, !dbg !725

14:                                               ; preds = %12
  ret i16 %13, !dbg !725
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7) !dbg !729 {
  %9 = alloca i16, i16 1, align 2, !dbg !730
  %10 = alloca i16, i16 1, align 2, !dbg !732
  %11 = alloca i16, i16 1, align 2, !dbg !733
  %12 = alloca i16, i16 1, align 2, !dbg !734
  %13 = alloca i16, i16 1, align 2, !dbg !735
  %14 = alloca i16, i16 1, align 2, !dbg !736
  %15 = alloca i16, i16 1, align 2, !dbg !737
  %16 = alloca i16, i16 1, align 2, !dbg !738
  %17 = alloca i16, i16 1, align 2, !dbg !739
  store i16 %0, i16* %17, align 2, !dbg !739
  store i16 %1, i16* %16, align 2, !dbg !738
  store i16 %2, i16* %15, align 2, !dbg !737
  store i16 %3, i16* %14, align 2, !dbg !736
  store i16 %4, i16* %13, align 2, !dbg !735
  store i16 %5, i16* %12, align 2, !dbg !734
  store i16 %6, i16* %11, align 2, !dbg !733
  store i16 %7, i16* %10, align 2, !dbg !732
  %18 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !740
  store i16 %18, i16* %9, align 2, !dbg !730
  %19 = load i16, i16* %11, align 2, !dbg !741
  store i16 %19, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_c, align 2, !dbg !742
  %20 = load i16, i16* %10, align 2, !dbg !743
  store i16 %20, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_is_half, align 2, !dbg !744
  %21 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_c, align 2, !dbg !745
  %22 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval(i16 %21), !dbg !746
  store i16 %22, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !747
  store i16 0, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !748
  %23 = load i16, i16* %16, align 2, !dbg !749
  store i16 %23, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !750
  %24 = load i16, i16* %15, align 2, !dbg !751
  store i16 %24, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !752
  %25 = load i16, i16* %15, align 2, !dbg !753
  %26 = load i16, i16* %13, align 2, !dbg !754
  %27 = add i16 %25, %26, !dbg !755
  %28 = sub i16 %27, 1, !dbg !756
  store i16 %28, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_last, align 2, !dbg !757
  %29 = load i16, i16* %9, align 2, !dbg !758
  %30 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_last, align 2, !dbg !759
  %31 = icmp eq i16 %29, %30, !dbg !760
  br i1 %31, label %32, label %37, !dbg !761

32:                                               ; preds = %8
  %33 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !762
  %34 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !762
  %35 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !762
  store i16 %33, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !763
  store i16 lshr (i16 ptrtoint ([1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.ctrl_1 to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !763
  store i16 %34, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !763
  store i16 %35, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !763
  %36 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.ctrl_1, i16 0, i1 false), align 4, !dbg !764
  store i32 %36, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$13$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i1 false), align 4, !dbg !765
  br label %42, !dbg !761

37:                                               ; preds = %8
  %38 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !766
  %39 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !766
  %40 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !766
  store i16 %38, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !767
  store i16 lshr (i16 ptrtoint ([1 x i32]* @"$$csl_base_address$$9$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11" to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !767
  store i16 %39, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !767
  store i16 %40, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !767
  %41 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @"$$csl_base_address$$9$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11", i16 0, i1 false), align 4, !dbg !768
  store i32 %41, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$13$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i1 false), align 4, !dbg !769
  br label %42, !dbg !761

42:                                               ; preds = %32, %37
  store i32 165646921, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$13$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i2 1), align 4, !dbg !770
  %43 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !771
  %44 = icmp eq i16 0, %43, !dbg !772
  br i1 %44, label %45, label %56, !dbg !773

45:                                               ; preds = %42
  %46 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !774
  %47 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !774
  %48 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !774
  %49 = load i16, i16* %17, align 2, !dbg !775
  %50 = call i16* @.get_tensor_ptr(i16 %49), !dbg !776
  %51 = ptrtoint i16* %50 to i16, !dbg !777
  %52 = lshr i16 %51, 1, !dbg !777
  store i16 %46, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !778
  store i16 %52, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !778
  store i16 %47, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !778
  store i16 %48, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !778
  %53 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !779
  %54 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !779
  %55 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !779
  store i16 1, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !780
  store i16 %53, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !780
  store i16 %54, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !780
  store i16 %55, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !780
  call void @llvm.sdr.actvt.r(i16 21), !dbg !781
  br label %63, !dbg !773

56:                                               ; preds = %42
  %57 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !782
  %58 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !782
  %59 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !782
  store i16 %57, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !783
  store i16 lshr (i16 ptrtoint ([1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.data_buf to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !783
  store i16 %58, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !783
  store i16 %59, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !783
  %60 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !784
  %61 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !784
  %62 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !784
  store i16 1, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !785
  store i16 %60, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !785
  store i16 %61, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !785
  store i16 %62, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !785
  call void @llvm.sdr.ublk.r(i16 0), !dbg !786
  br label %63, !dbg !773

63:                                               ; preds = %45, %56
  ret void, !dbg !761
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x(i32 %0) #8 !dbg !787 {
  %2 = alloca i32, i16 1, align 4, !dbg !788
  store i32 %0, i32* %2, align 4, !dbg !788
  call void @llvm.sdr.blk.r(i16 0), !dbg !790
  %3 = load i32, i32* %2, align 4, !dbg !791
  store i32 %3, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.data_buf, i16 0, i1 false), align 4, !dbg !792
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__13 to i8*)), !dbg !793
  %4 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !794
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !794
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !794
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !794
  store volatile i16 %4, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !795
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !795
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !795
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !795
  call void asm sideeffect "nop", ""(), !dbg !795
  call void asm sideeffect "nop", ""(), !dbg !795
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !796
  %8 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !797
  %9 = add i16 %8, 1, !dbg !798
  store i16 %9, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !799
  ret void, !dbg !800
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_send_data() #9 !dbg !801 {
  %1 = alloca i16, i16 1, align 2, !dbg !802
  %2 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !804
  %3 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !805
  %4 = icmp ult i16 %2, %3, !dbg !806
  br i1 %4, label %5, label %27, !dbg !807

5:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__13 to i8*)), !dbg !808
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !809
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !809
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !809
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !809
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !810
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !810
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !810
  store volatile i16 %9, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !810
  call void asm sideeffect "nop", ""(), !dbg !810
  call void asm sideeffect "nop", ""(), !dbg !810
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_is_half, align 2, !dbg !811
  %11 = icmp ult i16 0, %10, !dbg !812
  br i1 %11, label %12, label %18, !dbg !813

12:                                               ; preds = %5
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !814
  %13 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !815
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !815
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !815
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !815
  %17 = add i16 %14, 1, !dbg !816
  store i16 %13, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !817
  store i16 %17, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !817
  store i16 %15, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !817
  store i16 %16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !817
  br label %24, !dbg !813

18:                                               ; preds = %5
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !818
  %19 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !819
  %20 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !819
  %21 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !819
  %22 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !819
  %23 = add i16 %20, 2, !dbg !820
  store i16 %19, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !821
  store i16 %23, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !821
  store i16 %21, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !821
  store i16 %22, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !821
  br label %24, !dbg !813

24:                                               ; preds = %12, %18
  %25 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !822
  %26 = add i16 %25, 1, !dbg !823
  store i16 %26, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !824
  br label %34, !dbg !807

27:                                               ; preds = %0
  %28 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !825
  store i16 %28, i16* %1, align 2, !dbg !802
  %29 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !826
  %30 = load i16, i16* %1, align 2, !dbg !827
  %31 = icmp eq i16 %29, %30, !dbg !828
  br i1 %31, label %32, label %33, !dbg !829

32:                                               ; preds = %27
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__14 to i8*)), !dbg !830
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__15 to i8*)), !dbg !831
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !832
  br label %33, !dbg !829

33:                                               ; preds = %32, %27
  br label %34, !dbg !807

34:                                               ; preds = %24, %33
  ret void, !dbg !807
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl() #10 !dbg !833 {
  %1 = alloca i16, i16 1, align 2, !dbg !834
  %2 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !836
  %3 = icmp eq i16 0, %2, !dbg !837
  br i1 %3, label %4, label %9, !dbg !838

4:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__16 to i8*)), !dbg !839
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !840
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !840
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !840
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !840
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !841
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !841
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !841
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !841
  call void asm sideeffect "nop", ""(), !dbg !841
  call void asm sideeffect "nop", ""(), !dbg !841
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !842
  br label %31, !dbg !838

9:                                                ; preds = %0
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !843
  %11 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !844
  %12 = icmp ult i16 %10, %11, !dbg !845
  br i1 %12, label %13, label %18, !dbg !846

13:                                               ; preds = %9
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__17 to i8*)), !dbg !847
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !848
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !848
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !848
  %17 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !848
  store volatile i16 %14, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !849
  store volatile i16 %15, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !849
  store volatile i16 %16, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !849
  store volatile i16 %17, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !849
  call void asm sideeffect "nop", ""(), !dbg !849
  call void asm sideeffect "nop", ""(), !dbg !849
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !850
  br label %30, !dbg !846

18:                                               ; preds = %9
  %19 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !851
  store i16 %19, i16* %1, align 2, !dbg !834
  %20 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !852
  %21 = load i16, i16* %1, align 2, !dbg !853
  %22 = icmp eq i16 %20, %21, !dbg !854
  br i1 %22, label %23, label %24, !dbg !855

23:                                               ; preds = %18
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__18 to i8*)), !dbg !856
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__19 to i8*)), !dbg !857
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !858
  br label %29, !dbg !855

24:                                               ; preds = %18
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__14 to i8*)), !dbg !859
  %25 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !860
  %26 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !860
  %27 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !860
  %28 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !860
  store volatile i16 %25, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !861
  store volatile i16 %26, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !861
  store volatile i16 %27, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !861
  store volatile i16 %28, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !861
  call void asm sideeffect "nop", ""(), !dbg !861
  call void asm sideeffect "nop", ""(), !dbg !861
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !862
  br label %29, !dbg !855

29:                                               ; preds = %23, %24
  br label %30, !dbg !846

30:                                               ; preds = %13, %29
  br label %31, !dbg !838

31:                                               ; preds = %4, %30
  ret void, !dbg !838
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.d2h_configure(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7) !dbg !863 {
  %9 = alloca i1, i16 1, align 1, !dbg !864
  %10 = alloca i1, i16 1, align 1, !dbg !866
  %11 = alloca i1, i16 1, align 1, !dbg !867
  %12 = alloca i16, i16 1, align 2, !dbg !868
  %13 = alloca i16, i16 1, align 2, !dbg !869
  %14 = alloca i16, i16 1, align 2, !dbg !870
  %15 = alloca i16, i16 1, align 2, !dbg !871
  %16 = alloca i16, i16 1, align 2, !dbg !872
  %17 = alloca i16, i16 1, align 2, !dbg !873
  %18 = alloca i16, i16 1, align 2, !dbg !874
  %19 = alloca i16, i16 1, align 2, !dbg !875
  %20 = alloca i16, i16 1, align 2, !dbg !876
  %21 = alloca i16, i16 1, align 2, !dbg !877
  %22 = alloca i16, i16 1, align 2, !dbg !878
  %23 = alloca i16, i16 1, align 2, !dbg !879
  %24 = alloca i16, i16 1, align 2, !dbg !880
  %25 = alloca i16, i16 1, align 2, !dbg !881
  store i16 %0, i16* %25, align 2, !dbg !881
  store i16 %1, i16* %24, align 2, !dbg !880
  store i16 %2, i16* %23, align 2, !dbg !879
  store i16 %3, i16* %22, align 2, !dbg !878
  store i16 %4, i16* %21, align 2, !dbg !877
  store i16 %5, i16* %20, align 2, !dbg !876
  store i16 %6, i16* %19, align 2, !dbg !875
  store i16 %7, i16* %18, align 2, !dbg !874
  %26 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !882
  store i16 %26, i16* %17, align 2, !dbg !873
  %27 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_y_coord(), !dbg !883
  store i16 %27, i16* %16, align 2, !dbg !872
  %28 = load i16, i16* %24, align 2, !dbg !884
  store i16 %28, i16* %15, align 2, !dbg !871
  %29 = load i16, i16* %24, align 2, !dbg !885
  %30 = load i16, i16* %22, align 2, !dbg !886
  %31 = add i16 %29, %30, !dbg !887
  %32 = sub i16 %31, 1, !dbg !888
  store i16 %32, i16* %14, align 2, !dbg !870
  %33 = load i16, i16* %23, align 2, !dbg !889
  store i16 %33, i16* %13, align 2, !dbg !869
  %34 = load i16, i16* %23, align 2, !dbg !890
  %35 = load i16, i16* %21, align 2, !dbg !891
  %36 = add i16 %34, %35, !dbg !892
  %37 = sub i16 %36, 1, !dbg !893
  store i16 %37, i16* %12, align 2, !dbg !868
  store i1 false, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !894
  %38 = load i16, i16* %17, align 2, !dbg !895
  %39 = load i16, i16* %15, align 2, !dbg !896
  %40 = icmp sge i16 %38, %39, !dbg !897
  br i1 %40, label %41, label %45, !dbg !867

41:                                               ; preds = %8
  %42 = load i16, i16* %16, align 2, !dbg !898
  %43 = load i16, i16* %12, align 2, !dbg !899
  %44 = icmp sle i16 %42, %43, !dbg !900
  store i1 %44, i1* %11, align 1, !dbg !867
  br label %46, !dbg !867

45:                                               ; preds = %8
  store i1 false, i1* %11, align 1, !dbg !867
  br label %46, !dbg !867

46:                                               ; preds = %41, %45
  %47 = load i1, i1* %11, align 1, !dbg !867
  br i1 %47, label %48, label %52, !dbg !866

48:                                               ; preds = %46
  %49 = load i16, i16* %16, align 2, !dbg !901
  %50 = load i16, i16* %13, align 2, !dbg !902
  %51 = icmp sge i16 %49, %50, !dbg !903
  store i1 %51, i1* %10, align 1, !dbg !866
  br label %53, !dbg !866

52:                                               ; preds = %46
  store i1 false, i1* %10, align 1, !dbg !866
  br label %53, !dbg !866

53:                                               ; preds = %48, %52
  %54 = load i1, i1* %10, align 1, !dbg !866
  br i1 %54, label %55, label %56, !dbg !904

55:                                               ; preds = %53
  store i1 true, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !905
  br label %56, !dbg !904

56:                                               ; preds = %55, %53
  store i1 false, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !906
  %57 = load i16, i16* %17, align 2, !dbg !907
  %58 = load i16, i16* %14, align 2, !dbg !908
  %59 = icmp sle i16 %57, %58, !dbg !909
  br i1 %59, label %60, label %62, !dbg !864

60:                                               ; preds = %56
  %61 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !910
  store i1 %61, i1* %9, align 1, !dbg !864
  br label %63, !dbg !864

62:                                               ; preds = %56
  store i1 false, i1* %9, align 1, !dbg !864
  br label %63, !dbg !864

63:                                               ; preds = %60, %62
  %64 = load i1, i1* %9, align 1, !dbg !864
  br i1 %64, label %65, label %66, !dbg !911

65:                                               ; preds = %63
  store i1 true, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !912
  br label %66, !dbg !911

66:                                               ; preds = %65, %63
  %67 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !913
  br i1 %67, label %68, label %86, !dbg !914

68:                                               ; preds = %66
  call void @__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position(i16 31959), !dbg !915
  %69 = load i16, i16* %15, align 2, !dbg !916
  %70 = load i16, i16* %17, align 2, !dbg !917
  %71 = icmp eq i16 %69, %70, !dbg !918
  br i1 %71, label %72, label %73, !dbg !919

72:                                               ; preds = %68
  call void @__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 31765), !dbg !920
  br label %74, !dbg !919

73:                                               ; preds = %68
  call void @__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 31765), !dbg !921
  br label %74, !dbg !919

74:                                               ; preds = %72, %73
  call void @sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit(i16 21), !dbg !922
  %75 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !923
  br i1 %75, label %76, label %85, !dbg !924

76:                                               ; preds = %74
  %77 = load i16, i16* %20, align 2, !dbg !925
  %78 = load i16, i16* %19, align 2, !dbg !926
  %79 = load i16, i16* %24, align 2, !dbg !927
  %80 = load i16, i16* %23, align 2, !dbg !928
  %81 = load i16, i16* %22, align 2, !dbg !929
  %82 = load i16, i16* %21, align 2, !dbg !930
  %83 = load i16, i16* %25, align 2, !dbg !931
  %84 = load i16, i16* %18, align 2, !dbg !932
  call void @sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start(i16 %77, i16 %78, i16 %79, i16 %80, i16 %81, i16 %82, i16 %83, i16 %84), !dbg !933
  br label %85, !dbg !924

85:                                               ; preds = %76, %74
  br label %87, !dbg !914

86:                                               ; preds = %66
  call void @llvm.sdr.actvt.r(i16 28), !dbg !934
  br label %87, !dbg !914

87:                                               ; preds = %85, %86
  ret void, !dbg !867
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit(i16 %0) !dbg !935 {
  %2 = alloca i16, i16 1, align 2, !dbg !936
  %3 = alloca i16, i16 1, align 2, !dbg !938
  %4 = alloca i16, i16 1, align 2, !dbg !939
  %5 = alloca i16, i16 1, align 2, !dbg !940
  store i16 %0, i16* %5, align 2, !dbg !940
  %6 = load i16, i16* %5, align 2, !dbg !941
  store i16 %6, i16* %4, align 2, !dbg !939
  %7 = load i16, i16* %4, align 2, !dbg !942
  %8 = add i16 %7, 31744, !dbg !943
  store i16 %8, i16* %3, align 2, !dbg !938
  %9 = load i16, i16* %3, align 2, !dbg !944
  %10 = shl i16 %9, 1, !dbg !945
  %11 = inttoptr i16 %10 to i16*, !dbg !945
  call void asm sideeffect "nop", ""(), !dbg !945
  call void asm sideeffect "nop", ""(), !dbg !945
  %12 = load volatile i16, i16* %11, align 2, !dbg !945
  store i16 %12, i16* %2, align 2, !dbg !936
  %13 = load i16, i16* %3, align 2, !dbg !946
  %14 = load i16, i16* %2, align 2, !dbg !947
  %15 = and i16 %14, 32767, !dbg !948
  %16 = shl i16 %13, 1, !dbg !949
  %17 = inttoptr i16 %16 to i16*, !dbg !949
  store volatile i16 %15, i16* %17, align 2, !dbg !949
  call void asm sideeffect "nop", ""(), !dbg !949
  call void asm sideeffect "nop", ""(), !dbg !949
  ret void, !dbg !950
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord() !dbg !951 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 2), !dbg !952
  %2 = sub i16 %1, 4, !dbg !954
  ret i16 %2, !dbg !955
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord() !dbg !956 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 0), !dbg !957
  %2 = sub i16 %1, 1, !dbg !959
  ret i16 %2, !dbg !960
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 %0) !dbg !961 {
  %2 = alloca i16, i16 1, align 2, !dbg !962
  %3 = alloca i16, i16 1, align 2, !dbg !964
  store i16 %0, i16* %3, align 2, !dbg !964
  %4 = load i16, i16* %3, align 2, !dbg !965
  %5 = lshr i16 %4, 1, !dbg !966
  %6 = add i16 %5, 31813, !dbg !967
  %7 = shl i16 %6, 1, !dbg !968
  %8 = inttoptr i16 %7 to i16*, !dbg !968
  call void asm sideeffect "nop", ""(), !dbg !968
  call void asm sideeffect "nop", ""(), !dbg !968
  %9 = load volatile i16, i16* %8, align 2, !dbg !968
  store i16 %9, i16* %2, align 2, !dbg !962
  %10 = load i16, i16* %2, align 2, !dbg !969
  %11 = and i16 %10, 2047, !dbg !970
  ret i16 %11, !dbg !971
}

define internal i16 @sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr(i16 %0) !dbg !972 {
  %2 = alloca i16, i16 1, align 2, !dbg !974
  store i16 %0, i16* %2, align 2, !dbg !974
  %3 = load i16, i16* %2, align 2, !dbg !976
  %4 = mul i16 %3, 2, !dbg !977
  %5 = add i16 %4, 31680, !dbg !978
  ret i16 %5, !dbg !979
}

define internal void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 %0, i16 %1, i1 %2) !dbg !980 {
  %4 = alloca i16, i16 1, align 2, !dbg !981
  %5 = alloca i16, i16 1, align 2, !dbg !983
  %6 = alloca i1, i16 1, align 1, !dbg !984
  %7 = alloca i16, i16 1, align 2, !dbg !985
  %8 = alloca i16, i16 1, align 2, !dbg !986
  store i16 %0, i16* %8, align 2, !dbg !986
  store i16 %1, i16* %7, align 2, !dbg !985
  store i1 %2, i1* %6, align 1, !dbg !984
  %9 = load i16, i16* %8, align 2, !dbg !987
  %10 = call i16 @sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr(i16 %9), !dbg !988
  store i16 %10, i16* %5, align 2, !dbg !983
  %11 = load i16, i16* %5, align 2, !dbg !989
  %12 = shl i16 %11, 1, !dbg !990
  %13 = inttoptr i16 %12 to i16*, !dbg !990
  call void asm sideeffect "nop", ""(), !dbg !990
  call void asm sideeffect "nop", ""(), !dbg !990
  call void asm sideeffect "nop", ""(), !dbg !990
  call void asm sideeffect "nop", ""(), !dbg !990
  %14 = load volatile i16, i16* %13, align 2, !dbg !990
  store i16 %14, i16* %4, align 2, !dbg !981
  %15 = load i1, i1* %6, align 1, !dbg !991
  br i1 %15, label %16, label %19, !dbg !992

16:                                               ; preds = %3
  %17 = load i16, i16* %4, align 2, !dbg !993
  %18 = or i16 %17, 2048, !dbg !994
  store i16 %18, i16* %4, align 2, !dbg !995
  br label %22, !dbg !992

19:                                               ; preds = %3
  %20 = load i16, i16* %4, align 2, !dbg !996
  %21 = and i16 %20, -2049, !dbg !997
  store i16 %21, i16* %4, align 2, !dbg !998
  br label %22, !dbg !992

22:                                               ; preds = %16, %19
  %23 = load i16, i16* %4, align 2, !dbg !999
  %24 = and i16 %23, -32, !dbg !1000
  store i16 %24, i16* %4, align 2, !dbg !1001
  %25 = load i16, i16* %4, align 2, !dbg !1002
  %26 = load i16, i16* %7, align 2, !dbg !1003
  %27 = add i16 %25, %26, !dbg !1004
  store i16 %27, i16* %4, align 2, !dbg !1005
  %28 = load i16, i16* %5, align 2, !dbg !1006
  %29 = load i16, i16* %4, align 2, !dbg !1007
  %30 = shl i16 %28, 1, !dbg !1008
  %31 = inttoptr i16 %30 to i16*, !dbg !1008
  store volatile i16 %29, i16* %31, align 2, !dbg !1008
  call void asm sideeffect "nop", ""(), !dbg !1008
  call void asm sideeffect "nop", ""(), !dbg !1008
  call void asm sideeffect "nop", ""(), !dbg !1008
  call void asm sideeffect "nop", ""(), !dbg !1008
  ret void, !dbg !992
}

define internal i16 @sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr(i16 %0) !dbg !1009 {
  %2 = alloca i16, i16 1, align 2, !dbg !1011
  store i16 %0, i16* %2, align 2, !dbg !1011
  %3 = load i16, i16* %2, align 2, !dbg !1013
  %4 = add i16 %3, 31616, !dbg !1014
  ret i16 %4, !dbg !1015
}

define internal void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 %0, i16 %1) !dbg !1016 {
  %3 = alloca i16, i16 1, align 2, !dbg !1017
  %4 = alloca i16, i16 1, align 2, !dbg !1019
  %5 = alloca i16, i16 1, align 2, !dbg !1020
  %6 = alloca i16, i16 1, align 2, !dbg !1021
  store i16 %0, i16* %6, align 2, !dbg !1021
  store i16 %1, i16* %5, align 2, !dbg !1020
  %7 = load i16, i16* %6, align 2, !dbg !1022
  %8 = call i16 @sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr(i16 %7), !dbg !1023
  store i16 %8, i16* %4, align 2, !dbg !1019
  %9 = load i16, i16* %4, align 2, !dbg !1024
  %10 = shl i16 %9, 1, !dbg !1025
  %11 = inttoptr i16 %10 to i16*, !dbg !1025
  call void asm sideeffect "nop", ""(), !dbg !1025
  call void asm sideeffect "nop", ""(), !dbg !1025
  call void asm sideeffect "nop", ""(), !dbg !1025
  call void asm sideeffect "nop", ""(), !dbg !1025
  %12 = load volatile i16, i16* %11, align 2, !dbg !1025
  store i16 %12, i16* %3, align 2, !dbg !1017
  %13 = load i16, i16* %3, align 2, !dbg !1026
  %14 = and i16 %13, -497, !dbg !1027
  store i16 %14, i16* %3, align 2, !dbg !1028
  %15 = load i16, i16* %3, align 2, !dbg !1029
  %16 = load i16, i16* %5, align 2, !dbg !1030
  %17 = add i16 %15, %16, !dbg !1031
  %18 = shl i16 %17, 4, !dbg !1032
  store i16 %18, i16* %3, align 2, !dbg !1033
  %19 = load i16, i16* %4, align 2, !dbg !1034
  %20 = load i16, i16* %3, align 2, !dbg !1035
  %21 = shl i16 %19, 1, !dbg !1036
  %22 = inttoptr i16 %21 to i16*, !dbg !1036
  store volatile i16 %20, i16* %22, align 2, !dbg !1036
  call void asm sideeffect "nop", ""(), !dbg !1036
  call void asm sideeffect "nop", ""(), !dbg !1036
  call void asm sideeffect "nop", ""(), !dbg !1036
  call void asm sideeffect "nop", ""(), !dbg !1036
  ret void, !dbg !1037
}

define internal i16* @.get_tensor_ptr(i16 %0) !dbg !1038 {
  %2 = alloca i16, i16 1, align 2, !dbg !1039
  store i16 %0, i16* %2, align 2, !dbg !1039
  %3 = load i16, i16* %2, align 2, !dbg !1039
  %4 = zext i16 %3 to i32, !dbg !1039
  switch i32 %4, label %5 [
    i32 1, label %9
    i32 2, label %11
    i32 3, label %13
    i32 4, label %15
    i32 5, label %18
    i32 6, label %21
    i32 7, label %24
    i32 8, label %27
    i32 9, label %30
    i32 10, label %33
    i32 11, label %36
    i32 12, label %39
    i32 13, label %42
    i32 14, label %44
    i32 15, label %46
    i32 16, label %48
  ], !dbg !1039

5:                                                ; preds = %1
  br i1 false, label %6, label %7, !dbg !1039

6:                                                ; preds = %5
  br label %8, !dbg !1039

7:                                                ; preds = %5
  call void asm sideeffect "hcf", ""(), !dbg !1039
  br label %8, !dbg !1039

8:                                                ; preds = %6, %7
  br label %50, !dbg !1039

9:                                                ; preds = %1
  %10 = load i16*, i16** @ptr_ai, align 8, !dbg !1039
  br label %50, !dbg !1039

11:                                               ; preds = %1
  %12 = load i16*, i16** @ptr_bi, align 8, !dbg !1039
  br label %50, !dbg !1039

13:                                               ; preds = %1
  %14 = load i16*, i16** @ptr_ci, align 8, !dbg !1039
  br label %50, !dbg !1039

15:                                               ; preds = %1
  %16 = load half*, half** @ptr_af, align 8, !dbg !1039
  %17 = bitcast half* %16 to i16*, !dbg !1039
  br label %50, !dbg !1039

18:                                               ; preds = %1
  %19 = load half*, half** @ptr_bf, align 8, !dbg !1039
  %20 = bitcast half* %19 to i16*, !dbg !1039
  br label %50, !dbg !1039

21:                                               ; preds = %1
  %22 = load half*, half** @ptr_cf, align 8, !dbg !1039
  %23 = bitcast half* %22 to i16*, !dbg !1039
  br label %50, !dbg !1039

24:                                               ; preds = %1
  %25 = load half*, half** @ptr_a, align 8, !dbg !1039
  %26 = bitcast half* %25 to i16*, !dbg !1039
  br label %50, !dbg !1039

27:                                               ; preds = %1
  %28 = load half*, half** @ptr_b, align 8, !dbg !1039
  %29 = bitcast half* %28 to i16*, !dbg !1039
  br label %50, !dbg !1039

30:                                               ; preds = %1
  %31 = load half*, half** @ptr_c, align 8, !dbg !1039
  %32 = bitcast half* %31 to i16*, !dbg !1039
  br label %50, !dbg !1039

33:                                               ; preds = %1
  %34 = load float*, float** @ptr_a32, align 8, !dbg !1039
  %35 = bitcast float* %34 to i16*, !dbg !1039
  br label %50, !dbg !1039

36:                                               ; preds = %1
  %37 = load float*, float** @ptr_b32, align 8, !dbg !1039
  %38 = bitcast float* %37 to i16*, !dbg !1039
  br label %50, !dbg !1039

39:                                               ; preds = %1
  %40 = load float*, float** @ptr_c32, align 8, !dbg !1039
  %41 = bitcast float* %40 to i16*, !dbg !1039
  br label %50, !dbg !1039

42:                                               ; preds = %1
  %43 = load i16*, i16** @ptr_ia8, align 8, !dbg !1039
  br label %50, !dbg !1039

44:                                               ; preds = %1
  %45 = load i16*, i16** @ptr_ib8, align 8, !dbg !1039
  br label %50, !dbg !1039

46:                                               ; preds = %1
  %47 = load i16*, i16** @ptr_ic8, align 8, !dbg !1039
  br label %50, !dbg !1039

48:                                               ; preds = %1
  %49 = load i16*, i16** @ptr_mark, align 8, !dbg !1039
  br label %50, !dbg !1039

50:                                               ; preds = %8, %9, %11, %13, %15, %18, %21, %24, %27, %30, %33, %36, %39, %42, %44, %46, %48
  %51 = phi i16 [ -2, %48 ], [ -2, %46 ], [ -2, %44 ], [ -2, %42 ], [ -2, %39 ], [ -2, %36 ], [ -2, %33 ], [ -2, %30 ], [ -2, %27 ], [ -2, %24 ], [ -2, %21 ], [ -2, %18 ], [ -2, %15 ], [ -2, %13 ], [ -2, %11 ], [ -2, %9 ], [ 0, %8 ]
  %52 = phi i16* [ %49, %48 ], [ %47, %46 ], [ %45, %44 ], [ %43, %42 ], [ %41, %39 ], [ %38, %36 ], [ %35, %33 ], [ %32, %30 ], [ %29, %27 ], [ %26, %24 ], [ %23, %21 ], [ %20, %18 ], [ %17, %15 ], [ %14, %13 ], [ %12, %11 ], [ %10, %9 ], [ undef, %8 ]
  br label %53, !dbg !1039

53:                                               ; preds = %50
  %54 = icmp ne i16 %51, 0, !dbg !1039
  br i1 %54, label %55, label %56, !dbg !1039

55:                                               ; preds = %53
  br label %58, !dbg !1039

56:                                               ; preds = %53
  %57 = load i16*, i16** @ptr_mark, align 8, !dbg !1039
  br label %58, !dbg !1039

58:                                               ; preds = %55, %56
  %59 = phi i16* [ %57, %56 ], [ %52, %55 ]
  br label %60, !dbg !1039

60:                                               ; preds = %58
  ret i16* %59, !dbg !1039
}

define internal void @__generic0sys_mod.sys_mod.tile_config.queue_flush.exit() !dbg !1041 {
  store volatile i16 1, i16* inttoptr (i16 -2268 to i16*), align 2, !dbg !1043
  call void asm sideeffect "nop", ""(), !dbg !1043
  call void asm sideeffect "nop", ""(), !dbg !1043
  ret void, !dbg !1045
}

define internal void @__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position(i16 %0) !dbg !1046 {
  %2 = alloca i16, i16 1, align 2, !dbg !1048
  %3 = alloca i16, i16 1, align 2, !dbg !1050
  %4 = alloca i16, i16 1, align 2, !dbg !1051
  store i16 %0, i16* %4, align 2, !dbg !1051
  %5 = load i16, i16* %4, align 2, !dbg !1052
  store i16 %5, i16* %3, align 2, !dbg !1050
  %6 = load i16, i16* %3, align 2, !dbg !1053
  %7 = shl i16 %6, 1, !dbg !1054
  %8 = inttoptr i16 %7 to i16*, !dbg !1054
  call void asm sideeffect "nop", ""(), !dbg !1054
  call void asm sideeffect "nop", ""(), !dbg !1054
  call void asm sideeffect "nop", ""(), !dbg !1054
  call void asm sideeffect "nop", ""(), !dbg !1054
  %9 = load volatile i16, i16* %8, align 2, !dbg !1054
  store i16 %9, i16* %2, align 2, !dbg !1048
  %10 = load i16, i16* %2, align 2, !dbg !1055
  %11 = and i16 %10, -16, !dbg !1056
  store i16 %11, i16* %2, align 2, !dbg !1056
  %12 = load i16, i16* %3, align 2, !dbg !1057
  %13 = load i16, i16* %2, align 2, !dbg !1058
  %14 = shl i16 %12, 1, !dbg !1059
  %15 = inttoptr i16 %14 to i16*, !dbg !1059
  store volatile i16 %13, i16* %15, align 2, !dbg !1059
  call void asm sideeffect "nop", ""(), !dbg !1059
  call void asm sideeffect "nop", ""(), !dbg !1059
  call void asm sideeffect "nop", ""(), !dbg !1059
  call void asm sideeffect "nop", ""(), !dbg !1059
  ret void, !dbg !1060
}

define internal void @__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 %0) !dbg !1061 {
  %2 = alloca i16, i16 1, align 2, !dbg !1063
  %3 = alloca i16, i16 1, align 2, !dbg !1065
  %4 = alloca i16, i16 1, align 2, !dbg !1066
  store i16 %0, i16* %4, align 2, !dbg !1066
  %5 = load i16, i16* %4, align 2, !dbg !1067
  store i16 %5, i16* %3, align 2, !dbg !1065
  %6 = load i16, i16* %3, align 2, !dbg !1068
  %7 = shl i16 %6, 1, !dbg !1069
  %8 = inttoptr i16 %7 to i16*, !dbg !1069
  call void asm sideeffect "nop", ""(), !dbg !1069
  call void asm sideeffect "nop", ""(), !dbg !1069
  %9 = load volatile i16, i16* %8, align 2, !dbg !1069
  store i16 %9, i16* %2, align 2, !dbg !1063
  %10 = load i16, i16* %2, align 2, !dbg !1070
  %11 = and i16 %10, -256, !dbg !1071
  store i16 %11, i16* %2, align 2, !dbg !1072
  %12 = load i16, i16* %2, align 2, !dbg !1073
  %13 = load i16, i16* %2, align 2, !dbg !1074
  %14 = call i16 @__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %13), !dbg !1075
  %15 = or i16 %12, %14, !dbg !1076
  store i16 %15, i16* %2, align 2, !dbg !1076
  %16 = load i16, i16* %2, align 2, !dbg !1077
  %17 = load i16, i16* %2, align 2, !dbg !1078
  %18 = call i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %17), !dbg !1079
  %19 = or i16 %16, %18, !dbg !1080
  store i16 %19, i16* %2, align 2, !dbg !1080
  %20 = load i16, i16* %3, align 2, !dbg !1081
  %21 = load i16, i16* %2, align 2, !dbg !1082
  %22 = shl i16 %20, 1, !dbg !1083
  %23 = inttoptr i16 %22 to i16*, !dbg !1083
  store volatile i16 %21, i16* %23, align 2, !dbg !1083
  call void asm sideeffect "nop", ""(), !dbg !1083
  call void asm sideeffect "nop", ""(), !dbg !1083
  ret void, !dbg !1084
}

define internal void @__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 %0) !dbg !1085 {
  %2 = alloca i16, i16 1, align 2, !dbg !1086
  %3 = alloca i16, i16 1, align 2, !dbg !1088
  %4 = alloca i16, i16 1, align 2, !dbg !1089
  store i16 %0, i16* %4, align 2, !dbg !1089
  %5 = load i16, i16* %4, align 2, !dbg !1090
  store i16 %5, i16* %3, align 2, !dbg !1088
  %6 = load i16, i16* %3, align 2, !dbg !1091
  %7 = shl i16 %6, 1, !dbg !1092
  %8 = inttoptr i16 %7 to i16*, !dbg !1092
  call void asm sideeffect "nop", ""(), !dbg !1092
  call void asm sideeffect "nop", ""(), !dbg !1092
  %9 = load volatile i16, i16* %8, align 2, !dbg !1092
  store i16 %9, i16* %2, align 2, !dbg !1086
  %10 = load i16, i16* %2, align 2, !dbg !1093
  %11 = and i16 %10, -256, !dbg !1094
  store i16 %11, i16* %2, align 2, !dbg !1095
  %12 = load i16, i16* %2, align 2, !dbg !1096
  %13 = load i16, i16* %2, align 2, !dbg !1097
  %14 = call i16 @__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %13), !dbg !1098
  %15 = or i16 %12, %14, !dbg !1099
  store i16 %15, i16* %2, align 2, !dbg !1099
  %16 = load i16, i16* %2, align 2, !dbg !1100
  %17 = load i16, i16* %2, align 2, !dbg !1101
  %18 = call i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %17), !dbg !1102
  %19 = or i16 %16, %18, !dbg !1103
  store i16 %19, i16* %2, align 2, !dbg !1103
  %20 = load i16, i16* %3, align 2, !dbg !1104
  %21 = load i16, i16* %2, align 2, !dbg !1105
  %22 = shl i16 %20, 1, !dbg !1106
  %23 = inttoptr i16 %22 to i16*, !dbg !1106
  store volatile i16 %21, i16* %23, align 2, !dbg !1106
  call void asm sideeffect "nop", ""(), !dbg !1106
  call void asm sideeffect "nop", ""(), !dbg !1106
  ret void, !dbg !1107
}

define internal i16 @__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %0) !dbg !1108 {
  %2 = alloca i16, i16 1, align 2, !dbg !1109
  %3 = alloca i16, i16 1, align 2, !dbg !1111
  store i16 %0, i16* %3, align 2, !dbg !1111
  %4 = load i16, i16* %3, align 2, !dbg !1112
  store i16 %4, i16* %2, align 2, !dbg !1109
  %5 = load i16, i16* %2, align 2, !dbg !1113
  store i16 %5, i16* %2, align 2, !dbg !1114
  %6 = load i16, i16* %2, align 2, !dbg !1115
  ret i16 %6, !dbg !1116
}

define internal i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %0) !dbg !1117 {
  %2 = alloca i16, i16 1, align 2, !dbg !1118
  %3 = alloca i16, i16 1, align 2, !dbg !1120
  store i16 %0, i16* %3, align 2, !dbg !1120
  %4 = load i16, i16* %3, align 2, !dbg !1121
  store i16 %4, i16* %2, align 2, !dbg !1118
  %5 = load i16, i16* %2, align 2, !dbg !1122
  %6 = or i16 %5, 2, !dbg !1123
  store i16 %6, i16* %2, align 2, !dbg !1123
  %7 = load i16, i16* %2, align 2, !dbg !1124
  ret i16 %7, !dbg !1125
}

define internal i16 @__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %0) !dbg !1126 {
  %2 = alloca i16, i16 1, align 2, !dbg !1127
  %3 = alloca i16, i16 1, align 2, !dbg !1129
  store i16 %0, i16* %3, align 2, !dbg !1129
  %4 = load i16, i16* %3, align 2, !dbg !1130
  store i16 %4, i16* %2, align 2, !dbg !1127
  %5 = load i16, i16* %2, align 2, !dbg !1131
  %6 = or i16 %5, 128, !dbg !1132
  store i16 %6, i16* %2, align 2, !dbg !1132
  %7 = load i16, i16* %2, align 2, !dbg !1133
  ret i16 %7, !dbg !1134
}

define internal void @__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction(i16 %0) !dbg !1135 {
  %2 = alloca i16, i16 1, align 2, !dbg !1136
  %3 = alloca i16, i16 1, align 2, !dbg !1138
  %4 = alloca i16, i16 1, align 2, !dbg !1139
  store i16 %0, i16* %4, align 2, !dbg !1139
  %5 = load i16, i16* %4, align 2, !dbg !1140
  store i16 %5, i16* %3, align 2, !dbg !1138
  %6 = load i16, i16* %3, align 2, !dbg !1141
  %7 = shl i16 %6, 1, !dbg !1142
  %8 = inttoptr i16 %7 to i16*, !dbg !1142
  call void asm sideeffect "nop", ""(), !dbg !1142
  call void asm sideeffect "nop", ""(), !dbg !1142
  %9 = load volatile i16, i16* %8, align 2, !dbg !1142
  store i16 %9, i16* %2, align 2, !dbg !1136
  %10 = load i16, i16* %2, align 2, !dbg !1143
  %11 = and i16 %10, -17, !dbg !1144
  store i16 %11, i16* %2, align 2, !dbg !1144
  %12 = load i16, i16* %3, align 2, !dbg !1145
  %13 = load i16, i16* %2, align 2, !dbg !1146
  %14 = shl i16 %12, 1, !dbg !1147
  %15 = inttoptr i16 %14 to i16*, !dbg !1147
  store volatile i16 %13, i16* %15, align 2, !dbg !1147
  call void asm sideeffect "nop", ""(), !dbg !1147
  call void asm sideeffect "nop", ""(), !dbg !1147
  ret void, !dbg !1148
}

define internal void @__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction(i16 %0) !dbg !1149 {
  %2 = alloca i16, i16 1, align 2, !dbg !1150
  %3 = alloca i16, i16 1, align 2, !dbg !1152
  %4 = alloca i16, i16 1, align 2, !dbg !1153
  store i16 %0, i16* %4, align 2, !dbg !1153
  %5 = load i16, i16* %4, align 2, !dbg !1154
  store i16 %5, i16* %3, align 2, !dbg !1152
  %6 = load i16, i16* %3, align 2, !dbg !1155
  %7 = shl i16 %6, 1, !dbg !1156
  %8 = inttoptr i16 %7 to i16*, !dbg !1156
  call void asm sideeffect "nop", ""(), !dbg !1156
  call void asm sideeffect "nop", ""(), !dbg !1156
  %9 = load volatile i16, i16* %8, align 2, !dbg !1156
  store i16 %9, i16* %2, align 2, !dbg !1150
  %10 = load i16, i16* %2, align 2, !dbg !1157
  %11 = or i16 %10, 16, !dbg !1158
  store i16 %11, i16* %2, align 2, !dbg !1158
  %12 = load i16, i16* %3, align 2, !dbg !1159
  %13 = load i16, i16* %2, align 2, !dbg !1160
  %14 = shl i16 %12, 1, !dbg !1161
  %15 = inttoptr i16 %14 to i16*, !dbg !1161
  store volatile i16 %13, i16* %15, align 2, !dbg !1161
  call void asm sideeffect "nop", ""(), !dbg !1161
  call void asm sideeffect "nop", ""(), !dbg !1161
  ret void, !dbg !1162
}

define void @.teardown() #11 {
  %1 = load volatile i16, i16* inttoptr (i16 -1916 to i16*), align 2
  %2 = zext i16 %1 to i32
  %3 = load volatile i16, i16* inttoptr (i16 -1914 to i16*), align 2
  %4 = zext i16 %3 to i32
  %5 = shl i32 %4, 16
  %6 = or i32 %2, %5
  %7 = and i32 %6, 8388608
  %8 = icmp ne i32 %7, 0
  br i1 %8, label %9, label %10

9:                                                ; preds = %0
  call void @sys_mod.sys_mod.teardown_h2d()
  br label %10

10:                                               ; preds = %9, %0
  %11 = and i32 %6, 2097152
  %12 = icmp ne i32 %11, 0
  br i1 %12, label %13, label %14

13:                                               ; preds = %10
  call void @sys_mod.sys_mod.teardown_d2h()
  br label %14

14:                                               ; preds = %13, %10
  %15 = load volatile i16, i16* inttoptr (i16 -2268 to i16*), align 2
  %16 = and i16 %15, 1
  %17 = icmp ne i16 %16, 0
  br i1 %17, label %18, label %19

18:                                               ; preds = %14
  call void @sys_mod.sys_mod.oq0_teardow_handler()
  br label %19

19:                                               ; preds = %18, %14
  ret void
}

; Function Attrs: nounwind
declare void @llvm.sdr.actvt.r(i16) #12

; Function Attrs: nounwind
declare void @llvm.sdr.blk.r(i16) #12

; Function Attrs: nounwind
declare void @llvm.sdr.ublk.r(i16) #12

; Function Attrs: nounwind
declare i16 @llvm.sdr.read.lfsr() #12

; Function Attrs: nounwind
declare void @llvm.sdr.stprng.r(i16) #12

; Function Attrs: nounwind
declare void @llvm.sdr.lds0wds(i16 immarg, i8* readonly) #12

; Function Attrs: nounwind
declare void @llvm.sdr.lds1wds(i16 immarg, i8* readonly) #12

; Function Attrs: nounwind
declare void @llvm.sdr.lddwds(i16 immarg, i8* readonly) #12

; Function Attrs: nounwind
declare void @llvm.sdr.ldxds(i16 immarg, i8* readonly) #12

; Function Attrs: nounwind
declare void @llvm.sdr.ldsr(i16 immarg, i8* readonly) #12

; Function Attrs: nounwind writeonly
declare void @llvm.sdr.iqflush(i16) #13

; Function Attrs: nounwind writeonly
declare void @llvm.sdr.oqflush(i16) #13

; Function Attrs: nounwind
declare void @llvm.sdr.imov16.ds1(i16 immarg, i16 immarg) #12

; Function Attrs: nounwind
declare void @llvm.sdr.fmov16.ds1(i16 immarg, i16 immarg) #12

; Function Attrs: nounwind
declare void @llvm.sdr.fmulh.ds0s1(i16 immarg, i16 immarg, i16 immarg) #12

; Function Attrs: nounwind
declare void @llvm.sdr.imov32.ds1(i16 immarg, i16 immarg) #12

; Function Attrs: nounwind
declare half @llvm.sdr.faddh.rrs1.f16(half, i16 immarg) #12

; Function Attrs: nounwind
declare void @llvm.sdr.add16.ds0s1(i16 immarg, i16 immarg, i16 immarg) #12

; Function Attrs: nounwind
declare void @llvm.sdr.fmach.ds0s1r.f16(i16 immarg, i16 immarg, i16 immarg, half) #12

; Function Attrs: nounwind
declare void @llvm.sdr.fadds.ds0s1(i16 immarg, i16 immarg, i16 immarg) #12

; Function Attrs: nounwind
declare void @llvm.sdr.fmov16.dr.f16(i16 immarg, half) #12

declare i16 @csl.ss.read.16(i16, i1)

declare i32 @csl.ss.read.32(i16, i1)

declare void @csl.ss.write.16(i16, i16, i1)

declare void @csl.ss.write.32(i16, i32, i1)

declare i1 @csl.ss.set_jump_target()

declare i1 @csl.fifo.set_jump_target()

attributes #0 = { "entry-point"="9" "task" }
attributes #1 = { "entry-point"="27" "task" }
attributes #2 = { "entry-point"="34" "task" }
attributes #3 = { "entry-point"="35" "task" }
attributes #4 = { "entry-point"="36" "task" }
attributes #5 = { "entry-point"="33" "task" }
attributes #6 = { "entry-point"="28" "task" }
attributes #7 = { "entry-point"="37" "task" }
attributes #8 = { "entry-point"="0" "task" }
attributes #9 = { "entry-point"="21" "task" }
attributes #10 = { "entry-point"="30" "task" }
attributes #11 = { "entry-point"="29" "task" }
attributes #12 = { nounwind }
attributes #13 = { nounwind writeonly }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!2}

!0 = distinct !DICompileUnit(language: DW_LANG_C, file: !1, producer: "mlir", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug)
!1 = !DIFile(filename: "./layout.csl", directory: "/")
!2 = !{i32 2, !"Debug Info Version", i32 3}
!3 = distinct !DISubprogram(name: "compute", linkageName: "compute", scope: null, file: !4, line: 34, type: !5, scopeLine: 34, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!4 = !DIFile(filename: "./pe.csl", directory: "/home/USER/xkernel/studies/wse3-characterization/microbench/atomic_ops")
!5 = !DISubroutineType(types: !6)
!6 = !{}
!7 = !DILocation(line: 69, column: 3, scope: !8)
!8 = !DILexicalBlockFile(scope: !3, file: !4, discriminator: 0)
!9 = !DILocation(line: 35, column: 11, scope: !8)
!10 = !DILocation(line: 36, column: 13, scope: !8)
!11 = !DILocation(line: 36, column: 21, scope: !8)
!12 = !DILocation(line: 36, column: 17, scope: !8)
!13 = !DILocation(line: 36, column: 9, scope: !8)
!14 = !DILocation(line: 38, column: 11, scope: !8)
!15 = !DILocation(line: 39, column: 13, scope: !8)
!16 = !DILocation(line: 39, column: 21, scope: !8)
!17 = !DILocation(line: 39, column: 17, scope: !8)
!18 = !DILocation(line: 39, column: 9, scope: !8)
!19 = !DILocation(line: 41, column: 11, scope: !8)
!20 = !DILocation(line: 42, column: 13, scope: !8)
!21 = !DILocation(line: 42, column: 21, scope: !8)
!22 = !DILocation(line: 42, column: 17, scope: !8)
!23 = !DILocation(line: 42, column: 9, scope: !8)
!24 = !DILocation(line: 44, column: 11, scope: !8)
!25 = !DILocation(line: 45, column: 13, scope: !8)
!26 = !DILocation(line: 45, column: 21, scope: !8)
!27 = !DILocation(line: 45, column: 17, scope: !8)
!28 = !DILocation(line: 45, column: 29, scope: !8)
!29 = !DILocation(line: 45, column: 25, scope: !8)
!30 = !DILocation(line: 45, column: 9, scope: !8)
!31 = !DILocation(line: 47, column: 11, scope: !8)
!32 = !DILocation(line: 48, column: 13, scope: !8)
!33 = !DILocation(line: 48, column: 21, scope: !8)
!34 = !DILocation(line: 48, column: 17, scope: !8)
!35 = !DILocation(line: 48, column: 9, scope: !8)
!36 = !DILocation(line: 50, column: 11, scope: !8)
!37 = !DILocation(line: 51, column: 13, scope: !8)
!38 = !DILocation(line: 51, column: 21, scope: !8)
!39 = !DILocation(line: 51, column: 17, scope: !8)
!40 = !DILocation(line: 51, column: 9, scope: !8)
!41 = !DILocation(line: 53, column: 11, scope: !8)
!42 = !DILocation(line: 54, column: 13, scope: !8)
!43 = !DILocation(line: 54, column: 21, scope: !8)
!44 = !DILocation(line: 54, column: 17, scope: !8)
!45 = !DILocation(line: 54, column: 9, scope: !8)
!46 = !DILocation(line: 56, column: 11, scope: !8)
!47 = !DILocation(line: 57, column: 13, scope: !8)
!48 = !DILocation(line: 57, column: 17, scope: !8)
!49 = !DILocation(line: 57, column: 9, scope: !8)
!50 = !DILocation(line: 59, column: 11, scope: !8)
!51 = !DILocation(line: 60, column: 13, scope: !8)
!52 = !DILocation(line: 60, column: 17, scope: !8)
!53 = !DILocation(line: 60, column: 9, scope: !8)
!54 = !DILocation(line: 62, column: 11, scope: !8)
!55 = !DILocation(line: 63, column: 9, scope: !8)
!56 = !DILocation(line: 63, column: 17, scope: !8)
!57 = !DILocation(line: 63, column: 13, scope: !8)
!58 = !DILocation(line: 63, column: 3, scope: !8)
!59 = !DILocation(line: 63, column: 30, scope: !8)
!60 = !DILocation(line: 65, column: 12, scope: !8)
!61 = !DILocation(line: 66, column: 9, scope: !8)
!62 = !DILocation(line: 66, column: 17, scope: !8)
!63 = !DILocation(line: 66, column: 13, scope: !8)
!64 = !DILocation(line: 66, column: 3, scope: !8)
!65 = !DILocation(line: 66, column: 30, scope: !8)
!66 = !DILocation(line: 68, column: 12, scope: !8)
!67 = !DILocation(line: 70, column: 3, scope: !8)
!68 = !DILocation(line: 70, column: 10, scope: !8)
!69 = !DILocation(line: 70, column: 25, scope: !8)
!70 = !DILocation(line: 70, column: 12, scope: !8)
!71 = !DILocation(line: 70, column: 54, scope: !8)
!72 = !DILocation(line: 70, column: 63, scope: !8)
!73 = !DILocation(line: 70, column: 62, scope: !8)
!74 = !DILocation(line: 70, column: 58, scope: !8)
!75 = !DILocation(line: 70, column: 50, scope: !8)
!76 = !DILocation(line: 70, column: 34, scope: !8)
!77 = !DILocation(line: 70, column: 36, scope: !8)
!78 = !DILocation(line: 72, column: 12, scope: !8)
!79 = !DILocation(line: 73, column: 23, scope: !8)
!80 = !DILocation(line: 73, column: 12, scope: !8)
!81 = !DILocation(line: 73, column: 10, scope: !8)
!82 = !DILocation(line: 75, column: 12, scope: !8)
!83 = !DILocation(line: 76, column: 23, scope: !8)
!84 = !DILocation(line: 76, column: 11, scope: !8)
!85 = !DILocation(line: 76, column: 9, scope: !8)
!86 = !DILocation(line: 78, column: 12, scope: !8)
!87 = !DILocation(line: 79, column: 3, scope: !8)
!88 = !DILocation(line: 81, column: 12, scope: !8)
!89 = !DILocation(line: 82, column: 3, scope: !8)
!90 = !DILocation(line: 84, column: 12, scope: !8)
!91 = !DILocation(line: 85, column: 3, scope: !8)
!92 = !DILocation(line: 87, column: 12, scope: !8)
!93 = !DILocation(line: 88, column: 16, scope: !8)
!94 = !DILocation(line: 88, column: 3, scope: !8)
!95 = !DILocation(line: 89, column: 11, scope: !8)
!96 = !DILocation(line: 89, column: 9, scope: !8)
!97 = !DILocation(line: 91, column: 12, scope: !8)
!98 = !DILocation(line: 92, column: 3, scope: !8)
!99 = !DILocation(line: 94, column: 12, scope: !8)
!100 = !DILocation(line: 95, column: 3, scope: !8)
!101 = !DILocation(line: 97, column: 12, scope: !8)
!102 = !DILocation(line: 98, column: 3, scope: !8)
!103 = !DILocation(line: 100, column: 12, scope: !8)
!104 = !DILocation(line: 101, column: 3, scope: !8)
!105 = !DILocation(line: 103, column: 12, scope: !8)
!106 = !DILocation(line: 104, column: 3, scope: !8)
!107 = distinct !DISubprogram(name: "f_exit", linkageName: "f_exit", scope: null, file: !4, line: 107, type: !5, scopeLine: 107, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!108 = !DILocation(line: 107, column: 22, scope: !109)
!109 = !DILexicalBlockFile(scope: !107, file: !4, discriminator: 0)
!110 = !DILocation(line: 107, column: 1, scope: !109)
!111 = distinct !DISubprogram(name: "sys_mod.sys_nop", linkageName: "sys_mod.sys_nop", scope: null, file: !112, line: 90, type: !5, scopeLine: 90, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!112 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/memcpy.csl", directory: "")
!113 = !DILocation(line: 90, column: 1, scope: !114)
!114 = !DILexicalBlockFile(scope: !111, file: !112, discriminator: 0)
!115 = distinct !DISubprogram(name: "sys_mod.unblock_cmd_stream", linkageName: "sys_mod.unblock_cmd_stream", scope: null, file: !112, line: 102, type: !5, scopeLine: 102, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!116 = !DILocation(line: 103, column: 3, scope: !117)
!117 = !DILexicalBlockFile(scope: !115, file: !112, discriminator: 0)
!118 = !DILocation(line: 102, column: 1, scope: !117)
!119 = distinct !DISubprogram(name: "sys_mod.sys_mod.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.unblock_cmd_stream", scope: null, file: !120, line: 307, type: !5, scopeLine: 307, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!120 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpy.csl", directory: "")
!121 = !DILocation(line: 308, column: 5, scope: !122)
!122 = !DILexicalBlockFile(scope: !119, file: !120, discriminator: 0)
!123 = !DILocation(line: 307, column: 1, scope: !122)
!124 = distinct !DISubprogram(name: "sys_mod.sys_mod.teardown_h2d", linkageName: "sys_mod.sys_mod.teardown_h2d", scope: null, file: !120, line: 323, type: !5, scopeLine: 323, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!125 = !DILocation(line: 326, column: 5, scope: !126)
!126 = !DILexicalBlockFile(scope: !124, file: !120, discriminator: 0)
!127 = !DILocation(line: 323, column: 1, scope: !126)
!128 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_ublk_c22", linkageName: "sys_mod.sys_mod.f_ublk_c22", scope: null, file: !120, line: 335, type: !5, scopeLine: 335, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!129 = !DILocation(line: 336, column: 5, scope: !130)
!130 = !DILexicalBlockFile(scope: !128, file: !120, discriminator: 0)
!131 = !DILocation(line: 335, column: 1, scope: !130)
!132 = distinct !DISubprogram(name: "sys_mod.sys_mod.teardown_d2h", linkageName: "sys_mod.sys_mod.teardown_d2h", scope: null, file: !120, line: 344, type: !5, scopeLine: 344, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!133 = !DILocation(line: 355, column: 5, scope: !134)
!134 = !DILexicalBlockFile(scope: !132, file: !120, discriminator: 0)
!135 = !DILocation(line: 359, column: 5, scope: !134)
!136 = !DILocation(line: 344, column: 1, scope: !134)
!137 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_memcpyh2d", linkageName: "sys_mod.sys_mod.f_memcpyh2d", scope: null, file: !120, line: 460, type: !5, scopeLine: 460, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!138 = !DILocation(line: 477, column: 5, scope: !139)
!139 = !DILexicalBlockFile(scope: !137, file: !120, discriminator: 0)
!140 = !DILocation(line: 476, column: 5, scope: !139)
!141 = !DILocation(line: 475, column: 5, scope: !139)
!142 = !DILocation(line: 474, column: 5, scope: !139)
!143 = !DILocation(line: 473, column: 5, scope: !139)
!144 = !DILocation(line: 472, column: 5, scope: !139)
!145 = !DILocation(line: 471, column: 5, scope: !139)
!146 = !DILocation(line: 470, column: 5, scope: !139)
!147 = !DILocation(line: 469, column: 5, scope: !139)
!148 = !DILocation(line: 468, column: 5, scope: !139)
!149 = !DILocation(line: 467, column: 5, scope: !139)
!150 = !DILocation(line: 466, column: 5, scope: !139)
!151 = !DILocation(line: 465, column: 5, scope: !139)
!152 = !DILocation(line: 463, column: 5, scope: !139)
!153 = !DILocation(line: 462, column: 20, scope: !139)
!154 = !DILocation(line: 462, column: 32, scope: !139)
!155 = !DILocation(line: 462, column: 5, scope: !139)
!156 = !DILocation(line: 465, column: 33, scope: !139)
!157 = !DILocation(line: 465, column: 38, scope: !139)
!158 = !DILocation(line: 466, column: 34, scope: !139)
!159 = !DILocation(line: 466, column: 39, scope: !139)
!160 = !DILocation(line: 467, column: 34, scope: !139)
!161 = !DILocation(line: 467, column: 39, scope: !139)
!162 = !DILocation(line: 468, column: 33, scope: !139)
!163 = !DILocation(line: 468, column: 38, scope: !139)
!164 = !DILocation(line: 469, column: 33, scope: !139)
!165 = !DILocation(line: 469, column: 38, scope: !139)
!166 = !DILocation(line: 470, column: 35, scope: !139)
!167 = !DILocation(line: 470, column: 21, scope: !139)
!168 = !DILocation(line: 471, column: 41, scope: !139)
!169 = !DILocation(line: 471, column: 27, scope: !139)
!170 = !DILocation(line: 472, column: 39, scope: !139)
!171 = !DILocation(line: 472, column: 25, scope: !139)
!172 = !DILocation(line: 473, column: 44, scope: !139)
!173 = !DILocation(line: 473, column: 49, scope: !139)
!174 = !DILocation(line: 474, column: 41, scope: !139)
!175 = !DILocation(line: 474, column: 46, scope: !139)
!176 = !DILocation(line: 475, column: 41, scope: !139)
!177 = !DILocation(line: 475, column: 46, scope: !139)
!178 = !DILocation(line: 476, column: 59, scope: !139)
!179 = !DILocation(line: 476, column: 64, scope: !139)
!180 = !DILocation(line: 476, column: 50, scope: !139)
!181 = !DILocation(line: 476, column: 129, scope: !139)
!182 = !DILocation(line: 476, column: 134, scope: !139)
!183 = !DILocation(line: 476, column: 120, scope: !139)
!184 = !DILocation(line: 476, column: 118, scope: !139)
!185 = !DILocation(line: 476, column: 112, scope: !139)
!186 = !DILocation(line: 476, column: 36, scope: !139)
!187 = !DILocation(line: 477, column: 59, scope: !139)
!188 = !DILocation(line: 477, column: 64, scope: !139)
!189 = !DILocation(line: 477, column: 50, scope: !139)
!190 = !DILocation(line: 477, column: 129, scope: !139)
!191 = !DILocation(line: 477, column: 134, scope: !139)
!192 = !DILocation(line: 477, column: 120, scope: !139)
!193 = !DILocation(line: 477, column: 118, scope: !139)
!194 = !DILocation(line: 477, column: 112, scope: !139)
!195 = !DILocation(line: 477, column: 36, scope: !139)
!196 = !DILocation(line: 479, column: 24, scope: !139)
!197 = !DILocation(line: 481, column: 21, scope: !139)
!198 = !DILocation(line: 481, column: 19, scope: !139)
!199 = !DILocation(line: 482, column: 21, scope: !139)
!200 = !DILocation(line: 482, column: 19, scope: !139)
!201 = !DILocation(line: 483, column: 21, scope: !139)
!202 = !DILocation(line: 483, column: 19, scope: !139)
!203 = !DILocation(line: 484, column: 20, scope: !139)
!204 = !DILocation(line: 484, column: 18, scope: !139)
!205 = !DILocation(line: 485, column: 20, scope: !139)
!206 = !DILocation(line: 485, column: 18, scope: !139)
!207 = !DILocation(line: 486, column: 22, scope: !139)
!208 = !DILocation(line: 486, column: 20, scope: !139)
!209 = !DILocation(line: 487, column: 27, scope: !139)
!210 = !DILocation(line: 487, column: 25, scope: !139)
!211 = !DILocation(line: 488, column: 25, scope: !139)
!212 = !DILocation(line: 488, column: 23, scope: !139)
!213 = !DILocation(line: 489, column: 31, scope: !139)
!214 = !DILocation(line: 489, column: 29, scope: !139)
!215 = !DILocation(line: 490, column: 28, scope: !139)
!216 = !DILocation(line: 490, column: 26, scope: !139)
!217 = !DILocation(line: 491, column: 28, scope: !139)
!218 = !DILocation(line: 491, column: 26, scope: !139)
!219 = !DILocation(line: 492, column: 37, scope: !139)
!220 = !DILocation(line: 492, column: 35, scope: !139)
!221 = !DILocation(line: 493, column: 37, scope: !139)
!222 = !DILocation(line: 493, column: 35, scope: !139)
!223 = !DILocation(line: 495, column: 5, scope: !139)
!224 = !DILocation(line: 501, column: 5, scope: !139)
!225 = !DILocation(line: 506, column: 5, scope: !139)
!226 = !DILocation(line: 521, column: 5, scope: !139)
!227 = !DILocation(line: 522, column: 16, scope: !139)
!228 = !DILocation(line: 531, column: 5, scope: !139)
!229 = !DILocation(line: 460, column: 1, scope: !139)
!230 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_memcpyd2h", linkageName: "sys_mod.sys_mod.f_memcpyd2h", scope: null, file: !120, line: 556, type: !5, scopeLine: 556, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!231 = !DILocation(line: 568, column: 5, scope: !232)
!232 = !DILexicalBlockFile(scope: !230, file: !120, discriminator: 0)
!233 = !DILocation(line: 567, column: 5, scope: !232)
!234 = !DILocation(line: 566, column: 5, scope: !232)
!235 = !DILocation(line: 565, column: 5, scope: !232)
!236 = !DILocation(line: 564, column: 5, scope: !232)
!237 = !DILocation(line: 563, column: 5, scope: !232)
!238 = !DILocation(line: 562, column: 5, scope: !232)
!239 = !DILocation(line: 561, column: 5, scope: !232)
!240 = !DILocation(line: 559, column: 5, scope: !232)
!241 = !DILocation(line: 558, column: 20, scope: !232)
!242 = !DILocation(line: 558, column: 32, scope: !232)
!243 = !DILocation(line: 558, column: 5, scope: !232)
!244 = !DILocation(line: 561, column: 33, scope: !232)
!245 = !DILocation(line: 561, column: 38, scope: !232)
!246 = !DILocation(line: 562, column: 34, scope: !232)
!247 = !DILocation(line: 562, column: 39, scope: !232)
!248 = !DILocation(line: 563, column: 34, scope: !232)
!249 = !DILocation(line: 563, column: 39, scope: !232)
!250 = !DILocation(line: 564, column: 33, scope: !232)
!251 = !DILocation(line: 564, column: 38, scope: !232)
!252 = !DILocation(line: 565, column: 33, scope: !232)
!253 = !DILocation(line: 565, column: 38, scope: !232)
!254 = !DILocation(line: 566, column: 35, scope: !232)
!255 = !DILocation(line: 566, column: 21, scope: !232)
!256 = !DILocation(line: 567, column: 41, scope: !232)
!257 = !DILocation(line: 567, column: 27, scope: !232)
!258 = !DILocation(line: 568, column: 39, scope: !232)
!259 = !DILocation(line: 568, column: 25, scope: !232)
!260 = !DILocation(line: 570, column: 24, scope: !232)
!261 = !DILocation(line: 573, column: 21, scope: !232)
!262 = !DILocation(line: 573, column: 19, scope: !232)
!263 = !DILocation(line: 574, column: 21, scope: !232)
!264 = !DILocation(line: 574, column: 19, scope: !232)
!265 = !DILocation(line: 575, column: 21, scope: !232)
!266 = !DILocation(line: 575, column: 19, scope: !232)
!267 = !DILocation(line: 576, column: 20, scope: !232)
!268 = !DILocation(line: 576, column: 18, scope: !232)
!269 = !DILocation(line: 577, column: 20, scope: !232)
!270 = !DILocation(line: 577, column: 18, scope: !232)
!271 = !DILocation(line: 578, column: 22, scope: !232)
!272 = !DILocation(line: 578, column: 20, scope: !232)
!273 = !DILocation(line: 579, column: 27, scope: !232)
!274 = !DILocation(line: 579, column: 25, scope: !232)
!275 = !DILocation(line: 580, column: 25, scope: !232)
!276 = !DILocation(line: 580, column: 23, scope: !232)
!277 = !DILocation(line: 582, column: 5, scope: !232)
!278 = !DILocation(line: 588, column: 59, scope: !232)
!279 = !DILocation(line: 588, column: 5, scope: !232)
!280 = !DILocation(line: 608, column: 5, scope: !232)
!281 = !DILocation(line: 609, column: 16, scope: !232)
!282 = !DILocation(line: 556, column: 1, scope: !232)
!283 = distinct !DISubprogram(name: "sys_mod.sys_mod.oq0_teardow_handler", linkageName: "sys_mod.sys_mod.oq0_teardow_handler", scope: null, file: !120, line: 631, type: !5, scopeLine: 631, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!284 = !DILocation(line: 632, column: 9, scope: !285)
!285 = !DILexicalBlockFile(scope: !283, file: !120, discriminator: 0)
!286 = !DILocation(line: 632, column: 5, scope: !285)
!287 = !DILocation(line: 634, column: 66, scope: !285)
!288 = !DILocation(line: 634, column: 9, scope: !285)
!289 = !DILocation(line: 636, column: 13, scope: !285)
!290 = !DILocation(line: 637, column: 13, scope: !285)
!291 = !DILocation(line: 638, column: 13, scope: !285)
!292 = !DILocation(line: 639, column: 13, scope: !285)
!293 = !DILocation(line: 640, column: 13, scope: !285)
!294 = !DILocation(line: 641, column: 13, scope: !285)
!295 = !DILocation(line: 642, column: 13, scope: !285)
!296 = !DILocation(line: 643, column: 13, scope: !285)
!297 = !DILocation(line: 644, column: 13, scope: !285)
!298 = !DILocation(line: 645, column: 13, scope: !285)
!299 = !DILocation(line: 646, column: 13, scope: !285)
!300 = !DILocation(line: 647, column: 13, scope: !285)
!301 = !DILocation(line: 648, column: 13, scope: !285)
!302 = !DILocation(line: 635, column: 9, scope: !285)
!303 = !DILocation(line: 652, column: 9, scope: !285)
!304 = !DILocation(line: 654, column: 13, scope: !285)
!305 = !DILocation(line: 655, column: 13, scope: !285)
!306 = !DILocation(line: 656, column: 13, scope: !285)
!307 = !DILocation(line: 657, column: 13, scope: !285)
!308 = !DILocation(line: 658, column: 13, scope: !285)
!309 = !DILocation(line: 659, column: 13, scope: !285)
!310 = !DILocation(line: 660, column: 13, scope: !285)
!311 = !DILocation(line: 661, column: 13, scope: !285)
!312 = !DILocation(line: 653, column: 9, scope: !285)
!313 = !DILocation(line: 664, column: 5, scope: !285)
!314 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_rpc", linkageName: "sys_mod.sys_mod.f_rpc", scope: null, file: !120, line: 694, type: !5, scopeLine: 694, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!315 = !DILocation(line: 694, column: 13, scope: !316)
!316 = !DILexicalBlockFile(scope: !314, file: !120, discriminator: 0)
!317 = !DILocation(line: 700, column: 5, scope: !316)
!318 = !DILocation(line: 706, column: 20, scope: !316)
!319 = !DILocation(line: 706, column: 32, scope: !316)
!320 = !DILocation(line: 706, column: 5, scope: !316)
!321 = !DILocation(line: 710, column: 5, scope: !316)
!322 = !DILocation(line: 712, column: 24, scope: !316)
!323 = !DILocation(line: 694, column: 1, scope: !316)
!324 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.stack_push", linkageName: "sys_mod.sys_mod.sys_mod.stack_push", scope: null, file: !325, line: 54, type: !5, scopeLine: 54, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!325 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/sys.csl", directory: "")
!326 = !DILocation(line: 60, column: 5, scope: !327)
!327 = !DILexicalBlockFile(scope: !324, file: !325, discriminator: 0)
!328 = !DILocation(line: 54, column: 16, scope: !327)
!329 = !DILocation(line: 59, column: 13, scope: !327)
!330 = !DILocation(line: 59, column: 24, scope: !327)
!331 = !DILocation(line: 59, column: 5, scope: !327)
!332 = !DILocation(line: 61, column: 25, scope: !327)
!333 = !DILocation(line: 61, column: 5, scope: !327)
!334 = !DILocation(line: 61, column: 11, scope: !327)
!335 = !DILocation(line: 61, column: 10, scope: !327)
!336 = !DILocation(line: 61, column: 23, scope: !327)
!337 = !DILocation(line: 62, column: 18, scope: !327)
!338 = !DILocation(line: 62, column: 29, scope: !327)
!339 = !DILocation(line: 62, column: 16, scope: !327)
!340 = !DILocation(line: 54, column: 1, scope: !327)
!341 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_push", linkageName: "sys_mod.sys_mod.sys_mod.f_push", scope: null, file: !325, line: 72, type: !5, scopeLine: 72, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!342 = !DILocation(line: 72, column: 25, scope: !343)
!343 = !DILexicalBlockFile(scope: !341, file: !325, discriminator: 0)
!344 = !DILocation(line: 72, column: 13, scope: !343)
!345 = !DILocation(line: 73, column: 16, scope: !343)
!346 = !DILocation(line: 73, column: 5, scope: !343)
!347 = !DILocation(line: 72, column: 1, scope: !343)
!348 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.block_cmd_stream", linkageName: "sys_mod.sys_mod.sys_mod.block_cmd_stream", scope: null, file: !325, line: 76, type: !5, scopeLine: 76, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!349 = !DILocation(line: 77, column: 5, scope: !350)
!350 = !DILexicalBlockFile(scope: !348, file: !325, discriminator: 0)
!351 = !DILocation(line: 76, column: 1, scope: !350)
!352 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.sys_mod.unblock_cmd_stream", scope: null, file: !325, line: 80, type: !5, scopeLine: 80, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!353 = !DILocation(line: 81, column: 5, scope: !354)
!354 = !DILexicalBlockFile(scope: !352, file: !325, discriminator: 0)
!355 = !DILocation(line: 80, column: 1, scope: !354)
!356 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_sys_exit", linkageName: "sys_mod.sys_mod.sys_mod.f_sys_exit", scope: null, file: !325, line: 85, type: !5, scopeLine: 85, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!357 = !DILocation(line: 86, column: 5, scope: !358)
!358 = !DILexicalBlockFile(scope: !356, file: !325, discriminator: 0)
!359 = !DILocation(line: 87, column: 5, scope: !358)
!360 = !DILocation(line: 85, column: 1, scope: !358)
!361 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore", linkageName: "sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore", scope: null, file: !325, line: 90, type: !5, scopeLine: 90, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!362 = !DILocation(line: 90, column: 30, scope: !363)
!363 = !DILexicalBlockFile(scope: !361, file: !325, discriminator: 0)
!364 = !DILocation(line: 90, column: 1, scope: !363)
!365 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord", scope: null, file: !366, line: 131, type: !5, scopeLine: 131, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!366 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpyh2d.csl", directory: "")
!367 = !DILocation(line: 132, column: 12, scope: !368)
!368 = !DILexicalBlockFile(scope: !365, file: !366, discriminator: 0)
!369 = !DILocation(line: 132, column: 5, scope: !368)
!370 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord", scope: null, file: !366, line: 134, type: !5, scopeLine: 134, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!371 = !DILocation(line: 135, column: 12, scope: !372)
!372 = !DILexicalBlockFile(scope: !370, file: !366, discriminator: 0)
!373 = !DILocation(line: 135, column: 5, scope: !372)
!374 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval", scope: null, file: !366, line: 148, type: !5, scopeLine: 148, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!375 = !DILocation(line: 148, column: 23, scope: !376)
!376 = !DILexicalBlockFile(scope: !374, file: !366, discriminator: 0)
!377 = !DILocation(line: 149, column: 9, scope: !376)
!378 = !DILocation(line: 149, column: 20, scope: !376)
!379 = !DILocation(line: 149, column: 5, scope: !376)
!380 = !DILocation(line: 152, column: 23, scope: !376)
!381 = !DILocation(line: 152, column: 20, scope: !376)
!382 = !DILocation(line: 152, column: 9, scope: !376)
!383 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start", scope: null, file: !366, line: 226, type: !5, scopeLine: 226, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!384 = !DILocation(line: 233, column: 5, scope: !385)
!385 = !DILexicalBlockFile(scope: !383, file: !366, discriminator: 0)
!386 = !DILocation(line: 226, column: 49, scope: !385)
!387 = !DILocation(line: 226, column: 32, scope: !385)
!388 = !DILocation(line: 226, column: 21, scope: !385)
!389 = !DILocation(line: 229, column: 37, scope: !385)
!390 = !DILocation(line: 229, column: 52, scope: !385)
!391 = !DILocation(line: 229, column: 19, scope: !385)
!392 = !DILocation(line: 233, column: 71, scope: !385)
!393 = !DILocation(line: 233, column: 55, scope: !385)
!394 = !DILocation(line: 233, column: 25, scope: !385)
!395 = !DILocation(line: 235, column: 37, scope: !385)
!396 = !DILocation(line: 235, column: 52, scope: !385)
!397 = !DILocation(line: 235, column: 19, scope: !385)
!398 = !DILocation(line: 236, column: 28, scope: !385)
!399 = !DILocation(line: 236, column: 5, scope: !385)
!400 = !DILocation(line: 237, column: 28, scope: !385)
!401 = !DILocation(line: 237, column: 5, scope: !385)
!402 = !DILocation(line: 238, column: 13, scope: !385)
!403 = !DILocation(line: 238, column: 11, scope: !385)
!404 = !DILocation(line: 238, column: 5, scope: !385)
!405 = !DILocation(line: 239, column: 9, scope: !385)
!406 = !DILocation(line: 241, column: 9, scope: !385)
!407 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream", scope: null, file: !366, line: 249, type: !5, scopeLine: 249, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!408 = !DILocation(line: 250, column: 5, scope: !409)
!409 = !DILexicalBlockFile(scope: !407, file: !366, discriminator: 0)
!410 = !DILocation(line: 249, column: 1, scope: !409)
!411 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure", scope: null, file: !366, line: 276, type: !5, scopeLine: 276, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!412 = !DILocation(line: 414, column: 13, scope: !413)
!413 = !DILexicalBlockFile(scope: !411, file: !366, discriminator: 0)
!414 = !DILocation(line: 413, column: 13, scope: !413)
!415 = !DILocation(line: 400, column: 17, scope: !413)
!416 = !DILocation(line: 340, column: 9, scope: !413)
!417 = !DILocation(line: 339, column: 9, scope: !413)
!418 = !DILocation(line: 337, column: 5, scope: !413)
!419 = !DILocation(line: 319, column: 9, scope: !413)
!420 = !DILocation(line: 318, column: 9, scope: !413)
!421 = !DILocation(line: 315, column: 5, scope: !413)
!422 = !DILocation(line: 292, column: 5, scope: !413)
!423 = !DILocation(line: 291, column: 5, scope: !413)
!424 = !DILocation(line: 289, column: 5, scope: !413)
!425 = !DILocation(line: 288, column: 5, scope: !413)
!426 = !DILocation(line: 287, column: 5, scope: !413)
!427 = !DILocation(line: 286, column: 5, scope: !413)
!428 = !DILocation(line: 285, column: 5, scope: !413)
!429 = !DILocation(line: 284, column: 5, scope: !413)
!430 = !DILocation(line: 283, column: 5, scope: !413)
!431 = !DILocation(line: 282, column: 5, scope: !413)
!432 = !DILocation(line: 281, column: 5, scope: !413)
!433 = !DILocation(line: 280, column: 5, scope: !413)
!434 = !DILocation(line: 279, column: 5, scope: !413)
!435 = !DILocation(line: 278, column: 5, scope: !413)
!436 = !DILocation(line: 277, column: 5, scope: !413)
!437 = !DILocation(line: 291, column: 26, scope: !413)
!438 = !DILocation(line: 292, column: 26, scope: !413)
!439 = !DILocation(line: 315, column: 25, scope: !413)
!440 = !DILocation(line: 315, column: 31, scope: !413)
!441 = !DILocation(line: 315, column: 29, scope: !413)
!442 = !DILocation(line: 316, column: 20, scope: !413)
!443 = !DILocation(line: 316, column: 18, scope: !413)
!444 = !DILocation(line: 317, column: 52, scope: !413)
!445 = !DILocation(line: 317, column: 49, scope: !413)
!446 = !DILocation(line: 317, column: 5, scope: !413)
!447 = !DILocation(line: 318, column: 42, scope: !413)
!448 = !DILocation(line: 318, column: 33, scope: !413)
!449 = !DILocation(line: 318, column: 49, scope: !413)
!450 = !DILocation(line: 318, column: 48, scope: !413)
!451 = !DILocation(line: 318, column: 24, scope: !413)
!452 = !DILocation(line: 319, column: 24, scope: !413)
!453 = !DILocation(line: 319, column: 32, scope: !413)
!454 = !DILocation(line: 319, column: 36, scope: !413)
!455 = !DILocation(line: 319, column: 34, scope: !413)
!456 = !DILocation(line: 319, column: 30, scope: !413)
!457 = !DILocation(line: 320, column: 18, scope: !413)
!458 = !DILocation(line: 320, column: 15, scope: !413)
!459 = !DILocation(line: 320, column: 9, scope: !413)
!460 = !DILocation(line: 321, column: 26, scope: !413)
!461 = !DILocation(line: 325, column: 28, scope: !413)
!462 = !DILocation(line: 325, column: 26, scope: !413)
!463 = !DILocation(line: 331, column: 9, scope: !413)
!464 = !DILocation(line: 331, column: 15, scope: !413)
!465 = !DILocation(line: 331, column: 5, scope: !413)
!466 = !DILocation(line: 332, column: 22, scope: !413)
!467 = !DILocation(line: 334, column: 9, scope: !413)
!468 = !DILocation(line: 334, column: 18, scope: !413)
!469 = !DILocation(line: 334, column: 15, scope: !413)
!470 = !DILocation(line: 334, column: 5, scope: !413)
!471 = !DILocation(line: 335, column: 22, scope: !413)
!472 = !DILocation(line: 338, column: 52, scope: !413)
!473 = !DILocation(line: 338, column: 49, scope: !413)
!474 = !DILocation(line: 338, column: 5, scope: !413)
!475 = !DILocation(line: 339, column: 42, scope: !413)
!476 = !DILocation(line: 339, column: 48, scope: !413)
!477 = !DILocation(line: 339, column: 46, scope: !413)
!478 = !DILocation(line: 339, column: 33, scope: !413)
!479 = !DILocation(line: 339, column: 52, scope: !413)
!480 = !DILocation(line: 339, column: 51, scope: !413)
!481 = !DILocation(line: 339, column: 24, scope: !413)
!482 = !DILocation(line: 340, column: 25, scope: !413)
!483 = !DILocation(line: 340, column: 31, scope: !413)
!484 = !DILocation(line: 340, column: 29, scope: !413)
!485 = !DILocation(line: 340, column: 37, scope: !413)
!486 = !DILocation(line: 340, column: 41, scope: !413)
!487 = !DILocation(line: 340, column: 39, scope: !413)
!488 = !DILocation(line: 340, column: 35, scope: !413)
!489 = !DILocation(line: 341, column: 18, scope: !413)
!490 = !DILocation(line: 341, column: 15, scope: !413)
!491 = !DILocation(line: 341, column: 9, scope: !413)
!492 = !DILocation(line: 342, column: 26, scope: !413)
!493 = !DILocation(line: 347, column: 10, scope: !413)
!494 = !DILocation(line: 347, column: 16, scope: !413)
!495 = !DILocation(line: 347, column: 14, scope: !413)
!496 = !DILocation(line: 347, column: 5, scope: !413)
!497 = !DILocation(line: 348, column: 22, scope: !413)
!498 = !DILocation(line: 350, column: 10, scope: !413)
!499 = !DILocation(line: 350, column: 18, scope: !413)
!500 = !DILocation(line: 350, column: 21, scope: !413)
!501 = !DILocation(line: 350, column: 20, scope: !413)
!502 = !DILocation(line: 350, column: 14, scope: !413)
!503 = !DILocation(line: 350, column: 5, scope: !413)
!504 = !DILocation(line: 351, column: 22, scope: !413)
!505 = !DILocation(line: 354, column: 9, scope: !413)
!506 = !DILocation(line: 354, column: 5, scope: !413)
!507 = !DILocation(line: 358, column: 9, scope: !413)
!508 = !DILocation(line: 361, column: 9, scope: !413)
!509 = !DILocation(line: 364, column: 20, scope: !413)
!510 = !DILocation(line: 364, column: 17, scope: !413)
!511 = !DILocation(line: 364, column: 9, scope: !413)
!512 = !DILocation(line: 368, column: 13, scope: !413)
!513 = !DILocation(line: 371, column: 13, scope: !413)
!514 = !DILocation(line: 375, column: 13, scope: !413)
!515 = !DILocation(line: 394, column: 13, scope: !413)
!516 = !DILocation(line: 396, column: 29, scope: !413)
!517 = !DILocation(line: 396, column: 27, scope: !413)
!518 = !DILocation(line: 397, column: 60, scope: !413)
!519 = !DILocation(line: 397, column: 57, scope: !413)
!520 = !DILocation(line: 397, column: 13, scope: !413)
!521 = !DILocation(line: 400, column: 54, scope: !413)
!522 = !DILocation(line: 400, column: 55, scope: !413)
!523 = !DILocation(line: 400, column: 46, scope: !413)
!524 = !DILocation(line: 400, column: 59, scope: !413)
!525 = !DILocation(line: 400, column: 58, scope: !413)
!526 = !DILocation(line: 400, column: 37, scope: !413)
!527 = !DILocation(line: 400, column: 35, scope: !413)
!528 = !DILocation(line: 401, column: 33, scope: !413)
!529 = !DILocation(line: 401, column: 31, scope: !413)
!530 = !DILocation(line: 402, column: 69, scope: !413)
!531 = !DILocation(line: 402, column: 66, scope: !413)
!532 = !DILocation(line: 402, column: 19, scope: !413)
!533 = !DILocation(line: 404, column: 31, scope: !413)
!534 = !DILocation(line: 408, column: 75, scope: !413)
!535 = !DILocation(line: 408, column: 88, scope: !413)
!536 = !DILocation(line: 408, column: 13, scope: !413)
!537 = !DILocation(line: 413, column: 31, scope: !413)
!538 = !DILocation(line: 414, column: 33, scope: !413)
!539 = !DILocation(line: 415, column: 21, scope: !413)
!540 = !DILocation(line: 415, column: 29, scope: !413)
!541 = !DILocation(line: 415, column: 27, scope: !413)
!542 = !DILocation(line: 415, column: 19, scope: !413)
!543 = !DILocation(line: 416, column: 22, scope: !413)
!544 = !DILocation(line: 416, column: 19, scope: !413)
!545 = !DILocation(line: 416, column: 13, scope: !413)
!546 = !DILocation(line: 417, column: 23, scope: !413)
!547 = !DILocation(line: 419, column: 63, scope: !413)
!548 = !DILocation(line: 419, column: 60, scope: !413)
!549 = !DILocation(line: 419, column: 13, scope: !413)
!550 = !DILocation(line: 421, column: 23, scope: !413)
!551 = !DILocation(line: 423, column: 69, scope: !413)
!552 = !DILocation(line: 423, column: 13, scope: !413)
!553 = !DILocation(line: 426, column: 13, scope: !413)
!554 = !DILocation(line: 430, column: 13, scope: !413)
!555 = !DILocation(line: 433, column: 48, scope: !413)
!556 = !DILocation(line: 433, column: 22, scope: !413)
!557 = !DILocation(line: 433, column: 19, scope: !413)
!558 = !DILocation(line: 433, column: 13, scope: !413)
!559 = !DILocation(line: 436, column: 34, scope: !413)
!560 = !DILocation(line: 436, column: 39, scope: !413)
!561 = !DILocation(line: 436, column: 50, scope: !413)
!562 = !DILocation(line: 436, column: 17, scope: !413)
!563 = !DILocation(line: 452, column: 49, scope: !413)
!564 = !DILocation(line: 452, column: 64, scope: !413)
!565 = !DILocation(line: 452, column: 31, scope: !413)
!566 = !DILocation(line: 453, column: 40, scope: !413)
!567 = !DILocation(line: 453, column: 17, scope: !413)
!568 = !DILocation(line: 454, column: 50, scope: !413)
!569 = !DILocation(line: 454, column: 66, scope: !413)
!570 = !DILocation(line: 454, column: 32, scope: !413)
!571 = !DILocation(line: 455, column: 40, scope: !413)
!572 = !DILocation(line: 455, column: 17, scope: !413)
!573 = !DILocation(line: 456, column: 17, scope: !413)
!574 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit", scope: null, file: !575, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!575 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/filters/wse3.csl", directory: "")
!576 = !DILocation(line: 24, column: 3, scope: !577)
!577 = !DILexicalBlockFile(scope: !574, file: !575, discriminator: 0)
!578 = !DILocation(line: 24, column: 22, scope: !577)
!579 = !DILocation(line: 23, column: 3, scope: !577)
!580 = !DILocation(line: 22, column: 3, scope: !577)
!581 = !DILocation(line: 20, column: 37, scope: !577)
!582 = !DILocation(line: 20, column: 21, scope: !577)
!583 = !DILocation(line: 21, column: 11, scope: !577)
!584 = !DILocation(line: 21, column: 17, scope: !577)
!585 = !DILocation(line: 21, column: 3, scope: !577)
!586 = !DILocation(line: 22, column: 24, scope: !577)
!587 = !DILocation(line: 22, column: 30, scope: !577)
!588 = !DILocation(line: 23, column: 40, scope: !577)
!589 = !DILocation(line: 23, column: 22, scope: !577)
!590 = !DILocation(line: 23, column: 67, scope: !577)
!591 = !DILocation(line: 24, column: 26, scope: !577)
!592 = !DILocation(line: 24, column: 41, scope: !577)
!593 = !DILocation(line: 24, column: 39, scope: !577)
!594 = !DILocation(line: 24, column: 61, scope: !577)
!595 = !DILocation(line: 24, column: 76, scope: !577)
!596 = !DILocation(line: 24, column: 74, scope: !577)
!597 = !DILocation(line: 25, column: 21, scope: !577)
!598 = !DILocation(line: 25, column: 50, scope: !577)
!599 = !DILocation(line: 25, column: 3, scope: !577)
!600 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter", scope: null, file: !575, line: 30, type: !5, scopeLine: 30, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!601 = !DILocation(line: 30, column: 36, scope: !602)
!602 = !DILexicalBlockFile(scope: !600, file: !575, discriminator: 0)
!603 = !DILocation(line: 30, column: 20, scope: !602)
!604 = !DILocation(line: 31, column: 11, scope: !602)
!605 = !DILocation(line: 31, column: 23, scope: !602)
!606 = !DILocation(line: 31, column: 3, scope: !602)
!607 = !DILocation(line: 32, column: 21, scope: !602)
!608 = !DILocation(line: 32, column: 48, scope: !602)
!609 = !DILocation(line: 32, column: 60, scope: !602)
!610 = !DILocation(line: 32, column: 64, scope: !602)
!611 = !DILocation(line: 32, column: 3, scope: !602)
!612 = !DILocation(line: 30, column: 1, scope: !602)
!613 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter", scope: null, file: !575, line: 40, type: !5, scopeLine: 40, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!614 = !DILocation(line: 47, column: 3, scope: !615)
!615 = !DILexicalBlockFile(scope: !613, file: !575, discriminator: 0)
!616 = !DILocation(line: 48, column: 7, scope: !615)
!617 = !DILocation(line: 44, column: 3, scope: !615)
!618 = !DILocation(line: 43, column: 3, scope: !615)
!619 = !DILocation(line: 42, column: 3, scope: !615)
!620 = !DILocation(line: 40, column: 32, scope: !615)
!621 = !DILocation(line: 40, column: 16, scope: !615)
!622 = !DILocation(line: 41, column: 11, scope: !615)
!623 = !DILocation(line: 41, column: 19, scope: !615)
!624 = !DILocation(line: 41, column: 3, scope: !615)
!625 = !DILocation(line: 42, column: 40, scope: !615)
!626 = !DILocation(line: 42, column: 22, scope: !615)
!627 = !DILocation(line: 43, column: 26, scope: !615)
!628 = !DILocation(line: 43, column: 34, scope: !615)
!629 = !DILocation(line: 44, column: 25, scope: !615)
!630 = !DILocation(line: 44, column: 42, scope: !615)
!631 = !DILocation(line: 44, column: 40, scope: !615)
!632 = !DILocation(line: 45, column: 21, scope: !615)
!633 = !DILocation(line: 46, column: 35, scope: !615)
!634 = !DILocation(line: 46, column: 21, scope: !615)
!635 = !DILocation(line: 46, column: 50, scope: !615)
!636 = !DILocation(line: 45, column: 3, scope: !615)
!637 = !DILocation(line: 48, column: 11, scope: !615)
!638 = !DILocation(line: 48, column: 26, scope: !615)
!639 = !DILocation(line: 48, column: 43, scope: !615)
!640 = !DILocation(line: 48, column: 41, scope: !615)
!641 = !DILocation(line: 48, column: 54, scope: !615)
!642 = !DILocation(line: 48, column: 63, scope: !615)
!643 = !DILocation(line: 49, column: 21, scope: !615)
!644 = !DILocation(line: 49, column: 47, scope: !615)
!645 = !DILocation(line: 49, column: 3, scope: !615)
!646 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config", scope: null, file: !647, line: 33, type: !5, scopeLine: 33, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!647 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/filters/common.csl", directory: "")
!648 = !DILocation(line: 33, column: 46, scope: !649)
!649 = !DILexicalBlockFile(scope: !646, file: !647, discriminator: 0)
!650 = !DILocation(line: 33, column: 31, scope: !649)
!651 = !DILocation(line: 33, column: 15, scope: !649)
!652 = !DILocation(line: 34, column: 24, scope: !649)
!653 = !DILocation(line: 34, column: 23, scope: !649)
!654 = !DILocation(line: 34, column: 51, scope: !649)
!655 = !DILocation(line: 34, column: 35, scope: !649)
!656 = !DILocation(line: 34, column: 60, scope: !649)
!657 = !DILocation(line: 34, column: 73, scope: !649)
!658 = !DILocation(line: 34, column: 3, scope: !649)
!659 = !DILocation(line: 33, column: 1, scope: !649)
!660 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config", scope: null, file: !647, line: 38, type: !5, scopeLine: 38, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!661 = !DILocation(line: 38, column: 31, scope: !662)
!662 = !DILexicalBlockFile(scope: !660, file: !647, discriminator: 0)
!663 = !DILocation(line: 38, column: 15, scope: !662)
!664 = !DILocation(line: 39, column: 31, scope: !662)
!665 = !DILocation(line: 39, column: 30, scope: !662)
!666 = !DILocation(line: 39, column: 58, scope: !662)
!667 = !DILocation(line: 39, column: 42, scope: !662)
!668 = !DILocation(line: 39, column: 67, scope: !662)
!669 = !DILocation(line: 39, column: 10, scope: !662)
!670 = !DILocation(line: 39, column: 3, scope: !662)
!671 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit", scope: null, file: !672, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!672 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/teardown.csl", directory: "")
!673 = !DILocation(line: 43, column: 3, scope: !674)
!674 = !DILexicalBlockFile(scope: !671, file: !672, discriminator: 0)
!675 = !DILocation(line: 41, column: 3, scope: !674)
!676 = !DILocation(line: 40, column: 3, scope: !674)
!677 = !DILocation(line: 39, column: 9, scope: !674)
!678 = !DILocation(line: 40, column: 23, scope: !674)
!679 = !DILocation(line: 41, column: 70, scope: !674)
!680 = !DILocation(line: 41, column: 68, scope: !674)
!681 = !DILocation(line: 43, column: 27, scope: !674)
!682 = !DILocation(line: 43, column: 15, scope: !674)
!683 = !DILocation(line: 44, column: 15, scope: !674)
!684 = !DILocation(line: 44, column: 21, scope: !674)
!685 = !DILocation(line: 44, column: 27, scope: !674)
!686 = !DILocation(line: 44, column: 3, scope: !674)
!687 = !DILocation(line: 39, column: 1, scope: !674)
!688 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord", scope: null, file: !689, line: 4, type: !5, scopeLine: 4, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!689 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/layout.csl", directory: "")
!690 = !DILocation(line: 5, column: 10, scope: !691)
!691 = !DILexicalBlockFile(scope: !688, file: !689, discriminator: 0)
!692 = !DILocation(line: 5, column: 67, scope: !691)
!693 = !DILocation(line: 5, column: 3, scope: !691)
!694 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord", scope: null, file: !689, line: 8, type: !5, scopeLine: 8, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!695 = !DILocation(line: 9, column: 10, scope: !696)
!696 = !DILexicalBlockFile(scope: !694, file: !689, discriminator: 0)
!697 = !DILocation(line: 9, column: 67, scope: !696)
!698 = !DILocation(line: 9, column: 3, scope: !696)
!699 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord", scope: null, file: !700, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!700 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config.csl", directory: "")
!701 = !DILocation(line: 50, column: 3, scope: !702)
!702 = !DILexicalBlockFile(scope: !699, file: !700, discriminator: 0)
!703 = !DILocation(line: 43, column: 21, scope: !702)
!704 = !DILocation(line: 50, column: 57, scope: !702)
!705 = !DILocation(line: 50, column: 68, scope: !702)
!706 = !DILocation(line: 50, column: 41, scope: !702)
!707 = !DILocation(line: 50, column: 19, scope: !702)
!708 = !DILocation(line: 52, column: 10, scope: !702)
!709 = !DILocation(line: 52, column: 18, scope: !702)
!710 = !DILocation(line: 48, column: 22, scope: !702)
!711 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.get_x_coord", scope: null, file: !712, line: 171, type: !5, scopeLine: 171, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!712 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpyd2h.csl", directory: "")
!713 = !DILocation(line: 172, column: 12, scope: !714)
!714 = !DILexicalBlockFile(scope: !711, file: !712, discriminator: 0)
!715 = !DILocation(line: 172, column: 5, scope: !714)
!716 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.get_y_coord", scope: null, file: !712, line: 174, type: !5, scopeLine: 174, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!717 = !DILocation(line: 175, column: 12, scope: !718)
!718 = !DILexicalBlockFile(scope: !716, file: !712, discriminator: 0)
!719 = !DILocation(line: 175, column: 5, scope: !718)
!720 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval", scope: null, file: !712, line: 187, type: !5, scopeLine: 187, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!721 = !DILocation(line: 187, column: 23, scope: !722)
!722 = !DILexicalBlockFile(scope: !720, file: !712, discriminator: 0)
!723 = !DILocation(line: 188, column: 9, scope: !722)
!724 = !DILocation(line: 188, column: 20, scope: !722)
!725 = !DILocation(line: 188, column: 5, scope: !722)
!726 = !DILocation(line: 191, column: 23, scope: !722)
!727 = !DILocation(line: 191, column: 20, scope: !722)
!728 = !DILocation(line: 191, column: 9, scope: !722)
!729 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start", scope: null, file: !712, line: 383, type: !5, scopeLine: 383, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!730 = !DILocation(line: 386, column: 5, scope: !731)
!731 = !DILexicalBlockFile(scope: !729, file: !712, discriminator: 0)
!732 = !DILocation(line: 384, column: 72, scope: !731)
!733 = !DILocation(line: 384, column: 59, scope: !731)
!734 = !DILocation(line: 384, column: 46, scope: !731)
!735 = !DILocation(line: 384, column: 33, scope: !731)
!736 = !DILocation(line: 384, column: 19, scope: !731)
!737 = !DILocation(line: 384, column: 5, scope: !731)
!738 = !DILocation(line: 383, column: 32, scope: !731)
!739 = !DILocation(line: 383, column: 21, scope: !731)
!740 = !DILocation(line: 386, column: 26, scope: !731)
!741 = !DILocation(line: 388, column: 28, scope: !731)
!742 = !DILocation(line: 388, column: 17, scope: !731)
!743 = !DILocation(line: 389, column: 25, scope: !731)
!744 = !DILocation(line: 389, column: 23, scope: !731)
!745 = !DILocation(line: 391, column: 38, scope: !731)
!746 = !DILocation(line: 391, column: 20, scope: !731)
!747 = !DILocation(line: 391, column: 18, scope: !731)
!748 = !DILocation(line: 393, column: 7, scope: !731)
!749 = !DILocation(line: 395, column: 17, scope: !731)
!750 = !DILocation(line: 395, column: 15, scope: !731)
!751 = !DILocation(line: 397, column: 15, scope: !731)
!752 = !DILocation(line: 397, column: 13, scope: !731)
!753 = !DILocation(line: 398, column: 15, scope: !731)
!754 = !DILocation(line: 398, column: 25, scope: !731)
!755 = !DILocation(line: 398, column: 23, scope: !731)
!756 = !DILocation(line: 398, column: 31, scope: !731)
!757 = !DILocation(line: 398, column: 13, scope: !731)
!758 = !DILocation(line: 401, column: 10, scope: !731)
!759 = !DILocation(line: 401, column: 17, scope: !731)
!760 = !DILocation(line: 401, column: 14, scope: !731)
!761 = !DILocation(line: 401, column: 5, scope: !731)
!762 = !DILocation(line: 403, column: 48, scope: !731)
!763 = !DILocation(line: 403, column: 26, scope: !731)
!764 = !DILocation(line: 404, column: 26, scope: !731)
!765 = !DILocation(line: 404, column: 18, scope: !731)
!766 = !DILocation(line: 407, column: 48, scope: !731)
!767 = !DILocation(line: 407, column: 26, scope: !731)
!768 = !DILocation(line: 408, column: 27, scope: !731)
!769 = !DILocation(line: 408, column: 18, scope: !731)
!770 = !DILocation(line: 411, column: 14, scope: !731)
!771 = !DILocation(line: 414, column: 14, scope: !731)
!772 = !DILocation(line: 414, column: 11, scope: !731)
!773 = !DILocation(line: 414, column: 5, scope: !731)
!774 = !DILocation(line: 416, column: 44, scope: !731)
!775 = !DILocation(line: 416, column: 75, scope: !731)
!776 = !DILocation(line: 416, column: 59, scope: !731)
!777 = !DILocation(line: 416, column: 25, scope: !731)
!778 = !DILocation(line: 416, column: 23, scope: !731)
!779 = !DILocation(line: 418, column: 41, scope: !731)
!780 = !DILocation(line: 418, column: 23, scope: !731)
!781 = !DILocation(line: 419, column: 9, scope: !731)
!782 = !DILocation(line: 425, column: 44, scope: !731)
!783 = !DILocation(line: 425, column: 23, scope: !731)
!784 = !DILocation(line: 426, column: 41, scope: !731)
!785 = !DILocation(line: 426, column: 23, scope: !731)
!786 = !DILocation(line: 427, column: 9, scope: !731)
!787 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x", scope: null, file: !712, line: 448, type: !5, scopeLine: 448, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!788 = !DILocation(line: 448, column: 31, scope: !789)
!789 = !DILexicalBlockFile(scope: !787, file: !712, discriminator: 0)
!790 = !DILocation(line: 453, column: 5, scope: !789)
!791 = !DILocation(line: 456, column: 19, scope: !789)
!792 = !DILocation(line: 456, column: 17, scope: !789)
!793 = !DILocation(line: 461, column: 5, scope: !789)
!794 = !DILocation(line: 462, column: 28, scope: !789)
!795 = !DILocation(line: 462, column: 5, scope: !789)
!796 = !DILocation(line: 463, column: 5, scope: !789)
!797 = !DILocation(line: 464, column: 9, scope: !789)
!798 = !DILocation(line: 464, column: 10, scope: !789)
!799 = !DILocation(line: 464, column: 7, scope: !789)
!800 = !DILocation(line: 448, column: 1, scope: !789)
!801 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_send_data", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_send_data", scope: null, file: !712, line: 476, type: !5, scopeLine: 476, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!802 = !DILocation(line: 494, column: 9, scope: !803)
!803 = !DILexicalBlockFile(scope: !801, file: !712, discriminator: 0)
!804 = !DILocation(line: 478, column: 9, scope: !803)
!805 = !DILocation(line: 478, column: 13, scope: !803)
!806 = !DILocation(line: 478, column: 11, scope: !803)
!807 = !DILocation(line: 478, column: 5, scope: !803)
!808 = !DILocation(line: 479, column: 9, scope: !803)
!809 = !DILocation(line: 480, column: 32, scope: !803)
!810 = !DILocation(line: 480, column: 9, scope: !803)
!811 = !DILocation(line: 481, column: 17, scope: !803)
!812 = !DILocation(line: 481, column: 15, scope: !803)
!813 = !DILocation(line: 481, column: 9, scope: !803)
!814 = !DILocation(line: 482, column: 13, scope: !803)
!815 = !DILocation(line: 483, column: 51, scope: !803)
!816 = !DILocation(line: 483, column: 29, scope: !803)
!817 = !DILocation(line: 483, column: 27, scope: !803)
!818 = !DILocation(line: 485, column: 13, scope: !803)
!819 = !DILocation(line: 486, column: 51, scope: !803)
!820 = !DILocation(line: 486, column: 29, scope: !803)
!821 = !DILocation(line: 486, column: 27, scope: !803)
!822 = !DILocation(line: 488, column: 13, scope: !803)
!823 = !DILocation(line: 488, column: 14, scope: !803)
!824 = !DILocation(line: 488, column: 11, scope: !803)
!825 = !DILocation(line: 494, column: 30, scope: !803)
!826 = !DILocation(line: 496, column: 14, scope: !803)
!827 = !DILocation(line: 496, column: 25, scope: !803)
!828 = !DILocation(line: 496, column: 22, scope: !803)
!829 = !DILocation(line: 496, column: 9, scope: !803)
!830 = !DILocation(line: 497, column: 13, scope: !803)
!831 = !DILocation(line: 498, column: 13, scope: !803)
!832 = !DILocation(line: 499, column: 13, scope: !803)
!833 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl", scope: null, file: !712, line: 505, type: !5, scopeLine: 505, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!834 = !DILocation(line: 524, column: 13, scope: !835)
!835 = !DILexicalBlockFile(scope: !833, file: !712, discriminator: 0)
!836 = !DILocation(line: 506, column: 14, scope: !835)
!837 = !DILocation(line: 506, column: 11, scope: !835)
!838 = !DILocation(line: 506, column: 5, scope: !835)
!839 = !DILocation(line: 508, column: 9, scope: !835)
!840 = !DILocation(line: 509, column: 32, scope: !835)
!841 = !DILocation(line: 509, column: 9, scope: !835)
!842 = !DILocation(line: 510, column: 9, scope: !835)
!843 = !DILocation(line: 514, column: 13, scope: !835)
!844 = !DILocation(line: 514, column: 17, scope: !835)
!845 = !DILocation(line: 514, column: 15, scope: !835)
!846 = !DILocation(line: 514, column: 9, scope: !835)
!847 = !DILocation(line: 518, column: 13, scope: !835)
!848 = !DILocation(line: 519, column: 36, scope: !835)
!849 = !DILocation(line: 519, column: 13, scope: !835)
!850 = !DILocation(line: 520, column: 13, scope: !835)
!851 = !DILocation(line: 524, column: 34, scope: !835)
!852 = !DILocation(line: 526, column: 18, scope: !835)
!853 = !DILocation(line: 526, column: 29, scope: !835)
!854 = !DILocation(line: 526, column: 26, scope: !835)
!855 = !DILocation(line: 526, column: 13, scope: !835)
!856 = !DILocation(line: 529, column: 17, scope: !835)
!857 = !DILocation(line: 530, column: 17, scope: !835)
!858 = !DILocation(line: 531, column: 17, scope: !835)
!859 = !DILocation(line: 534, column: 17, scope: !835)
!860 = !DILocation(line: 535, column: 40, scope: !835)
!861 = !DILocation(line: 535, column: 17, scope: !835)
!862 = !DILocation(line: 536, column: 17, scope: !835)
!863 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.d2h_configure", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.d2h_configure", scope: null, file: !712, line: 593, type: !5, scopeLine: 593, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!864 = !DILocation(line: 617, column: 26, scope: !865)
!865 = !DILexicalBlockFile(scope: !863, file: !712, discriminator: 0)
!866 = !DILocation(line: 612, column: 47, scope: !865)
!867 = !DILocation(line: 612, column: 27, scope: !865)
!868 = !DILocation(line: 602, column: 5, scope: !865)
!869 = !DILocation(line: 601, column: 5, scope: !865)
!870 = !DILocation(line: 599, column: 5, scope: !865)
!871 = !DILocation(line: 598, column: 5, scope: !865)
!872 = !DILocation(line: 596, column: 5, scope: !865)
!873 = !DILocation(line: 595, column: 5, scope: !865)
!874 = !DILocation(line: 593, column: 86, scope: !865)
!875 = !DILocation(line: 593, column: 70, scope: !865)
!876 = !DILocation(line: 593, column: 60, scope: !865)
!877 = !DILocation(line: 593, column: 52, scope: !865)
!878 = !DILocation(line: 593, column: 44, scope: !865)
!879 = !DILocation(line: 593, column: 35, scope: !865)
!880 = !DILocation(line: 593, column: 26, scope: !865)
!881 = !DILocation(line: 593, column: 18, scope: !865)
!882 = !DILocation(line: 595, column: 26, scope: !865)
!883 = !DILocation(line: 596, column: 26, scope: !865)
!884 = !DILocation(line: 598, column: 23, scope: !865)
!885 = !DILocation(line: 599, column: 23, scope: !865)
!886 = !DILocation(line: 599, column: 28, scope: !865)
!887 = !DILocation(line: 599, column: 26, scope: !865)
!888 = !DILocation(line: 599, column: 29, scope: !865)
!889 = !DILocation(line: 601, column: 24, scope: !865)
!890 = !DILocation(line: 602, column: 24, scope: !865)
!891 = !DILocation(line: 602, column: 29, scope: !865)
!892 = !DILocation(line: 602, column: 27, scope: !865)
!893 = !DILocation(line: 602, column: 30, scope: !865)
!894 = !DILocation(line: 611, column: 20, scope: !865)
!895 = !DILocation(line: 612, column: 11, scope: !865)
!896 = !DILocation(line: 612, column: 18, scope: !865)
!897 = !DILocation(line: 612, column: 15, scope: !865)
!898 = !DILocation(line: 612, column: 32, scope: !865)
!899 = !DILocation(line: 612, column: 39, scope: !865)
!900 = !DILocation(line: 612, column: 36, scope: !865)
!901 = !DILocation(line: 612, column: 52, scope: !865)
!902 = !DILocation(line: 612, column: 59, scope: !865)
!903 = !DILocation(line: 612, column: 56, scope: !865)
!904 = !DILocation(line: 612, column: 5, scope: !865)
!905 = !DILocation(line: 613, column: 24, scope: !865)
!906 = !DILocation(line: 616, column: 15, scope: !865)
!907 = !DILocation(line: 617, column: 11, scope: !865)
!908 = !DILocation(line: 617, column: 18, scope: !865)
!909 = !DILocation(line: 617, column: 15, scope: !865)
!910 = !DILocation(line: 617, column: 30, scope: !865)
!911 = !DILocation(line: 617, column: 5, scope: !865)
!912 = !DILocation(line: 618, column: 19, scope: !865)
!913 = !DILocation(line: 621, column: 9, scope: !865)
!914 = !DILocation(line: 621, column: 5, scope: !865)
!915 = !DILocation(line: 627, column: 9, scope: !865)
!916 = !DILocation(line: 629, column: 13, scope: !865)
!917 = !DILocation(line: 629, column: 25, scope: !865)
!918 = !DILocation(line: 629, column: 21, scope: !865)
!919 = !DILocation(line: 629, column: 9, scope: !865)
!920 = !DILocation(line: 632, column: 13, scope: !865)
!921 = !DILocation(line: 636, column: 13, scope: !865)
!922 = !DILocation(line: 641, column: 9, scope: !865)
!923 = !DILocation(line: 646, column: 13, scope: !865)
!924 = !DILocation(line: 646, column: 9, scope: !865)
!925 = !DILocation(line: 647, column: 30, scope: !865)
!926 = !DILocation(line: 647, column: 35, scope: !865)
!927 = !DILocation(line: 647, column: 46, scope: !865)
!928 = !DILocation(line: 647, column: 50, scope: !865)
!929 = !DILocation(line: 647, column: 54, scope: !865)
!930 = !DILocation(line: 647, column: 57, scope: !865)
!931 = !DILocation(line: 647, column: 60, scope: !865)
!932 = !DILocation(line: 647, column: 63, scope: !865)
!933 = !DILocation(line: 647, column: 13, scope: !865)
!934 = !DILocation(line: 661, column: 9, scope: !865)
!935 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit", scope: null, file: !672, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!936 = !DILocation(line: 43, column: 3, scope: !937)
!937 = !DILexicalBlockFile(scope: !935, file: !672, discriminator: 0)
!938 = !DILocation(line: 41, column: 3, scope: !937)
!939 = !DILocation(line: 40, column: 3, scope: !937)
!940 = !DILocation(line: 39, column: 9, scope: !937)
!941 = !DILocation(line: 40, column: 23, scope: !937)
!942 = !DILocation(line: 41, column: 70, scope: !937)
!943 = !DILocation(line: 41, column: 68, scope: !937)
!944 = !DILocation(line: 43, column: 27, scope: !937)
!945 = !DILocation(line: 43, column: 15, scope: !937)
!946 = !DILocation(line: 44, column: 15, scope: !937)
!947 = !DILocation(line: 44, column: 21, scope: !937)
!948 = !DILocation(line: 44, column: 27, scope: !937)
!949 = !DILocation(line: 44, column: 3, scope: !937)
!950 = !DILocation(line: 39, column: 1, scope: !937)
!951 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord", scope: null, file: !689, line: 4, type: !5, scopeLine: 4, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!952 = !DILocation(line: 5, column: 10, scope: !953)
!953 = !DILexicalBlockFile(scope: !951, file: !689, discriminator: 0)
!954 = !DILocation(line: 5, column: 67, scope: !953)
!955 = !DILocation(line: 5, column: 3, scope: !953)
!956 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord", scope: null, file: !689, line: 8, type: !5, scopeLine: 8, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!957 = !DILocation(line: 9, column: 10, scope: !958)
!958 = !DILexicalBlockFile(scope: !956, file: !689, discriminator: 0)
!959 = !DILocation(line: 9, column: 67, scope: !958)
!960 = !DILocation(line: 9, column: 3, scope: !958)
!961 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord", scope: null, file: !700, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!962 = !DILocation(line: 50, column: 3, scope: !963)
!963 = !DILexicalBlockFile(scope: !961, file: !700, discriminator: 0)
!964 = !DILocation(line: 43, column: 21, scope: !963)
!965 = !DILocation(line: 50, column: 57, scope: !963)
!966 = !DILocation(line: 50, column: 68, scope: !963)
!967 = !DILocation(line: 50, column: 41, scope: !963)
!968 = !DILocation(line: 50, column: 19, scope: !963)
!969 = !DILocation(line: 52, column: 10, scope: !963)
!970 = !DILocation(line: 52, column: 18, scope: !963)
!971 = !DILocation(line: 48, column: 22, scope: !963)
!972 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr", linkageName: "sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr", scope: null, file: !973, line: 11, type: !5, scopeLine: 11, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!973 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/input_queue_config.csl", directory: "")
!974 = !DILocation(line: 11, column: 32, scope: !975)
!975 = !DILexicalBlockFile(scope: !972, file: !973, discriminator: 0)
!976 = !DILocation(line: 12, column: 80, scope: !975)
!977 = !DILocation(line: 12, column: 69, scope: !975)
!978 = !DILocation(line: 12, column: 39, scope: !975)
!979 = !DILocation(line: 12, column: 3, scope: !975)
!980 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue", linkageName: "sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue", scope: null, file: !973, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!981 = !DILocation(line: 46, column: 3, scope: !982)
!982 = !DILexicalBlockFile(scope: !980, file: !973, discriminator: 0)
!983 = !DILocation(line: 45, column: 3, scope: !982)
!984 = !DILocation(line: 39, column: 42, scope: !982)
!985 = !DILocation(line: 39, column: 34, scope: !982)
!986 = !DILocation(line: 39, column: 24, scope: !982)
!987 = !DILocation(line: 45, column: 44, scope: !982)
!988 = !DILocation(line: 45, column: 16, scope: !982)
!989 = !DILocation(line: 46, column: 30, scope: !982)
!990 = !DILocation(line: 46, column: 18, scope: !982)
!991 = !DILocation(line: 56, column: 9, scope: !982)
!992 = !DILocation(line: 56, column: 5, scope: !982)
!993 = !DILocation(line: 58, column: 13, scope: !982)
!994 = !DILocation(line: 58, column: 17, scope: !982)
!995 = !DILocation(line: 58, column: 11, scope: !982)
!996 = !DILocation(line: 61, column: 13, scope: !982)
!997 = !DILocation(line: 61, column: 17, scope: !982)
!998 = !DILocation(line: 61, column: 11, scope: !982)
!999 = !DILocation(line: 66, column: 9, scope: !982)
!1000 = !DILocation(line: 66, column: 13, scope: !982)
!1001 = !DILocation(line: 66, column: 7, scope: !982)
!1002 = !DILocation(line: 68, column: 9, scope: !982)
!1003 = !DILocation(line: 68, column: 24, scope: !982)
!1004 = !DILocation(line: 68, column: 13, scope: !982)
!1005 = !DILocation(line: 68, column: 7, scope: !982)
!1006 = !DILocation(line: 70, column: 15, scope: !982)
!1007 = !DILocation(line: 70, column: 21, scope: !982)
!1008 = !DILocation(line: 70, column: 3, scope: !982)
!1009 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr", linkageName: "sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr", scope: null, file: !1010, line: 11, type: !5, scopeLine: 11, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1010 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/output_queue_config.csl", directory: "")
!1011 = !DILocation(line: 11, column: 33, scope: !1012)
!1012 = !DILexicalBlockFile(scope: !1009, file: !1010, discriminator: 0)
!1013 = !DILocation(line: 12, column: 82, scope: !1012)
!1014 = !DILocation(line: 12, column: 40, scope: !1012)
!1015 = !DILocation(line: 12, column: 3, scope: !1012)
!1016 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue", linkageName: "sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue", scope: null, file: !1010, line: 31, type: !5, scopeLine: 31, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1017 = !DILocation(line: 38, column: 3, scope: !1018)
!1018 = !DILexicalBlockFile(scope: !1016, file: !1010, discriminator: 0)
!1019 = !DILocation(line: 37, column: 3, scope: !1018)
!1020 = !DILocation(line: 31, column: 35, scope: !1018)
!1021 = !DILocation(line: 31, column: 25, scope: !1018)
!1022 = !DILocation(line: 37, column: 45, scope: !1018)
!1023 = !DILocation(line: 37, column: 16, scope: !1018)
!1024 = !DILocation(line: 38, column: 30, scope: !1018)
!1025 = !DILocation(line: 38, column: 18, scope: !1018)
!1026 = !DILocation(line: 41, column: 9, scope: !1018)
!1027 = !DILocation(line: 41, column: 13, scope: !1018)
!1028 = !DILocation(line: 41, column: 7, scope: !1018)
!1029 = !DILocation(line: 43, column: 9, scope: !1018)
!1030 = !DILocation(line: 43, column: 24, scope: !1018)
!1031 = !DILocation(line: 43, column: 13, scope: !1018)
!1032 = !DILocation(line: 43, column: 27, scope: !1018)
!1033 = !DILocation(line: 43, column: 7, scope: !1018)
!1034 = !DILocation(line: 45, column: 15, scope: !1018)
!1035 = !DILocation(line: 45, column: 21, scope: !1018)
!1036 = !DILocation(line: 45, column: 3, scope: !1018)
!1037 = !DILocation(line: 31, column: 1, scope: !1018)
!1038 = distinct !DISubprogram(name: ".get_tensor_ptr", linkageName: ".get_tensor_ptr", scope: null, file: !4, line: 1, type: !5, scopeLine: 1, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1039 = !DILocation(line: 1, column: 1, scope: !1040)
!1040 = !DILexicalBlockFile(scope: !1038, file: !4, discriminator: 0)
!1041 = distinct !DISubprogram(name: "__generic0sys_mod.sys_mod.tile_config.queue_flush.exit", linkageName: "__generic0sys_mod.sys_mod.tile_config.queue_flush.exit", scope: null, file: !1042, line: 12, type: !5, scopeLine: 12, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1042 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/queue_flush.csl", directory: "")
!1043 = !DILocation(line: 24, column: 3, scope: !1044)
!1044 = !DILexicalBlockFile(scope: !1041, file: !1042, discriminator: 0)
!1045 = !DILocation(line: 12, column: 1, scope: !1044)
!1046 = distinct !DISubprogram(name: "__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position", linkageName: "__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position", scope: null, file: !1047, line: 30, type: !5, scopeLine: 30, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1047 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/switch_config.csl", directory: "")
!1048 = !DILocation(line: 34, column: 3, scope: !1049)
!1049 = !DILexicalBlockFile(scope: !1046, file: !1047, discriminator: 0)
!1050 = !DILocation(line: 32, column: 3, scope: !1049)
!1051 = !DILocation(line: 30, column: 27, scope: !1049)
!1052 = !DILocation(line: 33, column: 7, scope: !1049)
!1053 = !DILocation(line: 34, column: 36, scope: !1049)
!1054 = !DILocation(line: 34, column: 24, scope: !1049)
!1055 = !DILocation(line: 35, column: 3, scope: !1049)
!1056 = !DILocation(line: 35, column: 18, scope: !1049)
!1057 = !DILocation(line: 36, column: 15, scope: !1049)
!1058 = !DILocation(line: 36, column: 21, scope: !1049)
!1059 = !DILocation(line: 36, column: 3, scope: !1049)
!1060 = !DILocation(line: 30, column: 1, scope: !1049)
!1061 = distinct !DISubprogram(name: "__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", linkageName: "__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", scope: null, file: !1062, line: 96, type: !5, scopeLine: 96, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1062 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/color_config.csl", directory: "")
!1063 = !DILocation(line: 99, column: 3, scope: !1064)
!1064 = !DILexicalBlockFile(scope: !1061, file: !1062, discriminator: 0)
!1065 = !DILocation(line: 98, column: 3, scope: !1064)
!1066 = !DILocation(line: 96, column: 17, scope: !1064)
!1067 = !DILocation(line: 98, column: 16, scope: !1064)
!1068 = !DILocation(line: 99, column: 29, scope: !1064)
!1069 = !DILocation(line: 99, column: 17, scope: !1064)
!1070 = !DILocation(line: 100, column: 13, scope: !1064)
!1071 = !DILocation(line: 100, column: 21, scope: !1064)
!1072 = !DILocation(line: 100, column: 11, scope: !1064)
!1073 = !DILocation(line: 104, column: 7, scope: !1064)
!1074 = !DILocation(line: 104, column: 50, scope: !1064)
!1075 = !DILocation(line: 104, column: 18, scope: !1064)
!1076 = !DILocation(line: 104, column: 15, scope: !1064)
!1077 = !DILocation(line: 121, column: 7, scope: !1064)
!1078 = !DILocation(line: 121, column: 50, scope: !1064)
!1079 = !DILocation(line: 121, column: 18, scope: !1064)
!1080 = !DILocation(line: 121, column: 15, scope: !1064)
!1081 = !DILocation(line: 128, column: 15, scope: !1064)
!1082 = !DILocation(line: 128, column: 21, scope: !1064)
!1083 = !DILocation(line: 128, column: 3, scope: !1064)
!1084 = !DILocation(line: 96, column: 1, scope: !1064)
!1085 = distinct !DISubprogram(name: "__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", linkageName: "__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", scope: null, file: !1062, line: 96, type: !5, scopeLine: 96, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1086 = !DILocation(line: 99, column: 3, scope: !1087)
!1087 = !DILexicalBlockFile(scope: !1085, file: !1062, discriminator: 0)
!1088 = !DILocation(line: 98, column: 3, scope: !1087)
!1089 = !DILocation(line: 96, column: 17, scope: !1087)
!1090 = !DILocation(line: 98, column: 16, scope: !1087)
!1091 = !DILocation(line: 99, column: 29, scope: !1087)
!1092 = !DILocation(line: 99, column: 17, scope: !1087)
!1093 = !DILocation(line: 100, column: 13, scope: !1087)
!1094 = !DILocation(line: 100, column: 21, scope: !1087)
!1095 = !DILocation(line: 100, column: 11, scope: !1087)
!1096 = !DILocation(line: 104, column: 7, scope: !1087)
!1097 = !DILocation(line: 104, column: 50, scope: !1087)
!1098 = !DILocation(line: 104, column: 18, scope: !1087)
!1099 = !DILocation(line: 104, column: 15, scope: !1087)
!1100 = !DILocation(line: 121, column: 7, scope: !1087)
!1101 = !DILocation(line: 121, column: 50, scope: !1087)
!1102 = !DILocation(line: 121, column: 18, scope: !1087)
!1103 = !DILocation(line: 121, column: 15, scope: !1087)
!1104 = !DILocation(line: 128, column: 15, scope: !1087)
!1105 = !DILocation(line: 128, column: 21, scope: !1087)
!1106 = !DILocation(line: 128, column: 3, scope: !1087)
!1107 = !DILocation(line: 96, column: 1, scope: !1087)
!1108 = distinct !DISubprogram(name: "__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", linkageName: "__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", scope: null, file: !1062, line: 60, type: !5, scopeLine: 60, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1109 = !DILocation(line: 61, column: 3, scope: !1110)
!1110 = !DILexicalBlockFile(scope: !1108, file: !1062, discriminator: 0)
!1111 = !DILocation(line: 60, column: 46, scope: !1110)
!1112 = !DILocation(line: 61, column: 16, scope: !1110)
!1113 = !DILocation(line: 72, column: 5, scope: !1110)
!1114 = !DILocation(line: 72, column: 12, scope: !1110)
!1115 = !DILocation(line: 74, column: 10, scope: !1110)
!1116 = !DILocation(line: 74, column: 3, scope: !1110)
!1117 = distinct !DISubprogram(name: "__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes", linkageName: "__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes", scope: null, file: !1062, line: 77, type: !5, scopeLine: 77, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1118 = !DILocation(line: 78, column: 3, scope: !1119)
!1119 = !DILexicalBlockFile(scope: !1117, file: !1062, discriminator: 0)
!1120 = !DILocation(line: 77, column: 46, scope: !1119)
!1121 = !DILocation(line: 78, column: 16, scope: !1119)
!1122 = !DILocation(line: 86, column: 5, scope: !1119)
!1123 = !DILocation(line: 86, column: 12, scope: !1119)
!1124 = !DILocation(line: 91, column: 10, scope: !1119)
!1125 = !DILocation(line: 91, column: 3, scope: !1119)
!1126 = distinct !DISubprogram(name: "__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", linkageName: "__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", scope: null, file: !1062, line: 60, type: !5, scopeLine: 60, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1127 = !DILocation(line: 61, column: 3, scope: !1128)
!1128 = !DILexicalBlockFile(scope: !1126, file: !1062, discriminator: 0)
!1129 = !DILocation(line: 60, column: 46, scope: !1128)
!1130 = !DILocation(line: 61, column: 16, scope: !1128)
!1131 = !DILocation(line: 63, column: 5, scope: !1128)
!1132 = !DILocation(line: 63, column: 12, scope: !1128)
!1133 = !DILocation(line: 74, column: 10, scope: !1128)
!1134 = !DILocation(line: 74, column: 3, scope: !1128)
!1135 = distinct !DISubprogram(name: "__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction", linkageName: "__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction", scope: null, file: !1062, line: 52, type: !5, scopeLine: 52, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1136 = !DILocation(line: 55, column: 3, scope: !1137)
!1137 = !DILexicalBlockFile(scope: !1135, file: !1062, discriminator: 0)
!1138 = !DILocation(line: 54, column: 3, scope: !1137)
!1139 = !DILocation(line: 52, column: 23, scope: !1137)
!1140 = !DILocation(line: 54, column: 16, scope: !1137)
!1141 = !DILocation(line: 55, column: 29, scope: !1137)
!1142 = !DILocation(line: 55, column: 17, scope: !1137)
!1143 = !DILocation(line: 56, column: 3, scope: !1137)
!1144 = !DILocation(line: 56, column: 11, scope: !1137)
!1145 = !DILocation(line: 57, column: 15, scope: !1137)
!1146 = !DILocation(line: 57, column: 21, scope: !1137)
!1147 = !DILocation(line: 57, column: 3, scope: !1137)
!1148 = !DILocation(line: 52, column: 1, scope: !1137)
!1149 = distinct !DISubprogram(name: "__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction", linkageName: "__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction", scope: null, file: !1062, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1150 = !DILocation(line: 23, column: 3, scope: !1151)
!1151 = !DILexicalBlockFile(scope: !1149, file: !1062, discriminator: 0)
!1152 = !DILocation(line: 22, column: 3, scope: !1151)
!1153 = !DILocation(line: 20, column: 21, scope: !1151)
!1154 = !DILocation(line: 22, column: 16, scope: !1151)
!1155 = !DILocation(line: 23, column: 29, scope: !1151)
!1156 = !DILocation(line: 23, column: 17, scope: !1151)
!1157 = !DILocation(line: 24, column: 3, scope: !1151)
!1158 = !DILocation(line: 24, column: 11, scope: !1151)
!1159 = !DILocation(line: 25, column: 15, scope: !1151)
!1160 = !DILocation(line: 25, column: 21, scope: !1151)
!1161 = !DILocation(line: 25, column: 3, scope: !1151)
!1162 = !DILocation(line: 20, column: 1, scope: !1151)
module asm ".section \22.pe_debug_info\22, \22\22"
module asm ".section \22.note\22, \22\22"
