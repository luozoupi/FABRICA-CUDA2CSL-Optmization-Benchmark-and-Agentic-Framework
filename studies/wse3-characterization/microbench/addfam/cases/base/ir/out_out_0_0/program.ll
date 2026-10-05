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
  %1 = load i16, i16* getelementptr inbounds ([64 x i16], [64 x i16]* @a, i16 0, i1 false), align 2, !dbg !7
  %2 = load i16, i16* getelementptr inbounds ([64 x i16], [64 x i16]* @b, i16 0, i1 false), align 2, !dbg !9
  %3 = add i16 %1, %2, !dbg !10
  store i16 %3, i16* getelementptr inbounds ([64 x i16], [64 x i16]* @c, i16 0, i1 false), align 2, !dbg !11
  call void @llvm.sdr.actvt.r(i16 9), !dbg !12
  ret void, !dbg !13
}

define void @f_exit() #0 !dbg !14 {
  call void @sys_mod.unblock_cmd_stream(), !dbg !15
  ret void, !dbg !17
}

define internal void @sys_mod.sys_nop() !dbg !18 {
  ret void, !dbg !20
}

define internal void @sys_mod.unblock_cmd_stream() !dbg !22 {
  call void @sys_mod.sys_mod.unblock_cmd_stream(), !dbg !23
  ret void, !dbg !25
}

define internal void @sys_mod.sys_mod.unblock_cmd_stream() !dbg !26 {
  call void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream(), !dbg !28
  ret void, !dbg !30
}

define internal void @sys_mod.sys_mod.teardown_h2d() !dbg !31 {
  call void @llvm.sdr.actvt.r(i16 27), !dbg !32
  ret void, !dbg !34
}

define void @sys_mod.sys_mod.f_ublk_c22() #1 !dbg !35 {
  call void @sys_mod.sys_mod.unblock_cmd_stream(), !dbg !36
  ret void, !dbg !38
}

define internal void @sys_mod.sys_mod.teardown_d2h() !dbg !39 {
  call void @llvm.sdr.blk.r(i16 0), !dbg !40
  call void @llvm.sdr.actvt.r(i16 28), !dbg !42
  ret void, !dbg !43
}

define void @sys_mod.sys_mod.f_memcpyh2d() #2 !dbg !44 {
  %1 = alloca float, i16 1, align 4, !dbg !45
  %2 = alloca float, i16 1, align 4, !dbg !47
  %3 = alloca i16, i16 1, align 2, !dbg !48
  %4 = alloca i16, i16 1, align 2, !dbg !49
  %5 = alloca i16, i16 1, align 2, !dbg !50
  %6 = alloca i16, i16 1, align 2, !dbg !51
  %7 = alloca i16, i16 1, align 2, !dbg !52
  %8 = alloca i16, i16 1, align 2, !dbg !53
  %9 = alloca i16, i16 1, align 2, !dbg !54
  %10 = alloca i16, i16 1, align 2, !dbg !55
  %11 = alloca i16, i16 1, align 2, !dbg !56
  %12 = alloca i16, i16 1, align 2, !dbg !57
  %13 = alloca i16, i16 1, align 2, !dbg !58
  %14 = alloca i16*, i16 1, align 8, !dbg !59
  %15 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !60
  %16 = icmp eq i16 %15, 15, !dbg !61
  br i1 %16, label %17, label %18, !dbg !62

17:                                               ; preds = %0
  br label %19, !dbg !62

18:                                               ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !62
  br label %19, !dbg !62

19:                                               ; preds = %17, %18
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %14, align 8, !dbg !59
  %20 = load i16*, i16** %14, align 8, !dbg !63
  %21 = load i16, i16* %20, align 2, !dbg !64
  store i16 %21, i16* %13, align 2, !dbg !58
  %22 = load i16*, i16** %14, align 8, !dbg !65
  %23 = getelementptr i16, i16* %22, i16 1, !dbg !66
  %24 = load i16, i16* %23, align 2, !dbg !66
  store i16 %24, i16* %12, align 2, !dbg !57
  %25 = load i16*, i16** %14, align 8, !dbg !67
  %26 = getelementptr i16, i16* %25, i16 2, !dbg !68
  %27 = load i16, i16* %26, align 2, !dbg !68
  store i16 %27, i16* %11, align 2, !dbg !56
  %28 = load i16*, i16** %14, align 8, !dbg !69
  %29 = getelementptr i16, i16* %28, i16 3, !dbg !70
  %30 = load i16, i16* %29, align 2, !dbg !70
  store i16 %30, i16* %10, align 2, !dbg !55
  %31 = load i16*, i16** %14, align 8, !dbg !71
  %32 = getelementptr i16, i16* %31, i16 4, !dbg !72
  %33 = load i16, i16* %32, align 2, !dbg !72
  store i16 %33, i16* %9, align 2, !dbg !54
  %34 = load i16*, i16** %14, align 8, !dbg !73
  %35 = getelementptr i16, i16* %34, i16 5, !dbg !74
  %36 = load i16, i16* %35, align 2, !dbg !74
  store i16 %36, i16* %8, align 2, !dbg !53
  %37 = load i16*, i16** %14, align 8, !dbg !75
  %38 = getelementptr i16, i16* %37, i16 6, !dbg !76
  %39 = load i16, i16* %38, align 2, !dbg !76
  store i16 %39, i16* %7, align 2, !dbg !52
  %40 = load i16*, i16** %14, align 8, !dbg !77
  %41 = getelementptr i16, i16* %40, i16 7, !dbg !78
  %42 = load i16, i16* %41, align 2, !dbg !78
  store i16 %42, i16* %6, align 2, !dbg !51
  %43 = load i16*, i16** %14, align 8, !dbg !79
  %44 = getelementptr i16, i16* %43, i16 8, !dbg !80
  %45 = load i16, i16* %44, align 2, !dbg !80
  store i16 %45, i16* %5, align 2, !dbg !50
  %46 = load i16*, i16** %14, align 8, !dbg !81
  %47 = getelementptr i16, i16* %46, i16 9, !dbg !82
  %48 = load i16, i16* %47, align 2, !dbg !82
  store i16 %48, i16* %4, align 2, !dbg !49
  %49 = load i16*, i16** %14, align 8, !dbg !83
  %50 = getelementptr i16, i16* %49, i16 10, !dbg !84
  %51 = load i16, i16* %50, align 2, !dbg !84
  store i16 %51, i16* %3, align 2, !dbg !48
  %52 = load i16*, i16** %14, align 8, !dbg !85
  %53 = getelementptr i16, i16* %52, i16 12, !dbg !86
  %54 = load i16, i16* %53, align 2, !dbg !86
  %55 = zext i16 %54 to i32, !dbg !87
  %56 = load i16*, i16** %14, align 8, !dbg !88
  %57 = getelementptr i16, i16* %56, i16 11, !dbg !89
  %58 = load i16, i16* %57, align 2, !dbg !89
  %59 = zext i16 %58 to i32, !dbg !90
  %60 = add i32 %59, 16, !dbg !91
  %61 = shl i32 %55, %60, !dbg !92
  %62 = bitcast i32 %61 to float, !dbg !93
  store float %62, float* %2, align 4, !dbg !47
  %63 = load i16*, i16** %14, align 8, !dbg !94
  %64 = getelementptr i16, i16* %63, i16 14, !dbg !95
  %65 = load i16, i16* %64, align 2, !dbg !95
  %66 = zext i16 %65 to i32, !dbg !96
  %67 = load i16*, i16** %14, align 8, !dbg !97
  %68 = getelementptr i16, i16* %67, i16 13, !dbg !98
  %69 = load i16, i16* %68, align 2, !dbg !98
  %70 = zext i16 %69 to i32, !dbg !99
  %71 = add i32 %70, 16, !dbg !100
  %72 = shl i32 %66, %71, !dbg !101
  %73 = bitcast i32 %72 to float, !dbg !102
  store float %73, float* %1, align 4, !dbg !45
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !103
  %74 = load i16, i16* %13, align 2, !dbg !104
  store i16 %74, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !105
  %75 = load i16, i16* %12, align 2, !dbg !106
  store i16 %75, i16* @sys_mod.sys_mod.memcpyH2D_px, align 2, !dbg !107
  %76 = load i16, i16* %11, align 2, !dbg !108
  store i16 %76, i16* @sys_mod.sys_mod.memcpyH2D_py, align 2, !dbg !109
  %77 = load i16, i16* %10, align 2, !dbg !110
  store i16 %77, i16* @sys_mod.sys_mod.memcpyH2D_w, align 2, !dbg !111
  %78 = load i16, i16* %9, align 2, !dbg !112
  store i16 %78, i16* @sys_mod.sys_mod.memcpyH2D_h, align 2, !dbg !113
  %79 = load i16, i16* %8, align 2, !dbg !114
  store i16 %79, i16* @sys_mod.sys_mod.memcpyH2D_addr, align 2, !dbg !115
  %80 = load i16, i16* %7, align 2, !dbg !116
  store i16 %80, i16* @sys_mod.sys_mod.memcpyH2D_pe_length, align 2, !dbg !117
  %81 = load i16, i16* %6, align 2, !dbg !118
  store i16 %81, i16* @sys_mod.sys_mod.memcpyH2D_is_half, align 2, !dbg !119
  %82 = load i16, i16* %5, align 2, !dbg !120
  store i16 %82, i16* @sys_mod.sys_mod.memcpyH2D_memcpy_optype, align 2, !dbg !121
  %83 = load i16, i16* %4, align 2, !dbg !122
  store i16 %83, i16* @sys_mod.sys_mod.memcpyH2D_row_stride, align 2, !dbg !123
  %84 = load i16, i16* %3, align 2, !dbg !124
  store i16 %84, i16* @sys_mod.sys_mod.memcpyH2D_col_stride, align 2, !dbg !125
  %85 = load float, float* %2, align 4, !dbg !126
  store float %85, float* @sys_mod.sys_mod.memcpyH2D_one_over_row_stride, align 4, !dbg !127
  %86 = load float, float* %1, align 4, !dbg !128
  store float %86, float* @sys_mod.sys_mod.memcpyH2D_one_over_col_stride, align 4, !dbg !129
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !130
  call void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 0, i16 23, i1 true), !dbg !131
  call void @llvm.sdr.blk.r(i16 27), !dbg !132
  call void @llvm.sdr.oqflush(i16 0), !dbg !133
  store i1 true, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !134
  call void @llvm.sdr.blk.r(i16 0), !dbg !135
  ret void, !dbg !136
}

define void @sys_mod.sys_mod.f_memcpyd2h() #3 !dbg !137 {
  %1 = alloca i16, i16 1, align 2, !dbg !138
  %2 = alloca i16, i16 1, align 2, !dbg !140
  %3 = alloca i16, i16 1, align 2, !dbg !141
  %4 = alloca i16, i16 1, align 2, !dbg !142
  %5 = alloca i16, i16 1, align 2, !dbg !143
  %6 = alloca i16, i16 1, align 2, !dbg !144
  %7 = alloca i16, i16 1, align 2, !dbg !145
  %8 = alloca i16, i16 1, align 2, !dbg !146
  %9 = alloca i16*, i16 1, align 8, !dbg !147
  %10 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !148
  %11 = icmp eq i16 %10, 8, !dbg !149
  br i1 %11, label %12, label %13, !dbg !150

12:                                               ; preds = %0
  br label %14, !dbg !150

13:                                               ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !150
  br label %14, !dbg !150

14:                                               ; preds = %12, %13
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %9, align 8, !dbg !147
  %15 = load i16*, i16** %9, align 8, !dbg !151
  %16 = load i16, i16* %15, align 2, !dbg !152
  store i16 %16, i16* %8, align 2, !dbg !146
  %17 = load i16*, i16** %9, align 8, !dbg !153
  %18 = getelementptr i16, i16* %17, i16 1, !dbg !154
  %19 = load i16, i16* %18, align 2, !dbg !154
  store i16 %19, i16* %7, align 2, !dbg !145
  %20 = load i16*, i16** %9, align 8, !dbg !155
  %21 = getelementptr i16, i16* %20, i16 2, !dbg !156
  %22 = load i16, i16* %21, align 2, !dbg !156
  store i16 %22, i16* %6, align 2, !dbg !144
  %23 = load i16*, i16** %9, align 8, !dbg !157
  %24 = getelementptr i16, i16* %23, i16 3, !dbg !158
  %25 = load i16, i16* %24, align 2, !dbg !158
  store i16 %25, i16* %5, align 2, !dbg !143
  %26 = load i16*, i16** %9, align 8, !dbg !159
  %27 = getelementptr i16, i16* %26, i16 4, !dbg !160
  %28 = load i16, i16* %27, align 2, !dbg !160
  store i16 %28, i16* %4, align 2, !dbg !142
  %29 = load i16*, i16** %9, align 8, !dbg !161
  %30 = getelementptr i16, i16* %29, i16 5, !dbg !162
  %31 = load i16, i16* %30, align 2, !dbg !162
  store i16 %31, i16* %3, align 2, !dbg !141
  %32 = load i16*, i16** %9, align 8, !dbg !163
  %33 = getelementptr i16, i16* %32, i16 6, !dbg !164
  %34 = load i16, i16* %33, align 2, !dbg !164
  store i16 %34, i16* %2, align 2, !dbg !140
  %35 = load i16*, i16** %9, align 8, !dbg !165
  %36 = getelementptr i16, i16* %35, i16 7, !dbg !166
  %37 = load i16, i16* %36, align 2, !dbg !166
  store i16 %37, i16* %1, align 2, !dbg !138
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !167
  %38 = load i16, i16* %8, align 2, !dbg !168
  store i16 %38, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !169
  %39 = load i16, i16* %7, align 2, !dbg !170
  store i16 %39, i16* @sys_mod.sys_mod.memcpyD2H_px, align 2, !dbg !171
  %40 = load i16, i16* %6, align 2, !dbg !172
  store i16 %40, i16* @sys_mod.sys_mod.memcpyD2H_py, align 2, !dbg !173
  %41 = load i16, i16* %5, align 2, !dbg !174
  store i16 %41, i16* @sys_mod.sys_mod.memcpyD2H_w, align 2, !dbg !175
  %42 = load i16, i16* %4, align 2, !dbg !176
  store i16 %42, i16* @sys_mod.sys_mod.memcpyD2H_h, align 2, !dbg !177
  %43 = load i16, i16* %3, align 2, !dbg !178
  store i16 %43, i16* @sys_mod.sys_mod.memcpyD2H_addr, align 2, !dbg !179
  %44 = load i16, i16* %2, align 2, !dbg !180
  store i16 %44, i16* @sys_mod.sys_mod.memcpyD2H_pe_length, align 2, !dbg !181
  %45 = load i16, i16* %1, align 2, !dbg !182
  store i16 %45, i16* @sys_mod.sys_mod.memcpyD2H_is_half, align 2, !dbg !183
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !184
  %46 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !185
  call void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 0, i16 %46, i1 false), !dbg !186
  call void @llvm.sdr.oqflush(i16 0), !dbg !187
  store i1 false, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !188
  ret void, !dbg !189
}

define internal void @sys_mod.sys_mod.oq0_teardow_handler() !dbg !190 {
  %1 = load i1, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !191
  br i1 %1, label %2, label %17, !dbg !193

2:                                                ; preds = %0
  %3 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !194
  call void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 0, i16 %3), !dbg !195
  %4 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !196
  %5 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_px, align 2, !dbg !197
  %6 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_py, align 2, !dbg !198
  %7 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_w, align 2, !dbg !199
  %8 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_h, align 2, !dbg !200
  %9 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_addr, align 2, !dbg !201
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_pe_length, align 2, !dbg !202
  %11 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_is_half, align 2, !dbg !203
  %12 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_memcpy_optype, align 2, !dbg !204
  %13 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_row_stride, align 2, !dbg !205
  %14 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_col_stride, align 2, !dbg !206
  %15 = load float, float* @sys_mod.sys_mod.memcpyH2D_one_over_row_stride, align 4, !dbg !207
  %16 = load float, float* @sys_mod.sys_mod.memcpyH2D_one_over_col_stride, align 4, !dbg !208
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure(i16 %4, i16 %5, i16 %6, i16 %7, i16 %8, i16 %9, i16 %10, i16 %11, i16 %12, i16 %13, i16 %14, float %15, float %16), !dbg !209
  br label %26, !dbg !193

17:                                               ; preds = %0
  call void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 0, i16 21), !dbg !210
  %18 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !211
  %19 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_px, align 2, !dbg !212
  %20 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_py, align 2, !dbg !213
  %21 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_w, align 2, !dbg !214
  %22 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_h, align 2, !dbg !215
  %23 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_addr, align 2, !dbg !216
  %24 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_pe_length, align 2, !dbg !217
  %25 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_is_half, align 2, !dbg !218
  call void @sys_mod.sys_mod.memcpyd2h_mod.d2h_configure(i16 %18, i16 %19, i16 %20, i16 %21, i16 %22, i16 %23, i16 %24, i16 %25), !dbg !219
  br label %26, !dbg !193

26:                                               ; preds = %2, %17
  call void @__generic0sys_mod.sys_mod.tile_config.queue_flush.exit(), !dbg !220
  ret void, !dbg !193
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

define void @sys_mod.sys_mod.f_rpc(i16 %0) #4 !dbg !221 {
  %2 = alloca i16, i16 1, align 2, !dbg !222
  store i16 %0, i16* %2, align 2, !dbg !222
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !224
  %3 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !225
  %4 = icmp sge i16 %3, 4, !dbg !226
  br i1 %4, label %5, label %6, !dbg !227

5:                                                ; preds = %1
  br label %7, !dbg !227

6:                                                ; preds = %1
  call void asm sideeffect "hcf", ""(), !dbg !227
  br label %7, !dbg !227

7:                                                ; preds = %5, %6
  call void @rpc_server(i32* getelementptr inbounds ([32 x i32], [32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32, i32 0, i32 0)), !dbg !228
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !229
  ret void, !dbg !230
}

define internal void @sys_mod.sys_mod.sys_mod.stack_push(i16 %0) !dbg !231 {
  %2 = alloca i16*, i16 1, align 8, !dbg !233
  %3 = alloca i16, i16 1, align 2, !dbg !235
  store i16 %0, i16* %3, align 2, !dbg !235
  %4 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !236
  %5 = icmp slt i16 %4, 32, !dbg !237
  br i1 %5, label %6, label %7, !dbg !238

6:                                                ; preds = %1
  br label %8, !dbg !238

7:                                                ; preds = %1
  call void asm sideeffect "hcf", ""(), !dbg !238
  br label %8, !dbg !238

8:                                                ; preds = %6, %7
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %2, align 8, !dbg !233
  %9 = load i16, i16* %3, align 2, !dbg !239
  %10 = load i16*, i16** %2, align 8, !dbg !240
  %11 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !241
  %12 = getelementptr i16, i16* %10, i16 %11, !dbg !242
  store i16 %9, i16* %12, align 2, !dbg !243
  %13 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !244
  %14 = add i16 %13, 1, !dbg !245
  store i16 %14, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !246
  ret void, !dbg !247
}

define void @sys_mod.sys_mod.sys_mod.f_push(i16 %0, i16 %1) #5 !dbg !248 {
  %3 = alloca i16, i16 1, align 2, !dbg !249
  %4 = alloca i16, i16 1, align 2, !dbg !251
  store i16 %0, i16* %4, align 2, !dbg !251
  store i16 %1, i16* %3, align 2, !dbg !249
  %5 = load i16, i16* %4, align 2, !dbg !252
  call void @sys_mod.sys_mod.sys_mod.stack_push(i16 %5), !dbg !253
  ret void, !dbg !254
}

define internal void @sys_mod.sys_mod.sys_mod.block_cmd_stream() !dbg !255 {
  call void @llvm.sdr.blk.r(i16 1), !dbg !256
  ret void, !dbg !258
}

define internal void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream() !dbg !259 {
  call void @llvm.sdr.ublk.r(i16 1), !dbg !260
  ret void, !dbg !262
}

define void @sys_mod.sys_mod.sys_mod.f_sys_exit() #6 !dbg !263 {
  call void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream(), !dbg !264
  call void @sys_mod.sys_nop(), !dbg !266
  ret void, !dbg !267
}

define void @sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore(i32 %0) #7 !dbg !268 {
  %2 = alloca i32, i16 1, align 4, !dbg !269
  store i32 %0, i32* %2, align 4, !dbg !269
  ret void, !dbg !271
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord() !dbg !272 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord(), !dbg !274
  ret i16 %1, !dbg !276
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord() !dbg !277 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord(), !dbg !278
  ret i16 %1, !dbg !280
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval(i16 %0) !dbg !281 {
  %2 = alloca i16, i16 1, align 2, !dbg !282
  store i16 %0, i16* %2, align 2, !dbg !282
  %3 = load i16, i16* %2, align 2, !dbg !284
  %4 = icmp ult i16 %3, 24, !dbg !285
  br i1 %4, label %5, label %7, !dbg !286

5:                                                ; preds = %10, %11, %1
  %6 = phi i16 [ 0, %10 ], [ 0, %11 ], [ 1, %1 ]
  br label %12, !dbg !286

7:                                                ; preds = %1
  %8 = load i16, i16* %2, align 2, !dbg !287
  %9 = icmp eq i16 31, %8, !dbg !288
  br i1 %9, label %10, label %11, !dbg !289

10:                                               ; preds = %7
  br label %5, !dbg !289

11:                                               ; preds = %7
  call void asm sideeffect "hcf", ""(), !dbg !289
  br label %5, !dbg !289

12:                                               ; preds = %5
  %13 = phi i16 [ %6, %5 ]
  br label %14, !dbg !286

14:                                               ; preds = %12
  ret i16 %13, !dbg !286
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start(i16 %0, i16 %1, i16 %2) !dbg !290 {
  %4 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !291
  %5 = alloca i16, i16 1, align 2, !dbg !293
  %6 = alloca i16, i16 1, align 2, !dbg !294
  %7 = alloca i16, i16 1, align 2, !dbg !295
  store i16 %0, i16* %7, align 2, !dbg !295
  store i16 %1, i16* %6, align 2, !dbg !294
  store i16 %2, i16* %5, align 2, !dbg !293
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !296
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !296
  %10 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !296
  %11 = load i16, i16* %6, align 2, !dbg !297
  store i16 %11, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !298
  store i16 %8, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !298
  store i16 %9, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !298
  store i16 %10, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !298
  %12 = load i16, i16* %7, align 2, !dbg !299
  %13 = call i16* @.get_tensor_ptr(i16 %12), !dbg !300
  %14 = ptrtoint i16* %13 to i16, !dbg !301
  %15 = lshr i16 %14, 1, !dbg !301
  %16 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !291
  store i16 42, i16* %16, align 2, !dbg !291
  %17 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !291
  store i16 %15, i16* %17, align 2, !dbg !291
  %18 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !291
  store i16 143, i16* %18, align 2, !dbg !291
  %19 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !291
  store i16 16, i16* %19, align 2, !dbg !291
  %20 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !302
  %21 = load i16, i16* %20, align 2, !dbg !302
  %22 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !302
  %23 = load i16, i16* %22, align 2, !dbg !302
  %24 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !302
  %25 = load i16, i16* %24, align 2, !dbg !302
  %26 = load i16, i16* %6, align 2, !dbg !303
  %27 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !304
  store i16 %26, i16* %27, align 2, !dbg !304
  %28 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !304
  store i16 %21, i16* %28, align 2, !dbg !304
  %29 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !304
  store i16 %23, i16* %29, align 2, !dbg !304
  %30 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !304
  store i16 %25, i16* %30, align 2, !dbg !304
  %31 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !305
  %32 = load i16, i16* %31, align 2, !dbg !305
  %33 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !305
  %34 = load i16, i16* %33, align 2, !dbg !305
  %35 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !305
  %36 = load i16, i16* %35, align 2, !dbg !305
  %37 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !305
  %38 = load i16, i16* %37, align 2, !dbg !305
  store volatile i16 %32, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !306
  store volatile i16 %34, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !306
  store volatile i16 %36, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !306
  store volatile i16 %38, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !306
  call void asm sideeffect "nop", ""(), !dbg !306
  call void asm sideeffect "nop", ""(), !dbg !306
  %39 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !307
  %40 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !307
  %41 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !307
  %42 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !307
  %43 = and i16 %41, -193, !dbg !307
  %44 = or i16 %43, 128, !dbg !307
  %45 = and i16 %40, -64, !dbg !307
  %46 = or i16 %45, 27, !dbg !307
  store volatile i16 %39, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !308
  store volatile i16 %46, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !308
  store volatile i16 %44, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !308
  store volatile i16 %42, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !308
  call void asm sideeffect "nop", ""(), !dbg !308
  call void asm sideeffect "nop", ""(), !dbg !308
  %47 = load i16, i16* %5, align 2, !dbg !309
  %48 = icmp ult i16 0, %47, !dbg !310
  br i1 %48, label %49, label %50, !dbg !311

49:                                               ; preds = %3
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !312
  br label %51, !dbg !311

50:                                               ; preds = %3
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !313
  br label %51, !dbg !311

51:                                               ; preds = %49, %50
  ret void, !dbg !311
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream() !dbg !314 {
  call void @llvm.sdr.ublk.r(i16 1), !dbg !315
  ret void, !dbg !317
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7, i16 %8, i16 %9, i16 %10, float %11, float %12) !dbg !318 {
  %14 = alloca i16, i16 1, align 2, !dbg !319
  %15 = alloca i16, i16 1, align 2, !dbg !321
  %16 = alloca i16, i16 1, align 2, !dbg !322
  %17 = alloca i16, i16 1, align 2, !dbg !323
  %18 = alloca i16, i16 1, align 2, !dbg !324
  %19 = alloca i1, i16 1, align 1, !dbg !325
  %20 = alloca i16, i16 1, align 2, !dbg !326
  %21 = alloca i16, i16 1, align 2, !dbg !327
  %22 = alloca i16, i16 1, align 2, !dbg !328
  %23 = alloca i16, i16 1, align 2, !dbg !329
  %24 = alloca i16, i16 1, align 2, !dbg !330
  %25 = alloca float, i16 1, align 4, !dbg !331
  %26 = alloca float, i16 1, align 4, !dbg !332
  %27 = alloca i16, i16 1, align 2, !dbg !333
  %28 = alloca i16, i16 1, align 2, !dbg !334
  %29 = alloca i16, i16 1, align 2, !dbg !335
  %30 = alloca i16, i16 1, align 2, !dbg !336
  %31 = alloca i16, i16 1, align 2, !dbg !337
  %32 = alloca i16, i16 1, align 2, !dbg !338
  %33 = alloca i16, i16 1, align 2, !dbg !339
  %34 = alloca i16, i16 1, align 2, !dbg !340
  %35 = alloca i16, i16 1, align 2, !dbg !341
  %36 = alloca i16, i16 1, align 2, !dbg !342
  %37 = alloca i16, i16 1, align 2, !dbg !343
  store i16 %0, i16* %37, align 2, !dbg !343
  store i16 %1, i16* %36, align 2, !dbg !342
  store i16 %2, i16* %35, align 2, !dbg !341
  store i16 %3, i16* %34, align 2, !dbg !340
  store i16 %4, i16* %33, align 2, !dbg !339
  store i16 %5, i16* %32, align 2, !dbg !338
  store i16 %6, i16* %31, align 2, !dbg !337
  store i16 %7, i16* %30, align 2, !dbg !336
  store i16 %8, i16* %29, align 2, !dbg !335
  store i16 %9, i16* %28, align 2, !dbg !334
  store i16 %10, i16* %27, align 2, !dbg !333
  store float %11, float* %26, align 4, !dbg !332
  store float %12, float* %25, align 4, !dbg !331
  %38 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord(), !dbg !344
  store i16 %38, i16* %24, align 2, !dbg !330
  %39 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord(), !dbg !345
  store i16 %39, i16* %23, align 2, !dbg !329
  %40 = load i16, i16* %24, align 2, !dbg !346
  %41 = load i16, i16* %36, align 2, !dbg !347
  %42 = sub i16 %40, %41, !dbg !348
  store i16 %42, i16* %22, align 2, !dbg !328
  %43 = load i16, i16* %22, align 2, !dbg !349
  store i16 %43, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !350
  %44 = load i16, i16* %29, align 2, !dbg !351
  %45 = icmp eq i16 3, %44, !dbg !352
  br i1 %45, label %46, label %63, !dbg !353

46:                                               ; preds = %13
  %47 = load i16, i16* %22, align 2, !dbg !354
  %48 = sitofp i16 %47 to float, !dbg !355
  %49 = load float, float* %26, align 4, !dbg !356
  %50 = fmul float %48, %49, !dbg !357
  %51 = fptosi float %50 to i16, !dbg !358
  store i16 %51, i16* %21, align 2, !dbg !327
  %52 = load i16, i16* %22, align 2, !dbg !359
  %53 = load i16, i16* %21, align 2, !dbg !360
  %54 = load i16, i16* %28, align 2, !dbg !361
  %55 = mul i16 %53, %54, !dbg !362
  %56 = sub i16 %52, %55, !dbg !363
  store i16 %56, i16* %20, align 2, !dbg !326
  %57 = load i16, i16* %20, align 2, !dbg !364
  %58 = icmp ne i16 0, %57, !dbg !365
  br i1 %58, label %59, label %60, !dbg !366

59:                                               ; preds = %46
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !367
  br label %62, !dbg !366

60:                                               ; preds = %46
  %61 = load i16, i16* %21, align 2, !dbg !368
  store i16 %61, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !369
  br label %62, !dbg !366

62:                                               ; preds = %59, %60
  br label %63, !dbg !353

63:                                               ; preds = %62, %13
  %64 = load i16, i16* %22, align 2, !dbg !370
  %65 = icmp slt i16 %64, 0, !dbg !371
  br i1 %65, label %66, label %67, !dbg !372

66:                                               ; preds = %63
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !373
  br label %67, !dbg !372

67:                                               ; preds = %66, %63
  %68 = load i16, i16* %22, align 2, !dbg !374
  %69 = load i16, i16* %34, align 2, !dbg !375
  %70 = icmp sge i16 %68, %69, !dbg !376
  br i1 %70, label %71, label %72, !dbg !377

71:                                               ; preds = %67
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !378
  br label %72, !dbg !377

72:                                               ; preds = %71, %67
  store i1 false, i1* %19, align 1, !dbg !325
  %73 = load i16, i16* %29, align 2, !dbg !379
  %74 = icmp eq i16 3, %73, !dbg !380
  br i1 %74, label %75, label %94, !dbg !381

75:                                               ; preds = %72
  %76 = load i16, i16* %23, align 2, !dbg !382
  %77 = load i16, i16* %35, align 2, !dbg !383
  %78 = sub i16 %76, %77, !dbg !384
  %79 = sitofp i16 %78 to float, !dbg !385
  %80 = load float, float* %25, align 4, !dbg !386
  %81 = fmul float %79, %80, !dbg !387
  %82 = fptosi float %81 to i16, !dbg !388
  store i16 %82, i16* %18, align 2, !dbg !324
  %83 = load i16, i16* %23, align 2, !dbg !389
  %84 = load i16, i16* %35, align 2, !dbg !390
  %85 = sub i16 %83, %84, !dbg !391
  %86 = load i16, i16* %18, align 2, !dbg !392
  %87 = load i16, i16* %27, align 2, !dbg !393
  %88 = mul i16 %86, %87, !dbg !394
  %89 = sub i16 %85, %88, !dbg !395
  store i16 %89, i16* %17, align 2, !dbg !323
  %90 = load i16, i16* %17, align 2, !dbg !396
  %91 = icmp ne i16 0, %90, !dbg !397
  br i1 %91, label %92, label %93, !dbg !398

92:                                               ; preds = %75
  store i1 true, i1* %19, align 1, !dbg !399
  br label %93, !dbg !398

93:                                               ; preds = %92, %75
  br label %94, !dbg !381

94:                                               ; preds = %93, %72
  %95 = load i16, i16* %23, align 2, !dbg !400
  %96 = load i16, i16* %35, align 2, !dbg !401
  %97 = icmp slt i16 %95, %96, !dbg !402
  br i1 %97, label %98, label %99, !dbg !403

98:                                               ; preds = %94
  store i1 true, i1* %19, align 1, !dbg !404
  br label %99, !dbg !403

99:                                               ; preds = %98, %94
  %100 = load i16, i16* %23, align 2, !dbg !405
  %101 = load i16, i16* %35, align 2, !dbg !406
  %102 = load i16, i16* %33, align 2, !dbg !407
  %103 = add i16 %101, %102, !dbg !408
  %104 = icmp sge i16 %100, %103, !dbg !409
  br i1 %104, label %105, label %106, !dbg !410

105:                                              ; preds = %99
  store i1 true, i1* %19, align 1, !dbg !411
  br label %106, !dbg !410

106:                                              ; preds = %105, %99
  %107 = load i1, i1* %19, align 1, !dbg !412
  br i1 %107, label %108, label %109, !dbg !413

108:                                              ; preds = %106
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream(), !dbg !414
  call void @llvm.sdr.ublk.r(i16 27), !dbg !415
  br label %180, !dbg !413

109:                                              ; preds = %106
  %110 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !416
  %111 = icmp eq i16 -1, %110, !dbg !417
  br i1 %111, label %112, label %113, !dbg !418

112:                                              ; preds = %109
  call void @__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction(i16 31767), !dbg !419
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 23), !dbg !420
  call void @llvm.sdr.ublk.r(i16 27), !dbg !421
  br label %179, !dbg !418

113:                                              ; preds = %109
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter(i16 0, i16 0), !dbg !422
  %114 = load i16, i16* %34, align 2, !dbg !423
  store i16 %114, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !424
  %115 = load i16, i16* %29, align 2, !dbg !425
  %116 = icmp eq i16 3, %115, !dbg !426
  br i1 %116, label %117, label %126, !dbg !427

117:                                              ; preds = %113
  %118 = load i16, i16* %34, align 2, !dbg !428
  %119 = sub i16 %118, 1, !dbg !429
  %120 = sitofp i16 %119 to float, !dbg !430
  %121 = load float, float* %26, align 4, !dbg !431
  %122 = fmul float %120, %121, !dbg !432
  %123 = fptosi float %122 to i16, !dbg !433
  %124 = add i16 %123, 1, !dbg !434
  store i16 %124, i16* %16, align 2, !dbg !322
  %125 = load i16, i16* %16, align 2, !dbg !435
  store i16 %125, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !436
  br label %131, !dbg !427

126:                                              ; preds = %113
  %127 = load i16, i16* %29, align 2, !dbg !437
  %128 = icmp eq i16 1, %127, !dbg !438
  br i1 %128, label %129, label %130, !dbg !439

129:                                              ; preds = %126
  store i16 1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !440
  br label %130, !dbg !439

130:                                              ; preds = %129, %126
  br label %131, !dbg !427

131:                                              ; preds = %117, %130
  %132 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !441
  %133 = sub i16 %132, 1, !dbg !442
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit(i16 0, i16 %133), !dbg !443
  %134 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !444
  store i16 %134, i16* %15, align 2, !dbg !321
  %135 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !445
  store i16 %135, i16* %14, align 2, !dbg !319
  %136 = load i16, i16* %15, align 2, !dbg !446
  %137 = load i16, i16* %14, align 2, !dbg !447
  %138 = sub i16 %136, %137, !dbg !448
  store i16 %138, i16* %15, align 2, !dbg !449
  %139 = load i16, i16* %14, align 2, !dbg !450
  %140 = icmp eq i16 0, %139, !dbg !451
  br i1 %140, label %141, label %142, !dbg !452

141:                                              ; preds = %131
  store i16 0, i16* %15, align 2, !dbg !453
  br label %142, !dbg !452

142:                                              ; preds = %141, %131
  %143 = load i16, i16* %29, align 2, !dbg !454
  %144 = icmp eq i16 1, %143, !dbg !455
  br i1 %144, label %145, label %146, !dbg !456

145:                                              ; preds = %142
  store i16 0, i16* %15, align 2, !dbg !457
  br label %146, !dbg !456

146:                                              ; preds = %145, %142
  %147 = load i16, i16* %15, align 2, !dbg !458
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter(i16 0, i16 %147), !dbg !459
  call void @__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction(i16 31767), !dbg !460
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 23), !dbg !461
  %148 = load i16, i16* %37, align 2, !dbg !462
  %149 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval(i16 %148), !dbg !463
  %150 = icmp eq i16 0, %149, !dbg !464
  br i1 %150, label %151, label %155, !dbg !465

151:                                              ; preds = %146
  %152 = load i16, i16* %32, align 2, !dbg !466
  %153 = load i16, i16* %31, align 2, !dbg !467
  %154 = load i16, i16* %30, align 2, !dbg !468
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start(i16 %152, i16 %153, i16 %154), !dbg !469
  br label %178, !dbg !465

155:                                              ; preds = %146
  %156 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !470
  %157 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !470
  %158 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !470
  %159 = load i16, i16* %31, align 2, !dbg !471
  store i16 %159, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !472
  store i16 %156, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !472
  store i16 %157, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !472
  store i16 %158, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !472
  %160 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !473
  %161 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !473
  %162 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !473
  %163 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !473
  %164 = and i16 %162, -193, !dbg !473
  %165 = or i16 %164, 128, !dbg !473
  store volatile i16 %160, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !474
  store volatile i16 %161, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !474
  store volatile i16 %165, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !474
  store volatile i16 %163, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !474
  call void asm sideeffect "nop", ""(), !dbg !474
  call void asm sideeffect "nop", ""(), !dbg !474
  %166 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !475
  %167 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !475
  %168 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !475
  %169 = load i16, i16* %31, align 2, !dbg !476
  store i16 %169, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !477
  store i16 %166, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !477
  store i16 %167, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !477
  store i16 %168, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !477
  %170 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !478
  %171 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !478
  %172 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !478
  %173 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !478
  %174 = and i16 %172, -193, !dbg !478
  %175 = or i16 %174, 128, !dbg !478
  %176 = and i16 %171, -64, !dbg !478
  %177 = or i16 %176, 27, !dbg !478
  store volatile i16 %170, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !479
  store volatile i16 %177, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !479
  store volatile i16 %175, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !479
  store volatile i16 %173, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !479
  call void asm sideeffect "nop", ""(), !dbg !479
  call void asm sideeffect "nop", ""(), !dbg !479
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !480
  br label %178, !dbg !465

178:                                              ; preds = %151, %155
  br label %179, !dbg !418

179:                                              ; preds = %112, %178
  br label %180, !dbg !413

180:                                              ; preds = %108, %179
  ret void, !dbg !353
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit(i16 %0, i16 %1) !dbg !481 {
  %3 = alloca i16, i16 1, align 2, !dbg !483
  %4 = alloca i16, i16 1, align 2, !dbg !485
  %5 = alloca i16, i16 1, align 2, !dbg !486
  %6 = alloca i16, i16 1, align 2, !dbg !487
  %7 = alloca i16, i16 1, align 2, !dbg !488
  %8 = alloca i16, i16 1, align 2, !dbg !489
  store i16 %0, i16* %8, align 2, !dbg !489
  store i16 %1, i16* %7, align 2, !dbg !488
  %9 = load i16, i16* %7, align 2, !dbg !490
  %10 = icmp ult i16 %9, -32768, !dbg !491
  br i1 %10, label %11, label %12, !dbg !492

11:                                               ; preds = %2
  br label %13, !dbg !492

12:                                               ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !492
  br label %13, !dbg !492

13:                                               ; preds = %11, %12
  %14 = load i16, i16* %7, align 2, !dbg !493
  %15 = mul i16 %14, 2, !dbg !494
  store i16 %15, i16* %6, align 2, !dbg !487
  %16 = load i16, i16* %8, align 2, !dbg !495
  %17 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %16, i16 8), !dbg !496
  %18 = sub i16 %17, 1, !dbg !497
  store i16 %18, i16* %5, align 2, !dbg !486
  %19 = load i16, i16* %6, align 2, !dbg !498
  %20 = load i16, i16* %5, align 2, !dbg !499
  %21 = icmp ult i16 %19, %20, !dbg !500
  br i1 %21, label %22, label %23, !dbg !485

22:                                               ; preds = %13
  store i16 0, i16* %4, align 2, !dbg !485
  br label %27, !dbg !485

23:                                               ; preds = %13
  %24 = load i16, i16* %6, align 2, !dbg !501
  %25 = load i16, i16* %5, align 2, !dbg !502
  %26 = sub i16 %24, %25, !dbg !503
  store i16 %26, i16* %4, align 2, !dbg !485
  br label %27, !dbg !485

27:                                               ; preds = %22, %23
  %28 = load i16, i16* %4, align 2, !dbg !485
  store i16 %28, i16* %3, align 2, !dbg !483
  %29 = load i16, i16* %8, align 2, !dbg !504
  %30 = load i16, i16* %3, align 2, !dbg !505
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %29, i16 4, i16 %30), !dbg !506
  ret void, !dbg !485
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter(i16 %0, i16 %1) !dbg !507 {
  %3 = alloca i16, i16 1, align 2, !dbg !508
  %4 = alloca i16, i16 1, align 2, !dbg !510
  store i16 %0, i16* %4, align 2, !dbg !510
  store i16 %1, i16* %3, align 2, !dbg !508
  %5 = load i16, i16* %3, align 2, !dbg !511
  %6 = icmp ult i16 %5, -32768, !dbg !512
  br i1 %6, label %7, label %8, !dbg !513

7:                                                ; preds = %2
  br label %9, !dbg !513

8:                                                ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !513
  br label %9, !dbg !513

9:                                                ; preds = %7, %8
  %10 = load i16, i16* %4, align 2, !dbg !514
  %11 = load i16, i16* %3, align 2, !dbg !515
  %12 = mul i16 %11, 2, !dbg !516
  %13 = add i16 %12, 1, !dbg !517
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %10, i16 8, i16 %13), !dbg !518
  ret void, !dbg !519
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter(i16 %0, i16 %1) !dbg !520 {
  %3 = alloca i16, i16 1, align 2, !dbg !521
  %4 = alloca i16, i16 1, align 2, !dbg !523
  %5 = alloca i1, i16 1, align 1, !dbg !524
  %6 = alloca i16, i16 1, align 2, !dbg !525
  %7 = alloca i16, i16 1, align 2, !dbg !526
  %8 = alloca i16, i16 1, align 2, !dbg !527
  %9 = alloca i16, i16 1, align 2, !dbg !528
  store i16 %0, i16* %9, align 2, !dbg !528
  store i16 %1, i16* %8, align 2, !dbg !527
  %10 = load i16, i16* %8, align 2, !dbg !529
  %11 = icmp ult i16 %10, -32768, !dbg !530
  br i1 %11, label %12, label %13, !dbg !531

12:                                               ; preds = %2
  br label %14, !dbg !531

13:                                               ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !531
  br label %14, !dbg !531

14:                                               ; preds = %12, %13
  %15 = load i16, i16* %9, align 2, !dbg !532
  %16 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %15, i16 8), !dbg !533
  store i16 %16, i16* %7, align 2, !dbg !526
  %17 = load i16, i16* %8, align 2, !dbg !534
  %18 = mul i16 %17, 2, !dbg !535
  store i16 %18, i16* %6, align 2, !dbg !525
  %19 = load i16, i16* %6, align 2, !dbg !536
  %20 = load i16, i16* %7, align 2, !dbg !537
  %21 = icmp ugt i16 %19, %20, !dbg !538
  store i1 %21, i1* %5, align 1, !dbg !524
  %22 = load i16, i16* %9, align 2, !dbg !539
  %23 = load i1, i1* %5, align 1, !dbg !540
  %24 = zext i1 %23 to i16, !dbg !541
  %25 = shl i16 %24, 6, !dbg !542
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %22, i16 14, i16 %25), !dbg !543
  %26 = load i1, i1* %5, align 1, !dbg !544
  br i1 %26, label %27, label %32, !dbg !523

27:                                               ; preds = %14
  %28 = load i16, i16* %6, align 2, !dbg !545
  %29 = load i16, i16* %7, align 2, !dbg !546
  %30 = sub i16 %28, %29, !dbg !547
  %31 = add i16 %30, 1, !dbg !548
  store i16 %31, i16* %4, align 2, !dbg !523
  br label %34, !dbg !523

32:                                               ; preds = %14
  %33 = load i16, i16* %6, align 2, !dbg !549
  store i16 %33, i16* %4, align 2, !dbg !523
  br label %34, !dbg !523

34:                                               ; preds = %27, %32
  %35 = load i16, i16* %4, align 2, !dbg !523
  store i16 %35, i16* %3, align 2, !dbg !521
  %36 = load i16, i16* %9, align 2, !dbg !550
  %37 = load i16, i16* %3, align 2, !dbg !551
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %36, i16 12, i16 %37), !dbg !552
  ret void, !dbg !523
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %0, i16 %1, i16 %2) !dbg !553 {
  %4 = alloca i16, i16 1, align 2, !dbg !555
  %5 = alloca i16, i16 1, align 2, !dbg !557
  %6 = alloca i16, i16 1, align 2, !dbg !558
  store i16 %0, i16* %6, align 2, !dbg !558
  store i16 %1, i16* %5, align 2, !dbg !557
  store i16 %2, i16* %4, align 2, !dbg !555
  %7 = load i16, i16* %6, align 2, !dbg !559
  %8 = getelementptr [6 x i16], [6 x i16]* @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.filters, i16 0, i16 %7, !dbg !560
  %9 = load i16, i16* %8, align 2, !dbg !560
  %10 = load i16, i16* %5, align 2, !dbg !561
  %11 = add i16 %9, %10, !dbg !562
  %12 = lshr i16 %11, 1, !dbg !563
  %13 = load i16, i16* %4, align 2, !dbg !564
  %14 = shl i16 %12, 1, !dbg !565
  %15 = inttoptr i16 %14 to i16*, !dbg !565
  store volatile i16 %13, i16* %15, align 2, !dbg !565
  call void asm sideeffect "nop", ""(), !dbg !565
  call void asm sideeffect "nop", ""(), !dbg !565
  ret void, !dbg !566
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %0, i16 %1) !dbg !567 {
  %3 = alloca i16, i16 1, align 2, !dbg !568
  %4 = alloca i16, i16 1, align 2, !dbg !570
  store i16 %0, i16* %4, align 2, !dbg !570
  store i16 %1, i16* %3, align 2, !dbg !568
  %5 = load i16, i16* %4, align 2, !dbg !571
  %6 = getelementptr [6 x i16], [6 x i16]* @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.filters, i16 0, i16 %5, !dbg !572
  %7 = load i16, i16* %6, align 2, !dbg !572
  %8 = load i16, i16* %3, align 2, !dbg !573
  %9 = add i16 %7, %8, !dbg !574
  %10 = lshr i16 %9, 1, !dbg !575
  %11 = shl i16 %10, 1, !dbg !576
  %12 = inttoptr i16 %11 to i16*, !dbg !576
  call void asm sideeffect "nop", ""(), !dbg !576
  call void asm sideeffect "nop", ""(), !dbg !576
  %13 = load volatile i16, i16* %12, align 2, !dbg !576
  ret i16 %13, !dbg !577
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 %0) !dbg !578 {
  %2 = alloca i16, i16 1, align 2, !dbg !580
  %3 = alloca i16, i16 1, align 2, !dbg !582
  %4 = alloca i16, i16 1, align 2, !dbg !583
  %5 = alloca i16, i16 1, align 2, !dbg !584
  store i16 %0, i16* %5, align 2, !dbg !584
  %6 = load i16, i16* %5, align 2, !dbg !585
  store i16 %6, i16* %4, align 2, !dbg !583
  %7 = load i16, i16* %4, align 2, !dbg !586
  %8 = add i16 %7, 31744, !dbg !587
  store i16 %8, i16* %3, align 2, !dbg !582
  %9 = load i16, i16* %3, align 2, !dbg !588
  %10 = shl i16 %9, 1, !dbg !589
  %11 = inttoptr i16 %10 to i16*, !dbg !589
  call void asm sideeffect "nop", ""(), !dbg !589
  call void asm sideeffect "nop", ""(), !dbg !589
  %12 = load volatile i16, i16* %11, align 2, !dbg !589
  store i16 %12, i16* %2, align 2, !dbg !580
  %13 = load i16, i16* %3, align 2, !dbg !590
  %14 = load i16, i16* %2, align 2, !dbg !591
  %15 = and i16 %14, 32767, !dbg !592
  %16 = shl i16 %13, 1, !dbg !593
  %17 = inttoptr i16 %16 to i16*, !dbg !593
  store volatile i16 %15, i16* %17, align 2, !dbg !593
  call void asm sideeffect "nop", ""(), !dbg !593
  call void asm sideeffect "nop", ""(), !dbg !593
  ret void, !dbg !594
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord() !dbg !595 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 2), !dbg !597
  %2 = sub i16 %1, 4, !dbg !599
  ret i16 %2, !dbg !600
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord() !dbg !601 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 0), !dbg !602
  %2 = sub i16 %1, 1, !dbg !604
  ret i16 %2, !dbg !605
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 %0) !dbg !606 {
  %2 = alloca i16, i16 1, align 2, !dbg !608
  %3 = alloca i16, i16 1, align 2, !dbg !610
  store i16 %0, i16* %3, align 2, !dbg !610
  %4 = load i16, i16* %3, align 2, !dbg !611
  %5 = lshr i16 %4, 1, !dbg !612
  %6 = add i16 %5, 31813, !dbg !613
  %7 = shl i16 %6, 1, !dbg !614
  %8 = inttoptr i16 %7 to i16*, !dbg !614
  call void asm sideeffect "nop", ""(), !dbg !614
  call void asm sideeffect "nop", ""(), !dbg !614
  %9 = load volatile i16, i16* %8, align 2, !dbg !614
  store i16 %9, i16* %2, align 2, !dbg !608
  %10 = load i16, i16* %2, align 2, !dbg !615
  %11 = and i16 %10, 2047, !dbg !616
  ret i16 %11, !dbg !617
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord() !dbg !618 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord(), !dbg !620
  ret i16 %1, !dbg !622
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.get_y_coord() !dbg !623 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord(), !dbg !624
  ret i16 %1, !dbg !626
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval(i16 %0) !dbg !627 {
  %2 = alloca i16, i16 1, align 2, !dbg !628
  store i16 %0, i16* %2, align 2, !dbg !628
  %3 = load i16, i16* %2, align 2, !dbg !630
  %4 = icmp ult i16 %3, 24, !dbg !631
  br i1 %4, label %5, label %7, !dbg !632

5:                                                ; preds = %10, %11, %1
  %6 = phi i16 [ 0, %10 ], [ 0, %11 ], [ 1, %1 ]
  br label %12, !dbg !632

7:                                                ; preds = %1
  %8 = load i16, i16* %2, align 2, !dbg !633
  %9 = icmp eq i16 31, %8, !dbg !634
  br i1 %9, label %10, label %11, !dbg !635

10:                                               ; preds = %7
  br label %5, !dbg !635

11:                                               ; preds = %7
  call void asm sideeffect "hcf", ""(), !dbg !635
  br label %5, !dbg !635

12:                                               ; preds = %5
  %13 = phi i16 [ %6, %5 ]
  br label %14, !dbg !632

14:                                               ; preds = %12
  ret i16 %13, !dbg !632
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7) !dbg !636 {
  %9 = alloca i16, i16 1, align 2, !dbg !637
  %10 = alloca i16, i16 1, align 2, !dbg !639
  %11 = alloca i16, i16 1, align 2, !dbg !640
  %12 = alloca i16, i16 1, align 2, !dbg !641
  %13 = alloca i16, i16 1, align 2, !dbg !642
  %14 = alloca i16, i16 1, align 2, !dbg !643
  %15 = alloca i16, i16 1, align 2, !dbg !644
  %16 = alloca i16, i16 1, align 2, !dbg !645
  %17 = alloca i16, i16 1, align 2, !dbg !646
  store i16 %0, i16* %17, align 2, !dbg !646
  store i16 %1, i16* %16, align 2, !dbg !645
  store i16 %2, i16* %15, align 2, !dbg !644
  store i16 %3, i16* %14, align 2, !dbg !643
  store i16 %4, i16* %13, align 2, !dbg !642
  store i16 %5, i16* %12, align 2, !dbg !641
  store i16 %6, i16* %11, align 2, !dbg !640
  store i16 %7, i16* %10, align 2, !dbg !639
  %18 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !647
  store i16 %18, i16* %9, align 2, !dbg !637
  %19 = load i16, i16* %11, align 2, !dbg !648
  store i16 %19, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_c, align 2, !dbg !649
  %20 = load i16, i16* %10, align 2, !dbg !650
  store i16 %20, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_is_half, align 2, !dbg !651
  %21 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_c, align 2, !dbg !652
  %22 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval(i16 %21), !dbg !653
  store i16 %22, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !654
  store i16 0, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !655
  %23 = load i16, i16* %16, align 2, !dbg !656
  store i16 %23, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !657
  %24 = load i16, i16* %15, align 2, !dbg !658
  store i16 %24, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !659
  %25 = load i16, i16* %15, align 2, !dbg !660
  %26 = load i16, i16* %13, align 2, !dbg !661
  %27 = add i16 %25, %26, !dbg !662
  %28 = sub i16 %27, 1, !dbg !663
  store i16 %28, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_last, align 2, !dbg !664
  %29 = load i16, i16* %9, align 2, !dbg !665
  %30 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_last, align 2, !dbg !666
  %31 = icmp eq i16 %29, %30, !dbg !667
  br i1 %31, label %32, label %37, !dbg !668

32:                                               ; preds = %8
  %33 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !669
  %34 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !669
  %35 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !669
  store i16 %33, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !670
  store i16 lshr (i16 ptrtoint ([1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.ctrl_1 to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !670
  store i16 %34, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !670
  store i16 %35, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !670
  %36 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.ctrl_1, i16 0, i1 false), align 4, !dbg !671
  store i32 %36, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i1 false), align 4, !dbg !672
  br label %42, !dbg !668

37:                                               ; preds = %8
  %38 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !673
  %39 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !673
  %40 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !673
  store i16 %38, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !674
  store i16 lshr (i16 ptrtoint ([1 x i32]* @"$$csl_base_address$$0$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11" to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !674
  store i16 %39, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !674
  store i16 %40, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !674
  %41 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @"$$csl_base_address$$0$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11", i16 0, i1 false), align 4, !dbg !675
  store i32 %41, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i1 false), align 4, !dbg !676
  br label %42, !dbg !668

42:                                               ; preds = %32, %37
  store i32 165646921, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i2 1), align 4, !dbg !677
  %43 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !678
  %44 = icmp eq i16 0, %43, !dbg !679
  br i1 %44, label %45, label %56, !dbg !680

45:                                               ; preds = %42
  %46 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !681
  %47 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !681
  %48 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !681
  %49 = load i16, i16* %17, align 2, !dbg !682
  %50 = call i16* @.get_tensor_ptr(i16 %49), !dbg !683
  %51 = ptrtoint i16* %50 to i16, !dbg !684
  %52 = lshr i16 %51, 1, !dbg !684
  store i16 %46, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !685
  store i16 %52, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !685
  store i16 %47, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !685
  store i16 %48, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !685
  %53 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !686
  %54 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !686
  %55 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !686
  store i16 1, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !687
  store i16 %53, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !687
  store i16 %54, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !687
  store i16 %55, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !687
  call void @llvm.sdr.actvt.r(i16 21), !dbg !688
  br label %63, !dbg !680

56:                                               ; preds = %42
  %57 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !689
  %58 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !689
  %59 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !689
  store i16 %57, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !690
  store i16 lshr (i16 ptrtoint ([1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.data_buf to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !690
  store i16 %58, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !690
  store i16 %59, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !690
  %60 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !691
  %61 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !691
  %62 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !691
  store i16 1, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !692
  store i16 %60, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !692
  store i16 %61, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !692
  store i16 %62, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !692
  call void @llvm.sdr.ublk.r(i16 0), !dbg !693
  br label %63, !dbg !680

63:                                               ; preds = %45, %56
  ret void, !dbg !668
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x(i32 %0) #8 !dbg !694 {
  %2 = alloca i32, i16 1, align 4, !dbg !695
  store i32 %0, i32* %2, align 4, !dbg !695
  call void @llvm.sdr.blk.r(i16 0), !dbg !697
  %3 = load i32, i32* %2, align 4, !dbg !698
  store i32 %3, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.data_buf, i16 0, i1 false), align 4, !dbg !699
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !700
  %4 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !701
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !701
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !701
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !701
  store volatile i16 %4, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !702
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !702
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !702
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !702
  call void asm sideeffect "nop", ""(), !dbg !702
  call void asm sideeffect "nop", ""(), !dbg !702
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !703
  %8 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !704
  %9 = add i16 %8, 1, !dbg !705
  store i16 %9, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !706
  ret void, !dbg !707
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_send_data() #9 !dbg !708 {
  %1 = alloca i16, i16 1, align 2, !dbg !709
  %2 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !711
  %3 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !712
  %4 = icmp ult i16 %2, %3, !dbg !713
  br i1 %4, label %5, label %27, !dbg !714

5:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !715
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !716
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !716
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !716
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !716
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !717
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !717
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !717
  store volatile i16 %9, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !717
  call void asm sideeffect "nop", ""(), !dbg !717
  call void asm sideeffect "nop", ""(), !dbg !717
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_is_half, align 2, !dbg !718
  %11 = icmp ult i16 0, %10, !dbg !719
  br i1 %11, label %12, label %18, !dbg !720

12:                                               ; preds = %5
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !721
  %13 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !722
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !722
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !722
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !722
  %17 = add i16 %14, 1, !dbg !723
  store i16 %13, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !724
  store i16 %17, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !724
  store i16 %15, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !724
  store i16 %16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !724
  br label %24, !dbg !720

18:                                               ; preds = %5
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !725
  %19 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !726
  %20 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !726
  %21 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !726
  %22 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !726
  %23 = add i16 %20, 2, !dbg !727
  store i16 %19, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !728
  store i16 %23, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !728
  store i16 %21, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !728
  store i16 %22, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !728
  br label %24, !dbg !720

24:                                               ; preds = %12, %18
  %25 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !729
  %26 = add i16 %25, 1, !dbg !730
  store i16 %26, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !731
  br label %34, !dbg !714

27:                                               ; preds = %0
  %28 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !732
  store i16 %28, i16* %1, align 2, !dbg !709
  %29 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !733
  %30 = load i16, i16* %1, align 2, !dbg !734
  %31 = icmp eq i16 %29, %30, !dbg !735
  br i1 %31, label %32, label %33, !dbg !736

32:                                               ; preds = %27
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !737
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__1 to i8*)), !dbg !738
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !739
  br label %33, !dbg !736

33:                                               ; preds = %32, %27
  br label %34, !dbg !714

34:                                               ; preds = %24, %33
  ret void, !dbg !714
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl() #10 !dbg !740 {
  %1 = alloca i16, i16 1, align 2, !dbg !741
  %2 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !743
  %3 = icmp eq i16 0, %2, !dbg !744
  br i1 %3, label %4, label %9, !dbg !745

4:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__2 to i8*)), !dbg !746
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !747
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !747
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !747
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !747
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !748
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !748
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !748
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !748
  call void asm sideeffect "nop", ""(), !dbg !748
  call void asm sideeffect "nop", ""(), !dbg !748
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !749
  br label %31, !dbg !745

9:                                                ; preds = %0
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !750
  %11 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !751
  %12 = icmp ult i16 %10, %11, !dbg !752
  br i1 %12, label %13, label %18, !dbg !753

13:                                               ; preds = %9
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__3 to i8*)), !dbg !754
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !755
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !755
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !755
  %17 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !755
  store volatile i16 %14, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !756
  store volatile i16 %15, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !756
  store volatile i16 %16, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !756
  store volatile i16 %17, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !756
  call void asm sideeffect "nop", ""(), !dbg !756
  call void asm sideeffect "nop", ""(), !dbg !756
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !757
  br label %30, !dbg !753

18:                                               ; preds = %9
  %19 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !758
  store i16 %19, i16* %1, align 2, !dbg !741
  %20 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !759
  %21 = load i16, i16* %1, align 2, !dbg !760
  %22 = icmp eq i16 %20, %21, !dbg !761
  br i1 %22, label %23, label %24, !dbg !762

23:                                               ; preds = %18
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__4 to i8*)), !dbg !763
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__5 to i8*)), !dbg !764
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !765
  br label %29, !dbg !762

24:                                               ; preds = %18
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !766
  %25 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !767
  %26 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !767
  %27 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !767
  %28 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !767
  store volatile i16 %25, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !768
  store volatile i16 %26, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !768
  store volatile i16 %27, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !768
  store volatile i16 %28, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !768
  call void asm sideeffect "nop", ""(), !dbg !768
  call void asm sideeffect "nop", ""(), !dbg !768
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !769
  br label %29, !dbg !762

29:                                               ; preds = %23, %24
  br label %30, !dbg !753

30:                                               ; preds = %13, %29
  br label %31, !dbg !745

31:                                               ; preds = %4, %30
  ret void, !dbg !745
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.d2h_configure(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7) !dbg !770 {
  %9 = alloca i1, i16 1, align 1, !dbg !771
  %10 = alloca i1, i16 1, align 1, !dbg !773
  %11 = alloca i1, i16 1, align 1, !dbg !774
  %12 = alloca i16, i16 1, align 2, !dbg !775
  %13 = alloca i16, i16 1, align 2, !dbg !776
  %14 = alloca i16, i16 1, align 2, !dbg !777
  %15 = alloca i16, i16 1, align 2, !dbg !778
  %16 = alloca i16, i16 1, align 2, !dbg !779
  %17 = alloca i16, i16 1, align 2, !dbg !780
  %18 = alloca i16, i16 1, align 2, !dbg !781
  %19 = alloca i16, i16 1, align 2, !dbg !782
  %20 = alloca i16, i16 1, align 2, !dbg !783
  %21 = alloca i16, i16 1, align 2, !dbg !784
  %22 = alloca i16, i16 1, align 2, !dbg !785
  %23 = alloca i16, i16 1, align 2, !dbg !786
  %24 = alloca i16, i16 1, align 2, !dbg !787
  %25 = alloca i16, i16 1, align 2, !dbg !788
  store i16 %0, i16* %25, align 2, !dbg !788
  store i16 %1, i16* %24, align 2, !dbg !787
  store i16 %2, i16* %23, align 2, !dbg !786
  store i16 %3, i16* %22, align 2, !dbg !785
  store i16 %4, i16* %21, align 2, !dbg !784
  store i16 %5, i16* %20, align 2, !dbg !783
  store i16 %6, i16* %19, align 2, !dbg !782
  store i16 %7, i16* %18, align 2, !dbg !781
  %26 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !789
  store i16 %26, i16* %17, align 2, !dbg !780
  %27 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_y_coord(), !dbg !790
  store i16 %27, i16* %16, align 2, !dbg !779
  %28 = load i16, i16* %24, align 2, !dbg !791
  store i16 %28, i16* %15, align 2, !dbg !778
  %29 = load i16, i16* %24, align 2, !dbg !792
  %30 = load i16, i16* %22, align 2, !dbg !793
  %31 = add i16 %29, %30, !dbg !794
  %32 = sub i16 %31, 1, !dbg !795
  store i16 %32, i16* %14, align 2, !dbg !777
  %33 = load i16, i16* %23, align 2, !dbg !796
  store i16 %33, i16* %13, align 2, !dbg !776
  %34 = load i16, i16* %23, align 2, !dbg !797
  %35 = load i16, i16* %21, align 2, !dbg !798
  %36 = add i16 %34, %35, !dbg !799
  %37 = sub i16 %36, 1, !dbg !800
  store i16 %37, i16* %12, align 2, !dbg !775
  store i1 false, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !801
  %38 = load i16, i16* %17, align 2, !dbg !802
  %39 = load i16, i16* %15, align 2, !dbg !803
  %40 = icmp sge i16 %38, %39, !dbg !804
  br i1 %40, label %41, label %45, !dbg !774

41:                                               ; preds = %8
  %42 = load i16, i16* %16, align 2, !dbg !805
  %43 = load i16, i16* %12, align 2, !dbg !806
  %44 = icmp sle i16 %42, %43, !dbg !807
  store i1 %44, i1* %11, align 1, !dbg !774
  br label %46, !dbg !774

45:                                               ; preds = %8
  store i1 false, i1* %11, align 1, !dbg !774
  br label %46, !dbg !774

46:                                               ; preds = %41, %45
  %47 = load i1, i1* %11, align 1, !dbg !774
  br i1 %47, label %48, label %52, !dbg !773

48:                                               ; preds = %46
  %49 = load i16, i16* %16, align 2, !dbg !808
  %50 = load i16, i16* %13, align 2, !dbg !809
  %51 = icmp sge i16 %49, %50, !dbg !810
  store i1 %51, i1* %10, align 1, !dbg !773
  br label %53, !dbg !773

52:                                               ; preds = %46
  store i1 false, i1* %10, align 1, !dbg !773
  br label %53, !dbg !773

53:                                               ; preds = %48, %52
  %54 = load i1, i1* %10, align 1, !dbg !773
  br i1 %54, label %55, label %56, !dbg !811

55:                                               ; preds = %53
  store i1 true, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !812
  br label %56, !dbg !811

56:                                               ; preds = %55, %53
  store i1 false, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !813
  %57 = load i16, i16* %17, align 2, !dbg !814
  %58 = load i16, i16* %14, align 2, !dbg !815
  %59 = icmp sle i16 %57, %58, !dbg !816
  br i1 %59, label %60, label %62, !dbg !771

60:                                               ; preds = %56
  %61 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !817
  store i1 %61, i1* %9, align 1, !dbg !771
  br label %63, !dbg !771

62:                                               ; preds = %56
  store i1 false, i1* %9, align 1, !dbg !771
  br label %63, !dbg !771

63:                                               ; preds = %60, %62
  %64 = load i1, i1* %9, align 1, !dbg !771
  br i1 %64, label %65, label %66, !dbg !818

65:                                               ; preds = %63
  store i1 true, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !819
  br label %66, !dbg !818

66:                                               ; preds = %65, %63
  %67 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !820
  br i1 %67, label %68, label %86, !dbg !821

68:                                               ; preds = %66
  call void @__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position(i16 31959), !dbg !822
  %69 = load i16, i16* %15, align 2, !dbg !823
  %70 = load i16, i16* %17, align 2, !dbg !824
  %71 = icmp eq i16 %69, %70, !dbg !825
  br i1 %71, label %72, label %73, !dbg !826

72:                                               ; preds = %68
  call void @__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 31765), !dbg !827
  br label %74, !dbg !826

73:                                               ; preds = %68
  call void @__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 31765), !dbg !828
  br label %74, !dbg !826

74:                                               ; preds = %72, %73
  call void @sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit(i16 21), !dbg !829
  %75 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !830
  br i1 %75, label %76, label %85, !dbg !831

76:                                               ; preds = %74
  %77 = load i16, i16* %20, align 2, !dbg !832
  %78 = load i16, i16* %19, align 2, !dbg !833
  %79 = load i16, i16* %24, align 2, !dbg !834
  %80 = load i16, i16* %23, align 2, !dbg !835
  %81 = load i16, i16* %22, align 2, !dbg !836
  %82 = load i16, i16* %21, align 2, !dbg !837
  %83 = load i16, i16* %25, align 2, !dbg !838
  %84 = load i16, i16* %18, align 2, !dbg !839
  call void @sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start(i16 %77, i16 %78, i16 %79, i16 %80, i16 %81, i16 %82, i16 %83, i16 %84), !dbg !840
  br label %85, !dbg !831

85:                                               ; preds = %76, %74
  br label %87, !dbg !821

86:                                               ; preds = %66
  call void @llvm.sdr.actvt.r(i16 28), !dbg !841
  br label %87, !dbg !821

87:                                               ; preds = %85, %86
  ret void, !dbg !774
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit(i16 %0) !dbg !842 {
  %2 = alloca i16, i16 1, align 2, !dbg !843
  %3 = alloca i16, i16 1, align 2, !dbg !845
  %4 = alloca i16, i16 1, align 2, !dbg !846
  %5 = alloca i16, i16 1, align 2, !dbg !847
  store i16 %0, i16* %5, align 2, !dbg !847
  %6 = load i16, i16* %5, align 2, !dbg !848
  store i16 %6, i16* %4, align 2, !dbg !846
  %7 = load i16, i16* %4, align 2, !dbg !849
  %8 = add i16 %7, 31744, !dbg !850
  store i16 %8, i16* %3, align 2, !dbg !845
  %9 = load i16, i16* %3, align 2, !dbg !851
  %10 = shl i16 %9, 1, !dbg !852
  %11 = inttoptr i16 %10 to i16*, !dbg !852
  call void asm sideeffect "nop", ""(), !dbg !852
  call void asm sideeffect "nop", ""(), !dbg !852
  %12 = load volatile i16, i16* %11, align 2, !dbg !852
  store i16 %12, i16* %2, align 2, !dbg !843
  %13 = load i16, i16* %3, align 2, !dbg !853
  %14 = load i16, i16* %2, align 2, !dbg !854
  %15 = and i16 %14, 32767, !dbg !855
  %16 = shl i16 %13, 1, !dbg !856
  %17 = inttoptr i16 %16 to i16*, !dbg !856
  store volatile i16 %15, i16* %17, align 2, !dbg !856
  call void asm sideeffect "nop", ""(), !dbg !856
  call void asm sideeffect "nop", ""(), !dbg !856
  ret void, !dbg !857
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord() !dbg !858 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 2), !dbg !859
  %2 = sub i16 %1, 4, !dbg !861
  ret i16 %2, !dbg !862
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord() !dbg !863 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 0), !dbg !864
  %2 = sub i16 %1, 1, !dbg !866
  ret i16 %2, !dbg !867
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 %0) !dbg !868 {
  %2 = alloca i16, i16 1, align 2, !dbg !869
  %3 = alloca i16, i16 1, align 2, !dbg !871
  store i16 %0, i16* %3, align 2, !dbg !871
  %4 = load i16, i16* %3, align 2, !dbg !872
  %5 = lshr i16 %4, 1, !dbg !873
  %6 = add i16 %5, 31813, !dbg !874
  %7 = shl i16 %6, 1, !dbg !875
  %8 = inttoptr i16 %7 to i16*, !dbg !875
  call void asm sideeffect "nop", ""(), !dbg !875
  call void asm sideeffect "nop", ""(), !dbg !875
  %9 = load volatile i16, i16* %8, align 2, !dbg !875
  store i16 %9, i16* %2, align 2, !dbg !869
  %10 = load i16, i16* %2, align 2, !dbg !876
  %11 = and i16 %10, 2047, !dbg !877
  ret i16 %11, !dbg !878
}

define internal i16 @sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr(i16 %0) !dbg !879 {
  %2 = alloca i16, i16 1, align 2, !dbg !881
  store i16 %0, i16* %2, align 2, !dbg !881
  %3 = load i16, i16* %2, align 2, !dbg !883
  %4 = mul i16 %3, 2, !dbg !884
  %5 = add i16 %4, 31680, !dbg !885
  ret i16 %5, !dbg !886
}

define internal void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 %0, i16 %1, i1 %2) !dbg !887 {
  %4 = alloca i16, i16 1, align 2, !dbg !888
  %5 = alloca i16, i16 1, align 2, !dbg !890
  %6 = alloca i1, i16 1, align 1, !dbg !891
  %7 = alloca i16, i16 1, align 2, !dbg !892
  %8 = alloca i16, i16 1, align 2, !dbg !893
  store i16 %0, i16* %8, align 2, !dbg !893
  store i16 %1, i16* %7, align 2, !dbg !892
  store i1 %2, i1* %6, align 1, !dbg !891
  %9 = load i16, i16* %8, align 2, !dbg !894
  %10 = call i16 @sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr(i16 %9), !dbg !895
  store i16 %10, i16* %5, align 2, !dbg !890
  %11 = load i16, i16* %5, align 2, !dbg !896
  %12 = shl i16 %11, 1, !dbg !897
  %13 = inttoptr i16 %12 to i16*, !dbg !897
  call void asm sideeffect "nop", ""(), !dbg !897
  call void asm sideeffect "nop", ""(), !dbg !897
  call void asm sideeffect "nop", ""(), !dbg !897
  call void asm sideeffect "nop", ""(), !dbg !897
  %14 = load volatile i16, i16* %13, align 2, !dbg !897
  store i16 %14, i16* %4, align 2, !dbg !888
  %15 = load i1, i1* %6, align 1, !dbg !898
  br i1 %15, label %16, label %19, !dbg !899

16:                                               ; preds = %3
  %17 = load i16, i16* %4, align 2, !dbg !900
  %18 = or i16 %17, 2048, !dbg !901
  store i16 %18, i16* %4, align 2, !dbg !902
  br label %22, !dbg !899

19:                                               ; preds = %3
  %20 = load i16, i16* %4, align 2, !dbg !903
  %21 = and i16 %20, -2049, !dbg !904
  store i16 %21, i16* %4, align 2, !dbg !905
  br label %22, !dbg !899

22:                                               ; preds = %16, %19
  %23 = load i16, i16* %4, align 2, !dbg !906
  %24 = and i16 %23, -32, !dbg !907
  store i16 %24, i16* %4, align 2, !dbg !908
  %25 = load i16, i16* %4, align 2, !dbg !909
  %26 = load i16, i16* %7, align 2, !dbg !910
  %27 = add i16 %25, %26, !dbg !911
  store i16 %27, i16* %4, align 2, !dbg !912
  %28 = load i16, i16* %5, align 2, !dbg !913
  %29 = load i16, i16* %4, align 2, !dbg !914
  %30 = shl i16 %28, 1, !dbg !915
  %31 = inttoptr i16 %30 to i16*, !dbg !915
  store volatile i16 %29, i16* %31, align 2, !dbg !915
  call void asm sideeffect "nop", ""(), !dbg !915
  call void asm sideeffect "nop", ""(), !dbg !915
  call void asm sideeffect "nop", ""(), !dbg !915
  call void asm sideeffect "nop", ""(), !dbg !915
  ret void, !dbg !899
}

define internal i16 @sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr(i16 %0) !dbg !916 {
  %2 = alloca i16, i16 1, align 2, !dbg !918
  store i16 %0, i16* %2, align 2, !dbg !918
  %3 = load i16, i16* %2, align 2, !dbg !920
  %4 = add i16 %3, 31616, !dbg !921
  ret i16 %4, !dbg !922
}

define internal void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 %0, i16 %1) !dbg !923 {
  %3 = alloca i16, i16 1, align 2, !dbg !924
  %4 = alloca i16, i16 1, align 2, !dbg !926
  %5 = alloca i16, i16 1, align 2, !dbg !927
  %6 = alloca i16, i16 1, align 2, !dbg !928
  store i16 %0, i16* %6, align 2, !dbg !928
  store i16 %1, i16* %5, align 2, !dbg !927
  %7 = load i16, i16* %6, align 2, !dbg !929
  %8 = call i16 @sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr(i16 %7), !dbg !930
  store i16 %8, i16* %4, align 2, !dbg !926
  %9 = load i16, i16* %4, align 2, !dbg !931
  %10 = shl i16 %9, 1, !dbg !932
  %11 = inttoptr i16 %10 to i16*, !dbg !932
  call void asm sideeffect "nop", ""(), !dbg !932
  call void asm sideeffect "nop", ""(), !dbg !932
  call void asm sideeffect "nop", ""(), !dbg !932
  call void asm sideeffect "nop", ""(), !dbg !932
  %12 = load volatile i16, i16* %11, align 2, !dbg !932
  store i16 %12, i16* %3, align 2, !dbg !924
  %13 = load i16, i16* %3, align 2, !dbg !933
  %14 = and i16 %13, -497, !dbg !934
  store i16 %14, i16* %3, align 2, !dbg !935
  %15 = load i16, i16* %3, align 2, !dbg !936
  %16 = load i16, i16* %5, align 2, !dbg !937
  %17 = add i16 %15, %16, !dbg !938
  %18 = shl i16 %17, 4, !dbg !939
  store i16 %18, i16* %3, align 2, !dbg !940
  %19 = load i16, i16* %4, align 2, !dbg !941
  %20 = load i16, i16* %3, align 2, !dbg !942
  %21 = shl i16 %19, 1, !dbg !943
  %22 = inttoptr i16 %21 to i16*, !dbg !943
  store volatile i16 %20, i16* %22, align 2, !dbg !943
  call void asm sideeffect "nop", ""(), !dbg !943
  call void asm sideeffect "nop", ""(), !dbg !943
  call void asm sideeffect "nop", ""(), !dbg !943
  call void asm sideeffect "nop", ""(), !dbg !943
  ret void, !dbg !944
}

define internal i16* @.get_tensor_ptr(i16 %0) !dbg !945 {
  %2 = alloca i16, i16 1, align 2, !dbg !946
  store i16 %0, i16* %2, align 2, !dbg !946
  %3 = load i16, i16* %2, align 2, !dbg !946
  %4 = zext i16 %3 to i32, !dbg !946
  switch i32 %4, label %5 [
    i32 1, label %9
    i32 2, label %11
    i32 3, label %13
    i32 4, label %15
    i32 5, label %17
  ], !dbg !946

5:                                                ; preds = %1
  br i1 false, label %6, label %7, !dbg !946

6:                                                ; preds = %5
  br label %8, !dbg !946

7:                                                ; preds = %5
  call void asm sideeffect "hcf", ""(), !dbg !946
  br label %8, !dbg !946

8:                                                ; preds = %6, %7
  br label %19, !dbg !946

9:                                                ; preds = %1
  %10 = load i16*, i16** @p_a, align 8, !dbg !946
  br label %19, !dbg !946

11:                                               ; preds = %1
  %12 = load i16*, i16** @p_b, align 8, !dbg !946
  br label %19, !dbg !946

13:                                               ; preds = %1
  %14 = load i16*, i16** @p_c, align 8, !dbg !946
  br label %19, !dbg !946

15:                                               ; preds = %1
  %16 = load i16*, i16** @p_idx, align 8, !dbg !946
  br label %19, !dbg !946

17:                                               ; preds = %1
  %18 = load i16*, i16** @p_k, align 8, !dbg !946
  br label %19, !dbg !946

19:                                               ; preds = %8, %9, %11, %13, %15, %17
  %20 = phi i16 [ -2, %17 ], [ -2, %15 ], [ -2, %13 ], [ -2, %11 ], [ -2, %9 ], [ 0, %8 ]
  %21 = phi i16* [ %18, %17 ], [ %16, %15 ], [ %14, %13 ], [ %12, %11 ], [ %10, %9 ], [ undef, %8 ]
  br label %22, !dbg !946

22:                                               ; preds = %19
  %23 = icmp ne i16 %20, 0, !dbg !946
  br i1 %23, label %24, label %25, !dbg !946

24:                                               ; preds = %22
  br label %27, !dbg !946

25:                                               ; preds = %22
  %26 = load i16*, i16** @p_k, align 8, !dbg !946
  br label %27, !dbg !946

27:                                               ; preds = %24, %25
  %28 = phi i16* [ %26, %25 ], [ %21, %24 ]
  br label %29, !dbg !946

29:                                               ; preds = %27
  ret i16* %28, !dbg !946
}

define internal void @__generic0sys_mod.sys_mod.tile_config.queue_flush.exit() !dbg !948 {
  store volatile i16 1, i16* inttoptr (i16 -2268 to i16*), align 2, !dbg !950
  call void asm sideeffect "nop", ""(), !dbg !950
  call void asm sideeffect "nop", ""(), !dbg !950
  ret void, !dbg !952
}

define internal void @__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position(i16 %0) !dbg !953 {
  %2 = alloca i16, i16 1, align 2, !dbg !955
  %3 = alloca i16, i16 1, align 2, !dbg !957
  %4 = alloca i16, i16 1, align 2, !dbg !958
  store i16 %0, i16* %4, align 2, !dbg !958
  %5 = load i16, i16* %4, align 2, !dbg !959
  store i16 %5, i16* %3, align 2, !dbg !957
  %6 = load i16, i16* %3, align 2, !dbg !960
  %7 = shl i16 %6, 1, !dbg !961
  %8 = inttoptr i16 %7 to i16*, !dbg !961
  call void asm sideeffect "nop", ""(), !dbg !961
  call void asm sideeffect "nop", ""(), !dbg !961
  call void asm sideeffect "nop", ""(), !dbg !961
  call void asm sideeffect "nop", ""(), !dbg !961
  %9 = load volatile i16, i16* %8, align 2, !dbg !961
  store i16 %9, i16* %2, align 2, !dbg !955
  %10 = load i16, i16* %2, align 2, !dbg !962
  %11 = and i16 %10, -16, !dbg !963
  store i16 %11, i16* %2, align 2, !dbg !963
  %12 = load i16, i16* %3, align 2, !dbg !964
  %13 = load i16, i16* %2, align 2, !dbg !965
  %14 = shl i16 %12, 1, !dbg !966
  %15 = inttoptr i16 %14 to i16*, !dbg !966
  store volatile i16 %13, i16* %15, align 2, !dbg !966
  call void asm sideeffect "nop", ""(), !dbg !966
  call void asm sideeffect "nop", ""(), !dbg !966
  call void asm sideeffect "nop", ""(), !dbg !966
  call void asm sideeffect "nop", ""(), !dbg !966
  ret void, !dbg !967
}

define internal void @__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 %0) !dbg !968 {
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
  %9 = load volatile i16, i16* %8, align 2, !dbg !976
  store i16 %9, i16* %2, align 2, !dbg !970
  %10 = load i16, i16* %2, align 2, !dbg !977
  %11 = and i16 %10, -256, !dbg !978
  store i16 %11, i16* %2, align 2, !dbg !979
  %12 = load i16, i16* %2, align 2, !dbg !980
  %13 = load i16, i16* %2, align 2, !dbg !981
  %14 = call i16 @__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %13), !dbg !982
  %15 = or i16 %12, %14, !dbg !983
  store i16 %15, i16* %2, align 2, !dbg !983
  %16 = load i16, i16* %2, align 2, !dbg !984
  %17 = load i16, i16* %2, align 2, !dbg !985
  %18 = call i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %17), !dbg !986
  %19 = or i16 %16, %18, !dbg !987
  store i16 %19, i16* %2, align 2, !dbg !987
  %20 = load i16, i16* %3, align 2, !dbg !988
  %21 = load i16, i16* %2, align 2, !dbg !989
  %22 = shl i16 %20, 1, !dbg !990
  %23 = inttoptr i16 %22 to i16*, !dbg !990
  store volatile i16 %21, i16* %23, align 2, !dbg !990
  call void asm sideeffect "nop", ""(), !dbg !990
  call void asm sideeffect "nop", ""(), !dbg !990
  ret void, !dbg !991
}

define internal void @__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 %0) !dbg !992 {
  %2 = alloca i16, i16 1, align 2, !dbg !993
  %3 = alloca i16, i16 1, align 2, !dbg !995
  %4 = alloca i16, i16 1, align 2, !dbg !996
  store i16 %0, i16* %4, align 2, !dbg !996
  %5 = load i16, i16* %4, align 2, !dbg !997
  store i16 %5, i16* %3, align 2, !dbg !995
  %6 = load i16, i16* %3, align 2, !dbg !998
  %7 = shl i16 %6, 1, !dbg !999
  %8 = inttoptr i16 %7 to i16*, !dbg !999
  call void asm sideeffect "nop", ""(), !dbg !999
  call void asm sideeffect "nop", ""(), !dbg !999
  %9 = load volatile i16, i16* %8, align 2, !dbg !999
  store i16 %9, i16* %2, align 2, !dbg !993
  %10 = load i16, i16* %2, align 2, !dbg !1000
  %11 = and i16 %10, -256, !dbg !1001
  store i16 %11, i16* %2, align 2, !dbg !1002
  %12 = load i16, i16* %2, align 2, !dbg !1003
  %13 = load i16, i16* %2, align 2, !dbg !1004
  %14 = call i16 @__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %13), !dbg !1005
  %15 = or i16 %12, %14, !dbg !1006
  store i16 %15, i16* %2, align 2, !dbg !1006
  %16 = load i16, i16* %2, align 2, !dbg !1007
  %17 = load i16, i16* %2, align 2, !dbg !1008
  %18 = call i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %17), !dbg !1009
  %19 = or i16 %16, %18, !dbg !1010
  store i16 %19, i16* %2, align 2, !dbg !1010
  %20 = load i16, i16* %3, align 2, !dbg !1011
  %21 = load i16, i16* %2, align 2, !dbg !1012
  %22 = shl i16 %20, 1, !dbg !1013
  %23 = inttoptr i16 %22 to i16*, !dbg !1013
  store volatile i16 %21, i16* %23, align 2, !dbg !1013
  call void asm sideeffect "nop", ""(), !dbg !1013
  call void asm sideeffect "nop", ""(), !dbg !1013
  ret void, !dbg !1014
}

define internal i16 @__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %0) !dbg !1015 {
  %2 = alloca i16, i16 1, align 2, !dbg !1016
  %3 = alloca i16, i16 1, align 2, !dbg !1018
  store i16 %0, i16* %3, align 2, !dbg !1018
  %4 = load i16, i16* %3, align 2, !dbg !1019
  store i16 %4, i16* %2, align 2, !dbg !1016
  %5 = load i16, i16* %2, align 2, !dbg !1020
  store i16 %5, i16* %2, align 2, !dbg !1021
  %6 = load i16, i16* %2, align 2, !dbg !1022
  ret i16 %6, !dbg !1023
}

define internal i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %0) !dbg !1024 {
  %2 = alloca i16, i16 1, align 2, !dbg !1025
  %3 = alloca i16, i16 1, align 2, !dbg !1027
  store i16 %0, i16* %3, align 2, !dbg !1027
  %4 = load i16, i16* %3, align 2, !dbg !1028
  store i16 %4, i16* %2, align 2, !dbg !1025
  %5 = load i16, i16* %2, align 2, !dbg !1029
  %6 = or i16 %5, 2, !dbg !1030
  store i16 %6, i16* %2, align 2, !dbg !1030
  %7 = load i16, i16* %2, align 2, !dbg !1031
  ret i16 %7, !dbg !1032
}

define internal i16 @__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %0) !dbg !1033 {
  %2 = alloca i16, i16 1, align 2, !dbg !1034
  %3 = alloca i16, i16 1, align 2, !dbg !1036
  store i16 %0, i16* %3, align 2, !dbg !1036
  %4 = load i16, i16* %3, align 2, !dbg !1037
  store i16 %4, i16* %2, align 2, !dbg !1034
  %5 = load i16, i16* %2, align 2, !dbg !1038
  %6 = or i16 %5, 128, !dbg !1039
  store i16 %6, i16* %2, align 2, !dbg !1039
  %7 = load i16, i16* %2, align 2, !dbg !1040
  ret i16 %7, !dbg !1041
}

define internal void @__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction(i16 %0) !dbg !1042 {
  %2 = alloca i16, i16 1, align 2, !dbg !1043
  %3 = alloca i16, i16 1, align 2, !dbg !1045
  %4 = alloca i16, i16 1, align 2, !dbg !1046
  store i16 %0, i16* %4, align 2, !dbg !1046
  %5 = load i16, i16* %4, align 2, !dbg !1047
  store i16 %5, i16* %3, align 2, !dbg !1045
  %6 = load i16, i16* %3, align 2, !dbg !1048
  %7 = shl i16 %6, 1, !dbg !1049
  %8 = inttoptr i16 %7 to i16*, !dbg !1049
  call void asm sideeffect "nop", ""(), !dbg !1049
  call void asm sideeffect "nop", ""(), !dbg !1049
  %9 = load volatile i16, i16* %8, align 2, !dbg !1049
  store i16 %9, i16* %2, align 2, !dbg !1043
  %10 = load i16, i16* %2, align 2, !dbg !1050
  %11 = and i16 %10, -17, !dbg !1051
  store i16 %11, i16* %2, align 2, !dbg !1051
  %12 = load i16, i16* %3, align 2, !dbg !1052
  %13 = load i16, i16* %2, align 2, !dbg !1053
  %14 = shl i16 %12, 1, !dbg !1054
  %15 = inttoptr i16 %14 to i16*, !dbg !1054
  store volatile i16 %13, i16* %15, align 2, !dbg !1054
  call void asm sideeffect "nop", ""(), !dbg !1054
  call void asm sideeffect "nop", ""(), !dbg !1054
  ret void, !dbg !1055
}

define internal void @__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction(i16 %0) !dbg !1056 {
  %2 = alloca i16, i16 1, align 2, !dbg !1057
  %3 = alloca i16, i16 1, align 2, !dbg !1059
  %4 = alloca i16, i16 1, align 2, !dbg !1060
  store i16 %0, i16* %4, align 2, !dbg !1060
  %5 = load i16, i16* %4, align 2, !dbg !1061
  store i16 %5, i16* %3, align 2, !dbg !1059
  %6 = load i16, i16* %3, align 2, !dbg !1062
  %7 = shl i16 %6, 1, !dbg !1063
  %8 = inttoptr i16 %7 to i16*, !dbg !1063
  call void asm sideeffect "nop", ""(), !dbg !1063
  call void asm sideeffect "nop", ""(), !dbg !1063
  %9 = load volatile i16, i16* %8, align 2, !dbg !1063
  store i16 %9, i16* %2, align 2, !dbg !1057
  %10 = load i16, i16* %2, align 2, !dbg !1064
  %11 = or i16 %10, 16, !dbg !1065
  store i16 %11, i16* %2, align 2, !dbg !1065
  %12 = load i16, i16* %3, align 2, !dbg !1066
  %13 = load i16, i16* %2, align 2, !dbg !1067
  %14 = shl i16 %12, 1, !dbg !1068
  %15 = inttoptr i16 %14 to i16*, !dbg !1068
  store volatile i16 %13, i16* %15, align 2, !dbg !1068
  call void asm sideeffect "nop", ""(), !dbg !1068
  call void asm sideeffect "nop", ""(), !dbg !1068
  ret void, !dbg !1069
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
!4 = !DIFile(filename: "./pe.csl", directory: "/home/USER/xkernel/studies/wse3-characterization/microbench/addfam/cases/base")
!5 = !DISubroutineType(types: !6)
!6 = !{}
!7 = !DILocation(line: 16, column: 11, scope: !8)
!8 = !DILexicalBlockFile(scope: !3, file: !4, discriminator: 0)
!9 = !DILocation(line: 16, column: 18, scope: !8)
!10 = !DILocation(line: 16, column: 15, scope: !8)
!11 = !DILocation(line: 16, column: 8, scope: !8)
!12 = !DILocation(line: 17, column: 3, scope: !8)
!13 = !DILocation(line: 15, column: 1, scope: !8)
!14 = distinct !DISubprogram(name: "f_exit", linkageName: "f_exit", scope: null, file: !4, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!15 = !DILocation(line: 20, column: 22, scope: !16)
!16 = !DILexicalBlockFile(scope: !14, file: !4, discriminator: 0)
!17 = !DILocation(line: 20, column: 1, scope: !16)
!18 = distinct !DISubprogram(name: "sys_mod.sys_nop", linkageName: "sys_mod.sys_nop", scope: null, file: !19, line: 90, type: !5, scopeLine: 90, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!19 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/memcpy.csl", directory: "")
!20 = !DILocation(line: 90, column: 1, scope: !21)
!21 = !DILexicalBlockFile(scope: !18, file: !19, discriminator: 0)
!22 = distinct !DISubprogram(name: "sys_mod.unblock_cmd_stream", linkageName: "sys_mod.unblock_cmd_stream", scope: null, file: !19, line: 102, type: !5, scopeLine: 102, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!23 = !DILocation(line: 103, column: 3, scope: !24)
!24 = !DILexicalBlockFile(scope: !22, file: !19, discriminator: 0)
!25 = !DILocation(line: 102, column: 1, scope: !24)
!26 = distinct !DISubprogram(name: "sys_mod.sys_mod.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.unblock_cmd_stream", scope: null, file: !27, line: 307, type: !5, scopeLine: 307, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!27 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpy.csl", directory: "")
!28 = !DILocation(line: 308, column: 5, scope: !29)
!29 = !DILexicalBlockFile(scope: !26, file: !27, discriminator: 0)
!30 = !DILocation(line: 307, column: 1, scope: !29)
!31 = distinct !DISubprogram(name: "sys_mod.sys_mod.teardown_h2d", linkageName: "sys_mod.sys_mod.teardown_h2d", scope: null, file: !27, line: 323, type: !5, scopeLine: 323, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!32 = !DILocation(line: 326, column: 5, scope: !33)
!33 = !DILexicalBlockFile(scope: !31, file: !27, discriminator: 0)
!34 = !DILocation(line: 323, column: 1, scope: !33)
!35 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_ublk_c22", linkageName: "sys_mod.sys_mod.f_ublk_c22", scope: null, file: !27, line: 335, type: !5, scopeLine: 335, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!36 = !DILocation(line: 336, column: 5, scope: !37)
!37 = !DILexicalBlockFile(scope: !35, file: !27, discriminator: 0)
!38 = !DILocation(line: 335, column: 1, scope: !37)
!39 = distinct !DISubprogram(name: "sys_mod.sys_mod.teardown_d2h", linkageName: "sys_mod.sys_mod.teardown_d2h", scope: null, file: !27, line: 344, type: !5, scopeLine: 344, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!40 = !DILocation(line: 355, column: 5, scope: !41)
!41 = !DILexicalBlockFile(scope: !39, file: !27, discriminator: 0)
!42 = !DILocation(line: 359, column: 5, scope: !41)
!43 = !DILocation(line: 344, column: 1, scope: !41)
!44 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_memcpyh2d", linkageName: "sys_mod.sys_mod.f_memcpyh2d", scope: null, file: !27, line: 460, type: !5, scopeLine: 460, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!45 = !DILocation(line: 477, column: 5, scope: !46)
!46 = !DILexicalBlockFile(scope: !44, file: !27, discriminator: 0)
!47 = !DILocation(line: 476, column: 5, scope: !46)
!48 = !DILocation(line: 475, column: 5, scope: !46)
!49 = !DILocation(line: 474, column: 5, scope: !46)
!50 = !DILocation(line: 473, column: 5, scope: !46)
!51 = !DILocation(line: 472, column: 5, scope: !46)
!52 = !DILocation(line: 471, column: 5, scope: !46)
!53 = !DILocation(line: 470, column: 5, scope: !46)
!54 = !DILocation(line: 469, column: 5, scope: !46)
!55 = !DILocation(line: 468, column: 5, scope: !46)
!56 = !DILocation(line: 467, column: 5, scope: !46)
!57 = !DILocation(line: 466, column: 5, scope: !46)
!58 = !DILocation(line: 465, column: 5, scope: !46)
!59 = !DILocation(line: 463, column: 5, scope: !46)
!60 = !DILocation(line: 462, column: 20, scope: !46)
!61 = !DILocation(line: 462, column: 32, scope: !46)
!62 = !DILocation(line: 462, column: 5, scope: !46)
!63 = !DILocation(line: 465, column: 33, scope: !46)
!64 = !DILocation(line: 465, column: 38, scope: !46)
!65 = !DILocation(line: 466, column: 34, scope: !46)
!66 = !DILocation(line: 466, column: 39, scope: !46)
!67 = !DILocation(line: 467, column: 34, scope: !46)
!68 = !DILocation(line: 467, column: 39, scope: !46)
!69 = !DILocation(line: 468, column: 33, scope: !46)
!70 = !DILocation(line: 468, column: 38, scope: !46)
!71 = !DILocation(line: 469, column: 33, scope: !46)
!72 = !DILocation(line: 469, column: 38, scope: !46)
!73 = !DILocation(line: 470, column: 35, scope: !46)
!74 = !DILocation(line: 470, column: 21, scope: !46)
!75 = !DILocation(line: 471, column: 41, scope: !46)
!76 = !DILocation(line: 471, column: 27, scope: !46)
!77 = !DILocation(line: 472, column: 39, scope: !46)
!78 = !DILocation(line: 472, column: 25, scope: !46)
!79 = !DILocation(line: 473, column: 44, scope: !46)
!80 = !DILocation(line: 473, column: 49, scope: !46)
!81 = !DILocation(line: 474, column: 41, scope: !46)
!82 = !DILocation(line: 474, column: 46, scope: !46)
!83 = !DILocation(line: 475, column: 41, scope: !46)
!84 = !DILocation(line: 475, column: 46, scope: !46)
!85 = !DILocation(line: 476, column: 59, scope: !46)
!86 = !DILocation(line: 476, column: 64, scope: !46)
!87 = !DILocation(line: 476, column: 50, scope: !46)
!88 = !DILocation(line: 476, column: 129, scope: !46)
!89 = !DILocation(line: 476, column: 134, scope: !46)
!90 = !DILocation(line: 476, column: 120, scope: !46)
!91 = !DILocation(line: 476, column: 118, scope: !46)
!92 = !DILocation(line: 476, column: 112, scope: !46)
!93 = !DILocation(line: 476, column: 36, scope: !46)
!94 = !DILocation(line: 477, column: 59, scope: !46)
!95 = !DILocation(line: 477, column: 64, scope: !46)
!96 = !DILocation(line: 477, column: 50, scope: !46)
!97 = !DILocation(line: 477, column: 129, scope: !46)
!98 = !DILocation(line: 477, column: 134, scope: !46)
!99 = !DILocation(line: 477, column: 120, scope: !46)
!100 = !DILocation(line: 477, column: 118, scope: !46)
!101 = !DILocation(line: 477, column: 112, scope: !46)
!102 = !DILocation(line: 477, column: 36, scope: !46)
!103 = !DILocation(line: 479, column: 24, scope: !46)
!104 = !DILocation(line: 481, column: 21, scope: !46)
!105 = !DILocation(line: 481, column: 19, scope: !46)
!106 = !DILocation(line: 482, column: 21, scope: !46)
!107 = !DILocation(line: 482, column: 19, scope: !46)
!108 = !DILocation(line: 483, column: 21, scope: !46)
!109 = !DILocation(line: 483, column: 19, scope: !46)
!110 = !DILocation(line: 484, column: 20, scope: !46)
!111 = !DILocation(line: 484, column: 18, scope: !46)
!112 = !DILocation(line: 485, column: 20, scope: !46)
!113 = !DILocation(line: 485, column: 18, scope: !46)
!114 = !DILocation(line: 486, column: 22, scope: !46)
!115 = !DILocation(line: 486, column: 20, scope: !46)
!116 = !DILocation(line: 487, column: 27, scope: !46)
!117 = !DILocation(line: 487, column: 25, scope: !46)
!118 = !DILocation(line: 488, column: 25, scope: !46)
!119 = !DILocation(line: 488, column: 23, scope: !46)
!120 = !DILocation(line: 489, column: 31, scope: !46)
!121 = !DILocation(line: 489, column: 29, scope: !46)
!122 = !DILocation(line: 490, column: 28, scope: !46)
!123 = !DILocation(line: 490, column: 26, scope: !46)
!124 = !DILocation(line: 491, column: 28, scope: !46)
!125 = !DILocation(line: 491, column: 26, scope: !46)
!126 = !DILocation(line: 492, column: 37, scope: !46)
!127 = !DILocation(line: 492, column: 35, scope: !46)
!128 = !DILocation(line: 493, column: 37, scope: !46)
!129 = !DILocation(line: 493, column: 35, scope: !46)
!130 = !DILocation(line: 495, column: 5, scope: !46)
!131 = !DILocation(line: 501, column: 5, scope: !46)
!132 = !DILocation(line: 506, column: 5, scope: !46)
!133 = !DILocation(line: 521, column: 5, scope: !46)
!134 = !DILocation(line: 522, column: 16, scope: !46)
!135 = !DILocation(line: 531, column: 5, scope: !46)
!136 = !DILocation(line: 460, column: 1, scope: !46)
!137 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_memcpyd2h", linkageName: "sys_mod.sys_mod.f_memcpyd2h", scope: null, file: !27, line: 556, type: !5, scopeLine: 556, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!138 = !DILocation(line: 568, column: 5, scope: !139)
!139 = !DILexicalBlockFile(scope: !137, file: !27, discriminator: 0)
!140 = !DILocation(line: 567, column: 5, scope: !139)
!141 = !DILocation(line: 566, column: 5, scope: !139)
!142 = !DILocation(line: 565, column: 5, scope: !139)
!143 = !DILocation(line: 564, column: 5, scope: !139)
!144 = !DILocation(line: 563, column: 5, scope: !139)
!145 = !DILocation(line: 562, column: 5, scope: !139)
!146 = !DILocation(line: 561, column: 5, scope: !139)
!147 = !DILocation(line: 559, column: 5, scope: !139)
!148 = !DILocation(line: 558, column: 20, scope: !139)
!149 = !DILocation(line: 558, column: 32, scope: !139)
!150 = !DILocation(line: 558, column: 5, scope: !139)
!151 = !DILocation(line: 561, column: 33, scope: !139)
!152 = !DILocation(line: 561, column: 38, scope: !139)
!153 = !DILocation(line: 562, column: 34, scope: !139)
!154 = !DILocation(line: 562, column: 39, scope: !139)
!155 = !DILocation(line: 563, column: 34, scope: !139)
!156 = !DILocation(line: 563, column: 39, scope: !139)
!157 = !DILocation(line: 564, column: 33, scope: !139)
!158 = !DILocation(line: 564, column: 38, scope: !139)
!159 = !DILocation(line: 565, column: 33, scope: !139)
!160 = !DILocation(line: 565, column: 38, scope: !139)
!161 = !DILocation(line: 566, column: 35, scope: !139)
!162 = !DILocation(line: 566, column: 21, scope: !139)
!163 = !DILocation(line: 567, column: 41, scope: !139)
!164 = !DILocation(line: 567, column: 27, scope: !139)
!165 = !DILocation(line: 568, column: 39, scope: !139)
!166 = !DILocation(line: 568, column: 25, scope: !139)
!167 = !DILocation(line: 570, column: 24, scope: !139)
!168 = !DILocation(line: 573, column: 21, scope: !139)
!169 = !DILocation(line: 573, column: 19, scope: !139)
!170 = !DILocation(line: 574, column: 21, scope: !139)
!171 = !DILocation(line: 574, column: 19, scope: !139)
!172 = !DILocation(line: 575, column: 21, scope: !139)
!173 = !DILocation(line: 575, column: 19, scope: !139)
!174 = !DILocation(line: 576, column: 20, scope: !139)
!175 = !DILocation(line: 576, column: 18, scope: !139)
!176 = !DILocation(line: 577, column: 20, scope: !139)
!177 = !DILocation(line: 577, column: 18, scope: !139)
!178 = !DILocation(line: 578, column: 22, scope: !139)
!179 = !DILocation(line: 578, column: 20, scope: !139)
!180 = !DILocation(line: 579, column: 27, scope: !139)
!181 = !DILocation(line: 579, column: 25, scope: !139)
!182 = !DILocation(line: 580, column: 25, scope: !139)
!183 = !DILocation(line: 580, column: 23, scope: !139)
!184 = !DILocation(line: 582, column: 5, scope: !139)
!185 = !DILocation(line: 588, column: 59, scope: !139)
!186 = !DILocation(line: 588, column: 5, scope: !139)
!187 = !DILocation(line: 608, column: 5, scope: !139)
!188 = !DILocation(line: 609, column: 16, scope: !139)
!189 = !DILocation(line: 556, column: 1, scope: !139)
!190 = distinct !DISubprogram(name: "sys_mod.sys_mod.oq0_teardow_handler", linkageName: "sys_mod.sys_mod.oq0_teardow_handler", scope: null, file: !27, line: 631, type: !5, scopeLine: 631, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!191 = !DILocation(line: 632, column: 9, scope: !192)
!192 = !DILexicalBlockFile(scope: !190, file: !27, discriminator: 0)
!193 = !DILocation(line: 632, column: 5, scope: !192)
!194 = !DILocation(line: 634, column: 66, scope: !192)
!195 = !DILocation(line: 634, column: 9, scope: !192)
!196 = !DILocation(line: 636, column: 13, scope: !192)
!197 = !DILocation(line: 637, column: 13, scope: !192)
!198 = !DILocation(line: 638, column: 13, scope: !192)
!199 = !DILocation(line: 639, column: 13, scope: !192)
!200 = !DILocation(line: 640, column: 13, scope: !192)
!201 = !DILocation(line: 641, column: 13, scope: !192)
!202 = !DILocation(line: 642, column: 13, scope: !192)
!203 = !DILocation(line: 643, column: 13, scope: !192)
!204 = !DILocation(line: 644, column: 13, scope: !192)
!205 = !DILocation(line: 645, column: 13, scope: !192)
!206 = !DILocation(line: 646, column: 13, scope: !192)
!207 = !DILocation(line: 647, column: 13, scope: !192)
!208 = !DILocation(line: 648, column: 13, scope: !192)
!209 = !DILocation(line: 635, column: 9, scope: !192)
!210 = !DILocation(line: 652, column: 9, scope: !192)
!211 = !DILocation(line: 654, column: 13, scope: !192)
!212 = !DILocation(line: 655, column: 13, scope: !192)
!213 = !DILocation(line: 656, column: 13, scope: !192)
!214 = !DILocation(line: 657, column: 13, scope: !192)
!215 = !DILocation(line: 658, column: 13, scope: !192)
!216 = !DILocation(line: 659, column: 13, scope: !192)
!217 = !DILocation(line: 660, column: 13, scope: !192)
!218 = !DILocation(line: 661, column: 13, scope: !192)
!219 = !DILocation(line: 653, column: 9, scope: !192)
!220 = !DILocation(line: 664, column: 5, scope: !192)
!221 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_rpc", linkageName: "sys_mod.sys_mod.f_rpc", scope: null, file: !27, line: 694, type: !5, scopeLine: 694, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!222 = !DILocation(line: 694, column: 13, scope: !223)
!223 = !DILexicalBlockFile(scope: !221, file: !27, discriminator: 0)
!224 = !DILocation(line: 700, column: 5, scope: !223)
!225 = !DILocation(line: 706, column: 20, scope: !223)
!226 = !DILocation(line: 706, column: 32, scope: !223)
!227 = !DILocation(line: 706, column: 5, scope: !223)
!228 = !DILocation(line: 710, column: 5, scope: !223)
!229 = !DILocation(line: 712, column: 24, scope: !223)
!230 = !DILocation(line: 694, column: 1, scope: !223)
!231 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.stack_push", linkageName: "sys_mod.sys_mod.sys_mod.stack_push", scope: null, file: !232, line: 54, type: !5, scopeLine: 54, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!232 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/sys.csl", directory: "")
!233 = !DILocation(line: 60, column: 5, scope: !234)
!234 = !DILexicalBlockFile(scope: !231, file: !232, discriminator: 0)
!235 = !DILocation(line: 54, column: 16, scope: !234)
!236 = !DILocation(line: 59, column: 13, scope: !234)
!237 = !DILocation(line: 59, column: 24, scope: !234)
!238 = !DILocation(line: 59, column: 5, scope: !234)
!239 = !DILocation(line: 61, column: 25, scope: !234)
!240 = !DILocation(line: 61, column: 5, scope: !234)
!241 = !DILocation(line: 61, column: 11, scope: !234)
!242 = !DILocation(line: 61, column: 10, scope: !234)
!243 = !DILocation(line: 61, column: 23, scope: !234)
!244 = !DILocation(line: 62, column: 18, scope: !234)
!245 = !DILocation(line: 62, column: 29, scope: !234)
!246 = !DILocation(line: 62, column: 16, scope: !234)
!247 = !DILocation(line: 54, column: 1, scope: !234)
!248 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_push", linkageName: "sys_mod.sys_mod.sys_mod.f_push", scope: null, file: !232, line: 72, type: !5, scopeLine: 72, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!249 = !DILocation(line: 72, column: 25, scope: !250)
!250 = !DILexicalBlockFile(scope: !248, file: !232, discriminator: 0)
!251 = !DILocation(line: 72, column: 13, scope: !250)
!252 = !DILocation(line: 73, column: 16, scope: !250)
!253 = !DILocation(line: 73, column: 5, scope: !250)
!254 = !DILocation(line: 72, column: 1, scope: !250)
!255 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.block_cmd_stream", linkageName: "sys_mod.sys_mod.sys_mod.block_cmd_stream", scope: null, file: !232, line: 76, type: !5, scopeLine: 76, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!256 = !DILocation(line: 77, column: 5, scope: !257)
!257 = !DILexicalBlockFile(scope: !255, file: !232, discriminator: 0)
!258 = !DILocation(line: 76, column: 1, scope: !257)
!259 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.sys_mod.unblock_cmd_stream", scope: null, file: !232, line: 80, type: !5, scopeLine: 80, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!260 = !DILocation(line: 81, column: 5, scope: !261)
!261 = !DILexicalBlockFile(scope: !259, file: !232, discriminator: 0)
!262 = !DILocation(line: 80, column: 1, scope: !261)
!263 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_sys_exit", linkageName: "sys_mod.sys_mod.sys_mod.f_sys_exit", scope: null, file: !232, line: 85, type: !5, scopeLine: 85, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!264 = !DILocation(line: 86, column: 5, scope: !265)
!265 = !DILexicalBlockFile(scope: !263, file: !232, discriminator: 0)
!266 = !DILocation(line: 87, column: 5, scope: !265)
!267 = !DILocation(line: 85, column: 1, scope: !265)
!268 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore", linkageName: "sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore", scope: null, file: !232, line: 90, type: !5, scopeLine: 90, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!269 = !DILocation(line: 90, column: 30, scope: !270)
!270 = !DILexicalBlockFile(scope: !268, file: !232, discriminator: 0)
!271 = !DILocation(line: 90, column: 1, scope: !270)
!272 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord", scope: null, file: !273, line: 131, type: !5, scopeLine: 131, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!273 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpyh2d.csl", directory: "")
!274 = !DILocation(line: 132, column: 12, scope: !275)
!275 = !DILexicalBlockFile(scope: !272, file: !273, discriminator: 0)
!276 = !DILocation(line: 132, column: 5, scope: !275)
!277 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord", scope: null, file: !273, line: 134, type: !5, scopeLine: 134, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!278 = !DILocation(line: 135, column: 12, scope: !279)
!279 = !DILexicalBlockFile(scope: !277, file: !273, discriminator: 0)
!280 = !DILocation(line: 135, column: 5, scope: !279)
!281 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval", scope: null, file: !273, line: 148, type: !5, scopeLine: 148, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!282 = !DILocation(line: 148, column: 23, scope: !283)
!283 = !DILexicalBlockFile(scope: !281, file: !273, discriminator: 0)
!284 = !DILocation(line: 149, column: 9, scope: !283)
!285 = !DILocation(line: 149, column: 20, scope: !283)
!286 = !DILocation(line: 149, column: 5, scope: !283)
!287 = !DILocation(line: 152, column: 23, scope: !283)
!288 = !DILocation(line: 152, column: 20, scope: !283)
!289 = !DILocation(line: 152, column: 9, scope: !283)
!290 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start", scope: null, file: !273, line: 226, type: !5, scopeLine: 226, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!291 = !DILocation(line: 233, column: 5, scope: !292)
!292 = !DILexicalBlockFile(scope: !290, file: !273, discriminator: 0)
!293 = !DILocation(line: 226, column: 49, scope: !292)
!294 = !DILocation(line: 226, column: 32, scope: !292)
!295 = !DILocation(line: 226, column: 21, scope: !292)
!296 = !DILocation(line: 229, column: 37, scope: !292)
!297 = !DILocation(line: 229, column: 52, scope: !292)
!298 = !DILocation(line: 229, column: 19, scope: !292)
!299 = !DILocation(line: 233, column: 71, scope: !292)
!300 = !DILocation(line: 233, column: 55, scope: !292)
!301 = !DILocation(line: 233, column: 25, scope: !292)
!302 = !DILocation(line: 235, column: 37, scope: !292)
!303 = !DILocation(line: 235, column: 52, scope: !292)
!304 = !DILocation(line: 235, column: 19, scope: !292)
!305 = !DILocation(line: 236, column: 28, scope: !292)
!306 = !DILocation(line: 236, column: 5, scope: !292)
!307 = !DILocation(line: 237, column: 28, scope: !292)
!308 = !DILocation(line: 237, column: 5, scope: !292)
!309 = !DILocation(line: 238, column: 13, scope: !292)
!310 = !DILocation(line: 238, column: 11, scope: !292)
!311 = !DILocation(line: 238, column: 5, scope: !292)
!312 = !DILocation(line: 239, column: 9, scope: !292)
!313 = !DILocation(line: 241, column: 9, scope: !292)
!314 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream", scope: null, file: !273, line: 249, type: !5, scopeLine: 249, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!315 = !DILocation(line: 250, column: 5, scope: !316)
!316 = !DILexicalBlockFile(scope: !314, file: !273, discriminator: 0)
!317 = !DILocation(line: 249, column: 1, scope: !316)
!318 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure", scope: null, file: !273, line: 276, type: !5, scopeLine: 276, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!319 = !DILocation(line: 414, column: 13, scope: !320)
!320 = !DILexicalBlockFile(scope: !318, file: !273, discriminator: 0)
!321 = !DILocation(line: 413, column: 13, scope: !320)
!322 = !DILocation(line: 400, column: 17, scope: !320)
!323 = !DILocation(line: 340, column: 9, scope: !320)
!324 = !DILocation(line: 339, column: 9, scope: !320)
!325 = !DILocation(line: 337, column: 5, scope: !320)
!326 = !DILocation(line: 319, column: 9, scope: !320)
!327 = !DILocation(line: 318, column: 9, scope: !320)
!328 = !DILocation(line: 315, column: 5, scope: !320)
!329 = !DILocation(line: 292, column: 5, scope: !320)
!330 = !DILocation(line: 291, column: 5, scope: !320)
!331 = !DILocation(line: 289, column: 5, scope: !320)
!332 = !DILocation(line: 288, column: 5, scope: !320)
!333 = !DILocation(line: 287, column: 5, scope: !320)
!334 = !DILocation(line: 286, column: 5, scope: !320)
!335 = !DILocation(line: 285, column: 5, scope: !320)
!336 = !DILocation(line: 284, column: 5, scope: !320)
!337 = !DILocation(line: 283, column: 5, scope: !320)
!338 = !DILocation(line: 282, column: 5, scope: !320)
!339 = !DILocation(line: 281, column: 5, scope: !320)
!340 = !DILocation(line: 280, column: 5, scope: !320)
!341 = !DILocation(line: 279, column: 5, scope: !320)
!342 = !DILocation(line: 278, column: 5, scope: !320)
!343 = !DILocation(line: 277, column: 5, scope: !320)
!344 = !DILocation(line: 291, column: 26, scope: !320)
!345 = !DILocation(line: 292, column: 26, scope: !320)
!346 = !DILocation(line: 315, column: 25, scope: !320)
!347 = !DILocation(line: 315, column: 31, scope: !320)
!348 = !DILocation(line: 315, column: 29, scope: !320)
!349 = !DILocation(line: 316, column: 20, scope: !320)
!350 = !DILocation(line: 316, column: 18, scope: !320)
!351 = !DILocation(line: 317, column: 52, scope: !320)
!352 = !DILocation(line: 317, column: 49, scope: !320)
!353 = !DILocation(line: 317, column: 5, scope: !320)
!354 = !DILocation(line: 318, column: 42, scope: !320)
!355 = !DILocation(line: 318, column: 33, scope: !320)
!356 = !DILocation(line: 318, column: 49, scope: !320)
!357 = !DILocation(line: 318, column: 48, scope: !320)
!358 = !DILocation(line: 318, column: 24, scope: !320)
!359 = !DILocation(line: 319, column: 24, scope: !320)
!360 = !DILocation(line: 319, column: 32, scope: !320)
!361 = !DILocation(line: 319, column: 36, scope: !320)
!362 = !DILocation(line: 319, column: 34, scope: !320)
!363 = !DILocation(line: 319, column: 30, scope: !320)
!364 = !DILocation(line: 320, column: 18, scope: !320)
!365 = !DILocation(line: 320, column: 15, scope: !320)
!366 = !DILocation(line: 320, column: 9, scope: !320)
!367 = !DILocation(line: 321, column: 26, scope: !320)
!368 = !DILocation(line: 325, column: 28, scope: !320)
!369 = !DILocation(line: 325, column: 26, scope: !320)
!370 = !DILocation(line: 331, column: 9, scope: !320)
!371 = !DILocation(line: 331, column: 15, scope: !320)
!372 = !DILocation(line: 331, column: 5, scope: !320)
!373 = !DILocation(line: 332, column: 22, scope: !320)
!374 = !DILocation(line: 334, column: 9, scope: !320)
!375 = !DILocation(line: 334, column: 18, scope: !320)
!376 = !DILocation(line: 334, column: 15, scope: !320)
!377 = !DILocation(line: 334, column: 5, scope: !320)
!378 = !DILocation(line: 335, column: 22, scope: !320)
!379 = !DILocation(line: 338, column: 52, scope: !320)
!380 = !DILocation(line: 338, column: 49, scope: !320)
!381 = !DILocation(line: 338, column: 5, scope: !320)
!382 = !DILocation(line: 339, column: 42, scope: !320)
!383 = !DILocation(line: 339, column: 48, scope: !320)
!384 = !DILocation(line: 339, column: 46, scope: !320)
!385 = !DILocation(line: 339, column: 33, scope: !320)
!386 = !DILocation(line: 339, column: 52, scope: !320)
!387 = !DILocation(line: 339, column: 51, scope: !320)
!388 = !DILocation(line: 339, column: 24, scope: !320)
!389 = !DILocation(line: 340, column: 25, scope: !320)
!390 = !DILocation(line: 340, column: 31, scope: !320)
!391 = !DILocation(line: 340, column: 29, scope: !320)
!392 = !DILocation(line: 340, column: 37, scope: !320)
!393 = !DILocation(line: 340, column: 41, scope: !320)
!394 = !DILocation(line: 340, column: 39, scope: !320)
!395 = !DILocation(line: 340, column: 35, scope: !320)
!396 = !DILocation(line: 341, column: 18, scope: !320)
!397 = !DILocation(line: 341, column: 15, scope: !320)
!398 = !DILocation(line: 341, column: 9, scope: !320)
!399 = !DILocation(line: 342, column: 26, scope: !320)
!400 = !DILocation(line: 347, column: 10, scope: !320)
!401 = !DILocation(line: 347, column: 16, scope: !320)
!402 = !DILocation(line: 347, column: 14, scope: !320)
!403 = !DILocation(line: 347, column: 5, scope: !320)
!404 = !DILocation(line: 348, column: 22, scope: !320)
!405 = !DILocation(line: 350, column: 10, scope: !320)
!406 = !DILocation(line: 350, column: 18, scope: !320)
!407 = !DILocation(line: 350, column: 21, scope: !320)
!408 = !DILocation(line: 350, column: 20, scope: !320)
!409 = !DILocation(line: 350, column: 14, scope: !320)
!410 = !DILocation(line: 350, column: 5, scope: !320)
!411 = !DILocation(line: 351, column: 22, scope: !320)
!412 = !DILocation(line: 354, column: 9, scope: !320)
!413 = !DILocation(line: 354, column: 5, scope: !320)
!414 = !DILocation(line: 358, column: 9, scope: !320)
!415 = !DILocation(line: 361, column: 9, scope: !320)
!416 = !DILocation(line: 364, column: 20, scope: !320)
!417 = !DILocation(line: 364, column: 17, scope: !320)
!418 = !DILocation(line: 364, column: 9, scope: !320)
!419 = !DILocation(line: 368, column: 13, scope: !320)
!420 = !DILocation(line: 371, column: 13, scope: !320)
!421 = !DILocation(line: 375, column: 13, scope: !320)
!422 = !DILocation(line: 394, column: 13, scope: !320)
!423 = !DILocation(line: 396, column: 29, scope: !320)
!424 = !DILocation(line: 396, column: 27, scope: !320)
!425 = !DILocation(line: 397, column: 60, scope: !320)
!426 = !DILocation(line: 397, column: 57, scope: !320)
!427 = !DILocation(line: 397, column: 13, scope: !320)
!428 = !DILocation(line: 400, column: 54, scope: !320)
!429 = !DILocation(line: 400, column: 55, scope: !320)
!430 = !DILocation(line: 400, column: 46, scope: !320)
!431 = !DILocation(line: 400, column: 59, scope: !320)
!432 = !DILocation(line: 400, column: 58, scope: !320)
!433 = !DILocation(line: 400, column: 37, scope: !320)
!434 = !DILocation(line: 400, column: 35, scope: !320)
!435 = !DILocation(line: 401, column: 33, scope: !320)
!436 = !DILocation(line: 401, column: 31, scope: !320)
!437 = !DILocation(line: 402, column: 69, scope: !320)
!438 = !DILocation(line: 402, column: 66, scope: !320)
!439 = !DILocation(line: 402, column: 19, scope: !320)
!440 = !DILocation(line: 404, column: 31, scope: !320)
!441 = !DILocation(line: 408, column: 75, scope: !320)
!442 = !DILocation(line: 408, column: 88, scope: !320)
!443 = !DILocation(line: 408, column: 13, scope: !320)
!444 = !DILocation(line: 413, column: 31, scope: !320)
!445 = !DILocation(line: 414, column: 33, scope: !320)
!446 = !DILocation(line: 415, column: 21, scope: !320)
!447 = !DILocation(line: 415, column: 29, scope: !320)
!448 = !DILocation(line: 415, column: 27, scope: !320)
!449 = !DILocation(line: 415, column: 19, scope: !320)
!450 = !DILocation(line: 416, column: 22, scope: !320)
!451 = !DILocation(line: 416, column: 19, scope: !320)
!452 = !DILocation(line: 416, column: 13, scope: !320)
!453 = !DILocation(line: 417, column: 23, scope: !320)
!454 = !DILocation(line: 419, column: 63, scope: !320)
!455 = !DILocation(line: 419, column: 60, scope: !320)
!456 = !DILocation(line: 419, column: 13, scope: !320)
!457 = !DILocation(line: 421, column: 23, scope: !320)
!458 = !DILocation(line: 423, column: 69, scope: !320)
!459 = !DILocation(line: 423, column: 13, scope: !320)
!460 = !DILocation(line: 426, column: 13, scope: !320)
!461 = !DILocation(line: 430, column: 13, scope: !320)
!462 = !DILocation(line: 433, column: 48, scope: !320)
!463 = !DILocation(line: 433, column: 22, scope: !320)
!464 = !DILocation(line: 433, column: 19, scope: !320)
!465 = !DILocation(line: 433, column: 13, scope: !320)
!466 = !DILocation(line: 436, column: 34, scope: !320)
!467 = !DILocation(line: 436, column: 39, scope: !320)
!468 = !DILocation(line: 436, column: 50, scope: !320)
!469 = !DILocation(line: 436, column: 17, scope: !320)
!470 = !DILocation(line: 452, column: 49, scope: !320)
!471 = !DILocation(line: 452, column: 64, scope: !320)
!472 = !DILocation(line: 452, column: 31, scope: !320)
!473 = !DILocation(line: 453, column: 40, scope: !320)
!474 = !DILocation(line: 453, column: 17, scope: !320)
!475 = !DILocation(line: 454, column: 50, scope: !320)
!476 = !DILocation(line: 454, column: 66, scope: !320)
!477 = !DILocation(line: 454, column: 32, scope: !320)
!478 = !DILocation(line: 455, column: 40, scope: !320)
!479 = !DILocation(line: 455, column: 17, scope: !320)
!480 = !DILocation(line: 456, column: 17, scope: !320)
!481 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit", scope: null, file: !482, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!482 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/filters/wse3.csl", directory: "")
!483 = !DILocation(line: 24, column: 3, scope: !484)
!484 = !DILexicalBlockFile(scope: !481, file: !482, discriminator: 0)
!485 = !DILocation(line: 24, column: 22, scope: !484)
!486 = !DILocation(line: 23, column: 3, scope: !484)
!487 = !DILocation(line: 22, column: 3, scope: !484)
!488 = !DILocation(line: 20, column: 37, scope: !484)
!489 = !DILocation(line: 20, column: 21, scope: !484)
!490 = !DILocation(line: 21, column: 11, scope: !484)
!491 = !DILocation(line: 21, column: 17, scope: !484)
!492 = !DILocation(line: 21, column: 3, scope: !484)
!493 = !DILocation(line: 22, column: 24, scope: !484)
!494 = !DILocation(line: 22, column: 30, scope: !484)
!495 = !DILocation(line: 23, column: 40, scope: !484)
!496 = !DILocation(line: 23, column: 22, scope: !484)
!497 = !DILocation(line: 23, column: 67, scope: !484)
!498 = !DILocation(line: 24, column: 26, scope: !484)
!499 = !DILocation(line: 24, column: 41, scope: !484)
!500 = !DILocation(line: 24, column: 39, scope: !484)
!501 = !DILocation(line: 24, column: 61, scope: !484)
!502 = !DILocation(line: 24, column: 76, scope: !484)
!503 = !DILocation(line: 24, column: 74, scope: !484)
!504 = !DILocation(line: 25, column: 21, scope: !484)
!505 = !DILocation(line: 25, column: 50, scope: !484)
!506 = !DILocation(line: 25, column: 3, scope: !484)
!507 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter", scope: null, file: !482, line: 30, type: !5, scopeLine: 30, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!508 = !DILocation(line: 30, column: 36, scope: !509)
!509 = !DILexicalBlockFile(scope: !507, file: !482, discriminator: 0)
!510 = !DILocation(line: 30, column: 20, scope: !509)
!511 = !DILocation(line: 31, column: 11, scope: !509)
!512 = !DILocation(line: 31, column: 23, scope: !509)
!513 = !DILocation(line: 31, column: 3, scope: !509)
!514 = !DILocation(line: 32, column: 21, scope: !509)
!515 = !DILocation(line: 32, column: 48, scope: !509)
!516 = !DILocation(line: 32, column: 60, scope: !509)
!517 = !DILocation(line: 32, column: 64, scope: !509)
!518 = !DILocation(line: 32, column: 3, scope: !509)
!519 = !DILocation(line: 30, column: 1, scope: !509)
!520 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter", scope: null, file: !482, line: 40, type: !5, scopeLine: 40, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!521 = !DILocation(line: 47, column: 3, scope: !522)
!522 = !DILexicalBlockFile(scope: !520, file: !482, discriminator: 0)
!523 = !DILocation(line: 48, column: 7, scope: !522)
!524 = !DILocation(line: 44, column: 3, scope: !522)
!525 = !DILocation(line: 43, column: 3, scope: !522)
!526 = !DILocation(line: 42, column: 3, scope: !522)
!527 = !DILocation(line: 40, column: 32, scope: !522)
!528 = !DILocation(line: 40, column: 16, scope: !522)
!529 = !DILocation(line: 41, column: 11, scope: !522)
!530 = !DILocation(line: 41, column: 19, scope: !522)
!531 = !DILocation(line: 41, column: 3, scope: !522)
!532 = !DILocation(line: 42, column: 40, scope: !522)
!533 = !DILocation(line: 42, column: 22, scope: !522)
!534 = !DILocation(line: 43, column: 26, scope: !522)
!535 = !DILocation(line: 43, column: 34, scope: !522)
!536 = !DILocation(line: 44, column: 25, scope: !522)
!537 = !DILocation(line: 44, column: 42, scope: !522)
!538 = !DILocation(line: 44, column: 40, scope: !522)
!539 = !DILocation(line: 45, column: 21, scope: !522)
!540 = !DILocation(line: 46, column: 35, scope: !522)
!541 = !DILocation(line: 46, column: 21, scope: !522)
!542 = !DILocation(line: 46, column: 50, scope: !522)
!543 = !DILocation(line: 45, column: 3, scope: !522)
!544 = !DILocation(line: 48, column: 11, scope: !522)
!545 = !DILocation(line: 48, column: 26, scope: !522)
!546 = !DILocation(line: 48, column: 43, scope: !522)
!547 = !DILocation(line: 48, column: 41, scope: !522)
!548 = !DILocation(line: 48, column: 54, scope: !522)
!549 = !DILocation(line: 48, column: 63, scope: !522)
!550 = !DILocation(line: 49, column: 21, scope: !522)
!551 = !DILocation(line: 49, column: 47, scope: !522)
!552 = !DILocation(line: 49, column: 3, scope: !522)
!553 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config", scope: null, file: !554, line: 33, type: !5, scopeLine: 33, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!554 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/filters/common.csl", directory: "")
!555 = !DILocation(line: 33, column: 46, scope: !556)
!556 = !DILexicalBlockFile(scope: !553, file: !554, discriminator: 0)
!557 = !DILocation(line: 33, column: 31, scope: !556)
!558 = !DILocation(line: 33, column: 15, scope: !556)
!559 = !DILocation(line: 34, column: 24, scope: !556)
!560 = !DILocation(line: 34, column: 23, scope: !556)
!561 = !DILocation(line: 34, column: 51, scope: !556)
!562 = !DILocation(line: 34, column: 35, scope: !556)
!563 = !DILocation(line: 34, column: 60, scope: !556)
!564 = !DILocation(line: 34, column: 73, scope: !556)
!565 = !DILocation(line: 34, column: 3, scope: !556)
!566 = !DILocation(line: 33, column: 1, scope: !556)
!567 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config", scope: null, file: !554, line: 38, type: !5, scopeLine: 38, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!568 = !DILocation(line: 38, column: 31, scope: !569)
!569 = !DILexicalBlockFile(scope: !567, file: !554, discriminator: 0)
!570 = !DILocation(line: 38, column: 15, scope: !569)
!571 = !DILocation(line: 39, column: 31, scope: !569)
!572 = !DILocation(line: 39, column: 30, scope: !569)
!573 = !DILocation(line: 39, column: 58, scope: !569)
!574 = !DILocation(line: 39, column: 42, scope: !569)
!575 = !DILocation(line: 39, column: 67, scope: !569)
!576 = !DILocation(line: 39, column: 10, scope: !569)
!577 = !DILocation(line: 39, column: 3, scope: !569)
!578 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit", scope: null, file: !579, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!579 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/teardown.csl", directory: "")
!580 = !DILocation(line: 43, column: 3, scope: !581)
!581 = !DILexicalBlockFile(scope: !578, file: !579, discriminator: 0)
!582 = !DILocation(line: 41, column: 3, scope: !581)
!583 = !DILocation(line: 40, column: 3, scope: !581)
!584 = !DILocation(line: 39, column: 9, scope: !581)
!585 = !DILocation(line: 40, column: 23, scope: !581)
!586 = !DILocation(line: 41, column: 70, scope: !581)
!587 = !DILocation(line: 41, column: 68, scope: !581)
!588 = !DILocation(line: 43, column: 27, scope: !581)
!589 = !DILocation(line: 43, column: 15, scope: !581)
!590 = !DILocation(line: 44, column: 15, scope: !581)
!591 = !DILocation(line: 44, column: 21, scope: !581)
!592 = !DILocation(line: 44, column: 27, scope: !581)
!593 = !DILocation(line: 44, column: 3, scope: !581)
!594 = !DILocation(line: 39, column: 1, scope: !581)
!595 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord", scope: null, file: !596, line: 4, type: !5, scopeLine: 4, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!596 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/layout.csl", directory: "")
!597 = !DILocation(line: 5, column: 10, scope: !598)
!598 = !DILexicalBlockFile(scope: !595, file: !596, discriminator: 0)
!599 = !DILocation(line: 5, column: 67, scope: !598)
!600 = !DILocation(line: 5, column: 3, scope: !598)
!601 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord", scope: null, file: !596, line: 8, type: !5, scopeLine: 8, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!602 = !DILocation(line: 9, column: 10, scope: !603)
!603 = !DILexicalBlockFile(scope: !601, file: !596, discriminator: 0)
!604 = !DILocation(line: 9, column: 67, scope: !603)
!605 = !DILocation(line: 9, column: 3, scope: !603)
!606 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord", scope: null, file: !607, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!607 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config.csl", directory: "")
!608 = !DILocation(line: 50, column: 3, scope: !609)
!609 = !DILexicalBlockFile(scope: !606, file: !607, discriminator: 0)
!610 = !DILocation(line: 43, column: 21, scope: !609)
!611 = !DILocation(line: 50, column: 57, scope: !609)
!612 = !DILocation(line: 50, column: 68, scope: !609)
!613 = !DILocation(line: 50, column: 41, scope: !609)
!614 = !DILocation(line: 50, column: 19, scope: !609)
!615 = !DILocation(line: 52, column: 10, scope: !609)
!616 = !DILocation(line: 52, column: 18, scope: !609)
!617 = !DILocation(line: 48, column: 22, scope: !609)
!618 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.get_x_coord", scope: null, file: !619, line: 171, type: !5, scopeLine: 171, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!619 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpyd2h.csl", directory: "")
!620 = !DILocation(line: 172, column: 12, scope: !621)
!621 = !DILexicalBlockFile(scope: !618, file: !619, discriminator: 0)
!622 = !DILocation(line: 172, column: 5, scope: !621)
!623 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.get_y_coord", scope: null, file: !619, line: 174, type: !5, scopeLine: 174, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!624 = !DILocation(line: 175, column: 12, scope: !625)
!625 = !DILexicalBlockFile(scope: !623, file: !619, discriminator: 0)
!626 = !DILocation(line: 175, column: 5, scope: !625)
!627 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval", scope: null, file: !619, line: 187, type: !5, scopeLine: 187, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!628 = !DILocation(line: 187, column: 23, scope: !629)
!629 = !DILexicalBlockFile(scope: !627, file: !619, discriminator: 0)
!630 = !DILocation(line: 188, column: 9, scope: !629)
!631 = !DILocation(line: 188, column: 20, scope: !629)
!632 = !DILocation(line: 188, column: 5, scope: !629)
!633 = !DILocation(line: 191, column: 23, scope: !629)
!634 = !DILocation(line: 191, column: 20, scope: !629)
!635 = !DILocation(line: 191, column: 9, scope: !629)
!636 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start", scope: null, file: !619, line: 383, type: !5, scopeLine: 383, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!637 = !DILocation(line: 386, column: 5, scope: !638)
!638 = !DILexicalBlockFile(scope: !636, file: !619, discriminator: 0)
!639 = !DILocation(line: 384, column: 72, scope: !638)
!640 = !DILocation(line: 384, column: 59, scope: !638)
!641 = !DILocation(line: 384, column: 46, scope: !638)
!642 = !DILocation(line: 384, column: 33, scope: !638)
!643 = !DILocation(line: 384, column: 19, scope: !638)
!644 = !DILocation(line: 384, column: 5, scope: !638)
!645 = !DILocation(line: 383, column: 32, scope: !638)
!646 = !DILocation(line: 383, column: 21, scope: !638)
!647 = !DILocation(line: 386, column: 26, scope: !638)
!648 = !DILocation(line: 388, column: 28, scope: !638)
!649 = !DILocation(line: 388, column: 17, scope: !638)
!650 = !DILocation(line: 389, column: 25, scope: !638)
!651 = !DILocation(line: 389, column: 23, scope: !638)
!652 = !DILocation(line: 391, column: 38, scope: !638)
!653 = !DILocation(line: 391, column: 20, scope: !638)
!654 = !DILocation(line: 391, column: 18, scope: !638)
!655 = !DILocation(line: 393, column: 7, scope: !638)
!656 = !DILocation(line: 395, column: 17, scope: !638)
!657 = !DILocation(line: 395, column: 15, scope: !638)
!658 = !DILocation(line: 397, column: 15, scope: !638)
!659 = !DILocation(line: 397, column: 13, scope: !638)
!660 = !DILocation(line: 398, column: 15, scope: !638)
!661 = !DILocation(line: 398, column: 25, scope: !638)
!662 = !DILocation(line: 398, column: 23, scope: !638)
!663 = !DILocation(line: 398, column: 31, scope: !638)
!664 = !DILocation(line: 398, column: 13, scope: !638)
!665 = !DILocation(line: 401, column: 10, scope: !638)
!666 = !DILocation(line: 401, column: 17, scope: !638)
!667 = !DILocation(line: 401, column: 14, scope: !638)
!668 = !DILocation(line: 401, column: 5, scope: !638)
!669 = !DILocation(line: 403, column: 48, scope: !638)
!670 = !DILocation(line: 403, column: 26, scope: !638)
!671 = !DILocation(line: 404, column: 26, scope: !638)
!672 = !DILocation(line: 404, column: 18, scope: !638)
!673 = !DILocation(line: 407, column: 48, scope: !638)
!674 = !DILocation(line: 407, column: 26, scope: !638)
!675 = !DILocation(line: 408, column: 27, scope: !638)
!676 = !DILocation(line: 408, column: 18, scope: !638)
!677 = !DILocation(line: 411, column: 14, scope: !638)
!678 = !DILocation(line: 414, column: 14, scope: !638)
!679 = !DILocation(line: 414, column: 11, scope: !638)
!680 = !DILocation(line: 414, column: 5, scope: !638)
!681 = !DILocation(line: 416, column: 44, scope: !638)
!682 = !DILocation(line: 416, column: 75, scope: !638)
!683 = !DILocation(line: 416, column: 59, scope: !638)
!684 = !DILocation(line: 416, column: 25, scope: !638)
!685 = !DILocation(line: 416, column: 23, scope: !638)
!686 = !DILocation(line: 418, column: 41, scope: !638)
!687 = !DILocation(line: 418, column: 23, scope: !638)
!688 = !DILocation(line: 419, column: 9, scope: !638)
!689 = !DILocation(line: 425, column: 44, scope: !638)
!690 = !DILocation(line: 425, column: 23, scope: !638)
!691 = !DILocation(line: 426, column: 41, scope: !638)
!692 = !DILocation(line: 426, column: 23, scope: !638)
!693 = !DILocation(line: 427, column: 9, scope: !638)
!694 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x", scope: null, file: !619, line: 448, type: !5, scopeLine: 448, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!695 = !DILocation(line: 448, column: 31, scope: !696)
!696 = !DILexicalBlockFile(scope: !694, file: !619, discriminator: 0)
!697 = !DILocation(line: 453, column: 5, scope: !696)
!698 = !DILocation(line: 456, column: 19, scope: !696)
!699 = !DILocation(line: 456, column: 17, scope: !696)
!700 = !DILocation(line: 461, column: 5, scope: !696)
!701 = !DILocation(line: 462, column: 28, scope: !696)
!702 = !DILocation(line: 462, column: 5, scope: !696)
!703 = !DILocation(line: 463, column: 5, scope: !696)
!704 = !DILocation(line: 464, column: 9, scope: !696)
!705 = !DILocation(line: 464, column: 10, scope: !696)
!706 = !DILocation(line: 464, column: 7, scope: !696)
!707 = !DILocation(line: 448, column: 1, scope: !696)
!708 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_send_data", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_send_data", scope: null, file: !619, line: 476, type: !5, scopeLine: 476, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!709 = !DILocation(line: 494, column: 9, scope: !710)
!710 = !DILexicalBlockFile(scope: !708, file: !619, discriminator: 0)
!711 = !DILocation(line: 478, column: 9, scope: !710)
!712 = !DILocation(line: 478, column: 13, scope: !710)
!713 = !DILocation(line: 478, column: 11, scope: !710)
!714 = !DILocation(line: 478, column: 5, scope: !710)
!715 = !DILocation(line: 479, column: 9, scope: !710)
!716 = !DILocation(line: 480, column: 32, scope: !710)
!717 = !DILocation(line: 480, column: 9, scope: !710)
!718 = !DILocation(line: 481, column: 17, scope: !710)
!719 = !DILocation(line: 481, column: 15, scope: !710)
!720 = !DILocation(line: 481, column: 9, scope: !710)
!721 = !DILocation(line: 482, column: 13, scope: !710)
!722 = !DILocation(line: 483, column: 51, scope: !710)
!723 = !DILocation(line: 483, column: 29, scope: !710)
!724 = !DILocation(line: 483, column: 27, scope: !710)
!725 = !DILocation(line: 485, column: 13, scope: !710)
!726 = !DILocation(line: 486, column: 51, scope: !710)
!727 = !DILocation(line: 486, column: 29, scope: !710)
!728 = !DILocation(line: 486, column: 27, scope: !710)
!729 = !DILocation(line: 488, column: 13, scope: !710)
!730 = !DILocation(line: 488, column: 14, scope: !710)
!731 = !DILocation(line: 488, column: 11, scope: !710)
!732 = !DILocation(line: 494, column: 30, scope: !710)
!733 = !DILocation(line: 496, column: 14, scope: !710)
!734 = !DILocation(line: 496, column: 25, scope: !710)
!735 = !DILocation(line: 496, column: 22, scope: !710)
!736 = !DILocation(line: 496, column: 9, scope: !710)
!737 = !DILocation(line: 497, column: 13, scope: !710)
!738 = !DILocation(line: 498, column: 13, scope: !710)
!739 = !DILocation(line: 499, column: 13, scope: !710)
!740 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl", scope: null, file: !619, line: 505, type: !5, scopeLine: 505, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!741 = !DILocation(line: 524, column: 13, scope: !742)
!742 = !DILexicalBlockFile(scope: !740, file: !619, discriminator: 0)
!743 = !DILocation(line: 506, column: 14, scope: !742)
!744 = !DILocation(line: 506, column: 11, scope: !742)
!745 = !DILocation(line: 506, column: 5, scope: !742)
!746 = !DILocation(line: 508, column: 9, scope: !742)
!747 = !DILocation(line: 509, column: 32, scope: !742)
!748 = !DILocation(line: 509, column: 9, scope: !742)
!749 = !DILocation(line: 510, column: 9, scope: !742)
!750 = !DILocation(line: 514, column: 13, scope: !742)
!751 = !DILocation(line: 514, column: 17, scope: !742)
!752 = !DILocation(line: 514, column: 15, scope: !742)
!753 = !DILocation(line: 514, column: 9, scope: !742)
!754 = !DILocation(line: 518, column: 13, scope: !742)
!755 = !DILocation(line: 519, column: 36, scope: !742)
!756 = !DILocation(line: 519, column: 13, scope: !742)
!757 = !DILocation(line: 520, column: 13, scope: !742)
!758 = !DILocation(line: 524, column: 34, scope: !742)
!759 = !DILocation(line: 526, column: 18, scope: !742)
!760 = !DILocation(line: 526, column: 29, scope: !742)
!761 = !DILocation(line: 526, column: 26, scope: !742)
!762 = !DILocation(line: 526, column: 13, scope: !742)
!763 = !DILocation(line: 529, column: 17, scope: !742)
!764 = !DILocation(line: 530, column: 17, scope: !742)
!765 = !DILocation(line: 531, column: 17, scope: !742)
!766 = !DILocation(line: 534, column: 17, scope: !742)
!767 = !DILocation(line: 535, column: 40, scope: !742)
!768 = !DILocation(line: 535, column: 17, scope: !742)
!769 = !DILocation(line: 536, column: 17, scope: !742)
!770 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.d2h_configure", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.d2h_configure", scope: null, file: !619, line: 593, type: !5, scopeLine: 593, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!771 = !DILocation(line: 617, column: 26, scope: !772)
!772 = !DILexicalBlockFile(scope: !770, file: !619, discriminator: 0)
!773 = !DILocation(line: 612, column: 47, scope: !772)
!774 = !DILocation(line: 612, column: 27, scope: !772)
!775 = !DILocation(line: 602, column: 5, scope: !772)
!776 = !DILocation(line: 601, column: 5, scope: !772)
!777 = !DILocation(line: 599, column: 5, scope: !772)
!778 = !DILocation(line: 598, column: 5, scope: !772)
!779 = !DILocation(line: 596, column: 5, scope: !772)
!780 = !DILocation(line: 595, column: 5, scope: !772)
!781 = !DILocation(line: 593, column: 86, scope: !772)
!782 = !DILocation(line: 593, column: 70, scope: !772)
!783 = !DILocation(line: 593, column: 60, scope: !772)
!784 = !DILocation(line: 593, column: 52, scope: !772)
!785 = !DILocation(line: 593, column: 44, scope: !772)
!786 = !DILocation(line: 593, column: 35, scope: !772)
!787 = !DILocation(line: 593, column: 26, scope: !772)
!788 = !DILocation(line: 593, column: 18, scope: !772)
!789 = !DILocation(line: 595, column: 26, scope: !772)
!790 = !DILocation(line: 596, column: 26, scope: !772)
!791 = !DILocation(line: 598, column: 23, scope: !772)
!792 = !DILocation(line: 599, column: 23, scope: !772)
!793 = !DILocation(line: 599, column: 28, scope: !772)
!794 = !DILocation(line: 599, column: 26, scope: !772)
!795 = !DILocation(line: 599, column: 29, scope: !772)
!796 = !DILocation(line: 601, column: 24, scope: !772)
!797 = !DILocation(line: 602, column: 24, scope: !772)
!798 = !DILocation(line: 602, column: 29, scope: !772)
!799 = !DILocation(line: 602, column: 27, scope: !772)
!800 = !DILocation(line: 602, column: 30, scope: !772)
!801 = !DILocation(line: 611, column: 20, scope: !772)
!802 = !DILocation(line: 612, column: 11, scope: !772)
!803 = !DILocation(line: 612, column: 18, scope: !772)
!804 = !DILocation(line: 612, column: 15, scope: !772)
!805 = !DILocation(line: 612, column: 32, scope: !772)
!806 = !DILocation(line: 612, column: 39, scope: !772)
!807 = !DILocation(line: 612, column: 36, scope: !772)
!808 = !DILocation(line: 612, column: 52, scope: !772)
!809 = !DILocation(line: 612, column: 59, scope: !772)
!810 = !DILocation(line: 612, column: 56, scope: !772)
!811 = !DILocation(line: 612, column: 5, scope: !772)
!812 = !DILocation(line: 613, column: 24, scope: !772)
!813 = !DILocation(line: 616, column: 15, scope: !772)
!814 = !DILocation(line: 617, column: 11, scope: !772)
!815 = !DILocation(line: 617, column: 18, scope: !772)
!816 = !DILocation(line: 617, column: 15, scope: !772)
!817 = !DILocation(line: 617, column: 30, scope: !772)
!818 = !DILocation(line: 617, column: 5, scope: !772)
!819 = !DILocation(line: 618, column: 19, scope: !772)
!820 = !DILocation(line: 621, column: 9, scope: !772)
!821 = !DILocation(line: 621, column: 5, scope: !772)
!822 = !DILocation(line: 627, column: 9, scope: !772)
!823 = !DILocation(line: 629, column: 13, scope: !772)
!824 = !DILocation(line: 629, column: 25, scope: !772)
!825 = !DILocation(line: 629, column: 21, scope: !772)
!826 = !DILocation(line: 629, column: 9, scope: !772)
!827 = !DILocation(line: 632, column: 13, scope: !772)
!828 = !DILocation(line: 636, column: 13, scope: !772)
!829 = !DILocation(line: 641, column: 9, scope: !772)
!830 = !DILocation(line: 646, column: 13, scope: !772)
!831 = !DILocation(line: 646, column: 9, scope: !772)
!832 = !DILocation(line: 647, column: 30, scope: !772)
!833 = !DILocation(line: 647, column: 35, scope: !772)
!834 = !DILocation(line: 647, column: 46, scope: !772)
!835 = !DILocation(line: 647, column: 50, scope: !772)
!836 = !DILocation(line: 647, column: 54, scope: !772)
!837 = !DILocation(line: 647, column: 57, scope: !772)
!838 = !DILocation(line: 647, column: 60, scope: !772)
!839 = !DILocation(line: 647, column: 63, scope: !772)
!840 = !DILocation(line: 647, column: 13, scope: !772)
!841 = !DILocation(line: 661, column: 9, scope: !772)
!842 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit", scope: null, file: !579, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!843 = !DILocation(line: 43, column: 3, scope: !844)
!844 = !DILexicalBlockFile(scope: !842, file: !579, discriminator: 0)
!845 = !DILocation(line: 41, column: 3, scope: !844)
!846 = !DILocation(line: 40, column: 3, scope: !844)
!847 = !DILocation(line: 39, column: 9, scope: !844)
!848 = !DILocation(line: 40, column: 23, scope: !844)
!849 = !DILocation(line: 41, column: 70, scope: !844)
!850 = !DILocation(line: 41, column: 68, scope: !844)
!851 = !DILocation(line: 43, column: 27, scope: !844)
!852 = !DILocation(line: 43, column: 15, scope: !844)
!853 = !DILocation(line: 44, column: 15, scope: !844)
!854 = !DILocation(line: 44, column: 21, scope: !844)
!855 = !DILocation(line: 44, column: 27, scope: !844)
!856 = !DILocation(line: 44, column: 3, scope: !844)
!857 = !DILocation(line: 39, column: 1, scope: !844)
!858 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord", scope: null, file: !596, line: 4, type: !5, scopeLine: 4, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!859 = !DILocation(line: 5, column: 10, scope: !860)
!860 = !DILexicalBlockFile(scope: !858, file: !596, discriminator: 0)
!861 = !DILocation(line: 5, column: 67, scope: !860)
!862 = !DILocation(line: 5, column: 3, scope: !860)
!863 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord", scope: null, file: !596, line: 8, type: !5, scopeLine: 8, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!864 = !DILocation(line: 9, column: 10, scope: !865)
!865 = !DILexicalBlockFile(scope: !863, file: !596, discriminator: 0)
!866 = !DILocation(line: 9, column: 67, scope: !865)
!867 = !DILocation(line: 9, column: 3, scope: !865)
!868 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord", scope: null, file: !607, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!869 = !DILocation(line: 50, column: 3, scope: !870)
!870 = !DILexicalBlockFile(scope: !868, file: !607, discriminator: 0)
!871 = !DILocation(line: 43, column: 21, scope: !870)
!872 = !DILocation(line: 50, column: 57, scope: !870)
!873 = !DILocation(line: 50, column: 68, scope: !870)
!874 = !DILocation(line: 50, column: 41, scope: !870)
!875 = !DILocation(line: 50, column: 19, scope: !870)
!876 = !DILocation(line: 52, column: 10, scope: !870)
!877 = !DILocation(line: 52, column: 18, scope: !870)
!878 = !DILocation(line: 48, column: 22, scope: !870)
!879 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr", linkageName: "sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr", scope: null, file: !880, line: 11, type: !5, scopeLine: 11, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!880 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/input_queue_config.csl", directory: "")
!881 = !DILocation(line: 11, column: 32, scope: !882)
!882 = !DILexicalBlockFile(scope: !879, file: !880, discriminator: 0)
!883 = !DILocation(line: 12, column: 80, scope: !882)
!884 = !DILocation(line: 12, column: 69, scope: !882)
!885 = !DILocation(line: 12, column: 39, scope: !882)
!886 = !DILocation(line: 12, column: 3, scope: !882)
!887 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue", linkageName: "sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue", scope: null, file: !880, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!888 = !DILocation(line: 46, column: 3, scope: !889)
!889 = !DILexicalBlockFile(scope: !887, file: !880, discriminator: 0)
!890 = !DILocation(line: 45, column: 3, scope: !889)
!891 = !DILocation(line: 39, column: 42, scope: !889)
!892 = !DILocation(line: 39, column: 34, scope: !889)
!893 = !DILocation(line: 39, column: 24, scope: !889)
!894 = !DILocation(line: 45, column: 44, scope: !889)
!895 = !DILocation(line: 45, column: 16, scope: !889)
!896 = !DILocation(line: 46, column: 30, scope: !889)
!897 = !DILocation(line: 46, column: 18, scope: !889)
!898 = !DILocation(line: 56, column: 9, scope: !889)
!899 = !DILocation(line: 56, column: 5, scope: !889)
!900 = !DILocation(line: 58, column: 13, scope: !889)
!901 = !DILocation(line: 58, column: 17, scope: !889)
!902 = !DILocation(line: 58, column: 11, scope: !889)
!903 = !DILocation(line: 61, column: 13, scope: !889)
!904 = !DILocation(line: 61, column: 17, scope: !889)
!905 = !DILocation(line: 61, column: 11, scope: !889)
!906 = !DILocation(line: 66, column: 9, scope: !889)
!907 = !DILocation(line: 66, column: 13, scope: !889)
!908 = !DILocation(line: 66, column: 7, scope: !889)
!909 = !DILocation(line: 68, column: 9, scope: !889)
!910 = !DILocation(line: 68, column: 24, scope: !889)
!911 = !DILocation(line: 68, column: 13, scope: !889)
!912 = !DILocation(line: 68, column: 7, scope: !889)
!913 = !DILocation(line: 70, column: 15, scope: !889)
!914 = !DILocation(line: 70, column: 21, scope: !889)
!915 = !DILocation(line: 70, column: 3, scope: !889)
!916 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr", linkageName: "sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr", scope: null, file: !917, line: 11, type: !5, scopeLine: 11, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!917 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/output_queue_config.csl", directory: "")
!918 = !DILocation(line: 11, column: 33, scope: !919)
!919 = !DILexicalBlockFile(scope: !916, file: !917, discriminator: 0)
!920 = !DILocation(line: 12, column: 82, scope: !919)
!921 = !DILocation(line: 12, column: 40, scope: !919)
!922 = !DILocation(line: 12, column: 3, scope: !919)
!923 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue", linkageName: "sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue", scope: null, file: !917, line: 31, type: !5, scopeLine: 31, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!924 = !DILocation(line: 38, column: 3, scope: !925)
!925 = !DILexicalBlockFile(scope: !923, file: !917, discriminator: 0)
!926 = !DILocation(line: 37, column: 3, scope: !925)
!927 = !DILocation(line: 31, column: 35, scope: !925)
!928 = !DILocation(line: 31, column: 25, scope: !925)
!929 = !DILocation(line: 37, column: 45, scope: !925)
!930 = !DILocation(line: 37, column: 16, scope: !925)
!931 = !DILocation(line: 38, column: 30, scope: !925)
!932 = !DILocation(line: 38, column: 18, scope: !925)
!933 = !DILocation(line: 41, column: 9, scope: !925)
!934 = !DILocation(line: 41, column: 13, scope: !925)
!935 = !DILocation(line: 41, column: 7, scope: !925)
!936 = !DILocation(line: 43, column: 9, scope: !925)
!937 = !DILocation(line: 43, column: 24, scope: !925)
!938 = !DILocation(line: 43, column: 13, scope: !925)
!939 = !DILocation(line: 43, column: 27, scope: !925)
!940 = !DILocation(line: 43, column: 7, scope: !925)
!941 = !DILocation(line: 45, column: 15, scope: !925)
!942 = !DILocation(line: 45, column: 21, scope: !925)
!943 = !DILocation(line: 45, column: 3, scope: !925)
!944 = !DILocation(line: 31, column: 1, scope: !925)
!945 = distinct !DISubprogram(name: ".get_tensor_ptr", linkageName: ".get_tensor_ptr", scope: null, file: !4, line: 1, type: !5, scopeLine: 1, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!946 = !DILocation(line: 1, column: 1, scope: !947)
!947 = !DILexicalBlockFile(scope: !945, file: !4, discriminator: 0)
!948 = distinct !DISubprogram(name: "__generic0sys_mod.sys_mod.tile_config.queue_flush.exit", linkageName: "__generic0sys_mod.sys_mod.tile_config.queue_flush.exit", scope: null, file: !949, line: 12, type: !5, scopeLine: 12, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!949 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/queue_flush.csl", directory: "")
!950 = !DILocation(line: 24, column: 3, scope: !951)
!951 = !DILexicalBlockFile(scope: !948, file: !949, discriminator: 0)
!952 = !DILocation(line: 12, column: 1, scope: !951)
!953 = distinct !DISubprogram(name: "__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position", linkageName: "__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position", scope: null, file: !954, line: 30, type: !5, scopeLine: 30, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!954 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/switch_config.csl", directory: "")
!955 = !DILocation(line: 34, column: 3, scope: !956)
!956 = !DILexicalBlockFile(scope: !953, file: !954, discriminator: 0)
!957 = !DILocation(line: 32, column: 3, scope: !956)
!958 = !DILocation(line: 30, column: 27, scope: !956)
!959 = !DILocation(line: 33, column: 7, scope: !956)
!960 = !DILocation(line: 34, column: 36, scope: !956)
!961 = !DILocation(line: 34, column: 24, scope: !956)
!962 = !DILocation(line: 35, column: 3, scope: !956)
!963 = !DILocation(line: 35, column: 18, scope: !956)
!964 = !DILocation(line: 36, column: 15, scope: !956)
!965 = !DILocation(line: 36, column: 21, scope: !956)
!966 = !DILocation(line: 36, column: 3, scope: !956)
!967 = !DILocation(line: 30, column: 1, scope: !956)
!968 = distinct !DISubprogram(name: "__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", linkageName: "__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", scope: null, file: !969, line: 96, type: !5, scopeLine: 96, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!969 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/color_config.csl", directory: "")
!970 = !DILocation(line: 99, column: 3, scope: !971)
!971 = !DILexicalBlockFile(scope: !968, file: !969, discriminator: 0)
!972 = !DILocation(line: 98, column: 3, scope: !971)
!973 = !DILocation(line: 96, column: 17, scope: !971)
!974 = !DILocation(line: 98, column: 16, scope: !971)
!975 = !DILocation(line: 99, column: 29, scope: !971)
!976 = !DILocation(line: 99, column: 17, scope: !971)
!977 = !DILocation(line: 100, column: 13, scope: !971)
!978 = !DILocation(line: 100, column: 21, scope: !971)
!979 = !DILocation(line: 100, column: 11, scope: !971)
!980 = !DILocation(line: 104, column: 7, scope: !971)
!981 = !DILocation(line: 104, column: 50, scope: !971)
!982 = !DILocation(line: 104, column: 18, scope: !971)
!983 = !DILocation(line: 104, column: 15, scope: !971)
!984 = !DILocation(line: 121, column: 7, scope: !971)
!985 = !DILocation(line: 121, column: 50, scope: !971)
!986 = !DILocation(line: 121, column: 18, scope: !971)
!987 = !DILocation(line: 121, column: 15, scope: !971)
!988 = !DILocation(line: 128, column: 15, scope: !971)
!989 = !DILocation(line: 128, column: 21, scope: !971)
!990 = !DILocation(line: 128, column: 3, scope: !971)
!991 = !DILocation(line: 96, column: 1, scope: !971)
!992 = distinct !DISubprogram(name: "__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", linkageName: "__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", scope: null, file: !969, line: 96, type: !5, scopeLine: 96, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!993 = !DILocation(line: 99, column: 3, scope: !994)
!994 = !DILexicalBlockFile(scope: !992, file: !969, discriminator: 0)
!995 = !DILocation(line: 98, column: 3, scope: !994)
!996 = !DILocation(line: 96, column: 17, scope: !994)
!997 = !DILocation(line: 98, column: 16, scope: !994)
!998 = !DILocation(line: 99, column: 29, scope: !994)
!999 = !DILocation(line: 99, column: 17, scope: !994)
!1000 = !DILocation(line: 100, column: 13, scope: !994)
!1001 = !DILocation(line: 100, column: 21, scope: !994)
!1002 = !DILocation(line: 100, column: 11, scope: !994)
!1003 = !DILocation(line: 104, column: 7, scope: !994)
!1004 = !DILocation(line: 104, column: 50, scope: !994)
!1005 = !DILocation(line: 104, column: 18, scope: !994)
!1006 = !DILocation(line: 104, column: 15, scope: !994)
!1007 = !DILocation(line: 121, column: 7, scope: !994)
!1008 = !DILocation(line: 121, column: 50, scope: !994)
!1009 = !DILocation(line: 121, column: 18, scope: !994)
!1010 = !DILocation(line: 121, column: 15, scope: !994)
!1011 = !DILocation(line: 128, column: 15, scope: !994)
!1012 = !DILocation(line: 128, column: 21, scope: !994)
!1013 = !DILocation(line: 128, column: 3, scope: !994)
!1014 = !DILocation(line: 96, column: 1, scope: !994)
!1015 = distinct !DISubprogram(name: "__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", linkageName: "__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", scope: null, file: !969, line: 60, type: !5, scopeLine: 60, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1016 = !DILocation(line: 61, column: 3, scope: !1017)
!1017 = !DILexicalBlockFile(scope: !1015, file: !969, discriminator: 0)
!1018 = !DILocation(line: 60, column: 46, scope: !1017)
!1019 = !DILocation(line: 61, column: 16, scope: !1017)
!1020 = !DILocation(line: 72, column: 5, scope: !1017)
!1021 = !DILocation(line: 72, column: 12, scope: !1017)
!1022 = !DILocation(line: 74, column: 10, scope: !1017)
!1023 = !DILocation(line: 74, column: 3, scope: !1017)
!1024 = distinct !DISubprogram(name: "__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes", linkageName: "__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes", scope: null, file: !969, line: 77, type: !5, scopeLine: 77, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1025 = !DILocation(line: 78, column: 3, scope: !1026)
!1026 = !DILexicalBlockFile(scope: !1024, file: !969, discriminator: 0)
!1027 = !DILocation(line: 77, column: 46, scope: !1026)
!1028 = !DILocation(line: 78, column: 16, scope: !1026)
!1029 = !DILocation(line: 86, column: 5, scope: !1026)
!1030 = !DILocation(line: 86, column: 12, scope: !1026)
!1031 = !DILocation(line: 91, column: 10, scope: !1026)
!1032 = !DILocation(line: 91, column: 3, scope: !1026)
!1033 = distinct !DISubprogram(name: "__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", linkageName: "__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", scope: null, file: !969, line: 60, type: !5, scopeLine: 60, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1034 = !DILocation(line: 61, column: 3, scope: !1035)
!1035 = !DILexicalBlockFile(scope: !1033, file: !969, discriminator: 0)
!1036 = !DILocation(line: 60, column: 46, scope: !1035)
!1037 = !DILocation(line: 61, column: 16, scope: !1035)
!1038 = !DILocation(line: 63, column: 5, scope: !1035)
!1039 = !DILocation(line: 63, column: 12, scope: !1035)
!1040 = !DILocation(line: 74, column: 10, scope: !1035)
!1041 = !DILocation(line: 74, column: 3, scope: !1035)
!1042 = distinct !DISubprogram(name: "__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction", linkageName: "__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction", scope: null, file: !969, line: 52, type: !5, scopeLine: 52, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1043 = !DILocation(line: 55, column: 3, scope: !1044)
!1044 = !DILexicalBlockFile(scope: !1042, file: !969, discriminator: 0)
!1045 = !DILocation(line: 54, column: 3, scope: !1044)
!1046 = !DILocation(line: 52, column: 23, scope: !1044)
!1047 = !DILocation(line: 54, column: 16, scope: !1044)
!1048 = !DILocation(line: 55, column: 29, scope: !1044)
!1049 = !DILocation(line: 55, column: 17, scope: !1044)
!1050 = !DILocation(line: 56, column: 3, scope: !1044)
!1051 = !DILocation(line: 56, column: 11, scope: !1044)
!1052 = !DILocation(line: 57, column: 15, scope: !1044)
!1053 = !DILocation(line: 57, column: 21, scope: !1044)
!1054 = !DILocation(line: 57, column: 3, scope: !1044)
!1055 = !DILocation(line: 52, column: 1, scope: !1044)
!1056 = distinct !DISubprogram(name: "__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction", linkageName: "__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction", scope: null, file: !969, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1057 = !DILocation(line: 23, column: 3, scope: !1058)
!1058 = !DILexicalBlockFile(scope: !1056, file: !969, discriminator: 0)
!1059 = !DILocation(line: 22, column: 3, scope: !1058)
!1060 = !DILocation(line: 20, column: 21, scope: !1058)
!1061 = !DILocation(line: 22, column: 16, scope: !1058)
!1062 = !DILocation(line: 23, column: 29, scope: !1058)
!1063 = !DILocation(line: 23, column: 17, scope: !1058)
!1064 = !DILocation(line: 24, column: 3, scope: !1058)
!1065 = !DILocation(line: 24, column: 11, scope: !1058)
!1066 = !DILocation(line: 25, column: 15, scope: !1058)
!1067 = !DILocation(line: 25, column: 21, scope: !1058)
!1068 = !DILocation(line: 25, column: 3, scope: !1058)
!1069 = !DILocation(line: 20, column: 1, scope: !1058)
module asm ".section \22.pe_debug_info\22, \22\22"
module asm ".section \22.note\22, \22\22"
