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
  %2 = add i16 %1, 7, !dbg !9
  store i16 %2, i16* getelementptr inbounds ([64 x i16], [64 x i16]* @c, i16 0, i1 false), align 2, !dbg !10
  call void @llvm.sdr.actvt.r(i16 9), !dbg !11
  ret void, !dbg !12
}

define void @f_exit() #0 !dbg !13 {
  call void @sys_mod.unblock_cmd_stream(), !dbg !14
  ret void, !dbg !16
}

define internal void @sys_mod.sys_nop() !dbg !17 {
  ret void, !dbg !19
}

define internal void @sys_mod.unblock_cmd_stream() !dbg !21 {
  call void @sys_mod.sys_mod.unblock_cmd_stream(), !dbg !22
  ret void, !dbg !24
}

define internal void @sys_mod.sys_mod.unblock_cmd_stream() !dbg !25 {
  call void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream(), !dbg !27
  ret void, !dbg !29
}

define internal void @sys_mod.sys_mod.teardown_h2d() !dbg !30 {
  call void @llvm.sdr.actvt.r(i16 27), !dbg !31
  ret void, !dbg !33
}

define void @sys_mod.sys_mod.f_ublk_c22() #1 !dbg !34 {
  call void @sys_mod.sys_mod.unblock_cmd_stream(), !dbg !35
  ret void, !dbg !37
}

define internal void @sys_mod.sys_mod.teardown_d2h() !dbg !38 {
  call void @llvm.sdr.blk.r(i16 0), !dbg !39
  call void @llvm.sdr.actvt.r(i16 28), !dbg !41
  ret void, !dbg !42
}

define void @sys_mod.sys_mod.f_memcpyh2d() #2 !dbg !43 {
  %1 = alloca float, i16 1, align 4, !dbg !44
  %2 = alloca float, i16 1, align 4, !dbg !46
  %3 = alloca i16, i16 1, align 2, !dbg !47
  %4 = alloca i16, i16 1, align 2, !dbg !48
  %5 = alloca i16, i16 1, align 2, !dbg !49
  %6 = alloca i16, i16 1, align 2, !dbg !50
  %7 = alloca i16, i16 1, align 2, !dbg !51
  %8 = alloca i16, i16 1, align 2, !dbg !52
  %9 = alloca i16, i16 1, align 2, !dbg !53
  %10 = alloca i16, i16 1, align 2, !dbg !54
  %11 = alloca i16, i16 1, align 2, !dbg !55
  %12 = alloca i16, i16 1, align 2, !dbg !56
  %13 = alloca i16, i16 1, align 2, !dbg !57
  %14 = alloca i16*, i16 1, align 8, !dbg !58
  %15 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !59
  %16 = icmp eq i16 %15, 15, !dbg !60
  br i1 %16, label %17, label %18, !dbg !61

17:                                               ; preds = %0
  br label %19, !dbg !61

18:                                               ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !61
  br label %19, !dbg !61

19:                                               ; preds = %17, %18
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %14, align 8, !dbg !58
  %20 = load i16*, i16** %14, align 8, !dbg !62
  %21 = load i16, i16* %20, align 2, !dbg !63
  store i16 %21, i16* %13, align 2, !dbg !57
  %22 = load i16*, i16** %14, align 8, !dbg !64
  %23 = getelementptr i16, i16* %22, i16 1, !dbg !65
  %24 = load i16, i16* %23, align 2, !dbg !65
  store i16 %24, i16* %12, align 2, !dbg !56
  %25 = load i16*, i16** %14, align 8, !dbg !66
  %26 = getelementptr i16, i16* %25, i16 2, !dbg !67
  %27 = load i16, i16* %26, align 2, !dbg !67
  store i16 %27, i16* %11, align 2, !dbg !55
  %28 = load i16*, i16** %14, align 8, !dbg !68
  %29 = getelementptr i16, i16* %28, i16 3, !dbg !69
  %30 = load i16, i16* %29, align 2, !dbg !69
  store i16 %30, i16* %10, align 2, !dbg !54
  %31 = load i16*, i16** %14, align 8, !dbg !70
  %32 = getelementptr i16, i16* %31, i16 4, !dbg !71
  %33 = load i16, i16* %32, align 2, !dbg !71
  store i16 %33, i16* %9, align 2, !dbg !53
  %34 = load i16*, i16** %14, align 8, !dbg !72
  %35 = getelementptr i16, i16* %34, i16 5, !dbg !73
  %36 = load i16, i16* %35, align 2, !dbg !73
  store i16 %36, i16* %8, align 2, !dbg !52
  %37 = load i16*, i16** %14, align 8, !dbg !74
  %38 = getelementptr i16, i16* %37, i16 6, !dbg !75
  %39 = load i16, i16* %38, align 2, !dbg !75
  store i16 %39, i16* %7, align 2, !dbg !51
  %40 = load i16*, i16** %14, align 8, !dbg !76
  %41 = getelementptr i16, i16* %40, i16 7, !dbg !77
  %42 = load i16, i16* %41, align 2, !dbg !77
  store i16 %42, i16* %6, align 2, !dbg !50
  %43 = load i16*, i16** %14, align 8, !dbg !78
  %44 = getelementptr i16, i16* %43, i16 8, !dbg !79
  %45 = load i16, i16* %44, align 2, !dbg !79
  store i16 %45, i16* %5, align 2, !dbg !49
  %46 = load i16*, i16** %14, align 8, !dbg !80
  %47 = getelementptr i16, i16* %46, i16 9, !dbg !81
  %48 = load i16, i16* %47, align 2, !dbg !81
  store i16 %48, i16* %4, align 2, !dbg !48
  %49 = load i16*, i16** %14, align 8, !dbg !82
  %50 = getelementptr i16, i16* %49, i16 10, !dbg !83
  %51 = load i16, i16* %50, align 2, !dbg !83
  store i16 %51, i16* %3, align 2, !dbg !47
  %52 = load i16*, i16** %14, align 8, !dbg !84
  %53 = getelementptr i16, i16* %52, i16 12, !dbg !85
  %54 = load i16, i16* %53, align 2, !dbg !85
  %55 = zext i16 %54 to i32, !dbg !86
  %56 = load i16*, i16** %14, align 8, !dbg !87
  %57 = getelementptr i16, i16* %56, i16 11, !dbg !88
  %58 = load i16, i16* %57, align 2, !dbg !88
  %59 = zext i16 %58 to i32, !dbg !89
  %60 = add i32 %59, 16, !dbg !90
  %61 = shl i32 %55, %60, !dbg !91
  %62 = bitcast i32 %61 to float, !dbg !92
  store float %62, float* %2, align 4, !dbg !46
  %63 = load i16*, i16** %14, align 8, !dbg !93
  %64 = getelementptr i16, i16* %63, i16 14, !dbg !94
  %65 = load i16, i16* %64, align 2, !dbg !94
  %66 = zext i16 %65 to i32, !dbg !95
  %67 = load i16*, i16** %14, align 8, !dbg !96
  %68 = getelementptr i16, i16* %67, i16 13, !dbg !97
  %69 = load i16, i16* %68, align 2, !dbg !97
  %70 = zext i16 %69 to i32, !dbg !98
  %71 = add i32 %70, 16, !dbg !99
  %72 = shl i32 %66, %71, !dbg !100
  %73 = bitcast i32 %72 to float, !dbg !101
  store float %73, float* %1, align 4, !dbg !44
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !102
  %74 = load i16, i16* %13, align 2, !dbg !103
  store i16 %74, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !104
  %75 = load i16, i16* %12, align 2, !dbg !105
  store i16 %75, i16* @sys_mod.sys_mod.memcpyH2D_px, align 2, !dbg !106
  %76 = load i16, i16* %11, align 2, !dbg !107
  store i16 %76, i16* @sys_mod.sys_mod.memcpyH2D_py, align 2, !dbg !108
  %77 = load i16, i16* %10, align 2, !dbg !109
  store i16 %77, i16* @sys_mod.sys_mod.memcpyH2D_w, align 2, !dbg !110
  %78 = load i16, i16* %9, align 2, !dbg !111
  store i16 %78, i16* @sys_mod.sys_mod.memcpyH2D_h, align 2, !dbg !112
  %79 = load i16, i16* %8, align 2, !dbg !113
  store i16 %79, i16* @sys_mod.sys_mod.memcpyH2D_addr, align 2, !dbg !114
  %80 = load i16, i16* %7, align 2, !dbg !115
  store i16 %80, i16* @sys_mod.sys_mod.memcpyH2D_pe_length, align 2, !dbg !116
  %81 = load i16, i16* %6, align 2, !dbg !117
  store i16 %81, i16* @sys_mod.sys_mod.memcpyH2D_is_half, align 2, !dbg !118
  %82 = load i16, i16* %5, align 2, !dbg !119
  store i16 %82, i16* @sys_mod.sys_mod.memcpyH2D_memcpy_optype, align 2, !dbg !120
  %83 = load i16, i16* %4, align 2, !dbg !121
  store i16 %83, i16* @sys_mod.sys_mod.memcpyH2D_row_stride, align 2, !dbg !122
  %84 = load i16, i16* %3, align 2, !dbg !123
  store i16 %84, i16* @sys_mod.sys_mod.memcpyH2D_col_stride, align 2, !dbg !124
  %85 = load float, float* %2, align 4, !dbg !125
  store float %85, float* @sys_mod.sys_mod.memcpyH2D_one_over_row_stride, align 4, !dbg !126
  %86 = load float, float* %1, align 4, !dbg !127
  store float %86, float* @sys_mod.sys_mod.memcpyH2D_one_over_col_stride, align 4, !dbg !128
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !129
  call void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 0, i16 23, i1 true), !dbg !130
  call void @llvm.sdr.blk.r(i16 27), !dbg !131
  call void @llvm.sdr.oqflush(i16 0), !dbg !132
  store i1 true, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !133
  call void @llvm.sdr.blk.r(i16 0), !dbg !134
  ret void, !dbg !135
}

define void @sys_mod.sys_mod.f_memcpyd2h() #3 !dbg !136 {
  %1 = alloca i16, i16 1, align 2, !dbg !137
  %2 = alloca i16, i16 1, align 2, !dbg !139
  %3 = alloca i16, i16 1, align 2, !dbg !140
  %4 = alloca i16, i16 1, align 2, !dbg !141
  %5 = alloca i16, i16 1, align 2, !dbg !142
  %6 = alloca i16, i16 1, align 2, !dbg !143
  %7 = alloca i16, i16 1, align 2, !dbg !144
  %8 = alloca i16, i16 1, align 2, !dbg !145
  %9 = alloca i16*, i16 1, align 8, !dbg !146
  %10 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !147
  %11 = icmp eq i16 %10, 8, !dbg !148
  br i1 %11, label %12, label %13, !dbg !149

12:                                               ; preds = %0
  br label %14, !dbg !149

13:                                               ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !149
  br label %14, !dbg !149

14:                                               ; preds = %12, %13
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %9, align 8, !dbg !146
  %15 = load i16*, i16** %9, align 8, !dbg !150
  %16 = load i16, i16* %15, align 2, !dbg !151
  store i16 %16, i16* %8, align 2, !dbg !145
  %17 = load i16*, i16** %9, align 8, !dbg !152
  %18 = getelementptr i16, i16* %17, i16 1, !dbg !153
  %19 = load i16, i16* %18, align 2, !dbg !153
  store i16 %19, i16* %7, align 2, !dbg !144
  %20 = load i16*, i16** %9, align 8, !dbg !154
  %21 = getelementptr i16, i16* %20, i16 2, !dbg !155
  %22 = load i16, i16* %21, align 2, !dbg !155
  store i16 %22, i16* %6, align 2, !dbg !143
  %23 = load i16*, i16** %9, align 8, !dbg !156
  %24 = getelementptr i16, i16* %23, i16 3, !dbg !157
  %25 = load i16, i16* %24, align 2, !dbg !157
  store i16 %25, i16* %5, align 2, !dbg !142
  %26 = load i16*, i16** %9, align 8, !dbg !158
  %27 = getelementptr i16, i16* %26, i16 4, !dbg !159
  %28 = load i16, i16* %27, align 2, !dbg !159
  store i16 %28, i16* %4, align 2, !dbg !141
  %29 = load i16*, i16** %9, align 8, !dbg !160
  %30 = getelementptr i16, i16* %29, i16 5, !dbg !161
  %31 = load i16, i16* %30, align 2, !dbg !161
  store i16 %31, i16* %3, align 2, !dbg !140
  %32 = load i16*, i16** %9, align 8, !dbg !162
  %33 = getelementptr i16, i16* %32, i16 6, !dbg !163
  %34 = load i16, i16* %33, align 2, !dbg !163
  store i16 %34, i16* %2, align 2, !dbg !139
  %35 = load i16*, i16** %9, align 8, !dbg !164
  %36 = getelementptr i16, i16* %35, i16 7, !dbg !165
  %37 = load i16, i16* %36, align 2, !dbg !165
  store i16 %37, i16* %1, align 2, !dbg !137
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !166
  %38 = load i16, i16* %8, align 2, !dbg !167
  store i16 %38, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !168
  %39 = load i16, i16* %7, align 2, !dbg !169
  store i16 %39, i16* @sys_mod.sys_mod.memcpyD2H_px, align 2, !dbg !170
  %40 = load i16, i16* %6, align 2, !dbg !171
  store i16 %40, i16* @sys_mod.sys_mod.memcpyD2H_py, align 2, !dbg !172
  %41 = load i16, i16* %5, align 2, !dbg !173
  store i16 %41, i16* @sys_mod.sys_mod.memcpyD2H_w, align 2, !dbg !174
  %42 = load i16, i16* %4, align 2, !dbg !175
  store i16 %42, i16* @sys_mod.sys_mod.memcpyD2H_h, align 2, !dbg !176
  %43 = load i16, i16* %3, align 2, !dbg !177
  store i16 %43, i16* @sys_mod.sys_mod.memcpyD2H_addr, align 2, !dbg !178
  %44 = load i16, i16* %2, align 2, !dbg !179
  store i16 %44, i16* @sys_mod.sys_mod.memcpyD2H_pe_length, align 2, !dbg !180
  %45 = load i16, i16* %1, align 2, !dbg !181
  store i16 %45, i16* @sys_mod.sys_mod.memcpyD2H_is_half, align 2, !dbg !182
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !183
  %46 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !184
  call void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 0, i16 %46, i1 false), !dbg !185
  call void @llvm.sdr.oqflush(i16 0), !dbg !186
  store i1 false, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !187
  ret void, !dbg !188
}

define internal void @sys_mod.sys_mod.oq0_teardow_handler() !dbg !189 {
  %1 = load i1, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !190
  br i1 %1, label %2, label %17, !dbg !192

2:                                                ; preds = %0
  %3 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !193
  call void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 0, i16 %3), !dbg !194
  %4 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !195
  %5 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_px, align 2, !dbg !196
  %6 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_py, align 2, !dbg !197
  %7 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_w, align 2, !dbg !198
  %8 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_h, align 2, !dbg !199
  %9 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_addr, align 2, !dbg !200
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_pe_length, align 2, !dbg !201
  %11 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_is_half, align 2, !dbg !202
  %12 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_memcpy_optype, align 2, !dbg !203
  %13 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_row_stride, align 2, !dbg !204
  %14 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_col_stride, align 2, !dbg !205
  %15 = load float, float* @sys_mod.sys_mod.memcpyH2D_one_over_row_stride, align 4, !dbg !206
  %16 = load float, float* @sys_mod.sys_mod.memcpyH2D_one_over_col_stride, align 4, !dbg !207
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure(i16 %4, i16 %5, i16 %6, i16 %7, i16 %8, i16 %9, i16 %10, i16 %11, i16 %12, i16 %13, i16 %14, float %15, float %16), !dbg !208
  br label %26, !dbg !192

17:                                               ; preds = %0
  call void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 0, i16 21), !dbg !209
  %18 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !210
  %19 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_px, align 2, !dbg !211
  %20 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_py, align 2, !dbg !212
  %21 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_w, align 2, !dbg !213
  %22 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_h, align 2, !dbg !214
  %23 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_addr, align 2, !dbg !215
  %24 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_pe_length, align 2, !dbg !216
  %25 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_is_half, align 2, !dbg !217
  call void @sys_mod.sys_mod.memcpyd2h_mod.d2h_configure(i16 %18, i16 %19, i16 %20, i16 %21, i16 %22, i16 %23, i16 %24, i16 %25), !dbg !218
  br label %26, !dbg !192

26:                                               ; preds = %2, %17
  call void @__generic0sys_mod.sys_mod.tile_config.queue_flush.exit(), !dbg !219
  ret void, !dbg !192
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

define void @sys_mod.sys_mod.f_rpc(i16 %0) #4 !dbg !220 {
  %2 = alloca i16, i16 1, align 2, !dbg !221
  store i16 %0, i16* %2, align 2, !dbg !221
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !223
  %3 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !224
  %4 = icmp sge i16 %3, 4, !dbg !225
  br i1 %4, label %5, label %6, !dbg !226

5:                                                ; preds = %1
  br label %7, !dbg !226

6:                                                ; preds = %1
  call void asm sideeffect "hcf", ""(), !dbg !226
  br label %7, !dbg !226

7:                                                ; preds = %5, %6
  call void @rpc_server(i32* getelementptr inbounds ([32 x i32], [32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32, i32 0, i32 0)), !dbg !227
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !228
  ret void, !dbg !229
}

define internal void @sys_mod.sys_mod.sys_mod.stack_push(i16 %0) !dbg !230 {
  %2 = alloca i16*, i16 1, align 8, !dbg !232
  %3 = alloca i16, i16 1, align 2, !dbg !234
  store i16 %0, i16* %3, align 2, !dbg !234
  %4 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !235
  %5 = icmp slt i16 %4, 32, !dbg !236
  br i1 %5, label %6, label %7, !dbg !237

6:                                                ; preds = %1
  br label %8, !dbg !237

7:                                                ; preds = %1
  call void asm sideeffect "hcf", ""(), !dbg !237
  br label %8, !dbg !237

8:                                                ; preds = %6, %7
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %2, align 8, !dbg !232
  %9 = load i16, i16* %3, align 2, !dbg !238
  %10 = load i16*, i16** %2, align 8, !dbg !239
  %11 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !240
  %12 = getelementptr i16, i16* %10, i16 %11, !dbg !241
  store i16 %9, i16* %12, align 2, !dbg !242
  %13 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !243
  %14 = add i16 %13, 1, !dbg !244
  store i16 %14, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !245
  ret void, !dbg !246
}

define void @sys_mod.sys_mod.sys_mod.f_push(i16 %0, i16 %1) #5 !dbg !247 {
  %3 = alloca i16, i16 1, align 2, !dbg !248
  %4 = alloca i16, i16 1, align 2, !dbg !250
  store i16 %0, i16* %4, align 2, !dbg !250
  store i16 %1, i16* %3, align 2, !dbg !248
  %5 = load i16, i16* %4, align 2, !dbg !251
  call void @sys_mod.sys_mod.sys_mod.stack_push(i16 %5), !dbg !252
  ret void, !dbg !253
}

define internal void @sys_mod.sys_mod.sys_mod.block_cmd_stream() !dbg !254 {
  call void @llvm.sdr.blk.r(i16 1), !dbg !255
  ret void, !dbg !257
}

define internal void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream() !dbg !258 {
  call void @llvm.sdr.ublk.r(i16 1), !dbg !259
  ret void, !dbg !261
}

define void @sys_mod.sys_mod.sys_mod.f_sys_exit() #6 !dbg !262 {
  call void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream(), !dbg !263
  call void @sys_mod.sys_nop(), !dbg !265
  ret void, !dbg !266
}

define void @sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore(i32 %0) #7 !dbg !267 {
  %2 = alloca i32, i16 1, align 4, !dbg !268
  store i32 %0, i32* %2, align 4, !dbg !268
  ret void, !dbg !270
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord() !dbg !271 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord(), !dbg !273
  ret i16 %1, !dbg !275
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord() !dbg !276 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord(), !dbg !277
  ret i16 %1, !dbg !279
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval(i16 %0) !dbg !280 {
  %2 = alloca i16, i16 1, align 2, !dbg !281
  store i16 %0, i16* %2, align 2, !dbg !281
  %3 = load i16, i16* %2, align 2, !dbg !283
  %4 = icmp ult i16 %3, 24, !dbg !284
  br i1 %4, label %5, label %7, !dbg !285

5:                                                ; preds = %10, %11, %1
  %6 = phi i16 [ 0, %10 ], [ 0, %11 ], [ 1, %1 ]
  br label %12, !dbg !285

7:                                                ; preds = %1
  %8 = load i16, i16* %2, align 2, !dbg !286
  %9 = icmp eq i16 31, %8, !dbg !287
  br i1 %9, label %10, label %11, !dbg !288

10:                                               ; preds = %7
  br label %5, !dbg !288

11:                                               ; preds = %7
  call void asm sideeffect "hcf", ""(), !dbg !288
  br label %5, !dbg !288

12:                                               ; preds = %5
  %13 = phi i16 [ %6, %5 ]
  br label %14, !dbg !285

14:                                               ; preds = %12
  ret i16 %13, !dbg !285
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start(i16 %0, i16 %1, i16 %2) !dbg !289 {
  %4 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !290
  %5 = alloca i16, i16 1, align 2, !dbg !292
  %6 = alloca i16, i16 1, align 2, !dbg !293
  %7 = alloca i16, i16 1, align 2, !dbg !294
  store i16 %0, i16* %7, align 2, !dbg !294
  store i16 %1, i16* %6, align 2, !dbg !293
  store i16 %2, i16* %5, align 2, !dbg !292
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !295
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !295
  %10 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !295
  %11 = load i16, i16* %6, align 2, !dbg !296
  store i16 %11, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !297
  store i16 %8, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !297
  store i16 %9, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !297
  store i16 %10, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !297
  %12 = load i16, i16* %7, align 2, !dbg !298
  %13 = call i16* @.get_tensor_ptr(i16 %12), !dbg !299
  %14 = ptrtoint i16* %13 to i16, !dbg !300
  %15 = lshr i16 %14, 1, !dbg !300
  %16 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !290
  store i16 42, i16* %16, align 2, !dbg !290
  %17 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !290
  store i16 %15, i16* %17, align 2, !dbg !290
  %18 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !290
  store i16 143, i16* %18, align 2, !dbg !290
  %19 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !290
  store i16 16, i16* %19, align 2, !dbg !290
  %20 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !301
  %21 = load i16, i16* %20, align 2, !dbg !301
  %22 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !301
  %23 = load i16, i16* %22, align 2, !dbg !301
  %24 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !301
  %25 = load i16, i16* %24, align 2, !dbg !301
  %26 = load i16, i16* %6, align 2, !dbg !302
  %27 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !303
  store i16 %26, i16* %27, align 2, !dbg !303
  %28 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !303
  store i16 %21, i16* %28, align 2, !dbg !303
  %29 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !303
  store i16 %23, i16* %29, align 2, !dbg !303
  %30 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !303
  store i16 %25, i16* %30, align 2, !dbg !303
  %31 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !304
  %32 = load i16, i16* %31, align 2, !dbg !304
  %33 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !304
  %34 = load i16, i16* %33, align 2, !dbg !304
  %35 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !304
  %36 = load i16, i16* %35, align 2, !dbg !304
  %37 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !304
  %38 = load i16, i16* %37, align 2, !dbg !304
  store volatile i16 %32, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !305
  store volatile i16 %34, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !305
  store volatile i16 %36, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !305
  store volatile i16 %38, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !305
  call void asm sideeffect "nop", ""(), !dbg !305
  call void asm sideeffect "nop", ""(), !dbg !305
  %39 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !306
  %40 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !306
  %41 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !306
  %42 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !306
  %43 = and i16 %41, -193, !dbg !306
  %44 = or i16 %43, 128, !dbg !306
  %45 = and i16 %40, -64, !dbg !306
  %46 = or i16 %45, 27, !dbg !306
  store volatile i16 %39, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !307
  store volatile i16 %46, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !307
  store volatile i16 %44, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !307
  store volatile i16 %42, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !307
  call void asm sideeffect "nop", ""(), !dbg !307
  call void asm sideeffect "nop", ""(), !dbg !307
  %47 = load i16, i16* %5, align 2, !dbg !308
  %48 = icmp ult i16 0, %47, !dbg !309
  br i1 %48, label %49, label %50, !dbg !310

49:                                               ; preds = %3
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !311
  br label %51, !dbg !310

50:                                               ; preds = %3
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !312
  br label %51, !dbg !310

51:                                               ; preds = %49, %50
  ret void, !dbg !310
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream() !dbg !313 {
  call void @llvm.sdr.ublk.r(i16 1), !dbg !314
  ret void, !dbg !316
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7, i16 %8, i16 %9, i16 %10, float %11, float %12) !dbg !317 {
  %14 = alloca i16, i16 1, align 2, !dbg !318
  %15 = alloca i16, i16 1, align 2, !dbg !320
  %16 = alloca i16, i16 1, align 2, !dbg !321
  %17 = alloca i16, i16 1, align 2, !dbg !322
  %18 = alloca i16, i16 1, align 2, !dbg !323
  %19 = alloca i1, i16 1, align 1, !dbg !324
  %20 = alloca i16, i16 1, align 2, !dbg !325
  %21 = alloca i16, i16 1, align 2, !dbg !326
  %22 = alloca i16, i16 1, align 2, !dbg !327
  %23 = alloca i16, i16 1, align 2, !dbg !328
  %24 = alloca i16, i16 1, align 2, !dbg !329
  %25 = alloca float, i16 1, align 4, !dbg !330
  %26 = alloca float, i16 1, align 4, !dbg !331
  %27 = alloca i16, i16 1, align 2, !dbg !332
  %28 = alloca i16, i16 1, align 2, !dbg !333
  %29 = alloca i16, i16 1, align 2, !dbg !334
  %30 = alloca i16, i16 1, align 2, !dbg !335
  %31 = alloca i16, i16 1, align 2, !dbg !336
  %32 = alloca i16, i16 1, align 2, !dbg !337
  %33 = alloca i16, i16 1, align 2, !dbg !338
  %34 = alloca i16, i16 1, align 2, !dbg !339
  %35 = alloca i16, i16 1, align 2, !dbg !340
  %36 = alloca i16, i16 1, align 2, !dbg !341
  %37 = alloca i16, i16 1, align 2, !dbg !342
  store i16 %0, i16* %37, align 2, !dbg !342
  store i16 %1, i16* %36, align 2, !dbg !341
  store i16 %2, i16* %35, align 2, !dbg !340
  store i16 %3, i16* %34, align 2, !dbg !339
  store i16 %4, i16* %33, align 2, !dbg !338
  store i16 %5, i16* %32, align 2, !dbg !337
  store i16 %6, i16* %31, align 2, !dbg !336
  store i16 %7, i16* %30, align 2, !dbg !335
  store i16 %8, i16* %29, align 2, !dbg !334
  store i16 %9, i16* %28, align 2, !dbg !333
  store i16 %10, i16* %27, align 2, !dbg !332
  store float %11, float* %26, align 4, !dbg !331
  store float %12, float* %25, align 4, !dbg !330
  %38 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord(), !dbg !343
  store i16 %38, i16* %24, align 2, !dbg !329
  %39 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord(), !dbg !344
  store i16 %39, i16* %23, align 2, !dbg !328
  %40 = load i16, i16* %24, align 2, !dbg !345
  %41 = load i16, i16* %36, align 2, !dbg !346
  %42 = sub i16 %40, %41, !dbg !347
  store i16 %42, i16* %22, align 2, !dbg !327
  %43 = load i16, i16* %22, align 2, !dbg !348
  store i16 %43, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !349
  %44 = load i16, i16* %29, align 2, !dbg !350
  %45 = icmp eq i16 3, %44, !dbg !351
  br i1 %45, label %46, label %63, !dbg !352

46:                                               ; preds = %13
  %47 = load i16, i16* %22, align 2, !dbg !353
  %48 = sitofp i16 %47 to float, !dbg !354
  %49 = load float, float* %26, align 4, !dbg !355
  %50 = fmul float %48, %49, !dbg !356
  %51 = fptosi float %50 to i16, !dbg !357
  store i16 %51, i16* %21, align 2, !dbg !326
  %52 = load i16, i16* %22, align 2, !dbg !358
  %53 = load i16, i16* %21, align 2, !dbg !359
  %54 = load i16, i16* %28, align 2, !dbg !360
  %55 = mul i16 %53, %54, !dbg !361
  %56 = sub i16 %52, %55, !dbg !362
  store i16 %56, i16* %20, align 2, !dbg !325
  %57 = load i16, i16* %20, align 2, !dbg !363
  %58 = icmp ne i16 0, %57, !dbg !364
  br i1 %58, label %59, label %60, !dbg !365

59:                                               ; preds = %46
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !366
  br label %62, !dbg !365

60:                                               ; preds = %46
  %61 = load i16, i16* %21, align 2, !dbg !367
  store i16 %61, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !368
  br label %62, !dbg !365

62:                                               ; preds = %59, %60
  br label %63, !dbg !352

63:                                               ; preds = %62, %13
  %64 = load i16, i16* %22, align 2, !dbg !369
  %65 = icmp slt i16 %64, 0, !dbg !370
  br i1 %65, label %66, label %67, !dbg !371

66:                                               ; preds = %63
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !372
  br label %67, !dbg !371

67:                                               ; preds = %66, %63
  %68 = load i16, i16* %22, align 2, !dbg !373
  %69 = load i16, i16* %34, align 2, !dbg !374
  %70 = icmp sge i16 %68, %69, !dbg !375
  br i1 %70, label %71, label %72, !dbg !376

71:                                               ; preds = %67
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !377
  br label %72, !dbg !376

72:                                               ; preds = %71, %67
  store i1 false, i1* %19, align 1, !dbg !324
  %73 = load i16, i16* %29, align 2, !dbg !378
  %74 = icmp eq i16 3, %73, !dbg !379
  br i1 %74, label %75, label %94, !dbg !380

75:                                               ; preds = %72
  %76 = load i16, i16* %23, align 2, !dbg !381
  %77 = load i16, i16* %35, align 2, !dbg !382
  %78 = sub i16 %76, %77, !dbg !383
  %79 = sitofp i16 %78 to float, !dbg !384
  %80 = load float, float* %25, align 4, !dbg !385
  %81 = fmul float %79, %80, !dbg !386
  %82 = fptosi float %81 to i16, !dbg !387
  store i16 %82, i16* %18, align 2, !dbg !323
  %83 = load i16, i16* %23, align 2, !dbg !388
  %84 = load i16, i16* %35, align 2, !dbg !389
  %85 = sub i16 %83, %84, !dbg !390
  %86 = load i16, i16* %18, align 2, !dbg !391
  %87 = load i16, i16* %27, align 2, !dbg !392
  %88 = mul i16 %86, %87, !dbg !393
  %89 = sub i16 %85, %88, !dbg !394
  store i16 %89, i16* %17, align 2, !dbg !322
  %90 = load i16, i16* %17, align 2, !dbg !395
  %91 = icmp ne i16 0, %90, !dbg !396
  br i1 %91, label %92, label %93, !dbg !397

92:                                               ; preds = %75
  store i1 true, i1* %19, align 1, !dbg !398
  br label %93, !dbg !397

93:                                               ; preds = %92, %75
  br label %94, !dbg !380

94:                                               ; preds = %93, %72
  %95 = load i16, i16* %23, align 2, !dbg !399
  %96 = load i16, i16* %35, align 2, !dbg !400
  %97 = icmp slt i16 %95, %96, !dbg !401
  br i1 %97, label %98, label %99, !dbg !402

98:                                               ; preds = %94
  store i1 true, i1* %19, align 1, !dbg !403
  br label %99, !dbg !402

99:                                               ; preds = %98, %94
  %100 = load i16, i16* %23, align 2, !dbg !404
  %101 = load i16, i16* %35, align 2, !dbg !405
  %102 = load i16, i16* %33, align 2, !dbg !406
  %103 = add i16 %101, %102, !dbg !407
  %104 = icmp sge i16 %100, %103, !dbg !408
  br i1 %104, label %105, label %106, !dbg !409

105:                                              ; preds = %99
  store i1 true, i1* %19, align 1, !dbg !410
  br label %106, !dbg !409

106:                                              ; preds = %105, %99
  %107 = load i1, i1* %19, align 1, !dbg !411
  br i1 %107, label %108, label %109, !dbg !412

108:                                              ; preds = %106
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream(), !dbg !413
  call void @llvm.sdr.ublk.r(i16 27), !dbg !414
  br label %180, !dbg !412

109:                                              ; preds = %106
  %110 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !415
  %111 = icmp eq i16 -1, %110, !dbg !416
  br i1 %111, label %112, label %113, !dbg !417

112:                                              ; preds = %109
  call void @__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction(i16 31767), !dbg !418
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 23), !dbg !419
  call void @llvm.sdr.ublk.r(i16 27), !dbg !420
  br label %179, !dbg !417

113:                                              ; preds = %109
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter(i16 0, i16 0), !dbg !421
  %114 = load i16, i16* %34, align 2, !dbg !422
  store i16 %114, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !423
  %115 = load i16, i16* %29, align 2, !dbg !424
  %116 = icmp eq i16 3, %115, !dbg !425
  br i1 %116, label %117, label %126, !dbg !426

117:                                              ; preds = %113
  %118 = load i16, i16* %34, align 2, !dbg !427
  %119 = sub i16 %118, 1, !dbg !428
  %120 = sitofp i16 %119 to float, !dbg !429
  %121 = load float, float* %26, align 4, !dbg !430
  %122 = fmul float %120, %121, !dbg !431
  %123 = fptosi float %122 to i16, !dbg !432
  %124 = add i16 %123, 1, !dbg !433
  store i16 %124, i16* %16, align 2, !dbg !321
  %125 = load i16, i16* %16, align 2, !dbg !434
  store i16 %125, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !435
  br label %131, !dbg !426

126:                                              ; preds = %113
  %127 = load i16, i16* %29, align 2, !dbg !436
  %128 = icmp eq i16 1, %127, !dbg !437
  br i1 %128, label %129, label %130, !dbg !438

129:                                              ; preds = %126
  store i16 1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !439
  br label %130, !dbg !438

130:                                              ; preds = %129, %126
  br label %131, !dbg !426

131:                                              ; preds = %117, %130
  %132 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !440
  %133 = sub i16 %132, 1, !dbg !441
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit(i16 0, i16 %133), !dbg !442
  %134 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !443
  store i16 %134, i16* %15, align 2, !dbg !320
  %135 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !444
  store i16 %135, i16* %14, align 2, !dbg !318
  %136 = load i16, i16* %15, align 2, !dbg !445
  %137 = load i16, i16* %14, align 2, !dbg !446
  %138 = sub i16 %136, %137, !dbg !447
  store i16 %138, i16* %15, align 2, !dbg !448
  %139 = load i16, i16* %14, align 2, !dbg !449
  %140 = icmp eq i16 0, %139, !dbg !450
  br i1 %140, label %141, label %142, !dbg !451

141:                                              ; preds = %131
  store i16 0, i16* %15, align 2, !dbg !452
  br label %142, !dbg !451

142:                                              ; preds = %141, %131
  %143 = load i16, i16* %29, align 2, !dbg !453
  %144 = icmp eq i16 1, %143, !dbg !454
  br i1 %144, label %145, label %146, !dbg !455

145:                                              ; preds = %142
  store i16 0, i16* %15, align 2, !dbg !456
  br label %146, !dbg !455

146:                                              ; preds = %145, %142
  %147 = load i16, i16* %15, align 2, !dbg !457
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter(i16 0, i16 %147), !dbg !458
  call void @__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction(i16 31767), !dbg !459
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 23), !dbg !460
  %148 = load i16, i16* %37, align 2, !dbg !461
  %149 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval(i16 %148), !dbg !462
  %150 = icmp eq i16 0, %149, !dbg !463
  br i1 %150, label %151, label %155, !dbg !464

151:                                              ; preds = %146
  %152 = load i16, i16* %32, align 2, !dbg !465
  %153 = load i16, i16* %31, align 2, !dbg !466
  %154 = load i16, i16* %30, align 2, !dbg !467
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start(i16 %152, i16 %153, i16 %154), !dbg !468
  br label %178, !dbg !464

155:                                              ; preds = %146
  %156 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !469
  %157 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !469
  %158 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !469
  %159 = load i16, i16* %31, align 2, !dbg !470
  store i16 %159, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !471
  store i16 %156, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !471
  store i16 %157, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !471
  store i16 %158, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !471
  %160 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !472
  %161 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !472
  %162 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !472
  %163 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !472
  %164 = and i16 %162, -193, !dbg !472
  %165 = or i16 %164, 128, !dbg !472
  store volatile i16 %160, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !473
  store volatile i16 %161, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !473
  store volatile i16 %165, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !473
  store volatile i16 %163, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !473
  call void asm sideeffect "nop", ""(), !dbg !473
  call void asm sideeffect "nop", ""(), !dbg !473
  %166 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !474
  %167 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !474
  %168 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !474
  %169 = load i16, i16* %31, align 2, !dbg !475
  store i16 %169, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !476
  store i16 %166, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !476
  store i16 %167, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !476
  store i16 %168, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !476
  %170 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !477
  %171 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !477
  %172 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !477
  %173 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !477
  %174 = and i16 %172, -193, !dbg !477
  %175 = or i16 %174, 128, !dbg !477
  %176 = and i16 %171, -64, !dbg !477
  %177 = or i16 %176, 27, !dbg !477
  store volatile i16 %170, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !478
  store volatile i16 %177, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !478
  store volatile i16 %175, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !478
  store volatile i16 %173, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !478
  call void asm sideeffect "nop", ""(), !dbg !478
  call void asm sideeffect "nop", ""(), !dbg !478
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !479
  br label %178, !dbg !464

178:                                              ; preds = %151, %155
  br label %179, !dbg !417

179:                                              ; preds = %112, %178
  br label %180, !dbg !412

180:                                              ; preds = %108, %179
  ret void, !dbg !352
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit(i16 %0, i16 %1) !dbg !480 {
  %3 = alloca i16, i16 1, align 2, !dbg !482
  %4 = alloca i16, i16 1, align 2, !dbg !484
  %5 = alloca i16, i16 1, align 2, !dbg !485
  %6 = alloca i16, i16 1, align 2, !dbg !486
  %7 = alloca i16, i16 1, align 2, !dbg !487
  %8 = alloca i16, i16 1, align 2, !dbg !488
  store i16 %0, i16* %8, align 2, !dbg !488
  store i16 %1, i16* %7, align 2, !dbg !487
  %9 = load i16, i16* %7, align 2, !dbg !489
  %10 = icmp ult i16 %9, -32768, !dbg !490
  br i1 %10, label %11, label %12, !dbg !491

11:                                               ; preds = %2
  br label %13, !dbg !491

12:                                               ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !491
  br label %13, !dbg !491

13:                                               ; preds = %11, %12
  %14 = load i16, i16* %7, align 2, !dbg !492
  %15 = mul i16 %14, 2, !dbg !493
  store i16 %15, i16* %6, align 2, !dbg !486
  %16 = load i16, i16* %8, align 2, !dbg !494
  %17 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %16, i16 8), !dbg !495
  %18 = sub i16 %17, 1, !dbg !496
  store i16 %18, i16* %5, align 2, !dbg !485
  %19 = load i16, i16* %6, align 2, !dbg !497
  %20 = load i16, i16* %5, align 2, !dbg !498
  %21 = icmp ult i16 %19, %20, !dbg !499
  br i1 %21, label %22, label %23, !dbg !484

22:                                               ; preds = %13
  store i16 0, i16* %4, align 2, !dbg !484
  br label %27, !dbg !484

23:                                               ; preds = %13
  %24 = load i16, i16* %6, align 2, !dbg !500
  %25 = load i16, i16* %5, align 2, !dbg !501
  %26 = sub i16 %24, %25, !dbg !502
  store i16 %26, i16* %4, align 2, !dbg !484
  br label %27, !dbg !484

27:                                               ; preds = %22, %23
  %28 = load i16, i16* %4, align 2, !dbg !484
  store i16 %28, i16* %3, align 2, !dbg !482
  %29 = load i16, i16* %8, align 2, !dbg !503
  %30 = load i16, i16* %3, align 2, !dbg !504
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %29, i16 4, i16 %30), !dbg !505
  ret void, !dbg !484
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter(i16 %0, i16 %1) !dbg !506 {
  %3 = alloca i16, i16 1, align 2, !dbg !507
  %4 = alloca i16, i16 1, align 2, !dbg !509
  store i16 %0, i16* %4, align 2, !dbg !509
  store i16 %1, i16* %3, align 2, !dbg !507
  %5 = load i16, i16* %3, align 2, !dbg !510
  %6 = icmp ult i16 %5, -32768, !dbg !511
  br i1 %6, label %7, label %8, !dbg !512

7:                                                ; preds = %2
  br label %9, !dbg !512

8:                                                ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !512
  br label %9, !dbg !512

9:                                                ; preds = %7, %8
  %10 = load i16, i16* %4, align 2, !dbg !513
  %11 = load i16, i16* %3, align 2, !dbg !514
  %12 = mul i16 %11, 2, !dbg !515
  %13 = add i16 %12, 1, !dbg !516
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %10, i16 8, i16 %13), !dbg !517
  ret void, !dbg !518
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter(i16 %0, i16 %1) !dbg !519 {
  %3 = alloca i16, i16 1, align 2, !dbg !520
  %4 = alloca i16, i16 1, align 2, !dbg !522
  %5 = alloca i1, i16 1, align 1, !dbg !523
  %6 = alloca i16, i16 1, align 2, !dbg !524
  %7 = alloca i16, i16 1, align 2, !dbg !525
  %8 = alloca i16, i16 1, align 2, !dbg !526
  %9 = alloca i16, i16 1, align 2, !dbg !527
  store i16 %0, i16* %9, align 2, !dbg !527
  store i16 %1, i16* %8, align 2, !dbg !526
  %10 = load i16, i16* %8, align 2, !dbg !528
  %11 = icmp ult i16 %10, -32768, !dbg !529
  br i1 %11, label %12, label %13, !dbg !530

12:                                               ; preds = %2
  br label %14, !dbg !530

13:                                               ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !530
  br label %14, !dbg !530

14:                                               ; preds = %12, %13
  %15 = load i16, i16* %9, align 2, !dbg !531
  %16 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %15, i16 8), !dbg !532
  store i16 %16, i16* %7, align 2, !dbg !525
  %17 = load i16, i16* %8, align 2, !dbg !533
  %18 = mul i16 %17, 2, !dbg !534
  store i16 %18, i16* %6, align 2, !dbg !524
  %19 = load i16, i16* %6, align 2, !dbg !535
  %20 = load i16, i16* %7, align 2, !dbg !536
  %21 = icmp ugt i16 %19, %20, !dbg !537
  store i1 %21, i1* %5, align 1, !dbg !523
  %22 = load i16, i16* %9, align 2, !dbg !538
  %23 = load i1, i1* %5, align 1, !dbg !539
  %24 = zext i1 %23 to i16, !dbg !540
  %25 = shl i16 %24, 6, !dbg !541
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %22, i16 14, i16 %25), !dbg !542
  %26 = load i1, i1* %5, align 1, !dbg !543
  br i1 %26, label %27, label %32, !dbg !522

27:                                               ; preds = %14
  %28 = load i16, i16* %6, align 2, !dbg !544
  %29 = load i16, i16* %7, align 2, !dbg !545
  %30 = sub i16 %28, %29, !dbg !546
  %31 = add i16 %30, 1, !dbg !547
  store i16 %31, i16* %4, align 2, !dbg !522
  br label %34, !dbg !522

32:                                               ; preds = %14
  %33 = load i16, i16* %6, align 2, !dbg !548
  store i16 %33, i16* %4, align 2, !dbg !522
  br label %34, !dbg !522

34:                                               ; preds = %27, %32
  %35 = load i16, i16* %4, align 2, !dbg !522
  store i16 %35, i16* %3, align 2, !dbg !520
  %36 = load i16, i16* %9, align 2, !dbg !549
  %37 = load i16, i16* %3, align 2, !dbg !550
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %36, i16 12, i16 %37), !dbg !551
  ret void, !dbg !522
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %0, i16 %1, i16 %2) !dbg !552 {
  %4 = alloca i16, i16 1, align 2, !dbg !554
  %5 = alloca i16, i16 1, align 2, !dbg !556
  %6 = alloca i16, i16 1, align 2, !dbg !557
  store i16 %0, i16* %6, align 2, !dbg !557
  store i16 %1, i16* %5, align 2, !dbg !556
  store i16 %2, i16* %4, align 2, !dbg !554
  %7 = load i16, i16* %6, align 2, !dbg !558
  %8 = getelementptr [6 x i16], [6 x i16]* @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.filters, i16 0, i16 %7, !dbg !559
  %9 = load i16, i16* %8, align 2, !dbg !559
  %10 = load i16, i16* %5, align 2, !dbg !560
  %11 = add i16 %9, %10, !dbg !561
  %12 = lshr i16 %11, 1, !dbg !562
  %13 = load i16, i16* %4, align 2, !dbg !563
  %14 = shl i16 %12, 1, !dbg !564
  %15 = inttoptr i16 %14 to i16*, !dbg !564
  store volatile i16 %13, i16* %15, align 2, !dbg !564
  call void asm sideeffect "nop", ""(), !dbg !564
  call void asm sideeffect "nop", ""(), !dbg !564
  ret void, !dbg !565
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %0, i16 %1) !dbg !566 {
  %3 = alloca i16, i16 1, align 2, !dbg !567
  %4 = alloca i16, i16 1, align 2, !dbg !569
  store i16 %0, i16* %4, align 2, !dbg !569
  store i16 %1, i16* %3, align 2, !dbg !567
  %5 = load i16, i16* %4, align 2, !dbg !570
  %6 = getelementptr [6 x i16], [6 x i16]* @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.filters, i16 0, i16 %5, !dbg !571
  %7 = load i16, i16* %6, align 2, !dbg !571
  %8 = load i16, i16* %3, align 2, !dbg !572
  %9 = add i16 %7, %8, !dbg !573
  %10 = lshr i16 %9, 1, !dbg !574
  %11 = shl i16 %10, 1, !dbg !575
  %12 = inttoptr i16 %11 to i16*, !dbg !575
  call void asm sideeffect "nop", ""(), !dbg !575
  call void asm sideeffect "nop", ""(), !dbg !575
  %13 = load volatile i16, i16* %12, align 2, !dbg !575
  ret i16 %13, !dbg !576
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 %0) !dbg !577 {
  %2 = alloca i16, i16 1, align 2, !dbg !579
  %3 = alloca i16, i16 1, align 2, !dbg !581
  %4 = alloca i16, i16 1, align 2, !dbg !582
  %5 = alloca i16, i16 1, align 2, !dbg !583
  store i16 %0, i16* %5, align 2, !dbg !583
  %6 = load i16, i16* %5, align 2, !dbg !584
  store i16 %6, i16* %4, align 2, !dbg !582
  %7 = load i16, i16* %4, align 2, !dbg !585
  %8 = add i16 %7, 31744, !dbg !586
  store i16 %8, i16* %3, align 2, !dbg !581
  %9 = load i16, i16* %3, align 2, !dbg !587
  %10 = shl i16 %9, 1, !dbg !588
  %11 = inttoptr i16 %10 to i16*, !dbg !588
  call void asm sideeffect "nop", ""(), !dbg !588
  call void asm sideeffect "nop", ""(), !dbg !588
  %12 = load volatile i16, i16* %11, align 2, !dbg !588
  store i16 %12, i16* %2, align 2, !dbg !579
  %13 = load i16, i16* %3, align 2, !dbg !589
  %14 = load i16, i16* %2, align 2, !dbg !590
  %15 = and i16 %14, 32767, !dbg !591
  %16 = shl i16 %13, 1, !dbg !592
  %17 = inttoptr i16 %16 to i16*, !dbg !592
  store volatile i16 %15, i16* %17, align 2, !dbg !592
  call void asm sideeffect "nop", ""(), !dbg !592
  call void asm sideeffect "nop", ""(), !dbg !592
  ret void, !dbg !593
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord() !dbg !594 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 2), !dbg !596
  %2 = sub i16 %1, 4, !dbg !598
  ret i16 %2, !dbg !599
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord() !dbg !600 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 0), !dbg !601
  %2 = sub i16 %1, 1, !dbg !603
  ret i16 %2, !dbg !604
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 %0) !dbg !605 {
  %2 = alloca i16, i16 1, align 2, !dbg !607
  %3 = alloca i16, i16 1, align 2, !dbg !609
  store i16 %0, i16* %3, align 2, !dbg !609
  %4 = load i16, i16* %3, align 2, !dbg !610
  %5 = lshr i16 %4, 1, !dbg !611
  %6 = add i16 %5, 31813, !dbg !612
  %7 = shl i16 %6, 1, !dbg !613
  %8 = inttoptr i16 %7 to i16*, !dbg !613
  call void asm sideeffect "nop", ""(), !dbg !613
  call void asm sideeffect "nop", ""(), !dbg !613
  %9 = load volatile i16, i16* %8, align 2, !dbg !613
  store i16 %9, i16* %2, align 2, !dbg !607
  %10 = load i16, i16* %2, align 2, !dbg !614
  %11 = and i16 %10, 2047, !dbg !615
  ret i16 %11, !dbg !616
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord() !dbg !617 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord(), !dbg !619
  ret i16 %1, !dbg !621
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.get_y_coord() !dbg !622 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord(), !dbg !623
  ret i16 %1, !dbg !625
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval(i16 %0) !dbg !626 {
  %2 = alloca i16, i16 1, align 2, !dbg !627
  store i16 %0, i16* %2, align 2, !dbg !627
  %3 = load i16, i16* %2, align 2, !dbg !629
  %4 = icmp ult i16 %3, 24, !dbg !630
  br i1 %4, label %5, label %7, !dbg !631

5:                                                ; preds = %10, %11, %1
  %6 = phi i16 [ 0, %10 ], [ 0, %11 ], [ 1, %1 ]
  br label %12, !dbg !631

7:                                                ; preds = %1
  %8 = load i16, i16* %2, align 2, !dbg !632
  %9 = icmp eq i16 31, %8, !dbg !633
  br i1 %9, label %10, label %11, !dbg !634

10:                                               ; preds = %7
  br label %5, !dbg !634

11:                                               ; preds = %7
  call void asm sideeffect "hcf", ""(), !dbg !634
  br label %5, !dbg !634

12:                                               ; preds = %5
  %13 = phi i16 [ %6, %5 ]
  br label %14, !dbg !631

14:                                               ; preds = %12
  ret i16 %13, !dbg !631
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7) !dbg !635 {
  %9 = alloca i16, i16 1, align 2, !dbg !636
  %10 = alloca i16, i16 1, align 2, !dbg !638
  %11 = alloca i16, i16 1, align 2, !dbg !639
  %12 = alloca i16, i16 1, align 2, !dbg !640
  %13 = alloca i16, i16 1, align 2, !dbg !641
  %14 = alloca i16, i16 1, align 2, !dbg !642
  %15 = alloca i16, i16 1, align 2, !dbg !643
  %16 = alloca i16, i16 1, align 2, !dbg !644
  %17 = alloca i16, i16 1, align 2, !dbg !645
  store i16 %0, i16* %17, align 2, !dbg !645
  store i16 %1, i16* %16, align 2, !dbg !644
  store i16 %2, i16* %15, align 2, !dbg !643
  store i16 %3, i16* %14, align 2, !dbg !642
  store i16 %4, i16* %13, align 2, !dbg !641
  store i16 %5, i16* %12, align 2, !dbg !640
  store i16 %6, i16* %11, align 2, !dbg !639
  store i16 %7, i16* %10, align 2, !dbg !638
  %18 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !646
  store i16 %18, i16* %9, align 2, !dbg !636
  %19 = load i16, i16* %11, align 2, !dbg !647
  store i16 %19, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_c, align 2, !dbg !648
  %20 = load i16, i16* %10, align 2, !dbg !649
  store i16 %20, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_is_half, align 2, !dbg !650
  %21 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_c, align 2, !dbg !651
  %22 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval(i16 %21), !dbg !652
  store i16 %22, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !653
  store i16 0, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !654
  %23 = load i16, i16* %16, align 2, !dbg !655
  store i16 %23, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !656
  %24 = load i16, i16* %15, align 2, !dbg !657
  store i16 %24, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !658
  %25 = load i16, i16* %15, align 2, !dbg !659
  %26 = load i16, i16* %13, align 2, !dbg !660
  %27 = add i16 %25, %26, !dbg !661
  %28 = sub i16 %27, 1, !dbg !662
  store i16 %28, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_last, align 2, !dbg !663
  %29 = load i16, i16* %9, align 2, !dbg !664
  %30 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_last, align 2, !dbg !665
  %31 = icmp eq i16 %29, %30, !dbg !666
  br i1 %31, label %32, label %37, !dbg !667

32:                                               ; preds = %8
  %33 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !668
  %34 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !668
  %35 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !668
  store i16 %33, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !669
  store i16 lshr (i16 ptrtoint ([1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.ctrl_1 to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !669
  store i16 %34, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !669
  store i16 %35, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !669
  %36 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.ctrl_1, i16 0, i1 false), align 4, !dbg !670
  store i32 %36, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i1 false), align 4, !dbg !671
  br label %42, !dbg !667

37:                                               ; preds = %8
  %38 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !672
  %39 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !672
  %40 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !672
  store i16 %38, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !673
  store i16 lshr (i16 ptrtoint ([1 x i32]* @"$$csl_base_address$$0$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11" to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !673
  store i16 %39, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !673
  store i16 %40, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !673
  %41 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @"$$csl_base_address$$0$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11", i16 0, i1 false), align 4, !dbg !674
  store i32 %41, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i1 false), align 4, !dbg !675
  br label %42, !dbg !667

42:                                               ; preds = %32, %37
  store i32 165646921, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i2 1), align 4, !dbg !676
  %43 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !677
  %44 = icmp eq i16 0, %43, !dbg !678
  br i1 %44, label %45, label %56, !dbg !679

45:                                               ; preds = %42
  %46 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !680
  %47 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !680
  %48 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !680
  %49 = load i16, i16* %17, align 2, !dbg !681
  %50 = call i16* @.get_tensor_ptr(i16 %49), !dbg !682
  %51 = ptrtoint i16* %50 to i16, !dbg !683
  %52 = lshr i16 %51, 1, !dbg !683
  store i16 %46, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !684
  store i16 %52, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !684
  store i16 %47, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !684
  store i16 %48, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !684
  %53 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !685
  %54 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !685
  %55 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !685
  store i16 1, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !686
  store i16 %53, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !686
  store i16 %54, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !686
  store i16 %55, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !686
  call void @llvm.sdr.actvt.r(i16 21), !dbg !687
  br label %63, !dbg !679

56:                                               ; preds = %42
  %57 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !688
  %58 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !688
  %59 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !688
  store i16 %57, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !689
  store i16 lshr (i16 ptrtoint ([1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.data_buf to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !689
  store i16 %58, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !689
  store i16 %59, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !689
  %60 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !690
  %61 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !690
  %62 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !690
  store i16 1, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !691
  store i16 %60, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !691
  store i16 %61, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !691
  store i16 %62, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !691
  call void @llvm.sdr.ublk.r(i16 0), !dbg !692
  br label %63, !dbg !679

63:                                               ; preds = %45, %56
  ret void, !dbg !667
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x(i32 %0) #8 !dbg !693 {
  %2 = alloca i32, i16 1, align 4, !dbg !694
  store i32 %0, i32* %2, align 4, !dbg !694
  call void @llvm.sdr.blk.r(i16 0), !dbg !696
  %3 = load i32, i32* %2, align 4, !dbg !697
  store i32 %3, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.data_buf, i16 0, i1 false), align 4, !dbg !698
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !699
  %4 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !700
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !700
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !700
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !700
  store volatile i16 %4, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !701
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !701
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !701
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !701
  call void asm sideeffect "nop", ""(), !dbg !701
  call void asm sideeffect "nop", ""(), !dbg !701
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !702
  %8 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !703
  %9 = add i16 %8, 1, !dbg !704
  store i16 %9, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !705
  ret void, !dbg !706
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_send_data() #9 !dbg !707 {
  %1 = alloca i16, i16 1, align 2, !dbg !708
  %2 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !710
  %3 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !711
  %4 = icmp ult i16 %2, %3, !dbg !712
  br i1 %4, label %5, label %27, !dbg !713

5:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !714
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !715
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !715
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !715
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !715
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !716
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !716
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !716
  store volatile i16 %9, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !716
  call void asm sideeffect "nop", ""(), !dbg !716
  call void asm sideeffect "nop", ""(), !dbg !716
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_is_half, align 2, !dbg !717
  %11 = icmp ult i16 0, %10, !dbg !718
  br i1 %11, label %12, label %18, !dbg !719

12:                                               ; preds = %5
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !720
  %13 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !721
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !721
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !721
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !721
  %17 = add i16 %14, 1, !dbg !722
  store i16 %13, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !723
  store i16 %17, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !723
  store i16 %15, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !723
  store i16 %16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !723
  br label %24, !dbg !719

18:                                               ; preds = %5
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !724
  %19 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !725
  %20 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !725
  %21 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !725
  %22 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !725
  %23 = add i16 %20, 2, !dbg !726
  store i16 %19, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !727
  store i16 %23, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !727
  store i16 %21, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !727
  store i16 %22, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !727
  br label %24, !dbg !719

24:                                               ; preds = %12, %18
  %25 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !728
  %26 = add i16 %25, 1, !dbg !729
  store i16 %26, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !730
  br label %34, !dbg !713

27:                                               ; preds = %0
  %28 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !731
  store i16 %28, i16* %1, align 2, !dbg !708
  %29 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !732
  %30 = load i16, i16* %1, align 2, !dbg !733
  %31 = icmp eq i16 %29, %30, !dbg !734
  br i1 %31, label %32, label %33, !dbg !735

32:                                               ; preds = %27
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !736
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__1 to i8*)), !dbg !737
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !738
  br label %33, !dbg !735

33:                                               ; preds = %32, %27
  br label %34, !dbg !713

34:                                               ; preds = %24, %33
  ret void, !dbg !713
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl() #10 !dbg !739 {
  %1 = alloca i16, i16 1, align 2, !dbg !740
  %2 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !742
  %3 = icmp eq i16 0, %2, !dbg !743
  br i1 %3, label %4, label %9, !dbg !744

4:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__2 to i8*)), !dbg !745
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !746
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !746
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !746
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !746
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !747
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !747
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !747
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !747
  call void asm sideeffect "nop", ""(), !dbg !747
  call void asm sideeffect "nop", ""(), !dbg !747
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !748
  br label %31, !dbg !744

9:                                                ; preds = %0
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !749
  %11 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !750
  %12 = icmp ult i16 %10, %11, !dbg !751
  br i1 %12, label %13, label %18, !dbg !752

13:                                               ; preds = %9
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__3 to i8*)), !dbg !753
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !754
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !754
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !754
  %17 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !754
  store volatile i16 %14, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !755
  store volatile i16 %15, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !755
  store volatile i16 %16, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !755
  store volatile i16 %17, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !755
  call void asm sideeffect "nop", ""(), !dbg !755
  call void asm sideeffect "nop", ""(), !dbg !755
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !756
  br label %30, !dbg !752

18:                                               ; preds = %9
  %19 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !757
  store i16 %19, i16* %1, align 2, !dbg !740
  %20 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !758
  %21 = load i16, i16* %1, align 2, !dbg !759
  %22 = icmp eq i16 %20, %21, !dbg !760
  br i1 %22, label %23, label %24, !dbg !761

23:                                               ; preds = %18
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__4 to i8*)), !dbg !762
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__5 to i8*)), !dbg !763
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !764
  br label %29, !dbg !761

24:                                               ; preds = %18
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !765
  %25 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !766
  %26 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !766
  %27 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !766
  %28 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !766
  store volatile i16 %25, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !767
  store volatile i16 %26, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !767
  store volatile i16 %27, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !767
  store volatile i16 %28, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !767
  call void asm sideeffect "nop", ""(), !dbg !767
  call void asm sideeffect "nop", ""(), !dbg !767
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !768
  br label %29, !dbg !761

29:                                               ; preds = %23, %24
  br label %30, !dbg !752

30:                                               ; preds = %13, %29
  br label %31, !dbg !744

31:                                               ; preds = %4, %30
  ret void, !dbg !744
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.d2h_configure(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7) !dbg !769 {
  %9 = alloca i1, i16 1, align 1, !dbg !770
  %10 = alloca i1, i16 1, align 1, !dbg !772
  %11 = alloca i1, i16 1, align 1, !dbg !773
  %12 = alloca i16, i16 1, align 2, !dbg !774
  %13 = alloca i16, i16 1, align 2, !dbg !775
  %14 = alloca i16, i16 1, align 2, !dbg !776
  %15 = alloca i16, i16 1, align 2, !dbg !777
  %16 = alloca i16, i16 1, align 2, !dbg !778
  %17 = alloca i16, i16 1, align 2, !dbg !779
  %18 = alloca i16, i16 1, align 2, !dbg !780
  %19 = alloca i16, i16 1, align 2, !dbg !781
  %20 = alloca i16, i16 1, align 2, !dbg !782
  %21 = alloca i16, i16 1, align 2, !dbg !783
  %22 = alloca i16, i16 1, align 2, !dbg !784
  %23 = alloca i16, i16 1, align 2, !dbg !785
  %24 = alloca i16, i16 1, align 2, !dbg !786
  %25 = alloca i16, i16 1, align 2, !dbg !787
  store i16 %0, i16* %25, align 2, !dbg !787
  store i16 %1, i16* %24, align 2, !dbg !786
  store i16 %2, i16* %23, align 2, !dbg !785
  store i16 %3, i16* %22, align 2, !dbg !784
  store i16 %4, i16* %21, align 2, !dbg !783
  store i16 %5, i16* %20, align 2, !dbg !782
  store i16 %6, i16* %19, align 2, !dbg !781
  store i16 %7, i16* %18, align 2, !dbg !780
  %26 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !788
  store i16 %26, i16* %17, align 2, !dbg !779
  %27 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_y_coord(), !dbg !789
  store i16 %27, i16* %16, align 2, !dbg !778
  %28 = load i16, i16* %24, align 2, !dbg !790
  store i16 %28, i16* %15, align 2, !dbg !777
  %29 = load i16, i16* %24, align 2, !dbg !791
  %30 = load i16, i16* %22, align 2, !dbg !792
  %31 = add i16 %29, %30, !dbg !793
  %32 = sub i16 %31, 1, !dbg !794
  store i16 %32, i16* %14, align 2, !dbg !776
  %33 = load i16, i16* %23, align 2, !dbg !795
  store i16 %33, i16* %13, align 2, !dbg !775
  %34 = load i16, i16* %23, align 2, !dbg !796
  %35 = load i16, i16* %21, align 2, !dbg !797
  %36 = add i16 %34, %35, !dbg !798
  %37 = sub i16 %36, 1, !dbg !799
  store i16 %37, i16* %12, align 2, !dbg !774
  store i1 false, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !800
  %38 = load i16, i16* %17, align 2, !dbg !801
  %39 = load i16, i16* %15, align 2, !dbg !802
  %40 = icmp sge i16 %38, %39, !dbg !803
  br i1 %40, label %41, label %45, !dbg !773

41:                                               ; preds = %8
  %42 = load i16, i16* %16, align 2, !dbg !804
  %43 = load i16, i16* %12, align 2, !dbg !805
  %44 = icmp sle i16 %42, %43, !dbg !806
  store i1 %44, i1* %11, align 1, !dbg !773
  br label %46, !dbg !773

45:                                               ; preds = %8
  store i1 false, i1* %11, align 1, !dbg !773
  br label %46, !dbg !773

46:                                               ; preds = %41, %45
  %47 = load i1, i1* %11, align 1, !dbg !773
  br i1 %47, label %48, label %52, !dbg !772

48:                                               ; preds = %46
  %49 = load i16, i16* %16, align 2, !dbg !807
  %50 = load i16, i16* %13, align 2, !dbg !808
  %51 = icmp sge i16 %49, %50, !dbg !809
  store i1 %51, i1* %10, align 1, !dbg !772
  br label %53, !dbg !772

52:                                               ; preds = %46
  store i1 false, i1* %10, align 1, !dbg !772
  br label %53, !dbg !772

53:                                               ; preds = %48, %52
  %54 = load i1, i1* %10, align 1, !dbg !772
  br i1 %54, label %55, label %56, !dbg !810

55:                                               ; preds = %53
  store i1 true, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !811
  br label %56, !dbg !810

56:                                               ; preds = %55, %53
  store i1 false, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !812
  %57 = load i16, i16* %17, align 2, !dbg !813
  %58 = load i16, i16* %14, align 2, !dbg !814
  %59 = icmp sle i16 %57, %58, !dbg !815
  br i1 %59, label %60, label %62, !dbg !770

60:                                               ; preds = %56
  %61 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !816
  store i1 %61, i1* %9, align 1, !dbg !770
  br label %63, !dbg !770

62:                                               ; preds = %56
  store i1 false, i1* %9, align 1, !dbg !770
  br label %63, !dbg !770

63:                                               ; preds = %60, %62
  %64 = load i1, i1* %9, align 1, !dbg !770
  br i1 %64, label %65, label %66, !dbg !817

65:                                               ; preds = %63
  store i1 true, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !818
  br label %66, !dbg !817

66:                                               ; preds = %65, %63
  %67 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !819
  br i1 %67, label %68, label %86, !dbg !820

68:                                               ; preds = %66
  call void @__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position(i16 31959), !dbg !821
  %69 = load i16, i16* %15, align 2, !dbg !822
  %70 = load i16, i16* %17, align 2, !dbg !823
  %71 = icmp eq i16 %69, %70, !dbg !824
  br i1 %71, label %72, label %73, !dbg !825

72:                                               ; preds = %68
  call void @__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 31765), !dbg !826
  br label %74, !dbg !825

73:                                               ; preds = %68
  call void @__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 31765), !dbg !827
  br label %74, !dbg !825

74:                                               ; preds = %72, %73
  call void @sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit(i16 21), !dbg !828
  %75 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !829
  br i1 %75, label %76, label %85, !dbg !830

76:                                               ; preds = %74
  %77 = load i16, i16* %20, align 2, !dbg !831
  %78 = load i16, i16* %19, align 2, !dbg !832
  %79 = load i16, i16* %24, align 2, !dbg !833
  %80 = load i16, i16* %23, align 2, !dbg !834
  %81 = load i16, i16* %22, align 2, !dbg !835
  %82 = load i16, i16* %21, align 2, !dbg !836
  %83 = load i16, i16* %25, align 2, !dbg !837
  %84 = load i16, i16* %18, align 2, !dbg !838
  call void @sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start(i16 %77, i16 %78, i16 %79, i16 %80, i16 %81, i16 %82, i16 %83, i16 %84), !dbg !839
  br label %85, !dbg !830

85:                                               ; preds = %76, %74
  br label %87, !dbg !820

86:                                               ; preds = %66
  call void @llvm.sdr.actvt.r(i16 28), !dbg !840
  br label %87, !dbg !820

87:                                               ; preds = %85, %86
  ret void, !dbg !773
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit(i16 %0) !dbg !841 {
  %2 = alloca i16, i16 1, align 2, !dbg !842
  %3 = alloca i16, i16 1, align 2, !dbg !844
  %4 = alloca i16, i16 1, align 2, !dbg !845
  %5 = alloca i16, i16 1, align 2, !dbg !846
  store i16 %0, i16* %5, align 2, !dbg !846
  %6 = load i16, i16* %5, align 2, !dbg !847
  store i16 %6, i16* %4, align 2, !dbg !845
  %7 = load i16, i16* %4, align 2, !dbg !848
  %8 = add i16 %7, 31744, !dbg !849
  store i16 %8, i16* %3, align 2, !dbg !844
  %9 = load i16, i16* %3, align 2, !dbg !850
  %10 = shl i16 %9, 1, !dbg !851
  %11 = inttoptr i16 %10 to i16*, !dbg !851
  call void asm sideeffect "nop", ""(), !dbg !851
  call void asm sideeffect "nop", ""(), !dbg !851
  %12 = load volatile i16, i16* %11, align 2, !dbg !851
  store i16 %12, i16* %2, align 2, !dbg !842
  %13 = load i16, i16* %3, align 2, !dbg !852
  %14 = load i16, i16* %2, align 2, !dbg !853
  %15 = and i16 %14, 32767, !dbg !854
  %16 = shl i16 %13, 1, !dbg !855
  %17 = inttoptr i16 %16 to i16*, !dbg !855
  store volatile i16 %15, i16* %17, align 2, !dbg !855
  call void asm sideeffect "nop", ""(), !dbg !855
  call void asm sideeffect "nop", ""(), !dbg !855
  ret void, !dbg !856
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord() !dbg !857 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 2), !dbg !858
  %2 = sub i16 %1, 4, !dbg !860
  ret i16 %2, !dbg !861
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord() !dbg !862 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 0), !dbg !863
  %2 = sub i16 %1, 1, !dbg !865
  ret i16 %2, !dbg !866
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 %0) !dbg !867 {
  %2 = alloca i16, i16 1, align 2, !dbg !868
  %3 = alloca i16, i16 1, align 2, !dbg !870
  store i16 %0, i16* %3, align 2, !dbg !870
  %4 = load i16, i16* %3, align 2, !dbg !871
  %5 = lshr i16 %4, 1, !dbg !872
  %6 = add i16 %5, 31813, !dbg !873
  %7 = shl i16 %6, 1, !dbg !874
  %8 = inttoptr i16 %7 to i16*, !dbg !874
  call void asm sideeffect "nop", ""(), !dbg !874
  call void asm sideeffect "nop", ""(), !dbg !874
  %9 = load volatile i16, i16* %8, align 2, !dbg !874
  store i16 %9, i16* %2, align 2, !dbg !868
  %10 = load i16, i16* %2, align 2, !dbg !875
  %11 = and i16 %10, 2047, !dbg !876
  ret i16 %11, !dbg !877
}

define internal i16 @sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr(i16 %0) !dbg !878 {
  %2 = alloca i16, i16 1, align 2, !dbg !880
  store i16 %0, i16* %2, align 2, !dbg !880
  %3 = load i16, i16* %2, align 2, !dbg !882
  %4 = mul i16 %3, 2, !dbg !883
  %5 = add i16 %4, 31680, !dbg !884
  ret i16 %5, !dbg !885
}

define internal void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 %0, i16 %1, i1 %2) !dbg !886 {
  %4 = alloca i16, i16 1, align 2, !dbg !887
  %5 = alloca i16, i16 1, align 2, !dbg !889
  %6 = alloca i1, i16 1, align 1, !dbg !890
  %7 = alloca i16, i16 1, align 2, !dbg !891
  %8 = alloca i16, i16 1, align 2, !dbg !892
  store i16 %0, i16* %8, align 2, !dbg !892
  store i16 %1, i16* %7, align 2, !dbg !891
  store i1 %2, i1* %6, align 1, !dbg !890
  %9 = load i16, i16* %8, align 2, !dbg !893
  %10 = call i16 @sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr(i16 %9), !dbg !894
  store i16 %10, i16* %5, align 2, !dbg !889
  %11 = load i16, i16* %5, align 2, !dbg !895
  %12 = shl i16 %11, 1, !dbg !896
  %13 = inttoptr i16 %12 to i16*, !dbg !896
  call void asm sideeffect "nop", ""(), !dbg !896
  call void asm sideeffect "nop", ""(), !dbg !896
  call void asm sideeffect "nop", ""(), !dbg !896
  call void asm sideeffect "nop", ""(), !dbg !896
  %14 = load volatile i16, i16* %13, align 2, !dbg !896
  store i16 %14, i16* %4, align 2, !dbg !887
  %15 = load i1, i1* %6, align 1, !dbg !897
  br i1 %15, label %16, label %19, !dbg !898

16:                                               ; preds = %3
  %17 = load i16, i16* %4, align 2, !dbg !899
  %18 = or i16 %17, 2048, !dbg !900
  store i16 %18, i16* %4, align 2, !dbg !901
  br label %22, !dbg !898

19:                                               ; preds = %3
  %20 = load i16, i16* %4, align 2, !dbg !902
  %21 = and i16 %20, -2049, !dbg !903
  store i16 %21, i16* %4, align 2, !dbg !904
  br label %22, !dbg !898

22:                                               ; preds = %16, %19
  %23 = load i16, i16* %4, align 2, !dbg !905
  %24 = and i16 %23, -32, !dbg !906
  store i16 %24, i16* %4, align 2, !dbg !907
  %25 = load i16, i16* %4, align 2, !dbg !908
  %26 = load i16, i16* %7, align 2, !dbg !909
  %27 = add i16 %25, %26, !dbg !910
  store i16 %27, i16* %4, align 2, !dbg !911
  %28 = load i16, i16* %5, align 2, !dbg !912
  %29 = load i16, i16* %4, align 2, !dbg !913
  %30 = shl i16 %28, 1, !dbg !914
  %31 = inttoptr i16 %30 to i16*, !dbg !914
  store volatile i16 %29, i16* %31, align 2, !dbg !914
  call void asm sideeffect "nop", ""(), !dbg !914
  call void asm sideeffect "nop", ""(), !dbg !914
  call void asm sideeffect "nop", ""(), !dbg !914
  call void asm sideeffect "nop", ""(), !dbg !914
  ret void, !dbg !898
}

define internal i16 @sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr(i16 %0) !dbg !915 {
  %2 = alloca i16, i16 1, align 2, !dbg !917
  store i16 %0, i16* %2, align 2, !dbg !917
  %3 = load i16, i16* %2, align 2, !dbg !919
  %4 = add i16 %3, 31616, !dbg !920
  ret i16 %4, !dbg !921
}

define internal void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 %0, i16 %1) !dbg !922 {
  %3 = alloca i16, i16 1, align 2, !dbg !923
  %4 = alloca i16, i16 1, align 2, !dbg !925
  %5 = alloca i16, i16 1, align 2, !dbg !926
  %6 = alloca i16, i16 1, align 2, !dbg !927
  store i16 %0, i16* %6, align 2, !dbg !927
  store i16 %1, i16* %5, align 2, !dbg !926
  %7 = load i16, i16* %6, align 2, !dbg !928
  %8 = call i16 @sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr(i16 %7), !dbg !929
  store i16 %8, i16* %4, align 2, !dbg !925
  %9 = load i16, i16* %4, align 2, !dbg !930
  %10 = shl i16 %9, 1, !dbg !931
  %11 = inttoptr i16 %10 to i16*, !dbg !931
  call void asm sideeffect "nop", ""(), !dbg !931
  call void asm sideeffect "nop", ""(), !dbg !931
  call void asm sideeffect "nop", ""(), !dbg !931
  call void asm sideeffect "nop", ""(), !dbg !931
  %12 = load volatile i16, i16* %11, align 2, !dbg !931
  store i16 %12, i16* %3, align 2, !dbg !923
  %13 = load i16, i16* %3, align 2, !dbg !932
  %14 = and i16 %13, -497, !dbg !933
  store i16 %14, i16* %3, align 2, !dbg !934
  %15 = load i16, i16* %3, align 2, !dbg !935
  %16 = load i16, i16* %5, align 2, !dbg !936
  %17 = add i16 %15, %16, !dbg !937
  %18 = shl i16 %17, 4, !dbg !938
  store i16 %18, i16* %3, align 2, !dbg !939
  %19 = load i16, i16* %4, align 2, !dbg !940
  %20 = load i16, i16* %3, align 2, !dbg !941
  %21 = shl i16 %19, 1, !dbg !942
  %22 = inttoptr i16 %21 to i16*, !dbg !942
  store volatile i16 %20, i16* %22, align 2, !dbg !942
  call void asm sideeffect "nop", ""(), !dbg !942
  call void asm sideeffect "nop", ""(), !dbg !942
  call void asm sideeffect "nop", ""(), !dbg !942
  call void asm sideeffect "nop", ""(), !dbg !942
  ret void, !dbg !943
}

define internal i16* @.get_tensor_ptr(i16 %0) !dbg !944 {
  %2 = alloca i16, i16 1, align 2, !dbg !945
  store i16 %0, i16* %2, align 2, !dbg !945
  %3 = load i16, i16* %2, align 2, !dbg !945
  %4 = zext i16 %3 to i32, !dbg !945
  switch i32 %4, label %5 [
    i32 1, label %9
    i32 2, label %11
    i32 3, label %13
    i32 4, label %15
    i32 5, label %17
  ], !dbg !945

5:                                                ; preds = %1
  br i1 false, label %6, label %7, !dbg !945

6:                                                ; preds = %5
  br label %8, !dbg !945

7:                                                ; preds = %5
  call void asm sideeffect "hcf", ""(), !dbg !945
  br label %8, !dbg !945

8:                                                ; preds = %6, %7
  br label %19, !dbg !945

9:                                                ; preds = %1
  %10 = load i16*, i16** @p_a, align 8, !dbg !945
  br label %19, !dbg !945

11:                                               ; preds = %1
  %12 = load i16*, i16** @p_b, align 8, !dbg !945
  br label %19, !dbg !945

13:                                               ; preds = %1
  %14 = load i16*, i16** @p_c, align 8, !dbg !945
  br label %19, !dbg !945

15:                                               ; preds = %1
  %16 = load i16*, i16** @p_idx, align 8, !dbg !945
  br label %19, !dbg !945

17:                                               ; preds = %1
  %18 = load i16*, i16** @p_k, align 8, !dbg !945
  br label %19, !dbg !945

19:                                               ; preds = %8, %9, %11, %13, %15, %17
  %20 = phi i16 [ -2, %17 ], [ -2, %15 ], [ -2, %13 ], [ -2, %11 ], [ -2, %9 ], [ 0, %8 ]
  %21 = phi i16* [ %18, %17 ], [ %16, %15 ], [ %14, %13 ], [ %12, %11 ], [ %10, %9 ], [ undef, %8 ]
  br label %22, !dbg !945

22:                                               ; preds = %19
  %23 = icmp ne i16 %20, 0, !dbg !945
  br i1 %23, label %24, label %25, !dbg !945

24:                                               ; preds = %22
  br label %27, !dbg !945

25:                                               ; preds = %22
  %26 = load i16*, i16** @p_k, align 8, !dbg !945
  br label %27, !dbg !945

27:                                               ; preds = %24, %25
  %28 = phi i16* [ %26, %25 ], [ %21, %24 ]
  br label %29, !dbg !945

29:                                               ; preds = %27
  ret i16* %28, !dbg !945
}

define internal void @__generic0sys_mod.sys_mod.tile_config.queue_flush.exit() !dbg !947 {
  store volatile i16 1, i16* inttoptr (i16 -2268 to i16*), align 2, !dbg !949
  call void asm sideeffect "nop", ""(), !dbg !949
  call void asm sideeffect "nop", ""(), !dbg !949
  ret void, !dbg !951
}

define internal void @__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position(i16 %0) !dbg !952 {
  %2 = alloca i16, i16 1, align 2, !dbg !954
  %3 = alloca i16, i16 1, align 2, !dbg !956
  %4 = alloca i16, i16 1, align 2, !dbg !957
  store i16 %0, i16* %4, align 2, !dbg !957
  %5 = load i16, i16* %4, align 2, !dbg !958
  store i16 %5, i16* %3, align 2, !dbg !956
  %6 = load i16, i16* %3, align 2, !dbg !959
  %7 = shl i16 %6, 1, !dbg !960
  %8 = inttoptr i16 %7 to i16*, !dbg !960
  call void asm sideeffect "nop", ""(), !dbg !960
  call void asm sideeffect "nop", ""(), !dbg !960
  call void asm sideeffect "nop", ""(), !dbg !960
  call void asm sideeffect "nop", ""(), !dbg !960
  %9 = load volatile i16, i16* %8, align 2, !dbg !960
  store i16 %9, i16* %2, align 2, !dbg !954
  %10 = load i16, i16* %2, align 2, !dbg !961
  %11 = and i16 %10, -16, !dbg !962
  store i16 %11, i16* %2, align 2, !dbg !962
  %12 = load i16, i16* %3, align 2, !dbg !963
  %13 = load i16, i16* %2, align 2, !dbg !964
  %14 = shl i16 %12, 1, !dbg !965
  %15 = inttoptr i16 %14 to i16*, !dbg !965
  store volatile i16 %13, i16* %15, align 2, !dbg !965
  call void asm sideeffect "nop", ""(), !dbg !965
  call void asm sideeffect "nop", ""(), !dbg !965
  call void asm sideeffect "nop", ""(), !dbg !965
  call void asm sideeffect "nop", ""(), !dbg !965
  ret void, !dbg !966
}

define internal void @__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 %0) !dbg !967 {
  %2 = alloca i16, i16 1, align 2, !dbg !969
  %3 = alloca i16, i16 1, align 2, !dbg !971
  %4 = alloca i16, i16 1, align 2, !dbg !972
  store i16 %0, i16* %4, align 2, !dbg !972
  %5 = load i16, i16* %4, align 2, !dbg !973
  store i16 %5, i16* %3, align 2, !dbg !971
  %6 = load i16, i16* %3, align 2, !dbg !974
  %7 = shl i16 %6, 1, !dbg !975
  %8 = inttoptr i16 %7 to i16*, !dbg !975
  call void asm sideeffect "nop", ""(), !dbg !975
  call void asm sideeffect "nop", ""(), !dbg !975
  %9 = load volatile i16, i16* %8, align 2, !dbg !975
  store i16 %9, i16* %2, align 2, !dbg !969
  %10 = load i16, i16* %2, align 2, !dbg !976
  %11 = and i16 %10, -256, !dbg !977
  store i16 %11, i16* %2, align 2, !dbg !978
  %12 = load i16, i16* %2, align 2, !dbg !979
  %13 = load i16, i16* %2, align 2, !dbg !980
  %14 = call i16 @__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %13), !dbg !981
  %15 = or i16 %12, %14, !dbg !982
  store i16 %15, i16* %2, align 2, !dbg !982
  %16 = load i16, i16* %2, align 2, !dbg !983
  %17 = load i16, i16* %2, align 2, !dbg !984
  %18 = call i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %17), !dbg !985
  %19 = or i16 %16, %18, !dbg !986
  store i16 %19, i16* %2, align 2, !dbg !986
  %20 = load i16, i16* %3, align 2, !dbg !987
  %21 = load i16, i16* %2, align 2, !dbg !988
  %22 = shl i16 %20, 1, !dbg !989
  %23 = inttoptr i16 %22 to i16*, !dbg !989
  store volatile i16 %21, i16* %23, align 2, !dbg !989
  call void asm sideeffect "nop", ""(), !dbg !989
  call void asm sideeffect "nop", ""(), !dbg !989
  ret void, !dbg !990
}

define internal void @__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 %0) !dbg !991 {
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
  %9 = load volatile i16, i16* %8, align 2, !dbg !998
  store i16 %9, i16* %2, align 2, !dbg !992
  %10 = load i16, i16* %2, align 2, !dbg !999
  %11 = and i16 %10, -256, !dbg !1000
  store i16 %11, i16* %2, align 2, !dbg !1001
  %12 = load i16, i16* %2, align 2, !dbg !1002
  %13 = load i16, i16* %2, align 2, !dbg !1003
  %14 = call i16 @__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %13), !dbg !1004
  %15 = or i16 %12, %14, !dbg !1005
  store i16 %15, i16* %2, align 2, !dbg !1005
  %16 = load i16, i16* %2, align 2, !dbg !1006
  %17 = load i16, i16* %2, align 2, !dbg !1007
  %18 = call i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %17), !dbg !1008
  %19 = or i16 %16, %18, !dbg !1009
  store i16 %19, i16* %2, align 2, !dbg !1009
  %20 = load i16, i16* %3, align 2, !dbg !1010
  %21 = load i16, i16* %2, align 2, !dbg !1011
  %22 = shl i16 %20, 1, !dbg !1012
  %23 = inttoptr i16 %22 to i16*, !dbg !1012
  store volatile i16 %21, i16* %23, align 2, !dbg !1012
  call void asm sideeffect "nop", ""(), !dbg !1012
  call void asm sideeffect "nop", ""(), !dbg !1012
  ret void, !dbg !1013
}

define internal i16 @__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %0) !dbg !1014 {
  %2 = alloca i16, i16 1, align 2, !dbg !1015
  %3 = alloca i16, i16 1, align 2, !dbg !1017
  store i16 %0, i16* %3, align 2, !dbg !1017
  %4 = load i16, i16* %3, align 2, !dbg !1018
  store i16 %4, i16* %2, align 2, !dbg !1015
  %5 = load i16, i16* %2, align 2, !dbg !1019
  store i16 %5, i16* %2, align 2, !dbg !1020
  %6 = load i16, i16* %2, align 2, !dbg !1021
  ret i16 %6, !dbg !1022
}

define internal i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %0) !dbg !1023 {
  %2 = alloca i16, i16 1, align 2, !dbg !1024
  %3 = alloca i16, i16 1, align 2, !dbg !1026
  store i16 %0, i16* %3, align 2, !dbg !1026
  %4 = load i16, i16* %3, align 2, !dbg !1027
  store i16 %4, i16* %2, align 2, !dbg !1024
  %5 = load i16, i16* %2, align 2, !dbg !1028
  %6 = or i16 %5, 2, !dbg !1029
  store i16 %6, i16* %2, align 2, !dbg !1029
  %7 = load i16, i16* %2, align 2, !dbg !1030
  ret i16 %7, !dbg !1031
}

define internal i16 @__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %0) !dbg !1032 {
  %2 = alloca i16, i16 1, align 2, !dbg !1033
  %3 = alloca i16, i16 1, align 2, !dbg !1035
  store i16 %0, i16* %3, align 2, !dbg !1035
  %4 = load i16, i16* %3, align 2, !dbg !1036
  store i16 %4, i16* %2, align 2, !dbg !1033
  %5 = load i16, i16* %2, align 2, !dbg !1037
  %6 = or i16 %5, 128, !dbg !1038
  store i16 %6, i16* %2, align 2, !dbg !1038
  %7 = load i16, i16* %2, align 2, !dbg !1039
  ret i16 %7, !dbg !1040
}

define internal void @__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction(i16 %0) !dbg !1041 {
  %2 = alloca i16, i16 1, align 2, !dbg !1042
  %3 = alloca i16, i16 1, align 2, !dbg !1044
  %4 = alloca i16, i16 1, align 2, !dbg !1045
  store i16 %0, i16* %4, align 2, !dbg !1045
  %5 = load i16, i16* %4, align 2, !dbg !1046
  store i16 %5, i16* %3, align 2, !dbg !1044
  %6 = load i16, i16* %3, align 2, !dbg !1047
  %7 = shl i16 %6, 1, !dbg !1048
  %8 = inttoptr i16 %7 to i16*, !dbg !1048
  call void asm sideeffect "nop", ""(), !dbg !1048
  call void asm sideeffect "nop", ""(), !dbg !1048
  %9 = load volatile i16, i16* %8, align 2, !dbg !1048
  store i16 %9, i16* %2, align 2, !dbg !1042
  %10 = load i16, i16* %2, align 2, !dbg !1049
  %11 = and i16 %10, -17, !dbg !1050
  store i16 %11, i16* %2, align 2, !dbg !1050
  %12 = load i16, i16* %3, align 2, !dbg !1051
  %13 = load i16, i16* %2, align 2, !dbg !1052
  %14 = shl i16 %12, 1, !dbg !1053
  %15 = inttoptr i16 %14 to i16*, !dbg !1053
  store volatile i16 %13, i16* %15, align 2, !dbg !1053
  call void asm sideeffect "nop", ""(), !dbg !1053
  call void asm sideeffect "nop", ""(), !dbg !1053
  ret void, !dbg !1054
}

define internal void @__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction(i16 %0) !dbg !1055 {
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
  %11 = or i16 %10, 16, !dbg !1064
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
!4 = !DIFile(filename: "./pe.csl", directory: "/home/USER/xkernel/studies/wse3-characterization/microbench/addfam/cases/const_one")
!5 = !DISubroutineType(types: !6)
!6 = !{}
!7 = !DILocation(line: 16, column: 11, scope: !8)
!8 = !DILexicalBlockFile(scope: !3, file: !4, discriminator: 0)
!9 = !DILocation(line: 16, column: 15, scope: !8)
!10 = !DILocation(line: 16, column: 8, scope: !8)
!11 = !DILocation(line: 17, column: 3, scope: !8)
!12 = !DILocation(line: 15, column: 1, scope: !8)
!13 = distinct !DISubprogram(name: "f_exit", linkageName: "f_exit", scope: null, file: !4, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!14 = !DILocation(line: 20, column: 22, scope: !15)
!15 = !DILexicalBlockFile(scope: !13, file: !4, discriminator: 0)
!16 = !DILocation(line: 20, column: 1, scope: !15)
!17 = distinct !DISubprogram(name: "sys_mod.sys_nop", linkageName: "sys_mod.sys_nop", scope: null, file: !18, line: 90, type: !5, scopeLine: 90, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!18 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/memcpy.csl", directory: "")
!19 = !DILocation(line: 90, column: 1, scope: !20)
!20 = !DILexicalBlockFile(scope: !17, file: !18, discriminator: 0)
!21 = distinct !DISubprogram(name: "sys_mod.unblock_cmd_stream", linkageName: "sys_mod.unblock_cmd_stream", scope: null, file: !18, line: 102, type: !5, scopeLine: 102, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!22 = !DILocation(line: 103, column: 3, scope: !23)
!23 = !DILexicalBlockFile(scope: !21, file: !18, discriminator: 0)
!24 = !DILocation(line: 102, column: 1, scope: !23)
!25 = distinct !DISubprogram(name: "sys_mod.sys_mod.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.unblock_cmd_stream", scope: null, file: !26, line: 307, type: !5, scopeLine: 307, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!26 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpy.csl", directory: "")
!27 = !DILocation(line: 308, column: 5, scope: !28)
!28 = !DILexicalBlockFile(scope: !25, file: !26, discriminator: 0)
!29 = !DILocation(line: 307, column: 1, scope: !28)
!30 = distinct !DISubprogram(name: "sys_mod.sys_mod.teardown_h2d", linkageName: "sys_mod.sys_mod.teardown_h2d", scope: null, file: !26, line: 323, type: !5, scopeLine: 323, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!31 = !DILocation(line: 326, column: 5, scope: !32)
!32 = !DILexicalBlockFile(scope: !30, file: !26, discriminator: 0)
!33 = !DILocation(line: 323, column: 1, scope: !32)
!34 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_ublk_c22", linkageName: "sys_mod.sys_mod.f_ublk_c22", scope: null, file: !26, line: 335, type: !5, scopeLine: 335, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!35 = !DILocation(line: 336, column: 5, scope: !36)
!36 = !DILexicalBlockFile(scope: !34, file: !26, discriminator: 0)
!37 = !DILocation(line: 335, column: 1, scope: !36)
!38 = distinct !DISubprogram(name: "sys_mod.sys_mod.teardown_d2h", linkageName: "sys_mod.sys_mod.teardown_d2h", scope: null, file: !26, line: 344, type: !5, scopeLine: 344, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!39 = !DILocation(line: 355, column: 5, scope: !40)
!40 = !DILexicalBlockFile(scope: !38, file: !26, discriminator: 0)
!41 = !DILocation(line: 359, column: 5, scope: !40)
!42 = !DILocation(line: 344, column: 1, scope: !40)
!43 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_memcpyh2d", linkageName: "sys_mod.sys_mod.f_memcpyh2d", scope: null, file: !26, line: 460, type: !5, scopeLine: 460, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!44 = !DILocation(line: 477, column: 5, scope: !45)
!45 = !DILexicalBlockFile(scope: !43, file: !26, discriminator: 0)
!46 = !DILocation(line: 476, column: 5, scope: !45)
!47 = !DILocation(line: 475, column: 5, scope: !45)
!48 = !DILocation(line: 474, column: 5, scope: !45)
!49 = !DILocation(line: 473, column: 5, scope: !45)
!50 = !DILocation(line: 472, column: 5, scope: !45)
!51 = !DILocation(line: 471, column: 5, scope: !45)
!52 = !DILocation(line: 470, column: 5, scope: !45)
!53 = !DILocation(line: 469, column: 5, scope: !45)
!54 = !DILocation(line: 468, column: 5, scope: !45)
!55 = !DILocation(line: 467, column: 5, scope: !45)
!56 = !DILocation(line: 466, column: 5, scope: !45)
!57 = !DILocation(line: 465, column: 5, scope: !45)
!58 = !DILocation(line: 463, column: 5, scope: !45)
!59 = !DILocation(line: 462, column: 20, scope: !45)
!60 = !DILocation(line: 462, column: 32, scope: !45)
!61 = !DILocation(line: 462, column: 5, scope: !45)
!62 = !DILocation(line: 465, column: 33, scope: !45)
!63 = !DILocation(line: 465, column: 38, scope: !45)
!64 = !DILocation(line: 466, column: 34, scope: !45)
!65 = !DILocation(line: 466, column: 39, scope: !45)
!66 = !DILocation(line: 467, column: 34, scope: !45)
!67 = !DILocation(line: 467, column: 39, scope: !45)
!68 = !DILocation(line: 468, column: 33, scope: !45)
!69 = !DILocation(line: 468, column: 38, scope: !45)
!70 = !DILocation(line: 469, column: 33, scope: !45)
!71 = !DILocation(line: 469, column: 38, scope: !45)
!72 = !DILocation(line: 470, column: 35, scope: !45)
!73 = !DILocation(line: 470, column: 21, scope: !45)
!74 = !DILocation(line: 471, column: 41, scope: !45)
!75 = !DILocation(line: 471, column: 27, scope: !45)
!76 = !DILocation(line: 472, column: 39, scope: !45)
!77 = !DILocation(line: 472, column: 25, scope: !45)
!78 = !DILocation(line: 473, column: 44, scope: !45)
!79 = !DILocation(line: 473, column: 49, scope: !45)
!80 = !DILocation(line: 474, column: 41, scope: !45)
!81 = !DILocation(line: 474, column: 46, scope: !45)
!82 = !DILocation(line: 475, column: 41, scope: !45)
!83 = !DILocation(line: 475, column: 46, scope: !45)
!84 = !DILocation(line: 476, column: 59, scope: !45)
!85 = !DILocation(line: 476, column: 64, scope: !45)
!86 = !DILocation(line: 476, column: 50, scope: !45)
!87 = !DILocation(line: 476, column: 129, scope: !45)
!88 = !DILocation(line: 476, column: 134, scope: !45)
!89 = !DILocation(line: 476, column: 120, scope: !45)
!90 = !DILocation(line: 476, column: 118, scope: !45)
!91 = !DILocation(line: 476, column: 112, scope: !45)
!92 = !DILocation(line: 476, column: 36, scope: !45)
!93 = !DILocation(line: 477, column: 59, scope: !45)
!94 = !DILocation(line: 477, column: 64, scope: !45)
!95 = !DILocation(line: 477, column: 50, scope: !45)
!96 = !DILocation(line: 477, column: 129, scope: !45)
!97 = !DILocation(line: 477, column: 134, scope: !45)
!98 = !DILocation(line: 477, column: 120, scope: !45)
!99 = !DILocation(line: 477, column: 118, scope: !45)
!100 = !DILocation(line: 477, column: 112, scope: !45)
!101 = !DILocation(line: 477, column: 36, scope: !45)
!102 = !DILocation(line: 479, column: 24, scope: !45)
!103 = !DILocation(line: 481, column: 21, scope: !45)
!104 = !DILocation(line: 481, column: 19, scope: !45)
!105 = !DILocation(line: 482, column: 21, scope: !45)
!106 = !DILocation(line: 482, column: 19, scope: !45)
!107 = !DILocation(line: 483, column: 21, scope: !45)
!108 = !DILocation(line: 483, column: 19, scope: !45)
!109 = !DILocation(line: 484, column: 20, scope: !45)
!110 = !DILocation(line: 484, column: 18, scope: !45)
!111 = !DILocation(line: 485, column: 20, scope: !45)
!112 = !DILocation(line: 485, column: 18, scope: !45)
!113 = !DILocation(line: 486, column: 22, scope: !45)
!114 = !DILocation(line: 486, column: 20, scope: !45)
!115 = !DILocation(line: 487, column: 27, scope: !45)
!116 = !DILocation(line: 487, column: 25, scope: !45)
!117 = !DILocation(line: 488, column: 25, scope: !45)
!118 = !DILocation(line: 488, column: 23, scope: !45)
!119 = !DILocation(line: 489, column: 31, scope: !45)
!120 = !DILocation(line: 489, column: 29, scope: !45)
!121 = !DILocation(line: 490, column: 28, scope: !45)
!122 = !DILocation(line: 490, column: 26, scope: !45)
!123 = !DILocation(line: 491, column: 28, scope: !45)
!124 = !DILocation(line: 491, column: 26, scope: !45)
!125 = !DILocation(line: 492, column: 37, scope: !45)
!126 = !DILocation(line: 492, column: 35, scope: !45)
!127 = !DILocation(line: 493, column: 37, scope: !45)
!128 = !DILocation(line: 493, column: 35, scope: !45)
!129 = !DILocation(line: 495, column: 5, scope: !45)
!130 = !DILocation(line: 501, column: 5, scope: !45)
!131 = !DILocation(line: 506, column: 5, scope: !45)
!132 = !DILocation(line: 521, column: 5, scope: !45)
!133 = !DILocation(line: 522, column: 16, scope: !45)
!134 = !DILocation(line: 531, column: 5, scope: !45)
!135 = !DILocation(line: 460, column: 1, scope: !45)
!136 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_memcpyd2h", linkageName: "sys_mod.sys_mod.f_memcpyd2h", scope: null, file: !26, line: 556, type: !5, scopeLine: 556, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!137 = !DILocation(line: 568, column: 5, scope: !138)
!138 = !DILexicalBlockFile(scope: !136, file: !26, discriminator: 0)
!139 = !DILocation(line: 567, column: 5, scope: !138)
!140 = !DILocation(line: 566, column: 5, scope: !138)
!141 = !DILocation(line: 565, column: 5, scope: !138)
!142 = !DILocation(line: 564, column: 5, scope: !138)
!143 = !DILocation(line: 563, column: 5, scope: !138)
!144 = !DILocation(line: 562, column: 5, scope: !138)
!145 = !DILocation(line: 561, column: 5, scope: !138)
!146 = !DILocation(line: 559, column: 5, scope: !138)
!147 = !DILocation(line: 558, column: 20, scope: !138)
!148 = !DILocation(line: 558, column: 32, scope: !138)
!149 = !DILocation(line: 558, column: 5, scope: !138)
!150 = !DILocation(line: 561, column: 33, scope: !138)
!151 = !DILocation(line: 561, column: 38, scope: !138)
!152 = !DILocation(line: 562, column: 34, scope: !138)
!153 = !DILocation(line: 562, column: 39, scope: !138)
!154 = !DILocation(line: 563, column: 34, scope: !138)
!155 = !DILocation(line: 563, column: 39, scope: !138)
!156 = !DILocation(line: 564, column: 33, scope: !138)
!157 = !DILocation(line: 564, column: 38, scope: !138)
!158 = !DILocation(line: 565, column: 33, scope: !138)
!159 = !DILocation(line: 565, column: 38, scope: !138)
!160 = !DILocation(line: 566, column: 35, scope: !138)
!161 = !DILocation(line: 566, column: 21, scope: !138)
!162 = !DILocation(line: 567, column: 41, scope: !138)
!163 = !DILocation(line: 567, column: 27, scope: !138)
!164 = !DILocation(line: 568, column: 39, scope: !138)
!165 = !DILocation(line: 568, column: 25, scope: !138)
!166 = !DILocation(line: 570, column: 24, scope: !138)
!167 = !DILocation(line: 573, column: 21, scope: !138)
!168 = !DILocation(line: 573, column: 19, scope: !138)
!169 = !DILocation(line: 574, column: 21, scope: !138)
!170 = !DILocation(line: 574, column: 19, scope: !138)
!171 = !DILocation(line: 575, column: 21, scope: !138)
!172 = !DILocation(line: 575, column: 19, scope: !138)
!173 = !DILocation(line: 576, column: 20, scope: !138)
!174 = !DILocation(line: 576, column: 18, scope: !138)
!175 = !DILocation(line: 577, column: 20, scope: !138)
!176 = !DILocation(line: 577, column: 18, scope: !138)
!177 = !DILocation(line: 578, column: 22, scope: !138)
!178 = !DILocation(line: 578, column: 20, scope: !138)
!179 = !DILocation(line: 579, column: 27, scope: !138)
!180 = !DILocation(line: 579, column: 25, scope: !138)
!181 = !DILocation(line: 580, column: 25, scope: !138)
!182 = !DILocation(line: 580, column: 23, scope: !138)
!183 = !DILocation(line: 582, column: 5, scope: !138)
!184 = !DILocation(line: 588, column: 59, scope: !138)
!185 = !DILocation(line: 588, column: 5, scope: !138)
!186 = !DILocation(line: 608, column: 5, scope: !138)
!187 = !DILocation(line: 609, column: 16, scope: !138)
!188 = !DILocation(line: 556, column: 1, scope: !138)
!189 = distinct !DISubprogram(name: "sys_mod.sys_mod.oq0_teardow_handler", linkageName: "sys_mod.sys_mod.oq0_teardow_handler", scope: null, file: !26, line: 631, type: !5, scopeLine: 631, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!190 = !DILocation(line: 632, column: 9, scope: !191)
!191 = !DILexicalBlockFile(scope: !189, file: !26, discriminator: 0)
!192 = !DILocation(line: 632, column: 5, scope: !191)
!193 = !DILocation(line: 634, column: 66, scope: !191)
!194 = !DILocation(line: 634, column: 9, scope: !191)
!195 = !DILocation(line: 636, column: 13, scope: !191)
!196 = !DILocation(line: 637, column: 13, scope: !191)
!197 = !DILocation(line: 638, column: 13, scope: !191)
!198 = !DILocation(line: 639, column: 13, scope: !191)
!199 = !DILocation(line: 640, column: 13, scope: !191)
!200 = !DILocation(line: 641, column: 13, scope: !191)
!201 = !DILocation(line: 642, column: 13, scope: !191)
!202 = !DILocation(line: 643, column: 13, scope: !191)
!203 = !DILocation(line: 644, column: 13, scope: !191)
!204 = !DILocation(line: 645, column: 13, scope: !191)
!205 = !DILocation(line: 646, column: 13, scope: !191)
!206 = !DILocation(line: 647, column: 13, scope: !191)
!207 = !DILocation(line: 648, column: 13, scope: !191)
!208 = !DILocation(line: 635, column: 9, scope: !191)
!209 = !DILocation(line: 652, column: 9, scope: !191)
!210 = !DILocation(line: 654, column: 13, scope: !191)
!211 = !DILocation(line: 655, column: 13, scope: !191)
!212 = !DILocation(line: 656, column: 13, scope: !191)
!213 = !DILocation(line: 657, column: 13, scope: !191)
!214 = !DILocation(line: 658, column: 13, scope: !191)
!215 = !DILocation(line: 659, column: 13, scope: !191)
!216 = !DILocation(line: 660, column: 13, scope: !191)
!217 = !DILocation(line: 661, column: 13, scope: !191)
!218 = !DILocation(line: 653, column: 9, scope: !191)
!219 = !DILocation(line: 664, column: 5, scope: !191)
!220 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_rpc", linkageName: "sys_mod.sys_mod.f_rpc", scope: null, file: !26, line: 694, type: !5, scopeLine: 694, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!221 = !DILocation(line: 694, column: 13, scope: !222)
!222 = !DILexicalBlockFile(scope: !220, file: !26, discriminator: 0)
!223 = !DILocation(line: 700, column: 5, scope: !222)
!224 = !DILocation(line: 706, column: 20, scope: !222)
!225 = !DILocation(line: 706, column: 32, scope: !222)
!226 = !DILocation(line: 706, column: 5, scope: !222)
!227 = !DILocation(line: 710, column: 5, scope: !222)
!228 = !DILocation(line: 712, column: 24, scope: !222)
!229 = !DILocation(line: 694, column: 1, scope: !222)
!230 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.stack_push", linkageName: "sys_mod.sys_mod.sys_mod.stack_push", scope: null, file: !231, line: 54, type: !5, scopeLine: 54, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!231 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/sys.csl", directory: "")
!232 = !DILocation(line: 60, column: 5, scope: !233)
!233 = !DILexicalBlockFile(scope: !230, file: !231, discriminator: 0)
!234 = !DILocation(line: 54, column: 16, scope: !233)
!235 = !DILocation(line: 59, column: 13, scope: !233)
!236 = !DILocation(line: 59, column: 24, scope: !233)
!237 = !DILocation(line: 59, column: 5, scope: !233)
!238 = !DILocation(line: 61, column: 25, scope: !233)
!239 = !DILocation(line: 61, column: 5, scope: !233)
!240 = !DILocation(line: 61, column: 11, scope: !233)
!241 = !DILocation(line: 61, column: 10, scope: !233)
!242 = !DILocation(line: 61, column: 23, scope: !233)
!243 = !DILocation(line: 62, column: 18, scope: !233)
!244 = !DILocation(line: 62, column: 29, scope: !233)
!245 = !DILocation(line: 62, column: 16, scope: !233)
!246 = !DILocation(line: 54, column: 1, scope: !233)
!247 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_push", linkageName: "sys_mod.sys_mod.sys_mod.f_push", scope: null, file: !231, line: 72, type: !5, scopeLine: 72, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!248 = !DILocation(line: 72, column: 25, scope: !249)
!249 = !DILexicalBlockFile(scope: !247, file: !231, discriminator: 0)
!250 = !DILocation(line: 72, column: 13, scope: !249)
!251 = !DILocation(line: 73, column: 16, scope: !249)
!252 = !DILocation(line: 73, column: 5, scope: !249)
!253 = !DILocation(line: 72, column: 1, scope: !249)
!254 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.block_cmd_stream", linkageName: "sys_mod.sys_mod.sys_mod.block_cmd_stream", scope: null, file: !231, line: 76, type: !5, scopeLine: 76, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!255 = !DILocation(line: 77, column: 5, scope: !256)
!256 = !DILexicalBlockFile(scope: !254, file: !231, discriminator: 0)
!257 = !DILocation(line: 76, column: 1, scope: !256)
!258 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.sys_mod.unblock_cmd_stream", scope: null, file: !231, line: 80, type: !5, scopeLine: 80, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!259 = !DILocation(line: 81, column: 5, scope: !260)
!260 = !DILexicalBlockFile(scope: !258, file: !231, discriminator: 0)
!261 = !DILocation(line: 80, column: 1, scope: !260)
!262 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_sys_exit", linkageName: "sys_mod.sys_mod.sys_mod.f_sys_exit", scope: null, file: !231, line: 85, type: !5, scopeLine: 85, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!263 = !DILocation(line: 86, column: 5, scope: !264)
!264 = !DILexicalBlockFile(scope: !262, file: !231, discriminator: 0)
!265 = !DILocation(line: 87, column: 5, scope: !264)
!266 = !DILocation(line: 85, column: 1, scope: !264)
!267 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore", linkageName: "sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore", scope: null, file: !231, line: 90, type: !5, scopeLine: 90, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!268 = !DILocation(line: 90, column: 30, scope: !269)
!269 = !DILexicalBlockFile(scope: !267, file: !231, discriminator: 0)
!270 = !DILocation(line: 90, column: 1, scope: !269)
!271 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord", scope: null, file: !272, line: 131, type: !5, scopeLine: 131, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!272 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpyh2d.csl", directory: "")
!273 = !DILocation(line: 132, column: 12, scope: !274)
!274 = !DILexicalBlockFile(scope: !271, file: !272, discriminator: 0)
!275 = !DILocation(line: 132, column: 5, scope: !274)
!276 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord", scope: null, file: !272, line: 134, type: !5, scopeLine: 134, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!277 = !DILocation(line: 135, column: 12, scope: !278)
!278 = !DILexicalBlockFile(scope: !276, file: !272, discriminator: 0)
!279 = !DILocation(line: 135, column: 5, scope: !278)
!280 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval", scope: null, file: !272, line: 148, type: !5, scopeLine: 148, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!281 = !DILocation(line: 148, column: 23, scope: !282)
!282 = !DILexicalBlockFile(scope: !280, file: !272, discriminator: 0)
!283 = !DILocation(line: 149, column: 9, scope: !282)
!284 = !DILocation(line: 149, column: 20, scope: !282)
!285 = !DILocation(line: 149, column: 5, scope: !282)
!286 = !DILocation(line: 152, column: 23, scope: !282)
!287 = !DILocation(line: 152, column: 20, scope: !282)
!288 = !DILocation(line: 152, column: 9, scope: !282)
!289 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start", scope: null, file: !272, line: 226, type: !5, scopeLine: 226, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!290 = !DILocation(line: 233, column: 5, scope: !291)
!291 = !DILexicalBlockFile(scope: !289, file: !272, discriminator: 0)
!292 = !DILocation(line: 226, column: 49, scope: !291)
!293 = !DILocation(line: 226, column: 32, scope: !291)
!294 = !DILocation(line: 226, column: 21, scope: !291)
!295 = !DILocation(line: 229, column: 37, scope: !291)
!296 = !DILocation(line: 229, column: 52, scope: !291)
!297 = !DILocation(line: 229, column: 19, scope: !291)
!298 = !DILocation(line: 233, column: 71, scope: !291)
!299 = !DILocation(line: 233, column: 55, scope: !291)
!300 = !DILocation(line: 233, column: 25, scope: !291)
!301 = !DILocation(line: 235, column: 37, scope: !291)
!302 = !DILocation(line: 235, column: 52, scope: !291)
!303 = !DILocation(line: 235, column: 19, scope: !291)
!304 = !DILocation(line: 236, column: 28, scope: !291)
!305 = !DILocation(line: 236, column: 5, scope: !291)
!306 = !DILocation(line: 237, column: 28, scope: !291)
!307 = !DILocation(line: 237, column: 5, scope: !291)
!308 = !DILocation(line: 238, column: 13, scope: !291)
!309 = !DILocation(line: 238, column: 11, scope: !291)
!310 = !DILocation(line: 238, column: 5, scope: !291)
!311 = !DILocation(line: 239, column: 9, scope: !291)
!312 = !DILocation(line: 241, column: 9, scope: !291)
!313 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream", scope: null, file: !272, line: 249, type: !5, scopeLine: 249, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!314 = !DILocation(line: 250, column: 5, scope: !315)
!315 = !DILexicalBlockFile(scope: !313, file: !272, discriminator: 0)
!316 = !DILocation(line: 249, column: 1, scope: !315)
!317 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure", scope: null, file: !272, line: 276, type: !5, scopeLine: 276, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!318 = !DILocation(line: 414, column: 13, scope: !319)
!319 = !DILexicalBlockFile(scope: !317, file: !272, discriminator: 0)
!320 = !DILocation(line: 413, column: 13, scope: !319)
!321 = !DILocation(line: 400, column: 17, scope: !319)
!322 = !DILocation(line: 340, column: 9, scope: !319)
!323 = !DILocation(line: 339, column: 9, scope: !319)
!324 = !DILocation(line: 337, column: 5, scope: !319)
!325 = !DILocation(line: 319, column: 9, scope: !319)
!326 = !DILocation(line: 318, column: 9, scope: !319)
!327 = !DILocation(line: 315, column: 5, scope: !319)
!328 = !DILocation(line: 292, column: 5, scope: !319)
!329 = !DILocation(line: 291, column: 5, scope: !319)
!330 = !DILocation(line: 289, column: 5, scope: !319)
!331 = !DILocation(line: 288, column: 5, scope: !319)
!332 = !DILocation(line: 287, column: 5, scope: !319)
!333 = !DILocation(line: 286, column: 5, scope: !319)
!334 = !DILocation(line: 285, column: 5, scope: !319)
!335 = !DILocation(line: 284, column: 5, scope: !319)
!336 = !DILocation(line: 283, column: 5, scope: !319)
!337 = !DILocation(line: 282, column: 5, scope: !319)
!338 = !DILocation(line: 281, column: 5, scope: !319)
!339 = !DILocation(line: 280, column: 5, scope: !319)
!340 = !DILocation(line: 279, column: 5, scope: !319)
!341 = !DILocation(line: 278, column: 5, scope: !319)
!342 = !DILocation(line: 277, column: 5, scope: !319)
!343 = !DILocation(line: 291, column: 26, scope: !319)
!344 = !DILocation(line: 292, column: 26, scope: !319)
!345 = !DILocation(line: 315, column: 25, scope: !319)
!346 = !DILocation(line: 315, column: 31, scope: !319)
!347 = !DILocation(line: 315, column: 29, scope: !319)
!348 = !DILocation(line: 316, column: 20, scope: !319)
!349 = !DILocation(line: 316, column: 18, scope: !319)
!350 = !DILocation(line: 317, column: 52, scope: !319)
!351 = !DILocation(line: 317, column: 49, scope: !319)
!352 = !DILocation(line: 317, column: 5, scope: !319)
!353 = !DILocation(line: 318, column: 42, scope: !319)
!354 = !DILocation(line: 318, column: 33, scope: !319)
!355 = !DILocation(line: 318, column: 49, scope: !319)
!356 = !DILocation(line: 318, column: 48, scope: !319)
!357 = !DILocation(line: 318, column: 24, scope: !319)
!358 = !DILocation(line: 319, column: 24, scope: !319)
!359 = !DILocation(line: 319, column: 32, scope: !319)
!360 = !DILocation(line: 319, column: 36, scope: !319)
!361 = !DILocation(line: 319, column: 34, scope: !319)
!362 = !DILocation(line: 319, column: 30, scope: !319)
!363 = !DILocation(line: 320, column: 18, scope: !319)
!364 = !DILocation(line: 320, column: 15, scope: !319)
!365 = !DILocation(line: 320, column: 9, scope: !319)
!366 = !DILocation(line: 321, column: 26, scope: !319)
!367 = !DILocation(line: 325, column: 28, scope: !319)
!368 = !DILocation(line: 325, column: 26, scope: !319)
!369 = !DILocation(line: 331, column: 9, scope: !319)
!370 = !DILocation(line: 331, column: 15, scope: !319)
!371 = !DILocation(line: 331, column: 5, scope: !319)
!372 = !DILocation(line: 332, column: 22, scope: !319)
!373 = !DILocation(line: 334, column: 9, scope: !319)
!374 = !DILocation(line: 334, column: 18, scope: !319)
!375 = !DILocation(line: 334, column: 15, scope: !319)
!376 = !DILocation(line: 334, column: 5, scope: !319)
!377 = !DILocation(line: 335, column: 22, scope: !319)
!378 = !DILocation(line: 338, column: 52, scope: !319)
!379 = !DILocation(line: 338, column: 49, scope: !319)
!380 = !DILocation(line: 338, column: 5, scope: !319)
!381 = !DILocation(line: 339, column: 42, scope: !319)
!382 = !DILocation(line: 339, column: 48, scope: !319)
!383 = !DILocation(line: 339, column: 46, scope: !319)
!384 = !DILocation(line: 339, column: 33, scope: !319)
!385 = !DILocation(line: 339, column: 52, scope: !319)
!386 = !DILocation(line: 339, column: 51, scope: !319)
!387 = !DILocation(line: 339, column: 24, scope: !319)
!388 = !DILocation(line: 340, column: 25, scope: !319)
!389 = !DILocation(line: 340, column: 31, scope: !319)
!390 = !DILocation(line: 340, column: 29, scope: !319)
!391 = !DILocation(line: 340, column: 37, scope: !319)
!392 = !DILocation(line: 340, column: 41, scope: !319)
!393 = !DILocation(line: 340, column: 39, scope: !319)
!394 = !DILocation(line: 340, column: 35, scope: !319)
!395 = !DILocation(line: 341, column: 18, scope: !319)
!396 = !DILocation(line: 341, column: 15, scope: !319)
!397 = !DILocation(line: 341, column: 9, scope: !319)
!398 = !DILocation(line: 342, column: 26, scope: !319)
!399 = !DILocation(line: 347, column: 10, scope: !319)
!400 = !DILocation(line: 347, column: 16, scope: !319)
!401 = !DILocation(line: 347, column: 14, scope: !319)
!402 = !DILocation(line: 347, column: 5, scope: !319)
!403 = !DILocation(line: 348, column: 22, scope: !319)
!404 = !DILocation(line: 350, column: 10, scope: !319)
!405 = !DILocation(line: 350, column: 18, scope: !319)
!406 = !DILocation(line: 350, column: 21, scope: !319)
!407 = !DILocation(line: 350, column: 20, scope: !319)
!408 = !DILocation(line: 350, column: 14, scope: !319)
!409 = !DILocation(line: 350, column: 5, scope: !319)
!410 = !DILocation(line: 351, column: 22, scope: !319)
!411 = !DILocation(line: 354, column: 9, scope: !319)
!412 = !DILocation(line: 354, column: 5, scope: !319)
!413 = !DILocation(line: 358, column: 9, scope: !319)
!414 = !DILocation(line: 361, column: 9, scope: !319)
!415 = !DILocation(line: 364, column: 20, scope: !319)
!416 = !DILocation(line: 364, column: 17, scope: !319)
!417 = !DILocation(line: 364, column: 9, scope: !319)
!418 = !DILocation(line: 368, column: 13, scope: !319)
!419 = !DILocation(line: 371, column: 13, scope: !319)
!420 = !DILocation(line: 375, column: 13, scope: !319)
!421 = !DILocation(line: 394, column: 13, scope: !319)
!422 = !DILocation(line: 396, column: 29, scope: !319)
!423 = !DILocation(line: 396, column: 27, scope: !319)
!424 = !DILocation(line: 397, column: 60, scope: !319)
!425 = !DILocation(line: 397, column: 57, scope: !319)
!426 = !DILocation(line: 397, column: 13, scope: !319)
!427 = !DILocation(line: 400, column: 54, scope: !319)
!428 = !DILocation(line: 400, column: 55, scope: !319)
!429 = !DILocation(line: 400, column: 46, scope: !319)
!430 = !DILocation(line: 400, column: 59, scope: !319)
!431 = !DILocation(line: 400, column: 58, scope: !319)
!432 = !DILocation(line: 400, column: 37, scope: !319)
!433 = !DILocation(line: 400, column: 35, scope: !319)
!434 = !DILocation(line: 401, column: 33, scope: !319)
!435 = !DILocation(line: 401, column: 31, scope: !319)
!436 = !DILocation(line: 402, column: 69, scope: !319)
!437 = !DILocation(line: 402, column: 66, scope: !319)
!438 = !DILocation(line: 402, column: 19, scope: !319)
!439 = !DILocation(line: 404, column: 31, scope: !319)
!440 = !DILocation(line: 408, column: 75, scope: !319)
!441 = !DILocation(line: 408, column: 88, scope: !319)
!442 = !DILocation(line: 408, column: 13, scope: !319)
!443 = !DILocation(line: 413, column: 31, scope: !319)
!444 = !DILocation(line: 414, column: 33, scope: !319)
!445 = !DILocation(line: 415, column: 21, scope: !319)
!446 = !DILocation(line: 415, column: 29, scope: !319)
!447 = !DILocation(line: 415, column: 27, scope: !319)
!448 = !DILocation(line: 415, column: 19, scope: !319)
!449 = !DILocation(line: 416, column: 22, scope: !319)
!450 = !DILocation(line: 416, column: 19, scope: !319)
!451 = !DILocation(line: 416, column: 13, scope: !319)
!452 = !DILocation(line: 417, column: 23, scope: !319)
!453 = !DILocation(line: 419, column: 63, scope: !319)
!454 = !DILocation(line: 419, column: 60, scope: !319)
!455 = !DILocation(line: 419, column: 13, scope: !319)
!456 = !DILocation(line: 421, column: 23, scope: !319)
!457 = !DILocation(line: 423, column: 69, scope: !319)
!458 = !DILocation(line: 423, column: 13, scope: !319)
!459 = !DILocation(line: 426, column: 13, scope: !319)
!460 = !DILocation(line: 430, column: 13, scope: !319)
!461 = !DILocation(line: 433, column: 48, scope: !319)
!462 = !DILocation(line: 433, column: 22, scope: !319)
!463 = !DILocation(line: 433, column: 19, scope: !319)
!464 = !DILocation(line: 433, column: 13, scope: !319)
!465 = !DILocation(line: 436, column: 34, scope: !319)
!466 = !DILocation(line: 436, column: 39, scope: !319)
!467 = !DILocation(line: 436, column: 50, scope: !319)
!468 = !DILocation(line: 436, column: 17, scope: !319)
!469 = !DILocation(line: 452, column: 49, scope: !319)
!470 = !DILocation(line: 452, column: 64, scope: !319)
!471 = !DILocation(line: 452, column: 31, scope: !319)
!472 = !DILocation(line: 453, column: 40, scope: !319)
!473 = !DILocation(line: 453, column: 17, scope: !319)
!474 = !DILocation(line: 454, column: 50, scope: !319)
!475 = !DILocation(line: 454, column: 66, scope: !319)
!476 = !DILocation(line: 454, column: 32, scope: !319)
!477 = !DILocation(line: 455, column: 40, scope: !319)
!478 = !DILocation(line: 455, column: 17, scope: !319)
!479 = !DILocation(line: 456, column: 17, scope: !319)
!480 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit", scope: null, file: !481, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!481 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/filters/wse3.csl", directory: "")
!482 = !DILocation(line: 24, column: 3, scope: !483)
!483 = !DILexicalBlockFile(scope: !480, file: !481, discriminator: 0)
!484 = !DILocation(line: 24, column: 22, scope: !483)
!485 = !DILocation(line: 23, column: 3, scope: !483)
!486 = !DILocation(line: 22, column: 3, scope: !483)
!487 = !DILocation(line: 20, column: 37, scope: !483)
!488 = !DILocation(line: 20, column: 21, scope: !483)
!489 = !DILocation(line: 21, column: 11, scope: !483)
!490 = !DILocation(line: 21, column: 17, scope: !483)
!491 = !DILocation(line: 21, column: 3, scope: !483)
!492 = !DILocation(line: 22, column: 24, scope: !483)
!493 = !DILocation(line: 22, column: 30, scope: !483)
!494 = !DILocation(line: 23, column: 40, scope: !483)
!495 = !DILocation(line: 23, column: 22, scope: !483)
!496 = !DILocation(line: 23, column: 67, scope: !483)
!497 = !DILocation(line: 24, column: 26, scope: !483)
!498 = !DILocation(line: 24, column: 41, scope: !483)
!499 = !DILocation(line: 24, column: 39, scope: !483)
!500 = !DILocation(line: 24, column: 61, scope: !483)
!501 = !DILocation(line: 24, column: 76, scope: !483)
!502 = !DILocation(line: 24, column: 74, scope: !483)
!503 = !DILocation(line: 25, column: 21, scope: !483)
!504 = !DILocation(line: 25, column: 50, scope: !483)
!505 = !DILocation(line: 25, column: 3, scope: !483)
!506 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter", scope: null, file: !481, line: 30, type: !5, scopeLine: 30, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!507 = !DILocation(line: 30, column: 36, scope: !508)
!508 = !DILexicalBlockFile(scope: !506, file: !481, discriminator: 0)
!509 = !DILocation(line: 30, column: 20, scope: !508)
!510 = !DILocation(line: 31, column: 11, scope: !508)
!511 = !DILocation(line: 31, column: 23, scope: !508)
!512 = !DILocation(line: 31, column: 3, scope: !508)
!513 = !DILocation(line: 32, column: 21, scope: !508)
!514 = !DILocation(line: 32, column: 48, scope: !508)
!515 = !DILocation(line: 32, column: 60, scope: !508)
!516 = !DILocation(line: 32, column: 64, scope: !508)
!517 = !DILocation(line: 32, column: 3, scope: !508)
!518 = !DILocation(line: 30, column: 1, scope: !508)
!519 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter", scope: null, file: !481, line: 40, type: !5, scopeLine: 40, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!520 = !DILocation(line: 47, column: 3, scope: !521)
!521 = !DILexicalBlockFile(scope: !519, file: !481, discriminator: 0)
!522 = !DILocation(line: 48, column: 7, scope: !521)
!523 = !DILocation(line: 44, column: 3, scope: !521)
!524 = !DILocation(line: 43, column: 3, scope: !521)
!525 = !DILocation(line: 42, column: 3, scope: !521)
!526 = !DILocation(line: 40, column: 32, scope: !521)
!527 = !DILocation(line: 40, column: 16, scope: !521)
!528 = !DILocation(line: 41, column: 11, scope: !521)
!529 = !DILocation(line: 41, column: 19, scope: !521)
!530 = !DILocation(line: 41, column: 3, scope: !521)
!531 = !DILocation(line: 42, column: 40, scope: !521)
!532 = !DILocation(line: 42, column: 22, scope: !521)
!533 = !DILocation(line: 43, column: 26, scope: !521)
!534 = !DILocation(line: 43, column: 34, scope: !521)
!535 = !DILocation(line: 44, column: 25, scope: !521)
!536 = !DILocation(line: 44, column: 42, scope: !521)
!537 = !DILocation(line: 44, column: 40, scope: !521)
!538 = !DILocation(line: 45, column: 21, scope: !521)
!539 = !DILocation(line: 46, column: 35, scope: !521)
!540 = !DILocation(line: 46, column: 21, scope: !521)
!541 = !DILocation(line: 46, column: 50, scope: !521)
!542 = !DILocation(line: 45, column: 3, scope: !521)
!543 = !DILocation(line: 48, column: 11, scope: !521)
!544 = !DILocation(line: 48, column: 26, scope: !521)
!545 = !DILocation(line: 48, column: 43, scope: !521)
!546 = !DILocation(line: 48, column: 41, scope: !521)
!547 = !DILocation(line: 48, column: 54, scope: !521)
!548 = !DILocation(line: 48, column: 63, scope: !521)
!549 = !DILocation(line: 49, column: 21, scope: !521)
!550 = !DILocation(line: 49, column: 47, scope: !521)
!551 = !DILocation(line: 49, column: 3, scope: !521)
!552 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config", scope: null, file: !553, line: 33, type: !5, scopeLine: 33, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!553 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/filters/common.csl", directory: "")
!554 = !DILocation(line: 33, column: 46, scope: !555)
!555 = !DILexicalBlockFile(scope: !552, file: !553, discriminator: 0)
!556 = !DILocation(line: 33, column: 31, scope: !555)
!557 = !DILocation(line: 33, column: 15, scope: !555)
!558 = !DILocation(line: 34, column: 24, scope: !555)
!559 = !DILocation(line: 34, column: 23, scope: !555)
!560 = !DILocation(line: 34, column: 51, scope: !555)
!561 = !DILocation(line: 34, column: 35, scope: !555)
!562 = !DILocation(line: 34, column: 60, scope: !555)
!563 = !DILocation(line: 34, column: 73, scope: !555)
!564 = !DILocation(line: 34, column: 3, scope: !555)
!565 = !DILocation(line: 33, column: 1, scope: !555)
!566 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config", scope: null, file: !553, line: 38, type: !5, scopeLine: 38, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!567 = !DILocation(line: 38, column: 31, scope: !568)
!568 = !DILexicalBlockFile(scope: !566, file: !553, discriminator: 0)
!569 = !DILocation(line: 38, column: 15, scope: !568)
!570 = !DILocation(line: 39, column: 31, scope: !568)
!571 = !DILocation(line: 39, column: 30, scope: !568)
!572 = !DILocation(line: 39, column: 58, scope: !568)
!573 = !DILocation(line: 39, column: 42, scope: !568)
!574 = !DILocation(line: 39, column: 67, scope: !568)
!575 = !DILocation(line: 39, column: 10, scope: !568)
!576 = !DILocation(line: 39, column: 3, scope: !568)
!577 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit", scope: null, file: !578, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!578 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/teardown.csl", directory: "")
!579 = !DILocation(line: 43, column: 3, scope: !580)
!580 = !DILexicalBlockFile(scope: !577, file: !578, discriminator: 0)
!581 = !DILocation(line: 41, column: 3, scope: !580)
!582 = !DILocation(line: 40, column: 3, scope: !580)
!583 = !DILocation(line: 39, column: 9, scope: !580)
!584 = !DILocation(line: 40, column: 23, scope: !580)
!585 = !DILocation(line: 41, column: 70, scope: !580)
!586 = !DILocation(line: 41, column: 68, scope: !580)
!587 = !DILocation(line: 43, column: 27, scope: !580)
!588 = !DILocation(line: 43, column: 15, scope: !580)
!589 = !DILocation(line: 44, column: 15, scope: !580)
!590 = !DILocation(line: 44, column: 21, scope: !580)
!591 = !DILocation(line: 44, column: 27, scope: !580)
!592 = !DILocation(line: 44, column: 3, scope: !580)
!593 = !DILocation(line: 39, column: 1, scope: !580)
!594 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord", scope: null, file: !595, line: 4, type: !5, scopeLine: 4, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!595 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/layout.csl", directory: "")
!596 = !DILocation(line: 5, column: 10, scope: !597)
!597 = !DILexicalBlockFile(scope: !594, file: !595, discriminator: 0)
!598 = !DILocation(line: 5, column: 67, scope: !597)
!599 = !DILocation(line: 5, column: 3, scope: !597)
!600 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord", scope: null, file: !595, line: 8, type: !5, scopeLine: 8, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!601 = !DILocation(line: 9, column: 10, scope: !602)
!602 = !DILexicalBlockFile(scope: !600, file: !595, discriminator: 0)
!603 = !DILocation(line: 9, column: 67, scope: !602)
!604 = !DILocation(line: 9, column: 3, scope: !602)
!605 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord", scope: null, file: !606, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!606 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config.csl", directory: "")
!607 = !DILocation(line: 50, column: 3, scope: !608)
!608 = !DILexicalBlockFile(scope: !605, file: !606, discriminator: 0)
!609 = !DILocation(line: 43, column: 21, scope: !608)
!610 = !DILocation(line: 50, column: 57, scope: !608)
!611 = !DILocation(line: 50, column: 68, scope: !608)
!612 = !DILocation(line: 50, column: 41, scope: !608)
!613 = !DILocation(line: 50, column: 19, scope: !608)
!614 = !DILocation(line: 52, column: 10, scope: !608)
!615 = !DILocation(line: 52, column: 18, scope: !608)
!616 = !DILocation(line: 48, column: 22, scope: !608)
!617 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.get_x_coord", scope: null, file: !618, line: 171, type: !5, scopeLine: 171, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!618 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpyd2h.csl", directory: "")
!619 = !DILocation(line: 172, column: 12, scope: !620)
!620 = !DILexicalBlockFile(scope: !617, file: !618, discriminator: 0)
!621 = !DILocation(line: 172, column: 5, scope: !620)
!622 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.get_y_coord", scope: null, file: !618, line: 174, type: !5, scopeLine: 174, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!623 = !DILocation(line: 175, column: 12, scope: !624)
!624 = !DILexicalBlockFile(scope: !622, file: !618, discriminator: 0)
!625 = !DILocation(line: 175, column: 5, scope: !624)
!626 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval", scope: null, file: !618, line: 187, type: !5, scopeLine: 187, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!627 = !DILocation(line: 187, column: 23, scope: !628)
!628 = !DILexicalBlockFile(scope: !626, file: !618, discriminator: 0)
!629 = !DILocation(line: 188, column: 9, scope: !628)
!630 = !DILocation(line: 188, column: 20, scope: !628)
!631 = !DILocation(line: 188, column: 5, scope: !628)
!632 = !DILocation(line: 191, column: 23, scope: !628)
!633 = !DILocation(line: 191, column: 20, scope: !628)
!634 = !DILocation(line: 191, column: 9, scope: !628)
!635 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start", scope: null, file: !618, line: 383, type: !5, scopeLine: 383, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!636 = !DILocation(line: 386, column: 5, scope: !637)
!637 = !DILexicalBlockFile(scope: !635, file: !618, discriminator: 0)
!638 = !DILocation(line: 384, column: 72, scope: !637)
!639 = !DILocation(line: 384, column: 59, scope: !637)
!640 = !DILocation(line: 384, column: 46, scope: !637)
!641 = !DILocation(line: 384, column: 33, scope: !637)
!642 = !DILocation(line: 384, column: 19, scope: !637)
!643 = !DILocation(line: 384, column: 5, scope: !637)
!644 = !DILocation(line: 383, column: 32, scope: !637)
!645 = !DILocation(line: 383, column: 21, scope: !637)
!646 = !DILocation(line: 386, column: 26, scope: !637)
!647 = !DILocation(line: 388, column: 28, scope: !637)
!648 = !DILocation(line: 388, column: 17, scope: !637)
!649 = !DILocation(line: 389, column: 25, scope: !637)
!650 = !DILocation(line: 389, column: 23, scope: !637)
!651 = !DILocation(line: 391, column: 38, scope: !637)
!652 = !DILocation(line: 391, column: 20, scope: !637)
!653 = !DILocation(line: 391, column: 18, scope: !637)
!654 = !DILocation(line: 393, column: 7, scope: !637)
!655 = !DILocation(line: 395, column: 17, scope: !637)
!656 = !DILocation(line: 395, column: 15, scope: !637)
!657 = !DILocation(line: 397, column: 15, scope: !637)
!658 = !DILocation(line: 397, column: 13, scope: !637)
!659 = !DILocation(line: 398, column: 15, scope: !637)
!660 = !DILocation(line: 398, column: 25, scope: !637)
!661 = !DILocation(line: 398, column: 23, scope: !637)
!662 = !DILocation(line: 398, column: 31, scope: !637)
!663 = !DILocation(line: 398, column: 13, scope: !637)
!664 = !DILocation(line: 401, column: 10, scope: !637)
!665 = !DILocation(line: 401, column: 17, scope: !637)
!666 = !DILocation(line: 401, column: 14, scope: !637)
!667 = !DILocation(line: 401, column: 5, scope: !637)
!668 = !DILocation(line: 403, column: 48, scope: !637)
!669 = !DILocation(line: 403, column: 26, scope: !637)
!670 = !DILocation(line: 404, column: 26, scope: !637)
!671 = !DILocation(line: 404, column: 18, scope: !637)
!672 = !DILocation(line: 407, column: 48, scope: !637)
!673 = !DILocation(line: 407, column: 26, scope: !637)
!674 = !DILocation(line: 408, column: 27, scope: !637)
!675 = !DILocation(line: 408, column: 18, scope: !637)
!676 = !DILocation(line: 411, column: 14, scope: !637)
!677 = !DILocation(line: 414, column: 14, scope: !637)
!678 = !DILocation(line: 414, column: 11, scope: !637)
!679 = !DILocation(line: 414, column: 5, scope: !637)
!680 = !DILocation(line: 416, column: 44, scope: !637)
!681 = !DILocation(line: 416, column: 75, scope: !637)
!682 = !DILocation(line: 416, column: 59, scope: !637)
!683 = !DILocation(line: 416, column: 25, scope: !637)
!684 = !DILocation(line: 416, column: 23, scope: !637)
!685 = !DILocation(line: 418, column: 41, scope: !637)
!686 = !DILocation(line: 418, column: 23, scope: !637)
!687 = !DILocation(line: 419, column: 9, scope: !637)
!688 = !DILocation(line: 425, column: 44, scope: !637)
!689 = !DILocation(line: 425, column: 23, scope: !637)
!690 = !DILocation(line: 426, column: 41, scope: !637)
!691 = !DILocation(line: 426, column: 23, scope: !637)
!692 = !DILocation(line: 427, column: 9, scope: !637)
!693 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x", scope: null, file: !618, line: 448, type: !5, scopeLine: 448, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!694 = !DILocation(line: 448, column: 31, scope: !695)
!695 = !DILexicalBlockFile(scope: !693, file: !618, discriminator: 0)
!696 = !DILocation(line: 453, column: 5, scope: !695)
!697 = !DILocation(line: 456, column: 19, scope: !695)
!698 = !DILocation(line: 456, column: 17, scope: !695)
!699 = !DILocation(line: 461, column: 5, scope: !695)
!700 = !DILocation(line: 462, column: 28, scope: !695)
!701 = !DILocation(line: 462, column: 5, scope: !695)
!702 = !DILocation(line: 463, column: 5, scope: !695)
!703 = !DILocation(line: 464, column: 9, scope: !695)
!704 = !DILocation(line: 464, column: 10, scope: !695)
!705 = !DILocation(line: 464, column: 7, scope: !695)
!706 = !DILocation(line: 448, column: 1, scope: !695)
!707 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_send_data", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_send_data", scope: null, file: !618, line: 476, type: !5, scopeLine: 476, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!708 = !DILocation(line: 494, column: 9, scope: !709)
!709 = !DILexicalBlockFile(scope: !707, file: !618, discriminator: 0)
!710 = !DILocation(line: 478, column: 9, scope: !709)
!711 = !DILocation(line: 478, column: 13, scope: !709)
!712 = !DILocation(line: 478, column: 11, scope: !709)
!713 = !DILocation(line: 478, column: 5, scope: !709)
!714 = !DILocation(line: 479, column: 9, scope: !709)
!715 = !DILocation(line: 480, column: 32, scope: !709)
!716 = !DILocation(line: 480, column: 9, scope: !709)
!717 = !DILocation(line: 481, column: 17, scope: !709)
!718 = !DILocation(line: 481, column: 15, scope: !709)
!719 = !DILocation(line: 481, column: 9, scope: !709)
!720 = !DILocation(line: 482, column: 13, scope: !709)
!721 = !DILocation(line: 483, column: 51, scope: !709)
!722 = !DILocation(line: 483, column: 29, scope: !709)
!723 = !DILocation(line: 483, column: 27, scope: !709)
!724 = !DILocation(line: 485, column: 13, scope: !709)
!725 = !DILocation(line: 486, column: 51, scope: !709)
!726 = !DILocation(line: 486, column: 29, scope: !709)
!727 = !DILocation(line: 486, column: 27, scope: !709)
!728 = !DILocation(line: 488, column: 13, scope: !709)
!729 = !DILocation(line: 488, column: 14, scope: !709)
!730 = !DILocation(line: 488, column: 11, scope: !709)
!731 = !DILocation(line: 494, column: 30, scope: !709)
!732 = !DILocation(line: 496, column: 14, scope: !709)
!733 = !DILocation(line: 496, column: 25, scope: !709)
!734 = !DILocation(line: 496, column: 22, scope: !709)
!735 = !DILocation(line: 496, column: 9, scope: !709)
!736 = !DILocation(line: 497, column: 13, scope: !709)
!737 = !DILocation(line: 498, column: 13, scope: !709)
!738 = !DILocation(line: 499, column: 13, scope: !709)
!739 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl", scope: null, file: !618, line: 505, type: !5, scopeLine: 505, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!740 = !DILocation(line: 524, column: 13, scope: !741)
!741 = !DILexicalBlockFile(scope: !739, file: !618, discriminator: 0)
!742 = !DILocation(line: 506, column: 14, scope: !741)
!743 = !DILocation(line: 506, column: 11, scope: !741)
!744 = !DILocation(line: 506, column: 5, scope: !741)
!745 = !DILocation(line: 508, column: 9, scope: !741)
!746 = !DILocation(line: 509, column: 32, scope: !741)
!747 = !DILocation(line: 509, column: 9, scope: !741)
!748 = !DILocation(line: 510, column: 9, scope: !741)
!749 = !DILocation(line: 514, column: 13, scope: !741)
!750 = !DILocation(line: 514, column: 17, scope: !741)
!751 = !DILocation(line: 514, column: 15, scope: !741)
!752 = !DILocation(line: 514, column: 9, scope: !741)
!753 = !DILocation(line: 518, column: 13, scope: !741)
!754 = !DILocation(line: 519, column: 36, scope: !741)
!755 = !DILocation(line: 519, column: 13, scope: !741)
!756 = !DILocation(line: 520, column: 13, scope: !741)
!757 = !DILocation(line: 524, column: 34, scope: !741)
!758 = !DILocation(line: 526, column: 18, scope: !741)
!759 = !DILocation(line: 526, column: 29, scope: !741)
!760 = !DILocation(line: 526, column: 26, scope: !741)
!761 = !DILocation(line: 526, column: 13, scope: !741)
!762 = !DILocation(line: 529, column: 17, scope: !741)
!763 = !DILocation(line: 530, column: 17, scope: !741)
!764 = !DILocation(line: 531, column: 17, scope: !741)
!765 = !DILocation(line: 534, column: 17, scope: !741)
!766 = !DILocation(line: 535, column: 40, scope: !741)
!767 = !DILocation(line: 535, column: 17, scope: !741)
!768 = !DILocation(line: 536, column: 17, scope: !741)
!769 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.d2h_configure", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.d2h_configure", scope: null, file: !618, line: 593, type: !5, scopeLine: 593, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!770 = !DILocation(line: 617, column: 26, scope: !771)
!771 = !DILexicalBlockFile(scope: !769, file: !618, discriminator: 0)
!772 = !DILocation(line: 612, column: 47, scope: !771)
!773 = !DILocation(line: 612, column: 27, scope: !771)
!774 = !DILocation(line: 602, column: 5, scope: !771)
!775 = !DILocation(line: 601, column: 5, scope: !771)
!776 = !DILocation(line: 599, column: 5, scope: !771)
!777 = !DILocation(line: 598, column: 5, scope: !771)
!778 = !DILocation(line: 596, column: 5, scope: !771)
!779 = !DILocation(line: 595, column: 5, scope: !771)
!780 = !DILocation(line: 593, column: 86, scope: !771)
!781 = !DILocation(line: 593, column: 70, scope: !771)
!782 = !DILocation(line: 593, column: 60, scope: !771)
!783 = !DILocation(line: 593, column: 52, scope: !771)
!784 = !DILocation(line: 593, column: 44, scope: !771)
!785 = !DILocation(line: 593, column: 35, scope: !771)
!786 = !DILocation(line: 593, column: 26, scope: !771)
!787 = !DILocation(line: 593, column: 18, scope: !771)
!788 = !DILocation(line: 595, column: 26, scope: !771)
!789 = !DILocation(line: 596, column: 26, scope: !771)
!790 = !DILocation(line: 598, column: 23, scope: !771)
!791 = !DILocation(line: 599, column: 23, scope: !771)
!792 = !DILocation(line: 599, column: 28, scope: !771)
!793 = !DILocation(line: 599, column: 26, scope: !771)
!794 = !DILocation(line: 599, column: 29, scope: !771)
!795 = !DILocation(line: 601, column: 24, scope: !771)
!796 = !DILocation(line: 602, column: 24, scope: !771)
!797 = !DILocation(line: 602, column: 29, scope: !771)
!798 = !DILocation(line: 602, column: 27, scope: !771)
!799 = !DILocation(line: 602, column: 30, scope: !771)
!800 = !DILocation(line: 611, column: 20, scope: !771)
!801 = !DILocation(line: 612, column: 11, scope: !771)
!802 = !DILocation(line: 612, column: 18, scope: !771)
!803 = !DILocation(line: 612, column: 15, scope: !771)
!804 = !DILocation(line: 612, column: 32, scope: !771)
!805 = !DILocation(line: 612, column: 39, scope: !771)
!806 = !DILocation(line: 612, column: 36, scope: !771)
!807 = !DILocation(line: 612, column: 52, scope: !771)
!808 = !DILocation(line: 612, column: 59, scope: !771)
!809 = !DILocation(line: 612, column: 56, scope: !771)
!810 = !DILocation(line: 612, column: 5, scope: !771)
!811 = !DILocation(line: 613, column: 24, scope: !771)
!812 = !DILocation(line: 616, column: 15, scope: !771)
!813 = !DILocation(line: 617, column: 11, scope: !771)
!814 = !DILocation(line: 617, column: 18, scope: !771)
!815 = !DILocation(line: 617, column: 15, scope: !771)
!816 = !DILocation(line: 617, column: 30, scope: !771)
!817 = !DILocation(line: 617, column: 5, scope: !771)
!818 = !DILocation(line: 618, column: 19, scope: !771)
!819 = !DILocation(line: 621, column: 9, scope: !771)
!820 = !DILocation(line: 621, column: 5, scope: !771)
!821 = !DILocation(line: 627, column: 9, scope: !771)
!822 = !DILocation(line: 629, column: 13, scope: !771)
!823 = !DILocation(line: 629, column: 25, scope: !771)
!824 = !DILocation(line: 629, column: 21, scope: !771)
!825 = !DILocation(line: 629, column: 9, scope: !771)
!826 = !DILocation(line: 632, column: 13, scope: !771)
!827 = !DILocation(line: 636, column: 13, scope: !771)
!828 = !DILocation(line: 641, column: 9, scope: !771)
!829 = !DILocation(line: 646, column: 13, scope: !771)
!830 = !DILocation(line: 646, column: 9, scope: !771)
!831 = !DILocation(line: 647, column: 30, scope: !771)
!832 = !DILocation(line: 647, column: 35, scope: !771)
!833 = !DILocation(line: 647, column: 46, scope: !771)
!834 = !DILocation(line: 647, column: 50, scope: !771)
!835 = !DILocation(line: 647, column: 54, scope: !771)
!836 = !DILocation(line: 647, column: 57, scope: !771)
!837 = !DILocation(line: 647, column: 60, scope: !771)
!838 = !DILocation(line: 647, column: 63, scope: !771)
!839 = !DILocation(line: 647, column: 13, scope: !771)
!840 = !DILocation(line: 661, column: 9, scope: !771)
!841 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit", scope: null, file: !578, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!842 = !DILocation(line: 43, column: 3, scope: !843)
!843 = !DILexicalBlockFile(scope: !841, file: !578, discriminator: 0)
!844 = !DILocation(line: 41, column: 3, scope: !843)
!845 = !DILocation(line: 40, column: 3, scope: !843)
!846 = !DILocation(line: 39, column: 9, scope: !843)
!847 = !DILocation(line: 40, column: 23, scope: !843)
!848 = !DILocation(line: 41, column: 70, scope: !843)
!849 = !DILocation(line: 41, column: 68, scope: !843)
!850 = !DILocation(line: 43, column: 27, scope: !843)
!851 = !DILocation(line: 43, column: 15, scope: !843)
!852 = !DILocation(line: 44, column: 15, scope: !843)
!853 = !DILocation(line: 44, column: 21, scope: !843)
!854 = !DILocation(line: 44, column: 27, scope: !843)
!855 = !DILocation(line: 44, column: 3, scope: !843)
!856 = !DILocation(line: 39, column: 1, scope: !843)
!857 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord", scope: null, file: !595, line: 4, type: !5, scopeLine: 4, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!858 = !DILocation(line: 5, column: 10, scope: !859)
!859 = !DILexicalBlockFile(scope: !857, file: !595, discriminator: 0)
!860 = !DILocation(line: 5, column: 67, scope: !859)
!861 = !DILocation(line: 5, column: 3, scope: !859)
!862 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord", scope: null, file: !595, line: 8, type: !5, scopeLine: 8, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!863 = !DILocation(line: 9, column: 10, scope: !864)
!864 = !DILexicalBlockFile(scope: !862, file: !595, discriminator: 0)
!865 = !DILocation(line: 9, column: 67, scope: !864)
!866 = !DILocation(line: 9, column: 3, scope: !864)
!867 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord", scope: null, file: !606, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!868 = !DILocation(line: 50, column: 3, scope: !869)
!869 = !DILexicalBlockFile(scope: !867, file: !606, discriminator: 0)
!870 = !DILocation(line: 43, column: 21, scope: !869)
!871 = !DILocation(line: 50, column: 57, scope: !869)
!872 = !DILocation(line: 50, column: 68, scope: !869)
!873 = !DILocation(line: 50, column: 41, scope: !869)
!874 = !DILocation(line: 50, column: 19, scope: !869)
!875 = !DILocation(line: 52, column: 10, scope: !869)
!876 = !DILocation(line: 52, column: 18, scope: !869)
!877 = !DILocation(line: 48, column: 22, scope: !869)
!878 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr", linkageName: "sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr", scope: null, file: !879, line: 11, type: !5, scopeLine: 11, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!879 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/input_queue_config.csl", directory: "")
!880 = !DILocation(line: 11, column: 32, scope: !881)
!881 = !DILexicalBlockFile(scope: !878, file: !879, discriminator: 0)
!882 = !DILocation(line: 12, column: 80, scope: !881)
!883 = !DILocation(line: 12, column: 69, scope: !881)
!884 = !DILocation(line: 12, column: 39, scope: !881)
!885 = !DILocation(line: 12, column: 3, scope: !881)
!886 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue", linkageName: "sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue", scope: null, file: !879, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!887 = !DILocation(line: 46, column: 3, scope: !888)
!888 = !DILexicalBlockFile(scope: !886, file: !879, discriminator: 0)
!889 = !DILocation(line: 45, column: 3, scope: !888)
!890 = !DILocation(line: 39, column: 42, scope: !888)
!891 = !DILocation(line: 39, column: 34, scope: !888)
!892 = !DILocation(line: 39, column: 24, scope: !888)
!893 = !DILocation(line: 45, column: 44, scope: !888)
!894 = !DILocation(line: 45, column: 16, scope: !888)
!895 = !DILocation(line: 46, column: 30, scope: !888)
!896 = !DILocation(line: 46, column: 18, scope: !888)
!897 = !DILocation(line: 56, column: 9, scope: !888)
!898 = !DILocation(line: 56, column: 5, scope: !888)
!899 = !DILocation(line: 58, column: 13, scope: !888)
!900 = !DILocation(line: 58, column: 17, scope: !888)
!901 = !DILocation(line: 58, column: 11, scope: !888)
!902 = !DILocation(line: 61, column: 13, scope: !888)
!903 = !DILocation(line: 61, column: 17, scope: !888)
!904 = !DILocation(line: 61, column: 11, scope: !888)
!905 = !DILocation(line: 66, column: 9, scope: !888)
!906 = !DILocation(line: 66, column: 13, scope: !888)
!907 = !DILocation(line: 66, column: 7, scope: !888)
!908 = !DILocation(line: 68, column: 9, scope: !888)
!909 = !DILocation(line: 68, column: 24, scope: !888)
!910 = !DILocation(line: 68, column: 13, scope: !888)
!911 = !DILocation(line: 68, column: 7, scope: !888)
!912 = !DILocation(line: 70, column: 15, scope: !888)
!913 = !DILocation(line: 70, column: 21, scope: !888)
!914 = !DILocation(line: 70, column: 3, scope: !888)
!915 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr", linkageName: "sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr", scope: null, file: !916, line: 11, type: !5, scopeLine: 11, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!916 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/output_queue_config.csl", directory: "")
!917 = !DILocation(line: 11, column: 33, scope: !918)
!918 = !DILexicalBlockFile(scope: !915, file: !916, discriminator: 0)
!919 = !DILocation(line: 12, column: 82, scope: !918)
!920 = !DILocation(line: 12, column: 40, scope: !918)
!921 = !DILocation(line: 12, column: 3, scope: !918)
!922 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue", linkageName: "sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue", scope: null, file: !916, line: 31, type: !5, scopeLine: 31, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!923 = !DILocation(line: 38, column: 3, scope: !924)
!924 = !DILexicalBlockFile(scope: !922, file: !916, discriminator: 0)
!925 = !DILocation(line: 37, column: 3, scope: !924)
!926 = !DILocation(line: 31, column: 35, scope: !924)
!927 = !DILocation(line: 31, column: 25, scope: !924)
!928 = !DILocation(line: 37, column: 45, scope: !924)
!929 = !DILocation(line: 37, column: 16, scope: !924)
!930 = !DILocation(line: 38, column: 30, scope: !924)
!931 = !DILocation(line: 38, column: 18, scope: !924)
!932 = !DILocation(line: 41, column: 9, scope: !924)
!933 = !DILocation(line: 41, column: 13, scope: !924)
!934 = !DILocation(line: 41, column: 7, scope: !924)
!935 = !DILocation(line: 43, column: 9, scope: !924)
!936 = !DILocation(line: 43, column: 24, scope: !924)
!937 = !DILocation(line: 43, column: 13, scope: !924)
!938 = !DILocation(line: 43, column: 27, scope: !924)
!939 = !DILocation(line: 43, column: 7, scope: !924)
!940 = !DILocation(line: 45, column: 15, scope: !924)
!941 = !DILocation(line: 45, column: 21, scope: !924)
!942 = !DILocation(line: 45, column: 3, scope: !924)
!943 = !DILocation(line: 31, column: 1, scope: !924)
!944 = distinct !DISubprogram(name: ".get_tensor_ptr", linkageName: ".get_tensor_ptr", scope: null, file: !4, line: 1, type: !5, scopeLine: 1, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!945 = !DILocation(line: 1, column: 1, scope: !946)
!946 = !DILexicalBlockFile(scope: !944, file: !4, discriminator: 0)
!947 = distinct !DISubprogram(name: "__generic0sys_mod.sys_mod.tile_config.queue_flush.exit", linkageName: "__generic0sys_mod.sys_mod.tile_config.queue_flush.exit", scope: null, file: !948, line: 12, type: !5, scopeLine: 12, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!948 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/queue_flush.csl", directory: "")
!949 = !DILocation(line: 24, column: 3, scope: !950)
!950 = !DILexicalBlockFile(scope: !947, file: !948, discriminator: 0)
!951 = !DILocation(line: 12, column: 1, scope: !950)
!952 = distinct !DISubprogram(name: "__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position", linkageName: "__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position", scope: null, file: !953, line: 30, type: !5, scopeLine: 30, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!953 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/switch_config.csl", directory: "")
!954 = !DILocation(line: 34, column: 3, scope: !955)
!955 = !DILexicalBlockFile(scope: !952, file: !953, discriminator: 0)
!956 = !DILocation(line: 32, column: 3, scope: !955)
!957 = !DILocation(line: 30, column: 27, scope: !955)
!958 = !DILocation(line: 33, column: 7, scope: !955)
!959 = !DILocation(line: 34, column: 36, scope: !955)
!960 = !DILocation(line: 34, column: 24, scope: !955)
!961 = !DILocation(line: 35, column: 3, scope: !955)
!962 = !DILocation(line: 35, column: 18, scope: !955)
!963 = !DILocation(line: 36, column: 15, scope: !955)
!964 = !DILocation(line: 36, column: 21, scope: !955)
!965 = !DILocation(line: 36, column: 3, scope: !955)
!966 = !DILocation(line: 30, column: 1, scope: !955)
!967 = distinct !DISubprogram(name: "__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", linkageName: "__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", scope: null, file: !968, line: 96, type: !5, scopeLine: 96, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!968 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/color_config.csl", directory: "")
!969 = !DILocation(line: 99, column: 3, scope: !970)
!970 = !DILexicalBlockFile(scope: !967, file: !968, discriminator: 0)
!971 = !DILocation(line: 98, column: 3, scope: !970)
!972 = !DILocation(line: 96, column: 17, scope: !970)
!973 = !DILocation(line: 98, column: 16, scope: !970)
!974 = !DILocation(line: 99, column: 29, scope: !970)
!975 = !DILocation(line: 99, column: 17, scope: !970)
!976 = !DILocation(line: 100, column: 13, scope: !970)
!977 = !DILocation(line: 100, column: 21, scope: !970)
!978 = !DILocation(line: 100, column: 11, scope: !970)
!979 = !DILocation(line: 104, column: 7, scope: !970)
!980 = !DILocation(line: 104, column: 50, scope: !970)
!981 = !DILocation(line: 104, column: 18, scope: !970)
!982 = !DILocation(line: 104, column: 15, scope: !970)
!983 = !DILocation(line: 121, column: 7, scope: !970)
!984 = !DILocation(line: 121, column: 50, scope: !970)
!985 = !DILocation(line: 121, column: 18, scope: !970)
!986 = !DILocation(line: 121, column: 15, scope: !970)
!987 = !DILocation(line: 128, column: 15, scope: !970)
!988 = !DILocation(line: 128, column: 21, scope: !970)
!989 = !DILocation(line: 128, column: 3, scope: !970)
!990 = !DILocation(line: 96, column: 1, scope: !970)
!991 = distinct !DISubprogram(name: "__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", linkageName: "__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", scope: null, file: !968, line: 96, type: !5, scopeLine: 96, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!992 = !DILocation(line: 99, column: 3, scope: !993)
!993 = !DILexicalBlockFile(scope: !991, file: !968, discriminator: 0)
!994 = !DILocation(line: 98, column: 3, scope: !993)
!995 = !DILocation(line: 96, column: 17, scope: !993)
!996 = !DILocation(line: 98, column: 16, scope: !993)
!997 = !DILocation(line: 99, column: 29, scope: !993)
!998 = !DILocation(line: 99, column: 17, scope: !993)
!999 = !DILocation(line: 100, column: 13, scope: !993)
!1000 = !DILocation(line: 100, column: 21, scope: !993)
!1001 = !DILocation(line: 100, column: 11, scope: !993)
!1002 = !DILocation(line: 104, column: 7, scope: !993)
!1003 = !DILocation(line: 104, column: 50, scope: !993)
!1004 = !DILocation(line: 104, column: 18, scope: !993)
!1005 = !DILocation(line: 104, column: 15, scope: !993)
!1006 = !DILocation(line: 121, column: 7, scope: !993)
!1007 = !DILocation(line: 121, column: 50, scope: !993)
!1008 = !DILocation(line: 121, column: 18, scope: !993)
!1009 = !DILocation(line: 121, column: 15, scope: !993)
!1010 = !DILocation(line: 128, column: 15, scope: !993)
!1011 = !DILocation(line: 128, column: 21, scope: !993)
!1012 = !DILocation(line: 128, column: 3, scope: !993)
!1013 = !DILocation(line: 96, column: 1, scope: !993)
!1014 = distinct !DISubprogram(name: "__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", linkageName: "__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", scope: null, file: !968, line: 60, type: !5, scopeLine: 60, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1015 = !DILocation(line: 61, column: 3, scope: !1016)
!1016 = !DILexicalBlockFile(scope: !1014, file: !968, discriminator: 0)
!1017 = !DILocation(line: 60, column: 46, scope: !1016)
!1018 = !DILocation(line: 61, column: 16, scope: !1016)
!1019 = !DILocation(line: 72, column: 5, scope: !1016)
!1020 = !DILocation(line: 72, column: 12, scope: !1016)
!1021 = !DILocation(line: 74, column: 10, scope: !1016)
!1022 = !DILocation(line: 74, column: 3, scope: !1016)
!1023 = distinct !DISubprogram(name: "__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes", linkageName: "__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes", scope: null, file: !968, line: 77, type: !5, scopeLine: 77, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1024 = !DILocation(line: 78, column: 3, scope: !1025)
!1025 = !DILexicalBlockFile(scope: !1023, file: !968, discriminator: 0)
!1026 = !DILocation(line: 77, column: 46, scope: !1025)
!1027 = !DILocation(line: 78, column: 16, scope: !1025)
!1028 = !DILocation(line: 86, column: 5, scope: !1025)
!1029 = !DILocation(line: 86, column: 12, scope: !1025)
!1030 = !DILocation(line: 91, column: 10, scope: !1025)
!1031 = !DILocation(line: 91, column: 3, scope: !1025)
!1032 = distinct !DISubprogram(name: "__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", linkageName: "__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", scope: null, file: !968, line: 60, type: !5, scopeLine: 60, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1033 = !DILocation(line: 61, column: 3, scope: !1034)
!1034 = !DILexicalBlockFile(scope: !1032, file: !968, discriminator: 0)
!1035 = !DILocation(line: 60, column: 46, scope: !1034)
!1036 = !DILocation(line: 61, column: 16, scope: !1034)
!1037 = !DILocation(line: 63, column: 5, scope: !1034)
!1038 = !DILocation(line: 63, column: 12, scope: !1034)
!1039 = !DILocation(line: 74, column: 10, scope: !1034)
!1040 = !DILocation(line: 74, column: 3, scope: !1034)
!1041 = distinct !DISubprogram(name: "__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction", linkageName: "__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction", scope: null, file: !968, line: 52, type: !5, scopeLine: 52, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1042 = !DILocation(line: 55, column: 3, scope: !1043)
!1043 = !DILexicalBlockFile(scope: !1041, file: !968, discriminator: 0)
!1044 = !DILocation(line: 54, column: 3, scope: !1043)
!1045 = !DILocation(line: 52, column: 23, scope: !1043)
!1046 = !DILocation(line: 54, column: 16, scope: !1043)
!1047 = !DILocation(line: 55, column: 29, scope: !1043)
!1048 = !DILocation(line: 55, column: 17, scope: !1043)
!1049 = !DILocation(line: 56, column: 3, scope: !1043)
!1050 = !DILocation(line: 56, column: 11, scope: !1043)
!1051 = !DILocation(line: 57, column: 15, scope: !1043)
!1052 = !DILocation(line: 57, column: 21, scope: !1043)
!1053 = !DILocation(line: 57, column: 3, scope: !1043)
!1054 = !DILocation(line: 52, column: 1, scope: !1043)
!1055 = distinct !DISubprogram(name: "__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction", linkageName: "__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction", scope: null, file: !968, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1056 = !DILocation(line: 23, column: 3, scope: !1057)
!1057 = !DILexicalBlockFile(scope: !1055, file: !968, discriminator: 0)
!1058 = !DILocation(line: 22, column: 3, scope: !1057)
!1059 = !DILocation(line: 20, column: 21, scope: !1057)
!1060 = !DILocation(line: 22, column: 16, scope: !1057)
!1061 = !DILocation(line: 23, column: 29, scope: !1057)
!1062 = !DILocation(line: 23, column: 17, scope: !1057)
!1063 = !DILocation(line: 24, column: 3, scope: !1057)
!1064 = !DILocation(line: 24, column: 11, scope: !1057)
!1065 = !DILocation(line: 25, column: 15, scope: !1057)
!1066 = !DILocation(line: 25, column: 21, scope: !1057)
!1067 = !DILocation(line: 25, column: 3, scope: !1057)
!1068 = !DILocation(line: 20, column: 1, scope: !1057)
module asm ".section \22.pe_debug_info\22, \22\22"
module asm ".section \22.note\22, \22\22"
