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
  call void asm sideeffect "movri r5 = 0x3e00", ""()
  call void asm sideeffect "movri r8 = 0x3c00", ""()
  call void asm sideeffect "add16.nf r5 = r5, r8", ""()
  call void asm sideeffect "add16.nf r5 = r5, r8", ""()
  store i16 24577, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i2 1), align 2, !dbg !9
  call void asm sideeffect "movri r5 = 0x3e00", ""()
  call void asm sideeffect "movri r8 = 0x3c00", ""()
  call void asm sideeffect "add16.nf r5 = r5, r8", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "add16.nf r5 = r5, r8", ""()
  store i16 24578, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i3 2), align 2, !dbg !10
  call void asm sideeffect "movri r5 = 0x3e00", ""()
  call void asm sideeffect "movri r8 = 0x3c00", ""()
  call void asm sideeffect "add16.nf r5 = r5, r8", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "add16.nf r5 = r5, r8", ""()
  store i16 24579, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i3 3), align 2, !dbg !11
  call void asm sideeffect "movri r5 = 0x3e00", ""()
  call void asm sideeffect "movri r8 = 0x3c00", ""()
  call void asm sideeffect "add16.nf r5 = r5, r8", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "add16.nf r5 = r5, r8", ""()
  store i16 24580, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i4 4), align 2, !dbg !12
  call void asm sideeffect "movri r5 = 0x3e00", ""()
  call void asm sideeffect "movri r8 = 0x3c00", ""()
  call void asm sideeffect "add16.nf r5 = r5, r8", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "add16.nf r5 = r5, r8", ""()
  store i16 24581, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i4 5), align 2, !dbg !13
  call void asm sideeffect "movri r5 = 0x3e00", ""()
  call void asm sideeffect "movri r8 = 0x3c00", ""()
  call void asm sideeffect "add16.nf r5 = r5, r8", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "add16.nf r5 = r5, r8", ""()
  store i16 24582, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i4 6), align 2, !dbg !14
  call void asm sideeffect "movri r5 = 0x3e00", ""()
  call void asm sideeffect "movri r8 = 0x3c00", ""()
  call void asm sideeffect "add16.nf r5 = r5, r8", ""()
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
  call void asm sideeffect "add16.nf r5 = r5, r8", ""()
  store i16 24583, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i4 7), align 2, !dbg !15
  call void asm sideeffect "movri r5 = 0x3e00", ""()
  call void asm sideeffect "movri r8 = 0x3c00", ""()
  call void asm sideeffect "add16.nf r5 = r5, r8", ""()
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
  call void asm sideeffect "add16.nf r5 = r5, r8", ""()
  store i16 24584, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i5 8), align 2, !dbg !16
  call void @llvm.sdr.actvt.r(i16 9), !dbg !17
  ret void, !dbg !18
}

define void @f_exit() #0 !dbg !19 {
  call void @sys_mod.unblock_cmd_stream(), !dbg !20
  ret void, !dbg !22
}

define internal void @sys_mod.sys_nop() !dbg !23 {
  ret void, !dbg !25
}

define internal void @sys_mod.unblock_cmd_stream() !dbg !27 {
  call void @sys_mod.sys_mod.unblock_cmd_stream(), !dbg !28
  ret void, !dbg !30
}

define internal void @sys_mod.sys_mod.unblock_cmd_stream() !dbg !31 {
  call void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream(), !dbg !33
  ret void, !dbg !35
}

define internal void @sys_mod.sys_mod.teardown_h2d() !dbg !36 {
  call void @llvm.sdr.actvt.r(i16 27), !dbg !37
  ret void, !dbg !39
}

define void @sys_mod.sys_mod.f_ublk_c22() #1 !dbg !40 {
  call void @sys_mod.sys_mod.unblock_cmd_stream(), !dbg !41
  ret void, !dbg !43
}

define internal void @sys_mod.sys_mod.teardown_d2h() !dbg !44 {
  call void @llvm.sdr.blk.r(i16 0), !dbg !45
  call void @llvm.sdr.actvt.r(i16 28), !dbg !47
  ret void, !dbg !48
}

define void @sys_mod.sys_mod.f_memcpyh2d() #2 !dbg !49 {
  %1 = alloca float, i16 1, align 4, !dbg !50
  %2 = alloca float, i16 1, align 4, !dbg !52
  %3 = alloca i16, i16 1, align 2, !dbg !53
  %4 = alloca i16, i16 1, align 2, !dbg !54
  %5 = alloca i16, i16 1, align 2, !dbg !55
  %6 = alloca i16, i16 1, align 2, !dbg !56
  %7 = alloca i16, i16 1, align 2, !dbg !57
  %8 = alloca i16, i16 1, align 2, !dbg !58
  %9 = alloca i16, i16 1, align 2, !dbg !59
  %10 = alloca i16, i16 1, align 2, !dbg !60
  %11 = alloca i16, i16 1, align 2, !dbg !61
  %12 = alloca i16, i16 1, align 2, !dbg !62
  %13 = alloca i16, i16 1, align 2, !dbg !63
  %14 = alloca i16*, i16 1, align 8, !dbg !64
  %15 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !65
  %16 = icmp eq i16 %15, 15, !dbg !66
  br i1 %16, label %17, label %18, !dbg !67

17:                                               ; preds = %0
  br label %19, !dbg !67

18:                                               ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !67
  br label %19, !dbg !67

19:                                               ; preds = %17, %18
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %14, align 8, !dbg !64
  %20 = load i16*, i16** %14, align 8, !dbg !68
  %21 = load i16, i16* %20, align 2, !dbg !69
  store i16 %21, i16* %13, align 2, !dbg !63
  %22 = load i16*, i16** %14, align 8, !dbg !70
  %23 = getelementptr i16, i16* %22, i16 1, !dbg !71
  %24 = load i16, i16* %23, align 2, !dbg !71
  store i16 %24, i16* %12, align 2, !dbg !62
  %25 = load i16*, i16** %14, align 8, !dbg !72
  %26 = getelementptr i16, i16* %25, i16 2, !dbg !73
  %27 = load i16, i16* %26, align 2, !dbg !73
  store i16 %27, i16* %11, align 2, !dbg !61
  %28 = load i16*, i16** %14, align 8, !dbg !74
  %29 = getelementptr i16, i16* %28, i16 3, !dbg !75
  %30 = load i16, i16* %29, align 2, !dbg !75
  store i16 %30, i16* %10, align 2, !dbg !60
  %31 = load i16*, i16** %14, align 8, !dbg !76
  %32 = getelementptr i16, i16* %31, i16 4, !dbg !77
  %33 = load i16, i16* %32, align 2, !dbg !77
  store i16 %33, i16* %9, align 2, !dbg !59
  %34 = load i16*, i16** %14, align 8, !dbg !78
  %35 = getelementptr i16, i16* %34, i16 5, !dbg !79
  %36 = load i16, i16* %35, align 2, !dbg !79
  store i16 %36, i16* %8, align 2, !dbg !58
  %37 = load i16*, i16** %14, align 8, !dbg !80
  %38 = getelementptr i16, i16* %37, i16 6, !dbg !81
  %39 = load i16, i16* %38, align 2, !dbg !81
  store i16 %39, i16* %7, align 2, !dbg !57
  %40 = load i16*, i16** %14, align 8, !dbg !82
  %41 = getelementptr i16, i16* %40, i16 7, !dbg !83
  %42 = load i16, i16* %41, align 2, !dbg !83
  store i16 %42, i16* %6, align 2, !dbg !56
  %43 = load i16*, i16** %14, align 8, !dbg !84
  %44 = getelementptr i16, i16* %43, i16 8, !dbg !85
  %45 = load i16, i16* %44, align 2, !dbg !85
  store i16 %45, i16* %5, align 2, !dbg !55
  %46 = load i16*, i16** %14, align 8, !dbg !86
  %47 = getelementptr i16, i16* %46, i16 9, !dbg !87
  %48 = load i16, i16* %47, align 2, !dbg !87
  store i16 %48, i16* %4, align 2, !dbg !54
  %49 = load i16*, i16** %14, align 8, !dbg !88
  %50 = getelementptr i16, i16* %49, i16 10, !dbg !89
  %51 = load i16, i16* %50, align 2, !dbg !89
  store i16 %51, i16* %3, align 2, !dbg !53
  %52 = load i16*, i16** %14, align 8, !dbg !90
  %53 = getelementptr i16, i16* %52, i16 12, !dbg !91
  %54 = load i16, i16* %53, align 2, !dbg !91
  %55 = zext i16 %54 to i32, !dbg !92
  %56 = load i16*, i16** %14, align 8, !dbg !93
  %57 = getelementptr i16, i16* %56, i16 11, !dbg !94
  %58 = load i16, i16* %57, align 2, !dbg !94
  %59 = zext i16 %58 to i32, !dbg !95
  %60 = add i32 %59, 16, !dbg !96
  %61 = shl i32 %55, %60, !dbg !97
  %62 = bitcast i32 %61 to float, !dbg !98
  store float %62, float* %2, align 4, !dbg !52
  %63 = load i16*, i16** %14, align 8, !dbg !99
  %64 = getelementptr i16, i16* %63, i16 14, !dbg !100
  %65 = load i16, i16* %64, align 2, !dbg !100
  %66 = zext i16 %65 to i32, !dbg !101
  %67 = load i16*, i16** %14, align 8, !dbg !102
  %68 = getelementptr i16, i16* %67, i16 13, !dbg !103
  %69 = load i16, i16* %68, align 2, !dbg !103
  %70 = zext i16 %69 to i32, !dbg !104
  %71 = add i32 %70, 16, !dbg !105
  %72 = shl i32 %66, %71, !dbg !106
  %73 = bitcast i32 %72 to float, !dbg !107
  store float %73, float* %1, align 4, !dbg !50
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !108
  %74 = load i16, i16* %13, align 2, !dbg !109
  store i16 %74, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !110
  %75 = load i16, i16* %12, align 2, !dbg !111
  store i16 %75, i16* @sys_mod.sys_mod.memcpyH2D_px, align 2, !dbg !112
  %76 = load i16, i16* %11, align 2, !dbg !113
  store i16 %76, i16* @sys_mod.sys_mod.memcpyH2D_py, align 2, !dbg !114
  %77 = load i16, i16* %10, align 2, !dbg !115
  store i16 %77, i16* @sys_mod.sys_mod.memcpyH2D_w, align 2, !dbg !116
  %78 = load i16, i16* %9, align 2, !dbg !117
  store i16 %78, i16* @sys_mod.sys_mod.memcpyH2D_h, align 2, !dbg !118
  %79 = load i16, i16* %8, align 2, !dbg !119
  store i16 %79, i16* @sys_mod.sys_mod.memcpyH2D_addr, align 2, !dbg !120
  %80 = load i16, i16* %7, align 2, !dbg !121
  store i16 %80, i16* @sys_mod.sys_mod.memcpyH2D_pe_length, align 2, !dbg !122
  %81 = load i16, i16* %6, align 2, !dbg !123
  store i16 %81, i16* @sys_mod.sys_mod.memcpyH2D_is_half, align 2, !dbg !124
  %82 = load i16, i16* %5, align 2, !dbg !125
  store i16 %82, i16* @sys_mod.sys_mod.memcpyH2D_memcpy_optype, align 2, !dbg !126
  %83 = load i16, i16* %4, align 2, !dbg !127
  store i16 %83, i16* @sys_mod.sys_mod.memcpyH2D_row_stride, align 2, !dbg !128
  %84 = load i16, i16* %3, align 2, !dbg !129
  store i16 %84, i16* @sys_mod.sys_mod.memcpyH2D_col_stride, align 2, !dbg !130
  %85 = load float, float* %2, align 4, !dbg !131
  store float %85, float* @sys_mod.sys_mod.memcpyH2D_one_over_row_stride, align 4, !dbg !132
  %86 = load float, float* %1, align 4, !dbg !133
  store float %86, float* @sys_mod.sys_mod.memcpyH2D_one_over_col_stride, align 4, !dbg !134
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !135
  call void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 0, i16 23, i1 true), !dbg !136
  call void @llvm.sdr.blk.r(i16 27), !dbg !137
  call void @llvm.sdr.oqflush(i16 0), !dbg !138
  store i1 true, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !139
  call void @llvm.sdr.blk.r(i16 0), !dbg !140
  ret void, !dbg !141
}

define void @sys_mod.sys_mod.f_memcpyd2h() #3 !dbg !142 {
  %1 = alloca i16, i16 1, align 2, !dbg !143
  %2 = alloca i16, i16 1, align 2, !dbg !145
  %3 = alloca i16, i16 1, align 2, !dbg !146
  %4 = alloca i16, i16 1, align 2, !dbg !147
  %5 = alloca i16, i16 1, align 2, !dbg !148
  %6 = alloca i16, i16 1, align 2, !dbg !149
  %7 = alloca i16, i16 1, align 2, !dbg !150
  %8 = alloca i16, i16 1, align 2, !dbg !151
  %9 = alloca i16*, i16 1, align 8, !dbg !152
  %10 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !153
  %11 = icmp eq i16 %10, 8, !dbg !154
  br i1 %11, label %12, label %13, !dbg !155

12:                                               ; preds = %0
  br label %14, !dbg !155

13:                                               ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !155
  br label %14, !dbg !155

14:                                               ; preds = %12, %13
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %9, align 8, !dbg !152
  %15 = load i16*, i16** %9, align 8, !dbg !156
  %16 = load i16, i16* %15, align 2, !dbg !157
  store i16 %16, i16* %8, align 2, !dbg !151
  %17 = load i16*, i16** %9, align 8, !dbg !158
  %18 = getelementptr i16, i16* %17, i16 1, !dbg !159
  %19 = load i16, i16* %18, align 2, !dbg !159
  store i16 %19, i16* %7, align 2, !dbg !150
  %20 = load i16*, i16** %9, align 8, !dbg !160
  %21 = getelementptr i16, i16* %20, i16 2, !dbg !161
  %22 = load i16, i16* %21, align 2, !dbg !161
  store i16 %22, i16* %6, align 2, !dbg !149
  %23 = load i16*, i16** %9, align 8, !dbg !162
  %24 = getelementptr i16, i16* %23, i16 3, !dbg !163
  %25 = load i16, i16* %24, align 2, !dbg !163
  store i16 %25, i16* %5, align 2, !dbg !148
  %26 = load i16*, i16** %9, align 8, !dbg !164
  %27 = getelementptr i16, i16* %26, i16 4, !dbg !165
  %28 = load i16, i16* %27, align 2, !dbg !165
  store i16 %28, i16* %4, align 2, !dbg !147
  %29 = load i16*, i16** %9, align 8, !dbg !166
  %30 = getelementptr i16, i16* %29, i16 5, !dbg !167
  %31 = load i16, i16* %30, align 2, !dbg !167
  store i16 %31, i16* %3, align 2, !dbg !146
  %32 = load i16*, i16** %9, align 8, !dbg !168
  %33 = getelementptr i16, i16* %32, i16 6, !dbg !169
  %34 = load i16, i16* %33, align 2, !dbg !169
  store i16 %34, i16* %2, align 2, !dbg !145
  %35 = load i16*, i16** %9, align 8, !dbg !170
  %36 = getelementptr i16, i16* %35, i16 7, !dbg !171
  %37 = load i16, i16* %36, align 2, !dbg !171
  store i16 %37, i16* %1, align 2, !dbg !143
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !172
  %38 = load i16, i16* %8, align 2, !dbg !173
  store i16 %38, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !174
  %39 = load i16, i16* %7, align 2, !dbg !175
  store i16 %39, i16* @sys_mod.sys_mod.memcpyD2H_px, align 2, !dbg !176
  %40 = load i16, i16* %6, align 2, !dbg !177
  store i16 %40, i16* @sys_mod.sys_mod.memcpyD2H_py, align 2, !dbg !178
  %41 = load i16, i16* %5, align 2, !dbg !179
  store i16 %41, i16* @sys_mod.sys_mod.memcpyD2H_w, align 2, !dbg !180
  %42 = load i16, i16* %4, align 2, !dbg !181
  store i16 %42, i16* @sys_mod.sys_mod.memcpyD2H_h, align 2, !dbg !182
  %43 = load i16, i16* %3, align 2, !dbg !183
  store i16 %43, i16* @sys_mod.sys_mod.memcpyD2H_addr, align 2, !dbg !184
  %44 = load i16, i16* %2, align 2, !dbg !185
  store i16 %44, i16* @sys_mod.sys_mod.memcpyD2H_pe_length, align 2, !dbg !186
  %45 = load i16, i16* %1, align 2, !dbg !187
  store i16 %45, i16* @sys_mod.sys_mod.memcpyD2H_is_half, align 2, !dbg !188
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !189
  %46 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !190
  call void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 0, i16 %46, i1 false), !dbg !191
  call void @llvm.sdr.oqflush(i16 0), !dbg !192
  store i1 false, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !193
  ret void, !dbg !194
}

define internal void @sys_mod.sys_mod.oq0_teardow_handler() !dbg !195 {
  %1 = load i1, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !196
  br i1 %1, label %2, label %17, !dbg !198

2:                                                ; preds = %0
  %3 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !199
  call void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 0, i16 %3), !dbg !200
  %4 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !201
  %5 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_px, align 2, !dbg !202
  %6 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_py, align 2, !dbg !203
  %7 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_w, align 2, !dbg !204
  %8 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_h, align 2, !dbg !205
  %9 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_addr, align 2, !dbg !206
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_pe_length, align 2, !dbg !207
  %11 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_is_half, align 2, !dbg !208
  %12 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_memcpy_optype, align 2, !dbg !209
  %13 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_row_stride, align 2, !dbg !210
  %14 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_col_stride, align 2, !dbg !211
  %15 = load float, float* @sys_mod.sys_mod.memcpyH2D_one_over_row_stride, align 4, !dbg !212
  %16 = load float, float* @sys_mod.sys_mod.memcpyH2D_one_over_col_stride, align 4, !dbg !213
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure(i16 %4, i16 %5, i16 %6, i16 %7, i16 %8, i16 %9, i16 %10, i16 %11, i16 %12, i16 %13, i16 %14, float %15, float %16), !dbg !214
  br label %26, !dbg !198

17:                                               ; preds = %0
  call void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 0, i16 21), !dbg !215
  %18 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !216
  %19 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_px, align 2, !dbg !217
  %20 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_py, align 2, !dbg !218
  %21 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_w, align 2, !dbg !219
  %22 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_h, align 2, !dbg !220
  %23 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_addr, align 2, !dbg !221
  %24 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_pe_length, align 2, !dbg !222
  %25 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_is_half, align 2, !dbg !223
  call void @sys_mod.sys_mod.memcpyd2h_mod.d2h_configure(i16 %18, i16 %19, i16 %20, i16 %21, i16 %22, i16 %23, i16 %24, i16 %25), !dbg !224
  br label %26, !dbg !198

26:                                               ; preds = %2, %17
  call void @__generic0sys_mod.sys_mod.tile_config.queue_flush.exit(), !dbg !225
  ret void, !dbg !198
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

define void @sys_mod.sys_mod.f_rpc(i16 %0) #4 !dbg !226 {
  %2 = alloca i16, i16 1, align 2, !dbg !227
  store i16 %0, i16* %2, align 2, !dbg !227
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !229
  %3 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !230
  %4 = icmp sge i16 %3, 4, !dbg !231
  br i1 %4, label %5, label %6, !dbg !232

5:                                                ; preds = %1
  br label %7, !dbg !232

6:                                                ; preds = %1
  call void asm sideeffect "hcf", ""(), !dbg !232
  br label %7, !dbg !232

7:                                                ; preds = %5, %6
  call void @rpc_server(i32* getelementptr inbounds ([32 x i32], [32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32, i32 0, i32 0)), !dbg !233
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !234
  ret void, !dbg !235
}

define internal void @sys_mod.sys_mod.sys_mod.stack_push(i16 %0) !dbg !236 {
  %2 = alloca i16*, i16 1, align 8, !dbg !238
  %3 = alloca i16, i16 1, align 2, !dbg !240
  store i16 %0, i16* %3, align 2, !dbg !240
  %4 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !241
  %5 = icmp slt i16 %4, 32, !dbg !242
  br i1 %5, label %6, label %7, !dbg !243

6:                                                ; preds = %1
  br label %8, !dbg !243

7:                                                ; preds = %1
  call void asm sideeffect "hcf", ""(), !dbg !243
  br label %8, !dbg !243

8:                                                ; preds = %6, %7
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %2, align 8, !dbg !238
  %9 = load i16, i16* %3, align 2, !dbg !244
  %10 = load i16*, i16** %2, align 8, !dbg !245
  %11 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !246
  %12 = getelementptr i16, i16* %10, i16 %11, !dbg !247
  store i16 %9, i16* %12, align 2, !dbg !248
  %13 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !249
  %14 = add i16 %13, 1, !dbg !250
  store i16 %14, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !251
  ret void, !dbg !252
}

define void @sys_mod.sys_mod.sys_mod.f_push(i16 %0, i16 %1) #5 !dbg !253 {
  %3 = alloca i16, i16 1, align 2, !dbg !254
  %4 = alloca i16, i16 1, align 2, !dbg !256
  store i16 %0, i16* %4, align 2, !dbg !256
  store i16 %1, i16* %3, align 2, !dbg !254
  %5 = load i16, i16* %4, align 2, !dbg !257
  call void @sys_mod.sys_mod.sys_mod.stack_push(i16 %5), !dbg !258
  ret void, !dbg !259
}

define internal void @sys_mod.sys_mod.sys_mod.block_cmd_stream() !dbg !260 {
  call void @llvm.sdr.blk.r(i16 1), !dbg !261
  ret void, !dbg !263
}

define internal void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream() !dbg !264 {
  call void @llvm.sdr.ublk.r(i16 1), !dbg !265
  ret void, !dbg !267
}

define void @sys_mod.sys_mod.sys_mod.f_sys_exit() #6 !dbg !268 {
  call void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream(), !dbg !269
  call void @sys_mod.sys_nop(), !dbg !271
  ret void, !dbg !272
}

define void @sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore(i32 %0) #7 !dbg !273 {
  %2 = alloca i32, i16 1, align 4, !dbg !274
  store i32 %0, i32* %2, align 4, !dbg !274
  ret void, !dbg !276
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord() !dbg !277 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord(), !dbg !279
  ret i16 %1, !dbg !281
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord() !dbg !282 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord(), !dbg !283
  ret i16 %1, !dbg !285
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval(i16 %0) !dbg !286 {
  %2 = alloca i16, i16 1, align 2, !dbg !287
  store i16 %0, i16* %2, align 2, !dbg !287
  %3 = load i16, i16* %2, align 2, !dbg !289
  %4 = icmp ult i16 %3, 24, !dbg !290
  br i1 %4, label %5, label %7, !dbg !291

5:                                                ; preds = %10, %11, %1
  %6 = phi i16 [ 0, %10 ], [ 0, %11 ], [ 1, %1 ]
  br label %12, !dbg !291

7:                                                ; preds = %1
  %8 = load i16, i16* %2, align 2, !dbg !292
  %9 = icmp eq i16 31, %8, !dbg !293
  br i1 %9, label %10, label %11, !dbg !294

10:                                               ; preds = %7
  br label %5, !dbg !294

11:                                               ; preds = %7
  call void asm sideeffect "hcf", ""(), !dbg !294
  br label %5, !dbg !294

12:                                               ; preds = %5
  %13 = phi i16 [ %6, %5 ]
  br label %14, !dbg !291

14:                                               ; preds = %12
  ret i16 %13, !dbg !291
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start(i16 %0, i16 %1, i16 %2) !dbg !295 {
  %4 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !296
  %5 = alloca i16, i16 1, align 2, !dbg !298
  %6 = alloca i16, i16 1, align 2, !dbg !299
  %7 = alloca i16, i16 1, align 2, !dbg !300
  store i16 %0, i16* %7, align 2, !dbg !300
  store i16 %1, i16* %6, align 2, !dbg !299
  store i16 %2, i16* %5, align 2, !dbg !298
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !301
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !301
  %10 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !301
  %11 = load i16, i16* %6, align 2, !dbg !302
  store i16 %11, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !303
  store i16 %8, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !303
  store i16 %9, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !303
  store i16 %10, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !303
  %12 = load i16, i16* %7, align 2, !dbg !304
  %13 = call i16* @.get_tensor_ptr(i16 %12), !dbg !305
  %14 = ptrtoint i16* %13 to i16, !dbg !306
  %15 = lshr i16 %14, 1, !dbg !306
  %16 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !296
  store i16 42, i16* %16, align 2, !dbg !296
  %17 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !296
  store i16 %15, i16* %17, align 2, !dbg !296
  %18 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !296
  store i16 143, i16* %18, align 2, !dbg !296
  %19 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !296
  store i16 16, i16* %19, align 2, !dbg !296
  %20 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !307
  %21 = load i16, i16* %20, align 2, !dbg !307
  %22 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !307
  %23 = load i16, i16* %22, align 2, !dbg !307
  %24 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !307
  %25 = load i16, i16* %24, align 2, !dbg !307
  %26 = load i16, i16* %6, align 2, !dbg !308
  %27 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !309
  store i16 %26, i16* %27, align 2, !dbg !309
  %28 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !309
  store i16 %21, i16* %28, align 2, !dbg !309
  %29 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !309
  store i16 %23, i16* %29, align 2, !dbg !309
  %30 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !309
  store i16 %25, i16* %30, align 2, !dbg !309
  %31 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !310
  %32 = load i16, i16* %31, align 2, !dbg !310
  %33 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !310
  %34 = load i16, i16* %33, align 2, !dbg !310
  %35 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !310
  %36 = load i16, i16* %35, align 2, !dbg !310
  %37 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !310
  %38 = load i16, i16* %37, align 2, !dbg !310
  store volatile i16 %32, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !311
  store volatile i16 %34, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !311
  store volatile i16 %36, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !311
  store volatile i16 %38, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !311
  call void asm sideeffect "nop", ""(), !dbg !311
  call void asm sideeffect "nop", ""(), !dbg !311
  %39 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !312
  %40 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !312
  %41 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !312
  %42 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !312
  %43 = and i16 %41, -193, !dbg !312
  %44 = or i16 %43, 128, !dbg !312
  %45 = and i16 %40, -64, !dbg !312
  %46 = or i16 %45, 27, !dbg !312
  store volatile i16 %39, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !313
  store volatile i16 %46, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !313
  store volatile i16 %44, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !313
  store volatile i16 %42, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !313
  call void asm sideeffect "nop", ""(), !dbg !313
  call void asm sideeffect "nop", ""(), !dbg !313
  %47 = load i16, i16* %5, align 2, !dbg !314
  %48 = icmp ult i16 0, %47, !dbg !315
  br i1 %48, label %49, label %50, !dbg !316

49:                                               ; preds = %3
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !317
  br label %51, !dbg !316

50:                                               ; preds = %3
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !318
  br label %51, !dbg !316

51:                                               ; preds = %49, %50
  ret void, !dbg !316
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream() !dbg !319 {
  call void @llvm.sdr.ublk.r(i16 1), !dbg !320
  ret void, !dbg !322
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7, i16 %8, i16 %9, i16 %10, float %11, float %12) !dbg !323 {
  %14 = alloca i16, i16 1, align 2, !dbg !324
  %15 = alloca i16, i16 1, align 2, !dbg !326
  %16 = alloca i16, i16 1, align 2, !dbg !327
  %17 = alloca i16, i16 1, align 2, !dbg !328
  %18 = alloca i16, i16 1, align 2, !dbg !329
  %19 = alloca i1, i16 1, align 1, !dbg !330
  %20 = alloca i16, i16 1, align 2, !dbg !331
  %21 = alloca i16, i16 1, align 2, !dbg !332
  %22 = alloca i16, i16 1, align 2, !dbg !333
  %23 = alloca i16, i16 1, align 2, !dbg !334
  %24 = alloca i16, i16 1, align 2, !dbg !335
  %25 = alloca float, i16 1, align 4, !dbg !336
  %26 = alloca float, i16 1, align 4, !dbg !337
  %27 = alloca i16, i16 1, align 2, !dbg !338
  %28 = alloca i16, i16 1, align 2, !dbg !339
  %29 = alloca i16, i16 1, align 2, !dbg !340
  %30 = alloca i16, i16 1, align 2, !dbg !341
  %31 = alloca i16, i16 1, align 2, !dbg !342
  %32 = alloca i16, i16 1, align 2, !dbg !343
  %33 = alloca i16, i16 1, align 2, !dbg !344
  %34 = alloca i16, i16 1, align 2, !dbg !345
  %35 = alloca i16, i16 1, align 2, !dbg !346
  %36 = alloca i16, i16 1, align 2, !dbg !347
  %37 = alloca i16, i16 1, align 2, !dbg !348
  store i16 %0, i16* %37, align 2, !dbg !348
  store i16 %1, i16* %36, align 2, !dbg !347
  store i16 %2, i16* %35, align 2, !dbg !346
  store i16 %3, i16* %34, align 2, !dbg !345
  store i16 %4, i16* %33, align 2, !dbg !344
  store i16 %5, i16* %32, align 2, !dbg !343
  store i16 %6, i16* %31, align 2, !dbg !342
  store i16 %7, i16* %30, align 2, !dbg !341
  store i16 %8, i16* %29, align 2, !dbg !340
  store i16 %9, i16* %28, align 2, !dbg !339
  store i16 %10, i16* %27, align 2, !dbg !338
  store float %11, float* %26, align 4, !dbg !337
  store float %12, float* %25, align 4, !dbg !336
  %38 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord(), !dbg !349
  store i16 %38, i16* %24, align 2, !dbg !335
  %39 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord(), !dbg !350
  store i16 %39, i16* %23, align 2, !dbg !334
  %40 = load i16, i16* %24, align 2, !dbg !351
  %41 = load i16, i16* %36, align 2, !dbg !352
  %42 = sub i16 %40, %41, !dbg !353
  store i16 %42, i16* %22, align 2, !dbg !333
  %43 = load i16, i16* %22, align 2, !dbg !354
  store i16 %43, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !355
  %44 = load i16, i16* %29, align 2, !dbg !356
  %45 = icmp eq i16 3, %44, !dbg !357
  br i1 %45, label %46, label %63, !dbg !358

46:                                               ; preds = %13
  %47 = load i16, i16* %22, align 2, !dbg !359
  %48 = sitofp i16 %47 to float, !dbg !360
  %49 = load float, float* %26, align 4, !dbg !361
  %50 = fmul float %48, %49, !dbg !362
  %51 = fptosi float %50 to i16, !dbg !363
  store i16 %51, i16* %21, align 2, !dbg !332
  %52 = load i16, i16* %22, align 2, !dbg !364
  %53 = load i16, i16* %21, align 2, !dbg !365
  %54 = load i16, i16* %28, align 2, !dbg !366
  %55 = mul i16 %53, %54, !dbg !367
  %56 = sub i16 %52, %55, !dbg !368
  store i16 %56, i16* %20, align 2, !dbg !331
  %57 = load i16, i16* %20, align 2, !dbg !369
  %58 = icmp ne i16 0, %57, !dbg !370
  br i1 %58, label %59, label %60, !dbg !371

59:                                               ; preds = %46
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !372
  br label %62, !dbg !371

60:                                               ; preds = %46
  %61 = load i16, i16* %21, align 2, !dbg !373
  store i16 %61, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !374
  br label %62, !dbg !371

62:                                               ; preds = %59, %60
  br label %63, !dbg !358

63:                                               ; preds = %62, %13
  %64 = load i16, i16* %22, align 2, !dbg !375
  %65 = icmp slt i16 %64, 0, !dbg !376
  br i1 %65, label %66, label %67, !dbg !377

66:                                               ; preds = %63
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !378
  br label %67, !dbg !377

67:                                               ; preds = %66, %63
  %68 = load i16, i16* %22, align 2, !dbg !379
  %69 = load i16, i16* %34, align 2, !dbg !380
  %70 = icmp sge i16 %68, %69, !dbg !381
  br i1 %70, label %71, label %72, !dbg !382

71:                                               ; preds = %67
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !383
  br label %72, !dbg !382

72:                                               ; preds = %71, %67
  store i1 false, i1* %19, align 1, !dbg !330
  %73 = load i16, i16* %29, align 2, !dbg !384
  %74 = icmp eq i16 3, %73, !dbg !385
  br i1 %74, label %75, label %94, !dbg !386

75:                                               ; preds = %72
  %76 = load i16, i16* %23, align 2, !dbg !387
  %77 = load i16, i16* %35, align 2, !dbg !388
  %78 = sub i16 %76, %77, !dbg !389
  %79 = sitofp i16 %78 to float, !dbg !390
  %80 = load float, float* %25, align 4, !dbg !391
  %81 = fmul float %79, %80, !dbg !392
  %82 = fptosi float %81 to i16, !dbg !393
  store i16 %82, i16* %18, align 2, !dbg !329
  %83 = load i16, i16* %23, align 2, !dbg !394
  %84 = load i16, i16* %35, align 2, !dbg !395
  %85 = sub i16 %83, %84, !dbg !396
  %86 = load i16, i16* %18, align 2, !dbg !397
  %87 = load i16, i16* %27, align 2, !dbg !398
  %88 = mul i16 %86, %87, !dbg !399
  %89 = sub i16 %85, %88, !dbg !400
  store i16 %89, i16* %17, align 2, !dbg !328
  %90 = load i16, i16* %17, align 2, !dbg !401
  %91 = icmp ne i16 0, %90, !dbg !402
  br i1 %91, label %92, label %93, !dbg !403

92:                                               ; preds = %75
  store i1 true, i1* %19, align 1, !dbg !404
  br label %93, !dbg !403

93:                                               ; preds = %92, %75
  br label %94, !dbg !386

94:                                               ; preds = %93, %72
  %95 = load i16, i16* %23, align 2, !dbg !405
  %96 = load i16, i16* %35, align 2, !dbg !406
  %97 = icmp slt i16 %95, %96, !dbg !407
  br i1 %97, label %98, label %99, !dbg !408

98:                                               ; preds = %94
  store i1 true, i1* %19, align 1, !dbg !409
  br label %99, !dbg !408

99:                                               ; preds = %98, %94
  %100 = load i16, i16* %23, align 2, !dbg !410
  %101 = load i16, i16* %35, align 2, !dbg !411
  %102 = load i16, i16* %33, align 2, !dbg !412
  %103 = add i16 %101, %102, !dbg !413
  %104 = icmp sge i16 %100, %103, !dbg !414
  br i1 %104, label %105, label %106, !dbg !415

105:                                              ; preds = %99
  store i1 true, i1* %19, align 1, !dbg !416
  br label %106, !dbg !415

106:                                              ; preds = %105, %99
  %107 = load i1, i1* %19, align 1, !dbg !417
  br i1 %107, label %108, label %109, !dbg !418

108:                                              ; preds = %106
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream(), !dbg !419
  call void @llvm.sdr.ublk.r(i16 27), !dbg !420
  br label %180, !dbg !418

109:                                              ; preds = %106
  %110 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !421
  %111 = icmp eq i16 -1, %110, !dbg !422
  br i1 %111, label %112, label %113, !dbg !423

112:                                              ; preds = %109
  call void @__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction(i16 31767), !dbg !424
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 23), !dbg !425
  call void @llvm.sdr.ublk.r(i16 27), !dbg !426
  br label %179, !dbg !423

113:                                              ; preds = %109
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter(i16 0, i16 0), !dbg !427
  %114 = load i16, i16* %34, align 2, !dbg !428
  store i16 %114, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !429
  %115 = load i16, i16* %29, align 2, !dbg !430
  %116 = icmp eq i16 3, %115, !dbg !431
  br i1 %116, label %117, label %126, !dbg !432

117:                                              ; preds = %113
  %118 = load i16, i16* %34, align 2, !dbg !433
  %119 = sub i16 %118, 1, !dbg !434
  %120 = sitofp i16 %119 to float, !dbg !435
  %121 = load float, float* %26, align 4, !dbg !436
  %122 = fmul float %120, %121, !dbg !437
  %123 = fptosi float %122 to i16, !dbg !438
  %124 = add i16 %123, 1, !dbg !439
  store i16 %124, i16* %16, align 2, !dbg !327
  %125 = load i16, i16* %16, align 2, !dbg !440
  store i16 %125, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !441
  br label %131, !dbg !432

126:                                              ; preds = %113
  %127 = load i16, i16* %29, align 2, !dbg !442
  %128 = icmp eq i16 1, %127, !dbg !443
  br i1 %128, label %129, label %130, !dbg !444

129:                                              ; preds = %126
  store i16 1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !445
  br label %130, !dbg !444

130:                                              ; preds = %129, %126
  br label %131, !dbg !432

131:                                              ; preds = %117, %130
  %132 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !446
  %133 = sub i16 %132, 1, !dbg !447
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit(i16 0, i16 %133), !dbg !448
  %134 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !449
  store i16 %134, i16* %15, align 2, !dbg !326
  %135 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !450
  store i16 %135, i16* %14, align 2, !dbg !324
  %136 = load i16, i16* %15, align 2, !dbg !451
  %137 = load i16, i16* %14, align 2, !dbg !452
  %138 = sub i16 %136, %137, !dbg !453
  store i16 %138, i16* %15, align 2, !dbg !454
  %139 = load i16, i16* %14, align 2, !dbg !455
  %140 = icmp eq i16 0, %139, !dbg !456
  br i1 %140, label %141, label %142, !dbg !457

141:                                              ; preds = %131
  store i16 0, i16* %15, align 2, !dbg !458
  br label %142, !dbg !457

142:                                              ; preds = %141, %131
  %143 = load i16, i16* %29, align 2, !dbg !459
  %144 = icmp eq i16 1, %143, !dbg !460
  br i1 %144, label %145, label %146, !dbg !461

145:                                              ; preds = %142
  store i16 0, i16* %15, align 2, !dbg !462
  br label %146, !dbg !461

146:                                              ; preds = %145, %142
  %147 = load i16, i16* %15, align 2, !dbg !463
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter(i16 0, i16 %147), !dbg !464
  call void @__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction(i16 31767), !dbg !465
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 23), !dbg !466
  %148 = load i16, i16* %37, align 2, !dbg !467
  %149 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval(i16 %148), !dbg !468
  %150 = icmp eq i16 0, %149, !dbg !469
  br i1 %150, label %151, label %155, !dbg !470

151:                                              ; preds = %146
  %152 = load i16, i16* %32, align 2, !dbg !471
  %153 = load i16, i16* %31, align 2, !dbg !472
  %154 = load i16, i16* %30, align 2, !dbg !473
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start(i16 %152, i16 %153, i16 %154), !dbg !474
  br label %178, !dbg !470

155:                                              ; preds = %146
  %156 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !475
  %157 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !475
  %158 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !475
  %159 = load i16, i16* %31, align 2, !dbg !476
  store i16 %159, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !477
  store i16 %156, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !477
  store i16 %157, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !477
  store i16 %158, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !477
  %160 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !478
  %161 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !478
  %162 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !478
  %163 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !478
  %164 = and i16 %162, -193, !dbg !478
  %165 = or i16 %164, 128, !dbg !478
  store volatile i16 %160, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !479
  store volatile i16 %161, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !479
  store volatile i16 %165, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !479
  store volatile i16 %163, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !479
  call void asm sideeffect "nop", ""(), !dbg !479
  call void asm sideeffect "nop", ""(), !dbg !479
  %166 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !480
  %167 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !480
  %168 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !480
  %169 = load i16, i16* %31, align 2, !dbg !481
  store i16 %169, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !482
  store i16 %166, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !482
  store i16 %167, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !482
  store i16 %168, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !482
  %170 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !483
  %171 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !483
  %172 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !483
  %173 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !483
  %174 = and i16 %172, -193, !dbg !483
  %175 = or i16 %174, 128, !dbg !483
  %176 = and i16 %171, -64, !dbg !483
  %177 = or i16 %176, 27, !dbg !483
  store volatile i16 %170, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !484
  store volatile i16 %177, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !484
  store volatile i16 %175, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !484
  store volatile i16 %173, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !484
  call void asm sideeffect "nop", ""(), !dbg !484
  call void asm sideeffect "nop", ""(), !dbg !484
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !485
  br label %178, !dbg !470

178:                                              ; preds = %151, %155
  br label %179, !dbg !423

179:                                              ; preds = %112, %178
  br label %180, !dbg !418

180:                                              ; preds = %108, %179
  ret void, !dbg !358
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit(i16 %0, i16 %1) !dbg !486 {
  %3 = alloca i16, i16 1, align 2, !dbg !488
  %4 = alloca i16, i16 1, align 2, !dbg !490
  %5 = alloca i16, i16 1, align 2, !dbg !491
  %6 = alloca i16, i16 1, align 2, !dbg !492
  %7 = alloca i16, i16 1, align 2, !dbg !493
  %8 = alloca i16, i16 1, align 2, !dbg !494
  store i16 %0, i16* %8, align 2, !dbg !494
  store i16 %1, i16* %7, align 2, !dbg !493
  %9 = load i16, i16* %7, align 2, !dbg !495
  %10 = icmp ult i16 %9, -32768, !dbg !496
  br i1 %10, label %11, label %12, !dbg !497

11:                                               ; preds = %2
  br label %13, !dbg !497

12:                                               ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !497
  br label %13, !dbg !497

13:                                               ; preds = %11, %12
  %14 = load i16, i16* %7, align 2, !dbg !498
  %15 = mul i16 %14, 2, !dbg !499
  store i16 %15, i16* %6, align 2, !dbg !492
  %16 = load i16, i16* %8, align 2, !dbg !500
  %17 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %16, i16 8), !dbg !501
  %18 = sub i16 %17, 1, !dbg !502
  store i16 %18, i16* %5, align 2, !dbg !491
  %19 = load i16, i16* %6, align 2, !dbg !503
  %20 = load i16, i16* %5, align 2, !dbg !504
  %21 = icmp ult i16 %19, %20, !dbg !505
  br i1 %21, label %22, label %23, !dbg !490

22:                                               ; preds = %13
  store i16 0, i16* %4, align 2, !dbg !490
  br label %27, !dbg !490

23:                                               ; preds = %13
  %24 = load i16, i16* %6, align 2, !dbg !506
  %25 = load i16, i16* %5, align 2, !dbg !507
  %26 = sub i16 %24, %25, !dbg !508
  store i16 %26, i16* %4, align 2, !dbg !490
  br label %27, !dbg !490

27:                                               ; preds = %22, %23
  %28 = load i16, i16* %4, align 2, !dbg !490
  store i16 %28, i16* %3, align 2, !dbg !488
  %29 = load i16, i16* %8, align 2, !dbg !509
  %30 = load i16, i16* %3, align 2, !dbg !510
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %29, i16 4, i16 %30), !dbg !511
  ret void, !dbg !490
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter(i16 %0, i16 %1) !dbg !512 {
  %3 = alloca i16, i16 1, align 2, !dbg !513
  %4 = alloca i16, i16 1, align 2, !dbg !515
  store i16 %0, i16* %4, align 2, !dbg !515
  store i16 %1, i16* %3, align 2, !dbg !513
  %5 = load i16, i16* %3, align 2, !dbg !516
  %6 = icmp ult i16 %5, -32768, !dbg !517
  br i1 %6, label %7, label %8, !dbg !518

7:                                                ; preds = %2
  br label %9, !dbg !518

8:                                                ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !518
  br label %9, !dbg !518

9:                                                ; preds = %7, %8
  %10 = load i16, i16* %4, align 2, !dbg !519
  %11 = load i16, i16* %3, align 2, !dbg !520
  %12 = mul i16 %11, 2, !dbg !521
  %13 = add i16 %12, 1, !dbg !522
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %10, i16 8, i16 %13), !dbg !523
  ret void, !dbg !524
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter(i16 %0, i16 %1) !dbg !525 {
  %3 = alloca i16, i16 1, align 2, !dbg !526
  %4 = alloca i16, i16 1, align 2, !dbg !528
  %5 = alloca i1, i16 1, align 1, !dbg !529
  %6 = alloca i16, i16 1, align 2, !dbg !530
  %7 = alloca i16, i16 1, align 2, !dbg !531
  %8 = alloca i16, i16 1, align 2, !dbg !532
  %9 = alloca i16, i16 1, align 2, !dbg !533
  store i16 %0, i16* %9, align 2, !dbg !533
  store i16 %1, i16* %8, align 2, !dbg !532
  %10 = load i16, i16* %8, align 2, !dbg !534
  %11 = icmp ult i16 %10, -32768, !dbg !535
  br i1 %11, label %12, label %13, !dbg !536

12:                                               ; preds = %2
  br label %14, !dbg !536

13:                                               ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !536
  br label %14, !dbg !536

14:                                               ; preds = %12, %13
  %15 = load i16, i16* %9, align 2, !dbg !537
  %16 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %15, i16 8), !dbg !538
  store i16 %16, i16* %7, align 2, !dbg !531
  %17 = load i16, i16* %8, align 2, !dbg !539
  %18 = mul i16 %17, 2, !dbg !540
  store i16 %18, i16* %6, align 2, !dbg !530
  %19 = load i16, i16* %6, align 2, !dbg !541
  %20 = load i16, i16* %7, align 2, !dbg !542
  %21 = icmp ugt i16 %19, %20, !dbg !543
  store i1 %21, i1* %5, align 1, !dbg !529
  %22 = load i16, i16* %9, align 2, !dbg !544
  %23 = load i1, i1* %5, align 1, !dbg !545
  %24 = zext i1 %23 to i16, !dbg !546
  %25 = shl i16 %24, 6, !dbg !547
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %22, i16 14, i16 %25), !dbg !548
  %26 = load i1, i1* %5, align 1, !dbg !549
  br i1 %26, label %27, label %32, !dbg !528

27:                                               ; preds = %14
  %28 = load i16, i16* %6, align 2, !dbg !550
  %29 = load i16, i16* %7, align 2, !dbg !551
  %30 = sub i16 %28, %29, !dbg !552
  %31 = add i16 %30, 1, !dbg !553
  store i16 %31, i16* %4, align 2, !dbg !528
  br label %34, !dbg !528

32:                                               ; preds = %14
  %33 = load i16, i16* %6, align 2, !dbg !554
  store i16 %33, i16* %4, align 2, !dbg !528
  br label %34, !dbg !528

34:                                               ; preds = %27, %32
  %35 = load i16, i16* %4, align 2, !dbg !528
  store i16 %35, i16* %3, align 2, !dbg !526
  %36 = load i16, i16* %9, align 2, !dbg !555
  %37 = load i16, i16* %3, align 2, !dbg !556
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %36, i16 12, i16 %37), !dbg !557
  ret void, !dbg !528
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %0, i16 %1, i16 %2) !dbg !558 {
  %4 = alloca i16, i16 1, align 2, !dbg !560
  %5 = alloca i16, i16 1, align 2, !dbg !562
  %6 = alloca i16, i16 1, align 2, !dbg !563
  store i16 %0, i16* %6, align 2, !dbg !563
  store i16 %1, i16* %5, align 2, !dbg !562
  store i16 %2, i16* %4, align 2, !dbg !560
  %7 = load i16, i16* %6, align 2, !dbg !564
  %8 = getelementptr [6 x i16], [6 x i16]* @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.filters, i16 0, i16 %7, !dbg !565
  %9 = load i16, i16* %8, align 2, !dbg !565
  %10 = load i16, i16* %5, align 2, !dbg !566
  %11 = add i16 %9, %10, !dbg !567
  %12 = lshr i16 %11, 1, !dbg !568
  %13 = load i16, i16* %4, align 2, !dbg !569
  %14 = shl i16 %12, 1, !dbg !570
  %15 = inttoptr i16 %14 to i16*, !dbg !570
  store volatile i16 %13, i16* %15, align 2, !dbg !570
  call void asm sideeffect "nop", ""(), !dbg !570
  call void asm sideeffect "nop", ""(), !dbg !570
  ret void, !dbg !571
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %0, i16 %1) !dbg !572 {
  %3 = alloca i16, i16 1, align 2, !dbg !573
  %4 = alloca i16, i16 1, align 2, !dbg !575
  store i16 %0, i16* %4, align 2, !dbg !575
  store i16 %1, i16* %3, align 2, !dbg !573
  %5 = load i16, i16* %4, align 2, !dbg !576
  %6 = getelementptr [6 x i16], [6 x i16]* @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.filters, i16 0, i16 %5, !dbg !577
  %7 = load i16, i16* %6, align 2, !dbg !577
  %8 = load i16, i16* %3, align 2, !dbg !578
  %9 = add i16 %7, %8, !dbg !579
  %10 = lshr i16 %9, 1, !dbg !580
  %11 = shl i16 %10, 1, !dbg !581
  %12 = inttoptr i16 %11 to i16*, !dbg !581
  call void asm sideeffect "nop", ""(), !dbg !581
  call void asm sideeffect "nop", ""(), !dbg !581
  %13 = load volatile i16, i16* %12, align 2, !dbg !581
  ret i16 %13, !dbg !582
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 %0) !dbg !583 {
  %2 = alloca i16, i16 1, align 2, !dbg !585
  %3 = alloca i16, i16 1, align 2, !dbg !587
  %4 = alloca i16, i16 1, align 2, !dbg !588
  %5 = alloca i16, i16 1, align 2, !dbg !589
  store i16 %0, i16* %5, align 2, !dbg !589
  %6 = load i16, i16* %5, align 2, !dbg !590
  store i16 %6, i16* %4, align 2, !dbg !588
  %7 = load i16, i16* %4, align 2, !dbg !591
  %8 = add i16 %7, 31744, !dbg !592
  store i16 %8, i16* %3, align 2, !dbg !587
  %9 = load i16, i16* %3, align 2, !dbg !593
  %10 = shl i16 %9, 1, !dbg !594
  %11 = inttoptr i16 %10 to i16*, !dbg !594
  call void asm sideeffect "nop", ""(), !dbg !594
  call void asm sideeffect "nop", ""(), !dbg !594
  %12 = load volatile i16, i16* %11, align 2, !dbg !594
  store i16 %12, i16* %2, align 2, !dbg !585
  %13 = load i16, i16* %3, align 2, !dbg !595
  %14 = load i16, i16* %2, align 2, !dbg !596
  %15 = and i16 %14, 32767, !dbg !597
  %16 = shl i16 %13, 1, !dbg !598
  %17 = inttoptr i16 %16 to i16*, !dbg !598
  store volatile i16 %15, i16* %17, align 2, !dbg !598
  call void asm sideeffect "nop", ""(), !dbg !598
  call void asm sideeffect "nop", ""(), !dbg !598
  ret void, !dbg !599
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord() !dbg !600 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 2), !dbg !602
  %2 = sub i16 %1, 4, !dbg !604
  ret i16 %2, !dbg !605
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord() !dbg !606 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 0), !dbg !607
  %2 = sub i16 %1, 1, !dbg !609
  ret i16 %2, !dbg !610
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 %0) !dbg !611 {
  %2 = alloca i16, i16 1, align 2, !dbg !613
  %3 = alloca i16, i16 1, align 2, !dbg !615
  store i16 %0, i16* %3, align 2, !dbg !615
  %4 = load i16, i16* %3, align 2, !dbg !616
  %5 = lshr i16 %4, 1, !dbg !617
  %6 = add i16 %5, 31813, !dbg !618
  %7 = shl i16 %6, 1, !dbg !619
  %8 = inttoptr i16 %7 to i16*, !dbg !619
  call void asm sideeffect "nop", ""(), !dbg !619
  call void asm sideeffect "nop", ""(), !dbg !619
  %9 = load volatile i16, i16* %8, align 2, !dbg !619
  store i16 %9, i16* %2, align 2, !dbg !613
  %10 = load i16, i16* %2, align 2, !dbg !620
  %11 = and i16 %10, 2047, !dbg !621
  ret i16 %11, !dbg !622
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord() !dbg !623 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord(), !dbg !625
  ret i16 %1, !dbg !627
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.get_y_coord() !dbg !628 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord(), !dbg !629
  ret i16 %1, !dbg !631
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval(i16 %0) !dbg !632 {
  %2 = alloca i16, i16 1, align 2, !dbg !633
  store i16 %0, i16* %2, align 2, !dbg !633
  %3 = load i16, i16* %2, align 2, !dbg !635
  %4 = icmp ult i16 %3, 24, !dbg !636
  br i1 %4, label %5, label %7, !dbg !637

5:                                                ; preds = %10, %11, %1
  %6 = phi i16 [ 0, %10 ], [ 0, %11 ], [ 1, %1 ]
  br label %12, !dbg !637

7:                                                ; preds = %1
  %8 = load i16, i16* %2, align 2, !dbg !638
  %9 = icmp eq i16 31, %8, !dbg !639
  br i1 %9, label %10, label %11, !dbg !640

10:                                               ; preds = %7
  br label %5, !dbg !640

11:                                               ; preds = %7
  call void asm sideeffect "hcf", ""(), !dbg !640
  br label %5, !dbg !640

12:                                               ; preds = %5
  %13 = phi i16 [ %6, %5 ]
  br label %14, !dbg !637

14:                                               ; preds = %12
  ret i16 %13, !dbg !637
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7) !dbg !641 {
  %9 = alloca i16, i16 1, align 2, !dbg !642
  %10 = alloca i16, i16 1, align 2, !dbg !644
  %11 = alloca i16, i16 1, align 2, !dbg !645
  %12 = alloca i16, i16 1, align 2, !dbg !646
  %13 = alloca i16, i16 1, align 2, !dbg !647
  %14 = alloca i16, i16 1, align 2, !dbg !648
  %15 = alloca i16, i16 1, align 2, !dbg !649
  %16 = alloca i16, i16 1, align 2, !dbg !650
  %17 = alloca i16, i16 1, align 2, !dbg !651
  store i16 %0, i16* %17, align 2, !dbg !651
  store i16 %1, i16* %16, align 2, !dbg !650
  store i16 %2, i16* %15, align 2, !dbg !649
  store i16 %3, i16* %14, align 2, !dbg !648
  store i16 %4, i16* %13, align 2, !dbg !647
  store i16 %5, i16* %12, align 2, !dbg !646
  store i16 %6, i16* %11, align 2, !dbg !645
  store i16 %7, i16* %10, align 2, !dbg !644
  %18 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !652
  store i16 %18, i16* %9, align 2, !dbg !642
  %19 = load i16, i16* %11, align 2, !dbg !653
  store i16 %19, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_c, align 2, !dbg !654
  %20 = load i16, i16* %10, align 2, !dbg !655
  store i16 %20, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_is_half, align 2, !dbg !656
  %21 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_c, align 2, !dbg !657
  %22 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval(i16 %21), !dbg !658
  store i16 %22, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !659
  store i16 0, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !660
  %23 = load i16, i16* %16, align 2, !dbg !661
  store i16 %23, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !662
  %24 = load i16, i16* %15, align 2, !dbg !663
  store i16 %24, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !664
  %25 = load i16, i16* %15, align 2, !dbg !665
  %26 = load i16, i16* %13, align 2, !dbg !666
  %27 = add i16 %25, %26, !dbg !667
  %28 = sub i16 %27, 1, !dbg !668
  store i16 %28, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_last, align 2, !dbg !669
  %29 = load i16, i16* %9, align 2, !dbg !670
  %30 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_last, align 2, !dbg !671
  %31 = icmp eq i16 %29, %30, !dbg !672
  br i1 %31, label %32, label %37, !dbg !673

32:                                               ; preds = %8
  %33 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !674
  %34 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !674
  %35 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !674
  store i16 %33, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !675
  store i16 lshr (i16 ptrtoint ([1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.ctrl_1 to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !675
  store i16 %34, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !675
  store i16 %35, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !675
  %36 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.ctrl_1, i16 0, i1 false), align 4, !dbg !676
  store i32 %36, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i1 false), align 4, !dbg !677
  br label %42, !dbg !673

37:                                               ; preds = %8
  %38 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !678
  %39 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !678
  %40 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !678
  store i16 %38, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !679
  store i16 lshr (i16 ptrtoint ([1 x i32]* @"$$csl_base_address$$0$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11" to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !679
  store i16 %39, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !679
  store i16 %40, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !679
  %41 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @"$$csl_base_address$$0$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11", i16 0, i1 false), align 4, !dbg !680
  store i32 %41, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i1 false), align 4, !dbg !681
  br label %42, !dbg !673

42:                                               ; preds = %32, %37
  store i32 165646921, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i2 1), align 4, !dbg !682
  %43 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !683
  %44 = icmp eq i16 0, %43, !dbg !684
  br i1 %44, label %45, label %56, !dbg !685

45:                                               ; preds = %42
  %46 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !686
  %47 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !686
  %48 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !686
  %49 = load i16, i16* %17, align 2, !dbg !687
  %50 = call i16* @.get_tensor_ptr(i16 %49), !dbg !688
  %51 = ptrtoint i16* %50 to i16, !dbg !689
  %52 = lshr i16 %51, 1, !dbg !689
  store i16 %46, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !690
  store i16 %52, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !690
  store i16 %47, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !690
  store i16 %48, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !690
  %53 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !691
  %54 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !691
  %55 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !691
  store i16 1, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !692
  store i16 %53, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !692
  store i16 %54, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !692
  store i16 %55, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !692
  call void @llvm.sdr.actvt.r(i16 21), !dbg !693
  br label %63, !dbg !685

56:                                               ; preds = %42
  %57 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !694
  %58 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !694
  %59 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !694
  store i16 %57, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !695
  store i16 lshr (i16 ptrtoint ([1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.data_buf to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !695
  store i16 %58, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !695
  store i16 %59, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !695
  %60 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !696
  %61 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !696
  %62 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !696
  store i16 1, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !697
  store i16 %60, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !697
  store i16 %61, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !697
  store i16 %62, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !697
  call void @llvm.sdr.ublk.r(i16 0), !dbg !698
  br label %63, !dbg !685

63:                                               ; preds = %45, %56
  ret void, !dbg !673
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x(i32 %0) #8 !dbg !699 {
  %2 = alloca i32, i16 1, align 4, !dbg !700
  store i32 %0, i32* %2, align 4, !dbg !700
  call void @llvm.sdr.blk.r(i16 0), !dbg !702
  %3 = load i32, i32* %2, align 4, !dbg !703
  store i32 %3, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.data_buf, i16 0, i1 false), align 4, !dbg !704
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !705
  %4 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !706
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !706
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !706
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !706
  store volatile i16 %4, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !707
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !707
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !707
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !707
  call void asm sideeffect "nop", ""(), !dbg !707
  call void asm sideeffect "nop", ""(), !dbg !707
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !708
  %8 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !709
  %9 = add i16 %8, 1, !dbg !710
  store i16 %9, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !711
  ret void, !dbg !712
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_send_data() #9 !dbg !713 {
  %1 = alloca i16, i16 1, align 2, !dbg !714
  %2 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !716
  %3 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !717
  %4 = icmp ult i16 %2, %3, !dbg !718
  br i1 %4, label %5, label %27, !dbg !719

5:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !720
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !721
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !721
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !721
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !721
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !722
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !722
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !722
  store volatile i16 %9, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !722
  call void asm sideeffect "nop", ""(), !dbg !722
  call void asm sideeffect "nop", ""(), !dbg !722
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_is_half, align 2, !dbg !723
  %11 = icmp ult i16 0, %10, !dbg !724
  br i1 %11, label %12, label %18, !dbg !725

12:                                               ; preds = %5
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !726
  %13 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !727
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !727
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !727
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !727
  %17 = add i16 %14, 1, !dbg !728
  store i16 %13, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !729
  store i16 %17, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !729
  store i16 %15, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !729
  store i16 %16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !729
  br label %24, !dbg !725

18:                                               ; preds = %5
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !730
  %19 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !731
  %20 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !731
  %21 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !731
  %22 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !731
  %23 = add i16 %20, 2, !dbg !732
  store i16 %19, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !733
  store i16 %23, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !733
  store i16 %21, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !733
  store i16 %22, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !733
  br label %24, !dbg !725

24:                                               ; preds = %12, %18
  %25 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !734
  %26 = add i16 %25, 1, !dbg !735
  store i16 %26, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !736
  br label %34, !dbg !719

27:                                               ; preds = %0
  %28 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !737
  store i16 %28, i16* %1, align 2, !dbg !714
  %29 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !738
  %30 = load i16, i16* %1, align 2, !dbg !739
  %31 = icmp eq i16 %29, %30, !dbg !740
  br i1 %31, label %32, label %33, !dbg !741

32:                                               ; preds = %27
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !742
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__1 to i8*)), !dbg !743
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !744
  br label %33, !dbg !741

33:                                               ; preds = %32, %27
  br label %34, !dbg !719

34:                                               ; preds = %24, %33
  ret void, !dbg !719
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl() #10 !dbg !745 {
  %1 = alloca i16, i16 1, align 2, !dbg !746
  %2 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !748
  %3 = icmp eq i16 0, %2, !dbg !749
  br i1 %3, label %4, label %9, !dbg !750

4:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__2 to i8*)), !dbg !751
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !752
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !752
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !752
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !752
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !753
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !753
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !753
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !753
  call void asm sideeffect "nop", ""(), !dbg !753
  call void asm sideeffect "nop", ""(), !dbg !753
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !754
  br label %31, !dbg !750

9:                                                ; preds = %0
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !755
  %11 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !756
  %12 = icmp ult i16 %10, %11, !dbg !757
  br i1 %12, label %13, label %18, !dbg !758

13:                                               ; preds = %9
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__3 to i8*)), !dbg !759
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !760
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !760
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !760
  %17 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !760
  store volatile i16 %14, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !761
  store volatile i16 %15, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !761
  store volatile i16 %16, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !761
  store volatile i16 %17, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !761
  call void asm sideeffect "nop", ""(), !dbg !761
  call void asm sideeffect "nop", ""(), !dbg !761
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !762
  br label %30, !dbg !758

18:                                               ; preds = %9
  %19 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !763
  store i16 %19, i16* %1, align 2, !dbg !746
  %20 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !764
  %21 = load i16, i16* %1, align 2, !dbg !765
  %22 = icmp eq i16 %20, %21, !dbg !766
  br i1 %22, label %23, label %24, !dbg !767

23:                                               ; preds = %18
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__4 to i8*)), !dbg !768
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__5 to i8*)), !dbg !769
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !770
  br label %29, !dbg !767

24:                                               ; preds = %18
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !771
  %25 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !772
  %26 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !772
  %27 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !772
  %28 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !772
  store volatile i16 %25, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !773
  store volatile i16 %26, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !773
  store volatile i16 %27, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !773
  store volatile i16 %28, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !773
  call void asm sideeffect "nop", ""(), !dbg !773
  call void asm sideeffect "nop", ""(), !dbg !773
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !774
  br label %29, !dbg !767

29:                                               ; preds = %23, %24
  br label %30, !dbg !758

30:                                               ; preds = %13, %29
  br label %31, !dbg !750

31:                                               ; preds = %4, %30
  ret void, !dbg !750
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.d2h_configure(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7) !dbg !775 {
  %9 = alloca i1, i16 1, align 1, !dbg !776
  %10 = alloca i1, i16 1, align 1, !dbg !778
  %11 = alloca i1, i16 1, align 1, !dbg !779
  %12 = alloca i16, i16 1, align 2, !dbg !780
  %13 = alloca i16, i16 1, align 2, !dbg !781
  %14 = alloca i16, i16 1, align 2, !dbg !782
  %15 = alloca i16, i16 1, align 2, !dbg !783
  %16 = alloca i16, i16 1, align 2, !dbg !784
  %17 = alloca i16, i16 1, align 2, !dbg !785
  %18 = alloca i16, i16 1, align 2, !dbg !786
  %19 = alloca i16, i16 1, align 2, !dbg !787
  %20 = alloca i16, i16 1, align 2, !dbg !788
  %21 = alloca i16, i16 1, align 2, !dbg !789
  %22 = alloca i16, i16 1, align 2, !dbg !790
  %23 = alloca i16, i16 1, align 2, !dbg !791
  %24 = alloca i16, i16 1, align 2, !dbg !792
  %25 = alloca i16, i16 1, align 2, !dbg !793
  store i16 %0, i16* %25, align 2, !dbg !793
  store i16 %1, i16* %24, align 2, !dbg !792
  store i16 %2, i16* %23, align 2, !dbg !791
  store i16 %3, i16* %22, align 2, !dbg !790
  store i16 %4, i16* %21, align 2, !dbg !789
  store i16 %5, i16* %20, align 2, !dbg !788
  store i16 %6, i16* %19, align 2, !dbg !787
  store i16 %7, i16* %18, align 2, !dbg !786
  %26 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !794
  store i16 %26, i16* %17, align 2, !dbg !785
  %27 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_y_coord(), !dbg !795
  store i16 %27, i16* %16, align 2, !dbg !784
  %28 = load i16, i16* %24, align 2, !dbg !796
  store i16 %28, i16* %15, align 2, !dbg !783
  %29 = load i16, i16* %24, align 2, !dbg !797
  %30 = load i16, i16* %22, align 2, !dbg !798
  %31 = add i16 %29, %30, !dbg !799
  %32 = sub i16 %31, 1, !dbg !800
  store i16 %32, i16* %14, align 2, !dbg !782
  %33 = load i16, i16* %23, align 2, !dbg !801
  store i16 %33, i16* %13, align 2, !dbg !781
  %34 = load i16, i16* %23, align 2, !dbg !802
  %35 = load i16, i16* %21, align 2, !dbg !803
  %36 = add i16 %34, %35, !dbg !804
  %37 = sub i16 %36, 1, !dbg !805
  store i16 %37, i16* %12, align 2, !dbg !780
  store i1 false, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !806
  %38 = load i16, i16* %17, align 2, !dbg !807
  %39 = load i16, i16* %15, align 2, !dbg !808
  %40 = icmp sge i16 %38, %39, !dbg !809
  br i1 %40, label %41, label %45, !dbg !779

41:                                               ; preds = %8
  %42 = load i16, i16* %16, align 2, !dbg !810
  %43 = load i16, i16* %12, align 2, !dbg !811
  %44 = icmp sle i16 %42, %43, !dbg !812
  store i1 %44, i1* %11, align 1, !dbg !779
  br label %46, !dbg !779

45:                                               ; preds = %8
  store i1 false, i1* %11, align 1, !dbg !779
  br label %46, !dbg !779

46:                                               ; preds = %41, %45
  %47 = load i1, i1* %11, align 1, !dbg !779
  br i1 %47, label %48, label %52, !dbg !778

48:                                               ; preds = %46
  %49 = load i16, i16* %16, align 2, !dbg !813
  %50 = load i16, i16* %13, align 2, !dbg !814
  %51 = icmp sge i16 %49, %50, !dbg !815
  store i1 %51, i1* %10, align 1, !dbg !778
  br label %53, !dbg !778

52:                                               ; preds = %46
  store i1 false, i1* %10, align 1, !dbg !778
  br label %53, !dbg !778

53:                                               ; preds = %48, %52
  %54 = load i1, i1* %10, align 1, !dbg !778
  br i1 %54, label %55, label %56, !dbg !816

55:                                               ; preds = %53
  store i1 true, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !817
  br label %56, !dbg !816

56:                                               ; preds = %55, %53
  store i1 false, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !818
  %57 = load i16, i16* %17, align 2, !dbg !819
  %58 = load i16, i16* %14, align 2, !dbg !820
  %59 = icmp sle i16 %57, %58, !dbg !821
  br i1 %59, label %60, label %62, !dbg !776

60:                                               ; preds = %56
  %61 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !822
  store i1 %61, i1* %9, align 1, !dbg !776
  br label %63, !dbg !776

62:                                               ; preds = %56
  store i1 false, i1* %9, align 1, !dbg !776
  br label %63, !dbg !776

63:                                               ; preds = %60, %62
  %64 = load i1, i1* %9, align 1, !dbg !776
  br i1 %64, label %65, label %66, !dbg !823

65:                                               ; preds = %63
  store i1 true, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !824
  br label %66, !dbg !823

66:                                               ; preds = %65, %63
  %67 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !825
  br i1 %67, label %68, label %86, !dbg !826

68:                                               ; preds = %66
  call void @__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position(i16 31959), !dbg !827
  %69 = load i16, i16* %15, align 2, !dbg !828
  %70 = load i16, i16* %17, align 2, !dbg !829
  %71 = icmp eq i16 %69, %70, !dbg !830
  br i1 %71, label %72, label %73, !dbg !831

72:                                               ; preds = %68
  call void @__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 31765), !dbg !832
  br label %74, !dbg !831

73:                                               ; preds = %68
  call void @__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 31765), !dbg !833
  br label %74, !dbg !831

74:                                               ; preds = %72, %73
  call void @sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit(i16 21), !dbg !834
  %75 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !835
  br i1 %75, label %76, label %85, !dbg !836

76:                                               ; preds = %74
  %77 = load i16, i16* %20, align 2, !dbg !837
  %78 = load i16, i16* %19, align 2, !dbg !838
  %79 = load i16, i16* %24, align 2, !dbg !839
  %80 = load i16, i16* %23, align 2, !dbg !840
  %81 = load i16, i16* %22, align 2, !dbg !841
  %82 = load i16, i16* %21, align 2, !dbg !842
  %83 = load i16, i16* %25, align 2, !dbg !843
  %84 = load i16, i16* %18, align 2, !dbg !844
  call void @sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start(i16 %77, i16 %78, i16 %79, i16 %80, i16 %81, i16 %82, i16 %83, i16 %84), !dbg !845
  br label %85, !dbg !836

85:                                               ; preds = %76, %74
  br label %87, !dbg !826

86:                                               ; preds = %66
  call void @llvm.sdr.actvt.r(i16 28), !dbg !846
  br label %87, !dbg !826

87:                                               ; preds = %85, %86
  ret void, !dbg !779
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit(i16 %0) !dbg !847 {
  %2 = alloca i16, i16 1, align 2, !dbg !848
  %3 = alloca i16, i16 1, align 2, !dbg !850
  %4 = alloca i16, i16 1, align 2, !dbg !851
  %5 = alloca i16, i16 1, align 2, !dbg !852
  store i16 %0, i16* %5, align 2, !dbg !852
  %6 = load i16, i16* %5, align 2, !dbg !853
  store i16 %6, i16* %4, align 2, !dbg !851
  %7 = load i16, i16* %4, align 2, !dbg !854
  %8 = add i16 %7, 31744, !dbg !855
  store i16 %8, i16* %3, align 2, !dbg !850
  %9 = load i16, i16* %3, align 2, !dbg !856
  %10 = shl i16 %9, 1, !dbg !857
  %11 = inttoptr i16 %10 to i16*, !dbg !857
  call void asm sideeffect "nop", ""(), !dbg !857
  call void asm sideeffect "nop", ""(), !dbg !857
  %12 = load volatile i16, i16* %11, align 2, !dbg !857
  store i16 %12, i16* %2, align 2, !dbg !848
  %13 = load i16, i16* %3, align 2, !dbg !858
  %14 = load i16, i16* %2, align 2, !dbg !859
  %15 = and i16 %14, 32767, !dbg !860
  %16 = shl i16 %13, 1, !dbg !861
  %17 = inttoptr i16 %16 to i16*, !dbg !861
  store volatile i16 %15, i16* %17, align 2, !dbg !861
  call void asm sideeffect "nop", ""(), !dbg !861
  call void asm sideeffect "nop", ""(), !dbg !861
  ret void, !dbg !862
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord() !dbg !863 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 2), !dbg !864
  %2 = sub i16 %1, 4, !dbg !866
  ret i16 %2, !dbg !867
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord() !dbg !868 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 0), !dbg !869
  %2 = sub i16 %1, 1, !dbg !871
  ret i16 %2, !dbg !872
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 %0) !dbg !873 {
  %2 = alloca i16, i16 1, align 2, !dbg !874
  %3 = alloca i16, i16 1, align 2, !dbg !876
  store i16 %0, i16* %3, align 2, !dbg !876
  %4 = load i16, i16* %3, align 2, !dbg !877
  %5 = lshr i16 %4, 1, !dbg !878
  %6 = add i16 %5, 31813, !dbg !879
  %7 = shl i16 %6, 1, !dbg !880
  %8 = inttoptr i16 %7 to i16*, !dbg !880
  call void asm sideeffect "nop", ""(), !dbg !880
  call void asm sideeffect "nop", ""(), !dbg !880
  %9 = load volatile i16, i16* %8, align 2, !dbg !880
  store i16 %9, i16* %2, align 2, !dbg !874
  %10 = load i16, i16* %2, align 2, !dbg !881
  %11 = and i16 %10, 2047, !dbg !882
  ret i16 %11, !dbg !883
}

define internal i16 @sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr(i16 %0) !dbg !884 {
  %2 = alloca i16, i16 1, align 2, !dbg !886
  store i16 %0, i16* %2, align 2, !dbg !886
  %3 = load i16, i16* %2, align 2, !dbg !888
  %4 = mul i16 %3, 2, !dbg !889
  %5 = add i16 %4, 31680, !dbg !890
  ret i16 %5, !dbg !891
}

define internal void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 %0, i16 %1, i1 %2) !dbg !892 {
  %4 = alloca i16, i16 1, align 2, !dbg !893
  %5 = alloca i16, i16 1, align 2, !dbg !895
  %6 = alloca i1, i16 1, align 1, !dbg !896
  %7 = alloca i16, i16 1, align 2, !dbg !897
  %8 = alloca i16, i16 1, align 2, !dbg !898
  store i16 %0, i16* %8, align 2, !dbg !898
  store i16 %1, i16* %7, align 2, !dbg !897
  store i1 %2, i1* %6, align 1, !dbg !896
  %9 = load i16, i16* %8, align 2, !dbg !899
  %10 = call i16 @sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr(i16 %9), !dbg !900
  store i16 %10, i16* %5, align 2, !dbg !895
  %11 = load i16, i16* %5, align 2, !dbg !901
  %12 = shl i16 %11, 1, !dbg !902
  %13 = inttoptr i16 %12 to i16*, !dbg !902
  call void asm sideeffect "nop", ""(), !dbg !902
  call void asm sideeffect "nop", ""(), !dbg !902
  call void asm sideeffect "nop", ""(), !dbg !902
  call void asm sideeffect "nop", ""(), !dbg !902
  %14 = load volatile i16, i16* %13, align 2, !dbg !902
  store i16 %14, i16* %4, align 2, !dbg !893
  %15 = load i1, i1* %6, align 1, !dbg !903
  br i1 %15, label %16, label %19, !dbg !904

16:                                               ; preds = %3
  %17 = load i16, i16* %4, align 2, !dbg !905
  %18 = or i16 %17, 2048, !dbg !906
  store i16 %18, i16* %4, align 2, !dbg !907
  br label %22, !dbg !904

19:                                               ; preds = %3
  %20 = load i16, i16* %4, align 2, !dbg !908
  %21 = and i16 %20, -2049, !dbg !909
  store i16 %21, i16* %4, align 2, !dbg !910
  br label %22, !dbg !904

22:                                               ; preds = %16, %19
  %23 = load i16, i16* %4, align 2, !dbg !911
  %24 = and i16 %23, -32, !dbg !912
  store i16 %24, i16* %4, align 2, !dbg !913
  %25 = load i16, i16* %4, align 2, !dbg !914
  %26 = load i16, i16* %7, align 2, !dbg !915
  %27 = add i16 %25, %26, !dbg !916
  store i16 %27, i16* %4, align 2, !dbg !917
  %28 = load i16, i16* %5, align 2, !dbg !918
  %29 = load i16, i16* %4, align 2, !dbg !919
  %30 = shl i16 %28, 1, !dbg !920
  %31 = inttoptr i16 %30 to i16*, !dbg !920
  store volatile i16 %29, i16* %31, align 2, !dbg !920
  call void asm sideeffect "nop", ""(), !dbg !920
  call void asm sideeffect "nop", ""(), !dbg !920
  call void asm sideeffect "nop", ""(), !dbg !920
  call void asm sideeffect "nop", ""(), !dbg !920
  ret void, !dbg !904
}

define internal i16 @sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr(i16 %0) !dbg !921 {
  %2 = alloca i16, i16 1, align 2, !dbg !923
  store i16 %0, i16* %2, align 2, !dbg !923
  %3 = load i16, i16* %2, align 2, !dbg !925
  %4 = add i16 %3, 31616, !dbg !926
  ret i16 %4, !dbg !927
}

define internal void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 %0, i16 %1) !dbg !928 {
  %3 = alloca i16, i16 1, align 2, !dbg !929
  %4 = alloca i16, i16 1, align 2, !dbg !931
  %5 = alloca i16, i16 1, align 2, !dbg !932
  %6 = alloca i16, i16 1, align 2, !dbg !933
  store i16 %0, i16* %6, align 2, !dbg !933
  store i16 %1, i16* %5, align 2, !dbg !932
  %7 = load i16, i16* %6, align 2, !dbg !934
  %8 = call i16 @sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr(i16 %7), !dbg !935
  store i16 %8, i16* %4, align 2, !dbg !931
  %9 = load i16, i16* %4, align 2, !dbg !936
  %10 = shl i16 %9, 1, !dbg !937
  %11 = inttoptr i16 %10 to i16*, !dbg !937
  call void asm sideeffect "nop", ""(), !dbg !937
  call void asm sideeffect "nop", ""(), !dbg !937
  call void asm sideeffect "nop", ""(), !dbg !937
  call void asm sideeffect "nop", ""(), !dbg !937
  %12 = load volatile i16, i16* %11, align 2, !dbg !937
  store i16 %12, i16* %3, align 2, !dbg !929
  %13 = load i16, i16* %3, align 2, !dbg !938
  %14 = and i16 %13, -497, !dbg !939
  store i16 %14, i16* %3, align 2, !dbg !940
  %15 = load i16, i16* %3, align 2, !dbg !941
  %16 = load i16, i16* %5, align 2, !dbg !942
  %17 = add i16 %15, %16, !dbg !943
  %18 = shl i16 %17, 4, !dbg !944
  store i16 %18, i16* %3, align 2, !dbg !945
  %19 = load i16, i16* %4, align 2, !dbg !946
  %20 = load i16, i16* %3, align 2, !dbg !947
  %21 = shl i16 %19, 1, !dbg !948
  %22 = inttoptr i16 %21 to i16*, !dbg !948
  store volatile i16 %20, i16* %22, align 2, !dbg !948
  call void asm sideeffect "nop", ""(), !dbg !948
  call void asm sideeffect "nop", ""(), !dbg !948
  call void asm sideeffect "nop", ""(), !dbg !948
  call void asm sideeffect "nop", ""(), !dbg !948
  ret void, !dbg !949
}

define internal i16* @.get_tensor_ptr(i16 %0) !dbg !950 {
  %2 = alloca i16, i16 1, align 2, !dbg !951
  store i16 %0, i16* %2, align 2, !dbg !951
  %3 = load i16, i16* %2, align 2, !dbg !951
  %4 = zext i16 %3 to i32, !dbg !951
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
  ], !dbg !951

5:                                                ; preds = %1
  br i1 false, label %6, label %7, !dbg !951

6:                                                ; preds = %5
  br label %8, !dbg !951

7:                                                ; preds = %5
  call void asm sideeffect "hcf", ""(), !dbg !951
  br label %8, !dbg !951

8:                                                ; preds = %6, %7
  br label %33, !dbg !951

9:                                                ; preds = %1
  %10 = load i16*, i16** @p_a, align 8, !dbg !951
  br label %33, !dbg !951

11:                                               ; preds = %1
  %12 = load i16*, i16** @p_b, align 8, !dbg !951
  br label %33, !dbg !951

13:                                               ; preds = %1
  %14 = load i16*, i16** @p_g, align 8, !dbg !951
  br label %33, !dbg !951

15:                                               ; preds = %1
  %16 = load i16*, i16** @p_c, align 8, !dbg !951
  br label %33, !dbg !951

17:                                               ; preds = %1
  %18 = load i16*, i16** @p_d, align 8, !dbg !951
  br label %33, !dbg !951

19:                                               ; preds = %1
  %20 = load half*, half** @p_af, align 8, !dbg !951
  %21 = bitcast half* %20 to i16*, !dbg !951
  br label %33, !dbg !951

22:                                               ; preds = %1
  %23 = load half*, half** @p_bf, align 8, !dbg !951
  %24 = bitcast half* %23 to i16*, !dbg !951
  br label %33, !dbg !951

25:                                               ; preds = %1
  %26 = load half*, half** @p_gf, align 8, !dbg !951
  %27 = bitcast half* %26 to i16*, !dbg !951
  br label %33, !dbg !951

28:                                               ; preds = %1
  %29 = load half*, half** @p_cf, align 8, !dbg !951
  %30 = bitcast half* %29 to i16*, !dbg !951
  br label %33, !dbg !951

31:                                               ; preds = %1
  %32 = load i16*, i16** @p_mark, align 8, !dbg !951
  br label %33, !dbg !951

33:                                               ; preds = %8, %9, %11, %13, %15, %17, %19, %22, %25, %28, %31
  %34 = phi i16 [ -2, %31 ], [ -2, %28 ], [ -2, %25 ], [ -2, %22 ], [ -2, %19 ], [ -2, %17 ], [ -2, %15 ], [ -2, %13 ], [ -2, %11 ], [ -2, %9 ], [ 0, %8 ]
  %35 = phi i16* [ %32, %31 ], [ %30, %28 ], [ %27, %25 ], [ %24, %22 ], [ %21, %19 ], [ %18, %17 ], [ %16, %15 ], [ %14, %13 ], [ %12, %11 ], [ %10, %9 ], [ undef, %8 ]
  br label %36, !dbg !951

36:                                               ; preds = %33
  %37 = icmp ne i16 %34, 0, !dbg !951
  br i1 %37, label %38, label %39, !dbg !951

38:                                               ; preds = %36
  br label %41, !dbg !951

39:                                               ; preds = %36
  %40 = load i16*, i16** @p_mark, align 8, !dbg !951
  br label %41, !dbg !951

41:                                               ; preds = %38, %39
  %42 = phi i16* [ %40, %39 ], [ %35, %38 ]
  br label %43, !dbg !951

43:                                               ; preds = %41
  ret i16* %42, !dbg !951
}

define internal void @__generic0sys_mod.sys_mod.tile_config.queue_flush.exit() !dbg !953 {
  store volatile i16 1, i16* inttoptr (i16 -2268 to i16*), align 2, !dbg !955
  call void asm sideeffect "nop", ""(), !dbg !955
  call void asm sideeffect "nop", ""(), !dbg !955
  ret void, !dbg !957
}

define internal void @__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position(i16 %0) !dbg !958 {
  %2 = alloca i16, i16 1, align 2, !dbg !960
  %3 = alloca i16, i16 1, align 2, !dbg !962
  %4 = alloca i16, i16 1, align 2, !dbg !963
  store i16 %0, i16* %4, align 2, !dbg !963
  %5 = load i16, i16* %4, align 2, !dbg !964
  store i16 %5, i16* %3, align 2, !dbg !962
  %6 = load i16, i16* %3, align 2, !dbg !965
  %7 = shl i16 %6, 1, !dbg !966
  %8 = inttoptr i16 %7 to i16*, !dbg !966
  call void asm sideeffect "nop", ""(), !dbg !966
  call void asm sideeffect "nop", ""(), !dbg !966
  call void asm sideeffect "nop", ""(), !dbg !966
  call void asm sideeffect "nop", ""(), !dbg !966
  %9 = load volatile i16, i16* %8, align 2, !dbg !966
  store i16 %9, i16* %2, align 2, !dbg !960
  %10 = load i16, i16* %2, align 2, !dbg !967
  %11 = and i16 %10, -16, !dbg !968
  store i16 %11, i16* %2, align 2, !dbg !968
  %12 = load i16, i16* %3, align 2, !dbg !969
  %13 = load i16, i16* %2, align 2, !dbg !970
  %14 = shl i16 %12, 1, !dbg !971
  %15 = inttoptr i16 %14 to i16*, !dbg !971
  store volatile i16 %13, i16* %15, align 2, !dbg !971
  call void asm sideeffect "nop", ""(), !dbg !971
  call void asm sideeffect "nop", ""(), !dbg !971
  call void asm sideeffect "nop", ""(), !dbg !971
  call void asm sideeffect "nop", ""(), !dbg !971
  ret void, !dbg !972
}

define internal void @__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 %0) !dbg !973 {
  %2 = alloca i16, i16 1, align 2, !dbg !975
  %3 = alloca i16, i16 1, align 2, !dbg !977
  %4 = alloca i16, i16 1, align 2, !dbg !978
  store i16 %0, i16* %4, align 2, !dbg !978
  %5 = load i16, i16* %4, align 2, !dbg !979
  store i16 %5, i16* %3, align 2, !dbg !977
  %6 = load i16, i16* %3, align 2, !dbg !980
  %7 = shl i16 %6, 1, !dbg !981
  %8 = inttoptr i16 %7 to i16*, !dbg !981
  call void asm sideeffect "nop", ""(), !dbg !981
  call void asm sideeffect "nop", ""(), !dbg !981
  %9 = load volatile i16, i16* %8, align 2, !dbg !981
  store i16 %9, i16* %2, align 2, !dbg !975
  %10 = load i16, i16* %2, align 2, !dbg !982
  %11 = and i16 %10, -256, !dbg !983
  store i16 %11, i16* %2, align 2, !dbg !984
  %12 = load i16, i16* %2, align 2, !dbg !985
  %13 = load i16, i16* %2, align 2, !dbg !986
  %14 = call i16 @__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %13), !dbg !987
  %15 = or i16 %12, %14, !dbg !988
  store i16 %15, i16* %2, align 2, !dbg !988
  %16 = load i16, i16* %2, align 2, !dbg !989
  %17 = load i16, i16* %2, align 2, !dbg !990
  %18 = call i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %17), !dbg !991
  %19 = or i16 %16, %18, !dbg !992
  store i16 %19, i16* %2, align 2, !dbg !992
  %20 = load i16, i16* %3, align 2, !dbg !993
  %21 = load i16, i16* %2, align 2, !dbg !994
  %22 = shl i16 %20, 1, !dbg !995
  %23 = inttoptr i16 %22 to i16*, !dbg !995
  store volatile i16 %21, i16* %23, align 2, !dbg !995
  call void asm sideeffect "nop", ""(), !dbg !995
  call void asm sideeffect "nop", ""(), !dbg !995
  ret void, !dbg !996
}

define internal void @__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 %0) !dbg !997 {
  %2 = alloca i16, i16 1, align 2, !dbg !998
  %3 = alloca i16, i16 1, align 2, !dbg !1000
  %4 = alloca i16, i16 1, align 2, !dbg !1001
  store i16 %0, i16* %4, align 2, !dbg !1001
  %5 = load i16, i16* %4, align 2, !dbg !1002
  store i16 %5, i16* %3, align 2, !dbg !1000
  %6 = load i16, i16* %3, align 2, !dbg !1003
  %7 = shl i16 %6, 1, !dbg !1004
  %8 = inttoptr i16 %7 to i16*, !dbg !1004
  call void asm sideeffect "nop", ""(), !dbg !1004
  call void asm sideeffect "nop", ""(), !dbg !1004
  %9 = load volatile i16, i16* %8, align 2, !dbg !1004
  store i16 %9, i16* %2, align 2, !dbg !998
  %10 = load i16, i16* %2, align 2, !dbg !1005
  %11 = and i16 %10, -256, !dbg !1006
  store i16 %11, i16* %2, align 2, !dbg !1007
  %12 = load i16, i16* %2, align 2, !dbg !1008
  %13 = load i16, i16* %2, align 2, !dbg !1009
  %14 = call i16 @__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %13), !dbg !1010
  %15 = or i16 %12, %14, !dbg !1011
  store i16 %15, i16* %2, align 2, !dbg !1011
  %16 = load i16, i16* %2, align 2, !dbg !1012
  %17 = load i16, i16* %2, align 2, !dbg !1013
  %18 = call i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %17), !dbg !1014
  %19 = or i16 %16, %18, !dbg !1015
  store i16 %19, i16* %2, align 2, !dbg !1015
  %20 = load i16, i16* %3, align 2, !dbg !1016
  %21 = load i16, i16* %2, align 2, !dbg !1017
  %22 = shl i16 %20, 1, !dbg !1018
  %23 = inttoptr i16 %22 to i16*, !dbg !1018
  store volatile i16 %21, i16* %23, align 2, !dbg !1018
  call void asm sideeffect "nop", ""(), !dbg !1018
  call void asm sideeffect "nop", ""(), !dbg !1018
  ret void, !dbg !1019
}

define internal i16 @__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %0) !dbg !1020 {
  %2 = alloca i16, i16 1, align 2, !dbg !1021
  %3 = alloca i16, i16 1, align 2, !dbg !1023
  store i16 %0, i16* %3, align 2, !dbg !1023
  %4 = load i16, i16* %3, align 2, !dbg !1024
  store i16 %4, i16* %2, align 2, !dbg !1021
  %5 = load i16, i16* %2, align 2, !dbg !1025
  store i16 %5, i16* %2, align 2, !dbg !1026
  %6 = load i16, i16* %2, align 2, !dbg !1027
  ret i16 %6, !dbg !1028
}

define internal i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %0) !dbg !1029 {
  %2 = alloca i16, i16 1, align 2, !dbg !1030
  %3 = alloca i16, i16 1, align 2, !dbg !1032
  store i16 %0, i16* %3, align 2, !dbg !1032
  %4 = load i16, i16* %3, align 2, !dbg !1033
  store i16 %4, i16* %2, align 2, !dbg !1030
  %5 = load i16, i16* %2, align 2, !dbg !1034
  %6 = or i16 %5, 2, !dbg !1035
  store i16 %6, i16* %2, align 2, !dbg !1035
  %7 = load i16, i16* %2, align 2, !dbg !1036
  ret i16 %7, !dbg !1037
}

define internal i16 @__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %0) !dbg !1038 {
  %2 = alloca i16, i16 1, align 2, !dbg !1039
  %3 = alloca i16, i16 1, align 2, !dbg !1041
  store i16 %0, i16* %3, align 2, !dbg !1041
  %4 = load i16, i16* %3, align 2, !dbg !1042
  store i16 %4, i16* %2, align 2, !dbg !1039
  %5 = load i16, i16* %2, align 2, !dbg !1043
  %6 = or i16 %5, 128, !dbg !1044
  store i16 %6, i16* %2, align 2, !dbg !1044
  %7 = load i16, i16* %2, align 2, !dbg !1045
  ret i16 %7, !dbg !1046
}

define internal void @__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction(i16 %0) !dbg !1047 {
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
  %9 = load volatile i16, i16* %8, align 2, !dbg !1054
  store i16 %9, i16* %2, align 2, !dbg !1048
  %10 = load i16, i16* %2, align 2, !dbg !1055
  %11 = and i16 %10, -17, !dbg !1056
  store i16 %11, i16* %2, align 2, !dbg !1056
  %12 = load i16, i16* %3, align 2, !dbg !1057
  %13 = load i16, i16* %2, align 2, !dbg !1058
  %14 = shl i16 %12, 1, !dbg !1059
  %15 = inttoptr i16 %14 to i16*, !dbg !1059
  store volatile i16 %13, i16* %15, align 2, !dbg !1059
  call void asm sideeffect "nop", ""(), !dbg !1059
  call void asm sideeffect "nop", ""(), !dbg !1059
  ret void, !dbg !1060
}

define internal void @__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction(i16 %0) !dbg !1061 {
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
  %11 = or i16 %10, 16, !dbg !1070
  store i16 %11, i16* %2, align 2, !dbg !1070
  %12 = load i16, i16* %3, align 2, !dbg !1071
  %13 = load i16, i16* %2, align 2, !dbg !1072
  %14 = shl i16 %12, 1, !dbg !1073
  %15 = inttoptr i16 %14 to i16*, !dbg !1073
  store volatile i16 %13, i16* %15, align 2, !dbg !1073
  call void asm sideeffect "nop", ""(), !dbg !1073
  call void asm sideeffect "nop", ""(), !dbg !1073
  ret void, !dbg !1074
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
!4 = !DIFile(filename: "./pe.csl", directory: "/home/USER/xkernel/studies/wse3-characterization/microbench/pcsweep/cases/i16chain_asm")
!5 = !DISubroutineType(types: !6)
!6 = !{}
!7 = !DILocation(line: 17, column: 11, scope: !8)
!8 = !DILexicalBlockFile(scope: !3, file: !4, discriminator: 0)
!9 = !DILocation(line: 18, column: 11, scope: !8)
!10 = !DILocation(line: 19, column: 11, scope: !8)
!11 = !DILocation(line: 20, column: 11, scope: !8)
!12 = !DILocation(line: 21, column: 11, scope: !8)
!13 = !DILocation(line: 22, column: 11, scope: !8)
!14 = !DILocation(line: 23, column: 11, scope: !8)
!15 = !DILocation(line: 24, column: 11, scope: !8)
!16 = !DILocation(line: 26, column: 11, scope: !8)
!17 = !DILocation(line: 27, column: 3, scope: !8)
!18 = !DILocation(line: 16, column: 1, scope: !8)
!19 = distinct !DISubprogram(name: "f_exit", linkageName: "f_exit", scope: null, file: !4, line: 30, type: !5, scopeLine: 30, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!20 = !DILocation(line: 30, column: 22, scope: !21)
!21 = !DILexicalBlockFile(scope: !19, file: !4, discriminator: 0)
!22 = !DILocation(line: 30, column: 1, scope: !21)
!23 = distinct !DISubprogram(name: "sys_mod.sys_nop", linkageName: "sys_mod.sys_nop", scope: null, file: !24, line: 90, type: !5, scopeLine: 90, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!24 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/memcpy.csl", directory: "")
!25 = !DILocation(line: 90, column: 1, scope: !26)
!26 = !DILexicalBlockFile(scope: !23, file: !24, discriminator: 0)
!27 = distinct !DISubprogram(name: "sys_mod.unblock_cmd_stream", linkageName: "sys_mod.unblock_cmd_stream", scope: null, file: !24, line: 102, type: !5, scopeLine: 102, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!28 = !DILocation(line: 103, column: 3, scope: !29)
!29 = !DILexicalBlockFile(scope: !27, file: !24, discriminator: 0)
!30 = !DILocation(line: 102, column: 1, scope: !29)
!31 = distinct !DISubprogram(name: "sys_mod.sys_mod.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.unblock_cmd_stream", scope: null, file: !32, line: 307, type: !5, scopeLine: 307, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!32 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpy.csl", directory: "")
!33 = !DILocation(line: 308, column: 5, scope: !34)
!34 = !DILexicalBlockFile(scope: !31, file: !32, discriminator: 0)
!35 = !DILocation(line: 307, column: 1, scope: !34)
!36 = distinct !DISubprogram(name: "sys_mod.sys_mod.teardown_h2d", linkageName: "sys_mod.sys_mod.teardown_h2d", scope: null, file: !32, line: 323, type: !5, scopeLine: 323, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!37 = !DILocation(line: 326, column: 5, scope: !38)
!38 = !DILexicalBlockFile(scope: !36, file: !32, discriminator: 0)
!39 = !DILocation(line: 323, column: 1, scope: !38)
!40 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_ublk_c22", linkageName: "sys_mod.sys_mod.f_ublk_c22", scope: null, file: !32, line: 335, type: !5, scopeLine: 335, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!41 = !DILocation(line: 336, column: 5, scope: !42)
!42 = !DILexicalBlockFile(scope: !40, file: !32, discriminator: 0)
!43 = !DILocation(line: 335, column: 1, scope: !42)
!44 = distinct !DISubprogram(name: "sys_mod.sys_mod.teardown_d2h", linkageName: "sys_mod.sys_mod.teardown_d2h", scope: null, file: !32, line: 344, type: !5, scopeLine: 344, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!45 = !DILocation(line: 355, column: 5, scope: !46)
!46 = !DILexicalBlockFile(scope: !44, file: !32, discriminator: 0)
!47 = !DILocation(line: 359, column: 5, scope: !46)
!48 = !DILocation(line: 344, column: 1, scope: !46)
!49 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_memcpyh2d", linkageName: "sys_mod.sys_mod.f_memcpyh2d", scope: null, file: !32, line: 460, type: !5, scopeLine: 460, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!50 = !DILocation(line: 477, column: 5, scope: !51)
!51 = !DILexicalBlockFile(scope: !49, file: !32, discriminator: 0)
!52 = !DILocation(line: 476, column: 5, scope: !51)
!53 = !DILocation(line: 475, column: 5, scope: !51)
!54 = !DILocation(line: 474, column: 5, scope: !51)
!55 = !DILocation(line: 473, column: 5, scope: !51)
!56 = !DILocation(line: 472, column: 5, scope: !51)
!57 = !DILocation(line: 471, column: 5, scope: !51)
!58 = !DILocation(line: 470, column: 5, scope: !51)
!59 = !DILocation(line: 469, column: 5, scope: !51)
!60 = !DILocation(line: 468, column: 5, scope: !51)
!61 = !DILocation(line: 467, column: 5, scope: !51)
!62 = !DILocation(line: 466, column: 5, scope: !51)
!63 = !DILocation(line: 465, column: 5, scope: !51)
!64 = !DILocation(line: 463, column: 5, scope: !51)
!65 = !DILocation(line: 462, column: 20, scope: !51)
!66 = !DILocation(line: 462, column: 32, scope: !51)
!67 = !DILocation(line: 462, column: 5, scope: !51)
!68 = !DILocation(line: 465, column: 33, scope: !51)
!69 = !DILocation(line: 465, column: 38, scope: !51)
!70 = !DILocation(line: 466, column: 34, scope: !51)
!71 = !DILocation(line: 466, column: 39, scope: !51)
!72 = !DILocation(line: 467, column: 34, scope: !51)
!73 = !DILocation(line: 467, column: 39, scope: !51)
!74 = !DILocation(line: 468, column: 33, scope: !51)
!75 = !DILocation(line: 468, column: 38, scope: !51)
!76 = !DILocation(line: 469, column: 33, scope: !51)
!77 = !DILocation(line: 469, column: 38, scope: !51)
!78 = !DILocation(line: 470, column: 35, scope: !51)
!79 = !DILocation(line: 470, column: 21, scope: !51)
!80 = !DILocation(line: 471, column: 41, scope: !51)
!81 = !DILocation(line: 471, column: 27, scope: !51)
!82 = !DILocation(line: 472, column: 39, scope: !51)
!83 = !DILocation(line: 472, column: 25, scope: !51)
!84 = !DILocation(line: 473, column: 44, scope: !51)
!85 = !DILocation(line: 473, column: 49, scope: !51)
!86 = !DILocation(line: 474, column: 41, scope: !51)
!87 = !DILocation(line: 474, column: 46, scope: !51)
!88 = !DILocation(line: 475, column: 41, scope: !51)
!89 = !DILocation(line: 475, column: 46, scope: !51)
!90 = !DILocation(line: 476, column: 59, scope: !51)
!91 = !DILocation(line: 476, column: 64, scope: !51)
!92 = !DILocation(line: 476, column: 50, scope: !51)
!93 = !DILocation(line: 476, column: 129, scope: !51)
!94 = !DILocation(line: 476, column: 134, scope: !51)
!95 = !DILocation(line: 476, column: 120, scope: !51)
!96 = !DILocation(line: 476, column: 118, scope: !51)
!97 = !DILocation(line: 476, column: 112, scope: !51)
!98 = !DILocation(line: 476, column: 36, scope: !51)
!99 = !DILocation(line: 477, column: 59, scope: !51)
!100 = !DILocation(line: 477, column: 64, scope: !51)
!101 = !DILocation(line: 477, column: 50, scope: !51)
!102 = !DILocation(line: 477, column: 129, scope: !51)
!103 = !DILocation(line: 477, column: 134, scope: !51)
!104 = !DILocation(line: 477, column: 120, scope: !51)
!105 = !DILocation(line: 477, column: 118, scope: !51)
!106 = !DILocation(line: 477, column: 112, scope: !51)
!107 = !DILocation(line: 477, column: 36, scope: !51)
!108 = !DILocation(line: 479, column: 24, scope: !51)
!109 = !DILocation(line: 481, column: 21, scope: !51)
!110 = !DILocation(line: 481, column: 19, scope: !51)
!111 = !DILocation(line: 482, column: 21, scope: !51)
!112 = !DILocation(line: 482, column: 19, scope: !51)
!113 = !DILocation(line: 483, column: 21, scope: !51)
!114 = !DILocation(line: 483, column: 19, scope: !51)
!115 = !DILocation(line: 484, column: 20, scope: !51)
!116 = !DILocation(line: 484, column: 18, scope: !51)
!117 = !DILocation(line: 485, column: 20, scope: !51)
!118 = !DILocation(line: 485, column: 18, scope: !51)
!119 = !DILocation(line: 486, column: 22, scope: !51)
!120 = !DILocation(line: 486, column: 20, scope: !51)
!121 = !DILocation(line: 487, column: 27, scope: !51)
!122 = !DILocation(line: 487, column: 25, scope: !51)
!123 = !DILocation(line: 488, column: 25, scope: !51)
!124 = !DILocation(line: 488, column: 23, scope: !51)
!125 = !DILocation(line: 489, column: 31, scope: !51)
!126 = !DILocation(line: 489, column: 29, scope: !51)
!127 = !DILocation(line: 490, column: 28, scope: !51)
!128 = !DILocation(line: 490, column: 26, scope: !51)
!129 = !DILocation(line: 491, column: 28, scope: !51)
!130 = !DILocation(line: 491, column: 26, scope: !51)
!131 = !DILocation(line: 492, column: 37, scope: !51)
!132 = !DILocation(line: 492, column: 35, scope: !51)
!133 = !DILocation(line: 493, column: 37, scope: !51)
!134 = !DILocation(line: 493, column: 35, scope: !51)
!135 = !DILocation(line: 495, column: 5, scope: !51)
!136 = !DILocation(line: 501, column: 5, scope: !51)
!137 = !DILocation(line: 506, column: 5, scope: !51)
!138 = !DILocation(line: 521, column: 5, scope: !51)
!139 = !DILocation(line: 522, column: 16, scope: !51)
!140 = !DILocation(line: 531, column: 5, scope: !51)
!141 = !DILocation(line: 460, column: 1, scope: !51)
!142 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_memcpyd2h", linkageName: "sys_mod.sys_mod.f_memcpyd2h", scope: null, file: !32, line: 556, type: !5, scopeLine: 556, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!143 = !DILocation(line: 568, column: 5, scope: !144)
!144 = !DILexicalBlockFile(scope: !142, file: !32, discriminator: 0)
!145 = !DILocation(line: 567, column: 5, scope: !144)
!146 = !DILocation(line: 566, column: 5, scope: !144)
!147 = !DILocation(line: 565, column: 5, scope: !144)
!148 = !DILocation(line: 564, column: 5, scope: !144)
!149 = !DILocation(line: 563, column: 5, scope: !144)
!150 = !DILocation(line: 562, column: 5, scope: !144)
!151 = !DILocation(line: 561, column: 5, scope: !144)
!152 = !DILocation(line: 559, column: 5, scope: !144)
!153 = !DILocation(line: 558, column: 20, scope: !144)
!154 = !DILocation(line: 558, column: 32, scope: !144)
!155 = !DILocation(line: 558, column: 5, scope: !144)
!156 = !DILocation(line: 561, column: 33, scope: !144)
!157 = !DILocation(line: 561, column: 38, scope: !144)
!158 = !DILocation(line: 562, column: 34, scope: !144)
!159 = !DILocation(line: 562, column: 39, scope: !144)
!160 = !DILocation(line: 563, column: 34, scope: !144)
!161 = !DILocation(line: 563, column: 39, scope: !144)
!162 = !DILocation(line: 564, column: 33, scope: !144)
!163 = !DILocation(line: 564, column: 38, scope: !144)
!164 = !DILocation(line: 565, column: 33, scope: !144)
!165 = !DILocation(line: 565, column: 38, scope: !144)
!166 = !DILocation(line: 566, column: 35, scope: !144)
!167 = !DILocation(line: 566, column: 21, scope: !144)
!168 = !DILocation(line: 567, column: 41, scope: !144)
!169 = !DILocation(line: 567, column: 27, scope: !144)
!170 = !DILocation(line: 568, column: 39, scope: !144)
!171 = !DILocation(line: 568, column: 25, scope: !144)
!172 = !DILocation(line: 570, column: 24, scope: !144)
!173 = !DILocation(line: 573, column: 21, scope: !144)
!174 = !DILocation(line: 573, column: 19, scope: !144)
!175 = !DILocation(line: 574, column: 21, scope: !144)
!176 = !DILocation(line: 574, column: 19, scope: !144)
!177 = !DILocation(line: 575, column: 21, scope: !144)
!178 = !DILocation(line: 575, column: 19, scope: !144)
!179 = !DILocation(line: 576, column: 20, scope: !144)
!180 = !DILocation(line: 576, column: 18, scope: !144)
!181 = !DILocation(line: 577, column: 20, scope: !144)
!182 = !DILocation(line: 577, column: 18, scope: !144)
!183 = !DILocation(line: 578, column: 22, scope: !144)
!184 = !DILocation(line: 578, column: 20, scope: !144)
!185 = !DILocation(line: 579, column: 27, scope: !144)
!186 = !DILocation(line: 579, column: 25, scope: !144)
!187 = !DILocation(line: 580, column: 25, scope: !144)
!188 = !DILocation(line: 580, column: 23, scope: !144)
!189 = !DILocation(line: 582, column: 5, scope: !144)
!190 = !DILocation(line: 588, column: 59, scope: !144)
!191 = !DILocation(line: 588, column: 5, scope: !144)
!192 = !DILocation(line: 608, column: 5, scope: !144)
!193 = !DILocation(line: 609, column: 16, scope: !144)
!194 = !DILocation(line: 556, column: 1, scope: !144)
!195 = distinct !DISubprogram(name: "sys_mod.sys_mod.oq0_teardow_handler", linkageName: "sys_mod.sys_mod.oq0_teardow_handler", scope: null, file: !32, line: 631, type: !5, scopeLine: 631, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!196 = !DILocation(line: 632, column: 9, scope: !197)
!197 = !DILexicalBlockFile(scope: !195, file: !32, discriminator: 0)
!198 = !DILocation(line: 632, column: 5, scope: !197)
!199 = !DILocation(line: 634, column: 66, scope: !197)
!200 = !DILocation(line: 634, column: 9, scope: !197)
!201 = !DILocation(line: 636, column: 13, scope: !197)
!202 = !DILocation(line: 637, column: 13, scope: !197)
!203 = !DILocation(line: 638, column: 13, scope: !197)
!204 = !DILocation(line: 639, column: 13, scope: !197)
!205 = !DILocation(line: 640, column: 13, scope: !197)
!206 = !DILocation(line: 641, column: 13, scope: !197)
!207 = !DILocation(line: 642, column: 13, scope: !197)
!208 = !DILocation(line: 643, column: 13, scope: !197)
!209 = !DILocation(line: 644, column: 13, scope: !197)
!210 = !DILocation(line: 645, column: 13, scope: !197)
!211 = !DILocation(line: 646, column: 13, scope: !197)
!212 = !DILocation(line: 647, column: 13, scope: !197)
!213 = !DILocation(line: 648, column: 13, scope: !197)
!214 = !DILocation(line: 635, column: 9, scope: !197)
!215 = !DILocation(line: 652, column: 9, scope: !197)
!216 = !DILocation(line: 654, column: 13, scope: !197)
!217 = !DILocation(line: 655, column: 13, scope: !197)
!218 = !DILocation(line: 656, column: 13, scope: !197)
!219 = !DILocation(line: 657, column: 13, scope: !197)
!220 = !DILocation(line: 658, column: 13, scope: !197)
!221 = !DILocation(line: 659, column: 13, scope: !197)
!222 = !DILocation(line: 660, column: 13, scope: !197)
!223 = !DILocation(line: 661, column: 13, scope: !197)
!224 = !DILocation(line: 653, column: 9, scope: !197)
!225 = !DILocation(line: 664, column: 5, scope: !197)
!226 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_rpc", linkageName: "sys_mod.sys_mod.f_rpc", scope: null, file: !32, line: 694, type: !5, scopeLine: 694, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!227 = !DILocation(line: 694, column: 13, scope: !228)
!228 = !DILexicalBlockFile(scope: !226, file: !32, discriminator: 0)
!229 = !DILocation(line: 700, column: 5, scope: !228)
!230 = !DILocation(line: 706, column: 20, scope: !228)
!231 = !DILocation(line: 706, column: 32, scope: !228)
!232 = !DILocation(line: 706, column: 5, scope: !228)
!233 = !DILocation(line: 710, column: 5, scope: !228)
!234 = !DILocation(line: 712, column: 24, scope: !228)
!235 = !DILocation(line: 694, column: 1, scope: !228)
!236 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.stack_push", linkageName: "sys_mod.sys_mod.sys_mod.stack_push", scope: null, file: !237, line: 54, type: !5, scopeLine: 54, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!237 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/sys.csl", directory: "")
!238 = !DILocation(line: 60, column: 5, scope: !239)
!239 = !DILexicalBlockFile(scope: !236, file: !237, discriminator: 0)
!240 = !DILocation(line: 54, column: 16, scope: !239)
!241 = !DILocation(line: 59, column: 13, scope: !239)
!242 = !DILocation(line: 59, column: 24, scope: !239)
!243 = !DILocation(line: 59, column: 5, scope: !239)
!244 = !DILocation(line: 61, column: 25, scope: !239)
!245 = !DILocation(line: 61, column: 5, scope: !239)
!246 = !DILocation(line: 61, column: 11, scope: !239)
!247 = !DILocation(line: 61, column: 10, scope: !239)
!248 = !DILocation(line: 61, column: 23, scope: !239)
!249 = !DILocation(line: 62, column: 18, scope: !239)
!250 = !DILocation(line: 62, column: 29, scope: !239)
!251 = !DILocation(line: 62, column: 16, scope: !239)
!252 = !DILocation(line: 54, column: 1, scope: !239)
!253 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_push", linkageName: "sys_mod.sys_mod.sys_mod.f_push", scope: null, file: !237, line: 72, type: !5, scopeLine: 72, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!254 = !DILocation(line: 72, column: 25, scope: !255)
!255 = !DILexicalBlockFile(scope: !253, file: !237, discriminator: 0)
!256 = !DILocation(line: 72, column: 13, scope: !255)
!257 = !DILocation(line: 73, column: 16, scope: !255)
!258 = !DILocation(line: 73, column: 5, scope: !255)
!259 = !DILocation(line: 72, column: 1, scope: !255)
!260 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.block_cmd_stream", linkageName: "sys_mod.sys_mod.sys_mod.block_cmd_stream", scope: null, file: !237, line: 76, type: !5, scopeLine: 76, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!261 = !DILocation(line: 77, column: 5, scope: !262)
!262 = !DILexicalBlockFile(scope: !260, file: !237, discriminator: 0)
!263 = !DILocation(line: 76, column: 1, scope: !262)
!264 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.sys_mod.unblock_cmd_stream", scope: null, file: !237, line: 80, type: !5, scopeLine: 80, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!265 = !DILocation(line: 81, column: 5, scope: !266)
!266 = !DILexicalBlockFile(scope: !264, file: !237, discriminator: 0)
!267 = !DILocation(line: 80, column: 1, scope: !266)
!268 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_sys_exit", linkageName: "sys_mod.sys_mod.sys_mod.f_sys_exit", scope: null, file: !237, line: 85, type: !5, scopeLine: 85, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!269 = !DILocation(line: 86, column: 5, scope: !270)
!270 = !DILexicalBlockFile(scope: !268, file: !237, discriminator: 0)
!271 = !DILocation(line: 87, column: 5, scope: !270)
!272 = !DILocation(line: 85, column: 1, scope: !270)
!273 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore", linkageName: "sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore", scope: null, file: !237, line: 90, type: !5, scopeLine: 90, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!274 = !DILocation(line: 90, column: 30, scope: !275)
!275 = !DILexicalBlockFile(scope: !273, file: !237, discriminator: 0)
!276 = !DILocation(line: 90, column: 1, scope: !275)
!277 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord", scope: null, file: !278, line: 131, type: !5, scopeLine: 131, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!278 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpyh2d.csl", directory: "")
!279 = !DILocation(line: 132, column: 12, scope: !280)
!280 = !DILexicalBlockFile(scope: !277, file: !278, discriminator: 0)
!281 = !DILocation(line: 132, column: 5, scope: !280)
!282 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord", scope: null, file: !278, line: 134, type: !5, scopeLine: 134, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!283 = !DILocation(line: 135, column: 12, scope: !284)
!284 = !DILexicalBlockFile(scope: !282, file: !278, discriminator: 0)
!285 = !DILocation(line: 135, column: 5, scope: !284)
!286 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval", scope: null, file: !278, line: 148, type: !5, scopeLine: 148, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!287 = !DILocation(line: 148, column: 23, scope: !288)
!288 = !DILexicalBlockFile(scope: !286, file: !278, discriminator: 0)
!289 = !DILocation(line: 149, column: 9, scope: !288)
!290 = !DILocation(line: 149, column: 20, scope: !288)
!291 = !DILocation(line: 149, column: 5, scope: !288)
!292 = !DILocation(line: 152, column: 23, scope: !288)
!293 = !DILocation(line: 152, column: 20, scope: !288)
!294 = !DILocation(line: 152, column: 9, scope: !288)
!295 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start", scope: null, file: !278, line: 226, type: !5, scopeLine: 226, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!296 = !DILocation(line: 233, column: 5, scope: !297)
!297 = !DILexicalBlockFile(scope: !295, file: !278, discriminator: 0)
!298 = !DILocation(line: 226, column: 49, scope: !297)
!299 = !DILocation(line: 226, column: 32, scope: !297)
!300 = !DILocation(line: 226, column: 21, scope: !297)
!301 = !DILocation(line: 229, column: 37, scope: !297)
!302 = !DILocation(line: 229, column: 52, scope: !297)
!303 = !DILocation(line: 229, column: 19, scope: !297)
!304 = !DILocation(line: 233, column: 71, scope: !297)
!305 = !DILocation(line: 233, column: 55, scope: !297)
!306 = !DILocation(line: 233, column: 25, scope: !297)
!307 = !DILocation(line: 235, column: 37, scope: !297)
!308 = !DILocation(line: 235, column: 52, scope: !297)
!309 = !DILocation(line: 235, column: 19, scope: !297)
!310 = !DILocation(line: 236, column: 28, scope: !297)
!311 = !DILocation(line: 236, column: 5, scope: !297)
!312 = !DILocation(line: 237, column: 28, scope: !297)
!313 = !DILocation(line: 237, column: 5, scope: !297)
!314 = !DILocation(line: 238, column: 13, scope: !297)
!315 = !DILocation(line: 238, column: 11, scope: !297)
!316 = !DILocation(line: 238, column: 5, scope: !297)
!317 = !DILocation(line: 239, column: 9, scope: !297)
!318 = !DILocation(line: 241, column: 9, scope: !297)
!319 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream", scope: null, file: !278, line: 249, type: !5, scopeLine: 249, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!320 = !DILocation(line: 250, column: 5, scope: !321)
!321 = !DILexicalBlockFile(scope: !319, file: !278, discriminator: 0)
!322 = !DILocation(line: 249, column: 1, scope: !321)
!323 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure", scope: null, file: !278, line: 276, type: !5, scopeLine: 276, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!324 = !DILocation(line: 414, column: 13, scope: !325)
!325 = !DILexicalBlockFile(scope: !323, file: !278, discriminator: 0)
!326 = !DILocation(line: 413, column: 13, scope: !325)
!327 = !DILocation(line: 400, column: 17, scope: !325)
!328 = !DILocation(line: 340, column: 9, scope: !325)
!329 = !DILocation(line: 339, column: 9, scope: !325)
!330 = !DILocation(line: 337, column: 5, scope: !325)
!331 = !DILocation(line: 319, column: 9, scope: !325)
!332 = !DILocation(line: 318, column: 9, scope: !325)
!333 = !DILocation(line: 315, column: 5, scope: !325)
!334 = !DILocation(line: 292, column: 5, scope: !325)
!335 = !DILocation(line: 291, column: 5, scope: !325)
!336 = !DILocation(line: 289, column: 5, scope: !325)
!337 = !DILocation(line: 288, column: 5, scope: !325)
!338 = !DILocation(line: 287, column: 5, scope: !325)
!339 = !DILocation(line: 286, column: 5, scope: !325)
!340 = !DILocation(line: 285, column: 5, scope: !325)
!341 = !DILocation(line: 284, column: 5, scope: !325)
!342 = !DILocation(line: 283, column: 5, scope: !325)
!343 = !DILocation(line: 282, column: 5, scope: !325)
!344 = !DILocation(line: 281, column: 5, scope: !325)
!345 = !DILocation(line: 280, column: 5, scope: !325)
!346 = !DILocation(line: 279, column: 5, scope: !325)
!347 = !DILocation(line: 278, column: 5, scope: !325)
!348 = !DILocation(line: 277, column: 5, scope: !325)
!349 = !DILocation(line: 291, column: 26, scope: !325)
!350 = !DILocation(line: 292, column: 26, scope: !325)
!351 = !DILocation(line: 315, column: 25, scope: !325)
!352 = !DILocation(line: 315, column: 31, scope: !325)
!353 = !DILocation(line: 315, column: 29, scope: !325)
!354 = !DILocation(line: 316, column: 20, scope: !325)
!355 = !DILocation(line: 316, column: 18, scope: !325)
!356 = !DILocation(line: 317, column: 52, scope: !325)
!357 = !DILocation(line: 317, column: 49, scope: !325)
!358 = !DILocation(line: 317, column: 5, scope: !325)
!359 = !DILocation(line: 318, column: 42, scope: !325)
!360 = !DILocation(line: 318, column: 33, scope: !325)
!361 = !DILocation(line: 318, column: 49, scope: !325)
!362 = !DILocation(line: 318, column: 48, scope: !325)
!363 = !DILocation(line: 318, column: 24, scope: !325)
!364 = !DILocation(line: 319, column: 24, scope: !325)
!365 = !DILocation(line: 319, column: 32, scope: !325)
!366 = !DILocation(line: 319, column: 36, scope: !325)
!367 = !DILocation(line: 319, column: 34, scope: !325)
!368 = !DILocation(line: 319, column: 30, scope: !325)
!369 = !DILocation(line: 320, column: 18, scope: !325)
!370 = !DILocation(line: 320, column: 15, scope: !325)
!371 = !DILocation(line: 320, column: 9, scope: !325)
!372 = !DILocation(line: 321, column: 26, scope: !325)
!373 = !DILocation(line: 325, column: 28, scope: !325)
!374 = !DILocation(line: 325, column: 26, scope: !325)
!375 = !DILocation(line: 331, column: 9, scope: !325)
!376 = !DILocation(line: 331, column: 15, scope: !325)
!377 = !DILocation(line: 331, column: 5, scope: !325)
!378 = !DILocation(line: 332, column: 22, scope: !325)
!379 = !DILocation(line: 334, column: 9, scope: !325)
!380 = !DILocation(line: 334, column: 18, scope: !325)
!381 = !DILocation(line: 334, column: 15, scope: !325)
!382 = !DILocation(line: 334, column: 5, scope: !325)
!383 = !DILocation(line: 335, column: 22, scope: !325)
!384 = !DILocation(line: 338, column: 52, scope: !325)
!385 = !DILocation(line: 338, column: 49, scope: !325)
!386 = !DILocation(line: 338, column: 5, scope: !325)
!387 = !DILocation(line: 339, column: 42, scope: !325)
!388 = !DILocation(line: 339, column: 48, scope: !325)
!389 = !DILocation(line: 339, column: 46, scope: !325)
!390 = !DILocation(line: 339, column: 33, scope: !325)
!391 = !DILocation(line: 339, column: 52, scope: !325)
!392 = !DILocation(line: 339, column: 51, scope: !325)
!393 = !DILocation(line: 339, column: 24, scope: !325)
!394 = !DILocation(line: 340, column: 25, scope: !325)
!395 = !DILocation(line: 340, column: 31, scope: !325)
!396 = !DILocation(line: 340, column: 29, scope: !325)
!397 = !DILocation(line: 340, column: 37, scope: !325)
!398 = !DILocation(line: 340, column: 41, scope: !325)
!399 = !DILocation(line: 340, column: 39, scope: !325)
!400 = !DILocation(line: 340, column: 35, scope: !325)
!401 = !DILocation(line: 341, column: 18, scope: !325)
!402 = !DILocation(line: 341, column: 15, scope: !325)
!403 = !DILocation(line: 341, column: 9, scope: !325)
!404 = !DILocation(line: 342, column: 26, scope: !325)
!405 = !DILocation(line: 347, column: 10, scope: !325)
!406 = !DILocation(line: 347, column: 16, scope: !325)
!407 = !DILocation(line: 347, column: 14, scope: !325)
!408 = !DILocation(line: 347, column: 5, scope: !325)
!409 = !DILocation(line: 348, column: 22, scope: !325)
!410 = !DILocation(line: 350, column: 10, scope: !325)
!411 = !DILocation(line: 350, column: 18, scope: !325)
!412 = !DILocation(line: 350, column: 21, scope: !325)
!413 = !DILocation(line: 350, column: 20, scope: !325)
!414 = !DILocation(line: 350, column: 14, scope: !325)
!415 = !DILocation(line: 350, column: 5, scope: !325)
!416 = !DILocation(line: 351, column: 22, scope: !325)
!417 = !DILocation(line: 354, column: 9, scope: !325)
!418 = !DILocation(line: 354, column: 5, scope: !325)
!419 = !DILocation(line: 358, column: 9, scope: !325)
!420 = !DILocation(line: 361, column: 9, scope: !325)
!421 = !DILocation(line: 364, column: 20, scope: !325)
!422 = !DILocation(line: 364, column: 17, scope: !325)
!423 = !DILocation(line: 364, column: 9, scope: !325)
!424 = !DILocation(line: 368, column: 13, scope: !325)
!425 = !DILocation(line: 371, column: 13, scope: !325)
!426 = !DILocation(line: 375, column: 13, scope: !325)
!427 = !DILocation(line: 394, column: 13, scope: !325)
!428 = !DILocation(line: 396, column: 29, scope: !325)
!429 = !DILocation(line: 396, column: 27, scope: !325)
!430 = !DILocation(line: 397, column: 60, scope: !325)
!431 = !DILocation(line: 397, column: 57, scope: !325)
!432 = !DILocation(line: 397, column: 13, scope: !325)
!433 = !DILocation(line: 400, column: 54, scope: !325)
!434 = !DILocation(line: 400, column: 55, scope: !325)
!435 = !DILocation(line: 400, column: 46, scope: !325)
!436 = !DILocation(line: 400, column: 59, scope: !325)
!437 = !DILocation(line: 400, column: 58, scope: !325)
!438 = !DILocation(line: 400, column: 37, scope: !325)
!439 = !DILocation(line: 400, column: 35, scope: !325)
!440 = !DILocation(line: 401, column: 33, scope: !325)
!441 = !DILocation(line: 401, column: 31, scope: !325)
!442 = !DILocation(line: 402, column: 69, scope: !325)
!443 = !DILocation(line: 402, column: 66, scope: !325)
!444 = !DILocation(line: 402, column: 19, scope: !325)
!445 = !DILocation(line: 404, column: 31, scope: !325)
!446 = !DILocation(line: 408, column: 75, scope: !325)
!447 = !DILocation(line: 408, column: 88, scope: !325)
!448 = !DILocation(line: 408, column: 13, scope: !325)
!449 = !DILocation(line: 413, column: 31, scope: !325)
!450 = !DILocation(line: 414, column: 33, scope: !325)
!451 = !DILocation(line: 415, column: 21, scope: !325)
!452 = !DILocation(line: 415, column: 29, scope: !325)
!453 = !DILocation(line: 415, column: 27, scope: !325)
!454 = !DILocation(line: 415, column: 19, scope: !325)
!455 = !DILocation(line: 416, column: 22, scope: !325)
!456 = !DILocation(line: 416, column: 19, scope: !325)
!457 = !DILocation(line: 416, column: 13, scope: !325)
!458 = !DILocation(line: 417, column: 23, scope: !325)
!459 = !DILocation(line: 419, column: 63, scope: !325)
!460 = !DILocation(line: 419, column: 60, scope: !325)
!461 = !DILocation(line: 419, column: 13, scope: !325)
!462 = !DILocation(line: 421, column: 23, scope: !325)
!463 = !DILocation(line: 423, column: 69, scope: !325)
!464 = !DILocation(line: 423, column: 13, scope: !325)
!465 = !DILocation(line: 426, column: 13, scope: !325)
!466 = !DILocation(line: 430, column: 13, scope: !325)
!467 = !DILocation(line: 433, column: 48, scope: !325)
!468 = !DILocation(line: 433, column: 22, scope: !325)
!469 = !DILocation(line: 433, column: 19, scope: !325)
!470 = !DILocation(line: 433, column: 13, scope: !325)
!471 = !DILocation(line: 436, column: 34, scope: !325)
!472 = !DILocation(line: 436, column: 39, scope: !325)
!473 = !DILocation(line: 436, column: 50, scope: !325)
!474 = !DILocation(line: 436, column: 17, scope: !325)
!475 = !DILocation(line: 452, column: 49, scope: !325)
!476 = !DILocation(line: 452, column: 64, scope: !325)
!477 = !DILocation(line: 452, column: 31, scope: !325)
!478 = !DILocation(line: 453, column: 40, scope: !325)
!479 = !DILocation(line: 453, column: 17, scope: !325)
!480 = !DILocation(line: 454, column: 50, scope: !325)
!481 = !DILocation(line: 454, column: 66, scope: !325)
!482 = !DILocation(line: 454, column: 32, scope: !325)
!483 = !DILocation(line: 455, column: 40, scope: !325)
!484 = !DILocation(line: 455, column: 17, scope: !325)
!485 = !DILocation(line: 456, column: 17, scope: !325)
!486 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit", scope: null, file: !487, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!487 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/filters/wse3.csl", directory: "")
!488 = !DILocation(line: 24, column: 3, scope: !489)
!489 = !DILexicalBlockFile(scope: !486, file: !487, discriminator: 0)
!490 = !DILocation(line: 24, column: 22, scope: !489)
!491 = !DILocation(line: 23, column: 3, scope: !489)
!492 = !DILocation(line: 22, column: 3, scope: !489)
!493 = !DILocation(line: 20, column: 37, scope: !489)
!494 = !DILocation(line: 20, column: 21, scope: !489)
!495 = !DILocation(line: 21, column: 11, scope: !489)
!496 = !DILocation(line: 21, column: 17, scope: !489)
!497 = !DILocation(line: 21, column: 3, scope: !489)
!498 = !DILocation(line: 22, column: 24, scope: !489)
!499 = !DILocation(line: 22, column: 30, scope: !489)
!500 = !DILocation(line: 23, column: 40, scope: !489)
!501 = !DILocation(line: 23, column: 22, scope: !489)
!502 = !DILocation(line: 23, column: 67, scope: !489)
!503 = !DILocation(line: 24, column: 26, scope: !489)
!504 = !DILocation(line: 24, column: 41, scope: !489)
!505 = !DILocation(line: 24, column: 39, scope: !489)
!506 = !DILocation(line: 24, column: 61, scope: !489)
!507 = !DILocation(line: 24, column: 76, scope: !489)
!508 = !DILocation(line: 24, column: 74, scope: !489)
!509 = !DILocation(line: 25, column: 21, scope: !489)
!510 = !DILocation(line: 25, column: 50, scope: !489)
!511 = !DILocation(line: 25, column: 3, scope: !489)
!512 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter", scope: null, file: !487, line: 30, type: !5, scopeLine: 30, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!513 = !DILocation(line: 30, column: 36, scope: !514)
!514 = !DILexicalBlockFile(scope: !512, file: !487, discriminator: 0)
!515 = !DILocation(line: 30, column: 20, scope: !514)
!516 = !DILocation(line: 31, column: 11, scope: !514)
!517 = !DILocation(line: 31, column: 23, scope: !514)
!518 = !DILocation(line: 31, column: 3, scope: !514)
!519 = !DILocation(line: 32, column: 21, scope: !514)
!520 = !DILocation(line: 32, column: 48, scope: !514)
!521 = !DILocation(line: 32, column: 60, scope: !514)
!522 = !DILocation(line: 32, column: 64, scope: !514)
!523 = !DILocation(line: 32, column: 3, scope: !514)
!524 = !DILocation(line: 30, column: 1, scope: !514)
!525 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter", scope: null, file: !487, line: 40, type: !5, scopeLine: 40, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!526 = !DILocation(line: 47, column: 3, scope: !527)
!527 = !DILexicalBlockFile(scope: !525, file: !487, discriminator: 0)
!528 = !DILocation(line: 48, column: 7, scope: !527)
!529 = !DILocation(line: 44, column: 3, scope: !527)
!530 = !DILocation(line: 43, column: 3, scope: !527)
!531 = !DILocation(line: 42, column: 3, scope: !527)
!532 = !DILocation(line: 40, column: 32, scope: !527)
!533 = !DILocation(line: 40, column: 16, scope: !527)
!534 = !DILocation(line: 41, column: 11, scope: !527)
!535 = !DILocation(line: 41, column: 19, scope: !527)
!536 = !DILocation(line: 41, column: 3, scope: !527)
!537 = !DILocation(line: 42, column: 40, scope: !527)
!538 = !DILocation(line: 42, column: 22, scope: !527)
!539 = !DILocation(line: 43, column: 26, scope: !527)
!540 = !DILocation(line: 43, column: 34, scope: !527)
!541 = !DILocation(line: 44, column: 25, scope: !527)
!542 = !DILocation(line: 44, column: 42, scope: !527)
!543 = !DILocation(line: 44, column: 40, scope: !527)
!544 = !DILocation(line: 45, column: 21, scope: !527)
!545 = !DILocation(line: 46, column: 35, scope: !527)
!546 = !DILocation(line: 46, column: 21, scope: !527)
!547 = !DILocation(line: 46, column: 50, scope: !527)
!548 = !DILocation(line: 45, column: 3, scope: !527)
!549 = !DILocation(line: 48, column: 11, scope: !527)
!550 = !DILocation(line: 48, column: 26, scope: !527)
!551 = !DILocation(line: 48, column: 43, scope: !527)
!552 = !DILocation(line: 48, column: 41, scope: !527)
!553 = !DILocation(line: 48, column: 54, scope: !527)
!554 = !DILocation(line: 48, column: 63, scope: !527)
!555 = !DILocation(line: 49, column: 21, scope: !527)
!556 = !DILocation(line: 49, column: 47, scope: !527)
!557 = !DILocation(line: 49, column: 3, scope: !527)
!558 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config", scope: null, file: !559, line: 33, type: !5, scopeLine: 33, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!559 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/filters/common.csl", directory: "")
!560 = !DILocation(line: 33, column: 46, scope: !561)
!561 = !DILexicalBlockFile(scope: !558, file: !559, discriminator: 0)
!562 = !DILocation(line: 33, column: 31, scope: !561)
!563 = !DILocation(line: 33, column: 15, scope: !561)
!564 = !DILocation(line: 34, column: 24, scope: !561)
!565 = !DILocation(line: 34, column: 23, scope: !561)
!566 = !DILocation(line: 34, column: 51, scope: !561)
!567 = !DILocation(line: 34, column: 35, scope: !561)
!568 = !DILocation(line: 34, column: 60, scope: !561)
!569 = !DILocation(line: 34, column: 73, scope: !561)
!570 = !DILocation(line: 34, column: 3, scope: !561)
!571 = !DILocation(line: 33, column: 1, scope: !561)
!572 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config", scope: null, file: !559, line: 38, type: !5, scopeLine: 38, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!573 = !DILocation(line: 38, column: 31, scope: !574)
!574 = !DILexicalBlockFile(scope: !572, file: !559, discriminator: 0)
!575 = !DILocation(line: 38, column: 15, scope: !574)
!576 = !DILocation(line: 39, column: 31, scope: !574)
!577 = !DILocation(line: 39, column: 30, scope: !574)
!578 = !DILocation(line: 39, column: 58, scope: !574)
!579 = !DILocation(line: 39, column: 42, scope: !574)
!580 = !DILocation(line: 39, column: 67, scope: !574)
!581 = !DILocation(line: 39, column: 10, scope: !574)
!582 = !DILocation(line: 39, column: 3, scope: !574)
!583 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit", scope: null, file: !584, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!584 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/teardown.csl", directory: "")
!585 = !DILocation(line: 43, column: 3, scope: !586)
!586 = !DILexicalBlockFile(scope: !583, file: !584, discriminator: 0)
!587 = !DILocation(line: 41, column: 3, scope: !586)
!588 = !DILocation(line: 40, column: 3, scope: !586)
!589 = !DILocation(line: 39, column: 9, scope: !586)
!590 = !DILocation(line: 40, column: 23, scope: !586)
!591 = !DILocation(line: 41, column: 70, scope: !586)
!592 = !DILocation(line: 41, column: 68, scope: !586)
!593 = !DILocation(line: 43, column: 27, scope: !586)
!594 = !DILocation(line: 43, column: 15, scope: !586)
!595 = !DILocation(line: 44, column: 15, scope: !586)
!596 = !DILocation(line: 44, column: 21, scope: !586)
!597 = !DILocation(line: 44, column: 27, scope: !586)
!598 = !DILocation(line: 44, column: 3, scope: !586)
!599 = !DILocation(line: 39, column: 1, scope: !586)
!600 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord", scope: null, file: !601, line: 4, type: !5, scopeLine: 4, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!601 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/layout.csl", directory: "")
!602 = !DILocation(line: 5, column: 10, scope: !603)
!603 = !DILexicalBlockFile(scope: !600, file: !601, discriminator: 0)
!604 = !DILocation(line: 5, column: 67, scope: !603)
!605 = !DILocation(line: 5, column: 3, scope: !603)
!606 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord", scope: null, file: !601, line: 8, type: !5, scopeLine: 8, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!607 = !DILocation(line: 9, column: 10, scope: !608)
!608 = !DILexicalBlockFile(scope: !606, file: !601, discriminator: 0)
!609 = !DILocation(line: 9, column: 67, scope: !608)
!610 = !DILocation(line: 9, column: 3, scope: !608)
!611 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord", scope: null, file: !612, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!612 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config.csl", directory: "")
!613 = !DILocation(line: 50, column: 3, scope: !614)
!614 = !DILexicalBlockFile(scope: !611, file: !612, discriminator: 0)
!615 = !DILocation(line: 43, column: 21, scope: !614)
!616 = !DILocation(line: 50, column: 57, scope: !614)
!617 = !DILocation(line: 50, column: 68, scope: !614)
!618 = !DILocation(line: 50, column: 41, scope: !614)
!619 = !DILocation(line: 50, column: 19, scope: !614)
!620 = !DILocation(line: 52, column: 10, scope: !614)
!621 = !DILocation(line: 52, column: 18, scope: !614)
!622 = !DILocation(line: 48, column: 22, scope: !614)
!623 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.get_x_coord", scope: null, file: !624, line: 171, type: !5, scopeLine: 171, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!624 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpyd2h.csl", directory: "")
!625 = !DILocation(line: 172, column: 12, scope: !626)
!626 = !DILexicalBlockFile(scope: !623, file: !624, discriminator: 0)
!627 = !DILocation(line: 172, column: 5, scope: !626)
!628 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.get_y_coord", scope: null, file: !624, line: 174, type: !5, scopeLine: 174, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!629 = !DILocation(line: 175, column: 12, scope: !630)
!630 = !DILexicalBlockFile(scope: !628, file: !624, discriminator: 0)
!631 = !DILocation(line: 175, column: 5, scope: !630)
!632 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval", scope: null, file: !624, line: 187, type: !5, scopeLine: 187, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!633 = !DILocation(line: 187, column: 23, scope: !634)
!634 = !DILexicalBlockFile(scope: !632, file: !624, discriminator: 0)
!635 = !DILocation(line: 188, column: 9, scope: !634)
!636 = !DILocation(line: 188, column: 20, scope: !634)
!637 = !DILocation(line: 188, column: 5, scope: !634)
!638 = !DILocation(line: 191, column: 23, scope: !634)
!639 = !DILocation(line: 191, column: 20, scope: !634)
!640 = !DILocation(line: 191, column: 9, scope: !634)
!641 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start", scope: null, file: !624, line: 383, type: !5, scopeLine: 383, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!642 = !DILocation(line: 386, column: 5, scope: !643)
!643 = !DILexicalBlockFile(scope: !641, file: !624, discriminator: 0)
!644 = !DILocation(line: 384, column: 72, scope: !643)
!645 = !DILocation(line: 384, column: 59, scope: !643)
!646 = !DILocation(line: 384, column: 46, scope: !643)
!647 = !DILocation(line: 384, column: 33, scope: !643)
!648 = !DILocation(line: 384, column: 19, scope: !643)
!649 = !DILocation(line: 384, column: 5, scope: !643)
!650 = !DILocation(line: 383, column: 32, scope: !643)
!651 = !DILocation(line: 383, column: 21, scope: !643)
!652 = !DILocation(line: 386, column: 26, scope: !643)
!653 = !DILocation(line: 388, column: 28, scope: !643)
!654 = !DILocation(line: 388, column: 17, scope: !643)
!655 = !DILocation(line: 389, column: 25, scope: !643)
!656 = !DILocation(line: 389, column: 23, scope: !643)
!657 = !DILocation(line: 391, column: 38, scope: !643)
!658 = !DILocation(line: 391, column: 20, scope: !643)
!659 = !DILocation(line: 391, column: 18, scope: !643)
!660 = !DILocation(line: 393, column: 7, scope: !643)
!661 = !DILocation(line: 395, column: 17, scope: !643)
!662 = !DILocation(line: 395, column: 15, scope: !643)
!663 = !DILocation(line: 397, column: 15, scope: !643)
!664 = !DILocation(line: 397, column: 13, scope: !643)
!665 = !DILocation(line: 398, column: 15, scope: !643)
!666 = !DILocation(line: 398, column: 25, scope: !643)
!667 = !DILocation(line: 398, column: 23, scope: !643)
!668 = !DILocation(line: 398, column: 31, scope: !643)
!669 = !DILocation(line: 398, column: 13, scope: !643)
!670 = !DILocation(line: 401, column: 10, scope: !643)
!671 = !DILocation(line: 401, column: 17, scope: !643)
!672 = !DILocation(line: 401, column: 14, scope: !643)
!673 = !DILocation(line: 401, column: 5, scope: !643)
!674 = !DILocation(line: 403, column: 48, scope: !643)
!675 = !DILocation(line: 403, column: 26, scope: !643)
!676 = !DILocation(line: 404, column: 26, scope: !643)
!677 = !DILocation(line: 404, column: 18, scope: !643)
!678 = !DILocation(line: 407, column: 48, scope: !643)
!679 = !DILocation(line: 407, column: 26, scope: !643)
!680 = !DILocation(line: 408, column: 27, scope: !643)
!681 = !DILocation(line: 408, column: 18, scope: !643)
!682 = !DILocation(line: 411, column: 14, scope: !643)
!683 = !DILocation(line: 414, column: 14, scope: !643)
!684 = !DILocation(line: 414, column: 11, scope: !643)
!685 = !DILocation(line: 414, column: 5, scope: !643)
!686 = !DILocation(line: 416, column: 44, scope: !643)
!687 = !DILocation(line: 416, column: 75, scope: !643)
!688 = !DILocation(line: 416, column: 59, scope: !643)
!689 = !DILocation(line: 416, column: 25, scope: !643)
!690 = !DILocation(line: 416, column: 23, scope: !643)
!691 = !DILocation(line: 418, column: 41, scope: !643)
!692 = !DILocation(line: 418, column: 23, scope: !643)
!693 = !DILocation(line: 419, column: 9, scope: !643)
!694 = !DILocation(line: 425, column: 44, scope: !643)
!695 = !DILocation(line: 425, column: 23, scope: !643)
!696 = !DILocation(line: 426, column: 41, scope: !643)
!697 = !DILocation(line: 426, column: 23, scope: !643)
!698 = !DILocation(line: 427, column: 9, scope: !643)
!699 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x", scope: null, file: !624, line: 448, type: !5, scopeLine: 448, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!700 = !DILocation(line: 448, column: 31, scope: !701)
!701 = !DILexicalBlockFile(scope: !699, file: !624, discriminator: 0)
!702 = !DILocation(line: 453, column: 5, scope: !701)
!703 = !DILocation(line: 456, column: 19, scope: !701)
!704 = !DILocation(line: 456, column: 17, scope: !701)
!705 = !DILocation(line: 461, column: 5, scope: !701)
!706 = !DILocation(line: 462, column: 28, scope: !701)
!707 = !DILocation(line: 462, column: 5, scope: !701)
!708 = !DILocation(line: 463, column: 5, scope: !701)
!709 = !DILocation(line: 464, column: 9, scope: !701)
!710 = !DILocation(line: 464, column: 10, scope: !701)
!711 = !DILocation(line: 464, column: 7, scope: !701)
!712 = !DILocation(line: 448, column: 1, scope: !701)
!713 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_send_data", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_send_data", scope: null, file: !624, line: 476, type: !5, scopeLine: 476, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!714 = !DILocation(line: 494, column: 9, scope: !715)
!715 = !DILexicalBlockFile(scope: !713, file: !624, discriminator: 0)
!716 = !DILocation(line: 478, column: 9, scope: !715)
!717 = !DILocation(line: 478, column: 13, scope: !715)
!718 = !DILocation(line: 478, column: 11, scope: !715)
!719 = !DILocation(line: 478, column: 5, scope: !715)
!720 = !DILocation(line: 479, column: 9, scope: !715)
!721 = !DILocation(line: 480, column: 32, scope: !715)
!722 = !DILocation(line: 480, column: 9, scope: !715)
!723 = !DILocation(line: 481, column: 17, scope: !715)
!724 = !DILocation(line: 481, column: 15, scope: !715)
!725 = !DILocation(line: 481, column: 9, scope: !715)
!726 = !DILocation(line: 482, column: 13, scope: !715)
!727 = !DILocation(line: 483, column: 51, scope: !715)
!728 = !DILocation(line: 483, column: 29, scope: !715)
!729 = !DILocation(line: 483, column: 27, scope: !715)
!730 = !DILocation(line: 485, column: 13, scope: !715)
!731 = !DILocation(line: 486, column: 51, scope: !715)
!732 = !DILocation(line: 486, column: 29, scope: !715)
!733 = !DILocation(line: 486, column: 27, scope: !715)
!734 = !DILocation(line: 488, column: 13, scope: !715)
!735 = !DILocation(line: 488, column: 14, scope: !715)
!736 = !DILocation(line: 488, column: 11, scope: !715)
!737 = !DILocation(line: 494, column: 30, scope: !715)
!738 = !DILocation(line: 496, column: 14, scope: !715)
!739 = !DILocation(line: 496, column: 25, scope: !715)
!740 = !DILocation(line: 496, column: 22, scope: !715)
!741 = !DILocation(line: 496, column: 9, scope: !715)
!742 = !DILocation(line: 497, column: 13, scope: !715)
!743 = !DILocation(line: 498, column: 13, scope: !715)
!744 = !DILocation(line: 499, column: 13, scope: !715)
!745 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl", scope: null, file: !624, line: 505, type: !5, scopeLine: 505, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!746 = !DILocation(line: 524, column: 13, scope: !747)
!747 = !DILexicalBlockFile(scope: !745, file: !624, discriminator: 0)
!748 = !DILocation(line: 506, column: 14, scope: !747)
!749 = !DILocation(line: 506, column: 11, scope: !747)
!750 = !DILocation(line: 506, column: 5, scope: !747)
!751 = !DILocation(line: 508, column: 9, scope: !747)
!752 = !DILocation(line: 509, column: 32, scope: !747)
!753 = !DILocation(line: 509, column: 9, scope: !747)
!754 = !DILocation(line: 510, column: 9, scope: !747)
!755 = !DILocation(line: 514, column: 13, scope: !747)
!756 = !DILocation(line: 514, column: 17, scope: !747)
!757 = !DILocation(line: 514, column: 15, scope: !747)
!758 = !DILocation(line: 514, column: 9, scope: !747)
!759 = !DILocation(line: 518, column: 13, scope: !747)
!760 = !DILocation(line: 519, column: 36, scope: !747)
!761 = !DILocation(line: 519, column: 13, scope: !747)
!762 = !DILocation(line: 520, column: 13, scope: !747)
!763 = !DILocation(line: 524, column: 34, scope: !747)
!764 = !DILocation(line: 526, column: 18, scope: !747)
!765 = !DILocation(line: 526, column: 29, scope: !747)
!766 = !DILocation(line: 526, column: 26, scope: !747)
!767 = !DILocation(line: 526, column: 13, scope: !747)
!768 = !DILocation(line: 529, column: 17, scope: !747)
!769 = !DILocation(line: 530, column: 17, scope: !747)
!770 = !DILocation(line: 531, column: 17, scope: !747)
!771 = !DILocation(line: 534, column: 17, scope: !747)
!772 = !DILocation(line: 535, column: 40, scope: !747)
!773 = !DILocation(line: 535, column: 17, scope: !747)
!774 = !DILocation(line: 536, column: 17, scope: !747)
!775 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.d2h_configure", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.d2h_configure", scope: null, file: !624, line: 593, type: !5, scopeLine: 593, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!776 = !DILocation(line: 617, column: 26, scope: !777)
!777 = !DILexicalBlockFile(scope: !775, file: !624, discriminator: 0)
!778 = !DILocation(line: 612, column: 47, scope: !777)
!779 = !DILocation(line: 612, column: 27, scope: !777)
!780 = !DILocation(line: 602, column: 5, scope: !777)
!781 = !DILocation(line: 601, column: 5, scope: !777)
!782 = !DILocation(line: 599, column: 5, scope: !777)
!783 = !DILocation(line: 598, column: 5, scope: !777)
!784 = !DILocation(line: 596, column: 5, scope: !777)
!785 = !DILocation(line: 595, column: 5, scope: !777)
!786 = !DILocation(line: 593, column: 86, scope: !777)
!787 = !DILocation(line: 593, column: 70, scope: !777)
!788 = !DILocation(line: 593, column: 60, scope: !777)
!789 = !DILocation(line: 593, column: 52, scope: !777)
!790 = !DILocation(line: 593, column: 44, scope: !777)
!791 = !DILocation(line: 593, column: 35, scope: !777)
!792 = !DILocation(line: 593, column: 26, scope: !777)
!793 = !DILocation(line: 593, column: 18, scope: !777)
!794 = !DILocation(line: 595, column: 26, scope: !777)
!795 = !DILocation(line: 596, column: 26, scope: !777)
!796 = !DILocation(line: 598, column: 23, scope: !777)
!797 = !DILocation(line: 599, column: 23, scope: !777)
!798 = !DILocation(line: 599, column: 28, scope: !777)
!799 = !DILocation(line: 599, column: 26, scope: !777)
!800 = !DILocation(line: 599, column: 29, scope: !777)
!801 = !DILocation(line: 601, column: 24, scope: !777)
!802 = !DILocation(line: 602, column: 24, scope: !777)
!803 = !DILocation(line: 602, column: 29, scope: !777)
!804 = !DILocation(line: 602, column: 27, scope: !777)
!805 = !DILocation(line: 602, column: 30, scope: !777)
!806 = !DILocation(line: 611, column: 20, scope: !777)
!807 = !DILocation(line: 612, column: 11, scope: !777)
!808 = !DILocation(line: 612, column: 18, scope: !777)
!809 = !DILocation(line: 612, column: 15, scope: !777)
!810 = !DILocation(line: 612, column: 32, scope: !777)
!811 = !DILocation(line: 612, column: 39, scope: !777)
!812 = !DILocation(line: 612, column: 36, scope: !777)
!813 = !DILocation(line: 612, column: 52, scope: !777)
!814 = !DILocation(line: 612, column: 59, scope: !777)
!815 = !DILocation(line: 612, column: 56, scope: !777)
!816 = !DILocation(line: 612, column: 5, scope: !777)
!817 = !DILocation(line: 613, column: 24, scope: !777)
!818 = !DILocation(line: 616, column: 15, scope: !777)
!819 = !DILocation(line: 617, column: 11, scope: !777)
!820 = !DILocation(line: 617, column: 18, scope: !777)
!821 = !DILocation(line: 617, column: 15, scope: !777)
!822 = !DILocation(line: 617, column: 30, scope: !777)
!823 = !DILocation(line: 617, column: 5, scope: !777)
!824 = !DILocation(line: 618, column: 19, scope: !777)
!825 = !DILocation(line: 621, column: 9, scope: !777)
!826 = !DILocation(line: 621, column: 5, scope: !777)
!827 = !DILocation(line: 627, column: 9, scope: !777)
!828 = !DILocation(line: 629, column: 13, scope: !777)
!829 = !DILocation(line: 629, column: 25, scope: !777)
!830 = !DILocation(line: 629, column: 21, scope: !777)
!831 = !DILocation(line: 629, column: 9, scope: !777)
!832 = !DILocation(line: 632, column: 13, scope: !777)
!833 = !DILocation(line: 636, column: 13, scope: !777)
!834 = !DILocation(line: 641, column: 9, scope: !777)
!835 = !DILocation(line: 646, column: 13, scope: !777)
!836 = !DILocation(line: 646, column: 9, scope: !777)
!837 = !DILocation(line: 647, column: 30, scope: !777)
!838 = !DILocation(line: 647, column: 35, scope: !777)
!839 = !DILocation(line: 647, column: 46, scope: !777)
!840 = !DILocation(line: 647, column: 50, scope: !777)
!841 = !DILocation(line: 647, column: 54, scope: !777)
!842 = !DILocation(line: 647, column: 57, scope: !777)
!843 = !DILocation(line: 647, column: 60, scope: !777)
!844 = !DILocation(line: 647, column: 63, scope: !777)
!845 = !DILocation(line: 647, column: 13, scope: !777)
!846 = !DILocation(line: 661, column: 9, scope: !777)
!847 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit", scope: null, file: !584, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!848 = !DILocation(line: 43, column: 3, scope: !849)
!849 = !DILexicalBlockFile(scope: !847, file: !584, discriminator: 0)
!850 = !DILocation(line: 41, column: 3, scope: !849)
!851 = !DILocation(line: 40, column: 3, scope: !849)
!852 = !DILocation(line: 39, column: 9, scope: !849)
!853 = !DILocation(line: 40, column: 23, scope: !849)
!854 = !DILocation(line: 41, column: 70, scope: !849)
!855 = !DILocation(line: 41, column: 68, scope: !849)
!856 = !DILocation(line: 43, column: 27, scope: !849)
!857 = !DILocation(line: 43, column: 15, scope: !849)
!858 = !DILocation(line: 44, column: 15, scope: !849)
!859 = !DILocation(line: 44, column: 21, scope: !849)
!860 = !DILocation(line: 44, column: 27, scope: !849)
!861 = !DILocation(line: 44, column: 3, scope: !849)
!862 = !DILocation(line: 39, column: 1, scope: !849)
!863 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord", scope: null, file: !601, line: 4, type: !5, scopeLine: 4, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!864 = !DILocation(line: 5, column: 10, scope: !865)
!865 = !DILexicalBlockFile(scope: !863, file: !601, discriminator: 0)
!866 = !DILocation(line: 5, column: 67, scope: !865)
!867 = !DILocation(line: 5, column: 3, scope: !865)
!868 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord", scope: null, file: !601, line: 8, type: !5, scopeLine: 8, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!869 = !DILocation(line: 9, column: 10, scope: !870)
!870 = !DILexicalBlockFile(scope: !868, file: !601, discriminator: 0)
!871 = !DILocation(line: 9, column: 67, scope: !870)
!872 = !DILocation(line: 9, column: 3, scope: !870)
!873 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord", scope: null, file: !612, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!874 = !DILocation(line: 50, column: 3, scope: !875)
!875 = !DILexicalBlockFile(scope: !873, file: !612, discriminator: 0)
!876 = !DILocation(line: 43, column: 21, scope: !875)
!877 = !DILocation(line: 50, column: 57, scope: !875)
!878 = !DILocation(line: 50, column: 68, scope: !875)
!879 = !DILocation(line: 50, column: 41, scope: !875)
!880 = !DILocation(line: 50, column: 19, scope: !875)
!881 = !DILocation(line: 52, column: 10, scope: !875)
!882 = !DILocation(line: 52, column: 18, scope: !875)
!883 = !DILocation(line: 48, column: 22, scope: !875)
!884 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr", linkageName: "sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr", scope: null, file: !885, line: 11, type: !5, scopeLine: 11, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!885 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/input_queue_config.csl", directory: "")
!886 = !DILocation(line: 11, column: 32, scope: !887)
!887 = !DILexicalBlockFile(scope: !884, file: !885, discriminator: 0)
!888 = !DILocation(line: 12, column: 80, scope: !887)
!889 = !DILocation(line: 12, column: 69, scope: !887)
!890 = !DILocation(line: 12, column: 39, scope: !887)
!891 = !DILocation(line: 12, column: 3, scope: !887)
!892 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue", linkageName: "sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue", scope: null, file: !885, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!893 = !DILocation(line: 46, column: 3, scope: !894)
!894 = !DILexicalBlockFile(scope: !892, file: !885, discriminator: 0)
!895 = !DILocation(line: 45, column: 3, scope: !894)
!896 = !DILocation(line: 39, column: 42, scope: !894)
!897 = !DILocation(line: 39, column: 34, scope: !894)
!898 = !DILocation(line: 39, column: 24, scope: !894)
!899 = !DILocation(line: 45, column: 44, scope: !894)
!900 = !DILocation(line: 45, column: 16, scope: !894)
!901 = !DILocation(line: 46, column: 30, scope: !894)
!902 = !DILocation(line: 46, column: 18, scope: !894)
!903 = !DILocation(line: 56, column: 9, scope: !894)
!904 = !DILocation(line: 56, column: 5, scope: !894)
!905 = !DILocation(line: 58, column: 13, scope: !894)
!906 = !DILocation(line: 58, column: 17, scope: !894)
!907 = !DILocation(line: 58, column: 11, scope: !894)
!908 = !DILocation(line: 61, column: 13, scope: !894)
!909 = !DILocation(line: 61, column: 17, scope: !894)
!910 = !DILocation(line: 61, column: 11, scope: !894)
!911 = !DILocation(line: 66, column: 9, scope: !894)
!912 = !DILocation(line: 66, column: 13, scope: !894)
!913 = !DILocation(line: 66, column: 7, scope: !894)
!914 = !DILocation(line: 68, column: 9, scope: !894)
!915 = !DILocation(line: 68, column: 24, scope: !894)
!916 = !DILocation(line: 68, column: 13, scope: !894)
!917 = !DILocation(line: 68, column: 7, scope: !894)
!918 = !DILocation(line: 70, column: 15, scope: !894)
!919 = !DILocation(line: 70, column: 21, scope: !894)
!920 = !DILocation(line: 70, column: 3, scope: !894)
!921 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr", linkageName: "sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr", scope: null, file: !922, line: 11, type: !5, scopeLine: 11, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!922 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/output_queue_config.csl", directory: "")
!923 = !DILocation(line: 11, column: 33, scope: !924)
!924 = !DILexicalBlockFile(scope: !921, file: !922, discriminator: 0)
!925 = !DILocation(line: 12, column: 82, scope: !924)
!926 = !DILocation(line: 12, column: 40, scope: !924)
!927 = !DILocation(line: 12, column: 3, scope: !924)
!928 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue", linkageName: "sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue", scope: null, file: !922, line: 31, type: !5, scopeLine: 31, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!929 = !DILocation(line: 38, column: 3, scope: !930)
!930 = !DILexicalBlockFile(scope: !928, file: !922, discriminator: 0)
!931 = !DILocation(line: 37, column: 3, scope: !930)
!932 = !DILocation(line: 31, column: 35, scope: !930)
!933 = !DILocation(line: 31, column: 25, scope: !930)
!934 = !DILocation(line: 37, column: 45, scope: !930)
!935 = !DILocation(line: 37, column: 16, scope: !930)
!936 = !DILocation(line: 38, column: 30, scope: !930)
!937 = !DILocation(line: 38, column: 18, scope: !930)
!938 = !DILocation(line: 41, column: 9, scope: !930)
!939 = !DILocation(line: 41, column: 13, scope: !930)
!940 = !DILocation(line: 41, column: 7, scope: !930)
!941 = !DILocation(line: 43, column: 9, scope: !930)
!942 = !DILocation(line: 43, column: 24, scope: !930)
!943 = !DILocation(line: 43, column: 13, scope: !930)
!944 = !DILocation(line: 43, column: 27, scope: !930)
!945 = !DILocation(line: 43, column: 7, scope: !930)
!946 = !DILocation(line: 45, column: 15, scope: !930)
!947 = !DILocation(line: 45, column: 21, scope: !930)
!948 = !DILocation(line: 45, column: 3, scope: !930)
!949 = !DILocation(line: 31, column: 1, scope: !930)
!950 = distinct !DISubprogram(name: ".get_tensor_ptr", linkageName: ".get_tensor_ptr", scope: null, file: !4, line: 1, type: !5, scopeLine: 1, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!951 = !DILocation(line: 1, column: 1, scope: !952)
!952 = !DILexicalBlockFile(scope: !950, file: !4, discriminator: 0)
!953 = distinct !DISubprogram(name: "__generic0sys_mod.sys_mod.tile_config.queue_flush.exit", linkageName: "__generic0sys_mod.sys_mod.tile_config.queue_flush.exit", scope: null, file: !954, line: 12, type: !5, scopeLine: 12, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!954 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/queue_flush.csl", directory: "")
!955 = !DILocation(line: 24, column: 3, scope: !956)
!956 = !DILexicalBlockFile(scope: !953, file: !954, discriminator: 0)
!957 = !DILocation(line: 12, column: 1, scope: !956)
!958 = distinct !DISubprogram(name: "__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position", linkageName: "__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position", scope: null, file: !959, line: 30, type: !5, scopeLine: 30, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!959 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/switch_config.csl", directory: "")
!960 = !DILocation(line: 34, column: 3, scope: !961)
!961 = !DILexicalBlockFile(scope: !958, file: !959, discriminator: 0)
!962 = !DILocation(line: 32, column: 3, scope: !961)
!963 = !DILocation(line: 30, column: 27, scope: !961)
!964 = !DILocation(line: 33, column: 7, scope: !961)
!965 = !DILocation(line: 34, column: 36, scope: !961)
!966 = !DILocation(line: 34, column: 24, scope: !961)
!967 = !DILocation(line: 35, column: 3, scope: !961)
!968 = !DILocation(line: 35, column: 18, scope: !961)
!969 = !DILocation(line: 36, column: 15, scope: !961)
!970 = !DILocation(line: 36, column: 21, scope: !961)
!971 = !DILocation(line: 36, column: 3, scope: !961)
!972 = !DILocation(line: 30, column: 1, scope: !961)
!973 = distinct !DISubprogram(name: "__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", linkageName: "__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", scope: null, file: !974, line: 96, type: !5, scopeLine: 96, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!974 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/color_config.csl", directory: "")
!975 = !DILocation(line: 99, column: 3, scope: !976)
!976 = !DILexicalBlockFile(scope: !973, file: !974, discriminator: 0)
!977 = !DILocation(line: 98, column: 3, scope: !976)
!978 = !DILocation(line: 96, column: 17, scope: !976)
!979 = !DILocation(line: 98, column: 16, scope: !976)
!980 = !DILocation(line: 99, column: 29, scope: !976)
!981 = !DILocation(line: 99, column: 17, scope: !976)
!982 = !DILocation(line: 100, column: 13, scope: !976)
!983 = !DILocation(line: 100, column: 21, scope: !976)
!984 = !DILocation(line: 100, column: 11, scope: !976)
!985 = !DILocation(line: 104, column: 7, scope: !976)
!986 = !DILocation(line: 104, column: 50, scope: !976)
!987 = !DILocation(line: 104, column: 18, scope: !976)
!988 = !DILocation(line: 104, column: 15, scope: !976)
!989 = !DILocation(line: 121, column: 7, scope: !976)
!990 = !DILocation(line: 121, column: 50, scope: !976)
!991 = !DILocation(line: 121, column: 18, scope: !976)
!992 = !DILocation(line: 121, column: 15, scope: !976)
!993 = !DILocation(line: 128, column: 15, scope: !976)
!994 = !DILocation(line: 128, column: 21, scope: !976)
!995 = !DILocation(line: 128, column: 3, scope: !976)
!996 = !DILocation(line: 96, column: 1, scope: !976)
!997 = distinct !DISubprogram(name: "__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", linkageName: "__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", scope: null, file: !974, line: 96, type: !5, scopeLine: 96, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!998 = !DILocation(line: 99, column: 3, scope: !999)
!999 = !DILexicalBlockFile(scope: !997, file: !974, discriminator: 0)
!1000 = !DILocation(line: 98, column: 3, scope: !999)
!1001 = !DILocation(line: 96, column: 17, scope: !999)
!1002 = !DILocation(line: 98, column: 16, scope: !999)
!1003 = !DILocation(line: 99, column: 29, scope: !999)
!1004 = !DILocation(line: 99, column: 17, scope: !999)
!1005 = !DILocation(line: 100, column: 13, scope: !999)
!1006 = !DILocation(line: 100, column: 21, scope: !999)
!1007 = !DILocation(line: 100, column: 11, scope: !999)
!1008 = !DILocation(line: 104, column: 7, scope: !999)
!1009 = !DILocation(line: 104, column: 50, scope: !999)
!1010 = !DILocation(line: 104, column: 18, scope: !999)
!1011 = !DILocation(line: 104, column: 15, scope: !999)
!1012 = !DILocation(line: 121, column: 7, scope: !999)
!1013 = !DILocation(line: 121, column: 50, scope: !999)
!1014 = !DILocation(line: 121, column: 18, scope: !999)
!1015 = !DILocation(line: 121, column: 15, scope: !999)
!1016 = !DILocation(line: 128, column: 15, scope: !999)
!1017 = !DILocation(line: 128, column: 21, scope: !999)
!1018 = !DILocation(line: 128, column: 3, scope: !999)
!1019 = !DILocation(line: 96, column: 1, scope: !999)
!1020 = distinct !DISubprogram(name: "__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", linkageName: "__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", scope: null, file: !974, line: 60, type: !5, scopeLine: 60, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1021 = !DILocation(line: 61, column: 3, scope: !1022)
!1022 = !DILexicalBlockFile(scope: !1020, file: !974, discriminator: 0)
!1023 = !DILocation(line: 60, column: 46, scope: !1022)
!1024 = !DILocation(line: 61, column: 16, scope: !1022)
!1025 = !DILocation(line: 72, column: 5, scope: !1022)
!1026 = !DILocation(line: 72, column: 12, scope: !1022)
!1027 = !DILocation(line: 74, column: 10, scope: !1022)
!1028 = !DILocation(line: 74, column: 3, scope: !1022)
!1029 = distinct !DISubprogram(name: "__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes", linkageName: "__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes", scope: null, file: !974, line: 77, type: !5, scopeLine: 77, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1030 = !DILocation(line: 78, column: 3, scope: !1031)
!1031 = !DILexicalBlockFile(scope: !1029, file: !974, discriminator: 0)
!1032 = !DILocation(line: 77, column: 46, scope: !1031)
!1033 = !DILocation(line: 78, column: 16, scope: !1031)
!1034 = !DILocation(line: 86, column: 5, scope: !1031)
!1035 = !DILocation(line: 86, column: 12, scope: !1031)
!1036 = !DILocation(line: 91, column: 10, scope: !1031)
!1037 = !DILocation(line: 91, column: 3, scope: !1031)
!1038 = distinct !DISubprogram(name: "__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", linkageName: "__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", scope: null, file: !974, line: 60, type: !5, scopeLine: 60, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1039 = !DILocation(line: 61, column: 3, scope: !1040)
!1040 = !DILexicalBlockFile(scope: !1038, file: !974, discriminator: 0)
!1041 = !DILocation(line: 60, column: 46, scope: !1040)
!1042 = !DILocation(line: 61, column: 16, scope: !1040)
!1043 = !DILocation(line: 63, column: 5, scope: !1040)
!1044 = !DILocation(line: 63, column: 12, scope: !1040)
!1045 = !DILocation(line: 74, column: 10, scope: !1040)
!1046 = !DILocation(line: 74, column: 3, scope: !1040)
!1047 = distinct !DISubprogram(name: "__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction", linkageName: "__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction", scope: null, file: !974, line: 52, type: !5, scopeLine: 52, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1048 = !DILocation(line: 55, column: 3, scope: !1049)
!1049 = !DILexicalBlockFile(scope: !1047, file: !974, discriminator: 0)
!1050 = !DILocation(line: 54, column: 3, scope: !1049)
!1051 = !DILocation(line: 52, column: 23, scope: !1049)
!1052 = !DILocation(line: 54, column: 16, scope: !1049)
!1053 = !DILocation(line: 55, column: 29, scope: !1049)
!1054 = !DILocation(line: 55, column: 17, scope: !1049)
!1055 = !DILocation(line: 56, column: 3, scope: !1049)
!1056 = !DILocation(line: 56, column: 11, scope: !1049)
!1057 = !DILocation(line: 57, column: 15, scope: !1049)
!1058 = !DILocation(line: 57, column: 21, scope: !1049)
!1059 = !DILocation(line: 57, column: 3, scope: !1049)
!1060 = !DILocation(line: 52, column: 1, scope: !1049)
!1061 = distinct !DISubprogram(name: "__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction", linkageName: "__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction", scope: null, file: !974, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1062 = !DILocation(line: 23, column: 3, scope: !1063)
!1063 = !DILexicalBlockFile(scope: !1061, file: !974, discriminator: 0)
!1064 = !DILocation(line: 22, column: 3, scope: !1063)
!1065 = !DILocation(line: 20, column: 21, scope: !1063)
!1066 = !DILocation(line: 22, column: 16, scope: !1063)
!1067 = !DILocation(line: 23, column: 29, scope: !1063)
!1068 = !DILocation(line: 23, column: 17, scope: !1063)
!1069 = !DILocation(line: 24, column: 3, scope: !1063)
!1070 = !DILocation(line: 24, column: 11, scope: !1063)
!1071 = !DILocation(line: 25, column: 15, scope: !1063)
!1072 = !DILocation(line: 25, column: 21, scope: !1063)
!1073 = !DILocation(line: 25, column: 3, scope: !1063)
!1074 = !DILocation(line: 20, column: 1, scope: !1063)
module asm ".section \22.pe_debug_info\22, \22\22"
module asm ".section \22.note\22, \22\22"
