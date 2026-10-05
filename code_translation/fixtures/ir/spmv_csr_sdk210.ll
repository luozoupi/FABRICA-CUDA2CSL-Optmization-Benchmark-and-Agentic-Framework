; ModuleID = './layout.csl'
source_filename = "./layout.csl"
target datalayout = "e-ni:0-p:16:16-i1:16-i16:16-i32:32-i64:64-f32:32-f64:64"
target triple = "cs_sdr-cerebras-csos"

@tsc_start_buf = internal global [3 x i16] zeroinitializer, align 4
@tsc_end_buf = internal global [3 x i16] zeroinitializer, align 4
@timer_buf = internal global [3 x float] zeroinitializer, align 4
@ptr_timer_buf = internal global float* getelementptr inbounds ([3 x float], [3 x float]* @timer_buf, i32 0, i32 0), align 4
@row_ptr_array = internal global [33 x i32] zeroinitializer, align 4
@col_idx_array = internal global [256 x i32] zeroinitializer, align 4
@val_array = internal global [256 x float] zeroinitializer, align 4
@x_array = internal global [32 x float] zeroinitializer, align 4
@y_array = internal global [32 x float] zeroinitializer, align 4
@ptr_row_ptr = internal global i32* getelementptr inbounds ([33 x i32], [33 x i32]* @row_ptr_array, i32 0, i32 0), align 4
@ptr_col_idx = internal global i32* getelementptr inbounds ([256 x i32], [256 x i32]* @col_idx_array, i32 0, i32 0), align 4
@ptr_val = internal global float* getelementptr inbounds ([256 x float], [256 x float]* @val_array, i32 0, i32 0), align 4
@ptr_x = internal global float* getelementptr inbounds ([32 x float], [32 x float]* @x_array, i32 0, i32 0), align 4
@ptr_y = internal global float* getelementptr inbounds ([32 x float], [32 x float]* @y_array, i32 0, i32 0), align 4
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
@cte.init = internal constant [3 x i16] [i16 0, i16 1, i16 1], align 4
@__dsr_lowmeminit_ = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 62, i16 142, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__0 = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 4127, i16 142, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__1 = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 lshr (i16 ptrtoint ([1 x i32]* @"$$csl_base_address$$3$$sys_mod.sys_mod.memcpyd2h_mod.teardown_buf" to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__2 = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 4149, i16 142, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__3 = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 4096, i16 142, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__4 = internal constant <{ i16, i16, i16, i16 }> <{ i16 2, i16 4127, i16 142, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__5 = internal constant <{ i16, i16, i16, i16 }> <{ i16 2, i16 lshr (i16 ptrtoint ([2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td" to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4

declare i8* @malloc(i64)

declare void @free(i8*)

define internal void @spmv_csr() !dbg !3 {
  %1 = alloca i32, i16 1, align 4, !dbg !7
  %2 = alloca i32, i16 1, align 4, !dbg !9
  %3 = alloca float, i16 1, align 4, !dbg !10
  %4 = alloca i32, i16 1, align 4, !dbg !11
  %5 = alloca i32, i16 1, align 4, !dbg !12
  %6 = alloca i16, i16 1, align 2, !dbg !13
  store i16 0, i16* %6, align 2, !dbg !13
  br label %7, !dbg !14

7:                                                ; preds = %78, %0
  %8 = phi i16 [ %77, %78 ], [ 0, %0 ]
  %9 = icmp ne i16 %8, 0, !dbg !14
  br i1 %9, label %10, label %11, !dbg !14

10:                                               ; preds = %7
  br label %14, !dbg !14

11:                                               ; preds = %7
  %12 = load i16, i16* %6, align 2, !dbg !15
  %13 = icmp ult i16 %12, 32, !dbg !16
  br label %14, !dbg !14

14:                                               ; preds = %10, %11
  %15 = phi i1 [ %13, %11 ], [ false, %10 ]
  br label %16, !dbg !14

16:                                               ; preds = %14
  br i1 %15, label %17, label %79, !dbg !14

17:                                               ; preds = %16
  %18 = load i16, i16* %6, align 2, !dbg !17
  %19 = getelementptr [33 x i32], [33 x i32]* @row_ptr_array, i16 0, i16 %18, !dbg !18
  %20 = load i32, i32* %19, align 4, !dbg !18
  store i32 %20, i32* %5, align 4, !dbg !12
  %21 = load i16, i16* %6, align 2, !dbg !19
  %22 = add i16 %21, 1, !dbg !20
  %23 = getelementptr [33 x i32], [33 x i32]* @row_ptr_array, i16 0, i16 %22, !dbg !21
  %24 = load i32, i32* %23, align 4, !dbg !21
  store i32 %24, i32* %4, align 4, !dbg !11
  store float 0.000000e+00, float* %3, align 4, !dbg !10
  %25 = load i32, i32* %5, align 4, !dbg !22
  store i32 %25, i32* %2, align 4, !dbg !9
  br label %26, !dbg !23

26:                                               ; preds = %44, %17
  %27 = phi i16 [ 0, %44 ], [ 0, %17 ]
  %28 = icmp sgt i16 %27, 0, !dbg !23
  br i1 %28, label %29, label %31, !dbg !23

29:                                               ; preds = %26
  %30 = sub i16 %27, 1, !dbg !23
  br label %32, !dbg !23

31:                                               ; preds = %26
  br label %32, !dbg !23

32:                                               ; preds = %29, %31
  %33 = phi i16 [ %27, %31 ], [ %30, %29 ]
  br label %34, !dbg !23

34:                                               ; preds = %32
  %35 = icmp ne i16 %27, 0, !dbg !23
  br i1 %35, label %36, label %37, !dbg !23

36:                                               ; preds = %34
  br label %41, !dbg !23

37:                                               ; preds = %34
  %38 = load i32, i32* %2, align 4, !dbg !24
  %39 = load i32, i32* %4, align 4, !dbg !25
  %40 = icmp ult i32 %38, %39, !dbg !26
  br label %41, !dbg !23

41:                                               ; preds = %36, %37
  %42 = phi i1 [ %40, %37 ], [ false, %36 ]
  br label %43, !dbg !23

43:                                               ; preds = %41
  br i1 %42, label %44, label %59, !dbg !23

44:                                               ; preds = %43
  %45 = load i32, i32* %2, align 4, !dbg !27
  %46 = getelementptr [256 x i32], [256 x i32]* @col_idx_array, i16 0, i32 %45, !dbg !28
  %47 = load i32, i32* %46, align 4, !dbg !28
  store i32 %47, i32* %1, align 4, !dbg !7
  %48 = load float, float* %3, align 4, !dbg !29
  %49 = load i32, i32* %2, align 4, !dbg !30
  %50 = getelementptr [256 x float], [256 x float]* @val_array, i16 0, i32 %49, !dbg !31
  %51 = load float, float* %50, align 4, !dbg !31
  %52 = load i32, i32* %1, align 4, !dbg !32
  %53 = getelementptr [32 x float], [32 x float]* @x_array, i16 0, i32 %52, !dbg !33
  %54 = load float, float* %53, align 4, !dbg !33
  %55 = fmul float %51, %54, !dbg !34
  %56 = fadd float %48, %55, !dbg !35
  store float %56, float* %3, align 4, !dbg !35
  %57 = load i32, i32* %2, align 4, !dbg !36
  %58 = add i32 %57, 1, !dbg !37
  store i32 %58, i32* %2, align 4, !dbg !37
  br label %26, !dbg !23

59:                                               ; preds = %43
  %60 = icmp ne i16 %33, 0, !dbg !23
  br i1 %60, label %61, label %62, !dbg !23

61:                                               ; preds = %59
  br label %66, !dbg !23

62:                                               ; preds = %59
  %63 = load float, float* %3, align 4, !dbg !38
  %64 = load i16, i16* %6, align 2, !dbg !39
  %65 = getelementptr [32 x float], [32 x float]* @y_array, i16 0, i16 %64, !dbg !40
  store float %63, float* %65, align 4, !dbg !41
  br label %66, !dbg !23

66:                                               ; preds = %61, %62
  %67 = phi i16 [ 0, %62 ], [ %33, %61 ]
  br label %68, !dbg !23

68:                                               ; preds = %66
  %69 = icmp eq i16 %67, -1, !dbg !14
  %70 = select i1 %69, i16 0, i16 %67, !dbg !14
  %71 = icmp ne i16 %70, 0, !dbg !14
  br i1 %71, label %72, label %73, !dbg !14

72:                                               ; preds = %68
  br label %76, !dbg !14

73:                                               ; preds = %68
  %74 = load i16, i16* %6, align 2, !dbg !42
  %75 = add i16 %74, 1, !dbg !43
  store i16 %75, i16* %6, align 2, !dbg !43
  br label %76, !dbg !14

76:                                               ; preds = %72, %73
  %77 = phi i16 [ 0, %73 ], [ %70, %72 ]
  br label %78, !dbg !14

78:                                               ; preds = %76
  br label %7, !dbg !14

79:                                               ; preds = %16
  ret void, !dbg !14
}

define internal void @compute() !dbg !44 {
  %1 = alloca i16, i16 1, align 2, !dbg !45
  %2 = alloca i16, i16 1, align 2, !dbg !47
  %3 = alloca i16, i16 1, align 2, !dbg !48
  %4 = alloca i16, i16 1, align 2, !dbg !49
  %5 = alloca [3 x i16], i16 1, align 2, !dbg !50
  %6 = alloca [3 x i16], i16 1, align 2, !dbg !50
  call void @timestamp.enable_tsc(), !dbg !51
  call void @timestamp.get_timestamp([3 x i16]* @tsc_start_buf), !dbg !52
  %7 = bitcast [3 x i16]* %5 to i8*, !dbg !50
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* %7, i8* bitcast ([3 x i16]* @cte.init to i8*), i32 6, i1 false), !dbg !50
  %8 = bitcast [3 x i16]* %5 to i8*, !dbg !50
  %9 = bitcast [3 x i16]* %6 to i8*, !dbg !50
  call void @llvm.memcpy.p0i8.p0i8.i32(i8* %9, i8* %8, i32 6, i1 false), !dbg !50
  store i16 0, i16* %4, align 2, !dbg !49
  store i16 0, i16* %3, align 2, !dbg !48
  br label %10, !dbg !48

10:                                               ; preds = %27, %0
  %11 = phi i16 [ 0, %27 ], [ 0, %0 ]
  %12 = icmp sgt i16 %11, 0, !dbg !48
  br i1 %12, label %13, label %15, !dbg !48

13:                                               ; preds = %10
  %14 = sub i16 %11, 1, !dbg !48
  br label %16, !dbg !48

15:                                               ; preds = %10
  br label %16, !dbg !48

16:                                               ; preds = %13, %15
  %17 = phi i16 [ %11, %15 ], [ %14, %13 ]
  br label %18, !dbg !48

18:                                               ; preds = %16
  %19 = icmp ne i16 %11, 0, !dbg !48
  br i1 %19, label %20, label %21, !dbg !48

20:                                               ; preds = %18
  br label %24, !dbg !48

21:                                               ; preds = %18
  %22 = load i16, i16* %4, align 2, !dbg !49
  %23 = icmp ult i16 %22, 1, !dbg !49
  br label %24, !dbg !48

24:                                               ; preds = %20, %21
  %25 = phi i1 [ %23, %21 ], [ false, %20 ]
  br label %26, !dbg !48

26:                                               ; preds = %24
  br i1 %25, label %27, label %32, !dbg !48

27:                                               ; preds = %26
  call void @spmv_csr(), !dbg !53
  %28 = load i16, i16* %3, align 2, !dbg !48
  %29 = add i16 %28, 1, !dbg !48
  store i16 %29, i16* %3, align 2, !dbg !48
  %30 = load i16, i16* %4, align 2, !dbg !49
  %31 = add i16 %30, 1, !dbg !49
  store i16 %31, i16* %4, align 2, !dbg !49
  br label %10, !dbg !48

32:                                               ; preds = %26
  %33 = icmp ne i16 %17, 0, !dbg !48
  br i1 %33, label %34, label %35, !dbg !48

34:                                               ; preds = %32
  br label %63, !dbg !48

35:                                               ; preds = %32
  call void @timestamp.get_timestamp([3 x i16]* @tsc_end_buf), !dbg !54
  call void @timestamp.disable_tsc(), !dbg !55
  store i16 0, i16* %2, align 2, !dbg !47
  store i16 0, i16* %1, align 2, !dbg !45
  %36 = load i16, i16* getelementptr inbounds ([3 x i16], [3 x i16]* @tsc_start_buf, i16 0, i1 false), align 2, !dbg !56
  store i16 %36, i16* %2, align 2, !dbg !57
  %37 = load i16, i16* getelementptr inbounds ([3 x i16], [3 x i16]* @tsc_start_buf, i16 0, i2 1), align 2, !dbg !58
  store i16 %37, i16* %1, align 2, !dbg !59
  %38 = load i16, i16* %1, align 2, !dbg !60
  %39 = zext i16 %38 to i32, !dbg !61
  %40 = shl i32 %39, 16, !dbg !62
  %41 = load i16, i16* %2, align 2, !dbg !63
  %42 = zext i16 %41 to i32, !dbg !64
  %43 = or i32 %40, %42, !dbg !65
  %44 = bitcast i32 %43 to float, !dbg !66
  store float %44, float* getelementptr inbounds ([3 x float], [3 x float]* @timer_buf, i16 0, i1 false), align 4, !dbg !67
  %45 = load i16, i16* getelementptr inbounds ([3 x i16], [3 x i16]* @tsc_start_buf, i16 0, i3 2), align 2, !dbg !68
  store i16 %45, i16* %2, align 2, !dbg !69
  %46 = load i16, i16* getelementptr inbounds ([3 x i16], [3 x i16]* @tsc_end_buf, i16 0, i1 false), align 2, !dbg !70
  store i16 %46, i16* %1, align 2, !dbg !71
  %47 = load i16, i16* %1, align 2, !dbg !72
  %48 = zext i16 %47 to i32, !dbg !73
  %49 = shl i32 %48, 16, !dbg !74
  %50 = load i16, i16* %2, align 2, !dbg !75
  %51 = zext i16 %50 to i32, !dbg !76
  %52 = or i32 %49, %51, !dbg !77
  %53 = bitcast i32 %52 to float, !dbg !78
  store float %53, float* getelementptr inbounds ([3 x float], [3 x float]* @timer_buf, i16 0, i2 1), align 4, !dbg !79
  %54 = load i16, i16* getelementptr inbounds ([3 x i16], [3 x i16]* @tsc_end_buf, i16 0, i2 1), align 2, !dbg !80
  store i16 %54, i16* %2, align 2, !dbg !81
  %55 = load i16, i16* getelementptr inbounds ([3 x i16], [3 x i16]* @tsc_end_buf, i16 0, i3 2), align 2, !dbg !82
  store i16 %55, i16* %1, align 2, !dbg !83
  %56 = load i16, i16* %1, align 2, !dbg !84
  %57 = zext i16 %56 to i32, !dbg !85
  %58 = shl i32 %57, 16, !dbg !86
  %59 = load i16, i16* %2, align 2, !dbg !87
  %60 = zext i16 %59 to i32, !dbg !88
  %61 = or i32 %58, %60, !dbg !89
  %62 = bitcast i32 %61 to float, !dbg !90
  store float %62, float* getelementptr inbounds ([3 x float], [3 x float]* @timer_buf, i16 0, i3 2), align 4, !dbg !91
  call void @llvm.sdr.actvt.r(i16 9), !dbg !92
  br label %63, !dbg !48

63:                                               ; preds = %34, %35
  ret void, !dbg !48
}

define void @f_exit() #0 !dbg !93 {
  call void @sys_mod.unblock_cmd_stream(), !dbg !94
  ret void, !dbg !96
}

define internal void @sys_mod.sys_nop() !dbg !97 {
  ret void, !dbg !99
}

define internal void @sys_mod.unblock_cmd_stream() !dbg !101 {
  call void @sys_mod.sys_mod.unblock_cmd_stream(), !dbg !102
  ret void, !dbg !104
}

define internal void @sys_mod.sys_mod.unblock_cmd_stream() !dbg !105 {
  call void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream(), !dbg !107
  ret void, !dbg !109
}

define internal void @sys_mod.sys_mod.teardown_h2d() !dbg !110 {
  call void @llvm.sdr.actvt.r(i16 27), !dbg !111
  ret void, !dbg !113
}

define void @sys_mod.sys_mod.f_ublk_c22() #1 !dbg !114 {
  call void @sys_mod.sys_mod.unblock_cmd_stream(), !dbg !115
  ret void, !dbg !117
}

define internal void @sys_mod.sys_mod.teardown_d2h() !dbg !118 {
  call void @llvm.sdr.blk.r(i16 0), !dbg !119
  call void @llvm.sdr.actvt.r(i16 28), !dbg !121
  ret void, !dbg !122
}

define void @sys_mod.sys_mod.f_memcpyh2d() #2 !dbg !123 {
  %1 = alloca float, i16 1, align 4, !dbg !124
  %2 = alloca float, i16 1, align 4, !dbg !126
  %3 = alloca i16, i16 1, align 2, !dbg !127
  %4 = alloca i16, i16 1, align 2, !dbg !128
  %5 = alloca i16, i16 1, align 2, !dbg !129
  %6 = alloca i16, i16 1, align 2, !dbg !130
  %7 = alloca i16, i16 1, align 2, !dbg !131
  %8 = alloca i16, i16 1, align 2, !dbg !132
  %9 = alloca i16, i16 1, align 2, !dbg !133
  %10 = alloca i16, i16 1, align 2, !dbg !134
  %11 = alloca i16, i16 1, align 2, !dbg !135
  %12 = alloca i16, i16 1, align 2, !dbg !136
  %13 = alloca i16, i16 1, align 2, !dbg !137
  %14 = alloca i16*, i16 1, align 8, !dbg !138
  %15 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !139
  %16 = icmp eq i16 %15, 15, !dbg !140
  br i1 %16, label %17, label %18, !dbg !141

17:                                               ; preds = %0
  br label %19, !dbg !141

18:                                               ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !141
  br label %19, !dbg !141

19:                                               ; preds = %17, %18
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %14, align 8, !dbg !138
  %20 = load i16*, i16** %14, align 8, !dbg !142
  %21 = load i16, i16* %20, align 2, !dbg !143
  store i16 %21, i16* %13, align 2, !dbg !137
  %22 = load i16*, i16** %14, align 8, !dbg !144
  %23 = getelementptr i16, i16* %22, i16 1, !dbg !145
  %24 = load i16, i16* %23, align 2, !dbg !145
  store i16 %24, i16* %12, align 2, !dbg !136
  %25 = load i16*, i16** %14, align 8, !dbg !146
  %26 = getelementptr i16, i16* %25, i16 2, !dbg !147
  %27 = load i16, i16* %26, align 2, !dbg !147
  store i16 %27, i16* %11, align 2, !dbg !135
  %28 = load i16*, i16** %14, align 8, !dbg !148
  %29 = getelementptr i16, i16* %28, i16 3, !dbg !149
  %30 = load i16, i16* %29, align 2, !dbg !149
  store i16 %30, i16* %10, align 2, !dbg !134
  %31 = load i16*, i16** %14, align 8, !dbg !150
  %32 = getelementptr i16, i16* %31, i16 4, !dbg !151
  %33 = load i16, i16* %32, align 2, !dbg !151
  store i16 %33, i16* %9, align 2, !dbg !133
  %34 = load i16*, i16** %14, align 8, !dbg !152
  %35 = getelementptr i16, i16* %34, i16 5, !dbg !153
  %36 = load i16, i16* %35, align 2, !dbg !153
  store i16 %36, i16* %8, align 2, !dbg !132
  %37 = load i16*, i16** %14, align 8, !dbg !154
  %38 = getelementptr i16, i16* %37, i16 6, !dbg !155
  %39 = load i16, i16* %38, align 2, !dbg !155
  store i16 %39, i16* %7, align 2, !dbg !131
  %40 = load i16*, i16** %14, align 8, !dbg !156
  %41 = getelementptr i16, i16* %40, i16 7, !dbg !157
  %42 = load i16, i16* %41, align 2, !dbg !157
  store i16 %42, i16* %6, align 2, !dbg !130
  %43 = load i16*, i16** %14, align 8, !dbg !158
  %44 = getelementptr i16, i16* %43, i16 8, !dbg !159
  %45 = load i16, i16* %44, align 2, !dbg !159
  store i16 %45, i16* %5, align 2, !dbg !129
  %46 = load i16*, i16** %14, align 8, !dbg !160
  %47 = getelementptr i16, i16* %46, i16 9, !dbg !161
  %48 = load i16, i16* %47, align 2, !dbg !161
  store i16 %48, i16* %4, align 2, !dbg !128
  %49 = load i16*, i16** %14, align 8, !dbg !162
  %50 = getelementptr i16, i16* %49, i16 10, !dbg !163
  %51 = load i16, i16* %50, align 2, !dbg !163
  store i16 %51, i16* %3, align 2, !dbg !127
  %52 = load i16*, i16** %14, align 8, !dbg !164
  %53 = getelementptr i16, i16* %52, i16 12, !dbg !165
  %54 = load i16, i16* %53, align 2, !dbg !165
  %55 = zext i16 %54 to i32, !dbg !166
  %56 = load i16*, i16** %14, align 8, !dbg !167
  %57 = getelementptr i16, i16* %56, i16 11, !dbg !168
  %58 = load i16, i16* %57, align 2, !dbg !168
  %59 = zext i16 %58 to i32, !dbg !169
  %60 = add i32 %59, 16, !dbg !170
  %61 = shl i32 %55, %60, !dbg !171
  %62 = bitcast i32 %61 to float, !dbg !172
  store float %62, float* %2, align 4, !dbg !126
  %63 = load i16*, i16** %14, align 8, !dbg !173
  %64 = getelementptr i16, i16* %63, i16 14, !dbg !174
  %65 = load i16, i16* %64, align 2, !dbg !174
  %66 = zext i16 %65 to i32, !dbg !175
  %67 = load i16*, i16** %14, align 8, !dbg !176
  %68 = getelementptr i16, i16* %67, i16 13, !dbg !177
  %69 = load i16, i16* %68, align 2, !dbg !177
  %70 = zext i16 %69 to i32, !dbg !178
  %71 = add i32 %70, 16, !dbg !179
  %72 = shl i32 %66, %71, !dbg !180
  %73 = bitcast i32 %72 to float, !dbg !181
  store float %73, float* %1, align 4, !dbg !124
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !182
  %74 = load i16, i16* %13, align 2, !dbg !183
  store i16 %74, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !184
  %75 = load i16, i16* %12, align 2, !dbg !185
  store i16 %75, i16* @sys_mod.sys_mod.memcpyH2D_px, align 2, !dbg !186
  %76 = load i16, i16* %11, align 2, !dbg !187
  store i16 %76, i16* @sys_mod.sys_mod.memcpyH2D_py, align 2, !dbg !188
  %77 = load i16, i16* %10, align 2, !dbg !189
  store i16 %77, i16* @sys_mod.sys_mod.memcpyH2D_w, align 2, !dbg !190
  %78 = load i16, i16* %9, align 2, !dbg !191
  store i16 %78, i16* @sys_mod.sys_mod.memcpyH2D_h, align 2, !dbg !192
  %79 = load i16, i16* %8, align 2, !dbg !193
  store i16 %79, i16* @sys_mod.sys_mod.memcpyH2D_addr, align 2, !dbg !194
  %80 = load i16, i16* %7, align 2, !dbg !195
  store i16 %80, i16* @sys_mod.sys_mod.memcpyH2D_pe_length, align 2, !dbg !196
  %81 = load i16, i16* %6, align 2, !dbg !197
  store i16 %81, i16* @sys_mod.sys_mod.memcpyH2D_is_half, align 2, !dbg !198
  %82 = load i16, i16* %5, align 2, !dbg !199
  store i16 %82, i16* @sys_mod.sys_mod.memcpyH2D_memcpy_optype, align 2, !dbg !200
  %83 = load i16, i16* %4, align 2, !dbg !201
  store i16 %83, i16* @sys_mod.sys_mod.memcpyH2D_row_stride, align 2, !dbg !202
  %84 = load i16, i16* %3, align 2, !dbg !203
  store i16 %84, i16* @sys_mod.sys_mod.memcpyH2D_col_stride, align 2, !dbg !204
  %85 = load float, float* %2, align 4, !dbg !205
  store float %85, float* @sys_mod.sys_mod.memcpyH2D_one_over_row_stride, align 4, !dbg !206
  %86 = load float, float* %1, align 4, !dbg !207
  store float %86, float* @sys_mod.sys_mod.memcpyH2D_one_over_col_stride, align 4, !dbg !208
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !209
  call void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 0, i16 23, i1 true), !dbg !210
  call void @llvm.sdr.blk.r(i16 27), !dbg !211
  call void @llvm.sdr.oqflush(i16 0), !dbg !212
  store i1 true, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !213
  call void @llvm.sdr.blk.r(i16 0), !dbg !214
  ret void, !dbg !215
}

define void @sys_mod.sys_mod.f_memcpyd2h() #3 !dbg !216 {
  %1 = alloca i16, i16 1, align 2, !dbg !217
  %2 = alloca i16, i16 1, align 2, !dbg !219
  %3 = alloca i16, i16 1, align 2, !dbg !220
  %4 = alloca i16, i16 1, align 2, !dbg !221
  %5 = alloca i16, i16 1, align 2, !dbg !222
  %6 = alloca i16, i16 1, align 2, !dbg !223
  %7 = alloca i16, i16 1, align 2, !dbg !224
  %8 = alloca i16, i16 1, align 2, !dbg !225
  %9 = alloca i16*, i16 1, align 8, !dbg !226
  %10 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !227
  %11 = icmp eq i16 %10, 8, !dbg !228
  br i1 %11, label %12, label %13, !dbg !229

12:                                               ; preds = %0
  br label %14, !dbg !229

13:                                               ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !229
  br label %14, !dbg !229

14:                                               ; preds = %12, %13
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %9, align 8, !dbg !226
  %15 = load i16*, i16** %9, align 8, !dbg !230
  %16 = load i16, i16* %15, align 2, !dbg !231
  store i16 %16, i16* %8, align 2, !dbg !225
  %17 = load i16*, i16** %9, align 8, !dbg !232
  %18 = getelementptr i16, i16* %17, i16 1, !dbg !233
  %19 = load i16, i16* %18, align 2, !dbg !233
  store i16 %19, i16* %7, align 2, !dbg !224
  %20 = load i16*, i16** %9, align 8, !dbg !234
  %21 = getelementptr i16, i16* %20, i16 2, !dbg !235
  %22 = load i16, i16* %21, align 2, !dbg !235
  store i16 %22, i16* %6, align 2, !dbg !223
  %23 = load i16*, i16** %9, align 8, !dbg !236
  %24 = getelementptr i16, i16* %23, i16 3, !dbg !237
  %25 = load i16, i16* %24, align 2, !dbg !237
  store i16 %25, i16* %5, align 2, !dbg !222
  %26 = load i16*, i16** %9, align 8, !dbg !238
  %27 = getelementptr i16, i16* %26, i16 4, !dbg !239
  %28 = load i16, i16* %27, align 2, !dbg !239
  store i16 %28, i16* %4, align 2, !dbg !221
  %29 = load i16*, i16** %9, align 8, !dbg !240
  %30 = getelementptr i16, i16* %29, i16 5, !dbg !241
  %31 = load i16, i16* %30, align 2, !dbg !241
  store i16 %31, i16* %3, align 2, !dbg !220
  %32 = load i16*, i16** %9, align 8, !dbg !242
  %33 = getelementptr i16, i16* %32, i16 6, !dbg !243
  %34 = load i16, i16* %33, align 2, !dbg !243
  store i16 %34, i16* %2, align 2, !dbg !219
  %35 = load i16*, i16** %9, align 8, !dbg !244
  %36 = getelementptr i16, i16* %35, i16 7, !dbg !245
  %37 = load i16, i16* %36, align 2, !dbg !245
  store i16 %37, i16* %1, align 2, !dbg !217
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !246
  %38 = load i16, i16* %8, align 2, !dbg !247
  store i16 %38, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !248
  %39 = load i16, i16* %7, align 2, !dbg !249
  store i16 %39, i16* @sys_mod.sys_mod.memcpyD2H_px, align 2, !dbg !250
  %40 = load i16, i16* %6, align 2, !dbg !251
  store i16 %40, i16* @sys_mod.sys_mod.memcpyD2H_py, align 2, !dbg !252
  %41 = load i16, i16* %5, align 2, !dbg !253
  store i16 %41, i16* @sys_mod.sys_mod.memcpyD2H_w, align 2, !dbg !254
  %42 = load i16, i16* %4, align 2, !dbg !255
  store i16 %42, i16* @sys_mod.sys_mod.memcpyD2H_h, align 2, !dbg !256
  %43 = load i16, i16* %3, align 2, !dbg !257
  store i16 %43, i16* @sys_mod.sys_mod.memcpyD2H_addr, align 2, !dbg !258
  %44 = load i16, i16* %2, align 2, !dbg !259
  store i16 %44, i16* @sys_mod.sys_mod.memcpyD2H_pe_length, align 2, !dbg !260
  %45 = load i16, i16* %1, align 2, !dbg !261
  store i16 %45, i16* @sys_mod.sys_mod.memcpyD2H_is_half, align 2, !dbg !262
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !263
  %46 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !264
  call void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 0, i16 %46, i1 false), !dbg !265
  call void @llvm.sdr.oqflush(i16 0), !dbg !266
  store i1 false, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !267
  ret void, !dbg !268
}

define internal void @sys_mod.sys_mod.oq0_teardow_handler() !dbg !269 {
  %1 = load i1, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !270
  br i1 %1, label %2, label %17, !dbg !272

2:                                                ; preds = %0
  %3 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !273
  call void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 0, i16 %3), !dbg !274
  %4 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !275
  %5 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_px, align 2, !dbg !276
  %6 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_py, align 2, !dbg !277
  %7 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_w, align 2, !dbg !278
  %8 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_h, align 2, !dbg !279
  %9 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_addr, align 2, !dbg !280
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_pe_length, align 2, !dbg !281
  %11 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_is_half, align 2, !dbg !282
  %12 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_memcpy_optype, align 2, !dbg !283
  %13 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_row_stride, align 2, !dbg !284
  %14 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_col_stride, align 2, !dbg !285
  %15 = load float, float* @sys_mod.sys_mod.memcpyH2D_one_over_row_stride, align 4, !dbg !286
  %16 = load float, float* @sys_mod.sys_mod.memcpyH2D_one_over_col_stride, align 4, !dbg !287
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure(i16 %4, i16 %5, i16 %6, i16 %7, i16 %8, i16 %9, i16 %10, i16 %11, i16 %12, i16 %13, i16 %14, float %15, float %16), !dbg !288
  br label %26, !dbg !272

17:                                               ; preds = %0
  call void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 0, i16 21), !dbg !289
  %18 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !290
  %19 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_px, align 2, !dbg !291
  %20 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_py, align 2, !dbg !292
  %21 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_w, align 2, !dbg !293
  %22 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_h, align 2, !dbg !294
  %23 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_addr, align 2, !dbg !295
  %24 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_pe_length, align 2, !dbg !296
  %25 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_is_half, align 2, !dbg !297
  call void @sys_mod.sys_mod.memcpyd2h_mod.d2h_configure(i16 %18, i16 %19, i16 %20, i16 %21, i16 %22, i16 %23, i16 %24, i16 %25), !dbg !298
  br label %26, !dbg !272

26:                                               ; preds = %2, %17
  call void @__generic0sys_mod.sys_mod.tile_config.queue_flush.exit(), !dbg !299
  ret void, !dbg !272
}

define internal void @rpc_server(i32* %0) {
  %2 = load i32, i32* %0, align 4
  %3 = add i32 %2, 1
  %4 = getelementptr i32, i32* %0, i32 %3
  %5 = load i32, i32* %4, align 4
  switch i32 %5, label %6 [
    i32 7, label %7
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

define void @sys_mod.sys_mod.f_rpc(i16 %0) #4 !dbg !300 {
  %2 = alloca i16, i16 1, align 2, !dbg !301
  store i16 %0, i16* %2, align 2, !dbg !301
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !303
  %3 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !304
  %4 = icmp sge i16 %3, 4, !dbg !305
  br i1 %4, label %5, label %6, !dbg !306

5:                                                ; preds = %1
  br label %7, !dbg !306

6:                                                ; preds = %1
  call void asm sideeffect "hcf", ""(), !dbg !306
  br label %7, !dbg !306

7:                                                ; preds = %5, %6
  call void @rpc_server(i32* getelementptr inbounds ([32 x i32], [32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32, i32 0, i32 0)), !dbg !307
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !308
  ret void, !dbg !309
}

define internal void @sys_mod.sys_mod.sys_mod.stack_push(i16 %0) !dbg !310 {
  %2 = alloca i16*, i16 1, align 8, !dbg !312
  %3 = alloca i16, i16 1, align 2, !dbg !314
  store i16 %0, i16* %3, align 2, !dbg !314
  %4 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !315
  %5 = icmp slt i16 %4, 32, !dbg !316
  br i1 %5, label %6, label %7, !dbg !317

6:                                                ; preds = %1
  br label %8, !dbg !317

7:                                                ; preds = %1
  call void asm sideeffect "hcf", ""(), !dbg !317
  br label %8, !dbg !317

8:                                                ; preds = %6, %7
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %2, align 8, !dbg !312
  %9 = load i16, i16* %3, align 2, !dbg !318
  %10 = load i16*, i16** %2, align 8, !dbg !319
  %11 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !320
  %12 = getelementptr i16, i16* %10, i16 %11, !dbg !321
  store i16 %9, i16* %12, align 2, !dbg !322
  %13 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !323
  %14 = add i16 %13, 1, !dbg !324
  store i16 %14, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !325
  ret void, !dbg !326
}

define void @sys_mod.sys_mod.sys_mod.f_push(i16 %0, i16 %1) #5 !dbg !327 {
  %3 = alloca i16, i16 1, align 2, !dbg !328
  %4 = alloca i16, i16 1, align 2, !dbg !330
  store i16 %0, i16* %4, align 2, !dbg !330
  store i16 %1, i16* %3, align 2, !dbg !328
  %5 = load i16, i16* %4, align 2, !dbg !331
  call void @sys_mod.sys_mod.sys_mod.stack_push(i16 %5), !dbg !332
  ret void, !dbg !333
}

define internal void @sys_mod.sys_mod.sys_mod.block_cmd_stream() !dbg !334 {
  call void @llvm.sdr.blk.r(i16 1), !dbg !335
  ret void, !dbg !337
}

define internal void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream() !dbg !338 {
  call void @llvm.sdr.ublk.r(i16 1), !dbg !339
  ret void, !dbg !341
}

define void @sys_mod.sys_mod.sys_mod.f_sys_exit() #6 !dbg !342 {
  call void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream(), !dbg !343
  call void @sys_mod.sys_nop(), !dbg !345
  ret void, !dbg !346
}

define void @sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore(i32 %0) #7 !dbg !347 {
  %2 = alloca i32, i16 1, align 4, !dbg !348
  store i32 %0, i32* %2, align 4, !dbg !348
  ret void, !dbg !350
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord() !dbg !351 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord(), !dbg !353
  ret i16 %1, !dbg !355
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord() !dbg !356 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord(), !dbg !357
  ret i16 %1, !dbg !359
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval(i16 %0) !dbg !360 {
  %2 = alloca i16, i16 1, align 2, !dbg !361
  store i16 %0, i16* %2, align 2, !dbg !361
  %3 = load i16, i16* %2, align 2, !dbg !363
  %4 = icmp ult i16 %3, 24, !dbg !364
  br i1 %4, label %5, label %7, !dbg !365

5:                                                ; preds = %10, %11, %1
  %6 = phi i16 [ 0, %10 ], [ 0, %11 ], [ 1, %1 ]
  br label %12, !dbg !365

7:                                                ; preds = %1
  %8 = load i16, i16* %2, align 2, !dbg !366
  %9 = icmp eq i16 31, %8, !dbg !367
  br i1 %9, label %10, label %11, !dbg !368

10:                                               ; preds = %7
  br label %5, !dbg !368

11:                                               ; preds = %7
  call void asm sideeffect "hcf", ""(), !dbg !368
  br label %5, !dbg !368

12:                                               ; preds = %5
  %13 = phi i16 [ %6, %5 ]
  br label %14, !dbg !365

14:                                               ; preds = %12
  ret i16 %13, !dbg !365
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start(i16 %0, i16 %1, i16 %2) !dbg !369 {
  %4 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !370
  %5 = alloca i16, i16 1, align 2, !dbg !372
  %6 = alloca i16, i16 1, align 2, !dbg !373
  %7 = alloca i16, i16 1, align 2, !dbg !374
  store i16 %0, i16* %7, align 2, !dbg !374
  store i16 %1, i16* %6, align 2, !dbg !373
  store i16 %2, i16* %5, align 2, !dbg !372
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !375
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !375
  %10 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !375
  %11 = load i16, i16* %6, align 2, !dbg !376
  store i16 %11, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !377
  store i16 %8, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !377
  store i16 %9, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !377
  store i16 %10, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !377
  %12 = load i16, i16* %7, align 2, !dbg !378
  %13 = call i16* @.get_tensor_ptr(i16 %12), !dbg !379
  %14 = ptrtoint i16* %13 to i16, !dbg !380
  %15 = lshr i16 %14, 1, !dbg !380
  %16 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !370
  store i16 42, i16* %16, align 2, !dbg !370
  %17 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !370
  store i16 %15, i16* %17, align 2, !dbg !370
  %18 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !370
  store i16 143, i16* %18, align 2, !dbg !370
  %19 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !370
  store i16 16, i16* %19, align 2, !dbg !370
  %20 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !381
  %21 = load i16, i16* %20, align 2, !dbg !381
  %22 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !381
  %23 = load i16, i16* %22, align 2, !dbg !381
  %24 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !381
  %25 = load i16, i16* %24, align 2, !dbg !381
  %26 = load i16, i16* %6, align 2, !dbg !382
  %27 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !383
  store i16 %26, i16* %27, align 2, !dbg !383
  %28 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !383
  store i16 %21, i16* %28, align 2, !dbg !383
  %29 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !383
  store i16 %23, i16* %29, align 2, !dbg !383
  %30 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !383
  store i16 %25, i16* %30, align 2, !dbg !383
  %31 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !384
  %32 = load i16, i16* %31, align 2, !dbg !384
  %33 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !384
  %34 = load i16, i16* %33, align 2, !dbg !384
  %35 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !384
  %36 = load i16, i16* %35, align 2, !dbg !384
  %37 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !384
  %38 = load i16, i16* %37, align 2, !dbg !384
  store volatile i16 %32, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !385
  store volatile i16 %34, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !385
  store volatile i16 %36, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !385
  store volatile i16 %38, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !385
  call void asm sideeffect "nop", ""(), !dbg !385
  call void asm sideeffect "nop", ""(), !dbg !385
  %39 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !386
  %40 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !386
  %41 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !386
  %42 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !386
  %43 = and i16 %41, -193, !dbg !386
  %44 = or i16 %43, 128, !dbg !386
  %45 = and i16 %40, -64, !dbg !386
  %46 = or i16 %45, 27, !dbg !386
  store volatile i16 %39, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !387
  store volatile i16 %46, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !387
  store volatile i16 %44, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !387
  store volatile i16 %42, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !387
  call void asm sideeffect "nop", ""(), !dbg !387
  call void asm sideeffect "nop", ""(), !dbg !387
  %47 = load i16, i16* %5, align 2, !dbg !388
  %48 = icmp ult i16 0, %47, !dbg !389
  br i1 %48, label %49, label %50, !dbg !390

49:                                               ; preds = %3
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !391
  br label %51, !dbg !390

50:                                               ; preds = %3
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !392
  br label %51, !dbg !390

51:                                               ; preds = %49, %50
  ret void, !dbg !390
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream() !dbg !393 {
  call void @llvm.sdr.ublk.r(i16 1), !dbg !394
  ret void, !dbg !396
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7, i16 %8, i16 %9, i16 %10, float %11, float %12) !dbg !397 {
  %14 = alloca i16, i16 1, align 2, !dbg !398
  %15 = alloca i16, i16 1, align 2, !dbg !400
  %16 = alloca i16, i16 1, align 2, !dbg !401
  %17 = alloca i16, i16 1, align 2, !dbg !402
  %18 = alloca i16, i16 1, align 2, !dbg !403
  %19 = alloca i1, i16 1, align 1, !dbg !404
  %20 = alloca i16, i16 1, align 2, !dbg !405
  %21 = alloca i16, i16 1, align 2, !dbg !406
  %22 = alloca i16, i16 1, align 2, !dbg !407
  %23 = alloca i16, i16 1, align 2, !dbg !408
  %24 = alloca i16, i16 1, align 2, !dbg !409
  %25 = alloca float, i16 1, align 4, !dbg !410
  %26 = alloca float, i16 1, align 4, !dbg !411
  %27 = alloca i16, i16 1, align 2, !dbg !412
  %28 = alloca i16, i16 1, align 2, !dbg !413
  %29 = alloca i16, i16 1, align 2, !dbg !414
  %30 = alloca i16, i16 1, align 2, !dbg !415
  %31 = alloca i16, i16 1, align 2, !dbg !416
  %32 = alloca i16, i16 1, align 2, !dbg !417
  %33 = alloca i16, i16 1, align 2, !dbg !418
  %34 = alloca i16, i16 1, align 2, !dbg !419
  %35 = alloca i16, i16 1, align 2, !dbg !420
  %36 = alloca i16, i16 1, align 2, !dbg !421
  %37 = alloca i16, i16 1, align 2, !dbg !422
  store i16 %0, i16* %37, align 2, !dbg !422
  store i16 %1, i16* %36, align 2, !dbg !421
  store i16 %2, i16* %35, align 2, !dbg !420
  store i16 %3, i16* %34, align 2, !dbg !419
  store i16 %4, i16* %33, align 2, !dbg !418
  store i16 %5, i16* %32, align 2, !dbg !417
  store i16 %6, i16* %31, align 2, !dbg !416
  store i16 %7, i16* %30, align 2, !dbg !415
  store i16 %8, i16* %29, align 2, !dbg !414
  store i16 %9, i16* %28, align 2, !dbg !413
  store i16 %10, i16* %27, align 2, !dbg !412
  store float %11, float* %26, align 4, !dbg !411
  store float %12, float* %25, align 4, !dbg !410
  %38 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord(), !dbg !423
  store i16 %38, i16* %24, align 2, !dbg !409
  %39 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord(), !dbg !424
  store i16 %39, i16* %23, align 2, !dbg !408
  %40 = load i16, i16* %24, align 2, !dbg !425
  %41 = load i16, i16* %36, align 2, !dbg !426
  %42 = sub i16 %40, %41, !dbg !427
  store i16 %42, i16* %22, align 2, !dbg !407
  %43 = load i16, i16* %22, align 2, !dbg !428
  store i16 %43, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !429
  %44 = load i16, i16* %29, align 2, !dbg !430
  %45 = icmp eq i16 3, %44, !dbg !431
  br i1 %45, label %46, label %63, !dbg !432

46:                                               ; preds = %13
  %47 = load i16, i16* %22, align 2, !dbg !433
  %48 = sitofp i16 %47 to float, !dbg !434
  %49 = load float, float* %26, align 4, !dbg !435
  %50 = fmul float %48, %49, !dbg !436
  %51 = fptosi float %50 to i16, !dbg !437
  store i16 %51, i16* %21, align 2, !dbg !406
  %52 = load i16, i16* %22, align 2, !dbg !438
  %53 = load i16, i16* %21, align 2, !dbg !439
  %54 = load i16, i16* %28, align 2, !dbg !440
  %55 = mul i16 %53, %54, !dbg !441
  %56 = sub i16 %52, %55, !dbg !442
  store i16 %56, i16* %20, align 2, !dbg !405
  %57 = load i16, i16* %20, align 2, !dbg !443
  %58 = icmp ne i16 0, %57, !dbg !444
  br i1 %58, label %59, label %60, !dbg !445

59:                                               ; preds = %46
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !446
  br label %62, !dbg !445

60:                                               ; preds = %46
  %61 = load i16, i16* %21, align 2, !dbg !447
  store i16 %61, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !448
  br label %62, !dbg !445

62:                                               ; preds = %59, %60
  br label %63, !dbg !432

63:                                               ; preds = %62, %13
  %64 = load i16, i16* %22, align 2, !dbg !449
  %65 = icmp slt i16 %64, 0, !dbg !450
  br i1 %65, label %66, label %67, !dbg !451

66:                                               ; preds = %63
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !452
  br label %67, !dbg !451

67:                                               ; preds = %66, %63
  %68 = load i16, i16* %22, align 2, !dbg !453
  %69 = load i16, i16* %34, align 2, !dbg !454
  %70 = icmp sge i16 %68, %69, !dbg !455
  br i1 %70, label %71, label %72, !dbg !456

71:                                               ; preds = %67
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !457
  br label %72, !dbg !456

72:                                               ; preds = %71, %67
  store i1 false, i1* %19, align 1, !dbg !404
  %73 = load i16, i16* %29, align 2, !dbg !458
  %74 = icmp eq i16 3, %73, !dbg !459
  br i1 %74, label %75, label %94, !dbg !460

75:                                               ; preds = %72
  %76 = load i16, i16* %23, align 2, !dbg !461
  %77 = load i16, i16* %35, align 2, !dbg !462
  %78 = sub i16 %76, %77, !dbg !463
  %79 = sitofp i16 %78 to float, !dbg !464
  %80 = load float, float* %25, align 4, !dbg !465
  %81 = fmul float %79, %80, !dbg !466
  %82 = fptosi float %81 to i16, !dbg !467
  store i16 %82, i16* %18, align 2, !dbg !403
  %83 = load i16, i16* %23, align 2, !dbg !468
  %84 = load i16, i16* %35, align 2, !dbg !469
  %85 = sub i16 %83, %84, !dbg !470
  %86 = load i16, i16* %18, align 2, !dbg !471
  %87 = load i16, i16* %27, align 2, !dbg !472
  %88 = mul i16 %86, %87, !dbg !473
  %89 = sub i16 %85, %88, !dbg !474
  store i16 %89, i16* %17, align 2, !dbg !402
  %90 = load i16, i16* %17, align 2, !dbg !475
  %91 = icmp ne i16 0, %90, !dbg !476
  br i1 %91, label %92, label %93, !dbg !477

92:                                               ; preds = %75
  store i1 true, i1* %19, align 1, !dbg !478
  br label %93, !dbg !477

93:                                               ; preds = %92, %75
  br label %94, !dbg !460

94:                                               ; preds = %93, %72
  %95 = load i16, i16* %23, align 2, !dbg !479
  %96 = load i16, i16* %35, align 2, !dbg !480
  %97 = icmp slt i16 %95, %96, !dbg !481
  br i1 %97, label %98, label %99, !dbg !482

98:                                               ; preds = %94
  store i1 true, i1* %19, align 1, !dbg !483
  br label %99, !dbg !482

99:                                               ; preds = %98, %94
  %100 = load i16, i16* %23, align 2, !dbg !484
  %101 = load i16, i16* %35, align 2, !dbg !485
  %102 = load i16, i16* %33, align 2, !dbg !486
  %103 = add i16 %101, %102, !dbg !487
  %104 = icmp sge i16 %100, %103, !dbg !488
  br i1 %104, label %105, label %106, !dbg !489

105:                                              ; preds = %99
  store i1 true, i1* %19, align 1, !dbg !490
  br label %106, !dbg !489

106:                                              ; preds = %105, %99
  %107 = load i1, i1* %19, align 1, !dbg !491
  br i1 %107, label %108, label %109, !dbg !492

108:                                              ; preds = %106
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream(), !dbg !493
  call void @llvm.sdr.ublk.r(i16 27), !dbg !494
  br label %180, !dbg !492

109:                                              ; preds = %106
  %110 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !495
  %111 = icmp eq i16 -1, %110, !dbg !496
  br i1 %111, label %112, label %113, !dbg !497

112:                                              ; preds = %109
  call void @__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction(i16 31767), !dbg !498
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 23), !dbg !499
  call void @llvm.sdr.ublk.r(i16 27), !dbg !500
  br label %179, !dbg !497

113:                                              ; preds = %109
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter(i16 0, i16 0), !dbg !501
  %114 = load i16, i16* %34, align 2, !dbg !502
  store i16 %114, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !503
  %115 = load i16, i16* %29, align 2, !dbg !504
  %116 = icmp eq i16 3, %115, !dbg !505
  br i1 %116, label %117, label %126, !dbg !506

117:                                              ; preds = %113
  %118 = load i16, i16* %34, align 2, !dbg !507
  %119 = sub i16 %118, 1, !dbg !508
  %120 = sitofp i16 %119 to float, !dbg !509
  %121 = load float, float* %26, align 4, !dbg !510
  %122 = fmul float %120, %121, !dbg !511
  %123 = fptosi float %122 to i16, !dbg !512
  %124 = add i16 %123, 1, !dbg !513
  store i16 %124, i16* %16, align 2, !dbg !401
  %125 = load i16, i16* %16, align 2, !dbg !514
  store i16 %125, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !515
  br label %131, !dbg !506

126:                                              ; preds = %113
  %127 = load i16, i16* %29, align 2, !dbg !516
  %128 = icmp eq i16 1, %127, !dbg !517
  br i1 %128, label %129, label %130, !dbg !518

129:                                              ; preds = %126
  store i16 1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !519
  br label %130, !dbg !518

130:                                              ; preds = %129, %126
  br label %131, !dbg !506

131:                                              ; preds = %117, %130
  %132 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !520
  %133 = sub i16 %132, 1, !dbg !521
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit(i16 0, i16 %133), !dbg !522
  %134 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !523
  store i16 %134, i16* %15, align 2, !dbg !400
  %135 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !524
  store i16 %135, i16* %14, align 2, !dbg !398
  %136 = load i16, i16* %15, align 2, !dbg !525
  %137 = load i16, i16* %14, align 2, !dbg !526
  %138 = sub i16 %136, %137, !dbg !527
  store i16 %138, i16* %15, align 2, !dbg !528
  %139 = load i16, i16* %14, align 2, !dbg !529
  %140 = icmp eq i16 0, %139, !dbg !530
  br i1 %140, label %141, label %142, !dbg !531

141:                                              ; preds = %131
  store i16 0, i16* %15, align 2, !dbg !532
  br label %142, !dbg !531

142:                                              ; preds = %141, %131
  %143 = load i16, i16* %29, align 2, !dbg !533
  %144 = icmp eq i16 1, %143, !dbg !534
  br i1 %144, label %145, label %146, !dbg !535

145:                                              ; preds = %142
  store i16 0, i16* %15, align 2, !dbg !536
  br label %146, !dbg !535

146:                                              ; preds = %145, %142
  %147 = load i16, i16* %15, align 2, !dbg !537
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter(i16 0, i16 %147), !dbg !538
  call void @__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction(i16 31767), !dbg !539
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 23), !dbg !540
  %148 = load i16, i16* %37, align 2, !dbg !541
  %149 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval(i16 %148), !dbg !542
  %150 = icmp eq i16 0, %149, !dbg !543
  br i1 %150, label %151, label %155, !dbg !544

151:                                              ; preds = %146
  %152 = load i16, i16* %32, align 2, !dbg !545
  %153 = load i16, i16* %31, align 2, !dbg !546
  %154 = load i16, i16* %30, align 2, !dbg !547
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start(i16 %152, i16 %153, i16 %154), !dbg !548
  br label %178, !dbg !544

155:                                              ; preds = %146
  %156 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !549
  %157 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !549
  %158 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !549
  %159 = load i16, i16* %31, align 2, !dbg !550
  store i16 %159, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !551
  store i16 %156, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !551
  store i16 %157, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !551
  store i16 %158, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !551
  %160 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !552
  %161 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !552
  %162 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !552
  %163 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !552
  %164 = and i16 %162, -193, !dbg !552
  %165 = or i16 %164, 128, !dbg !552
  store volatile i16 %160, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !553
  store volatile i16 %161, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !553
  store volatile i16 %165, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !553
  store volatile i16 %163, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !553
  call void asm sideeffect "nop", ""(), !dbg !553
  call void asm sideeffect "nop", ""(), !dbg !553
  %166 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !554
  %167 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !554
  %168 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !554
  %169 = load i16, i16* %31, align 2, !dbg !555
  store i16 %169, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !556
  store i16 %166, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !556
  store i16 %167, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !556
  store i16 %168, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !556
  %170 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !557
  %171 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !557
  %172 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !557
  %173 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !557
  %174 = and i16 %172, -193, !dbg !557
  %175 = or i16 %174, 128, !dbg !557
  %176 = and i16 %171, -64, !dbg !557
  %177 = or i16 %176, 27, !dbg !557
  store volatile i16 %170, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !558
  store volatile i16 %177, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !558
  store volatile i16 %175, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !558
  store volatile i16 %173, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !558
  call void asm sideeffect "nop", ""(), !dbg !558
  call void asm sideeffect "nop", ""(), !dbg !558
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !559
  br label %178, !dbg !544

178:                                              ; preds = %151, %155
  br label %179, !dbg !497

179:                                              ; preds = %112, %178
  br label %180, !dbg !492

180:                                              ; preds = %108, %179
  ret void, !dbg !432
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit(i16 %0, i16 %1) !dbg !560 {
  %3 = alloca i16, i16 1, align 2, !dbg !562
  %4 = alloca i16, i16 1, align 2, !dbg !564
  %5 = alloca i16, i16 1, align 2, !dbg !565
  %6 = alloca i16, i16 1, align 2, !dbg !566
  %7 = alloca i16, i16 1, align 2, !dbg !567
  %8 = alloca i16, i16 1, align 2, !dbg !568
  store i16 %0, i16* %8, align 2, !dbg !568
  store i16 %1, i16* %7, align 2, !dbg !567
  %9 = load i16, i16* %7, align 2, !dbg !569
  %10 = icmp ult i16 %9, -32768, !dbg !570
  br i1 %10, label %11, label %12, !dbg !571

11:                                               ; preds = %2
  br label %13, !dbg !571

12:                                               ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !571
  br label %13, !dbg !571

13:                                               ; preds = %11, %12
  %14 = load i16, i16* %7, align 2, !dbg !572
  %15 = mul i16 %14, 2, !dbg !573
  store i16 %15, i16* %6, align 2, !dbg !566
  %16 = load i16, i16* %8, align 2, !dbg !574
  %17 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %16, i16 8), !dbg !575
  %18 = sub i16 %17, 1, !dbg !576
  store i16 %18, i16* %5, align 2, !dbg !565
  %19 = load i16, i16* %6, align 2, !dbg !577
  %20 = load i16, i16* %5, align 2, !dbg !578
  %21 = icmp ult i16 %19, %20, !dbg !579
  br i1 %21, label %22, label %23, !dbg !564

22:                                               ; preds = %13
  store i16 0, i16* %4, align 2, !dbg !564
  br label %27, !dbg !564

23:                                               ; preds = %13
  %24 = load i16, i16* %6, align 2, !dbg !580
  %25 = load i16, i16* %5, align 2, !dbg !581
  %26 = sub i16 %24, %25, !dbg !582
  store i16 %26, i16* %4, align 2, !dbg !564
  br label %27, !dbg !564

27:                                               ; preds = %22, %23
  %28 = load i16, i16* %4, align 2, !dbg !564
  store i16 %28, i16* %3, align 2, !dbg !562
  %29 = load i16, i16* %8, align 2, !dbg !583
  %30 = load i16, i16* %3, align 2, !dbg !584
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %29, i16 4, i16 %30), !dbg !585
  ret void, !dbg !564
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter(i16 %0, i16 %1) !dbg !586 {
  %3 = alloca i16, i16 1, align 2, !dbg !587
  %4 = alloca i16, i16 1, align 2, !dbg !589
  store i16 %0, i16* %4, align 2, !dbg !589
  store i16 %1, i16* %3, align 2, !dbg !587
  %5 = load i16, i16* %3, align 2, !dbg !590
  %6 = icmp ult i16 %5, -32768, !dbg !591
  br i1 %6, label %7, label %8, !dbg !592

7:                                                ; preds = %2
  br label %9, !dbg !592

8:                                                ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !592
  br label %9, !dbg !592

9:                                                ; preds = %7, %8
  %10 = load i16, i16* %4, align 2, !dbg !593
  %11 = load i16, i16* %3, align 2, !dbg !594
  %12 = mul i16 %11, 2, !dbg !595
  %13 = add i16 %12, 1, !dbg !596
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %10, i16 8, i16 %13), !dbg !597
  ret void, !dbg !598
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter(i16 %0, i16 %1) !dbg !599 {
  %3 = alloca i16, i16 1, align 2, !dbg !600
  %4 = alloca i16, i16 1, align 2, !dbg !602
  %5 = alloca i1, i16 1, align 1, !dbg !603
  %6 = alloca i16, i16 1, align 2, !dbg !604
  %7 = alloca i16, i16 1, align 2, !dbg !605
  %8 = alloca i16, i16 1, align 2, !dbg !606
  %9 = alloca i16, i16 1, align 2, !dbg !607
  store i16 %0, i16* %9, align 2, !dbg !607
  store i16 %1, i16* %8, align 2, !dbg !606
  %10 = load i16, i16* %8, align 2, !dbg !608
  %11 = icmp ult i16 %10, -32768, !dbg !609
  br i1 %11, label %12, label %13, !dbg !610

12:                                               ; preds = %2
  br label %14, !dbg !610

13:                                               ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !610
  br label %14, !dbg !610

14:                                               ; preds = %12, %13
  %15 = load i16, i16* %9, align 2, !dbg !611
  %16 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %15, i16 8), !dbg !612
  store i16 %16, i16* %7, align 2, !dbg !605
  %17 = load i16, i16* %8, align 2, !dbg !613
  %18 = mul i16 %17, 2, !dbg !614
  store i16 %18, i16* %6, align 2, !dbg !604
  %19 = load i16, i16* %6, align 2, !dbg !615
  %20 = load i16, i16* %7, align 2, !dbg !616
  %21 = icmp ugt i16 %19, %20, !dbg !617
  store i1 %21, i1* %5, align 1, !dbg !603
  %22 = load i16, i16* %9, align 2, !dbg !618
  %23 = load i1, i1* %5, align 1, !dbg !619
  %24 = zext i1 %23 to i16, !dbg !620
  %25 = shl i16 %24, 6, !dbg !621
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %22, i16 14, i16 %25), !dbg !622
  %26 = load i1, i1* %5, align 1, !dbg !623
  br i1 %26, label %27, label %32, !dbg !602

27:                                               ; preds = %14
  %28 = load i16, i16* %6, align 2, !dbg !624
  %29 = load i16, i16* %7, align 2, !dbg !625
  %30 = sub i16 %28, %29, !dbg !626
  %31 = add i16 %30, 1, !dbg !627
  store i16 %31, i16* %4, align 2, !dbg !602
  br label %34, !dbg !602

32:                                               ; preds = %14
  %33 = load i16, i16* %6, align 2, !dbg !628
  store i16 %33, i16* %4, align 2, !dbg !602
  br label %34, !dbg !602

34:                                               ; preds = %27, %32
  %35 = load i16, i16* %4, align 2, !dbg !602
  store i16 %35, i16* %3, align 2, !dbg !600
  %36 = load i16, i16* %9, align 2, !dbg !629
  %37 = load i16, i16* %3, align 2, !dbg !630
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %36, i16 12, i16 %37), !dbg !631
  ret void, !dbg !602
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %0, i16 %1, i16 %2) !dbg !632 {
  %4 = alloca i16, i16 1, align 2, !dbg !634
  %5 = alloca i16, i16 1, align 2, !dbg !636
  %6 = alloca i16, i16 1, align 2, !dbg !637
  store i16 %0, i16* %6, align 2, !dbg !637
  store i16 %1, i16* %5, align 2, !dbg !636
  store i16 %2, i16* %4, align 2, !dbg !634
  %7 = load i16, i16* %6, align 2, !dbg !638
  %8 = getelementptr [6 x i16], [6 x i16]* @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.filters, i16 0, i16 %7, !dbg !639
  %9 = load i16, i16* %8, align 2, !dbg !639
  %10 = load i16, i16* %5, align 2, !dbg !640
  %11 = add i16 %9, %10, !dbg !641
  %12 = lshr i16 %11, 1, !dbg !642
  %13 = load i16, i16* %4, align 2, !dbg !643
  %14 = shl i16 %12, 1, !dbg !644
  %15 = inttoptr i16 %14 to i16*, !dbg !644
  store volatile i16 %13, i16* %15, align 2, !dbg !644
  call void asm sideeffect "nop", ""(), !dbg !644
  call void asm sideeffect "nop", ""(), !dbg !644
  ret void, !dbg !645
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %0, i16 %1) !dbg !646 {
  %3 = alloca i16, i16 1, align 2, !dbg !647
  %4 = alloca i16, i16 1, align 2, !dbg !649
  store i16 %0, i16* %4, align 2, !dbg !649
  store i16 %1, i16* %3, align 2, !dbg !647
  %5 = load i16, i16* %4, align 2, !dbg !650
  %6 = getelementptr [6 x i16], [6 x i16]* @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.filters, i16 0, i16 %5, !dbg !651
  %7 = load i16, i16* %6, align 2, !dbg !651
  %8 = load i16, i16* %3, align 2, !dbg !652
  %9 = add i16 %7, %8, !dbg !653
  %10 = lshr i16 %9, 1, !dbg !654
  %11 = shl i16 %10, 1, !dbg !655
  %12 = inttoptr i16 %11 to i16*, !dbg !655
  call void asm sideeffect "nop", ""(), !dbg !655
  call void asm sideeffect "nop", ""(), !dbg !655
  %13 = load volatile i16, i16* %12, align 2, !dbg !655
  ret i16 %13, !dbg !656
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 %0) !dbg !657 {
  %2 = alloca i16, i16 1, align 2, !dbg !659
  %3 = alloca i16, i16 1, align 2, !dbg !661
  %4 = alloca i16, i16 1, align 2, !dbg !662
  %5 = alloca i16, i16 1, align 2, !dbg !663
  store i16 %0, i16* %5, align 2, !dbg !663
  %6 = load i16, i16* %5, align 2, !dbg !664
  store i16 %6, i16* %4, align 2, !dbg !662
  %7 = load i16, i16* %4, align 2, !dbg !665
  %8 = add i16 %7, 31744, !dbg !666
  store i16 %8, i16* %3, align 2, !dbg !661
  %9 = load i16, i16* %3, align 2, !dbg !667
  %10 = shl i16 %9, 1, !dbg !668
  %11 = inttoptr i16 %10 to i16*, !dbg !668
  call void asm sideeffect "nop", ""(), !dbg !668
  call void asm sideeffect "nop", ""(), !dbg !668
  %12 = load volatile i16, i16* %11, align 2, !dbg !668
  store i16 %12, i16* %2, align 2, !dbg !659
  %13 = load i16, i16* %3, align 2, !dbg !669
  %14 = load i16, i16* %2, align 2, !dbg !670
  %15 = and i16 %14, 32767, !dbg !671
  %16 = shl i16 %13, 1, !dbg !672
  %17 = inttoptr i16 %16 to i16*, !dbg !672
  store volatile i16 %15, i16* %17, align 2, !dbg !672
  call void asm sideeffect "nop", ""(), !dbg !672
  call void asm sideeffect "nop", ""(), !dbg !672
  ret void, !dbg !673
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord() !dbg !674 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 2), !dbg !676
  %2 = sub i16 %1, 4, !dbg !678
  ret i16 %2, !dbg !679
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord() !dbg !680 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 0), !dbg !681
  %2 = sub i16 %1, 1, !dbg !683
  ret i16 %2, !dbg !684
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 %0) !dbg !685 {
  %2 = alloca i16, i16 1, align 2, !dbg !687
  %3 = alloca i16, i16 1, align 2, !dbg !689
  store i16 %0, i16* %3, align 2, !dbg !689
  %4 = load i16, i16* %3, align 2, !dbg !690
  %5 = lshr i16 %4, 1, !dbg !691
  %6 = add i16 %5, 31813, !dbg !692
  %7 = shl i16 %6, 1, !dbg !693
  %8 = inttoptr i16 %7 to i16*, !dbg !693
  call void asm sideeffect "nop", ""(), !dbg !693
  call void asm sideeffect "nop", ""(), !dbg !693
  %9 = load volatile i16, i16* %8, align 2, !dbg !693
  store i16 %9, i16* %2, align 2, !dbg !687
  %10 = load i16, i16* %2, align 2, !dbg !694
  %11 = and i16 %10, 2047, !dbg !695
  ret i16 %11, !dbg !696
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord() !dbg !697 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord(), !dbg !699
  ret i16 %1, !dbg !701
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.get_y_coord() !dbg !702 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord(), !dbg !703
  ret i16 %1, !dbg !705
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval(i16 %0) !dbg !706 {
  %2 = alloca i16, i16 1, align 2, !dbg !707
  store i16 %0, i16* %2, align 2, !dbg !707
  %3 = load i16, i16* %2, align 2, !dbg !709
  %4 = icmp ult i16 %3, 24, !dbg !710
  br i1 %4, label %5, label %7, !dbg !711

5:                                                ; preds = %10, %11, %1
  %6 = phi i16 [ 0, %10 ], [ 0, %11 ], [ 1, %1 ]
  br label %12, !dbg !711

7:                                                ; preds = %1
  %8 = load i16, i16* %2, align 2, !dbg !712
  %9 = icmp eq i16 31, %8, !dbg !713
  br i1 %9, label %10, label %11, !dbg !714

10:                                               ; preds = %7
  br label %5, !dbg !714

11:                                               ; preds = %7
  call void asm sideeffect "hcf", ""(), !dbg !714
  br label %5, !dbg !714

12:                                               ; preds = %5
  %13 = phi i16 [ %6, %5 ]
  br label %14, !dbg !711

14:                                               ; preds = %12
  ret i16 %13, !dbg !711
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7) !dbg !715 {
  %9 = alloca i16, i16 1, align 2, !dbg !716
  %10 = alloca i16, i16 1, align 2, !dbg !718
  %11 = alloca i16, i16 1, align 2, !dbg !719
  %12 = alloca i16, i16 1, align 2, !dbg !720
  %13 = alloca i16, i16 1, align 2, !dbg !721
  %14 = alloca i16, i16 1, align 2, !dbg !722
  %15 = alloca i16, i16 1, align 2, !dbg !723
  %16 = alloca i16, i16 1, align 2, !dbg !724
  %17 = alloca i16, i16 1, align 2, !dbg !725
  store i16 %0, i16* %17, align 2, !dbg !725
  store i16 %1, i16* %16, align 2, !dbg !724
  store i16 %2, i16* %15, align 2, !dbg !723
  store i16 %3, i16* %14, align 2, !dbg !722
  store i16 %4, i16* %13, align 2, !dbg !721
  store i16 %5, i16* %12, align 2, !dbg !720
  store i16 %6, i16* %11, align 2, !dbg !719
  store i16 %7, i16* %10, align 2, !dbg !718
  %18 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !726
  store i16 %18, i16* %9, align 2, !dbg !716
  %19 = load i16, i16* %11, align 2, !dbg !727
  store i16 %19, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_c, align 2, !dbg !728
  %20 = load i16, i16* %10, align 2, !dbg !729
  store i16 %20, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_is_half, align 2, !dbg !730
  %21 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_c, align 2, !dbg !731
  %22 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval(i16 %21), !dbg !732
  store i16 %22, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !733
  store i16 0, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !734
  %23 = load i16, i16* %16, align 2, !dbg !735
  store i16 %23, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !736
  %24 = load i16, i16* %15, align 2, !dbg !737
  store i16 %24, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !738
  %25 = load i16, i16* %15, align 2, !dbg !739
  %26 = load i16, i16* %13, align 2, !dbg !740
  %27 = add i16 %25, %26, !dbg !741
  %28 = sub i16 %27, 1, !dbg !742
  store i16 %28, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_last, align 2, !dbg !743
  %29 = load i16, i16* %9, align 2, !dbg !744
  %30 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_last, align 2, !dbg !745
  %31 = icmp eq i16 %29, %30, !dbg !746
  br i1 %31, label %32, label %37, !dbg !747

32:                                               ; preds = %8
  %33 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !748
  %34 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !748
  %35 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !748
  store i16 %33, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !749
  store i16 lshr (i16 ptrtoint ([1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.ctrl_1 to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !749
  store i16 %34, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !749
  store i16 %35, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !749
  %36 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.ctrl_1, i16 0, i1 false), align 4, !dbg !750
  store i32 %36, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i1 false), align 4, !dbg !751
  br label %42, !dbg !747

37:                                               ; preds = %8
  %38 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !752
  %39 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !752
  %40 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !752
  store i16 %38, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !753
  store i16 lshr (i16 ptrtoint ([1 x i32]* @"$$csl_base_address$$0$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11" to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !753
  store i16 %39, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !753
  store i16 %40, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !753
  %41 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @"$$csl_base_address$$0$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11", i16 0, i1 false), align 4, !dbg !754
  store i32 %41, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i1 false), align 4, !dbg !755
  br label %42, !dbg !747

42:                                               ; preds = %32, %37
  store i32 165646921, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i2 1), align 4, !dbg !756
  %43 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !757
  %44 = icmp eq i16 0, %43, !dbg !758
  br i1 %44, label %45, label %56, !dbg !759

45:                                               ; preds = %42
  %46 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !760
  %47 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !760
  %48 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !760
  %49 = load i16, i16* %17, align 2, !dbg !761
  %50 = call i16* @.get_tensor_ptr(i16 %49), !dbg !762
  %51 = ptrtoint i16* %50 to i16, !dbg !763
  %52 = lshr i16 %51, 1, !dbg !763
  store i16 %46, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !764
  store i16 %52, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !764
  store i16 %47, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !764
  store i16 %48, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !764
  %53 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !765
  %54 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !765
  %55 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !765
  store i16 1, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !766
  store i16 %53, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !766
  store i16 %54, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !766
  store i16 %55, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !766
  call void @llvm.sdr.actvt.r(i16 21), !dbg !767
  br label %63, !dbg !759

56:                                               ; preds = %42
  %57 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !768
  %58 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !768
  %59 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !768
  store i16 %57, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !769
  store i16 lshr (i16 ptrtoint ([1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.data_buf to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !769
  store i16 %58, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !769
  store i16 %59, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !769
  %60 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !770
  %61 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !770
  %62 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !770
  store i16 1, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !771
  store i16 %60, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !771
  store i16 %61, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !771
  store i16 %62, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !771
  call void @llvm.sdr.ublk.r(i16 0), !dbg !772
  br label %63, !dbg !759

63:                                               ; preds = %45, %56
  ret void, !dbg !747
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x(i32 %0) #8 !dbg !773 {
  %2 = alloca i32, i16 1, align 4, !dbg !774
  store i32 %0, i32* %2, align 4, !dbg !774
  call void @llvm.sdr.blk.r(i16 0), !dbg !776
  %3 = load i32, i32* %2, align 4, !dbg !777
  store i32 %3, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.data_buf, i16 0, i1 false), align 4, !dbg !778
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !779
  %4 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !780
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !780
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !780
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !780
  store volatile i16 %4, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !781
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !781
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !781
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !781
  call void asm sideeffect "nop", ""(), !dbg !781
  call void asm sideeffect "nop", ""(), !dbg !781
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !782
  %8 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !783
  %9 = add i16 %8, 1, !dbg !784
  store i16 %9, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !785
  ret void, !dbg !786
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_send_data() #9 !dbg !787 {
  %1 = alloca i16, i16 1, align 2, !dbg !788
  %2 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !790
  %3 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !791
  %4 = icmp ult i16 %2, %3, !dbg !792
  br i1 %4, label %5, label %27, !dbg !793

5:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !794
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !795
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !795
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !795
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !795
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !796
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !796
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !796
  store volatile i16 %9, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !796
  call void asm sideeffect "nop", ""(), !dbg !796
  call void asm sideeffect "nop", ""(), !dbg !796
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_is_half, align 2, !dbg !797
  %11 = icmp ult i16 0, %10, !dbg !798
  br i1 %11, label %12, label %18, !dbg !799

12:                                               ; preds = %5
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !800
  %13 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !801
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !801
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !801
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !801
  %17 = add i16 %14, 1, !dbg !802
  store i16 %13, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !803
  store i16 %17, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !803
  store i16 %15, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !803
  store i16 %16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !803
  br label %24, !dbg !799

18:                                               ; preds = %5
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !804
  %19 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !805
  %20 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !805
  %21 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !805
  %22 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !805
  %23 = add i16 %20, 2, !dbg !806
  store i16 %19, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !807
  store i16 %23, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !807
  store i16 %21, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !807
  store i16 %22, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !807
  br label %24, !dbg !799

24:                                               ; preds = %12, %18
  %25 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !808
  %26 = add i16 %25, 1, !dbg !809
  store i16 %26, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !810
  br label %34, !dbg !793

27:                                               ; preds = %0
  %28 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !811
  store i16 %28, i16* %1, align 2, !dbg !788
  %29 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !812
  %30 = load i16, i16* %1, align 2, !dbg !813
  %31 = icmp eq i16 %29, %30, !dbg !814
  br i1 %31, label %32, label %33, !dbg !815

32:                                               ; preds = %27
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !816
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__1 to i8*)), !dbg !817
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !818
  br label %33, !dbg !815

33:                                               ; preds = %32, %27
  br label %34, !dbg !793

34:                                               ; preds = %24, %33
  ret void, !dbg !793
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl() #10 !dbg !819 {
  %1 = alloca i16, i16 1, align 2, !dbg !820
  %2 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !822
  %3 = icmp eq i16 0, %2, !dbg !823
  br i1 %3, label %4, label %9, !dbg !824

4:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__2 to i8*)), !dbg !825
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !826
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !826
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !826
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !826
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !827
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !827
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !827
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !827
  call void asm sideeffect "nop", ""(), !dbg !827
  call void asm sideeffect "nop", ""(), !dbg !827
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !828
  br label %31, !dbg !824

9:                                                ; preds = %0
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !829
  %11 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !830
  %12 = icmp ult i16 %10, %11, !dbg !831
  br i1 %12, label %13, label %18, !dbg !832

13:                                               ; preds = %9
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__3 to i8*)), !dbg !833
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !834
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !834
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !834
  %17 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !834
  store volatile i16 %14, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !835
  store volatile i16 %15, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !835
  store volatile i16 %16, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !835
  store volatile i16 %17, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !835
  call void asm sideeffect "nop", ""(), !dbg !835
  call void asm sideeffect "nop", ""(), !dbg !835
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !836
  br label %30, !dbg !832

18:                                               ; preds = %9
  %19 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !837
  store i16 %19, i16* %1, align 2, !dbg !820
  %20 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !838
  %21 = load i16, i16* %1, align 2, !dbg !839
  %22 = icmp eq i16 %20, %21, !dbg !840
  br i1 %22, label %23, label %24, !dbg !841

23:                                               ; preds = %18
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__4 to i8*)), !dbg !842
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__5 to i8*)), !dbg !843
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !844
  br label %29, !dbg !841

24:                                               ; preds = %18
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !845
  %25 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !846
  %26 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !846
  %27 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !846
  %28 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !846
  store volatile i16 %25, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !847
  store volatile i16 %26, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !847
  store volatile i16 %27, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !847
  store volatile i16 %28, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !847
  call void asm sideeffect "nop", ""(), !dbg !847
  call void asm sideeffect "nop", ""(), !dbg !847
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !848
  br label %29, !dbg !841

29:                                               ; preds = %23, %24
  br label %30, !dbg !832

30:                                               ; preds = %13, %29
  br label %31, !dbg !824

31:                                               ; preds = %4, %30
  ret void, !dbg !824
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.d2h_configure(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7) !dbg !849 {
  %9 = alloca i1, i16 1, align 1, !dbg !850
  %10 = alloca i1, i16 1, align 1, !dbg !852
  %11 = alloca i1, i16 1, align 1, !dbg !853
  %12 = alloca i16, i16 1, align 2, !dbg !854
  %13 = alloca i16, i16 1, align 2, !dbg !855
  %14 = alloca i16, i16 1, align 2, !dbg !856
  %15 = alloca i16, i16 1, align 2, !dbg !857
  %16 = alloca i16, i16 1, align 2, !dbg !858
  %17 = alloca i16, i16 1, align 2, !dbg !859
  %18 = alloca i16, i16 1, align 2, !dbg !860
  %19 = alloca i16, i16 1, align 2, !dbg !861
  %20 = alloca i16, i16 1, align 2, !dbg !862
  %21 = alloca i16, i16 1, align 2, !dbg !863
  %22 = alloca i16, i16 1, align 2, !dbg !864
  %23 = alloca i16, i16 1, align 2, !dbg !865
  %24 = alloca i16, i16 1, align 2, !dbg !866
  %25 = alloca i16, i16 1, align 2, !dbg !867
  store i16 %0, i16* %25, align 2, !dbg !867
  store i16 %1, i16* %24, align 2, !dbg !866
  store i16 %2, i16* %23, align 2, !dbg !865
  store i16 %3, i16* %22, align 2, !dbg !864
  store i16 %4, i16* %21, align 2, !dbg !863
  store i16 %5, i16* %20, align 2, !dbg !862
  store i16 %6, i16* %19, align 2, !dbg !861
  store i16 %7, i16* %18, align 2, !dbg !860
  %26 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !868
  store i16 %26, i16* %17, align 2, !dbg !859
  %27 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_y_coord(), !dbg !869
  store i16 %27, i16* %16, align 2, !dbg !858
  %28 = load i16, i16* %24, align 2, !dbg !870
  store i16 %28, i16* %15, align 2, !dbg !857
  %29 = load i16, i16* %24, align 2, !dbg !871
  %30 = load i16, i16* %22, align 2, !dbg !872
  %31 = add i16 %29, %30, !dbg !873
  %32 = sub i16 %31, 1, !dbg !874
  store i16 %32, i16* %14, align 2, !dbg !856
  %33 = load i16, i16* %23, align 2, !dbg !875
  store i16 %33, i16* %13, align 2, !dbg !855
  %34 = load i16, i16* %23, align 2, !dbg !876
  %35 = load i16, i16* %21, align 2, !dbg !877
  %36 = add i16 %34, %35, !dbg !878
  %37 = sub i16 %36, 1, !dbg !879
  store i16 %37, i16* %12, align 2, !dbg !854
  store i1 false, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !880
  %38 = load i16, i16* %17, align 2, !dbg !881
  %39 = load i16, i16* %15, align 2, !dbg !882
  %40 = icmp sge i16 %38, %39, !dbg !883
  br i1 %40, label %41, label %45, !dbg !853

41:                                               ; preds = %8
  %42 = load i16, i16* %16, align 2, !dbg !884
  %43 = load i16, i16* %12, align 2, !dbg !885
  %44 = icmp sle i16 %42, %43, !dbg !886
  store i1 %44, i1* %11, align 1, !dbg !853
  br label %46, !dbg !853

45:                                               ; preds = %8
  store i1 false, i1* %11, align 1, !dbg !853
  br label %46, !dbg !853

46:                                               ; preds = %41, %45
  %47 = load i1, i1* %11, align 1, !dbg !853
  br i1 %47, label %48, label %52, !dbg !852

48:                                               ; preds = %46
  %49 = load i16, i16* %16, align 2, !dbg !887
  %50 = load i16, i16* %13, align 2, !dbg !888
  %51 = icmp sge i16 %49, %50, !dbg !889
  store i1 %51, i1* %10, align 1, !dbg !852
  br label %53, !dbg !852

52:                                               ; preds = %46
  store i1 false, i1* %10, align 1, !dbg !852
  br label %53, !dbg !852

53:                                               ; preds = %48, %52
  %54 = load i1, i1* %10, align 1, !dbg !852
  br i1 %54, label %55, label %56, !dbg !890

55:                                               ; preds = %53
  store i1 true, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !891
  br label %56, !dbg !890

56:                                               ; preds = %55, %53
  store i1 false, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !892
  %57 = load i16, i16* %17, align 2, !dbg !893
  %58 = load i16, i16* %14, align 2, !dbg !894
  %59 = icmp sle i16 %57, %58, !dbg !895
  br i1 %59, label %60, label %62, !dbg !850

60:                                               ; preds = %56
  %61 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !896
  store i1 %61, i1* %9, align 1, !dbg !850
  br label %63, !dbg !850

62:                                               ; preds = %56
  store i1 false, i1* %9, align 1, !dbg !850
  br label %63, !dbg !850

63:                                               ; preds = %60, %62
  %64 = load i1, i1* %9, align 1, !dbg !850
  br i1 %64, label %65, label %66, !dbg !897

65:                                               ; preds = %63
  store i1 true, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !898
  br label %66, !dbg !897

66:                                               ; preds = %65, %63
  %67 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !899
  br i1 %67, label %68, label %86, !dbg !900

68:                                               ; preds = %66
  call void @__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position(i16 31959), !dbg !901
  %69 = load i16, i16* %15, align 2, !dbg !902
  %70 = load i16, i16* %17, align 2, !dbg !903
  %71 = icmp eq i16 %69, %70, !dbg !904
  br i1 %71, label %72, label %73, !dbg !905

72:                                               ; preds = %68
  call void @__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 31765), !dbg !906
  br label %74, !dbg !905

73:                                               ; preds = %68
  call void @__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 31765), !dbg !907
  br label %74, !dbg !905

74:                                               ; preds = %72, %73
  call void @sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit(i16 21), !dbg !908
  %75 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !909
  br i1 %75, label %76, label %85, !dbg !910

76:                                               ; preds = %74
  %77 = load i16, i16* %20, align 2, !dbg !911
  %78 = load i16, i16* %19, align 2, !dbg !912
  %79 = load i16, i16* %24, align 2, !dbg !913
  %80 = load i16, i16* %23, align 2, !dbg !914
  %81 = load i16, i16* %22, align 2, !dbg !915
  %82 = load i16, i16* %21, align 2, !dbg !916
  %83 = load i16, i16* %25, align 2, !dbg !917
  %84 = load i16, i16* %18, align 2, !dbg !918
  call void @sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start(i16 %77, i16 %78, i16 %79, i16 %80, i16 %81, i16 %82, i16 %83, i16 %84), !dbg !919
  br label %85, !dbg !910

85:                                               ; preds = %76, %74
  br label %87, !dbg !900

86:                                               ; preds = %66
  call void @llvm.sdr.actvt.r(i16 28), !dbg !920
  br label %87, !dbg !900

87:                                               ; preds = %85, %86
  ret void, !dbg !853
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit(i16 %0) !dbg !921 {
  %2 = alloca i16, i16 1, align 2, !dbg !922
  %3 = alloca i16, i16 1, align 2, !dbg !924
  %4 = alloca i16, i16 1, align 2, !dbg !925
  %5 = alloca i16, i16 1, align 2, !dbg !926
  store i16 %0, i16* %5, align 2, !dbg !926
  %6 = load i16, i16* %5, align 2, !dbg !927
  store i16 %6, i16* %4, align 2, !dbg !925
  %7 = load i16, i16* %4, align 2, !dbg !928
  %8 = add i16 %7, 31744, !dbg !929
  store i16 %8, i16* %3, align 2, !dbg !924
  %9 = load i16, i16* %3, align 2, !dbg !930
  %10 = shl i16 %9, 1, !dbg !931
  %11 = inttoptr i16 %10 to i16*, !dbg !931
  call void asm sideeffect "nop", ""(), !dbg !931
  call void asm sideeffect "nop", ""(), !dbg !931
  %12 = load volatile i16, i16* %11, align 2, !dbg !931
  store i16 %12, i16* %2, align 2, !dbg !922
  %13 = load i16, i16* %3, align 2, !dbg !932
  %14 = load i16, i16* %2, align 2, !dbg !933
  %15 = and i16 %14, 32767, !dbg !934
  %16 = shl i16 %13, 1, !dbg !935
  %17 = inttoptr i16 %16 to i16*, !dbg !935
  store volatile i16 %15, i16* %17, align 2, !dbg !935
  call void asm sideeffect "nop", ""(), !dbg !935
  call void asm sideeffect "nop", ""(), !dbg !935
  ret void, !dbg !936
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord() !dbg !937 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 2), !dbg !938
  %2 = sub i16 %1, 4, !dbg !940
  ret i16 %2, !dbg !941
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord() !dbg !942 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 0), !dbg !943
  %2 = sub i16 %1, 1, !dbg !945
  ret i16 %2, !dbg !946
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 %0) !dbg !947 {
  %2 = alloca i16, i16 1, align 2, !dbg !948
  %3 = alloca i16, i16 1, align 2, !dbg !950
  store i16 %0, i16* %3, align 2, !dbg !950
  %4 = load i16, i16* %3, align 2, !dbg !951
  %5 = lshr i16 %4, 1, !dbg !952
  %6 = add i16 %5, 31813, !dbg !953
  %7 = shl i16 %6, 1, !dbg !954
  %8 = inttoptr i16 %7 to i16*, !dbg !954
  call void asm sideeffect "nop", ""(), !dbg !954
  call void asm sideeffect "nop", ""(), !dbg !954
  %9 = load volatile i16, i16* %8, align 2, !dbg !954
  store i16 %9, i16* %2, align 2, !dbg !948
  %10 = load i16, i16* %2, align 2, !dbg !955
  %11 = and i16 %10, 2047, !dbg !956
  ret i16 %11, !dbg !957
}

define internal i16 @sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr(i16 %0) !dbg !958 {
  %2 = alloca i16, i16 1, align 2, !dbg !960
  store i16 %0, i16* %2, align 2, !dbg !960
  %3 = load i16, i16* %2, align 2, !dbg !962
  %4 = mul i16 %3, 2, !dbg !963
  %5 = add i16 %4, 31680, !dbg !964
  ret i16 %5, !dbg !965
}

define internal void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 %0, i16 %1, i1 %2) !dbg !966 {
  %4 = alloca i16, i16 1, align 2, !dbg !967
  %5 = alloca i16, i16 1, align 2, !dbg !969
  %6 = alloca i1, i16 1, align 1, !dbg !970
  %7 = alloca i16, i16 1, align 2, !dbg !971
  %8 = alloca i16, i16 1, align 2, !dbg !972
  store i16 %0, i16* %8, align 2, !dbg !972
  store i16 %1, i16* %7, align 2, !dbg !971
  store i1 %2, i1* %6, align 1, !dbg !970
  %9 = load i16, i16* %8, align 2, !dbg !973
  %10 = call i16 @sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr(i16 %9), !dbg !974
  store i16 %10, i16* %5, align 2, !dbg !969
  %11 = load i16, i16* %5, align 2, !dbg !975
  %12 = shl i16 %11, 1, !dbg !976
  %13 = inttoptr i16 %12 to i16*, !dbg !976
  call void asm sideeffect "nop", ""(), !dbg !976
  call void asm sideeffect "nop", ""(), !dbg !976
  call void asm sideeffect "nop", ""(), !dbg !976
  call void asm sideeffect "nop", ""(), !dbg !976
  %14 = load volatile i16, i16* %13, align 2, !dbg !976
  store i16 %14, i16* %4, align 2, !dbg !967
  %15 = load i1, i1* %6, align 1, !dbg !977
  br i1 %15, label %16, label %19, !dbg !978

16:                                               ; preds = %3
  %17 = load i16, i16* %4, align 2, !dbg !979
  %18 = or i16 %17, 2048, !dbg !980
  store i16 %18, i16* %4, align 2, !dbg !981
  br label %22, !dbg !978

19:                                               ; preds = %3
  %20 = load i16, i16* %4, align 2, !dbg !982
  %21 = and i16 %20, -2049, !dbg !983
  store i16 %21, i16* %4, align 2, !dbg !984
  br label %22, !dbg !978

22:                                               ; preds = %16, %19
  %23 = load i16, i16* %4, align 2, !dbg !985
  %24 = and i16 %23, -32, !dbg !986
  store i16 %24, i16* %4, align 2, !dbg !987
  %25 = load i16, i16* %4, align 2, !dbg !988
  %26 = load i16, i16* %7, align 2, !dbg !989
  %27 = add i16 %25, %26, !dbg !990
  store i16 %27, i16* %4, align 2, !dbg !991
  %28 = load i16, i16* %5, align 2, !dbg !992
  %29 = load i16, i16* %4, align 2, !dbg !993
  %30 = shl i16 %28, 1, !dbg !994
  %31 = inttoptr i16 %30 to i16*, !dbg !994
  store volatile i16 %29, i16* %31, align 2, !dbg !994
  call void asm sideeffect "nop", ""(), !dbg !994
  call void asm sideeffect "nop", ""(), !dbg !994
  call void asm sideeffect "nop", ""(), !dbg !994
  call void asm sideeffect "nop", ""(), !dbg !994
  ret void, !dbg !978
}

define internal i16 @sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr(i16 %0) !dbg !995 {
  %2 = alloca i16, i16 1, align 2, !dbg !997
  store i16 %0, i16* %2, align 2, !dbg !997
  %3 = load i16, i16* %2, align 2, !dbg !999
  %4 = add i16 %3, 31616, !dbg !1000
  ret i16 %4, !dbg !1001
}

define internal void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 %0, i16 %1) !dbg !1002 {
  %3 = alloca i16, i16 1, align 2, !dbg !1003
  %4 = alloca i16, i16 1, align 2, !dbg !1005
  %5 = alloca i16, i16 1, align 2, !dbg !1006
  %6 = alloca i16, i16 1, align 2, !dbg !1007
  store i16 %0, i16* %6, align 2, !dbg !1007
  store i16 %1, i16* %5, align 2, !dbg !1006
  %7 = load i16, i16* %6, align 2, !dbg !1008
  %8 = call i16 @sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr(i16 %7), !dbg !1009
  store i16 %8, i16* %4, align 2, !dbg !1005
  %9 = load i16, i16* %4, align 2, !dbg !1010
  %10 = shl i16 %9, 1, !dbg !1011
  %11 = inttoptr i16 %10 to i16*, !dbg !1011
  call void asm sideeffect "nop", ""(), !dbg !1011
  call void asm sideeffect "nop", ""(), !dbg !1011
  call void asm sideeffect "nop", ""(), !dbg !1011
  call void asm sideeffect "nop", ""(), !dbg !1011
  %12 = load volatile i16, i16* %11, align 2, !dbg !1011
  store i16 %12, i16* %3, align 2, !dbg !1003
  %13 = load i16, i16* %3, align 2, !dbg !1012
  %14 = and i16 %13, -497, !dbg !1013
  store i16 %14, i16* %3, align 2, !dbg !1014
  %15 = load i16, i16* %3, align 2, !dbg !1015
  %16 = load i16, i16* %5, align 2, !dbg !1016
  %17 = add i16 %15, %16, !dbg !1017
  %18 = shl i16 %17, 4, !dbg !1018
  store i16 %18, i16* %3, align 2, !dbg !1019
  %19 = load i16, i16* %4, align 2, !dbg !1020
  %20 = load i16, i16* %3, align 2, !dbg !1021
  %21 = shl i16 %19, 1, !dbg !1022
  %22 = inttoptr i16 %21 to i16*, !dbg !1022
  store volatile i16 %20, i16* %22, align 2, !dbg !1022
  call void asm sideeffect "nop", ""(), !dbg !1022
  call void asm sideeffect "nop", ""(), !dbg !1022
  call void asm sideeffect "nop", ""(), !dbg !1022
  call void asm sideeffect "nop", ""(), !dbg !1022
  ret void, !dbg !1023
}

define internal void @timestamp.enable_tsc() !dbg !1024 {
  call void @timestamp.ts.enable_tsc(), !dbg !1026
  ret void, !dbg !1028
}

define internal void @timestamp.disable_tsc() !dbg !1029 {
  call void @timestamp.ts.disable_tsc(), !dbg !1030
  ret void, !dbg !1032
}

define internal void @timestamp.get_timestamp([3 x i16]* %0) !dbg !1033 {
  %2 = alloca [3 x i16]*, i16 1, align 8, !dbg !1034
  store [3 x i16]* %0, [3 x i16]** %2, align 8, !dbg !1034
  %3 = load [3 x i16]*, [3 x i16]** %2, align 8, !dbg !1036
  call void @timestamp.ts.get_timestamp([3 x i16]* %3), !dbg !1037
  ret void, !dbg !1038
}

define internal void @timestamp.ts.set_tsc_ctrl_reg(i16 %0) !dbg !1039 {
  %2 = alloca i16, i16 1, align 2, !dbg !1041
  store i16 %0, i16* %2, align 2, !dbg !1041
  %3 = load i16, i16* %2, align 2, !dbg !1043
  store volatile i16 %3, i16* inttoptr (i16 -2456 to i16*), align 2, !dbg !1044
  call void asm sideeffect "nop", ""(), !dbg !1044
  call void asm sideeffect "nop", ""(), !dbg !1044
  ret void, !dbg !1045
}

define internal void @timestamp.ts.get_value([3 x i16]* %0, i16 %1) !dbg !1046 {
  %3 = alloca i16, i16 1, align 2, !dbg !1047
  %4 = alloca [3 x i16]*, i16 1, align 8, !dbg !1049
  store [3 x i16]* %0, [3 x i16]** %4, align 8, !dbg !1049
  store i16 %1, i16* %3, align 2, !dbg !1047
  %5 = load i16, i16* %3, align 2, !dbg !1050
  %6 = shl i16 %5, 1, !dbg !1051
  %7 = inttoptr i16 %6 to i16*, !dbg !1051
  call void asm sideeffect "nop", ""(), !dbg !1051
  call void asm sideeffect "nop", ""(), !dbg !1051
  call void asm sideeffect "nop", ""(), !dbg !1051
  call void asm sideeffect "nop", ""(), !dbg !1051
  %8 = load volatile i16, i16* %7, align 2, !dbg !1051
  %9 = load [3 x i16]*, [3 x i16]** %4, align 8, !dbg !1052
  %10 = getelementptr [3 x i16], [3 x i16]* %9, i16 0, i16 0, !dbg !1053
  store i16 %8, i16* %10, align 2, !dbg !1054
  %11 = load i16, i16* %3, align 2, !dbg !1050
  %12 = add i16 %11, 1, !dbg !1055
  %13 = shl i16 %12, 1, !dbg !1051
  %14 = inttoptr i16 %13 to i16*, !dbg !1051
  %15 = load volatile i16, i16* %14, align 2, !dbg !1051
  %16 = load [3 x i16]*, [3 x i16]** %4, align 8, !dbg !1052
  %17 = getelementptr [3 x i16], [3 x i16]* %16, i16 0, i16 1, !dbg !1053
  store i16 %15, i16* %17, align 2, !dbg !1054
  %18 = load i16, i16* %3, align 2, !dbg !1050
  %19 = add i16 %18, 2, !dbg !1055
  %20 = shl i16 %19, 1, !dbg !1051
  %21 = inttoptr i16 %20 to i16*, !dbg !1051
  %22 = load volatile i16, i16* %21, align 2, !dbg !1051
  %23 = load [3 x i16]*, [3 x i16]** %4, align 8, !dbg !1052
  %24 = getelementptr [3 x i16], [3 x i16]* %23, i16 0, i16 2, !dbg !1053
  store i16 %22, i16* %24, align 2, !dbg !1054
  ret void, !dbg !1056
}

define internal void @timestamp.ts.enable_tsc() !dbg !1057 {
  call void @timestamp.ts.set_tsc_ctrl_reg(i16 7), !dbg !1058
  call void @timestamp.ts.reset_tsc_counter(), !dbg !1060
  ret void, !dbg !1061
}

define internal void @timestamp.ts.disable_tsc() !dbg !1062 {
  call void @timestamp.ts.set_tsc_ctrl_reg(i16 0), !dbg !1063
  ret void, !dbg !1065
}

define internal void @timestamp.ts.get_timestamp([3 x i16]* %0) !dbg !1066 {
  %2 = alloca [3 x i16]*, i16 1, align 8, !dbg !1067
  store [3 x i16]* %0, [3 x i16]** %2, align 8, !dbg !1067
  %3 = load [3 x i16]*, [3 x i16]** %2, align 8, !dbg !1069
  call void @timestamp.ts.get_value([3 x i16]* %3, i16 31536), !dbg !1070
  ret void, !dbg !1071
}

define internal void @timestamp.ts.reset_tsc_counter() !dbg !1072 {
  store volatile i16 0, i16* inttoptr (i16 -2464 to i16*), align 2, !dbg !1073
  store volatile i16 0, i16* inttoptr (i16 -2462 to i16*), align 2, !dbg !1073
  store volatile i16 0, i16* inttoptr (i16 -2460 to i16*), align 2, !dbg !1073
  ret void, !dbg !1075
}

define internal i16* @.get_tensor_ptr(i16 %0) !dbg !1076 {
  %2 = alloca i16, i16 1, align 2, !dbg !1077
  store i16 %0, i16* %2, align 2, !dbg !1077
  %3 = load i16, i16* %2, align 2, !dbg !1077
  %4 = zext i16 %3 to i32, !dbg !1077
  switch i32 %4, label %5 [
    i32 1, label %9
    i32 2, label %12
    i32 3, label %15
    i32 4, label %18
    i32 5, label %21
    i32 6, label %24
  ], !dbg !1077

5:                                                ; preds = %1
  br i1 false, label %6, label %7, !dbg !1077

6:                                                ; preds = %5
  br label %8, !dbg !1077

7:                                                ; preds = %5
  call void asm sideeffect "hcf", ""(), !dbg !1077
  br label %8, !dbg !1077

8:                                                ; preds = %6, %7
  br label %27, !dbg !1077

9:                                                ; preds = %1
  %10 = load i32*, i32** @ptr_row_ptr, align 8, !dbg !1077
  %11 = bitcast i32* %10 to i16*, !dbg !1077
  br label %27, !dbg !1077

12:                                               ; preds = %1
  %13 = load i32*, i32** @ptr_col_idx, align 8, !dbg !1077
  %14 = bitcast i32* %13 to i16*, !dbg !1077
  br label %27, !dbg !1077

15:                                               ; preds = %1
  %16 = load float*, float** @ptr_val, align 8, !dbg !1077
  %17 = bitcast float* %16 to i16*, !dbg !1077
  br label %27, !dbg !1077

18:                                               ; preds = %1
  %19 = load float*, float** @ptr_x, align 8, !dbg !1077
  %20 = bitcast float* %19 to i16*, !dbg !1077
  br label %27, !dbg !1077

21:                                               ; preds = %1
  %22 = load float*, float** @ptr_y, align 8, !dbg !1077
  %23 = bitcast float* %22 to i16*, !dbg !1077
  br label %27, !dbg !1077

24:                                               ; preds = %1
  %25 = load float*, float** @ptr_timer_buf, align 8, !dbg !1077
  %26 = bitcast float* %25 to i16*, !dbg !1077
  br label %27, !dbg !1077

27:                                               ; preds = %8, %9, %12, %15, %18, %21, %24
  %28 = phi i16 [ -2, %24 ], [ -2, %21 ], [ -2, %18 ], [ -2, %15 ], [ -2, %12 ], [ -2, %9 ], [ 0, %8 ]
  %29 = phi i16* [ %26, %24 ], [ %23, %21 ], [ %20, %18 ], [ %17, %15 ], [ %14, %12 ], [ %11, %9 ], [ undef, %8 ]
  br label %30, !dbg !1077

30:                                               ; preds = %27
  %31 = icmp ne i16 %28, 0, !dbg !1077
  br i1 %31, label %32, label %33, !dbg !1077

32:                                               ; preds = %30
  br label %36, !dbg !1077

33:                                               ; preds = %30
  %34 = load float*, float** @ptr_timer_buf, align 8, !dbg !1077
  %35 = bitcast float* %34 to i16*, !dbg !1077
  br label %36, !dbg !1077

36:                                               ; preds = %32, %33
  %37 = phi i16* [ %35, %33 ], [ %29, %32 ]
  br label %38, !dbg !1077

38:                                               ; preds = %36
  ret i16* %37, !dbg !1077
}

define internal void @__generic0sys_mod.sys_mod.tile_config.queue_flush.exit() !dbg !1079 {
  store volatile i16 1, i16* inttoptr (i16 -2268 to i16*), align 2, !dbg !1081
  call void asm sideeffect "nop", ""(), !dbg !1081
  call void asm sideeffect "nop", ""(), !dbg !1081
  ret void, !dbg !1083
}

define internal void @__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position(i16 %0) !dbg !1084 {
  %2 = alloca i16, i16 1, align 2, !dbg !1086
  %3 = alloca i16, i16 1, align 2, !dbg !1088
  %4 = alloca i16, i16 1, align 2, !dbg !1089
  store i16 %0, i16* %4, align 2, !dbg !1089
  %5 = load i16, i16* %4, align 2, !dbg !1090
  store i16 %5, i16* %3, align 2, !dbg !1088
  %6 = load i16, i16* %3, align 2, !dbg !1091
  %7 = shl i16 %6, 1, !dbg !1092
  %8 = inttoptr i16 %7 to i16*, !dbg !1092
  call void asm sideeffect "nop", ""(), !dbg !1092
  call void asm sideeffect "nop", ""(), !dbg !1092
  call void asm sideeffect "nop", ""(), !dbg !1092
  call void asm sideeffect "nop", ""(), !dbg !1092
  %9 = load volatile i16, i16* %8, align 2, !dbg !1092
  store i16 %9, i16* %2, align 2, !dbg !1086
  %10 = load i16, i16* %2, align 2, !dbg !1093
  %11 = and i16 %10, -16, !dbg !1094
  store i16 %11, i16* %2, align 2, !dbg !1094
  %12 = load i16, i16* %3, align 2, !dbg !1095
  %13 = load i16, i16* %2, align 2, !dbg !1096
  %14 = shl i16 %12, 1, !dbg !1097
  %15 = inttoptr i16 %14 to i16*, !dbg !1097
  store volatile i16 %13, i16* %15, align 2, !dbg !1097
  call void asm sideeffect "nop", ""(), !dbg !1097
  call void asm sideeffect "nop", ""(), !dbg !1097
  call void asm sideeffect "nop", ""(), !dbg !1097
  call void asm sideeffect "nop", ""(), !dbg !1097
  ret void, !dbg !1098
}

define internal void @__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 %0) !dbg !1099 {
  %2 = alloca i16, i16 1, align 2, !dbg !1101
  %3 = alloca i16, i16 1, align 2, !dbg !1103
  %4 = alloca i16, i16 1, align 2, !dbg !1104
  store i16 %0, i16* %4, align 2, !dbg !1104
  %5 = load i16, i16* %4, align 2, !dbg !1105
  store i16 %5, i16* %3, align 2, !dbg !1103
  %6 = load i16, i16* %3, align 2, !dbg !1106
  %7 = shl i16 %6, 1, !dbg !1107
  %8 = inttoptr i16 %7 to i16*, !dbg !1107
  call void asm sideeffect "nop", ""(), !dbg !1107
  call void asm sideeffect "nop", ""(), !dbg !1107
  %9 = load volatile i16, i16* %8, align 2, !dbg !1107
  store i16 %9, i16* %2, align 2, !dbg !1101
  %10 = load i16, i16* %2, align 2, !dbg !1108
  %11 = and i16 %10, -256, !dbg !1109
  store i16 %11, i16* %2, align 2, !dbg !1110
  %12 = load i16, i16* %2, align 2, !dbg !1111
  %13 = load i16, i16* %2, align 2, !dbg !1112
  %14 = call i16 @__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %13), !dbg !1113
  %15 = or i16 %12, %14, !dbg !1114
  store i16 %15, i16* %2, align 2, !dbg !1114
  %16 = load i16, i16* %2, align 2, !dbg !1115
  %17 = load i16, i16* %2, align 2, !dbg !1116
  %18 = call i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %17), !dbg !1117
  %19 = or i16 %16, %18, !dbg !1118
  store i16 %19, i16* %2, align 2, !dbg !1118
  %20 = load i16, i16* %3, align 2, !dbg !1119
  %21 = load i16, i16* %2, align 2, !dbg !1120
  %22 = shl i16 %20, 1, !dbg !1121
  %23 = inttoptr i16 %22 to i16*, !dbg !1121
  store volatile i16 %21, i16* %23, align 2, !dbg !1121
  call void asm sideeffect "nop", ""(), !dbg !1121
  call void asm sideeffect "nop", ""(), !dbg !1121
  ret void, !dbg !1122
}

define internal void @__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 %0) !dbg !1123 {
  %2 = alloca i16, i16 1, align 2, !dbg !1124
  %3 = alloca i16, i16 1, align 2, !dbg !1126
  %4 = alloca i16, i16 1, align 2, !dbg !1127
  store i16 %0, i16* %4, align 2, !dbg !1127
  %5 = load i16, i16* %4, align 2, !dbg !1128
  store i16 %5, i16* %3, align 2, !dbg !1126
  %6 = load i16, i16* %3, align 2, !dbg !1129
  %7 = shl i16 %6, 1, !dbg !1130
  %8 = inttoptr i16 %7 to i16*, !dbg !1130
  call void asm sideeffect "nop", ""(), !dbg !1130
  call void asm sideeffect "nop", ""(), !dbg !1130
  %9 = load volatile i16, i16* %8, align 2, !dbg !1130
  store i16 %9, i16* %2, align 2, !dbg !1124
  %10 = load i16, i16* %2, align 2, !dbg !1131
  %11 = and i16 %10, -256, !dbg !1132
  store i16 %11, i16* %2, align 2, !dbg !1133
  %12 = load i16, i16* %2, align 2, !dbg !1134
  %13 = load i16, i16* %2, align 2, !dbg !1135
  %14 = call i16 @__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %13), !dbg !1136
  %15 = or i16 %12, %14, !dbg !1137
  store i16 %15, i16* %2, align 2, !dbg !1137
  %16 = load i16, i16* %2, align 2, !dbg !1138
  %17 = load i16, i16* %2, align 2, !dbg !1139
  %18 = call i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %17), !dbg !1140
  %19 = or i16 %16, %18, !dbg !1141
  store i16 %19, i16* %2, align 2, !dbg !1141
  %20 = load i16, i16* %3, align 2, !dbg !1142
  %21 = load i16, i16* %2, align 2, !dbg !1143
  %22 = shl i16 %20, 1, !dbg !1144
  %23 = inttoptr i16 %22 to i16*, !dbg !1144
  store volatile i16 %21, i16* %23, align 2, !dbg !1144
  call void asm sideeffect "nop", ""(), !dbg !1144
  call void asm sideeffect "nop", ""(), !dbg !1144
  ret void, !dbg !1145
}

define internal i16 @__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %0) !dbg !1146 {
  %2 = alloca i16, i16 1, align 2, !dbg !1147
  %3 = alloca i16, i16 1, align 2, !dbg !1149
  store i16 %0, i16* %3, align 2, !dbg !1149
  %4 = load i16, i16* %3, align 2, !dbg !1150
  store i16 %4, i16* %2, align 2, !dbg !1147
  %5 = load i16, i16* %2, align 2, !dbg !1151
  store i16 %5, i16* %2, align 2, !dbg !1152
  %6 = load i16, i16* %2, align 2, !dbg !1153
  ret i16 %6, !dbg !1154
}

define internal i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %0) !dbg !1155 {
  %2 = alloca i16, i16 1, align 2, !dbg !1156
  %3 = alloca i16, i16 1, align 2, !dbg !1158
  store i16 %0, i16* %3, align 2, !dbg !1158
  %4 = load i16, i16* %3, align 2, !dbg !1159
  store i16 %4, i16* %2, align 2, !dbg !1156
  %5 = load i16, i16* %2, align 2, !dbg !1160
  %6 = or i16 %5, 2, !dbg !1161
  store i16 %6, i16* %2, align 2, !dbg !1161
  %7 = load i16, i16* %2, align 2, !dbg !1162
  ret i16 %7, !dbg !1163
}

define internal i16 @__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %0) !dbg !1164 {
  %2 = alloca i16, i16 1, align 2, !dbg !1165
  %3 = alloca i16, i16 1, align 2, !dbg !1167
  store i16 %0, i16* %3, align 2, !dbg !1167
  %4 = load i16, i16* %3, align 2, !dbg !1168
  store i16 %4, i16* %2, align 2, !dbg !1165
  %5 = load i16, i16* %2, align 2, !dbg !1169
  %6 = or i16 %5, 128, !dbg !1170
  store i16 %6, i16* %2, align 2, !dbg !1170
  %7 = load i16, i16* %2, align 2, !dbg !1171
  ret i16 %7, !dbg !1172
}

define internal void @__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction(i16 %0) !dbg !1173 {
  %2 = alloca i16, i16 1, align 2, !dbg !1174
  %3 = alloca i16, i16 1, align 2, !dbg !1176
  %4 = alloca i16, i16 1, align 2, !dbg !1177
  store i16 %0, i16* %4, align 2, !dbg !1177
  %5 = load i16, i16* %4, align 2, !dbg !1178
  store i16 %5, i16* %3, align 2, !dbg !1176
  %6 = load i16, i16* %3, align 2, !dbg !1179
  %7 = shl i16 %6, 1, !dbg !1180
  %8 = inttoptr i16 %7 to i16*, !dbg !1180
  call void asm sideeffect "nop", ""(), !dbg !1180
  call void asm sideeffect "nop", ""(), !dbg !1180
  %9 = load volatile i16, i16* %8, align 2, !dbg !1180
  store i16 %9, i16* %2, align 2, !dbg !1174
  %10 = load i16, i16* %2, align 2, !dbg !1181
  %11 = and i16 %10, -17, !dbg !1182
  store i16 %11, i16* %2, align 2, !dbg !1182
  %12 = load i16, i16* %3, align 2, !dbg !1183
  %13 = load i16, i16* %2, align 2, !dbg !1184
  %14 = shl i16 %12, 1, !dbg !1185
  %15 = inttoptr i16 %14 to i16*, !dbg !1185
  store volatile i16 %13, i16* %15, align 2, !dbg !1185
  call void asm sideeffect "nop", ""(), !dbg !1185
  call void asm sideeffect "nop", ""(), !dbg !1185
  ret void, !dbg !1186
}

define internal void @__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction(i16 %0) !dbg !1187 {
  %2 = alloca i16, i16 1, align 2, !dbg !1188
  %3 = alloca i16, i16 1, align 2, !dbg !1190
  %4 = alloca i16, i16 1, align 2, !dbg !1191
  store i16 %0, i16* %4, align 2, !dbg !1191
  %5 = load i16, i16* %4, align 2, !dbg !1192
  store i16 %5, i16* %3, align 2, !dbg !1190
  %6 = load i16, i16* %3, align 2, !dbg !1193
  %7 = shl i16 %6, 1, !dbg !1194
  %8 = inttoptr i16 %7 to i16*, !dbg !1194
  call void asm sideeffect "nop", ""(), !dbg !1194
  call void asm sideeffect "nop", ""(), !dbg !1194
  %9 = load volatile i16, i16* %8, align 2, !dbg !1194
  store i16 %9, i16* %2, align 2, !dbg !1188
  %10 = load i16, i16* %2, align 2, !dbg !1195
  %11 = or i16 %10, 16, !dbg !1196
  store i16 %11, i16* %2, align 2, !dbg !1196
  %12 = load i16, i16* %3, align 2, !dbg !1197
  %13 = load i16, i16* %2, align 2, !dbg !1198
  %14 = shl i16 %12, 1, !dbg !1199
  %15 = inttoptr i16 %14 to i16*, !dbg !1199
  store volatile i16 %13, i16* %15, align 2, !dbg !1199
  call void asm sideeffect "nop", ""(), !dbg !1199
  call void asm sideeffect "nop", ""(), !dbg !1199
  ret void, !dbg !1200
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
!3 = distinct !DISubprogram(name: "spmv_csr", linkageName: "spmv_csr", scope: null, file: !4, line: 41, type: !5, scopeLine: 41, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!4 = !DIFile(filename: "./pe.csl", directory: "/home/USER/xkernel/code_translation/results/probe_sdk210/spmv210")
!5 = !DISubroutineType(types: !6)
!6 = !{}
!7 = !DILocation(line: 49, column: 7, scope: !8)
!8 = !DILexicalBlockFile(scope: !3, file: !4, discriminator: 0)
!9 = !DILocation(line: 47, column: 5, scope: !8)
!10 = !DILocation(line: 46, column: 5, scope: !8)
!11 = !DILocation(line: 45, column: 5, scope: !8)
!12 = !DILocation(line: 44, column: 5, scope: !8)
!13 = !DILocation(line: 42, column: 3, scope: !8)
!14 = !DILocation(line: 43, column: 3, scope: !8)
!15 = !DILocation(line: 43, column: 10, scope: !8)
!16 = !DILocation(line: 43, column: 12, scope: !8)
!17 = !DILocation(line: 44, column: 38, scope: !8)
!18 = !DILocation(line: 44, column: 37, scope: !8)
!19 = !DILocation(line: 45, column: 38, scope: !8)
!20 = !DILocation(line: 45, column: 40, scope: !8)
!21 = !DILocation(line: 45, column: 37, scope: !8)
!22 = !DILocation(line: 47, column: 18, scope: !8)
!23 = !DILocation(line: 48, column: 5, scope: !8)
!24 = !DILocation(line: 48, column: 12, scope: !8)
!25 = !DILocation(line: 48, column: 16, scope: !8)
!26 = !DILocation(line: 48, column: 14, scope: !8)
!27 = !DILocation(line: 49, column: 36, scope: !8)
!28 = !DILocation(line: 49, column: 35, scope: !8)
!29 = !DILocation(line: 50, column: 7, scope: !8)
!30 = !DILocation(line: 50, column: 24, scope: !8)
!31 = !DILocation(line: 50, column: 23, scope: !8)
!32 = !DILocation(line: 50, column: 37, scope: !8)
!33 = !DILocation(line: 50, column: 36, scope: !8)
!34 = !DILocation(line: 50, column: 27, scope: !8)
!35 = !DILocation(line: 50, column: 11, scope: !8)
!36 = !DILocation(line: 48, column: 24, scope: !8)
!37 = !DILocation(line: 48, column: 26, scope: !8)
!38 = !DILocation(line: 52, column: 18, scope: !8)
!39 = !DILocation(line: 52, column: 13, scope: !8)
!40 = !DILocation(line: 52, column: 12, scope: !8)
!41 = !DILocation(line: 52, column: 16, scope: !8)
!42 = !DILocation(line: 43, column: 24, scope: !8)
!43 = !DILocation(line: 43, column: 26, scope: !8)
!44 = distinct !DISubprogram(name: "compute", linkageName: "compute", scope: null, file: !4, line: 56, type: !5, scopeLine: 56, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!45 = !DILocation(line: 69, column: 3, scope: !46)
!46 = !DILexicalBlockFile(scope: !44, file: !4, discriminator: 0)
!47 = !DILocation(line: 68, column: 3, scope: !46)
!48 = !DILocation(line: 60, column: 3, scope: !46)
!49 = !DILocation(line: 60, column: 29, scope: !46)
!50 = !DILocation(line: 60, column: 8, scope: !46)
!51 = !DILocation(line: 57, column: 3, scope: !46)
!52 = !DILocation(line: 58, column: 3, scope: !46)
!53 = !DILocation(line: 61, column: 5, scope: !46)
!54 = !DILocation(line: 64, column: 3, scope: !46)
!55 = !DILocation(line: 65, column: 3, scope: !46)
!56 = !DILocation(line: 71, column: 22, scope: !46)
!57 = !DILocation(line: 71, column: 7, scope: !46)
!58 = !DILocation(line: 72, column: 22, scope: !46)
!59 = !DILocation(line: 72, column: 7, scope: !46)
!60 = !DILocation(line: 73, column: 42, scope: !46)
!61 = !DILocation(line: 73, column: 33, scope: !46)
!62 = !DILocation(line: 73, column: 47, scope: !46)
!63 = !DILocation(line: 73, column: 75, scope: !46)
!64 = !DILocation(line: 73, column: 66, scope: !46)
!65 = !DILocation(line: 73, column: 64, scope: !46)
!66 = !DILocation(line: 73, column: 18, scope: !46)
!67 = !DILocation(line: 73, column: 16, scope: !46)
!68 = !DILocation(line: 75, column: 22, scope: !46)
!69 = !DILocation(line: 75, column: 7, scope: !46)
!70 = !DILocation(line: 76, column: 20, scope: !46)
!71 = !DILocation(line: 76, column: 7, scope: !46)
!72 = !DILocation(line: 77, column: 42, scope: !46)
!73 = !DILocation(line: 77, column: 33, scope: !46)
!74 = !DILocation(line: 77, column: 47, scope: !46)
!75 = !DILocation(line: 77, column: 75, scope: !46)
!76 = !DILocation(line: 77, column: 66, scope: !46)
!77 = !DILocation(line: 77, column: 64, scope: !46)
!78 = !DILocation(line: 77, column: 18, scope: !46)
!79 = !DILocation(line: 77, column: 16, scope: !46)
!80 = !DILocation(line: 79, column: 20, scope: !46)
!81 = !DILocation(line: 79, column: 7, scope: !46)
!82 = !DILocation(line: 80, column: 20, scope: !46)
!83 = !DILocation(line: 80, column: 7, scope: !46)
!84 = !DILocation(line: 81, column: 42, scope: !46)
!85 = !DILocation(line: 81, column: 33, scope: !46)
!86 = !DILocation(line: 81, column: 47, scope: !46)
!87 = !DILocation(line: 81, column: 75, scope: !46)
!88 = !DILocation(line: 81, column: 66, scope: !46)
!89 = !DILocation(line: 81, column: 64, scope: !46)
!90 = !DILocation(line: 81, column: 18, scope: !46)
!91 = !DILocation(line: 81, column: 16, scope: !46)
!92 = !DILocation(line: 83, column: 3, scope: !46)
!93 = distinct !DISubprogram(name: "f_exit", linkageName: "f_exit", scope: null, file: !4, line: 86, type: !5, scopeLine: 86, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!94 = !DILocation(line: 87, column: 3, scope: !95)
!95 = !DILexicalBlockFile(scope: !93, file: !4, discriminator: 0)
!96 = !DILocation(line: 86, column: 1, scope: !95)
!97 = distinct !DISubprogram(name: "sys_mod.sys_nop", linkageName: "sys_mod.sys_nop", scope: null, file: !98, line: 90, type: !5, scopeLine: 90, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!98 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/memcpy.csl", directory: "")
!99 = !DILocation(line: 90, column: 1, scope: !100)
!100 = !DILexicalBlockFile(scope: !97, file: !98, discriminator: 0)
!101 = distinct !DISubprogram(name: "sys_mod.unblock_cmd_stream", linkageName: "sys_mod.unblock_cmd_stream", scope: null, file: !98, line: 102, type: !5, scopeLine: 102, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!102 = !DILocation(line: 103, column: 3, scope: !103)
!103 = !DILexicalBlockFile(scope: !101, file: !98, discriminator: 0)
!104 = !DILocation(line: 102, column: 1, scope: !103)
!105 = distinct !DISubprogram(name: "sys_mod.sys_mod.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.unblock_cmd_stream", scope: null, file: !106, line: 307, type: !5, scopeLine: 307, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!106 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpy.csl", directory: "")
!107 = !DILocation(line: 308, column: 5, scope: !108)
!108 = !DILexicalBlockFile(scope: !105, file: !106, discriminator: 0)
!109 = !DILocation(line: 307, column: 1, scope: !108)
!110 = distinct !DISubprogram(name: "sys_mod.sys_mod.teardown_h2d", linkageName: "sys_mod.sys_mod.teardown_h2d", scope: null, file: !106, line: 323, type: !5, scopeLine: 323, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!111 = !DILocation(line: 326, column: 5, scope: !112)
!112 = !DILexicalBlockFile(scope: !110, file: !106, discriminator: 0)
!113 = !DILocation(line: 323, column: 1, scope: !112)
!114 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_ublk_c22", linkageName: "sys_mod.sys_mod.f_ublk_c22", scope: null, file: !106, line: 335, type: !5, scopeLine: 335, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!115 = !DILocation(line: 336, column: 5, scope: !116)
!116 = !DILexicalBlockFile(scope: !114, file: !106, discriminator: 0)
!117 = !DILocation(line: 335, column: 1, scope: !116)
!118 = distinct !DISubprogram(name: "sys_mod.sys_mod.teardown_d2h", linkageName: "sys_mod.sys_mod.teardown_d2h", scope: null, file: !106, line: 344, type: !5, scopeLine: 344, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!119 = !DILocation(line: 355, column: 5, scope: !120)
!120 = !DILexicalBlockFile(scope: !118, file: !106, discriminator: 0)
!121 = !DILocation(line: 359, column: 5, scope: !120)
!122 = !DILocation(line: 344, column: 1, scope: !120)
!123 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_memcpyh2d", linkageName: "sys_mod.sys_mod.f_memcpyh2d", scope: null, file: !106, line: 460, type: !5, scopeLine: 460, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!124 = !DILocation(line: 477, column: 5, scope: !125)
!125 = !DILexicalBlockFile(scope: !123, file: !106, discriminator: 0)
!126 = !DILocation(line: 476, column: 5, scope: !125)
!127 = !DILocation(line: 475, column: 5, scope: !125)
!128 = !DILocation(line: 474, column: 5, scope: !125)
!129 = !DILocation(line: 473, column: 5, scope: !125)
!130 = !DILocation(line: 472, column: 5, scope: !125)
!131 = !DILocation(line: 471, column: 5, scope: !125)
!132 = !DILocation(line: 470, column: 5, scope: !125)
!133 = !DILocation(line: 469, column: 5, scope: !125)
!134 = !DILocation(line: 468, column: 5, scope: !125)
!135 = !DILocation(line: 467, column: 5, scope: !125)
!136 = !DILocation(line: 466, column: 5, scope: !125)
!137 = !DILocation(line: 465, column: 5, scope: !125)
!138 = !DILocation(line: 463, column: 5, scope: !125)
!139 = !DILocation(line: 462, column: 20, scope: !125)
!140 = !DILocation(line: 462, column: 32, scope: !125)
!141 = !DILocation(line: 462, column: 5, scope: !125)
!142 = !DILocation(line: 465, column: 33, scope: !125)
!143 = !DILocation(line: 465, column: 38, scope: !125)
!144 = !DILocation(line: 466, column: 34, scope: !125)
!145 = !DILocation(line: 466, column: 39, scope: !125)
!146 = !DILocation(line: 467, column: 34, scope: !125)
!147 = !DILocation(line: 467, column: 39, scope: !125)
!148 = !DILocation(line: 468, column: 33, scope: !125)
!149 = !DILocation(line: 468, column: 38, scope: !125)
!150 = !DILocation(line: 469, column: 33, scope: !125)
!151 = !DILocation(line: 469, column: 38, scope: !125)
!152 = !DILocation(line: 470, column: 35, scope: !125)
!153 = !DILocation(line: 470, column: 21, scope: !125)
!154 = !DILocation(line: 471, column: 41, scope: !125)
!155 = !DILocation(line: 471, column: 27, scope: !125)
!156 = !DILocation(line: 472, column: 39, scope: !125)
!157 = !DILocation(line: 472, column: 25, scope: !125)
!158 = !DILocation(line: 473, column: 44, scope: !125)
!159 = !DILocation(line: 473, column: 49, scope: !125)
!160 = !DILocation(line: 474, column: 41, scope: !125)
!161 = !DILocation(line: 474, column: 46, scope: !125)
!162 = !DILocation(line: 475, column: 41, scope: !125)
!163 = !DILocation(line: 475, column: 46, scope: !125)
!164 = !DILocation(line: 476, column: 59, scope: !125)
!165 = !DILocation(line: 476, column: 64, scope: !125)
!166 = !DILocation(line: 476, column: 50, scope: !125)
!167 = !DILocation(line: 476, column: 129, scope: !125)
!168 = !DILocation(line: 476, column: 134, scope: !125)
!169 = !DILocation(line: 476, column: 120, scope: !125)
!170 = !DILocation(line: 476, column: 118, scope: !125)
!171 = !DILocation(line: 476, column: 112, scope: !125)
!172 = !DILocation(line: 476, column: 36, scope: !125)
!173 = !DILocation(line: 477, column: 59, scope: !125)
!174 = !DILocation(line: 477, column: 64, scope: !125)
!175 = !DILocation(line: 477, column: 50, scope: !125)
!176 = !DILocation(line: 477, column: 129, scope: !125)
!177 = !DILocation(line: 477, column: 134, scope: !125)
!178 = !DILocation(line: 477, column: 120, scope: !125)
!179 = !DILocation(line: 477, column: 118, scope: !125)
!180 = !DILocation(line: 477, column: 112, scope: !125)
!181 = !DILocation(line: 477, column: 36, scope: !125)
!182 = !DILocation(line: 479, column: 24, scope: !125)
!183 = !DILocation(line: 481, column: 21, scope: !125)
!184 = !DILocation(line: 481, column: 19, scope: !125)
!185 = !DILocation(line: 482, column: 21, scope: !125)
!186 = !DILocation(line: 482, column: 19, scope: !125)
!187 = !DILocation(line: 483, column: 21, scope: !125)
!188 = !DILocation(line: 483, column: 19, scope: !125)
!189 = !DILocation(line: 484, column: 20, scope: !125)
!190 = !DILocation(line: 484, column: 18, scope: !125)
!191 = !DILocation(line: 485, column: 20, scope: !125)
!192 = !DILocation(line: 485, column: 18, scope: !125)
!193 = !DILocation(line: 486, column: 22, scope: !125)
!194 = !DILocation(line: 486, column: 20, scope: !125)
!195 = !DILocation(line: 487, column: 27, scope: !125)
!196 = !DILocation(line: 487, column: 25, scope: !125)
!197 = !DILocation(line: 488, column: 25, scope: !125)
!198 = !DILocation(line: 488, column: 23, scope: !125)
!199 = !DILocation(line: 489, column: 31, scope: !125)
!200 = !DILocation(line: 489, column: 29, scope: !125)
!201 = !DILocation(line: 490, column: 28, scope: !125)
!202 = !DILocation(line: 490, column: 26, scope: !125)
!203 = !DILocation(line: 491, column: 28, scope: !125)
!204 = !DILocation(line: 491, column: 26, scope: !125)
!205 = !DILocation(line: 492, column: 37, scope: !125)
!206 = !DILocation(line: 492, column: 35, scope: !125)
!207 = !DILocation(line: 493, column: 37, scope: !125)
!208 = !DILocation(line: 493, column: 35, scope: !125)
!209 = !DILocation(line: 495, column: 5, scope: !125)
!210 = !DILocation(line: 501, column: 5, scope: !125)
!211 = !DILocation(line: 506, column: 5, scope: !125)
!212 = !DILocation(line: 521, column: 5, scope: !125)
!213 = !DILocation(line: 522, column: 16, scope: !125)
!214 = !DILocation(line: 531, column: 5, scope: !125)
!215 = !DILocation(line: 460, column: 1, scope: !125)
!216 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_memcpyd2h", linkageName: "sys_mod.sys_mod.f_memcpyd2h", scope: null, file: !106, line: 556, type: !5, scopeLine: 556, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!217 = !DILocation(line: 568, column: 5, scope: !218)
!218 = !DILexicalBlockFile(scope: !216, file: !106, discriminator: 0)
!219 = !DILocation(line: 567, column: 5, scope: !218)
!220 = !DILocation(line: 566, column: 5, scope: !218)
!221 = !DILocation(line: 565, column: 5, scope: !218)
!222 = !DILocation(line: 564, column: 5, scope: !218)
!223 = !DILocation(line: 563, column: 5, scope: !218)
!224 = !DILocation(line: 562, column: 5, scope: !218)
!225 = !DILocation(line: 561, column: 5, scope: !218)
!226 = !DILocation(line: 559, column: 5, scope: !218)
!227 = !DILocation(line: 558, column: 20, scope: !218)
!228 = !DILocation(line: 558, column: 32, scope: !218)
!229 = !DILocation(line: 558, column: 5, scope: !218)
!230 = !DILocation(line: 561, column: 33, scope: !218)
!231 = !DILocation(line: 561, column: 38, scope: !218)
!232 = !DILocation(line: 562, column: 34, scope: !218)
!233 = !DILocation(line: 562, column: 39, scope: !218)
!234 = !DILocation(line: 563, column: 34, scope: !218)
!235 = !DILocation(line: 563, column: 39, scope: !218)
!236 = !DILocation(line: 564, column: 33, scope: !218)
!237 = !DILocation(line: 564, column: 38, scope: !218)
!238 = !DILocation(line: 565, column: 33, scope: !218)
!239 = !DILocation(line: 565, column: 38, scope: !218)
!240 = !DILocation(line: 566, column: 35, scope: !218)
!241 = !DILocation(line: 566, column: 21, scope: !218)
!242 = !DILocation(line: 567, column: 41, scope: !218)
!243 = !DILocation(line: 567, column: 27, scope: !218)
!244 = !DILocation(line: 568, column: 39, scope: !218)
!245 = !DILocation(line: 568, column: 25, scope: !218)
!246 = !DILocation(line: 570, column: 24, scope: !218)
!247 = !DILocation(line: 573, column: 21, scope: !218)
!248 = !DILocation(line: 573, column: 19, scope: !218)
!249 = !DILocation(line: 574, column: 21, scope: !218)
!250 = !DILocation(line: 574, column: 19, scope: !218)
!251 = !DILocation(line: 575, column: 21, scope: !218)
!252 = !DILocation(line: 575, column: 19, scope: !218)
!253 = !DILocation(line: 576, column: 20, scope: !218)
!254 = !DILocation(line: 576, column: 18, scope: !218)
!255 = !DILocation(line: 577, column: 20, scope: !218)
!256 = !DILocation(line: 577, column: 18, scope: !218)
!257 = !DILocation(line: 578, column: 22, scope: !218)
!258 = !DILocation(line: 578, column: 20, scope: !218)
!259 = !DILocation(line: 579, column: 27, scope: !218)
!260 = !DILocation(line: 579, column: 25, scope: !218)
!261 = !DILocation(line: 580, column: 25, scope: !218)
!262 = !DILocation(line: 580, column: 23, scope: !218)
!263 = !DILocation(line: 582, column: 5, scope: !218)
!264 = !DILocation(line: 588, column: 59, scope: !218)
!265 = !DILocation(line: 588, column: 5, scope: !218)
!266 = !DILocation(line: 608, column: 5, scope: !218)
!267 = !DILocation(line: 609, column: 16, scope: !218)
!268 = !DILocation(line: 556, column: 1, scope: !218)
!269 = distinct !DISubprogram(name: "sys_mod.sys_mod.oq0_teardow_handler", linkageName: "sys_mod.sys_mod.oq0_teardow_handler", scope: null, file: !106, line: 631, type: !5, scopeLine: 631, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!270 = !DILocation(line: 632, column: 9, scope: !271)
!271 = !DILexicalBlockFile(scope: !269, file: !106, discriminator: 0)
!272 = !DILocation(line: 632, column: 5, scope: !271)
!273 = !DILocation(line: 634, column: 66, scope: !271)
!274 = !DILocation(line: 634, column: 9, scope: !271)
!275 = !DILocation(line: 636, column: 13, scope: !271)
!276 = !DILocation(line: 637, column: 13, scope: !271)
!277 = !DILocation(line: 638, column: 13, scope: !271)
!278 = !DILocation(line: 639, column: 13, scope: !271)
!279 = !DILocation(line: 640, column: 13, scope: !271)
!280 = !DILocation(line: 641, column: 13, scope: !271)
!281 = !DILocation(line: 642, column: 13, scope: !271)
!282 = !DILocation(line: 643, column: 13, scope: !271)
!283 = !DILocation(line: 644, column: 13, scope: !271)
!284 = !DILocation(line: 645, column: 13, scope: !271)
!285 = !DILocation(line: 646, column: 13, scope: !271)
!286 = !DILocation(line: 647, column: 13, scope: !271)
!287 = !DILocation(line: 648, column: 13, scope: !271)
!288 = !DILocation(line: 635, column: 9, scope: !271)
!289 = !DILocation(line: 652, column: 9, scope: !271)
!290 = !DILocation(line: 654, column: 13, scope: !271)
!291 = !DILocation(line: 655, column: 13, scope: !271)
!292 = !DILocation(line: 656, column: 13, scope: !271)
!293 = !DILocation(line: 657, column: 13, scope: !271)
!294 = !DILocation(line: 658, column: 13, scope: !271)
!295 = !DILocation(line: 659, column: 13, scope: !271)
!296 = !DILocation(line: 660, column: 13, scope: !271)
!297 = !DILocation(line: 661, column: 13, scope: !271)
!298 = !DILocation(line: 653, column: 9, scope: !271)
!299 = !DILocation(line: 664, column: 5, scope: !271)
!300 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_rpc", linkageName: "sys_mod.sys_mod.f_rpc", scope: null, file: !106, line: 694, type: !5, scopeLine: 694, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!301 = !DILocation(line: 694, column: 13, scope: !302)
!302 = !DILexicalBlockFile(scope: !300, file: !106, discriminator: 0)
!303 = !DILocation(line: 700, column: 5, scope: !302)
!304 = !DILocation(line: 706, column: 20, scope: !302)
!305 = !DILocation(line: 706, column: 32, scope: !302)
!306 = !DILocation(line: 706, column: 5, scope: !302)
!307 = !DILocation(line: 710, column: 5, scope: !302)
!308 = !DILocation(line: 712, column: 24, scope: !302)
!309 = !DILocation(line: 694, column: 1, scope: !302)
!310 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.stack_push", linkageName: "sys_mod.sys_mod.sys_mod.stack_push", scope: null, file: !311, line: 54, type: !5, scopeLine: 54, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!311 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/sys.csl", directory: "")
!312 = !DILocation(line: 60, column: 5, scope: !313)
!313 = !DILexicalBlockFile(scope: !310, file: !311, discriminator: 0)
!314 = !DILocation(line: 54, column: 16, scope: !313)
!315 = !DILocation(line: 59, column: 13, scope: !313)
!316 = !DILocation(line: 59, column: 24, scope: !313)
!317 = !DILocation(line: 59, column: 5, scope: !313)
!318 = !DILocation(line: 61, column: 25, scope: !313)
!319 = !DILocation(line: 61, column: 5, scope: !313)
!320 = !DILocation(line: 61, column: 11, scope: !313)
!321 = !DILocation(line: 61, column: 10, scope: !313)
!322 = !DILocation(line: 61, column: 23, scope: !313)
!323 = !DILocation(line: 62, column: 18, scope: !313)
!324 = !DILocation(line: 62, column: 29, scope: !313)
!325 = !DILocation(line: 62, column: 16, scope: !313)
!326 = !DILocation(line: 54, column: 1, scope: !313)
!327 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_push", linkageName: "sys_mod.sys_mod.sys_mod.f_push", scope: null, file: !311, line: 72, type: !5, scopeLine: 72, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!328 = !DILocation(line: 72, column: 25, scope: !329)
!329 = !DILexicalBlockFile(scope: !327, file: !311, discriminator: 0)
!330 = !DILocation(line: 72, column: 13, scope: !329)
!331 = !DILocation(line: 73, column: 16, scope: !329)
!332 = !DILocation(line: 73, column: 5, scope: !329)
!333 = !DILocation(line: 72, column: 1, scope: !329)
!334 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.block_cmd_stream", linkageName: "sys_mod.sys_mod.sys_mod.block_cmd_stream", scope: null, file: !311, line: 76, type: !5, scopeLine: 76, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!335 = !DILocation(line: 77, column: 5, scope: !336)
!336 = !DILexicalBlockFile(scope: !334, file: !311, discriminator: 0)
!337 = !DILocation(line: 76, column: 1, scope: !336)
!338 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.sys_mod.unblock_cmd_stream", scope: null, file: !311, line: 80, type: !5, scopeLine: 80, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!339 = !DILocation(line: 81, column: 5, scope: !340)
!340 = !DILexicalBlockFile(scope: !338, file: !311, discriminator: 0)
!341 = !DILocation(line: 80, column: 1, scope: !340)
!342 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_sys_exit", linkageName: "sys_mod.sys_mod.sys_mod.f_sys_exit", scope: null, file: !311, line: 85, type: !5, scopeLine: 85, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!343 = !DILocation(line: 86, column: 5, scope: !344)
!344 = !DILexicalBlockFile(scope: !342, file: !311, discriminator: 0)
!345 = !DILocation(line: 87, column: 5, scope: !344)
!346 = !DILocation(line: 85, column: 1, scope: !344)
!347 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore", linkageName: "sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore", scope: null, file: !311, line: 90, type: !5, scopeLine: 90, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!348 = !DILocation(line: 90, column: 30, scope: !349)
!349 = !DILexicalBlockFile(scope: !347, file: !311, discriminator: 0)
!350 = !DILocation(line: 90, column: 1, scope: !349)
!351 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord", scope: null, file: !352, line: 131, type: !5, scopeLine: 131, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!352 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpyh2d.csl", directory: "")
!353 = !DILocation(line: 132, column: 12, scope: !354)
!354 = !DILexicalBlockFile(scope: !351, file: !352, discriminator: 0)
!355 = !DILocation(line: 132, column: 5, scope: !354)
!356 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord", scope: null, file: !352, line: 134, type: !5, scopeLine: 134, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!357 = !DILocation(line: 135, column: 12, scope: !358)
!358 = !DILexicalBlockFile(scope: !356, file: !352, discriminator: 0)
!359 = !DILocation(line: 135, column: 5, scope: !358)
!360 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval", scope: null, file: !352, line: 148, type: !5, scopeLine: 148, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!361 = !DILocation(line: 148, column: 23, scope: !362)
!362 = !DILexicalBlockFile(scope: !360, file: !352, discriminator: 0)
!363 = !DILocation(line: 149, column: 9, scope: !362)
!364 = !DILocation(line: 149, column: 20, scope: !362)
!365 = !DILocation(line: 149, column: 5, scope: !362)
!366 = !DILocation(line: 152, column: 23, scope: !362)
!367 = !DILocation(line: 152, column: 20, scope: !362)
!368 = !DILocation(line: 152, column: 9, scope: !362)
!369 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start", scope: null, file: !352, line: 226, type: !5, scopeLine: 226, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!370 = !DILocation(line: 233, column: 5, scope: !371)
!371 = !DILexicalBlockFile(scope: !369, file: !352, discriminator: 0)
!372 = !DILocation(line: 226, column: 49, scope: !371)
!373 = !DILocation(line: 226, column: 32, scope: !371)
!374 = !DILocation(line: 226, column: 21, scope: !371)
!375 = !DILocation(line: 229, column: 37, scope: !371)
!376 = !DILocation(line: 229, column: 52, scope: !371)
!377 = !DILocation(line: 229, column: 19, scope: !371)
!378 = !DILocation(line: 233, column: 71, scope: !371)
!379 = !DILocation(line: 233, column: 55, scope: !371)
!380 = !DILocation(line: 233, column: 25, scope: !371)
!381 = !DILocation(line: 235, column: 37, scope: !371)
!382 = !DILocation(line: 235, column: 52, scope: !371)
!383 = !DILocation(line: 235, column: 19, scope: !371)
!384 = !DILocation(line: 236, column: 28, scope: !371)
!385 = !DILocation(line: 236, column: 5, scope: !371)
!386 = !DILocation(line: 237, column: 28, scope: !371)
!387 = !DILocation(line: 237, column: 5, scope: !371)
!388 = !DILocation(line: 238, column: 13, scope: !371)
!389 = !DILocation(line: 238, column: 11, scope: !371)
!390 = !DILocation(line: 238, column: 5, scope: !371)
!391 = !DILocation(line: 239, column: 9, scope: !371)
!392 = !DILocation(line: 241, column: 9, scope: !371)
!393 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream", scope: null, file: !352, line: 249, type: !5, scopeLine: 249, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!394 = !DILocation(line: 250, column: 5, scope: !395)
!395 = !DILexicalBlockFile(scope: !393, file: !352, discriminator: 0)
!396 = !DILocation(line: 249, column: 1, scope: !395)
!397 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure", scope: null, file: !352, line: 276, type: !5, scopeLine: 276, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!398 = !DILocation(line: 414, column: 13, scope: !399)
!399 = !DILexicalBlockFile(scope: !397, file: !352, discriminator: 0)
!400 = !DILocation(line: 413, column: 13, scope: !399)
!401 = !DILocation(line: 400, column: 17, scope: !399)
!402 = !DILocation(line: 340, column: 9, scope: !399)
!403 = !DILocation(line: 339, column: 9, scope: !399)
!404 = !DILocation(line: 337, column: 5, scope: !399)
!405 = !DILocation(line: 319, column: 9, scope: !399)
!406 = !DILocation(line: 318, column: 9, scope: !399)
!407 = !DILocation(line: 315, column: 5, scope: !399)
!408 = !DILocation(line: 292, column: 5, scope: !399)
!409 = !DILocation(line: 291, column: 5, scope: !399)
!410 = !DILocation(line: 289, column: 5, scope: !399)
!411 = !DILocation(line: 288, column: 5, scope: !399)
!412 = !DILocation(line: 287, column: 5, scope: !399)
!413 = !DILocation(line: 286, column: 5, scope: !399)
!414 = !DILocation(line: 285, column: 5, scope: !399)
!415 = !DILocation(line: 284, column: 5, scope: !399)
!416 = !DILocation(line: 283, column: 5, scope: !399)
!417 = !DILocation(line: 282, column: 5, scope: !399)
!418 = !DILocation(line: 281, column: 5, scope: !399)
!419 = !DILocation(line: 280, column: 5, scope: !399)
!420 = !DILocation(line: 279, column: 5, scope: !399)
!421 = !DILocation(line: 278, column: 5, scope: !399)
!422 = !DILocation(line: 277, column: 5, scope: !399)
!423 = !DILocation(line: 291, column: 26, scope: !399)
!424 = !DILocation(line: 292, column: 26, scope: !399)
!425 = !DILocation(line: 315, column: 25, scope: !399)
!426 = !DILocation(line: 315, column: 31, scope: !399)
!427 = !DILocation(line: 315, column: 29, scope: !399)
!428 = !DILocation(line: 316, column: 20, scope: !399)
!429 = !DILocation(line: 316, column: 18, scope: !399)
!430 = !DILocation(line: 317, column: 52, scope: !399)
!431 = !DILocation(line: 317, column: 49, scope: !399)
!432 = !DILocation(line: 317, column: 5, scope: !399)
!433 = !DILocation(line: 318, column: 42, scope: !399)
!434 = !DILocation(line: 318, column: 33, scope: !399)
!435 = !DILocation(line: 318, column: 49, scope: !399)
!436 = !DILocation(line: 318, column: 48, scope: !399)
!437 = !DILocation(line: 318, column: 24, scope: !399)
!438 = !DILocation(line: 319, column: 24, scope: !399)
!439 = !DILocation(line: 319, column: 32, scope: !399)
!440 = !DILocation(line: 319, column: 36, scope: !399)
!441 = !DILocation(line: 319, column: 34, scope: !399)
!442 = !DILocation(line: 319, column: 30, scope: !399)
!443 = !DILocation(line: 320, column: 18, scope: !399)
!444 = !DILocation(line: 320, column: 15, scope: !399)
!445 = !DILocation(line: 320, column: 9, scope: !399)
!446 = !DILocation(line: 321, column: 26, scope: !399)
!447 = !DILocation(line: 325, column: 28, scope: !399)
!448 = !DILocation(line: 325, column: 26, scope: !399)
!449 = !DILocation(line: 331, column: 9, scope: !399)
!450 = !DILocation(line: 331, column: 15, scope: !399)
!451 = !DILocation(line: 331, column: 5, scope: !399)
!452 = !DILocation(line: 332, column: 22, scope: !399)
!453 = !DILocation(line: 334, column: 9, scope: !399)
!454 = !DILocation(line: 334, column: 18, scope: !399)
!455 = !DILocation(line: 334, column: 15, scope: !399)
!456 = !DILocation(line: 334, column: 5, scope: !399)
!457 = !DILocation(line: 335, column: 22, scope: !399)
!458 = !DILocation(line: 338, column: 52, scope: !399)
!459 = !DILocation(line: 338, column: 49, scope: !399)
!460 = !DILocation(line: 338, column: 5, scope: !399)
!461 = !DILocation(line: 339, column: 42, scope: !399)
!462 = !DILocation(line: 339, column: 48, scope: !399)
!463 = !DILocation(line: 339, column: 46, scope: !399)
!464 = !DILocation(line: 339, column: 33, scope: !399)
!465 = !DILocation(line: 339, column: 52, scope: !399)
!466 = !DILocation(line: 339, column: 51, scope: !399)
!467 = !DILocation(line: 339, column: 24, scope: !399)
!468 = !DILocation(line: 340, column: 25, scope: !399)
!469 = !DILocation(line: 340, column: 31, scope: !399)
!470 = !DILocation(line: 340, column: 29, scope: !399)
!471 = !DILocation(line: 340, column: 37, scope: !399)
!472 = !DILocation(line: 340, column: 41, scope: !399)
!473 = !DILocation(line: 340, column: 39, scope: !399)
!474 = !DILocation(line: 340, column: 35, scope: !399)
!475 = !DILocation(line: 341, column: 18, scope: !399)
!476 = !DILocation(line: 341, column: 15, scope: !399)
!477 = !DILocation(line: 341, column: 9, scope: !399)
!478 = !DILocation(line: 342, column: 26, scope: !399)
!479 = !DILocation(line: 347, column: 10, scope: !399)
!480 = !DILocation(line: 347, column: 16, scope: !399)
!481 = !DILocation(line: 347, column: 14, scope: !399)
!482 = !DILocation(line: 347, column: 5, scope: !399)
!483 = !DILocation(line: 348, column: 22, scope: !399)
!484 = !DILocation(line: 350, column: 10, scope: !399)
!485 = !DILocation(line: 350, column: 18, scope: !399)
!486 = !DILocation(line: 350, column: 21, scope: !399)
!487 = !DILocation(line: 350, column: 20, scope: !399)
!488 = !DILocation(line: 350, column: 14, scope: !399)
!489 = !DILocation(line: 350, column: 5, scope: !399)
!490 = !DILocation(line: 351, column: 22, scope: !399)
!491 = !DILocation(line: 354, column: 9, scope: !399)
!492 = !DILocation(line: 354, column: 5, scope: !399)
!493 = !DILocation(line: 358, column: 9, scope: !399)
!494 = !DILocation(line: 361, column: 9, scope: !399)
!495 = !DILocation(line: 364, column: 20, scope: !399)
!496 = !DILocation(line: 364, column: 17, scope: !399)
!497 = !DILocation(line: 364, column: 9, scope: !399)
!498 = !DILocation(line: 368, column: 13, scope: !399)
!499 = !DILocation(line: 371, column: 13, scope: !399)
!500 = !DILocation(line: 375, column: 13, scope: !399)
!501 = !DILocation(line: 394, column: 13, scope: !399)
!502 = !DILocation(line: 396, column: 29, scope: !399)
!503 = !DILocation(line: 396, column: 27, scope: !399)
!504 = !DILocation(line: 397, column: 60, scope: !399)
!505 = !DILocation(line: 397, column: 57, scope: !399)
!506 = !DILocation(line: 397, column: 13, scope: !399)
!507 = !DILocation(line: 400, column: 54, scope: !399)
!508 = !DILocation(line: 400, column: 55, scope: !399)
!509 = !DILocation(line: 400, column: 46, scope: !399)
!510 = !DILocation(line: 400, column: 59, scope: !399)
!511 = !DILocation(line: 400, column: 58, scope: !399)
!512 = !DILocation(line: 400, column: 37, scope: !399)
!513 = !DILocation(line: 400, column: 35, scope: !399)
!514 = !DILocation(line: 401, column: 33, scope: !399)
!515 = !DILocation(line: 401, column: 31, scope: !399)
!516 = !DILocation(line: 402, column: 69, scope: !399)
!517 = !DILocation(line: 402, column: 66, scope: !399)
!518 = !DILocation(line: 402, column: 19, scope: !399)
!519 = !DILocation(line: 404, column: 31, scope: !399)
!520 = !DILocation(line: 408, column: 75, scope: !399)
!521 = !DILocation(line: 408, column: 88, scope: !399)
!522 = !DILocation(line: 408, column: 13, scope: !399)
!523 = !DILocation(line: 413, column: 31, scope: !399)
!524 = !DILocation(line: 414, column: 33, scope: !399)
!525 = !DILocation(line: 415, column: 21, scope: !399)
!526 = !DILocation(line: 415, column: 29, scope: !399)
!527 = !DILocation(line: 415, column: 27, scope: !399)
!528 = !DILocation(line: 415, column: 19, scope: !399)
!529 = !DILocation(line: 416, column: 22, scope: !399)
!530 = !DILocation(line: 416, column: 19, scope: !399)
!531 = !DILocation(line: 416, column: 13, scope: !399)
!532 = !DILocation(line: 417, column: 23, scope: !399)
!533 = !DILocation(line: 419, column: 63, scope: !399)
!534 = !DILocation(line: 419, column: 60, scope: !399)
!535 = !DILocation(line: 419, column: 13, scope: !399)
!536 = !DILocation(line: 421, column: 23, scope: !399)
!537 = !DILocation(line: 423, column: 69, scope: !399)
!538 = !DILocation(line: 423, column: 13, scope: !399)
!539 = !DILocation(line: 426, column: 13, scope: !399)
!540 = !DILocation(line: 430, column: 13, scope: !399)
!541 = !DILocation(line: 433, column: 48, scope: !399)
!542 = !DILocation(line: 433, column: 22, scope: !399)
!543 = !DILocation(line: 433, column: 19, scope: !399)
!544 = !DILocation(line: 433, column: 13, scope: !399)
!545 = !DILocation(line: 436, column: 34, scope: !399)
!546 = !DILocation(line: 436, column: 39, scope: !399)
!547 = !DILocation(line: 436, column: 50, scope: !399)
!548 = !DILocation(line: 436, column: 17, scope: !399)
!549 = !DILocation(line: 452, column: 49, scope: !399)
!550 = !DILocation(line: 452, column: 64, scope: !399)
!551 = !DILocation(line: 452, column: 31, scope: !399)
!552 = !DILocation(line: 453, column: 40, scope: !399)
!553 = !DILocation(line: 453, column: 17, scope: !399)
!554 = !DILocation(line: 454, column: 50, scope: !399)
!555 = !DILocation(line: 454, column: 66, scope: !399)
!556 = !DILocation(line: 454, column: 32, scope: !399)
!557 = !DILocation(line: 455, column: 40, scope: !399)
!558 = !DILocation(line: 455, column: 17, scope: !399)
!559 = !DILocation(line: 456, column: 17, scope: !399)
!560 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit", scope: null, file: !561, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!561 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/filters/wse3.csl", directory: "")
!562 = !DILocation(line: 24, column: 3, scope: !563)
!563 = !DILexicalBlockFile(scope: !560, file: !561, discriminator: 0)
!564 = !DILocation(line: 24, column: 22, scope: !563)
!565 = !DILocation(line: 23, column: 3, scope: !563)
!566 = !DILocation(line: 22, column: 3, scope: !563)
!567 = !DILocation(line: 20, column: 37, scope: !563)
!568 = !DILocation(line: 20, column: 21, scope: !563)
!569 = !DILocation(line: 21, column: 11, scope: !563)
!570 = !DILocation(line: 21, column: 17, scope: !563)
!571 = !DILocation(line: 21, column: 3, scope: !563)
!572 = !DILocation(line: 22, column: 24, scope: !563)
!573 = !DILocation(line: 22, column: 30, scope: !563)
!574 = !DILocation(line: 23, column: 40, scope: !563)
!575 = !DILocation(line: 23, column: 22, scope: !563)
!576 = !DILocation(line: 23, column: 67, scope: !563)
!577 = !DILocation(line: 24, column: 26, scope: !563)
!578 = !DILocation(line: 24, column: 41, scope: !563)
!579 = !DILocation(line: 24, column: 39, scope: !563)
!580 = !DILocation(line: 24, column: 61, scope: !563)
!581 = !DILocation(line: 24, column: 76, scope: !563)
!582 = !DILocation(line: 24, column: 74, scope: !563)
!583 = !DILocation(line: 25, column: 21, scope: !563)
!584 = !DILocation(line: 25, column: 50, scope: !563)
!585 = !DILocation(line: 25, column: 3, scope: !563)
!586 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter", scope: null, file: !561, line: 30, type: !5, scopeLine: 30, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!587 = !DILocation(line: 30, column: 36, scope: !588)
!588 = !DILexicalBlockFile(scope: !586, file: !561, discriminator: 0)
!589 = !DILocation(line: 30, column: 20, scope: !588)
!590 = !DILocation(line: 31, column: 11, scope: !588)
!591 = !DILocation(line: 31, column: 23, scope: !588)
!592 = !DILocation(line: 31, column: 3, scope: !588)
!593 = !DILocation(line: 32, column: 21, scope: !588)
!594 = !DILocation(line: 32, column: 48, scope: !588)
!595 = !DILocation(line: 32, column: 60, scope: !588)
!596 = !DILocation(line: 32, column: 64, scope: !588)
!597 = !DILocation(line: 32, column: 3, scope: !588)
!598 = !DILocation(line: 30, column: 1, scope: !588)
!599 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter", scope: null, file: !561, line: 40, type: !5, scopeLine: 40, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!600 = !DILocation(line: 47, column: 3, scope: !601)
!601 = !DILexicalBlockFile(scope: !599, file: !561, discriminator: 0)
!602 = !DILocation(line: 48, column: 7, scope: !601)
!603 = !DILocation(line: 44, column: 3, scope: !601)
!604 = !DILocation(line: 43, column: 3, scope: !601)
!605 = !DILocation(line: 42, column: 3, scope: !601)
!606 = !DILocation(line: 40, column: 32, scope: !601)
!607 = !DILocation(line: 40, column: 16, scope: !601)
!608 = !DILocation(line: 41, column: 11, scope: !601)
!609 = !DILocation(line: 41, column: 19, scope: !601)
!610 = !DILocation(line: 41, column: 3, scope: !601)
!611 = !DILocation(line: 42, column: 40, scope: !601)
!612 = !DILocation(line: 42, column: 22, scope: !601)
!613 = !DILocation(line: 43, column: 26, scope: !601)
!614 = !DILocation(line: 43, column: 34, scope: !601)
!615 = !DILocation(line: 44, column: 25, scope: !601)
!616 = !DILocation(line: 44, column: 42, scope: !601)
!617 = !DILocation(line: 44, column: 40, scope: !601)
!618 = !DILocation(line: 45, column: 21, scope: !601)
!619 = !DILocation(line: 46, column: 35, scope: !601)
!620 = !DILocation(line: 46, column: 21, scope: !601)
!621 = !DILocation(line: 46, column: 50, scope: !601)
!622 = !DILocation(line: 45, column: 3, scope: !601)
!623 = !DILocation(line: 48, column: 11, scope: !601)
!624 = !DILocation(line: 48, column: 26, scope: !601)
!625 = !DILocation(line: 48, column: 43, scope: !601)
!626 = !DILocation(line: 48, column: 41, scope: !601)
!627 = !DILocation(line: 48, column: 54, scope: !601)
!628 = !DILocation(line: 48, column: 63, scope: !601)
!629 = !DILocation(line: 49, column: 21, scope: !601)
!630 = !DILocation(line: 49, column: 47, scope: !601)
!631 = !DILocation(line: 49, column: 3, scope: !601)
!632 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config", scope: null, file: !633, line: 33, type: !5, scopeLine: 33, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!633 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/filters/common.csl", directory: "")
!634 = !DILocation(line: 33, column: 46, scope: !635)
!635 = !DILexicalBlockFile(scope: !632, file: !633, discriminator: 0)
!636 = !DILocation(line: 33, column: 31, scope: !635)
!637 = !DILocation(line: 33, column: 15, scope: !635)
!638 = !DILocation(line: 34, column: 24, scope: !635)
!639 = !DILocation(line: 34, column: 23, scope: !635)
!640 = !DILocation(line: 34, column: 51, scope: !635)
!641 = !DILocation(line: 34, column: 35, scope: !635)
!642 = !DILocation(line: 34, column: 60, scope: !635)
!643 = !DILocation(line: 34, column: 73, scope: !635)
!644 = !DILocation(line: 34, column: 3, scope: !635)
!645 = !DILocation(line: 33, column: 1, scope: !635)
!646 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config", scope: null, file: !633, line: 38, type: !5, scopeLine: 38, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!647 = !DILocation(line: 38, column: 31, scope: !648)
!648 = !DILexicalBlockFile(scope: !646, file: !633, discriminator: 0)
!649 = !DILocation(line: 38, column: 15, scope: !648)
!650 = !DILocation(line: 39, column: 31, scope: !648)
!651 = !DILocation(line: 39, column: 30, scope: !648)
!652 = !DILocation(line: 39, column: 58, scope: !648)
!653 = !DILocation(line: 39, column: 42, scope: !648)
!654 = !DILocation(line: 39, column: 67, scope: !648)
!655 = !DILocation(line: 39, column: 10, scope: !648)
!656 = !DILocation(line: 39, column: 3, scope: !648)
!657 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit", scope: null, file: !658, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!658 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/teardown.csl", directory: "")
!659 = !DILocation(line: 43, column: 3, scope: !660)
!660 = !DILexicalBlockFile(scope: !657, file: !658, discriminator: 0)
!661 = !DILocation(line: 41, column: 3, scope: !660)
!662 = !DILocation(line: 40, column: 3, scope: !660)
!663 = !DILocation(line: 39, column: 9, scope: !660)
!664 = !DILocation(line: 40, column: 23, scope: !660)
!665 = !DILocation(line: 41, column: 70, scope: !660)
!666 = !DILocation(line: 41, column: 68, scope: !660)
!667 = !DILocation(line: 43, column: 27, scope: !660)
!668 = !DILocation(line: 43, column: 15, scope: !660)
!669 = !DILocation(line: 44, column: 15, scope: !660)
!670 = !DILocation(line: 44, column: 21, scope: !660)
!671 = !DILocation(line: 44, column: 27, scope: !660)
!672 = !DILocation(line: 44, column: 3, scope: !660)
!673 = !DILocation(line: 39, column: 1, scope: !660)
!674 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord", scope: null, file: !675, line: 4, type: !5, scopeLine: 4, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!675 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/layout.csl", directory: "")
!676 = !DILocation(line: 5, column: 10, scope: !677)
!677 = !DILexicalBlockFile(scope: !674, file: !675, discriminator: 0)
!678 = !DILocation(line: 5, column: 67, scope: !677)
!679 = !DILocation(line: 5, column: 3, scope: !677)
!680 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord", scope: null, file: !675, line: 8, type: !5, scopeLine: 8, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!681 = !DILocation(line: 9, column: 10, scope: !682)
!682 = !DILexicalBlockFile(scope: !680, file: !675, discriminator: 0)
!683 = !DILocation(line: 9, column: 67, scope: !682)
!684 = !DILocation(line: 9, column: 3, scope: !682)
!685 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord", scope: null, file: !686, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!686 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config.csl", directory: "")
!687 = !DILocation(line: 50, column: 3, scope: !688)
!688 = !DILexicalBlockFile(scope: !685, file: !686, discriminator: 0)
!689 = !DILocation(line: 43, column: 21, scope: !688)
!690 = !DILocation(line: 50, column: 57, scope: !688)
!691 = !DILocation(line: 50, column: 68, scope: !688)
!692 = !DILocation(line: 50, column: 41, scope: !688)
!693 = !DILocation(line: 50, column: 19, scope: !688)
!694 = !DILocation(line: 52, column: 10, scope: !688)
!695 = !DILocation(line: 52, column: 18, scope: !688)
!696 = !DILocation(line: 48, column: 22, scope: !688)
!697 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.get_x_coord", scope: null, file: !698, line: 171, type: !5, scopeLine: 171, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!698 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpyd2h.csl", directory: "")
!699 = !DILocation(line: 172, column: 12, scope: !700)
!700 = !DILexicalBlockFile(scope: !697, file: !698, discriminator: 0)
!701 = !DILocation(line: 172, column: 5, scope: !700)
!702 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.get_y_coord", scope: null, file: !698, line: 174, type: !5, scopeLine: 174, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!703 = !DILocation(line: 175, column: 12, scope: !704)
!704 = !DILexicalBlockFile(scope: !702, file: !698, discriminator: 0)
!705 = !DILocation(line: 175, column: 5, scope: !704)
!706 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval", scope: null, file: !698, line: 187, type: !5, scopeLine: 187, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!707 = !DILocation(line: 187, column: 23, scope: !708)
!708 = !DILexicalBlockFile(scope: !706, file: !698, discriminator: 0)
!709 = !DILocation(line: 188, column: 9, scope: !708)
!710 = !DILocation(line: 188, column: 20, scope: !708)
!711 = !DILocation(line: 188, column: 5, scope: !708)
!712 = !DILocation(line: 191, column: 23, scope: !708)
!713 = !DILocation(line: 191, column: 20, scope: !708)
!714 = !DILocation(line: 191, column: 9, scope: !708)
!715 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start", scope: null, file: !698, line: 383, type: !5, scopeLine: 383, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!716 = !DILocation(line: 386, column: 5, scope: !717)
!717 = !DILexicalBlockFile(scope: !715, file: !698, discriminator: 0)
!718 = !DILocation(line: 384, column: 72, scope: !717)
!719 = !DILocation(line: 384, column: 59, scope: !717)
!720 = !DILocation(line: 384, column: 46, scope: !717)
!721 = !DILocation(line: 384, column: 33, scope: !717)
!722 = !DILocation(line: 384, column: 19, scope: !717)
!723 = !DILocation(line: 384, column: 5, scope: !717)
!724 = !DILocation(line: 383, column: 32, scope: !717)
!725 = !DILocation(line: 383, column: 21, scope: !717)
!726 = !DILocation(line: 386, column: 26, scope: !717)
!727 = !DILocation(line: 388, column: 28, scope: !717)
!728 = !DILocation(line: 388, column: 17, scope: !717)
!729 = !DILocation(line: 389, column: 25, scope: !717)
!730 = !DILocation(line: 389, column: 23, scope: !717)
!731 = !DILocation(line: 391, column: 38, scope: !717)
!732 = !DILocation(line: 391, column: 20, scope: !717)
!733 = !DILocation(line: 391, column: 18, scope: !717)
!734 = !DILocation(line: 393, column: 7, scope: !717)
!735 = !DILocation(line: 395, column: 17, scope: !717)
!736 = !DILocation(line: 395, column: 15, scope: !717)
!737 = !DILocation(line: 397, column: 15, scope: !717)
!738 = !DILocation(line: 397, column: 13, scope: !717)
!739 = !DILocation(line: 398, column: 15, scope: !717)
!740 = !DILocation(line: 398, column: 25, scope: !717)
!741 = !DILocation(line: 398, column: 23, scope: !717)
!742 = !DILocation(line: 398, column: 31, scope: !717)
!743 = !DILocation(line: 398, column: 13, scope: !717)
!744 = !DILocation(line: 401, column: 10, scope: !717)
!745 = !DILocation(line: 401, column: 17, scope: !717)
!746 = !DILocation(line: 401, column: 14, scope: !717)
!747 = !DILocation(line: 401, column: 5, scope: !717)
!748 = !DILocation(line: 403, column: 48, scope: !717)
!749 = !DILocation(line: 403, column: 26, scope: !717)
!750 = !DILocation(line: 404, column: 26, scope: !717)
!751 = !DILocation(line: 404, column: 18, scope: !717)
!752 = !DILocation(line: 407, column: 48, scope: !717)
!753 = !DILocation(line: 407, column: 26, scope: !717)
!754 = !DILocation(line: 408, column: 27, scope: !717)
!755 = !DILocation(line: 408, column: 18, scope: !717)
!756 = !DILocation(line: 411, column: 14, scope: !717)
!757 = !DILocation(line: 414, column: 14, scope: !717)
!758 = !DILocation(line: 414, column: 11, scope: !717)
!759 = !DILocation(line: 414, column: 5, scope: !717)
!760 = !DILocation(line: 416, column: 44, scope: !717)
!761 = !DILocation(line: 416, column: 75, scope: !717)
!762 = !DILocation(line: 416, column: 59, scope: !717)
!763 = !DILocation(line: 416, column: 25, scope: !717)
!764 = !DILocation(line: 416, column: 23, scope: !717)
!765 = !DILocation(line: 418, column: 41, scope: !717)
!766 = !DILocation(line: 418, column: 23, scope: !717)
!767 = !DILocation(line: 419, column: 9, scope: !717)
!768 = !DILocation(line: 425, column: 44, scope: !717)
!769 = !DILocation(line: 425, column: 23, scope: !717)
!770 = !DILocation(line: 426, column: 41, scope: !717)
!771 = !DILocation(line: 426, column: 23, scope: !717)
!772 = !DILocation(line: 427, column: 9, scope: !717)
!773 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x", scope: null, file: !698, line: 448, type: !5, scopeLine: 448, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!774 = !DILocation(line: 448, column: 31, scope: !775)
!775 = !DILexicalBlockFile(scope: !773, file: !698, discriminator: 0)
!776 = !DILocation(line: 453, column: 5, scope: !775)
!777 = !DILocation(line: 456, column: 19, scope: !775)
!778 = !DILocation(line: 456, column: 17, scope: !775)
!779 = !DILocation(line: 461, column: 5, scope: !775)
!780 = !DILocation(line: 462, column: 28, scope: !775)
!781 = !DILocation(line: 462, column: 5, scope: !775)
!782 = !DILocation(line: 463, column: 5, scope: !775)
!783 = !DILocation(line: 464, column: 9, scope: !775)
!784 = !DILocation(line: 464, column: 10, scope: !775)
!785 = !DILocation(line: 464, column: 7, scope: !775)
!786 = !DILocation(line: 448, column: 1, scope: !775)
!787 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_send_data", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_send_data", scope: null, file: !698, line: 476, type: !5, scopeLine: 476, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!788 = !DILocation(line: 494, column: 9, scope: !789)
!789 = !DILexicalBlockFile(scope: !787, file: !698, discriminator: 0)
!790 = !DILocation(line: 478, column: 9, scope: !789)
!791 = !DILocation(line: 478, column: 13, scope: !789)
!792 = !DILocation(line: 478, column: 11, scope: !789)
!793 = !DILocation(line: 478, column: 5, scope: !789)
!794 = !DILocation(line: 479, column: 9, scope: !789)
!795 = !DILocation(line: 480, column: 32, scope: !789)
!796 = !DILocation(line: 480, column: 9, scope: !789)
!797 = !DILocation(line: 481, column: 17, scope: !789)
!798 = !DILocation(line: 481, column: 15, scope: !789)
!799 = !DILocation(line: 481, column: 9, scope: !789)
!800 = !DILocation(line: 482, column: 13, scope: !789)
!801 = !DILocation(line: 483, column: 51, scope: !789)
!802 = !DILocation(line: 483, column: 29, scope: !789)
!803 = !DILocation(line: 483, column: 27, scope: !789)
!804 = !DILocation(line: 485, column: 13, scope: !789)
!805 = !DILocation(line: 486, column: 51, scope: !789)
!806 = !DILocation(line: 486, column: 29, scope: !789)
!807 = !DILocation(line: 486, column: 27, scope: !789)
!808 = !DILocation(line: 488, column: 13, scope: !789)
!809 = !DILocation(line: 488, column: 14, scope: !789)
!810 = !DILocation(line: 488, column: 11, scope: !789)
!811 = !DILocation(line: 494, column: 30, scope: !789)
!812 = !DILocation(line: 496, column: 14, scope: !789)
!813 = !DILocation(line: 496, column: 25, scope: !789)
!814 = !DILocation(line: 496, column: 22, scope: !789)
!815 = !DILocation(line: 496, column: 9, scope: !789)
!816 = !DILocation(line: 497, column: 13, scope: !789)
!817 = !DILocation(line: 498, column: 13, scope: !789)
!818 = !DILocation(line: 499, column: 13, scope: !789)
!819 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl", scope: null, file: !698, line: 505, type: !5, scopeLine: 505, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!820 = !DILocation(line: 524, column: 13, scope: !821)
!821 = !DILexicalBlockFile(scope: !819, file: !698, discriminator: 0)
!822 = !DILocation(line: 506, column: 14, scope: !821)
!823 = !DILocation(line: 506, column: 11, scope: !821)
!824 = !DILocation(line: 506, column: 5, scope: !821)
!825 = !DILocation(line: 508, column: 9, scope: !821)
!826 = !DILocation(line: 509, column: 32, scope: !821)
!827 = !DILocation(line: 509, column: 9, scope: !821)
!828 = !DILocation(line: 510, column: 9, scope: !821)
!829 = !DILocation(line: 514, column: 13, scope: !821)
!830 = !DILocation(line: 514, column: 17, scope: !821)
!831 = !DILocation(line: 514, column: 15, scope: !821)
!832 = !DILocation(line: 514, column: 9, scope: !821)
!833 = !DILocation(line: 518, column: 13, scope: !821)
!834 = !DILocation(line: 519, column: 36, scope: !821)
!835 = !DILocation(line: 519, column: 13, scope: !821)
!836 = !DILocation(line: 520, column: 13, scope: !821)
!837 = !DILocation(line: 524, column: 34, scope: !821)
!838 = !DILocation(line: 526, column: 18, scope: !821)
!839 = !DILocation(line: 526, column: 29, scope: !821)
!840 = !DILocation(line: 526, column: 26, scope: !821)
!841 = !DILocation(line: 526, column: 13, scope: !821)
!842 = !DILocation(line: 529, column: 17, scope: !821)
!843 = !DILocation(line: 530, column: 17, scope: !821)
!844 = !DILocation(line: 531, column: 17, scope: !821)
!845 = !DILocation(line: 534, column: 17, scope: !821)
!846 = !DILocation(line: 535, column: 40, scope: !821)
!847 = !DILocation(line: 535, column: 17, scope: !821)
!848 = !DILocation(line: 536, column: 17, scope: !821)
!849 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.d2h_configure", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.d2h_configure", scope: null, file: !698, line: 593, type: !5, scopeLine: 593, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!850 = !DILocation(line: 617, column: 26, scope: !851)
!851 = !DILexicalBlockFile(scope: !849, file: !698, discriminator: 0)
!852 = !DILocation(line: 612, column: 47, scope: !851)
!853 = !DILocation(line: 612, column: 27, scope: !851)
!854 = !DILocation(line: 602, column: 5, scope: !851)
!855 = !DILocation(line: 601, column: 5, scope: !851)
!856 = !DILocation(line: 599, column: 5, scope: !851)
!857 = !DILocation(line: 598, column: 5, scope: !851)
!858 = !DILocation(line: 596, column: 5, scope: !851)
!859 = !DILocation(line: 595, column: 5, scope: !851)
!860 = !DILocation(line: 593, column: 86, scope: !851)
!861 = !DILocation(line: 593, column: 70, scope: !851)
!862 = !DILocation(line: 593, column: 60, scope: !851)
!863 = !DILocation(line: 593, column: 52, scope: !851)
!864 = !DILocation(line: 593, column: 44, scope: !851)
!865 = !DILocation(line: 593, column: 35, scope: !851)
!866 = !DILocation(line: 593, column: 26, scope: !851)
!867 = !DILocation(line: 593, column: 18, scope: !851)
!868 = !DILocation(line: 595, column: 26, scope: !851)
!869 = !DILocation(line: 596, column: 26, scope: !851)
!870 = !DILocation(line: 598, column: 23, scope: !851)
!871 = !DILocation(line: 599, column: 23, scope: !851)
!872 = !DILocation(line: 599, column: 28, scope: !851)
!873 = !DILocation(line: 599, column: 26, scope: !851)
!874 = !DILocation(line: 599, column: 29, scope: !851)
!875 = !DILocation(line: 601, column: 24, scope: !851)
!876 = !DILocation(line: 602, column: 24, scope: !851)
!877 = !DILocation(line: 602, column: 29, scope: !851)
!878 = !DILocation(line: 602, column: 27, scope: !851)
!879 = !DILocation(line: 602, column: 30, scope: !851)
!880 = !DILocation(line: 611, column: 20, scope: !851)
!881 = !DILocation(line: 612, column: 11, scope: !851)
!882 = !DILocation(line: 612, column: 18, scope: !851)
!883 = !DILocation(line: 612, column: 15, scope: !851)
!884 = !DILocation(line: 612, column: 32, scope: !851)
!885 = !DILocation(line: 612, column: 39, scope: !851)
!886 = !DILocation(line: 612, column: 36, scope: !851)
!887 = !DILocation(line: 612, column: 52, scope: !851)
!888 = !DILocation(line: 612, column: 59, scope: !851)
!889 = !DILocation(line: 612, column: 56, scope: !851)
!890 = !DILocation(line: 612, column: 5, scope: !851)
!891 = !DILocation(line: 613, column: 24, scope: !851)
!892 = !DILocation(line: 616, column: 15, scope: !851)
!893 = !DILocation(line: 617, column: 11, scope: !851)
!894 = !DILocation(line: 617, column: 18, scope: !851)
!895 = !DILocation(line: 617, column: 15, scope: !851)
!896 = !DILocation(line: 617, column: 30, scope: !851)
!897 = !DILocation(line: 617, column: 5, scope: !851)
!898 = !DILocation(line: 618, column: 19, scope: !851)
!899 = !DILocation(line: 621, column: 9, scope: !851)
!900 = !DILocation(line: 621, column: 5, scope: !851)
!901 = !DILocation(line: 627, column: 9, scope: !851)
!902 = !DILocation(line: 629, column: 13, scope: !851)
!903 = !DILocation(line: 629, column: 25, scope: !851)
!904 = !DILocation(line: 629, column: 21, scope: !851)
!905 = !DILocation(line: 629, column: 9, scope: !851)
!906 = !DILocation(line: 632, column: 13, scope: !851)
!907 = !DILocation(line: 636, column: 13, scope: !851)
!908 = !DILocation(line: 641, column: 9, scope: !851)
!909 = !DILocation(line: 646, column: 13, scope: !851)
!910 = !DILocation(line: 646, column: 9, scope: !851)
!911 = !DILocation(line: 647, column: 30, scope: !851)
!912 = !DILocation(line: 647, column: 35, scope: !851)
!913 = !DILocation(line: 647, column: 46, scope: !851)
!914 = !DILocation(line: 647, column: 50, scope: !851)
!915 = !DILocation(line: 647, column: 54, scope: !851)
!916 = !DILocation(line: 647, column: 57, scope: !851)
!917 = !DILocation(line: 647, column: 60, scope: !851)
!918 = !DILocation(line: 647, column: 63, scope: !851)
!919 = !DILocation(line: 647, column: 13, scope: !851)
!920 = !DILocation(line: 661, column: 9, scope: !851)
!921 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit", scope: null, file: !658, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!922 = !DILocation(line: 43, column: 3, scope: !923)
!923 = !DILexicalBlockFile(scope: !921, file: !658, discriminator: 0)
!924 = !DILocation(line: 41, column: 3, scope: !923)
!925 = !DILocation(line: 40, column: 3, scope: !923)
!926 = !DILocation(line: 39, column: 9, scope: !923)
!927 = !DILocation(line: 40, column: 23, scope: !923)
!928 = !DILocation(line: 41, column: 70, scope: !923)
!929 = !DILocation(line: 41, column: 68, scope: !923)
!930 = !DILocation(line: 43, column: 27, scope: !923)
!931 = !DILocation(line: 43, column: 15, scope: !923)
!932 = !DILocation(line: 44, column: 15, scope: !923)
!933 = !DILocation(line: 44, column: 21, scope: !923)
!934 = !DILocation(line: 44, column: 27, scope: !923)
!935 = !DILocation(line: 44, column: 3, scope: !923)
!936 = !DILocation(line: 39, column: 1, scope: !923)
!937 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord", scope: null, file: !675, line: 4, type: !5, scopeLine: 4, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!938 = !DILocation(line: 5, column: 10, scope: !939)
!939 = !DILexicalBlockFile(scope: !937, file: !675, discriminator: 0)
!940 = !DILocation(line: 5, column: 67, scope: !939)
!941 = !DILocation(line: 5, column: 3, scope: !939)
!942 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord", scope: null, file: !675, line: 8, type: !5, scopeLine: 8, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!943 = !DILocation(line: 9, column: 10, scope: !944)
!944 = !DILexicalBlockFile(scope: !942, file: !675, discriminator: 0)
!945 = !DILocation(line: 9, column: 67, scope: !944)
!946 = !DILocation(line: 9, column: 3, scope: !944)
!947 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord", scope: null, file: !686, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!948 = !DILocation(line: 50, column: 3, scope: !949)
!949 = !DILexicalBlockFile(scope: !947, file: !686, discriminator: 0)
!950 = !DILocation(line: 43, column: 21, scope: !949)
!951 = !DILocation(line: 50, column: 57, scope: !949)
!952 = !DILocation(line: 50, column: 68, scope: !949)
!953 = !DILocation(line: 50, column: 41, scope: !949)
!954 = !DILocation(line: 50, column: 19, scope: !949)
!955 = !DILocation(line: 52, column: 10, scope: !949)
!956 = !DILocation(line: 52, column: 18, scope: !949)
!957 = !DILocation(line: 48, column: 22, scope: !949)
!958 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr", linkageName: "sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr", scope: null, file: !959, line: 11, type: !5, scopeLine: 11, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!959 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/input_queue_config.csl", directory: "")
!960 = !DILocation(line: 11, column: 32, scope: !961)
!961 = !DILexicalBlockFile(scope: !958, file: !959, discriminator: 0)
!962 = !DILocation(line: 12, column: 80, scope: !961)
!963 = !DILocation(line: 12, column: 69, scope: !961)
!964 = !DILocation(line: 12, column: 39, scope: !961)
!965 = !DILocation(line: 12, column: 3, scope: !961)
!966 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue", linkageName: "sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue", scope: null, file: !959, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!967 = !DILocation(line: 46, column: 3, scope: !968)
!968 = !DILexicalBlockFile(scope: !966, file: !959, discriminator: 0)
!969 = !DILocation(line: 45, column: 3, scope: !968)
!970 = !DILocation(line: 39, column: 42, scope: !968)
!971 = !DILocation(line: 39, column: 34, scope: !968)
!972 = !DILocation(line: 39, column: 24, scope: !968)
!973 = !DILocation(line: 45, column: 44, scope: !968)
!974 = !DILocation(line: 45, column: 16, scope: !968)
!975 = !DILocation(line: 46, column: 30, scope: !968)
!976 = !DILocation(line: 46, column: 18, scope: !968)
!977 = !DILocation(line: 56, column: 9, scope: !968)
!978 = !DILocation(line: 56, column: 5, scope: !968)
!979 = !DILocation(line: 58, column: 13, scope: !968)
!980 = !DILocation(line: 58, column: 17, scope: !968)
!981 = !DILocation(line: 58, column: 11, scope: !968)
!982 = !DILocation(line: 61, column: 13, scope: !968)
!983 = !DILocation(line: 61, column: 17, scope: !968)
!984 = !DILocation(line: 61, column: 11, scope: !968)
!985 = !DILocation(line: 66, column: 9, scope: !968)
!986 = !DILocation(line: 66, column: 13, scope: !968)
!987 = !DILocation(line: 66, column: 7, scope: !968)
!988 = !DILocation(line: 68, column: 9, scope: !968)
!989 = !DILocation(line: 68, column: 24, scope: !968)
!990 = !DILocation(line: 68, column: 13, scope: !968)
!991 = !DILocation(line: 68, column: 7, scope: !968)
!992 = !DILocation(line: 70, column: 15, scope: !968)
!993 = !DILocation(line: 70, column: 21, scope: !968)
!994 = !DILocation(line: 70, column: 3, scope: !968)
!995 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr", linkageName: "sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr", scope: null, file: !996, line: 11, type: !5, scopeLine: 11, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!996 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/output_queue_config.csl", directory: "")
!997 = !DILocation(line: 11, column: 33, scope: !998)
!998 = !DILexicalBlockFile(scope: !995, file: !996, discriminator: 0)
!999 = !DILocation(line: 12, column: 82, scope: !998)
!1000 = !DILocation(line: 12, column: 40, scope: !998)
!1001 = !DILocation(line: 12, column: 3, scope: !998)
!1002 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue", linkageName: "sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue", scope: null, file: !996, line: 31, type: !5, scopeLine: 31, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1003 = !DILocation(line: 38, column: 3, scope: !1004)
!1004 = !DILexicalBlockFile(scope: !1002, file: !996, discriminator: 0)
!1005 = !DILocation(line: 37, column: 3, scope: !1004)
!1006 = !DILocation(line: 31, column: 35, scope: !1004)
!1007 = !DILocation(line: 31, column: 25, scope: !1004)
!1008 = !DILocation(line: 37, column: 45, scope: !1004)
!1009 = !DILocation(line: 37, column: 16, scope: !1004)
!1010 = !DILocation(line: 38, column: 30, scope: !1004)
!1011 = !DILocation(line: 38, column: 18, scope: !1004)
!1012 = !DILocation(line: 41, column: 9, scope: !1004)
!1013 = !DILocation(line: 41, column: 13, scope: !1004)
!1014 = !DILocation(line: 41, column: 7, scope: !1004)
!1015 = !DILocation(line: 43, column: 9, scope: !1004)
!1016 = !DILocation(line: 43, column: 24, scope: !1004)
!1017 = !DILocation(line: 43, column: 13, scope: !1004)
!1018 = !DILocation(line: 43, column: 27, scope: !1004)
!1019 = !DILocation(line: 43, column: 7, scope: !1004)
!1020 = !DILocation(line: 45, column: 15, scope: !1004)
!1021 = !DILocation(line: 45, column: 21, scope: !1004)
!1022 = !DILocation(line: 45, column: 3, scope: !1004)
!1023 = !DILocation(line: 31, column: 1, scope: !1004)
!1024 = distinct !DISubprogram(name: "timestamp.enable_tsc", linkageName: "timestamp.enable_tsc", scope: null, file: !1025, line: 6, type: !5, scopeLine: 6, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1025 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/time.csl", directory: "")
!1026 = !DILocation(line: 7, column: 3, scope: !1027)
!1027 = !DILexicalBlockFile(scope: !1024, file: !1025, discriminator: 0)
!1028 = !DILocation(line: 6, column: 1, scope: !1027)
!1029 = distinct !DISubprogram(name: "timestamp.disable_tsc", linkageName: "timestamp.disable_tsc", scope: null, file: !1025, line: 10, type: !5, scopeLine: 10, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1030 = !DILocation(line: 11, column: 3, scope: !1031)
!1031 = !DILexicalBlockFile(scope: !1029, file: !1025, discriminator: 0)
!1032 = !DILocation(line: 10, column: 1, scope: !1031)
!1033 = distinct !DISubprogram(name: "timestamp.get_timestamp", linkageName: "timestamp.get_timestamp", scope: null, file: !1025, line: 14, type: !5, scopeLine: 14, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1034 = !DILocation(line: 14, column: 18, scope: !1035)
!1035 = !DILexicalBlockFile(scope: !1033, file: !1025, discriminator: 0)
!1036 = !DILocation(line: 15, column: 20, scope: !1035)
!1037 = !DILocation(line: 15, column: 3, scope: !1035)
!1038 = !DILocation(line: 14, column: 1, scope: !1035)
!1039 = distinct !DISubprogram(name: "timestamp.ts.set_tsc_ctrl_reg", linkageName: "timestamp.ts.set_tsc_ctrl_reg", scope: null, file: !1040, line: 4, type: !5, scopeLine: 4, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1040 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/time/internal.csl", directory: "")
!1041 = !DILocation(line: 4, column: 21, scope: !1042)
!1042 = !DILexicalBlockFile(scope: !1039, file: !1040, discriminator: 0)
!1043 = !DILocation(line: 6, column: 33, scope: !1042)
!1044 = !DILocation(line: 5, column: 3, scope: !1042)
!1045 = !DILocation(line: 4, column: 1, scope: !1042)
!1046 = distinct !DISubprogram(name: "timestamp.ts.get_value", linkageName: "timestamp.ts.get_value", scope: null, file: !1040, line: 16, type: !5, scopeLine: 16, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1047 = !DILocation(line: 16, column: 45, scope: !1048)
!1048 = !DILexicalBlockFile(scope: !1046, file: !1040, discriminator: 0)
!1049 = !DILocation(line: 16, column: 14, scope: !1048)
!1050 = !DILocation(line: 18, column: 33, scope: !1048)
!1051 = !DILocation(line: 18, column: 21, scope: !1048)
!1052 = !DILocation(line: 18, column: 6, scope: !1048)
!1053 = !DILocation(line: 18, column: 15, scope: !1048)
!1054 = !DILocation(line: 18, column: 19, scope: !1048)
!1055 = !DILocation(line: 18, column: 44, scope: !1048)
!1056 = !DILocation(line: 16, column: 1, scope: !1048)
!1057 = distinct !DISubprogram(name: "timestamp.ts.enable_tsc", linkageName: "timestamp.ts.enable_tsc", scope: null, file: !1040, line: 36, type: !5, scopeLine: 36, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1058 = !DILocation(line: 37, column: 3, scope: !1059)
!1059 = !DILexicalBlockFile(scope: !1057, file: !1040, discriminator: 0)
!1060 = !DILocation(line: 40, column: 3, scope: !1059)
!1061 = !DILocation(line: 36, column: 1, scope: !1059)
!1062 = distinct !DISubprogram(name: "timestamp.ts.disable_tsc", linkageName: "timestamp.ts.disable_tsc", scope: null, file: !1040, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1063 = !DILocation(line: 44, column: 3, scope: !1064)
!1064 = !DILexicalBlockFile(scope: !1062, file: !1040, discriminator: 0)
!1065 = !DILocation(line: 43, column: 1, scope: !1064)
!1066 = distinct !DISubprogram(name: "timestamp.ts.get_timestamp", linkageName: "timestamp.ts.get_timestamp", scope: null, file: !1040, line: 47, type: !5, scopeLine: 47, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1067 = !DILocation(line: 47, column: 18, scope: !1068)
!1068 = !DILexicalBlockFile(scope: !1066, file: !1040, discriminator: 0)
!1069 = !DILocation(line: 49, column: 13, scope: !1068)
!1070 = !DILocation(line: 49, column: 3, scope: !1068)
!1071 = !DILocation(line: 47, column: 1, scope: !1068)
!1072 = distinct !DISubprogram(name: "timestamp.ts.reset_tsc_counter", linkageName: "timestamp.ts.reset_tsc_counter", scope: null, file: !1040, line: 61, type: !5, scopeLine: 61, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1073 = !DILocation(line: 65, column: 5, scope: !1074)
!1074 = !DILexicalBlockFile(scope: !1072, file: !1040, discriminator: 0)
!1075 = !DILocation(line: 61, column: 1, scope: !1074)
!1076 = distinct !DISubprogram(name: ".get_tensor_ptr", linkageName: ".get_tensor_ptr", scope: null, file: !4, line: 1, type: !5, scopeLine: 1, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1077 = !DILocation(line: 1, column: 1, scope: !1078)
!1078 = !DILexicalBlockFile(scope: !1076, file: !4, discriminator: 0)
!1079 = distinct !DISubprogram(name: "__generic0sys_mod.sys_mod.tile_config.queue_flush.exit", linkageName: "__generic0sys_mod.sys_mod.tile_config.queue_flush.exit", scope: null, file: !1080, line: 12, type: !5, scopeLine: 12, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1080 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/queue_flush.csl", directory: "")
!1081 = !DILocation(line: 24, column: 3, scope: !1082)
!1082 = !DILexicalBlockFile(scope: !1079, file: !1080, discriminator: 0)
!1083 = !DILocation(line: 12, column: 1, scope: !1082)
!1084 = distinct !DISubprogram(name: "__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position", linkageName: "__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position", scope: null, file: !1085, line: 30, type: !5, scopeLine: 30, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1085 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/switch_config.csl", directory: "")
!1086 = !DILocation(line: 34, column: 3, scope: !1087)
!1087 = !DILexicalBlockFile(scope: !1084, file: !1085, discriminator: 0)
!1088 = !DILocation(line: 32, column: 3, scope: !1087)
!1089 = !DILocation(line: 30, column: 27, scope: !1087)
!1090 = !DILocation(line: 33, column: 7, scope: !1087)
!1091 = !DILocation(line: 34, column: 36, scope: !1087)
!1092 = !DILocation(line: 34, column: 24, scope: !1087)
!1093 = !DILocation(line: 35, column: 3, scope: !1087)
!1094 = !DILocation(line: 35, column: 18, scope: !1087)
!1095 = !DILocation(line: 36, column: 15, scope: !1087)
!1096 = !DILocation(line: 36, column: 21, scope: !1087)
!1097 = !DILocation(line: 36, column: 3, scope: !1087)
!1098 = !DILocation(line: 30, column: 1, scope: !1087)
!1099 = distinct !DISubprogram(name: "__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", linkageName: "__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", scope: null, file: !1100, line: 96, type: !5, scopeLine: 96, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1100 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/color_config.csl", directory: "")
!1101 = !DILocation(line: 99, column: 3, scope: !1102)
!1102 = !DILexicalBlockFile(scope: !1099, file: !1100, discriminator: 0)
!1103 = !DILocation(line: 98, column: 3, scope: !1102)
!1104 = !DILocation(line: 96, column: 17, scope: !1102)
!1105 = !DILocation(line: 98, column: 16, scope: !1102)
!1106 = !DILocation(line: 99, column: 29, scope: !1102)
!1107 = !DILocation(line: 99, column: 17, scope: !1102)
!1108 = !DILocation(line: 100, column: 13, scope: !1102)
!1109 = !DILocation(line: 100, column: 21, scope: !1102)
!1110 = !DILocation(line: 100, column: 11, scope: !1102)
!1111 = !DILocation(line: 104, column: 7, scope: !1102)
!1112 = !DILocation(line: 104, column: 50, scope: !1102)
!1113 = !DILocation(line: 104, column: 18, scope: !1102)
!1114 = !DILocation(line: 104, column: 15, scope: !1102)
!1115 = !DILocation(line: 121, column: 7, scope: !1102)
!1116 = !DILocation(line: 121, column: 50, scope: !1102)
!1117 = !DILocation(line: 121, column: 18, scope: !1102)
!1118 = !DILocation(line: 121, column: 15, scope: !1102)
!1119 = !DILocation(line: 128, column: 15, scope: !1102)
!1120 = !DILocation(line: 128, column: 21, scope: !1102)
!1121 = !DILocation(line: 128, column: 3, scope: !1102)
!1122 = !DILocation(line: 96, column: 1, scope: !1102)
!1123 = distinct !DISubprogram(name: "__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", linkageName: "__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", scope: null, file: !1100, line: 96, type: !5, scopeLine: 96, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1124 = !DILocation(line: 99, column: 3, scope: !1125)
!1125 = !DILexicalBlockFile(scope: !1123, file: !1100, discriminator: 0)
!1126 = !DILocation(line: 98, column: 3, scope: !1125)
!1127 = !DILocation(line: 96, column: 17, scope: !1125)
!1128 = !DILocation(line: 98, column: 16, scope: !1125)
!1129 = !DILocation(line: 99, column: 29, scope: !1125)
!1130 = !DILocation(line: 99, column: 17, scope: !1125)
!1131 = !DILocation(line: 100, column: 13, scope: !1125)
!1132 = !DILocation(line: 100, column: 21, scope: !1125)
!1133 = !DILocation(line: 100, column: 11, scope: !1125)
!1134 = !DILocation(line: 104, column: 7, scope: !1125)
!1135 = !DILocation(line: 104, column: 50, scope: !1125)
!1136 = !DILocation(line: 104, column: 18, scope: !1125)
!1137 = !DILocation(line: 104, column: 15, scope: !1125)
!1138 = !DILocation(line: 121, column: 7, scope: !1125)
!1139 = !DILocation(line: 121, column: 50, scope: !1125)
!1140 = !DILocation(line: 121, column: 18, scope: !1125)
!1141 = !DILocation(line: 121, column: 15, scope: !1125)
!1142 = !DILocation(line: 128, column: 15, scope: !1125)
!1143 = !DILocation(line: 128, column: 21, scope: !1125)
!1144 = !DILocation(line: 128, column: 3, scope: !1125)
!1145 = !DILocation(line: 96, column: 1, scope: !1125)
!1146 = distinct !DISubprogram(name: "__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", linkageName: "__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", scope: null, file: !1100, line: 60, type: !5, scopeLine: 60, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1147 = !DILocation(line: 61, column: 3, scope: !1148)
!1148 = !DILexicalBlockFile(scope: !1146, file: !1100, discriminator: 0)
!1149 = !DILocation(line: 60, column: 46, scope: !1148)
!1150 = !DILocation(line: 61, column: 16, scope: !1148)
!1151 = !DILocation(line: 72, column: 5, scope: !1148)
!1152 = !DILocation(line: 72, column: 12, scope: !1148)
!1153 = !DILocation(line: 74, column: 10, scope: !1148)
!1154 = !DILocation(line: 74, column: 3, scope: !1148)
!1155 = distinct !DISubprogram(name: "__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes", linkageName: "__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes", scope: null, file: !1100, line: 77, type: !5, scopeLine: 77, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1156 = !DILocation(line: 78, column: 3, scope: !1157)
!1157 = !DILexicalBlockFile(scope: !1155, file: !1100, discriminator: 0)
!1158 = !DILocation(line: 77, column: 46, scope: !1157)
!1159 = !DILocation(line: 78, column: 16, scope: !1157)
!1160 = !DILocation(line: 86, column: 5, scope: !1157)
!1161 = !DILocation(line: 86, column: 12, scope: !1157)
!1162 = !DILocation(line: 91, column: 10, scope: !1157)
!1163 = !DILocation(line: 91, column: 3, scope: !1157)
!1164 = distinct !DISubprogram(name: "__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", linkageName: "__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", scope: null, file: !1100, line: 60, type: !5, scopeLine: 60, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1165 = !DILocation(line: 61, column: 3, scope: !1166)
!1166 = !DILexicalBlockFile(scope: !1164, file: !1100, discriminator: 0)
!1167 = !DILocation(line: 60, column: 46, scope: !1166)
!1168 = !DILocation(line: 61, column: 16, scope: !1166)
!1169 = !DILocation(line: 63, column: 5, scope: !1166)
!1170 = !DILocation(line: 63, column: 12, scope: !1166)
!1171 = !DILocation(line: 74, column: 10, scope: !1166)
!1172 = !DILocation(line: 74, column: 3, scope: !1166)
!1173 = distinct !DISubprogram(name: "__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction", linkageName: "__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction", scope: null, file: !1100, line: 52, type: !5, scopeLine: 52, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1174 = !DILocation(line: 55, column: 3, scope: !1175)
!1175 = !DILexicalBlockFile(scope: !1173, file: !1100, discriminator: 0)
!1176 = !DILocation(line: 54, column: 3, scope: !1175)
!1177 = !DILocation(line: 52, column: 23, scope: !1175)
!1178 = !DILocation(line: 54, column: 16, scope: !1175)
!1179 = !DILocation(line: 55, column: 29, scope: !1175)
!1180 = !DILocation(line: 55, column: 17, scope: !1175)
!1181 = !DILocation(line: 56, column: 3, scope: !1175)
!1182 = !DILocation(line: 56, column: 11, scope: !1175)
!1183 = !DILocation(line: 57, column: 15, scope: !1175)
!1184 = !DILocation(line: 57, column: 21, scope: !1175)
!1185 = !DILocation(line: 57, column: 3, scope: !1175)
!1186 = !DILocation(line: 52, column: 1, scope: !1175)
!1187 = distinct !DISubprogram(name: "__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction", linkageName: "__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction", scope: null, file: !1100, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1188 = !DILocation(line: 23, column: 3, scope: !1189)
!1189 = !DILexicalBlockFile(scope: !1187, file: !1100, discriminator: 0)
!1190 = !DILocation(line: 22, column: 3, scope: !1189)
!1191 = !DILocation(line: 20, column: 21, scope: !1189)
!1192 = !DILocation(line: 22, column: 16, scope: !1189)
!1193 = !DILocation(line: 23, column: 29, scope: !1189)
!1194 = !DILocation(line: 23, column: 17, scope: !1189)
!1195 = !DILocation(line: 24, column: 3, scope: !1189)
!1196 = !DILocation(line: 24, column: 11, scope: !1189)
!1197 = !DILocation(line: 25, column: 15, scope: !1189)
!1198 = !DILocation(line: 25, column: 21, scope: !1189)
!1199 = !DILocation(line: 25, column: 3, scope: !1189)
!1200 = !DILocation(line: 20, column: 1, scope: !1189)
module asm ".section \22.pe_debug_info\22, \22\22"
module asm ".section \22.note\22, \22\22"
