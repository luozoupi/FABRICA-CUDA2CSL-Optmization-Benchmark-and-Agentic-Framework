; ModuleID = './layout.csl'
source_filename = "./layout.csl"
target datalayout = "e-ni:0-p:16:16-i1:16-i16:16-i32:32-i64:64-f32:32-f64:64"
target triple = "cs_sdr-cerebras-csos"

@row_ptr = internal global [18 x i16] zeroinitializer, align 4
@col_idx = internal global [64 x i16] zeroinitializer, align 4
@col_start = internal global [16 x i16] zeroinitializer, align 4
@run_len = internal global [16 x i16] zeroinitializer, align 4
@"$$csl_base_address$$0$$val" = dso_local global [64 x float] zeroinitializer, align 4
@"$$csl_base_address$$1$$x" = dso_local global [16 x float] zeroinitializer, align 4
@"$$csl_base_address$$4$$dia_val" = dso_local global [64 x float] zeroinitializer, align 4
@dia_off = internal global [4 x i16] zeroinitializer, align 4
@dia_len = internal global [4 x i16] zeroinitializer, align 4
@dia_row0 = internal global [4 x i16] zeroinitializer, align 4
@dia_xoff = internal global [4 x i16] zeroinitializer, align 4
@"$$csl_base_address$$2$$tmp" = dso_local global [16 x float] zeroinitializer, align 4
@probe_seed = internal global [2 x float] zeroinitializer, align 4
@probe_out = internal global [2 x float] zeroinitializer, align 4
@acc32 = internal global float 0.000000e+00, align 4
@y_sc = internal global [16 x float] zeroinitializer, align 4
@y_ir = internal global [16 x float] zeroinitializer, align 4
@y_bk = internal global [16 x float] zeroinitializer, align 4
@"$$csl_base_address$$3$$y_di" = dso_local global [16 x float] zeroinitializer, align 4
@y_bd = internal global [16 x float] zeroinitializer, align 4
@mark = internal global [16 x i16] zeroinitializer, align 4
@p_row_ptr = internal global i16* getelementptr inbounds ([18 x i16], [18 x i16]* @row_ptr, i32 0, i32 0), align 4
@p_col_idx = internal global i16* getelementptr inbounds ([64 x i16], [64 x i16]* @col_idx, i32 0, i32 0), align 4
@p_col_start = internal global i16* getelementptr inbounds ([16 x i16], [16 x i16]* @col_start, i32 0, i32 0), align 4
@p_run_len = internal global i16* getelementptr inbounds ([16 x i16], [16 x i16]* @run_len, i32 0, i32 0), align 4
@p_val = internal global float* getelementptr inbounds ([64 x float], [64 x float]* @"$$csl_base_address$$0$$val", i32 0, i32 0), align 4
@p_x = internal global float* getelementptr inbounds ([16 x float], [16 x float]* @"$$csl_base_address$$1$$x", i32 0, i32 0), align 4
@p_dia_val = internal global float* getelementptr inbounds ([64 x float], [64 x float]* @"$$csl_base_address$$4$$dia_val", i32 0, i32 0), align 4
@p_dia_off = internal global i16* getelementptr inbounds ([4 x i16], [4 x i16]* @dia_off, i32 0, i32 0), align 4
@p_dia_len = internal global i16* getelementptr inbounds ([4 x i16], [4 x i16]* @dia_len, i32 0, i32 0), align 4
@p_dia_row0 = internal global i16* getelementptr inbounds ([4 x i16], [4 x i16]* @dia_row0, i32 0, i32 0), align 4
@p_dia_xoff = internal global i16* getelementptr inbounds ([4 x i16], [4 x i16]* @dia_xoff, i32 0, i32 0), align 4
@p_probe_seed = internal global float* getelementptr inbounds ([2 x float], [2 x float]* @probe_seed, i32 0, i32 0), align 4
@p_probe_out = internal global float* getelementptr inbounds ([2 x float], [2 x float]* @probe_out, i32 0, i32 0), align 4
@p_y_sc = internal global float* getelementptr inbounds ([16 x float], [16 x float]* @y_sc, i32 0, i32 0), align 4
@p_y_ir = internal global float* getelementptr inbounds ([16 x float], [16 x float]* @y_ir, i32 0, i32 0), align 4
@p_y_bk = internal global float* getelementptr inbounds ([16 x float], [16 x float]* @y_bk, i32 0, i32 0), align 4
@p_y_di = internal global float* getelementptr inbounds ([16 x float], [16 x float]* @"$$csl_base_address$$3$$y_di", i32 0, i32 0), align 4
@p_y_bd = internal global float* getelementptr inbounds ([16 x float], [16 x float]* @y_bd, i32 0, i32 0), align 4
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
@"$$csl_base_address$$7$$sys_mod.sys_mod.memcpyh2d_mod_1.dummy" = dso_local constant [1 x i16] zeroinitializer, align 4
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
@"$$csl_base_address$$6$$sys_mod.sys_mod.memcpyd2h_mod.dummy" = dso_local constant [1 x i16] zeroinitializer, align 4
@sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd = internal global <{ i16, i16, i16, i16 }> <{ i16 1, i16 lshr (i16 ptrtoint ([1 x i16]* @"$$csl_base_address$$6$$sys_mod.sys_mod.memcpyd2h_mod.dummy" to i16), i16 1), i16 143, i16 16 }>, align 4
@"$$csl_base_address$$5$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11" = dso_local global [1 x i32] [i32 190812745], align 4
@sys_mod.sys_mod.memcpyd2h_mod.ctrl_1 = internal global [1 x i32] [i32 157258313], align 4
@sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd = internal global <{ i16, i16, i16, i16 }> <{ i16 1, i16 lshr (i16 ptrtoint ([1 x i32]* @"$$csl_base_address$$5$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11" to i16), i16 1), i16 143, i16 16 }>, align 4
@"$$csl_base_address$$9$$sys_mod.sys_mod.memcpyd2h_mod.sw_td" = dso_local global [2 x i32] zeroinitializer, align 4
@"$$csl_base_address$$8$$sys_mod.sys_mod.memcpyd2h_mod.teardown_buf" = dso_local constant [1 x i32] [i32 165646921], align 4
@__dsr_lowmeminit_ = internal constant <{ i16, i16, i16, i16 }> <{ i16 16, i16 lshr (i16 ptrtoint ([16 x float]* @"$$csl_base_address$$3$$y_di" to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__0 = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 62, i16 142, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__1 = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 4127, i16 142, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__2 = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 lshr (i16 ptrtoint ([1 x i32]* @"$$csl_base_address$$8$$sys_mod.sys_mod.memcpyd2h_mod.teardown_buf" to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__3 = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 4149, i16 142, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__4 = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 4096, i16 142, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__5 = internal constant <{ i16, i16, i16, i16 }> <{ i16 2, i16 4127, i16 142, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__6 = internal constant <{ i16, i16, i16, i16 }> <{ i16 2, i16 lshr (i16 ptrtoint ([2 x i32]* @"$$csl_base_address$$9$$sys_mod.sys_mod.memcpyd2h_mod.sw_td" to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4

declare i8* @malloc(i64)

declare void @free(i8*)

define internal void @spmv_scalar() !dbg !3 {
  %1 = alloca i16, i16 1, align 2, !dbg !7
  %2 = alloca i16, i16 1, align 2, !dbg !9
  %3 = alloca float, i16 1, align 4, !dbg !10
  %4 = alloca i16, i16 1, align 2, !dbg !11
  %5 = alloca i16, i16 1, align 2, !dbg !12
  %6 = alloca i16, i16 1, align 2, !dbg !13
  store i16 28672, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i1 false), align 2, !dbg !14
  store i16 0, i16* %6, align 2, !dbg !13
  br label %7, !dbg !15

7:                                                ; preds = %85, %0
  %8 = phi i16 [ %84, %85 ], [ 0, %0 ]
  %9 = icmp sgt i16 %8, 0, !dbg !15
  br i1 %9, label %10, label %12, !dbg !15

10:                                               ; preds = %7
  %11 = sub i16 %8, 1, !dbg !15
  br label %13, !dbg !15

12:                                               ; preds = %7
  br label %13, !dbg !15

13:                                               ; preds = %10, %12
  %14 = phi i16 [ %8, %12 ], [ %11, %10 ]
  br label %15, !dbg !15

15:                                               ; preds = %13
  %16 = icmp ne i16 %8, 0, !dbg !15
  br i1 %16, label %17, label %18, !dbg !15

17:                                               ; preds = %15
  br label %21, !dbg !15

18:                                               ; preds = %15
  %19 = load i16, i16* %6, align 2, !dbg !16
  %20 = icmp ult i16 %19, 16, !dbg !17
  br label %21, !dbg !15

21:                                               ; preds = %17, %18
  %22 = phi i1 [ %20, %18 ], [ false, %17 ]
  br label %23, !dbg !15

23:                                               ; preds = %21
  br i1 %22, label %24, label %86, !dbg !15

24:                                               ; preds = %23
  %25 = load i16, i16* %6, align 2, !dbg !18
  %26 = getelementptr [18 x i16], [18 x i16]* @row_ptr, i16 0, i16 %25, !dbg !19
  %27 = load i16, i16* %26, align 2, !dbg !19
  store i16 %27, i16* %5, align 2, !dbg !12
  %28 = load i16, i16* %6, align 2, !dbg !20
  %29 = add i16 %28, 1, !dbg !21
  %30 = getelementptr [18 x i16], [18 x i16]* @row_ptr, i16 0, i16 %29, !dbg !22
  %31 = load i16, i16* %30, align 2, !dbg !22
  store i16 %31, i16* %4, align 2, !dbg !11
  store float 0.000000e+00, float* %3, align 4, !dbg !10
  %32 = load i16, i16* %5, align 2, !dbg !23
  store i16 %32, i16* %2, align 2, !dbg !9
  br label %33, !dbg !24

33:                                               ; preds = %51, %24
  %34 = phi i16 [ 0, %51 ], [ 0, %24 ]
  %35 = icmp sgt i16 %34, 0, !dbg !24
  br i1 %35, label %36, label %38, !dbg !24

36:                                               ; preds = %33
  %37 = sub i16 %34, 1, !dbg !24
  br label %39, !dbg !24

38:                                               ; preds = %33
  br label %39, !dbg !24

39:                                               ; preds = %36, %38
  %40 = phi i16 [ %34, %38 ], [ %37, %36 ]
  br label %41, !dbg !24

41:                                               ; preds = %39
  %42 = icmp ne i16 %34, 0, !dbg !24
  br i1 %42, label %43, label %44, !dbg !24

43:                                               ; preds = %41
  br label %48, !dbg !24

44:                                               ; preds = %41
  %45 = load i16, i16* %2, align 2, !dbg !25
  %46 = load i16, i16* %4, align 2, !dbg !26
  %47 = icmp ult i16 %45, %46, !dbg !27
  br label %48, !dbg !24

48:                                               ; preds = %43, %44
  %49 = phi i1 [ %47, %44 ], [ false, %43 ]
  br label %50, !dbg !24

50:                                               ; preds = %48
  br i1 %49, label %51, label %66, !dbg !24

51:                                               ; preds = %50
  %52 = load i16, i16* %2, align 2, !dbg !28
  %53 = getelementptr [64 x i16], [64 x i16]* @col_idx, i16 0, i16 %52, !dbg !29
  %54 = load i16, i16* %53, align 2, !dbg !29
  store i16 %54, i16* %1, align 2, !dbg !7
  %55 = load float, float* %3, align 4, !dbg !30
  %56 = load i16, i16* %2, align 2, !dbg !31
  %57 = getelementptr [64 x float], [64 x float]* @"$$csl_base_address$$0$$val", i16 0, i16 %56, !dbg !32
  %58 = load float, float* %57, align 4, !dbg !32
  %59 = load i16, i16* %1, align 2, !dbg !33
  %60 = getelementptr [16 x float], [16 x float]* @"$$csl_base_address$$1$$x", i16 0, i16 %59, !dbg !34
  %61 = load float, float* %60, align 4, !dbg !34
  %62 = fmul float %58, %61, !dbg !35
  %63 = fadd float %55, %62, !dbg !36
  store float %63, float* %3, align 4, !dbg !36
  %64 = load i16, i16* %2, align 2, !dbg !37
  %65 = add i16 %64, 1, !dbg !38
  store i16 %65, i16* %2, align 2, !dbg !38
  br label %33, !dbg !24

66:                                               ; preds = %50
  %67 = icmp ne i16 %40, 0, !dbg !24
  br i1 %67, label %68, label %69, !dbg !24

68:                                               ; preds = %66
  br label %73, !dbg !24

69:                                               ; preds = %66
  %70 = load float, float* %3, align 4, !dbg !39
  %71 = load i16, i16* %6, align 2, !dbg !40
  %72 = getelementptr [16 x float], [16 x float]* @y_sc, i16 0, i16 %71, !dbg !41
  store float %70, float* %72, align 4, !dbg !42
  br label %73, !dbg !24

73:                                               ; preds = %68, %69
  %74 = phi i16 [ 0, %69 ], [ %40, %68 ]
  br label %75, !dbg !24

75:                                               ; preds = %73
  %76 = icmp eq i16 %74, -1, !dbg !15
  %77 = select i1 %76, i16 0, i16 %74, !dbg !15
  %78 = icmp ne i16 %77, 0, !dbg !15
  br i1 %78, label %79, label %80, !dbg !15

79:                                               ; preds = %75
  br label %83, !dbg !15

80:                                               ; preds = %75
  %81 = load i16, i16* %6, align 2, !dbg !43
  %82 = add i16 %81, 1, !dbg !44
  store i16 %82, i16* %6, align 2, !dbg !44
  br label %83, !dbg !15

83:                                               ; preds = %79, %80
  %84 = phi i16 [ 0, %80 ], [ %77, %79 ]
  br label %85, !dbg !15

85:                                               ; preds = %83
  br label %7, !dbg !15

86:                                               ; preds = %23
  %87 = icmp ne i16 %14, 0, !dbg !15
  br i1 %87, label %88, label %89, !dbg !15

88:                                               ; preds = %86
  br label %90, !dbg !15

89:                                               ; preds = %86
  store i16 28673, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i2 1), align 2, !dbg !45
  call void @llvm.sdr.actvt.r(i16 9), !dbg !46
  br label %90, !dbg !15

90:                                               ; preds = %88, %89
  ret void, !dbg !15
}

define internal void @spmv_ir() !dbg !47 {
  store i16 28674, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i3 2), align 2, !dbg !48
  store float 0.000000e+00, float* getelementptr inbounds ([16 x float], [16 x float]* @y_ir, i16 0, i1 false), align 4, !dbg !50
  store i16 28675, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i3 3), align 2, !dbg !51
  call void @llvm.sdr.actvt.r(i16 9), !dbg !52
  ret void, !dbg !53
}

define internal void @spmv_blk() !dbg !54 {
  %1 = alloca i16, i16 1, align 2, !dbg !55
  %2 = alloca float, i16 1, align 4, !dbg !57
  %3 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !58
  %4 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !59
  %5 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !60
  %6 = alloca i16, i16 1, align 2, !dbg !61
  %7 = alloca i16, i16 1, align 2, !dbg !62
  %8 = alloca i16, i16 1, align 2, !dbg !63
  %9 = alloca i16, i16 1, align 2, !dbg !64
  store i16 28676, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i4 4), align 2, !dbg !65
  store i16 0, i16* %9, align 2, !dbg !64
  br label %10, !dbg !66

10:                                               ; preds = %151, %0
  %11 = phi i16 [ %150, %151 ], [ 0, %0 ]
  %12 = icmp sgt i16 %11, 0, !dbg !66
  br i1 %12, label %13, label %15, !dbg !66

13:                                               ; preds = %10
  %14 = sub i16 %11, 1, !dbg !66
  br label %16, !dbg !66

15:                                               ; preds = %10
  br label %16, !dbg !66

16:                                               ; preds = %13, %15
  %17 = phi i16 [ %11, %15 ], [ %14, %13 ]
  br label %18, !dbg !66

18:                                               ; preds = %16
  %19 = icmp ne i16 %11, 0, !dbg !66
  br i1 %19, label %20, label %21, !dbg !66

20:                                               ; preds = %18
  br label %24, !dbg !66

21:                                               ; preds = %18
  %22 = load i16, i16* %9, align 2, !dbg !67
  %23 = icmp ult i16 %22, 16, !dbg !68
  br label %24, !dbg !66

24:                                               ; preds = %20, %21
  %25 = phi i1 [ %23, %21 ], [ false, %20 ]
  br label %26, !dbg !66

26:                                               ; preds = %24
  br i1 %25, label %27, label %152, !dbg !66

27:                                               ; preds = %26
  %28 = load i16, i16* %9, align 2, !dbg !69
  %29 = getelementptr [18 x i16], [18 x i16]* @row_ptr, i16 0, i16 %28, !dbg !70
  %30 = load i16, i16* %29, align 2, !dbg !70
  store i16 %30, i16* %8, align 2, !dbg !63
  %31 = load i16, i16* %9, align 2, !dbg !71
  %32 = getelementptr [16 x i16], [16 x i16]* @run_len, i16 0, i16 %31, !dbg !72
  %33 = load i16, i16* %32, align 2, !dbg !72
  store i16 %33, i16* %7, align 2, !dbg !62
  %34 = load i16, i16* %9, align 2, !dbg !73
  %35 = getelementptr [16 x i16], [16 x i16]* @col_start, i16 0, i16 %34, !dbg !74
  %36 = load i16, i16* %35, align 2, !dbg !74
  store i16 %36, i16* %6, align 2, !dbg !61
  %37 = load i16, i16* %7, align 2, !dbg !75
  %38 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %5, i32 0, i32 0, !dbg !60
  store i16 %37, i16* %38, align 2, !dbg !60
  %39 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %5, i32 0, i32 1, !dbg !60
  store i16 lshr (i16 ptrtoint ([64 x float]* @"$$csl_base_address$$0$$val" to i16), i16 1), i16* %39, align 2, !dbg !60
  %40 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %5, i32 0, i32 2, !dbg !60
  store i16 143, i16* %40, align 2, !dbg !60
  %41 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %5, i32 0, i32 3, !dbg !60
  store i16 16, i16* %41, align 2, !dbg !60
  %42 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %5, i32 0, i32 0, !dbg !76
  %43 = load i16, i16* %42, align 2, !dbg !76
  %44 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %5, i32 0, i32 1, !dbg !76
  %45 = load i16, i16* %44, align 2, !dbg !76
  %46 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %5, i32 0, i32 2, !dbg !76
  %47 = load i16, i16* %46, align 2, !dbg !76
  %48 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %5, i32 0, i32 3, !dbg !76
  %49 = load i16, i16* %48, align 2, !dbg !76
  %50 = load i16, i16* %8, align 2, !dbg !77
  %51 = mul i16 %50, 2, !dbg !78
  %52 = add i16 %45, %51, !dbg !78
  %53 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %5, i32 0, i32 0, !dbg !79
  store i16 %43, i16* %53, align 2, !dbg !79
  %54 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %5, i32 0, i32 1, !dbg !79
  store i16 %52, i16* %54, align 2, !dbg !79
  %55 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %5, i32 0, i32 2, !dbg !79
  store i16 %47, i16* %55, align 2, !dbg !79
  %56 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %5, i32 0, i32 3, !dbg !79
  store i16 %49, i16* %56, align 2, !dbg !79
  %57 = load i16, i16* %7, align 2, !dbg !80
  %58 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !59
  store i16 %57, i16* %58, align 2, !dbg !59
  %59 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !59
  store i16 lshr (i16 ptrtoint ([16 x float]* @"$$csl_base_address$$1$$x" to i16), i16 1), i16* %59, align 2, !dbg !59
  %60 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !59
  store i16 143, i16* %60, align 2, !dbg !59
  %61 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !59
  store i16 16, i16* %61, align 2, !dbg !59
  %62 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !81
  %63 = load i16, i16* %62, align 2, !dbg !81
  %64 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !81
  %65 = load i16, i16* %64, align 2, !dbg !81
  %66 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !81
  %67 = load i16, i16* %66, align 2, !dbg !81
  %68 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !81
  %69 = load i16, i16* %68, align 2, !dbg !81
  %70 = load i16, i16* %6, align 2, !dbg !82
  %71 = mul i16 %70, 2, !dbg !83
  %72 = add i16 %65, %71, !dbg !83
  %73 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !84
  store i16 %63, i16* %73, align 2, !dbg !84
  %74 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !84
  store i16 %72, i16* %74, align 2, !dbg !84
  %75 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !84
  store i16 %67, i16* %75, align 2, !dbg !84
  %76 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !84
  store i16 %69, i16* %76, align 2, !dbg !84
  %77 = load i16, i16* %7, align 2, !dbg !85
  %78 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 0, !dbg !58
  store i16 %77, i16* %78, align 2, !dbg !58
  %79 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 1, !dbg !58
  store i16 lshr (i16 ptrtoint ([16 x float]* @"$$csl_base_address$$2$$tmp" to i16), i16 1), i16* %79, align 2, !dbg !58
  %80 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 2, !dbg !58
  store i16 143, i16* %80, align 2, !dbg !58
  %81 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 3, !dbg !58
  store i16 16, i16* %81, align 2, !dbg !58
  %82 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 0, !dbg !86
  %83 = load i16, i16* %82, align 2, !dbg !86
  %84 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 1, !dbg !86
  %85 = load i16, i16* %84, align 2, !dbg !86
  %86 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 2, !dbg !86
  %87 = load i16, i16* %86, align 2, !dbg !86
  %88 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 3, !dbg !86
  %89 = load i16, i16* %88, align 2, !dbg !86
  %90 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %5, i32 0, i32 0, !dbg !87
  %91 = load i16, i16* %90, align 2, !dbg !87
  %92 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %5, i32 0, i32 1, !dbg !87
  %93 = load i16, i16* %92, align 2, !dbg !87
  %94 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %5, i32 0, i32 2, !dbg !87
  %95 = load i16, i16* %94, align 2, !dbg !87
  %96 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %5, i32 0, i32 3, !dbg !87
  %97 = load i16, i16* %96, align 2, !dbg !87
  %98 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !88
  %99 = load i16, i16* %98, align 2, !dbg !88
  %100 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !88
  %101 = load i16, i16* %100, align 2, !dbg !88
  %102 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !88
  %103 = load i16, i16* %102, align 2, !dbg !88
  %104 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !88
  %105 = load i16, i16* %104, align 2, !dbg !88
  store volatile i16 %83, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 0), align 2, !dbg !89
  store volatile i16 %85, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 1), align 2, !dbg !89
  store volatile i16 %87, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 2), align 2, !dbg !89
  store volatile i16 %89, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 3), align 2, !dbg !89
  call void asm sideeffect "nop", ""(), !dbg !89
  call void asm sideeffect "nop", ""(), !dbg !89
  store volatile i16 %91, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -896 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 0), align 2, !dbg !89
  store volatile i16 %93, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -896 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 1), align 2, !dbg !89
  store volatile i16 %95, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -896 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 2), align 2, !dbg !89
  store volatile i16 %97, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -896 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 3), align 2, !dbg !89
  call void asm sideeffect "nop", ""(), !dbg !89
  call void asm sideeffect "nop", ""(), !dbg !89
  store volatile i16 %99, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 0), align 2, !dbg !89
  store volatile i16 %101, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 1), align 2, !dbg !89
  store volatile i16 %103, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 2), align 2, !dbg !89
  store volatile i16 %105, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 3), align 2, !dbg !89
  call void asm sideeffect "nop", ""(), !dbg !89
  call void asm sideeffect "nop", ""(), !dbg !89
  call void @llvm.sdr.fmuls.ds0s1(i16 1, i16 1, i16 1), !dbg !89
  store float 0.000000e+00, float* %2, align 4, !dbg !57
  store i16 0, i16* %1, align 2, !dbg !55
  br label %106, !dbg !90

106:                                              ; preds = %124, %27
  %107 = phi i16 [ 0, %124 ], [ 0, %27 ]
  %108 = icmp sgt i16 %107, 0, !dbg !90
  br i1 %108, label %109, label %111, !dbg !90

109:                                              ; preds = %106
  %110 = sub i16 %107, 1, !dbg !90
  br label %112, !dbg !90

111:                                              ; preds = %106
  br label %112, !dbg !90

112:                                              ; preds = %109, %111
  %113 = phi i16 [ %107, %111 ], [ %110, %109 ]
  br label %114, !dbg !90

114:                                              ; preds = %112
  %115 = icmp ne i16 %107, 0, !dbg !90
  br i1 %115, label %116, label %117, !dbg !90

116:                                              ; preds = %114
  br label %121, !dbg !90

117:                                              ; preds = %114
  %118 = load i16, i16* %1, align 2, !dbg !91
  %119 = load i16, i16* %7, align 2, !dbg !92
  %120 = icmp ult i16 %118, %119, !dbg !93
  br label %121, !dbg !90

121:                                              ; preds = %116, %117
  %122 = phi i1 [ %120, %117 ], [ false, %116 ]
  br label %123, !dbg !90

123:                                              ; preds = %121
  br i1 %122, label %124, label %132, !dbg !90

124:                                              ; preds = %123
  %125 = load float, float* %2, align 4, !dbg !94
  %126 = load i16, i16* %1, align 2, !dbg !95
  %127 = getelementptr [16 x float], [16 x float]* @"$$csl_base_address$$2$$tmp", i16 0, i16 %126, !dbg !96
  %128 = load float, float* %127, align 4, !dbg !96
  %129 = fadd float %125, %128, !dbg !97
  store float %129, float* %2, align 4, !dbg !97
  %130 = load i16, i16* %1, align 2, !dbg !98
  %131 = add i16 %130, 1, !dbg !99
  store i16 %131, i16* %1, align 2, !dbg !99
  br label %106, !dbg !90

132:                                              ; preds = %123
  %133 = icmp ne i16 %113, 0, !dbg !90
  br i1 %133, label %134, label %135, !dbg !90

134:                                              ; preds = %132
  br label %139, !dbg !90

135:                                              ; preds = %132
  %136 = load float, float* %2, align 4, !dbg !100
  %137 = load i16, i16* %9, align 2, !dbg !101
  %138 = getelementptr [16 x float], [16 x float]* @y_bk, i16 0, i16 %137, !dbg !102
  store float %136, float* %138, align 4, !dbg !103
  br label %139, !dbg !90

139:                                              ; preds = %134, %135
  %140 = phi i16 [ 0, %135 ], [ %113, %134 ]
  br label %141, !dbg !90

141:                                              ; preds = %139
  %142 = icmp eq i16 %140, -1, !dbg !66
  %143 = select i1 %142, i16 0, i16 %140, !dbg !66
  %144 = icmp ne i16 %143, 0, !dbg !66
  br i1 %144, label %145, label %146, !dbg !66

145:                                              ; preds = %141
  br label %149, !dbg !66

146:                                              ; preds = %141
  %147 = load i16, i16* %9, align 2, !dbg !104
  %148 = add i16 %147, 1, !dbg !105
  store i16 %148, i16* %9, align 2, !dbg !105
  br label %149, !dbg !66

149:                                              ; preds = %145, %146
  %150 = phi i16 [ 0, %146 ], [ %143, %145 ]
  br label %151, !dbg !66

151:                                              ; preds = %149
  br label %10, !dbg !66

152:                                              ; preds = %26
  %153 = icmp ne i16 %17, 0, !dbg !66
  br i1 %153, label %154, label %155, !dbg !66

154:                                              ; preds = %152
  br label %156, !dbg !66

155:                                              ; preds = %152
  store i16 28677, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i4 5), align 2, !dbg !106
  call void @llvm.sdr.actvt.r(i16 9), !dbg !107
  br label %156, !dbg !66

156:                                              ; preds = %154, %155
  ret void, !dbg !66
}

define internal void @spmv_blk_dsdred() !dbg !108 {
  %1 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !109
  %2 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !111
  %3 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !112
  %4 = alloca i16, i16 1, align 2, !dbg !113
  %5 = alloca i16, i16 1, align 2, !dbg !114
  %6 = alloca i16, i16 1, align 2, !dbg !115
  %7 = alloca i16, i16 1, align 2, !dbg !116
  store i16 28684, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i5 12), align 2, !dbg !117
  store i16 0, i16* %7, align 2, !dbg !116
  br label %8, !dbg !118

8:                                                ; preds = %25, %0
  %9 = phi i16 [ 0, %25 ], [ 0, %0 ]
  %10 = icmp sgt i16 %9, 0, !dbg !118
  br i1 %10, label %11, label %13, !dbg !118

11:                                               ; preds = %8
  %12 = sub i16 %9, 1, !dbg !118
  br label %14, !dbg !118

13:                                               ; preds = %8
  br label %14, !dbg !118

14:                                               ; preds = %11, %13
  %15 = phi i16 [ %9, %13 ], [ %12, %11 ]
  br label %16, !dbg !118

16:                                               ; preds = %14
  %17 = icmp ne i16 %9, 0, !dbg !118
  br i1 %17, label %18, label %19, !dbg !118

18:                                               ; preds = %16
  br label %22, !dbg !118

19:                                               ; preds = %16
  %20 = load i16, i16* %7, align 2, !dbg !119
  %21 = icmp ult i16 %20, 16, !dbg !120
  br label %22, !dbg !118

22:                                               ; preds = %18, %19
  %23 = phi i1 [ %21, %19 ], [ false, %18 ]
  br label %24, !dbg !118

24:                                               ; preds = %22
  br i1 %23, label %25, label %119, !dbg !118

25:                                               ; preds = %24
  %26 = load i16, i16* %7, align 2, !dbg !121
  %27 = getelementptr [18 x i16], [18 x i16]* @row_ptr, i16 0, i16 %26, !dbg !122
  %28 = load i16, i16* %27, align 2, !dbg !122
  store i16 %28, i16* %6, align 2, !dbg !115
  %29 = load i16, i16* %7, align 2, !dbg !123
  %30 = getelementptr [16 x i16], [16 x i16]* @run_len, i16 0, i16 %29, !dbg !124
  %31 = load i16, i16* %30, align 2, !dbg !124
  store i16 %31, i16* %5, align 2, !dbg !114
  %32 = load i16, i16* %7, align 2, !dbg !125
  %33 = getelementptr [16 x i16], [16 x i16]* @col_start, i16 0, i16 %32, !dbg !126
  %34 = load i16, i16* %33, align 2, !dbg !126
  store i16 %34, i16* %4, align 2, !dbg !113
  %35 = load i16, i16* %5, align 2, !dbg !127
  %36 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 0, !dbg !112
  store i16 %35, i16* %36, align 2, !dbg !112
  %37 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 1, !dbg !112
  store i16 lshr (i16 ptrtoint ([64 x float]* @"$$csl_base_address$$0$$val" to i16), i16 1), i16* %37, align 2, !dbg !112
  %38 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 2, !dbg !112
  store i16 143, i16* %38, align 2, !dbg !112
  %39 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 3, !dbg !112
  store i16 16, i16* %39, align 2, !dbg !112
  %40 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 0, !dbg !128
  %41 = load i16, i16* %40, align 2, !dbg !128
  %42 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 1, !dbg !128
  %43 = load i16, i16* %42, align 2, !dbg !128
  %44 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 2, !dbg !128
  %45 = load i16, i16* %44, align 2, !dbg !128
  %46 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 3, !dbg !128
  %47 = load i16, i16* %46, align 2, !dbg !128
  %48 = load i16, i16* %6, align 2, !dbg !129
  %49 = mul i16 %48, 2, !dbg !130
  %50 = add i16 %43, %49, !dbg !130
  %51 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 0, !dbg !131
  store i16 %41, i16* %51, align 2, !dbg !131
  %52 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 1, !dbg !131
  store i16 %50, i16* %52, align 2, !dbg !131
  %53 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 2, !dbg !131
  store i16 %45, i16* %53, align 2, !dbg !131
  %54 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 3, !dbg !131
  store i16 %47, i16* %54, align 2, !dbg !131
  %55 = load i16, i16* %5, align 2, !dbg !132
  %56 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 0, !dbg !111
  store i16 %55, i16* %56, align 2, !dbg !111
  %57 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 1, !dbg !111
  store i16 lshr (i16 ptrtoint ([16 x float]* @"$$csl_base_address$$1$$x" to i16), i16 1), i16* %57, align 2, !dbg !111
  %58 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 2, !dbg !111
  store i16 143, i16* %58, align 2, !dbg !111
  %59 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 3, !dbg !111
  store i16 16, i16* %59, align 2, !dbg !111
  %60 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 0, !dbg !133
  %61 = load i16, i16* %60, align 2, !dbg !133
  %62 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 1, !dbg !133
  %63 = load i16, i16* %62, align 2, !dbg !133
  %64 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 2, !dbg !133
  %65 = load i16, i16* %64, align 2, !dbg !133
  %66 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 3, !dbg !133
  %67 = load i16, i16* %66, align 2, !dbg !133
  %68 = load i16, i16* %4, align 2, !dbg !134
  %69 = mul i16 %68, 2, !dbg !135
  %70 = add i16 %63, %69, !dbg !135
  %71 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 0, !dbg !136
  store i16 %61, i16* %71, align 2, !dbg !136
  %72 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 1, !dbg !136
  store i16 %70, i16* %72, align 2, !dbg !136
  %73 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 2, !dbg !136
  store i16 %65, i16* %73, align 2, !dbg !136
  %74 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 3, !dbg !136
  store i16 %67, i16* %74, align 2, !dbg !136
  %75 = load i16, i16* %5, align 2, !dbg !137
  %76 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 0, !dbg !109
  store i16 %75, i16* %76, align 2, !dbg !109
  %77 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 1, !dbg !109
  store i16 lshr (i16 ptrtoint ([16 x float]* @"$$csl_base_address$$2$$tmp" to i16), i16 1), i16* %77, align 2, !dbg !109
  %78 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 2, !dbg !109
  store i16 143, i16* %78, align 2, !dbg !109
  %79 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 3, !dbg !109
  store i16 16, i16* %79, align 2, !dbg !109
  %80 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 0, !dbg !138
  %81 = load i16, i16* %80, align 2, !dbg !138
  %82 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 1, !dbg !138
  %83 = load i16, i16* %82, align 2, !dbg !138
  %84 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 2, !dbg !138
  %85 = load i16, i16* %84, align 2, !dbg !138
  %86 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 3, !dbg !138
  %87 = load i16, i16* %86, align 2, !dbg !138
  %88 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 0, !dbg !139
  %89 = load i16, i16* %88, align 2, !dbg !139
  %90 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 1, !dbg !139
  %91 = load i16, i16* %90, align 2, !dbg !139
  %92 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 2, !dbg !139
  %93 = load i16, i16* %92, align 2, !dbg !139
  %94 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 3, !dbg !139
  %95 = load i16, i16* %94, align 2, !dbg !139
  %96 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 0, !dbg !140
  %97 = load i16, i16* %96, align 2, !dbg !140
  %98 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 1, !dbg !140
  %99 = load i16, i16* %98, align 2, !dbg !140
  %100 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 2, !dbg !140
  %101 = load i16, i16* %100, align 2, !dbg !140
  %102 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 3, !dbg !140
  %103 = load i16, i16* %102, align 2, !dbg !140
  store volatile i16 %81, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 0), align 2, !dbg !141
  store volatile i16 %83, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 1), align 2, !dbg !141
  store volatile i16 %85, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 2), align 2, !dbg !141
  store volatile i16 %87, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 3), align 2, !dbg !141
  call void asm sideeffect "nop", ""(), !dbg !141
  call void asm sideeffect "nop", ""(), !dbg !141
  store volatile i16 %89, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -896 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 0), align 2, !dbg !141
  store volatile i16 %91, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -896 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 1), align 2, !dbg !141
  store volatile i16 %93, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -896 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 2), align 2, !dbg !141
  store volatile i16 %95, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -896 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 3), align 2, !dbg !141
  call void asm sideeffect "nop", ""(), !dbg !141
  call void asm sideeffect "nop", ""(), !dbg !141
  store volatile i16 %97, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 0), align 2, !dbg !141
  store volatile i16 %99, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 1), align 2, !dbg !141
  store volatile i16 %101, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 2), align 2, !dbg !141
  store volatile i16 %103, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 3), align 2, !dbg !141
  call void asm sideeffect "nop", ""(), !dbg !141
  call void asm sideeffect "nop", ""(), !dbg !141
  call void @llvm.sdr.fmuls.ds0s1(i16 1, i16 1, i16 1), !dbg !141
  store float 0.000000e+00, float* @acc32, align 4, !dbg !142
  %104 = load float, float* @acc32, align 4, !dbg !143
  %105 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 0, !dbg !144
  %106 = load i16, i16* %105, align 2, !dbg !144
  %107 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 1, !dbg !144
  %108 = load i16, i16* %107, align 2, !dbg !144
  %109 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 2, !dbg !144
  %110 = load i16, i16* %109, align 2, !dbg !144
  %111 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 3, !dbg !144
  %112 = load i16, i16* %111, align 2, !dbg !144
  store volatile i16 %106, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 0), align 2, !dbg !145
  store volatile i16 %108, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 1), align 2, !dbg !145
  store volatile i16 %110, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 2), align 2, !dbg !145
  store volatile i16 %112, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 3), align 2, !dbg !145
  call void asm sideeffect "nop", ""(), !dbg !145
  call void asm sideeffect "nop", ""(), !dbg !145
  %113 = call float @llvm.sdr.fadds.rrs1(float %104, i16 1), !dbg !145
  store float %113, float* @acc32, align 4, !dbg !145
  %114 = load float, float* @acc32, align 4, !dbg !146
  %115 = load i16, i16* %7, align 2, !dbg !147
  %116 = getelementptr [16 x float], [16 x float]* @y_bd, i16 0, i16 %115, !dbg !148
  store float %114, float* %116, align 4, !dbg !149
  %117 = load i16, i16* %7, align 2, !dbg !150
  %118 = add i16 %117, 1, !dbg !151
  store i16 %118, i16* %7, align 2, !dbg !151
  br label %8, !dbg !118

119:                                              ; preds = %24
  %120 = icmp ne i16 %15, 0, !dbg !118
  br i1 %120, label %121, label %122, !dbg !118

121:                                              ; preds = %119
  br label %123, !dbg !118

122:                                              ; preds = %119
  store i16 28685, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i5 13), align 2, !dbg !152
  call void @llvm.sdr.actvt.r(i16 9), !dbg !153
  br label %123, !dbg !118

123:                                              ; preds = %121, %122
  ret void, !dbg !118
}

define internal void @spmv_dia() !dbg !154 {
  %1 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !155
  %2 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !157
  %3 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !158
  %4 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !159
  %5 = alloca i16, i16 1, align 2, !dbg !160
  %6 = alloca i16, i16 1, align 2, !dbg !161
  store i16 28678, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i4 6), align 2, !dbg !162
  call void @llvm.sdr.lddwds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !163
  call void @llvm.sdr.fmov32.dr(i16 1, float 0.000000e+00), !dbg !163
  store i16 0, i16* %6, align 2, !dbg !161
  br label %7, !dbg !164

7:                                                ; preds = %24, %0
  %8 = phi i16 [ 0, %24 ], [ 0, %0 ]
  %9 = icmp sgt i16 %8, 0, !dbg !164
  br i1 %9, label %10, label %12, !dbg !164

10:                                               ; preds = %7
  %11 = sub i16 %8, 1, !dbg !164
  br label %13, !dbg !164

12:                                               ; preds = %7
  br label %13, !dbg !164

13:                                               ; preds = %10, %12
  %14 = phi i16 [ %8, %12 ], [ %11, %10 ]
  br label %15, !dbg !164

15:                                               ; preds = %13
  %16 = icmp ne i16 %8, 0, !dbg !164
  br i1 %16, label %17, label %18, !dbg !164

17:                                               ; preds = %15
  br label %21, !dbg !164

18:                                               ; preds = %15
  %19 = load i16, i16* %6, align 2, !dbg !165
  %20 = icmp ult i16 %19, 4, !dbg !166
  br label %21, !dbg !164

21:                                               ; preds = %17, %18
  %22 = phi i1 [ %20, %18 ], [ false, %17 ]
  br label %23, !dbg !164

23:                                               ; preds = %21
  br i1 %22, label %24, label %149, !dbg !164

24:                                               ; preds = %23
  %25 = load i16, i16* %6, align 2, !dbg !167
  %26 = getelementptr [4 x i16], [4 x i16]* @dia_len, i16 0, i16 %25, !dbg !168
  %27 = load i16, i16* %26, align 2, !dbg !168
  store i16 %27, i16* %5, align 2, !dbg !160
  %28 = load i16, i16* %5, align 2, !dbg !169
  %29 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !159
  store i16 %28, i16* %29, align 2, !dbg !159
  %30 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !159
  store i16 lshr (i16 ptrtoint ([64 x float]* @"$$csl_base_address$$4$$dia_val" to i16), i16 1), i16* %30, align 2, !dbg !159
  %31 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !159
  store i16 143, i16* %31, align 2, !dbg !159
  %32 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !159
  store i16 16, i16* %32, align 2, !dbg !159
  %33 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !170
  %34 = load i16, i16* %33, align 2, !dbg !170
  %35 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !170
  %36 = load i16, i16* %35, align 2, !dbg !170
  %37 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !170
  %38 = load i16, i16* %37, align 2, !dbg !170
  %39 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !170
  %40 = load i16, i16* %39, align 2, !dbg !170
  %41 = load i16, i16* %6, align 2, !dbg !171
  %42 = getelementptr [4 x i16], [4 x i16]* @dia_off, i16 0, i16 %41, !dbg !172
  %43 = load i16, i16* %42, align 2, !dbg !172
  %44 = mul i16 %43, 2, !dbg !173
  %45 = add i16 %36, %44, !dbg !173
  %46 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !174
  store i16 %34, i16* %46, align 2, !dbg !174
  %47 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !174
  store i16 %45, i16* %47, align 2, !dbg !174
  %48 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !174
  store i16 %38, i16* %48, align 2, !dbg !174
  %49 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !174
  store i16 %40, i16* %49, align 2, !dbg !174
  %50 = load i16, i16* %5, align 2, !dbg !175
  %51 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 0, !dbg !158
  store i16 %50, i16* %51, align 2, !dbg !158
  %52 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 1, !dbg !158
  store i16 lshr (i16 ptrtoint ([16 x float]* @"$$csl_base_address$$1$$x" to i16), i16 1), i16* %52, align 2, !dbg !158
  %53 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 2, !dbg !158
  store i16 143, i16* %53, align 2, !dbg !158
  %54 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 3, !dbg !158
  store i16 16, i16* %54, align 2, !dbg !158
  %55 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 0, !dbg !176
  %56 = load i16, i16* %55, align 2, !dbg !176
  %57 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 1, !dbg !176
  %58 = load i16, i16* %57, align 2, !dbg !176
  %59 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 2, !dbg !176
  %60 = load i16, i16* %59, align 2, !dbg !176
  %61 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 3, !dbg !176
  %62 = load i16, i16* %61, align 2, !dbg !176
  %63 = load i16, i16* %6, align 2, !dbg !177
  %64 = getelementptr [4 x i16], [4 x i16]* @dia_xoff, i16 0, i16 %63, !dbg !178
  %65 = load i16, i16* %64, align 2, !dbg !178
  %66 = mul i16 %65, 2, !dbg !179
  %67 = add i16 %58, %66, !dbg !179
  %68 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 0, !dbg !180
  store i16 %56, i16* %68, align 2, !dbg !180
  %69 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 1, !dbg !180
  store i16 %67, i16* %69, align 2, !dbg !180
  %70 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 2, !dbg !180
  store i16 %60, i16* %70, align 2, !dbg !180
  %71 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 3, !dbg !180
  store i16 %62, i16* %71, align 2, !dbg !180
  %72 = load i16, i16* %5, align 2, !dbg !181
  %73 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 0, !dbg !157
  store i16 %72, i16* %73, align 2, !dbg !157
  %74 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 1, !dbg !157
  store i16 lshr (i16 ptrtoint ([16 x float]* @"$$csl_base_address$$2$$tmp" to i16), i16 1), i16* %74, align 2, !dbg !157
  %75 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 2, !dbg !157
  store i16 143, i16* %75, align 2, !dbg !157
  %76 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 3, !dbg !157
  store i16 16, i16* %76, align 2, !dbg !157
  %77 = load i16, i16* %5, align 2, !dbg !182
  %78 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 0, !dbg !155
  store i16 %77, i16* %78, align 2, !dbg !155
  %79 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 1, !dbg !155
  store i16 lshr (i16 ptrtoint ([16 x float]* @"$$csl_base_address$$3$$y_di" to i16), i16 1), i16* %79, align 2, !dbg !155
  %80 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 2, !dbg !155
  store i16 143, i16* %80, align 2, !dbg !155
  %81 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 3, !dbg !155
  store i16 16, i16* %81, align 2, !dbg !155
  %82 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 0, !dbg !183
  %83 = load i16, i16* %82, align 2, !dbg !183
  %84 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 1, !dbg !183
  %85 = load i16, i16* %84, align 2, !dbg !183
  %86 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 2, !dbg !183
  %87 = load i16, i16* %86, align 2, !dbg !183
  %88 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 3, !dbg !183
  %89 = load i16, i16* %88, align 2, !dbg !183
  %90 = load i16, i16* %6, align 2, !dbg !184
  %91 = getelementptr [4 x i16], [4 x i16]* @dia_row0, i16 0, i16 %90, !dbg !185
  %92 = load i16, i16* %91, align 2, !dbg !185
  %93 = mul i16 %92, 2, !dbg !186
  %94 = add i16 %85, %93, !dbg !186
  %95 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 0, !dbg !187
  store i16 %83, i16* %95, align 2, !dbg !187
  %96 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 1, !dbg !187
  store i16 %94, i16* %96, align 2, !dbg !187
  %97 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 2, !dbg !187
  store i16 %87, i16* %97, align 2, !dbg !187
  %98 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 3, !dbg !187
  store i16 %89, i16* %98, align 2, !dbg !187
  %99 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 0, !dbg !188
  %100 = load i16, i16* %99, align 2, !dbg !188
  %101 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 1, !dbg !188
  %102 = load i16, i16* %101, align 2, !dbg !188
  %103 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 2, !dbg !188
  %104 = load i16, i16* %103, align 2, !dbg !188
  %105 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 3, !dbg !188
  %106 = load i16, i16* %105, align 2, !dbg !188
  %107 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !189
  %108 = load i16, i16* %107, align 2, !dbg !189
  %109 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !189
  %110 = load i16, i16* %109, align 2, !dbg !189
  %111 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !189
  %112 = load i16, i16* %111, align 2, !dbg !189
  %113 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !189
  %114 = load i16, i16* %113, align 2, !dbg !189
  %115 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 0, !dbg !190
  %116 = load i16, i16* %115, align 2, !dbg !190
  %117 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 1, !dbg !190
  %118 = load i16, i16* %117, align 2, !dbg !190
  %119 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 2, !dbg !190
  %120 = load i16, i16* %119, align 2, !dbg !190
  %121 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 3, !dbg !190
  %122 = load i16, i16* %121, align 2, !dbg !190
  store volatile i16 %116, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 0), align 2, !dbg !191
  store volatile i16 %118, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 1), align 2, !dbg !191
  store volatile i16 %120, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 2), align 2, !dbg !191
  store volatile i16 %122, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 3), align 2, !dbg !191
  call void asm sideeffect "nop", ""(), !dbg !191
  call void asm sideeffect "nop", ""(), !dbg !191
  store volatile i16 %100, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 0), align 2, !dbg !191
  store volatile i16 %102, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 1), align 2, !dbg !191
  store volatile i16 %104, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 2), align 2, !dbg !191
  store volatile i16 %106, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 3), align 2, !dbg !191
  call void asm sideeffect "nop", ""(), !dbg !191
  call void asm sideeffect "nop", ""(), !dbg !191
  store volatile i16 %108, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -896 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 0), align 2, !dbg !191
  store volatile i16 %110, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -896 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 1), align 2, !dbg !191
  store volatile i16 %112, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -896 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 2), align 2, !dbg !191
  store volatile i16 %114, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -896 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 3), align 2, !dbg !191
  call void asm sideeffect "nop", ""(), !dbg !191
  call void asm sideeffect "nop", ""(), !dbg !191
  call void @llvm.sdr.fmuls.ds0s1(i16 1, i16 1, i16 1), !dbg !191
  %123 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 0, !dbg !192
  %124 = load i16, i16* %123, align 2, !dbg !192
  %125 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 1, !dbg !192
  %126 = load i16, i16* %125, align 2, !dbg !192
  %127 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 2, !dbg !192
  %128 = load i16, i16* %127, align 2, !dbg !192
  %129 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 3, !dbg !192
  %130 = load i16, i16* %129, align 2, !dbg !192
  %131 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 0, !dbg !193
  %132 = load i16, i16* %131, align 2, !dbg !193
  %133 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 1, !dbg !193
  %134 = load i16, i16* %133, align 2, !dbg !193
  %135 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 2, !dbg !193
  %136 = load i16, i16* %135, align 2, !dbg !193
  %137 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 3, !dbg !193
  %138 = load i16, i16* %137, align 2, !dbg !193
  %139 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 0, !dbg !194
  %140 = load i16, i16* %139, align 2, !dbg !194
  %141 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 1, !dbg !194
  %142 = load i16, i16* %141, align 2, !dbg !194
  %143 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 2, !dbg !194
  %144 = load i16, i16* %143, align 2, !dbg !194
  %145 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 3, !dbg !194
  %146 = load i16, i16* %145, align 2, !dbg !194
  store volatile i16 %140, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 0), align 2, !dbg !195
  store volatile i16 %142, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 1), align 2, !dbg !195
  store volatile i16 %144, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 2), align 2, !dbg !195
  store volatile i16 %146, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 3), align 2, !dbg !195
  call void asm sideeffect "nop", ""(), !dbg !195
  call void asm sideeffect "nop", ""(), !dbg !195
  store volatile i16 %124, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 0), align 2, !dbg !195
  store volatile i16 %126, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 1), align 2, !dbg !195
  store volatile i16 %128, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 2), align 2, !dbg !195
  store volatile i16 %130, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 3), align 2, !dbg !195
  call void asm sideeffect "nop", ""(), !dbg !195
  call void asm sideeffect "nop", ""(), !dbg !195
  store volatile i16 %132, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -896 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 0), align 2, !dbg !195
  store volatile i16 %134, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -896 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 1), align 2, !dbg !195
  store volatile i16 %136, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -896 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 2), align 2, !dbg !195
  store volatile i16 %138, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -896 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 3), align 2, !dbg !195
  call void asm sideeffect "nop", ""(), !dbg !195
  call void asm sideeffect "nop", ""(), !dbg !195
  call void @llvm.sdr.fadds.ds0s1(i16 1, i16 1, i16 1), !dbg !195
  %147 = load i16, i16* %6, align 2, !dbg !196
  %148 = add i16 %147, 1, !dbg !197
  store i16 %148, i16* %6, align 2, !dbg !197
  br label %7, !dbg !164

149:                                              ; preds = %23
  %150 = icmp ne i16 %14, 0, !dbg !164
  br i1 %150, label %151, label %152, !dbg !164

151:                                              ; preds = %149
  br label %153, !dbg !164

152:                                              ; preds = %149
  store i16 28679, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i4 7), align 2, !dbg !198
  call void @llvm.sdr.actvt.r(i16 9), !dbg !199
  br label %153, !dbg !164

153:                                              ; preds = %151, %152
  ret void, !dbg !164
}

define internal void @probe_reduce() !dbg !200 {
  %1 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !201
  store i16 28680, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i5 8), align 2, !dbg !203
  %2 = load float, float* getelementptr inbounds ([2 x float], [2 x float]* @probe_seed, i16 0, i1 false), align 4, !dbg !204
  store float %2, float* @acc32, align 4, !dbg !205
  %3 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 0, !dbg !201
  store i16 64, i16* %3, align 2, !dbg !201
  %4 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 1, !dbg !201
  store i16 lshr (i16 ptrtoint ([64 x float]* @"$$csl_base_address$$0$$val" to i16), i16 1), i16* %4, align 2, !dbg !201
  %5 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 2, !dbg !201
  store i16 143, i16* %5, align 2, !dbg !201
  %6 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 3, !dbg !201
  store i16 16, i16* %6, align 2, !dbg !201
  %7 = load float, float* @acc32, align 4, !dbg !206
  %8 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 0, !dbg !207
  %9 = load i16, i16* %8, align 2, !dbg !207
  %10 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 1, !dbg !207
  %11 = load i16, i16* %10, align 2, !dbg !207
  %12 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 2, !dbg !207
  %13 = load i16, i16* %12, align 2, !dbg !207
  %14 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 3, !dbg !207
  %15 = load i16, i16* %14, align 2, !dbg !207
  store volatile i16 %9, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 0), align 2, !dbg !208
  store volatile i16 %11, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 1), align 2, !dbg !208
  store volatile i16 %13, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 2), align 2, !dbg !208
  store volatile i16 %15, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 3), align 2, !dbg !208
  call void asm sideeffect "nop", ""(), !dbg !208
  call void asm sideeffect "nop", ""(), !dbg !208
  %16 = call float @llvm.sdr.fadds.rrs1(float %7, i16 1), !dbg !208
  store float %16, float* @acc32, align 4, !dbg !208
  %17 = load float, float* @acc32, align 4, !dbg !209
  store float %17, float* getelementptr inbounds ([2 x float], [2 x float]* @probe_out, i16 0, i1 false), align 4, !dbg !210
  store i16 28681, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i5 9), align 2, !dbg !211
  call void @llvm.sdr.actvt.r(i16 9), !dbg !212
  ret void, !dbg !213
}

define internal void @probe_reduce_const() !dbg !214 {
  %1 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !215
  store i16 28682, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i5 10), align 2, !dbg !217
  store float 0.000000e+00, float* @acc32, align 4, !dbg !218
  %2 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 0, !dbg !215
  store i16 64, i16* %2, align 2, !dbg !215
  %3 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 1, !dbg !215
  store i16 lshr (i16 ptrtoint ([64 x float]* @"$$csl_base_address$$0$$val" to i16), i16 1), i16* %3, align 2, !dbg !215
  %4 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 2, !dbg !215
  store i16 143, i16* %4, align 2, !dbg !215
  %5 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 3, !dbg !215
  store i16 16, i16* %5, align 2, !dbg !215
  %6 = load float, float* @acc32, align 4, !dbg !219
  %7 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 0, !dbg !220
  %8 = load i16, i16* %7, align 2, !dbg !220
  %9 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 1, !dbg !220
  %10 = load i16, i16* %9, align 2, !dbg !220
  %11 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 2, !dbg !220
  %12 = load i16, i16* %11, align 2, !dbg !220
  %13 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 3, !dbg !220
  %14 = load i16, i16* %13, align 2, !dbg !220
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 0), align 2, !dbg !221
  store volatile i16 %10, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 1), align 2, !dbg !221
  store volatile i16 %12, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 2), align 2, !dbg !221
  store volatile i16 %14, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 3), align 2, !dbg !221
  call void asm sideeffect "nop", ""(), !dbg !221
  call void asm sideeffect "nop", ""(), !dbg !221
  %15 = call float @llvm.sdr.fadds.rrs1(float %6, i16 1), !dbg !221
  store float %15, float* @acc32, align 4, !dbg !221
  %16 = load float, float* @acc32, align 4, !dbg !222
  store float %16, float* getelementptr inbounds ([2 x float], [2 x float]* @probe_out, i16 0, i2 1), align 4, !dbg !223
  store i16 28683, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i5 11), align 2, !dbg !224
  call void @llvm.sdr.actvt.r(i16 9), !dbg !225
  ret void, !dbg !226
}

define void @f_exit() #0 !dbg !227 {
  call void @sys_mod.unblock_cmd_stream(), !dbg !228
  ret void, !dbg !230
}

define internal void @sys_mod.sys_nop() !dbg !231 {
  ret void, !dbg !233
}

define internal void @sys_mod.unblock_cmd_stream() !dbg !235 {
  call void @sys_mod.sys_mod.unblock_cmd_stream(), !dbg !236
  ret void, !dbg !238
}

define internal void @sys_mod.sys_mod.unblock_cmd_stream() !dbg !239 {
  call void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream(), !dbg !241
  ret void, !dbg !243
}

define internal void @sys_mod.sys_mod.teardown_h2d() !dbg !244 {
  call void @llvm.sdr.actvt.r(i16 27), !dbg !245
  ret void, !dbg !247
}

define void @sys_mod.sys_mod.f_ublk_c22() #1 !dbg !248 {
  call void @sys_mod.sys_mod.unblock_cmd_stream(), !dbg !249
  ret void, !dbg !251
}

define internal void @sys_mod.sys_mod.teardown_d2h() !dbg !252 {
  call void @llvm.sdr.blk.r(i16 0), !dbg !253
  call void @llvm.sdr.actvt.r(i16 28), !dbg !255
  ret void, !dbg !256
}

define void @sys_mod.sys_mod.f_memcpyh2d() #2 !dbg !257 {
  %1 = alloca float, i16 1, align 4, !dbg !258
  %2 = alloca float, i16 1, align 4, !dbg !260
  %3 = alloca i16, i16 1, align 2, !dbg !261
  %4 = alloca i16, i16 1, align 2, !dbg !262
  %5 = alloca i16, i16 1, align 2, !dbg !263
  %6 = alloca i16, i16 1, align 2, !dbg !264
  %7 = alloca i16, i16 1, align 2, !dbg !265
  %8 = alloca i16, i16 1, align 2, !dbg !266
  %9 = alloca i16, i16 1, align 2, !dbg !267
  %10 = alloca i16, i16 1, align 2, !dbg !268
  %11 = alloca i16, i16 1, align 2, !dbg !269
  %12 = alloca i16, i16 1, align 2, !dbg !270
  %13 = alloca i16, i16 1, align 2, !dbg !271
  %14 = alloca i16*, i16 1, align 8, !dbg !272
  %15 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !273
  %16 = icmp eq i16 %15, 15, !dbg !274
  br i1 %16, label %17, label %18, !dbg !275

17:                                               ; preds = %0
  br label %19, !dbg !275

18:                                               ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !275
  br label %19, !dbg !275

19:                                               ; preds = %17, %18
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %14, align 8, !dbg !272
  %20 = load i16*, i16** %14, align 8, !dbg !276
  %21 = load i16, i16* %20, align 2, !dbg !277
  store i16 %21, i16* %13, align 2, !dbg !271
  %22 = load i16*, i16** %14, align 8, !dbg !278
  %23 = getelementptr i16, i16* %22, i16 1, !dbg !279
  %24 = load i16, i16* %23, align 2, !dbg !279
  store i16 %24, i16* %12, align 2, !dbg !270
  %25 = load i16*, i16** %14, align 8, !dbg !280
  %26 = getelementptr i16, i16* %25, i16 2, !dbg !281
  %27 = load i16, i16* %26, align 2, !dbg !281
  store i16 %27, i16* %11, align 2, !dbg !269
  %28 = load i16*, i16** %14, align 8, !dbg !282
  %29 = getelementptr i16, i16* %28, i16 3, !dbg !283
  %30 = load i16, i16* %29, align 2, !dbg !283
  store i16 %30, i16* %10, align 2, !dbg !268
  %31 = load i16*, i16** %14, align 8, !dbg !284
  %32 = getelementptr i16, i16* %31, i16 4, !dbg !285
  %33 = load i16, i16* %32, align 2, !dbg !285
  store i16 %33, i16* %9, align 2, !dbg !267
  %34 = load i16*, i16** %14, align 8, !dbg !286
  %35 = getelementptr i16, i16* %34, i16 5, !dbg !287
  %36 = load i16, i16* %35, align 2, !dbg !287
  store i16 %36, i16* %8, align 2, !dbg !266
  %37 = load i16*, i16** %14, align 8, !dbg !288
  %38 = getelementptr i16, i16* %37, i16 6, !dbg !289
  %39 = load i16, i16* %38, align 2, !dbg !289
  store i16 %39, i16* %7, align 2, !dbg !265
  %40 = load i16*, i16** %14, align 8, !dbg !290
  %41 = getelementptr i16, i16* %40, i16 7, !dbg !291
  %42 = load i16, i16* %41, align 2, !dbg !291
  store i16 %42, i16* %6, align 2, !dbg !264
  %43 = load i16*, i16** %14, align 8, !dbg !292
  %44 = getelementptr i16, i16* %43, i16 8, !dbg !293
  %45 = load i16, i16* %44, align 2, !dbg !293
  store i16 %45, i16* %5, align 2, !dbg !263
  %46 = load i16*, i16** %14, align 8, !dbg !294
  %47 = getelementptr i16, i16* %46, i16 9, !dbg !295
  %48 = load i16, i16* %47, align 2, !dbg !295
  store i16 %48, i16* %4, align 2, !dbg !262
  %49 = load i16*, i16** %14, align 8, !dbg !296
  %50 = getelementptr i16, i16* %49, i16 10, !dbg !297
  %51 = load i16, i16* %50, align 2, !dbg !297
  store i16 %51, i16* %3, align 2, !dbg !261
  %52 = load i16*, i16** %14, align 8, !dbg !298
  %53 = getelementptr i16, i16* %52, i16 12, !dbg !299
  %54 = load i16, i16* %53, align 2, !dbg !299
  %55 = zext i16 %54 to i32, !dbg !300
  %56 = load i16*, i16** %14, align 8, !dbg !301
  %57 = getelementptr i16, i16* %56, i16 11, !dbg !302
  %58 = load i16, i16* %57, align 2, !dbg !302
  %59 = zext i16 %58 to i32, !dbg !303
  %60 = add i32 %59, 16, !dbg !304
  %61 = shl i32 %55, %60, !dbg !305
  %62 = bitcast i32 %61 to float, !dbg !306
  store float %62, float* %2, align 4, !dbg !260
  %63 = load i16*, i16** %14, align 8, !dbg !307
  %64 = getelementptr i16, i16* %63, i16 14, !dbg !308
  %65 = load i16, i16* %64, align 2, !dbg !308
  %66 = zext i16 %65 to i32, !dbg !309
  %67 = load i16*, i16** %14, align 8, !dbg !310
  %68 = getelementptr i16, i16* %67, i16 13, !dbg !311
  %69 = load i16, i16* %68, align 2, !dbg !311
  %70 = zext i16 %69 to i32, !dbg !312
  %71 = add i32 %70, 16, !dbg !313
  %72 = shl i32 %66, %71, !dbg !314
  %73 = bitcast i32 %72 to float, !dbg !315
  store float %73, float* %1, align 4, !dbg !258
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !316
  %74 = load i16, i16* %13, align 2, !dbg !317
  store i16 %74, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !318
  %75 = load i16, i16* %12, align 2, !dbg !319
  store i16 %75, i16* @sys_mod.sys_mod.memcpyH2D_px, align 2, !dbg !320
  %76 = load i16, i16* %11, align 2, !dbg !321
  store i16 %76, i16* @sys_mod.sys_mod.memcpyH2D_py, align 2, !dbg !322
  %77 = load i16, i16* %10, align 2, !dbg !323
  store i16 %77, i16* @sys_mod.sys_mod.memcpyH2D_w, align 2, !dbg !324
  %78 = load i16, i16* %9, align 2, !dbg !325
  store i16 %78, i16* @sys_mod.sys_mod.memcpyH2D_h, align 2, !dbg !326
  %79 = load i16, i16* %8, align 2, !dbg !327
  store i16 %79, i16* @sys_mod.sys_mod.memcpyH2D_addr, align 2, !dbg !328
  %80 = load i16, i16* %7, align 2, !dbg !329
  store i16 %80, i16* @sys_mod.sys_mod.memcpyH2D_pe_length, align 2, !dbg !330
  %81 = load i16, i16* %6, align 2, !dbg !331
  store i16 %81, i16* @sys_mod.sys_mod.memcpyH2D_is_half, align 2, !dbg !332
  %82 = load i16, i16* %5, align 2, !dbg !333
  store i16 %82, i16* @sys_mod.sys_mod.memcpyH2D_memcpy_optype, align 2, !dbg !334
  %83 = load i16, i16* %4, align 2, !dbg !335
  store i16 %83, i16* @sys_mod.sys_mod.memcpyH2D_row_stride, align 2, !dbg !336
  %84 = load i16, i16* %3, align 2, !dbg !337
  store i16 %84, i16* @sys_mod.sys_mod.memcpyH2D_col_stride, align 2, !dbg !338
  %85 = load float, float* %2, align 4, !dbg !339
  store float %85, float* @sys_mod.sys_mod.memcpyH2D_one_over_row_stride, align 4, !dbg !340
  %86 = load float, float* %1, align 4, !dbg !341
  store float %86, float* @sys_mod.sys_mod.memcpyH2D_one_over_col_stride, align 4, !dbg !342
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !343
  call void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 0, i16 23, i1 true), !dbg !344
  call void @llvm.sdr.blk.r(i16 27), !dbg !345
  call void @llvm.sdr.oqflush(i16 0), !dbg !346
  store i1 true, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !347
  call void @llvm.sdr.blk.r(i16 0), !dbg !348
  ret void, !dbg !349
}

define void @sys_mod.sys_mod.f_memcpyd2h() #3 !dbg !350 {
  %1 = alloca i16, i16 1, align 2, !dbg !351
  %2 = alloca i16, i16 1, align 2, !dbg !353
  %3 = alloca i16, i16 1, align 2, !dbg !354
  %4 = alloca i16, i16 1, align 2, !dbg !355
  %5 = alloca i16, i16 1, align 2, !dbg !356
  %6 = alloca i16, i16 1, align 2, !dbg !357
  %7 = alloca i16, i16 1, align 2, !dbg !358
  %8 = alloca i16, i16 1, align 2, !dbg !359
  %9 = alloca i16*, i16 1, align 8, !dbg !360
  %10 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !361
  %11 = icmp eq i16 %10, 8, !dbg !362
  br i1 %11, label %12, label %13, !dbg !363

12:                                               ; preds = %0
  br label %14, !dbg !363

13:                                               ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !363
  br label %14, !dbg !363

14:                                               ; preds = %12, %13
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %9, align 8, !dbg !360
  %15 = load i16*, i16** %9, align 8, !dbg !364
  %16 = load i16, i16* %15, align 2, !dbg !365
  store i16 %16, i16* %8, align 2, !dbg !359
  %17 = load i16*, i16** %9, align 8, !dbg !366
  %18 = getelementptr i16, i16* %17, i16 1, !dbg !367
  %19 = load i16, i16* %18, align 2, !dbg !367
  store i16 %19, i16* %7, align 2, !dbg !358
  %20 = load i16*, i16** %9, align 8, !dbg !368
  %21 = getelementptr i16, i16* %20, i16 2, !dbg !369
  %22 = load i16, i16* %21, align 2, !dbg !369
  store i16 %22, i16* %6, align 2, !dbg !357
  %23 = load i16*, i16** %9, align 8, !dbg !370
  %24 = getelementptr i16, i16* %23, i16 3, !dbg !371
  %25 = load i16, i16* %24, align 2, !dbg !371
  store i16 %25, i16* %5, align 2, !dbg !356
  %26 = load i16*, i16** %9, align 8, !dbg !372
  %27 = getelementptr i16, i16* %26, i16 4, !dbg !373
  %28 = load i16, i16* %27, align 2, !dbg !373
  store i16 %28, i16* %4, align 2, !dbg !355
  %29 = load i16*, i16** %9, align 8, !dbg !374
  %30 = getelementptr i16, i16* %29, i16 5, !dbg !375
  %31 = load i16, i16* %30, align 2, !dbg !375
  store i16 %31, i16* %3, align 2, !dbg !354
  %32 = load i16*, i16** %9, align 8, !dbg !376
  %33 = getelementptr i16, i16* %32, i16 6, !dbg !377
  %34 = load i16, i16* %33, align 2, !dbg !377
  store i16 %34, i16* %2, align 2, !dbg !353
  %35 = load i16*, i16** %9, align 8, !dbg !378
  %36 = getelementptr i16, i16* %35, i16 7, !dbg !379
  %37 = load i16, i16* %36, align 2, !dbg !379
  store i16 %37, i16* %1, align 2, !dbg !351
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !380
  %38 = load i16, i16* %8, align 2, !dbg !381
  store i16 %38, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !382
  %39 = load i16, i16* %7, align 2, !dbg !383
  store i16 %39, i16* @sys_mod.sys_mod.memcpyD2H_px, align 2, !dbg !384
  %40 = load i16, i16* %6, align 2, !dbg !385
  store i16 %40, i16* @sys_mod.sys_mod.memcpyD2H_py, align 2, !dbg !386
  %41 = load i16, i16* %5, align 2, !dbg !387
  store i16 %41, i16* @sys_mod.sys_mod.memcpyD2H_w, align 2, !dbg !388
  %42 = load i16, i16* %4, align 2, !dbg !389
  store i16 %42, i16* @sys_mod.sys_mod.memcpyD2H_h, align 2, !dbg !390
  %43 = load i16, i16* %3, align 2, !dbg !391
  store i16 %43, i16* @sys_mod.sys_mod.memcpyD2H_addr, align 2, !dbg !392
  %44 = load i16, i16* %2, align 2, !dbg !393
  store i16 %44, i16* @sys_mod.sys_mod.memcpyD2H_pe_length, align 2, !dbg !394
  %45 = load i16, i16* %1, align 2, !dbg !395
  store i16 %45, i16* @sys_mod.sys_mod.memcpyD2H_is_half, align 2, !dbg !396
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !397
  %46 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !398
  call void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 0, i16 %46, i1 false), !dbg !399
  call void @llvm.sdr.oqflush(i16 0), !dbg !400
  store i1 false, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !401
  ret void, !dbg !402
}

define internal void @sys_mod.sys_mod.oq0_teardow_handler() !dbg !403 {
  %1 = load i1, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !404
  br i1 %1, label %2, label %17, !dbg !406

2:                                                ; preds = %0
  %3 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !407
  call void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 0, i16 %3), !dbg !408
  %4 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !409
  %5 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_px, align 2, !dbg !410
  %6 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_py, align 2, !dbg !411
  %7 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_w, align 2, !dbg !412
  %8 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_h, align 2, !dbg !413
  %9 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_addr, align 2, !dbg !414
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_pe_length, align 2, !dbg !415
  %11 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_is_half, align 2, !dbg !416
  %12 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_memcpy_optype, align 2, !dbg !417
  %13 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_row_stride, align 2, !dbg !418
  %14 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_col_stride, align 2, !dbg !419
  %15 = load float, float* @sys_mod.sys_mod.memcpyH2D_one_over_row_stride, align 4, !dbg !420
  %16 = load float, float* @sys_mod.sys_mod.memcpyH2D_one_over_col_stride, align 4, !dbg !421
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure(i16 %4, i16 %5, i16 %6, i16 %7, i16 %8, i16 %9, i16 %10, i16 %11, i16 %12, i16 %13, i16 %14, float %15, float %16), !dbg !422
  br label %26, !dbg !406

17:                                               ; preds = %0
  call void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 0, i16 21), !dbg !423
  %18 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !424
  %19 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_px, align 2, !dbg !425
  %20 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_py, align 2, !dbg !426
  %21 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_w, align 2, !dbg !427
  %22 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_h, align 2, !dbg !428
  %23 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_addr, align 2, !dbg !429
  %24 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_pe_length, align 2, !dbg !430
  %25 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_is_half, align 2, !dbg !431
  call void @sys_mod.sys_mod.memcpyd2h_mod.d2h_configure(i16 %18, i16 %19, i16 %20, i16 %21, i16 %22, i16 %23, i16 %24, i16 %25), !dbg !432
  br label %26, !dbg !406

26:                                               ; preds = %2, %17
  call void @__generic0sys_mod.sys_mod.tile_config.queue_flush.exit(), !dbg !433
  ret void, !dbg !406
}

define internal void @rpc_server(i32* %0) {
  %2 = load i32, i32* %0, align 4
  %3 = add i32 %2, 1
  %4 = getelementptr i32, i32* %0, i32 %3
  %5 = load i32, i32* %4, align 4
  switch i32 %5, label %6 [
    i32 23, label %7
    i32 22, label %12
    i32 20, label %17
    i32 25, label %22
    i32 24, label %27
    i32 19, label %32
    i32 21, label %37
  ]

6:                                                ; preds = %1
  br label %42

7:                                                ; preds = %1
  %8 = icmp eq i32 0, %2
  br i1 %8, label %9, label %10

9:                                                ; preds = %7
  br label %11

10:                                               ; preds = %7
  call void asm sideeffect "hcf", ""()
  br label %11

11:                                               ; preds = %9, %10
  call void @probe_reduce()
  br label %42

12:                                               ; preds = %1
  %13 = icmp eq i32 0, %2
  br i1 %13, label %14, label %15

14:                                               ; preds = %12
  br label %16

15:                                               ; preds = %12
  call void asm sideeffect "hcf", ""()
  br label %16

16:                                               ; preds = %14, %15
  call void @spmv_dia()
  br label %42

17:                                               ; preds = %1
  %18 = icmp eq i32 0, %2
  br i1 %18, label %19, label %20

19:                                               ; preds = %17
  br label %21

20:                                               ; preds = %17
  call void asm sideeffect "hcf", ""()
  br label %21

21:                                               ; preds = %19, %20
  call void @spmv_ir()
  br label %42

22:                                               ; preds = %1
  %23 = icmp eq i32 0, %2
  br i1 %23, label %24, label %25

24:                                               ; preds = %22
  br label %26

25:                                               ; preds = %22
  call void asm sideeffect "hcf", ""()
  br label %26

26:                                               ; preds = %24, %25
  call void @spmv_blk_dsdred()
  br label %42

27:                                               ; preds = %1
  %28 = icmp eq i32 0, %2
  br i1 %28, label %29, label %30

29:                                               ; preds = %27
  br label %31

30:                                               ; preds = %27
  call void asm sideeffect "hcf", ""()
  br label %31

31:                                               ; preds = %29, %30
  call void @probe_reduce_const()
  br label %42

32:                                               ; preds = %1
  %33 = icmp eq i32 0, %2
  br i1 %33, label %34, label %35

34:                                               ; preds = %32
  br label %36

35:                                               ; preds = %32
  call void asm sideeffect "hcf", ""()
  br label %36

36:                                               ; preds = %34, %35
  call void @spmv_scalar()
  br label %42

37:                                               ; preds = %1
  %38 = icmp eq i32 0, %2
  br i1 %38, label %39, label %40

39:                                               ; preds = %37
  br label %41

40:                                               ; preds = %37
  call void asm sideeffect "hcf", ""()
  br label %41

41:                                               ; preds = %39, %40
  call void @spmv_blk()
  br label %42

42:                                               ; preds = %6, %11, %16, %21, %26, %31, %36, %41
  ret void
}

define void @sys_mod.sys_mod.f_rpc(i16 %0) #4 !dbg !434 {
  %2 = alloca i16, i16 1, align 2, !dbg !435
  store i16 %0, i16* %2, align 2, !dbg !435
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !437
  %3 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !438
  %4 = icmp sge i16 %3, 4, !dbg !439
  br i1 %4, label %5, label %6, !dbg !440

5:                                                ; preds = %1
  br label %7, !dbg !440

6:                                                ; preds = %1
  call void asm sideeffect "hcf", ""(), !dbg !440
  br label %7, !dbg !440

7:                                                ; preds = %5, %6
  call void @rpc_server(i32* getelementptr inbounds ([32 x i32], [32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32, i32 0, i32 0)), !dbg !441
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !442
  ret void, !dbg !443
}

define internal void @sys_mod.sys_mod.sys_mod.stack_push(i16 %0) !dbg !444 {
  %2 = alloca i16*, i16 1, align 8, !dbg !446
  %3 = alloca i16, i16 1, align 2, !dbg !448
  store i16 %0, i16* %3, align 2, !dbg !448
  %4 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !449
  %5 = icmp slt i16 %4, 32, !dbg !450
  br i1 %5, label %6, label %7, !dbg !451

6:                                                ; preds = %1
  br label %8, !dbg !451

7:                                                ; preds = %1
  call void asm sideeffect "hcf", ""(), !dbg !451
  br label %8, !dbg !451

8:                                                ; preds = %6, %7
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %2, align 8, !dbg !446
  %9 = load i16, i16* %3, align 2, !dbg !452
  %10 = load i16*, i16** %2, align 8, !dbg !453
  %11 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !454
  %12 = getelementptr i16, i16* %10, i16 %11, !dbg !455
  store i16 %9, i16* %12, align 2, !dbg !456
  %13 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !457
  %14 = add i16 %13, 1, !dbg !458
  store i16 %14, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !459
  ret void, !dbg !460
}

define void @sys_mod.sys_mod.sys_mod.f_push(i16 %0, i16 %1) #5 !dbg !461 {
  %3 = alloca i16, i16 1, align 2, !dbg !462
  %4 = alloca i16, i16 1, align 2, !dbg !464
  store i16 %0, i16* %4, align 2, !dbg !464
  store i16 %1, i16* %3, align 2, !dbg !462
  %5 = load i16, i16* %4, align 2, !dbg !465
  call void @sys_mod.sys_mod.sys_mod.stack_push(i16 %5), !dbg !466
  ret void, !dbg !467
}

define internal void @sys_mod.sys_mod.sys_mod.block_cmd_stream() !dbg !468 {
  call void @llvm.sdr.blk.r(i16 1), !dbg !469
  ret void, !dbg !471
}

define internal void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream() !dbg !472 {
  call void @llvm.sdr.ublk.r(i16 1), !dbg !473
  ret void, !dbg !475
}

define void @sys_mod.sys_mod.sys_mod.f_sys_exit() #6 !dbg !476 {
  call void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream(), !dbg !477
  call void @sys_mod.sys_nop(), !dbg !479
  ret void, !dbg !480
}

define void @sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore(i32 %0) #7 !dbg !481 {
  %2 = alloca i32, i16 1, align 4, !dbg !482
  store i32 %0, i32* %2, align 4, !dbg !482
  ret void, !dbg !484
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord() !dbg !485 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord(), !dbg !487
  ret i16 %1, !dbg !489
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord() !dbg !490 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord(), !dbg !491
  ret i16 %1, !dbg !493
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval(i16 %0) !dbg !494 {
  %2 = alloca i16, i16 1, align 2, !dbg !495
  store i16 %0, i16* %2, align 2, !dbg !495
  %3 = load i16, i16* %2, align 2, !dbg !497
  %4 = icmp ult i16 %3, 24, !dbg !498
  br i1 %4, label %5, label %7, !dbg !499

5:                                                ; preds = %10, %11, %1
  %6 = phi i16 [ 0, %10 ], [ 0, %11 ], [ 1, %1 ]
  br label %12, !dbg !499

7:                                                ; preds = %1
  %8 = load i16, i16* %2, align 2, !dbg !500
  %9 = icmp eq i16 31, %8, !dbg !501
  br i1 %9, label %10, label %11, !dbg !502

10:                                               ; preds = %7
  br label %5, !dbg !502

11:                                               ; preds = %7
  call void asm sideeffect "hcf", ""(), !dbg !502
  br label %5, !dbg !502

12:                                               ; preds = %5
  %13 = phi i16 [ %6, %5 ]
  br label %14, !dbg !499

14:                                               ; preds = %12
  ret i16 %13, !dbg !499
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start(i16 %0, i16 %1, i16 %2) !dbg !503 {
  %4 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !504
  %5 = alloca i16, i16 1, align 2, !dbg !506
  %6 = alloca i16, i16 1, align 2, !dbg !507
  %7 = alloca i16, i16 1, align 2, !dbg !508
  store i16 %0, i16* %7, align 2, !dbg !508
  store i16 %1, i16* %6, align 2, !dbg !507
  store i16 %2, i16* %5, align 2, !dbg !506
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !509
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !509
  %10 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !509
  %11 = load i16, i16* %6, align 2, !dbg !510
  store i16 %11, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !511
  store i16 %8, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !511
  store i16 %9, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !511
  store i16 %10, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !511
  %12 = load i16, i16* %7, align 2, !dbg !512
  %13 = call i16* @.get_tensor_ptr(i16 %12), !dbg !513
  %14 = ptrtoint i16* %13 to i16, !dbg !514
  %15 = lshr i16 %14, 1, !dbg !514
  %16 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !504
  store i16 42, i16* %16, align 2, !dbg !504
  %17 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !504
  store i16 %15, i16* %17, align 2, !dbg !504
  %18 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !504
  store i16 143, i16* %18, align 2, !dbg !504
  %19 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !504
  store i16 16, i16* %19, align 2, !dbg !504
  %20 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !515
  %21 = load i16, i16* %20, align 2, !dbg !515
  %22 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !515
  %23 = load i16, i16* %22, align 2, !dbg !515
  %24 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !515
  %25 = load i16, i16* %24, align 2, !dbg !515
  %26 = load i16, i16* %6, align 2, !dbg !516
  %27 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !517
  store i16 %26, i16* %27, align 2, !dbg !517
  %28 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !517
  store i16 %21, i16* %28, align 2, !dbg !517
  %29 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !517
  store i16 %23, i16* %29, align 2, !dbg !517
  %30 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !517
  store i16 %25, i16* %30, align 2, !dbg !517
  %31 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !518
  %32 = load i16, i16* %31, align 2, !dbg !518
  %33 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !518
  %34 = load i16, i16* %33, align 2, !dbg !518
  %35 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !518
  %36 = load i16, i16* %35, align 2, !dbg !518
  %37 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !518
  %38 = load i16, i16* %37, align 2, !dbg !518
  store volatile i16 %32, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !519
  store volatile i16 %34, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !519
  store volatile i16 %36, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !519
  store volatile i16 %38, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !519
  call void asm sideeffect "nop", ""(), !dbg !519
  call void asm sideeffect "nop", ""(), !dbg !519
  %39 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !520
  %40 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !520
  %41 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !520
  %42 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !520
  %43 = and i16 %41, -193, !dbg !520
  %44 = or i16 %43, 128, !dbg !520
  %45 = and i16 %40, -64, !dbg !520
  %46 = or i16 %45, 27, !dbg !520
  store volatile i16 %39, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !521
  store volatile i16 %46, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !521
  store volatile i16 %44, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !521
  store volatile i16 %42, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !521
  call void asm sideeffect "nop", ""(), !dbg !521
  call void asm sideeffect "nop", ""(), !dbg !521
  %47 = load i16, i16* %5, align 2, !dbg !522
  %48 = icmp ult i16 0, %47, !dbg !523
  br i1 %48, label %49, label %50, !dbg !524

49:                                               ; preds = %3
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !525
  br label %51, !dbg !524

50:                                               ; preds = %3
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !526
  br label %51, !dbg !524

51:                                               ; preds = %49, %50
  ret void, !dbg !524
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream() !dbg !527 {
  call void @llvm.sdr.ublk.r(i16 1), !dbg !528
  ret void, !dbg !530
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7, i16 %8, i16 %9, i16 %10, float %11, float %12) !dbg !531 {
  %14 = alloca i16, i16 1, align 2, !dbg !532
  %15 = alloca i16, i16 1, align 2, !dbg !534
  %16 = alloca i16, i16 1, align 2, !dbg !535
  %17 = alloca i16, i16 1, align 2, !dbg !536
  %18 = alloca i16, i16 1, align 2, !dbg !537
  %19 = alloca i1, i16 1, align 1, !dbg !538
  %20 = alloca i16, i16 1, align 2, !dbg !539
  %21 = alloca i16, i16 1, align 2, !dbg !540
  %22 = alloca i16, i16 1, align 2, !dbg !541
  %23 = alloca i16, i16 1, align 2, !dbg !542
  %24 = alloca i16, i16 1, align 2, !dbg !543
  %25 = alloca float, i16 1, align 4, !dbg !544
  %26 = alloca float, i16 1, align 4, !dbg !545
  %27 = alloca i16, i16 1, align 2, !dbg !546
  %28 = alloca i16, i16 1, align 2, !dbg !547
  %29 = alloca i16, i16 1, align 2, !dbg !548
  %30 = alloca i16, i16 1, align 2, !dbg !549
  %31 = alloca i16, i16 1, align 2, !dbg !550
  %32 = alloca i16, i16 1, align 2, !dbg !551
  %33 = alloca i16, i16 1, align 2, !dbg !552
  %34 = alloca i16, i16 1, align 2, !dbg !553
  %35 = alloca i16, i16 1, align 2, !dbg !554
  %36 = alloca i16, i16 1, align 2, !dbg !555
  %37 = alloca i16, i16 1, align 2, !dbg !556
  store i16 %0, i16* %37, align 2, !dbg !556
  store i16 %1, i16* %36, align 2, !dbg !555
  store i16 %2, i16* %35, align 2, !dbg !554
  store i16 %3, i16* %34, align 2, !dbg !553
  store i16 %4, i16* %33, align 2, !dbg !552
  store i16 %5, i16* %32, align 2, !dbg !551
  store i16 %6, i16* %31, align 2, !dbg !550
  store i16 %7, i16* %30, align 2, !dbg !549
  store i16 %8, i16* %29, align 2, !dbg !548
  store i16 %9, i16* %28, align 2, !dbg !547
  store i16 %10, i16* %27, align 2, !dbg !546
  store float %11, float* %26, align 4, !dbg !545
  store float %12, float* %25, align 4, !dbg !544
  %38 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord(), !dbg !557
  store i16 %38, i16* %24, align 2, !dbg !543
  %39 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord(), !dbg !558
  store i16 %39, i16* %23, align 2, !dbg !542
  %40 = load i16, i16* %24, align 2, !dbg !559
  %41 = load i16, i16* %36, align 2, !dbg !560
  %42 = sub i16 %40, %41, !dbg !561
  store i16 %42, i16* %22, align 2, !dbg !541
  %43 = load i16, i16* %22, align 2, !dbg !562
  store i16 %43, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !563
  %44 = load i16, i16* %29, align 2, !dbg !564
  %45 = icmp eq i16 3, %44, !dbg !565
  br i1 %45, label %46, label %63, !dbg !566

46:                                               ; preds = %13
  %47 = load i16, i16* %22, align 2, !dbg !567
  %48 = sitofp i16 %47 to float, !dbg !568
  %49 = load float, float* %26, align 4, !dbg !569
  %50 = fmul float %48, %49, !dbg !570
  %51 = fptosi float %50 to i16, !dbg !571
  store i16 %51, i16* %21, align 2, !dbg !540
  %52 = load i16, i16* %22, align 2, !dbg !572
  %53 = load i16, i16* %21, align 2, !dbg !573
  %54 = load i16, i16* %28, align 2, !dbg !574
  %55 = mul i16 %53, %54, !dbg !575
  %56 = sub i16 %52, %55, !dbg !576
  store i16 %56, i16* %20, align 2, !dbg !539
  %57 = load i16, i16* %20, align 2, !dbg !577
  %58 = icmp ne i16 0, %57, !dbg !578
  br i1 %58, label %59, label %60, !dbg !579

59:                                               ; preds = %46
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !580
  br label %62, !dbg !579

60:                                               ; preds = %46
  %61 = load i16, i16* %21, align 2, !dbg !581
  store i16 %61, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !582
  br label %62, !dbg !579

62:                                               ; preds = %59, %60
  br label %63, !dbg !566

63:                                               ; preds = %62, %13
  %64 = load i16, i16* %22, align 2, !dbg !583
  %65 = icmp slt i16 %64, 0, !dbg !584
  br i1 %65, label %66, label %67, !dbg !585

66:                                               ; preds = %63
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !586
  br label %67, !dbg !585

67:                                               ; preds = %66, %63
  %68 = load i16, i16* %22, align 2, !dbg !587
  %69 = load i16, i16* %34, align 2, !dbg !588
  %70 = icmp sge i16 %68, %69, !dbg !589
  br i1 %70, label %71, label %72, !dbg !590

71:                                               ; preds = %67
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !591
  br label %72, !dbg !590

72:                                               ; preds = %71, %67
  store i1 false, i1* %19, align 1, !dbg !538
  %73 = load i16, i16* %29, align 2, !dbg !592
  %74 = icmp eq i16 3, %73, !dbg !593
  br i1 %74, label %75, label %94, !dbg !594

75:                                               ; preds = %72
  %76 = load i16, i16* %23, align 2, !dbg !595
  %77 = load i16, i16* %35, align 2, !dbg !596
  %78 = sub i16 %76, %77, !dbg !597
  %79 = sitofp i16 %78 to float, !dbg !598
  %80 = load float, float* %25, align 4, !dbg !599
  %81 = fmul float %79, %80, !dbg !600
  %82 = fptosi float %81 to i16, !dbg !601
  store i16 %82, i16* %18, align 2, !dbg !537
  %83 = load i16, i16* %23, align 2, !dbg !602
  %84 = load i16, i16* %35, align 2, !dbg !603
  %85 = sub i16 %83, %84, !dbg !604
  %86 = load i16, i16* %18, align 2, !dbg !605
  %87 = load i16, i16* %27, align 2, !dbg !606
  %88 = mul i16 %86, %87, !dbg !607
  %89 = sub i16 %85, %88, !dbg !608
  store i16 %89, i16* %17, align 2, !dbg !536
  %90 = load i16, i16* %17, align 2, !dbg !609
  %91 = icmp ne i16 0, %90, !dbg !610
  br i1 %91, label %92, label %93, !dbg !611

92:                                               ; preds = %75
  store i1 true, i1* %19, align 1, !dbg !612
  br label %93, !dbg !611

93:                                               ; preds = %92, %75
  br label %94, !dbg !594

94:                                               ; preds = %93, %72
  %95 = load i16, i16* %23, align 2, !dbg !613
  %96 = load i16, i16* %35, align 2, !dbg !614
  %97 = icmp slt i16 %95, %96, !dbg !615
  br i1 %97, label %98, label %99, !dbg !616

98:                                               ; preds = %94
  store i1 true, i1* %19, align 1, !dbg !617
  br label %99, !dbg !616

99:                                               ; preds = %98, %94
  %100 = load i16, i16* %23, align 2, !dbg !618
  %101 = load i16, i16* %35, align 2, !dbg !619
  %102 = load i16, i16* %33, align 2, !dbg !620
  %103 = add i16 %101, %102, !dbg !621
  %104 = icmp sge i16 %100, %103, !dbg !622
  br i1 %104, label %105, label %106, !dbg !623

105:                                              ; preds = %99
  store i1 true, i1* %19, align 1, !dbg !624
  br label %106, !dbg !623

106:                                              ; preds = %105, %99
  %107 = load i1, i1* %19, align 1, !dbg !625
  br i1 %107, label %108, label %109, !dbg !626

108:                                              ; preds = %106
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream(), !dbg !627
  call void @llvm.sdr.ublk.r(i16 27), !dbg !628
  br label %180, !dbg !626

109:                                              ; preds = %106
  %110 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !629
  %111 = icmp eq i16 -1, %110, !dbg !630
  br i1 %111, label %112, label %113, !dbg !631

112:                                              ; preds = %109
  call void @__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction(i16 31767), !dbg !632
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 23), !dbg !633
  call void @llvm.sdr.ublk.r(i16 27), !dbg !634
  br label %179, !dbg !631

113:                                              ; preds = %109
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter(i16 0, i16 0), !dbg !635
  %114 = load i16, i16* %34, align 2, !dbg !636
  store i16 %114, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !637
  %115 = load i16, i16* %29, align 2, !dbg !638
  %116 = icmp eq i16 3, %115, !dbg !639
  br i1 %116, label %117, label %126, !dbg !640

117:                                              ; preds = %113
  %118 = load i16, i16* %34, align 2, !dbg !641
  %119 = sub i16 %118, 1, !dbg !642
  %120 = sitofp i16 %119 to float, !dbg !643
  %121 = load float, float* %26, align 4, !dbg !644
  %122 = fmul float %120, %121, !dbg !645
  %123 = fptosi float %122 to i16, !dbg !646
  %124 = add i16 %123, 1, !dbg !647
  store i16 %124, i16* %16, align 2, !dbg !535
  %125 = load i16, i16* %16, align 2, !dbg !648
  store i16 %125, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !649
  br label %131, !dbg !640

126:                                              ; preds = %113
  %127 = load i16, i16* %29, align 2, !dbg !650
  %128 = icmp eq i16 1, %127, !dbg !651
  br i1 %128, label %129, label %130, !dbg !652

129:                                              ; preds = %126
  store i16 1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !653
  br label %130, !dbg !652

130:                                              ; preds = %129, %126
  br label %131, !dbg !640

131:                                              ; preds = %117, %130
  %132 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !654
  %133 = sub i16 %132, 1, !dbg !655
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit(i16 0, i16 %133), !dbg !656
  %134 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !657
  store i16 %134, i16* %15, align 2, !dbg !534
  %135 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !658
  store i16 %135, i16* %14, align 2, !dbg !532
  %136 = load i16, i16* %15, align 2, !dbg !659
  %137 = load i16, i16* %14, align 2, !dbg !660
  %138 = sub i16 %136, %137, !dbg !661
  store i16 %138, i16* %15, align 2, !dbg !662
  %139 = load i16, i16* %14, align 2, !dbg !663
  %140 = icmp eq i16 0, %139, !dbg !664
  br i1 %140, label %141, label %142, !dbg !665

141:                                              ; preds = %131
  store i16 0, i16* %15, align 2, !dbg !666
  br label %142, !dbg !665

142:                                              ; preds = %141, %131
  %143 = load i16, i16* %29, align 2, !dbg !667
  %144 = icmp eq i16 1, %143, !dbg !668
  br i1 %144, label %145, label %146, !dbg !669

145:                                              ; preds = %142
  store i16 0, i16* %15, align 2, !dbg !670
  br label %146, !dbg !669

146:                                              ; preds = %145, %142
  %147 = load i16, i16* %15, align 2, !dbg !671
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter(i16 0, i16 %147), !dbg !672
  call void @__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction(i16 31767), !dbg !673
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 23), !dbg !674
  %148 = load i16, i16* %37, align 2, !dbg !675
  %149 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval(i16 %148), !dbg !676
  %150 = icmp eq i16 0, %149, !dbg !677
  br i1 %150, label %151, label %155, !dbg !678

151:                                              ; preds = %146
  %152 = load i16, i16* %32, align 2, !dbg !679
  %153 = load i16, i16* %31, align 2, !dbg !680
  %154 = load i16, i16* %30, align 2, !dbg !681
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start(i16 %152, i16 %153, i16 %154), !dbg !682
  br label %178, !dbg !678

155:                                              ; preds = %146
  %156 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !683
  %157 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !683
  %158 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !683
  %159 = load i16, i16* %31, align 2, !dbg !684
  store i16 %159, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !685
  store i16 %156, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !685
  store i16 %157, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !685
  store i16 %158, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !685
  %160 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !686
  %161 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !686
  %162 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !686
  %163 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !686
  %164 = and i16 %162, -193, !dbg !686
  %165 = or i16 %164, 128, !dbg !686
  store volatile i16 %160, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !687
  store volatile i16 %161, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !687
  store volatile i16 %165, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !687
  store volatile i16 %163, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !687
  call void asm sideeffect "nop", ""(), !dbg !687
  call void asm sideeffect "nop", ""(), !dbg !687
  %166 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !688
  %167 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !688
  %168 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !688
  %169 = load i16, i16* %31, align 2, !dbg !689
  store i16 %169, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !690
  store i16 %166, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !690
  store i16 %167, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !690
  store i16 %168, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !690
  %170 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !691
  %171 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !691
  %172 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !691
  %173 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !691
  %174 = and i16 %172, -193, !dbg !691
  %175 = or i16 %174, 128, !dbg !691
  %176 = and i16 %171, -64, !dbg !691
  %177 = or i16 %176, 27, !dbg !691
  store volatile i16 %170, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !692
  store volatile i16 %177, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !692
  store volatile i16 %175, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !692
  store volatile i16 %173, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !692
  call void asm sideeffect "nop", ""(), !dbg !692
  call void asm sideeffect "nop", ""(), !dbg !692
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !693
  br label %178, !dbg !678

178:                                              ; preds = %151, %155
  br label %179, !dbg !631

179:                                              ; preds = %112, %178
  br label %180, !dbg !626

180:                                              ; preds = %108, %179
  ret void, !dbg !566
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit(i16 %0, i16 %1) !dbg !694 {
  %3 = alloca i16, i16 1, align 2, !dbg !696
  %4 = alloca i16, i16 1, align 2, !dbg !698
  %5 = alloca i16, i16 1, align 2, !dbg !699
  %6 = alloca i16, i16 1, align 2, !dbg !700
  %7 = alloca i16, i16 1, align 2, !dbg !701
  %8 = alloca i16, i16 1, align 2, !dbg !702
  store i16 %0, i16* %8, align 2, !dbg !702
  store i16 %1, i16* %7, align 2, !dbg !701
  %9 = load i16, i16* %7, align 2, !dbg !703
  %10 = icmp ult i16 %9, -32768, !dbg !704
  br i1 %10, label %11, label %12, !dbg !705

11:                                               ; preds = %2
  br label %13, !dbg !705

12:                                               ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !705
  br label %13, !dbg !705

13:                                               ; preds = %11, %12
  %14 = load i16, i16* %7, align 2, !dbg !706
  %15 = mul i16 %14, 2, !dbg !707
  store i16 %15, i16* %6, align 2, !dbg !700
  %16 = load i16, i16* %8, align 2, !dbg !708
  %17 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %16, i16 8), !dbg !709
  %18 = sub i16 %17, 1, !dbg !710
  store i16 %18, i16* %5, align 2, !dbg !699
  %19 = load i16, i16* %6, align 2, !dbg !711
  %20 = load i16, i16* %5, align 2, !dbg !712
  %21 = icmp ult i16 %19, %20, !dbg !713
  br i1 %21, label %22, label %23, !dbg !698

22:                                               ; preds = %13
  store i16 0, i16* %4, align 2, !dbg !698
  br label %27, !dbg !698

23:                                               ; preds = %13
  %24 = load i16, i16* %6, align 2, !dbg !714
  %25 = load i16, i16* %5, align 2, !dbg !715
  %26 = sub i16 %24, %25, !dbg !716
  store i16 %26, i16* %4, align 2, !dbg !698
  br label %27, !dbg !698

27:                                               ; preds = %22, %23
  %28 = load i16, i16* %4, align 2, !dbg !698
  store i16 %28, i16* %3, align 2, !dbg !696
  %29 = load i16, i16* %8, align 2, !dbg !717
  %30 = load i16, i16* %3, align 2, !dbg !718
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %29, i16 4, i16 %30), !dbg !719
  ret void, !dbg !698
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter(i16 %0, i16 %1) !dbg !720 {
  %3 = alloca i16, i16 1, align 2, !dbg !721
  %4 = alloca i16, i16 1, align 2, !dbg !723
  store i16 %0, i16* %4, align 2, !dbg !723
  store i16 %1, i16* %3, align 2, !dbg !721
  %5 = load i16, i16* %3, align 2, !dbg !724
  %6 = icmp ult i16 %5, -32768, !dbg !725
  br i1 %6, label %7, label %8, !dbg !726

7:                                                ; preds = %2
  br label %9, !dbg !726

8:                                                ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !726
  br label %9, !dbg !726

9:                                                ; preds = %7, %8
  %10 = load i16, i16* %4, align 2, !dbg !727
  %11 = load i16, i16* %3, align 2, !dbg !728
  %12 = mul i16 %11, 2, !dbg !729
  %13 = add i16 %12, 1, !dbg !730
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %10, i16 8, i16 %13), !dbg !731
  ret void, !dbg !732
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter(i16 %0, i16 %1) !dbg !733 {
  %3 = alloca i16, i16 1, align 2, !dbg !734
  %4 = alloca i16, i16 1, align 2, !dbg !736
  %5 = alloca i1, i16 1, align 1, !dbg !737
  %6 = alloca i16, i16 1, align 2, !dbg !738
  %7 = alloca i16, i16 1, align 2, !dbg !739
  %8 = alloca i16, i16 1, align 2, !dbg !740
  %9 = alloca i16, i16 1, align 2, !dbg !741
  store i16 %0, i16* %9, align 2, !dbg !741
  store i16 %1, i16* %8, align 2, !dbg !740
  %10 = load i16, i16* %8, align 2, !dbg !742
  %11 = icmp ult i16 %10, -32768, !dbg !743
  br i1 %11, label %12, label %13, !dbg !744

12:                                               ; preds = %2
  br label %14, !dbg !744

13:                                               ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !744
  br label %14, !dbg !744

14:                                               ; preds = %12, %13
  %15 = load i16, i16* %9, align 2, !dbg !745
  %16 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %15, i16 8), !dbg !746
  store i16 %16, i16* %7, align 2, !dbg !739
  %17 = load i16, i16* %8, align 2, !dbg !747
  %18 = mul i16 %17, 2, !dbg !748
  store i16 %18, i16* %6, align 2, !dbg !738
  %19 = load i16, i16* %6, align 2, !dbg !749
  %20 = load i16, i16* %7, align 2, !dbg !750
  %21 = icmp ugt i16 %19, %20, !dbg !751
  store i1 %21, i1* %5, align 1, !dbg !737
  %22 = load i16, i16* %9, align 2, !dbg !752
  %23 = load i1, i1* %5, align 1, !dbg !753
  %24 = zext i1 %23 to i16, !dbg !754
  %25 = shl i16 %24, 6, !dbg !755
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %22, i16 14, i16 %25), !dbg !756
  %26 = load i1, i1* %5, align 1, !dbg !757
  br i1 %26, label %27, label %32, !dbg !736

27:                                               ; preds = %14
  %28 = load i16, i16* %6, align 2, !dbg !758
  %29 = load i16, i16* %7, align 2, !dbg !759
  %30 = sub i16 %28, %29, !dbg !760
  %31 = add i16 %30, 1, !dbg !761
  store i16 %31, i16* %4, align 2, !dbg !736
  br label %34, !dbg !736

32:                                               ; preds = %14
  %33 = load i16, i16* %6, align 2, !dbg !762
  store i16 %33, i16* %4, align 2, !dbg !736
  br label %34, !dbg !736

34:                                               ; preds = %27, %32
  %35 = load i16, i16* %4, align 2, !dbg !736
  store i16 %35, i16* %3, align 2, !dbg !734
  %36 = load i16, i16* %9, align 2, !dbg !763
  %37 = load i16, i16* %3, align 2, !dbg !764
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %36, i16 12, i16 %37), !dbg !765
  ret void, !dbg !736
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %0, i16 %1, i16 %2) !dbg !766 {
  %4 = alloca i16, i16 1, align 2, !dbg !768
  %5 = alloca i16, i16 1, align 2, !dbg !770
  %6 = alloca i16, i16 1, align 2, !dbg !771
  store i16 %0, i16* %6, align 2, !dbg !771
  store i16 %1, i16* %5, align 2, !dbg !770
  store i16 %2, i16* %4, align 2, !dbg !768
  %7 = load i16, i16* %6, align 2, !dbg !772
  %8 = getelementptr [6 x i16], [6 x i16]* @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.filters, i16 0, i16 %7, !dbg !773
  %9 = load i16, i16* %8, align 2, !dbg !773
  %10 = load i16, i16* %5, align 2, !dbg !774
  %11 = add i16 %9, %10, !dbg !775
  %12 = lshr i16 %11, 1, !dbg !776
  %13 = load i16, i16* %4, align 2, !dbg !777
  %14 = shl i16 %12, 1, !dbg !778
  %15 = inttoptr i16 %14 to i16*, !dbg !778
  store volatile i16 %13, i16* %15, align 2, !dbg !778
  call void asm sideeffect "nop", ""(), !dbg !778
  call void asm sideeffect "nop", ""(), !dbg !778
  ret void, !dbg !779
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %0, i16 %1) !dbg !780 {
  %3 = alloca i16, i16 1, align 2, !dbg !781
  %4 = alloca i16, i16 1, align 2, !dbg !783
  store i16 %0, i16* %4, align 2, !dbg !783
  store i16 %1, i16* %3, align 2, !dbg !781
  %5 = load i16, i16* %4, align 2, !dbg !784
  %6 = getelementptr [6 x i16], [6 x i16]* @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.filters, i16 0, i16 %5, !dbg !785
  %7 = load i16, i16* %6, align 2, !dbg !785
  %8 = load i16, i16* %3, align 2, !dbg !786
  %9 = add i16 %7, %8, !dbg !787
  %10 = lshr i16 %9, 1, !dbg !788
  %11 = shl i16 %10, 1, !dbg !789
  %12 = inttoptr i16 %11 to i16*, !dbg !789
  call void asm sideeffect "nop", ""(), !dbg !789
  call void asm sideeffect "nop", ""(), !dbg !789
  %13 = load volatile i16, i16* %12, align 2, !dbg !789
  ret i16 %13, !dbg !790
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 %0) !dbg !791 {
  %2 = alloca i16, i16 1, align 2, !dbg !793
  %3 = alloca i16, i16 1, align 2, !dbg !795
  %4 = alloca i16, i16 1, align 2, !dbg !796
  %5 = alloca i16, i16 1, align 2, !dbg !797
  store i16 %0, i16* %5, align 2, !dbg !797
  %6 = load i16, i16* %5, align 2, !dbg !798
  store i16 %6, i16* %4, align 2, !dbg !796
  %7 = load i16, i16* %4, align 2, !dbg !799
  %8 = add i16 %7, 31744, !dbg !800
  store i16 %8, i16* %3, align 2, !dbg !795
  %9 = load i16, i16* %3, align 2, !dbg !801
  %10 = shl i16 %9, 1, !dbg !802
  %11 = inttoptr i16 %10 to i16*, !dbg !802
  call void asm sideeffect "nop", ""(), !dbg !802
  call void asm sideeffect "nop", ""(), !dbg !802
  %12 = load volatile i16, i16* %11, align 2, !dbg !802
  store i16 %12, i16* %2, align 2, !dbg !793
  %13 = load i16, i16* %3, align 2, !dbg !803
  %14 = load i16, i16* %2, align 2, !dbg !804
  %15 = and i16 %14, 32767, !dbg !805
  %16 = shl i16 %13, 1, !dbg !806
  %17 = inttoptr i16 %16 to i16*, !dbg !806
  store volatile i16 %15, i16* %17, align 2, !dbg !806
  call void asm sideeffect "nop", ""(), !dbg !806
  call void asm sideeffect "nop", ""(), !dbg !806
  ret void, !dbg !807
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord() !dbg !808 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 2), !dbg !810
  %2 = sub i16 %1, 4, !dbg !812
  ret i16 %2, !dbg !813
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord() !dbg !814 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 0), !dbg !815
  %2 = sub i16 %1, 1, !dbg !817
  ret i16 %2, !dbg !818
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 %0) !dbg !819 {
  %2 = alloca i16, i16 1, align 2, !dbg !821
  %3 = alloca i16, i16 1, align 2, !dbg !823
  store i16 %0, i16* %3, align 2, !dbg !823
  %4 = load i16, i16* %3, align 2, !dbg !824
  %5 = lshr i16 %4, 1, !dbg !825
  %6 = add i16 %5, 31813, !dbg !826
  %7 = shl i16 %6, 1, !dbg !827
  %8 = inttoptr i16 %7 to i16*, !dbg !827
  call void asm sideeffect "nop", ""(), !dbg !827
  call void asm sideeffect "nop", ""(), !dbg !827
  %9 = load volatile i16, i16* %8, align 2, !dbg !827
  store i16 %9, i16* %2, align 2, !dbg !821
  %10 = load i16, i16* %2, align 2, !dbg !828
  %11 = and i16 %10, 2047, !dbg !829
  ret i16 %11, !dbg !830
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord() !dbg !831 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord(), !dbg !833
  ret i16 %1, !dbg !835
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.get_y_coord() !dbg !836 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord(), !dbg !837
  ret i16 %1, !dbg !839
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval(i16 %0) !dbg !840 {
  %2 = alloca i16, i16 1, align 2, !dbg !841
  store i16 %0, i16* %2, align 2, !dbg !841
  %3 = load i16, i16* %2, align 2, !dbg !843
  %4 = icmp ult i16 %3, 24, !dbg !844
  br i1 %4, label %5, label %7, !dbg !845

5:                                                ; preds = %10, %11, %1
  %6 = phi i16 [ 0, %10 ], [ 0, %11 ], [ 1, %1 ]
  br label %12, !dbg !845

7:                                                ; preds = %1
  %8 = load i16, i16* %2, align 2, !dbg !846
  %9 = icmp eq i16 31, %8, !dbg !847
  br i1 %9, label %10, label %11, !dbg !848

10:                                               ; preds = %7
  br label %5, !dbg !848

11:                                               ; preds = %7
  call void asm sideeffect "hcf", ""(), !dbg !848
  br label %5, !dbg !848

12:                                               ; preds = %5
  %13 = phi i16 [ %6, %5 ]
  br label %14, !dbg !845

14:                                               ; preds = %12
  ret i16 %13, !dbg !845
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7) !dbg !849 {
  %9 = alloca i16, i16 1, align 2, !dbg !850
  %10 = alloca i16, i16 1, align 2, !dbg !852
  %11 = alloca i16, i16 1, align 2, !dbg !853
  %12 = alloca i16, i16 1, align 2, !dbg !854
  %13 = alloca i16, i16 1, align 2, !dbg !855
  %14 = alloca i16, i16 1, align 2, !dbg !856
  %15 = alloca i16, i16 1, align 2, !dbg !857
  %16 = alloca i16, i16 1, align 2, !dbg !858
  %17 = alloca i16, i16 1, align 2, !dbg !859
  store i16 %0, i16* %17, align 2, !dbg !859
  store i16 %1, i16* %16, align 2, !dbg !858
  store i16 %2, i16* %15, align 2, !dbg !857
  store i16 %3, i16* %14, align 2, !dbg !856
  store i16 %4, i16* %13, align 2, !dbg !855
  store i16 %5, i16* %12, align 2, !dbg !854
  store i16 %6, i16* %11, align 2, !dbg !853
  store i16 %7, i16* %10, align 2, !dbg !852
  %18 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !860
  store i16 %18, i16* %9, align 2, !dbg !850
  %19 = load i16, i16* %11, align 2, !dbg !861
  store i16 %19, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_c, align 2, !dbg !862
  %20 = load i16, i16* %10, align 2, !dbg !863
  store i16 %20, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_is_half, align 2, !dbg !864
  %21 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_c, align 2, !dbg !865
  %22 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval(i16 %21), !dbg !866
  store i16 %22, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !867
  store i16 0, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !868
  %23 = load i16, i16* %16, align 2, !dbg !869
  store i16 %23, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !870
  %24 = load i16, i16* %15, align 2, !dbg !871
  store i16 %24, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !872
  %25 = load i16, i16* %15, align 2, !dbg !873
  %26 = load i16, i16* %13, align 2, !dbg !874
  %27 = add i16 %25, %26, !dbg !875
  %28 = sub i16 %27, 1, !dbg !876
  store i16 %28, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_last, align 2, !dbg !877
  %29 = load i16, i16* %9, align 2, !dbg !878
  %30 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_last, align 2, !dbg !879
  %31 = icmp eq i16 %29, %30, !dbg !880
  br i1 %31, label %32, label %37, !dbg !881

32:                                               ; preds = %8
  %33 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !882
  %34 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !882
  %35 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !882
  store i16 %33, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !883
  store i16 lshr (i16 ptrtoint ([1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.ctrl_1 to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !883
  store i16 %34, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !883
  store i16 %35, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !883
  %36 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.ctrl_1, i16 0, i1 false), align 4, !dbg !884
  store i32 %36, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$9$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i1 false), align 4, !dbg !885
  br label %42, !dbg !881

37:                                               ; preds = %8
  %38 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !886
  %39 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !886
  %40 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !886
  store i16 %38, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !887
  store i16 lshr (i16 ptrtoint ([1 x i32]* @"$$csl_base_address$$5$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11" to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !887
  store i16 %39, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !887
  store i16 %40, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !887
  %41 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @"$$csl_base_address$$5$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11", i16 0, i1 false), align 4, !dbg !888
  store i32 %41, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$9$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i1 false), align 4, !dbg !889
  br label %42, !dbg !881

42:                                               ; preds = %32, %37
  store i32 165646921, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$9$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i2 1), align 4, !dbg !890
  %43 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !891
  %44 = icmp eq i16 0, %43, !dbg !892
  br i1 %44, label %45, label %56, !dbg !893

45:                                               ; preds = %42
  %46 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !894
  %47 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !894
  %48 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !894
  %49 = load i16, i16* %17, align 2, !dbg !895
  %50 = call i16* @.get_tensor_ptr(i16 %49), !dbg !896
  %51 = ptrtoint i16* %50 to i16, !dbg !897
  %52 = lshr i16 %51, 1, !dbg !897
  store i16 %46, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !898
  store i16 %52, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !898
  store i16 %47, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !898
  store i16 %48, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !898
  %53 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !899
  %54 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !899
  %55 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !899
  store i16 1, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !900
  store i16 %53, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !900
  store i16 %54, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !900
  store i16 %55, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !900
  call void @llvm.sdr.actvt.r(i16 21), !dbg !901
  br label %63, !dbg !893

56:                                               ; preds = %42
  %57 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !902
  %58 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !902
  %59 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !902
  store i16 %57, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !903
  store i16 lshr (i16 ptrtoint ([1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.data_buf to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !903
  store i16 %58, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !903
  store i16 %59, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !903
  %60 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !904
  %61 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !904
  %62 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !904
  store i16 1, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !905
  store i16 %60, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !905
  store i16 %61, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !905
  store i16 %62, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !905
  call void @llvm.sdr.ublk.r(i16 0), !dbg !906
  br label %63, !dbg !893

63:                                               ; preds = %45, %56
  ret void, !dbg !881
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x(i32 %0) #8 !dbg !907 {
  %2 = alloca i32, i16 1, align 4, !dbg !908
  store i32 %0, i32* %2, align 4, !dbg !908
  call void @llvm.sdr.blk.r(i16 0), !dbg !910
  %3 = load i32, i32* %2, align 4, !dbg !911
  store i32 %3, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.data_buf, i16 0, i1 false), align 4, !dbg !912
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !913
  %4 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !914
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !914
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !914
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !914
  store volatile i16 %4, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !915
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !915
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !915
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !915
  call void asm sideeffect "nop", ""(), !dbg !915
  call void asm sideeffect "nop", ""(), !dbg !915
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !916
  %8 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !917
  %9 = add i16 %8, 1, !dbg !918
  store i16 %9, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !919
  ret void, !dbg !920
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_send_data() #9 !dbg !921 {
  %1 = alloca i16, i16 1, align 2, !dbg !922
  %2 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !924
  %3 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !925
  %4 = icmp ult i16 %2, %3, !dbg !926
  br i1 %4, label %5, label %27, !dbg !927

5:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !928
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !929
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !929
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !929
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !929
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !930
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !930
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !930
  store volatile i16 %9, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !930
  call void asm sideeffect "nop", ""(), !dbg !930
  call void asm sideeffect "nop", ""(), !dbg !930
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_is_half, align 2, !dbg !931
  %11 = icmp ult i16 0, %10, !dbg !932
  br i1 %11, label %12, label %18, !dbg !933

12:                                               ; preds = %5
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !934
  %13 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !935
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !935
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !935
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !935
  %17 = add i16 %14, 1, !dbg !936
  store i16 %13, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !937
  store i16 %17, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !937
  store i16 %15, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !937
  store i16 %16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !937
  br label %24, !dbg !933

18:                                               ; preds = %5
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !938
  %19 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !939
  %20 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !939
  %21 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !939
  %22 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !939
  %23 = add i16 %20, 2, !dbg !940
  store i16 %19, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !941
  store i16 %23, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !941
  store i16 %21, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !941
  store i16 %22, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !941
  br label %24, !dbg !933

24:                                               ; preds = %12, %18
  %25 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !942
  %26 = add i16 %25, 1, !dbg !943
  store i16 %26, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !944
  br label %34, !dbg !927

27:                                               ; preds = %0
  %28 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !945
  store i16 %28, i16* %1, align 2, !dbg !922
  %29 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !946
  %30 = load i16, i16* %1, align 2, !dbg !947
  %31 = icmp eq i16 %29, %30, !dbg !948
  br i1 %31, label %32, label %33, !dbg !949

32:                                               ; preds = %27
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__1 to i8*)), !dbg !950
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__2 to i8*)), !dbg !951
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !952
  br label %33, !dbg !949

33:                                               ; preds = %32, %27
  br label %34, !dbg !927

34:                                               ; preds = %24, %33
  ret void, !dbg !927
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl() #10 !dbg !953 {
  %1 = alloca i16, i16 1, align 2, !dbg !954
  %2 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !956
  %3 = icmp eq i16 0, %2, !dbg !957
  br i1 %3, label %4, label %9, !dbg !958

4:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__3 to i8*)), !dbg !959
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !960
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !960
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !960
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !960
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !961
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !961
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !961
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !961
  call void asm sideeffect "nop", ""(), !dbg !961
  call void asm sideeffect "nop", ""(), !dbg !961
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !962
  br label %31, !dbg !958

9:                                                ; preds = %0
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !963
  %11 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !964
  %12 = icmp ult i16 %10, %11, !dbg !965
  br i1 %12, label %13, label %18, !dbg !966

13:                                               ; preds = %9
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__4 to i8*)), !dbg !967
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !968
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !968
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !968
  %17 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !968
  store volatile i16 %14, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !969
  store volatile i16 %15, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !969
  store volatile i16 %16, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !969
  store volatile i16 %17, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !969
  call void asm sideeffect "nop", ""(), !dbg !969
  call void asm sideeffect "nop", ""(), !dbg !969
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !970
  br label %30, !dbg !966

18:                                               ; preds = %9
  %19 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !971
  store i16 %19, i16* %1, align 2, !dbg !954
  %20 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !972
  %21 = load i16, i16* %1, align 2, !dbg !973
  %22 = icmp eq i16 %20, %21, !dbg !974
  br i1 %22, label %23, label %24, !dbg !975

23:                                               ; preds = %18
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__5 to i8*)), !dbg !976
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__6 to i8*)), !dbg !977
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !978
  br label %29, !dbg !975

24:                                               ; preds = %18
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__1 to i8*)), !dbg !979
  %25 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !980
  %26 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !980
  %27 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !980
  %28 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !980
  store volatile i16 %25, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !981
  store volatile i16 %26, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !981
  store volatile i16 %27, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !981
  store volatile i16 %28, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !981
  call void asm sideeffect "nop", ""(), !dbg !981
  call void asm sideeffect "nop", ""(), !dbg !981
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !982
  br label %29, !dbg !975

29:                                               ; preds = %23, %24
  br label %30, !dbg !966

30:                                               ; preds = %13, %29
  br label %31, !dbg !958

31:                                               ; preds = %4, %30
  ret void, !dbg !958
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.d2h_configure(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7) !dbg !983 {
  %9 = alloca i1, i16 1, align 1, !dbg !984
  %10 = alloca i1, i16 1, align 1, !dbg !986
  %11 = alloca i1, i16 1, align 1, !dbg !987
  %12 = alloca i16, i16 1, align 2, !dbg !988
  %13 = alloca i16, i16 1, align 2, !dbg !989
  %14 = alloca i16, i16 1, align 2, !dbg !990
  %15 = alloca i16, i16 1, align 2, !dbg !991
  %16 = alloca i16, i16 1, align 2, !dbg !992
  %17 = alloca i16, i16 1, align 2, !dbg !993
  %18 = alloca i16, i16 1, align 2, !dbg !994
  %19 = alloca i16, i16 1, align 2, !dbg !995
  %20 = alloca i16, i16 1, align 2, !dbg !996
  %21 = alloca i16, i16 1, align 2, !dbg !997
  %22 = alloca i16, i16 1, align 2, !dbg !998
  %23 = alloca i16, i16 1, align 2, !dbg !999
  %24 = alloca i16, i16 1, align 2, !dbg !1000
  %25 = alloca i16, i16 1, align 2, !dbg !1001
  store i16 %0, i16* %25, align 2, !dbg !1001
  store i16 %1, i16* %24, align 2, !dbg !1000
  store i16 %2, i16* %23, align 2, !dbg !999
  store i16 %3, i16* %22, align 2, !dbg !998
  store i16 %4, i16* %21, align 2, !dbg !997
  store i16 %5, i16* %20, align 2, !dbg !996
  store i16 %6, i16* %19, align 2, !dbg !995
  store i16 %7, i16* %18, align 2, !dbg !994
  %26 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !1002
  store i16 %26, i16* %17, align 2, !dbg !993
  %27 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_y_coord(), !dbg !1003
  store i16 %27, i16* %16, align 2, !dbg !992
  %28 = load i16, i16* %24, align 2, !dbg !1004
  store i16 %28, i16* %15, align 2, !dbg !991
  %29 = load i16, i16* %24, align 2, !dbg !1005
  %30 = load i16, i16* %22, align 2, !dbg !1006
  %31 = add i16 %29, %30, !dbg !1007
  %32 = sub i16 %31, 1, !dbg !1008
  store i16 %32, i16* %14, align 2, !dbg !990
  %33 = load i16, i16* %23, align 2, !dbg !1009
  store i16 %33, i16* %13, align 2, !dbg !989
  %34 = load i16, i16* %23, align 2, !dbg !1010
  %35 = load i16, i16* %21, align 2, !dbg !1011
  %36 = add i16 %34, %35, !dbg !1012
  %37 = sub i16 %36, 1, !dbg !1013
  store i16 %37, i16* %12, align 2, !dbg !988
  store i1 false, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !1014
  %38 = load i16, i16* %17, align 2, !dbg !1015
  %39 = load i16, i16* %15, align 2, !dbg !1016
  %40 = icmp sge i16 %38, %39, !dbg !1017
  br i1 %40, label %41, label %45, !dbg !987

41:                                               ; preds = %8
  %42 = load i16, i16* %16, align 2, !dbg !1018
  %43 = load i16, i16* %12, align 2, !dbg !1019
  %44 = icmp sle i16 %42, %43, !dbg !1020
  store i1 %44, i1* %11, align 1, !dbg !987
  br label %46, !dbg !987

45:                                               ; preds = %8
  store i1 false, i1* %11, align 1, !dbg !987
  br label %46, !dbg !987

46:                                               ; preds = %41, %45
  %47 = load i1, i1* %11, align 1, !dbg !987
  br i1 %47, label %48, label %52, !dbg !986

48:                                               ; preds = %46
  %49 = load i16, i16* %16, align 2, !dbg !1021
  %50 = load i16, i16* %13, align 2, !dbg !1022
  %51 = icmp sge i16 %49, %50, !dbg !1023
  store i1 %51, i1* %10, align 1, !dbg !986
  br label %53, !dbg !986

52:                                               ; preds = %46
  store i1 false, i1* %10, align 1, !dbg !986
  br label %53, !dbg !986

53:                                               ; preds = %48, %52
  %54 = load i1, i1* %10, align 1, !dbg !986
  br i1 %54, label %55, label %56, !dbg !1024

55:                                               ; preds = %53
  store i1 true, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !1025
  br label %56, !dbg !1024

56:                                               ; preds = %55, %53
  store i1 false, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !1026
  %57 = load i16, i16* %17, align 2, !dbg !1027
  %58 = load i16, i16* %14, align 2, !dbg !1028
  %59 = icmp sle i16 %57, %58, !dbg !1029
  br i1 %59, label %60, label %62, !dbg !984

60:                                               ; preds = %56
  %61 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !1030
  store i1 %61, i1* %9, align 1, !dbg !984
  br label %63, !dbg !984

62:                                               ; preds = %56
  store i1 false, i1* %9, align 1, !dbg !984
  br label %63, !dbg !984

63:                                               ; preds = %60, %62
  %64 = load i1, i1* %9, align 1, !dbg !984
  br i1 %64, label %65, label %66, !dbg !1031

65:                                               ; preds = %63
  store i1 true, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !1032
  br label %66, !dbg !1031

66:                                               ; preds = %65, %63
  %67 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !1033
  br i1 %67, label %68, label %86, !dbg !1034

68:                                               ; preds = %66
  call void @__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position(i16 31959), !dbg !1035
  %69 = load i16, i16* %15, align 2, !dbg !1036
  %70 = load i16, i16* %17, align 2, !dbg !1037
  %71 = icmp eq i16 %69, %70, !dbg !1038
  br i1 %71, label %72, label %73, !dbg !1039

72:                                               ; preds = %68
  call void @__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 31765), !dbg !1040
  br label %74, !dbg !1039

73:                                               ; preds = %68
  call void @__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 31765), !dbg !1041
  br label %74, !dbg !1039

74:                                               ; preds = %72, %73
  call void @sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit(i16 21), !dbg !1042
  %75 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !1043
  br i1 %75, label %76, label %85, !dbg !1044

76:                                               ; preds = %74
  %77 = load i16, i16* %20, align 2, !dbg !1045
  %78 = load i16, i16* %19, align 2, !dbg !1046
  %79 = load i16, i16* %24, align 2, !dbg !1047
  %80 = load i16, i16* %23, align 2, !dbg !1048
  %81 = load i16, i16* %22, align 2, !dbg !1049
  %82 = load i16, i16* %21, align 2, !dbg !1050
  %83 = load i16, i16* %25, align 2, !dbg !1051
  %84 = load i16, i16* %18, align 2, !dbg !1052
  call void @sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start(i16 %77, i16 %78, i16 %79, i16 %80, i16 %81, i16 %82, i16 %83, i16 %84), !dbg !1053
  br label %85, !dbg !1044

85:                                               ; preds = %76, %74
  br label %87, !dbg !1034

86:                                               ; preds = %66
  call void @llvm.sdr.actvt.r(i16 28), !dbg !1054
  br label %87, !dbg !1034

87:                                               ; preds = %85, %86
  ret void, !dbg !987
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit(i16 %0) !dbg !1055 {
  %2 = alloca i16, i16 1, align 2, !dbg !1056
  %3 = alloca i16, i16 1, align 2, !dbg !1058
  %4 = alloca i16, i16 1, align 2, !dbg !1059
  %5 = alloca i16, i16 1, align 2, !dbg !1060
  store i16 %0, i16* %5, align 2, !dbg !1060
  %6 = load i16, i16* %5, align 2, !dbg !1061
  store i16 %6, i16* %4, align 2, !dbg !1059
  %7 = load i16, i16* %4, align 2, !dbg !1062
  %8 = add i16 %7, 31744, !dbg !1063
  store i16 %8, i16* %3, align 2, !dbg !1058
  %9 = load i16, i16* %3, align 2, !dbg !1064
  %10 = shl i16 %9, 1, !dbg !1065
  %11 = inttoptr i16 %10 to i16*, !dbg !1065
  call void asm sideeffect "nop", ""(), !dbg !1065
  call void asm sideeffect "nop", ""(), !dbg !1065
  %12 = load volatile i16, i16* %11, align 2, !dbg !1065
  store i16 %12, i16* %2, align 2, !dbg !1056
  %13 = load i16, i16* %3, align 2, !dbg !1066
  %14 = load i16, i16* %2, align 2, !dbg !1067
  %15 = and i16 %14, 32767, !dbg !1068
  %16 = shl i16 %13, 1, !dbg !1069
  %17 = inttoptr i16 %16 to i16*, !dbg !1069
  store volatile i16 %15, i16* %17, align 2, !dbg !1069
  call void asm sideeffect "nop", ""(), !dbg !1069
  call void asm sideeffect "nop", ""(), !dbg !1069
  ret void, !dbg !1070
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord() !dbg !1071 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 2), !dbg !1072
  %2 = sub i16 %1, 4, !dbg !1074
  ret i16 %2, !dbg !1075
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord() !dbg !1076 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 0), !dbg !1077
  %2 = sub i16 %1, 1, !dbg !1079
  ret i16 %2, !dbg !1080
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 %0) !dbg !1081 {
  %2 = alloca i16, i16 1, align 2, !dbg !1082
  %3 = alloca i16, i16 1, align 2, !dbg !1084
  store i16 %0, i16* %3, align 2, !dbg !1084
  %4 = load i16, i16* %3, align 2, !dbg !1085
  %5 = lshr i16 %4, 1, !dbg !1086
  %6 = add i16 %5, 31813, !dbg !1087
  %7 = shl i16 %6, 1, !dbg !1088
  %8 = inttoptr i16 %7 to i16*, !dbg !1088
  call void asm sideeffect "nop", ""(), !dbg !1088
  call void asm sideeffect "nop", ""(), !dbg !1088
  %9 = load volatile i16, i16* %8, align 2, !dbg !1088
  store i16 %9, i16* %2, align 2, !dbg !1082
  %10 = load i16, i16* %2, align 2, !dbg !1089
  %11 = and i16 %10, 2047, !dbg !1090
  ret i16 %11, !dbg !1091
}

define internal i16 @sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr(i16 %0) !dbg !1092 {
  %2 = alloca i16, i16 1, align 2, !dbg !1094
  store i16 %0, i16* %2, align 2, !dbg !1094
  %3 = load i16, i16* %2, align 2, !dbg !1096
  %4 = mul i16 %3, 2, !dbg !1097
  %5 = add i16 %4, 31680, !dbg !1098
  ret i16 %5, !dbg !1099
}

define internal void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 %0, i16 %1, i1 %2) !dbg !1100 {
  %4 = alloca i16, i16 1, align 2, !dbg !1101
  %5 = alloca i16, i16 1, align 2, !dbg !1103
  %6 = alloca i1, i16 1, align 1, !dbg !1104
  %7 = alloca i16, i16 1, align 2, !dbg !1105
  %8 = alloca i16, i16 1, align 2, !dbg !1106
  store i16 %0, i16* %8, align 2, !dbg !1106
  store i16 %1, i16* %7, align 2, !dbg !1105
  store i1 %2, i1* %6, align 1, !dbg !1104
  %9 = load i16, i16* %8, align 2, !dbg !1107
  %10 = call i16 @sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr(i16 %9), !dbg !1108
  store i16 %10, i16* %5, align 2, !dbg !1103
  %11 = load i16, i16* %5, align 2, !dbg !1109
  %12 = shl i16 %11, 1, !dbg !1110
  %13 = inttoptr i16 %12 to i16*, !dbg !1110
  call void asm sideeffect "nop", ""(), !dbg !1110
  call void asm sideeffect "nop", ""(), !dbg !1110
  call void asm sideeffect "nop", ""(), !dbg !1110
  call void asm sideeffect "nop", ""(), !dbg !1110
  %14 = load volatile i16, i16* %13, align 2, !dbg !1110
  store i16 %14, i16* %4, align 2, !dbg !1101
  %15 = load i1, i1* %6, align 1, !dbg !1111
  br i1 %15, label %16, label %19, !dbg !1112

16:                                               ; preds = %3
  %17 = load i16, i16* %4, align 2, !dbg !1113
  %18 = or i16 %17, 2048, !dbg !1114
  store i16 %18, i16* %4, align 2, !dbg !1115
  br label %22, !dbg !1112

19:                                               ; preds = %3
  %20 = load i16, i16* %4, align 2, !dbg !1116
  %21 = and i16 %20, -2049, !dbg !1117
  store i16 %21, i16* %4, align 2, !dbg !1118
  br label %22, !dbg !1112

22:                                               ; preds = %16, %19
  %23 = load i16, i16* %4, align 2, !dbg !1119
  %24 = and i16 %23, -32, !dbg !1120
  store i16 %24, i16* %4, align 2, !dbg !1121
  %25 = load i16, i16* %4, align 2, !dbg !1122
  %26 = load i16, i16* %7, align 2, !dbg !1123
  %27 = add i16 %25, %26, !dbg !1124
  store i16 %27, i16* %4, align 2, !dbg !1125
  %28 = load i16, i16* %5, align 2, !dbg !1126
  %29 = load i16, i16* %4, align 2, !dbg !1127
  %30 = shl i16 %28, 1, !dbg !1128
  %31 = inttoptr i16 %30 to i16*, !dbg !1128
  store volatile i16 %29, i16* %31, align 2, !dbg !1128
  call void asm sideeffect "nop", ""(), !dbg !1128
  call void asm sideeffect "nop", ""(), !dbg !1128
  call void asm sideeffect "nop", ""(), !dbg !1128
  call void asm sideeffect "nop", ""(), !dbg !1128
  ret void, !dbg !1112
}

define internal i16 @sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr(i16 %0) !dbg !1129 {
  %2 = alloca i16, i16 1, align 2, !dbg !1131
  store i16 %0, i16* %2, align 2, !dbg !1131
  %3 = load i16, i16* %2, align 2, !dbg !1133
  %4 = add i16 %3, 31616, !dbg !1134
  ret i16 %4, !dbg !1135
}

define internal void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 %0, i16 %1) !dbg !1136 {
  %3 = alloca i16, i16 1, align 2, !dbg !1137
  %4 = alloca i16, i16 1, align 2, !dbg !1139
  %5 = alloca i16, i16 1, align 2, !dbg !1140
  %6 = alloca i16, i16 1, align 2, !dbg !1141
  store i16 %0, i16* %6, align 2, !dbg !1141
  store i16 %1, i16* %5, align 2, !dbg !1140
  %7 = load i16, i16* %6, align 2, !dbg !1142
  %8 = call i16 @sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr(i16 %7), !dbg !1143
  store i16 %8, i16* %4, align 2, !dbg !1139
  %9 = load i16, i16* %4, align 2, !dbg !1144
  %10 = shl i16 %9, 1, !dbg !1145
  %11 = inttoptr i16 %10 to i16*, !dbg !1145
  call void asm sideeffect "nop", ""(), !dbg !1145
  call void asm sideeffect "nop", ""(), !dbg !1145
  call void asm sideeffect "nop", ""(), !dbg !1145
  call void asm sideeffect "nop", ""(), !dbg !1145
  %12 = load volatile i16, i16* %11, align 2, !dbg !1145
  store i16 %12, i16* %3, align 2, !dbg !1137
  %13 = load i16, i16* %3, align 2, !dbg !1146
  %14 = and i16 %13, -497, !dbg !1147
  store i16 %14, i16* %3, align 2, !dbg !1148
  %15 = load i16, i16* %3, align 2, !dbg !1149
  %16 = load i16, i16* %5, align 2, !dbg !1150
  %17 = add i16 %15, %16, !dbg !1151
  %18 = shl i16 %17, 4, !dbg !1152
  store i16 %18, i16* %3, align 2, !dbg !1153
  %19 = load i16, i16* %4, align 2, !dbg !1154
  %20 = load i16, i16* %3, align 2, !dbg !1155
  %21 = shl i16 %19, 1, !dbg !1156
  %22 = inttoptr i16 %21 to i16*, !dbg !1156
  store volatile i16 %20, i16* %22, align 2, !dbg !1156
  call void asm sideeffect "nop", ""(), !dbg !1156
  call void asm sideeffect "nop", ""(), !dbg !1156
  call void asm sideeffect "nop", ""(), !dbg !1156
  call void asm sideeffect "nop", ""(), !dbg !1156
  ret void, !dbg !1157
}

define internal i16* @.get_tensor_ptr(i16 %0) !dbg !1158 {
  %2 = alloca i16, i16 1, align 2, !dbg !1159
  store i16 %0, i16* %2, align 2, !dbg !1159
  %3 = load i16, i16* %2, align 2, !dbg !1159
  %4 = zext i16 %3 to i32, !dbg !1159
  switch i32 %4, label %5 [
    i32 1, label %9
    i32 2, label %11
    i32 3, label %13
    i32 4, label %15
    i32 5, label %17
    i32 6, label %20
    i32 7, label %23
    i32 8, label %26
    i32 9, label %28
    i32 10, label %30
    i32 11, label %32
    i32 12, label %34
    i32 13, label %37
    i32 14, label %40
    i32 15, label %43
    i32 16, label %46
    i32 17, label %49
    i32 26, label %52
    i32 18, label %55
  ], !dbg !1159

5:                                                ; preds = %1
  br i1 false, label %6, label %7, !dbg !1159

6:                                                ; preds = %5
  br label %8, !dbg !1159

7:                                                ; preds = %5
  call void asm sideeffect "hcf", ""(), !dbg !1159
  br label %8, !dbg !1159

8:                                                ; preds = %6, %7
  br label %57, !dbg !1159

9:                                                ; preds = %1
  %10 = load i16*, i16** @p_row_ptr, align 8, !dbg !1159
  br label %57, !dbg !1159

11:                                               ; preds = %1
  %12 = load i16*, i16** @p_col_idx, align 8, !dbg !1159
  br label %57, !dbg !1159

13:                                               ; preds = %1
  %14 = load i16*, i16** @p_col_start, align 8, !dbg !1159
  br label %57, !dbg !1159

15:                                               ; preds = %1
  %16 = load i16*, i16** @p_run_len, align 8, !dbg !1159
  br label %57, !dbg !1159

17:                                               ; preds = %1
  %18 = load float*, float** @p_val, align 8, !dbg !1159
  %19 = bitcast float* %18 to i16*, !dbg !1159
  br label %57, !dbg !1159

20:                                               ; preds = %1
  %21 = load float*, float** @p_x, align 8, !dbg !1159
  %22 = bitcast float* %21 to i16*, !dbg !1159
  br label %57, !dbg !1159

23:                                               ; preds = %1
  %24 = load float*, float** @p_dia_val, align 8, !dbg !1159
  %25 = bitcast float* %24 to i16*, !dbg !1159
  br label %57, !dbg !1159

26:                                               ; preds = %1
  %27 = load i16*, i16** @p_dia_off, align 8, !dbg !1159
  br label %57, !dbg !1159

28:                                               ; preds = %1
  %29 = load i16*, i16** @p_dia_len, align 8, !dbg !1159
  br label %57, !dbg !1159

30:                                               ; preds = %1
  %31 = load i16*, i16** @p_dia_row0, align 8, !dbg !1159
  br label %57, !dbg !1159

32:                                               ; preds = %1
  %33 = load i16*, i16** @p_dia_xoff, align 8, !dbg !1159
  br label %57, !dbg !1159

34:                                               ; preds = %1
  %35 = load float*, float** @p_probe_seed, align 8, !dbg !1159
  %36 = bitcast float* %35 to i16*, !dbg !1159
  br label %57, !dbg !1159

37:                                               ; preds = %1
  %38 = load float*, float** @p_probe_out, align 8, !dbg !1159
  %39 = bitcast float* %38 to i16*, !dbg !1159
  br label %57, !dbg !1159

40:                                               ; preds = %1
  %41 = load float*, float** @p_y_sc, align 8, !dbg !1159
  %42 = bitcast float* %41 to i16*, !dbg !1159
  br label %57, !dbg !1159

43:                                               ; preds = %1
  %44 = load float*, float** @p_y_ir, align 8, !dbg !1159
  %45 = bitcast float* %44 to i16*, !dbg !1159
  br label %57, !dbg !1159

46:                                               ; preds = %1
  %47 = load float*, float** @p_y_bk, align 8, !dbg !1159
  %48 = bitcast float* %47 to i16*, !dbg !1159
  br label %57, !dbg !1159

49:                                               ; preds = %1
  %50 = load float*, float** @p_y_di, align 8, !dbg !1159
  %51 = bitcast float* %50 to i16*, !dbg !1159
  br label %57, !dbg !1159

52:                                               ; preds = %1
  %53 = load float*, float** @p_y_bd, align 8, !dbg !1159
  %54 = bitcast float* %53 to i16*, !dbg !1159
  br label %57, !dbg !1159

55:                                               ; preds = %1
  %56 = load i16*, i16** @p_mark, align 8, !dbg !1159
  br label %57, !dbg !1159

57:                                               ; preds = %8, %9, %11, %13, %15, %17, %20, %23, %26, %28, %30, %32, %34, %37, %40, %43, %46, %49, %52, %55
  %58 = phi i16 [ -2, %55 ], [ -2, %52 ], [ -2, %49 ], [ -2, %46 ], [ -2, %43 ], [ -2, %40 ], [ -2, %37 ], [ -2, %34 ], [ -2, %32 ], [ -2, %30 ], [ -2, %28 ], [ -2, %26 ], [ -2, %23 ], [ -2, %20 ], [ -2, %17 ], [ -2, %15 ], [ -2, %13 ], [ -2, %11 ], [ -2, %9 ], [ 0, %8 ]
  %59 = phi i16* [ %56, %55 ], [ %54, %52 ], [ %51, %49 ], [ %48, %46 ], [ %45, %43 ], [ %42, %40 ], [ %39, %37 ], [ %36, %34 ], [ %33, %32 ], [ %31, %30 ], [ %29, %28 ], [ %27, %26 ], [ %25, %23 ], [ %22, %20 ], [ %19, %17 ], [ %16, %15 ], [ %14, %13 ], [ %12, %11 ], [ %10, %9 ], [ undef, %8 ]
  br label %60, !dbg !1159

60:                                               ; preds = %57
  %61 = icmp ne i16 %58, 0, !dbg !1159
  br i1 %61, label %62, label %63, !dbg !1159

62:                                               ; preds = %60
  br label %65, !dbg !1159

63:                                               ; preds = %60
  %64 = load i16*, i16** @p_mark, align 8, !dbg !1159
  br label %65, !dbg !1159

65:                                               ; preds = %62, %63
  %66 = phi i16* [ %64, %63 ], [ %59, %62 ]
  br label %67, !dbg !1159

67:                                               ; preds = %65
  ret i16* %66, !dbg !1159
}

define internal void @__generic0sys_mod.sys_mod.tile_config.queue_flush.exit() !dbg !1161 {
  store volatile i16 1, i16* inttoptr (i16 -2268 to i16*), align 2, !dbg !1163
  call void asm sideeffect "nop", ""(), !dbg !1163
  call void asm sideeffect "nop", ""(), !dbg !1163
  ret void, !dbg !1165
}

define internal void @__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position(i16 %0) !dbg !1166 {
  %2 = alloca i16, i16 1, align 2, !dbg !1168
  %3 = alloca i16, i16 1, align 2, !dbg !1170
  %4 = alloca i16, i16 1, align 2, !dbg !1171
  store i16 %0, i16* %4, align 2, !dbg !1171
  %5 = load i16, i16* %4, align 2, !dbg !1172
  store i16 %5, i16* %3, align 2, !dbg !1170
  %6 = load i16, i16* %3, align 2, !dbg !1173
  %7 = shl i16 %6, 1, !dbg !1174
  %8 = inttoptr i16 %7 to i16*, !dbg !1174
  call void asm sideeffect "nop", ""(), !dbg !1174
  call void asm sideeffect "nop", ""(), !dbg !1174
  call void asm sideeffect "nop", ""(), !dbg !1174
  call void asm sideeffect "nop", ""(), !dbg !1174
  %9 = load volatile i16, i16* %8, align 2, !dbg !1174
  store i16 %9, i16* %2, align 2, !dbg !1168
  %10 = load i16, i16* %2, align 2, !dbg !1175
  %11 = and i16 %10, -16, !dbg !1176
  store i16 %11, i16* %2, align 2, !dbg !1176
  %12 = load i16, i16* %3, align 2, !dbg !1177
  %13 = load i16, i16* %2, align 2, !dbg !1178
  %14 = shl i16 %12, 1, !dbg !1179
  %15 = inttoptr i16 %14 to i16*, !dbg !1179
  store volatile i16 %13, i16* %15, align 2, !dbg !1179
  call void asm sideeffect "nop", ""(), !dbg !1179
  call void asm sideeffect "nop", ""(), !dbg !1179
  call void asm sideeffect "nop", ""(), !dbg !1179
  call void asm sideeffect "nop", ""(), !dbg !1179
  ret void, !dbg !1180
}

define internal void @__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 %0) !dbg !1181 {
  %2 = alloca i16, i16 1, align 2, !dbg !1183
  %3 = alloca i16, i16 1, align 2, !dbg !1185
  %4 = alloca i16, i16 1, align 2, !dbg !1186
  store i16 %0, i16* %4, align 2, !dbg !1186
  %5 = load i16, i16* %4, align 2, !dbg !1187
  store i16 %5, i16* %3, align 2, !dbg !1185
  %6 = load i16, i16* %3, align 2, !dbg !1188
  %7 = shl i16 %6, 1, !dbg !1189
  %8 = inttoptr i16 %7 to i16*, !dbg !1189
  call void asm sideeffect "nop", ""(), !dbg !1189
  call void asm sideeffect "nop", ""(), !dbg !1189
  %9 = load volatile i16, i16* %8, align 2, !dbg !1189
  store i16 %9, i16* %2, align 2, !dbg !1183
  %10 = load i16, i16* %2, align 2, !dbg !1190
  %11 = and i16 %10, -256, !dbg !1191
  store i16 %11, i16* %2, align 2, !dbg !1192
  %12 = load i16, i16* %2, align 2, !dbg !1193
  %13 = load i16, i16* %2, align 2, !dbg !1194
  %14 = call i16 @__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %13), !dbg !1195
  %15 = or i16 %12, %14, !dbg !1196
  store i16 %15, i16* %2, align 2, !dbg !1196
  %16 = load i16, i16* %2, align 2, !dbg !1197
  %17 = load i16, i16* %2, align 2, !dbg !1198
  %18 = call i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %17), !dbg !1199
  %19 = or i16 %16, %18, !dbg !1200
  store i16 %19, i16* %2, align 2, !dbg !1200
  %20 = load i16, i16* %3, align 2, !dbg !1201
  %21 = load i16, i16* %2, align 2, !dbg !1202
  %22 = shl i16 %20, 1, !dbg !1203
  %23 = inttoptr i16 %22 to i16*, !dbg !1203
  store volatile i16 %21, i16* %23, align 2, !dbg !1203
  call void asm sideeffect "nop", ""(), !dbg !1203
  call void asm sideeffect "nop", ""(), !dbg !1203
  ret void, !dbg !1204
}

define internal void @__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 %0) !dbg !1205 {
  %2 = alloca i16, i16 1, align 2, !dbg !1206
  %3 = alloca i16, i16 1, align 2, !dbg !1208
  %4 = alloca i16, i16 1, align 2, !dbg !1209
  store i16 %0, i16* %4, align 2, !dbg !1209
  %5 = load i16, i16* %4, align 2, !dbg !1210
  store i16 %5, i16* %3, align 2, !dbg !1208
  %6 = load i16, i16* %3, align 2, !dbg !1211
  %7 = shl i16 %6, 1, !dbg !1212
  %8 = inttoptr i16 %7 to i16*, !dbg !1212
  call void asm sideeffect "nop", ""(), !dbg !1212
  call void asm sideeffect "nop", ""(), !dbg !1212
  %9 = load volatile i16, i16* %8, align 2, !dbg !1212
  store i16 %9, i16* %2, align 2, !dbg !1206
  %10 = load i16, i16* %2, align 2, !dbg !1213
  %11 = and i16 %10, -256, !dbg !1214
  store i16 %11, i16* %2, align 2, !dbg !1215
  %12 = load i16, i16* %2, align 2, !dbg !1216
  %13 = load i16, i16* %2, align 2, !dbg !1217
  %14 = call i16 @__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %13), !dbg !1218
  %15 = or i16 %12, %14, !dbg !1219
  store i16 %15, i16* %2, align 2, !dbg !1219
  %16 = load i16, i16* %2, align 2, !dbg !1220
  %17 = load i16, i16* %2, align 2, !dbg !1221
  %18 = call i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %17), !dbg !1222
  %19 = or i16 %16, %18, !dbg !1223
  store i16 %19, i16* %2, align 2, !dbg !1223
  %20 = load i16, i16* %3, align 2, !dbg !1224
  %21 = load i16, i16* %2, align 2, !dbg !1225
  %22 = shl i16 %20, 1, !dbg !1226
  %23 = inttoptr i16 %22 to i16*, !dbg !1226
  store volatile i16 %21, i16* %23, align 2, !dbg !1226
  call void asm sideeffect "nop", ""(), !dbg !1226
  call void asm sideeffect "nop", ""(), !dbg !1226
  ret void, !dbg !1227
}

define internal i16 @__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %0) !dbg !1228 {
  %2 = alloca i16, i16 1, align 2, !dbg !1229
  %3 = alloca i16, i16 1, align 2, !dbg !1231
  store i16 %0, i16* %3, align 2, !dbg !1231
  %4 = load i16, i16* %3, align 2, !dbg !1232
  store i16 %4, i16* %2, align 2, !dbg !1229
  %5 = load i16, i16* %2, align 2, !dbg !1233
  store i16 %5, i16* %2, align 2, !dbg !1234
  %6 = load i16, i16* %2, align 2, !dbg !1235
  ret i16 %6, !dbg !1236
}

define internal i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %0) !dbg !1237 {
  %2 = alloca i16, i16 1, align 2, !dbg !1238
  %3 = alloca i16, i16 1, align 2, !dbg !1240
  store i16 %0, i16* %3, align 2, !dbg !1240
  %4 = load i16, i16* %3, align 2, !dbg !1241
  store i16 %4, i16* %2, align 2, !dbg !1238
  %5 = load i16, i16* %2, align 2, !dbg !1242
  %6 = or i16 %5, 2, !dbg !1243
  store i16 %6, i16* %2, align 2, !dbg !1243
  %7 = load i16, i16* %2, align 2, !dbg !1244
  ret i16 %7, !dbg !1245
}

define internal i16 @__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %0) !dbg !1246 {
  %2 = alloca i16, i16 1, align 2, !dbg !1247
  %3 = alloca i16, i16 1, align 2, !dbg !1249
  store i16 %0, i16* %3, align 2, !dbg !1249
  %4 = load i16, i16* %3, align 2, !dbg !1250
  store i16 %4, i16* %2, align 2, !dbg !1247
  %5 = load i16, i16* %2, align 2, !dbg !1251
  %6 = or i16 %5, 128, !dbg !1252
  store i16 %6, i16* %2, align 2, !dbg !1252
  %7 = load i16, i16* %2, align 2, !dbg !1253
  ret i16 %7, !dbg !1254
}

define internal void @__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction(i16 %0) !dbg !1255 {
  %2 = alloca i16, i16 1, align 2, !dbg !1256
  %3 = alloca i16, i16 1, align 2, !dbg !1258
  %4 = alloca i16, i16 1, align 2, !dbg !1259
  store i16 %0, i16* %4, align 2, !dbg !1259
  %5 = load i16, i16* %4, align 2, !dbg !1260
  store i16 %5, i16* %3, align 2, !dbg !1258
  %6 = load i16, i16* %3, align 2, !dbg !1261
  %7 = shl i16 %6, 1, !dbg !1262
  %8 = inttoptr i16 %7 to i16*, !dbg !1262
  call void asm sideeffect "nop", ""(), !dbg !1262
  call void asm sideeffect "nop", ""(), !dbg !1262
  %9 = load volatile i16, i16* %8, align 2, !dbg !1262
  store i16 %9, i16* %2, align 2, !dbg !1256
  %10 = load i16, i16* %2, align 2, !dbg !1263
  %11 = and i16 %10, -17, !dbg !1264
  store i16 %11, i16* %2, align 2, !dbg !1264
  %12 = load i16, i16* %3, align 2, !dbg !1265
  %13 = load i16, i16* %2, align 2, !dbg !1266
  %14 = shl i16 %12, 1, !dbg !1267
  %15 = inttoptr i16 %14 to i16*, !dbg !1267
  store volatile i16 %13, i16* %15, align 2, !dbg !1267
  call void asm sideeffect "nop", ""(), !dbg !1267
  call void asm sideeffect "nop", ""(), !dbg !1267
  ret void, !dbg !1268
}

define internal void @__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction(i16 %0) !dbg !1269 {
  %2 = alloca i16, i16 1, align 2, !dbg !1270
  %3 = alloca i16, i16 1, align 2, !dbg !1272
  %4 = alloca i16, i16 1, align 2, !dbg !1273
  store i16 %0, i16* %4, align 2, !dbg !1273
  %5 = load i16, i16* %4, align 2, !dbg !1274
  store i16 %5, i16* %3, align 2, !dbg !1272
  %6 = load i16, i16* %3, align 2, !dbg !1275
  %7 = shl i16 %6, 1, !dbg !1276
  %8 = inttoptr i16 %7 to i16*, !dbg !1276
  call void asm sideeffect "nop", ""(), !dbg !1276
  call void asm sideeffect "nop", ""(), !dbg !1276
  %9 = load volatile i16, i16* %8, align 2, !dbg !1276
  store i16 %9, i16* %2, align 2, !dbg !1270
  %10 = load i16, i16* %2, align 2, !dbg !1277
  %11 = or i16 %10, 16, !dbg !1278
  store i16 %11, i16* %2, align 2, !dbg !1278
  %12 = load i16, i16* %3, align 2, !dbg !1279
  %13 = load i16, i16* %2, align 2, !dbg !1280
  %14 = shl i16 %12, 1, !dbg !1281
  %15 = inttoptr i16 %14 to i16*, !dbg !1281
  store volatile i16 %13, i16* %15, align 2, !dbg !1281
  call void asm sideeffect "nop", ""(), !dbg !1281
  call void asm sideeffect "nop", ""(), !dbg !1281
  ret void, !dbg !1282
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
declare void @llvm.sdr.fmuls.ds0s1(i16 immarg, i16 immarg, i16 immarg) #12

; Function Attrs: nounwind
declare void @llvm.sdr.fmov32.dr(i16 immarg, float) #12

; Function Attrs: nounwind
declare void @llvm.sdr.imov32.ds1(i16 immarg, i16 immarg) #12

; Function Attrs: nounwind
declare float @llvm.sdr.fadds.rrs1(float, i16 immarg) #12

; Function Attrs: nounwind
declare void @llvm.sdr.imov16.ds1(i16 immarg, i16 immarg) #12

; Function Attrs: nounwind
declare void @llvm.sdr.fadds.ds0s1(i16 immarg, i16 immarg, i16 immarg) #12

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
!3 = distinct !DISubprogram(name: "spmv_scalar", linkageName: "spmv_scalar", scope: null, file: !4, line: 46, type: !5, scopeLine: 46, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!4 = !DIFile(filename: "./pe.csl", directory: "/home/USER/xkernel/studies/wse3-characterization/microbench/iremit")
!5 = !DISubroutineType(types: !6)
!6 = !{}
!7 = !DILocation(line: 55, column: 7, scope: !8)
!8 = !DILexicalBlockFile(scope: !3, file: !4, discriminator: 0)
!9 = !DILocation(line: 53, column: 5, scope: !8)
!10 = !DILocation(line: 52, column: 5, scope: !8)
!11 = !DILocation(line: 51, column: 5, scope: !8)
!12 = !DILocation(line: 50, column: 5, scope: !8)
!13 = !DILocation(line: 48, column: 3, scope: !8)
!14 = !DILocation(line: 47, column: 11, scope: !8)
!15 = !DILocation(line: 49, column: 3, scope: !8)
!16 = !DILocation(line: 49, column: 10, scope: !8)
!17 = !DILocation(line: 49, column: 12, scope: !8)
!18 = !DILocation(line: 50, column: 28, scope: !8)
!19 = !DILocation(line: 50, column: 27, scope: !8)
!20 = !DILocation(line: 51, column: 28, scope: !8)
!21 = !DILocation(line: 51, column: 30, scope: !8)
!22 = !DILocation(line: 51, column: 27, scope: !8)
!23 = !DILocation(line: 53, column: 18, scope: !8)
!24 = !DILocation(line: 54, column: 5, scope: !8)
!25 = !DILocation(line: 54, column: 12, scope: !8)
!26 = !DILocation(line: 54, column: 16, scope: !8)
!27 = !DILocation(line: 54, column: 14, scope: !8)
!28 = !DILocation(line: 55, column: 30, scope: !8)
!29 = !DILocation(line: 55, column: 29, scope: !8)
!30 = !DILocation(line: 56, column: 7, scope: !8)
!31 = !DILocation(line: 56, column: 18, scope: !8)
!32 = !DILocation(line: 56, column: 17, scope: !8)
!33 = !DILocation(line: 56, column: 25, scope: !8)
!34 = !DILocation(line: 56, column: 24, scope: !8)
!35 = !DILocation(line: 56, column: 21, scope: !8)
!36 = !DILocation(line: 56, column: 11, scope: !8)
!37 = !DILocation(line: 54, column: 22, scope: !8)
!38 = !DILocation(line: 54, column: 24, scope: !8)
!39 = !DILocation(line: 58, column: 15, scope: !8)
!40 = !DILocation(line: 58, column: 10, scope: !8)
!41 = !DILocation(line: 58, column: 9, scope: !8)
!42 = !DILocation(line: 58, column: 13, scope: !8)
!43 = !DILocation(line: 49, column: 24, scope: !8)
!44 = !DILocation(line: 49, column: 26, scope: !8)
!45 = !DILocation(line: 60, column: 11, scope: !8)
!46 = !DILocation(line: 61, column: 3, scope: !8)
!47 = distinct !DISubprogram(name: "spmv_ir", linkageName: "spmv_ir", scope: null, file: !4, line: 65, type: !5, scopeLine: 65, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!48 = !DILocation(line: 66, column: 11, scope: !49)
!49 = !DILexicalBlockFile(scope: !47, file: !4, discriminator: 0)
!50 = !DILocation(line: 67, column: 11, scope: !49)
!51 = !DILocation(line: 68, column: 11, scope: !49)
!52 = !DILocation(line: 69, column: 3, scope: !49)
!53 = !DILocation(line: 65, column: 1, scope: !49)
!54 = distinct !DISubprogram(name: "spmv_blk", linkageName: "spmv_blk", scope: null, file: !4, line: 75, type: !5, scopeLine: 75, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!55 = !DILocation(line: 89, column: 5, scope: !56)
!56 = !DILexicalBlockFile(scope: !54, file: !4, discriminator: 0)
!57 = !DILocation(line: 88, column: 5, scope: !56)
!58 = !DILocation(line: 86, column: 5, scope: !56)
!59 = !DILocation(line: 84, column: 5, scope: !56)
!60 = !DILocation(line: 82, column: 5, scope: !56)
!61 = !DILocation(line: 81, column: 5, scope: !56)
!62 = !DILocation(line: 80, column: 5, scope: !56)
!63 = !DILocation(line: 79, column: 5, scope: !56)
!64 = !DILocation(line: 77, column: 3, scope: !56)
!65 = !DILocation(line: 76, column: 11, scope: !56)
!66 = !DILocation(line: 78, column: 3, scope: !56)
!67 = !DILocation(line: 78, column: 10, scope: !56)
!68 = !DILocation(line: 78, column: 12, scope: !56)
!69 = !DILocation(line: 79, column: 28, scope: !56)
!70 = !DILocation(line: 79, column: 27, scope: !56)
!71 = !DILocation(line: 80, column: 28, scope: !56)
!72 = !DILocation(line: 80, column: 27, scope: !56)
!73 = !DILocation(line: 81, column: 31, scope: !56)
!74 = !DILocation(line: 81, column: 30, scope: !56)
!75 = !DILocation(line: 82, column: 39, scope: !56)
!76 = !DILocation(line: 83, column: 32, scope: !56)
!77 = !DILocation(line: 83, column: 45, scope: !56)
!78 = !DILocation(line: 83, column: 10, scope: !56)
!79 = !DILocation(line: 83, column: 8, scope: !56)
!80 = !DILocation(line: 84, column: 37, scope: !56)
!81 = !DILocation(line: 85, column: 32, scope: !56)
!82 = !DILocation(line: 85, column: 45, scope: !56)
!83 = !DILocation(line: 85, column: 10, scope: !56)
!84 = !DILocation(line: 85, column: 8, scope: !56)
!85 = !DILocation(line: 86, column: 39, scope: !56)
!86 = !DILocation(line: 87, column: 12, scope: !56)
!87 = !DILocation(line: 87, column: 16, scope: !56)
!88 = !DILocation(line: 87, column: 20, scope: !56)
!89 = !DILocation(line: 87, column: 5, scope: !56)
!90 = !DILocation(line: 90, column: 5, scope: !56)
!91 = !DILocation(line: 90, column: 12, scope: !56)
!92 = !DILocation(line: 90, column: 16, scope: !56)
!93 = !DILocation(line: 90, column: 14, scope: !56)
!94 = !DILocation(line: 90, column: 32, scope: !56)
!95 = !DILocation(line: 90, column: 43, scope: !56)
!96 = !DILocation(line: 90, column: 42, scope: !56)
!97 = !DILocation(line: 90, column: 36, scope: !56)
!98 = !DILocation(line: 90, column: 22, scope: !56)
!99 = !DILocation(line: 90, column: 24, scope: !56)
!100 = !DILocation(line: 91, column: 15, scope: !56)
!101 = !DILocation(line: 91, column: 10, scope: !56)
!102 = !DILocation(line: 91, column: 9, scope: !56)
!103 = !DILocation(line: 91, column: 13, scope: !56)
!104 = !DILocation(line: 78, column: 24, scope: !56)
!105 = !DILocation(line: 78, column: 26, scope: !56)
!106 = !DILocation(line: 93, column: 11, scope: !56)
!107 = !DILocation(line: 94, column: 3, scope: !56)
!108 = distinct !DISubprogram(name: "spmv_blk_dsdred", linkageName: "spmv_blk_dsdred", scope: null, file: !4, line: 101, type: !5, scopeLine: 101, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!109 = !DILocation(line: 112, column: 5, scope: !110)
!110 = !DILexicalBlockFile(scope: !108, file: !4, discriminator: 0)
!111 = !DILocation(line: 110, column: 5, scope: !110)
!112 = !DILocation(line: 108, column: 5, scope: !110)
!113 = !DILocation(line: 107, column: 5, scope: !110)
!114 = !DILocation(line: 106, column: 5, scope: !110)
!115 = !DILocation(line: 105, column: 5, scope: !110)
!116 = !DILocation(line: 103, column: 3, scope: !110)
!117 = !DILocation(line: 102, column: 12, scope: !110)
!118 = !DILocation(line: 104, column: 3, scope: !110)
!119 = !DILocation(line: 104, column: 10, scope: !110)
!120 = !DILocation(line: 104, column: 12, scope: !110)
!121 = !DILocation(line: 105, column: 28, scope: !110)
!122 = !DILocation(line: 105, column: 27, scope: !110)
!123 = !DILocation(line: 106, column: 28, scope: !110)
!124 = !DILocation(line: 106, column: 27, scope: !110)
!125 = !DILocation(line: 107, column: 31, scope: !110)
!126 = !DILocation(line: 107, column: 30, scope: !110)
!127 = !DILocation(line: 108, column: 39, scope: !110)
!128 = !DILocation(line: 109, column: 32, scope: !110)
!129 = !DILocation(line: 109, column: 45, scope: !110)
!130 = !DILocation(line: 109, column: 10, scope: !110)
!131 = !DILocation(line: 109, column: 8, scope: !110)
!132 = !DILocation(line: 110, column: 37, scope: !110)
!133 = !DILocation(line: 111, column: 32, scope: !110)
!134 = !DILocation(line: 111, column: 45, scope: !110)
!135 = !DILocation(line: 111, column: 10, scope: !110)
!136 = !DILocation(line: 111, column: 8, scope: !110)
!137 = !DILocation(line: 112, column: 39, scope: !110)
!138 = !DILocation(line: 113, column: 12, scope: !110)
!139 = !DILocation(line: 113, column: 16, scope: !110)
!140 = !DILocation(line: 113, column: 20, scope: !110)
!141 = !DILocation(line: 113, column: 5, scope: !110)
!142 = !DILocation(line: 114, column: 11, scope: !110)
!143 = !DILocation(line: 115, column: 20, scope: !110)
!144 = !DILocation(line: 115, column: 27, scope: !110)
!145 = !DILocation(line: 115, column: 5, scope: !110)
!146 = !DILocation(line: 116, column: 15, scope: !110)
!147 = !DILocation(line: 116, column: 10, scope: !110)
!148 = !DILocation(line: 116, column: 9, scope: !110)
!149 = !DILocation(line: 116, column: 13, scope: !110)
!150 = !DILocation(line: 104, column: 24, scope: !110)
!151 = !DILocation(line: 104, column: 26, scope: !110)
!152 = !DILocation(line: 118, column: 12, scope: !110)
!153 = !DILocation(line: 119, column: 3, scope: !110)
!154 = distinct !DISubprogram(name: "spmv_dia", linkageName: "spmv_dia", scope: null, file: !4, line: 125, type: !5, scopeLine: 125, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!155 = !DILocation(line: 136, column: 5, scope: !156)
!156 = !DILexicalBlockFile(scope: !154, file: !4, discriminator: 0)
!157 = !DILocation(line: 135, column: 5, scope: !156)
!158 = !DILocation(line: 133, column: 5, scope: !156)
!159 = !DILocation(line: 131, column: 5, scope: !156)
!160 = !DILocation(line: 130, column: 5, scope: !156)
!161 = !DILocation(line: 128, column: 3, scope: !156)
!162 = !DILocation(line: 126, column: 11, scope: !156)
!163 = !DILocation(line: 127, column: 3, scope: !156)
!164 = !DILocation(line: 129, column: 3, scope: !156)
!165 = !DILocation(line: 129, column: 10, scope: !156)
!166 = !DILocation(line: 129, column: 12, scope: !156)
!167 = !DILocation(line: 130, column: 28, scope: !156)
!168 = !DILocation(line: 130, column: 27, scope: !156)
!169 = !DILocation(line: 131, column: 38, scope: !156)
!170 = !DILocation(line: 132, column: 32, scope: !156)
!171 = !DILocation(line: 132, column: 53, scope: !156)
!172 = !DILocation(line: 132, column: 52, scope: !156)
!173 = !DILocation(line: 132, column: 10, scope: !156)
!174 = !DILocation(line: 132, column: 8, scope: !156)
!175 = !DILocation(line: 133, column: 37, scope: !156)
!176 = !DILocation(line: 134, column: 32, scope: !156)
!177 = !DILocation(line: 134, column: 54, scope: !156)
!178 = !DILocation(line: 134, column: 53, scope: !156)
!179 = !DILocation(line: 134, column: 10, scope: !156)
!180 = !DILocation(line: 134, column: 8, scope: !156)
!181 = !DILocation(line: 135, column: 39, scope: !156)
!182 = !DILocation(line: 136, column: 39, scope: !156)
!183 = !DILocation(line: 137, column: 32, scope: !156)
!184 = !DILocation(line: 137, column: 54, scope: !156)
!185 = !DILocation(line: 137, column: 53, scope: !156)
!186 = !DILocation(line: 137, column: 10, scope: !156)
!187 = !DILocation(line: 137, column: 8, scope: !156)
!188 = !DILocation(line: 138, column: 12, scope: !156)
!189 = !DILocation(line: 138, column: 16, scope: !156)
!190 = !DILocation(line: 138, column: 20, scope: !156)
!191 = !DILocation(line: 138, column: 5, scope: !156)
!192 = !DILocation(line: 139, column: 12, scope: !156)
!193 = !DILocation(line: 139, column: 16, scope: !156)
!194 = !DILocation(line: 139, column: 20, scope: !156)
!195 = !DILocation(line: 139, column: 5, scope: !156)
!196 = !DILocation(line: 129, column: 23, scope: !156)
!197 = !DILocation(line: 129, column: 25, scope: !156)
!198 = !DILocation(line: 141, column: 11, scope: !156)
!199 = !DILocation(line: 142, column: 3, scope: !156)
!200 = distinct !DISubprogram(name: "probe_reduce", linkageName: "probe_reduce", scope: null, file: !4, line: 148, type: !5, scopeLine: 148, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!201 = !DILocation(line: 151, column: 3, scope: !202)
!202 = !DILexicalBlockFile(scope: !200, file: !4, discriminator: 0)
!203 = !DILocation(line: 149, column: 11, scope: !202)
!204 = !DILocation(line: 150, column: 21, scope: !202)
!205 = !DILocation(line: 150, column: 9, scope: !202)
!206 = !DILocation(line: 152, column: 18, scope: !202)
!207 = !DILocation(line: 152, column: 25, scope: !202)
!208 = !DILocation(line: 152, column: 3, scope: !202)
!209 = !DILocation(line: 153, column: 18, scope: !202)
!210 = !DILocation(line: 153, column: 16, scope: !202)
!211 = !DILocation(line: 154, column: 11, scope: !202)
!212 = !DILocation(line: 155, column: 3, scope: !202)
!213 = !DILocation(line: 148, column: 1, scope: !202)
!214 = distinct !DISubprogram(name: "probe_reduce_const", linkageName: "probe_reduce_const", scope: null, file: !4, line: 160, type: !5, scopeLine: 160, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!215 = !DILocation(line: 163, column: 3, scope: !216)
!216 = !DILexicalBlockFile(scope: !214, file: !4, discriminator: 0)
!217 = !DILocation(line: 161, column: 12, scope: !216)
!218 = !DILocation(line: 162, column: 9, scope: !216)
!219 = !DILocation(line: 164, column: 18, scope: !216)
!220 = !DILocation(line: 164, column: 25, scope: !216)
!221 = !DILocation(line: 164, column: 3, scope: !216)
!222 = !DILocation(line: 165, column: 18, scope: !216)
!223 = !DILocation(line: 165, column: 16, scope: !216)
!224 = !DILocation(line: 166, column: 12, scope: !216)
!225 = !DILocation(line: 167, column: 3, scope: !216)
!226 = !DILocation(line: 160, column: 1, scope: !216)
!227 = distinct !DISubprogram(name: "f_exit", linkageName: "f_exit", scope: null, file: !4, line: 170, type: !5, scopeLine: 170, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!228 = !DILocation(line: 170, column: 22, scope: !229)
!229 = !DILexicalBlockFile(scope: !227, file: !4, discriminator: 0)
!230 = !DILocation(line: 170, column: 1, scope: !229)
!231 = distinct !DISubprogram(name: "sys_mod.sys_nop", linkageName: "sys_mod.sys_nop", scope: null, file: !232, line: 90, type: !5, scopeLine: 90, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!232 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/memcpy.csl", directory: "")
!233 = !DILocation(line: 90, column: 1, scope: !234)
!234 = !DILexicalBlockFile(scope: !231, file: !232, discriminator: 0)
!235 = distinct !DISubprogram(name: "sys_mod.unblock_cmd_stream", linkageName: "sys_mod.unblock_cmd_stream", scope: null, file: !232, line: 102, type: !5, scopeLine: 102, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!236 = !DILocation(line: 103, column: 3, scope: !237)
!237 = !DILexicalBlockFile(scope: !235, file: !232, discriminator: 0)
!238 = !DILocation(line: 102, column: 1, scope: !237)
!239 = distinct !DISubprogram(name: "sys_mod.sys_mod.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.unblock_cmd_stream", scope: null, file: !240, line: 307, type: !5, scopeLine: 307, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!240 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpy.csl", directory: "")
!241 = !DILocation(line: 308, column: 5, scope: !242)
!242 = !DILexicalBlockFile(scope: !239, file: !240, discriminator: 0)
!243 = !DILocation(line: 307, column: 1, scope: !242)
!244 = distinct !DISubprogram(name: "sys_mod.sys_mod.teardown_h2d", linkageName: "sys_mod.sys_mod.teardown_h2d", scope: null, file: !240, line: 323, type: !5, scopeLine: 323, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!245 = !DILocation(line: 326, column: 5, scope: !246)
!246 = !DILexicalBlockFile(scope: !244, file: !240, discriminator: 0)
!247 = !DILocation(line: 323, column: 1, scope: !246)
!248 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_ublk_c22", linkageName: "sys_mod.sys_mod.f_ublk_c22", scope: null, file: !240, line: 335, type: !5, scopeLine: 335, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!249 = !DILocation(line: 336, column: 5, scope: !250)
!250 = !DILexicalBlockFile(scope: !248, file: !240, discriminator: 0)
!251 = !DILocation(line: 335, column: 1, scope: !250)
!252 = distinct !DISubprogram(name: "sys_mod.sys_mod.teardown_d2h", linkageName: "sys_mod.sys_mod.teardown_d2h", scope: null, file: !240, line: 344, type: !5, scopeLine: 344, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!253 = !DILocation(line: 355, column: 5, scope: !254)
!254 = !DILexicalBlockFile(scope: !252, file: !240, discriminator: 0)
!255 = !DILocation(line: 359, column: 5, scope: !254)
!256 = !DILocation(line: 344, column: 1, scope: !254)
!257 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_memcpyh2d", linkageName: "sys_mod.sys_mod.f_memcpyh2d", scope: null, file: !240, line: 460, type: !5, scopeLine: 460, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!258 = !DILocation(line: 477, column: 5, scope: !259)
!259 = !DILexicalBlockFile(scope: !257, file: !240, discriminator: 0)
!260 = !DILocation(line: 476, column: 5, scope: !259)
!261 = !DILocation(line: 475, column: 5, scope: !259)
!262 = !DILocation(line: 474, column: 5, scope: !259)
!263 = !DILocation(line: 473, column: 5, scope: !259)
!264 = !DILocation(line: 472, column: 5, scope: !259)
!265 = !DILocation(line: 471, column: 5, scope: !259)
!266 = !DILocation(line: 470, column: 5, scope: !259)
!267 = !DILocation(line: 469, column: 5, scope: !259)
!268 = !DILocation(line: 468, column: 5, scope: !259)
!269 = !DILocation(line: 467, column: 5, scope: !259)
!270 = !DILocation(line: 466, column: 5, scope: !259)
!271 = !DILocation(line: 465, column: 5, scope: !259)
!272 = !DILocation(line: 463, column: 5, scope: !259)
!273 = !DILocation(line: 462, column: 20, scope: !259)
!274 = !DILocation(line: 462, column: 32, scope: !259)
!275 = !DILocation(line: 462, column: 5, scope: !259)
!276 = !DILocation(line: 465, column: 33, scope: !259)
!277 = !DILocation(line: 465, column: 38, scope: !259)
!278 = !DILocation(line: 466, column: 34, scope: !259)
!279 = !DILocation(line: 466, column: 39, scope: !259)
!280 = !DILocation(line: 467, column: 34, scope: !259)
!281 = !DILocation(line: 467, column: 39, scope: !259)
!282 = !DILocation(line: 468, column: 33, scope: !259)
!283 = !DILocation(line: 468, column: 38, scope: !259)
!284 = !DILocation(line: 469, column: 33, scope: !259)
!285 = !DILocation(line: 469, column: 38, scope: !259)
!286 = !DILocation(line: 470, column: 35, scope: !259)
!287 = !DILocation(line: 470, column: 21, scope: !259)
!288 = !DILocation(line: 471, column: 41, scope: !259)
!289 = !DILocation(line: 471, column: 27, scope: !259)
!290 = !DILocation(line: 472, column: 39, scope: !259)
!291 = !DILocation(line: 472, column: 25, scope: !259)
!292 = !DILocation(line: 473, column: 44, scope: !259)
!293 = !DILocation(line: 473, column: 49, scope: !259)
!294 = !DILocation(line: 474, column: 41, scope: !259)
!295 = !DILocation(line: 474, column: 46, scope: !259)
!296 = !DILocation(line: 475, column: 41, scope: !259)
!297 = !DILocation(line: 475, column: 46, scope: !259)
!298 = !DILocation(line: 476, column: 59, scope: !259)
!299 = !DILocation(line: 476, column: 64, scope: !259)
!300 = !DILocation(line: 476, column: 50, scope: !259)
!301 = !DILocation(line: 476, column: 129, scope: !259)
!302 = !DILocation(line: 476, column: 134, scope: !259)
!303 = !DILocation(line: 476, column: 120, scope: !259)
!304 = !DILocation(line: 476, column: 118, scope: !259)
!305 = !DILocation(line: 476, column: 112, scope: !259)
!306 = !DILocation(line: 476, column: 36, scope: !259)
!307 = !DILocation(line: 477, column: 59, scope: !259)
!308 = !DILocation(line: 477, column: 64, scope: !259)
!309 = !DILocation(line: 477, column: 50, scope: !259)
!310 = !DILocation(line: 477, column: 129, scope: !259)
!311 = !DILocation(line: 477, column: 134, scope: !259)
!312 = !DILocation(line: 477, column: 120, scope: !259)
!313 = !DILocation(line: 477, column: 118, scope: !259)
!314 = !DILocation(line: 477, column: 112, scope: !259)
!315 = !DILocation(line: 477, column: 36, scope: !259)
!316 = !DILocation(line: 479, column: 24, scope: !259)
!317 = !DILocation(line: 481, column: 21, scope: !259)
!318 = !DILocation(line: 481, column: 19, scope: !259)
!319 = !DILocation(line: 482, column: 21, scope: !259)
!320 = !DILocation(line: 482, column: 19, scope: !259)
!321 = !DILocation(line: 483, column: 21, scope: !259)
!322 = !DILocation(line: 483, column: 19, scope: !259)
!323 = !DILocation(line: 484, column: 20, scope: !259)
!324 = !DILocation(line: 484, column: 18, scope: !259)
!325 = !DILocation(line: 485, column: 20, scope: !259)
!326 = !DILocation(line: 485, column: 18, scope: !259)
!327 = !DILocation(line: 486, column: 22, scope: !259)
!328 = !DILocation(line: 486, column: 20, scope: !259)
!329 = !DILocation(line: 487, column: 27, scope: !259)
!330 = !DILocation(line: 487, column: 25, scope: !259)
!331 = !DILocation(line: 488, column: 25, scope: !259)
!332 = !DILocation(line: 488, column: 23, scope: !259)
!333 = !DILocation(line: 489, column: 31, scope: !259)
!334 = !DILocation(line: 489, column: 29, scope: !259)
!335 = !DILocation(line: 490, column: 28, scope: !259)
!336 = !DILocation(line: 490, column: 26, scope: !259)
!337 = !DILocation(line: 491, column: 28, scope: !259)
!338 = !DILocation(line: 491, column: 26, scope: !259)
!339 = !DILocation(line: 492, column: 37, scope: !259)
!340 = !DILocation(line: 492, column: 35, scope: !259)
!341 = !DILocation(line: 493, column: 37, scope: !259)
!342 = !DILocation(line: 493, column: 35, scope: !259)
!343 = !DILocation(line: 495, column: 5, scope: !259)
!344 = !DILocation(line: 501, column: 5, scope: !259)
!345 = !DILocation(line: 506, column: 5, scope: !259)
!346 = !DILocation(line: 521, column: 5, scope: !259)
!347 = !DILocation(line: 522, column: 16, scope: !259)
!348 = !DILocation(line: 531, column: 5, scope: !259)
!349 = !DILocation(line: 460, column: 1, scope: !259)
!350 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_memcpyd2h", linkageName: "sys_mod.sys_mod.f_memcpyd2h", scope: null, file: !240, line: 556, type: !5, scopeLine: 556, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!351 = !DILocation(line: 568, column: 5, scope: !352)
!352 = !DILexicalBlockFile(scope: !350, file: !240, discriminator: 0)
!353 = !DILocation(line: 567, column: 5, scope: !352)
!354 = !DILocation(line: 566, column: 5, scope: !352)
!355 = !DILocation(line: 565, column: 5, scope: !352)
!356 = !DILocation(line: 564, column: 5, scope: !352)
!357 = !DILocation(line: 563, column: 5, scope: !352)
!358 = !DILocation(line: 562, column: 5, scope: !352)
!359 = !DILocation(line: 561, column: 5, scope: !352)
!360 = !DILocation(line: 559, column: 5, scope: !352)
!361 = !DILocation(line: 558, column: 20, scope: !352)
!362 = !DILocation(line: 558, column: 32, scope: !352)
!363 = !DILocation(line: 558, column: 5, scope: !352)
!364 = !DILocation(line: 561, column: 33, scope: !352)
!365 = !DILocation(line: 561, column: 38, scope: !352)
!366 = !DILocation(line: 562, column: 34, scope: !352)
!367 = !DILocation(line: 562, column: 39, scope: !352)
!368 = !DILocation(line: 563, column: 34, scope: !352)
!369 = !DILocation(line: 563, column: 39, scope: !352)
!370 = !DILocation(line: 564, column: 33, scope: !352)
!371 = !DILocation(line: 564, column: 38, scope: !352)
!372 = !DILocation(line: 565, column: 33, scope: !352)
!373 = !DILocation(line: 565, column: 38, scope: !352)
!374 = !DILocation(line: 566, column: 35, scope: !352)
!375 = !DILocation(line: 566, column: 21, scope: !352)
!376 = !DILocation(line: 567, column: 41, scope: !352)
!377 = !DILocation(line: 567, column: 27, scope: !352)
!378 = !DILocation(line: 568, column: 39, scope: !352)
!379 = !DILocation(line: 568, column: 25, scope: !352)
!380 = !DILocation(line: 570, column: 24, scope: !352)
!381 = !DILocation(line: 573, column: 21, scope: !352)
!382 = !DILocation(line: 573, column: 19, scope: !352)
!383 = !DILocation(line: 574, column: 21, scope: !352)
!384 = !DILocation(line: 574, column: 19, scope: !352)
!385 = !DILocation(line: 575, column: 21, scope: !352)
!386 = !DILocation(line: 575, column: 19, scope: !352)
!387 = !DILocation(line: 576, column: 20, scope: !352)
!388 = !DILocation(line: 576, column: 18, scope: !352)
!389 = !DILocation(line: 577, column: 20, scope: !352)
!390 = !DILocation(line: 577, column: 18, scope: !352)
!391 = !DILocation(line: 578, column: 22, scope: !352)
!392 = !DILocation(line: 578, column: 20, scope: !352)
!393 = !DILocation(line: 579, column: 27, scope: !352)
!394 = !DILocation(line: 579, column: 25, scope: !352)
!395 = !DILocation(line: 580, column: 25, scope: !352)
!396 = !DILocation(line: 580, column: 23, scope: !352)
!397 = !DILocation(line: 582, column: 5, scope: !352)
!398 = !DILocation(line: 588, column: 59, scope: !352)
!399 = !DILocation(line: 588, column: 5, scope: !352)
!400 = !DILocation(line: 608, column: 5, scope: !352)
!401 = !DILocation(line: 609, column: 16, scope: !352)
!402 = !DILocation(line: 556, column: 1, scope: !352)
!403 = distinct !DISubprogram(name: "sys_mod.sys_mod.oq0_teardow_handler", linkageName: "sys_mod.sys_mod.oq0_teardow_handler", scope: null, file: !240, line: 631, type: !5, scopeLine: 631, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!404 = !DILocation(line: 632, column: 9, scope: !405)
!405 = !DILexicalBlockFile(scope: !403, file: !240, discriminator: 0)
!406 = !DILocation(line: 632, column: 5, scope: !405)
!407 = !DILocation(line: 634, column: 66, scope: !405)
!408 = !DILocation(line: 634, column: 9, scope: !405)
!409 = !DILocation(line: 636, column: 13, scope: !405)
!410 = !DILocation(line: 637, column: 13, scope: !405)
!411 = !DILocation(line: 638, column: 13, scope: !405)
!412 = !DILocation(line: 639, column: 13, scope: !405)
!413 = !DILocation(line: 640, column: 13, scope: !405)
!414 = !DILocation(line: 641, column: 13, scope: !405)
!415 = !DILocation(line: 642, column: 13, scope: !405)
!416 = !DILocation(line: 643, column: 13, scope: !405)
!417 = !DILocation(line: 644, column: 13, scope: !405)
!418 = !DILocation(line: 645, column: 13, scope: !405)
!419 = !DILocation(line: 646, column: 13, scope: !405)
!420 = !DILocation(line: 647, column: 13, scope: !405)
!421 = !DILocation(line: 648, column: 13, scope: !405)
!422 = !DILocation(line: 635, column: 9, scope: !405)
!423 = !DILocation(line: 652, column: 9, scope: !405)
!424 = !DILocation(line: 654, column: 13, scope: !405)
!425 = !DILocation(line: 655, column: 13, scope: !405)
!426 = !DILocation(line: 656, column: 13, scope: !405)
!427 = !DILocation(line: 657, column: 13, scope: !405)
!428 = !DILocation(line: 658, column: 13, scope: !405)
!429 = !DILocation(line: 659, column: 13, scope: !405)
!430 = !DILocation(line: 660, column: 13, scope: !405)
!431 = !DILocation(line: 661, column: 13, scope: !405)
!432 = !DILocation(line: 653, column: 9, scope: !405)
!433 = !DILocation(line: 664, column: 5, scope: !405)
!434 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_rpc", linkageName: "sys_mod.sys_mod.f_rpc", scope: null, file: !240, line: 694, type: !5, scopeLine: 694, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!435 = !DILocation(line: 694, column: 13, scope: !436)
!436 = !DILexicalBlockFile(scope: !434, file: !240, discriminator: 0)
!437 = !DILocation(line: 700, column: 5, scope: !436)
!438 = !DILocation(line: 706, column: 20, scope: !436)
!439 = !DILocation(line: 706, column: 32, scope: !436)
!440 = !DILocation(line: 706, column: 5, scope: !436)
!441 = !DILocation(line: 710, column: 5, scope: !436)
!442 = !DILocation(line: 712, column: 24, scope: !436)
!443 = !DILocation(line: 694, column: 1, scope: !436)
!444 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.stack_push", linkageName: "sys_mod.sys_mod.sys_mod.stack_push", scope: null, file: !445, line: 54, type: !5, scopeLine: 54, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!445 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/sys.csl", directory: "")
!446 = !DILocation(line: 60, column: 5, scope: !447)
!447 = !DILexicalBlockFile(scope: !444, file: !445, discriminator: 0)
!448 = !DILocation(line: 54, column: 16, scope: !447)
!449 = !DILocation(line: 59, column: 13, scope: !447)
!450 = !DILocation(line: 59, column: 24, scope: !447)
!451 = !DILocation(line: 59, column: 5, scope: !447)
!452 = !DILocation(line: 61, column: 25, scope: !447)
!453 = !DILocation(line: 61, column: 5, scope: !447)
!454 = !DILocation(line: 61, column: 11, scope: !447)
!455 = !DILocation(line: 61, column: 10, scope: !447)
!456 = !DILocation(line: 61, column: 23, scope: !447)
!457 = !DILocation(line: 62, column: 18, scope: !447)
!458 = !DILocation(line: 62, column: 29, scope: !447)
!459 = !DILocation(line: 62, column: 16, scope: !447)
!460 = !DILocation(line: 54, column: 1, scope: !447)
!461 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_push", linkageName: "sys_mod.sys_mod.sys_mod.f_push", scope: null, file: !445, line: 72, type: !5, scopeLine: 72, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!462 = !DILocation(line: 72, column: 25, scope: !463)
!463 = !DILexicalBlockFile(scope: !461, file: !445, discriminator: 0)
!464 = !DILocation(line: 72, column: 13, scope: !463)
!465 = !DILocation(line: 73, column: 16, scope: !463)
!466 = !DILocation(line: 73, column: 5, scope: !463)
!467 = !DILocation(line: 72, column: 1, scope: !463)
!468 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.block_cmd_stream", linkageName: "sys_mod.sys_mod.sys_mod.block_cmd_stream", scope: null, file: !445, line: 76, type: !5, scopeLine: 76, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!469 = !DILocation(line: 77, column: 5, scope: !470)
!470 = !DILexicalBlockFile(scope: !468, file: !445, discriminator: 0)
!471 = !DILocation(line: 76, column: 1, scope: !470)
!472 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.sys_mod.unblock_cmd_stream", scope: null, file: !445, line: 80, type: !5, scopeLine: 80, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!473 = !DILocation(line: 81, column: 5, scope: !474)
!474 = !DILexicalBlockFile(scope: !472, file: !445, discriminator: 0)
!475 = !DILocation(line: 80, column: 1, scope: !474)
!476 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_sys_exit", linkageName: "sys_mod.sys_mod.sys_mod.f_sys_exit", scope: null, file: !445, line: 85, type: !5, scopeLine: 85, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!477 = !DILocation(line: 86, column: 5, scope: !478)
!478 = !DILexicalBlockFile(scope: !476, file: !445, discriminator: 0)
!479 = !DILocation(line: 87, column: 5, scope: !478)
!480 = !DILocation(line: 85, column: 1, scope: !478)
!481 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore", linkageName: "sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore", scope: null, file: !445, line: 90, type: !5, scopeLine: 90, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!482 = !DILocation(line: 90, column: 30, scope: !483)
!483 = !DILexicalBlockFile(scope: !481, file: !445, discriminator: 0)
!484 = !DILocation(line: 90, column: 1, scope: !483)
!485 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord", scope: null, file: !486, line: 131, type: !5, scopeLine: 131, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!486 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpyh2d.csl", directory: "")
!487 = !DILocation(line: 132, column: 12, scope: !488)
!488 = !DILexicalBlockFile(scope: !485, file: !486, discriminator: 0)
!489 = !DILocation(line: 132, column: 5, scope: !488)
!490 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord", scope: null, file: !486, line: 134, type: !5, scopeLine: 134, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!491 = !DILocation(line: 135, column: 12, scope: !492)
!492 = !DILexicalBlockFile(scope: !490, file: !486, discriminator: 0)
!493 = !DILocation(line: 135, column: 5, scope: !492)
!494 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval", scope: null, file: !486, line: 148, type: !5, scopeLine: 148, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!495 = !DILocation(line: 148, column: 23, scope: !496)
!496 = !DILexicalBlockFile(scope: !494, file: !486, discriminator: 0)
!497 = !DILocation(line: 149, column: 9, scope: !496)
!498 = !DILocation(line: 149, column: 20, scope: !496)
!499 = !DILocation(line: 149, column: 5, scope: !496)
!500 = !DILocation(line: 152, column: 23, scope: !496)
!501 = !DILocation(line: 152, column: 20, scope: !496)
!502 = !DILocation(line: 152, column: 9, scope: !496)
!503 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start", scope: null, file: !486, line: 226, type: !5, scopeLine: 226, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!504 = !DILocation(line: 233, column: 5, scope: !505)
!505 = !DILexicalBlockFile(scope: !503, file: !486, discriminator: 0)
!506 = !DILocation(line: 226, column: 49, scope: !505)
!507 = !DILocation(line: 226, column: 32, scope: !505)
!508 = !DILocation(line: 226, column: 21, scope: !505)
!509 = !DILocation(line: 229, column: 37, scope: !505)
!510 = !DILocation(line: 229, column: 52, scope: !505)
!511 = !DILocation(line: 229, column: 19, scope: !505)
!512 = !DILocation(line: 233, column: 71, scope: !505)
!513 = !DILocation(line: 233, column: 55, scope: !505)
!514 = !DILocation(line: 233, column: 25, scope: !505)
!515 = !DILocation(line: 235, column: 37, scope: !505)
!516 = !DILocation(line: 235, column: 52, scope: !505)
!517 = !DILocation(line: 235, column: 19, scope: !505)
!518 = !DILocation(line: 236, column: 28, scope: !505)
!519 = !DILocation(line: 236, column: 5, scope: !505)
!520 = !DILocation(line: 237, column: 28, scope: !505)
!521 = !DILocation(line: 237, column: 5, scope: !505)
!522 = !DILocation(line: 238, column: 13, scope: !505)
!523 = !DILocation(line: 238, column: 11, scope: !505)
!524 = !DILocation(line: 238, column: 5, scope: !505)
!525 = !DILocation(line: 239, column: 9, scope: !505)
!526 = !DILocation(line: 241, column: 9, scope: !505)
!527 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream", scope: null, file: !486, line: 249, type: !5, scopeLine: 249, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!528 = !DILocation(line: 250, column: 5, scope: !529)
!529 = !DILexicalBlockFile(scope: !527, file: !486, discriminator: 0)
!530 = !DILocation(line: 249, column: 1, scope: !529)
!531 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure", scope: null, file: !486, line: 276, type: !5, scopeLine: 276, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!532 = !DILocation(line: 414, column: 13, scope: !533)
!533 = !DILexicalBlockFile(scope: !531, file: !486, discriminator: 0)
!534 = !DILocation(line: 413, column: 13, scope: !533)
!535 = !DILocation(line: 400, column: 17, scope: !533)
!536 = !DILocation(line: 340, column: 9, scope: !533)
!537 = !DILocation(line: 339, column: 9, scope: !533)
!538 = !DILocation(line: 337, column: 5, scope: !533)
!539 = !DILocation(line: 319, column: 9, scope: !533)
!540 = !DILocation(line: 318, column: 9, scope: !533)
!541 = !DILocation(line: 315, column: 5, scope: !533)
!542 = !DILocation(line: 292, column: 5, scope: !533)
!543 = !DILocation(line: 291, column: 5, scope: !533)
!544 = !DILocation(line: 289, column: 5, scope: !533)
!545 = !DILocation(line: 288, column: 5, scope: !533)
!546 = !DILocation(line: 287, column: 5, scope: !533)
!547 = !DILocation(line: 286, column: 5, scope: !533)
!548 = !DILocation(line: 285, column: 5, scope: !533)
!549 = !DILocation(line: 284, column: 5, scope: !533)
!550 = !DILocation(line: 283, column: 5, scope: !533)
!551 = !DILocation(line: 282, column: 5, scope: !533)
!552 = !DILocation(line: 281, column: 5, scope: !533)
!553 = !DILocation(line: 280, column: 5, scope: !533)
!554 = !DILocation(line: 279, column: 5, scope: !533)
!555 = !DILocation(line: 278, column: 5, scope: !533)
!556 = !DILocation(line: 277, column: 5, scope: !533)
!557 = !DILocation(line: 291, column: 26, scope: !533)
!558 = !DILocation(line: 292, column: 26, scope: !533)
!559 = !DILocation(line: 315, column: 25, scope: !533)
!560 = !DILocation(line: 315, column: 31, scope: !533)
!561 = !DILocation(line: 315, column: 29, scope: !533)
!562 = !DILocation(line: 316, column: 20, scope: !533)
!563 = !DILocation(line: 316, column: 18, scope: !533)
!564 = !DILocation(line: 317, column: 52, scope: !533)
!565 = !DILocation(line: 317, column: 49, scope: !533)
!566 = !DILocation(line: 317, column: 5, scope: !533)
!567 = !DILocation(line: 318, column: 42, scope: !533)
!568 = !DILocation(line: 318, column: 33, scope: !533)
!569 = !DILocation(line: 318, column: 49, scope: !533)
!570 = !DILocation(line: 318, column: 48, scope: !533)
!571 = !DILocation(line: 318, column: 24, scope: !533)
!572 = !DILocation(line: 319, column: 24, scope: !533)
!573 = !DILocation(line: 319, column: 32, scope: !533)
!574 = !DILocation(line: 319, column: 36, scope: !533)
!575 = !DILocation(line: 319, column: 34, scope: !533)
!576 = !DILocation(line: 319, column: 30, scope: !533)
!577 = !DILocation(line: 320, column: 18, scope: !533)
!578 = !DILocation(line: 320, column: 15, scope: !533)
!579 = !DILocation(line: 320, column: 9, scope: !533)
!580 = !DILocation(line: 321, column: 26, scope: !533)
!581 = !DILocation(line: 325, column: 28, scope: !533)
!582 = !DILocation(line: 325, column: 26, scope: !533)
!583 = !DILocation(line: 331, column: 9, scope: !533)
!584 = !DILocation(line: 331, column: 15, scope: !533)
!585 = !DILocation(line: 331, column: 5, scope: !533)
!586 = !DILocation(line: 332, column: 22, scope: !533)
!587 = !DILocation(line: 334, column: 9, scope: !533)
!588 = !DILocation(line: 334, column: 18, scope: !533)
!589 = !DILocation(line: 334, column: 15, scope: !533)
!590 = !DILocation(line: 334, column: 5, scope: !533)
!591 = !DILocation(line: 335, column: 22, scope: !533)
!592 = !DILocation(line: 338, column: 52, scope: !533)
!593 = !DILocation(line: 338, column: 49, scope: !533)
!594 = !DILocation(line: 338, column: 5, scope: !533)
!595 = !DILocation(line: 339, column: 42, scope: !533)
!596 = !DILocation(line: 339, column: 48, scope: !533)
!597 = !DILocation(line: 339, column: 46, scope: !533)
!598 = !DILocation(line: 339, column: 33, scope: !533)
!599 = !DILocation(line: 339, column: 52, scope: !533)
!600 = !DILocation(line: 339, column: 51, scope: !533)
!601 = !DILocation(line: 339, column: 24, scope: !533)
!602 = !DILocation(line: 340, column: 25, scope: !533)
!603 = !DILocation(line: 340, column: 31, scope: !533)
!604 = !DILocation(line: 340, column: 29, scope: !533)
!605 = !DILocation(line: 340, column: 37, scope: !533)
!606 = !DILocation(line: 340, column: 41, scope: !533)
!607 = !DILocation(line: 340, column: 39, scope: !533)
!608 = !DILocation(line: 340, column: 35, scope: !533)
!609 = !DILocation(line: 341, column: 18, scope: !533)
!610 = !DILocation(line: 341, column: 15, scope: !533)
!611 = !DILocation(line: 341, column: 9, scope: !533)
!612 = !DILocation(line: 342, column: 26, scope: !533)
!613 = !DILocation(line: 347, column: 10, scope: !533)
!614 = !DILocation(line: 347, column: 16, scope: !533)
!615 = !DILocation(line: 347, column: 14, scope: !533)
!616 = !DILocation(line: 347, column: 5, scope: !533)
!617 = !DILocation(line: 348, column: 22, scope: !533)
!618 = !DILocation(line: 350, column: 10, scope: !533)
!619 = !DILocation(line: 350, column: 18, scope: !533)
!620 = !DILocation(line: 350, column: 21, scope: !533)
!621 = !DILocation(line: 350, column: 20, scope: !533)
!622 = !DILocation(line: 350, column: 14, scope: !533)
!623 = !DILocation(line: 350, column: 5, scope: !533)
!624 = !DILocation(line: 351, column: 22, scope: !533)
!625 = !DILocation(line: 354, column: 9, scope: !533)
!626 = !DILocation(line: 354, column: 5, scope: !533)
!627 = !DILocation(line: 358, column: 9, scope: !533)
!628 = !DILocation(line: 361, column: 9, scope: !533)
!629 = !DILocation(line: 364, column: 20, scope: !533)
!630 = !DILocation(line: 364, column: 17, scope: !533)
!631 = !DILocation(line: 364, column: 9, scope: !533)
!632 = !DILocation(line: 368, column: 13, scope: !533)
!633 = !DILocation(line: 371, column: 13, scope: !533)
!634 = !DILocation(line: 375, column: 13, scope: !533)
!635 = !DILocation(line: 394, column: 13, scope: !533)
!636 = !DILocation(line: 396, column: 29, scope: !533)
!637 = !DILocation(line: 396, column: 27, scope: !533)
!638 = !DILocation(line: 397, column: 60, scope: !533)
!639 = !DILocation(line: 397, column: 57, scope: !533)
!640 = !DILocation(line: 397, column: 13, scope: !533)
!641 = !DILocation(line: 400, column: 54, scope: !533)
!642 = !DILocation(line: 400, column: 55, scope: !533)
!643 = !DILocation(line: 400, column: 46, scope: !533)
!644 = !DILocation(line: 400, column: 59, scope: !533)
!645 = !DILocation(line: 400, column: 58, scope: !533)
!646 = !DILocation(line: 400, column: 37, scope: !533)
!647 = !DILocation(line: 400, column: 35, scope: !533)
!648 = !DILocation(line: 401, column: 33, scope: !533)
!649 = !DILocation(line: 401, column: 31, scope: !533)
!650 = !DILocation(line: 402, column: 69, scope: !533)
!651 = !DILocation(line: 402, column: 66, scope: !533)
!652 = !DILocation(line: 402, column: 19, scope: !533)
!653 = !DILocation(line: 404, column: 31, scope: !533)
!654 = !DILocation(line: 408, column: 75, scope: !533)
!655 = !DILocation(line: 408, column: 88, scope: !533)
!656 = !DILocation(line: 408, column: 13, scope: !533)
!657 = !DILocation(line: 413, column: 31, scope: !533)
!658 = !DILocation(line: 414, column: 33, scope: !533)
!659 = !DILocation(line: 415, column: 21, scope: !533)
!660 = !DILocation(line: 415, column: 29, scope: !533)
!661 = !DILocation(line: 415, column: 27, scope: !533)
!662 = !DILocation(line: 415, column: 19, scope: !533)
!663 = !DILocation(line: 416, column: 22, scope: !533)
!664 = !DILocation(line: 416, column: 19, scope: !533)
!665 = !DILocation(line: 416, column: 13, scope: !533)
!666 = !DILocation(line: 417, column: 23, scope: !533)
!667 = !DILocation(line: 419, column: 63, scope: !533)
!668 = !DILocation(line: 419, column: 60, scope: !533)
!669 = !DILocation(line: 419, column: 13, scope: !533)
!670 = !DILocation(line: 421, column: 23, scope: !533)
!671 = !DILocation(line: 423, column: 69, scope: !533)
!672 = !DILocation(line: 423, column: 13, scope: !533)
!673 = !DILocation(line: 426, column: 13, scope: !533)
!674 = !DILocation(line: 430, column: 13, scope: !533)
!675 = !DILocation(line: 433, column: 48, scope: !533)
!676 = !DILocation(line: 433, column: 22, scope: !533)
!677 = !DILocation(line: 433, column: 19, scope: !533)
!678 = !DILocation(line: 433, column: 13, scope: !533)
!679 = !DILocation(line: 436, column: 34, scope: !533)
!680 = !DILocation(line: 436, column: 39, scope: !533)
!681 = !DILocation(line: 436, column: 50, scope: !533)
!682 = !DILocation(line: 436, column: 17, scope: !533)
!683 = !DILocation(line: 452, column: 49, scope: !533)
!684 = !DILocation(line: 452, column: 64, scope: !533)
!685 = !DILocation(line: 452, column: 31, scope: !533)
!686 = !DILocation(line: 453, column: 40, scope: !533)
!687 = !DILocation(line: 453, column: 17, scope: !533)
!688 = !DILocation(line: 454, column: 50, scope: !533)
!689 = !DILocation(line: 454, column: 66, scope: !533)
!690 = !DILocation(line: 454, column: 32, scope: !533)
!691 = !DILocation(line: 455, column: 40, scope: !533)
!692 = !DILocation(line: 455, column: 17, scope: !533)
!693 = !DILocation(line: 456, column: 17, scope: !533)
!694 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit", scope: null, file: !695, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!695 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/filters/wse3.csl", directory: "")
!696 = !DILocation(line: 24, column: 3, scope: !697)
!697 = !DILexicalBlockFile(scope: !694, file: !695, discriminator: 0)
!698 = !DILocation(line: 24, column: 22, scope: !697)
!699 = !DILocation(line: 23, column: 3, scope: !697)
!700 = !DILocation(line: 22, column: 3, scope: !697)
!701 = !DILocation(line: 20, column: 37, scope: !697)
!702 = !DILocation(line: 20, column: 21, scope: !697)
!703 = !DILocation(line: 21, column: 11, scope: !697)
!704 = !DILocation(line: 21, column: 17, scope: !697)
!705 = !DILocation(line: 21, column: 3, scope: !697)
!706 = !DILocation(line: 22, column: 24, scope: !697)
!707 = !DILocation(line: 22, column: 30, scope: !697)
!708 = !DILocation(line: 23, column: 40, scope: !697)
!709 = !DILocation(line: 23, column: 22, scope: !697)
!710 = !DILocation(line: 23, column: 67, scope: !697)
!711 = !DILocation(line: 24, column: 26, scope: !697)
!712 = !DILocation(line: 24, column: 41, scope: !697)
!713 = !DILocation(line: 24, column: 39, scope: !697)
!714 = !DILocation(line: 24, column: 61, scope: !697)
!715 = !DILocation(line: 24, column: 76, scope: !697)
!716 = !DILocation(line: 24, column: 74, scope: !697)
!717 = !DILocation(line: 25, column: 21, scope: !697)
!718 = !DILocation(line: 25, column: 50, scope: !697)
!719 = !DILocation(line: 25, column: 3, scope: !697)
!720 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter", scope: null, file: !695, line: 30, type: !5, scopeLine: 30, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!721 = !DILocation(line: 30, column: 36, scope: !722)
!722 = !DILexicalBlockFile(scope: !720, file: !695, discriminator: 0)
!723 = !DILocation(line: 30, column: 20, scope: !722)
!724 = !DILocation(line: 31, column: 11, scope: !722)
!725 = !DILocation(line: 31, column: 23, scope: !722)
!726 = !DILocation(line: 31, column: 3, scope: !722)
!727 = !DILocation(line: 32, column: 21, scope: !722)
!728 = !DILocation(line: 32, column: 48, scope: !722)
!729 = !DILocation(line: 32, column: 60, scope: !722)
!730 = !DILocation(line: 32, column: 64, scope: !722)
!731 = !DILocation(line: 32, column: 3, scope: !722)
!732 = !DILocation(line: 30, column: 1, scope: !722)
!733 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter", scope: null, file: !695, line: 40, type: !5, scopeLine: 40, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!734 = !DILocation(line: 47, column: 3, scope: !735)
!735 = !DILexicalBlockFile(scope: !733, file: !695, discriminator: 0)
!736 = !DILocation(line: 48, column: 7, scope: !735)
!737 = !DILocation(line: 44, column: 3, scope: !735)
!738 = !DILocation(line: 43, column: 3, scope: !735)
!739 = !DILocation(line: 42, column: 3, scope: !735)
!740 = !DILocation(line: 40, column: 32, scope: !735)
!741 = !DILocation(line: 40, column: 16, scope: !735)
!742 = !DILocation(line: 41, column: 11, scope: !735)
!743 = !DILocation(line: 41, column: 19, scope: !735)
!744 = !DILocation(line: 41, column: 3, scope: !735)
!745 = !DILocation(line: 42, column: 40, scope: !735)
!746 = !DILocation(line: 42, column: 22, scope: !735)
!747 = !DILocation(line: 43, column: 26, scope: !735)
!748 = !DILocation(line: 43, column: 34, scope: !735)
!749 = !DILocation(line: 44, column: 25, scope: !735)
!750 = !DILocation(line: 44, column: 42, scope: !735)
!751 = !DILocation(line: 44, column: 40, scope: !735)
!752 = !DILocation(line: 45, column: 21, scope: !735)
!753 = !DILocation(line: 46, column: 35, scope: !735)
!754 = !DILocation(line: 46, column: 21, scope: !735)
!755 = !DILocation(line: 46, column: 50, scope: !735)
!756 = !DILocation(line: 45, column: 3, scope: !735)
!757 = !DILocation(line: 48, column: 11, scope: !735)
!758 = !DILocation(line: 48, column: 26, scope: !735)
!759 = !DILocation(line: 48, column: 43, scope: !735)
!760 = !DILocation(line: 48, column: 41, scope: !735)
!761 = !DILocation(line: 48, column: 54, scope: !735)
!762 = !DILocation(line: 48, column: 63, scope: !735)
!763 = !DILocation(line: 49, column: 21, scope: !735)
!764 = !DILocation(line: 49, column: 47, scope: !735)
!765 = !DILocation(line: 49, column: 3, scope: !735)
!766 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config", scope: null, file: !767, line: 33, type: !5, scopeLine: 33, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!767 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/filters/common.csl", directory: "")
!768 = !DILocation(line: 33, column: 46, scope: !769)
!769 = !DILexicalBlockFile(scope: !766, file: !767, discriminator: 0)
!770 = !DILocation(line: 33, column: 31, scope: !769)
!771 = !DILocation(line: 33, column: 15, scope: !769)
!772 = !DILocation(line: 34, column: 24, scope: !769)
!773 = !DILocation(line: 34, column: 23, scope: !769)
!774 = !DILocation(line: 34, column: 51, scope: !769)
!775 = !DILocation(line: 34, column: 35, scope: !769)
!776 = !DILocation(line: 34, column: 60, scope: !769)
!777 = !DILocation(line: 34, column: 73, scope: !769)
!778 = !DILocation(line: 34, column: 3, scope: !769)
!779 = !DILocation(line: 33, column: 1, scope: !769)
!780 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config", scope: null, file: !767, line: 38, type: !5, scopeLine: 38, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!781 = !DILocation(line: 38, column: 31, scope: !782)
!782 = !DILexicalBlockFile(scope: !780, file: !767, discriminator: 0)
!783 = !DILocation(line: 38, column: 15, scope: !782)
!784 = !DILocation(line: 39, column: 31, scope: !782)
!785 = !DILocation(line: 39, column: 30, scope: !782)
!786 = !DILocation(line: 39, column: 58, scope: !782)
!787 = !DILocation(line: 39, column: 42, scope: !782)
!788 = !DILocation(line: 39, column: 67, scope: !782)
!789 = !DILocation(line: 39, column: 10, scope: !782)
!790 = !DILocation(line: 39, column: 3, scope: !782)
!791 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit", scope: null, file: !792, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!792 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/teardown.csl", directory: "")
!793 = !DILocation(line: 43, column: 3, scope: !794)
!794 = !DILexicalBlockFile(scope: !791, file: !792, discriminator: 0)
!795 = !DILocation(line: 41, column: 3, scope: !794)
!796 = !DILocation(line: 40, column: 3, scope: !794)
!797 = !DILocation(line: 39, column: 9, scope: !794)
!798 = !DILocation(line: 40, column: 23, scope: !794)
!799 = !DILocation(line: 41, column: 70, scope: !794)
!800 = !DILocation(line: 41, column: 68, scope: !794)
!801 = !DILocation(line: 43, column: 27, scope: !794)
!802 = !DILocation(line: 43, column: 15, scope: !794)
!803 = !DILocation(line: 44, column: 15, scope: !794)
!804 = !DILocation(line: 44, column: 21, scope: !794)
!805 = !DILocation(line: 44, column: 27, scope: !794)
!806 = !DILocation(line: 44, column: 3, scope: !794)
!807 = !DILocation(line: 39, column: 1, scope: !794)
!808 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord", scope: null, file: !809, line: 4, type: !5, scopeLine: 4, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!809 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/layout.csl", directory: "")
!810 = !DILocation(line: 5, column: 10, scope: !811)
!811 = !DILexicalBlockFile(scope: !808, file: !809, discriminator: 0)
!812 = !DILocation(line: 5, column: 67, scope: !811)
!813 = !DILocation(line: 5, column: 3, scope: !811)
!814 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord", scope: null, file: !809, line: 8, type: !5, scopeLine: 8, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!815 = !DILocation(line: 9, column: 10, scope: !816)
!816 = !DILexicalBlockFile(scope: !814, file: !809, discriminator: 0)
!817 = !DILocation(line: 9, column: 67, scope: !816)
!818 = !DILocation(line: 9, column: 3, scope: !816)
!819 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord", scope: null, file: !820, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!820 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config.csl", directory: "")
!821 = !DILocation(line: 50, column: 3, scope: !822)
!822 = !DILexicalBlockFile(scope: !819, file: !820, discriminator: 0)
!823 = !DILocation(line: 43, column: 21, scope: !822)
!824 = !DILocation(line: 50, column: 57, scope: !822)
!825 = !DILocation(line: 50, column: 68, scope: !822)
!826 = !DILocation(line: 50, column: 41, scope: !822)
!827 = !DILocation(line: 50, column: 19, scope: !822)
!828 = !DILocation(line: 52, column: 10, scope: !822)
!829 = !DILocation(line: 52, column: 18, scope: !822)
!830 = !DILocation(line: 48, column: 22, scope: !822)
!831 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.get_x_coord", scope: null, file: !832, line: 171, type: !5, scopeLine: 171, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!832 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpyd2h.csl", directory: "")
!833 = !DILocation(line: 172, column: 12, scope: !834)
!834 = !DILexicalBlockFile(scope: !831, file: !832, discriminator: 0)
!835 = !DILocation(line: 172, column: 5, scope: !834)
!836 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.get_y_coord", scope: null, file: !832, line: 174, type: !5, scopeLine: 174, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!837 = !DILocation(line: 175, column: 12, scope: !838)
!838 = !DILexicalBlockFile(scope: !836, file: !832, discriminator: 0)
!839 = !DILocation(line: 175, column: 5, scope: !838)
!840 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval", scope: null, file: !832, line: 187, type: !5, scopeLine: 187, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!841 = !DILocation(line: 187, column: 23, scope: !842)
!842 = !DILexicalBlockFile(scope: !840, file: !832, discriminator: 0)
!843 = !DILocation(line: 188, column: 9, scope: !842)
!844 = !DILocation(line: 188, column: 20, scope: !842)
!845 = !DILocation(line: 188, column: 5, scope: !842)
!846 = !DILocation(line: 191, column: 23, scope: !842)
!847 = !DILocation(line: 191, column: 20, scope: !842)
!848 = !DILocation(line: 191, column: 9, scope: !842)
!849 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start", scope: null, file: !832, line: 383, type: !5, scopeLine: 383, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!850 = !DILocation(line: 386, column: 5, scope: !851)
!851 = !DILexicalBlockFile(scope: !849, file: !832, discriminator: 0)
!852 = !DILocation(line: 384, column: 72, scope: !851)
!853 = !DILocation(line: 384, column: 59, scope: !851)
!854 = !DILocation(line: 384, column: 46, scope: !851)
!855 = !DILocation(line: 384, column: 33, scope: !851)
!856 = !DILocation(line: 384, column: 19, scope: !851)
!857 = !DILocation(line: 384, column: 5, scope: !851)
!858 = !DILocation(line: 383, column: 32, scope: !851)
!859 = !DILocation(line: 383, column: 21, scope: !851)
!860 = !DILocation(line: 386, column: 26, scope: !851)
!861 = !DILocation(line: 388, column: 28, scope: !851)
!862 = !DILocation(line: 388, column: 17, scope: !851)
!863 = !DILocation(line: 389, column: 25, scope: !851)
!864 = !DILocation(line: 389, column: 23, scope: !851)
!865 = !DILocation(line: 391, column: 38, scope: !851)
!866 = !DILocation(line: 391, column: 20, scope: !851)
!867 = !DILocation(line: 391, column: 18, scope: !851)
!868 = !DILocation(line: 393, column: 7, scope: !851)
!869 = !DILocation(line: 395, column: 17, scope: !851)
!870 = !DILocation(line: 395, column: 15, scope: !851)
!871 = !DILocation(line: 397, column: 15, scope: !851)
!872 = !DILocation(line: 397, column: 13, scope: !851)
!873 = !DILocation(line: 398, column: 15, scope: !851)
!874 = !DILocation(line: 398, column: 25, scope: !851)
!875 = !DILocation(line: 398, column: 23, scope: !851)
!876 = !DILocation(line: 398, column: 31, scope: !851)
!877 = !DILocation(line: 398, column: 13, scope: !851)
!878 = !DILocation(line: 401, column: 10, scope: !851)
!879 = !DILocation(line: 401, column: 17, scope: !851)
!880 = !DILocation(line: 401, column: 14, scope: !851)
!881 = !DILocation(line: 401, column: 5, scope: !851)
!882 = !DILocation(line: 403, column: 48, scope: !851)
!883 = !DILocation(line: 403, column: 26, scope: !851)
!884 = !DILocation(line: 404, column: 26, scope: !851)
!885 = !DILocation(line: 404, column: 18, scope: !851)
!886 = !DILocation(line: 407, column: 48, scope: !851)
!887 = !DILocation(line: 407, column: 26, scope: !851)
!888 = !DILocation(line: 408, column: 27, scope: !851)
!889 = !DILocation(line: 408, column: 18, scope: !851)
!890 = !DILocation(line: 411, column: 14, scope: !851)
!891 = !DILocation(line: 414, column: 14, scope: !851)
!892 = !DILocation(line: 414, column: 11, scope: !851)
!893 = !DILocation(line: 414, column: 5, scope: !851)
!894 = !DILocation(line: 416, column: 44, scope: !851)
!895 = !DILocation(line: 416, column: 75, scope: !851)
!896 = !DILocation(line: 416, column: 59, scope: !851)
!897 = !DILocation(line: 416, column: 25, scope: !851)
!898 = !DILocation(line: 416, column: 23, scope: !851)
!899 = !DILocation(line: 418, column: 41, scope: !851)
!900 = !DILocation(line: 418, column: 23, scope: !851)
!901 = !DILocation(line: 419, column: 9, scope: !851)
!902 = !DILocation(line: 425, column: 44, scope: !851)
!903 = !DILocation(line: 425, column: 23, scope: !851)
!904 = !DILocation(line: 426, column: 41, scope: !851)
!905 = !DILocation(line: 426, column: 23, scope: !851)
!906 = !DILocation(line: 427, column: 9, scope: !851)
!907 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x", scope: null, file: !832, line: 448, type: !5, scopeLine: 448, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!908 = !DILocation(line: 448, column: 31, scope: !909)
!909 = !DILexicalBlockFile(scope: !907, file: !832, discriminator: 0)
!910 = !DILocation(line: 453, column: 5, scope: !909)
!911 = !DILocation(line: 456, column: 19, scope: !909)
!912 = !DILocation(line: 456, column: 17, scope: !909)
!913 = !DILocation(line: 461, column: 5, scope: !909)
!914 = !DILocation(line: 462, column: 28, scope: !909)
!915 = !DILocation(line: 462, column: 5, scope: !909)
!916 = !DILocation(line: 463, column: 5, scope: !909)
!917 = !DILocation(line: 464, column: 9, scope: !909)
!918 = !DILocation(line: 464, column: 10, scope: !909)
!919 = !DILocation(line: 464, column: 7, scope: !909)
!920 = !DILocation(line: 448, column: 1, scope: !909)
!921 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_send_data", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_send_data", scope: null, file: !832, line: 476, type: !5, scopeLine: 476, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!922 = !DILocation(line: 494, column: 9, scope: !923)
!923 = !DILexicalBlockFile(scope: !921, file: !832, discriminator: 0)
!924 = !DILocation(line: 478, column: 9, scope: !923)
!925 = !DILocation(line: 478, column: 13, scope: !923)
!926 = !DILocation(line: 478, column: 11, scope: !923)
!927 = !DILocation(line: 478, column: 5, scope: !923)
!928 = !DILocation(line: 479, column: 9, scope: !923)
!929 = !DILocation(line: 480, column: 32, scope: !923)
!930 = !DILocation(line: 480, column: 9, scope: !923)
!931 = !DILocation(line: 481, column: 17, scope: !923)
!932 = !DILocation(line: 481, column: 15, scope: !923)
!933 = !DILocation(line: 481, column: 9, scope: !923)
!934 = !DILocation(line: 482, column: 13, scope: !923)
!935 = !DILocation(line: 483, column: 51, scope: !923)
!936 = !DILocation(line: 483, column: 29, scope: !923)
!937 = !DILocation(line: 483, column: 27, scope: !923)
!938 = !DILocation(line: 485, column: 13, scope: !923)
!939 = !DILocation(line: 486, column: 51, scope: !923)
!940 = !DILocation(line: 486, column: 29, scope: !923)
!941 = !DILocation(line: 486, column: 27, scope: !923)
!942 = !DILocation(line: 488, column: 13, scope: !923)
!943 = !DILocation(line: 488, column: 14, scope: !923)
!944 = !DILocation(line: 488, column: 11, scope: !923)
!945 = !DILocation(line: 494, column: 30, scope: !923)
!946 = !DILocation(line: 496, column: 14, scope: !923)
!947 = !DILocation(line: 496, column: 25, scope: !923)
!948 = !DILocation(line: 496, column: 22, scope: !923)
!949 = !DILocation(line: 496, column: 9, scope: !923)
!950 = !DILocation(line: 497, column: 13, scope: !923)
!951 = !DILocation(line: 498, column: 13, scope: !923)
!952 = !DILocation(line: 499, column: 13, scope: !923)
!953 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl", scope: null, file: !832, line: 505, type: !5, scopeLine: 505, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!954 = !DILocation(line: 524, column: 13, scope: !955)
!955 = !DILexicalBlockFile(scope: !953, file: !832, discriminator: 0)
!956 = !DILocation(line: 506, column: 14, scope: !955)
!957 = !DILocation(line: 506, column: 11, scope: !955)
!958 = !DILocation(line: 506, column: 5, scope: !955)
!959 = !DILocation(line: 508, column: 9, scope: !955)
!960 = !DILocation(line: 509, column: 32, scope: !955)
!961 = !DILocation(line: 509, column: 9, scope: !955)
!962 = !DILocation(line: 510, column: 9, scope: !955)
!963 = !DILocation(line: 514, column: 13, scope: !955)
!964 = !DILocation(line: 514, column: 17, scope: !955)
!965 = !DILocation(line: 514, column: 15, scope: !955)
!966 = !DILocation(line: 514, column: 9, scope: !955)
!967 = !DILocation(line: 518, column: 13, scope: !955)
!968 = !DILocation(line: 519, column: 36, scope: !955)
!969 = !DILocation(line: 519, column: 13, scope: !955)
!970 = !DILocation(line: 520, column: 13, scope: !955)
!971 = !DILocation(line: 524, column: 34, scope: !955)
!972 = !DILocation(line: 526, column: 18, scope: !955)
!973 = !DILocation(line: 526, column: 29, scope: !955)
!974 = !DILocation(line: 526, column: 26, scope: !955)
!975 = !DILocation(line: 526, column: 13, scope: !955)
!976 = !DILocation(line: 529, column: 17, scope: !955)
!977 = !DILocation(line: 530, column: 17, scope: !955)
!978 = !DILocation(line: 531, column: 17, scope: !955)
!979 = !DILocation(line: 534, column: 17, scope: !955)
!980 = !DILocation(line: 535, column: 40, scope: !955)
!981 = !DILocation(line: 535, column: 17, scope: !955)
!982 = !DILocation(line: 536, column: 17, scope: !955)
!983 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.d2h_configure", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.d2h_configure", scope: null, file: !832, line: 593, type: !5, scopeLine: 593, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!984 = !DILocation(line: 617, column: 26, scope: !985)
!985 = !DILexicalBlockFile(scope: !983, file: !832, discriminator: 0)
!986 = !DILocation(line: 612, column: 47, scope: !985)
!987 = !DILocation(line: 612, column: 27, scope: !985)
!988 = !DILocation(line: 602, column: 5, scope: !985)
!989 = !DILocation(line: 601, column: 5, scope: !985)
!990 = !DILocation(line: 599, column: 5, scope: !985)
!991 = !DILocation(line: 598, column: 5, scope: !985)
!992 = !DILocation(line: 596, column: 5, scope: !985)
!993 = !DILocation(line: 595, column: 5, scope: !985)
!994 = !DILocation(line: 593, column: 86, scope: !985)
!995 = !DILocation(line: 593, column: 70, scope: !985)
!996 = !DILocation(line: 593, column: 60, scope: !985)
!997 = !DILocation(line: 593, column: 52, scope: !985)
!998 = !DILocation(line: 593, column: 44, scope: !985)
!999 = !DILocation(line: 593, column: 35, scope: !985)
!1000 = !DILocation(line: 593, column: 26, scope: !985)
!1001 = !DILocation(line: 593, column: 18, scope: !985)
!1002 = !DILocation(line: 595, column: 26, scope: !985)
!1003 = !DILocation(line: 596, column: 26, scope: !985)
!1004 = !DILocation(line: 598, column: 23, scope: !985)
!1005 = !DILocation(line: 599, column: 23, scope: !985)
!1006 = !DILocation(line: 599, column: 28, scope: !985)
!1007 = !DILocation(line: 599, column: 26, scope: !985)
!1008 = !DILocation(line: 599, column: 29, scope: !985)
!1009 = !DILocation(line: 601, column: 24, scope: !985)
!1010 = !DILocation(line: 602, column: 24, scope: !985)
!1011 = !DILocation(line: 602, column: 29, scope: !985)
!1012 = !DILocation(line: 602, column: 27, scope: !985)
!1013 = !DILocation(line: 602, column: 30, scope: !985)
!1014 = !DILocation(line: 611, column: 20, scope: !985)
!1015 = !DILocation(line: 612, column: 11, scope: !985)
!1016 = !DILocation(line: 612, column: 18, scope: !985)
!1017 = !DILocation(line: 612, column: 15, scope: !985)
!1018 = !DILocation(line: 612, column: 32, scope: !985)
!1019 = !DILocation(line: 612, column: 39, scope: !985)
!1020 = !DILocation(line: 612, column: 36, scope: !985)
!1021 = !DILocation(line: 612, column: 52, scope: !985)
!1022 = !DILocation(line: 612, column: 59, scope: !985)
!1023 = !DILocation(line: 612, column: 56, scope: !985)
!1024 = !DILocation(line: 612, column: 5, scope: !985)
!1025 = !DILocation(line: 613, column: 24, scope: !985)
!1026 = !DILocation(line: 616, column: 15, scope: !985)
!1027 = !DILocation(line: 617, column: 11, scope: !985)
!1028 = !DILocation(line: 617, column: 18, scope: !985)
!1029 = !DILocation(line: 617, column: 15, scope: !985)
!1030 = !DILocation(line: 617, column: 30, scope: !985)
!1031 = !DILocation(line: 617, column: 5, scope: !985)
!1032 = !DILocation(line: 618, column: 19, scope: !985)
!1033 = !DILocation(line: 621, column: 9, scope: !985)
!1034 = !DILocation(line: 621, column: 5, scope: !985)
!1035 = !DILocation(line: 627, column: 9, scope: !985)
!1036 = !DILocation(line: 629, column: 13, scope: !985)
!1037 = !DILocation(line: 629, column: 25, scope: !985)
!1038 = !DILocation(line: 629, column: 21, scope: !985)
!1039 = !DILocation(line: 629, column: 9, scope: !985)
!1040 = !DILocation(line: 632, column: 13, scope: !985)
!1041 = !DILocation(line: 636, column: 13, scope: !985)
!1042 = !DILocation(line: 641, column: 9, scope: !985)
!1043 = !DILocation(line: 646, column: 13, scope: !985)
!1044 = !DILocation(line: 646, column: 9, scope: !985)
!1045 = !DILocation(line: 647, column: 30, scope: !985)
!1046 = !DILocation(line: 647, column: 35, scope: !985)
!1047 = !DILocation(line: 647, column: 46, scope: !985)
!1048 = !DILocation(line: 647, column: 50, scope: !985)
!1049 = !DILocation(line: 647, column: 54, scope: !985)
!1050 = !DILocation(line: 647, column: 57, scope: !985)
!1051 = !DILocation(line: 647, column: 60, scope: !985)
!1052 = !DILocation(line: 647, column: 63, scope: !985)
!1053 = !DILocation(line: 647, column: 13, scope: !985)
!1054 = !DILocation(line: 661, column: 9, scope: !985)
!1055 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit", scope: null, file: !792, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1056 = !DILocation(line: 43, column: 3, scope: !1057)
!1057 = !DILexicalBlockFile(scope: !1055, file: !792, discriminator: 0)
!1058 = !DILocation(line: 41, column: 3, scope: !1057)
!1059 = !DILocation(line: 40, column: 3, scope: !1057)
!1060 = !DILocation(line: 39, column: 9, scope: !1057)
!1061 = !DILocation(line: 40, column: 23, scope: !1057)
!1062 = !DILocation(line: 41, column: 70, scope: !1057)
!1063 = !DILocation(line: 41, column: 68, scope: !1057)
!1064 = !DILocation(line: 43, column: 27, scope: !1057)
!1065 = !DILocation(line: 43, column: 15, scope: !1057)
!1066 = !DILocation(line: 44, column: 15, scope: !1057)
!1067 = !DILocation(line: 44, column: 21, scope: !1057)
!1068 = !DILocation(line: 44, column: 27, scope: !1057)
!1069 = !DILocation(line: 44, column: 3, scope: !1057)
!1070 = !DILocation(line: 39, column: 1, scope: !1057)
!1071 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord", scope: null, file: !809, line: 4, type: !5, scopeLine: 4, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1072 = !DILocation(line: 5, column: 10, scope: !1073)
!1073 = !DILexicalBlockFile(scope: !1071, file: !809, discriminator: 0)
!1074 = !DILocation(line: 5, column: 67, scope: !1073)
!1075 = !DILocation(line: 5, column: 3, scope: !1073)
!1076 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord", scope: null, file: !809, line: 8, type: !5, scopeLine: 8, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1077 = !DILocation(line: 9, column: 10, scope: !1078)
!1078 = !DILexicalBlockFile(scope: !1076, file: !809, discriminator: 0)
!1079 = !DILocation(line: 9, column: 67, scope: !1078)
!1080 = !DILocation(line: 9, column: 3, scope: !1078)
!1081 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord", scope: null, file: !820, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1082 = !DILocation(line: 50, column: 3, scope: !1083)
!1083 = !DILexicalBlockFile(scope: !1081, file: !820, discriminator: 0)
!1084 = !DILocation(line: 43, column: 21, scope: !1083)
!1085 = !DILocation(line: 50, column: 57, scope: !1083)
!1086 = !DILocation(line: 50, column: 68, scope: !1083)
!1087 = !DILocation(line: 50, column: 41, scope: !1083)
!1088 = !DILocation(line: 50, column: 19, scope: !1083)
!1089 = !DILocation(line: 52, column: 10, scope: !1083)
!1090 = !DILocation(line: 52, column: 18, scope: !1083)
!1091 = !DILocation(line: 48, column: 22, scope: !1083)
!1092 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr", linkageName: "sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr", scope: null, file: !1093, line: 11, type: !5, scopeLine: 11, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1093 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/input_queue_config.csl", directory: "")
!1094 = !DILocation(line: 11, column: 32, scope: !1095)
!1095 = !DILexicalBlockFile(scope: !1092, file: !1093, discriminator: 0)
!1096 = !DILocation(line: 12, column: 80, scope: !1095)
!1097 = !DILocation(line: 12, column: 69, scope: !1095)
!1098 = !DILocation(line: 12, column: 39, scope: !1095)
!1099 = !DILocation(line: 12, column: 3, scope: !1095)
!1100 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue", linkageName: "sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue", scope: null, file: !1093, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1101 = !DILocation(line: 46, column: 3, scope: !1102)
!1102 = !DILexicalBlockFile(scope: !1100, file: !1093, discriminator: 0)
!1103 = !DILocation(line: 45, column: 3, scope: !1102)
!1104 = !DILocation(line: 39, column: 42, scope: !1102)
!1105 = !DILocation(line: 39, column: 34, scope: !1102)
!1106 = !DILocation(line: 39, column: 24, scope: !1102)
!1107 = !DILocation(line: 45, column: 44, scope: !1102)
!1108 = !DILocation(line: 45, column: 16, scope: !1102)
!1109 = !DILocation(line: 46, column: 30, scope: !1102)
!1110 = !DILocation(line: 46, column: 18, scope: !1102)
!1111 = !DILocation(line: 56, column: 9, scope: !1102)
!1112 = !DILocation(line: 56, column: 5, scope: !1102)
!1113 = !DILocation(line: 58, column: 13, scope: !1102)
!1114 = !DILocation(line: 58, column: 17, scope: !1102)
!1115 = !DILocation(line: 58, column: 11, scope: !1102)
!1116 = !DILocation(line: 61, column: 13, scope: !1102)
!1117 = !DILocation(line: 61, column: 17, scope: !1102)
!1118 = !DILocation(line: 61, column: 11, scope: !1102)
!1119 = !DILocation(line: 66, column: 9, scope: !1102)
!1120 = !DILocation(line: 66, column: 13, scope: !1102)
!1121 = !DILocation(line: 66, column: 7, scope: !1102)
!1122 = !DILocation(line: 68, column: 9, scope: !1102)
!1123 = !DILocation(line: 68, column: 24, scope: !1102)
!1124 = !DILocation(line: 68, column: 13, scope: !1102)
!1125 = !DILocation(line: 68, column: 7, scope: !1102)
!1126 = !DILocation(line: 70, column: 15, scope: !1102)
!1127 = !DILocation(line: 70, column: 21, scope: !1102)
!1128 = !DILocation(line: 70, column: 3, scope: !1102)
!1129 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr", linkageName: "sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr", scope: null, file: !1130, line: 11, type: !5, scopeLine: 11, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1130 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/output_queue_config.csl", directory: "")
!1131 = !DILocation(line: 11, column: 33, scope: !1132)
!1132 = !DILexicalBlockFile(scope: !1129, file: !1130, discriminator: 0)
!1133 = !DILocation(line: 12, column: 82, scope: !1132)
!1134 = !DILocation(line: 12, column: 40, scope: !1132)
!1135 = !DILocation(line: 12, column: 3, scope: !1132)
!1136 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue", linkageName: "sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue", scope: null, file: !1130, line: 31, type: !5, scopeLine: 31, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1137 = !DILocation(line: 38, column: 3, scope: !1138)
!1138 = !DILexicalBlockFile(scope: !1136, file: !1130, discriminator: 0)
!1139 = !DILocation(line: 37, column: 3, scope: !1138)
!1140 = !DILocation(line: 31, column: 35, scope: !1138)
!1141 = !DILocation(line: 31, column: 25, scope: !1138)
!1142 = !DILocation(line: 37, column: 45, scope: !1138)
!1143 = !DILocation(line: 37, column: 16, scope: !1138)
!1144 = !DILocation(line: 38, column: 30, scope: !1138)
!1145 = !DILocation(line: 38, column: 18, scope: !1138)
!1146 = !DILocation(line: 41, column: 9, scope: !1138)
!1147 = !DILocation(line: 41, column: 13, scope: !1138)
!1148 = !DILocation(line: 41, column: 7, scope: !1138)
!1149 = !DILocation(line: 43, column: 9, scope: !1138)
!1150 = !DILocation(line: 43, column: 24, scope: !1138)
!1151 = !DILocation(line: 43, column: 13, scope: !1138)
!1152 = !DILocation(line: 43, column: 27, scope: !1138)
!1153 = !DILocation(line: 43, column: 7, scope: !1138)
!1154 = !DILocation(line: 45, column: 15, scope: !1138)
!1155 = !DILocation(line: 45, column: 21, scope: !1138)
!1156 = !DILocation(line: 45, column: 3, scope: !1138)
!1157 = !DILocation(line: 31, column: 1, scope: !1138)
!1158 = distinct !DISubprogram(name: ".get_tensor_ptr", linkageName: ".get_tensor_ptr", scope: null, file: !4, line: 1, type: !5, scopeLine: 1, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1159 = !DILocation(line: 1, column: 1, scope: !1160)
!1160 = !DILexicalBlockFile(scope: !1158, file: !4, discriminator: 0)
!1161 = distinct !DISubprogram(name: "__generic0sys_mod.sys_mod.tile_config.queue_flush.exit", linkageName: "__generic0sys_mod.sys_mod.tile_config.queue_flush.exit", scope: null, file: !1162, line: 12, type: !5, scopeLine: 12, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1162 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/queue_flush.csl", directory: "")
!1163 = !DILocation(line: 24, column: 3, scope: !1164)
!1164 = !DILexicalBlockFile(scope: !1161, file: !1162, discriminator: 0)
!1165 = !DILocation(line: 12, column: 1, scope: !1164)
!1166 = distinct !DISubprogram(name: "__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position", linkageName: "__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position", scope: null, file: !1167, line: 30, type: !5, scopeLine: 30, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1167 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/switch_config.csl", directory: "")
!1168 = !DILocation(line: 34, column: 3, scope: !1169)
!1169 = !DILexicalBlockFile(scope: !1166, file: !1167, discriminator: 0)
!1170 = !DILocation(line: 32, column: 3, scope: !1169)
!1171 = !DILocation(line: 30, column: 27, scope: !1169)
!1172 = !DILocation(line: 33, column: 7, scope: !1169)
!1173 = !DILocation(line: 34, column: 36, scope: !1169)
!1174 = !DILocation(line: 34, column: 24, scope: !1169)
!1175 = !DILocation(line: 35, column: 3, scope: !1169)
!1176 = !DILocation(line: 35, column: 18, scope: !1169)
!1177 = !DILocation(line: 36, column: 15, scope: !1169)
!1178 = !DILocation(line: 36, column: 21, scope: !1169)
!1179 = !DILocation(line: 36, column: 3, scope: !1169)
!1180 = !DILocation(line: 30, column: 1, scope: !1169)
!1181 = distinct !DISubprogram(name: "__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", linkageName: "__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", scope: null, file: !1182, line: 96, type: !5, scopeLine: 96, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1182 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/color_config.csl", directory: "")
!1183 = !DILocation(line: 99, column: 3, scope: !1184)
!1184 = !DILexicalBlockFile(scope: !1181, file: !1182, discriminator: 0)
!1185 = !DILocation(line: 98, column: 3, scope: !1184)
!1186 = !DILocation(line: 96, column: 17, scope: !1184)
!1187 = !DILocation(line: 98, column: 16, scope: !1184)
!1188 = !DILocation(line: 99, column: 29, scope: !1184)
!1189 = !DILocation(line: 99, column: 17, scope: !1184)
!1190 = !DILocation(line: 100, column: 13, scope: !1184)
!1191 = !DILocation(line: 100, column: 21, scope: !1184)
!1192 = !DILocation(line: 100, column: 11, scope: !1184)
!1193 = !DILocation(line: 104, column: 7, scope: !1184)
!1194 = !DILocation(line: 104, column: 50, scope: !1184)
!1195 = !DILocation(line: 104, column: 18, scope: !1184)
!1196 = !DILocation(line: 104, column: 15, scope: !1184)
!1197 = !DILocation(line: 121, column: 7, scope: !1184)
!1198 = !DILocation(line: 121, column: 50, scope: !1184)
!1199 = !DILocation(line: 121, column: 18, scope: !1184)
!1200 = !DILocation(line: 121, column: 15, scope: !1184)
!1201 = !DILocation(line: 128, column: 15, scope: !1184)
!1202 = !DILocation(line: 128, column: 21, scope: !1184)
!1203 = !DILocation(line: 128, column: 3, scope: !1184)
!1204 = !DILocation(line: 96, column: 1, scope: !1184)
!1205 = distinct !DISubprogram(name: "__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", linkageName: "__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", scope: null, file: !1182, line: 96, type: !5, scopeLine: 96, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1206 = !DILocation(line: 99, column: 3, scope: !1207)
!1207 = !DILexicalBlockFile(scope: !1205, file: !1182, discriminator: 0)
!1208 = !DILocation(line: 98, column: 3, scope: !1207)
!1209 = !DILocation(line: 96, column: 17, scope: !1207)
!1210 = !DILocation(line: 98, column: 16, scope: !1207)
!1211 = !DILocation(line: 99, column: 29, scope: !1207)
!1212 = !DILocation(line: 99, column: 17, scope: !1207)
!1213 = !DILocation(line: 100, column: 13, scope: !1207)
!1214 = !DILocation(line: 100, column: 21, scope: !1207)
!1215 = !DILocation(line: 100, column: 11, scope: !1207)
!1216 = !DILocation(line: 104, column: 7, scope: !1207)
!1217 = !DILocation(line: 104, column: 50, scope: !1207)
!1218 = !DILocation(line: 104, column: 18, scope: !1207)
!1219 = !DILocation(line: 104, column: 15, scope: !1207)
!1220 = !DILocation(line: 121, column: 7, scope: !1207)
!1221 = !DILocation(line: 121, column: 50, scope: !1207)
!1222 = !DILocation(line: 121, column: 18, scope: !1207)
!1223 = !DILocation(line: 121, column: 15, scope: !1207)
!1224 = !DILocation(line: 128, column: 15, scope: !1207)
!1225 = !DILocation(line: 128, column: 21, scope: !1207)
!1226 = !DILocation(line: 128, column: 3, scope: !1207)
!1227 = !DILocation(line: 96, column: 1, scope: !1207)
!1228 = distinct !DISubprogram(name: "__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", linkageName: "__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", scope: null, file: !1182, line: 60, type: !5, scopeLine: 60, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1229 = !DILocation(line: 61, column: 3, scope: !1230)
!1230 = !DILexicalBlockFile(scope: !1228, file: !1182, discriminator: 0)
!1231 = !DILocation(line: 60, column: 46, scope: !1230)
!1232 = !DILocation(line: 61, column: 16, scope: !1230)
!1233 = !DILocation(line: 72, column: 5, scope: !1230)
!1234 = !DILocation(line: 72, column: 12, scope: !1230)
!1235 = !DILocation(line: 74, column: 10, scope: !1230)
!1236 = !DILocation(line: 74, column: 3, scope: !1230)
!1237 = distinct !DISubprogram(name: "__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes", linkageName: "__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes", scope: null, file: !1182, line: 77, type: !5, scopeLine: 77, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1238 = !DILocation(line: 78, column: 3, scope: !1239)
!1239 = !DILexicalBlockFile(scope: !1237, file: !1182, discriminator: 0)
!1240 = !DILocation(line: 77, column: 46, scope: !1239)
!1241 = !DILocation(line: 78, column: 16, scope: !1239)
!1242 = !DILocation(line: 86, column: 5, scope: !1239)
!1243 = !DILocation(line: 86, column: 12, scope: !1239)
!1244 = !DILocation(line: 91, column: 10, scope: !1239)
!1245 = !DILocation(line: 91, column: 3, scope: !1239)
!1246 = distinct !DISubprogram(name: "__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", linkageName: "__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", scope: null, file: !1182, line: 60, type: !5, scopeLine: 60, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1247 = !DILocation(line: 61, column: 3, scope: !1248)
!1248 = !DILexicalBlockFile(scope: !1246, file: !1182, discriminator: 0)
!1249 = !DILocation(line: 60, column: 46, scope: !1248)
!1250 = !DILocation(line: 61, column: 16, scope: !1248)
!1251 = !DILocation(line: 63, column: 5, scope: !1248)
!1252 = !DILocation(line: 63, column: 12, scope: !1248)
!1253 = !DILocation(line: 74, column: 10, scope: !1248)
!1254 = !DILocation(line: 74, column: 3, scope: !1248)
!1255 = distinct !DISubprogram(name: "__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction", linkageName: "__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction", scope: null, file: !1182, line: 52, type: !5, scopeLine: 52, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1256 = !DILocation(line: 55, column: 3, scope: !1257)
!1257 = !DILexicalBlockFile(scope: !1255, file: !1182, discriminator: 0)
!1258 = !DILocation(line: 54, column: 3, scope: !1257)
!1259 = !DILocation(line: 52, column: 23, scope: !1257)
!1260 = !DILocation(line: 54, column: 16, scope: !1257)
!1261 = !DILocation(line: 55, column: 29, scope: !1257)
!1262 = !DILocation(line: 55, column: 17, scope: !1257)
!1263 = !DILocation(line: 56, column: 3, scope: !1257)
!1264 = !DILocation(line: 56, column: 11, scope: !1257)
!1265 = !DILocation(line: 57, column: 15, scope: !1257)
!1266 = !DILocation(line: 57, column: 21, scope: !1257)
!1267 = !DILocation(line: 57, column: 3, scope: !1257)
!1268 = !DILocation(line: 52, column: 1, scope: !1257)
!1269 = distinct !DISubprogram(name: "__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction", linkageName: "__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction", scope: null, file: !1182, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1270 = !DILocation(line: 23, column: 3, scope: !1271)
!1271 = !DILexicalBlockFile(scope: !1269, file: !1182, discriminator: 0)
!1272 = !DILocation(line: 22, column: 3, scope: !1271)
!1273 = !DILocation(line: 20, column: 21, scope: !1271)
!1274 = !DILocation(line: 22, column: 16, scope: !1271)
!1275 = !DILocation(line: 23, column: 29, scope: !1271)
!1276 = !DILocation(line: 23, column: 17, scope: !1271)
!1277 = !DILocation(line: 24, column: 3, scope: !1271)
!1278 = !DILocation(line: 24, column: 11, scope: !1271)
!1279 = !DILocation(line: 25, column: 15, scope: !1271)
!1280 = !DILocation(line: 25, column: 21, scope: !1271)
!1281 = !DILocation(line: 25, column: 3, scope: !1271)
!1282 = !DILocation(line: 20, column: 1, scope: !1271)
module asm ".section \22.pe_debug_info\22, \22\22"
module asm ".section \22.note\22, \22\22"
