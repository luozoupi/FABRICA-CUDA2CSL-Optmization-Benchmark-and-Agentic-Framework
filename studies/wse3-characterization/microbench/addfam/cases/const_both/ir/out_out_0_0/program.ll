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
  store i16 10, i16* getelementptr inbounds ([64 x i16], [64 x i16]* @c, i16 0, i1 false), align 2, !dbg !7
  call void @llvm.sdr.actvt.r(i16 9), !dbg !9
  ret void, !dbg !10
}

define void @f_exit() #0 !dbg !11 {
  call void @sys_mod.unblock_cmd_stream(), !dbg !12
  ret void, !dbg !14
}

define internal void @sys_mod.sys_nop() !dbg !15 {
  ret void, !dbg !17
}

define internal void @sys_mod.unblock_cmd_stream() !dbg !19 {
  call void @sys_mod.sys_mod.unblock_cmd_stream(), !dbg !20
  ret void, !dbg !22
}

define internal void @sys_mod.sys_mod.unblock_cmd_stream() !dbg !23 {
  call void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream(), !dbg !25
  ret void, !dbg !27
}

define internal void @sys_mod.sys_mod.teardown_h2d() !dbg !28 {
  call void @llvm.sdr.actvt.r(i16 27), !dbg !29
  ret void, !dbg !31
}

define void @sys_mod.sys_mod.f_ublk_c22() #1 !dbg !32 {
  call void @sys_mod.sys_mod.unblock_cmd_stream(), !dbg !33
  ret void, !dbg !35
}

define internal void @sys_mod.sys_mod.teardown_d2h() !dbg !36 {
  call void @llvm.sdr.blk.r(i16 0), !dbg !37
  call void @llvm.sdr.actvt.r(i16 28), !dbg !39
  ret void, !dbg !40
}

define void @sys_mod.sys_mod.f_memcpyh2d() #2 !dbg !41 {
  %1 = alloca float, i16 1, align 4, !dbg !42
  %2 = alloca float, i16 1, align 4, !dbg !44
  %3 = alloca i16, i16 1, align 2, !dbg !45
  %4 = alloca i16, i16 1, align 2, !dbg !46
  %5 = alloca i16, i16 1, align 2, !dbg !47
  %6 = alloca i16, i16 1, align 2, !dbg !48
  %7 = alloca i16, i16 1, align 2, !dbg !49
  %8 = alloca i16, i16 1, align 2, !dbg !50
  %9 = alloca i16, i16 1, align 2, !dbg !51
  %10 = alloca i16, i16 1, align 2, !dbg !52
  %11 = alloca i16, i16 1, align 2, !dbg !53
  %12 = alloca i16, i16 1, align 2, !dbg !54
  %13 = alloca i16, i16 1, align 2, !dbg !55
  %14 = alloca i16*, i16 1, align 8, !dbg !56
  %15 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !57
  %16 = icmp eq i16 %15, 15, !dbg !58
  br i1 %16, label %17, label %18, !dbg !59

17:                                               ; preds = %0
  br label %19, !dbg !59

18:                                               ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !59
  br label %19, !dbg !59

19:                                               ; preds = %17, %18
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %14, align 8, !dbg !56
  %20 = load i16*, i16** %14, align 8, !dbg !60
  %21 = load i16, i16* %20, align 2, !dbg !61
  store i16 %21, i16* %13, align 2, !dbg !55
  %22 = load i16*, i16** %14, align 8, !dbg !62
  %23 = getelementptr i16, i16* %22, i16 1, !dbg !63
  %24 = load i16, i16* %23, align 2, !dbg !63
  store i16 %24, i16* %12, align 2, !dbg !54
  %25 = load i16*, i16** %14, align 8, !dbg !64
  %26 = getelementptr i16, i16* %25, i16 2, !dbg !65
  %27 = load i16, i16* %26, align 2, !dbg !65
  store i16 %27, i16* %11, align 2, !dbg !53
  %28 = load i16*, i16** %14, align 8, !dbg !66
  %29 = getelementptr i16, i16* %28, i16 3, !dbg !67
  %30 = load i16, i16* %29, align 2, !dbg !67
  store i16 %30, i16* %10, align 2, !dbg !52
  %31 = load i16*, i16** %14, align 8, !dbg !68
  %32 = getelementptr i16, i16* %31, i16 4, !dbg !69
  %33 = load i16, i16* %32, align 2, !dbg !69
  store i16 %33, i16* %9, align 2, !dbg !51
  %34 = load i16*, i16** %14, align 8, !dbg !70
  %35 = getelementptr i16, i16* %34, i16 5, !dbg !71
  %36 = load i16, i16* %35, align 2, !dbg !71
  store i16 %36, i16* %8, align 2, !dbg !50
  %37 = load i16*, i16** %14, align 8, !dbg !72
  %38 = getelementptr i16, i16* %37, i16 6, !dbg !73
  %39 = load i16, i16* %38, align 2, !dbg !73
  store i16 %39, i16* %7, align 2, !dbg !49
  %40 = load i16*, i16** %14, align 8, !dbg !74
  %41 = getelementptr i16, i16* %40, i16 7, !dbg !75
  %42 = load i16, i16* %41, align 2, !dbg !75
  store i16 %42, i16* %6, align 2, !dbg !48
  %43 = load i16*, i16** %14, align 8, !dbg !76
  %44 = getelementptr i16, i16* %43, i16 8, !dbg !77
  %45 = load i16, i16* %44, align 2, !dbg !77
  store i16 %45, i16* %5, align 2, !dbg !47
  %46 = load i16*, i16** %14, align 8, !dbg !78
  %47 = getelementptr i16, i16* %46, i16 9, !dbg !79
  %48 = load i16, i16* %47, align 2, !dbg !79
  store i16 %48, i16* %4, align 2, !dbg !46
  %49 = load i16*, i16** %14, align 8, !dbg !80
  %50 = getelementptr i16, i16* %49, i16 10, !dbg !81
  %51 = load i16, i16* %50, align 2, !dbg !81
  store i16 %51, i16* %3, align 2, !dbg !45
  %52 = load i16*, i16** %14, align 8, !dbg !82
  %53 = getelementptr i16, i16* %52, i16 12, !dbg !83
  %54 = load i16, i16* %53, align 2, !dbg !83
  %55 = zext i16 %54 to i32, !dbg !84
  %56 = load i16*, i16** %14, align 8, !dbg !85
  %57 = getelementptr i16, i16* %56, i16 11, !dbg !86
  %58 = load i16, i16* %57, align 2, !dbg !86
  %59 = zext i16 %58 to i32, !dbg !87
  %60 = add i32 %59, 16, !dbg !88
  %61 = shl i32 %55, %60, !dbg !89
  %62 = bitcast i32 %61 to float, !dbg !90
  store float %62, float* %2, align 4, !dbg !44
  %63 = load i16*, i16** %14, align 8, !dbg !91
  %64 = getelementptr i16, i16* %63, i16 14, !dbg !92
  %65 = load i16, i16* %64, align 2, !dbg !92
  %66 = zext i16 %65 to i32, !dbg !93
  %67 = load i16*, i16** %14, align 8, !dbg !94
  %68 = getelementptr i16, i16* %67, i16 13, !dbg !95
  %69 = load i16, i16* %68, align 2, !dbg !95
  %70 = zext i16 %69 to i32, !dbg !96
  %71 = add i32 %70, 16, !dbg !97
  %72 = shl i32 %66, %71, !dbg !98
  %73 = bitcast i32 %72 to float, !dbg !99
  store float %73, float* %1, align 4, !dbg !42
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !100
  %74 = load i16, i16* %13, align 2, !dbg !101
  store i16 %74, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !102
  %75 = load i16, i16* %12, align 2, !dbg !103
  store i16 %75, i16* @sys_mod.sys_mod.memcpyH2D_px, align 2, !dbg !104
  %76 = load i16, i16* %11, align 2, !dbg !105
  store i16 %76, i16* @sys_mod.sys_mod.memcpyH2D_py, align 2, !dbg !106
  %77 = load i16, i16* %10, align 2, !dbg !107
  store i16 %77, i16* @sys_mod.sys_mod.memcpyH2D_w, align 2, !dbg !108
  %78 = load i16, i16* %9, align 2, !dbg !109
  store i16 %78, i16* @sys_mod.sys_mod.memcpyH2D_h, align 2, !dbg !110
  %79 = load i16, i16* %8, align 2, !dbg !111
  store i16 %79, i16* @sys_mod.sys_mod.memcpyH2D_addr, align 2, !dbg !112
  %80 = load i16, i16* %7, align 2, !dbg !113
  store i16 %80, i16* @sys_mod.sys_mod.memcpyH2D_pe_length, align 2, !dbg !114
  %81 = load i16, i16* %6, align 2, !dbg !115
  store i16 %81, i16* @sys_mod.sys_mod.memcpyH2D_is_half, align 2, !dbg !116
  %82 = load i16, i16* %5, align 2, !dbg !117
  store i16 %82, i16* @sys_mod.sys_mod.memcpyH2D_memcpy_optype, align 2, !dbg !118
  %83 = load i16, i16* %4, align 2, !dbg !119
  store i16 %83, i16* @sys_mod.sys_mod.memcpyH2D_row_stride, align 2, !dbg !120
  %84 = load i16, i16* %3, align 2, !dbg !121
  store i16 %84, i16* @sys_mod.sys_mod.memcpyH2D_col_stride, align 2, !dbg !122
  %85 = load float, float* %2, align 4, !dbg !123
  store float %85, float* @sys_mod.sys_mod.memcpyH2D_one_over_row_stride, align 4, !dbg !124
  %86 = load float, float* %1, align 4, !dbg !125
  store float %86, float* @sys_mod.sys_mod.memcpyH2D_one_over_col_stride, align 4, !dbg !126
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !127
  call void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 0, i16 23, i1 true), !dbg !128
  call void @llvm.sdr.blk.r(i16 27), !dbg !129
  call void @llvm.sdr.oqflush(i16 0), !dbg !130
  store i1 true, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !131
  call void @llvm.sdr.blk.r(i16 0), !dbg !132
  ret void, !dbg !133
}

define void @sys_mod.sys_mod.f_memcpyd2h() #3 !dbg !134 {
  %1 = alloca i16, i16 1, align 2, !dbg !135
  %2 = alloca i16, i16 1, align 2, !dbg !137
  %3 = alloca i16, i16 1, align 2, !dbg !138
  %4 = alloca i16, i16 1, align 2, !dbg !139
  %5 = alloca i16, i16 1, align 2, !dbg !140
  %6 = alloca i16, i16 1, align 2, !dbg !141
  %7 = alloca i16, i16 1, align 2, !dbg !142
  %8 = alloca i16, i16 1, align 2, !dbg !143
  %9 = alloca i16*, i16 1, align 8, !dbg !144
  %10 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !145
  %11 = icmp eq i16 %10, 8, !dbg !146
  br i1 %11, label %12, label %13, !dbg !147

12:                                               ; preds = %0
  br label %14, !dbg !147

13:                                               ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !147
  br label %14, !dbg !147

14:                                               ; preds = %12, %13
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %9, align 8, !dbg !144
  %15 = load i16*, i16** %9, align 8, !dbg !148
  %16 = load i16, i16* %15, align 2, !dbg !149
  store i16 %16, i16* %8, align 2, !dbg !143
  %17 = load i16*, i16** %9, align 8, !dbg !150
  %18 = getelementptr i16, i16* %17, i16 1, !dbg !151
  %19 = load i16, i16* %18, align 2, !dbg !151
  store i16 %19, i16* %7, align 2, !dbg !142
  %20 = load i16*, i16** %9, align 8, !dbg !152
  %21 = getelementptr i16, i16* %20, i16 2, !dbg !153
  %22 = load i16, i16* %21, align 2, !dbg !153
  store i16 %22, i16* %6, align 2, !dbg !141
  %23 = load i16*, i16** %9, align 8, !dbg !154
  %24 = getelementptr i16, i16* %23, i16 3, !dbg !155
  %25 = load i16, i16* %24, align 2, !dbg !155
  store i16 %25, i16* %5, align 2, !dbg !140
  %26 = load i16*, i16** %9, align 8, !dbg !156
  %27 = getelementptr i16, i16* %26, i16 4, !dbg !157
  %28 = load i16, i16* %27, align 2, !dbg !157
  store i16 %28, i16* %4, align 2, !dbg !139
  %29 = load i16*, i16** %9, align 8, !dbg !158
  %30 = getelementptr i16, i16* %29, i16 5, !dbg !159
  %31 = load i16, i16* %30, align 2, !dbg !159
  store i16 %31, i16* %3, align 2, !dbg !138
  %32 = load i16*, i16** %9, align 8, !dbg !160
  %33 = getelementptr i16, i16* %32, i16 6, !dbg !161
  %34 = load i16, i16* %33, align 2, !dbg !161
  store i16 %34, i16* %2, align 2, !dbg !137
  %35 = load i16*, i16** %9, align 8, !dbg !162
  %36 = getelementptr i16, i16* %35, i16 7, !dbg !163
  %37 = load i16, i16* %36, align 2, !dbg !163
  store i16 %37, i16* %1, align 2, !dbg !135
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !164
  %38 = load i16, i16* %8, align 2, !dbg !165
  store i16 %38, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !166
  %39 = load i16, i16* %7, align 2, !dbg !167
  store i16 %39, i16* @sys_mod.sys_mod.memcpyD2H_px, align 2, !dbg !168
  %40 = load i16, i16* %6, align 2, !dbg !169
  store i16 %40, i16* @sys_mod.sys_mod.memcpyD2H_py, align 2, !dbg !170
  %41 = load i16, i16* %5, align 2, !dbg !171
  store i16 %41, i16* @sys_mod.sys_mod.memcpyD2H_w, align 2, !dbg !172
  %42 = load i16, i16* %4, align 2, !dbg !173
  store i16 %42, i16* @sys_mod.sys_mod.memcpyD2H_h, align 2, !dbg !174
  %43 = load i16, i16* %3, align 2, !dbg !175
  store i16 %43, i16* @sys_mod.sys_mod.memcpyD2H_addr, align 2, !dbg !176
  %44 = load i16, i16* %2, align 2, !dbg !177
  store i16 %44, i16* @sys_mod.sys_mod.memcpyD2H_pe_length, align 2, !dbg !178
  %45 = load i16, i16* %1, align 2, !dbg !179
  store i16 %45, i16* @sys_mod.sys_mod.memcpyD2H_is_half, align 2, !dbg !180
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !181
  %46 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !182
  call void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 0, i16 %46, i1 false), !dbg !183
  call void @llvm.sdr.oqflush(i16 0), !dbg !184
  store i1 false, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !185
  ret void, !dbg !186
}

define internal void @sys_mod.sys_mod.oq0_teardow_handler() !dbg !187 {
  %1 = load i1, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !188
  br i1 %1, label %2, label %17, !dbg !190

2:                                                ; preds = %0
  %3 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !191
  call void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 0, i16 %3), !dbg !192
  %4 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !193
  %5 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_px, align 2, !dbg !194
  %6 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_py, align 2, !dbg !195
  %7 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_w, align 2, !dbg !196
  %8 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_h, align 2, !dbg !197
  %9 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_addr, align 2, !dbg !198
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_pe_length, align 2, !dbg !199
  %11 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_is_half, align 2, !dbg !200
  %12 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_memcpy_optype, align 2, !dbg !201
  %13 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_row_stride, align 2, !dbg !202
  %14 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_col_stride, align 2, !dbg !203
  %15 = load float, float* @sys_mod.sys_mod.memcpyH2D_one_over_row_stride, align 4, !dbg !204
  %16 = load float, float* @sys_mod.sys_mod.memcpyH2D_one_over_col_stride, align 4, !dbg !205
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure(i16 %4, i16 %5, i16 %6, i16 %7, i16 %8, i16 %9, i16 %10, i16 %11, i16 %12, i16 %13, i16 %14, float %15, float %16), !dbg !206
  br label %26, !dbg !190

17:                                               ; preds = %0
  call void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 0, i16 21), !dbg !207
  %18 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !208
  %19 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_px, align 2, !dbg !209
  %20 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_py, align 2, !dbg !210
  %21 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_w, align 2, !dbg !211
  %22 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_h, align 2, !dbg !212
  %23 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_addr, align 2, !dbg !213
  %24 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_pe_length, align 2, !dbg !214
  %25 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_is_half, align 2, !dbg !215
  call void @sys_mod.sys_mod.memcpyd2h_mod.d2h_configure(i16 %18, i16 %19, i16 %20, i16 %21, i16 %22, i16 %23, i16 %24, i16 %25), !dbg !216
  br label %26, !dbg !190

26:                                               ; preds = %2, %17
  call void @__generic0sys_mod.sys_mod.tile_config.queue_flush.exit(), !dbg !217
  ret void, !dbg !190
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

define void @sys_mod.sys_mod.f_rpc(i16 %0) #4 !dbg !218 {
  %2 = alloca i16, i16 1, align 2, !dbg !219
  store i16 %0, i16* %2, align 2, !dbg !219
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !221
  %3 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !222
  %4 = icmp sge i16 %3, 4, !dbg !223
  br i1 %4, label %5, label %6, !dbg !224

5:                                                ; preds = %1
  br label %7, !dbg !224

6:                                                ; preds = %1
  call void asm sideeffect "hcf", ""(), !dbg !224
  br label %7, !dbg !224

7:                                                ; preds = %5, %6
  call void @rpc_server(i32* getelementptr inbounds ([32 x i32], [32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32, i32 0, i32 0)), !dbg !225
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !226
  ret void, !dbg !227
}

define internal void @sys_mod.sys_mod.sys_mod.stack_push(i16 %0) !dbg !228 {
  %2 = alloca i16*, i16 1, align 8, !dbg !230
  %3 = alloca i16, i16 1, align 2, !dbg !232
  store i16 %0, i16* %3, align 2, !dbg !232
  %4 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !233
  %5 = icmp slt i16 %4, 32, !dbg !234
  br i1 %5, label %6, label %7, !dbg !235

6:                                                ; preds = %1
  br label %8, !dbg !235

7:                                                ; preds = %1
  call void asm sideeffect "hcf", ""(), !dbg !235
  br label %8, !dbg !235

8:                                                ; preds = %6, %7
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %2, align 8, !dbg !230
  %9 = load i16, i16* %3, align 2, !dbg !236
  %10 = load i16*, i16** %2, align 8, !dbg !237
  %11 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !238
  %12 = getelementptr i16, i16* %10, i16 %11, !dbg !239
  store i16 %9, i16* %12, align 2, !dbg !240
  %13 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !241
  %14 = add i16 %13, 1, !dbg !242
  store i16 %14, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !243
  ret void, !dbg !244
}

define void @sys_mod.sys_mod.sys_mod.f_push(i16 %0, i16 %1) #5 !dbg !245 {
  %3 = alloca i16, i16 1, align 2, !dbg !246
  %4 = alloca i16, i16 1, align 2, !dbg !248
  store i16 %0, i16* %4, align 2, !dbg !248
  store i16 %1, i16* %3, align 2, !dbg !246
  %5 = load i16, i16* %4, align 2, !dbg !249
  call void @sys_mod.sys_mod.sys_mod.stack_push(i16 %5), !dbg !250
  ret void, !dbg !251
}

define internal void @sys_mod.sys_mod.sys_mod.block_cmd_stream() !dbg !252 {
  call void @llvm.sdr.blk.r(i16 1), !dbg !253
  ret void, !dbg !255
}

define internal void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream() !dbg !256 {
  call void @llvm.sdr.ublk.r(i16 1), !dbg !257
  ret void, !dbg !259
}

define void @sys_mod.sys_mod.sys_mod.f_sys_exit() #6 !dbg !260 {
  call void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream(), !dbg !261
  call void @sys_mod.sys_nop(), !dbg !263
  ret void, !dbg !264
}

define void @sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore(i32 %0) #7 !dbg !265 {
  %2 = alloca i32, i16 1, align 4, !dbg !266
  store i32 %0, i32* %2, align 4, !dbg !266
  ret void, !dbg !268
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord() !dbg !269 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord(), !dbg !271
  ret i16 %1, !dbg !273
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord() !dbg !274 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord(), !dbg !275
  ret i16 %1, !dbg !277
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval(i16 %0) !dbg !278 {
  %2 = alloca i16, i16 1, align 2, !dbg !279
  store i16 %0, i16* %2, align 2, !dbg !279
  %3 = load i16, i16* %2, align 2, !dbg !281
  %4 = icmp ult i16 %3, 24, !dbg !282
  br i1 %4, label %5, label %7, !dbg !283

5:                                                ; preds = %10, %11, %1
  %6 = phi i16 [ 0, %10 ], [ 0, %11 ], [ 1, %1 ]
  br label %12, !dbg !283

7:                                                ; preds = %1
  %8 = load i16, i16* %2, align 2, !dbg !284
  %9 = icmp eq i16 31, %8, !dbg !285
  br i1 %9, label %10, label %11, !dbg !286

10:                                               ; preds = %7
  br label %5, !dbg !286

11:                                               ; preds = %7
  call void asm sideeffect "hcf", ""(), !dbg !286
  br label %5, !dbg !286

12:                                               ; preds = %5
  %13 = phi i16 [ %6, %5 ]
  br label %14, !dbg !283

14:                                               ; preds = %12
  ret i16 %13, !dbg !283
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start(i16 %0, i16 %1, i16 %2) !dbg !287 {
  %4 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !288
  %5 = alloca i16, i16 1, align 2, !dbg !290
  %6 = alloca i16, i16 1, align 2, !dbg !291
  %7 = alloca i16, i16 1, align 2, !dbg !292
  store i16 %0, i16* %7, align 2, !dbg !292
  store i16 %1, i16* %6, align 2, !dbg !291
  store i16 %2, i16* %5, align 2, !dbg !290
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !293
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !293
  %10 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !293
  %11 = load i16, i16* %6, align 2, !dbg !294
  store i16 %11, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !295
  store i16 %8, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !295
  store i16 %9, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !295
  store i16 %10, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !295
  %12 = load i16, i16* %7, align 2, !dbg !296
  %13 = call i16* @.get_tensor_ptr(i16 %12), !dbg !297
  %14 = ptrtoint i16* %13 to i16, !dbg !298
  %15 = lshr i16 %14, 1, !dbg !298
  %16 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !288
  store i16 42, i16* %16, align 2, !dbg !288
  %17 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !288
  store i16 %15, i16* %17, align 2, !dbg !288
  %18 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !288
  store i16 143, i16* %18, align 2, !dbg !288
  %19 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !288
  store i16 16, i16* %19, align 2, !dbg !288
  %20 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !299
  %21 = load i16, i16* %20, align 2, !dbg !299
  %22 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !299
  %23 = load i16, i16* %22, align 2, !dbg !299
  %24 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !299
  %25 = load i16, i16* %24, align 2, !dbg !299
  %26 = load i16, i16* %6, align 2, !dbg !300
  %27 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !301
  store i16 %26, i16* %27, align 2, !dbg !301
  %28 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !301
  store i16 %21, i16* %28, align 2, !dbg !301
  %29 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !301
  store i16 %23, i16* %29, align 2, !dbg !301
  %30 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !301
  store i16 %25, i16* %30, align 2, !dbg !301
  %31 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !302
  %32 = load i16, i16* %31, align 2, !dbg !302
  %33 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !302
  %34 = load i16, i16* %33, align 2, !dbg !302
  %35 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !302
  %36 = load i16, i16* %35, align 2, !dbg !302
  %37 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !302
  %38 = load i16, i16* %37, align 2, !dbg !302
  store volatile i16 %32, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !303
  store volatile i16 %34, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !303
  store volatile i16 %36, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !303
  store volatile i16 %38, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !303
  call void asm sideeffect "nop", ""(), !dbg !303
  call void asm sideeffect "nop", ""(), !dbg !303
  %39 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !304
  %40 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !304
  %41 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !304
  %42 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !304
  %43 = and i16 %41, -193, !dbg !304
  %44 = or i16 %43, 128, !dbg !304
  %45 = and i16 %40, -64, !dbg !304
  %46 = or i16 %45, 27, !dbg !304
  store volatile i16 %39, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !305
  store volatile i16 %46, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !305
  store volatile i16 %44, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !305
  store volatile i16 %42, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !305
  call void asm sideeffect "nop", ""(), !dbg !305
  call void asm sideeffect "nop", ""(), !dbg !305
  %47 = load i16, i16* %5, align 2, !dbg !306
  %48 = icmp ult i16 0, %47, !dbg !307
  br i1 %48, label %49, label %50, !dbg !308

49:                                               ; preds = %3
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !309
  br label %51, !dbg !308

50:                                               ; preds = %3
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !310
  br label %51, !dbg !308

51:                                               ; preds = %49, %50
  ret void, !dbg !308
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream() !dbg !311 {
  call void @llvm.sdr.ublk.r(i16 1), !dbg !312
  ret void, !dbg !314
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7, i16 %8, i16 %9, i16 %10, float %11, float %12) !dbg !315 {
  %14 = alloca i16, i16 1, align 2, !dbg !316
  %15 = alloca i16, i16 1, align 2, !dbg !318
  %16 = alloca i16, i16 1, align 2, !dbg !319
  %17 = alloca i16, i16 1, align 2, !dbg !320
  %18 = alloca i16, i16 1, align 2, !dbg !321
  %19 = alloca i1, i16 1, align 1, !dbg !322
  %20 = alloca i16, i16 1, align 2, !dbg !323
  %21 = alloca i16, i16 1, align 2, !dbg !324
  %22 = alloca i16, i16 1, align 2, !dbg !325
  %23 = alloca i16, i16 1, align 2, !dbg !326
  %24 = alloca i16, i16 1, align 2, !dbg !327
  %25 = alloca float, i16 1, align 4, !dbg !328
  %26 = alloca float, i16 1, align 4, !dbg !329
  %27 = alloca i16, i16 1, align 2, !dbg !330
  %28 = alloca i16, i16 1, align 2, !dbg !331
  %29 = alloca i16, i16 1, align 2, !dbg !332
  %30 = alloca i16, i16 1, align 2, !dbg !333
  %31 = alloca i16, i16 1, align 2, !dbg !334
  %32 = alloca i16, i16 1, align 2, !dbg !335
  %33 = alloca i16, i16 1, align 2, !dbg !336
  %34 = alloca i16, i16 1, align 2, !dbg !337
  %35 = alloca i16, i16 1, align 2, !dbg !338
  %36 = alloca i16, i16 1, align 2, !dbg !339
  %37 = alloca i16, i16 1, align 2, !dbg !340
  store i16 %0, i16* %37, align 2, !dbg !340
  store i16 %1, i16* %36, align 2, !dbg !339
  store i16 %2, i16* %35, align 2, !dbg !338
  store i16 %3, i16* %34, align 2, !dbg !337
  store i16 %4, i16* %33, align 2, !dbg !336
  store i16 %5, i16* %32, align 2, !dbg !335
  store i16 %6, i16* %31, align 2, !dbg !334
  store i16 %7, i16* %30, align 2, !dbg !333
  store i16 %8, i16* %29, align 2, !dbg !332
  store i16 %9, i16* %28, align 2, !dbg !331
  store i16 %10, i16* %27, align 2, !dbg !330
  store float %11, float* %26, align 4, !dbg !329
  store float %12, float* %25, align 4, !dbg !328
  %38 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord(), !dbg !341
  store i16 %38, i16* %24, align 2, !dbg !327
  %39 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord(), !dbg !342
  store i16 %39, i16* %23, align 2, !dbg !326
  %40 = load i16, i16* %24, align 2, !dbg !343
  %41 = load i16, i16* %36, align 2, !dbg !344
  %42 = sub i16 %40, %41, !dbg !345
  store i16 %42, i16* %22, align 2, !dbg !325
  %43 = load i16, i16* %22, align 2, !dbg !346
  store i16 %43, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !347
  %44 = load i16, i16* %29, align 2, !dbg !348
  %45 = icmp eq i16 3, %44, !dbg !349
  br i1 %45, label %46, label %63, !dbg !350

46:                                               ; preds = %13
  %47 = load i16, i16* %22, align 2, !dbg !351
  %48 = sitofp i16 %47 to float, !dbg !352
  %49 = load float, float* %26, align 4, !dbg !353
  %50 = fmul float %48, %49, !dbg !354
  %51 = fptosi float %50 to i16, !dbg !355
  store i16 %51, i16* %21, align 2, !dbg !324
  %52 = load i16, i16* %22, align 2, !dbg !356
  %53 = load i16, i16* %21, align 2, !dbg !357
  %54 = load i16, i16* %28, align 2, !dbg !358
  %55 = mul i16 %53, %54, !dbg !359
  %56 = sub i16 %52, %55, !dbg !360
  store i16 %56, i16* %20, align 2, !dbg !323
  %57 = load i16, i16* %20, align 2, !dbg !361
  %58 = icmp ne i16 0, %57, !dbg !362
  br i1 %58, label %59, label %60, !dbg !363

59:                                               ; preds = %46
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !364
  br label %62, !dbg !363

60:                                               ; preds = %46
  %61 = load i16, i16* %21, align 2, !dbg !365
  store i16 %61, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !366
  br label %62, !dbg !363

62:                                               ; preds = %59, %60
  br label %63, !dbg !350

63:                                               ; preds = %62, %13
  %64 = load i16, i16* %22, align 2, !dbg !367
  %65 = icmp slt i16 %64, 0, !dbg !368
  br i1 %65, label %66, label %67, !dbg !369

66:                                               ; preds = %63
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !370
  br label %67, !dbg !369

67:                                               ; preds = %66, %63
  %68 = load i16, i16* %22, align 2, !dbg !371
  %69 = load i16, i16* %34, align 2, !dbg !372
  %70 = icmp sge i16 %68, %69, !dbg !373
  br i1 %70, label %71, label %72, !dbg !374

71:                                               ; preds = %67
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !375
  br label %72, !dbg !374

72:                                               ; preds = %71, %67
  store i1 false, i1* %19, align 1, !dbg !322
  %73 = load i16, i16* %29, align 2, !dbg !376
  %74 = icmp eq i16 3, %73, !dbg !377
  br i1 %74, label %75, label %94, !dbg !378

75:                                               ; preds = %72
  %76 = load i16, i16* %23, align 2, !dbg !379
  %77 = load i16, i16* %35, align 2, !dbg !380
  %78 = sub i16 %76, %77, !dbg !381
  %79 = sitofp i16 %78 to float, !dbg !382
  %80 = load float, float* %25, align 4, !dbg !383
  %81 = fmul float %79, %80, !dbg !384
  %82 = fptosi float %81 to i16, !dbg !385
  store i16 %82, i16* %18, align 2, !dbg !321
  %83 = load i16, i16* %23, align 2, !dbg !386
  %84 = load i16, i16* %35, align 2, !dbg !387
  %85 = sub i16 %83, %84, !dbg !388
  %86 = load i16, i16* %18, align 2, !dbg !389
  %87 = load i16, i16* %27, align 2, !dbg !390
  %88 = mul i16 %86, %87, !dbg !391
  %89 = sub i16 %85, %88, !dbg !392
  store i16 %89, i16* %17, align 2, !dbg !320
  %90 = load i16, i16* %17, align 2, !dbg !393
  %91 = icmp ne i16 0, %90, !dbg !394
  br i1 %91, label %92, label %93, !dbg !395

92:                                               ; preds = %75
  store i1 true, i1* %19, align 1, !dbg !396
  br label %93, !dbg !395

93:                                               ; preds = %92, %75
  br label %94, !dbg !378

94:                                               ; preds = %93, %72
  %95 = load i16, i16* %23, align 2, !dbg !397
  %96 = load i16, i16* %35, align 2, !dbg !398
  %97 = icmp slt i16 %95, %96, !dbg !399
  br i1 %97, label %98, label %99, !dbg !400

98:                                               ; preds = %94
  store i1 true, i1* %19, align 1, !dbg !401
  br label %99, !dbg !400

99:                                               ; preds = %98, %94
  %100 = load i16, i16* %23, align 2, !dbg !402
  %101 = load i16, i16* %35, align 2, !dbg !403
  %102 = load i16, i16* %33, align 2, !dbg !404
  %103 = add i16 %101, %102, !dbg !405
  %104 = icmp sge i16 %100, %103, !dbg !406
  br i1 %104, label %105, label %106, !dbg !407

105:                                              ; preds = %99
  store i1 true, i1* %19, align 1, !dbg !408
  br label %106, !dbg !407

106:                                              ; preds = %105, %99
  %107 = load i1, i1* %19, align 1, !dbg !409
  br i1 %107, label %108, label %109, !dbg !410

108:                                              ; preds = %106
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream(), !dbg !411
  call void @llvm.sdr.ublk.r(i16 27), !dbg !412
  br label %180, !dbg !410

109:                                              ; preds = %106
  %110 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !413
  %111 = icmp eq i16 -1, %110, !dbg !414
  br i1 %111, label %112, label %113, !dbg !415

112:                                              ; preds = %109
  call void @__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction(i16 31767), !dbg !416
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 23), !dbg !417
  call void @llvm.sdr.ublk.r(i16 27), !dbg !418
  br label %179, !dbg !415

113:                                              ; preds = %109
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter(i16 0, i16 0), !dbg !419
  %114 = load i16, i16* %34, align 2, !dbg !420
  store i16 %114, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !421
  %115 = load i16, i16* %29, align 2, !dbg !422
  %116 = icmp eq i16 3, %115, !dbg !423
  br i1 %116, label %117, label %126, !dbg !424

117:                                              ; preds = %113
  %118 = load i16, i16* %34, align 2, !dbg !425
  %119 = sub i16 %118, 1, !dbg !426
  %120 = sitofp i16 %119 to float, !dbg !427
  %121 = load float, float* %26, align 4, !dbg !428
  %122 = fmul float %120, %121, !dbg !429
  %123 = fptosi float %122 to i16, !dbg !430
  %124 = add i16 %123, 1, !dbg !431
  store i16 %124, i16* %16, align 2, !dbg !319
  %125 = load i16, i16* %16, align 2, !dbg !432
  store i16 %125, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !433
  br label %131, !dbg !424

126:                                              ; preds = %113
  %127 = load i16, i16* %29, align 2, !dbg !434
  %128 = icmp eq i16 1, %127, !dbg !435
  br i1 %128, label %129, label %130, !dbg !436

129:                                              ; preds = %126
  store i16 1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !437
  br label %130, !dbg !436

130:                                              ; preds = %129, %126
  br label %131, !dbg !424

131:                                              ; preds = %117, %130
  %132 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !438
  %133 = sub i16 %132, 1, !dbg !439
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit(i16 0, i16 %133), !dbg !440
  %134 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !441
  store i16 %134, i16* %15, align 2, !dbg !318
  %135 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !442
  store i16 %135, i16* %14, align 2, !dbg !316
  %136 = load i16, i16* %15, align 2, !dbg !443
  %137 = load i16, i16* %14, align 2, !dbg !444
  %138 = sub i16 %136, %137, !dbg !445
  store i16 %138, i16* %15, align 2, !dbg !446
  %139 = load i16, i16* %14, align 2, !dbg !447
  %140 = icmp eq i16 0, %139, !dbg !448
  br i1 %140, label %141, label %142, !dbg !449

141:                                              ; preds = %131
  store i16 0, i16* %15, align 2, !dbg !450
  br label %142, !dbg !449

142:                                              ; preds = %141, %131
  %143 = load i16, i16* %29, align 2, !dbg !451
  %144 = icmp eq i16 1, %143, !dbg !452
  br i1 %144, label %145, label %146, !dbg !453

145:                                              ; preds = %142
  store i16 0, i16* %15, align 2, !dbg !454
  br label %146, !dbg !453

146:                                              ; preds = %145, %142
  %147 = load i16, i16* %15, align 2, !dbg !455
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter(i16 0, i16 %147), !dbg !456
  call void @__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction(i16 31767), !dbg !457
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 23), !dbg !458
  %148 = load i16, i16* %37, align 2, !dbg !459
  %149 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval(i16 %148), !dbg !460
  %150 = icmp eq i16 0, %149, !dbg !461
  br i1 %150, label %151, label %155, !dbg !462

151:                                              ; preds = %146
  %152 = load i16, i16* %32, align 2, !dbg !463
  %153 = load i16, i16* %31, align 2, !dbg !464
  %154 = load i16, i16* %30, align 2, !dbg !465
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start(i16 %152, i16 %153, i16 %154), !dbg !466
  br label %178, !dbg !462

155:                                              ; preds = %146
  %156 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !467
  %157 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !467
  %158 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !467
  %159 = load i16, i16* %31, align 2, !dbg !468
  store i16 %159, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !469
  store i16 %156, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !469
  store i16 %157, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !469
  store i16 %158, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !469
  %160 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !470
  %161 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !470
  %162 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !470
  %163 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !470
  %164 = and i16 %162, -193, !dbg !470
  %165 = or i16 %164, 128, !dbg !470
  store volatile i16 %160, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !471
  store volatile i16 %161, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !471
  store volatile i16 %165, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !471
  store volatile i16 %163, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !471
  call void asm sideeffect "nop", ""(), !dbg !471
  call void asm sideeffect "nop", ""(), !dbg !471
  %166 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !472
  %167 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !472
  %168 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !472
  %169 = load i16, i16* %31, align 2, !dbg !473
  store i16 %169, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !474
  store i16 %166, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !474
  store i16 %167, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !474
  store i16 %168, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !474
  %170 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !475
  %171 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !475
  %172 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !475
  %173 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !475
  %174 = and i16 %172, -193, !dbg !475
  %175 = or i16 %174, 128, !dbg !475
  %176 = and i16 %171, -64, !dbg !475
  %177 = or i16 %176, 27, !dbg !475
  store volatile i16 %170, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !476
  store volatile i16 %177, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !476
  store volatile i16 %175, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !476
  store volatile i16 %173, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !476
  call void asm sideeffect "nop", ""(), !dbg !476
  call void asm sideeffect "nop", ""(), !dbg !476
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !477
  br label %178, !dbg !462

178:                                              ; preds = %151, %155
  br label %179, !dbg !415

179:                                              ; preds = %112, %178
  br label %180, !dbg !410

180:                                              ; preds = %108, %179
  ret void, !dbg !350
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit(i16 %0, i16 %1) !dbg !478 {
  %3 = alloca i16, i16 1, align 2, !dbg !480
  %4 = alloca i16, i16 1, align 2, !dbg !482
  %5 = alloca i16, i16 1, align 2, !dbg !483
  %6 = alloca i16, i16 1, align 2, !dbg !484
  %7 = alloca i16, i16 1, align 2, !dbg !485
  %8 = alloca i16, i16 1, align 2, !dbg !486
  store i16 %0, i16* %8, align 2, !dbg !486
  store i16 %1, i16* %7, align 2, !dbg !485
  %9 = load i16, i16* %7, align 2, !dbg !487
  %10 = icmp ult i16 %9, -32768, !dbg !488
  br i1 %10, label %11, label %12, !dbg !489

11:                                               ; preds = %2
  br label %13, !dbg !489

12:                                               ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !489
  br label %13, !dbg !489

13:                                               ; preds = %11, %12
  %14 = load i16, i16* %7, align 2, !dbg !490
  %15 = mul i16 %14, 2, !dbg !491
  store i16 %15, i16* %6, align 2, !dbg !484
  %16 = load i16, i16* %8, align 2, !dbg !492
  %17 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %16, i16 8), !dbg !493
  %18 = sub i16 %17, 1, !dbg !494
  store i16 %18, i16* %5, align 2, !dbg !483
  %19 = load i16, i16* %6, align 2, !dbg !495
  %20 = load i16, i16* %5, align 2, !dbg !496
  %21 = icmp ult i16 %19, %20, !dbg !497
  br i1 %21, label %22, label %23, !dbg !482

22:                                               ; preds = %13
  store i16 0, i16* %4, align 2, !dbg !482
  br label %27, !dbg !482

23:                                               ; preds = %13
  %24 = load i16, i16* %6, align 2, !dbg !498
  %25 = load i16, i16* %5, align 2, !dbg !499
  %26 = sub i16 %24, %25, !dbg !500
  store i16 %26, i16* %4, align 2, !dbg !482
  br label %27, !dbg !482

27:                                               ; preds = %22, %23
  %28 = load i16, i16* %4, align 2, !dbg !482
  store i16 %28, i16* %3, align 2, !dbg !480
  %29 = load i16, i16* %8, align 2, !dbg !501
  %30 = load i16, i16* %3, align 2, !dbg !502
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %29, i16 4, i16 %30), !dbg !503
  ret void, !dbg !482
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter(i16 %0, i16 %1) !dbg !504 {
  %3 = alloca i16, i16 1, align 2, !dbg !505
  %4 = alloca i16, i16 1, align 2, !dbg !507
  store i16 %0, i16* %4, align 2, !dbg !507
  store i16 %1, i16* %3, align 2, !dbg !505
  %5 = load i16, i16* %3, align 2, !dbg !508
  %6 = icmp ult i16 %5, -32768, !dbg !509
  br i1 %6, label %7, label %8, !dbg !510

7:                                                ; preds = %2
  br label %9, !dbg !510

8:                                                ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !510
  br label %9, !dbg !510

9:                                                ; preds = %7, %8
  %10 = load i16, i16* %4, align 2, !dbg !511
  %11 = load i16, i16* %3, align 2, !dbg !512
  %12 = mul i16 %11, 2, !dbg !513
  %13 = add i16 %12, 1, !dbg !514
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %10, i16 8, i16 %13), !dbg !515
  ret void, !dbg !516
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter(i16 %0, i16 %1) !dbg !517 {
  %3 = alloca i16, i16 1, align 2, !dbg !518
  %4 = alloca i16, i16 1, align 2, !dbg !520
  %5 = alloca i1, i16 1, align 1, !dbg !521
  %6 = alloca i16, i16 1, align 2, !dbg !522
  %7 = alloca i16, i16 1, align 2, !dbg !523
  %8 = alloca i16, i16 1, align 2, !dbg !524
  %9 = alloca i16, i16 1, align 2, !dbg !525
  store i16 %0, i16* %9, align 2, !dbg !525
  store i16 %1, i16* %8, align 2, !dbg !524
  %10 = load i16, i16* %8, align 2, !dbg !526
  %11 = icmp ult i16 %10, -32768, !dbg !527
  br i1 %11, label %12, label %13, !dbg !528

12:                                               ; preds = %2
  br label %14, !dbg !528

13:                                               ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !528
  br label %14, !dbg !528

14:                                               ; preds = %12, %13
  %15 = load i16, i16* %9, align 2, !dbg !529
  %16 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %15, i16 8), !dbg !530
  store i16 %16, i16* %7, align 2, !dbg !523
  %17 = load i16, i16* %8, align 2, !dbg !531
  %18 = mul i16 %17, 2, !dbg !532
  store i16 %18, i16* %6, align 2, !dbg !522
  %19 = load i16, i16* %6, align 2, !dbg !533
  %20 = load i16, i16* %7, align 2, !dbg !534
  %21 = icmp ugt i16 %19, %20, !dbg !535
  store i1 %21, i1* %5, align 1, !dbg !521
  %22 = load i16, i16* %9, align 2, !dbg !536
  %23 = load i1, i1* %5, align 1, !dbg !537
  %24 = zext i1 %23 to i16, !dbg !538
  %25 = shl i16 %24, 6, !dbg !539
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %22, i16 14, i16 %25), !dbg !540
  %26 = load i1, i1* %5, align 1, !dbg !541
  br i1 %26, label %27, label %32, !dbg !520

27:                                               ; preds = %14
  %28 = load i16, i16* %6, align 2, !dbg !542
  %29 = load i16, i16* %7, align 2, !dbg !543
  %30 = sub i16 %28, %29, !dbg !544
  %31 = add i16 %30, 1, !dbg !545
  store i16 %31, i16* %4, align 2, !dbg !520
  br label %34, !dbg !520

32:                                               ; preds = %14
  %33 = load i16, i16* %6, align 2, !dbg !546
  store i16 %33, i16* %4, align 2, !dbg !520
  br label %34, !dbg !520

34:                                               ; preds = %27, %32
  %35 = load i16, i16* %4, align 2, !dbg !520
  store i16 %35, i16* %3, align 2, !dbg !518
  %36 = load i16, i16* %9, align 2, !dbg !547
  %37 = load i16, i16* %3, align 2, !dbg !548
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %36, i16 12, i16 %37), !dbg !549
  ret void, !dbg !520
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %0, i16 %1, i16 %2) !dbg !550 {
  %4 = alloca i16, i16 1, align 2, !dbg !552
  %5 = alloca i16, i16 1, align 2, !dbg !554
  %6 = alloca i16, i16 1, align 2, !dbg !555
  store i16 %0, i16* %6, align 2, !dbg !555
  store i16 %1, i16* %5, align 2, !dbg !554
  store i16 %2, i16* %4, align 2, !dbg !552
  %7 = load i16, i16* %6, align 2, !dbg !556
  %8 = getelementptr [6 x i16], [6 x i16]* @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.filters, i16 0, i16 %7, !dbg !557
  %9 = load i16, i16* %8, align 2, !dbg !557
  %10 = load i16, i16* %5, align 2, !dbg !558
  %11 = add i16 %9, %10, !dbg !559
  %12 = lshr i16 %11, 1, !dbg !560
  %13 = load i16, i16* %4, align 2, !dbg !561
  %14 = shl i16 %12, 1, !dbg !562
  %15 = inttoptr i16 %14 to i16*, !dbg !562
  store volatile i16 %13, i16* %15, align 2, !dbg !562
  call void asm sideeffect "nop", ""(), !dbg !562
  call void asm sideeffect "nop", ""(), !dbg !562
  ret void, !dbg !563
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %0, i16 %1) !dbg !564 {
  %3 = alloca i16, i16 1, align 2, !dbg !565
  %4 = alloca i16, i16 1, align 2, !dbg !567
  store i16 %0, i16* %4, align 2, !dbg !567
  store i16 %1, i16* %3, align 2, !dbg !565
  %5 = load i16, i16* %4, align 2, !dbg !568
  %6 = getelementptr [6 x i16], [6 x i16]* @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.filters, i16 0, i16 %5, !dbg !569
  %7 = load i16, i16* %6, align 2, !dbg !569
  %8 = load i16, i16* %3, align 2, !dbg !570
  %9 = add i16 %7, %8, !dbg !571
  %10 = lshr i16 %9, 1, !dbg !572
  %11 = shl i16 %10, 1, !dbg !573
  %12 = inttoptr i16 %11 to i16*, !dbg !573
  call void asm sideeffect "nop", ""(), !dbg !573
  call void asm sideeffect "nop", ""(), !dbg !573
  %13 = load volatile i16, i16* %12, align 2, !dbg !573
  ret i16 %13, !dbg !574
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 %0) !dbg !575 {
  %2 = alloca i16, i16 1, align 2, !dbg !577
  %3 = alloca i16, i16 1, align 2, !dbg !579
  %4 = alloca i16, i16 1, align 2, !dbg !580
  %5 = alloca i16, i16 1, align 2, !dbg !581
  store i16 %0, i16* %5, align 2, !dbg !581
  %6 = load i16, i16* %5, align 2, !dbg !582
  store i16 %6, i16* %4, align 2, !dbg !580
  %7 = load i16, i16* %4, align 2, !dbg !583
  %8 = add i16 %7, 31744, !dbg !584
  store i16 %8, i16* %3, align 2, !dbg !579
  %9 = load i16, i16* %3, align 2, !dbg !585
  %10 = shl i16 %9, 1, !dbg !586
  %11 = inttoptr i16 %10 to i16*, !dbg !586
  call void asm sideeffect "nop", ""(), !dbg !586
  call void asm sideeffect "nop", ""(), !dbg !586
  %12 = load volatile i16, i16* %11, align 2, !dbg !586
  store i16 %12, i16* %2, align 2, !dbg !577
  %13 = load i16, i16* %3, align 2, !dbg !587
  %14 = load i16, i16* %2, align 2, !dbg !588
  %15 = and i16 %14, 32767, !dbg !589
  %16 = shl i16 %13, 1, !dbg !590
  %17 = inttoptr i16 %16 to i16*, !dbg !590
  store volatile i16 %15, i16* %17, align 2, !dbg !590
  call void asm sideeffect "nop", ""(), !dbg !590
  call void asm sideeffect "nop", ""(), !dbg !590
  ret void, !dbg !591
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord() !dbg !592 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 2), !dbg !594
  %2 = sub i16 %1, 4, !dbg !596
  ret i16 %2, !dbg !597
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord() !dbg !598 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 0), !dbg !599
  %2 = sub i16 %1, 1, !dbg !601
  ret i16 %2, !dbg !602
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 %0) !dbg !603 {
  %2 = alloca i16, i16 1, align 2, !dbg !605
  %3 = alloca i16, i16 1, align 2, !dbg !607
  store i16 %0, i16* %3, align 2, !dbg !607
  %4 = load i16, i16* %3, align 2, !dbg !608
  %5 = lshr i16 %4, 1, !dbg !609
  %6 = add i16 %5, 31813, !dbg !610
  %7 = shl i16 %6, 1, !dbg !611
  %8 = inttoptr i16 %7 to i16*, !dbg !611
  call void asm sideeffect "nop", ""(), !dbg !611
  call void asm sideeffect "nop", ""(), !dbg !611
  %9 = load volatile i16, i16* %8, align 2, !dbg !611
  store i16 %9, i16* %2, align 2, !dbg !605
  %10 = load i16, i16* %2, align 2, !dbg !612
  %11 = and i16 %10, 2047, !dbg !613
  ret i16 %11, !dbg !614
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord() !dbg !615 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord(), !dbg !617
  ret i16 %1, !dbg !619
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.get_y_coord() !dbg !620 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord(), !dbg !621
  ret i16 %1, !dbg !623
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval(i16 %0) !dbg !624 {
  %2 = alloca i16, i16 1, align 2, !dbg !625
  store i16 %0, i16* %2, align 2, !dbg !625
  %3 = load i16, i16* %2, align 2, !dbg !627
  %4 = icmp ult i16 %3, 24, !dbg !628
  br i1 %4, label %5, label %7, !dbg !629

5:                                                ; preds = %10, %11, %1
  %6 = phi i16 [ 0, %10 ], [ 0, %11 ], [ 1, %1 ]
  br label %12, !dbg !629

7:                                                ; preds = %1
  %8 = load i16, i16* %2, align 2, !dbg !630
  %9 = icmp eq i16 31, %8, !dbg !631
  br i1 %9, label %10, label %11, !dbg !632

10:                                               ; preds = %7
  br label %5, !dbg !632

11:                                               ; preds = %7
  call void asm sideeffect "hcf", ""(), !dbg !632
  br label %5, !dbg !632

12:                                               ; preds = %5
  %13 = phi i16 [ %6, %5 ]
  br label %14, !dbg !629

14:                                               ; preds = %12
  ret i16 %13, !dbg !629
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7) !dbg !633 {
  %9 = alloca i16, i16 1, align 2, !dbg !634
  %10 = alloca i16, i16 1, align 2, !dbg !636
  %11 = alloca i16, i16 1, align 2, !dbg !637
  %12 = alloca i16, i16 1, align 2, !dbg !638
  %13 = alloca i16, i16 1, align 2, !dbg !639
  %14 = alloca i16, i16 1, align 2, !dbg !640
  %15 = alloca i16, i16 1, align 2, !dbg !641
  %16 = alloca i16, i16 1, align 2, !dbg !642
  %17 = alloca i16, i16 1, align 2, !dbg !643
  store i16 %0, i16* %17, align 2, !dbg !643
  store i16 %1, i16* %16, align 2, !dbg !642
  store i16 %2, i16* %15, align 2, !dbg !641
  store i16 %3, i16* %14, align 2, !dbg !640
  store i16 %4, i16* %13, align 2, !dbg !639
  store i16 %5, i16* %12, align 2, !dbg !638
  store i16 %6, i16* %11, align 2, !dbg !637
  store i16 %7, i16* %10, align 2, !dbg !636
  %18 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !644
  store i16 %18, i16* %9, align 2, !dbg !634
  %19 = load i16, i16* %11, align 2, !dbg !645
  store i16 %19, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_c, align 2, !dbg !646
  %20 = load i16, i16* %10, align 2, !dbg !647
  store i16 %20, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_is_half, align 2, !dbg !648
  %21 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_c, align 2, !dbg !649
  %22 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval(i16 %21), !dbg !650
  store i16 %22, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !651
  store i16 0, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !652
  %23 = load i16, i16* %16, align 2, !dbg !653
  store i16 %23, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !654
  %24 = load i16, i16* %15, align 2, !dbg !655
  store i16 %24, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !656
  %25 = load i16, i16* %15, align 2, !dbg !657
  %26 = load i16, i16* %13, align 2, !dbg !658
  %27 = add i16 %25, %26, !dbg !659
  %28 = sub i16 %27, 1, !dbg !660
  store i16 %28, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_last, align 2, !dbg !661
  %29 = load i16, i16* %9, align 2, !dbg !662
  %30 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_last, align 2, !dbg !663
  %31 = icmp eq i16 %29, %30, !dbg !664
  br i1 %31, label %32, label %37, !dbg !665

32:                                               ; preds = %8
  %33 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !666
  %34 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !666
  %35 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !666
  store i16 %33, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !667
  store i16 lshr (i16 ptrtoint ([1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.ctrl_1 to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !667
  store i16 %34, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !667
  store i16 %35, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !667
  %36 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.ctrl_1, i16 0, i1 false), align 4, !dbg !668
  store i32 %36, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i1 false), align 4, !dbg !669
  br label %42, !dbg !665

37:                                               ; preds = %8
  %38 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !670
  %39 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !670
  %40 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !670
  store i16 %38, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !671
  store i16 lshr (i16 ptrtoint ([1 x i32]* @"$$csl_base_address$$0$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11" to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !671
  store i16 %39, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !671
  store i16 %40, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !671
  %41 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @"$$csl_base_address$$0$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11", i16 0, i1 false), align 4, !dbg !672
  store i32 %41, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i1 false), align 4, !dbg !673
  br label %42, !dbg !665

42:                                               ; preds = %32, %37
  store i32 165646921, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i2 1), align 4, !dbg !674
  %43 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !675
  %44 = icmp eq i16 0, %43, !dbg !676
  br i1 %44, label %45, label %56, !dbg !677

45:                                               ; preds = %42
  %46 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !678
  %47 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !678
  %48 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !678
  %49 = load i16, i16* %17, align 2, !dbg !679
  %50 = call i16* @.get_tensor_ptr(i16 %49), !dbg !680
  %51 = ptrtoint i16* %50 to i16, !dbg !681
  %52 = lshr i16 %51, 1, !dbg !681
  store i16 %46, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !682
  store i16 %52, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !682
  store i16 %47, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !682
  store i16 %48, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !682
  %53 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !683
  %54 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !683
  %55 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !683
  store i16 1, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !684
  store i16 %53, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !684
  store i16 %54, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !684
  store i16 %55, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !684
  call void @llvm.sdr.actvt.r(i16 21), !dbg !685
  br label %63, !dbg !677

56:                                               ; preds = %42
  %57 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !686
  %58 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !686
  %59 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !686
  store i16 %57, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !687
  store i16 lshr (i16 ptrtoint ([1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.data_buf to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !687
  store i16 %58, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !687
  store i16 %59, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !687
  %60 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !688
  %61 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !688
  %62 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !688
  store i16 1, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !689
  store i16 %60, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !689
  store i16 %61, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !689
  store i16 %62, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !689
  call void @llvm.sdr.ublk.r(i16 0), !dbg !690
  br label %63, !dbg !677

63:                                               ; preds = %45, %56
  ret void, !dbg !665
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x(i32 %0) #8 !dbg !691 {
  %2 = alloca i32, i16 1, align 4, !dbg !692
  store i32 %0, i32* %2, align 4, !dbg !692
  call void @llvm.sdr.blk.r(i16 0), !dbg !694
  %3 = load i32, i32* %2, align 4, !dbg !695
  store i32 %3, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.data_buf, i16 0, i1 false), align 4, !dbg !696
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !697
  %4 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !698
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !698
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !698
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !698
  store volatile i16 %4, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !699
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !699
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !699
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !699
  call void asm sideeffect "nop", ""(), !dbg !699
  call void asm sideeffect "nop", ""(), !dbg !699
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !700
  %8 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !701
  %9 = add i16 %8, 1, !dbg !702
  store i16 %9, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !703
  ret void, !dbg !704
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_send_data() #9 !dbg !705 {
  %1 = alloca i16, i16 1, align 2, !dbg !706
  %2 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !708
  %3 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !709
  %4 = icmp ult i16 %2, %3, !dbg !710
  br i1 %4, label %5, label %27, !dbg !711

5:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !712
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !713
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !713
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !713
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !713
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !714
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !714
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !714
  store volatile i16 %9, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !714
  call void asm sideeffect "nop", ""(), !dbg !714
  call void asm sideeffect "nop", ""(), !dbg !714
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_is_half, align 2, !dbg !715
  %11 = icmp ult i16 0, %10, !dbg !716
  br i1 %11, label %12, label %18, !dbg !717

12:                                               ; preds = %5
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !718
  %13 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !719
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !719
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !719
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !719
  %17 = add i16 %14, 1, !dbg !720
  store i16 %13, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !721
  store i16 %17, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !721
  store i16 %15, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !721
  store i16 %16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !721
  br label %24, !dbg !717

18:                                               ; preds = %5
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !722
  %19 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !723
  %20 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !723
  %21 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !723
  %22 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !723
  %23 = add i16 %20, 2, !dbg !724
  store i16 %19, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !725
  store i16 %23, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !725
  store i16 %21, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !725
  store i16 %22, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !725
  br label %24, !dbg !717

24:                                               ; preds = %12, %18
  %25 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !726
  %26 = add i16 %25, 1, !dbg !727
  store i16 %26, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !728
  br label %34, !dbg !711

27:                                               ; preds = %0
  %28 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !729
  store i16 %28, i16* %1, align 2, !dbg !706
  %29 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !730
  %30 = load i16, i16* %1, align 2, !dbg !731
  %31 = icmp eq i16 %29, %30, !dbg !732
  br i1 %31, label %32, label %33, !dbg !733

32:                                               ; preds = %27
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !734
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__1 to i8*)), !dbg !735
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !736
  br label %33, !dbg !733

33:                                               ; preds = %32, %27
  br label %34, !dbg !711

34:                                               ; preds = %24, %33
  ret void, !dbg !711
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl() #10 !dbg !737 {
  %1 = alloca i16, i16 1, align 2, !dbg !738
  %2 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !740
  %3 = icmp eq i16 0, %2, !dbg !741
  br i1 %3, label %4, label %9, !dbg !742

4:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__2 to i8*)), !dbg !743
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !744
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !744
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !744
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !744
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !745
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !745
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !745
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !745
  call void asm sideeffect "nop", ""(), !dbg !745
  call void asm sideeffect "nop", ""(), !dbg !745
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !746
  br label %31, !dbg !742

9:                                                ; preds = %0
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !747
  %11 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !748
  %12 = icmp ult i16 %10, %11, !dbg !749
  br i1 %12, label %13, label %18, !dbg !750

13:                                               ; preds = %9
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__3 to i8*)), !dbg !751
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !752
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !752
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !752
  %17 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !752
  store volatile i16 %14, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !753
  store volatile i16 %15, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !753
  store volatile i16 %16, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !753
  store volatile i16 %17, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !753
  call void asm sideeffect "nop", ""(), !dbg !753
  call void asm sideeffect "nop", ""(), !dbg !753
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !754
  br label %30, !dbg !750

18:                                               ; preds = %9
  %19 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !755
  store i16 %19, i16* %1, align 2, !dbg !738
  %20 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !756
  %21 = load i16, i16* %1, align 2, !dbg !757
  %22 = icmp eq i16 %20, %21, !dbg !758
  br i1 %22, label %23, label %24, !dbg !759

23:                                               ; preds = %18
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__4 to i8*)), !dbg !760
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__5 to i8*)), !dbg !761
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !762
  br label %29, !dbg !759

24:                                               ; preds = %18
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !763
  %25 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !764
  %26 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !764
  %27 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !764
  %28 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !764
  store volatile i16 %25, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !765
  store volatile i16 %26, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !765
  store volatile i16 %27, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !765
  store volatile i16 %28, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !765
  call void asm sideeffect "nop", ""(), !dbg !765
  call void asm sideeffect "nop", ""(), !dbg !765
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !766
  br label %29, !dbg !759

29:                                               ; preds = %23, %24
  br label %30, !dbg !750

30:                                               ; preds = %13, %29
  br label %31, !dbg !742

31:                                               ; preds = %4, %30
  ret void, !dbg !742
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.d2h_configure(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7) !dbg !767 {
  %9 = alloca i1, i16 1, align 1, !dbg !768
  %10 = alloca i1, i16 1, align 1, !dbg !770
  %11 = alloca i1, i16 1, align 1, !dbg !771
  %12 = alloca i16, i16 1, align 2, !dbg !772
  %13 = alloca i16, i16 1, align 2, !dbg !773
  %14 = alloca i16, i16 1, align 2, !dbg !774
  %15 = alloca i16, i16 1, align 2, !dbg !775
  %16 = alloca i16, i16 1, align 2, !dbg !776
  %17 = alloca i16, i16 1, align 2, !dbg !777
  %18 = alloca i16, i16 1, align 2, !dbg !778
  %19 = alloca i16, i16 1, align 2, !dbg !779
  %20 = alloca i16, i16 1, align 2, !dbg !780
  %21 = alloca i16, i16 1, align 2, !dbg !781
  %22 = alloca i16, i16 1, align 2, !dbg !782
  %23 = alloca i16, i16 1, align 2, !dbg !783
  %24 = alloca i16, i16 1, align 2, !dbg !784
  %25 = alloca i16, i16 1, align 2, !dbg !785
  store i16 %0, i16* %25, align 2, !dbg !785
  store i16 %1, i16* %24, align 2, !dbg !784
  store i16 %2, i16* %23, align 2, !dbg !783
  store i16 %3, i16* %22, align 2, !dbg !782
  store i16 %4, i16* %21, align 2, !dbg !781
  store i16 %5, i16* %20, align 2, !dbg !780
  store i16 %6, i16* %19, align 2, !dbg !779
  store i16 %7, i16* %18, align 2, !dbg !778
  %26 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !786
  store i16 %26, i16* %17, align 2, !dbg !777
  %27 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_y_coord(), !dbg !787
  store i16 %27, i16* %16, align 2, !dbg !776
  %28 = load i16, i16* %24, align 2, !dbg !788
  store i16 %28, i16* %15, align 2, !dbg !775
  %29 = load i16, i16* %24, align 2, !dbg !789
  %30 = load i16, i16* %22, align 2, !dbg !790
  %31 = add i16 %29, %30, !dbg !791
  %32 = sub i16 %31, 1, !dbg !792
  store i16 %32, i16* %14, align 2, !dbg !774
  %33 = load i16, i16* %23, align 2, !dbg !793
  store i16 %33, i16* %13, align 2, !dbg !773
  %34 = load i16, i16* %23, align 2, !dbg !794
  %35 = load i16, i16* %21, align 2, !dbg !795
  %36 = add i16 %34, %35, !dbg !796
  %37 = sub i16 %36, 1, !dbg !797
  store i16 %37, i16* %12, align 2, !dbg !772
  store i1 false, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !798
  %38 = load i16, i16* %17, align 2, !dbg !799
  %39 = load i16, i16* %15, align 2, !dbg !800
  %40 = icmp sge i16 %38, %39, !dbg !801
  br i1 %40, label %41, label %45, !dbg !771

41:                                               ; preds = %8
  %42 = load i16, i16* %16, align 2, !dbg !802
  %43 = load i16, i16* %12, align 2, !dbg !803
  %44 = icmp sle i16 %42, %43, !dbg !804
  store i1 %44, i1* %11, align 1, !dbg !771
  br label %46, !dbg !771

45:                                               ; preds = %8
  store i1 false, i1* %11, align 1, !dbg !771
  br label %46, !dbg !771

46:                                               ; preds = %41, %45
  %47 = load i1, i1* %11, align 1, !dbg !771
  br i1 %47, label %48, label %52, !dbg !770

48:                                               ; preds = %46
  %49 = load i16, i16* %16, align 2, !dbg !805
  %50 = load i16, i16* %13, align 2, !dbg !806
  %51 = icmp sge i16 %49, %50, !dbg !807
  store i1 %51, i1* %10, align 1, !dbg !770
  br label %53, !dbg !770

52:                                               ; preds = %46
  store i1 false, i1* %10, align 1, !dbg !770
  br label %53, !dbg !770

53:                                               ; preds = %48, %52
  %54 = load i1, i1* %10, align 1, !dbg !770
  br i1 %54, label %55, label %56, !dbg !808

55:                                               ; preds = %53
  store i1 true, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !809
  br label %56, !dbg !808

56:                                               ; preds = %55, %53
  store i1 false, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !810
  %57 = load i16, i16* %17, align 2, !dbg !811
  %58 = load i16, i16* %14, align 2, !dbg !812
  %59 = icmp sle i16 %57, %58, !dbg !813
  br i1 %59, label %60, label %62, !dbg !768

60:                                               ; preds = %56
  %61 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !814
  store i1 %61, i1* %9, align 1, !dbg !768
  br label %63, !dbg !768

62:                                               ; preds = %56
  store i1 false, i1* %9, align 1, !dbg !768
  br label %63, !dbg !768

63:                                               ; preds = %60, %62
  %64 = load i1, i1* %9, align 1, !dbg !768
  br i1 %64, label %65, label %66, !dbg !815

65:                                               ; preds = %63
  store i1 true, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !816
  br label %66, !dbg !815

66:                                               ; preds = %65, %63
  %67 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !817
  br i1 %67, label %68, label %86, !dbg !818

68:                                               ; preds = %66
  call void @__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position(i16 31959), !dbg !819
  %69 = load i16, i16* %15, align 2, !dbg !820
  %70 = load i16, i16* %17, align 2, !dbg !821
  %71 = icmp eq i16 %69, %70, !dbg !822
  br i1 %71, label %72, label %73, !dbg !823

72:                                               ; preds = %68
  call void @__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 31765), !dbg !824
  br label %74, !dbg !823

73:                                               ; preds = %68
  call void @__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 31765), !dbg !825
  br label %74, !dbg !823

74:                                               ; preds = %72, %73
  call void @sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit(i16 21), !dbg !826
  %75 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !827
  br i1 %75, label %76, label %85, !dbg !828

76:                                               ; preds = %74
  %77 = load i16, i16* %20, align 2, !dbg !829
  %78 = load i16, i16* %19, align 2, !dbg !830
  %79 = load i16, i16* %24, align 2, !dbg !831
  %80 = load i16, i16* %23, align 2, !dbg !832
  %81 = load i16, i16* %22, align 2, !dbg !833
  %82 = load i16, i16* %21, align 2, !dbg !834
  %83 = load i16, i16* %25, align 2, !dbg !835
  %84 = load i16, i16* %18, align 2, !dbg !836
  call void @sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start(i16 %77, i16 %78, i16 %79, i16 %80, i16 %81, i16 %82, i16 %83, i16 %84), !dbg !837
  br label %85, !dbg !828

85:                                               ; preds = %76, %74
  br label %87, !dbg !818

86:                                               ; preds = %66
  call void @llvm.sdr.actvt.r(i16 28), !dbg !838
  br label %87, !dbg !818

87:                                               ; preds = %85, %86
  ret void, !dbg !771
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit(i16 %0) !dbg !839 {
  %2 = alloca i16, i16 1, align 2, !dbg !840
  %3 = alloca i16, i16 1, align 2, !dbg !842
  %4 = alloca i16, i16 1, align 2, !dbg !843
  %5 = alloca i16, i16 1, align 2, !dbg !844
  store i16 %0, i16* %5, align 2, !dbg !844
  %6 = load i16, i16* %5, align 2, !dbg !845
  store i16 %6, i16* %4, align 2, !dbg !843
  %7 = load i16, i16* %4, align 2, !dbg !846
  %8 = add i16 %7, 31744, !dbg !847
  store i16 %8, i16* %3, align 2, !dbg !842
  %9 = load i16, i16* %3, align 2, !dbg !848
  %10 = shl i16 %9, 1, !dbg !849
  %11 = inttoptr i16 %10 to i16*, !dbg !849
  call void asm sideeffect "nop", ""(), !dbg !849
  call void asm sideeffect "nop", ""(), !dbg !849
  %12 = load volatile i16, i16* %11, align 2, !dbg !849
  store i16 %12, i16* %2, align 2, !dbg !840
  %13 = load i16, i16* %3, align 2, !dbg !850
  %14 = load i16, i16* %2, align 2, !dbg !851
  %15 = and i16 %14, 32767, !dbg !852
  %16 = shl i16 %13, 1, !dbg !853
  %17 = inttoptr i16 %16 to i16*, !dbg !853
  store volatile i16 %15, i16* %17, align 2, !dbg !853
  call void asm sideeffect "nop", ""(), !dbg !853
  call void asm sideeffect "nop", ""(), !dbg !853
  ret void, !dbg !854
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord() !dbg !855 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 2), !dbg !856
  %2 = sub i16 %1, 4, !dbg !858
  ret i16 %2, !dbg !859
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord() !dbg !860 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 0), !dbg !861
  %2 = sub i16 %1, 1, !dbg !863
  ret i16 %2, !dbg !864
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 %0) !dbg !865 {
  %2 = alloca i16, i16 1, align 2, !dbg !866
  %3 = alloca i16, i16 1, align 2, !dbg !868
  store i16 %0, i16* %3, align 2, !dbg !868
  %4 = load i16, i16* %3, align 2, !dbg !869
  %5 = lshr i16 %4, 1, !dbg !870
  %6 = add i16 %5, 31813, !dbg !871
  %7 = shl i16 %6, 1, !dbg !872
  %8 = inttoptr i16 %7 to i16*, !dbg !872
  call void asm sideeffect "nop", ""(), !dbg !872
  call void asm sideeffect "nop", ""(), !dbg !872
  %9 = load volatile i16, i16* %8, align 2, !dbg !872
  store i16 %9, i16* %2, align 2, !dbg !866
  %10 = load i16, i16* %2, align 2, !dbg !873
  %11 = and i16 %10, 2047, !dbg !874
  ret i16 %11, !dbg !875
}

define internal i16 @sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr(i16 %0) !dbg !876 {
  %2 = alloca i16, i16 1, align 2, !dbg !878
  store i16 %0, i16* %2, align 2, !dbg !878
  %3 = load i16, i16* %2, align 2, !dbg !880
  %4 = mul i16 %3, 2, !dbg !881
  %5 = add i16 %4, 31680, !dbg !882
  ret i16 %5, !dbg !883
}

define internal void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 %0, i16 %1, i1 %2) !dbg !884 {
  %4 = alloca i16, i16 1, align 2, !dbg !885
  %5 = alloca i16, i16 1, align 2, !dbg !887
  %6 = alloca i1, i16 1, align 1, !dbg !888
  %7 = alloca i16, i16 1, align 2, !dbg !889
  %8 = alloca i16, i16 1, align 2, !dbg !890
  store i16 %0, i16* %8, align 2, !dbg !890
  store i16 %1, i16* %7, align 2, !dbg !889
  store i1 %2, i1* %6, align 1, !dbg !888
  %9 = load i16, i16* %8, align 2, !dbg !891
  %10 = call i16 @sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr(i16 %9), !dbg !892
  store i16 %10, i16* %5, align 2, !dbg !887
  %11 = load i16, i16* %5, align 2, !dbg !893
  %12 = shl i16 %11, 1, !dbg !894
  %13 = inttoptr i16 %12 to i16*, !dbg !894
  call void asm sideeffect "nop", ""(), !dbg !894
  call void asm sideeffect "nop", ""(), !dbg !894
  call void asm sideeffect "nop", ""(), !dbg !894
  call void asm sideeffect "nop", ""(), !dbg !894
  %14 = load volatile i16, i16* %13, align 2, !dbg !894
  store i16 %14, i16* %4, align 2, !dbg !885
  %15 = load i1, i1* %6, align 1, !dbg !895
  br i1 %15, label %16, label %19, !dbg !896

16:                                               ; preds = %3
  %17 = load i16, i16* %4, align 2, !dbg !897
  %18 = or i16 %17, 2048, !dbg !898
  store i16 %18, i16* %4, align 2, !dbg !899
  br label %22, !dbg !896

19:                                               ; preds = %3
  %20 = load i16, i16* %4, align 2, !dbg !900
  %21 = and i16 %20, -2049, !dbg !901
  store i16 %21, i16* %4, align 2, !dbg !902
  br label %22, !dbg !896

22:                                               ; preds = %16, %19
  %23 = load i16, i16* %4, align 2, !dbg !903
  %24 = and i16 %23, -32, !dbg !904
  store i16 %24, i16* %4, align 2, !dbg !905
  %25 = load i16, i16* %4, align 2, !dbg !906
  %26 = load i16, i16* %7, align 2, !dbg !907
  %27 = add i16 %25, %26, !dbg !908
  store i16 %27, i16* %4, align 2, !dbg !909
  %28 = load i16, i16* %5, align 2, !dbg !910
  %29 = load i16, i16* %4, align 2, !dbg !911
  %30 = shl i16 %28, 1, !dbg !912
  %31 = inttoptr i16 %30 to i16*, !dbg !912
  store volatile i16 %29, i16* %31, align 2, !dbg !912
  call void asm sideeffect "nop", ""(), !dbg !912
  call void asm sideeffect "nop", ""(), !dbg !912
  call void asm sideeffect "nop", ""(), !dbg !912
  call void asm sideeffect "nop", ""(), !dbg !912
  ret void, !dbg !896
}

define internal i16 @sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr(i16 %0) !dbg !913 {
  %2 = alloca i16, i16 1, align 2, !dbg !915
  store i16 %0, i16* %2, align 2, !dbg !915
  %3 = load i16, i16* %2, align 2, !dbg !917
  %4 = add i16 %3, 31616, !dbg !918
  ret i16 %4, !dbg !919
}

define internal void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 %0, i16 %1) !dbg !920 {
  %3 = alloca i16, i16 1, align 2, !dbg !921
  %4 = alloca i16, i16 1, align 2, !dbg !923
  %5 = alloca i16, i16 1, align 2, !dbg !924
  %6 = alloca i16, i16 1, align 2, !dbg !925
  store i16 %0, i16* %6, align 2, !dbg !925
  store i16 %1, i16* %5, align 2, !dbg !924
  %7 = load i16, i16* %6, align 2, !dbg !926
  %8 = call i16 @sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr(i16 %7), !dbg !927
  store i16 %8, i16* %4, align 2, !dbg !923
  %9 = load i16, i16* %4, align 2, !dbg !928
  %10 = shl i16 %9, 1, !dbg !929
  %11 = inttoptr i16 %10 to i16*, !dbg !929
  call void asm sideeffect "nop", ""(), !dbg !929
  call void asm sideeffect "nop", ""(), !dbg !929
  call void asm sideeffect "nop", ""(), !dbg !929
  call void asm sideeffect "nop", ""(), !dbg !929
  %12 = load volatile i16, i16* %11, align 2, !dbg !929
  store i16 %12, i16* %3, align 2, !dbg !921
  %13 = load i16, i16* %3, align 2, !dbg !930
  %14 = and i16 %13, -497, !dbg !931
  store i16 %14, i16* %3, align 2, !dbg !932
  %15 = load i16, i16* %3, align 2, !dbg !933
  %16 = load i16, i16* %5, align 2, !dbg !934
  %17 = add i16 %15, %16, !dbg !935
  %18 = shl i16 %17, 4, !dbg !936
  store i16 %18, i16* %3, align 2, !dbg !937
  %19 = load i16, i16* %4, align 2, !dbg !938
  %20 = load i16, i16* %3, align 2, !dbg !939
  %21 = shl i16 %19, 1, !dbg !940
  %22 = inttoptr i16 %21 to i16*, !dbg !940
  store volatile i16 %20, i16* %22, align 2, !dbg !940
  call void asm sideeffect "nop", ""(), !dbg !940
  call void asm sideeffect "nop", ""(), !dbg !940
  call void asm sideeffect "nop", ""(), !dbg !940
  call void asm sideeffect "nop", ""(), !dbg !940
  ret void, !dbg !941
}

define internal i16* @.get_tensor_ptr(i16 %0) !dbg !942 {
  %2 = alloca i16, i16 1, align 2, !dbg !943
  store i16 %0, i16* %2, align 2, !dbg !943
  %3 = load i16, i16* %2, align 2, !dbg !943
  %4 = zext i16 %3 to i32, !dbg !943
  switch i32 %4, label %5 [
    i32 1, label %9
    i32 2, label %11
    i32 3, label %13
    i32 4, label %15
    i32 5, label %17
  ], !dbg !943

5:                                                ; preds = %1
  br i1 false, label %6, label %7, !dbg !943

6:                                                ; preds = %5
  br label %8, !dbg !943

7:                                                ; preds = %5
  call void asm sideeffect "hcf", ""(), !dbg !943
  br label %8, !dbg !943

8:                                                ; preds = %6, %7
  br label %19, !dbg !943

9:                                                ; preds = %1
  %10 = load i16*, i16** @p_a, align 8, !dbg !943
  br label %19, !dbg !943

11:                                               ; preds = %1
  %12 = load i16*, i16** @p_b, align 8, !dbg !943
  br label %19, !dbg !943

13:                                               ; preds = %1
  %14 = load i16*, i16** @p_c, align 8, !dbg !943
  br label %19, !dbg !943

15:                                               ; preds = %1
  %16 = load i16*, i16** @p_idx, align 8, !dbg !943
  br label %19, !dbg !943

17:                                               ; preds = %1
  %18 = load i16*, i16** @p_k, align 8, !dbg !943
  br label %19, !dbg !943

19:                                               ; preds = %8, %9, %11, %13, %15, %17
  %20 = phi i16 [ -2, %17 ], [ -2, %15 ], [ -2, %13 ], [ -2, %11 ], [ -2, %9 ], [ 0, %8 ]
  %21 = phi i16* [ %18, %17 ], [ %16, %15 ], [ %14, %13 ], [ %12, %11 ], [ %10, %9 ], [ undef, %8 ]
  br label %22, !dbg !943

22:                                               ; preds = %19
  %23 = icmp ne i16 %20, 0, !dbg !943
  br i1 %23, label %24, label %25, !dbg !943

24:                                               ; preds = %22
  br label %27, !dbg !943

25:                                               ; preds = %22
  %26 = load i16*, i16** @p_k, align 8, !dbg !943
  br label %27, !dbg !943

27:                                               ; preds = %24, %25
  %28 = phi i16* [ %26, %25 ], [ %21, %24 ]
  br label %29, !dbg !943

29:                                               ; preds = %27
  ret i16* %28, !dbg !943
}

define internal void @__generic0sys_mod.sys_mod.tile_config.queue_flush.exit() !dbg !945 {
  store volatile i16 1, i16* inttoptr (i16 -2268 to i16*), align 2, !dbg !947
  call void asm sideeffect "nop", ""(), !dbg !947
  call void asm sideeffect "nop", ""(), !dbg !947
  ret void, !dbg !949
}

define internal void @__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position(i16 %0) !dbg !950 {
  %2 = alloca i16, i16 1, align 2, !dbg !952
  %3 = alloca i16, i16 1, align 2, !dbg !954
  %4 = alloca i16, i16 1, align 2, !dbg !955
  store i16 %0, i16* %4, align 2, !dbg !955
  %5 = load i16, i16* %4, align 2, !dbg !956
  store i16 %5, i16* %3, align 2, !dbg !954
  %6 = load i16, i16* %3, align 2, !dbg !957
  %7 = shl i16 %6, 1, !dbg !958
  %8 = inttoptr i16 %7 to i16*, !dbg !958
  call void asm sideeffect "nop", ""(), !dbg !958
  call void asm sideeffect "nop", ""(), !dbg !958
  call void asm sideeffect "nop", ""(), !dbg !958
  call void asm sideeffect "nop", ""(), !dbg !958
  %9 = load volatile i16, i16* %8, align 2, !dbg !958
  store i16 %9, i16* %2, align 2, !dbg !952
  %10 = load i16, i16* %2, align 2, !dbg !959
  %11 = and i16 %10, -16, !dbg !960
  store i16 %11, i16* %2, align 2, !dbg !960
  %12 = load i16, i16* %3, align 2, !dbg !961
  %13 = load i16, i16* %2, align 2, !dbg !962
  %14 = shl i16 %12, 1, !dbg !963
  %15 = inttoptr i16 %14 to i16*, !dbg !963
  store volatile i16 %13, i16* %15, align 2, !dbg !963
  call void asm sideeffect "nop", ""(), !dbg !963
  call void asm sideeffect "nop", ""(), !dbg !963
  call void asm sideeffect "nop", ""(), !dbg !963
  call void asm sideeffect "nop", ""(), !dbg !963
  ret void, !dbg !964
}

define internal void @__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 %0) !dbg !965 {
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
  %9 = load volatile i16, i16* %8, align 2, !dbg !973
  store i16 %9, i16* %2, align 2, !dbg !967
  %10 = load i16, i16* %2, align 2, !dbg !974
  %11 = and i16 %10, -256, !dbg !975
  store i16 %11, i16* %2, align 2, !dbg !976
  %12 = load i16, i16* %2, align 2, !dbg !977
  %13 = load i16, i16* %2, align 2, !dbg !978
  %14 = call i16 @__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %13), !dbg !979
  %15 = or i16 %12, %14, !dbg !980
  store i16 %15, i16* %2, align 2, !dbg !980
  %16 = load i16, i16* %2, align 2, !dbg !981
  %17 = load i16, i16* %2, align 2, !dbg !982
  %18 = call i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %17), !dbg !983
  %19 = or i16 %16, %18, !dbg !984
  store i16 %19, i16* %2, align 2, !dbg !984
  %20 = load i16, i16* %3, align 2, !dbg !985
  %21 = load i16, i16* %2, align 2, !dbg !986
  %22 = shl i16 %20, 1, !dbg !987
  %23 = inttoptr i16 %22 to i16*, !dbg !987
  store volatile i16 %21, i16* %23, align 2, !dbg !987
  call void asm sideeffect "nop", ""(), !dbg !987
  call void asm sideeffect "nop", ""(), !dbg !987
  ret void, !dbg !988
}

define internal void @__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 %0) !dbg !989 {
  %2 = alloca i16, i16 1, align 2, !dbg !990
  %3 = alloca i16, i16 1, align 2, !dbg !992
  %4 = alloca i16, i16 1, align 2, !dbg !993
  store i16 %0, i16* %4, align 2, !dbg !993
  %5 = load i16, i16* %4, align 2, !dbg !994
  store i16 %5, i16* %3, align 2, !dbg !992
  %6 = load i16, i16* %3, align 2, !dbg !995
  %7 = shl i16 %6, 1, !dbg !996
  %8 = inttoptr i16 %7 to i16*, !dbg !996
  call void asm sideeffect "nop", ""(), !dbg !996
  call void asm sideeffect "nop", ""(), !dbg !996
  %9 = load volatile i16, i16* %8, align 2, !dbg !996
  store i16 %9, i16* %2, align 2, !dbg !990
  %10 = load i16, i16* %2, align 2, !dbg !997
  %11 = and i16 %10, -256, !dbg !998
  store i16 %11, i16* %2, align 2, !dbg !999
  %12 = load i16, i16* %2, align 2, !dbg !1000
  %13 = load i16, i16* %2, align 2, !dbg !1001
  %14 = call i16 @__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %13), !dbg !1002
  %15 = or i16 %12, %14, !dbg !1003
  store i16 %15, i16* %2, align 2, !dbg !1003
  %16 = load i16, i16* %2, align 2, !dbg !1004
  %17 = load i16, i16* %2, align 2, !dbg !1005
  %18 = call i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %17), !dbg !1006
  %19 = or i16 %16, %18, !dbg !1007
  store i16 %19, i16* %2, align 2, !dbg !1007
  %20 = load i16, i16* %3, align 2, !dbg !1008
  %21 = load i16, i16* %2, align 2, !dbg !1009
  %22 = shl i16 %20, 1, !dbg !1010
  %23 = inttoptr i16 %22 to i16*, !dbg !1010
  store volatile i16 %21, i16* %23, align 2, !dbg !1010
  call void asm sideeffect "nop", ""(), !dbg !1010
  call void asm sideeffect "nop", ""(), !dbg !1010
  ret void, !dbg !1011
}

define internal i16 @__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %0) !dbg !1012 {
  %2 = alloca i16, i16 1, align 2, !dbg !1013
  %3 = alloca i16, i16 1, align 2, !dbg !1015
  store i16 %0, i16* %3, align 2, !dbg !1015
  %4 = load i16, i16* %3, align 2, !dbg !1016
  store i16 %4, i16* %2, align 2, !dbg !1013
  %5 = load i16, i16* %2, align 2, !dbg !1017
  store i16 %5, i16* %2, align 2, !dbg !1018
  %6 = load i16, i16* %2, align 2, !dbg !1019
  ret i16 %6, !dbg !1020
}

define internal i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %0) !dbg !1021 {
  %2 = alloca i16, i16 1, align 2, !dbg !1022
  %3 = alloca i16, i16 1, align 2, !dbg !1024
  store i16 %0, i16* %3, align 2, !dbg !1024
  %4 = load i16, i16* %3, align 2, !dbg !1025
  store i16 %4, i16* %2, align 2, !dbg !1022
  %5 = load i16, i16* %2, align 2, !dbg !1026
  %6 = or i16 %5, 2, !dbg !1027
  store i16 %6, i16* %2, align 2, !dbg !1027
  %7 = load i16, i16* %2, align 2, !dbg !1028
  ret i16 %7, !dbg !1029
}

define internal i16 @__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %0) !dbg !1030 {
  %2 = alloca i16, i16 1, align 2, !dbg !1031
  %3 = alloca i16, i16 1, align 2, !dbg !1033
  store i16 %0, i16* %3, align 2, !dbg !1033
  %4 = load i16, i16* %3, align 2, !dbg !1034
  store i16 %4, i16* %2, align 2, !dbg !1031
  %5 = load i16, i16* %2, align 2, !dbg !1035
  %6 = or i16 %5, 128, !dbg !1036
  store i16 %6, i16* %2, align 2, !dbg !1036
  %7 = load i16, i16* %2, align 2, !dbg !1037
  ret i16 %7, !dbg !1038
}

define internal void @__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction(i16 %0) !dbg !1039 {
  %2 = alloca i16, i16 1, align 2, !dbg !1040
  %3 = alloca i16, i16 1, align 2, !dbg !1042
  %4 = alloca i16, i16 1, align 2, !dbg !1043
  store i16 %0, i16* %4, align 2, !dbg !1043
  %5 = load i16, i16* %4, align 2, !dbg !1044
  store i16 %5, i16* %3, align 2, !dbg !1042
  %6 = load i16, i16* %3, align 2, !dbg !1045
  %7 = shl i16 %6, 1, !dbg !1046
  %8 = inttoptr i16 %7 to i16*, !dbg !1046
  call void asm sideeffect "nop", ""(), !dbg !1046
  call void asm sideeffect "nop", ""(), !dbg !1046
  %9 = load volatile i16, i16* %8, align 2, !dbg !1046
  store i16 %9, i16* %2, align 2, !dbg !1040
  %10 = load i16, i16* %2, align 2, !dbg !1047
  %11 = and i16 %10, -17, !dbg !1048
  store i16 %11, i16* %2, align 2, !dbg !1048
  %12 = load i16, i16* %3, align 2, !dbg !1049
  %13 = load i16, i16* %2, align 2, !dbg !1050
  %14 = shl i16 %12, 1, !dbg !1051
  %15 = inttoptr i16 %14 to i16*, !dbg !1051
  store volatile i16 %13, i16* %15, align 2, !dbg !1051
  call void asm sideeffect "nop", ""(), !dbg !1051
  call void asm sideeffect "nop", ""(), !dbg !1051
  ret void, !dbg !1052
}

define internal void @__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction(i16 %0) !dbg !1053 {
  %2 = alloca i16, i16 1, align 2, !dbg !1054
  %3 = alloca i16, i16 1, align 2, !dbg !1056
  %4 = alloca i16, i16 1, align 2, !dbg !1057
  store i16 %0, i16* %4, align 2, !dbg !1057
  %5 = load i16, i16* %4, align 2, !dbg !1058
  store i16 %5, i16* %3, align 2, !dbg !1056
  %6 = load i16, i16* %3, align 2, !dbg !1059
  %7 = shl i16 %6, 1, !dbg !1060
  %8 = inttoptr i16 %7 to i16*, !dbg !1060
  call void asm sideeffect "nop", ""(), !dbg !1060
  call void asm sideeffect "nop", ""(), !dbg !1060
  %9 = load volatile i16, i16* %8, align 2, !dbg !1060
  store i16 %9, i16* %2, align 2, !dbg !1054
  %10 = load i16, i16* %2, align 2, !dbg !1061
  %11 = or i16 %10, 16, !dbg !1062
  store i16 %11, i16* %2, align 2, !dbg !1062
  %12 = load i16, i16* %3, align 2, !dbg !1063
  %13 = load i16, i16* %2, align 2, !dbg !1064
  %14 = shl i16 %12, 1, !dbg !1065
  %15 = inttoptr i16 %14 to i16*, !dbg !1065
  store volatile i16 %13, i16* %15, align 2, !dbg !1065
  call void asm sideeffect "nop", ""(), !dbg !1065
  call void asm sideeffect "nop", ""(), !dbg !1065
  ret void, !dbg !1066
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
!4 = !DIFile(filename: "./pe.csl", directory: "/home/USER/xkernel/studies/wse3-characterization/microbench/addfam/cases/const_both")
!5 = !DISubroutineType(types: !6)
!6 = !{}
!7 = !DILocation(line: 16, column: 8, scope: !8)
!8 = !DILexicalBlockFile(scope: !3, file: !4, discriminator: 0)
!9 = !DILocation(line: 17, column: 3, scope: !8)
!10 = !DILocation(line: 15, column: 1, scope: !8)
!11 = distinct !DISubprogram(name: "f_exit", linkageName: "f_exit", scope: null, file: !4, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!12 = !DILocation(line: 20, column: 22, scope: !13)
!13 = !DILexicalBlockFile(scope: !11, file: !4, discriminator: 0)
!14 = !DILocation(line: 20, column: 1, scope: !13)
!15 = distinct !DISubprogram(name: "sys_mod.sys_nop", linkageName: "sys_mod.sys_nop", scope: null, file: !16, line: 90, type: !5, scopeLine: 90, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!16 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/memcpy.csl", directory: "")
!17 = !DILocation(line: 90, column: 1, scope: !18)
!18 = !DILexicalBlockFile(scope: !15, file: !16, discriminator: 0)
!19 = distinct !DISubprogram(name: "sys_mod.unblock_cmd_stream", linkageName: "sys_mod.unblock_cmd_stream", scope: null, file: !16, line: 102, type: !5, scopeLine: 102, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!20 = !DILocation(line: 103, column: 3, scope: !21)
!21 = !DILexicalBlockFile(scope: !19, file: !16, discriminator: 0)
!22 = !DILocation(line: 102, column: 1, scope: !21)
!23 = distinct !DISubprogram(name: "sys_mod.sys_mod.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.unblock_cmd_stream", scope: null, file: !24, line: 307, type: !5, scopeLine: 307, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!24 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpy.csl", directory: "")
!25 = !DILocation(line: 308, column: 5, scope: !26)
!26 = !DILexicalBlockFile(scope: !23, file: !24, discriminator: 0)
!27 = !DILocation(line: 307, column: 1, scope: !26)
!28 = distinct !DISubprogram(name: "sys_mod.sys_mod.teardown_h2d", linkageName: "sys_mod.sys_mod.teardown_h2d", scope: null, file: !24, line: 323, type: !5, scopeLine: 323, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!29 = !DILocation(line: 326, column: 5, scope: !30)
!30 = !DILexicalBlockFile(scope: !28, file: !24, discriminator: 0)
!31 = !DILocation(line: 323, column: 1, scope: !30)
!32 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_ublk_c22", linkageName: "sys_mod.sys_mod.f_ublk_c22", scope: null, file: !24, line: 335, type: !5, scopeLine: 335, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!33 = !DILocation(line: 336, column: 5, scope: !34)
!34 = !DILexicalBlockFile(scope: !32, file: !24, discriminator: 0)
!35 = !DILocation(line: 335, column: 1, scope: !34)
!36 = distinct !DISubprogram(name: "sys_mod.sys_mod.teardown_d2h", linkageName: "sys_mod.sys_mod.teardown_d2h", scope: null, file: !24, line: 344, type: !5, scopeLine: 344, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!37 = !DILocation(line: 355, column: 5, scope: !38)
!38 = !DILexicalBlockFile(scope: !36, file: !24, discriminator: 0)
!39 = !DILocation(line: 359, column: 5, scope: !38)
!40 = !DILocation(line: 344, column: 1, scope: !38)
!41 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_memcpyh2d", linkageName: "sys_mod.sys_mod.f_memcpyh2d", scope: null, file: !24, line: 460, type: !5, scopeLine: 460, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!42 = !DILocation(line: 477, column: 5, scope: !43)
!43 = !DILexicalBlockFile(scope: !41, file: !24, discriminator: 0)
!44 = !DILocation(line: 476, column: 5, scope: !43)
!45 = !DILocation(line: 475, column: 5, scope: !43)
!46 = !DILocation(line: 474, column: 5, scope: !43)
!47 = !DILocation(line: 473, column: 5, scope: !43)
!48 = !DILocation(line: 472, column: 5, scope: !43)
!49 = !DILocation(line: 471, column: 5, scope: !43)
!50 = !DILocation(line: 470, column: 5, scope: !43)
!51 = !DILocation(line: 469, column: 5, scope: !43)
!52 = !DILocation(line: 468, column: 5, scope: !43)
!53 = !DILocation(line: 467, column: 5, scope: !43)
!54 = !DILocation(line: 466, column: 5, scope: !43)
!55 = !DILocation(line: 465, column: 5, scope: !43)
!56 = !DILocation(line: 463, column: 5, scope: !43)
!57 = !DILocation(line: 462, column: 20, scope: !43)
!58 = !DILocation(line: 462, column: 32, scope: !43)
!59 = !DILocation(line: 462, column: 5, scope: !43)
!60 = !DILocation(line: 465, column: 33, scope: !43)
!61 = !DILocation(line: 465, column: 38, scope: !43)
!62 = !DILocation(line: 466, column: 34, scope: !43)
!63 = !DILocation(line: 466, column: 39, scope: !43)
!64 = !DILocation(line: 467, column: 34, scope: !43)
!65 = !DILocation(line: 467, column: 39, scope: !43)
!66 = !DILocation(line: 468, column: 33, scope: !43)
!67 = !DILocation(line: 468, column: 38, scope: !43)
!68 = !DILocation(line: 469, column: 33, scope: !43)
!69 = !DILocation(line: 469, column: 38, scope: !43)
!70 = !DILocation(line: 470, column: 35, scope: !43)
!71 = !DILocation(line: 470, column: 21, scope: !43)
!72 = !DILocation(line: 471, column: 41, scope: !43)
!73 = !DILocation(line: 471, column: 27, scope: !43)
!74 = !DILocation(line: 472, column: 39, scope: !43)
!75 = !DILocation(line: 472, column: 25, scope: !43)
!76 = !DILocation(line: 473, column: 44, scope: !43)
!77 = !DILocation(line: 473, column: 49, scope: !43)
!78 = !DILocation(line: 474, column: 41, scope: !43)
!79 = !DILocation(line: 474, column: 46, scope: !43)
!80 = !DILocation(line: 475, column: 41, scope: !43)
!81 = !DILocation(line: 475, column: 46, scope: !43)
!82 = !DILocation(line: 476, column: 59, scope: !43)
!83 = !DILocation(line: 476, column: 64, scope: !43)
!84 = !DILocation(line: 476, column: 50, scope: !43)
!85 = !DILocation(line: 476, column: 129, scope: !43)
!86 = !DILocation(line: 476, column: 134, scope: !43)
!87 = !DILocation(line: 476, column: 120, scope: !43)
!88 = !DILocation(line: 476, column: 118, scope: !43)
!89 = !DILocation(line: 476, column: 112, scope: !43)
!90 = !DILocation(line: 476, column: 36, scope: !43)
!91 = !DILocation(line: 477, column: 59, scope: !43)
!92 = !DILocation(line: 477, column: 64, scope: !43)
!93 = !DILocation(line: 477, column: 50, scope: !43)
!94 = !DILocation(line: 477, column: 129, scope: !43)
!95 = !DILocation(line: 477, column: 134, scope: !43)
!96 = !DILocation(line: 477, column: 120, scope: !43)
!97 = !DILocation(line: 477, column: 118, scope: !43)
!98 = !DILocation(line: 477, column: 112, scope: !43)
!99 = !DILocation(line: 477, column: 36, scope: !43)
!100 = !DILocation(line: 479, column: 24, scope: !43)
!101 = !DILocation(line: 481, column: 21, scope: !43)
!102 = !DILocation(line: 481, column: 19, scope: !43)
!103 = !DILocation(line: 482, column: 21, scope: !43)
!104 = !DILocation(line: 482, column: 19, scope: !43)
!105 = !DILocation(line: 483, column: 21, scope: !43)
!106 = !DILocation(line: 483, column: 19, scope: !43)
!107 = !DILocation(line: 484, column: 20, scope: !43)
!108 = !DILocation(line: 484, column: 18, scope: !43)
!109 = !DILocation(line: 485, column: 20, scope: !43)
!110 = !DILocation(line: 485, column: 18, scope: !43)
!111 = !DILocation(line: 486, column: 22, scope: !43)
!112 = !DILocation(line: 486, column: 20, scope: !43)
!113 = !DILocation(line: 487, column: 27, scope: !43)
!114 = !DILocation(line: 487, column: 25, scope: !43)
!115 = !DILocation(line: 488, column: 25, scope: !43)
!116 = !DILocation(line: 488, column: 23, scope: !43)
!117 = !DILocation(line: 489, column: 31, scope: !43)
!118 = !DILocation(line: 489, column: 29, scope: !43)
!119 = !DILocation(line: 490, column: 28, scope: !43)
!120 = !DILocation(line: 490, column: 26, scope: !43)
!121 = !DILocation(line: 491, column: 28, scope: !43)
!122 = !DILocation(line: 491, column: 26, scope: !43)
!123 = !DILocation(line: 492, column: 37, scope: !43)
!124 = !DILocation(line: 492, column: 35, scope: !43)
!125 = !DILocation(line: 493, column: 37, scope: !43)
!126 = !DILocation(line: 493, column: 35, scope: !43)
!127 = !DILocation(line: 495, column: 5, scope: !43)
!128 = !DILocation(line: 501, column: 5, scope: !43)
!129 = !DILocation(line: 506, column: 5, scope: !43)
!130 = !DILocation(line: 521, column: 5, scope: !43)
!131 = !DILocation(line: 522, column: 16, scope: !43)
!132 = !DILocation(line: 531, column: 5, scope: !43)
!133 = !DILocation(line: 460, column: 1, scope: !43)
!134 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_memcpyd2h", linkageName: "sys_mod.sys_mod.f_memcpyd2h", scope: null, file: !24, line: 556, type: !5, scopeLine: 556, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!135 = !DILocation(line: 568, column: 5, scope: !136)
!136 = !DILexicalBlockFile(scope: !134, file: !24, discriminator: 0)
!137 = !DILocation(line: 567, column: 5, scope: !136)
!138 = !DILocation(line: 566, column: 5, scope: !136)
!139 = !DILocation(line: 565, column: 5, scope: !136)
!140 = !DILocation(line: 564, column: 5, scope: !136)
!141 = !DILocation(line: 563, column: 5, scope: !136)
!142 = !DILocation(line: 562, column: 5, scope: !136)
!143 = !DILocation(line: 561, column: 5, scope: !136)
!144 = !DILocation(line: 559, column: 5, scope: !136)
!145 = !DILocation(line: 558, column: 20, scope: !136)
!146 = !DILocation(line: 558, column: 32, scope: !136)
!147 = !DILocation(line: 558, column: 5, scope: !136)
!148 = !DILocation(line: 561, column: 33, scope: !136)
!149 = !DILocation(line: 561, column: 38, scope: !136)
!150 = !DILocation(line: 562, column: 34, scope: !136)
!151 = !DILocation(line: 562, column: 39, scope: !136)
!152 = !DILocation(line: 563, column: 34, scope: !136)
!153 = !DILocation(line: 563, column: 39, scope: !136)
!154 = !DILocation(line: 564, column: 33, scope: !136)
!155 = !DILocation(line: 564, column: 38, scope: !136)
!156 = !DILocation(line: 565, column: 33, scope: !136)
!157 = !DILocation(line: 565, column: 38, scope: !136)
!158 = !DILocation(line: 566, column: 35, scope: !136)
!159 = !DILocation(line: 566, column: 21, scope: !136)
!160 = !DILocation(line: 567, column: 41, scope: !136)
!161 = !DILocation(line: 567, column: 27, scope: !136)
!162 = !DILocation(line: 568, column: 39, scope: !136)
!163 = !DILocation(line: 568, column: 25, scope: !136)
!164 = !DILocation(line: 570, column: 24, scope: !136)
!165 = !DILocation(line: 573, column: 21, scope: !136)
!166 = !DILocation(line: 573, column: 19, scope: !136)
!167 = !DILocation(line: 574, column: 21, scope: !136)
!168 = !DILocation(line: 574, column: 19, scope: !136)
!169 = !DILocation(line: 575, column: 21, scope: !136)
!170 = !DILocation(line: 575, column: 19, scope: !136)
!171 = !DILocation(line: 576, column: 20, scope: !136)
!172 = !DILocation(line: 576, column: 18, scope: !136)
!173 = !DILocation(line: 577, column: 20, scope: !136)
!174 = !DILocation(line: 577, column: 18, scope: !136)
!175 = !DILocation(line: 578, column: 22, scope: !136)
!176 = !DILocation(line: 578, column: 20, scope: !136)
!177 = !DILocation(line: 579, column: 27, scope: !136)
!178 = !DILocation(line: 579, column: 25, scope: !136)
!179 = !DILocation(line: 580, column: 25, scope: !136)
!180 = !DILocation(line: 580, column: 23, scope: !136)
!181 = !DILocation(line: 582, column: 5, scope: !136)
!182 = !DILocation(line: 588, column: 59, scope: !136)
!183 = !DILocation(line: 588, column: 5, scope: !136)
!184 = !DILocation(line: 608, column: 5, scope: !136)
!185 = !DILocation(line: 609, column: 16, scope: !136)
!186 = !DILocation(line: 556, column: 1, scope: !136)
!187 = distinct !DISubprogram(name: "sys_mod.sys_mod.oq0_teardow_handler", linkageName: "sys_mod.sys_mod.oq0_teardow_handler", scope: null, file: !24, line: 631, type: !5, scopeLine: 631, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!188 = !DILocation(line: 632, column: 9, scope: !189)
!189 = !DILexicalBlockFile(scope: !187, file: !24, discriminator: 0)
!190 = !DILocation(line: 632, column: 5, scope: !189)
!191 = !DILocation(line: 634, column: 66, scope: !189)
!192 = !DILocation(line: 634, column: 9, scope: !189)
!193 = !DILocation(line: 636, column: 13, scope: !189)
!194 = !DILocation(line: 637, column: 13, scope: !189)
!195 = !DILocation(line: 638, column: 13, scope: !189)
!196 = !DILocation(line: 639, column: 13, scope: !189)
!197 = !DILocation(line: 640, column: 13, scope: !189)
!198 = !DILocation(line: 641, column: 13, scope: !189)
!199 = !DILocation(line: 642, column: 13, scope: !189)
!200 = !DILocation(line: 643, column: 13, scope: !189)
!201 = !DILocation(line: 644, column: 13, scope: !189)
!202 = !DILocation(line: 645, column: 13, scope: !189)
!203 = !DILocation(line: 646, column: 13, scope: !189)
!204 = !DILocation(line: 647, column: 13, scope: !189)
!205 = !DILocation(line: 648, column: 13, scope: !189)
!206 = !DILocation(line: 635, column: 9, scope: !189)
!207 = !DILocation(line: 652, column: 9, scope: !189)
!208 = !DILocation(line: 654, column: 13, scope: !189)
!209 = !DILocation(line: 655, column: 13, scope: !189)
!210 = !DILocation(line: 656, column: 13, scope: !189)
!211 = !DILocation(line: 657, column: 13, scope: !189)
!212 = !DILocation(line: 658, column: 13, scope: !189)
!213 = !DILocation(line: 659, column: 13, scope: !189)
!214 = !DILocation(line: 660, column: 13, scope: !189)
!215 = !DILocation(line: 661, column: 13, scope: !189)
!216 = !DILocation(line: 653, column: 9, scope: !189)
!217 = !DILocation(line: 664, column: 5, scope: !189)
!218 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_rpc", linkageName: "sys_mod.sys_mod.f_rpc", scope: null, file: !24, line: 694, type: !5, scopeLine: 694, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!219 = !DILocation(line: 694, column: 13, scope: !220)
!220 = !DILexicalBlockFile(scope: !218, file: !24, discriminator: 0)
!221 = !DILocation(line: 700, column: 5, scope: !220)
!222 = !DILocation(line: 706, column: 20, scope: !220)
!223 = !DILocation(line: 706, column: 32, scope: !220)
!224 = !DILocation(line: 706, column: 5, scope: !220)
!225 = !DILocation(line: 710, column: 5, scope: !220)
!226 = !DILocation(line: 712, column: 24, scope: !220)
!227 = !DILocation(line: 694, column: 1, scope: !220)
!228 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.stack_push", linkageName: "sys_mod.sys_mod.sys_mod.stack_push", scope: null, file: !229, line: 54, type: !5, scopeLine: 54, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!229 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/sys.csl", directory: "")
!230 = !DILocation(line: 60, column: 5, scope: !231)
!231 = !DILexicalBlockFile(scope: !228, file: !229, discriminator: 0)
!232 = !DILocation(line: 54, column: 16, scope: !231)
!233 = !DILocation(line: 59, column: 13, scope: !231)
!234 = !DILocation(line: 59, column: 24, scope: !231)
!235 = !DILocation(line: 59, column: 5, scope: !231)
!236 = !DILocation(line: 61, column: 25, scope: !231)
!237 = !DILocation(line: 61, column: 5, scope: !231)
!238 = !DILocation(line: 61, column: 11, scope: !231)
!239 = !DILocation(line: 61, column: 10, scope: !231)
!240 = !DILocation(line: 61, column: 23, scope: !231)
!241 = !DILocation(line: 62, column: 18, scope: !231)
!242 = !DILocation(line: 62, column: 29, scope: !231)
!243 = !DILocation(line: 62, column: 16, scope: !231)
!244 = !DILocation(line: 54, column: 1, scope: !231)
!245 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_push", linkageName: "sys_mod.sys_mod.sys_mod.f_push", scope: null, file: !229, line: 72, type: !5, scopeLine: 72, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!246 = !DILocation(line: 72, column: 25, scope: !247)
!247 = !DILexicalBlockFile(scope: !245, file: !229, discriminator: 0)
!248 = !DILocation(line: 72, column: 13, scope: !247)
!249 = !DILocation(line: 73, column: 16, scope: !247)
!250 = !DILocation(line: 73, column: 5, scope: !247)
!251 = !DILocation(line: 72, column: 1, scope: !247)
!252 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.block_cmd_stream", linkageName: "sys_mod.sys_mod.sys_mod.block_cmd_stream", scope: null, file: !229, line: 76, type: !5, scopeLine: 76, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!253 = !DILocation(line: 77, column: 5, scope: !254)
!254 = !DILexicalBlockFile(scope: !252, file: !229, discriminator: 0)
!255 = !DILocation(line: 76, column: 1, scope: !254)
!256 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.sys_mod.unblock_cmd_stream", scope: null, file: !229, line: 80, type: !5, scopeLine: 80, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!257 = !DILocation(line: 81, column: 5, scope: !258)
!258 = !DILexicalBlockFile(scope: !256, file: !229, discriminator: 0)
!259 = !DILocation(line: 80, column: 1, scope: !258)
!260 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_sys_exit", linkageName: "sys_mod.sys_mod.sys_mod.f_sys_exit", scope: null, file: !229, line: 85, type: !5, scopeLine: 85, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!261 = !DILocation(line: 86, column: 5, scope: !262)
!262 = !DILexicalBlockFile(scope: !260, file: !229, discriminator: 0)
!263 = !DILocation(line: 87, column: 5, scope: !262)
!264 = !DILocation(line: 85, column: 1, scope: !262)
!265 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore", linkageName: "sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore", scope: null, file: !229, line: 90, type: !5, scopeLine: 90, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!266 = !DILocation(line: 90, column: 30, scope: !267)
!267 = !DILexicalBlockFile(scope: !265, file: !229, discriminator: 0)
!268 = !DILocation(line: 90, column: 1, scope: !267)
!269 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord", scope: null, file: !270, line: 131, type: !5, scopeLine: 131, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!270 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpyh2d.csl", directory: "")
!271 = !DILocation(line: 132, column: 12, scope: !272)
!272 = !DILexicalBlockFile(scope: !269, file: !270, discriminator: 0)
!273 = !DILocation(line: 132, column: 5, scope: !272)
!274 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord", scope: null, file: !270, line: 134, type: !5, scopeLine: 134, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!275 = !DILocation(line: 135, column: 12, scope: !276)
!276 = !DILexicalBlockFile(scope: !274, file: !270, discriminator: 0)
!277 = !DILocation(line: 135, column: 5, scope: !276)
!278 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval", scope: null, file: !270, line: 148, type: !5, scopeLine: 148, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!279 = !DILocation(line: 148, column: 23, scope: !280)
!280 = !DILexicalBlockFile(scope: !278, file: !270, discriminator: 0)
!281 = !DILocation(line: 149, column: 9, scope: !280)
!282 = !DILocation(line: 149, column: 20, scope: !280)
!283 = !DILocation(line: 149, column: 5, scope: !280)
!284 = !DILocation(line: 152, column: 23, scope: !280)
!285 = !DILocation(line: 152, column: 20, scope: !280)
!286 = !DILocation(line: 152, column: 9, scope: !280)
!287 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start", scope: null, file: !270, line: 226, type: !5, scopeLine: 226, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!288 = !DILocation(line: 233, column: 5, scope: !289)
!289 = !DILexicalBlockFile(scope: !287, file: !270, discriminator: 0)
!290 = !DILocation(line: 226, column: 49, scope: !289)
!291 = !DILocation(line: 226, column: 32, scope: !289)
!292 = !DILocation(line: 226, column: 21, scope: !289)
!293 = !DILocation(line: 229, column: 37, scope: !289)
!294 = !DILocation(line: 229, column: 52, scope: !289)
!295 = !DILocation(line: 229, column: 19, scope: !289)
!296 = !DILocation(line: 233, column: 71, scope: !289)
!297 = !DILocation(line: 233, column: 55, scope: !289)
!298 = !DILocation(line: 233, column: 25, scope: !289)
!299 = !DILocation(line: 235, column: 37, scope: !289)
!300 = !DILocation(line: 235, column: 52, scope: !289)
!301 = !DILocation(line: 235, column: 19, scope: !289)
!302 = !DILocation(line: 236, column: 28, scope: !289)
!303 = !DILocation(line: 236, column: 5, scope: !289)
!304 = !DILocation(line: 237, column: 28, scope: !289)
!305 = !DILocation(line: 237, column: 5, scope: !289)
!306 = !DILocation(line: 238, column: 13, scope: !289)
!307 = !DILocation(line: 238, column: 11, scope: !289)
!308 = !DILocation(line: 238, column: 5, scope: !289)
!309 = !DILocation(line: 239, column: 9, scope: !289)
!310 = !DILocation(line: 241, column: 9, scope: !289)
!311 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream", scope: null, file: !270, line: 249, type: !5, scopeLine: 249, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!312 = !DILocation(line: 250, column: 5, scope: !313)
!313 = !DILexicalBlockFile(scope: !311, file: !270, discriminator: 0)
!314 = !DILocation(line: 249, column: 1, scope: !313)
!315 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure", scope: null, file: !270, line: 276, type: !5, scopeLine: 276, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!316 = !DILocation(line: 414, column: 13, scope: !317)
!317 = !DILexicalBlockFile(scope: !315, file: !270, discriminator: 0)
!318 = !DILocation(line: 413, column: 13, scope: !317)
!319 = !DILocation(line: 400, column: 17, scope: !317)
!320 = !DILocation(line: 340, column: 9, scope: !317)
!321 = !DILocation(line: 339, column: 9, scope: !317)
!322 = !DILocation(line: 337, column: 5, scope: !317)
!323 = !DILocation(line: 319, column: 9, scope: !317)
!324 = !DILocation(line: 318, column: 9, scope: !317)
!325 = !DILocation(line: 315, column: 5, scope: !317)
!326 = !DILocation(line: 292, column: 5, scope: !317)
!327 = !DILocation(line: 291, column: 5, scope: !317)
!328 = !DILocation(line: 289, column: 5, scope: !317)
!329 = !DILocation(line: 288, column: 5, scope: !317)
!330 = !DILocation(line: 287, column: 5, scope: !317)
!331 = !DILocation(line: 286, column: 5, scope: !317)
!332 = !DILocation(line: 285, column: 5, scope: !317)
!333 = !DILocation(line: 284, column: 5, scope: !317)
!334 = !DILocation(line: 283, column: 5, scope: !317)
!335 = !DILocation(line: 282, column: 5, scope: !317)
!336 = !DILocation(line: 281, column: 5, scope: !317)
!337 = !DILocation(line: 280, column: 5, scope: !317)
!338 = !DILocation(line: 279, column: 5, scope: !317)
!339 = !DILocation(line: 278, column: 5, scope: !317)
!340 = !DILocation(line: 277, column: 5, scope: !317)
!341 = !DILocation(line: 291, column: 26, scope: !317)
!342 = !DILocation(line: 292, column: 26, scope: !317)
!343 = !DILocation(line: 315, column: 25, scope: !317)
!344 = !DILocation(line: 315, column: 31, scope: !317)
!345 = !DILocation(line: 315, column: 29, scope: !317)
!346 = !DILocation(line: 316, column: 20, scope: !317)
!347 = !DILocation(line: 316, column: 18, scope: !317)
!348 = !DILocation(line: 317, column: 52, scope: !317)
!349 = !DILocation(line: 317, column: 49, scope: !317)
!350 = !DILocation(line: 317, column: 5, scope: !317)
!351 = !DILocation(line: 318, column: 42, scope: !317)
!352 = !DILocation(line: 318, column: 33, scope: !317)
!353 = !DILocation(line: 318, column: 49, scope: !317)
!354 = !DILocation(line: 318, column: 48, scope: !317)
!355 = !DILocation(line: 318, column: 24, scope: !317)
!356 = !DILocation(line: 319, column: 24, scope: !317)
!357 = !DILocation(line: 319, column: 32, scope: !317)
!358 = !DILocation(line: 319, column: 36, scope: !317)
!359 = !DILocation(line: 319, column: 34, scope: !317)
!360 = !DILocation(line: 319, column: 30, scope: !317)
!361 = !DILocation(line: 320, column: 18, scope: !317)
!362 = !DILocation(line: 320, column: 15, scope: !317)
!363 = !DILocation(line: 320, column: 9, scope: !317)
!364 = !DILocation(line: 321, column: 26, scope: !317)
!365 = !DILocation(line: 325, column: 28, scope: !317)
!366 = !DILocation(line: 325, column: 26, scope: !317)
!367 = !DILocation(line: 331, column: 9, scope: !317)
!368 = !DILocation(line: 331, column: 15, scope: !317)
!369 = !DILocation(line: 331, column: 5, scope: !317)
!370 = !DILocation(line: 332, column: 22, scope: !317)
!371 = !DILocation(line: 334, column: 9, scope: !317)
!372 = !DILocation(line: 334, column: 18, scope: !317)
!373 = !DILocation(line: 334, column: 15, scope: !317)
!374 = !DILocation(line: 334, column: 5, scope: !317)
!375 = !DILocation(line: 335, column: 22, scope: !317)
!376 = !DILocation(line: 338, column: 52, scope: !317)
!377 = !DILocation(line: 338, column: 49, scope: !317)
!378 = !DILocation(line: 338, column: 5, scope: !317)
!379 = !DILocation(line: 339, column: 42, scope: !317)
!380 = !DILocation(line: 339, column: 48, scope: !317)
!381 = !DILocation(line: 339, column: 46, scope: !317)
!382 = !DILocation(line: 339, column: 33, scope: !317)
!383 = !DILocation(line: 339, column: 52, scope: !317)
!384 = !DILocation(line: 339, column: 51, scope: !317)
!385 = !DILocation(line: 339, column: 24, scope: !317)
!386 = !DILocation(line: 340, column: 25, scope: !317)
!387 = !DILocation(line: 340, column: 31, scope: !317)
!388 = !DILocation(line: 340, column: 29, scope: !317)
!389 = !DILocation(line: 340, column: 37, scope: !317)
!390 = !DILocation(line: 340, column: 41, scope: !317)
!391 = !DILocation(line: 340, column: 39, scope: !317)
!392 = !DILocation(line: 340, column: 35, scope: !317)
!393 = !DILocation(line: 341, column: 18, scope: !317)
!394 = !DILocation(line: 341, column: 15, scope: !317)
!395 = !DILocation(line: 341, column: 9, scope: !317)
!396 = !DILocation(line: 342, column: 26, scope: !317)
!397 = !DILocation(line: 347, column: 10, scope: !317)
!398 = !DILocation(line: 347, column: 16, scope: !317)
!399 = !DILocation(line: 347, column: 14, scope: !317)
!400 = !DILocation(line: 347, column: 5, scope: !317)
!401 = !DILocation(line: 348, column: 22, scope: !317)
!402 = !DILocation(line: 350, column: 10, scope: !317)
!403 = !DILocation(line: 350, column: 18, scope: !317)
!404 = !DILocation(line: 350, column: 21, scope: !317)
!405 = !DILocation(line: 350, column: 20, scope: !317)
!406 = !DILocation(line: 350, column: 14, scope: !317)
!407 = !DILocation(line: 350, column: 5, scope: !317)
!408 = !DILocation(line: 351, column: 22, scope: !317)
!409 = !DILocation(line: 354, column: 9, scope: !317)
!410 = !DILocation(line: 354, column: 5, scope: !317)
!411 = !DILocation(line: 358, column: 9, scope: !317)
!412 = !DILocation(line: 361, column: 9, scope: !317)
!413 = !DILocation(line: 364, column: 20, scope: !317)
!414 = !DILocation(line: 364, column: 17, scope: !317)
!415 = !DILocation(line: 364, column: 9, scope: !317)
!416 = !DILocation(line: 368, column: 13, scope: !317)
!417 = !DILocation(line: 371, column: 13, scope: !317)
!418 = !DILocation(line: 375, column: 13, scope: !317)
!419 = !DILocation(line: 394, column: 13, scope: !317)
!420 = !DILocation(line: 396, column: 29, scope: !317)
!421 = !DILocation(line: 396, column: 27, scope: !317)
!422 = !DILocation(line: 397, column: 60, scope: !317)
!423 = !DILocation(line: 397, column: 57, scope: !317)
!424 = !DILocation(line: 397, column: 13, scope: !317)
!425 = !DILocation(line: 400, column: 54, scope: !317)
!426 = !DILocation(line: 400, column: 55, scope: !317)
!427 = !DILocation(line: 400, column: 46, scope: !317)
!428 = !DILocation(line: 400, column: 59, scope: !317)
!429 = !DILocation(line: 400, column: 58, scope: !317)
!430 = !DILocation(line: 400, column: 37, scope: !317)
!431 = !DILocation(line: 400, column: 35, scope: !317)
!432 = !DILocation(line: 401, column: 33, scope: !317)
!433 = !DILocation(line: 401, column: 31, scope: !317)
!434 = !DILocation(line: 402, column: 69, scope: !317)
!435 = !DILocation(line: 402, column: 66, scope: !317)
!436 = !DILocation(line: 402, column: 19, scope: !317)
!437 = !DILocation(line: 404, column: 31, scope: !317)
!438 = !DILocation(line: 408, column: 75, scope: !317)
!439 = !DILocation(line: 408, column: 88, scope: !317)
!440 = !DILocation(line: 408, column: 13, scope: !317)
!441 = !DILocation(line: 413, column: 31, scope: !317)
!442 = !DILocation(line: 414, column: 33, scope: !317)
!443 = !DILocation(line: 415, column: 21, scope: !317)
!444 = !DILocation(line: 415, column: 29, scope: !317)
!445 = !DILocation(line: 415, column: 27, scope: !317)
!446 = !DILocation(line: 415, column: 19, scope: !317)
!447 = !DILocation(line: 416, column: 22, scope: !317)
!448 = !DILocation(line: 416, column: 19, scope: !317)
!449 = !DILocation(line: 416, column: 13, scope: !317)
!450 = !DILocation(line: 417, column: 23, scope: !317)
!451 = !DILocation(line: 419, column: 63, scope: !317)
!452 = !DILocation(line: 419, column: 60, scope: !317)
!453 = !DILocation(line: 419, column: 13, scope: !317)
!454 = !DILocation(line: 421, column: 23, scope: !317)
!455 = !DILocation(line: 423, column: 69, scope: !317)
!456 = !DILocation(line: 423, column: 13, scope: !317)
!457 = !DILocation(line: 426, column: 13, scope: !317)
!458 = !DILocation(line: 430, column: 13, scope: !317)
!459 = !DILocation(line: 433, column: 48, scope: !317)
!460 = !DILocation(line: 433, column: 22, scope: !317)
!461 = !DILocation(line: 433, column: 19, scope: !317)
!462 = !DILocation(line: 433, column: 13, scope: !317)
!463 = !DILocation(line: 436, column: 34, scope: !317)
!464 = !DILocation(line: 436, column: 39, scope: !317)
!465 = !DILocation(line: 436, column: 50, scope: !317)
!466 = !DILocation(line: 436, column: 17, scope: !317)
!467 = !DILocation(line: 452, column: 49, scope: !317)
!468 = !DILocation(line: 452, column: 64, scope: !317)
!469 = !DILocation(line: 452, column: 31, scope: !317)
!470 = !DILocation(line: 453, column: 40, scope: !317)
!471 = !DILocation(line: 453, column: 17, scope: !317)
!472 = !DILocation(line: 454, column: 50, scope: !317)
!473 = !DILocation(line: 454, column: 66, scope: !317)
!474 = !DILocation(line: 454, column: 32, scope: !317)
!475 = !DILocation(line: 455, column: 40, scope: !317)
!476 = !DILocation(line: 455, column: 17, scope: !317)
!477 = !DILocation(line: 456, column: 17, scope: !317)
!478 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit", scope: null, file: !479, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!479 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/filters/wse3.csl", directory: "")
!480 = !DILocation(line: 24, column: 3, scope: !481)
!481 = !DILexicalBlockFile(scope: !478, file: !479, discriminator: 0)
!482 = !DILocation(line: 24, column: 22, scope: !481)
!483 = !DILocation(line: 23, column: 3, scope: !481)
!484 = !DILocation(line: 22, column: 3, scope: !481)
!485 = !DILocation(line: 20, column: 37, scope: !481)
!486 = !DILocation(line: 20, column: 21, scope: !481)
!487 = !DILocation(line: 21, column: 11, scope: !481)
!488 = !DILocation(line: 21, column: 17, scope: !481)
!489 = !DILocation(line: 21, column: 3, scope: !481)
!490 = !DILocation(line: 22, column: 24, scope: !481)
!491 = !DILocation(line: 22, column: 30, scope: !481)
!492 = !DILocation(line: 23, column: 40, scope: !481)
!493 = !DILocation(line: 23, column: 22, scope: !481)
!494 = !DILocation(line: 23, column: 67, scope: !481)
!495 = !DILocation(line: 24, column: 26, scope: !481)
!496 = !DILocation(line: 24, column: 41, scope: !481)
!497 = !DILocation(line: 24, column: 39, scope: !481)
!498 = !DILocation(line: 24, column: 61, scope: !481)
!499 = !DILocation(line: 24, column: 76, scope: !481)
!500 = !DILocation(line: 24, column: 74, scope: !481)
!501 = !DILocation(line: 25, column: 21, scope: !481)
!502 = !DILocation(line: 25, column: 50, scope: !481)
!503 = !DILocation(line: 25, column: 3, scope: !481)
!504 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter", scope: null, file: !479, line: 30, type: !5, scopeLine: 30, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!505 = !DILocation(line: 30, column: 36, scope: !506)
!506 = !DILexicalBlockFile(scope: !504, file: !479, discriminator: 0)
!507 = !DILocation(line: 30, column: 20, scope: !506)
!508 = !DILocation(line: 31, column: 11, scope: !506)
!509 = !DILocation(line: 31, column: 23, scope: !506)
!510 = !DILocation(line: 31, column: 3, scope: !506)
!511 = !DILocation(line: 32, column: 21, scope: !506)
!512 = !DILocation(line: 32, column: 48, scope: !506)
!513 = !DILocation(line: 32, column: 60, scope: !506)
!514 = !DILocation(line: 32, column: 64, scope: !506)
!515 = !DILocation(line: 32, column: 3, scope: !506)
!516 = !DILocation(line: 30, column: 1, scope: !506)
!517 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter", scope: null, file: !479, line: 40, type: !5, scopeLine: 40, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!518 = !DILocation(line: 47, column: 3, scope: !519)
!519 = !DILexicalBlockFile(scope: !517, file: !479, discriminator: 0)
!520 = !DILocation(line: 48, column: 7, scope: !519)
!521 = !DILocation(line: 44, column: 3, scope: !519)
!522 = !DILocation(line: 43, column: 3, scope: !519)
!523 = !DILocation(line: 42, column: 3, scope: !519)
!524 = !DILocation(line: 40, column: 32, scope: !519)
!525 = !DILocation(line: 40, column: 16, scope: !519)
!526 = !DILocation(line: 41, column: 11, scope: !519)
!527 = !DILocation(line: 41, column: 19, scope: !519)
!528 = !DILocation(line: 41, column: 3, scope: !519)
!529 = !DILocation(line: 42, column: 40, scope: !519)
!530 = !DILocation(line: 42, column: 22, scope: !519)
!531 = !DILocation(line: 43, column: 26, scope: !519)
!532 = !DILocation(line: 43, column: 34, scope: !519)
!533 = !DILocation(line: 44, column: 25, scope: !519)
!534 = !DILocation(line: 44, column: 42, scope: !519)
!535 = !DILocation(line: 44, column: 40, scope: !519)
!536 = !DILocation(line: 45, column: 21, scope: !519)
!537 = !DILocation(line: 46, column: 35, scope: !519)
!538 = !DILocation(line: 46, column: 21, scope: !519)
!539 = !DILocation(line: 46, column: 50, scope: !519)
!540 = !DILocation(line: 45, column: 3, scope: !519)
!541 = !DILocation(line: 48, column: 11, scope: !519)
!542 = !DILocation(line: 48, column: 26, scope: !519)
!543 = !DILocation(line: 48, column: 43, scope: !519)
!544 = !DILocation(line: 48, column: 41, scope: !519)
!545 = !DILocation(line: 48, column: 54, scope: !519)
!546 = !DILocation(line: 48, column: 63, scope: !519)
!547 = !DILocation(line: 49, column: 21, scope: !519)
!548 = !DILocation(line: 49, column: 47, scope: !519)
!549 = !DILocation(line: 49, column: 3, scope: !519)
!550 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config", scope: null, file: !551, line: 33, type: !5, scopeLine: 33, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!551 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/filters/common.csl", directory: "")
!552 = !DILocation(line: 33, column: 46, scope: !553)
!553 = !DILexicalBlockFile(scope: !550, file: !551, discriminator: 0)
!554 = !DILocation(line: 33, column: 31, scope: !553)
!555 = !DILocation(line: 33, column: 15, scope: !553)
!556 = !DILocation(line: 34, column: 24, scope: !553)
!557 = !DILocation(line: 34, column: 23, scope: !553)
!558 = !DILocation(line: 34, column: 51, scope: !553)
!559 = !DILocation(line: 34, column: 35, scope: !553)
!560 = !DILocation(line: 34, column: 60, scope: !553)
!561 = !DILocation(line: 34, column: 73, scope: !553)
!562 = !DILocation(line: 34, column: 3, scope: !553)
!563 = !DILocation(line: 33, column: 1, scope: !553)
!564 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config", scope: null, file: !551, line: 38, type: !5, scopeLine: 38, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!565 = !DILocation(line: 38, column: 31, scope: !566)
!566 = !DILexicalBlockFile(scope: !564, file: !551, discriminator: 0)
!567 = !DILocation(line: 38, column: 15, scope: !566)
!568 = !DILocation(line: 39, column: 31, scope: !566)
!569 = !DILocation(line: 39, column: 30, scope: !566)
!570 = !DILocation(line: 39, column: 58, scope: !566)
!571 = !DILocation(line: 39, column: 42, scope: !566)
!572 = !DILocation(line: 39, column: 67, scope: !566)
!573 = !DILocation(line: 39, column: 10, scope: !566)
!574 = !DILocation(line: 39, column: 3, scope: !566)
!575 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit", scope: null, file: !576, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!576 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/teardown.csl", directory: "")
!577 = !DILocation(line: 43, column: 3, scope: !578)
!578 = !DILexicalBlockFile(scope: !575, file: !576, discriminator: 0)
!579 = !DILocation(line: 41, column: 3, scope: !578)
!580 = !DILocation(line: 40, column: 3, scope: !578)
!581 = !DILocation(line: 39, column: 9, scope: !578)
!582 = !DILocation(line: 40, column: 23, scope: !578)
!583 = !DILocation(line: 41, column: 70, scope: !578)
!584 = !DILocation(line: 41, column: 68, scope: !578)
!585 = !DILocation(line: 43, column: 27, scope: !578)
!586 = !DILocation(line: 43, column: 15, scope: !578)
!587 = !DILocation(line: 44, column: 15, scope: !578)
!588 = !DILocation(line: 44, column: 21, scope: !578)
!589 = !DILocation(line: 44, column: 27, scope: !578)
!590 = !DILocation(line: 44, column: 3, scope: !578)
!591 = !DILocation(line: 39, column: 1, scope: !578)
!592 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord", scope: null, file: !593, line: 4, type: !5, scopeLine: 4, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!593 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/layout.csl", directory: "")
!594 = !DILocation(line: 5, column: 10, scope: !595)
!595 = !DILexicalBlockFile(scope: !592, file: !593, discriminator: 0)
!596 = !DILocation(line: 5, column: 67, scope: !595)
!597 = !DILocation(line: 5, column: 3, scope: !595)
!598 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord", scope: null, file: !593, line: 8, type: !5, scopeLine: 8, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!599 = !DILocation(line: 9, column: 10, scope: !600)
!600 = !DILexicalBlockFile(scope: !598, file: !593, discriminator: 0)
!601 = !DILocation(line: 9, column: 67, scope: !600)
!602 = !DILocation(line: 9, column: 3, scope: !600)
!603 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord", scope: null, file: !604, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!604 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config.csl", directory: "")
!605 = !DILocation(line: 50, column: 3, scope: !606)
!606 = !DILexicalBlockFile(scope: !603, file: !604, discriminator: 0)
!607 = !DILocation(line: 43, column: 21, scope: !606)
!608 = !DILocation(line: 50, column: 57, scope: !606)
!609 = !DILocation(line: 50, column: 68, scope: !606)
!610 = !DILocation(line: 50, column: 41, scope: !606)
!611 = !DILocation(line: 50, column: 19, scope: !606)
!612 = !DILocation(line: 52, column: 10, scope: !606)
!613 = !DILocation(line: 52, column: 18, scope: !606)
!614 = !DILocation(line: 48, column: 22, scope: !606)
!615 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.get_x_coord", scope: null, file: !616, line: 171, type: !5, scopeLine: 171, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!616 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpyd2h.csl", directory: "")
!617 = !DILocation(line: 172, column: 12, scope: !618)
!618 = !DILexicalBlockFile(scope: !615, file: !616, discriminator: 0)
!619 = !DILocation(line: 172, column: 5, scope: !618)
!620 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.get_y_coord", scope: null, file: !616, line: 174, type: !5, scopeLine: 174, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!621 = !DILocation(line: 175, column: 12, scope: !622)
!622 = !DILexicalBlockFile(scope: !620, file: !616, discriminator: 0)
!623 = !DILocation(line: 175, column: 5, scope: !622)
!624 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval", scope: null, file: !616, line: 187, type: !5, scopeLine: 187, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!625 = !DILocation(line: 187, column: 23, scope: !626)
!626 = !DILexicalBlockFile(scope: !624, file: !616, discriminator: 0)
!627 = !DILocation(line: 188, column: 9, scope: !626)
!628 = !DILocation(line: 188, column: 20, scope: !626)
!629 = !DILocation(line: 188, column: 5, scope: !626)
!630 = !DILocation(line: 191, column: 23, scope: !626)
!631 = !DILocation(line: 191, column: 20, scope: !626)
!632 = !DILocation(line: 191, column: 9, scope: !626)
!633 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start", scope: null, file: !616, line: 383, type: !5, scopeLine: 383, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!634 = !DILocation(line: 386, column: 5, scope: !635)
!635 = !DILexicalBlockFile(scope: !633, file: !616, discriminator: 0)
!636 = !DILocation(line: 384, column: 72, scope: !635)
!637 = !DILocation(line: 384, column: 59, scope: !635)
!638 = !DILocation(line: 384, column: 46, scope: !635)
!639 = !DILocation(line: 384, column: 33, scope: !635)
!640 = !DILocation(line: 384, column: 19, scope: !635)
!641 = !DILocation(line: 384, column: 5, scope: !635)
!642 = !DILocation(line: 383, column: 32, scope: !635)
!643 = !DILocation(line: 383, column: 21, scope: !635)
!644 = !DILocation(line: 386, column: 26, scope: !635)
!645 = !DILocation(line: 388, column: 28, scope: !635)
!646 = !DILocation(line: 388, column: 17, scope: !635)
!647 = !DILocation(line: 389, column: 25, scope: !635)
!648 = !DILocation(line: 389, column: 23, scope: !635)
!649 = !DILocation(line: 391, column: 38, scope: !635)
!650 = !DILocation(line: 391, column: 20, scope: !635)
!651 = !DILocation(line: 391, column: 18, scope: !635)
!652 = !DILocation(line: 393, column: 7, scope: !635)
!653 = !DILocation(line: 395, column: 17, scope: !635)
!654 = !DILocation(line: 395, column: 15, scope: !635)
!655 = !DILocation(line: 397, column: 15, scope: !635)
!656 = !DILocation(line: 397, column: 13, scope: !635)
!657 = !DILocation(line: 398, column: 15, scope: !635)
!658 = !DILocation(line: 398, column: 25, scope: !635)
!659 = !DILocation(line: 398, column: 23, scope: !635)
!660 = !DILocation(line: 398, column: 31, scope: !635)
!661 = !DILocation(line: 398, column: 13, scope: !635)
!662 = !DILocation(line: 401, column: 10, scope: !635)
!663 = !DILocation(line: 401, column: 17, scope: !635)
!664 = !DILocation(line: 401, column: 14, scope: !635)
!665 = !DILocation(line: 401, column: 5, scope: !635)
!666 = !DILocation(line: 403, column: 48, scope: !635)
!667 = !DILocation(line: 403, column: 26, scope: !635)
!668 = !DILocation(line: 404, column: 26, scope: !635)
!669 = !DILocation(line: 404, column: 18, scope: !635)
!670 = !DILocation(line: 407, column: 48, scope: !635)
!671 = !DILocation(line: 407, column: 26, scope: !635)
!672 = !DILocation(line: 408, column: 27, scope: !635)
!673 = !DILocation(line: 408, column: 18, scope: !635)
!674 = !DILocation(line: 411, column: 14, scope: !635)
!675 = !DILocation(line: 414, column: 14, scope: !635)
!676 = !DILocation(line: 414, column: 11, scope: !635)
!677 = !DILocation(line: 414, column: 5, scope: !635)
!678 = !DILocation(line: 416, column: 44, scope: !635)
!679 = !DILocation(line: 416, column: 75, scope: !635)
!680 = !DILocation(line: 416, column: 59, scope: !635)
!681 = !DILocation(line: 416, column: 25, scope: !635)
!682 = !DILocation(line: 416, column: 23, scope: !635)
!683 = !DILocation(line: 418, column: 41, scope: !635)
!684 = !DILocation(line: 418, column: 23, scope: !635)
!685 = !DILocation(line: 419, column: 9, scope: !635)
!686 = !DILocation(line: 425, column: 44, scope: !635)
!687 = !DILocation(line: 425, column: 23, scope: !635)
!688 = !DILocation(line: 426, column: 41, scope: !635)
!689 = !DILocation(line: 426, column: 23, scope: !635)
!690 = !DILocation(line: 427, column: 9, scope: !635)
!691 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x", scope: null, file: !616, line: 448, type: !5, scopeLine: 448, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!692 = !DILocation(line: 448, column: 31, scope: !693)
!693 = !DILexicalBlockFile(scope: !691, file: !616, discriminator: 0)
!694 = !DILocation(line: 453, column: 5, scope: !693)
!695 = !DILocation(line: 456, column: 19, scope: !693)
!696 = !DILocation(line: 456, column: 17, scope: !693)
!697 = !DILocation(line: 461, column: 5, scope: !693)
!698 = !DILocation(line: 462, column: 28, scope: !693)
!699 = !DILocation(line: 462, column: 5, scope: !693)
!700 = !DILocation(line: 463, column: 5, scope: !693)
!701 = !DILocation(line: 464, column: 9, scope: !693)
!702 = !DILocation(line: 464, column: 10, scope: !693)
!703 = !DILocation(line: 464, column: 7, scope: !693)
!704 = !DILocation(line: 448, column: 1, scope: !693)
!705 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_send_data", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_send_data", scope: null, file: !616, line: 476, type: !5, scopeLine: 476, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!706 = !DILocation(line: 494, column: 9, scope: !707)
!707 = !DILexicalBlockFile(scope: !705, file: !616, discriminator: 0)
!708 = !DILocation(line: 478, column: 9, scope: !707)
!709 = !DILocation(line: 478, column: 13, scope: !707)
!710 = !DILocation(line: 478, column: 11, scope: !707)
!711 = !DILocation(line: 478, column: 5, scope: !707)
!712 = !DILocation(line: 479, column: 9, scope: !707)
!713 = !DILocation(line: 480, column: 32, scope: !707)
!714 = !DILocation(line: 480, column: 9, scope: !707)
!715 = !DILocation(line: 481, column: 17, scope: !707)
!716 = !DILocation(line: 481, column: 15, scope: !707)
!717 = !DILocation(line: 481, column: 9, scope: !707)
!718 = !DILocation(line: 482, column: 13, scope: !707)
!719 = !DILocation(line: 483, column: 51, scope: !707)
!720 = !DILocation(line: 483, column: 29, scope: !707)
!721 = !DILocation(line: 483, column: 27, scope: !707)
!722 = !DILocation(line: 485, column: 13, scope: !707)
!723 = !DILocation(line: 486, column: 51, scope: !707)
!724 = !DILocation(line: 486, column: 29, scope: !707)
!725 = !DILocation(line: 486, column: 27, scope: !707)
!726 = !DILocation(line: 488, column: 13, scope: !707)
!727 = !DILocation(line: 488, column: 14, scope: !707)
!728 = !DILocation(line: 488, column: 11, scope: !707)
!729 = !DILocation(line: 494, column: 30, scope: !707)
!730 = !DILocation(line: 496, column: 14, scope: !707)
!731 = !DILocation(line: 496, column: 25, scope: !707)
!732 = !DILocation(line: 496, column: 22, scope: !707)
!733 = !DILocation(line: 496, column: 9, scope: !707)
!734 = !DILocation(line: 497, column: 13, scope: !707)
!735 = !DILocation(line: 498, column: 13, scope: !707)
!736 = !DILocation(line: 499, column: 13, scope: !707)
!737 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl", scope: null, file: !616, line: 505, type: !5, scopeLine: 505, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!738 = !DILocation(line: 524, column: 13, scope: !739)
!739 = !DILexicalBlockFile(scope: !737, file: !616, discriminator: 0)
!740 = !DILocation(line: 506, column: 14, scope: !739)
!741 = !DILocation(line: 506, column: 11, scope: !739)
!742 = !DILocation(line: 506, column: 5, scope: !739)
!743 = !DILocation(line: 508, column: 9, scope: !739)
!744 = !DILocation(line: 509, column: 32, scope: !739)
!745 = !DILocation(line: 509, column: 9, scope: !739)
!746 = !DILocation(line: 510, column: 9, scope: !739)
!747 = !DILocation(line: 514, column: 13, scope: !739)
!748 = !DILocation(line: 514, column: 17, scope: !739)
!749 = !DILocation(line: 514, column: 15, scope: !739)
!750 = !DILocation(line: 514, column: 9, scope: !739)
!751 = !DILocation(line: 518, column: 13, scope: !739)
!752 = !DILocation(line: 519, column: 36, scope: !739)
!753 = !DILocation(line: 519, column: 13, scope: !739)
!754 = !DILocation(line: 520, column: 13, scope: !739)
!755 = !DILocation(line: 524, column: 34, scope: !739)
!756 = !DILocation(line: 526, column: 18, scope: !739)
!757 = !DILocation(line: 526, column: 29, scope: !739)
!758 = !DILocation(line: 526, column: 26, scope: !739)
!759 = !DILocation(line: 526, column: 13, scope: !739)
!760 = !DILocation(line: 529, column: 17, scope: !739)
!761 = !DILocation(line: 530, column: 17, scope: !739)
!762 = !DILocation(line: 531, column: 17, scope: !739)
!763 = !DILocation(line: 534, column: 17, scope: !739)
!764 = !DILocation(line: 535, column: 40, scope: !739)
!765 = !DILocation(line: 535, column: 17, scope: !739)
!766 = !DILocation(line: 536, column: 17, scope: !739)
!767 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.d2h_configure", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.d2h_configure", scope: null, file: !616, line: 593, type: !5, scopeLine: 593, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!768 = !DILocation(line: 617, column: 26, scope: !769)
!769 = !DILexicalBlockFile(scope: !767, file: !616, discriminator: 0)
!770 = !DILocation(line: 612, column: 47, scope: !769)
!771 = !DILocation(line: 612, column: 27, scope: !769)
!772 = !DILocation(line: 602, column: 5, scope: !769)
!773 = !DILocation(line: 601, column: 5, scope: !769)
!774 = !DILocation(line: 599, column: 5, scope: !769)
!775 = !DILocation(line: 598, column: 5, scope: !769)
!776 = !DILocation(line: 596, column: 5, scope: !769)
!777 = !DILocation(line: 595, column: 5, scope: !769)
!778 = !DILocation(line: 593, column: 86, scope: !769)
!779 = !DILocation(line: 593, column: 70, scope: !769)
!780 = !DILocation(line: 593, column: 60, scope: !769)
!781 = !DILocation(line: 593, column: 52, scope: !769)
!782 = !DILocation(line: 593, column: 44, scope: !769)
!783 = !DILocation(line: 593, column: 35, scope: !769)
!784 = !DILocation(line: 593, column: 26, scope: !769)
!785 = !DILocation(line: 593, column: 18, scope: !769)
!786 = !DILocation(line: 595, column: 26, scope: !769)
!787 = !DILocation(line: 596, column: 26, scope: !769)
!788 = !DILocation(line: 598, column: 23, scope: !769)
!789 = !DILocation(line: 599, column: 23, scope: !769)
!790 = !DILocation(line: 599, column: 28, scope: !769)
!791 = !DILocation(line: 599, column: 26, scope: !769)
!792 = !DILocation(line: 599, column: 29, scope: !769)
!793 = !DILocation(line: 601, column: 24, scope: !769)
!794 = !DILocation(line: 602, column: 24, scope: !769)
!795 = !DILocation(line: 602, column: 29, scope: !769)
!796 = !DILocation(line: 602, column: 27, scope: !769)
!797 = !DILocation(line: 602, column: 30, scope: !769)
!798 = !DILocation(line: 611, column: 20, scope: !769)
!799 = !DILocation(line: 612, column: 11, scope: !769)
!800 = !DILocation(line: 612, column: 18, scope: !769)
!801 = !DILocation(line: 612, column: 15, scope: !769)
!802 = !DILocation(line: 612, column: 32, scope: !769)
!803 = !DILocation(line: 612, column: 39, scope: !769)
!804 = !DILocation(line: 612, column: 36, scope: !769)
!805 = !DILocation(line: 612, column: 52, scope: !769)
!806 = !DILocation(line: 612, column: 59, scope: !769)
!807 = !DILocation(line: 612, column: 56, scope: !769)
!808 = !DILocation(line: 612, column: 5, scope: !769)
!809 = !DILocation(line: 613, column: 24, scope: !769)
!810 = !DILocation(line: 616, column: 15, scope: !769)
!811 = !DILocation(line: 617, column: 11, scope: !769)
!812 = !DILocation(line: 617, column: 18, scope: !769)
!813 = !DILocation(line: 617, column: 15, scope: !769)
!814 = !DILocation(line: 617, column: 30, scope: !769)
!815 = !DILocation(line: 617, column: 5, scope: !769)
!816 = !DILocation(line: 618, column: 19, scope: !769)
!817 = !DILocation(line: 621, column: 9, scope: !769)
!818 = !DILocation(line: 621, column: 5, scope: !769)
!819 = !DILocation(line: 627, column: 9, scope: !769)
!820 = !DILocation(line: 629, column: 13, scope: !769)
!821 = !DILocation(line: 629, column: 25, scope: !769)
!822 = !DILocation(line: 629, column: 21, scope: !769)
!823 = !DILocation(line: 629, column: 9, scope: !769)
!824 = !DILocation(line: 632, column: 13, scope: !769)
!825 = !DILocation(line: 636, column: 13, scope: !769)
!826 = !DILocation(line: 641, column: 9, scope: !769)
!827 = !DILocation(line: 646, column: 13, scope: !769)
!828 = !DILocation(line: 646, column: 9, scope: !769)
!829 = !DILocation(line: 647, column: 30, scope: !769)
!830 = !DILocation(line: 647, column: 35, scope: !769)
!831 = !DILocation(line: 647, column: 46, scope: !769)
!832 = !DILocation(line: 647, column: 50, scope: !769)
!833 = !DILocation(line: 647, column: 54, scope: !769)
!834 = !DILocation(line: 647, column: 57, scope: !769)
!835 = !DILocation(line: 647, column: 60, scope: !769)
!836 = !DILocation(line: 647, column: 63, scope: !769)
!837 = !DILocation(line: 647, column: 13, scope: !769)
!838 = !DILocation(line: 661, column: 9, scope: !769)
!839 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit", scope: null, file: !576, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!840 = !DILocation(line: 43, column: 3, scope: !841)
!841 = !DILexicalBlockFile(scope: !839, file: !576, discriminator: 0)
!842 = !DILocation(line: 41, column: 3, scope: !841)
!843 = !DILocation(line: 40, column: 3, scope: !841)
!844 = !DILocation(line: 39, column: 9, scope: !841)
!845 = !DILocation(line: 40, column: 23, scope: !841)
!846 = !DILocation(line: 41, column: 70, scope: !841)
!847 = !DILocation(line: 41, column: 68, scope: !841)
!848 = !DILocation(line: 43, column: 27, scope: !841)
!849 = !DILocation(line: 43, column: 15, scope: !841)
!850 = !DILocation(line: 44, column: 15, scope: !841)
!851 = !DILocation(line: 44, column: 21, scope: !841)
!852 = !DILocation(line: 44, column: 27, scope: !841)
!853 = !DILocation(line: 44, column: 3, scope: !841)
!854 = !DILocation(line: 39, column: 1, scope: !841)
!855 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord", scope: null, file: !593, line: 4, type: !5, scopeLine: 4, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!856 = !DILocation(line: 5, column: 10, scope: !857)
!857 = !DILexicalBlockFile(scope: !855, file: !593, discriminator: 0)
!858 = !DILocation(line: 5, column: 67, scope: !857)
!859 = !DILocation(line: 5, column: 3, scope: !857)
!860 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord", scope: null, file: !593, line: 8, type: !5, scopeLine: 8, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!861 = !DILocation(line: 9, column: 10, scope: !862)
!862 = !DILexicalBlockFile(scope: !860, file: !593, discriminator: 0)
!863 = !DILocation(line: 9, column: 67, scope: !862)
!864 = !DILocation(line: 9, column: 3, scope: !862)
!865 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord", scope: null, file: !604, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!866 = !DILocation(line: 50, column: 3, scope: !867)
!867 = !DILexicalBlockFile(scope: !865, file: !604, discriminator: 0)
!868 = !DILocation(line: 43, column: 21, scope: !867)
!869 = !DILocation(line: 50, column: 57, scope: !867)
!870 = !DILocation(line: 50, column: 68, scope: !867)
!871 = !DILocation(line: 50, column: 41, scope: !867)
!872 = !DILocation(line: 50, column: 19, scope: !867)
!873 = !DILocation(line: 52, column: 10, scope: !867)
!874 = !DILocation(line: 52, column: 18, scope: !867)
!875 = !DILocation(line: 48, column: 22, scope: !867)
!876 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr", linkageName: "sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr", scope: null, file: !877, line: 11, type: !5, scopeLine: 11, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!877 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/input_queue_config.csl", directory: "")
!878 = !DILocation(line: 11, column: 32, scope: !879)
!879 = !DILexicalBlockFile(scope: !876, file: !877, discriminator: 0)
!880 = !DILocation(line: 12, column: 80, scope: !879)
!881 = !DILocation(line: 12, column: 69, scope: !879)
!882 = !DILocation(line: 12, column: 39, scope: !879)
!883 = !DILocation(line: 12, column: 3, scope: !879)
!884 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue", linkageName: "sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue", scope: null, file: !877, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!885 = !DILocation(line: 46, column: 3, scope: !886)
!886 = !DILexicalBlockFile(scope: !884, file: !877, discriminator: 0)
!887 = !DILocation(line: 45, column: 3, scope: !886)
!888 = !DILocation(line: 39, column: 42, scope: !886)
!889 = !DILocation(line: 39, column: 34, scope: !886)
!890 = !DILocation(line: 39, column: 24, scope: !886)
!891 = !DILocation(line: 45, column: 44, scope: !886)
!892 = !DILocation(line: 45, column: 16, scope: !886)
!893 = !DILocation(line: 46, column: 30, scope: !886)
!894 = !DILocation(line: 46, column: 18, scope: !886)
!895 = !DILocation(line: 56, column: 9, scope: !886)
!896 = !DILocation(line: 56, column: 5, scope: !886)
!897 = !DILocation(line: 58, column: 13, scope: !886)
!898 = !DILocation(line: 58, column: 17, scope: !886)
!899 = !DILocation(line: 58, column: 11, scope: !886)
!900 = !DILocation(line: 61, column: 13, scope: !886)
!901 = !DILocation(line: 61, column: 17, scope: !886)
!902 = !DILocation(line: 61, column: 11, scope: !886)
!903 = !DILocation(line: 66, column: 9, scope: !886)
!904 = !DILocation(line: 66, column: 13, scope: !886)
!905 = !DILocation(line: 66, column: 7, scope: !886)
!906 = !DILocation(line: 68, column: 9, scope: !886)
!907 = !DILocation(line: 68, column: 24, scope: !886)
!908 = !DILocation(line: 68, column: 13, scope: !886)
!909 = !DILocation(line: 68, column: 7, scope: !886)
!910 = !DILocation(line: 70, column: 15, scope: !886)
!911 = !DILocation(line: 70, column: 21, scope: !886)
!912 = !DILocation(line: 70, column: 3, scope: !886)
!913 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr", linkageName: "sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr", scope: null, file: !914, line: 11, type: !5, scopeLine: 11, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!914 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/output_queue_config.csl", directory: "")
!915 = !DILocation(line: 11, column: 33, scope: !916)
!916 = !DILexicalBlockFile(scope: !913, file: !914, discriminator: 0)
!917 = !DILocation(line: 12, column: 82, scope: !916)
!918 = !DILocation(line: 12, column: 40, scope: !916)
!919 = !DILocation(line: 12, column: 3, scope: !916)
!920 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue", linkageName: "sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue", scope: null, file: !914, line: 31, type: !5, scopeLine: 31, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!921 = !DILocation(line: 38, column: 3, scope: !922)
!922 = !DILexicalBlockFile(scope: !920, file: !914, discriminator: 0)
!923 = !DILocation(line: 37, column: 3, scope: !922)
!924 = !DILocation(line: 31, column: 35, scope: !922)
!925 = !DILocation(line: 31, column: 25, scope: !922)
!926 = !DILocation(line: 37, column: 45, scope: !922)
!927 = !DILocation(line: 37, column: 16, scope: !922)
!928 = !DILocation(line: 38, column: 30, scope: !922)
!929 = !DILocation(line: 38, column: 18, scope: !922)
!930 = !DILocation(line: 41, column: 9, scope: !922)
!931 = !DILocation(line: 41, column: 13, scope: !922)
!932 = !DILocation(line: 41, column: 7, scope: !922)
!933 = !DILocation(line: 43, column: 9, scope: !922)
!934 = !DILocation(line: 43, column: 24, scope: !922)
!935 = !DILocation(line: 43, column: 13, scope: !922)
!936 = !DILocation(line: 43, column: 27, scope: !922)
!937 = !DILocation(line: 43, column: 7, scope: !922)
!938 = !DILocation(line: 45, column: 15, scope: !922)
!939 = !DILocation(line: 45, column: 21, scope: !922)
!940 = !DILocation(line: 45, column: 3, scope: !922)
!941 = !DILocation(line: 31, column: 1, scope: !922)
!942 = distinct !DISubprogram(name: ".get_tensor_ptr", linkageName: ".get_tensor_ptr", scope: null, file: !4, line: 1, type: !5, scopeLine: 1, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!943 = !DILocation(line: 1, column: 1, scope: !944)
!944 = !DILexicalBlockFile(scope: !942, file: !4, discriminator: 0)
!945 = distinct !DISubprogram(name: "__generic0sys_mod.sys_mod.tile_config.queue_flush.exit", linkageName: "__generic0sys_mod.sys_mod.tile_config.queue_flush.exit", scope: null, file: !946, line: 12, type: !5, scopeLine: 12, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!946 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/queue_flush.csl", directory: "")
!947 = !DILocation(line: 24, column: 3, scope: !948)
!948 = !DILexicalBlockFile(scope: !945, file: !946, discriminator: 0)
!949 = !DILocation(line: 12, column: 1, scope: !948)
!950 = distinct !DISubprogram(name: "__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position", linkageName: "__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position", scope: null, file: !951, line: 30, type: !5, scopeLine: 30, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!951 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/switch_config.csl", directory: "")
!952 = !DILocation(line: 34, column: 3, scope: !953)
!953 = !DILexicalBlockFile(scope: !950, file: !951, discriminator: 0)
!954 = !DILocation(line: 32, column: 3, scope: !953)
!955 = !DILocation(line: 30, column: 27, scope: !953)
!956 = !DILocation(line: 33, column: 7, scope: !953)
!957 = !DILocation(line: 34, column: 36, scope: !953)
!958 = !DILocation(line: 34, column: 24, scope: !953)
!959 = !DILocation(line: 35, column: 3, scope: !953)
!960 = !DILocation(line: 35, column: 18, scope: !953)
!961 = !DILocation(line: 36, column: 15, scope: !953)
!962 = !DILocation(line: 36, column: 21, scope: !953)
!963 = !DILocation(line: 36, column: 3, scope: !953)
!964 = !DILocation(line: 30, column: 1, scope: !953)
!965 = distinct !DISubprogram(name: "__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", linkageName: "__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", scope: null, file: !966, line: 96, type: !5, scopeLine: 96, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!966 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/color_config.csl", directory: "")
!967 = !DILocation(line: 99, column: 3, scope: !968)
!968 = !DILexicalBlockFile(scope: !965, file: !966, discriminator: 0)
!969 = !DILocation(line: 98, column: 3, scope: !968)
!970 = !DILocation(line: 96, column: 17, scope: !968)
!971 = !DILocation(line: 98, column: 16, scope: !968)
!972 = !DILocation(line: 99, column: 29, scope: !968)
!973 = !DILocation(line: 99, column: 17, scope: !968)
!974 = !DILocation(line: 100, column: 13, scope: !968)
!975 = !DILocation(line: 100, column: 21, scope: !968)
!976 = !DILocation(line: 100, column: 11, scope: !968)
!977 = !DILocation(line: 104, column: 7, scope: !968)
!978 = !DILocation(line: 104, column: 50, scope: !968)
!979 = !DILocation(line: 104, column: 18, scope: !968)
!980 = !DILocation(line: 104, column: 15, scope: !968)
!981 = !DILocation(line: 121, column: 7, scope: !968)
!982 = !DILocation(line: 121, column: 50, scope: !968)
!983 = !DILocation(line: 121, column: 18, scope: !968)
!984 = !DILocation(line: 121, column: 15, scope: !968)
!985 = !DILocation(line: 128, column: 15, scope: !968)
!986 = !DILocation(line: 128, column: 21, scope: !968)
!987 = !DILocation(line: 128, column: 3, scope: !968)
!988 = !DILocation(line: 96, column: 1, scope: !968)
!989 = distinct !DISubprogram(name: "__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", linkageName: "__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", scope: null, file: !966, line: 96, type: !5, scopeLine: 96, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!990 = !DILocation(line: 99, column: 3, scope: !991)
!991 = !DILexicalBlockFile(scope: !989, file: !966, discriminator: 0)
!992 = !DILocation(line: 98, column: 3, scope: !991)
!993 = !DILocation(line: 96, column: 17, scope: !991)
!994 = !DILocation(line: 98, column: 16, scope: !991)
!995 = !DILocation(line: 99, column: 29, scope: !991)
!996 = !DILocation(line: 99, column: 17, scope: !991)
!997 = !DILocation(line: 100, column: 13, scope: !991)
!998 = !DILocation(line: 100, column: 21, scope: !991)
!999 = !DILocation(line: 100, column: 11, scope: !991)
!1000 = !DILocation(line: 104, column: 7, scope: !991)
!1001 = !DILocation(line: 104, column: 50, scope: !991)
!1002 = !DILocation(line: 104, column: 18, scope: !991)
!1003 = !DILocation(line: 104, column: 15, scope: !991)
!1004 = !DILocation(line: 121, column: 7, scope: !991)
!1005 = !DILocation(line: 121, column: 50, scope: !991)
!1006 = !DILocation(line: 121, column: 18, scope: !991)
!1007 = !DILocation(line: 121, column: 15, scope: !991)
!1008 = !DILocation(line: 128, column: 15, scope: !991)
!1009 = !DILocation(line: 128, column: 21, scope: !991)
!1010 = !DILocation(line: 128, column: 3, scope: !991)
!1011 = !DILocation(line: 96, column: 1, scope: !991)
!1012 = distinct !DISubprogram(name: "__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", linkageName: "__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", scope: null, file: !966, line: 60, type: !5, scopeLine: 60, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1013 = !DILocation(line: 61, column: 3, scope: !1014)
!1014 = !DILexicalBlockFile(scope: !1012, file: !966, discriminator: 0)
!1015 = !DILocation(line: 60, column: 46, scope: !1014)
!1016 = !DILocation(line: 61, column: 16, scope: !1014)
!1017 = !DILocation(line: 72, column: 5, scope: !1014)
!1018 = !DILocation(line: 72, column: 12, scope: !1014)
!1019 = !DILocation(line: 74, column: 10, scope: !1014)
!1020 = !DILocation(line: 74, column: 3, scope: !1014)
!1021 = distinct !DISubprogram(name: "__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes", linkageName: "__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes", scope: null, file: !966, line: 77, type: !5, scopeLine: 77, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1022 = !DILocation(line: 78, column: 3, scope: !1023)
!1023 = !DILexicalBlockFile(scope: !1021, file: !966, discriminator: 0)
!1024 = !DILocation(line: 77, column: 46, scope: !1023)
!1025 = !DILocation(line: 78, column: 16, scope: !1023)
!1026 = !DILocation(line: 86, column: 5, scope: !1023)
!1027 = !DILocation(line: 86, column: 12, scope: !1023)
!1028 = !DILocation(line: 91, column: 10, scope: !1023)
!1029 = !DILocation(line: 91, column: 3, scope: !1023)
!1030 = distinct !DISubprogram(name: "__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", linkageName: "__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", scope: null, file: !966, line: 60, type: !5, scopeLine: 60, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1031 = !DILocation(line: 61, column: 3, scope: !1032)
!1032 = !DILexicalBlockFile(scope: !1030, file: !966, discriminator: 0)
!1033 = !DILocation(line: 60, column: 46, scope: !1032)
!1034 = !DILocation(line: 61, column: 16, scope: !1032)
!1035 = !DILocation(line: 63, column: 5, scope: !1032)
!1036 = !DILocation(line: 63, column: 12, scope: !1032)
!1037 = !DILocation(line: 74, column: 10, scope: !1032)
!1038 = !DILocation(line: 74, column: 3, scope: !1032)
!1039 = distinct !DISubprogram(name: "__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction", linkageName: "__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction", scope: null, file: !966, line: 52, type: !5, scopeLine: 52, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1040 = !DILocation(line: 55, column: 3, scope: !1041)
!1041 = !DILexicalBlockFile(scope: !1039, file: !966, discriminator: 0)
!1042 = !DILocation(line: 54, column: 3, scope: !1041)
!1043 = !DILocation(line: 52, column: 23, scope: !1041)
!1044 = !DILocation(line: 54, column: 16, scope: !1041)
!1045 = !DILocation(line: 55, column: 29, scope: !1041)
!1046 = !DILocation(line: 55, column: 17, scope: !1041)
!1047 = !DILocation(line: 56, column: 3, scope: !1041)
!1048 = !DILocation(line: 56, column: 11, scope: !1041)
!1049 = !DILocation(line: 57, column: 15, scope: !1041)
!1050 = !DILocation(line: 57, column: 21, scope: !1041)
!1051 = !DILocation(line: 57, column: 3, scope: !1041)
!1052 = !DILocation(line: 52, column: 1, scope: !1041)
!1053 = distinct !DISubprogram(name: "__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction", linkageName: "__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction", scope: null, file: !966, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1054 = !DILocation(line: 23, column: 3, scope: !1055)
!1055 = !DILexicalBlockFile(scope: !1053, file: !966, discriminator: 0)
!1056 = !DILocation(line: 22, column: 3, scope: !1055)
!1057 = !DILocation(line: 20, column: 21, scope: !1055)
!1058 = !DILocation(line: 22, column: 16, scope: !1055)
!1059 = !DILocation(line: 23, column: 29, scope: !1055)
!1060 = !DILocation(line: 23, column: 17, scope: !1055)
!1061 = !DILocation(line: 24, column: 3, scope: !1055)
!1062 = !DILocation(line: 24, column: 11, scope: !1055)
!1063 = !DILocation(line: 25, column: 15, scope: !1055)
!1064 = !DILocation(line: 25, column: 21, scope: !1055)
!1065 = !DILocation(line: 25, column: 3, scope: !1055)
!1066 = !DILocation(line: 20, column: 1, scope: !1055)
module asm ".section \22.pe_debug_info\22, \22\22"
module asm ".section \22.note\22, \22\22"
