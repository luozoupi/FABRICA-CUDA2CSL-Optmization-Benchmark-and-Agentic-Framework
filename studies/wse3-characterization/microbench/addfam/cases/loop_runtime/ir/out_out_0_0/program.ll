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
  %3 = load i16, i16* getelementptr inbounds ([4 x i16], [4 x i16]* @k, i16 0, i1 false), align 2, !dbg !10
  store i16 %3, i16* %2, align 2, !dbg !9
  store i16 0, i16* %1, align 2, !dbg !7
  br label %4, !dbg !11

4:                                                ; preds = %22, %0
  %5 = phi i16 [ 0, %22 ], [ 0, %0 ]
  %6 = icmp sgt i16 %5, 0, !dbg !11
  br i1 %6, label %7, label %9, !dbg !11

7:                                                ; preds = %4
  %8 = sub i16 %5, 1, !dbg !11
  br label %10, !dbg !11

9:                                                ; preds = %4
  br label %10, !dbg !11

10:                                               ; preds = %7, %9
  %11 = phi i16 [ %5, %9 ], [ %8, %7 ]
  br label %12, !dbg !11

12:                                               ; preds = %10
  %13 = icmp ne i16 %5, 0, !dbg !11
  br i1 %13, label %14, label %15, !dbg !11

14:                                               ; preds = %12
  br label %19, !dbg !11

15:                                               ; preds = %12
  %16 = load i16, i16* %1, align 2, !dbg !12
  %17 = load i16, i16* %2, align 2, !dbg !13
  %18 = icmp ult i16 %16, %17, !dbg !14
  br label %19, !dbg !11

19:                                               ; preds = %14, %15
  %20 = phi i1 [ %18, %15 ], [ false, %14 ]
  br label %21, !dbg !11

21:                                               ; preds = %19
  br i1 %20, label %22, label %34, !dbg !11

22:                                               ; preds = %21
  %23 = load i16, i16* %1, align 2, !dbg !15
  %24 = getelementptr [64 x i16], [64 x i16]* @a, i16 0, i16 %23, !dbg !16
  %25 = load i16, i16* %24, align 2, !dbg !16
  %26 = load i16, i16* %1, align 2, !dbg !17
  %27 = getelementptr [64 x i16], [64 x i16]* @b, i16 0, i16 %26, !dbg !18
  %28 = load i16, i16* %27, align 2, !dbg !18
  %29 = add i16 %25, %28, !dbg !19
  %30 = load i16, i16* %1, align 2, !dbg !20
  %31 = getelementptr [64 x i16], [64 x i16]* @c, i16 0, i16 %30, !dbg !21
  store i16 %29, i16* %31, align 2, !dbg !22
  %32 = load i16, i16* %1, align 2, !dbg !23
  %33 = add i16 %32, 1, !dbg !24
  store i16 %33, i16* %1, align 2, !dbg !24
  br label %4, !dbg !11

34:                                               ; preds = %21
  %35 = icmp ne i16 %11, 0, !dbg !11
  br i1 %35, label %36, label %37, !dbg !11

36:                                               ; preds = %34
  br label %38, !dbg !11

37:                                               ; preds = %34
  call void @llvm.sdr.actvt.r(i16 9), !dbg !25
  br label %38, !dbg !11

38:                                               ; preds = %36, %37
  ret void, !dbg !11
}

define void @f_exit() #0 !dbg !26 {
  call void @sys_mod.unblock_cmd_stream(), !dbg !27
  ret void, !dbg !29
}

define internal void @sys_mod.sys_nop() !dbg !30 {
  ret void, !dbg !32
}

define internal void @sys_mod.unblock_cmd_stream() !dbg !34 {
  call void @sys_mod.sys_mod.unblock_cmd_stream(), !dbg !35
  ret void, !dbg !37
}

define internal void @sys_mod.sys_mod.unblock_cmd_stream() !dbg !38 {
  call void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream(), !dbg !40
  ret void, !dbg !42
}

define internal void @sys_mod.sys_mod.teardown_h2d() !dbg !43 {
  call void @llvm.sdr.actvt.r(i16 27), !dbg !44
  ret void, !dbg !46
}

define void @sys_mod.sys_mod.f_ublk_c22() #1 !dbg !47 {
  call void @sys_mod.sys_mod.unblock_cmd_stream(), !dbg !48
  ret void, !dbg !50
}

define internal void @sys_mod.sys_mod.teardown_d2h() !dbg !51 {
  call void @llvm.sdr.blk.r(i16 0), !dbg !52
  call void @llvm.sdr.actvt.r(i16 28), !dbg !54
  ret void, !dbg !55
}

define void @sys_mod.sys_mod.f_memcpyh2d() #2 !dbg !56 {
  %1 = alloca float, i16 1, align 4, !dbg !57
  %2 = alloca float, i16 1, align 4, !dbg !59
  %3 = alloca i16, i16 1, align 2, !dbg !60
  %4 = alloca i16, i16 1, align 2, !dbg !61
  %5 = alloca i16, i16 1, align 2, !dbg !62
  %6 = alloca i16, i16 1, align 2, !dbg !63
  %7 = alloca i16, i16 1, align 2, !dbg !64
  %8 = alloca i16, i16 1, align 2, !dbg !65
  %9 = alloca i16, i16 1, align 2, !dbg !66
  %10 = alloca i16, i16 1, align 2, !dbg !67
  %11 = alloca i16, i16 1, align 2, !dbg !68
  %12 = alloca i16, i16 1, align 2, !dbg !69
  %13 = alloca i16, i16 1, align 2, !dbg !70
  %14 = alloca i16*, i16 1, align 8, !dbg !71
  %15 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !72
  %16 = icmp eq i16 %15, 15, !dbg !73
  br i1 %16, label %17, label %18, !dbg !74

17:                                               ; preds = %0
  br label %19, !dbg !74

18:                                               ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !74
  br label %19, !dbg !74

19:                                               ; preds = %17, %18
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %14, align 8, !dbg !71
  %20 = load i16*, i16** %14, align 8, !dbg !75
  %21 = load i16, i16* %20, align 2, !dbg !76
  store i16 %21, i16* %13, align 2, !dbg !70
  %22 = load i16*, i16** %14, align 8, !dbg !77
  %23 = getelementptr i16, i16* %22, i16 1, !dbg !78
  %24 = load i16, i16* %23, align 2, !dbg !78
  store i16 %24, i16* %12, align 2, !dbg !69
  %25 = load i16*, i16** %14, align 8, !dbg !79
  %26 = getelementptr i16, i16* %25, i16 2, !dbg !80
  %27 = load i16, i16* %26, align 2, !dbg !80
  store i16 %27, i16* %11, align 2, !dbg !68
  %28 = load i16*, i16** %14, align 8, !dbg !81
  %29 = getelementptr i16, i16* %28, i16 3, !dbg !82
  %30 = load i16, i16* %29, align 2, !dbg !82
  store i16 %30, i16* %10, align 2, !dbg !67
  %31 = load i16*, i16** %14, align 8, !dbg !83
  %32 = getelementptr i16, i16* %31, i16 4, !dbg !84
  %33 = load i16, i16* %32, align 2, !dbg !84
  store i16 %33, i16* %9, align 2, !dbg !66
  %34 = load i16*, i16** %14, align 8, !dbg !85
  %35 = getelementptr i16, i16* %34, i16 5, !dbg !86
  %36 = load i16, i16* %35, align 2, !dbg !86
  store i16 %36, i16* %8, align 2, !dbg !65
  %37 = load i16*, i16** %14, align 8, !dbg !87
  %38 = getelementptr i16, i16* %37, i16 6, !dbg !88
  %39 = load i16, i16* %38, align 2, !dbg !88
  store i16 %39, i16* %7, align 2, !dbg !64
  %40 = load i16*, i16** %14, align 8, !dbg !89
  %41 = getelementptr i16, i16* %40, i16 7, !dbg !90
  %42 = load i16, i16* %41, align 2, !dbg !90
  store i16 %42, i16* %6, align 2, !dbg !63
  %43 = load i16*, i16** %14, align 8, !dbg !91
  %44 = getelementptr i16, i16* %43, i16 8, !dbg !92
  %45 = load i16, i16* %44, align 2, !dbg !92
  store i16 %45, i16* %5, align 2, !dbg !62
  %46 = load i16*, i16** %14, align 8, !dbg !93
  %47 = getelementptr i16, i16* %46, i16 9, !dbg !94
  %48 = load i16, i16* %47, align 2, !dbg !94
  store i16 %48, i16* %4, align 2, !dbg !61
  %49 = load i16*, i16** %14, align 8, !dbg !95
  %50 = getelementptr i16, i16* %49, i16 10, !dbg !96
  %51 = load i16, i16* %50, align 2, !dbg !96
  store i16 %51, i16* %3, align 2, !dbg !60
  %52 = load i16*, i16** %14, align 8, !dbg !97
  %53 = getelementptr i16, i16* %52, i16 12, !dbg !98
  %54 = load i16, i16* %53, align 2, !dbg !98
  %55 = zext i16 %54 to i32, !dbg !99
  %56 = load i16*, i16** %14, align 8, !dbg !100
  %57 = getelementptr i16, i16* %56, i16 11, !dbg !101
  %58 = load i16, i16* %57, align 2, !dbg !101
  %59 = zext i16 %58 to i32, !dbg !102
  %60 = add i32 %59, 16, !dbg !103
  %61 = shl i32 %55, %60, !dbg !104
  %62 = bitcast i32 %61 to float, !dbg !105
  store float %62, float* %2, align 4, !dbg !59
  %63 = load i16*, i16** %14, align 8, !dbg !106
  %64 = getelementptr i16, i16* %63, i16 14, !dbg !107
  %65 = load i16, i16* %64, align 2, !dbg !107
  %66 = zext i16 %65 to i32, !dbg !108
  %67 = load i16*, i16** %14, align 8, !dbg !109
  %68 = getelementptr i16, i16* %67, i16 13, !dbg !110
  %69 = load i16, i16* %68, align 2, !dbg !110
  %70 = zext i16 %69 to i32, !dbg !111
  %71 = add i32 %70, 16, !dbg !112
  %72 = shl i32 %66, %71, !dbg !113
  %73 = bitcast i32 %72 to float, !dbg !114
  store float %73, float* %1, align 4, !dbg !57
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !115
  %74 = load i16, i16* %13, align 2, !dbg !116
  store i16 %74, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !117
  %75 = load i16, i16* %12, align 2, !dbg !118
  store i16 %75, i16* @sys_mod.sys_mod.memcpyH2D_px, align 2, !dbg !119
  %76 = load i16, i16* %11, align 2, !dbg !120
  store i16 %76, i16* @sys_mod.sys_mod.memcpyH2D_py, align 2, !dbg !121
  %77 = load i16, i16* %10, align 2, !dbg !122
  store i16 %77, i16* @sys_mod.sys_mod.memcpyH2D_w, align 2, !dbg !123
  %78 = load i16, i16* %9, align 2, !dbg !124
  store i16 %78, i16* @sys_mod.sys_mod.memcpyH2D_h, align 2, !dbg !125
  %79 = load i16, i16* %8, align 2, !dbg !126
  store i16 %79, i16* @sys_mod.sys_mod.memcpyH2D_addr, align 2, !dbg !127
  %80 = load i16, i16* %7, align 2, !dbg !128
  store i16 %80, i16* @sys_mod.sys_mod.memcpyH2D_pe_length, align 2, !dbg !129
  %81 = load i16, i16* %6, align 2, !dbg !130
  store i16 %81, i16* @sys_mod.sys_mod.memcpyH2D_is_half, align 2, !dbg !131
  %82 = load i16, i16* %5, align 2, !dbg !132
  store i16 %82, i16* @sys_mod.sys_mod.memcpyH2D_memcpy_optype, align 2, !dbg !133
  %83 = load i16, i16* %4, align 2, !dbg !134
  store i16 %83, i16* @sys_mod.sys_mod.memcpyH2D_row_stride, align 2, !dbg !135
  %84 = load i16, i16* %3, align 2, !dbg !136
  store i16 %84, i16* @sys_mod.sys_mod.memcpyH2D_col_stride, align 2, !dbg !137
  %85 = load float, float* %2, align 4, !dbg !138
  store float %85, float* @sys_mod.sys_mod.memcpyH2D_one_over_row_stride, align 4, !dbg !139
  %86 = load float, float* %1, align 4, !dbg !140
  store float %86, float* @sys_mod.sys_mod.memcpyH2D_one_over_col_stride, align 4, !dbg !141
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !142
  call void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 0, i16 23, i1 true), !dbg !143
  call void @llvm.sdr.blk.r(i16 27), !dbg !144
  call void @llvm.sdr.oqflush(i16 0), !dbg !145
  store i1 true, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !146
  call void @llvm.sdr.blk.r(i16 0), !dbg !147
  ret void, !dbg !148
}

define void @sys_mod.sys_mod.f_memcpyd2h() #3 !dbg !149 {
  %1 = alloca i16, i16 1, align 2, !dbg !150
  %2 = alloca i16, i16 1, align 2, !dbg !152
  %3 = alloca i16, i16 1, align 2, !dbg !153
  %4 = alloca i16, i16 1, align 2, !dbg !154
  %5 = alloca i16, i16 1, align 2, !dbg !155
  %6 = alloca i16, i16 1, align 2, !dbg !156
  %7 = alloca i16, i16 1, align 2, !dbg !157
  %8 = alloca i16, i16 1, align 2, !dbg !158
  %9 = alloca i16*, i16 1, align 8, !dbg !159
  %10 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !160
  %11 = icmp eq i16 %10, 8, !dbg !161
  br i1 %11, label %12, label %13, !dbg !162

12:                                               ; preds = %0
  br label %14, !dbg !162

13:                                               ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !162
  br label %14, !dbg !162

14:                                               ; preds = %12, %13
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %9, align 8, !dbg !159
  %15 = load i16*, i16** %9, align 8, !dbg !163
  %16 = load i16, i16* %15, align 2, !dbg !164
  store i16 %16, i16* %8, align 2, !dbg !158
  %17 = load i16*, i16** %9, align 8, !dbg !165
  %18 = getelementptr i16, i16* %17, i16 1, !dbg !166
  %19 = load i16, i16* %18, align 2, !dbg !166
  store i16 %19, i16* %7, align 2, !dbg !157
  %20 = load i16*, i16** %9, align 8, !dbg !167
  %21 = getelementptr i16, i16* %20, i16 2, !dbg !168
  %22 = load i16, i16* %21, align 2, !dbg !168
  store i16 %22, i16* %6, align 2, !dbg !156
  %23 = load i16*, i16** %9, align 8, !dbg !169
  %24 = getelementptr i16, i16* %23, i16 3, !dbg !170
  %25 = load i16, i16* %24, align 2, !dbg !170
  store i16 %25, i16* %5, align 2, !dbg !155
  %26 = load i16*, i16** %9, align 8, !dbg !171
  %27 = getelementptr i16, i16* %26, i16 4, !dbg !172
  %28 = load i16, i16* %27, align 2, !dbg !172
  store i16 %28, i16* %4, align 2, !dbg !154
  %29 = load i16*, i16** %9, align 8, !dbg !173
  %30 = getelementptr i16, i16* %29, i16 5, !dbg !174
  %31 = load i16, i16* %30, align 2, !dbg !174
  store i16 %31, i16* %3, align 2, !dbg !153
  %32 = load i16*, i16** %9, align 8, !dbg !175
  %33 = getelementptr i16, i16* %32, i16 6, !dbg !176
  %34 = load i16, i16* %33, align 2, !dbg !176
  store i16 %34, i16* %2, align 2, !dbg !152
  %35 = load i16*, i16** %9, align 8, !dbg !177
  %36 = getelementptr i16, i16* %35, i16 7, !dbg !178
  %37 = load i16, i16* %36, align 2, !dbg !178
  store i16 %37, i16* %1, align 2, !dbg !150
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !179
  %38 = load i16, i16* %8, align 2, !dbg !180
  store i16 %38, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !181
  %39 = load i16, i16* %7, align 2, !dbg !182
  store i16 %39, i16* @sys_mod.sys_mod.memcpyD2H_px, align 2, !dbg !183
  %40 = load i16, i16* %6, align 2, !dbg !184
  store i16 %40, i16* @sys_mod.sys_mod.memcpyD2H_py, align 2, !dbg !185
  %41 = load i16, i16* %5, align 2, !dbg !186
  store i16 %41, i16* @sys_mod.sys_mod.memcpyD2H_w, align 2, !dbg !187
  %42 = load i16, i16* %4, align 2, !dbg !188
  store i16 %42, i16* @sys_mod.sys_mod.memcpyD2H_h, align 2, !dbg !189
  %43 = load i16, i16* %3, align 2, !dbg !190
  store i16 %43, i16* @sys_mod.sys_mod.memcpyD2H_addr, align 2, !dbg !191
  %44 = load i16, i16* %2, align 2, !dbg !192
  store i16 %44, i16* @sys_mod.sys_mod.memcpyD2H_pe_length, align 2, !dbg !193
  %45 = load i16, i16* %1, align 2, !dbg !194
  store i16 %45, i16* @sys_mod.sys_mod.memcpyD2H_is_half, align 2, !dbg !195
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !196
  %46 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !197
  call void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 0, i16 %46, i1 false), !dbg !198
  call void @llvm.sdr.oqflush(i16 0), !dbg !199
  store i1 false, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !200
  ret void, !dbg !201
}

define internal void @sys_mod.sys_mod.oq0_teardow_handler() !dbg !202 {
  %1 = load i1, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !203
  br i1 %1, label %2, label %17, !dbg !205

2:                                                ; preds = %0
  %3 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !206
  call void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 0, i16 %3), !dbg !207
  %4 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !208
  %5 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_px, align 2, !dbg !209
  %6 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_py, align 2, !dbg !210
  %7 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_w, align 2, !dbg !211
  %8 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_h, align 2, !dbg !212
  %9 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_addr, align 2, !dbg !213
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_pe_length, align 2, !dbg !214
  %11 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_is_half, align 2, !dbg !215
  %12 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_memcpy_optype, align 2, !dbg !216
  %13 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_row_stride, align 2, !dbg !217
  %14 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_col_stride, align 2, !dbg !218
  %15 = load float, float* @sys_mod.sys_mod.memcpyH2D_one_over_row_stride, align 4, !dbg !219
  %16 = load float, float* @sys_mod.sys_mod.memcpyH2D_one_over_col_stride, align 4, !dbg !220
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure(i16 %4, i16 %5, i16 %6, i16 %7, i16 %8, i16 %9, i16 %10, i16 %11, i16 %12, i16 %13, i16 %14, float %15, float %16), !dbg !221
  br label %26, !dbg !205

17:                                               ; preds = %0
  call void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 0, i16 21), !dbg !222
  %18 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !223
  %19 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_px, align 2, !dbg !224
  %20 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_py, align 2, !dbg !225
  %21 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_w, align 2, !dbg !226
  %22 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_h, align 2, !dbg !227
  %23 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_addr, align 2, !dbg !228
  %24 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_pe_length, align 2, !dbg !229
  %25 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_is_half, align 2, !dbg !230
  call void @sys_mod.sys_mod.memcpyd2h_mod.d2h_configure(i16 %18, i16 %19, i16 %20, i16 %21, i16 %22, i16 %23, i16 %24, i16 %25), !dbg !231
  br label %26, !dbg !205

26:                                               ; preds = %2, %17
  call void @__generic0sys_mod.sys_mod.tile_config.queue_flush.exit(), !dbg !232
  ret void, !dbg !205
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

define void @sys_mod.sys_mod.f_rpc(i16 %0) #4 !dbg !233 {
  %2 = alloca i16, i16 1, align 2, !dbg !234
  store i16 %0, i16* %2, align 2, !dbg !234
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !236
  %3 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !237
  %4 = icmp sge i16 %3, 4, !dbg !238
  br i1 %4, label %5, label %6, !dbg !239

5:                                                ; preds = %1
  br label %7, !dbg !239

6:                                                ; preds = %1
  call void asm sideeffect "hcf", ""(), !dbg !239
  br label %7, !dbg !239

7:                                                ; preds = %5, %6
  call void @rpc_server(i32* getelementptr inbounds ([32 x i32], [32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32, i32 0, i32 0)), !dbg !240
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !241
  ret void, !dbg !242
}

define internal void @sys_mod.sys_mod.sys_mod.stack_push(i16 %0) !dbg !243 {
  %2 = alloca i16*, i16 1, align 8, !dbg !245
  %3 = alloca i16, i16 1, align 2, !dbg !247
  store i16 %0, i16* %3, align 2, !dbg !247
  %4 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !248
  %5 = icmp slt i16 %4, 32, !dbg !249
  br i1 %5, label %6, label %7, !dbg !250

6:                                                ; preds = %1
  br label %8, !dbg !250

7:                                                ; preds = %1
  call void asm sideeffect "hcf", ""(), !dbg !250
  br label %8, !dbg !250

8:                                                ; preds = %6, %7
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %2, align 8, !dbg !245
  %9 = load i16, i16* %3, align 2, !dbg !251
  %10 = load i16*, i16** %2, align 8, !dbg !252
  %11 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !253
  %12 = getelementptr i16, i16* %10, i16 %11, !dbg !254
  store i16 %9, i16* %12, align 2, !dbg !255
  %13 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !256
  %14 = add i16 %13, 1, !dbg !257
  store i16 %14, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !258
  ret void, !dbg !259
}

define void @sys_mod.sys_mod.sys_mod.f_push(i16 %0, i16 %1) #5 !dbg !260 {
  %3 = alloca i16, i16 1, align 2, !dbg !261
  %4 = alloca i16, i16 1, align 2, !dbg !263
  store i16 %0, i16* %4, align 2, !dbg !263
  store i16 %1, i16* %3, align 2, !dbg !261
  %5 = load i16, i16* %4, align 2, !dbg !264
  call void @sys_mod.sys_mod.sys_mod.stack_push(i16 %5), !dbg !265
  ret void, !dbg !266
}

define internal void @sys_mod.sys_mod.sys_mod.block_cmd_stream() !dbg !267 {
  call void @llvm.sdr.blk.r(i16 1), !dbg !268
  ret void, !dbg !270
}

define internal void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream() !dbg !271 {
  call void @llvm.sdr.ublk.r(i16 1), !dbg !272
  ret void, !dbg !274
}

define void @sys_mod.sys_mod.sys_mod.f_sys_exit() #6 !dbg !275 {
  call void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream(), !dbg !276
  call void @sys_mod.sys_nop(), !dbg !278
  ret void, !dbg !279
}

define void @sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore(i32 %0) #7 !dbg !280 {
  %2 = alloca i32, i16 1, align 4, !dbg !281
  store i32 %0, i32* %2, align 4, !dbg !281
  ret void, !dbg !283
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord() !dbg !284 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord(), !dbg !286
  ret i16 %1, !dbg !288
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord() !dbg !289 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord(), !dbg !290
  ret i16 %1, !dbg !292
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval(i16 %0) !dbg !293 {
  %2 = alloca i16, i16 1, align 2, !dbg !294
  store i16 %0, i16* %2, align 2, !dbg !294
  %3 = load i16, i16* %2, align 2, !dbg !296
  %4 = icmp ult i16 %3, 24, !dbg !297
  br i1 %4, label %5, label %7, !dbg !298

5:                                                ; preds = %10, %11, %1
  %6 = phi i16 [ 0, %10 ], [ 0, %11 ], [ 1, %1 ]
  br label %12, !dbg !298

7:                                                ; preds = %1
  %8 = load i16, i16* %2, align 2, !dbg !299
  %9 = icmp eq i16 31, %8, !dbg !300
  br i1 %9, label %10, label %11, !dbg !301

10:                                               ; preds = %7
  br label %5, !dbg !301

11:                                               ; preds = %7
  call void asm sideeffect "hcf", ""(), !dbg !301
  br label %5, !dbg !301

12:                                               ; preds = %5
  %13 = phi i16 [ %6, %5 ]
  br label %14, !dbg !298

14:                                               ; preds = %12
  ret i16 %13, !dbg !298
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start(i16 %0, i16 %1, i16 %2) !dbg !302 {
  %4 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !303
  %5 = alloca i16, i16 1, align 2, !dbg !305
  %6 = alloca i16, i16 1, align 2, !dbg !306
  %7 = alloca i16, i16 1, align 2, !dbg !307
  store i16 %0, i16* %7, align 2, !dbg !307
  store i16 %1, i16* %6, align 2, !dbg !306
  store i16 %2, i16* %5, align 2, !dbg !305
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !308
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !308
  %10 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !308
  %11 = load i16, i16* %6, align 2, !dbg !309
  store i16 %11, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !310
  store i16 %8, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !310
  store i16 %9, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !310
  store i16 %10, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !310
  %12 = load i16, i16* %7, align 2, !dbg !311
  %13 = call i16* @.get_tensor_ptr(i16 %12), !dbg !312
  %14 = ptrtoint i16* %13 to i16, !dbg !313
  %15 = lshr i16 %14, 1, !dbg !313
  %16 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !303
  store i16 42, i16* %16, align 2, !dbg !303
  %17 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !303
  store i16 %15, i16* %17, align 2, !dbg !303
  %18 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !303
  store i16 143, i16* %18, align 2, !dbg !303
  %19 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !303
  store i16 16, i16* %19, align 2, !dbg !303
  %20 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !314
  %21 = load i16, i16* %20, align 2, !dbg !314
  %22 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !314
  %23 = load i16, i16* %22, align 2, !dbg !314
  %24 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !314
  %25 = load i16, i16* %24, align 2, !dbg !314
  %26 = load i16, i16* %6, align 2, !dbg !315
  %27 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !316
  store i16 %26, i16* %27, align 2, !dbg !316
  %28 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !316
  store i16 %21, i16* %28, align 2, !dbg !316
  %29 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !316
  store i16 %23, i16* %29, align 2, !dbg !316
  %30 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !316
  store i16 %25, i16* %30, align 2, !dbg !316
  %31 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !317
  %32 = load i16, i16* %31, align 2, !dbg !317
  %33 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !317
  %34 = load i16, i16* %33, align 2, !dbg !317
  %35 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !317
  %36 = load i16, i16* %35, align 2, !dbg !317
  %37 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !317
  %38 = load i16, i16* %37, align 2, !dbg !317
  store volatile i16 %32, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !318
  store volatile i16 %34, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !318
  store volatile i16 %36, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !318
  store volatile i16 %38, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !318
  call void asm sideeffect "nop", ""(), !dbg !318
  call void asm sideeffect "nop", ""(), !dbg !318
  %39 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !319
  %40 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !319
  %41 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !319
  %42 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !319
  %43 = and i16 %41, -193, !dbg !319
  %44 = or i16 %43, 128, !dbg !319
  %45 = and i16 %40, -64, !dbg !319
  %46 = or i16 %45, 27, !dbg !319
  store volatile i16 %39, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !320
  store volatile i16 %46, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !320
  store volatile i16 %44, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !320
  store volatile i16 %42, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !320
  call void asm sideeffect "nop", ""(), !dbg !320
  call void asm sideeffect "nop", ""(), !dbg !320
  %47 = load i16, i16* %5, align 2, !dbg !321
  %48 = icmp ult i16 0, %47, !dbg !322
  br i1 %48, label %49, label %50, !dbg !323

49:                                               ; preds = %3
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !324
  br label %51, !dbg !323

50:                                               ; preds = %3
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !325
  br label %51, !dbg !323

51:                                               ; preds = %49, %50
  ret void, !dbg !323
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream() !dbg !326 {
  call void @llvm.sdr.ublk.r(i16 1), !dbg !327
  ret void, !dbg !329
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7, i16 %8, i16 %9, i16 %10, float %11, float %12) !dbg !330 {
  %14 = alloca i16, i16 1, align 2, !dbg !331
  %15 = alloca i16, i16 1, align 2, !dbg !333
  %16 = alloca i16, i16 1, align 2, !dbg !334
  %17 = alloca i16, i16 1, align 2, !dbg !335
  %18 = alloca i16, i16 1, align 2, !dbg !336
  %19 = alloca i1, i16 1, align 1, !dbg !337
  %20 = alloca i16, i16 1, align 2, !dbg !338
  %21 = alloca i16, i16 1, align 2, !dbg !339
  %22 = alloca i16, i16 1, align 2, !dbg !340
  %23 = alloca i16, i16 1, align 2, !dbg !341
  %24 = alloca i16, i16 1, align 2, !dbg !342
  %25 = alloca float, i16 1, align 4, !dbg !343
  %26 = alloca float, i16 1, align 4, !dbg !344
  %27 = alloca i16, i16 1, align 2, !dbg !345
  %28 = alloca i16, i16 1, align 2, !dbg !346
  %29 = alloca i16, i16 1, align 2, !dbg !347
  %30 = alloca i16, i16 1, align 2, !dbg !348
  %31 = alloca i16, i16 1, align 2, !dbg !349
  %32 = alloca i16, i16 1, align 2, !dbg !350
  %33 = alloca i16, i16 1, align 2, !dbg !351
  %34 = alloca i16, i16 1, align 2, !dbg !352
  %35 = alloca i16, i16 1, align 2, !dbg !353
  %36 = alloca i16, i16 1, align 2, !dbg !354
  %37 = alloca i16, i16 1, align 2, !dbg !355
  store i16 %0, i16* %37, align 2, !dbg !355
  store i16 %1, i16* %36, align 2, !dbg !354
  store i16 %2, i16* %35, align 2, !dbg !353
  store i16 %3, i16* %34, align 2, !dbg !352
  store i16 %4, i16* %33, align 2, !dbg !351
  store i16 %5, i16* %32, align 2, !dbg !350
  store i16 %6, i16* %31, align 2, !dbg !349
  store i16 %7, i16* %30, align 2, !dbg !348
  store i16 %8, i16* %29, align 2, !dbg !347
  store i16 %9, i16* %28, align 2, !dbg !346
  store i16 %10, i16* %27, align 2, !dbg !345
  store float %11, float* %26, align 4, !dbg !344
  store float %12, float* %25, align 4, !dbg !343
  %38 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord(), !dbg !356
  store i16 %38, i16* %24, align 2, !dbg !342
  %39 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord(), !dbg !357
  store i16 %39, i16* %23, align 2, !dbg !341
  %40 = load i16, i16* %24, align 2, !dbg !358
  %41 = load i16, i16* %36, align 2, !dbg !359
  %42 = sub i16 %40, %41, !dbg !360
  store i16 %42, i16* %22, align 2, !dbg !340
  %43 = load i16, i16* %22, align 2, !dbg !361
  store i16 %43, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !362
  %44 = load i16, i16* %29, align 2, !dbg !363
  %45 = icmp eq i16 3, %44, !dbg !364
  br i1 %45, label %46, label %63, !dbg !365

46:                                               ; preds = %13
  %47 = load i16, i16* %22, align 2, !dbg !366
  %48 = sitofp i16 %47 to float, !dbg !367
  %49 = load float, float* %26, align 4, !dbg !368
  %50 = fmul float %48, %49, !dbg !369
  %51 = fptosi float %50 to i16, !dbg !370
  store i16 %51, i16* %21, align 2, !dbg !339
  %52 = load i16, i16* %22, align 2, !dbg !371
  %53 = load i16, i16* %21, align 2, !dbg !372
  %54 = load i16, i16* %28, align 2, !dbg !373
  %55 = mul i16 %53, %54, !dbg !374
  %56 = sub i16 %52, %55, !dbg !375
  store i16 %56, i16* %20, align 2, !dbg !338
  %57 = load i16, i16* %20, align 2, !dbg !376
  %58 = icmp ne i16 0, %57, !dbg !377
  br i1 %58, label %59, label %60, !dbg !378

59:                                               ; preds = %46
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !379
  br label %62, !dbg !378

60:                                               ; preds = %46
  %61 = load i16, i16* %21, align 2, !dbg !380
  store i16 %61, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !381
  br label %62, !dbg !378

62:                                               ; preds = %59, %60
  br label %63, !dbg !365

63:                                               ; preds = %62, %13
  %64 = load i16, i16* %22, align 2, !dbg !382
  %65 = icmp slt i16 %64, 0, !dbg !383
  br i1 %65, label %66, label %67, !dbg !384

66:                                               ; preds = %63
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !385
  br label %67, !dbg !384

67:                                               ; preds = %66, %63
  %68 = load i16, i16* %22, align 2, !dbg !386
  %69 = load i16, i16* %34, align 2, !dbg !387
  %70 = icmp sge i16 %68, %69, !dbg !388
  br i1 %70, label %71, label %72, !dbg !389

71:                                               ; preds = %67
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !390
  br label %72, !dbg !389

72:                                               ; preds = %71, %67
  store i1 false, i1* %19, align 1, !dbg !337
  %73 = load i16, i16* %29, align 2, !dbg !391
  %74 = icmp eq i16 3, %73, !dbg !392
  br i1 %74, label %75, label %94, !dbg !393

75:                                               ; preds = %72
  %76 = load i16, i16* %23, align 2, !dbg !394
  %77 = load i16, i16* %35, align 2, !dbg !395
  %78 = sub i16 %76, %77, !dbg !396
  %79 = sitofp i16 %78 to float, !dbg !397
  %80 = load float, float* %25, align 4, !dbg !398
  %81 = fmul float %79, %80, !dbg !399
  %82 = fptosi float %81 to i16, !dbg !400
  store i16 %82, i16* %18, align 2, !dbg !336
  %83 = load i16, i16* %23, align 2, !dbg !401
  %84 = load i16, i16* %35, align 2, !dbg !402
  %85 = sub i16 %83, %84, !dbg !403
  %86 = load i16, i16* %18, align 2, !dbg !404
  %87 = load i16, i16* %27, align 2, !dbg !405
  %88 = mul i16 %86, %87, !dbg !406
  %89 = sub i16 %85, %88, !dbg !407
  store i16 %89, i16* %17, align 2, !dbg !335
  %90 = load i16, i16* %17, align 2, !dbg !408
  %91 = icmp ne i16 0, %90, !dbg !409
  br i1 %91, label %92, label %93, !dbg !410

92:                                               ; preds = %75
  store i1 true, i1* %19, align 1, !dbg !411
  br label %93, !dbg !410

93:                                               ; preds = %92, %75
  br label %94, !dbg !393

94:                                               ; preds = %93, %72
  %95 = load i16, i16* %23, align 2, !dbg !412
  %96 = load i16, i16* %35, align 2, !dbg !413
  %97 = icmp slt i16 %95, %96, !dbg !414
  br i1 %97, label %98, label %99, !dbg !415

98:                                               ; preds = %94
  store i1 true, i1* %19, align 1, !dbg !416
  br label %99, !dbg !415

99:                                               ; preds = %98, %94
  %100 = load i16, i16* %23, align 2, !dbg !417
  %101 = load i16, i16* %35, align 2, !dbg !418
  %102 = load i16, i16* %33, align 2, !dbg !419
  %103 = add i16 %101, %102, !dbg !420
  %104 = icmp sge i16 %100, %103, !dbg !421
  br i1 %104, label %105, label %106, !dbg !422

105:                                              ; preds = %99
  store i1 true, i1* %19, align 1, !dbg !423
  br label %106, !dbg !422

106:                                              ; preds = %105, %99
  %107 = load i1, i1* %19, align 1, !dbg !424
  br i1 %107, label %108, label %109, !dbg !425

108:                                              ; preds = %106
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream(), !dbg !426
  call void @llvm.sdr.ublk.r(i16 27), !dbg !427
  br label %180, !dbg !425

109:                                              ; preds = %106
  %110 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !428
  %111 = icmp eq i16 -1, %110, !dbg !429
  br i1 %111, label %112, label %113, !dbg !430

112:                                              ; preds = %109
  call void @__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction(i16 31767), !dbg !431
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 23), !dbg !432
  call void @llvm.sdr.ublk.r(i16 27), !dbg !433
  br label %179, !dbg !430

113:                                              ; preds = %109
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter(i16 0, i16 0), !dbg !434
  %114 = load i16, i16* %34, align 2, !dbg !435
  store i16 %114, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !436
  %115 = load i16, i16* %29, align 2, !dbg !437
  %116 = icmp eq i16 3, %115, !dbg !438
  br i1 %116, label %117, label %126, !dbg !439

117:                                              ; preds = %113
  %118 = load i16, i16* %34, align 2, !dbg !440
  %119 = sub i16 %118, 1, !dbg !441
  %120 = sitofp i16 %119 to float, !dbg !442
  %121 = load float, float* %26, align 4, !dbg !443
  %122 = fmul float %120, %121, !dbg !444
  %123 = fptosi float %122 to i16, !dbg !445
  %124 = add i16 %123, 1, !dbg !446
  store i16 %124, i16* %16, align 2, !dbg !334
  %125 = load i16, i16* %16, align 2, !dbg !447
  store i16 %125, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !448
  br label %131, !dbg !439

126:                                              ; preds = %113
  %127 = load i16, i16* %29, align 2, !dbg !449
  %128 = icmp eq i16 1, %127, !dbg !450
  br i1 %128, label %129, label %130, !dbg !451

129:                                              ; preds = %126
  store i16 1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !452
  br label %130, !dbg !451

130:                                              ; preds = %129, %126
  br label %131, !dbg !439

131:                                              ; preds = %117, %130
  %132 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !453
  %133 = sub i16 %132, 1, !dbg !454
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit(i16 0, i16 %133), !dbg !455
  %134 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !456
  store i16 %134, i16* %15, align 2, !dbg !333
  %135 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !457
  store i16 %135, i16* %14, align 2, !dbg !331
  %136 = load i16, i16* %15, align 2, !dbg !458
  %137 = load i16, i16* %14, align 2, !dbg !459
  %138 = sub i16 %136, %137, !dbg !460
  store i16 %138, i16* %15, align 2, !dbg !461
  %139 = load i16, i16* %14, align 2, !dbg !462
  %140 = icmp eq i16 0, %139, !dbg !463
  br i1 %140, label %141, label %142, !dbg !464

141:                                              ; preds = %131
  store i16 0, i16* %15, align 2, !dbg !465
  br label %142, !dbg !464

142:                                              ; preds = %141, %131
  %143 = load i16, i16* %29, align 2, !dbg !466
  %144 = icmp eq i16 1, %143, !dbg !467
  br i1 %144, label %145, label %146, !dbg !468

145:                                              ; preds = %142
  store i16 0, i16* %15, align 2, !dbg !469
  br label %146, !dbg !468

146:                                              ; preds = %145, %142
  %147 = load i16, i16* %15, align 2, !dbg !470
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter(i16 0, i16 %147), !dbg !471
  call void @__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction(i16 31767), !dbg !472
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 23), !dbg !473
  %148 = load i16, i16* %37, align 2, !dbg !474
  %149 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval(i16 %148), !dbg !475
  %150 = icmp eq i16 0, %149, !dbg !476
  br i1 %150, label %151, label %155, !dbg !477

151:                                              ; preds = %146
  %152 = load i16, i16* %32, align 2, !dbg !478
  %153 = load i16, i16* %31, align 2, !dbg !479
  %154 = load i16, i16* %30, align 2, !dbg !480
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start(i16 %152, i16 %153, i16 %154), !dbg !481
  br label %178, !dbg !477

155:                                              ; preds = %146
  %156 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !482
  %157 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !482
  %158 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !482
  %159 = load i16, i16* %31, align 2, !dbg !483
  store i16 %159, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !484
  store i16 %156, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !484
  store i16 %157, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !484
  store i16 %158, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !484
  %160 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !485
  %161 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !485
  %162 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !485
  %163 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !485
  %164 = and i16 %162, -193, !dbg !485
  %165 = or i16 %164, 128, !dbg !485
  store volatile i16 %160, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !486
  store volatile i16 %161, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !486
  store volatile i16 %165, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !486
  store volatile i16 %163, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !486
  call void asm sideeffect "nop", ""(), !dbg !486
  call void asm sideeffect "nop", ""(), !dbg !486
  %166 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !487
  %167 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !487
  %168 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !487
  %169 = load i16, i16* %31, align 2, !dbg !488
  store i16 %169, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !489
  store i16 %166, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !489
  store i16 %167, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !489
  store i16 %168, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !489
  %170 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !490
  %171 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !490
  %172 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !490
  %173 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !490
  %174 = and i16 %172, -193, !dbg !490
  %175 = or i16 %174, 128, !dbg !490
  %176 = and i16 %171, -64, !dbg !490
  %177 = or i16 %176, 27, !dbg !490
  store volatile i16 %170, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !491
  store volatile i16 %177, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !491
  store volatile i16 %175, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !491
  store volatile i16 %173, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !491
  call void asm sideeffect "nop", ""(), !dbg !491
  call void asm sideeffect "nop", ""(), !dbg !491
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !492
  br label %178, !dbg !477

178:                                              ; preds = %151, %155
  br label %179, !dbg !430

179:                                              ; preds = %112, %178
  br label %180, !dbg !425

180:                                              ; preds = %108, %179
  ret void, !dbg !365
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit(i16 %0, i16 %1) !dbg !493 {
  %3 = alloca i16, i16 1, align 2, !dbg !495
  %4 = alloca i16, i16 1, align 2, !dbg !497
  %5 = alloca i16, i16 1, align 2, !dbg !498
  %6 = alloca i16, i16 1, align 2, !dbg !499
  %7 = alloca i16, i16 1, align 2, !dbg !500
  %8 = alloca i16, i16 1, align 2, !dbg !501
  store i16 %0, i16* %8, align 2, !dbg !501
  store i16 %1, i16* %7, align 2, !dbg !500
  %9 = load i16, i16* %7, align 2, !dbg !502
  %10 = icmp ult i16 %9, -32768, !dbg !503
  br i1 %10, label %11, label %12, !dbg !504

11:                                               ; preds = %2
  br label %13, !dbg !504

12:                                               ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !504
  br label %13, !dbg !504

13:                                               ; preds = %11, %12
  %14 = load i16, i16* %7, align 2, !dbg !505
  %15 = mul i16 %14, 2, !dbg !506
  store i16 %15, i16* %6, align 2, !dbg !499
  %16 = load i16, i16* %8, align 2, !dbg !507
  %17 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %16, i16 8), !dbg !508
  %18 = sub i16 %17, 1, !dbg !509
  store i16 %18, i16* %5, align 2, !dbg !498
  %19 = load i16, i16* %6, align 2, !dbg !510
  %20 = load i16, i16* %5, align 2, !dbg !511
  %21 = icmp ult i16 %19, %20, !dbg !512
  br i1 %21, label %22, label %23, !dbg !497

22:                                               ; preds = %13
  store i16 0, i16* %4, align 2, !dbg !497
  br label %27, !dbg !497

23:                                               ; preds = %13
  %24 = load i16, i16* %6, align 2, !dbg !513
  %25 = load i16, i16* %5, align 2, !dbg !514
  %26 = sub i16 %24, %25, !dbg !515
  store i16 %26, i16* %4, align 2, !dbg !497
  br label %27, !dbg !497

27:                                               ; preds = %22, %23
  %28 = load i16, i16* %4, align 2, !dbg !497
  store i16 %28, i16* %3, align 2, !dbg !495
  %29 = load i16, i16* %8, align 2, !dbg !516
  %30 = load i16, i16* %3, align 2, !dbg !517
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %29, i16 4, i16 %30), !dbg !518
  ret void, !dbg !497
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter(i16 %0, i16 %1) !dbg !519 {
  %3 = alloca i16, i16 1, align 2, !dbg !520
  %4 = alloca i16, i16 1, align 2, !dbg !522
  store i16 %0, i16* %4, align 2, !dbg !522
  store i16 %1, i16* %3, align 2, !dbg !520
  %5 = load i16, i16* %3, align 2, !dbg !523
  %6 = icmp ult i16 %5, -32768, !dbg !524
  br i1 %6, label %7, label %8, !dbg !525

7:                                                ; preds = %2
  br label %9, !dbg !525

8:                                                ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !525
  br label %9, !dbg !525

9:                                                ; preds = %7, %8
  %10 = load i16, i16* %4, align 2, !dbg !526
  %11 = load i16, i16* %3, align 2, !dbg !527
  %12 = mul i16 %11, 2, !dbg !528
  %13 = add i16 %12, 1, !dbg !529
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %10, i16 8, i16 %13), !dbg !530
  ret void, !dbg !531
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter(i16 %0, i16 %1) !dbg !532 {
  %3 = alloca i16, i16 1, align 2, !dbg !533
  %4 = alloca i16, i16 1, align 2, !dbg !535
  %5 = alloca i1, i16 1, align 1, !dbg !536
  %6 = alloca i16, i16 1, align 2, !dbg !537
  %7 = alloca i16, i16 1, align 2, !dbg !538
  %8 = alloca i16, i16 1, align 2, !dbg !539
  %9 = alloca i16, i16 1, align 2, !dbg !540
  store i16 %0, i16* %9, align 2, !dbg !540
  store i16 %1, i16* %8, align 2, !dbg !539
  %10 = load i16, i16* %8, align 2, !dbg !541
  %11 = icmp ult i16 %10, -32768, !dbg !542
  br i1 %11, label %12, label %13, !dbg !543

12:                                               ; preds = %2
  br label %14, !dbg !543

13:                                               ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !543
  br label %14, !dbg !543

14:                                               ; preds = %12, %13
  %15 = load i16, i16* %9, align 2, !dbg !544
  %16 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %15, i16 8), !dbg !545
  store i16 %16, i16* %7, align 2, !dbg !538
  %17 = load i16, i16* %8, align 2, !dbg !546
  %18 = mul i16 %17, 2, !dbg !547
  store i16 %18, i16* %6, align 2, !dbg !537
  %19 = load i16, i16* %6, align 2, !dbg !548
  %20 = load i16, i16* %7, align 2, !dbg !549
  %21 = icmp ugt i16 %19, %20, !dbg !550
  store i1 %21, i1* %5, align 1, !dbg !536
  %22 = load i16, i16* %9, align 2, !dbg !551
  %23 = load i1, i1* %5, align 1, !dbg !552
  %24 = zext i1 %23 to i16, !dbg !553
  %25 = shl i16 %24, 6, !dbg !554
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %22, i16 14, i16 %25), !dbg !555
  %26 = load i1, i1* %5, align 1, !dbg !556
  br i1 %26, label %27, label %32, !dbg !535

27:                                               ; preds = %14
  %28 = load i16, i16* %6, align 2, !dbg !557
  %29 = load i16, i16* %7, align 2, !dbg !558
  %30 = sub i16 %28, %29, !dbg !559
  %31 = add i16 %30, 1, !dbg !560
  store i16 %31, i16* %4, align 2, !dbg !535
  br label %34, !dbg !535

32:                                               ; preds = %14
  %33 = load i16, i16* %6, align 2, !dbg !561
  store i16 %33, i16* %4, align 2, !dbg !535
  br label %34, !dbg !535

34:                                               ; preds = %27, %32
  %35 = load i16, i16* %4, align 2, !dbg !535
  store i16 %35, i16* %3, align 2, !dbg !533
  %36 = load i16, i16* %9, align 2, !dbg !562
  %37 = load i16, i16* %3, align 2, !dbg !563
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %36, i16 12, i16 %37), !dbg !564
  ret void, !dbg !535
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %0, i16 %1, i16 %2) !dbg !565 {
  %4 = alloca i16, i16 1, align 2, !dbg !567
  %5 = alloca i16, i16 1, align 2, !dbg !569
  %6 = alloca i16, i16 1, align 2, !dbg !570
  store i16 %0, i16* %6, align 2, !dbg !570
  store i16 %1, i16* %5, align 2, !dbg !569
  store i16 %2, i16* %4, align 2, !dbg !567
  %7 = load i16, i16* %6, align 2, !dbg !571
  %8 = getelementptr [6 x i16], [6 x i16]* @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.filters, i16 0, i16 %7, !dbg !572
  %9 = load i16, i16* %8, align 2, !dbg !572
  %10 = load i16, i16* %5, align 2, !dbg !573
  %11 = add i16 %9, %10, !dbg !574
  %12 = lshr i16 %11, 1, !dbg !575
  %13 = load i16, i16* %4, align 2, !dbg !576
  %14 = shl i16 %12, 1, !dbg !577
  %15 = inttoptr i16 %14 to i16*, !dbg !577
  store volatile i16 %13, i16* %15, align 2, !dbg !577
  call void asm sideeffect "nop", ""(), !dbg !577
  call void asm sideeffect "nop", ""(), !dbg !577
  ret void, !dbg !578
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %0, i16 %1) !dbg !579 {
  %3 = alloca i16, i16 1, align 2, !dbg !580
  %4 = alloca i16, i16 1, align 2, !dbg !582
  store i16 %0, i16* %4, align 2, !dbg !582
  store i16 %1, i16* %3, align 2, !dbg !580
  %5 = load i16, i16* %4, align 2, !dbg !583
  %6 = getelementptr [6 x i16], [6 x i16]* @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.filters, i16 0, i16 %5, !dbg !584
  %7 = load i16, i16* %6, align 2, !dbg !584
  %8 = load i16, i16* %3, align 2, !dbg !585
  %9 = add i16 %7, %8, !dbg !586
  %10 = lshr i16 %9, 1, !dbg !587
  %11 = shl i16 %10, 1, !dbg !588
  %12 = inttoptr i16 %11 to i16*, !dbg !588
  call void asm sideeffect "nop", ""(), !dbg !588
  call void asm sideeffect "nop", ""(), !dbg !588
  %13 = load volatile i16, i16* %12, align 2, !dbg !588
  ret i16 %13, !dbg !589
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 %0) !dbg !590 {
  %2 = alloca i16, i16 1, align 2, !dbg !592
  %3 = alloca i16, i16 1, align 2, !dbg !594
  %4 = alloca i16, i16 1, align 2, !dbg !595
  %5 = alloca i16, i16 1, align 2, !dbg !596
  store i16 %0, i16* %5, align 2, !dbg !596
  %6 = load i16, i16* %5, align 2, !dbg !597
  store i16 %6, i16* %4, align 2, !dbg !595
  %7 = load i16, i16* %4, align 2, !dbg !598
  %8 = add i16 %7, 31744, !dbg !599
  store i16 %8, i16* %3, align 2, !dbg !594
  %9 = load i16, i16* %3, align 2, !dbg !600
  %10 = shl i16 %9, 1, !dbg !601
  %11 = inttoptr i16 %10 to i16*, !dbg !601
  call void asm sideeffect "nop", ""(), !dbg !601
  call void asm sideeffect "nop", ""(), !dbg !601
  %12 = load volatile i16, i16* %11, align 2, !dbg !601
  store i16 %12, i16* %2, align 2, !dbg !592
  %13 = load i16, i16* %3, align 2, !dbg !602
  %14 = load i16, i16* %2, align 2, !dbg !603
  %15 = and i16 %14, 32767, !dbg !604
  %16 = shl i16 %13, 1, !dbg !605
  %17 = inttoptr i16 %16 to i16*, !dbg !605
  store volatile i16 %15, i16* %17, align 2, !dbg !605
  call void asm sideeffect "nop", ""(), !dbg !605
  call void asm sideeffect "nop", ""(), !dbg !605
  ret void, !dbg !606
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord() !dbg !607 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 2), !dbg !609
  %2 = sub i16 %1, 4, !dbg !611
  ret i16 %2, !dbg !612
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord() !dbg !613 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 0), !dbg !614
  %2 = sub i16 %1, 1, !dbg !616
  ret i16 %2, !dbg !617
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 %0) !dbg !618 {
  %2 = alloca i16, i16 1, align 2, !dbg !620
  %3 = alloca i16, i16 1, align 2, !dbg !622
  store i16 %0, i16* %3, align 2, !dbg !622
  %4 = load i16, i16* %3, align 2, !dbg !623
  %5 = lshr i16 %4, 1, !dbg !624
  %6 = add i16 %5, 31813, !dbg !625
  %7 = shl i16 %6, 1, !dbg !626
  %8 = inttoptr i16 %7 to i16*, !dbg !626
  call void asm sideeffect "nop", ""(), !dbg !626
  call void asm sideeffect "nop", ""(), !dbg !626
  %9 = load volatile i16, i16* %8, align 2, !dbg !626
  store i16 %9, i16* %2, align 2, !dbg !620
  %10 = load i16, i16* %2, align 2, !dbg !627
  %11 = and i16 %10, 2047, !dbg !628
  ret i16 %11, !dbg !629
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord() !dbg !630 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord(), !dbg !632
  ret i16 %1, !dbg !634
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.get_y_coord() !dbg !635 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord(), !dbg !636
  ret i16 %1, !dbg !638
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval(i16 %0) !dbg !639 {
  %2 = alloca i16, i16 1, align 2, !dbg !640
  store i16 %0, i16* %2, align 2, !dbg !640
  %3 = load i16, i16* %2, align 2, !dbg !642
  %4 = icmp ult i16 %3, 24, !dbg !643
  br i1 %4, label %5, label %7, !dbg !644

5:                                                ; preds = %10, %11, %1
  %6 = phi i16 [ 0, %10 ], [ 0, %11 ], [ 1, %1 ]
  br label %12, !dbg !644

7:                                                ; preds = %1
  %8 = load i16, i16* %2, align 2, !dbg !645
  %9 = icmp eq i16 31, %8, !dbg !646
  br i1 %9, label %10, label %11, !dbg !647

10:                                               ; preds = %7
  br label %5, !dbg !647

11:                                               ; preds = %7
  call void asm sideeffect "hcf", ""(), !dbg !647
  br label %5, !dbg !647

12:                                               ; preds = %5
  %13 = phi i16 [ %6, %5 ]
  br label %14, !dbg !644

14:                                               ; preds = %12
  ret i16 %13, !dbg !644
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7) !dbg !648 {
  %9 = alloca i16, i16 1, align 2, !dbg !649
  %10 = alloca i16, i16 1, align 2, !dbg !651
  %11 = alloca i16, i16 1, align 2, !dbg !652
  %12 = alloca i16, i16 1, align 2, !dbg !653
  %13 = alloca i16, i16 1, align 2, !dbg !654
  %14 = alloca i16, i16 1, align 2, !dbg !655
  %15 = alloca i16, i16 1, align 2, !dbg !656
  %16 = alloca i16, i16 1, align 2, !dbg !657
  %17 = alloca i16, i16 1, align 2, !dbg !658
  store i16 %0, i16* %17, align 2, !dbg !658
  store i16 %1, i16* %16, align 2, !dbg !657
  store i16 %2, i16* %15, align 2, !dbg !656
  store i16 %3, i16* %14, align 2, !dbg !655
  store i16 %4, i16* %13, align 2, !dbg !654
  store i16 %5, i16* %12, align 2, !dbg !653
  store i16 %6, i16* %11, align 2, !dbg !652
  store i16 %7, i16* %10, align 2, !dbg !651
  %18 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !659
  store i16 %18, i16* %9, align 2, !dbg !649
  %19 = load i16, i16* %11, align 2, !dbg !660
  store i16 %19, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_c, align 2, !dbg !661
  %20 = load i16, i16* %10, align 2, !dbg !662
  store i16 %20, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_is_half, align 2, !dbg !663
  %21 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_c, align 2, !dbg !664
  %22 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval(i16 %21), !dbg !665
  store i16 %22, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !666
  store i16 0, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !667
  %23 = load i16, i16* %16, align 2, !dbg !668
  store i16 %23, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !669
  %24 = load i16, i16* %15, align 2, !dbg !670
  store i16 %24, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !671
  %25 = load i16, i16* %15, align 2, !dbg !672
  %26 = load i16, i16* %13, align 2, !dbg !673
  %27 = add i16 %25, %26, !dbg !674
  %28 = sub i16 %27, 1, !dbg !675
  store i16 %28, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_last, align 2, !dbg !676
  %29 = load i16, i16* %9, align 2, !dbg !677
  %30 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_last, align 2, !dbg !678
  %31 = icmp eq i16 %29, %30, !dbg !679
  br i1 %31, label %32, label %37, !dbg !680

32:                                               ; preds = %8
  %33 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !681
  %34 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !681
  %35 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !681
  store i16 %33, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !682
  store i16 lshr (i16 ptrtoint ([1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.ctrl_1 to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !682
  store i16 %34, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !682
  store i16 %35, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !682
  %36 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.ctrl_1, i16 0, i1 false), align 4, !dbg !683
  store i32 %36, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i1 false), align 4, !dbg !684
  br label %42, !dbg !680

37:                                               ; preds = %8
  %38 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !685
  %39 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !685
  %40 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !685
  store i16 %38, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !686
  store i16 lshr (i16 ptrtoint ([1 x i32]* @"$$csl_base_address$$0$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11" to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !686
  store i16 %39, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !686
  store i16 %40, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !686
  %41 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @"$$csl_base_address$$0$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11", i16 0, i1 false), align 4, !dbg !687
  store i32 %41, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i1 false), align 4, !dbg !688
  br label %42, !dbg !680

42:                                               ; preds = %32, %37
  store i32 165646921, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i2 1), align 4, !dbg !689
  %43 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !690
  %44 = icmp eq i16 0, %43, !dbg !691
  br i1 %44, label %45, label %56, !dbg !692

45:                                               ; preds = %42
  %46 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !693
  %47 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !693
  %48 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !693
  %49 = load i16, i16* %17, align 2, !dbg !694
  %50 = call i16* @.get_tensor_ptr(i16 %49), !dbg !695
  %51 = ptrtoint i16* %50 to i16, !dbg !696
  %52 = lshr i16 %51, 1, !dbg !696
  store i16 %46, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !697
  store i16 %52, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !697
  store i16 %47, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !697
  store i16 %48, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !697
  %53 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !698
  %54 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !698
  %55 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !698
  store i16 1, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !699
  store i16 %53, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !699
  store i16 %54, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !699
  store i16 %55, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !699
  call void @llvm.sdr.actvt.r(i16 21), !dbg !700
  br label %63, !dbg !692

56:                                               ; preds = %42
  %57 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !701
  %58 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !701
  %59 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !701
  store i16 %57, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !702
  store i16 lshr (i16 ptrtoint ([1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.data_buf to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !702
  store i16 %58, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !702
  store i16 %59, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !702
  %60 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !703
  %61 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !703
  %62 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !703
  store i16 1, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !704
  store i16 %60, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !704
  store i16 %61, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !704
  store i16 %62, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !704
  call void @llvm.sdr.ublk.r(i16 0), !dbg !705
  br label %63, !dbg !692

63:                                               ; preds = %45, %56
  ret void, !dbg !680
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x(i32 %0) #8 !dbg !706 {
  %2 = alloca i32, i16 1, align 4, !dbg !707
  store i32 %0, i32* %2, align 4, !dbg !707
  call void @llvm.sdr.blk.r(i16 0), !dbg !709
  %3 = load i32, i32* %2, align 4, !dbg !710
  store i32 %3, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.data_buf, i16 0, i1 false), align 4, !dbg !711
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !712
  %4 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !713
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !713
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !713
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !713
  store volatile i16 %4, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !714
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !714
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !714
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !714
  call void asm sideeffect "nop", ""(), !dbg !714
  call void asm sideeffect "nop", ""(), !dbg !714
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !715
  %8 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !716
  %9 = add i16 %8, 1, !dbg !717
  store i16 %9, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !718
  ret void, !dbg !719
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_send_data() #9 !dbg !720 {
  %1 = alloca i16, i16 1, align 2, !dbg !721
  %2 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !723
  %3 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !724
  %4 = icmp ult i16 %2, %3, !dbg !725
  br i1 %4, label %5, label %27, !dbg !726

5:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !727
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !728
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !728
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !728
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !728
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !729
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !729
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !729
  store volatile i16 %9, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !729
  call void asm sideeffect "nop", ""(), !dbg !729
  call void asm sideeffect "nop", ""(), !dbg !729
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_is_half, align 2, !dbg !730
  %11 = icmp ult i16 0, %10, !dbg !731
  br i1 %11, label %12, label %18, !dbg !732

12:                                               ; preds = %5
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !733
  %13 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !734
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !734
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !734
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !734
  %17 = add i16 %14, 1, !dbg !735
  store i16 %13, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !736
  store i16 %17, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !736
  store i16 %15, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !736
  store i16 %16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !736
  br label %24, !dbg !732

18:                                               ; preds = %5
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !737
  %19 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !738
  %20 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !738
  %21 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !738
  %22 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !738
  %23 = add i16 %20, 2, !dbg !739
  store i16 %19, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !740
  store i16 %23, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !740
  store i16 %21, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !740
  store i16 %22, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !740
  br label %24, !dbg !732

24:                                               ; preds = %12, %18
  %25 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !741
  %26 = add i16 %25, 1, !dbg !742
  store i16 %26, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !743
  br label %34, !dbg !726

27:                                               ; preds = %0
  %28 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !744
  store i16 %28, i16* %1, align 2, !dbg !721
  %29 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !745
  %30 = load i16, i16* %1, align 2, !dbg !746
  %31 = icmp eq i16 %29, %30, !dbg !747
  br i1 %31, label %32, label %33, !dbg !748

32:                                               ; preds = %27
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !749
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__1 to i8*)), !dbg !750
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !751
  br label %33, !dbg !748

33:                                               ; preds = %32, %27
  br label %34, !dbg !726

34:                                               ; preds = %24, %33
  ret void, !dbg !726
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl() #10 !dbg !752 {
  %1 = alloca i16, i16 1, align 2, !dbg !753
  %2 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !755
  %3 = icmp eq i16 0, %2, !dbg !756
  br i1 %3, label %4, label %9, !dbg !757

4:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__2 to i8*)), !dbg !758
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !759
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !759
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !759
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !759
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !760
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !760
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !760
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !760
  call void asm sideeffect "nop", ""(), !dbg !760
  call void asm sideeffect "nop", ""(), !dbg !760
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !761
  br label %31, !dbg !757

9:                                                ; preds = %0
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !762
  %11 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !763
  %12 = icmp ult i16 %10, %11, !dbg !764
  br i1 %12, label %13, label %18, !dbg !765

13:                                               ; preds = %9
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__3 to i8*)), !dbg !766
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !767
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !767
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !767
  %17 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !767
  store volatile i16 %14, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !768
  store volatile i16 %15, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !768
  store volatile i16 %16, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !768
  store volatile i16 %17, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !768
  call void asm sideeffect "nop", ""(), !dbg !768
  call void asm sideeffect "nop", ""(), !dbg !768
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !769
  br label %30, !dbg !765

18:                                               ; preds = %9
  %19 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !770
  store i16 %19, i16* %1, align 2, !dbg !753
  %20 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !771
  %21 = load i16, i16* %1, align 2, !dbg !772
  %22 = icmp eq i16 %20, %21, !dbg !773
  br i1 %22, label %23, label %24, !dbg !774

23:                                               ; preds = %18
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__4 to i8*)), !dbg !775
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__5 to i8*)), !dbg !776
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !777
  br label %29, !dbg !774

24:                                               ; preds = %18
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !778
  %25 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !779
  %26 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !779
  %27 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !779
  %28 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !779
  store volatile i16 %25, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !780
  store volatile i16 %26, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !780
  store volatile i16 %27, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !780
  store volatile i16 %28, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !780
  call void asm sideeffect "nop", ""(), !dbg !780
  call void asm sideeffect "nop", ""(), !dbg !780
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !781
  br label %29, !dbg !774

29:                                               ; preds = %23, %24
  br label %30, !dbg !765

30:                                               ; preds = %13, %29
  br label %31, !dbg !757

31:                                               ; preds = %4, %30
  ret void, !dbg !757
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.d2h_configure(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7) !dbg !782 {
  %9 = alloca i1, i16 1, align 1, !dbg !783
  %10 = alloca i1, i16 1, align 1, !dbg !785
  %11 = alloca i1, i16 1, align 1, !dbg !786
  %12 = alloca i16, i16 1, align 2, !dbg !787
  %13 = alloca i16, i16 1, align 2, !dbg !788
  %14 = alloca i16, i16 1, align 2, !dbg !789
  %15 = alloca i16, i16 1, align 2, !dbg !790
  %16 = alloca i16, i16 1, align 2, !dbg !791
  %17 = alloca i16, i16 1, align 2, !dbg !792
  %18 = alloca i16, i16 1, align 2, !dbg !793
  %19 = alloca i16, i16 1, align 2, !dbg !794
  %20 = alloca i16, i16 1, align 2, !dbg !795
  %21 = alloca i16, i16 1, align 2, !dbg !796
  %22 = alloca i16, i16 1, align 2, !dbg !797
  %23 = alloca i16, i16 1, align 2, !dbg !798
  %24 = alloca i16, i16 1, align 2, !dbg !799
  %25 = alloca i16, i16 1, align 2, !dbg !800
  store i16 %0, i16* %25, align 2, !dbg !800
  store i16 %1, i16* %24, align 2, !dbg !799
  store i16 %2, i16* %23, align 2, !dbg !798
  store i16 %3, i16* %22, align 2, !dbg !797
  store i16 %4, i16* %21, align 2, !dbg !796
  store i16 %5, i16* %20, align 2, !dbg !795
  store i16 %6, i16* %19, align 2, !dbg !794
  store i16 %7, i16* %18, align 2, !dbg !793
  %26 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !801
  store i16 %26, i16* %17, align 2, !dbg !792
  %27 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_y_coord(), !dbg !802
  store i16 %27, i16* %16, align 2, !dbg !791
  %28 = load i16, i16* %24, align 2, !dbg !803
  store i16 %28, i16* %15, align 2, !dbg !790
  %29 = load i16, i16* %24, align 2, !dbg !804
  %30 = load i16, i16* %22, align 2, !dbg !805
  %31 = add i16 %29, %30, !dbg !806
  %32 = sub i16 %31, 1, !dbg !807
  store i16 %32, i16* %14, align 2, !dbg !789
  %33 = load i16, i16* %23, align 2, !dbg !808
  store i16 %33, i16* %13, align 2, !dbg !788
  %34 = load i16, i16* %23, align 2, !dbg !809
  %35 = load i16, i16* %21, align 2, !dbg !810
  %36 = add i16 %34, %35, !dbg !811
  %37 = sub i16 %36, 1, !dbg !812
  store i16 %37, i16* %12, align 2, !dbg !787
  store i1 false, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !813
  %38 = load i16, i16* %17, align 2, !dbg !814
  %39 = load i16, i16* %15, align 2, !dbg !815
  %40 = icmp sge i16 %38, %39, !dbg !816
  br i1 %40, label %41, label %45, !dbg !786

41:                                               ; preds = %8
  %42 = load i16, i16* %16, align 2, !dbg !817
  %43 = load i16, i16* %12, align 2, !dbg !818
  %44 = icmp sle i16 %42, %43, !dbg !819
  store i1 %44, i1* %11, align 1, !dbg !786
  br label %46, !dbg !786

45:                                               ; preds = %8
  store i1 false, i1* %11, align 1, !dbg !786
  br label %46, !dbg !786

46:                                               ; preds = %41, %45
  %47 = load i1, i1* %11, align 1, !dbg !786
  br i1 %47, label %48, label %52, !dbg !785

48:                                               ; preds = %46
  %49 = load i16, i16* %16, align 2, !dbg !820
  %50 = load i16, i16* %13, align 2, !dbg !821
  %51 = icmp sge i16 %49, %50, !dbg !822
  store i1 %51, i1* %10, align 1, !dbg !785
  br label %53, !dbg !785

52:                                               ; preds = %46
  store i1 false, i1* %10, align 1, !dbg !785
  br label %53, !dbg !785

53:                                               ; preds = %48, %52
  %54 = load i1, i1* %10, align 1, !dbg !785
  br i1 %54, label %55, label %56, !dbg !823

55:                                               ; preds = %53
  store i1 true, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !824
  br label %56, !dbg !823

56:                                               ; preds = %55, %53
  store i1 false, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !825
  %57 = load i16, i16* %17, align 2, !dbg !826
  %58 = load i16, i16* %14, align 2, !dbg !827
  %59 = icmp sle i16 %57, %58, !dbg !828
  br i1 %59, label %60, label %62, !dbg !783

60:                                               ; preds = %56
  %61 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !829
  store i1 %61, i1* %9, align 1, !dbg !783
  br label %63, !dbg !783

62:                                               ; preds = %56
  store i1 false, i1* %9, align 1, !dbg !783
  br label %63, !dbg !783

63:                                               ; preds = %60, %62
  %64 = load i1, i1* %9, align 1, !dbg !783
  br i1 %64, label %65, label %66, !dbg !830

65:                                               ; preds = %63
  store i1 true, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !831
  br label %66, !dbg !830

66:                                               ; preds = %65, %63
  %67 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !832
  br i1 %67, label %68, label %86, !dbg !833

68:                                               ; preds = %66
  call void @__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position(i16 31959), !dbg !834
  %69 = load i16, i16* %15, align 2, !dbg !835
  %70 = load i16, i16* %17, align 2, !dbg !836
  %71 = icmp eq i16 %69, %70, !dbg !837
  br i1 %71, label %72, label %73, !dbg !838

72:                                               ; preds = %68
  call void @__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 31765), !dbg !839
  br label %74, !dbg !838

73:                                               ; preds = %68
  call void @__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 31765), !dbg !840
  br label %74, !dbg !838

74:                                               ; preds = %72, %73
  call void @sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit(i16 21), !dbg !841
  %75 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !842
  br i1 %75, label %76, label %85, !dbg !843

76:                                               ; preds = %74
  %77 = load i16, i16* %20, align 2, !dbg !844
  %78 = load i16, i16* %19, align 2, !dbg !845
  %79 = load i16, i16* %24, align 2, !dbg !846
  %80 = load i16, i16* %23, align 2, !dbg !847
  %81 = load i16, i16* %22, align 2, !dbg !848
  %82 = load i16, i16* %21, align 2, !dbg !849
  %83 = load i16, i16* %25, align 2, !dbg !850
  %84 = load i16, i16* %18, align 2, !dbg !851
  call void @sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start(i16 %77, i16 %78, i16 %79, i16 %80, i16 %81, i16 %82, i16 %83, i16 %84), !dbg !852
  br label %85, !dbg !843

85:                                               ; preds = %76, %74
  br label %87, !dbg !833

86:                                               ; preds = %66
  call void @llvm.sdr.actvt.r(i16 28), !dbg !853
  br label %87, !dbg !833

87:                                               ; preds = %85, %86
  ret void, !dbg !786
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit(i16 %0) !dbg !854 {
  %2 = alloca i16, i16 1, align 2, !dbg !855
  %3 = alloca i16, i16 1, align 2, !dbg !857
  %4 = alloca i16, i16 1, align 2, !dbg !858
  %5 = alloca i16, i16 1, align 2, !dbg !859
  store i16 %0, i16* %5, align 2, !dbg !859
  %6 = load i16, i16* %5, align 2, !dbg !860
  store i16 %6, i16* %4, align 2, !dbg !858
  %7 = load i16, i16* %4, align 2, !dbg !861
  %8 = add i16 %7, 31744, !dbg !862
  store i16 %8, i16* %3, align 2, !dbg !857
  %9 = load i16, i16* %3, align 2, !dbg !863
  %10 = shl i16 %9, 1, !dbg !864
  %11 = inttoptr i16 %10 to i16*, !dbg !864
  call void asm sideeffect "nop", ""(), !dbg !864
  call void asm sideeffect "nop", ""(), !dbg !864
  %12 = load volatile i16, i16* %11, align 2, !dbg !864
  store i16 %12, i16* %2, align 2, !dbg !855
  %13 = load i16, i16* %3, align 2, !dbg !865
  %14 = load i16, i16* %2, align 2, !dbg !866
  %15 = and i16 %14, 32767, !dbg !867
  %16 = shl i16 %13, 1, !dbg !868
  %17 = inttoptr i16 %16 to i16*, !dbg !868
  store volatile i16 %15, i16* %17, align 2, !dbg !868
  call void asm sideeffect "nop", ""(), !dbg !868
  call void asm sideeffect "nop", ""(), !dbg !868
  ret void, !dbg !869
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord() !dbg !870 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 2), !dbg !871
  %2 = sub i16 %1, 4, !dbg !873
  ret i16 %2, !dbg !874
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord() !dbg !875 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 0), !dbg !876
  %2 = sub i16 %1, 1, !dbg !878
  ret i16 %2, !dbg !879
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 %0) !dbg !880 {
  %2 = alloca i16, i16 1, align 2, !dbg !881
  %3 = alloca i16, i16 1, align 2, !dbg !883
  store i16 %0, i16* %3, align 2, !dbg !883
  %4 = load i16, i16* %3, align 2, !dbg !884
  %5 = lshr i16 %4, 1, !dbg !885
  %6 = add i16 %5, 31813, !dbg !886
  %7 = shl i16 %6, 1, !dbg !887
  %8 = inttoptr i16 %7 to i16*, !dbg !887
  call void asm sideeffect "nop", ""(), !dbg !887
  call void asm sideeffect "nop", ""(), !dbg !887
  %9 = load volatile i16, i16* %8, align 2, !dbg !887
  store i16 %9, i16* %2, align 2, !dbg !881
  %10 = load i16, i16* %2, align 2, !dbg !888
  %11 = and i16 %10, 2047, !dbg !889
  ret i16 %11, !dbg !890
}

define internal i16 @sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr(i16 %0) !dbg !891 {
  %2 = alloca i16, i16 1, align 2, !dbg !893
  store i16 %0, i16* %2, align 2, !dbg !893
  %3 = load i16, i16* %2, align 2, !dbg !895
  %4 = mul i16 %3, 2, !dbg !896
  %5 = add i16 %4, 31680, !dbg !897
  ret i16 %5, !dbg !898
}

define internal void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 %0, i16 %1, i1 %2) !dbg !899 {
  %4 = alloca i16, i16 1, align 2, !dbg !900
  %5 = alloca i16, i16 1, align 2, !dbg !902
  %6 = alloca i1, i16 1, align 1, !dbg !903
  %7 = alloca i16, i16 1, align 2, !dbg !904
  %8 = alloca i16, i16 1, align 2, !dbg !905
  store i16 %0, i16* %8, align 2, !dbg !905
  store i16 %1, i16* %7, align 2, !dbg !904
  store i1 %2, i1* %6, align 1, !dbg !903
  %9 = load i16, i16* %8, align 2, !dbg !906
  %10 = call i16 @sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr(i16 %9), !dbg !907
  store i16 %10, i16* %5, align 2, !dbg !902
  %11 = load i16, i16* %5, align 2, !dbg !908
  %12 = shl i16 %11, 1, !dbg !909
  %13 = inttoptr i16 %12 to i16*, !dbg !909
  call void asm sideeffect "nop", ""(), !dbg !909
  call void asm sideeffect "nop", ""(), !dbg !909
  call void asm sideeffect "nop", ""(), !dbg !909
  call void asm sideeffect "nop", ""(), !dbg !909
  %14 = load volatile i16, i16* %13, align 2, !dbg !909
  store i16 %14, i16* %4, align 2, !dbg !900
  %15 = load i1, i1* %6, align 1, !dbg !910
  br i1 %15, label %16, label %19, !dbg !911

16:                                               ; preds = %3
  %17 = load i16, i16* %4, align 2, !dbg !912
  %18 = or i16 %17, 2048, !dbg !913
  store i16 %18, i16* %4, align 2, !dbg !914
  br label %22, !dbg !911

19:                                               ; preds = %3
  %20 = load i16, i16* %4, align 2, !dbg !915
  %21 = and i16 %20, -2049, !dbg !916
  store i16 %21, i16* %4, align 2, !dbg !917
  br label %22, !dbg !911

22:                                               ; preds = %16, %19
  %23 = load i16, i16* %4, align 2, !dbg !918
  %24 = and i16 %23, -32, !dbg !919
  store i16 %24, i16* %4, align 2, !dbg !920
  %25 = load i16, i16* %4, align 2, !dbg !921
  %26 = load i16, i16* %7, align 2, !dbg !922
  %27 = add i16 %25, %26, !dbg !923
  store i16 %27, i16* %4, align 2, !dbg !924
  %28 = load i16, i16* %5, align 2, !dbg !925
  %29 = load i16, i16* %4, align 2, !dbg !926
  %30 = shl i16 %28, 1, !dbg !927
  %31 = inttoptr i16 %30 to i16*, !dbg !927
  store volatile i16 %29, i16* %31, align 2, !dbg !927
  call void asm sideeffect "nop", ""(), !dbg !927
  call void asm sideeffect "nop", ""(), !dbg !927
  call void asm sideeffect "nop", ""(), !dbg !927
  call void asm sideeffect "nop", ""(), !dbg !927
  ret void, !dbg !911
}

define internal i16 @sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr(i16 %0) !dbg !928 {
  %2 = alloca i16, i16 1, align 2, !dbg !930
  store i16 %0, i16* %2, align 2, !dbg !930
  %3 = load i16, i16* %2, align 2, !dbg !932
  %4 = add i16 %3, 31616, !dbg !933
  ret i16 %4, !dbg !934
}

define internal void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 %0, i16 %1) !dbg !935 {
  %3 = alloca i16, i16 1, align 2, !dbg !936
  %4 = alloca i16, i16 1, align 2, !dbg !938
  %5 = alloca i16, i16 1, align 2, !dbg !939
  %6 = alloca i16, i16 1, align 2, !dbg !940
  store i16 %0, i16* %6, align 2, !dbg !940
  store i16 %1, i16* %5, align 2, !dbg !939
  %7 = load i16, i16* %6, align 2, !dbg !941
  %8 = call i16 @sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr(i16 %7), !dbg !942
  store i16 %8, i16* %4, align 2, !dbg !938
  %9 = load i16, i16* %4, align 2, !dbg !943
  %10 = shl i16 %9, 1, !dbg !944
  %11 = inttoptr i16 %10 to i16*, !dbg !944
  call void asm sideeffect "nop", ""(), !dbg !944
  call void asm sideeffect "nop", ""(), !dbg !944
  call void asm sideeffect "nop", ""(), !dbg !944
  call void asm sideeffect "nop", ""(), !dbg !944
  %12 = load volatile i16, i16* %11, align 2, !dbg !944
  store i16 %12, i16* %3, align 2, !dbg !936
  %13 = load i16, i16* %3, align 2, !dbg !945
  %14 = and i16 %13, -497, !dbg !946
  store i16 %14, i16* %3, align 2, !dbg !947
  %15 = load i16, i16* %3, align 2, !dbg !948
  %16 = load i16, i16* %5, align 2, !dbg !949
  %17 = add i16 %15, %16, !dbg !950
  %18 = shl i16 %17, 4, !dbg !951
  store i16 %18, i16* %3, align 2, !dbg !952
  %19 = load i16, i16* %4, align 2, !dbg !953
  %20 = load i16, i16* %3, align 2, !dbg !954
  %21 = shl i16 %19, 1, !dbg !955
  %22 = inttoptr i16 %21 to i16*, !dbg !955
  store volatile i16 %20, i16* %22, align 2, !dbg !955
  call void asm sideeffect "nop", ""(), !dbg !955
  call void asm sideeffect "nop", ""(), !dbg !955
  call void asm sideeffect "nop", ""(), !dbg !955
  call void asm sideeffect "nop", ""(), !dbg !955
  ret void, !dbg !956
}

define internal i16* @.get_tensor_ptr(i16 %0) !dbg !957 {
  %2 = alloca i16, i16 1, align 2, !dbg !958
  store i16 %0, i16* %2, align 2, !dbg !958
  %3 = load i16, i16* %2, align 2, !dbg !958
  %4 = zext i16 %3 to i32, !dbg !958
  switch i32 %4, label %5 [
    i32 1, label %9
    i32 2, label %11
    i32 3, label %13
    i32 4, label %15
    i32 5, label %17
  ], !dbg !958

5:                                                ; preds = %1
  br i1 false, label %6, label %7, !dbg !958

6:                                                ; preds = %5
  br label %8, !dbg !958

7:                                                ; preds = %5
  call void asm sideeffect "hcf", ""(), !dbg !958
  br label %8, !dbg !958

8:                                                ; preds = %6, %7
  br label %19, !dbg !958

9:                                                ; preds = %1
  %10 = load i16*, i16** @p_a, align 8, !dbg !958
  br label %19, !dbg !958

11:                                               ; preds = %1
  %12 = load i16*, i16** @p_b, align 8, !dbg !958
  br label %19, !dbg !958

13:                                               ; preds = %1
  %14 = load i16*, i16** @p_c, align 8, !dbg !958
  br label %19, !dbg !958

15:                                               ; preds = %1
  %16 = load i16*, i16** @p_idx, align 8, !dbg !958
  br label %19, !dbg !958

17:                                               ; preds = %1
  %18 = load i16*, i16** @p_k, align 8, !dbg !958
  br label %19, !dbg !958

19:                                               ; preds = %8, %9, %11, %13, %15, %17
  %20 = phi i16 [ -2, %17 ], [ -2, %15 ], [ -2, %13 ], [ -2, %11 ], [ -2, %9 ], [ 0, %8 ]
  %21 = phi i16* [ %18, %17 ], [ %16, %15 ], [ %14, %13 ], [ %12, %11 ], [ %10, %9 ], [ undef, %8 ]
  br label %22, !dbg !958

22:                                               ; preds = %19
  %23 = icmp ne i16 %20, 0, !dbg !958
  br i1 %23, label %24, label %25, !dbg !958

24:                                               ; preds = %22
  br label %27, !dbg !958

25:                                               ; preds = %22
  %26 = load i16*, i16** @p_k, align 8, !dbg !958
  br label %27, !dbg !958

27:                                               ; preds = %24, %25
  %28 = phi i16* [ %26, %25 ], [ %21, %24 ]
  br label %29, !dbg !958

29:                                               ; preds = %27
  ret i16* %28, !dbg !958
}

define internal void @__generic0sys_mod.sys_mod.tile_config.queue_flush.exit() !dbg !960 {
  store volatile i16 1, i16* inttoptr (i16 -2268 to i16*), align 2, !dbg !962
  call void asm sideeffect "nop", ""(), !dbg !962
  call void asm sideeffect "nop", ""(), !dbg !962
  ret void, !dbg !964
}

define internal void @__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position(i16 %0) !dbg !965 {
  %2 = alloca i16, i16 1, align 2, !dbg !967
  %3 = alloca i16, i16 1, align 2, !dbg !969
  %4 = alloca i16, i16 1, align 2, !dbg !970
  store i16 %0, i16* %4, align 2, !dbg !970
  %5 = load i16, i16* %4, align 2, !dbg !971
  store i16 %5, i16* %3, align 2, !dbg !969
  %6 = load i16, i16* %3, align 2, !dbg !972
  %7 = shl i16 %6, 1, !dbg !973
  %8 = inttoptr i16 %7 to i16*, !dbg !973
  call void asm sideeffect "nop", ""(), !dbg !973
  call void asm sideeffect "nop", ""(), !dbg !973
  call void asm sideeffect "nop", ""(), !dbg !973
  call void asm sideeffect "nop", ""(), !dbg !973
  %9 = load volatile i16, i16* %8, align 2, !dbg !973
  store i16 %9, i16* %2, align 2, !dbg !967
  %10 = load i16, i16* %2, align 2, !dbg !974
  %11 = and i16 %10, -16, !dbg !975
  store i16 %11, i16* %2, align 2, !dbg !975
  %12 = load i16, i16* %3, align 2, !dbg !976
  %13 = load i16, i16* %2, align 2, !dbg !977
  %14 = shl i16 %12, 1, !dbg !978
  %15 = inttoptr i16 %14 to i16*, !dbg !978
  store volatile i16 %13, i16* %15, align 2, !dbg !978
  call void asm sideeffect "nop", ""(), !dbg !978
  call void asm sideeffect "nop", ""(), !dbg !978
  call void asm sideeffect "nop", ""(), !dbg !978
  call void asm sideeffect "nop", ""(), !dbg !978
  ret void, !dbg !979
}

define internal void @__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 %0) !dbg !980 {
  %2 = alloca i16, i16 1, align 2, !dbg !982
  %3 = alloca i16, i16 1, align 2, !dbg !984
  %4 = alloca i16, i16 1, align 2, !dbg !985
  store i16 %0, i16* %4, align 2, !dbg !985
  %5 = load i16, i16* %4, align 2, !dbg !986
  store i16 %5, i16* %3, align 2, !dbg !984
  %6 = load i16, i16* %3, align 2, !dbg !987
  %7 = shl i16 %6, 1, !dbg !988
  %8 = inttoptr i16 %7 to i16*, !dbg !988
  call void asm sideeffect "nop", ""(), !dbg !988
  call void asm sideeffect "nop", ""(), !dbg !988
  %9 = load volatile i16, i16* %8, align 2, !dbg !988
  store i16 %9, i16* %2, align 2, !dbg !982
  %10 = load i16, i16* %2, align 2, !dbg !989
  %11 = and i16 %10, -256, !dbg !990
  store i16 %11, i16* %2, align 2, !dbg !991
  %12 = load i16, i16* %2, align 2, !dbg !992
  %13 = load i16, i16* %2, align 2, !dbg !993
  %14 = call i16 @__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %13), !dbg !994
  %15 = or i16 %12, %14, !dbg !995
  store i16 %15, i16* %2, align 2, !dbg !995
  %16 = load i16, i16* %2, align 2, !dbg !996
  %17 = load i16, i16* %2, align 2, !dbg !997
  %18 = call i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %17), !dbg !998
  %19 = or i16 %16, %18, !dbg !999
  store i16 %19, i16* %2, align 2, !dbg !999
  %20 = load i16, i16* %3, align 2, !dbg !1000
  %21 = load i16, i16* %2, align 2, !dbg !1001
  %22 = shl i16 %20, 1, !dbg !1002
  %23 = inttoptr i16 %22 to i16*, !dbg !1002
  store volatile i16 %21, i16* %23, align 2, !dbg !1002
  call void asm sideeffect "nop", ""(), !dbg !1002
  call void asm sideeffect "nop", ""(), !dbg !1002
  ret void, !dbg !1003
}

define internal void @__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 %0) !dbg !1004 {
  %2 = alloca i16, i16 1, align 2, !dbg !1005
  %3 = alloca i16, i16 1, align 2, !dbg !1007
  %4 = alloca i16, i16 1, align 2, !dbg !1008
  store i16 %0, i16* %4, align 2, !dbg !1008
  %5 = load i16, i16* %4, align 2, !dbg !1009
  store i16 %5, i16* %3, align 2, !dbg !1007
  %6 = load i16, i16* %3, align 2, !dbg !1010
  %7 = shl i16 %6, 1, !dbg !1011
  %8 = inttoptr i16 %7 to i16*, !dbg !1011
  call void asm sideeffect "nop", ""(), !dbg !1011
  call void asm sideeffect "nop", ""(), !dbg !1011
  %9 = load volatile i16, i16* %8, align 2, !dbg !1011
  store i16 %9, i16* %2, align 2, !dbg !1005
  %10 = load i16, i16* %2, align 2, !dbg !1012
  %11 = and i16 %10, -256, !dbg !1013
  store i16 %11, i16* %2, align 2, !dbg !1014
  %12 = load i16, i16* %2, align 2, !dbg !1015
  %13 = load i16, i16* %2, align 2, !dbg !1016
  %14 = call i16 @__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %13), !dbg !1017
  %15 = or i16 %12, %14, !dbg !1018
  store i16 %15, i16* %2, align 2, !dbg !1018
  %16 = load i16, i16* %2, align 2, !dbg !1019
  %17 = load i16, i16* %2, align 2, !dbg !1020
  %18 = call i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %17), !dbg !1021
  %19 = or i16 %16, %18, !dbg !1022
  store i16 %19, i16* %2, align 2, !dbg !1022
  %20 = load i16, i16* %3, align 2, !dbg !1023
  %21 = load i16, i16* %2, align 2, !dbg !1024
  %22 = shl i16 %20, 1, !dbg !1025
  %23 = inttoptr i16 %22 to i16*, !dbg !1025
  store volatile i16 %21, i16* %23, align 2, !dbg !1025
  call void asm sideeffect "nop", ""(), !dbg !1025
  call void asm sideeffect "nop", ""(), !dbg !1025
  ret void, !dbg !1026
}

define internal i16 @__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %0) !dbg !1027 {
  %2 = alloca i16, i16 1, align 2, !dbg !1028
  %3 = alloca i16, i16 1, align 2, !dbg !1030
  store i16 %0, i16* %3, align 2, !dbg !1030
  %4 = load i16, i16* %3, align 2, !dbg !1031
  store i16 %4, i16* %2, align 2, !dbg !1028
  %5 = load i16, i16* %2, align 2, !dbg !1032
  store i16 %5, i16* %2, align 2, !dbg !1033
  %6 = load i16, i16* %2, align 2, !dbg !1034
  ret i16 %6, !dbg !1035
}

define internal i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %0) !dbg !1036 {
  %2 = alloca i16, i16 1, align 2, !dbg !1037
  %3 = alloca i16, i16 1, align 2, !dbg !1039
  store i16 %0, i16* %3, align 2, !dbg !1039
  %4 = load i16, i16* %3, align 2, !dbg !1040
  store i16 %4, i16* %2, align 2, !dbg !1037
  %5 = load i16, i16* %2, align 2, !dbg !1041
  %6 = or i16 %5, 2, !dbg !1042
  store i16 %6, i16* %2, align 2, !dbg !1042
  %7 = load i16, i16* %2, align 2, !dbg !1043
  ret i16 %7, !dbg !1044
}

define internal i16 @__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %0) !dbg !1045 {
  %2 = alloca i16, i16 1, align 2, !dbg !1046
  %3 = alloca i16, i16 1, align 2, !dbg !1048
  store i16 %0, i16* %3, align 2, !dbg !1048
  %4 = load i16, i16* %3, align 2, !dbg !1049
  store i16 %4, i16* %2, align 2, !dbg !1046
  %5 = load i16, i16* %2, align 2, !dbg !1050
  %6 = or i16 %5, 128, !dbg !1051
  store i16 %6, i16* %2, align 2, !dbg !1051
  %7 = load i16, i16* %2, align 2, !dbg !1052
  ret i16 %7, !dbg !1053
}

define internal void @__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction(i16 %0) !dbg !1054 {
  %2 = alloca i16, i16 1, align 2, !dbg !1055
  %3 = alloca i16, i16 1, align 2, !dbg !1057
  %4 = alloca i16, i16 1, align 2, !dbg !1058
  store i16 %0, i16* %4, align 2, !dbg !1058
  %5 = load i16, i16* %4, align 2, !dbg !1059
  store i16 %5, i16* %3, align 2, !dbg !1057
  %6 = load i16, i16* %3, align 2, !dbg !1060
  %7 = shl i16 %6, 1, !dbg !1061
  %8 = inttoptr i16 %7 to i16*, !dbg !1061
  call void asm sideeffect "nop", ""(), !dbg !1061
  call void asm sideeffect "nop", ""(), !dbg !1061
  %9 = load volatile i16, i16* %8, align 2, !dbg !1061
  store i16 %9, i16* %2, align 2, !dbg !1055
  %10 = load i16, i16* %2, align 2, !dbg !1062
  %11 = and i16 %10, -17, !dbg !1063
  store i16 %11, i16* %2, align 2, !dbg !1063
  %12 = load i16, i16* %3, align 2, !dbg !1064
  %13 = load i16, i16* %2, align 2, !dbg !1065
  %14 = shl i16 %12, 1, !dbg !1066
  %15 = inttoptr i16 %14 to i16*, !dbg !1066
  store volatile i16 %13, i16* %15, align 2, !dbg !1066
  call void asm sideeffect "nop", ""(), !dbg !1066
  call void asm sideeffect "nop", ""(), !dbg !1066
  ret void, !dbg !1067
}

define internal void @__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction(i16 %0) !dbg !1068 {
  %2 = alloca i16, i16 1, align 2, !dbg !1069
  %3 = alloca i16, i16 1, align 2, !dbg !1071
  %4 = alloca i16, i16 1, align 2, !dbg !1072
  store i16 %0, i16* %4, align 2, !dbg !1072
  %5 = load i16, i16* %4, align 2, !dbg !1073
  store i16 %5, i16* %3, align 2, !dbg !1071
  %6 = load i16, i16* %3, align 2, !dbg !1074
  %7 = shl i16 %6, 1, !dbg !1075
  %8 = inttoptr i16 %7 to i16*, !dbg !1075
  call void asm sideeffect "nop", ""(), !dbg !1075
  call void asm sideeffect "nop", ""(), !dbg !1075
  %9 = load volatile i16, i16* %8, align 2, !dbg !1075
  store i16 %9, i16* %2, align 2, !dbg !1069
  %10 = load i16, i16* %2, align 2, !dbg !1076
  %11 = or i16 %10, 16, !dbg !1077
  store i16 %11, i16* %2, align 2, !dbg !1077
  %12 = load i16, i16* %3, align 2, !dbg !1078
  %13 = load i16, i16* %2, align 2, !dbg !1079
  %14 = shl i16 %12, 1, !dbg !1080
  %15 = inttoptr i16 %14 to i16*, !dbg !1080
  store volatile i16 %13, i16* %15, align 2, !dbg !1080
  call void asm sideeffect "nop", ""(), !dbg !1080
  call void asm sideeffect "nop", ""(), !dbg !1080
  ret void, !dbg !1081
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
!3 = distinct !DISubprogram(name: "compute", linkageName: "compute", scope: null, file: !4, line: 15, type: !5, scopeLine: 15, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!4 = !DIFile(filename: "./pe.csl", directory: "/home/USER/xkernel/studies/wse3-characterization/microbench/addfam/cases/loop_runtime")
!5 = !DISubroutineType(types: !6)
!6 = !{}
!7 = !DILocation(line: 17, column: 3, scope: !8)
!8 = !DILexicalBlockFile(scope: !3, file: !4, discriminator: 0)
!9 = !DILocation(line: 16, column: 3, scope: !8)
!10 = !DILocation(line: 16, column: 26, scope: !8)
!11 = !DILocation(line: 18, column: 3, scope: !8)
!12 = !DILocation(line: 18, column: 10, scope: !8)
!13 = !DILocation(line: 18, column: 14, scope: !8)
!14 = !DILocation(line: 18, column: 12, scope: !8)
!15 = !DILocation(line: 18, column: 39, scope: !8)
!16 = !DILocation(line: 18, column: 38, scope: !8)
!17 = !DILocation(line: 18, column: 46, scope: !8)
!18 = !DILocation(line: 18, column: 45, scope: !8)
!19 = !DILocation(line: 18, column: 42, scope: !8)
!20 = !DILocation(line: 18, column: 32, scope: !8)
!21 = !DILocation(line: 18, column: 31, scope: !8)
!22 = !DILocation(line: 18, column: 35, scope: !8)
!23 = !DILocation(line: 18, column: 20, scope: !8)
!24 = !DILocation(line: 18, column: 22, scope: !8)
!25 = !DILocation(line: 19, column: 3, scope: !8)
!26 = distinct !DISubprogram(name: "f_exit", linkageName: "f_exit", scope: null, file: !4, line: 22, type: !5, scopeLine: 22, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!27 = !DILocation(line: 22, column: 22, scope: !28)
!28 = !DILexicalBlockFile(scope: !26, file: !4, discriminator: 0)
!29 = !DILocation(line: 22, column: 1, scope: !28)
!30 = distinct !DISubprogram(name: "sys_mod.sys_nop", linkageName: "sys_mod.sys_nop", scope: null, file: !31, line: 90, type: !5, scopeLine: 90, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!31 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/memcpy.csl", directory: "")
!32 = !DILocation(line: 90, column: 1, scope: !33)
!33 = !DILexicalBlockFile(scope: !30, file: !31, discriminator: 0)
!34 = distinct !DISubprogram(name: "sys_mod.unblock_cmd_stream", linkageName: "sys_mod.unblock_cmd_stream", scope: null, file: !31, line: 102, type: !5, scopeLine: 102, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!35 = !DILocation(line: 103, column: 3, scope: !36)
!36 = !DILexicalBlockFile(scope: !34, file: !31, discriminator: 0)
!37 = !DILocation(line: 102, column: 1, scope: !36)
!38 = distinct !DISubprogram(name: "sys_mod.sys_mod.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.unblock_cmd_stream", scope: null, file: !39, line: 307, type: !5, scopeLine: 307, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!39 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpy.csl", directory: "")
!40 = !DILocation(line: 308, column: 5, scope: !41)
!41 = !DILexicalBlockFile(scope: !38, file: !39, discriminator: 0)
!42 = !DILocation(line: 307, column: 1, scope: !41)
!43 = distinct !DISubprogram(name: "sys_mod.sys_mod.teardown_h2d", linkageName: "sys_mod.sys_mod.teardown_h2d", scope: null, file: !39, line: 323, type: !5, scopeLine: 323, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!44 = !DILocation(line: 326, column: 5, scope: !45)
!45 = !DILexicalBlockFile(scope: !43, file: !39, discriminator: 0)
!46 = !DILocation(line: 323, column: 1, scope: !45)
!47 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_ublk_c22", linkageName: "sys_mod.sys_mod.f_ublk_c22", scope: null, file: !39, line: 335, type: !5, scopeLine: 335, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!48 = !DILocation(line: 336, column: 5, scope: !49)
!49 = !DILexicalBlockFile(scope: !47, file: !39, discriminator: 0)
!50 = !DILocation(line: 335, column: 1, scope: !49)
!51 = distinct !DISubprogram(name: "sys_mod.sys_mod.teardown_d2h", linkageName: "sys_mod.sys_mod.teardown_d2h", scope: null, file: !39, line: 344, type: !5, scopeLine: 344, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!52 = !DILocation(line: 355, column: 5, scope: !53)
!53 = !DILexicalBlockFile(scope: !51, file: !39, discriminator: 0)
!54 = !DILocation(line: 359, column: 5, scope: !53)
!55 = !DILocation(line: 344, column: 1, scope: !53)
!56 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_memcpyh2d", linkageName: "sys_mod.sys_mod.f_memcpyh2d", scope: null, file: !39, line: 460, type: !5, scopeLine: 460, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!57 = !DILocation(line: 477, column: 5, scope: !58)
!58 = !DILexicalBlockFile(scope: !56, file: !39, discriminator: 0)
!59 = !DILocation(line: 476, column: 5, scope: !58)
!60 = !DILocation(line: 475, column: 5, scope: !58)
!61 = !DILocation(line: 474, column: 5, scope: !58)
!62 = !DILocation(line: 473, column: 5, scope: !58)
!63 = !DILocation(line: 472, column: 5, scope: !58)
!64 = !DILocation(line: 471, column: 5, scope: !58)
!65 = !DILocation(line: 470, column: 5, scope: !58)
!66 = !DILocation(line: 469, column: 5, scope: !58)
!67 = !DILocation(line: 468, column: 5, scope: !58)
!68 = !DILocation(line: 467, column: 5, scope: !58)
!69 = !DILocation(line: 466, column: 5, scope: !58)
!70 = !DILocation(line: 465, column: 5, scope: !58)
!71 = !DILocation(line: 463, column: 5, scope: !58)
!72 = !DILocation(line: 462, column: 20, scope: !58)
!73 = !DILocation(line: 462, column: 32, scope: !58)
!74 = !DILocation(line: 462, column: 5, scope: !58)
!75 = !DILocation(line: 465, column: 33, scope: !58)
!76 = !DILocation(line: 465, column: 38, scope: !58)
!77 = !DILocation(line: 466, column: 34, scope: !58)
!78 = !DILocation(line: 466, column: 39, scope: !58)
!79 = !DILocation(line: 467, column: 34, scope: !58)
!80 = !DILocation(line: 467, column: 39, scope: !58)
!81 = !DILocation(line: 468, column: 33, scope: !58)
!82 = !DILocation(line: 468, column: 38, scope: !58)
!83 = !DILocation(line: 469, column: 33, scope: !58)
!84 = !DILocation(line: 469, column: 38, scope: !58)
!85 = !DILocation(line: 470, column: 35, scope: !58)
!86 = !DILocation(line: 470, column: 21, scope: !58)
!87 = !DILocation(line: 471, column: 41, scope: !58)
!88 = !DILocation(line: 471, column: 27, scope: !58)
!89 = !DILocation(line: 472, column: 39, scope: !58)
!90 = !DILocation(line: 472, column: 25, scope: !58)
!91 = !DILocation(line: 473, column: 44, scope: !58)
!92 = !DILocation(line: 473, column: 49, scope: !58)
!93 = !DILocation(line: 474, column: 41, scope: !58)
!94 = !DILocation(line: 474, column: 46, scope: !58)
!95 = !DILocation(line: 475, column: 41, scope: !58)
!96 = !DILocation(line: 475, column: 46, scope: !58)
!97 = !DILocation(line: 476, column: 59, scope: !58)
!98 = !DILocation(line: 476, column: 64, scope: !58)
!99 = !DILocation(line: 476, column: 50, scope: !58)
!100 = !DILocation(line: 476, column: 129, scope: !58)
!101 = !DILocation(line: 476, column: 134, scope: !58)
!102 = !DILocation(line: 476, column: 120, scope: !58)
!103 = !DILocation(line: 476, column: 118, scope: !58)
!104 = !DILocation(line: 476, column: 112, scope: !58)
!105 = !DILocation(line: 476, column: 36, scope: !58)
!106 = !DILocation(line: 477, column: 59, scope: !58)
!107 = !DILocation(line: 477, column: 64, scope: !58)
!108 = !DILocation(line: 477, column: 50, scope: !58)
!109 = !DILocation(line: 477, column: 129, scope: !58)
!110 = !DILocation(line: 477, column: 134, scope: !58)
!111 = !DILocation(line: 477, column: 120, scope: !58)
!112 = !DILocation(line: 477, column: 118, scope: !58)
!113 = !DILocation(line: 477, column: 112, scope: !58)
!114 = !DILocation(line: 477, column: 36, scope: !58)
!115 = !DILocation(line: 479, column: 24, scope: !58)
!116 = !DILocation(line: 481, column: 21, scope: !58)
!117 = !DILocation(line: 481, column: 19, scope: !58)
!118 = !DILocation(line: 482, column: 21, scope: !58)
!119 = !DILocation(line: 482, column: 19, scope: !58)
!120 = !DILocation(line: 483, column: 21, scope: !58)
!121 = !DILocation(line: 483, column: 19, scope: !58)
!122 = !DILocation(line: 484, column: 20, scope: !58)
!123 = !DILocation(line: 484, column: 18, scope: !58)
!124 = !DILocation(line: 485, column: 20, scope: !58)
!125 = !DILocation(line: 485, column: 18, scope: !58)
!126 = !DILocation(line: 486, column: 22, scope: !58)
!127 = !DILocation(line: 486, column: 20, scope: !58)
!128 = !DILocation(line: 487, column: 27, scope: !58)
!129 = !DILocation(line: 487, column: 25, scope: !58)
!130 = !DILocation(line: 488, column: 25, scope: !58)
!131 = !DILocation(line: 488, column: 23, scope: !58)
!132 = !DILocation(line: 489, column: 31, scope: !58)
!133 = !DILocation(line: 489, column: 29, scope: !58)
!134 = !DILocation(line: 490, column: 28, scope: !58)
!135 = !DILocation(line: 490, column: 26, scope: !58)
!136 = !DILocation(line: 491, column: 28, scope: !58)
!137 = !DILocation(line: 491, column: 26, scope: !58)
!138 = !DILocation(line: 492, column: 37, scope: !58)
!139 = !DILocation(line: 492, column: 35, scope: !58)
!140 = !DILocation(line: 493, column: 37, scope: !58)
!141 = !DILocation(line: 493, column: 35, scope: !58)
!142 = !DILocation(line: 495, column: 5, scope: !58)
!143 = !DILocation(line: 501, column: 5, scope: !58)
!144 = !DILocation(line: 506, column: 5, scope: !58)
!145 = !DILocation(line: 521, column: 5, scope: !58)
!146 = !DILocation(line: 522, column: 16, scope: !58)
!147 = !DILocation(line: 531, column: 5, scope: !58)
!148 = !DILocation(line: 460, column: 1, scope: !58)
!149 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_memcpyd2h", linkageName: "sys_mod.sys_mod.f_memcpyd2h", scope: null, file: !39, line: 556, type: !5, scopeLine: 556, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!150 = !DILocation(line: 568, column: 5, scope: !151)
!151 = !DILexicalBlockFile(scope: !149, file: !39, discriminator: 0)
!152 = !DILocation(line: 567, column: 5, scope: !151)
!153 = !DILocation(line: 566, column: 5, scope: !151)
!154 = !DILocation(line: 565, column: 5, scope: !151)
!155 = !DILocation(line: 564, column: 5, scope: !151)
!156 = !DILocation(line: 563, column: 5, scope: !151)
!157 = !DILocation(line: 562, column: 5, scope: !151)
!158 = !DILocation(line: 561, column: 5, scope: !151)
!159 = !DILocation(line: 559, column: 5, scope: !151)
!160 = !DILocation(line: 558, column: 20, scope: !151)
!161 = !DILocation(line: 558, column: 32, scope: !151)
!162 = !DILocation(line: 558, column: 5, scope: !151)
!163 = !DILocation(line: 561, column: 33, scope: !151)
!164 = !DILocation(line: 561, column: 38, scope: !151)
!165 = !DILocation(line: 562, column: 34, scope: !151)
!166 = !DILocation(line: 562, column: 39, scope: !151)
!167 = !DILocation(line: 563, column: 34, scope: !151)
!168 = !DILocation(line: 563, column: 39, scope: !151)
!169 = !DILocation(line: 564, column: 33, scope: !151)
!170 = !DILocation(line: 564, column: 38, scope: !151)
!171 = !DILocation(line: 565, column: 33, scope: !151)
!172 = !DILocation(line: 565, column: 38, scope: !151)
!173 = !DILocation(line: 566, column: 35, scope: !151)
!174 = !DILocation(line: 566, column: 21, scope: !151)
!175 = !DILocation(line: 567, column: 41, scope: !151)
!176 = !DILocation(line: 567, column: 27, scope: !151)
!177 = !DILocation(line: 568, column: 39, scope: !151)
!178 = !DILocation(line: 568, column: 25, scope: !151)
!179 = !DILocation(line: 570, column: 24, scope: !151)
!180 = !DILocation(line: 573, column: 21, scope: !151)
!181 = !DILocation(line: 573, column: 19, scope: !151)
!182 = !DILocation(line: 574, column: 21, scope: !151)
!183 = !DILocation(line: 574, column: 19, scope: !151)
!184 = !DILocation(line: 575, column: 21, scope: !151)
!185 = !DILocation(line: 575, column: 19, scope: !151)
!186 = !DILocation(line: 576, column: 20, scope: !151)
!187 = !DILocation(line: 576, column: 18, scope: !151)
!188 = !DILocation(line: 577, column: 20, scope: !151)
!189 = !DILocation(line: 577, column: 18, scope: !151)
!190 = !DILocation(line: 578, column: 22, scope: !151)
!191 = !DILocation(line: 578, column: 20, scope: !151)
!192 = !DILocation(line: 579, column: 27, scope: !151)
!193 = !DILocation(line: 579, column: 25, scope: !151)
!194 = !DILocation(line: 580, column: 25, scope: !151)
!195 = !DILocation(line: 580, column: 23, scope: !151)
!196 = !DILocation(line: 582, column: 5, scope: !151)
!197 = !DILocation(line: 588, column: 59, scope: !151)
!198 = !DILocation(line: 588, column: 5, scope: !151)
!199 = !DILocation(line: 608, column: 5, scope: !151)
!200 = !DILocation(line: 609, column: 16, scope: !151)
!201 = !DILocation(line: 556, column: 1, scope: !151)
!202 = distinct !DISubprogram(name: "sys_mod.sys_mod.oq0_teardow_handler", linkageName: "sys_mod.sys_mod.oq0_teardow_handler", scope: null, file: !39, line: 631, type: !5, scopeLine: 631, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!203 = !DILocation(line: 632, column: 9, scope: !204)
!204 = !DILexicalBlockFile(scope: !202, file: !39, discriminator: 0)
!205 = !DILocation(line: 632, column: 5, scope: !204)
!206 = !DILocation(line: 634, column: 66, scope: !204)
!207 = !DILocation(line: 634, column: 9, scope: !204)
!208 = !DILocation(line: 636, column: 13, scope: !204)
!209 = !DILocation(line: 637, column: 13, scope: !204)
!210 = !DILocation(line: 638, column: 13, scope: !204)
!211 = !DILocation(line: 639, column: 13, scope: !204)
!212 = !DILocation(line: 640, column: 13, scope: !204)
!213 = !DILocation(line: 641, column: 13, scope: !204)
!214 = !DILocation(line: 642, column: 13, scope: !204)
!215 = !DILocation(line: 643, column: 13, scope: !204)
!216 = !DILocation(line: 644, column: 13, scope: !204)
!217 = !DILocation(line: 645, column: 13, scope: !204)
!218 = !DILocation(line: 646, column: 13, scope: !204)
!219 = !DILocation(line: 647, column: 13, scope: !204)
!220 = !DILocation(line: 648, column: 13, scope: !204)
!221 = !DILocation(line: 635, column: 9, scope: !204)
!222 = !DILocation(line: 652, column: 9, scope: !204)
!223 = !DILocation(line: 654, column: 13, scope: !204)
!224 = !DILocation(line: 655, column: 13, scope: !204)
!225 = !DILocation(line: 656, column: 13, scope: !204)
!226 = !DILocation(line: 657, column: 13, scope: !204)
!227 = !DILocation(line: 658, column: 13, scope: !204)
!228 = !DILocation(line: 659, column: 13, scope: !204)
!229 = !DILocation(line: 660, column: 13, scope: !204)
!230 = !DILocation(line: 661, column: 13, scope: !204)
!231 = !DILocation(line: 653, column: 9, scope: !204)
!232 = !DILocation(line: 664, column: 5, scope: !204)
!233 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_rpc", linkageName: "sys_mod.sys_mod.f_rpc", scope: null, file: !39, line: 694, type: !5, scopeLine: 694, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!234 = !DILocation(line: 694, column: 13, scope: !235)
!235 = !DILexicalBlockFile(scope: !233, file: !39, discriminator: 0)
!236 = !DILocation(line: 700, column: 5, scope: !235)
!237 = !DILocation(line: 706, column: 20, scope: !235)
!238 = !DILocation(line: 706, column: 32, scope: !235)
!239 = !DILocation(line: 706, column: 5, scope: !235)
!240 = !DILocation(line: 710, column: 5, scope: !235)
!241 = !DILocation(line: 712, column: 24, scope: !235)
!242 = !DILocation(line: 694, column: 1, scope: !235)
!243 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.stack_push", linkageName: "sys_mod.sys_mod.sys_mod.stack_push", scope: null, file: !244, line: 54, type: !5, scopeLine: 54, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!244 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/sys.csl", directory: "")
!245 = !DILocation(line: 60, column: 5, scope: !246)
!246 = !DILexicalBlockFile(scope: !243, file: !244, discriminator: 0)
!247 = !DILocation(line: 54, column: 16, scope: !246)
!248 = !DILocation(line: 59, column: 13, scope: !246)
!249 = !DILocation(line: 59, column: 24, scope: !246)
!250 = !DILocation(line: 59, column: 5, scope: !246)
!251 = !DILocation(line: 61, column: 25, scope: !246)
!252 = !DILocation(line: 61, column: 5, scope: !246)
!253 = !DILocation(line: 61, column: 11, scope: !246)
!254 = !DILocation(line: 61, column: 10, scope: !246)
!255 = !DILocation(line: 61, column: 23, scope: !246)
!256 = !DILocation(line: 62, column: 18, scope: !246)
!257 = !DILocation(line: 62, column: 29, scope: !246)
!258 = !DILocation(line: 62, column: 16, scope: !246)
!259 = !DILocation(line: 54, column: 1, scope: !246)
!260 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_push", linkageName: "sys_mod.sys_mod.sys_mod.f_push", scope: null, file: !244, line: 72, type: !5, scopeLine: 72, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!261 = !DILocation(line: 72, column: 25, scope: !262)
!262 = !DILexicalBlockFile(scope: !260, file: !244, discriminator: 0)
!263 = !DILocation(line: 72, column: 13, scope: !262)
!264 = !DILocation(line: 73, column: 16, scope: !262)
!265 = !DILocation(line: 73, column: 5, scope: !262)
!266 = !DILocation(line: 72, column: 1, scope: !262)
!267 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.block_cmd_stream", linkageName: "sys_mod.sys_mod.sys_mod.block_cmd_stream", scope: null, file: !244, line: 76, type: !5, scopeLine: 76, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!268 = !DILocation(line: 77, column: 5, scope: !269)
!269 = !DILexicalBlockFile(scope: !267, file: !244, discriminator: 0)
!270 = !DILocation(line: 76, column: 1, scope: !269)
!271 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.sys_mod.unblock_cmd_stream", scope: null, file: !244, line: 80, type: !5, scopeLine: 80, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!272 = !DILocation(line: 81, column: 5, scope: !273)
!273 = !DILexicalBlockFile(scope: !271, file: !244, discriminator: 0)
!274 = !DILocation(line: 80, column: 1, scope: !273)
!275 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_sys_exit", linkageName: "sys_mod.sys_mod.sys_mod.f_sys_exit", scope: null, file: !244, line: 85, type: !5, scopeLine: 85, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!276 = !DILocation(line: 86, column: 5, scope: !277)
!277 = !DILexicalBlockFile(scope: !275, file: !244, discriminator: 0)
!278 = !DILocation(line: 87, column: 5, scope: !277)
!279 = !DILocation(line: 85, column: 1, scope: !277)
!280 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore", linkageName: "sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore", scope: null, file: !244, line: 90, type: !5, scopeLine: 90, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!281 = !DILocation(line: 90, column: 30, scope: !282)
!282 = !DILexicalBlockFile(scope: !280, file: !244, discriminator: 0)
!283 = !DILocation(line: 90, column: 1, scope: !282)
!284 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord", scope: null, file: !285, line: 131, type: !5, scopeLine: 131, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!285 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpyh2d.csl", directory: "")
!286 = !DILocation(line: 132, column: 12, scope: !287)
!287 = !DILexicalBlockFile(scope: !284, file: !285, discriminator: 0)
!288 = !DILocation(line: 132, column: 5, scope: !287)
!289 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord", scope: null, file: !285, line: 134, type: !5, scopeLine: 134, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!290 = !DILocation(line: 135, column: 12, scope: !291)
!291 = !DILexicalBlockFile(scope: !289, file: !285, discriminator: 0)
!292 = !DILocation(line: 135, column: 5, scope: !291)
!293 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval", scope: null, file: !285, line: 148, type: !5, scopeLine: 148, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!294 = !DILocation(line: 148, column: 23, scope: !295)
!295 = !DILexicalBlockFile(scope: !293, file: !285, discriminator: 0)
!296 = !DILocation(line: 149, column: 9, scope: !295)
!297 = !DILocation(line: 149, column: 20, scope: !295)
!298 = !DILocation(line: 149, column: 5, scope: !295)
!299 = !DILocation(line: 152, column: 23, scope: !295)
!300 = !DILocation(line: 152, column: 20, scope: !295)
!301 = !DILocation(line: 152, column: 9, scope: !295)
!302 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start", scope: null, file: !285, line: 226, type: !5, scopeLine: 226, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!303 = !DILocation(line: 233, column: 5, scope: !304)
!304 = !DILexicalBlockFile(scope: !302, file: !285, discriminator: 0)
!305 = !DILocation(line: 226, column: 49, scope: !304)
!306 = !DILocation(line: 226, column: 32, scope: !304)
!307 = !DILocation(line: 226, column: 21, scope: !304)
!308 = !DILocation(line: 229, column: 37, scope: !304)
!309 = !DILocation(line: 229, column: 52, scope: !304)
!310 = !DILocation(line: 229, column: 19, scope: !304)
!311 = !DILocation(line: 233, column: 71, scope: !304)
!312 = !DILocation(line: 233, column: 55, scope: !304)
!313 = !DILocation(line: 233, column: 25, scope: !304)
!314 = !DILocation(line: 235, column: 37, scope: !304)
!315 = !DILocation(line: 235, column: 52, scope: !304)
!316 = !DILocation(line: 235, column: 19, scope: !304)
!317 = !DILocation(line: 236, column: 28, scope: !304)
!318 = !DILocation(line: 236, column: 5, scope: !304)
!319 = !DILocation(line: 237, column: 28, scope: !304)
!320 = !DILocation(line: 237, column: 5, scope: !304)
!321 = !DILocation(line: 238, column: 13, scope: !304)
!322 = !DILocation(line: 238, column: 11, scope: !304)
!323 = !DILocation(line: 238, column: 5, scope: !304)
!324 = !DILocation(line: 239, column: 9, scope: !304)
!325 = !DILocation(line: 241, column: 9, scope: !304)
!326 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream", scope: null, file: !285, line: 249, type: !5, scopeLine: 249, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!327 = !DILocation(line: 250, column: 5, scope: !328)
!328 = !DILexicalBlockFile(scope: !326, file: !285, discriminator: 0)
!329 = !DILocation(line: 249, column: 1, scope: !328)
!330 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure", scope: null, file: !285, line: 276, type: !5, scopeLine: 276, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!331 = !DILocation(line: 414, column: 13, scope: !332)
!332 = !DILexicalBlockFile(scope: !330, file: !285, discriminator: 0)
!333 = !DILocation(line: 413, column: 13, scope: !332)
!334 = !DILocation(line: 400, column: 17, scope: !332)
!335 = !DILocation(line: 340, column: 9, scope: !332)
!336 = !DILocation(line: 339, column: 9, scope: !332)
!337 = !DILocation(line: 337, column: 5, scope: !332)
!338 = !DILocation(line: 319, column: 9, scope: !332)
!339 = !DILocation(line: 318, column: 9, scope: !332)
!340 = !DILocation(line: 315, column: 5, scope: !332)
!341 = !DILocation(line: 292, column: 5, scope: !332)
!342 = !DILocation(line: 291, column: 5, scope: !332)
!343 = !DILocation(line: 289, column: 5, scope: !332)
!344 = !DILocation(line: 288, column: 5, scope: !332)
!345 = !DILocation(line: 287, column: 5, scope: !332)
!346 = !DILocation(line: 286, column: 5, scope: !332)
!347 = !DILocation(line: 285, column: 5, scope: !332)
!348 = !DILocation(line: 284, column: 5, scope: !332)
!349 = !DILocation(line: 283, column: 5, scope: !332)
!350 = !DILocation(line: 282, column: 5, scope: !332)
!351 = !DILocation(line: 281, column: 5, scope: !332)
!352 = !DILocation(line: 280, column: 5, scope: !332)
!353 = !DILocation(line: 279, column: 5, scope: !332)
!354 = !DILocation(line: 278, column: 5, scope: !332)
!355 = !DILocation(line: 277, column: 5, scope: !332)
!356 = !DILocation(line: 291, column: 26, scope: !332)
!357 = !DILocation(line: 292, column: 26, scope: !332)
!358 = !DILocation(line: 315, column: 25, scope: !332)
!359 = !DILocation(line: 315, column: 31, scope: !332)
!360 = !DILocation(line: 315, column: 29, scope: !332)
!361 = !DILocation(line: 316, column: 20, scope: !332)
!362 = !DILocation(line: 316, column: 18, scope: !332)
!363 = !DILocation(line: 317, column: 52, scope: !332)
!364 = !DILocation(line: 317, column: 49, scope: !332)
!365 = !DILocation(line: 317, column: 5, scope: !332)
!366 = !DILocation(line: 318, column: 42, scope: !332)
!367 = !DILocation(line: 318, column: 33, scope: !332)
!368 = !DILocation(line: 318, column: 49, scope: !332)
!369 = !DILocation(line: 318, column: 48, scope: !332)
!370 = !DILocation(line: 318, column: 24, scope: !332)
!371 = !DILocation(line: 319, column: 24, scope: !332)
!372 = !DILocation(line: 319, column: 32, scope: !332)
!373 = !DILocation(line: 319, column: 36, scope: !332)
!374 = !DILocation(line: 319, column: 34, scope: !332)
!375 = !DILocation(line: 319, column: 30, scope: !332)
!376 = !DILocation(line: 320, column: 18, scope: !332)
!377 = !DILocation(line: 320, column: 15, scope: !332)
!378 = !DILocation(line: 320, column: 9, scope: !332)
!379 = !DILocation(line: 321, column: 26, scope: !332)
!380 = !DILocation(line: 325, column: 28, scope: !332)
!381 = !DILocation(line: 325, column: 26, scope: !332)
!382 = !DILocation(line: 331, column: 9, scope: !332)
!383 = !DILocation(line: 331, column: 15, scope: !332)
!384 = !DILocation(line: 331, column: 5, scope: !332)
!385 = !DILocation(line: 332, column: 22, scope: !332)
!386 = !DILocation(line: 334, column: 9, scope: !332)
!387 = !DILocation(line: 334, column: 18, scope: !332)
!388 = !DILocation(line: 334, column: 15, scope: !332)
!389 = !DILocation(line: 334, column: 5, scope: !332)
!390 = !DILocation(line: 335, column: 22, scope: !332)
!391 = !DILocation(line: 338, column: 52, scope: !332)
!392 = !DILocation(line: 338, column: 49, scope: !332)
!393 = !DILocation(line: 338, column: 5, scope: !332)
!394 = !DILocation(line: 339, column: 42, scope: !332)
!395 = !DILocation(line: 339, column: 48, scope: !332)
!396 = !DILocation(line: 339, column: 46, scope: !332)
!397 = !DILocation(line: 339, column: 33, scope: !332)
!398 = !DILocation(line: 339, column: 52, scope: !332)
!399 = !DILocation(line: 339, column: 51, scope: !332)
!400 = !DILocation(line: 339, column: 24, scope: !332)
!401 = !DILocation(line: 340, column: 25, scope: !332)
!402 = !DILocation(line: 340, column: 31, scope: !332)
!403 = !DILocation(line: 340, column: 29, scope: !332)
!404 = !DILocation(line: 340, column: 37, scope: !332)
!405 = !DILocation(line: 340, column: 41, scope: !332)
!406 = !DILocation(line: 340, column: 39, scope: !332)
!407 = !DILocation(line: 340, column: 35, scope: !332)
!408 = !DILocation(line: 341, column: 18, scope: !332)
!409 = !DILocation(line: 341, column: 15, scope: !332)
!410 = !DILocation(line: 341, column: 9, scope: !332)
!411 = !DILocation(line: 342, column: 26, scope: !332)
!412 = !DILocation(line: 347, column: 10, scope: !332)
!413 = !DILocation(line: 347, column: 16, scope: !332)
!414 = !DILocation(line: 347, column: 14, scope: !332)
!415 = !DILocation(line: 347, column: 5, scope: !332)
!416 = !DILocation(line: 348, column: 22, scope: !332)
!417 = !DILocation(line: 350, column: 10, scope: !332)
!418 = !DILocation(line: 350, column: 18, scope: !332)
!419 = !DILocation(line: 350, column: 21, scope: !332)
!420 = !DILocation(line: 350, column: 20, scope: !332)
!421 = !DILocation(line: 350, column: 14, scope: !332)
!422 = !DILocation(line: 350, column: 5, scope: !332)
!423 = !DILocation(line: 351, column: 22, scope: !332)
!424 = !DILocation(line: 354, column: 9, scope: !332)
!425 = !DILocation(line: 354, column: 5, scope: !332)
!426 = !DILocation(line: 358, column: 9, scope: !332)
!427 = !DILocation(line: 361, column: 9, scope: !332)
!428 = !DILocation(line: 364, column: 20, scope: !332)
!429 = !DILocation(line: 364, column: 17, scope: !332)
!430 = !DILocation(line: 364, column: 9, scope: !332)
!431 = !DILocation(line: 368, column: 13, scope: !332)
!432 = !DILocation(line: 371, column: 13, scope: !332)
!433 = !DILocation(line: 375, column: 13, scope: !332)
!434 = !DILocation(line: 394, column: 13, scope: !332)
!435 = !DILocation(line: 396, column: 29, scope: !332)
!436 = !DILocation(line: 396, column: 27, scope: !332)
!437 = !DILocation(line: 397, column: 60, scope: !332)
!438 = !DILocation(line: 397, column: 57, scope: !332)
!439 = !DILocation(line: 397, column: 13, scope: !332)
!440 = !DILocation(line: 400, column: 54, scope: !332)
!441 = !DILocation(line: 400, column: 55, scope: !332)
!442 = !DILocation(line: 400, column: 46, scope: !332)
!443 = !DILocation(line: 400, column: 59, scope: !332)
!444 = !DILocation(line: 400, column: 58, scope: !332)
!445 = !DILocation(line: 400, column: 37, scope: !332)
!446 = !DILocation(line: 400, column: 35, scope: !332)
!447 = !DILocation(line: 401, column: 33, scope: !332)
!448 = !DILocation(line: 401, column: 31, scope: !332)
!449 = !DILocation(line: 402, column: 69, scope: !332)
!450 = !DILocation(line: 402, column: 66, scope: !332)
!451 = !DILocation(line: 402, column: 19, scope: !332)
!452 = !DILocation(line: 404, column: 31, scope: !332)
!453 = !DILocation(line: 408, column: 75, scope: !332)
!454 = !DILocation(line: 408, column: 88, scope: !332)
!455 = !DILocation(line: 408, column: 13, scope: !332)
!456 = !DILocation(line: 413, column: 31, scope: !332)
!457 = !DILocation(line: 414, column: 33, scope: !332)
!458 = !DILocation(line: 415, column: 21, scope: !332)
!459 = !DILocation(line: 415, column: 29, scope: !332)
!460 = !DILocation(line: 415, column: 27, scope: !332)
!461 = !DILocation(line: 415, column: 19, scope: !332)
!462 = !DILocation(line: 416, column: 22, scope: !332)
!463 = !DILocation(line: 416, column: 19, scope: !332)
!464 = !DILocation(line: 416, column: 13, scope: !332)
!465 = !DILocation(line: 417, column: 23, scope: !332)
!466 = !DILocation(line: 419, column: 63, scope: !332)
!467 = !DILocation(line: 419, column: 60, scope: !332)
!468 = !DILocation(line: 419, column: 13, scope: !332)
!469 = !DILocation(line: 421, column: 23, scope: !332)
!470 = !DILocation(line: 423, column: 69, scope: !332)
!471 = !DILocation(line: 423, column: 13, scope: !332)
!472 = !DILocation(line: 426, column: 13, scope: !332)
!473 = !DILocation(line: 430, column: 13, scope: !332)
!474 = !DILocation(line: 433, column: 48, scope: !332)
!475 = !DILocation(line: 433, column: 22, scope: !332)
!476 = !DILocation(line: 433, column: 19, scope: !332)
!477 = !DILocation(line: 433, column: 13, scope: !332)
!478 = !DILocation(line: 436, column: 34, scope: !332)
!479 = !DILocation(line: 436, column: 39, scope: !332)
!480 = !DILocation(line: 436, column: 50, scope: !332)
!481 = !DILocation(line: 436, column: 17, scope: !332)
!482 = !DILocation(line: 452, column: 49, scope: !332)
!483 = !DILocation(line: 452, column: 64, scope: !332)
!484 = !DILocation(line: 452, column: 31, scope: !332)
!485 = !DILocation(line: 453, column: 40, scope: !332)
!486 = !DILocation(line: 453, column: 17, scope: !332)
!487 = !DILocation(line: 454, column: 50, scope: !332)
!488 = !DILocation(line: 454, column: 66, scope: !332)
!489 = !DILocation(line: 454, column: 32, scope: !332)
!490 = !DILocation(line: 455, column: 40, scope: !332)
!491 = !DILocation(line: 455, column: 17, scope: !332)
!492 = !DILocation(line: 456, column: 17, scope: !332)
!493 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit", scope: null, file: !494, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!494 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/filters/wse3.csl", directory: "")
!495 = !DILocation(line: 24, column: 3, scope: !496)
!496 = !DILexicalBlockFile(scope: !493, file: !494, discriminator: 0)
!497 = !DILocation(line: 24, column: 22, scope: !496)
!498 = !DILocation(line: 23, column: 3, scope: !496)
!499 = !DILocation(line: 22, column: 3, scope: !496)
!500 = !DILocation(line: 20, column: 37, scope: !496)
!501 = !DILocation(line: 20, column: 21, scope: !496)
!502 = !DILocation(line: 21, column: 11, scope: !496)
!503 = !DILocation(line: 21, column: 17, scope: !496)
!504 = !DILocation(line: 21, column: 3, scope: !496)
!505 = !DILocation(line: 22, column: 24, scope: !496)
!506 = !DILocation(line: 22, column: 30, scope: !496)
!507 = !DILocation(line: 23, column: 40, scope: !496)
!508 = !DILocation(line: 23, column: 22, scope: !496)
!509 = !DILocation(line: 23, column: 67, scope: !496)
!510 = !DILocation(line: 24, column: 26, scope: !496)
!511 = !DILocation(line: 24, column: 41, scope: !496)
!512 = !DILocation(line: 24, column: 39, scope: !496)
!513 = !DILocation(line: 24, column: 61, scope: !496)
!514 = !DILocation(line: 24, column: 76, scope: !496)
!515 = !DILocation(line: 24, column: 74, scope: !496)
!516 = !DILocation(line: 25, column: 21, scope: !496)
!517 = !DILocation(line: 25, column: 50, scope: !496)
!518 = !DILocation(line: 25, column: 3, scope: !496)
!519 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter", scope: null, file: !494, line: 30, type: !5, scopeLine: 30, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!520 = !DILocation(line: 30, column: 36, scope: !521)
!521 = !DILexicalBlockFile(scope: !519, file: !494, discriminator: 0)
!522 = !DILocation(line: 30, column: 20, scope: !521)
!523 = !DILocation(line: 31, column: 11, scope: !521)
!524 = !DILocation(line: 31, column: 23, scope: !521)
!525 = !DILocation(line: 31, column: 3, scope: !521)
!526 = !DILocation(line: 32, column: 21, scope: !521)
!527 = !DILocation(line: 32, column: 48, scope: !521)
!528 = !DILocation(line: 32, column: 60, scope: !521)
!529 = !DILocation(line: 32, column: 64, scope: !521)
!530 = !DILocation(line: 32, column: 3, scope: !521)
!531 = !DILocation(line: 30, column: 1, scope: !521)
!532 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter", scope: null, file: !494, line: 40, type: !5, scopeLine: 40, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!533 = !DILocation(line: 47, column: 3, scope: !534)
!534 = !DILexicalBlockFile(scope: !532, file: !494, discriminator: 0)
!535 = !DILocation(line: 48, column: 7, scope: !534)
!536 = !DILocation(line: 44, column: 3, scope: !534)
!537 = !DILocation(line: 43, column: 3, scope: !534)
!538 = !DILocation(line: 42, column: 3, scope: !534)
!539 = !DILocation(line: 40, column: 32, scope: !534)
!540 = !DILocation(line: 40, column: 16, scope: !534)
!541 = !DILocation(line: 41, column: 11, scope: !534)
!542 = !DILocation(line: 41, column: 19, scope: !534)
!543 = !DILocation(line: 41, column: 3, scope: !534)
!544 = !DILocation(line: 42, column: 40, scope: !534)
!545 = !DILocation(line: 42, column: 22, scope: !534)
!546 = !DILocation(line: 43, column: 26, scope: !534)
!547 = !DILocation(line: 43, column: 34, scope: !534)
!548 = !DILocation(line: 44, column: 25, scope: !534)
!549 = !DILocation(line: 44, column: 42, scope: !534)
!550 = !DILocation(line: 44, column: 40, scope: !534)
!551 = !DILocation(line: 45, column: 21, scope: !534)
!552 = !DILocation(line: 46, column: 35, scope: !534)
!553 = !DILocation(line: 46, column: 21, scope: !534)
!554 = !DILocation(line: 46, column: 50, scope: !534)
!555 = !DILocation(line: 45, column: 3, scope: !534)
!556 = !DILocation(line: 48, column: 11, scope: !534)
!557 = !DILocation(line: 48, column: 26, scope: !534)
!558 = !DILocation(line: 48, column: 43, scope: !534)
!559 = !DILocation(line: 48, column: 41, scope: !534)
!560 = !DILocation(line: 48, column: 54, scope: !534)
!561 = !DILocation(line: 48, column: 63, scope: !534)
!562 = !DILocation(line: 49, column: 21, scope: !534)
!563 = !DILocation(line: 49, column: 47, scope: !534)
!564 = !DILocation(line: 49, column: 3, scope: !534)
!565 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config", scope: null, file: !566, line: 33, type: !5, scopeLine: 33, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!566 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/filters/common.csl", directory: "")
!567 = !DILocation(line: 33, column: 46, scope: !568)
!568 = !DILexicalBlockFile(scope: !565, file: !566, discriminator: 0)
!569 = !DILocation(line: 33, column: 31, scope: !568)
!570 = !DILocation(line: 33, column: 15, scope: !568)
!571 = !DILocation(line: 34, column: 24, scope: !568)
!572 = !DILocation(line: 34, column: 23, scope: !568)
!573 = !DILocation(line: 34, column: 51, scope: !568)
!574 = !DILocation(line: 34, column: 35, scope: !568)
!575 = !DILocation(line: 34, column: 60, scope: !568)
!576 = !DILocation(line: 34, column: 73, scope: !568)
!577 = !DILocation(line: 34, column: 3, scope: !568)
!578 = !DILocation(line: 33, column: 1, scope: !568)
!579 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config", scope: null, file: !566, line: 38, type: !5, scopeLine: 38, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!580 = !DILocation(line: 38, column: 31, scope: !581)
!581 = !DILexicalBlockFile(scope: !579, file: !566, discriminator: 0)
!582 = !DILocation(line: 38, column: 15, scope: !581)
!583 = !DILocation(line: 39, column: 31, scope: !581)
!584 = !DILocation(line: 39, column: 30, scope: !581)
!585 = !DILocation(line: 39, column: 58, scope: !581)
!586 = !DILocation(line: 39, column: 42, scope: !581)
!587 = !DILocation(line: 39, column: 67, scope: !581)
!588 = !DILocation(line: 39, column: 10, scope: !581)
!589 = !DILocation(line: 39, column: 3, scope: !581)
!590 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit", scope: null, file: !591, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!591 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/teardown.csl", directory: "")
!592 = !DILocation(line: 43, column: 3, scope: !593)
!593 = !DILexicalBlockFile(scope: !590, file: !591, discriminator: 0)
!594 = !DILocation(line: 41, column: 3, scope: !593)
!595 = !DILocation(line: 40, column: 3, scope: !593)
!596 = !DILocation(line: 39, column: 9, scope: !593)
!597 = !DILocation(line: 40, column: 23, scope: !593)
!598 = !DILocation(line: 41, column: 70, scope: !593)
!599 = !DILocation(line: 41, column: 68, scope: !593)
!600 = !DILocation(line: 43, column: 27, scope: !593)
!601 = !DILocation(line: 43, column: 15, scope: !593)
!602 = !DILocation(line: 44, column: 15, scope: !593)
!603 = !DILocation(line: 44, column: 21, scope: !593)
!604 = !DILocation(line: 44, column: 27, scope: !593)
!605 = !DILocation(line: 44, column: 3, scope: !593)
!606 = !DILocation(line: 39, column: 1, scope: !593)
!607 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord", scope: null, file: !608, line: 4, type: !5, scopeLine: 4, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!608 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/layout.csl", directory: "")
!609 = !DILocation(line: 5, column: 10, scope: !610)
!610 = !DILexicalBlockFile(scope: !607, file: !608, discriminator: 0)
!611 = !DILocation(line: 5, column: 67, scope: !610)
!612 = !DILocation(line: 5, column: 3, scope: !610)
!613 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord", scope: null, file: !608, line: 8, type: !5, scopeLine: 8, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!614 = !DILocation(line: 9, column: 10, scope: !615)
!615 = !DILexicalBlockFile(scope: !613, file: !608, discriminator: 0)
!616 = !DILocation(line: 9, column: 67, scope: !615)
!617 = !DILocation(line: 9, column: 3, scope: !615)
!618 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord", scope: null, file: !619, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!619 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config.csl", directory: "")
!620 = !DILocation(line: 50, column: 3, scope: !621)
!621 = !DILexicalBlockFile(scope: !618, file: !619, discriminator: 0)
!622 = !DILocation(line: 43, column: 21, scope: !621)
!623 = !DILocation(line: 50, column: 57, scope: !621)
!624 = !DILocation(line: 50, column: 68, scope: !621)
!625 = !DILocation(line: 50, column: 41, scope: !621)
!626 = !DILocation(line: 50, column: 19, scope: !621)
!627 = !DILocation(line: 52, column: 10, scope: !621)
!628 = !DILocation(line: 52, column: 18, scope: !621)
!629 = !DILocation(line: 48, column: 22, scope: !621)
!630 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.get_x_coord", scope: null, file: !631, line: 171, type: !5, scopeLine: 171, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!631 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpyd2h.csl", directory: "")
!632 = !DILocation(line: 172, column: 12, scope: !633)
!633 = !DILexicalBlockFile(scope: !630, file: !631, discriminator: 0)
!634 = !DILocation(line: 172, column: 5, scope: !633)
!635 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.get_y_coord", scope: null, file: !631, line: 174, type: !5, scopeLine: 174, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!636 = !DILocation(line: 175, column: 12, scope: !637)
!637 = !DILexicalBlockFile(scope: !635, file: !631, discriminator: 0)
!638 = !DILocation(line: 175, column: 5, scope: !637)
!639 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval", scope: null, file: !631, line: 187, type: !5, scopeLine: 187, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!640 = !DILocation(line: 187, column: 23, scope: !641)
!641 = !DILexicalBlockFile(scope: !639, file: !631, discriminator: 0)
!642 = !DILocation(line: 188, column: 9, scope: !641)
!643 = !DILocation(line: 188, column: 20, scope: !641)
!644 = !DILocation(line: 188, column: 5, scope: !641)
!645 = !DILocation(line: 191, column: 23, scope: !641)
!646 = !DILocation(line: 191, column: 20, scope: !641)
!647 = !DILocation(line: 191, column: 9, scope: !641)
!648 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start", scope: null, file: !631, line: 383, type: !5, scopeLine: 383, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!649 = !DILocation(line: 386, column: 5, scope: !650)
!650 = !DILexicalBlockFile(scope: !648, file: !631, discriminator: 0)
!651 = !DILocation(line: 384, column: 72, scope: !650)
!652 = !DILocation(line: 384, column: 59, scope: !650)
!653 = !DILocation(line: 384, column: 46, scope: !650)
!654 = !DILocation(line: 384, column: 33, scope: !650)
!655 = !DILocation(line: 384, column: 19, scope: !650)
!656 = !DILocation(line: 384, column: 5, scope: !650)
!657 = !DILocation(line: 383, column: 32, scope: !650)
!658 = !DILocation(line: 383, column: 21, scope: !650)
!659 = !DILocation(line: 386, column: 26, scope: !650)
!660 = !DILocation(line: 388, column: 28, scope: !650)
!661 = !DILocation(line: 388, column: 17, scope: !650)
!662 = !DILocation(line: 389, column: 25, scope: !650)
!663 = !DILocation(line: 389, column: 23, scope: !650)
!664 = !DILocation(line: 391, column: 38, scope: !650)
!665 = !DILocation(line: 391, column: 20, scope: !650)
!666 = !DILocation(line: 391, column: 18, scope: !650)
!667 = !DILocation(line: 393, column: 7, scope: !650)
!668 = !DILocation(line: 395, column: 17, scope: !650)
!669 = !DILocation(line: 395, column: 15, scope: !650)
!670 = !DILocation(line: 397, column: 15, scope: !650)
!671 = !DILocation(line: 397, column: 13, scope: !650)
!672 = !DILocation(line: 398, column: 15, scope: !650)
!673 = !DILocation(line: 398, column: 25, scope: !650)
!674 = !DILocation(line: 398, column: 23, scope: !650)
!675 = !DILocation(line: 398, column: 31, scope: !650)
!676 = !DILocation(line: 398, column: 13, scope: !650)
!677 = !DILocation(line: 401, column: 10, scope: !650)
!678 = !DILocation(line: 401, column: 17, scope: !650)
!679 = !DILocation(line: 401, column: 14, scope: !650)
!680 = !DILocation(line: 401, column: 5, scope: !650)
!681 = !DILocation(line: 403, column: 48, scope: !650)
!682 = !DILocation(line: 403, column: 26, scope: !650)
!683 = !DILocation(line: 404, column: 26, scope: !650)
!684 = !DILocation(line: 404, column: 18, scope: !650)
!685 = !DILocation(line: 407, column: 48, scope: !650)
!686 = !DILocation(line: 407, column: 26, scope: !650)
!687 = !DILocation(line: 408, column: 27, scope: !650)
!688 = !DILocation(line: 408, column: 18, scope: !650)
!689 = !DILocation(line: 411, column: 14, scope: !650)
!690 = !DILocation(line: 414, column: 14, scope: !650)
!691 = !DILocation(line: 414, column: 11, scope: !650)
!692 = !DILocation(line: 414, column: 5, scope: !650)
!693 = !DILocation(line: 416, column: 44, scope: !650)
!694 = !DILocation(line: 416, column: 75, scope: !650)
!695 = !DILocation(line: 416, column: 59, scope: !650)
!696 = !DILocation(line: 416, column: 25, scope: !650)
!697 = !DILocation(line: 416, column: 23, scope: !650)
!698 = !DILocation(line: 418, column: 41, scope: !650)
!699 = !DILocation(line: 418, column: 23, scope: !650)
!700 = !DILocation(line: 419, column: 9, scope: !650)
!701 = !DILocation(line: 425, column: 44, scope: !650)
!702 = !DILocation(line: 425, column: 23, scope: !650)
!703 = !DILocation(line: 426, column: 41, scope: !650)
!704 = !DILocation(line: 426, column: 23, scope: !650)
!705 = !DILocation(line: 427, column: 9, scope: !650)
!706 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x", scope: null, file: !631, line: 448, type: !5, scopeLine: 448, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!707 = !DILocation(line: 448, column: 31, scope: !708)
!708 = !DILexicalBlockFile(scope: !706, file: !631, discriminator: 0)
!709 = !DILocation(line: 453, column: 5, scope: !708)
!710 = !DILocation(line: 456, column: 19, scope: !708)
!711 = !DILocation(line: 456, column: 17, scope: !708)
!712 = !DILocation(line: 461, column: 5, scope: !708)
!713 = !DILocation(line: 462, column: 28, scope: !708)
!714 = !DILocation(line: 462, column: 5, scope: !708)
!715 = !DILocation(line: 463, column: 5, scope: !708)
!716 = !DILocation(line: 464, column: 9, scope: !708)
!717 = !DILocation(line: 464, column: 10, scope: !708)
!718 = !DILocation(line: 464, column: 7, scope: !708)
!719 = !DILocation(line: 448, column: 1, scope: !708)
!720 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_send_data", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_send_data", scope: null, file: !631, line: 476, type: !5, scopeLine: 476, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!721 = !DILocation(line: 494, column: 9, scope: !722)
!722 = !DILexicalBlockFile(scope: !720, file: !631, discriminator: 0)
!723 = !DILocation(line: 478, column: 9, scope: !722)
!724 = !DILocation(line: 478, column: 13, scope: !722)
!725 = !DILocation(line: 478, column: 11, scope: !722)
!726 = !DILocation(line: 478, column: 5, scope: !722)
!727 = !DILocation(line: 479, column: 9, scope: !722)
!728 = !DILocation(line: 480, column: 32, scope: !722)
!729 = !DILocation(line: 480, column: 9, scope: !722)
!730 = !DILocation(line: 481, column: 17, scope: !722)
!731 = !DILocation(line: 481, column: 15, scope: !722)
!732 = !DILocation(line: 481, column: 9, scope: !722)
!733 = !DILocation(line: 482, column: 13, scope: !722)
!734 = !DILocation(line: 483, column: 51, scope: !722)
!735 = !DILocation(line: 483, column: 29, scope: !722)
!736 = !DILocation(line: 483, column: 27, scope: !722)
!737 = !DILocation(line: 485, column: 13, scope: !722)
!738 = !DILocation(line: 486, column: 51, scope: !722)
!739 = !DILocation(line: 486, column: 29, scope: !722)
!740 = !DILocation(line: 486, column: 27, scope: !722)
!741 = !DILocation(line: 488, column: 13, scope: !722)
!742 = !DILocation(line: 488, column: 14, scope: !722)
!743 = !DILocation(line: 488, column: 11, scope: !722)
!744 = !DILocation(line: 494, column: 30, scope: !722)
!745 = !DILocation(line: 496, column: 14, scope: !722)
!746 = !DILocation(line: 496, column: 25, scope: !722)
!747 = !DILocation(line: 496, column: 22, scope: !722)
!748 = !DILocation(line: 496, column: 9, scope: !722)
!749 = !DILocation(line: 497, column: 13, scope: !722)
!750 = !DILocation(line: 498, column: 13, scope: !722)
!751 = !DILocation(line: 499, column: 13, scope: !722)
!752 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl", scope: null, file: !631, line: 505, type: !5, scopeLine: 505, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!753 = !DILocation(line: 524, column: 13, scope: !754)
!754 = !DILexicalBlockFile(scope: !752, file: !631, discriminator: 0)
!755 = !DILocation(line: 506, column: 14, scope: !754)
!756 = !DILocation(line: 506, column: 11, scope: !754)
!757 = !DILocation(line: 506, column: 5, scope: !754)
!758 = !DILocation(line: 508, column: 9, scope: !754)
!759 = !DILocation(line: 509, column: 32, scope: !754)
!760 = !DILocation(line: 509, column: 9, scope: !754)
!761 = !DILocation(line: 510, column: 9, scope: !754)
!762 = !DILocation(line: 514, column: 13, scope: !754)
!763 = !DILocation(line: 514, column: 17, scope: !754)
!764 = !DILocation(line: 514, column: 15, scope: !754)
!765 = !DILocation(line: 514, column: 9, scope: !754)
!766 = !DILocation(line: 518, column: 13, scope: !754)
!767 = !DILocation(line: 519, column: 36, scope: !754)
!768 = !DILocation(line: 519, column: 13, scope: !754)
!769 = !DILocation(line: 520, column: 13, scope: !754)
!770 = !DILocation(line: 524, column: 34, scope: !754)
!771 = !DILocation(line: 526, column: 18, scope: !754)
!772 = !DILocation(line: 526, column: 29, scope: !754)
!773 = !DILocation(line: 526, column: 26, scope: !754)
!774 = !DILocation(line: 526, column: 13, scope: !754)
!775 = !DILocation(line: 529, column: 17, scope: !754)
!776 = !DILocation(line: 530, column: 17, scope: !754)
!777 = !DILocation(line: 531, column: 17, scope: !754)
!778 = !DILocation(line: 534, column: 17, scope: !754)
!779 = !DILocation(line: 535, column: 40, scope: !754)
!780 = !DILocation(line: 535, column: 17, scope: !754)
!781 = !DILocation(line: 536, column: 17, scope: !754)
!782 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.d2h_configure", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.d2h_configure", scope: null, file: !631, line: 593, type: !5, scopeLine: 593, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!783 = !DILocation(line: 617, column: 26, scope: !784)
!784 = !DILexicalBlockFile(scope: !782, file: !631, discriminator: 0)
!785 = !DILocation(line: 612, column: 47, scope: !784)
!786 = !DILocation(line: 612, column: 27, scope: !784)
!787 = !DILocation(line: 602, column: 5, scope: !784)
!788 = !DILocation(line: 601, column: 5, scope: !784)
!789 = !DILocation(line: 599, column: 5, scope: !784)
!790 = !DILocation(line: 598, column: 5, scope: !784)
!791 = !DILocation(line: 596, column: 5, scope: !784)
!792 = !DILocation(line: 595, column: 5, scope: !784)
!793 = !DILocation(line: 593, column: 86, scope: !784)
!794 = !DILocation(line: 593, column: 70, scope: !784)
!795 = !DILocation(line: 593, column: 60, scope: !784)
!796 = !DILocation(line: 593, column: 52, scope: !784)
!797 = !DILocation(line: 593, column: 44, scope: !784)
!798 = !DILocation(line: 593, column: 35, scope: !784)
!799 = !DILocation(line: 593, column: 26, scope: !784)
!800 = !DILocation(line: 593, column: 18, scope: !784)
!801 = !DILocation(line: 595, column: 26, scope: !784)
!802 = !DILocation(line: 596, column: 26, scope: !784)
!803 = !DILocation(line: 598, column: 23, scope: !784)
!804 = !DILocation(line: 599, column: 23, scope: !784)
!805 = !DILocation(line: 599, column: 28, scope: !784)
!806 = !DILocation(line: 599, column: 26, scope: !784)
!807 = !DILocation(line: 599, column: 29, scope: !784)
!808 = !DILocation(line: 601, column: 24, scope: !784)
!809 = !DILocation(line: 602, column: 24, scope: !784)
!810 = !DILocation(line: 602, column: 29, scope: !784)
!811 = !DILocation(line: 602, column: 27, scope: !784)
!812 = !DILocation(line: 602, column: 30, scope: !784)
!813 = !DILocation(line: 611, column: 20, scope: !784)
!814 = !DILocation(line: 612, column: 11, scope: !784)
!815 = !DILocation(line: 612, column: 18, scope: !784)
!816 = !DILocation(line: 612, column: 15, scope: !784)
!817 = !DILocation(line: 612, column: 32, scope: !784)
!818 = !DILocation(line: 612, column: 39, scope: !784)
!819 = !DILocation(line: 612, column: 36, scope: !784)
!820 = !DILocation(line: 612, column: 52, scope: !784)
!821 = !DILocation(line: 612, column: 59, scope: !784)
!822 = !DILocation(line: 612, column: 56, scope: !784)
!823 = !DILocation(line: 612, column: 5, scope: !784)
!824 = !DILocation(line: 613, column: 24, scope: !784)
!825 = !DILocation(line: 616, column: 15, scope: !784)
!826 = !DILocation(line: 617, column: 11, scope: !784)
!827 = !DILocation(line: 617, column: 18, scope: !784)
!828 = !DILocation(line: 617, column: 15, scope: !784)
!829 = !DILocation(line: 617, column: 30, scope: !784)
!830 = !DILocation(line: 617, column: 5, scope: !784)
!831 = !DILocation(line: 618, column: 19, scope: !784)
!832 = !DILocation(line: 621, column: 9, scope: !784)
!833 = !DILocation(line: 621, column: 5, scope: !784)
!834 = !DILocation(line: 627, column: 9, scope: !784)
!835 = !DILocation(line: 629, column: 13, scope: !784)
!836 = !DILocation(line: 629, column: 25, scope: !784)
!837 = !DILocation(line: 629, column: 21, scope: !784)
!838 = !DILocation(line: 629, column: 9, scope: !784)
!839 = !DILocation(line: 632, column: 13, scope: !784)
!840 = !DILocation(line: 636, column: 13, scope: !784)
!841 = !DILocation(line: 641, column: 9, scope: !784)
!842 = !DILocation(line: 646, column: 13, scope: !784)
!843 = !DILocation(line: 646, column: 9, scope: !784)
!844 = !DILocation(line: 647, column: 30, scope: !784)
!845 = !DILocation(line: 647, column: 35, scope: !784)
!846 = !DILocation(line: 647, column: 46, scope: !784)
!847 = !DILocation(line: 647, column: 50, scope: !784)
!848 = !DILocation(line: 647, column: 54, scope: !784)
!849 = !DILocation(line: 647, column: 57, scope: !784)
!850 = !DILocation(line: 647, column: 60, scope: !784)
!851 = !DILocation(line: 647, column: 63, scope: !784)
!852 = !DILocation(line: 647, column: 13, scope: !784)
!853 = !DILocation(line: 661, column: 9, scope: !784)
!854 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit", scope: null, file: !591, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!855 = !DILocation(line: 43, column: 3, scope: !856)
!856 = !DILexicalBlockFile(scope: !854, file: !591, discriminator: 0)
!857 = !DILocation(line: 41, column: 3, scope: !856)
!858 = !DILocation(line: 40, column: 3, scope: !856)
!859 = !DILocation(line: 39, column: 9, scope: !856)
!860 = !DILocation(line: 40, column: 23, scope: !856)
!861 = !DILocation(line: 41, column: 70, scope: !856)
!862 = !DILocation(line: 41, column: 68, scope: !856)
!863 = !DILocation(line: 43, column: 27, scope: !856)
!864 = !DILocation(line: 43, column: 15, scope: !856)
!865 = !DILocation(line: 44, column: 15, scope: !856)
!866 = !DILocation(line: 44, column: 21, scope: !856)
!867 = !DILocation(line: 44, column: 27, scope: !856)
!868 = !DILocation(line: 44, column: 3, scope: !856)
!869 = !DILocation(line: 39, column: 1, scope: !856)
!870 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord", scope: null, file: !608, line: 4, type: !5, scopeLine: 4, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!871 = !DILocation(line: 5, column: 10, scope: !872)
!872 = !DILexicalBlockFile(scope: !870, file: !608, discriminator: 0)
!873 = !DILocation(line: 5, column: 67, scope: !872)
!874 = !DILocation(line: 5, column: 3, scope: !872)
!875 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord", scope: null, file: !608, line: 8, type: !5, scopeLine: 8, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!876 = !DILocation(line: 9, column: 10, scope: !877)
!877 = !DILexicalBlockFile(scope: !875, file: !608, discriminator: 0)
!878 = !DILocation(line: 9, column: 67, scope: !877)
!879 = !DILocation(line: 9, column: 3, scope: !877)
!880 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord", scope: null, file: !619, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!881 = !DILocation(line: 50, column: 3, scope: !882)
!882 = !DILexicalBlockFile(scope: !880, file: !619, discriminator: 0)
!883 = !DILocation(line: 43, column: 21, scope: !882)
!884 = !DILocation(line: 50, column: 57, scope: !882)
!885 = !DILocation(line: 50, column: 68, scope: !882)
!886 = !DILocation(line: 50, column: 41, scope: !882)
!887 = !DILocation(line: 50, column: 19, scope: !882)
!888 = !DILocation(line: 52, column: 10, scope: !882)
!889 = !DILocation(line: 52, column: 18, scope: !882)
!890 = !DILocation(line: 48, column: 22, scope: !882)
!891 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr", linkageName: "sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr", scope: null, file: !892, line: 11, type: !5, scopeLine: 11, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!892 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/input_queue_config.csl", directory: "")
!893 = !DILocation(line: 11, column: 32, scope: !894)
!894 = !DILexicalBlockFile(scope: !891, file: !892, discriminator: 0)
!895 = !DILocation(line: 12, column: 80, scope: !894)
!896 = !DILocation(line: 12, column: 69, scope: !894)
!897 = !DILocation(line: 12, column: 39, scope: !894)
!898 = !DILocation(line: 12, column: 3, scope: !894)
!899 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue", linkageName: "sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue", scope: null, file: !892, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!900 = !DILocation(line: 46, column: 3, scope: !901)
!901 = !DILexicalBlockFile(scope: !899, file: !892, discriminator: 0)
!902 = !DILocation(line: 45, column: 3, scope: !901)
!903 = !DILocation(line: 39, column: 42, scope: !901)
!904 = !DILocation(line: 39, column: 34, scope: !901)
!905 = !DILocation(line: 39, column: 24, scope: !901)
!906 = !DILocation(line: 45, column: 44, scope: !901)
!907 = !DILocation(line: 45, column: 16, scope: !901)
!908 = !DILocation(line: 46, column: 30, scope: !901)
!909 = !DILocation(line: 46, column: 18, scope: !901)
!910 = !DILocation(line: 56, column: 9, scope: !901)
!911 = !DILocation(line: 56, column: 5, scope: !901)
!912 = !DILocation(line: 58, column: 13, scope: !901)
!913 = !DILocation(line: 58, column: 17, scope: !901)
!914 = !DILocation(line: 58, column: 11, scope: !901)
!915 = !DILocation(line: 61, column: 13, scope: !901)
!916 = !DILocation(line: 61, column: 17, scope: !901)
!917 = !DILocation(line: 61, column: 11, scope: !901)
!918 = !DILocation(line: 66, column: 9, scope: !901)
!919 = !DILocation(line: 66, column: 13, scope: !901)
!920 = !DILocation(line: 66, column: 7, scope: !901)
!921 = !DILocation(line: 68, column: 9, scope: !901)
!922 = !DILocation(line: 68, column: 24, scope: !901)
!923 = !DILocation(line: 68, column: 13, scope: !901)
!924 = !DILocation(line: 68, column: 7, scope: !901)
!925 = !DILocation(line: 70, column: 15, scope: !901)
!926 = !DILocation(line: 70, column: 21, scope: !901)
!927 = !DILocation(line: 70, column: 3, scope: !901)
!928 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr", linkageName: "sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr", scope: null, file: !929, line: 11, type: !5, scopeLine: 11, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!929 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/output_queue_config.csl", directory: "")
!930 = !DILocation(line: 11, column: 33, scope: !931)
!931 = !DILexicalBlockFile(scope: !928, file: !929, discriminator: 0)
!932 = !DILocation(line: 12, column: 82, scope: !931)
!933 = !DILocation(line: 12, column: 40, scope: !931)
!934 = !DILocation(line: 12, column: 3, scope: !931)
!935 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue", linkageName: "sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue", scope: null, file: !929, line: 31, type: !5, scopeLine: 31, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!936 = !DILocation(line: 38, column: 3, scope: !937)
!937 = !DILexicalBlockFile(scope: !935, file: !929, discriminator: 0)
!938 = !DILocation(line: 37, column: 3, scope: !937)
!939 = !DILocation(line: 31, column: 35, scope: !937)
!940 = !DILocation(line: 31, column: 25, scope: !937)
!941 = !DILocation(line: 37, column: 45, scope: !937)
!942 = !DILocation(line: 37, column: 16, scope: !937)
!943 = !DILocation(line: 38, column: 30, scope: !937)
!944 = !DILocation(line: 38, column: 18, scope: !937)
!945 = !DILocation(line: 41, column: 9, scope: !937)
!946 = !DILocation(line: 41, column: 13, scope: !937)
!947 = !DILocation(line: 41, column: 7, scope: !937)
!948 = !DILocation(line: 43, column: 9, scope: !937)
!949 = !DILocation(line: 43, column: 24, scope: !937)
!950 = !DILocation(line: 43, column: 13, scope: !937)
!951 = !DILocation(line: 43, column: 27, scope: !937)
!952 = !DILocation(line: 43, column: 7, scope: !937)
!953 = !DILocation(line: 45, column: 15, scope: !937)
!954 = !DILocation(line: 45, column: 21, scope: !937)
!955 = !DILocation(line: 45, column: 3, scope: !937)
!956 = !DILocation(line: 31, column: 1, scope: !937)
!957 = distinct !DISubprogram(name: ".get_tensor_ptr", linkageName: ".get_tensor_ptr", scope: null, file: !4, line: 1, type: !5, scopeLine: 1, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!958 = !DILocation(line: 1, column: 1, scope: !959)
!959 = !DILexicalBlockFile(scope: !957, file: !4, discriminator: 0)
!960 = distinct !DISubprogram(name: "__generic0sys_mod.sys_mod.tile_config.queue_flush.exit", linkageName: "__generic0sys_mod.sys_mod.tile_config.queue_flush.exit", scope: null, file: !961, line: 12, type: !5, scopeLine: 12, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!961 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/queue_flush.csl", directory: "")
!962 = !DILocation(line: 24, column: 3, scope: !963)
!963 = !DILexicalBlockFile(scope: !960, file: !961, discriminator: 0)
!964 = !DILocation(line: 12, column: 1, scope: !963)
!965 = distinct !DISubprogram(name: "__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position", linkageName: "__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position", scope: null, file: !966, line: 30, type: !5, scopeLine: 30, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!966 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/switch_config.csl", directory: "")
!967 = !DILocation(line: 34, column: 3, scope: !968)
!968 = !DILexicalBlockFile(scope: !965, file: !966, discriminator: 0)
!969 = !DILocation(line: 32, column: 3, scope: !968)
!970 = !DILocation(line: 30, column: 27, scope: !968)
!971 = !DILocation(line: 33, column: 7, scope: !968)
!972 = !DILocation(line: 34, column: 36, scope: !968)
!973 = !DILocation(line: 34, column: 24, scope: !968)
!974 = !DILocation(line: 35, column: 3, scope: !968)
!975 = !DILocation(line: 35, column: 18, scope: !968)
!976 = !DILocation(line: 36, column: 15, scope: !968)
!977 = !DILocation(line: 36, column: 21, scope: !968)
!978 = !DILocation(line: 36, column: 3, scope: !968)
!979 = !DILocation(line: 30, column: 1, scope: !968)
!980 = distinct !DISubprogram(name: "__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", linkageName: "__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", scope: null, file: !981, line: 96, type: !5, scopeLine: 96, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!981 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/color_config.csl", directory: "")
!982 = !DILocation(line: 99, column: 3, scope: !983)
!983 = !DILexicalBlockFile(scope: !980, file: !981, discriminator: 0)
!984 = !DILocation(line: 98, column: 3, scope: !983)
!985 = !DILocation(line: 96, column: 17, scope: !983)
!986 = !DILocation(line: 98, column: 16, scope: !983)
!987 = !DILocation(line: 99, column: 29, scope: !983)
!988 = !DILocation(line: 99, column: 17, scope: !983)
!989 = !DILocation(line: 100, column: 13, scope: !983)
!990 = !DILocation(line: 100, column: 21, scope: !983)
!991 = !DILocation(line: 100, column: 11, scope: !983)
!992 = !DILocation(line: 104, column: 7, scope: !983)
!993 = !DILocation(line: 104, column: 50, scope: !983)
!994 = !DILocation(line: 104, column: 18, scope: !983)
!995 = !DILocation(line: 104, column: 15, scope: !983)
!996 = !DILocation(line: 121, column: 7, scope: !983)
!997 = !DILocation(line: 121, column: 50, scope: !983)
!998 = !DILocation(line: 121, column: 18, scope: !983)
!999 = !DILocation(line: 121, column: 15, scope: !983)
!1000 = !DILocation(line: 128, column: 15, scope: !983)
!1001 = !DILocation(line: 128, column: 21, scope: !983)
!1002 = !DILocation(line: 128, column: 3, scope: !983)
!1003 = !DILocation(line: 96, column: 1, scope: !983)
!1004 = distinct !DISubprogram(name: "__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", linkageName: "__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", scope: null, file: !981, line: 96, type: !5, scopeLine: 96, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1005 = !DILocation(line: 99, column: 3, scope: !1006)
!1006 = !DILexicalBlockFile(scope: !1004, file: !981, discriminator: 0)
!1007 = !DILocation(line: 98, column: 3, scope: !1006)
!1008 = !DILocation(line: 96, column: 17, scope: !1006)
!1009 = !DILocation(line: 98, column: 16, scope: !1006)
!1010 = !DILocation(line: 99, column: 29, scope: !1006)
!1011 = !DILocation(line: 99, column: 17, scope: !1006)
!1012 = !DILocation(line: 100, column: 13, scope: !1006)
!1013 = !DILocation(line: 100, column: 21, scope: !1006)
!1014 = !DILocation(line: 100, column: 11, scope: !1006)
!1015 = !DILocation(line: 104, column: 7, scope: !1006)
!1016 = !DILocation(line: 104, column: 50, scope: !1006)
!1017 = !DILocation(line: 104, column: 18, scope: !1006)
!1018 = !DILocation(line: 104, column: 15, scope: !1006)
!1019 = !DILocation(line: 121, column: 7, scope: !1006)
!1020 = !DILocation(line: 121, column: 50, scope: !1006)
!1021 = !DILocation(line: 121, column: 18, scope: !1006)
!1022 = !DILocation(line: 121, column: 15, scope: !1006)
!1023 = !DILocation(line: 128, column: 15, scope: !1006)
!1024 = !DILocation(line: 128, column: 21, scope: !1006)
!1025 = !DILocation(line: 128, column: 3, scope: !1006)
!1026 = !DILocation(line: 96, column: 1, scope: !1006)
!1027 = distinct !DISubprogram(name: "__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", linkageName: "__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", scope: null, file: !981, line: 60, type: !5, scopeLine: 60, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1028 = !DILocation(line: 61, column: 3, scope: !1029)
!1029 = !DILexicalBlockFile(scope: !1027, file: !981, discriminator: 0)
!1030 = !DILocation(line: 60, column: 46, scope: !1029)
!1031 = !DILocation(line: 61, column: 16, scope: !1029)
!1032 = !DILocation(line: 72, column: 5, scope: !1029)
!1033 = !DILocation(line: 72, column: 12, scope: !1029)
!1034 = !DILocation(line: 74, column: 10, scope: !1029)
!1035 = !DILocation(line: 74, column: 3, scope: !1029)
!1036 = distinct !DISubprogram(name: "__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes", linkageName: "__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes", scope: null, file: !981, line: 77, type: !5, scopeLine: 77, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1037 = !DILocation(line: 78, column: 3, scope: !1038)
!1038 = !DILexicalBlockFile(scope: !1036, file: !981, discriminator: 0)
!1039 = !DILocation(line: 77, column: 46, scope: !1038)
!1040 = !DILocation(line: 78, column: 16, scope: !1038)
!1041 = !DILocation(line: 86, column: 5, scope: !1038)
!1042 = !DILocation(line: 86, column: 12, scope: !1038)
!1043 = !DILocation(line: 91, column: 10, scope: !1038)
!1044 = !DILocation(line: 91, column: 3, scope: !1038)
!1045 = distinct !DISubprogram(name: "__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", linkageName: "__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", scope: null, file: !981, line: 60, type: !5, scopeLine: 60, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1046 = !DILocation(line: 61, column: 3, scope: !1047)
!1047 = !DILexicalBlockFile(scope: !1045, file: !981, discriminator: 0)
!1048 = !DILocation(line: 60, column: 46, scope: !1047)
!1049 = !DILocation(line: 61, column: 16, scope: !1047)
!1050 = !DILocation(line: 63, column: 5, scope: !1047)
!1051 = !DILocation(line: 63, column: 12, scope: !1047)
!1052 = !DILocation(line: 74, column: 10, scope: !1047)
!1053 = !DILocation(line: 74, column: 3, scope: !1047)
!1054 = distinct !DISubprogram(name: "__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction", linkageName: "__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction", scope: null, file: !981, line: 52, type: !5, scopeLine: 52, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1055 = !DILocation(line: 55, column: 3, scope: !1056)
!1056 = !DILexicalBlockFile(scope: !1054, file: !981, discriminator: 0)
!1057 = !DILocation(line: 54, column: 3, scope: !1056)
!1058 = !DILocation(line: 52, column: 23, scope: !1056)
!1059 = !DILocation(line: 54, column: 16, scope: !1056)
!1060 = !DILocation(line: 55, column: 29, scope: !1056)
!1061 = !DILocation(line: 55, column: 17, scope: !1056)
!1062 = !DILocation(line: 56, column: 3, scope: !1056)
!1063 = !DILocation(line: 56, column: 11, scope: !1056)
!1064 = !DILocation(line: 57, column: 15, scope: !1056)
!1065 = !DILocation(line: 57, column: 21, scope: !1056)
!1066 = !DILocation(line: 57, column: 3, scope: !1056)
!1067 = !DILocation(line: 52, column: 1, scope: !1056)
!1068 = distinct !DISubprogram(name: "__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction", linkageName: "__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction", scope: null, file: !981, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1069 = !DILocation(line: 23, column: 3, scope: !1070)
!1070 = !DILexicalBlockFile(scope: !1068, file: !981, discriminator: 0)
!1071 = !DILocation(line: 22, column: 3, scope: !1070)
!1072 = !DILocation(line: 20, column: 21, scope: !1070)
!1073 = !DILocation(line: 22, column: 16, scope: !1070)
!1074 = !DILocation(line: 23, column: 29, scope: !1070)
!1075 = !DILocation(line: 23, column: 17, scope: !1070)
!1076 = !DILocation(line: 24, column: 3, scope: !1070)
!1077 = !DILocation(line: 24, column: 11, scope: !1070)
!1078 = !DILocation(line: 25, column: 15, scope: !1070)
!1079 = !DILocation(line: 25, column: 21, scope: !1070)
!1080 = !DILocation(line: 25, column: 3, scope: !1070)
!1081 = !DILocation(line: 20, column: 1, scope: !1070)
module asm ".section \22.pe_debug_info\22, \22\22"
module asm ".section \22.note\22, \22\22"
