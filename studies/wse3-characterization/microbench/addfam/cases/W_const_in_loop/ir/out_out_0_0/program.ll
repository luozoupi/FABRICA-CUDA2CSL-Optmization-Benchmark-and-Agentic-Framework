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
@cte.init = internal constant [3 x i16] [i16 0, i16 8, i16 1], align 4
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
  %21 = icmp ult i16 %20, 8, !dbg !9
  br label %22, !dbg !7

22:                                               ; preds = %18, %19
  %23 = phi i1 [ %21, %19 ], [ false, %18 ]
  br label %24, !dbg !7

24:                                               ; preds = %22
  br i1 %23, label %25, label %34, !dbg !7

25:                                               ; preds = %24
  %26 = load i16, i16* getelementptr inbounds ([64 x i16], [64 x i16]* @a, i16 0, i1 false), align 2, !dbg !11
  %27 = add i16 %26, 5, !dbg !12
  %28 = load i16, i16* %2, align 2, !dbg !13
  %29 = getelementptr [64 x i16], [64 x i16]* @c, i16 0, i16 %28, !dbg !14
  store i16 %27, i16* %29, align 2, !dbg !15
  %30 = load i16, i16* %1, align 2, !dbg !7
  %31 = add i16 %30, 1, !dbg !7
  store i16 %31, i16* %1, align 2, !dbg !7
  %32 = load i16, i16* %2, align 2, !dbg !9
  %33 = add i16 %32, 1, !dbg !9
  store i16 %33, i16* %2, align 2, !dbg !9
  br label %8, !dbg !7

34:                                               ; preds = %24
  %35 = icmp ne i16 %15, 0, !dbg !7
  br i1 %35, label %36, label %37, !dbg !7

36:                                               ; preds = %34
  br label %38, !dbg !7

37:                                               ; preds = %34
  call void @llvm.sdr.actvt.r(i16 9), !dbg !16
  br label %38, !dbg !7

38:                                               ; preds = %36, %37
  ret void, !dbg !7
}

define void @f_exit() #0 !dbg !17 {
  call void @sys_mod.unblock_cmd_stream(), !dbg !18
  ret void, !dbg !20
}

define internal void @sys_mod.sys_nop() !dbg !21 {
  ret void, !dbg !23
}

define internal void @sys_mod.unblock_cmd_stream() !dbg !25 {
  call void @sys_mod.sys_mod.unblock_cmd_stream(), !dbg !26
  ret void, !dbg !28
}

define internal void @sys_mod.sys_mod.unblock_cmd_stream() !dbg !29 {
  call void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream(), !dbg !31
  ret void, !dbg !33
}

define internal void @sys_mod.sys_mod.teardown_h2d() !dbg !34 {
  call void @llvm.sdr.actvt.r(i16 27), !dbg !35
  ret void, !dbg !37
}

define void @sys_mod.sys_mod.f_ublk_c22() #1 !dbg !38 {
  call void @sys_mod.sys_mod.unblock_cmd_stream(), !dbg !39
  ret void, !dbg !41
}

define internal void @sys_mod.sys_mod.teardown_d2h() !dbg !42 {
  call void @llvm.sdr.blk.r(i16 0), !dbg !43
  call void @llvm.sdr.actvt.r(i16 28), !dbg !45
  ret void, !dbg !46
}

define void @sys_mod.sys_mod.f_memcpyh2d() #2 !dbg !47 {
  %1 = alloca float, i16 1, align 4, !dbg !48
  %2 = alloca float, i16 1, align 4, !dbg !50
  %3 = alloca i16, i16 1, align 2, !dbg !51
  %4 = alloca i16, i16 1, align 2, !dbg !52
  %5 = alloca i16, i16 1, align 2, !dbg !53
  %6 = alloca i16, i16 1, align 2, !dbg !54
  %7 = alloca i16, i16 1, align 2, !dbg !55
  %8 = alloca i16, i16 1, align 2, !dbg !56
  %9 = alloca i16, i16 1, align 2, !dbg !57
  %10 = alloca i16, i16 1, align 2, !dbg !58
  %11 = alloca i16, i16 1, align 2, !dbg !59
  %12 = alloca i16, i16 1, align 2, !dbg !60
  %13 = alloca i16, i16 1, align 2, !dbg !61
  %14 = alloca i16*, i16 1, align 8, !dbg !62
  %15 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !63
  %16 = icmp eq i16 %15, 15, !dbg !64
  br i1 %16, label %17, label %18, !dbg !65

17:                                               ; preds = %0
  br label %19, !dbg !65

18:                                               ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !65
  br label %19, !dbg !65

19:                                               ; preds = %17, %18
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %14, align 8, !dbg !62
  %20 = load i16*, i16** %14, align 8, !dbg !66
  %21 = load i16, i16* %20, align 2, !dbg !67
  store i16 %21, i16* %13, align 2, !dbg !61
  %22 = load i16*, i16** %14, align 8, !dbg !68
  %23 = getelementptr i16, i16* %22, i16 1, !dbg !69
  %24 = load i16, i16* %23, align 2, !dbg !69
  store i16 %24, i16* %12, align 2, !dbg !60
  %25 = load i16*, i16** %14, align 8, !dbg !70
  %26 = getelementptr i16, i16* %25, i16 2, !dbg !71
  %27 = load i16, i16* %26, align 2, !dbg !71
  store i16 %27, i16* %11, align 2, !dbg !59
  %28 = load i16*, i16** %14, align 8, !dbg !72
  %29 = getelementptr i16, i16* %28, i16 3, !dbg !73
  %30 = load i16, i16* %29, align 2, !dbg !73
  store i16 %30, i16* %10, align 2, !dbg !58
  %31 = load i16*, i16** %14, align 8, !dbg !74
  %32 = getelementptr i16, i16* %31, i16 4, !dbg !75
  %33 = load i16, i16* %32, align 2, !dbg !75
  store i16 %33, i16* %9, align 2, !dbg !57
  %34 = load i16*, i16** %14, align 8, !dbg !76
  %35 = getelementptr i16, i16* %34, i16 5, !dbg !77
  %36 = load i16, i16* %35, align 2, !dbg !77
  store i16 %36, i16* %8, align 2, !dbg !56
  %37 = load i16*, i16** %14, align 8, !dbg !78
  %38 = getelementptr i16, i16* %37, i16 6, !dbg !79
  %39 = load i16, i16* %38, align 2, !dbg !79
  store i16 %39, i16* %7, align 2, !dbg !55
  %40 = load i16*, i16** %14, align 8, !dbg !80
  %41 = getelementptr i16, i16* %40, i16 7, !dbg !81
  %42 = load i16, i16* %41, align 2, !dbg !81
  store i16 %42, i16* %6, align 2, !dbg !54
  %43 = load i16*, i16** %14, align 8, !dbg !82
  %44 = getelementptr i16, i16* %43, i16 8, !dbg !83
  %45 = load i16, i16* %44, align 2, !dbg !83
  store i16 %45, i16* %5, align 2, !dbg !53
  %46 = load i16*, i16** %14, align 8, !dbg !84
  %47 = getelementptr i16, i16* %46, i16 9, !dbg !85
  %48 = load i16, i16* %47, align 2, !dbg !85
  store i16 %48, i16* %4, align 2, !dbg !52
  %49 = load i16*, i16** %14, align 8, !dbg !86
  %50 = getelementptr i16, i16* %49, i16 10, !dbg !87
  %51 = load i16, i16* %50, align 2, !dbg !87
  store i16 %51, i16* %3, align 2, !dbg !51
  %52 = load i16*, i16** %14, align 8, !dbg !88
  %53 = getelementptr i16, i16* %52, i16 12, !dbg !89
  %54 = load i16, i16* %53, align 2, !dbg !89
  %55 = zext i16 %54 to i32, !dbg !90
  %56 = load i16*, i16** %14, align 8, !dbg !91
  %57 = getelementptr i16, i16* %56, i16 11, !dbg !92
  %58 = load i16, i16* %57, align 2, !dbg !92
  %59 = zext i16 %58 to i32, !dbg !93
  %60 = add i32 %59, 16, !dbg !94
  %61 = shl i32 %55, %60, !dbg !95
  %62 = bitcast i32 %61 to float, !dbg !96
  store float %62, float* %2, align 4, !dbg !50
  %63 = load i16*, i16** %14, align 8, !dbg !97
  %64 = getelementptr i16, i16* %63, i16 14, !dbg !98
  %65 = load i16, i16* %64, align 2, !dbg !98
  %66 = zext i16 %65 to i32, !dbg !99
  %67 = load i16*, i16** %14, align 8, !dbg !100
  %68 = getelementptr i16, i16* %67, i16 13, !dbg !101
  %69 = load i16, i16* %68, align 2, !dbg !101
  %70 = zext i16 %69 to i32, !dbg !102
  %71 = add i32 %70, 16, !dbg !103
  %72 = shl i32 %66, %71, !dbg !104
  %73 = bitcast i32 %72 to float, !dbg !105
  store float %73, float* %1, align 4, !dbg !48
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !106
  %74 = load i16, i16* %13, align 2, !dbg !107
  store i16 %74, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !108
  %75 = load i16, i16* %12, align 2, !dbg !109
  store i16 %75, i16* @sys_mod.sys_mod.memcpyH2D_px, align 2, !dbg !110
  %76 = load i16, i16* %11, align 2, !dbg !111
  store i16 %76, i16* @sys_mod.sys_mod.memcpyH2D_py, align 2, !dbg !112
  %77 = load i16, i16* %10, align 2, !dbg !113
  store i16 %77, i16* @sys_mod.sys_mod.memcpyH2D_w, align 2, !dbg !114
  %78 = load i16, i16* %9, align 2, !dbg !115
  store i16 %78, i16* @sys_mod.sys_mod.memcpyH2D_h, align 2, !dbg !116
  %79 = load i16, i16* %8, align 2, !dbg !117
  store i16 %79, i16* @sys_mod.sys_mod.memcpyH2D_addr, align 2, !dbg !118
  %80 = load i16, i16* %7, align 2, !dbg !119
  store i16 %80, i16* @sys_mod.sys_mod.memcpyH2D_pe_length, align 2, !dbg !120
  %81 = load i16, i16* %6, align 2, !dbg !121
  store i16 %81, i16* @sys_mod.sys_mod.memcpyH2D_is_half, align 2, !dbg !122
  %82 = load i16, i16* %5, align 2, !dbg !123
  store i16 %82, i16* @sys_mod.sys_mod.memcpyH2D_memcpy_optype, align 2, !dbg !124
  %83 = load i16, i16* %4, align 2, !dbg !125
  store i16 %83, i16* @sys_mod.sys_mod.memcpyH2D_row_stride, align 2, !dbg !126
  %84 = load i16, i16* %3, align 2, !dbg !127
  store i16 %84, i16* @sys_mod.sys_mod.memcpyH2D_col_stride, align 2, !dbg !128
  %85 = load float, float* %2, align 4, !dbg !129
  store float %85, float* @sys_mod.sys_mod.memcpyH2D_one_over_row_stride, align 4, !dbg !130
  %86 = load float, float* %1, align 4, !dbg !131
  store float %86, float* @sys_mod.sys_mod.memcpyH2D_one_over_col_stride, align 4, !dbg !132
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !133
  call void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 0, i16 23, i1 true), !dbg !134
  call void @llvm.sdr.blk.r(i16 27), !dbg !135
  call void @llvm.sdr.oqflush(i16 0), !dbg !136
  store i1 true, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !137
  call void @llvm.sdr.blk.r(i16 0), !dbg !138
  ret void, !dbg !139
}

define void @sys_mod.sys_mod.f_memcpyd2h() #3 !dbg !140 {
  %1 = alloca i16, i16 1, align 2, !dbg !141
  %2 = alloca i16, i16 1, align 2, !dbg !143
  %3 = alloca i16, i16 1, align 2, !dbg !144
  %4 = alloca i16, i16 1, align 2, !dbg !145
  %5 = alloca i16, i16 1, align 2, !dbg !146
  %6 = alloca i16, i16 1, align 2, !dbg !147
  %7 = alloca i16, i16 1, align 2, !dbg !148
  %8 = alloca i16, i16 1, align 2, !dbg !149
  %9 = alloca i16*, i16 1, align 8, !dbg !150
  %10 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !151
  %11 = icmp eq i16 %10, 8, !dbg !152
  br i1 %11, label %12, label %13, !dbg !153

12:                                               ; preds = %0
  br label %14, !dbg !153

13:                                               ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !153
  br label %14, !dbg !153

14:                                               ; preds = %12, %13
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %9, align 8, !dbg !150
  %15 = load i16*, i16** %9, align 8, !dbg !154
  %16 = load i16, i16* %15, align 2, !dbg !155
  store i16 %16, i16* %8, align 2, !dbg !149
  %17 = load i16*, i16** %9, align 8, !dbg !156
  %18 = getelementptr i16, i16* %17, i16 1, !dbg !157
  %19 = load i16, i16* %18, align 2, !dbg !157
  store i16 %19, i16* %7, align 2, !dbg !148
  %20 = load i16*, i16** %9, align 8, !dbg !158
  %21 = getelementptr i16, i16* %20, i16 2, !dbg !159
  %22 = load i16, i16* %21, align 2, !dbg !159
  store i16 %22, i16* %6, align 2, !dbg !147
  %23 = load i16*, i16** %9, align 8, !dbg !160
  %24 = getelementptr i16, i16* %23, i16 3, !dbg !161
  %25 = load i16, i16* %24, align 2, !dbg !161
  store i16 %25, i16* %5, align 2, !dbg !146
  %26 = load i16*, i16** %9, align 8, !dbg !162
  %27 = getelementptr i16, i16* %26, i16 4, !dbg !163
  %28 = load i16, i16* %27, align 2, !dbg !163
  store i16 %28, i16* %4, align 2, !dbg !145
  %29 = load i16*, i16** %9, align 8, !dbg !164
  %30 = getelementptr i16, i16* %29, i16 5, !dbg !165
  %31 = load i16, i16* %30, align 2, !dbg !165
  store i16 %31, i16* %3, align 2, !dbg !144
  %32 = load i16*, i16** %9, align 8, !dbg !166
  %33 = getelementptr i16, i16* %32, i16 6, !dbg !167
  %34 = load i16, i16* %33, align 2, !dbg !167
  store i16 %34, i16* %2, align 2, !dbg !143
  %35 = load i16*, i16** %9, align 8, !dbg !168
  %36 = getelementptr i16, i16* %35, i16 7, !dbg !169
  %37 = load i16, i16* %36, align 2, !dbg !169
  store i16 %37, i16* %1, align 2, !dbg !141
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !170
  %38 = load i16, i16* %8, align 2, !dbg !171
  store i16 %38, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !172
  %39 = load i16, i16* %7, align 2, !dbg !173
  store i16 %39, i16* @sys_mod.sys_mod.memcpyD2H_px, align 2, !dbg !174
  %40 = load i16, i16* %6, align 2, !dbg !175
  store i16 %40, i16* @sys_mod.sys_mod.memcpyD2H_py, align 2, !dbg !176
  %41 = load i16, i16* %5, align 2, !dbg !177
  store i16 %41, i16* @sys_mod.sys_mod.memcpyD2H_w, align 2, !dbg !178
  %42 = load i16, i16* %4, align 2, !dbg !179
  store i16 %42, i16* @sys_mod.sys_mod.memcpyD2H_h, align 2, !dbg !180
  %43 = load i16, i16* %3, align 2, !dbg !181
  store i16 %43, i16* @sys_mod.sys_mod.memcpyD2H_addr, align 2, !dbg !182
  %44 = load i16, i16* %2, align 2, !dbg !183
  store i16 %44, i16* @sys_mod.sys_mod.memcpyD2H_pe_length, align 2, !dbg !184
  %45 = load i16, i16* %1, align 2, !dbg !185
  store i16 %45, i16* @sys_mod.sys_mod.memcpyD2H_is_half, align 2, !dbg !186
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !187
  %46 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !188
  call void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 0, i16 %46, i1 false), !dbg !189
  call void @llvm.sdr.oqflush(i16 0), !dbg !190
  store i1 false, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !191
  ret void, !dbg !192
}

define internal void @sys_mod.sys_mod.oq0_teardow_handler() !dbg !193 {
  %1 = load i1, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !194
  br i1 %1, label %2, label %17, !dbg !196

2:                                                ; preds = %0
  %3 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !197
  call void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 0, i16 %3), !dbg !198
  %4 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !199
  %5 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_px, align 2, !dbg !200
  %6 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_py, align 2, !dbg !201
  %7 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_w, align 2, !dbg !202
  %8 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_h, align 2, !dbg !203
  %9 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_addr, align 2, !dbg !204
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_pe_length, align 2, !dbg !205
  %11 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_is_half, align 2, !dbg !206
  %12 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_memcpy_optype, align 2, !dbg !207
  %13 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_row_stride, align 2, !dbg !208
  %14 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_col_stride, align 2, !dbg !209
  %15 = load float, float* @sys_mod.sys_mod.memcpyH2D_one_over_row_stride, align 4, !dbg !210
  %16 = load float, float* @sys_mod.sys_mod.memcpyH2D_one_over_col_stride, align 4, !dbg !211
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure(i16 %4, i16 %5, i16 %6, i16 %7, i16 %8, i16 %9, i16 %10, i16 %11, i16 %12, i16 %13, i16 %14, float %15, float %16), !dbg !212
  br label %26, !dbg !196

17:                                               ; preds = %0
  call void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 0, i16 21), !dbg !213
  %18 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !214
  %19 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_px, align 2, !dbg !215
  %20 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_py, align 2, !dbg !216
  %21 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_w, align 2, !dbg !217
  %22 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_h, align 2, !dbg !218
  %23 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_addr, align 2, !dbg !219
  %24 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_pe_length, align 2, !dbg !220
  %25 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_is_half, align 2, !dbg !221
  call void @sys_mod.sys_mod.memcpyd2h_mod.d2h_configure(i16 %18, i16 %19, i16 %20, i16 %21, i16 %22, i16 %23, i16 %24, i16 %25), !dbg !222
  br label %26, !dbg !196

26:                                               ; preds = %2, %17
  call void @__generic0sys_mod.sys_mod.tile_config.queue_flush.exit(), !dbg !223
  ret void, !dbg !196
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

define void @sys_mod.sys_mod.f_rpc(i16 %0) #4 !dbg !224 {
  %2 = alloca i16, i16 1, align 2, !dbg !225
  store i16 %0, i16* %2, align 2, !dbg !225
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !227
  %3 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !228
  %4 = icmp sge i16 %3, 4, !dbg !229
  br i1 %4, label %5, label %6, !dbg !230

5:                                                ; preds = %1
  br label %7, !dbg !230

6:                                                ; preds = %1
  call void asm sideeffect "hcf", ""(), !dbg !230
  br label %7, !dbg !230

7:                                                ; preds = %5, %6
  call void @rpc_server(i32* getelementptr inbounds ([32 x i32], [32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32, i32 0, i32 0)), !dbg !231
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !232
  ret void, !dbg !233
}

define internal void @sys_mod.sys_mod.sys_mod.stack_push(i16 %0) !dbg !234 {
  %2 = alloca i16*, i16 1, align 8, !dbg !236
  %3 = alloca i16, i16 1, align 2, !dbg !238
  store i16 %0, i16* %3, align 2, !dbg !238
  %4 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !239
  %5 = icmp slt i16 %4, 32, !dbg !240
  br i1 %5, label %6, label %7, !dbg !241

6:                                                ; preds = %1
  br label %8, !dbg !241

7:                                                ; preds = %1
  call void asm sideeffect "hcf", ""(), !dbg !241
  br label %8, !dbg !241

8:                                                ; preds = %6, %7
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %2, align 8, !dbg !236
  %9 = load i16, i16* %3, align 2, !dbg !242
  %10 = load i16*, i16** %2, align 8, !dbg !243
  %11 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !244
  %12 = getelementptr i16, i16* %10, i16 %11, !dbg !245
  store i16 %9, i16* %12, align 2, !dbg !246
  %13 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !247
  %14 = add i16 %13, 1, !dbg !248
  store i16 %14, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !249
  ret void, !dbg !250
}

define void @sys_mod.sys_mod.sys_mod.f_push(i16 %0, i16 %1) #5 !dbg !251 {
  %3 = alloca i16, i16 1, align 2, !dbg !252
  %4 = alloca i16, i16 1, align 2, !dbg !254
  store i16 %0, i16* %4, align 2, !dbg !254
  store i16 %1, i16* %3, align 2, !dbg !252
  %5 = load i16, i16* %4, align 2, !dbg !255
  call void @sys_mod.sys_mod.sys_mod.stack_push(i16 %5), !dbg !256
  ret void, !dbg !257
}

define internal void @sys_mod.sys_mod.sys_mod.block_cmd_stream() !dbg !258 {
  call void @llvm.sdr.blk.r(i16 1), !dbg !259
  ret void, !dbg !261
}

define internal void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream() !dbg !262 {
  call void @llvm.sdr.ublk.r(i16 1), !dbg !263
  ret void, !dbg !265
}

define void @sys_mod.sys_mod.sys_mod.f_sys_exit() #6 !dbg !266 {
  call void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream(), !dbg !267
  call void @sys_mod.sys_nop(), !dbg !269
  ret void, !dbg !270
}

define void @sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore(i32 %0) #7 !dbg !271 {
  %2 = alloca i32, i16 1, align 4, !dbg !272
  store i32 %0, i32* %2, align 4, !dbg !272
  ret void, !dbg !274
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord() !dbg !275 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord(), !dbg !277
  ret i16 %1, !dbg !279
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord() !dbg !280 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord(), !dbg !281
  ret i16 %1, !dbg !283
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval(i16 %0) !dbg !284 {
  %2 = alloca i16, i16 1, align 2, !dbg !285
  store i16 %0, i16* %2, align 2, !dbg !285
  %3 = load i16, i16* %2, align 2, !dbg !287
  %4 = icmp ult i16 %3, 24, !dbg !288
  br i1 %4, label %5, label %7, !dbg !289

5:                                                ; preds = %10, %11, %1
  %6 = phi i16 [ 0, %10 ], [ 0, %11 ], [ 1, %1 ]
  br label %12, !dbg !289

7:                                                ; preds = %1
  %8 = load i16, i16* %2, align 2, !dbg !290
  %9 = icmp eq i16 31, %8, !dbg !291
  br i1 %9, label %10, label %11, !dbg !292

10:                                               ; preds = %7
  br label %5, !dbg !292

11:                                               ; preds = %7
  call void asm sideeffect "hcf", ""(), !dbg !292
  br label %5, !dbg !292

12:                                               ; preds = %5
  %13 = phi i16 [ %6, %5 ]
  br label %14, !dbg !289

14:                                               ; preds = %12
  ret i16 %13, !dbg !289
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start(i16 %0, i16 %1, i16 %2) !dbg !293 {
  %4 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !294
  %5 = alloca i16, i16 1, align 2, !dbg !296
  %6 = alloca i16, i16 1, align 2, !dbg !297
  %7 = alloca i16, i16 1, align 2, !dbg !298
  store i16 %0, i16* %7, align 2, !dbg !298
  store i16 %1, i16* %6, align 2, !dbg !297
  store i16 %2, i16* %5, align 2, !dbg !296
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !299
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !299
  %10 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !299
  %11 = load i16, i16* %6, align 2, !dbg !300
  store i16 %11, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !301
  store i16 %8, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !301
  store i16 %9, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !301
  store i16 %10, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !301
  %12 = load i16, i16* %7, align 2, !dbg !302
  %13 = call i16* @.get_tensor_ptr(i16 %12), !dbg !303
  %14 = ptrtoint i16* %13 to i16, !dbg !304
  %15 = lshr i16 %14, 1, !dbg !304
  %16 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !294
  store i16 42, i16* %16, align 2, !dbg !294
  %17 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !294
  store i16 %15, i16* %17, align 2, !dbg !294
  %18 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !294
  store i16 143, i16* %18, align 2, !dbg !294
  %19 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !294
  store i16 16, i16* %19, align 2, !dbg !294
  %20 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !305
  %21 = load i16, i16* %20, align 2, !dbg !305
  %22 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !305
  %23 = load i16, i16* %22, align 2, !dbg !305
  %24 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !305
  %25 = load i16, i16* %24, align 2, !dbg !305
  %26 = load i16, i16* %6, align 2, !dbg !306
  %27 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !307
  store i16 %26, i16* %27, align 2, !dbg !307
  %28 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !307
  store i16 %21, i16* %28, align 2, !dbg !307
  %29 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !307
  store i16 %23, i16* %29, align 2, !dbg !307
  %30 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !307
  store i16 %25, i16* %30, align 2, !dbg !307
  %31 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !308
  %32 = load i16, i16* %31, align 2, !dbg !308
  %33 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !308
  %34 = load i16, i16* %33, align 2, !dbg !308
  %35 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !308
  %36 = load i16, i16* %35, align 2, !dbg !308
  %37 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !308
  %38 = load i16, i16* %37, align 2, !dbg !308
  store volatile i16 %32, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !309
  store volatile i16 %34, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !309
  store volatile i16 %36, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !309
  store volatile i16 %38, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !309
  call void asm sideeffect "nop", ""(), !dbg !309
  call void asm sideeffect "nop", ""(), !dbg !309
  %39 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !310
  %40 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !310
  %41 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !310
  %42 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !310
  %43 = and i16 %41, -193, !dbg !310
  %44 = or i16 %43, 128, !dbg !310
  %45 = and i16 %40, -64, !dbg !310
  %46 = or i16 %45, 27, !dbg !310
  store volatile i16 %39, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !311
  store volatile i16 %46, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !311
  store volatile i16 %44, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !311
  store volatile i16 %42, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !311
  call void asm sideeffect "nop", ""(), !dbg !311
  call void asm sideeffect "nop", ""(), !dbg !311
  %47 = load i16, i16* %5, align 2, !dbg !312
  %48 = icmp ult i16 0, %47, !dbg !313
  br i1 %48, label %49, label %50, !dbg !314

49:                                               ; preds = %3
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !315
  br label %51, !dbg !314

50:                                               ; preds = %3
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !316
  br label %51, !dbg !314

51:                                               ; preds = %49, %50
  ret void, !dbg !314
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream() !dbg !317 {
  call void @llvm.sdr.ublk.r(i16 1), !dbg !318
  ret void, !dbg !320
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7, i16 %8, i16 %9, i16 %10, float %11, float %12) !dbg !321 {
  %14 = alloca i16, i16 1, align 2, !dbg !322
  %15 = alloca i16, i16 1, align 2, !dbg !324
  %16 = alloca i16, i16 1, align 2, !dbg !325
  %17 = alloca i16, i16 1, align 2, !dbg !326
  %18 = alloca i16, i16 1, align 2, !dbg !327
  %19 = alloca i1, i16 1, align 1, !dbg !328
  %20 = alloca i16, i16 1, align 2, !dbg !329
  %21 = alloca i16, i16 1, align 2, !dbg !330
  %22 = alloca i16, i16 1, align 2, !dbg !331
  %23 = alloca i16, i16 1, align 2, !dbg !332
  %24 = alloca i16, i16 1, align 2, !dbg !333
  %25 = alloca float, i16 1, align 4, !dbg !334
  %26 = alloca float, i16 1, align 4, !dbg !335
  %27 = alloca i16, i16 1, align 2, !dbg !336
  %28 = alloca i16, i16 1, align 2, !dbg !337
  %29 = alloca i16, i16 1, align 2, !dbg !338
  %30 = alloca i16, i16 1, align 2, !dbg !339
  %31 = alloca i16, i16 1, align 2, !dbg !340
  %32 = alloca i16, i16 1, align 2, !dbg !341
  %33 = alloca i16, i16 1, align 2, !dbg !342
  %34 = alloca i16, i16 1, align 2, !dbg !343
  %35 = alloca i16, i16 1, align 2, !dbg !344
  %36 = alloca i16, i16 1, align 2, !dbg !345
  %37 = alloca i16, i16 1, align 2, !dbg !346
  store i16 %0, i16* %37, align 2, !dbg !346
  store i16 %1, i16* %36, align 2, !dbg !345
  store i16 %2, i16* %35, align 2, !dbg !344
  store i16 %3, i16* %34, align 2, !dbg !343
  store i16 %4, i16* %33, align 2, !dbg !342
  store i16 %5, i16* %32, align 2, !dbg !341
  store i16 %6, i16* %31, align 2, !dbg !340
  store i16 %7, i16* %30, align 2, !dbg !339
  store i16 %8, i16* %29, align 2, !dbg !338
  store i16 %9, i16* %28, align 2, !dbg !337
  store i16 %10, i16* %27, align 2, !dbg !336
  store float %11, float* %26, align 4, !dbg !335
  store float %12, float* %25, align 4, !dbg !334
  %38 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord(), !dbg !347
  store i16 %38, i16* %24, align 2, !dbg !333
  %39 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord(), !dbg !348
  store i16 %39, i16* %23, align 2, !dbg !332
  %40 = load i16, i16* %24, align 2, !dbg !349
  %41 = load i16, i16* %36, align 2, !dbg !350
  %42 = sub i16 %40, %41, !dbg !351
  store i16 %42, i16* %22, align 2, !dbg !331
  %43 = load i16, i16* %22, align 2, !dbg !352
  store i16 %43, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !353
  %44 = load i16, i16* %29, align 2, !dbg !354
  %45 = icmp eq i16 3, %44, !dbg !355
  br i1 %45, label %46, label %63, !dbg !356

46:                                               ; preds = %13
  %47 = load i16, i16* %22, align 2, !dbg !357
  %48 = sitofp i16 %47 to float, !dbg !358
  %49 = load float, float* %26, align 4, !dbg !359
  %50 = fmul float %48, %49, !dbg !360
  %51 = fptosi float %50 to i16, !dbg !361
  store i16 %51, i16* %21, align 2, !dbg !330
  %52 = load i16, i16* %22, align 2, !dbg !362
  %53 = load i16, i16* %21, align 2, !dbg !363
  %54 = load i16, i16* %28, align 2, !dbg !364
  %55 = mul i16 %53, %54, !dbg !365
  %56 = sub i16 %52, %55, !dbg !366
  store i16 %56, i16* %20, align 2, !dbg !329
  %57 = load i16, i16* %20, align 2, !dbg !367
  %58 = icmp ne i16 0, %57, !dbg !368
  br i1 %58, label %59, label %60, !dbg !369

59:                                               ; preds = %46
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !370
  br label %62, !dbg !369

60:                                               ; preds = %46
  %61 = load i16, i16* %21, align 2, !dbg !371
  store i16 %61, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !372
  br label %62, !dbg !369

62:                                               ; preds = %59, %60
  br label %63, !dbg !356

63:                                               ; preds = %62, %13
  %64 = load i16, i16* %22, align 2, !dbg !373
  %65 = icmp slt i16 %64, 0, !dbg !374
  br i1 %65, label %66, label %67, !dbg !375

66:                                               ; preds = %63
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !376
  br label %67, !dbg !375

67:                                               ; preds = %66, %63
  %68 = load i16, i16* %22, align 2, !dbg !377
  %69 = load i16, i16* %34, align 2, !dbg !378
  %70 = icmp sge i16 %68, %69, !dbg !379
  br i1 %70, label %71, label %72, !dbg !380

71:                                               ; preds = %67
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !381
  br label %72, !dbg !380

72:                                               ; preds = %71, %67
  store i1 false, i1* %19, align 1, !dbg !328
  %73 = load i16, i16* %29, align 2, !dbg !382
  %74 = icmp eq i16 3, %73, !dbg !383
  br i1 %74, label %75, label %94, !dbg !384

75:                                               ; preds = %72
  %76 = load i16, i16* %23, align 2, !dbg !385
  %77 = load i16, i16* %35, align 2, !dbg !386
  %78 = sub i16 %76, %77, !dbg !387
  %79 = sitofp i16 %78 to float, !dbg !388
  %80 = load float, float* %25, align 4, !dbg !389
  %81 = fmul float %79, %80, !dbg !390
  %82 = fptosi float %81 to i16, !dbg !391
  store i16 %82, i16* %18, align 2, !dbg !327
  %83 = load i16, i16* %23, align 2, !dbg !392
  %84 = load i16, i16* %35, align 2, !dbg !393
  %85 = sub i16 %83, %84, !dbg !394
  %86 = load i16, i16* %18, align 2, !dbg !395
  %87 = load i16, i16* %27, align 2, !dbg !396
  %88 = mul i16 %86, %87, !dbg !397
  %89 = sub i16 %85, %88, !dbg !398
  store i16 %89, i16* %17, align 2, !dbg !326
  %90 = load i16, i16* %17, align 2, !dbg !399
  %91 = icmp ne i16 0, %90, !dbg !400
  br i1 %91, label %92, label %93, !dbg !401

92:                                               ; preds = %75
  store i1 true, i1* %19, align 1, !dbg !402
  br label %93, !dbg !401

93:                                               ; preds = %92, %75
  br label %94, !dbg !384

94:                                               ; preds = %93, %72
  %95 = load i16, i16* %23, align 2, !dbg !403
  %96 = load i16, i16* %35, align 2, !dbg !404
  %97 = icmp slt i16 %95, %96, !dbg !405
  br i1 %97, label %98, label %99, !dbg !406

98:                                               ; preds = %94
  store i1 true, i1* %19, align 1, !dbg !407
  br label %99, !dbg !406

99:                                               ; preds = %98, %94
  %100 = load i16, i16* %23, align 2, !dbg !408
  %101 = load i16, i16* %35, align 2, !dbg !409
  %102 = load i16, i16* %33, align 2, !dbg !410
  %103 = add i16 %101, %102, !dbg !411
  %104 = icmp sge i16 %100, %103, !dbg !412
  br i1 %104, label %105, label %106, !dbg !413

105:                                              ; preds = %99
  store i1 true, i1* %19, align 1, !dbg !414
  br label %106, !dbg !413

106:                                              ; preds = %105, %99
  %107 = load i1, i1* %19, align 1, !dbg !415
  br i1 %107, label %108, label %109, !dbg !416

108:                                              ; preds = %106
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream(), !dbg !417
  call void @llvm.sdr.ublk.r(i16 27), !dbg !418
  br label %180, !dbg !416

109:                                              ; preds = %106
  %110 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !419
  %111 = icmp eq i16 -1, %110, !dbg !420
  br i1 %111, label %112, label %113, !dbg !421

112:                                              ; preds = %109
  call void @__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction(i16 31767), !dbg !422
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 23), !dbg !423
  call void @llvm.sdr.ublk.r(i16 27), !dbg !424
  br label %179, !dbg !421

113:                                              ; preds = %109
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter(i16 0, i16 0), !dbg !425
  %114 = load i16, i16* %34, align 2, !dbg !426
  store i16 %114, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !427
  %115 = load i16, i16* %29, align 2, !dbg !428
  %116 = icmp eq i16 3, %115, !dbg !429
  br i1 %116, label %117, label %126, !dbg !430

117:                                              ; preds = %113
  %118 = load i16, i16* %34, align 2, !dbg !431
  %119 = sub i16 %118, 1, !dbg !432
  %120 = sitofp i16 %119 to float, !dbg !433
  %121 = load float, float* %26, align 4, !dbg !434
  %122 = fmul float %120, %121, !dbg !435
  %123 = fptosi float %122 to i16, !dbg !436
  %124 = add i16 %123, 1, !dbg !437
  store i16 %124, i16* %16, align 2, !dbg !325
  %125 = load i16, i16* %16, align 2, !dbg !438
  store i16 %125, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !439
  br label %131, !dbg !430

126:                                              ; preds = %113
  %127 = load i16, i16* %29, align 2, !dbg !440
  %128 = icmp eq i16 1, %127, !dbg !441
  br i1 %128, label %129, label %130, !dbg !442

129:                                              ; preds = %126
  store i16 1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !443
  br label %130, !dbg !442

130:                                              ; preds = %129, %126
  br label %131, !dbg !430

131:                                              ; preds = %117, %130
  %132 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !444
  %133 = sub i16 %132, 1, !dbg !445
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit(i16 0, i16 %133), !dbg !446
  %134 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !447
  store i16 %134, i16* %15, align 2, !dbg !324
  %135 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !448
  store i16 %135, i16* %14, align 2, !dbg !322
  %136 = load i16, i16* %15, align 2, !dbg !449
  %137 = load i16, i16* %14, align 2, !dbg !450
  %138 = sub i16 %136, %137, !dbg !451
  store i16 %138, i16* %15, align 2, !dbg !452
  %139 = load i16, i16* %14, align 2, !dbg !453
  %140 = icmp eq i16 0, %139, !dbg !454
  br i1 %140, label %141, label %142, !dbg !455

141:                                              ; preds = %131
  store i16 0, i16* %15, align 2, !dbg !456
  br label %142, !dbg !455

142:                                              ; preds = %141, %131
  %143 = load i16, i16* %29, align 2, !dbg !457
  %144 = icmp eq i16 1, %143, !dbg !458
  br i1 %144, label %145, label %146, !dbg !459

145:                                              ; preds = %142
  store i16 0, i16* %15, align 2, !dbg !460
  br label %146, !dbg !459

146:                                              ; preds = %145, %142
  %147 = load i16, i16* %15, align 2, !dbg !461
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter(i16 0, i16 %147), !dbg !462
  call void @__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction(i16 31767), !dbg !463
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 23), !dbg !464
  %148 = load i16, i16* %37, align 2, !dbg !465
  %149 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval(i16 %148), !dbg !466
  %150 = icmp eq i16 0, %149, !dbg !467
  br i1 %150, label %151, label %155, !dbg !468

151:                                              ; preds = %146
  %152 = load i16, i16* %32, align 2, !dbg !469
  %153 = load i16, i16* %31, align 2, !dbg !470
  %154 = load i16, i16* %30, align 2, !dbg !471
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start(i16 %152, i16 %153, i16 %154), !dbg !472
  br label %178, !dbg !468

155:                                              ; preds = %146
  %156 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !473
  %157 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !473
  %158 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !473
  %159 = load i16, i16* %31, align 2, !dbg !474
  store i16 %159, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !475
  store i16 %156, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !475
  store i16 %157, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !475
  store i16 %158, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !475
  %160 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !476
  %161 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !476
  %162 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !476
  %163 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !476
  %164 = and i16 %162, -193, !dbg !476
  %165 = or i16 %164, 128, !dbg !476
  store volatile i16 %160, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !477
  store volatile i16 %161, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !477
  store volatile i16 %165, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !477
  store volatile i16 %163, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !477
  call void asm sideeffect "nop", ""(), !dbg !477
  call void asm sideeffect "nop", ""(), !dbg !477
  %166 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !478
  %167 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !478
  %168 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !478
  %169 = load i16, i16* %31, align 2, !dbg !479
  store i16 %169, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !480
  store i16 %166, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !480
  store i16 %167, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !480
  store i16 %168, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !480
  %170 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !481
  %171 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !481
  %172 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !481
  %173 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !481
  %174 = and i16 %172, -193, !dbg !481
  %175 = or i16 %174, 128, !dbg !481
  %176 = and i16 %171, -64, !dbg !481
  %177 = or i16 %176, 27, !dbg !481
  store volatile i16 %170, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !482
  store volatile i16 %177, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !482
  store volatile i16 %175, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !482
  store volatile i16 %173, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !482
  call void asm sideeffect "nop", ""(), !dbg !482
  call void asm sideeffect "nop", ""(), !dbg !482
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !483
  br label %178, !dbg !468

178:                                              ; preds = %151, %155
  br label %179, !dbg !421

179:                                              ; preds = %112, %178
  br label %180, !dbg !416

180:                                              ; preds = %108, %179
  ret void, !dbg !356
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit(i16 %0, i16 %1) !dbg !484 {
  %3 = alloca i16, i16 1, align 2, !dbg !486
  %4 = alloca i16, i16 1, align 2, !dbg !488
  %5 = alloca i16, i16 1, align 2, !dbg !489
  %6 = alloca i16, i16 1, align 2, !dbg !490
  %7 = alloca i16, i16 1, align 2, !dbg !491
  %8 = alloca i16, i16 1, align 2, !dbg !492
  store i16 %0, i16* %8, align 2, !dbg !492
  store i16 %1, i16* %7, align 2, !dbg !491
  %9 = load i16, i16* %7, align 2, !dbg !493
  %10 = icmp ult i16 %9, -32768, !dbg !494
  br i1 %10, label %11, label %12, !dbg !495

11:                                               ; preds = %2
  br label %13, !dbg !495

12:                                               ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !495
  br label %13, !dbg !495

13:                                               ; preds = %11, %12
  %14 = load i16, i16* %7, align 2, !dbg !496
  %15 = mul i16 %14, 2, !dbg !497
  store i16 %15, i16* %6, align 2, !dbg !490
  %16 = load i16, i16* %8, align 2, !dbg !498
  %17 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %16, i16 8), !dbg !499
  %18 = sub i16 %17, 1, !dbg !500
  store i16 %18, i16* %5, align 2, !dbg !489
  %19 = load i16, i16* %6, align 2, !dbg !501
  %20 = load i16, i16* %5, align 2, !dbg !502
  %21 = icmp ult i16 %19, %20, !dbg !503
  br i1 %21, label %22, label %23, !dbg !488

22:                                               ; preds = %13
  store i16 0, i16* %4, align 2, !dbg !488
  br label %27, !dbg !488

23:                                               ; preds = %13
  %24 = load i16, i16* %6, align 2, !dbg !504
  %25 = load i16, i16* %5, align 2, !dbg !505
  %26 = sub i16 %24, %25, !dbg !506
  store i16 %26, i16* %4, align 2, !dbg !488
  br label %27, !dbg !488

27:                                               ; preds = %22, %23
  %28 = load i16, i16* %4, align 2, !dbg !488
  store i16 %28, i16* %3, align 2, !dbg !486
  %29 = load i16, i16* %8, align 2, !dbg !507
  %30 = load i16, i16* %3, align 2, !dbg !508
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %29, i16 4, i16 %30), !dbg !509
  ret void, !dbg !488
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter(i16 %0, i16 %1) !dbg !510 {
  %3 = alloca i16, i16 1, align 2, !dbg !511
  %4 = alloca i16, i16 1, align 2, !dbg !513
  store i16 %0, i16* %4, align 2, !dbg !513
  store i16 %1, i16* %3, align 2, !dbg !511
  %5 = load i16, i16* %3, align 2, !dbg !514
  %6 = icmp ult i16 %5, -32768, !dbg !515
  br i1 %6, label %7, label %8, !dbg !516

7:                                                ; preds = %2
  br label %9, !dbg !516

8:                                                ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !516
  br label %9, !dbg !516

9:                                                ; preds = %7, %8
  %10 = load i16, i16* %4, align 2, !dbg !517
  %11 = load i16, i16* %3, align 2, !dbg !518
  %12 = mul i16 %11, 2, !dbg !519
  %13 = add i16 %12, 1, !dbg !520
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %10, i16 8, i16 %13), !dbg !521
  ret void, !dbg !522
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter(i16 %0, i16 %1) !dbg !523 {
  %3 = alloca i16, i16 1, align 2, !dbg !524
  %4 = alloca i16, i16 1, align 2, !dbg !526
  %5 = alloca i1, i16 1, align 1, !dbg !527
  %6 = alloca i16, i16 1, align 2, !dbg !528
  %7 = alloca i16, i16 1, align 2, !dbg !529
  %8 = alloca i16, i16 1, align 2, !dbg !530
  %9 = alloca i16, i16 1, align 2, !dbg !531
  store i16 %0, i16* %9, align 2, !dbg !531
  store i16 %1, i16* %8, align 2, !dbg !530
  %10 = load i16, i16* %8, align 2, !dbg !532
  %11 = icmp ult i16 %10, -32768, !dbg !533
  br i1 %11, label %12, label %13, !dbg !534

12:                                               ; preds = %2
  br label %14, !dbg !534

13:                                               ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !534
  br label %14, !dbg !534

14:                                               ; preds = %12, %13
  %15 = load i16, i16* %9, align 2, !dbg !535
  %16 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %15, i16 8), !dbg !536
  store i16 %16, i16* %7, align 2, !dbg !529
  %17 = load i16, i16* %8, align 2, !dbg !537
  %18 = mul i16 %17, 2, !dbg !538
  store i16 %18, i16* %6, align 2, !dbg !528
  %19 = load i16, i16* %6, align 2, !dbg !539
  %20 = load i16, i16* %7, align 2, !dbg !540
  %21 = icmp ugt i16 %19, %20, !dbg !541
  store i1 %21, i1* %5, align 1, !dbg !527
  %22 = load i16, i16* %9, align 2, !dbg !542
  %23 = load i1, i1* %5, align 1, !dbg !543
  %24 = zext i1 %23 to i16, !dbg !544
  %25 = shl i16 %24, 6, !dbg !545
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %22, i16 14, i16 %25), !dbg !546
  %26 = load i1, i1* %5, align 1, !dbg !547
  br i1 %26, label %27, label %32, !dbg !526

27:                                               ; preds = %14
  %28 = load i16, i16* %6, align 2, !dbg !548
  %29 = load i16, i16* %7, align 2, !dbg !549
  %30 = sub i16 %28, %29, !dbg !550
  %31 = add i16 %30, 1, !dbg !551
  store i16 %31, i16* %4, align 2, !dbg !526
  br label %34, !dbg !526

32:                                               ; preds = %14
  %33 = load i16, i16* %6, align 2, !dbg !552
  store i16 %33, i16* %4, align 2, !dbg !526
  br label %34, !dbg !526

34:                                               ; preds = %27, %32
  %35 = load i16, i16* %4, align 2, !dbg !526
  store i16 %35, i16* %3, align 2, !dbg !524
  %36 = load i16, i16* %9, align 2, !dbg !553
  %37 = load i16, i16* %3, align 2, !dbg !554
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %36, i16 12, i16 %37), !dbg !555
  ret void, !dbg !526
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %0, i16 %1, i16 %2) !dbg !556 {
  %4 = alloca i16, i16 1, align 2, !dbg !558
  %5 = alloca i16, i16 1, align 2, !dbg !560
  %6 = alloca i16, i16 1, align 2, !dbg !561
  store i16 %0, i16* %6, align 2, !dbg !561
  store i16 %1, i16* %5, align 2, !dbg !560
  store i16 %2, i16* %4, align 2, !dbg !558
  %7 = load i16, i16* %6, align 2, !dbg !562
  %8 = getelementptr [6 x i16], [6 x i16]* @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.filters, i16 0, i16 %7, !dbg !563
  %9 = load i16, i16* %8, align 2, !dbg !563
  %10 = load i16, i16* %5, align 2, !dbg !564
  %11 = add i16 %9, %10, !dbg !565
  %12 = lshr i16 %11, 1, !dbg !566
  %13 = load i16, i16* %4, align 2, !dbg !567
  %14 = shl i16 %12, 1, !dbg !568
  %15 = inttoptr i16 %14 to i16*, !dbg !568
  store volatile i16 %13, i16* %15, align 2, !dbg !568
  call void asm sideeffect "nop", ""(), !dbg !568
  call void asm sideeffect "nop", ""(), !dbg !568
  ret void, !dbg !569
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %0, i16 %1) !dbg !570 {
  %3 = alloca i16, i16 1, align 2, !dbg !571
  %4 = alloca i16, i16 1, align 2, !dbg !573
  store i16 %0, i16* %4, align 2, !dbg !573
  store i16 %1, i16* %3, align 2, !dbg !571
  %5 = load i16, i16* %4, align 2, !dbg !574
  %6 = getelementptr [6 x i16], [6 x i16]* @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.filters, i16 0, i16 %5, !dbg !575
  %7 = load i16, i16* %6, align 2, !dbg !575
  %8 = load i16, i16* %3, align 2, !dbg !576
  %9 = add i16 %7, %8, !dbg !577
  %10 = lshr i16 %9, 1, !dbg !578
  %11 = shl i16 %10, 1, !dbg !579
  %12 = inttoptr i16 %11 to i16*, !dbg !579
  call void asm sideeffect "nop", ""(), !dbg !579
  call void asm sideeffect "nop", ""(), !dbg !579
  %13 = load volatile i16, i16* %12, align 2, !dbg !579
  ret i16 %13, !dbg !580
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 %0) !dbg !581 {
  %2 = alloca i16, i16 1, align 2, !dbg !583
  %3 = alloca i16, i16 1, align 2, !dbg !585
  %4 = alloca i16, i16 1, align 2, !dbg !586
  %5 = alloca i16, i16 1, align 2, !dbg !587
  store i16 %0, i16* %5, align 2, !dbg !587
  %6 = load i16, i16* %5, align 2, !dbg !588
  store i16 %6, i16* %4, align 2, !dbg !586
  %7 = load i16, i16* %4, align 2, !dbg !589
  %8 = add i16 %7, 31744, !dbg !590
  store i16 %8, i16* %3, align 2, !dbg !585
  %9 = load i16, i16* %3, align 2, !dbg !591
  %10 = shl i16 %9, 1, !dbg !592
  %11 = inttoptr i16 %10 to i16*, !dbg !592
  call void asm sideeffect "nop", ""(), !dbg !592
  call void asm sideeffect "nop", ""(), !dbg !592
  %12 = load volatile i16, i16* %11, align 2, !dbg !592
  store i16 %12, i16* %2, align 2, !dbg !583
  %13 = load i16, i16* %3, align 2, !dbg !593
  %14 = load i16, i16* %2, align 2, !dbg !594
  %15 = and i16 %14, 32767, !dbg !595
  %16 = shl i16 %13, 1, !dbg !596
  %17 = inttoptr i16 %16 to i16*, !dbg !596
  store volatile i16 %15, i16* %17, align 2, !dbg !596
  call void asm sideeffect "nop", ""(), !dbg !596
  call void asm sideeffect "nop", ""(), !dbg !596
  ret void, !dbg !597
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord() !dbg !598 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 2), !dbg !600
  %2 = sub i16 %1, 4, !dbg !602
  ret i16 %2, !dbg !603
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord() !dbg !604 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 0), !dbg !605
  %2 = sub i16 %1, 1, !dbg !607
  ret i16 %2, !dbg !608
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 %0) !dbg !609 {
  %2 = alloca i16, i16 1, align 2, !dbg !611
  %3 = alloca i16, i16 1, align 2, !dbg !613
  store i16 %0, i16* %3, align 2, !dbg !613
  %4 = load i16, i16* %3, align 2, !dbg !614
  %5 = lshr i16 %4, 1, !dbg !615
  %6 = add i16 %5, 31813, !dbg !616
  %7 = shl i16 %6, 1, !dbg !617
  %8 = inttoptr i16 %7 to i16*, !dbg !617
  call void asm sideeffect "nop", ""(), !dbg !617
  call void asm sideeffect "nop", ""(), !dbg !617
  %9 = load volatile i16, i16* %8, align 2, !dbg !617
  store i16 %9, i16* %2, align 2, !dbg !611
  %10 = load i16, i16* %2, align 2, !dbg !618
  %11 = and i16 %10, 2047, !dbg !619
  ret i16 %11, !dbg !620
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord() !dbg !621 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord(), !dbg !623
  ret i16 %1, !dbg !625
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.get_y_coord() !dbg !626 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord(), !dbg !627
  ret i16 %1, !dbg !629
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval(i16 %0) !dbg !630 {
  %2 = alloca i16, i16 1, align 2, !dbg !631
  store i16 %0, i16* %2, align 2, !dbg !631
  %3 = load i16, i16* %2, align 2, !dbg !633
  %4 = icmp ult i16 %3, 24, !dbg !634
  br i1 %4, label %5, label %7, !dbg !635

5:                                                ; preds = %10, %11, %1
  %6 = phi i16 [ 0, %10 ], [ 0, %11 ], [ 1, %1 ]
  br label %12, !dbg !635

7:                                                ; preds = %1
  %8 = load i16, i16* %2, align 2, !dbg !636
  %9 = icmp eq i16 31, %8, !dbg !637
  br i1 %9, label %10, label %11, !dbg !638

10:                                               ; preds = %7
  br label %5, !dbg !638

11:                                               ; preds = %7
  call void asm sideeffect "hcf", ""(), !dbg !638
  br label %5, !dbg !638

12:                                               ; preds = %5
  %13 = phi i16 [ %6, %5 ]
  br label %14, !dbg !635

14:                                               ; preds = %12
  ret i16 %13, !dbg !635
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7) !dbg !639 {
  %9 = alloca i16, i16 1, align 2, !dbg !640
  %10 = alloca i16, i16 1, align 2, !dbg !642
  %11 = alloca i16, i16 1, align 2, !dbg !643
  %12 = alloca i16, i16 1, align 2, !dbg !644
  %13 = alloca i16, i16 1, align 2, !dbg !645
  %14 = alloca i16, i16 1, align 2, !dbg !646
  %15 = alloca i16, i16 1, align 2, !dbg !647
  %16 = alloca i16, i16 1, align 2, !dbg !648
  %17 = alloca i16, i16 1, align 2, !dbg !649
  store i16 %0, i16* %17, align 2, !dbg !649
  store i16 %1, i16* %16, align 2, !dbg !648
  store i16 %2, i16* %15, align 2, !dbg !647
  store i16 %3, i16* %14, align 2, !dbg !646
  store i16 %4, i16* %13, align 2, !dbg !645
  store i16 %5, i16* %12, align 2, !dbg !644
  store i16 %6, i16* %11, align 2, !dbg !643
  store i16 %7, i16* %10, align 2, !dbg !642
  %18 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !650
  store i16 %18, i16* %9, align 2, !dbg !640
  %19 = load i16, i16* %11, align 2, !dbg !651
  store i16 %19, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_c, align 2, !dbg !652
  %20 = load i16, i16* %10, align 2, !dbg !653
  store i16 %20, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_is_half, align 2, !dbg !654
  %21 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_c, align 2, !dbg !655
  %22 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval(i16 %21), !dbg !656
  store i16 %22, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !657
  store i16 0, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !658
  %23 = load i16, i16* %16, align 2, !dbg !659
  store i16 %23, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !660
  %24 = load i16, i16* %15, align 2, !dbg !661
  store i16 %24, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !662
  %25 = load i16, i16* %15, align 2, !dbg !663
  %26 = load i16, i16* %13, align 2, !dbg !664
  %27 = add i16 %25, %26, !dbg !665
  %28 = sub i16 %27, 1, !dbg !666
  store i16 %28, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_last, align 2, !dbg !667
  %29 = load i16, i16* %9, align 2, !dbg !668
  %30 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_last, align 2, !dbg !669
  %31 = icmp eq i16 %29, %30, !dbg !670
  br i1 %31, label %32, label %37, !dbg !671

32:                                               ; preds = %8
  %33 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !672
  %34 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !672
  %35 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !672
  store i16 %33, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !673
  store i16 lshr (i16 ptrtoint ([1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.ctrl_1 to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !673
  store i16 %34, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !673
  store i16 %35, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !673
  %36 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.ctrl_1, i16 0, i1 false), align 4, !dbg !674
  store i32 %36, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i1 false), align 4, !dbg !675
  br label %42, !dbg !671

37:                                               ; preds = %8
  %38 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !676
  %39 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !676
  %40 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !676
  store i16 %38, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !677
  store i16 lshr (i16 ptrtoint ([1 x i32]* @"$$csl_base_address$$0$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11" to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !677
  store i16 %39, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !677
  store i16 %40, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !677
  %41 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @"$$csl_base_address$$0$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11", i16 0, i1 false), align 4, !dbg !678
  store i32 %41, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i1 false), align 4, !dbg !679
  br label %42, !dbg !671

42:                                               ; preds = %32, %37
  store i32 165646921, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i2 1), align 4, !dbg !680
  %43 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !681
  %44 = icmp eq i16 0, %43, !dbg !682
  br i1 %44, label %45, label %56, !dbg !683

45:                                               ; preds = %42
  %46 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !684
  %47 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !684
  %48 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !684
  %49 = load i16, i16* %17, align 2, !dbg !685
  %50 = call i16* @.get_tensor_ptr(i16 %49), !dbg !686
  %51 = ptrtoint i16* %50 to i16, !dbg !687
  %52 = lshr i16 %51, 1, !dbg !687
  store i16 %46, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !688
  store i16 %52, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !688
  store i16 %47, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !688
  store i16 %48, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !688
  %53 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !689
  %54 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !689
  %55 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !689
  store i16 1, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !690
  store i16 %53, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !690
  store i16 %54, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !690
  store i16 %55, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !690
  call void @llvm.sdr.actvt.r(i16 21), !dbg !691
  br label %63, !dbg !683

56:                                               ; preds = %42
  %57 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !692
  %58 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !692
  %59 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !692
  store i16 %57, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !693
  store i16 lshr (i16 ptrtoint ([1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.data_buf to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !693
  store i16 %58, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !693
  store i16 %59, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !693
  %60 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !694
  %61 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !694
  %62 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !694
  store i16 1, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !695
  store i16 %60, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !695
  store i16 %61, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !695
  store i16 %62, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !695
  call void @llvm.sdr.ublk.r(i16 0), !dbg !696
  br label %63, !dbg !683

63:                                               ; preds = %45, %56
  ret void, !dbg !671
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x(i32 %0) #8 !dbg !697 {
  %2 = alloca i32, i16 1, align 4, !dbg !698
  store i32 %0, i32* %2, align 4, !dbg !698
  call void @llvm.sdr.blk.r(i16 0), !dbg !700
  %3 = load i32, i32* %2, align 4, !dbg !701
  store i32 %3, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.data_buf, i16 0, i1 false), align 4, !dbg !702
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !703
  %4 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !704
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !704
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !704
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !704
  store volatile i16 %4, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !705
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !705
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !705
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !705
  call void asm sideeffect "nop", ""(), !dbg !705
  call void asm sideeffect "nop", ""(), !dbg !705
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !706
  %8 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !707
  %9 = add i16 %8, 1, !dbg !708
  store i16 %9, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !709
  ret void, !dbg !710
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_send_data() #9 !dbg !711 {
  %1 = alloca i16, i16 1, align 2, !dbg !712
  %2 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !714
  %3 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !715
  %4 = icmp ult i16 %2, %3, !dbg !716
  br i1 %4, label %5, label %27, !dbg !717

5:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !718
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !719
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !719
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !719
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !719
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !720
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !720
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !720
  store volatile i16 %9, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !720
  call void asm sideeffect "nop", ""(), !dbg !720
  call void asm sideeffect "nop", ""(), !dbg !720
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_is_half, align 2, !dbg !721
  %11 = icmp ult i16 0, %10, !dbg !722
  br i1 %11, label %12, label %18, !dbg !723

12:                                               ; preds = %5
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !724
  %13 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !725
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !725
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !725
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !725
  %17 = add i16 %14, 1, !dbg !726
  store i16 %13, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !727
  store i16 %17, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !727
  store i16 %15, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !727
  store i16 %16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !727
  br label %24, !dbg !723

18:                                               ; preds = %5
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !728
  %19 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !729
  %20 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !729
  %21 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !729
  %22 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !729
  %23 = add i16 %20, 2, !dbg !730
  store i16 %19, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !731
  store i16 %23, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !731
  store i16 %21, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !731
  store i16 %22, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !731
  br label %24, !dbg !723

24:                                               ; preds = %12, %18
  %25 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !732
  %26 = add i16 %25, 1, !dbg !733
  store i16 %26, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !734
  br label %34, !dbg !717

27:                                               ; preds = %0
  %28 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !735
  store i16 %28, i16* %1, align 2, !dbg !712
  %29 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !736
  %30 = load i16, i16* %1, align 2, !dbg !737
  %31 = icmp eq i16 %29, %30, !dbg !738
  br i1 %31, label %32, label %33, !dbg !739

32:                                               ; preds = %27
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !740
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__1 to i8*)), !dbg !741
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !742
  br label %33, !dbg !739

33:                                               ; preds = %32, %27
  br label %34, !dbg !717

34:                                               ; preds = %24, %33
  ret void, !dbg !717
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl() #10 !dbg !743 {
  %1 = alloca i16, i16 1, align 2, !dbg !744
  %2 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !746
  %3 = icmp eq i16 0, %2, !dbg !747
  br i1 %3, label %4, label %9, !dbg !748

4:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__2 to i8*)), !dbg !749
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !750
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !750
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !750
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !750
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !751
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !751
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !751
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !751
  call void asm sideeffect "nop", ""(), !dbg !751
  call void asm sideeffect "nop", ""(), !dbg !751
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !752
  br label %31, !dbg !748

9:                                                ; preds = %0
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !753
  %11 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !754
  %12 = icmp ult i16 %10, %11, !dbg !755
  br i1 %12, label %13, label %18, !dbg !756

13:                                               ; preds = %9
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__3 to i8*)), !dbg !757
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !758
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !758
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !758
  %17 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !758
  store volatile i16 %14, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !759
  store volatile i16 %15, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !759
  store volatile i16 %16, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !759
  store volatile i16 %17, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !759
  call void asm sideeffect "nop", ""(), !dbg !759
  call void asm sideeffect "nop", ""(), !dbg !759
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !760
  br label %30, !dbg !756

18:                                               ; preds = %9
  %19 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !761
  store i16 %19, i16* %1, align 2, !dbg !744
  %20 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !762
  %21 = load i16, i16* %1, align 2, !dbg !763
  %22 = icmp eq i16 %20, %21, !dbg !764
  br i1 %22, label %23, label %24, !dbg !765

23:                                               ; preds = %18
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__4 to i8*)), !dbg !766
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__5 to i8*)), !dbg !767
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !768
  br label %29, !dbg !765

24:                                               ; preds = %18
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !769
  %25 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !770
  %26 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !770
  %27 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !770
  %28 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !770
  store volatile i16 %25, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !771
  store volatile i16 %26, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !771
  store volatile i16 %27, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !771
  store volatile i16 %28, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !771
  call void asm sideeffect "nop", ""(), !dbg !771
  call void asm sideeffect "nop", ""(), !dbg !771
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !772
  br label %29, !dbg !765

29:                                               ; preds = %23, %24
  br label %30, !dbg !756

30:                                               ; preds = %13, %29
  br label %31, !dbg !748

31:                                               ; preds = %4, %30
  ret void, !dbg !748
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.d2h_configure(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7) !dbg !773 {
  %9 = alloca i1, i16 1, align 1, !dbg !774
  %10 = alloca i1, i16 1, align 1, !dbg !776
  %11 = alloca i1, i16 1, align 1, !dbg !777
  %12 = alloca i16, i16 1, align 2, !dbg !778
  %13 = alloca i16, i16 1, align 2, !dbg !779
  %14 = alloca i16, i16 1, align 2, !dbg !780
  %15 = alloca i16, i16 1, align 2, !dbg !781
  %16 = alloca i16, i16 1, align 2, !dbg !782
  %17 = alloca i16, i16 1, align 2, !dbg !783
  %18 = alloca i16, i16 1, align 2, !dbg !784
  %19 = alloca i16, i16 1, align 2, !dbg !785
  %20 = alloca i16, i16 1, align 2, !dbg !786
  %21 = alloca i16, i16 1, align 2, !dbg !787
  %22 = alloca i16, i16 1, align 2, !dbg !788
  %23 = alloca i16, i16 1, align 2, !dbg !789
  %24 = alloca i16, i16 1, align 2, !dbg !790
  %25 = alloca i16, i16 1, align 2, !dbg !791
  store i16 %0, i16* %25, align 2, !dbg !791
  store i16 %1, i16* %24, align 2, !dbg !790
  store i16 %2, i16* %23, align 2, !dbg !789
  store i16 %3, i16* %22, align 2, !dbg !788
  store i16 %4, i16* %21, align 2, !dbg !787
  store i16 %5, i16* %20, align 2, !dbg !786
  store i16 %6, i16* %19, align 2, !dbg !785
  store i16 %7, i16* %18, align 2, !dbg !784
  %26 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !792
  store i16 %26, i16* %17, align 2, !dbg !783
  %27 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_y_coord(), !dbg !793
  store i16 %27, i16* %16, align 2, !dbg !782
  %28 = load i16, i16* %24, align 2, !dbg !794
  store i16 %28, i16* %15, align 2, !dbg !781
  %29 = load i16, i16* %24, align 2, !dbg !795
  %30 = load i16, i16* %22, align 2, !dbg !796
  %31 = add i16 %29, %30, !dbg !797
  %32 = sub i16 %31, 1, !dbg !798
  store i16 %32, i16* %14, align 2, !dbg !780
  %33 = load i16, i16* %23, align 2, !dbg !799
  store i16 %33, i16* %13, align 2, !dbg !779
  %34 = load i16, i16* %23, align 2, !dbg !800
  %35 = load i16, i16* %21, align 2, !dbg !801
  %36 = add i16 %34, %35, !dbg !802
  %37 = sub i16 %36, 1, !dbg !803
  store i16 %37, i16* %12, align 2, !dbg !778
  store i1 false, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !804
  %38 = load i16, i16* %17, align 2, !dbg !805
  %39 = load i16, i16* %15, align 2, !dbg !806
  %40 = icmp sge i16 %38, %39, !dbg !807
  br i1 %40, label %41, label %45, !dbg !777

41:                                               ; preds = %8
  %42 = load i16, i16* %16, align 2, !dbg !808
  %43 = load i16, i16* %12, align 2, !dbg !809
  %44 = icmp sle i16 %42, %43, !dbg !810
  store i1 %44, i1* %11, align 1, !dbg !777
  br label %46, !dbg !777

45:                                               ; preds = %8
  store i1 false, i1* %11, align 1, !dbg !777
  br label %46, !dbg !777

46:                                               ; preds = %41, %45
  %47 = load i1, i1* %11, align 1, !dbg !777
  br i1 %47, label %48, label %52, !dbg !776

48:                                               ; preds = %46
  %49 = load i16, i16* %16, align 2, !dbg !811
  %50 = load i16, i16* %13, align 2, !dbg !812
  %51 = icmp sge i16 %49, %50, !dbg !813
  store i1 %51, i1* %10, align 1, !dbg !776
  br label %53, !dbg !776

52:                                               ; preds = %46
  store i1 false, i1* %10, align 1, !dbg !776
  br label %53, !dbg !776

53:                                               ; preds = %48, %52
  %54 = load i1, i1* %10, align 1, !dbg !776
  br i1 %54, label %55, label %56, !dbg !814

55:                                               ; preds = %53
  store i1 true, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !815
  br label %56, !dbg !814

56:                                               ; preds = %55, %53
  store i1 false, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !816
  %57 = load i16, i16* %17, align 2, !dbg !817
  %58 = load i16, i16* %14, align 2, !dbg !818
  %59 = icmp sle i16 %57, %58, !dbg !819
  br i1 %59, label %60, label %62, !dbg !774

60:                                               ; preds = %56
  %61 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !820
  store i1 %61, i1* %9, align 1, !dbg !774
  br label %63, !dbg !774

62:                                               ; preds = %56
  store i1 false, i1* %9, align 1, !dbg !774
  br label %63, !dbg !774

63:                                               ; preds = %60, %62
  %64 = load i1, i1* %9, align 1, !dbg !774
  br i1 %64, label %65, label %66, !dbg !821

65:                                               ; preds = %63
  store i1 true, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !822
  br label %66, !dbg !821

66:                                               ; preds = %65, %63
  %67 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !823
  br i1 %67, label %68, label %86, !dbg !824

68:                                               ; preds = %66
  call void @__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position(i16 31959), !dbg !825
  %69 = load i16, i16* %15, align 2, !dbg !826
  %70 = load i16, i16* %17, align 2, !dbg !827
  %71 = icmp eq i16 %69, %70, !dbg !828
  br i1 %71, label %72, label %73, !dbg !829

72:                                               ; preds = %68
  call void @__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 31765), !dbg !830
  br label %74, !dbg !829

73:                                               ; preds = %68
  call void @__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 31765), !dbg !831
  br label %74, !dbg !829

74:                                               ; preds = %72, %73
  call void @sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit(i16 21), !dbg !832
  %75 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !833
  br i1 %75, label %76, label %85, !dbg !834

76:                                               ; preds = %74
  %77 = load i16, i16* %20, align 2, !dbg !835
  %78 = load i16, i16* %19, align 2, !dbg !836
  %79 = load i16, i16* %24, align 2, !dbg !837
  %80 = load i16, i16* %23, align 2, !dbg !838
  %81 = load i16, i16* %22, align 2, !dbg !839
  %82 = load i16, i16* %21, align 2, !dbg !840
  %83 = load i16, i16* %25, align 2, !dbg !841
  %84 = load i16, i16* %18, align 2, !dbg !842
  call void @sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start(i16 %77, i16 %78, i16 %79, i16 %80, i16 %81, i16 %82, i16 %83, i16 %84), !dbg !843
  br label %85, !dbg !834

85:                                               ; preds = %76, %74
  br label %87, !dbg !824

86:                                               ; preds = %66
  call void @llvm.sdr.actvt.r(i16 28), !dbg !844
  br label %87, !dbg !824

87:                                               ; preds = %85, %86
  ret void, !dbg !777
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit(i16 %0) !dbg !845 {
  %2 = alloca i16, i16 1, align 2, !dbg !846
  %3 = alloca i16, i16 1, align 2, !dbg !848
  %4 = alloca i16, i16 1, align 2, !dbg !849
  %5 = alloca i16, i16 1, align 2, !dbg !850
  store i16 %0, i16* %5, align 2, !dbg !850
  %6 = load i16, i16* %5, align 2, !dbg !851
  store i16 %6, i16* %4, align 2, !dbg !849
  %7 = load i16, i16* %4, align 2, !dbg !852
  %8 = add i16 %7, 31744, !dbg !853
  store i16 %8, i16* %3, align 2, !dbg !848
  %9 = load i16, i16* %3, align 2, !dbg !854
  %10 = shl i16 %9, 1, !dbg !855
  %11 = inttoptr i16 %10 to i16*, !dbg !855
  call void asm sideeffect "nop", ""(), !dbg !855
  call void asm sideeffect "nop", ""(), !dbg !855
  %12 = load volatile i16, i16* %11, align 2, !dbg !855
  store i16 %12, i16* %2, align 2, !dbg !846
  %13 = load i16, i16* %3, align 2, !dbg !856
  %14 = load i16, i16* %2, align 2, !dbg !857
  %15 = and i16 %14, 32767, !dbg !858
  %16 = shl i16 %13, 1, !dbg !859
  %17 = inttoptr i16 %16 to i16*, !dbg !859
  store volatile i16 %15, i16* %17, align 2, !dbg !859
  call void asm sideeffect "nop", ""(), !dbg !859
  call void asm sideeffect "nop", ""(), !dbg !859
  ret void, !dbg !860
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord() !dbg !861 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 2), !dbg !862
  %2 = sub i16 %1, 4, !dbg !864
  ret i16 %2, !dbg !865
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord() !dbg !866 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 0), !dbg !867
  %2 = sub i16 %1, 1, !dbg !869
  ret i16 %2, !dbg !870
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 %0) !dbg !871 {
  %2 = alloca i16, i16 1, align 2, !dbg !872
  %3 = alloca i16, i16 1, align 2, !dbg !874
  store i16 %0, i16* %3, align 2, !dbg !874
  %4 = load i16, i16* %3, align 2, !dbg !875
  %5 = lshr i16 %4, 1, !dbg !876
  %6 = add i16 %5, 31813, !dbg !877
  %7 = shl i16 %6, 1, !dbg !878
  %8 = inttoptr i16 %7 to i16*, !dbg !878
  call void asm sideeffect "nop", ""(), !dbg !878
  call void asm sideeffect "nop", ""(), !dbg !878
  %9 = load volatile i16, i16* %8, align 2, !dbg !878
  store i16 %9, i16* %2, align 2, !dbg !872
  %10 = load i16, i16* %2, align 2, !dbg !879
  %11 = and i16 %10, 2047, !dbg !880
  ret i16 %11, !dbg !881
}

define internal i16 @sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr(i16 %0) !dbg !882 {
  %2 = alloca i16, i16 1, align 2, !dbg !884
  store i16 %0, i16* %2, align 2, !dbg !884
  %3 = load i16, i16* %2, align 2, !dbg !886
  %4 = mul i16 %3, 2, !dbg !887
  %5 = add i16 %4, 31680, !dbg !888
  ret i16 %5, !dbg !889
}

define internal void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 %0, i16 %1, i1 %2) !dbg !890 {
  %4 = alloca i16, i16 1, align 2, !dbg !891
  %5 = alloca i16, i16 1, align 2, !dbg !893
  %6 = alloca i1, i16 1, align 1, !dbg !894
  %7 = alloca i16, i16 1, align 2, !dbg !895
  %8 = alloca i16, i16 1, align 2, !dbg !896
  store i16 %0, i16* %8, align 2, !dbg !896
  store i16 %1, i16* %7, align 2, !dbg !895
  store i1 %2, i1* %6, align 1, !dbg !894
  %9 = load i16, i16* %8, align 2, !dbg !897
  %10 = call i16 @sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr(i16 %9), !dbg !898
  store i16 %10, i16* %5, align 2, !dbg !893
  %11 = load i16, i16* %5, align 2, !dbg !899
  %12 = shl i16 %11, 1, !dbg !900
  %13 = inttoptr i16 %12 to i16*, !dbg !900
  call void asm sideeffect "nop", ""(), !dbg !900
  call void asm sideeffect "nop", ""(), !dbg !900
  call void asm sideeffect "nop", ""(), !dbg !900
  call void asm sideeffect "nop", ""(), !dbg !900
  %14 = load volatile i16, i16* %13, align 2, !dbg !900
  store i16 %14, i16* %4, align 2, !dbg !891
  %15 = load i1, i1* %6, align 1, !dbg !901
  br i1 %15, label %16, label %19, !dbg !902

16:                                               ; preds = %3
  %17 = load i16, i16* %4, align 2, !dbg !903
  %18 = or i16 %17, 2048, !dbg !904
  store i16 %18, i16* %4, align 2, !dbg !905
  br label %22, !dbg !902

19:                                               ; preds = %3
  %20 = load i16, i16* %4, align 2, !dbg !906
  %21 = and i16 %20, -2049, !dbg !907
  store i16 %21, i16* %4, align 2, !dbg !908
  br label %22, !dbg !902

22:                                               ; preds = %16, %19
  %23 = load i16, i16* %4, align 2, !dbg !909
  %24 = and i16 %23, -32, !dbg !910
  store i16 %24, i16* %4, align 2, !dbg !911
  %25 = load i16, i16* %4, align 2, !dbg !912
  %26 = load i16, i16* %7, align 2, !dbg !913
  %27 = add i16 %25, %26, !dbg !914
  store i16 %27, i16* %4, align 2, !dbg !915
  %28 = load i16, i16* %5, align 2, !dbg !916
  %29 = load i16, i16* %4, align 2, !dbg !917
  %30 = shl i16 %28, 1, !dbg !918
  %31 = inttoptr i16 %30 to i16*, !dbg !918
  store volatile i16 %29, i16* %31, align 2, !dbg !918
  call void asm sideeffect "nop", ""(), !dbg !918
  call void asm sideeffect "nop", ""(), !dbg !918
  call void asm sideeffect "nop", ""(), !dbg !918
  call void asm sideeffect "nop", ""(), !dbg !918
  ret void, !dbg !902
}

define internal i16 @sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr(i16 %0) !dbg !919 {
  %2 = alloca i16, i16 1, align 2, !dbg !921
  store i16 %0, i16* %2, align 2, !dbg !921
  %3 = load i16, i16* %2, align 2, !dbg !923
  %4 = add i16 %3, 31616, !dbg !924
  ret i16 %4, !dbg !925
}

define internal void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 %0, i16 %1) !dbg !926 {
  %3 = alloca i16, i16 1, align 2, !dbg !927
  %4 = alloca i16, i16 1, align 2, !dbg !929
  %5 = alloca i16, i16 1, align 2, !dbg !930
  %6 = alloca i16, i16 1, align 2, !dbg !931
  store i16 %0, i16* %6, align 2, !dbg !931
  store i16 %1, i16* %5, align 2, !dbg !930
  %7 = load i16, i16* %6, align 2, !dbg !932
  %8 = call i16 @sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr(i16 %7), !dbg !933
  store i16 %8, i16* %4, align 2, !dbg !929
  %9 = load i16, i16* %4, align 2, !dbg !934
  %10 = shl i16 %9, 1, !dbg !935
  %11 = inttoptr i16 %10 to i16*, !dbg !935
  call void asm sideeffect "nop", ""(), !dbg !935
  call void asm sideeffect "nop", ""(), !dbg !935
  call void asm sideeffect "nop", ""(), !dbg !935
  call void asm sideeffect "nop", ""(), !dbg !935
  %12 = load volatile i16, i16* %11, align 2, !dbg !935
  store i16 %12, i16* %3, align 2, !dbg !927
  %13 = load i16, i16* %3, align 2, !dbg !936
  %14 = and i16 %13, -497, !dbg !937
  store i16 %14, i16* %3, align 2, !dbg !938
  %15 = load i16, i16* %3, align 2, !dbg !939
  %16 = load i16, i16* %5, align 2, !dbg !940
  %17 = add i16 %15, %16, !dbg !941
  %18 = shl i16 %17, 4, !dbg !942
  store i16 %18, i16* %3, align 2, !dbg !943
  %19 = load i16, i16* %4, align 2, !dbg !944
  %20 = load i16, i16* %3, align 2, !dbg !945
  %21 = shl i16 %19, 1, !dbg !946
  %22 = inttoptr i16 %21 to i16*, !dbg !946
  store volatile i16 %20, i16* %22, align 2, !dbg !946
  call void asm sideeffect "nop", ""(), !dbg !946
  call void asm sideeffect "nop", ""(), !dbg !946
  call void asm sideeffect "nop", ""(), !dbg !946
  call void asm sideeffect "nop", ""(), !dbg !946
  ret void, !dbg !947
}

define internal i16* @.get_tensor_ptr(i16 %0) !dbg !948 {
  %2 = alloca i16, i16 1, align 2, !dbg !949
  store i16 %0, i16* %2, align 2, !dbg !949
  %3 = load i16, i16* %2, align 2, !dbg !949
  %4 = zext i16 %3 to i32, !dbg !949
  switch i32 %4, label %5 [
    i32 1, label %9
    i32 2, label %11
    i32 3, label %13
    i32 4, label %15
    i32 5, label %17
  ], !dbg !949

5:                                                ; preds = %1
  br i1 false, label %6, label %7, !dbg !949

6:                                                ; preds = %5
  br label %8, !dbg !949

7:                                                ; preds = %5
  call void asm sideeffect "hcf", ""(), !dbg !949
  br label %8, !dbg !949

8:                                                ; preds = %6, %7
  br label %19, !dbg !949

9:                                                ; preds = %1
  %10 = load i16*, i16** @p_a, align 8, !dbg !949
  br label %19, !dbg !949

11:                                               ; preds = %1
  %12 = load i16*, i16** @p_b, align 8, !dbg !949
  br label %19, !dbg !949

13:                                               ; preds = %1
  %14 = load i16*, i16** @p_c, align 8, !dbg !949
  br label %19, !dbg !949

15:                                               ; preds = %1
  %16 = load i16*, i16** @p_idx, align 8, !dbg !949
  br label %19, !dbg !949

17:                                               ; preds = %1
  %18 = load i16*, i16** @p_k, align 8, !dbg !949
  br label %19, !dbg !949

19:                                               ; preds = %8, %9, %11, %13, %15, %17
  %20 = phi i16 [ -2, %17 ], [ -2, %15 ], [ -2, %13 ], [ -2, %11 ], [ -2, %9 ], [ 0, %8 ]
  %21 = phi i16* [ %18, %17 ], [ %16, %15 ], [ %14, %13 ], [ %12, %11 ], [ %10, %9 ], [ undef, %8 ]
  br label %22, !dbg !949

22:                                               ; preds = %19
  %23 = icmp ne i16 %20, 0, !dbg !949
  br i1 %23, label %24, label %25, !dbg !949

24:                                               ; preds = %22
  br label %27, !dbg !949

25:                                               ; preds = %22
  %26 = load i16*, i16** @p_k, align 8, !dbg !949
  br label %27, !dbg !949

27:                                               ; preds = %24, %25
  %28 = phi i16* [ %26, %25 ], [ %21, %24 ]
  br label %29, !dbg !949

29:                                               ; preds = %27
  ret i16* %28, !dbg !949
}

define internal void @__generic0sys_mod.sys_mod.tile_config.queue_flush.exit() !dbg !951 {
  store volatile i16 1, i16* inttoptr (i16 -2268 to i16*), align 2, !dbg !953
  call void asm sideeffect "nop", ""(), !dbg !953
  call void asm sideeffect "nop", ""(), !dbg !953
  ret void, !dbg !955
}

define internal void @__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position(i16 %0) !dbg !956 {
  %2 = alloca i16, i16 1, align 2, !dbg !958
  %3 = alloca i16, i16 1, align 2, !dbg !960
  %4 = alloca i16, i16 1, align 2, !dbg !961
  store i16 %0, i16* %4, align 2, !dbg !961
  %5 = load i16, i16* %4, align 2, !dbg !962
  store i16 %5, i16* %3, align 2, !dbg !960
  %6 = load i16, i16* %3, align 2, !dbg !963
  %7 = shl i16 %6, 1, !dbg !964
  %8 = inttoptr i16 %7 to i16*, !dbg !964
  call void asm sideeffect "nop", ""(), !dbg !964
  call void asm sideeffect "nop", ""(), !dbg !964
  call void asm sideeffect "nop", ""(), !dbg !964
  call void asm sideeffect "nop", ""(), !dbg !964
  %9 = load volatile i16, i16* %8, align 2, !dbg !964
  store i16 %9, i16* %2, align 2, !dbg !958
  %10 = load i16, i16* %2, align 2, !dbg !965
  %11 = and i16 %10, -16, !dbg !966
  store i16 %11, i16* %2, align 2, !dbg !966
  %12 = load i16, i16* %3, align 2, !dbg !967
  %13 = load i16, i16* %2, align 2, !dbg !968
  %14 = shl i16 %12, 1, !dbg !969
  %15 = inttoptr i16 %14 to i16*, !dbg !969
  store volatile i16 %13, i16* %15, align 2, !dbg !969
  call void asm sideeffect "nop", ""(), !dbg !969
  call void asm sideeffect "nop", ""(), !dbg !969
  call void asm sideeffect "nop", ""(), !dbg !969
  call void asm sideeffect "nop", ""(), !dbg !969
  ret void, !dbg !970
}

define internal void @__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 %0) !dbg !971 {
  %2 = alloca i16, i16 1, align 2, !dbg !973
  %3 = alloca i16, i16 1, align 2, !dbg !975
  %4 = alloca i16, i16 1, align 2, !dbg !976
  store i16 %0, i16* %4, align 2, !dbg !976
  %5 = load i16, i16* %4, align 2, !dbg !977
  store i16 %5, i16* %3, align 2, !dbg !975
  %6 = load i16, i16* %3, align 2, !dbg !978
  %7 = shl i16 %6, 1, !dbg !979
  %8 = inttoptr i16 %7 to i16*, !dbg !979
  call void asm sideeffect "nop", ""(), !dbg !979
  call void asm sideeffect "nop", ""(), !dbg !979
  %9 = load volatile i16, i16* %8, align 2, !dbg !979
  store i16 %9, i16* %2, align 2, !dbg !973
  %10 = load i16, i16* %2, align 2, !dbg !980
  %11 = and i16 %10, -256, !dbg !981
  store i16 %11, i16* %2, align 2, !dbg !982
  %12 = load i16, i16* %2, align 2, !dbg !983
  %13 = load i16, i16* %2, align 2, !dbg !984
  %14 = call i16 @__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %13), !dbg !985
  %15 = or i16 %12, %14, !dbg !986
  store i16 %15, i16* %2, align 2, !dbg !986
  %16 = load i16, i16* %2, align 2, !dbg !987
  %17 = load i16, i16* %2, align 2, !dbg !988
  %18 = call i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %17), !dbg !989
  %19 = or i16 %16, %18, !dbg !990
  store i16 %19, i16* %2, align 2, !dbg !990
  %20 = load i16, i16* %3, align 2, !dbg !991
  %21 = load i16, i16* %2, align 2, !dbg !992
  %22 = shl i16 %20, 1, !dbg !993
  %23 = inttoptr i16 %22 to i16*, !dbg !993
  store volatile i16 %21, i16* %23, align 2, !dbg !993
  call void asm sideeffect "nop", ""(), !dbg !993
  call void asm sideeffect "nop", ""(), !dbg !993
  ret void, !dbg !994
}

define internal void @__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 %0) !dbg !995 {
  %2 = alloca i16, i16 1, align 2, !dbg !996
  %3 = alloca i16, i16 1, align 2, !dbg !998
  %4 = alloca i16, i16 1, align 2, !dbg !999
  store i16 %0, i16* %4, align 2, !dbg !999
  %5 = load i16, i16* %4, align 2, !dbg !1000
  store i16 %5, i16* %3, align 2, !dbg !998
  %6 = load i16, i16* %3, align 2, !dbg !1001
  %7 = shl i16 %6, 1, !dbg !1002
  %8 = inttoptr i16 %7 to i16*, !dbg !1002
  call void asm sideeffect "nop", ""(), !dbg !1002
  call void asm sideeffect "nop", ""(), !dbg !1002
  %9 = load volatile i16, i16* %8, align 2, !dbg !1002
  store i16 %9, i16* %2, align 2, !dbg !996
  %10 = load i16, i16* %2, align 2, !dbg !1003
  %11 = and i16 %10, -256, !dbg !1004
  store i16 %11, i16* %2, align 2, !dbg !1005
  %12 = load i16, i16* %2, align 2, !dbg !1006
  %13 = load i16, i16* %2, align 2, !dbg !1007
  %14 = call i16 @__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %13), !dbg !1008
  %15 = or i16 %12, %14, !dbg !1009
  store i16 %15, i16* %2, align 2, !dbg !1009
  %16 = load i16, i16* %2, align 2, !dbg !1010
  %17 = load i16, i16* %2, align 2, !dbg !1011
  %18 = call i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %17), !dbg !1012
  %19 = or i16 %16, %18, !dbg !1013
  store i16 %19, i16* %2, align 2, !dbg !1013
  %20 = load i16, i16* %3, align 2, !dbg !1014
  %21 = load i16, i16* %2, align 2, !dbg !1015
  %22 = shl i16 %20, 1, !dbg !1016
  %23 = inttoptr i16 %22 to i16*, !dbg !1016
  store volatile i16 %21, i16* %23, align 2, !dbg !1016
  call void asm sideeffect "nop", ""(), !dbg !1016
  call void asm sideeffect "nop", ""(), !dbg !1016
  ret void, !dbg !1017
}

define internal i16 @__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %0) !dbg !1018 {
  %2 = alloca i16, i16 1, align 2, !dbg !1019
  %3 = alloca i16, i16 1, align 2, !dbg !1021
  store i16 %0, i16* %3, align 2, !dbg !1021
  %4 = load i16, i16* %3, align 2, !dbg !1022
  store i16 %4, i16* %2, align 2, !dbg !1019
  %5 = load i16, i16* %2, align 2, !dbg !1023
  store i16 %5, i16* %2, align 2, !dbg !1024
  %6 = load i16, i16* %2, align 2, !dbg !1025
  ret i16 %6, !dbg !1026
}

define internal i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %0) !dbg !1027 {
  %2 = alloca i16, i16 1, align 2, !dbg !1028
  %3 = alloca i16, i16 1, align 2, !dbg !1030
  store i16 %0, i16* %3, align 2, !dbg !1030
  %4 = load i16, i16* %3, align 2, !dbg !1031
  store i16 %4, i16* %2, align 2, !dbg !1028
  %5 = load i16, i16* %2, align 2, !dbg !1032
  %6 = or i16 %5, 2, !dbg !1033
  store i16 %6, i16* %2, align 2, !dbg !1033
  %7 = load i16, i16* %2, align 2, !dbg !1034
  ret i16 %7, !dbg !1035
}

define internal i16 @__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %0) !dbg !1036 {
  %2 = alloca i16, i16 1, align 2, !dbg !1037
  %3 = alloca i16, i16 1, align 2, !dbg !1039
  store i16 %0, i16* %3, align 2, !dbg !1039
  %4 = load i16, i16* %3, align 2, !dbg !1040
  store i16 %4, i16* %2, align 2, !dbg !1037
  %5 = load i16, i16* %2, align 2, !dbg !1041
  %6 = or i16 %5, 128, !dbg !1042
  store i16 %6, i16* %2, align 2, !dbg !1042
  %7 = load i16, i16* %2, align 2, !dbg !1043
  ret i16 %7, !dbg !1044
}

define internal void @__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction(i16 %0) !dbg !1045 {
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
  %11 = and i16 %10, -17, !dbg !1054
  store i16 %11, i16* %2, align 2, !dbg !1054
  %12 = load i16, i16* %3, align 2, !dbg !1055
  %13 = load i16, i16* %2, align 2, !dbg !1056
  %14 = shl i16 %12, 1, !dbg !1057
  %15 = inttoptr i16 %14 to i16*, !dbg !1057
  store volatile i16 %13, i16* %15, align 2, !dbg !1057
  call void asm sideeffect "nop", ""(), !dbg !1057
  call void asm sideeffect "nop", ""(), !dbg !1057
  ret void, !dbg !1058
}

define internal void @__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction(i16 %0) !dbg !1059 {
  %2 = alloca i16, i16 1, align 2, !dbg !1060
  %3 = alloca i16, i16 1, align 2, !dbg !1062
  %4 = alloca i16, i16 1, align 2, !dbg !1063
  store i16 %0, i16* %4, align 2, !dbg !1063
  %5 = load i16, i16* %4, align 2, !dbg !1064
  store i16 %5, i16* %3, align 2, !dbg !1062
  %6 = load i16, i16* %3, align 2, !dbg !1065
  %7 = shl i16 %6, 1, !dbg !1066
  %8 = inttoptr i16 %7 to i16*, !dbg !1066
  call void asm sideeffect "nop", ""(), !dbg !1066
  call void asm sideeffect "nop", ""(), !dbg !1066
  %9 = load volatile i16, i16* %8, align 2, !dbg !1066
  store i16 %9, i16* %2, align 2, !dbg !1060
  %10 = load i16, i16* %2, align 2, !dbg !1067
  %11 = or i16 %10, 16, !dbg !1068
  store i16 %11, i16* %2, align 2, !dbg !1068
  %12 = load i16, i16* %3, align 2, !dbg !1069
  %13 = load i16, i16* %2, align 2, !dbg !1070
  %14 = shl i16 %12, 1, !dbg !1071
  %15 = inttoptr i16 %14 to i16*, !dbg !1071
  store volatile i16 %13, i16* %15, align 2, !dbg !1071
  call void asm sideeffect "nop", ""(), !dbg !1071
  call void asm sideeffect "nop", ""(), !dbg !1071
  ret void, !dbg !1072
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
!4 = !DIFile(filename: "./pe.csl", directory: "/home/USER/xkernel/studies/wse3-characterization/microbench/addfam/cases/W_const_in_loop")
!5 = !DISubroutineType(types: !6)
!6 = !{}
!7 = !DILocation(line: 16, column: 3, scope: !8)
!8 = !DILexicalBlockFile(scope: !3, file: !4, discriminator: 0)
!9 = !DILocation(line: 16, column: 25, scope: !8)
!10 = !DILocation(line: 16, column: 8, scope: !8)
!11 = !DILocation(line: 16, column: 38, scope: !8)
!12 = !DILocation(line: 16, column: 42, scope: !8)
!13 = !DILocation(line: 16, column: 32, scope: !8)
!14 = !DILocation(line: 16, column: 31, scope: !8)
!15 = !DILocation(line: 16, column: 35, scope: !8)
!16 = !DILocation(line: 17, column: 3, scope: !8)
!17 = distinct !DISubprogram(name: "f_exit", linkageName: "f_exit", scope: null, file: !4, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!18 = !DILocation(line: 20, column: 22, scope: !19)
!19 = !DILexicalBlockFile(scope: !17, file: !4, discriminator: 0)
!20 = !DILocation(line: 20, column: 1, scope: !19)
!21 = distinct !DISubprogram(name: "sys_mod.sys_nop", linkageName: "sys_mod.sys_nop", scope: null, file: !22, line: 90, type: !5, scopeLine: 90, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!22 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/memcpy.csl", directory: "")
!23 = !DILocation(line: 90, column: 1, scope: !24)
!24 = !DILexicalBlockFile(scope: !21, file: !22, discriminator: 0)
!25 = distinct !DISubprogram(name: "sys_mod.unblock_cmd_stream", linkageName: "sys_mod.unblock_cmd_stream", scope: null, file: !22, line: 102, type: !5, scopeLine: 102, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!26 = !DILocation(line: 103, column: 3, scope: !27)
!27 = !DILexicalBlockFile(scope: !25, file: !22, discriminator: 0)
!28 = !DILocation(line: 102, column: 1, scope: !27)
!29 = distinct !DISubprogram(name: "sys_mod.sys_mod.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.unblock_cmd_stream", scope: null, file: !30, line: 307, type: !5, scopeLine: 307, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!30 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpy.csl", directory: "")
!31 = !DILocation(line: 308, column: 5, scope: !32)
!32 = !DILexicalBlockFile(scope: !29, file: !30, discriminator: 0)
!33 = !DILocation(line: 307, column: 1, scope: !32)
!34 = distinct !DISubprogram(name: "sys_mod.sys_mod.teardown_h2d", linkageName: "sys_mod.sys_mod.teardown_h2d", scope: null, file: !30, line: 323, type: !5, scopeLine: 323, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!35 = !DILocation(line: 326, column: 5, scope: !36)
!36 = !DILexicalBlockFile(scope: !34, file: !30, discriminator: 0)
!37 = !DILocation(line: 323, column: 1, scope: !36)
!38 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_ublk_c22", linkageName: "sys_mod.sys_mod.f_ublk_c22", scope: null, file: !30, line: 335, type: !5, scopeLine: 335, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!39 = !DILocation(line: 336, column: 5, scope: !40)
!40 = !DILexicalBlockFile(scope: !38, file: !30, discriminator: 0)
!41 = !DILocation(line: 335, column: 1, scope: !40)
!42 = distinct !DISubprogram(name: "sys_mod.sys_mod.teardown_d2h", linkageName: "sys_mod.sys_mod.teardown_d2h", scope: null, file: !30, line: 344, type: !5, scopeLine: 344, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!43 = !DILocation(line: 355, column: 5, scope: !44)
!44 = !DILexicalBlockFile(scope: !42, file: !30, discriminator: 0)
!45 = !DILocation(line: 359, column: 5, scope: !44)
!46 = !DILocation(line: 344, column: 1, scope: !44)
!47 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_memcpyh2d", linkageName: "sys_mod.sys_mod.f_memcpyh2d", scope: null, file: !30, line: 460, type: !5, scopeLine: 460, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!48 = !DILocation(line: 477, column: 5, scope: !49)
!49 = !DILexicalBlockFile(scope: !47, file: !30, discriminator: 0)
!50 = !DILocation(line: 476, column: 5, scope: !49)
!51 = !DILocation(line: 475, column: 5, scope: !49)
!52 = !DILocation(line: 474, column: 5, scope: !49)
!53 = !DILocation(line: 473, column: 5, scope: !49)
!54 = !DILocation(line: 472, column: 5, scope: !49)
!55 = !DILocation(line: 471, column: 5, scope: !49)
!56 = !DILocation(line: 470, column: 5, scope: !49)
!57 = !DILocation(line: 469, column: 5, scope: !49)
!58 = !DILocation(line: 468, column: 5, scope: !49)
!59 = !DILocation(line: 467, column: 5, scope: !49)
!60 = !DILocation(line: 466, column: 5, scope: !49)
!61 = !DILocation(line: 465, column: 5, scope: !49)
!62 = !DILocation(line: 463, column: 5, scope: !49)
!63 = !DILocation(line: 462, column: 20, scope: !49)
!64 = !DILocation(line: 462, column: 32, scope: !49)
!65 = !DILocation(line: 462, column: 5, scope: !49)
!66 = !DILocation(line: 465, column: 33, scope: !49)
!67 = !DILocation(line: 465, column: 38, scope: !49)
!68 = !DILocation(line: 466, column: 34, scope: !49)
!69 = !DILocation(line: 466, column: 39, scope: !49)
!70 = !DILocation(line: 467, column: 34, scope: !49)
!71 = !DILocation(line: 467, column: 39, scope: !49)
!72 = !DILocation(line: 468, column: 33, scope: !49)
!73 = !DILocation(line: 468, column: 38, scope: !49)
!74 = !DILocation(line: 469, column: 33, scope: !49)
!75 = !DILocation(line: 469, column: 38, scope: !49)
!76 = !DILocation(line: 470, column: 35, scope: !49)
!77 = !DILocation(line: 470, column: 21, scope: !49)
!78 = !DILocation(line: 471, column: 41, scope: !49)
!79 = !DILocation(line: 471, column: 27, scope: !49)
!80 = !DILocation(line: 472, column: 39, scope: !49)
!81 = !DILocation(line: 472, column: 25, scope: !49)
!82 = !DILocation(line: 473, column: 44, scope: !49)
!83 = !DILocation(line: 473, column: 49, scope: !49)
!84 = !DILocation(line: 474, column: 41, scope: !49)
!85 = !DILocation(line: 474, column: 46, scope: !49)
!86 = !DILocation(line: 475, column: 41, scope: !49)
!87 = !DILocation(line: 475, column: 46, scope: !49)
!88 = !DILocation(line: 476, column: 59, scope: !49)
!89 = !DILocation(line: 476, column: 64, scope: !49)
!90 = !DILocation(line: 476, column: 50, scope: !49)
!91 = !DILocation(line: 476, column: 129, scope: !49)
!92 = !DILocation(line: 476, column: 134, scope: !49)
!93 = !DILocation(line: 476, column: 120, scope: !49)
!94 = !DILocation(line: 476, column: 118, scope: !49)
!95 = !DILocation(line: 476, column: 112, scope: !49)
!96 = !DILocation(line: 476, column: 36, scope: !49)
!97 = !DILocation(line: 477, column: 59, scope: !49)
!98 = !DILocation(line: 477, column: 64, scope: !49)
!99 = !DILocation(line: 477, column: 50, scope: !49)
!100 = !DILocation(line: 477, column: 129, scope: !49)
!101 = !DILocation(line: 477, column: 134, scope: !49)
!102 = !DILocation(line: 477, column: 120, scope: !49)
!103 = !DILocation(line: 477, column: 118, scope: !49)
!104 = !DILocation(line: 477, column: 112, scope: !49)
!105 = !DILocation(line: 477, column: 36, scope: !49)
!106 = !DILocation(line: 479, column: 24, scope: !49)
!107 = !DILocation(line: 481, column: 21, scope: !49)
!108 = !DILocation(line: 481, column: 19, scope: !49)
!109 = !DILocation(line: 482, column: 21, scope: !49)
!110 = !DILocation(line: 482, column: 19, scope: !49)
!111 = !DILocation(line: 483, column: 21, scope: !49)
!112 = !DILocation(line: 483, column: 19, scope: !49)
!113 = !DILocation(line: 484, column: 20, scope: !49)
!114 = !DILocation(line: 484, column: 18, scope: !49)
!115 = !DILocation(line: 485, column: 20, scope: !49)
!116 = !DILocation(line: 485, column: 18, scope: !49)
!117 = !DILocation(line: 486, column: 22, scope: !49)
!118 = !DILocation(line: 486, column: 20, scope: !49)
!119 = !DILocation(line: 487, column: 27, scope: !49)
!120 = !DILocation(line: 487, column: 25, scope: !49)
!121 = !DILocation(line: 488, column: 25, scope: !49)
!122 = !DILocation(line: 488, column: 23, scope: !49)
!123 = !DILocation(line: 489, column: 31, scope: !49)
!124 = !DILocation(line: 489, column: 29, scope: !49)
!125 = !DILocation(line: 490, column: 28, scope: !49)
!126 = !DILocation(line: 490, column: 26, scope: !49)
!127 = !DILocation(line: 491, column: 28, scope: !49)
!128 = !DILocation(line: 491, column: 26, scope: !49)
!129 = !DILocation(line: 492, column: 37, scope: !49)
!130 = !DILocation(line: 492, column: 35, scope: !49)
!131 = !DILocation(line: 493, column: 37, scope: !49)
!132 = !DILocation(line: 493, column: 35, scope: !49)
!133 = !DILocation(line: 495, column: 5, scope: !49)
!134 = !DILocation(line: 501, column: 5, scope: !49)
!135 = !DILocation(line: 506, column: 5, scope: !49)
!136 = !DILocation(line: 521, column: 5, scope: !49)
!137 = !DILocation(line: 522, column: 16, scope: !49)
!138 = !DILocation(line: 531, column: 5, scope: !49)
!139 = !DILocation(line: 460, column: 1, scope: !49)
!140 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_memcpyd2h", linkageName: "sys_mod.sys_mod.f_memcpyd2h", scope: null, file: !30, line: 556, type: !5, scopeLine: 556, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!141 = !DILocation(line: 568, column: 5, scope: !142)
!142 = !DILexicalBlockFile(scope: !140, file: !30, discriminator: 0)
!143 = !DILocation(line: 567, column: 5, scope: !142)
!144 = !DILocation(line: 566, column: 5, scope: !142)
!145 = !DILocation(line: 565, column: 5, scope: !142)
!146 = !DILocation(line: 564, column: 5, scope: !142)
!147 = !DILocation(line: 563, column: 5, scope: !142)
!148 = !DILocation(line: 562, column: 5, scope: !142)
!149 = !DILocation(line: 561, column: 5, scope: !142)
!150 = !DILocation(line: 559, column: 5, scope: !142)
!151 = !DILocation(line: 558, column: 20, scope: !142)
!152 = !DILocation(line: 558, column: 32, scope: !142)
!153 = !DILocation(line: 558, column: 5, scope: !142)
!154 = !DILocation(line: 561, column: 33, scope: !142)
!155 = !DILocation(line: 561, column: 38, scope: !142)
!156 = !DILocation(line: 562, column: 34, scope: !142)
!157 = !DILocation(line: 562, column: 39, scope: !142)
!158 = !DILocation(line: 563, column: 34, scope: !142)
!159 = !DILocation(line: 563, column: 39, scope: !142)
!160 = !DILocation(line: 564, column: 33, scope: !142)
!161 = !DILocation(line: 564, column: 38, scope: !142)
!162 = !DILocation(line: 565, column: 33, scope: !142)
!163 = !DILocation(line: 565, column: 38, scope: !142)
!164 = !DILocation(line: 566, column: 35, scope: !142)
!165 = !DILocation(line: 566, column: 21, scope: !142)
!166 = !DILocation(line: 567, column: 41, scope: !142)
!167 = !DILocation(line: 567, column: 27, scope: !142)
!168 = !DILocation(line: 568, column: 39, scope: !142)
!169 = !DILocation(line: 568, column: 25, scope: !142)
!170 = !DILocation(line: 570, column: 24, scope: !142)
!171 = !DILocation(line: 573, column: 21, scope: !142)
!172 = !DILocation(line: 573, column: 19, scope: !142)
!173 = !DILocation(line: 574, column: 21, scope: !142)
!174 = !DILocation(line: 574, column: 19, scope: !142)
!175 = !DILocation(line: 575, column: 21, scope: !142)
!176 = !DILocation(line: 575, column: 19, scope: !142)
!177 = !DILocation(line: 576, column: 20, scope: !142)
!178 = !DILocation(line: 576, column: 18, scope: !142)
!179 = !DILocation(line: 577, column: 20, scope: !142)
!180 = !DILocation(line: 577, column: 18, scope: !142)
!181 = !DILocation(line: 578, column: 22, scope: !142)
!182 = !DILocation(line: 578, column: 20, scope: !142)
!183 = !DILocation(line: 579, column: 27, scope: !142)
!184 = !DILocation(line: 579, column: 25, scope: !142)
!185 = !DILocation(line: 580, column: 25, scope: !142)
!186 = !DILocation(line: 580, column: 23, scope: !142)
!187 = !DILocation(line: 582, column: 5, scope: !142)
!188 = !DILocation(line: 588, column: 59, scope: !142)
!189 = !DILocation(line: 588, column: 5, scope: !142)
!190 = !DILocation(line: 608, column: 5, scope: !142)
!191 = !DILocation(line: 609, column: 16, scope: !142)
!192 = !DILocation(line: 556, column: 1, scope: !142)
!193 = distinct !DISubprogram(name: "sys_mod.sys_mod.oq0_teardow_handler", linkageName: "sys_mod.sys_mod.oq0_teardow_handler", scope: null, file: !30, line: 631, type: !5, scopeLine: 631, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!194 = !DILocation(line: 632, column: 9, scope: !195)
!195 = !DILexicalBlockFile(scope: !193, file: !30, discriminator: 0)
!196 = !DILocation(line: 632, column: 5, scope: !195)
!197 = !DILocation(line: 634, column: 66, scope: !195)
!198 = !DILocation(line: 634, column: 9, scope: !195)
!199 = !DILocation(line: 636, column: 13, scope: !195)
!200 = !DILocation(line: 637, column: 13, scope: !195)
!201 = !DILocation(line: 638, column: 13, scope: !195)
!202 = !DILocation(line: 639, column: 13, scope: !195)
!203 = !DILocation(line: 640, column: 13, scope: !195)
!204 = !DILocation(line: 641, column: 13, scope: !195)
!205 = !DILocation(line: 642, column: 13, scope: !195)
!206 = !DILocation(line: 643, column: 13, scope: !195)
!207 = !DILocation(line: 644, column: 13, scope: !195)
!208 = !DILocation(line: 645, column: 13, scope: !195)
!209 = !DILocation(line: 646, column: 13, scope: !195)
!210 = !DILocation(line: 647, column: 13, scope: !195)
!211 = !DILocation(line: 648, column: 13, scope: !195)
!212 = !DILocation(line: 635, column: 9, scope: !195)
!213 = !DILocation(line: 652, column: 9, scope: !195)
!214 = !DILocation(line: 654, column: 13, scope: !195)
!215 = !DILocation(line: 655, column: 13, scope: !195)
!216 = !DILocation(line: 656, column: 13, scope: !195)
!217 = !DILocation(line: 657, column: 13, scope: !195)
!218 = !DILocation(line: 658, column: 13, scope: !195)
!219 = !DILocation(line: 659, column: 13, scope: !195)
!220 = !DILocation(line: 660, column: 13, scope: !195)
!221 = !DILocation(line: 661, column: 13, scope: !195)
!222 = !DILocation(line: 653, column: 9, scope: !195)
!223 = !DILocation(line: 664, column: 5, scope: !195)
!224 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_rpc", linkageName: "sys_mod.sys_mod.f_rpc", scope: null, file: !30, line: 694, type: !5, scopeLine: 694, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!225 = !DILocation(line: 694, column: 13, scope: !226)
!226 = !DILexicalBlockFile(scope: !224, file: !30, discriminator: 0)
!227 = !DILocation(line: 700, column: 5, scope: !226)
!228 = !DILocation(line: 706, column: 20, scope: !226)
!229 = !DILocation(line: 706, column: 32, scope: !226)
!230 = !DILocation(line: 706, column: 5, scope: !226)
!231 = !DILocation(line: 710, column: 5, scope: !226)
!232 = !DILocation(line: 712, column: 24, scope: !226)
!233 = !DILocation(line: 694, column: 1, scope: !226)
!234 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.stack_push", linkageName: "sys_mod.sys_mod.sys_mod.stack_push", scope: null, file: !235, line: 54, type: !5, scopeLine: 54, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!235 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/sys.csl", directory: "")
!236 = !DILocation(line: 60, column: 5, scope: !237)
!237 = !DILexicalBlockFile(scope: !234, file: !235, discriminator: 0)
!238 = !DILocation(line: 54, column: 16, scope: !237)
!239 = !DILocation(line: 59, column: 13, scope: !237)
!240 = !DILocation(line: 59, column: 24, scope: !237)
!241 = !DILocation(line: 59, column: 5, scope: !237)
!242 = !DILocation(line: 61, column: 25, scope: !237)
!243 = !DILocation(line: 61, column: 5, scope: !237)
!244 = !DILocation(line: 61, column: 11, scope: !237)
!245 = !DILocation(line: 61, column: 10, scope: !237)
!246 = !DILocation(line: 61, column: 23, scope: !237)
!247 = !DILocation(line: 62, column: 18, scope: !237)
!248 = !DILocation(line: 62, column: 29, scope: !237)
!249 = !DILocation(line: 62, column: 16, scope: !237)
!250 = !DILocation(line: 54, column: 1, scope: !237)
!251 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_push", linkageName: "sys_mod.sys_mod.sys_mod.f_push", scope: null, file: !235, line: 72, type: !5, scopeLine: 72, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!252 = !DILocation(line: 72, column: 25, scope: !253)
!253 = !DILexicalBlockFile(scope: !251, file: !235, discriminator: 0)
!254 = !DILocation(line: 72, column: 13, scope: !253)
!255 = !DILocation(line: 73, column: 16, scope: !253)
!256 = !DILocation(line: 73, column: 5, scope: !253)
!257 = !DILocation(line: 72, column: 1, scope: !253)
!258 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.block_cmd_stream", linkageName: "sys_mod.sys_mod.sys_mod.block_cmd_stream", scope: null, file: !235, line: 76, type: !5, scopeLine: 76, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!259 = !DILocation(line: 77, column: 5, scope: !260)
!260 = !DILexicalBlockFile(scope: !258, file: !235, discriminator: 0)
!261 = !DILocation(line: 76, column: 1, scope: !260)
!262 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.sys_mod.unblock_cmd_stream", scope: null, file: !235, line: 80, type: !5, scopeLine: 80, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!263 = !DILocation(line: 81, column: 5, scope: !264)
!264 = !DILexicalBlockFile(scope: !262, file: !235, discriminator: 0)
!265 = !DILocation(line: 80, column: 1, scope: !264)
!266 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_sys_exit", linkageName: "sys_mod.sys_mod.sys_mod.f_sys_exit", scope: null, file: !235, line: 85, type: !5, scopeLine: 85, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!267 = !DILocation(line: 86, column: 5, scope: !268)
!268 = !DILexicalBlockFile(scope: !266, file: !235, discriminator: 0)
!269 = !DILocation(line: 87, column: 5, scope: !268)
!270 = !DILocation(line: 85, column: 1, scope: !268)
!271 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore", linkageName: "sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore", scope: null, file: !235, line: 90, type: !5, scopeLine: 90, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!272 = !DILocation(line: 90, column: 30, scope: !273)
!273 = !DILexicalBlockFile(scope: !271, file: !235, discriminator: 0)
!274 = !DILocation(line: 90, column: 1, scope: !273)
!275 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord", scope: null, file: !276, line: 131, type: !5, scopeLine: 131, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!276 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpyh2d.csl", directory: "")
!277 = !DILocation(line: 132, column: 12, scope: !278)
!278 = !DILexicalBlockFile(scope: !275, file: !276, discriminator: 0)
!279 = !DILocation(line: 132, column: 5, scope: !278)
!280 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord", scope: null, file: !276, line: 134, type: !5, scopeLine: 134, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!281 = !DILocation(line: 135, column: 12, scope: !282)
!282 = !DILexicalBlockFile(scope: !280, file: !276, discriminator: 0)
!283 = !DILocation(line: 135, column: 5, scope: !282)
!284 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval", scope: null, file: !276, line: 148, type: !5, scopeLine: 148, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!285 = !DILocation(line: 148, column: 23, scope: !286)
!286 = !DILexicalBlockFile(scope: !284, file: !276, discriminator: 0)
!287 = !DILocation(line: 149, column: 9, scope: !286)
!288 = !DILocation(line: 149, column: 20, scope: !286)
!289 = !DILocation(line: 149, column: 5, scope: !286)
!290 = !DILocation(line: 152, column: 23, scope: !286)
!291 = !DILocation(line: 152, column: 20, scope: !286)
!292 = !DILocation(line: 152, column: 9, scope: !286)
!293 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start", scope: null, file: !276, line: 226, type: !5, scopeLine: 226, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!294 = !DILocation(line: 233, column: 5, scope: !295)
!295 = !DILexicalBlockFile(scope: !293, file: !276, discriminator: 0)
!296 = !DILocation(line: 226, column: 49, scope: !295)
!297 = !DILocation(line: 226, column: 32, scope: !295)
!298 = !DILocation(line: 226, column: 21, scope: !295)
!299 = !DILocation(line: 229, column: 37, scope: !295)
!300 = !DILocation(line: 229, column: 52, scope: !295)
!301 = !DILocation(line: 229, column: 19, scope: !295)
!302 = !DILocation(line: 233, column: 71, scope: !295)
!303 = !DILocation(line: 233, column: 55, scope: !295)
!304 = !DILocation(line: 233, column: 25, scope: !295)
!305 = !DILocation(line: 235, column: 37, scope: !295)
!306 = !DILocation(line: 235, column: 52, scope: !295)
!307 = !DILocation(line: 235, column: 19, scope: !295)
!308 = !DILocation(line: 236, column: 28, scope: !295)
!309 = !DILocation(line: 236, column: 5, scope: !295)
!310 = !DILocation(line: 237, column: 28, scope: !295)
!311 = !DILocation(line: 237, column: 5, scope: !295)
!312 = !DILocation(line: 238, column: 13, scope: !295)
!313 = !DILocation(line: 238, column: 11, scope: !295)
!314 = !DILocation(line: 238, column: 5, scope: !295)
!315 = !DILocation(line: 239, column: 9, scope: !295)
!316 = !DILocation(line: 241, column: 9, scope: !295)
!317 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream", scope: null, file: !276, line: 249, type: !5, scopeLine: 249, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!318 = !DILocation(line: 250, column: 5, scope: !319)
!319 = !DILexicalBlockFile(scope: !317, file: !276, discriminator: 0)
!320 = !DILocation(line: 249, column: 1, scope: !319)
!321 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure", scope: null, file: !276, line: 276, type: !5, scopeLine: 276, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!322 = !DILocation(line: 414, column: 13, scope: !323)
!323 = !DILexicalBlockFile(scope: !321, file: !276, discriminator: 0)
!324 = !DILocation(line: 413, column: 13, scope: !323)
!325 = !DILocation(line: 400, column: 17, scope: !323)
!326 = !DILocation(line: 340, column: 9, scope: !323)
!327 = !DILocation(line: 339, column: 9, scope: !323)
!328 = !DILocation(line: 337, column: 5, scope: !323)
!329 = !DILocation(line: 319, column: 9, scope: !323)
!330 = !DILocation(line: 318, column: 9, scope: !323)
!331 = !DILocation(line: 315, column: 5, scope: !323)
!332 = !DILocation(line: 292, column: 5, scope: !323)
!333 = !DILocation(line: 291, column: 5, scope: !323)
!334 = !DILocation(line: 289, column: 5, scope: !323)
!335 = !DILocation(line: 288, column: 5, scope: !323)
!336 = !DILocation(line: 287, column: 5, scope: !323)
!337 = !DILocation(line: 286, column: 5, scope: !323)
!338 = !DILocation(line: 285, column: 5, scope: !323)
!339 = !DILocation(line: 284, column: 5, scope: !323)
!340 = !DILocation(line: 283, column: 5, scope: !323)
!341 = !DILocation(line: 282, column: 5, scope: !323)
!342 = !DILocation(line: 281, column: 5, scope: !323)
!343 = !DILocation(line: 280, column: 5, scope: !323)
!344 = !DILocation(line: 279, column: 5, scope: !323)
!345 = !DILocation(line: 278, column: 5, scope: !323)
!346 = !DILocation(line: 277, column: 5, scope: !323)
!347 = !DILocation(line: 291, column: 26, scope: !323)
!348 = !DILocation(line: 292, column: 26, scope: !323)
!349 = !DILocation(line: 315, column: 25, scope: !323)
!350 = !DILocation(line: 315, column: 31, scope: !323)
!351 = !DILocation(line: 315, column: 29, scope: !323)
!352 = !DILocation(line: 316, column: 20, scope: !323)
!353 = !DILocation(line: 316, column: 18, scope: !323)
!354 = !DILocation(line: 317, column: 52, scope: !323)
!355 = !DILocation(line: 317, column: 49, scope: !323)
!356 = !DILocation(line: 317, column: 5, scope: !323)
!357 = !DILocation(line: 318, column: 42, scope: !323)
!358 = !DILocation(line: 318, column: 33, scope: !323)
!359 = !DILocation(line: 318, column: 49, scope: !323)
!360 = !DILocation(line: 318, column: 48, scope: !323)
!361 = !DILocation(line: 318, column: 24, scope: !323)
!362 = !DILocation(line: 319, column: 24, scope: !323)
!363 = !DILocation(line: 319, column: 32, scope: !323)
!364 = !DILocation(line: 319, column: 36, scope: !323)
!365 = !DILocation(line: 319, column: 34, scope: !323)
!366 = !DILocation(line: 319, column: 30, scope: !323)
!367 = !DILocation(line: 320, column: 18, scope: !323)
!368 = !DILocation(line: 320, column: 15, scope: !323)
!369 = !DILocation(line: 320, column: 9, scope: !323)
!370 = !DILocation(line: 321, column: 26, scope: !323)
!371 = !DILocation(line: 325, column: 28, scope: !323)
!372 = !DILocation(line: 325, column: 26, scope: !323)
!373 = !DILocation(line: 331, column: 9, scope: !323)
!374 = !DILocation(line: 331, column: 15, scope: !323)
!375 = !DILocation(line: 331, column: 5, scope: !323)
!376 = !DILocation(line: 332, column: 22, scope: !323)
!377 = !DILocation(line: 334, column: 9, scope: !323)
!378 = !DILocation(line: 334, column: 18, scope: !323)
!379 = !DILocation(line: 334, column: 15, scope: !323)
!380 = !DILocation(line: 334, column: 5, scope: !323)
!381 = !DILocation(line: 335, column: 22, scope: !323)
!382 = !DILocation(line: 338, column: 52, scope: !323)
!383 = !DILocation(line: 338, column: 49, scope: !323)
!384 = !DILocation(line: 338, column: 5, scope: !323)
!385 = !DILocation(line: 339, column: 42, scope: !323)
!386 = !DILocation(line: 339, column: 48, scope: !323)
!387 = !DILocation(line: 339, column: 46, scope: !323)
!388 = !DILocation(line: 339, column: 33, scope: !323)
!389 = !DILocation(line: 339, column: 52, scope: !323)
!390 = !DILocation(line: 339, column: 51, scope: !323)
!391 = !DILocation(line: 339, column: 24, scope: !323)
!392 = !DILocation(line: 340, column: 25, scope: !323)
!393 = !DILocation(line: 340, column: 31, scope: !323)
!394 = !DILocation(line: 340, column: 29, scope: !323)
!395 = !DILocation(line: 340, column: 37, scope: !323)
!396 = !DILocation(line: 340, column: 41, scope: !323)
!397 = !DILocation(line: 340, column: 39, scope: !323)
!398 = !DILocation(line: 340, column: 35, scope: !323)
!399 = !DILocation(line: 341, column: 18, scope: !323)
!400 = !DILocation(line: 341, column: 15, scope: !323)
!401 = !DILocation(line: 341, column: 9, scope: !323)
!402 = !DILocation(line: 342, column: 26, scope: !323)
!403 = !DILocation(line: 347, column: 10, scope: !323)
!404 = !DILocation(line: 347, column: 16, scope: !323)
!405 = !DILocation(line: 347, column: 14, scope: !323)
!406 = !DILocation(line: 347, column: 5, scope: !323)
!407 = !DILocation(line: 348, column: 22, scope: !323)
!408 = !DILocation(line: 350, column: 10, scope: !323)
!409 = !DILocation(line: 350, column: 18, scope: !323)
!410 = !DILocation(line: 350, column: 21, scope: !323)
!411 = !DILocation(line: 350, column: 20, scope: !323)
!412 = !DILocation(line: 350, column: 14, scope: !323)
!413 = !DILocation(line: 350, column: 5, scope: !323)
!414 = !DILocation(line: 351, column: 22, scope: !323)
!415 = !DILocation(line: 354, column: 9, scope: !323)
!416 = !DILocation(line: 354, column: 5, scope: !323)
!417 = !DILocation(line: 358, column: 9, scope: !323)
!418 = !DILocation(line: 361, column: 9, scope: !323)
!419 = !DILocation(line: 364, column: 20, scope: !323)
!420 = !DILocation(line: 364, column: 17, scope: !323)
!421 = !DILocation(line: 364, column: 9, scope: !323)
!422 = !DILocation(line: 368, column: 13, scope: !323)
!423 = !DILocation(line: 371, column: 13, scope: !323)
!424 = !DILocation(line: 375, column: 13, scope: !323)
!425 = !DILocation(line: 394, column: 13, scope: !323)
!426 = !DILocation(line: 396, column: 29, scope: !323)
!427 = !DILocation(line: 396, column: 27, scope: !323)
!428 = !DILocation(line: 397, column: 60, scope: !323)
!429 = !DILocation(line: 397, column: 57, scope: !323)
!430 = !DILocation(line: 397, column: 13, scope: !323)
!431 = !DILocation(line: 400, column: 54, scope: !323)
!432 = !DILocation(line: 400, column: 55, scope: !323)
!433 = !DILocation(line: 400, column: 46, scope: !323)
!434 = !DILocation(line: 400, column: 59, scope: !323)
!435 = !DILocation(line: 400, column: 58, scope: !323)
!436 = !DILocation(line: 400, column: 37, scope: !323)
!437 = !DILocation(line: 400, column: 35, scope: !323)
!438 = !DILocation(line: 401, column: 33, scope: !323)
!439 = !DILocation(line: 401, column: 31, scope: !323)
!440 = !DILocation(line: 402, column: 69, scope: !323)
!441 = !DILocation(line: 402, column: 66, scope: !323)
!442 = !DILocation(line: 402, column: 19, scope: !323)
!443 = !DILocation(line: 404, column: 31, scope: !323)
!444 = !DILocation(line: 408, column: 75, scope: !323)
!445 = !DILocation(line: 408, column: 88, scope: !323)
!446 = !DILocation(line: 408, column: 13, scope: !323)
!447 = !DILocation(line: 413, column: 31, scope: !323)
!448 = !DILocation(line: 414, column: 33, scope: !323)
!449 = !DILocation(line: 415, column: 21, scope: !323)
!450 = !DILocation(line: 415, column: 29, scope: !323)
!451 = !DILocation(line: 415, column: 27, scope: !323)
!452 = !DILocation(line: 415, column: 19, scope: !323)
!453 = !DILocation(line: 416, column: 22, scope: !323)
!454 = !DILocation(line: 416, column: 19, scope: !323)
!455 = !DILocation(line: 416, column: 13, scope: !323)
!456 = !DILocation(line: 417, column: 23, scope: !323)
!457 = !DILocation(line: 419, column: 63, scope: !323)
!458 = !DILocation(line: 419, column: 60, scope: !323)
!459 = !DILocation(line: 419, column: 13, scope: !323)
!460 = !DILocation(line: 421, column: 23, scope: !323)
!461 = !DILocation(line: 423, column: 69, scope: !323)
!462 = !DILocation(line: 423, column: 13, scope: !323)
!463 = !DILocation(line: 426, column: 13, scope: !323)
!464 = !DILocation(line: 430, column: 13, scope: !323)
!465 = !DILocation(line: 433, column: 48, scope: !323)
!466 = !DILocation(line: 433, column: 22, scope: !323)
!467 = !DILocation(line: 433, column: 19, scope: !323)
!468 = !DILocation(line: 433, column: 13, scope: !323)
!469 = !DILocation(line: 436, column: 34, scope: !323)
!470 = !DILocation(line: 436, column: 39, scope: !323)
!471 = !DILocation(line: 436, column: 50, scope: !323)
!472 = !DILocation(line: 436, column: 17, scope: !323)
!473 = !DILocation(line: 452, column: 49, scope: !323)
!474 = !DILocation(line: 452, column: 64, scope: !323)
!475 = !DILocation(line: 452, column: 31, scope: !323)
!476 = !DILocation(line: 453, column: 40, scope: !323)
!477 = !DILocation(line: 453, column: 17, scope: !323)
!478 = !DILocation(line: 454, column: 50, scope: !323)
!479 = !DILocation(line: 454, column: 66, scope: !323)
!480 = !DILocation(line: 454, column: 32, scope: !323)
!481 = !DILocation(line: 455, column: 40, scope: !323)
!482 = !DILocation(line: 455, column: 17, scope: !323)
!483 = !DILocation(line: 456, column: 17, scope: !323)
!484 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit", scope: null, file: !485, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!485 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/filters/wse3.csl", directory: "")
!486 = !DILocation(line: 24, column: 3, scope: !487)
!487 = !DILexicalBlockFile(scope: !484, file: !485, discriminator: 0)
!488 = !DILocation(line: 24, column: 22, scope: !487)
!489 = !DILocation(line: 23, column: 3, scope: !487)
!490 = !DILocation(line: 22, column: 3, scope: !487)
!491 = !DILocation(line: 20, column: 37, scope: !487)
!492 = !DILocation(line: 20, column: 21, scope: !487)
!493 = !DILocation(line: 21, column: 11, scope: !487)
!494 = !DILocation(line: 21, column: 17, scope: !487)
!495 = !DILocation(line: 21, column: 3, scope: !487)
!496 = !DILocation(line: 22, column: 24, scope: !487)
!497 = !DILocation(line: 22, column: 30, scope: !487)
!498 = !DILocation(line: 23, column: 40, scope: !487)
!499 = !DILocation(line: 23, column: 22, scope: !487)
!500 = !DILocation(line: 23, column: 67, scope: !487)
!501 = !DILocation(line: 24, column: 26, scope: !487)
!502 = !DILocation(line: 24, column: 41, scope: !487)
!503 = !DILocation(line: 24, column: 39, scope: !487)
!504 = !DILocation(line: 24, column: 61, scope: !487)
!505 = !DILocation(line: 24, column: 76, scope: !487)
!506 = !DILocation(line: 24, column: 74, scope: !487)
!507 = !DILocation(line: 25, column: 21, scope: !487)
!508 = !DILocation(line: 25, column: 50, scope: !487)
!509 = !DILocation(line: 25, column: 3, scope: !487)
!510 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter", scope: null, file: !485, line: 30, type: !5, scopeLine: 30, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!511 = !DILocation(line: 30, column: 36, scope: !512)
!512 = !DILexicalBlockFile(scope: !510, file: !485, discriminator: 0)
!513 = !DILocation(line: 30, column: 20, scope: !512)
!514 = !DILocation(line: 31, column: 11, scope: !512)
!515 = !DILocation(line: 31, column: 23, scope: !512)
!516 = !DILocation(line: 31, column: 3, scope: !512)
!517 = !DILocation(line: 32, column: 21, scope: !512)
!518 = !DILocation(line: 32, column: 48, scope: !512)
!519 = !DILocation(line: 32, column: 60, scope: !512)
!520 = !DILocation(line: 32, column: 64, scope: !512)
!521 = !DILocation(line: 32, column: 3, scope: !512)
!522 = !DILocation(line: 30, column: 1, scope: !512)
!523 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter", scope: null, file: !485, line: 40, type: !5, scopeLine: 40, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!524 = !DILocation(line: 47, column: 3, scope: !525)
!525 = !DILexicalBlockFile(scope: !523, file: !485, discriminator: 0)
!526 = !DILocation(line: 48, column: 7, scope: !525)
!527 = !DILocation(line: 44, column: 3, scope: !525)
!528 = !DILocation(line: 43, column: 3, scope: !525)
!529 = !DILocation(line: 42, column: 3, scope: !525)
!530 = !DILocation(line: 40, column: 32, scope: !525)
!531 = !DILocation(line: 40, column: 16, scope: !525)
!532 = !DILocation(line: 41, column: 11, scope: !525)
!533 = !DILocation(line: 41, column: 19, scope: !525)
!534 = !DILocation(line: 41, column: 3, scope: !525)
!535 = !DILocation(line: 42, column: 40, scope: !525)
!536 = !DILocation(line: 42, column: 22, scope: !525)
!537 = !DILocation(line: 43, column: 26, scope: !525)
!538 = !DILocation(line: 43, column: 34, scope: !525)
!539 = !DILocation(line: 44, column: 25, scope: !525)
!540 = !DILocation(line: 44, column: 42, scope: !525)
!541 = !DILocation(line: 44, column: 40, scope: !525)
!542 = !DILocation(line: 45, column: 21, scope: !525)
!543 = !DILocation(line: 46, column: 35, scope: !525)
!544 = !DILocation(line: 46, column: 21, scope: !525)
!545 = !DILocation(line: 46, column: 50, scope: !525)
!546 = !DILocation(line: 45, column: 3, scope: !525)
!547 = !DILocation(line: 48, column: 11, scope: !525)
!548 = !DILocation(line: 48, column: 26, scope: !525)
!549 = !DILocation(line: 48, column: 43, scope: !525)
!550 = !DILocation(line: 48, column: 41, scope: !525)
!551 = !DILocation(line: 48, column: 54, scope: !525)
!552 = !DILocation(line: 48, column: 63, scope: !525)
!553 = !DILocation(line: 49, column: 21, scope: !525)
!554 = !DILocation(line: 49, column: 47, scope: !525)
!555 = !DILocation(line: 49, column: 3, scope: !525)
!556 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config", scope: null, file: !557, line: 33, type: !5, scopeLine: 33, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!557 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/filters/common.csl", directory: "")
!558 = !DILocation(line: 33, column: 46, scope: !559)
!559 = !DILexicalBlockFile(scope: !556, file: !557, discriminator: 0)
!560 = !DILocation(line: 33, column: 31, scope: !559)
!561 = !DILocation(line: 33, column: 15, scope: !559)
!562 = !DILocation(line: 34, column: 24, scope: !559)
!563 = !DILocation(line: 34, column: 23, scope: !559)
!564 = !DILocation(line: 34, column: 51, scope: !559)
!565 = !DILocation(line: 34, column: 35, scope: !559)
!566 = !DILocation(line: 34, column: 60, scope: !559)
!567 = !DILocation(line: 34, column: 73, scope: !559)
!568 = !DILocation(line: 34, column: 3, scope: !559)
!569 = !DILocation(line: 33, column: 1, scope: !559)
!570 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config", scope: null, file: !557, line: 38, type: !5, scopeLine: 38, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!571 = !DILocation(line: 38, column: 31, scope: !572)
!572 = !DILexicalBlockFile(scope: !570, file: !557, discriminator: 0)
!573 = !DILocation(line: 38, column: 15, scope: !572)
!574 = !DILocation(line: 39, column: 31, scope: !572)
!575 = !DILocation(line: 39, column: 30, scope: !572)
!576 = !DILocation(line: 39, column: 58, scope: !572)
!577 = !DILocation(line: 39, column: 42, scope: !572)
!578 = !DILocation(line: 39, column: 67, scope: !572)
!579 = !DILocation(line: 39, column: 10, scope: !572)
!580 = !DILocation(line: 39, column: 3, scope: !572)
!581 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit", scope: null, file: !582, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!582 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/teardown.csl", directory: "")
!583 = !DILocation(line: 43, column: 3, scope: !584)
!584 = !DILexicalBlockFile(scope: !581, file: !582, discriminator: 0)
!585 = !DILocation(line: 41, column: 3, scope: !584)
!586 = !DILocation(line: 40, column: 3, scope: !584)
!587 = !DILocation(line: 39, column: 9, scope: !584)
!588 = !DILocation(line: 40, column: 23, scope: !584)
!589 = !DILocation(line: 41, column: 70, scope: !584)
!590 = !DILocation(line: 41, column: 68, scope: !584)
!591 = !DILocation(line: 43, column: 27, scope: !584)
!592 = !DILocation(line: 43, column: 15, scope: !584)
!593 = !DILocation(line: 44, column: 15, scope: !584)
!594 = !DILocation(line: 44, column: 21, scope: !584)
!595 = !DILocation(line: 44, column: 27, scope: !584)
!596 = !DILocation(line: 44, column: 3, scope: !584)
!597 = !DILocation(line: 39, column: 1, scope: !584)
!598 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord", scope: null, file: !599, line: 4, type: !5, scopeLine: 4, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!599 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/layout.csl", directory: "")
!600 = !DILocation(line: 5, column: 10, scope: !601)
!601 = !DILexicalBlockFile(scope: !598, file: !599, discriminator: 0)
!602 = !DILocation(line: 5, column: 67, scope: !601)
!603 = !DILocation(line: 5, column: 3, scope: !601)
!604 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord", scope: null, file: !599, line: 8, type: !5, scopeLine: 8, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!605 = !DILocation(line: 9, column: 10, scope: !606)
!606 = !DILexicalBlockFile(scope: !604, file: !599, discriminator: 0)
!607 = !DILocation(line: 9, column: 67, scope: !606)
!608 = !DILocation(line: 9, column: 3, scope: !606)
!609 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord", scope: null, file: !610, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!610 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config.csl", directory: "")
!611 = !DILocation(line: 50, column: 3, scope: !612)
!612 = !DILexicalBlockFile(scope: !609, file: !610, discriminator: 0)
!613 = !DILocation(line: 43, column: 21, scope: !612)
!614 = !DILocation(line: 50, column: 57, scope: !612)
!615 = !DILocation(line: 50, column: 68, scope: !612)
!616 = !DILocation(line: 50, column: 41, scope: !612)
!617 = !DILocation(line: 50, column: 19, scope: !612)
!618 = !DILocation(line: 52, column: 10, scope: !612)
!619 = !DILocation(line: 52, column: 18, scope: !612)
!620 = !DILocation(line: 48, column: 22, scope: !612)
!621 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.get_x_coord", scope: null, file: !622, line: 171, type: !5, scopeLine: 171, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!622 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpyd2h.csl", directory: "")
!623 = !DILocation(line: 172, column: 12, scope: !624)
!624 = !DILexicalBlockFile(scope: !621, file: !622, discriminator: 0)
!625 = !DILocation(line: 172, column: 5, scope: !624)
!626 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.get_y_coord", scope: null, file: !622, line: 174, type: !5, scopeLine: 174, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!627 = !DILocation(line: 175, column: 12, scope: !628)
!628 = !DILexicalBlockFile(scope: !626, file: !622, discriminator: 0)
!629 = !DILocation(line: 175, column: 5, scope: !628)
!630 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval", scope: null, file: !622, line: 187, type: !5, scopeLine: 187, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!631 = !DILocation(line: 187, column: 23, scope: !632)
!632 = !DILexicalBlockFile(scope: !630, file: !622, discriminator: 0)
!633 = !DILocation(line: 188, column: 9, scope: !632)
!634 = !DILocation(line: 188, column: 20, scope: !632)
!635 = !DILocation(line: 188, column: 5, scope: !632)
!636 = !DILocation(line: 191, column: 23, scope: !632)
!637 = !DILocation(line: 191, column: 20, scope: !632)
!638 = !DILocation(line: 191, column: 9, scope: !632)
!639 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start", scope: null, file: !622, line: 383, type: !5, scopeLine: 383, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!640 = !DILocation(line: 386, column: 5, scope: !641)
!641 = !DILexicalBlockFile(scope: !639, file: !622, discriminator: 0)
!642 = !DILocation(line: 384, column: 72, scope: !641)
!643 = !DILocation(line: 384, column: 59, scope: !641)
!644 = !DILocation(line: 384, column: 46, scope: !641)
!645 = !DILocation(line: 384, column: 33, scope: !641)
!646 = !DILocation(line: 384, column: 19, scope: !641)
!647 = !DILocation(line: 384, column: 5, scope: !641)
!648 = !DILocation(line: 383, column: 32, scope: !641)
!649 = !DILocation(line: 383, column: 21, scope: !641)
!650 = !DILocation(line: 386, column: 26, scope: !641)
!651 = !DILocation(line: 388, column: 28, scope: !641)
!652 = !DILocation(line: 388, column: 17, scope: !641)
!653 = !DILocation(line: 389, column: 25, scope: !641)
!654 = !DILocation(line: 389, column: 23, scope: !641)
!655 = !DILocation(line: 391, column: 38, scope: !641)
!656 = !DILocation(line: 391, column: 20, scope: !641)
!657 = !DILocation(line: 391, column: 18, scope: !641)
!658 = !DILocation(line: 393, column: 7, scope: !641)
!659 = !DILocation(line: 395, column: 17, scope: !641)
!660 = !DILocation(line: 395, column: 15, scope: !641)
!661 = !DILocation(line: 397, column: 15, scope: !641)
!662 = !DILocation(line: 397, column: 13, scope: !641)
!663 = !DILocation(line: 398, column: 15, scope: !641)
!664 = !DILocation(line: 398, column: 25, scope: !641)
!665 = !DILocation(line: 398, column: 23, scope: !641)
!666 = !DILocation(line: 398, column: 31, scope: !641)
!667 = !DILocation(line: 398, column: 13, scope: !641)
!668 = !DILocation(line: 401, column: 10, scope: !641)
!669 = !DILocation(line: 401, column: 17, scope: !641)
!670 = !DILocation(line: 401, column: 14, scope: !641)
!671 = !DILocation(line: 401, column: 5, scope: !641)
!672 = !DILocation(line: 403, column: 48, scope: !641)
!673 = !DILocation(line: 403, column: 26, scope: !641)
!674 = !DILocation(line: 404, column: 26, scope: !641)
!675 = !DILocation(line: 404, column: 18, scope: !641)
!676 = !DILocation(line: 407, column: 48, scope: !641)
!677 = !DILocation(line: 407, column: 26, scope: !641)
!678 = !DILocation(line: 408, column: 27, scope: !641)
!679 = !DILocation(line: 408, column: 18, scope: !641)
!680 = !DILocation(line: 411, column: 14, scope: !641)
!681 = !DILocation(line: 414, column: 14, scope: !641)
!682 = !DILocation(line: 414, column: 11, scope: !641)
!683 = !DILocation(line: 414, column: 5, scope: !641)
!684 = !DILocation(line: 416, column: 44, scope: !641)
!685 = !DILocation(line: 416, column: 75, scope: !641)
!686 = !DILocation(line: 416, column: 59, scope: !641)
!687 = !DILocation(line: 416, column: 25, scope: !641)
!688 = !DILocation(line: 416, column: 23, scope: !641)
!689 = !DILocation(line: 418, column: 41, scope: !641)
!690 = !DILocation(line: 418, column: 23, scope: !641)
!691 = !DILocation(line: 419, column: 9, scope: !641)
!692 = !DILocation(line: 425, column: 44, scope: !641)
!693 = !DILocation(line: 425, column: 23, scope: !641)
!694 = !DILocation(line: 426, column: 41, scope: !641)
!695 = !DILocation(line: 426, column: 23, scope: !641)
!696 = !DILocation(line: 427, column: 9, scope: !641)
!697 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x", scope: null, file: !622, line: 448, type: !5, scopeLine: 448, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!698 = !DILocation(line: 448, column: 31, scope: !699)
!699 = !DILexicalBlockFile(scope: !697, file: !622, discriminator: 0)
!700 = !DILocation(line: 453, column: 5, scope: !699)
!701 = !DILocation(line: 456, column: 19, scope: !699)
!702 = !DILocation(line: 456, column: 17, scope: !699)
!703 = !DILocation(line: 461, column: 5, scope: !699)
!704 = !DILocation(line: 462, column: 28, scope: !699)
!705 = !DILocation(line: 462, column: 5, scope: !699)
!706 = !DILocation(line: 463, column: 5, scope: !699)
!707 = !DILocation(line: 464, column: 9, scope: !699)
!708 = !DILocation(line: 464, column: 10, scope: !699)
!709 = !DILocation(line: 464, column: 7, scope: !699)
!710 = !DILocation(line: 448, column: 1, scope: !699)
!711 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_send_data", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_send_data", scope: null, file: !622, line: 476, type: !5, scopeLine: 476, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!712 = !DILocation(line: 494, column: 9, scope: !713)
!713 = !DILexicalBlockFile(scope: !711, file: !622, discriminator: 0)
!714 = !DILocation(line: 478, column: 9, scope: !713)
!715 = !DILocation(line: 478, column: 13, scope: !713)
!716 = !DILocation(line: 478, column: 11, scope: !713)
!717 = !DILocation(line: 478, column: 5, scope: !713)
!718 = !DILocation(line: 479, column: 9, scope: !713)
!719 = !DILocation(line: 480, column: 32, scope: !713)
!720 = !DILocation(line: 480, column: 9, scope: !713)
!721 = !DILocation(line: 481, column: 17, scope: !713)
!722 = !DILocation(line: 481, column: 15, scope: !713)
!723 = !DILocation(line: 481, column: 9, scope: !713)
!724 = !DILocation(line: 482, column: 13, scope: !713)
!725 = !DILocation(line: 483, column: 51, scope: !713)
!726 = !DILocation(line: 483, column: 29, scope: !713)
!727 = !DILocation(line: 483, column: 27, scope: !713)
!728 = !DILocation(line: 485, column: 13, scope: !713)
!729 = !DILocation(line: 486, column: 51, scope: !713)
!730 = !DILocation(line: 486, column: 29, scope: !713)
!731 = !DILocation(line: 486, column: 27, scope: !713)
!732 = !DILocation(line: 488, column: 13, scope: !713)
!733 = !DILocation(line: 488, column: 14, scope: !713)
!734 = !DILocation(line: 488, column: 11, scope: !713)
!735 = !DILocation(line: 494, column: 30, scope: !713)
!736 = !DILocation(line: 496, column: 14, scope: !713)
!737 = !DILocation(line: 496, column: 25, scope: !713)
!738 = !DILocation(line: 496, column: 22, scope: !713)
!739 = !DILocation(line: 496, column: 9, scope: !713)
!740 = !DILocation(line: 497, column: 13, scope: !713)
!741 = !DILocation(line: 498, column: 13, scope: !713)
!742 = !DILocation(line: 499, column: 13, scope: !713)
!743 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl", scope: null, file: !622, line: 505, type: !5, scopeLine: 505, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!744 = !DILocation(line: 524, column: 13, scope: !745)
!745 = !DILexicalBlockFile(scope: !743, file: !622, discriminator: 0)
!746 = !DILocation(line: 506, column: 14, scope: !745)
!747 = !DILocation(line: 506, column: 11, scope: !745)
!748 = !DILocation(line: 506, column: 5, scope: !745)
!749 = !DILocation(line: 508, column: 9, scope: !745)
!750 = !DILocation(line: 509, column: 32, scope: !745)
!751 = !DILocation(line: 509, column: 9, scope: !745)
!752 = !DILocation(line: 510, column: 9, scope: !745)
!753 = !DILocation(line: 514, column: 13, scope: !745)
!754 = !DILocation(line: 514, column: 17, scope: !745)
!755 = !DILocation(line: 514, column: 15, scope: !745)
!756 = !DILocation(line: 514, column: 9, scope: !745)
!757 = !DILocation(line: 518, column: 13, scope: !745)
!758 = !DILocation(line: 519, column: 36, scope: !745)
!759 = !DILocation(line: 519, column: 13, scope: !745)
!760 = !DILocation(line: 520, column: 13, scope: !745)
!761 = !DILocation(line: 524, column: 34, scope: !745)
!762 = !DILocation(line: 526, column: 18, scope: !745)
!763 = !DILocation(line: 526, column: 29, scope: !745)
!764 = !DILocation(line: 526, column: 26, scope: !745)
!765 = !DILocation(line: 526, column: 13, scope: !745)
!766 = !DILocation(line: 529, column: 17, scope: !745)
!767 = !DILocation(line: 530, column: 17, scope: !745)
!768 = !DILocation(line: 531, column: 17, scope: !745)
!769 = !DILocation(line: 534, column: 17, scope: !745)
!770 = !DILocation(line: 535, column: 40, scope: !745)
!771 = !DILocation(line: 535, column: 17, scope: !745)
!772 = !DILocation(line: 536, column: 17, scope: !745)
!773 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.d2h_configure", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.d2h_configure", scope: null, file: !622, line: 593, type: !5, scopeLine: 593, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!774 = !DILocation(line: 617, column: 26, scope: !775)
!775 = !DILexicalBlockFile(scope: !773, file: !622, discriminator: 0)
!776 = !DILocation(line: 612, column: 47, scope: !775)
!777 = !DILocation(line: 612, column: 27, scope: !775)
!778 = !DILocation(line: 602, column: 5, scope: !775)
!779 = !DILocation(line: 601, column: 5, scope: !775)
!780 = !DILocation(line: 599, column: 5, scope: !775)
!781 = !DILocation(line: 598, column: 5, scope: !775)
!782 = !DILocation(line: 596, column: 5, scope: !775)
!783 = !DILocation(line: 595, column: 5, scope: !775)
!784 = !DILocation(line: 593, column: 86, scope: !775)
!785 = !DILocation(line: 593, column: 70, scope: !775)
!786 = !DILocation(line: 593, column: 60, scope: !775)
!787 = !DILocation(line: 593, column: 52, scope: !775)
!788 = !DILocation(line: 593, column: 44, scope: !775)
!789 = !DILocation(line: 593, column: 35, scope: !775)
!790 = !DILocation(line: 593, column: 26, scope: !775)
!791 = !DILocation(line: 593, column: 18, scope: !775)
!792 = !DILocation(line: 595, column: 26, scope: !775)
!793 = !DILocation(line: 596, column: 26, scope: !775)
!794 = !DILocation(line: 598, column: 23, scope: !775)
!795 = !DILocation(line: 599, column: 23, scope: !775)
!796 = !DILocation(line: 599, column: 28, scope: !775)
!797 = !DILocation(line: 599, column: 26, scope: !775)
!798 = !DILocation(line: 599, column: 29, scope: !775)
!799 = !DILocation(line: 601, column: 24, scope: !775)
!800 = !DILocation(line: 602, column: 24, scope: !775)
!801 = !DILocation(line: 602, column: 29, scope: !775)
!802 = !DILocation(line: 602, column: 27, scope: !775)
!803 = !DILocation(line: 602, column: 30, scope: !775)
!804 = !DILocation(line: 611, column: 20, scope: !775)
!805 = !DILocation(line: 612, column: 11, scope: !775)
!806 = !DILocation(line: 612, column: 18, scope: !775)
!807 = !DILocation(line: 612, column: 15, scope: !775)
!808 = !DILocation(line: 612, column: 32, scope: !775)
!809 = !DILocation(line: 612, column: 39, scope: !775)
!810 = !DILocation(line: 612, column: 36, scope: !775)
!811 = !DILocation(line: 612, column: 52, scope: !775)
!812 = !DILocation(line: 612, column: 59, scope: !775)
!813 = !DILocation(line: 612, column: 56, scope: !775)
!814 = !DILocation(line: 612, column: 5, scope: !775)
!815 = !DILocation(line: 613, column: 24, scope: !775)
!816 = !DILocation(line: 616, column: 15, scope: !775)
!817 = !DILocation(line: 617, column: 11, scope: !775)
!818 = !DILocation(line: 617, column: 18, scope: !775)
!819 = !DILocation(line: 617, column: 15, scope: !775)
!820 = !DILocation(line: 617, column: 30, scope: !775)
!821 = !DILocation(line: 617, column: 5, scope: !775)
!822 = !DILocation(line: 618, column: 19, scope: !775)
!823 = !DILocation(line: 621, column: 9, scope: !775)
!824 = !DILocation(line: 621, column: 5, scope: !775)
!825 = !DILocation(line: 627, column: 9, scope: !775)
!826 = !DILocation(line: 629, column: 13, scope: !775)
!827 = !DILocation(line: 629, column: 25, scope: !775)
!828 = !DILocation(line: 629, column: 21, scope: !775)
!829 = !DILocation(line: 629, column: 9, scope: !775)
!830 = !DILocation(line: 632, column: 13, scope: !775)
!831 = !DILocation(line: 636, column: 13, scope: !775)
!832 = !DILocation(line: 641, column: 9, scope: !775)
!833 = !DILocation(line: 646, column: 13, scope: !775)
!834 = !DILocation(line: 646, column: 9, scope: !775)
!835 = !DILocation(line: 647, column: 30, scope: !775)
!836 = !DILocation(line: 647, column: 35, scope: !775)
!837 = !DILocation(line: 647, column: 46, scope: !775)
!838 = !DILocation(line: 647, column: 50, scope: !775)
!839 = !DILocation(line: 647, column: 54, scope: !775)
!840 = !DILocation(line: 647, column: 57, scope: !775)
!841 = !DILocation(line: 647, column: 60, scope: !775)
!842 = !DILocation(line: 647, column: 63, scope: !775)
!843 = !DILocation(line: 647, column: 13, scope: !775)
!844 = !DILocation(line: 661, column: 9, scope: !775)
!845 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit", scope: null, file: !582, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!846 = !DILocation(line: 43, column: 3, scope: !847)
!847 = !DILexicalBlockFile(scope: !845, file: !582, discriminator: 0)
!848 = !DILocation(line: 41, column: 3, scope: !847)
!849 = !DILocation(line: 40, column: 3, scope: !847)
!850 = !DILocation(line: 39, column: 9, scope: !847)
!851 = !DILocation(line: 40, column: 23, scope: !847)
!852 = !DILocation(line: 41, column: 70, scope: !847)
!853 = !DILocation(line: 41, column: 68, scope: !847)
!854 = !DILocation(line: 43, column: 27, scope: !847)
!855 = !DILocation(line: 43, column: 15, scope: !847)
!856 = !DILocation(line: 44, column: 15, scope: !847)
!857 = !DILocation(line: 44, column: 21, scope: !847)
!858 = !DILocation(line: 44, column: 27, scope: !847)
!859 = !DILocation(line: 44, column: 3, scope: !847)
!860 = !DILocation(line: 39, column: 1, scope: !847)
!861 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord", scope: null, file: !599, line: 4, type: !5, scopeLine: 4, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!862 = !DILocation(line: 5, column: 10, scope: !863)
!863 = !DILexicalBlockFile(scope: !861, file: !599, discriminator: 0)
!864 = !DILocation(line: 5, column: 67, scope: !863)
!865 = !DILocation(line: 5, column: 3, scope: !863)
!866 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord", scope: null, file: !599, line: 8, type: !5, scopeLine: 8, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!867 = !DILocation(line: 9, column: 10, scope: !868)
!868 = !DILexicalBlockFile(scope: !866, file: !599, discriminator: 0)
!869 = !DILocation(line: 9, column: 67, scope: !868)
!870 = !DILocation(line: 9, column: 3, scope: !868)
!871 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord", scope: null, file: !610, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!872 = !DILocation(line: 50, column: 3, scope: !873)
!873 = !DILexicalBlockFile(scope: !871, file: !610, discriminator: 0)
!874 = !DILocation(line: 43, column: 21, scope: !873)
!875 = !DILocation(line: 50, column: 57, scope: !873)
!876 = !DILocation(line: 50, column: 68, scope: !873)
!877 = !DILocation(line: 50, column: 41, scope: !873)
!878 = !DILocation(line: 50, column: 19, scope: !873)
!879 = !DILocation(line: 52, column: 10, scope: !873)
!880 = !DILocation(line: 52, column: 18, scope: !873)
!881 = !DILocation(line: 48, column: 22, scope: !873)
!882 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr", linkageName: "sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr", scope: null, file: !883, line: 11, type: !5, scopeLine: 11, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!883 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/input_queue_config.csl", directory: "")
!884 = !DILocation(line: 11, column: 32, scope: !885)
!885 = !DILexicalBlockFile(scope: !882, file: !883, discriminator: 0)
!886 = !DILocation(line: 12, column: 80, scope: !885)
!887 = !DILocation(line: 12, column: 69, scope: !885)
!888 = !DILocation(line: 12, column: 39, scope: !885)
!889 = !DILocation(line: 12, column: 3, scope: !885)
!890 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue", linkageName: "sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue", scope: null, file: !883, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!891 = !DILocation(line: 46, column: 3, scope: !892)
!892 = !DILexicalBlockFile(scope: !890, file: !883, discriminator: 0)
!893 = !DILocation(line: 45, column: 3, scope: !892)
!894 = !DILocation(line: 39, column: 42, scope: !892)
!895 = !DILocation(line: 39, column: 34, scope: !892)
!896 = !DILocation(line: 39, column: 24, scope: !892)
!897 = !DILocation(line: 45, column: 44, scope: !892)
!898 = !DILocation(line: 45, column: 16, scope: !892)
!899 = !DILocation(line: 46, column: 30, scope: !892)
!900 = !DILocation(line: 46, column: 18, scope: !892)
!901 = !DILocation(line: 56, column: 9, scope: !892)
!902 = !DILocation(line: 56, column: 5, scope: !892)
!903 = !DILocation(line: 58, column: 13, scope: !892)
!904 = !DILocation(line: 58, column: 17, scope: !892)
!905 = !DILocation(line: 58, column: 11, scope: !892)
!906 = !DILocation(line: 61, column: 13, scope: !892)
!907 = !DILocation(line: 61, column: 17, scope: !892)
!908 = !DILocation(line: 61, column: 11, scope: !892)
!909 = !DILocation(line: 66, column: 9, scope: !892)
!910 = !DILocation(line: 66, column: 13, scope: !892)
!911 = !DILocation(line: 66, column: 7, scope: !892)
!912 = !DILocation(line: 68, column: 9, scope: !892)
!913 = !DILocation(line: 68, column: 24, scope: !892)
!914 = !DILocation(line: 68, column: 13, scope: !892)
!915 = !DILocation(line: 68, column: 7, scope: !892)
!916 = !DILocation(line: 70, column: 15, scope: !892)
!917 = !DILocation(line: 70, column: 21, scope: !892)
!918 = !DILocation(line: 70, column: 3, scope: !892)
!919 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr", linkageName: "sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr", scope: null, file: !920, line: 11, type: !5, scopeLine: 11, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!920 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/output_queue_config.csl", directory: "")
!921 = !DILocation(line: 11, column: 33, scope: !922)
!922 = !DILexicalBlockFile(scope: !919, file: !920, discriminator: 0)
!923 = !DILocation(line: 12, column: 82, scope: !922)
!924 = !DILocation(line: 12, column: 40, scope: !922)
!925 = !DILocation(line: 12, column: 3, scope: !922)
!926 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue", linkageName: "sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue", scope: null, file: !920, line: 31, type: !5, scopeLine: 31, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!927 = !DILocation(line: 38, column: 3, scope: !928)
!928 = !DILexicalBlockFile(scope: !926, file: !920, discriminator: 0)
!929 = !DILocation(line: 37, column: 3, scope: !928)
!930 = !DILocation(line: 31, column: 35, scope: !928)
!931 = !DILocation(line: 31, column: 25, scope: !928)
!932 = !DILocation(line: 37, column: 45, scope: !928)
!933 = !DILocation(line: 37, column: 16, scope: !928)
!934 = !DILocation(line: 38, column: 30, scope: !928)
!935 = !DILocation(line: 38, column: 18, scope: !928)
!936 = !DILocation(line: 41, column: 9, scope: !928)
!937 = !DILocation(line: 41, column: 13, scope: !928)
!938 = !DILocation(line: 41, column: 7, scope: !928)
!939 = !DILocation(line: 43, column: 9, scope: !928)
!940 = !DILocation(line: 43, column: 24, scope: !928)
!941 = !DILocation(line: 43, column: 13, scope: !928)
!942 = !DILocation(line: 43, column: 27, scope: !928)
!943 = !DILocation(line: 43, column: 7, scope: !928)
!944 = !DILocation(line: 45, column: 15, scope: !928)
!945 = !DILocation(line: 45, column: 21, scope: !928)
!946 = !DILocation(line: 45, column: 3, scope: !928)
!947 = !DILocation(line: 31, column: 1, scope: !928)
!948 = distinct !DISubprogram(name: ".get_tensor_ptr", linkageName: ".get_tensor_ptr", scope: null, file: !4, line: 1, type: !5, scopeLine: 1, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!949 = !DILocation(line: 1, column: 1, scope: !950)
!950 = !DILexicalBlockFile(scope: !948, file: !4, discriminator: 0)
!951 = distinct !DISubprogram(name: "__generic0sys_mod.sys_mod.tile_config.queue_flush.exit", linkageName: "__generic0sys_mod.sys_mod.tile_config.queue_flush.exit", scope: null, file: !952, line: 12, type: !5, scopeLine: 12, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!952 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/queue_flush.csl", directory: "")
!953 = !DILocation(line: 24, column: 3, scope: !954)
!954 = !DILexicalBlockFile(scope: !951, file: !952, discriminator: 0)
!955 = !DILocation(line: 12, column: 1, scope: !954)
!956 = distinct !DISubprogram(name: "__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position", linkageName: "__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position", scope: null, file: !957, line: 30, type: !5, scopeLine: 30, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!957 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/switch_config.csl", directory: "")
!958 = !DILocation(line: 34, column: 3, scope: !959)
!959 = !DILexicalBlockFile(scope: !956, file: !957, discriminator: 0)
!960 = !DILocation(line: 32, column: 3, scope: !959)
!961 = !DILocation(line: 30, column: 27, scope: !959)
!962 = !DILocation(line: 33, column: 7, scope: !959)
!963 = !DILocation(line: 34, column: 36, scope: !959)
!964 = !DILocation(line: 34, column: 24, scope: !959)
!965 = !DILocation(line: 35, column: 3, scope: !959)
!966 = !DILocation(line: 35, column: 18, scope: !959)
!967 = !DILocation(line: 36, column: 15, scope: !959)
!968 = !DILocation(line: 36, column: 21, scope: !959)
!969 = !DILocation(line: 36, column: 3, scope: !959)
!970 = !DILocation(line: 30, column: 1, scope: !959)
!971 = distinct !DISubprogram(name: "__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", linkageName: "__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", scope: null, file: !972, line: 96, type: !5, scopeLine: 96, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!972 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/color_config.csl", directory: "")
!973 = !DILocation(line: 99, column: 3, scope: !974)
!974 = !DILexicalBlockFile(scope: !971, file: !972, discriminator: 0)
!975 = !DILocation(line: 98, column: 3, scope: !974)
!976 = !DILocation(line: 96, column: 17, scope: !974)
!977 = !DILocation(line: 98, column: 16, scope: !974)
!978 = !DILocation(line: 99, column: 29, scope: !974)
!979 = !DILocation(line: 99, column: 17, scope: !974)
!980 = !DILocation(line: 100, column: 13, scope: !974)
!981 = !DILocation(line: 100, column: 21, scope: !974)
!982 = !DILocation(line: 100, column: 11, scope: !974)
!983 = !DILocation(line: 104, column: 7, scope: !974)
!984 = !DILocation(line: 104, column: 50, scope: !974)
!985 = !DILocation(line: 104, column: 18, scope: !974)
!986 = !DILocation(line: 104, column: 15, scope: !974)
!987 = !DILocation(line: 121, column: 7, scope: !974)
!988 = !DILocation(line: 121, column: 50, scope: !974)
!989 = !DILocation(line: 121, column: 18, scope: !974)
!990 = !DILocation(line: 121, column: 15, scope: !974)
!991 = !DILocation(line: 128, column: 15, scope: !974)
!992 = !DILocation(line: 128, column: 21, scope: !974)
!993 = !DILocation(line: 128, column: 3, scope: !974)
!994 = !DILocation(line: 96, column: 1, scope: !974)
!995 = distinct !DISubprogram(name: "__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", linkageName: "__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", scope: null, file: !972, line: 96, type: !5, scopeLine: 96, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!996 = !DILocation(line: 99, column: 3, scope: !997)
!997 = !DILexicalBlockFile(scope: !995, file: !972, discriminator: 0)
!998 = !DILocation(line: 98, column: 3, scope: !997)
!999 = !DILocation(line: 96, column: 17, scope: !997)
!1000 = !DILocation(line: 98, column: 16, scope: !997)
!1001 = !DILocation(line: 99, column: 29, scope: !997)
!1002 = !DILocation(line: 99, column: 17, scope: !997)
!1003 = !DILocation(line: 100, column: 13, scope: !997)
!1004 = !DILocation(line: 100, column: 21, scope: !997)
!1005 = !DILocation(line: 100, column: 11, scope: !997)
!1006 = !DILocation(line: 104, column: 7, scope: !997)
!1007 = !DILocation(line: 104, column: 50, scope: !997)
!1008 = !DILocation(line: 104, column: 18, scope: !997)
!1009 = !DILocation(line: 104, column: 15, scope: !997)
!1010 = !DILocation(line: 121, column: 7, scope: !997)
!1011 = !DILocation(line: 121, column: 50, scope: !997)
!1012 = !DILocation(line: 121, column: 18, scope: !997)
!1013 = !DILocation(line: 121, column: 15, scope: !997)
!1014 = !DILocation(line: 128, column: 15, scope: !997)
!1015 = !DILocation(line: 128, column: 21, scope: !997)
!1016 = !DILocation(line: 128, column: 3, scope: !997)
!1017 = !DILocation(line: 96, column: 1, scope: !997)
!1018 = distinct !DISubprogram(name: "__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", linkageName: "__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", scope: null, file: !972, line: 60, type: !5, scopeLine: 60, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1019 = !DILocation(line: 61, column: 3, scope: !1020)
!1020 = !DILexicalBlockFile(scope: !1018, file: !972, discriminator: 0)
!1021 = !DILocation(line: 60, column: 46, scope: !1020)
!1022 = !DILocation(line: 61, column: 16, scope: !1020)
!1023 = !DILocation(line: 72, column: 5, scope: !1020)
!1024 = !DILocation(line: 72, column: 12, scope: !1020)
!1025 = !DILocation(line: 74, column: 10, scope: !1020)
!1026 = !DILocation(line: 74, column: 3, scope: !1020)
!1027 = distinct !DISubprogram(name: "__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes", linkageName: "__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes", scope: null, file: !972, line: 77, type: !5, scopeLine: 77, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1028 = !DILocation(line: 78, column: 3, scope: !1029)
!1029 = !DILexicalBlockFile(scope: !1027, file: !972, discriminator: 0)
!1030 = !DILocation(line: 77, column: 46, scope: !1029)
!1031 = !DILocation(line: 78, column: 16, scope: !1029)
!1032 = !DILocation(line: 86, column: 5, scope: !1029)
!1033 = !DILocation(line: 86, column: 12, scope: !1029)
!1034 = !DILocation(line: 91, column: 10, scope: !1029)
!1035 = !DILocation(line: 91, column: 3, scope: !1029)
!1036 = distinct !DISubprogram(name: "__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", linkageName: "__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", scope: null, file: !972, line: 60, type: !5, scopeLine: 60, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1037 = !DILocation(line: 61, column: 3, scope: !1038)
!1038 = !DILexicalBlockFile(scope: !1036, file: !972, discriminator: 0)
!1039 = !DILocation(line: 60, column: 46, scope: !1038)
!1040 = !DILocation(line: 61, column: 16, scope: !1038)
!1041 = !DILocation(line: 63, column: 5, scope: !1038)
!1042 = !DILocation(line: 63, column: 12, scope: !1038)
!1043 = !DILocation(line: 74, column: 10, scope: !1038)
!1044 = !DILocation(line: 74, column: 3, scope: !1038)
!1045 = distinct !DISubprogram(name: "__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction", linkageName: "__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction", scope: null, file: !972, line: 52, type: !5, scopeLine: 52, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1046 = !DILocation(line: 55, column: 3, scope: !1047)
!1047 = !DILexicalBlockFile(scope: !1045, file: !972, discriminator: 0)
!1048 = !DILocation(line: 54, column: 3, scope: !1047)
!1049 = !DILocation(line: 52, column: 23, scope: !1047)
!1050 = !DILocation(line: 54, column: 16, scope: !1047)
!1051 = !DILocation(line: 55, column: 29, scope: !1047)
!1052 = !DILocation(line: 55, column: 17, scope: !1047)
!1053 = !DILocation(line: 56, column: 3, scope: !1047)
!1054 = !DILocation(line: 56, column: 11, scope: !1047)
!1055 = !DILocation(line: 57, column: 15, scope: !1047)
!1056 = !DILocation(line: 57, column: 21, scope: !1047)
!1057 = !DILocation(line: 57, column: 3, scope: !1047)
!1058 = !DILocation(line: 52, column: 1, scope: !1047)
!1059 = distinct !DISubprogram(name: "__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction", linkageName: "__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction", scope: null, file: !972, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1060 = !DILocation(line: 23, column: 3, scope: !1061)
!1061 = !DILexicalBlockFile(scope: !1059, file: !972, discriminator: 0)
!1062 = !DILocation(line: 22, column: 3, scope: !1061)
!1063 = !DILocation(line: 20, column: 21, scope: !1061)
!1064 = !DILocation(line: 22, column: 16, scope: !1061)
!1065 = !DILocation(line: 23, column: 29, scope: !1061)
!1066 = !DILocation(line: 23, column: 17, scope: !1061)
!1067 = !DILocation(line: 24, column: 3, scope: !1061)
!1068 = !DILocation(line: 24, column: 11, scope: !1061)
!1069 = !DILocation(line: 25, column: 15, scope: !1061)
!1070 = !DILocation(line: 25, column: 21, scope: !1061)
!1071 = !DILocation(line: 25, column: 3, scope: !1061)
!1072 = !DILocation(line: 20, column: 1, scope: !1061)
module asm ".section \22.pe_debug_info\22, \22\22"
module asm ".section \22.note\22, \22\22"
