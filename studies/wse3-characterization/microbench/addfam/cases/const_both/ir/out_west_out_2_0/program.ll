; ModuleID = '/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/runtime/layout_west_demux_cmdfan_multi.csl'
source_filename = "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/runtime/layout_west_demux_cmdfan_multi.csl"
target datalayout = "e-ni:0-p:16:16-i1:16-i16:16-i32:32-i64:64-f32:32-f64:64"
target triple = "cs_sdr-cerebras-csos"

@"$$csl_base_address$$0$$fifo_buffer" = dso_local global [7168 x float] zeroinitializer, align 16
@"$$csl_base_address$$1$$fifo_cmd_buffer" = dso_local global [1024 x i32] zeroinitializer, align 16
@"$$csl_base_address$$4$$cmd" = dso_local global [128 x i32] zeroinitializer, align 4
@stack_u32 = internal global [128 x i32] zeroinitializer, align 4
@stack_last = internal global i16 0, align 4
@memcpyH2D_c = internal global i16 0, align 4
@memcpyH2D_px = internal global i16 0, align 4
@memcpyH2D_py = internal global i16 0, align 4
@memcpyH2D_w = internal global i16 0, align 4
@memcpyH2D_h = internal global i16 0, align 4
@memcpyH2D_addr = internal global i16 0, align 4
@memcpyH2D_pe_length = internal global i16 0, align 4
@memcpyH2D_is_half = internal global i16 0, align 4
@memcpyH2D_memcpy_optype = internal global i16 0, align 4
@memcpyH2D_row_stride = internal global i16 0, align 4
@memcpyH2D_col_stride = internal global i16 0, align 4
@memcpyH2D_one_over_row_stride = internal global float 0.000000e+00, align 4
@memcpyH2D_one_over_col_stride = internal global float 0.000000e+00, align 4
@num_send = internal global i16 0, align 4
@idx_send = internal global i16 0, align 4
@"$$csl_base_address$$3$$teardown_buf" = dso_local constant [1 x i32] [i32 165646921], align 4
@_pe_id = internal global i16 0, align 4
@fab_trans_data_wdsd = internal global <{ i16, i16, i16, i16 }> <{ i16 1, i16 31, i16 -30258, i16 16 }>, align 4
@fab_recv_data_wdsd = internal global <{ i16, i16, i16, i16 }> <{ i16 1, i16 3999, i16 -32562, i16 16 }>, align 4
@fab_recv_cmdfifo_wdsd = internal global <{ i16, i16, i16, i16 }> <{ i16 1, i16 3999, i16 -23346, i16 16 }>, align 4
@fab_trans_cmdfifo_wdsd = internal global <{ i16, i16, i16, i16 }> <{ i16 1, i16 31, i16 -21042, i16 16 }>, align 4
@memcpy_use_addr_color = dso_local global i16 31, section ".memcpy_cfg", align 4
@sys_cmd_push = dso_local global i16 33, align 4
@sys_cmd_h2d = dso_local global i16 34, align 4
@sys_cmd_d2h = dso_local global i16 35, align 4
@sys_cmd_rpc = dso_local global i16 36, align 4
@CHECK_AND_IGNORE = internal global i16 37, align 4
@memcpy_version = dso_local global i16 5, align 4
@"$$csl_base_address$$2$$init_sym" = dso_local global [6 x i32] zeroinitializer, align 4
@__dsr_lowmeminit_ = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 4154, i16 -25714, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__0 = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 lshr (i16 ptrtoint ([128 x i32]* @"$$csl_base_address$$4$$cmd" to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__1 = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 4098, i16 -25714, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__2 = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 lshr (i16 ptrtoint ([1 x i32]* @"$$csl_base_address$$3$$teardown_buf" to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__3 = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 4098, i16 -30322, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__4 = internal constant <{ i16, i16, i16, i16 }> <{ i16 6, i16 4098, i16 -25714, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__5 = internal constant <{ i16, i16, i16, i16 }> <{ i16 6, i16 lshr (i16 ptrtoint ([6 x i32]* @"$$csl_base_address$$2$$init_sym" to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4

declare i8* @malloc(i64)

declare void @free(i8*)

define internal i16 @get_pe_id() !dbg !3 {
  %1 = call i16 @fabric.get_y_coord(), !dbg !7
  ret i16 %1, !dbg !9
}

define internal void @stack_push(i16 %0) !dbg !10 {
  %2 = alloca i16*, i16 1, align 8, !dbg !11
  %3 = alloca i16, i16 1, align 2, !dbg !13
  store i16 %0, i16* %3, align 2, !dbg !13
  %4 = load i16, i16* @stack_last, align 2, !dbg !14
  %5 = icmp slt i16 %4, 128, !dbg !15
  br i1 %5, label %6, label %7, !dbg !16

6:                                                ; preds = %1
  br label %8, !dbg !16

7:                                                ; preds = %1
  call void asm sideeffect "hcf", ""(), !dbg !16
  br label %8, !dbg !16

8:                                                ; preds = %6, %7
  store i16* bitcast ([128 x i32]* @stack_u32 to i16*), i16** %2, align 8, !dbg !11
  %9 = load i16, i16* %3, align 2, !dbg !17
  %10 = load i16*, i16** %2, align 8, !dbg !18
  %11 = load i16, i16* @stack_last, align 2, !dbg !19
  %12 = getelementptr i16, i16* %10, i16 %11, !dbg !20
  store i16 %9, i16* %12, align 2, !dbg !21
  %13 = load i16, i16* @stack_last, align 2, !dbg !22
  %14 = add i16 %13, 1, !dbg !23
  store i16 %14, i16* @stack_last, align 2, !dbg !24
  ret void, !dbg !25
}

define internal void @cmd_decode_h2d() !dbg !26 {
  %1 = alloca float, i16 1, align 4, !dbg !27
  %2 = alloca float, i16 1, align 4, !dbg !29
  %3 = alloca i16, i16 1, align 2, !dbg !30
  %4 = alloca i16, i16 1, align 2, !dbg !31
  %5 = alloca i16, i16 1, align 2, !dbg !32
  %6 = alloca i16, i16 1, align 2, !dbg !33
  %7 = alloca i16, i16 1, align 2, !dbg !34
  %8 = alloca i16, i16 1, align 2, !dbg !35
  %9 = alloca i16, i16 1, align 2, !dbg !36
  %10 = alloca i16, i16 1, align 2, !dbg !37
  %11 = alloca i16, i16 1, align 2, !dbg !38
  %12 = alloca i16, i16 1, align 2, !dbg !39
  %13 = alloca i16, i16 1, align 2, !dbg !40
  %14 = alloca i16*, i16 1, align 8, !dbg !41
  %15 = load i16, i16* @stack_last, align 2, !dbg !42
  %16 = icmp eq i16 %15, 15, !dbg !43
  br i1 %16, label %17, label %18, !dbg !44

17:                                               ; preds = %0
  br label %19, !dbg !44

18:                                               ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !44
  br label %19, !dbg !44

19:                                               ; preds = %17, %18
  store i16* bitcast ([128 x i32]* @stack_u32 to i16*), i16** %14, align 8, !dbg !41
  %20 = load i16*, i16** %14, align 8, !dbg !45
  %21 = load i16, i16* %20, align 2, !dbg !46
  store i16 %21, i16* %13, align 2, !dbg !40
  %22 = load i16*, i16** %14, align 8, !dbg !47
  %23 = getelementptr i16, i16* %22, i2 1, !dbg !48
  %24 = load i16, i16* %23, align 2, !dbg !48
  store i16 %24, i16* %12, align 2, !dbg !39
  %25 = load i16*, i16** %14, align 8, !dbg !49
  %26 = getelementptr i16, i16* %25, i3 2, !dbg !50
  %27 = load i16, i16* %26, align 2, !dbg !50
  store i16 %27, i16* %11, align 2, !dbg !38
  %28 = load i16*, i16** %14, align 8, !dbg !51
  %29 = getelementptr i16, i16* %28, i3 3, !dbg !52
  %30 = load i16, i16* %29, align 2, !dbg !52
  store i16 %30, i16* %10, align 2, !dbg !37
  %31 = load i16*, i16** %14, align 8, !dbg !53
  %32 = getelementptr i16, i16* %31, i4 4, !dbg !54
  %33 = load i16, i16* %32, align 2, !dbg !54
  store i16 %33, i16* %9, align 2, !dbg !36
  %34 = load i16*, i16** %14, align 8, !dbg !55
  %35 = getelementptr i16, i16* %34, i4 5, !dbg !56
  %36 = load i16, i16* %35, align 2, !dbg !56
  store i16 %36, i16* %8, align 2, !dbg !35
  %37 = load i16*, i16** %14, align 8, !dbg !57
  %38 = getelementptr i16, i16* %37, i4 6, !dbg !58
  %39 = load i16, i16* %38, align 2, !dbg !58
  store i16 %39, i16* %7, align 2, !dbg !34
  %40 = load i16*, i16** %14, align 8, !dbg !59
  %41 = getelementptr i16, i16* %40, i4 7, !dbg !60
  %42 = load i16, i16* %41, align 2, !dbg !60
  store i16 %42, i16* %6, align 2, !dbg !33
  %43 = load i16*, i16** %14, align 8, !dbg !61
  %44 = getelementptr i16, i16* %43, i5 8, !dbg !62
  %45 = load i16, i16* %44, align 2, !dbg !62
  store i16 %45, i16* %5, align 2, !dbg !32
  %46 = load i16*, i16** %14, align 8, !dbg !63
  %47 = getelementptr i16, i16* %46, i5 9, !dbg !64
  %48 = load i16, i16* %47, align 2, !dbg !64
  store i16 %48, i16* %4, align 2, !dbg !31
  %49 = load i16*, i16** %14, align 8, !dbg !65
  %50 = getelementptr i16, i16* %49, i5 10, !dbg !66
  %51 = load i16, i16* %50, align 2, !dbg !66
  store i16 %51, i16* %3, align 2, !dbg !30
  %52 = load i16*, i16** %14, align 8, !dbg !67
  %53 = getelementptr i16, i16* %52, i5 12, !dbg !68
  %54 = load i16, i16* %53, align 2, !dbg !68
  %55 = zext i16 %54 to i32, !dbg !69
  %56 = load i16*, i16** %14, align 8, !dbg !70
  %57 = getelementptr i16, i16* %56, i5 11, !dbg !71
  %58 = load i16, i16* %57, align 2, !dbg !71
  %59 = zext i16 %58 to i32, !dbg !72
  %60 = add i32 %59, 16, !dbg !73
  %61 = shl i32 %55, %60, !dbg !74
  %62 = bitcast i32 %61 to float, !dbg !75
  store float %62, float* %2, align 4, !dbg !29
  %63 = load i16*, i16** %14, align 8, !dbg !76
  %64 = getelementptr i16, i16* %63, i5 14, !dbg !77
  %65 = load i16, i16* %64, align 2, !dbg !77
  %66 = zext i16 %65 to i32, !dbg !78
  %67 = load i16*, i16** %14, align 8, !dbg !79
  %68 = getelementptr i16, i16* %67, i5 13, !dbg !80
  %69 = load i16, i16* %68, align 2, !dbg !80
  %70 = zext i16 %69 to i32, !dbg !81
  %71 = add i32 %70, 16, !dbg !82
  %72 = shl i32 %66, %71, !dbg !83
  %73 = bitcast i32 %72 to float, !dbg !84
  store float %73, float* %1, align 4, !dbg !27
  store i16 0, i16* @stack_last, align 2, !dbg !85
  %74 = load i16, i16* %13, align 2, !dbg !86
  store i16 %74, i16* @memcpyH2D_c, align 2, !dbg !87
  %75 = load i16, i16* %12, align 2, !dbg !88
  store i16 %75, i16* @memcpyH2D_px, align 2, !dbg !89
  %76 = load i16, i16* %11, align 2, !dbg !90
  store i16 %76, i16* @memcpyH2D_py, align 2, !dbg !91
  %77 = load i16, i16* %10, align 2, !dbg !92
  store i16 %77, i16* @memcpyH2D_w, align 2, !dbg !93
  %78 = load i16, i16* %9, align 2, !dbg !94
  store i16 %78, i16* @memcpyH2D_h, align 2, !dbg !95
  %79 = load i16, i16* %8, align 2, !dbg !96
  store i16 %79, i16* @memcpyH2D_addr, align 2, !dbg !97
  %80 = load i16, i16* %7, align 2, !dbg !98
  store i16 %80, i16* @memcpyH2D_pe_length, align 2, !dbg !99
  %81 = load i16, i16* %6, align 2, !dbg !100
  store i16 %81, i16* @memcpyH2D_is_half, align 2, !dbg !101
  %82 = load i16, i16* %5, align 2, !dbg !102
  store i16 %82, i16* @memcpyH2D_memcpy_optype, align 2, !dbg !103
  %83 = load i16, i16* %4, align 2, !dbg !104
  store i16 %83, i16* @memcpyH2D_row_stride, align 2, !dbg !105
  %84 = load i16, i16* %3, align 2, !dbg !106
  store i16 %84, i16* @memcpyH2D_col_stride, align 2, !dbg !107
  %85 = load float, float* %2, align 4, !dbg !108
  store float %85, float* @memcpyH2D_one_over_row_stride, align 4, !dbg !109
  %86 = load float, float* %1, align 4, !dbg !110
  store float %86, float* @memcpyH2D_one_over_col_stride, align 4, !dbg !111
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !112
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !112
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !112
  ret void, !dbg !113
}

define internal void @cmd_decode_d2h() !dbg !114 {
  %1 = load i16, i16* @stack_last, align 2, !dbg !115
  %2 = icmp eq i16 %1, 8, !dbg !117
  br i1 %2, label %3, label %4, !dbg !118

3:                                                ; preds = %0
  br label %5, !dbg !118

4:                                                ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !118
  br label %5, !dbg !118

5:                                                ; preds = %3, %4
  store i16 0, i16* @stack_last, align 2, !dbg !119
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__1 to i8*)), !dbg !120
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !120
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !120
  ret void, !dbg !121
}

define void @f_rxact_cmd(i32 %0) #0 !dbg !122 {
  %2 = alloca i16, i16 1, align 2, !dbg !123
  %3 = alloca i16, i16 1, align 2, !dbg !125
  %4 = alloca i32, i16 1, align 4, !dbg !126
  store i32 %0, i32* %4, align 4, !dbg !126
  call void @llvm.sdr.blk.r(i16 2), !dbg !127
  %5 = load i32, i32* %4, align 4, !dbg !128
  store i32 %5, i32* getelementptr inbounds ([128 x i32], [128 x i32]* @"$$csl_base_address$$4$$cmd", i16 0, i1 false), align 4, !dbg !129
  %6 = load i32, i32* %4, align 4, !dbg !130
  %7 = lshr i32 %6, 16, !dbg !131
  %8 = trunc i32 %7 to i16, !dbg !132
  store i16 %8, i16* %3, align 2, !dbg !125
  %9 = load i16, i16* %3, align 2, !dbg !133
  %10 = icmp eq i16 %9, 34, !dbg !134
  br i1 %10, label %11, label %12, !dbg !135

11:                                               ; preds = %1
  call void @cmd_decode_h2d(), !dbg !136
  br label %27, !dbg !135

12:                                               ; preds = %1
  %13 = load i16, i16* %3, align 2, !dbg !137
  %14 = icmp eq i16 %13, 35, !dbg !138
  br i1 %14, label %15, label %16, !dbg !139

15:                                               ; preds = %12
  call void @cmd_decode_d2h(), !dbg !140
  br label %26, !dbg !139

16:                                               ; preds = %12
  %17 = load i16, i16* %3, align 2, !dbg !141
  %18 = icmp eq i16 %17, 36, !dbg !142
  br i1 %18, label %19, label %20, !dbg !143

19:                                               ; preds = %16
  store i16 0, i16* @stack_last, align 2, !dbg !144
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__1 to i8*)), !dbg !145
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !145
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !145
  br label %25, !dbg !143

20:                                               ; preds = %16
  %21 = load i32, i32* %4, align 4, !dbg !146
  %22 = and i32 %21, 65535, !dbg !147
  %23 = trunc i32 %22 to i16, !dbg !148
  store i16 %23, i16* %2, align 2, !dbg !123
  %24 = load i16, i16* %2, align 2, !dbg !149
  call void @stack_push(i16 %24), !dbg !150
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !151
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__1 to i8*)), !dbg !151
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !151
  br label %25, !dbg !143

25:                                               ; preds = %19, %20
  br label %26, !dbg !139

26:                                               ; preds = %15, %25
  br label %27, !dbg !135

27:                                               ; preds = %11, %26
  ret void, !dbg !135
}

define void @f_txact_next_tensor() #1 !dbg !152 {
  %1 = alloca i16, i16 1, align 2, !dbg !153
  %2 = alloca i16, i16 1, align 2, !dbg !155
  %3 = alloca i16, i16 1, align 2, !dbg !156
  %4 = alloca i16, i16 1, align 2, !dbg !157
  %5 = alloca i16, i16 1, align 2, !dbg !158
  %6 = alloca i16, i16 1, align 2, !dbg !159
  %7 = alloca i16, i16 1, align 2, !dbg !160
  %8 = alloca i16, i16 1, align 2, !dbg !161
  %9 = load i16, i16* @memcpyH2D_py, align 2, !dbg !162
  store i16 %9, i16* %8, align 2, !dbg !161
  %10 = load i16, i16* @memcpyH2D_w, align 2, !dbg !163
  store i16 %10, i16* %7, align 2, !dbg !160
  %11 = load i16, i16* @memcpyH2D_h, align 2, !dbg !164
  store i16 %11, i16* %6, align 2, !dbg !159
  %12 = load i16, i16* @memcpyH2D_pe_length, align 2, !dbg !165
  store i16 %12, i16* %5, align 2, !dbg !158
  %13 = load i16, i16* %7, align 2, !dbg !166
  store i16 %13, i16* @num_send, align 2, !dbg !167
  store i16 0, i16* @idx_send, align 2, !dbg !168
  %14 = load i16, i16* @_pe_id, align 2, !dbg !169
  store i16 %14, i16* %4, align 2, !dbg !157
  %15 = load i16, i16* @memcpyH2D_memcpy_optype, align 2, !dbg !170
  %16 = icmp eq i16 3, %15, !dbg !171
  br i1 %16, label %17, label %45, !dbg !172

17:                                               ; preds = %0
  %18 = load i16, i16* %7, align 2, !dbg !173
  %19 = sub i16 %18, 1, !dbg !174
  %20 = sitofp i16 %19 to float, !dbg !175
  %21 = load float, float* @memcpyH2D_one_over_row_stride, align 4, !dbg !176
  %22 = fmul float %20, %21, !dbg !177
  %23 = fptosi float %22 to i16, !dbg !178
  %24 = add i16 %23, 1, !dbg !179
  store i16 %24, i16* %3, align 2, !dbg !156
  %25 = load i16, i16* %3, align 2, !dbg !180
  store i16 %25, i16* @num_send, align 2, !dbg !181
  %26 = load i16, i16* %4, align 2, !dbg !182
  %27 = load i16, i16* %8, align 2, !dbg !183
  %28 = sub i16 %26, %27, !dbg !184
  %29 = sitofp i16 %28 to float, !dbg !185
  %30 = load float, float* @memcpyH2D_one_over_col_stride, align 4, !dbg !186
  %31 = fmul float %29, %30, !dbg !187
  %32 = fptosi float %31 to i16, !dbg !188
  store i16 %32, i16* %2, align 2, !dbg !155
  %33 = load i16, i16* %4, align 2, !dbg !189
  %34 = load i16, i16* %8, align 2, !dbg !190
  %35 = sub i16 %33, %34, !dbg !191
  %36 = load i16, i16* %2, align 2, !dbg !192
  %37 = load i16, i16* @memcpyH2D_col_stride, align 2, !dbg !193
  %38 = mul i16 %36, %37, !dbg !194
  %39 = sub i16 %35, %38, !dbg !195
  store i16 %39, i16* %1, align 2, !dbg !153
  %40 = load i16, i16* %1, align 2, !dbg !196
  %41 = icmp ne i16 0, %40, !dbg !197
  br i1 %41, label %42, label %44, !dbg !198

42:                                               ; preds = %17, %45
  %43 = phi i16 [ 1, %45 ], [ 0, %17 ]
  store i16 %43, i16* @num_send, align 2, !dbg !199
  br label %44, !dbg !198

44:                                               ; preds = %42, %17, %45
  br label %48, !dbg !172

45:                                               ; preds = %0
  %46 = load i16, i16* @memcpyH2D_memcpy_optype, align 2, !dbg !200
  %47 = icmp eq i16 1, %46, !dbg !201
  br i1 %47, label %42, label %44, !dbg !202

48:                                               ; preds = %44
  %49 = load i16, i16* %4, align 2, !dbg !203
  %50 = load i16, i16* %8, align 2, !dbg !204
  %51 = icmp slt i16 %49, %50, !dbg !205
  br i1 %51, label %52, label %53, !dbg !206

52:                                               ; preds = %48
  store i16 0, i16* @num_send, align 2, !dbg !207
  br label %53, !dbg !206

53:                                               ; preds = %52, %48
  %54 = load i16, i16* %4, align 2, !dbg !208
  %55 = load i16, i16* %8, align 2, !dbg !209
  %56 = load i16, i16* %6, align 2, !dbg !210
  %57 = add i16 %55, %56, !dbg !211
  %58 = icmp sge i16 %54, %57, !dbg !212
  br i1 %58, label %59, label %60, !dbg !213

59:                                               ; preds = %53
  store i16 0, i16* @num_send, align 2, !dbg !214
  br label %60, !dbg !213

60:                                               ; preds = %59, %53
  %61 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_data_wdsd, i32 0, i32 1), align 2, !dbg !215
  %62 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_data_wdsd, i32 0, i32 2), align 2, !dbg !215
  %63 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_data_wdsd, i32 0, i32 3), align 2, !dbg !215
  %64 = load i16, i16* %5, align 2, !dbg !216
  store i16 %64, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_data_wdsd, i32 0, i32 0), align 2, !dbg !217
  store i16 %61, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_data_wdsd, i32 0, i32 1), align 2, !dbg !217
  store i16 %62, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_data_wdsd, i32 0, i32 2), align 2, !dbg !217
  store i16 %63, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_data_wdsd, i32 0, i32 3), align 2, !dbg !217
  call void @llvm.sdr.actvt.r(i16 27), !dbg !218
  ret void, !dbg !172
}

define void @f_txact_next_chunk() #2 !dbg !219 {
  %1 = load i16, i16* @idx_send, align 2, !dbg !220
  %2 = load i16, i16* @num_send, align 2, !dbg !222
  %3 = icmp sge i16 %1, %2, !dbg !223
  br i1 %3, label %4, label %10, !dbg !224

4:                                                ; preds = %0
  %5 = load i16, i16* @num_send, align 2, !dbg !225
  %6 = icmp eq i16 0, %5, !dbg !226
  br i1 %6, label %7, label %8, !dbg !227

7:                                                ; preds = %4
  call void @llvm.sdr.ublk.r(i16 2), !dbg !228
  br label %9, !dbg !227

8:                                                ; preds = %4
  call void @llvm.sdr.actvt.r(i16 28), !dbg !229
  br label %9, !dbg !227

9:                                                ; preds = %7, %8
  br label %21, !dbg !224

10:                                               ; preds = %0
  %11 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_data_wdsd, i32 0, i32 0), align 2, !dbg !230
  %12 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_data_wdsd, i32 0, i32 1), align 2, !dbg !230
  %13 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_data_wdsd, i32 0, i32 2), align 2, !dbg !230
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_data_wdsd, i32 0, i32 3), align 2, !dbg !230
  %15 = and i16 %13, -193, !dbg !230
  %16 = or i16 %15, 128, !dbg !230
  %17 = and i16 %12, -64, !dbg !230
  %18 = or i16 %17, 59, !dbg !230
  store volatile i16 %11, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 0), align 2, !dbg !231
  store volatile i16 %18, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 1), align 2, !dbg !231
  store volatile i16 %16, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 2), align 2, !dbg !231
  store volatile i16 %14, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 3), align 2, !dbg !231
  call void asm sideeffect "nop", ""(), !dbg !231
  call void asm sideeffect "nop", ""(), !dbg !231
  call void @llvm.sdr.imov32.ds1(i16 1, i16 4), !dbg !231
  %19 = load i16, i16* @idx_send, align 2, !dbg !232
  %20 = add i16 %19, 1, !dbg !233
  store i16 %20, i16* @idx_send, align 2, !dbg !234
  br label %21, !dbg !224

21:                                               ; preds = %9, %10
  ret void, !dbg !224
}

define void @f_h2d_td() #3 !dbg !235 {
  call void @llvm.sdr.lds1wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__2 to i8*)), !dbg !236
  call void @llvm.sdr.lddwds(i16 2, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__3 to i8*)), !dbg !236
  call void @llvm.sdr.imov32.ds1(i16 2, i16 1), !dbg !236
  ret void, !dbg !238
}

define void @f_teardown() #4 !dbg !239 {
  %1 = alloca i32, i16 1, align 4, !dbg !240
  %2 = call i32 @tile_config.teardown.get_pending(), !dbg !242
  store i32 %2, i32* %1, align 4, !dbg !240
  %3 = load i32, i32* %1, align 4, !dbg !243
  %4 = call i1 @tile_config.teardown.is_pending(i32 %3, i16 23), !dbg !244
  br i1 %4, label %5, label %6, !dbg !245

5:                                                ; preds = %0
  call void @tile_config.teardown.exit(i16 23), !dbg !246
  br label %6, !dbg !245

6:                                                ; preds = %5, %0
  ret void, !dbg !245
}

define void @f_startup() #5 !dbg !247 {
  %1 = call i16 @get_pe_id(), !dbg !248
  store i16 %1, i16* @_pe_id, align 2, !dbg !250
  %2 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_data_wdsd, i32 0, i32 1), align 2, !dbg !251
  %3 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_data_wdsd, i32 0, i32 2), align 2, !dbg !251
  %4 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_data_wdsd, i32 0, i32 3), align 2, !dbg !251
  store i16 32767, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_data_wdsd, i32 0, i32 0), align 2, !dbg !252
  store i16 %2, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_data_wdsd, i32 0, i32 1), align 2, !dbg !252
  store i16 %3, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_data_wdsd, i32 0, i32 2), align 2, !dbg !252
  store i16 %4, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_data_wdsd, i32 0, i32 3), align 2, !dbg !252
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_data_wdsd, i32 0, i32 0), align 2, !dbg !253
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_data_wdsd, i32 0, i32 1), align 2, !dbg !253
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_data_wdsd, i32 0, i32 2), align 2, !dbg !253
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_data_wdsd, i32 0, i32 3), align 2, !dbg !253
  %9 = and i16 %7, -193, !dbg !253
  %10 = or i16 %9, 128, !dbg !253
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 2, i32 0), align 2, !dbg !254
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 2, i32 1), align 2, !dbg !254
  store volatile i16 %10, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 2, i32 2), align 2, !dbg !254
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 2, i32 3), align 2, !dbg !254
  call void asm sideeffect "nop", ""(), !dbg !254
  call void asm sideeffect "nop", ""(), !dbg !254
  call void @llvm.sdr.imov32.ds1(i16 4, i16 2), !dbg !254
  %11 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_cmdfifo_wdsd, i32 0, i32 1), align 2, !dbg !255
  %12 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_cmdfifo_wdsd, i32 0, i32 2), align 2, !dbg !255
  %13 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_cmdfifo_wdsd, i32 0, i32 3), align 2, !dbg !255
  store i16 32767, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_cmdfifo_wdsd, i32 0, i32 0), align 2, !dbg !256
  store i16 %11, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_cmdfifo_wdsd, i32 0, i32 1), align 2, !dbg !256
  store i16 %12, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_cmdfifo_wdsd, i32 0, i32 2), align 2, !dbg !256
  store i16 %13, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_cmdfifo_wdsd, i32 0, i32 3), align 2, !dbg !256
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_cmdfifo_wdsd, i32 0, i32 0), align 2, !dbg !257
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_cmdfifo_wdsd, i32 0, i32 1), align 2, !dbg !257
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_cmdfifo_wdsd, i32 0, i32 2), align 2, !dbg !257
  %17 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_cmdfifo_wdsd, i32 0, i32 3), align 2, !dbg !257
  %18 = and i16 %16, -193, !dbg !257
  %19 = or i16 %18, 128, !dbg !257
  store volatile i16 %14, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 3, i32 0), align 2, !dbg !258
  store volatile i16 %15, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 3, i32 1), align 2, !dbg !258
  store volatile i16 %19, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 3, i32 2), align 2, !dbg !258
  store volatile i16 %17, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 3, i32 3), align 2, !dbg !258
  call void asm sideeffect "nop", ""(), !dbg !258
  call void asm sideeffect "nop", ""(), !dbg !258
  call void @llvm.sdr.imov32.ds1(i16 5, i16 3), !dbg !258
  %20 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_cmdfifo_wdsd, i32 0, i32 1), align 2, !dbg !259
  %21 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_cmdfifo_wdsd, i32 0, i32 2), align 2, !dbg !259
  %22 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_cmdfifo_wdsd, i32 0, i32 3), align 2, !dbg !259
  store i16 32767, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_cmdfifo_wdsd, i32 0, i32 0), align 2, !dbg !260
  store i16 %20, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_cmdfifo_wdsd, i32 0, i32 1), align 2, !dbg !260
  store i16 %21, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_cmdfifo_wdsd, i32 0, i32 2), align 2, !dbg !260
  store i16 %22, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_cmdfifo_wdsd, i32 0, i32 3), align 2, !dbg !260
  %23 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_cmdfifo_wdsd, i32 0, i32 0), align 2, !dbg !261
  %24 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_cmdfifo_wdsd, i32 0, i32 1), align 2, !dbg !261
  %25 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_cmdfifo_wdsd, i32 0, i32 2), align 2, !dbg !261
  %26 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_cmdfifo_wdsd, i32 0, i32 3), align 2, !dbg !261
  %27 = and i16 %25, -193, !dbg !261
  %28 = or i16 %27, 128, !dbg !261
  store volatile i16 %23, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 3, i32 0), align 2, !dbg !262
  store volatile i16 %24, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 3, i32 1), align 2, !dbg !262
  store volatile i16 %28, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 3, i32 2), align 2, !dbg !262
  store volatile i16 %26, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 3, i32 3), align 2, !dbg !262
  call void asm sideeffect "nop", ""(), !dbg !262
  call void asm sideeffect "nop", ""(), !dbg !262
  call void @llvm.sdr.imov32.ds1(i16 3, i16 5), !dbg !262
  %29 = load i16, i16* @CHECK_AND_IGNORE, align 2, !dbg !263
  %30 = zext i16 %29 to i32, !dbg !264
  %31 = shl i32 %30, 16, !dbg !265
  %32 = load i16, i16* @memcpy_use_addr_color, align 2, !dbg !266
  %33 = zext i16 %32 to i32, !dbg !267
  %34 = add i32 %31, %33, !dbg !268
  store i32 %34, i32* getelementptr inbounds ([6 x i32], [6 x i32]* @"$$csl_base_address$$2$$init_sym", i16 0, i1 false), align 4, !dbg !269
  %35 = load i16, i16* @CHECK_AND_IGNORE, align 2, !dbg !270
  %36 = zext i16 %35 to i32, !dbg !271
  %37 = shl i32 %36, 16, !dbg !272
  %38 = load i16, i16* @sys_cmd_push, align 2, !dbg !273
  %39 = zext i16 %38 to i32, !dbg !274
  %40 = add i32 %37, %39, !dbg !275
  store i32 %40, i32* getelementptr inbounds ([6 x i32], [6 x i32]* @"$$csl_base_address$$2$$init_sym", i16 0, i2 1), align 4, !dbg !276
  %41 = load i16, i16* @CHECK_AND_IGNORE, align 2, !dbg !277
  %42 = zext i16 %41 to i32, !dbg !278
  %43 = shl i32 %42, 16, !dbg !279
  %44 = load i16, i16* @sys_cmd_h2d, align 2, !dbg !280
  %45 = zext i16 %44 to i32, !dbg !281
  %46 = add i32 %43, %45, !dbg !282
  store i32 %46, i32* getelementptr inbounds ([6 x i32], [6 x i32]* @"$$csl_base_address$$2$$init_sym", i16 0, i3 2), align 4, !dbg !283
  %47 = load i16, i16* @CHECK_AND_IGNORE, align 2, !dbg !284
  %48 = zext i16 %47 to i32, !dbg !285
  %49 = shl i32 %48, 16, !dbg !286
  %50 = load i16, i16* @sys_cmd_d2h, align 2, !dbg !287
  %51 = zext i16 %50 to i32, !dbg !288
  %52 = add i32 %49, %51, !dbg !289
  store i32 %52, i32* getelementptr inbounds ([6 x i32], [6 x i32]* @"$$csl_base_address$$2$$init_sym", i16 0, i3 3), align 4, !dbg !290
  %53 = load i16, i16* @CHECK_AND_IGNORE, align 2, !dbg !291
  %54 = zext i16 %53 to i32, !dbg !292
  %55 = shl i32 %54, 16, !dbg !293
  %56 = load i16, i16* @sys_cmd_rpc, align 2, !dbg !294
  %57 = zext i16 %56 to i32, !dbg !295
  %58 = add i32 %55, %57, !dbg !296
  store i32 %58, i32* getelementptr inbounds ([6 x i32], [6 x i32]* @"$$csl_base_address$$2$$init_sym", i16 0, i4 4), align 4, !dbg !297
  %59 = load i16, i16* @CHECK_AND_IGNORE, align 2, !dbg !298
  %60 = zext i16 %59 to i32, !dbg !299
  %61 = shl i32 %60, 16, !dbg !300
  %62 = load i16, i16* @memcpy_version, align 2, !dbg !301
  %63 = zext i16 %62 to i32, !dbg !302
  %64 = add i32 %61, %63, !dbg !303
  store i32 %64, i32* getelementptr inbounds ([6 x i32], [6 x i32]* @"$$csl_base_address$$2$$init_sym", i16 0, i4 5), align 4, !dbg !304
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__4 to i8*)), !dbg !305
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__5 to i8*)), !dbg !305
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !305
  ret void, !dbg !306
}

define internal i32 @tile_config.teardown.get_pending() !dbg !307 {
  %1 = alloca i16, i16 1, align 2, !dbg !309
  %2 = alloca i16, i16 1, align 2, !dbg !311
  call void asm sideeffect "nop", ""(), !dbg !312
  call void asm sideeffect "nop", ""(), !dbg !312
  %3 = load volatile i16, i16* inttoptr (i16 -1916 to i16*), align 2, !dbg !312
  store i16 %3, i16* %2, align 2, !dbg !311
  %4 = load volatile i16, i16* inttoptr (i16 -1914 to i16*), align 2, !dbg !313
  store i16 %4, i16* %1, align 2, !dbg !309
  %5 = load i16, i16* %1, align 2, !dbg !314
  %6 = zext i16 %5 to i32, !dbg !315
  %7 = shl i32 %6, 16, !dbg !316
  %8 = load i16, i16* %2, align 2, !dbg !317
  %9 = zext i16 %8 to i32, !dbg !318
  %10 = or i32 %7, %9, !dbg !319
  ret i32 %10, !dbg !320
}

define internal i1 @tile_config.teardown.is_pending(i32 %0, i16 %1) !dbg !321 {
  %3 = alloca i32, i16 1, align 4, !dbg !322
  %4 = alloca i16, i16 1, align 2, !dbg !324
  %5 = alloca i16, i16 1, align 2, !dbg !325
  %6 = alloca i32, i16 1, align 4, !dbg !326
  store i32 %0, i32* %6, align 4, !dbg !326
  store i16 %1, i16* %5, align 2, !dbg !325
  %7 = load i16, i16* %5, align 2, !dbg !327
  store i16 %7, i16* %4, align 2, !dbg !324
  %8 = load i16, i16* %4, align 2, !dbg !328
  %9 = zext i16 %8 to i32, !dbg !328
  %10 = shl i32 1, %9, !dbg !329
  store i32 %10, i32* %3, align 4, !dbg !322
  %11 = load i32, i32* %6, align 4, !dbg !330
  %12 = load i32, i32* %3, align 4, !dbg !331
  %13 = and i32 %11, %12, !dbg !332
  %14 = icmp ne i32 %13, 0, !dbg !333
  ret i1 %14, !dbg !334
}

define internal void @tile_config.teardown.exit(i16 %0) !dbg !335 {
  %2 = alloca i16, i16 1, align 2, !dbg !336
  %3 = alloca i16, i16 1, align 2, !dbg !338
  %4 = alloca i16, i16 1, align 2, !dbg !339
  %5 = alloca i16, i16 1, align 2, !dbg !340
  store i16 %0, i16* %5, align 2, !dbg !340
  %6 = load i16, i16* %5, align 2, !dbg !341
  store i16 %6, i16* %4, align 2, !dbg !339
  %7 = load i16, i16* %4, align 2, !dbg !342
  %8 = add i16 %7, 31744, !dbg !343
  store i16 %8, i16* %3, align 2, !dbg !338
  %9 = load i16, i16* %3, align 2, !dbg !344
  %10 = shl i16 %9, 1, !dbg !345
  %11 = inttoptr i16 %10 to i16*, !dbg !345
  call void asm sideeffect "nop", ""(), !dbg !345
  call void asm sideeffect "nop", ""(), !dbg !345
  %12 = load volatile i16, i16* %11, align 2, !dbg !345
  store i16 %12, i16* %2, align 2, !dbg !336
  %13 = load i16, i16* %3, align 2, !dbg !346
  %14 = load i16, i16* %2, align 2, !dbg !347
  %15 = and i16 %14, 32767, !dbg !348
  %16 = shl i16 %13, 1, !dbg !349
  %17 = inttoptr i16 %16 to i16*, !dbg !349
  store volatile i16 %15, i16* %17, align 2, !dbg !349
  call void asm sideeffect "nop", ""(), !dbg !349
  call void asm sideeffect "nop", ""(), !dbg !349
  ret void, !dbg !350
}

define internal i16 @fabric.get_y_coord() !dbg !351 {
  %1 = call i16 @fabric.tile_config.get_fabric_coord(i16 0), !dbg !353
  %2 = sub i16 %1, 1, !dbg !355
  ret i16 %2, !dbg !356
}

define internal i16 @fabric.tile_config.get_fabric_coord(i16 %0) !dbg !357 {
  %2 = alloca i16, i16 1, align 2, !dbg !359
  %3 = alloca i16, i16 1, align 2, !dbg !361
  store i16 %0, i16* %3, align 2, !dbg !361
  %4 = load i16, i16* %3, align 2, !dbg !362
  %5 = lshr i16 %4, 1, !dbg !363
  %6 = add i16 %5, 31813, !dbg !364
  %7 = shl i16 %6, 1, !dbg !365
  %8 = inttoptr i16 %7 to i16*, !dbg !365
  call void asm sideeffect "nop", ""(), !dbg !365
  call void asm sideeffect "nop", ""(), !dbg !365
  %9 = load volatile i16, i16* %8, align 2, !dbg !365
  store i16 %9, i16* %2, align 2, !dbg !359
  %10 = load i16, i16* %2, align 2, !dbg !366
  %11 = and i16 %10, 2047, !dbg !367
  ret i16 %11, !dbg !368
}

; Function Attrs: nounwind
declare void @llvm.sdr.actvt.r(i16) #6

; Function Attrs: nounwind
declare void @llvm.sdr.blk.r(i16) #6

; Function Attrs: nounwind
declare void @llvm.sdr.ublk.r(i16) #6

; Function Attrs: nounwind
declare i16 @llvm.sdr.read.lfsr() #6

; Function Attrs: nounwind
declare void @llvm.sdr.stprng.r(i16) #6

; Function Attrs: nounwind
declare void @llvm.sdr.lds0wds(i16 immarg, i8* readonly) #6

; Function Attrs: nounwind
declare void @llvm.sdr.lds1wds(i16 immarg, i8* readonly) #6

; Function Attrs: nounwind
declare void @llvm.sdr.lddwds(i16 immarg, i8* readonly) #6

; Function Attrs: nounwind
declare void @llvm.sdr.ldxds(i16 immarg, i8* readonly) #6

; Function Attrs: nounwind
declare void @llvm.sdr.ldsr(i16 immarg, i8* readonly) #6

; Function Attrs: nounwind writeonly
declare void @llvm.sdr.iqflush(i16) #7

; Function Attrs: nounwind writeonly
declare void @llvm.sdr.oqflush(i16) #7

; Function Attrs: nounwind
declare void @llvm.sdr.imov32.ds1(i16 immarg, i16 immarg) #6

declare i16 @csl.ss.read.16(i16, i1)

declare i32 @csl.ss.read.32(i16, i1)

declare void @csl.ss.write.16(i16, i16, i1)

declare void @csl.ss.write.32(i16, i32, i1)

declare i1 @csl.ss.set_jump_target()

declare i1 @csl.fifo.set_jump_target()

attributes #0 = { "entry-point"="2" "task" }
attributes #1 = { "entry-point"="26" "task" }
attributes #2 = { "entry-point"="27" "task" }
attributes #3 = { "entry-point"="28" "task" }
attributes #4 = { "entry-point"="29" "task" }
attributes #5 = { "entry-point"="24" "task" }
attributes #6 = { nounwind }
attributes #7 = { nounwind writeonly }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!2}

!0 = distinct !DICompileUnit(language: DW_LANG_C, file: !1, producer: "mlir", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug)
!1 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/runtime/layout_west_demux_cmdfan_multi.csl", directory: "/")
!2 = !{i32 2, !"Debug Info Version", i32 3}
!3 = distinct !DISubprogram(name: "get_pe_id", linkageName: "get_pe_id", scope: null, file: !4, line: 217, type: !5, scopeLine: 217, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!4 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/runtime/cmd_fan.csl", directory: "")
!5 = !DISubroutineType(types: !6)
!6 = !{}
!7 = !DILocation(line: 218, column: 12, scope: !8)
!8 = !DILexicalBlockFile(scope: !3, file: !4, discriminator: 0)
!9 = !DILocation(line: 218, column: 5, scope: !8)
!10 = distinct !DISubprogram(name: "stack_push", linkageName: "stack_push", scope: null, file: !4, line: 315, type: !5, scopeLine: 315, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!11 = !DILocation(line: 321, column: 5, scope: !12)
!12 = !DILexicalBlockFile(scope: !10, file: !4, discriminator: 0)
!13 = !DILocation(line: 315, column: 16, scope: !12)
!14 = !DILocation(line: 320, column: 13, scope: !12)
!15 = !DILocation(line: 320, column: 24, scope: !12)
!16 = !DILocation(line: 320, column: 5, scope: !12)
!17 = !DILocation(line: 322, column: 25, scope: !12)
!18 = !DILocation(line: 322, column: 5, scope: !12)
!19 = !DILocation(line: 322, column: 11, scope: !12)
!20 = !DILocation(line: 322, column: 10, scope: !12)
!21 = !DILocation(line: 322, column: 23, scope: !12)
!22 = !DILocation(line: 323, column: 18, scope: !12)
!23 = !DILocation(line: 323, column: 29, scope: !12)
!24 = !DILocation(line: 323, column: 16, scope: !12)
!25 = !DILocation(line: 315, column: 1, scope: !12)
!26 = distinct !DISubprogram(name: "cmd_decode_h2d", linkageName: "cmd_decode_h2d", scope: null, file: !4, line: 342, type: !5, scopeLine: 342, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!27 = !DILocation(line: 378, column: 5, scope: !28)
!28 = !DILexicalBlockFile(scope: !26, file: !4, discriminator: 0)
!29 = !DILocation(line: 377, column: 5, scope: !28)
!30 = !DILocation(line: 376, column: 5, scope: !28)
!31 = !DILocation(line: 375, column: 5, scope: !28)
!32 = !DILocation(line: 374, column: 5, scope: !28)
!33 = !DILocation(line: 373, column: 5, scope: !28)
!34 = !DILocation(line: 372, column: 5, scope: !28)
!35 = !DILocation(line: 371, column: 5, scope: !28)
!36 = !DILocation(line: 370, column: 5, scope: !28)
!37 = !DILocation(line: 369, column: 5, scope: !28)
!38 = !DILocation(line: 368, column: 5, scope: !28)
!39 = !DILocation(line: 367, column: 5, scope: !28)
!40 = !DILocation(line: 366, column: 5, scope: !28)
!41 = !DILocation(line: 364, column: 5, scope: !28)
!42 = !DILocation(line: 363, column: 13, scope: !28)
!43 = !DILocation(line: 363, column: 24, scope: !28)
!44 = !DILocation(line: 363, column: 5, scope: !28)
!45 = !DILocation(line: 366, column: 33, scope: !28)
!46 = !DILocation(line: 366, column: 38, scope: !28)
!47 = !DILocation(line: 367, column: 34, scope: !28)
!48 = !DILocation(line: 367, column: 39, scope: !28)
!49 = !DILocation(line: 368, column: 34, scope: !28)
!50 = !DILocation(line: 368, column: 39, scope: !28)
!51 = !DILocation(line: 369, column: 33, scope: !28)
!52 = !DILocation(line: 369, column: 38, scope: !28)
!53 = !DILocation(line: 370, column: 33, scope: !28)
!54 = !DILocation(line: 370, column: 38, scope: !28)
!55 = !DILocation(line: 371, column: 35, scope: !28)
!56 = !DILocation(line: 371, column: 40, scope: !28)
!57 = !DILocation(line: 372, column: 41, scope: !28)
!58 = !DILocation(line: 372, column: 46, scope: !28)
!59 = !DILocation(line: 373, column: 39, scope: !28)
!60 = !DILocation(line: 373, column: 44, scope: !28)
!61 = !DILocation(line: 374, column: 44, scope: !28)
!62 = !DILocation(line: 374, column: 49, scope: !28)
!63 = !DILocation(line: 375, column: 41, scope: !28)
!64 = !DILocation(line: 375, column: 46, scope: !28)
!65 = !DILocation(line: 376, column: 41, scope: !28)
!66 = !DILocation(line: 376, column: 46, scope: !28)
!67 = !DILocation(line: 377, column: 59, scope: !28)
!68 = !DILocation(line: 377, column: 64, scope: !28)
!69 = !DILocation(line: 377, column: 50, scope: !28)
!70 = !DILocation(line: 377, column: 87, scope: !28)
!71 = !DILocation(line: 377, column: 92, scope: !28)
!72 = !DILocation(line: 377, column: 78, scope: !28)
!73 = !DILocation(line: 377, column: 76, scope: !28)
!74 = !DILocation(line: 377, column: 70, scope: !28)
!75 = !DILocation(line: 377, column: 36, scope: !28)
!76 = !DILocation(line: 378, column: 59, scope: !28)
!77 = !DILocation(line: 378, column: 64, scope: !28)
!78 = !DILocation(line: 378, column: 50, scope: !28)
!79 = !DILocation(line: 378, column: 87, scope: !28)
!80 = !DILocation(line: 378, column: 92, scope: !28)
!81 = !DILocation(line: 378, column: 78, scope: !28)
!82 = !DILocation(line: 378, column: 76, scope: !28)
!83 = !DILocation(line: 378, column: 70, scope: !28)
!84 = !DILocation(line: 378, column: 36, scope: !28)
!85 = !DILocation(line: 380, column: 16, scope: !28)
!86 = !DILocation(line: 382, column: 21, scope: !28)
!87 = !DILocation(line: 382, column: 19, scope: !28)
!88 = !DILocation(line: 383, column: 21, scope: !28)
!89 = !DILocation(line: 383, column: 19, scope: !28)
!90 = !DILocation(line: 384, column: 21, scope: !28)
!91 = !DILocation(line: 384, column: 19, scope: !28)
!92 = !DILocation(line: 385, column: 20, scope: !28)
!93 = !DILocation(line: 385, column: 18, scope: !28)
!94 = !DILocation(line: 386, column: 20, scope: !28)
!95 = !DILocation(line: 386, column: 18, scope: !28)
!96 = !DILocation(line: 387, column: 22, scope: !28)
!97 = !DILocation(line: 387, column: 20, scope: !28)
!98 = !DILocation(line: 388, column: 27, scope: !28)
!99 = !DILocation(line: 388, column: 25, scope: !28)
!100 = !DILocation(line: 389, column: 25, scope: !28)
!101 = !DILocation(line: 389, column: 23, scope: !28)
!102 = !DILocation(line: 390, column: 31, scope: !28)
!103 = !DILocation(line: 390, column: 29, scope: !28)
!104 = !DILocation(line: 391, column: 28, scope: !28)
!105 = !DILocation(line: 391, column: 26, scope: !28)
!106 = !DILocation(line: 392, column: 28, scope: !28)
!107 = !DILocation(line: 392, column: 26, scope: !28)
!108 = !DILocation(line: 393, column: 37, scope: !28)
!109 = !DILocation(line: 393, column: 35, scope: !28)
!110 = !DILocation(line: 394, column: 37, scope: !28)
!111 = !DILocation(line: 394, column: 35, scope: !28)
!112 = !DILocation(line: 402, column: 5, scope: !28)
!113 = !DILocation(line: 342, column: 1, scope: !28)
!114 = distinct !DISubprogram(name: "cmd_decode_d2h", linkageName: "cmd_decode_d2h", scope: null, file: !4, line: 409, type: !5, scopeLine: 409, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!115 = !DILocation(line: 415, column: 13, scope: !116)
!116 = !DILexicalBlockFile(scope: !114, file: !4, discriminator: 0)
!117 = !DILocation(line: 415, column: 24, scope: !116)
!118 = !DILocation(line: 415, column: 5, scope: !116)
!119 = !DILocation(line: 416, column: 16, scope: !116)
!120 = !DILocation(line: 418, column: 5, scope: !116)
!121 = !DILocation(line: 409, column: 1, scope: !116)
!122 = distinct !DISubprogram(name: "f_rxact_cmd", linkageName: "f_rxact_cmd", scope: null, file: !4, line: 426, type: !5, scopeLine: 426, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!123 = !DILocation(line: 454, column: 9, scope: !124)
!124 = !DILexicalBlockFile(scope: !122, file: !4, discriminator: 0)
!125 = !DILocation(line: 439, column: 5, scope: !124)
!126 = !DILocation(line: 426, column: 19, scope: !124)
!127 = !DILocation(line: 428, column: 5, scope: !124)
!128 = !DILocation(line: 431, column: 14, scope: !124)
!129 = !DILocation(line: 431, column: 12, scope: !124)
!130 = !DILocation(line: 439, column: 33, scope: !124)
!131 = !DILocation(line: 439, column: 38, scope: !124)
!132 = !DILocation(line: 439, column: 23, scope: !124)
!133 = !DILocation(line: 440, column: 9, scope: !124)
!134 = !DILocation(line: 440, column: 15, scope: !124)
!135 = !DILocation(line: 440, column: 5, scope: !124)
!136 = !DILocation(line: 441, column: 9, scope: !124)
!137 = !DILocation(line: 443, column: 15, scope: !124)
!138 = !DILocation(line: 443, column: 21, scope: !124)
!139 = !DILocation(line: 443, column: 11, scope: !124)
!140 = !DILocation(line: 444, column: 9, scope: !124)
!141 = !DILocation(line: 446, column: 15, scope: !124)
!142 = !DILocation(line: 446, column: 21, scope: !124)
!143 = !DILocation(line: 446, column: 11, scope: !124)
!144 = !DILocation(line: 447, column: 20, scope: !124)
!145 = !DILocation(line: 449, column: 9, scope: !124)
!146 = !DILocation(line: 454, column: 41, scope: !124)
!147 = !DILocation(line: 454, column: 46, scope: !124)
!148 = !DILocation(line: 454, column: 31, scope: !124)
!149 = !DILocation(line: 455, column: 20, scope: !124)
!150 = !DILocation(line: 455, column: 9, scope: !124)
!151 = !DILocation(line: 457, column: 9, scope: !124)
!152 = distinct !DISubprogram(name: "f_txact_next_tensor", linkageName: "f_txact_next_tensor", scope: null, file: !4, line: 471, type: !5, scopeLine: 471, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!153 = !DILocation(line: 519, column: 9, scope: !154)
!154 = !DILexicalBlockFile(scope: !152, file: !4, discriminator: 0)
!155 = !DILocation(line: 518, column: 9, scope: !154)
!156 = !DILocation(line: 516, column: 9, scope: !154)
!157 = !DILocation(line: 510, column: 5, scope: !154)
!158 = !DILocation(line: 487, column: 5, scope: !154)
!159 = !DILocation(line: 485, column: 5, scope: !154)
!160 = !DILocation(line: 484, column: 5, scope: !154)
!161 = !DILocation(line: 483, column: 5, scope: !154)
!162 = !DILocation(line: 483, column: 19, scope: !154)
!163 = !DILocation(line: 484, column: 19, scope: !154)
!164 = !DILocation(line: 485, column: 19, scope: !154)
!165 = !DILocation(line: 487, column: 26, scope: !154)
!166 = !DILocation(line: 507, column: 16, scope: !154)
!167 = !DILocation(line: 507, column: 14, scope: !154)
!168 = !DILocation(line: 508, column: 14, scope: !154)
!169 = !DILocation(line: 510, column: 20, scope: !154)
!170 = !DILocation(line: 512, column: 52, scope: !154)
!171 = !DILocation(line: 512, column: 49, scope: !154)
!172 = !DILocation(line: 512, column: 5, scope: !154)
!173 = !DILocation(line: 516, column: 46, scope: !154)
!174 = !DILocation(line: 516, column: 47, scope: !154)
!175 = !DILocation(line: 516, column: 38, scope: !154)
!176 = !DILocation(line: 516, column: 51, scope: !154)
!177 = !DILocation(line: 516, column: 50, scope: !154)
!178 = !DILocation(line: 516, column: 29, scope: !154)
!179 = !DILocation(line: 516, column: 27, scope: !154)
!180 = !DILocation(line: 517, column: 20, scope: !154)
!181 = !DILocation(line: 517, column: 18, scope: !154)
!182 = !DILocation(line: 518, column: 42, scope: !154)
!183 = !DILocation(line: 518, column: 48, scope: !154)
!184 = !DILocation(line: 518, column: 46, scope: !154)
!185 = !DILocation(line: 518, column: 33, scope: !154)
!186 = !DILocation(line: 518, column: 52, scope: !154)
!187 = !DILocation(line: 518, column: 51, scope: !154)
!188 = !DILocation(line: 518, column: 24, scope: !154)
!189 = !DILocation(line: 519, column: 25, scope: !154)
!190 = !DILocation(line: 519, column: 31, scope: !154)
!191 = !DILocation(line: 519, column: 29, scope: !154)
!192 = !DILocation(line: 519, column: 37, scope: !154)
!193 = !DILocation(line: 519, column: 41, scope: !154)
!194 = !DILocation(line: 519, column: 39, scope: !154)
!195 = !DILocation(line: 519, column: 35, scope: !154)
!196 = !DILocation(line: 520, column: 18, scope: !154)
!197 = !DILocation(line: 520, column: 15, scope: !154)
!198 = !DILocation(line: 520, column: 9, scope: !154)
!199 = !DILocation(line: 521, column: 22, scope: !154)
!200 = !DILocation(line: 523, column: 61, scope: !154)
!201 = !DILocation(line: 523, column: 58, scope: !154)
!202 = !DILocation(line: 523, column: 11, scope: !154)
!203 = !DILocation(line: 530, column: 10, scope: !154)
!204 = !DILocation(line: 530, column: 16, scope: !154)
!205 = !DILocation(line: 530, column: 14, scope: !154)
!206 = !DILocation(line: 530, column: 5, scope: !154)
!207 = !DILocation(line: 531, column: 18, scope: !154)
!208 = !DILocation(line: 533, column: 10, scope: !154)
!209 = !DILocation(line: 533, column: 18, scope: !154)
!210 = !DILocation(line: 533, column: 21, scope: !154)
!211 = !DILocation(line: 533, column: 20, scope: !154)
!212 = !DILocation(line: 533, column: 14, scope: !154)
!213 = !DILocation(line: 533, column: 5, scope: !154)
!214 = !DILocation(line: 534, column: 18, scope: !154)
!215 = !DILocation(line: 546, column: 43, scope: !154)
!216 = !DILocation(line: 546, column: 72, scope: !154)
!217 = !DILocation(line: 546, column: 25, scope: !154)
!218 = !DILocation(line: 548, column: 5, scope: !154)
!219 = distinct !DISubprogram(name: "f_txact_next_chunk", linkageName: "f_txact_next_chunk", scope: null, file: !4, line: 556, type: !5, scopeLine: 556, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!220 = !DILocation(line: 557, column: 10, scope: !221)
!221 = !DILexicalBlockFile(scope: !219, file: !4, discriminator: 0)
!222 = !DILocation(line: 557, column: 22, scope: !221)
!223 = !DILocation(line: 557, column: 19, scope: !221)
!224 = !DILocation(line: 557, column: 5, scope: !221)
!225 = !DILocation(line: 558, column: 18, scope: !221)
!226 = !DILocation(line: 558, column: 15, scope: !221)
!227 = !DILocation(line: 558, column: 9, scope: !221)
!228 = !DILocation(line: 560, column: 13, scope: !221)
!229 = !DILocation(line: 565, column: 13, scope: !221)
!230 = !DILocation(line: 570, column: 20, scope: !221)
!231 = !DILocation(line: 570, column: 13, scope: !221)
!232 = !DILocation(line: 574, column: 20, scope: !221)
!233 = !DILocation(line: 574, column: 28, scope: !221)
!234 = !DILocation(line: 574, column: 18, scope: !221)
!235 = distinct !DISubprogram(name: "f_h2d_td", linkageName: "f_h2d_td", scope: null, file: !4, line: 582, type: !5, scopeLine: 582, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!236 = !DILocation(line: 583, column: 5, scope: !237)
!237 = !DILexicalBlockFile(scope: !235, file: !4, discriminator: 0)
!238 = !DILocation(line: 582, column: 1, scope: !237)
!239 = distinct !DISubprogram(name: "f_teardown", linkageName: "f_teardown", scope: null, file: !4, line: 608, type: !5, scopeLine: 608, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!240 = !DILocation(line: 611, column: 5, scope: !241)
!241 = !DILexicalBlockFile(scope: !239, file: !4, discriminator: 0)
!242 = !DILocation(line: 611, column: 21, scope: !241)
!243 = !DILocation(line: 616, column: 41, scope: !241)
!244 = !DILocation(line: 616, column: 9, scope: !241)
!245 = !DILocation(line: 616, column: 5, scope: !241)
!246 = !DILocation(line: 617, column: 9, scope: !241)
!247 = distinct !DISubprogram(name: "f_startup", linkageName: "f_startup", scope: null, file: !4, line: 645, type: !5, scopeLine: 645, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!248 = !DILocation(line: 649, column: 23, scope: !249)
!249 = !DILexicalBlockFile(scope: !247, file: !4, discriminator: 0)
!250 = !DILocation(line: 649, column: 12, scope: !249)
!251 = !DILocation(line: 654, column: 46, scope: !249)
!252 = !DILocation(line: 654, column: 28, scope: !249)
!253 = !DILocation(line: 659, column: 22, scope: !249)
!254 = !DILocation(line: 659, column: 9, scope: !249)
!255 = !DILocation(line: 662, column: 49, scope: !249)
!256 = !DILocation(line: 662, column: 31, scope: !249)
!257 = !DILocation(line: 663, column: 26, scope: !249)
!258 = !DILocation(line: 663, column: 9, scope: !249)
!259 = !DILocation(line: 667, column: 50, scope: !249)
!260 = !DILocation(line: 667, column: 32, scope: !249)
!261 = !DILocation(line: 668, column: 16, scope: !249)
!262 = !DILocation(line: 668, column: 9, scope: !249)
!263 = !DILocation(line: 671, column: 29, scope: !249)
!264 = !DILocation(line: 671, column: 20, scope: !249)
!265 = !DILocation(line: 671, column: 47, scope: !249)
!266 = !DILocation(line: 671, column: 65, scope: !249)
!267 = !DILocation(line: 671, column: 56, scope: !249)
!268 = !DILocation(line: 671, column: 54, scope: !249)
!269 = !DILocation(line: 671, column: 17, scope: !249)
!270 = !DILocation(line: 672, column: 29, scope: !249)
!271 = !DILocation(line: 672, column: 20, scope: !249)
!272 = !DILocation(line: 672, column: 47, scope: !249)
!273 = !DILocation(line: 672, column: 65, scope: !249)
!274 = !DILocation(line: 672, column: 56, scope: !249)
!275 = !DILocation(line: 672, column: 54, scope: !249)
!276 = !DILocation(line: 672, column: 17, scope: !249)
!277 = !DILocation(line: 673, column: 29, scope: !249)
!278 = !DILocation(line: 673, column: 20, scope: !249)
!279 = !DILocation(line: 673, column: 47, scope: !249)
!280 = !DILocation(line: 673, column: 65, scope: !249)
!281 = !DILocation(line: 673, column: 56, scope: !249)
!282 = !DILocation(line: 673, column: 54, scope: !249)
!283 = !DILocation(line: 673, column: 17, scope: !249)
!284 = !DILocation(line: 674, column: 29, scope: !249)
!285 = !DILocation(line: 674, column: 20, scope: !249)
!286 = !DILocation(line: 674, column: 47, scope: !249)
!287 = !DILocation(line: 674, column: 65, scope: !249)
!288 = !DILocation(line: 674, column: 56, scope: !249)
!289 = !DILocation(line: 674, column: 54, scope: !249)
!290 = !DILocation(line: 674, column: 17, scope: !249)
!291 = !DILocation(line: 675, column: 29, scope: !249)
!292 = !DILocation(line: 675, column: 20, scope: !249)
!293 = !DILocation(line: 675, column: 47, scope: !249)
!294 = !DILocation(line: 675, column: 65, scope: !249)
!295 = !DILocation(line: 675, column: 56, scope: !249)
!296 = !DILocation(line: 675, column: 54, scope: !249)
!297 = !DILocation(line: 675, column: 17, scope: !249)
!298 = !DILocation(line: 676, column: 29, scope: !249)
!299 = !DILocation(line: 676, column: 20, scope: !249)
!300 = !DILocation(line: 676, column: 47, scope: !249)
!301 = !DILocation(line: 676, column: 65, scope: !249)
!302 = !DILocation(line: 676, column: 56, scope: !249)
!303 = !DILocation(line: 676, column: 54, scope: !249)
!304 = !DILocation(line: 676, column: 17, scope: !249)
!305 = !DILocation(line: 679, column: 5, scope: !249)
!306 = !DILocation(line: 645, column: 1, scope: !249)
!307 = distinct !DISubprogram(name: "tile_config.teardown.get_pending", linkageName: "tile_config.teardown.get_pending", scope: null, file: !308, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!308 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/teardown.csl", directory: "")
!309 = !DILocation(line: 23, column: 3, scope: !310)
!310 = !DILexicalBlockFile(scope: !307, file: !308, discriminator: 0)
!311 = !DILocation(line: 21, column: 3, scope: !310)
!312 = !DILocation(line: 22, column: 7, scope: !310)
!313 = !DILocation(line: 24, column: 7, scope: !310)
!314 = !DILocation(line: 25, column: 32, scope: !310)
!315 = !DILocation(line: 25, column: 11, scope: !310)
!316 = !DILocation(line: 25, column: 41, scope: !310)
!317 = !DILocation(line: 26, column: 32, scope: !310)
!318 = !DILocation(line: 26, column: 11, scope: !310)
!319 = !DILocation(line: 25, column: 61, scope: !310)
!320 = !DILocation(line: 25, column: 3, scope: !310)
!321 = distinct !DISubprogram(name: "tile_config.teardown.is_pending", linkageName: "tile_config.teardown.is_pending", scope: null, file: !308, line: 32, type: !5, scopeLine: 32, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!322 = !DILocation(line: 34, column: 3, scope: !323)
!323 = !DILexicalBlockFile(scope: !321, file: !308, discriminator: 0)
!324 = !DILocation(line: 33, column: 3, scope: !323)
!325 = !DILocation(line: 32, column: 39, scope: !323)
!326 = !DILocation(line: 32, column: 15, scope: !323)
!327 = !DILocation(line: 33, column: 29, scope: !323)
!328 = !DILocation(line: 34, column: 48, scope: !323)
!329 = !DILocation(line: 34, column: 45, scope: !323)
!330 = !DILocation(line: 35, column: 11, scope: !323)
!331 = !DILocation(line: 35, column: 19, scope: !323)
!332 = !DILocation(line: 35, column: 17, scope: !323)
!333 = !DILocation(line: 35, column: 30, scope: !323)
!334 = !DILocation(line: 35, column: 3, scope: !323)
!335 = distinct !DISubprogram(name: "tile_config.teardown.exit", linkageName: "tile_config.teardown.exit", scope: null, file: !308, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!336 = !DILocation(line: 43, column: 3, scope: !337)
!337 = !DILexicalBlockFile(scope: !335, file: !308, discriminator: 0)
!338 = !DILocation(line: 41, column: 3, scope: !337)
!339 = !DILocation(line: 40, column: 3, scope: !337)
!340 = !DILocation(line: 39, column: 9, scope: !337)
!341 = !DILocation(line: 40, column: 23, scope: !337)
!342 = !DILocation(line: 41, column: 70, scope: !337)
!343 = !DILocation(line: 41, column: 68, scope: !337)
!344 = !DILocation(line: 43, column: 27, scope: !337)
!345 = !DILocation(line: 43, column: 15, scope: !337)
!346 = !DILocation(line: 44, column: 15, scope: !337)
!347 = !DILocation(line: 44, column: 21, scope: !337)
!348 = !DILocation(line: 44, column: 27, scope: !337)
!349 = !DILocation(line: 44, column: 3, scope: !337)
!350 = !DILocation(line: 39, column: 1, scope: !337)
!351 = distinct !DISubprogram(name: "fabric.get_y_coord", linkageName: "fabric.get_y_coord", scope: null, file: !352, line: 8, type: !5, scopeLine: 8, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!352 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/layout.csl", directory: "")
!353 = !DILocation(line: 9, column: 10, scope: !354)
!354 = !DILexicalBlockFile(scope: !351, file: !352, discriminator: 0)
!355 = !DILocation(line: 9, column: 67, scope: !354)
!356 = !DILocation(line: 9, column: 3, scope: !354)
!357 = distinct !DISubprogram(name: "fabric.tile_config.get_fabric_coord", linkageName: "fabric.tile_config.get_fabric_coord", scope: null, file: !358, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!358 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config.csl", directory: "")
!359 = !DILocation(line: 50, column: 3, scope: !360)
!360 = !DILexicalBlockFile(scope: !357, file: !358, discriminator: 0)
!361 = !DILocation(line: 43, column: 21, scope: !360)
!362 = !DILocation(line: 50, column: 57, scope: !360)
!363 = !DILocation(line: 50, column: 68, scope: !360)
!364 = !DILocation(line: 50, column: 41, scope: !360)
!365 = !DILocation(line: 50, column: 19, scope: !360)
!366 = !DILocation(line: 52, column: 10, scope: !360)
!367 = !DILocation(line: 52, column: 18, scope: !360)
!368 = !DILocation(line: 48, column: 22, scope: !360)
module asm ".section \22.pe_debug_info\22, \22\22"
module asm ".section \22.note\22, \22\22"
