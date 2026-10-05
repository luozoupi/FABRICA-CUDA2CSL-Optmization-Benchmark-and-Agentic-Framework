; ModuleID = './layout.csl'
source_filename = "./layout.csl"
target datalayout = "e-ni:0-p:16:16-i1:16-i16:16-i32:32-i64:64-f32:32-f64:64"
target triple = "cs_sdr-cerebras-csos"

@a = internal global [8 x i16] zeroinitializer, align 4
@b = internal global [8 x i16] zeroinitializer, align 4
@g = internal global [8 x i16] zeroinitializer, align 4
@c = internal global [80 x i16] zeroinitializer, align 4
@d = internal global [8 x i16] zeroinitializer, align 4
@af = internal global [8 x half] zeroinitializer, align 4
@bf = internal global [8 x half] zeroinitializer, align 4
@gf = internal global [8 x half] zeroinitializer, align 4
@cf = internal global [16 x half] zeroinitializer, align 4
@mark = internal global [16 x i16] zeroinitializer, align 4
@p_a = internal global i16* getelementptr inbounds ([8 x i16], [8 x i16]* @a, i32 0, i32 0), align 4
@p_b = internal global i16* getelementptr inbounds ([8 x i16], [8 x i16]* @b, i32 0, i32 0), align 4
@p_g = internal global i16* getelementptr inbounds ([8 x i16], [8 x i16]* @g, i32 0, i32 0), align 4
@p_c = internal global i16* getelementptr inbounds ([80 x i16], [80 x i16]* @c, i32 0, i32 0), align 4
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
@"$$csl_base_address$$2$$sys_mod.sys_mod.memcpyh2d_mod_1.dummy" = dso_local constant [1 x i16] zeroinitializer, align 4
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
@"$$csl_base_address$$1$$sys_mod.sys_mod.memcpyd2h_mod.dummy" = dso_local constant [1 x i16] zeroinitializer, align 4
@sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd = internal global <{ i16, i16, i16, i16 }> <{ i16 1, i16 lshr (i16 ptrtoint ([1 x i16]* @"$$csl_base_address$$1$$sys_mod.sys_mod.memcpyd2h_mod.dummy" to i16), i16 1), i16 143, i16 16 }>, align 4
@"$$csl_base_address$$0$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11" = dso_local global [1 x i32] [i32 190812745], align 4
@sys_mod.sys_mod.memcpyd2h_mod.ctrl_1 = internal global [1 x i32] [i32 157258313], align 4
@sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd = internal global <{ i16, i16, i16, i16 }> <{ i16 1, i16 lshr (i16 ptrtoint ([1 x i32]* @"$$csl_base_address$$0$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11" to i16), i16 1), i16 143, i16 16 }>, align 4
@"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td" = dso_local global [2 x i32] zeroinitializer, align 4
@"$$csl_base_address$$3$$sys_mod.sys_mod.memcpyd2h_mod.teardown_buf" = dso_local constant [1 x i32] [i32 165646921], align 4
@__dsr_lowmeminit_ = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 62, i16 142, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__0 = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 4127, i16 142, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__1 = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 lshr (i16 ptrtoint ([1 x i32]* @"$$csl_base_address$$3$$sys_mod.sys_mod.memcpyd2h_mod.teardown_buf" to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__2 = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 4149, i16 142, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__3 = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 4096, i16 142, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__4 = internal constant <{ i16, i16, i16, i16 }> <{ i16 2, i16 4127, i16 142, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__5 = internal constant <{ i16, i16, i16, i16 }> <{ i16 2, i16 lshr (i16 ptrtoint ([2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td" to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4

declare i8* @malloc(i64)

declare void @free(i8*)

define internal void @compute() !dbg !3 {
  store i16 24576, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i1 false), align 2, !dbg !7
  %1 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @a, i16 0, i1 false), align 2, !dbg !9
  %2 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @b, i16 0, i1 false), align 2, !dbg !10
  %3 = add i16 %1, %2, !dbg !11
  %4 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @g, i16 0, i1 false), align 2, !dbg !12
  %5 = add i16 %3, %4, !dbg !13
  store i16 %5, i16* getelementptr inbounds ([80 x i16], [80 x i16]* @c, i16 0, i1 false), align 2, !dbg !14
  store i16 24577, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i2 1), align 2, !dbg !15
  %6 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @a, i16 0, i2 1), align 2, !dbg !16
  %7 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @b, i16 0, i2 1), align 2, !dbg !17
  %8 = add i16 %6, %7, !dbg !18
  %9 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @g, i16 0, i2 1), align 2, !dbg !19
  %10 = add i16 %8, %9, !dbg !20
  store i16 %10, i16* getelementptr inbounds ([80 x i16], [80 x i16]* @c, i16 0, i2 1), align 2, !dbg !21
  store i16 24578, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i3 2), align 2, !dbg !22
  %11 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @a, i16 0, i3 2), align 2, !dbg !23
  %12 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @b, i16 0, i3 2), align 2, !dbg !24
  %13 = add i16 %11, %12, !dbg !25
  %14 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @g, i16 0, i3 2), align 2, !dbg !26
  %15 = add i16 %13, %14, !dbg !27
  store i16 %15, i16* getelementptr inbounds ([80 x i16], [80 x i16]* @c, i16 0, i3 2), align 2, !dbg !28
  store i16 24579, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i3 3), align 2, !dbg !29
  %16 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @a, i16 0, i3 3), align 2, !dbg !30
  %17 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @b, i16 0, i3 3), align 2, !dbg !31
  %18 = add i16 %16, %17, !dbg !32
  %19 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @g, i16 0, i3 3), align 2, !dbg !33
  %20 = add i16 %18, %19, !dbg !34
  store i16 %20, i16* getelementptr inbounds ([80 x i16], [80 x i16]* @c, i16 0, i3 3), align 2, !dbg !35
  store i16 24580, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i4 4), align 2, !dbg !36
  %21 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @a, i16 0, i4 4), align 2, !dbg !37
  %22 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @b, i16 0, i4 4), align 2, !dbg !38
  %23 = add i16 %21, %22, !dbg !39
  %24 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @g, i16 0, i4 4), align 2, !dbg !40
  %25 = add i16 %23, %24, !dbg !41
  store i16 %25, i16* getelementptr inbounds ([80 x i16], [80 x i16]* @c, i16 0, i4 4), align 2, !dbg !42
  store i16 24581, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i4 5), align 2, !dbg !43
  %26 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @a, i16 0, i4 5), align 2, !dbg !44
  %27 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @b, i16 0, i4 5), align 2, !dbg !45
  %28 = add i16 %26, %27, !dbg !46
  %29 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @g, i16 0, i4 5), align 2, !dbg !47
  %30 = add i16 %28, %29, !dbg !48
  store i16 %30, i16* getelementptr inbounds ([80 x i16], [80 x i16]* @c, i16 0, i4 5), align 2, !dbg !49
  store i16 24582, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i4 6), align 2, !dbg !50
  %31 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @a, i16 0, i4 6), align 2, !dbg !51
  %32 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @b, i16 0, i4 6), align 2, !dbg !52
  %33 = add i16 %31, %32, !dbg !53
  %34 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @g, i16 0, i4 6), align 2, !dbg !54
  %35 = add i16 %33, %34, !dbg !55
  store i16 %35, i16* getelementptr inbounds ([80 x i16], [80 x i16]* @c, i16 0, i4 6), align 2, !dbg !56
  store i16 24583, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i4 7), align 2, !dbg !57
  %36 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @a, i16 0, i4 7), align 2, !dbg !58
  %37 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @b, i16 0, i4 7), align 2, !dbg !59
  %38 = add i16 %36, %37, !dbg !60
  %39 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @g, i16 0, i4 7), align 2, !dbg !61
  %40 = add i16 %38, %39, !dbg !62
  store i16 %40, i16* getelementptr inbounds ([80 x i16], [80 x i16]* @c, i16 0, i4 7), align 2, !dbg !63
  store i16 24584, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i5 8), align 2, !dbg !64
  call void @llvm.sdr.actvt.r(i16 9), !dbg !65
  ret void, !dbg !66
}

define void @f_exit() #0 !dbg !67 {
  call void @sys_mod.unblock_cmd_stream(), !dbg !68
  ret void, !dbg !70
}

define internal void @sys_mod.sys_nop() !dbg !71 {
  ret void, !dbg !73
}

define internal void @sys_mod.unblock_cmd_stream() !dbg !75 {
  call void @sys_mod.sys_mod.unblock_cmd_stream(), !dbg !76
  ret void, !dbg !78
}

define internal void @sys_mod.sys_mod.unblock_cmd_stream() !dbg !79 {
  call void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream(), !dbg !81
  ret void, !dbg !83
}

define internal void @sys_mod.sys_mod.teardown_h2d() !dbg !84 {
  call void @llvm.sdr.actvt.r(i16 27), !dbg !85
  ret void, !dbg !87
}

define void @sys_mod.sys_mod.f_ublk_c22() #1 !dbg !88 {
  call void @sys_mod.sys_mod.unblock_cmd_stream(), !dbg !89
  ret void, !dbg !91
}

define internal void @sys_mod.sys_mod.teardown_d2h() !dbg !92 {
  call void @llvm.sdr.blk.r(i16 0), !dbg !93
  call void @llvm.sdr.actvt.r(i16 28), !dbg !95
  ret void, !dbg !96
}

define void @sys_mod.sys_mod.f_memcpyh2d() #2 !dbg !97 {
  %1 = alloca float, i16 1, align 4, !dbg !98
  %2 = alloca float, i16 1, align 4, !dbg !100
  %3 = alloca i16, i16 1, align 2, !dbg !101
  %4 = alloca i16, i16 1, align 2, !dbg !102
  %5 = alloca i16, i16 1, align 2, !dbg !103
  %6 = alloca i16, i16 1, align 2, !dbg !104
  %7 = alloca i16, i16 1, align 2, !dbg !105
  %8 = alloca i16, i16 1, align 2, !dbg !106
  %9 = alloca i16, i16 1, align 2, !dbg !107
  %10 = alloca i16, i16 1, align 2, !dbg !108
  %11 = alloca i16, i16 1, align 2, !dbg !109
  %12 = alloca i16, i16 1, align 2, !dbg !110
  %13 = alloca i16, i16 1, align 2, !dbg !111
  %14 = alloca i16*, i16 1, align 8, !dbg !112
  %15 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !113
  %16 = icmp eq i16 %15, 15, !dbg !114
  br i1 %16, label %17, label %18, !dbg !115

17:                                               ; preds = %0
  br label %19, !dbg !115

18:                                               ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !115
  br label %19, !dbg !115

19:                                               ; preds = %17, %18
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %14, align 8, !dbg !112
  %20 = load i16*, i16** %14, align 8, !dbg !116
  %21 = load i16, i16* %20, align 2, !dbg !117
  store i16 %21, i16* %13, align 2, !dbg !111
  %22 = load i16*, i16** %14, align 8, !dbg !118
  %23 = getelementptr i16, i16* %22, i16 1, !dbg !119
  %24 = load i16, i16* %23, align 2, !dbg !119
  store i16 %24, i16* %12, align 2, !dbg !110
  %25 = load i16*, i16** %14, align 8, !dbg !120
  %26 = getelementptr i16, i16* %25, i16 2, !dbg !121
  %27 = load i16, i16* %26, align 2, !dbg !121
  store i16 %27, i16* %11, align 2, !dbg !109
  %28 = load i16*, i16** %14, align 8, !dbg !122
  %29 = getelementptr i16, i16* %28, i16 3, !dbg !123
  %30 = load i16, i16* %29, align 2, !dbg !123
  store i16 %30, i16* %10, align 2, !dbg !108
  %31 = load i16*, i16** %14, align 8, !dbg !124
  %32 = getelementptr i16, i16* %31, i16 4, !dbg !125
  %33 = load i16, i16* %32, align 2, !dbg !125
  store i16 %33, i16* %9, align 2, !dbg !107
  %34 = load i16*, i16** %14, align 8, !dbg !126
  %35 = getelementptr i16, i16* %34, i16 5, !dbg !127
  %36 = load i16, i16* %35, align 2, !dbg !127
  store i16 %36, i16* %8, align 2, !dbg !106
  %37 = load i16*, i16** %14, align 8, !dbg !128
  %38 = getelementptr i16, i16* %37, i16 6, !dbg !129
  %39 = load i16, i16* %38, align 2, !dbg !129
  store i16 %39, i16* %7, align 2, !dbg !105
  %40 = load i16*, i16** %14, align 8, !dbg !130
  %41 = getelementptr i16, i16* %40, i16 7, !dbg !131
  %42 = load i16, i16* %41, align 2, !dbg !131
  store i16 %42, i16* %6, align 2, !dbg !104
  %43 = load i16*, i16** %14, align 8, !dbg !132
  %44 = getelementptr i16, i16* %43, i16 8, !dbg !133
  %45 = load i16, i16* %44, align 2, !dbg !133
  store i16 %45, i16* %5, align 2, !dbg !103
  %46 = load i16*, i16** %14, align 8, !dbg !134
  %47 = getelementptr i16, i16* %46, i16 9, !dbg !135
  %48 = load i16, i16* %47, align 2, !dbg !135
  store i16 %48, i16* %4, align 2, !dbg !102
  %49 = load i16*, i16** %14, align 8, !dbg !136
  %50 = getelementptr i16, i16* %49, i16 10, !dbg !137
  %51 = load i16, i16* %50, align 2, !dbg !137
  store i16 %51, i16* %3, align 2, !dbg !101
  %52 = load i16*, i16** %14, align 8, !dbg !138
  %53 = getelementptr i16, i16* %52, i16 12, !dbg !139
  %54 = load i16, i16* %53, align 2, !dbg !139
  %55 = zext i16 %54 to i32, !dbg !140
  %56 = load i16*, i16** %14, align 8, !dbg !141
  %57 = getelementptr i16, i16* %56, i16 11, !dbg !142
  %58 = load i16, i16* %57, align 2, !dbg !142
  %59 = zext i16 %58 to i32, !dbg !143
  %60 = add i32 %59, 16, !dbg !144
  %61 = shl i32 %55, %60, !dbg !145
  %62 = bitcast i32 %61 to float, !dbg !146
  store float %62, float* %2, align 4, !dbg !100
  %63 = load i16*, i16** %14, align 8, !dbg !147
  %64 = getelementptr i16, i16* %63, i16 14, !dbg !148
  %65 = load i16, i16* %64, align 2, !dbg !148
  %66 = zext i16 %65 to i32, !dbg !149
  %67 = load i16*, i16** %14, align 8, !dbg !150
  %68 = getelementptr i16, i16* %67, i16 13, !dbg !151
  %69 = load i16, i16* %68, align 2, !dbg !151
  %70 = zext i16 %69 to i32, !dbg !152
  %71 = add i32 %70, 16, !dbg !153
  %72 = shl i32 %66, %71, !dbg !154
  %73 = bitcast i32 %72 to float, !dbg !155
  store float %73, float* %1, align 4, !dbg !98
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !156
  %74 = load i16, i16* %13, align 2, !dbg !157
  store i16 %74, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !158
  %75 = load i16, i16* %12, align 2, !dbg !159
  store i16 %75, i16* @sys_mod.sys_mod.memcpyH2D_px, align 2, !dbg !160
  %76 = load i16, i16* %11, align 2, !dbg !161
  store i16 %76, i16* @sys_mod.sys_mod.memcpyH2D_py, align 2, !dbg !162
  %77 = load i16, i16* %10, align 2, !dbg !163
  store i16 %77, i16* @sys_mod.sys_mod.memcpyH2D_w, align 2, !dbg !164
  %78 = load i16, i16* %9, align 2, !dbg !165
  store i16 %78, i16* @sys_mod.sys_mod.memcpyH2D_h, align 2, !dbg !166
  %79 = load i16, i16* %8, align 2, !dbg !167
  store i16 %79, i16* @sys_mod.sys_mod.memcpyH2D_addr, align 2, !dbg !168
  %80 = load i16, i16* %7, align 2, !dbg !169
  store i16 %80, i16* @sys_mod.sys_mod.memcpyH2D_pe_length, align 2, !dbg !170
  %81 = load i16, i16* %6, align 2, !dbg !171
  store i16 %81, i16* @sys_mod.sys_mod.memcpyH2D_is_half, align 2, !dbg !172
  %82 = load i16, i16* %5, align 2, !dbg !173
  store i16 %82, i16* @sys_mod.sys_mod.memcpyH2D_memcpy_optype, align 2, !dbg !174
  %83 = load i16, i16* %4, align 2, !dbg !175
  store i16 %83, i16* @sys_mod.sys_mod.memcpyH2D_row_stride, align 2, !dbg !176
  %84 = load i16, i16* %3, align 2, !dbg !177
  store i16 %84, i16* @sys_mod.sys_mod.memcpyH2D_col_stride, align 2, !dbg !178
  %85 = load float, float* %2, align 4, !dbg !179
  store float %85, float* @sys_mod.sys_mod.memcpyH2D_one_over_row_stride, align 4, !dbg !180
  %86 = load float, float* %1, align 4, !dbg !181
  store float %86, float* @sys_mod.sys_mod.memcpyH2D_one_over_col_stride, align 4, !dbg !182
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !183
  call void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 0, i16 23, i1 true), !dbg !184
  call void @llvm.sdr.blk.r(i16 27), !dbg !185
  call void @llvm.sdr.oqflush(i16 0), !dbg !186
  store i1 true, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !187
  call void @llvm.sdr.blk.r(i16 0), !dbg !188
  ret void, !dbg !189
}

define void @sys_mod.sys_mod.f_memcpyd2h() #3 !dbg !190 {
  %1 = alloca i16, i16 1, align 2, !dbg !191
  %2 = alloca i16, i16 1, align 2, !dbg !193
  %3 = alloca i16, i16 1, align 2, !dbg !194
  %4 = alloca i16, i16 1, align 2, !dbg !195
  %5 = alloca i16, i16 1, align 2, !dbg !196
  %6 = alloca i16, i16 1, align 2, !dbg !197
  %7 = alloca i16, i16 1, align 2, !dbg !198
  %8 = alloca i16, i16 1, align 2, !dbg !199
  %9 = alloca i16*, i16 1, align 8, !dbg !200
  %10 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !201
  %11 = icmp eq i16 %10, 8, !dbg !202
  br i1 %11, label %12, label %13, !dbg !203

12:                                               ; preds = %0
  br label %14, !dbg !203

13:                                               ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !203
  br label %14, !dbg !203

14:                                               ; preds = %12, %13
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %9, align 8, !dbg !200
  %15 = load i16*, i16** %9, align 8, !dbg !204
  %16 = load i16, i16* %15, align 2, !dbg !205
  store i16 %16, i16* %8, align 2, !dbg !199
  %17 = load i16*, i16** %9, align 8, !dbg !206
  %18 = getelementptr i16, i16* %17, i16 1, !dbg !207
  %19 = load i16, i16* %18, align 2, !dbg !207
  store i16 %19, i16* %7, align 2, !dbg !198
  %20 = load i16*, i16** %9, align 8, !dbg !208
  %21 = getelementptr i16, i16* %20, i16 2, !dbg !209
  %22 = load i16, i16* %21, align 2, !dbg !209
  store i16 %22, i16* %6, align 2, !dbg !197
  %23 = load i16*, i16** %9, align 8, !dbg !210
  %24 = getelementptr i16, i16* %23, i16 3, !dbg !211
  %25 = load i16, i16* %24, align 2, !dbg !211
  store i16 %25, i16* %5, align 2, !dbg !196
  %26 = load i16*, i16** %9, align 8, !dbg !212
  %27 = getelementptr i16, i16* %26, i16 4, !dbg !213
  %28 = load i16, i16* %27, align 2, !dbg !213
  store i16 %28, i16* %4, align 2, !dbg !195
  %29 = load i16*, i16** %9, align 8, !dbg !214
  %30 = getelementptr i16, i16* %29, i16 5, !dbg !215
  %31 = load i16, i16* %30, align 2, !dbg !215
  store i16 %31, i16* %3, align 2, !dbg !194
  %32 = load i16*, i16** %9, align 8, !dbg !216
  %33 = getelementptr i16, i16* %32, i16 6, !dbg !217
  %34 = load i16, i16* %33, align 2, !dbg !217
  store i16 %34, i16* %2, align 2, !dbg !193
  %35 = load i16*, i16** %9, align 8, !dbg !218
  %36 = getelementptr i16, i16* %35, i16 7, !dbg !219
  %37 = load i16, i16* %36, align 2, !dbg !219
  store i16 %37, i16* %1, align 2, !dbg !191
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !220
  %38 = load i16, i16* %8, align 2, !dbg !221
  store i16 %38, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !222
  %39 = load i16, i16* %7, align 2, !dbg !223
  store i16 %39, i16* @sys_mod.sys_mod.memcpyD2H_px, align 2, !dbg !224
  %40 = load i16, i16* %6, align 2, !dbg !225
  store i16 %40, i16* @sys_mod.sys_mod.memcpyD2H_py, align 2, !dbg !226
  %41 = load i16, i16* %5, align 2, !dbg !227
  store i16 %41, i16* @sys_mod.sys_mod.memcpyD2H_w, align 2, !dbg !228
  %42 = load i16, i16* %4, align 2, !dbg !229
  store i16 %42, i16* @sys_mod.sys_mod.memcpyD2H_h, align 2, !dbg !230
  %43 = load i16, i16* %3, align 2, !dbg !231
  store i16 %43, i16* @sys_mod.sys_mod.memcpyD2H_addr, align 2, !dbg !232
  %44 = load i16, i16* %2, align 2, !dbg !233
  store i16 %44, i16* @sys_mod.sys_mod.memcpyD2H_pe_length, align 2, !dbg !234
  %45 = load i16, i16* %1, align 2, !dbg !235
  store i16 %45, i16* @sys_mod.sys_mod.memcpyD2H_is_half, align 2, !dbg !236
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !237
  %46 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !238
  call void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 0, i16 %46, i1 false), !dbg !239
  call void @llvm.sdr.oqflush(i16 0), !dbg !240
  store i1 false, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !241
  ret void, !dbg !242
}

define internal void @sys_mod.sys_mod.oq0_teardow_handler() !dbg !243 {
  %1 = load i1, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !244
  br i1 %1, label %2, label %17, !dbg !246

2:                                                ; preds = %0
  %3 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !247
  call void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 0, i16 %3), !dbg !248
  %4 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !249
  %5 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_px, align 2, !dbg !250
  %6 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_py, align 2, !dbg !251
  %7 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_w, align 2, !dbg !252
  %8 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_h, align 2, !dbg !253
  %9 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_addr, align 2, !dbg !254
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_pe_length, align 2, !dbg !255
  %11 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_is_half, align 2, !dbg !256
  %12 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_memcpy_optype, align 2, !dbg !257
  %13 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_row_stride, align 2, !dbg !258
  %14 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_col_stride, align 2, !dbg !259
  %15 = load float, float* @sys_mod.sys_mod.memcpyH2D_one_over_row_stride, align 4, !dbg !260
  %16 = load float, float* @sys_mod.sys_mod.memcpyH2D_one_over_col_stride, align 4, !dbg !261
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure(i16 %4, i16 %5, i16 %6, i16 %7, i16 %8, i16 %9, i16 %10, i16 %11, i16 %12, i16 %13, i16 %14, float %15, float %16), !dbg !262
  br label %26, !dbg !246

17:                                               ; preds = %0
  call void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 0, i16 21), !dbg !263
  %18 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !264
  %19 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_px, align 2, !dbg !265
  %20 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_py, align 2, !dbg !266
  %21 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_w, align 2, !dbg !267
  %22 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_h, align 2, !dbg !268
  %23 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_addr, align 2, !dbg !269
  %24 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_pe_length, align 2, !dbg !270
  %25 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_is_half, align 2, !dbg !271
  call void @sys_mod.sys_mod.memcpyd2h_mod.d2h_configure(i16 %18, i16 %19, i16 %20, i16 %21, i16 %22, i16 %23, i16 %24, i16 %25), !dbg !272
  br label %26, !dbg !246

26:                                               ; preds = %2, %17
  call void @__generic0sys_mod.sys_mod.tile_config.queue_flush.exit(), !dbg !273
  ret void, !dbg !246
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

define void @sys_mod.sys_mod.f_rpc(i16 %0) #4 !dbg !274 {
  %2 = alloca i16, i16 1, align 2, !dbg !275
  store i16 %0, i16* %2, align 2, !dbg !275
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !277
  %3 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !278
  %4 = icmp sge i16 %3, 4, !dbg !279
  br i1 %4, label %5, label %6, !dbg !280

5:                                                ; preds = %1
  br label %7, !dbg !280

6:                                                ; preds = %1
  call void asm sideeffect "hcf", ""(), !dbg !280
  br label %7, !dbg !280

7:                                                ; preds = %5, %6
  call void @rpc_server(i32* getelementptr inbounds ([32 x i32], [32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32, i32 0, i32 0)), !dbg !281
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !282
  ret void, !dbg !283
}

define internal void @sys_mod.sys_mod.sys_mod.stack_push(i16 %0) !dbg !284 {
  %2 = alloca i16*, i16 1, align 8, !dbg !286
  %3 = alloca i16, i16 1, align 2, !dbg !288
  store i16 %0, i16* %3, align 2, !dbg !288
  %4 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !289
  %5 = icmp slt i16 %4, 32, !dbg !290
  br i1 %5, label %6, label %7, !dbg !291

6:                                                ; preds = %1
  br label %8, !dbg !291

7:                                                ; preds = %1
  call void asm sideeffect "hcf", ""(), !dbg !291
  br label %8, !dbg !291

8:                                                ; preds = %6, %7
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %2, align 8, !dbg !286
  %9 = load i16, i16* %3, align 2, !dbg !292
  %10 = load i16*, i16** %2, align 8, !dbg !293
  %11 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !294
  %12 = getelementptr i16, i16* %10, i16 %11, !dbg !295
  store i16 %9, i16* %12, align 2, !dbg !296
  %13 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !297
  %14 = add i16 %13, 1, !dbg !298
  store i16 %14, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !299
  ret void, !dbg !300
}

define void @sys_mod.sys_mod.sys_mod.f_push(i16 %0, i16 %1) #5 !dbg !301 {
  %3 = alloca i16, i16 1, align 2, !dbg !302
  %4 = alloca i16, i16 1, align 2, !dbg !304
  store i16 %0, i16* %4, align 2, !dbg !304
  store i16 %1, i16* %3, align 2, !dbg !302
  %5 = load i16, i16* %4, align 2, !dbg !305
  call void @sys_mod.sys_mod.sys_mod.stack_push(i16 %5), !dbg !306
  ret void, !dbg !307
}

define internal void @sys_mod.sys_mod.sys_mod.block_cmd_stream() !dbg !308 {
  call void @llvm.sdr.blk.r(i16 1), !dbg !309
  ret void, !dbg !311
}

define internal void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream() !dbg !312 {
  call void @llvm.sdr.ublk.r(i16 1), !dbg !313
  ret void, !dbg !315
}

define void @sys_mod.sys_mod.sys_mod.f_sys_exit() #6 !dbg !316 {
  call void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream(), !dbg !317
  call void @sys_mod.sys_nop(), !dbg !319
  ret void, !dbg !320
}

define void @sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore(i32 %0) #7 !dbg !321 {
  %2 = alloca i32, i16 1, align 4, !dbg !322
  store i32 %0, i32* %2, align 4, !dbg !322
  ret void, !dbg !324
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord() !dbg !325 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord(), !dbg !327
  ret i16 %1, !dbg !329
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord() !dbg !330 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord(), !dbg !331
  ret i16 %1, !dbg !333
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval(i16 %0) !dbg !334 {
  %2 = alloca i16, i16 1, align 2, !dbg !335
  store i16 %0, i16* %2, align 2, !dbg !335
  %3 = load i16, i16* %2, align 2, !dbg !337
  %4 = icmp ult i16 %3, 24, !dbg !338
  br i1 %4, label %5, label %7, !dbg !339

5:                                                ; preds = %10, %11, %1
  %6 = phi i16 [ 0, %10 ], [ 0, %11 ], [ 1, %1 ]
  br label %12, !dbg !339

7:                                                ; preds = %1
  %8 = load i16, i16* %2, align 2, !dbg !340
  %9 = icmp eq i16 31, %8, !dbg !341
  br i1 %9, label %10, label %11, !dbg !342

10:                                               ; preds = %7
  br label %5, !dbg !342

11:                                               ; preds = %7
  call void asm sideeffect "hcf", ""(), !dbg !342
  br label %5, !dbg !342

12:                                               ; preds = %5
  %13 = phi i16 [ %6, %5 ]
  br label %14, !dbg !339

14:                                               ; preds = %12
  ret i16 %13, !dbg !339
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start(i16 %0, i16 %1, i16 %2) !dbg !343 {
  %4 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !344
  %5 = alloca i16, i16 1, align 2, !dbg !346
  %6 = alloca i16, i16 1, align 2, !dbg !347
  %7 = alloca i16, i16 1, align 2, !dbg !348
  store i16 %0, i16* %7, align 2, !dbg !348
  store i16 %1, i16* %6, align 2, !dbg !347
  store i16 %2, i16* %5, align 2, !dbg !346
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !349
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !349
  %10 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !349
  %11 = load i16, i16* %6, align 2, !dbg !350
  store i16 %11, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !351
  store i16 %8, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !351
  store i16 %9, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !351
  store i16 %10, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !351
  %12 = load i16, i16* %7, align 2, !dbg !352
  %13 = call i16* @.get_tensor_ptr(i16 %12), !dbg !353
  %14 = ptrtoint i16* %13 to i16, !dbg !354
  %15 = lshr i16 %14, 1, !dbg !354
  %16 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !344
  store i16 42, i16* %16, align 2, !dbg !344
  %17 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !344
  store i16 %15, i16* %17, align 2, !dbg !344
  %18 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !344
  store i16 143, i16* %18, align 2, !dbg !344
  %19 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !344
  store i16 16, i16* %19, align 2, !dbg !344
  %20 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !355
  %21 = load i16, i16* %20, align 2, !dbg !355
  %22 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !355
  %23 = load i16, i16* %22, align 2, !dbg !355
  %24 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !355
  %25 = load i16, i16* %24, align 2, !dbg !355
  %26 = load i16, i16* %6, align 2, !dbg !356
  %27 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !357
  store i16 %26, i16* %27, align 2, !dbg !357
  %28 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !357
  store i16 %21, i16* %28, align 2, !dbg !357
  %29 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !357
  store i16 %23, i16* %29, align 2, !dbg !357
  %30 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !357
  store i16 %25, i16* %30, align 2, !dbg !357
  %31 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !358
  %32 = load i16, i16* %31, align 2, !dbg !358
  %33 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !358
  %34 = load i16, i16* %33, align 2, !dbg !358
  %35 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !358
  %36 = load i16, i16* %35, align 2, !dbg !358
  %37 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !358
  %38 = load i16, i16* %37, align 2, !dbg !358
  store volatile i16 %32, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !359
  store volatile i16 %34, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !359
  store volatile i16 %36, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !359
  store volatile i16 %38, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !359
  call void asm sideeffect "nop", ""(), !dbg !359
  call void asm sideeffect "nop", ""(), !dbg !359
  %39 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !360
  %40 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !360
  %41 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !360
  %42 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !360
  %43 = and i16 %41, -193, !dbg !360
  %44 = or i16 %43, 128, !dbg !360
  %45 = and i16 %40, -64, !dbg !360
  %46 = or i16 %45, 27, !dbg !360
  store volatile i16 %39, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !361
  store volatile i16 %46, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !361
  store volatile i16 %44, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !361
  store volatile i16 %42, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !361
  call void asm sideeffect "nop", ""(), !dbg !361
  call void asm sideeffect "nop", ""(), !dbg !361
  %47 = load i16, i16* %5, align 2, !dbg !362
  %48 = icmp ult i16 0, %47, !dbg !363
  br i1 %48, label %49, label %50, !dbg !364

49:                                               ; preds = %3
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !365
  br label %51, !dbg !364

50:                                               ; preds = %3
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !366
  br label %51, !dbg !364

51:                                               ; preds = %49, %50
  ret void, !dbg !364
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream() !dbg !367 {
  call void @llvm.sdr.ublk.r(i16 1), !dbg !368
  ret void, !dbg !370
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7, i16 %8, i16 %9, i16 %10, float %11, float %12) !dbg !371 {
  %14 = alloca i16, i16 1, align 2, !dbg !372
  %15 = alloca i16, i16 1, align 2, !dbg !374
  %16 = alloca i16, i16 1, align 2, !dbg !375
  %17 = alloca i16, i16 1, align 2, !dbg !376
  %18 = alloca i16, i16 1, align 2, !dbg !377
  %19 = alloca i1, i16 1, align 1, !dbg !378
  %20 = alloca i16, i16 1, align 2, !dbg !379
  %21 = alloca i16, i16 1, align 2, !dbg !380
  %22 = alloca i16, i16 1, align 2, !dbg !381
  %23 = alloca i16, i16 1, align 2, !dbg !382
  %24 = alloca i16, i16 1, align 2, !dbg !383
  %25 = alloca float, i16 1, align 4, !dbg !384
  %26 = alloca float, i16 1, align 4, !dbg !385
  %27 = alloca i16, i16 1, align 2, !dbg !386
  %28 = alloca i16, i16 1, align 2, !dbg !387
  %29 = alloca i16, i16 1, align 2, !dbg !388
  %30 = alloca i16, i16 1, align 2, !dbg !389
  %31 = alloca i16, i16 1, align 2, !dbg !390
  %32 = alloca i16, i16 1, align 2, !dbg !391
  %33 = alloca i16, i16 1, align 2, !dbg !392
  %34 = alloca i16, i16 1, align 2, !dbg !393
  %35 = alloca i16, i16 1, align 2, !dbg !394
  %36 = alloca i16, i16 1, align 2, !dbg !395
  %37 = alloca i16, i16 1, align 2, !dbg !396
  store i16 %0, i16* %37, align 2, !dbg !396
  store i16 %1, i16* %36, align 2, !dbg !395
  store i16 %2, i16* %35, align 2, !dbg !394
  store i16 %3, i16* %34, align 2, !dbg !393
  store i16 %4, i16* %33, align 2, !dbg !392
  store i16 %5, i16* %32, align 2, !dbg !391
  store i16 %6, i16* %31, align 2, !dbg !390
  store i16 %7, i16* %30, align 2, !dbg !389
  store i16 %8, i16* %29, align 2, !dbg !388
  store i16 %9, i16* %28, align 2, !dbg !387
  store i16 %10, i16* %27, align 2, !dbg !386
  store float %11, float* %26, align 4, !dbg !385
  store float %12, float* %25, align 4, !dbg !384
  %38 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord(), !dbg !397
  store i16 %38, i16* %24, align 2, !dbg !383
  %39 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord(), !dbg !398
  store i16 %39, i16* %23, align 2, !dbg !382
  %40 = load i16, i16* %24, align 2, !dbg !399
  %41 = load i16, i16* %36, align 2, !dbg !400
  %42 = sub i16 %40, %41, !dbg !401
  store i16 %42, i16* %22, align 2, !dbg !381
  %43 = load i16, i16* %22, align 2, !dbg !402
  store i16 %43, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !403
  %44 = load i16, i16* %29, align 2, !dbg !404
  %45 = icmp eq i16 3, %44, !dbg !405
  br i1 %45, label %46, label %63, !dbg !406

46:                                               ; preds = %13
  %47 = load i16, i16* %22, align 2, !dbg !407
  %48 = sitofp i16 %47 to float, !dbg !408
  %49 = load float, float* %26, align 4, !dbg !409
  %50 = fmul float %48, %49, !dbg !410
  %51 = fptosi float %50 to i16, !dbg !411
  store i16 %51, i16* %21, align 2, !dbg !380
  %52 = load i16, i16* %22, align 2, !dbg !412
  %53 = load i16, i16* %21, align 2, !dbg !413
  %54 = load i16, i16* %28, align 2, !dbg !414
  %55 = mul i16 %53, %54, !dbg !415
  %56 = sub i16 %52, %55, !dbg !416
  store i16 %56, i16* %20, align 2, !dbg !379
  %57 = load i16, i16* %20, align 2, !dbg !417
  %58 = icmp ne i16 0, %57, !dbg !418
  br i1 %58, label %59, label %60, !dbg !419

59:                                               ; preds = %46
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !420
  br label %62, !dbg !419

60:                                               ; preds = %46
  %61 = load i16, i16* %21, align 2, !dbg !421
  store i16 %61, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !422
  br label %62, !dbg !419

62:                                               ; preds = %59, %60
  br label %63, !dbg !406

63:                                               ; preds = %62, %13
  %64 = load i16, i16* %22, align 2, !dbg !423
  %65 = icmp slt i16 %64, 0, !dbg !424
  br i1 %65, label %66, label %67, !dbg !425

66:                                               ; preds = %63
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !426
  br label %67, !dbg !425

67:                                               ; preds = %66, %63
  %68 = load i16, i16* %22, align 2, !dbg !427
  %69 = load i16, i16* %34, align 2, !dbg !428
  %70 = icmp sge i16 %68, %69, !dbg !429
  br i1 %70, label %71, label %72, !dbg !430

71:                                               ; preds = %67
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !431
  br label %72, !dbg !430

72:                                               ; preds = %71, %67
  store i1 false, i1* %19, align 1, !dbg !378
  %73 = load i16, i16* %29, align 2, !dbg !432
  %74 = icmp eq i16 3, %73, !dbg !433
  br i1 %74, label %75, label %94, !dbg !434

75:                                               ; preds = %72
  %76 = load i16, i16* %23, align 2, !dbg !435
  %77 = load i16, i16* %35, align 2, !dbg !436
  %78 = sub i16 %76, %77, !dbg !437
  %79 = sitofp i16 %78 to float, !dbg !438
  %80 = load float, float* %25, align 4, !dbg !439
  %81 = fmul float %79, %80, !dbg !440
  %82 = fptosi float %81 to i16, !dbg !441
  store i16 %82, i16* %18, align 2, !dbg !377
  %83 = load i16, i16* %23, align 2, !dbg !442
  %84 = load i16, i16* %35, align 2, !dbg !443
  %85 = sub i16 %83, %84, !dbg !444
  %86 = load i16, i16* %18, align 2, !dbg !445
  %87 = load i16, i16* %27, align 2, !dbg !446
  %88 = mul i16 %86, %87, !dbg !447
  %89 = sub i16 %85, %88, !dbg !448
  store i16 %89, i16* %17, align 2, !dbg !376
  %90 = load i16, i16* %17, align 2, !dbg !449
  %91 = icmp ne i16 0, %90, !dbg !450
  br i1 %91, label %92, label %93, !dbg !451

92:                                               ; preds = %75
  store i1 true, i1* %19, align 1, !dbg !452
  br label %93, !dbg !451

93:                                               ; preds = %92, %75
  br label %94, !dbg !434

94:                                               ; preds = %93, %72
  %95 = load i16, i16* %23, align 2, !dbg !453
  %96 = load i16, i16* %35, align 2, !dbg !454
  %97 = icmp slt i16 %95, %96, !dbg !455
  br i1 %97, label %98, label %99, !dbg !456

98:                                               ; preds = %94
  store i1 true, i1* %19, align 1, !dbg !457
  br label %99, !dbg !456

99:                                               ; preds = %98, %94
  %100 = load i16, i16* %23, align 2, !dbg !458
  %101 = load i16, i16* %35, align 2, !dbg !459
  %102 = load i16, i16* %33, align 2, !dbg !460
  %103 = add i16 %101, %102, !dbg !461
  %104 = icmp sge i16 %100, %103, !dbg !462
  br i1 %104, label %105, label %106, !dbg !463

105:                                              ; preds = %99
  store i1 true, i1* %19, align 1, !dbg !464
  br label %106, !dbg !463

106:                                              ; preds = %105, %99
  %107 = load i1, i1* %19, align 1, !dbg !465
  br i1 %107, label %108, label %109, !dbg !466

108:                                              ; preds = %106
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream(), !dbg !467
  call void @llvm.sdr.ublk.r(i16 27), !dbg !468
  br label %180, !dbg !466

109:                                              ; preds = %106
  %110 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !469
  %111 = icmp eq i16 -1, %110, !dbg !470
  br i1 %111, label %112, label %113, !dbg !471

112:                                              ; preds = %109
  call void @__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction(i16 31767), !dbg !472
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 23), !dbg !473
  call void @llvm.sdr.ublk.r(i16 27), !dbg !474
  br label %179, !dbg !471

113:                                              ; preds = %109
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter(i16 0, i16 0), !dbg !475
  %114 = load i16, i16* %34, align 2, !dbg !476
  store i16 %114, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !477
  %115 = load i16, i16* %29, align 2, !dbg !478
  %116 = icmp eq i16 3, %115, !dbg !479
  br i1 %116, label %117, label %126, !dbg !480

117:                                              ; preds = %113
  %118 = load i16, i16* %34, align 2, !dbg !481
  %119 = sub i16 %118, 1, !dbg !482
  %120 = sitofp i16 %119 to float, !dbg !483
  %121 = load float, float* %26, align 4, !dbg !484
  %122 = fmul float %120, %121, !dbg !485
  %123 = fptosi float %122 to i16, !dbg !486
  %124 = add i16 %123, 1, !dbg !487
  store i16 %124, i16* %16, align 2, !dbg !375
  %125 = load i16, i16* %16, align 2, !dbg !488
  store i16 %125, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !489
  br label %131, !dbg !480

126:                                              ; preds = %113
  %127 = load i16, i16* %29, align 2, !dbg !490
  %128 = icmp eq i16 1, %127, !dbg !491
  br i1 %128, label %129, label %130, !dbg !492

129:                                              ; preds = %126
  store i16 1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !493
  br label %130, !dbg !492

130:                                              ; preds = %129, %126
  br label %131, !dbg !480

131:                                              ; preds = %117, %130
  %132 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !494
  %133 = sub i16 %132, 1, !dbg !495
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit(i16 0, i16 %133), !dbg !496
  %134 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !497
  store i16 %134, i16* %15, align 2, !dbg !374
  %135 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !498
  store i16 %135, i16* %14, align 2, !dbg !372
  %136 = load i16, i16* %15, align 2, !dbg !499
  %137 = load i16, i16* %14, align 2, !dbg !500
  %138 = sub i16 %136, %137, !dbg !501
  store i16 %138, i16* %15, align 2, !dbg !502
  %139 = load i16, i16* %14, align 2, !dbg !503
  %140 = icmp eq i16 0, %139, !dbg !504
  br i1 %140, label %141, label %142, !dbg !505

141:                                              ; preds = %131
  store i16 0, i16* %15, align 2, !dbg !506
  br label %142, !dbg !505

142:                                              ; preds = %141, %131
  %143 = load i16, i16* %29, align 2, !dbg !507
  %144 = icmp eq i16 1, %143, !dbg !508
  br i1 %144, label %145, label %146, !dbg !509

145:                                              ; preds = %142
  store i16 0, i16* %15, align 2, !dbg !510
  br label %146, !dbg !509

146:                                              ; preds = %145, %142
  %147 = load i16, i16* %15, align 2, !dbg !511
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter(i16 0, i16 %147), !dbg !512
  call void @__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction(i16 31767), !dbg !513
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 23), !dbg !514
  %148 = load i16, i16* %37, align 2, !dbg !515
  %149 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval(i16 %148), !dbg !516
  %150 = icmp eq i16 0, %149, !dbg !517
  br i1 %150, label %151, label %155, !dbg !518

151:                                              ; preds = %146
  %152 = load i16, i16* %32, align 2, !dbg !519
  %153 = load i16, i16* %31, align 2, !dbg !520
  %154 = load i16, i16* %30, align 2, !dbg !521
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start(i16 %152, i16 %153, i16 %154), !dbg !522
  br label %178, !dbg !518

155:                                              ; preds = %146
  %156 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !523
  %157 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !523
  %158 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !523
  %159 = load i16, i16* %31, align 2, !dbg !524
  store i16 %159, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !525
  store i16 %156, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !525
  store i16 %157, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !525
  store i16 %158, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !525
  %160 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !526
  %161 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !526
  %162 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !526
  %163 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !526
  %164 = and i16 %162, -193, !dbg !526
  %165 = or i16 %164, 128, !dbg !526
  store volatile i16 %160, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !527
  store volatile i16 %161, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !527
  store volatile i16 %165, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !527
  store volatile i16 %163, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !527
  call void asm sideeffect "nop", ""(), !dbg !527
  call void asm sideeffect "nop", ""(), !dbg !527
  %166 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !528
  %167 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !528
  %168 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !528
  %169 = load i16, i16* %31, align 2, !dbg !529
  store i16 %169, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !530
  store i16 %166, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !530
  store i16 %167, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !530
  store i16 %168, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !530
  %170 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !531
  %171 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !531
  %172 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !531
  %173 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !531
  %174 = and i16 %172, -193, !dbg !531
  %175 = or i16 %174, 128, !dbg !531
  %176 = and i16 %171, -64, !dbg !531
  %177 = or i16 %176, 27, !dbg !531
  store volatile i16 %170, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !532
  store volatile i16 %177, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !532
  store volatile i16 %175, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !532
  store volatile i16 %173, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !532
  call void asm sideeffect "nop", ""(), !dbg !532
  call void asm sideeffect "nop", ""(), !dbg !532
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !533
  br label %178, !dbg !518

178:                                              ; preds = %151, %155
  br label %179, !dbg !471

179:                                              ; preds = %112, %178
  br label %180, !dbg !466

180:                                              ; preds = %108, %179
  ret void, !dbg !406
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit(i16 %0, i16 %1) !dbg !534 {
  %3 = alloca i16, i16 1, align 2, !dbg !536
  %4 = alloca i16, i16 1, align 2, !dbg !538
  %5 = alloca i16, i16 1, align 2, !dbg !539
  %6 = alloca i16, i16 1, align 2, !dbg !540
  %7 = alloca i16, i16 1, align 2, !dbg !541
  %8 = alloca i16, i16 1, align 2, !dbg !542
  store i16 %0, i16* %8, align 2, !dbg !542
  store i16 %1, i16* %7, align 2, !dbg !541
  %9 = load i16, i16* %7, align 2, !dbg !543
  %10 = icmp ult i16 %9, -32768, !dbg !544
  br i1 %10, label %11, label %12, !dbg !545

11:                                               ; preds = %2
  br label %13, !dbg !545

12:                                               ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !545
  br label %13, !dbg !545

13:                                               ; preds = %11, %12
  %14 = load i16, i16* %7, align 2, !dbg !546
  %15 = mul i16 %14, 2, !dbg !547
  store i16 %15, i16* %6, align 2, !dbg !540
  %16 = load i16, i16* %8, align 2, !dbg !548
  %17 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %16, i16 8), !dbg !549
  %18 = sub i16 %17, 1, !dbg !550
  store i16 %18, i16* %5, align 2, !dbg !539
  %19 = load i16, i16* %6, align 2, !dbg !551
  %20 = load i16, i16* %5, align 2, !dbg !552
  %21 = icmp ult i16 %19, %20, !dbg !553
  br i1 %21, label %22, label %23, !dbg !538

22:                                               ; preds = %13
  store i16 0, i16* %4, align 2, !dbg !538
  br label %27, !dbg !538

23:                                               ; preds = %13
  %24 = load i16, i16* %6, align 2, !dbg !554
  %25 = load i16, i16* %5, align 2, !dbg !555
  %26 = sub i16 %24, %25, !dbg !556
  store i16 %26, i16* %4, align 2, !dbg !538
  br label %27, !dbg !538

27:                                               ; preds = %22, %23
  %28 = load i16, i16* %4, align 2, !dbg !538
  store i16 %28, i16* %3, align 2, !dbg !536
  %29 = load i16, i16* %8, align 2, !dbg !557
  %30 = load i16, i16* %3, align 2, !dbg !558
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %29, i16 4, i16 %30), !dbg !559
  ret void, !dbg !538
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter(i16 %0, i16 %1) !dbg !560 {
  %3 = alloca i16, i16 1, align 2, !dbg !561
  %4 = alloca i16, i16 1, align 2, !dbg !563
  store i16 %0, i16* %4, align 2, !dbg !563
  store i16 %1, i16* %3, align 2, !dbg !561
  %5 = load i16, i16* %3, align 2, !dbg !564
  %6 = icmp ult i16 %5, -32768, !dbg !565
  br i1 %6, label %7, label %8, !dbg !566

7:                                                ; preds = %2
  br label %9, !dbg !566

8:                                                ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !566
  br label %9, !dbg !566

9:                                                ; preds = %7, %8
  %10 = load i16, i16* %4, align 2, !dbg !567
  %11 = load i16, i16* %3, align 2, !dbg !568
  %12 = mul i16 %11, 2, !dbg !569
  %13 = add i16 %12, 1, !dbg !570
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %10, i16 8, i16 %13), !dbg !571
  ret void, !dbg !572
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter(i16 %0, i16 %1) !dbg !573 {
  %3 = alloca i16, i16 1, align 2, !dbg !574
  %4 = alloca i16, i16 1, align 2, !dbg !576
  %5 = alloca i1, i16 1, align 1, !dbg !577
  %6 = alloca i16, i16 1, align 2, !dbg !578
  %7 = alloca i16, i16 1, align 2, !dbg !579
  %8 = alloca i16, i16 1, align 2, !dbg !580
  %9 = alloca i16, i16 1, align 2, !dbg !581
  store i16 %0, i16* %9, align 2, !dbg !581
  store i16 %1, i16* %8, align 2, !dbg !580
  %10 = load i16, i16* %8, align 2, !dbg !582
  %11 = icmp ult i16 %10, -32768, !dbg !583
  br i1 %11, label %12, label %13, !dbg !584

12:                                               ; preds = %2
  br label %14, !dbg !584

13:                                               ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !584
  br label %14, !dbg !584

14:                                               ; preds = %12, %13
  %15 = load i16, i16* %9, align 2, !dbg !585
  %16 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %15, i16 8), !dbg !586
  store i16 %16, i16* %7, align 2, !dbg !579
  %17 = load i16, i16* %8, align 2, !dbg !587
  %18 = mul i16 %17, 2, !dbg !588
  store i16 %18, i16* %6, align 2, !dbg !578
  %19 = load i16, i16* %6, align 2, !dbg !589
  %20 = load i16, i16* %7, align 2, !dbg !590
  %21 = icmp ugt i16 %19, %20, !dbg !591
  store i1 %21, i1* %5, align 1, !dbg !577
  %22 = load i16, i16* %9, align 2, !dbg !592
  %23 = load i1, i1* %5, align 1, !dbg !593
  %24 = zext i1 %23 to i16, !dbg !594
  %25 = shl i16 %24, 6, !dbg !595
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %22, i16 14, i16 %25), !dbg !596
  %26 = load i1, i1* %5, align 1, !dbg !597
  br i1 %26, label %27, label %32, !dbg !576

27:                                               ; preds = %14
  %28 = load i16, i16* %6, align 2, !dbg !598
  %29 = load i16, i16* %7, align 2, !dbg !599
  %30 = sub i16 %28, %29, !dbg !600
  %31 = add i16 %30, 1, !dbg !601
  store i16 %31, i16* %4, align 2, !dbg !576
  br label %34, !dbg !576

32:                                               ; preds = %14
  %33 = load i16, i16* %6, align 2, !dbg !602
  store i16 %33, i16* %4, align 2, !dbg !576
  br label %34, !dbg !576

34:                                               ; preds = %27, %32
  %35 = load i16, i16* %4, align 2, !dbg !576
  store i16 %35, i16* %3, align 2, !dbg !574
  %36 = load i16, i16* %9, align 2, !dbg !603
  %37 = load i16, i16* %3, align 2, !dbg !604
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %36, i16 12, i16 %37), !dbg !605
  ret void, !dbg !576
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %0, i16 %1, i16 %2) !dbg !606 {
  %4 = alloca i16, i16 1, align 2, !dbg !608
  %5 = alloca i16, i16 1, align 2, !dbg !610
  %6 = alloca i16, i16 1, align 2, !dbg !611
  store i16 %0, i16* %6, align 2, !dbg !611
  store i16 %1, i16* %5, align 2, !dbg !610
  store i16 %2, i16* %4, align 2, !dbg !608
  %7 = load i16, i16* %6, align 2, !dbg !612
  %8 = getelementptr [6 x i16], [6 x i16]* @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.filters, i16 0, i16 %7, !dbg !613
  %9 = load i16, i16* %8, align 2, !dbg !613
  %10 = load i16, i16* %5, align 2, !dbg !614
  %11 = add i16 %9, %10, !dbg !615
  %12 = lshr i16 %11, 1, !dbg !616
  %13 = load i16, i16* %4, align 2, !dbg !617
  %14 = shl i16 %12, 1, !dbg !618
  %15 = inttoptr i16 %14 to i16*, !dbg !618
  store volatile i16 %13, i16* %15, align 2, !dbg !618
  call void asm sideeffect "nop", ""(), !dbg !618
  call void asm sideeffect "nop", ""(), !dbg !618
  ret void, !dbg !619
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %0, i16 %1) !dbg !620 {
  %3 = alloca i16, i16 1, align 2, !dbg !621
  %4 = alloca i16, i16 1, align 2, !dbg !623
  store i16 %0, i16* %4, align 2, !dbg !623
  store i16 %1, i16* %3, align 2, !dbg !621
  %5 = load i16, i16* %4, align 2, !dbg !624
  %6 = getelementptr [6 x i16], [6 x i16]* @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.filters, i16 0, i16 %5, !dbg !625
  %7 = load i16, i16* %6, align 2, !dbg !625
  %8 = load i16, i16* %3, align 2, !dbg !626
  %9 = add i16 %7, %8, !dbg !627
  %10 = lshr i16 %9, 1, !dbg !628
  %11 = shl i16 %10, 1, !dbg !629
  %12 = inttoptr i16 %11 to i16*, !dbg !629
  call void asm sideeffect "nop", ""(), !dbg !629
  call void asm sideeffect "nop", ""(), !dbg !629
  %13 = load volatile i16, i16* %12, align 2, !dbg !629
  ret i16 %13, !dbg !630
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 %0) !dbg !631 {
  %2 = alloca i16, i16 1, align 2, !dbg !633
  %3 = alloca i16, i16 1, align 2, !dbg !635
  %4 = alloca i16, i16 1, align 2, !dbg !636
  %5 = alloca i16, i16 1, align 2, !dbg !637
  store i16 %0, i16* %5, align 2, !dbg !637
  %6 = load i16, i16* %5, align 2, !dbg !638
  store i16 %6, i16* %4, align 2, !dbg !636
  %7 = load i16, i16* %4, align 2, !dbg !639
  %8 = add i16 %7, 31744, !dbg !640
  store i16 %8, i16* %3, align 2, !dbg !635
  %9 = load i16, i16* %3, align 2, !dbg !641
  %10 = shl i16 %9, 1, !dbg !642
  %11 = inttoptr i16 %10 to i16*, !dbg !642
  call void asm sideeffect "nop", ""(), !dbg !642
  call void asm sideeffect "nop", ""(), !dbg !642
  %12 = load volatile i16, i16* %11, align 2, !dbg !642
  store i16 %12, i16* %2, align 2, !dbg !633
  %13 = load i16, i16* %3, align 2, !dbg !643
  %14 = load i16, i16* %2, align 2, !dbg !644
  %15 = and i16 %14, 32767, !dbg !645
  %16 = shl i16 %13, 1, !dbg !646
  %17 = inttoptr i16 %16 to i16*, !dbg !646
  store volatile i16 %15, i16* %17, align 2, !dbg !646
  call void asm sideeffect "nop", ""(), !dbg !646
  call void asm sideeffect "nop", ""(), !dbg !646
  ret void, !dbg !647
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord() !dbg !648 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 2), !dbg !650
  %2 = sub i16 %1, 4, !dbg !652
  ret i16 %2, !dbg !653
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord() !dbg !654 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 0), !dbg !655
  %2 = sub i16 %1, 1, !dbg !657
  ret i16 %2, !dbg !658
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 %0) !dbg !659 {
  %2 = alloca i16, i16 1, align 2, !dbg !661
  %3 = alloca i16, i16 1, align 2, !dbg !663
  store i16 %0, i16* %3, align 2, !dbg !663
  %4 = load i16, i16* %3, align 2, !dbg !664
  %5 = lshr i16 %4, 1, !dbg !665
  %6 = add i16 %5, 31813, !dbg !666
  %7 = shl i16 %6, 1, !dbg !667
  %8 = inttoptr i16 %7 to i16*, !dbg !667
  call void asm sideeffect "nop", ""(), !dbg !667
  call void asm sideeffect "nop", ""(), !dbg !667
  %9 = load volatile i16, i16* %8, align 2, !dbg !667
  store i16 %9, i16* %2, align 2, !dbg !661
  %10 = load i16, i16* %2, align 2, !dbg !668
  %11 = and i16 %10, 2047, !dbg !669
  ret i16 %11, !dbg !670
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord() !dbg !671 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord(), !dbg !673
  ret i16 %1, !dbg !675
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.get_y_coord() !dbg !676 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord(), !dbg !677
  ret i16 %1, !dbg !679
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval(i16 %0) !dbg !680 {
  %2 = alloca i16, i16 1, align 2, !dbg !681
  store i16 %0, i16* %2, align 2, !dbg !681
  %3 = load i16, i16* %2, align 2, !dbg !683
  %4 = icmp ult i16 %3, 24, !dbg !684
  br i1 %4, label %5, label %7, !dbg !685

5:                                                ; preds = %10, %11, %1
  %6 = phi i16 [ 0, %10 ], [ 0, %11 ], [ 1, %1 ]
  br label %12, !dbg !685

7:                                                ; preds = %1
  %8 = load i16, i16* %2, align 2, !dbg !686
  %9 = icmp eq i16 31, %8, !dbg !687
  br i1 %9, label %10, label %11, !dbg !688

10:                                               ; preds = %7
  br label %5, !dbg !688

11:                                               ; preds = %7
  call void asm sideeffect "hcf", ""(), !dbg !688
  br label %5, !dbg !688

12:                                               ; preds = %5
  %13 = phi i16 [ %6, %5 ]
  br label %14, !dbg !685

14:                                               ; preds = %12
  ret i16 %13, !dbg !685
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7) !dbg !689 {
  %9 = alloca i16, i16 1, align 2, !dbg !690
  %10 = alloca i16, i16 1, align 2, !dbg !692
  %11 = alloca i16, i16 1, align 2, !dbg !693
  %12 = alloca i16, i16 1, align 2, !dbg !694
  %13 = alloca i16, i16 1, align 2, !dbg !695
  %14 = alloca i16, i16 1, align 2, !dbg !696
  %15 = alloca i16, i16 1, align 2, !dbg !697
  %16 = alloca i16, i16 1, align 2, !dbg !698
  %17 = alloca i16, i16 1, align 2, !dbg !699
  store i16 %0, i16* %17, align 2, !dbg !699
  store i16 %1, i16* %16, align 2, !dbg !698
  store i16 %2, i16* %15, align 2, !dbg !697
  store i16 %3, i16* %14, align 2, !dbg !696
  store i16 %4, i16* %13, align 2, !dbg !695
  store i16 %5, i16* %12, align 2, !dbg !694
  store i16 %6, i16* %11, align 2, !dbg !693
  store i16 %7, i16* %10, align 2, !dbg !692
  %18 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !700
  store i16 %18, i16* %9, align 2, !dbg !690
  %19 = load i16, i16* %11, align 2, !dbg !701
  store i16 %19, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_c, align 2, !dbg !702
  %20 = load i16, i16* %10, align 2, !dbg !703
  store i16 %20, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_is_half, align 2, !dbg !704
  %21 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_c, align 2, !dbg !705
  %22 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval(i16 %21), !dbg !706
  store i16 %22, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !707
  store i16 0, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !708
  %23 = load i16, i16* %16, align 2, !dbg !709
  store i16 %23, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !710
  %24 = load i16, i16* %15, align 2, !dbg !711
  store i16 %24, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !712
  %25 = load i16, i16* %15, align 2, !dbg !713
  %26 = load i16, i16* %13, align 2, !dbg !714
  %27 = add i16 %25, %26, !dbg !715
  %28 = sub i16 %27, 1, !dbg !716
  store i16 %28, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_last, align 2, !dbg !717
  %29 = load i16, i16* %9, align 2, !dbg !718
  %30 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_last, align 2, !dbg !719
  %31 = icmp eq i16 %29, %30, !dbg !720
  br i1 %31, label %32, label %37, !dbg !721

32:                                               ; preds = %8
  %33 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !722
  %34 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !722
  %35 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !722
  store i16 %33, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !723
  store i16 lshr (i16 ptrtoint ([1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.ctrl_1 to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !723
  store i16 %34, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !723
  store i16 %35, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !723
  %36 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.ctrl_1, i16 0, i1 false), align 4, !dbg !724
  store i32 %36, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i1 false), align 4, !dbg !725
  br label %42, !dbg !721

37:                                               ; preds = %8
  %38 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !726
  %39 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !726
  %40 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !726
  store i16 %38, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !727
  store i16 lshr (i16 ptrtoint ([1 x i32]* @"$$csl_base_address$$0$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11" to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !727
  store i16 %39, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !727
  store i16 %40, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !727
  %41 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @"$$csl_base_address$$0$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11", i16 0, i1 false), align 4, !dbg !728
  store i32 %41, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i1 false), align 4, !dbg !729
  br label %42, !dbg !721

42:                                               ; preds = %32, %37
  store i32 165646921, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i2 1), align 4, !dbg !730
  %43 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !731
  %44 = icmp eq i16 0, %43, !dbg !732
  br i1 %44, label %45, label %56, !dbg !733

45:                                               ; preds = %42
  %46 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !734
  %47 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !734
  %48 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !734
  %49 = load i16, i16* %17, align 2, !dbg !735
  %50 = call i16* @.get_tensor_ptr(i16 %49), !dbg !736
  %51 = ptrtoint i16* %50 to i16, !dbg !737
  %52 = lshr i16 %51, 1, !dbg !737
  store i16 %46, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !738
  store i16 %52, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !738
  store i16 %47, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !738
  store i16 %48, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !738
  %53 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !739
  %54 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !739
  %55 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !739
  store i16 1, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !740
  store i16 %53, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !740
  store i16 %54, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !740
  store i16 %55, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !740
  call void @llvm.sdr.actvt.r(i16 21), !dbg !741
  br label %63, !dbg !733

56:                                               ; preds = %42
  %57 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !742
  %58 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !742
  %59 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !742
  store i16 %57, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !743
  store i16 lshr (i16 ptrtoint ([1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.data_buf to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !743
  store i16 %58, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !743
  store i16 %59, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !743
  %60 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !744
  %61 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !744
  %62 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !744
  store i16 1, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !745
  store i16 %60, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !745
  store i16 %61, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !745
  store i16 %62, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !745
  call void @llvm.sdr.ublk.r(i16 0), !dbg !746
  br label %63, !dbg !733

63:                                               ; preds = %45, %56
  ret void, !dbg !721
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x(i32 %0) #8 !dbg !747 {
  %2 = alloca i32, i16 1, align 4, !dbg !748
  store i32 %0, i32* %2, align 4, !dbg !748
  call void @llvm.sdr.blk.r(i16 0), !dbg !750
  %3 = load i32, i32* %2, align 4, !dbg !751
  store i32 %3, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.data_buf, i16 0, i1 false), align 4, !dbg !752
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !753
  %4 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !754
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !754
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !754
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !754
  store volatile i16 %4, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !755
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !755
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !755
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !755
  call void asm sideeffect "nop", ""(), !dbg !755
  call void asm sideeffect "nop", ""(), !dbg !755
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !756
  %8 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !757
  %9 = add i16 %8, 1, !dbg !758
  store i16 %9, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !759
  ret void, !dbg !760
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_send_data() #9 !dbg !761 {
  %1 = alloca i16, i16 1, align 2, !dbg !762
  %2 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !764
  %3 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !765
  %4 = icmp ult i16 %2, %3, !dbg !766
  br i1 %4, label %5, label %27, !dbg !767

5:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !768
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !769
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !769
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !769
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !769
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !770
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !770
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !770
  store volatile i16 %9, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !770
  call void asm sideeffect "nop", ""(), !dbg !770
  call void asm sideeffect "nop", ""(), !dbg !770
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_is_half, align 2, !dbg !771
  %11 = icmp ult i16 0, %10, !dbg !772
  br i1 %11, label %12, label %18, !dbg !773

12:                                               ; preds = %5
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !774
  %13 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !775
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !775
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !775
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !775
  %17 = add i16 %14, 1, !dbg !776
  store i16 %13, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !777
  store i16 %17, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !777
  store i16 %15, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !777
  store i16 %16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !777
  br label %24, !dbg !773

18:                                               ; preds = %5
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !778
  %19 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !779
  %20 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !779
  %21 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !779
  %22 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !779
  %23 = add i16 %20, 2, !dbg !780
  store i16 %19, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !781
  store i16 %23, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !781
  store i16 %21, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !781
  store i16 %22, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !781
  br label %24, !dbg !773

24:                                               ; preds = %12, %18
  %25 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !782
  %26 = add i16 %25, 1, !dbg !783
  store i16 %26, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !784
  br label %34, !dbg !767

27:                                               ; preds = %0
  %28 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !785
  store i16 %28, i16* %1, align 2, !dbg !762
  %29 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !786
  %30 = load i16, i16* %1, align 2, !dbg !787
  %31 = icmp eq i16 %29, %30, !dbg !788
  br i1 %31, label %32, label %33, !dbg !789

32:                                               ; preds = %27
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !790
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__1 to i8*)), !dbg !791
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !792
  br label %33, !dbg !789

33:                                               ; preds = %32, %27
  br label %34, !dbg !767

34:                                               ; preds = %24, %33
  ret void, !dbg !767
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl() #10 !dbg !793 {
  %1 = alloca i16, i16 1, align 2, !dbg !794
  %2 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !796
  %3 = icmp eq i16 0, %2, !dbg !797
  br i1 %3, label %4, label %9, !dbg !798

4:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__2 to i8*)), !dbg !799
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !800
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !800
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !800
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !800
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !801
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !801
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !801
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !801
  call void asm sideeffect "nop", ""(), !dbg !801
  call void asm sideeffect "nop", ""(), !dbg !801
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !802
  br label %31, !dbg !798

9:                                                ; preds = %0
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !803
  %11 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !804
  %12 = icmp ult i16 %10, %11, !dbg !805
  br i1 %12, label %13, label %18, !dbg !806

13:                                               ; preds = %9
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__3 to i8*)), !dbg !807
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !808
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !808
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !808
  %17 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !808
  store volatile i16 %14, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !809
  store volatile i16 %15, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !809
  store volatile i16 %16, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !809
  store volatile i16 %17, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !809
  call void asm sideeffect "nop", ""(), !dbg !809
  call void asm sideeffect "nop", ""(), !dbg !809
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !810
  br label %30, !dbg !806

18:                                               ; preds = %9
  %19 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !811
  store i16 %19, i16* %1, align 2, !dbg !794
  %20 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !812
  %21 = load i16, i16* %1, align 2, !dbg !813
  %22 = icmp eq i16 %20, %21, !dbg !814
  br i1 %22, label %23, label %24, !dbg !815

23:                                               ; preds = %18
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__4 to i8*)), !dbg !816
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__5 to i8*)), !dbg !817
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !818
  br label %29, !dbg !815

24:                                               ; preds = %18
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !819
  %25 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !820
  %26 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !820
  %27 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !820
  %28 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !820
  store volatile i16 %25, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !821
  store volatile i16 %26, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !821
  store volatile i16 %27, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !821
  store volatile i16 %28, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !821
  call void asm sideeffect "nop", ""(), !dbg !821
  call void asm sideeffect "nop", ""(), !dbg !821
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !822
  br label %29, !dbg !815

29:                                               ; preds = %23, %24
  br label %30, !dbg !806

30:                                               ; preds = %13, %29
  br label %31, !dbg !798

31:                                               ; preds = %4, %30
  ret void, !dbg !798
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.d2h_configure(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7) !dbg !823 {
  %9 = alloca i1, i16 1, align 1, !dbg !824
  %10 = alloca i1, i16 1, align 1, !dbg !826
  %11 = alloca i1, i16 1, align 1, !dbg !827
  %12 = alloca i16, i16 1, align 2, !dbg !828
  %13 = alloca i16, i16 1, align 2, !dbg !829
  %14 = alloca i16, i16 1, align 2, !dbg !830
  %15 = alloca i16, i16 1, align 2, !dbg !831
  %16 = alloca i16, i16 1, align 2, !dbg !832
  %17 = alloca i16, i16 1, align 2, !dbg !833
  %18 = alloca i16, i16 1, align 2, !dbg !834
  %19 = alloca i16, i16 1, align 2, !dbg !835
  %20 = alloca i16, i16 1, align 2, !dbg !836
  %21 = alloca i16, i16 1, align 2, !dbg !837
  %22 = alloca i16, i16 1, align 2, !dbg !838
  %23 = alloca i16, i16 1, align 2, !dbg !839
  %24 = alloca i16, i16 1, align 2, !dbg !840
  %25 = alloca i16, i16 1, align 2, !dbg !841
  store i16 %0, i16* %25, align 2, !dbg !841
  store i16 %1, i16* %24, align 2, !dbg !840
  store i16 %2, i16* %23, align 2, !dbg !839
  store i16 %3, i16* %22, align 2, !dbg !838
  store i16 %4, i16* %21, align 2, !dbg !837
  store i16 %5, i16* %20, align 2, !dbg !836
  store i16 %6, i16* %19, align 2, !dbg !835
  store i16 %7, i16* %18, align 2, !dbg !834
  %26 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !842
  store i16 %26, i16* %17, align 2, !dbg !833
  %27 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_y_coord(), !dbg !843
  store i16 %27, i16* %16, align 2, !dbg !832
  %28 = load i16, i16* %24, align 2, !dbg !844
  store i16 %28, i16* %15, align 2, !dbg !831
  %29 = load i16, i16* %24, align 2, !dbg !845
  %30 = load i16, i16* %22, align 2, !dbg !846
  %31 = add i16 %29, %30, !dbg !847
  %32 = sub i16 %31, 1, !dbg !848
  store i16 %32, i16* %14, align 2, !dbg !830
  %33 = load i16, i16* %23, align 2, !dbg !849
  store i16 %33, i16* %13, align 2, !dbg !829
  %34 = load i16, i16* %23, align 2, !dbg !850
  %35 = load i16, i16* %21, align 2, !dbg !851
  %36 = add i16 %34, %35, !dbg !852
  %37 = sub i16 %36, 1, !dbg !853
  store i16 %37, i16* %12, align 2, !dbg !828
  store i1 false, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !854
  %38 = load i16, i16* %17, align 2, !dbg !855
  %39 = load i16, i16* %15, align 2, !dbg !856
  %40 = icmp sge i16 %38, %39, !dbg !857
  br i1 %40, label %41, label %45, !dbg !827

41:                                               ; preds = %8
  %42 = load i16, i16* %16, align 2, !dbg !858
  %43 = load i16, i16* %12, align 2, !dbg !859
  %44 = icmp sle i16 %42, %43, !dbg !860
  store i1 %44, i1* %11, align 1, !dbg !827
  br label %46, !dbg !827

45:                                               ; preds = %8
  store i1 false, i1* %11, align 1, !dbg !827
  br label %46, !dbg !827

46:                                               ; preds = %41, %45
  %47 = load i1, i1* %11, align 1, !dbg !827
  br i1 %47, label %48, label %52, !dbg !826

48:                                               ; preds = %46
  %49 = load i16, i16* %16, align 2, !dbg !861
  %50 = load i16, i16* %13, align 2, !dbg !862
  %51 = icmp sge i16 %49, %50, !dbg !863
  store i1 %51, i1* %10, align 1, !dbg !826
  br label %53, !dbg !826

52:                                               ; preds = %46
  store i1 false, i1* %10, align 1, !dbg !826
  br label %53, !dbg !826

53:                                               ; preds = %48, %52
  %54 = load i1, i1* %10, align 1, !dbg !826
  br i1 %54, label %55, label %56, !dbg !864

55:                                               ; preds = %53
  store i1 true, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !865
  br label %56, !dbg !864

56:                                               ; preds = %55, %53
  store i1 false, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !866
  %57 = load i16, i16* %17, align 2, !dbg !867
  %58 = load i16, i16* %14, align 2, !dbg !868
  %59 = icmp sle i16 %57, %58, !dbg !869
  br i1 %59, label %60, label %62, !dbg !824

60:                                               ; preds = %56
  %61 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !870
  store i1 %61, i1* %9, align 1, !dbg !824
  br label %63, !dbg !824

62:                                               ; preds = %56
  store i1 false, i1* %9, align 1, !dbg !824
  br label %63, !dbg !824

63:                                               ; preds = %60, %62
  %64 = load i1, i1* %9, align 1, !dbg !824
  br i1 %64, label %65, label %66, !dbg !871

65:                                               ; preds = %63
  store i1 true, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !872
  br label %66, !dbg !871

66:                                               ; preds = %65, %63
  %67 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !873
  br i1 %67, label %68, label %86, !dbg !874

68:                                               ; preds = %66
  call void @__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position(i16 31959), !dbg !875
  %69 = load i16, i16* %15, align 2, !dbg !876
  %70 = load i16, i16* %17, align 2, !dbg !877
  %71 = icmp eq i16 %69, %70, !dbg !878
  br i1 %71, label %72, label %73, !dbg !879

72:                                               ; preds = %68
  call void @__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 31765), !dbg !880
  br label %74, !dbg !879

73:                                               ; preds = %68
  call void @__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 31765), !dbg !881
  br label %74, !dbg !879

74:                                               ; preds = %72, %73
  call void @sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit(i16 21), !dbg !882
  %75 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !883
  br i1 %75, label %76, label %85, !dbg !884

76:                                               ; preds = %74
  %77 = load i16, i16* %20, align 2, !dbg !885
  %78 = load i16, i16* %19, align 2, !dbg !886
  %79 = load i16, i16* %24, align 2, !dbg !887
  %80 = load i16, i16* %23, align 2, !dbg !888
  %81 = load i16, i16* %22, align 2, !dbg !889
  %82 = load i16, i16* %21, align 2, !dbg !890
  %83 = load i16, i16* %25, align 2, !dbg !891
  %84 = load i16, i16* %18, align 2, !dbg !892
  call void @sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start(i16 %77, i16 %78, i16 %79, i16 %80, i16 %81, i16 %82, i16 %83, i16 %84), !dbg !893
  br label %85, !dbg !884

85:                                               ; preds = %76, %74
  br label %87, !dbg !874

86:                                               ; preds = %66
  call void @llvm.sdr.actvt.r(i16 28), !dbg !894
  br label %87, !dbg !874

87:                                               ; preds = %85, %86
  ret void, !dbg !827
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit(i16 %0) !dbg !895 {
  %2 = alloca i16, i16 1, align 2, !dbg !896
  %3 = alloca i16, i16 1, align 2, !dbg !898
  %4 = alloca i16, i16 1, align 2, !dbg !899
  %5 = alloca i16, i16 1, align 2, !dbg !900
  store i16 %0, i16* %5, align 2, !dbg !900
  %6 = load i16, i16* %5, align 2, !dbg !901
  store i16 %6, i16* %4, align 2, !dbg !899
  %7 = load i16, i16* %4, align 2, !dbg !902
  %8 = add i16 %7, 31744, !dbg !903
  store i16 %8, i16* %3, align 2, !dbg !898
  %9 = load i16, i16* %3, align 2, !dbg !904
  %10 = shl i16 %9, 1, !dbg !905
  %11 = inttoptr i16 %10 to i16*, !dbg !905
  call void asm sideeffect "nop", ""(), !dbg !905
  call void asm sideeffect "nop", ""(), !dbg !905
  %12 = load volatile i16, i16* %11, align 2, !dbg !905
  store i16 %12, i16* %2, align 2, !dbg !896
  %13 = load i16, i16* %3, align 2, !dbg !906
  %14 = load i16, i16* %2, align 2, !dbg !907
  %15 = and i16 %14, 32767, !dbg !908
  %16 = shl i16 %13, 1, !dbg !909
  %17 = inttoptr i16 %16 to i16*, !dbg !909
  store volatile i16 %15, i16* %17, align 2, !dbg !909
  call void asm sideeffect "nop", ""(), !dbg !909
  call void asm sideeffect "nop", ""(), !dbg !909
  ret void, !dbg !910
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord() !dbg !911 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 2), !dbg !912
  %2 = sub i16 %1, 4, !dbg !914
  ret i16 %2, !dbg !915
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord() !dbg !916 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 0), !dbg !917
  %2 = sub i16 %1, 1, !dbg !919
  ret i16 %2, !dbg !920
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 %0) !dbg !921 {
  %2 = alloca i16, i16 1, align 2, !dbg !922
  %3 = alloca i16, i16 1, align 2, !dbg !924
  store i16 %0, i16* %3, align 2, !dbg !924
  %4 = load i16, i16* %3, align 2, !dbg !925
  %5 = lshr i16 %4, 1, !dbg !926
  %6 = add i16 %5, 31813, !dbg !927
  %7 = shl i16 %6, 1, !dbg !928
  %8 = inttoptr i16 %7 to i16*, !dbg !928
  call void asm sideeffect "nop", ""(), !dbg !928
  call void asm sideeffect "nop", ""(), !dbg !928
  %9 = load volatile i16, i16* %8, align 2, !dbg !928
  store i16 %9, i16* %2, align 2, !dbg !922
  %10 = load i16, i16* %2, align 2, !dbg !929
  %11 = and i16 %10, 2047, !dbg !930
  ret i16 %11, !dbg !931
}

define internal i16 @sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr(i16 %0) !dbg !932 {
  %2 = alloca i16, i16 1, align 2, !dbg !934
  store i16 %0, i16* %2, align 2, !dbg !934
  %3 = load i16, i16* %2, align 2, !dbg !936
  %4 = mul i16 %3, 2, !dbg !937
  %5 = add i16 %4, 31680, !dbg !938
  ret i16 %5, !dbg !939
}

define internal void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 %0, i16 %1, i1 %2) !dbg !940 {
  %4 = alloca i16, i16 1, align 2, !dbg !941
  %5 = alloca i16, i16 1, align 2, !dbg !943
  %6 = alloca i1, i16 1, align 1, !dbg !944
  %7 = alloca i16, i16 1, align 2, !dbg !945
  %8 = alloca i16, i16 1, align 2, !dbg !946
  store i16 %0, i16* %8, align 2, !dbg !946
  store i16 %1, i16* %7, align 2, !dbg !945
  store i1 %2, i1* %6, align 1, !dbg !944
  %9 = load i16, i16* %8, align 2, !dbg !947
  %10 = call i16 @sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr(i16 %9), !dbg !948
  store i16 %10, i16* %5, align 2, !dbg !943
  %11 = load i16, i16* %5, align 2, !dbg !949
  %12 = shl i16 %11, 1, !dbg !950
  %13 = inttoptr i16 %12 to i16*, !dbg !950
  call void asm sideeffect "nop", ""(), !dbg !950
  call void asm sideeffect "nop", ""(), !dbg !950
  call void asm sideeffect "nop", ""(), !dbg !950
  call void asm sideeffect "nop", ""(), !dbg !950
  %14 = load volatile i16, i16* %13, align 2, !dbg !950
  store i16 %14, i16* %4, align 2, !dbg !941
  %15 = load i1, i1* %6, align 1, !dbg !951
  br i1 %15, label %16, label %19, !dbg !952

16:                                               ; preds = %3
  %17 = load i16, i16* %4, align 2, !dbg !953
  %18 = or i16 %17, 2048, !dbg !954
  store i16 %18, i16* %4, align 2, !dbg !955
  br label %22, !dbg !952

19:                                               ; preds = %3
  %20 = load i16, i16* %4, align 2, !dbg !956
  %21 = and i16 %20, -2049, !dbg !957
  store i16 %21, i16* %4, align 2, !dbg !958
  br label %22, !dbg !952

22:                                               ; preds = %16, %19
  %23 = load i16, i16* %4, align 2, !dbg !959
  %24 = and i16 %23, -32, !dbg !960
  store i16 %24, i16* %4, align 2, !dbg !961
  %25 = load i16, i16* %4, align 2, !dbg !962
  %26 = load i16, i16* %7, align 2, !dbg !963
  %27 = add i16 %25, %26, !dbg !964
  store i16 %27, i16* %4, align 2, !dbg !965
  %28 = load i16, i16* %5, align 2, !dbg !966
  %29 = load i16, i16* %4, align 2, !dbg !967
  %30 = shl i16 %28, 1, !dbg !968
  %31 = inttoptr i16 %30 to i16*, !dbg !968
  store volatile i16 %29, i16* %31, align 2, !dbg !968
  call void asm sideeffect "nop", ""(), !dbg !968
  call void asm sideeffect "nop", ""(), !dbg !968
  call void asm sideeffect "nop", ""(), !dbg !968
  call void asm sideeffect "nop", ""(), !dbg !968
  ret void, !dbg !952
}

define internal i16 @sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr(i16 %0) !dbg !969 {
  %2 = alloca i16, i16 1, align 2, !dbg !971
  store i16 %0, i16* %2, align 2, !dbg !971
  %3 = load i16, i16* %2, align 2, !dbg !973
  %4 = add i16 %3, 31616, !dbg !974
  ret i16 %4, !dbg !975
}

define internal void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 %0, i16 %1) !dbg !976 {
  %3 = alloca i16, i16 1, align 2, !dbg !977
  %4 = alloca i16, i16 1, align 2, !dbg !979
  %5 = alloca i16, i16 1, align 2, !dbg !980
  %6 = alloca i16, i16 1, align 2, !dbg !981
  store i16 %0, i16* %6, align 2, !dbg !981
  store i16 %1, i16* %5, align 2, !dbg !980
  %7 = load i16, i16* %6, align 2, !dbg !982
  %8 = call i16 @sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr(i16 %7), !dbg !983
  store i16 %8, i16* %4, align 2, !dbg !979
  %9 = load i16, i16* %4, align 2, !dbg !984
  %10 = shl i16 %9, 1, !dbg !985
  %11 = inttoptr i16 %10 to i16*, !dbg !985
  call void asm sideeffect "nop", ""(), !dbg !985
  call void asm sideeffect "nop", ""(), !dbg !985
  call void asm sideeffect "nop", ""(), !dbg !985
  call void asm sideeffect "nop", ""(), !dbg !985
  %12 = load volatile i16, i16* %11, align 2, !dbg !985
  store i16 %12, i16* %3, align 2, !dbg !977
  %13 = load i16, i16* %3, align 2, !dbg !986
  %14 = and i16 %13, -497, !dbg !987
  store i16 %14, i16* %3, align 2, !dbg !988
  %15 = load i16, i16* %3, align 2, !dbg !989
  %16 = load i16, i16* %5, align 2, !dbg !990
  %17 = add i16 %15, %16, !dbg !991
  %18 = shl i16 %17, 4, !dbg !992
  store i16 %18, i16* %3, align 2, !dbg !993
  %19 = load i16, i16* %4, align 2, !dbg !994
  %20 = load i16, i16* %3, align 2, !dbg !995
  %21 = shl i16 %19, 1, !dbg !996
  %22 = inttoptr i16 %21 to i16*, !dbg !996
  store volatile i16 %20, i16* %22, align 2, !dbg !996
  call void asm sideeffect "nop", ""(), !dbg !996
  call void asm sideeffect "nop", ""(), !dbg !996
  call void asm sideeffect "nop", ""(), !dbg !996
  call void asm sideeffect "nop", ""(), !dbg !996
  ret void, !dbg !997
}

define internal i16* @.get_tensor_ptr(i16 %0) !dbg !998 {
  %2 = alloca i16, i16 1, align 2, !dbg !999
  store i16 %0, i16* %2, align 2, !dbg !999
  %3 = load i16, i16* %2, align 2, !dbg !999
  %4 = zext i16 %3 to i32, !dbg !999
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
  ], !dbg !999

5:                                                ; preds = %1
  br i1 false, label %6, label %7, !dbg !999

6:                                                ; preds = %5
  br label %8, !dbg !999

7:                                                ; preds = %5
  call void asm sideeffect "hcf", ""(), !dbg !999
  br label %8, !dbg !999

8:                                                ; preds = %6, %7
  br label %33, !dbg !999

9:                                                ; preds = %1
  %10 = load i16*, i16** @p_a, align 8, !dbg !999
  br label %33, !dbg !999

11:                                               ; preds = %1
  %12 = load i16*, i16** @p_b, align 8, !dbg !999
  br label %33, !dbg !999

13:                                               ; preds = %1
  %14 = load i16*, i16** @p_g, align 8, !dbg !999
  br label %33, !dbg !999

15:                                               ; preds = %1
  %16 = load i16*, i16** @p_c, align 8, !dbg !999
  br label %33, !dbg !999

17:                                               ; preds = %1
  %18 = load i16*, i16** @p_d, align 8, !dbg !999
  br label %33, !dbg !999

19:                                               ; preds = %1
  %20 = load half*, half** @p_af, align 8, !dbg !999
  %21 = bitcast half* %20 to i16*, !dbg !999
  br label %33, !dbg !999

22:                                               ; preds = %1
  %23 = load half*, half** @p_bf, align 8, !dbg !999
  %24 = bitcast half* %23 to i16*, !dbg !999
  br label %33, !dbg !999

25:                                               ; preds = %1
  %26 = load half*, half** @p_gf, align 8, !dbg !999
  %27 = bitcast half* %26 to i16*, !dbg !999
  br label %33, !dbg !999

28:                                               ; preds = %1
  %29 = load half*, half** @p_cf, align 8, !dbg !999
  %30 = bitcast half* %29 to i16*, !dbg !999
  br label %33, !dbg !999

31:                                               ; preds = %1
  %32 = load i16*, i16** @p_mark, align 8, !dbg !999
  br label %33, !dbg !999

33:                                               ; preds = %8, %9, %11, %13, %15, %17, %19, %22, %25, %28, %31
  %34 = phi i16 [ -2, %31 ], [ -2, %28 ], [ -2, %25 ], [ -2, %22 ], [ -2, %19 ], [ -2, %17 ], [ -2, %15 ], [ -2, %13 ], [ -2, %11 ], [ -2, %9 ], [ 0, %8 ]
  %35 = phi i16* [ %32, %31 ], [ %30, %28 ], [ %27, %25 ], [ %24, %22 ], [ %21, %19 ], [ %18, %17 ], [ %16, %15 ], [ %14, %13 ], [ %12, %11 ], [ %10, %9 ], [ undef, %8 ]
  br label %36, !dbg !999

36:                                               ; preds = %33
  %37 = icmp ne i16 %34, 0, !dbg !999
  br i1 %37, label %38, label %39, !dbg !999

38:                                               ; preds = %36
  br label %41, !dbg !999

39:                                               ; preds = %36
  %40 = load i16*, i16** @p_mark, align 8, !dbg !999
  br label %41, !dbg !999

41:                                               ; preds = %38, %39
  %42 = phi i16* [ %40, %39 ], [ %35, %38 ]
  br label %43, !dbg !999

43:                                               ; preds = %41
  ret i16* %42, !dbg !999
}

define internal void @__generic0sys_mod.sys_mod.tile_config.queue_flush.exit() !dbg !1001 {
  store volatile i16 1, i16* inttoptr (i16 -2268 to i16*), align 2, !dbg !1003
  call void asm sideeffect "nop", ""(), !dbg !1003
  call void asm sideeffect "nop", ""(), !dbg !1003
  ret void, !dbg !1005
}

define internal void @__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position(i16 %0) !dbg !1006 {
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
  call void asm sideeffect "nop", ""(), !dbg !1014
  call void asm sideeffect "nop", ""(), !dbg !1014
  %9 = load volatile i16, i16* %8, align 2, !dbg !1014
  store i16 %9, i16* %2, align 2, !dbg !1008
  %10 = load i16, i16* %2, align 2, !dbg !1015
  %11 = and i16 %10, -16, !dbg !1016
  store i16 %11, i16* %2, align 2, !dbg !1016
  %12 = load i16, i16* %3, align 2, !dbg !1017
  %13 = load i16, i16* %2, align 2, !dbg !1018
  %14 = shl i16 %12, 1, !dbg !1019
  %15 = inttoptr i16 %14 to i16*, !dbg !1019
  store volatile i16 %13, i16* %15, align 2, !dbg !1019
  call void asm sideeffect "nop", ""(), !dbg !1019
  call void asm sideeffect "nop", ""(), !dbg !1019
  call void asm sideeffect "nop", ""(), !dbg !1019
  call void asm sideeffect "nop", ""(), !dbg !1019
  ret void, !dbg !1020
}

define internal void @__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 %0) !dbg !1021 {
  %2 = alloca i16, i16 1, align 2, !dbg !1023
  %3 = alloca i16, i16 1, align 2, !dbg !1025
  %4 = alloca i16, i16 1, align 2, !dbg !1026
  store i16 %0, i16* %4, align 2, !dbg !1026
  %5 = load i16, i16* %4, align 2, !dbg !1027
  store i16 %5, i16* %3, align 2, !dbg !1025
  %6 = load i16, i16* %3, align 2, !dbg !1028
  %7 = shl i16 %6, 1, !dbg !1029
  %8 = inttoptr i16 %7 to i16*, !dbg !1029
  call void asm sideeffect "nop", ""(), !dbg !1029
  call void asm sideeffect "nop", ""(), !dbg !1029
  %9 = load volatile i16, i16* %8, align 2, !dbg !1029
  store i16 %9, i16* %2, align 2, !dbg !1023
  %10 = load i16, i16* %2, align 2, !dbg !1030
  %11 = and i16 %10, -256, !dbg !1031
  store i16 %11, i16* %2, align 2, !dbg !1032
  %12 = load i16, i16* %2, align 2, !dbg !1033
  %13 = load i16, i16* %2, align 2, !dbg !1034
  %14 = call i16 @__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %13), !dbg !1035
  %15 = or i16 %12, %14, !dbg !1036
  store i16 %15, i16* %2, align 2, !dbg !1036
  %16 = load i16, i16* %2, align 2, !dbg !1037
  %17 = load i16, i16* %2, align 2, !dbg !1038
  %18 = call i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %17), !dbg !1039
  %19 = or i16 %16, %18, !dbg !1040
  store i16 %19, i16* %2, align 2, !dbg !1040
  %20 = load i16, i16* %3, align 2, !dbg !1041
  %21 = load i16, i16* %2, align 2, !dbg !1042
  %22 = shl i16 %20, 1, !dbg !1043
  %23 = inttoptr i16 %22 to i16*, !dbg !1043
  store volatile i16 %21, i16* %23, align 2, !dbg !1043
  call void asm sideeffect "nop", ""(), !dbg !1043
  call void asm sideeffect "nop", ""(), !dbg !1043
  ret void, !dbg !1044
}

define internal void @__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 %0) !dbg !1045 {
  %2 = alloca i16, i16 1, align 2, !dbg !1046
  %3 = alloca i16, i16 1, align 2, !dbg !1048
  %4 = alloca i16, i16 1, align 2, !dbg !1049
  store i16 %0, i16* %4, align 2, !dbg !1049
  %5 = load i16, i16* %4, align 2, !dbg !1050
  store i16 %5, i16* %3, align 2, !dbg !1048
  %6 = load i16, i16* %3, align 2, !dbg !1051
  %7 = shl i16 %6, 1, !dbg !1052
  %8 = inttoptr i16 %7 to i16*, !dbg !1052
  call void asm sideeffect "nop", ""(), !dbg !1052
  call void asm sideeffect "nop", ""(), !dbg !1052
  %9 = load volatile i16, i16* %8, align 2, !dbg !1052
  store i16 %9, i16* %2, align 2, !dbg !1046
  %10 = load i16, i16* %2, align 2, !dbg !1053
  %11 = and i16 %10, -256, !dbg !1054
  store i16 %11, i16* %2, align 2, !dbg !1055
  %12 = load i16, i16* %2, align 2, !dbg !1056
  %13 = load i16, i16* %2, align 2, !dbg !1057
  %14 = call i16 @__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %13), !dbg !1058
  %15 = or i16 %12, %14, !dbg !1059
  store i16 %15, i16* %2, align 2, !dbg !1059
  %16 = load i16, i16* %2, align 2, !dbg !1060
  %17 = load i16, i16* %2, align 2, !dbg !1061
  %18 = call i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %17), !dbg !1062
  %19 = or i16 %16, %18, !dbg !1063
  store i16 %19, i16* %2, align 2, !dbg !1063
  %20 = load i16, i16* %3, align 2, !dbg !1064
  %21 = load i16, i16* %2, align 2, !dbg !1065
  %22 = shl i16 %20, 1, !dbg !1066
  %23 = inttoptr i16 %22 to i16*, !dbg !1066
  store volatile i16 %21, i16* %23, align 2, !dbg !1066
  call void asm sideeffect "nop", ""(), !dbg !1066
  call void asm sideeffect "nop", ""(), !dbg !1066
  ret void, !dbg !1067
}

define internal i16 @__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %0) !dbg !1068 {
  %2 = alloca i16, i16 1, align 2, !dbg !1069
  %3 = alloca i16, i16 1, align 2, !dbg !1071
  store i16 %0, i16* %3, align 2, !dbg !1071
  %4 = load i16, i16* %3, align 2, !dbg !1072
  store i16 %4, i16* %2, align 2, !dbg !1069
  %5 = load i16, i16* %2, align 2, !dbg !1073
  store i16 %5, i16* %2, align 2, !dbg !1074
  %6 = load i16, i16* %2, align 2, !dbg !1075
  ret i16 %6, !dbg !1076
}

define internal i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %0) !dbg !1077 {
  %2 = alloca i16, i16 1, align 2, !dbg !1078
  %3 = alloca i16, i16 1, align 2, !dbg !1080
  store i16 %0, i16* %3, align 2, !dbg !1080
  %4 = load i16, i16* %3, align 2, !dbg !1081
  store i16 %4, i16* %2, align 2, !dbg !1078
  %5 = load i16, i16* %2, align 2, !dbg !1082
  %6 = or i16 %5, 2, !dbg !1083
  store i16 %6, i16* %2, align 2, !dbg !1083
  %7 = load i16, i16* %2, align 2, !dbg !1084
  ret i16 %7, !dbg !1085
}

define internal i16 @__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %0) !dbg !1086 {
  %2 = alloca i16, i16 1, align 2, !dbg !1087
  %3 = alloca i16, i16 1, align 2, !dbg !1089
  store i16 %0, i16* %3, align 2, !dbg !1089
  %4 = load i16, i16* %3, align 2, !dbg !1090
  store i16 %4, i16* %2, align 2, !dbg !1087
  %5 = load i16, i16* %2, align 2, !dbg !1091
  %6 = or i16 %5, 128, !dbg !1092
  store i16 %6, i16* %2, align 2, !dbg !1092
  %7 = load i16, i16* %2, align 2, !dbg !1093
  ret i16 %7, !dbg !1094
}

define internal void @__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction(i16 %0) !dbg !1095 {
  %2 = alloca i16, i16 1, align 2, !dbg !1096
  %3 = alloca i16, i16 1, align 2, !dbg !1098
  %4 = alloca i16, i16 1, align 2, !dbg !1099
  store i16 %0, i16* %4, align 2, !dbg !1099
  %5 = load i16, i16* %4, align 2, !dbg !1100
  store i16 %5, i16* %3, align 2, !dbg !1098
  %6 = load i16, i16* %3, align 2, !dbg !1101
  %7 = shl i16 %6, 1, !dbg !1102
  %8 = inttoptr i16 %7 to i16*, !dbg !1102
  call void asm sideeffect "nop", ""(), !dbg !1102
  call void asm sideeffect "nop", ""(), !dbg !1102
  %9 = load volatile i16, i16* %8, align 2, !dbg !1102
  store i16 %9, i16* %2, align 2, !dbg !1096
  %10 = load i16, i16* %2, align 2, !dbg !1103
  %11 = and i16 %10, -17, !dbg !1104
  store i16 %11, i16* %2, align 2, !dbg !1104
  %12 = load i16, i16* %3, align 2, !dbg !1105
  %13 = load i16, i16* %2, align 2, !dbg !1106
  %14 = shl i16 %12, 1, !dbg !1107
  %15 = inttoptr i16 %14 to i16*, !dbg !1107
  store volatile i16 %13, i16* %15, align 2, !dbg !1107
  call void asm sideeffect "nop", ""(), !dbg !1107
  call void asm sideeffect "nop", ""(), !dbg !1107
  ret void, !dbg !1108
}

define internal void @__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction(i16 %0) !dbg !1109 {
  %2 = alloca i16, i16 1, align 2, !dbg !1110
  %3 = alloca i16, i16 1, align 2, !dbg !1112
  %4 = alloca i16, i16 1, align 2, !dbg !1113
  store i16 %0, i16* %4, align 2, !dbg !1113
  %5 = load i16, i16* %4, align 2, !dbg !1114
  store i16 %5, i16* %3, align 2, !dbg !1112
  %6 = load i16, i16* %3, align 2, !dbg !1115
  %7 = shl i16 %6, 1, !dbg !1116
  %8 = inttoptr i16 %7 to i16*, !dbg !1116
  call void asm sideeffect "nop", ""(), !dbg !1116
  call void asm sideeffect "nop", ""(), !dbg !1116
  %9 = load volatile i16, i16* %8, align 2, !dbg !1116
  store i16 %9, i16* %2, align 2, !dbg !1110
  %10 = load i16, i16* %2, align 2, !dbg !1117
  %11 = or i16 %10, 16, !dbg !1118
  store i16 %11, i16* %2, align 2, !dbg !1118
  %12 = load i16, i16* %3, align 2, !dbg !1119
  %13 = load i16, i16* %2, align 2, !dbg !1120
  %14 = shl i16 %12, 1, !dbg !1121
  %15 = inttoptr i16 %14 to i16*, !dbg !1121
  store volatile i16 %13, i16* %15, align 2, !dbg !1121
  call void asm sideeffect "nop", ""(), !dbg !1121
  call void asm sideeffect "nop", ""(), !dbg !1121
  ret void, !dbg !1122
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
!3 = distinct !DISubprogram(name: "compute", linkageName: "compute", scope: null, file: !4, line: 16, type: !5, scopeLine: 16, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!4 = !DIFile(filename: "./pe.csl", directory: "/home/USER/xkernel/studies/wse3-characterization/microbench/pcsweep/cases/i16dep")
!5 = !DISubroutineType(types: !6)
!6 = !{}
!7 = !DILocation(line: 17, column: 11, scope: !8)
!8 = !DILexicalBlockFile(scope: !3, file: !4, discriminator: 0)
!9 = !DILocation(line: 18, column: 12, scope: !8)
!10 = !DILocation(line: 18, column: 19, scope: !8)
!11 = !DILocation(line: 18, column: 16, scope: !8)
!12 = !DILocation(line: 18, column: 27, scope: !8)
!13 = !DILocation(line: 18, column: 24, scope: !8)
!14 = !DILocation(line: 18, column: 8, scope: !8)
!15 = !DILocation(line: 19, column: 11, scope: !8)
!16 = !DILocation(line: 20, column: 12, scope: !8)
!17 = !DILocation(line: 20, column: 19, scope: !8)
!18 = !DILocation(line: 20, column: 16, scope: !8)
!19 = !DILocation(line: 20, column: 27, scope: !8)
!20 = !DILocation(line: 20, column: 24, scope: !8)
!21 = !DILocation(line: 20, column: 8, scope: !8)
!22 = !DILocation(line: 21, column: 11, scope: !8)
!23 = !DILocation(line: 22, column: 12, scope: !8)
!24 = !DILocation(line: 22, column: 19, scope: !8)
!25 = !DILocation(line: 22, column: 16, scope: !8)
!26 = !DILocation(line: 22, column: 27, scope: !8)
!27 = !DILocation(line: 22, column: 24, scope: !8)
!28 = !DILocation(line: 22, column: 8, scope: !8)
!29 = !DILocation(line: 23, column: 11, scope: !8)
!30 = !DILocation(line: 24, column: 12, scope: !8)
!31 = !DILocation(line: 24, column: 19, scope: !8)
!32 = !DILocation(line: 24, column: 16, scope: !8)
!33 = !DILocation(line: 24, column: 27, scope: !8)
!34 = !DILocation(line: 24, column: 24, scope: !8)
!35 = !DILocation(line: 24, column: 8, scope: !8)
!36 = !DILocation(line: 25, column: 11, scope: !8)
!37 = !DILocation(line: 26, column: 12, scope: !8)
!38 = !DILocation(line: 26, column: 19, scope: !8)
!39 = !DILocation(line: 26, column: 16, scope: !8)
!40 = !DILocation(line: 26, column: 27, scope: !8)
!41 = !DILocation(line: 26, column: 24, scope: !8)
!42 = !DILocation(line: 26, column: 8, scope: !8)
!43 = !DILocation(line: 27, column: 11, scope: !8)
!44 = !DILocation(line: 28, column: 12, scope: !8)
!45 = !DILocation(line: 28, column: 19, scope: !8)
!46 = !DILocation(line: 28, column: 16, scope: !8)
!47 = !DILocation(line: 28, column: 27, scope: !8)
!48 = !DILocation(line: 28, column: 24, scope: !8)
!49 = !DILocation(line: 28, column: 8, scope: !8)
!50 = !DILocation(line: 29, column: 11, scope: !8)
!51 = !DILocation(line: 30, column: 12, scope: !8)
!52 = !DILocation(line: 30, column: 19, scope: !8)
!53 = !DILocation(line: 30, column: 16, scope: !8)
!54 = !DILocation(line: 30, column: 27, scope: !8)
!55 = !DILocation(line: 30, column: 24, scope: !8)
!56 = !DILocation(line: 30, column: 8, scope: !8)
!57 = !DILocation(line: 31, column: 11, scope: !8)
!58 = !DILocation(line: 32, column: 12, scope: !8)
!59 = !DILocation(line: 32, column: 19, scope: !8)
!60 = !DILocation(line: 32, column: 16, scope: !8)
!61 = !DILocation(line: 32, column: 27, scope: !8)
!62 = !DILocation(line: 32, column: 24, scope: !8)
!63 = !DILocation(line: 32, column: 8, scope: !8)
!64 = !DILocation(line: 34, column: 11, scope: !8)
!65 = !DILocation(line: 35, column: 3, scope: !8)
!66 = !DILocation(line: 16, column: 1, scope: !8)
!67 = distinct !DISubprogram(name: "f_exit", linkageName: "f_exit", scope: null, file: !4, line: 38, type: !5, scopeLine: 38, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!68 = !DILocation(line: 38, column: 22, scope: !69)
!69 = !DILexicalBlockFile(scope: !67, file: !4, discriminator: 0)
!70 = !DILocation(line: 38, column: 1, scope: !69)
!71 = distinct !DISubprogram(name: "sys_mod.sys_nop", linkageName: "sys_mod.sys_nop", scope: null, file: !72, line: 90, type: !5, scopeLine: 90, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!72 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/memcpy.csl", directory: "")
!73 = !DILocation(line: 90, column: 1, scope: !74)
!74 = !DILexicalBlockFile(scope: !71, file: !72, discriminator: 0)
!75 = distinct !DISubprogram(name: "sys_mod.unblock_cmd_stream", linkageName: "sys_mod.unblock_cmd_stream", scope: null, file: !72, line: 102, type: !5, scopeLine: 102, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!76 = !DILocation(line: 103, column: 3, scope: !77)
!77 = !DILexicalBlockFile(scope: !75, file: !72, discriminator: 0)
!78 = !DILocation(line: 102, column: 1, scope: !77)
!79 = distinct !DISubprogram(name: "sys_mod.sys_mod.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.unblock_cmd_stream", scope: null, file: !80, line: 307, type: !5, scopeLine: 307, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!80 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpy.csl", directory: "")
!81 = !DILocation(line: 308, column: 5, scope: !82)
!82 = !DILexicalBlockFile(scope: !79, file: !80, discriminator: 0)
!83 = !DILocation(line: 307, column: 1, scope: !82)
!84 = distinct !DISubprogram(name: "sys_mod.sys_mod.teardown_h2d", linkageName: "sys_mod.sys_mod.teardown_h2d", scope: null, file: !80, line: 323, type: !5, scopeLine: 323, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!85 = !DILocation(line: 326, column: 5, scope: !86)
!86 = !DILexicalBlockFile(scope: !84, file: !80, discriminator: 0)
!87 = !DILocation(line: 323, column: 1, scope: !86)
!88 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_ublk_c22", linkageName: "sys_mod.sys_mod.f_ublk_c22", scope: null, file: !80, line: 335, type: !5, scopeLine: 335, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!89 = !DILocation(line: 336, column: 5, scope: !90)
!90 = !DILexicalBlockFile(scope: !88, file: !80, discriminator: 0)
!91 = !DILocation(line: 335, column: 1, scope: !90)
!92 = distinct !DISubprogram(name: "sys_mod.sys_mod.teardown_d2h", linkageName: "sys_mod.sys_mod.teardown_d2h", scope: null, file: !80, line: 344, type: !5, scopeLine: 344, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!93 = !DILocation(line: 355, column: 5, scope: !94)
!94 = !DILexicalBlockFile(scope: !92, file: !80, discriminator: 0)
!95 = !DILocation(line: 359, column: 5, scope: !94)
!96 = !DILocation(line: 344, column: 1, scope: !94)
!97 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_memcpyh2d", linkageName: "sys_mod.sys_mod.f_memcpyh2d", scope: null, file: !80, line: 460, type: !5, scopeLine: 460, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!98 = !DILocation(line: 477, column: 5, scope: !99)
!99 = !DILexicalBlockFile(scope: !97, file: !80, discriminator: 0)
!100 = !DILocation(line: 476, column: 5, scope: !99)
!101 = !DILocation(line: 475, column: 5, scope: !99)
!102 = !DILocation(line: 474, column: 5, scope: !99)
!103 = !DILocation(line: 473, column: 5, scope: !99)
!104 = !DILocation(line: 472, column: 5, scope: !99)
!105 = !DILocation(line: 471, column: 5, scope: !99)
!106 = !DILocation(line: 470, column: 5, scope: !99)
!107 = !DILocation(line: 469, column: 5, scope: !99)
!108 = !DILocation(line: 468, column: 5, scope: !99)
!109 = !DILocation(line: 467, column: 5, scope: !99)
!110 = !DILocation(line: 466, column: 5, scope: !99)
!111 = !DILocation(line: 465, column: 5, scope: !99)
!112 = !DILocation(line: 463, column: 5, scope: !99)
!113 = !DILocation(line: 462, column: 20, scope: !99)
!114 = !DILocation(line: 462, column: 32, scope: !99)
!115 = !DILocation(line: 462, column: 5, scope: !99)
!116 = !DILocation(line: 465, column: 33, scope: !99)
!117 = !DILocation(line: 465, column: 38, scope: !99)
!118 = !DILocation(line: 466, column: 34, scope: !99)
!119 = !DILocation(line: 466, column: 39, scope: !99)
!120 = !DILocation(line: 467, column: 34, scope: !99)
!121 = !DILocation(line: 467, column: 39, scope: !99)
!122 = !DILocation(line: 468, column: 33, scope: !99)
!123 = !DILocation(line: 468, column: 38, scope: !99)
!124 = !DILocation(line: 469, column: 33, scope: !99)
!125 = !DILocation(line: 469, column: 38, scope: !99)
!126 = !DILocation(line: 470, column: 35, scope: !99)
!127 = !DILocation(line: 470, column: 21, scope: !99)
!128 = !DILocation(line: 471, column: 41, scope: !99)
!129 = !DILocation(line: 471, column: 27, scope: !99)
!130 = !DILocation(line: 472, column: 39, scope: !99)
!131 = !DILocation(line: 472, column: 25, scope: !99)
!132 = !DILocation(line: 473, column: 44, scope: !99)
!133 = !DILocation(line: 473, column: 49, scope: !99)
!134 = !DILocation(line: 474, column: 41, scope: !99)
!135 = !DILocation(line: 474, column: 46, scope: !99)
!136 = !DILocation(line: 475, column: 41, scope: !99)
!137 = !DILocation(line: 475, column: 46, scope: !99)
!138 = !DILocation(line: 476, column: 59, scope: !99)
!139 = !DILocation(line: 476, column: 64, scope: !99)
!140 = !DILocation(line: 476, column: 50, scope: !99)
!141 = !DILocation(line: 476, column: 129, scope: !99)
!142 = !DILocation(line: 476, column: 134, scope: !99)
!143 = !DILocation(line: 476, column: 120, scope: !99)
!144 = !DILocation(line: 476, column: 118, scope: !99)
!145 = !DILocation(line: 476, column: 112, scope: !99)
!146 = !DILocation(line: 476, column: 36, scope: !99)
!147 = !DILocation(line: 477, column: 59, scope: !99)
!148 = !DILocation(line: 477, column: 64, scope: !99)
!149 = !DILocation(line: 477, column: 50, scope: !99)
!150 = !DILocation(line: 477, column: 129, scope: !99)
!151 = !DILocation(line: 477, column: 134, scope: !99)
!152 = !DILocation(line: 477, column: 120, scope: !99)
!153 = !DILocation(line: 477, column: 118, scope: !99)
!154 = !DILocation(line: 477, column: 112, scope: !99)
!155 = !DILocation(line: 477, column: 36, scope: !99)
!156 = !DILocation(line: 479, column: 24, scope: !99)
!157 = !DILocation(line: 481, column: 21, scope: !99)
!158 = !DILocation(line: 481, column: 19, scope: !99)
!159 = !DILocation(line: 482, column: 21, scope: !99)
!160 = !DILocation(line: 482, column: 19, scope: !99)
!161 = !DILocation(line: 483, column: 21, scope: !99)
!162 = !DILocation(line: 483, column: 19, scope: !99)
!163 = !DILocation(line: 484, column: 20, scope: !99)
!164 = !DILocation(line: 484, column: 18, scope: !99)
!165 = !DILocation(line: 485, column: 20, scope: !99)
!166 = !DILocation(line: 485, column: 18, scope: !99)
!167 = !DILocation(line: 486, column: 22, scope: !99)
!168 = !DILocation(line: 486, column: 20, scope: !99)
!169 = !DILocation(line: 487, column: 27, scope: !99)
!170 = !DILocation(line: 487, column: 25, scope: !99)
!171 = !DILocation(line: 488, column: 25, scope: !99)
!172 = !DILocation(line: 488, column: 23, scope: !99)
!173 = !DILocation(line: 489, column: 31, scope: !99)
!174 = !DILocation(line: 489, column: 29, scope: !99)
!175 = !DILocation(line: 490, column: 28, scope: !99)
!176 = !DILocation(line: 490, column: 26, scope: !99)
!177 = !DILocation(line: 491, column: 28, scope: !99)
!178 = !DILocation(line: 491, column: 26, scope: !99)
!179 = !DILocation(line: 492, column: 37, scope: !99)
!180 = !DILocation(line: 492, column: 35, scope: !99)
!181 = !DILocation(line: 493, column: 37, scope: !99)
!182 = !DILocation(line: 493, column: 35, scope: !99)
!183 = !DILocation(line: 495, column: 5, scope: !99)
!184 = !DILocation(line: 501, column: 5, scope: !99)
!185 = !DILocation(line: 506, column: 5, scope: !99)
!186 = !DILocation(line: 521, column: 5, scope: !99)
!187 = !DILocation(line: 522, column: 16, scope: !99)
!188 = !DILocation(line: 531, column: 5, scope: !99)
!189 = !DILocation(line: 460, column: 1, scope: !99)
!190 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_memcpyd2h", linkageName: "sys_mod.sys_mod.f_memcpyd2h", scope: null, file: !80, line: 556, type: !5, scopeLine: 556, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!191 = !DILocation(line: 568, column: 5, scope: !192)
!192 = !DILexicalBlockFile(scope: !190, file: !80, discriminator: 0)
!193 = !DILocation(line: 567, column: 5, scope: !192)
!194 = !DILocation(line: 566, column: 5, scope: !192)
!195 = !DILocation(line: 565, column: 5, scope: !192)
!196 = !DILocation(line: 564, column: 5, scope: !192)
!197 = !DILocation(line: 563, column: 5, scope: !192)
!198 = !DILocation(line: 562, column: 5, scope: !192)
!199 = !DILocation(line: 561, column: 5, scope: !192)
!200 = !DILocation(line: 559, column: 5, scope: !192)
!201 = !DILocation(line: 558, column: 20, scope: !192)
!202 = !DILocation(line: 558, column: 32, scope: !192)
!203 = !DILocation(line: 558, column: 5, scope: !192)
!204 = !DILocation(line: 561, column: 33, scope: !192)
!205 = !DILocation(line: 561, column: 38, scope: !192)
!206 = !DILocation(line: 562, column: 34, scope: !192)
!207 = !DILocation(line: 562, column: 39, scope: !192)
!208 = !DILocation(line: 563, column: 34, scope: !192)
!209 = !DILocation(line: 563, column: 39, scope: !192)
!210 = !DILocation(line: 564, column: 33, scope: !192)
!211 = !DILocation(line: 564, column: 38, scope: !192)
!212 = !DILocation(line: 565, column: 33, scope: !192)
!213 = !DILocation(line: 565, column: 38, scope: !192)
!214 = !DILocation(line: 566, column: 35, scope: !192)
!215 = !DILocation(line: 566, column: 21, scope: !192)
!216 = !DILocation(line: 567, column: 41, scope: !192)
!217 = !DILocation(line: 567, column: 27, scope: !192)
!218 = !DILocation(line: 568, column: 39, scope: !192)
!219 = !DILocation(line: 568, column: 25, scope: !192)
!220 = !DILocation(line: 570, column: 24, scope: !192)
!221 = !DILocation(line: 573, column: 21, scope: !192)
!222 = !DILocation(line: 573, column: 19, scope: !192)
!223 = !DILocation(line: 574, column: 21, scope: !192)
!224 = !DILocation(line: 574, column: 19, scope: !192)
!225 = !DILocation(line: 575, column: 21, scope: !192)
!226 = !DILocation(line: 575, column: 19, scope: !192)
!227 = !DILocation(line: 576, column: 20, scope: !192)
!228 = !DILocation(line: 576, column: 18, scope: !192)
!229 = !DILocation(line: 577, column: 20, scope: !192)
!230 = !DILocation(line: 577, column: 18, scope: !192)
!231 = !DILocation(line: 578, column: 22, scope: !192)
!232 = !DILocation(line: 578, column: 20, scope: !192)
!233 = !DILocation(line: 579, column: 27, scope: !192)
!234 = !DILocation(line: 579, column: 25, scope: !192)
!235 = !DILocation(line: 580, column: 25, scope: !192)
!236 = !DILocation(line: 580, column: 23, scope: !192)
!237 = !DILocation(line: 582, column: 5, scope: !192)
!238 = !DILocation(line: 588, column: 59, scope: !192)
!239 = !DILocation(line: 588, column: 5, scope: !192)
!240 = !DILocation(line: 608, column: 5, scope: !192)
!241 = !DILocation(line: 609, column: 16, scope: !192)
!242 = !DILocation(line: 556, column: 1, scope: !192)
!243 = distinct !DISubprogram(name: "sys_mod.sys_mod.oq0_teardow_handler", linkageName: "sys_mod.sys_mod.oq0_teardow_handler", scope: null, file: !80, line: 631, type: !5, scopeLine: 631, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!244 = !DILocation(line: 632, column: 9, scope: !245)
!245 = !DILexicalBlockFile(scope: !243, file: !80, discriminator: 0)
!246 = !DILocation(line: 632, column: 5, scope: !245)
!247 = !DILocation(line: 634, column: 66, scope: !245)
!248 = !DILocation(line: 634, column: 9, scope: !245)
!249 = !DILocation(line: 636, column: 13, scope: !245)
!250 = !DILocation(line: 637, column: 13, scope: !245)
!251 = !DILocation(line: 638, column: 13, scope: !245)
!252 = !DILocation(line: 639, column: 13, scope: !245)
!253 = !DILocation(line: 640, column: 13, scope: !245)
!254 = !DILocation(line: 641, column: 13, scope: !245)
!255 = !DILocation(line: 642, column: 13, scope: !245)
!256 = !DILocation(line: 643, column: 13, scope: !245)
!257 = !DILocation(line: 644, column: 13, scope: !245)
!258 = !DILocation(line: 645, column: 13, scope: !245)
!259 = !DILocation(line: 646, column: 13, scope: !245)
!260 = !DILocation(line: 647, column: 13, scope: !245)
!261 = !DILocation(line: 648, column: 13, scope: !245)
!262 = !DILocation(line: 635, column: 9, scope: !245)
!263 = !DILocation(line: 652, column: 9, scope: !245)
!264 = !DILocation(line: 654, column: 13, scope: !245)
!265 = !DILocation(line: 655, column: 13, scope: !245)
!266 = !DILocation(line: 656, column: 13, scope: !245)
!267 = !DILocation(line: 657, column: 13, scope: !245)
!268 = !DILocation(line: 658, column: 13, scope: !245)
!269 = !DILocation(line: 659, column: 13, scope: !245)
!270 = !DILocation(line: 660, column: 13, scope: !245)
!271 = !DILocation(line: 661, column: 13, scope: !245)
!272 = !DILocation(line: 653, column: 9, scope: !245)
!273 = !DILocation(line: 664, column: 5, scope: !245)
!274 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_rpc", linkageName: "sys_mod.sys_mod.f_rpc", scope: null, file: !80, line: 694, type: !5, scopeLine: 694, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!275 = !DILocation(line: 694, column: 13, scope: !276)
!276 = !DILexicalBlockFile(scope: !274, file: !80, discriminator: 0)
!277 = !DILocation(line: 700, column: 5, scope: !276)
!278 = !DILocation(line: 706, column: 20, scope: !276)
!279 = !DILocation(line: 706, column: 32, scope: !276)
!280 = !DILocation(line: 706, column: 5, scope: !276)
!281 = !DILocation(line: 710, column: 5, scope: !276)
!282 = !DILocation(line: 712, column: 24, scope: !276)
!283 = !DILocation(line: 694, column: 1, scope: !276)
!284 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.stack_push", linkageName: "sys_mod.sys_mod.sys_mod.stack_push", scope: null, file: !285, line: 54, type: !5, scopeLine: 54, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!285 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/sys.csl", directory: "")
!286 = !DILocation(line: 60, column: 5, scope: !287)
!287 = !DILexicalBlockFile(scope: !284, file: !285, discriminator: 0)
!288 = !DILocation(line: 54, column: 16, scope: !287)
!289 = !DILocation(line: 59, column: 13, scope: !287)
!290 = !DILocation(line: 59, column: 24, scope: !287)
!291 = !DILocation(line: 59, column: 5, scope: !287)
!292 = !DILocation(line: 61, column: 25, scope: !287)
!293 = !DILocation(line: 61, column: 5, scope: !287)
!294 = !DILocation(line: 61, column: 11, scope: !287)
!295 = !DILocation(line: 61, column: 10, scope: !287)
!296 = !DILocation(line: 61, column: 23, scope: !287)
!297 = !DILocation(line: 62, column: 18, scope: !287)
!298 = !DILocation(line: 62, column: 29, scope: !287)
!299 = !DILocation(line: 62, column: 16, scope: !287)
!300 = !DILocation(line: 54, column: 1, scope: !287)
!301 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_push", linkageName: "sys_mod.sys_mod.sys_mod.f_push", scope: null, file: !285, line: 72, type: !5, scopeLine: 72, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!302 = !DILocation(line: 72, column: 25, scope: !303)
!303 = !DILexicalBlockFile(scope: !301, file: !285, discriminator: 0)
!304 = !DILocation(line: 72, column: 13, scope: !303)
!305 = !DILocation(line: 73, column: 16, scope: !303)
!306 = !DILocation(line: 73, column: 5, scope: !303)
!307 = !DILocation(line: 72, column: 1, scope: !303)
!308 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.block_cmd_stream", linkageName: "sys_mod.sys_mod.sys_mod.block_cmd_stream", scope: null, file: !285, line: 76, type: !5, scopeLine: 76, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!309 = !DILocation(line: 77, column: 5, scope: !310)
!310 = !DILexicalBlockFile(scope: !308, file: !285, discriminator: 0)
!311 = !DILocation(line: 76, column: 1, scope: !310)
!312 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.sys_mod.unblock_cmd_stream", scope: null, file: !285, line: 80, type: !5, scopeLine: 80, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!313 = !DILocation(line: 81, column: 5, scope: !314)
!314 = !DILexicalBlockFile(scope: !312, file: !285, discriminator: 0)
!315 = !DILocation(line: 80, column: 1, scope: !314)
!316 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_sys_exit", linkageName: "sys_mod.sys_mod.sys_mod.f_sys_exit", scope: null, file: !285, line: 85, type: !5, scopeLine: 85, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!317 = !DILocation(line: 86, column: 5, scope: !318)
!318 = !DILexicalBlockFile(scope: !316, file: !285, discriminator: 0)
!319 = !DILocation(line: 87, column: 5, scope: !318)
!320 = !DILocation(line: 85, column: 1, scope: !318)
!321 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore", linkageName: "sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore", scope: null, file: !285, line: 90, type: !5, scopeLine: 90, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!322 = !DILocation(line: 90, column: 30, scope: !323)
!323 = !DILexicalBlockFile(scope: !321, file: !285, discriminator: 0)
!324 = !DILocation(line: 90, column: 1, scope: !323)
!325 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord", scope: null, file: !326, line: 131, type: !5, scopeLine: 131, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!326 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpyh2d.csl", directory: "")
!327 = !DILocation(line: 132, column: 12, scope: !328)
!328 = !DILexicalBlockFile(scope: !325, file: !326, discriminator: 0)
!329 = !DILocation(line: 132, column: 5, scope: !328)
!330 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord", scope: null, file: !326, line: 134, type: !5, scopeLine: 134, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!331 = !DILocation(line: 135, column: 12, scope: !332)
!332 = !DILexicalBlockFile(scope: !330, file: !326, discriminator: 0)
!333 = !DILocation(line: 135, column: 5, scope: !332)
!334 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval", scope: null, file: !326, line: 148, type: !5, scopeLine: 148, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!335 = !DILocation(line: 148, column: 23, scope: !336)
!336 = !DILexicalBlockFile(scope: !334, file: !326, discriminator: 0)
!337 = !DILocation(line: 149, column: 9, scope: !336)
!338 = !DILocation(line: 149, column: 20, scope: !336)
!339 = !DILocation(line: 149, column: 5, scope: !336)
!340 = !DILocation(line: 152, column: 23, scope: !336)
!341 = !DILocation(line: 152, column: 20, scope: !336)
!342 = !DILocation(line: 152, column: 9, scope: !336)
!343 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start", scope: null, file: !326, line: 226, type: !5, scopeLine: 226, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!344 = !DILocation(line: 233, column: 5, scope: !345)
!345 = !DILexicalBlockFile(scope: !343, file: !326, discriminator: 0)
!346 = !DILocation(line: 226, column: 49, scope: !345)
!347 = !DILocation(line: 226, column: 32, scope: !345)
!348 = !DILocation(line: 226, column: 21, scope: !345)
!349 = !DILocation(line: 229, column: 37, scope: !345)
!350 = !DILocation(line: 229, column: 52, scope: !345)
!351 = !DILocation(line: 229, column: 19, scope: !345)
!352 = !DILocation(line: 233, column: 71, scope: !345)
!353 = !DILocation(line: 233, column: 55, scope: !345)
!354 = !DILocation(line: 233, column: 25, scope: !345)
!355 = !DILocation(line: 235, column: 37, scope: !345)
!356 = !DILocation(line: 235, column: 52, scope: !345)
!357 = !DILocation(line: 235, column: 19, scope: !345)
!358 = !DILocation(line: 236, column: 28, scope: !345)
!359 = !DILocation(line: 236, column: 5, scope: !345)
!360 = !DILocation(line: 237, column: 28, scope: !345)
!361 = !DILocation(line: 237, column: 5, scope: !345)
!362 = !DILocation(line: 238, column: 13, scope: !345)
!363 = !DILocation(line: 238, column: 11, scope: !345)
!364 = !DILocation(line: 238, column: 5, scope: !345)
!365 = !DILocation(line: 239, column: 9, scope: !345)
!366 = !DILocation(line: 241, column: 9, scope: !345)
!367 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream", scope: null, file: !326, line: 249, type: !5, scopeLine: 249, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!368 = !DILocation(line: 250, column: 5, scope: !369)
!369 = !DILexicalBlockFile(scope: !367, file: !326, discriminator: 0)
!370 = !DILocation(line: 249, column: 1, scope: !369)
!371 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure", scope: null, file: !326, line: 276, type: !5, scopeLine: 276, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!372 = !DILocation(line: 414, column: 13, scope: !373)
!373 = !DILexicalBlockFile(scope: !371, file: !326, discriminator: 0)
!374 = !DILocation(line: 413, column: 13, scope: !373)
!375 = !DILocation(line: 400, column: 17, scope: !373)
!376 = !DILocation(line: 340, column: 9, scope: !373)
!377 = !DILocation(line: 339, column: 9, scope: !373)
!378 = !DILocation(line: 337, column: 5, scope: !373)
!379 = !DILocation(line: 319, column: 9, scope: !373)
!380 = !DILocation(line: 318, column: 9, scope: !373)
!381 = !DILocation(line: 315, column: 5, scope: !373)
!382 = !DILocation(line: 292, column: 5, scope: !373)
!383 = !DILocation(line: 291, column: 5, scope: !373)
!384 = !DILocation(line: 289, column: 5, scope: !373)
!385 = !DILocation(line: 288, column: 5, scope: !373)
!386 = !DILocation(line: 287, column: 5, scope: !373)
!387 = !DILocation(line: 286, column: 5, scope: !373)
!388 = !DILocation(line: 285, column: 5, scope: !373)
!389 = !DILocation(line: 284, column: 5, scope: !373)
!390 = !DILocation(line: 283, column: 5, scope: !373)
!391 = !DILocation(line: 282, column: 5, scope: !373)
!392 = !DILocation(line: 281, column: 5, scope: !373)
!393 = !DILocation(line: 280, column: 5, scope: !373)
!394 = !DILocation(line: 279, column: 5, scope: !373)
!395 = !DILocation(line: 278, column: 5, scope: !373)
!396 = !DILocation(line: 277, column: 5, scope: !373)
!397 = !DILocation(line: 291, column: 26, scope: !373)
!398 = !DILocation(line: 292, column: 26, scope: !373)
!399 = !DILocation(line: 315, column: 25, scope: !373)
!400 = !DILocation(line: 315, column: 31, scope: !373)
!401 = !DILocation(line: 315, column: 29, scope: !373)
!402 = !DILocation(line: 316, column: 20, scope: !373)
!403 = !DILocation(line: 316, column: 18, scope: !373)
!404 = !DILocation(line: 317, column: 52, scope: !373)
!405 = !DILocation(line: 317, column: 49, scope: !373)
!406 = !DILocation(line: 317, column: 5, scope: !373)
!407 = !DILocation(line: 318, column: 42, scope: !373)
!408 = !DILocation(line: 318, column: 33, scope: !373)
!409 = !DILocation(line: 318, column: 49, scope: !373)
!410 = !DILocation(line: 318, column: 48, scope: !373)
!411 = !DILocation(line: 318, column: 24, scope: !373)
!412 = !DILocation(line: 319, column: 24, scope: !373)
!413 = !DILocation(line: 319, column: 32, scope: !373)
!414 = !DILocation(line: 319, column: 36, scope: !373)
!415 = !DILocation(line: 319, column: 34, scope: !373)
!416 = !DILocation(line: 319, column: 30, scope: !373)
!417 = !DILocation(line: 320, column: 18, scope: !373)
!418 = !DILocation(line: 320, column: 15, scope: !373)
!419 = !DILocation(line: 320, column: 9, scope: !373)
!420 = !DILocation(line: 321, column: 26, scope: !373)
!421 = !DILocation(line: 325, column: 28, scope: !373)
!422 = !DILocation(line: 325, column: 26, scope: !373)
!423 = !DILocation(line: 331, column: 9, scope: !373)
!424 = !DILocation(line: 331, column: 15, scope: !373)
!425 = !DILocation(line: 331, column: 5, scope: !373)
!426 = !DILocation(line: 332, column: 22, scope: !373)
!427 = !DILocation(line: 334, column: 9, scope: !373)
!428 = !DILocation(line: 334, column: 18, scope: !373)
!429 = !DILocation(line: 334, column: 15, scope: !373)
!430 = !DILocation(line: 334, column: 5, scope: !373)
!431 = !DILocation(line: 335, column: 22, scope: !373)
!432 = !DILocation(line: 338, column: 52, scope: !373)
!433 = !DILocation(line: 338, column: 49, scope: !373)
!434 = !DILocation(line: 338, column: 5, scope: !373)
!435 = !DILocation(line: 339, column: 42, scope: !373)
!436 = !DILocation(line: 339, column: 48, scope: !373)
!437 = !DILocation(line: 339, column: 46, scope: !373)
!438 = !DILocation(line: 339, column: 33, scope: !373)
!439 = !DILocation(line: 339, column: 52, scope: !373)
!440 = !DILocation(line: 339, column: 51, scope: !373)
!441 = !DILocation(line: 339, column: 24, scope: !373)
!442 = !DILocation(line: 340, column: 25, scope: !373)
!443 = !DILocation(line: 340, column: 31, scope: !373)
!444 = !DILocation(line: 340, column: 29, scope: !373)
!445 = !DILocation(line: 340, column: 37, scope: !373)
!446 = !DILocation(line: 340, column: 41, scope: !373)
!447 = !DILocation(line: 340, column: 39, scope: !373)
!448 = !DILocation(line: 340, column: 35, scope: !373)
!449 = !DILocation(line: 341, column: 18, scope: !373)
!450 = !DILocation(line: 341, column: 15, scope: !373)
!451 = !DILocation(line: 341, column: 9, scope: !373)
!452 = !DILocation(line: 342, column: 26, scope: !373)
!453 = !DILocation(line: 347, column: 10, scope: !373)
!454 = !DILocation(line: 347, column: 16, scope: !373)
!455 = !DILocation(line: 347, column: 14, scope: !373)
!456 = !DILocation(line: 347, column: 5, scope: !373)
!457 = !DILocation(line: 348, column: 22, scope: !373)
!458 = !DILocation(line: 350, column: 10, scope: !373)
!459 = !DILocation(line: 350, column: 18, scope: !373)
!460 = !DILocation(line: 350, column: 21, scope: !373)
!461 = !DILocation(line: 350, column: 20, scope: !373)
!462 = !DILocation(line: 350, column: 14, scope: !373)
!463 = !DILocation(line: 350, column: 5, scope: !373)
!464 = !DILocation(line: 351, column: 22, scope: !373)
!465 = !DILocation(line: 354, column: 9, scope: !373)
!466 = !DILocation(line: 354, column: 5, scope: !373)
!467 = !DILocation(line: 358, column: 9, scope: !373)
!468 = !DILocation(line: 361, column: 9, scope: !373)
!469 = !DILocation(line: 364, column: 20, scope: !373)
!470 = !DILocation(line: 364, column: 17, scope: !373)
!471 = !DILocation(line: 364, column: 9, scope: !373)
!472 = !DILocation(line: 368, column: 13, scope: !373)
!473 = !DILocation(line: 371, column: 13, scope: !373)
!474 = !DILocation(line: 375, column: 13, scope: !373)
!475 = !DILocation(line: 394, column: 13, scope: !373)
!476 = !DILocation(line: 396, column: 29, scope: !373)
!477 = !DILocation(line: 396, column: 27, scope: !373)
!478 = !DILocation(line: 397, column: 60, scope: !373)
!479 = !DILocation(line: 397, column: 57, scope: !373)
!480 = !DILocation(line: 397, column: 13, scope: !373)
!481 = !DILocation(line: 400, column: 54, scope: !373)
!482 = !DILocation(line: 400, column: 55, scope: !373)
!483 = !DILocation(line: 400, column: 46, scope: !373)
!484 = !DILocation(line: 400, column: 59, scope: !373)
!485 = !DILocation(line: 400, column: 58, scope: !373)
!486 = !DILocation(line: 400, column: 37, scope: !373)
!487 = !DILocation(line: 400, column: 35, scope: !373)
!488 = !DILocation(line: 401, column: 33, scope: !373)
!489 = !DILocation(line: 401, column: 31, scope: !373)
!490 = !DILocation(line: 402, column: 69, scope: !373)
!491 = !DILocation(line: 402, column: 66, scope: !373)
!492 = !DILocation(line: 402, column: 19, scope: !373)
!493 = !DILocation(line: 404, column: 31, scope: !373)
!494 = !DILocation(line: 408, column: 75, scope: !373)
!495 = !DILocation(line: 408, column: 88, scope: !373)
!496 = !DILocation(line: 408, column: 13, scope: !373)
!497 = !DILocation(line: 413, column: 31, scope: !373)
!498 = !DILocation(line: 414, column: 33, scope: !373)
!499 = !DILocation(line: 415, column: 21, scope: !373)
!500 = !DILocation(line: 415, column: 29, scope: !373)
!501 = !DILocation(line: 415, column: 27, scope: !373)
!502 = !DILocation(line: 415, column: 19, scope: !373)
!503 = !DILocation(line: 416, column: 22, scope: !373)
!504 = !DILocation(line: 416, column: 19, scope: !373)
!505 = !DILocation(line: 416, column: 13, scope: !373)
!506 = !DILocation(line: 417, column: 23, scope: !373)
!507 = !DILocation(line: 419, column: 63, scope: !373)
!508 = !DILocation(line: 419, column: 60, scope: !373)
!509 = !DILocation(line: 419, column: 13, scope: !373)
!510 = !DILocation(line: 421, column: 23, scope: !373)
!511 = !DILocation(line: 423, column: 69, scope: !373)
!512 = !DILocation(line: 423, column: 13, scope: !373)
!513 = !DILocation(line: 426, column: 13, scope: !373)
!514 = !DILocation(line: 430, column: 13, scope: !373)
!515 = !DILocation(line: 433, column: 48, scope: !373)
!516 = !DILocation(line: 433, column: 22, scope: !373)
!517 = !DILocation(line: 433, column: 19, scope: !373)
!518 = !DILocation(line: 433, column: 13, scope: !373)
!519 = !DILocation(line: 436, column: 34, scope: !373)
!520 = !DILocation(line: 436, column: 39, scope: !373)
!521 = !DILocation(line: 436, column: 50, scope: !373)
!522 = !DILocation(line: 436, column: 17, scope: !373)
!523 = !DILocation(line: 452, column: 49, scope: !373)
!524 = !DILocation(line: 452, column: 64, scope: !373)
!525 = !DILocation(line: 452, column: 31, scope: !373)
!526 = !DILocation(line: 453, column: 40, scope: !373)
!527 = !DILocation(line: 453, column: 17, scope: !373)
!528 = !DILocation(line: 454, column: 50, scope: !373)
!529 = !DILocation(line: 454, column: 66, scope: !373)
!530 = !DILocation(line: 454, column: 32, scope: !373)
!531 = !DILocation(line: 455, column: 40, scope: !373)
!532 = !DILocation(line: 455, column: 17, scope: !373)
!533 = !DILocation(line: 456, column: 17, scope: !373)
!534 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit", scope: null, file: !535, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!535 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/filters/wse3.csl", directory: "")
!536 = !DILocation(line: 24, column: 3, scope: !537)
!537 = !DILexicalBlockFile(scope: !534, file: !535, discriminator: 0)
!538 = !DILocation(line: 24, column: 22, scope: !537)
!539 = !DILocation(line: 23, column: 3, scope: !537)
!540 = !DILocation(line: 22, column: 3, scope: !537)
!541 = !DILocation(line: 20, column: 37, scope: !537)
!542 = !DILocation(line: 20, column: 21, scope: !537)
!543 = !DILocation(line: 21, column: 11, scope: !537)
!544 = !DILocation(line: 21, column: 17, scope: !537)
!545 = !DILocation(line: 21, column: 3, scope: !537)
!546 = !DILocation(line: 22, column: 24, scope: !537)
!547 = !DILocation(line: 22, column: 30, scope: !537)
!548 = !DILocation(line: 23, column: 40, scope: !537)
!549 = !DILocation(line: 23, column: 22, scope: !537)
!550 = !DILocation(line: 23, column: 67, scope: !537)
!551 = !DILocation(line: 24, column: 26, scope: !537)
!552 = !DILocation(line: 24, column: 41, scope: !537)
!553 = !DILocation(line: 24, column: 39, scope: !537)
!554 = !DILocation(line: 24, column: 61, scope: !537)
!555 = !DILocation(line: 24, column: 76, scope: !537)
!556 = !DILocation(line: 24, column: 74, scope: !537)
!557 = !DILocation(line: 25, column: 21, scope: !537)
!558 = !DILocation(line: 25, column: 50, scope: !537)
!559 = !DILocation(line: 25, column: 3, scope: !537)
!560 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter", scope: null, file: !535, line: 30, type: !5, scopeLine: 30, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!561 = !DILocation(line: 30, column: 36, scope: !562)
!562 = !DILexicalBlockFile(scope: !560, file: !535, discriminator: 0)
!563 = !DILocation(line: 30, column: 20, scope: !562)
!564 = !DILocation(line: 31, column: 11, scope: !562)
!565 = !DILocation(line: 31, column: 23, scope: !562)
!566 = !DILocation(line: 31, column: 3, scope: !562)
!567 = !DILocation(line: 32, column: 21, scope: !562)
!568 = !DILocation(line: 32, column: 48, scope: !562)
!569 = !DILocation(line: 32, column: 60, scope: !562)
!570 = !DILocation(line: 32, column: 64, scope: !562)
!571 = !DILocation(line: 32, column: 3, scope: !562)
!572 = !DILocation(line: 30, column: 1, scope: !562)
!573 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter", scope: null, file: !535, line: 40, type: !5, scopeLine: 40, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!574 = !DILocation(line: 47, column: 3, scope: !575)
!575 = !DILexicalBlockFile(scope: !573, file: !535, discriminator: 0)
!576 = !DILocation(line: 48, column: 7, scope: !575)
!577 = !DILocation(line: 44, column: 3, scope: !575)
!578 = !DILocation(line: 43, column: 3, scope: !575)
!579 = !DILocation(line: 42, column: 3, scope: !575)
!580 = !DILocation(line: 40, column: 32, scope: !575)
!581 = !DILocation(line: 40, column: 16, scope: !575)
!582 = !DILocation(line: 41, column: 11, scope: !575)
!583 = !DILocation(line: 41, column: 19, scope: !575)
!584 = !DILocation(line: 41, column: 3, scope: !575)
!585 = !DILocation(line: 42, column: 40, scope: !575)
!586 = !DILocation(line: 42, column: 22, scope: !575)
!587 = !DILocation(line: 43, column: 26, scope: !575)
!588 = !DILocation(line: 43, column: 34, scope: !575)
!589 = !DILocation(line: 44, column: 25, scope: !575)
!590 = !DILocation(line: 44, column: 42, scope: !575)
!591 = !DILocation(line: 44, column: 40, scope: !575)
!592 = !DILocation(line: 45, column: 21, scope: !575)
!593 = !DILocation(line: 46, column: 35, scope: !575)
!594 = !DILocation(line: 46, column: 21, scope: !575)
!595 = !DILocation(line: 46, column: 50, scope: !575)
!596 = !DILocation(line: 45, column: 3, scope: !575)
!597 = !DILocation(line: 48, column: 11, scope: !575)
!598 = !DILocation(line: 48, column: 26, scope: !575)
!599 = !DILocation(line: 48, column: 43, scope: !575)
!600 = !DILocation(line: 48, column: 41, scope: !575)
!601 = !DILocation(line: 48, column: 54, scope: !575)
!602 = !DILocation(line: 48, column: 63, scope: !575)
!603 = !DILocation(line: 49, column: 21, scope: !575)
!604 = !DILocation(line: 49, column: 47, scope: !575)
!605 = !DILocation(line: 49, column: 3, scope: !575)
!606 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config", scope: null, file: !607, line: 33, type: !5, scopeLine: 33, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!607 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/filters/common.csl", directory: "")
!608 = !DILocation(line: 33, column: 46, scope: !609)
!609 = !DILexicalBlockFile(scope: !606, file: !607, discriminator: 0)
!610 = !DILocation(line: 33, column: 31, scope: !609)
!611 = !DILocation(line: 33, column: 15, scope: !609)
!612 = !DILocation(line: 34, column: 24, scope: !609)
!613 = !DILocation(line: 34, column: 23, scope: !609)
!614 = !DILocation(line: 34, column: 51, scope: !609)
!615 = !DILocation(line: 34, column: 35, scope: !609)
!616 = !DILocation(line: 34, column: 60, scope: !609)
!617 = !DILocation(line: 34, column: 73, scope: !609)
!618 = !DILocation(line: 34, column: 3, scope: !609)
!619 = !DILocation(line: 33, column: 1, scope: !609)
!620 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config", scope: null, file: !607, line: 38, type: !5, scopeLine: 38, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!621 = !DILocation(line: 38, column: 31, scope: !622)
!622 = !DILexicalBlockFile(scope: !620, file: !607, discriminator: 0)
!623 = !DILocation(line: 38, column: 15, scope: !622)
!624 = !DILocation(line: 39, column: 31, scope: !622)
!625 = !DILocation(line: 39, column: 30, scope: !622)
!626 = !DILocation(line: 39, column: 58, scope: !622)
!627 = !DILocation(line: 39, column: 42, scope: !622)
!628 = !DILocation(line: 39, column: 67, scope: !622)
!629 = !DILocation(line: 39, column: 10, scope: !622)
!630 = !DILocation(line: 39, column: 3, scope: !622)
!631 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit", scope: null, file: !632, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!632 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/teardown.csl", directory: "")
!633 = !DILocation(line: 43, column: 3, scope: !634)
!634 = !DILexicalBlockFile(scope: !631, file: !632, discriminator: 0)
!635 = !DILocation(line: 41, column: 3, scope: !634)
!636 = !DILocation(line: 40, column: 3, scope: !634)
!637 = !DILocation(line: 39, column: 9, scope: !634)
!638 = !DILocation(line: 40, column: 23, scope: !634)
!639 = !DILocation(line: 41, column: 70, scope: !634)
!640 = !DILocation(line: 41, column: 68, scope: !634)
!641 = !DILocation(line: 43, column: 27, scope: !634)
!642 = !DILocation(line: 43, column: 15, scope: !634)
!643 = !DILocation(line: 44, column: 15, scope: !634)
!644 = !DILocation(line: 44, column: 21, scope: !634)
!645 = !DILocation(line: 44, column: 27, scope: !634)
!646 = !DILocation(line: 44, column: 3, scope: !634)
!647 = !DILocation(line: 39, column: 1, scope: !634)
!648 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord", scope: null, file: !649, line: 4, type: !5, scopeLine: 4, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!649 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/layout.csl", directory: "")
!650 = !DILocation(line: 5, column: 10, scope: !651)
!651 = !DILexicalBlockFile(scope: !648, file: !649, discriminator: 0)
!652 = !DILocation(line: 5, column: 67, scope: !651)
!653 = !DILocation(line: 5, column: 3, scope: !651)
!654 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord", scope: null, file: !649, line: 8, type: !5, scopeLine: 8, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!655 = !DILocation(line: 9, column: 10, scope: !656)
!656 = !DILexicalBlockFile(scope: !654, file: !649, discriminator: 0)
!657 = !DILocation(line: 9, column: 67, scope: !656)
!658 = !DILocation(line: 9, column: 3, scope: !656)
!659 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord", scope: null, file: !660, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!660 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config.csl", directory: "")
!661 = !DILocation(line: 50, column: 3, scope: !662)
!662 = !DILexicalBlockFile(scope: !659, file: !660, discriminator: 0)
!663 = !DILocation(line: 43, column: 21, scope: !662)
!664 = !DILocation(line: 50, column: 57, scope: !662)
!665 = !DILocation(line: 50, column: 68, scope: !662)
!666 = !DILocation(line: 50, column: 41, scope: !662)
!667 = !DILocation(line: 50, column: 19, scope: !662)
!668 = !DILocation(line: 52, column: 10, scope: !662)
!669 = !DILocation(line: 52, column: 18, scope: !662)
!670 = !DILocation(line: 48, column: 22, scope: !662)
!671 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.get_x_coord", scope: null, file: !672, line: 171, type: !5, scopeLine: 171, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!672 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpyd2h.csl", directory: "")
!673 = !DILocation(line: 172, column: 12, scope: !674)
!674 = !DILexicalBlockFile(scope: !671, file: !672, discriminator: 0)
!675 = !DILocation(line: 172, column: 5, scope: !674)
!676 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.get_y_coord", scope: null, file: !672, line: 174, type: !5, scopeLine: 174, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!677 = !DILocation(line: 175, column: 12, scope: !678)
!678 = !DILexicalBlockFile(scope: !676, file: !672, discriminator: 0)
!679 = !DILocation(line: 175, column: 5, scope: !678)
!680 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval", scope: null, file: !672, line: 187, type: !5, scopeLine: 187, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!681 = !DILocation(line: 187, column: 23, scope: !682)
!682 = !DILexicalBlockFile(scope: !680, file: !672, discriminator: 0)
!683 = !DILocation(line: 188, column: 9, scope: !682)
!684 = !DILocation(line: 188, column: 20, scope: !682)
!685 = !DILocation(line: 188, column: 5, scope: !682)
!686 = !DILocation(line: 191, column: 23, scope: !682)
!687 = !DILocation(line: 191, column: 20, scope: !682)
!688 = !DILocation(line: 191, column: 9, scope: !682)
!689 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start", scope: null, file: !672, line: 383, type: !5, scopeLine: 383, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!690 = !DILocation(line: 386, column: 5, scope: !691)
!691 = !DILexicalBlockFile(scope: !689, file: !672, discriminator: 0)
!692 = !DILocation(line: 384, column: 72, scope: !691)
!693 = !DILocation(line: 384, column: 59, scope: !691)
!694 = !DILocation(line: 384, column: 46, scope: !691)
!695 = !DILocation(line: 384, column: 33, scope: !691)
!696 = !DILocation(line: 384, column: 19, scope: !691)
!697 = !DILocation(line: 384, column: 5, scope: !691)
!698 = !DILocation(line: 383, column: 32, scope: !691)
!699 = !DILocation(line: 383, column: 21, scope: !691)
!700 = !DILocation(line: 386, column: 26, scope: !691)
!701 = !DILocation(line: 388, column: 28, scope: !691)
!702 = !DILocation(line: 388, column: 17, scope: !691)
!703 = !DILocation(line: 389, column: 25, scope: !691)
!704 = !DILocation(line: 389, column: 23, scope: !691)
!705 = !DILocation(line: 391, column: 38, scope: !691)
!706 = !DILocation(line: 391, column: 20, scope: !691)
!707 = !DILocation(line: 391, column: 18, scope: !691)
!708 = !DILocation(line: 393, column: 7, scope: !691)
!709 = !DILocation(line: 395, column: 17, scope: !691)
!710 = !DILocation(line: 395, column: 15, scope: !691)
!711 = !DILocation(line: 397, column: 15, scope: !691)
!712 = !DILocation(line: 397, column: 13, scope: !691)
!713 = !DILocation(line: 398, column: 15, scope: !691)
!714 = !DILocation(line: 398, column: 25, scope: !691)
!715 = !DILocation(line: 398, column: 23, scope: !691)
!716 = !DILocation(line: 398, column: 31, scope: !691)
!717 = !DILocation(line: 398, column: 13, scope: !691)
!718 = !DILocation(line: 401, column: 10, scope: !691)
!719 = !DILocation(line: 401, column: 17, scope: !691)
!720 = !DILocation(line: 401, column: 14, scope: !691)
!721 = !DILocation(line: 401, column: 5, scope: !691)
!722 = !DILocation(line: 403, column: 48, scope: !691)
!723 = !DILocation(line: 403, column: 26, scope: !691)
!724 = !DILocation(line: 404, column: 26, scope: !691)
!725 = !DILocation(line: 404, column: 18, scope: !691)
!726 = !DILocation(line: 407, column: 48, scope: !691)
!727 = !DILocation(line: 407, column: 26, scope: !691)
!728 = !DILocation(line: 408, column: 27, scope: !691)
!729 = !DILocation(line: 408, column: 18, scope: !691)
!730 = !DILocation(line: 411, column: 14, scope: !691)
!731 = !DILocation(line: 414, column: 14, scope: !691)
!732 = !DILocation(line: 414, column: 11, scope: !691)
!733 = !DILocation(line: 414, column: 5, scope: !691)
!734 = !DILocation(line: 416, column: 44, scope: !691)
!735 = !DILocation(line: 416, column: 75, scope: !691)
!736 = !DILocation(line: 416, column: 59, scope: !691)
!737 = !DILocation(line: 416, column: 25, scope: !691)
!738 = !DILocation(line: 416, column: 23, scope: !691)
!739 = !DILocation(line: 418, column: 41, scope: !691)
!740 = !DILocation(line: 418, column: 23, scope: !691)
!741 = !DILocation(line: 419, column: 9, scope: !691)
!742 = !DILocation(line: 425, column: 44, scope: !691)
!743 = !DILocation(line: 425, column: 23, scope: !691)
!744 = !DILocation(line: 426, column: 41, scope: !691)
!745 = !DILocation(line: 426, column: 23, scope: !691)
!746 = !DILocation(line: 427, column: 9, scope: !691)
!747 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x", scope: null, file: !672, line: 448, type: !5, scopeLine: 448, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!748 = !DILocation(line: 448, column: 31, scope: !749)
!749 = !DILexicalBlockFile(scope: !747, file: !672, discriminator: 0)
!750 = !DILocation(line: 453, column: 5, scope: !749)
!751 = !DILocation(line: 456, column: 19, scope: !749)
!752 = !DILocation(line: 456, column: 17, scope: !749)
!753 = !DILocation(line: 461, column: 5, scope: !749)
!754 = !DILocation(line: 462, column: 28, scope: !749)
!755 = !DILocation(line: 462, column: 5, scope: !749)
!756 = !DILocation(line: 463, column: 5, scope: !749)
!757 = !DILocation(line: 464, column: 9, scope: !749)
!758 = !DILocation(line: 464, column: 10, scope: !749)
!759 = !DILocation(line: 464, column: 7, scope: !749)
!760 = !DILocation(line: 448, column: 1, scope: !749)
!761 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_send_data", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_send_data", scope: null, file: !672, line: 476, type: !5, scopeLine: 476, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!762 = !DILocation(line: 494, column: 9, scope: !763)
!763 = !DILexicalBlockFile(scope: !761, file: !672, discriminator: 0)
!764 = !DILocation(line: 478, column: 9, scope: !763)
!765 = !DILocation(line: 478, column: 13, scope: !763)
!766 = !DILocation(line: 478, column: 11, scope: !763)
!767 = !DILocation(line: 478, column: 5, scope: !763)
!768 = !DILocation(line: 479, column: 9, scope: !763)
!769 = !DILocation(line: 480, column: 32, scope: !763)
!770 = !DILocation(line: 480, column: 9, scope: !763)
!771 = !DILocation(line: 481, column: 17, scope: !763)
!772 = !DILocation(line: 481, column: 15, scope: !763)
!773 = !DILocation(line: 481, column: 9, scope: !763)
!774 = !DILocation(line: 482, column: 13, scope: !763)
!775 = !DILocation(line: 483, column: 51, scope: !763)
!776 = !DILocation(line: 483, column: 29, scope: !763)
!777 = !DILocation(line: 483, column: 27, scope: !763)
!778 = !DILocation(line: 485, column: 13, scope: !763)
!779 = !DILocation(line: 486, column: 51, scope: !763)
!780 = !DILocation(line: 486, column: 29, scope: !763)
!781 = !DILocation(line: 486, column: 27, scope: !763)
!782 = !DILocation(line: 488, column: 13, scope: !763)
!783 = !DILocation(line: 488, column: 14, scope: !763)
!784 = !DILocation(line: 488, column: 11, scope: !763)
!785 = !DILocation(line: 494, column: 30, scope: !763)
!786 = !DILocation(line: 496, column: 14, scope: !763)
!787 = !DILocation(line: 496, column: 25, scope: !763)
!788 = !DILocation(line: 496, column: 22, scope: !763)
!789 = !DILocation(line: 496, column: 9, scope: !763)
!790 = !DILocation(line: 497, column: 13, scope: !763)
!791 = !DILocation(line: 498, column: 13, scope: !763)
!792 = !DILocation(line: 499, column: 13, scope: !763)
!793 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl", scope: null, file: !672, line: 505, type: !5, scopeLine: 505, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!794 = !DILocation(line: 524, column: 13, scope: !795)
!795 = !DILexicalBlockFile(scope: !793, file: !672, discriminator: 0)
!796 = !DILocation(line: 506, column: 14, scope: !795)
!797 = !DILocation(line: 506, column: 11, scope: !795)
!798 = !DILocation(line: 506, column: 5, scope: !795)
!799 = !DILocation(line: 508, column: 9, scope: !795)
!800 = !DILocation(line: 509, column: 32, scope: !795)
!801 = !DILocation(line: 509, column: 9, scope: !795)
!802 = !DILocation(line: 510, column: 9, scope: !795)
!803 = !DILocation(line: 514, column: 13, scope: !795)
!804 = !DILocation(line: 514, column: 17, scope: !795)
!805 = !DILocation(line: 514, column: 15, scope: !795)
!806 = !DILocation(line: 514, column: 9, scope: !795)
!807 = !DILocation(line: 518, column: 13, scope: !795)
!808 = !DILocation(line: 519, column: 36, scope: !795)
!809 = !DILocation(line: 519, column: 13, scope: !795)
!810 = !DILocation(line: 520, column: 13, scope: !795)
!811 = !DILocation(line: 524, column: 34, scope: !795)
!812 = !DILocation(line: 526, column: 18, scope: !795)
!813 = !DILocation(line: 526, column: 29, scope: !795)
!814 = !DILocation(line: 526, column: 26, scope: !795)
!815 = !DILocation(line: 526, column: 13, scope: !795)
!816 = !DILocation(line: 529, column: 17, scope: !795)
!817 = !DILocation(line: 530, column: 17, scope: !795)
!818 = !DILocation(line: 531, column: 17, scope: !795)
!819 = !DILocation(line: 534, column: 17, scope: !795)
!820 = !DILocation(line: 535, column: 40, scope: !795)
!821 = !DILocation(line: 535, column: 17, scope: !795)
!822 = !DILocation(line: 536, column: 17, scope: !795)
!823 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.d2h_configure", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.d2h_configure", scope: null, file: !672, line: 593, type: !5, scopeLine: 593, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!824 = !DILocation(line: 617, column: 26, scope: !825)
!825 = !DILexicalBlockFile(scope: !823, file: !672, discriminator: 0)
!826 = !DILocation(line: 612, column: 47, scope: !825)
!827 = !DILocation(line: 612, column: 27, scope: !825)
!828 = !DILocation(line: 602, column: 5, scope: !825)
!829 = !DILocation(line: 601, column: 5, scope: !825)
!830 = !DILocation(line: 599, column: 5, scope: !825)
!831 = !DILocation(line: 598, column: 5, scope: !825)
!832 = !DILocation(line: 596, column: 5, scope: !825)
!833 = !DILocation(line: 595, column: 5, scope: !825)
!834 = !DILocation(line: 593, column: 86, scope: !825)
!835 = !DILocation(line: 593, column: 70, scope: !825)
!836 = !DILocation(line: 593, column: 60, scope: !825)
!837 = !DILocation(line: 593, column: 52, scope: !825)
!838 = !DILocation(line: 593, column: 44, scope: !825)
!839 = !DILocation(line: 593, column: 35, scope: !825)
!840 = !DILocation(line: 593, column: 26, scope: !825)
!841 = !DILocation(line: 593, column: 18, scope: !825)
!842 = !DILocation(line: 595, column: 26, scope: !825)
!843 = !DILocation(line: 596, column: 26, scope: !825)
!844 = !DILocation(line: 598, column: 23, scope: !825)
!845 = !DILocation(line: 599, column: 23, scope: !825)
!846 = !DILocation(line: 599, column: 28, scope: !825)
!847 = !DILocation(line: 599, column: 26, scope: !825)
!848 = !DILocation(line: 599, column: 29, scope: !825)
!849 = !DILocation(line: 601, column: 24, scope: !825)
!850 = !DILocation(line: 602, column: 24, scope: !825)
!851 = !DILocation(line: 602, column: 29, scope: !825)
!852 = !DILocation(line: 602, column: 27, scope: !825)
!853 = !DILocation(line: 602, column: 30, scope: !825)
!854 = !DILocation(line: 611, column: 20, scope: !825)
!855 = !DILocation(line: 612, column: 11, scope: !825)
!856 = !DILocation(line: 612, column: 18, scope: !825)
!857 = !DILocation(line: 612, column: 15, scope: !825)
!858 = !DILocation(line: 612, column: 32, scope: !825)
!859 = !DILocation(line: 612, column: 39, scope: !825)
!860 = !DILocation(line: 612, column: 36, scope: !825)
!861 = !DILocation(line: 612, column: 52, scope: !825)
!862 = !DILocation(line: 612, column: 59, scope: !825)
!863 = !DILocation(line: 612, column: 56, scope: !825)
!864 = !DILocation(line: 612, column: 5, scope: !825)
!865 = !DILocation(line: 613, column: 24, scope: !825)
!866 = !DILocation(line: 616, column: 15, scope: !825)
!867 = !DILocation(line: 617, column: 11, scope: !825)
!868 = !DILocation(line: 617, column: 18, scope: !825)
!869 = !DILocation(line: 617, column: 15, scope: !825)
!870 = !DILocation(line: 617, column: 30, scope: !825)
!871 = !DILocation(line: 617, column: 5, scope: !825)
!872 = !DILocation(line: 618, column: 19, scope: !825)
!873 = !DILocation(line: 621, column: 9, scope: !825)
!874 = !DILocation(line: 621, column: 5, scope: !825)
!875 = !DILocation(line: 627, column: 9, scope: !825)
!876 = !DILocation(line: 629, column: 13, scope: !825)
!877 = !DILocation(line: 629, column: 25, scope: !825)
!878 = !DILocation(line: 629, column: 21, scope: !825)
!879 = !DILocation(line: 629, column: 9, scope: !825)
!880 = !DILocation(line: 632, column: 13, scope: !825)
!881 = !DILocation(line: 636, column: 13, scope: !825)
!882 = !DILocation(line: 641, column: 9, scope: !825)
!883 = !DILocation(line: 646, column: 13, scope: !825)
!884 = !DILocation(line: 646, column: 9, scope: !825)
!885 = !DILocation(line: 647, column: 30, scope: !825)
!886 = !DILocation(line: 647, column: 35, scope: !825)
!887 = !DILocation(line: 647, column: 46, scope: !825)
!888 = !DILocation(line: 647, column: 50, scope: !825)
!889 = !DILocation(line: 647, column: 54, scope: !825)
!890 = !DILocation(line: 647, column: 57, scope: !825)
!891 = !DILocation(line: 647, column: 60, scope: !825)
!892 = !DILocation(line: 647, column: 63, scope: !825)
!893 = !DILocation(line: 647, column: 13, scope: !825)
!894 = !DILocation(line: 661, column: 9, scope: !825)
!895 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit", scope: null, file: !632, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!896 = !DILocation(line: 43, column: 3, scope: !897)
!897 = !DILexicalBlockFile(scope: !895, file: !632, discriminator: 0)
!898 = !DILocation(line: 41, column: 3, scope: !897)
!899 = !DILocation(line: 40, column: 3, scope: !897)
!900 = !DILocation(line: 39, column: 9, scope: !897)
!901 = !DILocation(line: 40, column: 23, scope: !897)
!902 = !DILocation(line: 41, column: 70, scope: !897)
!903 = !DILocation(line: 41, column: 68, scope: !897)
!904 = !DILocation(line: 43, column: 27, scope: !897)
!905 = !DILocation(line: 43, column: 15, scope: !897)
!906 = !DILocation(line: 44, column: 15, scope: !897)
!907 = !DILocation(line: 44, column: 21, scope: !897)
!908 = !DILocation(line: 44, column: 27, scope: !897)
!909 = !DILocation(line: 44, column: 3, scope: !897)
!910 = !DILocation(line: 39, column: 1, scope: !897)
!911 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord", scope: null, file: !649, line: 4, type: !5, scopeLine: 4, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!912 = !DILocation(line: 5, column: 10, scope: !913)
!913 = !DILexicalBlockFile(scope: !911, file: !649, discriminator: 0)
!914 = !DILocation(line: 5, column: 67, scope: !913)
!915 = !DILocation(line: 5, column: 3, scope: !913)
!916 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord", scope: null, file: !649, line: 8, type: !5, scopeLine: 8, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!917 = !DILocation(line: 9, column: 10, scope: !918)
!918 = !DILexicalBlockFile(scope: !916, file: !649, discriminator: 0)
!919 = !DILocation(line: 9, column: 67, scope: !918)
!920 = !DILocation(line: 9, column: 3, scope: !918)
!921 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord", scope: null, file: !660, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!922 = !DILocation(line: 50, column: 3, scope: !923)
!923 = !DILexicalBlockFile(scope: !921, file: !660, discriminator: 0)
!924 = !DILocation(line: 43, column: 21, scope: !923)
!925 = !DILocation(line: 50, column: 57, scope: !923)
!926 = !DILocation(line: 50, column: 68, scope: !923)
!927 = !DILocation(line: 50, column: 41, scope: !923)
!928 = !DILocation(line: 50, column: 19, scope: !923)
!929 = !DILocation(line: 52, column: 10, scope: !923)
!930 = !DILocation(line: 52, column: 18, scope: !923)
!931 = !DILocation(line: 48, column: 22, scope: !923)
!932 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr", linkageName: "sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr", scope: null, file: !933, line: 11, type: !5, scopeLine: 11, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!933 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/input_queue_config.csl", directory: "")
!934 = !DILocation(line: 11, column: 32, scope: !935)
!935 = !DILexicalBlockFile(scope: !932, file: !933, discriminator: 0)
!936 = !DILocation(line: 12, column: 80, scope: !935)
!937 = !DILocation(line: 12, column: 69, scope: !935)
!938 = !DILocation(line: 12, column: 39, scope: !935)
!939 = !DILocation(line: 12, column: 3, scope: !935)
!940 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue", linkageName: "sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue", scope: null, file: !933, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!941 = !DILocation(line: 46, column: 3, scope: !942)
!942 = !DILexicalBlockFile(scope: !940, file: !933, discriminator: 0)
!943 = !DILocation(line: 45, column: 3, scope: !942)
!944 = !DILocation(line: 39, column: 42, scope: !942)
!945 = !DILocation(line: 39, column: 34, scope: !942)
!946 = !DILocation(line: 39, column: 24, scope: !942)
!947 = !DILocation(line: 45, column: 44, scope: !942)
!948 = !DILocation(line: 45, column: 16, scope: !942)
!949 = !DILocation(line: 46, column: 30, scope: !942)
!950 = !DILocation(line: 46, column: 18, scope: !942)
!951 = !DILocation(line: 56, column: 9, scope: !942)
!952 = !DILocation(line: 56, column: 5, scope: !942)
!953 = !DILocation(line: 58, column: 13, scope: !942)
!954 = !DILocation(line: 58, column: 17, scope: !942)
!955 = !DILocation(line: 58, column: 11, scope: !942)
!956 = !DILocation(line: 61, column: 13, scope: !942)
!957 = !DILocation(line: 61, column: 17, scope: !942)
!958 = !DILocation(line: 61, column: 11, scope: !942)
!959 = !DILocation(line: 66, column: 9, scope: !942)
!960 = !DILocation(line: 66, column: 13, scope: !942)
!961 = !DILocation(line: 66, column: 7, scope: !942)
!962 = !DILocation(line: 68, column: 9, scope: !942)
!963 = !DILocation(line: 68, column: 24, scope: !942)
!964 = !DILocation(line: 68, column: 13, scope: !942)
!965 = !DILocation(line: 68, column: 7, scope: !942)
!966 = !DILocation(line: 70, column: 15, scope: !942)
!967 = !DILocation(line: 70, column: 21, scope: !942)
!968 = !DILocation(line: 70, column: 3, scope: !942)
!969 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr", linkageName: "sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr", scope: null, file: !970, line: 11, type: !5, scopeLine: 11, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!970 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/output_queue_config.csl", directory: "")
!971 = !DILocation(line: 11, column: 33, scope: !972)
!972 = !DILexicalBlockFile(scope: !969, file: !970, discriminator: 0)
!973 = !DILocation(line: 12, column: 82, scope: !972)
!974 = !DILocation(line: 12, column: 40, scope: !972)
!975 = !DILocation(line: 12, column: 3, scope: !972)
!976 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue", linkageName: "sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue", scope: null, file: !970, line: 31, type: !5, scopeLine: 31, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!977 = !DILocation(line: 38, column: 3, scope: !978)
!978 = !DILexicalBlockFile(scope: !976, file: !970, discriminator: 0)
!979 = !DILocation(line: 37, column: 3, scope: !978)
!980 = !DILocation(line: 31, column: 35, scope: !978)
!981 = !DILocation(line: 31, column: 25, scope: !978)
!982 = !DILocation(line: 37, column: 45, scope: !978)
!983 = !DILocation(line: 37, column: 16, scope: !978)
!984 = !DILocation(line: 38, column: 30, scope: !978)
!985 = !DILocation(line: 38, column: 18, scope: !978)
!986 = !DILocation(line: 41, column: 9, scope: !978)
!987 = !DILocation(line: 41, column: 13, scope: !978)
!988 = !DILocation(line: 41, column: 7, scope: !978)
!989 = !DILocation(line: 43, column: 9, scope: !978)
!990 = !DILocation(line: 43, column: 24, scope: !978)
!991 = !DILocation(line: 43, column: 13, scope: !978)
!992 = !DILocation(line: 43, column: 27, scope: !978)
!993 = !DILocation(line: 43, column: 7, scope: !978)
!994 = !DILocation(line: 45, column: 15, scope: !978)
!995 = !DILocation(line: 45, column: 21, scope: !978)
!996 = !DILocation(line: 45, column: 3, scope: !978)
!997 = !DILocation(line: 31, column: 1, scope: !978)
!998 = distinct !DISubprogram(name: ".get_tensor_ptr", linkageName: ".get_tensor_ptr", scope: null, file: !4, line: 1, type: !5, scopeLine: 1, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!999 = !DILocation(line: 1, column: 1, scope: !1000)
!1000 = !DILexicalBlockFile(scope: !998, file: !4, discriminator: 0)
!1001 = distinct !DISubprogram(name: "__generic0sys_mod.sys_mod.tile_config.queue_flush.exit", linkageName: "__generic0sys_mod.sys_mod.tile_config.queue_flush.exit", scope: null, file: !1002, line: 12, type: !5, scopeLine: 12, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1002 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/queue_flush.csl", directory: "")
!1003 = !DILocation(line: 24, column: 3, scope: !1004)
!1004 = !DILexicalBlockFile(scope: !1001, file: !1002, discriminator: 0)
!1005 = !DILocation(line: 12, column: 1, scope: !1004)
!1006 = distinct !DISubprogram(name: "__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position", linkageName: "__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position", scope: null, file: !1007, line: 30, type: !5, scopeLine: 30, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1007 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/switch_config.csl", directory: "")
!1008 = !DILocation(line: 34, column: 3, scope: !1009)
!1009 = !DILexicalBlockFile(scope: !1006, file: !1007, discriminator: 0)
!1010 = !DILocation(line: 32, column: 3, scope: !1009)
!1011 = !DILocation(line: 30, column: 27, scope: !1009)
!1012 = !DILocation(line: 33, column: 7, scope: !1009)
!1013 = !DILocation(line: 34, column: 36, scope: !1009)
!1014 = !DILocation(line: 34, column: 24, scope: !1009)
!1015 = !DILocation(line: 35, column: 3, scope: !1009)
!1016 = !DILocation(line: 35, column: 18, scope: !1009)
!1017 = !DILocation(line: 36, column: 15, scope: !1009)
!1018 = !DILocation(line: 36, column: 21, scope: !1009)
!1019 = !DILocation(line: 36, column: 3, scope: !1009)
!1020 = !DILocation(line: 30, column: 1, scope: !1009)
!1021 = distinct !DISubprogram(name: "__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", linkageName: "__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", scope: null, file: !1022, line: 96, type: !5, scopeLine: 96, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1022 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/color_config.csl", directory: "")
!1023 = !DILocation(line: 99, column: 3, scope: !1024)
!1024 = !DILexicalBlockFile(scope: !1021, file: !1022, discriminator: 0)
!1025 = !DILocation(line: 98, column: 3, scope: !1024)
!1026 = !DILocation(line: 96, column: 17, scope: !1024)
!1027 = !DILocation(line: 98, column: 16, scope: !1024)
!1028 = !DILocation(line: 99, column: 29, scope: !1024)
!1029 = !DILocation(line: 99, column: 17, scope: !1024)
!1030 = !DILocation(line: 100, column: 13, scope: !1024)
!1031 = !DILocation(line: 100, column: 21, scope: !1024)
!1032 = !DILocation(line: 100, column: 11, scope: !1024)
!1033 = !DILocation(line: 104, column: 7, scope: !1024)
!1034 = !DILocation(line: 104, column: 50, scope: !1024)
!1035 = !DILocation(line: 104, column: 18, scope: !1024)
!1036 = !DILocation(line: 104, column: 15, scope: !1024)
!1037 = !DILocation(line: 121, column: 7, scope: !1024)
!1038 = !DILocation(line: 121, column: 50, scope: !1024)
!1039 = !DILocation(line: 121, column: 18, scope: !1024)
!1040 = !DILocation(line: 121, column: 15, scope: !1024)
!1041 = !DILocation(line: 128, column: 15, scope: !1024)
!1042 = !DILocation(line: 128, column: 21, scope: !1024)
!1043 = !DILocation(line: 128, column: 3, scope: !1024)
!1044 = !DILocation(line: 96, column: 1, scope: !1024)
!1045 = distinct !DISubprogram(name: "__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", linkageName: "__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", scope: null, file: !1022, line: 96, type: !5, scopeLine: 96, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1046 = !DILocation(line: 99, column: 3, scope: !1047)
!1047 = !DILexicalBlockFile(scope: !1045, file: !1022, discriminator: 0)
!1048 = !DILocation(line: 98, column: 3, scope: !1047)
!1049 = !DILocation(line: 96, column: 17, scope: !1047)
!1050 = !DILocation(line: 98, column: 16, scope: !1047)
!1051 = !DILocation(line: 99, column: 29, scope: !1047)
!1052 = !DILocation(line: 99, column: 17, scope: !1047)
!1053 = !DILocation(line: 100, column: 13, scope: !1047)
!1054 = !DILocation(line: 100, column: 21, scope: !1047)
!1055 = !DILocation(line: 100, column: 11, scope: !1047)
!1056 = !DILocation(line: 104, column: 7, scope: !1047)
!1057 = !DILocation(line: 104, column: 50, scope: !1047)
!1058 = !DILocation(line: 104, column: 18, scope: !1047)
!1059 = !DILocation(line: 104, column: 15, scope: !1047)
!1060 = !DILocation(line: 121, column: 7, scope: !1047)
!1061 = !DILocation(line: 121, column: 50, scope: !1047)
!1062 = !DILocation(line: 121, column: 18, scope: !1047)
!1063 = !DILocation(line: 121, column: 15, scope: !1047)
!1064 = !DILocation(line: 128, column: 15, scope: !1047)
!1065 = !DILocation(line: 128, column: 21, scope: !1047)
!1066 = !DILocation(line: 128, column: 3, scope: !1047)
!1067 = !DILocation(line: 96, column: 1, scope: !1047)
!1068 = distinct !DISubprogram(name: "__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", linkageName: "__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", scope: null, file: !1022, line: 60, type: !5, scopeLine: 60, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1069 = !DILocation(line: 61, column: 3, scope: !1070)
!1070 = !DILexicalBlockFile(scope: !1068, file: !1022, discriminator: 0)
!1071 = !DILocation(line: 60, column: 46, scope: !1070)
!1072 = !DILocation(line: 61, column: 16, scope: !1070)
!1073 = !DILocation(line: 72, column: 5, scope: !1070)
!1074 = !DILocation(line: 72, column: 12, scope: !1070)
!1075 = !DILocation(line: 74, column: 10, scope: !1070)
!1076 = !DILocation(line: 74, column: 3, scope: !1070)
!1077 = distinct !DISubprogram(name: "__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes", linkageName: "__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes", scope: null, file: !1022, line: 77, type: !5, scopeLine: 77, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1078 = !DILocation(line: 78, column: 3, scope: !1079)
!1079 = !DILexicalBlockFile(scope: !1077, file: !1022, discriminator: 0)
!1080 = !DILocation(line: 77, column: 46, scope: !1079)
!1081 = !DILocation(line: 78, column: 16, scope: !1079)
!1082 = !DILocation(line: 86, column: 5, scope: !1079)
!1083 = !DILocation(line: 86, column: 12, scope: !1079)
!1084 = !DILocation(line: 91, column: 10, scope: !1079)
!1085 = !DILocation(line: 91, column: 3, scope: !1079)
!1086 = distinct !DISubprogram(name: "__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", linkageName: "__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", scope: null, file: !1022, line: 60, type: !5, scopeLine: 60, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1087 = !DILocation(line: 61, column: 3, scope: !1088)
!1088 = !DILexicalBlockFile(scope: !1086, file: !1022, discriminator: 0)
!1089 = !DILocation(line: 60, column: 46, scope: !1088)
!1090 = !DILocation(line: 61, column: 16, scope: !1088)
!1091 = !DILocation(line: 63, column: 5, scope: !1088)
!1092 = !DILocation(line: 63, column: 12, scope: !1088)
!1093 = !DILocation(line: 74, column: 10, scope: !1088)
!1094 = !DILocation(line: 74, column: 3, scope: !1088)
!1095 = distinct !DISubprogram(name: "__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction", linkageName: "__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction", scope: null, file: !1022, line: 52, type: !5, scopeLine: 52, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1096 = !DILocation(line: 55, column: 3, scope: !1097)
!1097 = !DILexicalBlockFile(scope: !1095, file: !1022, discriminator: 0)
!1098 = !DILocation(line: 54, column: 3, scope: !1097)
!1099 = !DILocation(line: 52, column: 23, scope: !1097)
!1100 = !DILocation(line: 54, column: 16, scope: !1097)
!1101 = !DILocation(line: 55, column: 29, scope: !1097)
!1102 = !DILocation(line: 55, column: 17, scope: !1097)
!1103 = !DILocation(line: 56, column: 3, scope: !1097)
!1104 = !DILocation(line: 56, column: 11, scope: !1097)
!1105 = !DILocation(line: 57, column: 15, scope: !1097)
!1106 = !DILocation(line: 57, column: 21, scope: !1097)
!1107 = !DILocation(line: 57, column: 3, scope: !1097)
!1108 = !DILocation(line: 52, column: 1, scope: !1097)
!1109 = distinct !DISubprogram(name: "__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction", linkageName: "__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction", scope: null, file: !1022, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1110 = !DILocation(line: 23, column: 3, scope: !1111)
!1111 = !DILexicalBlockFile(scope: !1109, file: !1022, discriminator: 0)
!1112 = !DILocation(line: 22, column: 3, scope: !1111)
!1113 = !DILocation(line: 20, column: 21, scope: !1111)
!1114 = !DILocation(line: 22, column: 16, scope: !1111)
!1115 = !DILocation(line: 23, column: 29, scope: !1111)
!1116 = !DILocation(line: 23, column: 17, scope: !1111)
!1117 = !DILocation(line: 24, column: 3, scope: !1111)
!1118 = !DILocation(line: 24, column: 11, scope: !1111)
!1119 = !DILocation(line: 25, column: 15, scope: !1111)
!1120 = !DILocation(line: 25, column: 21, scope: !1111)
!1121 = !DILocation(line: 25, column: 3, scope: !1111)
!1122 = !DILocation(line: 20, column: 1, scope: !1111)
module asm ".section \22.pe_debug_info\22, \22\22"
module asm ".section \22.note\22, \22\22"
