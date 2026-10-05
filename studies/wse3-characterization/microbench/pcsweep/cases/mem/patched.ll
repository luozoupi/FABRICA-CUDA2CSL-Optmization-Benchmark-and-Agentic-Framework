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
  store i16 %3, i16* getelementptr inbounds ([80 x i16], [80 x i16]* @c, i16 0, i1 false), align 2, !dbg !12
  %4 = load i16, i16* getelementptr inbounds ([80 x i16], [80 x i16]* @c, i16 0, i1 false), align 2, !dbg !13
  %5 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @g, i16 0, i1 false), align 2, !dbg !14
  %6 = add i16 %4, %5, !dbg !15
  store i16 %6, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @d, i16 0, i1 false), align 2, !dbg !16
  store i16 24577, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i2 1), align 2, !dbg !17
  %7 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @a, i16 0, i2 1), align 2, !dbg !18
  %8 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @b, i16 0, i2 1), align 2, !dbg !19
  %9 = add i16 %7, %8, !dbg !20
  store i16 %9, i16* getelementptr inbounds ([80 x i16], [80 x i16]* @c, i16 0, i2 1), align 2, !dbg !21
  call void asm sideeffect "nop", ""()
  %10 = load i16, i16* getelementptr inbounds ([80 x i16], [80 x i16]* @c, i16 0, i2 1), align 2, !dbg !22
  %11 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @g, i16 0, i2 1), align 2, !dbg !23
  %12 = add i16 %10, %11, !dbg !24
  store i16 %12, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @d, i16 0, i2 1), align 2, !dbg !25
  store i16 24578, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i3 2), align 2, !dbg !26
  %13 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @a, i16 0, i3 2), align 2, !dbg !27
  %14 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @b, i16 0, i3 2), align 2, !dbg !28
  %15 = add i16 %13, %14, !dbg !29
  store i16 %15, i16* getelementptr inbounds ([80 x i16], [80 x i16]* @c, i16 0, i3 2), align 2, !dbg !30
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  %16 = load i16, i16* getelementptr inbounds ([80 x i16], [80 x i16]* @c, i16 0, i3 2), align 2, !dbg !31
  %17 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @g, i16 0, i3 2), align 2, !dbg !32
  %18 = add i16 %16, %17, !dbg !33
  store i16 %18, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @d, i16 0, i3 2), align 2, !dbg !34
  store i16 24579, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i3 3), align 2, !dbg !35
  %19 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @a, i16 0, i3 3), align 2, !dbg !36
  %20 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @b, i16 0, i3 3), align 2, !dbg !37
  %21 = add i16 %19, %20, !dbg !38
  store i16 %21, i16* getelementptr inbounds ([80 x i16], [80 x i16]* @c, i16 0, i3 3), align 2, !dbg !39
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  %22 = load i16, i16* getelementptr inbounds ([80 x i16], [80 x i16]* @c, i16 0, i3 3), align 2, !dbg !40
  %23 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @g, i16 0, i3 3), align 2, !dbg !41
  %24 = add i16 %22, %23, !dbg !42
  store i16 %24, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @d, i16 0, i3 3), align 2, !dbg !43
  store i16 24580, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i4 4), align 2, !dbg !44
  %25 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @a, i16 0, i4 4), align 2, !dbg !45
  %26 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @b, i16 0, i4 4), align 2, !dbg !46
  %27 = add i16 %25, %26, !dbg !47
  store i16 %27, i16* getelementptr inbounds ([80 x i16], [80 x i16]* @c, i16 0, i4 4), align 2, !dbg !48
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  %28 = load i16, i16* getelementptr inbounds ([80 x i16], [80 x i16]* @c, i16 0, i4 4), align 2, !dbg !49
  %29 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @g, i16 0, i4 4), align 2, !dbg !50
  %30 = add i16 %28, %29, !dbg !51
  store i16 %30, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @d, i16 0, i4 4), align 2, !dbg !52
  store i16 24581, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i4 5), align 2, !dbg !53
  %31 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @a, i16 0, i4 5), align 2, !dbg !54
  %32 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @b, i16 0, i4 5), align 2, !dbg !55
  %33 = add i16 %31, %32, !dbg !56
  store i16 %33, i16* getelementptr inbounds ([80 x i16], [80 x i16]* @c, i16 0, i4 5), align 2, !dbg !57
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  %34 = load i16, i16* getelementptr inbounds ([80 x i16], [80 x i16]* @c, i16 0, i4 5), align 2, !dbg !58
  %35 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @g, i16 0, i4 5), align 2, !dbg !59
  %36 = add i16 %34, %35, !dbg !60
  store i16 %36, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @d, i16 0, i4 5), align 2, !dbg !61
  store i16 24582, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i4 6), align 2, !dbg !62
  %37 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @a, i16 0, i4 6), align 2, !dbg !63
  %38 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @b, i16 0, i4 6), align 2, !dbg !64
  %39 = add i16 %37, %38, !dbg !65
  store i16 %39, i16* getelementptr inbounds ([80 x i16], [80 x i16]* @c, i16 0, i4 6), align 2, !dbg !66
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
  %40 = load i16, i16* getelementptr inbounds ([80 x i16], [80 x i16]* @c, i16 0, i4 6), align 2, !dbg !67
  %41 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @g, i16 0, i4 6), align 2, !dbg !68
  %42 = add i16 %40, %41, !dbg !69
  store i16 %42, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @d, i16 0, i4 6), align 2, !dbg !70
  store i16 24583, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i4 7), align 2, !dbg !71
  %43 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @a, i16 0, i4 7), align 2, !dbg !72
  %44 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @b, i16 0, i4 7), align 2, !dbg !73
  %45 = add i16 %43, %44, !dbg !74
  store i16 %45, i16* getelementptr inbounds ([80 x i16], [80 x i16]* @c, i16 0, i4 7), align 2, !dbg !75
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
  %46 = load i16, i16* getelementptr inbounds ([80 x i16], [80 x i16]* @c, i16 0, i4 7), align 2, !dbg !76
  %47 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @g, i16 0, i4 7), align 2, !dbg !77
  %48 = add i16 %46, %47, !dbg !78
  store i16 %48, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @d, i16 0, i4 7), align 2, !dbg !79
  store i16 24584, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i5 8), align 2, !dbg !80
  call void @llvm.sdr.actvt.r(i16 9), !dbg !81
  ret void, !dbg !82
}

define void @f_exit() #0 !dbg !83 {
  call void @sys_mod.unblock_cmd_stream(), !dbg !84
  ret void, !dbg !86
}

define internal void @sys_mod.sys_nop() !dbg !87 {
  ret void, !dbg !89
}

define internal void @sys_mod.unblock_cmd_stream() !dbg !91 {
  call void @sys_mod.sys_mod.unblock_cmd_stream(), !dbg !92
  ret void, !dbg !94
}

define internal void @sys_mod.sys_mod.unblock_cmd_stream() !dbg !95 {
  call void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream(), !dbg !97
  ret void, !dbg !99
}

define internal void @sys_mod.sys_mod.teardown_h2d() !dbg !100 {
  call void @llvm.sdr.actvt.r(i16 27), !dbg !101
  ret void, !dbg !103
}

define void @sys_mod.sys_mod.f_ublk_c22() #1 !dbg !104 {
  call void @sys_mod.sys_mod.unblock_cmd_stream(), !dbg !105
  ret void, !dbg !107
}

define internal void @sys_mod.sys_mod.teardown_d2h() !dbg !108 {
  call void @llvm.sdr.blk.r(i16 0), !dbg !109
  call void @llvm.sdr.actvt.r(i16 28), !dbg !111
  ret void, !dbg !112
}

define void @sys_mod.sys_mod.f_memcpyh2d() #2 !dbg !113 {
  %1 = alloca float, i16 1, align 4, !dbg !114
  %2 = alloca float, i16 1, align 4, !dbg !116
  %3 = alloca i16, i16 1, align 2, !dbg !117
  %4 = alloca i16, i16 1, align 2, !dbg !118
  %5 = alloca i16, i16 1, align 2, !dbg !119
  %6 = alloca i16, i16 1, align 2, !dbg !120
  %7 = alloca i16, i16 1, align 2, !dbg !121
  %8 = alloca i16, i16 1, align 2, !dbg !122
  %9 = alloca i16, i16 1, align 2, !dbg !123
  %10 = alloca i16, i16 1, align 2, !dbg !124
  %11 = alloca i16, i16 1, align 2, !dbg !125
  %12 = alloca i16, i16 1, align 2, !dbg !126
  %13 = alloca i16, i16 1, align 2, !dbg !127
  %14 = alloca i16*, i16 1, align 8, !dbg !128
  %15 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !129
  %16 = icmp eq i16 %15, 15, !dbg !130
  br i1 %16, label %17, label %18, !dbg !131

17:                                               ; preds = %0
  br label %19, !dbg !131

18:                                               ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !131
  br label %19, !dbg !131

19:                                               ; preds = %17, %18
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %14, align 8, !dbg !128
  %20 = load i16*, i16** %14, align 8, !dbg !132
  %21 = load i16, i16* %20, align 2, !dbg !133
  store i16 %21, i16* %13, align 2, !dbg !127
  %22 = load i16*, i16** %14, align 8, !dbg !134
  %23 = getelementptr i16, i16* %22, i16 1, !dbg !135
  %24 = load i16, i16* %23, align 2, !dbg !135
  store i16 %24, i16* %12, align 2, !dbg !126
  %25 = load i16*, i16** %14, align 8, !dbg !136
  %26 = getelementptr i16, i16* %25, i16 2, !dbg !137
  %27 = load i16, i16* %26, align 2, !dbg !137
  store i16 %27, i16* %11, align 2, !dbg !125
  %28 = load i16*, i16** %14, align 8, !dbg !138
  %29 = getelementptr i16, i16* %28, i16 3, !dbg !139
  %30 = load i16, i16* %29, align 2, !dbg !139
  store i16 %30, i16* %10, align 2, !dbg !124
  %31 = load i16*, i16** %14, align 8, !dbg !140
  %32 = getelementptr i16, i16* %31, i16 4, !dbg !141
  %33 = load i16, i16* %32, align 2, !dbg !141
  store i16 %33, i16* %9, align 2, !dbg !123
  %34 = load i16*, i16** %14, align 8, !dbg !142
  %35 = getelementptr i16, i16* %34, i16 5, !dbg !143
  %36 = load i16, i16* %35, align 2, !dbg !143
  store i16 %36, i16* %8, align 2, !dbg !122
  %37 = load i16*, i16** %14, align 8, !dbg !144
  %38 = getelementptr i16, i16* %37, i16 6, !dbg !145
  %39 = load i16, i16* %38, align 2, !dbg !145
  store i16 %39, i16* %7, align 2, !dbg !121
  %40 = load i16*, i16** %14, align 8, !dbg !146
  %41 = getelementptr i16, i16* %40, i16 7, !dbg !147
  %42 = load i16, i16* %41, align 2, !dbg !147
  store i16 %42, i16* %6, align 2, !dbg !120
  %43 = load i16*, i16** %14, align 8, !dbg !148
  %44 = getelementptr i16, i16* %43, i16 8, !dbg !149
  %45 = load i16, i16* %44, align 2, !dbg !149
  store i16 %45, i16* %5, align 2, !dbg !119
  %46 = load i16*, i16** %14, align 8, !dbg !150
  %47 = getelementptr i16, i16* %46, i16 9, !dbg !151
  %48 = load i16, i16* %47, align 2, !dbg !151
  store i16 %48, i16* %4, align 2, !dbg !118
  %49 = load i16*, i16** %14, align 8, !dbg !152
  %50 = getelementptr i16, i16* %49, i16 10, !dbg !153
  %51 = load i16, i16* %50, align 2, !dbg !153
  store i16 %51, i16* %3, align 2, !dbg !117
  %52 = load i16*, i16** %14, align 8, !dbg !154
  %53 = getelementptr i16, i16* %52, i16 12, !dbg !155
  %54 = load i16, i16* %53, align 2, !dbg !155
  %55 = zext i16 %54 to i32, !dbg !156
  %56 = load i16*, i16** %14, align 8, !dbg !157
  %57 = getelementptr i16, i16* %56, i16 11, !dbg !158
  %58 = load i16, i16* %57, align 2, !dbg !158
  %59 = zext i16 %58 to i32, !dbg !159
  %60 = add i32 %59, 16, !dbg !160
  %61 = shl i32 %55, %60, !dbg !161
  %62 = bitcast i32 %61 to float, !dbg !162
  store float %62, float* %2, align 4, !dbg !116
  %63 = load i16*, i16** %14, align 8, !dbg !163
  %64 = getelementptr i16, i16* %63, i16 14, !dbg !164
  %65 = load i16, i16* %64, align 2, !dbg !164
  %66 = zext i16 %65 to i32, !dbg !165
  %67 = load i16*, i16** %14, align 8, !dbg !166
  %68 = getelementptr i16, i16* %67, i16 13, !dbg !167
  %69 = load i16, i16* %68, align 2, !dbg !167
  %70 = zext i16 %69 to i32, !dbg !168
  %71 = add i32 %70, 16, !dbg !169
  %72 = shl i32 %66, %71, !dbg !170
  %73 = bitcast i32 %72 to float, !dbg !171
  store float %73, float* %1, align 4, !dbg !114
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !172
  %74 = load i16, i16* %13, align 2, !dbg !173
  store i16 %74, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !174
  %75 = load i16, i16* %12, align 2, !dbg !175
  store i16 %75, i16* @sys_mod.sys_mod.memcpyH2D_px, align 2, !dbg !176
  %76 = load i16, i16* %11, align 2, !dbg !177
  store i16 %76, i16* @sys_mod.sys_mod.memcpyH2D_py, align 2, !dbg !178
  %77 = load i16, i16* %10, align 2, !dbg !179
  store i16 %77, i16* @sys_mod.sys_mod.memcpyH2D_w, align 2, !dbg !180
  %78 = load i16, i16* %9, align 2, !dbg !181
  store i16 %78, i16* @sys_mod.sys_mod.memcpyH2D_h, align 2, !dbg !182
  %79 = load i16, i16* %8, align 2, !dbg !183
  store i16 %79, i16* @sys_mod.sys_mod.memcpyH2D_addr, align 2, !dbg !184
  %80 = load i16, i16* %7, align 2, !dbg !185
  store i16 %80, i16* @sys_mod.sys_mod.memcpyH2D_pe_length, align 2, !dbg !186
  %81 = load i16, i16* %6, align 2, !dbg !187
  store i16 %81, i16* @sys_mod.sys_mod.memcpyH2D_is_half, align 2, !dbg !188
  %82 = load i16, i16* %5, align 2, !dbg !189
  store i16 %82, i16* @sys_mod.sys_mod.memcpyH2D_memcpy_optype, align 2, !dbg !190
  %83 = load i16, i16* %4, align 2, !dbg !191
  store i16 %83, i16* @sys_mod.sys_mod.memcpyH2D_row_stride, align 2, !dbg !192
  %84 = load i16, i16* %3, align 2, !dbg !193
  store i16 %84, i16* @sys_mod.sys_mod.memcpyH2D_col_stride, align 2, !dbg !194
  %85 = load float, float* %2, align 4, !dbg !195
  store float %85, float* @sys_mod.sys_mod.memcpyH2D_one_over_row_stride, align 4, !dbg !196
  %86 = load float, float* %1, align 4, !dbg !197
  store float %86, float* @sys_mod.sys_mod.memcpyH2D_one_over_col_stride, align 4, !dbg !198
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !199
  call void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 0, i16 23, i1 true), !dbg !200
  call void @llvm.sdr.blk.r(i16 27), !dbg !201
  call void @llvm.sdr.oqflush(i16 0), !dbg !202
  store i1 true, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !203
  call void @llvm.sdr.blk.r(i16 0), !dbg !204
  ret void, !dbg !205
}

define void @sys_mod.sys_mod.f_memcpyd2h() #3 !dbg !206 {
  %1 = alloca i16, i16 1, align 2, !dbg !207
  %2 = alloca i16, i16 1, align 2, !dbg !209
  %3 = alloca i16, i16 1, align 2, !dbg !210
  %4 = alloca i16, i16 1, align 2, !dbg !211
  %5 = alloca i16, i16 1, align 2, !dbg !212
  %6 = alloca i16, i16 1, align 2, !dbg !213
  %7 = alloca i16, i16 1, align 2, !dbg !214
  %8 = alloca i16, i16 1, align 2, !dbg !215
  %9 = alloca i16*, i16 1, align 8, !dbg !216
  %10 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !217
  %11 = icmp eq i16 %10, 8, !dbg !218
  br i1 %11, label %12, label %13, !dbg !219

12:                                               ; preds = %0
  br label %14, !dbg !219

13:                                               ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !219
  br label %14, !dbg !219

14:                                               ; preds = %12, %13
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %9, align 8, !dbg !216
  %15 = load i16*, i16** %9, align 8, !dbg !220
  %16 = load i16, i16* %15, align 2, !dbg !221
  store i16 %16, i16* %8, align 2, !dbg !215
  %17 = load i16*, i16** %9, align 8, !dbg !222
  %18 = getelementptr i16, i16* %17, i16 1, !dbg !223
  %19 = load i16, i16* %18, align 2, !dbg !223
  store i16 %19, i16* %7, align 2, !dbg !214
  %20 = load i16*, i16** %9, align 8, !dbg !224
  %21 = getelementptr i16, i16* %20, i16 2, !dbg !225
  %22 = load i16, i16* %21, align 2, !dbg !225
  store i16 %22, i16* %6, align 2, !dbg !213
  %23 = load i16*, i16** %9, align 8, !dbg !226
  %24 = getelementptr i16, i16* %23, i16 3, !dbg !227
  %25 = load i16, i16* %24, align 2, !dbg !227
  store i16 %25, i16* %5, align 2, !dbg !212
  %26 = load i16*, i16** %9, align 8, !dbg !228
  %27 = getelementptr i16, i16* %26, i16 4, !dbg !229
  %28 = load i16, i16* %27, align 2, !dbg !229
  store i16 %28, i16* %4, align 2, !dbg !211
  %29 = load i16*, i16** %9, align 8, !dbg !230
  %30 = getelementptr i16, i16* %29, i16 5, !dbg !231
  %31 = load i16, i16* %30, align 2, !dbg !231
  store i16 %31, i16* %3, align 2, !dbg !210
  %32 = load i16*, i16** %9, align 8, !dbg !232
  %33 = getelementptr i16, i16* %32, i16 6, !dbg !233
  %34 = load i16, i16* %33, align 2, !dbg !233
  store i16 %34, i16* %2, align 2, !dbg !209
  %35 = load i16*, i16** %9, align 8, !dbg !234
  %36 = getelementptr i16, i16* %35, i16 7, !dbg !235
  %37 = load i16, i16* %36, align 2, !dbg !235
  store i16 %37, i16* %1, align 2, !dbg !207
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !236
  %38 = load i16, i16* %8, align 2, !dbg !237
  store i16 %38, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !238
  %39 = load i16, i16* %7, align 2, !dbg !239
  store i16 %39, i16* @sys_mod.sys_mod.memcpyD2H_px, align 2, !dbg !240
  %40 = load i16, i16* %6, align 2, !dbg !241
  store i16 %40, i16* @sys_mod.sys_mod.memcpyD2H_py, align 2, !dbg !242
  %41 = load i16, i16* %5, align 2, !dbg !243
  store i16 %41, i16* @sys_mod.sys_mod.memcpyD2H_w, align 2, !dbg !244
  %42 = load i16, i16* %4, align 2, !dbg !245
  store i16 %42, i16* @sys_mod.sys_mod.memcpyD2H_h, align 2, !dbg !246
  %43 = load i16, i16* %3, align 2, !dbg !247
  store i16 %43, i16* @sys_mod.sys_mod.memcpyD2H_addr, align 2, !dbg !248
  %44 = load i16, i16* %2, align 2, !dbg !249
  store i16 %44, i16* @sys_mod.sys_mod.memcpyD2H_pe_length, align 2, !dbg !250
  %45 = load i16, i16* %1, align 2, !dbg !251
  store i16 %45, i16* @sys_mod.sys_mod.memcpyD2H_is_half, align 2, !dbg !252
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !253
  %46 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !254
  call void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 0, i16 %46, i1 false), !dbg !255
  call void @llvm.sdr.oqflush(i16 0), !dbg !256
  store i1 false, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !257
  ret void, !dbg !258
}

define internal void @sys_mod.sys_mod.oq0_teardow_handler() !dbg !259 {
  %1 = load i1, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !260
  br i1 %1, label %2, label %17, !dbg !262

2:                                                ; preds = %0
  %3 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !263
  call void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 0, i16 %3), !dbg !264
  %4 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !265
  %5 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_px, align 2, !dbg !266
  %6 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_py, align 2, !dbg !267
  %7 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_w, align 2, !dbg !268
  %8 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_h, align 2, !dbg !269
  %9 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_addr, align 2, !dbg !270
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_pe_length, align 2, !dbg !271
  %11 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_is_half, align 2, !dbg !272
  %12 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_memcpy_optype, align 2, !dbg !273
  %13 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_row_stride, align 2, !dbg !274
  %14 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_col_stride, align 2, !dbg !275
  %15 = load float, float* @sys_mod.sys_mod.memcpyH2D_one_over_row_stride, align 4, !dbg !276
  %16 = load float, float* @sys_mod.sys_mod.memcpyH2D_one_over_col_stride, align 4, !dbg !277
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure(i16 %4, i16 %5, i16 %6, i16 %7, i16 %8, i16 %9, i16 %10, i16 %11, i16 %12, i16 %13, i16 %14, float %15, float %16), !dbg !278
  br label %26, !dbg !262

17:                                               ; preds = %0
  call void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 0, i16 21), !dbg !279
  %18 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !280
  %19 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_px, align 2, !dbg !281
  %20 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_py, align 2, !dbg !282
  %21 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_w, align 2, !dbg !283
  %22 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_h, align 2, !dbg !284
  %23 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_addr, align 2, !dbg !285
  %24 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_pe_length, align 2, !dbg !286
  %25 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_is_half, align 2, !dbg !287
  call void @sys_mod.sys_mod.memcpyd2h_mod.d2h_configure(i16 %18, i16 %19, i16 %20, i16 %21, i16 %22, i16 %23, i16 %24, i16 %25), !dbg !288
  br label %26, !dbg !262

26:                                               ; preds = %2, %17
  call void @__generic0sys_mod.sys_mod.tile_config.queue_flush.exit(), !dbg !289
  ret void, !dbg !262
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

define void @sys_mod.sys_mod.f_rpc(i16 %0) #4 !dbg !290 {
  %2 = alloca i16, i16 1, align 2, !dbg !291
  store i16 %0, i16* %2, align 2, !dbg !291
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !293
  %3 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !294
  %4 = icmp sge i16 %3, 4, !dbg !295
  br i1 %4, label %5, label %6, !dbg !296

5:                                                ; preds = %1
  br label %7, !dbg !296

6:                                                ; preds = %1
  call void asm sideeffect "hcf", ""(), !dbg !296
  br label %7, !dbg !296

7:                                                ; preds = %5, %6
  call void @rpc_server(i32* getelementptr inbounds ([32 x i32], [32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32, i32 0, i32 0)), !dbg !297
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !298
  ret void, !dbg !299
}

define internal void @sys_mod.sys_mod.sys_mod.stack_push(i16 %0) !dbg !300 {
  %2 = alloca i16*, i16 1, align 8, !dbg !302
  %3 = alloca i16, i16 1, align 2, !dbg !304
  store i16 %0, i16* %3, align 2, !dbg !304
  %4 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !305
  %5 = icmp slt i16 %4, 32, !dbg !306
  br i1 %5, label %6, label %7, !dbg !307

6:                                                ; preds = %1
  br label %8, !dbg !307

7:                                                ; preds = %1
  call void asm sideeffect "hcf", ""(), !dbg !307
  br label %8, !dbg !307

8:                                                ; preds = %6, %7
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %2, align 8, !dbg !302
  %9 = load i16, i16* %3, align 2, !dbg !308
  %10 = load i16*, i16** %2, align 8, !dbg !309
  %11 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !310
  %12 = getelementptr i16, i16* %10, i16 %11, !dbg !311
  store i16 %9, i16* %12, align 2, !dbg !312
  %13 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !313
  %14 = add i16 %13, 1, !dbg !314
  store i16 %14, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !315
  ret void, !dbg !316
}

define void @sys_mod.sys_mod.sys_mod.f_push(i16 %0, i16 %1) #5 !dbg !317 {
  %3 = alloca i16, i16 1, align 2, !dbg !318
  %4 = alloca i16, i16 1, align 2, !dbg !320
  store i16 %0, i16* %4, align 2, !dbg !320
  store i16 %1, i16* %3, align 2, !dbg !318
  %5 = load i16, i16* %4, align 2, !dbg !321
  call void @sys_mod.sys_mod.sys_mod.stack_push(i16 %5), !dbg !322
  ret void, !dbg !323
}

define internal void @sys_mod.sys_mod.sys_mod.block_cmd_stream() !dbg !324 {
  call void @llvm.sdr.blk.r(i16 1), !dbg !325
  ret void, !dbg !327
}

define internal void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream() !dbg !328 {
  call void @llvm.sdr.ublk.r(i16 1), !dbg !329
  ret void, !dbg !331
}

define void @sys_mod.sys_mod.sys_mod.f_sys_exit() #6 !dbg !332 {
  call void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream(), !dbg !333
  call void @sys_mod.sys_nop(), !dbg !335
  ret void, !dbg !336
}

define void @sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore(i32 %0) #7 !dbg !337 {
  %2 = alloca i32, i16 1, align 4, !dbg !338
  store i32 %0, i32* %2, align 4, !dbg !338
  ret void, !dbg !340
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord() !dbg !341 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord(), !dbg !343
  ret i16 %1, !dbg !345
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord() !dbg !346 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord(), !dbg !347
  ret i16 %1, !dbg !349
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval(i16 %0) !dbg !350 {
  %2 = alloca i16, i16 1, align 2, !dbg !351
  store i16 %0, i16* %2, align 2, !dbg !351
  %3 = load i16, i16* %2, align 2, !dbg !353
  %4 = icmp ult i16 %3, 24, !dbg !354
  br i1 %4, label %5, label %7, !dbg !355

5:                                                ; preds = %10, %11, %1
  %6 = phi i16 [ 0, %10 ], [ 0, %11 ], [ 1, %1 ]
  br label %12, !dbg !355

7:                                                ; preds = %1
  %8 = load i16, i16* %2, align 2, !dbg !356
  %9 = icmp eq i16 31, %8, !dbg !357
  br i1 %9, label %10, label %11, !dbg !358

10:                                               ; preds = %7
  br label %5, !dbg !358

11:                                               ; preds = %7
  call void asm sideeffect "hcf", ""(), !dbg !358
  br label %5, !dbg !358

12:                                               ; preds = %5
  %13 = phi i16 [ %6, %5 ]
  br label %14, !dbg !355

14:                                               ; preds = %12
  ret i16 %13, !dbg !355
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start(i16 %0, i16 %1, i16 %2) !dbg !359 {
  %4 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !360
  %5 = alloca i16, i16 1, align 2, !dbg !362
  %6 = alloca i16, i16 1, align 2, !dbg !363
  %7 = alloca i16, i16 1, align 2, !dbg !364
  store i16 %0, i16* %7, align 2, !dbg !364
  store i16 %1, i16* %6, align 2, !dbg !363
  store i16 %2, i16* %5, align 2, !dbg !362
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !365
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !365
  %10 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !365
  %11 = load i16, i16* %6, align 2, !dbg !366
  store i16 %11, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !367
  store i16 %8, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !367
  store i16 %9, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !367
  store i16 %10, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !367
  %12 = load i16, i16* %7, align 2, !dbg !368
  %13 = call i16* @.get_tensor_ptr(i16 %12), !dbg !369
  %14 = ptrtoint i16* %13 to i16, !dbg !370
  %15 = lshr i16 %14, 1, !dbg !370
  %16 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !360
  store i16 42, i16* %16, align 2, !dbg !360
  %17 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !360
  store i16 %15, i16* %17, align 2, !dbg !360
  %18 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !360
  store i16 143, i16* %18, align 2, !dbg !360
  %19 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !360
  store i16 16, i16* %19, align 2, !dbg !360
  %20 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !371
  %21 = load i16, i16* %20, align 2, !dbg !371
  %22 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !371
  %23 = load i16, i16* %22, align 2, !dbg !371
  %24 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !371
  %25 = load i16, i16* %24, align 2, !dbg !371
  %26 = load i16, i16* %6, align 2, !dbg !372
  %27 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !373
  store i16 %26, i16* %27, align 2, !dbg !373
  %28 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !373
  store i16 %21, i16* %28, align 2, !dbg !373
  %29 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !373
  store i16 %23, i16* %29, align 2, !dbg !373
  %30 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !373
  store i16 %25, i16* %30, align 2, !dbg !373
  %31 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !374
  %32 = load i16, i16* %31, align 2, !dbg !374
  %33 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !374
  %34 = load i16, i16* %33, align 2, !dbg !374
  %35 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !374
  %36 = load i16, i16* %35, align 2, !dbg !374
  %37 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !374
  %38 = load i16, i16* %37, align 2, !dbg !374
  store volatile i16 %32, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !375
  store volatile i16 %34, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !375
  store volatile i16 %36, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !375
  store volatile i16 %38, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !375
  call void asm sideeffect "nop", ""(), !dbg !375
  call void asm sideeffect "nop", ""(), !dbg !375
  %39 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !376
  %40 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !376
  %41 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !376
  %42 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !376
  %43 = and i16 %41, -193, !dbg !376
  %44 = or i16 %43, 128, !dbg !376
  %45 = and i16 %40, -64, !dbg !376
  %46 = or i16 %45, 27, !dbg !376
  store volatile i16 %39, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !377
  store volatile i16 %46, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !377
  store volatile i16 %44, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !377
  store volatile i16 %42, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !377
  call void asm sideeffect "nop", ""(), !dbg !377
  call void asm sideeffect "nop", ""(), !dbg !377
  %47 = load i16, i16* %5, align 2, !dbg !378
  %48 = icmp ult i16 0, %47, !dbg !379
  br i1 %48, label %49, label %50, !dbg !380

49:                                               ; preds = %3
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !381
  br label %51, !dbg !380

50:                                               ; preds = %3
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !382
  br label %51, !dbg !380

51:                                               ; preds = %49, %50
  ret void, !dbg !380
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream() !dbg !383 {
  call void @llvm.sdr.ublk.r(i16 1), !dbg !384
  ret void, !dbg !386
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7, i16 %8, i16 %9, i16 %10, float %11, float %12) !dbg !387 {
  %14 = alloca i16, i16 1, align 2, !dbg !388
  %15 = alloca i16, i16 1, align 2, !dbg !390
  %16 = alloca i16, i16 1, align 2, !dbg !391
  %17 = alloca i16, i16 1, align 2, !dbg !392
  %18 = alloca i16, i16 1, align 2, !dbg !393
  %19 = alloca i1, i16 1, align 1, !dbg !394
  %20 = alloca i16, i16 1, align 2, !dbg !395
  %21 = alloca i16, i16 1, align 2, !dbg !396
  %22 = alloca i16, i16 1, align 2, !dbg !397
  %23 = alloca i16, i16 1, align 2, !dbg !398
  %24 = alloca i16, i16 1, align 2, !dbg !399
  %25 = alloca float, i16 1, align 4, !dbg !400
  %26 = alloca float, i16 1, align 4, !dbg !401
  %27 = alloca i16, i16 1, align 2, !dbg !402
  %28 = alloca i16, i16 1, align 2, !dbg !403
  %29 = alloca i16, i16 1, align 2, !dbg !404
  %30 = alloca i16, i16 1, align 2, !dbg !405
  %31 = alloca i16, i16 1, align 2, !dbg !406
  %32 = alloca i16, i16 1, align 2, !dbg !407
  %33 = alloca i16, i16 1, align 2, !dbg !408
  %34 = alloca i16, i16 1, align 2, !dbg !409
  %35 = alloca i16, i16 1, align 2, !dbg !410
  %36 = alloca i16, i16 1, align 2, !dbg !411
  %37 = alloca i16, i16 1, align 2, !dbg !412
  store i16 %0, i16* %37, align 2, !dbg !412
  store i16 %1, i16* %36, align 2, !dbg !411
  store i16 %2, i16* %35, align 2, !dbg !410
  store i16 %3, i16* %34, align 2, !dbg !409
  store i16 %4, i16* %33, align 2, !dbg !408
  store i16 %5, i16* %32, align 2, !dbg !407
  store i16 %6, i16* %31, align 2, !dbg !406
  store i16 %7, i16* %30, align 2, !dbg !405
  store i16 %8, i16* %29, align 2, !dbg !404
  store i16 %9, i16* %28, align 2, !dbg !403
  store i16 %10, i16* %27, align 2, !dbg !402
  store float %11, float* %26, align 4, !dbg !401
  store float %12, float* %25, align 4, !dbg !400
  %38 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord(), !dbg !413
  store i16 %38, i16* %24, align 2, !dbg !399
  %39 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord(), !dbg !414
  store i16 %39, i16* %23, align 2, !dbg !398
  %40 = load i16, i16* %24, align 2, !dbg !415
  %41 = load i16, i16* %36, align 2, !dbg !416
  %42 = sub i16 %40, %41, !dbg !417
  store i16 %42, i16* %22, align 2, !dbg !397
  %43 = load i16, i16* %22, align 2, !dbg !418
  store i16 %43, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !419
  %44 = load i16, i16* %29, align 2, !dbg !420
  %45 = icmp eq i16 3, %44, !dbg !421
  br i1 %45, label %46, label %63, !dbg !422

46:                                               ; preds = %13
  %47 = load i16, i16* %22, align 2, !dbg !423
  %48 = sitofp i16 %47 to float, !dbg !424
  %49 = load float, float* %26, align 4, !dbg !425
  %50 = fmul float %48, %49, !dbg !426
  %51 = fptosi float %50 to i16, !dbg !427
  store i16 %51, i16* %21, align 2, !dbg !396
  %52 = load i16, i16* %22, align 2, !dbg !428
  %53 = load i16, i16* %21, align 2, !dbg !429
  %54 = load i16, i16* %28, align 2, !dbg !430
  %55 = mul i16 %53, %54, !dbg !431
  %56 = sub i16 %52, %55, !dbg !432
  store i16 %56, i16* %20, align 2, !dbg !395
  %57 = load i16, i16* %20, align 2, !dbg !433
  %58 = icmp ne i16 0, %57, !dbg !434
  br i1 %58, label %59, label %60, !dbg !435

59:                                               ; preds = %46
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !436
  br label %62, !dbg !435

60:                                               ; preds = %46
  %61 = load i16, i16* %21, align 2, !dbg !437
  store i16 %61, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !438
  br label %62, !dbg !435

62:                                               ; preds = %59, %60
  br label %63, !dbg !422

63:                                               ; preds = %62, %13
  %64 = load i16, i16* %22, align 2, !dbg !439
  %65 = icmp slt i16 %64, 0, !dbg !440
  br i1 %65, label %66, label %67, !dbg !441

66:                                               ; preds = %63
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !442
  br label %67, !dbg !441

67:                                               ; preds = %66, %63
  %68 = load i16, i16* %22, align 2, !dbg !443
  %69 = load i16, i16* %34, align 2, !dbg !444
  %70 = icmp sge i16 %68, %69, !dbg !445
  br i1 %70, label %71, label %72, !dbg !446

71:                                               ; preds = %67
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !447
  br label %72, !dbg !446

72:                                               ; preds = %71, %67
  store i1 false, i1* %19, align 1, !dbg !394
  %73 = load i16, i16* %29, align 2, !dbg !448
  %74 = icmp eq i16 3, %73, !dbg !449
  br i1 %74, label %75, label %94, !dbg !450

75:                                               ; preds = %72
  %76 = load i16, i16* %23, align 2, !dbg !451
  %77 = load i16, i16* %35, align 2, !dbg !452
  %78 = sub i16 %76, %77, !dbg !453
  %79 = sitofp i16 %78 to float, !dbg !454
  %80 = load float, float* %25, align 4, !dbg !455
  %81 = fmul float %79, %80, !dbg !456
  %82 = fptosi float %81 to i16, !dbg !457
  store i16 %82, i16* %18, align 2, !dbg !393
  %83 = load i16, i16* %23, align 2, !dbg !458
  %84 = load i16, i16* %35, align 2, !dbg !459
  %85 = sub i16 %83, %84, !dbg !460
  %86 = load i16, i16* %18, align 2, !dbg !461
  %87 = load i16, i16* %27, align 2, !dbg !462
  %88 = mul i16 %86, %87, !dbg !463
  %89 = sub i16 %85, %88, !dbg !464
  store i16 %89, i16* %17, align 2, !dbg !392
  %90 = load i16, i16* %17, align 2, !dbg !465
  %91 = icmp ne i16 0, %90, !dbg !466
  br i1 %91, label %92, label %93, !dbg !467

92:                                               ; preds = %75
  store i1 true, i1* %19, align 1, !dbg !468
  br label %93, !dbg !467

93:                                               ; preds = %92, %75
  br label %94, !dbg !450

94:                                               ; preds = %93, %72
  %95 = load i16, i16* %23, align 2, !dbg !469
  %96 = load i16, i16* %35, align 2, !dbg !470
  %97 = icmp slt i16 %95, %96, !dbg !471
  br i1 %97, label %98, label %99, !dbg !472

98:                                               ; preds = %94
  store i1 true, i1* %19, align 1, !dbg !473
  br label %99, !dbg !472

99:                                               ; preds = %98, %94
  %100 = load i16, i16* %23, align 2, !dbg !474
  %101 = load i16, i16* %35, align 2, !dbg !475
  %102 = load i16, i16* %33, align 2, !dbg !476
  %103 = add i16 %101, %102, !dbg !477
  %104 = icmp sge i16 %100, %103, !dbg !478
  br i1 %104, label %105, label %106, !dbg !479

105:                                              ; preds = %99
  store i1 true, i1* %19, align 1, !dbg !480
  br label %106, !dbg !479

106:                                              ; preds = %105, %99
  %107 = load i1, i1* %19, align 1, !dbg !481
  br i1 %107, label %108, label %109, !dbg !482

108:                                              ; preds = %106
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream(), !dbg !483
  call void @llvm.sdr.ublk.r(i16 27), !dbg !484
  br label %180, !dbg !482

109:                                              ; preds = %106
  %110 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !485
  %111 = icmp eq i16 -1, %110, !dbg !486
  br i1 %111, label %112, label %113, !dbg !487

112:                                              ; preds = %109
  call void @__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction(i16 31767), !dbg !488
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 23), !dbg !489
  call void @llvm.sdr.ublk.r(i16 27), !dbg !490
  br label %179, !dbg !487

113:                                              ; preds = %109
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter(i16 0, i16 0), !dbg !491
  %114 = load i16, i16* %34, align 2, !dbg !492
  store i16 %114, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !493
  %115 = load i16, i16* %29, align 2, !dbg !494
  %116 = icmp eq i16 3, %115, !dbg !495
  br i1 %116, label %117, label %126, !dbg !496

117:                                              ; preds = %113
  %118 = load i16, i16* %34, align 2, !dbg !497
  %119 = sub i16 %118, 1, !dbg !498
  %120 = sitofp i16 %119 to float, !dbg !499
  %121 = load float, float* %26, align 4, !dbg !500
  %122 = fmul float %120, %121, !dbg !501
  %123 = fptosi float %122 to i16, !dbg !502
  %124 = add i16 %123, 1, !dbg !503
  store i16 %124, i16* %16, align 2, !dbg !391
  %125 = load i16, i16* %16, align 2, !dbg !504
  store i16 %125, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !505
  br label %131, !dbg !496

126:                                              ; preds = %113
  %127 = load i16, i16* %29, align 2, !dbg !506
  %128 = icmp eq i16 1, %127, !dbg !507
  br i1 %128, label %129, label %130, !dbg !508

129:                                              ; preds = %126
  store i16 1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !509
  br label %130, !dbg !508

130:                                              ; preds = %129, %126
  br label %131, !dbg !496

131:                                              ; preds = %117, %130
  %132 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !510
  %133 = sub i16 %132, 1, !dbg !511
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit(i16 0, i16 %133), !dbg !512
  %134 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !513
  store i16 %134, i16* %15, align 2, !dbg !390
  %135 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !514
  store i16 %135, i16* %14, align 2, !dbg !388
  %136 = load i16, i16* %15, align 2, !dbg !515
  %137 = load i16, i16* %14, align 2, !dbg !516
  %138 = sub i16 %136, %137, !dbg !517
  store i16 %138, i16* %15, align 2, !dbg !518
  %139 = load i16, i16* %14, align 2, !dbg !519
  %140 = icmp eq i16 0, %139, !dbg !520
  br i1 %140, label %141, label %142, !dbg !521

141:                                              ; preds = %131
  store i16 0, i16* %15, align 2, !dbg !522
  br label %142, !dbg !521

142:                                              ; preds = %141, %131
  %143 = load i16, i16* %29, align 2, !dbg !523
  %144 = icmp eq i16 1, %143, !dbg !524
  br i1 %144, label %145, label %146, !dbg !525

145:                                              ; preds = %142
  store i16 0, i16* %15, align 2, !dbg !526
  br label %146, !dbg !525

146:                                              ; preds = %145, %142
  %147 = load i16, i16* %15, align 2, !dbg !527
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter(i16 0, i16 %147), !dbg !528
  call void @__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction(i16 31767), !dbg !529
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 23), !dbg !530
  %148 = load i16, i16* %37, align 2, !dbg !531
  %149 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval(i16 %148), !dbg !532
  %150 = icmp eq i16 0, %149, !dbg !533
  br i1 %150, label %151, label %155, !dbg !534

151:                                              ; preds = %146
  %152 = load i16, i16* %32, align 2, !dbg !535
  %153 = load i16, i16* %31, align 2, !dbg !536
  %154 = load i16, i16* %30, align 2, !dbg !537
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start(i16 %152, i16 %153, i16 %154), !dbg !538
  br label %178, !dbg !534

155:                                              ; preds = %146
  %156 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !539
  %157 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !539
  %158 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !539
  %159 = load i16, i16* %31, align 2, !dbg !540
  store i16 %159, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !541
  store i16 %156, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !541
  store i16 %157, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !541
  store i16 %158, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !541
  %160 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !542
  %161 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !542
  %162 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !542
  %163 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !542
  %164 = and i16 %162, -193, !dbg !542
  %165 = or i16 %164, 128, !dbg !542
  store volatile i16 %160, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !543
  store volatile i16 %161, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !543
  store volatile i16 %165, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !543
  store volatile i16 %163, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !543
  call void asm sideeffect "nop", ""(), !dbg !543
  call void asm sideeffect "nop", ""(), !dbg !543
  %166 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !544
  %167 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !544
  %168 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !544
  %169 = load i16, i16* %31, align 2, !dbg !545
  store i16 %169, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !546
  store i16 %166, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !546
  store i16 %167, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !546
  store i16 %168, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !546
  %170 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !547
  %171 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !547
  %172 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !547
  %173 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !547
  %174 = and i16 %172, -193, !dbg !547
  %175 = or i16 %174, 128, !dbg !547
  %176 = and i16 %171, -64, !dbg !547
  %177 = or i16 %176, 27, !dbg !547
  store volatile i16 %170, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !548
  store volatile i16 %177, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !548
  store volatile i16 %175, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !548
  store volatile i16 %173, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !548
  call void asm sideeffect "nop", ""(), !dbg !548
  call void asm sideeffect "nop", ""(), !dbg !548
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !549
  br label %178, !dbg !534

178:                                              ; preds = %151, %155
  br label %179, !dbg !487

179:                                              ; preds = %112, %178
  br label %180, !dbg !482

180:                                              ; preds = %108, %179
  ret void, !dbg !422
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit(i16 %0, i16 %1) !dbg !550 {
  %3 = alloca i16, i16 1, align 2, !dbg !552
  %4 = alloca i16, i16 1, align 2, !dbg !554
  %5 = alloca i16, i16 1, align 2, !dbg !555
  %6 = alloca i16, i16 1, align 2, !dbg !556
  %7 = alloca i16, i16 1, align 2, !dbg !557
  %8 = alloca i16, i16 1, align 2, !dbg !558
  store i16 %0, i16* %8, align 2, !dbg !558
  store i16 %1, i16* %7, align 2, !dbg !557
  %9 = load i16, i16* %7, align 2, !dbg !559
  %10 = icmp ult i16 %9, -32768, !dbg !560
  br i1 %10, label %11, label %12, !dbg !561

11:                                               ; preds = %2
  br label %13, !dbg !561

12:                                               ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !561
  br label %13, !dbg !561

13:                                               ; preds = %11, %12
  %14 = load i16, i16* %7, align 2, !dbg !562
  %15 = mul i16 %14, 2, !dbg !563
  store i16 %15, i16* %6, align 2, !dbg !556
  %16 = load i16, i16* %8, align 2, !dbg !564
  %17 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %16, i16 8), !dbg !565
  %18 = sub i16 %17, 1, !dbg !566
  store i16 %18, i16* %5, align 2, !dbg !555
  %19 = load i16, i16* %6, align 2, !dbg !567
  %20 = load i16, i16* %5, align 2, !dbg !568
  %21 = icmp ult i16 %19, %20, !dbg !569
  br i1 %21, label %22, label %23, !dbg !554

22:                                               ; preds = %13
  store i16 0, i16* %4, align 2, !dbg !554
  br label %27, !dbg !554

23:                                               ; preds = %13
  %24 = load i16, i16* %6, align 2, !dbg !570
  %25 = load i16, i16* %5, align 2, !dbg !571
  %26 = sub i16 %24, %25, !dbg !572
  store i16 %26, i16* %4, align 2, !dbg !554
  br label %27, !dbg !554

27:                                               ; preds = %22, %23
  %28 = load i16, i16* %4, align 2, !dbg !554
  store i16 %28, i16* %3, align 2, !dbg !552
  %29 = load i16, i16* %8, align 2, !dbg !573
  %30 = load i16, i16* %3, align 2, !dbg !574
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %29, i16 4, i16 %30), !dbg !575
  ret void, !dbg !554
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter(i16 %0, i16 %1) !dbg !576 {
  %3 = alloca i16, i16 1, align 2, !dbg !577
  %4 = alloca i16, i16 1, align 2, !dbg !579
  store i16 %0, i16* %4, align 2, !dbg !579
  store i16 %1, i16* %3, align 2, !dbg !577
  %5 = load i16, i16* %3, align 2, !dbg !580
  %6 = icmp ult i16 %5, -32768, !dbg !581
  br i1 %6, label %7, label %8, !dbg !582

7:                                                ; preds = %2
  br label %9, !dbg !582

8:                                                ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !582
  br label %9, !dbg !582

9:                                                ; preds = %7, %8
  %10 = load i16, i16* %4, align 2, !dbg !583
  %11 = load i16, i16* %3, align 2, !dbg !584
  %12 = mul i16 %11, 2, !dbg !585
  %13 = add i16 %12, 1, !dbg !586
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %10, i16 8, i16 %13), !dbg !587
  ret void, !dbg !588
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter(i16 %0, i16 %1) !dbg !589 {
  %3 = alloca i16, i16 1, align 2, !dbg !590
  %4 = alloca i16, i16 1, align 2, !dbg !592
  %5 = alloca i1, i16 1, align 1, !dbg !593
  %6 = alloca i16, i16 1, align 2, !dbg !594
  %7 = alloca i16, i16 1, align 2, !dbg !595
  %8 = alloca i16, i16 1, align 2, !dbg !596
  %9 = alloca i16, i16 1, align 2, !dbg !597
  store i16 %0, i16* %9, align 2, !dbg !597
  store i16 %1, i16* %8, align 2, !dbg !596
  %10 = load i16, i16* %8, align 2, !dbg !598
  %11 = icmp ult i16 %10, -32768, !dbg !599
  br i1 %11, label %12, label %13, !dbg !600

12:                                               ; preds = %2
  br label %14, !dbg !600

13:                                               ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !600
  br label %14, !dbg !600

14:                                               ; preds = %12, %13
  %15 = load i16, i16* %9, align 2, !dbg !601
  %16 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %15, i16 8), !dbg !602
  store i16 %16, i16* %7, align 2, !dbg !595
  %17 = load i16, i16* %8, align 2, !dbg !603
  %18 = mul i16 %17, 2, !dbg !604
  store i16 %18, i16* %6, align 2, !dbg !594
  %19 = load i16, i16* %6, align 2, !dbg !605
  %20 = load i16, i16* %7, align 2, !dbg !606
  %21 = icmp ugt i16 %19, %20, !dbg !607
  store i1 %21, i1* %5, align 1, !dbg !593
  %22 = load i16, i16* %9, align 2, !dbg !608
  %23 = load i1, i1* %5, align 1, !dbg !609
  %24 = zext i1 %23 to i16, !dbg !610
  %25 = shl i16 %24, 6, !dbg !611
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %22, i16 14, i16 %25), !dbg !612
  %26 = load i1, i1* %5, align 1, !dbg !613
  br i1 %26, label %27, label %32, !dbg !592

27:                                               ; preds = %14
  %28 = load i16, i16* %6, align 2, !dbg !614
  %29 = load i16, i16* %7, align 2, !dbg !615
  %30 = sub i16 %28, %29, !dbg !616
  %31 = add i16 %30, 1, !dbg !617
  store i16 %31, i16* %4, align 2, !dbg !592
  br label %34, !dbg !592

32:                                               ; preds = %14
  %33 = load i16, i16* %6, align 2, !dbg !618
  store i16 %33, i16* %4, align 2, !dbg !592
  br label %34, !dbg !592

34:                                               ; preds = %27, %32
  %35 = load i16, i16* %4, align 2, !dbg !592
  store i16 %35, i16* %3, align 2, !dbg !590
  %36 = load i16, i16* %9, align 2, !dbg !619
  %37 = load i16, i16* %3, align 2, !dbg !620
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %36, i16 12, i16 %37), !dbg !621
  ret void, !dbg !592
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %0, i16 %1, i16 %2) !dbg !622 {
  %4 = alloca i16, i16 1, align 2, !dbg !624
  %5 = alloca i16, i16 1, align 2, !dbg !626
  %6 = alloca i16, i16 1, align 2, !dbg !627
  store i16 %0, i16* %6, align 2, !dbg !627
  store i16 %1, i16* %5, align 2, !dbg !626
  store i16 %2, i16* %4, align 2, !dbg !624
  %7 = load i16, i16* %6, align 2, !dbg !628
  %8 = getelementptr [6 x i16], [6 x i16]* @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.filters, i16 0, i16 %7, !dbg !629
  %9 = load i16, i16* %8, align 2, !dbg !629
  %10 = load i16, i16* %5, align 2, !dbg !630
  %11 = add i16 %9, %10, !dbg !631
  %12 = lshr i16 %11, 1, !dbg !632
  %13 = load i16, i16* %4, align 2, !dbg !633
  %14 = shl i16 %12, 1, !dbg !634
  %15 = inttoptr i16 %14 to i16*, !dbg !634
  store volatile i16 %13, i16* %15, align 2, !dbg !634
  call void asm sideeffect "nop", ""(), !dbg !634
  call void asm sideeffect "nop", ""(), !dbg !634
  ret void, !dbg !635
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %0, i16 %1) !dbg !636 {
  %3 = alloca i16, i16 1, align 2, !dbg !637
  %4 = alloca i16, i16 1, align 2, !dbg !639
  store i16 %0, i16* %4, align 2, !dbg !639
  store i16 %1, i16* %3, align 2, !dbg !637
  %5 = load i16, i16* %4, align 2, !dbg !640
  %6 = getelementptr [6 x i16], [6 x i16]* @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.filters, i16 0, i16 %5, !dbg !641
  %7 = load i16, i16* %6, align 2, !dbg !641
  %8 = load i16, i16* %3, align 2, !dbg !642
  %9 = add i16 %7, %8, !dbg !643
  %10 = lshr i16 %9, 1, !dbg !644
  %11 = shl i16 %10, 1, !dbg !645
  %12 = inttoptr i16 %11 to i16*, !dbg !645
  call void asm sideeffect "nop", ""(), !dbg !645
  call void asm sideeffect "nop", ""(), !dbg !645
  %13 = load volatile i16, i16* %12, align 2, !dbg !645
  ret i16 %13, !dbg !646
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 %0) !dbg !647 {
  %2 = alloca i16, i16 1, align 2, !dbg !649
  %3 = alloca i16, i16 1, align 2, !dbg !651
  %4 = alloca i16, i16 1, align 2, !dbg !652
  %5 = alloca i16, i16 1, align 2, !dbg !653
  store i16 %0, i16* %5, align 2, !dbg !653
  %6 = load i16, i16* %5, align 2, !dbg !654
  store i16 %6, i16* %4, align 2, !dbg !652
  %7 = load i16, i16* %4, align 2, !dbg !655
  %8 = add i16 %7, 31744, !dbg !656
  store i16 %8, i16* %3, align 2, !dbg !651
  %9 = load i16, i16* %3, align 2, !dbg !657
  %10 = shl i16 %9, 1, !dbg !658
  %11 = inttoptr i16 %10 to i16*, !dbg !658
  call void asm sideeffect "nop", ""(), !dbg !658
  call void asm sideeffect "nop", ""(), !dbg !658
  %12 = load volatile i16, i16* %11, align 2, !dbg !658
  store i16 %12, i16* %2, align 2, !dbg !649
  %13 = load i16, i16* %3, align 2, !dbg !659
  %14 = load i16, i16* %2, align 2, !dbg !660
  %15 = and i16 %14, 32767, !dbg !661
  %16 = shl i16 %13, 1, !dbg !662
  %17 = inttoptr i16 %16 to i16*, !dbg !662
  store volatile i16 %15, i16* %17, align 2, !dbg !662
  call void asm sideeffect "nop", ""(), !dbg !662
  call void asm sideeffect "nop", ""(), !dbg !662
  ret void, !dbg !663
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord() !dbg !664 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 2), !dbg !666
  %2 = sub i16 %1, 4, !dbg !668
  ret i16 %2, !dbg !669
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord() !dbg !670 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 0), !dbg !671
  %2 = sub i16 %1, 1, !dbg !673
  ret i16 %2, !dbg !674
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 %0) !dbg !675 {
  %2 = alloca i16, i16 1, align 2, !dbg !677
  %3 = alloca i16, i16 1, align 2, !dbg !679
  store i16 %0, i16* %3, align 2, !dbg !679
  %4 = load i16, i16* %3, align 2, !dbg !680
  %5 = lshr i16 %4, 1, !dbg !681
  %6 = add i16 %5, 31813, !dbg !682
  %7 = shl i16 %6, 1, !dbg !683
  %8 = inttoptr i16 %7 to i16*, !dbg !683
  call void asm sideeffect "nop", ""(), !dbg !683
  call void asm sideeffect "nop", ""(), !dbg !683
  %9 = load volatile i16, i16* %8, align 2, !dbg !683
  store i16 %9, i16* %2, align 2, !dbg !677
  %10 = load i16, i16* %2, align 2, !dbg !684
  %11 = and i16 %10, 2047, !dbg !685
  ret i16 %11, !dbg !686
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord() !dbg !687 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord(), !dbg !689
  ret i16 %1, !dbg !691
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.get_y_coord() !dbg !692 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord(), !dbg !693
  ret i16 %1, !dbg !695
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval(i16 %0) !dbg !696 {
  %2 = alloca i16, i16 1, align 2, !dbg !697
  store i16 %0, i16* %2, align 2, !dbg !697
  %3 = load i16, i16* %2, align 2, !dbg !699
  %4 = icmp ult i16 %3, 24, !dbg !700
  br i1 %4, label %5, label %7, !dbg !701

5:                                                ; preds = %10, %11, %1
  %6 = phi i16 [ 0, %10 ], [ 0, %11 ], [ 1, %1 ]
  br label %12, !dbg !701

7:                                                ; preds = %1
  %8 = load i16, i16* %2, align 2, !dbg !702
  %9 = icmp eq i16 31, %8, !dbg !703
  br i1 %9, label %10, label %11, !dbg !704

10:                                               ; preds = %7
  br label %5, !dbg !704

11:                                               ; preds = %7
  call void asm sideeffect "hcf", ""(), !dbg !704
  br label %5, !dbg !704

12:                                               ; preds = %5
  %13 = phi i16 [ %6, %5 ]
  br label %14, !dbg !701

14:                                               ; preds = %12
  ret i16 %13, !dbg !701
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7) !dbg !705 {
  %9 = alloca i16, i16 1, align 2, !dbg !706
  %10 = alloca i16, i16 1, align 2, !dbg !708
  %11 = alloca i16, i16 1, align 2, !dbg !709
  %12 = alloca i16, i16 1, align 2, !dbg !710
  %13 = alloca i16, i16 1, align 2, !dbg !711
  %14 = alloca i16, i16 1, align 2, !dbg !712
  %15 = alloca i16, i16 1, align 2, !dbg !713
  %16 = alloca i16, i16 1, align 2, !dbg !714
  %17 = alloca i16, i16 1, align 2, !dbg !715
  store i16 %0, i16* %17, align 2, !dbg !715
  store i16 %1, i16* %16, align 2, !dbg !714
  store i16 %2, i16* %15, align 2, !dbg !713
  store i16 %3, i16* %14, align 2, !dbg !712
  store i16 %4, i16* %13, align 2, !dbg !711
  store i16 %5, i16* %12, align 2, !dbg !710
  store i16 %6, i16* %11, align 2, !dbg !709
  store i16 %7, i16* %10, align 2, !dbg !708
  %18 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !716
  store i16 %18, i16* %9, align 2, !dbg !706
  %19 = load i16, i16* %11, align 2, !dbg !717
  store i16 %19, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_c, align 2, !dbg !718
  %20 = load i16, i16* %10, align 2, !dbg !719
  store i16 %20, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_is_half, align 2, !dbg !720
  %21 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_c, align 2, !dbg !721
  %22 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval(i16 %21), !dbg !722
  store i16 %22, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !723
  store i16 0, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !724
  %23 = load i16, i16* %16, align 2, !dbg !725
  store i16 %23, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !726
  %24 = load i16, i16* %15, align 2, !dbg !727
  store i16 %24, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !728
  %25 = load i16, i16* %15, align 2, !dbg !729
  %26 = load i16, i16* %13, align 2, !dbg !730
  %27 = add i16 %25, %26, !dbg !731
  %28 = sub i16 %27, 1, !dbg !732
  store i16 %28, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_last, align 2, !dbg !733
  %29 = load i16, i16* %9, align 2, !dbg !734
  %30 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_last, align 2, !dbg !735
  %31 = icmp eq i16 %29, %30, !dbg !736
  br i1 %31, label %32, label %37, !dbg !737

32:                                               ; preds = %8
  %33 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !738
  %34 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !738
  %35 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !738
  store i16 %33, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !739
  store i16 lshr (i16 ptrtoint ([1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.ctrl_1 to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !739
  store i16 %34, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !739
  store i16 %35, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !739
  %36 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.ctrl_1, i16 0, i1 false), align 4, !dbg !740
  store i32 %36, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i1 false), align 4, !dbg !741
  br label %42, !dbg !737

37:                                               ; preds = %8
  %38 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !742
  %39 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !742
  %40 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !742
  store i16 %38, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !743
  store i16 lshr (i16 ptrtoint ([1 x i32]* @"$$csl_base_address$$0$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11" to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !743
  store i16 %39, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !743
  store i16 %40, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !743
  %41 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @"$$csl_base_address$$0$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11", i16 0, i1 false), align 4, !dbg !744
  store i32 %41, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i1 false), align 4, !dbg !745
  br label %42, !dbg !737

42:                                               ; preds = %32, %37
  store i32 165646921, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i2 1), align 4, !dbg !746
  %43 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !747
  %44 = icmp eq i16 0, %43, !dbg !748
  br i1 %44, label %45, label %56, !dbg !749

45:                                               ; preds = %42
  %46 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !750
  %47 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !750
  %48 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !750
  %49 = load i16, i16* %17, align 2, !dbg !751
  %50 = call i16* @.get_tensor_ptr(i16 %49), !dbg !752
  %51 = ptrtoint i16* %50 to i16, !dbg !753
  %52 = lshr i16 %51, 1, !dbg !753
  store i16 %46, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !754
  store i16 %52, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !754
  store i16 %47, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !754
  store i16 %48, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !754
  %53 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !755
  %54 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !755
  %55 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !755
  store i16 1, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !756
  store i16 %53, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !756
  store i16 %54, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !756
  store i16 %55, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !756
  call void @llvm.sdr.actvt.r(i16 21), !dbg !757
  br label %63, !dbg !749

56:                                               ; preds = %42
  %57 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !758
  %58 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !758
  %59 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !758
  store i16 %57, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !759
  store i16 lshr (i16 ptrtoint ([1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.data_buf to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !759
  store i16 %58, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !759
  store i16 %59, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !759
  %60 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !760
  %61 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !760
  %62 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !760
  store i16 1, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !761
  store i16 %60, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !761
  store i16 %61, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !761
  store i16 %62, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !761
  call void @llvm.sdr.ublk.r(i16 0), !dbg !762
  br label %63, !dbg !749

63:                                               ; preds = %45, %56
  ret void, !dbg !737
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x(i32 %0) #8 !dbg !763 {
  %2 = alloca i32, i16 1, align 4, !dbg !764
  store i32 %0, i32* %2, align 4, !dbg !764
  call void @llvm.sdr.blk.r(i16 0), !dbg !766
  %3 = load i32, i32* %2, align 4, !dbg !767
  store i32 %3, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.data_buf, i16 0, i1 false), align 4, !dbg !768
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !769
  %4 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !770
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !770
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !770
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !770
  store volatile i16 %4, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !771
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !771
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !771
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !771
  call void asm sideeffect "nop", ""(), !dbg !771
  call void asm sideeffect "nop", ""(), !dbg !771
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !772
  %8 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !773
  %9 = add i16 %8, 1, !dbg !774
  store i16 %9, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !775
  ret void, !dbg !776
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_send_data() #9 !dbg !777 {
  %1 = alloca i16, i16 1, align 2, !dbg !778
  %2 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !780
  %3 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !781
  %4 = icmp ult i16 %2, %3, !dbg !782
  br i1 %4, label %5, label %27, !dbg !783

5:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !784
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !785
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !785
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !785
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !785
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !786
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !786
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !786
  store volatile i16 %9, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !786
  call void asm sideeffect "nop", ""(), !dbg !786
  call void asm sideeffect "nop", ""(), !dbg !786
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_is_half, align 2, !dbg !787
  %11 = icmp ult i16 0, %10, !dbg !788
  br i1 %11, label %12, label %18, !dbg !789

12:                                               ; preds = %5
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !790
  %13 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !791
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !791
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !791
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !791
  %17 = add i16 %14, 1, !dbg !792
  store i16 %13, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !793
  store i16 %17, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !793
  store i16 %15, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !793
  store i16 %16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !793
  br label %24, !dbg !789

18:                                               ; preds = %5
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !794
  %19 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !795
  %20 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !795
  %21 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !795
  %22 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !795
  %23 = add i16 %20, 2, !dbg !796
  store i16 %19, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !797
  store i16 %23, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !797
  store i16 %21, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !797
  store i16 %22, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !797
  br label %24, !dbg !789

24:                                               ; preds = %12, %18
  %25 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !798
  %26 = add i16 %25, 1, !dbg !799
  store i16 %26, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !800
  br label %34, !dbg !783

27:                                               ; preds = %0
  %28 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !801
  store i16 %28, i16* %1, align 2, !dbg !778
  %29 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !802
  %30 = load i16, i16* %1, align 2, !dbg !803
  %31 = icmp eq i16 %29, %30, !dbg !804
  br i1 %31, label %32, label %33, !dbg !805

32:                                               ; preds = %27
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !806
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__1 to i8*)), !dbg !807
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !808
  br label %33, !dbg !805

33:                                               ; preds = %32, %27
  br label %34, !dbg !783

34:                                               ; preds = %24, %33
  ret void, !dbg !783
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl() #10 !dbg !809 {
  %1 = alloca i16, i16 1, align 2, !dbg !810
  %2 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !812
  %3 = icmp eq i16 0, %2, !dbg !813
  br i1 %3, label %4, label %9, !dbg !814

4:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__2 to i8*)), !dbg !815
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !816
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !816
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !816
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !816
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !817
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !817
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !817
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !817
  call void asm sideeffect "nop", ""(), !dbg !817
  call void asm sideeffect "nop", ""(), !dbg !817
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !818
  br label %31, !dbg !814

9:                                                ; preds = %0
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !819
  %11 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !820
  %12 = icmp ult i16 %10, %11, !dbg !821
  br i1 %12, label %13, label %18, !dbg !822

13:                                               ; preds = %9
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__3 to i8*)), !dbg !823
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !824
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !824
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !824
  %17 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !824
  store volatile i16 %14, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !825
  store volatile i16 %15, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !825
  store volatile i16 %16, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !825
  store volatile i16 %17, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !825
  call void asm sideeffect "nop", ""(), !dbg !825
  call void asm sideeffect "nop", ""(), !dbg !825
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !826
  br label %30, !dbg !822

18:                                               ; preds = %9
  %19 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !827
  store i16 %19, i16* %1, align 2, !dbg !810
  %20 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !828
  %21 = load i16, i16* %1, align 2, !dbg !829
  %22 = icmp eq i16 %20, %21, !dbg !830
  br i1 %22, label %23, label %24, !dbg !831

23:                                               ; preds = %18
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__4 to i8*)), !dbg !832
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__5 to i8*)), !dbg !833
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !834
  br label %29, !dbg !831

24:                                               ; preds = %18
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !835
  %25 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !836
  %26 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !836
  %27 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !836
  %28 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !836
  store volatile i16 %25, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !837
  store volatile i16 %26, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !837
  store volatile i16 %27, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !837
  store volatile i16 %28, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !837
  call void asm sideeffect "nop", ""(), !dbg !837
  call void asm sideeffect "nop", ""(), !dbg !837
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !838
  br label %29, !dbg !831

29:                                               ; preds = %23, %24
  br label %30, !dbg !822

30:                                               ; preds = %13, %29
  br label %31, !dbg !814

31:                                               ; preds = %4, %30
  ret void, !dbg !814
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.d2h_configure(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7) !dbg !839 {
  %9 = alloca i1, i16 1, align 1, !dbg !840
  %10 = alloca i1, i16 1, align 1, !dbg !842
  %11 = alloca i1, i16 1, align 1, !dbg !843
  %12 = alloca i16, i16 1, align 2, !dbg !844
  %13 = alloca i16, i16 1, align 2, !dbg !845
  %14 = alloca i16, i16 1, align 2, !dbg !846
  %15 = alloca i16, i16 1, align 2, !dbg !847
  %16 = alloca i16, i16 1, align 2, !dbg !848
  %17 = alloca i16, i16 1, align 2, !dbg !849
  %18 = alloca i16, i16 1, align 2, !dbg !850
  %19 = alloca i16, i16 1, align 2, !dbg !851
  %20 = alloca i16, i16 1, align 2, !dbg !852
  %21 = alloca i16, i16 1, align 2, !dbg !853
  %22 = alloca i16, i16 1, align 2, !dbg !854
  %23 = alloca i16, i16 1, align 2, !dbg !855
  %24 = alloca i16, i16 1, align 2, !dbg !856
  %25 = alloca i16, i16 1, align 2, !dbg !857
  store i16 %0, i16* %25, align 2, !dbg !857
  store i16 %1, i16* %24, align 2, !dbg !856
  store i16 %2, i16* %23, align 2, !dbg !855
  store i16 %3, i16* %22, align 2, !dbg !854
  store i16 %4, i16* %21, align 2, !dbg !853
  store i16 %5, i16* %20, align 2, !dbg !852
  store i16 %6, i16* %19, align 2, !dbg !851
  store i16 %7, i16* %18, align 2, !dbg !850
  %26 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !858
  store i16 %26, i16* %17, align 2, !dbg !849
  %27 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_y_coord(), !dbg !859
  store i16 %27, i16* %16, align 2, !dbg !848
  %28 = load i16, i16* %24, align 2, !dbg !860
  store i16 %28, i16* %15, align 2, !dbg !847
  %29 = load i16, i16* %24, align 2, !dbg !861
  %30 = load i16, i16* %22, align 2, !dbg !862
  %31 = add i16 %29, %30, !dbg !863
  %32 = sub i16 %31, 1, !dbg !864
  store i16 %32, i16* %14, align 2, !dbg !846
  %33 = load i16, i16* %23, align 2, !dbg !865
  store i16 %33, i16* %13, align 2, !dbg !845
  %34 = load i16, i16* %23, align 2, !dbg !866
  %35 = load i16, i16* %21, align 2, !dbg !867
  %36 = add i16 %34, %35, !dbg !868
  %37 = sub i16 %36, 1, !dbg !869
  store i16 %37, i16* %12, align 2, !dbg !844
  store i1 false, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !870
  %38 = load i16, i16* %17, align 2, !dbg !871
  %39 = load i16, i16* %15, align 2, !dbg !872
  %40 = icmp sge i16 %38, %39, !dbg !873
  br i1 %40, label %41, label %45, !dbg !843

41:                                               ; preds = %8
  %42 = load i16, i16* %16, align 2, !dbg !874
  %43 = load i16, i16* %12, align 2, !dbg !875
  %44 = icmp sle i16 %42, %43, !dbg !876
  store i1 %44, i1* %11, align 1, !dbg !843
  br label %46, !dbg !843

45:                                               ; preds = %8
  store i1 false, i1* %11, align 1, !dbg !843
  br label %46, !dbg !843

46:                                               ; preds = %41, %45
  %47 = load i1, i1* %11, align 1, !dbg !843
  br i1 %47, label %48, label %52, !dbg !842

48:                                               ; preds = %46
  %49 = load i16, i16* %16, align 2, !dbg !877
  %50 = load i16, i16* %13, align 2, !dbg !878
  %51 = icmp sge i16 %49, %50, !dbg !879
  store i1 %51, i1* %10, align 1, !dbg !842
  br label %53, !dbg !842

52:                                               ; preds = %46
  store i1 false, i1* %10, align 1, !dbg !842
  br label %53, !dbg !842

53:                                               ; preds = %48, %52
  %54 = load i1, i1* %10, align 1, !dbg !842
  br i1 %54, label %55, label %56, !dbg !880

55:                                               ; preds = %53
  store i1 true, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !881
  br label %56, !dbg !880

56:                                               ; preds = %55, %53
  store i1 false, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !882
  %57 = load i16, i16* %17, align 2, !dbg !883
  %58 = load i16, i16* %14, align 2, !dbg !884
  %59 = icmp sle i16 %57, %58, !dbg !885
  br i1 %59, label %60, label %62, !dbg !840

60:                                               ; preds = %56
  %61 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !886
  store i1 %61, i1* %9, align 1, !dbg !840
  br label %63, !dbg !840

62:                                               ; preds = %56
  store i1 false, i1* %9, align 1, !dbg !840
  br label %63, !dbg !840

63:                                               ; preds = %60, %62
  %64 = load i1, i1* %9, align 1, !dbg !840
  br i1 %64, label %65, label %66, !dbg !887

65:                                               ; preds = %63
  store i1 true, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !888
  br label %66, !dbg !887

66:                                               ; preds = %65, %63
  %67 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !889
  br i1 %67, label %68, label %86, !dbg !890

68:                                               ; preds = %66
  call void @__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position(i16 31959), !dbg !891
  %69 = load i16, i16* %15, align 2, !dbg !892
  %70 = load i16, i16* %17, align 2, !dbg !893
  %71 = icmp eq i16 %69, %70, !dbg !894
  br i1 %71, label %72, label %73, !dbg !895

72:                                               ; preds = %68
  call void @__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 31765), !dbg !896
  br label %74, !dbg !895

73:                                               ; preds = %68
  call void @__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 31765), !dbg !897
  br label %74, !dbg !895

74:                                               ; preds = %72, %73
  call void @sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit(i16 21), !dbg !898
  %75 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !899
  br i1 %75, label %76, label %85, !dbg !900

76:                                               ; preds = %74
  %77 = load i16, i16* %20, align 2, !dbg !901
  %78 = load i16, i16* %19, align 2, !dbg !902
  %79 = load i16, i16* %24, align 2, !dbg !903
  %80 = load i16, i16* %23, align 2, !dbg !904
  %81 = load i16, i16* %22, align 2, !dbg !905
  %82 = load i16, i16* %21, align 2, !dbg !906
  %83 = load i16, i16* %25, align 2, !dbg !907
  %84 = load i16, i16* %18, align 2, !dbg !908
  call void @sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start(i16 %77, i16 %78, i16 %79, i16 %80, i16 %81, i16 %82, i16 %83, i16 %84), !dbg !909
  br label %85, !dbg !900

85:                                               ; preds = %76, %74
  br label %87, !dbg !890

86:                                               ; preds = %66
  call void @llvm.sdr.actvt.r(i16 28), !dbg !910
  br label %87, !dbg !890

87:                                               ; preds = %85, %86
  ret void, !dbg !843
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit(i16 %0) !dbg !911 {
  %2 = alloca i16, i16 1, align 2, !dbg !912
  %3 = alloca i16, i16 1, align 2, !dbg !914
  %4 = alloca i16, i16 1, align 2, !dbg !915
  %5 = alloca i16, i16 1, align 2, !dbg !916
  store i16 %0, i16* %5, align 2, !dbg !916
  %6 = load i16, i16* %5, align 2, !dbg !917
  store i16 %6, i16* %4, align 2, !dbg !915
  %7 = load i16, i16* %4, align 2, !dbg !918
  %8 = add i16 %7, 31744, !dbg !919
  store i16 %8, i16* %3, align 2, !dbg !914
  %9 = load i16, i16* %3, align 2, !dbg !920
  %10 = shl i16 %9, 1, !dbg !921
  %11 = inttoptr i16 %10 to i16*, !dbg !921
  call void asm sideeffect "nop", ""(), !dbg !921
  call void asm sideeffect "nop", ""(), !dbg !921
  %12 = load volatile i16, i16* %11, align 2, !dbg !921
  store i16 %12, i16* %2, align 2, !dbg !912
  %13 = load i16, i16* %3, align 2, !dbg !922
  %14 = load i16, i16* %2, align 2, !dbg !923
  %15 = and i16 %14, 32767, !dbg !924
  %16 = shl i16 %13, 1, !dbg !925
  %17 = inttoptr i16 %16 to i16*, !dbg !925
  store volatile i16 %15, i16* %17, align 2, !dbg !925
  call void asm sideeffect "nop", ""(), !dbg !925
  call void asm sideeffect "nop", ""(), !dbg !925
  ret void, !dbg !926
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord() !dbg !927 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 2), !dbg !928
  %2 = sub i16 %1, 4, !dbg !930
  ret i16 %2, !dbg !931
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord() !dbg !932 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 0), !dbg !933
  %2 = sub i16 %1, 1, !dbg !935
  ret i16 %2, !dbg !936
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 %0) !dbg !937 {
  %2 = alloca i16, i16 1, align 2, !dbg !938
  %3 = alloca i16, i16 1, align 2, !dbg !940
  store i16 %0, i16* %3, align 2, !dbg !940
  %4 = load i16, i16* %3, align 2, !dbg !941
  %5 = lshr i16 %4, 1, !dbg !942
  %6 = add i16 %5, 31813, !dbg !943
  %7 = shl i16 %6, 1, !dbg !944
  %8 = inttoptr i16 %7 to i16*, !dbg !944
  call void asm sideeffect "nop", ""(), !dbg !944
  call void asm sideeffect "nop", ""(), !dbg !944
  %9 = load volatile i16, i16* %8, align 2, !dbg !944
  store i16 %9, i16* %2, align 2, !dbg !938
  %10 = load i16, i16* %2, align 2, !dbg !945
  %11 = and i16 %10, 2047, !dbg !946
  ret i16 %11, !dbg !947
}

define internal i16 @sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr(i16 %0) !dbg !948 {
  %2 = alloca i16, i16 1, align 2, !dbg !950
  store i16 %0, i16* %2, align 2, !dbg !950
  %3 = load i16, i16* %2, align 2, !dbg !952
  %4 = mul i16 %3, 2, !dbg !953
  %5 = add i16 %4, 31680, !dbg !954
  ret i16 %5, !dbg !955
}

define internal void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 %0, i16 %1, i1 %2) !dbg !956 {
  %4 = alloca i16, i16 1, align 2, !dbg !957
  %5 = alloca i16, i16 1, align 2, !dbg !959
  %6 = alloca i1, i16 1, align 1, !dbg !960
  %7 = alloca i16, i16 1, align 2, !dbg !961
  %8 = alloca i16, i16 1, align 2, !dbg !962
  store i16 %0, i16* %8, align 2, !dbg !962
  store i16 %1, i16* %7, align 2, !dbg !961
  store i1 %2, i1* %6, align 1, !dbg !960
  %9 = load i16, i16* %8, align 2, !dbg !963
  %10 = call i16 @sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr(i16 %9), !dbg !964
  store i16 %10, i16* %5, align 2, !dbg !959
  %11 = load i16, i16* %5, align 2, !dbg !965
  %12 = shl i16 %11, 1, !dbg !966
  %13 = inttoptr i16 %12 to i16*, !dbg !966
  call void asm sideeffect "nop", ""(), !dbg !966
  call void asm sideeffect "nop", ""(), !dbg !966
  call void asm sideeffect "nop", ""(), !dbg !966
  call void asm sideeffect "nop", ""(), !dbg !966
  %14 = load volatile i16, i16* %13, align 2, !dbg !966
  store i16 %14, i16* %4, align 2, !dbg !957
  %15 = load i1, i1* %6, align 1, !dbg !967
  br i1 %15, label %16, label %19, !dbg !968

16:                                               ; preds = %3
  %17 = load i16, i16* %4, align 2, !dbg !969
  %18 = or i16 %17, 2048, !dbg !970
  store i16 %18, i16* %4, align 2, !dbg !971
  br label %22, !dbg !968

19:                                               ; preds = %3
  %20 = load i16, i16* %4, align 2, !dbg !972
  %21 = and i16 %20, -2049, !dbg !973
  store i16 %21, i16* %4, align 2, !dbg !974
  br label %22, !dbg !968

22:                                               ; preds = %16, %19
  %23 = load i16, i16* %4, align 2, !dbg !975
  %24 = and i16 %23, -32, !dbg !976
  store i16 %24, i16* %4, align 2, !dbg !977
  %25 = load i16, i16* %4, align 2, !dbg !978
  %26 = load i16, i16* %7, align 2, !dbg !979
  %27 = add i16 %25, %26, !dbg !980
  store i16 %27, i16* %4, align 2, !dbg !981
  %28 = load i16, i16* %5, align 2, !dbg !982
  %29 = load i16, i16* %4, align 2, !dbg !983
  %30 = shl i16 %28, 1, !dbg !984
  %31 = inttoptr i16 %30 to i16*, !dbg !984
  store volatile i16 %29, i16* %31, align 2, !dbg !984
  call void asm sideeffect "nop", ""(), !dbg !984
  call void asm sideeffect "nop", ""(), !dbg !984
  call void asm sideeffect "nop", ""(), !dbg !984
  call void asm sideeffect "nop", ""(), !dbg !984
  ret void, !dbg !968
}

define internal i16 @sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr(i16 %0) !dbg !985 {
  %2 = alloca i16, i16 1, align 2, !dbg !987
  store i16 %0, i16* %2, align 2, !dbg !987
  %3 = load i16, i16* %2, align 2, !dbg !989
  %4 = add i16 %3, 31616, !dbg !990
  ret i16 %4, !dbg !991
}

define internal void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 %0, i16 %1) !dbg !992 {
  %3 = alloca i16, i16 1, align 2, !dbg !993
  %4 = alloca i16, i16 1, align 2, !dbg !995
  %5 = alloca i16, i16 1, align 2, !dbg !996
  %6 = alloca i16, i16 1, align 2, !dbg !997
  store i16 %0, i16* %6, align 2, !dbg !997
  store i16 %1, i16* %5, align 2, !dbg !996
  %7 = load i16, i16* %6, align 2, !dbg !998
  %8 = call i16 @sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr(i16 %7), !dbg !999
  store i16 %8, i16* %4, align 2, !dbg !995
  %9 = load i16, i16* %4, align 2, !dbg !1000
  %10 = shl i16 %9, 1, !dbg !1001
  %11 = inttoptr i16 %10 to i16*, !dbg !1001
  call void asm sideeffect "nop", ""(), !dbg !1001
  call void asm sideeffect "nop", ""(), !dbg !1001
  call void asm sideeffect "nop", ""(), !dbg !1001
  call void asm sideeffect "nop", ""(), !dbg !1001
  %12 = load volatile i16, i16* %11, align 2, !dbg !1001
  store i16 %12, i16* %3, align 2, !dbg !993
  %13 = load i16, i16* %3, align 2, !dbg !1002
  %14 = and i16 %13, -497, !dbg !1003
  store i16 %14, i16* %3, align 2, !dbg !1004
  %15 = load i16, i16* %3, align 2, !dbg !1005
  %16 = load i16, i16* %5, align 2, !dbg !1006
  %17 = add i16 %15, %16, !dbg !1007
  %18 = shl i16 %17, 4, !dbg !1008
  store i16 %18, i16* %3, align 2, !dbg !1009
  %19 = load i16, i16* %4, align 2, !dbg !1010
  %20 = load i16, i16* %3, align 2, !dbg !1011
  %21 = shl i16 %19, 1, !dbg !1012
  %22 = inttoptr i16 %21 to i16*, !dbg !1012
  store volatile i16 %20, i16* %22, align 2, !dbg !1012
  call void asm sideeffect "nop", ""(), !dbg !1012
  call void asm sideeffect "nop", ""(), !dbg !1012
  call void asm sideeffect "nop", ""(), !dbg !1012
  call void asm sideeffect "nop", ""(), !dbg !1012
  ret void, !dbg !1013
}

define internal i16* @.get_tensor_ptr(i16 %0) !dbg !1014 {
  %2 = alloca i16, i16 1, align 2, !dbg !1015
  store i16 %0, i16* %2, align 2, !dbg !1015
  %3 = load i16, i16* %2, align 2, !dbg !1015
  %4 = zext i16 %3 to i32, !dbg !1015
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
  ], !dbg !1015

5:                                                ; preds = %1
  br i1 false, label %6, label %7, !dbg !1015

6:                                                ; preds = %5
  br label %8, !dbg !1015

7:                                                ; preds = %5
  call void asm sideeffect "hcf", ""(), !dbg !1015
  br label %8, !dbg !1015

8:                                                ; preds = %6, %7
  br label %33, !dbg !1015

9:                                                ; preds = %1
  %10 = load i16*, i16** @p_a, align 8, !dbg !1015
  br label %33, !dbg !1015

11:                                               ; preds = %1
  %12 = load i16*, i16** @p_b, align 8, !dbg !1015
  br label %33, !dbg !1015

13:                                               ; preds = %1
  %14 = load i16*, i16** @p_g, align 8, !dbg !1015
  br label %33, !dbg !1015

15:                                               ; preds = %1
  %16 = load i16*, i16** @p_c, align 8, !dbg !1015
  br label %33, !dbg !1015

17:                                               ; preds = %1
  %18 = load i16*, i16** @p_d, align 8, !dbg !1015
  br label %33, !dbg !1015

19:                                               ; preds = %1
  %20 = load half*, half** @p_af, align 8, !dbg !1015
  %21 = bitcast half* %20 to i16*, !dbg !1015
  br label %33, !dbg !1015

22:                                               ; preds = %1
  %23 = load half*, half** @p_bf, align 8, !dbg !1015
  %24 = bitcast half* %23 to i16*, !dbg !1015
  br label %33, !dbg !1015

25:                                               ; preds = %1
  %26 = load half*, half** @p_gf, align 8, !dbg !1015
  %27 = bitcast half* %26 to i16*, !dbg !1015
  br label %33, !dbg !1015

28:                                               ; preds = %1
  %29 = load half*, half** @p_cf, align 8, !dbg !1015
  %30 = bitcast half* %29 to i16*, !dbg !1015
  br label %33, !dbg !1015

31:                                               ; preds = %1
  %32 = load i16*, i16** @p_mark, align 8, !dbg !1015
  br label %33, !dbg !1015

33:                                               ; preds = %8, %9, %11, %13, %15, %17, %19, %22, %25, %28, %31
  %34 = phi i16 [ -2, %31 ], [ -2, %28 ], [ -2, %25 ], [ -2, %22 ], [ -2, %19 ], [ -2, %17 ], [ -2, %15 ], [ -2, %13 ], [ -2, %11 ], [ -2, %9 ], [ 0, %8 ]
  %35 = phi i16* [ %32, %31 ], [ %30, %28 ], [ %27, %25 ], [ %24, %22 ], [ %21, %19 ], [ %18, %17 ], [ %16, %15 ], [ %14, %13 ], [ %12, %11 ], [ %10, %9 ], [ undef, %8 ]
  br label %36, !dbg !1015

36:                                               ; preds = %33
  %37 = icmp ne i16 %34, 0, !dbg !1015
  br i1 %37, label %38, label %39, !dbg !1015

38:                                               ; preds = %36
  br label %41, !dbg !1015

39:                                               ; preds = %36
  %40 = load i16*, i16** @p_mark, align 8, !dbg !1015
  br label %41, !dbg !1015

41:                                               ; preds = %38, %39
  %42 = phi i16* [ %40, %39 ], [ %35, %38 ]
  br label %43, !dbg !1015

43:                                               ; preds = %41
  ret i16* %42, !dbg !1015
}

define internal void @__generic0sys_mod.sys_mod.tile_config.queue_flush.exit() !dbg !1017 {
  store volatile i16 1, i16* inttoptr (i16 -2268 to i16*), align 2, !dbg !1019
  call void asm sideeffect "nop", ""(), !dbg !1019
  call void asm sideeffect "nop", ""(), !dbg !1019
  ret void, !dbg !1021
}

define internal void @__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position(i16 %0) !dbg !1022 {
  %2 = alloca i16, i16 1, align 2, !dbg !1024
  %3 = alloca i16, i16 1, align 2, !dbg !1026
  %4 = alloca i16, i16 1, align 2, !dbg !1027
  store i16 %0, i16* %4, align 2, !dbg !1027
  %5 = load i16, i16* %4, align 2, !dbg !1028
  store i16 %5, i16* %3, align 2, !dbg !1026
  %6 = load i16, i16* %3, align 2, !dbg !1029
  %7 = shl i16 %6, 1, !dbg !1030
  %8 = inttoptr i16 %7 to i16*, !dbg !1030
  call void asm sideeffect "nop", ""(), !dbg !1030
  call void asm sideeffect "nop", ""(), !dbg !1030
  call void asm sideeffect "nop", ""(), !dbg !1030
  call void asm sideeffect "nop", ""(), !dbg !1030
  %9 = load volatile i16, i16* %8, align 2, !dbg !1030
  store i16 %9, i16* %2, align 2, !dbg !1024
  %10 = load i16, i16* %2, align 2, !dbg !1031
  %11 = and i16 %10, -16, !dbg !1032
  store i16 %11, i16* %2, align 2, !dbg !1032
  %12 = load i16, i16* %3, align 2, !dbg !1033
  %13 = load i16, i16* %2, align 2, !dbg !1034
  %14 = shl i16 %12, 1, !dbg !1035
  %15 = inttoptr i16 %14 to i16*, !dbg !1035
  store volatile i16 %13, i16* %15, align 2, !dbg !1035
  call void asm sideeffect "nop", ""(), !dbg !1035
  call void asm sideeffect "nop", ""(), !dbg !1035
  call void asm sideeffect "nop", ""(), !dbg !1035
  call void asm sideeffect "nop", ""(), !dbg !1035
  ret void, !dbg !1036
}

define internal void @__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 %0) !dbg !1037 {
  %2 = alloca i16, i16 1, align 2, !dbg !1039
  %3 = alloca i16, i16 1, align 2, !dbg !1041
  %4 = alloca i16, i16 1, align 2, !dbg !1042
  store i16 %0, i16* %4, align 2, !dbg !1042
  %5 = load i16, i16* %4, align 2, !dbg !1043
  store i16 %5, i16* %3, align 2, !dbg !1041
  %6 = load i16, i16* %3, align 2, !dbg !1044
  %7 = shl i16 %6, 1, !dbg !1045
  %8 = inttoptr i16 %7 to i16*, !dbg !1045
  call void asm sideeffect "nop", ""(), !dbg !1045
  call void asm sideeffect "nop", ""(), !dbg !1045
  %9 = load volatile i16, i16* %8, align 2, !dbg !1045
  store i16 %9, i16* %2, align 2, !dbg !1039
  %10 = load i16, i16* %2, align 2, !dbg !1046
  %11 = and i16 %10, -256, !dbg !1047
  store i16 %11, i16* %2, align 2, !dbg !1048
  %12 = load i16, i16* %2, align 2, !dbg !1049
  %13 = load i16, i16* %2, align 2, !dbg !1050
  %14 = call i16 @__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %13), !dbg !1051
  %15 = or i16 %12, %14, !dbg !1052
  store i16 %15, i16* %2, align 2, !dbg !1052
  %16 = load i16, i16* %2, align 2, !dbg !1053
  %17 = load i16, i16* %2, align 2, !dbg !1054
  %18 = call i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %17), !dbg !1055
  %19 = or i16 %16, %18, !dbg !1056
  store i16 %19, i16* %2, align 2, !dbg !1056
  %20 = load i16, i16* %3, align 2, !dbg !1057
  %21 = load i16, i16* %2, align 2, !dbg !1058
  %22 = shl i16 %20, 1, !dbg !1059
  %23 = inttoptr i16 %22 to i16*, !dbg !1059
  store volatile i16 %21, i16* %23, align 2, !dbg !1059
  call void asm sideeffect "nop", ""(), !dbg !1059
  call void asm sideeffect "nop", ""(), !dbg !1059
  ret void, !dbg !1060
}

define internal void @__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 %0) !dbg !1061 {
  %2 = alloca i16, i16 1, align 2, !dbg !1062
  %3 = alloca i16, i16 1, align 2, !dbg !1064
  %4 = alloca i16, i16 1, align 2, !dbg !1065
  store i16 %0, i16* %4, align 2, !dbg !1065
  %5 = load i16, i16* %4, align 2, !dbg !1066
  store i16 %5, i16* %3, align 2, !dbg !1064
  %6 = load i16, i16* %3, align 2, !dbg !1067
  %7 = shl i16 %6, 1, !dbg !1068
  %8 = inttoptr i16 %7 to i16*, !dbg !1068
  call void asm sideeffect "nop", ""(), !dbg !1068
  call void asm sideeffect "nop", ""(), !dbg !1068
  %9 = load volatile i16, i16* %8, align 2, !dbg !1068
  store i16 %9, i16* %2, align 2, !dbg !1062
  %10 = load i16, i16* %2, align 2, !dbg !1069
  %11 = and i16 %10, -256, !dbg !1070
  store i16 %11, i16* %2, align 2, !dbg !1071
  %12 = load i16, i16* %2, align 2, !dbg !1072
  %13 = load i16, i16* %2, align 2, !dbg !1073
  %14 = call i16 @__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %13), !dbg !1074
  %15 = or i16 %12, %14, !dbg !1075
  store i16 %15, i16* %2, align 2, !dbg !1075
  %16 = load i16, i16* %2, align 2, !dbg !1076
  %17 = load i16, i16* %2, align 2, !dbg !1077
  %18 = call i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %17), !dbg !1078
  %19 = or i16 %16, %18, !dbg !1079
  store i16 %19, i16* %2, align 2, !dbg !1079
  %20 = load i16, i16* %3, align 2, !dbg !1080
  %21 = load i16, i16* %2, align 2, !dbg !1081
  %22 = shl i16 %20, 1, !dbg !1082
  %23 = inttoptr i16 %22 to i16*, !dbg !1082
  store volatile i16 %21, i16* %23, align 2, !dbg !1082
  call void asm sideeffect "nop", ""(), !dbg !1082
  call void asm sideeffect "nop", ""(), !dbg !1082
  ret void, !dbg !1083
}

define internal i16 @__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %0) !dbg !1084 {
  %2 = alloca i16, i16 1, align 2, !dbg !1085
  %3 = alloca i16, i16 1, align 2, !dbg !1087
  store i16 %0, i16* %3, align 2, !dbg !1087
  %4 = load i16, i16* %3, align 2, !dbg !1088
  store i16 %4, i16* %2, align 2, !dbg !1085
  %5 = load i16, i16* %2, align 2, !dbg !1089
  store i16 %5, i16* %2, align 2, !dbg !1090
  %6 = load i16, i16* %2, align 2, !dbg !1091
  ret i16 %6, !dbg !1092
}

define internal i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %0) !dbg !1093 {
  %2 = alloca i16, i16 1, align 2, !dbg !1094
  %3 = alloca i16, i16 1, align 2, !dbg !1096
  store i16 %0, i16* %3, align 2, !dbg !1096
  %4 = load i16, i16* %3, align 2, !dbg !1097
  store i16 %4, i16* %2, align 2, !dbg !1094
  %5 = load i16, i16* %2, align 2, !dbg !1098
  %6 = or i16 %5, 2, !dbg !1099
  store i16 %6, i16* %2, align 2, !dbg !1099
  %7 = load i16, i16* %2, align 2, !dbg !1100
  ret i16 %7, !dbg !1101
}

define internal i16 @__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %0) !dbg !1102 {
  %2 = alloca i16, i16 1, align 2, !dbg !1103
  %3 = alloca i16, i16 1, align 2, !dbg !1105
  store i16 %0, i16* %3, align 2, !dbg !1105
  %4 = load i16, i16* %3, align 2, !dbg !1106
  store i16 %4, i16* %2, align 2, !dbg !1103
  %5 = load i16, i16* %2, align 2, !dbg !1107
  %6 = or i16 %5, 128, !dbg !1108
  store i16 %6, i16* %2, align 2, !dbg !1108
  %7 = load i16, i16* %2, align 2, !dbg !1109
  ret i16 %7, !dbg !1110
}

define internal void @__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction(i16 %0) !dbg !1111 {
  %2 = alloca i16, i16 1, align 2, !dbg !1112
  %3 = alloca i16, i16 1, align 2, !dbg !1114
  %4 = alloca i16, i16 1, align 2, !dbg !1115
  store i16 %0, i16* %4, align 2, !dbg !1115
  %5 = load i16, i16* %4, align 2, !dbg !1116
  store i16 %5, i16* %3, align 2, !dbg !1114
  %6 = load i16, i16* %3, align 2, !dbg !1117
  %7 = shl i16 %6, 1, !dbg !1118
  %8 = inttoptr i16 %7 to i16*, !dbg !1118
  call void asm sideeffect "nop", ""(), !dbg !1118
  call void asm sideeffect "nop", ""(), !dbg !1118
  %9 = load volatile i16, i16* %8, align 2, !dbg !1118
  store i16 %9, i16* %2, align 2, !dbg !1112
  %10 = load i16, i16* %2, align 2, !dbg !1119
  %11 = and i16 %10, -17, !dbg !1120
  store i16 %11, i16* %2, align 2, !dbg !1120
  %12 = load i16, i16* %3, align 2, !dbg !1121
  %13 = load i16, i16* %2, align 2, !dbg !1122
  %14 = shl i16 %12, 1, !dbg !1123
  %15 = inttoptr i16 %14 to i16*, !dbg !1123
  store volatile i16 %13, i16* %15, align 2, !dbg !1123
  call void asm sideeffect "nop", ""(), !dbg !1123
  call void asm sideeffect "nop", ""(), !dbg !1123
  ret void, !dbg !1124
}

define internal void @__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction(i16 %0) !dbg !1125 {
  %2 = alloca i16, i16 1, align 2, !dbg !1126
  %3 = alloca i16, i16 1, align 2, !dbg !1128
  %4 = alloca i16, i16 1, align 2, !dbg !1129
  store i16 %0, i16* %4, align 2, !dbg !1129
  %5 = load i16, i16* %4, align 2, !dbg !1130
  store i16 %5, i16* %3, align 2, !dbg !1128
  %6 = load i16, i16* %3, align 2, !dbg !1131
  %7 = shl i16 %6, 1, !dbg !1132
  %8 = inttoptr i16 %7 to i16*, !dbg !1132
  call void asm sideeffect "nop", ""(), !dbg !1132
  call void asm sideeffect "nop", ""(), !dbg !1132
  %9 = load volatile i16, i16* %8, align 2, !dbg !1132
  store i16 %9, i16* %2, align 2, !dbg !1126
  %10 = load i16, i16* %2, align 2, !dbg !1133
  %11 = or i16 %10, 16, !dbg !1134
  store i16 %11, i16* %2, align 2, !dbg !1134
  %12 = load i16, i16* %3, align 2, !dbg !1135
  %13 = load i16, i16* %2, align 2, !dbg !1136
  %14 = shl i16 %12, 1, !dbg !1137
  %15 = inttoptr i16 %14 to i16*, !dbg !1137
  store volatile i16 %13, i16* %15, align 2, !dbg !1137
  call void asm sideeffect "nop", ""(), !dbg !1137
  call void asm sideeffect "nop", ""(), !dbg !1137
  ret void, !dbg !1138
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
!4 = !DIFile(filename: "./pe.csl", directory: "/home/USER/xkernel/studies/wse3-characterization/microbench/pcsweep/cases/mem")
!5 = !DISubroutineType(types: !6)
!6 = !{}
!7 = !DILocation(line: 17, column: 11, scope: !8)
!8 = !DILexicalBlockFile(scope: !3, file: !4, discriminator: 0)
!9 = !DILocation(line: 18, column: 11, scope: !8)
!10 = !DILocation(line: 18, column: 18, scope: !8)
!11 = !DILocation(line: 18, column: 15, scope: !8)
!12 = !DILocation(line: 18, column: 8, scope: !8)
!13 = !DILocation(line: 19, column: 11, scope: !8)
!14 = !DILocation(line: 19, column: 18, scope: !8)
!15 = !DILocation(line: 19, column: 15, scope: !8)
!16 = !DILocation(line: 19, column: 8, scope: !8)
!17 = !DILocation(line: 20, column: 11, scope: !8)
!18 = !DILocation(line: 21, column: 11, scope: !8)
!19 = !DILocation(line: 21, column: 18, scope: !8)
!20 = !DILocation(line: 21, column: 15, scope: !8)
!21 = !DILocation(line: 21, column: 8, scope: !8)
!22 = !DILocation(line: 22, column: 11, scope: !8)
!23 = !DILocation(line: 22, column: 18, scope: !8)
!24 = !DILocation(line: 22, column: 15, scope: !8)
!25 = !DILocation(line: 22, column: 8, scope: !8)
!26 = !DILocation(line: 23, column: 11, scope: !8)
!27 = !DILocation(line: 24, column: 11, scope: !8)
!28 = !DILocation(line: 24, column: 18, scope: !8)
!29 = !DILocation(line: 24, column: 15, scope: !8)
!30 = !DILocation(line: 24, column: 8, scope: !8)
!31 = !DILocation(line: 25, column: 11, scope: !8)
!32 = !DILocation(line: 25, column: 18, scope: !8)
!33 = !DILocation(line: 25, column: 15, scope: !8)
!34 = !DILocation(line: 25, column: 8, scope: !8)
!35 = !DILocation(line: 26, column: 11, scope: !8)
!36 = !DILocation(line: 27, column: 11, scope: !8)
!37 = !DILocation(line: 27, column: 18, scope: !8)
!38 = !DILocation(line: 27, column: 15, scope: !8)
!39 = !DILocation(line: 27, column: 8, scope: !8)
!40 = !DILocation(line: 28, column: 11, scope: !8)
!41 = !DILocation(line: 28, column: 18, scope: !8)
!42 = !DILocation(line: 28, column: 15, scope: !8)
!43 = !DILocation(line: 28, column: 8, scope: !8)
!44 = !DILocation(line: 29, column: 11, scope: !8)
!45 = !DILocation(line: 30, column: 11, scope: !8)
!46 = !DILocation(line: 30, column: 18, scope: !8)
!47 = !DILocation(line: 30, column: 15, scope: !8)
!48 = !DILocation(line: 30, column: 8, scope: !8)
!49 = !DILocation(line: 31, column: 11, scope: !8)
!50 = !DILocation(line: 31, column: 18, scope: !8)
!51 = !DILocation(line: 31, column: 15, scope: !8)
!52 = !DILocation(line: 31, column: 8, scope: !8)
!53 = !DILocation(line: 32, column: 11, scope: !8)
!54 = !DILocation(line: 33, column: 11, scope: !8)
!55 = !DILocation(line: 33, column: 18, scope: !8)
!56 = !DILocation(line: 33, column: 15, scope: !8)
!57 = !DILocation(line: 33, column: 8, scope: !8)
!58 = !DILocation(line: 34, column: 11, scope: !8)
!59 = !DILocation(line: 34, column: 18, scope: !8)
!60 = !DILocation(line: 34, column: 15, scope: !8)
!61 = !DILocation(line: 34, column: 8, scope: !8)
!62 = !DILocation(line: 35, column: 11, scope: !8)
!63 = !DILocation(line: 36, column: 11, scope: !8)
!64 = !DILocation(line: 36, column: 18, scope: !8)
!65 = !DILocation(line: 36, column: 15, scope: !8)
!66 = !DILocation(line: 36, column: 8, scope: !8)
!67 = !DILocation(line: 37, column: 11, scope: !8)
!68 = !DILocation(line: 37, column: 18, scope: !8)
!69 = !DILocation(line: 37, column: 15, scope: !8)
!70 = !DILocation(line: 37, column: 8, scope: !8)
!71 = !DILocation(line: 38, column: 11, scope: !8)
!72 = !DILocation(line: 39, column: 11, scope: !8)
!73 = !DILocation(line: 39, column: 18, scope: !8)
!74 = !DILocation(line: 39, column: 15, scope: !8)
!75 = !DILocation(line: 39, column: 8, scope: !8)
!76 = !DILocation(line: 40, column: 11, scope: !8)
!77 = !DILocation(line: 40, column: 18, scope: !8)
!78 = !DILocation(line: 40, column: 15, scope: !8)
!79 = !DILocation(line: 40, column: 8, scope: !8)
!80 = !DILocation(line: 42, column: 11, scope: !8)
!81 = !DILocation(line: 43, column: 3, scope: !8)
!82 = !DILocation(line: 16, column: 1, scope: !8)
!83 = distinct !DISubprogram(name: "f_exit", linkageName: "f_exit", scope: null, file: !4, line: 46, type: !5, scopeLine: 46, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!84 = !DILocation(line: 46, column: 22, scope: !85)
!85 = !DILexicalBlockFile(scope: !83, file: !4, discriminator: 0)
!86 = !DILocation(line: 46, column: 1, scope: !85)
!87 = distinct !DISubprogram(name: "sys_mod.sys_nop", linkageName: "sys_mod.sys_nop", scope: null, file: !88, line: 90, type: !5, scopeLine: 90, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!88 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/memcpy.csl", directory: "")
!89 = !DILocation(line: 90, column: 1, scope: !90)
!90 = !DILexicalBlockFile(scope: !87, file: !88, discriminator: 0)
!91 = distinct !DISubprogram(name: "sys_mod.unblock_cmd_stream", linkageName: "sys_mod.unblock_cmd_stream", scope: null, file: !88, line: 102, type: !5, scopeLine: 102, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!92 = !DILocation(line: 103, column: 3, scope: !93)
!93 = !DILexicalBlockFile(scope: !91, file: !88, discriminator: 0)
!94 = !DILocation(line: 102, column: 1, scope: !93)
!95 = distinct !DISubprogram(name: "sys_mod.sys_mod.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.unblock_cmd_stream", scope: null, file: !96, line: 307, type: !5, scopeLine: 307, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!96 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpy.csl", directory: "")
!97 = !DILocation(line: 308, column: 5, scope: !98)
!98 = !DILexicalBlockFile(scope: !95, file: !96, discriminator: 0)
!99 = !DILocation(line: 307, column: 1, scope: !98)
!100 = distinct !DISubprogram(name: "sys_mod.sys_mod.teardown_h2d", linkageName: "sys_mod.sys_mod.teardown_h2d", scope: null, file: !96, line: 323, type: !5, scopeLine: 323, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!101 = !DILocation(line: 326, column: 5, scope: !102)
!102 = !DILexicalBlockFile(scope: !100, file: !96, discriminator: 0)
!103 = !DILocation(line: 323, column: 1, scope: !102)
!104 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_ublk_c22", linkageName: "sys_mod.sys_mod.f_ublk_c22", scope: null, file: !96, line: 335, type: !5, scopeLine: 335, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!105 = !DILocation(line: 336, column: 5, scope: !106)
!106 = !DILexicalBlockFile(scope: !104, file: !96, discriminator: 0)
!107 = !DILocation(line: 335, column: 1, scope: !106)
!108 = distinct !DISubprogram(name: "sys_mod.sys_mod.teardown_d2h", linkageName: "sys_mod.sys_mod.teardown_d2h", scope: null, file: !96, line: 344, type: !5, scopeLine: 344, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!109 = !DILocation(line: 355, column: 5, scope: !110)
!110 = !DILexicalBlockFile(scope: !108, file: !96, discriminator: 0)
!111 = !DILocation(line: 359, column: 5, scope: !110)
!112 = !DILocation(line: 344, column: 1, scope: !110)
!113 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_memcpyh2d", linkageName: "sys_mod.sys_mod.f_memcpyh2d", scope: null, file: !96, line: 460, type: !5, scopeLine: 460, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!114 = !DILocation(line: 477, column: 5, scope: !115)
!115 = !DILexicalBlockFile(scope: !113, file: !96, discriminator: 0)
!116 = !DILocation(line: 476, column: 5, scope: !115)
!117 = !DILocation(line: 475, column: 5, scope: !115)
!118 = !DILocation(line: 474, column: 5, scope: !115)
!119 = !DILocation(line: 473, column: 5, scope: !115)
!120 = !DILocation(line: 472, column: 5, scope: !115)
!121 = !DILocation(line: 471, column: 5, scope: !115)
!122 = !DILocation(line: 470, column: 5, scope: !115)
!123 = !DILocation(line: 469, column: 5, scope: !115)
!124 = !DILocation(line: 468, column: 5, scope: !115)
!125 = !DILocation(line: 467, column: 5, scope: !115)
!126 = !DILocation(line: 466, column: 5, scope: !115)
!127 = !DILocation(line: 465, column: 5, scope: !115)
!128 = !DILocation(line: 463, column: 5, scope: !115)
!129 = !DILocation(line: 462, column: 20, scope: !115)
!130 = !DILocation(line: 462, column: 32, scope: !115)
!131 = !DILocation(line: 462, column: 5, scope: !115)
!132 = !DILocation(line: 465, column: 33, scope: !115)
!133 = !DILocation(line: 465, column: 38, scope: !115)
!134 = !DILocation(line: 466, column: 34, scope: !115)
!135 = !DILocation(line: 466, column: 39, scope: !115)
!136 = !DILocation(line: 467, column: 34, scope: !115)
!137 = !DILocation(line: 467, column: 39, scope: !115)
!138 = !DILocation(line: 468, column: 33, scope: !115)
!139 = !DILocation(line: 468, column: 38, scope: !115)
!140 = !DILocation(line: 469, column: 33, scope: !115)
!141 = !DILocation(line: 469, column: 38, scope: !115)
!142 = !DILocation(line: 470, column: 35, scope: !115)
!143 = !DILocation(line: 470, column: 21, scope: !115)
!144 = !DILocation(line: 471, column: 41, scope: !115)
!145 = !DILocation(line: 471, column: 27, scope: !115)
!146 = !DILocation(line: 472, column: 39, scope: !115)
!147 = !DILocation(line: 472, column: 25, scope: !115)
!148 = !DILocation(line: 473, column: 44, scope: !115)
!149 = !DILocation(line: 473, column: 49, scope: !115)
!150 = !DILocation(line: 474, column: 41, scope: !115)
!151 = !DILocation(line: 474, column: 46, scope: !115)
!152 = !DILocation(line: 475, column: 41, scope: !115)
!153 = !DILocation(line: 475, column: 46, scope: !115)
!154 = !DILocation(line: 476, column: 59, scope: !115)
!155 = !DILocation(line: 476, column: 64, scope: !115)
!156 = !DILocation(line: 476, column: 50, scope: !115)
!157 = !DILocation(line: 476, column: 129, scope: !115)
!158 = !DILocation(line: 476, column: 134, scope: !115)
!159 = !DILocation(line: 476, column: 120, scope: !115)
!160 = !DILocation(line: 476, column: 118, scope: !115)
!161 = !DILocation(line: 476, column: 112, scope: !115)
!162 = !DILocation(line: 476, column: 36, scope: !115)
!163 = !DILocation(line: 477, column: 59, scope: !115)
!164 = !DILocation(line: 477, column: 64, scope: !115)
!165 = !DILocation(line: 477, column: 50, scope: !115)
!166 = !DILocation(line: 477, column: 129, scope: !115)
!167 = !DILocation(line: 477, column: 134, scope: !115)
!168 = !DILocation(line: 477, column: 120, scope: !115)
!169 = !DILocation(line: 477, column: 118, scope: !115)
!170 = !DILocation(line: 477, column: 112, scope: !115)
!171 = !DILocation(line: 477, column: 36, scope: !115)
!172 = !DILocation(line: 479, column: 24, scope: !115)
!173 = !DILocation(line: 481, column: 21, scope: !115)
!174 = !DILocation(line: 481, column: 19, scope: !115)
!175 = !DILocation(line: 482, column: 21, scope: !115)
!176 = !DILocation(line: 482, column: 19, scope: !115)
!177 = !DILocation(line: 483, column: 21, scope: !115)
!178 = !DILocation(line: 483, column: 19, scope: !115)
!179 = !DILocation(line: 484, column: 20, scope: !115)
!180 = !DILocation(line: 484, column: 18, scope: !115)
!181 = !DILocation(line: 485, column: 20, scope: !115)
!182 = !DILocation(line: 485, column: 18, scope: !115)
!183 = !DILocation(line: 486, column: 22, scope: !115)
!184 = !DILocation(line: 486, column: 20, scope: !115)
!185 = !DILocation(line: 487, column: 27, scope: !115)
!186 = !DILocation(line: 487, column: 25, scope: !115)
!187 = !DILocation(line: 488, column: 25, scope: !115)
!188 = !DILocation(line: 488, column: 23, scope: !115)
!189 = !DILocation(line: 489, column: 31, scope: !115)
!190 = !DILocation(line: 489, column: 29, scope: !115)
!191 = !DILocation(line: 490, column: 28, scope: !115)
!192 = !DILocation(line: 490, column: 26, scope: !115)
!193 = !DILocation(line: 491, column: 28, scope: !115)
!194 = !DILocation(line: 491, column: 26, scope: !115)
!195 = !DILocation(line: 492, column: 37, scope: !115)
!196 = !DILocation(line: 492, column: 35, scope: !115)
!197 = !DILocation(line: 493, column: 37, scope: !115)
!198 = !DILocation(line: 493, column: 35, scope: !115)
!199 = !DILocation(line: 495, column: 5, scope: !115)
!200 = !DILocation(line: 501, column: 5, scope: !115)
!201 = !DILocation(line: 506, column: 5, scope: !115)
!202 = !DILocation(line: 521, column: 5, scope: !115)
!203 = !DILocation(line: 522, column: 16, scope: !115)
!204 = !DILocation(line: 531, column: 5, scope: !115)
!205 = !DILocation(line: 460, column: 1, scope: !115)
!206 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_memcpyd2h", linkageName: "sys_mod.sys_mod.f_memcpyd2h", scope: null, file: !96, line: 556, type: !5, scopeLine: 556, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!207 = !DILocation(line: 568, column: 5, scope: !208)
!208 = !DILexicalBlockFile(scope: !206, file: !96, discriminator: 0)
!209 = !DILocation(line: 567, column: 5, scope: !208)
!210 = !DILocation(line: 566, column: 5, scope: !208)
!211 = !DILocation(line: 565, column: 5, scope: !208)
!212 = !DILocation(line: 564, column: 5, scope: !208)
!213 = !DILocation(line: 563, column: 5, scope: !208)
!214 = !DILocation(line: 562, column: 5, scope: !208)
!215 = !DILocation(line: 561, column: 5, scope: !208)
!216 = !DILocation(line: 559, column: 5, scope: !208)
!217 = !DILocation(line: 558, column: 20, scope: !208)
!218 = !DILocation(line: 558, column: 32, scope: !208)
!219 = !DILocation(line: 558, column: 5, scope: !208)
!220 = !DILocation(line: 561, column: 33, scope: !208)
!221 = !DILocation(line: 561, column: 38, scope: !208)
!222 = !DILocation(line: 562, column: 34, scope: !208)
!223 = !DILocation(line: 562, column: 39, scope: !208)
!224 = !DILocation(line: 563, column: 34, scope: !208)
!225 = !DILocation(line: 563, column: 39, scope: !208)
!226 = !DILocation(line: 564, column: 33, scope: !208)
!227 = !DILocation(line: 564, column: 38, scope: !208)
!228 = !DILocation(line: 565, column: 33, scope: !208)
!229 = !DILocation(line: 565, column: 38, scope: !208)
!230 = !DILocation(line: 566, column: 35, scope: !208)
!231 = !DILocation(line: 566, column: 21, scope: !208)
!232 = !DILocation(line: 567, column: 41, scope: !208)
!233 = !DILocation(line: 567, column: 27, scope: !208)
!234 = !DILocation(line: 568, column: 39, scope: !208)
!235 = !DILocation(line: 568, column: 25, scope: !208)
!236 = !DILocation(line: 570, column: 24, scope: !208)
!237 = !DILocation(line: 573, column: 21, scope: !208)
!238 = !DILocation(line: 573, column: 19, scope: !208)
!239 = !DILocation(line: 574, column: 21, scope: !208)
!240 = !DILocation(line: 574, column: 19, scope: !208)
!241 = !DILocation(line: 575, column: 21, scope: !208)
!242 = !DILocation(line: 575, column: 19, scope: !208)
!243 = !DILocation(line: 576, column: 20, scope: !208)
!244 = !DILocation(line: 576, column: 18, scope: !208)
!245 = !DILocation(line: 577, column: 20, scope: !208)
!246 = !DILocation(line: 577, column: 18, scope: !208)
!247 = !DILocation(line: 578, column: 22, scope: !208)
!248 = !DILocation(line: 578, column: 20, scope: !208)
!249 = !DILocation(line: 579, column: 27, scope: !208)
!250 = !DILocation(line: 579, column: 25, scope: !208)
!251 = !DILocation(line: 580, column: 25, scope: !208)
!252 = !DILocation(line: 580, column: 23, scope: !208)
!253 = !DILocation(line: 582, column: 5, scope: !208)
!254 = !DILocation(line: 588, column: 59, scope: !208)
!255 = !DILocation(line: 588, column: 5, scope: !208)
!256 = !DILocation(line: 608, column: 5, scope: !208)
!257 = !DILocation(line: 609, column: 16, scope: !208)
!258 = !DILocation(line: 556, column: 1, scope: !208)
!259 = distinct !DISubprogram(name: "sys_mod.sys_mod.oq0_teardow_handler", linkageName: "sys_mod.sys_mod.oq0_teardow_handler", scope: null, file: !96, line: 631, type: !5, scopeLine: 631, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!260 = !DILocation(line: 632, column: 9, scope: !261)
!261 = !DILexicalBlockFile(scope: !259, file: !96, discriminator: 0)
!262 = !DILocation(line: 632, column: 5, scope: !261)
!263 = !DILocation(line: 634, column: 66, scope: !261)
!264 = !DILocation(line: 634, column: 9, scope: !261)
!265 = !DILocation(line: 636, column: 13, scope: !261)
!266 = !DILocation(line: 637, column: 13, scope: !261)
!267 = !DILocation(line: 638, column: 13, scope: !261)
!268 = !DILocation(line: 639, column: 13, scope: !261)
!269 = !DILocation(line: 640, column: 13, scope: !261)
!270 = !DILocation(line: 641, column: 13, scope: !261)
!271 = !DILocation(line: 642, column: 13, scope: !261)
!272 = !DILocation(line: 643, column: 13, scope: !261)
!273 = !DILocation(line: 644, column: 13, scope: !261)
!274 = !DILocation(line: 645, column: 13, scope: !261)
!275 = !DILocation(line: 646, column: 13, scope: !261)
!276 = !DILocation(line: 647, column: 13, scope: !261)
!277 = !DILocation(line: 648, column: 13, scope: !261)
!278 = !DILocation(line: 635, column: 9, scope: !261)
!279 = !DILocation(line: 652, column: 9, scope: !261)
!280 = !DILocation(line: 654, column: 13, scope: !261)
!281 = !DILocation(line: 655, column: 13, scope: !261)
!282 = !DILocation(line: 656, column: 13, scope: !261)
!283 = !DILocation(line: 657, column: 13, scope: !261)
!284 = !DILocation(line: 658, column: 13, scope: !261)
!285 = !DILocation(line: 659, column: 13, scope: !261)
!286 = !DILocation(line: 660, column: 13, scope: !261)
!287 = !DILocation(line: 661, column: 13, scope: !261)
!288 = !DILocation(line: 653, column: 9, scope: !261)
!289 = !DILocation(line: 664, column: 5, scope: !261)
!290 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_rpc", linkageName: "sys_mod.sys_mod.f_rpc", scope: null, file: !96, line: 694, type: !5, scopeLine: 694, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!291 = !DILocation(line: 694, column: 13, scope: !292)
!292 = !DILexicalBlockFile(scope: !290, file: !96, discriminator: 0)
!293 = !DILocation(line: 700, column: 5, scope: !292)
!294 = !DILocation(line: 706, column: 20, scope: !292)
!295 = !DILocation(line: 706, column: 32, scope: !292)
!296 = !DILocation(line: 706, column: 5, scope: !292)
!297 = !DILocation(line: 710, column: 5, scope: !292)
!298 = !DILocation(line: 712, column: 24, scope: !292)
!299 = !DILocation(line: 694, column: 1, scope: !292)
!300 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.stack_push", linkageName: "sys_mod.sys_mod.sys_mod.stack_push", scope: null, file: !301, line: 54, type: !5, scopeLine: 54, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!301 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/sys.csl", directory: "")
!302 = !DILocation(line: 60, column: 5, scope: !303)
!303 = !DILexicalBlockFile(scope: !300, file: !301, discriminator: 0)
!304 = !DILocation(line: 54, column: 16, scope: !303)
!305 = !DILocation(line: 59, column: 13, scope: !303)
!306 = !DILocation(line: 59, column: 24, scope: !303)
!307 = !DILocation(line: 59, column: 5, scope: !303)
!308 = !DILocation(line: 61, column: 25, scope: !303)
!309 = !DILocation(line: 61, column: 5, scope: !303)
!310 = !DILocation(line: 61, column: 11, scope: !303)
!311 = !DILocation(line: 61, column: 10, scope: !303)
!312 = !DILocation(line: 61, column: 23, scope: !303)
!313 = !DILocation(line: 62, column: 18, scope: !303)
!314 = !DILocation(line: 62, column: 29, scope: !303)
!315 = !DILocation(line: 62, column: 16, scope: !303)
!316 = !DILocation(line: 54, column: 1, scope: !303)
!317 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_push", linkageName: "sys_mod.sys_mod.sys_mod.f_push", scope: null, file: !301, line: 72, type: !5, scopeLine: 72, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!318 = !DILocation(line: 72, column: 25, scope: !319)
!319 = !DILexicalBlockFile(scope: !317, file: !301, discriminator: 0)
!320 = !DILocation(line: 72, column: 13, scope: !319)
!321 = !DILocation(line: 73, column: 16, scope: !319)
!322 = !DILocation(line: 73, column: 5, scope: !319)
!323 = !DILocation(line: 72, column: 1, scope: !319)
!324 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.block_cmd_stream", linkageName: "sys_mod.sys_mod.sys_mod.block_cmd_stream", scope: null, file: !301, line: 76, type: !5, scopeLine: 76, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!325 = !DILocation(line: 77, column: 5, scope: !326)
!326 = !DILexicalBlockFile(scope: !324, file: !301, discriminator: 0)
!327 = !DILocation(line: 76, column: 1, scope: !326)
!328 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.sys_mod.unblock_cmd_stream", scope: null, file: !301, line: 80, type: !5, scopeLine: 80, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!329 = !DILocation(line: 81, column: 5, scope: !330)
!330 = !DILexicalBlockFile(scope: !328, file: !301, discriminator: 0)
!331 = !DILocation(line: 80, column: 1, scope: !330)
!332 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_sys_exit", linkageName: "sys_mod.sys_mod.sys_mod.f_sys_exit", scope: null, file: !301, line: 85, type: !5, scopeLine: 85, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!333 = !DILocation(line: 86, column: 5, scope: !334)
!334 = !DILexicalBlockFile(scope: !332, file: !301, discriminator: 0)
!335 = !DILocation(line: 87, column: 5, scope: !334)
!336 = !DILocation(line: 85, column: 1, scope: !334)
!337 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore", linkageName: "sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore", scope: null, file: !301, line: 90, type: !5, scopeLine: 90, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!338 = !DILocation(line: 90, column: 30, scope: !339)
!339 = !DILexicalBlockFile(scope: !337, file: !301, discriminator: 0)
!340 = !DILocation(line: 90, column: 1, scope: !339)
!341 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord", scope: null, file: !342, line: 131, type: !5, scopeLine: 131, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!342 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpyh2d.csl", directory: "")
!343 = !DILocation(line: 132, column: 12, scope: !344)
!344 = !DILexicalBlockFile(scope: !341, file: !342, discriminator: 0)
!345 = !DILocation(line: 132, column: 5, scope: !344)
!346 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord", scope: null, file: !342, line: 134, type: !5, scopeLine: 134, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!347 = !DILocation(line: 135, column: 12, scope: !348)
!348 = !DILexicalBlockFile(scope: !346, file: !342, discriminator: 0)
!349 = !DILocation(line: 135, column: 5, scope: !348)
!350 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval", scope: null, file: !342, line: 148, type: !5, scopeLine: 148, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!351 = !DILocation(line: 148, column: 23, scope: !352)
!352 = !DILexicalBlockFile(scope: !350, file: !342, discriminator: 0)
!353 = !DILocation(line: 149, column: 9, scope: !352)
!354 = !DILocation(line: 149, column: 20, scope: !352)
!355 = !DILocation(line: 149, column: 5, scope: !352)
!356 = !DILocation(line: 152, column: 23, scope: !352)
!357 = !DILocation(line: 152, column: 20, scope: !352)
!358 = !DILocation(line: 152, column: 9, scope: !352)
!359 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start", scope: null, file: !342, line: 226, type: !5, scopeLine: 226, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!360 = !DILocation(line: 233, column: 5, scope: !361)
!361 = !DILexicalBlockFile(scope: !359, file: !342, discriminator: 0)
!362 = !DILocation(line: 226, column: 49, scope: !361)
!363 = !DILocation(line: 226, column: 32, scope: !361)
!364 = !DILocation(line: 226, column: 21, scope: !361)
!365 = !DILocation(line: 229, column: 37, scope: !361)
!366 = !DILocation(line: 229, column: 52, scope: !361)
!367 = !DILocation(line: 229, column: 19, scope: !361)
!368 = !DILocation(line: 233, column: 71, scope: !361)
!369 = !DILocation(line: 233, column: 55, scope: !361)
!370 = !DILocation(line: 233, column: 25, scope: !361)
!371 = !DILocation(line: 235, column: 37, scope: !361)
!372 = !DILocation(line: 235, column: 52, scope: !361)
!373 = !DILocation(line: 235, column: 19, scope: !361)
!374 = !DILocation(line: 236, column: 28, scope: !361)
!375 = !DILocation(line: 236, column: 5, scope: !361)
!376 = !DILocation(line: 237, column: 28, scope: !361)
!377 = !DILocation(line: 237, column: 5, scope: !361)
!378 = !DILocation(line: 238, column: 13, scope: !361)
!379 = !DILocation(line: 238, column: 11, scope: !361)
!380 = !DILocation(line: 238, column: 5, scope: !361)
!381 = !DILocation(line: 239, column: 9, scope: !361)
!382 = !DILocation(line: 241, column: 9, scope: !361)
!383 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream", scope: null, file: !342, line: 249, type: !5, scopeLine: 249, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!384 = !DILocation(line: 250, column: 5, scope: !385)
!385 = !DILexicalBlockFile(scope: !383, file: !342, discriminator: 0)
!386 = !DILocation(line: 249, column: 1, scope: !385)
!387 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure", scope: null, file: !342, line: 276, type: !5, scopeLine: 276, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!388 = !DILocation(line: 414, column: 13, scope: !389)
!389 = !DILexicalBlockFile(scope: !387, file: !342, discriminator: 0)
!390 = !DILocation(line: 413, column: 13, scope: !389)
!391 = !DILocation(line: 400, column: 17, scope: !389)
!392 = !DILocation(line: 340, column: 9, scope: !389)
!393 = !DILocation(line: 339, column: 9, scope: !389)
!394 = !DILocation(line: 337, column: 5, scope: !389)
!395 = !DILocation(line: 319, column: 9, scope: !389)
!396 = !DILocation(line: 318, column: 9, scope: !389)
!397 = !DILocation(line: 315, column: 5, scope: !389)
!398 = !DILocation(line: 292, column: 5, scope: !389)
!399 = !DILocation(line: 291, column: 5, scope: !389)
!400 = !DILocation(line: 289, column: 5, scope: !389)
!401 = !DILocation(line: 288, column: 5, scope: !389)
!402 = !DILocation(line: 287, column: 5, scope: !389)
!403 = !DILocation(line: 286, column: 5, scope: !389)
!404 = !DILocation(line: 285, column: 5, scope: !389)
!405 = !DILocation(line: 284, column: 5, scope: !389)
!406 = !DILocation(line: 283, column: 5, scope: !389)
!407 = !DILocation(line: 282, column: 5, scope: !389)
!408 = !DILocation(line: 281, column: 5, scope: !389)
!409 = !DILocation(line: 280, column: 5, scope: !389)
!410 = !DILocation(line: 279, column: 5, scope: !389)
!411 = !DILocation(line: 278, column: 5, scope: !389)
!412 = !DILocation(line: 277, column: 5, scope: !389)
!413 = !DILocation(line: 291, column: 26, scope: !389)
!414 = !DILocation(line: 292, column: 26, scope: !389)
!415 = !DILocation(line: 315, column: 25, scope: !389)
!416 = !DILocation(line: 315, column: 31, scope: !389)
!417 = !DILocation(line: 315, column: 29, scope: !389)
!418 = !DILocation(line: 316, column: 20, scope: !389)
!419 = !DILocation(line: 316, column: 18, scope: !389)
!420 = !DILocation(line: 317, column: 52, scope: !389)
!421 = !DILocation(line: 317, column: 49, scope: !389)
!422 = !DILocation(line: 317, column: 5, scope: !389)
!423 = !DILocation(line: 318, column: 42, scope: !389)
!424 = !DILocation(line: 318, column: 33, scope: !389)
!425 = !DILocation(line: 318, column: 49, scope: !389)
!426 = !DILocation(line: 318, column: 48, scope: !389)
!427 = !DILocation(line: 318, column: 24, scope: !389)
!428 = !DILocation(line: 319, column: 24, scope: !389)
!429 = !DILocation(line: 319, column: 32, scope: !389)
!430 = !DILocation(line: 319, column: 36, scope: !389)
!431 = !DILocation(line: 319, column: 34, scope: !389)
!432 = !DILocation(line: 319, column: 30, scope: !389)
!433 = !DILocation(line: 320, column: 18, scope: !389)
!434 = !DILocation(line: 320, column: 15, scope: !389)
!435 = !DILocation(line: 320, column: 9, scope: !389)
!436 = !DILocation(line: 321, column: 26, scope: !389)
!437 = !DILocation(line: 325, column: 28, scope: !389)
!438 = !DILocation(line: 325, column: 26, scope: !389)
!439 = !DILocation(line: 331, column: 9, scope: !389)
!440 = !DILocation(line: 331, column: 15, scope: !389)
!441 = !DILocation(line: 331, column: 5, scope: !389)
!442 = !DILocation(line: 332, column: 22, scope: !389)
!443 = !DILocation(line: 334, column: 9, scope: !389)
!444 = !DILocation(line: 334, column: 18, scope: !389)
!445 = !DILocation(line: 334, column: 15, scope: !389)
!446 = !DILocation(line: 334, column: 5, scope: !389)
!447 = !DILocation(line: 335, column: 22, scope: !389)
!448 = !DILocation(line: 338, column: 52, scope: !389)
!449 = !DILocation(line: 338, column: 49, scope: !389)
!450 = !DILocation(line: 338, column: 5, scope: !389)
!451 = !DILocation(line: 339, column: 42, scope: !389)
!452 = !DILocation(line: 339, column: 48, scope: !389)
!453 = !DILocation(line: 339, column: 46, scope: !389)
!454 = !DILocation(line: 339, column: 33, scope: !389)
!455 = !DILocation(line: 339, column: 52, scope: !389)
!456 = !DILocation(line: 339, column: 51, scope: !389)
!457 = !DILocation(line: 339, column: 24, scope: !389)
!458 = !DILocation(line: 340, column: 25, scope: !389)
!459 = !DILocation(line: 340, column: 31, scope: !389)
!460 = !DILocation(line: 340, column: 29, scope: !389)
!461 = !DILocation(line: 340, column: 37, scope: !389)
!462 = !DILocation(line: 340, column: 41, scope: !389)
!463 = !DILocation(line: 340, column: 39, scope: !389)
!464 = !DILocation(line: 340, column: 35, scope: !389)
!465 = !DILocation(line: 341, column: 18, scope: !389)
!466 = !DILocation(line: 341, column: 15, scope: !389)
!467 = !DILocation(line: 341, column: 9, scope: !389)
!468 = !DILocation(line: 342, column: 26, scope: !389)
!469 = !DILocation(line: 347, column: 10, scope: !389)
!470 = !DILocation(line: 347, column: 16, scope: !389)
!471 = !DILocation(line: 347, column: 14, scope: !389)
!472 = !DILocation(line: 347, column: 5, scope: !389)
!473 = !DILocation(line: 348, column: 22, scope: !389)
!474 = !DILocation(line: 350, column: 10, scope: !389)
!475 = !DILocation(line: 350, column: 18, scope: !389)
!476 = !DILocation(line: 350, column: 21, scope: !389)
!477 = !DILocation(line: 350, column: 20, scope: !389)
!478 = !DILocation(line: 350, column: 14, scope: !389)
!479 = !DILocation(line: 350, column: 5, scope: !389)
!480 = !DILocation(line: 351, column: 22, scope: !389)
!481 = !DILocation(line: 354, column: 9, scope: !389)
!482 = !DILocation(line: 354, column: 5, scope: !389)
!483 = !DILocation(line: 358, column: 9, scope: !389)
!484 = !DILocation(line: 361, column: 9, scope: !389)
!485 = !DILocation(line: 364, column: 20, scope: !389)
!486 = !DILocation(line: 364, column: 17, scope: !389)
!487 = !DILocation(line: 364, column: 9, scope: !389)
!488 = !DILocation(line: 368, column: 13, scope: !389)
!489 = !DILocation(line: 371, column: 13, scope: !389)
!490 = !DILocation(line: 375, column: 13, scope: !389)
!491 = !DILocation(line: 394, column: 13, scope: !389)
!492 = !DILocation(line: 396, column: 29, scope: !389)
!493 = !DILocation(line: 396, column: 27, scope: !389)
!494 = !DILocation(line: 397, column: 60, scope: !389)
!495 = !DILocation(line: 397, column: 57, scope: !389)
!496 = !DILocation(line: 397, column: 13, scope: !389)
!497 = !DILocation(line: 400, column: 54, scope: !389)
!498 = !DILocation(line: 400, column: 55, scope: !389)
!499 = !DILocation(line: 400, column: 46, scope: !389)
!500 = !DILocation(line: 400, column: 59, scope: !389)
!501 = !DILocation(line: 400, column: 58, scope: !389)
!502 = !DILocation(line: 400, column: 37, scope: !389)
!503 = !DILocation(line: 400, column: 35, scope: !389)
!504 = !DILocation(line: 401, column: 33, scope: !389)
!505 = !DILocation(line: 401, column: 31, scope: !389)
!506 = !DILocation(line: 402, column: 69, scope: !389)
!507 = !DILocation(line: 402, column: 66, scope: !389)
!508 = !DILocation(line: 402, column: 19, scope: !389)
!509 = !DILocation(line: 404, column: 31, scope: !389)
!510 = !DILocation(line: 408, column: 75, scope: !389)
!511 = !DILocation(line: 408, column: 88, scope: !389)
!512 = !DILocation(line: 408, column: 13, scope: !389)
!513 = !DILocation(line: 413, column: 31, scope: !389)
!514 = !DILocation(line: 414, column: 33, scope: !389)
!515 = !DILocation(line: 415, column: 21, scope: !389)
!516 = !DILocation(line: 415, column: 29, scope: !389)
!517 = !DILocation(line: 415, column: 27, scope: !389)
!518 = !DILocation(line: 415, column: 19, scope: !389)
!519 = !DILocation(line: 416, column: 22, scope: !389)
!520 = !DILocation(line: 416, column: 19, scope: !389)
!521 = !DILocation(line: 416, column: 13, scope: !389)
!522 = !DILocation(line: 417, column: 23, scope: !389)
!523 = !DILocation(line: 419, column: 63, scope: !389)
!524 = !DILocation(line: 419, column: 60, scope: !389)
!525 = !DILocation(line: 419, column: 13, scope: !389)
!526 = !DILocation(line: 421, column: 23, scope: !389)
!527 = !DILocation(line: 423, column: 69, scope: !389)
!528 = !DILocation(line: 423, column: 13, scope: !389)
!529 = !DILocation(line: 426, column: 13, scope: !389)
!530 = !DILocation(line: 430, column: 13, scope: !389)
!531 = !DILocation(line: 433, column: 48, scope: !389)
!532 = !DILocation(line: 433, column: 22, scope: !389)
!533 = !DILocation(line: 433, column: 19, scope: !389)
!534 = !DILocation(line: 433, column: 13, scope: !389)
!535 = !DILocation(line: 436, column: 34, scope: !389)
!536 = !DILocation(line: 436, column: 39, scope: !389)
!537 = !DILocation(line: 436, column: 50, scope: !389)
!538 = !DILocation(line: 436, column: 17, scope: !389)
!539 = !DILocation(line: 452, column: 49, scope: !389)
!540 = !DILocation(line: 452, column: 64, scope: !389)
!541 = !DILocation(line: 452, column: 31, scope: !389)
!542 = !DILocation(line: 453, column: 40, scope: !389)
!543 = !DILocation(line: 453, column: 17, scope: !389)
!544 = !DILocation(line: 454, column: 50, scope: !389)
!545 = !DILocation(line: 454, column: 66, scope: !389)
!546 = !DILocation(line: 454, column: 32, scope: !389)
!547 = !DILocation(line: 455, column: 40, scope: !389)
!548 = !DILocation(line: 455, column: 17, scope: !389)
!549 = !DILocation(line: 456, column: 17, scope: !389)
!550 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit", scope: null, file: !551, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!551 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/filters/wse3.csl", directory: "")
!552 = !DILocation(line: 24, column: 3, scope: !553)
!553 = !DILexicalBlockFile(scope: !550, file: !551, discriminator: 0)
!554 = !DILocation(line: 24, column: 22, scope: !553)
!555 = !DILocation(line: 23, column: 3, scope: !553)
!556 = !DILocation(line: 22, column: 3, scope: !553)
!557 = !DILocation(line: 20, column: 37, scope: !553)
!558 = !DILocation(line: 20, column: 21, scope: !553)
!559 = !DILocation(line: 21, column: 11, scope: !553)
!560 = !DILocation(line: 21, column: 17, scope: !553)
!561 = !DILocation(line: 21, column: 3, scope: !553)
!562 = !DILocation(line: 22, column: 24, scope: !553)
!563 = !DILocation(line: 22, column: 30, scope: !553)
!564 = !DILocation(line: 23, column: 40, scope: !553)
!565 = !DILocation(line: 23, column: 22, scope: !553)
!566 = !DILocation(line: 23, column: 67, scope: !553)
!567 = !DILocation(line: 24, column: 26, scope: !553)
!568 = !DILocation(line: 24, column: 41, scope: !553)
!569 = !DILocation(line: 24, column: 39, scope: !553)
!570 = !DILocation(line: 24, column: 61, scope: !553)
!571 = !DILocation(line: 24, column: 76, scope: !553)
!572 = !DILocation(line: 24, column: 74, scope: !553)
!573 = !DILocation(line: 25, column: 21, scope: !553)
!574 = !DILocation(line: 25, column: 50, scope: !553)
!575 = !DILocation(line: 25, column: 3, scope: !553)
!576 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter", scope: null, file: !551, line: 30, type: !5, scopeLine: 30, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!577 = !DILocation(line: 30, column: 36, scope: !578)
!578 = !DILexicalBlockFile(scope: !576, file: !551, discriminator: 0)
!579 = !DILocation(line: 30, column: 20, scope: !578)
!580 = !DILocation(line: 31, column: 11, scope: !578)
!581 = !DILocation(line: 31, column: 23, scope: !578)
!582 = !DILocation(line: 31, column: 3, scope: !578)
!583 = !DILocation(line: 32, column: 21, scope: !578)
!584 = !DILocation(line: 32, column: 48, scope: !578)
!585 = !DILocation(line: 32, column: 60, scope: !578)
!586 = !DILocation(line: 32, column: 64, scope: !578)
!587 = !DILocation(line: 32, column: 3, scope: !578)
!588 = !DILocation(line: 30, column: 1, scope: !578)
!589 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter", scope: null, file: !551, line: 40, type: !5, scopeLine: 40, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!590 = !DILocation(line: 47, column: 3, scope: !591)
!591 = !DILexicalBlockFile(scope: !589, file: !551, discriminator: 0)
!592 = !DILocation(line: 48, column: 7, scope: !591)
!593 = !DILocation(line: 44, column: 3, scope: !591)
!594 = !DILocation(line: 43, column: 3, scope: !591)
!595 = !DILocation(line: 42, column: 3, scope: !591)
!596 = !DILocation(line: 40, column: 32, scope: !591)
!597 = !DILocation(line: 40, column: 16, scope: !591)
!598 = !DILocation(line: 41, column: 11, scope: !591)
!599 = !DILocation(line: 41, column: 19, scope: !591)
!600 = !DILocation(line: 41, column: 3, scope: !591)
!601 = !DILocation(line: 42, column: 40, scope: !591)
!602 = !DILocation(line: 42, column: 22, scope: !591)
!603 = !DILocation(line: 43, column: 26, scope: !591)
!604 = !DILocation(line: 43, column: 34, scope: !591)
!605 = !DILocation(line: 44, column: 25, scope: !591)
!606 = !DILocation(line: 44, column: 42, scope: !591)
!607 = !DILocation(line: 44, column: 40, scope: !591)
!608 = !DILocation(line: 45, column: 21, scope: !591)
!609 = !DILocation(line: 46, column: 35, scope: !591)
!610 = !DILocation(line: 46, column: 21, scope: !591)
!611 = !DILocation(line: 46, column: 50, scope: !591)
!612 = !DILocation(line: 45, column: 3, scope: !591)
!613 = !DILocation(line: 48, column: 11, scope: !591)
!614 = !DILocation(line: 48, column: 26, scope: !591)
!615 = !DILocation(line: 48, column: 43, scope: !591)
!616 = !DILocation(line: 48, column: 41, scope: !591)
!617 = !DILocation(line: 48, column: 54, scope: !591)
!618 = !DILocation(line: 48, column: 63, scope: !591)
!619 = !DILocation(line: 49, column: 21, scope: !591)
!620 = !DILocation(line: 49, column: 47, scope: !591)
!621 = !DILocation(line: 49, column: 3, scope: !591)
!622 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config", scope: null, file: !623, line: 33, type: !5, scopeLine: 33, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!623 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/filters/common.csl", directory: "")
!624 = !DILocation(line: 33, column: 46, scope: !625)
!625 = !DILexicalBlockFile(scope: !622, file: !623, discriminator: 0)
!626 = !DILocation(line: 33, column: 31, scope: !625)
!627 = !DILocation(line: 33, column: 15, scope: !625)
!628 = !DILocation(line: 34, column: 24, scope: !625)
!629 = !DILocation(line: 34, column: 23, scope: !625)
!630 = !DILocation(line: 34, column: 51, scope: !625)
!631 = !DILocation(line: 34, column: 35, scope: !625)
!632 = !DILocation(line: 34, column: 60, scope: !625)
!633 = !DILocation(line: 34, column: 73, scope: !625)
!634 = !DILocation(line: 34, column: 3, scope: !625)
!635 = !DILocation(line: 33, column: 1, scope: !625)
!636 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config", scope: null, file: !623, line: 38, type: !5, scopeLine: 38, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!637 = !DILocation(line: 38, column: 31, scope: !638)
!638 = !DILexicalBlockFile(scope: !636, file: !623, discriminator: 0)
!639 = !DILocation(line: 38, column: 15, scope: !638)
!640 = !DILocation(line: 39, column: 31, scope: !638)
!641 = !DILocation(line: 39, column: 30, scope: !638)
!642 = !DILocation(line: 39, column: 58, scope: !638)
!643 = !DILocation(line: 39, column: 42, scope: !638)
!644 = !DILocation(line: 39, column: 67, scope: !638)
!645 = !DILocation(line: 39, column: 10, scope: !638)
!646 = !DILocation(line: 39, column: 3, scope: !638)
!647 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit", scope: null, file: !648, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!648 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/teardown.csl", directory: "")
!649 = !DILocation(line: 43, column: 3, scope: !650)
!650 = !DILexicalBlockFile(scope: !647, file: !648, discriminator: 0)
!651 = !DILocation(line: 41, column: 3, scope: !650)
!652 = !DILocation(line: 40, column: 3, scope: !650)
!653 = !DILocation(line: 39, column: 9, scope: !650)
!654 = !DILocation(line: 40, column: 23, scope: !650)
!655 = !DILocation(line: 41, column: 70, scope: !650)
!656 = !DILocation(line: 41, column: 68, scope: !650)
!657 = !DILocation(line: 43, column: 27, scope: !650)
!658 = !DILocation(line: 43, column: 15, scope: !650)
!659 = !DILocation(line: 44, column: 15, scope: !650)
!660 = !DILocation(line: 44, column: 21, scope: !650)
!661 = !DILocation(line: 44, column: 27, scope: !650)
!662 = !DILocation(line: 44, column: 3, scope: !650)
!663 = !DILocation(line: 39, column: 1, scope: !650)
!664 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord", scope: null, file: !665, line: 4, type: !5, scopeLine: 4, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!665 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/layout.csl", directory: "")
!666 = !DILocation(line: 5, column: 10, scope: !667)
!667 = !DILexicalBlockFile(scope: !664, file: !665, discriminator: 0)
!668 = !DILocation(line: 5, column: 67, scope: !667)
!669 = !DILocation(line: 5, column: 3, scope: !667)
!670 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord", scope: null, file: !665, line: 8, type: !5, scopeLine: 8, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!671 = !DILocation(line: 9, column: 10, scope: !672)
!672 = !DILexicalBlockFile(scope: !670, file: !665, discriminator: 0)
!673 = !DILocation(line: 9, column: 67, scope: !672)
!674 = !DILocation(line: 9, column: 3, scope: !672)
!675 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord", scope: null, file: !676, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!676 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config.csl", directory: "")
!677 = !DILocation(line: 50, column: 3, scope: !678)
!678 = !DILexicalBlockFile(scope: !675, file: !676, discriminator: 0)
!679 = !DILocation(line: 43, column: 21, scope: !678)
!680 = !DILocation(line: 50, column: 57, scope: !678)
!681 = !DILocation(line: 50, column: 68, scope: !678)
!682 = !DILocation(line: 50, column: 41, scope: !678)
!683 = !DILocation(line: 50, column: 19, scope: !678)
!684 = !DILocation(line: 52, column: 10, scope: !678)
!685 = !DILocation(line: 52, column: 18, scope: !678)
!686 = !DILocation(line: 48, column: 22, scope: !678)
!687 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.get_x_coord", scope: null, file: !688, line: 171, type: !5, scopeLine: 171, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!688 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpyd2h.csl", directory: "")
!689 = !DILocation(line: 172, column: 12, scope: !690)
!690 = !DILexicalBlockFile(scope: !687, file: !688, discriminator: 0)
!691 = !DILocation(line: 172, column: 5, scope: !690)
!692 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.get_y_coord", scope: null, file: !688, line: 174, type: !5, scopeLine: 174, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!693 = !DILocation(line: 175, column: 12, scope: !694)
!694 = !DILexicalBlockFile(scope: !692, file: !688, discriminator: 0)
!695 = !DILocation(line: 175, column: 5, scope: !694)
!696 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval", scope: null, file: !688, line: 187, type: !5, scopeLine: 187, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!697 = !DILocation(line: 187, column: 23, scope: !698)
!698 = !DILexicalBlockFile(scope: !696, file: !688, discriminator: 0)
!699 = !DILocation(line: 188, column: 9, scope: !698)
!700 = !DILocation(line: 188, column: 20, scope: !698)
!701 = !DILocation(line: 188, column: 5, scope: !698)
!702 = !DILocation(line: 191, column: 23, scope: !698)
!703 = !DILocation(line: 191, column: 20, scope: !698)
!704 = !DILocation(line: 191, column: 9, scope: !698)
!705 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start", scope: null, file: !688, line: 383, type: !5, scopeLine: 383, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!706 = !DILocation(line: 386, column: 5, scope: !707)
!707 = !DILexicalBlockFile(scope: !705, file: !688, discriminator: 0)
!708 = !DILocation(line: 384, column: 72, scope: !707)
!709 = !DILocation(line: 384, column: 59, scope: !707)
!710 = !DILocation(line: 384, column: 46, scope: !707)
!711 = !DILocation(line: 384, column: 33, scope: !707)
!712 = !DILocation(line: 384, column: 19, scope: !707)
!713 = !DILocation(line: 384, column: 5, scope: !707)
!714 = !DILocation(line: 383, column: 32, scope: !707)
!715 = !DILocation(line: 383, column: 21, scope: !707)
!716 = !DILocation(line: 386, column: 26, scope: !707)
!717 = !DILocation(line: 388, column: 28, scope: !707)
!718 = !DILocation(line: 388, column: 17, scope: !707)
!719 = !DILocation(line: 389, column: 25, scope: !707)
!720 = !DILocation(line: 389, column: 23, scope: !707)
!721 = !DILocation(line: 391, column: 38, scope: !707)
!722 = !DILocation(line: 391, column: 20, scope: !707)
!723 = !DILocation(line: 391, column: 18, scope: !707)
!724 = !DILocation(line: 393, column: 7, scope: !707)
!725 = !DILocation(line: 395, column: 17, scope: !707)
!726 = !DILocation(line: 395, column: 15, scope: !707)
!727 = !DILocation(line: 397, column: 15, scope: !707)
!728 = !DILocation(line: 397, column: 13, scope: !707)
!729 = !DILocation(line: 398, column: 15, scope: !707)
!730 = !DILocation(line: 398, column: 25, scope: !707)
!731 = !DILocation(line: 398, column: 23, scope: !707)
!732 = !DILocation(line: 398, column: 31, scope: !707)
!733 = !DILocation(line: 398, column: 13, scope: !707)
!734 = !DILocation(line: 401, column: 10, scope: !707)
!735 = !DILocation(line: 401, column: 17, scope: !707)
!736 = !DILocation(line: 401, column: 14, scope: !707)
!737 = !DILocation(line: 401, column: 5, scope: !707)
!738 = !DILocation(line: 403, column: 48, scope: !707)
!739 = !DILocation(line: 403, column: 26, scope: !707)
!740 = !DILocation(line: 404, column: 26, scope: !707)
!741 = !DILocation(line: 404, column: 18, scope: !707)
!742 = !DILocation(line: 407, column: 48, scope: !707)
!743 = !DILocation(line: 407, column: 26, scope: !707)
!744 = !DILocation(line: 408, column: 27, scope: !707)
!745 = !DILocation(line: 408, column: 18, scope: !707)
!746 = !DILocation(line: 411, column: 14, scope: !707)
!747 = !DILocation(line: 414, column: 14, scope: !707)
!748 = !DILocation(line: 414, column: 11, scope: !707)
!749 = !DILocation(line: 414, column: 5, scope: !707)
!750 = !DILocation(line: 416, column: 44, scope: !707)
!751 = !DILocation(line: 416, column: 75, scope: !707)
!752 = !DILocation(line: 416, column: 59, scope: !707)
!753 = !DILocation(line: 416, column: 25, scope: !707)
!754 = !DILocation(line: 416, column: 23, scope: !707)
!755 = !DILocation(line: 418, column: 41, scope: !707)
!756 = !DILocation(line: 418, column: 23, scope: !707)
!757 = !DILocation(line: 419, column: 9, scope: !707)
!758 = !DILocation(line: 425, column: 44, scope: !707)
!759 = !DILocation(line: 425, column: 23, scope: !707)
!760 = !DILocation(line: 426, column: 41, scope: !707)
!761 = !DILocation(line: 426, column: 23, scope: !707)
!762 = !DILocation(line: 427, column: 9, scope: !707)
!763 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x", scope: null, file: !688, line: 448, type: !5, scopeLine: 448, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!764 = !DILocation(line: 448, column: 31, scope: !765)
!765 = !DILexicalBlockFile(scope: !763, file: !688, discriminator: 0)
!766 = !DILocation(line: 453, column: 5, scope: !765)
!767 = !DILocation(line: 456, column: 19, scope: !765)
!768 = !DILocation(line: 456, column: 17, scope: !765)
!769 = !DILocation(line: 461, column: 5, scope: !765)
!770 = !DILocation(line: 462, column: 28, scope: !765)
!771 = !DILocation(line: 462, column: 5, scope: !765)
!772 = !DILocation(line: 463, column: 5, scope: !765)
!773 = !DILocation(line: 464, column: 9, scope: !765)
!774 = !DILocation(line: 464, column: 10, scope: !765)
!775 = !DILocation(line: 464, column: 7, scope: !765)
!776 = !DILocation(line: 448, column: 1, scope: !765)
!777 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_send_data", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_send_data", scope: null, file: !688, line: 476, type: !5, scopeLine: 476, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!778 = !DILocation(line: 494, column: 9, scope: !779)
!779 = !DILexicalBlockFile(scope: !777, file: !688, discriminator: 0)
!780 = !DILocation(line: 478, column: 9, scope: !779)
!781 = !DILocation(line: 478, column: 13, scope: !779)
!782 = !DILocation(line: 478, column: 11, scope: !779)
!783 = !DILocation(line: 478, column: 5, scope: !779)
!784 = !DILocation(line: 479, column: 9, scope: !779)
!785 = !DILocation(line: 480, column: 32, scope: !779)
!786 = !DILocation(line: 480, column: 9, scope: !779)
!787 = !DILocation(line: 481, column: 17, scope: !779)
!788 = !DILocation(line: 481, column: 15, scope: !779)
!789 = !DILocation(line: 481, column: 9, scope: !779)
!790 = !DILocation(line: 482, column: 13, scope: !779)
!791 = !DILocation(line: 483, column: 51, scope: !779)
!792 = !DILocation(line: 483, column: 29, scope: !779)
!793 = !DILocation(line: 483, column: 27, scope: !779)
!794 = !DILocation(line: 485, column: 13, scope: !779)
!795 = !DILocation(line: 486, column: 51, scope: !779)
!796 = !DILocation(line: 486, column: 29, scope: !779)
!797 = !DILocation(line: 486, column: 27, scope: !779)
!798 = !DILocation(line: 488, column: 13, scope: !779)
!799 = !DILocation(line: 488, column: 14, scope: !779)
!800 = !DILocation(line: 488, column: 11, scope: !779)
!801 = !DILocation(line: 494, column: 30, scope: !779)
!802 = !DILocation(line: 496, column: 14, scope: !779)
!803 = !DILocation(line: 496, column: 25, scope: !779)
!804 = !DILocation(line: 496, column: 22, scope: !779)
!805 = !DILocation(line: 496, column: 9, scope: !779)
!806 = !DILocation(line: 497, column: 13, scope: !779)
!807 = !DILocation(line: 498, column: 13, scope: !779)
!808 = !DILocation(line: 499, column: 13, scope: !779)
!809 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl", scope: null, file: !688, line: 505, type: !5, scopeLine: 505, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!810 = !DILocation(line: 524, column: 13, scope: !811)
!811 = !DILexicalBlockFile(scope: !809, file: !688, discriminator: 0)
!812 = !DILocation(line: 506, column: 14, scope: !811)
!813 = !DILocation(line: 506, column: 11, scope: !811)
!814 = !DILocation(line: 506, column: 5, scope: !811)
!815 = !DILocation(line: 508, column: 9, scope: !811)
!816 = !DILocation(line: 509, column: 32, scope: !811)
!817 = !DILocation(line: 509, column: 9, scope: !811)
!818 = !DILocation(line: 510, column: 9, scope: !811)
!819 = !DILocation(line: 514, column: 13, scope: !811)
!820 = !DILocation(line: 514, column: 17, scope: !811)
!821 = !DILocation(line: 514, column: 15, scope: !811)
!822 = !DILocation(line: 514, column: 9, scope: !811)
!823 = !DILocation(line: 518, column: 13, scope: !811)
!824 = !DILocation(line: 519, column: 36, scope: !811)
!825 = !DILocation(line: 519, column: 13, scope: !811)
!826 = !DILocation(line: 520, column: 13, scope: !811)
!827 = !DILocation(line: 524, column: 34, scope: !811)
!828 = !DILocation(line: 526, column: 18, scope: !811)
!829 = !DILocation(line: 526, column: 29, scope: !811)
!830 = !DILocation(line: 526, column: 26, scope: !811)
!831 = !DILocation(line: 526, column: 13, scope: !811)
!832 = !DILocation(line: 529, column: 17, scope: !811)
!833 = !DILocation(line: 530, column: 17, scope: !811)
!834 = !DILocation(line: 531, column: 17, scope: !811)
!835 = !DILocation(line: 534, column: 17, scope: !811)
!836 = !DILocation(line: 535, column: 40, scope: !811)
!837 = !DILocation(line: 535, column: 17, scope: !811)
!838 = !DILocation(line: 536, column: 17, scope: !811)
!839 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.d2h_configure", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.d2h_configure", scope: null, file: !688, line: 593, type: !5, scopeLine: 593, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!840 = !DILocation(line: 617, column: 26, scope: !841)
!841 = !DILexicalBlockFile(scope: !839, file: !688, discriminator: 0)
!842 = !DILocation(line: 612, column: 47, scope: !841)
!843 = !DILocation(line: 612, column: 27, scope: !841)
!844 = !DILocation(line: 602, column: 5, scope: !841)
!845 = !DILocation(line: 601, column: 5, scope: !841)
!846 = !DILocation(line: 599, column: 5, scope: !841)
!847 = !DILocation(line: 598, column: 5, scope: !841)
!848 = !DILocation(line: 596, column: 5, scope: !841)
!849 = !DILocation(line: 595, column: 5, scope: !841)
!850 = !DILocation(line: 593, column: 86, scope: !841)
!851 = !DILocation(line: 593, column: 70, scope: !841)
!852 = !DILocation(line: 593, column: 60, scope: !841)
!853 = !DILocation(line: 593, column: 52, scope: !841)
!854 = !DILocation(line: 593, column: 44, scope: !841)
!855 = !DILocation(line: 593, column: 35, scope: !841)
!856 = !DILocation(line: 593, column: 26, scope: !841)
!857 = !DILocation(line: 593, column: 18, scope: !841)
!858 = !DILocation(line: 595, column: 26, scope: !841)
!859 = !DILocation(line: 596, column: 26, scope: !841)
!860 = !DILocation(line: 598, column: 23, scope: !841)
!861 = !DILocation(line: 599, column: 23, scope: !841)
!862 = !DILocation(line: 599, column: 28, scope: !841)
!863 = !DILocation(line: 599, column: 26, scope: !841)
!864 = !DILocation(line: 599, column: 29, scope: !841)
!865 = !DILocation(line: 601, column: 24, scope: !841)
!866 = !DILocation(line: 602, column: 24, scope: !841)
!867 = !DILocation(line: 602, column: 29, scope: !841)
!868 = !DILocation(line: 602, column: 27, scope: !841)
!869 = !DILocation(line: 602, column: 30, scope: !841)
!870 = !DILocation(line: 611, column: 20, scope: !841)
!871 = !DILocation(line: 612, column: 11, scope: !841)
!872 = !DILocation(line: 612, column: 18, scope: !841)
!873 = !DILocation(line: 612, column: 15, scope: !841)
!874 = !DILocation(line: 612, column: 32, scope: !841)
!875 = !DILocation(line: 612, column: 39, scope: !841)
!876 = !DILocation(line: 612, column: 36, scope: !841)
!877 = !DILocation(line: 612, column: 52, scope: !841)
!878 = !DILocation(line: 612, column: 59, scope: !841)
!879 = !DILocation(line: 612, column: 56, scope: !841)
!880 = !DILocation(line: 612, column: 5, scope: !841)
!881 = !DILocation(line: 613, column: 24, scope: !841)
!882 = !DILocation(line: 616, column: 15, scope: !841)
!883 = !DILocation(line: 617, column: 11, scope: !841)
!884 = !DILocation(line: 617, column: 18, scope: !841)
!885 = !DILocation(line: 617, column: 15, scope: !841)
!886 = !DILocation(line: 617, column: 30, scope: !841)
!887 = !DILocation(line: 617, column: 5, scope: !841)
!888 = !DILocation(line: 618, column: 19, scope: !841)
!889 = !DILocation(line: 621, column: 9, scope: !841)
!890 = !DILocation(line: 621, column: 5, scope: !841)
!891 = !DILocation(line: 627, column: 9, scope: !841)
!892 = !DILocation(line: 629, column: 13, scope: !841)
!893 = !DILocation(line: 629, column: 25, scope: !841)
!894 = !DILocation(line: 629, column: 21, scope: !841)
!895 = !DILocation(line: 629, column: 9, scope: !841)
!896 = !DILocation(line: 632, column: 13, scope: !841)
!897 = !DILocation(line: 636, column: 13, scope: !841)
!898 = !DILocation(line: 641, column: 9, scope: !841)
!899 = !DILocation(line: 646, column: 13, scope: !841)
!900 = !DILocation(line: 646, column: 9, scope: !841)
!901 = !DILocation(line: 647, column: 30, scope: !841)
!902 = !DILocation(line: 647, column: 35, scope: !841)
!903 = !DILocation(line: 647, column: 46, scope: !841)
!904 = !DILocation(line: 647, column: 50, scope: !841)
!905 = !DILocation(line: 647, column: 54, scope: !841)
!906 = !DILocation(line: 647, column: 57, scope: !841)
!907 = !DILocation(line: 647, column: 60, scope: !841)
!908 = !DILocation(line: 647, column: 63, scope: !841)
!909 = !DILocation(line: 647, column: 13, scope: !841)
!910 = !DILocation(line: 661, column: 9, scope: !841)
!911 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit", scope: null, file: !648, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!912 = !DILocation(line: 43, column: 3, scope: !913)
!913 = !DILexicalBlockFile(scope: !911, file: !648, discriminator: 0)
!914 = !DILocation(line: 41, column: 3, scope: !913)
!915 = !DILocation(line: 40, column: 3, scope: !913)
!916 = !DILocation(line: 39, column: 9, scope: !913)
!917 = !DILocation(line: 40, column: 23, scope: !913)
!918 = !DILocation(line: 41, column: 70, scope: !913)
!919 = !DILocation(line: 41, column: 68, scope: !913)
!920 = !DILocation(line: 43, column: 27, scope: !913)
!921 = !DILocation(line: 43, column: 15, scope: !913)
!922 = !DILocation(line: 44, column: 15, scope: !913)
!923 = !DILocation(line: 44, column: 21, scope: !913)
!924 = !DILocation(line: 44, column: 27, scope: !913)
!925 = !DILocation(line: 44, column: 3, scope: !913)
!926 = !DILocation(line: 39, column: 1, scope: !913)
!927 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord", scope: null, file: !665, line: 4, type: !5, scopeLine: 4, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!928 = !DILocation(line: 5, column: 10, scope: !929)
!929 = !DILexicalBlockFile(scope: !927, file: !665, discriminator: 0)
!930 = !DILocation(line: 5, column: 67, scope: !929)
!931 = !DILocation(line: 5, column: 3, scope: !929)
!932 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord", scope: null, file: !665, line: 8, type: !5, scopeLine: 8, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!933 = !DILocation(line: 9, column: 10, scope: !934)
!934 = !DILexicalBlockFile(scope: !932, file: !665, discriminator: 0)
!935 = !DILocation(line: 9, column: 67, scope: !934)
!936 = !DILocation(line: 9, column: 3, scope: !934)
!937 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord", scope: null, file: !676, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!938 = !DILocation(line: 50, column: 3, scope: !939)
!939 = !DILexicalBlockFile(scope: !937, file: !676, discriminator: 0)
!940 = !DILocation(line: 43, column: 21, scope: !939)
!941 = !DILocation(line: 50, column: 57, scope: !939)
!942 = !DILocation(line: 50, column: 68, scope: !939)
!943 = !DILocation(line: 50, column: 41, scope: !939)
!944 = !DILocation(line: 50, column: 19, scope: !939)
!945 = !DILocation(line: 52, column: 10, scope: !939)
!946 = !DILocation(line: 52, column: 18, scope: !939)
!947 = !DILocation(line: 48, column: 22, scope: !939)
!948 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr", linkageName: "sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr", scope: null, file: !949, line: 11, type: !5, scopeLine: 11, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!949 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/input_queue_config.csl", directory: "")
!950 = !DILocation(line: 11, column: 32, scope: !951)
!951 = !DILexicalBlockFile(scope: !948, file: !949, discriminator: 0)
!952 = !DILocation(line: 12, column: 80, scope: !951)
!953 = !DILocation(line: 12, column: 69, scope: !951)
!954 = !DILocation(line: 12, column: 39, scope: !951)
!955 = !DILocation(line: 12, column: 3, scope: !951)
!956 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue", linkageName: "sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue", scope: null, file: !949, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!957 = !DILocation(line: 46, column: 3, scope: !958)
!958 = !DILexicalBlockFile(scope: !956, file: !949, discriminator: 0)
!959 = !DILocation(line: 45, column: 3, scope: !958)
!960 = !DILocation(line: 39, column: 42, scope: !958)
!961 = !DILocation(line: 39, column: 34, scope: !958)
!962 = !DILocation(line: 39, column: 24, scope: !958)
!963 = !DILocation(line: 45, column: 44, scope: !958)
!964 = !DILocation(line: 45, column: 16, scope: !958)
!965 = !DILocation(line: 46, column: 30, scope: !958)
!966 = !DILocation(line: 46, column: 18, scope: !958)
!967 = !DILocation(line: 56, column: 9, scope: !958)
!968 = !DILocation(line: 56, column: 5, scope: !958)
!969 = !DILocation(line: 58, column: 13, scope: !958)
!970 = !DILocation(line: 58, column: 17, scope: !958)
!971 = !DILocation(line: 58, column: 11, scope: !958)
!972 = !DILocation(line: 61, column: 13, scope: !958)
!973 = !DILocation(line: 61, column: 17, scope: !958)
!974 = !DILocation(line: 61, column: 11, scope: !958)
!975 = !DILocation(line: 66, column: 9, scope: !958)
!976 = !DILocation(line: 66, column: 13, scope: !958)
!977 = !DILocation(line: 66, column: 7, scope: !958)
!978 = !DILocation(line: 68, column: 9, scope: !958)
!979 = !DILocation(line: 68, column: 24, scope: !958)
!980 = !DILocation(line: 68, column: 13, scope: !958)
!981 = !DILocation(line: 68, column: 7, scope: !958)
!982 = !DILocation(line: 70, column: 15, scope: !958)
!983 = !DILocation(line: 70, column: 21, scope: !958)
!984 = !DILocation(line: 70, column: 3, scope: !958)
!985 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr", linkageName: "sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr", scope: null, file: !986, line: 11, type: !5, scopeLine: 11, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!986 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/output_queue_config.csl", directory: "")
!987 = !DILocation(line: 11, column: 33, scope: !988)
!988 = !DILexicalBlockFile(scope: !985, file: !986, discriminator: 0)
!989 = !DILocation(line: 12, column: 82, scope: !988)
!990 = !DILocation(line: 12, column: 40, scope: !988)
!991 = !DILocation(line: 12, column: 3, scope: !988)
!992 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue", linkageName: "sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue", scope: null, file: !986, line: 31, type: !5, scopeLine: 31, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!993 = !DILocation(line: 38, column: 3, scope: !994)
!994 = !DILexicalBlockFile(scope: !992, file: !986, discriminator: 0)
!995 = !DILocation(line: 37, column: 3, scope: !994)
!996 = !DILocation(line: 31, column: 35, scope: !994)
!997 = !DILocation(line: 31, column: 25, scope: !994)
!998 = !DILocation(line: 37, column: 45, scope: !994)
!999 = !DILocation(line: 37, column: 16, scope: !994)
!1000 = !DILocation(line: 38, column: 30, scope: !994)
!1001 = !DILocation(line: 38, column: 18, scope: !994)
!1002 = !DILocation(line: 41, column: 9, scope: !994)
!1003 = !DILocation(line: 41, column: 13, scope: !994)
!1004 = !DILocation(line: 41, column: 7, scope: !994)
!1005 = !DILocation(line: 43, column: 9, scope: !994)
!1006 = !DILocation(line: 43, column: 24, scope: !994)
!1007 = !DILocation(line: 43, column: 13, scope: !994)
!1008 = !DILocation(line: 43, column: 27, scope: !994)
!1009 = !DILocation(line: 43, column: 7, scope: !994)
!1010 = !DILocation(line: 45, column: 15, scope: !994)
!1011 = !DILocation(line: 45, column: 21, scope: !994)
!1012 = !DILocation(line: 45, column: 3, scope: !994)
!1013 = !DILocation(line: 31, column: 1, scope: !994)
!1014 = distinct !DISubprogram(name: ".get_tensor_ptr", linkageName: ".get_tensor_ptr", scope: null, file: !4, line: 1, type: !5, scopeLine: 1, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1015 = !DILocation(line: 1, column: 1, scope: !1016)
!1016 = !DILexicalBlockFile(scope: !1014, file: !4, discriminator: 0)
!1017 = distinct !DISubprogram(name: "__generic0sys_mod.sys_mod.tile_config.queue_flush.exit", linkageName: "__generic0sys_mod.sys_mod.tile_config.queue_flush.exit", scope: null, file: !1018, line: 12, type: !5, scopeLine: 12, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1018 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/queue_flush.csl", directory: "")
!1019 = !DILocation(line: 24, column: 3, scope: !1020)
!1020 = !DILexicalBlockFile(scope: !1017, file: !1018, discriminator: 0)
!1021 = !DILocation(line: 12, column: 1, scope: !1020)
!1022 = distinct !DISubprogram(name: "__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position", linkageName: "__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position", scope: null, file: !1023, line: 30, type: !5, scopeLine: 30, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1023 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/switch_config.csl", directory: "")
!1024 = !DILocation(line: 34, column: 3, scope: !1025)
!1025 = !DILexicalBlockFile(scope: !1022, file: !1023, discriminator: 0)
!1026 = !DILocation(line: 32, column: 3, scope: !1025)
!1027 = !DILocation(line: 30, column: 27, scope: !1025)
!1028 = !DILocation(line: 33, column: 7, scope: !1025)
!1029 = !DILocation(line: 34, column: 36, scope: !1025)
!1030 = !DILocation(line: 34, column: 24, scope: !1025)
!1031 = !DILocation(line: 35, column: 3, scope: !1025)
!1032 = !DILocation(line: 35, column: 18, scope: !1025)
!1033 = !DILocation(line: 36, column: 15, scope: !1025)
!1034 = !DILocation(line: 36, column: 21, scope: !1025)
!1035 = !DILocation(line: 36, column: 3, scope: !1025)
!1036 = !DILocation(line: 30, column: 1, scope: !1025)
!1037 = distinct !DISubprogram(name: "__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", linkageName: "__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", scope: null, file: !1038, line: 96, type: !5, scopeLine: 96, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1038 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/color_config.csl", directory: "")
!1039 = !DILocation(line: 99, column: 3, scope: !1040)
!1040 = !DILexicalBlockFile(scope: !1037, file: !1038, discriminator: 0)
!1041 = !DILocation(line: 98, column: 3, scope: !1040)
!1042 = !DILocation(line: 96, column: 17, scope: !1040)
!1043 = !DILocation(line: 98, column: 16, scope: !1040)
!1044 = !DILocation(line: 99, column: 29, scope: !1040)
!1045 = !DILocation(line: 99, column: 17, scope: !1040)
!1046 = !DILocation(line: 100, column: 13, scope: !1040)
!1047 = !DILocation(line: 100, column: 21, scope: !1040)
!1048 = !DILocation(line: 100, column: 11, scope: !1040)
!1049 = !DILocation(line: 104, column: 7, scope: !1040)
!1050 = !DILocation(line: 104, column: 50, scope: !1040)
!1051 = !DILocation(line: 104, column: 18, scope: !1040)
!1052 = !DILocation(line: 104, column: 15, scope: !1040)
!1053 = !DILocation(line: 121, column: 7, scope: !1040)
!1054 = !DILocation(line: 121, column: 50, scope: !1040)
!1055 = !DILocation(line: 121, column: 18, scope: !1040)
!1056 = !DILocation(line: 121, column: 15, scope: !1040)
!1057 = !DILocation(line: 128, column: 15, scope: !1040)
!1058 = !DILocation(line: 128, column: 21, scope: !1040)
!1059 = !DILocation(line: 128, column: 3, scope: !1040)
!1060 = !DILocation(line: 96, column: 1, scope: !1040)
!1061 = distinct !DISubprogram(name: "__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", linkageName: "__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", scope: null, file: !1038, line: 96, type: !5, scopeLine: 96, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1062 = !DILocation(line: 99, column: 3, scope: !1063)
!1063 = !DILexicalBlockFile(scope: !1061, file: !1038, discriminator: 0)
!1064 = !DILocation(line: 98, column: 3, scope: !1063)
!1065 = !DILocation(line: 96, column: 17, scope: !1063)
!1066 = !DILocation(line: 98, column: 16, scope: !1063)
!1067 = !DILocation(line: 99, column: 29, scope: !1063)
!1068 = !DILocation(line: 99, column: 17, scope: !1063)
!1069 = !DILocation(line: 100, column: 13, scope: !1063)
!1070 = !DILocation(line: 100, column: 21, scope: !1063)
!1071 = !DILocation(line: 100, column: 11, scope: !1063)
!1072 = !DILocation(line: 104, column: 7, scope: !1063)
!1073 = !DILocation(line: 104, column: 50, scope: !1063)
!1074 = !DILocation(line: 104, column: 18, scope: !1063)
!1075 = !DILocation(line: 104, column: 15, scope: !1063)
!1076 = !DILocation(line: 121, column: 7, scope: !1063)
!1077 = !DILocation(line: 121, column: 50, scope: !1063)
!1078 = !DILocation(line: 121, column: 18, scope: !1063)
!1079 = !DILocation(line: 121, column: 15, scope: !1063)
!1080 = !DILocation(line: 128, column: 15, scope: !1063)
!1081 = !DILocation(line: 128, column: 21, scope: !1063)
!1082 = !DILocation(line: 128, column: 3, scope: !1063)
!1083 = !DILocation(line: 96, column: 1, scope: !1063)
!1084 = distinct !DISubprogram(name: "__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", linkageName: "__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", scope: null, file: !1038, line: 60, type: !5, scopeLine: 60, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1085 = !DILocation(line: 61, column: 3, scope: !1086)
!1086 = !DILexicalBlockFile(scope: !1084, file: !1038, discriminator: 0)
!1087 = !DILocation(line: 60, column: 46, scope: !1086)
!1088 = !DILocation(line: 61, column: 16, scope: !1086)
!1089 = !DILocation(line: 72, column: 5, scope: !1086)
!1090 = !DILocation(line: 72, column: 12, scope: !1086)
!1091 = !DILocation(line: 74, column: 10, scope: !1086)
!1092 = !DILocation(line: 74, column: 3, scope: !1086)
!1093 = distinct !DISubprogram(name: "__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes", linkageName: "__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes", scope: null, file: !1038, line: 77, type: !5, scopeLine: 77, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1094 = !DILocation(line: 78, column: 3, scope: !1095)
!1095 = !DILexicalBlockFile(scope: !1093, file: !1038, discriminator: 0)
!1096 = !DILocation(line: 77, column: 46, scope: !1095)
!1097 = !DILocation(line: 78, column: 16, scope: !1095)
!1098 = !DILocation(line: 86, column: 5, scope: !1095)
!1099 = !DILocation(line: 86, column: 12, scope: !1095)
!1100 = !DILocation(line: 91, column: 10, scope: !1095)
!1101 = !DILocation(line: 91, column: 3, scope: !1095)
!1102 = distinct !DISubprogram(name: "__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", linkageName: "__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", scope: null, file: !1038, line: 60, type: !5, scopeLine: 60, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1103 = !DILocation(line: 61, column: 3, scope: !1104)
!1104 = !DILexicalBlockFile(scope: !1102, file: !1038, discriminator: 0)
!1105 = !DILocation(line: 60, column: 46, scope: !1104)
!1106 = !DILocation(line: 61, column: 16, scope: !1104)
!1107 = !DILocation(line: 63, column: 5, scope: !1104)
!1108 = !DILocation(line: 63, column: 12, scope: !1104)
!1109 = !DILocation(line: 74, column: 10, scope: !1104)
!1110 = !DILocation(line: 74, column: 3, scope: !1104)
!1111 = distinct !DISubprogram(name: "__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction", linkageName: "__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction", scope: null, file: !1038, line: 52, type: !5, scopeLine: 52, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1112 = !DILocation(line: 55, column: 3, scope: !1113)
!1113 = !DILexicalBlockFile(scope: !1111, file: !1038, discriminator: 0)
!1114 = !DILocation(line: 54, column: 3, scope: !1113)
!1115 = !DILocation(line: 52, column: 23, scope: !1113)
!1116 = !DILocation(line: 54, column: 16, scope: !1113)
!1117 = !DILocation(line: 55, column: 29, scope: !1113)
!1118 = !DILocation(line: 55, column: 17, scope: !1113)
!1119 = !DILocation(line: 56, column: 3, scope: !1113)
!1120 = !DILocation(line: 56, column: 11, scope: !1113)
!1121 = !DILocation(line: 57, column: 15, scope: !1113)
!1122 = !DILocation(line: 57, column: 21, scope: !1113)
!1123 = !DILocation(line: 57, column: 3, scope: !1113)
!1124 = !DILocation(line: 52, column: 1, scope: !1113)
!1125 = distinct !DISubprogram(name: "__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction", linkageName: "__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction", scope: null, file: !1038, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1126 = !DILocation(line: 23, column: 3, scope: !1127)
!1127 = !DILexicalBlockFile(scope: !1125, file: !1038, discriminator: 0)
!1128 = !DILocation(line: 22, column: 3, scope: !1127)
!1129 = !DILocation(line: 20, column: 21, scope: !1127)
!1130 = !DILocation(line: 22, column: 16, scope: !1127)
!1131 = !DILocation(line: 23, column: 29, scope: !1127)
!1132 = !DILocation(line: 23, column: 17, scope: !1127)
!1133 = !DILocation(line: 24, column: 3, scope: !1127)
!1134 = !DILocation(line: 24, column: 11, scope: !1127)
!1135 = !DILocation(line: 25, column: 15, scope: !1127)
!1136 = !DILocation(line: 25, column: 21, scope: !1127)
!1137 = !DILocation(line: 25, column: 3, scope: !1127)
!1138 = !DILocation(line: 20, column: 1, scope: !1127)
module asm ".section \22.pe_debug_info\22, \22\22"
module asm ".section \22.note\22, \22\22"
