; ModuleID = './layout.csl'
source_filename = "./layout.csl"
target datalayout = "e-ni:0-p:16:16-i1:16-i16:16-i32:32-i64:64-f32:32-f64:64"
target triple = "cs_sdr-cerebras-csos"

@row_ptr = internal global [18 x i16] zeroinitializer, align 4
@col_idx = internal global [64 x i16] zeroinitializer, align 4
@col_start = internal global [16 x i16] zeroinitializer, align 4
@run_len = internal global [16 x i16] zeroinitializer, align 4
@"$$csl_base_address$$0$$val" = dso_local global [64 x float] zeroinitializer, align 4
@"$$csl_base_address$$3$$x" = dso_local global [16 x float] zeroinitializer, align 4
@"$$csl_base_address$$2$$dia_val" = dso_local global [64 x float] zeroinitializer, align 4
@dia_off = internal global [4 x i16] zeroinitializer, align 4
@dia_len = internal global [4 x i16] zeroinitializer, align 4
@dia_row0 = internal global [4 x i16] zeroinitializer, align 4
@dia_xoff = internal global [4 x i16] zeroinitializer, align 4
@"$$csl_base_address$$4$$tmp" = dso_local global [16 x float] zeroinitializer, align 4
@probe_seed = internal global [2 x float] zeroinitializer, align 4
@probe_out = internal global [2 x float] zeroinitializer, align 4
@acc32 = internal global float 0.000000e+00, align 4
@y_sc = internal global [16 x float] zeroinitializer, align 4
@y_ir = internal global [16 x float] zeroinitializer, align 4
@y_bk = internal global [16 x float] zeroinitializer, align 4
@"$$csl_base_address$$1$$y_di" = dso_local global [16 x float] zeroinitializer, align 4
@mark = internal global [16 x i16] zeroinitializer, align 4
@p_row_ptr = internal global i16* getelementptr inbounds ([18 x i16], [18 x i16]* @row_ptr, i32 0, i32 0), align 4
@p_col_idx = internal global i16* getelementptr inbounds ([64 x i16], [64 x i16]* @col_idx, i32 0, i32 0), align 4
@p_col_start = internal global i16* getelementptr inbounds ([16 x i16], [16 x i16]* @col_start, i32 0, i32 0), align 4
@p_run_len = internal global i16* getelementptr inbounds ([16 x i16], [16 x i16]* @run_len, i32 0, i32 0), align 4
@p_val = internal global float* getelementptr inbounds ([64 x float], [64 x float]* @"$$csl_base_address$$0$$val", i32 0, i32 0), align 4
@p_x = internal global float* getelementptr inbounds ([16 x float], [16 x float]* @"$$csl_base_address$$3$$x", i32 0, i32 0), align 4
@p_dia_val = internal global float* getelementptr inbounds ([64 x float], [64 x float]* @"$$csl_base_address$$2$$dia_val", i32 0, i32 0), align 4
@p_dia_off = internal global i16* getelementptr inbounds ([4 x i16], [4 x i16]* @dia_off, i32 0, i32 0), align 4
@p_dia_len = internal global i16* getelementptr inbounds ([4 x i16], [4 x i16]* @dia_len, i32 0, i32 0), align 4
@p_dia_row0 = internal global i16* getelementptr inbounds ([4 x i16], [4 x i16]* @dia_row0, i32 0, i32 0), align 4
@p_dia_xoff = internal global i16* getelementptr inbounds ([4 x i16], [4 x i16]* @dia_xoff, i32 0, i32 0), align 4
@p_probe_seed = internal global float* getelementptr inbounds ([2 x float], [2 x float]* @probe_seed, i32 0, i32 0), align 4
@p_probe_out = internal global float* getelementptr inbounds ([2 x float], [2 x float]* @probe_out, i32 0, i32 0), align 4
@p_y_sc = internal global float* getelementptr inbounds ([16 x float], [16 x float]* @y_sc, i32 0, i32 0), align 4
@p_y_ir = internal global float* getelementptr inbounds ([16 x float], [16 x float]* @y_ir, i32 0, i32 0), align 4
@p_y_bk = internal global float* getelementptr inbounds ([16 x float], [16 x float]* @y_bk, i32 0, i32 0), align 4
@p_y_di = internal global float* getelementptr inbounds ([16 x float], [16 x float]* @"$$csl_base_address$$1$$y_di", i32 0, i32 0), align 4
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
@__dsr_lowmeminit_ = internal constant <{ i16, i16, i16, i16 }> <{ i16 16, i16 lshr (i16 ptrtoint ([16 x float]* @"$$csl_base_address$$1$$y_di" to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
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
  %60 = getelementptr [16 x float], [16 x float]* @"$$csl_base_address$$3$$x", i16 0, i16 %59, !dbg !34
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
entry:
  store i16 28674, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i16 2), align 2
  br label %row.head

row.head:
  %r = phi i16 [ 0, %entry ], [ %r.next, %row.tail ]
  %r.lt = icmp ult i16 %r, 16
  br i1 %r.lt, label %row.body, label %done

row.body:
  %sp = getelementptr [18 x i16], [18 x i16]* @row_ptr, i16 0, i16 %r
  %s = load i16, i16* %sp, align 2
  %r.p1 = add i16 %r, 1
  %ep = getelementptr [18 x i16], [18 x i16]* @row_ptr, i16 0, i16 %r.p1
  %e = load i16, i16* %ep, align 2
  br label %nz.head

nz.head:
  %j = phi i16 [ %s, %row.body ], [ %j.next, %nz.body ]
  %acc = phi float [ 0.000000e+00, %row.body ], [ %acc.next, %nz.body ]
  %j.lt = icmp ult i16 %j, %e
  br i1 %j.lt, label %nz.body, label %nz.done

nz.body:
  %cp = getelementptr [64 x i16], [64 x i16]* @col_idx, i16 0, i16 %j
  %c = load i16, i16* %cp, align 2
  %vp = getelementptr [64 x float], [64 x float]* @"$$csl_base_address$$0$$val", i16 0, i16 %j
  %v = load float, float* %vp, align 4
  %xp = getelementptr [16 x float], [16 x float]* @"$$csl_base_address$$3$$x", i16 0, i16 %c
  %xv = load float, float* %xp, align 4
  %prod = fmul float %v, %xv
  %acc.next = fadd float %acc, %prod
  %j.next = add i16 %j, 1
  br label %nz.head

nz.done:
  %yp = getelementptr [16 x float], [16 x float]* @y_ir, i16 0, i16 %r
  store float %acc, float* %yp, align 4
  br label %row.tail

row.tail:
  %r.next = add i16 %r, 1
  br label %row.head

done:
  store i16 28675, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i16 3), align 2
  call void @llvm.sdr.actvt.r(i16 9)
  ret void
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
  store i16 lshr (i16 ptrtoint ([16 x float]* @"$$csl_base_address$$3$$x" to i16), i16 1), i16* %59, align 2, !dbg !59
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
  store i16 lshr (i16 ptrtoint ([16 x float]* @"$$csl_base_address$$4$$tmp" to i16), i16 1), i16* %79, align 2, !dbg !58
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
  %127 = getelementptr [16 x float], [16 x float]* @"$$csl_base_address$$4$$tmp", i16 0, i16 %126, !dbg !96
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

define internal void @spmv_dia() !dbg !108 {
  %1 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !109
  %2 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !111
  %3 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !112
  %4 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !113
  %5 = alloca i16, i16 1, align 2, !dbg !114
  %6 = alloca i16, i16 1, align 2, !dbg !115
  store i16 28678, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i4 6), align 2, !dbg !116
  call void @llvm.sdr.lddwds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !117
  call void @llvm.sdr.fmov32.dr(i16 1, float 0.000000e+00), !dbg !117
  store i16 0, i16* %6, align 2, !dbg !115
  br label %7, !dbg !118

7:                                                ; preds = %24, %0
  %8 = phi i16 [ 0, %24 ], [ 0, %0 ]
  %9 = icmp sgt i16 %8, 0, !dbg !118
  br i1 %9, label %10, label %12, !dbg !118

10:                                               ; preds = %7
  %11 = sub i16 %8, 1, !dbg !118
  br label %13, !dbg !118

12:                                               ; preds = %7
  br label %13, !dbg !118

13:                                               ; preds = %10, %12
  %14 = phi i16 [ %8, %12 ], [ %11, %10 ]
  br label %15, !dbg !118

15:                                               ; preds = %13
  %16 = icmp ne i16 %8, 0, !dbg !118
  br i1 %16, label %17, label %18, !dbg !118

17:                                               ; preds = %15
  br label %21, !dbg !118

18:                                               ; preds = %15
  %19 = load i16, i16* %6, align 2, !dbg !119
  %20 = icmp ult i16 %19, 4, !dbg !120
  br label %21, !dbg !118

21:                                               ; preds = %17, %18
  %22 = phi i1 [ %20, %18 ], [ false, %17 ]
  br label %23, !dbg !118

23:                                               ; preds = %21
  br i1 %22, label %24, label %149, !dbg !118

24:                                               ; preds = %23
  %25 = load i16, i16* %6, align 2, !dbg !121
  %26 = getelementptr [4 x i16], [4 x i16]* @dia_len, i16 0, i16 %25, !dbg !122
  %27 = load i16, i16* %26, align 2, !dbg !122
  store i16 %27, i16* %5, align 2, !dbg !114
  %28 = load i16, i16* %5, align 2, !dbg !123
  %29 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !113
  store i16 %28, i16* %29, align 2, !dbg !113
  %30 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !113
  store i16 lshr (i16 ptrtoint ([64 x float]* @"$$csl_base_address$$2$$dia_val" to i16), i16 1), i16* %30, align 2, !dbg !113
  %31 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !113
  store i16 143, i16* %31, align 2, !dbg !113
  %32 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !113
  store i16 16, i16* %32, align 2, !dbg !113
  %33 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !124
  %34 = load i16, i16* %33, align 2, !dbg !124
  %35 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !124
  %36 = load i16, i16* %35, align 2, !dbg !124
  %37 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !124
  %38 = load i16, i16* %37, align 2, !dbg !124
  %39 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !124
  %40 = load i16, i16* %39, align 2, !dbg !124
  %41 = load i16, i16* %6, align 2, !dbg !125
  %42 = getelementptr [4 x i16], [4 x i16]* @dia_off, i16 0, i16 %41, !dbg !126
  %43 = load i16, i16* %42, align 2, !dbg !126
  %44 = mul i16 %43, 2, !dbg !127
  %45 = add i16 %36, %44, !dbg !127
  %46 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !128
  store i16 %34, i16* %46, align 2, !dbg !128
  %47 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !128
  store i16 %45, i16* %47, align 2, !dbg !128
  %48 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !128
  store i16 %38, i16* %48, align 2, !dbg !128
  %49 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !128
  store i16 %40, i16* %49, align 2, !dbg !128
  %50 = load i16, i16* %5, align 2, !dbg !129
  %51 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 0, !dbg !112
  store i16 %50, i16* %51, align 2, !dbg !112
  %52 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 1, !dbg !112
  store i16 lshr (i16 ptrtoint ([16 x float]* @"$$csl_base_address$$3$$x" to i16), i16 1), i16* %52, align 2, !dbg !112
  %53 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 2, !dbg !112
  store i16 143, i16* %53, align 2, !dbg !112
  %54 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 3, !dbg !112
  store i16 16, i16* %54, align 2, !dbg !112
  %55 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 0, !dbg !130
  %56 = load i16, i16* %55, align 2, !dbg !130
  %57 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 1, !dbg !130
  %58 = load i16, i16* %57, align 2, !dbg !130
  %59 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 2, !dbg !130
  %60 = load i16, i16* %59, align 2, !dbg !130
  %61 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 3, !dbg !130
  %62 = load i16, i16* %61, align 2, !dbg !130
  %63 = load i16, i16* %6, align 2, !dbg !131
  %64 = getelementptr [4 x i16], [4 x i16]* @dia_xoff, i16 0, i16 %63, !dbg !132
  %65 = load i16, i16* %64, align 2, !dbg !132
  %66 = mul i16 %65, 2, !dbg !133
  %67 = add i16 %58, %66, !dbg !133
  %68 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 0, !dbg !134
  store i16 %56, i16* %68, align 2, !dbg !134
  %69 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 1, !dbg !134
  store i16 %67, i16* %69, align 2, !dbg !134
  %70 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 2, !dbg !134
  store i16 %60, i16* %70, align 2, !dbg !134
  %71 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 3, !dbg !134
  store i16 %62, i16* %71, align 2, !dbg !134
  %72 = load i16, i16* %5, align 2, !dbg !135
  %73 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 0, !dbg !111
  store i16 %72, i16* %73, align 2, !dbg !111
  %74 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 1, !dbg !111
  store i16 lshr (i16 ptrtoint ([16 x float]* @"$$csl_base_address$$4$$tmp" to i16), i16 1), i16* %74, align 2, !dbg !111
  %75 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 2, !dbg !111
  store i16 143, i16* %75, align 2, !dbg !111
  %76 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 3, !dbg !111
  store i16 16, i16* %76, align 2, !dbg !111
  %77 = load i16, i16* %5, align 2, !dbg !136
  %78 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 0, !dbg !109
  store i16 %77, i16* %78, align 2, !dbg !109
  %79 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 1, !dbg !109
  store i16 lshr (i16 ptrtoint ([16 x float]* @"$$csl_base_address$$1$$y_di" to i16), i16 1), i16* %79, align 2, !dbg !109
  %80 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 2, !dbg !109
  store i16 143, i16* %80, align 2, !dbg !109
  %81 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 3, !dbg !109
  store i16 16, i16* %81, align 2, !dbg !109
  %82 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 0, !dbg !137
  %83 = load i16, i16* %82, align 2, !dbg !137
  %84 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 1, !dbg !137
  %85 = load i16, i16* %84, align 2, !dbg !137
  %86 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 2, !dbg !137
  %87 = load i16, i16* %86, align 2, !dbg !137
  %88 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 3, !dbg !137
  %89 = load i16, i16* %88, align 2, !dbg !137
  %90 = load i16, i16* %6, align 2, !dbg !138
  %91 = getelementptr [4 x i16], [4 x i16]* @dia_row0, i16 0, i16 %90, !dbg !139
  %92 = load i16, i16* %91, align 2, !dbg !139
  %93 = mul i16 %92, 2, !dbg !140
  %94 = add i16 %85, %93, !dbg !140
  %95 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 0, !dbg !141
  store i16 %83, i16* %95, align 2, !dbg !141
  %96 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 1, !dbg !141
  store i16 %94, i16* %96, align 2, !dbg !141
  %97 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 2, !dbg !141
  store i16 %87, i16* %97, align 2, !dbg !141
  %98 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 3, !dbg !141
  store i16 %89, i16* %98, align 2, !dbg !141
  %99 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 0, !dbg !142
  %100 = load i16, i16* %99, align 2, !dbg !142
  %101 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 1, !dbg !142
  %102 = load i16, i16* %101, align 2, !dbg !142
  %103 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 2, !dbg !142
  %104 = load i16, i16* %103, align 2, !dbg !142
  %105 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 3, !dbg !142
  %106 = load i16, i16* %105, align 2, !dbg !142
  %107 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !143
  %108 = load i16, i16* %107, align 2, !dbg !143
  %109 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !143
  %110 = load i16, i16* %109, align 2, !dbg !143
  %111 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !143
  %112 = load i16, i16* %111, align 2, !dbg !143
  %113 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !143
  %114 = load i16, i16* %113, align 2, !dbg !143
  %115 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 0, !dbg !144
  %116 = load i16, i16* %115, align 2, !dbg !144
  %117 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 1, !dbg !144
  %118 = load i16, i16* %117, align 2, !dbg !144
  %119 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 2, !dbg !144
  %120 = load i16, i16* %119, align 2, !dbg !144
  %121 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 3, !dbg !144
  %122 = load i16, i16* %121, align 2, !dbg !144
  store volatile i16 %116, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 0), align 2, !dbg !145
  store volatile i16 %118, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 1), align 2, !dbg !145
  store volatile i16 %120, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 2), align 2, !dbg !145
  store volatile i16 %122, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 3), align 2, !dbg !145
  call void asm sideeffect "nop", ""(), !dbg !145
  call void asm sideeffect "nop", ""(), !dbg !145
  store volatile i16 %100, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 0), align 2, !dbg !145
  store volatile i16 %102, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 1), align 2, !dbg !145
  store volatile i16 %104, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 2), align 2, !dbg !145
  store volatile i16 %106, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 3), align 2, !dbg !145
  call void asm sideeffect "nop", ""(), !dbg !145
  call void asm sideeffect "nop", ""(), !dbg !145
  store volatile i16 %108, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -896 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 0), align 2, !dbg !145
  store volatile i16 %110, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -896 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 1), align 2, !dbg !145
  store volatile i16 %112, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -896 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 2), align 2, !dbg !145
  store volatile i16 %114, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -896 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 3), align 2, !dbg !145
  call void asm sideeffect "nop", ""(), !dbg !145
  call void asm sideeffect "nop", ""(), !dbg !145
  call void @llvm.sdr.fmuls.ds0s1(i16 1, i16 1, i16 1), !dbg !145
  %123 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 0, !dbg !146
  %124 = load i16, i16* %123, align 2, !dbg !146
  %125 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 1, !dbg !146
  %126 = load i16, i16* %125, align 2, !dbg !146
  %127 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 2, !dbg !146
  %128 = load i16, i16* %127, align 2, !dbg !146
  %129 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 3, !dbg !146
  %130 = load i16, i16* %129, align 2, !dbg !146
  %131 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 0, !dbg !147
  %132 = load i16, i16* %131, align 2, !dbg !147
  %133 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 1, !dbg !147
  %134 = load i16, i16* %133, align 2, !dbg !147
  %135 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 2, !dbg !147
  %136 = load i16, i16* %135, align 2, !dbg !147
  %137 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 3, !dbg !147
  %138 = load i16, i16* %137, align 2, !dbg !147
  %139 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 0, !dbg !148
  %140 = load i16, i16* %139, align 2, !dbg !148
  %141 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 1, !dbg !148
  %142 = load i16, i16* %141, align 2, !dbg !148
  %143 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 2, !dbg !148
  %144 = load i16, i16* %143, align 2, !dbg !148
  %145 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 3, !dbg !148
  %146 = load i16, i16* %145, align 2, !dbg !148
  store volatile i16 %140, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 0), align 2, !dbg !149
  store volatile i16 %142, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 1), align 2, !dbg !149
  store volatile i16 %144, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 2), align 2, !dbg !149
  store volatile i16 %146, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 3), align 2, !dbg !149
  call void asm sideeffect "nop", ""(), !dbg !149
  call void asm sideeffect "nop", ""(), !dbg !149
  store volatile i16 %124, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 0), align 2, !dbg !149
  store volatile i16 %126, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 1), align 2, !dbg !149
  store volatile i16 %128, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 2), align 2, !dbg !149
  store volatile i16 %130, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 3), align 2, !dbg !149
  call void asm sideeffect "nop", ""(), !dbg !149
  call void asm sideeffect "nop", ""(), !dbg !149
  store volatile i16 %132, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -896 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 0), align 2, !dbg !149
  store volatile i16 %134, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -896 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 1), align 2, !dbg !149
  store volatile i16 %136, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -896 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 2), align 2, !dbg !149
  store volatile i16 %138, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -896 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 3), align 2, !dbg !149
  call void asm sideeffect "nop", ""(), !dbg !149
  call void asm sideeffect "nop", ""(), !dbg !149
  call void @llvm.sdr.fadds.ds0s1(i16 1, i16 1, i16 1), !dbg !149
  %147 = load i16, i16* %6, align 2, !dbg !150
  %148 = add i16 %147, 1, !dbg !151
  store i16 %148, i16* %6, align 2, !dbg !151
  br label %7, !dbg !118

149:                                              ; preds = %23
  %150 = icmp ne i16 %14, 0, !dbg !118
  br i1 %150, label %151, label %152, !dbg !118

151:                                              ; preds = %149
  br label %153, !dbg !118

152:                                              ; preds = %149
  store i16 28679, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i4 7), align 2, !dbg !152
  call void @llvm.sdr.actvt.r(i16 9), !dbg !153
  br label %153, !dbg !118

153:                                              ; preds = %151, %152
  ret void, !dbg !118
}

define internal void @probe_reduce() !dbg !154 {
  %1 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !155
  store i16 28680, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i5 8), align 2, !dbg !157
  %2 = load float, float* getelementptr inbounds ([2 x float], [2 x float]* @probe_seed, i16 0, i1 false), align 4, !dbg !158
  store float %2, float* @acc32, align 4, !dbg !159
  %3 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 0, !dbg !155
  store i16 64, i16* %3, align 2, !dbg !155
  %4 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 1, !dbg !155
  store i16 lshr (i16 ptrtoint ([64 x float]* @"$$csl_base_address$$0$$val" to i16), i16 1), i16* %4, align 2, !dbg !155
  %5 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 2, !dbg !155
  store i16 143, i16* %5, align 2, !dbg !155
  %6 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 3, !dbg !155
  store i16 16, i16* %6, align 2, !dbg !155
  %7 = load float, float* @acc32, align 4, !dbg !160
  %8 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 0, !dbg !161
  %9 = load i16, i16* %8, align 2, !dbg !161
  %10 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 1, !dbg !161
  %11 = load i16, i16* %10, align 2, !dbg !161
  %12 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 2, !dbg !161
  %13 = load i16, i16* %12, align 2, !dbg !161
  %14 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %1, i32 0, i32 3, !dbg !161
  %15 = load i16, i16* %14, align 2, !dbg !161
  store volatile i16 %9, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 0), align 2, !dbg !162
  store volatile i16 %11, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 1), align 2, !dbg !162
  store volatile i16 %13, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 2), align 2, !dbg !162
  store volatile i16 %15, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 3), align 2, !dbg !162
  call void asm sideeffect "nop", ""(), !dbg !162
  call void asm sideeffect "nop", ""(), !dbg !162
  %16 = call float @llvm.sdr.fadds.rrs1(float %7, i16 1), !dbg !162
  store float %16, float* @acc32, align 4, !dbg !162
  %17 = load float, float* @acc32, align 4, !dbg !163
  store float %17, float* getelementptr inbounds ([2 x float], [2 x float]* @probe_out, i16 0, i1 false), align 4, !dbg !164
  store i16 28681, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i5 9), align 2, !dbg !165
  call void @llvm.sdr.actvt.r(i16 9), !dbg !166
  ret void, !dbg !167
}

define void @f_exit() #0 !dbg !168 {
  call void @sys_mod.unblock_cmd_stream(), !dbg !169
  ret void, !dbg !171
}

define internal void @sys_mod.sys_nop() !dbg !172 {
  ret void, !dbg !174
}

define internal void @sys_mod.unblock_cmd_stream() !dbg !176 {
  call void @sys_mod.sys_mod.unblock_cmd_stream(), !dbg !177
  ret void, !dbg !179
}

define internal void @sys_mod.sys_mod.unblock_cmd_stream() !dbg !180 {
  call void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream(), !dbg !182
  ret void, !dbg !184
}

define internal void @sys_mod.sys_mod.teardown_h2d() !dbg !185 {
  call void @llvm.sdr.actvt.r(i16 27), !dbg !186
  ret void, !dbg !188
}

define void @sys_mod.sys_mod.f_ublk_c22() #1 !dbg !189 {
  call void @sys_mod.sys_mod.unblock_cmd_stream(), !dbg !190
  ret void, !dbg !192
}

define internal void @sys_mod.sys_mod.teardown_d2h() !dbg !193 {
  call void @llvm.sdr.blk.r(i16 0), !dbg !194
  call void @llvm.sdr.actvt.r(i16 28), !dbg !196
  ret void, !dbg !197
}

define void @sys_mod.sys_mod.f_memcpyh2d() #2 !dbg !198 {
  %1 = alloca float, i16 1, align 4, !dbg !199
  %2 = alloca float, i16 1, align 4, !dbg !201
  %3 = alloca i16, i16 1, align 2, !dbg !202
  %4 = alloca i16, i16 1, align 2, !dbg !203
  %5 = alloca i16, i16 1, align 2, !dbg !204
  %6 = alloca i16, i16 1, align 2, !dbg !205
  %7 = alloca i16, i16 1, align 2, !dbg !206
  %8 = alloca i16, i16 1, align 2, !dbg !207
  %9 = alloca i16, i16 1, align 2, !dbg !208
  %10 = alloca i16, i16 1, align 2, !dbg !209
  %11 = alloca i16, i16 1, align 2, !dbg !210
  %12 = alloca i16, i16 1, align 2, !dbg !211
  %13 = alloca i16, i16 1, align 2, !dbg !212
  %14 = alloca i16*, i16 1, align 8, !dbg !213
  %15 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !214
  %16 = icmp eq i16 %15, 15, !dbg !215
  br i1 %16, label %17, label %18, !dbg !216

17:                                               ; preds = %0
  br label %19, !dbg !216

18:                                               ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !216
  br label %19, !dbg !216

19:                                               ; preds = %17, %18
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %14, align 8, !dbg !213
  %20 = load i16*, i16** %14, align 8, !dbg !217
  %21 = load i16, i16* %20, align 2, !dbg !218
  store i16 %21, i16* %13, align 2, !dbg !212
  %22 = load i16*, i16** %14, align 8, !dbg !219
  %23 = getelementptr i16, i16* %22, i16 1, !dbg !220
  %24 = load i16, i16* %23, align 2, !dbg !220
  store i16 %24, i16* %12, align 2, !dbg !211
  %25 = load i16*, i16** %14, align 8, !dbg !221
  %26 = getelementptr i16, i16* %25, i16 2, !dbg !222
  %27 = load i16, i16* %26, align 2, !dbg !222
  store i16 %27, i16* %11, align 2, !dbg !210
  %28 = load i16*, i16** %14, align 8, !dbg !223
  %29 = getelementptr i16, i16* %28, i16 3, !dbg !224
  %30 = load i16, i16* %29, align 2, !dbg !224
  store i16 %30, i16* %10, align 2, !dbg !209
  %31 = load i16*, i16** %14, align 8, !dbg !225
  %32 = getelementptr i16, i16* %31, i16 4, !dbg !226
  %33 = load i16, i16* %32, align 2, !dbg !226
  store i16 %33, i16* %9, align 2, !dbg !208
  %34 = load i16*, i16** %14, align 8, !dbg !227
  %35 = getelementptr i16, i16* %34, i16 5, !dbg !228
  %36 = load i16, i16* %35, align 2, !dbg !228
  store i16 %36, i16* %8, align 2, !dbg !207
  %37 = load i16*, i16** %14, align 8, !dbg !229
  %38 = getelementptr i16, i16* %37, i16 6, !dbg !230
  %39 = load i16, i16* %38, align 2, !dbg !230
  store i16 %39, i16* %7, align 2, !dbg !206
  %40 = load i16*, i16** %14, align 8, !dbg !231
  %41 = getelementptr i16, i16* %40, i16 7, !dbg !232
  %42 = load i16, i16* %41, align 2, !dbg !232
  store i16 %42, i16* %6, align 2, !dbg !205
  %43 = load i16*, i16** %14, align 8, !dbg !233
  %44 = getelementptr i16, i16* %43, i16 8, !dbg !234
  %45 = load i16, i16* %44, align 2, !dbg !234
  store i16 %45, i16* %5, align 2, !dbg !204
  %46 = load i16*, i16** %14, align 8, !dbg !235
  %47 = getelementptr i16, i16* %46, i16 9, !dbg !236
  %48 = load i16, i16* %47, align 2, !dbg !236
  store i16 %48, i16* %4, align 2, !dbg !203
  %49 = load i16*, i16** %14, align 8, !dbg !237
  %50 = getelementptr i16, i16* %49, i16 10, !dbg !238
  %51 = load i16, i16* %50, align 2, !dbg !238
  store i16 %51, i16* %3, align 2, !dbg !202
  %52 = load i16*, i16** %14, align 8, !dbg !239
  %53 = getelementptr i16, i16* %52, i16 12, !dbg !240
  %54 = load i16, i16* %53, align 2, !dbg !240
  %55 = zext i16 %54 to i32, !dbg !241
  %56 = load i16*, i16** %14, align 8, !dbg !242
  %57 = getelementptr i16, i16* %56, i16 11, !dbg !243
  %58 = load i16, i16* %57, align 2, !dbg !243
  %59 = zext i16 %58 to i32, !dbg !244
  %60 = add i32 %59, 16, !dbg !245
  %61 = shl i32 %55, %60, !dbg !246
  %62 = bitcast i32 %61 to float, !dbg !247
  store float %62, float* %2, align 4, !dbg !201
  %63 = load i16*, i16** %14, align 8, !dbg !248
  %64 = getelementptr i16, i16* %63, i16 14, !dbg !249
  %65 = load i16, i16* %64, align 2, !dbg !249
  %66 = zext i16 %65 to i32, !dbg !250
  %67 = load i16*, i16** %14, align 8, !dbg !251
  %68 = getelementptr i16, i16* %67, i16 13, !dbg !252
  %69 = load i16, i16* %68, align 2, !dbg !252
  %70 = zext i16 %69 to i32, !dbg !253
  %71 = add i32 %70, 16, !dbg !254
  %72 = shl i32 %66, %71, !dbg !255
  %73 = bitcast i32 %72 to float, !dbg !256
  store float %73, float* %1, align 4, !dbg !199
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !257
  %74 = load i16, i16* %13, align 2, !dbg !258
  store i16 %74, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !259
  %75 = load i16, i16* %12, align 2, !dbg !260
  store i16 %75, i16* @sys_mod.sys_mod.memcpyH2D_px, align 2, !dbg !261
  %76 = load i16, i16* %11, align 2, !dbg !262
  store i16 %76, i16* @sys_mod.sys_mod.memcpyH2D_py, align 2, !dbg !263
  %77 = load i16, i16* %10, align 2, !dbg !264
  store i16 %77, i16* @sys_mod.sys_mod.memcpyH2D_w, align 2, !dbg !265
  %78 = load i16, i16* %9, align 2, !dbg !266
  store i16 %78, i16* @sys_mod.sys_mod.memcpyH2D_h, align 2, !dbg !267
  %79 = load i16, i16* %8, align 2, !dbg !268
  store i16 %79, i16* @sys_mod.sys_mod.memcpyH2D_addr, align 2, !dbg !269
  %80 = load i16, i16* %7, align 2, !dbg !270
  store i16 %80, i16* @sys_mod.sys_mod.memcpyH2D_pe_length, align 2, !dbg !271
  %81 = load i16, i16* %6, align 2, !dbg !272
  store i16 %81, i16* @sys_mod.sys_mod.memcpyH2D_is_half, align 2, !dbg !273
  %82 = load i16, i16* %5, align 2, !dbg !274
  store i16 %82, i16* @sys_mod.sys_mod.memcpyH2D_memcpy_optype, align 2, !dbg !275
  %83 = load i16, i16* %4, align 2, !dbg !276
  store i16 %83, i16* @sys_mod.sys_mod.memcpyH2D_row_stride, align 2, !dbg !277
  %84 = load i16, i16* %3, align 2, !dbg !278
  store i16 %84, i16* @sys_mod.sys_mod.memcpyH2D_col_stride, align 2, !dbg !279
  %85 = load float, float* %2, align 4, !dbg !280
  store float %85, float* @sys_mod.sys_mod.memcpyH2D_one_over_row_stride, align 4, !dbg !281
  %86 = load float, float* %1, align 4, !dbg !282
  store float %86, float* @sys_mod.sys_mod.memcpyH2D_one_over_col_stride, align 4, !dbg !283
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !284
  call void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 0, i16 23, i1 true), !dbg !285
  call void @llvm.sdr.blk.r(i16 27), !dbg !286
  call void @llvm.sdr.oqflush(i16 0), !dbg !287
  store i1 true, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !288
  call void @llvm.sdr.blk.r(i16 0), !dbg !289
  ret void, !dbg !290
}

define void @sys_mod.sys_mod.f_memcpyd2h() #3 !dbg !291 {
  %1 = alloca i16, i16 1, align 2, !dbg !292
  %2 = alloca i16, i16 1, align 2, !dbg !294
  %3 = alloca i16, i16 1, align 2, !dbg !295
  %4 = alloca i16, i16 1, align 2, !dbg !296
  %5 = alloca i16, i16 1, align 2, !dbg !297
  %6 = alloca i16, i16 1, align 2, !dbg !298
  %7 = alloca i16, i16 1, align 2, !dbg !299
  %8 = alloca i16, i16 1, align 2, !dbg !300
  %9 = alloca i16*, i16 1, align 8, !dbg !301
  %10 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !302
  %11 = icmp eq i16 %10, 8, !dbg !303
  br i1 %11, label %12, label %13, !dbg !304

12:                                               ; preds = %0
  br label %14, !dbg !304

13:                                               ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !304
  br label %14, !dbg !304

14:                                               ; preds = %12, %13
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %9, align 8, !dbg !301
  %15 = load i16*, i16** %9, align 8, !dbg !305
  %16 = load i16, i16* %15, align 2, !dbg !306
  store i16 %16, i16* %8, align 2, !dbg !300
  %17 = load i16*, i16** %9, align 8, !dbg !307
  %18 = getelementptr i16, i16* %17, i16 1, !dbg !308
  %19 = load i16, i16* %18, align 2, !dbg !308
  store i16 %19, i16* %7, align 2, !dbg !299
  %20 = load i16*, i16** %9, align 8, !dbg !309
  %21 = getelementptr i16, i16* %20, i16 2, !dbg !310
  %22 = load i16, i16* %21, align 2, !dbg !310
  store i16 %22, i16* %6, align 2, !dbg !298
  %23 = load i16*, i16** %9, align 8, !dbg !311
  %24 = getelementptr i16, i16* %23, i16 3, !dbg !312
  %25 = load i16, i16* %24, align 2, !dbg !312
  store i16 %25, i16* %5, align 2, !dbg !297
  %26 = load i16*, i16** %9, align 8, !dbg !313
  %27 = getelementptr i16, i16* %26, i16 4, !dbg !314
  %28 = load i16, i16* %27, align 2, !dbg !314
  store i16 %28, i16* %4, align 2, !dbg !296
  %29 = load i16*, i16** %9, align 8, !dbg !315
  %30 = getelementptr i16, i16* %29, i16 5, !dbg !316
  %31 = load i16, i16* %30, align 2, !dbg !316
  store i16 %31, i16* %3, align 2, !dbg !295
  %32 = load i16*, i16** %9, align 8, !dbg !317
  %33 = getelementptr i16, i16* %32, i16 6, !dbg !318
  %34 = load i16, i16* %33, align 2, !dbg !318
  store i16 %34, i16* %2, align 2, !dbg !294
  %35 = load i16*, i16** %9, align 8, !dbg !319
  %36 = getelementptr i16, i16* %35, i16 7, !dbg !320
  %37 = load i16, i16* %36, align 2, !dbg !320
  store i16 %37, i16* %1, align 2, !dbg !292
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !321
  %38 = load i16, i16* %8, align 2, !dbg !322
  store i16 %38, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !323
  %39 = load i16, i16* %7, align 2, !dbg !324
  store i16 %39, i16* @sys_mod.sys_mod.memcpyD2H_px, align 2, !dbg !325
  %40 = load i16, i16* %6, align 2, !dbg !326
  store i16 %40, i16* @sys_mod.sys_mod.memcpyD2H_py, align 2, !dbg !327
  %41 = load i16, i16* %5, align 2, !dbg !328
  store i16 %41, i16* @sys_mod.sys_mod.memcpyD2H_w, align 2, !dbg !329
  %42 = load i16, i16* %4, align 2, !dbg !330
  store i16 %42, i16* @sys_mod.sys_mod.memcpyD2H_h, align 2, !dbg !331
  %43 = load i16, i16* %3, align 2, !dbg !332
  store i16 %43, i16* @sys_mod.sys_mod.memcpyD2H_addr, align 2, !dbg !333
  %44 = load i16, i16* %2, align 2, !dbg !334
  store i16 %44, i16* @sys_mod.sys_mod.memcpyD2H_pe_length, align 2, !dbg !335
  %45 = load i16, i16* %1, align 2, !dbg !336
  store i16 %45, i16* @sys_mod.sys_mod.memcpyD2H_is_half, align 2, !dbg !337
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !338
  %46 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !339
  call void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 0, i16 %46, i1 false), !dbg !340
  call void @llvm.sdr.oqflush(i16 0), !dbg !341
  store i1 false, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !342
  ret void, !dbg !343
}

define internal void @sys_mod.sys_mod.oq0_teardow_handler() !dbg !344 {
  %1 = load i1, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !345
  br i1 %1, label %2, label %17, !dbg !347

2:                                                ; preds = %0
  %3 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !348
  call void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 0, i16 %3), !dbg !349
  %4 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !350
  %5 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_px, align 2, !dbg !351
  %6 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_py, align 2, !dbg !352
  %7 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_w, align 2, !dbg !353
  %8 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_h, align 2, !dbg !354
  %9 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_addr, align 2, !dbg !355
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_pe_length, align 2, !dbg !356
  %11 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_is_half, align 2, !dbg !357
  %12 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_memcpy_optype, align 2, !dbg !358
  %13 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_row_stride, align 2, !dbg !359
  %14 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_col_stride, align 2, !dbg !360
  %15 = load float, float* @sys_mod.sys_mod.memcpyH2D_one_over_row_stride, align 4, !dbg !361
  %16 = load float, float* @sys_mod.sys_mod.memcpyH2D_one_over_col_stride, align 4, !dbg !362
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure(i16 %4, i16 %5, i16 %6, i16 %7, i16 %8, i16 %9, i16 %10, i16 %11, i16 %12, i16 %13, i16 %14, float %15, float %16), !dbg !363
  br label %26, !dbg !347

17:                                               ; preds = %0
  call void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 0, i16 21), !dbg !364
  %18 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !365
  %19 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_px, align 2, !dbg !366
  %20 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_py, align 2, !dbg !367
  %21 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_w, align 2, !dbg !368
  %22 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_h, align 2, !dbg !369
  %23 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_addr, align 2, !dbg !370
  %24 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_pe_length, align 2, !dbg !371
  %25 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_is_half, align 2, !dbg !372
  call void @sys_mod.sys_mod.memcpyd2h_mod.d2h_configure(i16 %18, i16 %19, i16 %20, i16 %21, i16 %22, i16 %23, i16 %24, i16 %25), !dbg !373
  br label %26, !dbg !347

26:                                               ; preds = %2, %17
  call void @__generic0sys_mod.sys_mod.tile_config.queue_flush.exit(), !dbg !374
  ret void, !dbg !347
}

define internal void @rpc_server(i32* %0) {
  %2 = load i32, i32* %0, align 4
  %3 = add i32 %2, 1
  %4 = getelementptr i32, i32* %0, i32 %3
  %5 = load i32, i32* %4, align 4
  switch i32 %5, label %6 [
    i32 20, label %7
    i32 23, label %12
    i32 22, label %17
    i32 19, label %22
    i32 21, label %27
  ]

6:                                                ; preds = %1
  br label %32

7:                                                ; preds = %1
  %8 = icmp eq i32 0, %2
  br i1 %8, label %9, label %10

9:                                                ; preds = %7
  br label %11

10:                                               ; preds = %7
  call void asm sideeffect "hcf", ""()
  br label %11

11:                                               ; preds = %9, %10
  call void @spmv_ir()
  br label %32

12:                                               ; preds = %1
  %13 = icmp eq i32 0, %2
  br i1 %13, label %14, label %15

14:                                               ; preds = %12
  br label %16

15:                                               ; preds = %12
  call void asm sideeffect "hcf", ""()
  br label %16

16:                                               ; preds = %14, %15
  call void @probe_reduce()
  br label %32

17:                                               ; preds = %1
  %18 = icmp eq i32 0, %2
  br i1 %18, label %19, label %20

19:                                               ; preds = %17
  br label %21

20:                                               ; preds = %17
  call void asm sideeffect "hcf", ""()
  br label %21

21:                                               ; preds = %19, %20
  call void @spmv_dia()
  br label %32

22:                                               ; preds = %1
  %23 = icmp eq i32 0, %2
  br i1 %23, label %24, label %25

24:                                               ; preds = %22
  br label %26

25:                                               ; preds = %22
  call void asm sideeffect "hcf", ""()
  br label %26

26:                                               ; preds = %24, %25
  call void @spmv_scalar()
  br label %32

27:                                               ; preds = %1
  %28 = icmp eq i32 0, %2
  br i1 %28, label %29, label %30

29:                                               ; preds = %27
  br label %31

30:                                               ; preds = %27
  call void asm sideeffect "hcf", ""()
  br label %31

31:                                               ; preds = %29, %30
  call void @spmv_blk()
  br label %32

32:                                               ; preds = %6, %11, %16, %21, %26, %31
  ret void
}

define void @sys_mod.sys_mod.f_rpc(i16 %0) #4 !dbg !375 {
  %2 = alloca i16, i16 1, align 2, !dbg !376
  store i16 %0, i16* %2, align 2, !dbg !376
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !378
  %3 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !379
  %4 = icmp sge i16 %3, 4, !dbg !380
  br i1 %4, label %5, label %6, !dbg !381

5:                                                ; preds = %1
  br label %7, !dbg !381

6:                                                ; preds = %1
  call void asm sideeffect "hcf", ""(), !dbg !381
  br label %7, !dbg !381

7:                                                ; preds = %5, %6
  call void @rpc_server(i32* getelementptr inbounds ([32 x i32], [32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32, i32 0, i32 0)), !dbg !382
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !383
  ret void, !dbg !384
}

define internal void @sys_mod.sys_mod.sys_mod.stack_push(i16 %0) !dbg !385 {
  %2 = alloca i16*, i16 1, align 8, !dbg !387
  %3 = alloca i16, i16 1, align 2, !dbg !389
  store i16 %0, i16* %3, align 2, !dbg !389
  %4 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !390
  %5 = icmp slt i16 %4, 32, !dbg !391
  br i1 %5, label %6, label %7, !dbg !392

6:                                                ; preds = %1
  br label %8, !dbg !392

7:                                                ; preds = %1
  call void asm sideeffect "hcf", ""(), !dbg !392
  br label %8, !dbg !392

8:                                                ; preds = %6, %7
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %2, align 8, !dbg !387
  %9 = load i16, i16* %3, align 2, !dbg !393
  %10 = load i16*, i16** %2, align 8, !dbg !394
  %11 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !395
  %12 = getelementptr i16, i16* %10, i16 %11, !dbg !396
  store i16 %9, i16* %12, align 2, !dbg !397
  %13 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !398
  %14 = add i16 %13, 1, !dbg !399
  store i16 %14, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !400
  ret void, !dbg !401
}

define void @sys_mod.sys_mod.sys_mod.f_push(i16 %0, i16 %1) #5 !dbg !402 {
  %3 = alloca i16, i16 1, align 2, !dbg !403
  %4 = alloca i16, i16 1, align 2, !dbg !405
  store i16 %0, i16* %4, align 2, !dbg !405
  store i16 %1, i16* %3, align 2, !dbg !403
  %5 = load i16, i16* %4, align 2, !dbg !406
  call void @sys_mod.sys_mod.sys_mod.stack_push(i16 %5), !dbg !407
  ret void, !dbg !408
}

define internal void @sys_mod.sys_mod.sys_mod.block_cmd_stream() !dbg !409 {
  call void @llvm.sdr.blk.r(i16 1), !dbg !410
  ret void, !dbg !412
}

define internal void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream() !dbg !413 {
  call void @llvm.sdr.ublk.r(i16 1), !dbg !414
  ret void, !dbg !416
}

define void @sys_mod.sys_mod.sys_mod.f_sys_exit() #6 !dbg !417 {
  call void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream(), !dbg !418
  call void @sys_mod.sys_nop(), !dbg !420
  ret void, !dbg !421
}

define void @sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore(i32 %0) #7 !dbg !422 {
  %2 = alloca i32, i16 1, align 4, !dbg !423
  store i32 %0, i32* %2, align 4, !dbg !423
  ret void, !dbg !425
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord() !dbg !426 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord(), !dbg !428
  ret i16 %1, !dbg !430
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord() !dbg !431 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord(), !dbg !432
  ret i16 %1, !dbg !434
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval(i16 %0) !dbg !435 {
  %2 = alloca i16, i16 1, align 2, !dbg !436
  store i16 %0, i16* %2, align 2, !dbg !436
  %3 = load i16, i16* %2, align 2, !dbg !438
  %4 = icmp ult i16 %3, 24, !dbg !439
  br i1 %4, label %5, label %7, !dbg !440

5:                                                ; preds = %10, %11, %1
  %6 = phi i16 [ 0, %10 ], [ 0, %11 ], [ 1, %1 ]
  br label %12, !dbg !440

7:                                                ; preds = %1
  %8 = load i16, i16* %2, align 2, !dbg !441
  %9 = icmp eq i16 31, %8, !dbg !442
  br i1 %9, label %10, label %11, !dbg !443

10:                                               ; preds = %7
  br label %5, !dbg !443

11:                                               ; preds = %7
  call void asm sideeffect "hcf", ""(), !dbg !443
  br label %5, !dbg !443

12:                                               ; preds = %5
  %13 = phi i16 [ %6, %5 ]
  br label %14, !dbg !440

14:                                               ; preds = %12
  ret i16 %13, !dbg !440
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start(i16 %0, i16 %1, i16 %2) !dbg !444 {
  %4 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !445
  %5 = alloca i16, i16 1, align 2, !dbg !447
  %6 = alloca i16, i16 1, align 2, !dbg !448
  %7 = alloca i16, i16 1, align 2, !dbg !449
  store i16 %0, i16* %7, align 2, !dbg !449
  store i16 %1, i16* %6, align 2, !dbg !448
  store i16 %2, i16* %5, align 2, !dbg !447
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !450
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !450
  %10 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !450
  %11 = load i16, i16* %6, align 2, !dbg !451
  store i16 %11, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !452
  store i16 %8, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !452
  store i16 %9, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !452
  store i16 %10, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !452
  %12 = load i16, i16* %7, align 2, !dbg !453
  %13 = call i16* @.get_tensor_ptr(i16 %12), !dbg !454
  %14 = ptrtoint i16* %13 to i16, !dbg !455
  %15 = lshr i16 %14, 1, !dbg !455
  %16 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !445
  store i16 42, i16* %16, align 2, !dbg !445
  %17 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !445
  store i16 %15, i16* %17, align 2, !dbg !445
  %18 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !445
  store i16 143, i16* %18, align 2, !dbg !445
  %19 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !445
  store i16 16, i16* %19, align 2, !dbg !445
  %20 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !456
  %21 = load i16, i16* %20, align 2, !dbg !456
  %22 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !456
  %23 = load i16, i16* %22, align 2, !dbg !456
  %24 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !456
  %25 = load i16, i16* %24, align 2, !dbg !456
  %26 = load i16, i16* %6, align 2, !dbg !457
  %27 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !458
  store i16 %26, i16* %27, align 2, !dbg !458
  %28 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !458
  store i16 %21, i16* %28, align 2, !dbg !458
  %29 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !458
  store i16 %23, i16* %29, align 2, !dbg !458
  %30 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !458
  store i16 %25, i16* %30, align 2, !dbg !458
  %31 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !459
  %32 = load i16, i16* %31, align 2, !dbg !459
  %33 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !459
  %34 = load i16, i16* %33, align 2, !dbg !459
  %35 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !459
  %36 = load i16, i16* %35, align 2, !dbg !459
  %37 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !459
  %38 = load i16, i16* %37, align 2, !dbg !459
  store volatile i16 %32, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !460
  store volatile i16 %34, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !460
  store volatile i16 %36, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !460
  store volatile i16 %38, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !460
  call void asm sideeffect "nop", ""(), !dbg !460
  call void asm sideeffect "nop", ""(), !dbg !460
  %39 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !461
  %40 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !461
  %41 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !461
  %42 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !461
  %43 = and i16 %41, -193, !dbg !461
  %44 = or i16 %43, 128, !dbg !461
  %45 = and i16 %40, -64, !dbg !461
  %46 = or i16 %45, 27, !dbg !461
  store volatile i16 %39, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !462
  store volatile i16 %46, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !462
  store volatile i16 %44, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !462
  store volatile i16 %42, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !462
  call void asm sideeffect "nop", ""(), !dbg !462
  call void asm sideeffect "nop", ""(), !dbg !462
  %47 = load i16, i16* %5, align 2, !dbg !463
  %48 = icmp ult i16 0, %47, !dbg !464
  br i1 %48, label %49, label %50, !dbg !465

49:                                               ; preds = %3
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !466
  br label %51, !dbg !465

50:                                               ; preds = %3
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !467
  br label %51, !dbg !465

51:                                               ; preds = %49, %50
  ret void, !dbg !465
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream() !dbg !468 {
  call void @llvm.sdr.ublk.r(i16 1), !dbg !469
  ret void, !dbg !471
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7, i16 %8, i16 %9, i16 %10, float %11, float %12) !dbg !472 {
  %14 = alloca i16, i16 1, align 2, !dbg !473
  %15 = alloca i16, i16 1, align 2, !dbg !475
  %16 = alloca i16, i16 1, align 2, !dbg !476
  %17 = alloca i16, i16 1, align 2, !dbg !477
  %18 = alloca i16, i16 1, align 2, !dbg !478
  %19 = alloca i1, i16 1, align 1, !dbg !479
  %20 = alloca i16, i16 1, align 2, !dbg !480
  %21 = alloca i16, i16 1, align 2, !dbg !481
  %22 = alloca i16, i16 1, align 2, !dbg !482
  %23 = alloca i16, i16 1, align 2, !dbg !483
  %24 = alloca i16, i16 1, align 2, !dbg !484
  %25 = alloca float, i16 1, align 4, !dbg !485
  %26 = alloca float, i16 1, align 4, !dbg !486
  %27 = alloca i16, i16 1, align 2, !dbg !487
  %28 = alloca i16, i16 1, align 2, !dbg !488
  %29 = alloca i16, i16 1, align 2, !dbg !489
  %30 = alloca i16, i16 1, align 2, !dbg !490
  %31 = alloca i16, i16 1, align 2, !dbg !491
  %32 = alloca i16, i16 1, align 2, !dbg !492
  %33 = alloca i16, i16 1, align 2, !dbg !493
  %34 = alloca i16, i16 1, align 2, !dbg !494
  %35 = alloca i16, i16 1, align 2, !dbg !495
  %36 = alloca i16, i16 1, align 2, !dbg !496
  %37 = alloca i16, i16 1, align 2, !dbg !497
  store i16 %0, i16* %37, align 2, !dbg !497
  store i16 %1, i16* %36, align 2, !dbg !496
  store i16 %2, i16* %35, align 2, !dbg !495
  store i16 %3, i16* %34, align 2, !dbg !494
  store i16 %4, i16* %33, align 2, !dbg !493
  store i16 %5, i16* %32, align 2, !dbg !492
  store i16 %6, i16* %31, align 2, !dbg !491
  store i16 %7, i16* %30, align 2, !dbg !490
  store i16 %8, i16* %29, align 2, !dbg !489
  store i16 %9, i16* %28, align 2, !dbg !488
  store i16 %10, i16* %27, align 2, !dbg !487
  store float %11, float* %26, align 4, !dbg !486
  store float %12, float* %25, align 4, !dbg !485
  %38 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord(), !dbg !498
  store i16 %38, i16* %24, align 2, !dbg !484
  %39 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord(), !dbg !499
  store i16 %39, i16* %23, align 2, !dbg !483
  %40 = load i16, i16* %24, align 2, !dbg !500
  %41 = load i16, i16* %36, align 2, !dbg !501
  %42 = sub i16 %40, %41, !dbg !502
  store i16 %42, i16* %22, align 2, !dbg !482
  %43 = load i16, i16* %22, align 2, !dbg !503
  store i16 %43, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !504
  %44 = load i16, i16* %29, align 2, !dbg !505
  %45 = icmp eq i16 3, %44, !dbg !506
  br i1 %45, label %46, label %63, !dbg !507

46:                                               ; preds = %13
  %47 = load i16, i16* %22, align 2, !dbg !508
  %48 = sitofp i16 %47 to float, !dbg !509
  %49 = load float, float* %26, align 4, !dbg !510
  %50 = fmul float %48, %49, !dbg !511
  %51 = fptosi float %50 to i16, !dbg !512
  store i16 %51, i16* %21, align 2, !dbg !481
  %52 = load i16, i16* %22, align 2, !dbg !513
  %53 = load i16, i16* %21, align 2, !dbg !514
  %54 = load i16, i16* %28, align 2, !dbg !515
  %55 = mul i16 %53, %54, !dbg !516
  %56 = sub i16 %52, %55, !dbg !517
  store i16 %56, i16* %20, align 2, !dbg !480
  %57 = load i16, i16* %20, align 2, !dbg !518
  %58 = icmp ne i16 0, %57, !dbg !519
  br i1 %58, label %59, label %60, !dbg !520

59:                                               ; preds = %46
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !521
  br label %62, !dbg !520

60:                                               ; preds = %46
  %61 = load i16, i16* %21, align 2, !dbg !522
  store i16 %61, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !523
  br label %62, !dbg !520

62:                                               ; preds = %59, %60
  br label %63, !dbg !507

63:                                               ; preds = %62, %13
  %64 = load i16, i16* %22, align 2, !dbg !524
  %65 = icmp slt i16 %64, 0, !dbg !525
  br i1 %65, label %66, label %67, !dbg !526

66:                                               ; preds = %63
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !527
  br label %67, !dbg !526

67:                                               ; preds = %66, %63
  %68 = load i16, i16* %22, align 2, !dbg !528
  %69 = load i16, i16* %34, align 2, !dbg !529
  %70 = icmp sge i16 %68, %69, !dbg !530
  br i1 %70, label %71, label %72, !dbg !531

71:                                               ; preds = %67
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !532
  br label %72, !dbg !531

72:                                               ; preds = %71, %67
  store i1 false, i1* %19, align 1, !dbg !479
  %73 = load i16, i16* %29, align 2, !dbg !533
  %74 = icmp eq i16 3, %73, !dbg !534
  br i1 %74, label %75, label %94, !dbg !535

75:                                               ; preds = %72
  %76 = load i16, i16* %23, align 2, !dbg !536
  %77 = load i16, i16* %35, align 2, !dbg !537
  %78 = sub i16 %76, %77, !dbg !538
  %79 = sitofp i16 %78 to float, !dbg !539
  %80 = load float, float* %25, align 4, !dbg !540
  %81 = fmul float %79, %80, !dbg !541
  %82 = fptosi float %81 to i16, !dbg !542
  store i16 %82, i16* %18, align 2, !dbg !478
  %83 = load i16, i16* %23, align 2, !dbg !543
  %84 = load i16, i16* %35, align 2, !dbg !544
  %85 = sub i16 %83, %84, !dbg !545
  %86 = load i16, i16* %18, align 2, !dbg !546
  %87 = load i16, i16* %27, align 2, !dbg !547
  %88 = mul i16 %86, %87, !dbg !548
  %89 = sub i16 %85, %88, !dbg !549
  store i16 %89, i16* %17, align 2, !dbg !477
  %90 = load i16, i16* %17, align 2, !dbg !550
  %91 = icmp ne i16 0, %90, !dbg !551
  br i1 %91, label %92, label %93, !dbg !552

92:                                               ; preds = %75
  store i1 true, i1* %19, align 1, !dbg !553
  br label %93, !dbg !552

93:                                               ; preds = %92, %75
  br label %94, !dbg !535

94:                                               ; preds = %93, %72
  %95 = load i16, i16* %23, align 2, !dbg !554
  %96 = load i16, i16* %35, align 2, !dbg !555
  %97 = icmp slt i16 %95, %96, !dbg !556
  br i1 %97, label %98, label %99, !dbg !557

98:                                               ; preds = %94
  store i1 true, i1* %19, align 1, !dbg !558
  br label %99, !dbg !557

99:                                               ; preds = %98, %94
  %100 = load i16, i16* %23, align 2, !dbg !559
  %101 = load i16, i16* %35, align 2, !dbg !560
  %102 = load i16, i16* %33, align 2, !dbg !561
  %103 = add i16 %101, %102, !dbg !562
  %104 = icmp sge i16 %100, %103, !dbg !563
  br i1 %104, label %105, label %106, !dbg !564

105:                                              ; preds = %99
  store i1 true, i1* %19, align 1, !dbg !565
  br label %106, !dbg !564

106:                                              ; preds = %105, %99
  %107 = load i1, i1* %19, align 1, !dbg !566
  br i1 %107, label %108, label %109, !dbg !567

108:                                              ; preds = %106
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream(), !dbg !568
  call void @llvm.sdr.ublk.r(i16 27), !dbg !569
  br label %180, !dbg !567

109:                                              ; preds = %106
  %110 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !570
  %111 = icmp eq i16 -1, %110, !dbg !571
  br i1 %111, label %112, label %113, !dbg !572

112:                                              ; preds = %109
  call void @__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction(i16 31767), !dbg !573
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 23), !dbg !574
  call void @llvm.sdr.ublk.r(i16 27), !dbg !575
  br label %179, !dbg !572

113:                                              ; preds = %109
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter(i16 0, i16 0), !dbg !576
  %114 = load i16, i16* %34, align 2, !dbg !577
  store i16 %114, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !578
  %115 = load i16, i16* %29, align 2, !dbg !579
  %116 = icmp eq i16 3, %115, !dbg !580
  br i1 %116, label %117, label %126, !dbg !581

117:                                              ; preds = %113
  %118 = load i16, i16* %34, align 2, !dbg !582
  %119 = sub i16 %118, 1, !dbg !583
  %120 = sitofp i16 %119 to float, !dbg !584
  %121 = load float, float* %26, align 4, !dbg !585
  %122 = fmul float %120, %121, !dbg !586
  %123 = fptosi float %122 to i16, !dbg !587
  %124 = add i16 %123, 1, !dbg !588
  store i16 %124, i16* %16, align 2, !dbg !476
  %125 = load i16, i16* %16, align 2, !dbg !589
  store i16 %125, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !590
  br label %131, !dbg !581

126:                                              ; preds = %113
  %127 = load i16, i16* %29, align 2, !dbg !591
  %128 = icmp eq i16 1, %127, !dbg !592
  br i1 %128, label %129, label %130, !dbg !593

129:                                              ; preds = %126
  store i16 1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !594
  br label %130, !dbg !593

130:                                              ; preds = %129, %126
  br label %131, !dbg !581

131:                                              ; preds = %117, %130
  %132 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !595
  %133 = sub i16 %132, 1, !dbg !596
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit(i16 0, i16 %133), !dbg !597
  %134 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !598
  store i16 %134, i16* %15, align 2, !dbg !475
  %135 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !599
  store i16 %135, i16* %14, align 2, !dbg !473
  %136 = load i16, i16* %15, align 2, !dbg !600
  %137 = load i16, i16* %14, align 2, !dbg !601
  %138 = sub i16 %136, %137, !dbg !602
  store i16 %138, i16* %15, align 2, !dbg !603
  %139 = load i16, i16* %14, align 2, !dbg !604
  %140 = icmp eq i16 0, %139, !dbg !605
  br i1 %140, label %141, label %142, !dbg !606

141:                                              ; preds = %131
  store i16 0, i16* %15, align 2, !dbg !607
  br label %142, !dbg !606

142:                                              ; preds = %141, %131
  %143 = load i16, i16* %29, align 2, !dbg !608
  %144 = icmp eq i16 1, %143, !dbg !609
  br i1 %144, label %145, label %146, !dbg !610

145:                                              ; preds = %142
  store i16 0, i16* %15, align 2, !dbg !611
  br label %146, !dbg !610

146:                                              ; preds = %145, %142
  %147 = load i16, i16* %15, align 2, !dbg !612
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter(i16 0, i16 %147), !dbg !613
  call void @__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction(i16 31767), !dbg !614
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 23), !dbg !615
  %148 = load i16, i16* %37, align 2, !dbg !616
  %149 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval(i16 %148), !dbg !617
  %150 = icmp eq i16 0, %149, !dbg !618
  br i1 %150, label %151, label %155, !dbg !619

151:                                              ; preds = %146
  %152 = load i16, i16* %32, align 2, !dbg !620
  %153 = load i16, i16* %31, align 2, !dbg !621
  %154 = load i16, i16* %30, align 2, !dbg !622
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start(i16 %152, i16 %153, i16 %154), !dbg !623
  br label %178, !dbg !619

155:                                              ; preds = %146
  %156 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !624
  %157 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !624
  %158 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !624
  %159 = load i16, i16* %31, align 2, !dbg !625
  store i16 %159, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !626
  store i16 %156, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !626
  store i16 %157, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !626
  store i16 %158, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !626
  %160 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !627
  %161 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !627
  %162 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !627
  %163 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !627
  %164 = and i16 %162, -193, !dbg !627
  %165 = or i16 %164, 128, !dbg !627
  store volatile i16 %160, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !628
  store volatile i16 %161, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !628
  store volatile i16 %165, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !628
  store volatile i16 %163, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !628
  call void asm sideeffect "nop", ""(), !dbg !628
  call void asm sideeffect "nop", ""(), !dbg !628
  %166 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !629
  %167 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !629
  %168 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !629
  %169 = load i16, i16* %31, align 2, !dbg !630
  store i16 %169, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !631
  store i16 %166, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !631
  store i16 %167, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !631
  store i16 %168, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !631
  %170 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !632
  %171 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !632
  %172 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !632
  %173 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !632
  %174 = and i16 %172, -193, !dbg !632
  %175 = or i16 %174, 128, !dbg !632
  %176 = and i16 %171, -64, !dbg !632
  %177 = or i16 %176, 27, !dbg !632
  store volatile i16 %170, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !633
  store volatile i16 %177, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !633
  store volatile i16 %175, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !633
  store volatile i16 %173, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !633
  call void asm sideeffect "nop", ""(), !dbg !633
  call void asm sideeffect "nop", ""(), !dbg !633
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !634
  br label %178, !dbg !619

178:                                              ; preds = %151, %155
  br label %179, !dbg !572

179:                                              ; preds = %112, %178
  br label %180, !dbg !567

180:                                              ; preds = %108, %179
  ret void, !dbg !507
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit(i16 %0, i16 %1) !dbg !635 {
  %3 = alloca i16, i16 1, align 2, !dbg !637
  %4 = alloca i16, i16 1, align 2, !dbg !639
  %5 = alloca i16, i16 1, align 2, !dbg !640
  %6 = alloca i16, i16 1, align 2, !dbg !641
  %7 = alloca i16, i16 1, align 2, !dbg !642
  %8 = alloca i16, i16 1, align 2, !dbg !643
  store i16 %0, i16* %8, align 2, !dbg !643
  store i16 %1, i16* %7, align 2, !dbg !642
  %9 = load i16, i16* %7, align 2, !dbg !644
  %10 = icmp ult i16 %9, -32768, !dbg !645
  br i1 %10, label %11, label %12, !dbg !646

11:                                               ; preds = %2
  br label %13, !dbg !646

12:                                               ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !646
  br label %13, !dbg !646

13:                                               ; preds = %11, %12
  %14 = load i16, i16* %7, align 2, !dbg !647
  %15 = mul i16 %14, 2, !dbg !648
  store i16 %15, i16* %6, align 2, !dbg !641
  %16 = load i16, i16* %8, align 2, !dbg !649
  %17 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %16, i16 8), !dbg !650
  %18 = sub i16 %17, 1, !dbg !651
  store i16 %18, i16* %5, align 2, !dbg !640
  %19 = load i16, i16* %6, align 2, !dbg !652
  %20 = load i16, i16* %5, align 2, !dbg !653
  %21 = icmp ult i16 %19, %20, !dbg !654
  br i1 %21, label %22, label %23, !dbg !639

22:                                               ; preds = %13
  store i16 0, i16* %4, align 2, !dbg !639
  br label %27, !dbg !639

23:                                               ; preds = %13
  %24 = load i16, i16* %6, align 2, !dbg !655
  %25 = load i16, i16* %5, align 2, !dbg !656
  %26 = sub i16 %24, %25, !dbg !657
  store i16 %26, i16* %4, align 2, !dbg !639
  br label %27, !dbg !639

27:                                               ; preds = %22, %23
  %28 = load i16, i16* %4, align 2, !dbg !639
  store i16 %28, i16* %3, align 2, !dbg !637
  %29 = load i16, i16* %8, align 2, !dbg !658
  %30 = load i16, i16* %3, align 2, !dbg !659
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %29, i16 4, i16 %30), !dbg !660
  ret void, !dbg !639
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter(i16 %0, i16 %1) !dbg !661 {
  %3 = alloca i16, i16 1, align 2, !dbg !662
  %4 = alloca i16, i16 1, align 2, !dbg !664
  store i16 %0, i16* %4, align 2, !dbg !664
  store i16 %1, i16* %3, align 2, !dbg !662
  %5 = load i16, i16* %3, align 2, !dbg !665
  %6 = icmp ult i16 %5, -32768, !dbg !666
  br i1 %6, label %7, label %8, !dbg !667

7:                                                ; preds = %2
  br label %9, !dbg !667

8:                                                ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !667
  br label %9, !dbg !667

9:                                                ; preds = %7, %8
  %10 = load i16, i16* %4, align 2, !dbg !668
  %11 = load i16, i16* %3, align 2, !dbg !669
  %12 = mul i16 %11, 2, !dbg !670
  %13 = add i16 %12, 1, !dbg !671
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %10, i16 8, i16 %13), !dbg !672
  ret void, !dbg !673
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter(i16 %0, i16 %1) !dbg !674 {
  %3 = alloca i16, i16 1, align 2, !dbg !675
  %4 = alloca i16, i16 1, align 2, !dbg !677
  %5 = alloca i1, i16 1, align 1, !dbg !678
  %6 = alloca i16, i16 1, align 2, !dbg !679
  %7 = alloca i16, i16 1, align 2, !dbg !680
  %8 = alloca i16, i16 1, align 2, !dbg !681
  %9 = alloca i16, i16 1, align 2, !dbg !682
  store i16 %0, i16* %9, align 2, !dbg !682
  store i16 %1, i16* %8, align 2, !dbg !681
  %10 = load i16, i16* %8, align 2, !dbg !683
  %11 = icmp ult i16 %10, -32768, !dbg !684
  br i1 %11, label %12, label %13, !dbg !685

12:                                               ; preds = %2
  br label %14, !dbg !685

13:                                               ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !685
  br label %14, !dbg !685

14:                                               ; preds = %12, %13
  %15 = load i16, i16* %9, align 2, !dbg !686
  %16 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %15, i16 8), !dbg !687
  store i16 %16, i16* %7, align 2, !dbg !680
  %17 = load i16, i16* %8, align 2, !dbg !688
  %18 = mul i16 %17, 2, !dbg !689
  store i16 %18, i16* %6, align 2, !dbg !679
  %19 = load i16, i16* %6, align 2, !dbg !690
  %20 = load i16, i16* %7, align 2, !dbg !691
  %21 = icmp ugt i16 %19, %20, !dbg !692
  store i1 %21, i1* %5, align 1, !dbg !678
  %22 = load i16, i16* %9, align 2, !dbg !693
  %23 = load i1, i1* %5, align 1, !dbg !694
  %24 = zext i1 %23 to i16, !dbg !695
  %25 = shl i16 %24, 6, !dbg !696
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %22, i16 14, i16 %25), !dbg !697
  %26 = load i1, i1* %5, align 1, !dbg !698
  br i1 %26, label %27, label %32, !dbg !677

27:                                               ; preds = %14
  %28 = load i16, i16* %6, align 2, !dbg !699
  %29 = load i16, i16* %7, align 2, !dbg !700
  %30 = sub i16 %28, %29, !dbg !701
  %31 = add i16 %30, 1, !dbg !702
  store i16 %31, i16* %4, align 2, !dbg !677
  br label %34, !dbg !677

32:                                               ; preds = %14
  %33 = load i16, i16* %6, align 2, !dbg !703
  store i16 %33, i16* %4, align 2, !dbg !677
  br label %34, !dbg !677

34:                                               ; preds = %27, %32
  %35 = load i16, i16* %4, align 2, !dbg !677
  store i16 %35, i16* %3, align 2, !dbg !675
  %36 = load i16, i16* %9, align 2, !dbg !704
  %37 = load i16, i16* %3, align 2, !dbg !705
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %36, i16 12, i16 %37), !dbg !706
  ret void, !dbg !677
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %0, i16 %1, i16 %2) !dbg !707 {
  %4 = alloca i16, i16 1, align 2, !dbg !709
  %5 = alloca i16, i16 1, align 2, !dbg !711
  %6 = alloca i16, i16 1, align 2, !dbg !712
  store i16 %0, i16* %6, align 2, !dbg !712
  store i16 %1, i16* %5, align 2, !dbg !711
  store i16 %2, i16* %4, align 2, !dbg !709
  %7 = load i16, i16* %6, align 2, !dbg !713
  %8 = getelementptr [6 x i16], [6 x i16]* @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.filters, i16 0, i16 %7, !dbg !714
  %9 = load i16, i16* %8, align 2, !dbg !714
  %10 = load i16, i16* %5, align 2, !dbg !715
  %11 = add i16 %9, %10, !dbg !716
  %12 = lshr i16 %11, 1, !dbg !717
  %13 = load i16, i16* %4, align 2, !dbg !718
  %14 = shl i16 %12, 1, !dbg !719
  %15 = inttoptr i16 %14 to i16*, !dbg !719
  store volatile i16 %13, i16* %15, align 2, !dbg !719
  call void asm sideeffect "nop", ""(), !dbg !719
  call void asm sideeffect "nop", ""(), !dbg !719
  ret void, !dbg !720
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %0, i16 %1) !dbg !721 {
  %3 = alloca i16, i16 1, align 2, !dbg !722
  %4 = alloca i16, i16 1, align 2, !dbg !724
  store i16 %0, i16* %4, align 2, !dbg !724
  store i16 %1, i16* %3, align 2, !dbg !722
  %5 = load i16, i16* %4, align 2, !dbg !725
  %6 = getelementptr [6 x i16], [6 x i16]* @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.filters, i16 0, i16 %5, !dbg !726
  %7 = load i16, i16* %6, align 2, !dbg !726
  %8 = load i16, i16* %3, align 2, !dbg !727
  %9 = add i16 %7, %8, !dbg !728
  %10 = lshr i16 %9, 1, !dbg !729
  %11 = shl i16 %10, 1, !dbg !730
  %12 = inttoptr i16 %11 to i16*, !dbg !730
  call void asm sideeffect "nop", ""(), !dbg !730
  call void asm sideeffect "nop", ""(), !dbg !730
  %13 = load volatile i16, i16* %12, align 2, !dbg !730
  ret i16 %13, !dbg !731
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 %0) !dbg !732 {
  %2 = alloca i16, i16 1, align 2, !dbg !734
  %3 = alloca i16, i16 1, align 2, !dbg !736
  %4 = alloca i16, i16 1, align 2, !dbg !737
  %5 = alloca i16, i16 1, align 2, !dbg !738
  store i16 %0, i16* %5, align 2, !dbg !738
  %6 = load i16, i16* %5, align 2, !dbg !739
  store i16 %6, i16* %4, align 2, !dbg !737
  %7 = load i16, i16* %4, align 2, !dbg !740
  %8 = add i16 %7, 31744, !dbg !741
  store i16 %8, i16* %3, align 2, !dbg !736
  %9 = load i16, i16* %3, align 2, !dbg !742
  %10 = shl i16 %9, 1, !dbg !743
  %11 = inttoptr i16 %10 to i16*, !dbg !743
  call void asm sideeffect "nop", ""(), !dbg !743
  call void asm sideeffect "nop", ""(), !dbg !743
  %12 = load volatile i16, i16* %11, align 2, !dbg !743
  store i16 %12, i16* %2, align 2, !dbg !734
  %13 = load i16, i16* %3, align 2, !dbg !744
  %14 = load i16, i16* %2, align 2, !dbg !745
  %15 = and i16 %14, 32767, !dbg !746
  %16 = shl i16 %13, 1, !dbg !747
  %17 = inttoptr i16 %16 to i16*, !dbg !747
  store volatile i16 %15, i16* %17, align 2, !dbg !747
  call void asm sideeffect "nop", ""(), !dbg !747
  call void asm sideeffect "nop", ""(), !dbg !747
  ret void, !dbg !748
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord() !dbg !749 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 2), !dbg !751
  %2 = sub i16 %1, 4, !dbg !753
  ret i16 %2, !dbg !754
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord() !dbg !755 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 0), !dbg !756
  %2 = sub i16 %1, 1, !dbg !758
  ret i16 %2, !dbg !759
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 %0) !dbg !760 {
  %2 = alloca i16, i16 1, align 2, !dbg !762
  %3 = alloca i16, i16 1, align 2, !dbg !764
  store i16 %0, i16* %3, align 2, !dbg !764
  %4 = load i16, i16* %3, align 2, !dbg !765
  %5 = lshr i16 %4, 1, !dbg !766
  %6 = add i16 %5, 31813, !dbg !767
  %7 = shl i16 %6, 1, !dbg !768
  %8 = inttoptr i16 %7 to i16*, !dbg !768
  call void asm sideeffect "nop", ""(), !dbg !768
  call void asm sideeffect "nop", ""(), !dbg !768
  %9 = load volatile i16, i16* %8, align 2, !dbg !768
  store i16 %9, i16* %2, align 2, !dbg !762
  %10 = load i16, i16* %2, align 2, !dbg !769
  %11 = and i16 %10, 2047, !dbg !770
  ret i16 %11, !dbg !771
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord() !dbg !772 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord(), !dbg !774
  ret i16 %1, !dbg !776
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.get_y_coord() !dbg !777 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord(), !dbg !778
  ret i16 %1, !dbg !780
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval(i16 %0) !dbg !781 {
  %2 = alloca i16, i16 1, align 2, !dbg !782
  store i16 %0, i16* %2, align 2, !dbg !782
  %3 = load i16, i16* %2, align 2, !dbg !784
  %4 = icmp ult i16 %3, 24, !dbg !785
  br i1 %4, label %5, label %7, !dbg !786

5:                                                ; preds = %10, %11, %1
  %6 = phi i16 [ 0, %10 ], [ 0, %11 ], [ 1, %1 ]
  br label %12, !dbg !786

7:                                                ; preds = %1
  %8 = load i16, i16* %2, align 2, !dbg !787
  %9 = icmp eq i16 31, %8, !dbg !788
  br i1 %9, label %10, label %11, !dbg !789

10:                                               ; preds = %7
  br label %5, !dbg !789

11:                                               ; preds = %7
  call void asm sideeffect "hcf", ""(), !dbg !789
  br label %5, !dbg !789

12:                                               ; preds = %5
  %13 = phi i16 [ %6, %5 ]
  br label %14, !dbg !786

14:                                               ; preds = %12
  ret i16 %13, !dbg !786
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7) !dbg !790 {
  %9 = alloca i16, i16 1, align 2, !dbg !791
  %10 = alloca i16, i16 1, align 2, !dbg !793
  %11 = alloca i16, i16 1, align 2, !dbg !794
  %12 = alloca i16, i16 1, align 2, !dbg !795
  %13 = alloca i16, i16 1, align 2, !dbg !796
  %14 = alloca i16, i16 1, align 2, !dbg !797
  %15 = alloca i16, i16 1, align 2, !dbg !798
  %16 = alloca i16, i16 1, align 2, !dbg !799
  %17 = alloca i16, i16 1, align 2, !dbg !800
  store i16 %0, i16* %17, align 2, !dbg !800
  store i16 %1, i16* %16, align 2, !dbg !799
  store i16 %2, i16* %15, align 2, !dbg !798
  store i16 %3, i16* %14, align 2, !dbg !797
  store i16 %4, i16* %13, align 2, !dbg !796
  store i16 %5, i16* %12, align 2, !dbg !795
  store i16 %6, i16* %11, align 2, !dbg !794
  store i16 %7, i16* %10, align 2, !dbg !793
  %18 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !801
  store i16 %18, i16* %9, align 2, !dbg !791
  %19 = load i16, i16* %11, align 2, !dbg !802
  store i16 %19, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_c, align 2, !dbg !803
  %20 = load i16, i16* %10, align 2, !dbg !804
  store i16 %20, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_is_half, align 2, !dbg !805
  %21 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_c, align 2, !dbg !806
  %22 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval(i16 %21), !dbg !807
  store i16 %22, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !808
  store i16 0, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !809
  %23 = load i16, i16* %16, align 2, !dbg !810
  store i16 %23, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !811
  %24 = load i16, i16* %15, align 2, !dbg !812
  store i16 %24, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !813
  %25 = load i16, i16* %15, align 2, !dbg !814
  %26 = load i16, i16* %13, align 2, !dbg !815
  %27 = add i16 %25, %26, !dbg !816
  %28 = sub i16 %27, 1, !dbg !817
  store i16 %28, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_last, align 2, !dbg !818
  %29 = load i16, i16* %9, align 2, !dbg !819
  %30 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_last, align 2, !dbg !820
  %31 = icmp eq i16 %29, %30, !dbg !821
  br i1 %31, label %32, label %37, !dbg !822

32:                                               ; preds = %8
  %33 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !823
  %34 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !823
  %35 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !823
  store i16 %33, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !824
  store i16 lshr (i16 ptrtoint ([1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.ctrl_1 to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !824
  store i16 %34, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !824
  store i16 %35, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !824
  %36 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.ctrl_1, i16 0, i1 false), align 4, !dbg !825
  store i32 %36, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$9$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i1 false), align 4, !dbg !826
  br label %42, !dbg !822

37:                                               ; preds = %8
  %38 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !827
  %39 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !827
  %40 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !827
  store i16 %38, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !828
  store i16 lshr (i16 ptrtoint ([1 x i32]* @"$$csl_base_address$$5$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11" to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !828
  store i16 %39, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !828
  store i16 %40, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !828
  %41 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @"$$csl_base_address$$5$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11", i16 0, i1 false), align 4, !dbg !829
  store i32 %41, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$9$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i1 false), align 4, !dbg !830
  br label %42, !dbg !822

42:                                               ; preds = %32, %37
  store i32 165646921, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$9$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i2 1), align 4, !dbg !831
  %43 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !832
  %44 = icmp eq i16 0, %43, !dbg !833
  br i1 %44, label %45, label %56, !dbg !834

45:                                               ; preds = %42
  %46 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !835
  %47 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !835
  %48 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !835
  %49 = load i16, i16* %17, align 2, !dbg !836
  %50 = call i16* @.get_tensor_ptr(i16 %49), !dbg !837
  %51 = ptrtoint i16* %50 to i16, !dbg !838
  %52 = lshr i16 %51, 1, !dbg !838
  store i16 %46, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !839
  store i16 %52, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !839
  store i16 %47, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !839
  store i16 %48, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !839
  %53 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !840
  %54 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !840
  %55 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !840
  store i16 1, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !841
  store i16 %53, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !841
  store i16 %54, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !841
  store i16 %55, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !841
  call void @llvm.sdr.actvt.r(i16 21), !dbg !842
  br label %63, !dbg !834

56:                                               ; preds = %42
  %57 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !843
  %58 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !843
  %59 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !843
  store i16 %57, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !844
  store i16 lshr (i16 ptrtoint ([1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.data_buf to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !844
  store i16 %58, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !844
  store i16 %59, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !844
  %60 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !845
  %61 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !845
  %62 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !845
  store i16 1, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !846
  store i16 %60, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !846
  store i16 %61, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !846
  store i16 %62, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !846
  call void @llvm.sdr.ublk.r(i16 0), !dbg !847
  br label %63, !dbg !834

63:                                               ; preds = %45, %56
  ret void, !dbg !822
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x(i32 %0) #8 !dbg !848 {
  %2 = alloca i32, i16 1, align 4, !dbg !849
  store i32 %0, i32* %2, align 4, !dbg !849
  call void @llvm.sdr.blk.r(i16 0), !dbg !851
  %3 = load i32, i32* %2, align 4, !dbg !852
  store i32 %3, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.data_buf, i16 0, i1 false), align 4, !dbg !853
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !854
  %4 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !855
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !855
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !855
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !855
  store volatile i16 %4, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !856
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !856
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !856
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !856
  call void asm sideeffect "nop", ""(), !dbg !856
  call void asm sideeffect "nop", ""(), !dbg !856
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !857
  %8 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !858
  %9 = add i16 %8, 1, !dbg !859
  store i16 %9, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !860
  ret void, !dbg !861
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_send_data() #9 !dbg !862 {
  %1 = alloca i16, i16 1, align 2, !dbg !863
  %2 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !865
  %3 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !866
  %4 = icmp ult i16 %2, %3, !dbg !867
  br i1 %4, label %5, label %27, !dbg !868

5:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !869
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !870
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !870
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !870
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !870
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !871
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !871
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !871
  store volatile i16 %9, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !871
  call void asm sideeffect "nop", ""(), !dbg !871
  call void asm sideeffect "nop", ""(), !dbg !871
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_is_half, align 2, !dbg !872
  %11 = icmp ult i16 0, %10, !dbg !873
  br i1 %11, label %12, label %18, !dbg !874

12:                                               ; preds = %5
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !875
  %13 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !876
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !876
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !876
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !876
  %17 = add i16 %14, 1, !dbg !877
  store i16 %13, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !878
  store i16 %17, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !878
  store i16 %15, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !878
  store i16 %16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !878
  br label %24, !dbg !874

18:                                               ; preds = %5
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !879
  %19 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !880
  %20 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !880
  %21 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !880
  %22 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !880
  %23 = add i16 %20, 2, !dbg !881
  store i16 %19, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !882
  store i16 %23, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !882
  store i16 %21, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !882
  store i16 %22, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !882
  br label %24, !dbg !874

24:                                               ; preds = %12, %18
  %25 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !883
  %26 = add i16 %25, 1, !dbg !884
  store i16 %26, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !885
  br label %34, !dbg !868

27:                                               ; preds = %0
  %28 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !886
  store i16 %28, i16* %1, align 2, !dbg !863
  %29 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !887
  %30 = load i16, i16* %1, align 2, !dbg !888
  %31 = icmp eq i16 %29, %30, !dbg !889
  br i1 %31, label %32, label %33, !dbg !890

32:                                               ; preds = %27
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__1 to i8*)), !dbg !891
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__2 to i8*)), !dbg !892
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !893
  br label %33, !dbg !890

33:                                               ; preds = %32, %27
  br label %34, !dbg !868

34:                                               ; preds = %24, %33
  ret void, !dbg !868
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl() #10 !dbg !894 {
  %1 = alloca i16, i16 1, align 2, !dbg !895
  %2 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !897
  %3 = icmp eq i16 0, %2, !dbg !898
  br i1 %3, label %4, label %9, !dbg !899

4:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__3 to i8*)), !dbg !900
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !901
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !901
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !901
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !901
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !902
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !902
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !902
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !902
  call void asm sideeffect "nop", ""(), !dbg !902
  call void asm sideeffect "nop", ""(), !dbg !902
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !903
  br label %31, !dbg !899

9:                                                ; preds = %0
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !904
  %11 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !905
  %12 = icmp ult i16 %10, %11, !dbg !906
  br i1 %12, label %13, label %18, !dbg !907

13:                                               ; preds = %9
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__4 to i8*)), !dbg !908
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !909
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !909
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !909
  %17 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !909
  store volatile i16 %14, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !910
  store volatile i16 %15, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !910
  store volatile i16 %16, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !910
  store volatile i16 %17, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !910
  call void asm sideeffect "nop", ""(), !dbg !910
  call void asm sideeffect "nop", ""(), !dbg !910
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !911
  br label %30, !dbg !907

18:                                               ; preds = %9
  %19 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !912
  store i16 %19, i16* %1, align 2, !dbg !895
  %20 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !913
  %21 = load i16, i16* %1, align 2, !dbg !914
  %22 = icmp eq i16 %20, %21, !dbg !915
  br i1 %22, label %23, label %24, !dbg !916

23:                                               ; preds = %18
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__5 to i8*)), !dbg !917
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__6 to i8*)), !dbg !918
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !919
  br label %29, !dbg !916

24:                                               ; preds = %18
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__1 to i8*)), !dbg !920
  %25 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !921
  %26 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !921
  %27 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !921
  %28 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !921
  store volatile i16 %25, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !922
  store volatile i16 %26, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !922
  store volatile i16 %27, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !922
  store volatile i16 %28, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !922
  call void asm sideeffect "nop", ""(), !dbg !922
  call void asm sideeffect "nop", ""(), !dbg !922
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !923
  br label %29, !dbg !916

29:                                               ; preds = %23, %24
  br label %30, !dbg !907

30:                                               ; preds = %13, %29
  br label %31, !dbg !899

31:                                               ; preds = %4, %30
  ret void, !dbg !899
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.d2h_configure(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7) !dbg !924 {
  %9 = alloca i1, i16 1, align 1, !dbg !925
  %10 = alloca i1, i16 1, align 1, !dbg !927
  %11 = alloca i1, i16 1, align 1, !dbg !928
  %12 = alloca i16, i16 1, align 2, !dbg !929
  %13 = alloca i16, i16 1, align 2, !dbg !930
  %14 = alloca i16, i16 1, align 2, !dbg !931
  %15 = alloca i16, i16 1, align 2, !dbg !932
  %16 = alloca i16, i16 1, align 2, !dbg !933
  %17 = alloca i16, i16 1, align 2, !dbg !934
  %18 = alloca i16, i16 1, align 2, !dbg !935
  %19 = alloca i16, i16 1, align 2, !dbg !936
  %20 = alloca i16, i16 1, align 2, !dbg !937
  %21 = alloca i16, i16 1, align 2, !dbg !938
  %22 = alloca i16, i16 1, align 2, !dbg !939
  %23 = alloca i16, i16 1, align 2, !dbg !940
  %24 = alloca i16, i16 1, align 2, !dbg !941
  %25 = alloca i16, i16 1, align 2, !dbg !942
  store i16 %0, i16* %25, align 2, !dbg !942
  store i16 %1, i16* %24, align 2, !dbg !941
  store i16 %2, i16* %23, align 2, !dbg !940
  store i16 %3, i16* %22, align 2, !dbg !939
  store i16 %4, i16* %21, align 2, !dbg !938
  store i16 %5, i16* %20, align 2, !dbg !937
  store i16 %6, i16* %19, align 2, !dbg !936
  store i16 %7, i16* %18, align 2, !dbg !935
  %26 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !943
  store i16 %26, i16* %17, align 2, !dbg !934
  %27 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_y_coord(), !dbg !944
  store i16 %27, i16* %16, align 2, !dbg !933
  %28 = load i16, i16* %24, align 2, !dbg !945
  store i16 %28, i16* %15, align 2, !dbg !932
  %29 = load i16, i16* %24, align 2, !dbg !946
  %30 = load i16, i16* %22, align 2, !dbg !947
  %31 = add i16 %29, %30, !dbg !948
  %32 = sub i16 %31, 1, !dbg !949
  store i16 %32, i16* %14, align 2, !dbg !931
  %33 = load i16, i16* %23, align 2, !dbg !950
  store i16 %33, i16* %13, align 2, !dbg !930
  %34 = load i16, i16* %23, align 2, !dbg !951
  %35 = load i16, i16* %21, align 2, !dbg !952
  %36 = add i16 %34, %35, !dbg !953
  %37 = sub i16 %36, 1, !dbg !954
  store i16 %37, i16* %12, align 2, !dbg !929
  store i1 false, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !955
  %38 = load i16, i16* %17, align 2, !dbg !956
  %39 = load i16, i16* %15, align 2, !dbg !957
  %40 = icmp sge i16 %38, %39, !dbg !958
  br i1 %40, label %41, label %45, !dbg !928

41:                                               ; preds = %8
  %42 = load i16, i16* %16, align 2, !dbg !959
  %43 = load i16, i16* %12, align 2, !dbg !960
  %44 = icmp sle i16 %42, %43, !dbg !961
  store i1 %44, i1* %11, align 1, !dbg !928
  br label %46, !dbg !928

45:                                               ; preds = %8
  store i1 false, i1* %11, align 1, !dbg !928
  br label %46, !dbg !928

46:                                               ; preds = %41, %45
  %47 = load i1, i1* %11, align 1, !dbg !928
  br i1 %47, label %48, label %52, !dbg !927

48:                                               ; preds = %46
  %49 = load i16, i16* %16, align 2, !dbg !962
  %50 = load i16, i16* %13, align 2, !dbg !963
  %51 = icmp sge i16 %49, %50, !dbg !964
  store i1 %51, i1* %10, align 1, !dbg !927
  br label %53, !dbg !927

52:                                               ; preds = %46
  store i1 false, i1* %10, align 1, !dbg !927
  br label %53, !dbg !927

53:                                               ; preds = %48, %52
  %54 = load i1, i1* %10, align 1, !dbg !927
  br i1 %54, label %55, label %56, !dbg !965

55:                                               ; preds = %53
  store i1 true, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !966
  br label %56, !dbg !965

56:                                               ; preds = %55, %53
  store i1 false, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !967
  %57 = load i16, i16* %17, align 2, !dbg !968
  %58 = load i16, i16* %14, align 2, !dbg !969
  %59 = icmp sle i16 %57, %58, !dbg !970
  br i1 %59, label %60, label %62, !dbg !925

60:                                               ; preds = %56
  %61 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !971
  store i1 %61, i1* %9, align 1, !dbg !925
  br label %63, !dbg !925

62:                                               ; preds = %56
  store i1 false, i1* %9, align 1, !dbg !925
  br label %63, !dbg !925

63:                                               ; preds = %60, %62
  %64 = load i1, i1* %9, align 1, !dbg !925
  br i1 %64, label %65, label %66, !dbg !972

65:                                               ; preds = %63
  store i1 true, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !973
  br label %66, !dbg !972

66:                                               ; preds = %65, %63
  %67 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !974
  br i1 %67, label %68, label %86, !dbg !975

68:                                               ; preds = %66
  call void @__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position(i16 31959), !dbg !976
  %69 = load i16, i16* %15, align 2, !dbg !977
  %70 = load i16, i16* %17, align 2, !dbg !978
  %71 = icmp eq i16 %69, %70, !dbg !979
  br i1 %71, label %72, label %73, !dbg !980

72:                                               ; preds = %68
  call void @__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 31765), !dbg !981
  br label %74, !dbg !980

73:                                               ; preds = %68
  call void @__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 31765), !dbg !982
  br label %74, !dbg !980

74:                                               ; preds = %72, %73
  call void @sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit(i16 21), !dbg !983
  %75 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !984
  br i1 %75, label %76, label %85, !dbg !985

76:                                               ; preds = %74
  %77 = load i16, i16* %20, align 2, !dbg !986
  %78 = load i16, i16* %19, align 2, !dbg !987
  %79 = load i16, i16* %24, align 2, !dbg !988
  %80 = load i16, i16* %23, align 2, !dbg !989
  %81 = load i16, i16* %22, align 2, !dbg !990
  %82 = load i16, i16* %21, align 2, !dbg !991
  %83 = load i16, i16* %25, align 2, !dbg !992
  %84 = load i16, i16* %18, align 2, !dbg !993
  call void @sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start(i16 %77, i16 %78, i16 %79, i16 %80, i16 %81, i16 %82, i16 %83, i16 %84), !dbg !994
  br label %85, !dbg !985

85:                                               ; preds = %76, %74
  br label %87, !dbg !975

86:                                               ; preds = %66
  call void @llvm.sdr.actvt.r(i16 28), !dbg !995
  br label %87, !dbg !975

87:                                               ; preds = %85, %86
  ret void, !dbg !928
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit(i16 %0) !dbg !996 {
  %2 = alloca i16, i16 1, align 2, !dbg !997
  %3 = alloca i16, i16 1, align 2, !dbg !999
  %4 = alloca i16, i16 1, align 2, !dbg !1000
  %5 = alloca i16, i16 1, align 2, !dbg !1001
  store i16 %0, i16* %5, align 2, !dbg !1001
  %6 = load i16, i16* %5, align 2, !dbg !1002
  store i16 %6, i16* %4, align 2, !dbg !1000
  %7 = load i16, i16* %4, align 2, !dbg !1003
  %8 = add i16 %7, 31744, !dbg !1004
  store i16 %8, i16* %3, align 2, !dbg !999
  %9 = load i16, i16* %3, align 2, !dbg !1005
  %10 = shl i16 %9, 1, !dbg !1006
  %11 = inttoptr i16 %10 to i16*, !dbg !1006
  call void asm sideeffect "nop", ""(), !dbg !1006
  call void asm sideeffect "nop", ""(), !dbg !1006
  %12 = load volatile i16, i16* %11, align 2, !dbg !1006
  store i16 %12, i16* %2, align 2, !dbg !997
  %13 = load i16, i16* %3, align 2, !dbg !1007
  %14 = load i16, i16* %2, align 2, !dbg !1008
  %15 = and i16 %14, 32767, !dbg !1009
  %16 = shl i16 %13, 1, !dbg !1010
  %17 = inttoptr i16 %16 to i16*, !dbg !1010
  store volatile i16 %15, i16* %17, align 2, !dbg !1010
  call void asm sideeffect "nop", ""(), !dbg !1010
  call void asm sideeffect "nop", ""(), !dbg !1010
  ret void, !dbg !1011
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord() !dbg !1012 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 2), !dbg !1013
  %2 = sub i16 %1, 4, !dbg !1015
  ret i16 %2, !dbg !1016
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord() !dbg !1017 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 0), !dbg !1018
  %2 = sub i16 %1, 1, !dbg !1020
  ret i16 %2, !dbg !1021
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 %0) !dbg !1022 {
  %2 = alloca i16, i16 1, align 2, !dbg !1023
  %3 = alloca i16, i16 1, align 2, !dbg !1025
  store i16 %0, i16* %3, align 2, !dbg !1025
  %4 = load i16, i16* %3, align 2, !dbg !1026
  %5 = lshr i16 %4, 1, !dbg !1027
  %6 = add i16 %5, 31813, !dbg !1028
  %7 = shl i16 %6, 1, !dbg !1029
  %8 = inttoptr i16 %7 to i16*, !dbg !1029
  call void asm sideeffect "nop", ""(), !dbg !1029
  call void asm sideeffect "nop", ""(), !dbg !1029
  %9 = load volatile i16, i16* %8, align 2, !dbg !1029
  store i16 %9, i16* %2, align 2, !dbg !1023
  %10 = load i16, i16* %2, align 2, !dbg !1030
  %11 = and i16 %10, 2047, !dbg !1031
  ret i16 %11, !dbg !1032
}

define internal i16 @sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr(i16 %0) !dbg !1033 {
  %2 = alloca i16, i16 1, align 2, !dbg !1035
  store i16 %0, i16* %2, align 2, !dbg !1035
  %3 = load i16, i16* %2, align 2, !dbg !1037
  %4 = mul i16 %3, 2, !dbg !1038
  %5 = add i16 %4, 31680, !dbg !1039
  ret i16 %5, !dbg !1040
}

define internal void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 %0, i16 %1, i1 %2) !dbg !1041 {
  %4 = alloca i16, i16 1, align 2, !dbg !1042
  %5 = alloca i16, i16 1, align 2, !dbg !1044
  %6 = alloca i1, i16 1, align 1, !dbg !1045
  %7 = alloca i16, i16 1, align 2, !dbg !1046
  %8 = alloca i16, i16 1, align 2, !dbg !1047
  store i16 %0, i16* %8, align 2, !dbg !1047
  store i16 %1, i16* %7, align 2, !dbg !1046
  store i1 %2, i1* %6, align 1, !dbg !1045
  %9 = load i16, i16* %8, align 2, !dbg !1048
  %10 = call i16 @sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr(i16 %9), !dbg !1049
  store i16 %10, i16* %5, align 2, !dbg !1044
  %11 = load i16, i16* %5, align 2, !dbg !1050
  %12 = shl i16 %11, 1, !dbg !1051
  %13 = inttoptr i16 %12 to i16*, !dbg !1051
  call void asm sideeffect "nop", ""(), !dbg !1051
  call void asm sideeffect "nop", ""(), !dbg !1051
  call void asm sideeffect "nop", ""(), !dbg !1051
  call void asm sideeffect "nop", ""(), !dbg !1051
  %14 = load volatile i16, i16* %13, align 2, !dbg !1051
  store i16 %14, i16* %4, align 2, !dbg !1042
  %15 = load i1, i1* %6, align 1, !dbg !1052
  br i1 %15, label %16, label %19, !dbg !1053

16:                                               ; preds = %3
  %17 = load i16, i16* %4, align 2, !dbg !1054
  %18 = or i16 %17, 2048, !dbg !1055
  store i16 %18, i16* %4, align 2, !dbg !1056
  br label %22, !dbg !1053

19:                                               ; preds = %3
  %20 = load i16, i16* %4, align 2, !dbg !1057
  %21 = and i16 %20, -2049, !dbg !1058
  store i16 %21, i16* %4, align 2, !dbg !1059
  br label %22, !dbg !1053

22:                                               ; preds = %16, %19
  %23 = load i16, i16* %4, align 2, !dbg !1060
  %24 = and i16 %23, -32, !dbg !1061
  store i16 %24, i16* %4, align 2, !dbg !1062
  %25 = load i16, i16* %4, align 2, !dbg !1063
  %26 = load i16, i16* %7, align 2, !dbg !1064
  %27 = add i16 %25, %26, !dbg !1065
  store i16 %27, i16* %4, align 2, !dbg !1066
  %28 = load i16, i16* %5, align 2, !dbg !1067
  %29 = load i16, i16* %4, align 2, !dbg !1068
  %30 = shl i16 %28, 1, !dbg !1069
  %31 = inttoptr i16 %30 to i16*, !dbg !1069
  store volatile i16 %29, i16* %31, align 2, !dbg !1069
  call void asm sideeffect "nop", ""(), !dbg !1069
  call void asm sideeffect "nop", ""(), !dbg !1069
  call void asm sideeffect "nop", ""(), !dbg !1069
  call void asm sideeffect "nop", ""(), !dbg !1069
  ret void, !dbg !1053
}

define internal i16 @sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr(i16 %0) !dbg !1070 {
  %2 = alloca i16, i16 1, align 2, !dbg !1072
  store i16 %0, i16* %2, align 2, !dbg !1072
  %3 = load i16, i16* %2, align 2, !dbg !1074
  %4 = add i16 %3, 31616, !dbg !1075
  ret i16 %4, !dbg !1076
}

define internal void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 %0, i16 %1) !dbg !1077 {
  %3 = alloca i16, i16 1, align 2, !dbg !1078
  %4 = alloca i16, i16 1, align 2, !dbg !1080
  %5 = alloca i16, i16 1, align 2, !dbg !1081
  %6 = alloca i16, i16 1, align 2, !dbg !1082
  store i16 %0, i16* %6, align 2, !dbg !1082
  store i16 %1, i16* %5, align 2, !dbg !1081
  %7 = load i16, i16* %6, align 2, !dbg !1083
  %8 = call i16 @sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr(i16 %7), !dbg !1084
  store i16 %8, i16* %4, align 2, !dbg !1080
  %9 = load i16, i16* %4, align 2, !dbg !1085
  %10 = shl i16 %9, 1, !dbg !1086
  %11 = inttoptr i16 %10 to i16*, !dbg !1086
  call void asm sideeffect "nop", ""(), !dbg !1086
  call void asm sideeffect "nop", ""(), !dbg !1086
  call void asm sideeffect "nop", ""(), !dbg !1086
  call void asm sideeffect "nop", ""(), !dbg !1086
  %12 = load volatile i16, i16* %11, align 2, !dbg !1086
  store i16 %12, i16* %3, align 2, !dbg !1078
  %13 = load i16, i16* %3, align 2, !dbg !1087
  %14 = and i16 %13, -497, !dbg !1088
  store i16 %14, i16* %3, align 2, !dbg !1089
  %15 = load i16, i16* %3, align 2, !dbg !1090
  %16 = load i16, i16* %5, align 2, !dbg !1091
  %17 = add i16 %15, %16, !dbg !1092
  %18 = shl i16 %17, 4, !dbg !1093
  store i16 %18, i16* %3, align 2, !dbg !1094
  %19 = load i16, i16* %4, align 2, !dbg !1095
  %20 = load i16, i16* %3, align 2, !dbg !1096
  %21 = shl i16 %19, 1, !dbg !1097
  %22 = inttoptr i16 %21 to i16*, !dbg !1097
  store volatile i16 %20, i16* %22, align 2, !dbg !1097
  call void asm sideeffect "nop", ""(), !dbg !1097
  call void asm sideeffect "nop", ""(), !dbg !1097
  call void asm sideeffect "nop", ""(), !dbg !1097
  call void asm sideeffect "nop", ""(), !dbg !1097
  ret void, !dbg !1098
}

define internal i16* @.get_tensor_ptr(i16 %0) !dbg !1099 {
  %2 = alloca i16, i16 1, align 2, !dbg !1100
  store i16 %0, i16* %2, align 2, !dbg !1100
  %3 = load i16, i16* %2, align 2, !dbg !1100
  %4 = zext i16 %3 to i32, !dbg !1100
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
    i32 18, label %52
  ], !dbg !1100

5:                                                ; preds = %1
  br i1 false, label %6, label %7, !dbg !1100

6:                                                ; preds = %5
  br label %8, !dbg !1100

7:                                                ; preds = %5
  call void asm sideeffect "hcf", ""(), !dbg !1100
  br label %8, !dbg !1100

8:                                                ; preds = %6, %7
  br label %54, !dbg !1100

9:                                                ; preds = %1
  %10 = load i16*, i16** @p_row_ptr, align 8, !dbg !1100
  br label %54, !dbg !1100

11:                                               ; preds = %1
  %12 = load i16*, i16** @p_col_idx, align 8, !dbg !1100
  br label %54, !dbg !1100

13:                                               ; preds = %1
  %14 = load i16*, i16** @p_col_start, align 8, !dbg !1100
  br label %54, !dbg !1100

15:                                               ; preds = %1
  %16 = load i16*, i16** @p_run_len, align 8, !dbg !1100
  br label %54, !dbg !1100

17:                                               ; preds = %1
  %18 = load float*, float** @p_val, align 8, !dbg !1100
  %19 = bitcast float* %18 to i16*, !dbg !1100
  br label %54, !dbg !1100

20:                                               ; preds = %1
  %21 = load float*, float** @p_x, align 8, !dbg !1100
  %22 = bitcast float* %21 to i16*, !dbg !1100
  br label %54, !dbg !1100

23:                                               ; preds = %1
  %24 = load float*, float** @p_dia_val, align 8, !dbg !1100
  %25 = bitcast float* %24 to i16*, !dbg !1100
  br label %54, !dbg !1100

26:                                               ; preds = %1
  %27 = load i16*, i16** @p_dia_off, align 8, !dbg !1100
  br label %54, !dbg !1100

28:                                               ; preds = %1
  %29 = load i16*, i16** @p_dia_len, align 8, !dbg !1100
  br label %54, !dbg !1100

30:                                               ; preds = %1
  %31 = load i16*, i16** @p_dia_row0, align 8, !dbg !1100
  br label %54, !dbg !1100

32:                                               ; preds = %1
  %33 = load i16*, i16** @p_dia_xoff, align 8, !dbg !1100
  br label %54, !dbg !1100

34:                                               ; preds = %1
  %35 = load float*, float** @p_probe_seed, align 8, !dbg !1100
  %36 = bitcast float* %35 to i16*, !dbg !1100
  br label %54, !dbg !1100

37:                                               ; preds = %1
  %38 = load float*, float** @p_probe_out, align 8, !dbg !1100
  %39 = bitcast float* %38 to i16*, !dbg !1100
  br label %54, !dbg !1100

40:                                               ; preds = %1
  %41 = load float*, float** @p_y_sc, align 8, !dbg !1100
  %42 = bitcast float* %41 to i16*, !dbg !1100
  br label %54, !dbg !1100

43:                                               ; preds = %1
  %44 = load float*, float** @p_y_ir, align 8, !dbg !1100
  %45 = bitcast float* %44 to i16*, !dbg !1100
  br label %54, !dbg !1100

46:                                               ; preds = %1
  %47 = load float*, float** @p_y_bk, align 8, !dbg !1100
  %48 = bitcast float* %47 to i16*, !dbg !1100
  br label %54, !dbg !1100

49:                                               ; preds = %1
  %50 = load float*, float** @p_y_di, align 8, !dbg !1100
  %51 = bitcast float* %50 to i16*, !dbg !1100
  br label %54, !dbg !1100

52:                                               ; preds = %1
  %53 = load i16*, i16** @p_mark, align 8, !dbg !1100
  br label %54, !dbg !1100

54:                                               ; preds = %8, %9, %11, %13, %15, %17, %20, %23, %26, %28, %30, %32, %34, %37, %40, %43, %46, %49, %52
  %55 = phi i16 [ -2, %52 ], [ -2, %49 ], [ -2, %46 ], [ -2, %43 ], [ -2, %40 ], [ -2, %37 ], [ -2, %34 ], [ -2, %32 ], [ -2, %30 ], [ -2, %28 ], [ -2, %26 ], [ -2, %23 ], [ -2, %20 ], [ -2, %17 ], [ -2, %15 ], [ -2, %13 ], [ -2, %11 ], [ -2, %9 ], [ 0, %8 ]
  %56 = phi i16* [ %53, %52 ], [ %51, %49 ], [ %48, %46 ], [ %45, %43 ], [ %42, %40 ], [ %39, %37 ], [ %36, %34 ], [ %33, %32 ], [ %31, %30 ], [ %29, %28 ], [ %27, %26 ], [ %25, %23 ], [ %22, %20 ], [ %19, %17 ], [ %16, %15 ], [ %14, %13 ], [ %12, %11 ], [ %10, %9 ], [ undef, %8 ]
  br label %57, !dbg !1100

57:                                               ; preds = %54
  %58 = icmp ne i16 %55, 0, !dbg !1100
  br i1 %58, label %59, label %60, !dbg !1100

59:                                               ; preds = %57
  br label %62, !dbg !1100

60:                                               ; preds = %57
  %61 = load i16*, i16** @p_mark, align 8, !dbg !1100
  br label %62, !dbg !1100

62:                                               ; preds = %59, %60
  %63 = phi i16* [ %61, %60 ], [ %56, %59 ]
  br label %64, !dbg !1100

64:                                               ; preds = %62
  ret i16* %63, !dbg !1100
}

define internal void @__generic0sys_mod.sys_mod.tile_config.queue_flush.exit() !dbg !1102 {
  store volatile i16 1, i16* inttoptr (i16 -2268 to i16*), align 2, !dbg !1104
  call void asm sideeffect "nop", ""(), !dbg !1104
  call void asm sideeffect "nop", ""(), !dbg !1104
  ret void, !dbg !1106
}

define internal void @__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position(i16 %0) !dbg !1107 {
  %2 = alloca i16, i16 1, align 2, !dbg !1109
  %3 = alloca i16, i16 1, align 2, !dbg !1111
  %4 = alloca i16, i16 1, align 2, !dbg !1112
  store i16 %0, i16* %4, align 2, !dbg !1112
  %5 = load i16, i16* %4, align 2, !dbg !1113
  store i16 %5, i16* %3, align 2, !dbg !1111
  %6 = load i16, i16* %3, align 2, !dbg !1114
  %7 = shl i16 %6, 1, !dbg !1115
  %8 = inttoptr i16 %7 to i16*, !dbg !1115
  call void asm sideeffect "nop", ""(), !dbg !1115
  call void asm sideeffect "nop", ""(), !dbg !1115
  call void asm sideeffect "nop", ""(), !dbg !1115
  call void asm sideeffect "nop", ""(), !dbg !1115
  %9 = load volatile i16, i16* %8, align 2, !dbg !1115
  store i16 %9, i16* %2, align 2, !dbg !1109
  %10 = load i16, i16* %2, align 2, !dbg !1116
  %11 = and i16 %10, -16, !dbg !1117
  store i16 %11, i16* %2, align 2, !dbg !1117
  %12 = load i16, i16* %3, align 2, !dbg !1118
  %13 = load i16, i16* %2, align 2, !dbg !1119
  %14 = shl i16 %12, 1, !dbg !1120
  %15 = inttoptr i16 %14 to i16*, !dbg !1120
  store volatile i16 %13, i16* %15, align 2, !dbg !1120
  call void asm sideeffect "nop", ""(), !dbg !1120
  call void asm sideeffect "nop", ""(), !dbg !1120
  call void asm sideeffect "nop", ""(), !dbg !1120
  call void asm sideeffect "nop", ""(), !dbg !1120
  ret void, !dbg !1121
}

define internal void @__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 %0) !dbg !1122 {
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
  %14 = call i16 @__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %13), !dbg !1136
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

define internal void @__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 %0) !dbg !1146 {
  %2 = alloca i16, i16 1, align 2, !dbg !1147
  %3 = alloca i16, i16 1, align 2, !dbg !1149
  %4 = alloca i16, i16 1, align 2, !dbg !1150
  store i16 %0, i16* %4, align 2, !dbg !1150
  %5 = load i16, i16* %4, align 2, !dbg !1151
  store i16 %5, i16* %3, align 2, !dbg !1149
  %6 = load i16, i16* %3, align 2, !dbg !1152
  %7 = shl i16 %6, 1, !dbg !1153
  %8 = inttoptr i16 %7 to i16*, !dbg !1153
  call void asm sideeffect "nop", ""(), !dbg !1153
  call void asm sideeffect "nop", ""(), !dbg !1153
  %9 = load volatile i16, i16* %8, align 2, !dbg !1153
  store i16 %9, i16* %2, align 2, !dbg !1147
  %10 = load i16, i16* %2, align 2, !dbg !1154
  %11 = and i16 %10, -256, !dbg !1155
  store i16 %11, i16* %2, align 2, !dbg !1156
  %12 = load i16, i16* %2, align 2, !dbg !1157
  %13 = load i16, i16* %2, align 2, !dbg !1158
  %14 = call i16 @__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %13), !dbg !1159
  %15 = or i16 %12, %14, !dbg !1160
  store i16 %15, i16* %2, align 2, !dbg !1160
  %16 = load i16, i16* %2, align 2, !dbg !1161
  %17 = load i16, i16* %2, align 2, !dbg !1162
  %18 = call i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %17), !dbg !1163
  %19 = or i16 %16, %18, !dbg !1164
  store i16 %19, i16* %2, align 2, !dbg !1164
  %20 = load i16, i16* %3, align 2, !dbg !1165
  %21 = load i16, i16* %2, align 2, !dbg !1166
  %22 = shl i16 %20, 1, !dbg !1167
  %23 = inttoptr i16 %22 to i16*, !dbg !1167
  store volatile i16 %21, i16* %23, align 2, !dbg !1167
  call void asm sideeffect "nop", ""(), !dbg !1167
  call void asm sideeffect "nop", ""(), !dbg !1167
  ret void, !dbg !1168
}

define internal i16 @__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %0) !dbg !1169 {
  %2 = alloca i16, i16 1, align 2, !dbg !1170
  %3 = alloca i16, i16 1, align 2, !dbg !1172
  store i16 %0, i16* %3, align 2, !dbg !1172
  %4 = load i16, i16* %3, align 2, !dbg !1173
  store i16 %4, i16* %2, align 2, !dbg !1170
  %5 = load i16, i16* %2, align 2, !dbg !1174
  store i16 %5, i16* %2, align 2, !dbg !1175
  %6 = load i16, i16* %2, align 2, !dbg !1176
  ret i16 %6, !dbg !1177
}

define internal i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %0) !dbg !1178 {
  %2 = alloca i16, i16 1, align 2, !dbg !1179
  %3 = alloca i16, i16 1, align 2, !dbg !1181
  store i16 %0, i16* %3, align 2, !dbg !1181
  %4 = load i16, i16* %3, align 2, !dbg !1182
  store i16 %4, i16* %2, align 2, !dbg !1179
  %5 = load i16, i16* %2, align 2, !dbg !1183
  %6 = or i16 %5, 2, !dbg !1184
  store i16 %6, i16* %2, align 2, !dbg !1184
  %7 = load i16, i16* %2, align 2, !dbg !1185
  ret i16 %7, !dbg !1186
}

define internal i16 @__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %0) !dbg !1187 {
  %2 = alloca i16, i16 1, align 2, !dbg !1188
  %3 = alloca i16, i16 1, align 2, !dbg !1190
  store i16 %0, i16* %3, align 2, !dbg !1190
  %4 = load i16, i16* %3, align 2, !dbg !1191
  store i16 %4, i16* %2, align 2, !dbg !1188
  %5 = load i16, i16* %2, align 2, !dbg !1192
  %6 = or i16 %5, 128, !dbg !1193
  store i16 %6, i16* %2, align 2, !dbg !1193
  %7 = load i16, i16* %2, align 2, !dbg !1194
  ret i16 %7, !dbg !1195
}

define internal void @__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction(i16 %0) !dbg !1196 {
  %2 = alloca i16, i16 1, align 2, !dbg !1197
  %3 = alloca i16, i16 1, align 2, !dbg !1199
  %4 = alloca i16, i16 1, align 2, !dbg !1200
  store i16 %0, i16* %4, align 2, !dbg !1200
  %5 = load i16, i16* %4, align 2, !dbg !1201
  store i16 %5, i16* %3, align 2, !dbg !1199
  %6 = load i16, i16* %3, align 2, !dbg !1202
  %7 = shl i16 %6, 1, !dbg !1203
  %8 = inttoptr i16 %7 to i16*, !dbg !1203
  call void asm sideeffect "nop", ""(), !dbg !1203
  call void asm sideeffect "nop", ""(), !dbg !1203
  %9 = load volatile i16, i16* %8, align 2, !dbg !1203
  store i16 %9, i16* %2, align 2, !dbg !1197
  %10 = load i16, i16* %2, align 2, !dbg !1204
  %11 = and i16 %10, -17, !dbg !1205
  store i16 %11, i16* %2, align 2, !dbg !1205
  %12 = load i16, i16* %3, align 2, !dbg !1206
  %13 = load i16, i16* %2, align 2, !dbg !1207
  %14 = shl i16 %12, 1, !dbg !1208
  %15 = inttoptr i16 %14 to i16*, !dbg !1208
  store volatile i16 %13, i16* %15, align 2, !dbg !1208
  call void asm sideeffect "nop", ""(), !dbg !1208
  call void asm sideeffect "nop", ""(), !dbg !1208
  ret void, !dbg !1209
}

define internal void @__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction(i16 %0) !dbg !1210 {
  %2 = alloca i16, i16 1, align 2, !dbg !1211
  %3 = alloca i16, i16 1, align 2, !dbg !1213
  %4 = alloca i16, i16 1, align 2, !dbg !1214
  store i16 %0, i16* %4, align 2, !dbg !1214
  %5 = load i16, i16* %4, align 2, !dbg !1215
  store i16 %5, i16* %3, align 2, !dbg !1213
  %6 = load i16, i16* %3, align 2, !dbg !1216
  %7 = shl i16 %6, 1, !dbg !1217
  %8 = inttoptr i16 %7 to i16*, !dbg !1217
  call void asm sideeffect "nop", ""(), !dbg !1217
  call void asm sideeffect "nop", ""(), !dbg !1217
  %9 = load volatile i16, i16* %8, align 2, !dbg !1217
  store i16 %9, i16* %2, align 2, !dbg !1211
  %10 = load i16, i16* %2, align 2, !dbg !1218
  %11 = or i16 %10, 16, !dbg !1219
  store i16 %11, i16* %2, align 2, !dbg !1219
  %12 = load i16, i16* %3, align 2, !dbg !1220
  %13 = load i16, i16* %2, align 2, !dbg !1221
  %14 = shl i16 %12, 1, !dbg !1222
  %15 = inttoptr i16 %14 to i16*, !dbg !1222
  store volatile i16 %13, i16* %15, align 2, !dbg !1222
  call void asm sideeffect "nop", ""(), !dbg !1222
  call void asm sideeffect "nop", ""(), !dbg !1222
  ret void, !dbg !1223
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
!108 = distinct !DISubprogram(name: "spmv_dia", linkageName: "spmv_dia", scope: null, file: !4, line: 100, type: !5, scopeLine: 100, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!109 = !DILocation(line: 111, column: 5, scope: !110)
!110 = !DILexicalBlockFile(scope: !108, file: !4, discriminator: 0)
!111 = !DILocation(line: 110, column: 5, scope: !110)
!112 = !DILocation(line: 108, column: 5, scope: !110)
!113 = !DILocation(line: 106, column: 5, scope: !110)
!114 = !DILocation(line: 105, column: 5, scope: !110)
!115 = !DILocation(line: 103, column: 3, scope: !110)
!116 = !DILocation(line: 101, column: 11, scope: !110)
!117 = !DILocation(line: 102, column: 3, scope: !110)
!118 = !DILocation(line: 104, column: 3, scope: !110)
!119 = !DILocation(line: 104, column: 10, scope: !110)
!120 = !DILocation(line: 104, column: 12, scope: !110)
!121 = !DILocation(line: 105, column: 28, scope: !110)
!122 = !DILocation(line: 105, column: 27, scope: !110)
!123 = !DILocation(line: 106, column: 38, scope: !110)
!124 = !DILocation(line: 107, column: 32, scope: !110)
!125 = !DILocation(line: 107, column: 53, scope: !110)
!126 = !DILocation(line: 107, column: 52, scope: !110)
!127 = !DILocation(line: 107, column: 10, scope: !110)
!128 = !DILocation(line: 107, column: 8, scope: !110)
!129 = !DILocation(line: 108, column: 37, scope: !110)
!130 = !DILocation(line: 109, column: 32, scope: !110)
!131 = !DILocation(line: 109, column: 54, scope: !110)
!132 = !DILocation(line: 109, column: 53, scope: !110)
!133 = !DILocation(line: 109, column: 10, scope: !110)
!134 = !DILocation(line: 109, column: 8, scope: !110)
!135 = !DILocation(line: 110, column: 39, scope: !110)
!136 = !DILocation(line: 111, column: 39, scope: !110)
!137 = !DILocation(line: 112, column: 32, scope: !110)
!138 = !DILocation(line: 112, column: 54, scope: !110)
!139 = !DILocation(line: 112, column: 53, scope: !110)
!140 = !DILocation(line: 112, column: 10, scope: !110)
!141 = !DILocation(line: 112, column: 8, scope: !110)
!142 = !DILocation(line: 113, column: 12, scope: !110)
!143 = !DILocation(line: 113, column: 16, scope: !110)
!144 = !DILocation(line: 113, column: 20, scope: !110)
!145 = !DILocation(line: 113, column: 5, scope: !110)
!146 = !DILocation(line: 114, column: 12, scope: !110)
!147 = !DILocation(line: 114, column: 16, scope: !110)
!148 = !DILocation(line: 114, column: 20, scope: !110)
!149 = !DILocation(line: 114, column: 5, scope: !110)
!150 = !DILocation(line: 104, column: 23, scope: !110)
!151 = !DILocation(line: 104, column: 25, scope: !110)
!152 = !DILocation(line: 116, column: 11, scope: !110)
!153 = !DILocation(line: 117, column: 3, scope: !110)
!154 = distinct !DISubprogram(name: "probe_reduce", linkageName: "probe_reduce", scope: null, file: !4, line: 123, type: !5, scopeLine: 123, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!155 = !DILocation(line: 126, column: 3, scope: !156)
!156 = !DILexicalBlockFile(scope: !154, file: !4, discriminator: 0)
!157 = !DILocation(line: 124, column: 11, scope: !156)
!158 = !DILocation(line: 125, column: 21, scope: !156)
!159 = !DILocation(line: 125, column: 9, scope: !156)
!160 = !DILocation(line: 127, column: 18, scope: !156)
!161 = !DILocation(line: 127, column: 25, scope: !156)
!162 = !DILocation(line: 127, column: 3, scope: !156)
!163 = !DILocation(line: 128, column: 18, scope: !156)
!164 = !DILocation(line: 128, column: 16, scope: !156)
!165 = !DILocation(line: 129, column: 11, scope: !156)
!166 = !DILocation(line: 130, column: 3, scope: !156)
!167 = !DILocation(line: 123, column: 1, scope: !156)
!168 = distinct !DISubprogram(name: "f_exit", linkageName: "f_exit", scope: null, file: !4, line: 133, type: !5, scopeLine: 133, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!169 = !DILocation(line: 133, column: 22, scope: !170)
!170 = !DILexicalBlockFile(scope: !168, file: !4, discriminator: 0)
!171 = !DILocation(line: 133, column: 1, scope: !170)
!172 = distinct !DISubprogram(name: "sys_mod.sys_nop", linkageName: "sys_mod.sys_nop", scope: null, file: !173, line: 90, type: !5, scopeLine: 90, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!173 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/memcpy.csl", directory: "")
!174 = !DILocation(line: 90, column: 1, scope: !175)
!175 = !DILexicalBlockFile(scope: !172, file: !173, discriminator: 0)
!176 = distinct !DISubprogram(name: "sys_mod.unblock_cmd_stream", linkageName: "sys_mod.unblock_cmd_stream", scope: null, file: !173, line: 102, type: !5, scopeLine: 102, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!177 = !DILocation(line: 103, column: 3, scope: !178)
!178 = !DILexicalBlockFile(scope: !176, file: !173, discriminator: 0)
!179 = !DILocation(line: 102, column: 1, scope: !178)
!180 = distinct !DISubprogram(name: "sys_mod.sys_mod.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.unblock_cmd_stream", scope: null, file: !181, line: 307, type: !5, scopeLine: 307, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!181 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpy.csl", directory: "")
!182 = !DILocation(line: 308, column: 5, scope: !183)
!183 = !DILexicalBlockFile(scope: !180, file: !181, discriminator: 0)
!184 = !DILocation(line: 307, column: 1, scope: !183)
!185 = distinct !DISubprogram(name: "sys_mod.sys_mod.teardown_h2d", linkageName: "sys_mod.sys_mod.teardown_h2d", scope: null, file: !181, line: 323, type: !5, scopeLine: 323, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!186 = !DILocation(line: 326, column: 5, scope: !187)
!187 = !DILexicalBlockFile(scope: !185, file: !181, discriminator: 0)
!188 = !DILocation(line: 323, column: 1, scope: !187)
!189 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_ublk_c22", linkageName: "sys_mod.sys_mod.f_ublk_c22", scope: null, file: !181, line: 335, type: !5, scopeLine: 335, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!190 = !DILocation(line: 336, column: 5, scope: !191)
!191 = !DILexicalBlockFile(scope: !189, file: !181, discriminator: 0)
!192 = !DILocation(line: 335, column: 1, scope: !191)
!193 = distinct !DISubprogram(name: "sys_mod.sys_mod.teardown_d2h", linkageName: "sys_mod.sys_mod.teardown_d2h", scope: null, file: !181, line: 344, type: !5, scopeLine: 344, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!194 = !DILocation(line: 355, column: 5, scope: !195)
!195 = !DILexicalBlockFile(scope: !193, file: !181, discriminator: 0)
!196 = !DILocation(line: 359, column: 5, scope: !195)
!197 = !DILocation(line: 344, column: 1, scope: !195)
!198 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_memcpyh2d", linkageName: "sys_mod.sys_mod.f_memcpyh2d", scope: null, file: !181, line: 460, type: !5, scopeLine: 460, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!199 = !DILocation(line: 477, column: 5, scope: !200)
!200 = !DILexicalBlockFile(scope: !198, file: !181, discriminator: 0)
!201 = !DILocation(line: 476, column: 5, scope: !200)
!202 = !DILocation(line: 475, column: 5, scope: !200)
!203 = !DILocation(line: 474, column: 5, scope: !200)
!204 = !DILocation(line: 473, column: 5, scope: !200)
!205 = !DILocation(line: 472, column: 5, scope: !200)
!206 = !DILocation(line: 471, column: 5, scope: !200)
!207 = !DILocation(line: 470, column: 5, scope: !200)
!208 = !DILocation(line: 469, column: 5, scope: !200)
!209 = !DILocation(line: 468, column: 5, scope: !200)
!210 = !DILocation(line: 467, column: 5, scope: !200)
!211 = !DILocation(line: 466, column: 5, scope: !200)
!212 = !DILocation(line: 465, column: 5, scope: !200)
!213 = !DILocation(line: 463, column: 5, scope: !200)
!214 = !DILocation(line: 462, column: 20, scope: !200)
!215 = !DILocation(line: 462, column: 32, scope: !200)
!216 = !DILocation(line: 462, column: 5, scope: !200)
!217 = !DILocation(line: 465, column: 33, scope: !200)
!218 = !DILocation(line: 465, column: 38, scope: !200)
!219 = !DILocation(line: 466, column: 34, scope: !200)
!220 = !DILocation(line: 466, column: 39, scope: !200)
!221 = !DILocation(line: 467, column: 34, scope: !200)
!222 = !DILocation(line: 467, column: 39, scope: !200)
!223 = !DILocation(line: 468, column: 33, scope: !200)
!224 = !DILocation(line: 468, column: 38, scope: !200)
!225 = !DILocation(line: 469, column: 33, scope: !200)
!226 = !DILocation(line: 469, column: 38, scope: !200)
!227 = !DILocation(line: 470, column: 35, scope: !200)
!228 = !DILocation(line: 470, column: 21, scope: !200)
!229 = !DILocation(line: 471, column: 41, scope: !200)
!230 = !DILocation(line: 471, column: 27, scope: !200)
!231 = !DILocation(line: 472, column: 39, scope: !200)
!232 = !DILocation(line: 472, column: 25, scope: !200)
!233 = !DILocation(line: 473, column: 44, scope: !200)
!234 = !DILocation(line: 473, column: 49, scope: !200)
!235 = !DILocation(line: 474, column: 41, scope: !200)
!236 = !DILocation(line: 474, column: 46, scope: !200)
!237 = !DILocation(line: 475, column: 41, scope: !200)
!238 = !DILocation(line: 475, column: 46, scope: !200)
!239 = !DILocation(line: 476, column: 59, scope: !200)
!240 = !DILocation(line: 476, column: 64, scope: !200)
!241 = !DILocation(line: 476, column: 50, scope: !200)
!242 = !DILocation(line: 476, column: 129, scope: !200)
!243 = !DILocation(line: 476, column: 134, scope: !200)
!244 = !DILocation(line: 476, column: 120, scope: !200)
!245 = !DILocation(line: 476, column: 118, scope: !200)
!246 = !DILocation(line: 476, column: 112, scope: !200)
!247 = !DILocation(line: 476, column: 36, scope: !200)
!248 = !DILocation(line: 477, column: 59, scope: !200)
!249 = !DILocation(line: 477, column: 64, scope: !200)
!250 = !DILocation(line: 477, column: 50, scope: !200)
!251 = !DILocation(line: 477, column: 129, scope: !200)
!252 = !DILocation(line: 477, column: 134, scope: !200)
!253 = !DILocation(line: 477, column: 120, scope: !200)
!254 = !DILocation(line: 477, column: 118, scope: !200)
!255 = !DILocation(line: 477, column: 112, scope: !200)
!256 = !DILocation(line: 477, column: 36, scope: !200)
!257 = !DILocation(line: 479, column: 24, scope: !200)
!258 = !DILocation(line: 481, column: 21, scope: !200)
!259 = !DILocation(line: 481, column: 19, scope: !200)
!260 = !DILocation(line: 482, column: 21, scope: !200)
!261 = !DILocation(line: 482, column: 19, scope: !200)
!262 = !DILocation(line: 483, column: 21, scope: !200)
!263 = !DILocation(line: 483, column: 19, scope: !200)
!264 = !DILocation(line: 484, column: 20, scope: !200)
!265 = !DILocation(line: 484, column: 18, scope: !200)
!266 = !DILocation(line: 485, column: 20, scope: !200)
!267 = !DILocation(line: 485, column: 18, scope: !200)
!268 = !DILocation(line: 486, column: 22, scope: !200)
!269 = !DILocation(line: 486, column: 20, scope: !200)
!270 = !DILocation(line: 487, column: 27, scope: !200)
!271 = !DILocation(line: 487, column: 25, scope: !200)
!272 = !DILocation(line: 488, column: 25, scope: !200)
!273 = !DILocation(line: 488, column: 23, scope: !200)
!274 = !DILocation(line: 489, column: 31, scope: !200)
!275 = !DILocation(line: 489, column: 29, scope: !200)
!276 = !DILocation(line: 490, column: 28, scope: !200)
!277 = !DILocation(line: 490, column: 26, scope: !200)
!278 = !DILocation(line: 491, column: 28, scope: !200)
!279 = !DILocation(line: 491, column: 26, scope: !200)
!280 = !DILocation(line: 492, column: 37, scope: !200)
!281 = !DILocation(line: 492, column: 35, scope: !200)
!282 = !DILocation(line: 493, column: 37, scope: !200)
!283 = !DILocation(line: 493, column: 35, scope: !200)
!284 = !DILocation(line: 495, column: 5, scope: !200)
!285 = !DILocation(line: 501, column: 5, scope: !200)
!286 = !DILocation(line: 506, column: 5, scope: !200)
!287 = !DILocation(line: 521, column: 5, scope: !200)
!288 = !DILocation(line: 522, column: 16, scope: !200)
!289 = !DILocation(line: 531, column: 5, scope: !200)
!290 = !DILocation(line: 460, column: 1, scope: !200)
!291 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_memcpyd2h", linkageName: "sys_mod.sys_mod.f_memcpyd2h", scope: null, file: !181, line: 556, type: !5, scopeLine: 556, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!292 = !DILocation(line: 568, column: 5, scope: !293)
!293 = !DILexicalBlockFile(scope: !291, file: !181, discriminator: 0)
!294 = !DILocation(line: 567, column: 5, scope: !293)
!295 = !DILocation(line: 566, column: 5, scope: !293)
!296 = !DILocation(line: 565, column: 5, scope: !293)
!297 = !DILocation(line: 564, column: 5, scope: !293)
!298 = !DILocation(line: 563, column: 5, scope: !293)
!299 = !DILocation(line: 562, column: 5, scope: !293)
!300 = !DILocation(line: 561, column: 5, scope: !293)
!301 = !DILocation(line: 559, column: 5, scope: !293)
!302 = !DILocation(line: 558, column: 20, scope: !293)
!303 = !DILocation(line: 558, column: 32, scope: !293)
!304 = !DILocation(line: 558, column: 5, scope: !293)
!305 = !DILocation(line: 561, column: 33, scope: !293)
!306 = !DILocation(line: 561, column: 38, scope: !293)
!307 = !DILocation(line: 562, column: 34, scope: !293)
!308 = !DILocation(line: 562, column: 39, scope: !293)
!309 = !DILocation(line: 563, column: 34, scope: !293)
!310 = !DILocation(line: 563, column: 39, scope: !293)
!311 = !DILocation(line: 564, column: 33, scope: !293)
!312 = !DILocation(line: 564, column: 38, scope: !293)
!313 = !DILocation(line: 565, column: 33, scope: !293)
!314 = !DILocation(line: 565, column: 38, scope: !293)
!315 = !DILocation(line: 566, column: 35, scope: !293)
!316 = !DILocation(line: 566, column: 21, scope: !293)
!317 = !DILocation(line: 567, column: 41, scope: !293)
!318 = !DILocation(line: 567, column: 27, scope: !293)
!319 = !DILocation(line: 568, column: 39, scope: !293)
!320 = !DILocation(line: 568, column: 25, scope: !293)
!321 = !DILocation(line: 570, column: 24, scope: !293)
!322 = !DILocation(line: 573, column: 21, scope: !293)
!323 = !DILocation(line: 573, column: 19, scope: !293)
!324 = !DILocation(line: 574, column: 21, scope: !293)
!325 = !DILocation(line: 574, column: 19, scope: !293)
!326 = !DILocation(line: 575, column: 21, scope: !293)
!327 = !DILocation(line: 575, column: 19, scope: !293)
!328 = !DILocation(line: 576, column: 20, scope: !293)
!329 = !DILocation(line: 576, column: 18, scope: !293)
!330 = !DILocation(line: 577, column: 20, scope: !293)
!331 = !DILocation(line: 577, column: 18, scope: !293)
!332 = !DILocation(line: 578, column: 22, scope: !293)
!333 = !DILocation(line: 578, column: 20, scope: !293)
!334 = !DILocation(line: 579, column: 27, scope: !293)
!335 = !DILocation(line: 579, column: 25, scope: !293)
!336 = !DILocation(line: 580, column: 25, scope: !293)
!337 = !DILocation(line: 580, column: 23, scope: !293)
!338 = !DILocation(line: 582, column: 5, scope: !293)
!339 = !DILocation(line: 588, column: 59, scope: !293)
!340 = !DILocation(line: 588, column: 5, scope: !293)
!341 = !DILocation(line: 608, column: 5, scope: !293)
!342 = !DILocation(line: 609, column: 16, scope: !293)
!343 = !DILocation(line: 556, column: 1, scope: !293)
!344 = distinct !DISubprogram(name: "sys_mod.sys_mod.oq0_teardow_handler", linkageName: "sys_mod.sys_mod.oq0_teardow_handler", scope: null, file: !181, line: 631, type: !5, scopeLine: 631, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!345 = !DILocation(line: 632, column: 9, scope: !346)
!346 = !DILexicalBlockFile(scope: !344, file: !181, discriminator: 0)
!347 = !DILocation(line: 632, column: 5, scope: !346)
!348 = !DILocation(line: 634, column: 66, scope: !346)
!349 = !DILocation(line: 634, column: 9, scope: !346)
!350 = !DILocation(line: 636, column: 13, scope: !346)
!351 = !DILocation(line: 637, column: 13, scope: !346)
!352 = !DILocation(line: 638, column: 13, scope: !346)
!353 = !DILocation(line: 639, column: 13, scope: !346)
!354 = !DILocation(line: 640, column: 13, scope: !346)
!355 = !DILocation(line: 641, column: 13, scope: !346)
!356 = !DILocation(line: 642, column: 13, scope: !346)
!357 = !DILocation(line: 643, column: 13, scope: !346)
!358 = !DILocation(line: 644, column: 13, scope: !346)
!359 = !DILocation(line: 645, column: 13, scope: !346)
!360 = !DILocation(line: 646, column: 13, scope: !346)
!361 = !DILocation(line: 647, column: 13, scope: !346)
!362 = !DILocation(line: 648, column: 13, scope: !346)
!363 = !DILocation(line: 635, column: 9, scope: !346)
!364 = !DILocation(line: 652, column: 9, scope: !346)
!365 = !DILocation(line: 654, column: 13, scope: !346)
!366 = !DILocation(line: 655, column: 13, scope: !346)
!367 = !DILocation(line: 656, column: 13, scope: !346)
!368 = !DILocation(line: 657, column: 13, scope: !346)
!369 = !DILocation(line: 658, column: 13, scope: !346)
!370 = !DILocation(line: 659, column: 13, scope: !346)
!371 = !DILocation(line: 660, column: 13, scope: !346)
!372 = !DILocation(line: 661, column: 13, scope: !346)
!373 = !DILocation(line: 653, column: 9, scope: !346)
!374 = !DILocation(line: 664, column: 5, scope: !346)
!375 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_rpc", linkageName: "sys_mod.sys_mod.f_rpc", scope: null, file: !181, line: 694, type: !5, scopeLine: 694, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!376 = !DILocation(line: 694, column: 13, scope: !377)
!377 = !DILexicalBlockFile(scope: !375, file: !181, discriminator: 0)
!378 = !DILocation(line: 700, column: 5, scope: !377)
!379 = !DILocation(line: 706, column: 20, scope: !377)
!380 = !DILocation(line: 706, column: 32, scope: !377)
!381 = !DILocation(line: 706, column: 5, scope: !377)
!382 = !DILocation(line: 710, column: 5, scope: !377)
!383 = !DILocation(line: 712, column: 24, scope: !377)
!384 = !DILocation(line: 694, column: 1, scope: !377)
!385 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.stack_push", linkageName: "sys_mod.sys_mod.sys_mod.stack_push", scope: null, file: !386, line: 54, type: !5, scopeLine: 54, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!386 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/sys.csl", directory: "")
!387 = !DILocation(line: 60, column: 5, scope: !388)
!388 = !DILexicalBlockFile(scope: !385, file: !386, discriminator: 0)
!389 = !DILocation(line: 54, column: 16, scope: !388)
!390 = !DILocation(line: 59, column: 13, scope: !388)
!391 = !DILocation(line: 59, column: 24, scope: !388)
!392 = !DILocation(line: 59, column: 5, scope: !388)
!393 = !DILocation(line: 61, column: 25, scope: !388)
!394 = !DILocation(line: 61, column: 5, scope: !388)
!395 = !DILocation(line: 61, column: 11, scope: !388)
!396 = !DILocation(line: 61, column: 10, scope: !388)
!397 = !DILocation(line: 61, column: 23, scope: !388)
!398 = !DILocation(line: 62, column: 18, scope: !388)
!399 = !DILocation(line: 62, column: 29, scope: !388)
!400 = !DILocation(line: 62, column: 16, scope: !388)
!401 = !DILocation(line: 54, column: 1, scope: !388)
!402 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_push", linkageName: "sys_mod.sys_mod.sys_mod.f_push", scope: null, file: !386, line: 72, type: !5, scopeLine: 72, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!403 = !DILocation(line: 72, column: 25, scope: !404)
!404 = !DILexicalBlockFile(scope: !402, file: !386, discriminator: 0)
!405 = !DILocation(line: 72, column: 13, scope: !404)
!406 = !DILocation(line: 73, column: 16, scope: !404)
!407 = !DILocation(line: 73, column: 5, scope: !404)
!408 = !DILocation(line: 72, column: 1, scope: !404)
!409 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.block_cmd_stream", linkageName: "sys_mod.sys_mod.sys_mod.block_cmd_stream", scope: null, file: !386, line: 76, type: !5, scopeLine: 76, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!410 = !DILocation(line: 77, column: 5, scope: !411)
!411 = !DILexicalBlockFile(scope: !409, file: !386, discriminator: 0)
!412 = !DILocation(line: 76, column: 1, scope: !411)
!413 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.sys_mod.unblock_cmd_stream", scope: null, file: !386, line: 80, type: !5, scopeLine: 80, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!414 = !DILocation(line: 81, column: 5, scope: !415)
!415 = !DILexicalBlockFile(scope: !413, file: !386, discriminator: 0)
!416 = !DILocation(line: 80, column: 1, scope: !415)
!417 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_sys_exit", linkageName: "sys_mod.sys_mod.sys_mod.f_sys_exit", scope: null, file: !386, line: 85, type: !5, scopeLine: 85, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!418 = !DILocation(line: 86, column: 5, scope: !419)
!419 = !DILexicalBlockFile(scope: !417, file: !386, discriminator: 0)
!420 = !DILocation(line: 87, column: 5, scope: !419)
!421 = !DILocation(line: 85, column: 1, scope: !419)
!422 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore", linkageName: "sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore", scope: null, file: !386, line: 90, type: !5, scopeLine: 90, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!423 = !DILocation(line: 90, column: 30, scope: !424)
!424 = !DILexicalBlockFile(scope: !422, file: !386, discriminator: 0)
!425 = !DILocation(line: 90, column: 1, scope: !424)
!426 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord", scope: null, file: !427, line: 131, type: !5, scopeLine: 131, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!427 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpyh2d.csl", directory: "")
!428 = !DILocation(line: 132, column: 12, scope: !429)
!429 = !DILexicalBlockFile(scope: !426, file: !427, discriminator: 0)
!430 = !DILocation(line: 132, column: 5, scope: !429)
!431 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord", scope: null, file: !427, line: 134, type: !5, scopeLine: 134, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!432 = !DILocation(line: 135, column: 12, scope: !433)
!433 = !DILexicalBlockFile(scope: !431, file: !427, discriminator: 0)
!434 = !DILocation(line: 135, column: 5, scope: !433)
!435 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval", scope: null, file: !427, line: 148, type: !5, scopeLine: 148, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!436 = !DILocation(line: 148, column: 23, scope: !437)
!437 = !DILexicalBlockFile(scope: !435, file: !427, discriminator: 0)
!438 = !DILocation(line: 149, column: 9, scope: !437)
!439 = !DILocation(line: 149, column: 20, scope: !437)
!440 = !DILocation(line: 149, column: 5, scope: !437)
!441 = !DILocation(line: 152, column: 23, scope: !437)
!442 = !DILocation(line: 152, column: 20, scope: !437)
!443 = !DILocation(line: 152, column: 9, scope: !437)
!444 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start", scope: null, file: !427, line: 226, type: !5, scopeLine: 226, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!445 = !DILocation(line: 233, column: 5, scope: !446)
!446 = !DILexicalBlockFile(scope: !444, file: !427, discriminator: 0)
!447 = !DILocation(line: 226, column: 49, scope: !446)
!448 = !DILocation(line: 226, column: 32, scope: !446)
!449 = !DILocation(line: 226, column: 21, scope: !446)
!450 = !DILocation(line: 229, column: 37, scope: !446)
!451 = !DILocation(line: 229, column: 52, scope: !446)
!452 = !DILocation(line: 229, column: 19, scope: !446)
!453 = !DILocation(line: 233, column: 71, scope: !446)
!454 = !DILocation(line: 233, column: 55, scope: !446)
!455 = !DILocation(line: 233, column: 25, scope: !446)
!456 = !DILocation(line: 235, column: 37, scope: !446)
!457 = !DILocation(line: 235, column: 52, scope: !446)
!458 = !DILocation(line: 235, column: 19, scope: !446)
!459 = !DILocation(line: 236, column: 28, scope: !446)
!460 = !DILocation(line: 236, column: 5, scope: !446)
!461 = !DILocation(line: 237, column: 28, scope: !446)
!462 = !DILocation(line: 237, column: 5, scope: !446)
!463 = !DILocation(line: 238, column: 13, scope: !446)
!464 = !DILocation(line: 238, column: 11, scope: !446)
!465 = !DILocation(line: 238, column: 5, scope: !446)
!466 = !DILocation(line: 239, column: 9, scope: !446)
!467 = !DILocation(line: 241, column: 9, scope: !446)
!468 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream", scope: null, file: !427, line: 249, type: !5, scopeLine: 249, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!469 = !DILocation(line: 250, column: 5, scope: !470)
!470 = !DILexicalBlockFile(scope: !468, file: !427, discriminator: 0)
!471 = !DILocation(line: 249, column: 1, scope: !470)
!472 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure", scope: null, file: !427, line: 276, type: !5, scopeLine: 276, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!473 = !DILocation(line: 414, column: 13, scope: !474)
!474 = !DILexicalBlockFile(scope: !472, file: !427, discriminator: 0)
!475 = !DILocation(line: 413, column: 13, scope: !474)
!476 = !DILocation(line: 400, column: 17, scope: !474)
!477 = !DILocation(line: 340, column: 9, scope: !474)
!478 = !DILocation(line: 339, column: 9, scope: !474)
!479 = !DILocation(line: 337, column: 5, scope: !474)
!480 = !DILocation(line: 319, column: 9, scope: !474)
!481 = !DILocation(line: 318, column: 9, scope: !474)
!482 = !DILocation(line: 315, column: 5, scope: !474)
!483 = !DILocation(line: 292, column: 5, scope: !474)
!484 = !DILocation(line: 291, column: 5, scope: !474)
!485 = !DILocation(line: 289, column: 5, scope: !474)
!486 = !DILocation(line: 288, column: 5, scope: !474)
!487 = !DILocation(line: 287, column: 5, scope: !474)
!488 = !DILocation(line: 286, column: 5, scope: !474)
!489 = !DILocation(line: 285, column: 5, scope: !474)
!490 = !DILocation(line: 284, column: 5, scope: !474)
!491 = !DILocation(line: 283, column: 5, scope: !474)
!492 = !DILocation(line: 282, column: 5, scope: !474)
!493 = !DILocation(line: 281, column: 5, scope: !474)
!494 = !DILocation(line: 280, column: 5, scope: !474)
!495 = !DILocation(line: 279, column: 5, scope: !474)
!496 = !DILocation(line: 278, column: 5, scope: !474)
!497 = !DILocation(line: 277, column: 5, scope: !474)
!498 = !DILocation(line: 291, column: 26, scope: !474)
!499 = !DILocation(line: 292, column: 26, scope: !474)
!500 = !DILocation(line: 315, column: 25, scope: !474)
!501 = !DILocation(line: 315, column: 31, scope: !474)
!502 = !DILocation(line: 315, column: 29, scope: !474)
!503 = !DILocation(line: 316, column: 20, scope: !474)
!504 = !DILocation(line: 316, column: 18, scope: !474)
!505 = !DILocation(line: 317, column: 52, scope: !474)
!506 = !DILocation(line: 317, column: 49, scope: !474)
!507 = !DILocation(line: 317, column: 5, scope: !474)
!508 = !DILocation(line: 318, column: 42, scope: !474)
!509 = !DILocation(line: 318, column: 33, scope: !474)
!510 = !DILocation(line: 318, column: 49, scope: !474)
!511 = !DILocation(line: 318, column: 48, scope: !474)
!512 = !DILocation(line: 318, column: 24, scope: !474)
!513 = !DILocation(line: 319, column: 24, scope: !474)
!514 = !DILocation(line: 319, column: 32, scope: !474)
!515 = !DILocation(line: 319, column: 36, scope: !474)
!516 = !DILocation(line: 319, column: 34, scope: !474)
!517 = !DILocation(line: 319, column: 30, scope: !474)
!518 = !DILocation(line: 320, column: 18, scope: !474)
!519 = !DILocation(line: 320, column: 15, scope: !474)
!520 = !DILocation(line: 320, column: 9, scope: !474)
!521 = !DILocation(line: 321, column: 26, scope: !474)
!522 = !DILocation(line: 325, column: 28, scope: !474)
!523 = !DILocation(line: 325, column: 26, scope: !474)
!524 = !DILocation(line: 331, column: 9, scope: !474)
!525 = !DILocation(line: 331, column: 15, scope: !474)
!526 = !DILocation(line: 331, column: 5, scope: !474)
!527 = !DILocation(line: 332, column: 22, scope: !474)
!528 = !DILocation(line: 334, column: 9, scope: !474)
!529 = !DILocation(line: 334, column: 18, scope: !474)
!530 = !DILocation(line: 334, column: 15, scope: !474)
!531 = !DILocation(line: 334, column: 5, scope: !474)
!532 = !DILocation(line: 335, column: 22, scope: !474)
!533 = !DILocation(line: 338, column: 52, scope: !474)
!534 = !DILocation(line: 338, column: 49, scope: !474)
!535 = !DILocation(line: 338, column: 5, scope: !474)
!536 = !DILocation(line: 339, column: 42, scope: !474)
!537 = !DILocation(line: 339, column: 48, scope: !474)
!538 = !DILocation(line: 339, column: 46, scope: !474)
!539 = !DILocation(line: 339, column: 33, scope: !474)
!540 = !DILocation(line: 339, column: 52, scope: !474)
!541 = !DILocation(line: 339, column: 51, scope: !474)
!542 = !DILocation(line: 339, column: 24, scope: !474)
!543 = !DILocation(line: 340, column: 25, scope: !474)
!544 = !DILocation(line: 340, column: 31, scope: !474)
!545 = !DILocation(line: 340, column: 29, scope: !474)
!546 = !DILocation(line: 340, column: 37, scope: !474)
!547 = !DILocation(line: 340, column: 41, scope: !474)
!548 = !DILocation(line: 340, column: 39, scope: !474)
!549 = !DILocation(line: 340, column: 35, scope: !474)
!550 = !DILocation(line: 341, column: 18, scope: !474)
!551 = !DILocation(line: 341, column: 15, scope: !474)
!552 = !DILocation(line: 341, column: 9, scope: !474)
!553 = !DILocation(line: 342, column: 26, scope: !474)
!554 = !DILocation(line: 347, column: 10, scope: !474)
!555 = !DILocation(line: 347, column: 16, scope: !474)
!556 = !DILocation(line: 347, column: 14, scope: !474)
!557 = !DILocation(line: 347, column: 5, scope: !474)
!558 = !DILocation(line: 348, column: 22, scope: !474)
!559 = !DILocation(line: 350, column: 10, scope: !474)
!560 = !DILocation(line: 350, column: 18, scope: !474)
!561 = !DILocation(line: 350, column: 21, scope: !474)
!562 = !DILocation(line: 350, column: 20, scope: !474)
!563 = !DILocation(line: 350, column: 14, scope: !474)
!564 = !DILocation(line: 350, column: 5, scope: !474)
!565 = !DILocation(line: 351, column: 22, scope: !474)
!566 = !DILocation(line: 354, column: 9, scope: !474)
!567 = !DILocation(line: 354, column: 5, scope: !474)
!568 = !DILocation(line: 358, column: 9, scope: !474)
!569 = !DILocation(line: 361, column: 9, scope: !474)
!570 = !DILocation(line: 364, column: 20, scope: !474)
!571 = !DILocation(line: 364, column: 17, scope: !474)
!572 = !DILocation(line: 364, column: 9, scope: !474)
!573 = !DILocation(line: 368, column: 13, scope: !474)
!574 = !DILocation(line: 371, column: 13, scope: !474)
!575 = !DILocation(line: 375, column: 13, scope: !474)
!576 = !DILocation(line: 394, column: 13, scope: !474)
!577 = !DILocation(line: 396, column: 29, scope: !474)
!578 = !DILocation(line: 396, column: 27, scope: !474)
!579 = !DILocation(line: 397, column: 60, scope: !474)
!580 = !DILocation(line: 397, column: 57, scope: !474)
!581 = !DILocation(line: 397, column: 13, scope: !474)
!582 = !DILocation(line: 400, column: 54, scope: !474)
!583 = !DILocation(line: 400, column: 55, scope: !474)
!584 = !DILocation(line: 400, column: 46, scope: !474)
!585 = !DILocation(line: 400, column: 59, scope: !474)
!586 = !DILocation(line: 400, column: 58, scope: !474)
!587 = !DILocation(line: 400, column: 37, scope: !474)
!588 = !DILocation(line: 400, column: 35, scope: !474)
!589 = !DILocation(line: 401, column: 33, scope: !474)
!590 = !DILocation(line: 401, column: 31, scope: !474)
!591 = !DILocation(line: 402, column: 69, scope: !474)
!592 = !DILocation(line: 402, column: 66, scope: !474)
!593 = !DILocation(line: 402, column: 19, scope: !474)
!594 = !DILocation(line: 404, column: 31, scope: !474)
!595 = !DILocation(line: 408, column: 75, scope: !474)
!596 = !DILocation(line: 408, column: 88, scope: !474)
!597 = !DILocation(line: 408, column: 13, scope: !474)
!598 = !DILocation(line: 413, column: 31, scope: !474)
!599 = !DILocation(line: 414, column: 33, scope: !474)
!600 = !DILocation(line: 415, column: 21, scope: !474)
!601 = !DILocation(line: 415, column: 29, scope: !474)
!602 = !DILocation(line: 415, column: 27, scope: !474)
!603 = !DILocation(line: 415, column: 19, scope: !474)
!604 = !DILocation(line: 416, column: 22, scope: !474)
!605 = !DILocation(line: 416, column: 19, scope: !474)
!606 = !DILocation(line: 416, column: 13, scope: !474)
!607 = !DILocation(line: 417, column: 23, scope: !474)
!608 = !DILocation(line: 419, column: 63, scope: !474)
!609 = !DILocation(line: 419, column: 60, scope: !474)
!610 = !DILocation(line: 419, column: 13, scope: !474)
!611 = !DILocation(line: 421, column: 23, scope: !474)
!612 = !DILocation(line: 423, column: 69, scope: !474)
!613 = !DILocation(line: 423, column: 13, scope: !474)
!614 = !DILocation(line: 426, column: 13, scope: !474)
!615 = !DILocation(line: 430, column: 13, scope: !474)
!616 = !DILocation(line: 433, column: 48, scope: !474)
!617 = !DILocation(line: 433, column: 22, scope: !474)
!618 = !DILocation(line: 433, column: 19, scope: !474)
!619 = !DILocation(line: 433, column: 13, scope: !474)
!620 = !DILocation(line: 436, column: 34, scope: !474)
!621 = !DILocation(line: 436, column: 39, scope: !474)
!622 = !DILocation(line: 436, column: 50, scope: !474)
!623 = !DILocation(line: 436, column: 17, scope: !474)
!624 = !DILocation(line: 452, column: 49, scope: !474)
!625 = !DILocation(line: 452, column: 64, scope: !474)
!626 = !DILocation(line: 452, column: 31, scope: !474)
!627 = !DILocation(line: 453, column: 40, scope: !474)
!628 = !DILocation(line: 453, column: 17, scope: !474)
!629 = !DILocation(line: 454, column: 50, scope: !474)
!630 = !DILocation(line: 454, column: 66, scope: !474)
!631 = !DILocation(line: 454, column: 32, scope: !474)
!632 = !DILocation(line: 455, column: 40, scope: !474)
!633 = !DILocation(line: 455, column: 17, scope: !474)
!634 = !DILocation(line: 456, column: 17, scope: !474)
!635 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit", scope: null, file: !636, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!636 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/filters/wse3.csl", directory: "")
!637 = !DILocation(line: 24, column: 3, scope: !638)
!638 = !DILexicalBlockFile(scope: !635, file: !636, discriminator: 0)
!639 = !DILocation(line: 24, column: 22, scope: !638)
!640 = !DILocation(line: 23, column: 3, scope: !638)
!641 = !DILocation(line: 22, column: 3, scope: !638)
!642 = !DILocation(line: 20, column: 37, scope: !638)
!643 = !DILocation(line: 20, column: 21, scope: !638)
!644 = !DILocation(line: 21, column: 11, scope: !638)
!645 = !DILocation(line: 21, column: 17, scope: !638)
!646 = !DILocation(line: 21, column: 3, scope: !638)
!647 = !DILocation(line: 22, column: 24, scope: !638)
!648 = !DILocation(line: 22, column: 30, scope: !638)
!649 = !DILocation(line: 23, column: 40, scope: !638)
!650 = !DILocation(line: 23, column: 22, scope: !638)
!651 = !DILocation(line: 23, column: 67, scope: !638)
!652 = !DILocation(line: 24, column: 26, scope: !638)
!653 = !DILocation(line: 24, column: 41, scope: !638)
!654 = !DILocation(line: 24, column: 39, scope: !638)
!655 = !DILocation(line: 24, column: 61, scope: !638)
!656 = !DILocation(line: 24, column: 76, scope: !638)
!657 = !DILocation(line: 24, column: 74, scope: !638)
!658 = !DILocation(line: 25, column: 21, scope: !638)
!659 = !DILocation(line: 25, column: 50, scope: !638)
!660 = !DILocation(line: 25, column: 3, scope: !638)
!661 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter", scope: null, file: !636, line: 30, type: !5, scopeLine: 30, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!662 = !DILocation(line: 30, column: 36, scope: !663)
!663 = !DILexicalBlockFile(scope: !661, file: !636, discriminator: 0)
!664 = !DILocation(line: 30, column: 20, scope: !663)
!665 = !DILocation(line: 31, column: 11, scope: !663)
!666 = !DILocation(line: 31, column: 23, scope: !663)
!667 = !DILocation(line: 31, column: 3, scope: !663)
!668 = !DILocation(line: 32, column: 21, scope: !663)
!669 = !DILocation(line: 32, column: 48, scope: !663)
!670 = !DILocation(line: 32, column: 60, scope: !663)
!671 = !DILocation(line: 32, column: 64, scope: !663)
!672 = !DILocation(line: 32, column: 3, scope: !663)
!673 = !DILocation(line: 30, column: 1, scope: !663)
!674 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter", scope: null, file: !636, line: 40, type: !5, scopeLine: 40, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!675 = !DILocation(line: 47, column: 3, scope: !676)
!676 = !DILexicalBlockFile(scope: !674, file: !636, discriminator: 0)
!677 = !DILocation(line: 48, column: 7, scope: !676)
!678 = !DILocation(line: 44, column: 3, scope: !676)
!679 = !DILocation(line: 43, column: 3, scope: !676)
!680 = !DILocation(line: 42, column: 3, scope: !676)
!681 = !DILocation(line: 40, column: 32, scope: !676)
!682 = !DILocation(line: 40, column: 16, scope: !676)
!683 = !DILocation(line: 41, column: 11, scope: !676)
!684 = !DILocation(line: 41, column: 19, scope: !676)
!685 = !DILocation(line: 41, column: 3, scope: !676)
!686 = !DILocation(line: 42, column: 40, scope: !676)
!687 = !DILocation(line: 42, column: 22, scope: !676)
!688 = !DILocation(line: 43, column: 26, scope: !676)
!689 = !DILocation(line: 43, column: 34, scope: !676)
!690 = !DILocation(line: 44, column: 25, scope: !676)
!691 = !DILocation(line: 44, column: 42, scope: !676)
!692 = !DILocation(line: 44, column: 40, scope: !676)
!693 = !DILocation(line: 45, column: 21, scope: !676)
!694 = !DILocation(line: 46, column: 35, scope: !676)
!695 = !DILocation(line: 46, column: 21, scope: !676)
!696 = !DILocation(line: 46, column: 50, scope: !676)
!697 = !DILocation(line: 45, column: 3, scope: !676)
!698 = !DILocation(line: 48, column: 11, scope: !676)
!699 = !DILocation(line: 48, column: 26, scope: !676)
!700 = !DILocation(line: 48, column: 43, scope: !676)
!701 = !DILocation(line: 48, column: 41, scope: !676)
!702 = !DILocation(line: 48, column: 54, scope: !676)
!703 = !DILocation(line: 48, column: 63, scope: !676)
!704 = !DILocation(line: 49, column: 21, scope: !676)
!705 = !DILocation(line: 49, column: 47, scope: !676)
!706 = !DILocation(line: 49, column: 3, scope: !676)
!707 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config", scope: null, file: !708, line: 33, type: !5, scopeLine: 33, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!708 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/filters/common.csl", directory: "")
!709 = !DILocation(line: 33, column: 46, scope: !710)
!710 = !DILexicalBlockFile(scope: !707, file: !708, discriminator: 0)
!711 = !DILocation(line: 33, column: 31, scope: !710)
!712 = !DILocation(line: 33, column: 15, scope: !710)
!713 = !DILocation(line: 34, column: 24, scope: !710)
!714 = !DILocation(line: 34, column: 23, scope: !710)
!715 = !DILocation(line: 34, column: 51, scope: !710)
!716 = !DILocation(line: 34, column: 35, scope: !710)
!717 = !DILocation(line: 34, column: 60, scope: !710)
!718 = !DILocation(line: 34, column: 73, scope: !710)
!719 = !DILocation(line: 34, column: 3, scope: !710)
!720 = !DILocation(line: 33, column: 1, scope: !710)
!721 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config", scope: null, file: !708, line: 38, type: !5, scopeLine: 38, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!722 = !DILocation(line: 38, column: 31, scope: !723)
!723 = !DILexicalBlockFile(scope: !721, file: !708, discriminator: 0)
!724 = !DILocation(line: 38, column: 15, scope: !723)
!725 = !DILocation(line: 39, column: 31, scope: !723)
!726 = !DILocation(line: 39, column: 30, scope: !723)
!727 = !DILocation(line: 39, column: 58, scope: !723)
!728 = !DILocation(line: 39, column: 42, scope: !723)
!729 = !DILocation(line: 39, column: 67, scope: !723)
!730 = !DILocation(line: 39, column: 10, scope: !723)
!731 = !DILocation(line: 39, column: 3, scope: !723)
!732 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit", scope: null, file: !733, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!733 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/teardown.csl", directory: "")
!734 = !DILocation(line: 43, column: 3, scope: !735)
!735 = !DILexicalBlockFile(scope: !732, file: !733, discriminator: 0)
!736 = !DILocation(line: 41, column: 3, scope: !735)
!737 = !DILocation(line: 40, column: 3, scope: !735)
!738 = !DILocation(line: 39, column: 9, scope: !735)
!739 = !DILocation(line: 40, column: 23, scope: !735)
!740 = !DILocation(line: 41, column: 70, scope: !735)
!741 = !DILocation(line: 41, column: 68, scope: !735)
!742 = !DILocation(line: 43, column: 27, scope: !735)
!743 = !DILocation(line: 43, column: 15, scope: !735)
!744 = !DILocation(line: 44, column: 15, scope: !735)
!745 = !DILocation(line: 44, column: 21, scope: !735)
!746 = !DILocation(line: 44, column: 27, scope: !735)
!747 = !DILocation(line: 44, column: 3, scope: !735)
!748 = !DILocation(line: 39, column: 1, scope: !735)
!749 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord", scope: null, file: !750, line: 4, type: !5, scopeLine: 4, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!750 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/layout.csl", directory: "")
!751 = !DILocation(line: 5, column: 10, scope: !752)
!752 = !DILexicalBlockFile(scope: !749, file: !750, discriminator: 0)
!753 = !DILocation(line: 5, column: 67, scope: !752)
!754 = !DILocation(line: 5, column: 3, scope: !752)
!755 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord", scope: null, file: !750, line: 8, type: !5, scopeLine: 8, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!756 = !DILocation(line: 9, column: 10, scope: !757)
!757 = !DILexicalBlockFile(scope: !755, file: !750, discriminator: 0)
!758 = !DILocation(line: 9, column: 67, scope: !757)
!759 = !DILocation(line: 9, column: 3, scope: !757)
!760 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord", scope: null, file: !761, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!761 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config.csl", directory: "")
!762 = !DILocation(line: 50, column: 3, scope: !763)
!763 = !DILexicalBlockFile(scope: !760, file: !761, discriminator: 0)
!764 = !DILocation(line: 43, column: 21, scope: !763)
!765 = !DILocation(line: 50, column: 57, scope: !763)
!766 = !DILocation(line: 50, column: 68, scope: !763)
!767 = !DILocation(line: 50, column: 41, scope: !763)
!768 = !DILocation(line: 50, column: 19, scope: !763)
!769 = !DILocation(line: 52, column: 10, scope: !763)
!770 = !DILocation(line: 52, column: 18, scope: !763)
!771 = !DILocation(line: 48, column: 22, scope: !763)
!772 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.get_x_coord", scope: null, file: !773, line: 171, type: !5, scopeLine: 171, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!773 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpyd2h.csl", directory: "")
!774 = !DILocation(line: 172, column: 12, scope: !775)
!775 = !DILexicalBlockFile(scope: !772, file: !773, discriminator: 0)
!776 = !DILocation(line: 172, column: 5, scope: !775)
!777 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.get_y_coord", scope: null, file: !773, line: 174, type: !5, scopeLine: 174, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!778 = !DILocation(line: 175, column: 12, scope: !779)
!779 = !DILexicalBlockFile(scope: !777, file: !773, discriminator: 0)
!780 = !DILocation(line: 175, column: 5, scope: !779)
!781 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval", scope: null, file: !773, line: 187, type: !5, scopeLine: 187, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!782 = !DILocation(line: 187, column: 23, scope: !783)
!783 = !DILexicalBlockFile(scope: !781, file: !773, discriminator: 0)
!784 = !DILocation(line: 188, column: 9, scope: !783)
!785 = !DILocation(line: 188, column: 20, scope: !783)
!786 = !DILocation(line: 188, column: 5, scope: !783)
!787 = !DILocation(line: 191, column: 23, scope: !783)
!788 = !DILocation(line: 191, column: 20, scope: !783)
!789 = !DILocation(line: 191, column: 9, scope: !783)
!790 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start", scope: null, file: !773, line: 383, type: !5, scopeLine: 383, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!791 = !DILocation(line: 386, column: 5, scope: !792)
!792 = !DILexicalBlockFile(scope: !790, file: !773, discriminator: 0)
!793 = !DILocation(line: 384, column: 72, scope: !792)
!794 = !DILocation(line: 384, column: 59, scope: !792)
!795 = !DILocation(line: 384, column: 46, scope: !792)
!796 = !DILocation(line: 384, column: 33, scope: !792)
!797 = !DILocation(line: 384, column: 19, scope: !792)
!798 = !DILocation(line: 384, column: 5, scope: !792)
!799 = !DILocation(line: 383, column: 32, scope: !792)
!800 = !DILocation(line: 383, column: 21, scope: !792)
!801 = !DILocation(line: 386, column: 26, scope: !792)
!802 = !DILocation(line: 388, column: 28, scope: !792)
!803 = !DILocation(line: 388, column: 17, scope: !792)
!804 = !DILocation(line: 389, column: 25, scope: !792)
!805 = !DILocation(line: 389, column: 23, scope: !792)
!806 = !DILocation(line: 391, column: 38, scope: !792)
!807 = !DILocation(line: 391, column: 20, scope: !792)
!808 = !DILocation(line: 391, column: 18, scope: !792)
!809 = !DILocation(line: 393, column: 7, scope: !792)
!810 = !DILocation(line: 395, column: 17, scope: !792)
!811 = !DILocation(line: 395, column: 15, scope: !792)
!812 = !DILocation(line: 397, column: 15, scope: !792)
!813 = !DILocation(line: 397, column: 13, scope: !792)
!814 = !DILocation(line: 398, column: 15, scope: !792)
!815 = !DILocation(line: 398, column: 25, scope: !792)
!816 = !DILocation(line: 398, column: 23, scope: !792)
!817 = !DILocation(line: 398, column: 31, scope: !792)
!818 = !DILocation(line: 398, column: 13, scope: !792)
!819 = !DILocation(line: 401, column: 10, scope: !792)
!820 = !DILocation(line: 401, column: 17, scope: !792)
!821 = !DILocation(line: 401, column: 14, scope: !792)
!822 = !DILocation(line: 401, column: 5, scope: !792)
!823 = !DILocation(line: 403, column: 48, scope: !792)
!824 = !DILocation(line: 403, column: 26, scope: !792)
!825 = !DILocation(line: 404, column: 26, scope: !792)
!826 = !DILocation(line: 404, column: 18, scope: !792)
!827 = !DILocation(line: 407, column: 48, scope: !792)
!828 = !DILocation(line: 407, column: 26, scope: !792)
!829 = !DILocation(line: 408, column: 27, scope: !792)
!830 = !DILocation(line: 408, column: 18, scope: !792)
!831 = !DILocation(line: 411, column: 14, scope: !792)
!832 = !DILocation(line: 414, column: 14, scope: !792)
!833 = !DILocation(line: 414, column: 11, scope: !792)
!834 = !DILocation(line: 414, column: 5, scope: !792)
!835 = !DILocation(line: 416, column: 44, scope: !792)
!836 = !DILocation(line: 416, column: 75, scope: !792)
!837 = !DILocation(line: 416, column: 59, scope: !792)
!838 = !DILocation(line: 416, column: 25, scope: !792)
!839 = !DILocation(line: 416, column: 23, scope: !792)
!840 = !DILocation(line: 418, column: 41, scope: !792)
!841 = !DILocation(line: 418, column: 23, scope: !792)
!842 = !DILocation(line: 419, column: 9, scope: !792)
!843 = !DILocation(line: 425, column: 44, scope: !792)
!844 = !DILocation(line: 425, column: 23, scope: !792)
!845 = !DILocation(line: 426, column: 41, scope: !792)
!846 = !DILocation(line: 426, column: 23, scope: !792)
!847 = !DILocation(line: 427, column: 9, scope: !792)
!848 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x", scope: null, file: !773, line: 448, type: !5, scopeLine: 448, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!849 = !DILocation(line: 448, column: 31, scope: !850)
!850 = !DILexicalBlockFile(scope: !848, file: !773, discriminator: 0)
!851 = !DILocation(line: 453, column: 5, scope: !850)
!852 = !DILocation(line: 456, column: 19, scope: !850)
!853 = !DILocation(line: 456, column: 17, scope: !850)
!854 = !DILocation(line: 461, column: 5, scope: !850)
!855 = !DILocation(line: 462, column: 28, scope: !850)
!856 = !DILocation(line: 462, column: 5, scope: !850)
!857 = !DILocation(line: 463, column: 5, scope: !850)
!858 = !DILocation(line: 464, column: 9, scope: !850)
!859 = !DILocation(line: 464, column: 10, scope: !850)
!860 = !DILocation(line: 464, column: 7, scope: !850)
!861 = !DILocation(line: 448, column: 1, scope: !850)
!862 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_send_data", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_send_data", scope: null, file: !773, line: 476, type: !5, scopeLine: 476, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!863 = !DILocation(line: 494, column: 9, scope: !864)
!864 = !DILexicalBlockFile(scope: !862, file: !773, discriminator: 0)
!865 = !DILocation(line: 478, column: 9, scope: !864)
!866 = !DILocation(line: 478, column: 13, scope: !864)
!867 = !DILocation(line: 478, column: 11, scope: !864)
!868 = !DILocation(line: 478, column: 5, scope: !864)
!869 = !DILocation(line: 479, column: 9, scope: !864)
!870 = !DILocation(line: 480, column: 32, scope: !864)
!871 = !DILocation(line: 480, column: 9, scope: !864)
!872 = !DILocation(line: 481, column: 17, scope: !864)
!873 = !DILocation(line: 481, column: 15, scope: !864)
!874 = !DILocation(line: 481, column: 9, scope: !864)
!875 = !DILocation(line: 482, column: 13, scope: !864)
!876 = !DILocation(line: 483, column: 51, scope: !864)
!877 = !DILocation(line: 483, column: 29, scope: !864)
!878 = !DILocation(line: 483, column: 27, scope: !864)
!879 = !DILocation(line: 485, column: 13, scope: !864)
!880 = !DILocation(line: 486, column: 51, scope: !864)
!881 = !DILocation(line: 486, column: 29, scope: !864)
!882 = !DILocation(line: 486, column: 27, scope: !864)
!883 = !DILocation(line: 488, column: 13, scope: !864)
!884 = !DILocation(line: 488, column: 14, scope: !864)
!885 = !DILocation(line: 488, column: 11, scope: !864)
!886 = !DILocation(line: 494, column: 30, scope: !864)
!887 = !DILocation(line: 496, column: 14, scope: !864)
!888 = !DILocation(line: 496, column: 25, scope: !864)
!889 = !DILocation(line: 496, column: 22, scope: !864)
!890 = !DILocation(line: 496, column: 9, scope: !864)
!891 = !DILocation(line: 497, column: 13, scope: !864)
!892 = !DILocation(line: 498, column: 13, scope: !864)
!893 = !DILocation(line: 499, column: 13, scope: !864)
!894 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl", scope: null, file: !773, line: 505, type: !5, scopeLine: 505, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!895 = !DILocation(line: 524, column: 13, scope: !896)
!896 = !DILexicalBlockFile(scope: !894, file: !773, discriminator: 0)
!897 = !DILocation(line: 506, column: 14, scope: !896)
!898 = !DILocation(line: 506, column: 11, scope: !896)
!899 = !DILocation(line: 506, column: 5, scope: !896)
!900 = !DILocation(line: 508, column: 9, scope: !896)
!901 = !DILocation(line: 509, column: 32, scope: !896)
!902 = !DILocation(line: 509, column: 9, scope: !896)
!903 = !DILocation(line: 510, column: 9, scope: !896)
!904 = !DILocation(line: 514, column: 13, scope: !896)
!905 = !DILocation(line: 514, column: 17, scope: !896)
!906 = !DILocation(line: 514, column: 15, scope: !896)
!907 = !DILocation(line: 514, column: 9, scope: !896)
!908 = !DILocation(line: 518, column: 13, scope: !896)
!909 = !DILocation(line: 519, column: 36, scope: !896)
!910 = !DILocation(line: 519, column: 13, scope: !896)
!911 = !DILocation(line: 520, column: 13, scope: !896)
!912 = !DILocation(line: 524, column: 34, scope: !896)
!913 = !DILocation(line: 526, column: 18, scope: !896)
!914 = !DILocation(line: 526, column: 29, scope: !896)
!915 = !DILocation(line: 526, column: 26, scope: !896)
!916 = !DILocation(line: 526, column: 13, scope: !896)
!917 = !DILocation(line: 529, column: 17, scope: !896)
!918 = !DILocation(line: 530, column: 17, scope: !896)
!919 = !DILocation(line: 531, column: 17, scope: !896)
!920 = !DILocation(line: 534, column: 17, scope: !896)
!921 = !DILocation(line: 535, column: 40, scope: !896)
!922 = !DILocation(line: 535, column: 17, scope: !896)
!923 = !DILocation(line: 536, column: 17, scope: !896)
!924 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.d2h_configure", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.d2h_configure", scope: null, file: !773, line: 593, type: !5, scopeLine: 593, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!925 = !DILocation(line: 617, column: 26, scope: !926)
!926 = !DILexicalBlockFile(scope: !924, file: !773, discriminator: 0)
!927 = !DILocation(line: 612, column: 47, scope: !926)
!928 = !DILocation(line: 612, column: 27, scope: !926)
!929 = !DILocation(line: 602, column: 5, scope: !926)
!930 = !DILocation(line: 601, column: 5, scope: !926)
!931 = !DILocation(line: 599, column: 5, scope: !926)
!932 = !DILocation(line: 598, column: 5, scope: !926)
!933 = !DILocation(line: 596, column: 5, scope: !926)
!934 = !DILocation(line: 595, column: 5, scope: !926)
!935 = !DILocation(line: 593, column: 86, scope: !926)
!936 = !DILocation(line: 593, column: 70, scope: !926)
!937 = !DILocation(line: 593, column: 60, scope: !926)
!938 = !DILocation(line: 593, column: 52, scope: !926)
!939 = !DILocation(line: 593, column: 44, scope: !926)
!940 = !DILocation(line: 593, column: 35, scope: !926)
!941 = !DILocation(line: 593, column: 26, scope: !926)
!942 = !DILocation(line: 593, column: 18, scope: !926)
!943 = !DILocation(line: 595, column: 26, scope: !926)
!944 = !DILocation(line: 596, column: 26, scope: !926)
!945 = !DILocation(line: 598, column: 23, scope: !926)
!946 = !DILocation(line: 599, column: 23, scope: !926)
!947 = !DILocation(line: 599, column: 28, scope: !926)
!948 = !DILocation(line: 599, column: 26, scope: !926)
!949 = !DILocation(line: 599, column: 29, scope: !926)
!950 = !DILocation(line: 601, column: 24, scope: !926)
!951 = !DILocation(line: 602, column: 24, scope: !926)
!952 = !DILocation(line: 602, column: 29, scope: !926)
!953 = !DILocation(line: 602, column: 27, scope: !926)
!954 = !DILocation(line: 602, column: 30, scope: !926)
!955 = !DILocation(line: 611, column: 20, scope: !926)
!956 = !DILocation(line: 612, column: 11, scope: !926)
!957 = !DILocation(line: 612, column: 18, scope: !926)
!958 = !DILocation(line: 612, column: 15, scope: !926)
!959 = !DILocation(line: 612, column: 32, scope: !926)
!960 = !DILocation(line: 612, column: 39, scope: !926)
!961 = !DILocation(line: 612, column: 36, scope: !926)
!962 = !DILocation(line: 612, column: 52, scope: !926)
!963 = !DILocation(line: 612, column: 59, scope: !926)
!964 = !DILocation(line: 612, column: 56, scope: !926)
!965 = !DILocation(line: 612, column: 5, scope: !926)
!966 = !DILocation(line: 613, column: 24, scope: !926)
!967 = !DILocation(line: 616, column: 15, scope: !926)
!968 = !DILocation(line: 617, column: 11, scope: !926)
!969 = !DILocation(line: 617, column: 18, scope: !926)
!970 = !DILocation(line: 617, column: 15, scope: !926)
!971 = !DILocation(line: 617, column: 30, scope: !926)
!972 = !DILocation(line: 617, column: 5, scope: !926)
!973 = !DILocation(line: 618, column: 19, scope: !926)
!974 = !DILocation(line: 621, column: 9, scope: !926)
!975 = !DILocation(line: 621, column: 5, scope: !926)
!976 = !DILocation(line: 627, column: 9, scope: !926)
!977 = !DILocation(line: 629, column: 13, scope: !926)
!978 = !DILocation(line: 629, column: 25, scope: !926)
!979 = !DILocation(line: 629, column: 21, scope: !926)
!980 = !DILocation(line: 629, column: 9, scope: !926)
!981 = !DILocation(line: 632, column: 13, scope: !926)
!982 = !DILocation(line: 636, column: 13, scope: !926)
!983 = !DILocation(line: 641, column: 9, scope: !926)
!984 = !DILocation(line: 646, column: 13, scope: !926)
!985 = !DILocation(line: 646, column: 9, scope: !926)
!986 = !DILocation(line: 647, column: 30, scope: !926)
!987 = !DILocation(line: 647, column: 35, scope: !926)
!988 = !DILocation(line: 647, column: 46, scope: !926)
!989 = !DILocation(line: 647, column: 50, scope: !926)
!990 = !DILocation(line: 647, column: 54, scope: !926)
!991 = !DILocation(line: 647, column: 57, scope: !926)
!992 = !DILocation(line: 647, column: 60, scope: !926)
!993 = !DILocation(line: 647, column: 63, scope: !926)
!994 = !DILocation(line: 647, column: 13, scope: !926)
!995 = !DILocation(line: 661, column: 9, scope: !926)
!996 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit", scope: null, file: !733, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!997 = !DILocation(line: 43, column: 3, scope: !998)
!998 = !DILexicalBlockFile(scope: !996, file: !733, discriminator: 0)
!999 = !DILocation(line: 41, column: 3, scope: !998)
!1000 = !DILocation(line: 40, column: 3, scope: !998)
!1001 = !DILocation(line: 39, column: 9, scope: !998)
!1002 = !DILocation(line: 40, column: 23, scope: !998)
!1003 = !DILocation(line: 41, column: 70, scope: !998)
!1004 = !DILocation(line: 41, column: 68, scope: !998)
!1005 = !DILocation(line: 43, column: 27, scope: !998)
!1006 = !DILocation(line: 43, column: 15, scope: !998)
!1007 = !DILocation(line: 44, column: 15, scope: !998)
!1008 = !DILocation(line: 44, column: 21, scope: !998)
!1009 = !DILocation(line: 44, column: 27, scope: !998)
!1010 = !DILocation(line: 44, column: 3, scope: !998)
!1011 = !DILocation(line: 39, column: 1, scope: !998)
!1012 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord", scope: null, file: !750, line: 4, type: !5, scopeLine: 4, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1013 = !DILocation(line: 5, column: 10, scope: !1014)
!1014 = !DILexicalBlockFile(scope: !1012, file: !750, discriminator: 0)
!1015 = !DILocation(line: 5, column: 67, scope: !1014)
!1016 = !DILocation(line: 5, column: 3, scope: !1014)
!1017 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord", scope: null, file: !750, line: 8, type: !5, scopeLine: 8, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1018 = !DILocation(line: 9, column: 10, scope: !1019)
!1019 = !DILexicalBlockFile(scope: !1017, file: !750, discriminator: 0)
!1020 = !DILocation(line: 9, column: 67, scope: !1019)
!1021 = !DILocation(line: 9, column: 3, scope: !1019)
!1022 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord", scope: null, file: !761, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1023 = !DILocation(line: 50, column: 3, scope: !1024)
!1024 = !DILexicalBlockFile(scope: !1022, file: !761, discriminator: 0)
!1025 = !DILocation(line: 43, column: 21, scope: !1024)
!1026 = !DILocation(line: 50, column: 57, scope: !1024)
!1027 = !DILocation(line: 50, column: 68, scope: !1024)
!1028 = !DILocation(line: 50, column: 41, scope: !1024)
!1029 = !DILocation(line: 50, column: 19, scope: !1024)
!1030 = !DILocation(line: 52, column: 10, scope: !1024)
!1031 = !DILocation(line: 52, column: 18, scope: !1024)
!1032 = !DILocation(line: 48, column: 22, scope: !1024)
!1033 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr", linkageName: "sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr", scope: null, file: !1034, line: 11, type: !5, scopeLine: 11, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1034 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/input_queue_config.csl", directory: "")
!1035 = !DILocation(line: 11, column: 32, scope: !1036)
!1036 = !DILexicalBlockFile(scope: !1033, file: !1034, discriminator: 0)
!1037 = !DILocation(line: 12, column: 80, scope: !1036)
!1038 = !DILocation(line: 12, column: 69, scope: !1036)
!1039 = !DILocation(line: 12, column: 39, scope: !1036)
!1040 = !DILocation(line: 12, column: 3, scope: !1036)
!1041 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue", linkageName: "sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue", scope: null, file: !1034, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1042 = !DILocation(line: 46, column: 3, scope: !1043)
!1043 = !DILexicalBlockFile(scope: !1041, file: !1034, discriminator: 0)
!1044 = !DILocation(line: 45, column: 3, scope: !1043)
!1045 = !DILocation(line: 39, column: 42, scope: !1043)
!1046 = !DILocation(line: 39, column: 34, scope: !1043)
!1047 = !DILocation(line: 39, column: 24, scope: !1043)
!1048 = !DILocation(line: 45, column: 44, scope: !1043)
!1049 = !DILocation(line: 45, column: 16, scope: !1043)
!1050 = !DILocation(line: 46, column: 30, scope: !1043)
!1051 = !DILocation(line: 46, column: 18, scope: !1043)
!1052 = !DILocation(line: 56, column: 9, scope: !1043)
!1053 = !DILocation(line: 56, column: 5, scope: !1043)
!1054 = !DILocation(line: 58, column: 13, scope: !1043)
!1055 = !DILocation(line: 58, column: 17, scope: !1043)
!1056 = !DILocation(line: 58, column: 11, scope: !1043)
!1057 = !DILocation(line: 61, column: 13, scope: !1043)
!1058 = !DILocation(line: 61, column: 17, scope: !1043)
!1059 = !DILocation(line: 61, column: 11, scope: !1043)
!1060 = !DILocation(line: 66, column: 9, scope: !1043)
!1061 = !DILocation(line: 66, column: 13, scope: !1043)
!1062 = !DILocation(line: 66, column: 7, scope: !1043)
!1063 = !DILocation(line: 68, column: 9, scope: !1043)
!1064 = !DILocation(line: 68, column: 24, scope: !1043)
!1065 = !DILocation(line: 68, column: 13, scope: !1043)
!1066 = !DILocation(line: 68, column: 7, scope: !1043)
!1067 = !DILocation(line: 70, column: 15, scope: !1043)
!1068 = !DILocation(line: 70, column: 21, scope: !1043)
!1069 = !DILocation(line: 70, column: 3, scope: !1043)
!1070 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr", linkageName: "sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr", scope: null, file: !1071, line: 11, type: !5, scopeLine: 11, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1071 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/output_queue_config.csl", directory: "")
!1072 = !DILocation(line: 11, column: 33, scope: !1073)
!1073 = !DILexicalBlockFile(scope: !1070, file: !1071, discriminator: 0)
!1074 = !DILocation(line: 12, column: 82, scope: !1073)
!1075 = !DILocation(line: 12, column: 40, scope: !1073)
!1076 = !DILocation(line: 12, column: 3, scope: !1073)
!1077 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue", linkageName: "sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue", scope: null, file: !1071, line: 31, type: !5, scopeLine: 31, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1078 = !DILocation(line: 38, column: 3, scope: !1079)
!1079 = !DILexicalBlockFile(scope: !1077, file: !1071, discriminator: 0)
!1080 = !DILocation(line: 37, column: 3, scope: !1079)
!1081 = !DILocation(line: 31, column: 35, scope: !1079)
!1082 = !DILocation(line: 31, column: 25, scope: !1079)
!1083 = !DILocation(line: 37, column: 45, scope: !1079)
!1084 = !DILocation(line: 37, column: 16, scope: !1079)
!1085 = !DILocation(line: 38, column: 30, scope: !1079)
!1086 = !DILocation(line: 38, column: 18, scope: !1079)
!1087 = !DILocation(line: 41, column: 9, scope: !1079)
!1088 = !DILocation(line: 41, column: 13, scope: !1079)
!1089 = !DILocation(line: 41, column: 7, scope: !1079)
!1090 = !DILocation(line: 43, column: 9, scope: !1079)
!1091 = !DILocation(line: 43, column: 24, scope: !1079)
!1092 = !DILocation(line: 43, column: 13, scope: !1079)
!1093 = !DILocation(line: 43, column: 27, scope: !1079)
!1094 = !DILocation(line: 43, column: 7, scope: !1079)
!1095 = !DILocation(line: 45, column: 15, scope: !1079)
!1096 = !DILocation(line: 45, column: 21, scope: !1079)
!1097 = !DILocation(line: 45, column: 3, scope: !1079)
!1098 = !DILocation(line: 31, column: 1, scope: !1079)
!1099 = distinct !DISubprogram(name: ".get_tensor_ptr", linkageName: ".get_tensor_ptr", scope: null, file: !4, line: 1, type: !5, scopeLine: 1, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1100 = !DILocation(line: 1, column: 1, scope: !1101)
!1101 = !DILexicalBlockFile(scope: !1099, file: !4, discriminator: 0)
!1102 = distinct !DISubprogram(name: "__generic0sys_mod.sys_mod.tile_config.queue_flush.exit", linkageName: "__generic0sys_mod.sys_mod.tile_config.queue_flush.exit", scope: null, file: !1103, line: 12, type: !5, scopeLine: 12, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1103 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/queue_flush.csl", directory: "")
!1104 = !DILocation(line: 24, column: 3, scope: !1105)
!1105 = !DILexicalBlockFile(scope: !1102, file: !1103, discriminator: 0)
!1106 = !DILocation(line: 12, column: 1, scope: !1105)
!1107 = distinct !DISubprogram(name: "__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position", linkageName: "__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position", scope: null, file: !1108, line: 30, type: !5, scopeLine: 30, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1108 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/switch_config.csl", directory: "")
!1109 = !DILocation(line: 34, column: 3, scope: !1110)
!1110 = !DILexicalBlockFile(scope: !1107, file: !1108, discriminator: 0)
!1111 = !DILocation(line: 32, column: 3, scope: !1110)
!1112 = !DILocation(line: 30, column: 27, scope: !1110)
!1113 = !DILocation(line: 33, column: 7, scope: !1110)
!1114 = !DILocation(line: 34, column: 36, scope: !1110)
!1115 = !DILocation(line: 34, column: 24, scope: !1110)
!1116 = !DILocation(line: 35, column: 3, scope: !1110)
!1117 = !DILocation(line: 35, column: 18, scope: !1110)
!1118 = !DILocation(line: 36, column: 15, scope: !1110)
!1119 = !DILocation(line: 36, column: 21, scope: !1110)
!1120 = !DILocation(line: 36, column: 3, scope: !1110)
!1121 = !DILocation(line: 30, column: 1, scope: !1110)
!1122 = distinct !DISubprogram(name: "__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", linkageName: "__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", scope: null, file: !1123, line: 96, type: !5, scopeLine: 96, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1123 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/color_config.csl", directory: "")
!1124 = !DILocation(line: 99, column: 3, scope: !1125)
!1125 = !DILexicalBlockFile(scope: !1122, file: !1123, discriminator: 0)
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
!1146 = distinct !DISubprogram(name: "__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", linkageName: "__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", scope: null, file: !1123, line: 96, type: !5, scopeLine: 96, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1147 = !DILocation(line: 99, column: 3, scope: !1148)
!1148 = !DILexicalBlockFile(scope: !1146, file: !1123, discriminator: 0)
!1149 = !DILocation(line: 98, column: 3, scope: !1148)
!1150 = !DILocation(line: 96, column: 17, scope: !1148)
!1151 = !DILocation(line: 98, column: 16, scope: !1148)
!1152 = !DILocation(line: 99, column: 29, scope: !1148)
!1153 = !DILocation(line: 99, column: 17, scope: !1148)
!1154 = !DILocation(line: 100, column: 13, scope: !1148)
!1155 = !DILocation(line: 100, column: 21, scope: !1148)
!1156 = !DILocation(line: 100, column: 11, scope: !1148)
!1157 = !DILocation(line: 104, column: 7, scope: !1148)
!1158 = !DILocation(line: 104, column: 50, scope: !1148)
!1159 = !DILocation(line: 104, column: 18, scope: !1148)
!1160 = !DILocation(line: 104, column: 15, scope: !1148)
!1161 = !DILocation(line: 121, column: 7, scope: !1148)
!1162 = !DILocation(line: 121, column: 50, scope: !1148)
!1163 = !DILocation(line: 121, column: 18, scope: !1148)
!1164 = !DILocation(line: 121, column: 15, scope: !1148)
!1165 = !DILocation(line: 128, column: 15, scope: !1148)
!1166 = !DILocation(line: 128, column: 21, scope: !1148)
!1167 = !DILocation(line: 128, column: 3, scope: !1148)
!1168 = !DILocation(line: 96, column: 1, scope: !1148)
!1169 = distinct !DISubprogram(name: "__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", linkageName: "__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", scope: null, file: !1123, line: 60, type: !5, scopeLine: 60, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1170 = !DILocation(line: 61, column: 3, scope: !1171)
!1171 = !DILexicalBlockFile(scope: !1169, file: !1123, discriminator: 0)
!1172 = !DILocation(line: 60, column: 46, scope: !1171)
!1173 = !DILocation(line: 61, column: 16, scope: !1171)
!1174 = !DILocation(line: 72, column: 5, scope: !1171)
!1175 = !DILocation(line: 72, column: 12, scope: !1171)
!1176 = !DILocation(line: 74, column: 10, scope: !1171)
!1177 = !DILocation(line: 74, column: 3, scope: !1171)
!1178 = distinct !DISubprogram(name: "__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes", linkageName: "__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes", scope: null, file: !1123, line: 77, type: !5, scopeLine: 77, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1179 = !DILocation(line: 78, column: 3, scope: !1180)
!1180 = !DILexicalBlockFile(scope: !1178, file: !1123, discriminator: 0)
!1181 = !DILocation(line: 77, column: 46, scope: !1180)
!1182 = !DILocation(line: 78, column: 16, scope: !1180)
!1183 = !DILocation(line: 86, column: 5, scope: !1180)
!1184 = !DILocation(line: 86, column: 12, scope: !1180)
!1185 = !DILocation(line: 91, column: 10, scope: !1180)
!1186 = !DILocation(line: 91, column: 3, scope: !1180)
!1187 = distinct !DISubprogram(name: "__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", linkageName: "__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", scope: null, file: !1123, line: 60, type: !5, scopeLine: 60, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1188 = !DILocation(line: 61, column: 3, scope: !1189)
!1189 = !DILexicalBlockFile(scope: !1187, file: !1123, discriminator: 0)
!1190 = !DILocation(line: 60, column: 46, scope: !1189)
!1191 = !DILocation(line: 61, column: 16, scope: !1189)
!1192 = !DILocation(line: 63, column: 5, scope: !1189)
!1193 = !DILocation(line: 63, column: 12, scope: !1189)
!1194 = !DILocation(line: 74, column: 10, scope: !1189)
!1195 = !DILocation(line: 74, column: 3, scope: !1189)
!1196 = distinct !DISubprogram(name: "__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction", linkageName: "__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction", scope: null, file: !1123, line: 52, type: !5, scopeLine: 52, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1197 = !DILocation(line: 55, column: 3, scope: !1198)
!1198 = !DILexicalBlockFile(scope: !1196, file: !1123, discriminator: 0)
!1199 = !DILocation(line: 54, column: 3, scope: !1198)
!1200 = !DILocation(line: 52, column: 23, scope: !1198)
!1201 = !DILocation(line: 54, column: 16, scope: !1198)
!1202 = !DILocation(line: 55, column: 29, scope: !1198)
!1203 = !DILocation(line: 55, column: 17, scope: !1198)
!1204 = !DILocation(line: 56, column: 3, scope: !1198)
!1205 = !DILocation(line: 56, column: 11, scope: !1198)
!1206 = !DILocation(line: 57, column: 15, scope: !1198)
!1207 = !DILocation(line: 57, column: 21, scope: !1198)
!1208 = !DILocation(line: 57, column: 3, scope: !1198)
!1209 = !DILocation(line: 52, column: 1, scope: !1198)
!1210 = distinct !DISubprogram(name: "__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction", linkageName: "__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction", scope: null, file: !1123, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1211 = !DILocation(line: 23, column: 3, scope: !1212)
!1212 = !DILexicalBlockFile(scope: !1210, file: !1123, discriminator: 0)
!1213 = !DILocation(line: 22, column: 3, scope: !1212)
!1214 = !DILocation(line: 20, column: 21, scope: !1212)
!1215 = !DILocation(line: 22, column: 16, scope: !1212)
!1216 = !DILocation(line: 23, column: 29, scope: !1212)
!1217 = !DILocation(line: 23, column: 17, scope: !1212)
!1218 = !DILocation(line: 24, column: 3, scope: !1212)
!1219 = !DILocation(line: 24, column: 11, scope: !1212)
!1220 = !DILocation(line: 25, column: 15, scope: !1212)
!1221 = !DILocation(line: 25, column: 21, scope: !1212)
!1222 = !DILocation(line: 25, column: 3, scope: !1212)
!1223 = !DILocation(line: 20, column: 1, scope: !1212)
module asm ".section \22.pe_debug_info\22, \22\22"
module asm ".section \22.note\22, \22\22"
