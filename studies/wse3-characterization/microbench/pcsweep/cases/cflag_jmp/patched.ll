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
  %3 = icmp slt i16 %1, %2, !dbg !11
  br i1 %3, label %4, label %49, !dbg !12

4:                                                ; preds = %49, %0
  %5 = phi i16 [ %50, %49 ], [ 11, %0 ]
  store i16 %5, i16* getelementptr inbounds ([80 x i16], [80 x i16]* @c, i16 0, i1 false), align 2, !dbg !13
  br label %6, !dbg !12

6:                                                ; preds = %4
  store i16 24577, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i2 1), align 2, !dbg !14
  %7 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @a, i16 0, i2 1), align 2, !dbg !15
  %8 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @b, i16 0, i2 1), align 2, !dbg !16
  %9 = icmp slt i16 %7, %8, !dbg !17
  call void asm sideeffect "nop", ""()
  br i1 %9, label %10, label %51, !dbg !18

10:                                               ; preds = %51, %6
  %11 = phi i16 [ %52, %51 ], [ 11, %6 ]
  store i16 %11, i16* getelementptr inbounds ([80 x i16], [80 x i16]* @c, i16 0, i2 1), align 2, !dbg !19
  br label %12, !dbg !18

12:                                               ; preds = %10
  store i16 24578, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i3 2), align 2, !dbg !20
  %13 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @a, i16 0, i3 2), align 2, !dbg !21
  %14 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @b, i16 0, i3 2), align 2, !dbg !22
  %15 = icmp slt i16 %13, %14, !dbg !23
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  br i1 %15, label %16, label %53, !dbg !24

16:                                               ; preds = %53, %12
  %17 = phi i16 [ %54, %53 ], [ 11, %12 ]
  store i16 %17, i16* getelementptr inbounds ([80 x i16], [80 x i16]* @c, i16 0, i3 2), align 2, !dbg !25
  br label %18, !dbg !24

18:                                               ; preds = %16
  store i16 24579, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i3 3), align 2, !dbg !26
  %19 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @a, i16 0, i3 3), align 2, !dbg !27
  %20 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @b, i16 0, i3 3), align 2, !dbg !28
  %21 = icmp slt i16 %19, %20, !dbg !29
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  br i1 %21, label %22, label %55, !dbg !30

22:                                               ; preds = %55, %18
  %23 = phi i16 [ %56, %55 ], [ 11, %18 ]
  store i16 %23, i16* getelementptr inbounds ([80 x i16], [80 x i16]* @c, i16 0, i3 3), align 2, !dbg !31
  br label %24, !dbg !30

24:                                               ; preds = %22
  store i16 24580, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i4 4), align 2, !dbg !32
  %25 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @a, i16 0, i4 4), align 2, !dbg !33
  %26 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @b, i16 0, i4 4), align 2, !dbg !34
  %27 = icmp slt i16 %25, %26, !dbg !35
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  br i1 %27, label %28, label %57, !dbg !36

28:                                               ; preds = %57, %24
  %29 = phi i16 [ %58, %57 ], [ 11, %24 ]
  store i16 %29, i16* getelementptr inbounds ([80 x i16], [80 x i16]* @c, i16 0, i4 4), align 2, !dbg !37
  br label %30, !dbg !36

30:                                               ; preds = %28
  store i16 24581, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i4 5), align 2, !dbg !38
  %31 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @a, i16 0, i4 5), align 2, !dbg !39
  %32 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @b, i16 0, i4 5), align 2, !dbg !40
  %33 = icmp slt i16 %31, %32, !dbg !41
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  call void asm sideeffect "nop", ""()
  br i1 %33, label %34, label %59, !dbg !42

34:                                               ; preds = %59, %30
  %35 = phi i16 [ %60, %59 ], [ 11, %30 ]
  store i16 %35, i16* getelementptr inbounds ([80 x i16], [80 x i16]* @c, i16 0, i4 5), align 2, !dbg !43
  br label %36, !dbg !42

36:                                               ; preds = %34
  store i16 24582, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i4 6), align 2, !dbg !44
  %37 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @a, i16 0, i4 6), align 2, !dbg !45
  %38 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @b, i16 0, i4 6), align 2, !dbg !46
  %39 = icmp slt i16 %37, %38, !dbg !47
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
  br i1 %39, label %40, label %61, !dbg !48

40:                                               ; preds = %61, %36
  %41 = phi i16 [ %62, %61 ], [ 11, %36 ]
  store i16 %41, i16* getelementptr inbounds ([80 x i16], [80 x i16]* @c, i16 0, i4 6), align 2, !dbg !49
  br label %42, !dbg !48

42:                                               ; preds = %40
  store i16 24583, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i4 7), align 2, !dbg !50
  %43 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @a, i16 0, i4 7), align 2, !dbg !51
  %44 = load i16, i16* getelementptr inbounds ([8 x i16], [8 x i16]* @b, i16 0, i4 7), align 2, !dbg !52
  %45 = icmp slt i16 %43, %44, !dbg !53
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
  br i1 %45, label %46, label %63, !dbg !54

46:                                               ; preds = %63, %42
  %47 = phi i16 [ %64, %63 ], [ 11, %42 ]
  store i16 %47, i16* getelementptr inbounds ([80 x i16], [80 x i16]* @c, i16 0, i4 7), align 2, !dbg !55
  br label %48, !dbg !54

48:                                               ; preds = %46
  store i16 24584, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i5 8), align 2, !dbg !56
  call void @llvm.sdr.actvt.r(i16 9), !dbg !57
  ret void, !dbg !12

49:                                               ; preds = %0
  %50 = phi i16 [ 22, %0 ]
  br label %4, !dbg !12

51:                                               ; preds = %6
  %52 = phi i16 [ 22, %6 ]
  br label %10, !dbg !18

53:                                               ; preds = %12
  %54 = phi i16 [ 22, %12 ]
  br label %16, !dbg !24

55:                                               ; preds = %18
  %56 = phi i16 [ 22, %18 ]
  br label %22, !dbg !30

57:                                               ; preds = %24
  %58 = phi i16 [ 22, %24 ]
  br label %28, !dbg !36

59:                                               ; preds = %30
  %60 = phi i16 [ 22, %30 ]
  br label %34, !dbg !42

61:                                               ; preds = %36
  %62 = phi i16 [ 22, %36 ]
  br label %40, !dbg !48

63:                                               ; preds = %42
  %64 = phi i16 [ 22, %42 ]
  br label %46, !dbg !54
}

define void @f_exit() #0 !dbg !58 {
  call void @sys_mod.unblock_cmd_stream(), !dbg !59
  ret void, !dbg !61
}

define internal void @sys_mod.sys_nop() !dbg !62 {
  ret void, !dbg !64
}

define internal void @sys_mod.unblock_cmd_stream() !dbg !66 {
  call void @sys_mod.sys_mod.unblock_cmd_stream(), !dbg !67
  ret void, !dbg !69
}

define internal void @sys_mod.sys_mod.unblock_cmd_stream() !dbg !70 {
  call void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream(), !dbg !72
  ret void, !dbg !74
}

define internal void @sys_mod.sys_mod.teardown_h2d() !dbg !75 {
  call void @llvm.sdr.actvt.r(i16 27), !dbg !76
  ret void, !dbg !78
}

define void @sys_mod.sys_mod.f_ublk_c22() #1 !dbg !79 {
  call void @sys_mod.sys_mod.unblock_cmd_stream(), !dbg !80
  ret void, !dbg !82
}

define internal void @sys_mod.sys_mod.teardown_d2h() !dbg !83 {
  call void @llvm.sdr.blk.r(i16 0), !dbg !84
  call void @llvm.sdr.actvt.r(i16 28), !dbg !86
  ret void, !dbg !87
}

define void @sys_mod.sys_mod.f_memcpyh2d() #2 !dbg !88 {
  %1 = alloca float, i16 1, align 4, !dbg !89
  %2 = alloca float, i16 1, align 4, !dbg !91
  %3 = alloca i16, i16 1, align 2, !dbg !92
  %4 = alloca i16, i16 1, align 2, !dbg !93
  %5 = alloca i16, i16 1, align 2, !dbg !94
  %6 = alloca i16, i16 1, align 2, !dbg !95
  %7 = alloca i16, i16 1, align 2, !dbg !96
  %8 = alloca i16, i16 1, align 2, !dbg !97
  %9 = alloca i16, i16 1, align 2, !dbg !98
  %10 = alloca i16, i16 1, align 2, !dbg !99
  %11 = alloca i16, i16 1, align 2, !dbg !100
  %12 = alloca i16, i16 1, align 2, !dbg !101
  %13 = alloca i16, i16 1, align 2, !dbg !102
  %14 = alloca i16*, i16 1, align 8, !dbg !103
  %15 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !104
  %16 = icmp eq i16 %15, 15, !dbg !105
  br i1 %16, label %17, label %18, !dbg !106

17:                                               ; preds = %0
  br label %19, !dbg !106

18:                                               ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !106
  br label %19, !dbg !106

19:                                               ; preds = %17, %18
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %14, align 8, !dbg !103
  %20 = load i16*, i16** %14, align 8, !dbg !107
  %21 = load i16, i16* %20, align 2, !dbg !108
  store i16 %21, i16* %13, align 2, !dbg !102
  %22 = load i16*, i16** %14, align 8, !dbg !109
  %23 = getelementptr i16, i16* %22, i16 1, !dbg !110
  %24 = load i16, i16* %23, align 2, !dbg !110
  store i16 %24, i16* %12, align 2, !dbg !101
  %25 = load i16*, i16** %14, align 8, !dbg !111
  %26 = getelementptr i16, i16* %25, i16 2, !dbg !112
  %27 = load i16, i16* %26, align 2, !dbg !112
  store i16 %27, i16* %11, align 2, !dbg !100
  %28 = load i16*, i16** %14, align 8, !dbg !113
  %29 = getelementptr i16, i16* %28, i16 3, !dbg !114
  %30 = load i16, i16* %29, align 2, !dbg !114
  store i16 %30, i16* %10, align 2, !dbg !99
  %31 = load i16*, i16** %14, align 8, !dbg !115
  %32 = getelementptr i16, i16* %31, i16 4, !dbg !116
  %33 = load i16, i16* %32, align 2, !dbg !116
  store i16 %33, i16* %9, align 2, !dbg !98
  %34 = load i16*, i16** %14, align 8, !dbg !117
  %35 = getelementptr i16, i16* %34, i16 5, !dbg !118
  %36 = load i16, i16* %35, align 2, !dbg !118
  store i16 %36, i16* %8, align 2, !dbg !97
  %37 = load i16*, i16** %14, align 8, !dbg !119
  %38 = getelementptr i16, i16* %37, i16 6, !dbg !120
  %39 = load i16, i16* %38, align 2, !dbg !120
  store i16 %39, i16* %7, align 2, !dbg !96
  %40 = load i16*, i16** %14, align 8, !dbg !121
  %41 = getelementptr i16, i16* %40, i16 7, !dbg !122
  %42 = load i16, i16* %41, align 2, !dbg !122
  store i16 %42, i16* %6, align 2, !dbg !95
  %43 = load i16*, i16** %14, align 8, !dbg !123
  %44 = getelementptr i16, i16* %43, i16 8, !dbg !124
  %45 = load i16, i16* %44, align 2, !dbg !124
  store i16 %45, i16* %5, align 2, !dbg !94
  %46 = load i16*, i16** %14, align 8, !dbg !125
  %47 = getelementptr i16, i16* %46, i16 9, !dbg !126
  %48 = load i16, i16* %47, align 2, !dbg !126
  store i16 %48, i16* %4, align 2, !dbg !93
  %49 = load i16*, i16** %14, align 8, !dbg !127
  %50 = getelementptr i16, i16* %49, i16 10, !dbg !128
  %51 = load i16, i16* %50, align 2, !dbg !128
  store i16 %51, i16* %3, align 2, !dbg !92
  %52 = load i16*, i16** %14, align 8, !dbg !129
  %53 = getelementptr i16, i16* %52, i16 12, !dbg !130
  %54 = load i16, i16* %53, align 2, !dbg !130
  %55 = zext i16 %54 to i32, !dbg !131
  %56 = load i16*, i16** %14, align 8, !dbg !132
  %57 = getelementptr i16, i16* %56, i16 11, !dbg !133
  %58 = load i16, i16* %57, align 2, !dbg !133
  %59 = zext i16 %58 to i32, !dbg !134
  %60 = add i32 %59, 16, !dbg !135
  %61 = shl i32 %55, %60, !dbg !136
  %62 = bitcast i32 %61 to float, !dbg !137
  store float %62, float* %2, align 4, !dbg !91
  %63 = load i16*, i16** %14, align 8, !dbg !138
  %64 = getelementptr i16, i16* %63, i16 14, !dbg !139
  %65 = load i16, i16* %64, align 2, !dbg !139
  %66 = zext i16 %65 to i32, !dbg !140
  %67 = load i16*, i16** %14, align 8, !dbg !141
  %68 = getelementptr i16, i16* %67, i16 13, !dbg !142
  %69 = load i16, i16* %68, align 2, !dbg !142
  %70 = zext i16 %69 to i32, !dbg !143
  %71 = add i32 %70, 16, !dbg !144
  %72 = shl i32 %66, %71, !dbg !145
  %73 = bitcast i32 %72 to float, !dbg !146
  store float %73, float* %1, align 4, !dbg !89
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !147
  %74 = load i16, i16* %13, align 2, !dbg !148
  store i16 %74, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !149
  %75 = load i16, i16* %12, align 2, !dbg !150
  store i16 %75, i16* @sys_mod.sys_mod.memcpyH2D_px, align 2, !dbg !151
  %76 = load i16, i16* %11, align 2, !dbg !152
  store i16 %76, i16* @sys_mod.sys_mod.memcpyH2D_py, align 2, !dbg !153
  %77 = load i16, i16* %10, align 2, !dbg !154
  store i16 %77, i16* @sys_mod.sys_mod.memcpyH2D_w, align 2, !dbg !155
  %78 = load i16, i16* %9, align 2, !dbg !156
  store i16 %78, i16* @sys_mod.sys_mod.memcpyH2D_h, align 2, !dbg !157
  %79 = load i16, i16* %8, align 2, !dbg !158
  store i16 %79, i16* @sys_mod.sys_mod.memcpyH2D_addr, align 2, !dbg !159
  %80 = load i16, i16* %7, align 2, !dbg !160
  store i16 %80, i16* @sys_mod.sys_mod.memcpyH2D_pe_length, align 2, !dbg !161
  %81 = load i16, i16* %6, align 2, !dbg !162
  store i16 %81, i16* @sys_mod.sys_mod.memcpyH2D_is_half, align 2, !dbg !163
  %82 = load i16, i16* %5, align 2, !dbg !164
  store i16 %82, i16* @sys_mod.sys_mod.memcpyH2D_memcpy_optype, align 2, !dbg !165
  %83 = load i16, i16* %4, align 2, !dbg !166
  store i16 %83, i16* @sys_mod.sys_mod.memcpyH2D_row_stride, align 2, !dbg !167
  %84 = load i16, i16* %3, align 2, !dbg !168
  store i16 %84, i16* @sys_mod.sys_mod.memcpyH2D_col_stride, align 2, !dbg !169
  %85 = load float, float* %2, align 4, !dbg !170
  store float %85, float* @sys_mod.sys_mod.memcpyH2D_one_over_row_stride, align 4, !dbg !171
  %86 = load float, float* %1, align 4, !dbg !172
  store float %86, float* @sys_mod.sys_mod.memcpyH2D_one_over_col_stride, align 4, !dbg !173
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !174
  call void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 0, i16 23, i1 true), !dbg !175
  call void @llvm.sdr.blk.r(i16 27), !dbg !176
  call void @llvm.sdr.oqflush(i16 0), !dbg !177
  store i1 true, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !178
  call void @llvm.sdr.blk.r(i16 0), !dbg !179
  ret void, !dbg !180
}

define void @sys_mod.sys_mod.f_memcpyd2h() #3 !dbg !181 {
  %1 = alloca i16, i16 1, align 2, !dbg !182
  %2 = alloca i16, i16 1, align 2, !dbg !184
  %3 = alloca i16, i16 1, align 2, !dbg !185
  %4 = alloca i16, i16 1, align 2, !dbg !186
  %5 = alloca i16, i16 1, align 2, !dbg !187
  %6 = alloca i16, i16 1, align 2, !dbg !188
  %7 = alloca i16, i16 1, align 2, !dbg !189
  %8 = alloca i16, i16 1, align 2, !dbg !190
  %9 = alloca i16*, i16 1, align 8, !dbg !191
  %10 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !192
  %11 = icmp eq i16 %10, 8, !dbg !193
  br i1 %11, label %12, label %13, !dbg !194

12:                                               ; preds = %0
  br label %14, !dbg !194

13:                                               ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !194
  br label %14, !dbg !194

14:                                               ; preds = %12, %13
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %9, align 8, !dbg !191
  %15 = load i16*, i16** %9, align 8, !dbg !195
  %16 = load i16, i16* %15, align 2, !dbg !196
  store i16 %16, i16* %8, align 2, !dbg !190
  %17 = load i16*, i16** %9, align 8, !dbg !197
  %18 = getelementptr i16, i16* %17, i16 1, !dbg !198
  %19 = load i16, i16* %18, align 2, !dbg !198
  store i16 %19, i16* %7, align 2, !dbg !189
  %20 = load i16*, i16** %9, align 8, !dbg !199
  %21 = getelementptr i16, i16* %20, i16 2, !dbg !200
  %22 = load i16, i16* %21, align 2, !dbg !200
  store i16 %22, i16* %6, align 2, !dbg !188
  %23 = load i16*, i16** %9, align 8, !dbg !201
  %24 = getelementptr i16, i16* %23, i16 3, !dbg !202
  %25 = load i16, i16* %24, align 2, !dbg !202
  store i16 %25, i16* %5, align 2, !dbg !187
  %26 = load i16*, i16** %9, align 8, !dbg !203
  %27 = getelementptr i16, i16* %26, i16 4, !dbg !204
  %28 = load i16, i16* %27, align 2, !dbg !204
  store i16 %28, i16* %4, align 2, !dbg !186
  %29 = load i16*, i16** %9, align 8, !dbg !205
  %30 = getelementptr i16, i16* %29, i16 5, !dbg !206
  %31 = load i16, i16* %30, align 2, !dbg !206
  store i16 %31, i16* %3, align 2, !dbg !185
  %32 = load i16*, i16** %9, align 8, !dbg !207
  %33 = getelementptr i16, i16* %32, i16 6, !dbg !208
  %34 = load i16, i16* %33, align 2, !dbg !208
  store i16 %34, i16* %2, align 2, !dbg !184
  %35 = load i16*, i16** %9, align 8, !dbg !209
  %36 = getelementptr i16, i16* %35, i16 7, !dbg !210
  %37 = load i16, i16* %36, align 2, !dbg !210
  store i16 %37, i16* %1, align 2, !dbg !182
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !211
  %38 = load i16, i16* %8, align 2, !dbg !212
  store i16 %38, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !213
  %39 = load i16, i16* %7, align 2, !dbg !214
  store i16 %39, i16* @sys_mod.sys_mod.memcpyD2H_px, align 2, !dbg !215
  %40 = load i16, i16* %6, align 2, !dbg !216
  store i16 %40, i16* @sys_mod.sys_mod.memcpyD2H_py, align 2, !dbg !217
  %41 = load i16, i16* %5, align 2, !dbg !218
  store i16 %41, i16* @sys_mod.sys_mod.memcpyD2H_w, align 2, !dbg !219
  %42 = load i16, i16* %4, align 2, !dbg !220
  store i16 %42, i16* @sys_mod.sys_mod.memcpyD2H_h, align 2, !dbg !221
  %43 = load i16, i16* %3, align 2, !dbg !222
  store i16 %43, i16* @sys_mod.sys_mod.memcpyD2H_addr, align 2, !dbg !223
  %44 = load i16, i16* %2, align 2, !dbg !224
  store i16 %44, i16* @sys_mod.sys_mod.memcpyD2H_pe_length, align 2, !dbg !225
  %45 = load i16, i16* %1, align 2, !dbg !226
  store i16 %45, i16* @sys_mod.sys_mod.memcpyD2H_is_half, align 2, !dbg !227
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !228
  %46 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !229
  call void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 0, i16 %46, i1 false), !dbg !230
  call void @llvm.sdr.oqflush(i16 0), !dbg !231
  store i1 false, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !232
  ret void, !dbg !233
}

define internal void @sys_mod.sys_mod.oq0_teardow_handler() !dbg !234 {
  %1 = load i1, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !235
  br i1 %1, label %2, label %17, !dbg !237

2:                                                ; preds = %0
  %3 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !238
  call void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 0, i16 %3), !dbg !239
  %4 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !240
  %5 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_px, align 2, !dbg !241
  %6 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_py, align 2, !dbg !242
  %7 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_w, align 2, !dbg !243
  %8 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_h, align 2, !dbg !244
  %9 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_addr, align 2, !dbg !245
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_pe_length, align 2, !dbg !246
  %11 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_is_half, align 2, !dbg !247
  %12 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_memcpy_optype, align 2, !dbg !248
  %13 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_row_stride, align 2, !dbg !249
  %14 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_col_stride, align 2, !dbg !250
  %15 = load float, float* @sys_mod.sys_mod.memcpyH2D_one_over_row_stride, align 4, !dbg !251
  %16 = load float, float* @sys_mod.sys_mod.memcpyH2D_one_over_col_stride, align 4, !dbg !252
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure(i16 %4, i16 %5, i16 %6, i16 %7, i16 %8, i16 %9, i16 %10, i16 %11, i16 %12, i16 %13, i16 %14, float %15, float %16), !dbg !253
  br label %26, !dbg !237

17:                                               ; preds = %0
  call void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 0, i16 21), !dbg !254
  %18 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !255
  %19 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_px, align 2, !dbg !256
  %20 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_py, align 2, !dbg !257
  %21 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_w, align 2, !dbg !258
  %22 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_h, align 2, !dbg !259
  %23 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_addr, align 2, !dbg !260
  %24 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_pe_length, align 2, !dbg !261
  %25 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_is_half, align 2, !dbg !262
  call void @sys_mod.sys_mod.memcpyd2h_mod.d2h_configure(i16 %18, i16 %19, i16 %20, i16 %21, i16 %22, i16 %23, i16 %24, i16 %25), !dbg !263
  br label %26, !dbg !237

26:                                               ; preds = %2, %17
  call void @__generic0sys_mod.sys_mod.tile_config.queue_flush.exit(), !dbg !264
  ret void, !dbg !237
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

define void @sys_mod.sys_mod.f_rpc(i16 %0) #4 !dbg !265 {
  %2 = alloca i16, i16 1, align 2, !dbg !266
  store i16 %0, i16* %2, align 2, !dbg !266
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !268
  %3 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !269
  %4 = icmp sge i16 %3, 4, !dbg !270
  br i1 %4, label %5, label %6, !dbg !271

5:                                                ; preds = %1
  br label %7, !dbg !271

6:                                                ; preds = %1
  call void asm sideeffect "hcf", ""(), !dbg !271
  br label %7, !dbg !271

7:                                                ; preds = %5, %6
  call void @rpc_server(i32* getelementptr inbounds ([32 x i32], [32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32, i32 0, i32 0)), !dbg !272
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !273
  ret void, !dbg !274
}

define internal void @sys_mod.sys_mod.sys_mod.stack_push(i16 %0) !dbg !275 {
  %2 = alloca i16*, i16 1, align 8, !dbg !277
  %3 = alloca i16, i16 1, align 2, !dbg !279
  store i16 %0, i16* %3, align 2, !dbg !279
  %4 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !280
  %5 = icmp slt i16 %4, 32, !dbg !281
  br i1 %5, label %6, label %7, !dbg !282

6:                                                ; preds = %1
  br label %8, !dbg !282

7:                                                ; preds = %1
  call void asm sideeffect "hcf", ""(), !dbg !282
  br label %8, !dbg !282

8:                                                ; preds = %6, %7
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %2, align 8, !dbg !277
  %9 = load i16, i16* %3, align 2, !dbg !283
  %10 = load i16*, i16** %2, align 8, !dbg !284
  %11 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !285
  %12 = getelementptr i16, i16* %10, i16 %11, !dbg !286
  store i16 %9, i16* %12, align 2, !dbg !287
  %13 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !288
  %14 = add i16 %13, 1, !dbg !289
  store i16 %14, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !290
  ret void, !dbg !291
}

define void @sys_mod.sys_mod.sys_mod.f_push(i16 %0, i16 %1) #5 !dbg !292 {
  %3 = alloca i16, i16 1, align 2, !dbg !293
  %4 = alloca i16, i16 1, align 2, !dbg !295
  store i16 %0, i16* %4, align 2, !dbg !295
  store i16 %1, i16* %3, align 2, !dbg !293
  %5 = load i16, i16* %4, align 2, !dbg !296
  call void @sys_mod.sys_mod.sys_mod.stack_push(i16 %5), !dbg !297
  ret void, !dbg !298
}

define internal void @sys_mod.sys_mod.sys_mod.block_cmd_stream() !dbg !299 {
  call void @llvm.sdr.blk.r(i16 1), !dbg !300
  ret void, !dbg !302
}

define internal void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream() !dbg !303 {
  call void @llvm.sdr.ublk.r(i16 1), !dbg !304
  ret void, !dbg !306
}

define void @sys_mod.sys_mod.sys_mod.f_sys_exit() #6 !dbg !307 {
  call void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream(), !dbg !308
  call void @sys_mod.sys_nop(), !dbg !310
  ret void, !dbg !311
}

define void @sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore(i32 %0) #7 !dbg !312 {
  %2 = alloca i32, i16 1, align 4, !dbg !313
  store i32 %0, i32* %2, align 4, !dbg !313
  ret void, !dbg !315
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord() !dbg !316 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord(), !dbg !318
  ret i16 %1, !dbg !320
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord() !dbg !321 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord(), !dbg !322
  ret i16 %1, !dbg !324
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval(i16 %0) !dbg !325 {
  %2 = alloca i16, i16 1, align 2, !dbg !326
  store i16 %0, i16* %2, align 2, !dbg !326
  %3 = load i16, i16* %2, align 2, !dbg !328
  %4 = icmp ult i16 %3, 24, !dbg !329
  br i1 %4, label %5, label %7, !dbg !330

5:                                                ; preds = %10, %11, %1
  %6 = phi i16 [ 0, %10 ], [ 0, %11 ], [ 1, %1 ]
  br label %12, !dbg !330

7:                                                ; preds = %1
  %8 = load i16, i16* %2, align 2, !dbg !331
  %9 = icmp eq i16 31, %8, !dbg !332
  br i1 %9, label %10, label %11, !dbg !333

10:                                               ; preds = %7
  br label %5, !dbg !333

11:                                               ; preds = %7
  call void asm sideeffect "hcf", ""(), !dbg !333
  br label %5, !dbg !333

12:                                               ; preds = %5
  %13 = phi i16 [ %6, %5 ]
  br label %14, !dbg !330

14:                                               ; preds = %12
  ret i16 %13, !dbg !330
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start(i16 %0, i16 %1, i16 %2) !dbg !334 {
  %4 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !335
  %5 = alloca i16, i16 1, align 2, !dbg !337
  %6 = alloca i16, i16 1, align 2, !dbg !338
  %7 = alloca i16, i16 1, align 2, !dbg !339
  store i16 %0, i16* %7, align 2, !dbg !339
  store i16 %1, i16* %6, align 2, !dbg !338
  store i16 %2, i16* %5, align 2, !dbg !337
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !340
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !340
  %10 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !340
  %11 = load i16, i16* %6, align 2, !dbg !341
  store i16 %11, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !342
  store i16 %8, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !342
  store i16 %9, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !342
  store i16 %10, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !342
  %12 = load i16, i16* %7, align 2, !dbg !343
  %13 = call i16* @.get_tensor_ptr(i16 %12), !dbg !344
  %14 = ptrtoint i16* %13 to i16, !dbg !345
  %15 = lshr i16 %14, 1, !dbg !345
  %16 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !335
  store i16 42, i16* %16, align 2, !dbg !335
  %17 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !335
  store i16 %15, i16* %17, align 2, !dbg !335
  %18 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !335
  store i16 143, i16* %18, align 2, !dbg !335
  %19 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !335
  store i16 16, i16* %19, align 2, !dbg !335
  %20 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !346
  %21 = load i16, i16* %20, align 2, !dbg !346
  %22 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !346
  %23 = load i16, i16* %22, align 2, !dbg !346
  %24 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !346
  %25 = load i16, i16* %24, align 2, !dbg !346
  %26 = load i16, i16* %6, align 2, !dbg !347
  %27 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !348
  store i16 %26, i16* %27, align 2, !dbg !348
  %28 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !348
  store i16 %21, i16* %28, align 2, !dbg !348
  %29 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !348
  store i16 %23, i16* %29, align 2, !dbg !348
  %30 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !348
  store i16 %25, i16* %30, align 2, !dbg !348
  %31 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !349
  %32 = load i16, i16* %31, align 2, !dbg !349
  %33 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !349
  %34 = load i16, i16* %33, align 2, !dbg !349
  %35 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !349
  %36 = load i16, i16* %35, align 2, !dbg !349
  %37 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !349
  %38 = load i16, i16* %37, align 2, !dbg !349
  store volatile i16 %32, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !350
  store volatile i16 %34, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !350
  store volatile i16 %36, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !350
  store volatile i16 %38, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !350
  call void asm sideeffect "nop", ""(), !dbg !350
  call void asm sideeffect "nop", ""(), !dbg !350
  %39 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !351
  %40 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !351
  %41 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !351
  %42 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !351
  %43 = and i16 %41, -193, !dbg !351
  %44 = or i16 %43, 128, !dbg !351
  %45 = and i16 %40, -64, !dbg !351
  %46 = or i16 %45, 27, !dbg !351
  store volatile i16 %39, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !352
  store volatile i16 %46, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !352
  store volatile i16 %44, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !352
  store volatile i16 %42, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !352
  call void asm sideeffect "nop", ""(), !dbg !352
  call void asm sideeffect "nop", ""(), !dbg !352
  %47 = load i16, i16* %5, align 2, !dbg !353
  %48 = icmp ult i16 0, %47, !dbg !354
  br i1 %48, label %49, label %50, !dbg !355

49:                                               ; preds = %3
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !356
  br label %51, !dbg !355

50:                                               ; preds = %3
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !357
  br label %51, !dbg !355

51:                                               ; preds = %49, %50
  ret void, !dbg !355
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream() !dbg !358 {
  call void @llvm.sdr.ublk.r(i16 1), !dbg !359
  ret void, !dbg !361
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7, i16 %8, i16 %9, i16 %10, float %11, float %12) !dbg !362 {
  %14 = alloca i16, i16 1, align 2, !dbg !363
  %15 = alloca i16, i16 1, align 2, !dbg !365
  %16 = alloca i16, i16 1, align 2, !dbg !366
  %17 = alloca i16, i16 1, align 2, !dbg !367
  %18 = alloca i16, i16 1, align 2, !dbg !368
  %19 = alloca i1, i16 1, align 1, !dbg !369
  %20 = alloca i16, i16 1, align 2, !dbg !370
  %21 = alloca i16, i16 1, align 2, !dbg !371
  %22 = alloca i16, i16 1, align 2, !dbg !372
  %23 = alloca i16, i16 1, align 2, !dbg !373
  %24 = alloca i16, i16 1, align 2, !dbg !374
  %25 = alloca float, i16 1, align 4, !dbg !375
  %26 = alloca float, i16 1, align 4, !dbg !376
  %27 = alloca i16, i16 1, align 2, !dbg !377
  %28 = alloca i16, i16 1, align 2, !dbg !378
  %29 = alloca i16, i16 1, align 2, !dbg !379
  %30 = alloca i16, i16 1, align 2, !dbg !380
  %31 = alloca i16, i16 1, align 2, !dbg !381
  %32 = alloca i16, i16 1, align 2, !dbg !382
  %33 = alloca i16, i16 1, align 2, !dbg !383
  %34 = alloca i16, i16 1, align 2, !dbg !384
  %35 = alloca i16, i16 1, align 2, !dbg !385
  %36 = alloca i16, i16 1, align 2, !dbg !386
  %37 = alloca i16, i16 1, align 2, !dbg !387
  store i16 %0, i16* %37, align 2, !dbg !387
  store i16 %1, i16* %36, align 2, !dbg !386
  store i16 %2, i16* %35, align 2, !dbg !385
  store i16 %3, i16* %34, align 2, !dbg !384
  store i16 %4, i16* %33, align 2, !dbg !383
  store i16 %5, i16* %32, align 2, !dbg !382
  store i16 %6, i16* %31, align 2, !dbg !381
  store i16 %7, i16* %30, align 2, !dbg !380
  store i16 %8, i16* %29, align 2, !dbg !379
  store i16 %9, i16* %28, align 2, !dbg !378
  store i16 %10, i16* %27, align 2, !dbg !377
  store float %11, float* %26, align 4, !dbg !376
  store float %12, float* %25, align 4, !dbg !375
  %38 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord(), !dbg !388
  store i16 %38, i16* %24, align 2, !dbg !374
  %39 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord(), !dbg !389
  store i16 %39, i16* %23, align 2, !dbg !373
  %40 = load i16, i16* %24, align 2, !dbg !390
  %41 = load i16, i16* %36, align 2, !dbg !391
  %42 = sub i16 %40, %41, !dbg !392
  store i16 %42, i16* %22, align 2, !dbg !372
  %43 = load i16, i16* %22, align 2, !dbg !393
  store i16 %43, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !394
  %44 = load i16, i16* %29, align 2, !dbg !395
  %45 = icmp eq i16 3, %44, !dbg !396
  br i1 %45, label %46, label %63, !dbg !397

46:                                               ; preds = %13
  %47 = load i16, i16* %22, align 2, !dbg !398
  %48 = sitofp i16 %47 to float, !dbg !399
  %49 = load float, float* %26, align 4, !dbg !400
  %50 = fmul float %48, %49, !dbg !401
  %51 = fptosi float %50 to i16, !dbg !402
  store i16 %51, i16* %21, align 2, !dbg !371
  %52 = load i16, i16* %22, align 2, !dbg !403
  %53 = load i16, i16* %21, align 2, !dbg !404
  %54 = load i16, i16* %28, align 2, !dbg !405
  %55 = mul i16 %53, %54, !dbg !406
  %56 = sub i16 %52, %55, !dbg !407
  store i16 %56, i16* %20, align 2, !dbg !370
  %57 = load i16, i16* %20, align 2, !dbg !408
  %58 = icmp ne i16 0, %57, !dbg !409
  br i1 %58, label %59, label %60, !dbg !410

59:                                               ; preds = %46
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !411
  br label %62, !dbg !410

60:                                               ; preds = %46
  %61 = load i16, i16* %21, align 2, !dbg !412
  store i16 %61, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !413
  br label %62, !dbg !410

62:                                               ; preds = %59, %60
  br label %63, !dbg !397

63:                                               ; preds = %62, %13
  %64 = load i16, i16* %22, align 2, !dbg !414
  %65 = icmp slt i16 %64, 0, !dbg !415
  br i1 %65, label %66, label %67, !dbg !416

66:                                               ; preds = %63
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !417
  br label %67, !dbg !416

67:                                               ; preds = %66, %63
  %68 = load i16, i16* %22, align 2, !dbg !418
  %69 = load i16, i16* %34, align 2, !dbg !419
  %70 = icmp sge i16 %68, %69, !dbg !420
  br i1 %70, label %71, label %72, !dbg !421

71:                                               ; preds = %67
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !422
  br label %72, !dbg !421

72:                                               ; preds = %71, %67
  store i1 false, i1* %19, align 1, !dbg !369
  %73 = load i16, i16* %29, align 2, !dbg !423
  %74 = icmp eq i16 3, %73, !dbg !424
  br i1 %74, label %75, label %94, !dbg !425

75:                                               ; preds = %72
  %76 = load i16, i16* %23, align 2, !dbg !426
  %77 = load i16, i16* %35, align 2, !dbg !427
  %78 = sub i16 %76, %77, !dbg !428
  %79 = sitofp i16 %78 to float, !dbg !429
  %80 = load float, float* %25, align 4, !dbg !430
  %81 = fmul float %79, %80, !dbg !431
  %82 = fptosi float %81 to i16, !dbg !432
  store i16 %82, i16* %18, align 2, !dbg !368
  %83 = load i16, i16* %23, align 2, !dbg !433
  %84 = load i16, i16* %35, align 2, !dbg !434
  %85 = sub i16 %83, %84, !dbg !435
  %86 = load i16, i16* %18, align 2, !dbg !436
  %87 = load i16, i16* %27, align 2, !dbg !437
  %88 = mul i16 %86, %87, !dbg !438
  %89 = sub i16 %85, %88, !dbg !439
  store i16 %89, i16* %17, align 2, !dbg !367
  %90 = load i16, i16* %17, align 2, !dbg !440
  %91 = icmp ne i16 0, %90, !dbg !441
  br i1 %91, label %92, label %93, !dbg !442

92:                                               ; preds = %75
  store i1 true, i1* %19, align 1, !dbg !443
  br label %93, !dbg !442

93:                                               ; preds = %92, %75
  br label %94, !dbg !425

94:                                               ; preds = %93, %72
  %95 = load i16, i16* %23, align 2, !dbg !444
  %96 = load i16, i16* %35, align 2, !dbg !445
  %97 = icmp slt i16 %95, %96, !dbg !446
  br i1 %97, label %98, label %99, !dbg !447

98:                                               ; preds = %94
  store i1 true, i1* %19, align 1, !dbg !448
  br label %99, !dbg !447

99:                                               ; preds = %98, %94
  %100 = load i16, i16* %23, align 2, !dbg !449
  %101 = load i16, i16* %35, align 2, !dbg !450
  %102 = load i16, i16* %33, align 2, !dbg !451
  %103 = add i16 %101, %102, !dbg !452
  %104 = icmp sge i16 %100, %103, !dbg !453
  br i1 %104, label %105, label %106, !dbg !454

105:                                              ; preds = %99
  store i1 true, i1* %19, align 1, !dbg !455
  br label %106, !dbg !454

106:                                              ; preds = %105, %99
  %107 = load i1, i1* %19, align 1, !dbg !456
  br i1 %107, label %108, label %109, !dbg !457

108:                                              ; preds = %106
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream(), !dbg !458
  call void @llvm.sdr.ublk.r(i16 27), !dbg !459
  br label %180, !dbg !457

109:                                              ; preds = %106
  %110 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !460
  %111 = icmp eq i16 -1, %110, !dbg !461
  br i1 %111, label %112, label %113, !dbg !462

112:                                              ; preds = %109
  call void @__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction(i16 31767), !dbg !463
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 23), !dbg !464
  call void @llvm.sdr.ublk.r(i16 27), !dbg !465
  br label %179, !dbg !462

113:                                              ; preds = %109
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter(i16 0, i16 0), !dbg !466
  %114 = load i16, i16* %34, align 2, !dbg !467
  store i16 %114, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !468
  %115 = load i16, i16* %29, align 2, !dbg !469
  %116 = icmp eq i16 3, %115, !dbg !470
  br i1 %116, label %117, label %126, !dbg !471

117:                                              ; preds = %113
  %118 = load i16, i16* %34, align 2, !dbg !472
  %119 = sub i16 %118, 1, !dbg !473
  %120 = sitofp i16 %119 to float, !dbg !474
  %121 = load float, float* %26, align 4, !dbg !475
  %122 = fmul float %120, %121, !dbg !476
  %123 = fptosi float %122 to i16, !dbg !477
  %124 = add i16 %123, 1, !dbg !478
  store i16 %124, i16* %16, align 2, !dbg !366
  %125 = load i16, i16* %16, align 2, !dbg !479
  store i16 %125, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !480
  br label %131, !dbg !471

126:                                              ; preds = %113
  %127 = load i16, i16* %29, align 2, !dbg !481
  %128 = icmp eq i16 1, %127, !dbg !482
  br i1 %128, label %129, label %130, !dbg !483

129:                                              ; preds = %126
  store i16 1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !484
  br label %130, !dbg !483

130:                                              ; preds = %129, %126
  br label %131, !dbg !471

131:                                              ; preds = %117, %130
  %132 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !485
  %133 = sub i16 %132, 1, !dbg !486
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit(i16 0, i16 %133), !dbg !487
  %134 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !488
  store i16 %134, i16* %15, align 2, !dbg !365
  %135 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !489
  store i16 %135, i16* %14, align 2, !dbg !363
  %136 = load i16, i16* %15, align 2, !dbg !490
  %137 = load i16, i16* %14, align 2, !dbg !491
  %138 = sub i16 %136, %137, !dbg !492
  store i16 %138, i16* %15, align 2, !dbg !493
  %139 = load i16, i16* %14, align 2, !dbg !494
  %140 = icmp eq i16 0, %139, !dbg !495
  br i1 %140, label %141, label %142, !dbg !496

141:                                              ; preds = %131
  store i16 0, i16* %15, align 2, !dbg !497
  br label %142, !dbg !496

142:                                              ; preds = %141, %131
  %143 = load i16, i16* %29, align 2, !dbg !498
  %144 = icmp eq i16 1, %143, !dbg !499
  br i1 %144, label %145, label %146, !dbg !500

145:                                              ; preds = %142
  store i16 0, i16* %15, align 2, !dbg !501
  br label %146, !dbg !500

146:                                              ; preds = %145, %142
  %147 = load i16, i16* %15, align 2, !dbg !502
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter(i16 0, i16 %147), !dbg !503
  call void @__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction(i16 31767), !dbg !504
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 23), !dbg !505
  %148 = load i16, i16* %37, align 2, !dbg !506
  %149 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval(i16 %148), !dbg !507
  %150 = icmp eq i16 0, %149, !dbg !508
  br i1 %150, label %151, label %155, !dbg !509

151:                                              ; preds = %146
  %152 = load i16, i16* %32, align 2, !dbg !510
  %153 = load i16, i16* %31, align 2, !dbg !511
  %154 = load i16, i16* %30, align 2, !dbg !512
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start(i16 %152, i16 %153, i16 %154), !dbg !513
  br label %178, !dbg !509

155:                                              ; preds = %146
  %156 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !514
  %157 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !514
  %158 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !514
  %159 = load i16, i16* %31, align 2, !dbg !515
  store i16 %159, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !516
  store i16 %156, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !516
  store i16 %157, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !516
  store i16 %158, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !516
  %160 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !517
  %161 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !517
  %162 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !517
  %163 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !517
  %164 = and i16 %162, -193, !dbg !517
  %165 = or i16 %164, 128, !dbg !517
  store volatile i16 %160, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !518
  store volatile i16 %161, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !518
  store volatile i16 %165, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !518
  store volatile i16 %163, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !518
  call void asm sideeffect "nop", ""(), !dbg !518
  call void asm sideeffect "nop", ""(), !dbg !518
  %166 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !519
  %167 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !519
  %168 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !519
  %169 = load i16, i16* %31, align 2, !dbg !520
  store i16 %169, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !521
  store i16 %166, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !521
  store i16 %167, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !521
  store i16 %168, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !521
  %170 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !522
  %171 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !522
  %172 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !522
  %173 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !522
  %174 = and i16 %172, -193, !dbg !522
  %175 = or i16 %174, 128, !dbg !522
  %176 = and i16 %171, -64, !dbg !522
  %177 = or i16 %176, 27, !dbg !522
  store volatile i16 %170, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !523
  store volatile i16 %177, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !523
  store volatile i16 %175, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !523
  store volatile i16 %173, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !523
  call void asm sideeffect "nop", ""(), !dbg !523
  call void asm sideeffect "nop", ""(), !dbg !523
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !524
  br label %178, !dbg !509

178:                                              ; preds = %151, %155
  br label %179, !dbg !462

179:                                              ; preds = %112, %178
  br label %180, !dbg !457

180:                                              ; preds = %108, %179
  ret void, !dbg !397
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit(i16 %0, i16 %1) !dbg !525 {
  %3 = alloca i16, i16 1, align 2, !dbg !527
  %4 = alloca i16, i16 1, align 2, !dbg !529
  %5 = alloca i16, i16 1, align 2, !dbg !530
  %6 = alloca i16, i16 1, align 2, !dbg !531
  %7 = alloca i16, i16 1, align 2, !dbg !532
  %8 = alloca i16, i16 1, align 2, !dbg !533
  store i16 %0, i16* %8, align 2, !dbg !533
  store i16 %1, i16* %7, align 2, !dbg !532
  %9 = load i16, i16* %7, align 2, !dbg !534
  %10 = icmp ult i16 %9, -32768, !dbg !535
  br i1 %10, label %11, label %12, !dbg !536

11:                                               ; preds = %2
  br label %13, !dbg !536

12:                                               ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !536
  br label %13, !dbg !536

13:                                               ; preds = %11, %12
  %14 = load i16, i16* %7, align 2, !dbg !537
  %15 = mul i16 %14, 2, !dbg !538
  store i16 %15, i16* %6, align 2, !dbg !531
  %16 = load i16, i16* %8, align 2, !dbg !539
  %17 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %16, i16 8), !dbg !540
  %18 = sub i16 %17, 1, !dbg !541
  store i16 %18, i16* %5, align 2, !dbg !530
  %19 = load i16, i16* %6, align 2, !dbg !542
  %20 = load i16, i16* %5, align 2, !dbg !543
  %21 = icmp ult i16 %19, %20, !dbg !544
  br i1 %21, label %22, label %23, !dbg !529

22:                                               ; preds = %13
  store i16 0, i16* %4, align 2, !dbg !529
  br label %27, !dbg !529

23:                                               ; preds = %13
  %24 = load i16, i16* %6, align 2, !dbg !545
  %25 = load i16, i16* %5, align 2, !dbg !546
  %26 = sub i16 %24, %25, !dbg !547
  store i16 %26, i16* %4, align 2, !dbg !529
  br label %27, !dbg !529

27:                                               ; preds = %22, %23
  %28 = load i16, i16* %4, align 2, !dbg !529
  store i16 %28, i16* %3, align 2, !dbg !527
  %29 = load i16, i16* %8, align 2, !dbg !548
  %30 = load i16, i16* %3, align 2, !dbg !549
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %29, i16 4, i16 %30), !dbg !550
  ret void, !dbg !529
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter(i16 %0, i16 %1) !dbg !551 {
  %3 = alloca i16, i16 1, align 2, !dbg !552
  %4 = alloca i16, i16 1, align 2, !dbg !554
  store i16 %0, i16* %4, align 2, !dbg !554
  store i16 %1, i16* %3, align 2, !dbg !552
  %5 = load i16, i16* %3, align 2, !dbg !555
  %6 = icmp ult i16 %5, -32768, !dbg !556
  br i1 %6, label %7, label %8, !dbg !557

7:                                                ; preds = %2
  br label %9, !dbg !557

8:                                                ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !557
  br label %9, !dbg !557

9:                                                ; preds = %7, %8
  %10 = load i16, i16* %4, align 2, !dbg !558
  %11 = load i16, i16* %3, align 2, !dbg !559
  %12 = mul i16 %11, 2, !dbg !560
  %13 = add i16 %12, 1, !dbg !561
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %10, i16 8, i16 %13), !dbg !562
  ret void, !dbg !563
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter(i16 %0, i16 %1) !dbg !564 {
  %3 = alloca i16, i16 1, align 2, !dbg !565
  %4 = alloca i16, i16 1, align 2, !dbg !567
  %5 = alloca i1, i16 1, align 1, !dbg !568
  %6 = alloca i16, i16 1, align 2, !dbg !569
  %7 = alloca i16, i16 1, align 2, !dbg !570
  %8 = alloca i16, i16 1, align 2, !dbg !571
  %9 = alloca i16, i16 1, align 2, !dbg !572
  store i16 %0, i16* %9, align 2, !dbg !572
  store i16 %1, i16* %8, align 2, !dbg !571
  %10 = load i16, i16* %8, align 2, !dbg !573
  %11 = icmp ult i16 %10, -32768, !dbg !574
  br i1 %11, label %12, label %13, !dbg !575

12:                                               ; preds = %2
  br label %14, !dbg !575

13:                                               ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !575
  br label %14, !dbg !575

14:                                               ; preds = %12, %13
  %15 = load i16, i16* %9, align 2, !dbg !576
  %16 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %15, i16 8), !dbg !577
  store i16 %16, i16* %7, align 2, !dbg !570
  %17 = load i16, i16* %8, align 2, !dbg !578
  %18 = mul i16 %17, 2, !dbg !579
  store i16 %18, i16* %6, align 2, !dbg !569
  %19 = load i16, i16* %6, align 2, !dbg !580
  %20 = load i16, i16* %7, align 2, !dbg !581
  %21 = icmp ugt i16 %19, %20, !dbg !582
  store i1 %21, i1* %5, align 1, !dbg !568
  %22 = load i16, i16* %9, align 2, !dbg !583
  %23 = load i1, i1* %5, align 1, !dbg !584
  %24 = zext i1 %23 to i16, !dbg !585
  %25 = shl i16 %24, 6, !dbg !586
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %22, i16 14, i16 %25), !dbg !587
  %26 = load i1, i1* %5, align 1, !dbg !588
  br i1 %26, label %27, label %32, !dbg !567

27:                                               ; preds = %14
  %28 = load i16, i16* %6, align 2, !dbg !589
  %29 = load i16, i16* %7, align 2, !dbg !590
  %30 = sub i16 %28, %29, !dbg !591
  %31 = add i16 %30, 1, !dbg !592
  store i16 %31, i16* %4, align 2, !dbg !567
  br label %34, !dbg !567

32:                                               ; preds = %14
  %33 = load i16, i16* %6, align 2, !dbg !593
  store i16 %33, i16* %4, align 2, !dbg !567
  br label %34, !dbg !567

34:                                               ; preds = %27, %32
  %35 = load i16, i16* %4, align 2, !dbg !567
  store i16 %35, i16* %3, align 2, !dbg !565
  %36 = load i16, i16* %9, align 2, !dbg !594
  %37 = load i16, i16* %3, align 2, !dbg !595
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %36, i16 12, i16 %37), !dbg !596
  ret void, !dbg !567
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %0, i16 %1, i16 %2) !dbg !597 {
  %4 = alloca i16, i16 1, align 2, !dbg !599
  %5 = alloca i16, i16 1, align 2, !dbg !601
  %6 = alloca i16, i16 1, align 2, !dbg !602
  store i16 %0, i16* %6, align 2, !dbg !602
  store i16 %1, i16* %5, align 2, !dbg !601
  store i16 %2, i16* %4, align 2, !dbg !599
  %7 = load i16, i16* %6, align 2, !dbg !603
  %8 = getelementptr [6 x i16], [6 x i16]* @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.filters, i16 0, i16 %7, !dbg !604
  %9 = load i16, i16* %8, align 2, !dbg !604
  %10 = load i16, i16* %5, align 2, !dbg !605
  %11 = add i16 %9, %10, !dbg !606
  %12 = lshr i16 %11, 1, !dbg !607
  %13 = load i16, i16* %4, align 2, !dbg !608
  %14 = shl i16 %12, 1, !dbg !609
  %15 = inttoptr i16 %14 to i16*, !dbg !609
  store volatile i16 %13, i16* %15, align 2, !dbg !609
  call void asm sideeffect "nop", ""(), !dbg !609
  call void asm sideeffect "nop", ""(), !dbg !609
  ret void, !dbg !610
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %0, i16 %1) !dbg !611 {
  %3 = alloca i16, i16 1, align 2, !dbg !612
  %4 = alloca i16, i16 1, align 2, !dbg !614
  store i16 %0, i16* %4, align 2, !dbg !614
  store i16 %1, i16* %3, align 2, !dbg !612
  %5 = load i16, i16* %4, align 2, !dbg !615
  %6 = getelementptr [6 x i16], [6 x i16]* @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.filters, i16 0, i16 %5, !dbg !616
  %7 = load i16, i16* %6, align 2, !dbg !616
  %8 = load i16, i16* %3, align 2, !dbg !617
  %9 = add i16 %7, %8, !dbg !618
  %10 = lshr i16 %9, 1, !dbg !619
  %11 = shl i16 %10, 1, !dbg !620
  %12 = inttoptr i16 %11 to i16*, !dbg !620
  call void asm sideeffect "nop", ""(), !dbg !620
  call void asm sideeffect "nop", ""(), !dbg !620
  %13 = load volatile i16, i16* %12, align 2, !dbg !620
  ret i16 %13, !dbg !621
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 %0) !dbg !622 {
  %2 = alloca i16, i16 1, align 2, !dbg !624
  %3 = alloca i16, i16 1, align 2, !dbg !626
  %4 = alloca i16, i16 1, align 2, !dbg !627
  %5 = alloca i16, i16 1, align 2, !dbg !628
  store i16 %0, i16* %5, align 2, !dbg !628
  %6 = load i16, i16* %5, align 2, !dbg !629
  store i16 %6, i16* %4, align 2, !dbg !627
  %7 = load i16, i16* %4, align 2, !dbg !630
  %8 = add i16 %7, 31744, !dbg !631
  store i16 %8, i16* %3, align 2, !dbg !626
  %9 = load i16, i16* %3, align 2, !dbg !632
  %10 = shl i16 %9, 1, !dbg !633
  %11 = inttoptr i16 %10 to i16*, !dbg !633
  call void asm sideeffect "nop", ""(), !dbg !633
  call void asm sideeffect "nop", ""(), !dbg !633
  %12 = load volatile i16, i16* %11, align 2, !dbg !633
  store i16 %12, i16* %2, align 2, !dbg !624
  %13 = load i16, i16* %3, align 2, !dbg !634
  %14 = load i16, i16* %2, align 2, !dbg !635
  %15 = and i16 %14, 32767, !dbg !636
  %16 = shl i16 %13, 1, !dbg !637
  %17 = inttoptr i16 %16 to i16*, !dbg !637
  store volatile i16 %15, i16* %17, align 2, !dbg !637
  call void asm sideeffect "nop", ""(), !dbg !637
  call void asm sideeffect "nop", ""(), !dbg !637
  ret void, !dbg !638
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord() !dbg !639 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 2), !dbg !641
  %2 = sub i16 %1, 4, !dbg !643
  ret i16 %2, !dbg !644
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord() !dbg !645 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 0), !dbg !646
  %2 = sub i16 %1, 1, !dbg !648
  ret i16 %2, !dbg !649
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 %0) !dbg !650 {
  %2 = alloca i16, i16 1, align 2, !dbg !652
  %3 = alloca i16, i16 1, align 2, !dbg !654
  store i16 %0, i16* %3, align 2, !dbg !654
  %4 = load i16, i16* %3, align 2, !dbg !655
  %5 = lshr i16 %4, 1, !dbg !656
  %6 = add i16 %5, 31813, !dbg !657
  %7 = shl i16 %6, 1, !dbg !658
  %8 = inttoptr i16 %7 to i16*, !dbg !658
  call void asm sideeffect "nop", ""(), !dbg !658
  call void asm sideeffect "nop", ""(), !dbg !658
  %9 = load volatile i16, i16* %8, align 2, !dbg !658
  store i16 %9, i16* %2, align 2, !dbg !652
  %10 = load i16, i16* %2, align 2, !dbg !659
  %11 = and i16 %10, 2047, !dbg !660
  ret i16 %11, !dbg !661
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord() !dbg !662 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord(), !dbg !664
  ret i16 %1, !dbg !666
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.get_y_coord() !dbg !667 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord(), !dbg !668
  ret i16 %1, !dbg !670
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval(i16 %0) !dbg !671 {
  %2 = alloca i16, i16 1, align 2, !dbg !672
  store i16 %0, i16* %2, align 2, !dbg !672
  %3 = load i16, i16* %2, align 2, !dbg !674
  %4 = icmp ult i16 %3, 24, !dbg !675
  br i1 %4, label %5, label %7, !dbg !676

5:                                                ; preds = %10, %11, %1
  %6 = phi i16 [ 0, %10 ], [ 0, %11 ], [ 1, %1 ]
  br label %12, !dbg !676

7:                                                ; preds = %1
  %8 = load i16, i16* %2, align 2, !dbg !677
  %9 = icmp eq i16 31, %8, !dbg !678
  br i1 %9, label %10, label %11, !dbg !679

10:                                               ; preds = %7
  br label %5, !dbg !679

11:                                               ; preds = %7
  call void asm sideeffect "hcf", ""(), !dbg !679
  br label %5, !dbg !679

12:                                               ; preds = %5
  %13 = phi i16 [ %6, %5 ]
  br label %14, !dbg !676

14:                                               ; preds = %12
  ret i16 %13, !dbg !676
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7) !dbg !680 {
  %9 = alloca i16, i16 1, align 2, !dbg !681
  %10 = alloca i16, i16 1, align 2, !dbg !683
  %11 = alloca i16, i16 1, align 2, !dbg !684
  %12 = alloca i16, i16 1, align 2, !dbg !685
  %13 = alloca i16, i16 1, align 2, !dbg !686
  %14 = alloca i16, i16 1, align 2, !dbg !687
  %15 = alloca i16, i16 1, align 2, !dbg !688
  %16 = alloca i16, i16 1, align 2, !dbg !689
  %17 = alloca i16, i16 1, align 2, !dbg !690
  store i16 %0, i16* %17, align 2, !dbg !690
  store i16 %1, i16* %16, align 2, !dbg !689
  store i16 %2, i16* %15, align 2, !dbg !688
  store i16 %3, i16* %14, align 2, !dbg !687
  store i16 %4, i16* %13, align 2, !dbg !686
  store i16 %5, i16* %12, align 2, !dbg !685
  store i16 %6, i16* %11, align 2, !dbg !684
  store i16 %7, i16* %10, align 2, !dbg !683
  %18 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !691
  store i16 %18, i16* %9, align 2, !dbg !681
  %19 = load i16, i16* %11, align 2, !dbg !692
  store i16 %19, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_c, align 2, !dbg !693
  %20 = load i16, i16* %10, align 2, !dbg !694
  store i16 %20, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_is_half, align 2, !dbg !695
  %21 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_c, align 2, !dbg !696
  %22 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval(i16 %21), !dbg !697
  store i16 %22, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !698
  store i16 0, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !699
  %23 = load i16, i16* %16, align 2, !dbg !700
  store i16 %23, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !701
  %24 = load i16, i16* %15, align 2, !dbg !702
  store i16 %24, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !703
  %25 = load i16, i16* %15, align 2, !dbg !704
  %26 = load i16, i16* %13, align 2, !dbg !705
  %27 = add i16 %25, %26, !dbg !706
  %28 = sub i16 %27, 1, !dbg !707
  store i16 %28, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_last, align 2, !dbg !708
  %29 = load i16, i16* %9, align 2, !dbg !709
  %30 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_last, align 2, !dbg !710
  %31 = icmp eq i16 %29, %30, !dbg !711
  br i1 %31, label %32, label %37, !dbg !712

32:                                               ; preds = %8
  %33 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !713
  %34 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !713
  %35 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !713
  store i16 %33, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !714
  store i16 lshr (i16 ptrtoint ([1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.ctrl_1 to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !714
  store i16 %34, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !714
  store i16 %35, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !714
  %36 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.ctrl_1, i16 0, i1 false), align 4, !dbg !715
  store i32 %36, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i1 false), align 4, !dbg !716
  br label %42, !dbg !712

37:                                               ; preds = %8
  %38 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !717
  %39 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !717
  %40 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !717
  store i16 %38, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !718
  store i16 lshr (i16 ptrtoint ([1 x i32]* @"$$csl_base_address$$0$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11" to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !718
  store i16 %39, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !718
  store i16 %40, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !718
  %41 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @"$$csl_base_address$$0$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11", i16 0, i1 false), align 4, !dbg !719
  store i32 %41, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i1 false), align 4, !dbg !720
  br label %42, !dbg !712

42:                                               ; preds = %32, %37
  store i32 165646921, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i2 1), align 4, !dbg !721
  %43 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !722
  %44 = icmp eq i16 0, %43, !dbg !723
  br i1 %44, label %45, label %56, !dbg !724

45:                                               ; preds = %42
  %46 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !725
  %47 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !725
  %48 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !725
  %49 = load i16, i16* %17, align 2, !dbg !726
  %50 = call i16* @.get_tensor_ptr(i16 %49), !dbg !727
  %51 = ptrtoint i16* %50 to i16, !dbg !728
  %52 = lshr i16 %51, 1, !dbg !728
  store i16 %46, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !729
  store i16 %52, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !729
  store i16 %47, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !729
  store i16 %48, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !729
  %53 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !730
  %54 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !730
  %55 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !730
  store i16 1, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !731
  store i16 %53, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !731
  store i16 %54, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !731
  store i16 %55, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !731
  call void @llvm.sdr.actvt.r(i16 21), !dbg !732
  br label %63, !dbg !724

56:                                               ; preds = %42
  %57 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !733
  %58 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !733
  %59 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !733
  store i16 %57, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !734
  store i16 lshr (i16 ptrtoint ([1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.data_buf to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !734
  store i16 %58, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !734
  store i16 %59, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !734
  %60 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !735
  %61 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !735
  %62 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !735
  store i16 1, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !736
  store i16 %60, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !736
  store i16 %61, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !736
  store i16 %62, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !736
  call void @llvm.sdr.ublk.r(i16 0), !dbg !737
  br label %63, !dbg !724

63:                                               ; preds = %45, %56
  ret void, !dbg !712
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x(i32 %0) #8 !dbg !738 {
  %2 = alloca i32, i16 1, align 4, !dbg !739
  store i32 %0, i32* %2, align 4, !dbg !739
  call void @llvm.sdr.blk.r(i16 0), !dbg !741
  %3 = load i32, i32* %2, align 4, !dbg !742
  store i32 %3, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.data_buf, i16 0, i1 false), align 4, !dbg !743
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !744
  %4 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !745
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !745
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !745
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !745
  store volatile i16 %4, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !746
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !746
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !746
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !746
  call void asm sideeffect "nop", ""(), !dbg !746
  call void asm sideeffect "nop", ""(), !dbg !746
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !747
  %8 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !748
  %9 = add i16 %8, 1, !dbg !749
  store i16 %9, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !750
  ret void, !dbg !751
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_send_data() #9 !dbg !752 {
  %1 = alloca i16, i16 1, align 2, !dbg !753
  %2 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !755
  %3 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !756
  %4 = icmp ult i16 %2, %3, !dbg !757
  br i1 %4, label %5, label %27, !dbg !758

5:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !759
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !760
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !760
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !760
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !760
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !761
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !761
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !761
  store volatile i16 %9, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !761
  call void asm sideeffect "nop", ""(), !dbg !761
  call void asm sideeffect "nop", ""(), !dbg !761
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_is_half, align 2, !dbg !762
  %11 = icmp ult i16 0, %10, !dbg !763
  br i1 %11, label %12, label %18, !dbg !764

12:                                               ; preds = %5
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !765
  %13 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !766
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !766
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !766
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !766
  %17 = add i16 %14, 1, !dbg !767
  store i16 %13, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !768
  store i16 %17, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !768
  store i16 %15, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !768
  store i16 %16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !768
  br label %24, !dbg !764

18:                                               ; preds = %5
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !769
  %19 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !770
  %20 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !770
  %21 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !770
  %22 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !770
  %23 = add i16 %20, 2, !dbg !771
  store i16 %19, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !772
  store i16 %23, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !772
  store i16 %21, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !772
  store i16 %22, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !772
  br label %24, !dbg !764

24:                                               ; preds = %12, %18
  %25 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !773
  %26 = add i16 %25, 1, !dbg !774
  store i16 %26, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !775
  br label %34, !dbg !758

27:                                               ; preds = %0
  %28 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !776
  store i16 %28, i16* %1, align 2, !dbg !753
  %29 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !777
  %30 = load i16, i16* %1, align 2, !dbg !778
  %31 = icmp eq i16 %29, %30, !dbg !779
  br i1 %31, label %32, label %33, !dbg !780

32:                                               ; preds = %27
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !781
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__1 to i8*)), !dbg !782
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !783
  br label %33, !dbg !780

33:                                               ; preds = %32, %27
  br label %34, !dbg !758

34:                                               ; preds = %24, %33
  ret void, !dbg !758
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl() #10 !dbg !784 {
  %1 = alloca i16, i16 1, align 2, !dbg !785
  %2 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !787
  %3 = icmp eq i16 0, %2, !dbg !788
  br i1 %3, label %4, label %9, !dbg !789

4:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__2 to i8*)), !dbg !790
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !791
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !791
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !791
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !791
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !792
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !792
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !792
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !792
  call void asm sideeffect "nop", ""(), !dbg !792
  call void asm sideeffect "nop", ""(), !dbg !792
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !793
  br label %31, !dbg !789

9:                                                ; preds = %0
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !794
  %11 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !795
  %12 = icmp ult i16 %10, %11, !dbg !796
  br i1 %12, label %13, label %18, !dbg !797

13:                                               ; preds = %9
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__3 to i8*)), !dbg !798
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !799
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !799
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !799
  %17 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !799
  store volatile i16 %14, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !800
  store volatile i16 %15, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !800
  store volatile i16 %16, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !800
  store volatile i16 %17, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !800
  call void asm sideeffect "nop", ""(), !dbg !800
  call void asm sideeffect "nop", ""(), !dbg !800
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !801
  br label %30, !dbg !797

18:                                               ; preds = %9
  %19 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !802
  store i16 %19, i16* %1, align 2, !dbg !785
  %20 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !803
  %21 = load i16, i16* %1, align 2, !dbg !804
  %22 = icmp eq i16 %20, %21, !dbg !805
  br i1 %22, label %23, label %24, !dbg !806

23:                                               ; preds = %18
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__4 to i8*)), !dbg !807
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__5 to i8*)), !dbg !808
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !809
  br label %29, !dbg !806

24:                                               ; preds = %18
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !810
  %25 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !811
  %26 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !811
  %27 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !811
  %28 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !811
  store volatile i16 %25, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !812
  store volatile i16 %26, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !812
  store volatile i16 %27, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !812
  store volatile i16 %28, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !812
  call void asm sideeffect "nop", ""(), !dbg !812
  call void asm sideeffect "nop", ""(), !dbg !812
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !813
  br label %29, !dbg !806

29:                                               ; preds = %23, %24
  br label %30, !dbg !797

30:                                               ; preds = %13, %29
  br label %31, !dbg !789

31:                                               ; preds = %4, %30
  ret void, !dbg !789
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.d2h_configure(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7) !dbg !814 {
  %9 = alloca i1, i16 1, align 1, !dbg !815
  %10 = alloca i1, i16 1, align 1, !dbg !817
  %11 = alloca i1, i16 1, align 1, !dbg !818
  %12 = alloca i16, i16 1, align 2, !dbg !819
  %13 = alloca i16, i16 1, align 2, !dbg !820
  %14 = alloca i16, i16 1, align 2, !dbg !821
  %15 = alloca i16, i16 1, align 2, !dbg !822
  %16 = alloca i16, i16 1, align 2, !dbg !823
  %17 = alloca i16, i16 1, align 2, !dbg !824
  %18 = alloca i16, i16 1, align 2, !dbg !825
  %19 = alloca i16, i16 1, align 2, !dbg !826
  %20 = alloca i16, i16 1, align 2, !dbg !827
  %21 = alloca i16, i16 1, align 2, !dbg !828
  %22 = alloca i16, i16 1, align 2, !dbg !829
  %23 = alloca i16, i16 1, align 2, !dbg !830
  %24 = alloca i16, i16 1, align 2, !dbg !831
  %25 = alloca i16, i16 1, align 2, !dbg !832
  store i16 %0, i16* %25, align 2, !dbg !832
  store i16 %1, i16* %24, align 2, !dbg !831
  store i16 %2, i16* %23, align 2, !dbg !830
  store i16 %3, i16* %22, align 2, !dbg !829
  store i16 %4, i16* %21, align 2, !dbg !828
  store i16 %5, i16* %20, align 2, !dbg !827
  store i16 %6, i16* %19, align 2, !dbg !826
  store i16 %7, i16* %18, align 2, !dbg !825
  %26 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !833
  store i16 %26, i16* %17, align 2, !dbg !824
  %27 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_y_coord(), !dbg !834
  store i16 %27, i16* %16, align 2, !dbg !823
  %28 = load i16, i16* %24, align 2, !dbg !835
  store i16 %28, i16* %15, align 2, !dbg !822
  %29 = load i16, i16* %24, align 2, !dbg !836
  %30 = load i16, i16* %22, align 2, !dbg !837
  %31 = add i16 %29, %30, !dbg !838
  %32 = sub i16 %31, 1, !dbg !839
  store i16 %32, i16* %14, align 2, !dbg !821
  %33 = load i16, i16* %23, align 2, !dbg !840
  store i16 %33, i16* %13, align 2, !dbg !820
  %34 = load i16, i16* %23, align 2, !dbg !841
  %35 = load i16, i16* %21, align 2, !dbg !842
  %36 = add i16 %34, %35, !dbg !843
  %37 = sub i16 %36, 1, !dbg !844
  store i16 %37, i16* %12, align 2, !dbg !819
  store i1 false, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !845
  %38 = load i16, i16* %17, align 2, !dbg !846
  %39 = load i16, i16* %15, align 2, !dbg !847
  %40 = icmp sge i16 %38, %39, !dbg !848
  br i1 %40, label %41, label %45, !dbg !818

41:                                               ; preds = %8
  %42 = load i16, i16* %16, align 2, !dbg !849
  %43 = load i16, i16* %12, align 2, !dbg !850
  %44 = icmp sle i16 %42, %43, !dbg !851
  store i1 %44, i1* %11, align 1, !dbg !818
  br label %46, !dbg !818

45:                                               ; preds = %8
  store i1 false, i1* %11, align 1, !dbg !818
  br label %46, !dbg !818

46:                                               ; preds = %41, %45
  %47 = load i1, i1* %11, align 1, !dbg !818
  br i1 %47, label %48, label %52, !dbg !817

48:                                               ; preds = %46
  %49 = load i16, i16* %16, align 2, !dbg !852
  %50 = load i16, i16* %13, align 2, !dbg !853
  %51 = icmp sge i16 %49, %50, !dbg !854
  store i1 %51, i1* %10, align 1, !dbg !817
  br label %53, !dbg !817

52:                                               ; preds = %46
  store i1 false, i1* %10, align 1, !dbg !817
  br label %53, !dbg !817

53:                                               ; preds = %48, %52
  %54 = load i1, i1* %10, align 1, !dbg !817
  br i1 %54, label %55, label %56, !dbg !855

55:                                               ; preds = %53
  store i1 true, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !856
  br label %56, !dbg !855

56:                                               ; preds = %55, %53
  store i1 false, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !857
  %57 = load i16, i16* %17, align 2, !dbg !858
  %58 = load i16, i16* %14, align 2, !dbg !859
  %59 = icmp sle i16 %57, %58, !dbg !860
  br i1 %59, label %60, label %62, !dbg !815

60:                                               ; preds = %56
  %61 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !861
  store i1 %61, i1* %9, align 1, !dbg !815
  br label %63, !dbg !815

62:                                               ; preds = %56
  store i1 false, i1* %9, align 1, !dbg !815
  br label %63, !dbg !815

63:                                               ; preds = %60, %62
  %64 = load i1, i1* %9, align 1, !dbg !815
  br i1 %64, label %65, label %66, !dbg !862

65:                                               ; preds = %63
  store i1 true, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !863
  br label %66, !dbg !862

66:                                               ; preds = %65, %63
  %67 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !864
  br i1 %67, label %68, label %86, !dbg !865

68:                                               ; preds = %66
  call void @__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position(i16 31959), !dbg !866
  %69 = load i16, i16* %15, align 2, !dbg !867
  %70 = load i16, i16* %17, align 2, !dbg !868
  %71 = icmp eq i16 %69, %70, !dbg !869
  br i1 %71, label %72, label %73, !dbg !870

72:                                               ; preds = %68
  call void @__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 31765), !dbg !871
  br label %74, !dbg !870

73:                                               ; preds = %68
  call void @__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 31765), !dbg !872
  br label %74, !dbg !870

74:                                               ; preds = %72, %73
  call void @sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit(i16 21), !dbg !873
  %75 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !874
  br i1 %75, label %76, label %85, !dbg !875

76:                                               ; preds = %74
  %77 = load i16, i16* %20, align 2, !dbg !876
  %78 = load i16, i16* %19, align 2, !dbg !877
  %79 = load i16, i16* %24, align 2, !dbg !878
  %80 = load i16, i16* %23, align 2, !dbg !879
  %81 = load i16, i16* %22, align 2, !dbg !880
  %82 = load i16, i16* %21, align 2, !dbg !881
  %83 = load i16, i16* %25, align 2, !dbg !882
  %84 = load i16, i16* %18, align 2, !dbg !883
  call void @sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start(i16 %77, i16 %78, i16 %79, i16 %80, i16 %81, i16 %82, i16 %83, i16 %84), !dbg !884
  br label %85, !dbg !875

85:                                               ; preds = %76, %74
  br label %87, !dbg !865

86:                                               ; preds = %66
  call void @llvm.sdr.actvt.r(i16 28), !dbg !885
  br label %87, !dbg !865

87:                                               ; preds = %85, %86
  ret void, !dbg !818
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit(i16 %0) !dbg !886 {
  %2 = alloca i16, i16 1, align 2, !dbg !887
  %3 = alloca i16, i16 1, align 2, !dbg !889
  %4 = alloca i16, i16 1, align 2, !dbg !890
  %5 = alloca i16, i16 1, align 2, !dbg !891
  store i16 %0, i16* %5, align 2, !dbg !891
  %6 = load i16, i16* %5, align 2, !dbg !892
  store i16 %6, i16* %4, align 2, !dbg !890
  %7 = load i16, i16* %4, align 2, !dbg !893
  %8 = add i16 %7, 31744, !dbg !894
  store i16 %8, i16* %3, align 2, !dbg !889
  %9 = load i16, i16* %3, align 2, !dbg !895
  %10 = shl i16 %9, 1, !dbg !896
  %11 = inttoptr i16 %10 to i16*, !dbg !896
  call void asm sideeffect "nop", ""(), !dbg !896
  call void asm sideeffect "nop", ""(), !dbg !896
  %12 = load volatile i16, i16* %11, align 2, !dbg !896
  store i16 %12, i16* %2, align 2, !dbg !887
  %13 = load i16, i16* %3, align 2, !dbg !897
  %14 = load i16, i16* %2, align 2, !dbg !898
  %15 = and i16 %14, 32767, !dbg !899
  %16 = shl i16 %13, 1, !dbg !900
  %17 = inttoptr i16 %16 to i16*, !dbg !900
  store volatile i16 %15, i16* %17, align 2, !dbg !900
  call void asm sideeffect "nop", ""(), !dbg !900
  call void asm sideeffect "nop", ""(), !dbg !900
  ret void, !dbg !901
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord() !dbg !902 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 2), !dbg !903
  %2 = sub i16 %1, 4, !dbg !905
  ret i16 %2, !dbg !906
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord() !dbg !907 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 0), !dbg !908
  %2 = sub i16 %1, 1, !dbg !910
  ret i16 %2, !dbg !911
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 %0) !dbg !912 {
  %2 = alloca i16, i16 1, align 2, !dbg !913
  %3 = alloca i16, i16 1, align 2, !dbg !915
  store i16 %0, i16* %3, align 2, !dbg !915
  %4 = load i16, i16* %3, align 2, !dbg !916
  %5 = lshr i16 %4, 1, !dbg !917
  %6 = add i16 %5, 31813, !dbg !918
  %7 = shl i16 %6, 1, !dbg !919
  %8 = inttoptr i16 %7 to i16*, !dbg !919
  call void asm sideeffect "nop", ""(), !dbg !919
  call void asm sideeffect "nop", ""(), !dbg !919
  %9 = load volatile i16, i16* %8, align 2, !dbg !919
  store i16 %9, i16* %2, align 2, !dbg !913
  %10 = load i16, i16* %2, align 2, !dbg !920
  %11 = and i16 %10, 2047, !dbg !921
  ret i16 %11, !dbg !922
}

define internal i16 @sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr(i16 %0) !dbg !923 {
  %2 = alloca i16, i16 1, align 2, !dbg !925
  store i16 %0, i16* %2, align 2, !dbg !925
  %3 = load i16, i16* %2, align 2, !dbg !927
  %4 = mul i16 %3, 2, !dbg !928
  %5 = add i16 %4, 31680, !dbg !929
  ret i16 %5, !dbg !930
}

define internal void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 %0, i16 %1, i1 %2) !dbg !931 {
  %4 = alloca i16, i16 1, align 2, !dbg !932
  %5 = alloca i16, i16 1, align 2, !dbg !934
  %6 = alloca i1, i16 1, align 1, !dbg !935
  %7 = alloca i16, i16 1, align 2, !dbg !936
  %8 = alloca i16, i16 1, align 2, !dbg !937
  store i16 %0, i16* %8, align 2, !dbg !937
  store i16 %1, i16* %7, align 2, !dbg !936
  store i1 %2, i1* %6, align 1, !dbg !935
  %9 = load i16, i16* %8, align 2, !dbg !938
  %10 = call i16 @sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr(i16 %9), !dbg !939
  store i16 %10, i16* %5, align 2, !dbg !934
  %11 = load i16, i16* %5, align 2, !dbg !940
  %12 = shl i16 %11, 1, !dbg !941
  %13 = inttoptr i16 %12 to i16*, !dbg !941
  call void asm sideeffect "nop", ""(), !dbg !941
  call void asm sideeffect "nop", ""(), !dbg !941
  call void asm sideeffect "nop", ""(), !dbg !941
  call void asm sideeffect "nop", ""(), !dbg !941
  %14 = load volatile i16, i16* %13, align 2, !dbg !941
  store i16 %14, i16* %4, align 2, !dbg !932
  %15 = load i1, i1* %6, align 1, !dbg !942
  br i1 %15, label %16, label %19, !dbg !943

16:                                               ; preds = %3
  %17 = load i16, i16* %4, align 2, !dbg !944
  %18 = or i16 %17, 2048, !dbg !945
  store i16 %18, i16* %4, align 2, !dbg !946
  br label %22, !dbg !943

19:                                               ; preds = %3
  %20 = load i16, i16* %4, align 2, !dbg !947
  %21 = and i16 %20, -2049, !dbg !948
  store i16 %21, i16* %4, align 2, !dbg !949
  br label %22, !dbg !943

22:                                               ; preds = %16, %19
  %23 = load i16, i16* %4, align 2, !dbg !950
  %24 = and i16 %23, -32, !dbg !951
  store i16 %24, i16* %4, align 2, !dbg !952
  %25 = load i16, i16* %4, align 2, !dbg !953
  %26 = load i16, i16* %7, align 2, !dbg !954
  %27 = add i16 %25, %26, !dbg !955
  store i16 %27, i16* %4, align 2, !dbg !956
  %28 = load i16, i16* %5, align 2, !dbg !957
  %29 = load i16, i16* %4, align 2, !dbg !958
  %30 = shl i16 %28, 1, !dbg !959
  %31 = inttoptr i16 %30 to i16*, !dbg !959
  store volatile i16 %29, i16* %31, align 2, !dbg !959
  call void asm sideeffect "nop", ""(), !dbg !959
  call void asm sideeffect "nop", ""(), !dbg !959
  call void asm sideeffect "nop", ""(), !dbg !959
  call void asm sideeffect "nop", ""(), !dbg !959
  ret void, !dbg !943
}

define internal i16 @sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr(i16 %0) !dbg !960 {
  %2 = alloca i16, i16 1, align 2, !dbg !962
  store i16 %0, i16* %2, align 2, !dbg !962
  %3 = load i16, i16* %2, align 2, !dbg !964
  %4 = add i16 %3, 31616, !dbg !965
  ret i16 %4, !dbg !966
}

define internal void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 %0, i16 %1) !dbg !967 {
  %3 = alloca i16, i16 1, align 2, !dbg !968
  %4 = alloca i16, i16 1, align 2, !dbg !970
  %5 = alloca i16, i16 1, align 2, !dbg !971
  %6 = alloca i16, i16 1, align 2, !dbg !972
  store i16 %0, i16* %6, align 2, !dbg !972
  store i16 %1, i16* %5, align 2, !dbg !971
  %7 = load i16, i16* %6, align 2, !dbg !973
  %8 = call i16 @sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr(i16 %7), !dbg !974
  store i16 %8, i16* %4, align 2, !dbg !970
  %9 = load i16, i16* %4, align 2, !dbg !975
  %10 = shl i16 %9, 1, !dbg !976
  %11 = inttoptr i16 %10 to i16*, !dbg !976
  call void asm sideeffect "nop", ""(), !dbg !976
  call void asm sideeffect "nop", ""(), !dbg !976
  call void asm sideeffect "nop", ""(), !dbg !976
  call void asm sideeffect "nop", ""(), !dbg !976
  %12 = load volatile i16, i16* %11, align 2, !dbg !976
  store i16 %12, i16* %3, align 2, !dbg !968
  %13 = load i16, i16* %3, align 2, !dbg !977
  %14 = and i16 %13, -497, !dbg !978
  store i16 %14, i16* %3, align 2, !dbg !979
  %15 = load i16, i16* %3, align 2, !dbg !980
  %16 = load i16, i16* %5, align 2, !dbg !981
  %17 = add i16 %15, %16, !dbg !982
  %18 = shl i16 %17, 4, !dbg !983
  store i16 %18, i16* %3, align 2, !dbg !984
  %19 = load i16, i16* %4, align 2, !dbg !985
  %20 = load i16, i16* %3, align 2, !dbg !986
  %21 = shl i16 %19, 1, !dbg !987
  %22 = inttoptr i16 %21 to i16*, !dbg !987
  store volatile i16 %20, i16* %22, align 2, !dbg !987
  call void asm sideeffect "nop", ""(), !dbg !987
  call void asm sideeffect "nop", ""(), !dbg !987
  call void asm sideeffect "nop", ""(), !dbg !987
  call void asm sideeffect "nop", ""(), !dbg !987
  ret void, !dbg !988
}

define internal i16* @.get_tensor_ptr(i16 %0) !dbg !989 {
  %2 = alloca i16, i16 1, align 2, !dbg !990
  store i16 %0, i16* %2, align 2, !dbg !990
  %3 = load i16, i16* %2, align 2, !dbg !990
  %4 = zext i16 %3 to i32, !dbg !990
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
  ], !dbg !990

5:                                                ; preds = %1
  br i1 false, label %6, label %7, !dbg !990

6:                                                ; preds = %5
  br label %8, !dbg !990

7:                                                ; preds = %5
  call void asm sideeffect "hcf", ""(), !dbg !990
  br label %8, !dbg !990

8:                                                ; preds = %6, %7
  br label %33, !dbg !990

9:                                                ; preds = %1
  %10 = load i16*, i16** @p_a, align 8, !dbg !990
  br label %33, !dbg !990

11:                                               ; preds = %1
  %12 = load i16*, i16** @p_b, align 8, !dbg !990
  br label %33, !dbg !990

13:                                               ; preds = %1
  %14 = load i16*, i16** @p_g, align 8, !dbg !990
  br label %33, !dbg !990

15:                                               ; preds = %1
  %16 = load i16*, i16** @p_c, align 8, !dbg !990
  br label %33, !dbg !990

17:                                               ; preds = %1
  %18 = load i16*, i16** @p_d, align 8, !dbg !990
  br label %33, !dbg !990

19:                                               ; preds = %1
  %20 = load half*, half** @p_af, align 8, !dbg !990
  %21 = bitcast half* %20 to i16*, !dbg !990
  br label %33, !dbg !990

22:                                               ; preds = %1
  %23 = load half*, half** @p_bf, align 8, !dbg !990
  %24 = bitcast half* %23 to i16*, !dbg !990
  br label %33, !dbg !990

25:                                               ; preds = %1
  %26 = load half*, half** @p_gf, align 8, !dbg !990
  %27 = bitcast half* %26 to i16*, !dbg !990
  br label %33, !dbg !990

28:                                               ; preds = %1
  %29 = load half*, half** @p_cf, align 8, !dbg !990
  %30 = bitcast half* %29 to i16*, !dbg !990
  br label %33, !dbg !990

31:                                               ; preds = %1
  %32 = load i16*, i16** @p_mark, align 8, !dbg !990
  br label %33, !dbg !990

33:                                               ; preds = %8, %9, %11, %13, %15, %17, %19, %22, %25, %28, %31
  %34 = phi i16 [ -2, %31 ], [ -2, %28 ], [ -2, %25 ], [ -2, %22 ], [ -2, %19 ], [ -2, %17 ], [ -2, %15 ], [ -2, %13 ], [ -2, %11 ], [ -2, %9 ], [ 0, %8 ]
  %35 = phi i16* [ %32, %31 ], [ %30, %28 ], [ %27, %25 ], [ %24, %22 ], [ %21, %19 ], [ %18, %17 ], [ %16, %15 ], [ %14, %13 ], [ %12, %11 ], [ %10, %9 ], [ undef, %8 ]
  br label %36, !dbg !990

36:                                               ; preds = %33
  %37 = icmp ne i16 %34, 0, !dbg !990
  br i1 %37, label %38, label %39, !dbg !990

38:                                               ; preds = %36
  br label %41, !dbg !990

39:                                               ; preds = %36
  %40 = load i16*, i16** @p_mark, align 8, !dbg !990
  br label %41, !dbg !990

41:                                               ; preds = %38, %39
  %42 = phi i16* [ %40, %39 ], [ %35, %38 ]
  br label %43, !dbg !990

43:                                               ; preds = %41
  ret i16* %42, !dbg !990
}

define internal void @__generic0sys_mod.sys_mod.tile_config.queue_flush.exit() !dbg !992 {
  store volatile i16 1, i16* inttoptr (i16 -2268 to i16*), align 2, !dbg !994
  call void asm sideeffect "nop", ""(), !dbg !994
  call void asm sideeffect "nop", ""(), !dbg !994
  ret void, !dbg !996
}

define internal void @__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position(i16 %0) !dbg !997 {
  %2 = alloca i16, i16 1, align 2, !dbg !999
  %3 = alloca i16, i16 1, align 2, !dbg !1001
  %4 = alloca i16, i16 1, align 2, !dbg !1002
  store i16 %0, i16* %4, align 2, !dbg !1002
  %5 = load i16, i16* %4, align 2, !dbg !1003
  store i16 %5, i16* %3, align 2, !dbg !1001
  %6 = load i16, i16* %3, align 2, !dbg !1004
  %7 = shl i16 %6, 1, !dbg !1005
  %8 = inttoptr i16 %7 to i16*, !dbg !1005
  call void asm sideeffect "nop", ""(), !dbg !1005
  call void asm sideeffect "nop", ""(), !dbg !1005
  call void asm sideeffect "nop", ""(), !dbg !1005
  call void asm sideeffect "nop", ""(), !dbg !1005
  %9 = load volatile i16, i16* %8, align 2, !dbg !1005
  store i16 %9, i16* %2, align 2, !dbg !999
  %10 = load i16, i16* %2, align 2, !dbg !1006
  %11 = and i16 %10, -16, !dbg !1007
  store i16 %11, i16* %2, align 2, !dbg !1007
  %12 = load i16, i16* %3, align 2, !dbg !1008
  %13 = load i16, i16* %2, align 2, !dbg !1009
  %14 = shl i16 %12, 1, !dbg !1010
  %15 = inttoptr i16 %14 to i16*, !dbg !1010
  store volatile i16 %13, i16* %15, align 2, !dbg !1010
  call void asm sideeffect "nop", ""(), !dbg !1010
  call void asm sideeffect "nop", ""(), !dbg !1010
  call void asm sideeffect "nop", ""(), !dbg !1010
  call void asm sideeffect "nop", ""(), !dbg !1010
  ret void, !dbg !1011
}

define internal void @__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 %0) !dbg !1012 {
  %2 = alloca i16, i16 1, align 2, !dbg !1014
  %3 = alloca i16, i16 1, align 2, !dbg !1016
  %4 = alloca i16, i16 1, align 2, !dbg !1017
  store i16 %0, i16* %4, align 2, !dbg !1017
  %5 = load i16, i16* %4, align 2, !dbg !1018
  store i16 %5, i16* %3, align 2, !dbg !1016
  %6 = load i16, i16* %3, align 2, !dbg !1019
  %7 = shl i16 %6, 1, !dbg !1020
  %8 = inttoptr i16 %7 to i16*, !dbg !1020
  call void asm sideeffect "nop", ""(), !dbg !1020
  call void asm sideeffect "nop", ""(), !dbg !1020
  %9 = load volatile i16, i16* %8, align 2, !dbg !1020
  store i16 %9, i16* %2, align 2, !dbg !1014
  %10 = load i16, i16* %2, align 2, !dbg !1021
  %11 = and i16 %10, -256, !dbg !1022
  store i16 %11, i16* %2, align 2, !dbg !1023
  %12 = load i16, i16* %2, align 2, !dbg !1024
  %13 = load i16, i16* %2, align 2, !dbg !1025
  %14 = call i16 @__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %13), !dbg !1026
  %15 = or i16 %12, %14, !dbg !1027
  store i16 %15, i16* %2, align 2, !dbg !1027
  %16 = load i16, i16* %2, align 2, !dbg !1028
  %17 = load i16, i16* %2, align 2, !dbg !1029
  %18 = call i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %17), !dbg !1030
  %19 = or i16 %16, %18, !dbg !1031
  store i16 %19, i16* %2, align 2, !dbg !1031
  %20 = load i16, i16* %3, align 2, !dbg !1032
  %21 = load i16, i16* %2, align 2, !dbg !1033
  %22 = shl i16 %20, 1, !dbg !1034
  %23 = inttoptr i16 %22 to i16*, !dbg !1034
  store volatile i16 %21, i16* %23, align 2, !dbg !1034
  call void asm sideeffect "nop", ""(), !dbg !1034
  call void asm sideeffect "nop", ""(), !dbg !1034
  ret void, !dbg !1035
}

define internal void @__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 %0) !dbg !1036 {
  %2 = alloca i16, i16 1, align 2, !dbg !1037
  %3 = alloca i16, i16 1, align 2, !dbg !1039
  %4 = alloca i16, i16 1, align 2, !dbg !1040
  store i16 %0, i16* %4, align 2, !dbg !1040
  %5 = load i16, i16* %4, align 2, !dbg !1041
  store i16 %5, i16* %3, align 2, !dbg !1039
  %6 = load i16, i16* %3, align 2, !dbg !1042
  %7 = shl i16 %6, 1, !dbg !1043
  %8 = inttoptr i16 %7 to i16*, !dbg !1043
  call void asm sideeffect "nop", ""(), !dbg !1043
  call void asm sideeffect "nop", ""(), !dbg !1043
  %9 = load volatile i16, i16* %8, align 2, !dbg !1043
  store i16 %9, i16* %2, align 2, !dbg !1037
  %10 = load i16, i16* %2, align 2, !dbg !1044
  %11 = and i16 %10, -256, !dbg !1045
  store i16 %11, i16* %2, align 2, !dbg !1046
  %12 = load i16, i16* %2, align 2, !dbg !1047
  %13 = load i16, i16* %2, align 2, !dbg !1048
  %14 = call i16 @__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %13), !dbg !1049
  %15 = or i16 %12, %14, !dbg !1050
  store i16 %15, i16* %2, align 2, !dbg !1050
  %16 = load i16, i16* %2, align 2, !dbg !1051
  %17 = load i16, i16* %2, align 2, !dbg !1052
  %18 = call i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %17), !dbg !1053
  %19 = or i16 %16, %18, !dbg !1054
  store i16 %19, i16* %2, align 2, !dbg !1054
  %20 = load i16, i16* %3, align 2, !dbg !1055
  %21 = load i16, i16* %2, align 2, !dbg !1056
  %22 = shl i16 %20, 1, !dbg !1057
  %23 = inttoptr i16 %22 to i16*, !dbg !1057
  store volatile i16 %21, i16* %23, align 2, !dbg !1057
  call void asm sideeffect "nop", ""(), !dbg !1057
  call void asm sideeffect "nop", ""(), !dbg !1057
  ret void, !dbg !1058
}

define internal i16 @__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %0) !dbg !1059 {
  %2 = alloca i16, i16 1, align 2, !dbg !1060
  %3 = alloca i16, i16 1, align 2, !dbg !1062
  store i16 %0, i16* %3, align 2, !dbg !1062
  %4 = load i16, i16* %3, align 2, !dbg !1063
  store i16 %4, i16* %2, align 2, !dbg !1060
  %5 = load i16, i16* %2, align 2, !dbg !1064
  store i16 %5, i16* %2, align 2, !dbg !1065
  %6 = load i16, i16* %2, align 2, !dbg !1066
  ret i16 %6, !dbg !1067
}

define internal i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %0) !dbg !1068 {
  %2 = alloca i16, i16 1, align 2, !dbg !1069
  %3 = alloca i16, i16 1, align 2, !dbg !1071
  store i16 %0, i16* %3, align 2, !dbg !1071
  %4 = load i16, i16* %3, align 2, !dbg !1072
  store i16 %4, i16* %2, align 2, !dbg !1069
  %5 = load i16, i16* %2, align 2, !dbg !1073
  %6 = or i16 %5, 2, !dbg !1074
  store i16 %6, i16* %2, align 2, !dbg !1074
  %7 = load i16, i16* %2, align 2, !dbg !1075
  ret i16 %7, !dbg !1076
}

define internal i16 @__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %0) !dbg !1077 {
  %2 = alloca i16, i16 1, align 2, !dbg !1078
  %3 = alloca i16, i16 1, align 2, !dbg !1080
  store i16 %0, i16* %3, align 2, !dbg !1080
  %4 = load i16, i16* %3, align 2, !dbg !1081
  store i16 %4, i16* %2, align 2, !dbg !1078
  %5 = load i16, i16* %2, align 2, !dbg !1082
  %6 = or i16 %5, 128, !dbg !1083
  store i16 %6, i16* %2, align 2, !dbg !1083
  %7 = load i16, i16* %2, align 2, !dbg !1084
  ret i16 %7, !dbg !1085
}

define internal void @__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction(i16 %0) !dbg !1086 {
  %2 = alloca i16, i16 1, align 2, !dbg !1087
  %3 = alloca i16, i16 1, align 2, !dbg !1089
  %4 = alloca i16, i16 1, align 2, !dbg !1090
  store i16 %0, i16* %4, align 2, !dbg !1090
  %5 = load i16, i16* %4, align 2, !dbg !1091
  store i16 %5, i16* %3, align 2, !dbg !1089
  %6 = load i16, i16* %3, align 2, !dbg !1092
  %7 = shl i16 %6, 1, !dbg !1093
  %8 = inttoptr i16 %7 to i16*, !dbg !1093
  call void asm sideeffect "nop", ""(), !dbg !1093
  call void asm sideeffect "nop", ""(), !dbg !1093
  %9 = load volatile i16, i16* %8, align 2, !dbg !1093
  store i16 %9, i16* %2, align 2, !dbg !1087
  %10 = load i16, i16* %2, align 2, !dbg !1094
  %11 = and i16 %10, -17, !dbg !1095
  store i16 %11, i16* %2, align 2, !dbg !1095
  %12 = load i16, i16* %3, align 2, !dbg !1096
  %13 = load i16, i16* %2, align 2, !dbg !1097
  %14 = shl i16 %12, 1, !dbg !1098
  %15 = inttoptr i16 %14 to i16*, !dbg !1098
  store volatile i16 %13, i16* %15, align 2, !dbg !1098
  call void asm sideeffect "nop", ""(), !dbg !1098
  call void asm sideeffect "nop", ""(), !dbg !1098
  ret void, !dbg !1099
}

define internal void @__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction(i16 %0) !dbg !1100 {
  %2 = alloca i16, i16 1, align 2, !dbg !1101
  %3 = alloca i16, i16 1, align 2, !dbg !1103
  %4 = alloca i16, i16 1, align 2, !dbg !1104
  store i16 %0, i16* %4, align 2, !dbg !1104
  %5 = load i16, i16* %4, align 2, !dbg !1105
  store i16 %5, i16* %3, align 2, !dbg !1103
  %6 = load i16, i16* %3, align 2, !dbg !1106
  %7 = shl i16 %6, 1, !dbg !1107
  %8 = inttoptr i16 %7 to i16*, !dbg !1107
  call void asm sideeffect "nop", ""(), !dbg !1107
  call void asm sideeffect "nop", ""(), !dbg !1107
  %9 = load volatile i16, i16* %8, align 2, !dbg !1107
  store i16 %9, i16* %2, align 2, !dbg !1101
  %10 = load i16, i16* %2, align 2, !dbg !1108
  %11 = or i16 %10, 16, !dbg !1109
  store i16 %11, i16* %2, align 2, !dbg !1109
  %12 = load i16, i16* %3, align 2, !dbg !1110
  %13 = load i16, i16* %2, align 2, !dbg !1111
  %14 = shl i16 %12, 1, !dbg !1112
  %15 = inttoptr i16 %14 to i16*, !dbg !1112
  store volatile i16 %13, i16* %15, align 2, !dbg !1112
  call void asm sideeffect "nop", ""(), !dbg !1112
  call void asm sideeffect "nop", ""(), !dbg !1112
  ret void, !dbg !1113
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
!4 = !DIFile(filename: "./pe.csl", directory: "/home/USER/xkernel/studies/wse3-characterization/microbench/pcsweep/cases/cflag_jmp")
!5 = !DISubroutineType(types: !6)
!6 = !{}
!7 = !DILocation(line: 17, column: 11, scope: !8)
!8 = !DILexicalBlockFile(scope: !3, file: !4, discriminator: 0)
!9 = !DILocation(line: 18, column: 8, scope: !8)
!10 = !DILocation(line: 18, column: 15, scope: !8)
!11 = !DILocation(line: 18, column: 12, scope: !8)
!12 = !DILocation(line: 18, column: 3, scope: !8)
!13 = !DILocation(line: 18, column: 27, scope: !8)
!14 = !DILocation(line: 19, column: 11, scope: !8)
!15 = !DILocation(line: 20, column: 8, scope: !8)
!16 = !DILocation(line: 20, column: 15, scope: !8)
!17 = !DILocation(line: 20, column: 12, scope: !8)
!18 = !DILocation(line: 20, column: 3, scope: !8)
!19 = !DILocation(line: 20, column: 27, scope: !8)
!20 = !DILocation(line: 21, column: 11, scope: !8)
!21 = !DILocation(line: 22, column: 8, scope: !8)
!22 = !DILocation(line: 22, column: 15, scope: !8)
!23 = !DILocation(line: 22, column: 12, scope: !8)
!24 = !DILocation(line: 22, column: 3, scope: !8)
!25 = !DILocation(line: 22, column: 27, scope: !8)
!26 = !DILocation(line: 23, column: 11, scope: !8)
!27 = !DILocation(line: 24, column: 8, scope: !8)
!28 = !DILocation(line: 24, column: 15, scope: !8)
!29 = !DILocation(line: 24, column: 12, scope: !8)
!30 = !DILocation(line: 24, column: 3, scope: !8)
!31 = !DILocation(line: 24, column: 27, scope: !8)
!32 = !DILocation(line: 25, column: 11, scope: !8)
!33 = !DILocation(line: 26, column: 8, scope: !8)
!34 = !DILocation(line: 26, column: 15, scope: !8)
!35 = !DILocation(line: 26, column: 12, scope: !8)
!36 = !DILocation(line: 26, column: 3, scope: !8)
!37 = !DILocation(line: 26, column: 27, scope: !8)
!38 = !DILocation(line: 27, column: 11, scope: !8)
!39 = !DILocation(line: 28, column: 8, scope: !8)
!40 = !DILocation(line: 28, column: 15, scope: !8)
!41 = !DILocation(line: 28, column: 12, scope: !8)
!42 = !DILocation(line: 28, column: 3, scope: !8)
!43 = !DILocation(line: 28, column: 27, scope: !8)
!44 = !DILocation(line: 29, column: 11, scope: !8)
!45 = !DILocation(line: 30, column: 8, scope: !8)
!46 = !DILocation(line: 30, column: 15, scope: !8)
!47 = !DILocation(line: 30, column: 12, scope: !8)
!48 = !DILocation(line: 30, column: 3, scope: !8)
!49 = !DILocation(line: 30, column: 27, scope: !8)
!50 = !DILocation(line: 31, column: 11, scope: !8)
!51 = !DILocation(line: 32, column: 8, scope: !8)
!52 = !DILocation(line: 32, column: 15, scope: !8)
!53 = !DILocation(line: 32, column: 12, scope: !8)
!54 = !DILocation(line: 32, column: 3, scope: !8)
!55 = !DILocation(line: 32, column: 27, scope: !8)
!56 = !DILocation(line: 34, column: 11, scope: !8)
!57 = !DILocation(line: 35, column: 3, scope: !8)
!58 = distinct !DISubprogram(name: "f_exit", linkageName: "f_exit", scope: null, file: !4, line: 38, type: !5, scopeLine: 38, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!59 = !DILocation(line: 38, column: 22, scope: !60)
!60 = !DILexicalBlockFile(scope: !58, file: !4, discriminator: 0)
!61 = !DILocation(line: 38, column: 1, scope: !60)
!62 = distinct !DISubprogram(name: "sys_mod.sys_nop", linkageName: "sys_mod.sys_nop", scope: null, file: !63, line: 90, type: !5, scopeLine: 90, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!63 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/memcpy.csl", directory: "")
!64 = !DILocation(line: 90, column: 1, scope: !65)
!65 = !DILexicalBlockFile(scope: !62, file: !63, discriminator: 0)
!66 = distinct !DISubprogram(name: "sys_mod.unblock_cmd_stream", linkageName: "sys_mod.unblock_cmd_stream", scope: null, file: !63, line: 102, type: !5, scopeLine: 102, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!67 = !DILocation(line: 103, column: 3, scope: !68)
!68 = !DILexicalBlockFile(scope: !66, file: !63, discriminator: 0)
!69 = !DILocation(line: 102, column: 1, scope: !68)
!70 = distinct !DISubprogram(name: "sys_mod.sys_mod.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.unblock_cmd_stream", scope: null, file: !71, line: 307, type: !5, scopeLine: 307, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!71 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpy.csl", directory: "")
!72 = !DILocation(line: 308, column: 5, scope: !73)
!73 = !DILexicalBlockFile(scope: !70, file: !71, discriminator: 0)
!74 = !DILocation(line: 307, column: 1, scope: !73)
!75 = distinct !DISubprogram(name: "sys_mod.sys_mod.teardown_h2d", linkageName: "sys_mod.sys_mod.teardown_h2d", scope: null, file: !71, line: 323, type: !5, scopeLine: 323, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!76 = !DILocation(line: 326, column: 5, scope: !77)
!77 = !DILexicalBlockFile(scope: !75, file: !71, discriminator: 0)
!78 = !DILocation(line: 323, column: 1, scope: !77)
!79 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_ublk_c22", linkageName: "sys_mod.sys_mod.f_ublk_c22", scope: null, file: !71, line: 335, type: !5, scopeLine: 335, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!80 = !DILocation(line: 336, column: 5, scope: !81)
!81 = !DILexicalBlockFile(scope: !79, file: !71, discriminator: 0)
!82 = !DILocation(line: 335, column: 1, scope: !81)
!83 = distinct !DISubprogram(name: "sys_mod.sys_mod.teardown_d2h", linkageName: "sys_mod.sys_mod.teardown_d2h", scope: null, file: !71, line: 344, type: !5, scopeLine: 344, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!84 = !DILocation(line: 355, column: 5, scope: !85)
!85 = !DILexicalBlockFile(scope: !83, file: !71, discriminator: 0)
!86 = !DILocation(line: 359, column: 5, scope: !85)
!87 = !DILocation(line: 344, column: 1, scope: !85)
!88 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_memcpyh2d", linkageName: "sys_mod.sys_mod.f_memcpyh2d", scope: null, file: !71, line: 460, type: !5, scopeLine: 460, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!89 = !DILocation(line: 477, column: 5, scope: !90)
!90 = !DILexicalBlockFile(scope: !88, file: !71, discriminator: 0)
!91 = !DILocation(line: 476, column: 5, scope: !90)
!92 = !DILocation(line: 475, column: 5, scope: !90)
!93 = !DILocation(line: 474, column: 5, scope: !90)
!94 = !DILocation(line: 473, column: 5, scope: !90)
!95 = !DILocation(line: 472, column: 5, scope: !90)
!96 = !DILocation(line: 471, column: 5, scope: !90)
!97 = !DILocation(line: 470, column: 5, scope: !90)
!98 = !DILocation(line: 469, column: 5, scope: !90)
!99 = !DILocation(line: 468, column: 5, scope: !90)
!100 = !DILocation(line: 467, column: 5, scope: !90)
!101 = !DILocation(line: 466, column: 5, scope: !90)
!102 = !DILocation(line: 465, column: 5, scope: !90)
!103 = !DILocation(line: 463, column: 5, scope: !90)
!104 = !DILocation(line: 462, column: 20, scope: !90)
!105 = !DILocation(line: 462, column: 32, scope: !90)
!106 = !DILocation(line: 462, column: 5, scope: !90)
!107 = !DILocation(line: 465, column: 33, scope: !90)
!108 = !DILocation(line: 465, column: 38, scope: !90)
!109 = !DILocation(line: 466, column: 34, scope: !90)
!110 = !DILocation(line: 466, column: 39, scope: !90)
!111 = !DILocation(line: 467, column: 34, scope: !90)
!112 = !DILocation(line: 467, column: 39, scope: !90)
!113 = !DILocation(line: 468, column: 33, scope: !90)
!114 = !DILocation(line: 468, column: 38, scope: !90)
!115 = !DILocation(line: 469, column: 33, scope: !90)
!116 = !DILocation(line: 469, column: 38, scope: !90)
!117 = !DILocation(line: 470, column: 35, scope: !90)
!118 = !DILocation(line: 470, column: 21, scope: !90)
!119 = !DILocation(line: 471, column: 41, scope: !90)
!120 = !DILocation(line: 471, column: 27, scope: !90)
!121 = !DILocation(line: 472, column: 39, scope: !90)
!122 = !DILocation(line: 472, column: 25, scope: !90)
!123 = !DILocation(line: 473, column: 44, scope: !90)
!124 = !DILocation(line: 473, column: 49, scope: !90)
!125 = !DILocation(line: 474, column: 41, scope: !90)
!126 = !DILocation(line: 474, column: 46, scope: !90)
!127 = !DILocation(line: 475, column: 41, scope: !90)
!128 = !DILocation(line: 475, column: 46, scope: !90)
!129 = !DILocation(line: 476, column: 59, scope: !90)
!130 = !DILocation(line: 476, column: 64, scope: !90)
!131 = !DILocation(line: 476, column: 50, scope: !90)
!132 = !DILocation(line: 476, column: 129, scope: !90)
!133 = !DILocation(line: 476, column: 134, scope: !90)
!134 = !DILocation(line: 476, column: 120, scope: !90)
!135 = !DILocation(line: 476, column: 118, scope: !90)
!136 = !DILocation(line: 476, column: 112, scope: !90)
!137 = !DILocation(line: 476, column: 36, scope: !90)
!138 = !DILocation(line: 477, column: 59, scope: !90)
!139 = !DILocation(line: 477, column: 64, scope: !90)
!140 = !DILocation(line: 477, column: 50, scope: !90)
!141 = !DILocation(line: 477, column: 129, scope: !90)
!142 = !DILocation(line: 477, column: 134, scope: !90)
!143 = !DILocation(line: 477, column: 120, scope: !90)
!144 = !DILocation(line: 477, column: 118, scope: !90)
!145 = !DILocation(line: 477, column: 112, scope: !90)
!146 = !DILocation(line: 477, column: 36, scope: !90)
!147 = !DILocation(line: 479, column: 24, scope: !90)
!148 = !DILocation(line: 481, column: 21, scope: !90)
!149 = !DILocation(line: 481, column: 19, scope: !90)
!150 = !DILocation(line: 482, column: 21, scope: !90)
!151 = !DILocation(line: 482, column: 19, scope: !90)
!152 = !DILocation(line: 483, column: 21, scope: !90)
!153 = !DILocation(line: 483, column: 19, scope: !90)
!154 = !DILocation(line: 484, column: 20, scope: !90)
!155 = !DILocation(line: 484, column: 18, scope: !90)
!156 = !DILocation(line: 485, column: 20, scope: !90)
!157 = !DILocation(line: 485, column: 18, scope: !90)
!158 = !DILocation(line: 486, column: 22, scope: !90)
!159 = !DILocation(line: 486, column: 20, scope: !90)
!160 = !DILocation(line: 487, column: 27, scope: !90)
!161 = !DILocation(line: 487, column: 25, scope: !90)
!162 = !DILocation(line: 488, column: 25, scope: !90)
!163 = !DILocation(line: 488, column: 23, scope: !90)
!164 = !DILocation(line: 489, column: 31, scope: !90)
!165 = !DILocation(line: 489, column: 29, scope: !90)
!166 = !DILocation(line: 490, column: 28, scope: !90)
!167 = !DILocation(line: 490, column: 26, scope: !90)
!168 = !DILocation(line: 491, column: 28, scope: !90)
!169 = !DILocation(line: 491, column: 26, scope: !90)
!170 = !DILocation(line: 492, column: 37, scope: !90)
!171 = !DILocation(line: 492, column: 35, scope: !90)
!172 = !DILocation(line: 493, column: 37, scope: !90)
!173 = !DILocation(line: 493, column: 35, scope: !90)
!174 = !DILocation(line: 495, column: 5, scope: !90)
!175 = !DILocation(line: 501, column: 5, scope: !90)
!176 = !DILocation(line: 506, column: 5, scope: !90)
!177 = !DILocation(line: 521, column: 5, scope: !90)
!178 = !DILocation(line: 522, column: 16, scope: !90)
!179 = !DILocation(line: 531, column: 5, scope: !90)
!180 = !DILocation(line: 460, column: 1, scope: !90)
!181 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_memcpyd2h", linkageName: "sys_mod.sys_mod.f_memcpyd2h", scope: null, file: !71, line: 556, type: !5, scopeLine: 556, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!182 = !DILocation(line: 568, column: 5, scope: !183)
!183 = !DILexicalBlockFile(scope: !181, file: !71, discriminator: 0)
!184 = !DILocation(line: 567, column: 5, scope: !183)
!185 = !DILocation(line: 566, column: 5, scope: !183)
!186 = !DILocation(line: 565, column: 5, scope: !183)
!187 = !DILocation(line: 564, column: 5, scope: !183)
!188 = !DILocation(line: 563, column: 5, scope: !183)
!189 = !DILocation(line: 562, column: 5, scope: !183)
!190 = !DILocation(line: 561, column: 5, scope: !183)
!191 = !DILocation(line: 559, column: 5, scope: !183)
!192 = !DILocation(line: 558, column: 20, scope: !183)
!193 = !DILocation(line: 558, column: 32, scope: !183)
!194 = !DILocation(line: 558, column: 5, scope: !183)
!195 = !DILocation(line: 561, column: 33, scope: !183)
!196 = !DILocation(line: 561, column: 38, scope: !183)
!197 = !DILocation(line: 562, column: 34, scope: !183)
!198 = !DILocation(line: 562, column: 39, scope: !183)
!199 = !DILocation(line: 563, column: 34, scope: !183)
!200 = !DILocation(line: 563, column: 39, scope: !183)
!201 = !DILocation(line: 564, column: 33, scope: !183)
!202 = !DILocation(line: 564, column: 38, scope: !183)
!203 = !DILocation(line: 565, column: 33, scope: !183)
!204 = !DILocation(line: 565, column: 38, scope: !183)
!205 = !DILocation(line: 566, column: 35, scope: !183)
!206 = !DILocation(line: 566, column: 21, scope: !183)
!207 = !DILocation(line: 567, column: 41, scope: !183)
!208 = !DILocation(line: 567, column: 27, scope: !183)
!209 = !DILocation(line: 568, column: 39, scope: !183)
!210 = !DILocation(line: 568, column: 25, scope: !183)
!211 = !DILocation(line: 570, column: 24, scope: !183)
!212 = !DILocation(line: 573, column: 21, scope: !183)
!213 = !DILocation(line: 573, column: 19, scope: !183)
!214 = !DILocation(line: 574, column: 21, scope: !183)
!215 = !DILocation(line: 574, column: 19, scope: !183)
!216 = !DILocation(line: 575, column: 21, scope: !183)
!217 = !DILocation(line: 575, column: 19, scope: !183)
!218 = !DILocation(line: 576, column: 20, scope: !183)
!219 = !DILocation(line: 576, column: 18, scope: !183)
!220 = !DILocation(line: 577, column: 20, scope: !183)
!221 = !DILocation(line: 577, column: 18, scope: !183)
!222 = !DILocation(line: 578, column: 22, scope: !183)
!223 = !DILocation(line: 578, column: 20, scope: !183)
!224 = !DILocation(line: 579, column: 27, scope: !183)
!225 = !DILocation(line: 579, column: 25, scope: !183)
!226 = !DILocation(line: 580, column: 25, scope: !183)
!227 = !DILocation(line: 580, column: 23, scope: !183)
!228 = !DILocation(line: 582, column: 5, scope: !183)
!229 = !DILocation(line: 588, column: 59, scope: !183)
!230 = !DILocation(line: 588, column: 5, scope: !183)
!231 = !DILocation(line: 608, column: 5, scope: !183)
!232 = !DILocation(line: 609, column: 16, scope: !183)
!233 = !DILocation(line: 556, column: 1, scope: !183)
!234 = distinct !DISubprogram(name: "sys_mod.sys_mod.oq0_teardow_handler", linkageName: "sys_mod.sys_mod.oq0_teardow_handler", scope: null, file: !71, line: 631, type: !5, scopeLine: 631, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!235 = !DILocation(line: 632, column: 9, scope: !236)
!236 = !DILexicalBlockFile(scope: !234, file: !71, discriminator: 0)
!237 = !DILocation(line: 632, column: 5, scope: !236)
!238 = !DILocation(line: 634, column: 66, scope: !236)
!239 = !DILocation(line: 634, column: 9, scope: !236)
!240 = !DILocation(line: 636, column: 13, scope: !236)
!241 = !DILocation(line: 637, column: 13, scope: !236)
!242 = !DILocation(line: 638, column: 13, scope: !236)
!243 = !DILocation(line: 639, column: 13, scope: !236)
!244 = !DILocation(line: 640, column: 13, scope: !236)
!245 = !DILocation(line: 641, column: 13, scope: !236)
!246 = !DILocation(line: 642, column: 13, scope: !236)
!247 = !DILocation(line: 643, column: 13, scope: !236)
!248 = !DILocation(line: 644, column: 13, scope: !236)
!249 = !DILocation(line: 645, column: 13, scope: !236)
!250 = !DILocation(line: 646, column: 13, scope: !236)
!251 = !DILocation(line: 647, column: 13, scope: !236)
!252 = !DILocation(line: 648, column: 13, scope: !236)
!253 = !DILocation(line: 635, column: 9, scope: !236)
!254 = !DILocation(line: 652, column: 9, scope: !236)
!255 = !DILocation(line: 654, column: 13, scope: !236)
!256 = !DILocation(line: 655, column: 13, scope: !236)
!257 = !DILocation(line: 656, column: 13, scope: !236)
!258 = !DILocation(line: 657, column: 13, scope: !236)
!259 = !DILocation(line: 658, column: 13, scope: !236)
!260 = !DILocation(line: 659, column: 13, scope: !236)
!261 = !DILocation(line: 660, column: 13, scope: !236)
!262 = !DILocation(line: 661, column: 13, scope: !236)
!263 = !DILocation(line: 653, column: 9, scope: !236)
!264 = !DILocation(line: 664, column: 5, scope: !236)
!265 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_rpc", linkageName: "sys_mod.sys_mod.f_rpc", scope: null, file: !71, line: 694, type: !5, scopeLine: 694, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!266 = !DILocation(line: 694, column: 13, scope: !267)
!267 = !DILexicalBlockFile(scope: !265, file: !71, discriminator: 0)
!268 = !DILocation(line: 700, column: 5, scope: !267)
!269 = !DILocation(line: 706, column: 20, scope: !267)
!270 = !DILocation(line: 706, column: 32, scope: !267)
!271 = !DILocation(line: 706, column: 5, scope: !267)
!272 = !DILocation(line: 710, column: 5, scope: !267)
!273 = !DILocation(line: 712, column: 24, scope: !267)
!274 = !DILocation(line: 694, column: 1, scope: !267)
!275 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.stack_push", linkageName: "sys_mod.sys_mod.sys_mod.stack_push", scope: null, file: !276, line: 54, type: !5, scopeLine: 54, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!276 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/sys.csl", directory: "")
!277 = !DILocation(line: 60, column: 5, scope: !278)
!278 = !DILexicalBlockFile(scope: !275, file: !276, discriminator: 0)
!279 = !DILocation(line: 54, column: 16, scope: !278)
!280 = !DILocation(line: 59, column: 13, scope: !278)
!281 = !DILocation(line: 59, column: 24, scope: !278)
!282 = !DILocation(line: 59, column: 5, scope: !278)
!283 = !DILocation(line: 61, column: 25, scope: !278)
!284 = !DILocation(line: 61, column: 5, scope: !278)
!285 = !DILocation(line: 61, column: 11, scope: !278)
!286 = !DILocation(line: 61, column: 10, scope: !278)
!287 = !DILocation(line: 61, column: 23, scope: !278)
!288 = !DILocation(line: 62, column: 18, scope: !278)
!289 = !DILocation(line: 62, column: 29, scope: !278)
!290 = !DILocation(line: 62, column: 16, scope: !278)
!291 = !DILocation(line: 54, column: 1, scope: !278)
!292 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_push", linkageName: "sys_mod.sys_mod.sys_mod.f_push", scope: null, file: !276, line: 72, type: !5, scopeLine: 72, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!293 = !DILocation(line: 72, column: 25, scope: !294)
!294 = !DILexicalBlockFile(scope: !292, file: !276, discriminator: 0)
!295 = !DILocation(line: 72, column: 13, scope: !294)
!296 = !DILocation(line: 73, column: 16, scope: !294)
!297 = !DILocation(line: 73, column: 5, scope: !294)
!298 = !DILocation(line: 72, column: 1, scope: !294)
!299 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.block_cmd_stream", linkageName: "sys_mod.sys_mod.sys_mod.block_cmd_stream", scope: null, file: !276, line: 76, type: !5, scopeLine: 76, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!300 = !DILocation(line: 77, column: 5, scope: !301)
!301 = !DILexicalBlockFile(scope: !299, file: !276, discriminator: 0)
!302 = !DILocation(line: 76, column: 1, scope: !301)
!303 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.sys_mod.unblock_cmd_stream", scope: null, file: !276, line: 80, type: !5, scopeLine: 80, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!304 = !DILocation(line: 81, column: 5, scope: !305)
!305 = !DILexicalBlockFile(scope: !303, file: !276, discriminator: 0)
!306 = !DILocation(line: 80, column: 1, scope: !305)
!307 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_sys_exit", linkageName: "sys_mod.sys_mod.sys_mod.f_sys_exit", scope: null, file: !276, line: 85, type: !5, scopeLine: 85, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!308 = !DILocation(line: 86, column: 5, scope: !309)
!309 = !DILexicalBlockFile(scope: !307, file: !276, discriminator: 0)
!310 = !DILocation(line: 87, column: 5, scope: !309)
!311 = !DILocation(line: 85, column: 1, scope: !309)
!312 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore", linkageName: "sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore", scope: null, file: !276, line: 90, type: !5, scopeLine: 90, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!313 = !DILocation(line: 90, column: 30, scope: !314)
!314 = !DILexicalBlockFile(scope: !312, file: !276, discriminator: 0)
!315 = !DILocation(line: 90, column: 1, scope: !314)
!316 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord", scope: null, file: !317, line: 131, type: !5, scopeLine: 131, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!317 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpyh2d.csl", directory: "")
!318 = !DILocation(line: 132, column: 12, scope: !319)
!319 = !DILexicalBlockFile(scope: !316, file: !317, discriminator: 0)
!320 = !DILocation(line: 132, column: 5, scope: !319)
!321 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord", scope: null, file: !317, line: 134, type: !5, scopeLine: 134, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!322 = !DILocation(line: 135, column: 12, scope: !323)
!323 = !DILexicalBlockFile(scope: !321, file: !317, discriminator: 0)
!324 = !DILocation(line: 135, column: 5, scope: !323)
!325 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval", scope: null, file: !317, line: 148, type: !5, scopeLine: 148, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!326 = !DILocation(line: 148, column: 23, scope: !327)
!327 = !DILexicalBlockFile(scope: !325, file: !317, discriminator: 0)
!328 = !DILocation(line: 149, column: 9, scope: !327)
!329 = !DILocation(line: 149, column: 20, scope: !327)
!330 = !DILocation(line: 149, column: 5, scope: !327)
!331 = !DILocation(line: 152, column: 23, scope: !327)
!332 = !DILocation(line: 152, column: 20, scope: !327)
!333 = !DILocation(line: 152, column: 9, scope: !327)
!334 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start", scope: null, file: !317, line: 226, type: !5, scopeLine: 226, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!335 = !DILocation(line: 233, column: 5, scope: !336)
!336 = !DILexicalBlockFile(scope: !334, file: !317, discriminator: 0)
!337 = !DILocation(line: 226, column: 49, scope: !336)
!338 = !DILocation(line: 226, column: 32, scope: !336)
!339 = !DILocation(line: 226, column: 21, scope: !336)
!340 = !DILocation(line: 229, column: 37, scope: !336)
!341 = !DILocation(line: 229, column: 52, scope: !336)
!342 = !DILocation(line: 229, column: 19, scope: !336)
!343 = !DILocation(line: 233, column: 71, scope: !336)
!344 = !DILocation(line: 233, column: 55, scope: !336)
!345 = !DILocation(line: 233, column: 25, scope: !336)
!346 = !DILocation(line: 235, column: 37, scope: !336)
!347 = !DILocation(line: 235, column: 52, scope: !336)
!348 = !DILocation(line: 235, column: 19, scope: !336)
!349 = !DILocation(line: 236, column: 28, scope: !336)
!350 = !DILocation(line: 236, column: 5, scope: !336)
!351 = !DILocation(line: 237, column: 28, scope: !336)
!352 = !DILocation(line: 237, column: 5, scope: !336)
!353 = !DILocation(line: 238, column: 13, scope: !336)
!354 = !DILocation(line: 238, column: 11, scope: !336)
!355 = !DILocation(line: 238, column: 5, scope: !336)
!356 = !DILocation(line: 239, column: 9, scope: !336)
!357 = !DILocation(line: 241, column: 9, scope: !336)
!358 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream", scope: null, file: !317, line: 249, type: !5, scopeLine: 249, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!359 = !DILocation(line: 250, column: 5, scope: !360)
!360 = !DILexicalBlockFile(scope: !358, file: !317, discriminator: 0)
!361 = !DILocation(line: 249, column: 1, scope: !360)
!362 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure", scope: null, file: !317, line: 276, type: !5, scopeLine: 276, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!363 = !DILocation(line: 414, column: 13, scope: !364)
!364 = !DILexicalBlockFile(scope: !362, file: !317, discriminator: 0)
!365 = !DILocation(line: 413, column: 13, scope: !364)
!366 = !DILocation(line: 400, column: 17, scope: !364)
!367 = !DILocation(line: 340, column: 9, scope: !364)
!368 = !DILocation(line: 339, column: 9, scope: !364)
!369 = !DILocation(line: 337, column: 5, scope: !364)
!370 = !DILocation(line: 319, column: 9, scope: !364)
!371 = !DILocation(line: 318, column: 9, scope: !364)
!372 = !DILocation(line: 315, column: 5, scope: !364)
!373 = !DILocation(line: 292, column: 5, scope: !364)
!374 = !DILocation(line: 291, column: 5, scope: !364)
!375 = !DILocation(line: 289, column: 5, scope: !364)
!376 = !DILocation(line: 288, column: 5, scope: !364)
!377 = !DILocation(line: 287, column: 5, scope: !364)
!378 = !DILocation(line: 286, column: 5, scope: !364)
!379 = !DILocation(line: 285, column: 5, scope: !364)
!380 = !DILocation(line: 284, column: 5, scope: !364)
!381 = !DILocation(line: 283, column: 5, scope: !364)
!382 = !DILocation(line: 282, column: 5, scope: !364)
!383 = !DILocation(line: 281, column: 5, scope: !364)
!384 = !DILocation(line: 280, column: 5, scope: !364)
!385 = !DILocation(line: 279, column: 5, scope: !364)
!386 = !DILocation(line: 278, column: 5, scope: !364)
!387 = !DILocation(line: 277, column: 5, scope: !364)
!388 = !DILocation(line: 291, column: 26, scope: !364)
!389 = !DILocation(line: 292, column: 26, scope: !364)
!390 = !DILocation(line: 315, column: 25, scope: !364)
!391 = !DILocation(line: 315, column: 31, scope: !364)
!392 = !DILocation(line: 315, column: 29, scope: !364)
!393 = !DILocation(line: 316, column: 20, scope: !364)
!394 = !DILocation(line: 316, column: 18, scope: !364)
!395 = !DILocation(line: 317, column: 52, scope: !364)
!396 = !DILocation(line: 317, column: 49, scope: !364)
!397 = !DILocation(line: 317, column: 5, scope: !364)
!398 = !DILocation(line: 318, column: 42, scope: !364)
!399 = !DILocation(line: 318, column: 33, scope: !364)
!400 = !DILocation(line: 318, column: 49, scope: !364)
!401 = !DILocation(line: 318, column: 48, scope: !364)
!402 = !DILocation(line: 318, column: 24, scope: !364)
!403 = !DILocation(line: 319, column: 24, scope: !364)
!404 = !DILocation(line: 319, column: 32, scope: !364)
!405 = !DILocation(line: 319, column: 36, scope: !364)
!406 = !DILocation(line: 319, column: 34, scope: !364)
!407 = !DILocation(line: 319, column: 30, scope: !364)
!408 = !DILocation(line: 320, column: 18, scope: !364)
!409 = !DILocation(line: 320, column: 15, scope: !364)
!410 = !DILocation(line: 320, column: 9, scope: !364)
!411 = !DILocation(line: 321, column: 26, scope: !364)
!412 = !DILocation(line: 325, column: 28, scope: !364)
!413 = !DILocation(line: 325, column: 26, scope: !364)
!414 = !DILocation(line: 331, column: 9, scope: !364)
!415 = !DILocation(line: 331, column: 15, scope: !364)
!416 = !DILocation(line: 331, column: 5, scope: !364)
!417 = !DILocation(line: 332, column: 22, scope: !364)
!418 = !DILocation(line: 334, column: 9, scope: !364)
!419 = !DILocation(line: 334, column: 18, scope: !364)
!420 = !DILocation(line: 334, column: 15, scope: !364)
!421 = !DILocation(line: 334, column: 5, scope: !364)
!422 = !DILocation(line: 335, column: 22, scope: !364)
!423 = !DILocation(line: 338, column: 52, scope: !364)
!424 = !DILocation(line: 338, column: 49, scope: !364)
!425 = !DILocation(line: 338, column: 5, scope: !364)
!426 = !DILocation(line: 339, column: 42, scope: !364)
!427 = !DILocation(line: 339, column: 48, scope: !364)
!428 = !DILocation(line: 339, column: 46, scope: !364)
!429 = !DILocation(line: 339, column: 33, scope: !364)
!430 = !DILocation(line: 339, column: 52, scope: !364)
!431 = !DILocation(line: 339, column: 51, scope: !364)
!432 = !DILocation(line: 339, column: 24, scope: !364)
!433 = !DILocation(line: 340, column: 25, scope: !364)
!434 = !DILocation(line: 340, column: 31, scope: !364)
!435 = !DILocation(line: 340, column: 29, scope: !364)
!436 = !DILocation(line: 340, column: 37, scope: !364)
!437 = !DILocation(line: 340, column: 41, scope: !364)
!438 = !DILocation(line: 340, column: 39, scope: !364)
!439 = !DILocation(line: 340, column: 35, scope: !364)
!440 = !DILocation(line: 341, column: 18, scope: !364)
!441 = !DILocation(line: 341, column: 15, scope: !364)
!442 = !DILocation(line: 341, column: 9, scope: !364)
!443 = !DILocation(line: 342, column: 26, scope: !364)
!444 = !DILocation(line: 347, column: 10, scope: !364)
!445 = !DILocation(line: 347, column: 16, scope: !364)
!446 = !DILocation(line: 347, column: 14, scope: !364)
!447 = !DILocation(line: 347, column: 5, scope: !364)
!448 = !DILocation(line: 348, column: 22, scope: !364)
!449 = !DILocation(line: 350, column: 10, scope: !364)
!450 = !DILocation(line: 350, column: 18, scope: !364)
!451 = !DILocation(line: 350, column: 21, scope: !364)
!452 = !DILocation(line: 350, column: 20, scope: !364)
!453 = !DILocation(line: 350, column: 14, scope: !364)
!454 = !DILocation(line: 350, column: 5, scope: !364)
!455 = !DILocation(line: 351, column: 22, scope: !364)
!456 = !DILocation(line: 354, column: 9, scope: !364)
!457 = !DILocation(line: 354, column: 5, scope: !364)
!458 = !DILocation(line: 358, column: 9, scope: !364)
!459 = !DILocation(line: 361, column: 9, scope: !364)
!460 = !DILocation(line: 364, column: 20, scope: !364)
!461 = !DILocation(line: 364, column: 17, scope: !364)
!462 = !DILocation(line: 364, column: 9, scope: !364)
!463 = !DILocation(line: 368, column: 13, scope: !364)
!464 = !DILocation(line: 371, column: 13, scope: !364)
!465 = !DILocation(line: 375, column: 13, scope: !364)
!466 = !DILocation(line: 394, column: 13, scope: !364)
!467 = !DILocation(line: 396, column: 29, scope: !364)
!468 = !DILocation(line: 396, column: 27, scope: !364)
!469 = !DILocation(line: 397, column: 60, scope: !364)
!470 = !DILocation(line: 397, column: 57, scope: !364)
!471 = !DILocation(line: 397, column: 13, scope: !364)
!472 = !DILocation(line: 400, column: 54, scope: !364)
!473 = !DILocation(line: 400, column: 55, scope: !364)
!474 = !DILocation(line: 400, column: 46, scope: !364)
!475 = !DILocation(line: 400, column: 59, scope: !364)
!476 = !DILocation(line: 400, column: 58, scope: !364)
!477 = !DILocation(line: 400, column: 37, scope: !364)
!478 = !DILocation(line: 400, column: 35, scope: !364)
!479 = !DILocation(line: 401, column: 33, scope: !364)
!480 = !DILocation(line: 401, column: 31, scope: !364)
!481 = !DILocation(line: 402, column: 69, scope: !364)
!482 = !DILocation(line: 402, column: 66, scope: !364)
!483 = !DILocation(line: 402, column: 19, scope: !364)
!484 = !DILocation(line: 404, column: 31, scope: !364)
!485 = !DILocation(line: 408, column: 75, scope: !364)
!486 = !DILocation(line: 408, column: 88, scope: !364)
!487 = !DILocation(line: 408, column: 13, scope: !364)
!488 = !DILocation(line: 413, column: 31, scope: !364)
!489 = !DILocation(line: 414, column: 33, scope: !364)
!490 = !DILocation(line: 415, column: 21, scope: !364)
!491 = !DILocation(line: 415, column: 29, scope: !364)
!492 = !DILocation(line: 415, column: 27, scope: !364)
!493 = !DILocation(line: 415, column: 19, scope: !364)
!494 = !DILocation(line: 416, column: 22, scope: !364)
!495 = !DILocation(line: 416, column: 19, scope: !364)
!496 = !DILocation(line: 416, column: 13, scope: !364)
!497 = !DILocation(line: 417, column: 23, scope: !364)
!498 = !DILocation(line: 419, column: 63, scope: !364)
!499 = !DILocation(line: 419, column: 60, scope: !364)
!500 = !DILocation(line: 419, column: 13, scope: !364)
!501 = !DILocation(line: 421, column: 23, scope: !364)
!502 = !DILocation(line: 423, column: 69, scope: !364)
!503 = !DILocation(line: 423, column: 13, scope: !364)
!504 = !DILocation(line: 426, column: 13, scope: !364)
!505 = !DILocation(line: 430, column: 13, scope: !364)
!506 = !DILocation(line: 433, column: 48, scope: !364)
!507 = !DILocation(line: 433, column: 22, scope: !364)
!508 = !DILocation(line: 433, column: 19, scope: !364)
!509 = !DILocation(line: 433, column: 13, scope: !364)
!510 = !DILocation(line: 436, column: 34, scope: !364)
!511 = !DILocation(line: 436, column: 39, scope: !364)
!512 = !DILocation(line: 436, column: 50, scope: !364)
!513 = !DILocation(line: 436, column: 17, scope: !364)
!514 = !DILocation(line: 452, column: 49, scope: !364)
!515 = !DILocation(line: 452, column: 64, scope: !364)
!516 = !DILocation(line: 452, column: 31, scope: !364)
!517 = !DILocation(line: 453, column: 40, scope: !364)
!518 = !DILocation(line: 453, column: 17, scope: !364)
!519 = !DILocation(line: 454, column: 50, scope: !364)
!520 = !DILocation(line: 454, column: 66, scope: !364)
!521 = !DILocation(line: 454, column: 32, scope: !364)
!522 = !DILocation(line: 455, column: 40, scope: !364)
!523 = !DILocation(line: 455, column: 17, scope: !364)
!524 = !DILocation(line: 456, column: 17, scope: !364)
!525 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit", scope: null, file: !526, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!526 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/filters/wse3.csl", directory: "")
!527 = !DILocation(line: 24, column: 3, scope: !528)
!528 = !DILexicalBlockFile(scope: !525, file: !526, discriminator: 0)
!529 = !DILocation(line: 24, column: 22, scope: !528)
!530 = !DILocation(line: 23, column: 3, scope: !528)
!531 = !DILocation(line: 22, column: 3, scope: !528)
!532 = !DILocation(line: 20, column: 37, scope: !528)
!533 = !DILocation(line: 20, column: 21, scope: !528)
!534 = !DILocation(line: 21, column: 11, scope: !528)
!535 = !DILocation(line: 21, column: 17, scope: !528)
!536 = !DILocation(line: 21, column: 3, scope: !528)
!537 = !DILocation(line: 22, column: 24, scope: !528)
!538 = !DILocation(line: 22, column: 30, scope: !528)
!539 = !DILocation(line: 23, column: 40, scope: !528)
!540 = !DILocation(line: 23, column: 22, scope: !528)
!541 = !DILocation(line: 23, column: 67, scope: !528)
!542 = !DILocation(line: 24, column: 26, scope: !528)
!543 = !DILocation(line: 24, column: 41, scope: !528)
!544 = !DILocation(line: 24, column: 39, scope: !528)
!545 = !DILocation(line: 24, column: 61, scope: !528)
!546 = !DILocation(line: 24, column: 76, scope: !528)
!547 = !DILocation(line: 24, column: 74, scope: !528)
!548 = !DILocation(line: 25, column: 21, scope: !528)
!549 = !DILocation(line: 25, column: 50, scope: !528)
!550 = !DILocation(line: 25, column: 3, scope: !528)
!551 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter", scope: null, file: !526, line: 30, type: !5, scopeLine: 30, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!552 = !DILocation(line: 30, column: 36, scope: !553)
!553 = !DILexicalBlockFile(scope: !551, file: !526, discriminator: 0)
!554 = !DILocation(line: 30, column: 20, scope: !553)
!555 = !DILocation(line: 31, column: 11, scope: !553)
!556 = !DILocation(line: 31, column: 23, scope: !553)
!557 = !DILocation(line: 31, column: 3, scope: !553)
!558 = !DILocation(line: 32, column: 21, scope: !553)
!559 = !DILocation(line: 32, column: 48, scope: !553)
!560 = !DILocation(line: 32, column: 60, scope: !553)
!561 = !DILocation(line: 32, column: 64, scope: !553)
!562 = !DILocation(line: 32, column: 3, scope: !553)
!563 = !DILocation(line: 30, column: 1, scope: !553)
!564 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter", scope: null, file: !526, line: 40, type: !5, scopeLine: 40, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!565 = !DILocation(line: 47, column: 3, scope: !566)
!566 = !DILexicalBlockFile(scope: !564, file: !526, discriminator: 0)
!567 = !DILocation(line: 48, column: 7, scope: !566)
!568 = !DILocation(line: 44, column: 3, scope: !566)
!569 = !DILocation(line: 43, column: 3, scope: !566)
!570 = !DILocation(line: 42, column: 3, scope: !566)
!571 = !DILocation(line: 40, column: 32, scope: !566)
!572 = !DILocation(line: 40, column: 16, scope: !566)
!573 = !DILocation(line: 41, column: 11, scope: !566)
!574 = !DILocation(line: 41, column: 19, scope: !566)
!575 = !DILocation(line: 41, column: 3, scope: !566)
!576 = !DILocation(line: 42, column: 40, scope: !566)
!577 = !DILocation(line: 42, column: 22, scope: !566)
!578 = !DILocation(line: 43, column: 26, scope: !566)
!579 = !DILocation(line: 43, column: 34, scope: !566)
!580 = !DILocation(line: 44, column: 25, scope: !566)
!581 = !DILocation(line: 44, column: 42, scope: !566)
!582 = !DILocation(line: 44, column: 40, scope: !566)
!583 = !DILocation(line: 45, column: 21, scope: !566)
!584 = !DILocation(line: 46, column: 35, scope: !566)
!585 = !DILocation(line: 46, column: 21, scope: !566)
!586 = !DILocation(line: 46, column: 50, scope: !566)
!587 = !DILocation(line: 45, column: 3, scope: !566)
!588 = !DILocation(line: 48, column: 11, scope: !566)
!589 = !DILocation(line: 48, column: 26, scope: !566)
!590 = !DILocation(line: 48, column: 43, scope: !566)
!591 = !DILocation(line: 48, column: 41, scope: !566)
!592 = !DILocation(line: 48, column: 54, scope: !566)
!593 = !DILocation(line: 48, column: 63, scope: !566)
!594 = !DILocation(line: 49, column: 21, scope: !566)
!595 = !DILocation(line: 49, column: 47, scope: !566)
!596 = !DILocation(line: 49, column: 3, scope: !566)
!597 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config", scope: null, file: !598, line: 33, type: !5, scopeLine: 33, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!598 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/filters/common.csl", directory: "")
!599 = !DILocation(line: 33, column: 46, scope: !600)
!600 = !DILexicalBlockFile(scope: !597, file: !598, discriminator: 0)
!601 = !DILocation(line: 33, column: 31, scope: !600)
!602 = !DILocation(line: 33, column: 15, scope: !600)
!603 = !DILocation(line: 34, column: 24, scope: !600)
!604 = !DILocation(line: 34, column: 23, scope: !600)
!605 = !DILocation(line: 34, column: 51, scope: !600)
!606 = !DILocation(line: 34, column: 35, scope: !600)
!607 = !DILocation(line: 34, column: 60, scope: !600)
!608 = !DILocation(line: 34, column: 73, scope: !600)
!609 = !DILocation(line: 34, column: 3, scope: !600)
!610 = !DILocation(line: 33, column: 1, scope: !600)
!611 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config", scope: null, file: !598, line: 38, type: !5, scopeLine: 38, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!612 = !DILocation(line: 38, column: 31, scope: !613)
!613 = !DILexicalBlockFile(scope: !611, file: !598, discriminator: 0)
!614 = !DILocation(line: 38, column: 15, scope: !613)
!615 = !DILocation(line: 39, column: 31, scope: !613)
!616 = !DILocation(line: 39, column: 30, scope: !613)
!617 = !DILocation(line: 39, column: 58, scope: !613)
!618 = !DILocation(line: 39, column: 42, scope: !613)
!619 = !DILocation(line: 39, column: 67, scope: !613)
!620 = !DILocation(line: 39, column: 10, scope: !613)
!621 = !DILocation(line: 39, column: 3, scope: !613)
!622 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit", scope: null, file: !623, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!623 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/teardown.csl", directory: "")
!624 = !DILocation(line: 43, column: 3, scope: !625)
!625 = !DILexicalBlockFile(scope: !622, file: !623, discriminator: 0)
!626 = !DILocation(line: 41, column: 3, scope: !625)
!627 = !DILocation(line: 40, column: 3, scope: !625)
!628 = !DILocation(line: 39, column: 9, scope: !625)
!629 = !DILocation(line: 40, column: 23, scope: !625)
!630 = !DILocation(line: 41, column: 70, scope: !625)
!631 = !DILocation(line: 41, column: 68, scope: !625)
!632 = !DILocation(line: 43, column: 27, scope: !625)
!633 = !DILocation(line: 43, column: 15, scope: !625)
!634 = !DILocation(line: 44, column: 15, scope: !625)
!635 = !DILocation(line: 44, column: 21, scope: !625)
!636 = !DILocation(line: 44, column: 27, scope: !625)
!637 = !DILocation(line: 44, column: 3, scope: !625)
!638 = !DILocation(line: 39, column: 1, scope: !625)
!639 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord", scope: null, file: !640, line: 4, type: !5, scopeLine: 4, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!640 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/layout.csl", directory: "")
!641 = !DILocation(line: 5, column: 10, scope: !642)
!642 = !DILexicalBlockFile(scope: !639, file: !640, discriminator: 0)
!643 = !DILocation(line: 5, column: 67, scope: !642)
!644 = !DILocation(line: 5, column: 3, scope: !642)
!645 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord", scope: null, file: !640, line: 8, type: !5, scopeLine: 8, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!646 = !DILocation(line: 9, column: 10, scope: !647)
!647 = !DILexicalBlockFile(scope: !645, file: !640, discriminator: 0)
!648 = !DILocation(line: 9, column: 67, scope: !647)
!649 = !DILocation(line: 9, column: 3, scope: !647)
!650 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord", scope: null, file: !651, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!651 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config.csl", directory: "")
!652 = !DILocation(line: 50, column: 3, scope: !653)
!653 = !DILexicalBlockFile(scope: !650, file: !651, discriminator: 0)
!654 = !DILocation(line: 43, column: 21, scope: !653)
!655 = !DILocation(line: 50, column: 57, scope: !653)
!656 = !DILocation(line: 50, column: 68, scope: !653)
!657 = !DILocation(line: 50, column: 41, scope: !653)
!658 = !DILocation(line: 50, column: 19, scope: !653)
!659 = !DILocation(line: 52, column: 10, scope: !653)
!660 = !DILocation(line: 52, column: 18, scope: !653)
!661 = !DILocation(line: 48, column: 22, scope: !653)
!662 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.get_x_coord", scope: null, file: !663, line: 171, type: !5, scopeLine: 171, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!663 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpyd2h.csl", directory: "")
!664 = !DILocation(line: 172, column: 12, scope: !665)
!665 = !DILexicalBlockFile(scope: !662, file: !663, discriminator: 0)
!666 = !DILocation(line: 172, column: 5, scope: !665)
!667 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.get_y_coord", scope: null, file: !663, line: 174, type: !5, scopeLine: 174, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!668 = !DILocation(line: 175, column: 12, scope: !669)
!669 = !DILexicalBlockFile(scope: !667, file: !663, discriminator: 0)
!670 = !DILocation(line: 175, column: 5, scope: !669)
!671 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval", scope: null, file: !663, line: 187, type: !5, scopeLine: 187, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!672 = !DILocation(line: 187, column: 23, scope: !673)
!673 = !DILexicalBlockFile(scope: !671, file: !663, discriminator: 0)
!674 = !DILocation(line: 188, column: 9, scope: !673)
!675 = !DILocation(line: 188, column: 20, scope: !673)
!676 = !DILocation(line: 188, column: 5, scope: !673)
!677 = !DILocation(line: 191, column: 23, scope: !673)
!678 = !DILocation(line: 191, column: 20, scope: !673)
!679 = !DILocation(line: 191, column: 9, scope: !673)
!680 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start", scope: null, file: !663, line: 383, type: !5, scopeLine: 383, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!681 = !DILocation(line: 386, column: 5, scope: !682)
!682 = !DILexicalBlockFile(scope: !680, file: !663, discriminator: 0)
!683 = !DILocation(line: 384, column: 72, scope: !682)
!684 = !DILocation(line: 384, column: 59, scope: !682)
!685 = !DILocation(line: 384, column: 46, scope: !682)
!686 = !DILocation(line: 384, column: 33, scope: !682)
!687 = !DILocation(line: 384, column: 19, scope: !682)
!688 = !DILocation(line: 384, column: 5, scope: !682)
!689 = !DILocation(line: 383, column: 32, scope: !682)
!690 = !DILocation(line: 383, column: 21, scope: !682)
!691 = !DILocation(line: 386, column: 26, scope: !682)
!692 = !DILocation(line: 388, column: 28, scope: !682)
!693 = !DILocation(line: 388, column: 17, scope: !682)
!694 = !DILocation(line: 389, column: 25, scope: !682)
!695 = !DILocation(line: 389, column: 23, scope: !682)
!696 = !DILocation(line: 391, column: 38, scope: !682)
!697 = !DILocation(line: 391, column: 20, scope: !682)
!698 = !DILocation(line: 391, column: 18, scope: !682)
!699 = !DILocation(line: 393, column: 7, scope: !682)
!700 = !DILocation(line: 395, column: 17, scope: !682)
!701 = !DILocation(line: 395, column: 15, scope: !682)
!702 = !DILocation(line: 397, column: 15, scope: !682)
!703 = !DILocation(line: 397, column: 13, scope: !682)
!704 = !DILocation(line: 398, column: 15, scope: !682)
!705 = !DILocation(line: 398, column: 25, scope: !682)
!706 = !DILocation(line: 398, column: 23, scope: !682)
!707 = !DILocation(line: 398, column: 31, scope: !682)
!708 = !DILocation(line: 398, column: 13, scope: !682)
!709 = !DILocation(line: 401, column: 10, scope: !682)
!710 = !DILocation(line: 401, column: 17, scope: !682)
!711 = !DILocation(line: 401, column: 14, scope: !682)
!712 = !DILocation(line: 401, column: 5, scope: !682)
!713 = !DILocation(line: 403, column: 48, scope: !682)
!714 = !DILocation(line: 403, column: 26, scope: !682)
!715 = !DILocation(line: 404, column: 26, scope: !682)
!716 = !DILocation(line: 404, column: 18, scope: !682)
!717 = !DILocation(line: 407, column: 48, scope: !682)
!718 = !DILocation(line: 407, column: 26, scope: !682)
!719 = !DILocation(line: 408, column: 27, scope: !682)
!720 = !DILocation(line: 408, column: 18, scope: !682)
!721 = !DILocation(line: 411, column: 14, scope: !682)
!722 = !DILocation(line: 414, column: 14, scope: !682)
!723 = !DILocation(line: 414, column: 11, scope: !682)
!724 = !DILocation(line: 414, column: 5, scope: !682)
!725 = !DILocation(line: 416, column: 44, scope: !682)
!726 = !DILocation(line: 416, column: 75, scope: !682)
!727 = !DILocation(line: 416, column: 59, scope: !682)
!728 = !DILocation(line: 416, column: 25, scope: !682)
!729 = !DILocation(line: 416, column: 23, scope: !682)
!730 = !DILocation(line: 418, column: 41, scope: !682)
!731 = !DILocation(line: 418, column: 23, scope: !682)
!732 = !DILocation(line: 419, column: 9, scope: !682)
!733 = !DILocation(line: 425, column: 44, scope: !682)
!734 = !DILocation(line: 425, column: 23, scope: !682)
!735 = !DILocation(line: 426, column: 41, scope: !682)
!736 = !DILocation(line: 426, column: 23, scope: !682)
!737 = !DILocation(line: 427, column: 9, scope: !682)
!738 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x", scope: null, file: !663, line: 448, type: !5, scopeLine: 448, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!739 = !DILocation(line: 448, column: 31, scope: !740)
!740 = !DILexicalBlockFile(scope: !738, file: !663, discriminator: 0)
!741 = !DILocation(line: 453, column: 5, scope: !740)
!742 = !DILocation(line: 456, column: 19, scope: !740)
!743 = !DILocation(line: 456, column: 17, scope: !740)
!744 = !DILocation(line: 461, column: 5, scope: !740)
!745 = !DILocation(line: 462, column: 28, scope: !740)
!746 = !DILocation(line: 462, column: 5, scope: !740)
!747 = !DILocation(line: 463, column: 5, scope: !740)
!748 = !DILocation(line: 464, column: 9, scope: !740)
!749 = !DILocation(line: 464, column: 10, scope: !740)
!750 = !DILocation(line: 464, column: 7, scope: !740)
!751 = !DILocation(line: 448, column: 1, scope: !740)
!752 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_send_data", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_send_data", scope: null, file: !663, line: 476, type: !5, scopeLine: 476, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!753 = !DILocation(line: 494, column: 9, scope: !754)
!754 = !DILexicalBlockFile(scope: !752, file: !663, discriminator: 0)
!755 = !DILocation(line: 478, column: 9, scope: !754)
!756 = !DILocation(line: 478, column: 13, scope: !754)
!757 = !DILocation(line: 478, column: 11, scope: !754)
!758 = !DILocation(line: 478, column: 5, scope: !754)
!759 = !DILocation(line: 479, column: 9, scope: !754)
!760 = !DILocation(line: 480, column: 32, scope: !754)
!761 = !DILocation(line: 480, column: 9, scope: !754)
!762 = !DILocation(line: 481, column: 17, scope: !754)
!763 = !DILocation(line: 481, column: 15, scope: !754)
!764 = !DILocation(line: 481, column: 9, scope: !754)
!765 = !DILocation(line: 482, column: 13, scope: !754)
!766 = !DILocation(line: 483, column: 51, scope: !754)
!767 = !DILocation(line: 483, column: 29, scope: !754)
!768 = !DILocation(line: 483, column: 27, scope: !754)
!769 = !DILocation(line: 485, column: 13, scope: !754)
!770 = !DILocation(line: 486, column: 51, scope: !754)
!771 = !DILocation(line: 486, column: 29, scope: !754)
!772 = !DILocation(line: 486, column: 27, scope: !754)
!773 = !DILocation(line: 488, column: 13, scope: !754)
!774 = !DILocation(line: 488, column: 14, scope: !754)
!775 = !DILocation(line: 488, column: 11, scope: !754)
!776 = !DILocation(line: 494, column: 30, scope: !754)
!777 = !DILocation(line: 496, column: 14, scope: !754)
!778 = !DILocation(line: 496, column: 25, scope: !754)
!779 = !DILocation(line: 496, column: 22, scope: !754)
!780 = !DILocation(line: 496, column: 9, scope: !754)
!781 = !DILocation(line: 497, column: 13, scope: !754)
!782 = !DILocation(line: 498, column: 13, scope: !754)
!783 = !DILocation(line: 499, column: 13, scope: !754)
!784 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl", scope: null, file: !663, line: 505, type: !5, scopeLine: 505, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!785 = !DILocation(line: 524, column: 13, scope: !786)
!786 = !DILexicalBlockFile(scope: !784, file: !663, discriminator: 0)
!787 = !DILocation(line: 506, column: 14, scope: !786)
!788 = !DILocation(line: 506, column: 11, scope: !786)
!789 = !DILocation(line: 506, column: 5, scope: !786)
!790 = !DILocation(line: 508, column: 9, scope: !786)
!791 = !DILocation(line: 509, column: 32, scope: !786)
!792 = !DILocation(line: 509, column: 9, scope: !786)
!793 = !DILocation(line: 510, column: 9, scope: !786)
!794 = !DILocation(line: 514, column: 13, scope: !786)
!795 = !DILocation(line: 514, column: 17, scope: !786)
!796 = !DILocation(line: 514, column: 15, scope: !786)
!797 = !DILocation(line: 514, column: 9, scope: !786)
!798 = !DILocation(line: 518, column: 13, scope: !786)
!799 = !DILocation(line: 519, column: 36, scope: !786)
!800 = !DILocation(line: 519, column: 13, scope: !786)
!801 = !DILocation(line: 520, column: 13, scope: !786)
!802 = !DILocation(line: 524, column: 34, scope: !786)
!803 = !DILocation(line: 526, column: 18, scope: !786)
!804 = !DILocation(line: 526, column: 29, scope: !786)
!805 = !DILocation(line: 526, column: 26, scope: !786)
!806 = !DILocation(line: 526, column: 13, scope: !786)
!807 = !DILocation(line: 529, column: 17, scope: !786)
!808 = !DILocation(line: 530, column: 17, scope: !786)
!809 = !DILocation(line: 531, column: 17, scope: !786)
!810 = !DILocation(line: 534, column: 17, scope: !786)
!811 = !DILocation(line: 535, column: 40, scope: !786)
!812 = !DILocation(line: 535, column: 17, scope: !786)
!813 = !DILocation(line: 536, column: 17, scope: !786)
!814 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.d2h_configure", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.d2h_configure", scope: null, file: !663, line: 593, type: !5, scopeLine: 593, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!815 = !DILocation(line: 617, column: 26, scope: !816)
!816 = !DILexicalBlockFile(scope: !814, file: !663, discriminator: 0)
!817 = !DILocation(line: 612, column: 47, scope: !816)
!818 = !DILocation(line: 612, column: 27, scope: !816)
!819 = !DILocation(line: 602, column: 5, scope: !816)
!820 = !DILocation(line: 601, column: 5, scope: !816)
!821 = !DILocation(line: 599, column: 5, scope: !816)
!822 = !DILocation(line: 598, column: 5, scope: !816)
!823 = !DILocation(line: 596, column: 5, scope: !816)
!824 = !DILocation(line: 595, column: 5, scope: !816)
!825 = !DILocation(line: 593, column: 86, scope: !816)
!826 = !DILocation(line: 593, column: 70, scope: !816)
!827 = !DILocation(line: 593, column: 60, scope: !816)
!828 = !DILocation(line: 593, column: 52, scope: !816)
!829 = !DILocation(line: 593, column: 44, scope: !816)
!830 = !DILocation(line: 593, column: 35, scope: !816)
!831 = !DILocation(line: 593, column: 26, scope: !816)
!832 = !DILocation(line: 593, column: 18, scope: !816)
!833 = !DILocation(line: 595, column: 26, scope: !816)
!834 = !DILocation(line: 596, column: 26, scope: !816)
!835 = !DILocation(line: 598, column: 23, scope: !816)
!836 = !DILocation(line: 599, column: 23, scope: !816)
!837 = !DILocation(line: 599, column: 28, scope: !816)
!838 = !DILocation(line: 599, column: 26, scope: !816)
!839 = !DILocation(line: 599, column: 29, scope: !816)
!840 = !DILocation(line: 601, column: 24, scope: !816)
!841 = !DILocation(line: 602, column: 24, scope: !816)
!842 = !DILocation(line: 602, column: 29, scope: !816)
!843 = !DILocation(line: 602, column: 27, scope: !816)
!844 = !DILocation(line: 602, column: 30, scope: !816)
!845 = !DILocation(line: 611, column: 20, scope: !816)
!846 = !DILocation(line: 612, column: 11, scope: !816)
!847 = !DILocation(line: 612, column: 18, scope: !816)
!848 = !DILocation(line: 612, column: 15, scope: !816)
!849 = !DILocation(line: 612, column: 32, scope: !816)
!850 = !DILocation(line: 612, column: 39, scope: !816)
!851 = !DILocation(line: 612, column: 36, scope: !816)
!852 = !DILocation(line: 612, column: 52, scope: !816)
!853 = !DILocation(line: 612, column: 59, scope: !816)
!854 = !DILocation(line: 612, column: 56, scope: !816)
!855 = !DILocation(line: 612, column: 5, scope: !816)
!856 = !DILocation(line: 613, column: 24, scope: !816)
!857 = !DILocation(line: 616, column: 15, scope: !816)
!858 = !DILocation(line: 617, column: 11, scope: !816)
!859 = !DILocation(line: 617, column: 18, scope: !816)
!860 = !DILocation(line: 617, column: 15, scope: !816)
!861 = !DILocation(line: 617, column: 30, scope: !816)
!862 = !DILocation(line: 617, column: 5, scope: !816)
!863 = !DILocation(line: 618, column: 19, scope: !816)
!864 = !DILocation(line: 621, column: 9, scope: !816)
!865 = !DILocation(line: 621, column: 5, scope: !816)
!866 = !DILocation(line: 627, column: 9, scope: !816)
!867 = !DILocation(line: 629, column: 13, scope: !816)
!868 = !DILocation(line: 629, column: 25, scope: !816)
!869 = !DILocation(line: 629, column: 21, scope: !816)
!870 = !DILocation(line: 629, column: 9, scope: !816)
!871 = !DILocation(line: 632, column: 13, scope: !816)
!872 = !DILocation(line: 636, column: 13, scope: !816)
!873 = !DILocation(line: 641, column: 9, scope: !816)
!874 = !DILocation(line: 646, column: 13, scope: !816)
!875 = !DILocation(line: 646, column: 9, scope: !816)
!876 = !DILocation(line: 647, column: 30, scope: !816)
!877 = !DILocation(line: 647, column: 35, scope: !816)
!878 = !DILocation(line: 647, column: 46, scope: !816)
!879 = !DILocation(line: 647, column: 50, scope: !816)
!880 = !DILocation(line: 647, column: 54, scope: !816)
!881 = !DILocation(line: 647, column: 57, scope: !816)
!882 = !DILocation(line: 647, column: 60, scope: !816)
!883 = !DILocation(line: 647, column: 63, scope: !816)
!884 = !DILocation(line: 647, column: 13, scope: !816)
!885 = !DILocation(line: 661, column: 9, scope: !816)
!886 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit", scope: null, file: !623, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!887 = !DILocation(line: 43, column: 3, scope: !888)
!888 = !DILexicalBlockFile(scope: !886, file: !623, discriminator: 0)
!889 = !DILocation(line: 41, column: 3, scope: !888)
!890 = !DILocation(line: 40, column: 3, scope: !888)
!891 = !DILocation(line: 39, column: 9, scope: !888)
!892 = !DILocation(line: 40, column: 23, scope: !888)
!893 = !DILocation(line: 41, column: 70, scope: !888)
!894 = !DILocation(line: 41, column: 68, scope: !888)
!895 = !DILocation(line: 43, column: 27, scope: !888)
!896 = !DILocation(line: 43, column: 15, scope: !888)
!897 = !DILocation(line: 44, column: 15, scope: !888)
!898 = !DILocation(line: 44, column: 21, scope: !888)
!899 = !DILocation(line: 44, column: 27, scope: !888)
!900 = !DILocation(line: 44, column: 3, scope: !888)
!901 = !DILocation(line: 39, column: 1, scope: !888)
!902 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord", scope: null, file: !640, line: 4, type: !5, scopeLine: 4, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!903 = !DILocation(line: 5, column: 10, scope: !904)
!904 = !DILexicalBlockFile(scope: !902, file: !640, discriminator: 0)
!905 = !DILocation(line: 5, column: 67, scope: !904)
!906 = !DILocation(line: 5, column: 3, scope: !904)
!907 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord", scope: null, file: !640, line: 8, type: !5, scopeLine: 8, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!908 = !DILocation(line: 9, column: 10, scope: !909)
!909 = !DILexicalBlockFile(scope: !907, file: !640, discriminator: 0)
!910 = !DILocation(line: 9, column: 67, scope: !909)
!911 = !DILocation(line: 9, column: 3, scope: !909)
!912 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord", scope: null, file: !651, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!913 = !DILocation(line: 50, column: 3, scope: !914)
!914 = !DILexicalBlockFile(scope: !912, file: !651, discriminator: 0)
!915 = !DILocation(line: 43, column: 21, scope: !914)
!916 = !DILocation(line: 50, column: 57, scope: !914)
!917 = !DILocation(line: 50, column: 68, scope: !914)
!918 = !DILocation(line: 50, column: 41, scope: !914)
!919 = !DILocation(line: 50, column: 19, scope: !914)
!920 = !DILocation(line: 52, column: 10, scope: !914)
!921 = !DILocation(line: 52, column: 18, scope: !914)
!922 = !DILocation(line: 48, column: 22, scope: !914)
!923 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr", linkageName: "sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr", scope: null, file: !924, line: 11, type: !5, scopeLine: 11, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!924 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/input_queue_config.csl", directory: "")
!925 = !DILocation(line: 11, column: 32, scope: !926)
!926 = !DILexicalBlockFile(scope: !923, file: !924, discriminator: 0)
!927 = !DILocation(line: 12, column: 80, scope: !926)
!928 = !DILocation(line: 12, column: 69, scope: !926)
!929 = !DILocation(line: 12, column: 39, scope: !926)
!930 = !DILocation(line: 12, column: 3, scope: !926)
!931 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue", linkageName: "sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue", scope: null, file: !924, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!932 = !DILocation(line: 46, column: 3, scope: !933)
!933 = !DILexicalBlockFile(scope: !931, file: !924, discriminator: 0)
!934 = !DILocation(line: 45, column: 3, scope: !933)
!935 = !DILocation(line: 39, column: 42, scope: !933)
!936 = !DILocation(line: 39, column: 34, scope: !933)
!937 = !DILocation(line: 39, column: 24, scope: !933)
!938 = !DILocation(line: 45, column: 44, scope: !933)
!939 = !DILocation(line: 45, column: 16, scope: !933)
!940 = !DILocation(line: 46, column: 30, scope: !933)
!941 = !DILocation(line: 46, column: 18, scope: !933)
!942 = !DILocation(line: 56, column: 9, scope: !933)
!943 = !DILocation(line: 56, column: 5, scope: !933)
!944 = !DILocation(line: 58, column: 13, scope: !933)
!945 = !DILocation(line: 58, column: 17, scope: !933)
!946 = !DILocation(line: 58, column: 11, scope: !933)
!947 = !DILocation(line: 61, column: 13, scope: !933)
!948 = !DILocation(line: 61, column: 17, scope: !933)
!949 = !DILocation(line: 61, column: 11, scope: !933)
!950 = !DILocation(line: 66, column: 9, scope: !933)
!951 = !DILocation(line: 66, column: 13, scope: !933)
!952 = !DILocation(line: 66, column: 7, scope: !933)
!953 = !DILocation(line: 68, column: 9, scope: !933)
!954 = !DILocation(line: 68, column: 24, scope: !933)
!955 = !DILocation(line: 68, column: 13, scope: !933)
!956 = !DILocation(line: 68, column: 7, scope: !933)
!957 = !DILocation(line: 70, column: 15, scope: !933)
!958 = !DILocation(line: 70, column: 21, scope: !933)
!959 = !DILocation(line: 70, column: 3, scope: !933)
!960 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr", linkageName: "sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr", scope: null, file: !961, line: 11, type: !5, scopeLine: 11, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!961 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/output_queue_config.csl", directory: "")
!962 = !DILocation(line: 11, column: 33, scope: !963)
!963 = !DILexicalBlockFile(scope: !960, file: !961, discriminator: 0)
!964 = !DILocation(line: 12, column: 82, scope: !963)
!965 = !DILocation(line: 12, column: 40, scope: !963)
!966 = !DILocation(line: 12, column: 3, scope: !963)
!967 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue", linkageName: "sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue", scope: null, file: !961, line: 31, type: !5, scopeLine: 31, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!968 = !DILocation(line: 38, column: 3, scope: !969)
!969 = !DILexicalBlockFile(scope: !967, file: !961, discriminator: 0)
!970 = !DILocation(line: 37, column: 3, scope: !969)
!971 = !DILocation(line: 31, column: 35, scope: !969)
!972 = !DILocation(line: 31, column: 25, scope: !969)
!973 = !DILocation(line: 37, column: 45, scope: !969)
!974 = !DILocation(line: 37, column: 16, scope: !969)
!975 = !DILocation(line: 38, column: 30, scope: !969)
!976 = !DILocation(line: 38, column: 18, scope: !969)
!977 = !DILocation(line: 41, column: 9, scope: !969)
!978 = !DILocation(line: 41, column: 13, scope: !969)
!979 = !DILocation(line: 41, column: 7, scope: !969)
!980 = !DILocation(line: 43, column: 9, scope: !969)
!981 = !DILocation(line: 43, column: 24, scope: !969)
!982 = !DILocation(line: 43, column: 13, scope: !969)
!983 = !DILocation(line: 43, column: 27, scope: !969)
!984 = !DILocation(line: 43, column: 7, scope: !969)
!985 = !DILocation(line: 45, column: 15, scope: !969)
!986 = !DILocation(line: 45, column: 21, scope: !969)
!987 = !DILocation(line: 45, column: 3, scope: !969)
!988 = !DILocation(line: 31, column: 1, scope: !969)
!989 = distinct !DISubprogram(name: ".get_tensor_ptr", linkageName: ".get_tensor_ptr", scope: null, file: !4, line: 1, type: !5, scopeLine: 1, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!990 = !DILocation(line: 1, column: 1, scope: !991)
!991 = !DILexicalBlockFile(scope: !989, file: !4, discriminator: 0)
!992 = distinct !DISubprogram(name: "__generic0sys_mod.sys_mod.tile_config.queue_flush.exit", linkageName: "__generic0sys_mod.sys_mod.tile_config.queue_flush.exit", scope: null, file: !993, line: 12, type: !5, scopeLine: 12, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!993 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/queue_flush.csl", directory: "")
!994 = !DILocation(line: 24, column: 3, scope: !995)
!995 = !DILexicalBlockFile(scope: !992, file: !993, discriminator: 0)
!996 = !DILocation(line: 12, column: 1, scope: !995)
!997 = distinct !DISubprogram(name: "__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position", linkageName: "__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position", scope: null, file: !998, line: 30, type: !5, scopeLine: 30, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!998 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/switch_config.csl", directory: "")
!999 = !DILocation(line: 34, column: 3, scope: !1000)
!1000 = !DILexicalBlockFile(scope: !997, file: !998, discriminator: 0)
!1001 = !DILocation(line: 32, column: 3, scope: !1000)
!1002 = !DILocation(line: 30, column: 27, scope: !1000)
!1003 = !DILocation(line: 33, column: 7, scope: !1000)
!1004 = !DILocation(line: 34, column: 36, scope: !1000)
!1005 = !DILocation(line: 34, column: 24, scope: !1000)
!1006 = !DILocation(line: 35, column: 3, scope: !1000)
!1007 = !DILocation(line: 35, column: 18, scope: !1000)
!1008 = !DILocation(line: 36, column: 15, scope: !1000)
!1009 = !DILocation(line: 36, column: 21, scope: !1000)
!1010 = !DILocation(line: 36, column: 3, scope: !1000)
!1011 = !DILocation(line: 30, column: 1, scope: !1000)
!1012 = distinct !DISubprogram(name: "__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", linkageName: "__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", scope: null, file: !1013, line: 96, type: !5, scopeLine: 96, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1013 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/color_config.csl", directory: "")
!1014 = !DILocation(line: 99, column: 3, scope: !1015)
!1015 = !DILexicalBlockFile(scope: !1012, file: !1013, discriminator: 0)
!1016 = !DILocation(line: 98, column: 3, scope: !1015)
!1017 = !DILocation(line: 96, column: 17, scope: !1015)
!1018 = !DILocation(line: 98, column: 16, scope: !1015)
!1019 = !DILocation(line: 99, column: 29, scope: !1015)
!1020 = !DILocation(line: 99, column: 17, scope: !1015)
!1021 = !DILocation(line: 100, column: 13, scope: !1015)
!1022 = !DILocation(line: 100, column: 21, scope: !1015)
!1023 = !DILocation(line: 100, column: 11, scope: !1015)
!1024 = !DILocation(line: 104, column: 7, scope: !1015)
!1025 = !DILocation(line: 104, column: 50, scope: !1015)
!1026 = !DILocation(line: 104, column: 18, scope: !1015)
!1027 = !DILocation(line: 104, column: 15, scope: !1015)
!1028 = !DILocation(line: 121, column: 7, scope: !1015)
!1029 = !DILocation(line: 121, column: 50, scope: !1015)
!1030 = !DILocation(line: 121, column: 18, scope: !1015)
!1031 = !DILocation(line: 121, column: 15, scope: !1015)
!1032 = !DILocation(line: 128, column: 15, scope: !1015)
!1033 = !DILocation(line: 128, column: 21, scope: !1015)
!1034 = !DILocation(line: 128, column: 3, scope: !1015)
!1035 = !DILocation(line: 96, column: 1, scope: !1015)
!1036 = distinct !DISubprogram(name: "__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", linkageName: "__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", scope: null, file: !1013, line: 96, type: !5, scopeLine: 96, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1037 = !DILocation(line: 99, column: 3, scope: !1038)
!1038 = !DILexicalBlockFile(scope: !1036, file: !1013, discriminator: 0)
!1039 = !DILocation(line: 98, column: 3, scope: !1038)
!1040 = !DILocation(line: 96, column: 17, scope: !1038)
!1041 = !DILocation(line: 98, column: 16, scope: !1038)
!1042 = !DILocation(line: 99, column: 29, scope: !1038)
!1043 = !DILocation(line: 99, column: 17, scope: !1038)
!1044 = !DILocation(line: 100, column: 13, scope: !1038)
!1045 = !DILocation(line: 100, column: 21, scope: !1038)
!1046 = !DILocation(line: 100, column: 11, scope: !1038)
!1047 = !DILocation(line: 104, column: 7, scope: !1038)
!1048 = !DILocation(line: 104, column: 50, scope: !1038)
!1049 = !DILocation(line: 104, column: 18, scope: !1038)
!1050 = !DILocation(line: 104, column: 15, scope: !1038)
!1051 = !DILocation(line: 121, column: 7, scope: !1038)
!1052 = !DILocation(line: 121, column: 50, scope: !1038)
!1053 = !DILocation(line: 121, column: 18, scope: !1038)
!1054 = !DILocation(line: 121, column: 15, scope: !1038)
!1055 = !DILocation(line: 128, column: 15, scope: !1038)
!1056 = !DILocation(line: 128, column: 21, scope: !1038)
!1057 = !DILocation(line: 128, column: 3, scope: !1038)
!1058 = !DILocation(line: 96, column: 1, scope: !1038)
!1059 = distinct !DISubprogram(name: "__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", linkageName: "__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", scope: null, file: !1013, line: 60, type: !5, scopeLine: 60, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1060 = !DILocation(line: 61, column: 3, scope: !1061)
!1061 = !DILexicalBlockFile(scope: !1059, file: !1013, discriminator: 0)
!1062 = !DILocation(line: 60, column: 46, scope: !1061)
!1063 = !DILocation(line: 61, column: 16, scope: !1061)
!1064 = !DILocation(line: 72, column: 5, scope: !1061)
!1065 = !DILocation(line: 72, column: 12, scope: !1061)
!1066 = !DILocation(line: 74, column: 10, scope: !1061)
!1067 = !DILocation(line: 74, column: 3, scope: !1061)
!1068 = distinct !DISubprogram(name: "__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes", linkageName: "__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes", scope: null, file: !1013, line: 77, type: !5, scopeLine: 77, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1069 = !DILocation(line: 78, column: 3, scope: !1070)
!1070 = !DILexicalBlockFile(scope: !1068, file: !1013, discriminator: 0)
!1071 = !DILocation(line: 77, column: 46, scope: !1070)
!1072 = !DILocation(line: 78, column: 16, scope: !1070)
!1073 = !DILocation(line: 86, column: 5, scope: !1070)
!1074 = !DILocation(line: 86, column: 12, scope: !1070)
!1075 = !DILocation(line: 91, column: 10, scope: !1070)
!1076 = !DILocation(line: 91, column: 3, scope: !1070)
!1077 = distinct !DISubprogram(name: "__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", linkageName: "__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", scope: null, file: !1013, line: 60, type: !5, scopeLine: 60, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1078 = !DILocation(line: 61, column: 3, scope: !1079)
!1079 = !DILexicalBlockFile(scope: !1077, file: !1013, discriminator: 0)
!1080 = !DILocation(line: 60, column: 46, scope: !1079)
!1081 = !DILocation(line: 61, column: 16, scope: !1079)
!1082 = !DILocation(line: 63, column: 5, scope: !1079)
!1083 = !DILocation(line: 63, column: 12, scope: !1079)
!1084 = !DILocation(line: 74, column: 10, scope: !1079)
!1085 = !DILocation(line: 74, column: 3, scope: !1079)
!1086 = distinct !DISubprogram(name: "__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction", linkageName: "__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction", scope: null, file: !1013, line: 52, type: !5, scopeLine: 52, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1087 = !DILocation(line: 55, column: 3, scope: !1088)
!1088 = !DILexicalBlockFile(scope: !1086, file: !1013, discriminator: 0)
!1089 = !DILocation(line: 54, column: 3, scope: !1088)
!1090 = !DILocation(line: 52, column: 23, scope: !1088)
!1091 = !DILocation(line: 54, column: 16, scope: !1088)
!1092 = !DILocation(line: 55, column: 29, scope: !1088)
!1093 = !DILocation(line: 55, column: 17, scope: !1088)
!1094 = !DILocation(line: 56, column: 3, scope: !1088)
!1095 = !DILocation(line: 56, column: 11, scope: !1088)
!1096 = !DILocation(line: 57, column: 15, scope: !1088)
!1097 = !DILocation(line: 57, column: 21, scope: !1088)
!1098 = !DILocation(line: 57, column: 3, scope: !1088)
!1099 = !DILocation(line: 52, column: 1, scope: !1088)
!1100 = distinct !DISubprogram(name: "__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction", linkageName: "__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction", scope: null, file: !1013, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1101 = !DILocation(line: 23, column: 3, scope: !1102)
!1102 = !DILexicalBlockFile(scope: !1100, file: !1013, discriminator: 0)
!1103 = !DILocation(line: 22, column: 3, scope: !1102)
!1104 = !DILocation(line: 20, column: 21, scope: !1102)
!1105 = !DILocation(line: 22, column: 16, scope: !1102)
!1106 = !DILocation(line: 23, column: 29, scope: !1102)
!1107 = !DILocation(line: 23, column: 17, scope: !1102)
!1108 = !DILocation(line: 24, column: 3, scope: !1102)
!1109 = !DILocation(line: 24, column: 11, scope: !1102)
!1110 = !DILocation(line: 25, column: 15, scope: !1102)
!1111 = !DILocation(line: 25, column: 21, scope: !1102)
!1112 = !DILocation(line: 25, column: 3, scope: !1102)
!1113 = !DILocation(line: 20, column: 1, scope: !1102)
module asm ".section \22.pe_debug_info\22, \22\22"
module asm ".section \22.note\22, \22\22"
