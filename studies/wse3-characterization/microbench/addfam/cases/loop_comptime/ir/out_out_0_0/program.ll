; ModuleID = './layout.csl'
source_filename = "./layout.csl"
target datalayout = "e-ni:0-p:16:16-i1:16-i16:16-i32:32-i64:64-f32:32-f64:64"
target triple = "cs_sdr-cerebras-csos"

@a = internal global [64 x i16] zeroinitializer, align 4
@b = internal global [64 x i16] zeroinitializer, align 4
@c = internal global [64 x i16] zeroinitializer, align 4
@idx = internal global [4 x i16] zeroinitializer, align 4
@k = internal global [4 x i16] zeroinitializer, align 4
@p_a = internal global i16* getelementptr inbounds ([64 x i16], [64 x i16]* @a, i32 0, i32 0), align 4
@p_b = internal global i16* getelementptr inbounds ([64 x i16], [64 x i16]* @b, i32 0, i32 0), align 4
@p_c = internal global i16* getelementptr inbounds ([64 x i16], [64 x i16]* @c, i32 0, i32 0), align 4
@p_idx = internal global i16* getelementptr inbounds ([4 x i16], [4 x i16]* @idx, i32 0, i32 0), align 4
@p_k = internal global i16* getelementptr inbounds ([4 x i16], [4 x i16]* @k, i32 0, i32 0), align 4
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
@cte.init = internal constant [3 x i16] [i16 0, i16 16, i16 1], align 4
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
  %1 = alloca i16, i16 1, align 2, !dbg !7
  %2 = alloca i16, i16 1, align 2, !dbg !9
  %3 = alloca [3 x i16], i16 1, align 2, !dbg !10
  %4 = alloca [3 x i16], i16 1, align 2, !dbg !10
  %5 = bitcast [3 x i16]* %3 to i8*, !dbg !10
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* %5, i8* bitcast ([3 x i16]* @cte.init to i8*), i32 6, i1 false), !dbg !10
  %6 = bitcast [3 x i16]* %3 to i8*, !dbg !10
  %7 = bitcast [3 x i16]* %4 to i8*, !dbg !10
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* %7, i8* %6, i32 6, i1 false), !dbg !10
  store i16 0, i16* %2, align 2, !dbg !9
  store i16 0, i16* %1, align 2, !dbg !7
  br label %8, !dbg !7

8:                                                ; preds = %25, %0
  %9 = phi i16 [ 0, %25 ], [ 0, %0 ]
  %10 = icmp sgt i16 %9, 0, !dbg !7
  br i1 %10, label %11, label %13, !dbg !7

11:                                               ; preds = %8
  %12 = sub i16 %9, 1, !dbg !7
  br label %14, !dbg !7

13:                                               ; preds = %8
  br label %14, !dbg !7

14:                                               ; preds = %11, %13
  %15 = phi i16 [ %9, %13 ], [ %12, %11 ]
  br label %16, !dbg !7

16:                                               ; preds = %14
  %17 = icmp ne i16 %9, 0, !dbg !7
  br i1 %17, label %18, label %19, !dbg !7

18:                                               ; preds = %16
  br label %22, !dbg !7

19:                                               ; preds = %16
  %20 = load i16, i16* %2, align 2, !dbg !9
  %21 = icmp ult i16 %20, 16, !dbg !9
  br label %22, !dbg !7

22:                                               ; preds = %18, %19
  %23 = phi i1 [ %21, %19 ], [ false, %18 ]
  br label %24, !dbg !7

24:                                               ; preds = %22
  br i1 %23, label %25, label %39, !dbg !7

25:                                               ; preds = %24
  %26 = load i16, i16* %2, align 2, !dbg !11
  %27 = getelementptr [64 x i16], [64 x i16]* @a, i16 0, i16 %26, !dbg !12
  %28 = load i16, i16* %27, align 2, !dbg !12
  %29 = load i16, i16* %2, align 2, !dbg !13
  %30 = getelementptr [64 x i16], [64 x i16]* @b, i16 0, i16 %29, !dbg !14
  %31 = load i16, i16* %30, align 2, !dbg !14
  %32 = add i16 %28, %31, !dbg !15
  %33 = load i16, i16* %2, align 2, !dbg !16
  %34 = getelementptr [64 x i16], [64 x i16]* @c, i16 0, i16 %33, !dbg !17
  store i16 %32, i16* %34, align 2, !dbg !18
  %35 = load i16, i16* %1, align 2, !dbg !7
  %36 = add i16 %35, 1, !dbg !7
  store i16 %36, i16* %1, align 2, !dbg !7
  %37 = load i16, i16* %2, align 2, !dbg !9
  %38 = add i16 %37, 1, !dbg !9
  store i16 %38, i16* %2, align 2, !dbg !9
  br label %8, !dbg !7

39:                                               ; preds = %24
  %40 = icmp ne i16 %15, 0, !dbg !7
  br i1 %40, label %41, label %42, !dbg !7

41:                                               ; preds = %39
  br label %43, !dbg !7

42:                                               ; preds = %39
  call void @llvm.sdr.actvt.r(i16 9), !dbg !19
  br label %43, !dbg !7

43:                                               ; preds = %41, %42
  ret void, !dbg !7
}

define void @f_exit() #0 !dbg !20 {
  call void @sys_mod.unblock_cmd_stream(), !dbg !21
  ret void, !dbg !23
}

define internal void @sys_mod.sys_nop() !dbg !24 {
  ret void, !dbg !26
}

define internal void @sys_mod.unblock_cmd_stream() !dbg !28 {
  call void @sys_mod.sys_mod.unblock_cmd_stream(), !dbg !29
  ret void, !dbg !31
}

define internal void @sys_mod.sys_mod.unblock_cmd_stream() !dbg !32 {
  call void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream(), !dbg !34
  ret void, !dbg !36
}

define internal void @sys_mod.sys_mod.teardown_h2d() !dbg !37 {
  call void @llvm.sdr.actvt.r(i16 27), !dbg !38
  ret void, !dbg !40
}

define void @sys_mod.sys_mod.f_ublk_c22() #1 !dbg !41 {
  call void @sys_mod.sys_mod.unblock_cmd_stream(), !dbg !42
  ret void, !dbg !44
}

define internal void @sys_mod.sys_mod.teardown_d2h() !dbg !45 {
  call void @llvm.sdr.blk.r(i16 0), !dbg !46
  call void @llvm.sdr.actvt.r(i16 28), !dbg !48
  ret void, !dbg !49
}

define void @sys_mod.sys_mod.f_memcpyh2d() #2 !dbg !50 {
  %1 = alloca float, i16 1, align 4, !dbg !51
  %2 = alloca float, i16 1, align 4, !dbg !53
  %3 = alloca i16, i16 1, align 2, !dbg !54
  %4 = alloca i16, i16 1, align 2, !dbg !55
  %5 = alloca i16, i16 1, align 2, !dbg !56
  %6 = alloca i16, i16 1, align 2, !dbg !57
  %7 = alloca i16, i16 1, align 2, !dbg !58
  %8 = alloca i16, i16 1, align 2, !dbg !59
  %9 = alloca i16, i16 1, align 2, !dbg !60
  %10 = alloca i16, i16 1, align 2, !dbg !61
  %11 = alloca i16, i16 1, align 2, !dbg !62
  %12 = alloca i16, i16 1, align 2, !dbg !63
  %13 = alloca i16, i16 1, align 2, !dbg !64
  %14 = alloca i16*, i16 1, align 8, !dbg !65
  %15 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !66
  %16 = icmp eq i16 %15, 15, !dbg !67
  br i1 %16, label %17, label %18, !dbg !68

17:                                               ; preds = %0
  br label %19, !dbg !68

18:                                               ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !68
  br label %19, !dbg !68

19:                                               ; preds = %17, %18
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %14, align 8, !dbg !65
  %20 = load i16*, i16** %14, align 8, !dbg !69
  %21 = load i16, i16* %20, align 2, !dbg !70
  store i16 %21, i16* %13, align 2, !dbg !64
  %22 = load i16*, i16** %14, align 8, !dbg !71
  %23 = getelementptr i16, i16* %22, i16 1, !dbg !72
  %24 = load i16, i16* %23, align 2, !dbg !72
  store i16 %24, i16* %12, align 2, !dbg !63
  %25 = load i16*, i16** %14, align 8, !dbg !73
  %26 = getelementptr i16, i16* %25, i16 2, !dbg !74
  %27 = load i16, i16* %26, align 2, !dbg !74
  store i16 %27, i16* %11, align 2, !dbg !62
  %28 = load i16*, i16** %14, align 8, !dbg !75
  %29 = getelementptr i16, i16* %28, i16 3, !dbg !76
  %30 = load i16, i16* %29, align 2, !dbg !76
  store i16 %30, i16* %10, align 2, !dbg !61
  %31 = load i16*, i16** %14, align 8, !dbg !77
  %32 = getelementptr i16, i16* %31, i16 4, !dbg !78
  %33 = load i16, i16* %32, align 2, !dbg !78
  store i16 %33, i16* %9, align 2, !dbg !60
  %34 = load i16*, i16** %14, align 8, !dbg !79
  %35 = getelementptr i16, i16* %34, i16 5, !dbg !80
  %36 = load i16, i16* %35, align 2, !dbg !80
  store i16 %36, i16* %8, align 2, !dbg !59
  %37 = load i16*, i16** %14, align 8, !dbg !81
  %38 = getelementptr i16, i16* %37, i16 6, !dbg !82
  %39 = load i16, i16* %38, align 2, !dbg !82
  store i16 %39, i16* %7, align 2, !dbg !58
  %40 = load i16*, i16** %14, align 8, !dbg !83
  %41 = getelementptr i16, i16* %40, i16 7, !dbg !84
  %42 = load i16, i16* %41, align 2, !dbg !84
  store i16 %42, i16* %6, align 2, !dbg !57
  %43 = load i16*, i16** %14, align 8, !dbg !85
  %44 = getelementptr i16, i16* %43, i16 8, !dbg !86
  %45 = load i16, i16* %44, align 2, !dbg !86
  store i16 %45, i16* %5, align 2, !dbg !56
  %46 = load i16*, i16** %14, align 8, !dbg !87
  %47 = getelementptr i16, i16* %46, i16 9, !dbg !88
  %48 = load i16, i16* %47, align 2, !dbg !88
  store i16 %48, i16* %4, align 2, !dbg !55
  %49 = load i16*, i16** %14, align 8, !dbg !89
  %50 = getelementptr i16, i16* %49, i16 10, !dbg !90
  %51 = load i16, i16* %50, align 2, !dbg !90
  store i16 %51, i16* %3, align 2, !dbg !54
  %52 = load i16*, i16** %14, align 8, !dbg !91
  %53 = getelementptr i16, i16* %52, i16 12, !dbg !92
  %54 = load i16, i16* %53, align 2, !dbg !92
  %55 = zext i16 %54 to i32, !dbg !93
  %56 = load i16*, i16** %14, align 8, !dbg !94
  %57 = getelementptr i16, i16* %56, i16 11, !dbg !95
  %58 = load i16, i16* %57, align 2, !dbg !95
  %59 = zext i16 %58 to i32, !dbg !96
  %60 = add i32 %59, 16, !dbg !97
  %61 = shl i32 %55, %60, !dbg !98
  %62 = bitcast i32 %61 to float, !dbg !99
  store float %62, float* %2, align 4, !dbg !53
  %63 = load i16*, i16** %14, align 8, !dbg !100
  %64 = getelementptr i16, i16* %63, i16 14, !dbg !101
  %65 = load i16, i16* %64, align 2, !dbg !101
  %66 = zext i16 %65 to i32, !dbg !102
  %67 = load i16*, i16** %14, align 8, !dbg !103
  %68 = getelementptr i16, i16* %67, i16 13, !dbg !104
  %69 = load i16, i16* %68, align 2, !dbg !104
  %70 = zext i16 %69 to i32, !dbg !105
  %71 = add i32 %70, 16, !dbg !106
  %72 = shl i32 %66, %71, !dbg !107
  %73 = bitcast i32 %72 to float, !dbg !108
  store float %73, float* %1, align 4, !dbg !51
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !109
  %74 = load i16, i16* %13, align 2, !dbg !110
  store i16 %74, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !111
  %75 = load i16, i16* %12, align 2, !dbg !112
  store i16 %75, i16* @sys_mod.sys_mod.memcpyH2D_px, align 2, !dbg !113
  %76 = load i16, i16* %11, align 2, !dbg !114
  store i16 %76, i16* @sys_mod.sys_mod.memcpyH2D_py, align 2, !dbg !115
  %77 = load i16, i16* %10, align 2, !dbg !116
  store i16 %77, i16* @sys_mod.sys_mod.memcpyH2D_w, align 2, !dbg !117
  %78 = load i16, i16* %9, align 2, !dbg !118
  store i16 %78, i16* @sys_mod.sys_mod.memcpyH2D_h, align 2, !dbg !119
  %79 = load i16, i16* %8, align 2, !dbg !120
  store i16 %79, i16* @sys_mod.sys_mod.memcpyH2D_addr, align 2, !dbg !121
  %80 = load i16, i16* %7, align 2, !dbg !122
  store i16 %80, i16* @sys_mod.sys_mod.memcpyH2D_pe_length, align 2, !dbg !123
  %81 = load i16, i16* %6, align 2, !dbg !124
  store i16 %81, i16* @sys_mod.sys_mod.memcpyH2D_is_half, align 2, !dbg !125
  %82 = load i16, i16* %5, align 2, !dbg !126
  store i16 %82, i16* @sys_mod.sys_mod.memcpyH2D_memcpy_optype, align 2, !dbg !127
  %83 = load i16, i16* %4, align 2, !dbg !128
  store i16 %83, i16* @sys_mod.sys_mod.memcpyH2D_row_stride, align 2, !dbg !129
  %84 = load i16, i16* %3, align 2, !dbg !130
  store i16 %84, i16* @sys_mod.sys_mod.memcpyH2D_col_stride, align 2, !dbg !131
  %85 = load float, float* %2, align 4, !dbg !132
  store float %85, float* @sys_mod.sys_mod.memcpyH2D_one_over_row_stride, align 4, !dbg !133
  %86 = load float, float* %1, align 4, !dbg !134
  store float %86, float* @sys_mod.sys_mod.memcpyH2D_one_over_col_stride, align 4, !dbg !135
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !136
  call void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 0, i16 23, i1 true), !dbg !137
  call void @llvm.sdr.blk.r(i16 27), !dbg !138
  call void @llvm.sdr.oqflush(i16 0), !dbg !139
  store i1 true, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !140
  call void @llvm.sdr.blk.r(i16 0), !dbg !141
  ret void, !dbg !142
}

define void @sys_mod.sys_mod.f_memcpyd2h() #3 !dbg !143 {
  %1 = alloca i16, i16 1, align 2, !dbg !144
  %2 = alloca i16, i16 1, align 2, !dbg !146
  %3 = alloca i16, i16 1, align 2, !dbg !147
  %4 = alloca i16, i16 1, align 2, !dbg !148
  %5 = alloca i16, i16 1, align 2, !dbg !149
  %6 = alloca i16, i16 1, align 2, !dbg !150
  %7 = alloca i16, i16 1, align 2, !dbg !151
  %8 = alloca i16, i16 1, align 2, !dbg !152
  %9 = alloca i16*, i16 1, align 8, !dbg !153
  %10 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !154
  %11 = icmp eq i16 %10, 8, !dbg !155
  br i1 %11, label %12, label %13, !dbg !156

12:                                               ; preds = %0
  br label %14, !dbg !156

13:                                               ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !156
  br label %14, !dbg !156

14:                                               ; preds = %12, %13
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %9, align 8, !dbg !153
  %15 = load i16*, i16** %9, align 8, !dbg !157
  %16 = load i16, i16* %15, align 2, !dbg !158
  store i16 %16, i16* %8, align 2, !dbg !152
  %17 = load i16*, i16** %9, align 8, !dbg !159
  %18 = getelementptr i16, i16* %17, i16 1, !dbg !160
  %19 = load i16, i16* %18, align 2, !dbg !160
  store i16 %19, i16* %7, align 2, !dbg !151
  %20 = load i16*, i16** %9, align 8, !dbg !161
  %21 = getelementptr i16, i16* %20, i16 2, !dbg !162
  %22 = load i16, i16* %21, align 2, !dbg !162
  store i16 %22, i16* %6, align 2, !dbg !150
  %23 = load i16*, i16** %9, align 8, !dbg !163
  %24 = getelementptr i16, i16* %23, i16 3, !dbg !164
  %25 = load i16, i16* %24, align 2, !dbg !164
  store i16 %25, i16* %5, align 2, !dbg !149
  %26 = load i16*, i16** %9, align 8, !dbg !165
  %27 = getelementptr i16, i16* %26, i16 4, !dbg !166
  %28 = load i16, i16* %27, align 2, !dbg !166
  store i16 %28, i16* %4, align 2, !dbg !148
  %29 = load i16*, i16** %9, align 8, !dbg !167
  %30 = getelementptr i16, i16* %29, i16 5, !dbg !168
  %31 = load i16, i16* %30, align 2, !dbg !168
  store i16 %31, i16* %3, align 2, !dbg !147
  %32 = load i16*, i16** %9, align 8, !dbg !169
  %33 = getelementptr i16, i16* %32, i16 6, !dbg !170
  %34 = load i16, i16* %33, align 2, !dbg !170
  store i16 %34, i16* %2, align 2, !dbg !146
  %35 = load i16*, i16** %9, align 8, !dbg !171
  %36 = getelementptr i16, i16* %35, i16 7, !dbg !172
  %37 = load i16, i16* %36, align 2, !dbg !172
  store i16 %37, i16* %1, align 2, !dbg !144
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !173
  %38 = load i16, i16* %8, align 2, !dbg !174
  store i16 %38, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !175
  %39 = load i16, i16* %7, align 2, !dbg !176
  store i16 %39, i16* @sys_mod.sys_mod.memcpyD2H_px, align 2, !dbg !177
  %40 = load i16, i16* %6, align 2, !dbg !178
  store i16 %40, i16* @sys_mod.sys_mod.memcpyD2H_py, align 2, !dbg !179
  %41 = load i16, i16* %5, align 2, !dbg !180
  store i16 %41, i16* @sys_mod.sys_mod.memcpyD2H_w, align 2, !dbg !181
  %42 = load i16, i16* %4, align 2, !dbg !182
  store i16 %42, i16* @sys_mod.sys_mod.memcpyD2H_h, align 2, !dbg !183
  %43 = load i16, i16* %3, align 2, !dbg !184
  store i16 %43, i16* @sys_mod.sys_mod.memcpyD2H_addr, align 2, !dbg !185
  %44 = load i16, i16* %2, align 2, !dbg !186
  store i16 %44, i16* @sys_mod.sys_mod.memcpyD2H_pe_length, align 2, !dbg !187
  %45 = load i16, i16* %1, align 2, !dbg !188
  store i16 %45, i16* @sys_mod.sys_mod.memcpyD2H_is_half, align 2, !dbg !189
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !190
  %46 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !191
  call void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 0, i16 %46, i1 false), !dbg !192
  call void @llvm.sdr.oqflush(i16 0), !dbg !193
  store i1 false, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !194
  ret void, !dbg !195
}

define internal void @sys_mod.sys_mod.oq0_teardow_handler() !dbg !196 {
  %1 = load i1, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !197
  br i1 %1, label %2, label %17, !dbg !199

2:                                                ; preds = %0
  %3 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !200
  call void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 0, i16 %3), !dbg !201
  %4 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !202
  %5 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_px, align 2, !dbg !203
  %6 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_py, align 2, !dbg !204
  %7 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_w, align 2, !dbg !205
  %8 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_h, align 2, !dbg !206
  %9 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_addr, align 2, !dbg !207
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_pe_length, align 2, !dbg !208
  %11 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_is_half, align 2, !dbg !209
  %12 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_memcpy_optype, align 2, !dbg !210
  %13 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_row_stride, align 2, !dbg !211
  %14 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_col_stride, align 2, !dbg !212
  %15 = load float, float* @sys_mod.sys_mod.memcpyH2D_one_over_row_stride, align 4, !dbg !213
  %16 = load float, float* @sys_mod.sys_mod.memcpyH2D_one_over_col_stride, align 4, !dbg !214
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure(i16 %4, i16 %5, i16 %6, i16 %7, i16 %8, i16 %9, i16 %10, i16 %11, i16 %12, i16 %13, i16 %14, float %15, float %16), !dbg !215
  br label %26, !dbg !199

17:                                               ; preds = %0
  call void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 0, i16 21), !dbg !216
  %18 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !217
  %19 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_px, align 2, !dbg !218
  %20 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_py, align 2, !dbg !219
  %21 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_w, align 2, !dbg !220
  %22 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_h, align 2, !dbg !221
  %23 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_addr, align 2, !dbg !222
  %24 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_pe_length, align 2, !dbg !223
  %25 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_is_half, align 2, !dbg !224
  call void @sys_mod.sys_mod.memcpyd2h_mod.d2h_configure(i16 %18, i16 %19, i16 %20, i16 %21, i16 %22, i16 %23, i16 %24, i16 %25), !dbg !225
  br label %26, !dbg !199

26:                                               ; preds = %2, %17
  call void @__generic0sys_mod.sys_mod.tile_config.queue_flush.exit(), !dbg !226
  ret void, !dbg !199
}

define internal void @rpc_server(i32* %0) {
  %2 = load i32, i32* %0, align 4
  %3 = add i32 %2, 1
  %4 = getelementptr i32, i32* %0, i32 %3
  %5 = load i32, i32* %4, align 4
  switch i32 %5, label %6 [
    i32 6, label %7
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

define void @sys_mod.sys_mod.f_rpc(i16 %0) #4 !dbg !227 {
  %2 = alloca i16, i16 1, align 2, !dbg !228
  store i16 %0, i16* %2, align 2, !dbg !228
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !230
  %3 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !231
  %4 = icmp sge i16 %3, 4, !dbg !232
  br i1 %4, label %5, label %6, !dbg !233

5:                                                ; preds = %1
  br label %7, !dbg !233

6:                                                ; preds = %1
  call void asm sideeffect "hcf", ""(), !dbg !233
  br label %7, !dbg !233

7:                                                ; preds = %5, %6
  call void @rpc_server(i32* getelementptr inbounds ([32 x i32], [32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32, i32 0, i32 0)), !dbg !234
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !235
  ret void, !dbg !236
}

define internal void @sys_mod.sys_mod.sys_mod.stack_push(i16 %0) !dbg !237 {
  %2 = alloca i16*, i16 1, align 8, !dbg !239
  %3 = alloca i16, i16 1, align 2, !dbg !241
  store i16 %0, i16* %3, align 2, !dbg !241
  %4 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !242
  %5 = icmp slt i16 %4, 32, !dbg !243
  br i1 %5, label %6, label %7, !dbg !244

6:                                                ; preds = %1
  br label %8, !dbg !244

7:                                                ; preds = %1
  call void asm sideeffect "hcf", ""(), !dbg !244
  br label %8, !dbg !244

8:                                                ; preds = %6, %7
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %2, align 8, !dbg !239
  %9 = load i16, i16* %3, align 2, !dbg !245
  %10 = load i16*, i16** %2, align 8, !dbg !246
  %11 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !247
  %12 = getelementptr i16, i16* %10, i16 %11, !dbg !248
  store i16 %9, i16* %12, align 2, !dbg !249
  %13 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !250
  %14 = add i16 %13, 1, !dbg !251
  store i16 %14, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !252
  ret void, !dbg !253
}

define void @sys_mod.sys_mod.sys_mod.f_push(i16 %0, i16 %1) #5 !dbg !254 {
  %3 = alloca i16, i16 1, align 2, !dbg !255
  %4 = alloca i16, i16 1, align 2, !dbg !257
  store i16 %0, i16* %4, align 2, !dbg !257
  store i16 %1, i16* %3, align 2, !dbg !255
  %5 = load i16, i16* %4, align 2, !dbg !258
  call void @sys_mod.sys_mod.sys_mod.stack_push(i16 %5), !dbg !259
  ret void, !dbg !260
}

define internal void @sys_mod.sys_mod.sys_mod.block_cmd_stream() !dbg !261 {
  call void @llvm.sdr.blk.r(i16 1), !dbg !262
  ret void, !dbg !264
}

define internal void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream() !dbg !265 {
  call void @llvm.sdr.ublk.r(i16 1), !dbg !266
  ret void, !dbg !268
}

define void @sys_mod.sys_mod.sys_mod.f_sys_exit() #6 !dbg !269 {
  call void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream(), !dbg !270
  call void @sys_mod.sys_nop(), !dbg !272
  ret void, !dbg !273
}

define void @sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore(i32 %0) #7 !dbg !274 {
  %2 = alloca i32, i16 1, align 4, !dbg !275
  store i32 %0, i32* %2, align 4, !dbg !275
  ret void, !dbg !277
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord() !dbg !278 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord(), !dbg !280
  ret i16 %1, !dbg !282
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord() !dbg !283 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord(), !dbg !284
  ret i16 %1, !dbg !286
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval(i16 %0) !dbg !287 {
  %2 = alloca i16, i16 1, align 2, !dbg !288
  store i16 %0, i16* %2, align 2, !dbg !288
  %3 = load i16, i16* %2, align 2, !dbg !290
  %4 = icmp ult i16 %3, 24, !dbg !291
  br i1 %4, label %5, label %7, !dbg !292

5:                                                ; preds = %10, %11, %1
  %6 = phi i16 [ 0, %10 ], [ 0, %11 ], [ 1, %1 ]
  br label %12, !dbg !292

7:                                                ; preds = %1
  %8 = load i16, i16* %2, align 2, !dbg !293
  %9 = icmp eq i16 31, %8, !dbg !294
  br i1 %9, label %10, label %11, !dbg !295

10:                                               ; preds = %7
  br label %5, !dbg !295

11:                                               ; preds = %7
  call void asm sideeffect "hcf", ""(), !dbg !295
  br label %5, !dbg !295

12:                                               ; preds = %5
  %13 = phi i16 [ %6, %5 ]
  br label %14, !dbg !292

14:                                               ; preds = %12
  ret i16 %13, !dbg !292
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start(i16 %0, i16 %1, i16 %2) !dbg !296 {
  %4 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !297
  %5 = alloca i16, i16 1, align 2, !dbg !299
  %6 = alloca i16, i16 1, align 2, !dbg !300
  %7 = alloca i16, i16 1, align 2, !dbg !301
  store i16 %0, i16* %7, align 2, !dbg !301
  store i16 %1, i16* %6, align 2, !dbg !300
  store i16 %2, i16* %5, align 2, !dbg !299
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !302
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !302
  %10 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !302
  %11 = load i16, i16* %6, align 2, !dbg !303
  store i16 %11, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !304
  store i16 %8, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !304
  store i16 %9, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !304
  store i16 %10, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !304
  %12 = load i16, i16* %7, align 2, !dbg !305
  %13 = call i16* @.get_tensor_ptr(i16 %12), !dbg !306
  %14 = ptrtoint i16* %13 to i16, !dbg !307
  %15 = lshr i16 %14, 1, !dbg !307
  %16 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !297
  store i16 42, i16* %16, align 2, !dbg !297
  %17 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !297
  store i16 %15, i16* %17, align 2, !dbg !297
  %18 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !297
  store i16 143, i16* %18, align 2, !dbg !297
  %19 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !297
  store i16 16, i16* %19, align 2, !dbg !297
  %20 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !308
  %21 = load i16, i16* %20, align 2, !dbg !308
  %22 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !308
  %23 = load i16, i16* %22, align 2, !dbg !308
  %24 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !308
  %25 = load i16, i16* %24, align 2, !dbg !308
  %26 = load i16, i16* %6, align 2, !dbg !309
  %27 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !310
  store i16 %26, i16* %27, align 2, !dbg !310
  %28 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !310
  store i16 %21, i16* %28, align 2, !dbg !310
  %29 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !310
  store i16 %23, i16* %29, align 2, !dbg !310
  %30 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !310
  store i16 %25, i16* %30, align 2, !dbg !310
  %31 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !311
  %32 = load i16, i16* %31, align 2, !dbg !311
  %33 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !311
  %34 = load i16, i16* %33, align 2, !dbg !311
  %35 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !311
  %36 = load i16, i16* %35, align 2, !dbg !311
  %37 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !311
  %38 = load i16, i16* %37, align 2, !dbg !311
  store volatile i16 %32, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !312
  store volatile i16 %34, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !312
  store volatile i16 %36, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !312
  store volatile i16 %38, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !312
  call void asm sideeffect "nop", ""(), !dbg !312
  call void asm sideeffect "nop", ""(), !dbg !312
  %39 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !313
  %40 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !313
  %41 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !313
  %42 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !313
  %43 = and i16 %41, -193, !dbg !313
  %44 = or i16 %43, 128, !dbg !313
  %45 = and i16 %40, -64, !dbg !313
  %46 = or i16 %45, 27, !dbg !313
  store volatile i16 %39, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !314
  store volatile i16 %46, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !314
  store volatile i16 %44, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !314
  store volatile i16 %42, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !314
  call void asm sideeffect "nop", ""(), !dbg !314
  call void asm sideeffect "nop", ""(), !dbg !314
  %47 = load i16, i16* %5, align 2, !dbg !315
  %48 = icmp ult i16 0, %47, !dbg !316
  br i1 %48, label %49, label %50, !dbg !317

49:                                               ; preds = %3
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !318
  br label %51, !dbg !317

50:                                               ; preds = %3
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !319
  br label %51, !dbg !317

51:                                               ; preds = %49, %50
  ret void, !dbg !317
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream() !dbg !320 {
  call void @llvm.sdr.ublk.r(i16 1), !dbg !321
  ret void, !dbg !323
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7, i16 %8, i16 %9, i16 %10, float %11, float %12) !dbg !324 {
  %14 = alloca i16, i16 1, align 2, !dbg !325
  %15 = alloca i16, i16 1, align 2, !dbg !327
  %16 = alloca i16, i16 1, align 2, !dbg !328
  %17 = alloca i16, i16 1, align 2, !dbg !329
  %18 = alloca i16, i16 1, align 2, !dbg !330
  %19 = alloca i1, i16 1, align 1, !dbg !331
  %20 = alloca i16, i16 1, align 2, !dbg !332
  %21 = alloca i16, i16 1, align 2, !dbg !333
  %22 = alloca i16, i16 1, align 2, !dbg !334
  %23 = alloca i16, i16 1, align 2, !dbg !335
  %24 = alloca i16, i16 1, align 2, !dbg !336
  %25 = alloca float, i16 1, align 4, !dbg !337
  %26 = alloca float, i16 1, align 4, !dbg !338
  %27 = alloca i16, i16 1, align 2, !dbg !339
  %28 = alloca i16, i16 1, align 2, !dbg !340
  %29 = alloca i16, i16 1, align 2, !dbg !341
  %30 = alloca i16, i16 1, align 2, !dbg !342
  %31 = alloca i16, i16 1, align 2, !dbg !343
  %32 = alloca i16, i16 1, align 2, !dbg !344
  %33 = alloca i16, i16 1, align 2, !dbg !345
  %34 = alloca i16, i16 1, align 2, !dbg !346
  %35 = alloca i16, i16 1, align 2, !dbg !347
  %36 = alloca i16, i16 1, align 2, !dbg !348
  %37 = alloca i16, i16 1, align 2, !dbg !349
  store i16 %0, i16* %37, align 2, !dbg !349
  store i16 %1, i16* %36, align 2, !dbg !348
  store i16 %2, i16* %35, align 2, !dbg !347
  store i16 %3, i16* %34, align 2, !dbg !346
  store i16 %4, i16* %33, align 2, !dbg !345
  store i16 %5, i16* %32, align 2, !dbg !344
  store i16 %6, i16* %31, align 2, !dbg !343
  store i16 %7, i16* %30, align 2, !dbg !342
  store i16 %8, i16* %29, align 2, !dbg !341
  store i16 %9, i16* %28, align 2, !dbg !340
  store i16 %10, i16* %27, align 2, !dbg !339
  store float %11, float* %26, align 4, !dbg !338
  store float %12, float* %25, align 4, !dbg !337
  %38 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord(), !dbg !350
  store i16 %38, i16* %24, align 2, !dbg !336
  %39 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord(), !dbg !351
  store i16 %39, i16* %23, align 2, !dbg !335
  %40 = load i16, i16* %24, align 2, !dbg !352
  %41 = load i16, i16* %36, align 2, !dbg !353
  %42 = sub i16 %40, %41, !dbg !354
  store i16 %42, i16* %22, align 2, !dbg !334
  %43 = load i16, i16* %22, align 2, !dbg !355
  store i16 %43, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !356
  %44 = load i16, i16* %29, align 2, !dbg !357
  %45 = icmp eq i16 3, %44, !dbg !358
  br i1 %45, label %46, label %63, !dbg !359

46:                                               ; preds = %13
  %47 = load i16, i16* %22, align 2, !dbg !360
  %48 = sitofp i16 %47 to float, !dbg !361
  %49 = load float, float* %26, align 4, !dbg !362
  %50 = fmul float %48, %49, !dbg !363
  %51 = fptosi float %50 to i16, !dbg !364
  store i16 %51, i16* %21, align 2, !dbg !333
  %52 = load i16, i16* %22, align 2, !dbg !365
  %53 = load i16, i16* %21, align 2, !dbg !366
  %54 = load i16, i16* %28, align 2, !dbg !367
  %55 = mul i16 %53, %54, !dbg !368
  %56 = sub i16 %52, %55, !dbg !369
  store i16 %56, i16* %20, align 2, !dbg !332
  %57 = load i16, i16* %20, align 2, !dbg !370
  %58 = icmp ne i16 0, %57, !dbg !371
  br i1 %58, label %59, label %60, !dbg !372

59:                                               ; preds = %46
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !373
  br label %62, !dbg !372

60:                                               ; preds = %46
  %61 = load i16, i16* %21, align 2, !dbg !374
  store i16 %61, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !375
  br label %62, !dbg !372

62:                                               ; preds = %59, %60
  br label %63, !dbg !359

63:                                               ; preds = %62, %13
  %64 = load i16, i16* %22, align 2, !dbg !376
  %65 = icmp slt i16 %64, 0, !dbg !377
  br i1 %65, label %66, label %67, !dbg !378

66:                                               ; preds = %63
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !379
  br label %67, !dbg !378

67:                                               ; preds = %66, %63
  %68 = load i16, i16* %22, align 2, !dbg !380
  %69 = load i16, i16* %34, align 2, !dbg !381
  %70 = icmp sge i16 %68, %69, !dbg !382
  br i1 %70, label %71, label %72, !dbg !383

71:                                               ; preds = %67
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !384
  br label %72, !dbg !383

72:                                               ; preds = %71, %67
  store i1 false, i1* %19, align 1, !dbg !331
  %73 = load i16, i16* %29, align 2, !dbg !385
  %74 = icmp eq i16 3, %73, !dbg !386
  br i1 %74, label %75, label %94, !dbg !387

75:                                               ; preds = %72
  %76 = load i16, i16* %23, align 2, !dbg !388
  %77 = load i16, i16* %35, align 2, !dbg !389
  %78 = sub i16 %76, %77, !dbg !390
  %79 = sitofp i16 %78 to float, !dbg !391
  %80 = load float, float* %25, align 4, !dbg !392
  %81 = fmul float %79, %80, !dbg !393
  %82 = fptosi float %81 to i16, !dbg !394
  store i16 %82, i16* %18, align 2, !dbg !330
  %83 = load i16, i16* %23, align 2, !dbg !395
  %84 = load i16, i16* %35, align 2, !dbg !396
  %85 = sub i16 %83, %84, !dbg !397
  %86 = load i16, i16* %18, align 2, !dbg !398
  %87 = load i16, i16* %27, align 2, !dbg !399
  %88 = mul i16 %86, %87, !dbg !400
  %89 = sub i16 %85, %88, !dbg !401
  store i16 %89, i16* %17, align 2, !dbg !329
  %90 = load i16, i16* %17, align 2, !dbg !402
  %91 = icmp ne i16 0, %90, !dbg !403
  br i1 %91, label %92, label %93, !dbg !404

92:                                               ; preds = %75
  store i1 true, i1* %19, align 1, !dbg !405
  br label %93, !dbg !404

93:                                               ; preds = %92, %75
  br label %94, !dbg !387

94:                                               ; preds = %93, %72
  %95 = load i16, i16* %23, align 2, !dbg !406
  %96 = load i16, i16* %35, align 2, !dbg !407
  %97 = icmp slt i16 %95, %96, !dbg !408
  br i1 %97, label %98, label %99, !dbg !409

98:                                               ; preds = %94
  store i1 true, i1* %19, align 1, !dbg !410
  br label %99, !dbg !409

99:                                               ; preds = %98, %94
  %100 = load i16, i16* %23, align 2, !dbg !411
  %101 = load i16, i16* %35, align 2, !dbg !412
  %102 = load i16, i16* %33, align 2, !dbg !413
  %103 = add i16 %101, %102, !dbg !414
  %104 = icmp sge i16 %100, %103, !dbg !415
  br i1 %104, label %105, label %106, !dbg !416

105:                                              ; preds = %99
  store i1 true, i1* %19, align 1, !dbg !417
  br label %106, !dbg !416

106:                                              ; preds = %105, %99
  %107 = load i1, i1* %19, align 1, !dbg !418
  br i1 %107, label %108, label %109, !dbg !419

108:                                              ; preds = %106
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream(), !dbg !420
  call void @llvm.sdr.ublk.r(i16 27), !dbg !421
  br label %180, !dbg !419

109:                                              ; preds = %106
  %110 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !422
  %111 = icmp eq i16 -1, %110, !dbg !423
  br i1 %111, label %112, label %113, !dbg !424

112:                                              ; preds = %109
  call void @__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction(i16 31767), !dbg !425
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 23), !dbg !426
  call void @llvm.sdr.ublk.r(i16 27), !dbg !427
  br label %179, !dbg !424

113:                                              ; preds = %109
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter(i16 0, i16 0), !dbg !428
  %114 = load i16, i16* %34, align 2, !dbg !429
  store i16 %114, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !430
  %115 = load i16, i16* %29, align 2, !dbg !431
  %116 = icmp eq i16 3, %115, !dbg !432
  br i1 %116, label %117, label %126, !dbg !433

117:                                              ; preds = %113
  %118 = load i16, i16* %34, align 2, !dbg !434
  %119 = sub i16 %118, 1, !dbg !435
  %120 = sitofp i16 %119 to float, !dbg !436
  %121 = load float, float* %26, align 4, !dbg !437
  %122 = fmul float %120, %121, !dbg !438
  %123 = fptosi float %122 to i16, !dbg !439
  %124 = add i16 %123, 1, !dbg !440
  store i16 %124, i16* %16, align 2, !dbg !328
  %125 = load i16, i16* %16, align 2, !dbg !441
  store i16 %125, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !442
  br label %131, !dbg !433

126:                                              ; preds = %113
  %127 = load i16, i16* %29, align 2, !dbg !443
  %128 = icmp eq i16 1, %127, !dbg !444
  br i1 %128, label %129, label %130, !dbg !445

129:                                              ; preds = %126
  store i16 1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !446
  br label %130, !dbg !445

130:                                              ; preds = %129, %126
  br label %131, !dbg !433

131:                                              ; preds = %117, %130
  %132 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !447
  %133 = sub i16 %132, 1, !dbg !448
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit(i16 0, i16 %133), !dbg !449
  %134 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !450
  store i16 %134, i16* %15, align 2, !dbg !327
  %135 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !451
  store i16 %135, i16* %14, align 2, !dbg !325
  %136 = load i16, i16* %15, align 2, !dbg !452
  %137 = load i16, i16* %14, align 2, !dbg !453
  %138 = sub i16 %136, %137, !dbg !454
  store i16 %138, i16* %15, align 2, !dbg !455
  %139 = load i16, i16* %14, align 2, !dbg !456
  %140 = icmp eq i16 0, %139, !dbg !457
  br i1 %140, label %141, label %142, !dbg !458

141:                                              ; preds = %131
  store i16 0, i16* %15, align 2, !dbg !459
  br label %142, !dbg !458

142:                                              ; preds = %141, %131
  %143 = load i16, i16* %29, align 2, !dbg !460
  %144 = icmp eq i16 1, %143, !dbg !461
  br i1 %144, label %145, label %146, !dbg !462

145:                                              ; preds = %142
  store i16 0, i16* %15, align 2, !dbg !463
  br label %146, !dbg !462

146:                                              ; preds = %145, %142
  %147 = load i16, i16* %15, align 2, !dbg !464
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter(i16 0, i16 %147), !dbg !465
  call void @__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction(i16 31767), !dbg !466
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 23), !dbg !467
  %148 = load i16, i16* %37, align 2, !dbg !468
  %149 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval(i16 %148), !dbg !469
  %150 = icmp eq i16 0, %149, !dbg !470
  br i1 %150, label %151, label %155, !dbg !471

151:                                              ; preds = %146
  %152 = load i16, i16* %32, align 2, !dbg !472
  %153 = load i16, i16* %31, align 2, !dbg !473
  %154 = load i16, i16* %30, align 2, !dbg !474
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start(i16 %152, i16 %153, i16 %154), !dbg !475
  br label %178, !dbg !471

155:                                              ; preds = %146
  %156 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !476
  %157 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !476
  %158 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !476
  %159 = load i16, i16* %31, align 2, !dbg !477
  store i16 %159, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !478
  store i16 %156, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !478
  store i16 %157, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !478
  store i16 %158, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !478
  %160 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !479
  %161 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !479
  %162 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !479
  %163 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !479
  %164 = and i16 %162, -193, !dbg !479
  %165 = or i16 %164, 128, !dbg !479
  store volatile i16 %160, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !480
  store volatile i16 %161, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !480
  store volatile i16 %165, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !480
  store volatile i16 %163, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !480
  call void asm sideeffect "nop", ""(), !dbg !480
  call void asm sideeffect "nop", ""(), !dbg !480
  %166 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !481
  %167 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !481
  %168 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !481
  %169 = load i16, i16* %31, align 2, !dbg !482
  store i16 %169, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !483
  store i16 %166, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !483
  store i16 %167, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !483
  store i16 %168, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !483
  %170 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !484
  %171 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !484
  %172 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !484
  %173 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !484
  %174 = and i16 %172, -193, !dbg !484
  %175 = or i16 %174, 128, !dbg !484
  %176 = and i16 %171, -64, !dbg !484
  %177 = or i16 %176, 27, !dbg !484
  store volatile i16 %170, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !485
  store volatile i16 %177, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !485
  store volatile i16 %175, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !485
  store volatile i16 %173, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !485
  call void asm sideeffect "nop", ""(), !dbg !485
  call void asm sideeffect "nop", ""(), !dbg !485
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !486
  br label %178, !dbg !471

178:                                              ; preds = %151, %155
  br label %179, !dbg !424

179:                                              ; preds = %112, %178
  br label %180, !dbg !419

180:                                              ; preds = %108, %179
  ret void, !dbg !359
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit(i16 %0, i16 %1) !dbg !487 {
  %3 = alloca i16, i16 1, align 2, !dbg !489
  %4 = alloca i16, i16 1, align 2, !dbg !491
  %5 = alloca i16, i16 1, align 2, !dbg !492
  %6 = alloca i16, i16 1, align 2, !dbg !493
  %7 = alloca i16, i16 1, align 2, !dbg !494
  %8 = alloca i16, i16 1, align 2, !dbg !495
  store i16 %0, i16* %8, align 2, !dbg !495
  store i16 %1, i16* %7, align 2, !dbg !494
  %9 = load i16, i16* %7, align 2, !dbg !496
  %10 = icmp ult i16 %9, -32768, !dbg !497
  br i1 %10, label %11, label %12, !dbg !498

11:                                               ; preds = %2
  br label %13, !dbg !498

12:                                               ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !498
  br label %13, !dbg !498

13:                                               ; preds = %11, %12
  %14 = load i16, i16* %7, align 2, !dbg !499
  %15 = mul i16 %14, 2, !dbg !500
  store i16 %15, i16* %6, align 2, !dbg !493
  %16 = load i16, i16* %8, align 2, !dbg !501
  %17 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %16, i16 8), !dbg !502
  %18 = sub i16 %17, 1, !dbg !503
  store i16 %18, i16* %5, align 2, !dbg !492
  %19 = load i16, i16* %6, align 2, !dbg !504
  %20 = load i16, i16* %5, align 2, !dbg !505
  %21 = icmp ult i16 %19, %20, !dbg !506
  br i1 %21, label %22, label %23, !dbg !491

22:                                               ; preds = %13
  store i16 0, i16* %4, align 2, !dbg !491
  br label %27, !dbg !491

23:                                               ; preds = %13
  %24 = load i16, i16* %6, align 2, !dbg !507
  %25 = load i16, i16* %5, align 2, !dbg !508
  %26 = sub i16 %24, %25, !dbg !509
  store i16 %26, i16* %4, align 2, !dbg !491
  br label %27, !dbg !491

27:                                               ; preds = %22, %23
  %28 = load i16, i16* %4, align 2, !dbg !491
  store i16 %28, i16* %3, align 2, !dbg !489
  %29 = load i16, i16* %8, align 2, !dbg !510
  %30 = load i16, i16* %3, align 2, !dbg !511
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %29, i16 4, i16 %30), !dbg !512
  ret void, !dbg !491
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter(i16 %0, i16 %1) !dbg !513 {
  %3 = alloca i16, i16 1, align 2, !dbg !514
  %4 = alloca i16, i16 1, align 2, !dbg !516
  store i16 %0, i16* %4, align 2, !dbg !516
  store i16 %1, i16* %3, align 2, !dbg !514
  %5 = load i16, i16* %3, align 2, !dbg !517
  %6 = icmp ult i16 %5, -32768, !dbg !518
  br i1 %6, label %7, label %8, !dbg !519

7:                                                ; preds = %2
  br label %9, !dbg !519

8:                                                ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !519
  br label %9, !dbg !519

9:                                                ; preds = %7, %8
  %10 = load i16, i16* %4, align 2, !dbg !520
  %11 = load i16, i16* %3, align 2, !dbg !521
  %12 = mul i16 %11, 2, !dbg !522
  %13 = add i16 %12, 1, !dbg !523
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %10, i16 8, i16 %13), !dbg !524
  ret void, !dbg !525
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter(i16 %0, i16 %1) !dbg !526 {
  %3 = alloca i16, i16 1, align 2, !dbg !527
  %4 = alloca i16, i16 1, align 2, !dbg !529
  %5 = alloca i1, i16 1, align 1, !dbg !530
  %6 = alloca i16, i16 1, align 2, !dbg !531
  %7 = alloca i16, i16 1, align 2, !dbg !532
  %8 = alloca i16, i16 1, align 2, !dbg !533
  %9 = alloca i16, i16 1, align 2, !dbg !534
  store i16 %0, i16* %9, align 2, !dbg !534
  store i16 %1, i16* %8, align 2, !dbg !533
  %10 = load i16, i16* %8, align 2, !dbg !535
  %11 = icmp ult i16 %10, -32768, !dbg !536
  br i1 %11, label %12, label %13, !dbg !537

12:                                               ; preds = %2
  br label %14, !dbg !537

13:                                               ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !537
  br label %14, !dbg !537

14:                                               ; preds = %12, %13
  %15 = load i16, i16* %9, align 2, !dbg !538
  %16 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %15, i16 8), !dbg !539
  store i16 %16, i16* %7, align 2, !dbg !532
  %17 = load i16, i16* %8, align 2, !dbg !540
  %18 = mul i16 %17, 2, !dbg !541
  store i16 %18, i16* %6, align 2, !dbg !531
  %19 = load i16, i16* %6, align 2, !dbg !542
  %20 = load i16, i16* %7, align 2, !dbg !543
  %21 = icmp ugt i16 %19, %20, !dbg !544
  store i1 %21, i1* %5, align 1, !dbg !530
  %22 = load i16, i16* %9, align 2, !dbg !545
  %23 = load i1, i1* %5, align 1, !dbg !546
  %24 = zext i1 %23 to i16, !dbg !547
  %25 = shl i16 %24, 6, !dbg !548
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %22, i16 14, i16 %25), !dbg !549
  %26 = load i1, i1* %5, align 1, !dbg !550
  br i1 %26, label %27, label %32, !dbg !529

27:                                               ; preds = %14
  %28 = load i16, i16* %6, align 2, !dbg !551
  %29 = load i16, i16* %7, align 2, !dbg !552
  %30 = sub i16 %28, %29, !dbg !553
  %31 = add i16 %30, 1, !dbg !554
  store i16 %31, i16* %4, align 2, !dbg !529
  br label %34, !dbg !529

32:                                               ; preds = %14
  %33 = load i16, i16* %6, align 2, !dbg !555
  store i16 %33, i16* %4, align 2, !dbg !529
  br label %34, !dbg !529

34:                                               ; preds = %27, %32
  %35 = load i16, i16* %4, align 2, !dbg !529
  store i16 %35, i16* %3, align 2, !dbg !527
  %36 = load i16, i16* %9, align 2, !dbg !556
  %37 = load i16, i16* %3, align 2, !dbg !557
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %36, i16 12, i16 %37), !dbg !558
  ret void, !dbg !529
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %0, i16 %1, i16 %2) !dbg !559 {
  %4 = alloca i16, i16 1, align 2, !dbg !561
  %5 = alloca i16, i16 1, align 2, !dbg !563
  %6 = alloca i16, i16 1, align 2, !dbg !564
  store i16 %0, i16* %6, align 2, !dbg !564
  store i16 %1, i16* %5, align 2, !dbg !563
  store i16 %2, i16* %4, align 2, !dbg !561
  %7 = load i16, i16* %6, align 2, !dbg !565
  %8 = getelementptr [6 x i16], [6 x i16]* @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.filters, i16 0, i16 %7, !dbg !566
  %9 = load i16, i16* %8, align 2, !dbg !566
  %10 = load i16, i16* %5, align 2, !dbg !567
  %11 = add i16 %9, %10, !dbg !568
  %12 = lshr i16 %11, 1, !dbg !569
  %13 = load i16, i16* %4, align 2, !dbg !570
  %14 = shl i16 %12, 1, !dbg !571
  %15 = inttoptr i16 %14 to i16*, !dbg !571
  store volatile i16 %13, i16* %15, align 2, !dbg !571
  call void asm sideeffect "nop", ""(), !dbg !571
  call void asm sideeffect "nop", ""(), !dbg !571
  ret void, !dbg !572
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %0, i16 %1) !dbg !573 {
  %3 = alloca i16, i16 1, align 2, !dbg !574
  %4 = alloca i16, i16 1, align 2, !dbg !576
  store i16 %0, i16* %4, align 2, !dbg !576
  store i16 %1, i16* %3, align 2, !dbg !574
  %5 = load i16, i16* %4, align 2, !dbg !577
  %6 = getelementptr [6 x i16], [6 x i16]* @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.filters, i16 0, i16 %5, !dbg !578
  %7 = load i16, i16* %6, align 2, !dbg !578
  %8 = load i16, i16* %3, align 2, !dbg !579
  %9 = add i16 %7, %8, !dbg !580
  %10 = lshr i16 %9, 1, !dbg !581
  %11 = shl i16 %10, 1, !dbg !582
  %12 = inttoptr i16 %11 to i16*, !dbg !582
  call void asm sideeffect "nop", ""(), !dbg !582
  call void asm sideeffect "nop", ""(), !dbg !582
  %13 = load volatile i16, i16* %12, align 2, !dbg !582
  ret i16 %13, !dbg !583
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 %0) !dbg !584 {
  %2 = alloca i16, i16 1, align 2, !dbg !586
  %3 = alloca i16, i16 1, align 2, !dbg !588
  %4 = alloca i16, i16 1, align 2, !dbg !589
  %5 = alloca i16, i16 1, align 2, !dbg !590
  store i16 %0, i16* %5, align 2, !dbg !590
  %6 = load i16, i16* %5, align 2, !dbg !591
  store i16 %6, i16* %4, align 2, !dbg !589
  %7 = load i16, i16* %4, align 2, !dbg !592
  %8 = add i16 %7, 31744, !dbg !593
  store i16 %8, i16* %3, align 2, !dbg !588
  %9 = load i16, i16* %3, align 2, !dbg !594
  %10 = shl i16 %9, 1, !dbg !595
  %11 = inttoptr i16 %10 to i16*, !dbg !595
  call void asm sideeffect "nop", ""(), !dbg !595
  call void asm sideeffect "nop", ""(), !dbg !595
  %12 = load volatile i16, i16* %11, align 2, !dbg !595
  store i16 %12, i16* %2, align 2, !dbg !586
  %13 = load i16, i16* %3, align 2, !dbg !596
  %14 = load i16, i16* %2, align 2, !dbg !597
  %15 = and i16 %14, 32767, !dbg !598
  %16 = shl i16 %13, 1, !dbg !599
  %17 = inttoptr i16 %16 to i16*, !dbg !599
  store volatile i16 %15, i16* %17, align 2, !dbg !599
  call void asm sideeffect "nop", ""(), !dbg !599
  call void asm sideeffect "nop", ""(), !dbg !599
  ret void, !dbg !600
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord() !dbg !601 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 2), !dbg !603
  %2 = sub i16 %1, 4, !dbg !605
  ret i16 %2, !dbg !606
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord() !dbg !607 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 0), !dbg !608
  %2 = sub i16 %1, 1, !dbg !610
  ret i16 %2, !dbg !611
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 %0) !dbg !612 {
  %2 = alloca i16, i16 1, align 2, !dbg !614
  %3 = alloca i16, i16 1, align 2, !dbg !616
  store i16 %0, i16* %3, align 2, !dbg !616
  %4 = load i16, i16* %3, align 2, !dbg !617
  %5 = lshr i16 %4, 1, !dbg !618
  %6 = add i16 %5, 31813, !dbg !619
  %7 = shl i16 %6, 1, !dbg !620
  %8 = inttoptr i16 %7 to i16*, !dbg !620
  call void asm sideeffect "nop", ""(), !dbg !620
  call void asm sideeffect "nop", ""(), !dbg !620
  %9 = load volatile i16, i16* %8, align 2, !dbg !620
  store i16 %9, i16* %2, align 2, !dbg !614
  %10 = load i16, i16* %2, align 2, !dbg !621
  %11 = and i16 %10, 2047, !dbg !622
  ret i16 %11, !dbg !623
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord() !dbg !624 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord(), !dbg !626
  ret i16 %1, !dbg !628
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.get_y_coord() !dbg !629 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord(), !dbg !630
  ret i16 %1, !dbg !632
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval(i16 %0) !dbg !633 {
  %2 = alloca i16, i16 1, align 2, !dbg !634
  store i16 %0, i16* %2, align 2, !dbg !634
  %3 = load i16, i16* %2, align 2, !dbg !636
  %4 = icmp ult i16 %3, 24, !dbg !637
  br i1 %4, label %5, label %7, !dbg !638

5:                                                ; preds = %10, %11, %1
  %6 = phi i16 [ 0, %10 ], [ 0, %11 ], [ 1, %1 ]
  br label %12, !dbg !638

7:                                                ; preds = %1
  %8 = load i16, i16* %2, align 2, !dbg !639
  %9 = icmp eq i16 31, %8, !dbg !640
  br i1 %9, label %10, label %11, !dbg !641

10:                                               ; preds = %7
  br label %5, !dbg !641

11:                                               ; preds = %7
  call void asm sideeffect "hcf", ""(), !dbg !641
  br label %5, !dbg !641

12:                                               ; preds = %5
  %13 = phi i16 [ %6, %5 ]
  br label %14, !dbg !638

14:                                               ; preds = %12
  ret i16 %13, !dbg !638
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7) !dbg !642 {
  %9 = alloca i16, i16 1, align 2, !dbg !643
  %10 = alloca i16, i16 1, align 2, !dbg !645
  %11 = alloca i16, i16 1, align 2, !dbg !646
  %12 = alloca i16, i16 1, align 2, !dbg !647
  %13 = alloca i16, i16 1, align 2, !dbg !648
  %14 = alloca i16, i16 1, align 2, !dbg !649
  %15 = alloca i16, i16 1, align 2, !dbg !650
  %16 = alloca i16, i16 1, align 2, !dbg !651
  %17 = alloca i16, i16 1, align 2, !dbg !652
  store i16 %0, i16* %17, align 2, !dbg !652
  store i16 %1, i16* %16, align 2, !dbg !651
  store i16 %2, i16* %15, align 2, !dbg !650
  store i16 %3, i16* %14, align 2, !dbg !649
  store i16 %4, i16* %13, align 2, !dbg !648
  store i16 %5, i16* %12, align 2, !dbg !647
  store i16 %6, i16* %11, align 2, !dbg !646
  store i16 %7, i16* %10, align 2, !dbg !645
  %18 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !653
  store i16 %18, i16* %9, align 2, !dbg !643
  %19 = load i16, i16* %11, align 2, !dbg !654
  store i16 %19, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_c, align 2, !dbg !655
  %20 = load i16, i16* %10, align 2, !dbg !656
  store i16 %20, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_is_half, align 2, !dbg !657
  %21 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_c, align 2, !dbg !658
  %22 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval(i16 %21), !dbg !659
  store i16 %22, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !660
  store i16 0, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !661
  %23 = load i16, i16* %16, align 2, !dbg !662
  store i16 %23, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !663
  %24 = load i16, i16* %15, align 2, !dbg !664
  store i16 %24, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !665
  %25 = load i16, i16* %15, align 2, !dbg !666
  %26 = load i16, i16* %13, align 2, !dbg !667
  %27 = add i16 %25, %26, !dbg !668
  %28 = sub i16 %27, 1, !dbg !669
  store i16 %28, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_last, align 2, !dbg !670
  %29 = load i16, i16* %9, align 2, !dbg !671
  %30 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_last, align 2, !dbg !672
  %31 = icmp eq i16 %29, %30, !dbg !673
  br i1 %31, label %32, label %37, !dbg !674

32:                                               ; preds = %8
  %33 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !675
  %34 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !675
  %35 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !675
  store i16 %33, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !676
  store i16 lshr (i16 ptrtoint ([1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.ctrl_1 to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !676
  store i16 %34, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !676
  store i16 %35, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !676
  %36 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.ctrl_1, i16 0, i1 false), align 4, !dbg !677
  store i32 %36, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i1 false), align 4, !dbg !678
  br label %42, !dbg !674

37:                                               ; preds = %8
  %38 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !679
  %39 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !679
  %40 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !679
  store i16 %38, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !680
  store i16 lshr (i16 ptrtoint ([1 x i32]* @"$$csl_base_address$$0$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11" to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !680
  store i16 %39, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !680
  store i16 %40, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !680
  %41 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @"$$csl_base_address$$0$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11", i16 0, i1 false), align 4, !dbg !681
  store i32 %41, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i1 false), align 4, !dbg !682
  br label %42, !dbg !674

42:                                               ; preds = %32, %37
  store i32 165646921, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i2 1), align 4, !dbg !683
  %43 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !684
  %44 = icmp eq i16 0, %43, !dbg !685
  br i1 %44, label %45, label %56, !dbg !686

45:                                               ; preds = %42
  %46 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !687
  %47 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !687
  %48 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !687
  %49 = load i16, i16* %17, align 2, !dbg !688
  %50 = call i16* @.get_tensor_ptr(i16 %49), !dbg !689
  %51 = ptrtoint i16* %50 to i16, !dbg !690
  %52 = lshr i16 %51, 1, !dbg !690
  store i16 %46, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !691
  store i16 %52, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !691
  store i16 %47, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !691
  store i16 %48, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !691
  %53 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !692
  %54 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !692
  %55 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !692
  store i16 1, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !693
  store i16 %53, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !693
  store i16 %54, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !693
  store i16 %55, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !693
  call void @llvm.sdr.actvt.r(i16 21), !dbg !694
  br label %63, !dbg !686

56:                                               ; preds = %42
  %57 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !695
  %58 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !695
  %59 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !695
  store i16 %57, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !696
  store i16 lshr (i16 ptrtoint ([1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.data_buf to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !696
  store i16 %58, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !696
  store i16 %59, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !696
  %60 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !697
  %61 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !697
  %62 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !697
  store i16 1, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !698
  store i16 %60, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !698
  store i16 %61, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !698
  store i16 %62, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !698
  call void @llvm.sdr.ublk.r(i16 0), !dbg !699
  br label %63, !dbg !686

63:                                               ; preds = %45, %56
  ret void, !dbg !674
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x(i32 %0) #8 !dbg !700 {
  %2 = alloca i32, i16 1, align 4, !dbg !701
  store i32 %0, i32* %2, align 4, !dbg !701
  call void @llvm.sdr.blk.r(i16 0), !dbg !703
  %3 = load i32, i32* %2, align 4, !dbg !704
  store i32 %3, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.data_buf, i16 0, i1 false), align 4, !dbg !705
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !706
  %4 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !707
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !707
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !707
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !707
  store volatile i16 %4, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !708
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !708
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !708
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !708
  call void asm sideeffect "nop", ""(), !dbg !708
  call void asm sideeffect "nop", ""(), !dbg !708
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !709
  %8 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !710
  %9 = add i16 %8, 1, !dbg !711
  store i16 %9, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !712
  ret void, !dbg !713
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_send_data() #9 !dbg !714 {
  %1 = alloca i16, i16 1, align 2, !dbg !715
  %2 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !717
  %3 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !718
  %4 = icmp ult i16 %2, %3, !dbg !719
  br i1 %4, label %5, label %27, !dbg !720

5:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !721
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !722
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !722
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !722
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !722
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !723
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !723
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !723
  store volatile i16 %9, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !723
  call void asm sideeffect "nop", ""(), !dbg !723
  call void asm sideeffect "nop", ""(), !dbg !723
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_is_half, align 2, !dbg !724
  %11 = icmp ult i16 0, %10, !dbg !725
  br i1 %11, label %12, label %18, !dbg !726

12:                                               ; preds = %5
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !727
  %13 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !728
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !728
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !728
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !728
  %17 = add i16 %14, 1, !dbg !729
  store i16 %13, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !730
  store i16 %17, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !730
  store i16 %15, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !730
  store i16 %16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !730
  br label %24, !dbg !726

18:                                               ; preds = %5
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !731
  %19 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !732
  %20 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !732
  %21 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !732
  %22 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !732
  %23 = add i16 %20, 2, !dbg !733
  store i16 %19, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !734
  store i16 %23, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !734
  store i16 %21, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !734
  store i16 %22, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !734
  br label %24, !dbg !726

24:                                               ; preds = %12, %18
  %25 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !735
  %26 = add i16 %25, 1, !dbg !736
  store i16 %26, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !737
  br label %34, !dbg !720

27:                                               ; preds = %0
  %28 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !738
  store i16 %28, i16* %1, align 2, !dbg !715
  %29 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !739
  %30 = load i16, i16* %1, align 2, !dbg !740
  %31 = icmp eq i16 %29, %30, !dbg !741
  br i1 %31, label %32, label %33, !dbg !742

32:                                               ; preds = %27
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !743
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__1 to i8*)), !dbg !744
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !745
  br label %33, !dbg !742

33:                                               ; preds = %32, %27
  br label %34, !dbg !720

34:                                               ; preds = %24, %33
  ret void, !dbg !720
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl() #10 !dbg !746 {
  %1 = alloca i16, i16 1, align 2, !dbg !747
  %2 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !749
  %3 = icmp eq i16 0, %2, !dbg !750
  br i1 %3, label %4, label %9, !dbg !751

4:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__2 to i8*)), !dbg !752
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !753
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !753
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !753
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !753
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !754
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !754
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !754
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !754
  call void asm sideeffect "nop", ""(), !dbg !754
  call void asm sideeffect "nop", ""(), !dbg !754
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !755
  br label %31, !dbg !751

9:                                                ; preds = %0
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !756
  %11 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !757
  %12 = icmp ult i16 %10, %11, !dbg !758
  br i1 %12, label %13, label %18, !dbg !759

13:                                               ; preds = %9
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__3 to i8*)), !dbg !760
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !761
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !761
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !761
  %17 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !761
  store volatile i16 %14, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !762
  store volatile i16 %15, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !762
  store volatile i16 %16, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !762
  store volatile i16 %17, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !762
  call void asm sideeffect "nop", ""(), !dbg !762
  call void asm sideeffect "nop", ""(), !dbg !762
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !763
  br label %30, !dbg !759

18:                                               ; preds = %9
  %19 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !764
  store i16 %19, i16* %1, align 2, !dbg !747
  %20 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !765
  %21 = load i16, i16* %1, align 2, !dbg !766
  %22 = icmp eq i16 %20, %21, !dbg !767
  br i1 %22, label %23, label %24, !dbg !768

23:                                               ; preds = %18
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__4 to i8*)), !dbg !769
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__5 to i8*)), !dbg !770
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !771
  br label %29, !dbg !768

24:                                               ; preds = %18
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !772
  %25 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !773
  %26 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !773
  %27 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !773
  %28 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !773
  store volatile i16 %25, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !774
  store volatile i16 %26, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !774
  store volatile i16 %27, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !774
  store volatile i16 %28, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !774
  call void asm sideeffect "nop", ""(), !dbg !774
  call void asm sideeffect "nop", ""(), !dbg !774
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !775
  br label %29, !dbg !768

29:                                               ; preds = %23, %24
  br label %30, !dbg !759

30:                                               ; preds = %13, %29
  br label %31, !dbg !751

31:                                               ; preds = %4, %30
  ret void, !dbg !751
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.d2h_configure(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7) !dbg !776 {
  %9 = alloca i1, i16 1, align 1, !dbg !777
  %10 = alloca i1, i16 1, align 1, !dbg !779
  %11 = alloca i1, i16 1, align 1, !dbg !780
  %12 = alloca i16, i16 1, align 2, !dbg !781
  %13 = alloca i16, i16 1, align 2, !dbg !782
  %14 = alloca i16, i16 1, align 2, !dbg !783
  %15 = alloca i16, i16 1, align 2, !dbg !784
  %16 = alloca i16, i16 1, align 2, !dbg !785
  %17 = alloca i16, i16 1, align 2, !dbg !786
  %18 = alloca i16, i16 1, align 2, !dbg !787
  %19 = alloca i16, i16 1, align 2, !dbg !788
  %20 = alloca i16, i16 1, align 2, !dbg !789
  %21 = alloca i16, i16 1, align 2, !dbg !790
  %22 = alloca i16, i16 1, align 2, !dbg !791
  %23 = alloca i16, i16 1, align 2, !dbg !792
  %24 = alloca i16, i16 1, align 2, !dbg !793
  %25 = alloca i16, i16 1, align 2, !dbg !794
  store i16 %0, i16* %25, align 2, !dbg !794
  store i16 %1, i16* %24, align 2, !dbg !793
  store i16 %2, i16* %23, align 2, !dbg !792
  store i16 %3, i16* %22, align 2, !dbg !791
  store i16 %4, i16* %21, align 2, !dbg !790
  store i16 %5, i16* %20, align 2, !dbg !789
  store i16 %6, i16* %19, align 2, !dbg !788
  store i16 %7, i16* %18, align 2, !dbg !787
  %26 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !795
  store i16 %26, i16* %17, align 2, !dbg !786
  %27 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_y_coord(), !dbg !796
  store i16 %27, i16* %16, align 2, !dbg !785
  %28 = load i16, i16* %24, align 2, !dbg !797
  store i16 %28, i16* %15, align 2, !dbg !784
  %29 = load i16, i16* %24, align 2, !dbg !798
  %30 = load i16, i16* %22, align 2, !dbg !799
  %31 = add i16 %29, %30, !dbg !800
  %32 = sub i16 %31, 1, !dbg !801
  store i16 %32, i16* %14, align 2, !dbg !783
  %33 = load i16, i16* %23, align 2, !dbg !802
  store i16 %33, i16* %13, align 2, !dbg !782
  %34 = load i16, i16* %23, align 2, !dbg !803
  %35 = load i16, i16* %21, align 2, !dbg !804
  %36 = add i16 %34, %35, !dbg !805
  %37 = sub i16 %36, 1, !dbg !806
  store i16 %37, i16* %12, align 2, !dbg !781
  store i1 false, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !807
  %38 = load i16, i16* %17, align 2, !dbg !808
  %39 = load i16, i16* %15, align 2, !dbg !809
  %40 = icmp sge i16 %38, %39, !dbg !810
  br i1 %40, label %41, label %45, !dbg !780

41:                                               ; preds = %8
  %42 = load i16, i16* %16, align 2, !dbg !811
  %43 = load i16, i16* %12, align 2, !dbg !812
  %44 = icmp sle i16 %42, %43, !dbg !813
  store i1 %44, i1* %11, align 1, !dbg !780
  br label %46, !dbg !780

45:                                               ; preds = %8
  store i1 false, i1* %11, align 1, !dbg !780
  br label %46, !dbg !780

46:                                               ; preds = %41, %45
  %47 = load i1, i1* %11, align 1, !dbg !780
  br i1 %47, label %48, label %52, !dbg !779

48:                                               ; preds = %46
  %49 = load i16, i16* %16, align 2, !dbg !814
  %50 = load i16, i16* %13, align 2, !dbg !815
  %51 = icmp sge i16 %49, %50, !dbg !816
  store i1 %51, i1* %10, align 1, !dbg !779
  br label %53, !dbg !779

52:                                               ; preds = %46
  store i1 false, i1* %10, align 1, !dbg !779
  br label %53, !dbg !779

53:                                               ; preds = %48, %52
  %54 = load i1, i1* %10, align 1, !dbg !779
  br i1 %54, label %55, label %56, !dbg !817

55:                                               ; preds = %53
  store i1 true, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !818
  br label %56, !dbg !817

56:                                               ; preds = %55, %53
  store i1 false, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !819
  %57 = load i16, i16* %17, align 2, !dbg !820
  %58 = load i16, i16* %14, align 2, !dbg !821
  %59 = icmp sle i16 %57, %58, !dbg !822
  br i1 %59, label %60, label %62, !dbg !777

60:                                               ; preds = %56
  %61 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !823
  store i1 %61, i1* %9, align 1, !dbg !777
  br label %63, !dbg !777

62:                                               ; preds = %56
  store i1 false, i1* %9, align 1, !dbg !777
  br label %63, !dbg !777

63:                                               ; preds = %60, %62
  %64 = load i1, i1* %9, align 1, !dbg !777
  br i1 %64, label %65, label %66, !dbg !824

65:                                               ; preds = %63
  store i1 true, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !825
  br label %66, !dbg !824

66:                                               ; preds = %65, %63
  %67 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !826
  br i1 %67, label %68, label %86, !dbg !827

68:                                               ; preds = %66
  call void @__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position(i16 31959), !dbg !828
  %69 = load i16, i16* %15, align 2, !dbg !829
  %70 = load i16, i16* %17, align 2, !dbg !830
  %71 = icmp eq i16 %69, %70, !dbg !831
  br i1 %71, label %72, label %73, !dbg !832

72:                                               ; preds = %68
  call void @__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 31765), !dbg !833
  br label %74, !dbg !832

73:                                               ; preds = %68
  call void @__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 31765), !dbg !834
  br label %74, !dbg !832

74:                                               ; preds = %72, %73
  call void @sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit(i16 21), !dbg !835
  %75 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !836
  br i1 %75, label %76, label %85, !dbg !837

76:                                               ; preds = %74
  %77 = load i16, i16* %20, align 2, !dbg !838
  %78 = load i16, i16* %19, align 2, !dbg !839
  %79 = load i16, i16* %24, align 2, !dbg !840
  %80 = load i16, i16* %23, align 2, !dbg !841
  %81 = load i16, i16* %22, align 2, !dbg !842
  %82 = load i16, i16* %21, align 2, !dbg !843
  %83 = load i16, i16* %25, align 2, !dbg !844
  %84 = load i16, i16* %18, align 2, !dbg !845
  call void @sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start(i16 %77, i16 %78, i16 %79, i16 %80, i16 %81, i16 %82, i16 %83, i16 %84), !dbg !846
  br label %85, !dbg !837

85:                                               ; preds = %76, %74
  br label %87, !dbg !827

86:                                               ; preds = %66
  call void @llvm.sdr.actvt.r(i16 28), !dbg !847
  br label %87, !dbg !827

87:                                               ; preds = %85, %86
  ret void, !dbg !780
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit(i16 %0) !dbg !848 {
  %2 = alloca i16, i16 1, align 2, !dbg !849
  %3 = alloca i16, i16 1, align 2, !dbg !851
  %4 = alloca i16, i16 1, align 2, !dbg !852
  %5 = alloca i16, i16 1, align 2, !dbg !853
  store i16 %0, i16* %5, align 2, !dbg !853
  %6 = load i16, i16* %5, align 2, !dbg !854
  store i16 %6, i16* %4, align 2, !dbg !852
  %7 = load i16, i16* %4, align 2, !dbg !855
  %8 = add i16 %7, 31744, !dbg !856
  store i16 %8, i16* %3, align 2, !dbg !851
  %9 = load i16, i16* %3, align 2, !dbg !857
  %10 = shl i16 %9, 1, !dbg !858
  %11 = inttoptr i16 %10 to i16*, !dbg !858
  call void asm sideeffect "nop", ""(), !dbg !858
  call void asm sideeffect "nop", ""(), !dbg !858
  %12 = load volatile i16, i16* %11, align 2, !dbg !858
  store i16 %12, i16* %2, align 2, !dbg !849
  %13 = load i16, i16* %3, align 2, !dbg !859
  %14 = load i16, i16* %2, align 2, !dbg !860
  %15 = and i16 %14, 32767, !dbg !861
  %16 = shl i16 %13, 1, !dbg !862
  %17 = inttoptr i16 %16 to i16*, !dbg !862
  store volatile i16 %15, i16* %17, align 2, !dbg !862
  call void asm sideeffect "nop", ""(), !dbg !862
  call void asm sideeffect "nop", ""(), !dbg !862
  ret void, !dbg !863
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord() !dbg !864 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 2), !dbg !865
  %2 = sub i16 %1, 4, !dbg !867
  ret i16 %2, !dbg !868
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord() !dbg !869 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 0), !dbg !870
  %2 = sub i16 %1, 1, !dbg !872
  ret i16 %2, !dbg !873
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 %0) !dbg !874 {
  %2 = alloca i16, i16 1, align 2, !dbg !875
  %3 = alloca i16, i16 1, align 2, !dbg !877
  store i16 %0, i16* %3, align 2, !dbg !877
  %4 = load i16, i16* %3, align 2, !dbg !878
  %5 = lshr i16 %4, 1, !dbg !879
  %6 = add i16 %5, 31813, !dbg !880
  %7 = shl i16 %6, 1, !dbg !881
  %8 = inttoptr i16 %7 to i16*, !dbg !881
  call void asm sideeffect "nop", ""(), !dbg !881
  call void asm sideeffect "nop", ""(), !dbg !881
  %9 = load volatile i16, i16* %8, align 2, !dbg !881
  store i16 %9, i16* %2, align 2, !dbg !875
  %10 = load i16, i16* %2, align 2, !dbg !882
  %11 = and i16 %10, 2047, !dbg !883
  ret i16 %11, !dbg !884
}

define internal i16 @sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr(i16 %0) !dbg !885 {
  %2 = alloca i16, i16 1, align 2, !dbg !887
  store i16 %0, i16* %2, align 2, !dbg !887
  %3 = load i16, i16* %2, align 2, !dbg !889
  %4 = mul i16 %3, 2, !dbg !890
  %5 = add i16 %4, 31680, !dbg !891
  ret i16 %5, !dbg !892
}

define internal void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 %0, i16 %1, i1 %2) !dbg !893 {
  %4 = alloca i16, i16 1, align 2, !dbg !894
  %5 = alloca i16, i16 1, align 2, !dbg !896
  %6 = alloca i1, i16 1, align 1, !dbg !897
  %7 = alloca i16, i16 1, align 2, !dbg !898
  %8 = alloca i16, i16 1, align 2, !dbg !899
  store i16 %0, i16* %8, align 2, !dbg !899
  store i16 %1, i16* %7, align 2, !dbg !898
  store i1 %2, i1* %6, align 1, !dbg !897
  %9 = load i16, i16* %8, align 2, !dbg !900
  %10 = call i16 @sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr(i16 %9), !dbg !901
  store i16 %10, i16* %5, align 2, !dbg !896
  %11 = load i16, i16* %5, align 2, !dbg !902
  %12 = shl i16 %11, 1, !dbg !903
  %13 = inttoptr i16 %12 to i16*, !dbg !903
  call void asm sideeffect "nop", ""(), !dbg !903
  call void asm sideeffect "nop", ""(), !dbg !903
  call void asm sideeffect "nop", ""(), !dbg !903
  call void asm sideeffect "nop", ""(), !dbg !903
  %14 = load volatile i16, i16* %13, align 2, !dbg !903
  store i16 %14, i16* %4, align 2, !dbg !894
  %15 = load i1, i1* %6, align 1, !dbg !904
  br i1 %15, label %16, label %19, !dbg !905

16:                                               ; preds = %3
  %17 = load i16, i16* %4, align 2, !dbg !906
  %18 = or i16 %17, 2048, !dbg !907
  store i16 %18, i16* %4, align 2, !dbg !908
  br label %22, !dbg !905

19:                                               ; preds = %3
  %20 = load i16, i16* %4, align 2, !dbg !909
  %21 = and i16 %20, -2049, !dbg !910
  store i16 %21, i16* %4, align 2, !dbg !911
  br label %22, !dbg !905

22:                                               ; preds = %16, %19
  %23 = load i16, i16* %4, align 2, !dbg !912
  %24 = and i16 %23, -32, !dbg !913
  store i16 %24, i16* %4, align 2, !dbg !914
  %25 = load i16, i16* %4, align 2, !dbg !915
  %26 = load i16, i16* %7, align 2, !dbg !916
  %27 = add i16 %25, %26, !dbg !917
  store i16 %27, i16* %4, align 2, !dbg !918
  %28 = load i16, i16* %5, align 2, !dbg !919
  %29 = load i16, i16* %4, align 2, !dbg !920
  %30 = shl i16 %28, 1, !dbg !921
  %31 = inttoptr i16 %30 to i16*, !dbg !921
  store volatile i16 %29, i16* %31, align 2, !dbg !921
  call void asm sideeffect "nop", ""(), !dbg !921
  call void asm sideeffect "nop", ""(), !dbg !921
  call void asm sideeffect "nop", ""(), !dbg !921
  call void asm sideeffect "nop", ""(), !dbg !921
  ret void, !dbg !905
}

define internal i16 @sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr(i16 %0) !dbg !922 {
  %2 = alloca i16, i16 1, align 2, !dbg !924
  store i16 %0, i16* %2, align 2, !dbg !924
  %3 = load i16, i16* %2, align 2, !dbg !926
  %4 = add i16 %3, 31616, !dbg !927
  ret i16 %4, !dbg !928
}

define internal void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 %0, i16 %1) !dbg !929 {
  %3 = alloca i16, i16 1, align 2, !dbg !930
  %4 = alloca i16, i16 1, align 2, !dbg !932
  %5 = alloca i16, i16 1, align 2, !dbg !933
  %6 = alloca i16, i16 1, align 2, !dbg !934
  store i16 %0, i16* %6, align 2, !dbg !934
  store i16 %1, i16* %5, align 2, !dbg !933
  %7 = load i16, i16* %6, align 2, !dbg !935
  %8 = call i16 @sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr(i16 %7), !dbg !936
  store i16 %8, i16* %4, align 2, !dbg !932
  %9 = load i16, i16* %4, align 2, !dbg !937
  %10 = shl i16 %9, 1, !dbg !938
  %11 = inttoptr i16 %10 to i16*, !dbg !938
  call void asm sideeffect "nop", ""(), !dbg !938
  call void asm sideeffect "nop", ""(), !dbg !938
  call void asm sideeffect "nop", ""(), !dbg !938
  call void asm sideeffect "nop", ""(), !dbg !938
  %12 = load volatile i16, i16* %11, align 2, !dbg !938
  store i16 %12, i16* %3, align 2, !dbg !930
  %13 = load i16, i16* %3, align 2, !dbg !939
  %14 = and i16 %13, -497, !dbg !940
  store i16 %14, i16* %3, align 2, !dbg !941
  %15 = load i16, i16* %3, align 2, !dbg !942
  %16 = load i16, i16* %5, align 2, !dbg !943
  %17 = add i16 %15, %16, !dbg !944
  %18 = shl i16 %17, 4, !dbg !945
  store i16 %18, i16* %3, align 2, !dbg !946
  %19 = load i16, i16* %4, align 2, !dbg !947
  %20 = load i16, i16* %3, align 2, !dbg !948
  %21 = shl i16 %19, 1, !dbg !949
  %22 = inttoptr i16 %21 to i16*, !dbg !949
  store volatile i16 %20, i16* %22, align 2, !dbg !949
  call void asm sideeffect "nop", ""(), !dbg !949
  call void asm sideeffect "nop", ""(), !dbg !949
  call void asm sideeffect "nop", ""(), !dbg !949
  call void asm sideeffect "nop", ""(), !dbg !949
  ret void, !dbg !950
}

define internal i16* @.get_tensor_ptr(i16 %0) !dbg !951 {
  %2 = alloca i16, i16 1, align 2, !dbg !952
  store i16 %0, i16* %2, align 2, !dbg !952
  %3 = load i16, i16* %2, align 2, !dbg !952
  %4 = zext i16 %3 to i32, !dbg !952
  switch i32 %4, label %5 [
    i32 1, label %9
    i32 2, label %11
    i32 3, label %13
    i32 4, label %15
    i32 5, label %17
  ], !dbg !952

5:                                                ; preds = %1
  br i1 false, label %6, label %7, !dbg !952

6:                                                ; preds = %5
  br label %8, !dbg !952

7:                                                ; preds = %5
  call void asm sideeffect "hcf", ""(), !dbg !952
  br label %8, !dbg !952

8:                                                ; preds = %6, %7
  br label %19, !dbg !952

9:                                                ; preds = %1
  %10 = load i16*, i16** @p_a, align 8, !dbg !952
  br label %19, !dbg !952

11:                                               ; preds = %1
  %12 = load i16*, i16** @p_b, align 8, !dbg !952
  br label %19, !dbg !952

13:                                               ; preds = %1
  %14 = load i16*, i16** @p_c, align 8, !dbg !952
  br label %19, !dbg !952

15:                                               ; preds = %1
  %16 = load i16*, i16** @p_idx, align 8, !dbg !952
  br label %19, !dbg !952

17:                                               ; preds = %1
  %18 = load i16*, i16** @p_k, align 8, !dbg !952
  br label %19, !dbg !952

19:                                               ; preds = %8, %9, %11, %13, %15, %17
  %20 = phi i16 [ -2, %17 ], [ -2, %15 ], [ -2, %13 ], [ -2, %11 ], [ -2, %9 ], [ 0, %8 ]
  %21 = phi i16* [ %18, %17 ], [ %16, %15 ], [ %14, %13 ], [ %12, %11 ], [ %10, %9 ], [ undef, %8 ]
  br label %22, !dbg !952

22:                                               ; preds = %19
  %23 = icmp ne i16 %20, 0, !dbg !952
  br i1 %23, label %24, label %25, !dbg !952

24:                                               ; preds = %22
  br label %27, !dbg !952

25:                                               ; preds = %22
  %26 = load i16*, i16** @p_k, align 8, !dbg !952
  br label %27, !dbg !952

27:                                               ; preds = %24, %25
  %28 = phi i16* [ %26, %25 ], [ %21, %24 ]
  br label %29, !dbg !952

29:                                               ; preds = %27
  ret i16* %28, !dbg !952
}

define internal void @__generic0sys_mod.sys_mod.tile_config.queue_flush.exit() !dbg !954 {
  store volatile i16 1, i16* inttoptr (i16 -2268 to i16*), align 2, !dbg !956
  call void asm sideeffect "nop", ""(), !dbg !956
  call void asm sideeffect "nop", ""(), !dbg !956
  ret void, !dbg !958
}

define internal void @__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position(i16 %0) !dbg !959 {
  %2 = alloca i16, i16 1, align 2, !dbg !961
  %3 = alloca i16, i16 1, align 2, !dbg !963
  %4 = alloca i16, i16 1, align 2, !dbg !964
  store i16 %0, i16* %4, align 2, !dbg !964
  %5 = load i16, i16* %4, align 2, !dbg !965
  store i16 %5, i16* %3, align 2, !dbg !963
  %6 = load i16, i16* %3, align 2, !dbg !966
  %7 = shl i16 %6, 1, !dbg !967
  %8 = inttoptr i16 %7 to i16*, !dbg !967
  call void asm sideeffect "nop", ""(), !dbg !967
  call void asm sideeffect "nop", ""(), !dbg !967
  call void asm sideeffect "nop", ""(), !dbg !967
  call void asm sideeffect "nop", ""(), !dbg !967
  %9 = load volatile i16, i16* %8, align 2, !dbg !967
  store i16 %9, i16* %2, align 2, !dbg !961
  %10 = load i16, i16* %2, align 2, !dbg !968
  %11 = and i16 %10, -16, !dbg !969
  store i16 %11, i16* %2, align 2, !dbg !969
  %12 = load i16, i16* %3, align 2, !dbg !970
  %13 = load i16, i16* %2, align 2, !dbg !971
  %14 = shl i16 %12, 1, !dbg !972
  %15 = inttoptr i16 %14 to i16*, !dbg !972
  store volatile i16 %13, i16* %15, align 2, !dbg !972
  call void asm sideeffect "nop", ""(), !dbg !972
  call void asm sideeffect "nop", ""(), !dbg !972
  call void asm sideeffect "nop", ""(), !dbg !972
  call void asm sideeffect "nop", ""(), !dbg !972
  ret void, !dbg !973
}

define internal void @__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 %0) !dbg !974 {
  %2 = alloca i16, i16 1, align 2, !dbg !976
  %3 = alloca i16, i16 1, align 2, !dbg !978
  %4 = alloca i16, i16 1, align 2, !dbg !979
  store i16 %0, i16* %4, align 2, !dbg !979
  %5 = load i16, i16* %4, align 2, !dbg !980
  store i16 %5, i16* %3, align 2, !dbg !978
  %6 = load i16, i16* %3, align 2, !dbg !981
  %7 = shl i16 %6, 1, !dbg !982
  %8 = inttoptr i16 %7 to i16*, !dbg !982
  call void asm sideeffect "nop", ""(), !dbg !982
  call void asm sideeffect "nop", ""(), !dbg !982
  %9 = load volatile i16, i16* %8, align 2, !dbg !982
  store i16 %9, i16* %2, align 2, !dbg !976
  %10 = load i16, i16* %2, align 2, !dbg !983
  %11 = and i16 %10, -256, !dbg !984
  store i16 %11, i16* %2, align 2, !dbg !985
  %12 = load i16, i16* %2, align 2, !dbg !986
  %13 = load i16, i16* %2, align 2, !dbg !987
  %14 = call i16 @__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %13), !dbg !988
  %15 = or i16 %12, %14, !dbg !989
  store i16 %15, i16* %2, align 2, !dbg !989
  %16 = load i16, i16* %2, align 2, !dbg !990
  %17 = load i16, i16* %2, align 2, !dbg !991
  %18 = call i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %17), !dbg !992
  %19 = or i16 %16, %18, !dbg !993
  store i16 %19, i16* %2, align 2, !dbg !993
  %20 = load i16, i16* %3, align 2, !dbg !994
  %21 = load i16, i16* %2, align 2, !dbg !995
  %22 = shl i16 %20, 1, !dbg !996
  %23 = inttoptr i16 %22 to i16*, !dbg !996
  store volatile i16 %21, i16* %23, align 2, !dbg !996
  call void asm sideeffect "nop", ""(), !dbg !996
  call void asm sideeffect "nop", ""(), !dbg !996
  ret void, !dbg !997
}

define internal void @__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 %0) !dbg !998 {
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
  %9 = load volatile i16, i16* %8, align 2, !dbg !1005
  store i16 %9, i16* %2, align 2, !dbg !999
  %10 = load i16, i16* %2, align 2, !dbg !1006
  %11 = and i16 %10, -256, !dbg !1007
  store i16 %11, i16* %2, align 2, !dbg !1008
  %12 = load i16, i16* %2, align 2, !dbg !1009
  %13 = load i16, i16* %2, align 2, !dbg !1010
  %14 = call i16 @__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %13), !dbg !1011
  %15 = or i16 %12, %14, !dbg !1012
  store i16 %15, i16* %2, align 2, !dbg !1012
  %16 = load i16, i16* %2, align 2, !dbg !1013
  %17 = load i16, i16* %2, align 2, !dbg !1014
  %18 = call i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %17), !dbg !1015
  %19 = or i16 %16, %18, !dbg !1016
  store i16 %19, i16* %2, align 2, !dbg !1016
  %20 = load i16, i16* %3, align 2, !dbg !1017
  %21 = load i16, i16* %2, align 2, !dbg !1018
  %22 = shl i16 %20, 1, !dbg !1019
  %23 = inttoptr i16 %22 to i16*, !dbg !1019
  store volatile i16 %21, i16* %23, align 2, !dbg !1019
  call void asm sideeffect "nop", ""(), !dbg !1019
  call void asm sideeffect "nop", ""(), !dbg !1019
  ret void, !dbg !1020
}

define internal i16 @__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %0) !dbg !1021 {
  %2 = alloca i16, i16 1, align 2, !dbg !1022
  %3 = alloca i16, i16 1, align 2, !dbg !1024
  store i16 %0, i16* %3, align 2, !dbg !1024
  %4 = load i16, i16* %3, align 2, !dbg !1025
  store i16 %4, i16* %2, align 2, !dbg !1022
  %5 = load i16, i16* %2, align 2, !dbg !1026
  store i16 %5, i16* %2, align 2, !dbg !1027
  %6 = load i16, i16* %2, align 2, !dbg !1028
  ret i16 %6, !dbg !1029
}

define internal i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %0) !dbg !1030 {
  %2 = alloca i16, i16 1, align 2, !dbg !1031
  %3 = alloca i16, i16 1, align 2, !dbg !1033
  store i16 %0, i16* %3, align 2, !dbg !1033
  %4 = load i16, i16* %3, align 2, !dbg !1034
  store i16 %4, i16* %2, align 2, !dbg !1031
  %5 = load i16, i16* %2, align 2, !dbg !1035
  %6 = or i16 %5, 2, !dbg !1036
  store i16 %6, i16* %2, align 2, !dbg !1036
  %7 = load i16, i16* %2, align 2, !dbg !1037
  ret i16 %7, !dbg !1038
}

define internal i16 @__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %0) !dbg !1039 {
  %2 = alloca i16, i16 1, align 2, !dbg !1040
  %3 = alloca i16, i16 1, align 2, !dbg !1042
  store i16 %0, i16* %3, align 2, !dbg !1042
  %4 = load i16, i16* %3, align 2, !dbg !1043
  store i16 %4, i16* %2, align 2, !dbg !1040
  %5 = load i16, i16* %2, align 2, !dbg !1044
  %6 = or i16 %5, 128, !dbg !1045
  store i16 %6, i16* %2, align 2, !dbg !1045
  %7 = load i16, i16* %2, align 2, !dbg !1046
  ret i16 %7, !dbg !1047
}

define internal void @__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction(i16 %0) !dbg !1048 {
  %2 = alloca i16, i16 1, align 2, !dbg !1049
  %3 = alloca i16, i16 1, align 2, !dbg !1051
  %4 = alloca i16, i16 1, align 2, !dbg !1052
  store i16 %0, i16* %4, align 2, !dbg !1052
  %5 = load i16, i16* %4, align 2, !dbg !1053
  store i16 %5, i16* %3, align 2, !dbg !1051
  %6 = load i16, i16* %3, align 2, !dbg !1054
  %7 = shl i16 %6, 1, !dbg !1055
  %8 = inttoptr i16 %7 to i16*, !dbg !1055
  call void asm sideeffect "nop", ""(), !dbg !1055
  call void asm sideeffect "nop", ""(), !dbg !1055
  %9 = load volatile i16, i16* %8, align 2, !dbg !1055
  store i16 %9, i16* %2, align 2, !dbg !1049
  %10 = load i16, i16* %2, align 2, !dbg !1056
  %11 = and i16 %10, -17, !dbg !1057
  store i16 %11, i16* %2, align 2, !dbg !1057
  %12 = load i16, i16* %3, align 2, !dbg !1058
  %13 = load i16, i16* %2, align 2, !dbg !1059
  %14 = shl i16 %12, 1, !dbg !1060
  %15 = inttoptr i16 %14 to i16*, !dbg !1060
  store volatile i16 %13, i16* %15, align 2, !dbg !1060
  call void asm sideeffect "nop", ""(), !dbg !1060
  call void asm sideeffect "nop", ""(), !dbg !1060
  ret void, !dbg !1061
}

define internal void @__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction(i16 %0) !dbg !1062 {
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
  %11 = or i16 %10, 16, !dbg !1071
  store i16 %11, i16* %2, align 2, !dbg !1071
  %12 = load i16, i16* %3, align 2, !dbg !1072
  %13 = load i16, i16* %2, align 2, !dbg !1073
  %14 = shl i16 %12, 1, !dbg !1074
  %15 = inttoptr i16 %14 to i16*, !dbg !1074
  store volatile i16 %13, i16* %15, align 2, !dbg !1074
  call void asm sideeffect "nop", ""(), !dbg !1074
  call void asm sideeffect "nop", ""(), !dbg !1074
  ret void, !dbg !1075
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

; Function Attrs: argmemonly nofree nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i32(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i32, i1 immarg) #14

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
attributes #14 = { argmemonly nofree nounwind willreturn }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!2}

!0 = distinct !DICompileUnit(language: DW_LANG_C, file: !1, producer: "mlir", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug)
!1 = !DIFile(filename: "./layout.csl", directory: "/")
!2 = !{i32 2, !"Debug Info Version", i32 3}
!3 = distinct !DISubprogram(name: "compute", linkageName: "compute", scope: null, file: !4, line: 15, type: !5, scopeLine: 15, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!4 = !DIFile(filename: "./pe.csl", directory: "/home/USER/xkernel/studies/wse3-characterization/microbench/addfam/cases/loop_comptime")
!5 = !DISubroutineType(types: !6)
!6 = !{}
!7 = !DILocation(line: 16, column: 3, scope: !8)
!8 = !DILexicalBlockFile(scope: !3, file: !4, discriminator: 0)
!9 = !DILocation(line: 16, column: 26, scope: !8)
!10 = !DILocation(line: 16, column: 8, scope: !8)
!11 = !DILocation(line: 16, column: 40, scope: !8)
!12 = !DILocation(line: 16, column: 39, scope: !8)
!13 = !DILocation(line: 16, column: 47, scope: !8)
!14 = !DILocation(line: 16, column: 46, scope: !8)
!15 = !DILocation(line: 16, column: 43, scope: !8)
!16 = !DILocation(line: 16, column: 33, scope: !8)
!17 = !DILocation(line: 16, column: 32, scope: !8)
!18 = !DILocation(line: 16, column: 36, scope: !8)
!19 = !DILocation(line: 17, column: 3, scope: !8)
!20 = distinct !DISubprogram(name: "f_exit", linkageName: "f_exit", scope: null, file: !4, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!21 = !DILocation(line: 20, column: 22, scope: !22)
!22 = !DILexicalBlockFile(scope: !20, file: !4, discriminator: 0)
!23 = !DILocation(line: 20, column: 1, scope: !22)
!24 = distinct !DISubprogram(name: "sys_mod.sys_nop", linkageName: "sys_mod.sys_nop", scope: null, file: !25, line: 90, type: !5, scopeLine: 90, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!25 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/memcpy.csl", directory: "")
!26 = !DILocation(line: 90, column: 1, scope: !27)
!27 = !DILexicalBlockFile(scope: !24, file: !25, discriminator: 0)
!28 = distinct !DISubprogram(name: "sys_mod.unblock_cmd_stream", linkageName: "sys_mod.unblock_cmd_stream", scope: null, file: !25, line: 102, type: !5, scopeLine: 102, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!29 = !DILocation(line: 103, column: 3, scope: !30)
!30 = !DILexicalBlockFile(scope: !28, file: !25, discriminator: 0)
!31 = !DILocation(line: 102, column: 1, scope: !30)
!32 = distinct !DISubprogram(name: "sys_mod.sys_mod.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.unblock_cmd_stream", scope: null, file: !33, line: 307, type: !5, scopeLine: 307, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!33 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpy.csl", directory: "")
!34 = !DILocation(line: 308, column: 5, scope: !35)
!35 = !DILexicalBlockFile(scope: !32, file: !33, discriminator: 0)
!36 = !DILocation(line: 307, column: 1, scope: !35)
!37 = distinct !DISubprogram(name: "sys_mod.sys_mod.teardown_h2d", linkageName: "sys_mod.sys_mod.teardown_h2d", scope: null, file: !33, line: 323, type: !5, scopeLine: 323, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!38 = !DILocation(line: 326, column: 5, scope: !39)
!39 = !DILexicalBlockFile(scope: !37, file: !33, discriminator: 0)
!40 = !DILocation(line: 323, column: 1, scope: !39)
!41 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_ublk_c22", linkageName: "sys_mod.sys_mod.f_ublk_c22", scope: null, file: !33, line: 335, type: !5, scopeLine: 335, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!42 = !DILocation(line: 336, column: 5, scope: !43)
!43 = !DILexicalBlockFile(scope: !41, file: !33, discriminator: 0)
!44 = !DILocation(line: 335, column: 1, scope: !43)
!45 = distinct !DISubprogram(name: "sys_mod.sys_mod.teardown_d2h", linkageName: "sys_mod.sys_mod.teardown_d2h", scope: null, file: !33, line: 344, type: !5, scopeLine: 344, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!46 = !DILocation(line: 355, column: 5, scope: !47)
!47 = !DILexicalBlockFile(scope: !45, file: !33, discriminator: 0)
!48 = !DILocation(line: 359, column: 5, scope: !47)
!49 = !DILocation(line: 344, column: 1, scope: !47)
!50 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_memcpyh2d", linkageName: "sys_mod.sys_mod.f_memcpyh2d", scope: null, file: !33, line: 460, type: !5, scopeLine: 460, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!51 = !DILocation(line: 477, column: 5, scope: !52)
!52 = !DILexicalBlockFile(scope: !50, file: !33, discriminator: 0)
!53 = !DILocation(line: 476, column: 5, scope: !52)
!54 = !DILocation(line: 475, column: 5, scope: !52)
!55 = !DILocation(line: 474, column: 5, scope: !52)
!56 = !DILocation(line: 473, column: 5, scope: !52)
!57 = !DILocation(line: 472, column: 5, scope: !52)
!58 = !DILocation(line: 471, column: 5, scope: !52)
!59 = !DILocation(line: 470, column: 5, scope: !52)
!60 = !DILocation(line: 469, column: 5, scope: !52)
!61 = !DILocation(line: 468, column: 5, scope: !52)
!62 = !DILocation(line: 467, column: 5, scope: !52)
!63 = !DILocation(line: 466, column: 5, scope: !52)
!64 = !DILocation(line: 465, column: 5, scope: !52)
!65 = !DILocation(line: 463, column: 5, scope: !52)
!66 = !DILocation(line: 462, column: 20, scope: !52)
!67 = !DILocation(line: 462, column: 32, scope: !52)
!68 = !DILocation(line: 462, column: 5, scope: !52)
!69 = !DILocation(line: 465, column: 33, scope: !52)
!70 = !DILocation(line: 465, column: 38, scope: !52)
!71 = !DILocation(line: 466, column: 34, scope: !52)
!72 = !DILocation(line: 466, column: 39, scope: !52)
!73 = !DILocation(line: 467, column: 34, scope: !52)
!74 = !DILocation(line: 467, column: 39, scope: !52)
!75 = !DILocation(line: 468, column: 33, scope: !52)
!76 = !DILocation(line: 468, column: 38, scope: !52)
!77 = !DILocation(line: 469, column: 33, scope: !52)
!78 = !DILocation(line: 469, column: 38, scope: !52)
!79 = !DILocation(line: 470, column: 35, scope: !52)
!80 = !DILocation(line: 470, column: 21, scope: !52)
!81 = !DILocation(line: 471, column: 41, scope: !52)
!82 = !DILocation(line: 471, column: 27, scope: !52)
!83 = !DILocation(line: 472, column: 39, scope: !52)
!84 = !DILocation(line: 472, column: 25, scope: !52)
!85 = !DILocation(line: 473, column: 44, scope: !52)
!86 = !DILocation(line: 473, column: 49, scope: !52)
!87 = !DILocation(line: 474, column: 41, scope: !52)
!88 = !DILocation(line: 474, column: 46, scope: !52)
!89 = !DILocation(line: 475, column: 41, scope: !52)
!90 = !DILocation(line: 475, column: 46, scope: !52)
!91 = !DILocation(line: 476, column: 59, scope: !52)
!92 = !DILocation(line: 476, column: 64, scope: !52)
!93 = !DILocation(line: 476, column: 50, scope: !52)
!94 = !DILocation(line: 476, column: 129, scope: !52)
!95 = !DILocation(line: 476, column: 134, scope: !52)
!96 = !DILocation(line: 476, column: 120, scope: !52)
!97 = !DILocation(line: 476, column: 118, scope: !52)
!98 = !DILocation(line: 476, column: 112, scope: !52)
!99 = !DILocation(line: 476, column: 36, scope: !52)
!100 = !DILocation(line: 477, column: 59, scope: !52)
!101 = !DILocation(line: 477, column: 64, scope: !52)
!102 = !DILocation(line: 477, column: 50, scope: !52)
!103 = !DILocation(line: 477, column: 129, scope: !52)
!104 = !DILocation(line: 477, column: 134, scope: !52)
!105 = !DILocation(line: 477, column: 120, scope: !52)
!106 = !DILocation(line: 477, column: 118, scope: !52)
!107 = !DILocation(line: 477, column: 112, scope: !52)
!108 = !DILocation(line: 477, column: 36, scope: !52)
!109 = !DILocation(line: 479, column: 24, scope: !52)
!110 = !DILocation(line: 481, column: 21, scope: !52)
!111 = !DILocation(line: 481, column: 19, scope: !52)
!112 = !DILocation(line: 482, column: 21, scope: !52)
!113 = !DILocation(line: 482, column: 19, scope: !52)
!114 = !DILocation(line: 483, column: 21, scope: !52)
!115 = !DILocation(line: 483, column: 19, scope: !52)
!116 = !DILocation(line: 484, column: 20, scope: !52)
!117 = !DILocation(line: 484, column: 18, scope: !52)
!118 = !DILocation(line: 485, column: 20, scope: !52)
!119 = !DILocation(line: 485, column: 18, scope: !52)
!120 = !DILocation(line: 486, column: 22, scope: !52)
!121 = !DILocation(line: 486, column: 20, scope: !52)
!122 = !DILocation(line: 487, column: 27, scope: !52)
!123 = !DILocation(line: 487, column: 25, scope: !52)
!124 = !DILocation(line: 488, column: 25, scope: !52)
!125 = !DILocation(line: 488, column: 23, scope: !52)
!126 = !DILocation(line: 489, column: 31, scope: !52)
!127 = !DILocation(line: 489, column: 29, scope: !52)
!128 = !DILocation(line: 490, column: 28, scope: !52)
!129 = !DILocation(line: 490, column: 26, scope: !52)
!130 = !DILocation(line: 491, column: 28, scope: !52)
!131 = !DILocation(line: 491, column: 26, scope: !52)
!132 = !DILocation(line: 492, column: 37, scope: !52)
!133 = !DILocation(line: 492, column: 35, scope: !52)
!134 = !DILocation(line: 493, column: 37, scope: !52)
!135 = !DILocation(line: 493, column: 35, scope: !52)
!136 = !DILocation(line: 495, column: 5, scope: !52)
!137 = !DILocation(line: 501, column: 5, scope: !52)
!138 = !DILocation(line: 506, column: 5, scope: !52)
!139 = !DILocation(line: 521, column: 5, scope: !52)
!140 = !DILocation(line: 522, column: 16, scope: !52)
!141 = !DILocation(line: 531, column: 5, scope: !52)
!142 = !DILocation(line: 460, column: 1, scope: !52)
!143 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_memcpyd2h", linkageName: "sys_mod.sys_mod.f_memcpyd2h", scope: null, file: !33, line: 556, type: !5, scopeLine: 556, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!144 = !DILocation(line: 568, column: 5, scope: !145)
!145 = !DILexicalBlockFile(scope: !143, file: !33, discriminator: 0)
!146 = !DILocation(line: 567, column: 5, scope: !145)
!147 = !DILocation(line: 566, column: 5, scope: !145)
!148 = !DILocation(line: 565, column: 5, scope: !145)
!149 = !DILocation(line: 564, column: 5, scope: !145)
!150 = !DILocation(line: 563, column: 5, scope: !145)
!151 = !DILocation(line: 562, column: 5, scope: !145)
!152 = !DILocation(line: 561, column: 5, scope: !145)
!153 = !DILocation(line: 559, column: 5, scope: !145)
!154 = !DILocation(line: 558, column: 20, scope: !145)
!155 = !DILocation(line: 558, column: 32, scope: !145)
!156 = !DILocation(line: 558, column: 5, scope: !145)
!157 = !DILocation(line: 561, column: 33, scope: !145)
!158 = !DILocation(line: 561, column: 38, scope: !145)
!159 = !DILocation(line: 562, column: 34, scope: !145)
!160 = !DILocation(line: 562, column: 39, scope: !145)
!161 = !DILocation(line: 563, column: 34, scope: !145)
!162 = !DILocation(line: 563, column: 39, scope: !145)
!163 = !DILocation(line: 564, column: 33, scope: !145)
!164 = !DILocation(line: 564, column: 38, scope: !145)
!165 = !DILocation(line: 565, column: 33, scope: !145)
!166 = !DILocation(line: 565, column: 38, scope: !145)
!167 = !DILocation(line: 566, column: 35, scope: !145)
!168 = !DILocation(line: 566, column: 21, scope: !145)
!169 = !DILocation(line: 567, column: 41, scope: !145)
!170 = !DILocation(line: 567, column: 27, scope: !145)
!171 = !DILocation(line: 568, column: 39, scope: !145)
!172 = !DILocation(line: 568, column: 25, scope: !145)
!173 = !DILocation(line: 570, column: 24, scope: !145)
!174 = !DILocation(line: 573, column: 21, scope: !145)
!175 = !DILocation(line: 573, column: 19, scope: !145)
!176 = !DILocation(line: 574, column: 21, scope: !145)
!177 = !DILocation(line: 574, column: 19, scope: !145)
!178 = !DILocation(line: 575, column: 21, scope: !145)
!179 = !DILocation(line: 575, column: 19, scope: !145)
!180 = !DILocation(line: 576, column: 20, scope: !145)
!181 = !DILocation(line: 576, column: 18, scope: !145)
!182 = !DILocation(line: 577, column: 20, scope: !145)
!183 = !DILocation(line: 577, column: 18, scope: !145)
!184 = !DILocation(line: 578, column: 22, scope: !145)
!185 = !DILocation(line: 578, column: 20, scope: !145)
!186 = !DILocation(line: 579, column: 27, scope: !145)
!187 = !DILocation(line: 579, column: 25, scope: !145)
!188 = !DILocation(line: 580, column: 25, scope: !145)
!189 = !DILocation(line: 580, column: 23, scope: !145)
!190 = !DILocation(line: 582, column: 5, scope: !145)
!191 = !DILocation(line: 588, column: 59, scope: !145)
!192 = !DILocation(line: 588, column: 5, scope: !145)
!193 = !DILocation(line: 608, column: 5, scope: !145)
!194 = !DILocation(line: 609, column: 16, scope: !145)
!195 = !DILocation(line: 556, column: 1, scope: !145)
!196 = distinct !DISubprogram(name: "sys_mod.sys_mod.oq0_teardow_handler", linkageName: "sys_mod.sys_mod.oq0_teardow_handler", scope: null, file: !33, line: 631, type: !5, scopeLine: 631, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!197 = !DILocation(line: 632, column: 9, scope: !198)
!198 = !DILexicalBlockFile(scope: !196, file: !33, discriminator: 0)
!199 = !DILocation(line: 632, column: 5, scope: !198)
!200 = !DILocation(line: 634, column: 66, scope: !198)
!201 = !DILocation(line: 634, column: 9, scope: !198)
!202 = !DILocation(line: 636, column: 13, scope: !198)
!203 = !DILocation(line: 637, column: 13, scope: !198)
!204 = !DILocation(line: 638, column: 13, scope: !198)
!205 = !DILocation(line: 639, column: 13, scope: !198)
!206 = !DILocation(line: 640, column: 13, scope: !198)
!207 = !DILocation(line: 641, column: 13, scope: !198)
!208 = !DILocation(line: 642, column: 13, scope: !198)
!209 = !DILocation(line: 643, column: 13, scope: !198)
!210 = !DILocation(line: 644, column: 13, scope: !198)
!211 = !DILocation(line: 645, column: 13, scope: !198)
!212 = !DILocation(line: 646, column: 13, scope: !198)
!213 = !DILocation(line: 647, column: 13, scope: !198)
!214 = !DILocation(line: 648, column: 13, scope: !198)
!215 = !DILocation(line: 635, column: 9, scope: !198)
!216 = !DILocation(line: 652, column: 9, scope: !198)
!217 = !DILocation(line: 654, column: 13, scope: !198)
!218 = !DILocation(line: 655, column: 13, scope: !198)
!219 = !DILocation(line: 656, column: 13, scope: !198)
!220 = !DILocation(line: 657, column: 13, scope: !198)
!221 = !DILocation(line: 658, column: 13, scope: !198)
!222 = !DILocation(line: 659, column: 13, scope: !198)
!223 = !DILocation(line: 660, column: 13, scope: !198)
!224 = !DILocation(line: 661, column: 13, scope: !198)
!225 = !DILocation(line: 653, column: 9, scope: !198)
!226 = !DILocation(line: 664, column: 5, scope: !198)
!227 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_rpc", linkageName: "sys_mod.sys_mod.f_rpc", scope: null, file: !33, line: 694, type: !5, scopeLine: 694, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!228 = !DILocation(line: 694, column: 13, scope: !229)
!229 = !DILexicalBlockFile(scope: !227, file: !33, discriminator: 0)
!230 = !DILocation(line: 700, column: 5, scope: !229)
!231 = !DILocation(line: 706, column: 20, scope: !229)
!232 = !DILocation(line: 706, column: 32, scope: !229)
!233 = !DILocation(line: 706, column: 5, scope: !229)
!234 = !DILocation(line: 710, column: 5, scope: !229)
!235 = !DILocation(line: 712, column: 24, scope: !229)
!236 = !DILocation(line: 694, column: 1, scope: !229)
!237 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.stack_push", linkageName: "sys_mod.sys_mod.sys_mod.stack_push", scope: null, file: !238, line: 54, type: !5, scopeLine: 54, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!238 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/sys.csl", directory: "")
!239 = !DILocation(line: 60, column: 5, scope: !240)
!240 = !DILexicalBlockFile(scope: !237, file: !238, discriminator: 0)
!241 = !DILocation(line: 54, column: 16, scope: !240)
!242 = !DILocation(line: 59, column: 13, scope: !240)
!243 = !DILocation(line: 59, column: 24, scope: !240)
!244 = !DILocation(line: 59, column: 5, scope: !240)
!245 = !DILocation(line: 61, column: 25, scope: !240)
!246 = !DILocation(line: 61, column: 5, scope: !240)
!247 = !DILocation(line: 61, column: 11, scope: !240)
!248 = !DILocation(line: 61, column: 10, scope: !240)
!249 = !DILocation(line: 61, column: 23, scope: !240)
!250 = !DILocation(line: 62, column: 18, scope: !240)
!251 = !DILocation(line: 62, column: 29, scope: !240)
!252 = !DILocation(line: 62, column: 16, scope: !240)
!253 = !DILocation(line: 54, column: 1, scope: !240)
!254 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_push", linkageName: "sys_mod.sys_mod.sys_mod.f_push", scope: null, file: !238, line: 72, type: !5, scopeLine: 72, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!255 = !DILocation(line: 72, column: 25, scope: !256)
!256 = !DILexicalBlockFile(scope: !254, file: !238, discriminator: 0)
!257 = !DILocation(line: 72, column: 13, scope: !256)
!258 = !DILocation(line: 73, column: 16, scope: !256)
!259 = !DILocation(line: 73, column: 5, scope: !256)
!260 = !DILocation(line: 72, column: 1, scope: !256)
!261 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.block_cmd_stream", linkageName: "sys_mod.sys_mod.sys_mod.block_cmd_stream", scope: null, file: !238, line: 76, type: !5, scopeLine: 76, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!262 = !DILocation(line: 77, column: 5, scope: !263)
!263 = !DILexicalBlockFile(scope: !261, file: !238, discriminator: 0)
!264 = !DILocation(line: 76, column: 1, scope: !263)
!265 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.sys_mod.unblock_cmd_stream", scope: null, file: !238, line: 80, type: !5, scopeLine: 80, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!266 = !DILocation(line: 81, column: 5, scope: !267)
!267 = !DILexicalBlockFile(scope: !265, file: !238, discriminator: 0)
!268 = !DILocation(line: 80, column: 1, scope: !267)
!269 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_sys_exit", linkageName: "sys_mod.sys_mod.sys_mod.f_sys_exit", scope: null, file: !238, line: 85, type: !5, scopeLine: 85, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!270 = !DILocation(line: 86, column: 5, scope: !271)
!271 = !DILexicalBlockFile(scope: !269, file: !238, discriminator: 0)
!272 = !DILocation(line: 87, column: 5, scope: !271)
!273 = !DILocation(line: 85, column: 1, scope: !271)
!274 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore", linkageName: "sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore", scope: null, file: !238, line: 90, type: !5, scopeLine: 90, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!275 = !DILocation(line: 90, column: 30, scope: !276)
!276 = !DILexicalBlockFile(scope: !274, file: !238, discriminator: 0)
!277 = !DILocation(line: 90, column: 1, scope: !276)
!278 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord", scope: null, file: !279, line: 131, type: !5, scopeLine: 131, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!279 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpyh2d.csl", directory: "")
!280 = !DILocation(line: 132, column: 12, scope: !281)
!281 = !DILexicalBlockFile(scope: !278, file: !279, discriminator: 0)
!282 = !DILocation(line: 132, column: 5, scope: !281)
!283 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord", scope: null, file: !279, line: 134, type: !5, scopeLine: 134, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!284 = !DILocation(line: 135, column: 12, scope: !285)
!285 = !DILexicalBlockFile(scope: !283, file: !279, discriminator: 0)
!286 = !DILocation(line: 135, column: 5, scope: !285)
!287 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval", scope: null, file: !279, line: 148, type: !5, scopeLine: 148, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!288 = !DILocation(line: 148, column: 23, scope: !289)
!289 = !DILexicalBlockFile(scope: !287, file: !279, discriminator: 0)
!290 = !DILocation(line: 149, column: 9, scope: !289)
!291 = !DILocation(line: 149, column: 20, scope: !289)
!292 = !DILocation(line: 149, column: 5, scope: !289)
!293 = !DILocation(line: 152, column: 23, scope: !289)
!294 = !DILocation(line: 152, column: 20, scope: !289)
!295 = !DILocation(line: 152, column: 9, scope: !289)
!296 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start", scope: null, file: !279, line: 226, type: !5, scopeLine: 226, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!297 = !DILocation(line: 233, column: 5, scope: !298)
!298 = !DILexicalBlockFile(scope: !296, file: !279, discriminator: 0)
!299 = !DILocation(line: 226, column: 49, scope: !298)
!300 = !DILocation(line: 226, column: 32, scope: !298)
!301 = !DILocation(line: 226, column: 21, scope: !298)
!302 = !DILocation(line: 229, column: 37, scope: !298)
!303 = !DILocation(line: 229, column: 52, scope: !298)
!304 = !DILocation(line: 229, column: 19, scope: !298)
!305 = !DILocation(line: 233, column: 71, scope: !298)
!306 = !DILocation(line: 233, column: 55, scope: !298)
!307 = !DILocation(line: 233, column: 25, scope: !298)
!308 = !DILocation(line: 235, column: 37, scope: !298)
!309 = !DILocation(line: 235, column: 52, scope: !298)
!310 = !DILocation(line: 235, column: 19, scope: !298)
!311 = !DILocation(line: 236, column: 28, scope: !298)
!312 = !DILocation(line: 236, column: 5, scope: !298)
!313 = !DILocation(line: 237, column: 28, scope: !298)
!314 = !DILocation(line: 237, column: 5, scope: !298)
!315 = !DILocation(line: 238, column: 13, scope: !298)
!316 = !DILocation(line: 238, column: 11, scope: !298)
!317 = !DILocation(line: 238, column: 5, scope: !298)
!318 = !DILocation(line: 239, column: 9, scope: !298)
!319 = !DILocation(line: 241, column: 9, scope: !298)
!320 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream", scope: null, file: !279, line: 249, type: !5, scopeLine: 249, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!321 = !DILocation(line: 250, column: 5, scope: !322)
!322 = !DILexicalBlockFile(scope: !320, file: !279, discriminator: 0)
!323 = !DILocation(line: 249, column: 1, scope: !322)
!324 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure", scope: null, file: !279, line: 276, type: !5, scopeLine: 276, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!325 = !DILocation(line: 414, column: 13, scope: !326)
!326 = !DILexicalBlockFile(scope: !324, file: !279, discriminator: 0)
!327 = !DILocation(line: 413, column: 13, scope: !326)
!328 = !DILocation(line: 400, column: 17, scope: !326)
!329 = !DILocation(line: 340, column: 9, scope: !326)
!330 = !DILocation(line: 339, column: 9, scope: !326)
!331 = !DILocation(line: 337, column: 5, scope: !326)
!332 = !DILocation(line: 319, column: 9, scope: !326)
!333 = !DILocation(line: 318, column: 9, scope: !326)
!334 = !DILocation(line: 315, column: 5, scope: !326)
!335 = !DILocation(line: 292, column: 5, scope: !326)
!336 = !DILocation(line: 291, column: 5, scope: !326)
!337 = !DILocation(line: 289, column: 5, scope: !326)
!338 = !DILocation(line: 288, column: 5, scope: !326)
!339 = !DILocation(line: 287, column: 5, scope: !326)
!340 = !DILocation(line: 286, column: 5, scope: !326)
!341 = !DILocation(line: 285, column: 5, scope: !326)
!342 = !DILocation(line: 284, column: 5, scope: !326)
!343 = !DILocation(line: 283, column: 5, scope: !326)
!344 = !DILocation(line: 282, column: 5, scope: !326)
!345 = !DILocation(line: 281, column: 5, scope: !326)
!346 = !DILocation(line: 280, column: 5, scope: !326)
!347 = !DILocation(line: 279, column: 5, scope: !326)
!348 = !DILocation(line: 278, column: 5, scope: !326)
!349 = !DILocation(line: 277, column: 5, scope: !326)
!350 = !DILocation(line: 291, column: 26, scope: !326)
!351 = !DILocation(line: 292, column: 26, scope: !326)
!352 = !DILocation(line: 315, column: 25, scope: !326)
!353 = !DILocation(line: 315, column: 31, scope: !326)
!354 = !DILocation(line: 315, column: 29, scope: !326)
!355 = !DILocation(line: 316, column: 20, scope: !326)
!356 = !DILocation(line: 316, column: 18, scope: !326)
!357 = !DILocation(line: 317, column: 52, scope: !326)
!358 = !DILocation(line: 317, column: 49, scope: !326)
!359 = !DILocation(line: 317, column: 5, scope: !326)
!360 = !DILocation(line: 318, column: 42, scope: !326)
!361 = !DILocation(line: 318, column: 33, scope: !326)
!362 = !DILocation(line: 318, column: 49, scope: !326)
!363 = !DILocation(line: 318, column: 48, scope: !326)
!364 = !DILocation(line: 318, column: 24, scope: !326)
!365 = !DILocation(line: 319, column: 24, scope: !326)
!366 = !DILocation(line: 319, column: 32, scope: !326)
!367 = !DILocation(line: 319, column: 36, scope: !326)
!368 = !DILocation(line: 319, column: 34, scope: !326)
!369 = !DILocation(line: 319, column: 30, scope: !326)
!370 = !DILocation(line: 320, column: 18, scope: !326)
!371 = !DILocation(line: 320, column: 15, scope: !326)
!372 = !DILocation(line: 320, column: 9, scope: !326)
!373 = !DILocation(line: 321, column: 26, scope: !326)
!374 = !DILocation(line: 325, column: 28, scope: !326)
!375 = !DILocation(line: 325, column: 26, scope: !326)
!376 = !DILocation(line: 331, column: 9, scope: !326)
!377 = !DILocation(line: 331, column: 15, scope: !326)
!378 = !DILocation(line: 331, column: 5, scope: !326)
!379 = !DILocation(line: 332, column: 22, scope: !326)
!380 = !DILocation(line: 334, column: 9, scope: !326)
!381 = !DILocation(line: 334, column: 18, scope: !326)
!382 = !DILocation(line: 334, column: 15, scope: !326)
!383 = !DILocation(line: 334, column: 5, scope: !326)
!384 = !DILocation(line: 335, column: 22, scope: !326)
!385 = !DILocation(line: 338, column: 52, scope: !326)
!386 = !DILocation(line: 338, column: 49, scope: !326)
!387 = !DILocation(line: 338, column: 5, scope: !326)
!388 = !DILocation(line: 339, column: 42, scope: !326)
!389 = !DILocation(line: 339, column: 48, scope: !326)
!390 = !DILocation(line: 339, column: 46, scope: !326)
!391 = !DILocation(line: 339, column: 33, scope: !326)
!392 = !DILocation(line: 339, column: 52, scope: !326)
!393 = !DILocation(line: 339, column: 51, scope: !326)
!394 = !DILocation(line: 339, column: 24, scope: !326)
!395 = !DILocation(line: 340, column: 25, scope: !326)
!396 = !DILocation(line: 340, column: 31, scope: !326)
!397 = !DILocation(line: 340, column: 29, scope: !326)
!398 = !DILocation(line: 340, column: 37, scope: !326)
!399 = !DILocation(line: 340, column: 41, scope: !326)
!400 = !DILocation(line: 340, column: 39, scope: !326)
!401 = !DILocation(line: 340, column: 35, scope: !326)
!402 = !DILocation(line: 341, column: 18, scope: !326)
!403 = !DILocation(line: 341, column: 15, scope: !326)
!404 = !DILocation(line: 341, column: 9, scope: !326)
!405 = !DILocation(line: 342, column: 26, scope: !326)
!406 = !DILocation(line: 347, column: 10, scope: !326)
!407 = !DILocation(line: 347, column: 16, scope: !326)
!408 = !DILocation(line: 347, column: 14, scope: !326)
!409 = !DILocation(line: 347, column: 5, scope: !326)
!410 = !DILocation(line: 348, column: 22, scope: !326)
!411 = !DILocation(line: 350, column: 10, scope: !326)
!412 = !DILocation(line: 350, column: 18, scope: !326)
!413 = !DILocation(line: 350, column: 21, scope: !326)
!414 = !DILocation(line: 350, column: 20, scope: !326)
!415 = !DILocation(line: 350, column: 14, scope: !326)
!416 = !DILocation(line: 350, column: 5, scope: !326)
!417 = !DILocation(line: 351, column: 22, scope: !326)
!418 = !DILocation(line: 354, column: 9, scope: !326)
!419 = !DILocation(line: 354, column: 5, scope: !326)
!420 = !DILocation(line: 358, column: 9, scope: !326)
!421 = !DILocation(line: 361, column: 9, scope: !326)
!422 = !DILocation(line: 364, column: 20, scope: !326)
!423 = !DILocation(line: 364, column: 17, scope: !326)
!424 = !DILocation(line: 364, column: 9, scope: !326)
!425 = !DILocation(line: 368, column: 13, scope: !326)
!426 = !DILocation(line: 371, column: 13, scope: !326)
!427 = !DILocation(line: 375, column: 13, scope: !326)
!428 = !DILocation(line: 394, column: 13, scope: !326)
!429 = !DILocation(line: 396, column: 29, scope: !326)
!430 = !DILocation(line: 396, column: 27, scope: !326)
!431 = !DILocation(line: 397, column: 60, scope: !326)
!432 = !DILocation(line: 397, column: 57, scope: !326)
!433 = !DILocation(line: 397, column: 13, scope: !326)
!434 = !DILocation(line: 400, column: 54, scope: !326)
!435 = !DILocation(line: 400, column: 55, scope: !326)
!436 = !DILocation(line: 400, column: 46, scope: !326)
!437 = !DILocation(line: 400, column: 59, scope: !326)
!438 = !DILocation(line: 400, column: 58, scope: !326)
!439 = !DILocation(line: 400, column: 37, scope: !326)
!440 = !DILocation(line: 400, column: 35, scope: !326)
!441 = !DILocation(line: 401, column: 33, scope: !326)
!442 = !DILocation(line: 401, column: 31, scope: !326)
!443 = !DILocation(line: 402, column: 69, scope: !326)
!444 = !DILocation(line: 402, column: 66, scope: !326)
!445 = !DILocation(line: 402, column: 19, scope: !326)
!446 = !DILocation(line: 404, column: 31, scope: !326)
!447 = !DILocation(line: 408, column: 75, scope: !326)
!448 = !DILocation(line: 408, column: 88, scope: !326)
!449 = !DILocation(line: 408, column: 13, scope: !326)
!450 = !DILocation(line: 413, column: 31, scope: !326)
!451 = !DILocation(line: 414, column: 33, scope: !326)
!452 = !DILocation(line: 415, column: 21, scope: !326)
!453 = !DILocation(line: 415, column: 29, scope: !326)
!454 = !DILocation(line: 415, column: 27, scope: !326)
!455 = !DILocation(line: 415, column: 19, scope: !326)
!456 = !DILocation(line: 416, column: 22, scope: !326)
!457 = !DILocation(line: 416, column: 19, scope: !326)
!458 = !DILocation(line: 416, column: 13, scope: !326)
!459 = !DILocation(line: 417, column: 23, scope: !326)
!460 = !DILocation(line: 419, column: 63, scope: !326)
!461 = !DILocation(line: 419, column: 60, scope: !326)
!462 = !DILocation(line: 419, column: 13, scope: !326)
!463 = !DILocation(line: 421, column: 23, scope: !326)
!464 = !DILocation(line: 423, column: 69, scope: !326)
!465 = !DILocation(line: 423, column: 13, scope: !326)
!466 = !DILocation(line: 426, column: 13, scope: !326)
!467 = !DILocation(line: 430, column: 13, scope: !326)
!468 = !DILocation(line: 433, column: 48, scope: !326)
!469 = !DILocation(line: 433, column: 22, scope: !326)
!470 = !DILocation(line: 433, column: 19, scope: !326)
!471 = !DILocation(line: 433, column: 13, scope: !326)
!472 = !DILocation(line: 436, column: 34, scope: !326)
!473 = !DILocation(line: 436, column: 39, scope: !326)
!474 = !DILocation(line: 436, column: 50, scope: !326)
!475 = !DILocation(line: 436, column: 17, scope: !326)
!476 = !DILocation(line: 452, column: 49, scope: !326)
!477 = !DILocation(line: 452, column: 64, scope: !326)
!478 = !DILocation(line: 452, column: 31, scope: !326)
!479 = !DILocation(line: 453, column: 40, scope: !326)
!480 = !DILocation(line: 453, column: 17, scope: !326)
!481 = !DILocation(line: 454, column: 50, scope: !326)
!482 = !DILocation(line: 454, column: 66, scope: !326)
!483 = !DILocation(line: 454, column: 32, scope: !326)
!484 = !DILocation(line: 455, column: 40, scope: !326)
!485 = !DILocation(line: 455, column: 17, scope: !326)
!486 = !DILocation(line: 456, column: 17, scope: !326)
!487 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit", scope: null, file: !488, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!488 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/filters/wse3.csl", directory: "")
!489 = !DILocation(line: 24, column: 3, scope: !490)
!490 = !DILexicalBlockFile(scope: !487, file: !488, discriminator: 0)
!491 = !DILocation(line: 24, column: 22, scope: !490)
!492 = !DILocation(line: 23, column: 3, scope: !490)
!493 = !DILocation(line: 22, column: 3, scope: !490)
!494 = !DILocation(line: 20, column: 37, scope: !490)
!495 = !DILocation(line: 20, column: 21, scope: !490)
!496 = !DILocation(line: 21, column: 11, scope: !490)
!497 = !DILocation(line: 21, column: 17, scope: !490)
!498 = !DILocation(line: 21, column: 3, scope: !490)
!499 = !DILocation(line: 22, column: 24, scope: !490)
!500 = !DILocation(line: 22, column: 30, scope: !490)
!501 = !DILocation(line: 23, column: 40, scope: !490)
!502 = !DILocation(line: 23, column: 22, scope: !490)
!503 = !DILocation(line: 23, column: 67, scope: !490)
!504 = !DILocation(line: 24, column: 26, scope: !490)
!505 = !DILocation(line: 24, column: 41, scope: !490)
!506 = !DILocation(line: 24, column: 39, scope: !490)
!507 = !DILocation(line: 24, column: 61, scope: !490)
!508 = !DILocation(line: 24, column: 76, scope: !490)
!509 = !DILocation(line: 24, column: 74, scope: !490)
!510 = !DILocation(line: 25, column: 21, scope: !490)
!511 = !DILocation(line: 25, column: 50, scope: !490)
!512 = !DILocation(line: 25, column: 3, scope: !490)
!513 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter", scope: null, file: !488, line: 30, type: !5, scopeLine: 30, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!514 = !DILocation(line: 30, column: 36, scope: !515)
!515 = !DILexicalBlockFile(scope: !513, file: !488, discriminator: 0)
!516 = !DILocation(line: 30, column: 20, scope: !515)
!517 = !DILocation(line: 31, column: 11, scope: !515)
!518 = !DILocation(line: 31, column: 23, scope: !515)
!519 = !DILocation(line: 31, column: 3, scope: !515)
!520 = !DILocation(line: 32, column: 21, scope: !515)
!521 = !DILocation(line: 32, column: 48, scope: !515)
!522 = !DILocation(line: 32, column: 60, scope: !515)
!523 = !DILocation(line: 32, column: 64, scope: !515)
!524 = !DILocation(line: 32, column: 3, scope: !515)
!525 = !DILocation(line: 30, column: 1, scope: !515)
!526 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter", scope: null, file: !488, line: 40, type: !5, scopeLine: 40, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!527 = !DILocation(line: 47, column: 3, scope: !528)
!528 = !DILexicalBlockFile(scope: !526, file: !488, discriminator: 0)
!529 = !DILocation(line: 48, column: 7, scope: !528)
!530 = !DILocation(line: 44, column: 3, scope: !528)
!531 = !DILocation(line: 43, column: 3, scope: !528)
!532 = !DILocation(line: 42, column: 3, scope: !528)
!533 = !DILocation(line: 40, column: 32, scope: !528)
!534 = !DILocation(line: 40, column: 16, scope: !528)
!535 = !DILocation(line: 41, column: 11, scope: !528)
!536 = !DILocation(line: 41, column: 19, scope: !528)
!537 = !DILocation(line: 41, column: 3, scope: !528)
!538 = !DILocation(line: 42, column: 40, scope: !528)
!539 = !DILocation(line: 42, column: 22, scope: !528)
!540 = !DILocation(line: 43, column: 26, scope: !528)
!541 = !DILocation(line: 43, column: 34, scope: !528)
!542 = !DILocation(line: 44, column: 25, scope: !528)
!543 = !DILocation(line: 44, column: 42, scope: !528)
!544 = !DILocation(line: 44, column: 40, scope: !528)
!545 = !DILocation(line: 45, column: 21, scope: !528)
!546 = !DILocation(line: 46, column: 35, scope: !528)
!547 = !DILocation(line: 46, column: 21, scope: !528)
!548 = !DILocation(line: 46, column: 50, scope: !528)
!549 = !DILocation(line: 45, column: 3, scope: !528)
!550 = !DILocation(line: 48, column: 11, scope: !528)
!551 = !DILocation(line: 48, column: 26, scope: !528)
!552 = !DILocation(line: 48, column: 43, scope: !528)
!553 = !DILocation(line: 48, column: 41, scope: !528)
!554 = !DILocation(line: 48, column: 54, scope: !528)
!555 = !DILocation(line: 48, column: 63, scope: !528)
!556 = !DILocation(line: 49, column: 21, scope: !528)
!557 = !DILocation(line: 49, column: 47, scope: !528)
!558 = !DILocation(line: 49, column: 3, scope: !528)
!559 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config", scope: null, file: !560, line: 33, type: !5, scopeLine: 33, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!560 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/filters/common.csl", directory: "")
!561 = !DILocation(line: 33, column: 46, scope: !562)
!562 = !DILexicalBlockFile(scope: !559, file: !560, discriminator: 0)
!563 = !DILocation(line: 33, column: 31, scope: !562)
!564 = !DILocation(line: 33, column: 15, scope: !562)
!565 = !DILocation(line: 34, column: 24, scope: !562)
!566 = !DILocation(line: 34, column: 23, scope: !562)
!567 = !DILocation(line: 34, column: 51, scope: !562)
!568 = !DILocation(line: 34, column: 35, scope: !562)
!569 = !DILocation(line: 34, column: 60, scope: !562)
!570 = !DILocation(line: 34, column: 73, scope: !562)
!571 = !DILocation(line: 34, column: 3, scope: !562)
!572 = !DILocation(line: 33, column: 1, scope: !562)
!573 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config", scope: null, file: !560, line: 38, type: !5, scopeLine: 38, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!574 = !DILocation(line: 38, column: 31, scope: !575)
!575 = !DILexicalBlockFile(scope: !573, file: !560, discriminator: 0)
!576 = !DILocation(line: 38, column: 15, scope: !575)
!577 = !DILocation(line: 39, column: 31, scope: !575)
!578 = !DILocation(line: 39, column: 30, scope: !575)
!579 = !DILocation(line: 39, column: 58, scope: !575)
!580 = !DILocation(line: 39, column: 42, scope: !575)
!581 = !DILocation(line: 39, column: 67, scope: !575)
!582 = !DILocation(line: 39, column: 10, scope: !575)
!583 = !DILocation(line: 39, column: 3, scope: !575)
!584 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit", scope: null, file: !585, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!585 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/teardown.csl", directory: "")
!586 = !DILocation(line: 43, column: 3, scope: !587)
!587 = !DILexicalBlockFile(scope: !584, file: !585, discriminator: 0)
!588 = !DILocation(line: 41, column: 3, scope: !587)
!589 = !DILocation(line: 40, column: 3, scope: !587)
!590 = !DILocation(line: 39, column: 9, scope: !587)
!591 = !DILocation(line: 40, column: 23, scope: !587)
!592 = !DILocation(line: 41, column: 70, scope: !587)
!593 = !DILocation(line: 41, column: 68, scope: !587)
!594 = !DILocation(line: 43, column: 27, scope: !587)
!595 = !DILocation(line: 43, column: 15, scope: !587)
!596 = !DILocation(line: 44, column: 15, scope: !587)
!597 = !DILocation(line: 44, column: 21, scope: !587)
!598 = !DILocation(line: 44, column: 27, scope: !587)
!599 = !DILocation(line: 44, column: 3, scope: !587)
!600 = !DILocation(line: 39, column: 1, scope: !587)
!601 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord", scope: null, file: !602, line: 4, type: !5, scopeLine: 4, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!602 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/layout.csl", directory: "")
!603 = !DILocation(line: 5, column: 10, scope: !604)
!604 = !DILexicalBlockFile(scope: !601, file: !602, discriminator: 0)
!605 = !DILocation(line: 5, column: 67, scope: !604)
!606 = !DILocation(line: 5, column: 3, scope: !604)
!607 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord", scope: null, file: !602, line: 8, type: !5, scopeLine: 8, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!608 = !DILocation(line: 9, column: 10, scope: !609)
!609 = !DILexicalBlockFile(scope: !607, file: !602, discriminator: 0)
!610 = !DILocation(line: 9, column: 67, scope: !609)
!611 = !DILocation(line: 9, column: 3, scope: !609)
!612 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord", scope: null, file: !613, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!613 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config.csl", directory: "")
!614 = !DILocation(line: 50, column: 3, scope: !615)
!615 = !DILexicalBlockFile(scope: !612, file: !613, discriminator: 0)
!616 = !DILocation(line: 43, column: 21, scope: !615)
!617 = !DILocation(line: 50, column: 57, scope: !615)
!618 = !DILocation(line: 50, column: 68, scope: !615)
!619 = !DILocation(line: 50, column: 41, scope: !615)
!620 = !DILocation(line: 50, column: 19, scope: !615)
!621 = !DILocation(line: 52, column: 10, scope: !615)
!622 = !DILocation(line: 52, column: 18, scope: !615)
!623 = !DILocation(line: 48, column: 22, scope: !615)
!624 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.get_x_coord", scope: null, file: !625, line: 171, type: !5, scopeLine: 171, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!625 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpyd2h.csl", directory: "")
!626 = !DILocation(line: 172, column: 12, scope: !627)
!627 = !DILexicalBlockFile(scope: !624, file: !625, discriminator: 0)
!628 = !DILocation(line: 172, column: 5, scope: !627)
!629 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.get_y_coord", scope: null, file: !625, line: 174, type: !5, scopeLine: 174, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!630 = !DILocation(line: 175, column: 12, scope: !631)
!631 = !DILexicalBlockFile(scope: !629, file: !625, discriminator: 0)
!632 = !DILocation(line: 175, column: 5, scope: !631)
!633 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval", scope: null, file: !625, line: 187, type: !5, scopeLine: 187, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!634 = !DILocation(line: 187, column: 23, scope: !635)
!635 = !DILexicalBlockFile(scope: !633, file: !625, discriminator: 0)
!636 = !DILocation(line: 188, column: 9, scope: !635)
!637 = !DILocation(line: 188, column: 20, scope: !635)
!638 = !DILocation(line: 188, column: 5, scope: !635)
!639 = !DILocation(line: 191, column: 23, scope: !635)
!640 = !DILocation(line: 191, column: 20, scope: !635)
!641 = !DILocation(line: 191, column: 9, scope: !635)
!642 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start", scope: null, file: !625, line: 383, type: !5, scopeLine: 383, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!643 = !DILocation(line: 386, column: 5, scope: !644)
!644 = !DILexicalBlockFile(scope: !642, file: !625, discriminator: 0)
!645 = !DILocation(line: 384, column: 72, scope: !644)
!646 = !DILocation(line: 384, column: 59, scope: !644)
!647 = !DILocation(line: 384, column: 46, scope: !644)
!648 = !DILocation(line: 384, column: 33, scope: !644)
!649 = !DILocation(line: 384, column: 19, scope: !644)
!650 = !DILocation(line: 384, column: 5, scope: !644)
!651 = !DILocation(line: 383, column: 32, scope: !644)
!652 = !DILocation(line: 383, column: 21, scope: !644)
!653 = !DILocation(line: 386, column: 26, scope: !644)
!654 = !DILocation(line: 388, column: 28, scope: !644)
!655 = !DILocation(line: 388, column: 17, scope: !644)
!656 = !DILocation(line: 389, column: 25, scope: !644)
!657 = !DILocation(line: 389, column: 23, scope: !644)
!658 = !DILocation(line: 391, column: 38, scope: !644)
!659 = !DILocation(line: 391, column: 20, scope: !644)
!660 = !DILocation(line: 391, column: 18, scope: !644)
!661 = !DILocation(line: 393, column: 7, scope: !644)
!662 = !DILocation(line: 395, column: 17, scope: !644)
!663 = !DILocation(line: 395, column: 15, scope: !644)
!664 = !DILocation(line: 397, column: 15, scope: !644)
!665 = !DILocation(line: 397, column: 13, scope: !644)
!666 = !DILocation(line: 398, column: 15, scope: !644)
!667 = !DILocation(line: 398, column: 25, scope: !644)
!668 = !DILocation(line: 398, column: 23, scope: !644)
!669 = !DILocation(line: 398, column: 31, scope: !644)
!670 = !DILocation(line: 398, column: 13, scope: !644)
!671 = !DILocation(line: 401, column: 10, scope: !644)
!672 = !DILocation(line: 401, column: 17, scope: !644)
!673 = !DILocation(line: 401, column: 14, scope: !644)
!674 = !DILocation(line: 401, column: 5, scope: !644)
!675 = !DILocation(line: 403, column: 48, scope: !644)
!676 = !DILocation(line: 403, column: 26, scope: !644)
!677 = !DILocation(line: 404, column: 26, scope: !644)
!678 = !DILocation(line: 404, column: 18, scope: !644)
!679 = !DILocation(line: 407, column: 48, scope: !644)
!680 = !DILocation(line: 407, column: 26, scope: !644)
!681 = !DILocation(line: 408, column: 27, scope: !644)
!682 = !DILocation(line: 408, column: 18, scope: !644)
!683 = !DILocation(line: 411, column: 14, scope: !644)
!684 = !DILocation(line: 414, column: 14, scope: !644)
!685 = !DILocation(line: 414, column: 11, scope: !644)
!686 = !DILocation(line: 414, column: 5, scope: !644)
!687 = !DILocation(line: 416, column: 44, scope: !644)
!688 = !DILocation(line: 416, column: 75, scope: !644)
!689 = !DILocation(line: 416, column: 59, scope: !644)
!690 = !DILocation(line: 416, column: 25, scope: !644)
!691 = !DILocation(line: 416, column: 23, scope: !644)
!692 = !DILocation(line: 418, column: 41, scope: !644)
!693 = !DILocation(line: 418, column: 23, scope: !644)
!694 = !DILocation(line: 419, column: 9, scope: !644)
!695 = !DILocation(line: 425, column: 44, scope: !644)
!696 = !DILocation(line: 425, column: 23, scope: !644)
!697 = !DILocation(line: 426, column: 41, scope: !644)
!698 = !DILocation(line: 426, column: 23, scope: !644)
!699 = !DILocation(line: 427, column: 9, scope: !644)
!700 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x", scope: null, file: !625, line: 448, type: !5, scopeLine: 448, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!701 = !DILocation(line: 448, column: 31, scope: !702)
!702 = !DILexicalBlockFile(scope: !700, file: !625, discriminator: 0)
!703 = !DILocation(line: 453, column: 5, scope: !702)
!704 = !DILocation(line: 456, column: 19, scope: !702)
!705 = !DILocation(line: 456, column: 17, scope: !702)
!706 = !DILocation(line: 461, column: 5, scope: !702)
!707 = !DILocation(line: 462, column: 28, scope: !702)
!708 = !DILocation(line: 462, column: 5, scope: !702)
!709 = !DILocation(line: 463, column: 5, scope: !702)
!710 = !DILocation(line: 464, column: 9, scope: !702)
!711 = !DILocation(line: 464, column: 10, scope: !702)
!712 = !DILocation(line: 464, column: 7, scope: !702)
!713 = !DILocation(line: 448, column: 1, scope: !702)
!714 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_send_data", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_send_data", scope: null, file: !625, line: 476, type: !5, scopeLine: 476, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!715 = !DILocation(line: 494, column: 9, scope: !716)
!716 = !DILexicalBlockFile(scope: !714, file: !625, discriminator: 0)
!717 = !DILocation(line: 478, column: 9, scope: !716)
!718 = !DILocation(line: 478, column: 13, scope: !716)
!719 = !DILocation(line: 478, column: 11, scope: !716)
!720 = !DILocation(line: 478, column: 5, scope: !716)
!721 = !DILocation(line: 479, column: 9, scope: !716)
!722 = !DILocation(line: 480, column: 32, scope: !716)
!723 = !DILocation(line: 480, column: 9, scope: !716)
!724 = !DILocation(line: 481, column: 17, scope: !716)
!725 = !DILocation(line: 481, column: 15, scope: !716)
!726 = !DILocation(line: 481, column: 9, scope: !716)
!727 = !DILocation(line: 482, column: 13, scope: !716)
!728 = !DILocation(line: 483, column: 51, scope: !716)
!729 = !DILocation(line: 483, column: 29, scope: !716)
!730 = !DILocation(line: 483, column: 27, scope: !716)
!731 = !DILocation(line: 485, column: 13, scope: !716)
!732 = !DILocation(line: 486, column: 51, scope: !716)
!733 = !DILocation(line: 486, column: 29, scope: !716)
!734 = !DILocation(line: 486, column: 27, scope: !716)
!735 = !DILocation(line: 488, column: 13, scope: !716)
!736 = !DILocation(line: 488, column: 14, scope: !716)
!737 = !DILocation(line: 488, column: 11, scope: !716)
!738 = !DILocation(line: 494, column: 30, scope: !716)
!739 = !DILocation(line: 496, column: 14, scope: !716)
!740 = !DILocation(line: 496, column: 25, scope: !716)
!741 = !DILocation(line: 496, column: 22, scope: !716)
!742 = !DILocation(line: 496, column: 9, scope: !716)
!743 = !DILocation(line: 497, column: 13, scope: !716)
!744 = !DILocation(line: 498, column: 13, scope: !716)
!745 = !DILocation(line: 499, column: 13, scope: !716)
!746 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl", scope: null, file: !625, line: 505, type: !5, scopeLine: 505, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!747 = !DILocation(line: 524, column: 13, scope: !748)
!748 = !DILexicalBlockFile(scope: !746, file: !625, discriminator: 0)
!749 = !DILocation(line: 506, column: 14, scope: !748)
!750 = !DILocation(line: 506, column: 11, scope: !748)
!751 = !DILocation(line: 506, column: 5, scope: !748)
!752 = !DILocation(line: 508, column: 9, scope: !748)
!753 = !DILocation(line: 509, column: 32, scope: !748)
!754 = !DILocation(line: 509, column: 9, scope: !748)
!755 = !DILocation(line: 510, column: 9, scope: !748)
!756 = !DILocation(line: 514, column: 13, scope: !748)
!757 = !DILocation(line: 514, column: 17, scope: !748)
!758 = !DILocation(line: 514, column: 15, scope: !748)
!759 = !DILocation(line: 514, column: 9, scope: !748)
!760 = !DILocation(line: 518, column: 13, scope: !748)
!761 = !DILocation(line: 519, column: 36, scope: !748)
!762 = !DILocation(line: 519, column: 13, scope: !748)
!763 = !DILocation(line: 520, column: 13, scope: !748)
!764 = !DILocation(line: 524, column: 34, scope: !748)
!765 = !DILocation(line: 526, column: 18, scope: !748)
!766 = !DILocation(line: 526, column: 29, scope: !748)
!767 = !DILocation(line: 526, column: 26, scope: !748)
!768 = !DILocation(line: 526, column: 13, scope: !748)
!769 = !DILocation(line: 529, column: 17, scope: !748)
!770 = !DILocation(line: 530, column: 17, scope: !748)
!771 = !DILocation(line: 531, column: 17, scope: !748)
!772 = !DILocation(line: 534, column: 17, scope: !748)
!773 = !DILocation(line: 535, column: 40, scope: !748)
!774 = !DILocation(line: 535, column: 17, scope: !748)
!775 = !DILocation(line: 536, column: 17, scope: !748)
!776 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.d2h_configure", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.d2h_configure", scope: null, file: !625, line: 593, type: !5, scopeLine: 593, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!777 = !DILocation(line: 617, column: 26, scope: !778)
!778 = !DILexicalBlockFile(scope: !776, file: !625, discriminator: 0)
!779 = !DILocation(line: 612, column: 47, scope: !778)
!780 = !DILocation(line: 612, column: 27, scope: !778)
!781 = !DILocation(line: 602, column: 5, scope: !778)
!782 = !DILocation(line: 601, column: 5, scope: !778)
!783 = !DILocation(line: 599, column: 5, scope: !778)
!784 = !DILocation(line: 598, column: 5, scope: !778)
!785 = !DILocation(line: 596, column: 5, scope: !778)
!786 = !DILocation(line: 595, column: 5, scope: !778)
!787 = !DILocation(line: 593, column: 86, scope: !778)
!788 = !DILocation(line: 593, column: 70, scope: !778)
!789 = !DILocation(line: 593, column: 60, scope: !778)
!790 = !DILocation(line: 593, column: 52, scope: !778)
!791 = !DILocation(line: 593, column: 44, scope: !778)
!792 = !DILocation(line: 593, column: 35, scope: !778)
!793 = !DILocation(line: 593, column: 26, scope: !778)
!794 = !DILocation(line: 593, column: 18, scope: !778)
!795 = !DILocation(line: 595, column: 26, scope: !778)
!796 = !DILocation(line: 596, column: 26, scope: !778)
!797 = !DILocation(line: 598, column: 23, scope: !778)
!798 = !DILocation(line: 599, column: 23, scope: !778)
!799 = !DILocation(line: 599, column: 28, scope: !778)
!800 = !DILocation(line: 599, column: 26, scope: !778)
!801 = !DILocation(line: 599, column: 29, scope: !778)
!802 = !DILocation(line: 601, column: 24, scope: !778)
!803 = !DILocation(line: 602, column: 24, scope: !778)
!804 = !DILocation(line: 602, column: 29, scope: !778)
!805 = !DILocation(line: 602, column: 27, scope: !778)
!806 = !DILocation(line: 602, column: 30, scope: !778)
!807 = !DILocation(line: 611, column: 20, scope: !778)
!808 = !DILocation(line: 612, column: 11, scope: !778)
!809 = !DILocation(line: 612, column: 18, scope: !778)
!810 = !DILocation(line: 612, column: 15, scope: !778)
!811 = !DILocation(line: 612, column: 32, scope: !778)
!812 = !DILocation(line: 612, column: 39, scope: !778)
!813 = !DILocation(line: 612, column: 36, scope: !778)
!814 = !DILocation(line: 612, column: 52, scope: !778)
!815 = !DILocation(line: 612, column: 59, scope: !778)
!816 = !DILocation(line: 612, column: 56, scope: !778)
!817 = !DILocation(line: 612, column: 5, scope: !778)
!818 = !DILocation(line: 613, column: 24, scope: !778)
!819 = !DILocation(line: 616, column: 15, scope: !778)
!820 = !DILocation(line: 617, column: 11, scope: !778)
!821 = !DILocation(line: 617, column: 18, scope: !778)
!822 = !DILocation(line: 617, column: 15, scope: !778)
!823 = !DILocation(line: 617, column: 30, scope: !778)
!824 = !DILocation(line: 617, column: 5, scope: !778)
!825 = !DILocation(line: 618, column: 19, scope: !778)
!826 = !DILocation(line: 621, column: 9, scope: !778)
!827 = !DILocation(line: 621, column: 5, scope: !778)
!828 = !DILocation(line: 627, column: 9, scope: !778)
!829 = !DILocation(line: 629, column: 13, scope: !778)
!830 = !DILocation(line: 629, column: 25, scope: !778)
!831 = !DILocation(line: 629, column: 21, scope: !778)
!832 = !DILocation(line: 629, column: 9, scope: !778)
!833 = !DILocation(line: 632, column: 13, scope: !778)
!834 = !DILocation(line: 636, column: 13, scope: !778)
!835 = !DILocation(line: 641, column: 9, scope: !778)
!836 = !DILocation(line: 646, column: 13, scope: !778)
!837 = !DILocation(line: 646, column: 9, scope: !778)
!838 = !DILocation(line: 647, column: 30, scope: !778)
!839 = !DILocation(line: 647, column: 35, scope: !778)
!840 = !DILocation(line: 647, column: 46, scope: !778)
!841 = !DILocation(line: 647, column: 50, scope: !778)
!842 = !DILocation(line: 647, column: 54, scope: !778)
!843 = !DILocation(line: 647, column: 57, scope: !778)
!844 = !DILocation(line: 647, column: 60, scope: !778)
!845 = !DILocation(line: 647, column: 63, scope: !778)
!846 = !DILocation(line: 647, column: 13, scope: !778)
!847 = !DILocation(line: 661, column: 9, scope: !778)
!848 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit", scope: null, file: !585, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!849 = !DILocation(line: 43, column: 3, scope: !850)
!850 = !DILexicalBlockFile(scope: !848, file: !585, discriminator: 0)
!851 = !DILocation(line: 41, column: 3, scope: !850)
!852 = !DILocation(line: 40, column: 3, scope: !850)
!853 = !DILocation(line: 39, column: 9, scope: !850)
!854 = !DILocation(line: 40, column: 23, scope: !850)
!855 = !DILocation(line: 41, column: 70, scope: !850)
!856 = !DILocation(line: 41, column: 68, scope: !850)
!857 = !DILocation(line: 43, column: 27, scope: !850)
!858 = !DILocation(line: 43, column: 15, scope: !850)
!859 = !DILocation(line: 44, column: 15, scope: !850)
!860 = !DILocation(line: 44, column: 21, scope: !850)
!861 = !DILocation(line: 44, column: 27, scope: !850)
!862 = !DILocation(line: 44, column: 3, scope: !850)
!863 = !DILocation(line: 39, column: 1, scope: !850)
!864 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord", scope: null, file: !602, line: 4, type: !5, scopeLine: 4, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!865 = !DILocation(line: 5, column: 10, scope: !866)
!866 = !DILexicalBlockFile(scope: !864, file: !602, discriminator: 0)
!867 = !DILocation(line: 5, column: 67, scope: !866)
!868 = !DILocation(line: 5, column: 3, scope: !866)
!869 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord", scope: null, file: !602, line: 8, type: !5, scopeLine: 8, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!870 = !DILocation(line: 9, column: 10, scope: !871)
!871 = !DILexicalBlockFile(scope: !869, file: !602, discriminator: 0)
!872 = !DILocation(line: 9, column: 67, scope: !871)
!873 = !DILocation(line: 9, column: 3, scope: !871)
!874 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord", scope: null, file: !613, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!875 = !DILocation(line: 50, column: 3, scope: !876)
!876 = !DILexicalBlockFile(scope: !874, file: !613, discriminator: 0)
!877 = !DILocation(line: 43, column: 21, scope: !876)
!878 = !DILocation(line: 50, column: 57, scope: !876)
!879 = !DILocation(line: 50, column: 68, scope: !876)
!880 = !DILocation(line: 50, column: 41, scope: !876)
!881 = !DILocation(line: 50, column: 19, scope: !876)
!882 = !DILocation(line: 52, column: 10, scope: !876)
!883 = !DILocation(line: 52, column: 18, scope: !876)
!884 = !DILocation(line: 48, column: 22, scope: !876)
!885 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr", linkageName: "sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr", scope: null, file: !886, line: 11, type: !5, scopeLine: 11, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!886 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/input_queue_config.csl", directory: "")
!887 = !DILocation(line: 11, column: 32, scope: !888)
!888 = !DILexicalBlockFile(scope: !885, file: !886, discriminator: 0)
!889 = !DILocation(line: 12, column: 80, scope: !888)
!890 = !DILocation(line: 12, column: 69, scope: !888)
!891 = !DILocation(line: 12, column: 39, scope: !888)
!892 = !DILocation(line: 12, column: 3, scope: !888)
!893 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue", linkageName: "sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue", scope: null, file: !886, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!894 = !DILocation(line: 46, column: 3, scope: !895)
!895 = !DILexicalBlockFile(scope: !893, file: !886, discriminator: 0)
!896 = !DILocation(line: 45, column: 3, scope: !895)
!897 = !DILocation(line: 39, column: 42, scope: !895)
!898 = !DILocation(line: 39, column: 34, scope: !895)
!899 = !DILocation(line: 39, column: 24, scope: !895)
!900 = !DILocation(line: 45, column: 44, scope: !895)
!901 = !DILocation(line: 45, column: 16, scope: !895)
!902 = !DILocation(line: 46, column: 30, scope: !895)
!903 = !DILocation(line: 46, column: 18, scope: !895)
!904 = !DILocation(line: 56, column: 9, scope: !895)
!905 = !DILocation(line: 56, column: 5, scope: !895)
!906 = !DILocation(line: 58, column: 13, scope: !895)
!907 = !DILocation(line: 58, column: 17, scope: !895)
!908 = !DILocation(line: 58, column: 11, scope: !895)
!909 = !DILocation(line: 61, column: 13, scope: !895)
!910 = !DILocation(line: 61, column: 17, scope: !895)
!911 = !DILocation(line: 61, column: 11, scope: !895)
!912 = !DILocation(line: 66, column: 9, scope: !895)
!913 = !DILocation(line: 66, column: 13, scope: !895)
!914 = !DILocation(line: 66, column: 7, scope: !895)
!915 = !DILocation(line: 68, column: 9, scope: !895)
!916 = !DILocation(line: 68, column: 24, scope: !895)
!917 = !DILocation(line: 68, column: 13, scope: !895)
!918 = !DILocation(line: 68, column: 7, scope: !895)
!919 = !DILocation(line: 70, column: 15, scope: !895)
!920 = !DILocation(line: 70, column: 21, scope: !895)
!921 = !DILocation(line: 70, column: 3, scope: !895)
!922 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr", linkageName: "sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr", scope: null, file: !923, line: 11, type: !5, scopeLine: 11, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!923 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/output_queue_config.csl", directory: "")
!924 = !DILocation(line: 11, column: 33, scope: !925)
!925 = !DILexicalBlockFile(scope: !922, file: !923, discriminator: 0)
!926 = !DILocation(line: 12, column: 82, scope: !925)
!927 = !DILocation(line: 12, column: 40, scope: !925)
!928 = !DILocation(line: 12, column: 3, scope: !925)
!929 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue", linkageName: "sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue", scope: null, file: !923, line: 31, type: !5, scopeLine: 31, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!930 = !DILocation(line: 38, column: 3, scope: !931)
!931 = !DILexicalBlockFile(scope: !929, file: !923, discriminator: 0)
!932 = !DILocation(line: 37, column: 3, scope: !931)
!933 = !DILocation(line: 31, column: 35, scope: !931)
!934 = !DILocation(line: 31, column: 25, scope: !931)
!935 = !DILocation(line: 37, column: 45, scope: !931)
!936 = !DILocation(line: 37, column: 16, scope: !931)
!937 = !DILocation(line: 38, column: 30, scope: !931)
!938 = !DILocation(line: 38, column: 18, scope: !931)
!939 = !DILocation(line: 41, column: 9, scope: !931)
!940 = !DILocation(line: 41, column: 13, scope: !931)
!941 = !DILocation(line: 41, column: 7, scope: !931)
!942 = !DILocation(line: 43, column: 9, scope: !931)
!943 = !DILocation(line: 43, column: 24, scope: !931)
!944 = !DILocation(line: 43, column: 13, scope: !931)
!945 = !DILocation(line: 43, column: 27, scope: !931)
!946 = !DILocation(line: 43, column: 7, scope: !931)
!947 = !DILocation(line: 45, column: 15, scope: !931)
!948 = !DILocation(line: 45, column: 21, scope: !931)
!949 = !DILocation(line: 45, column: 3, scope: !931)
!950 = !DILocation(line: 31, column: 1, scope: !931)
!951 = distinct !DISubprogram(name: ".get_tensor_ptr", linkageName: ".get_tensor_ptr", scope: null, file: !4, line: 1, type: !5, scopeLine: 1, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!952 = !DILocation(line: 1, column: 1, scope: !953)
!953 = !DILexicalBlockFile(scope: !951, file: !4, discriminator: 0)
!954 = distinct !DISubprogram(name: "__generic0sys_mod.sys_mod.tile_config.queue_flush.exit", linkageName: "__generic0sys_mod.sys_mod.tile_config.queue_flush.exit", scope: null, file: !955, line: 12, type: !5, scopeLine: 12, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!955 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/queue_flush.csl", directory: "")
!956 = !DILocation(line: 24, column: 3, scope: !957)
!957 = !DILexicalBlockFile(scope: !954, file: !955, discriminator: 0)
!958 = !DILocation(line: 12, column: 1, scope: !957)
!959 = distinct !DISubprogram(name: "__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position", linkageName: "__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position", scope: null, file: !960, line: 30, type: !5, scopeLine: 30, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!960 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/switch_config.csl", directory: "")
!961 = !DILocation(line: 34, column: 3, scope: !962)
!962 = !DILexicalBlockFile(scope: !959, file: !960, discriminator: 0)
!963 = !DILocation(line: 32, column: 3, scope: !962)
!964 = !DILocation(line: 30, column: 27, scope: !962)
!965 = !DILocation(line: 33, column: 7, scope: !962)
!966 = !DILocation(line: 34, column: 36, scope: !962)
!967 = !DILocation(line: 34, column: 24, scope: !962)
!968 = !DILocation(line: 35, column: 3, scope: !962)
!969 = !DILocation(line: 35, column: 18, scope: !962)
!970 = !DILocation(line: 36, column: 15, scope: !962)
!971 = !DILocation(line: 36, column: 21, scope: !962)
!972 = !DILocation(line: 36, column: 3, scope: !962)
!973 = !DILocation(line: 30, column: 1, scope: !962)
!974 = distinct !DISubprogram(name: "__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", linkageName: "__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", scope: null, file: !975, line: 96, type: !5, scopeLine: 96, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!975 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/color_config.csl", directory: "")
!976 = !DILocation(line: 99, column: 3, scope: !977)
!977 = !DILexicalBlockFile(scope: !974, file: !975, discriminator: 0)
!978 = !DILocation(line: 98, column: 3, scope: !977)
!979 = !DILocation(line: 96, column: 17, scope: !977)
!980 = !DILocation(line: 98, column: 16, scope: !977)
!981 = !DILocation(line: 99, column: 29, scope: !977)
!982 = !DILocation(line: 99, column: 17, scope: !977)
!983 = !DILocation(line: 100, column: 13, scope: !977)
!984 = !DILocation(line: 100, column: 21, scope: !977)
!985 = !DILocation(line: 100, column: 11, scope: !977)
!986 = !DILocation(line: 104, column: 7, scope: !977)
!987 = !DILocation(line: 104, column: 50, scope: !977)
!988 = !DILocation(line: 104, column: 18, scope: !977)
!989 = !DILocation(line: 104, column: 15, scope: !977)
!990 = !DILocation(line: 121, column: 7, scope: !977)
!991 = !DILocation(line: 121, column: 50, scope: !977)
!992 = !DILocation(line: 121, column: 18, scope: !977)
!993 = !DILocation(line: 121, column: 15, scope: !977)
!994 = !DILocation(line: 128, column: 15, scope: !977)
!995 = !DILocation(line: 128, column: 21, scope: !977)
!996 = !DILocation(line: 128, column: 3, scope: !977)
!997 = !DILocation(line: 96, column: 1, scope: !977)
!998 = distinct !DISubprogram(name: "__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", linkageName: "__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", scope: null, file: !975, line: 96, type: !5, scopeLine: 96, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!999 = !DILocation(line: 99, column: 3, scope: !1000)
!1000 = !DILexicalBlockFile(scope: !998, file: !975, discriminator: 0)
!1001 = !DILocation(line: 98, column: 3, scope: !1000)
!1002 = !DILocation(line: 96, column: 17, scope: !1000)
!1003 = !DILocation(line: 98, column: 16, scope: !1000)
!1004 = !DILocation(line: 99, column: 29, scope: !1000)
!1005 = !DILocation(line: 99, column: 17, scope: !1000)
!1006 = !DILocation(line: 100, column: 13, scope: !1000)
!1007 = !DILocation(line: 100, column: 21, scope: !1000)
!1008 = !DILocation(line: 100, column: 11, scope: !1000)
!1009 = !DILocation(line: 104, column: 7, scope: !1000)
!1010 = !DILocation(line: 104, column: 50, scope: !1000)
!1011 = !DILocation(line: 104, column: 18, scope: !1000)
!1012 = !DILocation(line: 104, column: 15, scope: !1000)
!1013 = !DILocation(line: 121, column: 7, scope: !1000)
!1014 = !DILocation(line: 121, column: 50, scope: !1000)
!1015 = !DILocation(line: 121, column: 18, scope: !1000)
!1016 = !DILocation(line: 121, column: 15, scope: !1000)
!1017 = !DILocation(line: 128, column: 15, scope: !1000)
!1018 = !DILocation(line: 128, column: 21, scope: !1000)
!1019 = !DILocation(line: 128, column: 3, scope: !1000)
!1020 = !DILocation(line: 96, column: 1, scope: !1000)
!1021 = distinct !DISubprogram(name: "__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", linkageName: "__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", scope: null, file: !975, line: 60, type: !5, scopeLine: 60, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1022 = !DILocation(line: 61, column: 3, scope: !1023)
!1023 = !DILexicalBlockFile(scope: !1021, file: !975, discriminator: 0)
!1024 = !DILocation(line: 60, column: 46, scope: !1023)
!1025 = !DILocation(line: 61, column: 16, scope: !1023)
!1026 = !DILocation(line: 72, column: 5, scope: !1023)
!1027 = !DILocation(line: 72, column: 12, scope: !1023)
!1028 = !DILocation(line: 74, column: 10, scope: !1023)
!1029 = !DILocation(line: 74, column: 3, scope: !1023)
!1030 = distinct !DISubprogram(name: "__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes", linkageName: "__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes", scope: null, file: !975, line: 77, type: !5, scopeLine: 77, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1031 = !DILocation(line: 78, column: 3, scope: !1032)
!1032 = !DILexicalBlockFile(scope: !1030, file: !975, discriminator: 0)
!1033 = !DILocation(line: 77, column: 46, scope: !1032)
!1034 = !DILocation(line: 78, column: 16, scope: !1032)
!1035 = !DILocation(line: 86, column: 5, scope: !1032)
!1036 = !DILocation(line: 86, column: 12, scope: !1032)
!1037 = !DILocation(line: 91, column: 10, scope: !1032)
!1038 = !DILocation(line: 91, column: 3, scope: !1032)
!1039 = distinct !DISubprogram(name: "__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", linkageName: "__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", scope: null, file: !975, line: 60, type: !5, scopeLine: 60, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1040 = !DILocation(line: 61, column: 3, scope: !1041)
!1041 = !DILexicalBlockFile(scope: !1039, file: !975, discriminator: 0)
!1042 = !DILocation(line: 60, column: 46, scope: !1041)
!1043 = !DILocation(line: 61, column: 16, scope: !1041)
!1044 = !DILocation(line: 63, column: 5, scope: !1041)
!1045 = !DILocation(line: 63, column: 12, scope: !1041)
!1046 = !DILocation(line: 74, column: 10, scope: !1041)
!1047 = !DILocation(line: 74, column: 3, scope: !1041)
!1048 = distinct !DISubprogram(name: "__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction", linkageName: "__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction", scope: null, file: !975, line: 52, type: !5, scopeLine: 52, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1049 = !DILocation(line: 55, column: 3, scope: !1050)
!1050 = !DILexicalBlockFile(scope: !1048, file: !975, discriminator: 0)
!1051 = !DILocation(line: 54, column: 3, scope: !1050)
!1052 = !DILocation(line: 52, column: 23, scope: !1050)
!1053 = !DILocation(line: 54, column: 16, scope: !1050)
!1054 = !DILocation(line: 55, column: 29, scope: !1050)
!1055 = !DILocation(line: 55, column: 17, scope: !1050)
!1056 = !DILocation(line: 56, column: 3, scope: !1050)
!1057 = !DILocation(line: 56, column: 11, scope: !1050)
!1058 = !DILocation(line: 57, column: 15, scope: !1050)
!1059 = !DILocation(line: 57, column: 21, scope: !1050)
!1060 = !DILocation(line: 57, column: 3, scope: !1050)
!1061 = !DILocation(line: 52, column: 1, scope: !1050)
!1062 = distinct !DISubprogram(name: "__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction", linkageName: "__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction", scope: null, file: !975, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1063 = !DILocation(line: 23, column: 3, scope: !1064)
!1064 = !DILexicalBlockFile(scope: !1062, file: !975, discriminator: 0)
!1065 = !DILocation(line: 22, column: 3, scope: !1064)
!1066 = !DILocation(line: 20, column: 21, scope: !1064)
!1067 = !DILocation(line: 22, column: 16, scope: !1064)
!1068 = !DILocation(line: 23, column: 29, scope: !1064)
!1069 = !DILocation(line: 23, column: 17, scope: !1064)
!1070 = !DILocation(line: 24, column: 3, scope: !1064)
!1071 = !DILocation(line: 24, column: 11, scope: !1064)
!1072 = !DILocation(line: 25, column: 15, scope: !1064)
!1073 = !DILocation(line: 25, column: 21, scope: !1064)
!1074 = !DILocation(line: 25, column: 3, scope: !1064)
!1075 = !DILocation(line: 20, column: 1, scope: !1064)
module asm ".section \22.pe_debug_info\22, \22\22"
module asm ".section \22.note\22, \22\22"
