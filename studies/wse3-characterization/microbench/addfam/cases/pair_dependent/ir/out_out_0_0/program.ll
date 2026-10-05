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
  %4 = load i16, i16* getelementptr inbounds ([64 x i16], [64 x i16]* @c, i16 0, i1 false), align 2, !dbg !12
  %5 = load i16, i16* getelementptr inbounds ([64 x i16], [64 x i16]* @b, i16 0, i2 1), align 2, !dbg !13
  %6 = add i16 %4, %5, !dbg !14
  store i16 %6, i16* getelementptr inbounds ([64 x i16], [64 x i16]* @c, i16 0, i2 1), align 2, !dbg !15
  call void @llvm.sdr.actvt.r(i16 9), !dbg !16
  ret void, !dbg !17
}

define void @f_exit() #0 !dbg !18 {
  call void @sys_mod.unblock_cmd_stream(), !dbg !19
  ret void, !dbg !21
}

define internal void @sys_mod.sys_nop() !dbg !22 {
  ret void, !dbg !24
}

define internal void @sys_mod.unblock_cmd_stream() !dbg !26 {
  call void @sys_mod.sys_mod.unblock_cmd_stream(), !dbg !27
  ret void, !dbg !29
}

define internal void @sys_mod.sys_mod.unblock_cmd_stream() !dbg !30 {
  call void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream(), !dbg !32
  ret void, !dbg !34
}

define internal void @sys_mod.sys_mod.teardown_h2d() !dbg !35 {
  call void @llvm.sdr.actvt.r(i16 27), !dbg !36
  ret void, !dbg !38
}

define void @sys_mod.sys_mod.f_ublk_c22() #1 !dbg !39 {
  call void @sys_mod.sys_mod.unblock_cmd_stream(), !dbg !40
  ret void, !dbg !42
}

define internal void @sys_mod.sys_mod.teardown_d2h() !dbg !43 {
  call void @llvm.sdr.blk.r(i16 0), !dbg !44
  call void @llvm.sdr.actvt.r(i16 28), !dbg !46
  ret void, !dbg !47
}

define void @sys_mod.sys_mod.f_memcpyh2d() #2 !dbg !48 {
  %1 = alloca float, i16 1, align 4, !dbg !49
  %2 = alloca float, i16 1, align 4, !dbg !51
  %3 = alloca i16, i16 1, align 2, !dbg !52
  %4 = alloca i16, i16 1, align 2, !dbg !53
  %5 = alloca i16, i16 1, align 2, !dbg !54
  %6 = alloca i16, i16 1, align 2, !dbg !55
  %7 = alloca i16, i16 1, align 2, !dbg !56
  %8 = alloca i16, i16 1, align 2, !dbg !57
  %9 = alloca i16, i16 1, align 2, !dbg !58
  %10 = alloca i16, i16 1, align 2, !dbg !59
  %11 = alloca i16, i16 1, align 2, !dbg !60
  %12 = alloca i16, i16 1, align 2, !dbg !61
  %13 = alloca i16, i16 1, align 2, !dbg !62
  %14 = alloca i16*, i16 1, align 8, !dbg !63
  %15 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !64
  %16 = icmp eq i16 %15, 15, !dbg !65
  br i1 %16, label %17, label %18, !dbg !66

17:                                               ; preds = %0
  br label %19, !dbg !66

18:                                               ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !66
  br label %19, !dbg !66

19:                                               ; preds = %17, %18
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %14, align 8, !dbg !63
  %20 = load i16*, i16** %14, align 8, !dbg !67
  %21 = load i16, i16* %20, align 2, !dbg !68
  store i16 %21, i16* %13, align 2, !dbg !62
  %22 = load i16*, i16** %14, align 8, !dbg !69
  %23 = getelementptr i16, i16* %22, i16 1, !dbg !70
  %24 = load i16, i16* %23, align 2, !dbg !70
  store i16 %24, i16* %12, align 2, !dbg !61
  %25 = load i16*, i16** %14, align 8, !dbg !71
  %26 = getelementptr i16, i16* %25, i16 2, !dbg !72
  %27 = load i16, i16* %26, align 2, !dbg !72
  store i16 %27, i16* %11, align 2, !dbg !60
  %28 = load i16*, i16** %14, align 8, !dbg !73
  %29 = getelementptr i16, i16* %28, i16 3, !dbg !74
  %30 = load i16, i16* %29, align 2, !dbg !74
  store i16 %30, i16* %10, align 2, !dbg !59
  %31 = load i16*, i16** %14, align 8, !dbg !75
  %32 = getelementptr i16, i16* %31, i16 4, !dbg !76
  %33 = load i16, i16* %32, align 2, !dbg !76
  store i16 %33, i16* %9, align 2, !dbg !58
  %34 = load i16*, i16** %14, align 8, !dbg !77
  %35 = getelementptr i16, i16* %34, i16 5, !dbg !78
  %36 = load i16, i16* %35, align 2, !dbg !78
  store i16 %36, i16* %8, align 2, !dbg !57
  %37 = load i16*, i16** %14, align 8, !dbg !79
  %38 = getelementptr i16, i16* %37, i16 6, !dbg !80
  %39 = load i16, i16* %38, align 2, !dbg !80
  store i16 %39, i16* %7, align 2, !dbg !56
  %40 = load i16*, i16** %14, align 8, !dbg !81
  %41 = getelementptr i16, i16* %40, i16 7, !dbg !82
  %42 = load i16, i16* %41, align 2, !dbg !82
  store i16 %42, i16* %6, align 2, !dbg !55
  %43 = load i16*, i16** %14, align 8, !dbg !83
  %44 = getelementptr i16, i16* %43, i16 8, !dbg !84
  %45 = load i16, i16* %44, align 2, !dbg !84
  store i16 %45, i16* %5, align 2, !dbg !54
  %46 = load i16*, i16** %14, align 8, !dbg !85
  %47 = getelementptr i16, i16* %46, i16 9, !dbg !86
  %48 = load i16, i16* %47, align 2, !dbg !86
  store i16 %48, i16* %4, align 2, !dbg !53
  %49 = load i16*, i16** %14, align 8, !dbg !87
  %50 = getelementptr i16, i16* %49, i16 10, !dbg !88
  %51 = load i16, i16* %50, align 2, !dbg !88
  store i16 %51, i16* %3, align 2, !dbg !52
  %52 = load i16*, i16** %14, align 8, !dbg !89
  %53 = getelementptr i16, i16* %52, i16 12, !dbg !90
  %54 = load i16, i16* %53, align 2, !dbg !90
  %55 = zext i16 %54 to i32, !dbg !91
  %56 = load i16*, i16** %14, align 8, !dbg !92
  %57 = getelementptr i16, i16* %56, i16 11, !dbg !93
  %58 = load i16, i16* %57, align 2, !dbg !93
  %59 = zext i16 %58 to i32, !dbg !94
  %60 = add i32 %59, 16, !dbg !95
  %61 = shl i32 %55, %60, !dbg !96
  %62 = bitcast i32 %61 to float, !dbg !97
  store float %62, float* %2, align 4, !dbg !51
  %63 = load i16*, i16** %14, align 8, !dbg !98
  %64 = getelementptr i16, i16* %63, i16 14, !dbg !99
  %65 = load i16, i16* %64, align 2, !dbg !99
  %66 = zext i16 %65 to i32, !dbg !100
  %67 = load i16*, i16** %14, align 8, !dbg !101
  %68 = getelementptr i16, i16* %67, i16 13, !dbg !102
  %69 = load i16, i16* %68, align 2, !dbg !102
  %70 = zext i16 %69 to i32, !dbg !103
  %71 = add i32 %70, 16, !dbg !104
  %72 = shl i32 %66, %71, !dbg !105
  %73 = bitcast i32 %72 to float, !dbg !106
  store float %73, float* %1, align 4, !dbg !49
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !107
  %74 = load i16, i16* %13, align 2, !dbg !108
  store i16 %74, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !109
  %75 = load i16, i16* %12, align 2, !dbg !110
  store i16 %75, i16* @sys_mod.sys_mod.memcpyH2D_px, align 2, !dbg !111
  %76 = load i16, i16* %11, align 2, !dbg !112
  store i16 %76, i16* @sys_mod.sys_mod.memcpyH2D_py, align 2, !dbg !113
  %77 = load i16, i16* %10, align 2, !dbg !114
  store i16 %77, i16* @sys_mod.sys_mod.memcpyH2D_w, align 2, !dbg !115
  %78 = load i16, i16* %9, align 2, !dbg !116
  store i16 %78, i16* @sys_mod.sys_mod.memcpyH2D_h, align 2, !dbg !117
  %79 = load i16, i16* %8, align 2, !dbg !118
  store i16 %79, i16* @sys_mod.sys_mod.memcpyH2D_addr, align 2, !dbg !119
  %80 = load i16, i16* %7, align 2, !dbg !120
  store i16 %80, i16* @sys_mod.sys_mod.memcpyH2D_pe_length, align 2, !dbg !121
  %81 = load i16, i16* %6, align 2, !dbg !122
  store i16 %81, i16* @sys_mod.sys_mod.memcpyH2D_is_half, align 2, !dbg !123
  %82 = load i16, i16* %5, align 2, !dbg !124
  store i16 %82, i16* @sys_mod.sys_mod.memcpyH2D_memcpy_optype, align 2, !dbg !125
  %83 = load i16, i16* %4, align 2, !dbg !126
  store i16 %83, i16* @sys_mod.sys_mod.memcpyH2D_row_stride, align 2, !dbg !127
  %84 = load i16, i16* %3, align 2, !dbg !128
  store i16 %84, i16* @sys_mod.sys_mod.memcpyH2D_col_stride, align 2, !dbg !129
  %85 = load float, float* %2, align 4, !dbg !130
  store float %85, float* @sys_mod.sys_mod.memcpyH2D_one_over_row_stride, align 4, !dbg !131
  %86 = load float, float* %1, align 4, !dbg !132
  store float %86, float* @sys_mod.sys_mod.memcpyH2D_one_over_col_stride, align 4, !dbg !133
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !134
  call void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 0, i16 23, i1 true), !dbg !135
  call void @llvm.sdr.blk.r(i16 27), !dbg !136
  call void @llvm.sdr.oqflush(i16 0), !dbg !137
  store i1 true, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !138
  call void @llvm.sdr.blk.r(i16 0), !dbg !139
  ret void, !dbg !140
}

define void @sys_mod.sys_mod.f_memcpyd2h() #3 !dbg !141 {
  %1 = alloca i16, i16 1, align 2, !dbg !142
  %2 = alloca i16, i16 1, align 2, !dbg !144
  %3 = alloca i16, i16 1, align 2, !dbg !145
  %4 = alloca i16, i16 1, align 2, !dbg !146
  %5 = alloca i16, i16 1, align 2, !dbg !147
  %6 = alloca i16, i16 1, align 2, !dbg !148
  %7 = alloca i16, i16 1, align 2, !dbg !149
  %8 = alloca i16, i16 1, align 2, !dbg !150
  %9 = alloca i16*, i16 1, align 8, !dbg !151
  %10 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !152
  %11 = icmp eq i16 %10, 8, !dbg !153
  br i1 %11, label %12, label %13, !dbg !154

12:                                               ; preds = %0
  br label %14, !dbg !154

13:                                               ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !154
  br label %14, !dbg !154

14:                                               ; preds = %12, %13
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %9, align 8, !dbg !151
  %15 = load i16*, i16** %9, align 8, !dbg !155
  %16 = load i16, i16* %15, align 2, !dbg !156
  store i16 %16, i16* %8, align 2, !dbg !150
  %17 = load i16*, i16** %9, align 8, !dbg !157
  %18 = getelementptr i16, i16* %17, i16 1, !dbg !158
  %19 = load i16, i16* %18, align 2, !dbg !158
  store i16 %19, i16* %7, align 2, !dbg !149
  %20 = load i16*, i16** %9, align 8, !dbg !159
  %21 = getelementptr i16, i16* %20, i16 2, !dbg !160
  %22 = load i16, i16* %21, align 2, !dbg !160
  store i16 %22, i16* %6, align 2, !dbg !148
  %23 = load i16*, i16** %9, align 8, !dbg !161
  %24 = getelementptr i16, i16* %23, i16 3, !dbg !162
  %25 = load i16, i16* %24, align 2, !dbg !162
  store i16 %25, i16* %5, align 2, !dbg !147
  %26 = load i16*, i16** %9, align 8, !dbg !163
  %27 = getelementptr i16, i16* %26, i16 4, !dbg !164
  %28 = load i16, i16* %27, align 2, !dbg !164
  store i16 %28, i16* %4, align 2, !dbg !146
  %29 = load i16*, i16** %9, align 8, !dbg !165
  %30 = getelementptr i16, i16* %29, i16 5, !dbg !166
  %31 = load i16, i16* %30, align 2, !dbg !166
  store i16 %31, i16* %3, align 2, !dbg !145
  %32 = load i16*, i16** %9, align 8, !dbg !167
  %33 = getelementptr i16, i16* %32, i16 6, !dbg !168
  %34 = load i16, i16* %33, align 2, !dbg !168
  store i16 %34, i16* %2, align 2, !dbg !144
  %35 = load i16*, i16** %9, align 8, !dbg !169
  %36 = getelementptr i16, i16* %35, i16 7, !dbg !170
  %37 = load i16, i16* %36, align 2, !dbg !170
  store i16 %37, i16* %1, align 2, !dbg !142
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !171
  %38 = load i16, i16* %8, align 2, !dbg !172
  store i16 %38, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !173
  %39 = load i16, i16* %7, align 2, !dbg !174
  store i16 %39, i16* @sys_mod.sys_mod.memcpyD2H_px, align 2, !dbg !175
  %40 = load i16, i16* %6, align 2, !dbg !176
  store i16 %40, i16* @sys_mod.sys_mod.memcpyD2H_py, align 2, !dbg !177
  %41 = load i16, i16* %5, align 2, !dbg !178
  store i16 %41, i16* @sys_mod.sys_mod.memcpyD2H_w, align 2, !dbg !179
  %42 = load i16, i16* %4, align 2, !dbg !180
  store i16 %42, i16* @sys_mod.sys_mod.memcpyD2H_h, align 2, !dbg !181
  %43 = load i16, i16* %3, align 2, !dbg !182
  store i16 %43, i16* @sys_mod.sys_mod.memcpyD2H_addr, align 2, !dbg !183
  %44 = load i16, i16* %2, align 2, !dbg !184
  store i16 %44, i16* @sys_mod.sys_mod.memcpyD2H_pe_length, align 2, !dbg !185
  %45 = load i16, i16* %1, align 2, !dbg !186
  store i16 %45, i16* @sys_mod.sys_mod.memcpyD2H_is_half, align 2, !dbg !187
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !188
  %46 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !189
  call void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 0, i16 %46, i1 false), !dbg !190
  call void @llvm.sdr.oqflush(i16 0), !dbg !191
  store i1 false, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !192
  ret void, !dbg !193
}

define internal void @sys_mod.sys_mod.oq0_teardow_handler() !dbg !194 {
  %1 = load i1, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !195
  br i1 %1, label %2, label %17, !dbg !197

2:                                                ; preds = %0
  %3 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !198
  call void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 0, i16 %3), !dbg !199
  %4 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !200
  %5 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_px, align 2, !dbg !201
  %6 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_py, align 2, !dbg !202
  %7 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_w, align 2, !dbg !203
  %8 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_h, align 2, !dbg !204
  %9 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_addr, align 2, !dbg !205
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_pe_length, align 2, !dbg !206
  %11 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_is_half, align 2, !dbg !207
  %12 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_memcpy_optype, align 2, !dbg !208
  %13 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_row_stride, align 2, !dbg !209
  %14 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_col_stride, align 2, !dbg !210
  %15 = load float, float* @sys_mod.sys_mod.memcpyH2D_one_over_row_stride, align 4, !dbg !211
  %16 = load float, float* @sys_mod.sys_mod.memcpyH2D_one_over_col_stride, align 4, !dbg !212
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure(i16 %4, i16 %5, i16 %6, i16 %7, i16 %8, i16 %9, i16 %10, i16 %11, i16 %12, i16 %13, i16 %14, float %15, float %16), !dbg !213
  br label %26, !dbg !197

17:                                               ; preds = %0
  call void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 0, i16 21), !dbg !214
  %18 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !215
  %19 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_px, align 2, !dbg !216
  %20 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_py, align 2, !dbg !217
  %21 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_w, align 2, !dbg !218
  %22 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_h, align 2, !dbg !219
  %23 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_addr, align 2, !dbg !220
  %24 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_pe_length, align 2, !dbg !221
  %25 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_is_half, align 2, !dbg !222
  call void @sys_mod.sys_mod.memcpyd2h_mod.d2h_configure(i16 %18, i16 %19, i16 %20, i16 %21, i16 %22, i16 %23, i16 %24, i16 %25), !dbg !223
  br label %26, !dbg !197

26:                                               ; preds = %2, %17
  call void @__generic0sys_mod.sys_mod.tile_config.queue_flush.exit(), !dbg !224
  ret void, !dbg !197
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

define void @sys_mod.sys_mod.f_rpc(i16 %0) #4 !dbg !225 {
  %2 = alloca i16, i16 1, align 2, !dbg !226
  store i16 %0, i16* %2, align 2, !dbg !226
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !228
  %3 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !229
  %4 = icmp sge i16 %3, 4, !dbg !230
  br i1 %4, label %5, label %6, !dbg !231

5:                                                ; preds = %1
  br label %7, !dbg !231

6:                                                ; preds = %1
  call void asm sideeffect "hcf", ""(), !dbg !231
  br label %7, !dbg !231

7:                                                ; preds = %5, %6
  call void @rpc_server(i32* getelementptr inbounds ([32 x i32], [32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32, i32 0, i32 0)), !dbg !232
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !233
  ret void, !dbg !234
}

define internal void @sys_mod.sys_mod.sys_mod.stack_push(i16 %0) !dbg !235 {
  %2 = alloca i16*, i16 1, align 8, !dbg !237
  %3 = alloca i16, i16 1, align 2, !dbg !239
  store i16 %0, i16* %3, align 2, !dbg !239
  %4 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !240
  %5 = icmp slt i16 %4, 32, !dbg !241
  br i1 %5, label %6, label %7, !dbg !242

6:                                                ; preds = %1
  br label %8, !dbg !242

7:                                                ; preds = %1
  call void asm sideeffect "hcf", ""(), !dbg !242
  br label %8, !dbg !242

8:                                                ; preds = %6, %7
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %2, align 8, !dbg !237
  %9 = load i16, i16* %3, align 2, !dbg !243
  %10 = load i16*, i16** %2, align 8, !dbg !244
  %11 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !245
  %12 = getelementptr i16, i16* %10, i16 %11, !dbg !246
  store i16 %9, i16* %12, align 2, !dbg !247
  %13 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !248
  %14 = add i16 %13, 1, !dbg !249
  store i16 %14, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !250
  ret void, !dbg !251
}

define void @sys_mod.sys_mod.sys_mod.f_push(i16 %0, i16 %1) #5 !dbg !252 {
  %3 = alloca i16, i16 1, align 2, !dbg !253
  %4 = alloca i16, i16 1, align 2, !dbg !255
  store i16 %0, i16* %4, align 2, !dbg !255
  store i16 %1, i16* %3, align 2, !dbg !253
  %5 = load i16, i16* %4, align 2, !dbg !256
  call void @sys_mod.sys_mod.sys_mod.stack_push(i16 %5), !dbg !257
  ret void, !dbg !258
}

define internal void @sys_mod.sys_mod.sys_mod.block_cmd_stream() !dbg !259 {
  call void @llvm.sdr.blk.r(i16 1), !dbg !260
  ret void, !dbg !262
}

define internal void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream() !dbg !263 {
  call void @llvm.sdr.ublk.r(i16 1), !dbg !264
  ret void, !dbg !266
}

define void @sys_mod.sys_mod.sys_mod.f_sys_exit() #6 !dbg !267 {
  call void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream(), !dbg !268
  call void @sys_mod.sys_nop(), !dbg !270
  ret void, !dbg !271
}

define void @sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore(i32 %0) #7 !dbg !272 {
  %2 = alloca i32, i16 1, align 4, !dbg !273
  store i32 %0, i32* %2, align 4, !dbg !273
  ret void, !dbg !275
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord() !dbg !276 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord(), !dbg !278
  ret i16 %1, !dbg !280
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord() !dbg !281 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord(), !dbg !282
  ret i16 %1, !dbg !284
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval(i16 %0) !dbg !285 {
  %2 = alloca i16, i16 1, align 2, !dbg !286
  store i16 %0, i16* %2, align 2, !dbg !286
  %3 = load i16, i16* %2, align 2, !dbg !288
  %4 = icmp ult i16 %3, 24, !dbg !289
  br i1 %4, label %5, label %7, !dbg !290

5:                                                ; preds = %10, %11, %1
  %6 = phi i16 [ 0, %10 ], [ 0, %11 ], [ 1, %1 ]
  br label %12, !dbg !290

7:                                                ; preds = %1
  %8 = load i16, i16* %2, align 2, !dbg !291
  %9 = icmp eq i16 31, %8, !dbg !292
  br i1 %9, label %10, label %11, !dbg !293

10:                                               ; preds = %7
  br label %5, !dbg !293

11:                                               ; preds = %7
  call void asm sideeffect "hcf", ""(), !dbg !293
  br label %5, !dbg !293

12:                                               ; preds = %5
  %13 = phi i16 [ %6, %5 ]
  br label %14, !dbg !290

14:                                               ; preds = %12
  ret i16 %13, !dbg !290
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start(i16 %0, i16 %1, i16 %2) !dbg !294 {
  %4 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !295
  %5 = alloca i16, i16 1, align 2, !dbg !297
  %6 = alloca i16, i16 1, align 2, !dbg !298
  %7 = alloca i16, i16 1, align 2, !dbg !299
  store i16 %0, i16* %7, align 2, !dbg !299
  store i16 %1, i16* %6, align 2, !dbg !298
  store i16 %2, i16* %5, align 2, !dbg !297
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !300
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !300
  %10 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !300
  %11 = load i16, i16* %6, align 2, !dbg !301
  store i16 %11, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !302
  store i16 %8, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !302
  store i16 %9, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !302
  store i16 %10, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !302
  %12 = load i16, i16* %7, align 2, !dbg !303
  %13 = call i16* @.get_tensor_ptr(i16 %12), !dbg !304
  %14 = ptrtoint i16* %13 to i16, !dbg !305
  %15 = lshr i16 %14, 1, !dbg !305
  %16 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !295
  store i16 42, i16* %16, align 2, !dbg !295
  %17 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !295
  store i16 %15, i16* %17, align 2, !dbg !295
  %18 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !295
  store i16 143, i16* %18, align 2, !dbg !295
  %19 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !295
  store i16 16, i16* %19, align 2, !dbg !295
  %20 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !306
  %21 = load i16, i16* %20, align 2, !dbg !306
  %22 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !306
  %23 = load i16, i16* %22, align 2, !dbg !306
  %24 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !306
  %25 = load i16, i16* %24, align 2, !dbg !306
  %26 = load i16, i16* %6, align 2, !dbg !307
  %27 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !308
  store i16 %26, i16* %27, align 2, !dbg !308
  %28 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !308
  store i16 %21, i16* %28, align 2, !dbg !308
  %29 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !308
  store i16 %23, i16* %29, align 2, !dbg !308
  %30 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !308
  store i16 %25, i16* %30, align 2, !dbg !308
  %31 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !309
  %32 = load i16, i16* %31, align 2, !dbg !309
  %33 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !309
  %34 = load i16, i16* %33, align 2, !dbg !309
  %35 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !309
  %36 = load i16, i16* %35, align 2, !dbg !309
  %37 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !309
  %38 = load i16, i16* %37, align 2, !dbg !309
  store volatile i16 %32, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !310
  store volatile i16 %34, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !310
  store volatile i16 %36, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !310
  store volatile i16 %38, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !310
  call void asm sideeffect "nop", ""(), !dbg !310
  call void asm sideeffect "nop", ""(), !dbg !310
  %39 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !311
  %40 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !311
  %41 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !311
  %42 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !311
  %43 = and i16 %41, -193, !dbg !311
  %44 = or i16 %43, 128, !dbg !311
  %45 = and i16 %40, -64, !dbg !311
  %46 = or i16 %45, 27, !dbg !311
  store volatile i16 %39, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !312
  store volatile i16 %46, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !312
  store volatile i16 %44, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !312
  store volatile i16 %42, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !312
  call void asm sideeffect "nop", ""(), !dbg !312
  call void asm sideeffect "nop", ""(), !dbg !312
  %47 = load i16, i16* %5, align 2, !dbg !313
  %48 = icmp ult i16 0, %47, !dbg !314
  br i1 %48, label %49, label %50, !dbg !315

49:                                               ; preds = %3
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !316
  br label %51, !dbg !315

50:                                               ; preds = %3
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !317
  br label %51, !dbg !315

51:                                               ; preds = %49, %50
  ret void, !dbg !315
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream() !dbg !318 {
  call void @llvm.sdr.ublk.r(i16 1), !dbg !319
  ret void, !dbg !321
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7, i16 %8, i16 %9, i16 %10, float %11, float %12) !dbg !322 {
  %14 = alloca i16, i16 1, align 2, !dbg !323
  %15 = alloca i16, i16 1, align 2, !dbg !325
  %16 = alloca i16, i16 1, align 2, !dbg !326
  %17 = alloca i16, i16 1, align 2, !dbg !327
  %18 = alloca i16, i16 1, align 2, !dbg !328
  %19 = alloca i1, i16 1, align 1, !dbg !329
  %20 = alloca i16, i16 1, align 2, !dbg !330
  %21 = alloca i16, i16 1, align 2, !dbg !331
  %22 = alloca i16, i16 1, align 2, !dbg !332
  %23 = alloca i16, i16 1, align 2, !dbg !333
  %24 = alloca i16, i16 1, align 2, !dbg !334
  %25 = alloca float, i16 1, align 4, !dbg !335
  %26 = alloca float, i16 1, align 4, !dbg !336
  %27 = alloca i16, i16 1, align 2, !dbg !337
  %28 = alloca i16, i16 1, align 2, !dbg !338
  %29 = alloca i16, i16 1, align 2, !dbg !339
  %30 = alloca i16, i16 1, align 2, !dbg !340
  %31 = alloca i16, i16 1, align 2, !dbg !341
  %32 = alloca i16, i16 1, align 2, !dbg !342
  %33 = alloca i16, i16 1, align 2, !dbg !343
  %34 = alloca i16, i16 1, align 2, !dbg !344
  %35 = alloca i16, i16 1, align 2, !dbg !345
  %36 = alloca i16, i16 1, align 2, !dbg !346
  %37 = alloca i16, i16 1, align 2, !dbg !347
  store i16 %0, i16* %37, align 2, !dbg !347
  store i16 %1, i16* %36, align 2, !dbg !346
  store i16 %2, i16* %35, align 2, !dbg !345
  store i16 %3, i16* %34, align 2, !dbg !344
  store i16 %4, i16* %33, align 2, !dbg !343
  store i16 %5, i16* %32, align 2, !dbg !342
  store i16 %6, i16* %31, align 2, !dbg !341
  store i16 %7, i16* %30, align 2, !dbg !340
  store i16 %8, i16* %29, align 2, !dbg !339
  store i16 %9, i16* %28, align 2, !dbg !338
  store i16 %10, i16* %27, align 2, !dbg !337
  store float %11, float* %26, align 4, !dbg !336
  store float %12, float* %25, align 4, !dbg !335
  %38 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord(), !dbg !348
  store i16 %38, i16* %24, align 2, !dbg !334
  %39 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord(), !dbg !349
  store i16 %39, i16* %23, align 2, !dbg !333
  %40 = load i16, i16* %24, align 2, !dbg !350
  %41 = load i16, i16* %36, align 2, !dbg !351
  %42 = sub i16 %40, %41, !dbg !352
  store i16 %42, i16* %22, align 2, !dbg !332
  %43 = load i16, i16* %22, align 2, !dbg !353
  store i16 %43, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !354
  %44 = load i16, i16* %29, align 2, !dbg !355
  %45 = icmp eq i16 3, %44, !dbg !356
  br i1 %45, label %46, label %63, !dbg !357

46:                                               ; preds = %13
  %47 = load i16, i16* %22, align 2, !dbg !358
  %48 = sitofp i16 %47 to float, !dbg !359
  %49 = load float, float* %26, align 4, !dbg !360
  %50 = fmul float %48, %49, !dbg !361
  %51 = fptosi float %50 to i16, !dbg !362
  store i16 %51, i16* %21, align 2, !dbg !331
  %52 = load i16, i16* %22, align 2, !dbg !363
  %53 = load i16, i16* %21, align 2, !dbg !364
  %54 = load i16, i16* %28, align 2, !dbg !365
  %55 = mul i16 %53, %54, !dbg !366
  %56 = sub i16 %52, %55, !dbg !367
  store i16 %56, i16* %20, align 2, !dbg !330
  %57 = load i16, i16* %20, align 2, !dbg !368
  %58 = icmp ne i16 0, %57, !dbg !369
  br i1 %58, label %59, label %60, !dbg !370

59:                                               ; preds = %46
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !371
  br label %62, !dbg !370

60:                                               ; preds = %46
  %61 = load i16, i16* %21, align 2, !dbg !372
  store i16 %61, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !373
  br label %62, !dbg !370

62:                                               ; preds = %59, %60
  br label %63, !dbg !357

63:                                               ; preds = %62, %13
  %64 = load i16, i16* %22, align 2, !dbg !374
  %65 = icmp slt i16 %64, 0, !dbg !375
  br i1 %65, label %66, label %67, !dbg !376

66:                                               ; preds = %63
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !377
  br label %67, !dbg !376

67:                                               ; preds = %66, %63
  %68 = load i16, i16* %22, align 2, !dbg !378
  %69 = load i16, i16* %34, align 2, !dbg !379
  %70 = icmp sge i16 %68, %69, !dbg !380
  br i1 %70, label %71, label %72, !dbg !381

71:                                               ; preds = %67
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !382
  br label %72, !dbg !381

72:                                               ; preds = %71, %67
  store i1 false, i1* %19, align 1, !dbg !329
  %73 = load i16, i16* %29, align 2, !dbg !383
  %74 = icmp eq i16 3, %73, !dbg !384
  br i1 %74, label %75, label %94, !dbg !385

75:                                               ; preds = %72
  %76 = load i16, i16* %23, align 2, !dbg !386
  %77 = load i16, i16* %35, align 2, !dbg !387
  %78 = sub i16 %76, %77, !dbg !388
  %79 = sitofp i16 %78 to float, !dbg !389
  %80 = load float, float* %25, align 4, !dbg !390
  %81 = fmul float %79, %80, !dbg !391
  %82 = fptosi float %81 to i16, !dbg !392
  store i16 %82, i16* %18, align 2, !dbg !328
  %83 = load i16, i16* %23, align 2, !dbg !393
  %84 = load i16, i16* %35, align 2, !dbg !394
  %85 = sub i16 %83, %84, !dbg !395
  %86 = load i16, i16* %18, align 2, !dbg !396
  %87 = load i16, i16* %27, align 2, !dbg !397
  %88 = mul i16 %86, %87, !dbg !398
  %89 = sub i16 %85, %88, !dbg !399
  store i16 %89, i16* %17, align 2, !dbg !327
  %90 = load i16, i16* %17, align 2, !dbg !400
  %91 = icmp ne i16 0, %90, !dbg !401
  br i1 %91, label %92, label %93, !dbg !402

92:                                               ; preds = %75
  store i1 true, i1* %19, align 1, !dbg !403
  br label %93, !dbg !402

93:                                               ; preds = %92, %75
  br label %94, !dbg !385

94:                                               ; preds = %93, %72
  %95 = load i16, i16* %23, align 2, !dbg !404
  %96 = load i16, i16* %35, align 2, !dbg !405
  %97 = icmp slt i16 %95, %96, !dbg !406
  br i1 %97, label %98, label %99, !dbg !407

98:                                               ; preds = %94
  store i1 true, i1* %19, align 1, !dbg !408
  br label %99, !dbg !407

99:                                               ; preds = %98, %94
  %100 = load i16, i16* %23, align 2, !dbg !409
  %101 = load i16, i16* %35, align 2, !dbg !410
  %102 = load i16, i16* %33, align 2, !dbg !411
  %103 = add i16 %101, %102, !dbg !412
  %104 = icmp sge i16 %100, %103, !dbg !413
  br i1 %104, label %105, label %106, !dbg !414

105:                                              ; preds = %99
  store i1 true, i1* %19, align 1, !dbg !415
  br label %106, !dbg !414

106:                                              ; preds = %105, %99
  %107 = load i1, i1* %19, align 1, !dbg !416
  br i1 %107, label %108, label %109, !dbg !417

108:                                              ; preds = %106
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream(), !dbg !418
  call void @llvm.sdr.ublk.r(i16 27), !dbg !419
  br label %180, !dbg !417

109:                                              ; preds = %106
  %110 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !420
  %111 = icmp eq i16 -1, %110, !dbg !421
  br i1 %111, label %112, label %113, !dbg !422

112:                                              ; preds = %109
  call void @__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction(i16 31767), !dbg !423
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 23), !dbg !424
  call void @llvm.sdr.ublk.r(i16 27), !dbg !425
  br label %179, !dbg !422

113:                                              ; preds = %109
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter(i16 0, i16 0), !dbg !426
  %114 = load i16, i16* %34, align 2, !dbg !427
  store i16 %114, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !428
  %115 = load i16, i16* %29, align 2, !dbg !429
  %116 = icmp eq i16 3, %115, !dbg !430
  br i1 %116, label %117, label %126, !dbg !431

117:                                              ; preds = %113
  %118 = load i16, i16* %34, align 2, !dbg !432
  %119 = sub i16 %118, 1, !dbg !433
  %120 = sitofp i16 %119 to float, !dbg !434
  %121 = load float, float* %26, align 4, !dbg !435
  %122 = fmul float %120, %121, !dbg !436
  %123 = fptosi float %122 to i16, !dbg !437
  %124 = add i16 %123, 1, !dbg !438
  store i16 %124, i16* %16, align 2, !dbg !326
  %125 = load i16, i16* %16, align 2, !dbg !439
  store i16 %125, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !440
  br label %131, !dbg !431

126:                                              ; preds = %113
  %127 = load i16, i16* %29, align 2, !dbg !441
  %128 = icmp eq i16 1, %127, !dbg !442
  br i1 %128, label %129, label %130, !dbg !443

129:                                              ; preds = %126
  store i16 1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !444
  br label %130, !dbg !443

130:                                              ; preds = %129, %126
  br label %131, !dbg !431

131:                                              ; preds = %117, %130
  %132 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !445
  %133 = sub i16 %132, 1, !dbg !446
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit(i16 0, i16 %133), !dbg !447
  %134 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !448
  store i16 %134, i16* %15, align 2, !dbg !325
  %135 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !449
  store i16 %135, i16* %14, align 2, !dbg !323
  %136 = load i16, i16* %15, align 2, !dbg !450
  %137 = load i16, i16* %14, align 2, !dbg !451
  %138 = sub i16 %136, %137, !dbg !452
  store i16 %138, i16* %15, align 2, !dbg !453
  %139 = load i16, i16* %14, align 2, !dbg !454
  %140 = icmp eq i16 0, %139, !dbg !455
  br i1 %140, label %141, label %142, !dbg !456

141:                                              ; preds = %131
  store i16 0, i16* %15, align 2, !dbg !457
  br label %142, !dbg !456

142:                                              ; preds = %141, %131
  %143 = load i16, i16* %29, align 2, !dbg !458
  %144 = icmp eq i16 1, %143, !dbg !459
  br i1 %144, label %145, label %146, !dbg !460

145:                                              ; preds = %142
  store i16 0, i16* %15, align 2, !dbg !461
  br label %146, !dbg !460

146:                                              ; preds = %145, %142
  %147 = load i16, i16* %15, align 2, !dbg !462
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter(i16 0, i16 %147), !dbg !463
  call void @__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction(i16 31767), !dbg !464
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 23), !dbg !465
  %148 = load i16, i16* %37, align 2, !dbg !466
  %149 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval(i16 %148), !dbg !467
  %150 = icmp eq i16 0, %149, !dbg !468
  br i1 %150, label %151, label %155, !dbg !469

151:                                              ; preds = %146
  %152 = load i16, i16* %32, align 2, !dbg !470
  %153 = load i16, i16* %31, align 2, !dbg !471
  %154 = load i16, i16* %30, align 2, !dbg !472
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start(i16 %152, i16 %153, i16 %154), !dbg !473
  br label %178, !dbg !469

155:                                              ; preds = %146
  %156 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !474
  %157 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !474
  %158 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !474
  %159 = load i16, i16* %31, align 2, !dbg !475
  store i16 %159, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !476
  store i16 %156, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !476
  store i16 %157, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !476
  store i16 %158, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !476
  %160 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !477
  %161 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !477
  %162 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !477
  %163 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !477
  %164 = and i16 %162, -193, !dbg !477
  %165 = or i16 %164, 128, !dbg !477
  store volatile i16 %160, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !478
  store volatile i16 %161, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !478
  store volatile i16 %165, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !478
  store volatile i16 %163, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !478
  call void asm sideeffect "nop", ""(), !dbg !478
  call void asm sideeffect "nop", ""(), !dbg !478
  %166 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !479
  %167 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !479
  %168 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !479
  %169 = load i16, i16* %31, align 2, !dbg !480
  store i16 %169, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !481
  store i16 %166, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !481
  store i16 %167, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !481
  store i16 %168, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !481
  %170 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !482
  %171 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !482
  %172 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !482
  %173 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !482
  %174 = and i16 %172, -193, !dbg !482
  %175 = or i16 %174, 128, !dbg !482
  %176 = and i16 %171, -64, !dbg !482
  %177 = or i16 %176, 27, !dbg !482
  store volatile i16 %170, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !483
  store volatile i16 %177, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !483
  store volatile i16 %175, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !483
  store volatile i16 %173, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !483
  call void asm sideeffect "nop", ""(), !dbg !483
  call void asm sideeffect "nop", ""(), !dbg !483
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !484
  br label %178, !dbg !469

178:                                              ; preds = %151, %155
  br label %179, !dbg !422

179:                                              ; preds = %112, %178
  br label %180, !dbg !417

180:                                              ; preds = %108, %179
  ret void, !dbg !357
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit(i16 %0, i16 %1) !dbg !485 {
  %3 = alloca i16, i16 1, align 2, !dbg !487
  %4 = alloca i16, i16 1, align 2, !dbg !489
  %5 = alloca i16, i16 1, align 2, !dbg !490
  %6 = alloca i16, i16 1, align 2, !dbg !491
  %7 = alloca i16, i16 1, align 2, !dbg !492
  %8 = alloca i16, i16 1, align 2, !dbg !493
  store i16 %0, i16* %8, align 2, !dbg !493
  store i16 %1, i16* %7, align 2, !dbg !492
  %9 = load i16, i16* %7, align 2, !dbg !494
  %10 = icmp ult i16 %9, -32768, !dbg !495
  br i1 %10, label %11, label %12, !dbg !496

11:                                               ; preds = %2
  br label %13, !dbg !496

12:                                               ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !496
  br label %13, !dbg !496

13:                                               ; preds = %11, %12
  %14 = load i16, i16* %7, align 2, !dbg !497
  %15 = mul i16 %14, 2, !dbg !498
  store i16 %15, i16* %6, align 2, !dbg !491
  %16 = load i16, i16* %8, align 2, !dbg !499
  %17 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %16, i16 8), !dbg !500
  %18 = sub i16 %17, 1, !dbg !501
  store i16 %18, i16* %5, align 2, !dbg !490
  %19 = load i16, i16* %6, align 2, !dbg !502
  %20 = load i16, i16* %5, align 2, !dbg !503
  %21 = icmp ult i16 %19, %20, !dbg !504
  br i1 %21, label %22, label %23, !dbg !489

22:                                               ; preds = %13
  store i16 0, i16* %4, align 2, !dbg !489
  br label %27, !dbg !489

23:                                               ; preds = %13
  %24 = load i16, i16* %6, align 2, !dbg !505
  %25 = load i16, i16* %5, align 2, !dbg !506
  %26 = sub i16 %24, %25, !dbg !507
  store i16 %26, i16* %4, align 2, !dbg !489
  br label %27, !dbg !489

27:                                               ; preds = %22, %23
  %28 = load i16, i16* %4, align 2, !dbg !489
  store i16 %28, i16* %3, align 2, !dbg !487
  %29 = load i16, i16* %8, align 2, !dbg !508
  %30 = load i16, i16* %3, align 2, !dbg !509
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %29, i16 4, i16 %30), !dbg !510
  ret void, !dbg !489
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter(i16 %0, i16 %1) !dbg !511 {
  %3 = alloca i16, i16 1, align 2, !dbg !512
  %4 = alloca i16, i16 1, align 2, !dbg !514
  store i16 %0, i16* %4, align 2, !dbg !514
  store i16 %1, i16* %3, align 2, !dbg !512
  %5 = load i16, i16* %3, align 2, !dbg !515
  %6 = icmp ult i16 %5, -32768, !dbg !516
  br i1 %6, label %7, label %8, !dbg !517

7:                                                ; preds = %2
  br label %9, !dbg !517

8:                                                ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !517
  br label %9, !dbg !517

9:                                                ; preds = %7, %8
  %10 = load i16, i16* %4, align 2, !dbg !518
  %11 = load i16, i16* %3, align 2, !dbg !519
  %12 = mul i16 %11, 2, !dbg !520
  %13 = add i16 %12, 1, !dbg !521
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %10, i16 8, i16 %13), !dbg !522
  ret void, !dbg !523
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter(i16 %0, i16 %1) !dbg !524 {
  %3 = alloca i16, i16 1, align 2, !dbg !525
  %4 = alloca i16, i16 1, align 2, !dbg !527
  %5 = alloca i1, i16 1, align 1, !dbg !528
  %6 = alloca i16, i16 1, align 2, !dbg !529
  %7 = alloca i16, i16 1, align 2, !dbg !530
  %8 = alloca i16, i16 1, align 2, !dbg !531
  %9 = alloca i16, i16 1, align 2, !dbg !532
  store i16 %0, i16* %9, align 2, !dbg !532
  store i16 %1, i16* %8, align 2, !dbg !531
  %10 = load i16, i16* %8, align 2, !dbg !533
  %11 = icmp ult i16 %10, -32768, !dbg !534
  br i1 %11, label %12, label %13, !dbg !535

12:                                               ; preds = %2
  br label %14, !dbg !535

13:                                               ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !535
  br label %14, !dbg !535

14:                                               ; preds = %12, %13
  %15 = load i16, i16* %9, align 2, !dbg !536
  %16 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %15, i16 8), !dbg !537
  store i16 %16, i16* %7, align 2, !dbg !530
  %17 = load i16, i16* %8, align 2, !dbg !538
  %18 = mul i16 %17, 2, !dbg !539
  store i16 %18, i16* %6, align 2, !dbg !529
  %19 = load i16, i16* %6, align 2, !dbg !540
  %20 = load i16, i16* %7, align 2, !dbg !541
  %21 = icmp ugt i16 %19, %20, !dbg !542
  store i1 %21, i1* %5, align 1, !dbg !528
  %22 = load i16, i16* %9, align 2, !dbg !543
  %23 = load i1, i1* %5, align 1, !dbg !544
  %24 = zext i1 %23 to i16, !dbg !545
  %25 = shl i16 %24, 6, !dbg !546
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %22, i16 14, i16 %25), !dbg !547
  %26 = load i1, i1* %5, align 1, !dbg !548
  br i1 %26, label %27, label %32, !dbg !527

27:                                               ; preds = %14
  %28 = load i16, i16* %6, align 2, !dbg !549
  %29 = load i16, i16* %7, align 2, !dbg !550
  %30 = sub i16 %28, %29, !dbg !551
  %31 = add i16 %30, 1, !dbg !552
  store i16 %31, i16* %4, align 2, !dbg !527
  br label %34, !dbg !527

32:                                               ; preds = %14
  %33 = load i16, i16* %6, align 2, !dbg !553
  store i16 %33, i16* %4, align 2, !dbg !527
  br label %34, !dbg !527

34:                                               ; preds = %27, %32
  %35 = load i16, i16* %4, align 2, !dbg !527
  store i16 %35, i16* %3, align 2, !dbg !525
  %36 = load i16, i16* %9, align 2, !dbg !554
  %37 = load i16, i16* %3, align 2, !dbg !555
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %36, i16 12, i16 %37), !dbg !556
  ret void, !dbg !527
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %0, i16 %1, i16 %2) !dbg !557 {
  %4 = alloca i16, i16 1, align 2, !dbg !559
  %5 = alloca i16, i16 1, align 2, !dbg !561
  %6 = alloca i16, i16 1, align 2, !dbg !562
  store i16 %0, i16* %6, align 2, !dbg !562
  store i16 %1, i16* %5, align 2, !dbg !561
  store i16 %2, i16* %4, align 2, !dbg !559
  %7 = load i16, i16* %6, align 2, !dbg !563
  %8 = getelementptr [6 x i16], [6 x i16]* @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.filters, i16 0, i16 %7, !dbg !564
  %9 = load i16, i16* %8, align 2, !dbg !564
  %10 = load i16, i16* %5, align 2, !dbg !565
  %11 = add i16 %9, %10, !dbg !566
  %12 = lshr i16 %11, 1, !dbg !567
  %13 = load i16, i16* %4, align 2, !dbg !568
  %14 = shl i16 %12, 1, !dbg !569
  %15 = inttoptr i16 %14 to i16*, !dbg !569
  store volatile i16 %13, i16* %15, align 2, !dbg !569
  call void asm sideeffect "nop", ""(), !dbg !569
  call void asm sideeffect "nop", ""(), !dbg !569
  ret void, !dbg !570
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %0, i16 %1) !dbg !571 {
  %3 = alloca i16, i16 1, align 2, !dbg !572
  %4 = alloca i16, i16 1, align 2, !dbg !574
  store i16 %0, i16* %4, align 2, !dbg !574
  store i16 %1, i16* %3, align 2, !dbg !572
  %5 = load i16, i16* %4, align 2, !dbg !575
  %6 = getelementptr [6 x i16], [6 x i16]* @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.filters, i16 0, i16 %5, !dbg !576
  %7 = load i16, i16* %6, align 2, !dbg !576
  %8 = load i16, i16* %3, align 2, !dbg !577
  %9 = add i16 %7, %8, !dbg !578
  %10 = lshr i16 %9, 1, !dbg !579
  %11 = shl i16 %10, 1, !dbg !580
  %12 = inttoptr i16 %11 to i16*, !dbg !580
  call void asm sideeffect "nop", ""(), !dbg !580
  call void asm sideeffect "nop", ""(), !dbg !580
  %13 = load volatile i16, i16* %12, align 2, !dbg !580
  ret i16 %13, !dbg !581
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 %0) !dbg !582 {
  %2 = alloca i16, i16 1, align 2, !dbg !584
  %3 = alloca i16, i16 1, align 2, !dbg !586
  %4 = alloca i16, i16 1, align 2, !dbg !587
  %5 = alloca i16, i16 1, align 2, !dbg !588
  store i16 %0, i16* %5, align 2, !dbg !588
  %6 = load i16, i16* %5, align 2, !dbg !589
  store i16 %6, i16* %4, align 2, !dbg !587
  %7 = load i16, i16* %4, align 2, !dbg !590
  %8 = add i16 %7, 31744, !dbg !591
  store i16 %8, i16* %3, align 2, !dbg !586
  %9 = load i16, i16* %3, align 2, !dbg !592
  %10 = shl i16 %9, 1, !dbg !593
  %11 = inttoptr i16 %10 to i16*, !dbg !593
  call void asm sideeffect "nop", ""(), !dbg !593
  call void asm sideeffect "nop", ""(), !dbg !593
  %12 = load volatile i16, i16* %11, align 2, !dbg !593
  store i16 %12, i16* %2, align 2, !dbg !584
  %13 = load i16, i16* %3, align 2, !dbg !594
  %14 = load i16, i16* %2, align 2, !dbg !595
  %15 = and i16 %14, 32767, !dbg !596
  %16 = shl i16 %13, 1, !dbg !597
  %17 = inttoptr i16 %16 to i16*, !dbg !597
  store volatile i16 %15, i16* %17, align 2, !dbg !597
  call void asm sideeffect "nop", ""(), !dbg !597
  call void asm sideeffect "nop", ""(), !dbg !597
  ret void, !dbg !598
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord() !dbg !599 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 2), !dbg !601
  %2 = sub i16 %1, 4, !dbg !603
  ret i16 %2, !dbg !604
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord() !dbg !605 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 0), !dbg !606
  %2 = sub i16 %1, 1, !dbg !608
  ret i16 %2, !dbg !609
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 %0) !dbg !610 {
  %2 = alloca i16, i16 1, align 2, !dbg !612
  %3 = alloca i16, i16 1, align 2, !dbg !614
  store i16 %0, i16* %3, align 2, !dbg !614
  %4 = load i16, i16* %3, align 2, !dbg !615
  %5 = lshr i16 %4, 1, !dbg !616
  %6 = add i16 %5, 31813, !dbg !617
  %7 = shl i16 %6, 1, !dbg !618
  %8 = inttoptr i16 %7 to i16*, !dbg !618
  call void asm sideeffect "nop", ""(), !dbg !618
  call void asm sideeffect "nop", ""(), !dbg !618
  %9 = load volatile i16, i16* %8, align 2, !dbg !618
  store i16 %9, i16* %2, align 2, !dbg !612
  %10 = load i16, i16* %2, align 2, !dbg !619
  %11 = and i16 %10, 2047, !dbg !620
  ret i16 %11, !dbg !621
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord() !dbg !622 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord(), !dbg !624
  ret i16 %1, !dbg !626
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.get_y_coord() !dbg !627 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord(), !dbg !628
  ret i16 %1, !dbg !630
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval(i16 %0) !dbg !631 {
  %2 = alloca i16, i16 1, align 2, !dbg !632
  store i16 %0, i16* %2, align 2, !dbg !632
  %3 = load i16, i16* %2, align 2, !dbg !634
  %4 = icmp ult i16 %3, 24, !dbg !635
  br i1 %4, label %5, label %7, !dbg !636

5:                                                ; preds = %10, %11, %1
  %6 = phi i16 [ 0, %10 ], [ 0, %11 ], [ 1, %1 ]
  br label %12, !dbg !636

7:                                                ; preds = %1
  %8 = load i16, i16* %2, align 2, !dbg !637
  %9 = icmp eq i16 31, %8, !dbg !638
  br i1 %9, label %10, label %11, !dbg !639

10:                                               ; preds = %7
  br label %5, !dbg !639

11:                                               ; preds = %7
  call void asm sideeffect "hcf", ""(), !dbg !639
  br label %5, !dbg !639

12:                                               ; preds = %5
  %13 = phi i16 [ %6, %5 ]
  br label %14, !dbg !636

14:                                               ; preds = %12
  ret i16 %13, !dbg !636
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7) !dbg !640 {
  %9 = alloca i16, i16 1, align 2, !dbg !641
  %10 = alloca i16, i16 1, align 2, !dbg !643
  %11 = alloca i16, i16 1, align 2, !dbg !644
  %12 = alloca i16, i16 1, align 2, !dbg !645
  %13 = alloca i16, i16 1, align 2, !dbg !646
  %14 = alloca i16, i16 1, align 2, !dbg !647
  %15 = alloca i16, i16 1, align 2, !dbg !648
  %16 = alloca i16, i16 1, align 2, !dbg !649
  %17 = alloca i16, i16 1, align 2, !dbg !650
  store i16 %0, i16* %17, align 2, !dbg !650
  store i16 %1, i16* %16, align 2, !dbg !649
  store i16 %2, i16* %15, align 2, !dbg !648
  store i16 %3, i16* %14, align 2, !dbg !647
  store i16 %4, i16* %13, align 2, !dbg !646
  store i16 %5, i16* %12, align 2, !dbg !645
  store i16 %6, i16* %11, align 2, !dbg !644
  store i16 %7, i16* %10, align 2, !dbg !643
  %18 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !651
  store i16 %18, i16* %9, align 2, !dbg !641
  %19 = load i16, i16* %11, align 2, !dbg !652
  store i16 %19, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_c, align 2, !dbg !653
  %20 = load i16, i16* %10, align 2, !dbg !654
  store i16 %20, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_is_half, align 2, !dbg !655
  %21 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_c, align 2, !dbg !656
  %22 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval(i16 %21), !dbg !657
  store i16 %22, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !658
  store i16 0, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !659
  %23 = load i16, i16* %16, align 2, !dbg !660
  store i16 %23, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !661
  %24 = load i16, i16* %15, align 2, !dbg !662
  store i16 %24, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !663
  %25 = load i16, i16* %15, align 2, !dbg !664
  %26 = load i16, i16* %13, align 2, !dbg !665
  %27 = add i16 %25, %26, !dbg !666
  %28 = sub i16 %27, 1, !dbg !667
  store i16 %28, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_last, align 2, !dbg !668
  %29 = load i16, i16* %9, align 2, !dbg !669
  %30 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_last, align 2, !dbg !670
  %31 = icmp eq i16 %29, %30, !dbg !671
  br i1 %31, label %32, label %37, !dbg !672

32:                                               ; preds = %8
  %33 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !673
  %34 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !673
  %35 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !673
  store i16 %33, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !674
  store i16 lshr (i16 ptrtoint ([1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.ctrl_1 to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !674
  store i16 %34, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !674
  store i16 %35, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !674
  %36 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.ctrl_1, i16 0, i1 false), align 4, !dbg !675
  store i32 %36, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i1 false), align 4, !dbg !676
  br label %42, !dbg !672

37:                                               ; preds = %8
  %38 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !677
  %39 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !677
  %40 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !677
  store i16 %38, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !678
  store i16 lshr (i16 ptrtoint ([1 x i32]* @"$$csl_base_address$$0$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11" to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !678
  store i16 %39, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !678
  store i16 %40, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !678
  %41 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @"$$csl_base_address$$0$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11", i16 0, i1 false), align 4, !dbg !679
  store i32 %41, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i1 false), align 4, !dbg !680
  br label %42, !dbg !672

42:                                               ; preds = %32, %37
  store i32 165646921, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i2 1), align 4, !dbg !681
  %43 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !682
  %44 = icmp eq i16 0, %43, !dbg !683
  br i1 %44, label %45, label %56, !dbg !684

45:                                               ; preds = %42
  %46 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !685
  %47 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !685
  %48 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !685
  %49 = load i16, i16* %17, align 2, !dbg !686
  %50 = call i16* @.get_tensor_ptr(i16 %49), !dbg !687
  %51 = ptrtoint i16* %50 to i16, !dbg !688
  %52 = lshr i16 %51, 1, !dbg !688
  store i16 %46, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !689
  store i16 %52, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !689
  store i16 %47, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !689
  store i16 %48, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !689
  %53 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !690
  %54 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !690
  %55 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !690
  store i16 1, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !691
  store i16 %53, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !691
  store i16 %54, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !691
  store i16 %55, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !691
  call void @llvm.sdr.actvt.r(i16 21), !dbg !692
  br label %63, !dbg !684

56:                                               ; preds = %42
  %57 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !693
  %58 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !693
  %59 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !693
  store i16 %57, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !694
  store i16 lshr (i16 ptrtoint ([1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.data_buf to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !694
  store i16 %58, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !694
  store i16 %59, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !694
  %60 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !695
  %61 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !695
  %62 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !695
  store i16 1, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !696
  store i16 %60, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !696
  store i16 %61, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !696
  store i16 %62, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !696
  call void @llvm.sdr.ublk.r(i16 0), !dbg !697
  br label %63, !dbg !684

63:                                               ; preds = %45, %56
  ret void, !dbg !672
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x(i32 %0) #8 !dbg !698 {
  %2 = alloca i32, i16 1, align 4, !dbg !699
  store i32 %0, i32* %2, align 4, !dbg !699
  call void @llvm.sdr.blk.r(i16 0), !dbg !701
  %3 = load i32, i32* %2, align 4, !dbg !702
  store i32 %3, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.data_buf, i16 0, i1 false), align 4, !dbg !703
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !704
  %4 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !705
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !705
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !705
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !705
  store volatile i16 %4, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !706
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !706
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !706
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !706
  call void asm sideeffect "nop", ""(), !dbg !706
  call void asm sideeffect "nop", ""(), !dbg !706
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !707
  %8 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !708
  %9 = add i16 %8, 1, !dbg !709
  store i16 %9, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !710
  ret void, !dbg !711
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_send_data() #9 !dbg !712 {
  %1 = alloca i16, i16 1, align 2, !dbg !713
  %2 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !715
  %3 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !716
  %4 = icmp ult i16 %2, %3, !dbg !717
  br i1 %4, label %5, label %27, !dbg !718

5:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !719
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !720
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !720
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !720
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !720
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !721
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !721
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !721
  store volatile i16 %9, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !721
  call void asm sideeffect "nop", ""(), !dbg !721
  call void asm sideeffect "nop", ""(), !dbg !721
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_is_half, align 2, !dbg !722
  %11 = icmp ult i16 0, %10, !dbg !723
  br i1 %11, label %12, label %18, !dbg !724

12:                                               ; preds = %5
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !725
  %13 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !726
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !726
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !726
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !726
  %17 = add i16 %14, 1, !dbg !727
  store i16 %13, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !728
  store i16 %17, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !728
  store i16 %15, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !728
  store i16 %16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !728
  br label %24, !dbg !724

18:                                               ; preds = %5
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !729
  %19 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !730
  %20 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !730
  %21 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !730
  %22 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !730
  %23 = add i16 %20, 2, !dbg !731
  store i16 %19, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !732
  store i16 %23, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !732
  store i16 %21, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !732
  store i16 %22, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !732
  br label %24, !dbg !724

24:                                               ; preds = %12, %18
  %25 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !733
  %26 = add i16 %25, 1, !dbg !734
  store i16 %26, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !735
  br label %34, !dbg !718

27:                                               ; preds = %0
  %28 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !736
  store i16 %28, i16* %1, align 2, !dbg !713
  %29 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !737
  %30 = load i16, i16* %1, align 2, !dbg !738
  %31 = icmp eq i16 %29, %30, !dbg !739
  br i1 %31, label %32, label %33, !dbg !740

32:                                               ; preds = %27
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !741
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__1 to i8*)), !dbg !742
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !743
  br label %33, !dbg !740

33:                                               ; preds = %32, %27
  br label %34, !dbg !718

34:                                               ; preds = %24, %33
  ret void, !dbg !718
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl() #10 !dbg !744 {
  %1 = alloca i16, i16 1, align 2, !dbg !745
  %2 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !747
  %3 = icmp eq i16 0, %2, !dbg !748
  br i1 %3, label %4, label %9, !dbg !749

4:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__2 to i8*)), !dbg !750
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !751
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !751
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !751
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !751
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !752
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !752
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !752
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !752
  call void asm sideeffect "nop", ""(), !dbg !752
  call void asm sideeffect "nop", ""(), !dbg !752
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !753
  br label %31, !dbg !749

9:                                                ; preds = %0
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !754
  %11 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !755
  %12 = icmp ult i16 %10, %11, !dbg !756
  br i1 %12, label %13, label %18, !dbg !757

13:                                               ; preds = %9
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__3 to i8*)), !dbg !758
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !759
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !759
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !759
  %17 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !759
  store volatile i16 %14, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !760
  store volatile i16 %15, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !760
  store volatile i16 %16, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !760
  store volatile i16 %17, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !760
  call void asm sideeffect "nop", ""(), !dbg !760
  call void asm sideeffect "nop", ""(), !dbg !760
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !761
  br label %30, !dbg !757

18:                                               ; preds = %9
  %19 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !762
  store i16 %19, i16* %1, align 2, !dbg !745
  %20 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !763
  %21 = load i16, i16* %1, align 2, !dbg !764
  %22 = icmp eq i16 %20, %21, !dbg !765
  br i1 %22, label %23, label %24, !dbg !766

23:                                               ; preds = %18
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__4 to i8*)), !dbg !767
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__5 to i8*)), !dbg !768
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !769
  br label %29, !dbg !766

24:                                               ; preds = %18
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !770
  %25 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !771
  %26 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !771
  %27 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !771
  %28 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !771
  store volatile i16 %25, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !772
  store volatile i16 %26, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !772
  store volatile i16 %27, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !772
  store volatile i16 %28, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !772
  call void asm sideeffect "nop", ""(), !dbg !772
  call void asm sideeffect "nop", ""(), !dbg !772
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !773
  br label %29, !dbg !766

29:                                               ; preds = %23, %24
  br label %30, !dbg !757

30:                                               ; preds = %13, %29
  br label %31, !dbg !749

31:                                               ; preds = %4, %30
  ret void, !dbg !749
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.d2h_configure(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7) !dbg !774 {
  %9 = alloca i1, i16 1, align 1, !dbg !775
  %10 = alloca i1, i16 1, align 1, !dbg !777
  %11 = alloca i1, i16 1, align 1, !dbg !778
  %12 = alloca i16, i16 1, align 2, !dbg !779
  %13 = alloca i16, i16 1, align 2, !dbg !780
  %14 = alloca i16, i16 1, align 2, !dbg !781
  %15 = alloca i16, i16 1, align 2, !dbg !782
  %16 = alloca i16, i16 1, align 2, !dbg !783
  %17 = alloca i16, i16 1, align 2, !dbg !784
  %18 = alloca i16, i16 1, align 2, !dbg !785
  %19 = alloca i16, i16 1, align 2, !dbg !786
  %20 = alloca i16, i16 1, align 2, !dbg !787
  %21 = alloca i16, i16 1, align 2, !dbg !788
  %22 = alloca i16, i16 1, align 2, !dbg !789
  %23 = alloca i16, i16 1, align 2, !dbg !790
  %24 = alloca i16, i16 1, align 2, !dbg !791
  %25 = alloca i16, i16 1, align 2, !dbg !792
  store i16 %0, i16* %25, align 2, !dbg !792
  store i16 %1, i16* %24, align 2, !dbg !791
  store i16 %2, i16* %23, align 2, !dbg !790
  store i16 %3, i16* %22, align 2, !dbg !789
  store i16 %4, i16* %21, align 2, !dbg !788
  store i16 %5, i16* %20, align 2, !dbg !787
  store i16 %6, i16* %19, align 2, !dbg !786
  store i16 %7, i16* %18, align 2, !dbg !785
  %26 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !793
  store i16 %26, i16* %17, align 2, !dbg !784
  %27 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_y_coord(), !dbg !794
  store i16 %27, i16* %16, align 2, !dbg !783
  %28 = load i16, i16* %24, align 2, !dbg !795
  store i16 %28, i16* %15, align 2, !dbg !782
  %29 = load i16, i16* %24, align 2, !dbg !796
  %30 = load i16, i16* %22, align 2, !dbg !797
  %31 = add i16 %29, %30, !dbg !798
  %32 = sub i16 %31, 1, !dbg !799
  store i16 %32, i16* %14, align 2, !dbg !781
  %33 = load i16, i16* %23, align 2, !dbg !800
  store i16 %33, i16* %13, align 2, !dbg !780
  %34 = load i16, i16* %23, align 2, !dbg !801
  %35 = load i16, i16* %21, align 2, !dbg !802
  %36 = add i16 %34, %35, !dbg !803
  %37 = sub i16 %36, 1, !dbg !804
  store i16 %37, i16* %12, align 2, !dbg !779
  store i1 false, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !805
  %38 = load i16, i16* %17, align 2, !dbg !806
  %39 = load i16, i16* %15, align 2, !dbg !807
  %40 = icmp sge i16 %38, %39, !dbg !808
  br i1 %40, label %41, label %45, !dbg !778

41:                                               ; preds = %8
  %42 = load i16, i16* %16, align 2, !dbg !809
  %43 = load i16, i16* %12, align 2, !dbg !810
  %44 = icmp sle i16 %42, %43, !dbg !811
  store i1 %44, i1* %11, align 1, !dbg !778
  br label %46, !dbg !778

45:                                               ; preds = %8
  store i1 false, i1* %11, align 1, !dbg !778
  br label %46, !dbg !778

46:                                               ; preds = %41, %45
  %47 = load i1, i1* %11, align 1, !dbg !778
  br i1 %47, label %48, label %52, !dbg !777

48:                                               ; preds = %46
  %49 = load i16, i16* %16, align 2, !dbg !812
  %50 = load i16, i16* %13, align 2, !dbg !813
  %51 = icmp sge i16 %49, %50, !dbg !814
  store i1 %51, i1* %10, align 1, !dbg !777
  br label %53, !dbg !777

52:                                               ; preds = %46
  store i1 false, i1* %10, align 1, !dbg !777
  br label %53, !dbg !777

53:                                               ; preds = %48, %52
  %54 = load i1, i1* %10, align 1, !dbg !777
  br i1 %54, label %55, label %56, !dbg !815

55:                                               ; preds = %53
  store i1 true, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !816
  br label %56, !dbg !815

56:                                               ; preds = %55, %53
  store i1 false, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !817
  %57 = load i16, i16* %17, align 2, !dbg !818
  %58 = load i16, i16* %14, align 2, !dbg !819
  %59 = icmp sle i16 %57, %58, !dbg !820
  br i1 %59, label %60, label %62, !dbg !775

60:                                               ; preds = %56
  %61 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !821
  store i1 %61, i1* %9, align 1, !dbg !775
  br label %63, !dbg !775

62:                                               ; preds = %56
  store i1 false, i1* %9, align 1, !dbg !775
  br label %63, !dbg !775

63:                                               ; preds = %60, %62
  %64 = load i1, i1* %9, align 1, !dbg !775
  br i1 %64, label %65, label %66, !dbg !822

65:                                               ; preds = %63
  store i1 true, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !823
  br label %66, !dbg !822

66:                                               ; preds = %65, %63
  %67 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !824
  br i1 %67, label %68, label %86, !dbg !825

68:                                               ; preds = %66
  call void @__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position(i16 31959), !dbg !826
  %69 = load i16, i16* %15, align 2, !dbg !827
  %70 = load i16, i16* %17, align 2, !dbg !828
  %71 = icmp eq i16 %69, %70, !dbg !829
  br i1 %71, label %72, label %73, !dbg !830

72:                                               ; preds = %68
  call void @__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 31765), !dbg !831
  br label %74, !dbg !830

73:                                               ; preds = %68
  call void @__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 31765), !dbg !832
  br label %74, !dbg !830

74:                                               ; preds = %72, %73
  call void @sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit(i16 21), !dbg !833
  %75 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !834
  br i1 %75, label %76, label %85, !dbg !835

76:                                               ; preds = %74
  %77 = load i16, i16* %20, align 2, !dbg !836
  %78 = load i16, i16* %19, align 2, !dbg !837
  %79 = load i16, i16* %24, align 2, !dbg !838
  %80 = load i16, i16* %23, align 2, !dbg !839
  %81 = load i16, i16* %22, align 2, !dbg !840
  %82 = load i16, i16* %21, align 2, !dbg !841
  %83 = load i16, i16* %25, align 2, !dbg !842
  %84 = load i16, i16* %18, align 2, !dbg !843
  call void @sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start(i16 %77, i16 %78, i16 %79, i16 %80, i16 %81, i16 %82, i16 %83, i16 %84), !dbg !844
  br label %85, !dbg !835

85:                                               ; preds = %76, %74
  br label %87, !dbg !825

86:                                               ; preds = %66
  call void @llvm.sdr.actvt.r(i16 28), !dbg !845
  br label %87, !dbg !825

87:                                               ; preds = %85, %86
  ret void, !dbg !778
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit(i16 %0) !dbg !846 {
  %2 = alloca i16, i16 1, align 2, !dbg !847
  %3 = alloca i16, i16 1, align 2, !dbg !849
  %4 = alloca i16, i16 1, align 2, !dbg !850
  %5 = alloca i16, i16 1, align 2, !dbg !851
  store i16 %0, i16* %5, align 2, !dbg !851
  %6 = load i16, i16* %5, align 2, !dbg !852
  store i16 %6, i16* %4, align 2, !dbg !850
  %7 = load i16, i16* %4, align 2, !dbg !853
  %8 = add i16 %7, 31744, !dbg !854
  store i16 %8, i16* %3, align 2, !dbg !849
  %9 = load i16, i16* %3, align 2, !dbg !855
  %10 = shl i16 %9, 1, !dbg !856
  %11 = inttoptr i16 %10 to i16*, !dbg !856
  call void asm sideeffect "nop", ""(), !dbg !856
  call void asm sideeffect "nop", ""(), !dbg !856
  %12 = load volatile i16, i16* %11, align 2, !dbg !856
  store i16 %12, i16* %2, align 2, !dbg !847
  %13 = load i16, i16* %3, align 2, !dbg !857
  %14 = load i16, i16* %2, align 2, !dbg !858
  %15 = and i16 %14, 32767, !dbg !859
  %16 = shl i16 %13, 1, !dbg !860
  %17 = inttoptr i16 %16 to i16*, !dbg !860
  store volatile i16 %15, i16* %17, align 2, !dbg !860
  call void asm sideeffect "nop", ""(), !dbg !860
  call void asm sideeffect "nop", ""(), !dbg !860
  ret void, !dbg !861
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord() !dbg !862 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 2), !dbg !863
  %2 = sub i16 %1, 4, !dbg !865
  ret i16 %2, !dbg !866
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord() !dbg !867 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 0), !dbg !868
  %2 = sub i16 %1, 1, !dbg !870
  ret i16 %2, !dbg !871
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 %0) !dbg !872 {
  %2 = alloca i16, i16 1, align 2, !dbg !873
  %3 = alloca i16, i16 1, align 2, !dbg !875
  store i16 %0, i16* %3, align 2, !dbg !875
  %4 = load i16, i16* %3, align 2, !dbg !876
  %5 = lshr i16 %4, 1, !dbg !877
  %6 = add i16 %5, 31813, !dbg !878
  %7 = shl i16 %6, 1, !dbg !879
  %8 = inttoptr i16 %7 to i16*, !dbg !879
  call void asm sideeffect "nop", ""(), !dbg !879
  call void asm sideeffect "nop", ""(), !dbg !879
  %9 = load volatile i16, i16* %8, align 2, !dbg !879
  store i16 %9, i16* %2, align 2, !dbg !873
  %10 = load i16, i16* %2, align 2, !dbg !880
  %11 = and i16 %10, 2047, !dbg !881
  ret i16 %11, !dbg !882
}

define internal i16 @sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr(i16 %0) !dbg !883 {
  %2 = alloca i16, i16 1, align 2, !dbg !885
  store i16 %0, i16* %2, align 2, !dbg !885
  %3 = load i16, i16* %2, align 2, !dbg !887
  %4 = mul i16 %3, 2, !dbg !888
  %5 = add i16 %4, 31680, !dbg !889
  ret i16 %5, !dbg !890
}

define internal void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 %0, i16 %1, i1 %2) !dbg !891 {
  %4 = alloca i16, i16 1, align 2, !dbg !892
  %5 = alloca i16, i16 1, align 2, !dbg !894
  %6 = alloca i1, i16 1, align 1, !dbg !895
  %7 = alloca i16, i16 1, align 2, !dbg !896
  %8 = alloca i16, i16 1, align 2, !dbg !897
  store i16 %0, i16* %8, align 2, !dbg !897
  store i16 %1, i16* %7, align 2, !dbg !896
  store i1 %2, i1* %6, align 1, !dbg !895
  %9 = load i16, i16* %8, align 2, !dbg !898
  %10 = call i16 @sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr(i16 %9), !dbg !899
  store i16 %10, i16* %5, align 2, !dbg !894
  %11 = load i16, i16* %5, align 2, !dbg !900
  %12 = shl i16 %11, 1, !dbg !901
  %13 = inttoptr i16 %12 to i16*, !dbg !901
  call void asm sideeffect "nop", ""(), !dbg !901
  call void asm sideeffect "nop", ""(), !dbg !901
  call void asm sideeffect "nop", ""(), !dbg !901
  call void asm sideeffect "nop", ""(), !dbg !901
  %14 = load volatile i16, i16* %13, align 2, !dbg !901
  store i16 %14, i16* %4, align 2, !dbg !892
  %15 = load i1, i1* %6, align 1, !dbg !902
  br i1 %15, label %16, label %19, !dbg !903

16:                                               ; preds = %3
  %17 = load i16, i16* %4, align 2, !dbg !904
  %18 = or i16 %17, 2048, !dbg !905
  store i16 %18, i16* %4, align 2, !dbg !906
  br label %22, !dbg !903

19:                                               ; preds = %3
  %20 = load i16, i16* %4, align 2, !dbg !907
  %21 = and i16 %20, -2049, !dbg !908
  store i16 %21, i16* %4, align 2, !dbg !909
  br label %22, !dbg !903

22:                                               ; preds = %16, %19
  %23 = load i16, i16* %4, align 2, !dbg !910
  %24 = and i16 %23, -32, !dbg !911
  store i16 %24, i16* %4, align 2, !dbg !912
  %25 = load i16, i16* %4, align 2, !dbg !913
  %26 = load i16, i16* %7, align 2, !dbg !914
  %27 = add i16 %25, %26, !dbg !915
  store i16 %27, i16* %4, align 2, !dbg !916
  %28 = load i16, i16* %5, align 2, !dbg !917
  %29 = load i16, i16* %4, align 2, !dbg !918
  %30 = shl i16 %28, 1, !dbg !919
  %31 = inttoptr i16 %30 to i16*, !dbg !919
  store volatile i16 %29, i16* %31, align 2, !dbg !919
  call void asm sideeffect "nop", ""(), !dbg !919
  call void asm sideeffect "nop", ""(), !dbg !919
  call void asm sideeffect "nop", ""(), !dbg !919
  call void asm sideeffect "nop", ""(), !dbg !919
  ret void, !dbg !903
}

define internal i16 @sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr(i16 %0) !dbg !920 {
  %2 = alloca i16, i16 1, align 2, !dbg !922
  store i16 %0, i16* %2, align 2, !dbg !922
  %3 = load i16, i16* %2, align 2, !dbg !924
  %4 = add i16 %3, 31616, !dbg !925
  ret i16 %4, !dbg !926
}

define internal void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 %0, i16 %1) !dbg !927 {
  %3 = alloca i16, i16 1, align 2, !dbg !928
  %4 = alloca i16, i16 1, align 2, !dbg !930
  %5 = alloca i16, i16 1, align 2, !dbg !931
  %6 = alloca i16, i16 1, align 2, !dbg !932
  store i16 %0, i16* %6, align 2, !dbg !932
  store i16 %1, i16* %5, align 2, !dbg !931
  %7 = load i16, i16* %6, align 2, !dbg !933
  %8 = call i16 @sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr(i16 %7), !dbg !934
  store i16 %8, i16* %4, align 2, !dbg !930
  %9 = load i16, i16* %4, align 2, !dbg !935
  %10 = shl i16 %9, 1, !dbg !936
  %11 = inttoptr i16 %10 to i16*, !dbg !936
  call void asm sideeffect "nop", ""(), !dbg !936
  call void asm sideeffect "nop", ""(), !dbg !936
  call void asm sideeffect "nop", ""(), !dbg !936
  call void asm sideeffect "nop", ""(), !dbg !936
  %12 = load volatile i16, i16* %11, align 2, !dbg !936
  store i16 %12, i16* %3, align 2, !dbg !928
  %13 = load i16, i16* %3, align 2, !dbg !937
  %14 = and i16 %13, -497, !dbg !938
  store i16 %14, i16* %3, align 2, !dbg !939
  %15 = load i16, i16* %3, align 2, !dbg !940
  %16 = load i16, i16* %5, align 2, !dbg !941
  %17 = add i16 %15, %16, !dbg !942
  %18 = shl i16 %17, 4, !dbg !943
  store i16 %18, i16* %3, align 2, !dbg !944
  %19 = load i16, i16* %4, align 2, !dbg !945
  %20 = load i16, i16* %3, align 2, !dbg !946
  %21 = shl i16 %19, 1, !dbg !947
  %22 = inttoptr i16 %21 to i16*, !dbg !947
  store volatile i16 %20, i16* %22, align 2, !dbg !947
  call void asm sideeffect "nop", ""(), !dbg !947
  call void asm sideeffect "nop", ""(), !dbg !947
  call void asm sideeffect "nop", ""(), !dbg !947
  call void asm sideeffect "nop", ""(), !dbg !947
  ret void, !dbg !948
}

define internal i16* @.get_tensor_ptr(i16 %0) !dbg !949 {
  %2 = alloca i16, i16 1, align 2, !dbg !950
  store i16 %0, i16* %2, align 2, !dbg !950
  %3 = load i16, i16* %2, align 2, !dbg !950
  %4 = zext i16 %3 to i32, !dbg !950
  switch i32 %4, label %5 [
    i32 1, label %9
    i32 2, label %11
    i32 3, label %13
    i32 4, label %15
    i32 5, label %17
  ], !dbg !950

5:                                                ; preds = %1
  br i1 false, label %6, label %7, !dbg !950

6:                                                ; preds = %5
  br label %8, !dbg !950

7:                                                ; preds = %5
  call void asm sideeffect "hcf", ""(), !dbg !950
  br label %8, !dbg !950

8:                                                ; preds = %6, %7
  br label %19, !dbg !950

9:                                                ; preds = %1
  %10 = load i16*, i16** @p_a, align 8, !dbg !950
  br label %19, !dbg !950

11:                                               ; preds = %1
  %12 = load i16*, i16** @p_b, align 8, !dbg !950
  br label %19, !dbg !950

13:                                               ; preds = %1
  %14 = load i16*, i16** @p_c, align 8, !dbg !950
  br label %19, !dbg !950

15:                                               ; preds = %1
  %16 = load i16*, i16** @p_idx, align 8, !dbg !950
  br label %19, !dbg !950

17:                                               ; preds = %1
  %18 = load i16*, i16** @p_k, align 8, !dbg !950
  br label %19, !dbg !950

19:                                               ; preds = %8, %9, %11, %13, %15, %17
  %20 = phi i16 [ -2, %17 ], [ -2, %15 ], [ -2, %13 ], [ -2, %11 ], [ -2, %9 ], [ 0, %8 ]
  %21 = phi i16* [ %18, %17 ], [ %16, %15 ], [ %14, %13 ], [ %12, %11 ], [ %10, %9 ], [ undef, %8 ]
  br label %22, !dbg !950

22:                                               ; preds = %19
  %23 = icmp ne i16 %20, 0, !dbg !950
  br i1 %23, label %24, label %25, !dbg !950

24:                                               ; preds = %22
  br label %27, !dbg !950

25:                                               ; preds = %22
  %26 = load i16*, i16** @p_k, align 8, !dbg !950
  br label %27, !dbg !950

27:                                               ; preds = %24, %25
  %28 = phi i16* [ %26, %25 ], [ %21, %24 ]
  br label %29, !dbg !950

29:                                               ; preds = %27
  ret i16* %28, !dbg !950
}

define internal void @__generic0sys_mod.sys_mod.tile_config.queue_flush.exit() !dbg !952 {
  store volatile i16 1, i16* inttoptr (i16 -2268 to i16*), align 2, !dbg !954
  call void asm sideeffect "nop", ""(), !dbg !954
  call void asm sideeffect "nop", ""(), !dbg !954
  ret void, !dbg !956
}

define internal void @__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position(i16 %0) !dbg !957 {
  %2 = alloca i16, i16 1, align 2, !dbg !959
  %3 = alloca i16, i16 1, align 2, !dbg !961
  %4 = alloca i16, i16 1, align 2, !dbg !962
  store i16 %0, i16* %4, align 2, !dbg !962
  %5 = load i16, i16* %4, align 2, !dbg !963
  store i16 %5, i16* %3, align 2, !dbg !961
  %6 = load i16, i16* %3, align 2, !dbg !964
  %7 = shl i16 %6, 1, !dbg !965
  %8 = inttoptr i16 %7 to i16*, !dbg !965
  call void asm sideeffect "nop", ""(), !dbg !965
  call void asm sideeffect "nop", ""(), !dbg !965
  call void asm sideeffect "nop", ""(), !dbg !965
  call void asm sideeffect "nop", ""(), !dbg !965
  %9 = load volatile i16, i16* %8, align 2, !dbg !965
  store i16 %9, i16* %2, align 2, !dbg !959
  %10 = load i16, i16* %2, align 2, !dbg !966
  %11 = and i16 %10, -16, !dbg !967
  store i16 %11, i16* %2, align 2, !dbg !967
  %12 = load i16, i16* %3, align 2, !dbg !968
  %13 = load i16, i16* %2, align 2, !dbg !969
  %14 = shl i16 %12, 1, !dbg !970
  %15 = inttoptr i16 %14 to i16*, !dbg !970
  store volatile i16 %13, i16* %15, align 2, !dbg !970
  call void asm sideeffect "nop", ""(), !dbg !970
  call void asm sideeffect "nop", ""(), !dbg !970
  call void asm sideeffect "nop", ""(), !dbg !970
  call void asm sideeffect "nop", ""(), !dbg !970
  ret void, !dbg !971
}

define internal void @__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 %0) !dbg !972 {
  %2 = alloca i16, i16 1, align 2, !dbg !974
  %3 = alloca i16, i16 1, align 2, !dbg !976
  %4 = alloca i16, i16 1, align 2, !dbg !977
  store i16 %0, i16* %4, align 2, !dbg !977
  %5 = load i16, i16* %4, align 2, !dbg !978
  store i16 %5, i16* %3, align 2, !dbg !976
  %6 = load i16, i16* %3, align 2, !dbg !979
  %7 = shl i16 %6, 1, !dbg !980
  %8 = inttoptr i16 %7 to i16*, !dbg !980
  call void asm sideeffect "nop", ""(), !dbg !980
  call void asm sideeffect "nop", ""(), !dbg !980
  %9 = load volatile i16, i16* %8, align 2, !dbg !980
  store i16 %9, i16* %2, align 2, !dbg !974
  %10 = load i16, i16* %2, align 2, !dbg !981
  %11 = and i16 %10, -256, !dbg !982
  store i16 %11, i16* %2, align 2, !dbg !983
  %12 = load i16, i16* %2, align 2, !dbg !984
  %13 = load i16, i16* %2, align 2, !dbg !985
  %14 = call i16 @__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %13), !dbg !986
  %15 = or i16 %12, %14, !dbg !987
  store i16 %15, i16* %2, align 2, !dbg !987
  %16 = load i16, i16* %2, align 2, !dbg !988
  %17 = load i16, i16* %2, align 2, !dbg !989
  %18 = call i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %17), !dbg !990
  %19 = or i16 %16, %18, !dbg !991
  store i16 %19, i16* %2, align 2, !dbg !991
  %20 = load i16, i16* %3, align 2, !dbg !992
  %21 = load i16, i16* %2, align 2, !dbg !993
  %22 = shl i16 %20, 1, !dbg !994
  %23 = inttoptr i16 %22 to i16*, !dbg !994
  store volatile i16 %21, i16* %23, align 2, !dbg !994
  call void asm sideeffect "nop", ""(), !dbg !994
  call void asm sideeffect "nop", ""(), !dbg !994
  ret void, !dbg !995
}

define internal void @__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 %0) !dbg !996 {
  %2 = alloca i16, i16 1, align 2, !dbg !997
  %3 = alloca i16, i16 1, align 2, !dbg !999
  %4 = alloca i16, i16 1, align 2, !dbg !1000
  store i16 %0, i16* %4, align 2, !dbg !1000
  %5 = load i16, i16* %4, align 2, !dbg !1001
  store i16 %5, i16* %3, align 2, !dbg !999
  %6 = load i16, i16* %3, align 2, !dbg !1002
  %7 = shl i16 %6, 1, !dbg !1003
  %8 = inttoptr i16 %7 to i16*, !dbg !1003
  call void asm sideeffect "nop", ""(), !dbg !1003
  call void asm sideeffect "nop", ""(), !dbg !1003
  %9 = load volatile i16, i16* %8, align 2, !dbg !1003
  store i16 %9, i16* %2, align 2, !dbg !997
  %10 = load i16, i16* %2, align 2, !dbg !1004
  %11 = and i16 %10, -256, !dbg !1005
  store i16 %11, i16* %2, align 2, !dbg !1006
  %12 = load i16, i16* %2, align 2, !dbg !1007
  %13 = load i16, i16* %2, align 2, !dbg !1008
  %14 = call i16 @__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %13), !dbg !1009
  %15 = or i16 %12, %14, !dbg !1010
  store i16 %15, i16* %2, align 2, !dbg !1010
  %16 = load i16, i16* %2, align 2, !dbg !1011
  %17 = load i16, i16* %2, align 2, !dbg !1012
  %18 = call i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %17), !dbg !1013
  %19 = or i16 %16, %18, !dbg !1014
  store i16 %19, i16* %2, align 2, !dbg !1014
  %20 = load i16, i16* %3, align 2, !dbg !1015
  %21 = load i16, i16* %2, align 2, !dbg !1016
  %22 = shl i16 %20, 1, !dbg !1017
  %23 = inttoptr i16 %22 to i16*, !dbg !1017
  store volatile i16 %21, i16* %23, align 2, !dbg !1017
  call void asm sideeffect "nop", ""(), !dbg !1017
  call void asm sideeffect "nop", ""(), !dbg !1017
  ret void, !dbg !1018
}

define internal i16 @__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %0) !dbg !1019 {
  %2 = alloca i16, i16 1, align 2, !dbg !1020
  %3 = alloca i16, i16 1, align 2, !dbg !1022
  store i16 %0, i16* %3, align 2, !dbg !1022
  %4 = load i16, i16* %3, align 2, !dbg !1023
  store i16 %4, i16* %2, align 2, !dbg !1020
  %5 = load i16, i16* %2, align 2, !dbg !1024
  store i16 %5, i16* %2, align 2, !dbg !1025
  %6 = load i16, i16* %2, align 2, !dbg !1026
  ret i16 %6, !dbg !1027
}

define internal i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %0) !dbg !1028 {
  %2 = alloca i16, i16 1, align 2, !dbg !1029
  %3 = alloca i16, i16 1, align 2, !dbg !1031
  store i16 %0, i16* %3, align 2, !dbg !1031
  %4 = load i16, i16* %3, align 2, !dbg !1032
  store i16 %4, i16* %2, align 2, !dbg !1029
  %5 = load i16, i16* %2, align 2, !dbg !1033
  %6 = or i16 %5, 2, !dbg !1034
  store i16 %6, i16* %2, align 2, !dbg !1034
  %7 = load i16, i16* %2, align 2, !dbg !1035
  ret i16 %7, !dbg !1036
}

define internal i16 @__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %0) !dbg !1037 {
  %2 = alloca i16, i16 1, align 2, !dbg !1038
  %3 = alloca i16, i16 1, align 2, !dbg !1040
  store i16 %0, i16* %3, align 2, !dbg !1040
  %4 = load i16, i16* %3, align 2, !dbg !1041
  store i16 %4, i16* %2, align 2, !dbg !1038
  %5 = load i16, i16* %2, align 2, !dbg !1042
  %6 = or i16 %5, 128, !dbg !1043
  store i16 %6, i16* %2, align 2, !dbg !1043
  %7 = load i16, i16* %2, align 2, !dbg !1044
  ret i16 %7, !dbg !1045
}

define internal void @__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction(i16 %0) !dbg !1046 {
  %2 = alloca i16, i16 1, align 2, !dbg !1047
  %3 = alloca i16, i16 1, align 2, !dbg !1049
  %4 = alloca i16, i16 1, align 2, !dbg !1050
  store i16 %0, i16* %4, align 2, !dbg !1050
  %5 = load i16, i16* %4, align 2, !dbg !1051
  store i16 %5, i16* %3, align 2, !dbg !1049
  %6 = load i16, i16* %3, align 2, !dbg !1052
  %7 = shl i16 %6, 1, !dbg !1053
  %8 = inttoptr i16 %7 to i16*, !dbg !1053
  call void asm sideeffect "nop", ""(), !dbg !1053
  call void asm sideeffect "nop", ""(), !dbg !1053
  %9 = load volatile i16, i16* %8, align 2, !dbg !1053
  store i16 %9, i16* %2, align 2, !dbg !1047
  %10 = load i16, i16* %2, align 2, !dbg !1054
  %11 = and i16 %10, -17, !dbg !1055
  store i16 %11, i16* %2, align 2, !dbg !1055
  %12 = load i16, i16* %3, align 2, !dbg !1056
  %13 = load i16, i16* %2, align 2, !dbg !1057
  %14 = shl i16 %12, 1, !dbg !1058
  %15 = inttoptr i16 %14 to i16*, !dbg !1058
  store volatile i16 %13, i16* %15, align 2, !dbg !1058
  call void asm sideeffect "nop", ""(), !dbg !1058
  call void asm sideeffect "nop", ""(), !dbg !1058
  ret void, !dbg !1059
}

define internal void @__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction(i16 %0) !dbg !1060 {
  %2 = alloca i16, i16 1, align 2, !dbg !1061
  %3 = alloca i16, i16 1, align 2, !dbg !1063
  %4 = alloca i16, i16 1, align 2, !dbg !1064
  store i16 %0, i16* %4, align 2, !dbg !1064
  %5 = load i16, i16* %4, align 2, !dbg !1065
  store i16 %5, i16* %3, align 2, !dbg !1063
  %6 = load i16, i16* %3, align 2, !dbg !1066
  %7 = shl i16 %6, 1, !dbg !1067
  %8 = inttoptr i16 %7 to i16*, !dbg !1067
  call void asm sideeffect "nop", ""(), !dbg !1067
  call void asm sideeffect "nop", ""(), !dbg !1067
  %9 = load volatile i16, i16* %8, align 2, !dbg !1067
  store i16 %9, i16* %2, align 2, !dbg !1061
  %10 = load i16, i16* %2, align 2, !dbg !1068
  %11 = or i16 %10, 16, !dbg !1069
  store i16 %11, i16* %2, align 2, !dbg !1069
  %12 = load i16, i16* %3, align 2, !dbg !1070
  %13 = load i16, i16* %2, align 2, !dbg !1071
  %14 = shl i16 %12, 1, !dbg !1072
  %15 = inttoptr i16 %14 to i16*, !dbg !1072
  store volatile i16 %13, i16* %15, align 2, !dbg !1072
  call void asm sideeffect "nop", ""(), !dbg !1072
  call void asm sideeffect "nop", ""(), !dbg !1072
  ret void, !dbg !1073
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
!4 = !DIFile(filename: "./pe.csl", directory: "/home/USER/xkernel/studies/wse3-characterization/microbench/addfam/cases/pair_dependent")
!5 = !DISubroutineType(types: !6)
!6 = !{}
!7 = !DILocation(line: 16, column: 11, scope: !8)
!8 = !DILexicalBlockFile(scope: !3, file: !4, discriminator: 0)
!9 = !DILocation(line: 16, column: 18, scope: !8)
!10 = !DILocation(line: 16, column: 15, scope: !8)
!11 = !DILocation(line: 16, column: 8, scope: !8)
!12 = !DILocation(line: 17, column: 11, scope: !8)
!13 = !DILocation(line: 17, column: 18, scope: !8)
!14 = !DILocation(line: 17, column: 15, scope: !8)
!15 = !DILocation(line: 17, column: 8, scope: !8)
!16 = !DILocation(line: 18, column: 3, scope: !8)
!17 = !DILocation(line: 15, column: 1, scope: !8)
!18 = distinct !DISubprogram(name: "f_exit", linkageName: "f_exit", scope: null, file: !4, line: 21, type: !5, scopeLine: 21, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!19 = !DILocation(line: 21, column: 22, scope: !20)
!20 = !DILexicalBlockFile(scope: !18, file: !4, discriminator: 0)
!21 = !DILocation(line: 21, column: 1, scope: !20)
!22 = distinct !DISubprogram(name: "sys_mod.sys_nop", linkageName: "sys_mod.sys_nop", scope: null, file: !23, line: 90, type: !5, scopeLine: 90, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!23 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/memcpy.csl", directory: "")
!24 = !DILocation(line: 90, column: 1, scope: !25)
!25 = !DILexicalBlockFile(scope: !22, file: !23, discriminator: 0)
!26 = distinct !DISubprogram(name: "sys_mod.unblock_cmd_stream", linkageName: "sys_mod.unblock_cmd_stream", scope: null, file: !23, line: 102, type: !5, scopeLine: 102, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!27 = !DILocation(line: 103, column: 3, scope: !28)
!28 = !DILexicalBlockFile(scope: !26, file: !23, discriminator: 0)
!29 = !DILocation(line: 102, column: 1, scope: !28)
!30 = distinct !DISubprogram(name: "sys_mod.sys_mod.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.unblock_cmd_stream", scope: null, file: !31, line: 307, type: !5, scopeLine: 307, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!31 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpy.csl", directory: "")
!32 = !DILocation(line: 308, column: 5, scope: !33)
!33 = !DILexicalBlockFile(scope: !30, file: !31, discriminator: 0)
!34 = !DILocation(line: 307, column: 1, scope: !33)
!35 = distinct !DISubprogram(name: "sys_mod.sys_mod.teardown_h2d", linkageName: "sys_mod.sys_mod.teardown_h2d", scope: null, file: !31, line: 323, type: !5, scopeLine: 323, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!36 = !DILocation(line: 326, column: 5, scope: !37)
!37 = !DILexicalBlockFile(scope: !35, file: !31, discriminator: 0)
!38 = !DILocation(line: 323, column: 1, scope: !37)
!39 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_ublk_c22", linkageName: "sys_mod.sys_mod.f_ublk_c22", scope: null, file: !31, line: 335, type: !5, scopeLine: 335, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!40 = !DILocation(line: 336, column: 5, scope: !41)
!41 = !DILexicalBlockFile(scope: !39, file: !31, discriminator: 0)
!42 = !DILocation(line: 335, column: 1, scope: !41)
!43 = distinct !DISubprogram(name: "sys_mod.sys_mod.teardown_d2h", linkageName: "sys_mod.sys_mod.teardown_d2h", scope: null, file: !31, line: 344, type: !5, scopeLine: 344, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!44 = !DILocation(line: 355, column: 5, scope: !45)
!45 = !DILexicalBlockFile(scope: !43, file: !31, discriminator: 0)
!46 = !DILocation(line: 359, column: 5, scope: !45)
!47 = !DILocation(line: 344, column: 1, scope: !45)
!48 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_memcpyh2d", linkageName: "sys_mod.sys_mod.f_memcpyh2d", scope: null, file: !31, line: 460, type: !5, scopeLine: 460, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!49 = !DILocation(line: 477, column: 5, scope: !50)
!50 = !DILexicalBlockFile(scope: !48, file: !31, discriminator: 0)
!51 = !DILocation(line: 476, column: 5, scope: !50)
!52 = !DILocation(line: 475, column: 5, scope: !50)
!53 = !DILocation(line: 474, column: 5, scope: !50)
!54 = !DILocation(line: 473, column: 5, scope: !50)
!55 = !DILocation(line: 472, column: 5, scope: !50)
!56 = !DILocation(line: 471, column: 5, scope: !50)
!57 = !DILocation(line: 470, column: 5, scope: !50)
!58 = !DILocation(line: 469, column: 5, scope: !50)
!59 = !DILocation(line: 468, column: 5, scope: !50)
!60 = !DILocation(line: 467, column: 5, scope: !50)
!61 = !DILocation(line: 466, column: 5, scope: !50)
!62 = !DILocation(line: 465, column: 5, scope: !50)
!63 = !DILocation(line: 463, column: 5, scope: !50)
!64 = !DILocation(line: 462, column: 20, scope: !50)
!65 = !DILocation(line: 462, column: 32, scope: !50)
!66 = !DILocation(line: 462, column: 5, scope: !50)
!67 = !DILocation(line: 465, column: 33, scope: !50)
!68 = !DILocation(line: 465, column: 38, scope: !50)
!69 = !DILocation(line: 466, column: 34, scope: !50)
!70 = !DILocation(line: 466, column: 39, scope: !50)
!71 = !DILocation(line: 467, column: 34, scope: !50)
!72 = !DILocation(line: 467, column: 39, scope: !50)
!73 = !DILocation(line: 468, column: 33, scope: !50)
!74 = !DILocation(line: 468, column: 38, scope: !50)
!75 = !DILocation(line: 469, column: 33, scope: !50)
!76 = !DILocation(line: 469, column: 38, scope: !50)
!77 = !DILocation(line: 470, column: 35, scope: !50)
!78 = !DILocation(line: 470, column: 21, scope: !50)
!79 = !DILocation(line: 471, column: 41, scope: !50)
!80 = !DILocation(line: 471, column: 27, scope: !50)
!81 = !DILocation(line: 472, column: 39, scope: !50)
!82 = !DILocation(line: 472, column: 25, scope: !50)
!83 = !DILocation(line: 473, column: 44, scope: !50)
!84 = !DILocation(line: 473, column: 49, scope: !50)
!85 = !DILocation(line: 474, column: 41, scope: !50)
!86 = !DILocation(line: 474, column: 46, scope: !50)
!87 = !DILocation(line: 475, column: 41, scope: !50)
!88 = !DILocation(line: 475, column: 46, scope: !50)
!89 = !DILocation(line: 476, column: 59, scope: !50)
!90 = !DILocation(line: 476, column: 64, scope: !50)
!91 = !DILocation(line: 476, column: 50, scope: !50)
!92 = !DILocation(line: 476, column: 129, scope: !50)
!93 = !DILocation(line: 476, column: 134, scope: !50)
!94 = !DILocation(line: 476, column: 120, scope: !50)
!95 = !DILocation(line: 476, column: 118, scope: !50)
!96 = !DILocation(line: 476, column: 112, scope: !50)
!97 = !DILocation(line: 476, column: 36, scope: !50)
!98 = !DILocation(line: 477, column: 59, scope: !50)
!99 = !DILocation(line: 477, column: 64, scope: !50)
!100 = !DILocation(line: 477, column: 50, scope: !50)
!101 = !DILocation(line: 477, column: 129, scope: !50)
!102 = !DILocation(line: 477, column: 134, scope: !50)
!103 = !DILocation(line: 477, column: 120, scope: !50)
!104 = !DILocation(line: 477, column: 118, scope: !50)
!105 = !DILocation(line: 477, column: 112, scope: !50)
!106 = !DILocation(line: 477, column: 36, scope: !50)
!107 = !DILocation(line: 479, column: 24, scope: !50)
!108 = !DILocation(line: 481, column: 21, scope: !50)
!109 = !DILocation(line: 481, column: 19, scope: !50)
!110 = !DILocation(line: 482, column: 21, scope: !50)
!111 = !DILocation(line: 482, column: 19, scope: !50)
!112 = !DILocation(line: 483, column: 21, scope: !50)
!113 = !DILocation(line: 483, column: 19, scope: !50)
!114 = !DILocation(line: 484, column: 20, scope: !50)
!115 = !DILocation(line: 484, column: 18, scope: !50)
!116 = !DILocation(line: 485, column: 20, scope: !50)
!117 = !DILocation(line: 485, column: 18, scope: !50)
!118 = !DILocation(line: 486, column: 22, scope: !50)
!119 = !DILocation(line: 486, column: 20, scope: !50)
!120 = !DILocation(line: 487, column: 27, scope: !50)
!121 = !DILocation(line: 487, column: 25, scope: !50)
!122 = !DILocation(line: 488, column: 25, scope: !50)
!123 = !DILocation(line: 488, column: 23, scope: !50)
!124 = !DILocation(line: 489, column: 31, scope: !50)
!125 = !DILocation(line: 489, column: 29, scope: !50)
!126 = !DILocation(line: 490, column: 28, scope: !50)
!127 = !DILocation(line: 490, column: 26, scope: !50)
!128 = !DILocation(line: 491, column: 28, scope: !50)
!129 = !DILocation(line: 491, column: 26, scope: !50)
!130 = !DILocation(line: 492, column: 37, scope: !50)
!131 = !DILocation(line: 492, column: 35, scope: !50)
!132 = !DILocation(line: 493, column: 37, scope: !50)
!133 = !DILocation(line: 493, column: 35, scope: !50)
!134 = !DILocation(line: 495, column: 5, scope: !50)
!135 = !DILocation(line: 501, column: 5, scope: !50)
!136 = !DILocation(line: 506, column: 5, scope: !50)
!137 = !DILocation(line: 521, column: 5, scope: !50)
!138 = !DILocation(line: 522, column: 16, scope: !50)
!139 = !DILocation(line: 531, column: 5, scope: !50)
!140 = !DILocation(line: 460, column: 1, scope: !50)
!141 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_memcpyd2h", linkageName: "sys_mod.sys_mod.f_memcpyd2h", scope: null, file: !31, line: 556, type: !5, scopeLine: 556, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!142 = !DILocation(line: 568, column: 5, scope: !143)
!143 = !DILexicalBlockFile(scope: !141, file: !31, discriminator: 0)
!144 = !DILocation(line: 567, column: 5, scope: !143)
!145 = !DILocation(line: 566, column: 5, scope: !143)
!146 = !DILocation(line: 565, column: 5, scope: !143)
!147 = !DILocation(line: 564, column: 5, scope: !143)
!148 = !DILocation(line: 563, column: 5, scope: !143)
!149 = !DILocation(line: 562, column: 5, scope: !143)
!150 = !DILocation(line: 561, column: 5, scope: !143)
!151 = !DILocation(line: 559, column: 5, scope: !143)
!152 = !DILocation(line: 558, column: 20, scope: !143)
!153 = !DILocation(line: 558, column: 32, scope: !143)
!154 = !DILocation(line: 558, column: 5, scope: !143)
!155 = !DILocation(line: 561, column: 33, scope: !143)
!156 = !DILocation(line: 561, column: 38, scope: !143)
!157 = !DILocation(line: 562, column: 34, scope: !143)
!158 = !DILocation(line: 562, column: 39, scope: !143)
!159 = !DILocation(line: 563, column: 34, scope: !143)
!160 = !DILocation(line: 563, column: 39, scope: !143)
!161 = !DILocation(line: 564, column: 33, scope: !143)
!162 = !DILocation(line: 564, column: 38, scope: !143)
!163 = !DILocation(line: 565, column: 33, scope: !143)
!164 = !DILocation(line: 565, column: 38, scope: !143)
!165 = !DILocation(line: 566, column: 35, scope: !143)
!166 = !DILocation(line: 566, column: 21, scope: !143)
!167 = !DILocation(line: 567, column: 41, scope: !143)
!168 = !DILocation(line: 567, column: 27, scope: !143)
!169 = !DILocation(line: 568, column: 39, scope: !143)
!170 = !DILocation(line: 568, column: 25, scope: !143)
!171 = !DILocation(line: 570, column: 24, scope: !143)
!172 = !DILocation(line: 573, column: 21, scope: !143)
!173 = !DILocation(line: 573, column: 19, scope: !143)
!174 = !DILocation(line: 574, column: 21, scope: !143)
!175 = !DILocation(line: 574, column: 19, scope: !143)
!176 = !DILocation(line: 575, column: 21, scope: !143)
!177 = !DILocation(line: 575, column: 19, scope: !143)
!178 = !DILocation(line: 576, column: 20, scope: !143)
!179 = !DILocation(line: 576, column: 18, scope: !143)
!180 = !DILocation(line: 577, column: 20, scope: !143)
!181 = !DILocation(line: 577, column: 18, scope: !143)
!182 = !DILocation(line: 578, column: 22, scope: !143)
!183 = !DILocation(line: 578, column: 20, scope: !143)
!184 = !DILocation(line: 579, column: 27, scope: !143)
!185 = !DILocation(line: 579, column: 25, scope: !143)
!186 = !DILocation(line: 580, column: 25, scope: !143)
!187 = !DILocation(line: 580, column: 23, scope: !143)
!188 = !DILocation(line: 582, column: 5, scope: !143)
!189 = !DILocation(line: 588, column: 59, scope: !143)
!190 = !DILocation(line: 588, column: 5, scope: !143)
!191 = !DILocation(line: 608, column: 5, scope: !143)
!192 = !DILocation(line: 609, column: 16, scope: !143)
!193 = !DILocation(line: 556, column: 1, scope: !143)
!194 = distinct !DISubprogram(name: "sys_mod.sys_mod.oq0_teardow_handler", linkageName: "sys_mod.sys_mod.oq0_teardow_handler", scope: null, file: !31, line: 631, type: !5, scopeLine: 631, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!195 = !DILocation(line: 632, column: 9, scope: !196)
!196 = !DILexicalBlockFile(scope: !194, file: !31, discriminator: 0)
!197 = !DILocation(line: 632, column: 5, scope: !196)
!198 = !DILocation(line: 634, column: 66, scope: !196)
!199 = !DILocation(line: 634, column: 9, scope: !196)
!200 = !DILocation(line: 636, column: 13, scope: !196)
!201 = !DILocation(line: 637, column: 13, scope: !196)
!202 = !DILocation(line: 638, column: 13, scope: !196)
!203 = !DILocation(line: 639, column: 13, scope: !196)
!204 = !DILocation(line: 640, column: 13, scope: !196)
!205 = !DILocation(line: 641, column: 13, scope: !196)
!206 = !DILocation(line: 642, column: 13, scope: !196)
!207 = !DILocation(line: 643, column: 13, scope: !196)
!208 = !DILocation(line: 644, column: 13, scope: !196)
!209 = !DILocation(line: 645, column: 13, scope: !196)
!210 = !DILocation(line: 646, column: 13, scope: !196)
!211 = !DILocation(line: 647, column: 13, scope: !196)
!212 = !DILocation(line: 648, column: 13, scope: !196)
!213 = !DILocation(line: 635, column: 9, scope: !196)
!214 = !DILocation(line: 652, column: 9, scope: !196)
!215 = !DILocation(line: 654, column: 13, scope: !196)
!216 = !DILocation(line: 655, column: 13, scope: !196)
!217 = !DILocation(line: 656, column: 13, scope: !196)
!218 = !DILocation(line: 657, column: 13, scope: !196)
!219 = !DILocation(line: 658, column: 13, scope: !196)
!220 = !DILocation(line: 659, column: 13, scope: !196)
!221 = !DILocation(line: 660, column: 13, scope: !196)
!222 = !DILocation(line: 661, column: 13, scope: !196)
!223 = !DILocation(line: 653, column: 9, scope: !196)
!224 = !DILocation(line: 664, column: 5, scope: !196)
!225 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_rpc", linkageName: "sys_mod.sys_mod.f_rpc", scope: null, file: !31, line: 694, type: !5, scopeLine: 694, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!226 = !DILocation(line: 694, column: 13, scope: !227)
!227 = !DILexicalBlockFile(scope: !225, file: !31, discriminator: 0)
!228 = !DILocation(line: 700, column: 5, scope: !227)
!229 = !DILocation(line: 706, column: 20, scope: !227)
!230 = !DILocation(line: 706, column: 32, scope: !227)
!231 = !DILocation(line: 706, column: 5, scope: !227)
!232 = !DILocation(line: 710, column: 5, scope: !227)
!233 = !DILocation(line: 712, column: 24, scope: !227)
!234 = !DILocation(line: 694, column: 1, scope: !227)
!235 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.stack_push", linkageName: "sys_mod.sys_mod.sys_mod.stack_push", scope: null, file: !236, line: 54, type: !5, scopeLine: 54, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!236 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/sys.csl", directory: "")
!237 = !DILocation(line: 60, column: 5, scope: !238)
!238 = !DILexicalBlockFile(scope: !235, file: !236, discriminator: 0)
!239 = !DILocation(line: 54, column: 16, scope: !238)
!240 = !DILocation(line: 59, column: 13, scope: !238)
!241 = !DILocation(line: 59, column: 24, scope: !238)
!242 = !DILocation(line: 59, column: 5, scope: !238)
!243 = !DILocation(line: 61, column: 25, scope: !238)
!244 = !DILocation(line: 61, column: 5, scope: !238)
!245 = !DILocation(line: 61, column: 11, scope: !238)
!246 = !DILocation(line: 61, column: 10, scope: !238)
!247 = !DILocation(line: 61, column: 23, scope: !238)
!248 = !DILocation(line: 62, column: 18, scope: !238)
!249 = !DILocation(line: 62, column: 29, scope: !238)
!250 = !DILocation(line: 62, column: 16, scope: !238)
!251 = !DILocation(line: 54, column: 1, scope: !238)
!252 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_push", linkageName: "sys_mod.sys_mod.sys_mod.f_push", scope: null, file: !236, line: 72, type: !5, scopeLine: 72, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!253 = !DILocation(line: 72, column: 25, scope: !254)
!254 = !DILexicalBlockFile(scope: !252, file: !236, discriminator: 0)
!255 = !DILocation(line: 72, column: 13, scope: !254)
!256 = !DILocation(line: 73, column: 16, scope: !254)
!257 = !DILocation(line: 73, column: 5, scope: !254)
!258 = !DILocation(line: 72, column: 1, scope: !254)
!259 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.block_cmd_stream", linkageName: "sys_mod.sys_mod.sys_mod.block_cmd_stream", scope: null, file: !236, line: 76, type: !5, scopeLine: 76, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!260 = !DILocation(line: 77, column: 5, scope: !261)
!261 = !DILexicalBlockFile(scope: !259, file: !236, discriminator: 0)
!262 = !DILocation(line: 76, column: 1, scope: !261)
!263 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.sys_mod.unblock_cmd_stream", scope: null, file: !236, line: 80, type: !5, scopeLine: 80, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!264 = !DILocation(line: 81, column: 5, scope: !265)
!265 = !DILexicalBlockFile(scope: !263, file: !236, discriminator: 0)
!266 = !DILocation(line: 80, column: 1, scope: !265)
!267 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_sys_exit", linkageName: "sys_mod.sys_mod.sys_mod.f_sys_exit", scope: null, file: !236, line: 85, type: !5, scopeLine: 85, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!268 = !DILocation(line: 86, column: 5, scope: !269)
!269 = !DILexicalBlockFile(scope: !267, file: !236, discriminator: 0)
!270 = !DILocation(line: 87, column: 5, scope: !269)
!271 = !DILocation(line: 85, column: 1, scope: !269)
!272 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore", linkageName: "sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore", scope: null, file: !236, line: 90, type: !5, scopeLine: 90, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!273 = !DILocation(line: 90, column: 30, scope: !274)
!274 = !DILexicalBlockFile(scope: !272, file: !236, discriminator: 0)
!275 = !DILocation(line: 90, column: 1, scope: !274)
!276 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord", scope: null, file: !277, line: 131, type: !5, scopeLine: 131, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!277 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpyh2d.csl", directory: "")
!278 = !DILocation(line: 132, column: 12, scope: !279)
!279 = !DILexicalBlockFile(scope: !276, file: !277, discriminator: 0)
!280 = !DILocation(line: 132, column: 5, scope: !279)
!281 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord", scope: null, file: !277, line: 134, type: !5, scopeLine: 134, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!282 = !DILocation(line: 135, column: 12, scope: !283)
!283 = !DILexicalBlockFile(scope: !281, file: !277, discriminator: 0)
!284 = !DILocation(line: 135, column: 5, scope: !283)
!285 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval", scope: null, file: !277, line: 148, type: !5, scopeLine: 148, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!286 = !DILocation(line: 148, column: 23, scope: !287)
!287 = !DILexicalBlockFile(scope: !285, file: !277, discriminator: 0)
!288 = !DILocation(line: 149, column: 9, scope: !287)
!289 = !DILocation(line: 149, column: 20, scope: !287)
!290 = !DILocation(line: 149, column: 5, scope: !287)
!291 = !DILocation(line: 152, column: 23, scope: !287)
!292 = !DILocation(line: 152, column: 20, scope: !287)
!293 = !DILocation(line: 152, column: 9, scope: !287)
!294 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start", scope: null, file: !277, line: 226, type: !5, scopeLine: 226, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!295 = !DILocation(line: 233, column: 5, scope: !296)
!296 = !DILexicalBlockFile(scope: !294, file: !277, discriminator: 0)
!297 = !DILocation(line: 226, column: 49, scope: !296)
!298 = !DILocation(line: 226, column: 32, scope: !296)
!299 = !DILocation(line: 226, column: 21, scope: !296)
!300 = !DILocation(line: 229, column: 37, scope: !296)
!301 = !DILocation(line: 229, column: 52, scope: !296)
!302 = !DILocation(line: 229, column: 19, scope: !296)
!303 = !DILocation(line: 233, column: 71, scope: !296)
!304 = !DILocation(line: 233, column: 55, scope: !296)
!305 = !DILocation(line: 233, column: 25, scope: !296)
!306 = !DILocation(line: 235, column: 37, scope: !296)
!307 = !DILocation(line: 235, column: 52, scope: !296)
!308 = !DILocation(line: 235, column: 19, scope: !296)
!309 = !DILocation(line: 236, column: 28, scope: !296)
!310 = !DILocation(line: 236, column: 5, scope: !296)
!311 = !DILocation(line: 237, column: 28, scope: !296)
!312 = !DILocation(line: 237, column: 5, scope: !296)
!313 = !DILocation(line: 238, column: 13, scope: !296)
!314 = !DILocation(line: 238, column: 11, scope: !296)
!315 = !DILocation(line: 238, column: 5, scope: !296)
!316 = !DILocation(line: 239, column: 9, scope: !296)
!317 = !DILocation(line: 241, column: 9, scope: !296)
!318 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream", scope: null, file: !277, line: 249, type: !5, scopeLine: 249, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!319 = !DILocation(line: 250, column: 5, scope: !320)
!320 = !DILexicalBlockFile(scope: !318, file: !277, discriminator: 0)
!321 = !DILocation(line: 249, column: 1, scope: !320)
!322 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure", scope: null, file: !277, line: 276, type: !5, scopeLine: 276, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!323 = !DILocation(line: 414, column: 13, scope: !324)
!324 = !DILexicalBlockFile(scope: !322, file: !277, discriminator: 0)
!325 = !DILocation(line: 413, column: 13, scope: !324)
!326 = !DILocation(line: 400, column: 17, scope: !324)
!327 = !DILocation(line: 340, column: 9, scope: !324)
!328 = !DILocation(line: 339, column: 9, scope: !324)
!329 = !DILocation(line: 337, column: 5, scope: !324)
!330 = !DILocation(line: 319, column: 9, scope: !324)
!331 = !DILocation(line: 318, column: 9, scope: !324)
!332 = !DILocation(line: 315, column: 5, scope: !324)
!333 = !DILocation(line: 292, column: 5, scope: !324)
!334 = !DILocation(line: 291, column: 5, scope: !324)
!335 = !DILocation(line: 289, column: 5, scope: !324)
!336 = !DILocation(line: 288, column: 5, scope: !324)
!337 = !DILocation(line: 287, column: 5, scope: !324)
!338 = !DILocation(line: 286, column: 5, scope: !324)
!339 = !DILocation(line: 285, column: 5, scope: !324)
!340 = !DILocation(line: 284, column: 5, scope: !324)
!341 = !DILocation(line: 283, column: 5, scope: !324)
!342 = !DILocation(line: 282, column: 5, scope: !324)
!343 = !DILocation(line: 281, column: 5, scope: !324)
!344 = !DILocation(line: 280, column: 5, scope: !324)
!345 = !DILocation(line: 279, column: 5, scope: !324)
!346 = !DILocation(line: 278, column: 5, scope: !324)
!347 = !DILocation(line: 277, column: 5, scope: !324)
!348 = !DILocation(line: 291, column: 26, scope: !324)
!349 = !DILocation(line: 292, column: 26, scope: !324)
!350 = !DILocation(line: 315, column: 25, scope: !324)
!351 = !DILocation(line: 315, column: 31, scope: !324)
!352 = !DILocation(line: 315, column: 29, scope: !324)
!353 = !DILocation(line: 316, column: 20, scope: !324)
!354 = !DILocation(line: 316, column: 18, scope: !324)
!355 = !DILocation(line: 317, column: 52, scope: !324)
!356 = !DILocation(line: 317, column: 49, scope: !324)
!357 = !DILocation(line: 317, column: 5, scope: !324)
!358 = !DILocation(line: 318, column: 42, scope: !324)
!359 = !DILocation(line: 318, column: 33, scope: !324)
!360 = !DILocation(line: 318, column: 49, scope: !324)
!361 = !DILocation(line: 318, column: 48, scope: !324)
!362 = !DILocation(line: 318, column: 24, scope: !324)
!363 = !DILocation(line: 319, column: 24, scope: !324)
!364 = !DILocation(line: 319, column: 32, scope: !324)
!365 = !DILocation(line: 319, column: 36, scope: !324)
!366 = !DILocation(line: 319, column: 34, scope: !324)
!367 = !DILocation(line: 319, column: 30, scope: !324)
!368 = !DILocation(line: 320, column: 18, scope: !324)
!369 = !DILocation(line: 320, column: 15, scope: !324)
!370 = !DILocation(line: 320, column: 9, scope: !324)
!371 = !DILocation(line: 321, column: 26, scope: !324)
!372 = !DILocation(line: 325, column: 28, scope: !324)
!373 = !DILocation(line: 325, column: 26, scope: !324)
!374 = !DILocation(line: 331, column: 9, scope: !324)
!375 = !DILocation(line: 331, column: 15, scope: !324)
!376 = !DILocation(line: 331, column: 5, scope: !324)
!377 = !DILocation(line: 332, column: 22, scope: !324)
!378 = !DILocation(line: 334, column: 9, scope: !324)
!379 = !DILocation(line: 334, column: 18, scope: !324)
!380 = !DILocation(line: 334, column: 15, scope: !324)
!381 = !DILocation(line: 334, column: 5, scope: !324)
!382 = !DILocation(line: 335, column: 22, scope: !324)
!383 = !DILocation(line: 338, column: 52, scope: !324)
!384 = !DILocation(line: 338, column: 49, scope: !324)
!385 = !DILocation(line: 338, column: 5, scope: !324)
!386 = !DILocation(line: 339, column: 42, scope: !324)
!387 = !DILocation(line: 339, column: 48, scope: !324)
!388 = !DILocation(line: 339, column: 46, scope: !324)
!389 = !DILocation(line: 339, column: 33, scope: !324)
!390 = !DILocation(line: 339, column: 52, scope: !324)
!391 = !DILocation(line: 339, column: 51, scope: !324)
!392 = !DILocation(line: 339, column: 24, scope: !324)
!393 = !DILocation(line: 340, column: 25, scope: !324)
!394 = !DILocation(line: 340, column: 31, scope: !324)
!395 = !DILocation(line: 340, column: 29, scope: !324)
!396 = !DILocation(line: 340, column: 37, scope: !324)
!397 = !DILocation(line: 340, column: 41, scope: !324)
!398 = !DILocation(line: 340, column: 39, scope: !324)
!399 = !DILocation(line: 340, column: 35, scope: !324)
!400 = !DILocation(line: 341, column: 18, scope: !324)
!401 = !DILocation(line: 341, column: 15, scope: !324)
!402 = !DILocation(line: 341, column: 9, scope: !324)
!403 = !DILocation(line: 342, column: 26, scope: !324)
!404 = !DILocation(line: 347, column: 10, scope: !324)
!405 = !DILocation(line: 347, column: 16, scope: !324)
!406 = !DILocation(line: 347, column: 14, scope: !324)
!407 = !DILocation(line: 347, column: 5, scope: !324)
!408 = !DILocation(line: 348, column: 22, scope: !324)
!409 = !DILocation(line: 350, column: 10, scope: !324)
!410 = !DILocation(line: 350, column: 18, scope: !324)
!411 = !DILocation(line: 350, column: 21, scope: !324)
!412 = !DILocation(line: 350, column: 20, scope: !324)
!413 = !DILocation(line: 350, column: 14, scope: !324)
!414 = !DILocation(line: 350, column: 5, scope: !324)
!415 = !DILocation(line: 351, column: 22, scope: !324)
!416 = !DILocation(line: 354, column: 9, scope: !324)
!417 = !DILocation(line: 354, column: 5, scope: !324)
!418 = !DILocation(line: 358, column: 9, scope: !324)
!419 = !DILocation(line: 361, column: 9, scope: !324)
!420 = !DILocation(line: 364, column: 20, scope: !324)
!421 = !DILocation(line: 364, column: 17, scope: !324)
!422 = !DILocation(line: 364, column: 9, scope: !324)
!423 = !DILocation(line: 368, column: 13, scope: !324)
!424 = !DILocation(line: 371, column: 13, scope: !324)
!425 = !DILocation(line: 375, column: 13, scope: !324)
!426 = !DILocation(line: 394, column: 13, scope: !324)
!427 = !DILocation(line: 396, column: 29, scope: !324)
!428 = !DILocation(line: 396, column: 27, scope: !324)
!429 = !DILocation(line: 397, column: 60, scope: !324)
!430 = !DILocation(line: 397, column: 57, scope: !324)
!431 = !DILocation(line: 397, column: 13, scope: !324)
!432 = !DILocation(line: 400, column: 54, scope: !324)
!433 = !DILocation(line: 400, column: 55, scope: !324)
!434 = !DILocation(line: 400, column: 46, scope: !324)
!435 = !DILocation(line: 400, column: 59, scope: !324)
!436 = !DILocation(line: 400, column: 58, scope: !324)
!437 = !DILocation(line: 400, column: 37, scope: !324)
!438 = !DILocation(line: 400, column: 35, scope: !324)
!439 = !DILocation(line: 401, column: 33, scope: !324)
!440 = !DILocation(line: 401, column: 31, scope: !324)
!441 = !DILocation(line: 402, column: 69, scope: !324)
!442 = !DILocation(line: 402, column: 66, scope: !324)
!443 = !DILocation(line: 402, column: 19, scope: !324)
!444 = !DILocation(line: 404, column: 31, scope: !324)
!445 = !DILocation(line: 408, column: 75, scope: !324)
!446 = !DILocation(line: 408, column: 88, scope: !324)
!447 = !DILocation(line: 408, column: 13, scope: !324)
!448 = !DILocation(line: 413, column: 31, scope: !324)
!449 = !DILocation(line: 414, column: 33, scope: !324)
!450 = !DILocation(line: 415, column: 21, scope: !324)
!451 = !DILocation(line: 415, column: 29, scope: !324)
!452 = !DILocation(line: 415, column: 27, scope: !324)
!453 = !DILocation(line: 415, column: 19, scope: !324)
!454 = !DILocation(line: 416, column: 22, scope: !324)
!455 = !DILocation(line: 416, column: 19, scope: !324)
!456 = !DILocation(line: 416, column: 13, scope: !324)
!457 = !DILocation(line: 417, column: 23, scope: !324)
!458 = !DILocation(line: 419, column: 63, scope: !324)
!459 = !DILocation(line: 419, column: 60, scope: !324)
!460 = !DILocation(line: 419, column: 13, scope: !324)
!461 = !DILocation(line: 421, column: 23, scope: !324)
!462 = !DILocation(line: 423, column: 69, scope: !324)
!463 = !DILocation(line: 423, column: 13, scope: !324)
!464 = !DILocation(line: 426, column: 13, scope: !324)
!465 = !DILocation(line: 430, column: 13, scope: !324)
!466 = !DILocation(line: 433, column: 48, scope: !324)
!467 = !DILocation(line: 433, column: 22, scope: !324)
!468 = !DILocation(line: 433, column: 19, scope: !324)
!469 = !DILocation(line: 433, column: 13, scope: !324)
!470 = !DILocation(line: 436, column: 34, scope: !324)
!471 = !DILocation(line: 436, column: 39, scope: !324)
!472 = !DILocation(line: 436, column: 50, scope: !324)
!473 = !DILocation(line: 436, column: 17, scope: !324)
!474 = !DILocation(line: 452, column: 49, scope: !324)
!475 = !DILocation(line: 452, column: 64, scope: !324)
!476 = !DILocation(line: 452, column: 31, scope: !324)
!477 = !DILocation(line: 453, column: 40, scope: !324)
!478 = !DILocation(line: 453, column: 17, scope: !324)
!479 = !DILocation(line: 454, column: 50, scope: !324)
!480 = !DILocation(line: 454, column: 66, scope: !324)
!481 = !DILocation(line: 454, column: 32, scope: !324)
!482 = !DILocation(line: 455, column: 40, scope: !324)
!483 = !DILocation(line: 455, column: 17, scope: !324)
!484 = !DILocation(line: 456, column: 17, scope: !324)
!485 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit", scope: null, file: !486, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!486 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/filters/wse3.csl", directory: "")
!487 = !DILocation(line: 24, column: 3, scope: !488)
!488 = !DILexicalBlockFile(scope: !485, file: !486, discriminator: 0)
!489 = !DILocation(line: 24, column: 22, scope: !488)
!490 = !DILocation(line: 23, column: 3, scope: !488)
!491 = !DILocation(line: 22, column: 3, scope: !488)
!492 = !DILocation(line: 20, column: 37, scope: !488)
!493 = !DILocation(line: 20, column: 21, scope: !488)
!494 = !DILocation(line: 21, column: 11, scope: !488)
!495 = !DILocation(line: 21, column: 17, scope: !488)
!496 = !DILocation(line: 21, column: 3, scope: !488)
!497 = !DILocation(line: 22, column: 24, scope: !488)
!498 = !DILocation(line: 22, column: 30, scope: !488)
!499 = !DILocation(line: 23, column: 40, scope: !488)
!500 = !DILocation(line: 23, column: 22, scope: !488)
!501 = !DILocation(line: 23, column: 67, scope: !488)
!502 = !DILocation(line: 24, column: 26, scope: !488)
!503 = !DILocation(line: 24, column: 41, scope: !488)
!504 = !DILocation(line: 24, column: 39, scope: !488)
!505 = !DILocation(line: 24, column: 61, scope: !488)
!506 = !DILocation(line: 24, column: 76, scope: !488)
!507 = !DILocation(line: 24, column: 74, scope: !488)
!508 = !DILocation(line: 25, column: 21, scope: !488)
!509 = !DILocation(line: 25, column: 50, scope: !488)
!510 = !DILocation(line: 25, column: 3, scope: !488)
!511 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter", scope: null, file: !486, line: 30, type: !5, scopeLine: 30, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!512 = !DILocation(line: 30, column: 36, scope: !513)
!513 = !DILexicalBlockFile(scope: !511, file: !486, discriminator: 0)
!514 = !DILocation(line: 30, column: 20, scope: !513)
!515 = !DILocation(line: 31, column: 11, scope: !513)
!516 = !DILocation(line: 31, column: 23, scope: !513)
!517 = !DILocation(line: 31, column: 3, scope: !513)
!518 = !DILocation(line: 32, column: 21, scope: !513)
!519 = !DILocation(line: 32, column: 48, scope: !513)
!520 = !DILocation(line: 32, column: 60, scope: !513)
!521 = !DILocation(line: 32, column: 64, scope: !513)
!522 = !DILocation(line: 32, column: 3, scope: !513)
!523 = !DILocation(line: 30, column: 1, scope: !513)
!524 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter", scope: null, file: !486, line: 40, type: !5, scopeLine: 40, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!525 = !DILocation(line: 47, column: 3, scope: !526)
!526 = !DILexicalBlockFile(scope: !524, file: !486, discriminator: 0)
!527 = !DILocation(line: 48, column: 7, scope: !526)
!528 = !DILocation(line: 44, column: 3, scope: !526)
!529 = !DILocation(line: 43, column: 3, scope: !526)
!530 = !DILocation(line: 42, column: 3, scope: !526)
!531 = !DILocation(line: 40, column: 32, scope: !526)
!532 = !DILocation(line: 40, column: 16, scope: !526)
!533 = !DILocation(line: 41, column: 11, scope: !526)
!534 = !DILocation(line: 41, column: 19, scope: !526)
!535 = !DILocation(line: 41, column: 3, scope: !526)
!536 = !DILocation(line: 42, column: 40, scope: !526)
!537 = !DILocation(line: 42, column: 22, scope: !526)
!538 = !DILocation(line: 43, column: 26, scope: !526)
!539 = !DILocation(line: 43, column: 34, scope: !526)
!540 = !DILocation(line: 44, column: 25, scope: !526)
!541 = !DILocation(line: 44, column: 42, scope: !526)
!542 = !DILocation(line: 44, column: 40, scope: !526)
!543 = !DILocation(line: 45, column: 21, scope: !526)
!544 = !DILocation(line: 46, column: 35, scope: !526)
!545 = !DILocation(line: 46, column: 21, scope: !526)
!546 = !DILocation(line: 46, column: 50, scope: !526)
!547 = !DILocation(line: 45, column: 3, scope: !526)
!548 = !DILocation(line: 48, column: 11, scope: !526)
!549 = !DILocation(line: 48, column: 26, scope: !526)
!550 = !DILocation(line: 48, column: 43, scope: !526)
!551 = !DILocation(line: 48, column: 41, scope: !526)
!552 = !DILocation(line: 48, column: 54, scope: !526)
!553 = !DILocation(line: 48, column: 63, scope: !526)
!554 = !DILocation(line: 49, column: 21, scope: !526)
!555 = !DILocation(line: 49, column: 47, scope: !526)
!556 = !DILocation(line: 49, column: 3, scope: !526)
!557 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config", scope: null, file: !558, line: 33, type: !5, scopeLine: 33, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!558 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/filters/common.csl", directory: "")
!559 = !DILocation(line: 33, column: 46, scope: !560)
!560 = !DILexicalBlockFile(scope: !557, file: !558, discriminator: 0)
!561 = !DILocation(line: 33, column: 31, scope: !560)
!562 = !DILocation(line: 33, column: 15, scope: !560)
!563 = !DILocation(line: 34, column: 24, scope: !560)
!564 = !DILocation(line: 34, column: 23, scope: !560)
!565 = !DILocation(line: 34, column: 51, scope: !560)
!566 = !DILocation(line: 34, column: 35, scope: !560)
!567 = !DILocation(line: 34, column: 60, scope: !560)
!568 = !DILocation(line: 34, column: 73, scope: !560)
!569 = !DILocation(line: 34, column: 3, scope: !560)
!570 = !DILocation(line: 33, column: 1, scope: !560)
!571 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config", scope: null, file: !558, line: 38, type: !5, scopeLine: 38, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!572 = !DILocation(line: 38, column: 31, scope: !573)
!573 = !DILexicalBlockFile(scope: !571, file: !558, discriminator: 0)
!574 = !DILocation(line: 38, column: 15, scope: !573)
!575 = !DILocation(line: 39, column: 31, scope: !573)
!576 = !DILocation(line: 39, column: 30, scope: !573)
!577 = !DILocation(line: 39, column: 58, scope: !573)
!578 = !DILocation(line: 39, column: 42, scope: !573)
!579 = !DILocation(line: 39, column: 67, scope: !573)
!580 = !DILocation(line: 39, column: 10, scope: !573)
!581 = !DILocation(line: 39, column: 3, scope: !573)
!582 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit", scope: null, file: !583, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!583 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/teardown.csl", directory: "")
!584 = !DILocation(line: 43, column: 3, scope: !585)
!585 = !DILexicalBlockFile(scope: !582, file: !583, discriminator: 0)
!586 = !DILocation(line: 41, column: 3, scope: !585)
!587 = !DILocation(line: 40, column: 3, scope: !585)
!588 = !DILocation(line: 39, column: 9, scope: !585)
!589 = !DILocation(line: 40, column: 23, scope: !585)
!590 = !DILocation(line: 41, column: 70, scope: !585)
!591 = !DILocation(line: 41, column: 68, scope: !585)
!592 = !DILocation(line: 43, column: 27, scope: !585)
!593 = !DILocation(line: 43, column: 15, scope: !585)
!594 = !DILocation(line: 44, column: 15, scope: !585)
!595 = !DILocation(line: 44, column: 21, scope: !585)
!596 = !DILocation(line: 44, column: 27, scope: !585)
!597 = !DILocation(line: 44, column: 3, scope: !585)
!598 = !DILocation(line: 39, column: 1, scope: !585)
!599 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord", scope: null, file: !600, line: 4, type: !5, scopeLine: 4, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!600 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/layout.csl", directory: "")
!601 = !DILocation(line: 5, column: 10, scope: !602)
!602 = !DILexicalBlockFile(scope: !599, file: !600, discriminator: 0)
!603 = !DILocation(line: 5, column: 67, scope: !602)
!604 = !DILocation(line: 5, column: 3, scope: !602)
!605 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord", scope: null, file: !600, line: 8, type: !5, scopeLine: 8, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!606 = !DILocation(line: 9, column: 10, scope: !607)
!607 = !DILexicalBlockFile(scope: !605, file: !600, discriminator: 0)
!608 = !DILocation(line: 9, column: 67, scope: !607)
!609 = !DILocation(line: 9, column: 3, scope: !607)
!610 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord", scope: null, file: !611, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!611 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config.csl", directory: "")
!612 = !DILocation(line: 50, column: 3, scope: !613)
!613 = !DILexicalBlockFile(scope: !610, file: !611, discriminator: 0)
!614 = !DILocation(line: 43, column: 21, scope: !613)
!615 = !DILocation(line: 50, column: 57, scope: !613)
!616 = !DILocation(line: 50, column: 68, scope: !613)
!617 = !DILocation(line: 50, column: 41, scope: !613)
!618 = !DILocation(line: 50, column: 19, scope: !613)
!619 = !DILocation(line: 52, column: 10, scope: !613)
!620 = !DILocation(line: 52, column: 18, scope: !613)
!621 = !DILocation(line: 48, column: 22, scope: !613)
!622 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.get_x_coord", scope: null, file: !623, line: 171, type: !5, scopeLine: 171, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!623 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpyd2h.csl", directory: "")
!624 = !DILocation(line: 172, column: 12, scope: !625)
!625 = !DILexicalBlockFile(scope: !622, file: !623, discriminator: 0)
!626 = !DILocation(line: 172, column: 5, scope: !625)
!627 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.get_y_coord", scope: null, file: !623, line: 174, type: !5, scopeLine: 174, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!628 = !DILocation(line: 175, column: 12, scope: !629)
!629 = !DILexicalBlockFile(scope: !627, file: !623, discriminator: 0)
!630 = !DILocation(line: 175, column: 5, scope: !629)
!631 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval", scope: null, file: !623, line: 187, type: !5, scopeLine: 187, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!632 = !DILocation(line: 187, column: 23, scope: !633)
!633 = !DILexicalBlockFile(scope: !631, file: !623, discriminator: 0)
!634 = !DILocation(line: 188, column: 9, scope: !633)
!635 = !DILocation(line: 188, column: 20, scope: !633)
!636 = !DILocation(line: 188, column: 5, scope: !633)
!637 = !DILocation(line: 191, column: 23, scope: !633)
!638 = !DILocation(line: 191, column: 20, scope: !633)
!639 = !DILocation(line: 191, column: 9, scope: !633)
!640 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start", scope: null, file: !623, line: 383, type: !5, scopeLine: 383, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!641 = !DILocation(line: 386, column: 5, scope: !642)
!642 = !DILexicalBlockFile(scope: !640, file: !623, discriminator: 0)
!643 = !DILocation(line: 384, column: 72, scope: !642)
!644 = !DILocation(line: 384, column: 59, scope: !642)
!645 = !DILocation(line: 384, column: 46, scope: !642)
!646 = !DILocation(line: 384, column: 33, scope: !642)
!647 = !DILocation(line: 384, column: 19, scope: !642)
!648 = !DILocation(line: 384, column: 5, scope: !642)
!649 = !DILocation(line: 383, column: 32, scope: !642)
!650 = !DILocation(line: 383, column: 21, scope: !642)
!651 = !DILocation(line: 386, column: 26, scope: !642)
!652 = !DILocation(line: 388, column: 28, scope: !642)
!653 = !DILocation(line: 388, column: 17, scope: !642)
!654 = !DILocation(line: 389, column: 25, scope: !642)
!655 = !DILocation(line: 389, column: 23, scope: !642)
!656 = !DILocation(line: 391, column: 38, scope: !642)
!657 = !DILocation(line: 391, column: 20, scope: !642)
!658 = !DILocation(line: 391, column: 18, scope: !642)
!659 = !DILocation(line: 393, column: 7, scope: !642)
!660 = !DILocation(line: 395, column: 17, scope: !642)
!661 = !DILocation(line: 395, column: 15, scope: !642)
!662 = !DILocation(line: 397, column: 15, scope: !642)
!663 = !DILocation(line: 397, column: 13, scope: !642)
!664 = !DILocation(line: 398, column: 15, scope: !642)
!665 = !DILocation(line: 398, column: 25, scope: !642)
!666 = !DILocation(line: 398, column: 23, scope: !642)
!667 = !DILocation(line: 398, column: 31, scope: !642)
!668 = !DILocation(line: 398, column: 13, scope: !642)
!669 = !DILocation(line: 401, column: 10, scope: !642)
!670 = !DILocation(line: 401, column: 17, scope: !642)
!671 = !DILocation(line: 401, column: 14, scope: !642)
!672 = !DILocation(line: 401, column: 5, scope: !642)
!673 = !DILocation(line: 403, column: 48, scope: !642)
!674 = !DILocation(line: 403, column: 26, scope: !642)
!675 = !DILocation(line: 404, column: 26, scope: !642)
!676 = !DILocation(line: 404, column: 18, scope: !642)
!677 = !DILocation(line: 407, column: 48, scope: !642)
!678 = !DILocation(line: 407, column: 26, scope: !642)
!679 = !DILocation(line: 408, column: 27, scope: !642)
!680 = !DILocation(line: 408, column: 18, scope: !642)
!681 = !DILocation(line: 411, column: 14, scope: !642)
!682 = !DILocation(line: 414, column: 14, scope: !642)
!683 = !DILocation(line: 414, column: 11, scope: !642)
!684 = !DILocation(line: 414, column: 5, scope: !642)
!685 = !DILocation(line: 416, column: 44, scope: !642)
!686 = !DILocation(line: 416, column: 75, scope: !642)
!687 = !DILocation(line: 416, column: 59, scope: !642)
!688 = !DILocation(line: 416, column: 25, scope: !642)
!689 = !DILocation(line: 416, column: 23, scope: !642)
!690 = !DILocation(line: 418, column: 41, scope: !642)
!691 = !DILocation(line: 418, column: 23, scope: !642)
!692 = !DILocation(line: 419, column: 9, scope: !642)
!693 = !DILocation(line: 425, column: 44, scope: !642)
!694 = !DILocation(line: 425, column: 23, scope: !642)
!695 = !DILocation(line: 426, column: 41, scope: !642)
!696 = !DILocation(line: 426, column: 23, scope: !642)
!697 = !DILocation(line: 427, column: 9, scope: !642)
!698 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x", scope: null, file: !623, line: 448, type: !5, scopeLine: 448, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!699 = !DILocation(line: 448, column: 31, scope: !700)
!700 = !DILexicalBlockFile(scope: !698, file: !623, discriminator: 0)
!701 = !DILocation(line: 453, column: 5, scope: !700)
!702 = !DILocation(line: 456, column: 19, scope: !700)
!703 = !DILocation(line: 456, column: 17, scope: !700)
!704 = !DILocation(line: 461, column: 5, scope: !700)
!705 = !DILocation(line: 462, column: 28, scope: !700)
!706 = !DILocation(line: 462, column: 5, scope: !700)
!707 = !DILocation(line: 463, column: 5, scope: !700)
!708 = !DILocation(line: 464, column: 9, scope: !700)
!709 = !DILocation(line: 464, column: 10, scope: !700)
!710 = !DILocation(line: 464, column: 7, scope: !700)
!711 = !DILocation(line: 448, column: 1, scope: !700)
!712 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_send_data", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_send_data", scope: null, file: !623, line: 476, type: !5, scopeLine: 476, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!713 = !DILocation(line: 494, column: 9, scope: !714)
!714 = !DILexicalBlockFile(scope: !712, file: !623, discriminator: 0)
!715 = !DILocation(line: 478, column: 9, scope: !714)
!716 = !DILocation(line: 478, column: 13, scope: !714)
!717 = !DILocation(line: 478, column: 11, scope: !714)
!718 = !DILocation(line: 478, column: 5, scope: !714)
!719 = !DILocation(line: 479, column: 9, scope: !714)
!720 = !DILocation(line: 480, column: 32, scope: !714)
!721 = !DILocation(line: 480, column: 9, scope: !714)
!722 = !DILocation(line: 481, column: 17, scope: !714)
!723 = !DILocation(line: 481, column: 15, scope: !714)
!724 = !DILocation(line: 481, column: 9, scope: !714)
!725 = !DILocation(line: 482, column: 13, scope: !714)
!726 = !DILocation(line: 483, column: 51, scope: !714)
!727 = !DILocation(line: 483, column: 29, scope: !714)
!728 = !DILocation(line: 483, column: 27, scope: !714)
!729 = !DILocation(line: 485, column: 13, scope: !714)
!730 = !DILocation(line: 486, column: 51, scope: !714)
!731 = !DILocation(line: 486, column: 29, scope: !714)
!732 = !DILocation(line: 486, column: 27, scope: !714)
!733 = !DILocation(line: 488, column: 13, scope: !714)
!734 = !DILocation(line: 488, column: 14, scope: !714)
!735 = !DILocation(line: 488, column: 11, scope: !714)
!736 = !DILocation(line: 494, column: 30, scope: !714)
!737 = !DILocation(line: 496, column: 14, scope: !714)
!738 = !DILocation(line: 496, column: 25, scope: !714)
!739 = !DILocation(line: 496, column: 22, scope: !714)
!740 = !DILocation(line: 496, column: 9, scope: !714)
!741 = !DILocation(line: 497, column: 13, scope: !714)
!742 = !DILocation(line: 498, column: 13, scope: !714)
!743 = !DILocation(line: 499, column: 13, scope: !714)
!744 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl", scope: null, file: !623, line: 505, type: !5, scopeLine: 505, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!745 = !DILocation(line: 524, column: 13, scope: !746)
!746 = !DILexicalBlockFile(scope: !744, file: !623, discriminator: 0)
!747 = !DILocation(line: 506, column: 14, scope: !746)
!748 = !DILocation(line: 506, column: 11, scope: !746)
!749 = !DILocation(line: 506, column: 5, scope: !746)
!750 = !DILocation(line: 508, column: 9, scope: !746)
!751 = !DILocation(line: 509, column: 32, scope: !746)
!752 = !DILocation(line: 509, column: 9, scope: !746)
!753 = !DILocation(line: 510, column: 9, scope: !746)
!754 = !DILocation(line: 514, column: 13, scope: !746)
!755 = !DILocation(line: 514, column: 17, scope: !746)
!756 = !DILocation(line: 514, column: 15, scope: !746)
!757 = !DILocation(line: 514, column: 9, scope: !746)
!758 = !DILocation(line: 518, column: 13, scope: !746)
!759 = !DILocation(line: 519, column: 36, scope: !746)
!760 = !DILocation(line: 519, column: 13, scope: !746)
!761 = !DILocation(line: 520, column: 13, scope: !746)
!762 = !DILocation(line: 524, column: 34, scope: !746)
!763 = !DILocation(line: 526, column: 18, scope: !746)
!764 = !DILocation(line: 526, column: 29, scope: !746)
!765 = !DILocation(line: 526, column: 26, scope: !746)
!766 = !DILocation(line: 526, column: 13, scope: !746)
!767 = !DILocation(line: 529, column: 17, scope: !746)
!768 = !DILocation(line: 530, column: 17, scope: !746)
!769 = !DILocation(line: 531, column: 17, scope: !746)
!770 = !DILocation(line: 534, column: 17, scope: !746)
!771 = !DILocation(line: 535, column: 40, scope: !746)
!772 = !DILocation(line: 535, column: 17, scope: !746)
!773 = !DILocation(line: 536, column: 17, scope: !746)
!774 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.d2h_configure", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.d2h_configure", scope: null, file: !623, line: 593, type: !5, scopeLine: 593, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!775 = !DILocation(line: 617, column: 26, scope: !776)
!776 = !DILexicalBlockFile(scope: !774, file: !623, discriminator: 0)
!777 = !DILocation(line: 612, column: 47, scope: !776)
!778 = !DILocation(line: 612, column: 27, scope: !776)
!779 = !DILocation(line: 602, column: 5, scope: !776)
!780 = !DILocation(line: 601, column: 5, scope: !776)
!781 = !DILocation(line: 599, column: 5, scope: !776)
!782 = !DILocation(line: 598, column: 5, scope: !776)
!783 = !DILocation(line: 596, column: 5, scope: !776)
!784 = !DILocation(line: 595, column: 5, scope: !776)
!785 = !DILocation(line: 593, column: 86, scope: !776)
!786 = !DILocation(line: 593, column: 70, scope: !776)
!787 = !DILocation(line: 593, column: 60, scope: !776)
!788 = !DILocation(line: 593, column: 52, scope: !776)
!789 = !DILocation(line: 593, column: 44, scope: !776)
!790 = !DILocation(line: 593, column: 35, scope: !776)
!791 = !DILocation(line: 593, column: 26, scope: !776)
!792 = !DILocation(line: 593, column: 18, scope: !776)
!793 = !DILocation(line: 595, column: 26, scope: !776)
!794 = !DILocation(line: 596, column: 26, scope: !776)
!795 = !DILocation(line: 598, column: 23, scope: !776)
!796 = !DILocation(line: 599, column: 23, scope: !776)
!797 = !DILocation(line: 599, column: 28, scope: !776)
!798 = !DILocation(line: 599, column: 26, scope: !776)
!799 = !DILocation(line: 599, column: 29, scope: !776)
!800 = !DILocation(line: 601, column: 24, scope: !776)
!801 = !DILocation(line: 602, column: 24, scope: !776)
!802 = !DILocation(line: 602, column: 29, scope: !776)
!803 = !DILocation(line: 602, column: 27, scope: !776)
!804 = !DILocation(line: 602, column: 30, scope: !776)
!805 = !DILocation(line: 611, column: 20, scope: !776)
!806 = !DILocation(line: 612, column: 11, scope: !776)
!807 = !DILocation(line: 612, column: 18, scope: !776)
!808 = !DILocation(line: 612, column: 15, scope: !776)
!809 = !DILocation(line: 612, column: 32, scope: !776)
!810 = !DILocation(line: 612, column: 39, scope: !776)
!811 = !DILocation(line: 612, column: 36, scope: !776)
!812 = !DILocation(line: 612, column: 52, scope: !776)
!813 = !DILocation(line: 612, column: 59, scope: !776)
!814 = !DILocation(line: 612, column: 56, scope: !776)
!815 = !DILocation(line: 612, column: 5, scope: !776)
!816 = !DILocation(line: 613, column: 24, scope: !776)
!817 = !DILocation(line: 616, column: 15, scope: !776)
!818 = !DILocation(line: 617, column: 11, scope: !776)
!819 = !DILocation(line: 617, column: 18, scope: !776)
!820 = !DILocation(line: 617, column: 15, scope: !776)
!821 = !DILocation(line: 617, column: 30, scope: !776)
!822 = !DILocation(line: 617, column: 5, scope: !776)
!823 = !DILocation(line: 618, column: 19, scope: !776)
!824 = !DILocation(line: 621, column: 9, scope: !776)
!825 = !DILocation(line: 621, column: 5, scope: !776)
!826 = !DILocation(line: 627, column: 9, scope: !776)
!827 = !DILocation(line: 629, column: 13, scope: !776)
!828 = !DILocation(line: 629, column: 25, scope: !776)
!829 = !DILocation(line: 629, column: 21, scope: !776)
!830 = !DILocation(line: 629, column: 9, scope: !776)
!831 = !DILocation(line: 632, column: 13, scope: !776)
!832 = !DILocation(line: 636, column: 13, scope: !776)
!833 = !DILocation(line: 641, column: 9, scope: !776)
!834 = !DILocation(line: 646, column: 13, scope: !776)
!835 = !DILocation(line: 646, column: 9, scope: !776)
!836 = !DILocation(line: 647, column: 30, scope: !776)
!837 = !DILocation(line: 647, column: 35, scope: !776)
!838 = !DILocation(line: 647, column: 46, scope: !776)
!839 = !DILocation(line: 647, column: 50, scope: !776)
!840 = !DILocation(line: 647, column: 54, scope: !776)
!841 = !DILocation(line: 647, column: 57, scope: !776)
!842 = !DILocation(line: 647, column: 60, scope: !776)
!843 = !DILocation(line: 647, column: 63, scope: !776)
!844 = !DILocation(line: 647, column: 13, scope: !776)
!845 = !DILocation(line: 661, column: 9, scope: !776)
!846 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit", scope: null, file: !583, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!847 = !DILocation(line: 43, column: 3, scope: !848)
!848 = !DILexicalBlockFile(scope: !846, file: !583, discriminator: 0)
!849 = !DILocation(line: 41, column: 3, scope: !848)
!850 = !DILocation(line: 40, column: 3, scope: !848)
!851 = !DILocation(line: 39, column: 9, scope: !848)
!852 = !DILocation(line: 40, column: 23, scope: !848)
!853 = !DILocation(line: 41, column: 70, scope: !848)
!854 = !DILocation(line: 41, column: 68, scope: !848)
!855 = !DILocation(line: 43, column: 27, scope: !848)
!856 = !DILocation(line: 43, column: 15, scope: !848)
!857 = !DILocation(line: 44, column: 15, scope: !848)
!858 = !DILocation(line: 44, column: 21, scope: !848)
!859 = !DILocation(line: 44, column: 27, scope: !848)
!860 = !DILocation(line: 44, column: 3, scope: !848)
!861 = !DILocation(line: 39, column: 1, scope: !848)
!862 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord", scope: null, file: !600, line: 4, type: !5, scopeLine: 4, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!863 = !DILocation(line: 5, column: 10, scope: !864)
!864 = !DILexicalBlockFile(scope: !862, file: !600, discriminator: 0)
!865 = !DILocation(line: 5, column: 67, scope: !864)
!866 = !DILocation(line: 5, column: 3, scope: !864)
!867 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord", scope: null, file: !600, line: 8, type: !5, scopeLine: 8, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!868 = !DILocation(line: 9, column: 10, scope: !869)
!869 = !DILexicalBlockFile(scope: !867, file: !600, discriminator: 0)
!870 = !DILocation(line: 9, column: 67, scope: !869)
!871 = !DILocation(line: 9, column: 3, scope: !869)
!872 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord", scope: null, file: !611, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!873 = !DILocation(line: 50, column: 3, scope: !874)
!874 = !DILexicalBlockFile(scope: !872, file: !611, discriminator: 0)
!875 = !DILocation(line: 43, column: 21, scope: !874)
!876 = !DILocation(line: 50, column: 57, scope: !874)
!877 = !DILocation(line: 50, column: 68, scope: !874)
!878 = !DILocation(line: 50, column: 41, scope: !874)
!879 = !DILocation(line: 50, column: 19, scope: !874)
!880 = !DILocation(line: 52, column: 10, scope: !874)
!881 = !DILocation(line: 52, column: 18, scope: !874)
!882 = !DILocation(line: 48, column: 22, scope: !874)
!883 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr", linkageName: "sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr", scope: null, file: !884, line: 11, type: !5, scopeLine: 11, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!884 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/input_queue_config.csl", directory: "")
!885 = !DILocation(line: 11, column: 32, scope: !886)
!886 = !DILexicalBlockFile(scope: !883, file: !884, discriminator: 0)
!887 = !DILocation(line: 12, column: 80, scope: !886)
!888 = !DILocation(line: 12, column: 69, scope: !886)
!889 = !DILocation(line: 12, column: 39, scope: !886)
!890 = !DILocation(line: 12, column: 3, scope: !886)
!891 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue", linkageName: "sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue", scope: null, file: !884, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!892 = !DILocation(line: 46, column: 3, scope: !893)
!893 = !DILexicalBlockFile(scope: !891, file: !884, discriminator: 0)
!894 = !DILocation(line: 45, column: 3, scope: !893)
!895 = !DILocation(line: 39, column: 42, scope: !893)
!896 = !DILocation(line: 39, column: 34, scope: !893)
!897 = !DILocation(line: 39, column: 24, scope: !893)
!898 = !DILocation(line: 45, column: 44, scope: !893)
!899 = !DILocation(line: 45, column: 16, scope: !893)
!900 = !DILocation(line: 46, column: 30, scope: !893)
!901 = !DILocation(line: 46, column: 18, scope: !893)
!902 = !DILocation(line: 56, column: 9, scope: !893)
!903 = !DILocation(line: 56, column: 5, scope: !893)
!904 = !DILocation(line: 58, column: 13, scope: !893)
!905 = !DILocation(line: 58, column: 17, scope: !893)
!906 = !DILocation(line: 58, column: 11, scope: !893)
!907 = !DILocation(line: 61, column: 13, scope: !893)
!908 = !DILocation(line: 61, column: 17, scope: !893)
!909 = !DILocation(line: 61, column: 11, scope: !893)
!910 = !DILocation(line: 66, column: 9, scope: !893)
!911 = !DILocation(line: 66, column: 13, scope: !893)
!912 = !DILocation(line: 66, column: 7, scope: !893)
!913 = !DILocation(line: 68, column: 9, scope: !893)
!914 = !DILocation(line: 68, column: 24, scope: !893)
!915 = !DILocation(line: 68, column: 13, scope: !893)
!916 = !DILocation(line: 68, column: 7, scope: !893)
!917 = !DILocation(line: 70, column: 15, scope: !893)
!918 = !DILocation(line: 70, column: 21, scope: !893)
!919 = !DILocation(line: 70, column: 3, scope: !893)
!920 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr", linkageName: "sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr", scope: null, file: !921, line: 11, type: !5, scopeLine: 11, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!921 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/output_queue_config.csl", directory: "")
!922 = !DILocation(line: 11, column: 33, scope: !923)
!923 = !DILexicalBlockFile(scope: !920, file: !921, discriminator: 0)
!924 = !DILocation(line: 12, column: 82, scope: !923)
!925 = !DILocation(line: 12, column: 40, scope: !923)
!926 = !DILocation(line: 12, column: 3, scope: !923)
!927 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue", linkageName: "sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue", scope: null, file: !921, line: 31, type: !5, scopeLine: 31, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!928 = !DILocation(line: 38, column: 3, scope: !929)
!929 = !DILexicalBlockFile(scope: !927, file: !921, discriminator: 0)
!930 = !DILocation(line: 37, column: 3, scope: !929)
!931 = !DILocation(line: 31, column: 35, scope: !929)
!932 = !DILocation(line: 31, column: 25, scope: !929)
!933 = !DILocation(line: 37, column: 45, scope: !929)
!934 = !DILocation(line: 37, column: 16, scope: !929)
!935 = !DILocation(line: 38, column: 30, scope: !929)
!936 = !DILocation(line: 38, column: 18, scope: !929)
!937 = !DILocation(line: 41, column: 9, scope: !929)
!938 = !DILocation(line: 41, column: 13, scope: !929)
!939 = !DILocation(line: 41, column: 7, scope: !929)
!940 = !DILocation(line: 43, column: 9, scope: !929)
!941 = !DILocation(line: 43, column: 24, scope: !929)
!942 = !DILocation(line: 43, column: 13, scope: !929)
!943 = !DILocation(line: 43, column: 27, scope: !929)
!944 = !DILocation(line: 43, column: 7, scope: !929)
!945 = !DILocation(line: 45, column: 15, scope: !929)
!946 = !DILocation(line: 45, column: 21, scope: !929)
!947 = !DILocation(line: 45, column: 3, scope: !929)
!948 = !DILocation(line: 31, column: 1, scope: !929)
!949 = distinct !DISubprogram(name: ".get_tensor_ptr", linkageName: ".get_tensor_ptr", scope: null, file: !4, line: 1, type: !5, scopeLine: 1, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!950 = !DILocation(line: 1, column: 1, scope: !951)
!951 = !DILexicalBlockFile(scope: !949, file: !4, discriminator: 0)
!952 = distinct !DISubprogram(name: "__generic0sys_mod.sys_mod.tile_config.queue_flush.exit", linkageName: "__generic0sys_mod.sys_mod.tile_config.queue_flush.exit", scope: null, file: !953, line: 12, type: !5, scopeLine: 12, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!953 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/queue_flush.csl", directory: "")
!954 = !DILocation(line: 24, column: 3, scope: !955)
!955 = !DILexicalBlockFile(scope: !952, file: !953, discriminator: 0)
!956 = !DILocation(line: 12, column: 1, scope: !955)
!957 = distinct !DISubprogram(name: "__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position", linkageName: "__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position", scope: null, file: !958, line: 30, type: !5, scopeLine: 30, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!958 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/switch_config.csl", directory: "")
!959 = !DILocation(line: 34, column: 3, scope: !960)
!960 = !DILexicalBlockFile(scope: !957, file: !958, discriminator: 0)
!961 = !DILocation(line: 32, column: 3, scope: !960)
!962 = !DILocation(line: 30, column: 27, scope: !960)
!963 = !DILocation(line: 33, column: 7, scope: !960)
!964 = !DILocation(line: 34, column: 36, scope: !960)
!965 = !DILocation(line: 34, column: 24, scope: !960)
!966 = !DILocation(line: 35, column: 3, scope: !960)
!967 = !DILocation(line: 35, column: 18, scope: !960)
!968 = !DILocation(line: 36, column: 15, scope: !960)
!969 = !DILocation(line: 36, column: 21, scope: !960)
!970 = !DILocation(line: 36, column: 3, scope: !960)
!971 = !DILocation(line: 30, column: 1, scope: !960)
!972 = distinct !DISubprogram(name: "__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", linkageName: "__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", scope: null, file: !973, line: 96, type: !5, scopeLine: 96, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!973 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/color_config.csl", directory: "")
!974 = !DILocation(line: 99, column: 3, scope: !975)
!975 = !DILexicalBlockFile(scope: !972, file: !973, discriminator: 0)
!976 = !DILocation(line: 98, column: 3, scope: !975)
!977 = !DILocation(line: 96, column: 17, scope: !975)
!978 = !DILocation(line: 98, column: 16, scope: !975)
!979 = !DILocation(line: 99, column: 29, scope: !975)
!980 = !DILocation(line: 99, column: 17, scope: !975)
!981 = !DILocation(line: 100, column: 13, scope: !975)
!982 = !DILocation(line: 100, column: 21, scope: !975)
!983 = !DILocation(line: 100, column: 11, scope: !975)
!984 = !DILocation(line: 104, column: 7, scope: !975)
!985 = !DILocation(line: 104, column: 50, scope: !975)
!986 = !DILocation(line: 104, column: 18, scope: !975)
!987 = !DILocation(line: 104, column: 15, scope: !975)
!988 = !DILocation(line: 121, column: 7, scope: !975)
!989 = !DILocation(line: 121, column: 50, scope: !975)
!990 = !DILocation(line: 121, column: 18, scope: !975)
!991 = !DILocation(line: 121, column: 15, scope: !975)
!992 = !DILocation(line: 128, column: 15, scope: !975)
!993 = !DILocation(line: 128, column: 21, scope: !975)
!994 = !DILocation(line: 128, column: 3, scope: !975)
!995 = !DILocation(line: 96, column: 1, scope: !975)
!996 = distinct !DISubprogram(name: "__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", linkageName: "__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", scope: null, file: !973, line: 96, type: !5, scopeLine: 96, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!997 = !DILocation(line: 99, column: 3, scope: !998)
!998 = !DILexicalBlockFile(scope: !996, file: !973, discriminator: 0)
!999 = !DILocation(line: 98, column: 3, scope: !998)
!1000 = !DILocation(line: 96, column: 17, scope: !998)
!1001 = !DILocation(line: 98, column: 16, scope: !998)
!1002 = !DILocation(line: 99, column: 29, scope: !998)
!1003 = !DILocation(line: 99, column: 17, scope: !998)
!1004 = !DILocation(line: 100, column: 13, scope: !998)
!1005 = !DILocation(line: 100, column: 21, scope: !998)
!1006 = !DILocation(line: 100, column: 11, scope: !998)
!1007 = !DILocation(line: 104, column: 7, scope: !998)
!1008 = !DILocation(line: 104, column: 50, scope: !998)
!1009 = !DILocation(line: 104, column: 18, scope: !998)
!1010 = !DILocation(line: 104, column: 15, scope: !998)
!1011 = !DILocation(line: 121, column: 7, scope: !998)
!1012 = !DILocation(line: 121, column: 50, scope: !998)
!1013 = !DILocation(line: 121, column: 18, scope: !998)
!1014 = !DILocation(line: 121, column: 15, scope: !998)
!1015 = !DILocation(line: 128, column: 15, scope: !998)
!1016 = !DILocation(line: 128, column: 21, scope: !998)
!1017 = !DILocation(line: 128, column: 3, scope: !998)
!1018 = !DILocation(line: 96, column: 1, scope: !998)
!1019 = distinct !DISubprogram(name: "__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", linkageName: "__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", scope: null, file: !973, line: 60, type: !5, scopeLine: 60, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1020 = !DILocation(line: 61, column: 3, scope: !1021)
!1021 = !DILexicalBlockFile(scope: !1019, file: !973, discriminator: 0)
!1022 = !DILocation(line: 60, column: 46, scope: !1021)
!1023 = !DILocation(line: 61, column: 16, scope: !1021)
!1024 = !DILocation(line: 72, column: 5, scope: !1021)
!1025 = !DILocation(line: 72, column: 12, scope: !1021)
!1026 = !DILocation(line: 74, column: 10, scope: !1021)
!1027 = !DILocation(line: 74, column: 3, scope: !1021)
!1028 = distinct !DISubprogram(name: "__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes", linkageName: "__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes", scope: null, file: !973, line: 77, type: !5, scopeLine: 77, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1029 = !DILocation(line: 78, column: 3, scope: !1030)
!1030 = !DILexicalBlockFile(scope: !1028, file: !973, discriminator: 0)
!1031 = !DILocation(line: 77, column: 46, scope: !1030)
!1032 = !DILocation(line: 78, column: 16, scope: !1030)
!1033 = !DILocation(line: 86, column: 5, scope: !1030)
!1034 = !DILocation(line: 86, column: 12, scope: !1030)
!1035 = !DILocation(line: 91, column: 10, scope: !1030)
!1036 = !DILocation(line: 91, column: 3, scope: !1030)
!1037 = distinct !DISubprogram(name: "__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", linkageName: "__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", scope: null, file: !973, line: 60, type: !5, scopeLine: 60, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1038 = !DILocation(line: 61, column: 3, scope: !1039)
!1039 = !DILexicalBlockFile(scope: !1037, file: !973, discriminator: 0)
!1040 = !DILocation(line: 60, column: 46, scope: !1039)
!1041 = !DILocation(line: 61, column: 16, scope: !1039)
!1042 = !DILocation(line: 63, column: 5, scope: !1039)
!1043 = !DILocation(line: 63, column: 12, scope: !1039)
!1044 = !DILocation(line: 74, column: 10, scope: !1039)
!1045 = !DILocation(line: 74, column: 3, scope: !1039)
!1046 = distinct !DISubprogram(name: "__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction", linkageName: "__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction", scope: null, file: !973, line: 52, type: !5, scopeLine: 52, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1047 = !DILocation(line: 55, column: 3, scope: !1048)
!1048 = !DILexicalBlockFile(scope: !1046, file: !973, discriminator: 0)
!1049 = !DILocation(line: 54, column: 3, scope: !1048)
!1050 = !DILocation(line: 52, column: 23, scope: !1048)
!1051 = !DILocation(line: 54, column: 16, scope: !1048)
!1052 = !DILocation(line: 55, column: 29, scope: !1048)
!1053 = !DILocation(line: 55, column: 17, scope: !1048)
!1054 = !DILocation(line: 56, column: 3, scope: !1048)
!1055 = !DILocation(line: 56, column: 11, scope: !1048)
!1056 = !DILocation(line: 57, column: 15, scope: !1048)
!1057 = !DILocation(line: 57, column: 21, scope: !1048)
!1058 = !DILocation(line: 57, column: 3, scope: !1048)
!1059 = !DILocation(line: 52, column: 1, scope: !1048)
!1060 = distinct !DISubprogram(name: "__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction", linkageName: "__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction", scope: null, file: !973, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1061 = !DILocation(line: 23, column: 3, scope: !1062)
!1062 = !DILexicalBlockFile(scope: !1060, file: !973, discriminator: 0)
!1063 = !DILocation(line: 22, column: 3, scope: !1062)
!1064 = !DILocation(line: 20, column: 21, scope: !1062)
!1065 = !DILocation(line: 22, column: 16, scope: !1062)
!1066 = !DILocation(line: 23, column: 29, scope: !1062)
!1067 = !DILocation(line: 23, column: 17, scope: !1062)
!1068 = !DILocation(line: 24, column: 3, scope: !1062)
!1069 = !DILocation(line: 24, column: 11, scope: !1062)
!1070 = !DILocation(line: 25, column: 15, scope: !1062)
!1071 = !DILocation(line: 25, column: 21, scope: !1062)
!1072 = !DILocation(line: 25, column: 3, scope: !1062)
!1073 = !DILocation(line: 20, column: 1, scope: !1062)
module asm ".section \22.pe_debug_info\22, \22\22"
module asm ".section \22.note\22, \22\22"
