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
  store i16 1, i16* %1, align 2, !dbg !7
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
  br i1 %20, label %22, label %35, !dbg !11

22:                                               ; preds = %21
  %23 = load i16, i16* %1, align 2, !dbg !15
  %24 = sub i16 %23, 1, !dbg !16
  %25 = getelementptr [64 x i16], [64 x i16]* @c, i16 0, i16 %24, !dbg !17
  %26 = load i16, i16* %25, align 2, !dbg !17
  %27 = load i16, i16* %1, align 2, !dbg !18
  %28 = getelementptr [64 x i16], [64 x i16]* @b, i16 0, i16 %27, !dbg !19
  %29 = load i16, i16* %28, align 2, !dbg !19
  %30 = add i16 %26, %29, !dbg !20
  %31 = load i16, i16* %1, align 2, !dbg !21
  %32 = getelementptr [64 x i16], [64 x i16]* @c, i16 0, i16 %31, !dbg !22
  store i16 %30, i16* %32, align 2, !dbg !23
  %33 = load i16, i16* %1, align 2, !dbg !24
  %34 = add i16 %33, 1, !dbg !25
  store i16 %34, i16* %1, align 2, !dbg !25
  br label %4, !dbg !11

35:                                               ; preds = %21
  %36 = icmp ne i16 %11, 0, !dbg !11
  br i1 %36, label %37, label %38, !dbg !11

37:                                               ; preds = %35
  br label %39, !dbg !11

38:                                               ; preds = %35
  call void @llvm.sdr.actvt.r(i16 9), !dbg !26
  br label %39, !dbg !11

39:                                               ; preds = %37, %38
  ret void, !dbg !11
}

define void @f_exit() #0 !dbg !27 {
  call void @sys_mod.unblock_cmd_stream(), !dbg !28
  ret void, !dbg !30
}

define internal void @sys_mod.sys_nop() !dbg !31 {
  ret void, !dbg !33
}

define internal void @sys_mod.unblock_cmd_stream() !dbg !35 {
  call void @sys_mod.sys_mod.unblock_cmd_stream(), !dbg !36
  ret void, !dbg !38
}

define internal void @sys_mod.sys_mod.unblock_cmd_stream() !dbg !39 {
  call void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream(), !dbg !41
  ret void, !dbg !43
}

define internal void @sys_mod.sys_mod.teardown_h2d() !dbg !44 {
  call void @llvm.sdr.actvt.r(i16 27), !dbg !45
  ret void, !dbg !47
}

define void @sys_mod.sys_mod.f_ublk_c22() #1 !dbg !48 {
  call void @sys_mod.sys_mod.unblock_cmd_stream(), !dbg !49
  ret void, !dbg !51
}

define internal void @sys_mod.sys_mod.teardown_d2h() !dbg !52 {
  call void @llvm.sdr.blk.r(i16 0), !dbg !53
  call void @llvm.sdr.actvt.r(i16 28), !dbg !55
  ret void, !dbg !56
}

define void @sys_mod.sys_mod.f_memcpyh2d() #2 !dbg !57 {
  %1 = alloca float, i16 1, align 4, !dbg !58
  %2 = alloca float, i16 1, align 4, !dbg !60
  %3 = alloca i16, i16 1, align 2, !dbg !61
  %4 = alloca i16, i16 1, align 2, !dbg !62
  %5 = alloca i16, i16 1, align 2, !dbg !63
  %6 = alloca i16, i16 1, align 2, !dbg !64
  %7 = alloca i16, i16 1, align 2, !dbg !65
  %8 = alloca i16, i16 1, align 2, !dbg !66
  %9 = alloca i16, i16 1, align 2, !dbg !67
  %10 = alloca i16, i16 1, align 2, !dbg !68
  %11 = alloca i16, i16 1, align 2, !dbg !69
  %12 = alloca i16, i16 1, align 2, !dbg !70
  %13 = alloca i16, i16 1, align 2, !dbg !71
  %14 = alloca i16*, i16 1, align 8, !dbg !72
  %15 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !73
  %16 = icmp eq i16 %15, 15, !dbg !74
  br i1 %16, label %17, label %18, !dbg !75

17:                                               ; preds = %0
  br label %19, !dbg !75

18:                                               ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !75
  br label %19, !dbg !75

19:                                               ; preds = %17, %18
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %14, align 8, !dbg !72
  %20 = load i16*, i16** %14, align 8, !dbg !76
  %21 = load i16, i16* %20, align 2, !dbg !77
  store i16 %21, i16* %13, align 2, !dbg !71
  %22 = load i16*, i16** %14, align 8, !dbg !78
  %23 = getelementptr i16, i16* %22, i16 1, !dbg !79
  %24 = load i16, i16* %23, align 2, !dbg !79
  store i16 %24, i16* %12, align 2, !dbg !70
  %25 = load i16*, i16** %14, align 8, !dbg !80
  %26 = getelementptr i16, i16* %25, i16 2, !dbg !81
  %27 = load i16, i16* %26, align 2, !dbg !81
  store i16 %27, i16* %11, align 2, !dbg !69
  %28 = load i16*, i16** %14, align 8, !dbg !82
  %29 = getelementptr i16, i16* %28, i16 3, !dbg !83
  %30 = load i16, i16* %29, align 2, !dbg !83
  store i16 %30, i16* %10, align 2, !dbg !68
  %31 = load i16*, i16** %14, align 8, !dbg !84
  %32 = getelementptr i16, i16* %31, i16 4, !dbg !85
  %33 = load i16, i16* %32, align 2, !dbg !85
  store i16 %33, i16* %9, align 2, !dbg !67
  %34 = load i16*, i16** %14, align 8, !dbg !86
  %35 = getelementptr i16, i16* %34, i16 5, !dbg !87
  %36 = load i16, i16* %35, align 2, !dbg !87
  store i16 %36, i16* %8, align 2, !dbg !66
  %37 = load i16*, i16** %14, align 8, !dbg !88
  %38 = getelementptr i16, i16* %37, i16 6, !dbg !89
  %39 = load i16, i16* %38, align 2, !dbg !89
  store i16 %39, i16* %7, align 2, !dbg !65
  %40 = load i16*, i16** %14, align 8, !dbg !90
  %41 = getelementptr i16, i16* %40, i16 7, !dbg !91
  %42 = load i16, i16* %41, align 2, !dbg !91
  store i16 %42, i16* %6, align 2, !dbg !64
  %43 = load i16*, i16** %14, align 8, !dbg !92
  %44 = getelementptr i16, i16* %43, i16 8, !dbg !93
  %45 = load i16, i16* %44, align 2, !dbg !93
  store i16 %45, i16* %5, align 2, !dbg !63
  %46 = load i16*, i16** %14, align 8, !dbg !94
  %47 = getelementptr i16, i16* %46, i16 9, !dbg !95
  %48 = load i16, i16* %47, align 2, !dbg !95
  store i16 %48, i16* %4, align 2, !dbg !62
  %49 = load i16*, i16** %14, align 8, !dbg !96
  %50 = getelementptr i16, i16* %49, i16 10, !dbg !97
  %51 = load i16, i16* %50, align 2, !dbg !97
  store i16 %51, i16* %3, align 2, !dbg !61
  %52 = load i16*, i16** %14, align 8, !dbg !98
  %53 = getelementptr i16, i16* %52, i16 12, !dbg !99
  %54 = load i16, i16* %53, align 2, !dbg !99
  %55 = zext i16 %54 to i32, !dbg !100
  %56 = load i16*, i16** %14, align 8, !dbg !101
  %57 = getelementptr i16, i16* %56, i16 11, !dbg !102
  %58 = load i16, i16* %57, align 2, !dbg !102
  %59 = zext i16 %58 to i32, !dbg !103
  %60 = add i32 %59, 16, !dbg !104
  %61 = shl i32 %55, %60, !dbg !105
  %62 = bitcast i32 %61 to float, !dbg !106
  store float %62, float* %2, align 4, !dbg !60
  %63 = load i16*, i16** %14, align 8, !dbg !107
  %64 = getelementptr i16, i16* %63, i16 14, !dbg !108
  %65 = load i16, i16* %64, align 2, !dbg !108
  %66 = zext i16 %65 to i32, !dbg !109
  %67 = load i16*, i16** %14, align 8, !dbg !110
  %68 = getelementptr i16, i16* %67, i16 13, !dbg !111
  %69 = load i16, i16* %68, align 2, !dbg !111
  %70 = zext i16 %69 to i32, !dbg !112
  %71 = add i32 %70, 16, !dbg !113
  %72 = shl i32 %66, %71, !dbg !114
  %73 = bitcast i32 %72 to float, !dbg !115
  store float %73, float* %1, align 4, !dbg !58
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !116
  %74 = load i16, i16* %13, align 2, !dbg !117
  store i16 %74, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !118
  %75 = load i16, i16* %12, align 2, !dbg !119
  store i16 %75, i16* @sys_mod.sys_mod.memcpyH2D_px, align 2, !dbg !120
  %76 = load i16, i16* %11, align 2, !dbg !121
  store i16 %76, i16* @sys_mod.sys_mod.memcpyH2D_py, align 2, !dbg !122
  %77 = load i16, i16* %10, align 2, !dbg !123
  store i16 %77, i16* @sys_mod.sys_mod.memcpyH2D_w, align 2, !dbg !124
  %78 = load i16, i16* %9, align 2, !dbg !125
  store i16 %78, i16* @sys_mod.sys_mod.memcpyH2D_h, align 2, !dbg !126
  %79 = load i16, i16* %8, align 2, !dbg !127
  store i16 %79, i16* @sys_mod.sys_mod.memcpyH2D_addr, align 2, !dbg !128
  %80 = load i16, i16* %7, align 2, !dbg !129
  store i16 %80, i16* @sys_mod.sys_mod.memcpyH2D_pe_length, align 2, !dbg !130
  %81 = load i16, i16* %6, align 2, !dbg !131
  store i16 %81, i16* @sys_mod.sys_mod.memcpyH2D_is_half, align 2, !dbg !132
  %82 = load i16, i16* %5, align 2, !dbg !133
  store i16 %82, i16* @sys_mod.sys_mod.memcpyH2D_memcpy_optype, align 2, !dbg !134
  %83 = load i16, i16* %4, align 2, !dbg !135
  store i16 %83, i16* @sys_mod.sys_mod.memcpyH2D_row_stride, align 2, !dbg !136
  %84 = load i16, i16* %3, align 2, !dbg !137
  store i16 %84, i16* @sys_mod.sys_mod.memcpyH2D_col_stride, align 2, !dbg !138
  %85 = load float, float* %2, align 4, !dbg !139
  store float %85, float* @sys_mod.sys_mod.memcpyH2D_one_over_row_stride, align 4, !dbg !140
  %86 = load float, float* %1, align 4, !dbg !141
  store float %86, float* @sys_mod.sys_mod.memcpyH2D_one_over_col_stride, align 4, !dbg !142
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !143
  call void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 0, i16 23, i1 true), !dbg !144
  call void @llvm.sdr.blk.r(i16 27), !dbg !145
  call void @llvm.sdr.oqflush(i16 0), !dbg !146
  store i1 true, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !147
  call void @llvm.sdr.blk.r(i16 0), !dbg !148
  ret void, !dbg !149
}

define void @sys_mod.sys_mod.f_memcpyd2h() #3 !dbg !150 {
  %1 = alloca i16, i16 1, align 2, !dbg !151
  %2 = alloca i16, i16 1, align 2, !dbg !153
  %3 = alloca i16, i16 1, align 2, !dbg !154
  %4 = alloca i16, i16 1, align 2, !dbg !155
  %5 = alloca i16, i16 1, align 2, !dbg !156
  %6 = alloca i16, i16 1, align 2, !dbg !157
  %7 = alloca i16, i16 1, align 2, !dbg !158
  %8 = alloca i16, i16 1, align 2, !dbg !159
  %9 = alloca i16*, i16 1, align 8, !dbg !160
  %10 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !161
  %11 = icmp eq i16 %10, 8, !dbg !162
  br i1 %11, label %12, label %13, !dbg !163

12:                                               ; preds = %0
  br label %14, !dbg !163

13:                                               ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !163
  br label %14, !dbg !163

14:                                               ; preds = %12, %13
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %9, align 8, !dbg !160
  %15 = load i16*, i16** %9, align 8, !dbg !164
  %16 = load i16, i16* %15, align 2, !dbg !165
  store i16 %16, i16* %8, align 2, !dbg !159
  %17 = load i16*, i16** %9, align 8, !dbg !166
  %18 = getelementptr i16, i16* %17, i16 1, !dbg !167
  %19 = load i16, i16* %18, align 2, !dbg !167
  store i16 %19, i16* %7, align 2, !dbg !158
  %20 = load i16*, i16** %9, align 8, !dbg !168
  %21 = getelementptr i16, i16* %20, i16 2, !dbg !169
  %22 = load i16, i16* %21, align 2, !dbg !169
  store i16 %22, i16* %6, align 2, !dbg !157
  %23 = load i16*, i16** %9, align 8, !dbg !170
  %24 = getelementptr i16, i16* %23, i16 3, !dbg !171
  %25 = load i16, i16* %24, align 2, !dbg !171
  store i16 %25, i16* %5, align 2, !dbg !156
  %26 = load i16*, i16** %9, align 8, !dbg !172
  %27 = getelementptr i16, i16* %26, i16 4, !dbg !173
  %28 = load i16, i16* %27, align 2, !dbg !173
  store i16 %28, i16* %4, align 2, !dbg !155
  %29 = load i16*, i16** %9, align 8, !dbg !174
  %30 = getelementptr i16, i16* %29, i16 5, !dbg !175
  %31 = load i16, i16* %30, align 2, !dbg !175
  store i16 %31, i16* %3, align 2, !dbg !154
  %32 = load i16*, i16** %9, align 8, !dbg !176
  %33 = getelementptr i16, i16* %32, i16 6, !dbg !177
  %34 = load i16, i16* %33, align 2, !dbg !177
  store i16 %34, i16* %2, align 2, !dbg !153
  %35 = load i16*, i16** %9, align 8, !dbg !178
  %36 = getelementptr i16, i16* %35, i16 7, !dbg !179
  %37 = load i16, i16* %36, align 2, !dbg !179
  store i16 %37, i16* %1, align 2, !dbg !151
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !180
  %38 = load i16, i16* %8, align 2, !dbg !181
  store i16 %38, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !182
  %39 = load i16, i16* %7, align 2, !dbg !183
  store i16 %39, i16* @sys_mod.sys_mod.memcpyD2H_px, align 2, !dbg !184
  %40 = load i16, i16* %6, align 2, !dbg !185
  store i16 %40, i16* @sys_mod.sys_mod.memcpyD2H_py, align 2, !dbg !186
  %41 = load i16, i16* %5, align 2, !dbg !187
  store i16 %41, i16* @sys_mod.sys_mod.memcpyD2H_w, align 2, !dbg !188
  %42 = load i16, i16* %4, align 2, !dbg !189
  store i16 %42, i16* @sys_mod.sys_mod.memcpyD2H_h, align 2, !dbg !190
  %43 = load i16, i16* %3, align 2, !dbg !191
  store i16 %43, i16* @sys_mod.sys_mod.memcpyD2H_addr, align 2, !dbg !192
  %44 = load i16, i16* %2, align 2, !dbg !193
  store i16 %44, i16* @sys_mod.sys_mod.memcpyD2H_pe_length, align 2, !dbg !194
  %45 = load i16, i16* %1, align 2, !dbg !195
  store i16 %45, i16* @sys_mod.sys_mod.memcpyD2H_is_half, align 2, !dbg !196
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !197
  %46 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !198
  call void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 0, i16 %46, i1 false), !dbg !199
  call void @llvm.sdr.oqflush(i16 0), !dbg !200
  store i1 false, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !201
  ret void, !dbg !202
}

define internal void @sys_mod.sys_mod.oq0_teardow_handler() !dbg !203 {
  %1 = load i1, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !204
  br i1 %1, label %2, label %17, !dbg !206

2:                                                ; preds = %0
  %3 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !207
  call void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 0, i16 %3), !dbg !208
  %4 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !209
  %5 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_px, align 2, !dbg !210
  %6 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_py, align 2, !dbg !211
  %7 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_w, align 2, !dbg !212
  %8 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_h, align 2, !dbg !213
  %9 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_addr, align 2, !dbg !214
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_pe_length, align 2, !dbg !215
  %11 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_is_half, align 2, !dbg !216
  %12 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_memcpy_optype, align 2, !dbg !217
  %13 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_row_stride, align 2, !dbg !218
  %14 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_col_stride, align 2, !dbg !219
  %15 = load float, float* @sys_mod.sys_mod.memcpyH2D_one_over_row_stride, align 4, !dbg !220
  %16 = load float, float* @sys_mod.sys_mod.memcpyH2D_one_over_col_stride, align 4, !dbg !221
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure(i16 %4, i16 %5, i16 %6, i16 %7, i16 %8, i16 %9, i16 %10, i16 %11, i16 %12, i16 %13, i16 %14, float %15, float %16), !dbg !222
  br label %26, !dbg !206

17:                                               ; preds = %0
  call void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 0, i16 21), !dbg !223
  %18 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !224
  %19 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_px, align 2, !dbg !225
  %20 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_py, align 2, !dbg !226
  %21 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_w, align 2, !dbg !227
  %22 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_h, align 2, !dbg !228
  %23 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_addr, align 2, !dbg !229
  %24 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_pe_length, align 2, !dbg !230
  %25 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_is_half, align 2, !dbg !231
  call void @sys_mod.sys_mod.memcpyd2h_mod.d2h_configure(i16 %18, i16 %19, i16 %20, i16 %21, i16 %22, i16 %23, i16 %24, i16 %25), !dbg !232
  br label %26, !dbg !206

26:                                               ; preds = %2, %17
  call void @__generic0sys_mod.sys_mod.tile_config.queue_flush.exit(), !dbg !233
  ret void, !dbg !206
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

define void @sys_mod.sys_mod.f_rpc(i16 %0) #4 !dbg !234 {
  %2 = alloca i16, i16 1, align 2, !dbg !235
  store i16 %0, i16* %2, align 2, !dbg !235
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !237
  %3 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !238
  %4 = icmp sge i16 %3, 4, !dbg !239
  br i1 %4, label %5, label %6, !dbg !240

5:                                                ; preds = %1
  br label %7, !dbg !240

6:                                                ; preds = %1
  call void asm sideeffect "hcf", ""(), !dbg !240
  br label %7, !dbg !240

7:                                                ; preds = %5, %6
  call void @rpc_server(i32* getelementptr inbounds ([32 x i32], [32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32, i32 0, i32 0)), !dbg !241
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !242
  ret void, !dbg !243
}

define internal void @sys_mod.sys_mod.sys_mod.stack_push(i16 %0) !dbg !244 {
  %2 = alloca i16*, i16 1, align 8, !dbg !246
  %3 = alloca i16, i16 1, align 2, !dbg !248
  store i16 %0, i16* %3, align 2, !dbg !248
  %4 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !249
  %5 = icmp slt i16 %4, 32, !dbg !250
  br i1 %5, label %6, label %7, !dbg !251

6:                                                ; preds = %1
  br label %8, !dbg !251

7:                                                ; preds = %1
  call void asm sideeffect "hcf", ""(), !dbg !251
  br label %8, !dbg !251

8:                                                ; preds = %6, %7
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %2, align 8, !dbg !246
  %9 = load i16, i16* %3, align 2, !dbg !252
  %10 = load i16*, i16** %2, align 8, !dbg !253
  %11 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !254
  %12 = getelementptr i16, i16* %10, i16 %11, !dbg !255
  store i16 %9, i16* %12, align 2, !dbg !256
  %13 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !257
  %14 = add i16 %13, 1, !dbg !258
  store i16 %14, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !259
  ret void, !dbg !260
}

define void @sys_mod.sys_mod.sys_mod.f_push(i16 %0, i16 %1) #5 !dbg !261 {
  %3 = alloca i16, i16 1, align 2, !dbg !262
  %4 = alloca i16, i16 1, align 2, !dbg !264
  store i16 %0, i16* %4, align 2, !dbg !264
  store i16 %1, i16* %3, align 2, !dbg !262
  %5 = load i16, i16* %4, align 2, !dbg !265
  call void @sys_mod.sys_mod.sys_mod.stack_push(i16 %5), !dbg !266
  ret void, !dbg !267
}

define internal void @sys_mod.sys_mod.sys_mod.block_cmd_stream() !dbg !268 {
  call void @llvm.sdr.blk.r(i16 1), !dbg !269
  ret void, !dbg !271
}

define internal void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream() !dbg !272 {
  call void @llvm.sdr.ublk.r(i16 1), !dbg !273
  ret void, !dbg !275
}

define void @sys_mod.sys_mod.sys_mod.f_sys_exit() #6 !dbg !276 {
  call void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream(), !dbg !277
  call void @sys_mod.sys_nop(), !dbg !279
  ret void, !dbg !280
}

define void @sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore(i32 %0) #7 !dbg !281 {
  %2 = alloca i32, i16 1, align 4, !dbg !282
  store i32 %0, i32* %2, align 4, !dbg !282
  ret void, !dbg !284
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord() !dbg !285 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord(), !dbg !287
  ret i16 %1, !dbg !289
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord() !dbg !290 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord(), !dbg !291
  ret i16 %1, !dbg !293
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval(i16 %0) !dbg !294 {
  %2 = alloca i16, i16 1, align 2, !dbg !295
  store i16 %0, i16* %2, align 2, !dbg !295
  %3 = load i16, i16* %2, align 2, !dbg !297
  %4 = icmp ult i16 %3, 24, !dbg !298
  br i1 %4, label %5, label %7, !dbg !299

5:                                                ; preds = %10, %11, %1
  %6 = phi i16 [ 0, %10 ], [ 0, %11 ], [ 1, %1 ]
  br label %12, !dbg !299

7:                                                ; preds = %1
  %8 = load i16, i16* %2, align 2, !dbg !300
  %9 = icmp eq i16 31, %8, !dbg !301
  br i1 %9, label %10, label %11, !dbg !302

10:                                               ; preds = %7
  br label %5, !dbg !302

11:                                               ; preds = %7
  call void asm sideeffect "hcf", ""(), !dbg !302
  br label %5, !dbg !302

12:                                               ; preds = %5
  %13 = phi i16 [ %6, %5 ]
  br label %14, !dbg !299

14:                                               ; preds = %12
  ret i16 %13, !dbg !299
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start(i16 %0, i16 %1, i16 %2) !dbg !303 {
  %4 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !304
  %5 = alloca i16, i16 1, align 2, !dbg !306
  %6 = alloca i16, i16 1, align 2, !dbg !307
  %7 = alloca i16, i16 1, align 2, !dbg !308
  store i16 %0, i16* %7, align 2, !dbg !308
  store i16 %1, i16* %6, align 2, !dbg !307
  store i16 %2, i16* %5, align 2, !dbg !306
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !309
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !309
  %10 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !309
  %11 = load i16, i16* %6, align 2, !dbg !310
  store i16 %11, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !311
  store i16 %8, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !311
  store i16 %9, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !311
  store i16 %10, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !311
  %12 = load i16, i16* %7, align 2, !dbg !312
  %13 = call i16* @.get_tensor_ptr(i16 %12), !dbg !313
  %14 = ptrtoint i16* %13 to i16, !dbg !314
  %15 = lshr i16 %14, 1, !dbg !314
  %16 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !304
  store i16 42, i16* %16, align 2, !dbg !304
  %17 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !304
  store i16 %15, i16* %17, align 2, !dbg !304
  %18 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !304
  store i16 143, i16* %18, align 2, !dbg !304
  %19 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !304
  store i16 16, i16* %19, align 2, !dbg !304
  %20 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !315
  %21 = load i16, i16* %20, align 2, !dbg !315
  %22 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !315
  %23 = load i16, i16* %22, align 2, !dbg !315
  %24 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !315
  %25 = load i16, i16* %24, align 2, !dbg !315
  %26 = load i16, i16* %6, align 2, !dbg !316
  %27 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !317
  store i16 %26, i16* %27, align 2, !dbg !317
  %28 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !317
  store i16 %21, i16* %28, align 2, !dbg !317
  %29 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !317
  store i16 %23, i16* %29, align 2, !dbg !317
  %30 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !317
  store i16 %25, i16* %30, align 2, !dbg !317
  %31 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !318
  %32 = load i16, i16* %31, align 2, !dbg !318
  %33 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !318
  %34 = load i16, i16* %33, align 2, !dbg !318
  %35 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !318
  %36 = load i16, i16* %35, align 2, !dbg !318
  %37 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !318
  %38 = load i16, i16* %37, align 2, !dbg !318
  store volatile i16 %32, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !319
  store volatile i16 %34, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !319
  store volatile i16 %36, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !319
  store volatile i16 %38, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !319
  call void asm sideeffect "nop", ""(), !dbg !319
  call void asm sideeffect "nop", ""(), !dbg !319
  %39 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !320
  %40 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !320
  %41 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !320
  %42 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !320
  %43 = and i16 %41, -193, !dbg !320
  %44 = or i16 %43, 128, !dbg !320
  %45 = and i16 %40, -64, !dbg !320
  %46 = or i16 %45, 27, !dbg !320
  store volatile i16 %39, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !321
  store volatile i16 %46, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !321
  store volatile i16 %44, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !321
  store volatile i16 %42, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !321
  call void asm sideeffect "nop", ""(), !dbg !321
  call void asm sideeffect "nop", ""(), !dbg !321
  %47 = load i16, i16* %5, align 2, !dbg !322
  %48 = icmp ult i16 0, %47, !dbg !323
  br i1 %48, label %49, label %50, !dbg !324

49:                                               ; preds = %3
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !325
  br label %51, !dbg !324

50:                                               ; preds = %3
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !326
  br label %51, !dbg !324

51:                                               ; preds = %49, %50
  ret void, !dbg !324
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream() !dbg !327 {
  call void @llvm.sdr.ublk.r(i16 1), !dbg !328
  ret void, !dbg !330
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7, i16 %8, i16 %9, i16 %10, float %11, float %12) !dbg !331 {
  %14 = alloca i16, i16 1, align 2, !dbg !332
  %15 = alloca i16, i16 1, align 2, !dbg !334
  %16 = alloca i16, i16 1, align 2, !dbg !335
  %17 = alloca i16, i16 1, align 2, !dbg !336
  %18 = alloca i16, i16 1, align 2, !dbg !337
  %19 = alloca i1, i16 1, align 1, !dbg !338
  %20 = alloca i16, i16 1, align 2, !dbg !339
  %21 = alloca i16, i16 1, align 2, !dbg !340
  %22 = alloca i16, i16 1, align 2, !dbg !341
  %23 = alloca i16, i16 1, align 2, !dbg !342
  %24 = alloca i16, i16 1, align 2, !dbg !343
  %25 = alloca float, i16 1, align 4, !dbg !344
  %26 = alloca float, i16 1, align 4, !dbg !345
  %27 = alloca i16, i16 1, align 2, !dbg !346
  %28 = alloca i16, i16 1, align 2, !dbg !347
  %29 = alloca i16, i16 1, align 2, !dbg !348
  %30 = alloca i16, i16 1, align 2, !dbg !349
  %31 = alloca i16, i16 1, align 2, !dbg !350
  %32 = alloca i16, i16 1, align 2, !dbg !351
  %33 = alloca i16, i16 1, align 2, !dbg !352
  %34 = alloca i16, i16 1, align 2, !dbg !353
  %35 = alloca i16, i16 1, align 2, !dbg !354
  %36 = alloca i16, i16 1, align 2, !dbg !355
  %37 = alloca i16, i16 1, align 2, !dbg !356
  store i16 %0, i16* %37, align 2, !dbg !356
  store i16 %1, i16* %36, align 2, !dbg !355
  store i16 %2, i16* %35, align 2, !dbg !354
  store i16 %3, i16* %34, align 2, !dbg !353
  store i16 %4, i16* %33, align 2, !dbg !352
  store i16 %5, i16* %32, align 2, !dbg !351
  store i16 %6, i16* %31, align 2, !dbg !350
  store i16 %7, i16* %30, align 2, !dbg !349
  store i16 %8, i16* %29, align 2, !dbg !348
  store i16 %9, i16* %28, align 2, !dbg !347
  store i16 %10, i16* %27, align 2, !dbg !346
  store float %11, float* %26, align 4, !dbg !345
  store float %12, float* %25, align 4, !dbg !344
  %38 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord(), !dbg !357
  store i16 %38, i16* %24, align 2, !dbg !343
  %39 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord(), !dbg !358
  store i16 %39, i16* %23, align 2, !dbg !342
  %40 = load i16, i16* %24, align 2, !dbg !359
  %41 = load i16, i16* %36, align 2, !dbg !360
  %42 = sub i16 %40, %41, !dbg !361
  store i16 %42, i16* %22, align 2, !dbg !341
  %43 = load i16, i16* %22, align 2, !dbg !362
  store i16 %43, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !363
  %44 = load i16, i16* %29, align 2, !dbg !364
  %45 = icmp eq i16 3, %44, !dbg !365
  br i1 %45, label %46, label %63, !dbg !366

46:                                               ; preds = %13
  %47 = load i16, i16* %22, align 2, !dbg !367
  %48 = sitofp i16 %47 to float, !dbg !368
  %49 = load float, float* %26, align 4, !dbg !369
  %50 = fmul float %48, %49, !dbg !370
  %51 = fptosi float %50 to i16, !dbg !371
  store i16 %51, i16* %21, align 2, !dbg !340
  %52 = load i16, i16* %22, align 2, !dbg !372
  %53 = load i16, i16* %21, align 2, !dbg !373
  %54 = load i16, i16* %28, align 2, !dbg !374
  %55 = mul i16 %53, %54, !dbg !375
  %56 = sub i16 %52, %55, !dbg !376
  store i16 %56, i16* %20, align 2, !dbg !339
  %57 = load i16, i16* %20, align 2, !dbg !377
  %58 = icmp ne i16 0, %57, !dbg !378
  br i1 %58, label %59, label %60, !dbg !379

59:                                               ; preds = %46
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !380
  br label %62, !dbg !379

60:                                               ; preds = %46
  %61 = load i16, i16* %21, align 2, !dbg !381
  store i16 %61, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !382
  br label %62, !dbg !379

62:                                               ; preds = %59, %60
  br label %63, !dbg !366

63:                                               ; preds = %62, %13
  %64 = load i16, i16* %22, align 2, !dbg !383
  %65 = icmp slt i16 %64, 0, !dbg !384
  br i1 %65, label %66, label %67, !dbg !385

66:                                               ; preds = %63
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !386
  br label %67, !dbg !385

67:                                               ; preds = %66, %63
  %68 = load i16, i16* %22, align 2, !dbg !387
  %69 = load i16, i16* %34, align 2, !dbg !388
  %70 = icmp sge i16 %68, %69, !dbg !389
  br i1 %70, label %71, label %72, !dbg !390

71:                                               ; preds = %67
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !391
  br label %72, !dbg !390

72:                                               ; preds = %71, %67
  store i1 false, i1* %19, align 1, !dbg !338
  %73 = load i16, i16* %29, align 2, !dbg !392
  %74 = icmp eq i16 3, %73, !dbg !393
  br i1 %74, label %75, label %94, !dbg !394

75:                                               ; preds = %72
  %76 = load i16, i16* %23, align 2, !dbg !395
  %77 = load i16, i16* %35, align 2, !dbg !396
  %78 = sub i16 %76, %77, !dbg !397
  %79 = sitofp i16 %78 to float, !dbg !398
  %80 = load float, float* %25, align 4, !dbg !399
  %81 = fmul float %79, %80, !dbg !400
  %82 = fptosi float %81 to i16, !dbg !401
  store i16 %82, i16* %18, align 2, !dbg !337
  %83 = load i16, i16* %23, align 2, !dbg !402
  %84 = load i16, i16* %35, align 2, !dbg !403
  %85 = sub i16 %83, %84, !dbg !404
  %86 = load i16, i16* %18, align 2, !dbg !405
  %87 = load i16, i16* %27, align 2, !dbg !406
  %88 = mul i16 %86, %87, !dbg !407
  %89 = sub i16 %85, %88, !dbg !408
  store i16 %89, i16* %17, align 2, !dbg !336
  %90 = load i16, i16* %17, align 2, !dbg !409
  %91 = icmp ne i16 0, %90, !dbg !410
  br i1 %91, label %92, label %93, !dbg !411

92:                                               ; preds = %75
  store i1 true, i1* %19, align 1, !dbg !412
  br label %93, !dbg !411

93:                                               ; preds = %92, %75
  br label %94, !dbg !394

94:                                               ; preds = %93, %72
  %95 = load i16, i16* %23, align 2, !dbg !413
  %96 = load i16, i16* %35, align 2, !dbg !414
  %97 = icmp slt i16 %95, %96, !dbg !415
  br i1 %97, label %98, label %99, !dbg !416

98:                                               ; preds = %94
  store i1 true, i1* %19, align 1, !dbg !417
  br label %99, !dbg !416

99:                                               ; preds = %98, %94
  %100 = load i16, i16* %23, align 2, !dbg !418
  %101 = load i16, i16* %35, align 2, !dbg !419
  %102 = load i16, i16* %33, align 2, !dbg !420
  %103 = add i16 %101, %102, !dbg !421
  %104 = icmp sge i16 %100, %103, !dbg !422
  br i1 %104, label %105, label %106, !dbg !423

105:                                              ; preds = %99
  store i1 true, i1* %19, align 1, !dbg !424
  br label %106, !dbg !423

106:                                              ; preds = %105, %99
  %107 = load i1, i1* %19, align 1, !dbg !425
  br i1 %107, label %108, label %109, !dbg !426

108:                                              ; preds = %106
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream(), !dbg !427
  call void @llvm.sdr.ublk.r(i16 27), !dbg !428
  br label %180, !dbg !426

109:                                              ; preds = %106
  %110 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !429
  %111 = icmp eq i16 -1, %110, !dbg !430
  br i1 %111, label %112, label %113, !dbg !431

112:                                              ; preds = %109
  call void @__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction(i16 31767), !dbg !432
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 23), !dbg !433
  call void @llvm.sdr.ublk.r(i16 27), !dbg !434
  br label %179, !dbg !431

113:                                              ; preds = %109
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter(i16 0, i16 0), !dbg !435
  %114 = load i16, i16* %34, align 2, !dbg !436
  store i16 %114, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !437
  %115 = load i16, i16* %29, align 2, !dbg !438
  %116 = icmp eq i16 3, %115, !dbg !439
  br i1 %116, label %117, label %126, !dbg !440

117:                                              ; preds = %113
  %118 = load i16, i16* %34, align 2, !dbg !441
  %119 = sub i16 %118, 1, !dbg !442
  %120 = sitofp i16 %119 to float, !dbg !443
  %121 = load float, float* %26, align 4, !dbg !444
  %122 = fmul float %120, %121, !dbg !445
  %123 = fptosi float %122 to i16, !dbg !446
  %124 = add i16 %123, 1, !dbg !447
  store i16 %124, i16* %16, align 2, !dbg !335
  %125 = load i16, i16* %16, align 2, !dbg !448
  store i16 %125, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !449
  br label %131, !dbg !440

126:                                              ; preds = %113
  %127 = load i16, i16* %29, align 2, !dbg !450
  %128 = icmp eq i16 1, %127, !dbg !451
  br i1 %128, label %129, label %130, !dbg !452

129:                                              ; preds = %126
  store i16 1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !453
  br label %130, !dbg !452

130:                                              ; preds = %129, %126
  br label %131, !dbg !440

131:                                              ; preds = %117, %130
  %132 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !454
  %133 = sub i16 %132, 1, !dbg !455
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit(i16 0, i16 %133), !dbg !456
  %134 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !457
  store i16 %134, i16* %15, align 2, !dbg !334
  %135 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !458
  store i16 %135, i16* %14, align 2, !dbg !332
  %136 = load i16, i16* %15, align 2, !dbg !459
  %137 = load i16, i16* %14, align 2, !dbg !460
  %138 = sub i16 %136, %137, !dbg !461
  store i16 %138, i16* %15, align 2, !dbg !462
  %139 = load i16, i16* %14, align 2, !dbg !463
  %140 = icmp eq i16 0, %139, !dbg !464
  br i1 %140, label %141, label %142, !dbg !465

141:                                              ; preds = %131
  store i16 0, i16* %15, align 2, !dbg !466
  br label %142, !dbg !465

142:                                              ; preds = %141, %131
  %143 = load i16, i16* %29, align 2, !dbg !467
  %144 = icmp eq i16 1, %143, !dbg !468
  br i1 %144, label %145, label %146, !dbg !469

145:                                              ; preds = %142
  store i16 0, i16* %15, align 2, !dbg !470
  br label %146, !dbg !469

146:                                              ; preds = %145, %142
  %147 = load i16, i16* %15, align 2, !dbg !471
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter(i16 0, i16 %147), !dbg !472
  call void @__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction(i16 31767), !dbg !473
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 23), !dbg !474
  %148 = load i16, i16* %37, align 2, !dbg !475
  %149 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval(i16 %148), !dbg !476
  %150 = icmp eq i16 0, %149, !dbg !477
  br i1 %150, label %151, label %155, !dbg !478

151:                                              ; preds = %146
  %152 = load i16, i16* %32, align 2, !dbg !479
  %153 = load i16, i16* %31, align 2, !dbg !480
  %154 = load i16, i16* %30, align 2, !dbg !481
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start(i16 %152, i16 %153, i16 %154), !dbg !482
  br label %178, !dbg !478

155:                                              ; preds = %146
  %156 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !483
  %157 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !483
  %158 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !483
  %159 = load i16, i16* %31, align 2, !dbg !484
  store i16 %159, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !485
  store i16 %156, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !485
  store i16 %157, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !485
  store i16 %158, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !485
  %160 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !486
  %161 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !486
  %162 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !486
  %163 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !486
  %164 = and i16 %162, -193, !dbg !486
  %165 = or i16 %164, 128, !dbg !486
  store volatile i16 %160, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !487
  store volatile i16 %161, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !487
  store volatile i16 %165, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !487
  store volatile i16 %163, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !487
  call void asm sideeffect "nop", ""(), !dbg !487
  call void asm sideeffect "nop", ""(), !dbg !487
  %166 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !488
  %167 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !488
  %168 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !488
  %169 = load i16, i16* %31, align 2, !dbg !489
  store i16 %169, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !490
  store i16 %166, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !490
  store i16 %167, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !490
  store i16 %168, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !490
  %170 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !491
  %171 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !491
  %172 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !491
  %173 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !491
  %174 = and i16 %172, -193, !dbg !491
  %175 = or i16 %174, 128, !dbg !491
  %176 = and i16 %171, -64, !dbg !491
  %177 = or i16 %176, 27, !dbg !491
  store volatile i16 %170, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !492
  store volatile i16 %177, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !492
  store volatile i16 %175, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !492
  store volatile i16 %173, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !492
  call void asm sideeffect "nop", ""(), !dbg !492
  call void asm sideeffect "nop", ""(), !dbg !492
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !493
  br label %178, !dbg !478

178:                                              ; preds = %151, %155
  br label %179, !dbg !431

179:                                              ; preds = %112, %178
  br label %180, !dbg !426

180:                                              ; preds = %108, %179
  ret void, !dbg !366
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit(i16 %0, i16 %1) !dbg !494 {
  %3 = alloca i16, i16 1, align 2, !dbg !496
  %4 = alloca i16, i16 1, align 2, !dbg !498
  %5 = alloca i16, i16 1, align 2, !dbg !499
  %6 = alloca i16, i16 1, align 2, !dbg !500
  %7 = alloca i16, i16 1, align 2, !dbg !501
  %8 = alloca i16, i16 1, align 2, !dbg !502
  store i16 %0, i16* %8, align 2, !dbg !502
  store i16 %1, i16* %7, align 2, !dbg !501
  %9 = load i16, i16* %7, align 2, !dbg !503
  %10 = icmp ult i16 %9, -32768, !dbg !504
  br i1 %10, label %11, label %12, !dbg !505

11:                                               ; preds = %2
  br label %13, !dbg !505

12:                                               ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !505
  br label %13, !dbg !505

13:                                               ; preds = %11, %12
  %14 = load i16, i16* %7, align 2, !dbg !506
  %15 = mul i16 %14, 2, !dbg !507
  store i16 %15, i16* %6, align 2, !dbg !500
  %16 = load i16, i16* %8, align 2, !dbg !508
  %17 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %16, i16 8), !dbg !509
  %18 = sub i16 %17, 1, !dbg !510
  store i16 %18, i16* %5, align 2, !dbg !499
  %19 = load i16, i16* %6, align 2, !dbg !511
  %20 = load i16, i16* %5, align 2, !dbg !512
  %21 = icmp ult i16 %19, %20, !dbg !513
  br i1 %21, label %22, label %23, !dbg !498

22:                                               ; preds = %13
  store i16 0, i16* %4, align 2, !dbg !498
  br label %27, !dbg !498

23:                                               ; preds = %13
  %24 = load i16, i16* %6, align 2, !dbg !514
  %25 = load i16, i16* %5, align 2, !dbg !515
  %26 = sub i16 %24, %25, !dbg !516
  store i16 %26, i16* %4, align 2, !dbg !498
  br label %27, !dbg !498

27:                                               ; preds = %22, %23
  %28 = load i16, i16* %4, align 2, !dbg !498
  store i16 %28, i16* %3, align 2, !dbg !496
  %29 = load i16, i16* %8, align 2, !dbg !517
  %30 = load i16, i16* %3, align 2, !dbg !518
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %29, i16 4, i16 %30), !dbg !519
  ret void, !dbg !498
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter(i16 %0, i16 %1) !dbg !520 {
  %3 = alloca i16, i16 1, align 2, !dbg !521
  %4 = alloca i16, i16 1, align 2, !dbg !523
  store i16 %0, i16* %4, align 2, !dbg !523
  store i16 %1, i16* %3, align 2, !dbg !521
  %5 = load i16, i16* %3, align 2, !dbg !524
  %6 = icmp ult i16 %5, -32768, !dbg !525
  br i1 %6, label %7, label %8, !dbg !526

7:                                                ; preds = %2
  br label %9, !dbg !526

8:                                                ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !526
  br label %9, !dbg !526

9:                                                ; preds = %7, %8
  %10 = load i16, i16* %4, align 2, !dbg !527
  %11 = load i16, i16* %3, align 2, !dbg !528
  %12 = mul i16 %11, 2, !dbg !529
  %13 = add i16 %12, 1, !dbg !530
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %10, i16 8, i16 %13), !dbg !531
  ret void, !dbg !532
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter(i16 %0, i16 %1) !dbg !533 {
  %3 = alloca i16, i16 1, align 2, !dbg !534
  %4 = alloca i16, i16 1, align 2, !dbg !536
  %5 = alloca i1, i16 1, align 1, !dbg !537
  %6 = alloca i16, i16 1, align 2, !dbg !538
  %7 = alloca i16, i16 1, align 2, !dbg !539
  %8 = alloca i16, i16 1, align 2, !dbg !540
  %9 = alloca i16, i16 1, align 2, !dbg !541
  store i16 %0, i16* %9, align 2, !dbg !541
  store i16 %1, i16* %8, align 2, !dbg !540
  %10 = load i16, i16* %8, align 2, !dbg !542
  %11 = icmp ult i16 %10, -32768, !dbg !543
  br i1 %11, label %12, label %13, !dbg !544

12:                                               ; preds = %2
  br label %14, !dbg !544

13:                                               ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !544
  br label %14, !dbg !544

14:                                               ; preds = %12, %13
  %15 = load i16, i16* %9, align 2, !dbg !545
  %16 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %15, i16 8), !dbg !546
  store i16 %16, i16* %7, align 2, !dbg !539
  %17 = load i16, i16* %8, align 2, !dbg !547
  %18 = mul i16 %17, 2, !dbg !548
  store i16 %18, i16* %6, align 2, !dbg !538
  %19 = load i16, i16* %6, align 2, !dbg !549
  %20 = load i16, i16* %7, align 2, !dbg !550
  %21 = icmp ugt i16 %19, %20, !dbg !551
  store i1 %21, i1* %5, align 1, !dbg !537
  %22 = load i16, i16* %9, align 2, !dbg !552
  %23 = load i1, i1* %5, align 1, !dbg !553
  %24 = zext i1 %23 to i16, !dbg !554
  %25 = shl i16 %24, 6, !dbg !555
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %22, i16 14, i16 %25), !dbg !556
  %26 = load i1, i1* %5, align 1, !dbg !557
  br i1 %26, label %27, label %32, !dbg !536

27:                                               ; preds = %14
  %28 = load i16, i16* %6, align 2, !dbg !558
  %29 = load i16, i16* %7, align 2, !dbg !559
  %30 = sub i16 %28, %29, !dbg !560
  %31 = add i16 %30, 1, !dbg !561
  store i16 %31, i16* %4, align 2, !dbg !536
  br label %34, !dbg !536

32:                                               ; preds = %14
  %33 = load i16, i16* %6, align 2, !dbg !562
  store i16 %33, i16* %4, align 2, !dbg !536
  br label %34, !dbg !536

34:                                               ; preds = %27, %32
  %35 = load i16, i16* %4, align 2, !dbg !536
  store i16 %35, i16* %3, align 2, !dbg !534
  %36 = load i16, i16* %9, align 2, !dbg !563
  %37 = load i16, i16* %3, align 2, !dbg !564
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %36, i16 12, i16 %37), !dbg !565
  ret void, !dbg !536
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %0, i16 %1, i16 %2) !dbg !566 {
  %4 = alloca i16, i16 1, align 2, !dbg !568
  %5 = alloca i16, i16 1, align 2, !dbg !570
  %6 = alloca i16, i16 1, align 2, !dbg !571
  store i16 %0, i16* %6, align 2, !dbg !571
  store i16 %1, i16* %5, align 2, !dbg !570
  store i16 %2, i16* %4, align 2, !dbg !568
  %7 = load i16, i16* %6, align 2, !dbg !572
  %8 = getelementptr [6 x i16], [6 x i16]* @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.filters, i16 0, i16 %7, !dbg !573
  %9 = load i16, i16* %8, align 2, !dbg !573
  %10 = load i16, i16* %5, align 2, !dbg !574
  %11 = add i16 %9, %10, !dbg !575
  %12 = lshr i16 %11, 1, !dbg !576
  %13 = load i16, i16* %4, align 2, !dbg !577
  %14 = shl i16 %12, 1, !dbg !578
  %15 = inttoptr i16 %14 to i16*, !dbg !578
  store volatile i16 %13, i16* %15, align 2, !dbg !578
  call void asm sideeffect "nop", ""(), !dbg !578
  call void asm sideeffect "nop", ""(), !dbg !578
  ret void, !dbg !579
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %0, i16 %1) !dbg !580 {
  %3 = alloca i16, i16 1, align 2, !dbg !581
  %4 = alloca i16, i16 1, align 2, !dbg !583
  store i16 %0, i16* %4, align 2, !dbg !583
  store i16 %1, i16* %3, align 2, !dbg !581
  %5 = load i16, i16* %4, align 2, !dbg !584
  %6 = getelementptr [6 x i16], [6 x i16]* @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.filters, i16 0, i16 %5, !dbg !585
  %7 = load i16, i16* %6, align 2, !dbg !585
  %8 = load i16, i16* %3, align 2, !dbg !586
  %9 = add i16 %7, %8, !dbg !587
  %10 = lshr i16 %9, 1, !dbg !588
  %11 = shl i16 %10, 1, !dbg !589
  %12 = inttoptr i16 %11 to i16*, !dbg !589
  call void asm sideeffect "nop", ""(), !dbg !589
  call void asm sideeffect "nop", ""(), !dbg !589
  %13 = load volatile i16, i16* %12, align 2, !dbg !589
  ret i16 %13, !dbg !590
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 %0) !dbg !591 {
  %2 = alloca i16, i16 1, align 2, !dbg !593
  %3 = alloca i16, i16 1, align 2, !dbg !595
  %4 = alloca i16, i16 1, align 2, !dbg !596
  %5 = alloca i16, i16 1, align 2, !dbg !597
  store i16 %0, i16* %5, align 2, !dbg !597
  %6 = load i16, i16* %5, align 2, !dbg !598
  store i16 %6, i16* %4, align 2, !dbg !596
  %7 = load i16, i16* %4, align 2, !dbg !599
  %8 = add i16 %7, 31744, !dbg !600
  store i16 %8, i16* %3, align 2, !dbg !595
  %9 = load i16, i16* %3, align 2, !dbg !601
  %10 = shl i16 %9, 1, !dbg !602
  %11 = inttoptr i16 %10 to i16*, !dbg !602
  call void asm sideeffect "nop", ""(), !dbg !602
  call void asm sideeffect "nop", ""(), !dbg !602
  %12 = load volatile i16, i16* %11, align 2, !dbg !602
  store i16 %12, i16* %2, align 2, !dbg !593
  %13 = load i16, i16* %3, align 2, !dbg !603
  %14 = load i16, i16* %2, align 2, !dbg !604
  %15 = and i16 %14, 32767, !dbg !605
  %16 = shl i16 %13, 1, !dbg !606
  %17 = inttoptr i16 %16 to i16*, !dbg !606
  store volatile i16 %15, i16* %17, align 2, !dbg !606
  call void asm sideeffect "nop", ""(), !dbg !606
  call void asm sideeffect "nop", ""(), !dbg !606
  ret void, !dbg !607
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord() !dbg !608 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 2), !dbg !610
  %2 = sub i16 %1, 4, !dbg !612
  ret i16 %2, !dbg !613
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord() !dbg !614 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 0), !dbg !615
  %2 = sub i16 %1, 1, !dbg !617
  ret i16 %2, !dbg !618
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 %0) !dbg !619 {
  %2 = alloca i16, i16 1, align 2, !dbg !621
  %3 = alloca i16, i16 1, align 2, !dbg !623
  store i16 %0, i16* %3, align 2, !dbg !623
  %4 = load i16, i16* %3, align 2, !dbg !624
  %5 = lshr i16 %4, 1, !dbg !625
  %6 = add i16 %5, 31813, !dbg !626
  %7 = shl i16 %6, 1, !dbg !627
  %8 = inttoptr i16 %7 to i16*, !dbg !627
  call void asm sideeffect "nop", ""(), !dbg !627
  call void asm sideeffect "nop", ""(), !dbg !627
  %9 = load volatile i16, i16* %8, align 2, !dbg !627
  store i16 %9, i16* %2, align 2, !dbg !621
  %10 = load i16, i16* %2, align 2, !dbg !628
  %11 = and i16 %10, 2047, !dbg !629
  ret i16 %11, !dbg !630
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord() !dbg !631 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord(), !dbg !633
  ret i16 %1, !dbg !635
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.get_y_coord() !dbg !636 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord(), !dbg !637
  ret i16 %1, !dbg !639
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval(i16 %0) !dbg !640 {
  %2 = alloca i16, i16 1, align 2, !dbg !641
  store i16 %0, i16* %2, align 2, !dbg !641
  %3 = load i16, i16* %2, align 2, !dbg !643
  %4 = icmp ult i16 %3, 24, !dbg !644
  br i1 %4, label %5, label %7, !dbg !645

5:                                                ; preds = %10, %11, %1
  %6 = phi i16 [ 0, %10 ], [ 0, %11 ], [ 1, %1 ]
  br label %12, !dbg !645

7:                                                ; preds = %1
  %8 = load i16, i16* %2, align 2, !dbg !646
  %9 = icmp eq i16 31, %8, !dbg !647
  br i1 %9, label %10, label %11, !dbg !648

10:                                               ; preds = %7
  br label %5, !dbg !648

11:                                               ; preds = %7
  call void asm sideeffect "hcf", ""(), !dbg !648
  br label %5, !dbg !648

12:                                               ; preds = %5
  %13 = phi i16 [ %6, %5 ]
  br label %14, !dbg !645

14:                                               ; preds = %12
  ret i16 %13, !dbg !645
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7) !dbg !649 {
  %9 = alloca i16, i16 1, align 2, !dbg !650
  %10 = alloca i16, i16 1, align 2, !dbg !652
  %11 = alloca i16, i16 1, align 2, !dbg !653
  %12 = alloca i16, i16 1, align 2, !dbg !654
  %13 = alloca i16, i16 1, align 2, !dbg !655
  %14 = alloca i16, i16 1, align 2, !dbg !656
  %15 = alloca i16, i16 1, align 2, !dbg !657
  %16 = alloca i16, i16 1, align 2, !dbg !658
  %17 = alloca i16, i16 1, align 2, !dbg !659
  store i16 %0, i16* %17, align 2, !dbg !659
  store i16 %1, i16* %16, align 2, !dbg !658
  store i16 %2, i16* %15, align 2, !dbg !657
  store i16 %3, i16* %14, align 2, !dbg !656
  store i16 %4, i16* %13, align 2, !dbg !655
  store i16 %5, i16* %12, align 2, !dbg !654
  store i16 %6, i16* %11, align 2, !dbg !653
  store i16 %7, i16* %10, align 2, !dbg !652
  %18 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !660
  store i16 %18, i16* %9, align 2, !dbg !650
  %19 = load i16, i16* %11, align 2, !dbg !661
  store i16 %19, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_c, align 2, !dbg !662
  %20 = load i16, i16* %10, align 2, !dbg !663
  store i16 %20, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_is_half, align 2, !dbg !664
  %21 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_c, align 2, !dbg !665
  %22 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval(i16 %21), !dbg !666
  store i16 %22, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !667
  store i16 0, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !668
  %23 = load i16, i16* %16, align 2, !dbg !669
  store i16 %23, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !670
  %24 = load i16, i16* %15, align 2, !dbg !671
  store i16 %24, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !672
  %25 = load i16, i16* %15, align 2, !dbg !673
  %26 = load i16, i16* %13, align 2, !dbg !674
  %27 = add i16 %25, %26, !dbg !675
  %28 = sub i16 %27, 1, !dbg !676
  store i16 %28, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_last, align 2, !dbg !677
  %29 = load i16, i16* %9, align 2, !dbg !678
  %30 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_last, align 2, !dbg !679
  %31 = icmp eq i16 %29, %30, !dbg !680
  br i1 %31, label %32, label %37, !dbg !681

32:                                               ; preds = %8
  %33 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !682
  %34 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !682
  %35 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !682
  store i16 %33, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !683
  store i16 lshr (i16 ptrtoint ([1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.ctrl_1 to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !683
  store i16 %34, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !683
  store i16 %35, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !683
  %36 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.ctrl_1, i16 0, i1 false), align 4, !dbg !684
  store i32 %36, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i1 false), align 4, !dbg !685
  br label %42, !dbg !681

37:                                               ; preds = %8
  %38 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !686
  %39 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !686
  %40 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !686
  store i16 %38, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !687
  store i16 lshr (i16 ptrtoint ([1 x i32]* @"$$csl_base_address$$0$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11" to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !687
  store i16 %39, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !687
  store i16 %40, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !687
  %41 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @"$$csl_base_address$$0$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11", i16 0, i1 false), align 4, !dbg !688
  store i32 %41, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i1 false), align 4, !dbg !689
  br label %42, !dbg !681

42:                                               ; preds = %32, %37
  store i32 165646921, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i2 1), align 4, !dbg !690
  %43 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !691
  %44 = icmp eq i16 0, %43, !dbg !692
  br i1 %44, label %45, label %56, !dbg !693

45:                                               ; preds = %42
  %46 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !694
  %47 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !694
  %48 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !694
  %49 = load i16, i16* %17, align 2, !dbg !695
  %50 = call i16* @.get_tensor_ptr(i16 %49), !dbg !696
  %51 = ptrtoint i16* %50 to i16, !dbg !697
  %52 = lshr i16 %51, 1, !dbg !697
  store i16 %46, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !698
  store i16 %52, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !698
  store i16 %47, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !698
  store i16 %48, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !698
  %53 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !699
  %54 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !699
  %55 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !699
  store i16 1, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !700
  store i16 %53, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !700
  store i16 %54, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !700
  store i16 %55, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !700
  call void @llvm.sdr.actvt.r(i16 21), !dbg !701
  br label %63, !dbg !693

56:                                               ; preds = %42
  %57 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !702
  %58 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !702
  %59 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !702
  store i16 %57, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !703
  store i16 lshr (i16 ptrtoint ([1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.data_buf to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !703
  store i16 %58, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !703
  store i16 %59, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !703
  %60 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !704
  %61 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !704
  %62 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !704
  store i16 1, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !705
  store i16 %60, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !705
  store i16 %61, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !705
  store i16 %62, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !705
  call void @llvm.sdr.ublk.r(i16 0), !dbg !706
  br label %63, !dbg !693

63:                                               ; preds = %45, %56
  ret void, !dbg !681
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x(i32 %0) #8 !dbg !707 {
  %2 = alloca i32, i16 1, align 4, !dbg !708
  store i32 %0, i32* %2, align 4, !dbg !708
  call void @llvm.sdr.blk.r(i16 0), !dbg !710
  %3 = load i32, i32* %2, align 4, !dbg !711
  store i32 %3, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.data_buf, i16 0, i1 false), align 4, !dbg !712
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !713
  %4 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !714
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !714
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !714
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !714
  store volatile i16 %4, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !715
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !715
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !715
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !715
  call void asm sideeffect "nop", ""(), !dbg !715
  call void asm sideeffect "nop", ""(), !dbg !715
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !716
  %8 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !717
  %9 = add i16 %8, 1, !dbg !718
  store i16 %9, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !719
  ret void, !dbg !720
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_send_data() #9 !dbg !721 {
  %1 = alloca i16, i16 1, align 2, !dbg !722
  %2 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !724
  %3 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !725
  %4 = icmp ult i16 %2, %3, !dbg !726
  br i1 %4, label %5, label %27, !dbg !727

5:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !728
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !729
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !729
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !729
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !729
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !730
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !730
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !730
  store volatile i16 %9, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !730
  call void asm sideeffect "nop", ""(), !dbg !730
  call void asm sideeffect "nop", ""(), !dbg !730
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_is_half, align 2, !dbg !731
  %11 = icmp ult i16 0, %10, !dbg !732
  br i1 %11, label %12, label %18, !dbg !733

12:                                               ; preds = %5
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !734
  %13 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !735
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !735
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !735
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !735
  %17 = add i16 %14, 1, !dbg !736
  store i16 %13, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !737
  store i16 %17, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !737
  store i16 %15, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !737
  store i16 %16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !737
  br label %24, !dbg !733

18:                                               ; preds = %5
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !738
  %19 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !739
  %20 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !739
  %21 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !739
  %22 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !739
  %23 = add i16 %20, 2, !dbg !740
  store i16 %19, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !741
  store i16 %23, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !741
  store i16 %21, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !741
  store i16 %22, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !741
  br label %24, !dbg !733

24:                                               ; preds = %12, %18
  %25 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !742
  %26 = add i16 %25, 1, !dbg !743
  store i16 %26, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !744
  br label %34, !dbg !727

27:                                               ; preds = %0
  %28 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !745
  store i16 %28, i16* %1, align 2, !dbg !722
  %29 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !746
  %30 = load i16, i16* %1, align 2, !dbg !747
  %31 = icmp eq i16 %29, %30, !dbg !748
  br i1 %31, label %32, label %33, !dbg !749

32:                                               ; preds = %27
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !750
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__1 to i8*)), !dbg !751
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !752
  br label %33, !dbg !749

33:                                               ; preds = %32, %27
  br label %34, !dbg !727

34:                                               ; preds = %24, %33
  ret void, !dbg !727
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl() #10 !dbg !753 {
  %1 = alloca i16, i16 1, align 2, !dbg !754
  %2 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !756
  %3 = icmp eq i16 0, %2, !dbg !757
  br i1 %3, label %4, label %9, !dbg !758

4:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__2 to i8*)), !dbg !759
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !760
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !760
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !760
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !760
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !761
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !761
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !761
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !761
  call void asm sideeffect "nop", ""(), !dbg !761
  call void asm sideeffect "nop", ""(), !dbg !761
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !762
  br label %31, !dbg !758

9:                                                ; preds = %0
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !763
  %11 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !764
  %12 = icmp ult i16 %10, %11, !dbg !765
  br i1 %12, label %13, label %18, !dbg !766

13:                                               ; preds = %9
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__3 to i8*)), !dbg !767
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !768
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !768
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !768
  %17 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !768
  store volatile i16 %14, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !769
  store volatile i16 %15, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !769
  store volatile i16 %16, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !769
  store volatile i16 %17, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !769
  call void asm sideeffect "nop", ""(), !dbg !769
  call void asm sideeffect "nop", ""(), !dbg !769
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !770
  br label %30, !dbg !766

18:                                               ; preds = %9
  %19 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !771
  store i16 %19, i16* %1, align 2, !dbg !754
  %20 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !772
  %21 = load i16, i16* %1, align 2, !dbg !773
  %22 = icmp eq i16 %20, %21, !dbg !774
  br i1 %22, label %23, label %24, !dbg !775

23:                                               ; preds = %18
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__4 to i8*)), !dbg !776
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__5 to i8*)), !dbg !777
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !778
  br label %29, !dbg !775

24:                                               ; preds = %18
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !779
  %25 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !780
  %26 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !780
  %27 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !780
  %28 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !780
  store volatile i16 %25, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !781
  store volatile i16 %26, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !781
  store volatile i16 %27, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !781
  store volatile i16 %28, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !781
  call void asm sideeffect "nop", ""(), !dbg !781
  call void asm sideeffect "nop", ""(), !dbg !781
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !782
  br label %29, !dbg !775

29:                                               ; preds = %23, %24
  br label %30, !dbg !766

30:                                               ; preds = %13, %29
  br label %31, !dbg !758

31:                                               ; preds = %4, %30
  ret void, !dbg !758
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.d2h_configure(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7) !dbg !783 {
  %9 = alloca i1, i16 1, align 1, !dbg !784
  %10 = alloca i1, i16 1, align 1, !dbg !786
  %11 = alloca i1, i16 1, align 1, !dbg !787
  %12 = alloca i16, i16 1, align 2, !dbg !788
  %13 = alloca i16, i16 1, align 2, !dbg !789
  %14 = alloca i16, i16 1, align 2, !dbg !790
  %15 = alloca i16, i16 1, align 2, !dbg !791
  %16 = alloca i16, i16 1, align 2, !dbg !792
  %17 = alloca i16, i16 1, align 2, !dbg !793
  %18 = alloca i16, i16 1, align 2, !dbg !794
  %19 = alloca i16, i16 1, align 2, !dbg !795
  %20 = alloca i16, i16 1, align 2, !dbg !796
  %21 = alloca i16, i16 1, align 2, !dbg !797
  %22 = alloca i16, i16 1, align 2, !dbg !798
  %23 = alloca i16, i16 1, align 2, !dbg !799
  %24 = alloca i16, i16 1, align 2, !dbg !800
  %25 = alloca i16, i16 1, align 2, !dbg !801
  store i16 %0, i16* %25, align 2, !dbg !801
  store i16 %1, i16* %24, align 2, !dbg !800
  store i16 %2, i16* %23, align 2, !dbg !799
  store i16 %3, i16* %22, align 2, !dbg !798
  store i16 %4, i16* %21, align 2, !dbg !797
  store i16 %5, i16* %20, align 2, !dbg !796
  store i16 %6, i16* %19, align 2, !dbg !795
  store i16 %7, i16* %18, align 2, !dbg !794
  %26 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !802
  store i16 %26, i16* %17, align 2, !dbg !793
  %27 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_y_coord(), !dbg !803
  store i16 %27, i16* %16, align 2, !dbg !792
  %28 = load i16, i16* %24, align 2, !dbg !804
  store i16 %28, i16* %15, align 2, !dbg !791
  %29 = load i16, i16* %24, align 2, !dbg !805
  %30 = load i16, i16* %22, align 2, !dbg !806
  %31 = add i16 %29, %30, !dbg !807
  %32 = sub i16 %31, 1, !dbg !808
  store i16 %32, i16* %14, align 2, !dbg !790
  %33 = load i16, i16* %23, align 2, !dbg !809
  store i16 %33, i16* %13, align 2, !dbg !789
  %34 = load i16, i16* %23, align 2, !dbg !810
  %35 = load i16, i16* %21, align 2, !dbg !811
  %36 = add i16 %34, %35, !dbg !812
  %37 = sub i16 %36, 1, !dbg !813
  store i16 %37, i16* %12, align 2, !dbg !788
  store i1 false, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !814
  %38 = load i16, i16* %17, align 2, !dbg !815
  %39 = load i16, i16* %15, align 2, !dbg !816
  %40 = icmp sge i16 %38, %39, !dbg !817
  br i1 %40, label %41, label %45, !dbg !787

41:                                               ; preds = %8
  %42 = load i16, i16* %16, align 2, !dbg !818
  %43 = load i16, i16* %12, align 2, !dbg !819
  %44 = icmp sle i16 %42, %43, !dbg !820
  store i1 %44, i1* %11, align 1, !dbg !787
  br label %46, !dbg !787

45:                                               ; preds = %8
  store i1 false, i1* %11, align 1, !dbg !787
  br label %46, !dbg !787

46:                                               ; preds = %41, %45
  %47 = load i1, i1* %11, align 1, !dbg !787
  br i1 %47, label %48, label %52, !dbg !786

48:                                               ; preds = %46
  %49 = load i16, i16* %16, align 2, !dbg !821
  %50 = load i16, i16* %13, align 2, !dbg !822
  %51 = icmp sge i16 %49, %50, !dbg !823
  store i1 %51, i1* %10, align 1, !dbg !786
  br label %53, !dbg !786

52:                                               ; preds = %46
  store i1 false, i1* %10, align 1, !dbg !786
  br label %53, !dbg !786

53:                                               ; preds = %48, %52
  %54 = load i1, i1* %10, align 1, !dbg !786
  br i1 %54, label %55, label %56, !dbg !824

55:                                               ; preds = %53
  store i1 true, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !825
  br label %56, !dbg !824

56:                                               ; preds = %55, %53
  store i1 false, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !826
  %57 = load i16, i16* %17, align 2, !dbg !827
  %58 = load i16, i16* %14, align 2, !dbg !828
  %59 = icmp sle i16 %57, %58, !dbg !829
  br i1 %59, label %60, label %62, !dbg !784

60:                                               ; preds = %56
  %61 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !830
  store i1 %61, i1* %9, align 1, !dbg !784
  br label %63, !dbg !784

62:                                               ; preds = %56
  store i1 false, i1* %9, align 1, !dbg !784
  br label %63, !dbg !784

63:                                               ; preds = %60, %62
  %64 = load i1, i1* %9, align 1, !dbg !784
  br i1 %64, label %65, label %66, !dbg !831

65:                                               ; preds = %63
  store i1 true, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !832
  br label %66, !dbg !831

66:                                               ; preds = %65, %63
  %67 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !833
  br i1 %67, label %68, label %86, !dbg !834

68:                                               ; preds = %66
  call void @__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position(i16 31959), !dbg !835
  %69 = load i16, i16* %15, align 2, !dbg !836
  %70 = load i16, i16* %17, align 2, !dbg !837
  %71 = icmp eq i16 %69, %70, !dbg !838
  br i1 %71, label %72, label %73, !dbg !839

72:                                               ; preds = %68
  call void @__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 31765), !dbg !840
  br label %74, !dbg !839

73:                                               ; preds = %68
  call void @__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 31765), !dbg !841
  br label %74, !dbg !839

74:                                               ; preds = %72, %73
  call void @sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit(i16 21), !dbg !842
  %75 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !843
  br i1 %75, label %76, label %85, !dbg !844

76:                                               ; preds = %74
  %77 = load i16, i16* %20, align 2, !dbg !845
  %78 = load i16, i16* %19, align 2, !dbg !846
  %79 = load i16, i16* %24, align 2, !dbg !847
  %80 = load i16, i16* %23, align 2, !dbg !848
  %81 = load i16, i16* %22, align 2, !dbg !849
  %82 = load i16, i16* %21, align 2, !dbg !850
  %83 = load i16, i16* %25, align 2, !dbg !851
  %84 = load i16, i16* %18, align 2, !dbg !852
  call void @sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start(i16 %77, i16 %78, i16 %79, i16 %80, i16 %81, i16 %82, i16 %83, i16 %84), !dbg !853
  br label %85, !dbg !844

85:                                               ; preds = %76, %74
  br label %87, !dbg !834

86:                                               ; preds = %66
  call void @llvm.sdr.actvt.r(i16 28), !dbg !854
  br label %87, !dbg !834

87:                                               ; preds = %85, %86
  ret void, !dbg !787
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit(i16 %0) !dbg !855 {
  %2 = alloca i16, i16 1, align 2, !dbg !856
  %3 = alloca i16, i16 1, align 2, !dbg !858
  %4 = alloca i16, i16 1, align 2, !dbg !859
  %5 = alloca i16, i16 1, align 2, !dbg !860
  store i16 %0, i16* %5, align 2, !dbg !860
  %6 = load i16, i16* %5, align 2, !dbg !861
  store i16 %6, i16* %4, align 2, !dbg !859
  %7 = load i16, i16* %4, align 2, !dbg !862
  %8 = add i16 %7, 31744, !dbg !863
  store i16 %8, i16* %3, align 2, !dbg !858
  %9 = load i16, i16* %3, align 2, !dbg !864
  %10 = shl i16 %9, 1, !dbg !865
  %11 = inttoptr i16 %10 to i16*, !dbg !865
  call void asm sideeffect "nop", ""(), !dbg !865
  call void asm sideeffect "nop", ""(), !dbg !865
  %12 = load volatile i16, i16* %11, align 2, !dbg !865
  store i16 %12, i16* %2, align 2, !dbg !856
  %13 = load i16, i16* %3, align 2, !dbg !866
  %14 = load i16, i16* %2, align 2, !dbg !867
  %15 = and i16 %14, 32767, !dbg !868
  %16 = shl i16 %13, 1, !dbg !869
  %17 = inttoptr i16 %16 to i16*, !dbg !869
  store volatile i16 %15, i16* %17, align 2, !dbg !869
  call void asm sideeffect "nop", ""(), !dbg !869
  call void asm sideeffect "nop", ""(), !dbg !869
  ret void, !dbg !870
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord() !dbg !871 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 2), !dbg !872
  %2 = sub i16 %1, 4, !dbg !874
  ret i16 %2, !dbg !875
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord() !dbg !876 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 0), !dbg !877
  %2 = sub i16 %1, 1, !dbg !879
  ret i16 %2, !dbg !880
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 %0) !dbg !881 {
  %2 = alloca i16, i16 1, align 2, !dbg !882
  %3 = alloca i16, i16 1, align 2, !dbg !884
  store i16 %0, i16* %3, align 2, !dbg !884
  %4 = load i16, i16* %3, align 2, !dbg !885
  %5 = lshr i16 %4, 1, !dbg !886
  %6 = add i16 %5, 31813, !dbg !887
  %7 = shl i16 %6, 1, !dbg !888
  %8 = inttoptr i16 %7 to i16*, !dbg !888
  call void asm sideeffect "nop", ""(), !dbg !888
  call void asm sideeffect "nop", ""(), !dbg !888
  %9 = load volatile i16, i16* %8, align 2, !dbg !888
  store i16 %9, i16* %2, align 2, !dbg !882
  %10 = load i16, i16* %2, align 2, !dbg !889
  %11 = and i16 %10, 2047, !dbg !890
  ret i16 %11, !dbg !891
}

define internal i16 @sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr(i16 %0) !dbg !892 {
  %2 = alloca i16, i16 1, align 2, !dbg !894
  store i16 %0, i16* %2, align 2, !dbg !894
  %3 = load i16, i16* %2, align 2, !dbg !896
  %4 = mul i16 %3, 2, !dbg !897
  %5 = add i16 %4, 31680, !dbg !898
  ret i16 %5, !dbg !899
}

define internal void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 %0, i16 %1, i1 %2) !dbg !900 {
  %4 = alloca i16, i16 1, align 2, !dbg !901
  %5 = alloca i16, i16 1, align 2, !dbg !903
  %6 = alloca i1, i16 1, align 1, !dbg !904
  %7 = alloca i16, i16 1, align 2, !dbg !905
  %8 = alloca i16, i16 1, align 2, !dbg !906
  store i16 %0, i16* %8, align 2, !dbg !906
  store i16 %1, i16* %7, align 2, !dbg !905
  store i1 %2, i1* %6, align 1, !dbg !904
  %9 = load i16, i16* %8, align 2, !dbg !907
  %10 = call i16 @sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr(i16 %9), !dbg !908
  store i16 %10, i16* %5, align 2, !dbg !903
  %11 = load i16, i16* %5, align 2, !dbg !909
  %12 = shl i16 %11, 1, !dbg !910
  %13 = inttoptr i16 %12 to i16*, !dbg !910
  call void asm sideeffect "nop", ""(), !dbg !910
  call void asm sideeffect "nop", ""(), !dbg !910
  call void asm sideeffect "nop", ""(), !dbg !910
  call void asm sideeffect "nop", ""(), !dbg !910
  %14 = load volatile i16, i16* %13, align 2, !dbg !910
  store i16 %14, i16* %4, align 2, !dbg !901
  %15 = load i1, i1* %6, align 1, !dbg !911
  br i1 %15, label %16, label %19, !dbg !912

16:                                               ; preds = %3
  %17 = load i16, i16* %4, align 2, !dbg !913
  %18 = or i16 %17, 2048, !dbg !914
  store i16 %18, i16* %4, align 2, !dbg !915
  br label %22, !dbg !912

19:                                               ; preds = %3
  %20 = load i16, i16* %4, align 2, !dbg !916
  %21 = and i16 %20, -2049, !dbg !917
  store i16 %21, i16* %4, align 2, !dbg !918
  br label %22, !dbg !912

22:                                               ; preds = %16, %19
  %23 = load i16, i16* %4, align 2, !dbg !919
  %24 = and i16 %23, -32, !dbg !920
  store i16 %24, i16* %4, align 2, !dbg !921
  %25 = load i16, i16* %4, align 2, !dbg !922
  %26 = load i16, i16* %7, align 2, !dbg !923
  %27 = add i16 %25, %26, !dbg !924
  store i16 %27, i16* %4, align 2, !dbg !925
  %28 = load i16, i16* %5, align 2, !dbg !926
  %29 = load i16, i16* %4, align 2, !dbg !927
  %30 = shl i16 %28, 1, !dbg !928
  %31 = inttoptr i16 %30 to i16*, !dbg !928
  store volatile i16 %29, i16* %31, align 2, !dbg !928
  call void asm sideeffect "nop", ""(), !dbg !928
  call void asm sideeffect "nop", ""(), !dbg !928
  call void asm sideeffect "nop", ""(), !dbg !928
  call void asm sideeffect "nop", ""(), !dbg !928
  ret void, !dbg !912
}

define internal i16 @sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr(i16 %0) !dbg !929 {
  %2 = alloca i16, i16 1, align 2, !dbg !931
  store i16 %0, i16* %2, align 2, !dbg !931
  %3 = load i16, i16* %2, align 2, !dbg !933
  %4 = add i16 %3, 31616, !dbg !934
  ret i16 %4, !dbg !935
}

define internal void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 %0, i16 %1) !dbg !936 {
  %3 = alloca i16, i16 1, align 2, !dbg !937
  %4 = alloca i16, i16 1, align 2, !dbg !939
  %5 = alloca i16, i16 1, align 2, !dbg !940
  %6 = alloca i16, i16 1, align 2, !dbg !941
  store i16 %0, i16* %6, align 2, !dbg !941
  store i16 %1, i16* %5, align 2, !dbg !940
  %7 = load i16, i16* %6, align 2, !dbg !942
  %8 = call i16 @sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr(i16 %7), !dbg !943
  store i16 %8, i16* %4, align 2, !dbg !939
  %9 = load i16, i16* %4, align 2, !dbg !944
  %10 = shl i16 %9, 1, !dbg !945
  %11 = inttoptr i16 %10 to i16*, !dbg !945
  call void asm sideeffect "nop", ""(), !dbg !945
  call void asm sideeffect "nop", ""(), !dbg !945
  call void asm sideeffect "nop", ""(), !dbg !945
  call void asm sideeffect "nop", ""(), !dbg !945
  %12 = load volatile i16, i16* %11, align 2, !dbg !945
  store i16 %12, i16* %3, align 2, !dbg !937
  %13 = load i16, i16* %3, align 2, !dbg !946
  %14 = and i16 %13, -497, !dbg !947
  store i16 %14, i16* %3, align 2, !dbg !948
  %15 = load i16, i16* %3, align 2, !dbg !949
  %16 = load i16, i16* %5, align 2, !dbg !950
  %17 = add i16 %15, %16, !dbg !951
  %18 = shl i16 %17, 4, !dbg !952
  store i16 %18, i16* %3, align 2, !dbg !953
  %19 = load i16, i16* %4, align 2, !dbg !954
  %20 = load i16, i16* %3, align 2, !dbg !955
  %21 = shl i16 %19, 1, !dbg !956
  %22 = inttoptr i16 %21 to i16*, !dbg !956
  store volatile i16 %20, i16* %22, align 2, !dbg !956
  call void asm sideeffect "nop", ""(), !dbg !956
  call void asm sideeffect "nop", ""(), !dbg !956
  call void asm sideeffect "nop", ""(), !dbg !956
  call void asm sideeffect "nop", ""(), !dbg !956
  ret void, !dbg !957
}

define internal i16* @.get_tensor_ptr(i16 %0) !dbg !958 {
  %2 = alloca i16, i16 1, align 2, !dbg !959
  store i16 %0, i16* %2, align 2, !dbg !959
  %3 = load i16, i16* %2, align 2, !dbg !959
  %4 = zext i16 %3 to i32, !dbg !959
  switch i32 %4, label %5 [
    i32 1, label %9
    i32 2, label %11
    i32 3, label %13
    i32 4, label %15
    i32 5, label %17
  ], !dbg !959

5:                                                ; preds = %1
  br i1 false, label %6, label %7, !dbg !959

6:                                                ; preds = %5
  br label %8, !dbg !959

7:                                                ; preds = %5
  call void asm sideeffect "hcf", ""(), !dbg !959
  br label %8, !dbg !959

8:                                                ; preds = %6, %7
  br label %19, !dbg !959

9:                                                ; preds = %1
  %10 = load i16*, i16** @p_a, align 8, !dbg !959
  br label %19, !dbg !959

11:                                               ; preds = %1
  %12 = load i16*, i16** @p_b, align 8, !dbg !959
  br label %19, !dbg !959

13:                                               ; preds = %1
  %14 = load i16*, i16** @p_c, align 8, !dbg !959
  br label %19, !dbg !959

15:                                               ; preds = %1
  %16 = load i16*, i16** @p_idx, align 8, !dbg !959
  br label %19, !dbg !959

17:                                               ; preds = %1
  %18 = load i16*, i16** @p_k, align 8, !dbg !959
  br label %19, !dbg !959

19:                                               ; preds = %8, %9, %11, %13, %15, %17
  %20 = phi i16 [ -2, %17 ], [ -2, %15 ], [ -2, %13 ], [ -2, %11 ], [ -2, %9 ], [ 0, %8 ]
  %21 = phi i16* [ %18, %17 ], [ %16, %15 ], [ %14, %13 ], [ %12, %11 ], [ %10, %9 ], [ undef, %8 ]
  br label %22, !dbg !959

22:                                               ; preds = %19
  %23 = icmp ne i16 %20, 0, !dbg !959
  br i1 %23, label %24, label %25, !dbg !959

24:                                               ; preds = %22
  br label %27, !dbg !959

25:                                               ; preds = %22
  %26 = load i16*, i16** @p_k, align 8, !dbg !959
  br label %27, !dbg !959

27:                                               ; preds = %24, %25
  %28 = phi i16* [ %26, %25 ], [ %21, %24 ]
  br label %29, !dbg !959

29:                                               ; preds = %27
  ret i16* %28, !dbg !959
}

define internal void @__generic0sys_mod.sys_mod.tile_config.queue_flush.exit() !dbg !961 {
  store volatile i16 1, i16* inttoptr (i16 -2268 to i16*), align 2, !dbg !963
  call void asm sideeffect "nop", ""(), !dbg !963
  call void asm sideeffect "nop", ""(), !dbg !963
  ret void, !dbg !965
}

define internal void @__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position(i16 %0) !dbg !966 {
  %2 = alloca i16, i16 1, align 2, !dbg !968
  %3 = alloca i16, i16 1, align 2, !dbg !970
  %4 = alloca i16, i16 1, align 2, !dbg !971
  store i16 %0, i16* %4, align 2, !dbg !971
  %5 = load i16, i16* %4, align 2, !dbg !972
  store i16 %5, i16* %3, align 2, !dbg !970
  %6 = load i16, i16* %3, align 2, !dbg !973
  %7 = shl i16 %6, 1, !dbg !974
  %8 = inttoptr i16 %7 to i16*, !dbg !974
  call void asm sideeffect "nop", ""(), !dbg !974
  call void asm sideeffect "nop", ""(), !dbg !974
  call void asm sideeffect "nop", ""(), !dbg !974
  call void asm sideeffect "nop", ""(), !dbg !974
  %9 = load volatile i16, i16* %8, align 2, !dbg !974
  store i16 %9, i16* %2, align 2, !dbg !968
  %10 = load i16, i16* %2, align 2, !dbg !975
  %11 = and i16 %10, -16, !dbg !976
  store i16 %11, i16* %2, align 2, !dbg !976
  %12 = load i16, i16* %3, align 2, !dbg !977
  %13 = load i16, i16* %2, align 2, !dbg !978
  %14 = shl i16 %12, 1, !dbg !979
  %15 = inttoptr i16 %14 to i16*, !dbg !979
  store volatile i16 %13, i16* %15, align 2, !dbg !979
  call void asm sideeffect "nop", ""(), !dbg !979
  call void asm sideeffect "nop", ""(), !dbg !979
  call void asm sideeffect "nop", ""(), !dbg !979
  call void asm sideeffect "nop", ""(), !dbg !979
  ret void, !dbg !980
}

define internal void @__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 %0) !dbg !981 {
  %2 = alloca i16, i16 1, align 2, !dbg !983
  %3 = alloca i16, i16 1, align 2, !dbg !985
  %4 = alloca i16, i16 1, align 2, !dbg !986
  store i16 %0, i16* %4, align 2, !dbg !986
  %5 = load i16, i16* %4, align 2, !dbg !987
  store i16 %5, i16* %3, align 2, !dbg !985
  %6 = load i16, i16* %3, align 2, !dbg !988
  %7 = shl i16 %6, 1, !dbg !989
  %8 = inttoptr i16 %7 to i16*, !dbg !989
  call void asm sideeffect "nop", ""(), !dbg !989
  call void asm sideeffect "nop", ""(), !dbg !989
  %9 = load volatile i16, i16* %8, align 2, !dbg !989
  store i16 %9, i16* %2, align 2, !dbg !983
  %10 = load i16, i16* %2, align 2, !dbg !990
  %11 = and i16 %10, -256, !dbg !991
  store i16 %11, i16* %2, align 2, !dbg !992
  %12 = load i16, i16* %2, align 2, !dbg !993
  %13 = load i16, i16* %2, align 2, !dbg !994
  %14 = call i16 @__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %13), !dbg !995
  %15 = or i16 %12, %14, !dbg !996
  store i16 %15, i16* %2, align 2, !dbg !996
  %16 = load i16, i16* %2, align 2, !dbg !997
  %17 = load i16, i16* %2, align 2, !dbg !998
  %18 = call i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %17), !dbg !999
  %19 = or i16 %16, %18, !dbg !1000
  store i16 %19, i16* %2, align 2, !dbg !1000
  %20 = load i16, i16* %3, align 2, !dbg !1001
  %21 = load i16, i16* %2, align 2, !dbg !1002
  %22 = shl i16 %20, 1, !dbg !1003
  %23 = inttoptr i16 %22 to i16*, !dbg !1003
  store volatile i16 %21, i16* %23, align 2, !dbg !1003
  call void asm sideeffect "nop", ""(), !dbg !1003
  call void asm sideeffect "nop", ""(), !dbg !1003
  ret void, !dbg !1004
}

define internal void @__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 %0) !dbg !1005 {
  %2 = alloca i16, i16 1, align 2, !dbg !1006
  %3 = alloca i16, i16 1, align 2, !dbg !1008
  %4 = alloca i16, i16 1, align 2, !dbg !1009
  store i16 %0, i16* %4, align 2, !dbg !1009
  %5 = load i16, i16* %4, align 2, !dbg !1010
  store i16 %5, i16* %3, align 2, !dbg !1008
  %6 = load i16, i16* %3, align 2, !dbg !1011
  %7 = shl i16 %6, 1, !dbg !1012
  %8 = inttoptr i16 %7 to i16*, !dbg !1012
  call void asm sideeffect "nop", ""(), !dbg !1012
  call void asm sideeffect "nop", ""(), !dbg !1012
  %9 = load volatile i16, i16* %8, align 2, !dbg !1012
  store i16 %9, i16* %2, align 2, !dbg !1006
  %10 = load i16, i16* %2, align 2, !dbg !1013
  %11 = and i16 %10, -256, !dbg !1014
  store i16 %11, i16* %2, align 2, !dbg !1015
  %12 = load i16, i16* %2, align 2, !dbg !1016
  %13 = load i16, i16* %2, align 2, !dbg !1017
  %14 = call i16 @__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %13), !dbg !1018
  %15 = or i16 %12, %14, !dbg !1019
  store i16 %15, i16* %2, align 2, !dbg !1019
  %16 = load i16, i16* %2, align 2, !dbg !1020
  %17 = load i16, i16* %2, align 2, !dbg !1021
  %18 = call i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %17), !dbg !1022
  %19 = or i16 %16, %18, !dbg !1023
  store i16 %19, i16* %2, align 2, !dbg !1023
  %20 = load i16, i16* %3, align 2, !dbg !1024
  %21 = load i16, i16* %2, align 2, !dbg !1025
  %22 = shl i16 %20, 1, !dbg !1026
  %23 = inttoptr i16 %22 to i16*, !dbg !1026
  store volatile i16 %21, i16* %23, align 2, !dbg !1026
  call void asm sideeffect "nop", ""(), !dbg !1026
  call void asm sideeffect "nop", ""(), !dbg !1026
  ret void, !dbg !1027
}

define internal i16 @__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %0) !dbg !1028 {
  %2 = alloca i16, i16 1, align 2, !dbg !1029
  %3 = alloca i16, i16 1, align 2, !dbg !1031
  store i16 %0, i16* %3, align 2, !dbg !1031
  %4 = load i16, i16* %3, align 2, !dbg !1032
  store i16 %4, i16* %2, align 2, !dbg !1029
  %5 = load i16, i16* %2, align 2, !dbg !1033
  store i16 %5, i16* %2, align 2, !dbg !1034
  %6 = load i16, i16* %2, align 2, !dbg !1035
  ret i16 %6, !dbg !1036
}

define internal i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %0) !dbg !1037 {
  %2 = alloca i16, i16 1, align 2, !dbg !1038
  %3 = alloca i16, i16 1, align 2, !dbg !1040
  store i16 %0, i16* %3, align 2, !dbg !1040
  %4 = load i16, i16* %3, align 2, !dbg !1041
  store i16 %4, i16* %2, align 2, !dbg !1038
  %5 = load i16, i16* %2, align 2, !dbg !1042
  %6 = or i16 %5, 2, !dbg !1043
  store i16 %6, i16* %2, align 2, !dbg !1043
  %7 = load i16, i16* %2, align 2, !dbg !1044
  ret i16 %7, !dbg !1045
}

define internal i16 @__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %0) !dbg !1046 {
  %2 = alloca i16, i16 1, align 2, !dbg !1047
  %3 = alloca i16, i16 1, align 2, !dbg !1049
  store i16 %0, i16* %3, align 2, !dbg !1049
  %4 = load i16, i16* %3, align 2, !dbg !1050
  store i16 %4, i16* %2, align 2, !dbg !1047
  %5 = load i16, i16* %2, align 2, !dbg !1051
  %6 = or i16 %5, 128, !dbg !1052
  store i16 %6, i16* %2, align 2, !dbg !1052
  %7 = load i16, i16* %2, align 2, !dbg !1053
  ret i16 %7, !dbg !1054
}

define internal void @__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction(i16 %0) !dbg !1055 {
  %2 = alloca i16, i16 1, align 2, !dbg !1056
  %3 = alloca i16, i16 1, align 2, !dbg !1058
  %4 = alloca i16, i16 1, align 2, !dbg !1059
  store i16 %0, i16* %4, align 2, !dbg !1059
  %5 = load i16, i16* %4, align 2, !dbg !1060
  store i16 %5, i16* %3, align 2, !dbg !1058
  %6 = load i16, i16* %3, align 2, !dbg !1061
  %7 = shl i16 %6, 1, !dbg !1062
  %8 = inttoptr i16 %7 to i16*, !dbg !1062
  call void asm sideeffect "nop", ""(), !dbg !1062
  call void asm sideeffect "nop", ""(), !dbg !1062
  %9 = load volatile i16, i16* %8, align 2, !dbg !1062
  store i16 %9, i16* %2, align 2, !dbg !1056
  %10 = load i16, i16* %2, align 2, !dbg !1063
  %11 = and i16 %10, -17, !dbg !1064
  store i16 %11, i16* %2, align 2, !dbg !1064
  %12 = load i16, i16* %3, align 2, !dbg !1065
  %13 = load i16, i16* %2, align 2, !dbg !1066
  %14 = shl i16 %12, 1, !dbg !1067
  %15 = inttoptr i16 %14 to i16*, !dbg !1067
  store volatile i16 %13, i16* %15, align 2, !dbg !1067
  call void asm sideeffect "nop", ""(), !dbg !1067
  call void asm sideeffect "nop", ""(), !dbg !1067
  ret void, !dbg !1068
}

define internal void @__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction(i16 %0) !dbg !1069 {
  %2 = alloca i16, i16 1, align 2, !dbg !1070
  %3 = alloca i16, i16 1, align 2, !dbg !1072
  %4 = alloca i16, i16 1, align 2, !dbg !1073
  store i16 %0, i16* %4, align 2, !dbg !1073
  %5 = load i16, i16* %4, align 2, !dbg !1074
  store i16 %5, i16* %3, align 2, !dbg !1072
  %6 = load i16, i16* %3, align 2, !dbg !1075
  %7 = shl i16 %6, 1, !dbg !1076
  %8 = inttoptr i16 %7 to i16*, !dbg !1076
  call void asm sideeffect "nop", ""(), !dbg !1076
  call void asm sideeffect "nop", ""(), !dbg !1076
  %9 = load volatile i16, i16* %8, align 2, !dbg !1076
  store i16 %9, i16* %2, align 2, !dbg !1070
  %10 = load i16, i16* %2, align 2, !dbg !1077
  %11 = or i16 %10, 16, !dbg !1078
  store i16 %11, i16* %2, align 2, !dbg !1078
  %12 = load i16, i16* %3, align 2, !dbg !1079
  %13 = load i16, i16* %2, align 2, !dbg !1080
  %14 = shl i16 %12, 1, !dbg !1081
  %15 = inttoptr i16 %14 to i16*, !dbg !1081
  store volatile i16 %13, i16* %15, align 2, !dbg !1081
  call void asm sideeffect "nop", ""(), !dbg !1081
  call void asm sideeffect "nop", ""(), !dbg !1081
  ret void, !dbg !1082
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
!4 = !DIFile(filename: "./pe.csl", directory: "/home/USER/xkernel/studies/wse3-characterization/microbench/addfam/cases/W_chain_in_loop")
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
!16 = !DILocation(line: 18, column: 41, scope: !8)
!17 = !DILocation(line: 18, column: 38, scope: !8)
!18 = !DILocation(line: 18, column: 50, scope: !8)
!19 = !DILocation(line: 18, column: 49, scope: !8)
!20 = !DILocation(line: 18, column: 46, scope: !8)
!21 = !DILocation(line: 18, column: 32, scope: !8)
!22 = !DILocation(line: 18, column: 31, scope: !8)
!23 = !DILocation(line: 18, column: 35, scope: !8)
!24 = !DILocation(line: 18, column: 20, scope: !8)
!25 = !DILocation(line: 18, column: 22, scope: !8)
!26 = !DILocation(line: 19, column: 3, scope: !8)
!27 = distinct !DISubprogram(name: "f_exit", linkageName: "f_exit", scope: null, file: !4, line: 22, type: !5, scopeLine: 22, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!28 = !DILocation(line: 22, column: 22, scope: !29)
!29 = !DILexicalBlockFile(scope: !27, file: !4, discriminator: 0)
!30 = !DILocation(line: 22, column: 1, scope: !29)
!31 = distinct !DISubprogram(name: "sys_mod.sys_nop", linkageName: "sys_mod.sys_nop", scope: null, file: !32, line: 90, type: !5, scopeLine: 90, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!32 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/memcpy.csl", directory: "")
!33 = !DILocation(line: 90, column: 1, scope: !34)
!34 = !DILexicalBlockFile(scope: !31, file: !32, discriminator: 0)
!35 = distinct !DISubprogram(name: "sys_mod.unblock_cmd_stream", linkageName: "sys_mod.unblock_cmd_stream", scope: null, file: !32, line: 102, type: !5, scopeLine: 102, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!36 = !DILocation(line: 103, column: 3, scope: !37)
!37 = !DILexicalBlockFile(scope: !35, file: !32, discriminator: 0)
!38 = !DILocation(line: 102, column: 1, scope: !37)
!39 = distinct !DISubprogram(name: "sys_mod.sys_mod.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.unblock_cmd_stream", scope: null, file: !40, line: 307, type: !5, scopeLine: 307, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!40 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpy.csl", directory: "")
!41 = !DILocation(line: 308, column: 5, scope: !42)
!42 = !DILexicalBlockFile(scope: !39, file: !40, discriminator: 0)
!43 = !DILocation(line: 307, column: 1, scope: !42)
!44 = distinct !DISubprogram(name: "sys_mod.sys_mod.teardown_h2d", linkageName: "sys_mod.sys_mod.teardown_h2d", scope: null, file: !40, line: 323, type: !5, scopeLine: 323, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!45 = !DILocation(line: 326, column: 5, scope: !46)
!46 = !DILexicalBlockFile(scope: !44, file: !40, discriminator: 0)
!47 = !DILocation(line: 323, column: 1, scope: !46)
!48 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_ublk_c22", linkageName: "sys_mod.sys_mod.f_ublk_c22", scope: null, file: !40, line: 335, type: !5, scopeLine: 335, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!49 = !DILocation(line: 336, column: 5, scope: !50)
!50 = !DILexicalBlockFile(scope: !48, file: !40, discriminator: 0)
!51 = !DILocation(line: 335, column: 1, scope: !50)
!52 = distinct !DISubprogram(name: "sys_mod.sys_mod.teardown_d2h", linkageName: "sys_mod.sys_mod.teardown_d2h", scope: null, file: !40, line: 344, type: !5, scopeLine: 344, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!53 = !DILocation(line: 355, column: 5, scope: !54)
!54 = !DILexicalBlockFile(scope: !52, file: !40, discriminator: 0)
!55 = !DILocation(line: 359, column: 5, scope: !54)
!56 = !DILocation(line: 344, column: 1, scope: !54)
!57 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_memcpyh2d", linkageName: "sys_mod.sys_mod.f_memcpyh2d", scope: null, file: !40, line: 460, type: !5, scopeLine: 460, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!58 = !DILocation(line: 477, column: 5, scope: !59)
!59 = !DILexicalBlockFile(scope: !57, file: !40, discriminator: 0)
!60 = !DILocation(line: 476, column: 5, scope: !59)
!61 = !DILocation(line: 475, column: 5, scope: !59)
!62 = !DILocation(line: 474, column: 5, scope: !59)
!63 = !DILocation(line: 473, column: 5, scope: !59)
!64 = !DILocation(line: 472, column: 5, scope: !59)
!65 = !DILocation(line: 471, column: 5, scope: !59)
!66 = !DILocation(line: 470, column: 5, scope: !59)
!67 = !DILocation(line: 469, column: 5, scope: !59)
!68 = !DILocation(line: 468, column: 5, scope: !59)
!69 = !DILocation(line: 467, column: 5, scope: !59)
!70 = !DILocation(line: 466, column: 5, scope: !59)
!71 = !DILocation(line: 465, column: 5, scope: !59)
!72 = !DILocation(line: 463, column: 5, scope: !59)
!73 = !DILocation(line: 462, column: 20, scope: !59)
!74 = !DILocation(line: 462, column: 32, scope: !59)
!75 = !DILocation(line: 462, column: 5, scope: !59)
!76 = !DILocation(line: 465, column: 33, scope: !59)
!77 = !DILocation(line: 465, column: 38, scope: !59)
!78 = !DILocation(line: 466, column: 34, scope: !59)
!79 = !DILocation(line: 466, column: 39, scope: !59)
!80 = !DILocation(line: 467, column: 34, scope: !59)
!81 = !DILocation(line: 467, column: 39, scope: !59)
!82 = !DILocation(line: 468, column: 33, scope: !59)
!83 = !DILocation(line: 468, column: 38, scope: !59)
!84 = !DILocation(line: 469, column: 33, scope: !59)
!85 = !DILocation(line: 469, column: 38, scope: !59)
!86 = !DILocation(line: 470, column: 35, scope: !59)
!87 = !DILocation(line: 470, column: 21, scope: !59)
!88 = !DILocation(line: 471, column: 41, scope: !59)
!89 = !DILocation(line: 471, column: 27, scope: !59)
!90 = !DILocation(line: 472, column: 39, scope: !59)
!91 = !DILocation(line: 472, column: 25, scope: !59)
!92 = !DILocation(line: 473, column: 44, scope: !59)
!93 = !DILocation(line: 473, column: 49, scope: !59)
!94 = !DILocation(line: 474, column: 41, scope: !59)
!95 = !DILocation(line: 474, column: 46, scope: !59)
!96 = !DILocation(line: 475, column: 41, scope: !59)
!97 = !DILocation(line: 475, column: 46, scope: !59)
!98 = !DILocation(line: 476, column: 59, scope: !59)
!99 = !DILocation(line: 476, column: 64, scope: !59)
!100 = !DILocation(line: 476, column: 50, scope: !59)
!101 = !DILocation(line: 476, column: 129, scope: !59)
!102 = !DILocation(line: 476, column: 134, scope: !59)
!103 = !DILocation(line: 476, column: 120, scope: !59)
!104 = !DILocation(line: 476, column: 118, scope: !59)
!105 = !DILocation(line: 476, column: 112, scope: !59)
!106 = !DILocation(line: 476, column: 36, scope: !59)
!107 = !DILocation(line: 477, column: 59, scope: !59)
!108 = !DILocation(line: 477, column: 64, scope: !59)
!109 = !DILocation(line: 477, column: 50, scope: !59)
!110 = !DILocation(line: 477, column: 129, scope: !59)
!111 = !DILocation(line: 477, column: 134, scope: !59)
!112 = !DILocation(line: 477, column: 120, scope: !59)
!113 = !DILocation(line: 477, column: 118, scope: !59)
!114 = !DILocation(line: 477, column: 112, scope: !59)
!115 = !DILocation(line: 477, column: 36, scope: !59)
!116 = !DILocation(line: 479, column: 24, scope: !59)
!117 = !DILocation(line: 481, column: 21, scope: !59)
!118 = !DILocation(line: 481, column: 19, scope: !59)
!119 = !DILocation(line: 482, column: 21, scope: !59)
!120 = !DILocation(line: 482, column: 19, scope: !59)
!121 = !DILocation(line: 483, column: 21, scope: !59)
!122 = !DILocation(line: 483, column: 19, scope: !59)
!123 = !DILocation(line: 484, column: 20, scope: !59)
!124 = !DILocation(line: 484, column: 18, scope: !59)
!125 = !DILocation(line: 485, column: 20, scope: !59)
!126 = !DILocation(line: 485, column: 18, scope: !59)
!127 = !DILocation(line: 486, column: 22, scope: !59)
!128 = !DILocation(line: 486, column: 20, scope: !59)
!129 = !DILocation(line: 487, column: 27, scope: !59)
!130 = !DILocation(line: 487, column: 25, scope: !59)
!131 = !DILocation(line: 488, column: 25, scope: !59)
!132 = !DILocation(line: 488, column: 23, scope: !59)
!133 = !DILocation(line: 489, column: 31, scope: !59)
!134 = !DILocation(line: 489, column: 29, scope: !59)
!135 = !DILocation(line: 490, column: 28, scope: !59)
!136 = !DILocation(line: 490, column: 26, scope: !59)
!137 = !DILocation(line: 491, column: 28, scope: !59)
!138 = !DILocation(line: 491, column: 26, scope: !59)
!139 = !DILocation(line: 492, column: 37, scope: !59)
!140 = !DILocation(line: 492, column: 35, scope: !59)
!141 = !DILocation(line: 493, column: 37, scope: !59)
!142 = !DILocation(line: 493, column: 35, scope: !59)
!143 = !DILocation(line: 495, column: 5, scope: !59)
!144 = !DILocation(line: 501, column: 5, scope: !59)
!145 = !DILocation(line: 506, column: 5, scope: !59)
!146 = !DILocation(line: 521, column: 5, scope: !59)
!147 = !DILocation(line: 522, column: 16, scope: !59)
!148 = !DILocation(line: 531, column: 5, scope: !59)
!149 = !DILocation(line: 460, column: 1, scope: !59)
!150 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_memcpyd2h", linkageName: "sys_mod.sys_mod.f_memcpyd2h", scope: null, file: !40, line: 556, type: !5, scopeLine: 556, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!151 = !DILocation(line: 568, column: 5, scope: !152)
!152 = !DILexicalBlockFile(scope: !150, file: !40, discriminator: 0)
!153 = !DILocation(line: 567, column: 5, scope: !152)
!154 = !DILocation(line: 566, column: 5, scope: !152)
!155 = !DILocation(line: 565, column: 5, scope: !152)
!156 = !DILocation(line: 564, column: 5, scope: !152)
!157 = !DILocation(line: 563, column: 5, scope: !152)
!158 = !DILocation(line: 562, column: 5, scope: !152)
!159 = !DILocation(line: 561, column: 5, scope: !152)
!160 = !DILocation(line: 559, column: 5, scope: !152)
!161 = !DILocation(line: 558, column: 20, scope: !152)
!162 = !DILocation(line: 558, column: 32, scope: !152)
!163 = !DILocation(line: 558, column: 5, scope: !152)
!164 = !DILocation(line: 561, column: 33, scope: !152)
!165 = !DILocation(line: 561, column: 38, scope: !152)
!166 = !DILocation(line: 562, column: 34, scope: !152)
!167 = !DILocation(line: 562, column: 39, scope: !152)
!168 = !DILocation(line: 563, column: 34, scope: !152)
!169 = !DILocation(line: 563, column: 39, scope: !152)
!170 = !DILocation(line: 564, column: 33, scope: !152)
!171 = !DILocation(line: 564, column: 38, scope: !152)
!172 = !DILocation(line: 565, column: 33, scope: !152)
!173 = !DILocation(line: 565, column: 38, scope: !152)
!174 = !DILocation(line: 566, column: 35, scope: !152)
!175 = !DILocation(line: 566, column: 21, scope: !152)
!176 = !DILocation(line: 567, column: 41, scope: !152)
!177 = !DILocation(line: 567, column: 27, scope: !152)
!178 = !DILocation(line: 568, column: 39, scope: !152)
!179 = !DILocation(line: 568, column: 25, scope: !152)
!180 = !DILocation(line: 570, column: 24, scope: !152)
!181 = !DILocation(line: 573, column: 21, scope: !152)
!182 = !DILocation(line: 573, column: 19, scope: !152)
!183 = !DILocation(line: 574, column: 21, scope: !152)
!184 = !DILocation(line: 574, column: 19, scope: !152)
!185 = !DILocation(line: 575, column: 21, scope: !152)
!186 = !DILocation(line: 575, column: 19, scope: !152)
!187 = !DILocation(line: 576, column: 20, scope: !152)
!188 = !DILocation(line: 576, column: 18, scope: !152)
!189 = !DILocation(line: 577, column: 20, scope: !152)
!190 = !DILocation(line: 577, column: 18, scope: !152)
!191 = !DILocation(line: 578, column: 22, scope: !152)
!192 = !DILocation(line: 578, column: 20, scope: !152)
!193 = !DILocation(line: 579, column: 27, scope: !152)
!194 = !DILocation(line: 579, column: 25, scope: !152)
!195 = !DILocation(line: 580, column: 25, scope: !152)
!196 = !DILocation(line: 580, column: 23, scope: !152)
!197 = !DILocation(line: 582, column: 5, scope: !152)
!198 = !DILocation(line: 588, column: 59, scope: !152)
!199 = !DILocation(line: 588, column: 5, scope: !152)
!200 = !DILocation(line: 608, column: 5, scope: !152)
!201 = !DILocation(line: 609, column: 16, scope: !152)
!202 = !DILocation(line: 556, column: 1, scope: !152)
!203 = distinct !DISubprogram(name: "sys_mod.sys_mod.oq0_teardow_handler", linkageName: "sys_mod.sys_mod.oq0_teardow_handler", scope: null, file: !40, line: 631, type: !5, scopeLine: 631, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!204 = !DILocation(line: 632, column: 9, scope: !205)
!205 = !DILexicalBlockFile(scope: !203, file: !40, discriminator: 0)
!206 = !DILocation(line: 632, column: 5, scope: !205)
!207 = !DILocation(line: 634, column: 66, scope: !205)
!208 = !DILocation(line: 634, column: 9, scope: !205)
!209 = !DILocation(line: 636, column: 13, scope: !205)
!210 = !DILocation(line: 637, column: 13, scope: !205)
!211 = !DILocation(line: 638, column: 13, scope: !205)
!212 = !DILocation(line: 639, column: 13, scope: !205)
!213 = !DILocation(line: 640, column: 13, scope: !205)
!214 = !DILocation(line: 641, column: 13, scope: !205)
!215 = !DILocation(line: 642, column: 13, scope: !205)
!216 = !DILocation(line: 643, column: 13, scope: !205)
!217 = !DILocation(line: 644, column: 13, scope: !205)
!218 = !DILocation(line: 645, column: 13, scope: !205)
!219 = !DILocation(line: 646, column: 13, scope: !205)
!220 = !DILocation(line: 647, column: 13, scope: !205)
!221 = !DILocation(line: 648, column: 13, scope: !205)
!222 = !DILocation(line: 635, column: 9, scope: !205)
!223 = !DILocation(line: 652, column: 9, scope: !205)
!224 = !DILocation(line: 654, column: 13, scope: !205)
!225 = !DILocation(line: 655, column: 13, scope: !205)
!226 = !DILocation(line: 656, column: 13, scope: !205)
!227 = !DILocation(line: 657, column: 13, scope: !205)
!228 = !DILocation(line: 658, column: 13, scope: !205)
!229 = !DILocation(line: 659, column: 13, scope: !205)
!230 = !DILocation(line: 660, column: 13, scope: !205)
!231 = !DILocation(line: 661, column: 13, scope: !205)
!232 = !DILocation(line: 653, column: 9, scope: !205)
!233 = !DILocation(line: 664, column: 5, scope: !205)
!234 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_rpc", linkageName: "sys_mod.sys_mod.f_rpc", scope: null, file: !40, line: 694, type: !5, scopeLine: 694, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!235 = !DILocation(line: 694, column: 13, scope: !236)
!236 = !DILexicalBlockFile(scope: !234, file: !40, discriminator: 0)
!237 = !DILocation(line: 700, column: 5, scope: !236)
!238 = !DILocation(line: 706, column: 20, scope: !236)
!239 = !DILocation(line: 706, column: 32, scope: !236)
!240 = !DILocation(line: 706, column: 5, scope: !236)
!241 = !DILocation(line: 710, column: 5, scope: !236)
!242 = !DILocation(line: 712, column: 24, scope: !236)
!243 = !DILocation(line: 694, column: 1, scope: !236)
!244 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.stack_push", linkageName: "sys_mod.sys_mod.sys_mod.stack_push", scope: null, file: !245, line: 54, type: !5, scopeLine: 54, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!245 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/sys.csl", directory: "")
!246 = !DILocation(line: 60, column: 5, scope: !247)
!247 = !DILexicalBlockFile(scope: !244, file: !245, discriminator: 0)
!248 = !DILocation(line: 54, column: 16, scope: !247)
!249 = !DILocation(line: 59, column: 13, scope: !247)
!250 = !DILocation(line: 59, column: 24, scope: !247)
!251 = !DILocation(line: 59, column: 5, scope: !247)
!252 = !DILocation(line: 61, column: 25, scope: !247)
!253 = !DILocation(line: 61, column: 5, scope: !247)
!254 = !DILocation(line: 61, column: 11, scope: !247)
!255 = !DILocation(line: 61, column: 10, scope: !247)
!256 = !DILocation(line: 61, column: 23, scope: !247)
!257 = !DILocation(line: 62, column: 18, scope: !247)
!258 = !DILocation(line: 62, column: 29, scope: !247)
!259 = !DILocation(line: 62, column: 16, scope: !247)
!260 = !DILocation(line: 54, column: 1, scope: !247)
!261 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_push", linkageName: "sys_mod.sys_mod.sys_mod.f_push", scope: null, file: !245, line: 72, type: !5, scopeLine: 72, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!262 = !DILocation(line: 72, column: 25, scope: !263)
!263 = !DILexicalBlockFile(scope: !261, file: !245, discriminator: 0)
!264 = !DILocation(line: 72, column: 13, scope: !263)
!265 = !DILocation(line: 73, column: 16, scope: !263)
!266 = !DILocation(line: 73, column: 5, scope: !263)
!267 = !DILocation(line: 72, column: 1, scope: !263)
!268 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.block_cmd_stream", linkageName: "sys_mod.sys_mod.sys_mod.block_cmd_stream", scope: null, file: !245, line: 76, type: !5, scopeLine: 76, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!269 = !DILocation(line: 77, column: 5, scope: !270)
!270 = !DILexicalBlockFile(scope: !268, file: !245, discriminator: 0)
!271 = !DILocation(line: 76, column: 1, scope: !270)
!272 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.sys_mod.unblock_cmd_stream", scope: null, file: !245, line: 80, type: !5, scopeLine: 80, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!273 = !DILocation(line: 81, column: 5, scope: !274)
!274 = !DILexicalBlockFile(scope: !272, file: !245, discriminator: 0)
!275 = !DILocation(line: 80, column: 1, scope: !274)
!276 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_sys_exit", linkageName: "sys_mod.sys_mod.sys_mod.f_sys_exit", scope: null, file: !245, line: 85, type: !5, scopeLine: 85, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!277 = !DILocation(line: 86, column: 5, scope: !278)
!278 = !DILexicalBlockFile(scope: !276, file: !245, discriminator: 0)
!279 = !DILocation(line: 87, column: 5, scope: !278)
!280 = !DILocation(line: 85, column: 1, scope: !278)
!281 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore", linkageName: "sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore", scope: null, file: !245, line: 90, type: !5, scopeLine: 90, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!282 = !DILocation(line: 90, column: 30, scope: !283)
!283 = !DILexicalBlockFile(scope: !281, file: !245, discriminator: 0)
!284 = !DILocation(line: 90, column: 1, scope: !283)
!285 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord", scope: null, file: !286, line: 131, type: !5, scopeLine: 131, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!286 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpyh2d.csl", directory: "")
!287 = !DILocation(line: 132, column: 12, scope: !288)
!288 = !DILexicalBlockFile(scope: !285, file: !286, discriminator: 0)
!289 = !DILocation(line: 132, column: 5, scope: !288)
!290 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord", scope: null, file: !286, line: 134, type: !5, scopeLine: 134, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!291 = !DILocation(line: 135, column: 12, scope: !292)
!292 = !DILexicalBlockFile(scope: !290, file: !286, discriminator: 0)
!293 = !DILocation(line: 135, column: 5, scope: !292)
!294 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval", scope: null, file: !286, line: 148, type: !5, scopeLine: 148, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!295 = !DILocation(line: 148, column: 23, scope: !296)
!296 = !DILexicalBlockFile(scope: !294, file: !286, discriminator: 0)
!297 = !DILocation(line: 149, column: 9, scope: !296)
!298 = !DILocation(line: 149, column: 20, scope: !296)
!299 = !DILocation(line: 149, column: 5, scope: !296)
!300 = !DILocation(line: 152, column: 23, scope: !296)
!301 = !DILocation(line: 152, column: 20, scope: !296)
!302 = !DILocation(line: 152, column: 9, scope: !296)
!303 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start", scope: null, file: !286, line: 226, type: !5, scopeLine: 226, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!304 = !DILocation(line: 233, column: 5, scope: !305)
!305 = !DILexicalBlockFile(scope: !303, file: !286, discriminator: 0)
!306 = !DILocation(line: 226, column: 49, scope: !305)
!307 = !DILocation(line: 226, column: 32, scope: !305)
!308 = !DILocation(line: 226, column: 21, scope: !305)
!309 = !DILocation(line: 229, column: 37, scope: !305)
!310 = !DILocation(line: 229, column: 52, scope: !305)
!311 = !DILocation(line: 229, column: 19, scope: !305)
!312 = !DILocation(line: 233, column: 71, scope: !305)
!313 = !DILocation(line: 233, column: 55, scope: !305)
!314 = !DILocation(line: 233, column: 25, scope: !305)
!315 = !DILocation(line: 235, column: 37, scope: !305)
!316 = !DILocation(line: 235, column: 52, scope: !305)
!317 = !DILocation(line: 235, column: 19, scope: !305)
!318 = !DILocation(line: 236, column: 28, scope: !305)
!319 = !DILocation(line: 236, column: 5, scope: !305)
!320 = !DILocation(line: 237, column: 28, scope: !305)
!321 = !DILocation(line: 237, column: 5, scope: !305)
!322 = !DILocation(line: 238, column: 13, scope: !305)
!323 = !DILocation(line: 238, column: 11, scope: !305)
!324 = !DILocation(line: 238, column: 5, scope: !305)
!325 = !DILocation(line: 239, column: 9, scope: !305)
!326 = !DILocation(line: 241, column: 9, scope: !305)
!327 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream", scope: null, file: !286, line: 249, type: !5, scopeLine: 249, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!328 = !DILocation(line: 250, column: 5, scope: !329)
!329 = !DILexicalBlockFile(scope: !327, file: !286, discriminator: 0)
!330 = !DILocation(line: 249, column: 1, scope: !329)
!331 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure", scope: null, file: !286, line: 276, type: !5, scopeLine: 276, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!332 = !DILocation(line: 414, column: 13, scope: !333)
!333 = !DILexicalBlockFile(scope: !331, file: !286, discriminator: 0)
!334 = !DILocation(line: 413, column: 13, scope: !333)
!335 = !DILocation(line: 400, column: 17, scope: !333)
!336 = !DILocation(line: 340, column: 9, scope: !333)
!337 = !DILocation(line: 339, column: 9, scope: !333)
!338 = !DILocation(line: 337, column: 5, scope: !333)
!339 = !DILocation(line: 319, column: 9, scope: !333)
!340 = !DILocation(line: 318, column: 9, scope: !333)
!341 = !DILocation(line: 315, column: 5, scope: !333)
!342 = !DILocation(line: 292, column: 5, scope: !333)
!343 = !DILocation(line: 291, column: 5, scope: !333)
!344 = !DILocation(line: 289, column: 5, scope: !333)
!345 = !DILocation(line: 288, column: 5, scope: !333)
!346 = !DILocation(line: 287, column: 5, scope: !333)
!347 = !DILocation(line: 286, column: 5, scope: !333)
!348 = !DILocation(line: 285, column: 5, scope: !333)
!349 = !DILocation(line: 284, column: 5, scope: !333)
!350 = !DILocation(line: 283, column: 5, scope: !333)
!351 = !DILocation(line: 282, column: 5, scope: !333)
!352 = !DILocation(line: 281, column: 5, scope: !333)
!353 = !DILocation(line: 280, column: 5, scope: !333)
!354 = !DILocation(line: 279, column: 5, scope: !333)
!355 = !DILocation(line: 278, column: 5, scope: !333)
!356 = !DILocation(line: 277, column: 5, scope: !333)
!357 = !DILocation(line: 291, column: 26, scope: !333)
!358 = !DILocation(line: 292, column: 26, scope: !333)
!359 = !DILocation(line: 315, column: 25, scope: !333)
!360 = !DILocation(line: 315, column: 31, scope: !333)
!361 = !DILocation(line: 315, column: 29, scope: !333)
!362 = !DILocation(line: 316, column: 20, scope: !333)
!363 = !DILocation(line: 316, column: 18, scope: !333)
!364 = !DILocation(line: 317, column: 52, scope: !333)
!365 = !DILocation(line: 317, column: 49, scope: !333)
!366 = !DILocation(line: 317, column: 5, scope: !333)
!367 = !DILocation(line: 318, column: 42, scope: !333)
!368 = !DILocation(line: 318, column: 33, scope: !333)
!369 = !DILocation(line: 318, column: 49, scope: !333)
!370 = !DILocation(line: 318, column: 48, scope: !333)
!371 = !DILocation(line: 318, column: 24, scope: !333)
!372 = !DILocation(line: 319, column: 24, scope: !333)
!373 = !DILocation(line: 319, column: 32, scope: !333)
!374 = !DILocation(line: 319, column: 36, scope: !333)
!375 = !DILocation(line: 319, column: 34, scope: !333)
!376 = !DILocation(line: 319, column: 30, scope: !333)
!377 = !DILocation(line: 320, column: 18, scope: !333)
!378 = !DILocation(line: 320, column: 15, scope: !333)
!379 = !DILocation(line: 320, column: 9, scope: !333)
!380 = !DILocation(line: 321, column: 26, scope: !333)
!381 = !DILocation(line: 325, column: 28, scope: !333)
!382 = !DILocation(line: 325, column: 26, scope: !333)
!383 = !DILocation(line: 331, column: 9, scope: !333)
!384 = !DILocation(line: 331, column: 15, scope: !333)
!385 = !DILocation(line: 331, column: 5, scope: !333)
!386 = !DILocation(line: 332, column: 22, scope: !333)
!387 = !DILocation(line: 334, column: 9, scope: !333)
!388 = !DILocation(line: 334, column: 18, scope: !333)
!389 = !DILocation(line: 334, column: 15, scope: !333)
!390 = !DILocation(line: 334, column: 5, scope: !333)
!391 = !DILocation(line: 335, column: 22, scope: !333)
!392 = !DILocation(line: 338, column: 52, scope: !333)
!393 = !DILocation(line: 338, column: 49, scope: !333)
!394 = !DILocation(line: 338, column: 5, scope: !333)
!395 = !DILocation(line: 339, column: 42, scope: !333)
!396 = !DILocation(line: 339, column: 48, scope: !333)
!397 = !DILocation(line: 339, column: 46, scope: !333)
!398 = !DILocation(line: 339, column: 33, scope: !333)
!399 = !DILocation(line: 339, column: 52, scope: !333)
!400 = !DILocation(line: 339, column: 51, scope: !333)
!401 = !DILocation(line: 339, column: 24, scope: !333)
!402 = !DILocation(line: 340, column: 25, scope: !333)
!403 = !DILocation(line: 340, column: 31, scope: !333)
!404 = !DILocation(line: 340, column: 29, scope: !333)
!405 = !DILocation(line: 340, column: 37, scope: !333)
!406 = !DILocation(line: 340, column: 41, scope: !333)
!407 = !DILocation(line: 340, column: 39, scope: !333)
!408 = !DILocation(line: 340, column: 35, scope: !333)
!409 = !DILocation(line: 341, column: 18, scope: !333)
!410 = !DILocation(line: 341, column: 15, scope: !333)
!411 = !DILocation(line: 341, column: 9, scope: !333)
!412 = !DILocation(line: 342, column: 26, scope: !333)
!413 = !DILocation(line: 347, column: 10, scope: !333)
!414 = !DILocation(line: 347, column: 16, scope: !333)
!415 = !DILocation(line: 347, column: 14, scope: !333)
!416 = !DILocation(line: 347, column: 5, scope: !333)
!417 = !DILocation(line: 348, column: 22, scope: !333)
!418 = !DILocation(line: 350, column: 10, scope: !333)
!419 = !DILocation(line: 350, column: 18, scope: !333)
!420 = !DILocation(line: 350, column: 21, scope: !333)
!421 = !DILocation(line: 350, column: 20, scope: !333)
!422 = !DILocation(line: 350, column: 14, scope: !333)
!423 = !DILocation(line: 350, column: 5, scope: !333)
!424 = !DILocation(line: 351, column: 22, scope: !333)
!425 = !DILocation(line: 354, column: 9, scope: !333)
!426 = !DILocation(line: 354, column: 5, scope: !333)
!427 = !DILocation(line: 358, column: 9, scope: !333)
!428 = !DILocation(line: 361, column: 9, scope: !333)
!429 = !DILocation(line: 364, column: 20, scope: !333)
!430 = !DILocation(line: 364, column: 17, scope: !333)
!431 = !DILocation(line: 364, column: 9, scope: !333)
!432 = !DILocation(line: 368, column: 13, scope: !333)
!433 = !DILocation(line: 371, column: 13, scope: !333)
!434 = !DILocation(line: 375, column: 13, scope: !333)
!435 = !DILocation(line: 394, column: 13, scope: !333)
!436 = !DILocation(line: 396, column: 29, scope: !333)
!437 = !DILocation(line: 396, column: 27, scope: !333)
!438 = !DILocation(line: 397, column: 60, scope: !333)
!439 = !DILocation(line: 397, column: 57, scope: !333)
!440 = !DILocation(line: 397, column: 13, scope: !333)
!441 = !DILocation(line: 400, column: 54, scope: !333)
!442 = !DILocation(line: 400, column: 55, scope: !333)
!443 = !DILocation(line: 400, column: 46, scope: !333)
!444 = !DILocation(line: 400, column: 59, scope: !333)
!445 = !DILocation(line: 400, column: 58, scope: !333)
!446 = !DILocation(line: 400, column: 37, scope: !333)
!447 = !DILocation(line: 400, column: 35, scope: !333)
!448 = !DILocation(line: 401, column: 33, scope: !333)
!449 = !DILocation(line: 401, column: 31, scope: !333)
!450 = !DILocation(line: 402, column: 69, scope: !333)
!451 = !DILocation(line: 402, column: 66, scope: !333)
!452 = !DILocation(line: 402, column: 19, scope: !333)
!453 = !DILocation(line: 404, column: 31, scope: !333)
!454 = !DILocation(line: 408, column: 75, scope: !333)
!455 = !DILocation(line: 408, column: 88, scope: !333)
!456 = !DILocation(line: 408, column: 13, scope: !333)
!457 = !DILocation(line: 413, column: 31, scope: !333)
!458 = !DILocation(line: 414, column: 33, scope: !333)
!459 = !DILocation(line: 415, column: 21, scope: !333)
!460 = !DILocation(line: 415, column: 29, scope: !333)
!461 = !DILocation(line: 415, column: 27, scope: !333)
!462 = !DILocation(line: 415, column: 19, scope: !333)
!463 = !DILocation(line: 416, column: 22, scope: !333)
!464 = !DILocation(line: 416, column: 19, scope: !333)
!465 = !DILocation(line: 416, column: 13, scope: !333)
!466 = !DILocation(line: 417, column: 23, scope: !333)
!467 = !DILocation(line: 419, column: 63, scope: !333)
!468 = !DILocation(line: 419, column: 60, scope: !333)
!469 = !DILocation(line: 419, column: 13, scope: !333)
!470 = !DILocation(line: 421, column: 23, scope: !333)
!471 = !DILocation(line: 423, column: 69, scope: !333)
!472 = !DILocation(line: 423, column: 13, scope: !333)
!473 = !DILocation(line: 426, column: 13, scope: !333)
!474 = !DILocation(line: 430, column: 13, scope: !333)
!475 = !DILocation(line: 433, column: 48, scope: !333)
!476 = !DILocation(line: 433, column: 22, scope: !333)
!477 = !DILocation(line: 433, column: 19, scope: !333)
!478 = !DILocation(line: 433, column: 13, scope: !333)
!479 = !DILocation(line: 436, column: 34, scope: !333)
!480 = !DILocation(line: 436, column: 39, scope: !333)
!481 = !DILocation(line: 436, column: 50, scope: !333)
!482 = !DILocation(line: 436, column: 17, scope: !333)
!483 = !DILocation(line: 452, column: 49, scope: !333)
!484 = !DILocation(line: 452, column: 64, scope: !333)
!485 = !DILocation(line: 452, column: 31, scope: !333)
!486 = !DILocation(line: 453, column: 40, scope: !333)
!487 = !DILocation(line: 453, column: 17, scope: !333)
!488 = !DILocation(line: 454, column: 50, scope: !333)
!489 = !DILocation(line: 454, column: 66, scope: !333)
!490 = !DILocation(line: 454, column: 32, scope: !333)
!491 = !DILocation(line: 455, column: 40, scope: !333)
!492 = !DILocation(line: 455, column: 17, scope: !333)
!493 = !DILocation(line: 456, column: 17, scope: !333)
!494 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit", scope: null, file: !495, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!495 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/filters/wse3.csl", directory: "")
!496 = !DILocation(line: 24, column: 3, scope: !497)
!497 = !DILexicalBlockFile(scope: !494, file: !495, discriminator: 0)
!498 = !DILocation(line: 24, column: 22, scope: !497)
!499 = !DILocation(line: 23, column: 3, scope: !497)
!500 = !DILocation(line: 22, column: 3, scope: !497)
!501 = !DILocation(line: 20, column: 37, scope: !497)
!502 = !DILocation(line: 20, column: 21, scope: !497)
!503 = !DILocation(line: 21, column: 11, scope: !497)
!504 = !DILocation(line: 21, column: 17, scope: !497)
!505 = !DILocation(line: 21, column: 3, scope: !497)
!506 = !DILocation(line: 22, column: 24, scope: !497)
!507 = !DILocation(line: 22, column: 30, scope: !497)
!508 = !DILocation(line: 23, column: 40, scope: !497)
!509 = !DILocation(line: 23, column: 22, scope: !497)
!510 = !DILocation(line: 23, column: 67, scope: !497)
!511 = !DILocation(line: 24, column: 26, scope: !497)
!512 = !DILocation(line: 24, column: 41, scope: !497)
!513 = !DILocation(line: 24, column: 39, scope: !497)
!514 = !DILocation(line: 24, column: 61, scope: !497)
!515 = !DILocation(line: 24, column: 76, scope: !497)
!516 = !DILocation(line: 24, column: 74, scope: !497)
!517 = !DILocation(line: 25, column: 21, scope: !497)
!518 = !DILocation(line: 25, column: 50, scope: !497)
!519 = !DILocation(line: 25, column: 3, scope: !497)
!520 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter", scope: null, file: !495, line: 30, type: !5, scopeLine: 30, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!521 = !DILocation(line: 30, column: 36, scope: !522)
!522 = !DILexicalBlockFile(scope: !520, file: !495, discriminator: 0)
!523 = !DILocation(line: 30, column: 20, scope: !522)
!524 = !DILocation(line: 31, column: 11, scope: !522)
!525 = !DILocation(line: 31, column: 23, scope: !522)
!526 = !DILocation(line: 31, column: 3, scope: !522)
!527 = !DILocation(line: 32, column: 21, scope: !522)
!528 = !DILocation(line: 32, column: 48, scope: !522)
!529 = !DILocation(line: 32, column: 60, scope: !522)
!530 = !DILocation(line: 32, column: 64, scope: !522)
!531 = !DILocation(line: 32, column: 3, scope: !522)
!532 = !DILocation(line: 30, column: 1, scope: !522)
!533 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter", scope: null, file: !495, line: 40, type: !5, scopeLine: 40, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!534 = !DILocation(line: 47, column: 3, scope: !535)
!535 = !DILexicalBlockFile(scope: !533, file: !495, discriminator: 0)
!536 = !DILocation(line: 48, column: 7, scope: !535)
!537 = !DILocation(line: 44, column: 3, scope: !535)
!538 = !DILocation(line: 43, column: 3, scope: !535)
!539 = !DILocation(line: 42, column: 3, scope: !535)
!540 = !DILocation(line: 40, column: 32, scope: !535)
!541 = !DILocation(line: 40, column: 16, scope: !535)
!542 = !DILocation(line: 41, column: 11, scope: !535)
!543 = !DILocation(line: 41, column: 19, scope: !535)
!544 = !DILocation(line: 41, column: 3, scope: !535)
!545 = !DILocation(line: 42, column: 40, scope: !535)
!546 = !DILocation(line: 42, column: 22, scope: !535)
!547 = !DILocation(line: 43, column: 26, scope: !535)
!548 = !DILocation(line: 43, column: 34, scope: !535)
!549 = !DILocation(line: 44, column: 25, scope: !535)
!550 = !DILocation(line: 44, column: 42, scope: !535)
!551 = !DILocation(line: 44, column: 40, scope: !535)
!552 = !DILocation(line: 45, column: 21, scope: !535)
!553 = !DILocation(line: 46, column: 35, scope: !535)
!554 = !DILocation(line: 46, column: 21, scope: !535)
!555 = !DILocation(line: 46, column: 50, scope: !535)
!556 = !DILocation(line: 45, column: 3, scope: !535)
!557 = !DILocation(line: 48, column: 11, scope: !535)
!558 = !DILocation(line: 48, column: 26, scope: !535)
!559 = !DILocation(line: 48, column: 43, scope: !535)
!560 = !DILocation(line: 48, column: 41, scope: !535)
!561 = !DILocation(line: 48, column: 54, scope: !535)
!562 = !DILocation(line: 48, column: 63, scope: !535)
!563 = !DILocation(line: 49, column: 21, scope: !535)
!564 = !DILocation(line: 49, column: 47, scope: !535)
!565 = !DILocation(line: 49, column: 3, scope: !535)
!566 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config", scope: null, file: !567, line: 33, type: !5, scopeLine: 33, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!567 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/filters/common.csl", directory: "")
!568 = !DILocation(line: 33, column: 46, scope: !569)
!569 = !DILexicalBlockFile(scope: !566, file: !567, discriminator: 0)
!570 = !DILocation(line: 33, column: 31, scope: !569)
!571 = !DILocation(line: 33, column: 15, scope: !569)
!572 = !DILocation(line: 34, column: 24, scope: !569)
!573 = !DILocation(line: 34, column: 23, scope: !569)
!574 = !DILocation(line: 34, column: 51, scope: !569)
!575 = !DILocation(line: 34, column: 35, scope: !569)
!576 = !DILocation(line: 34, column: 60, scope: !569)
!577 = !DILocation(line: 34, column: 73, scope: !569)
!578 = !DILocation(line: 34, column: 3, scope: !569)
!579 = !DILocation(line: 33, column: 1, scope: !569)
!580 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config", scope: null, file: !567, line: 38, type: !5, scopeLine: 38, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!581 = !DILocation(line: 38, column: 31, scope: !582)
!582 = !DILexicalBlockFile(scope: !580, file: !567, discriminator: 0)
!583 = !DILocation(line: 38, column: 15, scope: !582)
!584 = !DILocation(line: 39, column: 31, scope: !582)
!585 = !DILocation(line: 39, column: 30, scope: !582)
!586 = !DILocation(line: 39, column: 58, scope: !582)
!587 = !DILocation(line: 39, column: 42, scope: !582)
!588 = !DILocation(line: 39, column: 67, scope: !582)
!589 = !DILocation(line: 39, column: 10, scope: !582)
!590 = !DILocation(line: 39, column: 3, scope: !582)
!591 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit", scope: null, file: !592, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!592 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/teardown.csl", directory: "")
!593 = !DILocation(line: 43, column: 3, scope: !594)
!594 = !DILexicalBlockFile(scope: !591, file: !592, discriminator: 0)
!595 = !DILocation(line: 41, column: 3, scope: !594)
!596 = !DILocation(line: 40, column: 3, scope: !594)
!597 = !DILocation(line: 39, column: 9, scope: !594)
!598 = !DILocation(line: 40, column: 23, scope: !594)
!599 = !DILocation(line: 41, column: 70, scope: !594)
!600 = !DILocation(line: 41, column: 68, scope: !594)
!601 = !DILocation(line: 43, column: 27, scope: !594)
!602 = !DILocation(line: 43, column: 15, scope: !594)
!603 = !DILocation(line: 44, column: 15, scope: !594)
!604 = !DILocation(line: 44, column: 21, scope: !594)
!605 = !DILocation(line: 44, column: 27, scope: !594)
!606 = !DILocation(line: 44, column: 3, scope: !594)
!607 = !DILocation(line: 39, column: 1, scope: !594)
!608 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord", scope: null, file: !609, line: 4, type: !5, scopeLine: 4, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!609 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/layout.csl", directory: "")
!610 = !DILocation(line: 5, column: 10, scope: !611)
!611 = !DILexicalBlockFile(scope: !608, file: !609, discriminator: 0)
!612 = !DILocation(line: 5, column: 67, scope: !611)
!613 = !DILocation(line: 5, column: 3, scope: !611)
!614 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord", scope: null, file: !609, line: 8, type: !5, scopeLine: 8, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!615 = !DILocation(line: 9, column: 10, scope: !616)
!616 = !DILexicalBlockFile(scope: !614, file: !609, discriminator: 0)
!617 = !DILocation(line: 9, column: 67, scope: !616)
!618 = !DILocation(line: 9, column: 3, scope: !616)
!619 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord", scope: null, file: !620, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!620 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config.csl", directory: "")
!621 = !DILocation(line: 50, column: 3, scope: !622)
!622 = !DILexicalBlockFile(scope: !619, file: !620, discriminator: 0)
!623 = !DILocation(line: 43, column: 21, scope: !622)
!624 = !DILocation(line: 50, column: 57, scope: !622)
!625 = !DILocation(line: 50, column: 68, scope: !622)
!626 = !DILocation(line: 50, column: 41, scope: !622)
!627 = !DILocation(line: 50, column: 19, scope: !622)
!628 = !DILocation(line: 52, column: 10, scope: !622)
!629 = !DILocation(line: 52, column: 18, scope: !622)
!630 = !DILocation(line: 48, column: 22, scope: !622)
!631 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.get_x_coord", scope: null, file: !632, line: 171, type: !5, scopeLine: 171, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!632 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpyd2h.csl", directory: "")
!633 = !DILocation(line: 172, column: 12, scope: !634)
!634 = !DILexicalBlockFile(scope: !631, file: !632, discriminator: 0)
!635 = !DILocation(line: 172, column: 5, scope: !634)
!636 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.get_y_coord", scope: null, file: !632, line: 174, type: !5, scopeLine: 174, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!637 = !DILocation(line: 175, column: 12, scope: !638)
!638 = !DILexicalBlockFile(scope: !636, file: !632, discriminator: 0)
!639 = !DILocation(line: 175, column: 5, scope: !638)
!640 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval", scope: null, file: !632, line: 187, type: !5, scopeLine: 187, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!641 = !DILocation(line: 187, column: 23, scope: !642)
!642 = !DILexicalBlockFile(scope: !640, file: !632, discriminator: 0)
!643 = !DILocation(line: 188, column: 9, scope: !642)
!644 = !DILocation(line: 188, column: 20, scope: !642)
!645 = !DILocation(line: 188, column: 5, scope: !642)
!646 = !DILocation(line: 191, column: 23, scope: !642)
!647 = !DILocation(line: 191, column: 20, scope: !642)
!648 = !DILocation(line: 191, column: 9, scope: !642)
!649 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start", scope: null, file: !632, line: 383, type: !5, scopeLine: 383, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!650 = !DILocation(line: 386, column: 5, scope: !651)
!651 = !DILexicalBlockFile(scope: !649, file: !632, discriminator: 0)
!652 = !DILocation(line: 384, column: 72, scope: !651)
!653 = !DILocation(line: 384, column: 59, scope: !651)
!654 = !DILocation(line: 384, column: 46, scope: !651)
!655 = !DILocation(line: 384, column: 33, scope: !651)
!656 = !DILocation(line: 384, column: 19, scope: !651)
!657 = !DILocation(line: 384, column: 5, scope: !651)
!658 = !DILocation(line: 383, column: 32, scope: !651)
!659 = !DILocation(line: 383, column: 21, scope: !651)
!660 = !DILocation(line: 386, column: 26, scope: !651)
!661 = !DILocation(line: 388, column: 28, scope: !651)
!662 = !DILocation(line: 388, column: 17, scope: !651)
!663 = !DILocation(line: 389, column: 25, scope: !651)
!664 = !DILocation(line: 389, column: 23, scope: !651)
!665 = !DILocation(line: 391, column: 38, scope: !651)
!666 = !DILocation(line: 391, column: 20, scope: !651)
!667 = !DILocation(line: 391, column: 18, scope: !651)
!668 = !DILocation(line: 393, column: 7, scope: !651)
!669 = !DILocation(line: 395, column: 17, scope: !651)
!670 = !DILocation(line: 395, column: 15, scope: !651)
!671 = !DILocation(line: 397, column: 15, scope: !651)
!672 = !DILocation(line: 397, column: 13, scope: !651)
!673 = !DILocation(line: 398, column: 15, scope: !651)
!674 = !DILocation(line: 398, column: 25, scope: !651)
!675 = !DILocation(line: 398, column: 23, scope: !651)
!676 = !DILocation(line: 398, column: 31, scope: !651)
!677 = !DILocation(line: 398, column: 13, scope: !651)
!678 = !DILocation(line: 401, column: 10, scope: !651)
!679 = !DILocation(line: 401, column: 17, scope: !651)
!680 = !DILocation(line: 401, column: 14, scope: !651)
!681 = !DILocation(line: 401, column: 5, scope: !651)
!682 = !DILocation(line: 403, column: 48, scope: !651)
!683 = !DILocation(line: 403, column: 26, scope: !651)
!684 = !DILocation(line: 404, column: 26, scope: !651)
!685 = !DILocation(line: 404, column: 18, scope: !651)
!686 = !DILocation(line: 407, column: 48, scope: !651)
!687 = !DILocation(line: 407, column: 26, scope: !651)
!688 = !DILocation(line: 408, column: 27, scope: !651)
!689 = !DILocation(line: 408, column: 18, scope: !651)
!690 = !DILocation(line: 411, column: 14, scope: !651)
!691 = !DILocation(line: 414, column: 14, scope: !651)
!692 = !DILocation(line: 414, column: 11, scope: !651)
!693 = !DILocation(line: 414, column: 5, scope: !651)
!694 = !DILocation(line: 416, column: 44, scope: !651)
!695 = !DILocation(line: 416, column: 75, scope: !651)
!696 = !DILocation(line: 416, column: 59, scope: !651)
!697 = !DILocation(line: 416, column: 25, scope: !651)
!698 = !DILocation(line: 416, column: 23, scope: !651)
!699 = !DILocation(line: 418, column: 41, scope: !651)
!700 = !DILocation(line: 418, column: 23, scope: !651)
!701 = !DILocation(line: 419, column: 9, scope: !651)
!702 = !DILocation(line: 425, column: 44, scope: !651)
!703 = !DILocation(line: 425, column: 23, scope: !651)
!704 = !DILocation(line: 426, column: 41, scope: !651)
!705 = !DILocation(line: 426, column: 23, scope: !651)
!706 = !DILocation(line: 427, column: 9, scope: !651)
!707 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x", scope: null, file: !632, line: 448, type: !5, scopeLine: 448, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!708 = !DILocation(line: 448, column: 31, scope: !709)
!709 = !DILexicalBlockFile(scope: !707, file: !632, discriminator: 0)
!710 = !DILocation(line: 453, column: 5, scope: !709)
!711 = !DILocation(line: 456, column: 19, scope: !709)
!712 = !DILocation(line: 456, column: 17, scope: !709)
!713 = !DILocation(line: 461, column: 5, scope: !709)
!714 = !DILocation(line: 462, column: 28, scope: !709)
!715 = !DILocation(line: 462, column: 5, scope: !709)
!716 = !DILocation(line: 463, column: 5, scope: !709)
!717 = !DILocation(line: 464, column: 9, scope: !709)
!718 = !DILocation(line: 464, column: 10, scope: !709)
!719 = !DILocation(line: 464, column: 7, scope: !709)
!720 = !DILocation(line: 448, column: 1, scope: !709)
!721 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_send_data", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_send_data", scope: null, file: !632, line: 476, type: !5, scopeLine: 476, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!722 = !DILocation(line: 494, column: 9, scope: !723)
!723 = !DILexicalBlockFile(scope: !721, file: !632, discriminator: 0)
!724 = !DILocation(line: 478, column: 9, scope: !723)
!725 = !DILocation(line: 478, column: 13, scope: !723)
!726 = !DILocation(line: 478, column: 11, scope: !723)
!727 = !DILocation(line: 478, column: 5, scope: !723)
!728 = !DILocation(line: 479, column: 9, scope: !723)
!729 = !DILocation(line: 480, column: 32, scope: !723)
!730 = !DILocation(line: 480, column: 9, scope: !723)
!731 = !DILocation(line: 481, column: 17, scope: !723)
!732 = !DILocation(line: 481, column: 15, scope: !723)
!733 = !DILocation(line: 481, column: 9, scope: !723)
!734 = !DILocation(line: 482, column: 13, scope: !723)
!735 = !DILocation(line: 483, column: 51, scope: !723)
!736 = !DILocation(line: 483, column: 29, scope: !723)
!737 = !DILocation(line: 483, column: 27, scope: !723)
!738 = !DILocation(line: 485, column: 13, scope: !723)
!739 = !DILocation(line: 486, column: 51, scope: !723)
!740 = !DILocation(line: 486, column: 29, scope: !723)
!741 = !DILocation(line: 486, column: 27, scope: !723)
!742 = !DILocation(line: 488, column: 13, scope: !723)
!743 = !DILocation(line: 488, column: 14, scope: !723)
!744 = !DILocation(line: 488, column: 11, scope: !723)
!745 = !DILocation(line: 494, column: 30, scope: !723)
!746 = !DILocation(line: 496, column: 14, scope: !723)
!747 = !DILocation(line: 496, column: 25, scope: !723)
!748 = !DILocation(line: 496, column: 22, scope: !723)
!749 = !DILocation(line: 496, column: 9, scope: !723)
!750 = !DILocation(line: 497, column: 13, scope: !723)
!751 = !DILocation(line: 498, column: 13, scope: !723)
!752 = !DILocation(line: 499, column: 13, scope: !723)
!753 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl", scope: null, file: !632, line: 505, type: !5, scopeLine: 505, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!754 = !DILocation(line: 524, column: 13, scope: !755)
!755 = !DILexicalBlockFile(scope: !753, file: !632, discriminator: 0)
!756 = !DILocation(line: 506, column: 14, scope: !755)
!757 = !DILocation(line: 506, column: 11, scope: !755)
!758 = !DILocation(line: 506, column: 5, scope: !755)
!759 = !DILocation(line: 508, column: 9, scope: !755)
!760 = !DILocation(line: 509, column: 32, scope: !755)
!761 = !DILocation(line: 509, column: 9, scope: !755)
!762 = !DILocation(line: 510, column: 9, scope: !755)
!763 = !DILocation(line: 514, column: 13, scope: !755)
!764 = !DILocation(line: 514, column: 17, scope: !755)
!765 = !DILocation(line: 514, column: 15, scope: !755)
!766 = !DILocation(line: 514, column: 9, scope: !755)
!767 = !DILocation(line: 518, column: 13, scope: !755)
!768 = !DILocation(line: 519, column: 36, scope: !755)
!769 = !DILocation(line: 519, column: 13, scope: !755)
!770 = !DILocation(line: 520, column: 13, scope: !755)
!771 = !DILocation(line: 524, column: 34, scope: !755)
!772 = !DILocation(line: 526, column: 18, scope: !755)
!773 = !DILocation(line: 526, column: 29, scope: !755)
!774 = !DILocation(line: 526, column: 26, scope: !755)
!775 = !DILocation(line: 526, column: 13, scope: !755)
!776 = !DILocation(line: 529, column: 17, scope: !755)
!777 = !DILocation(line: 530, column: 17, scope: !755)
!778 = !DILocation(line: 531, column: 17, scope: !755)
!779 = !DILocation(line: 534, column: 17, scope: !755)
!780 = !DILocation(line: 535, column: 40, scope: !755)
!781 = !DILocation(line: 535, column: 17, scope: !755)
!782 = !DILocation(line: 536, column: 17, scope: !755)
!783 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.d2h_configure", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.d2h_configure", scope: null, file: !632, line: 593, type: !5, scopeLine: 593, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!784 = !DILocation(line: 617, column: 26, scope: !785)
!785 = !DILexicalBlockFile(scope: !783, file: !632, discriminator: 0)
!786 = !DILocation(line: 612, column: 47, scope: !785)
!787 = !DILocation(line: 612, column: 27, scope: !785)
!788 = !DILocation(line: 602, column: 5, scope: !785)
!789 = !DILocation(line: 601, column: 5, scope: !785)
!790 = !DILocation(line: 599, column: 5, scope: !785)
!791 = !DILocation(line: 598, column: 5, scope: !785)
!792 = !DILocation(line: 596, column: 5, scope: !785)
!793 = !DILocation(line: 595, column: 5, scope: !785)
!794 = !DILocation(line: 593, column: 86, scope: !785)
!795 = !DILocation(line: 593, column: 70, scope: !785)
!796 = !DILocation(line: 593, column: 60, scope: !785)
!797 = !DILocation(line: 593, column: 52, scope: !785)
!798 = !DILocation(line: 593, column: 44, scope: !785)
!799 = !DILocation(line: 593, column: 35, scope: !785)
!800 = !DILocation(line: 593, column: 26, scope: !785)
!801 = !DILocation(line: 593, column: 18, scope: !785)
!802 = !DILocation(line: 595, column: 26, scope: !785)
!803 = !DILocation(line: 596, column: 26, scope: !785)
!804 = !DILocation(line: 598, column: 23, scope: !785)
!805 = !DILocation(line: 599, column: 23, scope: !785)
!806 = !DILocation(line: 599, column: 28, scope: !785)
!807 = !DILocation(line: 599, column: 26, scope: !785)
!808 = !DILocation(line: 599, column: 29, scope: !785)
!809 = !DILocation(line: 601, column: 24, scope: !785)
!810 = !DILocation(line: 602, column: 24, scope: !785)
!811 = !DILocation(line: 602, column: 29, scope: !785)
!812 = !DILocation(line: 602, column: 27, scope: !785)
!813 = !DILocation(line: 602, column: 30, scope: !785)
!814 = !DILocation(line: 611, column: 20, scope: !785)
!815 = !DILocation(line: 612, column: 11, scope: !785)
!816 = !DILocation(line: 612, column: 18, scope: !785)
!817 = !DILocation(line: 612, column: 15, scope: !785)
!818 = !DILocation(line: 612, column: 32, scope: !785)
!819 = !DILocation(line: 612, column: 39, scope: !785)
!820 = !DILocation(line: 612, column: 36, scope: !785)
!821 = !DILocation(line: 612, column: 52, scope: !785)
!822 = !DILocation(line: 612, column: 59, scope: !785)
!823 = !DILocation(line: 612, column: 56, scope: !785)
!824 = !DILocation(line: 612, column: 5, scope: !785)
!825 = !DILocation(line: 613, column: 24, scope: !785)
!826 = !DILocation(line: 616, column: 15, scope: !785)
!827 = !DILocation(line: 617, column: 11, scope: !785)
!828 = !DILocation(line: 617, column: 18, scope: !785)
!829 = !DILocation(line: 617, column: 15, scope: !785)
!830 = !DILocation(line: 617, column: 30, scope: !785)
!831 = !DILocation(line: 617, column: 5, scope: !785)
!832 = !DILocation(line: 618, column: 19, scope: !785)
!833 = !DILocation(line: 621, column: 9, scope: !785)
!834 = !DILocation(line: 621, column: 5, scope: !785)
!835 = !DILocation(line: 627, column: 9, scope: !785)
!836 = !DILocation(line: 629, column: 13, scope: !785)
!837 = !DILocation(line: 629, column: 25, scope: !785)
!838 = !DILocation(line: 629, column: 21, scope: !785)
!839 = !DILocation(line: 629, column: 9, scope: !785)
!840 = !DILocation(line: 632, column: 13, scope: !785)
!841 = !DILocation(line: 636, column: 13, scope: !785)
!842 = !DILocation(line: 641, column: 9, scope: !785)
!843 = !DILocation(line: 646, column: 13, scope: !785)
!844 = !DILocation(line: 646, column: 9, scope: !785)
!845 = !DILocation(line: 647, column: 30, scope: !785)
!846 = !DILocation(line: 647, column: 35, scope: !785)
!847 = !DILocation(line: 647, column: 46, scope: !785)
!848 = !DILocation(line: 647, column: 50, scope: !785)
!849 = !DILocation(line: 647, column: 54, scope: !785)
!850 = !DILocation(line: 647, column: 57, scope: !785)
!851 = !DILocation(line: 647, column: 60, scope: !785)
!852 = !DILocation(line: 647, column: 63, scope: !785)
!853 = !DILocation(line: 647, column: 13, scope: !785)
!854 = !DILocation(line: 661, column: 9, scope: !785)
!855 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit", scope: null, file: !592, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!856 = !DILocation(line: 43, column: 3, scope: !857)
!857 = !DILexicalBlockFile(scope: !855, file: !592, discriminator: 0)
!858 = !DILocation(line: 41, column: 3, scope: !857)
!859 = !DILocation(line: 40, column: 3, scope: !857)
!860 = !DILocation(line: 39, column: 9, scope: !857)
!861 = !DILocation(line: 40, column: 23, scope: !857)
!862 = !DILocation(line: 41, column: 70, scope: !857)
!863 = !DILocation(line: 41, column: 68, scope: !857)
!864 = !DILocation(line: 43, column: 27, scope: !857)
!865 = !DILocation(line: 43, column: 15, scope: !857)
!866 = !DILocation(line: 44, column: 15, scope: !857)
!867 = !DILocation(line: 44, column: 21, scope: !857)
!868 = !DILocation(line: 44, column: 27, scope: !857)
!869 = !DILocation(line: 44, column: 3, scope: !857)
!870 = !DILocation(line: 39, column: 1, scope: !857)
!871 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord", scope: null, file: !609, line: 4, type: !5, scopeLine: 4, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!872 = !DILocation(line: 5, column: 10, scope: !873)
!873 = !DILexicalBlockFile(scope: !871, file: !609, discriminator: 0)
!874 = !DILocation(line: 5, column: 67, scope: !873)
!875 = !DILocation(line: 5, column: 3, scope: !873)
!876 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord", scope: null, file: !609, line: 8, type: !5, scopeLine: 8, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!877 = !DILocation(line: 9, column: 10, scope: !878)
!878 = !DILexicalBlockFile(scope: !876, file: !609, discriminator: 0)
!879 = !DILocation(line: 9, column: 67, scope: !878)
!880 = !DILocation(line: 9, column: 3, scope: !878)
!881 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord", scope: null, file: !620, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!882 = !DILocation(line: 50, column: 3, scope: !883)
!883 = !DILexicalBlockFile(scope: !881, file: !620, discriminator: 0)
!884 = !DILocation(line: 43, column: 21, scope: !883)
!885 = !DILocation(line: 50, column: 57, scope: !883)
!886 = !DILocation(line: 50, column: 68, scope: !883)
!887 = !DILocation(line: 50, column: 41, scope: !883)
!888 = !DILocation(line: 50, column: 19, scope: !883)
!889 = !DILocation(line: 52, column: 10, scope: !883)
!890 = !DILocation(line: 52, column: 18, scope: !883)
!891 = !DILocation(line: 48, column: 22, scope: !883)
!892 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr", linkageName: "sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr", scope: null, file: !893, line: 11, type: !5, scopeLine: 11, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!893 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/input_queue_config.csl", directory: "")
!894 = !DILocation(line: 11, column: 32, scope: !895)
!895 = !DILexicalBlockFile(scope: !892, file: !893, discriminator: 0)
!896 = !DILocation(line: 12, column: 80, scope: !895)
!897 = !DILocation(line: 12, column: 69, scope: !895)
!898 = !DILocation(line: 12, column: 39, scope: !895)
!899 = !DILocation(line: 12, column: 3, scope: !895)
!900 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue", linkageName: "sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue", scope: null, file: !893, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!901 = !DILocation(line: 46, column: 3, scope: !902)
!902 = !DILexicalBlockFile(scope: !900, file: !893, discriminator: 0)
!903 = !DILocation(line: 45, column: 3, scope: !902)
!904 = !DILocation(line: 39, column: 42, scope: !902)
!905 = !DILocation(line: 39, column: 34, scope: !902)
!906 = !DILocation(line: 39, column: 24, scope: !902)
!907 = !DILocation(line: 45, column: 44, scope: !902)
!908 = !DILocation(line: 45, column: 16, scope: !902)
!909 = !DILocation(line: 46, column: 30, scope: !902)
!910 = !DILocation(line: 46, column: 18, scope: !902)
!911 = !DILocation(line: 56, column: 9, scope: !902)
!912 = !DILocation(line: 56, column: 5, scope: !902)
!913 = !DILocation(line: 58, column: 13, scope: !902)
!914 = !DILocation(line: 58, column: 17, scope: !902)
!915 = !DILocation(line: 58, column: 11, scope: !902)
!916 = !DILocation(line: 61, column: 13, scope: !902)
!917 = !DILocation(line: 61, column: 17, scope: !902)
!918 = !DILocation(line: 61, column: 11, scope: !902)
!919 = !DILocation(line: 66, column: 9, scope: !902)
!920 = !DILocation(line: 66, column: 13, scope: !902)
!921 = !DILocation(line: 66, column: 7, scope: !902)
!922 = !DILocation(line: 68, column: 9, scope: !902)
!923 = !DILocation(line: 68, column: 24, scope: !902)
!924 = !DILocation(line: 68, column: 13, scope: !902)
!925 = !DILocation(line: 68, column: 7, scope: !902)
!926 = !DILocation(line: 70, column: 15, scope: !902)
!927 = !DILocation(line: 70, column: 21, scope: !902)
!928 = !DILocation(line: 70, column: 3, scope: !902)
!929 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr", linkageName: "sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr", scope: null, file: !930, line: 11, type: !5, scopeLine: 11, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!930 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/output_queue_config.csl", directory: "")
!931 = !DILocation(line: 11, column: 33, scope: !932)
!932 = !DILexicalBlockFile(scope: !929, file: !930, discriminator: 0)
!933 = !DILocation(line: 12, column: 82, scope: !932)
!934 = !DILocation(line: 12, column: 40, scope: !932)
!935 = !DILocation(line: 12, column: 3, scope: !932)
!936 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue", linkageName: "sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue", scope: null, file: !930, line: 31, type: !5, scopeLine: 31, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!937 = !DILocation(line: 38, column: 3, scope: !938)
!938 = !DILexicalBlockFile(scope: !936, file: !930, discriminator: 0)
!939 = !DILocation(line: 37, column: 3, scope: !938)
!940 = !DILocation(line: 31, column: 35, scope: !938)
!941 = !DILocation(line: 31, column: 25, scope: !938)
!942 = !DILocation(line: 37, column: 45, scope: !938)
!943 = !DILocation(line: 37, column: 16, scope: !938)
!944 = !DILocation(line: 38, column: 30, scope: !938)
!945 = !DILocation(line: 38, column: 18, scope: !938)
!946 = !DILocation(line: 41, column: 9, scope: !938)
!947 = !DILocation(line: 41, column: 13, scope: !938)
!948 = !DILocation(line: 41, column: 7, scope: !938)
!949 = !DILocation(line: 43, column: 9, scope: !938)
!950 = !DILocation(line: 43, column: 24, scope: !938)
!951 = !DILocation(line: 43, column: 13, scope: !938)
!952 = !DILocation(line: 43, column: 27, scope: !938)
!953 = !DILocation(line: 43, column: 7, scope: !938)
!954 = !DILocation(line: 45, column: 15, scope: !938)
!955 = !DILocation(line: 45, column: 21, scope: !938)
!956 = !DILocation(line: 45, column: 3, scope: !938)
!957 = !DILocation(line: 31, column: 1, scope: !938)
!958 = distinct !DISubprogram(name: ".get_tensor_ptr", linkageName: ".get_tensor_ptr", scope: null, file: !4, line: 1, type: !5, scopeLine: 1, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!959 = !DILocation(line: 1, column: 1, scope: !960)
!960 = !DILexicalBlockFile(scope: !958, file: !4, discriminator: 0)
!961 = distinct !DISubprogram(name: "__generic0sys_mod.sys_mod.tile_config.queue_flush.exit", linkageName: "__generic0sys_mod.sys_mod.tile_config.queue_flush.exit", scope: null, file: !962, line: 12, type: !5, scopeLine: 12, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!962 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/queue_flush.csl", directory: "")
!963 = !DILocation(line: 24, column: 3, scope: !964)
!964 = !DILexicalBlockFile(scope: !961, file: !962, discriminator: 0)
!965 = !DILocation(line: 12, column: 1, scope: !964)
!966 = distinct !DISubprogram(name: "__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position", linkageName: "__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position", scope: null, file: !967, line: 30, type: !5, scopeLine: 30, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!967 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/switch_config.csl", directory: "")
!968 = !DILocation(line: 34, column: 3, scope: !969)
!969 = !DILexicalBlockFile(scope: !966, file: !967, discriminator: 0)
!970 = !DILocation(line: 32, column: 3, scope: !969)
!971 = !DILocation(line: 30, column: 27, scope: !969)
!972 = !DILocation(line: 33, column: 7, scope: !969)
!973 = !DILocation(line: 34, column: 36, scope: !969)
!974 = !DILocation(line: 34, column: 24, scope: !969)
!975 = !DILocation(line: 35, column: 3, scope: !969)
!976 = !DILocation(line: 35, column: 18, scope: !969)
!977 = !DILocation(line: 36, column: 15, scope: !969)
!978 = !DILocation(line: 36, column: 21, scope: !969)
!979 = !DILocation(line: 36, column: 3, scope: !969)
!980 = !DILocation(line: 30, column: 1, scope: !969)
!981 = distinct !DISubprogram(name: "__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", linkageName: "__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", scope: null, file: !982, line: 96, type: !5, scopeLine: 96, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!982 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/color_config.csl", directory: "")
!983 = !DILocation(line: 99, column: 3, scope: !984)
!984 = !DILexicalBlockFile(scope: !981, file: !982, discriminator: 0)
!985 = !DILocation(line: 98, column: 3, scope: !984)
!986 = !DILocation(line: 96, column: 17, scope: !984)
!987 = !DILocation(line: 98, column: 16, scope: !984)
!988 = !DILocation(line: 99, column: 29, scope: !984)
!989 = !DILocation(line: 99, column: 17, scope: !984)
!990 = !DILocation(line: 100, column: 13, scope: !984)
!991 = !DILocation(line: 100, column: 21, scope: !984)
!992 = !DILocation(line: 100, column: 11, scope: !984)
!993 = !DILocation(line: 104, column: 7, scope: !984)
!994 = !DILocation(line: 104, column: 50, scope: !984)
!995 = !DILocation(line: 104, column: 18, scope: !984)
!996 = !DILocation(line: 104, column: 15, scope: !984)
!997 = !DILocation(line: 121, column: 7, scope: !984)
!998 = !DILocation(line: 121, column: 50, scope: !984)
!999 = !DILocation(line: 121, column: 18, scope: !984)
!1000 = !DILocation(line: 121, column: 15, scope: !984)
!1001 = !DILocation(line: 128, column: 15, scope: !984)
!1002 = !DILocation(line: 128, column: 21, scope: !984)
!1003 = !DILocation(line: 128, column: 3, scope: !984)
!1004 = !DILocation(line: 96, column: 1, scope: !984)
!1005 = distinct !DISubprogram(name: "__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", linkageName: "__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", scope: null, file: !982, line: 96, type: !5, scopeLine: 96, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1006 = !DILocation(line: 99, column: 3, scope: !1007)
!1007 = !DILexicalBlockFile(scope: !1005, file: !982, discriminator: 0)
!1008 = !DILocation(line: 98, column: 3, scope: !1007)
!1009 = !DILocation(line: 96, column: 17, scope: !1007)
!1010 = !DILocation(line: 98, column: 16, scope: !1007)
!1011 = !DILocation(line: 99, column: 29, scope: !1007)
!1012 = !DILocation(line: 99, column: 17, scope: !1007)
!1013 = !DILocation(line: 100, column: 13, scope: !1007)
!1014 = !DILocation(line: 100, column: 21, scope: !1007)
!1015 = !DILocation(line: 100, column: 11, scope: !1007)
!1016 = !DILocation(line: 104, column: 7, scope: !1007)
!1017 = !DILocation(line: 104, column: 50, scope: !1007)
!1018 = !DILocation(line: 104, column: 18, scope: !1007)
!1019 = !DILocation(line: 104, column: 15, scope: !1007)
!1020 = !DILocation(line: 121, column: 7, scope: !1007)
!1021 = !DILocation(line: 121, column: 50, scope: !1007)
!1022 = !DILocation(line: 121, column: 18, scope: !1007)
!1023 = !DILocation(line: 121, column: 15, scope: !1007)
!1024 = !DILocation(line: 128, column: 15, scope: !1007)
!1025 = !DILocation(line: 128, column: 21, scope: !1007)
!1026 = !DILocation(line: 128, column: 3, scope: !1007)
!1027 = !DILocation(line: 96, column: 1, scope: !1007)
!1028 = distinct !DISubprogram(name: "__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", linkageName: "__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", scope: null, file: !982, line: 60, type: !5, scopeLine: 60, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1029 = !DILocation(line: 61, column: 3, scope: !1030)
!1030 = !DILexicalBlockFile(scope: !1028, file: !982, discriminator: 0)
!1031 = !DILocation(line: 60, column: 46, scope: !1030)
!1032 = !DILocation(line: 61, column: 16, scope: !1030)
!1033 = !DILocation(line: 72, column: 5, scope: !1030)
!1034 = !DILocation(line: 72, column: 12, scope: !1030)
!1035 = !DILocation(line: 74, column: 10, scope: !1030)
!1036 = !DILocation(line: 74, column: 3, scope: !1030)
!1037 = distinct !DISubprogram(name: "__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes", linkageName: "__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes", scope: null, file: !982, line: 77, type: !5, scopeLine: 77, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1038 = !DILocation(line: 78, column: 3, scope: !1039)
!1039 = !DILexicalBlockFile(scope: !1037, file: !982, discriminator: 0)
!1040 = !DILocation(line: 77, column: 46, scope: !1039)
!1041 = !DILocation(line: 78, column: 16, scope: !1039)
!1042 = !DILocation(line: 86, column: 5, scope: !1039)
!1043 = !DILocation(line: 86, column: 12, scope: !1039)
!1044 = !DILocation(line: 91, column: 10, scope: !1039)
!1045 = !DILocation(line: 91, column: 3, scope: !1039)
!1046 = distinct !DISubprogram(name: "__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", linkageName: "__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", scope: null, file: !982, line: 60, type: !5, scopeLine: 60, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1047 = !DILocation(line: 61, column: 3, scope: !1048)
!1048 = !DILexicalBlockFile(scope: !1046, file: !982, discriminator: 0)
!1049 = !DILocation(line: 60, column: 46, scope: !1048)
!1050 = !DILocation(line: 61, column: 16, scope: !1048)
!1051 = !DILocation(line: 63, column: 5, scope: !1048)
!1052 = !DILocation(line: 63, column: 12, scope: !1048)
!1053 = !DILocation(line: 74, column: 10, scope: !1048)
!1054 = !DILocation(line: 74, column: 3, scope: !1048)
!1055 = distinct !DISubprogram(name: "__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction", linkageName: "__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction", scope: null, file: !982, line: 52, type: !5, scopeLine: 52, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1056 = !DILocation(line: 55, column: 3, scope: !1057)
!1057 = !DILexicalBlockFile(scope: !1055, file: !982, discriminator: 0)
!1058 = !DILocation(line: 54, column: 3, scope: !1057)
!1059 = !DILocation(line: 52, column: 23, scope: !1057)
!1060 = !DILocation(line: 54, column: 16, scope: !1057)
!1061 = !DILocation(line: 55, column: 29, scope: !1057)
!1062 = !DILocation(line: 55, column: 17, scope: !1057)
!1063 = !DILocation(line: 56, column: 3, scope: !1057)
!1064 = !DILocation(line: 56, column: 11, scope: !1057)
!1065 = !DILocation(line: 57, column: 15, scope: !1057)
!1066 = !DILocation(line: 57, column: 21, scope: !1057)
!1067 = !DILocation(line: 57, column: 3, scope: !1057)
!1068 = !DILocation(line: 52, column: 1, scope: !1057)
!1069 = distinct !DISubprogram(name: "__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction", linkageName: "__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction", scope: null, file: !982, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1070 = !DILocation(line: 23, column: 3, scope: !1071)
!1071 = !DILexicalBlockFile(scope: !1069, file: !982, discriminator: 0)
!1072 = !DILocation(line: 22, column: 3, scope: !1071)
!1073 = !DILocation(line: 20, column: 21, scope: !1071)
!1074 = !DILocation(line: 22, column: 16, scope: !1071)
!1075 = !DILocation(line: 23, column: 29, scope: !1071)
!1076 = !DILocation(line: 23, column: 17, scope: !1071)
!1077 = !DILocation(line: 24, column: 3, scope: !1071)
!1078 = !DILocation(line: 24, column: 11, scope: !1071)
!1079 = !DILocation(line: 25, column: 15, scope: !1071)
!1080 = !DILocation(line: 25, column: 21, scope: !1071)
!1081 = !DILocation(line: 25, column: 3, scope: !1071)
!1082 = !DILocation(line: 20, column: 1, scope: !1071)
module asm ".section \22.pe_debug_info\22, \22\22"
module asm ".section \22.note\22, \22\22"
