; ModuleID = './layout.csl'
source_filename = "./layout.csl"
target datalayout = "e-ni:0-p:16:16-i1:16-i16:16-i32:32-i64:64-f32:32-f64:64"
target triple = "cs_sdr-cerebras-csos"

@"$$csl_base_address$$1$$a" = dso_local global [8 x i16] zeroinitializer, align 4
@"$$csl_base_address$$2$$b" = dso_local global [8 x i16] zeroinitializer, align 4
@g = internal global [8 x i16] zeroinitializer, align 4
@"$$csl_base_address$$0$$c" = dso_local global [80 x i16] zeroinitializer, align 4
@d = internal global [8 x i16] zeroinitializer, align 4
@af = internal global [8 x half] zeroinitializer, align 4
@bf = internal global [8 x half] zeroinitializer, align 4
@gf = internal global [8 x half] zeroinitializer, align 4
@cf = internal global [16 x half] zeroinitializer, align 4
@mark = internal global [16 x i16] zeroinitializer, align 4
@p_a = internal global i16* getelementptr inbounds ([8 x i16], [8 x i16]* @"$$csl_base_address$$1$$a", i32 0, i32 0), align 4
@p_b = internal global i16* getelementptr inbounds ([8 x i16], [8 x i16]* @"$$csl_base_address$$2$$b", i32 0, i32 0), align 4
@p_g = internal global i16* getelementptr inbounds ([8 x i16], [8 x i16]* @g, i32 0, i32 0), align 4
@p_c = internal global i16* getelementptr inbounds ([80 x i16], [80 x i16]* @"$$csl_base_address$$0$$c", i32 0, i32 0), align 4
@p_d = internal global i16* getelementptr inbounds ([8 x i16], [8 x i16]* @d, i32 0, i32 0), align 4
@p_af = internal global half* getelementptr inbounds ([8 x half], [8 x half]* @af, i32 0, i32 0), align 4
@p_bf = internal global half* getelementptr inbounds ([8 x half], [8 x half]* @bf, i32 0, i32 0), align 4
@p_gf = internal global half* getelementptr inbounds ([8 x half], [8 x half]* @gf, i32 0, i32 0), align 4
@p_cf = internal global half* getelementptr inbounds ([16 x half], [16 x half]* @cf, i32 0, i32 0), align 4
@p_mark = internal global i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i32 0, i32 0), align 4
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
@"$$csl_base_address$$5$$sys_mod.sys_mod.memcpyh2d_mod_1.dummy" = dso_local constant [1 x i16] zeroinitializer, align 4
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
@"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.dummy" = dso_local constant [1 x i16] zeroinitializer, align 4
@sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd = internal global <{ i16, i16, i16, i16 }> <{ i16 1, i16 lshr (i16 ptrtoint ([1 x i16]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.dummy" to i16), i16 1), i16 143, i16 16 }>, align 4
@"$$csl_base_address$$3$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11" = dso_local global [1 x i32] [i32 190812745], align 4
@sys_mod.sys_mod.memcpyd2h_mod.ctrl_1 = internal global [1 x i32] [i32 157258313], align 4
@sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd = internal global <{ i16, i16, i16, i16 }> <{ i16 1, i16 lshr (i16 ptrtoint ([1 x i32]* @"$$csl_base_address$$3$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11" to i16), i16 1), i16 143, i16 16 }>, align 4
@"$$csl_base_address$$7$$sys_mod.sys_mod.memcpyd2h_mod.sw_td" = dso_local global [2 x i32] zeroinitializer, align 4
@"$$csl_base_address$$6$$sys_mod.sys_mod.memcpyd2h_mod.teardown_buf" = dso_local constant [1 x i32] [i32 165646921], align 4
@__dsr_lowmeminit_ = internal constant <{ i16, i16, i16, i16 }> <{ i16 8, i16 lshr (i16 ptrtoint ([80 x i16]* @"$$csl_base_address$$0$$c" to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__0 = internal constant <{ i16, i16, i16, i16 }> <{ i16 8, i16 lshr (i16 ptrtoint ([8 x i16]* @"$$csl_base_address$$1$$a" to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__1 = internal constant <{ i16, i16, i16, i16 }> <{ i16 8, i16 lshr (i16 ptrtoint ([8 x i16]* @"$$csl_base_address$$2$$b" to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__2 = internal constant <{ i16, i16, i16, i16 }> <{ i16 8, i16 lshr (i16 ptrtoint (i16* getelementptr inbounds ([80 x i16], [80 x i16]* @"$$csl_base_address$$0$$c", i32 0, i64 8) to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__3 = internal constant <{ i16, i16, i16, i16 }> <{ i16 8, i16 lshr (i16 ptrtoint (i16* getelementptr inbounds ([80 x i16], [80 x i16]* @"$$csl_base_address$$0$$c", i32 0, i64 16) to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__4 = internal constant <{ i16, i16, i16, i16 }> <{ i16 8, i16 lshr (i16 ptrtoint (i16* getelementptr inbounds ([80 x i16], [80 x i16]* @"$$csl_base_address$$0$$c", i32 0, i64 24) to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__5 = internal constant <{ i16, i16, i16, i16 }> <{ i16 8, i16 lshr (i16 ptrtoint (i16* getelementptr inbounds ([80 x i16], [80 x i16]* @"$$csl_base_address$$0$$c", i32 0, i64 32) to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__6 = internal constant <{ i16, i16, i16, i16 }> <{ i16 8, i16 lshr (i16 ptrtoint (i16* getelementptr inbounds ([80 x i16], [80 x i16]* @"$$csl_base_address$$0$$c", i32 0, i64 40) to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__7 = internal constant <{ i16, i16, i16, i16 }> <{ i16 8, i16 lshr (i16 ptrtoint (i16* getelementptr inbounds ([80 x i16], [80 x i16]* @"$$csl_base_address$$0$$c", i32 0, i64 48) to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__8 = internal constant <{ i16, i16, i16, i16 }> <{ i16 8, i16 lshr (i16 ptrtoint (i16* getelementptr inbounds ([80 x i16], [80 x i16]* @"$$csl_base_address$$0$$c", i32 0, i64 56) to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__9 = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 62, i16 142, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__10 = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 4127, i16 142, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__11 = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 lshr (i16 ptrtoint ([1 x i32]* @"$$csl_base_address$$6$$sys_mod.sys_mod.memcpyd2h_mod.teardown_buf" to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__12 = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 4149, i16 142, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__13 = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 4096, i16 142, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__14 = internal constant <{ i16, i16, i16, i16 }> <{ i16 2, i16 4127, i16 142, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__15 = internal constant <{ i16, i16, i16, i16 }> <{ i16 2, i16 lshr (i16 ptrtoint ([2 x i32]* @"$$csl_base_address$$7$$sys_mod.sys_mod.memcpyd2h_mod.sw_td" to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4

declare i8* @malloc(i64)

declare void @free(i8*)

define internal void @compute() !dbg !3 {
  store i16 24576, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i1 false), align 2, !dbg !7
  call void @llvm.sdr.lddwds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !9
  call void @llvm.sdr.lds0wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !9
  call void @llvm.sdr.lds1wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__1 to i8*)), !dbg !9
  call void @llvm.sdr.add16.ds0s1(i16 1, i16 1, i16 1), !dbg !9
  store i16 24577, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i2 1), align 2, !dbg !10
  call void @llvm.sdr.lddwds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__2 to i8*)), !dbg !11
  call void @llvm.sdr.lds0wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !11
  call void @llvm.sdr.lds1wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__1 to i8*)), !dbg !11
  call void @llvm.sdr.add16.ds0s1(i16 1, i16 1, i16 1), !dbg !11
  store i16 24578, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i3 2), align 2, !dbg !12
  call void @llvm.sdr.lddwds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__3 to i8*)), !dbg !13
  call void @llvm.sdr.lds0wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !13
  call void @llvm.sdr.lds1wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__1 to i8*)), !dbg !13
  call void @llvm.sdr.add16.ds0s1(i16 1, i16 1, i16 1), !dbg !13
  store i16 24579, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i3 3), align 2, !dbg !14
  call void @llvm.sdr.lds1wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__1 to i8*)), !dbg !15
  call void @llvm.sdr.lddwds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__4 to i8*)), !dbg !15
  call void @llvm.sdr.lds0wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !15
  call void @llvm.sdr.add16.ds0s1(i16 1, i16 1, i16 1), !dbg !15
  store i16 24580, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i4 4), align 2, !dbg !16
  call void @llvm.sdr.lds1wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__1 to i8*)), !dbg !17
  call void @llvm.sdr.lddwds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__5 to i8*)), !dbg !17
  call void @llvm.sdr.lds0wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !17
  call void @llvm.sdr.add16.ds0s1(i16 1, i16 1, i16 1), !dbg !17
  store i16 24581, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i4 5), align 2, !dbg !18
  call void @llvm.sdr.lds1wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__1 to i8*)), !dbg !19
  call void @llvm.sdr.lddwds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__6 to i8*)), !dbg !19
  call void @llvm.sdr.lds0wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !19
  call void @llvm.sdr.add16.ds0s1(i16 1, i16 1, i16 1), !dbg !19
  store i16 24582, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i4 6), align 2, !dbg !20
  call void @llvm.sdr.lds1wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__1 to i8*)), !dbg !21
  call void @llvm.sdr.lddwds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__7 to i8*)), !dbg !21
  call void @llvm.sdr.lds0wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !21
  call void @llvm.sdr.add16.ds0s1(i16 1, i16 1, i16 1), !dbg !21
  store i16 24583, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i4 7), align 2, !dbg !22
  call void @llvm.sdr.lddwds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__8 to i8*)), !dbg !23
  call void @llvm.sdr.lds0wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !23
  call void @llvm.sdr.lds1wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__1 to i8*)), !dbg !23
  call void @llvm.sdr.add16.ds0s1(i16 1, i16 1, i16 1), !dbg !23
  store i16 24584, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i5 8), align 2, !dbg !24
  call void @llvm.sdr.lddwds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__8 to i8*)), !dbg !25
  call void @llvm.sdr.lds0wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !25
  call void @llvm.sdr.lds1wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__1 to i8*)), !dbg !25
  call void @llvm.sdr.add16.ds0s1(i16 1, i16 1, i16 1), !dbg !25
  store i16 24585, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i5 9), align 2, !dbg !26
  call void @llvm.sdr.actvt.r(i16 9), !dbg !27
  ret void, !dbg !28
}

define void @f_exit() #0 !dbg !29 {
  call void @sys_mod.unblock_cmd_stream(), !dbg !30
  ret void, !dbg !32
}

define internal void @sys_mod.sys_nop() !dbg !33 {
  ret void, !dbg !35
}

define internal void @sys_mod.unblock_cmd_stream() !dbg !37 {
  call void @sys_mod.sys_mod.unblock_cmd_stream(), !dbg !38
  ret void, !dbg !40
}

define internal void @sys_mod.sys_mod.unblock_cmd_stream() !dbg !41 {
  call void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream(), !dbg !43
  ret void, !dbg !45
}

define internal void @sys_mod.sys_mod.teardown_h2d() !dbg !46 {
  call void @llvm.sdr.actvt.r(i16 27), !dbg !47
  ret void, !dbg !49
}

define void @sys_mod.sys_mod.f_ublk_c22() #1 !dbg !50 {
  call void @sys_mod.sys_mod.unblock_cmd_stream(), !dbg !51
  ret void, !dbg !53
}

define internal void @sys_mod.sys_mod.teardown_d2h() !dbg !54 {
  call void @llvm.sdr.blk.r(i16 0), !dbg !55
  call void @llvm.sdr.actvt.r(i16 28), !dbg !57
  ret void, !dbg !58
}

define void @sys_mod.sys_mod.f_memcpyh2d() #2 !dbg !59 {
  %1 = alloca float, i16 1, align 4, !dbg !60
  %2 = alloca float, i16 1, align 4, !dbg !62
  %3 = alloca i16, i16 1, align 2, !dbg !63
  %4 = alloca i16, i16 1, align 2, !dbg !64
  %5 = alloca i16, i16 1, align 2, !dbg !65
  %6 = alloca i16, i16 1, align 2, !dbg !66
  %7 = alloca i16, i16 1, align 2, !dbg !67
  %8 = alloca i16, i16 1, align 2, !dbg !68
  %9 = alloca i16, i16 1, align 2, !dbg !69
  %10 = alloca i16, i16 1, align 2, !dbg !70
  %11 = alloca i16, i16 1, align 2, !dbg !71
  %12 = alloca i16, i16 1, align 2, !dbg !72
  %13 = alloca i16, i16 1, align 2, !dbg !73
  %14 = alloca i16*, i16 1, align 8, !dbg !74
  %15 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !75
  %16 = icmp eq i16 %15, 15, !dbg !76
  br i1 %16, label %17, label %18, !dbg !77

17:                                               ; preds = %0
  br label %19, !dbg !77

18:                                               ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !77
  br label %19, !dbg !77

19:                                               ; preds = %17, %18
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %14, align 8, !dbg !74
  %20 = load i16*, i16** %14, align 8, !dbg !78
  %21 = load i16, i16* %20, align 2, !dbg !79
  store i16 %21, i16* %13, align 2, !dbg !73
  %22 = load i16*, i16** %14, align 8, !dbg !80
  %23 = getelementptr i16, i16* %22, i16 1, !dbg !81
  %24 = load i16, i16* %23, align 2, !dbg !81
  store i16 %24, i16* %12, align 2, !dbg !72
  %25 = load i16*, i16** %14, align 8, !dbg !82
  %26 = getelementptr i16, i16* %25, i16 2, !dbg !83
  %27 = load i16, i16* %26, align 2, !dbg !83
  store i16 %27, i16* %11, align 2, !dbg !71
  %28 = load i16*, i16** %14, align 8, !dbg !84
  %29 = getelementptr i16, i16* %28, i16 3, !dbg !85
  %30 = load i16, i16* %29, align 2, !dbg !85
  store i16 %30, i16* %10, align 2, !dbg !70
  %31 = load i16*, i16** %14, align 8, !dbg !86
  %32 = getelementptr i16, i16* %31, i16 4, !dbg !87
  %33 = load i16, i16* %32, align 2, !dbg !87
  store i16 %33, i16* %9, align 2, !dbg !69
  %34 = load i16*, i16** %14, align 8, !dbg !88
  %35 = getelementptr i16, i16* %34, i16 5, !dbg !89
  %36 = load i16, i16* %35, align 2, !dbg !89
  store i16 %36, i16* %8, align 2, !dbg !68
  %37 = load i16*, i16** %14, align 8, !dbg !90
  %38 = getelementptr i16, i16* %37, i16 6, !dbg !91
  %39 = load i16, i16* %38, align 2, !dbg !91
  store i16 %39, i16* %7, align 2, !dbg !67
  %40 = load i16*, i16** %14, align 8, !dbg !92
  %41 = getelementptr i16, i16* %40, i16 7, !dbg !93
  %42 = load i16, i16* %41, align 2, !dbg !93
  store i16 %42, i16* %6, align 2, !dbg !66
  %43 = load i16*, i16** %14, align 8, !dbg !94
  %44 = getelementptr i16, i16* %43, i16 8, !dbg !95
  %45 = load i16, i16* %44, align 2, !dbg !95
  store i16 %45, i16* %5, align 2, !dbg !65
  %46 = load i16*, i16** %14, align 8, !dbg !96
  %47 = getelementptr i16, i16* %46, i16 9, !dbg !97
  %48 = load i16, i16* %47, align 2, !dbg !97
  store i16 %48, i16* %4, align 2, !dbg !64
  %49 = load i16*, i16** %14, align 8, !dbg !98
  %50 = getelementptr i16, i16* %49, i16 10, !dbg !99
  %51 = load i16, i16* %50, align 2, !dbg !99
  store i16 %51, i16* %3, align 2, !dbg !63
  %52 = load i16*, i16** %14, align 8, !dbg !100
  %53 = getelementptr i16, i16* %52, i16 12, !dbg !101
  %54 = load i16, i16* %53, align 2, !dbg !101
  %55 = zext i16 %54 to i32, !dbg !102
  %56 = load i16*, i16** %14, align 8, !dbg !103
  %57 = getelementptr i16, i16* %56, i16 11, !dbg !104
  %58 = load i16, i16* %57, align 2, !dbg !104
  %59 = zext i16 %58 to i32, !dbg !105
  %60 = add i32 %59, 16, !dbg !106
  %61 = shl i32 %55, %60, !dbg !107
  %62 = bitcast i32 %61 to float, !dbg !108
  store float %62, float* %2, align 4, !dbg !62
  %63 = load i16*, i16** %14, align 8, !dbg !109
  %64 = getelementptr i16, i16* %63, i16 14, !dbg !110
  %65 = load i16, i16* %64, align 2, !dbg !110
  %66 = zext i16 %65 to i32, !dbg !111
  %67 = load i16*, i16** %14, align 8, !dbg !112
  %68 = getelementptr i16, i16* %67, i16 13, !dbg !113
  %69 = load i16, i16* %68, align 2, !dbg !113
  %70 = zext i16 %69 to i32, !dbg !114
  %71 = add i32 %70, 16, !dbg !115
  %72 = shl i32 %66, %71, !dbg !116
  %73 = bitcast i32 %72 to float, !dbg !117
  store float %73, float* %1, align 4, !dbg !60
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !118
  %74 = load i16, i16* %13, align 2, !dbg !119
  store i16 %74, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !120
  %75 = load i16, i16* %12, align 2, !dbg !121
  store i16 %75, i16* @sys_mod.sys_mod.memcpyH2D_px, align 2, !dbg !122
  %76 = load i16, i16* %11, align 2, !dbg !123
  store i16 %76, i16* @sys_mod.sys_mod.memcpyH2D_py, align 2, !dbg !124
  %77 = load i16, i16* %10, align 2, !dbg !125
  store i16 %77, i16* @sys_mod.sys_mod.memcpyH2D_w, align 2, !dbg !126
  %78 = load i16, i16* %9, align 2, !dbg !127
  store i16 %78, i16* @sys_mod.sys_mod.memcpyH2D_h, align 2, !dbg !128
  %79 = load i16, i16* %8, align 2, !dbg !129
  store i16 %79, i16* @sys_mod.sys_mod.memcpyH2D_addr, align 2, !dbg !130
  %80 = load i16, i16* %7, align 2, !dbg !131
  store i16 %80, i16* @sys_mod.sys_mod.memcpyH2D_pe_length, align 2, !dbg !132
  %81 = load i16, i16* %6, align 2, !dbg !133
  store i16 %81, i16* @sys_mod.sys_mod.memcpyH2D_is_half, align 2, !dbg !134
  %82 = load i16, i16* %5, align 2, !dbg !135
  store i16 %82, i16* @sys_mod.sys_mod.memcpyH2D_memcpy_optype, align 2, !dbg !136
  %83 = load i16, i16* %4, align 2, !dbg !137
  store i16 %83, i16* @sys_mod.sys_mod.memcpyH2D_row_stride, align 2, !dbg !138
  %84 = load i16, i16* %3, align 2, !dbg !139
  store i16 %84, i16* @sys_mod.sys_mod.memcpyH2D_col_stride, align 2, !dbg !140
  %85 = load float, float* %2, align 4, !dbg !141
  store float %85, float* @sys_mod.sys_mod.memcpyH2D_one_over_row_stride, align 4, !dbg !142
  %86 = load float, float* %1, align 4, !dbg !143
  store float %86, float* @sys_mod.sys_mod.memcpyH2D_one_over_col_stride, align 4, !dbg !144
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !145
  call void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 0, i16 23, i1 true), !dbg !146
  call void @llvm.sdr.blk.r(i16 27), !dbg !147
  call void @llvm.sdr.oqflush(i16 0), !dbg !148
  store i1 true, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !149
  call void @llvm.sdr.blk.r(i16 0), !dbg !150
  ret void, !dbg !151
}

define void @sys_mod.sys_mod.f_memcpyd2h() #3 !dbg !152 {
  %1 = alloca i16, i16 1, align 2, !dbg !153
  %2 = alloca i16, i16 1, align 2, !dbg !155
  %3 = alloca i16, i16 1, align 2, !dbg !156
  %4 = alloca i16, i16 1, align 2, !dbg !157
  %5 = alloca i16, i16 1, align 2, !dbg !158
  %6 = alloca i16, i16 1, align 2, !dbg !159
  %7 = alloca i16, i16 1, align 2, !dbg !160
  %8 = alloca i16, i16 1, align 2, !dbg !161
  %9 = alloca i16*, i16 1, align 8, !dbg !162
  %10 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !163
  %11 = icmp eq i16 %10, 8, !dbg !164
  br i1 %11, label %12, label %13, !dbg !165

12:                                               ; preds = %0
  br label %14, !dbg !165

13:                                               ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !165
  br label %14, !dbg !165

14:                                               ; preds = %12, %13
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %9, align 8, !dbg !162
  %15 = load i16*, i16** %9, align 8, !dbg !166
  %16 = load i16, i16* %15, align 2, !dbg !167
  store i16 %16, i16* %8, align 2, !dbg !161
  %17 = load i16*, i16** %9, align 8, !dbg !168
  %18 = getelementptr i16, i16* %17, i16 1, !dbg !169
  %19 = load i16, i16* %18, align 2, !dbg !169
  store i16 %19, i16* %7, align 2, !dbg !160
  %20 = load i16*, i16** %9, align 8, !dbg !170
  %21 = getelementptr i16, i16* %20, i16 2, !dbg !171
  %22 = load i16, i16* %21, align 2, !dbg !171
  store i16 %22, i16* %6, align 2, !dbg !159
  %23 = load i16*, i16** %9, align 8, !dbg !172
  %24 = getelementptr i16, i16* %23, i16 3, !dbg !173
  %25 = load i16, i16* %24, align 2, !dbg !173
  store i16 %25, i16* %5, align 2, !dbg !158
  %26 = load i16*, i16** %9, align 8, !dbg !174
  %27 = getelementptr i16, i16* %26, i16 4, !dbg !175
  %28 = load i16, i16* %27, align 2, !dbg !175
  store i16 %28, i16* %4, align 2, !dbg !157
  %29 = load i16*, i16** %9, align 8, !dbg !176
  %30 = getelementptr i16, i16* %29, i16 5, !dbg !177
  %31 = load i16, i16* %30, align 2, !dbg !177
  store i16 %31, i16* %3, align 2, !dbg !156
  %32 = load i16*, i16** %9, align 8, !dbg !178
  %33 = getelementptr i16, i16* %32, i16 6, !dbg !179
  %34 = load i16, i16* %33, align 2, !dbg !179
  store i16 %34, i16* %2, align 2, !dbg !155
  %35 = load i16*, i16** %9, align 8, !dbg !180
  %36 = getelementptr i16, i16* %35, i16 7, !dbg !181
  %37 = load i16, i16* %36, align 2, !dbg !181
  store i16 %37, i16* %1, align 2, !dbg !153
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !182
  %38 = load i16, i16* %8, align 2, !dbg !183
  store i16 %38, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !184
  %39 = load i16, i16* %7, align 2, !dbg !185
  store i16 %39, i16* @sys_mod.sys_mod.memcpyD2H_px, align 2, !dbg !186
  %40 = load i16, i16* %6, align 2, !dbg !187
  store i16 %40, i16* @sys_mod.sys_mod.memcpyD2H_py, align 2, !dbg !188
  %41 = load i16, i16* %5, align 2, !dbg !189
  store i16 %41, i16* @sys_mod.sys_mod.memcpyD2H_w, align 2, !dbg !190
  %42 = load i16, i16* %4, align 2, !dbg !191
  store i16 %42, i16* @sys_mod.sys_mod.memcpyD2H_h, align 2, !dbg !192
  %43 = load i16, i16* %3, align 2, !dbg !193
  store i16 %43, i16* @sys_mod.sys_mod.memcpyD2H_addr, align 2, !dbg !194
  %44 = load i16, i16* %2, align 2, !dbg !195
  store i16 %44, i16* @sys_mod.sys_mod.memcpyD2H_pe_length, align 2, !dbg !196
  %45 = load i16, i16* %1, align 2, !dbg !197
  store i16 %45, i16* @sys_mod.sys_mod.memcpyD2H_is_half, align 2, !dbg !198
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !199
  %46 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !200
  call void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 0, i16 %46, i1 false), !dbg !201
  call void @llvm.sdr.oqflush(i16 0), !dbg !202
  store i1 false, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !203
  ret void, !dbg !204
}

define internal void @sys_mod.sys_mod.oq0_teardow_handler() !dbg !205 {
  %1 = load i1, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !206
  br i1 %1, label %2, label %17, !dbg !208

2:                                                ; preds = %0
  %3 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !209
  call void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 0, i16 %3), !dbg !210
  %4 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !211
  %5 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_px, align 2, !dbg !212
  %6 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_py, align 2, !dbg !213
  %7 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_w, align 2, !dbg !214
  %8 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_h, align 2, !dbg !215
  %9 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_addr, align 2, !dbg !216
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_pe_length, align 2, !dbg !217
  %11 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_is_half, align 2, !dbg !218
  %12 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_memcpy_optype, align 2, !dbg !219
  %13 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_row_stride, align 2, !dbg !220
  %14 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_col_stride, align 2, !dbg !221
  %15 = load float, float* @sys_mod.sys_mod.memcpyH2D_one_over_row_stride, align 4, !dbg !222
  %16 = load float, float* @sys_mod.sys_mod.memcpyH2D_one_over_col_stride, align 4, !dbg !223
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure(i16 %4, i16 %5, i16 %6, i16 %7, i16 %8, i16 %9, i16 %10, i16 %11, i16 %12, i16 %13, i16 %14, float %15, float %16), !dbg !224
  br label %26, !dbg !208

17:                                               ; preds = %0
  call void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 0, i16 21), !dbg !225
  %18 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !226
  %19 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_px, align 2, !dbg !227
  %20 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_py, align 2, !dbg !228
  %21 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_w, align 2, !dbg !229
  %22 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_h, align 2, !dbg !230
  %23 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_addr, align 2, !dbg !231
  %24 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_pe_length, align 2, !dbg !232
  %25 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_is_half, align 2, !dbg !233
  call void @sys_mod.sys_mod.memcpyd2h_mod.d2h_configure(i16 %18, i16 %19, i16 %20, i16 %21, i16 %22, i16 %23, i16 %24, i16 %25), !dbg !234
  br label %26, !dbg !208

26:                                               ; preds = %2, %17
  call void @__generic0sys_mod.sys_mod.tile_config.queue_flush.exit(), !dbg !235
  ret void, !dbg !208
}

define internal void @rpc_server(i32* %0) {
  %2 = load i32, i32* %0, align 4
  %3 = add i32 %2, 1
  %4 = getelementptr i32, i32* %0, i32 %3
  %5 = load i32, i32* %4, align 4
  switch i32 %5, label %6 [
    i32 11, label %7
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

define void @sys_mod.sys_mod.f_rpc(i16 %0) #4 !dbg !236 {
  %2 = alloca i16, i16 1, align 2, !dbg !237
  store i16 %0, i16* %2, align 2, !dbg !237
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !239
  %3 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !240
  %4 = icmp sge i16 %3, 4, !dbg !241
  br i1 %4, label %5, label %6, !dbg !242

5:                                                ; preds = %1
  br label %7, !dbg !242

6:                                                ; preds = %1
  call void asm sideeffect "hcf", ""(), !dbg !242
  br label %7, !dbg !242

7:                                                ; preds = %5, %6
  call void @rpc_server(i32* getelementptr inbounds ([32 x i32], [32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32, i32 0, i32 0)), !dbg !243
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !244
  ret void, !dbg !245
}

define internal void @sys_mod.sys_mod.sys_mod.stack_push(i16 %0) !dbg !246 {
  %2 = alloca i16*, i16 1, align 8, !dbg !248
  %3 = alloca i16, i16 1, align 2, !dbg !250
  store i16 %0, i16* %3, align 2, !dbg !250
  %4 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !251
  %5 = icmp slt i16 %4, 32, !dbg !252
  br i1 %5, label %6, label %7, !dbg !253

6:                                                ; preds = %1
  br label %8, !dbg !253

7:                                                ; preds = %1
  call void asm sideeffect "hcf", ""(), !dbg !253
  br label %8, !dbg !253

8:                                                ; preds = %6, %7
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %2, align 8, !dbg !248
  %9 = load i16, i16* %3, align 2, !dbg !254
  %10 = load i16*, i16** %2, align 8, !dbg !255
  %11 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !256
  %12 = getelementptr i16, i16* %10, i16 %11, !dbg !257
  store i16 %9, i16* %12, align 2, !dbg !258
  %13 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !259
  %14 = add i16 %13, 1, !dbg !260
  store i16 %14, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !261
  ret void, !dbg !262
}

define void @sys_mod.sys_mod.sys_mod.f_push(i16 %0, i16 %1) #5 !dbg !263 {
  %3 = alloca i16, i16 1, align 2, !dbg !264
  %4 = alloca i16, i16 1, align 2, !dbg !266
  store i16 %0, i16* %4, align 2, !dbg !266
  store i16 %1, i16* %3, align 2, !dbg !264
  %5 = load i16, i16* %4, align 2, !dbg !267
  call void @sys_mod.sys_mod.sys_mod.stack_push(i16 %5), !dbg !268
  ret void, !dbg !269
}

define internal void @sys_mod.sys_mod.sys_mod.block_cmd_stream() !dbg !270 {
  call void @llvm.sdr.blk.r(i16 1), !dbg !271
  ret void, !dbg !273
}

define internal void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream() !dbg !274 {
  call void @llvm.sdr.ublk.r(i16 1), !dbg !275
  ret void, !dbg !277
}

define void @sys_mod.sys_mod.sys_mod.f_sys_exit() #6 !dbg !278 {
  call void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream(), !dbg !279
  call void @sys_mod.sys_nop(), !dbg !281
  ret void, !dbg !282
}

define void @sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore(i32 %0) #7 !dbg !283 {
  %2 = alloca i32, i16 1, align 4, !dbg !284
  store i32 %0, i32* %2, align 4, !dbg !284
  ret void, !dbg !286
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord() !dbg !287 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord(), !dbg !289
  ret i16 %1, !dbg !291
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord() !dbg !292 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord(), !dbg !293
  ret i16 %1, !dbg !295
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval(i16 %0) !dbg !296 {
  %2 = alloca i16, i16 1, align 2, !dbg !297
  store i16 %0, i16* %2, align 2, !dbg !297
  %3 = load i16, i16* %2, align 2, !dbg !299
  %4 = icmp ult i16 %3, 24, !dbg !300
  br i1 %4, label %5, label %7, !dbg !301

5:                                                ; preds = %10, %11, %1
  %6 = phi i16 [ 0, %10 ], [ 0, %11 ], [ 1, %1 ]
  br label %12, !dbg !301

7:                                                ; preds = %1
  %8 = load i16, i16* %2, align 2, !dbg !302
  %9 = icmp eq i16 31, %8, !dbg !303
  br i1 %9, label %10, label %11, !dbg !304

10:                                               ; preds = %7
  br label %5, !dbg !304

11:                                               ; preds = %7
  call void asm sideeffect "hcf", ""(), !dbg !304
  br label %5, !dbg !304

12:                                               ; preds = %5
  %13 = phi i16 [ %6, %5 ]
  br label %14, !dbg !301

14:                                               ; preds = %12
  ret i16 %13, !dbg !301
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start(i16 %0, i16 %1, i16 %2) !dbg !305 {
  %4 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !306
  %5 = alloca i16, i16 1, align 2, !dbg !308
  %6 = alloca i16, i16 1, align 2, !dbg !309
  %7 = alloca i16, i16 1, align 2, !dbg !310
  store i16 %0, i16* %7, align 2, !dbg !310
  store i16 %1, i16* %6, align 2, !dbg !309
  store i16 %2, i16* %5, align 2, !dbg !308
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !311
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !311
  %10 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !311
  %11 = load i16, i16* %6, align 2, !dbg !312
  store i16 %11, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !313
  store i16 %8, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !313
  store i16 %9, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !313
  store i16 %10, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !313
  %12 = load i16, i16* %7, align 2, !dbg !314
  %13 = call i16* @.get_tensor_ptr(i16 %12), !dbg !315
  %14 = ptrtoint i16* %13 to i16, !dbg !316
  %15 = lshr i16 %14, 1, !dbg !316
  %16 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !306
  store i16 42, i16* %16, align 2, !dbg !306
  %17 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !306
  store i16 %15, i16* %17, align 2, !dbg !306
  %18 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !306
  store i16 143, i16* %18, align 2, !dbg !306
  %19 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !306
  store i16 16, i16* %19, align 2, !dbg !306
  %20 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !317
  %21 = load i16, i16* %20, align 2, !dbg !317
  %22 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !317
  %23 = load i16, i16* %22, align 2, !dbg !317
  %24 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !317
  %25 = load i16, i16* %24, align 2, !dbg !317
  %26 = load i16, i16* %6, align 2, !dbg !318
  %27 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !319
  store i16 %26, i16* %27, align 2, !dbg !319
  %28 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !319
  store i16 %21, i16* %28, align 2, !dbg !319
  %29 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !319
  store i16 %23, i16* %29, align 2, !dbg !319
  %30 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !319
  store i16 %25, i16* %30, align 2, !dbg !319
  %31 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !320
  %32 = load i16, i16* %31, align 2, !dbg !320
  %33 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !320
  %34 = load i16, i16* %33, align 2, !dbg !320
  %35 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !320
  %36 = load i16, i16* %35, align 2, !dbg !320
  %37 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !320
  %38 = load i16, i16* %37, align 2, !dbg !320
  store volatile i16 %32, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !321
  store volatile i16 %34, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !321
  store volatile i16 %36, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !321
  store volatile i16 %38, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !321
  call void asm sideeffect "nop", ""(), !dbg !321
  call void asm sideeffect "nop", ""(), !dbg !321
  %39 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !322
  %40 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !322
  %41 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !322
  %42 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !322
  %43 = and i16 %41, -193, !dbg !322
  %44 = or i16 %43, 128, !dbg !322
  %45 = and i16 %40, -64, !dbg !322
  %46 = or i16 %45, 27, !dbg !322
  store volatile i16 %39, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !323
  store volatile i16 %46, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !323
  store volatile i16 %44, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !323
  store volatile i16 %42, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !323
  call void asm sideeffect "nop", ""(), !dbg !323
  call void asm sideeffect "nop", ""(), !dbg !323
  %47 = load i16, i16* %5, align 2, !dbg !324
  %48 = icmp ult i16 0, %47, !dbg !325
  br i1 %48, label %49, label %50, !dbg !326

49:                                               ; preds = %3
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !327
  br label %51, !dbg !326

50:                                               ; preds = %3
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !328
  br label %51, !dbg !326

51:                                               ; preds = %49, %50
  ret void, !dbg !326
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream() !dbg !329 {
  call void @llvm.sdr.ublk.r(i16 1), !dbg !330
  ret void, !dbg !332
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7, i16 %8, i16 %9, i16 %10, float %11, float %12) !dbg !333 {
  %14 = alloca i16, i16 1, align 2, !dbg !334
  %15 = alloca i16, i16 1, align 2, !dbg !336
  %16 = alloca i16, i16 1, align 2, !dbg !337
  %17 = alloca i16, i16 1, align 2, !dbg !338
  %18 = alloca i16, i16 1, align 2, !dbg !339
  %19 = alloca i1, i16 1, align 1, !dbg !340
  %20 = alloca i16, i16 1, align 2, !dbg !341
  %21 = alloca i16, i16 1, align 2, !dbg !342
  %22 = alloca i16, i16 1, align 2, !dbg !343
  %23 = alloca i16, i16 1, align 2, !dbg !344
  %24 = alloca i16, i16 1, align 2, !dbg !345
  %25 = alloca float, i16 1, align 4, !dbg !346
  %26 = alloca float, i16 1, align 4, !dbg !347
  %27 = alloca i16, i16 1, align 2, !dbg !348
  %28 = alloca i16, i16 1, align 2, !dbg !349
  %29 = alloca i16, i16 1, align 2, !dbg !350
  %30 = alloca i16, i16 1, align 2, !dbg !351
  %31 = alloca i16, i16 1, align 2, !dbg !352
  %32 = alloca i16, i16 1, align 2, !dbg !353
  %33 = alloca i16, i16 1, align 2, !dbg !354
  %34 = alloca i16, i16 1, align 2, !dbg !355
  %35 = alloca i16, i16 1, align 2, !dbg !356
  %36 = alloca i16, i16 1, align 2, !dbg !357
  %37 = alloca i16, i16 1, align 2, !dbg !358
  store i16 %0, i16* %37, align 2, !dbg !358
  store i16 %1, i16* %36, align 2, !dbg !357
  store i16 %2, i16* %35, align 2, !dbg !356
  store i16 %3, i16* %34, align 2, !dbg !355
  store i16 %4, i16* %33, align 2, !dbg !354
  store i16 %5, i16* %32, align 2, !dbg !353
  store i16 %6, i16* %31, align 2, !dbg !352
  store i16 %7, i16* %30, align 2, !dbg !351
  store i16 %8, i16* %29, align 2, !dbg !350
  store i16 %9, i16* %28, align 2, !dbg !349
  store i16 %10, i16* %27, align 2, !dbg !348
  store float %11, float* %26, align 4, !dbg !347
  store float %12, float* %25, align 4, !dbg !346
  %38 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord(), !dbg !359
  store i16 %38, i16* %24, align 2, !dbg !345
  %39 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord(), !dbg !360
  store i16 %39, i16* %23, align 2, !dbg !344
  %40 = load i16, i16* %24, align 2, !dbg !361
  %41 = load i16, i16* %36, align 2, !dbg !362
  %42 = sub i16 %40, %41, !dbg !363
  store i16 %42, i16* %22, align 2, !dbg !343
  %43 = load i16, i16* %22, align 2, !dbg !364
  store i16 %43, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !365
  %44 = load i16, i16* %29, align 2, !dbg !366
  %45 = icmp eq i16 3, %44, !dbg !367
  br i1 %45, label %46, label %63, !dbg !368

46:                                               ; preds = %13
  %47 = load i16, i16* %22, align 2, !dbg !369
  %48 = sitofp i16 %47 to float, !dbg !370
  %49 = load float, float* %26, align 4, !dbg !371
  %50 = fmul float %48, %49, !dbg !372
  %51 = fptosi float %50 to i16, !dbg !373
  store i16 %51, i16* %21, align 2, !dbg !342
  %52 = load i16, i16* %22, align 2, !dbg !374
  %53 = load i16, i16* %21, align 2, !dbg !375
  %54 = load i16, i16* %28, align 2, !dbg !376
  %55 = mul i16 %53, %54, !dbg !377
  %56 = sub i16 %52, %55, !dbg !378
  store i16 %56, i16* %20, align 2, !dbg !341
  %57 = load i16, i16* %20, align 2, !dbg !379
  %58 = icmp ne i16 0, %57, !dbg !380
  br i1 %58, label %59, label %60, !dbg !381

59:                                               ; preds = %46
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !382
  br label %62, !dbg !381

60:                                               ; preds = %46
  %61 = load i16, i16* %21, align 2, !dbg !383
  store i16 %61, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !384
  br label %62, !dbg !381

62:                                               ; preds = %59, %60
  br label %63, !dbg !368

63:                                               ; preds = %62, %13
  %64 = load i16, i16* %22, align 2, !dbg !385
  %65 = icmp slt i16 %64, 0, !dbg !386
  br i1 %65, label %66, label %67, !dbg !387

66:                                               ; preds = %63
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !388
  br label %67, !dbg !387

67:                                               ; preds = %66, %63
  %68 = load i16, i16* %22, align 2, !dbg !389
  %69 = load i16, i16* %34, align 2, !dbg !390
  %70 = icmp sge i16 %68, %69, !dbg !391
  br i1 %70, label %71, label %72, !dbg !392

71:                                               ; preds = %67
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !393
  br label %72, !dbg !392

72:                                               ; preds = %71, %67
  store i1 false, i1* %19, align 1, !dbg !340
  %73 = load i16, i16* %29, align 2, !dbg !394
  %74 = icmp eq i16 3, %73, !dbg !395
  br i1 %74, label %75, label %94, !dbg !396

75:                                               ; preds = %72
  %76 = load i16, i16* %23, align 2, !dbg !397
  %77 = load i16, i16* %35, align 2, !dbg !398
  %78 = sub i16 %76, %77, !dbg !399
  %79 = sitofp i16 %78 to float, !dbg !400
  %80 = load float, float* %25, align 4, !dbg !401
  %81 = fmul float %79, %80, !dbg !402
  %82 = fptosi float %81 to i16, !dbg !403
  store i16 %82, i16* %18, align 2, !dbg !339
  %83 = load i16, i16* %23, align 2, !dbg !404
  %84 = load i16, i16* %35, align 2, !dbg !405
  %85 = sub i16 %83, %84, !dbg !406
  %86 = load i16, i16* %18, align 2, !dbg !407
  %87 = load i16, i16* %27, align 2, !dbg !408
  %88 = mul i16 %86, %87, !dbg !409
  %89 = sub i16 %85, %88, !dbg !410
  store i16 %89, i16* %17, align 2, !dbg !338
  %90 = load i16, i16* %17, align 2, !dbg !411
  %91 = icmp ne i16 0, %90, !dbg !412
  br i1 %91, label %92, label %93, !dbg !413

92:                                               ; preds = %75
  store i1 true, i1* %19, align 1, !dbg !414
  br label %93, !dbg !413

93:                                               ; preds = %92, %75
  br label %94, !dbg !396

94:                                               ; preds = %93, %72
  %95 = load i16, i16* %23, align 2, !dbg !415
  %96 = load i16, i16* %35, align 2, !dbg !416
  %97 = icmp slt i16 %95, %96, !dbg !417
  br i1 %97, label %98, label %99, !dbg !418

98:                                               ; preds = %94
  store i1 true, i1* %19, align 1, !dbg !419
  br label %99, !dbg !418

99:                                               ; preds = %98, %94
  %100 = load i16, i16* %23, align 2, !dbg !420
  %101 = load i16, i16* %35, align 2, !dbg !421
  %102 = load i16, i16* %33, align 2, !dbg !422
  %103 = add i16 %101, %102, !dbg !423
  %104 = icmp sge i16 %100, %103, !dbg !424
  br i1 %104, label %105, label %106, !dbg !425

105:                                              ; preds = %99
  store i1 true, i1* %19, align 1, !dbg !426
  br label %106, !dbg !425

106:                                              ; preds = %105, %99
  %107 = load i1, i1* %19, align 1, !dbg !427
  br i1 %107, label %108, label %109, !dbg !428

108:                                              ; preds = %106
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream(), !dbg !429
  call void @llvm.sdr.ublk.r(i16 27), !dbg !430
  br label %180, !dbg !428

109:                                              ; preds = %106
  %110 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !431
  %111 = icmp eq i16 -1, %110, !dbg !432
  br i1 %111, label %112, label %113, !dbg !433

112:                                              ; preds = %109
  call void @__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction(i16 31767), !dbg !434
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 23), !dbg !435
  call void @llvm.sdr.ublk.r(i16 27), !dbg !436
  br label %179, !dbg !433

113:                                              ; preds = %109
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter(i16 0, i16 0), !dbg !437
  %114 = load i16, i16* %34, align 2, !dbg !438
  store i16 %114, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !439
  %115 = load i16, i16* %29, align 2, !dbg !440
  %116 = icmp eq i16 3, %115, !dbg !441
  br i1 %116, label %117, label %126, !dbg !442

117:                                              ; preds = %113
  %118 = load i16, i16* %34, align 2, !dbg !443
  %119 = sub i16 %118, 1, !dbg !444
  %120 = sitofp i16 %119 to float, !dbg !445
  %121 = load float, float* %26, align 4, !dbg !446
  %122 = fmul float %120, %121, !dbg !447
  %123 = fptosi float %122 to i16, !dbg !448
  %124 = add i16 %123, 1, !dbg !449
  store i16 %124, i16* %16, align 2, !dbg !337
  %125 = load i16, i16* %16, align 2, !dbg !450
  store i16 %125, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !451
  br label %131, !dbg !442

126:                                              ; preds = %113
  %127 = load i16, i16* %29, align 2, !dbg !452
  %128 = icmp eq i16 1, %127, !dbg !453
  br i1 %128, label %129, label %130, !dbg !454

129:                                              ; preds = %126
  store i16 1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !455
  br label %130, !dbg !454

130:                                              ; preds = %129, %126
  br label %131, !dbg !442

131:                                              ; preds = %117, %130
  %132 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !456
  %133 = sub i16 %132, 1, !dbg !457
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit(i16 0, i16 %133), !dbg !458
  %134 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !459
  store i16 %134, i16* %15, align 2, !dbg !336
  %135 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !460
  store i16 %135, i16* %14, align 2, !dbg !334
  %136 = load i16, i16* %15, align 2, !dbg !461
  %137 = load i16, i16* %14, align 2, !dbg !462
  %138 = sub i16 %136, %137, !dbg !463
  store i16 %138, i16* %15, align 2, !dbg !464
  %139 = load i16, i16* %14, align 2, !dbg !465
  %140 = icmp eq i16 0, %139, !dbg !466
  br i1 %140, label %141, label %142, !dbg !467

141:                                              ; preds = %131
  store i16 0, i16* %15, align 2, !dbg !468
  br label %142, !dbg !467

142:                                              ; preds = %141, %131
  %143 = load i16, i16* %29, align 2, !dbg !469
  %144 = icmp eq i16 1, %143, !dbg !470
  br i1 %144, label %145, label %146, !dbg !471

145:                                              ; preds = %142
  store i16 0, i16* %15, align 2, !dbg !472
  br label %146, !dbg !471

146:                                              ; preds = %145, %142
  %147 = load i16, i16* %15, align 2, !dbg !473
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter(i16 0, i16 %147), !dbg !474
  call void @__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction(i16 31767), !dbg !475
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 23), !dbg !476
  %148 = load i16, i16* %37, align 2, !dbg !477
  %149 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval(i16 %148), !dbg !478
  %150 = icmp eq i16 0, %149, !dbg !479
  br i1 %150, label %151, label %155, !dbg !480

151:                                              ; preds = %146
  %152 = load i16, i16* %32, align 2, !dbg !481
  %153 = load i16, i16* %31, align 2, !dbg !482
  %154 = load i16, i16* %30, align 2, !dbg !483
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start(i16 %152, i16 %153, i16 %154), !dbg !484
  br label %178, !dbg !480

155:                                              ; preds = %146
  %156 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !485
  %157 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !485
  %158 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !485
  %159 = load i16, i16* %31, align 2, !dbg !486
  store i16 %159, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !487
  store i16 %156, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !487
  store i16 %157, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !487
  store i16 %158, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !487
  %160 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !488
  %161 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !488
  %162 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !488
  %163 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !488
  %164 = and i16 %162, -193, !dbg !488
  %165 = or i16 %164, 128, !dbg !488
  store volatile i16 %160, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !489
  store volatile i16 %161, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !489
  store volatile i16 %165, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !489
  store volatile i16 %163, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !489
  call void asm sideeffect "nop", ""(), !dbg !489
  call void asm sideeffect "nop", ""(), !dbg !489
  %166 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !490
  %167 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !490
  %168 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !490
  %169 = load i16, i16* %31, align 2, !dbg !491
  store i16 %169, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !492
  store i16 %166, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !492
  store i16 %167, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !492
  store i16 %168, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !492
  %170 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !493
  %171 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !493
  %172 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !493
  %173 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !493
  %174 = and i16 %172, -193, !dbg !493
  %175 = or i16 %174, 128, !dbg !493
  %176 = and i16 %171, -64, !dbg !493
  %177 = or i16 %176, 27, !dbg !493
  store volatile i16 %170, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !494
  store volatile i16 %177, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !494
  store volatile i16 %175, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !494
  store volatile i16 %173, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !494
  call void asm sideeffect "nop", ""(), !dbg !494
  call void asm sideeffect "nop", ""(), !dbg !494
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !495
  br label %178, !dbg !480

178:                                              ; preds = %151, %155
  br label %179, !dbg !433

179:                                              ; preds = %112, %178
  br label %180, !dbg !428

180:                                              ; preds = %108, %179
  ret void, !dbg !368
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit(i16 %0, i16 %1) !dbg !496 {
  %3 = alloca i16, i16 1, align 2, !dbg !498
  %4 = alloca i16, i16 1, align 2, !dbg !500
  %5 = alloca i16, i16 1, align 2, !dbg !501
  %6 = alloca i16, i16 1, align 2, !dbg !502
  %7 = alloca i16, i16 1, align 2, !dbg !503
  %8 = alloca i16, i16 1, align 2, !dbg !504
  store i16 %0, i16* %8, align 2, !dbg !504
  store i16 %1, i16* %7, align 2, !dbg !503
  %9 = load i16, i16* %7, align 2, !dbg !505
  %10 = icmp ult i16 %9, -32768, !dbg !506
  br i1 %10, label %11, label %12, !dbg !507

11:                                               ; preds = %2
  br label %13, !dbg !507

12:                                               ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !507
  br label %13, !dbg !507

13:                                               ; preds = %11, %12
  %14 = load i16, i16* %7, align 2, !dbg !508
  %15 = mul i16 %14, 2, !dbg !509
  store i16 %15, i16* %6, align 2, !dbg !502
  %16 = load i16, i16* %8, align 2, !dbg !510
  %17 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %16, i16 8), !dbg !511
  %18 = sub i16 %17, 1, !dbg !512
  store i16 %18, i16* %5, align 2, !dbg !501
  %19 = load i16, i16* %6, align 2, !dbg !513
  %20 = load i16, i16* %5, align 2, !dbg !514
  %21 = icmp ult i16 %19, %20, !dbg !515
  br i1 %21, label %22, label %23, !dbg !500

22:                                               ; preds = %13
  store i16 0, i16* %4, align 2, !dbg !500
  br label %27, !dbg !500

23:                                               ; preds = %13
  %24 = load i16, i16* %6, align 2, !dbg !516
  %25 = load i16, i16* %5, align 2, !dbg !517
  %26 = sub i16 %24, %25, !dbg !518
  store i16 %26, i16* %4, align 2, !dbg !500
  br label %27, !dbg !500

27:                                               ; preds = %22, %23
  %28 = load i16, i16* %4, align 2, !dbg !500
  store i16 %28, i16* %3, align 2, !dbg !498
  %29 = load i16, i16* %8, align 2, !dbg !519
  %30 = load i16, i16* %3, align 2, !dbg !520
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %29, i16 4, i16 %30), !dbg !521
  ret void, !dbg !500
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter(i16 %0, i16 %1) !dbg !522 {
  %3 = alloca i16, i16 1, align 2, !dbg !523
  %4 = alloca i16, i16 1, align 2, !dbg !525
  store i16 %0, i16* %4, align 2, !dbg !525
  store i16 %1, i16* %3, align 2, !dbg !523
  %5 = load i16, i16* %3, align 2, !dbg !526
  %6 = icmp ult i16 %5, -32768, !dbg !527
  br i1 %6, label %7, label %8, !dbg !528

7:                                                ; preds = %2
  br label %9, !dbg !528

8:                                                ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !528
  br label %9, !dbg !528

9:                                                ; preds = %7, %8
  %10 = load i16, i16* %4, align 2, !dbg !529
  %11 = load i16, i16* %3, align 2, !dbg !530
  %12 = mul i16 %11, 2, !dbg !531
  %13 = add i16 %12, 1, !dbg !532
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %10, i16 8, i16 %13), !dbg !533
  ret void, !dbg !534
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter(i16 %0, i16 %1) !dbg !535 {
  %3 = alloca i16, i16 1, align 2, !dbg !536
  %4 = alloca i16, i16 1, align 2, !dbg !538
  %5 = alloca i1, i16 1, align 1, !dbg !539
  %6 = alloca i16, i16 1, align 2, !dbg !540
  %7 = alloca i16, i16 1, align 2, !dbg !541
  %8 = alloca i16, i16 1, align 2, !dbg !542
  %9 = alloca i16, i16 1, align 2, !dbg !543
  store i16 %0, i16* %9, align 2, !dbg !543
  store i16 %1, i16* %8, align 2, !dbg !542
  %10 = load i16, i16* %8, align 2, !dbg !544
  %11 = icmp ult i16 %10, -32768, !dbg !545
  br i1 %11, label %12, label %13, !dbg !546

12:                                               ; preds = %2
  br label %14, !dbg !546

13:                                               ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !546
  br label %14, !dbg !546

14:                                               ; preds = %12, %13
  %15 = load i16, i16* %9, align 2, !dbg !547
  %16 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %15, i16 8), !dbg !548
  store i16 %16, i16* %7, align 2, !dbg !541
  %17 = load i16, i16* %8, align 2, !dbg !549
  %18 = mul i16 %17, 2, !dbg !550
  store i16 %18, i16* %6, align 2, !dbg !540
  %19 = load i16, i16* %6, align 2, !dbg !551
  %20 = load i16, i16* %7, align 2, !dbg !552
  %21 = icmp ugt i16 %19, %20, !dbg !553
  store i1 %21, i1* %5, align 1, !dbg !539
  %22 = load i16, i16* %9, align 2, !dbg !554
  %23 = load i1, i1* %5, align 1, !dbg !555
  %24 = zext i1 %23 to i16, !dbg !556
  %25 = shl i16 %24, 6, !dbg !557
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %22, i16 14, i16 %25), !dbg !558
  %26 = load i1, i1* %5, align 1, !dbg !559
  br i1 %26, label %27, label %32, !dbg !538

27:                                               ; preds = %14
  %28 = load i16, i16* %6, align 2, !dbg !560
  %29 = load i16, i16* %7, align 2, !dbg !561
  %30 = sub i16 %28, %29, !dbg !562
  %31 = add i16 %30, 1, !dbg !563
  store i16 %31, i16* %4, align 2, !dbg !538
  br label %34, !dbg !538

32:                                               ; preds = %14
  %33 = load i16, i16* %6, align 2, !dbg !564
  store i16 %33, i16* %4, align 2, !dbg !538
  br label %34, !dbg !538

34:                                               ; preds = %27, %32
  %35 = load i16, i16* %4, align 2, !dbg !538
  store i16 %35, i16* %3, align 2, !dbg !536
  %36 = load i16, i16* %9, align 2, !dbg !565
  %37 = load i16, i16* %3, align 2, !dbg !566
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %36, i16 12, i16 %37), !dbg !567
  ret void, !dbg !538
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %0, i16 %1, i16 %2) !dbg !568 {
  %4 = alloca i16, i16 1, align 2, !dbg !570
  %5 = alloca i16, i16 1, align 2, !dbg !572
  %6 = alloca i16, i16 1, align 2, !dbg !573
  store i16 %0, i16* %6, align 2, !dbg !573
  store i16 %1, i16* %5, align 2, !dbg !572
  store i16 %2, i16* %4, align 2, !dbg !570
  %7 = load i16, i16* %6, align 2, !dbg !574
  %8 = getelementptr [6 x i16], [6 x i16]* @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.filters, i16 0, i16 %7, !dbg !575
  %9 = load i16, i16* %8, align 2, !dbg !575
  %10 = load i16, i16* %5, align 2, !dbg !576
  %11 = add i16 %9, %10, !dbg !577
  %12 = lshr i16 %11, 1, !dbg !578
  %13 = load i16, i16* %4, align 2, !dbg !579
  %14 = shl i16 %12, 1, !dbg !580
  %15 = inttoptr i16 %14 to i16*, !dbg !580
  store volatile i16 %13, i16* %15, align 2, !dbg !580
  call void asm sideeffect "nop", ""(), !dbg !580
  call void asm sideeffect "nop", ""(), !dbg !580
  ret void, !dbg !581
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %0, i16 %1) !dbg !582 {
  %3 = alloca i16, i16 1, align 2, !dbg !583
  %4 = alloca i16, i16 1, align 2, !dbg !585
  store i16 %0, i16* %4, align 2, !dbg !585
  store i16 %1, i16* %3, align 2, !dbg !583
  %5 = load i16, i16* %4, align 2, !dbg !586
  %6 = getelementptr [6 x i16], [6 x i16]* @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.filters, i16 0, i16 %5, !dbg !587
  %7 = load i16, i16* %6, align 2, !dbg !587
  %8 = load i16, i16* %3, align 2, !dbg !588
  %9 = add i16 %7, %8, !dbg !589
  %10 = lshr i16 %9, 1, !dbg !590
  %11 = shl i16 %10, 1, !dbg !591
  %12 = inttoptr i16 %11 to i16*, !dbg !591
  call void asm sideeffect "nop", ""(), !dbg !591
  call void asm sideeffect "nop", ""(), !dbg !591
  %13 = load volatile i16, i16* %12, align 2, !dbg !591
  ret i16 %13, !dbg !592
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 %0) !dbg !593 {
  %2 = alloca i16, i16 1, align 2, !dbg !595
  %3 = alloca i16, i16 1, align 2, !dbg !597
  %4 = alloca i16, i16 1, align 2, !dbg !598
  %5 = alloca i16, i16 1, align 2, !dbg !599
  store i16 %0, i16* %5, align 2, !dbg !599
  %6 = load i16, i16* %5, align 2, !dbg !600
  store i16 %6, i16* %4, align 2, !dbg !598
  %7 = load i16, i16* %4, align 2, !dbg !601
  %8 = add i16 %7, 31744, !dbg !602
  store i16 %8, i16* %3, align 2, !dbg !597
  %9 = load i16, i16* %3, align 2, !dbg !603
  %10 = shl i16 %9, 1, !dbg !604
  %11 = inttoptr i16 %10 to i16*, !dbg !604
  call void asm sideeffect "nop", ""(), !dbg !604
  call void asm sideeffect "nop", ""(), !dbg !604
  %12 = load volatile i16, i16* %11, align 2, !dbg !604
  store i16 %12, i16* %2, align 2, !dbg !595
  %13 = load i16, i16* %3, align 2, !dbg !605
  %14 = load i16, i16* %2, align 2, !dbg !606
  %15 = and i16 %14, 32767, !dbg !607
  %16 = shl i16 %13, 1, !dbg !608
  %17 = inttoptr i16 %16 to i16*, !dbg !608
  store volatile i16 %15, i16* %17, align 2, !dbg !608
  call void asm sideeffect "nop", ""(), !dbg !608
  call void asm sideeffect "nop", ""(), !dbg !608
  ret void, !dbg !609
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord() !dbg !610 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 2), !dbg !612
  %2 = sub i16 %1, 4, !dbg !614
  ret i16 %2, !dbg !615
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord() !dbg !616 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 0), !dbg !617
  %2 = sub i16 %1, 1, !dbg !619
  ret i16 %2, !dbg !620
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 %0) !dbg !621 {
  %2 = alloca i16, i16 1, align 2, !dbg !623
  %3 = alloca i16, i16 1, align 2, !dbg !625
  store i16 %0, i16* %3, align 2, !dbg !625
  %4 = load i16, i16* %3, align 2, !dbg !626
  %5 = lshr i16 %4, 1, !dbg !627
  %6 = add i16 %5, 31813, !dbg !628
  %7 = shl i16 %6, 1, !dbg !629
  %8 = inttoptr i16 %7 to i16*, !dbg !629
  call void asm sideeffect "nop", ""(), !dbg !629
  call void asm sideeffect "nop", ""(), !dbg !629
  %9 = load volatile i16, i16* %8, align 2, !dbg !629
  store i16 %9, i16* %2, align 2, !dbg !623
  %10 = load i16, i16* %2, align 2, !dbg !630
  %11 = and i16 %10, 2047, !dbg !631
  ret i16 %11, !dbg !632
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord() !dbg !633 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord(), !dbg !635
  ret i16 %1, !dbg !637
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.get_y_coord() !dbg !638 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord(), !dbg !639
  ret i16 %1, !dbg !641
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval(i16 %0) !dbg !642 {
  %2 = alloca i16, i16 1, align 2, !dbg !643
  store i16 %0, i16* %2, align 2, !dbg !643
  %3 = load i16, i16* %2, align 2, !dbg !645
  %4 = icmp ult i16 %3, 24, !dbg !646
  br i1 %4, label %5, label %7, !dbg !647

5:                                                ; preds = %10, %11, %1
  %6 = phi i16 [ 0, %10 ], [ 0, %11 ], [ 1, %1 ]
  br label %12, !dbg !647

7:                                                ; preds = %1
  %8 = load i16, i16* %2, align 2, !dbg !648
  %9 = icmp eq i16 31, %8, !dbg !649
  br i1 %9, label %10, label %11, !dbg !650

10:                                               ; preds = %7
  br label %5, !dbg !650

11:                                               ; preds = %7
  call void asm sideeffect "hcf", ""(), !dbg !650
  br label %5, !dbg !650

12:                                               ; preds = %5
  %13 = phi i16 [ %6, %5 ]
  br label %14, !dbg !647

14:                                               ; preds = %12
  ret i16 %13, !dbg !647
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7) !dbg !651 {
  %9 = alloca i16, i16 1, align 2, !dbg !652
  %10 = alloca i16, i16 1, align 2, !dbg !654
  %11 = alloca i16, i16 1, align 2, !dbg !655
  %12 = alloca i16, i16 1, align 2, !dbg !656
  %13 = alloca i16, i16 1, align 2, !dbg !657
  %14 = alloca i16, i16 1, align 2, !dbg !658
  %15 = alloca i16, i16 1, align 2, !dbg !659
  %16 = alloca i16, i16 1, align 2, !dbg !660
  %17 = alloca i16, i16 1, align 2, !dbg !661
  store i16 %0, i16* %17, align 2, !dbg !661
  store i16 %1, i16* %16, align 2, !dbg !660
  store i16 %2, i16* %15, align 2, !dbg !659
  store i16 %3, i16* %14, align 2, !dbg !658
  store i16 %4, i16* %13, align 2, !dbg !657
  store i16 %5, i16* %12, align 2, !dbg !656
  store i16 %6, i16* %11, align 2, !dbg !655
  store i16 %7, i16* %10, align 2, !dbg !654
  %18 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !662
  store i16 %18, i16* %9, align 2, !dbg !652
  %19 = load i16, i16* %11, align 2, !dbg !663
  store i16 %19, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_c, align 2, !dbg !664
  %20 = load i16, i16* %10, align 2, !dbg !665
  store i16 %20, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_is_half, align 2, !dbg !666
  %21 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_c, align 2, !dbg !667
  %22 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval(i16 %21), !dbg !668
  store i16 %22, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !669
  store i16 0, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !670
  %23 = load i16, i16* %16, align 2, !dbg !671
  store i16 %23, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !672
  %24 = load i16, i16* %15, align 2, !dbg !673
  store i16 %24, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !674
  %25 = load i16, i16* %15, align 2, !dbg !675
  %26 = load i16, i16* %13, align 2, !dbg !676
  %27 = add i16 %25, %26, !dbg !677
  %28 = sub i16 %27, 1, !dbg !678
  store i16 %28, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_last, align 2, !dbg !679
  %29 = load i16, i16* %9, align 2, !dbg !680
  %30 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_last, align 2, !dbg !681
  %31 = icmp eq i16 %29, %30, !dbg !682
  br i1 %31, label %32, label %37, !dbg !683

32:                                               ; preds = %8
  %33 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !684
  %34 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !684
  %35 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !684
  store i16 %33, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !685
  store i16 lshr (i16 ptrtoint ([1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.ctrl_1 to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !685
  store i16 %34, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !685
  store i16 %35, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !685
  %36 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.ctrl_1, i16 0, i1 false), align 4, !dbg !686
  store i32 %36, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$7$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i1 false), align 4, !dbg !687
  br label %42, !dbg !683

37:                                               ; preds = %8
  %38 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !688
  %39 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !688
  %40 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !688
  store i16 %38, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !689
  store i16 lshr (i16 ptrtoint ([1 x i32]* @"$$csl_base_address$$3$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11" to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !689
  store i16 %39, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !689
  store i16 %40, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !689
  %41 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @"$$csl_base_address$$3$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11", i16 0, i1 false), align 4, !dbg !690
  store i32 %41, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$7$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i1 false), align 4, !dbg !691
  br label %42, !dbg !683

42:                                               ; preds = %32, %37
  store i32 165646921, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$7$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i2 1), align 4, !dbg !692
  %43 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !693
  %44 = icmp eq i16 0, %43, !dbg !694
  br i1 %44, label %45, label %56, !dbg !695

45:                                               ; preds = %42
  %46 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !696
  %47 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !696
  %48 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !696
  %49 = load i16, i16* %17, align 2, !dbg !697
  %50 = call i16* @.get_tensor_ptr(i16 %49), !dbg !698
  %51 = ptrtoint i16* %50 to i16, !dbg !699
  %52 = lshr i16 %51, 1, !dbg !699
  store i16 %46, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !700
  store i16 %52, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !700
  store i16 %47, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !700
  store i16 %48, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !700
  %53 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !701
  %54 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !701
  %55 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !701
  store i16 1, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !702
  store i16 %53, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !702
  store i16 %54, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !702
  store i16 %55, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !702
  call void @llvm.sdr.actvt.r(i16 21), !dbg !703
  br label %63, !dbg !695

56:                                               ; preds = %42
  %57 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !704
  %58 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !704
  %59 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !704
  store i16 %57, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !705
  store i16 lshr (i16 ptrtoint ([1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.data_buf to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !705
  store i16 %58, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !705
  store i16 %59, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !705
  %60 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !706
  %61 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !706
  %62 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !706
  store i16 1, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !707
  store i16 %60, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !707
  store i16 %61, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !707
  store i16 %62, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !707
  call void @llvm.sdr.ublk.r(i16 0), !dbg !708
  br label %63, !dbg !695

63:                                               ; preds = %45, %56
  ret void, !dbg !683
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x(i32 %0) #8 !dbg !709 {
  %2 = alloca i32, i16 1, align 4, !dbg !710
  store i32 %0, i32* %2, align 4, !dbg !710
  call void @llvm.sdr.blk.r(i16 0), !dbg !712
  %3 = load i32, i32* %2, align 4, !dbg !713
  store i32 %3, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.data_buf, i16 0, i1 false), align 4, !dbg !714
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__9 to i8*)), !dbg !715
  %4 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !716
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !716
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !716
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !716
  store volatile i16 %4, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !717
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !717
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !717
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !717
  call void asm sideeffect "nop", ""(), !dbg !717
  call void asm sideeffect "nop", ""(), !dbg !717
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !718
  %8 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !719
  %9 = add i16 %8, 1, !dbg !720
  store i16 %9, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !721
  ret void, !dbg !722
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_send_data() #9 !dbg !723 {
  %1 = alloca i16, i16 1, align 2, !dbg !724
  %2 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !726
  %3 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !727
  %4 = icmp ult i16 %2, %3, !dbg !728
  br i1 %4, label %5, label %27, !dbg !729

5:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__9 to i8*)), !dbg !730
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !731
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !731
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !731
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !731
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !732
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !732
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !732
  store volatile i16 %9, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !732
  call void asm sideeffect "nop", ""(), !dbg !732
  call void asm sideeffect "nop", ""(), !dbg !732
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_is_half, align 2, !dbg !733
  %11 = icmp ult i16 0, %10, !dbg !734
  br i1 %11, label %12, label %18, !dbg !735

12:                                               ; preds = %5
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !736
  %13 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !737
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !737
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !737
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !737
  %17 = add i16 %14, 1, !dbg !738
  store i16 %13, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !739
  store i16 %17, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !739
  store i16 %15, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !739
  store i16 %16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !739
  br label %24, !dbg !735

18:                                               ; preds = %5
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !740
  %19 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !741
  %20 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !741
  %21 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !741
  %22 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !741
  %23 = add i16 %20, 2, !dbg !742
  store i16 %19, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !743
  store i16 %23, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !743
  store i16 %21, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !743
  store i16 %22, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !743
  br label %24, !dbg !735

24:                                               ; preds = %12, %18
  %25 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !744
  %26 = add i16 %25, 1, !dbg !745
  store i16 %26, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !746
  br label %34, !dbg !729

27:                                               ; preds = %0
  %28 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !747
  store i16 %28, i16* %1, align 2, !dbg !724
  %29 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !748
  %30 = load i16, i16* %1, align 2, !dbg !749
  %31 = icmp eq i16 %29, %30, !dbg !750
  br i1 %31, label %32, label %33, !dbg !751

32:                                               ; preds = %27
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__10 to i8*)), !dbg !752
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__11 to i8*)), !dbg !753
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !754
  br label %33, !dbg !751

33:                                               ; preds = %32, %27
  br label %34, !dbg !729

34:                                               ; preds = %24, %33
  ret void, !dbg !729
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl() #10 !dbg !755 {
  %1 = alloca i16, i16 1, align 2, !dbg !756
  %2 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !758
  %3 = icmp eq i16 0, %2, !dbg !759
  br i1 %3, label %4, label %9, !dbg !760

4:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__12 to i8*)), !dbg !761
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !762
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !762
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !762
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !762
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !763
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !763
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !763
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !763
  call void asm sideeffect "nop", ""(), !dbg !763
  call void asm sideeffect "nop", ""(), !dbg !763
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !764
  br label %31, !dbg !760

9:                                                ; preds = %0
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !765
  %11 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !766
  %12 = icmp ult i16 %10, %11, !dbg !767
  br i1 %12, label %13, label %18, !dbg !768

13:                                               ; preds = %9
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__13 to i8*)), !dbg !769
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !770
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !770
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !770
  %17 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !770
  store volatile i16 %14, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !771
  store volatile i16 %15, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !771
  store volatile i16 %16, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !771
  store volatile i16 %17, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !771
  call void asm sideeffect "nop", ""(), !dbg !771
  call void asm sideeffect "nop", ""(), !dbg !771
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !772
  br label %30, !dbg !768

18:                                               ; preds = %9
  %19 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !773
  store i16 %19, i16* %1, align 2, !dbg !756
  %20 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !774
  %21 = load i16, i16* %1, align 2, !dbg !775
  %22 = icmp eq i16 %20, %21, !dbg !776
  br i1 %22, label %23, label %24, !dbg !777

23:                                               ; preds = %18
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__14 to i8*)), !dbg !778
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__15 to i8*)), !dbg !779
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !780
  br label %29, !dbg !777

24:                                               ; preds = %18
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__10 to i8*)), !dbg !781
  %25 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !782
  %26 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !782
  %27 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !782
  %28 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !782
  store volatile i16 %25, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !783
  store volatile i16 %26, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !783
  store volatile i16 %27, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !783
  store volatile i16 %28, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !783
  call void asm sideeffect "nop", ""(), !dbg !783
  call void asm sideeffect "nop", ""(), !dbg !783
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !784
  br label %29, !dbg !777

29:                                               ; preds = %23, %24
  br label %30, !dbg !768

30:                                               ; preds = %13, %29
  br label %31, !dbg !760

31:                                               ; preds = %4, %30
  ret void, !dbg !760
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.d2h_configure(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7) !dbg !785 {
  %9 = alloca i1, i16 1, align 1, !dbg !786
  %10 = alloca i1, i16 1, align 1, !dbg !788
  %11 = alloca i1, i16 1, align 1, !dbg !789
  %12 = alloca i16, i16 1, align 2, !dbg !790
  %13 = alloca i16, i16 1, align 2, !dbg !791
  %14 = alloca i16, i16 1, align 2, !dbg !792
  %15 = alloca i16, i16 1, align 2, !dbg !793
  %16 = alloca i16, i16 1, align 2, !dbg !794
  %17 = alloca i16, i16 1, align 2, !dbg !795
  %18 = alloca i16, i16 1, align 2, !dbg !796
  %19 = alloca i16, i16 1, align 2, !dbg !797
  %20 = alloca i16, i16 1, align 2, !dbg !798
  %21 = alloca i16, i16 1, align 2, !dbg !799
  %22 = alloca i16, i16 1, align 2, !dbg !800
  %23 = alloca i16, i16 1, align 2, !dbg !801
  %24 = alloca i16, i16 1, align 2, !dbg !802
  %25 = alloca i16, i16 1, align 2, !dbg !803
  store i16 %0, i16* %25, align 2, !dbg !803
  store i16 %1, i16* %24, align 2, !dbg !802
  store i16 %2, i16* %23, align 2, !dbg !801
  store i16 %3, i16* %22, align 2, !dbg !800
  store i16 %4, i16* %21, align 2, !dbg !799
  store i16 %5, i16* %20, align 2, !dbg !798
  store i16 %6, i16* %19, align 2, !dbg !797
  store i16 %7, i16* %18, align 2, !dbg !796
  %26 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !804
  store i16 %26, i16* %17, align 2, !dbg !795
  %27 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_y_coord(), !dbg !805
  store i16 %27, i16* %16, align 2, !dbg !794
  %28 = load i16, i16* %24, align 2, !dbg !806
  store i16 %28, i16* %15, align 2, !dbg !793
  %29 = load i16, i16* %24, align 2, !dbg !807
  %30 = load i16, i16* %22, align 2, !dbg !808
  %31 = add i16 %29, %30, !dbg !809
  %32 = sub i16 %31, 1, !dbg !810
  store i16 %32, i16* %14, align 2, !dbg !792
  %33 = load i16, i16* %23, align 2, !dbg !811
  store i16 %33, i16* %13, align 2, !dbg !791
  %34 = load i16, i16* %23, align 2, !dbg !812
  %35 = load i16, i16* %21, align 2, !dbg !813
  %36 = add i16 %34, %35, !dbg !814
  %37 = sub i16 %36, 1, !dbg !815
  store i16 %37, i16* %12, align 2, !dbg !790
  store i1 false, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !816
  %38 = load i16, i16* %17, align 2, !dbg !817
  %39 = load i16, i16* %15, align 2, !dbg !818
  %40 = icmp sge i16 %38, %39, !dbg !819
  br i1 %40, label %41, label %45, !dbg !789

41:                                               ; preds = %8
  %42 = load i16, i16* %16, align 2, !dbg !820
  %43 = load i16, i16* %12, align 2, !dbg !821
  %44 = icmp sle i16 %42, %43, !dbg !822
  store i1 %44, i1* %11, align 1, !dbg !789
  br label %46, !dbg !789

45:                                               ; preds = %8
  store i1 false, i1* %11, align 1, !dbg !789
  br label %46, !dbg !789

46:                                               ; preds = %41, %45
  %47 = load i1, i1* %11, align 1, !dbg !789
  br i1 %47, label %48, label %52, !dbg !788

48:                                               ; preds = %46
  %49 = load i16, i16* %16, align 2, !dbg !823
  %50 = load i16, i16* %13, align 2, !dbg !824
  %51 = icmp sge i16 %49, %50, !dbg !825
  store i1 %51, i1* %10, align 1, !dbg !788
  br label %53, !dbg !788

52:                                               ; preds = %46
  store i1 false, i1* %10, align 1, !dbg !788
  br label %53, !dbg !788

53:                                               ; preds = %48, %52
  %54 = load i1, i1* %10, align 1, !dbg !788
  br i1 %54, label %55, label %56, !dbg !826

55:                                               ; preds = %53
  store i1 true, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !827
  br label %56, !dbg !826

56:                                               ; preds = %55, %53
  store i1 false, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !828
  %57 = load i16, i16* %17, align 2, !dbg !829
  %58 = load i16, i16* %14, align 2, !dbg !830
  %59 = icmp sle i16 %57, %58, !dbg !831
  br i1 %59, label %60, label %62, !dbg !786

60:                                               ; preds = %56
  %61 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !832
  store i1 %61, i1* %9, align 1, !dbg !786
  br label %63, !dbg !786

62:                                               ; preds = %56
  store i1 false, i1* %9, align 1, !dbg !786
  br label %63, !dbg !786

63:                                               ; preds = %60, %62
  %64 = load i1, i1* %9, align 1, !dbg !786
  br i1 %64, label %65, label %66, !dbg !833

65:                                               ; preds = %63
  store i1 true, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !834
  br label %66, !dbg !833

66:                                               ; preds = %65, %63
  %67 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !835
  br i1 %67, label %68, label %86, !dbg !836

68:                                               ; preds = %66
  call void @__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position(i16 31959), !dbg !837
  %69 = load i16, i16* %15, align 2, !dbg !838
  %70 = load i16, i16* %17, align 2, !dbg !839
  %71 = icmp eq i16 %69, %70, !dbg !840
  br i1 %71, label %72, label %73, !dbg !841

72:                                               ; preds = %68
  call void @__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 31765), !dbg !842
  br label %74, !dbg !841

73:                                               ; preds = %68
  call void @__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 31765), !dbg !843
  br label %74, !dbg !841

74:                                               ; preds = %72, %73
  call void @sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit(i16 21), !dbg !844
  %75 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !845
  br i1 %75, label %76, label %85, !dbg !846

76:                                               ; preds = %74
  %77 = load i16, i16* %20, align 2, !dbg !847
  %78 = load i16, i16* %19, align 2, !dbg !848
  %79 = load i16, i16* %24, align 2, !dbg !849
  %80 = load i16, i16* %23, align 2, !dbg !850
  %81 = load i16, i16* %22, align 2, !dbg !851
  %82 = load i16, i16* %21, align 2, !dbg !852
  %83 = load i16, i16* %25, align 2, !dbg !853
  %84 = load i16, i16* %18, align 2, !dbg !854
  call void @sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start(i16 %77, i16 %78, i16 %79, i16 %80, i16 %81, i16 %82, i16 %83, i16 %84), !dbg !855
  br label %85, !dbg !846

85:                                               ; preds = %76, %74
  br label %87, !dbg !836

86:                                               ; preds = %66
  call void @llvm.sdr.actvt.r(i16 28), !dbg !856
  br label %87, !dbg !836

87:                                               ; preds = %85, %86
  ret void, !dbg !789
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit(i16 %0) !dbg !857 {
  %2 = alloca i16, i16 1, align 2, !dbg !858
  %3 = alloca i16, i16 1, align 2, !dbg !860
  %4 = alloca i16, i16 1, align 2, !dbg !861
  %5 = alloca i16, i16 1, align 2, !dbg !862
  store i16 %0, i16* %5, align 2, !dbg !862
  %6 = load i16, i16* %5, align 2, !dbg !863
  store i16 %6, i16* %4, align 2, !dbg !861
  %7 = load i16, i16* %4, align 2, !dbg !864
  %8 = add i16 %7, 31744, !dbg !865
  store i16 %8, i16* %3, align 2, !dbg !860
  %9 = load i16, i16* %3, align 2, !dbg !866
  %10 = shl i16 %9, 1, !dbg !867
  %11 = inttoptr i16 %10 to i16*, !dbg !867
  call void asm sideeffect "nop", ""(), !dbg !867
  call void asm sideeffect "nop", ""(), !dbg !867
  %12 = load volatile i16, i16* %11, align 2, !dbg !867
  store i16 %12, i16* %2, align 2, !dbg !858
  %13 = load i16, i16* %3, align 2, !dbg !868
  %14 = load i16, i16* %2, align 2, !dbg !869
  %15 = and i16 %14, 32767, !dbg !870
  %16 = shl i16 %13, 1, !dbg !871
  %17 = inttoptr i16 %16 to i16*, !dbg !871
  store volatile i16 %15, i16* %17, align 2, !dbg !871
  call void asm sideeffect "nop", ""(), !dbg !871
  call void asm sideeffect "nop", ""(), !dbg !871
  ret void, !dbg !872
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord() !dbg !873 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 2), !dbg !874
  %2 = sub i16 %1, 4, !dbg !876
  ret i16 %2, !dbg !877
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord() !dbg !878 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 0), !dbg !879
  %2 = sub i16 %1, 1, !dbg !881
  ret i16 %2, !dbg !882
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 %0) !dbg !883 {
  %2 = alloca i16, i16 1, align 2, !dbg !884
  %3 = alloca i16, i16 1, align 2, !dbg !886
  store i16 %0, i16* %3, align 2, !dbg !886
  %4 = load i16, i16* %3, align 2, !dbg !887
  %5 = lshr i16 %4, 1, !dbg !888
  %6 = add i16 %5, 31813, !dbg !889
  %7 = shl i16 %6, 1, !dbg !890
  %8 = inttoptr i16 %7 to i16*, !dbg !890
  call void asm sideeffect "nop", ""(), !dbg !890
  call void asm sideeffect "nop", ""(), !dbg !890
  %9 = load volatile i16, i16* %8, align 2, !dbg !890
  store i16 %9, i16* %2, align 2, !dbg !884
  %10 = load i16, i16* %2, align 2, !dbg !891
  %11 = and i16 %10, 2047, !dbg !892
  ret i16 %11, !dbg !893
}

define internal i16 @sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr(i16 %0) !dbg !894 {
  %2 = alloca i16, i16 1, align 2, !dbg !896
  store i16 %0, i16* %2, align 2, !dbg !896
  %3 = load i16, i16* %2, align 2, !dbg !898
  %4 = mul i16 %3, 2, !dbg !899
  %5 = add i16 %4, 31680, !dbg !900
  ret i16 %5, !dbg !901
}

define internal void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 %0, i16 %1, i1 %2) !dbg !902 {
  %4 = alloca i16, i16 1, align 2, !dbg !903
  %5 = alloca i16, i16 1, align 2, !dbg !905
  %6 = alloca i1, i16 1, align 1, !dbg !906
  %7 = alloca i16, i16 1, align 2, !dbg !907
  %8 = alloca i16, i16 1, align 2, !dbg !908
  store i16 %0, i16* %8, align 2, !dbg !908
  store i16 %1, i16* %7, align 2, !dbg !907
  store i1 %2, i1* %6, align 1, !dbg !906
  %9 = load i16, i16* %8, align 2, !dbg !909
  %10 = call i16 @sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr(i16 %9), !dbg !910
  store i16 %10, i16* %5, align 2, !dbg !905
  %11 = load i16, i16* %5, align 2, !dbg !911
  %12 = shl i16 %11, 1, !dbg !912
  %13 = inttoptr i16 %12 to i16*, !dbg !912
  call void asm sideeffect "nop", ""(), !dbg !912
  call void asm sideeffect "nop", ""(), !dbg !912
  call void asm sideeffect "nop", ""(), !dbg !912
  call void asm sideeffect "nop", ""(), !dbg !912
  %14 = load volatile i16, i16* %13, align 2, !dbg !912
  store i16 %14, i16* %4, align 2, !dbg !903
  %15 = load i1, i1* %6, align 1, !dbg !913
  br i1 %15, label %16, label %19, !dbg !914

16:                                               ; preds = %3
  %17 = load i16, i16* %4, align 2, !dbg !915
  %18 = or i16 %17, 2048, !dbg !916
  store i16 %18, i16* %4, align 2, !dbg !917
  br label %22, !dbg !914

19:                                               ; preds = %3
  %20 = load i16, i16* %4, align 2, !dbg !918
  %21 = and i16 %20, -2049, !dbg !919
  store i16 %21, i16* %4, align 2, !dbg !920
  br label %22, !dbg !914

22:                                               ; preds = %16, %19
  %23 = load i16, i16* %4, align 2, !dbg !921
  %24 = and i16 %23, -32, !dbg !922
  store i16 %24, i16* %4, align 2, !dbg !923
  %25 = load i16, i16* %4, align 2, !dbg !924
  %26 = load i16, i16* %7, align 2, !dbg !925
  %27 = add i16 %25, %26, !dbg !926
  store i16 %27, i16* %4, align 2, !dbg !927
  %28 = load i16, i16* %5, align 2, !dbg !928
  %29 = load i16, i16* %4, align 2, !dbg !929
  %30 = shl i16 %28, 1, !dbg !930
  %31 = inttoptr i16 %30 to i16*, !dbg !930
  store volatile i16 %29, i16* %31, align 2, !dbg !930
  call void asm sideeffect "nop", ""(), !dbg !930
  call void asm sideeffect "nop", ""(), !dbg !930
  call void asm sideeffect "nop", ""(), !dbg !930
  call void asm sideeffect "nop", ""(), !dbg !930
  ret void, !dbg !914
}

define internal i16 @sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr(i16 %0) !dbg !931 {
  %2 = alloca i16, i16 1, align 2, !dbg !933
  store i16 %0, i16* %2, align 2, !dbg !933
  %3 = load i16, i16* %2, align 2, !dbg !935
  %4 = add i16 %3, 31616, !dbg !936
  ret i16 %4, !dbg !937
}

define internal void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 %0, i16 %1) !dbg !938 {
  %3 = alloca i16, i16 1, align 2, !dbg !939
  %4 = alloca i16, i16 1, align 2, !dbg !941
  %5 = alloca i16, i16 1, align 2, !dbg !942
  %6 = alloca i16, i16 1, align 2, !dbg !943
  store i16 %0, i16* %6, align 2, !dbg !943
  store i16 %1, i16* %5, align 2, !dbg !942
  %7 = load i16, i16* %6, align 2, !dbg !944
  %8 = call i16 @sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr(i16 %7), !dbg !945
  store i16 %8, i16* %4, align 2, !dbg !941
  %9 = load i16, i16* %4, align 2, !dbg !946
  %10 = shl i16 %9, 1, !dbg !947
  %11 = inttoptr i16 %10 to i16*, !dbg !947
  call void asm sideeffect "nop", ""(), !dbg !947
  call void asm sideeffect "nop", ""(), !dbg !947
  call void asm sideeffect "nop", ""(), !dbg !947
  call void asm sideeffect "nop", ""(), !dbg !947
  %12 = load volatile i16, i16* %11, align 2, !dbg !947
  store i16 %12, i16* %3, align 2, !dbg !939
  %13 = load i16, i16* %3, align 2, !dbg !948
  %14 = and i16 %13, -497, !dbg !949
  store i16 %14, i16* %3, align 2, !dbg !950
  %15 = load i16, i16* %3, align 2, !dbg !951
  %16 = load i16, i16* %5, align 2, !dbg !952
  %17 = add i16 %15, %16, !dbg !953
  %18 = shl i16 %17, 4, !dbg !954
  store i16 %18, i16* %3, align 2, !dbg !955
  %19 = load i16, i16* %4, align 2, !dbg !956
  %20 = load i16, i16* %3, align 2, !dbg !957
  %21 = shl i16 %19, 1, !dbg !958
  %22 = inttoptr i16 %21 to i16*, !dbg !958
  store volatile i16 %20, i16* %22, align 2, !dbg !958
  call void asm sideeffect "nop", ""(), !dbg !958
  call void asm sideeffect "nop", ""(), !dbg !958
  call void asm sideeffect "nop", ""(), !dbg !958
  call void asm sideeffect "nop", ""(), !dbg !958
  ret void, !dbg !959
}

define internal i16* @.get_tensor_ptr(i16 %0) !dbg !960 {
  %2 = alloca i16, i16 1, align 2, !dbg !961
  store i16 %0, i16* %2, align 2, !dbg !961
  %3 = load i16, i16* %2, align 2, !dbg !961
  %4 = zext i16 %3 to i32, !dbg !961
  switch i32 %4, label %5 [
    i32 1, label %9
    i32 2, label %11
    i32 3, label %13
    i32 4, label %15
    i32 5, label %17
    i32 6, label %19
    i32 7, label %22
    i32 8, label %25
    i32 9, label %28
    i32 10, label %31
  ], !dbg !961

5:                                                ; preds = %1
  br i1 false, label %6, label %7, !dbg !961

6:                                                ; preds = %5
  br label %8, !dbg !961

7:                                                ; preds = %5
  call void asm sideeffect "hcf", ""(), !dbg !961
  br label %8, !dbg !961

8:                                                ; preds = %6, %7
  br label %33, !dbg !961

9:                                                ; preds = %1
  %10 = load i16*, i16** @p_a, align 8, !dbg !961
  br label %33, !dbg !961

11:                                               ; preds = %1
  %12 = load i16*, i16** @p_b, align 8, !dbg !961
  br label %33, !dbg !961

13:                                               ; preds = %1
  %14 = load i16*, i16** @p_g, align 8, !dbg !961
  br label %33, !dbg !961

15:                                               ; preds = %1
  %16 = load i16*, i16** @p_c, align 8, !dbg !961
  br label %33, !dbg !961

17:                                               ; preds = %1
  %18 = load i16*, i16** @p_d, align 8, !dbg !961
  br label %33, !dbg !961

19:                                               ; preds = %1
  %20 = load half*, half** @p_af, align 8, !dbg !961
  %21 = bitcast half* %20 to i16*, !dbg !961
  br label %33, !dbg !961

22:                                               ; preds = %1
  %23 = load half*, half** @p_bf, align 8, !dbg !961
  %24 = bitcast half* %23 to i16*, !dbg !961
  br label %33, !dbg !961

25:                                               ; preds = %1
  %26 = load half*, half** @p_gf, align 8, !dbg !961
  %27 = bitcast half* %26 to i16*, !dbg !961
  br label %33, !dbg !961

28:                                               ; preds = %1
  %29 = load half*, half** @p_cf, align 8, !dbg !961
  %30 = bitcast half* %29 to i16*, !dbg !961
  br label %33, !dbg !961

31:                                               ; preds = %1
  %32 = load i16*, i16** @p_mark, align 8, !dbg !961
  br label %33, !dbg !961

33:                                               ; preds = %8, %9, %11, %13, %15, %17, %19, %22, %25, %28, %31
  %34 = phi i16 [ -2, %31 ], [ -2, %28 ], [ -2, %25 ], [ -2, %22 ], [ -2, %19 ], [ -2, %17 ], [ -2, %15 ], [ -2, %13 ], [ -2, %11 ], [ -2, %9 ], [ 0, %8 ]
  %35 = phi i16* [ %32, %31 ], [ %30, %28 ], [ %27, %25 ], [ %24, %22 ], [ %21, %19 ], [ %18, %17 ], [ %16, %15 ], [ %14, %13 ], [ %12, %11 ], [ %10, %9 ], [ undef, %8 ]
  br label %36, !dbg !961

36:                                               ; preds = %33
  %37 = icmp ne i16 %34, 0, !dbg !961
  br i1 %37, label %38, label %39, !dbg !961

38:                                               ; preds = %36
  br label %41, !dbg !961

39:                                               ; preds = %36
  %40 = load i16*, i16** @p_mark, align 8, !dbg !961
  br label %41, !dbg !961

41:                                               ; preds = %38, %39
  %42 = phi i16* [ %40, %39 ], [ %35, %38 ]
  br label %43, !dbg !961

43:                                               ; preds = %41
  ret i16* %42, !dbg !961
}

define internal void @__generic0sys_mod.sys_mod.tile_config.queue_flush.exit() !dbg !963 {
  store volatile i16 1, i16* inttoptr (i16 -2268 to i16*), align 2, !dbg !965
  call void asm sideeffect "nop", ""(), !dbg !965
  call void asm sideeffect "nop", ""(), !dbg !965
  ret void, !dbg !967
}

define internal void @__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position(i16 %0) !dbg !968 {
  %2 = alloca i16, i16 1, align 2, !dbg !970
  %3 = alloca i16, i16 1, align 2, !dbg !972
  %4 = alloca i16, i16 1, align 2, !dbg !973
  store i16 %0, i16* %4, align 2, !dbg !973
  %5 = load i16, i16* %4, align 2, !dbg !974
  store i16 %5, i16* %3, align 2, !dbg !972
  %6 = load i16, i16* %3, align 2, !dbg !975
  %7 = shl i16 %6, 1, !dbg !976
  %8 = inttoptr i16 %7 to i16*, !dbg !976
  call void asm sideeffect "nop", ""(), !dbg !976
  call void asm sideeffect "nop", ""(), !dbg !976
  call void asm sideeffect "nop", ""(), !dbg !976
  call void asm sideeffect "nop", ""(), !dbg !976
  %9 = load volatile i16, i16* %8, align 2, !dbg !976
  store i16 %9, i16* %2, align 2, !dbg !970
  %10 = load i16, i16* %2, align 2, !dbg !977
  %11 = and i16 %10, -16, !dbg !978
  store i16 %11, i16* %2, align 2, !dbg !978
  %12 = load i16, i16* %3, align 2, !dbg !979
  %13 = load i16, i16* %2, align 2, !dbg !980
  %14 = shl i16 %12, 1, !dbg !981
  %15 = inttoptr i16 %14 to i16*, !dbg !981
  store volatile i16 %13, i16* %15, align 2, !dbg !981
  call void asm sideeffect "nop", ""(), !dbg !981
  call void asm sideeffect "nop", ""(), !dbg !981
  call void asm sideeffect "nop", ""(), !dbg !981
  call void asm sideeffect "nop", ""(), !dbg !981
  ret void, !dbg !982
}

define internal void @__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 %0) !dbg !983 {
  %2 = alloca i16, i16 1, align 2, !dbg !985
  %3 = alloca i16, i16 1, align 2, !dbg !987
  %4 = alloca i16, i16 1, align 2, !dbg !988
  store i16 %0, i16* %4, align 2, !dbg !988
  %5 = load i16, i16* %4, align 2, !dbg !989
  store i16 %5, i16* %3, align 2, !dbg !987
  %6 = load i16, i16* %3, align 2, !dbg !990
  %7 = shl i16 %6, 1, !dbg !991
  %8 = inttoptr i16 %7 to i16*, !dbg !991
  call void asm sideeffect "nop", ""(), !dbg !991
  call void asm sideeffect "nop", ""(), !dbg !991
  %9 = load volatile i16, i16* %8, align 2, !dbg !991
  store i16 %9, i16* %2, align 2, !dbg !985
  %10 = load i16, i16* %2, align 2, !dbg !992
  %11 = and i16 %10, -256, !dbg !993
  store i16 %11, i16* %2, align 2, !dbg !994
  %12 = load i16, i16* %2, align 2, !dbg !995
  %13 = load i16, i16* %2, align 2, !dbg !996
  %14 = call i16 @__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %13), !dbg !997
  %15 = or i16 %12, %14, !dbg !998
  store i16 %15, i16* %2, align 2, !dbg !998
  %16 = load i16, i16* %2, align 2, !dbg !999
  %17 = load i16, i16* %2, align 2, !dbg !1000
  %18 = call i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %17), !dbg !1001
  %19 = or i16 %16, %18, !dbg !1002
  store i16 %19, i16* %2, align 2, !dbg !1002
  %20 = load i16, i16* %3, align 2, !dbg !1003
  %21 = load i16, i16* %2, align 2, !dbg !1004
  %22 = shl i16 %20, 1, !dbg !1005
  %23 = inttoptr i16 %22 to i16*, !dbg !1005
  store volatile i16 %21, i16* %23, align 2, !dbg !1005
  call void asm sideeffect "nop", ""(), !dbg !1005
  call void asm sideeffect "nop", ""(), !dbg !1005
  ret void, !dbg !1006
}

define internal void @__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 %0) !dbg !1007 {
  %2 = alloca i16, i16 1, align 2, !dbg !1008
  %3 = alloca i16, i16 1, align 2, !dbg !1010
  %4 = alloca i16, i16 1, align 2, !dbg !1011
  store i16 %0, i16* %4, align 2, !dbg !1011
  %5 = load i16, i16* %4, align 2, !dbg !1012
  store i16 %5, i16* %3, align 2, !dbg !1010
  %6 = load i16, i16* %3, align 2, !dbg !1013
  %7 = shl i16 %6, 1, !dbg !1014
  %8 = inttoptr i16 %7 to i16*, !dbg !1014
  call void asm sideeffect "nop", ""(), !dbg !1014
  call void asm sideeffect "nop", ""(), !dbg !1014
  %9 = load volatile i16, i16* %8, align 2, !dbg !1014
  store i16 %9, i16* %2, align 2, !dbg !1008
  %10 = load i16, i16* %2, align 2, !dbg !1015
  %11 = and i16 %10, -256, !dbg !1016
  store i16 %11, i16* %2, align 2, !dbg !1017
  %12 = load i16, i16* %2, align 2, !dbg !1018
  %13 = load i16, i16* %2, align 2, !dbg !1019
  %14 = call i16 @__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %13), !dbg !1020
  %15 = or i16 %12, %14, !dbg !1021
  store i16 %15, i16* %2, align 2, !dbg !1021
  %16 = load i16, i16* %2, align 2, !dbg !1022
  %17 = load i16, i16* %2, align 2, !dbg !1023
  %18 = call i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %17), !dbg !1024
  %19 = or i16 %16, %18, !dbg !1025
  store i16 %19, i16* %2, align 2, !dbg !1025
  %20 = load i16, i16* %3, align 2, !dbg !1026
  %21 = load i16, i16* %2, align 2, !dbg !1027
  %22 = shl i16 %20, 1, !dbg !1028
  %23 = inttoptr i16 %22 to i16*, !dbg !1028
  store volatile i16 %21, i16* %23, align 2, !dbg !1028
  call void asm sideeffect "nop", ""(), !dbg !1028
  call void asm sideeffect "nop", ""(), !dbg !1028
  ret void, !dbg !1029
}

define internal i16 @__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %0) !dbg !1030 {
  %2 = alloca i16, i16 1, align 2, !dbg !1031
  %3 = alloca i16, i16 1, align 2, !dbg !1033
  store i16 %0, i16* %3, align 2, !dbg !1033
  %4 = load i16, i16* %3, align 2, !dbg !1034
  store i16 %4, i16* %2, align 2, !dbg !1031
  %5 = load i16, i16* %2, align 2, !dbg !1035
  store i16 %5, i16* %2, align 2, !dbg !1036
  %6 = load i16, i16* %2, align 2, !dbg !1037
  ret i16 %6, !dbg !1038
}

define internal i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %0) !dbg !1039 {
  %2 = alloca i16, i16 1, align 2, !dbg !1040
  %3 = alloca i16, i16 1, align 2, !dbg !1042
  store i16 %0, i16* %3, align 2, !dbg !1042
  %4 = load i16, i16* %3, align 2, !dbg !1043
  store i16 %4, i16* %2, align 2, !dbg !1040
  %5 = load i16, i16* %2, align 2, !dbg !1044
  %6 = or i16 %5, 2, !dbg !1045
  store i16 %6, i16* %2, align 2, !dbg !1045
  %7 = load i16, i16* %2, align 2, !dbg !1046
  ret i16 %7, !dbg !1047
}

define internal i16 @__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %0) !dbg !1048 {
  %2 = alloca i16, i16 1, align 2, !dbg !1049
  %3 = alloca i16, i16 1, align 2, !dbg !1051
  store i16 %0, i16* %3, align 2, !dbg !1051
  %4 = load i16, i16* %3, align 2, !dbg !1052
  store i16 %4, i16* %2, align 2, !dbg !1049
  %5 = load i16, i16* %2, align 2, !dbg !1053
  %6 = or i16 %5, 128, !dbg !1054
  store i16 %6, i16* %2, align 2, !dbg !1054
  %7 = load i16, i16* %2, align 2, !dbg !1055
  ret i16 %7, !dbg !1056
}

define internal void @__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction(i16 %0) !dbg !1057 {
  %2 = alloca i16, i16 1, align 2, !dbg !1058
  %3 = alloca i16, i16 1, align 2, !dbg !1060
  %4 = alloca i16, i16 1, align 2, !dbg !1061
  store i16 %0, i16* %4, align 2, !dbg !1061
  %5 = load i16, i16* %4, align 2, !dbg !1062
  store i16 %5, i16* %3, align 2, !dbg !1060
  %6 = load i16, i16* %3, align 2, !dbg !1063
  %7 = shl i16 %6, 1, !dbg !1064
  %8 = inttoptr i16 %7 to i16*, !dbg !1064
  call void asm sideeffect "nop", ""(), !dbg !1064
  call void asm sideeffect "nop", ""(), !dbg !1064
  %9 = load volatile i16, i16* %8, align 2, !dbg !1064
  store i16 %9, i16* %2, align 2, !dbg !1058
  %10 = load i16, i16* %2, align 2, !dbg !1065
  %11 = and i16 %10, -17, !dbg !1066
  store i16 %11, i16* %2, align 2, !dbg !1066
  %12 = load i16, i16* %3, align 2, !dbg !1067
  %13 = load i16, i16* %2, align 2, !dbg !1068
  %14 = shl i16 %12, 1, !dbg !1069
  %15 = inttoptr i16 %14 to i16*, !dbg !1069
  store volatile i16 %13, i16* %15, align 2, !dbg !1069
  call void asm sideeffect "nop", ""(), !dbg !1069
  call void asm sideeffect "nop", ""(), !dbg !1069
  ret void, !dbg !1070
}

define internal void @__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction(i16 %0) !dbg !1071 {
  %2 = alloca i16, i16 1, align 2, !dbg !1072
  %3 = alloca i16, i16 1, align 2, !dbg !1074
  %4 = alloca i16, i16 1, align 2, !dbg !1075
  store i16 %0, i16* %4, align 2, !dbg !1075
  %5 = load i16, i16* %4, align 2, !dbg !1076
  store i16 %5, i16* %3, align 2, !dbg !1074
  %6 = load i16, i16* %3, align 2, !dbg !1077
  %7 = shl i16 %6, 1, !dbg !1078
  %8 = inttoptr i16 %7 to i16*, !dbg !1078
  call void asm sideeffect "nop", ""(), !dbg !1078
  call void asm sideeffect "nop", ""(), !dbg !1078
  %9 = load volatile i16, i16* %8, align 2, !dbg !1078
  store i16 %9, i16* %2, align 2, !dbg !1072
  %10 = load i16, i16* %2, align 2, !dbg !1079
  %11 = or i16 %10, 16, !dbg !1080
  store i16 %11, i16* %2, align 2, !dbg !1080
  %12 = load i16, i16* %3, align 2, !dbg !1081
  %13 = load i16, i16* %2, align 2, !dbg !1082
  %14 = shl i16 %12, 1, !dbg !1083
  %15 = inttoptr i16 %14 to i16*, !dbg !1083
  store volatile i16 %13, i16* %15, align 2, !dbg !1083
  call void asm sideeffect "nop", ""(), !dbg !1083
  call void asm sideeffect "nop", ""(), !dbg !1083
  ret void, !dbg !1084
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
declare void @llvm.sdr.imov32.ds1(i16 immarg, i16 immarg) #12

; Function Attrs: nounwind
declare void @llvm.sdr.imov16.ds1(i16 immarg, i16 immarg) #12

; Function Attrs: nounwind
declare void @llvm.sdr.add16.ds0s1(i16 immarg, i16 immarg, i16 immarg) #12

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
!3 = distinct !DISubprogram(name: "compute", linkageName: "compute", scope: null, file: !4, line: 25, type: !5, scopeLine: 25, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!4 = !DIFile(filename: "./pe.csl", directory: "/home/USER/xkernel/studies/wse3-characterization/microbench/pcsweep/cases/dsr_s1last")
!5 = !DISubroutineType(types: !6)
!6 = !{}
!7 = !DILocation(line: 26, column: 11, scope: !8)
!8 = !DILexicalBlockFile(scope: !3, file: !4, discriminator: 0)
!9 = !DILocation(line: 27, column: 3, scope: !8)
!10 = !DILocation(line: 28, column: 11, scope: !8)
!11 = !DILocation(line: 29, column: 3, scope: !8)
!12 = !DILocation(line: 30, column: 11, scope: !8)
!13 = !DILocation(line: 31, column: 3, scope: !8)
!14 = !DILocation(line: 32, column: 11, scope: !8)
!15 = !DILocation(line: 33, column: 3, scope: !8)
!16 = !DILocation(line: 34, column: 11, scope: !8)
!17 = !DILocation(line: 35, column: 3, scope: !8)
!18 = !DILocation(line: 36, column: 11, scope: !8)
!19 = !DILocation(line: 37, column: 3, scope: !8)
!20 = !DILocation(line: 38, column: 11, scope: !8)
!21 = !DILocation(line: 39, column: 3, scope: !8)
!22 = !DILocation(line: 40, column: 11, scope: !8)
!23 = !DILocation(line: 41, column: 3, scope: !8)
!24 = !DILocation(line: 42, column: 11, scope: !8)
!25 = !DILocation(line: 43, column: 3, scope: !8)
!26 = !DILocation(line: 45, column: 11, scope: !8)
!27 = !DILocation(line: 46, column: 3, scope: !8)
!28 = !DILocation(line: 25, column: 1, scope: !8)
!29 = distinct !DISubprogram(name: "f_exit", linkageName: "f_exit", scope: null, file: !4, line: 49, type: !5, scopeLine: 49, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!30 = !DILocation(line: 49, column: 22, scope: !31)
!31 = !DILexicalBlockFile(scope: !29, file: !4, discriminator: 0)
!32 = !DILocation(line: 49, column: 1, scope: !31)
!33 = distinct !DISubprogram(name: "sys_mod.sys_nop", linkageName: "sys_mod.sys_nop", scope: null, file: !34, line: 90, type: !5, scopeLine: 90, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!34 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/memcpy.csl", directory: "")
!35 = !DILocation(line: 90, column: 1, scope: !36)
!36 = !DILexicalBlockFile(scope: !33, file: !34, discriminator: 0)
!37 = distinct !DISubprogram(name: "sys_mod.unblock_cmd_stream", linkageName: "sys_mod.unblock_cmd_stream", scope: null, file: !34, line: 102, type: !5, scopeLine: 102, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!38 = !DILocation(line: 103, column: 3, scope: !39)
!39 = !DILexicalBlockFile(scope: !37, file: !34, discriminator: 0)
!40 = !DILocation(line: 102, column: 1, scope: !39)
!41 = distinct !DISubprogram(name: "sys_mod.sys_mod.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.unblock_cmd_stream", scope: null, file: !42, line: 307, type: !5, scopeLine: 307, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!42 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpy.csl", directory: "")
!43 = !DILocation(line: 308, column: 5, scope: !44)
!44 = !DILexicalBlockFile(scope: !41, file: !42, discriminator: 0)
!45 = !DILocation(line: 307, column: 1, scope: !44)
!46 = distinct !DISubprogram(name: "sys_mod.sys_mod.teardown_h2d", linkageName: "sys_mod.sys_mod.teardown_h2d", scope: null, file: !42, line: 323, type: !5, scopeLine: 323, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!47 = !DILocation(line: 326, column: 5, scope: !48)
!48 = !DILexicalBlockFile(scope: !46, file: !42, discriminator: 0)
!49 = !DILocation(line: 323, column: 1, scope: !48)
!50 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_ublk_c22", linkageName: "sys_mod.sys_mod.f_ublk_c22", scope: null, file: !42, line: 335, type: !5, scopeLine: 335, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!51 = !DILocation(line: 336, column: 5, scope: !52)
!52 = !DILexicalBlockFile(scope: !50, file: !42, discriminator: 0)
!53 = !DILocation(line: 335, column: 1, scope: !52)
!54 = distinct !DISubprogram(name: "sys_mod.sys_mod.teardown_d2h", linkageName: "sys_mod.sys_mod.teardown_d2h", scope: null, file: !42, line: 344, type: !5, scopeLine: 344, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!55 = !DILocation(line: 355, column: 5, scope: !56)
!56 = !DILexicalBlockFile(scope: !54, file: !42, discriminator: 0)
!57 = !DILocation(line: 359, column: 5, scope: !56)
!58 = !DILocation(line: 344, column: 1, scope: !56)
!59 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_memcpyh2d", linkageName: "sys_mod.sys_mod.f_memcpyh2d", scope: null, file: !42, line: 460, type: !5, scopeLine: 460, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!60 = !DILocation(line: 477, column: 5, scope: !61)
!61 = !DILexicalBlockFile(scope: !59, file: !42, discriminator: 0)
!62 = !DILocation(line: 476, column: 5, scope: !61)
!63 = !DILocation(line: 475, column: 5, scope: !61)
!64 = !DILocation(line: 474, column: 5, scope: !61)
!65 = !DILocation(line: 473, column: 5, scope: !61)
!66 = !DILocation(line: 472, column: 5, scope: !61)
!67 = !DILocation(line: 471, column: 5, scope: !61)
!68 = !DILocation(line: 470, column: 5, scope: !61)
!69 = !DILocation(line: 469, column: 5, scope: !61)
!70 = !DILocation(line: 468, column: 5, scope: !61)
!71 = !DILocation(line: 467, column: 5, scope: !61)
!72 = !DILocation(line: 466, column: 5, scope: !61)
!73 = !DILocation(line: 465, column: 5, scope: !61)
!74 = !DILocation(line: 463, column: 5, scope: !61)
!75 = !DILocation(line: 462, column: 20, scope: !61)
!76 = !DILocation(line: 462, column: 32, scope: !61)
!77 = !DILocation(line: 462, column: 5, scope: !61)
!78 = !DILocation(line: 465, column: 33, scope: !61)
!79 = !DILocation(line: 465, column: 38, scope: !61)
!80 = !DILocation(line: 466, column: 34, scope: !61)
!81 = !DILocation(line: 466, column: 39, scope: !61)
!82 = !DILocation(line: 467, column: 34, scope: !61)
!83 = !DILocation(line: 467, column: 39, scope: !61)
!84 = !DILocation(line: 468, column: 33, scope: !61)
!85 = !DILocation(line: 468, column: 38, scope: !61)
!86 = !DILocation(line: 469, column: 33, scope: !61)
!87 = !DILocation(line: 469, column: 38, scope: !61)
!88 = !DILocation(line: 470, column: 35, scope: !61)
!89 = !DILocation(line: 470, column: 21, scope: !61)
!90 = !DILocation(line: 471, column: 41, scope: !61)
!91 = !DILocation(line: 471, column: 27, scope: !61)
!92 = !DILocation(line: 472, column: 39, scope: !61)
!93 = !DILocation(line: 472, column: 25, scope: !61)
!94 = !DILocation(line: 473, column: 44, scope: !61)
!95 = !DILocation(line: 473, column: 49, scope: !61)
!96 = !DILocation(line: 474, column: 41, scope: !61)
!97 = !DILocation(line: 474, column: 46, scope: !61)
!98 = !DILocation(line: 475, column: 41, scope: !61)
!99 = !DILocation(line: 475, column: 46, scope: !61)
!100 = !DILocation(line: 476, column: 59, scope: !61)
!101 = !DILocation(line: 476, column: 64, scope: !61)
!102 = !DILocation(line: 476, column: 50, scope: !61)
!103 = !DILocation(line: 476, column: 129, scope: !61)
!104 = !DILocation(line: 476, column: 134, scope: !61)
!105 = !DILocation(line: 476, column: 120, scope: !61)
!106 = !DILocation(line: 476, column: 118, scope: !61)
!107 = !DILocation(line: 476, column: 112, scope: !61)
!108 = !DILocation(line: 476, column: 36, scope: !61)
!109 = !DILocation(line: 477, column: 59, scope: !61)
!110 = !DILocation(line: 477, column: 64, scope: !61)
!111 = !DILocation(line: 477, column: 50, scope: !61)
!112 = !DILocation(line: 477, column: 129, scope: !61)
!113 = !DILocation(line: 477, column: 134, scope: !61)
!114 = !DILocation(line: 477, column: 120, scope: !61)
!115 = !DILocation(line: 477, column: 118, scope: !61)
!116 = !DILocation(line: 477, column: 112, scope: !61)
!117 = !DILocation(line: 477, column: 36, scope: !61)
!118 = !DILocation(line: 479, column: 24, scope: !61)
!119 = !DILocation(line: 481, column: 21, scope: !61)
!120 = !DILocation(line: 481, column: 19, scope: !61)
!121 = !DILocation(line: 482, column: 21, scope: !61)
!122 = !DILocation(line: 482, column: 19, scope: !61)
!123 = !DILocation(line: 483, column: 21, scope: !61)
!124 = !DILocation(line: 483, column: 19, scope: !61)
!125 = !DILocation(line: 484, column: 20, scope: !61)
!126 = !DILocation(line: 484, column: 18, scope: !61)
!127 = !DILocation(line: 485, column: 20, scope: !61)
!128 = !DILocation(line: 485, column: 18, scope: !61)
!129 = !DILocation(line: 486, column: 22, scope: !61)
!130 = !DILocation(line: 486, column: 20, scope: !61)
!131 = !DILocation(line: 487, column: 27, scope: !61)
!132 = !DILocation(line: 487, column: 25, scope: !61)
!133 = !DILocation(line: 488, column: 25, scope: !61)
!134 = !DILocation(line: 488, column: 23, scope: !61)
!135 = !DILocation(line: 489, column: 31, scope: !61)
!136 = !DILocation(line: 489, column: 29, scope: !61)
!137 = !DILocation(line: 490, column: 28, scope: !61)
!138 = !DILocation(line: 490, column: 26, scope: !61)
!139 = !DILocation(line: 491, column: 28, scope: !61)
!140 = !DILocation(line: 491, column: 26, scope: !61)
!141 = !DILocation(line: 492, column: 37, scope: !61)
!142 = !DILocation(line: 492, column: 35, scope: !61)
!143 = !DILocation(line: 493, column: 37, scope: !61)
!144 = !DILocation(line: 493, column: 35, scope: !61)
!145 = !DILocation(line: 495, column: 5, scope: !61)
!146 = !DILocation(line: 501, column: 5, scope: !61)
!147 = !DILocation(line: 506, column: 5, scope: !61)
!148 = !DILocation(line: 521, column: 5, scope: !61)
!149 = !DILocation(line: 522, column: 16, scope: !61)
!150 = !DILocation(line: 531, column: 5, scope: !61)
!151 = !DILocation(line: 460, column: 1, scope: !61)
!152 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_memcpyd2h", linkageName: "sys_mod.sys_mod.f_memcpyd2h", scope: null, file: !42, line: 556, type: !5, scopeLine: 556, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!153 = !DILocation(line: 568, column: 5, scope: !154)
!154 = !DILexicalBlockFile(scope: !152, file: !42, discriminator: 0)
!155 = !DILocation(line: 567, column: 5, scope: !154)
!156 = !DILocation(line: 566, column: 5, scope: !154)
!157 = !DILocation(line: 565, column: 5, scope: !154)
!158 = !DILocation(line: 564, column: 5, scope: !154)
!159 = !DILocation(line: 563, column: 5, scope: !154)
!160 = !DILocation(line: 562, column: 5, scope: !154)
!161 = !DILocation(line: 561, column: 5, scope: !154)
!162 = !DILocation(line: 559, column: 5, scope: !154)
!163 = !DILocation(line: 558, column: 20, scope: !154)
!164 = !DILocation(line: 558, column: 32, scope: !154)
!165 = !DILocation(line: 558, column: 5, scope: !154)
!166 = !DILocation(line: 561, column: 33, scope: !154)
!167 = !DILocation(line: 561, column: 38, scope: !154)
!168 = !DILocation(line: 562, column: 34, scope: !154)
!169 = !DILocation(line: 562, column: 39, scope: !154)
!170 = !DILocation(line: 563, column: 34, scope: !154)
!171 = !DILocation(line: 563, column: 39, scope: !154)
!172 = !DILocation(line: 564, column: 33, scope: !154)
!173 = !DILocation(line: 564, column: 38, scope: !154)
!174 = !DILocation(line: 565, column: 33, scope: !154)
!175 = !DILocation(line: 565, column: 38, scope: !154)
!176 = !DILocation(line: 566, column: 35, scope: !154)
!177 = !DILocation(line: 566, column: 21, scope: !154)
!178 = !DILocation(line: 567, column: 41, scope: !154)
!179 = !DILocation(line: 567, column: 27, scope: !154)
!180 = !DILocation(line: 568, column: 39, scope: !154)
!181 = !DILocation(line: 568, column: 25, scope: !154)
!182 = !DILocation(line: 570, column: 24, scope: !154)
!183 = !DILocation(line: 573, column: 21, scope: !154)
!184 = !DILocation(line: 573, column: 19, scope: !154)
!185 = !DILocation(line: 574, column: 21, scope: !154)
!186 = !DILocation(line: 574, column: 19, scope: !154)
!187 = !DILocation(line: 575, column: 21, scope: !154)
!188 = !DILocation(line: 575, column: 19, scope: !154)
!189 = !DILocation(line: 576, column: 20, scope: !154)
!190 = !DILocation(line: 576, column: 18, scope: !154)
!191 = !DILocation(line: 577, column: 20, scope: !154)
!192 = !DILocation(line: 577, column: 18, scope: !154)
!193 = !DILocation(line: 578, column: 22, scope: !154)
!194 = !DILocation(line: 578, column: 20, scope: !154)
!195 = !DILocation(line: 579, column: 27, scope: !154)
!196 = !DILocation(line: 579, column: 25, scope: !154)
!197 = !DILocation(line: 580, column: 25, scope: !154)
!198 = !DILocation(line: 580, column: 23, scope: !154)
!199 = !DILocation(line: 582, column: 5, scope: !154)
!200 = !DILocation(line: 588, column: 59, scope: !154)
!201 = !DILocation(line: 588, column: 5, scope: !154)
!202 = !DILocation(line: 608, column: 5, scope: !154)
!203 = !DILocation(line: 609, column: 16, scope: !154)
!204 = !DILocation(line: 556, column: 1, scope: !154)
!205 = distinct !DISubprogram(name: "sys_mod.sys_mod.oq0_teardow_handler", linkageName: "sys_mod.sys_mod.oq0_teardow_handler", scope: null, file: !42, line: 631, type: !5, scopeLine: 631, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!206 = !DILocation(line: 632, column: 9, scope: !207)
!207 = !DILexicalBlockFile(scope: !205, file: !42, discriminator: 0)
!208 = !DILocation(line: 632, column: 5, scope: !207)
!209 = !DILocation(line: 634, column: 66, scope: !207)
!210 = !DILocation(line: 634, column: 9, scope: !207)
!211 = !DILocation(line: 636, column: 13, scope: !207)
!212 = !DILocation(line: 637, column: 13, scope: !207)
!213 = !DILocation(line: 638, column: 13, scope: !207)
!214 = !DILocation(line: 639, column: 13, scope: !207)
!215 = !DILocation(line: 640, column: 13, scope: !207)
!216 = !DILocation(line: 641, column: 13, scope: !207)
!217 = !DILocation(line: 642, column: 13, scope: !207)
!218 = !DILocation(line: 643, column: 13, scope: !207)
!219 = !DILocation(line: 644, column: 13, scope: !207)
!220 = !DILocation(line: 645, column: 13, scope: !207)
!221 = !DILocation(line: 646, column: 13, scope: !207)
!222 = !DILocation(line: 647, column: 13, scope: !207)
!223 = !DILocation(line: 648, column: 13, scope: !207)
!224 = !DILocation(line: 635, column: 9, scope: !207)
!225 = !DILocation(line: 652, column: 9, scope: !207)
!226 = !DILocation(line: 654, column: 13, scope: !207)
!227 = !DILocation(line: 655, column: 13, scope: !207)
!228 = !DILocation(line: 656, column: 13, scope: !207)
!229 = !DILocation(line: 657, column: 13, scope: !207)
!230 = !DILocation(line: 658, column: 13, scope: !207)
!231 = !DILocation(line: 659, column: 13, scope: !207)
!232 = !DILocation(line: 660, column: 13, scope: !207)
!233 = !DILocation(line: 661, column: 13, scope: !207)
!234 = !DILocation(line: 653, column: 9, scope: !207)
!235 = !DILocation(line: 664, column: 5, scope: !207)
!236 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_rpc", linkageName: "sys_mod.sys_mod.f_rpc", scope: null, file: !42, line: 694, type: !5, scopeLine: 694, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!237 = !DILocation(line: 694, column: 13, scope: !238)
!238 = !DILexicalBlockFile(scope: !236, file: !42, discriminator: 0)
!239 = !DILocation(line: 700, column: 5, scope: !238)
!240 = !DILocation(line: 706, column: 20, scope: !238)
!241 = !DILocation(line: 706, column: 32, scope: !238)
!242 = !DILocation(line: 706, column: 5, scope: !238)
!243 = !DILocation(line: 710, column: 5, scope: !238)
!244 = !DILocation(line: 712, column: 24, scope: !238)
!245 = !DILocation(line: 694, column: 1, scope: !238)
!246 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.stack_push", linkageName: "sys_mod.sys_mod.sys_mod.stack_push", scope: null, file: !247, line: 54, type: !5, scopeLine: 54, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!247 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/sys.csl", directory: "")
!248 = !DILocation(line: 60, column: 5, scope: !249)
!249 = !DILexicalBlockFile(scope: !246, file: !247, discriminator: 0)
!250 = !DILocation(line: 54, column: 16, scope: !249)
!251 = !DILocation(line: 59, column: 13, scope: !249)
!252 = !DILocation(line: 59, column: 24, scope: !249)
!253 = !DILocation(line: 59, column: 5, scope: !249)
!254 = !DILocation(line: 61, column: 25, scope: !249)
!255 = !DILocation(line: 61, column: 5, scope: !249)
!256 = !DILocation(line: 61, column: 11, scope: !249)
!257 = !DILocation(line: 61, column: 10, scope: !249)
!258 = !DILocation(line: 61, column: 23, scope: !249)
!259 = !DILocation(line: 62, column: 18, scope: !249)
!260 = !DILocation(line: 62, column: 29, scope: !249)
!261 = !DILocation(line: 62, column: 16, scope: !249)
!262 = !DILocation(line: 54, column: 1, scope: !249)
!263 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_push", linkageName: "sys_mod.sys_mod.sys_mod.f_push", scope: null, file: !247, line: 72, type: !5, scopeLine: 72, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!264 = !DILocation(line: 72, column: 25, scope: !265)
!265 = !DILexicalBlockFile(scope: !263, file: !247, discriminator: 0)
!266 = !DILocation(line: 72, column: 13, scope: !265)
!267 = !DILocation(line: 73, column: 16, scope: !265)
!268 = !DILocation(line: 73, column: 5, scope: !265)
!269 = !DILocation(line: 72, column: 1, scope: !265)
!270 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.block_cmd_stream", linkageName: "sys_mod.sys_mod.sys_mod.block_cmd_stream", scope: null, file: !247, line: 76, type: !5, scopeLine: 76, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!271 = !DILocation(line: 77, column: 5, scope: !272)
!272 = !DILexicalBlockFile(scope: !270, file: !247, discriminator: 0)
!273 = !DILocation(line: 76, column: 1, scope: !272)
!274 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.sys_mod.unblock_cmd_stream", scope: null, file: !247, line: 80, type: !5, scopeLine: 80, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!275 = !DILocation(line: 81, column: 5, scope: !276)
!276 = !DILexicalBlockFile(scope: !274, file: !247, discriminator: 0)
!277 = !DILocation(line: 80, column: 1, scope: !276)
!278 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_sys_exit", linkageName: "sys_mod.sys_mod.sys_mod.f_sys_exit", scope: null, file: !247, line: 85, type: !5, scopeLine: 85, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!279 = !DILocation(line: 86, column: 5, scope: !280)
!280 = !DILexicalBlockFile(scope: !278, file: !247, discriminator: 0)
!281 = !DILocation(line: 87, column: 5, scope: !280)
!282 = !DILocation(line: 85, column: 1, scope: !280)
!283 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore", linkageName: "sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore", scope: null, file: !247, line: 90, type: !5, scopeLine: 90, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!284 = !DILocation(line: 90, column: 30, scope: !285)
!285 = !DILexicalBlockFile(scope: !283, file: !247, discriminator: 0)
!286 = !DILocation(line: 90, column: 1, scope: !285)
!287 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord", scope: null, file: !288, line: 131, type: !5, scopeLine: 131, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!288 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpyh2d.csl", directory: "")
!289 = !DILocation(line: 132, column: 12, scope: !290)
!290 = !DILexicalBlockFile(scope: !287, file: !288, discriminator: 0)
!291 = !DILocation(line: 132, column: 5, scope: !290)
!292 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord", scope: null, file: !288, line: 134, type: !5, scopeLine: 134, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!293 = !DILocation(line: 135, column: 12, scope: !294)
!294 = !DILexicalBlockFile(scope: !292, file: !288, discriminator: 0)
!295 = !DILocation(line: 135, column: 5, scope: !294)
!296 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval", scope: null, file: !288, line: 148, type: !5, scopeLine: 148, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!297 = !DILocation(line: 148, column: 23, scope: !298)
!298 = !DILexicalBlockFile(scope: !296, file: !288, discriminator: 0)
!299 = !DILocation(line: 149, column: 9, scope: !298)
!300 = !DILocation(line: 149, column: 20, scope: !298)
!301 = !DILocation(line: 149, column: 5, scope: !298)
!302 = !DILocation(line: 152, column: 23, scope: !298)
!303 = !DILocation(line: 152, column: 20, scope: !298)
!304 = !DILocation(line: 152, column: 9, scope: !298)
!305 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start", scope: null, file: !288, line: 226, type: !5, scopeLine: 226, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!306 = !DILocation(line: 233, column: 5, scope: !307)
!307 = !DILexicalBlockFile(scope: !305, file: !288, discriminator: 0)
!308 = !DILocation(line: 226, column: 49, scope: !307)
!309 = !DILocation(line: 226, column: 32, scope: !307)
!310 = !DILocation(line: 226, column: 21, scope: !307)
!311 = !DILocation(line: 229, column: 37, scope: !307)
!312 = !DILocation(line: 229, column: 52, scope: !307)
!313 = !DILocation(line: 229, column: 19, scope: !307)
!314 = !DILocation(line: 233, column: 71, scope: !307)
!315 = !DILocation(line: 233, column: 55, scope: !307)
!316 = !DILocation(line: 233, column: 25, scope: !307)
!317 = !DILocation(line: 235, column: 37, scope: !307)
!318 = !DILocation(line: 235, column: 52, scope: !307)
!319 = !DILocation(line: 235, column: 19, scope: !307)
!320 = !DILocation(line: 236, column: 28, scope: !307)
!321 = !DILocation(line: 236, column: 5, scope: !307)
!322 = !DILocation(line: 237, column: 28, scope: !307)
!323 = !DILocation(line: 237, column: 5, scope: !307)
!324 = !DILocation(line: 238, column: 13, scope: !307)
!325 = !DILocation(line: 238, column: 11, scope: !307)
!326 = !DILocation(line: 238, column: 5, scope: !307)
!327 = !DILocation(line: 239, column: 9, scope: !307)
!328 = !DILocation(line: 241, column: 9, scope: !307)
!329 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream", scope: null, file: !288, line: 249, type: !5, scopeLine: 249, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!330 = !DILocation(line: 250, column: 5, scope: !331)
!331 = !DILexicalBlockFile(scope: !329, file: !288, discriminator: 0)
!332 = !DILocation(line: 249, column: 1, scope: !331)
!333 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure", scope: null, file: !288, line: 276, type: !5, scopeLine: 276, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!334 = !DILocation(line: 414, column: 13, scope: !335)
!335 = !DILexicalBlockFile(scope: !333, file: !288, discriminator: 0)
!336 = !DILocation(line: 413, column: 13, scope: !335)
!337 = !DILocation(line: 400, column: 17, scope: !335)
!338 = !DILocation(line: 340, column: 9, scope: !335)
!339 = !DILocation(line: 339, column: 9, scope: !335)
!340 = !DILocation(line: 337, column: 5, scope: !335)
!341 = !DILocation(line: 319, column: 9, scope: !335)
!342 = !DILocation(line: 318, column: 9, scope: !335)
!343 = !DILocation(line: 315, column: 5, scope: !335)
!344 = !DILocation(line: 292, column: 5, scope: !335)
!345 = !DILocation(line: 291, column: 5, scope: !335)
!346 = !DILocation(line: 289, column: 5, scope: !335)
!347 = !DILocation(line: 288, column: 5, scope: !335)
!348 = !DILocation(line: 287, column: 5, scope: !335)
!349 = !DILocation(line: 286, column: 5, scope: !335)
!350 = !DILocation(line: 285, column: 5, scope: !335)
!351 = !DILocation(line: 284, column: 5, scope: !335)
!352 = !DILocation(line: 283, column: 5, scope: !335)
!353 = !DILocation(line: 282, column: 5, scope: !335)
!354 = !DILocation(line: 281, column: 5, scope: !335)
!355 = !DILocation(line: 280, column: 5, scope: !335)
!356 = !DILocation(line: 279, column: 5, scope: !335)
!357 = !DILocation(line: 278, column: 5, scope: !335)
!358 = !DILocation(line: 277, column: 5, scope: !335)
!359 = !DILocation(line: 291, column: 26, scope: !335)
!360 = !DILocation(line: 292, column: 26, scope: !335)
!361 = !DILocation(line: 315, column: 25, scope: !335)
!362 = !DILocation(line: 315, column: 31, scope: !335)
!363 = !DILocation(line: 315, column: 29, scope: !335)
!364 = !DILocation(line: 316, column: 20, scope: !335)
!365 = !DILocation(line: 316, column: 18, scope: !335)
!366 = !DILocation(line: 317, column: 52, scope: !335)
!367 = !DILocation(line: 317, column: 49, scope: !335)
!368 = !DILocation(line: 317, column: 5, scope: !335)
!369 = !DILocation(line: 318, column: 42, scope: !335)
!370 = !DILocation(line: 318, column: 33, scope: !335)
!371 = !DILocation(line: 318, column: 49, scope: !335)
!372 = !DILocation(line: 318, column: 48, scope: !335)
!373 = !DILocation(line: 318, column: 24, scope: !335)
!374 = !DILocation(line: 319, column: 24, scope: !335)
!375 = !DILocation(line: 319, column: 32, scope: !335)
!376 = !DILocation(line: 319, column: 36, scope: !335)
!377 = !DILocation(line: 319, column: 34, scope: !335)
!378 = !DILocation(line: 319, column: 30, scope: !335)
!379 = !DILocation(line: 320, column: 18, scope: !335)
!380 = !DILocation(line: 320, column: 15, scope: !335)
!381 = !DILocation(line: 320, column: 9, scope: !335)
!382 = !DILocation(line: 321, column: 26, scope: !335)
!383 = !DILocation(line: 325, column: 28, scope: !335)
!384 = !DILocation(line: 325, column: 26, scope: !335)
!385 = !DILocation(line: 331, column: 9, scope: !335)
!386 = !DILocation(line: 331, column: 15, scope: !335)
!387 = !DILocation(line: 331, column: 5, scope: !335)
!388 = !DILocation(line: 332, column: 22, scope: !335)
!389 = !DILocation(line: 334, column: 9, scope: !335)
!390 = !DILocation(line: 334, column: 18, scope: !335)
!391 = !DILocation(line: 334, column: 15, scope: !335)
!392 = !DILocation(line: 334, column: 5, scope: !335)
!393 = !DILocation(line: 335, column: 22, scope: !335)
!394 = !DILocation(line: 338, column: 52, scope: !335)
!395 = !DILocation(line: 338, column: 49, scope: !335)
!396 = !DILocation(line: 338, column: 5, scope: !335)
!397 = !DILocation(line: 339, column: 42, scope: !335)
!398 = !DILocation(line: 339, column: 48, scope: !335)
!399 = !DILocation(line: 339, column: 46, scope: !335)
!400 = !DILocation(line: 339, column: 33, scope: !335)
!401 = !DILocation(line: 339, column: 52, scope: !335)
!402 = !DILocation(line: 339, column: 51, scope: !335)
!403 = !DILocation(line: 339, column: 24, scope: !335)
!404 = !DILocation(line: 340, column: 25, scope: !335)
!405 = !DILocation(line: 340, column: 31, scope: !335)
!406 = !DILocation(line: 340, column: 29, scope: !335)
!407 = !DILocation(line: 340, column: 37, scope: !335)
!408 = !DILocation(line: 340, column: 41, scope: !335)
!409 = !DILocation(line: 340, column: 39, scope: !335)
!410 = !DILocation(line: 340, column: 35, scope: !335)
!411 = !DILocation(line: 341, column: 18, scope: !335)
!412 = !DILocation(line: 341, column: 15, scope: !335)
!413 = !DILocation(line: 341, column: 9, scope: !335)
!414 = !DILocation(line: 342, column: 26, scope: !335)
!415 = !DILocation(line: 347, column: 10, scope: !335)
!416 = !DILocation(line: 347, column: 16, scope: !335)
!417 = !DILocation(line: 347, column: 14, scope: !335)
!418 = !DILocation(line: 347, column: 5, scope: !335)
!419 = !DILocation(line: 348, column: 22, scope: !335)
!420 = !DILocation(line: 350, column: 10, scope: !335)
!421 = !DILocation(line: 350, column: 18, scope: !335)
!422 = !DILocation(line: 350, column: 21, scope: !335)
!423 = !DILocation(line: 350, column: 20, scope: !335)
!424 = !DILocation(line: 350, column: 14, scope: !335)
!425 = !DILocation(line: 350, column: 5, scope: !335)
!426 = !DILocation(line: 351, column: 22, scope: !335)
!427 = !DILocation(line: 354, column: 9, scope: !335)
!428 = !DILocation(line: 354, column: 5, scope: !335)
!429 = !DILocation(line: 358, column: 9, scope: !335)
!430 = !DILocation(line: 361, column: 9, scope: !335)
!431 = !DILocation(line: 364, column: 20, scope: !335)
!432 = !DILocation(line: 364, column: 17, scope: !335)
!433 = !DILocation(line: 364, column: 9, scope: !335)
!434 = !DILocation(line: 368, column: 13, scope: !335)
!435 = !DILocation(line: 371, column: 13, scope: !335)
!436 = !DILocation(line: 375, column: 13, scope: !335)
!437 = !DILocation(line: 394, column: 13, scope: !335)
!438 = !DILocation(line: 396, column: 29, scope: !335)
!439 = !DILocation(line: 396, column: 27, scope: !335)
!440 = !DILocation(line: 397, column: 60, scope: !335)
!441 = !DILocation(line: 397, column: 57, scope: !335)
!442 = !DILocation(line: 397, column: 13, scope: !335)
!443 = !DILocation(line: 400, column: 54, scope: !335)
!444 = !DILocation(line: 400, column: 55, scope: !335)
!445 = !DILocation(line: 400, column: 46, scope: !335)
!446 = !DILocation(line: 400, column: 59, scope: !335)
!447 = !DILocation(line: 400, column: 58, scope: !335)
!448 = !DILocation(line: 400, column: 37, scope: !335)
!449 = !DILocation(line: 400, column: 35, scope: !335)
!450 = !DILocation(line: 401, column: 33, scope: !335)
!451 = !DILocation(line: 401, column: 31, scope: !335)
!452 = !DILocation(line: 402, column: 69, scope: !335)
!453 = !DILocation(line: 402, column: 66, scope: !335)
!454 = !DILocation(line: 402, column: 19, scope: !335)
!455 = !DILocation(line: 404, column: 31, scope: !335)
!456 = !DILocation(line: 408, column: 75, scope: !335)
!457 = !DILocation(line: 408, column: 88, scope: !335)
!458 = !DILocation(line: 408, column: 13, scope: !335)
!459 = !DILocation(line: 413, column: 31, scope: !335)
!460 = !DILocation(line: 414, column: 33, scope: !335)
!461 = !DILocation(line: 415, column: 21, scope: !335)
!462 = !DILocation(line: 415, column: 29, scope: !335)
!463 = !DILocation(line: 415, column: 27, scope: !335)
!464 = !DILocation(line: 415, column: 19, scope: !335)
!465 = !DILocation(line: 416, column: 22, scope: !335)
!466 = !DILocation(line: 416, column: 19, scope: !335)
!467 = !DILocation(line: 416, column: 13, scope: !335)
!468 = !DILocation(line: 417, column: 23, scope: !335)
!469 = !DILocation(line: 419, column: 63, scope: !335)
!470 = !DILocation(line: 419, column: 60, scope: !335)
!471 = !DILocation(line: 419, column: 13, scope: !335)
!472 = !DILocation(line: 421, column: 23, scope: !335)
!473 = !DILocation(line: 423, column: 69, scope: !335)
!474 = !DILocation(line: 423, column: 13, scope: !335)
!475 = !DILocation(line: 426, column: 13, scope: !335)
!476 = !DILocation(line: 430, column: 13, scope: !335)
!477 = !DILocation(line: 433, column: 48, scope: !335)
!478 = !DILocation(line: 433, column: 22, scope: !335)
!479 = !DILocation(line: 433, column: 19, scope: !335)
!480 = !DILocation(line: 433, column: 13, scope: !335)
!481 = !DILocation(line: 436, column: 34, scope: !335)
!482 = !DILocation(line: 436, column: 39, scope: !335)
!483 = !DILocation(line: 436, column: 50, scope: !335)
!484 = !DILocation(line: 436, column: 17, scope: !335)
!485 = !DILocation(line: 452, column: 49, scope: !335)
!486 = !DILocation(line: 452, column: 64, scope: !335)
!487 = !DILocation(line: 452, column: 31, scope: !335)
!488 = !DILocation(line: 453, column: 40, scope: !335)
!489 = !DILocation(line: 453, column: 17, scope: !335)
!490 = !DILocation(line: 454, column: 50, scope: !335)
!491 = !DILocation(line: 454, column: 66, scope: !335)
!492 = !DILocation(line: 454, column: 32, scope: !335)
!493 = !DILocation(line: 455, column: 40, scope: !335)
!494 = !DILocation(line: 455, column: 17, scope: !335)
!495 = !DILocation(line: 456, column: 17, scope: !335)
!496 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit", scope: null, file: !497, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!497 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/filters/wse3.csl", directory: "")
!498 = !DILocation(line: 24, column: 3, scope: !499)
!499 = !DILexicalBlockFile(scope: !496, file: !497, discriminator: 0)
!500 = !DILocation(line: 24, column: 22, scope: !499)
!501 = !DILocation(line: 23, column: 3, scope: !499)
!502 = !DILocation(line: 22, column: 3, scope: !499)
!503 = !DILocation(line: 20, column: 37, scope: !499)
!504 = !DILocation(line: 20, column: 21, scope: !499)
!505 = !DILocation(line: 21, column: 11, scope: !499)
!506 = !DILocation(line: 21, column: 17, scope: !499)
!507 = !DILocation(line: 21, column: 3, scope: !499)
!508 = !DILocation(line: 22, column: 24, scope: !499)
!509 = !DILocation(line: 22, column: 30, scope: !499)
!510 = !DILocation(line: 23, column: 40, scope: !499)
!511 = !DILocation(line: 23, column: 22, scope: !499)
!512 = !DILocation(line: 23, column: 67, scope: !499)
!513 = !DILocation(line: 24, column: 26, scope: !499)
!514 = !DILocation(line: 24, column: 41, scope: !499)
!515 = !DILocation(line: 24, column: 39, scope: !499)
!516 = !DILocation(line: 24, column: 61, scope: !499)
!517 = !DILocation(line: 24, column: 76, scope: !499)
!518 = !DILocation(line: 24, column: 74, scope: !499)
!519 = !DILocation(line: 25, column: 21, scope: !499)
!520 = !DILocation(line: 25, column: 50, scope: !499)
!521 = !DILocation(line: 25, column: 3, scope: !499)
!522 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter", scope: null, file: !497, line: 30, type: !5, scopeLine: 30, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!523 = !DILocation(line: 30, column: 36, scope: !524)
!524 = !DILexicalBlockFile(scope: !522, file: !497, discriminator: 0)
!525 = !DILocation(line: 30, column: 20, scope: !524)
!526 = !DILocation(line: 31, column: 11, scope: !524)
!527 = !DILocation(line: 31, column: 23, scope: !524)
!528 = !DILocation(line: 31, column: 3, scope: !524)
!529 = !DILocation(line: 32, column: 21, scope: !524)
!530 = !DILocation(line: 32, column: 48, scope: !524)
!531 = !DILocation(line: 32, column: 60, scope: !524)
!532 = !DILocation(line: 32, column: 64, scope: !524)
!533 = !DILocation(line: 32, column: 3, scope: !524)
!534 = !DILocation(line: 30, column: 1, scope: !524)
!535 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter", scope: null, file: !497, line: 40, type: !5, scopeLine: 40, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!536 = !DILocation(line: 47, column: 3, scope: !537)
!537 = !DILexicalBlockFile(scope: !535, file: !497, discriminator: 0)
!538 = !DILocation(line: 48, column: 7, scope: !537)
!539 = !DILocation(line: 44, column: 3, scope: !537)
!540 = !DILocation(line: 43, column: 3, scope: !537)
!541 = !DILocation(line: 42, column: 3, scope: !537)
!542 = !DILocation(line: 40, column: 32, scope: !537)
!543 = !DILocation(line: 40, column: 16, scope: !537)
!544 = !DILocation(line: 41, column: 11, scope: !537)
!545 = !DILocation(line: 41, column: 19, scope: !537)
!546 = !DILocation(line: 41, column: 3, scope: !537)
!547 = !DILocation(line: 42, column: 40, scope: !537)
!548 = !DILocation(line: 42, column: 22, scope: !537)
!549 = !DILocation(line: 43, column: 26, scope: !537)
!550 = !DILocation(line: 43, column: 34, scope: !537)
!551 = !DILocation(line: 44, column: 25, scope: !537)
!552 = !DILocation(line: 44, column: 42, scope: !537)
!553 = !DILocation(line: 44, column: 40, scope: !537)
!554 = !DILocation(line: 45, column: 21, scope: !537)
!555 = !DILocation(line: 46, column: 35, scope: !537)
!556 = !DILocation(line: 46, column: 21, scope: !537)
!557 = !DILocation(line: 46, column: 50, scope: !537)
!558 = !DILocation(line: 45, column: 3, scope: !537)
!559 = !DILocation(line: 48, column: 11, scope: !537)
!560 = !DILocation(line: 48, column: 26, scope: !537)
!561 = !DILocation(line: 48, column: 43, scope: !537)
!562 = !DILocation(line: 48, column: 41, scope: !537)
!563 = !DILocation(line: 48, column: 54, scope: !537)
!564 = !DILocation(line: 48, column: 63, scope: !537)
!565 = !DILocation(line: 49, column: 21, scope: !537)
!566 = !DILocation(line: 49, column: 47, scope: !537)
!567 = !DILocation(line: 49, column: 3, scope: !537)
!568 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config", scope: null, file: !569, line: 33, type: !5, scopeLine: 33, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!569 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/filters/common.csl", directory: "")
!570 = !DILocation(line: 33, column: 46, scope: !571)
!571 = !DILexicalBlockFile(scope: !568, file: !569, discriminator: 0)
!572 = !DILocation(line: 33, column: 31, scope: !571)
!573 = !DILocation(line: 33, column: 15, scope: !571)
!574 = !DILocation(line: 34, column: 24, scope: !571)
!575 = !DILocation(line: 34, column: 23, scope: !571)
!576 = !DILocation(line: 34, column: 51, scope: !571)
!577 = !DILocation(line: 34, column: 35, scope: !571)
!578 = !DILocation(line: 34, column: 60, scope: !571)
!579 = !DILocation(line: 34, column: 73, scope: !571)
!580 = !DILocation(line: 34, column: 3, scope: !571)
!581 = !DILocation(line: 33, column: 1, scope: !571)
!582 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config", scope: null, file: !569, line: 38, type: !5, scopeLine: 38, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!583 = !DILocation(line: 38, column: 31, scope: !584)
!584 = !DILexicalBlockFile(scope: !582, file: !569, discriminator: 0)
!585 = !DILocation(line: 38, column: 15, scope: !584)
!586 = !DILocation(line: 39, column: 31, scope: !584)
!587 = !DILocation(line: 39, column: 30, scope: !584)
!588 = !DILocation(line: 39, column: 58, scope: !584)
!589 = !DILocation(line: 39, column: 42, scope: !584)
!590 = !DILocation(line: 39, column: 67, scope: !584)
!591 = !DILocation(line: 39, column: 10, scope: !584)
!592 = !DILocation(line: 39, column: 3, scope: !584)
!593 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit", scope: null, file: !594, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!594 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/teardown.csl", directory: "")
!595 = !DILocation(line: 43, column: 3, scope: !596)
!596 = !DILexicalBlockFile(scope: !593, file: !594, discriminator: 0)
!597 = !DILocation(line: 41, column: 3, scope: !596)
!598 = !DILocation(line: 40, column: 3, scope: !596)
!599 = !DILocation(line: 39, column: 9, scope: !596)
!600 = !DILocation(line: 40, column: 23, scope: !596)
!601 = !DILocation(line: 41, column: 70, scope: !596)
!602 = !DILocation(line: 41, column: 68, scope: !596)
!603 = !DILocation(line: 43, column: 27, scope: !596)
!604 = !DILocation(line: 43, column: 15, scope: !596)
!605 = !DILocation(line: 44, column: 15, scope: !596)
!606 = !DILocation(line: 44, column: 21, scope: !596)
!607 = !DILocation(line: 44, column: 27, scope: !596)
!608 = !DILocation(line: 44, column: 3, scope: !596)
!609 = !DILocation(line: 39, column: 1, scope: !596)
!610 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord", scope: null, file: !611, line: 4, type: !5, scopeLine: 4, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!611 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/layout.csl", directory: "")
!612 = !DILocation(line: 5, column: 10, scope: !613)
!613 = !DILexicalBlockFile(scope: !610, file: !611, discriminator: 0)
!614 = !DILocation(line: 5, column: 67, scope: !613)
!615 = !DILocation(line: 5, column: 3, scope: !613)
!616 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord", scope: null, file: !611, line: 8, type: !5, scopeLine: 8, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!617 = !DILocation(line: 9, column: 10, scope: !618)
!618 = !DILexicalBlockFile(scope: !616, file: !611, discriminator: 0)
!619 = !DILocation(line: 9, column: 67, scope: !618)
!620 = !DILocation(line: 9, column: 3, scope: !618)
!621 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord", scope: null, file: !622, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!622 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config.csl", directory: "")
!623 = !DILocation(line: 50, column: 3, scope: !624)
!624 = !DILexicalBlockFile(scope: !621, file: !622, discriminator: 0)
!625 = !DILocation(line: 43, column: 21, scope: !624)
!626 = !DILocation(line: 50, column: 57, scope: !624)
!627 = !DILocation(line: 50, column: 68, scope: !624)
!628 = !DILocation(line: 50, column: 41, scope: !624)
!629 = !DILocation(line: 50, column: 19, scope: !624)
!630 = !DILocation(line: 52, column: 10, scope: !624)
!631 = !DILocation(line: 52, column: 18, scope: !624)
!632 = !DILocation(line: 48, column: 22, scope: !624)
!633 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.get_x_coord", scope: null, file: !634, line: 171, type: !5, scopeLine: 171, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!634 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpyd2h.csl", directory: "")
!635 = !DILocation(line: 172, column: 12, scope: !636)
!636 = !DILexicalBlockFile(scope: !633, file: !634, discriminator: 0)
!637 = !DILocation(line: 172, column: 5, scope: !636)
!638 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.get_y_coord", scope: null, file: !634, line: 174, type: !5, scopeLine: 174, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!639 = !DILocation(line: 175, column: 12, scope: !640)
!640 = !DILexicalBlockFile(scope: !638, file: !634, discriminator: 0)
!641 = !DILocation(line: 175, column: 5, scope: !640)
!642 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval", scope: null, file: !634, line: 187, type: !5, scopeLine: 187, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!643 = !DILocation(line: 187, column: 23, scope: !644)
!644 = !DILexicalBlockFile(scope: !642, file: !634, discriminator: 0)
!645 = !DILocation(line: 188, column: 9, scope: !644)
!646 = !DILocation(line: 188, column: 20, scope: !644)
!647 = !DILocation(line: 188, column: 5, scope: !644)
!648 = !DILocation(line: 191, column: 23, scope: !644)
!649 = !DILocation(line: 191, column: 20, scope: !644)
!650 = !DILocation(line: 191, column: 9, scope: !644)
!651 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start", scope: null, file: !634, line: 383, type: !5, scopeLine: 383, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!652 = !DILocation(line: 386, column: 5, scope: !653)
!653 = !DILexicalBlockFile(scope: !651, file: !634, discriminator: 0)
!654 = !DILocation(line: 384, column: 72, scope: !653)
!655 = !DILocation(line: 384, column: 59, scope: !653)
!656 = !DILocation(line: 384, column: 46, scope: !653)
!657 = !DILocation(line: 384, column: 33, scope: !653)
!658 = !DILocation(line: 384, column: 19, scope: !653)
!659 = !DILocation(line: 384, column: 5, scope: !653)
!660 = !DILocation(line: 383, column: 32, scope: !653)
!661 = !DILocation(line: 383, column: 21, scope: !653)
!662 = !DILocation(line: 386, column: 26, scope: !653)
!663 = !DILocation(line: 388, column: 28, scope: !653)
!664 = !DILocation(line: 388, column: 17, scope: !653)
!665 = !DILocation(line: 389, column: 25, scope: !653)
!666 = !DILocation(line: 389, column: 23, scope: !653)
!667 = !DILocation(line: 391, column: 38, scope: !653)
!668 = !DILocation(line: 391, column: 20, scope: !653)
!669 = !DILocation(line: 391, column: 18, scope: !653)
!670 = !DILocation(line: 393, column: 7, scope: !653)
!671 = !DILocation(line: 395, column: 17, scope: !653)
!672 = !DILocation(line: 395, column: 15, scope: !653)
!673 = !DILocation(line: 397, column: 15, scope: !653)
!674 = !DILocation(line: 397, column: 13, scope: !653)
!675 = !DILocation(line: 398, column: 15, scope: !653)
!676 = !DILocation(line: 398, column: 25, scope: !653)
!677 = !DILocation(line: 398, column: 23, scope: !653)
!678 = !DILocation(line: 398, column: 31, scope: !653)
!679 = !DILocation(line: 398, column: 13, scope: !653)
!680 = !DILocation(line: 401, column: 10, scope: !653)
!681 = !DILocation(line: 401, column: 17, scope: !653)
!682 = !DILocation(line: 401, column: 14, scope: !653)
!683 = !DILocation(line: 401, column: 5, scope: !653)
!684 = !DILocation(line: 403, column: 48, scope: !653)
!685 = !DILocation(line: 403, column: 26, scope: !653)
!686 = !DILocation(line: 404, column: 26, scope: !653)
!687 = !DILocation(line: 404, column: 18, scope: !653)
!688 = !DILocation(line: 407, column: 48, scope: !653)
!689 = !DILocation(line: 407, column: 26, scope: !653)
!690 = !DILocation(line: 408, column: 27, scope: !653)
!691 = !DILocation(line: 408, column: 18, scope: !653)
!692 = !DILocation(line: 411, column: 14, scope: !653)
!693 = !DILocation(line: 414, column: 14, scope: !653)
!694 = !DILocation(line: 414, column: 11, scope: !653)
!695 = !DILocation(line: 414, column: 5, scope: !653)
!696 = !DILocation(line: 416, column: 44, scope: !653)
!697 = !DILocation(line: 416, column: 75, scope: !653)
!698 = !DILocation(line: 416, column: 59, scope: !653)
!699 = !DILocation(line: 416, column: 25, scope: !653)
!700 = !DILocation(line: 416, column: 23, scope: !653)
!701 = !DILocation(line: 418, column: 41, scope: !653)
!702 = !DILocation(line: 418, column: 23, scope: !653)
!703 = !DILocation(line: 419, column: 9, scope: !653)
!704 = !DILocation(line: 425, column: 44, scope: !653)
!705 = !DILocation(line: 425, column: 23, scope: !653)
!706 = !DILocation(line: 426, column: 41, scope: !653)
!707 = !DILocation(line: 426, column: 23, scope: !653)
!708 = !DILocation(line: 427, column: 9, scope: !653)
!709 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x", scope: null, file: !634, line: 448, type: !5, scopeLine: 448, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!710 = !DILocation(line: 448, column: 31, scope: !711)
!711 = !DILexicalBlockFile(scope: !709, file: !634, discriminator: 0)
!712 = !DILocation(line: 453, column: 5, scope: !711)
!713 = !DILocation(line: 456, column: 19, scope: !711)
!714 = !DILocation(line: 456, column: 17, scope: !711)
!715 = !DILocation(line: 461, column: 5, scope: !711)
!716 = !DILocation(line: 462, column: 28, scope: !711)
!717 = !DILocation(line: 462, column: 5, scope: !711)
!718 = !DILocation(line: 463, column: 5, scope: !711)
!719 = !DILocation(line: 464, column: 9, scope: !711)
!720 = !DILocation(line: 464, column: 10, scope: !711)
!721 = !DILocation(line: 464, column: 7, scope: !711)
!722 = !DILocation(line: 448, column: 1, scope: !711)
!723 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_send_data", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_send_data", scope: null, file: !634, line: 476, type: !5, scopeLine: 476, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!724 = !DILocation(line: 494, column: 9, scope: !725)
!725 = !DILexicalBlockFile(scope: !723, file: !634, discriminator: 0)
!726 = !DILocation(line: 478, column: 9, scope: !725)
!727 = !DILocation(line: 478, column: 13, scope: !725)
!728 = !DILocation(line: 478, column: 11, scope: !725)
!729 = !DILocation(line: 478, column: 5, scope: !725)
!730 = !DILocation(line: 479, column: 9, scope: !725)
!731 = !DILocation(line: 480, column: 32, scope: !725)
!732 = !DILocation(line: 480, column: 9, scope: !725)
!733 = !DILocation(line: 481, column: 17, scope: !725)
!734 = !DILocation(line: 481, column: 15, scope: !725)
!735 = !DILocation(line: 481, column: 9, scope: !725)
!736 = !DILocation(line: 482, column: 13, scope: !725)
!737 = !DILocation(line: 483, column: 51, scope: !725)
!738 = !DILocation(line: 483, column: 29, scope: !725)
!739 = !DILocation(line: 483, column: 27, scope: !725)
!740 = !DILocation(line: 485, column: 13, scope: !725)
!741 = !DILocation(line: 486, column: 51, scope: !725)
!742 = !DILocation(line: 486, column: 29, scope: !725)
!743 = !DILocation(line: 486, column: 27, scope: !725)
!744 = !DILocation(line: 488, column: 13, scope: !725)
!745 = !DILocation(line: 488, column: 14, scope: !725)
!746 = !DILocation(line: 488, column: 11, scope: !725)
!747 = !DILocation(line: 494, column: 30, scope: !725)
!748 = !DILocation(line: 496, column: 14, scope: !725)
!749 = !DILocation(line: 496, column: 25, scope: !725)
!750 = !DILocation(line: 496, column: 22, scope: !725)
!751 = !DILocation(line: 496, column: 9, scope: !725)
!752 = !DILocation(line: 497, column: 13, scope: !725)
!753 = !DILocation(line: 498, column: 13, scope: !725)
!754 = !DILocation(line: 499, column: 13, scope: !725)
!755 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl", scope: null, file: !634, line: 505, type: !5, scopeLine: 505, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!756 = !DILocation(line: 524, column: 13, scope: !757)
!757 = !DILexicalBlockFile(scope: !755, file: !634, discriminator: 0)
!758 = !DILocation(line: 506, column: 14, scope: !757)
!759 = !DILocation(line: 506, column: 11, scope: !757)
!760 = !DILocation(line: 506, column: 5, scope: !757)
!761 = !DILocation(line: 508, column: 9, scope: !757)
!762 = !DILocation(line: 509, column: 32, scope: !757)
!763 = !DILocation(line: 509, column: 9, scope: !757)
!764 = !DILocation(line: 510, column: 9, scope: !757)
!765 = !DILocation(line: 514, column: 13, scope: !757)
!766 = !DILocation(line: 514, column: 17, scope: !757)
!767 = !DILocation(line: 514, column: 15, scope: !757)
!768 = !DILocation(line: 514, column: 9, scope: !757)
!769 = !DILocation(line: 518, column: 13, scope: !757)
!770 = !DILocation(line: 519, column: 36, scope: !757)
!771 = !DILocation(line: 519, column: 13, scope: !757)
!772 = !DILocation(line: 520, column: 13, scope: !757)
!773 = !DILocation(line: 524, column: 34, scope: !757)
!774 = !DILocation(line: 526, column: 18, scope: !757)
!775 = !DILocation(line: 526, column: 29, scope: !757)
!776 = !DILocation(line: 526, column: 26, scope: !757)
!777 = !DILocation(line: 526, column: 13, scope: !757)
!778 = !DILocation(line: 529, column: 17, scope: !757)
!779 = !DILocation(line: 530, column: 17, scope: !757)
!780 = !DILocation(line: 531, column: 17, scope: !757)
!781 = !DILocation(line: 534, column: 17, scope: !757)
!782 = !DILocation(line: 535, column: 40, scope: !757)
!783 = !DILocation(line: 535, column: 17, scope: !757)
!784 = !DILocation(line: 536, column: 17, scope: !757)
!785 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.d2h_configure", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.d2h_configure", scope: null, file: !634, line: 593, type: !5, scopeLine: 593, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!786 = !DILocation(line: 617, column: 26, scope: !787)
!787 = !DILexicalBlockFile(scope: !785, file: !634, discriminator: 0)
!788 = !DILocation(line: 612, column: 47, scope: !787)
!789 = !DILocation(line: 612, column: 27, scope: !787)
!790 = !DILocation(line: 602, column: 5, scope: !787)
!791 = !DILocation(line: 601, column: 5, scope: !787)
!792 = !DILocation(line: 599, column: 5, scope: !787)
!793 = !DILocation(line: 598, column: 5, scope: !787)
!794 = !DILocation(line: 596, column: 5, scope: !787)
!795 = !DILocation(line: 595, column: 5, scope: !787)
!796 = !DILocation(line: 593, column: 86, scope: !787)
!797 = !DILocation(line: 593, column: 70, scope: !787)
!798 = !DILocation(line: 593, column: 60, scope: !787)
!799 = !DILocation(line: 593, column: 52, scope: !787)
!800 = !DILocation(line: 593, column: 44, scope: !787)
!801 = !DILocation(line: 593, column: 35, scope: !787)
!802 = !DILocation(line: 593, column: 26, scope: !787)
!803 = !DILocation(line: 593, column: 18, scope: !787)
!804 = !DILocation(line: 595, column: 26, scope: !787)
!805 = !DILocation(line: 596, column: 26, scope: !787)
!806 = !DILocation(line: 598, column: 23, scope: !787)
!807 = !DILocation(line: 599, column: 23, scope: !787)
!808 = !DILocation(line: 599, column: 28, scope: !787)
!809 = !DILocation(line: 599, column: 26, scope: !787)
!810 = !DILocation(line: 599, column: 29, scope: !787)
!811 = !DILocation(line: 601, column: 24, scope: !787)
!812 = !DILocation(line: 602, column: 24, scope: !787)
!813 = !DILocation(line: 602, column: 29, scope: !787)
!814 = !DILocation(line: 602, column: 27, scope: !787)
!815 = !DILocation(line: 602, column: 30, scope: !787)
!816 = !DILocation(line: 611, column: 20, scope: !787)
!817 = !DILocation(line: 612, column: 11, scope: !787)
!818 = !DILocation(line: 612, column: 18, scope: !787)
!819 = !DILocation(line: 612, column: 15, scope: !787)
!820 = !DILocation(line: 612, column: 32, scope: !787)
!821 = !DILocation(line: 612, column: 39, scope: !787)
!822 = !DILocation(line: 612, column: 36, scope: !787)
!823 = !DILocation(line: 612, column: 52, scope: !787)
!824 = !DILocation(line: 612, column: 59, scope: !787)
!825 = !DILocation(line: 612, column: 56, scope: !787)
!826 = !DILocation(line: 612, column: 5, scope: !787)
!827 = !DILocation(line: 613, column: 24, scope: !787)
!828 = !DILocation(line: 616, column: 15, scope: !787)
!829 = !DILocation(line: 617, column: 11, scope: !787)
!830 = !DILocation(line: 617, column: 18, scope: !787)
!831 = !DILocation(line: 617, column: 15, scope: !787)
!832 = !DILocation(line: 617, column: 30, scope: !787)
!833 = !DILocation(line: 617, column: 5, scope: !787)
!834 = !DILocation(line: 618, column: 19, scope: !787)
!835 = !DILocation(line: 621, column: 9, scope: !787)
!836 = !DILocation(line: 621, column: 5, scope: !787)
!837 = !DILocation(line: 627, column: 9, scope: !787)
!838 = !DILocation(line: 629, column: 13, scope: !787)
!839 = !DILocation(line: 629, column: 25, scope: !787)
!840 = !DILocation(line: 629, column: 21, scope: !787)
!841 = !DILocation(line: 629, column: 9, scope: !787)
!842 = !DILocation(line: 632, column: 13, scope: !787)
!843 = !DILocation(line: 636, column: 13, scope: !787)
!844 = !DILocation(line: 641, column: 9, scope: !787)
!845 = !DILocation(line: 646, column: 13, scope: !787)
!846 = !DILocation(line: 646, column: 9, scope: !787)
!847 = !DILocation(line: 647, column: 30, scope: !787)
!848 = !DILocation(line: 647, column: 35, scope: !787)
!849 = !DILocation(line: 647, column: 46, scope: !787)
!850 = !DILocation(line: 647, column: 50, scope: !787)
!851 = !DILocation(line: 647, column: 54, scope: !787)
!852 = !DILocation(line: 647, column: 57, scope: !787)
!853 = !DILocation(line: 647, column: 60, scope: !787)
!854 = !DILocation(line: 647, column: 63, scope: !787)
!855 = !DILocation(line: 647, column: 13, scope: !787)
!856 = !DILocation(line: 661, column: 9, scope: !787)
!857 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit", scope: null, file: !594, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!858 = !DILocation(line: 43, column: 3, scope: !859)
!859 = !DILexicalBlockFile(scope: !857, file: !594, discriminator: 0)
!860 = !DILocation(line: 41, column: 3, scope: !859)
!861 = !DILocation(line: 40, column: 3, scope: !859)
!862 = !DILocation(line: 39, column: 9, scope: !859)
!863 = !DILocation(line: 40, column: 23, scope: !859)
!864 = !DILocation(line: 41, column: 70, scope: !859)
!865 = !DILocation(line: 41, column: 68, scope: !859)
!866 = !DILocation(line: 43, column: 27, scope: !859)
!867 = !DILocation(line: 43, column: 15, scope: !859)
!868 = !DILocation(line: 44, column: 15, scope: !859)
!869 = !DILocation(line: 44, column: 21, scope: !859)
!870 = !DILocation(line: 44, column: 27, scope: !859)
!871 = !DILocation(line: 44, column: 3, scope: !859)
!872 = !DILocation(line: 39, column: 1, scope: !859)
!873 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord", scope: null, file: !611, line: 4, type: !5, scopeLine: 4, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!874 = !DILocation(line: 5, column: 10, scope: !875)
!875 = !DILexicalBlockFile(scope: !873, file: !611, discriminator: 0)
!876 = !DILocation(line: 5, column: 67, scope: !875)
!877 = !DILocation(line: 5, column: 3, scope: !875)
!878 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord", scope: null, file: !611, line: 8, type: !5, scopeLine: 8, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!879 = !DILocation(line: 9, column: 10, scope: !880)
!880 = !DILexicalBlockFile(scope: !878, file: !611, discriminator: 0)
!881 = !DILocation(line: 9, column: 67, scope: !880)
!882 = !DILocation(line: 9, column: 3, scope: !880)
!883 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord", scope: null, file: !622, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!884 = !DILocation(line: 50, column: 3, scope: !885)
!885 = !DILexicalBlockFile(scope: !883, file: !622, discriminator: 0)
!886 = !DILocation(line: 43, column: 21, scope: !885)
!887 = !DILocation(line: 50, column: 57, scope: !885)
!888 = !DILocation(line: 50, column: 68, scope: !885)
!889 = !DILocation(line: 50, column: 41, scope: !885)
!890 = !DILocation(line: 50, column: 19, scope: !885)
!891 = !DILocation(line: 52, column: 10, scope: !885)
!892 = !DILocation(line: 52, column: 18, scope: !885)
!893 = !DILocation(line: 48, column: 22, scope: !885)
!894 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr", linkageName: "sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr", scope: null, file: !895, line: 11, type: !5, scopeLine: 11, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!895 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/input_queue_config.csl", directory: "")
!896 = !DILocation(line: 11, column: 32, scope: !897)
!897 = !DILexicalBlockFile(scope: !894, file: !895, discriminator: 0)
!898 = !DILocation(line: 12, column: 80, scope: !897)
!899 = !DILocation(line: 12, column: 69, scope: !897)
!900 = !DILocation(line: 12, column: 39, scope: !897)
!901 = !DILocation(line: 12, column: 3, scope: !897)
!902 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue", linkageName: "sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue", scope: null, file: !895, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!903 = !DILocation(line: 46, column: 3, scope: !904)
!904 = !DILexicalBlockFile(scope: !902, file: !895, discriminator: 0)
!905 = !DILocation(line: 45, column: 3, scope: !904)
!906 = !DILocation(line: 39, column: 42, scope: !904)
!907 = !DILocation(line: 39, column: 34, scope: !904)
!908 = !DILocation(line: 39, column: 24, scope: !904)
!909 = !DILocation(line: 45, column: 44, scope: !904)
!910 = !DILocation(line: 45, column: 16, scope: !904)
!911 = !DILocation(line: 46, column: 30, scope: !904)
!912 = !DILocation(line: 46, column: 18, scope: !904)
!913 = !DILocation(line: 56, column: 9, scope: !904)
!914 = !DILocation(line: 56, column: 5, scope: !904)
!915 = !DILocation(line: 58, column: 13, scope: !904)
!916 = !DILocation(line: 58, column: 17, scope: !904)
!917 = !DILocation(line: 58, column: 11, scope: !904)
!918 = !DILocation(line: 61, column: 13, scope: !904)
!919 = !DILocation(line: 61, column: 17, scope: !904)
!920 = !DILocation(line: 61, column: 11, scope: !904)
!921 = !DILocation(line: 66, column: 9, scope: !904)
!922 = !DILocation(line: 66, column: 13, scope: !904)
!923 = !DILocation(line: 66, column: 7, scope: !904)
!924 = !DILocation(line: 68, column: 9, scope: !904)
!925 = !DILocation(line: 68, column: 24, scope: !904)
!926 = !DILocation(line: 68, column: 13, scope: !904)
!927 = !DILocation(line: 68, column: 7, scope: !904)
!928 = !DILocation(line: 70, column: 15, scope: !904)
!929 = !DILocation(line: 70, column: 21, scope: !904)
!930 = !DILocation(line: 70, column: 3, scope: !904)
!931 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr", linkageName: "sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr", scope: null, file: !932, line: 11, type: !5, scopeLine: 11, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!932 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/output_queue_config.csl", directory: "")
!933 = !DILocation(line: 11, column: 33, scope: !934)
!934 = !DILexicalBlockFile(scope: !931, file: !932, discriminator: 0)
!935 = !DILocation(line: 12, column: 82, scope: !934)
!936 = !DILocation(line: 12, column: 40, scope: !934)
!937 = !DILocation(line: 12, column: 3, scope: !934)
!938 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue", linkageName: "sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue", scope: null, file: !932, line: 31, type: !5, scopeLine: 31, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!939 = !DILocation(line: 38, column: 3, scope: !940)
!940 = !DILexicalBlockFile(scope: !938, file: !932, discriminator: 0)
!941 = !DILocation(line: 37, column: 3, scope: !940)
!942 = !DILocation(line: 31, column: 35, scope: !940)
!943 = !DILocation(line: 31, column: 25, scope: !940)
!944 = !DILocation(line: 37, column: 45, scope: !940)
!945 = !DILocation(line: 37, column: 16, scope: !940)
!946 = !DILocation(line: 38, column: 30, scope: !940)
!947 = !DILocation(line: 38, column: 18, scope: !940)
!948 = !DILocation(line: 41, column: 9, scope: !940)
!949 = !DILocation(line: 41, column: 13, scope: !940)
!950 = !DILocation(line: 41, column: 7, scope: !940)
!951 = !DILocation(line: 43, column: 9, scope: !940)
!952 = !DILocation(line: 43, column: 24, scope: !940)
!953 = !DILocation(line: 43, column: 13, scope: !940)
!954 = !DILocation(line: 43, column: 27, scope: !940)
!955 = !DILocation(line: 43, column: 7, scope: !940)
!956 = !DILocation(line: 45, column: 15, scope: !940)
!957 = !DILocation(line: 45, column: 21, scope: !940)
!958 = !DILocation(line: 45, column: 3, scope: !940)
!959 = !DILocation(line: 31, column: 1, scope: !940)
!960 = distinct !DISubprogram(name: ".get_tensor_ptr", linkageName: ".get_tensor_ptr", scope: null, file: !4, line: 1, type: !5, scopeLine: 1, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!961 = !DILocation(line: 1, column: 1, scope: !962)
!962 = !DILexicalBlockFile(scope: !960, file: !4, discriminator: 0)
!963 = distinct !DISubprogram(name: "__generic0sys_mod.sys_mod.tile_config.queue_flush.exit", linkageName: "__generic0sys_mod.sys_mod.tile_config.queue_flush.exit", scope: null, file: !964, line: 12, type: !5, scopeLine: 12, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!964 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/queue_flush.csl", directory: "")
!965 = !DILocation(line: 24, column: 3, scope: !966)
!966 = !DILexicalBlockFile(scope: !963, file: !964, discriminator: 0)
!967 = !DILocation(line: 12, column: 1, scope: !966)
!968 = distinct !DISubprogram(name: "__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position", linkageName: "__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position", scope: null, file: !969, line: 30, type: !5, scopeLine: 30, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!969 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/switch_config.csl", directory: "")
!970 = !DILocation(line: 34, column: 3, scope: !971)
!971 = !DILexicalBlockFile(scope: !968, file: !969, discriminator: 0)
!972 = !DILocation(line: 32, column: 3, scope: !971)
!973 = !DILocation(line: 30, column: 27, scope: !971)
!974 = !DILocation(line: 33, column: 7, scope: !971)
!975 = !DILocation(line: 34, column: 36, scope: !971)
!976 = !DILocation(line: 34, column: 24, scope: !971)
!977 = !DILocation(line: 35, column: 3, scope: !971)
!978 = !DILocation(line: 35, column: 18, scope: !971)
!979 = !DILocation(line: 36, column: 15, scope: !971)
!980 = !DILocation(line: 36, column: 21, scope: !971)
!981 = !DILocation(line: 36, column: 3, scope: !971)
!982 = !DILocation(line: 30, column: 1, scope: !971)
!983 = distinct !DISubprogram(name: "__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", linkageName: "__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", scope: null, file: !984, line: 96, type: !5, scopeLine: 96, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!984 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/color_config.csl", directory: "")
!985 = !DILocation(line: 99, column: 3, scope: !986)
!986 = !DILexicalBlockFile(scope: !983, file: !984, discriminator: 0)
!987 = !DILocation(line: 98, column: 3, scope: !986)
!988 = !DILocation(line: 96, column: 17, scope: !986)
!989 = !DILocation(line: 98, column: 16, scope: !986)
!990 = !DILocation(line: 99, column: 29, scope: !986)
!991 = !DILocation(line: 99, column: 17, scope: !986)
!992 = !DILocation(line: 100, column: 13, scope: !986)
!993 = !DILocation(line: 100, column: 21, scope: !986)
!994 = !DILocation(line: 100, column: 11, scope: !986)
!995 = !DILocation(line: 104, column: 7, scope: !986)
!996 = !DILocation(line: 104, column: 50, scope: !986)
!997 = !DILocation(line: 104, column: 18, scope: !986)
!998 = !DILocation(line: 104, column: 15, scope: !986)
!999 = !DILocation(line: 121, column: 7, scope: !986)
!1000 = !DILocation(line: 121, column: 50, scope: !986)
!1001 = !DILocation(line: 121, column: 18, scope: !986)
!1002 = !DILocation(line: 121, column: 15, scope: !986)
!1003 = !DILocation(line: 128, column: 15, scope: !986)
!1004 = !DILocation(line: 128, column: 21, scope: !986)
!1005 = !DILocation(line: 128, column: 3, scope: !986)
!1006 = !DILocation(line: 96, column: 1, scope: !986)
!1007 = distinct !DISubprogram(name: "__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", linkageName: "__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", scope: null, file: !984, line: 96, type: !5, scopeLine: 96, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1008 = !DILocation(line: 99, column: 3, scope: !1009)
!1009 = !DILexicalBlockFile(scope: !1007, file: !984, discriminator: 0)
!1010 = !DILocation(line: 98, column: 3, scope: !1009)
!1011 = !DILocation(line: 96, column: 17, scope: !1009)
!1012 = !DILocation(line: 98, column: 16, scope: !1009)
!1013 = !DILocation(line: 99, column: 29, scope: !1009)
!1014 = !DILocation(line: 99, column: 17, scope: !1009)
!1015 = !DILocation(line: 100, column: 13, scope: !1009)
!1016 = !DILocation(line: 100, column: 21, scope: !1009)
!1017 = !DILocation(line: 100, column: 11, scope: !1009)
!1018 = !DILocation(line: 104, column: 7, scope: !1009)
!1019 = !DILocation(line: 104, column: 50, scope: !1009)
!1020 = !DILocation(line: 104, column: 18, scope: !1009)
!1021 = !DILocation(line: 104, column: 15, scope: !1009)
!1022 = !DILocation(line: 121, column: 7, scope: !1009)
!1023 = !DILocation(line: 121, column: 50, scope: !1009)
!1024 = !DILocation(line: 121, column: 18, scope: !1009)
!1025 = !DILocation(line: 121, column: 15, scope: !1009)
!1026 = !DILocation(line: 128, column: 15, scope: !1009)
!1027 = !DILocation(line: 128, column: 21, scope: !1009)
!1028 = !DILocation(line: 128, column: 3, scope: !1009)
!1029 = !DILocation(line: 96, column: 1, scope: !1009)
!1030 = distinct !DISubprogram(name: "__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", linkageName: "__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", scope: null, file: !984, line: 60, type: !5, scopeLine: 60, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1031 = !DILocation(line: 61, column: 3, scope: !1032)
!1032 = !DILexicalBlockFile(scope: !1030, file: !984, discriminator: 0)
!1033 = !DILocation(line: 60, column: 46, scope: !1032)
!1034 = !DILocation(line: 61, column: 16, scope: !1032)
!1035 = !DILocation(line: 72, column: 5, scope: !1032)
!1036 = !DILocation(line: 72, column: 12, scope: !1032)
!1037 = !DILocation(line: 74, column: 10, scope: !1032)
!1038 = !DILocation(line: 74, column: 3, scope: !1032)
!1039 = distinct !DISubprogram(name: "__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes", linkageName: "__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes", scope: null, file: !984, line: 77, type: !5, scopeLine: 77, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1040 = !DILocation(line: 78, column: 3, scope: !1041)
!1041 = !DILexicalBlockFile(scope: !1039, file: !984, discriminator: 0)
!1042 = !DILocation(line: 77, column: 46, scope: !1041)
!1043 = !DILocation(line: 78, column: 16, scope: !1041)
!1044 = !DILocation(line: 86, column: 5, scope: !1041)
!1045 = !DILocation(line: 86, column: 12, scope: !1041)
!1046 = !DILocation(line: 91, column: 10, scope: !1041)
!1047 = !DILocation(line: 91, column: 3, scope: !1041)
!1048 = distinct !DISubprogram(name: "__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", linkageName: "__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", scope: null, file: !984, line: 60, type: !5, scopeLine: 60, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1049 = !DILocation(line: 61, column: 3, scope: !1050)
!1050 = !DILexicalBlockFile(scope: !1048, file: !984, discriminator: 0)
!1051 = !DILocation(line: 60, column: 46, scope: !1050)
!1052 = !DILocation(line: 61, column: 16, scope: !1050)
!1053 = !DILocation(line: 63, column: 5, scope: !1050)
!1054 = !DILocation(line: 63, column: 12, scope: !1050)
!1055 = !DILocation(line: 74, column: 10, scope: !1050)
!1056 = !DILocation(line: 74, column: 3, scope: !1050)
!1057 = distinct !DISubprogram(name: "__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction", linkageName: "__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction", scope: null, file: !984, line: 52, type: !5, scopeLine: 52, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1058 = !DILocation(line: 55, column: 3, scope: !1059)
!1059 = !DILexicalBlockFile(scope: !1057, file: !984, discriminator: 0)
!1060 = !DILocation(line: 54, column: 3, scope: !1059)
!1061 = !DILocation(line: 52, column: 23, scope: !1059)
!1062 = !DILocation(line: 54, column: 16, scope: !1059)
!1063 = !DILocation(line: 55, column: 29, scope: !1059)
!1064 = !DILocation(line: 55, column: 17, scope: !1059)
!1065 = !DILocation(line: 56, column: 3, scope: !1059)
!1066 = !DILocation(line: 56, column: 11, scope: !1059)
!1067 = !DILocation(line: 57, column: 15, scope: !1059)
!1068 = !DILocation(line: 57, column: 21, scope: !1059)
!1069 = !DILocation(line: 57, column: 3, scope: !1059)
!1070 = !DILocation(line: 52, column: 1, scope: !1059)
!1071 = distinct !DISubprogram(name: "__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction", linkageName: "__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction", scope: null, file: !984, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1072 = !DILocation(line: 23, column: 3, scope: !1073)
!1073 = !DILexicalBlockFile(scope: !1071, file: !984, discriminator: 0)
!1074 = !DILocation(line: 22, column: 3, scope: !1073)
!1075 = !DILocation(line: 20, column: 21, scope: !1073)
!1076 = !DILocation(line: 22, column: 16, scope: !1073)
!1077 = !DILocation(line: 23, column: 29, scope: !1073)
!1078 = !DILocation(line: 23, column: 17, scope: !1073)
!1079 = !DILocation(line: 24, column: 3, scope: !1073)
!1080 = !DILocation(line: 24, column: 11, scope: !1073)
!1081 = !DILocation(line: 25, column: 15, scope: !1073)
!1082 = !DILocation(line: 25, column: 21, scope: !1073)
!1083 = !DILocation(line: 25, column: 3, scope: !1073)
!1084 = !DILocation(line: 20, column: 1, scope: !1073)
module asm ".section \22.pe_debug_info\22, \22\22"
module asm ".section \22.note\22, \22\22"
