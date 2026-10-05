; ModuleID = './layout.csl'
source_filename = "./layout.csl"
target datalayout = "e-ni:0-p:16:16-i1:16-i16:16-i32:32-i64:64-f32:32-f64:64"
target triple = "cs_sdr-cerebras-csos"

@a = internal global [8 x i16] zeroinitializer, align 4
@b = internal global [8 x i16] zeroinitializer, align 4
@g = internal global [8 x i16] zeroinitializer, align 4
@c = internal global [80 x i16] zeroinitializer, align 4
@d = internal global [8 x i16] zeroinitializer, align 4
@"$$csl_base_address$$0$$af" = dso_local global [8 x half] zeroinitializer, align 4
@bf = internal global [8 x half] zeroinitializer, align 4
@gf = internal global [8 x half] zeroinitializer, align 4
@cf = internal global [16 x half] zeroinitializer, align 4
@mark = internal global [16 x i16] zeroinitializer, align 4
@p_a = internal global i16* getelementptr inbounds ([8 x i16], [8 x i16]* @a, i32 0, i32 0), align 4
@p_b = internal global i16* getelementptr inbounds ([8 x i16], [8 x i16]* @b, i32 0, i32 0), align 4
@p_g = internal global i16* getelementptr inbounds ([8 x i16], [8 x i16]* @g, i32 0, i32 0), align 4
@p_c = internal global i16* getelementptr inbounds ([80 x i16], [80 x i16]* @c, i32 0, i32 0), align 4
@p_d = internal global i16* getelementptr inbounds ([8 x i16], [8 x i16]* @d, i32 0, i32 0), align 4
@p_af = internal global half* getelementptr inbounds ([8 x half], [8 x half]* @"$$csl_base_address$$0$$af", i32 0, i32 0), align 4
@p_bf = internal global half* getelementptr inbounds ([8 x half], [8 x half]* @bf, i32 0, i32 0), align 4
@p_gf = internal global half* getelementptr inbounds ([8 x half], [8 x half]* @gf, i32 0, i32 0), align 4
@p_cf = internal global half* getelementptr inbounds ([16 x half], [16 x half]* @cf, i32 0, i32 0), align 4
@p_mark = internal global i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i32 0, i32 0), align 4
@acc0 = internal global half 0xH0000, align 4
@acc1 = internal global half 0xH0000, align 4
@acc2 = internal global half 0xH0000, align 4
@acc3 = internal global half 0xH0000, align 4
@acc4 = internal global half 0xH0000, align 4
@acc5 = internal global half 0xH0000, align 4
@acc6 = internal global half 0xH0000, align 4
@acc7 = internal global half 0xH0000, align 4
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
@"$$csl_base_address$$3$$sys_mod.sys_mod.memcpyh2d_mod_1.dummy" = dso_local constant [1 x i16] zeroinitializer, align 4
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
@"$$csl_base_address$$2$$sys_mod.sys_mod.memcpyd2h_mod.dummy" = dso_local constant [1 x i16] zeroinitializer, align 4
@sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd = internal global <{ i16, i16, i16, i16 }> <{ i16 1, i16 lshr (i16 ptrtoint ([1 x i16]* @"$$csl_base_address$$2$$sys_mod.sys_mod.memcpyd2h_mod.dummy" to i16), i16 1), i16 143, i16 16 }>, align 4
@"$$csl_base_address$$1$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11" = dso_local global [1 x i32] [i32 190812745], align 4
@sys_mod.sys_mod.memcpyd2h_mod.ctrl_1 = internal global [1 x i32] [i32 157258313], align 4
@sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd = internal global <{ i16, i16, i16, i16 }> <{ i16 1, i16 lshr (i16 ptrtoint ([1 x i32]* @"$$csl_base_address$$1$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11" to i16), i16 1), i16 143, i16 16 }>, align 4
@"$$csl_base_address$$5$$sys_mod.sys_mod.memcpyd2h_mod.sw_td" = dso_local global [2 x i32] zeroinitializer, align 4
@"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.teardown_buf" = dso_local constant [1 x i32] [i32 165646921], align 4
@__dsr_lowmeminit_ = internal constant <{ i16, i16, i16, i16 }> <{ i16 8, i16 lshr (i16 ptrtoint ([8 x half]* @"$$csl_base_address$$0$$af" to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__0 = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 62, i16 142, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__1 = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 4127, i16 142, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__2 = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 lshr (i16 ptrtoint ([1 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.teardown_buf" to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__3 = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 4149, i16 142, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__4 = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 4096, i16 142, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__5 = internal constant <{ i16, i16, i16, i16 }> <{ i16 2, i16 4127, i16 142, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__6 = internal constant <{ i16, i16, i16, i16 }> <{ i16 2, i16 lshr (i16 ptrtoint ([2 x i32]* @"$$csl_base_address$$5$$sys_mod.sys_mod.memcpyd2h_mod.sw_td" to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4

declare i8* @malloc(i64)

declare void @free(i8*)

define internal void @compute() !dbg !3 {
  store i16 24576, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i1 false), align 2, !dbg !7
  %1 = load half, half* @acc0, align 2, !dbg !9
  call void @llvm.sdr.lds1wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !10
  %2 = call half @llvm.sdr.faddh.rrs1.f16(half %1, i16 1), !dbg !10
  store half %2, half* @acc0, align 2, !dbg !10
  %3 = load half, half* @acc0, align 2, !dbg !11
  store half %3, half* getelementptr inbounds ([16 x half], [16 x half]* @cf, i16 0, i1 false), align 2, !dbg !12
  store i16 24577, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i2 1), align 2, !dbg !13
  %4 = load half, half* @acc1, align 2, !dbg !14
  call void @llvm.sdr.lds1wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !15
  %5 = call half @llvm.sdr.faddh.rrs1.f16(half %4, i16 1), !dbg !15
  call void asm sideeffect "nop", ""()
  store half %5, half* @acc1, align 2, !dbg !15
  %6 = load half, half* @acc1, align 2, !dbg !16
  store half %6, half* getelementptr inbounds ([16 x half], [16 x half]* @cf, i16 0, i2 1), align 2, !dbg !17
  store i16 24578, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i3 2), align 2, !dbg !18
  %7 = load half, half* @acc2, align 2, !dbg !19
  call void @llvm.sdr.lds1wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !20
  %8 = call half @llvm.sdr.faddh.rrs1.f16(half %7, i16 1), !dbg !20
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  store half %8, half* @acc2, align 2, !dbg !20
  %9 = load half, half* @acc2, align 2, !dbg !21
  store half %9, half* getelementptr inbounds ([16 x half], [16 x half]* @cf, i16 0, i3 2), align 2, !dbg !22
  store i16 24579, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i3 3), align 2, !dbg !23
  %10 = load half, half* @acc3, align 2, !dbg !24
  call void @llvm.sdr.lds1wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !25
  %11 = call half @llvm.sdr.faddh.rrs1.f16(half %10, i16 1), !dbg !25
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  store half %11, half* @acc3, align 2, !dbg !25
  %12 = load half, half* @acc3, align 2, !dbg !26
  store half %12, half* getelementptr inbounds ([16 x half], [16 x half]* @cf, i16 0, i3 3), align 2, !dbg !27
  store i16 24580, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i4 4), align 2, !dbg !28
  %13 = load half, half* @acc4, align 2, !dbg !29
  call void @llvm.sdr.lds1wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !30
  %14 = call half @llvm.sdr.faddh.rrs1.f16(half %13, i16 1), !dbg !30
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  store half %14, half* @acc4, align 2, !dbg !30
  %15 = load half, half* @acc4, align 2, !dbg !31
  store half %15, half* getelementptr inbounds ([16 x half], [16 x half]* @cf, i16 0, i4 4), align 2, !dbg !32
  store i16 24581, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i4 5), align 2, !dbg !33
  %16 = load half, half* @acc5, align 2, !dbg !34
  call void @llvm.sdr.lds1wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !35
  %17 = call half @llvm.sdr.faddh.rrs1.f16(half %16, i16 1), !dbg !35
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  store half %17, half* @acc5, align 2, !dbg !35
  %18 = load half, half* @acc5, align 2, !dbg !36
  store half %18, half* getelementptr inbounds ([16 x half], [16 x half]* @cf, i16 0, i4 5), align 2, !dbg !37
  store i16 24582, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i4 6), align 2, !dbg !38
  %19 = load half, half* @acc6, align 2, !dbg !39
  call void @llvm.sdr.lds1wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !40
  %20 = call half @llvm.sdr.faddh.rrs1.f16(half %19, i16 1), !dbg !40
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  store half %20, half* @acc6, align 2, !dbg !40
  %21 = load half, half* @acc6, align 2, !dbg !41
  store half %21, half* getelementptr inbounds ([16 x half], [16 x half]* @cf, i16 0, i4 6), align 2, !dbg !42
  store i16 24583, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i4 7), align 2, !dbg !43
  %22 = load half, half* @acc7, align 2, !dbg !44
  call void @llvm.sdr.lds1wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !45
  %23 = call half @llvm.sdr.faddh.rrs1.f16(half %22, i16 1), !dbg !45
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  store half %23, half* @acc7, align 2, !dbg !45
  %24 = load half, half* @acc7, align 2, !dbg !46
  store half %24, half* getelementptr inbounds ([16 x half], [16 x half]* @cf, i16 0, i4 7), align 2, !dbg !47
  store i16 24584, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i5 8), align 2, !dbg !48
  call void @llvm.sdr.actvt.r(i16 9), !dbg !49
  ret void, !dbg !50
}

define void @f_exit() #0 !dbg !51 {
  call void @sys_mod.unblock_cmd_stream(), !dbg !52
  ret void, !dbg !54
}

define internal void @sys_mod.sys_nop() !dbg !55 {
  ret void, !dbg !57
}

define internal void @sys_mod.unblock_cmd_stream() !dbg !59 {
  call void @sys_mod.sys_mod.unblock_cmd_stream(), !dbg !60
  ret void, !dbg !62
}

define internal void @sys_mod.sys_mod.unblock_cmd_stream() !dbg !63 {
  call void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream(), !dbg !65
  ret void, !dbg !67
}

define internal void @sys_mod.sys_mod.teardown_h2d() !dbg !68 {
  call void @llvm.sdr.actvt.r(i16 27), !dbg !69
  ret void, !dbg !71
}

define void @sys_mod.sys_mod.f_ublk_c22() #1 !dbg !72 {
  call void @sys_mod.sys_mod.unblock_cmd_stream(), !dbg !73
  ret void, !dbg !75
}

define internal void @sys_mod.sys_mod.teardown_d2h() !dbg !76 {
  call void @llvm.sdr.blk.r(i16 0), !dbg !77
  call void @llvm.sdr.actvt.r(i16 28), !dbg !79
  ret void, !dbg !80
}

define void @sys_mod.sys_mod.f_memcpyh2d() #2 !dbg !81 {
  %1 = alloca float, i16 1, align 4, !dbg !82
  %2 = alloca float, i16 1, align 4, !dbg !84
  %3 = alloca i16, i16 1, align 2, !dbg !85
  %4 = alloca i16, i16 1, align 2, !dbg !86
  %5 = alloca i16, i16 1, align 2, !dbg !87
  %6 = alloca i16, i16 1, align 2, !dbg !88
  %7 = alloca i16, i16 1, align 2, !dbg !89
  %8 = alloca i16, i16 1, align 2, !dbg !90
  %9 = alloca i16, i16 1, align 2, !dbg !91
  %10 = alloca i16, i16 1, align 2, !dbg !92
  %11 = alloca i16, i16 1, align 2, !dbg !93
  %12 = alloca i16, i16 1, align 2, !dbg !94
  %13 = alloca i16, i16 1, align 2, !dbg !95
  %14 = alloca i16*, i16 1, align 8, !dbg !96
  %15 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !97
  %16 = icmp eq i16 %15, 15, !dbg !98
  br i1 %16, label %17, label %18, !dbg !99

17:                                               ; preds = %0
  br label %19, !dbg !99

18:                                               ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !99
  br label %19, !dbg !99

19:                                               ; preds = %17, %18
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %14, align 8, !dbg !96
  %20 = load i16*, i16** %14, align 8, !dbg !100
  %21 = load i16, i16* %20, align 2, !dbg !101
  store i16 %21, i16* %13, align 2, !dbg !95
  %22 = load i16*, i16** %14, align 8, !dbg !102
  %23 = getelementptr i16, i16* %22, i16 1, !dbg !103
  %24 = load i16, i16* %23, align 2, !dbg !103
  store i16 %24, i16* %12, align 2, !dbg !94
  %25 = load i16*, i16** %14, align 8, !dbg !104
  %26 = getelementptr i16, i16* %25, i16 2, !dbg !105
  %27 = load i16, i16* %26, align 2, !dbg !105
  store i16 %27, i16* %11, align 2, !dbg !93
  %28 = load i16*, i16** %14, align 8, !dbg !106
  %29 = getelementptr i16, i16* %28, i16 3, !dbg !107
  %30 = load i16, i16* %29, align 2, !dbg !107
  store i16 %30, i16* %10, align 2, !dbg !92
  %31 = load i16*, i16** %14, align 8, !dbg !108
  %32 = getelementptr i16, i16* %31, i16 4, !dbg !109
  %33 = load i16, i16* %32, align 2, !dbg !109
  store i16 %33, i16* %9, align 2, !dbg !91
  %34 = load i16*, i16** %14, align 8, !dbg !110
  %35 = getelementptr i16, i16* %34, i16 5, !dbg !111
  %36 = load i16, i16* %35, align 2, !dbg !111
  store i16 %36, i16* %8, align 2, !dbg !90
  %37 = load i16*, i16** %14, align 8, !dbg !112
  %38 = getelementptr i16, i16* %37, i16 6, !dbg !113
  %39 = load i16, i16* %38, align 2, !dbg !113
  store i16 %39, i16* %7, align 2, !dbg !89
  %40 = load i16*, i16** %14, align 8, !dbg !114
  %41 = getelementptr i16, i16* %40, i16 7, !dbg !115
  %42 = load i16, i16* %41, align 2, !dbg !115
  store i16 %42, i16* %6, align 2, !dbg !88
  %43 = load i16*, i16** %14, align 8, !dbg !116
  %44 = getelementptr i16, i16* %43, i16 8, !dbg !117
  %45 = load i16, i16* %44, align 2, !dbg !117
  store i16 %45, i16* %5, align 2, !dbg !87
  %46 = load i16*, i16** %14, align 8, !dbg !118
  %47 = getelementptr i16, i16* %46, i16 9, !dbg !119
  %48 = load i16, i16* %47, align 2, !dbg !119
  store i16 %48, i16* %4, align 2, !dbg !86
  %49 = load i16*, i16** %14, align 8, !dbg !120
  %50 = getelementptr i16, i16* %49, i16 10, !dbg !121
  %51 = load i16, i16* %50, align 2, !dbg !121
  store i16 %51, i16* %3, align 2, !dbg !85
  %52 = load i16*, i16** %14, align 8, !dbg !122
  %53 = getelementptr i16, i16* %52, i16 12, !dbg !123
  %54 = load i16, i16* %53, align 2, !dbg !123
  %55 = zext i16 %54 to i32, !dbg !124
  %56 = load i16*, i16** %14, align 8, !dbg !125
  %57 = getelementptr i16, i16* %56, i16 11, !dbg !126
  %58 = load i16, i16* %57, align 2, !dbg !126
  %59 = zext i16 %58 to i32, !dbg !127
  %60 = add i32 %59, 16, !dbg !128
  %61 = shl i32 %55, %60, !dbg !129
  %62 = bitcast i32 %61 to float, !dbg !130
  store float %62, float* %2, align 4, !dbg !84
  %63 = load i16*, i16** %14, align 8, !dbg !131
  %64 = getelementptr i16, i16* %63, i16 14, !dbg !132
  %65 = load i16, i16* %64, align 2, !dbg !132
  %66 = zext i16 %65 to i32, !dbg !133
  %67 = load i16*, i16** %14, align 8, !dbg !134
  %68 = getelementptr i16, i16* %67, i16 13, !dbg !135
  %69 = load i16, i16* %68, align 2, !dbg !135
  %70 = zext i16 %69 to i32, !dbg !136
  %71 = add i32 %70, 16, !dbg !137
  %72 = shl i32 %66, %71, !dbg !138
  %73 = bitcast i32 %72 to float, !dbg !139
  store float %73, float* %1, align 4, !dbg !82
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !140
  %74 = load i16, i16* %13, align 2, !dbg !141
  store i16 %74, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !142
  %75 = load i16, i16* %12, align 2, !dbg !143
  store i16 %75, i16* @sys_mod.sys_mod.memcpyH2D_px, align 2, !dbg !144
  %76 = load i16, i16* %11, align 2, !dbg !145
  store i16 %76, i16* @sys_mod.sys_mod.memcpyH2D_py, align 2, !dbg !146
  %77 = load i16, i16* %10, align 2, !dbg !147
  store i16 %77, i16* @sys_mod.sys_mod.memcpyH2D_w, align 2, !dbg !148
  %78 = load i16, i16* %9, align 2, !dbg !149
  store i16 %78, i16* @sys_mod.sys_mod.memcpyH2D_h, align 2, !dbg !150
  %79 = load i16, i16* %8, align 2, !dbg !151
  store i16 %79, i16* @sys_mod.sys_mod.memcpyH2D_addr, align 2, !dbg !152
  %80 = load i16, i16* %7, align 2, !dbg !153
  store i16 %80, i16* @sys_mod.sys_mod.memcpyH2D_pe_length, align 2, !dbg !154
  %81 = load i16, i16* %6, align 2, !dbg !155
  store i16 %81, i16* @sys_mod.sys_mod.memcpyH2D_is_half, align 2, !dbg !156
  %82 = load i16, i16* %5, align 2, !dbg !157
  store i16 %82, i16* @sys_mod.sys_mod.memcpyH2D_memcpy_optype, align 2, !dbg !158
  %83 = load i16, i16* %4, align 2, !dbg !159
  store i16 %83, i16* @sys_mod.sys_mod.memcpyH2D_row_stride, align 2, !dbg !160
  %84 = load i16, i16* %3, align 2, !dbg !161
  store i16 %84, i16* @sys_mod.sys_mod.memcpyH2D_col_stride, align 2, !dbg !162
  %85 = load float, float* %2, align 4, !dbg !163
  store float %85, float* @sys_mod.sys_mod.memcpyH2D_one_over_row_stride, align 4, !dbg !164
  %86 = load float, float* %1, align 4, !dbg !165
  store float %86, float* @sys_mod.sys_mod.memcpyH2D_one_over_col_stride, align 4, !dbg !166
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !167
  call void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 0, i16 23, i1 true), !dbg !168
  call void @llvm.sdr.blk.r(i16 27), !dbg !169
  call void @llvm.sdr.oqflush(i16 0), !dbg !170
  store i1 true, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !171
  call void @llvm.sdr.blk.r(i16 0), !dbg !172
  ret void, !dbg !173
}

define void @sys_mod.sys_mod.f_memcpyd2h() #3 !dbg !174 {
  %1 = alloca i16, i16 1, align 2, !dbg !175
  %2 = alloca i16, i16 1, align 2, !dbg !177
  %3 = alloca i16, i16 1, align 2, !dbg !178
  %4 = alloca i16, i16 1, align 2, !dbg !179
  %5 = alloca i16, i16 1, align 2, !dbg !180
  %6 = alloca i16, i16 1, align 2, !dbg !181
  %7 = alloca i16, i16 1, align 2, !dbg !182
  %8 = alloca i16, i16 1, align 2, !dbg !183
  %9 = alloca i16*, i16 1, align 8, !dbg !184
  %10 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !185
  %11 = icmp eq i16 %10, 8, !dbg !186
  br i1 %11, label %12, label %13, !dbg !187

12:                                               ; preds = %0
  br label %14, !dbg !187

13:                                               ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !187
  br label %14, !dbg !187

14:                                               ; preds = %12, %13
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %9, align 8, !dbg !184
  %15 = load i16*, i16** %9, align 8, !dbg !188
  %16 = load i16, i16* %15, align 2, !dbg !189
  store i16 %16, i16* %8, align 2, !dbg !183
  %17 = load i16*, i16** %9, align 8, !dbg !190
  %18 = getelementptr i16, i16* %17, i16 1, !dbg !191
  %19 = load i16, i16* %18, align 2, !dbg !191
  store i16 %19, i16* %7, align 2, !dbg !182
  %20 = load i16*, i16** %9, align 8, !dbg !192
  %21 = getelementptr i16, i16* %20, i16 2, !dbg !193
  %22 = load i16, i16* %21, align 2, !dbg !193
  store i16 %22, i16* %6, align 2, !dbg !181
  %23 = load i16*, i16** %9, align 8, !dbg !194
  %24 = getelementptr i16, i16* %23, i16 3, !dbg !195
  %25 = load i16, i16* %24, align 2, !dbg !195
  store i16 %25, i16* %5, align 2, !dbg !180
  %26 = load i16*, i16** %9, align 8, !dbg !196
  %27 = getelementptr i16, i16* %26, i16 4, !dbg !197
  %28 = load i16, i16* %27, align 2, !dbg !197
  store i16 %28, i16* %4, align 2, !dbg !179
  %29 = load i16*, i16** %9, align 8, !dbg !198
  %30 = getelementptr i16, i16* %29, i16 5, !dbg !199
  %31 = load i16, i16* %30, align 2, !dbg !199
  store i16 %31, i16* %3, align 2, !dbg !178
  %32 = load i16*, i16** %9, align 8, !dbg !200
  %33 = getelementptr i16, i16* %32, i16 6, !dbg !201
  %34 = load i16, i16* %33, align 2, !dbg !201
  store i16 %34, i16* %2, align 2, !dbg !177
  %35 = load i16*, i16** %9, align 8, !dbg !202
  %36 = getelementptr i16, i16* %35, i16 7, !dbg !203
  %37 = load i16, i16* %36, align 2, !dbg !203
  store i16 %37, i16* %1, align 2, !dbg !175
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !204
  %38 = load i16, i16* %8, align 2, !dbg !205
  store i16 %38, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !206
  %39 = load i16, i16* %7, align 2, !dbg !207
  store i16 %39, i16* @sys_mod.sys_mod.memcpyD2H_px, align 2, !dbg !208
  %40 = load i16, i16* %6, align 2, !dbg !209
  store i16 %40, i16* @sys_mod.sys_mod.memcpyD2H_py, align 2, !dbg !210
  %41 = load i16, i16* %5, align 2, !dbg !211
  store i16 %41, i16* @sys_mod.sys_mod.memcpyD2H_w, align 2, !dbg !212
  %42 = load i16, i16* %4, align 2, !dbg !213
  store i16 %42, i16* @sys_mod.sys_mod.memcpyD2H_h, align 2, !dbg !214
  %43 = load i16, i16* %3, align 2, !dbg !215
  store i16 %43, i16* @sys_mod.sys_mod.memcpyD2H_addr, align 2, !dbg !216
  %44 = load i16, i16* %2, align 2, !dbg !217
  store i16 %44, i16* @sys_mod.sys_mod.memcpyD2H_pe_length, align 2, !dbg !218
  %45 = load i16, i16* %1, align 2, !dbg !219
  store i16 %45, i16* @sys_mod.sys_mod.memcpyD2H_is_half, align 2, !dbg !220
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !221
  %46 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !222
  call void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 0, i16 %46, i1 false), !dbg !223
  call void @llvm.sdr.oqflush(i16 0), !dbg !224
  store i1 false, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !225
  ret void, !dbg !226
}

define internal void @sys_mod.sys_mod.oq0_teardow_handler() !dbg !227 {
  %1 = load i1, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !228
  br i1 %1, label %2, label %17, !dbg !230

2:                                                ; preds = %0
  %3 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !231
  call void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 0, i16 %3), !dbg !232
  %4 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !233
  %5 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_px, align 2, !dbg !234
  %6 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_py, align 2, !dbg !235
  %7 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_w, align 2, !dbg !236
  %8 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_h, align 2, !dbg !237
  %9 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_addr, align 2, !dbg !238
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_pe_length, align 2, !dbg !239
  %11 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_is_half, align 2, !dbg !240
  %12 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_memcpy_optype, align 2, !dbg !241
  %13 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_row_stride, align 2, !dbg !242
  %14 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_col_stride, align 2, !dbg !243
  %15 = load float, float* @sys_mod.sys_mod.memcpyH2D_one_over_row_stride, align 4, !dbg !244
  %16 = load float, float* @sys_mod.sys_mod.memcpyH2D_one_over_col_stride, align 4, !dbg !245
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure(i16 %4, i16 %5, i16 %6, i16 %7, i16 %8, i16 %9, i16 %10, i16 %11, i16 %12, i16 %13, i16 %14, float %15, float %16), !dbg !246
  br label %26, !dbg !230

17:                                               ; preds = %0
  call void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 0, i16 21), !dbg !247
  %18 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !248
  %19 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_px, align 2, !dbg !249
  %20 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_py, align 2, !dbg !250
  %21 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_w, align 2, !dbg !251
  %22 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_h, align 2, !dbg !252
  %23 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_addr, align 2, !dbg !253
  %24 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_pe_length, align 2, !dbg !254
  %25 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_is_half, align 2, !dbg !255
  call void @sys_mod.sys_mod.memcpyd2h_mod.d2h_configure(i16 %18, i16 %19, i16 %20, i16 %21, i16 %22, i16 %23, i16 %24, i16 %25), !dbg !256
  br label %26, !dbg !230

26:                                               ; preds = %2, %17
  call void @__generic0sys_mod.sys_mod.tile_config.queue_flush.exit(), !dbg !257
  ret void, !dbg !230
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

define void @sys_mod.sys_mod.f_rpc(i16 %0) #4 !dbg !258 {
  %2 = alloca i16, i16 1, align 2, !dbg !259
  store i16 %0, i16* %2, align 2, !dbg !259
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !261
  %3 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !262
  %4 = icmp sge i16 %3, 4, !dbg !263
  br i1 %4, label %5, label %6, !dbg !264

5:                                                ; preds = %1
  br label %7, !dbg !264

6:                                                ; preds = %1
  call void asm sideeffect "hcf", ""(), !dbg !264
  br label %7, !dbg !264

7:                                                ; preds = %5, %6
  call void @rpc_server(i32* getelementptr inbounds ([32 x i32], [32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32, i32 0, i32 0)), !dbg !265
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !266
  ret void, !dbg !267
}

define internal void @sys_mod.sys_mod.sys_mod.stack_push(i16 %0) !dbg !268 {
  %2 = alloca i16*, i16 1, align 8, !dbg !270
  %3 = alloca i16, i16 1, align 2, !dbg !272
  store i16 %0, i16* %3, align 2, !dbg !272
  %4 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !273
  %5 = icmp slt i16 %4, 32, !dbg !274
  br i1 %5, label %6, label %7, !dbg !275

6:                                                ; preds = %1
  br label %8, !dbg !275

7:                                                ; preds = %1
  call void asm sideeffect "hcf", ""(), !dbg !275
  br label %8, !dbg !275

8:                                                ; preds = %6, %7
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %2, align 8, !dbg !270
  %9 = load i16, i16* %3, align 2, !dbg !276
  %10 = load i16*, i16** %2, align 8, !dbg !277
  %11 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !278
  %12 = getelementptr i16, i16* %10, i16 %11, !dbg !279
  store i16 %9, i16* %12, align 2, !dbg !280
  %13 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !281
  %14 = add i16 %13, 1, !dbg !282
  store i16 %14, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !283
  ret void, !dbg !284
}

define void @sys_mod.sys_mod.sys_mod.f_push(i16 %0, i16 %1) #5 !dbg !285 {
  %3 = alloca i16, i16 1, align 2, !dbg !286
  %4 = alloca i16, i16 1, align 2, !dbg !288
  store i16 %0, i16* %4, align 2, !dbg !288
  store i16 %1, i16* %3, align 2, !dbg !286
  %5 = load i16, i16* %4, align 2, !dbg !289
  call void @sys_mod.sys_mod.sys_mod.stack_push(i16 %5), !dbg !290
  ret void, !dbg !291
}

define internal void @sys_mod.sys_mod.sys_mod.block_cmd_stream() !dbg !292 {
  call void @llvm.sdr.blk.r(i16 1), !dbg !293
  ret void, !dbg !295
}

define internal void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream() !dbg !296 {
  call void @llvm.sdr.ublk.r(i16 1), !dbg !297
  ret void, !dbg !299
}

define void @sys_mod.sys_mod.sys_mod.f_sys_exit() #6 !dbg !300 {
  call void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream(), !dbg !301
  call void @sys_mod.sys_nop(), !dbg !303
  ret void, !dbg !304
}

define void @sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore(i32 %0) #7 !dbg !305 {
  %2 = alloca i32, i16 1, align 4, !dbg !306
  store i32 %0, i32* %2, align 4, !dbg !306
  ret void, !dbg !308
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord() !dbg !309 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord(), !dbg !311
  ret i16 %1, !dbg !313
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord() !dbg !314 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord(), !dbg !315
  ret i16 %1, !dbg !317
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval(i16 %0) !dbg !318 {
  %2 = alloca i16, i16 1, align 2, !dbg !319
  store i16 %0, i16* %2, align 2, !dbg !319
  %3 = load i16, i16* %2, align 2, !dbg !321
  %4 = icmp ult i16 %3, 24, !dbg !322
  br i1 %4, label %5, label %7, !dbg !323

5:                                                ; preds = %10, %11, %1
  %6 = phi i16 [ 0, %10 ], [ 0, %11 ], [ 1, %1 ]
  br label %12, !dbg !323

7:                                                ; preds = %1
  %8 = load i16, i16* %2, align 2, !dbg !324
  %9 = icmp eq i16 31, %8, !dbg !325
  br i1 %9, label %10, label %11, !dbg !326

10:                                               ; preds = %7
  br label %5, !dbg !326

11:                                               ; preds = %7
  call void asm sideeffect "hcf", ""(), !dbg !326
  br label %5, !dbg !326

12:                                               ; preds = %5
  %13 = phi i16 [ %6, %5 ]
  br label %14, !dbg !323

14:                                               ; preds = %12
  ret i16 %13, !dbg !323
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start(i16 %0, i16 %1, i16 %2) !dbg !327 {
  %4 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !328
  %5 = alloca i16, i16 1, align 2, !dbg !330
  %6 = alloca i16, i16 1, align 2, !dbg !331
  %7 = alloca i16, i16 1, align 2, !dbg !332
  store i16 %0, i16* %7, align 2, !dbg !332
  store i16 %1, i16* %6, align 2, !dbg !331
  store i16 %2, i16* %5, align 2, !dbg !330
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !333
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !333
  %10 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !333
  %11 = load i16, i16* %6, align 2, !dbg !334
  store i16 %11, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !335
  store i16 %8, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !335
  store i16 %9, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !335
  store i16 %10, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !335
  %12 = load i16, i16* %7, align 2, !dbg !336
  %13 = call i16* @.get_tensor_ptr(i16 %12), !dbg !337
  %14 = ptrtoint i16* %13 to i16, !dbg !338
  %15 = lshr i16 %14, 1, !dbg !338
  %16 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !328
  store i16 42, i16* %16, align 2, !dbg !328
  %17 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !328
  store i16 %15, i16* %17, align 2, !dbg !328
  %18 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !328
  store i16 143, i16* %18, align 2, !dbg !328
  %19 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !328
  store i16 16, i16* %19, align 2, !dbg !328
  %20 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !339
  %21 = load i16, i16* %20, align 2, !dbg !339
  %22 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !339
  %23 = load i16, i16* %22, align 2, !dbg !339
  %24 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !339
  %25 = load i16, i16* %24, align 2, !dbg !339
  %26 = load i16, i16* %6, align 2, !dbg !340
  %27 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !341
  store i16 %26, i16* %27, align 2, !dbg !341
  %28 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !341
  store i16 %21, i16* %28, align 2, !dbg !341
  %29 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !341
  store i16 %23, i16* %29, align 2, !dbg !341
  %30 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !341
  store i16 %25, i16* %30, align 2, !dbg !341
  %31 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !342
  %32 = load i16, i16* %31, align 2, !dbg !342
  %33 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !342
  %34 = load i16, i16* %33, align 2, !dbg !342
  %35 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !342
  %36 = load i16, i16* %35, align 2, !dbg !342
  %37 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !342
  %38 = load i16, i16* %37, align 2, !dbg !342
  store volatile i16 %32, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !343
  store volatile i16 %34, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !343
  store volatile i16 %36, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !343
  store volatile i16 %38, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !343
  call void asm sideeffect "nop", ""(), !dbg !343
  call void asm sideeffect "nop", ""(), !dbg !343
  %39 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !344
  %40 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !344
  %41 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !344
  %42 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !344
  %43 = and i16 %41, -193, !dbg !344
  %44 = or i16 %43, 128, !dbg !344
  %45 = and i16 %40, -64, !dbg !344
  %46 = or i16 %45, 27, !dbg !344
  store volatile i16 %39, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !345
  store volatile i16 %46, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !345
  store volatile i16 %44, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !345
  store volatile i16 %42, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !345
  call void asm sideeffect "nop", ""(), !dbg !345
  call void asm sideeffect "nop", ""(), !dbg !345
  %47 = load i16, i16* %5, align 2, !dbg !346
  %48 = icmp ult i16 0, %47, !dbg !347
  br i1 %48, label %49, label %50, !dbg !348

49:                                               ; preds = %3
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !349
  br label %51, !dbg !348

50:                                               ; preds = %3
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !350
  br label %51, !dbg !348

51:                                               ; preds = %49, %50
  ret void, !dbg !348
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream() !dbg !351 {
  call void @llvm.sdr.ublk.r(i16 1), !dbg !352
  ret void, !dbg !354
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7, i16 %8, i16 %9, i16 %10, float %11, float %12) !dbg !355 {
  %14 = alloca i16, i16 1, align 2, !dbg !356
  %15 = alloca i16, i16 1, align 2, !dbg !358
  %16 = alloca i16, i16 1, align 2, !dbg !359
  %17 = alloca i16, i16 1, align 2, !dbg !360
  %18 = alloca i16, i16 1, align 2, !dbg !361
  %19 = alloca i1, i16 1, align 1, !dbg !362
  %20 = alloca i16, i16 1, align 2, !dbg !363
  %21 = alloca i16, i16 1, align 2, !dbg !364
  %22 = alloca i16, i16 1, align 2, !dbg !365
  %23 = alloca i16, i16 1, align 2, !dbg !366
  %24 = alloca i16, i16 1, align 2, !dbg !367
  %25 = alloca float, i16 1, align 4, !dbg !368
  %26 = alloca float, i16 1, align 4, !dbg !369
  %27 = alloca i16, i16 1, align 2, !dbg !370
  %28 = alloca i16, i16 1, align 2, !dbg !371
  %29 = alloca i16, i16 1, align 2, !dbg !372
  %30 = alloca i16, i16 1, align 2, !dbg !373
  %31 = alloca i16, i16 1, align 2, !dbg !374
  %32 = alloca i16, i16 1, align 2, !dbg !375
  %33 = alloca i16, i16 1, align 2, !dbg !376
  %34 = alloca i16, i16 1, align 2, !dbg !377
  %35 = alloca i16, i16 1, align 2, !dbg !378
  %36 = alloca i16, i16 1, align 2, !dbg !379
  %37 = alloca i16, i16 1, align 2, !dbg !380
  store i16 %0, i16* %37, align 2, !dbg !380
  store i16 %1, i16* %36, align 2, !dbg !379
  store i16 %2, i16* %35, align 2, !dbg !378
  store i16 %3, i16* %34, align 2, !dbg !377
  store i16 %4, i16* %33, align 2, !dbg !376
  store i16 %5, i16* %32, align 2, !dbg !375
  store i16 %6, i16* %31, align 2, !dbg !374
  store i16 %7, i16* %30, align 2, !dbg !373
  store i16 %8, i16* %29, align 2, !dbg !372
  store i16 %9, i16* %28, align 2, !dbg !371
  store i16 %10, i16* %27, align 2, !dbg !370
  store float %11, float* %26, align 4, !dbg !369
  store float %12, float* %25, align 4, !dbg !368
  %38 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord(), !dbg !381
  store i16 %38, i16* %24, align 2, !dbg !367
  %39 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord(), !dbg !382
  store i16 %39, i16* %23, align 2, !dbg !366
  %40 = load i16, i16* %24, align 2, !dbg !383
  %41 = load i16, i16* %36, align 2, !dbg !384
  %42 = sub i16 %40, %41, !dbg !385
  store i16 %42, i16* %22, align 2, !dbg !365
  %43 = load i16, i16* %22, align 2, !dbg !386
  store i16 %43, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !387
  %44 = load i16, i16* %29, align 2, !dbg !388
  %45 = icmp eq i16 3, %44, !dbg !389
  br i1 %45, label %46, label %63, !dbg !390

46:                                               ; preds = %13
  %47 = load i16, i16* %22, align 2, !dbg !391
  %48 = sitofp i16 %47 to float, !dbg !392
  %49 = load float, float* %26, align 4, !dbg !393
  %50 = fmul float %48, %49, !dbg !394
  %51 = fptosi float %50 to i16, !dbg !395
  store i16 %51, i16* %21, align 2, !dbg !364
  %52 = load i16, i16* %22, align 2, !dbg !396
  %53 = load i16, i16* %21, align 2, !dbg !397
  %54 = load i16, i16* %28, align 2, !dbg !398
  %55 = mul i16 %53, %54, !dbg !399
  %56 = sub i16 %52, %55, !dbg !400
  store i16 %56, i16* %20, align 2, !dbg !363
  %57 = load i16, i16* %20, align 2, !dbg !401
  %58 = icmp ne i16 0, %57, !dbg !402
  br i1 %58, label %59, label %60, !dbg !403

59:                                               ; preds = %46
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !404
  br label %62, !dbg !403

60:                                               ; preds = %46
  %61 = load i16, i16* %21, align 2, !dbg !405
  store i16 %61, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !406
  br label %62, !dbg !403

62:                                               ; preds = %59, %60
  br label %63, !dbg !390

63:                                               ; preds = %62, %13
  %64 = load i16, i16* %22, align 2, !dbg !407
  %65 = icmp slt i16 %64, 0, !dbg !408
  br i1 %65, label %66, label %67, !dbg !409

66:                                               ; preds = %63
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !410
  br label %67, !dbg !409

67:                                               ; preds = %66, %63
  %68 = load i16, i16* %22, align 2, !dbg !411
  %69 = load i16, i16* %34, align 2, !dbg !412
  %70 = icmp sge i16 %68, %69, !dbg !413
  br i1 %70, label %71, label %72, !dbg !414

71:                                               ; preds = %67
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !415
  br label %72, !dbg !414

72:                                               ; preds = %71, %67
  store i1 false, i1* %19, align 1, !dbg !362
  %73 = load i16, i16* %29, align 2, !dbg !416
  %74 = icmp eq i16 3, %73, !dbg !417
  br i1 %74, label %75, label %94, !dbg !418

75:                                               ; preds = %72
  %76 = load i16, i16* %23, align 2, !dbg !419
  %77 = load i16, i16* %35, align 2, !dbg !420
  %78 = sub i16 %76, %77, !dbg !421
  %79 = sitofp i16 %78 to float, !dbg !422
  %80 = load float, float* %25, align 4, !dbg !423
  %81 = fmul float %79, %80, !dbg !424
  %82 = fptosi float %81 to i16, !dbg !425
  store i16 %82, i16* %18, align 2, !dbg !361
  %83 = load i16, i16* %23, align 2, !dbg !426
  %84 = load i16, i16* %35, align 2, !dbg !427
  %85 = sub i16 %83, %84, !dbg !428
  %86 = load i16, i16* %18, align 2, !dbg !429
  %87 = load i16, i16* %27, align 2, !dbg !430
  %88 = mul i16 %86, %87, !dbg !431
  %89 = sub i16 %85, %88, !dbg !432
  store i16 %89, i16* %17, align 2, !dbg !360
  %90 = load i16, i16* %17, align 2, !dbg !433
  %91 = icmp ne i16 0, %90, !dbg !434
  br i1 %91, label %92, label %93, !dbg !435

92:                                               ; preds = %75
  store i1 true, i1* %19, align 1, !dbg !436
  br label %93, !dbg !435

93:                                               ; preds = %92, %75
  br label %94, !dbg !418

94:                                               ; preds = %93, %72
  %95 = load i16, i16* %23, align 2, !dbg !437
  %96 = load i16, i16* %35, align 2, !dbg !438
  %97 = icmp slt i16 %95, %96, !dbg !439
  br i1 %97, label %98, label %99, !dbg !440

98:                                               ; preds = %94
  store i1 true, i1* %19, align 1, !dbg !441
  br label %99, !dbg !440

99:                                               ; preds = %98, %94
  %100 = load i16, i16* %23, align 2, !dbg !442
  %101 = load i16, i16* %35, align 2, !dbg !443
  %102 = load i16, i16* %33, align 2, !dbg !444
  %103 = add i16 %101, %102, !dbg !445
  %104 = icmp sge i16 %100, %103, !dbg !446
  br i1 %104, label %105, label %106, !dbg !447

105:                                              ; preds = %99
  store i1 true, i1* %19, align 1, !dbg !448
  br label %106, !dbg !447

106:                                              ; preds = %105, %99
  %107 = load i1, i1* %19, align 1, !dbg !449
  br i1 %107, label %108, label %109, !dbg !450

108:                                              ; preds = %106
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream(), !dbg !451
  call void @llvm.sdr.ublk.r(i16 27), !dbg !452
  br label %180, !dbg !450

109:                                              ; preds = %106
  %110 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !453
  %111 = icmp eq i16 -1, %110, !dbg !454
  br i1 %111, label %112, label %113, !dbg !455

112:                                              ; preds = %109
  call void @__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction(i16 31767), !dbg !456
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 23), !dbg !457
  call void @llvm.sdr.ublk.r(i16 27), !dbg !458
  br label %179, !dbg !455

113:                                              ; preds = %109
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter(i16 0, i16 0), !dbg !459
  %114 = load i16, i16* %34, align 2, !dbg !460
  store i16 %114, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !461
  %115 = load i16, i16* %29, align 2, !dbg !462
  %116 = icmp eq i16 3, %115, !dbg !463
  br i1 %116, label %117, label %126, !dbg !464

117:                                              ; preds = %113
  %118 = load i16, i16* %34, align 2, !dbg !465
  %119 = sub i16 %118, 1, !dbg !466
  %120 = sitofp i16 %119 to float, !dbg !467
  %121 = load float, float* %26, align 4, !dbg !468
  %122 = fmul float %120, %121, !dbg !469
  %123 = fptosi float %122 to i16, !dbg !470
  %124 = add i16 %123, 1, !dbg !471
  store i16 %124, i16* %16, align 2, !dbg !359
  %125 = load i16, i16* %16, align 2, !dbg !472
  store i16 %125, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !473
  br label %131, !dbg !464

126:                                              ; preds = %113
  %127 = load i16, i16* %29, align 2, !dbg !474
  %128 = icmp eq i16 1, %127, !dbg !475
  br i1 %128, label %129, label %130, !dbg !476

129:                                              ; preds = %126
  store i16 1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !477
  br label %130, !dbg !476

130:                                              ; preds = %129, %126
  br label %131, !dbg !464

131:                                              ; preds = %117, %130
  %132 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !478
  %133 = sub i16 %132, 1, !dbg !479
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit(i16 0, i16 %133), !dbg !480
  %134 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !481
  store i16 %134, i16* %15, align 2, !dbg !358
  %135 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !482
  store i16 %135, i16* %14, align 2, !dbg !356
  %136 = load i16, i16* %15, align 2, !dbg !483
  %137 = load i16, i16* %14, align 2, !dbg !484
  %138 = sub i16 %136, %137, !dbg !485
  store i16 %138, i16* %15, align 2, !dbg !486
  %139 = load i16, i16* %14, align 2, !dbg !487
  %140 = icmp eq i16 0, %139, !dbg !488
  br i1 %140, label %141, label %142, !dbg !489

141:                                              ; preds = %131
  store i16 0, i16* %15, align 2, !dbg !490
  br label %142, !dbg !489

142:                                              ; preds = %141, %131
  %143 = load i16, i16* %29, align 2, !dbg !491
  %144 = icmp eq i16 1, %143, !dbg !492
  br i1 %144, label %145, label %146, !dbg !493

145:                                              ; preds = %142
  store i16 0, i16* %15, align 2, !dbg !494
  br label %146, !dbg !493

146:                                              ; preds = %145, %142
  %147 = load i16, i16* %15, align 2, !dbg !495
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter(i16 0, i16 %147), !dbg !496
  call void @__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction(i16 31767), !dbg !497
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 23), !dbg !498
  %148 = load i16, i16* %37, align 2, !dbg !499
  %149 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval(i16 %148), !dbg !500
  %150 = icmp eq i16 0, %149, !dbg !501
  br i1 %150, label %151, label %155, !dbg !502

151:                                              ; preds = %146
  %152 = load i16, i16* %32, align 2, !dbg !503
  %153 = load i16, i16* %31, align 2, !dbg !504
  %154 = load i16, i16* %30, align 2, !dbg !505
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start(i16 %152, i16 %153, i16 %154), !dbg !506
  br label %178, !dbg !502

155:                                              ; preds = %146
  %156 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !507
  %157 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !507
  %158 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !507
  %159 = load i16, i16* %31, align 2, !dbg !508
  store i16 %159, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !509
  store i16 %156, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !509
  store i16 %157, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !509
  store i16 %158, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !509
  %160 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !510
  %161 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !510
  %162 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !510
  %163 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !510
  %164 = and i16 %162, -193, !dbg !510
  %165 = or i16 %164, 128, !dbg !510
  store volatile i16 %160, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !511
  store volatile i16 %161, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !511
  store volatile i16 %165, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !511
  store volatile i16 %163, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !511
  call void asm sideeffect "nop", ""(), !dbg !511
  call void asm sideeffect "nop", ""(), !dbg !511
  %166 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !512
  %167 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !512
  %168 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !512
  %169 = load i16, i16* %31, align 2, !dbg !513
  store i16 %169, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !514
  store i16 %166, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !514
  store i16 %167, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !514
  store i16 %168, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !514
  %170 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !515
  %171 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !515
  %172 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !515
  %173 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !515
  %174 = and i16 %172, -193, !dbg !515
  %175 = or i16 %174, 128, !dbg !515
  %176 = and i16 %171, -64, !dbg !515
  %177 = or i16 %176, 27, !dbg !515
  store volatile i16 %170, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !516
  store volatile i16 %177, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !516
  store volatile i16 %175, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !516
  store volatile i16 %173, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !516
  call void asm sideeffect "nop", ""(), !dbg !516
  call void asm sideeffect "nop", ""(), !dbg !516
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !517
  br label %178, !dbg !502

178:                                              ; preds = %151, %155
  br label %179, !dbg !455

179:                                              ; preds = %112, %178
  br label %180, !dbg !450

180:                                              ; preds = %108, %179
  ret void, !dbg !390
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit(i16 %0, i16 %1) !dbg !518 {
  %3 = alloca i16, i16 1, align 2, !dbg !520
  %4 = alloca i16, i16 1, align 2, !dbg !522
  %5 = alloca i16, i16 1, align 2, !dbg !523
  %6 = alloca i16, i16 1, align 2, !dbg !524
  %7 = alloca i16, i16 1, align 2, !dbg !525
  %8 = alloca i16, i16 1, align 2, !dbg !526
  store i16 %0, i16* %8, align 2, !dbg !526
  store i16 %1, i16* %7, align 2, !dbg !525
  %9 = load i16, i16* %7, align 2, !dbg !527
  %10 = icmp ult i16 %9, -32768, !dbg !528
  br i1 %10, label %11, label %12, !dbg !529

11:                                               ; preds = %2
  br label %13, !dbg !529

12:                                               ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !529
  br label %13, !dbg !529

13:                                               ; preds = %11, %12
  %14 = load i16, i16* %7, align 2, !dbg !530
  %15 = mul i16 %14, 2, !dbg !531
  store i16 %15, i16* %6, align 2, !dbg !524
  %16 = load i16, i16* %8, align 2, !dbg !532
  %17 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %16, i16 8), !dbg !533
  %18 = sub i16 %17, 1, !dbg !534
  store i16 %18, i16* %5, align 2, !dbg !523
  %19 = load i16, i16* %6, align 2, !dbg !535
  %20 = load i16, i16* %5, align 2, !dbg !536
  %21 = icmp ult i16 %19, %20, !dbg !537
  br i1 %21, label %22, label %23, !dbg !522

22:                                               ; preds = %13
  store i16 0, i16* %4, align 2, !dbg !522
  br label %27, !dbg !522

23:                                               ; preds = %13
  %24 = load i16, i16* %6, align 2, !dbg !538
  %25 = load i16, i16* %5, align 2, !dbg !539
  %26 = sub i16 %24, %25, !dbg !540
  store i16 %26, i16* %4, align 2, !dbg !522
  br label %27, !dbg !522

27:                                               ; preds = %22, %23
  %28 = load i16, i16* %4, align 2, !dbg !522
  store i16 %28, i16* %3, align 2, !dbg !520
  %29 = load i16, i16* %8, align 2, !dbg !541
  %30 = load i16, i16* %3, align 2, !dbg !542
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %29, i16 4, i16 %30), !dbg !543
  ret void, !dbg !522
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter(i16 %0, i16 %1) !dbg !544 {
  %3 = alloca i16, i16 1, align 2, !dbg !545
  %4 = alloca i16, i16 1, align 2, !dbg !547
  store i16 %0, i16* %4, align 2, !dbg !547
  store i16 %1, i16* %3, align 2, !dbg !545
  %5 = load i16, i16* %3, align 2, !dbg !548
  %6 = icmp ult i16 %5, -32768, !dbg !549
  br i1 %6, label %7, label %8, !dbg !550

7:                                                ; preds = %2
  br label %9, !dbg !550

8:                                                ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !550
  br label %9, !dbg !550

9:                                                ; preds = %7, %8
  %10 = load i16, i16* %4, align 2, !dbg !551
  %11 = load i16, i16* %3, align 2, !dbg !552
  %12 = mul i16 %11, 2, !dbg !553
  %13 = add i16 %12, 1, !dbg !554
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %10, i16 8, i16 %13), !dbg !555
  ret void, !dbg !556
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter(i16 %0, i16 %1) !dbg !557 {
  %3 = alloca i16, i16 1, align 2, !dbg !558
  %4 = alloca i16, i16 1, align 2, !dbg !560
  %5 = alloca i1, i16 1, align 1, !dbg !561
  %6 = alloca i16, i16 1, align 2, !dbg !562
  %7 = alloca i16, i16 1, align 2, !dbg !563
  %8 = alloca i16, i16 1, align 2, !dbg !564
  %9 = alloca i16, i16 1, align 2, !dbg !565
  store i16 %0, i16* %9, align 2, !dbg !565
  store i16 %1, i16* %8, align 2, !dbg !564
  %10 = load i16, i16* %8, align 2, !dbg !566
  %11 = icmp ult i16 %10, -32768, !dbg !567
  br i1 %11, label %12, label %13, !dbg !568

12:                                               ; preds = %2
  br label %14, !dbg !568

13:                                               ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !568
  br label %14, !dbg !568

14:                                               ; preds = %12, %13
  %15 = load i16, i16* %9, align 2, !dbg !569
  %16 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %15, i16 8), !dbg !570
  store i16 %16, i16* %7, align 2, !dbg !563
  %17 = load i16, i16* %8, align 2, !dbg !571
  %18 = mul i16 %17, 2, !dbg !572
  store i16 %18, i16* %6, align 2, !dbg !562
  %19 = load i16, i16* %6, align 2, !dbg !573
  %20 = load i16, i16* %7, align 2, !dbg !574
  %21 = icmp ugt i16 %19, %20, !dbg !575
  store i1 %21, i1* %5, align 1, !dbg !561
  %22 = load i16, i16* %9, align 2, !dbg !576
  %23 = load i1, i1* %5, align 1, !dbg !577
  %24 = zext i1 %23 to i16, !dbg !578
  %25 = shl i16 %24, 6, !dbg !579
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %22, i16 14, i16 %25), !dbg !580
  %26 = load i1, i1* %5, align 1, !dbg !581
  br i1 %26, label %27, label %32, !dbg !560

27:                                               ; preds = %14
  %28 = load i16, i16* %6, align 2, !dbg !582
  %29 = load i16, i16* %7, align 2, !dbg !583
  %30 = sub i16 %28, %29, !dbg !584
  %31 = add i16 %30, 1, !dbg !585
  store i16 %31, i16* %4, align 2, !dbg !560
  br label %34, !dbg !560

32:                                               ; preds = %14
  %33 = load i16, i16* %6, align 2, !dbg !586
  store i16 %33, i16* %4, align 2, !dbg !560
  br label %34, !dbg !560

34:                                               ; preds = %27, %32
  %35 = load i16, i16* %4, align 2, !dbg !560
  store i16 %35, i16* %3, align 2, !dbg !558
  %36 = load i16, i16* %9, align 2, !dbg !587
  %37 = load i16, i16* %3, align 2, !dbg !588
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %36, i16 12, i16 %37), !dbg !589
  ret void, !dbg !560
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %0, i16 %1, i16 %2) !dbg !590 {
  %4 = alloca i16, i16 1, align 2, !dbg !592
  %5 = alloca i16, i16 1, align 2, !dbg !594
  %6 = alloca i16, i16 1, align 2, !dbg !595
  store i16 %0, i16* %6, align 2, !dbg !595
  store i16 %1, i16* %5, align 2, !dbg !594
  store i16 %2, i16* %4, align 2, !dbg !592
  %7 = load i16, i16* %6, align 2, !dbg !596
  %8 = getelementptr [6 x i16], [6 x i16]* @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.filters, i16 0, i16 %7, !dbg !597
  %9 = load i16, i16* %8, align 2, !dbg !597
  %10 = load i16, i16* %5, align 2, !dbg !598
  %11 = add i16 %9, %10, !dbg !599
  %12 = lshr i16 %11, 1, !dbg !600
  %13 = load i16, i16* %4, align 2, !dbg !601
  %14 = shl i16 %12, 1, !dbg !602
  %15 = inttoptr i16 %14 to i16*, !dbg !602
  store volatile i16 %13, i16* %15, align 2, !dbg !602
  call void asm sideeffect "nop", ""(), !dbg !602
  call void asm sideeffect "nop", ""(), !dbg !602
  ret void, !dbg !603
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %0, i16 %1) !dbg !604 {
  %3 = alloca i16, i16 1, align 2, !dbg !605
  %4 = alloca i16, i16 1, align 2, !dbg !607
  store i16 %0, i16* %4, align 2, !dbg !607
  store i16 %1, i16* %3, align 2, !dbg !605
  %5 = load i16, i16* %4, align 2, !dbg !608
  %6 = getelementptr [6 x i16], [6 x i16]* @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.filters, i16 0, i16 %5, !dbg !609
  %7 = load i16, i16* %6, align 2, !dbg !609
  %8 = load i16, i16* %3, align 2, !dbg !610
  %9 = add i16 %7, %8, !dbg !611
  %10 = lshr i16 %9, 1, !dbg !612
  %11 = shl i16 %10, 1, !dbg !613
  %12 = inttoptr i16 %11 to i16*, !dbg !613
  call void asm sideeffect "nop", ""(), !dbg !613
  call void asm sideeffect "nop", ""(), !dbg !613
  %13 = load volatile i16, i16* %12, align 2, !dbg !613
  ret i16 %13, !dbg !614
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 %0) !dbg !615 {
  %2 = alloca i16, i16 1, align 2, !dbg !617
  %3 = alloca i16, i16 1, align 2, !dbg !619
  %4 = alloca i16, i16 1, align 2, !dbg !620
  %5 = alloca i16, i16 1, align 2, !dbg !621
  store i16 %0, i16* %5, align 2, !dbg !621
  %6 = load i16, i16* %5, align 2, !dbg !622
  store i16 %6, i16* %4, align 2, !dbg !620
  %7 = load i16, i16* %4, align 2, !dbg !623
  %8 = add i16 %7, 31744, !dbg !624
  store i16 %8, i16* %3, align 2, !dbg !619
  %9 = load i16, i16* %3, align 2, !dbg !625
  %10 = shl i16 %9, 1, !dbg !626
  %11 = inttoptr i16 %10 to i16*, !dbg !626
  call void asm sideeffect "nop", ""(), !dbg !626
  call void asm sideeffect "nop", ""(), !dbg !626
  %12 = load volatile i16, i16* %11, align 2, !dbg !626
  store i16 %12, i16* %2, align 2, !dbg !617
  %13 = load i16, i16* %3, align 2, !dbg !627
  %14 = load i16, i16* %2, align 2, !dbg !628
  %15 = and i16 %14, 32767, !dbg !629
  %16 = shl i16 %13, 1, !dbg !630
  %17 = inttoptr i16 %16 to i16*, !dbg !630
  store volatile i16 %15, i16* %17, align 2, !dbg !630
  call void asm sideeffect "nop", ""(), !dbg !630
  call void asm sideeffect "nop", ""(), !dbg !630
  ret void, !dbg !631
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord() !dbg !632 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 2), !dbg !634
  %2 = sub i16 %1, 4, !dbg !636
  ret i16 %2, !dbg !637
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord() !dbg !638 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 0), !dbg !639
  %2 = sub i16 %1, 1, !dbg !641
  ret i16 %2, !dbg !642
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 %0) !dbg !643 {
  %2 = alloca i16, i16 1, align 2, !dbg !645
  %3 = alloca i16, i16 1, align 2, !dbg !647
  store i16 %0, i16* %3, align 2, !dbg !647
  %4 = load i16, i16* %3, align 2, !dbg !648
  %5 = lshr i16 %4, 1, !dbg !649
  %6 = add i16 %5, 31813, !dbg !650
  %7 = shl i16 %6, 1, !dbg !651
  %8 = inttoptr i16 %7 to i16*, !dbg !651
  call void asm sideeffect "nop", ""(), !dbg !651
  call void asm sideeffect "nop", ""(), !dbg !651
  %9 = load volatile i16, i16* %8, align 2, !dbg !651
  store i16 %9, i16* %2, align 2, !dbg !645
  %10 = load i16, i16* %2, align 2, !dbg !652
  %11 = and i16 %10, 2047, !dbg !653
  ret i16 %11, !dbg !654
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord() !dbg !655 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord(), !dbg !657
  ret i16 %1, !dbg !659
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.get_y_coord() !dbg !660 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord(), !dbg !661
  ret i16 %1, !dbg !663
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval(i16 %0) !dbg !664 {
  %2 = alloca i16, i16 1, align 2, !dbg !665
  store i16 %0, i16* %2, align 2, !dbg !665
  %3 = load i16, i16* %2, align 2, !dbg !667
  %4 = icmp ult i16 %3, 24, !dbg !668
  br i1 %4, label %5, label %7, !dbg !669

5:                                                ; preds = %10, %11, %1
  %6 = phi i16 [ 0, %10 ], [ 0, %11 ], [ 1, %1 ]
  br label %12, !dbg !669

7:                                                ; preds = %1
  %8 = load i16, i16* %2, align 2, !dbg !670
  %9 = icmp eq i16 31, %8, !dbg !671
  br i1 %9, label %10, label %11, !dbg !672

10:                                               ; preds = %7
  br label %5, !dbg !672

11:                                               ; preds = %7
  call void asm sideeffect "hcf", ""(), !dbg !672
  br label %5, !dbg !672

12:                                               ; preds = %5
  %13 = phi i16 [ %6, %5 ]
  br label %14, !dbg !669

14:                                               ; preds = %12
  ret i16 %13, !dbg !669
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7) !dbg !673 {
  %9 = alloca i16, i16 1, align 2, !dbg !674
  %10 = alloca i16, i16 1, align 2, !dbg !676
  %11 = alloca i16, i16 1, align 2, !dbg !677
  %12 = alloca i16, i16 1, align 2, !dbg !678
  %13 = alloca i16, i16 1, align 2, !dbg !679
  %14 = alloca i16, i16 1, align 2, !dbg !680
  %15 = alloca i16, i16 1, align 2, !dbg !681
  %16 = alloca i16, i16 1, align 2, !dbg !682
  %17 = alloca i16, i16 1, align 2, !dbg !683
  store i16 %0, i16* %17, align 2, !dbg !683
  store i16 %1, i16* %16, align 2, !dbg !682
  store i16 %2, i16* %15, align 2, !dbg !681
  store i16 %3, i16* %14, align 2, !dbg !680
  store i16 %4, i16* %13, align 2, !dbg !679
  store i16 %5, i16* %12, align 2, !dbg !678
  store i16 %6, i16* %11, align 2, !dbg !677
  store i16 %7, i16* %10, align 2, !dbg !676
  %18 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !684
  store i16 %18, i16* %9, align 2, !dbg !674
  %19 = load i16, i16* %11, align 2, !dbg !685
  store i16 %19, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_c, align 2, !dbg !686
  %20 = load i16, i16* %10, align 2, !dbg !687
  store i16 %20, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_is_half, align 2, !dbg !688
  %21 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_c, align 2, !dbg !689
  %22 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval(i16 %21), !dbg !690
  store i16 %22, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !691
  store i16 0, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !692
  %23 = load i16, i16* %16, align 2, !dbg !693
  store i16 %23, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !694
  %24 = load i16, i16* %15, align 2, !dbg !695
  store i16 %24, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !696
  %25 = load i16, i16* %15, align 2, !dbg !697
  %26 = load i16, i16* %13, align 2, !dbg !698
  %27 = add i16 %25, %26, !dbg !699
  %28 = sub i16 %27, 1, !dbg !700
  store i16 %28, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_last, align 2, !dbg !701
  %29 = load i16, i16* %9, align 2, !dbg !702
  %30 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_last, align 2, !dbg !703
  %31 = icmp eq i16 %29, %30, !dbg !704
  br i1 %31, label %32, label %37, !dbg !705

32:                                               ; preds = %8
  %33 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !706
  %34 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !706
  %35 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !706
  store i16 %33, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !707
  store i16 lshr (i16 ptrtoint ([1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.ctrl_1 to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !707
  store i16 %34, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !707
  store i16 %35, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !707
  %36 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.ctrl_1, i16 0, i1 false), align 4, !dbg !708
  store i32 %36, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$5$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i1 false), align 4, !dbg !709
  br label %42, !dbg !705

37:                                               ; preds = %8
  %38 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !710
  %39 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !710
  %40 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !710
  store i16 %38, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !711
  store i16 lshr (i16 ptrtoint ([1 x i32]* @"$$csl_base_address$$1$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11" to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !711
  store i16 %39, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !711
  store i16 %40, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !711
  %41 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @"$$csl_base_address$$1$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11", i16 0, i1 false), align 4, !dbg !712
  store i32 %41, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$5$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i1 false), align 4, !dbg !713
  br label %42, !dbg !705

42:                                               ; preds = %32, %37
  store i32 165646921, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$5$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i2 1), align 4, !dbg !714
  %43 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !715
  %44 = icmp eq i16 0, %43, !dbg !716
  br i1 %44, label %45, label %56, !dbg !717

45:                                               ; preds = %42
  %46 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !718
  %47 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !718
  %48 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !718
  %49 = load i16, i16* %17, align 2, !dbg !719
  %50 = call i16* @.get_tensor_ptr(i16 %49), !dbg !720
  %51 = ptrtoint i16* %50 to i16, !dbg !721
  %52 = lshr i16 %51, 1, !dbg !721
  store i16 %46, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !722
  store i16 %52, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !722
  store i16 %47, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !722
  store i16 %48, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !722
  %53 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !723
  %54 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !723
  %55 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !723
  store i16 1, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !724
  store i16 %53, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !724
  store i16 %54, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !724
  store i16 %55, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !724
  call void @llvm.sdr.actvt.r(i16 21), !dbg !725
  br label %63, !dbg !717

56:                                               ; preds = %42
  %57 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !726
  %58 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !726
  %59 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !726
  store i16 %57, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !727
  store i16 lshr (i16 ptrtoint ([1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.data_buf to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !727
  store i16 %58, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !727
  store i16 %59, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !727
  %60 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !728
  %61 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !728
  %62 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !728
  store i16 1, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !729
  store i16 %60, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !729
  store i16 %61, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !729
  store i16 %62, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !729
  call void @llvm.sdr.ublk.r(i16 0), !dbg !730
  br label %63, !dbg !717

63:                                               ; preds = %45, %56
  ret void, !dbg !705
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x(i32 %0) #8 !dbg !731 {
  %2 = alloca i32, i16 1, align 4, !dbg !732
  store i32 %0, i32* %2, align 4, !dbg !732
  call void @llvm.sdr.blk.r(i16 0), !dbg !734
  %3 = load i32, i32* %2, align 4, !dbg !735
  store i32 %3, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.data_buf, i16 0, i1 false), align 4, !dbg !736
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !737
  %4 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !738
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !738
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !738
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !738
  store volatile i16 %4, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !739
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !739
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !739
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !739
  call void asm sideeffect "nop", ""(), !dbg !739
  call void asm sideeffect "nop", ""(), !dbg !739
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !740
  %8 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !741
  %9 = add i16 %8, 1, !dbg !742
  store i16 %9, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !743
  ret void, !dbg !744
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_send_data() #9 !dbg !745 {
  %1 = alloca i16, i16 1, align 2, !dbg !746
  %2 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !748
  %3 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !749
  %4 = icmp ult i16 %2, %3, !dbg !750
  br i1 %4, label %5, label %27, !dbg !751

5:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !752
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !753
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !753
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !753
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !753
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !754
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !754
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !754
  store volatile i16 %9, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !754
  call void asm sideeffect "nop", ""(), !dbg !754
  call void asm sideeffect "nop", ""(), !dbg !754
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_is_half, align 2, !dbg !755
  %11 = icmp ult i16 0, %10, !dbg !756
  br i1 %11, label %12, label %18, !dbg !757

12:                                               ; preds = %5
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !758
  %13 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !759
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !759
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !759
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !759
  %17 = add i16 %14, 1, !dbg !760
  store i16 %13, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !761
  store i16 %17, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !761
  store i16 %15, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !761
  store i16 %16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !761
  br label %24, !dbg !757

18:                                               ; preds = %5
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !762
  %19 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !763
  %20 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !763
  %21 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !763
  %22 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !763
  %23 = add i16 %20, 2, !dbg !764
  store i16 %19, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !765
  store i16 %23, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !765
  store i16 %21, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !765
  store i16 %22, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !765
  br label %24, !dbg !757

24:                                               ; preds = %12, %18
  %25 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !766
  %26 = add i16 %25, 1, !dbg !767
  store i16 %26, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !768
  br label %34, !dbg !751

27:                                               ; preds = %0
  %28 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !769
  store i16 %28, i16* %1, align 2, !dbg !746
  %29 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !770
  %30 = load i16, i16* %1, align 2, !dbg !771
  %31 = icmp eq i16 %29, %30, !dbg !772
  br i1 %31, label %32, label %33, !dbg !773

32:                                               ; preds = %27
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__1 to i8*)), !dbg !774
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__2 to i8*)), !dbg !775
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !776
  br label %33, !dbg !773

33:                                               ; preds = %32, %27
  br label %34, !dbg !751

34:                                               ; preds = %24, %33
  ret void, !dbg !751
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl() #10 !dbg !777 {
  %1 = alloca i16, i16 1, align 2, !dbg !778
  %2 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !780
  %3 = icmp eq i16 0, %2, !dbg !781
  br i1 %3, label %4, label %9, !dbg !782

4:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__3 to i8*)), !dbg !783
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !784
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !784
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !784
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !784
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !785
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !785
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !785
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !785
  call void asm sideeffect "nop", ""(), !dbg !785
  call void asm sideeffect "nop", ""(), !dbg !785
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !786
  br label %31, !dbg !782

9:                                                ; preds = %0
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !787
  %11 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !788
  %12 = icmp ult i16 %10, %11, !dbg !789
  br i1 %12, label %13, label %18, !dbg !790

13:                                               ; preds = %9
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__4 to i8*)), !dbg !791
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !792
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !792
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !792
  %17 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !792
  store volatile i16 %14, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !793
  store volatile i16 %15, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !793
  store volatile i16 %16, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !793
  store volatile i16 %17, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !793
  call void asm sideeffect "nop", ""(), !dbg !793
  call void asm sideeffect "nop", ""(), !dbg !793
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !794
  br label %30, !dbg !790

18:                                               ; preds = %9
  %19 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !795
  store i16 %19, i16* %1, align 2, !dbg !778
  %20 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !796
  %21 = load i16, i16* %1, align 2, !dbg !797
  %22 = icmp eq i16 %20, %21, !dbg !798
  br i1 %22, label %23, label %24, !dbg !799

23:                                               ; preds = %18
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__5 to i8*)), !dbg !800
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__6 to i8*)), !dbg !801
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !802
  br label %29, !dbg !799

24:                                               ; preds = %18
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__1 to i8*)), !dbg !803
  %25 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !804
  %26 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !804
  %27 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !804
  %28 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !804
  store volatile i16 %25, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !805
  store volatile i16 %26, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !805
  store volatile i16 %27, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !805
  store volatile i16 %28, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !805
  call void asm sideeffect "nop", ""(), !dbg !805
  call void asm sideeffect "nop", ""(), !dbg !805
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !806
  br label %29, !dbg !799

29:                                               ; preds = %23, %24
  br label %30, !dbg !790

30:                                               ; preds = %13, %29
  br label %31, !dbg !782

31:                                               ; preds = %4, %30
  ret void, !dbg !782
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.d2h_configure(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7) !dbg !807 {
  %9 = alloca i1, i16 1, align 1, !dbg !808
  %10 = alloca i1, i16 1, align 1, !dbg !810
  %11 = alloca i1, i16 1, align 1, !dbg !811
  %12 = alloca i16, i16 1, align 2, !dbg !812
  %13 = alloca i16, i16 1, align 2, !dbg !813
  %14 = alloca i16, i16 1, align 2, !dbg !814
  %15 = alloca i16, i16 1, align 2, !dbg !815
  %16 = alloca i16, i16 1, align 2, !dbg !816
  %17 = alloca i16, i16 1, align 2, !dbg !817
  %18 = alloca i16, i16 1, align 2, !dbg !818
  %19 = alloca i16, i16 1, align 2, !dbg !819
  %20 = alloca i16, i16 1, align 2, !dbg !820
  %21 = alloca i16, i16 1, align 2, !dbg !821
  %22 = alloca i16, i16 1, align 2, !dbg !822
  %23 = alloca i16, i16 1, align 2, !dbg !823
  %24 = alloca i16, i16 1, align 2, !dbg !824
  %25 = alloca i16, i16 1, align 2, !dbg !825
  store i16 %0, i16* %25, align 2, !dbg !825
  store i16 %1, i16* %24, align 2, !dbg !824
  store i16 %2, i16* %23, align 2, !dbg !823
  store i16 %3, i16* %22, align 2, !dbg !822
  store i16 %4, i16* %21, align 2, !dbg !821
  store i16 %5, i16* %20, align 2, !dbg !820
  store i16 %6, i16* %19, align 2, !dbg !819
  store i16 %7, i16* %18, align 2, !dbg !818
  %26 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !826
  store i16 %26, i16* %17, align 2, !dbg !817
  %27 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_y_coord(), !dbg !827
  store i16 %27, i16* %16, align 2, !dbg !816
  %28 = load i16, i16* %24, align 2, !dbg !828
  store i16 %28, i16* %15, align 2, !dbg !815
  %29 = load i16, i16* %24, align 2, !dbg !829
  %30 = load i16, i16* %22, align 2, !dbg !830
  %31 = add i16 %29, %30, !dbg !831
  %32 = sub i16 %31, 1, !dbg !832
  store i16 %32, i16* %14, align 2, !dbg !814
  %33 = load i16, i16* %23, align 2, !dbg !833
  store i16 %33, i16* %13, align 2, !dbg !813
  %34 = load i16, i16* %23, align 2, !dbg !834
  %35 = load i16, i16* %21, align 2, !dbg !835
  %36 = add i16 %34, %35, !dbg !836
  %37 = sub i16 %36, 1, !dbg !837
  store i16 %37, i16* %12, align 2, !dbg !812
  store i1 false, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !838
  %38 = load i16, i16* %17, align 2, !dbg !839
  %39 = load i16, i16* %15, align 2, !dbg !840
  %40 = icmp sge i16 %38, %39, !dbg !841
  br i1 %40, label %41, label %45, !dbg !811

41:                                               ; preds = %8
  %42 = load i16, i16* %16, align 2, !dbg !842
  %43 = load i16, i16* %12, align 2, !dbg !843
  %44 = icmp sle i16 %42, %43, !dbg !844
  store i1 %44, i1* %11, align 1, !dbg !811
  br label %46, !dbg !811

45:                                               ; preds = %8
  store i1 false, i1* %11, align 1, !dbg !811
  br label %46, !dbg !811

46:                                               ; preds = %41, %45
  %47 = load i1, i1* %11, align 1, !dbg !811
  br i1 %47, label %48, label %52, !dbg !810

48:                                               ; preds = %46
  %49 = load i16, i16* %16, align 2, !dbg !845
  %50 = load i16, i16* %13, align 2, !dbg !846
  %51 = icmp sge i16 %49, %50, !dbg !847
  store i1 %51, i1* %10, align 1, !dbg !810
  br label %53, !dbg !810

52:                                               ; preds = %46
  store i1 false, i1* %10, align 1, !dbg !810
  br label %53, !dbg !810

53:                                               ; preds = %48, %52
  %54 = load i1, i1* %10, align 1, !dbg !810
  br i1 %54, label %55, label %56, !dbg !848

55:                                               ; preds = %53
  store i1 true, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !849
  br label %56, !dbg !848

56:                                               ; preds = %55, %53
  store i1 false, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !850
  %57 = load i16, i16* %17, align 2, !dbg !851
  %58 = load i16, i16* %14, align 2, !dbg !852
  %59 = icmp sle i16 %57, %58, !dbg !853
  br i1 %59, label %60, label %62, !dbg !808

60:                                               ; preds = %56
  %61 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !854
  store i1 %61, i1* %9, align 1, !dbg !808
  br label %63, !dbg !808

62:                                               ; preds = %56
  store i1 false, i1* %9, align 1, !dbg !808
  br label %63, !dbg !808

63:                                               ; preds = %60, %62
  %64 = load i1, i1* %9, align 1, !dbg !808
  br i1 %64, label %65, label %66, !dbg !855

65:                                               ; preds = %63
  store i1 true, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !856
  br label %66, !dbg !855

66:                                               ; preds = %65, %63
  %67 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !857
  br i1 %67, label %68, label %86, !dbg !858

68:                                               ; preds = %66
  call void @__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position(i16 31959), !dbg !859
  %69 = load i16, i16* %15, align 2, !dbg !860
  %70 = load i16, i16* %17, align 2, !dbg !861
  %71 = icmp eq i16 %69, %70, !dbg !862
  br i1 %71, label %72, label %73, !dbg !863

72:                                               ; preds = %68
  call void @__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 31765), !dbg !864
  br label %74, !dbg !863

73:                                               ; preds = %68
  call void @__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 31765), !dbg !865
  br label %74, !dbg !863

74:                                               ; preds = %72, %73
  call void @sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit(i16 21), !dbg !866
  %75 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !867
  br i1 %75, label %76, label %85, !dbg !868

76:                                               ; preds = %74
  %77 = load i16, i16* %20, align 2, !dbg !869
  %78 = load i16, i16* %19, align 2, !dbg !870
  %79 = load i16, i16* %24, align 2, !dbg !871
  %80 = load i16, i16* %23, align 2, !dbg !872
  %81 = load i16, i16* %22, align 2, !dbg !873
  %82 = load i16, i16* %21, align 2, !dbg !874
  %83 = load i16, i16* %25, align 2, !dbg !875
  %84 = load i16, i16* %18, align 2, !dbg !876
  call void @sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start(i16 %77, i16 %78, i16 %79, i16 %80, i16 %81, i16 %82, i16 %83, i16 %84), !dbg !877
  br label %85, !dbg !868

85:                                               ; preds = %76, %74
  br label %87, !dbg !858

86:                                               ; preds = %66
  call void @llvm.sdr.actvt.r(i16 28), !dbg !878
  br label %87, !dbg !858

87:                                               ; preds = %85, %86
  ret void, !dbg !811
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit(i16 %0) !dbg !879 {
  %2 = alloca i16, i16 1, align 2, !dbg !880
  %3 = alloca i16, i16 1, align 2, !dbg !882
  %4 = alloca i16, i16 1, align 2, !dbg !883
  %5 = alloca i16, i16 1, align 2, !dbg !884
  store i16 %0, i16* %5, align 2, !dbg !884
  %6 = load i16, i16* %5, align 2, !dbg !885
  store i16 %6, i16* %4, align 2, !dbg !883
  %7 = load i16, i16* %4, align 2, !dbg !886
  %8 = add i16 %7, 31744, !dbg !887
  store i16 %8, i16* %3, align 2, !dbg !882
  %9 = load i16, i16* %3, align 2, !dbg !888
  %10 = shl i16 %9, 1, !dbg !889
  %11 = inttoptr i16 %10 to i16*, !dbg !889
  call void asm sideeffect "nop", ""(), !dbg !889
  call void asm sideeffect "nop", ""(), !dbg !889
  %12 = load volatile i16, i16* %11, align 2, !dbg !889
  store i16 %12, i16* %2, align 2, !dbg !880
  %13 = load i16, i16* %3, align 2, !dbg !890
  %14 = load i16, i16* %2, align 2, !dbg !891
  %15 = and i16 %14, 32767, !dbg !892
  %16 = shl i16 %13, 1, !dbg !893
  %17 = inttoptr i16 %16 to i16*, !dbg !893
  store volatile i16 %15, i16* %17, align 2, !dbg !893
  call void asm sideeffect "nop", ""(), !dbg !893
  call void asm sideeffect "nop", ""(), !dbg !893
  ret void, !dbg !894
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord() !dbg !895 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 2), !dbg !896
  %2 = sub i16 %1, 4, !dbg !898
  ret i16 %2, !dbg !899
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord() !dbg !900 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 0), !dbg !901
  %2 = sub i16 %1, 1, !dbg !903
  ret i16 %2, !dbg !904
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 %0) !dbg !905 {
  %2 = alloca i16, i16 1, align 2, !dbg !906
  %3 = alloca i16, i16 1, align 2, !dbg !908
  store i16 %0, i16* %3, align 2, !dbg !908
  %4 = load i16, i16* %3, align 2, !dbg !909
  %5 = lshr i16 %4, 1, !dbg !910
  %6 = add i16 %5, 31813, !dbg !911
  %7 = shl i16 %6, 1, !dbg !912
  %8 = inttoptr i16 %7 to i16*, !dbg !912
  call void asm sideeffect "nop", ""(), !dbg !912
  call void asm sideeffect "nop", ""(), !dbg !912
  %9 = load volatile i16, i16* %8, align 2, !dbg !912
  store i16 %9, i16* %2, align 2, !dbg !906
  %10 = load i16, i16* %2, align 2, !dbg !913
  %11 = and i16 %10, 2047, !dbg !914
  ret i16 %11, !dbg !915
}

define internal i16 @sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr(i16 %0) !dbg !916 {
  %2 = alloca i16, i16 1, align 2, !dbg !918
  store i16 %0, i16* %2, align 2, !dbg !918
  %3 = load i16, i16* %2, align 2, !dbg !920
  %4 = mul i16 %3, 2, !dbg !921
  %5 = add i16 %4, 31680, !dbg !922
  ret i16 %5, !dbg !923
}

define internal void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 %0, i16 %1, i1 %2) !dbg !924 {
  %4 = alloca i16, i16 1, align 2, !dbg !925
  %5 = alloca i16, i16 1, align 2, !dbg !927
  %6 = alloca i1, i16 1, align 1, !dbg !928
  %7 = alloca i16, i16 1, align 2, !dbg !929
  %8 = alloca i16, i16 1, align 2, !dbg !930
  store i16 %0, i16* %8, align 2, !dbg !930
  store i16 %1, i16* %7, align 2, !dbg !929
  store i1 %2, i1* %6, align 1, !dbg !928
  %9 = load i16, i16* %8, align 2, !dbg !931
  %10 = call i16 @sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr(i16 %9), !dbg !932
  store i16 %10, i16* %5, align 2, !dbg !927
  %11 = load i16, i16* %5, align 2, !dbg !933
  %12 = shl i16 %11, 1, !dbg !934
  %13 = inttoptr i16 %12 to i16*, !dbg !934
  call void asm sideeffect "nop", ""(), !dbg !934
  call void asm sideeffect "nop", ""(), !dbg !934
  call void asm sideeffect "nop", ""(), !dbg !934
  call void asm sideeffect "nop", ""(), !dbg !934
  %14 = load volatile i16, i16* %13, align 2, !dbg !934
  store i16 %14, i16* %4, align 2, !dbg !925
  %15 = load i1, i1* %6, align 1, !dbg !935
  br i1 %15, label %16, label %19, !dbg !936

16:                                               ; preds = %3
  %17 = load i16, i16* %4, align 2, !dbg !937
  %18 = or i16 %17, 2048, !dbg !938
  store i16 %18, i16* %4, align 2, !dbg !939
  br label %22, !dbg !936

19:                                               ; preds = %3
  %20 = load i16, i16* %4, align 2, !dbg !940
  %21 = and i16 %20, -2049, !dbg !941
  store i16 %21, i16* %4, align 2, !dbg !942
  br label %22, !dbg !936

22:                                               ; preds = %16, %19
  %23 = load i16, i16* %4, align 2, !dbg !943
  %24 = and i16 %23, -32, !dbg !944
  store i16 %24, i16* %4, align 2, !dbg !945
  %25 = load i16, i16* %4, align 2, !dbg !946
  %26 = load i16, i16* %7, align 2, !dbg !947
  %27 = add i16 %25, %26, !dbg !948
  store i16 %27, i16* %4, align 2, !dbg !949
  %28 = load i16, i16* %5, align 2, !dbg !950
  %29 = load i16, i16* %4, align 2, !dbg !951
  %30 = shl i16 %28, 1, !dbg !952
  %31 = inttoptr i16 %30 to i16*, !dbg !952
  store volatile i16 %29, i16* %31, align 2, !dbg !952
  call void asm sideeffect "nop", ""(), !dbg !952
  call void asm sideeffect "nop", ""(), !dbg !952
  call void asm sideeffect "nop", ""(), !dbg !952
  call void asm sideeffect "nop", ""(), !dbg !952
  ret void, !dbg !936
}

define internal i16 @sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr(i16 %0) !dbg !953 {
  %2 = alloca i16, i16 1, align 2, !dbg !955
  store i16 %0, i16* %2, align 2, !dbg !955
  %3 = load i16, i16* %2, align 2, !dbg !957
  %4 = add i16 %3, 31616, !dbg !958
  ret i16 %4, !dbg !959
}

define internal void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 %0, i16 %1) !dbg !960 {
  %3 = alloca i16, i16 1, align 2, !dbg !961
  %4 = alloca i16, i16 1, align 2, !dbg !963
  %5 = alloca i16, i16 1, align 2, !dbg !964
  %6 = alloca i16, i16 1, align 2, !dbg !965
  store i16 %0, i16* %6, align 2, !dbg !965
  store i16 %1, i16* %5, align 2, !dbg !964
  %7 = load i16, i16* %6, align 2, !dbg !966
  %8 = call i16 @sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr(i16 %7), !dbg !967
  store i16 %8, i16* %4, align 2, !dbg !963
  %9 = load i16, i16* %4, align 2, !dbg !968
  %10 = shl i16 %9, 1, !dbg !969
  %11 = inttoptr i16 %10 to i16*, !dbg !969
  call void asm sideeffect "nop", ""(), !dbg !969
  call void asm sideeffect "nop", ""(), !dbg !969
  call void asm sideeffect "nop", ""(), !dbg !969
  call void asm sideeffect "nop", ""(), !dbg !969
  %12 = load volatile i16, i16* %11, align 2, !dbg !969
  store i16 %12, i16* %3, align 2, !dbg !961
  %13 = load i16, i16* %3, align 2, !dbg !970
  %14 = and i16 %13, -497, !dbg !971
  store i16 %14, i16* %3, align 2, !dbg !972
  %15 = load i16, i16* %3, align 2, !dbg !973
  %16 = load i16, i16* %5, align 2, !dbg !974
  %17 = add i16 %15, %16, !dbg !975
  %18 = shl i16 %17, 4, !dbg !976
  store i16 %18, i16* %3, align 2, !dbg !977
  %19 = load i16, i16* %4, align 2, !dbg !978
  %20 = load i16, i16* %3, align 2, !dbg !979
  %21 = shl i16 %19, 1, !dbg !980
  %22 = inttoptr i16 %21 to i16*, !dbg !980
  store volatile i16 %20, i16* %22, align 2, !dbg !980
  call void asm sideeffect "nop", ""(), !dbg !980
  call void asm sideeffect "nop", ""(), !dbg !980
  call void asm sideeffect "nop", ""(), !dbg !980
  call void asm sideeffect "nop", ""(), !dbg !980
  ret void, !dbg !981
}

define internal i16* @.get_tensor_ptr(i16 %0) !dbg !982 {
  %2 = alloca i16, i16 1, align 2, !dbg !983
  store i16 %0, i16* %2, align 2, !dbg !983
  %3 = load i16, i16* %2, align 2, !dbg !983
  %4 = zext i16 %3 to i32, !dbg !983
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
  ], !dbg !983

5:                                                ; preds = %1
  br i1 false, label %6, label %7, !dbg !983

6:                                                ; preds = %5
  br label %8, !dbg !983

7:                                                ; preds = %5
  call void asm sideeffect "hcf", ""(), !dbg !983
  br label %8, !dbg !983

8:                                                ; preds = %6, %7
  br label %33, !dbg !983

9:                                                ; preds = %1
  %10 = load i16*, i16** @p_a, align 8, !dbg !983
  br label %33, !dbg !983

11:                                               ; preds = %1
  %12 = load i16*, i16** @p_b, align 8, !dbg !983
  br label %33, !dbg !983

13:                                               ; preds = %1
  %14 = load i16*, i16** @p_g, align 8, !dbg !983
  br label %33, !dbg !983

15:                                               ; preds = %1
  %16 = load i16*, i16** @p_c, align 8, !dbg !983
  br label %33, !dbg !983

17:                                               ; preds = %1
  %18 = load i16*, i16** @p_d, align 8, !dbg !983
  br label %33, !dbg !983

19:                                               ; preds = %1
  %20 = load half*, half** @p_af, align 8, !dbg !983
  %21 = bitcast half* %20 to i16*, !dbg !983
  br label %33, !dbg !983

22:                                               ; preds = %1
  %23 = load half*, half** @p_bf, align 8, !dbg !983
  %24 = bitcast half* %23 to i16*, !dbg !983
  br label %33, !dbg !983

25:                                               ; preds = %1
  %26 = load half*, half** @p_gf, align 8, !dbg !983
  %27 = bitcast half* %26 to i16*, !dbg !983
  br label %33, !dbg !983

28:                                               ; preds = %1
  %29 = load half*, half** @p_cf, align 8, !dbg !983
  %30 = bitcast half* %29 to i16*, !dbg !983
  br label %33, !dbg !983

31:                                               ; preds = %1
  %32 = load i16*, i16** @p_mark, align 8, !dbg !983
  br label %33, !dbg !983

33:                                               ; preds = %8, %9, %11, %13, %15, %17, %19, %22, %25, %28, %31
  %34 = phi i16 [ -2, %31 ], [ -2, %28 ], [ -2, %25 ], [ -2, %22 ], [ -2, %19 ], [ -2, %17 ], [ -2, %15 ], [ -2, %13 ], [ -2, %11 ], [ -2, %9 ], [ 0, %8 ]
  %35 = phi i16* [ %32, %31 ], [ %30, %28 ], [ %27, %25 ], [ %24, %22 ], [ %21, %19 ], [ %18, %17 ], [ %16, %15 ], [ %14, %13 ], [ %12, %11 ], [ %10, %9 ], [ undef, %8 ]
  br label %36, !dbg !983

36:                                               ; preds = %33
  %37 = icmp ne i16 %34, 0, !dbg !983
  br i1 %37, label %38, label %39, !dbg !983

38:                                               ; preds = %36
  br label %41, !dbg !983

39:                                               ; preds = %36
  %40 = load i16*, i16** @p_mark, align 8, !dbg !983
  br label %41, !dbg !983

41:                                               ; preds = %38, %39
  %42 = phi i16* [ %40, %39 ], [ %35, %38 ]
  br label %43, !dbg !983

43:                                               ; preds = %41
  ret i16* %42, !dbg !983
}

define internal void @__generic0sys_mod.sys_mod.tile_config.queue_flush.exit() !dbg !985 {
  store volatile i16 1, i16* inttoptr (i16 -2268 to i16*), align 2, !dbg !987
  call void asm sideeffect "nop", ""(), !dbg !987
  call void asm sideeffect "nop", ""(), !dbg !987
  ret void, !dbg !989
}

define internal void @__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position(i16 %0) !dbg !990 {
  %2 = alloca i16, i16 1, align 2, !dbg !992
  %3 = alloca i16, i16 1, align 2, !dbg !994
  %4 = alloca i16, i16 1, align 2, !dbg !995
  store i16 %0, i16* %4, align 2, !dbg !995
  %5 = load i16, i16* %4, align 2, !dbg !996
  store i16 %5, i16* %3, align 2, !dbg !994
  %6 = load i16, i16* %3, align 2, !dbg !997
  %7 = shl i16 %6, 1, !dbg !998
  %8 = inttoptr i16 %7 to i16*, !dbg !998
  call void asm sideeffect "nop", ""(), !dbg !998
  call void asm sideeffect "nop", ""(), !dbg !998
  call void asm sideeffect "nop", ""(), !dbg !998
  call void asm sideeffect "nop", ""(), !dbg !998
  %9 = load volatile i16, i16* %8, align 2, !dbg !998
  store i16 %9, i16* %2, align 2, !dbg !992
  %10 = load i16, i16* %2, align 2, !dbg !999
  %11 = and i16 %10, -16, !dbg !1000
  store i16 %11, i16* %2, align 2, !dbg !1000
  %12 = load i16, i16* %3, align 2, !dbg !1001
  %13 = load i16, i16* %2, align 2, !dbg !1002
  %14 = shl i16 %12, 1, !dbg !1003
  %15 = inttoptr i16 %14 to i16*, !dbg !1003
  store volatile i16 %13, i16* %15, align 2, !dbg !1003
  call void asm sideeffect "nop", ""(), !dbg !1003
  call void asm sideeffect "nop", ""(), !dbg !1003
  call void asm sideeffect "nop", ""(), !dbg !1003
  call void asm sideeffect "nop", ""(), !dbg !1003
  ret void, !dbg !1004
}

define internal void @__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 %0) !dbg !1005 {
  %2 = alloca i16, i16 1, align 2, !dbg !1007
  %3 = alloca i16, i16 1, align 2, !dbg !1009
  %4 = alloca i16, i16 1, align 2, !dbg !1010
  store i16 %0, i16* %4, align 2, !dbg !1010
  %5 = load i16, i16* %4, align 2, !dbg !1011
  store i16 %5, i16* %3, align 2, !dbg !1009
  %6 = load i16, i16* %3, align 2, !dbg !1012
  %7 = shl i16 %6, 1, !dbg !1013
  %8 = inttoptr i16 %7 to i16*, !dbg !1013
  call void asm sideeffect "nop", ""(), !dbg !1013
  call void asm sideeffect "nop", ""(), !dbg !1013
  %9 = load volatile i16, i16* %8, align 2, !dbg !1013
  store i16 %9, i16* %2, align 2, !dbg !1007
  %10 = load i16, i16* %2, align 2, !dbg !1014
  %11 = and i16 %10, -256, !dbg !1015
  store i16 %11, i16* %2, align 2, !dbg !1016
  %12 = load i16, i16* %2, align 2, !dbg !1017
  %13 = load i16, i16* %2, align 2, !dbg !1018
  %14 = call i16 @__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %13), !dbg !1019
  %15 = or i16 %12, %14, !dbg !1020
  store i16 %15, i16* %2, align 2, !dbg !1020
  %16 = load i16, i16* %2, align 2, !dbg !1021
  %17 = load i16, i16* %2, align 2, !dbg !1022
  %18 = call i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %17), !dbg !1023
  %19 = or i16 %16, %18, !dbg !1024
  store i16 %19, i16* %2, align 2, !dbg !1024
  %20 = load i16, i16* %3, align 2, !dbg !1025
  %21 = load i16, i16* %2, align 2, !dbg !1026
  %22 = shl i16 %20, 1, !dbg !1027
  %23 = inttoptr i16 %22 to i16*, !dbg !1027
  store volatile i16 %21, i16* %23, align 2, !dbg !1027
  call void asm sideeffect "nop", ""(), !dbg !1027
  call void asm sideeffect "nop", ""(), !dbg !1027
  ret void, !dbg !1028
}

define internal void @__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 %0) !dbg !1029 {
  %2 = alloca i16, i16 1, align 2, !dbg !1030
  %3 = alloca i16, i16 1, align 2, !dbg !1032
  %4 = alloca i16, i16 1, align 2, !dbg !1033
  store i16 %0, i16* %4, align 2, !dbg !1033
  %5 = load i16, i16* %4, align 2, !dbg !1034
  store i16 %5, i16* %3, align 2, !dbg !1032
  %6 = load i16, i16* %3, align 2, !dbg !1035
  %7 = shl i16 %6, 1, !dbg !1036
  %8 = inttoptr i16 %7 to i16*, !dbg !1036
  call void asm sideeffect "nop", ""(), !dbg !1036
  call void asm sideeffect "nop", ""(), !dbg !1036
  %9 = load volatile i16, i16* %8, align 2, !dbg !1036
  store i16 %9, i16* %2, align 2, !dbg !1030
  %10 = load i16, i16* %2, align 2, !dbg !1037
  %11 = and i16 %10, -256, !dbg !1038
  store i16 %11, i16* %2, align 2, !dbg !1039
  %12 = load i16, i16* %2, align 2, !dbg !1040
  %13 = load i16, i16* %2, align 2, !dbg !1041
  %14 = call i16 @__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %13), !dbg !1042
  %15 = or i16 %12, %14, !dbg !1043
  store i16 %15, i16* %2, align 2, !dbg !1043
  %16 = load i16, i16* %2, align 2, !dbg !1044
  %17 = load i16, i16* %2, align 2, !dbg !1045
  %18 = call i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %17), !dbg !1046
  %19 = or i16 %16, %18, !dbg !1047
  store i16 %19, i16* %2, align 2, !dbg !1047
  %20 = load i16, i16* %3, align 2, !dbg !1048
  %21 = load i16, i16* %2, align 2, !dbg !1049
  %22 = shl i16 %20, 1, !dbg !1050
  %23 = inttoptr i16 %22 to i16*, !dbg !1050
  store volatile i16 %21, i16* %23, align 2, !dbg !1050
  call void asm sideeffect "nop", ""(), !dbg !1050
  call void asm sideeffect "nop", ""(), !dbg !1050
  ret void, !dbg !1051
}

define internal i16 @__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %0) !dbg !1052 {
  %2 = alloca i16, i16 1, align 2, !dbg !1053
  %3 = alloca i16, i16 1, align 2, !dbg !1055
  store i16 %0, i16* %3, align 2, !dbg !1055
  %4 = load i16, i16* %3, align 2, !dbg !1056
  store i16 %4, i16* %2, align 2, !dbg !1053
  %5 = load i16, i16* %2, align 2, !dbg !1057
  store i16 %5, i16* %2, align 2, !dbg !1058
  %6 = load i16, i16* %2, align 2, !dbg !1059
  ret i16 %6, !dbg !1060
}

define internal i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %0) !dbg !1061 {
  %2 = alloca i16, i16 1, align 2, !dbg !1062
  %3 = alloca i16, i16 1, align 2, !dbg !1064
  store i16 %0, i16* %3, align 2, !dbg !1064
  %4 = load i16, i16* %3, align 2, !dbg !1065
  store i16 %4, i16* %2, align 2, !dbg !1062
  %5 = load i16, i16* %2, align 2, !dbg !1066
  %6 = or i16 %5, 2, !dbg !1067
  store i16 %6, i16* %2, align 2, !dbg !1067
  %7 = load i16, i16* %2, align 2, !dbg !1068
  ret i16 %7, !dbg !1069
}

define internal i16 @__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %0) !dbg !1070 {
  %2 = alloca i16, i16 1, align 2, !dbg !1071
  %3 = alloca i16, i16 1, align 2, !dbg !1073
  store i16 %0, i16* %3, align 2, !dbg !1073
  %4 = load i16, i16* %3, align 2, !dbg !1074
  store i16 %4, i16* %2, align 2, !dbg !1071
  %5 = load i16, i16* %2, align 2, !dbg !1075
  %6 = or i16 %5, 128, !dbg !1076
  store i16 %6, i16* %2, align 2, !dbg !1076
  %7 = load i16, i16* %2, align 2, !dbg !1077
  ret i16 %7, !dbg !1078
}

define internal void @__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction(i16 %0) !dbg !1079 {
  %2 = alloca i16, i16 1, align 2, !dbg !1080
  %3 = alloca i16, i16 1, align 2, !dbg !1082
  %4 = alloca i16, i16 1, align 2, !dbg !1083
  store i16 %0, i16* %4, align 2, !dbg !1083
  %5 = load i16, i16* %4, align 2, !dbg !1084
  store i16 %5, i16* %3, align 2, !dbg !1082
  %6 = load i16, i16* %3, align 2, !dbg !1085
  %7 = shl i16 %6, 1, !dbg !1086
  %8 = inttoptr i16 %7 to i16*, !dbg !1086
  call void asm sideeffect "nop", ""(), !dbg !1086
  call void asm sideeffect "nop", ""(), !dbg !1086
  %9 = load volatile i16, i16* %8, align 2, !dbg !1086
  store i16 %9, i16* %2, align 2, !dbg !1080
  %10 = load i16, i16* %2, align 2, !dbg !1087
  %11 = and i16 %10, -17, !dbg !1088
  store i16 %11, i16* %2, align 2, !dbg !1088
  %12 = load i16, i16* %3, align 2, !dbg !1089
  %13 = load i16, i16* %2, align 2, !dbg !1090
  %14 = shl i16 %12, 1, !dbg !1091
  %15 = inttoptr i16 %14 to i16*, !dbg !1091
  store volatile i16 %13, i16* %15, align 2, !dbg !1091
  call void asm sideeffect "nop", ""(), !dbg !1091
  call void asm sideeffect "nop", ""(), !dbg !1091
  ret void, !dbg !1092
}

define internal void @__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction(i16 %0) !dbg !1093 {
  %2 = alloca i16, i16 1, align 2, !dbg !1094
  %3 = alloca i16, i16 1, align 2, !dbg !1096
  %4 = alloca i16, i16 1, align 2, !dbg !1097
  store i16 %0, i16* %4, align 2, !dbg !1097
  %5 = load i16, i16* %4, align 2, !dbg !1098
  store i16 %5, i16* %3, align 2, !dbg !1096
  %6 = load i16, i16* %3, align 2, !dbg !1099
  %7 = shl i16 %6, 1, !dbg !1100
  %8 = inttoptr i16 %7 to i16*, !dbg !1100
  call void asm sideeffect "nop", ""(), !dbg !1100
  call void asm sideeffect "nop", ""(), !dbg !1100
  %9 = load volatile i16, i16* %8, align 2, !dbg !1100
  store i16 %9, i16* %2, align 2, !dbg !1094
  %10 = load i16, i16* %2, align 2, !dbg !1101
  %11 = or i16 %10, 16, !dbg !1102
  store i16 %11, i16* %2, align 2, !dbg !1102
  %12 = load i16, i16* %3, align 2, !dbg !1103
  %13 = load i16, i16* %2, align 2, !dbg !1104
  %14 = shl i16 %12, 1, !dbg !1105
  %15 = inttoptr i16 %14 to i16*, !dbg !1105
  store volatile i16 %13, i16* %15, align 2, !dbg !1105
  call void asm sideeffect "nop", ""(), !dbg !1105
  call void asm sideeffect "nop", ""(), !dbg !1105
  ret void, !dbg !1106
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
declare half @llvm.sdr.faddh.rrs1.f16(half, i16 immarg) #12

; Function Attrs: nounwind
declare void @llvm.sdr.imov16.ds1(i16 immarg, i16 immarg) #12

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
!3 = distinct !DISubprogram(name: "compute", linkageName: "compute", scope: null, file: !4, line: 24, type: !5, scopeLine: 24, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!4 = !DIFile(filename: "./pe.csl", directory: "/home/USER/xkernel/studies/wse3-characterization/microbench/pcsweep/cases/reduce")
!5 = !DISubroutineType(types: !6)
!6 = !{}
!7 = !DILocation(line: 25, column: 11, scope: !8)
!8 = !DILexicalBlockFile(scope: !3, file: !4, discriminator: 0)
!9 = !DILocation(line: 26, column: 17, scope: !8)
!10 = !DILocation(line: 26, column: 3, scope: !8)
!11 = !DILocation(line: 27, column: 11, scope: !8)
!12 = !DILocation(line: 27, column: 9, scope: !8)
!13 = !DILocation(line: 28, column: 11, scope: !8)
!14 = !DILocation(line: 29, column: 17, scope: !8)
!15 = !DILocation(line: 29, column: 3, scope: !8)
!16 = !DILocation(line: 30, column: 11, scope: !8)
!17 = !DILocation(line: 30, column: 9, scope: !8)
!18 = !DILocation(line: 31, column: 11, scope: !8)
!19 = !DILocation(line: 32, column: 17, scope: !8)
!20 = !DILocation(line: 32, column: 3, scope: !8)
!21 = !DILocation(line: 33, column: 11, scope: !8)
!22 = !DILocation(line: 33, column: 9, scope: !8)
!23 = !DILocation(line: 34, column: 11, scope: !8)
!24 = !DILocation(line: 35, column: 17, scope: !8)
!25 = !DILocation(line: 35, column: 3, scope: !8)
!26 = !DILocation(line: 36, column: 11, scope: !8)
!27 = !DILocation(line: 36, column: 9, scope: !8)
!28 = !DILocation(line: 37, column: 11, scope: !8)
!29 = !DILocation(line: 38, column: 17, scope: !8)
!30 = !DILocation(line: 38, column: 3, scope: !8)
!31 = !DILocation(line: 39, column: 11, scope: !8)
!32 = !DILocation(line: 39, column: 9, scope: !8)
!33 = !DILocation(line: 40, column: 11, scope: !8)
!34 = !DILocation(line: 41, column: 17, scope: !8)
!35 = !DILocation(line: 41, column: 3, scope: !8)
!36 = !DILocation(line: 42, column: 11, scope: !8)
!37 = !DILocation(line: 42, column: 9, scope: !8)
!38 = !DILocation(line: 43, column: 11, scope: !8)
!39 = !DILocation(line: 44, column: 17, scope: !8)
!40 = !DILocation(line: 44, column: 3, scope: !8)
!41 = !DILocation(line: 45, column: 11, scope: !8)
!42 = !DILocation(line: 45, column: 9, scope: !8)
!43 = !DILocation(line: 46, column: 11, scope: !8)
!44 = !DILocation(line: 47, column: 17, scope: !8)
!45 = !DILocation(line: 47, column: 3, scope: !8)
!46 = !DILocation(line: 48, column: 11, scope: !8)
!47 = !DILocation(line: 48, column: 9, scope: !8)
!48 = !DILocation(line: 50, column: 11, scope: !8)
!49 = !DILocation(line: 51, column: 3, scope: !8)
!50 = !DILocation(line: 24, column: 1, scope: !8)
!51 = distinct !DISubprogram(name: "f_exit", linkageName: "f_exit", scope: null, file: !4, line: 54, type: !5, scopeLine: 54, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!52 = !DILocation(line: 54, column: 22, scope: !53)
!53 = !DILexicalBlockFile(scope: !51, file: !4, discriminator: 0)
!54 = !DILocation(line: 54, column: 1, scope: !53)
!55 = distinct !DISubprogram(name: "sys_mod.sys_nop", linkageName: "sys_mod.sys_nop", scope: null, file: !56, line: 90, type: !5, scopeLine: 90, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!56 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/memcpy.csl", directory: "")
!57 = !DILocation(line: 90, column: 1, scope: !58)
!58 = !DILexicalBlockFile(scope: !55, file: !56, discriminator: 0)
!59 = distinct !DISubprogram(name: "sys_mod.unblock_cmd_stream", linkageName: "sys_mod.unblock_cmd_stream", scope: null, file: !56, line: 102, type: !5, scopeLine: 102, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!60 = !DILocation(line: 103, column: 3, scope: !61)
!61 = !DILexicalBlockFile(scope: !59, file: !56, discriminator: 0)
!62 = !DILocation(line: 102, column: 1, scope: !61)
!63 = distinct !DISubprogram(name: "sys_mod.sys_mod.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.unblock_cmd_stream", scope: null, file: !64, line: 307, type: !5, scopeLine: 307, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!64 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpy.csl", directory: "")
!65 = !DILocation(line: 308, column: 5, scope: !66)
!66 = !DILexicalBlockFile(scope: !63, file: !64, discriminator: 0)
!67 = !DILocation(line: 307, column: 1, scope: !66)
!68 = distinct !DISubprogram(name: "sys_mod.sys_mod.teardown_h2d", linkageName: "sys_mod.sys_mod.teardown_h2d", scope: null, file: !64, line: 323, type: !5, scopeLine: 323, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!69 = !DILocation(line: 326, column: 5, scope: !70)
!70 = !DILexicalBlockFile(scope: !68, file: !64, discriminator: 0)
!71 = !DILocation(line: 323, column: 1, scope: !70)
!72 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_ublk_c22", linkageName: "sys_mod.sys_mod.f_ublk_c22", scope: null, file: !64, line: 335, type: !5, scopeLine: 335, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!73 = !DILocation(line: 336, column: 5, scope: !74)
!74 = !DILexicalBlockFile(scope: !72, file: !64, discriminator: 0)
!75 = !DILocation(line: 335, column: 1, scope: !74)
!76 = distinct !DISubprogram(name: "sys_mod.sys_mod.teardown_d2h", linkageName: "sys_mod.sys_mod.teardown_d2h", scope: null, file: !64, line: 344, type: !5, scopeLine: 344, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!77 = !DILocation(line: 355, column: 5, scope: !78)
!78 = !DILexicalBlockFile(scope: !76, file: !64, discriminator: 0)
!79 = !DILocation(line: 359, column: 5, scope: !78)
!80 = !DILocation(line: 344, column: 1, scope: !78)
!81 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_memcpyh2d", linkageName: "sys_mod.sys_mod.f_memcpyh2d", scope: null, file: !64, line: 460, type: !5, scopeLine: 460, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!82 = !DILocation(line: 477, column: 5, scope: !83)
!83 = !DILexicalBlockFile(scope: !81, file: !64, discriminator: 0)
!84 = !DILocation(line: 476, column: 5, scope: !83)
!85 = !DILocation(line: 475, column: 5, scope: !83)
!86 = !DILocation(line: 474, column: 5, scope: !83)
!87 = !DILocation(line: 473, column: 5, scope: !83)
!88 = !DILocation(line: 472, column: 5, scope: !83)
!89 = !DILocation(line: 471, column: 5, scope: !83)
!90 = !DILocation(line: 470, column: 5, scope: !83)
!91 = !DILocation(line: 469, column: 5, scope: !83)
!92 = !DILocation(line: 468, column: 5, scope: !83)
!93 = !DILocation(line: 467, column: 5, scope: !83)
!94 = !DILocation(line: 466, column: 5, scope: !83)
!95 = !DILocation(line: 465, column: 5, scope: !83)
!96 = !DILocation(line: 463, column: 5, scope: !83)
!97 = !DILocation(line: 462, column: 20, scope: !83)
!98 = !DILocation(line: 462, column: 32, scope: !83)
!99 = !DILocation(line: 462, column: 5, scope: !83)
!100 = !DILocation(line: 465, column: 33, scope: !83)
!101 = !DILocation(line: 465, column: 38, scope: !83)
!102 = !DILocation(line: 466, column: 34, scope: !83)
!103 = !DILocation(line: 466, column: 39, scope: !83)
!104 = !DILocation(line: 467, column: 34, scope: !83)
!105 = !DILocation(line: 467, column: 39, scope: !83)
!106 = !DILocation(line: 468, column: 33, scope: !83)
!107 = !DILocation(line: 468, column: 38, scope: !83)
!108 = !DILocation(line: 469, column: 33, scope: !83)
!109 = !DILocation(line: 469, column: 38, scope: !83)
!110 = !DILocation(line: 470, column: 35, scope: !83)
!111 = !DILocation(line: 470, column: 21, scope: !83)
!112 = !DILocation(line: 471, column: 41, scope: !83)
!113 = !DILocation(line: 471, column: 27, scope: !83)
!114 = !DILocation(line: 472, column: 39, scope: !83)
!115 = !DILocation(line: 472, column: 25, scope: !83)
!116 = !DILocation(line: 473, column: 44, scope: !83)
!117 = !DILocation(line: 473, column: 49, scope: !83)
!118 = !DILocation(line: 474, column: 41, scope: !83)
!119 = !DILocation(line: 474, column: 46, scope: !83)
!120 = !DILocation(line: 475, column: 41, scope: !83)
!121 = !DILocation(line: 475, column: 46, scope: !83)
!122 = !DILocation(line: 476, column: 59, scope: !83)
!123 = !DILocation(line: 476, column: 64, scope: !83)
!124 = !DILocation(line: 476, column: 50, scope: !83)
!125 = !DILocation(line: 476, column: 129, scope: !83)
!126 = !DILocation(line: 476, column: 134, scope: !83)
!127 = !DILocation(line: 476, column: 120, scope: !83)
!128 = !DILocation(line: 476, column: 118, scope: !83)
!129 = !DILocation(line: 476, column: 112, scope: !83)
!130 = !DILocation(line: 476, column: 36, scope: !83)
!131 = !DILocation(line: 477, column: 59, scope: !83)
!132 = !DILocation(line: 477, column: 64, scope: !83)
!133 = !DILocation(line: 477, column: 50, scope: !83)
!134 = !DILocation(line: 477, column: 129, scope: !83)
!135 = !DILocation(line: 477, column: 134, scope: !83)
!136 = !DILocation(line: 477, column: 120, scope: !83)
!137 = !DILocation(line: 477, column: 118, scope: !83)
!138 = !DILocation(line: 477, column: 112, scope: !83)
!139 = !DILocation(line: 477, column: 36, scope: !83)
!140 = !DILocation(line: 479, column: 24, scope: !83)
!141 = !DILocation(line: 481, column: 21, scope: !83)
!142 = !DILocation(line: 481, column: 19, scope: !83)
!143 = !DILocation(line: 482, column: 21, scope: !83)
!144 = !DILocation(line: 482, column: 19, scope: !83)
!145 = !DILocation(line: 483, column: 21, scope: !83)
!146 = !DILocation(line: 483, column: 19, scope: !83)
!147 = !DILocation(line: 484, column: 20, scope: !83)
!148 = !DILocation(line: 484, column: 18, scope: !83)
!149 = !DILocation(line: 485, column: 20, scope: !83)
!150 = !DILocation(line: 485, column: 18, scope: !83)
!151 = !DILocation(line: 486, column: 22, scope: !83)
!152 = !DILocation(line: 486, column: 20, scope: !83)
!153 = !DILocation(line: 487, column: 27, scope: !83)
!154 = !DILocation(line: 487, column: 25, scope: !83)
!155 = !DILocation(line: 488, column: 25, scope: !83)
!156 = !DILocation(line: 488, column: 23, scope: !83)
!157 = !DILocation(line: 489, column: 31, scope: !83)
!158 = !DILocation(line: 489, column: 29, scope: !83)
!159 = !DILocation(line: 490, column: 28, scope: !83)
!160 = !DILocation(line: 490, column: 26, scope: !83)
!161 = !DILocation(line: 491, column: 28, scope: !83)
!162 = !DILocation(line: 491, column: 26, scope: !83)
!163 = !DILocation(line: 492, column: 37, scope: !83)
!164 = !DILocation(line: 492, column: 35, scope: !83)
!165 = !DILocation(line: 493, column: 37, scope: !83)
!166 = !DILocation(line: 493, column: 35, scope: !83)
!167 = !DILocation(line: 495, column: 5, scope: !83)
!168 = !DILocation(line: 501, column: 5, scope: !83)
!169 = !DILocation(line: 506, column: 5, scope: !83)
!170 = !DILocation(line: 521, column: 5, scope: !83)
!171 = !DILocation(line: 522, column: 16, scope: !83)
!172 = !DILocation(line: 531, column: 5, scope: !83)
!173 = !DILocation(line: 460, column: 1, scope: !83)
!174 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_memcpyd2h", linkageName: "sys_mod.sys_mod.f_memcpyd2h", scope: null, file: !64, line: 556, type: !5, scopeLine: 556, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!175 = !DILocation(line: 568, column: 5, scope: !176)
!176 = !DILexicalBlockFile(scope: !174, file: !64, discriminator: 0)
!177 = !DILocation(line: 567, column: 5, scope: !176)
!178 = !DILocation(line: 566, column: 5, scope: !176)
!179 = !DILocation(line: 565, column: 5, scope: !176)
!180 = !DILocation(line: 564, column: 5, scope: !176)
!181 = !DILocation(line: 563, column: 5, scope: !176)
!182 = !DILocation(line: 562, column: 5, scope: !176)
!183 = !DILocation(line: 561, column: 5, scope: !176)
!184 = !DILocation(line: 559, column: 5, scope: !176)
!185 = !DILocation(line: 558, column: 20, scope: !176)
!186 = !DILocation(line: 558, column: 32, scope: !176)
!187 = !DILocation(line: 558, column: 5, scope: !176)
!188 = !DILocation(line: 561, column: 33, scope: !176)
!189 = !DILocation(line: 561, column: 38, scope: !176)
!190 = !DILocation(line: 562, column: 34, scope: !176)
!191 = !DILocation(line: 562, column: 39, scope: !176)
!192 = !DILocation(line: 563, column: 34, scope: !176)
!193 = !DILocation(line: 563, column: 39, scope: !176)
!194 = !DILocation(line: 564, column: 33, scope: !176)
!195 = !DILocation(line: 564, column: 38, scope: !176)
!196 = !DILocation(line: 565, column: 33, scope: !176)
!197 = !DILocation(line: 565, column: 38, scope: !176)
!198 = !DILocation(line: 566, column: 35, scope: !176)
!199 = !DILocation(line: 566, column: 21, scope: !176)
!200 = !DILocation(line: 567, column: 41, scope: !176)
!201 = !DILocation(line: 567, column: 27, scope: !176)
!202 = !DILocation(line: 568, column: 39, scope: !176)
!203 = !DILocation(line: 568, column: 25, scope: !176)
!204 = !DILocation(line: 570, column: 24, scope: !176)
!205 = !DILocation(line: 573, column: 21, scope: !176)
!206 = !DILocation(line: 573, column: 19, scope: !176)
!207 = !DILocation(line: 574, column: 21, scope: !176)
!208 = !DILocation(line: 574, column: 19, scope: !176)
!209 = !DILocation(line: 575, column: 21, scope: !176)
!210 = !DILocation(line: 575, column: 19, scope: !176)
!211 = !DILocation(line: 576, column: 20, scope: !176)
!212 = !DILocation(line: 576, column: 18, scope: !176)
!213 = !DILocation(line: 577, column: 20, scope: !176)
!214 = !DILocation(line: 577, column: 18, scope: !176)
!215 = !DILocation(line: 578, column: 22, scope: !176)
!216 = !DILocation(line: 578, column: 20, scope: !176)
!217 = !DILocation(line: 579, column: 27, scope: !176)
!218 = !DILocation(line: 579, column: 25, scope: !176)
!219 = !DILocation(line: 580, column: 25, scope: !176)
!220 = !DILocation(line: 580, column: 23, scope: !176)
!221 = !DILocation(line: 582, column: 5, scope: !176)
!222 = !DILocation(line: 588, column: 59, scope: !176)
!223 = !DILocation(line: 588, column: 5, scope: !176)
!224 = !DILocation(line: 608, column: 5, scope: !176)
!225 = !DILocation(line: 609, column: 16, scope: !176)
!226 = !DILocation(line: 556, column: 1, scope: !176)
!227 = distinct !DISubprogram(name: "sys_mod.sys_mod.oq0_teardow_handler", linkageName: "sys_mod.sys_mod.oq0_teardow_handler", scope: null, file: !64, line: 631, type: !5, scopeLine: 631, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!228 = !DILocation(line: 632, column: 9, scope: !229)
!229 = !DILexicalBlockFile(scope: !227, file: !64, discriminator: 0)
!230 = !DILocation(line: 632, column: 5, scope: !229)
!231 = !DILocation(line: 634, column: 66, scope: !229)
!232 = !DILocation(line: 634, column: 9, scope: !229)
!233 = !DILocation(line: 636, column: 13, scope: !229)
!234 = !DILocation(line: 637, column: 13, scope: !229)
!235 = !DILocation(line: 638, column: 13, scope: !229)
!236 = !DILocation(line: 639, column: 13, scope: !229)
!237 = !DILocation(line: 640, column: 13, scope: !229)
!238 = !DILocation(line: 641, column: 13, scope: !229)
!239 = !DILocation(line: 642, column: 13, scope: !229)
!240 = !DILocation(line: 643, column: 13, scope: !229)
!241 = !DILocation(line: 644, column: 13, scope: !229)
!242 = !DILocation(line: 645, column: 13, scope: !229)
!243 = !DILocation(line: 646, column: 13, scope: !229)
!244 = !DILocation(line: 647, column: 13, scope: !229)
!245 = !DILocation(line: 648, column: 13, scope: !229)
!246 = !DILocation(line: 635, column: 9, scope: !229)
!247 = !DILocation(line: 652, column: 9, scope: !229)
!248 = !DILocation(line: 654, column: 13, scope: !229)
!249 = !DILocation(line: 655, column: 13, scope: !229)
!250 = !DILocation(line: 656, column: 13, scope: !229)
!251 = !DILocation(line: 657, column: 13, scope: !229)
!252 = !DILocation(line: 658, column: 13, scope: !229)
!253 = !DILocation(line: 659, column: 13, scope: !229)
!254 = !DILocation(line: 660, column: 13, scope: !229)
!255 = !DILocation(line: 661, column: 13, scope: !229)
!256 = !DILocation(line: 653, column: 9, scope: !229)
!257 = !DILocation(line: 664, column: 5, scope: !229)
!258 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_rpc", linkageName: "sys_mod.sys_mod.f_rpc", scope: null, file: !64, line: 694, type: !5, scopeLine: 694, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!259 = !DILocation(line: 694, column: 13, scope: !260)
!260 = !DILexicalBlockFile(scope: !258, file: !64, discriminator: 0)
!261 = !DILocation(line: 700, column: 5, scope: !260)
!262 = !DILocation(line: 706, column: 20, scope: !260)
!263 = !DILocation(line: 706, column: 32, scope: !260)
!264 = !DILocation(line: 706, column: 5, scope: !260)
!265 = !DILocation(line: 710, column: 5, scope: !260)
!266 = !DILocation(line: 712, column: 24, scope: !260)
!267 = !DILocation(line: 694, column: 1, scope: !260)
!268 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.stack_push", linkageName: "sys_mod.sys_mod.sys_mod.stack_push", scope: null, file: !269, line: 54, type: !5, scopeLine: 54, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!269 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/sys.csl", directory: "")
!270 = !DILocation(line: 60, column: 5, scope: !271)
!271 = !DILexicalBlockFile(scope: !268, file: !269, discriminator: 0)
!272 = !DILocation(line: 54, column: 16, scope: !271)
!273 = !DILocation(line: 59, column: 13, scope: !271)
!274 = !DILocation(line: 59, column: 24, scope: !271)
!275 = !DILocation(line: 59, column: 5, scope: !271)
!276 = !DILocation(line: 61, column: 25, scope: !271)
!277 = !DILocation(line: 61, column: 5, scope: !271)
!278 = !DILocation(line: 61, column: 11, scope: !271)
!279 = !DILocation(line: 61, column: 10, scope: !271)
!280 = !DILocation(line: 61, column: 23, scope: !271)
!281 = !DILocation(line: 62, column: 18, scope: !271)
!282 = !DILocation(line: 62, column: 29, scope: !271)
!283 = !DILocation(line: 62, column: 16, scope: !271)
!284 = !DILocation(line: 54, column: 1, scope: !271)
!285 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_push", linkageName: "sys_mod.sys_mod.sys_mod.f_push", scope: null, file: !269, line: 72, type: !5, scopeLine: 72, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!286 = !DILocation(line: 72, column: 25, scope: !287)
!287 = !DILexicalBlockFile(scope: !285, file: !269, discriminator: 0)
!288 = !DILocation(line: 72, column: 13, scope: !287)
!289 = !DILocation(line: 73, column: 16, scope: !287)
!290 = !DILocation(line: 73, column: 5, scope: !287)
!291 = !DILocation(line: 72, column: 1, scope: !287)
!292 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.block_cmd_stream", linkageName: "sys_mod.sys_mod.sys_mod.block_cmd_stream", scope: null, file: !269, line: 76, type: !5, scopeLine: 76, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!293 = !DILocation(line: 77, column: 5, scope: !294)
!294 = !DILexicalBlockFile(scope: !292, file: !269, discriminator: 0)
!295 = !DILocation(line: 76, column: 1, scope: !294)
!296 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.sys_mod.unblock_cmd_stream", scope: null, file: !269, line: 80, type: !5, scopeLine: 80, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!297 = !DILocation(line: 81, column: 5, scope: !298)
!298 = !DILexicalBlockFile(scope: !296, file: !269, discriminator: 0)
!299 = !DILocation(line: 80, column: 1, scope: !298)
!300 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_sys_exit", linkageName: "sys_mod.sys_mod.sys_mod.f_sys_exit", scope: null, file: !269, line: 85, type: !5, scopeLine: 85, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!301 = !DILocation(line: 86, column: 5, scope: !302)
!302 = !DILexicalBlockFile(scope: !300, file: !269, discriminator: 0)
!303 = !DILocation(line: 87, column: 5, scope: !302)
!304 = !DILocation(line: 85, column: 1, scope: !302)
!305 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore", linkageName: "sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore", scope: null, file: !269, line: 90, type: !5, scopeLine: 90, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!306 = !DILocation(line: 90, column: 30, scope: !307)
!307 = !DILexicalBlockFile(scope: !305, file: !269, discriminator: 0)
!308 = !DILocation(line: 90, column: 1, scope: !307)
!309 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord", scope: null, file: !310, line: 131, type: !5, scopeLine: 131, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!310 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpyh2d.csl", directory: "")
!311 = !DILocation(line: 132, column: 12, scope: !312)
!312 = !DILexicalBlockFile(scope: !309, file: !310, discriminator: 0)
!313 = !DILocation(line: 132, column: 5, scope: !312)
!314 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord", scope: null, file: !310, line: 134, type: !5, scopeLine: 134, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!315 = !DILocation(line: 135, column: 12, scope: !316)
!316 = !DILexicalBlockFile(scope: !314, file: !310, discriminator: 0)
!317 = !DILocation(line: 135, column: 5, scope: !316)
!318 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval", scope: null, file: !310, line: 148, type: !5, scopeLine: 148, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!319 = !DILocation(line: 148, column: 23, scope: !320)
!320 = !DILexicalBlockFile(scope: !318, file: !310, discriminator: 0)
!321 = !DILocation(line: 149, column: 9, scope: !320)
!322 = !DILocation(line: 149, column: 20, scope: !320)
!323 = !DILocation(line: 149, column: 5, scope: !320)
!324 = !DILocation(line: 152, column: 23, scope: !320)
!325 = !DILocation(line: 152, column: 20, scope: !320)
!326 = !DILocation(line: 152, column: 9, scope: !320)
!327 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start", scope: null, file: !310, line: 226, type: !5, scopeLine: 226, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!328 = !DILocation(line: 233, column: 5, scope: !329)
!329 = !DILexicalBlockFile(scope: !327, file: !310, discriminator: 0)
!330 = !DILocation(line: 226, column: 49, scope: !329)
!331 = !DILocation(line: 226, column: 32, scope: !329)
!332 = !DILocation(line: 226, column: 21, scope: !329)
!333 = !DILocation(line: 229, column: 37, scope: !329)
!334 = !DILocation(line: 229, column: 52, scope: !329)
!335 = !DILocation(line: 229, column: 19, scope: !329)
!336 = !DILocation(line: 233, column: 71, scope: !329)
!337 = !DILocation(line: 233, column: 55, scope: !329)
!338 = !DILocation(line: 233, column: 25, scope: !329)
!339 = !DILocation(line: 235, column: 37, scope: !329)
!340 = !DILocation(line: 235, column: 52, scope: !329)
!341 = !DILocation(line: 235, column: 19, scope: !329)
!342 = !DILocation(line: 236, column: 28, scope: !329)
!343 = !DILocation(line: 236, column: 5, scope: !329)
!344 = !DILocation(line: 237, column: 28, scope: !329)
!345 = !DILocation(line: 237, column: 5, scope: !329)
!346 = !DILocation(line: 238, column: 13, scope: !329)
!347 = !DILocation(line: 238, column: 11, scope: !329)
!348 = !DILocation(line: 238, column: 5, scope: !329)
!349 = !DILocation(line: 239, column: 9, scope: !329)
!350 = !DILocation(line: 241, column: 9, scope: !329)
!351 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream", scope: null, file: !310, line: 249, type: !5, scopeLine: 249, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!352 = !DILocation(line: 250, column: 5, scope: !353)
!353 = !DILexicalBlockFile(scope: !351, file: !310, discriminator: 0)
!354 = !DILocation(line: 249, column: 1, scope: !353)
!355 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure", scope: null, file: !310, line: 276, type: !5, scopeLine: 276, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!356 = !DILocation(line: 414, column: 13, scope: !357)
!357 = !DILexicalBlockFile(scope: !355, file: !310, discriminator: 0)
!358 = !DILocation(line: 413, column: 13, scope: !357)
!359 = !DILocation(line: 400, column: 17, scope: !357)
!360 = !DILocation(line: 340, column: 9, scope: !357)
!361 = !DILocation(line: 339, column: 9, scope: !357)
!362 = !DILocation(line: 337, column: 5, scope: !357)
!363 = !DILocation(line: 319, column: 9, scope: !357)
!364 = !DILocation(line: 318, column: 9, scope: !357)
!365 = !DILocation(line: 315, column: 5, scope: !357)
!366 = !DILocation(line: 292, column: 5, scope: !357)
!367 = !DILocation(line: 291, column: 5, scope: !357)
!368 = !DILocation(line: 289, column: 5, scope: !357)
!369 = !DILocation(line: 288, column: 5, scope: !357)
!370 = !DILocation(line: 287, column: 5, scope: !357)
!371 = !DILocation(line: 286, column: 5, scope: !357)
!372 = !DILocation(line: 285, column: 5, scope: !357)
!373 = !DILocation(line: 284, column: 5, scope: !357)
!374 = !DILocation(line: 283, column: 5, scope: !357)
!375 = !DILocation(line: 282, column: 5, scope: !357)
!376 = !DILocation(line: 281, column: 5, scope: !357)
!377 = !DILocation(line: 280, column: 5, scope: !357)
!378 = !DILocation(line: 279, column: 5, scope: !357)
!379 = !DILocation(line: 278, column: 5, scope: !357)
!380 = !DILocation(line: 277, column: 5, scope: !357)
!381 = !DILocation(line: 291, column: 26, scope: !357)
!382 = !DILocation(line: 292, column: 26, scope: !357)
!383 = !DILocation(line: 315, column: 25, scope: !357)
!384 = !DILocation(line: 315, column: 31, scope: !357)
!385 = !DILocation(line: 315, column: 29, scope: !357)
!386 = !DILocation(line: 316, column: 20, scope: !357)
!387 = !DILocation(line: 316, column: 18, scope: !357)
!388 = !DILocation(line: 317, column: 52, scope: !357)
!389 = !DILocation(line: 317, column: 49, scope: !357)
!390 = !DILocation(line: 317, column: 5, scope: !357)
!391 = !DILocation(line: 318, column: 42, scope: !357)
!392 = !DILocation(line: 318, column: 33, scope: !357)
!393 = !DILocation(line: 318, column: 49, scope: !357)
!394 = !DILocation(line: 318, column: 48, scope: !357)
!395 = !DILocation(line: 318, column: 24, scope: !357)
!396 = !DILocation(line: 319, column: 24, scope: !357)
!397 = !DILocation(line: 319, column: 32, scope: !357)
!398 = !DILocation(line: 319, column: 36, scope: !357)
!399 = !DILocation(line: 319, column: 34, scope: !357)
!400 = !DILocation(line: 319, column: 30, scope: !357)
!401 = !DILocation(line: 320, column: 18, scope: !357)
!402 = !DILocation(line: 320, column: 15, scope: !357)
!403 = !DILocation(line: 320, column: 9, scope: !357)
!404 = !DILocation(line: 321, column: 26, scope: !357)
!405 = !DILocation(line: 325, column: 28, scope: !357)
!406 = !DILocation(line: 325, column: 26, scope: !357)
!407 = !DILocation(line: 331, column: 9, scope: !357)
!408 = !DILocation(line: 331, column: 15, scope: !357)
!409 = !DILocation(line: 331, column: 5, scope: !357)
!410 = !DILocation(line: 332, column: 22, scope: !357)
!411 = !DILocation(line: 334, column: 9, scope: !357)
!412 = !DILocation(line: 334, column: 18, scope: !357)
!413 = !DILocation(line: 334, column: 15, scope: !357)
!414 = !DILocation(line: 334, column: 5, scope: !357)
!415 = !DILocation(line: 335, column: 22, scope: !357)
!416 = !DILocation(line: 338, column: 52, scope: !357)
!417 = !DILocation(line: 338, column: 49, scope: !357)
!418 = !DILocation(line: 338, column: 5, scope: !357)
!419 = !DILocation(line: 339, column: 42, scope: !357)
!420 = !DILocation(line: 339, column: 48, scope: !357)
!421 = !DILocation(line: 339, column: 46, scope: !357)
!422 = !DILocation(line: 339, column: 33, scope: !357)
!423 = !DILocation(line: 339, column: 52, scope: !357)
!424 = !DILocation(line: 339, column: 51, scope: !357)
!425 = !DILocation(line: 339, column: 24, scope: !357)
!426 = !DILocation(line: 340, column: 25, scope: !357)
!427 = !DILocation(line: 340, column: 31, scope: !357)
!428 = !DILocation(line: 340, column: 29, scope: !357)
!429 = !DILocation(line: 340, column: 37, scope: !357)
!430 = !DILocation(line: 340, column: 41, scope: !357)
!431 = !DILocation(line: 340, column: 39, scope: !357)
!432 = !DILocation(line: 340, column: 35, scope: !357)
!433 = !DILocation(line: 341, column: 18, scope: !357)
!434 = !DILocation(line: 341, column: 15, scope: !357)
!435 = !DILocation(line: 341, column: 9, scope: !357)
!436 = !DILocation(line: 342, column: 26, scope: !357)
!437 = !DILocation(line: 347, column: 10, scope: !357)
!438 = !DILocation(line: 347, column: 16, scope: !357)
!439 = !DILocation(line: 347, column: 14, scope: !357)
!440 = !DILocation(line: 347, column: 5, scope: !357)
!441 = !DILocation(line: 348, column: 22, scope: !357)
!442 = !DILocation(line: 350, column: 10, scope: !357)
!443 = !DILocation(line: 350, column: 18, scope: !357)
!444 = !DILocation(line: 350, column: 21, scope: !357)
!445 = !DILocation(line: 350, column: 20, scope: !357)
!446 = !DILocation(line: 350, column: 14, scope: !357)
!447 = !DILocation(line: 350, column: 5, scope: !357)
!448 = !DILocation(line: 351, column: 22, scope: !357)
!449 = !DILocation(line: 354, column: 9, scope: !357)
!450 = !DILocation(line: 354, column: 5, scope: !357)
!451 = !DILocation(line: 358, column: 9, scope: !357)
!452 = !DILocation(line: 361, column: 9, scope: !357)
!453 = !DILocation(line: 364, column: 20, scope: !357)
!454 = !DILocation(line: 364, column: 17, scope: !357)
!455 = !DILocation(line: 364, column: 9, scope: !357)
!456 = !DILocation(line: 368, column: 13, scope: !357)
!457 = !DILocation(line: 371, column: 13, scope: !357)
!458 = !DILocation(line: 375, column: 13, scope: !357)
!459 = !DILocation(line: 394, column: 13, scope: !357)
!460 = !DILocation(line: 396, column: 29, scope: !357)
!461 = !DILocation(line: 396, column: 27, scope: !357)
!462 = !DILocation(line: 397, column: 60, scope: !357)
!463 = !DILocation(line: 397, column: 57, scope: !357)
!464 = !DILocation(line: 397, column: 13, scope: !357)
!465 = !DILocation(line: 400, column: 54, scope: !357)
!466 = !DILocation(line: 400, column: 55, scope: !357)
!467 = !DILocation(line: 400, column: 46, scope: !357)
!468 = !DILocation(line: 400, column: 59, scope: !357)
!469 = !DILocation(line: 400, column: 58, scope: !357)
!470 = !DILocation(line: 400, column: 37, scope: !357)
!471 = !DILocation(line: 400, column: 35, scope: !357)
!472 = !DILocation(line: 401, column: 33, scope: !357)
!473 = !DILocation(line: 401, column: 31, scope: !357)
!474 = !DILocation(line: 402, column: 69, scope: !357)
!475 = !DILocation(line: 402, column: 66, scope: !357)
!476 = !DILocation(line: 402, column: 19, scope: !357)
!477 = !DILocation(line: 404, column: 31, scope: !357)
!478 = !DILocation(line: 408, column: 75, scope: !357)
!479 = !DILocation(line: 408, column: 88, scope: !357)
!480 = !DILocation(line: 408, column: 13, scope: !357)
!481 = !DILocation(line: 413, column: 31, scope: !357)
!482 = !DILocation(line: 414, column: 33, scope: !357)
!483 = !DILocation(line: 415, column: 21, scope: !357)
!484 = !DILocation(line: 415, column: 29, scope: !357)
!485 = !DILocation(line: 415, column: 27, scope: !357)
!486 = !DILocation(line: 415, column: 19, scope: !357)
!487 = !DILocation(line: 416, column: 22, scope: !357)
!488 = !DILocation(line: 416, column: 19, scope: !357)
!489 = !DILocation(line: 416, column: 13, scope: !357)
!490 = !DILocation(line: 417, column: 23, scope: !357)
!491 = !DILocation(line: 419, column: 63, scope: !357)
!492 = !DILocation(line: 419, column: 60, scope: !357)
!493 = !DILocation(line: 419, column: 13, scope: !357)
!494 = !DILocation(line: 421, column: 23, scope: !357)
!495 = !DILocation(line: 423, column: 69, scope: !357)
!496 = !DILocation(line: 423, column: 13, scope: !357)
!497 = !DILocation(line: 426, column: 13, scope: !357)
!498 = !DILocation(line: 430, column: 13, scope: !357)
!499 = !DILocation(line: 433, column: 48, scope: !357)
!500 = !DILocation(line: 433, column: 22, scope: !357)
!501 = !DILocation(line: 433, column: 19, scope: !357)
!502 = !DILocation(line: 433, column: 13, scope: !357)
!503 = !DILocation(line: 436, column: 34, scope: !357)
!504 = !DILocation(line: 436, column: 39, scope: !357)
!505 = !DILocation(line: 436, column: 50, scope: !357)
!506 = !DILocation(line: 436, column: 17, scope: !357)
!507 = !DILocation(line: 452, column: 49, scope: !357)
!508 = !DILocation(line: 452, column: 64, scope: !357)
!509 = !DILocation(line: 452, column: 31, scope: !357)
!510 = !DILocation(line: 453, column: 40, scope: !357)
!511 = !DILocation(line: 453, column: 17, scope: !357)
!512 = !DILocation(line: 454, column: 50, scope: !357)
!513 = !DILocation(line: 454, column: 66, scope: !357)
!514 = !DILocation(line: 454, column: 32, scope: !357)
!515 = !DILocation(line: 455, column: 40, scope: !357)
!516 = !DILocation(line: 455, column: 17, scope: !357)
!517 = !DILocation(line: 456, column: 17, scope: !357)
!518 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit", scope: null, file: !519, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!519 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/filters/wse3.csl", directory: "")
!520 = !DILocation(line: 24, column: 3, scope: !521)
!521 = !DILexicalBlockFile(scope: !518, file: !519, discriminator: 0)
!522 = !DILocation(line: 24, column: 22, scope: !521)
!523 = !DILocation(line: 23, column: 3, scope: !521)
!524 = !DILocation(line: 22, column: 3, scope: !521)
!525 = !DILocation(line: 20, column: 37, scope: !521)
!526 = !DILocation(line: 20, column: 21, scope: !521)
!527 = !DILocation(line: 21, column: 11, scope: !521)
!528 = !DILocation(line: 21, column: 17, scope: !521)
!529 = !DILocation(line: 21, column: 3, scope: !521)
!530 = !DILocation(line: 22, column: 24, scope: !521)
!531 = !DILocation(line: 22, column: 30, scope: !521)
!532 = !DILocation(line: 23, column: 40, scope: !521)
!533 = !DILocation(line: 23, column: 22, scope: !521)
!534 = !DILocation(line: 23, column: 67, scope: !521)
!535 = !DILocation(line: 24, column: 26, scope: !521)
!536 = !DILocation(line: 24, column: 41, scope: !521)
!537 = !DILocation(line: 24, column: 39, scope: !521)
!538 = !DILocation(line: 24, column: 61, scope: !521)
!539 = !DILocation(line: 24, column: 76, scope: !521)
!540 = !DILocation(line: 24, column: 74, scope: !521)
!541 = !DILocation(line: 25, column: 21, scope: !521)
!542 = !DILocation(line: 25, column: 50, scope: !521)
!543 = !DILocation(line: 25, column: 3, scope: !521)
!544 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter", scope: null, file: !519, line: 30, type: !5, scopeLine: 30, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!545 = !DILocation(line: 30, column: 36, scope: !546)
!546 = !DILexicalBlockFile(scope: !544, file: !519, discriminator: 0)
!547 = !DILocation(line: 30, column: 20, scope: !546)
!548 = !DILocation(line: 31, column: 11, scope: !546)
!549 = !DILocation(line: 31, column: 23, scope: !546)
!550 = !DILocation(line: 31, column: 3, scope: !546)
!551 = !DILocation(line: 32, column: 21, scope: !546)
!552 = !DILocation(line: 32, column: 48, scope: !546)
!553 = !DILocation(line: 32, column: 60, scope: !546)
!554 = !DILocation(line: 32, column: 64, scope: !546)
!555 = !DILocation(line: 32, column: 3, scope: !546)
!556 = !DILocation(line: 30, column: 1, scope: !546)
!557 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter", scope: null, file: !519, line: 40, type: !5, scopeLine: 40, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!558 = !DILocation(line: 47, column: 3, scope: !559)
!559 = !DILexicalBlockFile(scope: !557, file: !519, discriminator: 0)
!560 = !DILocation(line: 48, column: 7, scope: !559)
!561 = !DILocation(line: 44, column: 3, scope: !559)
!562 = !DILocation(line: 43, column: 3, scope: !559)
!563 = !DILocation(line: 42, column: 3, scope: !559)
!564 = !DILocation(line: 40, column: 32, scope: !559)
!565 = !DILocation(line: 40, column: 16, scope: !559)
!566 = !DILocation(line: 41, column: 11, scope: !559)
!567 = !DILocation(line: 41, column: 19, scope: !559)
!568 = !DILocation(line: 41, column: 3, scope: !559)
!569 = !DILocation(line: 42, column: 40, scope: !559)
!570 = !DILocation(line: 42, column: 22, scope: !559)
!571 = !DILocation(line: 43, column: 26, scope: !559)
!572 = !DILocation(line: 43, column: 34, scope: !559)
!573 = !DILocation(line: 44, column: 25, scope: !559)
!574 = !DILocation(line: 44, column: 42, scope: !559)
!575 = !DILocation(line: 44, column: 40, scope: !559)
!576 = !DILocation(line: 45, column: 21, scope: !559)
!577 = !DILocation(line: 46, column: 35, scope: !559)
!578 = !DILocation(line: 46, column: 21, scope: !559)
!579 = !DILocation(line: 46, column: 50, scope: !559)
!580 = !DILocation(line: 45, column: 3, scope: !559)
!581 = !DILocation(line: 48, column: 11, scope: !559)
!582 = !DILocation(line: 48, column: 26, scope: !559)
!583 = !DILocation(line: 48, column: 43, scope: !559)
!584 = !DILocation(line: 48, column: 41, scope: !559)
!585 = !DILocation(line: 48, column: 54, scope: !559)
!586 = !DILocation(line: 48, column: 63, scope: !559)
!587 = !DILocation(line: 49, column: 21, scope: !559)
!588 = !DILocation(line: 49, column: 47, scope: !559)
!589 = !DILocation(line: 49, column: 3, scope: !559)
!590 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config", scope: null, file: !591, line: 33, type: !5, scopeLine: 33, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!591 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/filters/common.csl", directory: "")
!592 = !DILocation(line: 33, column: 46, scope: !593)
!593 = !DILexicalBlockFile(scope: !590, file: !591, discriminator: 0)
!594 = !DILocation(line: 33, column: 31, scope: !593)
!595 = !DILocation(line: 33, column: 15, scope: !593)
!596 = !DILocation(line: 34, column: 24, scope: !593)
!597 = !DILocation(line: 34, column: 23, scope: !593)
!598 = !DILocation(line: 34, column: 51, scope: !593)
!599 = !DILocation(line: 34, column: 35, scope: !593)
!600 = !DILocation(line: 34, column: 60, scope: !593)
!601 = !DILocation(line: 34, column: 73, scope: !593)
!602 = !DILocation(line: 34, column: 3, scope: !593)
!603 = !DILocation(line: 33, column: 1, scope: !593)
!604 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config", scope: null, file: !591, line: 38, type: !5, scopeLine: 38, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!605 = !DILocation(line: 38, column: 31, scope: !606)
!606 = !DILexicalBlockFile(scope: !604, file: !591, discriminator: 0)
!607 = !DILocation(line: 38, column: 15, scope: !606)
!608 = !DILocation(line: 39, column: 31, scope: !606)
!609 = !DILocation(line: 39, column: 30, scope: !606)
!610 = !DILocation(line: 39, column: 58, scope: !606)
!611 = !DILocation(line: 39, column: 42, scope: !606)
!612 = !DILocation(line: 39, column: 67, scope: !606)
!613 = !DILocation(line: 39, column: 10, scope: !606)
!614 = !DILocation(line: 39, column: 3, scope: !606)
!615 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit", scope: null, file: !616, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!616 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/teardown.csl", directory: "")
!617 = !DILocation(line: 43, column: 3, scope: !618)
!618 = !DILexicalBlockFile(scope: !615, file: !616, discriminator: 0)
!619 = !DILocation(line: 41, column: 3, scope: !618)
!620 = !DILocation(line: 40, column: 3, scope: !618)
!621 = !DILocation(line: 39, column: 9, scope: !618)
!622 = !DILocation(line: 40, column: 23, scope: !618)
!623 = !DILocation(line: 41, column: 70, scope: !618)
!624 = !DILocation(line: 41, column: 68, scope: !618)
!625 = !DILocation(line: 43, column: 27, scope: !618)
!626 = !DILocation(line: 43, column: 15, scope: !618)
!627 = !DILocation(line: 44, column: 15, scope: !618)
!628 = !DILocation(line: 44, column: 21, scope: !618)
!629 = !DILocation(line: 44, column: 27, scope: !618)
!630 = !DILocation(line: 44, column: 3, scope: !618)
!631 = !DILocation(line: 39, column: 1, scope: !618)
!632 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord", scope: null, file: !633, line: 4, type: !5, scopeLine: 4, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!633 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/layout.csl", directory: "")
!634 = !DILocation(line: 5, column: 10, scope: !635)
!635 = !DILexicalBlockFile(scope: !632, file: !633, discriminator: 0)
!636 = !DILocation(line: 5, column: 67, scope: !635)
!637 = !DILocation(line: 5, column: 3, scope: !635)
!638 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord", scope: null, file: !633, line: 8, type: !5, scopeLine: 8, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!639 = !DILocation(line: 9, column: 10, scope: !640)
!640 = !DILexicalBlockFile(scope: !638, file: !633, discriminator: 0)
!641 = !DILocation(line: 9, column: 67, scope: !640)
!642 = !DILocation(line: 9, column: 3, scope: !640)
!643 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord", scope: null, file: !644, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!644 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config.csl", directory: "")
!645 = !DILocation(line: 50, column: 3, scope: !646)
!646 = !DILexicalBlockFile(scope: !643, file: !644, discriminator: 0)
!647 = !DILocation(line: 43, column: 21, scope: !646)
!648 = !DILocation(line: 50, column: 57, scope: !646)
!649 = !DILocation(line: 50, column: 68, scope: !646)
!650 = !DILocation(line: 50, column: 41, scope: !646)
!651 = !DILocation(line: 50, column: 19, scope: !646)
!652 = !DILocation(line: 52, column: 10, scope: !646)
!653 = !DILocation(line: 52, column: 18, scope: !646)
!654 = !DILocation(line: 48, column: 22, scope: !646)
!655 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.get_x_coord", scope: null, file: !656, line: 171, type: !5, scopeLine: 171, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!656 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpyd2h.csl", directory: "")
!657 = !DILocation(line: 172, column: 12, scope: !658)
!658 = !DILexicalBlockFile(scope: !655, file: !656, discriminator: 0)
!659 = !DILocation(line: 172, column: 5, scope: !658)
!660 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.get_y_coord", scope: null, file: !656, line: 174, type: !5, scopeLine: 174, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!661 = !DILocation(line: 175, column: 12, scope: !662)
!662 = !DILexicalBlockFile(scope: !660, file: !656, discriminator: 0)
!663 = !DILocation(line: 175, column: 5, scope: !662)
!664 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval", scope: null, file: !656, line: 187, type: !5, scopeLine: 187, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!665 = !DILocation(line: 187, column: 23, scope: !666)
!666 = !DILexicalBlockFile(scope: !664, file: !656, discriminator: 0)
!667 = !DILocation(line: 188, column: 9, scope: !666)
!668 = !DILocation(line: 188, column: 20, scope: !666)
!669 = !DILocation(line: 188, column: 5, scope: !666)
!670 = !DILocation(line: 191, column: 23, scope: !666)
!671 = !DILocation(line: 191, column: 20, scope: !666)
!672 = !DILocation(line: 191, column: 9, scope: !666)
!673 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start", scope: null, file: !656, line: 383, type: !5, scopeLine: 383, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!674 = !DILocation(line: 386, column: 5, scope: !675)
!675 = !DILexicalBlockFile(scope: !673, file: !656, discriminator: 0)
!676 = !DILocation(line: 384, column: 72, scope: !675)
!677 = !DILocation(line: 384, column: 59, scope: !675)
!678 = !DILocation(line: 384, column: 46, scope: !675)
!679 = !DILocation(line: 384, column: 33, scope: !675)
!680 = !DILocation(line: 384, column: 19, scope: !675)
!681 = !DILocation(line: 384, column: 5, scope: !675)
!682 = !DILocation(line: 383, column: 32, scope: !675)
!683 = !DILocation(line: 383, column: 21, scope: !675)
!684 = !DILocation(line: 386, column: 26, scope: !675)
!685 = !DILocation(line: 388, column: 28, scope: !675)
!686 = !DILocation(line: 388, column: 17, scope: !675)
!687 = !DILocation(line: 389, column: 25, scope: !675)
!688 = !DILocation(line: 389, column: 23, scope: !675)
!689 = !DILocation(line: 391, column: 38, scope: !675)
!690 = !DILocation(line: 391, column: 20, scope: !675)
!691 = !DILocation(line: 391, column: 18, scope: !675)
!692 = !DILocation(line: 393, column: 7, scope: !675)
!693 = !DILocation(line: 395, column: 17, scope: !675)
!694 = !DILocation(line: 395, column: 15, scope: !675)
!695 = !DILocation(line: 397, column: 15, scope: !675)
!696 = !DILocation(line: 397, column: 13, scope: !675)
!697 = !DILocation(line: 398, column: 15, scope: !675)
!698 = !DILocation(line: 398, column: 25, scope: !675)
!699 = !DILocation(line: 398, column: 23, scope: !675)
!700 = !DILocation(line: 398, column: 31, scope: !675)
!701 = !DILocation(line: 398, column: 13, scope: !675)
!702 = !DILocation(line: 401, column: 10, scope: !675)
!703 = !DILocation(line: 401, column: 17, scope: !675)
!704 = !DILocation(line: 401, column: 14, scope: !675)
!705 = !DILocation(line: 401, column: 5, scope: !675)
!706 = !DILocation(line: 403, column: 48, scope: !675)
!707 = !DILocation(line: 403, column: 26, scope: !675)
!708 = !DILocation(line: 404, column: 26, scope: !675)
!709 = !DILocation(line: 404, column: 18, scope: !675)
!710 = !DILocation(line: 407, column: 48, scope: !675)
!711 = !DILocation(line: 407, column: 26, scope: !675)
!712 = !DILocation(line: 408, column: 27, scope: !675)
!713 = !DILocation(line: 408, column: 18, scope: !675)
!714 = !DILocation(line: 411, column: 14, scope: !675)
!715 = !DILocation(line: 414, column: 14, scope: !675)
!716 = !DILocation(line: 414, column: 11, scope: !675)
!717 = !DILocation(line: 414, column: 5, scope: !675)
!718 = !DILocation(line: 416, column: 44, scope: !675)
!719 = !DILocation(line: 416, column: 75, scope: !675)
!720 = !DILocation(line: 416, column: 59, scope: !675)
!721 = !DILocation(line: 416, column: 25, scope: !675)
!722 = !DILocation(line: 416, column: 23, scope: !675)
!723 = !DILocation(line: 418, column: 41, scope: !675)
!724 = !DILocation(line: 418, column: 23, scope: !675)
!725 = !DILocation(line: 419, column: 9, scope: !675)
!726 = !DILocation(line: 425, column: 44, scope: !675)
!727 = !DILocation(line: 425, column: 23, scope: !675)
!728 = !DILocation(line: 426, column: 41, scope: !675)
!729 = !DILocation(line: 426, column: 23, scope: !675)
!730 = !DILocation(line: 427, column: 9, scope: !675)
!731 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x", scope: null, file: !656, line: 448, type: !5, scopeLine: 448, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!732 = !DILocation(line: 448, column: 31, scope: !733)
!733 = !DILexicalBlockFile(scope: !731, file: !656, discriminator: 0)
!734 = !DILocation(line: 453, column: 5, scope: !733)
!735 = !DILocation(line: 456, column: 19, scope: !733)
!736 = !DILocation(line: 456, column: 17, scope: !733)
!737 = !DILocation(line: 461, column: 5, scope: !733)
!738 = !DILocation(line: 462, column: 28, scope: !733)
!739 = !DILocation(line: 462, column: 5, scope: !733)
!740 = !DILocation(line: 463, column: 5, scope: !733)
!741 = !DILocation(line: 464, column: 9, scope: !733)
!742 = !DILocation(line: 464, column: 10, scope: !733)
!743 = !DILocation(line: 464, column: 7, scope: !733)
!744 = !DILocation(line: 448, column: 1, scope: !733)
!745 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_send_data", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_send_data", scope: null, file: !656, line: 476, type: !5, scopeLine: 476, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!746 = !DILocation(line: 494, column: 9, scope: !747)
!747 = !DILexicalBlockFile(scope: !745, file: !656, discriminator: 0)
!748 = !DILocation(line: 478, column: 9, scope: !747)
!749 = !DILocation(line: 478, column: 13, scope: !747)
!750 = !DILocation(line: 478, column: 11, scope: !747)
!751 = !DILocation(line: 478, column: 5, scope: !747)
!752 = !DILocation(line: 479, column: 9, scope: !747)
!753 = !DILocation(line: 480, column: 32, scope: !747)
!754 = !DILocation(line: 480, column: 9, scope: !747)
!755 = !DILocation(line: 481, column: 17, scope: !747)
!756 = !DILocation(line: 481, column: 15, scope: !747)
!757 = !DILocation(line: 481, column: 9, scope: !747)
!758 = !DILocation(line: 482, column: 13, scope: !747)
!759 = !DILocation(line: 483, column: 51, scope: !747)
!760 = !DILocation(line: 483, column: 29, scope: !747)
!761 = !DILocation(line: 483, column: 27, scope: !747)
!762 = !DILocation(line: 485, column: 13, scope: !747)
!763 = !DILocation(line: 486, column: 51, scope: !747)
!764 = !DILocation(line: 486, column: 29, scope: !747)
!765 = !DILocation(line: 486, column: 27, scope: !747)
!766 = !DILocation(line: 488, column: 13, scope: !747)
!767 = !DILocation(line: 488, column: 14, scope: !747)
!768 = !DILocation(line: 488, column: 11, scope: !747)
!769 = !DILocation(line: 494, column: 30, scope: !747)
!770 = !DILocation(line: 496, column: 14, scope: !747)
!771 = !DILocation(line: 496, column: 25, scope: !747)
!772 = !DILocation(line: 496, column: 22, scope: !747)
!773 = !DILocation(line: 496, column: 9, scope: !747)
!774 = !DILocation(line: 497, column: 13, scope: !747)
!775 = !DILocation(line: 498, column: 13, scope: !747)
!776 = !DILocation(line: 499, column: 13, scope: !747)
!777 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl", scope: null, file: !656, line: 505, type: !5, scopeLine: 505, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!778 = !DILocation(line: 524, column: 13, scope: !779)
!779 = !DILexicalBlockFile(scope: !777, file: !656, discriminator: 0)
!780 = !DILocation(line: 506, column: 14, scope: !779)
!781 = !DILocation(line: 506, column: 11, scope: !779)
!782 = !DILocation(line: 506, column: 5, scope: !779)
!783 = !DILocation(line: 508, column: 9, scope: !779)
!784 = !DILocation(line: 509, column: 32, scope: !779)
!785 = !DILocation(line: 509, column: 9, scope: !779)
!786 = !DILocation(line: 510, column: 9, scope: !779)
!787 = !DILocation(line: 514, column: 13, scope: !779)
!788 = !DILocation(line: 514, column: 17, scope: !779)
!789 = !DILocation(line: 514, column: 15, scope: !779)
!790 = !DILocation(line: 514, column: 9, scope: !779)
!791 = !DILocation(line: 518, column: 13, scope: !779)
!792 = !DILocation(line: 519, column: 36, scope: !779)
!793 = !DILocation(line: 519, column: 13, scope: !779)
!794 = !DILocation(line: 520, column: 13, scope: !779)
!795 = !DILocation(line: 524, column: 34, scope: !779)
!796 = !DILocation(line: 526, column: 18, scope: !779)
!797 = !DILocation(line: 526, column: 29, scope: !779)
!798 = !DILocation(line: 526, column: 26, scope: !779)
!799 = !DILocation(line: 526, column: 13, scope: !779)
!800 = !DILocation(line: 529, column: 17, scope: !779)
!801 = !DILocation(line: 530, column: 17, scope: !779)
!802 = !DILocation(line: 531, column: 17, scope: !779)
!803 = !DILocation(line: 534, column: 17, scope: !779)
!804 = !DILocation(line: 535, column: 40, scope: !779)
!805 = !DILocation(line: 535, column: 17, scope: !779)
!806 = !DILocation(line: 536, column: 17, scope: !779)
!807 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.d2h_configure", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.d2h_configure", scope: null, file: !656, line: 593, type: !5, scopeLine: 593, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!808 = !DILocation(line: 617, column: 26, scope: !809)
!809 = !DILexicalBlockFile(scope: !807, file: !656, discriminator: 0)
!810 = !DILocation(line: 612, column: 47, scope: !809)
!811 = !DILocation(line: 612, column: 27, scope: !809)
!812 = !DILocation(line: 602, column: 5, scope: !809)
!813 = !DILocation(line: 601, column: 5, scope: !809)
!814 = !DILocation(line: 599, column: 5, scope: !809)
!815 = !DILocation(line: 598, column: 5, scope: !809)
!816 = !DILocation(line: 596, column: 5, scope: !809)
!817 = !DILocation(line: 595, column: 5, scope: !809)
!818 = !DILocation(line: 593, column: 86, scope: !809)
!819 = !DILocation(line: 593, column: 70, scope: !809)
!820 = !DILocation(line: 593, column: 60, scope: !809)
!821 = !DILocation(line: 593, column: 52, scope: !809)
!822 = !DILocation(line: 593, column: 44, scope: !809)
!823 = !DILocation(line: 593, column: 35, scope: !809)
!824 = !DILocation(line: 593, column: 26, scope: !809)
!825 = !DILocation(line: 593, column: 18, scope: !809)
!826 = !DILocation(line: 595, column: 26, scope: !809)
!827 = !DILocation(line: 596, column: 26, scope: !809)
!828 = !DILocation(line: 598, column: 23, scope: !809)
!829 = !DILocation(line: 599, column: 23, scope: !809)
!830 = !DILocation(line: 599, column: 28, scope: !809)
!831 = !DILocation(line: 599, column: 26, scope: !809)
!832 = !DILocation(line: 599, column: 29, scope: !809)
!833 = !DILocation(line: 601, column: 24, scope: !809)
!834 = !DILocation(line: 602, column: 24, scope: !809)
!835 = !DILocation(line: 602, column: 29, scope: !809)
!836 = !DILocation(line: 602, column: 27, scope: !809)
!837 = !DILocation(line: 602, column: 30, scope: !809)
!838 = !DILocation(line: 611, column: 20, scope: !809)
!839 = !DILocation(line: 612, column: 11, scope: !809)
!840 = !DILocation(line: 612, column: 18, scope: !809)
!841 = !DILocation(line: 612, column: 15, scope: !809)
!842 = !DILocation(line: 612, column: 32, scope: !809)
!843 = !DILocation(line: 612, column: 39, scope: !809)
!844 = !DILocation(line: 612, column: 36, scope: !809)
!845 = !DILocation(line: 612, column: 52, scope: !809)
!846 = !DILocation(line: 612, column: 59, scope: !809)
!847 = !DILocation(line: 612, column: 56, scope: !809)
!848 = !DILocation(line: 612, column: 5, scope: !809)
!849 = !DILocation(line: 613, column: 24, scope: !809)
!850 = !DILocation(line: 616, column: 15, scope: !809)
!851 = !DILocation(line: 617, column: 11, scope: !809)
!852 = !DILocation(line: 617, column: 18, scope: !809)
!853 = !DILocation(line: 617, column: 15, scope: !809)
!854 = !DILocation(line: 617, column: 30, scope: !809)
!855 = !DILocation(line: 617, column: 5, scope: !809)
!856 = !DILocation(line: 618, column: 19, scope: !809)
!857 = !DILocation(line: 621, column: 9, scope: !809)
!858 = !DILocation(line: 621, column: 5, scope: !809)
!859 = !DILocation(line: 627, column: 9, scope: !809)
!860 = !DILocation(line: 629, column: 13, scope: !809)
!861 = !DILocation(line: 629, column: 25, scope: !809)
!862 = !DILocation(line: 629, column: 21, scope: !809)
!863 = !DILocation(line: 629, column: 9, scope: !809)
!864 = !DILocation(line: 632, column: 13, scope: !809)
!865 = !DILocation(line: 636, column: 13, scope: !809)
!866 = !DILocation(line: 641, column: 9, scope: !809)
!867 = !DILocation(line: 646, column: 13, scope: !809)
!868 = !DILocation(line: 646, column: 9, scope: !809)
!869 = !DILocation(line: 647, column: 30, scope: !809)
!870 = !DILocation(line: 647, column: 35, scope: !809)
!871 = !DILocation(line: 647, column: 46, scope: !809)
!872 = !DILocation(line: 647, column: 50, scope: !809)
!873 = !DILocation(line: 647, column: 54, scope: !809)
!874 = !DILocation(line: 647, column: 57, scope: !809)
!875 = !DILocation(line: 647, column: 60, scope: !809)
!876 = !DILocation(line: 647, column: 63, scope: !809)
!877 = !DILocation(line: 647, column: 13, scope: !809)
!878 = !DILocation(line: 661, column: 9, scope: !809)
!879 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit", scope: null, file: !616, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!880 = !DILocation(line: 43, column: 3, scope: !881)
!881 = !DILexicalBlockFile(scope: !879, file: !616, discriminator: 0)
!882 = !DILocation(line: 41, column: 3, scope: !881)
!883 = !DILocation(line: 40, column: 3, scope: !881)
!884 = !DILocation(line: 39, column: 9, scope: !881)
!885 = !DILocation(line: 40, column: 23, scope: !881)
!886 = !DILocation(line: 41, column: 70, scope: !881)
!887 = !DILocation(line: 41, column: 68, scope: !881)
!888 = !DILocation(line: 43, column: 27, scope: !881)
!889 = !DILocation(line: 43, column: 15, scope: !881)
!890 = !DILocation(line: 44, column: 15, scope: !881)
!891 = !DILocation(line: 44, column: 21, scope: !881)
!892 = !DILocation(line: 44, column: 27, scope: !881)
!893 = !DILocation(line: 44, column: 3, scope: !881)
!894 = !DILocation(line: 39, column: 1, scope: !881)
!895 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord", scope: null, file: !633, line: 4, type: !5, scopeLine: 4, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!896 = !DILocation(line: 5, column: 10, scope: !897)
!897 = !DILexicalBlockFile(scope: !895, file: !633, discriminator: 0)
!898 = !DILocation(line: 5, column: 67, scope: !897)
!899 = !DILocation(line: 5, column: 3, scope: !897)
!900 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord", scope: null, file: !633, line: 8, type: !5, scopeLine: 8, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!901 = !DILocation(line: 9, column: 10, scope: !902)
!902 = !DILexicalBlockFile(scope: !900, file: !633, discriminator: 0)
!903 = !DILocation(line: 9, column: 67, scope: !902)
!904 = !DILocation(line: 9, column: 3, scope: !902)
!905 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord", scope: null, file: !644, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!906 = !DILocation(line: 50, column: 3, scope: !907)
!907 = !DILexicalBlockFile(scope: !905, file: !644, discriminator: 0)
!908 = !DILocation(line: 43, column: 21, scope: !907)
!909 = !DILocation(line: 50, column: 57, scope: !907)
!910 = !DILocation(line: 50, column: 68, scope: !907)
!911 = !DILocation(line: 50, column: 41, scope: !907)
!912 = !DILocation(line: 50, column: 19, scope: !907)
!913 = !DILocation(line: 52, column: 10, scope: !907)
!914 = !DILocation(line: 52, column: 18, scope: !907)
!915 = !DILocation(line: 48, column: 22, scope: !907)
!916 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr", linkageName: "sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr", scope: null, file: !917, line: 11, type: !5, scopeLine: 11, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!917 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/input_queue_config.csl", directory: "")
!918 = !DILocation(line: 11, column: 32, scope: !919)
!919 = !DILexicalBlockFile(scope: !916, file: !917, discriminator: 0)
!920 = !DILocation(line: 12, column: 80, scope: !919)
!921 = !DILocation(line: 12, column: 69, scope: !919)
!922 = !DILocation(line: 12, column: 39, scope: !919)
!923 = !DILocation(line: 12, column: 3, scope: !919)
!924 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue", linkageName: "sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue", scope: null, file: !917, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!925 = !DILocation(line: 46, column: 3, scope: !926)
!926 = !DILexicalBlockFile(scope: !924, file: !917, discriminator: 0)
!927 = !DILocation(line: 45, column: 3, scope: !926)
!928 = !DILocation(line: 39, column: 42, scope: !926)
!929 = !DILocation(line: 39, column: 34, scope: !926)
!930 = !DILocation(line: 39, column: 24, scope: !926)
!931 = !DILocation(line: 45, column: 44, scope: !926)
!932 = !DILocation(line: 45, column: 16, scope: !926)
!933 = !DILocation(line: 46, column: 30, scope: !926)
!934 = !DILocation(line: 46, column: 18, scope: !926)
!935 = !DILocation(line: 56, column: 9, scope: !926)
!936 = !DILocation(line: 56, column: 5, scope: !926)
!937 = !DILocation(line: 58, column: 13, scope: !926)
!938 = !DILocation(line: 58, column: 17, scope: !926)
!939 = !DILocation(line: 58, column: 11, scope: !926)
!940 = !DILocation(line: 61, column: 13, scope: !926)
!941 = !DILocation(line: 61, column: 17, scope: !926)
!942 = !DILocation(line: 61, column: 11, scope: !926)
!943 = !DILocation(line: 66, column: 9, scope: !926)
!944 = !DILocation(line: 66, column: 13, scope: !926)
!945 = !DILocation(line: 66, column: 7, scope: !926)
!946 = !DILocation(line: 68, column: 9, scope: !926)
!947 = !DILocation(line: 68, column: 24, scope: !926)
!948 = !DILocation(line: 68, column: 13, scope: !926)
!949 = !DILocation(line: 68, column: 7, scope: !926)
!950 = !DILocation(line: 70, column: 15, scope: !926)
!951 = !DILocation(line: 70, column: 21, scope: !926)
!952 = !DILocation(line: 70, column: 3, scope: !926)
!953 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr", linkageName: "sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr", scope: null, file: !954, line: 11, type: !5, scopeLine: 11, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!954 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/output_queue_config.csl", directory: "")
!955 = !DILocation(line: 11, column: 33, scope: !956)
!956 = !DILexicalBlockFile(scope: !953, file: !954, discriminator: 0)
!957 = !DILocation(line: 12, column: 82, scope: !956)
!958 = !DILocation(line: 12, column: 40, scope: !956)
!959 = !DILocation(line: 12, column: 3, scope: !956)
!960 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue", linkageName: "sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue", scope: null, file: !954, line: 31, type: !5, scopeLine: 31, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!961 = !DILocation(line: 38, column: 3, scope: !962)
!962 = !DILexicalBlockFile(scope: !960, file: !954, discriminator: 0)
!963 = !DILocation(line: 37, column: 3, scope: !962)
!964 = !DILocation(line: 31, column: 35, scope: !962)
!965 = !DILocation(line: 31, column: 25, scope: !962)
!966 = !DILocation(line: 37, column: 45, scope: !962)
!967 = !DILocation(line: 37, column: 16, scope: !962)
!968 = !DILocation(line: 38, column: 30, scope: !962)
!969 = !DILocation(line: 38, column: 18, scope: !962)
!970 = !DILocation(line: 41, column: 9, scope: !962)
!971 = !DILocation(line: 41, column: 13, scope: !962)
!972 = !DILocation(line: 41, column: 7, scope: !962)
!973 = !DILocation(line: 43, column: 9, scope: !962)
!974 = !DILocation(line: 43, column: 24, scope: !962)
!975 = !DILocation(line: 43, column: 13, scope: !962)
!976 = !DILocation(line: 43, column: 27, scope: !962)
!977 = !DILocation(line: 43, column: 7, scope: !962)
!978 = !DILocation(line: 45, column: 15, scope: !962)
!979 = !DILocation(line: 45, column: 21, scope: !962)
!980 = !DILocation(line: 45, column: 3, scope: !962)
!981 = !DILocation(line: 31, column: 1, scope: !962)
!982 = distinct !DISubprogram(name: ".get_tensor_ptr", linkageName: ".get_tensor_ptr", scope: null, file: !4, line: 1, type: !5, scopeLine: 1, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!983 = !DILocation(line: 1, column: 1, scope: !984)
!984 = !DILexicalBlockFile(scope: !982, file: !4, discriminator: 0)
!985 = distinct !DISubprogram(name: "__generic0sys_mod.sys_mod.tile_config.queue_flush.exit", linkageName: "__generic0sys_mod.sys_mod.tile_config.queue_flush.exit", scope: null, file: !986, line: 12, type: !5, scopeLine: 12, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!986 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/queue_flush.csl", directory: "")
!987 = !DILocation(line: 24, column: 3, scope: !988)
!988 = !DILexicalBlockFile(scope: !985, file: !986, discriminator: 0)
!989 = !DILocation(line: 12, column: 1, scope: !988)
!990 = distinct !DISubprogram(name: "__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position", linkageName: "__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position", scope: null, file: !991, line: 30, type: !5, scopeLine: 30, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!991 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/switch_config.csl", directory: "")
!992 = !DILocation(line: 34, column: 3, scope: !993)
!993 = !DILexicalBlockFile(scope: !990, file: !991, discriminator: 0)
!994 = !DILocation(line: 32, column: 3, scope: !993)
!995 = !DILocation(line: 30, column: 27, scope: !993)
!996 = !DILocation(line: 33, column: 7, scope: !993)
!997 = !DILocation(line: 34, column: 36, scope: !993)
!998 = !DILocation(line: 34, column: 24, scope: !993)
!999 = !DILocation(line: 35, column: 3, scope: !993)
!1000 = !DILocation(line: 35, column: 18, scope: !993)
!1001 = !DILocation(line: 36, column: 15, scope: !993)
!1002 = !DILocation(line: 36, column: 21, scope: !993)
!1003 = !DILocation(line: 36, column: 3, scope: !993)
!1004 = !DILocation(line: 30, column: 1, scope: !993)
!1005 = distinct !DISubprogram(name: "__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", linkageName: "__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", scope: null, file: !1006, line: 96, type: !5, scopeLine: 96, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1006 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/color_config.csl", directory: "")
!1007 = !DILocation(line: 99, column: 3, scope: !1008)
!1008 = !DILexicalBlockFile(scope: !1005, file: !1006, discriminator: 0)
!1009 = !DILocation(line: 98, column: 3, scope: !1008)
!1010 = !DILocation(line: 96, column: 17, scope: !1008)
!1011 = !DILocation(line: 98, column: 16, scope: !1008)
!1012 = !DILocation(line: 99, column: 29, scope: !1008)
!1013 = !DILocation(line: 99, column: 17, scope: !1008)
!1014 = !DILocation(line: 100, column: 13, scope: !1008)
!1015 = !DILocation(line: 100, column: 21, scope: !1008)
!1016 = !DILocation(line: 100, column: 11, scope: !1008)
!1017 = !DILocation(line: 104, column: 7, scope: !1008)
!1018 = !DILocation(line: 104, column: 50, scope: !1008)
!1019 = !DILocation(line: 104, column: 18, scope: !1008)
!1020 = !DILocation(line: 104, column: 15, scope: !1008)
!1021 = !DILocation(line: 121, column: 7, scope: !1008)
!1022 = !DILocation(line: 121, column: 50, scope: !1008)
!1023 = !DILocation(line: 121, column: 18, scope: !1008)
!1024 = !DILocation(line: 121, column: 15, scope: !1008)
!1025 = !DILocation(line: 128, column: 15, scope: !1008)
!1026 = !DILocation(line: 128, column: 21, scope: !1008)
!1027 = !DILocation(line: 128, column: 3, scope: !1008)
!1028 = !DILocation(line: 96, column: 1, scope: !1008)
!1029 = distinct !DISubprogram(name: "__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", linkageName: "__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", scope: null, file: !1006, line: 96, type: !5, scopeLine: 96, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1030 = !DILocation(line: 99, column: 3, scope: !1031)
!1031 = !DILexicalBlockFile(scope: !1029, file: !1006, discriminator: 0)
!1032 = !DILocation(line: 98, column: 3, scope: !1031)
!1033 = !DILocation(line: 96, column: 17, scope: !1031)
!1034 = !DILocation(line: 98, column: 16, scope: !1031)
!1035 = !DILocation(line: 99, column: 29, scope: !1031)
!1036 = !DILocation(line: 99, column: 17, scope: !1031)
!1037 = !DILocation(line: 100, column: 13, scope: !1031)
!1038 = !DILocation(line: 100, column: 21, scope: !1031)
!1039 = !DILocation(line: 100, column: 11, scope: !1031)
!1040 = !DILocation(line: 104, column: 7, scope: !1031)
!1041 = !DILocation(line: 104, column: 50, scope: !1031)
!1042 = !DILocation(line: 104, column: 18, scope: !1031)
!1043 = !DILocation(line: 104, column: 15, scope: !1031)
!1044 = !DILocation(line: 121, column: 7, scope: !1031)
!1045 = !DILocation(line: 121, column: 50, scope: !1031)
!1046 = !DILocation(line: 121, column: 18, scope: !1031)
!1047 = !DILocation(line: 121, column: 15, scope: !1031)
!1048 = !DILocation(line: 128, column: 15, scope: !1031)
!1049 = !DILocation(line: 128, column: 21, scope: !1031)
!1050 = !DILocation(line: 128, column: 3, scope: !1031)
!1051 = !DILocation(line: 96, column: 1, scope: !1031)
!1052 = distinct !DISubprogram(name: "__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", linkageName: "__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", scope: null, file: !1006, line: 60, type: !5, scopeLine: 60, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1053 = !DILocation(line: 61, column: 3, scope: !1054)
!1054 = !DILexicalBlockFile(scope: !1052, file: !1006, discriminator: 0)
!1055 = !DILocation(line: 60, column: 46, scope: !1054)
!1056 = !DILocation(line: 61, column: 16, scope: !1054)
!1057 = !DILocation(line: 72, column: 5, scope: !1054)
!1058 = !DILocation(line: 72, column: 12, scope: !1054)
!1059 = !DILocation(line: 74, column: 10, scope: !1054)
!1060 = !DILocation(line: 74, column: 3, scope: !1054)
!1061 = distinct !DISubprogram(name: "__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes", linkageName: "__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes", scope: null, file: !1006, line: 77, type: !5, scopeLine: 77, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1062 = !DILocation(line: 78, column: 3, scope: !1063)
!1063 = !DILexicalBlockFile(scope: !1061, file: !1006, discriminator: 0)
!1064 = !DILocation(line: 77, column: 46, scope: !1063)
!1065 = !DILocation(line: 78, column: 16, scope: !1063)
!1066 = !DILocation(line: 86, column: 5, scope: !1063)
!1067 = !DILocation(line: 86, column: 12, scope: !1063)
!1068 = !DILocation(line: 91, column: 10, scope: !1063)
!1069 = !DILocation(line: 91, column: 3, scope: !1063)
!1070 = distinct !DISubprogram(name: "__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", linkageName: "__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", scope: null, file: !1006, line: 60, type: !5, scopeLine: 60, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1071 = !DILocation(line: 61, column: 3, scope: !1072)
!1072 = !DILexicalBlockFile(scope: !1070, file: !1006, discriminator: 0)
!1073 = !DILocation(line: 60, column: 46, scope: !1072)
!1074 = !DILocation(line: 61, column: 16, scope: !1072)
!1075 = !DILocation(line: 63, column: 5, scope: !1072)
!1076 = !DILocation(line: 63, column: 12, scope: !1072)
!1077 = !DILocation(line: 74, column: 10, scope: !1072)
!1078 = !DILocation(line: 74, column: 3, scope: !1072)
!1079 = distinct !DISubprogram(name: "__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction", linkageName: "__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction", scope: null, file: !1006, line: 52, type: !5, scopeLine: 52, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1080 = !DILocation(line: 55, column: 3, scope: !1081)
!1081 = !DILexicalBlockFile(scope: !1079, file: !1006, discriminator: 0)
!1082 = !DILocation(line: 54, column: 3, scope: !1081)
!1083 = !DILocation(line: 52, column: 23, scope: !1081)
!1084 = !DILocation(line: 54, column: 16, scope: !1081)
!1085 = !DILocation(line: 55, column: 29, scope: !1081)
!1086 = !DILocation(line: 55, column: 17, scope: !1081)
!1087 = !DILocation(line: 56, column: 3, scope: !1081)
!1088 = !DILocation(line: 56, column: 11, scope: !1081)
!1089 = !DILocation(line: 57, column: 15, scope: !1081)
!1090 = !DILocation(line: 57, column: 21, scope: !1081)
!1091 = !DILocation(line: 57, column: 3, scope: !1081)
!1092 = !DILocation(line: 52, column: 1, scope: !1081)
!1093 = distinct !DISubprogram(name: "__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction", linkageName: "__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction", scope: null, file: !1006, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1094 = !DILocation(line: 23, column: 3, scope: !1095)
!1095 = !DILexicalBlockFile(scope: !1093, file: !1006, discriminator: 0)
!1096 = !DILocation(line: 22, column: 3, scope: !1095)
!1097 = !DILocation(line: 20, column: 21, scope: !1095)
!1098 = !DILocation(line: 22, column: 16, scope: !1095)
!1099 = !DILocation(line: 23, column: 29, scope: !1095)
!1100 = !DILocation(line: 23, column: 17, scope: !1095)
!1101 = !DILocation(line: 24, column: 3, scope: !1095)
!1102 = !DILocation(line: 24, column: 11, scope: !1095)
!1103 = !DILocation(line: 25, column: 15, scope: !1095)
!1104 = !DILocation(line: 25, column: 21, scope: !1095)
!1105 = !DILocation(line: 25, column: 3, scope: !1095)
!1106 = !DILocation(line: 20, column: 1, scope: !1095)
module asm ".section \22.pe_debug_info\22, \22\22"
module asm ".section \22.note\22, \22\22"
