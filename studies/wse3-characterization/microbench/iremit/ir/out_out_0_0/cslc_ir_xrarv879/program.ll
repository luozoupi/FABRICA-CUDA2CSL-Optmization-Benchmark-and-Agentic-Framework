; ModuleID = './layout.csl'
source_filename = "./layout.csl"
target datalayout = "e-ni:0-p:16:16-i1:16-i16:16-i32:32-i64:64-f32:32-f64:64"
target triple = "cs_sdr-cerebras-csos"

@row_ptr = internal global [18 x i16] zeroinitializer, align 4
@col_idx = internal global [64 x i16] zeroinitializer, align 4
@col_start = internal global [16 x i16] zeroinitializer, align 4
@run_len = internal global [16 x i16] zeroinitializer, align 4
@"$$csl_base_address$$3$$val" = dso_local global [64 x float] zeroinitializer, align 4
@"$$csl_base_address$$2$$x" = dso_local global [16 x float] zeroinitializer, align 4
@"$$csl_base_address$$0$$adense" = dso_local global [256 x float] zeroinitializer, align 4
@"$$csl_base_address$$1$$tmp" = dso_local global [16 x float] zeroinitializer, align 4
@y_sc = internal global [16 x float] zeroinitializer, align 4
@y_ir = internal global [16 x float] zeroinitializer, align 4
@y_bk = internal global [16 x float] zeroinitializer, align 4
@y_dn = internal global [16 x float] zeroinitializer, align 4
@mark = internal global [16 x i16] zeroinitializer, align 4
@p_row_ptr = internal global i16* getelementptr inbounds ([18 x i16], [18 x i16]* @row_ptr, i32 0, i32 0), align 4
@p_col_idx = internal global i16* getelementptr inbounds ([64 x i16], [64 x i16]* @col_idx, i32 0, i32 0), align 4
@p_col_start = internal global i16* getelementptr inbounds ([16 x i16], [16 x i16]* @col_start, i32 0, i32 0), align 4
@p_run_len = internal global i16* getelementptr inbounds ([16 x i16], [16 x i16]* @run_len, i32 0, i32 0), align 4
@p_val = internal global float* getelementptr inbounds ([64 x float], [64 x float]* @"$$csl_base_address$$3$$val", i32 0, i32 0), align 4
@p_x = internal global float* getelementptr inbounds ([16 x float], [16 x float]* @"$$csl_base_address$$2$$x", i32 0, i32 0), align 4
@p_adense = internal global float* getelementptr inbounds ([256 x float], [256 x float]* @"$$csl_base_address$$0$$adense", i32 0, i32 0), align 4
@p_y_sc = internal global float* getelementptr inbounds ([16 x float], [16 x float]* @y_sc, i32 0, i32 0), align 4
@p_y_ir = internal global float* getelementptr inbounds ([16 x float], [16 x float]* @y_ir, i32 0, i32 0), align 4
@p_y_bk = internal global float* getelementptr inbounds ([16 x float], [16 x float]* @y_bk, i32 0, i32 0), align 4
@p_y_dn = internal global float* getelementptr inbounds ([16 x float], [16 x float]* @y_dn, i32 0, i32 0), align 4
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
@"$$csl_base_address$$6$$sys_mod.sys_mod.memcpyh2d_mod_1.dummy" = dso_local constant [1 x i16] zeroinitializer, align 4
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
@"$$csl_base_address$$5$$sys_mod.sys_mod.memcpyd2h_mod.dummy" = dso_local constant [1 x i16] zeroinitializer, align 4
@sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd = internal global <{ i16, i16, i16, i16 }> <{ i16 1, i16 lshr (i16 ptrtoint ([1 x i16]* @"$$csl_base_address$$5$$sys_mod.sys_mod.memcpyd2h_mod.dummy" to i16), i16 1), i16 143, i16 16 }>, align 4
@"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11" = dso_local global [1 x i32] [i32 190812745], align 4
@sys_mod.sys_mod.memcpyd2h_mod.ctrl_1 = internal global [1 x i32] [i32 157258313], align 4
@sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd = internal global <{ i16, i16, i16, i16 }> <{ i16 1, i16 lshr (i16 ptrtoint ([1 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11" to i16), i16 1), i16 143, i16 16 }>, align 4
@"$$csl_base_address$$8$$sys_mod.sys_mod.memcpyd2h_mod.sw_td" = dso_local global [2 x i32] zeroinitializer, align 4
@"$$csl_base_address$$7$$sys_mod.sys_mod.memcpyd2h_mod.teardown_buf" = dso_local constant [1 x i32] [i32 165646921], align 4
@__dsr_lowmeminit_ = internal constant <{ i16, i16, i16, i16 }> <{ i16 16, i16 lshr (i16 ptrtoint ([16 x float]* @"$$csl_base_address$$2$$x" to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__0 = internal constant <{ i16, i16, i16, i16 }> <{ i16 16, i16 lshr (i16 ptrtoint ([16 x float]* @"$$csl_base_address$$1$$tmp" to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__1 = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 62, i16 142, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__2 = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 4127, i16 142, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__3 = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 lshr (i16 ptrtoint ([1 x i32]* @"$$csl_base_address$$7$$sys_mod.sys_mod.memcpyd2h_mod.teardown_buf" to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__4 = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 4149, i16 142, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__5 = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 4096, i16 142, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__6 = internal constant <{ i16, i16, i16, i16 }> <{ i16 2, i16 4127, i16 142, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__7 = internal constant <{ i16, i16, i16, i16 }> <{ i16 2, i16 lshr (i16 ptrtoint ([2 x i32]* @"$$csl_base_address$$8$$sys_mod.sys_mod.memcpyd2h_mod.sw_td" to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4

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
  %57 = getelementptr [64 x float], [64 x float]* @"$$csl_base_address$$3$$val", i16 0, i16 %56, !dbg !32
  %58 = load float, float* %57, align 4, !dbg !32
  %59 = load i16, i16* %1, align 2, !dbg !33
  %60 = getelementptr [16 x float], [16 x float]* @"$$csl_base_address$$2$$x", i16 0, i16 %59, !dbg !34
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
  %vp = getelementptr [64 x float], [64 x float]* @val, i16 0, i16 %j
  %v = load float, float* %vp, align 4
  %xp = getelementptr [16 x float], [16 x float]* @x, i16 0, i16 %c
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
  %1 = alloca float, i16 1, align 4, !dbg !55
  %2 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !57
  %3 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !58
  %4 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !59
  %5 = alloca i16, i16 1, align 2, !dbg !60
  %6 = alloca i16, i16 1, align 2, !dbg !61
  %7 = alloca i16, i16 1, align 2, !dbg !62
  %8 = alloca i16, i16 1, align 2, !dbg !63
  store i16 28676, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i4 4), align 2, !dbg !64
  store i16 0, i16* %8, align 2, !dbg !63
  br label %9, !dbg !65

9:                                                ; preds = %26, %0
  %10 = phi i16 [ 0, %26 ], [ 0, %0 ]
  %11 = icmp sgt i16 %10, 0, !dbg !65
  br i1 %11, label %12, label %14, !dbg !65

12:                                               ; preds = %9
  %13 = sub i16 %10, 1, !dbg !65
  br label %15, !dbg !65

14:                                               ; preds = %9
  br label %15, !dbg !65

15:                                               ; preds = %12, %14
  %16 = phi i16 [ %10, %14 ], [ %13, %12 ]
  br label %17, !dbg !65

17:                                               ; preds = %15
  %18 = icmp ne i16 %10, 0, !dbg !65
  br i1 %18, label %19, label %20, !dbg !65

19:                                               ; preds = %17
  br label %23, !dbg !65

20:                                               ; preds = %17
  %21 = load i16, i16* %8, align 2, !dbg !66
  %22 = icmp ult i16 %21, 16, !dbg !67
  br label %23, !dbg !65

23:                                               ; preds = %19, %20
  %24 = phi i1 [ %22, %20 ], [ false, %19 ]
  br label %25, !dbg !65

25:                                               ; preds = %23
  br i1 %24, label %26, label %120, !dbg !65

26:                                               ; preds = %25
  %27 = load i16, i16* %8, align 2, !dbg !68
  %28 = getelementptr [18 x i16], [18 x i16]* @row_ptr, i16 0, i16 %27, !dbg !69
  %29 = load i16, i16* %28, align 2, !dbg !69
  store i16 %29, i16* %7, align 2, !dbg !62
  %30 = load i16, i16* %8, align 2, !dbg !70
  %31 = getelementptr [16 x i16], [16 x i16]* @run_len, i16 0, i16 %30, !dbg !71
  %32 = load i16, i16* %31, align 2, !dbg !71
  store i16 %32, i16* %6, align 2, !dbg !61
  %33 = load i16, i16* %8, align 2, !dbg !72
  %34 = getelementptr [16 x i16], [16 x i16]* @col_start, i16 0, i16 %33, !dbg !73
  %35 = load i16, i16* %34, align 2, !dbg !73
  store i16 %35, i16* %5, align 2, !dbg !60
  %36 = load i16, i16* %6, align 2, !dbg !74
  %37 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !59
  store i16 %36, i16* %37, align 2, !dbg !59
  %38 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !59
  store i16 lshr (i16 ptrtoint ([64 x float]* @"$$csl_base_address$$3$$val" to i16), i16 1), i16* %38, align 2, !dbg !59
  %39 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !59
  store i16 143, i16* %39, align 2, !dbg !59
  %40 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !59
  store i16 16, i16* %40, align 2, !dbg !59
  %41 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !75
  %42 = load i16, i16* %41, align 2, !dbg !75
  %43 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !75
  %44 = load i16, i16* %43, align 2, !dbg !75
  %45 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !75
  %46 = load i16, i16* %45, align 2, !dbg !75
  %47 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !75
  %48 = load i16, i16* %47, align 2, !dbg !75
  %49 = load i16, i16* %7, align 2, !dbg !76
  %50 = mul i16 %49, 2, !dbg !77
  %51 = add i16 %44, %50, !dbg !77
  %52 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !78
  store i16 %42, i16* %52, align 2, !dbg !78
  %53 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !78
  store i16 %51, i16* %53, align 2, !dbg !78
  %54 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !78
  store i16 %46, i16* %54, align 2, !dbg !78
  %55 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !78
  store i16 %48, i16* %55, align 2, !dbg !78
  %56 = load i16, i16* %6, align 2, !dbg !79
  %57 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 0, !dbg !58
  store i16 %56, i16* %57, align 2, !dbg !58
  %58 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 1, !dbg !58
  store i16 lshr (i16 ptrtoint ([16 x float]* @"$$csl_base_address$$2$$x" to i16), i16 1), i16* %58, align 2, !dbg !58
  %59 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 2, !dbg !58
  store i16 143, i16* %59, align 2, !dbg !58
  %60 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 3, !dbg !58
  store i16 16, i16* %60, align 2, !dbg !58
  %61 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 0, !dbg !80
  %62 = load i16, i16* %61, align 2, !dbg !80
  %63 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 1, !dbg !80
  %64 = load i16, i16* %63, align 2, !dbg !80
  %65 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 2, !dbg !80
  %66 = load i16, i16* %65, align 2, !dbg !80
  %67 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 3, !dbg !80
  %68 = load i16, i16* %67, align 2, !dbg !80
  %69 = load i16, i16* %5, align 2, !dbg !81
  %70 = mul i16 %69, 2, !dbg !82
  %71 = add i16 %64, %70, !dbg !82
  %72 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 0, !dbg !83
  store i16 %62, i16* %72, align 2, !dbg !83
  %73 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 1, !dbg !83
  store i16 %71, i16* %73, align 2, !dbg !83
  %74 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 2, !dbg !83
  store i16 %66, i16* %74, align 2, !dbg !83
  %75 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 3, !dbg !83
  store i16 %68, i16* %75, align 2, !dbg !83
  %76 = load i16, i16* %6, align 2, !dbg !84
  %77 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 0, !dbg !57
  store i16 %76, i16* %77, align 2, !dbg !57
  %78 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 1, !dbg !57
  store i16 lshr (i16 ptrtoint ([16 x float]* @"$$csl_base_address$$1$$tmp" to i16), i16 1), i16* %78, align 2, !dbg !57
  %79 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 2, !dbg !57
  store i16 143, i16* %79, align 2, !dbg !57
  %80 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 3, !dbg !57
  store i16 16, i16* %80, align 2, !dbg !57
  %81 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 0, !dbg !85
  %82 = load i16, i16* %81, align 2, !dbg !85
  %83 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 1, !dbg !85
  %84 = load i16, i16* %83, align 2, !dbg !85
  %85 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 2, !dbg !85
  %86 = load i16, i16* %85, align 2, !dbg !85
  %87 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 3, !dbg !85
  %88 = load i16, i16* %87, align 2, !dbg !85
  %89 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !86
  %90 = load i16, i16* %89, align 2, !dbg !86
  %91 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !86
  %92 = load i16, i16* %91, align 2, !dbg !86
  %93 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !86
  %94 = load i16, i16* %93, align 2, !dbg !86
  %95 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !86
  %96 = load i16, i16* %95, align 2, !dbg !86
  %97 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 0, !dbg !87
  %98 = load i16, i16* %97, align 2, !dbg !87
  %99 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 1, !dbg !87
  %100 = load i16, i16* %99, align 2, !dbg !87
  %101 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 2, !dbg !87
  %102 = load i16, i16* %101, align 2, !dbg !87
  %103 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %3, i32 0, i32 3, !dbg !87
  %104 = load i16, i16* %103, align 2, !dbg !87
  store volatile i16 %82, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 0), align 2, !dbg !88
  store volatile i16 %84, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 1), align 2, !dbg !88
  store volatile i16 %86, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 2), align 2, !dbg !88
  store volatile i16 %88, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 3), align 2, !dbg !88
  call void asm sideeffect "nop", ""(), !dbg !88
  call void asm sideeffect "nop", ""(), !dbg !88
  store volatile i16 %90, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -896 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 0), align 2, !dbg !88
  store volatile i16 %92, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -896 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 1), align 2, !dbg !88
  store volatile i16 %94, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -896 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 2), align 2, !dbg !88
  store volatile i16 %96, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -896 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 3), align 2, !dbg !88
  call void asm sideeffect "nop", ""(), !dbg !88
  call void asm sideeffect "nop", ""(), !dbg !88
  store volatile i16 %98, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 0), align 2, !dbg !88
  store volatile i16 %100, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 1), align 2, !dbg !88
  store volatile i16 %102, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 2), align 2, !dbg !88
  store volatile i16 %104, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 3), align 2, !dbg !88
  call void asm sideeffect "nop", ""(), !dbg !88
  call void asm sideeffect "nop", ""(), !dbg !88
  call void @llvm.sdr.fmuls.ds0s1(i16 1, i16 1, i16 1), !dbg !88
  store float 0.000000e+00, float* %1, align 4, !dbg !55
  %105 = load float, float* %1, align 4, !dbg !89
  %106 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 0, !dbg !90
  %107 = load i16, i16* %106, align 2, !dbg !90
  %108 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 1, !dbg !90
  %109 = load i16, i16* %108, align 2, !dbg !90
  %110 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 2, !dbg !90
  %111 = load i16, i16* %110, align 2, !dbg !90
  %112 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 3, !dbg !90
  %113 = load i16, i16* %112, align 2, !dbg !90
  store volatile i16 %107, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 0), align 2, !dbg !91
  store volatile i16 %109, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 1), align 2, !dbg !91
  store volatile i16 %111, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 2), align 2, !dbg !91
  store volatile i16 %113, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 3), align 2, !dbg !91
  call void asm sideeffect "nop", ""(), !dbg !91
  call void asm sideeffect "nop", ""(), !dbg !91
  %114 = call float @llvm.sdr.fadds.rrs1(float %105, i16 1), !dbg !91
  store float %114, float* %1, align 4, !dbg !91
  %115 = load float, float* %1, align 4, !dbg !92
  %116 = load i16, i16* %8, align 2, !dbg !93
  %117 = getelementptr [16 x float], [16 x float]* @y_bk, i16 0, i16 %116, !dbg !94
  store float %115, float* %117, align 4, !dbg !95
  %118 = load i16, i16* %8, align 2, !dbg !96
  %119 = add i16 %118, 1, !dbg !97
  store i16 %119, i16* %8, align 2, !dbg !97
  br label %9, !dbg !65

120:                                              ; preds = %25
  %121 = icmp ne i16 %16, 0, !dbg !65
  br i1 %121, label %122, label %123, !dbg !65

122:                                              ; preds = %120
  br label %124, !dbg !65

123:                                              ; preds = %120
  store i16 28677, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i4 5), align 2, !dbg !98
  call void @llvm.sdr.actvt.r(i16 9), !dbg !99
  br label %124, !dbg !65

124:                                              ; preds = %122, %123
  ret void, !dbg !65
}

define internal void @spmv_dense() !dbg !100 {
  %1 = alloca float, i16 1, align 4, !dbg !101
  %2 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !103
  %3 = alloca i16, i16 1, align 2, !dbg !104
  store i16 28678, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i4 6), align 2, !dbg !105
  store i16 0, i16* %3, align 2, !dbg !104
  br label %4, !dbg !106

4:                                                ; preds = %21, %0
  %5 = phi i16 [ 0, %21 ], [ 0, %0 ]
  %6 = icmp sgt i16 %5, 0, !dbg !106
  br i1 %6, label %7, label %9, !dbg !106

7:                                                ; preds = %4
  %8 = sub i16 %5, 1, !dbg !106
  br label %10, !dbg !106

9:                                                ; preds = %4
  br label %10, !dbg !106

10:                                               ; preds = %7, %9
  %11 = phi i16 [ %5, %9 ], [ %8, %7 ]
  br label %12, !dbg !106

12:                                               ; preds = %10
  %13 = icmp ne i16 %5, 0, !dbg !106
  br i1 %13, label %14, label %15, !dbg !106

14:                                               ; preds = %12
  br label %18, !dbg !106

15:                                               ; preds = %12
  %16 = load i16, i16* %3, align 2, !dbg !107
  %17 = icmp ult i16 %16, 16, !dbg !108
  br label %18, !dbg !106

18:                                               ; preds = %14, %15
  %19 = phi i1 [ %17, %15 ], [ false, %14 ]
  br label %20, !dbg !106

20:                                               ; preds = %18
  br i1 %19, label %21, label %45, !dbg !106

21:                                               ; preds = %20
  %22 = load i16, i16* %3, align 2, !dbg !109
  %23 = mul i16 %22, 16, !dbg !110
  %24 = mul i16 %23, 2, !dbg !111
  %25 = add i16 lshr (i16 ptrtoint ([256 x float]* @"$$csl_base_address$$0$$adense" to i16), i16 1), %24, !dbg !111
  %26 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 0, !dbg !103
  store i16 16, i16* %26, align 2, !dbg !103
  %27 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 1, !dbg !103
  store i16 %25, i16* %27, align 2, !dbg !103
  %28 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 2, !dbg !103
  store i16 143, i16* %28, align 2, !dbg !103
  %29 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 3, !dbg !103
  store i16 16, i16* %29, align 2, !dbg !103
  %30 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 0, !dbg !112
  %31 = load i16, i16* %30, align 2, !dbg !112
  %32 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 1, !dbg !112
  %33 = load i16, i16* %32, align 2, !dbg !112
  %34 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 2, !dbg !112
  %35 = load i16, i16* %34, align 2, !dbg !112
  %36 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %2, i32 0, i32 3, !dbg !112
  %37 = load i16, i16* %36, align 2, !dbg !112
  call void @llvm.sdr.lds1wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !113
  call void @llvm.sdr.lddwds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !113
  store volatile i16 %31, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -896 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 0), align 2, !dbg !113
  store volatile i16 %33, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -896 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 1), align 2, !dbg !113
  store volatile i16 %35, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -896 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 2), align 2, !dbg !113
  store volatile i16 %37, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -896 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 3), align 2, !dbg !113
  call void asm sideeffect "nop", ""(), !dbg !113
  call void asm sideeffect "nop", ""(), !dbg !113
  call void @llvm.sdr.fmuls.ds0s1(i16 1, i16 1, i16 1), !dbg !113
  store float 0.000000e+00, float* %1, align 4, !dbg !101
  %38 = load float, float* %1, align 4, !dbg !114
  call void @llvm.sdr.lds1wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !115
  %39 = call float @llvm.sdr.fadds.rrs1(float %38, i16 1), !dbg !115
  store float %39, float* %1, align 4, !dbg !115
  %40 = load float, float* %1, align 4, !dbg !116
  %41 = load i16, i16* %3, align 2, !dbg !117
  %42 = getelementptr [16 x float], [16 x float]* @y_dn, i16 0, i16 %41, !dbg !118
  store float %40, float* %42, align 4, !dbg !119
  %43 = load i16, i16* %3, align 2, !dbg !120
  %44 = add i16 %43, 1, !dbg !121
  store i16 %44, i16* %3, align 2, !dbg !121
  br label %4, !dbg !106

45:                                               ; preds = %20
  %46 = icmp ne i16 %11, 0, !dbg !106
  br i1 %46, label %47, label %48, !dbg !106

47:                                               ; preds = %45
  br label %49, !dbg !106

48:                                               ; preds = %45
  store i16 28679, i16* getelementptr inbounds ([16 x i16], [16 x i16]* @mark, i16 0, i4 7), align 2, !dbg !122
  call void @llvm.sdr.actvt.r(i16 9), !dbg !123
  br label %49, !dbg !106

49:                                               ; preds = %47, %48
  ret void, !dbg !106
}

define void @f_exit() #0 !dbg !124 {
  call void @sys_mod.unblock_cmd_stream(), !dbg !125
  ret void, !dbg !127
}

define internal void @sys_mod.sys_nop() !dbg !128 {
  ret void, !dbg !130
}

define internal void @sys_mod.unblock_cmd_stream() !dbg !132 {
  call void @sys_mod.sys_mod.unblock_cmd_stream(), !dbg !133
  ret void, !dbg !135
}

define internal void @sys_mod.sys_mod.unblock_cmd_stream() !dbg !136 {
  call void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream(), !dbg !138
  ret void, !dbg !140
}

define internal void @sys_mod.sys_mod.teardown_h2d() !dbg !141 {
  call void @llvm.sdr.actvt.r(i16 27), !dbg !142
  ret void, !dbg !144
}

define void @sys_mod.sys_mod.f_ublk_c22() #1 !dbg !145 {
  call void @sys_mod.sys_mod.unblock_cmd_stream(), !dbg !146
  ret void, !dbg !148
}

define internal void @sys_mod.sys_mod.teardown_d2h() !dbg !149 {
  call void @llvm.sdr.blk.r(i16 0), !dbg !150
  call void @llvm.sdr.actvt.r(i16 28), !dbg !152
  ret void, !dbg !153
}

define void @sys_mod.sys_mod.f_memcpyh2d() #2 !dbg !154 {
  %1 = alloca float, i16 1, align 4, !dbg !155
  %2 = alloca float, i16 1, align 4, !dbg !157
  %3 = alloca i16, i16 1, align 2, !dbg !158
  %4 = alloca i16, i16 1, align 2, !dbg !159
  %5 = alloca i16, i16 1, align 2, !dbg !160
  %6 = alloca i16, i16 1, align 2, !dbg !161
  %7 = alloca i16, i16 1, align 2, !dbg !162
  %8 = alloca i16, i16 1, align 2, !dbg !163
  %9 = alloca i16, i16 1, align 2, !dbg !164
  %10 = alloca i16, i16 1, align 2, !dbg !165
  %11 = alloca i16, i16 1, align 2, !dbg !166
  %12 = alloca i16, i16 1, align 2, !dbg !167
  %13 = alloca i16, i16 1, align 2, !dbg !168
  %14 = alloca i16*, i16 1, align 8, !dbg !169
  %15 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !170
  %16 = icmp eq i16 %15, 15, !dbg !171
  br i1 %16, label %17, label %18, !dbg !172

17:                                               ; preds = %0
  br label %19, !dbg !172

18:                                               ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !172
  br label %19, !dbg !172

19:                                               ; preds = %17, %18
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %14, align 8, !dbg !169
  %20 = load i16*, i16** %14, align 8, !dbg !173
  %21 = load i16, i16* %20, align 2, !dbg !174
  store i16 %21, i16* %13, align 2, !dbg !168
  %22 = load i16*, i16** %14, align 8, !dbg !175
  %23 = getelementptr i16, i16* %22, i16 1, !dbg !176
  %24 = load i16, i16* %23, align 2, !dbg !176
  store i16 %24, i16* %12, align 2, !dbg !167
  %25 = load i16*, i16** %14, align 8, !dbg !177
  %26 = getelementptr i16, i16* %25, i16 2, !dbg !178
  %27 = load i16, i16* %26, align 2, !dbg !178
  store i16 %27, i16* %11, align 2, !dbg !166
  %28 = load i16*, i16** %14, align 8, !dbg !179
  %29 = getelementptr i16, i16* %28, i16 3, !dbg !180
  %30 = load i16, i16* %29, align 2, !dbg !180
  store i16 %30, i16* %10, align 2, !dbg !165
  %31 = load i16*, i16** %14, align 8, !dbg !181
  %32 = getelementptr i16, i16* %31, i16 4, !dbg !182
  %33 = load i16, i16* %32, align 2, !dbg !182
  store i16 %33, i16* %9, align 2, !dbg !164
  %34 = load i16*, i16** %14, align 8, !dbg !183
  %35 = getelementptr i16, i16* %34, i16 5, !dbg !184
  %36 = load i16, i16* %35, align 2, !dbg !184
  store i16 %36, i16* %8, align 2, !dbg !163
  %37 = load i16*, i16** %14, align 8, !dbg !185
  %38 = getelementptr i16, i16* %37, i16 6, !dbg !186
  %39 = load i16, i16* %38, align 2, !dbg !186
  store i16 %39, i16* %7, align 2, !dbg !162
  %40 = load i16*, i16** %14, align 8, !dbg !187
  %41 = getelementptr i16, i16* %40, i16 7, !dbg !188
  %42 = load i16, i16* %41, align 2, !dbg !188
  store i16 %42, i16* %6, align 2, !dbg !161
  %43 = load i16*, i16** %14, align 8, !dbg !189
  %44 = getelementptr i16, i16* %43, i16 8, !dbg !190
  %45 = load i16, i16* %44, align 2, !dbg !190
  store i16 %45, i16* %5, align 2, !dbg !160
  %46 = load i16*, i16** %14, align 8, !dbg !191
  %47 = getelementptr i16, i16* %46, i16 9, !dbg !192
  %48 = load i16, i16* %47, align 2, !dbg !192
  store i16 %48, i16* %4, align 2, !dbg !159
  %49 = load i16*, i16** %14, align 8, !dbg !193
  %50 = getelementptr i16, i16* %49, i16 10, !dbg !194
  %51 = load i16, i16* %50, align 2, !dbg !194
  store i16 %51, i16* %3, align 2, !dbg !158
  %52 = load i16*, i16** %14, align 8, !dbg !195
  %53 = getelementptr i16, i16* %52, i16 12, !dbg !196
  %54 = load i16, i16* %53, align 2, !dbg !196
  %55 = zext i16 %54 to i32, !dbg !197
  %56 = load i16*, i16** %14, align 8, !dbg !198
  %57 = getelementptr i16, i16* %56, i16 11, !dbg !199
  %58 = load i16, i16* %57, align 2, !dbg !199
  %59 = zext i16 %58 to i32, !dbg !200
  %60 = add i32 %59, 16, !dbg !201
  %61 = shl i32 %55, %60, !dbg !202
  %62 = bitcast i32 %61 to float, !dbg !203
  store float %62, float* %2, align 4, !dbg !157
  %63 = load i16*, i16** %14, align 8, !dbg !204
  %64 = getelementptr i16, i16* %63, i16 14, !dbg !205
  %65 = load i16, i16* %64, align 2, !dbg !205
  %66 = zext i16 %65 to i32, !dbg !206
  %67 = load i16*, i16** %14, align 8, !dbg !207
  %68 = getelementptr i16, i16* %67, i16 13, !dbg !208
  %69 = load i16, i16* %68, align 2, !dbg !208
  %70 = zext i16 %69 to i32, !dbg !209
  %71 = add i32 %70, 16, !dbg !210
  %72 = shl i32 %66, %71, !dbg !211
  %73 = bitcast i32 %72 to float, !dbg !212
  store float %73, float* %1, align 4, !dbg !155
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !213
  %74 = load i16, i16* %13, align 2, !dbg !214
  store i16 %74, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !215
  %75 = load i16, i16* %12, align 2, !dbg !216
  store i16 %75, i16* @sys_mod.sys_mod.memcpyH2D_px, align 2, !dbg !217
  %76 = load i16, i16* %11, align 2, !dbg !218
  store i16 %76, i16* @sys_mod.sys_mod.memcpyH2D_py, align 2, !dbg !219
  %77 = load i16, i16* %10, align 2, !dbg !220
  store i16 %77, i16* @sys_mod.sys_mod.memcpyH2D_w, align 2, !dbg !221
  %78 = load i16, i16* %9, align 2, !dbg !222
  store i16 %78, i16* @sys_mod.sys_mod.memcpyH2D_h, align 2, !dbg !223
  %79 = load i16, i16* %8, align 2, !dbg !224
  store i16 %79, i16* @sys_mod.sys_mod.memcpyH2D_addr, align 2, !dbg !225
  %80 = load i16, i16* %7, align 2, !dbg !226
  store i16 %80, i16* @sys_mod.sys_mod.memcpyH2D_pe_length, align 2, !dbg !227
  %81 = load i16, i16* %6, align 2, !dbg !228
  store i16 %81, i16* @sys_mod.sys_mod.memcpyH2D_is_half, align 2, !dbg !229
  %82 = load i16, i16* %5, align 2, !dbg !230
  store i16 %82, i16* @sys_mod.sys_mod.memcpyH2D_memcpy_optype, align 2, !dbg !231
  %83 = load i16, i16* %4, align 2, !dbg !232
  store i16 %83, i16* @sys_mod.sys_mod.memcpyH2D_row_stride, align 2, !dbg !233
  %84 = load i16, i16* %3, align 2, !dbg !234
  store i16 %84, i16* @sys_mod.sys_mod.memcpyH2D_col_stride, align 2, !dbg !235
  %85 = load float, float* %2, align 4, !dbg !236
  store float %85, float* @sys_mod.sys_mod.memcpyH2D_one_over_row_stride, align 4, !dbg !237
  %86 = load float, float* %1, align 4, !dbg !238
  store float %86, float* @sys_mod.sys_mod.memcpyH2D_one_over_col_stride, align 4, !dbg !239
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !240
  call void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 0, i16 23, i1 true), !dbg !241
  call void @llvm.sdr.blk.r(i16 27), !dbg !242
  call void @llvm.sdr.oqflush(i16 0), !dbg !243
  store i1 true, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !244
  call void @llvm.sdr.blk.r(i16 0), !dbg !245
  ret void, !dbg !246
}

define void @sys_mod.sys_mod.f_memcpyd2h() #3 !dbg !247 {
  %1 = alloca i16, i16 1, align 2, !dbg !248
  %2 = alloca i16, i16 1, align 2, !dbg !250
  %3 = alloca i16, i16 1, align 2, !dbg !251
  %4 = alloca i16, i16 1, align 2, !dbg !252
  %5 = alloca i16, i16 1, align 2, !dbg !253
  %6 = alloca i16, i16 1, align 2, !dbg !254
  %7 = alloca i16, i16 1, align 2, !dbg !255
  %8 = alloca i16, i16 1, align 2, !dbg !256
  %9 = alloca i16*, i16 1, align 8, !dbg !257
  %10 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !258
  %11 = icmp eq i16 %10, 8, !dbg !259
  br i1 %11, label %12, label %13, !dbg !260

12:                                               ; preds = %0
  br label %14, !dbg !260

13:                                               ; preds = %0
  call void asm sideeffect "hcf", ""(), !dbg !260
  br label %14, !dbg !260

14:                                               ; preds = %12, %13
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %9, align 8, !dbg !257
  %15 = load i16*, i16** %9, align 8, !dbg !261
  %16 = load i16, i16* %15, align 2, !dbg !262
  store i16 %16, i16* %8, align 2, !dbg !256
  %17 = load i16*, i16** %9, align 8, !dbg !263
  %18 = getelementptr i16, i16* %17, i16 1, !dbg !264
  %19 = load i16, i16* %18, align 2, !dbg !264
  store i16 %19, i16* %7, align 2, !dbg !255
  %20 = load i16*, i16** %9, align 8, !dbg !265
  %21 = getelementptr i16, i16* %20, i16 2, !dbg !266
  %22 = load i16, i16* %21, align 2, !dbg !266
  store i16 %22, i16* %6, align 2, !dbg !254
  %23 = load i16*, i16** %9, align 8, !dbg !267
  %24 = getelementptr i16, i16* %23, i16 3, !dbg !268
  %25 = load i16, i16* %24, align 2, !dbg !268
  store i16 %25, i16* %5, align 2, !dbg !253
  %26 = load i16*, i16** %9, align 8, !dbg !269
  %27 = getelementptr i16, i16* %26, i16 4, !dbg !270
  %28 = load i16, i16* %27, align 2, !dbg !270
  store i16 %28, i16* %4, align 2, !dbg !252
  %29 = load i16*, i16** %9, align 8, !dbg !271
  %30 = getelementptr i16, i16* %29, i16 5, !dbg !272
  %31 = load i16, i16* %30, align 2, !dbg !272
  store i16 %31, i16* %3, align 2, !dbg !251
  %32 = load i16*, i16** %9, align 8, !dbg !273
  %33 = getelementptr i16, i16* %32, i16 6, !dbg !274
  %34 = load i16, i16* %33, align 2, !dbg !274
  store i16 %34, i16* %2, align 2, !dbg !250
  %35 = load i16*, i16** %9, align 8, !dbg !275
  %36 = getelementptr i16, i16* %35, i16 7, !dbg !276
  %37 = load i16, i16* %36, align 2, !dbg !276
  store i16 %37, i16* %1, align 2, !dbg !248
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !277
  %38 = load i16, i16* %8, align 2, !dbg !278
  store i16 %38, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !279
  %39 = load i16, i16* %7, align 2, !dbg !280
  store i16 %39, i16* @sys_mod.sys_mod.memcpyD2H_px, align 2, !dbg !281
  %40 = load i16, i16* %6, align 2, !dbg !282
  store i16 %40, i16* @sys_mod.sys_mod.memcpyD2H_py, align 2, !dbg !283
  %41 = load i16, i16* %5, align 2, !dbg !284
  store i16 %41, i16* @sys_mod.sys_mod.memcpyD2H_w, align 2, !dbg !285
  %42 = load i16, i16* %4, align 2, !dbg !286
  store i16 %42, i16* @sys_mod.sys_mod.memcpyD2H_h, align 2, !dbg !287
  %43 = load i16, i16* %3, align 2, !dbg !288
  store i16 %43, i16* @sys_mod.sys_mod.memcpyD2H_addr, align 2, !dbg !289
  %44 = load i16, i16* %2, align 2, !dbg !290
  store i16 %44, i16* @sys_mod.sys_mod.memcpyD2H_pe_length, align 2, !dbg !291
  %45 = load i16, i16* %1, align 2, !dbg !292
  store i16 %45, i16* @sys_mod.sys_mod.memcpyD2H_is_half, align 2, !dbg !293
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !294
  %46 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !295
  call void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 0, i16 %46, i1 false), !dbg !296
  call void @llvm.sdr.oqflush(i16 0), !dbg !297
  store i1 false, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !298
  ret void, !dbg !299
}

define internal void @sys_mod.sys_mod.oq0_teardow_handler() !dbg !300 {
  %1 = load i1, i1* @sys_mod.sys_mod.is_h2d_cmd, align 1, !dbg !301
  br i1 %1, label %2, label %17, !dbg !303

2:                                                ; preds = %0
  %3 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !304
  call void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 0, i16 %3), !dbg !305
  %4 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_c, align 2, !dbg !306
  %5 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_px, align 2, !dbg !307
  %6 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_py, align 2, !dbg !308
  %7 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_w, align 2, !dbg !309
  %8 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_h, align 2, !dbg !310
  %9 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_addr, align 2, !dbg !311
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_pe_length, align 2, !dbg !312
  %11 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_is_half, align 2, !dbg !313
  %12 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_memcpy_optype, align 2, !dbg !314
  %13 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_row_stride, align 2, !dbg !315
  %14 = load i16, i16* @sys_mod.sys_mod.memcpyH2D_col_stride, align 2, !dbg !316
  %15 = load float, float* @sys_mod.sys_mod.memcpyH2D_one_over_row_stride, align 4, !dbg !317
  %16 = load float, float* @sys_mod.sys_mod.memcpyH2D_one_over_col_stride, align 4, !dbg !318
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure(i16 %4, i16 %5, i16 %6, i16 %7, i16 %8, i16 %9, i16 %10, i16 %11, i16 %12, i16 %13, i16 %14, float %15, float %16), !dbg !319
  br label %26, !dbg !303

17:                                               ; preds = %0
  call void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 0, i16 21), !dbg !320
  %18 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_c, align 2, !dbg !321
  %19 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_px, align 2, !dbg !322
  %20 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_py, align 2, !dbg !323
  %21 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_w, align 2, !dbg !324
  %22 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_h, align 2, !dbg !325
  %23 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_addr, align 2, !dbg !326
  %24 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_pe_length, align 2, !dbg !327
  %25 = load i16, i16* @sys_mod.sys_mod.memcpyD2H_is_half, align 2, !dbg !328
  call void @sys_mod.sys_mod.memcpyd2h_mod.d2h_configure(i16 %18, i16 %19, i16 %20, i16 %21, i16 %22, i16 %23, i16 %24, i16 %25), !dbg !329
  br label %26, !dbg !303

26:                                               ; preds = %2, %17
  call void @__generic0sys_mod.sys_mod.tile_config.queue_flush.exit(), !dbg !330
  ret void, !dbg !303
}

define internal void @rpc_server(i32* %0) {
  %2 = load i32, i32* %0, align 4
  %3 = add i32 %2, 1
  %4 = getelementptr i32, i32* %0, i32 %3
  %5 = load i32, i32* %4, align 4
  switch i32 %5, label %6 [
    i32 14, label %7
    i32 16, label %12
    i32 13, label %17
    i32 15, label %22
  ]

6:                                                ; preds = %1
  br label %27

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
  br label %27

12:                                               ; preds = %1
  %13 = icmp eq i32 0, %2
  br i1 %13, label %14, label %15

14:                                               ; preds = %12
  br label %16

15:                                               ; preds = %12
  call void asm sideeffect "hcf", ""()
  br label %16

16:                                               ; preds = %14, %15
  call void @spmv_dense()
  br label %27

17:                                               ; preds = %1
  %18 = icmp eq i32 0, %2
  br i1 %18, label %19, label %20

19:                                               ; preds = %17
  br label %21

20:                                               ; preds = %17
  call void asm sideeffect "hcf", ""()
  br label %21

21:                                               ; preds = %19, %20
  call void @spmv_scalar()
  br label %27

22:                                               ; preds = %1
  %23 = icmp eq i32 0, %2
  br i1 %23, label %24, label %25

24:                                               ; preds = %22
  br label %26

25:                                               ; preds = %22
  call void asm sideeffect "hcf", ""()
  br label %26

26:                                               ; preds = %24, %25
  call void @spmv_blk()
  br label %27

27:                                               ; preds = %6, %11, %16, %21, %26
  ret void
}

define void @sys_mod.sys_mod.f_rpc(i16 %0) #4 !dbg !331 {
  %2 = alloca i16, i16 1, align 2, !dbg !332
  store i16 %0, i16* %2, align 2, !dbg !332
  call void @sys_mod.sys_mod.sys_mod.block_cmd_stream(), !dbg !334
  %3 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !335
  %4 = icmp sge i16 %3, 4, !dbg !336
  br i1 %4, label %5, label %6, !dbg !337

5:                                                ; preds = %1
  br label %7, !dbg !337

6:                                                ; preds = %1
  call void asm sideeffect "hcf", ""(), !dbg !337
  br label %7, !dbg !337

7:                                                ; preds = %5, %6
  call void @rpc_server(i32* getelementptr inbounds ([32 x i32], [32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32, i32 0, i32 0)), !dbg !338
  store i16 0, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !339
  ret void, !dbg !340
}

define internal void @sys_mod.sys_mod.sys_mod.stack_push(i16 %0) !dbg !341 {
  %2 = alloca i16*, i16 1, align 8, !dbg !343
  %3 = alloca i16, i16 1, align 2, !dbg !345
  store i16 %0, i16* %3, align 2, !dbg !345
  %4 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !346
  %5 = icmp slt i16 %4, 32, !dbg !347
  br i1 %5, label %6, label %7, !dbg !348

6:                                                ; preds = %1
  br label %8, !dbg !348

7:                                                ; preds = %1
  call void asm sideeffect "hcf", ""(), !dbg !348
  br label %8, !dbg !348

8:                                                ; preds = %6, %7
  store i16* bitcast ([32 x i32]* @sys_mod.sys_mod.sys_mod.stack_u32 to i16*), i16** %2, align 8, !dbg !343
  %9 = load i16, i16* %3, align 2, !dbg !349
  %10 = load i16*, i16** %2, align 8, !dbg !350
  %11 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !351
  %12 = getelementptr i16, i16* %10, i16 %11, !dbg !352
  store i16 %9, i16* %12, align 2, !dbg !353
  %13 = load i16, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !354
  %14 = add i16 %13, 1, !dbg !355
  store i16 %14, i16* @sys_mod.sys_mod.sys_mod.stack_last, align 2, !dbg !356
  ret void, !dbg !357
}

define void @sys_mod.sys_mod.sys_mod.f_push(i16 %0, i16 %1) #5 !dbg !358 {
  %3 = alloca i16, i16 1, align 2, !dbg !359
  %4 = alloca i16, i16 1, align 2, !dbg !361
  store i16 %0, i16* %4, align 2, !dbg !361
  store i16 %1, i16* %3, align 2, !dbg !359
  %5 = load i16, i16* %4, align 2, !dbg !362
  call void @sys_mod.sys_mod.sys_mod.stack_push(i16 %5), !dbg !363
  ret void, !dbg !364
}

define internal void @sys_mod.sys_mod.sys_mod.block_cmd_stream() !dbg !365 {
  call void @llvm.sdr.blk.r(i16 1), !dbg !366
  ret void, !dbg !368
}

define internal void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream() !dbg !369 {
  call void @llvm.sdr.ublk.r(i16 1), !dbg !370
  ret void, !dbg !372
}

define void @sys_mod.sys_mod.sys_mod.f_sys_exit() #6 !dbg !373 {
  call void @sys_mod.sys_mod.sys_mod.unblock_cmd_stream(), !dbg !374
  call void @sys_mod.sys_nop(), !dbg !376
  ret void, !dbg !377
}

define void @sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore(i32 %0) #7 !dbg !378 {
  %2 = alloca i32, i16 1, align 4, !dbg !379
  store i32 %0, i32* %2, align 4, !dbg !379
  ret void, !dbg !381
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord() !dbg !382 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord(), !dbg !384
  ret i16 %1, !dbg !386
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord() !dbg !387 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord(), !dbg !388
  ret i16 %1, !dbg !390
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval(i16 %0) !dbg !391 {
  %2 = alloca i16, i16 1, align 2, !dbg !392
  store i16 %0, i16* %2, align 2, !dbg !392
  %3 = load i16, i16* %2, align 2, !dbg !394
  %4 = icmp ult i16 %3, 24, !dbg !395
  br i1 %4, label %5, label %7, !dbg !396

5:                                                ; preds = %10, %11, %1
  %6 = phi i16 [ 0, %10 ], [ 0, %11 ], [ 1, %1 ]
  br label %12, !dbg !396

7:                                                ; preds = %1
  %8 = load i16, i16* %2, align 2, !dbg !397
  %9 = icmp eq i16 31, %8, !dbg !398
  br i1 %9, label %10, label %11, !dbg !399

10:                                               ; preds = %7
  br label %5, !dbg !399

11:                                               ; preds = %7
  call void asm sideeffect "hcf", ""(), !dbg !399
  br label %5, !dbg !399

12:                                               ; preds = %5
  %13 = phi i16 [ %6, %5 ]
  br label %14, !dbg !396

14:                                               ; preds = %12
  ret i16 %13, !dbg !396
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start(i16 %0, i16 %1, i16 %2) !dbg !400 {
  %4 = alloca <{ i16, i16, i16, i16 }>, i16 1, align 8, !dbg !401
  %5 = alloca i16, i16 1, align 2, !dbg !403
  %6 = alloca i16, i16 1, align 2, !dbg !404
  %7 = alloca i16, i16 1, align 2, !dbg !405
  store i16 %0, i16* %7, align 2, !dbg !405
  store i16 %1, i16* %6, align 2, !dbg !404
  store i16 %2, i16* %5, align 2, !dbg !403
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !406
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !406
  %10 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !406
  %11 = load i16, i16* %6, align 2, !dbg !407
  store i16 %11, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !408
  store i16 %8, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !408
  store i16 %9, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !408
  store i16 %10, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !408
  %12 = load i16, i16* %7, align 2, !dbg !409
  %13 = call i16* @.get_tensor_ptr(i16 %12), !dbg !410
  %14 = ptrtoint i16* %13 to i16, !dbg !411
  %15 = lshr i16 %14, 1, !dbg !411
  %16 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !401
  store i16 42, i16* %16, align 2, !dbg !401
  %17 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !401
  store i16 %15, i16* %17, align 2, !dbg !401
  %18 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !401
  store i16 143, i16* %18, align 2, !dbg !401
  %19 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !401
  store i16 16, i16* %19, align 2, !dbg !401
  %20 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !412
  %21 = load i16, i16* %20, align 2, !dbg !412
  %22 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !412
  %23 = load i16, i16* %22, align 2, !dbg !412
  %24 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !412
  %25 = load i16, i16* %24, align 2, !dbg !412
  %26 = load i16, i16* %6, align 2, !dbg !413
  %27 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !414
  store i16 %26, i16* %27, align 2, !dbg !414
  %28 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !414
  store i16 %21, i16* %28, align 2, !dbg !414
  %29 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !414
  store i16 %23, i16* %29, align 2, !dbg !414
  %30 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !414
  store i16 %25, i16* %30, align 2, !dbg !414
  %31 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 0, !dbg !415
  %32 = load i16, i16* %31, align 2, !dbg !415
  %33 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 1, !dbg !415
  %34 = load i16, i16* %33, align 2, !dbg !415
  %35 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 2, !dbg !415
  %36 = load i16, i16* %35, align 2, !dbg !415
  %37 = getelementptr <{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* %4, i32 0, i32 3, !dbg !415
  %38 = load i16, i16* %37, align 2, !dbg !415
  store volatile i16 %32, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !416
  store volatile i16 %34, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !416
  store volatile i16 %36, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !416
  store volatile i16 %38, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !416
  call void asm sideeffect "nop", ""(), !dbg !416
  call void asm sideeffect "nop", ""(), !dbg !416
  %39 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !417
  %40 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !417
  %41 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !417
  %42 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !417
  %43 = and i16 %41, -193, !dbg !417
  %44 = or i16 %43, 128, !dbg !417
  %45 = and i16 %40, -64, !dbg !417
  %46 = or i16 %45, 27, !dbg !417
  store volatile i16 %39, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !418
  store volatile i16 %46, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !418
  store volatile i16 %44, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !418
  store volatile i16 %42, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !418
  call void asm sideeffect "nop", ""(), !dbg !418
  call void asm sideeffect "nop", ""(), !dbg !418
  %47 = load i16, i16* %5, align 2, !dbg !419
  %48 = icmp ult i16 0, %47, !dbg !420
  br i1 %48, label %49, label %50, !dbg !421

49:                                               ; preds = %3
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !422
  br label %51, !dbg !421

50:                                               ; preds = %3
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !423
  br label %51, !dbg !421

51:                                               ; preds = %49, %50
  ret void, !dbg !421
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream() !dbg !424 {
  call void @llvm.sdr.ublk.r(i16 1), !dbg !425
  ret void, !dbg !427
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7, i16 %8, i16 %9, i16 %10, float %11, float %12) !dbg !428 {
  %14 = alloca i16, i16 1, align 2, !dbg !429
  %15 = alloca i16, i16 1, align 2, !dbg !431
  %16 = alloca i16, i16 1, align 2, !dbg !432
  %17 = alloca i16, i16 1, align 2, !dbg !433
  %18 = alloca i16, i16 1, align 2, !dbg !434
  %19 = alloca i1, i16 1, align 1, !dbg !435
  %20 = alloca i16, i16 1, align 2, !dbg !436
  %21 = alloca i16, i16 1, align 2, !dbg !437
  %22 = alloca i16, i16 1, align 2, !dbg !438
  %23 = alloca i16, i16 1, align 2, !dbg !439
  %24 = alloca i16, i16 1, align 2, !dbg !440
  %25 = alloca float, i16 1, align 4, !dbg !441
  %26 = alloca float, i16 1, align 4, !dbg !442
  %27 = alloca i16, i16 1, align 2, !dbg !443
  %28 = alloca i16, i16 1, align 2, !dbg !444
  %29 = alloca i16, i16 1, align 2, !dbg !445
  %30 = alloca i16, i16 1, align 2, !dbg !446
  %31 = alloca i16, i16 1, align 2, !dbg !447
  %32 = alloca i16, i16 1, align 2, !dbg !448
  %33 = alloca i16, i16 1, align 2, !dbg !449
  %34 = alloca i16, i16 1, align 2, !dbg !450
  %35 = alloca i16, i16 1, align 2, !dbg !451
  %36 = alloca i16, i16 1, align 2, !dbg !452
  %37 = alloca i16, i16 1, align 2, !dbg !453
  store i16 %0, i16* %37, align 2, !dbg !453
  store i16 %1, i16* %36, align 2, !dbg !452
  store i16 %2, i16* %35, align 2, !dbg !451
  store i16 %3, i16* %34, align 2, !dbg !450
  store i16 %4, i16* %33, align 2, !dbg !449
  store i16 %5, i16* %32, align 2, !dbg !448
  store i16 %6, i16* %31, align 2, !dbg !447
  store i16 %7, i16* %30, align 2, !dbg !446
  store i16 %8, i16* %29, align 2, !dbg !445
  store i16 %9, i16* %28, align 2, !dbg !444
  store i16 %10, i16* %27, align 2, !dbg !443
  store float %11, float* %26, align 4, !dbg !442
  store float %12, float* %25, align 4, !dbg !441
  %38 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord(), !dbg !454
  store i16 %38, i16* %24, align 2, !dbg !440
  %39 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord(), !dbg !455
  store i16 %39, i16* %23, align 2, !dbg !439
  %40 = load i16, i16* %24, align 2, !dbg !456
  %41 = load i16, i16* %36, align 2, !dbg !457
  %42 = sub i16 %40, %41, !dbg !458
  store i16 %42, i16* %22, align 2, !dbg !438
  %43 = load i16, i16* %22, align 2, !dbg !459
  store i16 %43, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !460
  %44 = load i16, i16* %29, align 2, !dbg !461
  %45 = icmp eq i16 3, %44, !dbg !462
  br i1 %45, label %46, label %63, !dbg !463

46:                                               ; preds = %13
  %47 = load i16, i16* %22, align 2, !dbg !464
  %48 = sitofp i16 %47 to float, !dbg !465
  %49 = load float, float* %26, align 4, !dbg !466
  %50 = fmul float %48, %49, !dbg !467
  %51 = fptosi float %50 to i16, !dbg !468
  store i16 %51, i16* %21, align 2, !dbg !437
  %52 = load i16, i16* %22, align 2, !dbg !469
  %53 = load i16, i16* %21, align 2, !dbg !470
  %54 = load i16, i16* %28, align 2, !dbg !471
  %55 = mul i16 %53, %54, !dbg !472
  %56 = sub i16 %52, %55, !dbg !473
  store i16 %56, i16* %20, align 2, !dbg !436
  %57 = load i16, i16* %20, align 2, !dbg !474
  %58 = icmp ne i16 0, %57, !dbg !475
  br i1 %58, label %59, label %60, !dbg !476

59:                                               ; preds = %46
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !477
  br label %62, !dbg !476

60:                                               ; preds = %46
  %61 = load i16, i16* %21, align 2, !dbg !478
  store i16 %61, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !479
  br label %62, !dbg !476

62:                                               ; preds = %59, %60
  br label %63, !dbg !463

63:                                               ; preds = %62, %13
  %64 = load i16, i16* %22, align 2, !dbg !480
  %65 = icmp slt i16 %64, 0, !dbg !481
  br i1 %65, label %66, label %67, !dbg !482

66:                                               ; preds = %63
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !483
  br label %67, !dbg !482

67:                                               ; preds = %66, %63
  %68 = load i16, i16* %22, align 2, !dbg !484
  %69 = load i16, i16* %34, align 2, !dbg !485
  %70 = icmp sge i16 %68, %69, !dbg !486
  br i1 %70, label %71, label %72, !dbg !487

71:                                               ; preds = %67
  store i16 -1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !488
  br label %72, !dbg !487

72:                                               ; preds = %71, %67
  store i1 false, i1* %19, align 1, !dbg !435
  %73 = load i16, i16* %29, align 2, !dbg !489
  %74 = icmp eq i16 3, %73, !dbg !490
  br i1 %74, label %75, label %94, !dbg !491

75:                                               ; preds = %72
  %76 = load i16, i16* %23, align 2, !dbg !492
  %77 = load i16, i16* %35, align 2, !dbg !493
  %78 = sub i16 %76, %77, !dbg !494
  %79 = sitofp i16 %78 to float, !dbg !495
  %80 = load float, float* %25, align 4, !dbg !496
  %81 = fmul float %79, %80, !dbg !497
  %82 = fptosi float %81 to i16, !dbg !498
  store i16 %82, i16* %18, align 2, !dbg !434
  %83 = load i16, i16* %23, align 2, !dbg !499
  %84 = load i16, i16* %35, align 2, !dbg !500
  %85 = sub i16 %83, %84, !dbg !501
  %86 = load i16, i16* %18, align 2, !dbg !502
  %87 = load i16, i16* %27, align 2, !dbg !503
  %88 = mul i16 %86, %87, !dbg !504
  %89 = sub i16 %85, %88, !dbg !505
  store i16 %89, i16* %17, align 2, !dbg !433
  %90 = load i16, i16* %17, align 2, !dbg !506
  %91 = icmp ne i16 0, %90, !dbg !507
  br i1 %91, label %92, label %93, !dbg !508

92:                                               ; preds = %75
  store i1 true, i1* %19, align 1, !dbg !509
  br label %93, !dbg !508

93:                                               ; preds = %92, %75
  br label %94, !dbg !491

94:                                               ; preds = %93, %72
  %95 = load i16, i16* %23, align 2, !dbg !510
  %96 = load i16, i16* %35, align 2, !dbg !511
  %97 = icmp slt i16 %95, %96, !dbg !512
  br i1 %97, label %98, label %99, !dbg !513

98:                                               ; preds = %94
  store i1 true, i1* %19, align 1, !dbg !514
  br label %99, !dbg !513

99:                                               ; preds = %98, %94
  %100 = load i16, i16* %23, align 2, !dbg !515
  %101 = load i16, i16* %35, align 2, !dbg !516
  %102 = load i16, i16* %33, align 2, !dbg !517
  %103 = add i16 %101, %102, !dbg !518
  %104 = icmp sge i16 %100, %103, !dbg !519
  br i1 %104, label %105, label %106, !dbg !520

105:                                              ; preds = %99
  store i1 true, i1* %19, align 1, !dbg !521
  br label %106, !dbg !520

106:                                              ; preds = %105, %99
  %107 = load i1, i1* %19, align 1, !dbg !522
  br i1 %107, label %108, label %109, !dbg !523

108:                                              ; preds = %106
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream(), !dbg !524
  call void @llvm.sdr.ublk.r(i16 27), !dbg !525
  br label %180, !dbg !523

109:                                              ; preds = %106
  %110 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !526
  %111 = icmp eq i16 -1, %110, !dbg !527
  br i1 %111, label %112, label %113, !dbg !528

112:                                              ; preds = %109
  call void @__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction(i16 31767), !dbg !529
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 23), !dbg !530
  call void @llvm.sdr.ublk.r(i16 27), !dbg !531
  br label %179, !dbg !528

113:                                              ; preds = %109
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter(i16 0, i16 0), !dbg !532
  %114 = load i16, i16* %34, align 2, !dbg !533
  store i16 %114, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !534
  %115 = load i16, i16* %29, align 2, !dbg !535
  %116 = icmp eq i16 3, %115, !dbg !536
  br i1 %116, label %117, label %126, !dbg !537

117:                                              ; preds = %113
  %118 = load i16, i16* %34, align 2, !dbg !538
  %119 = sub i16 %118, 1, !dbg !539
  %120 = sitofp i16 %119 to float, !dbg !540
  %121 = load float, float* %26, align 4, !dbg !541
  %122 = fmul float %120, %121, !dbg !542
  %123 = fptosi float %122 to i16, !dbg !543
  %124 = add i16 %123, 1, !dbg !544
  store i16 %124, i16* %16, align 2, !dbg !432
  %125 = load i16, i16* %16, align 2, !dbg !545
  store i16 %125, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !546
  br label %131, !dbg !537

126:                                              ; preds = %113
  %127 = load i16, i16* %29, align 2, !dbg !547
  %128 = icmp eq i16 1, %127, !dbg !548
  br i1 %128, label %129, label %130, !dbg !549

129:                                              ; preds = %126
  store i16 1, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !550
  br label %130, !dbg !549

130:                                              ; preds = %129, %126
  br label %131, !dbg !537

131:                                              ; preds = %117, %130
  %132 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !551
  %133 = sub i16 %132, 1, !dbg !552
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit(i16 0, i16 %133), !dbg !553
  %134 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.num_receivers, align 2, !dbg !554
  store i16 %134, i16* %15, align 2, !dbg !431
  %135 = load i16, i16* @sys_mod.sys_mod.memcpyh2d_mod_1.receiver_idx, align 2, !dbg !555
  store i16 %135, i16* %14, align 2, !dbg !429
  %136 = load i16, i16* %15, align 2, !dbg !556
  %137 = load i16, i16* %14, align 2, !dbg !557
  %138 = sub i16 %136, %137, !dbg !558
  store i16 %138, i16* %15, align 2, !dbg !559
  %139 = load i16, i16* %14, align 2, !dbg !560
  %140 = icmp eq i16 0, %139, !dbg !561
  br i1 %140, label %141, label %142, !dbg !562

141:                                              ; preds = %131
  store i16 0, i16* %15, align 2, !dbg !563
  br label %142, !dbg !562

142:                                              ; preds = %141, %131
  %143 = load i16, i16* %29, align 2, !dbg !564
  %144 = icmp eq i16 1, %143, !dbg !565
  br i1 %144, label %145, label %146, !dbg !566

145:                                              ; preds = %142
  store i16 0, i16* %15, align 2, !dbg !567
  br label %146, !dbg !566

146:                                              ; preds = %145, %142
  %147 = load i16, i16* %15, align 2, !dbg !568
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter(i16 0, i16 %147), !dbg !569
  call void @__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction(i16 31767), !dbg !570
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 23), !dbg !571
  %148 = load i16, i16* %37, align 2, !dbg !572
  %149 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval(i16 %148), !dbg !573
  %150 = icmp eq i16 0, %149, !dbg !574
  br i1 %150, label %151, label %155, !dbg !575

151:                                              ; preds = %146
  %152 = load i16, i16* %32, align 2, !dbg !576
  %153 = load i16, i16* %31, align 2, !dbg !577
  %154 = load i16, i16* %30, align 2, !dbg !578
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start(i16 %152, i16 %153, i16 %154), !dbg !579
  br label %178, !dbg !575

155:                                              ; preds = %146
  %156 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !580
  %157 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !580
  %158 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !580
  %159 = load i16, i16* %31, align 2, !dbg !581
  store i16 %159, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !582
  store i16 %156, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !582
  store i16 %157, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !582
  store i16 %158, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !582
  %160 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !583
  %161 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !583
  %162 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !583
  %163 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !583
  %164 = and i16 %162, -193, !dbg !583
  %165 = or i16 %164, 128, !dbg !583
  store volatile i16 %160, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !584
  store volatile i16 %161, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !584
  store volatile i16 %165, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !584
  store volatile i16 %163, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !584
  call void asm sideeffect "nop", ""(), !dbg !584
  call void asm sideeffect "nop", ""(), !dbg !584
  %166 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !585
  %167 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !585
  %168 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !585
  %169 = load i16, i16* %31, align 2, !dbg !586
  store i16 %169, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !587
  store i16 %166, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !587
  store i16 %167, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !587
  store i16 %168, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !587
  %170 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !588
  %171 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !588
  %172 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !588
  %173 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyh2d_mod_1.fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !588
  %174 = and i16 %172, -193, !dbg !588
  %175 = or i16 %174, 128, !dbg !588
  %176 = and i16 %171, -64, !dbg !588
  %177 = or i16 %176, 27, !dbg !588
  store volatile i16 %170, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !589
  store volatile i16 %177, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !589
  store volatile i16 %175, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !589
  store volatile i16 %173, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !589
  call void asm sideeffect "nop", ""(), !dbg !589
  call void asm sideeffect "nop", ""(), !dbg !589
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !590
  br label %178, !dbg !575

178:                                              ; preds = %151, %155
  br label %179, !dbg !528

179:                                              ; preds = %112, %178
  br label %180, !dbg !523

180:                                              ; preds = %108, %179
  ret void, !dbg !463
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit(i16 %0, i16 %1) !dbg !591 {
  %3 = alloca i16, i16 1, align 2, !dbg !593
  %4 = alloca i16, i16 1, align 2, !dbg !595
  %5 = alloca i16, i16 1, align 2, !dbg !596
  %6 = alloca i16, i16 1, align 2, !dbg !597
  %7 = alloca i16, i16 1, align 2, !dbg !598
  %8 = alloca i16, i16 1, align 2, !dbg !599
  store i16 %0, i16* %8, align 2, !dbg !599
  store i16 %1, i16* %7, align 2, !dbg !598
  %9 = load i16, i16* %7, align 2, !dbg !600
  %10 = icmp ult i16 %9, -32768, !dbg !601
  br i1 %10, label %11, label %12, !dbg !602

11:                                               ; preds = %2
  br label %13, !dbg !602

12:                                               ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !602
  br label %13, !dbg !602

13:                                               ; preds = %11, %12
  %14 = load i16, i16* %7, align 2, !dbg !603
  %15 = mul i16 %14, 2, !dbg !604
  store i16 %15, i16* %6, align 2, !dbg !597
  %16 = load i16, i16* %8, align 2, !dbg !605
  %17 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %16, i16 8), !dbg !606
  %18 = sub i16 %17, 1, !dbg !607
  store i16 %18, i16* %5, align 2, !dbg !596
  %19 = load i16, i16* %6, align 2, !dbg !608
  %20 = load i16, i16* %5, align 2, !dbg !609
  %21 = icmp ult i16 %19, %20, !dbg !610
  br i1 %21, label %22, label %23, !dbg !595

22:                                               ; preds = %13
  store i16 0, i16* %4, align 2, !dbg !595
  br label %27, !dbg !595

23:                                               ; preds = %13
  %24 = load i16, i16* %6, align 2, !dbg !611
  %25 = load i16, i16* %5, align 2, !dbg !612
  %26 = sub i16 %24, %25, !dbg !613
  store i16 %26, i16* %4, align 2, !dbg !595
  br label %27, !dbg !595

27:                                               ; preds = %22, %23
  %28 = load i16, i16* %4, align 2, !dbg !595
  store i16 %28, i16* %3, align 2, !dbg !593
  %29 = load i16, i16* %8, align 2, !dbg !614
  %30 = load i16, i16* %3, align 2, !dbg !615
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %29, i16 4, i16 %30), !dbg !616
  ret void, !dbg !595
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter(i16 %0, i16 %1) !dbg !617 {
  %3 = alloca i16, i16 1, align 2, !dbg !618
  %4 = alloca i16, i16 1, align 2, !dbg !620
  store i16 %0, i16* %4, align 2, !dbg !620
  store i16 %1, i16* %3, align 2, !dbg !618
  %5 = load i16, i16* %3, align 2, !dbg !621
  %6 = icmp ult i16 %5, -32768, !dbg !622
  br i1 %6, label %7, label %8, !dbg !623

7:                                                ; preds = %2
  br label %9, !dbg !623

8:                                                ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !623
  br label %9, !dbg !623

9:                                                ; preds = %7, %8
  %10 = load i16, i16* %4, align 2, !dbg !624
  %11 = load i16, i16* %3, align 2, !dbg !625
  %12 = mul i16 %11, 2, !dbg !626
  %13 = add i16 %12, 1, !dbg !627
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %10, i16 8, i16 %13), !dbg !628
  ret void, !dbg !629
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter(i16 %0, i16 %1) !dbg !630 {
  %3 = alloca i16, i16 1, align 2, !dbg !631
  %4 = alloca i16, i16 1, align 2, !dbg !633
  %5 = alloca i1, i16 1, align 1, !dbg !634
  %6 = alloca i16, i16 1, align 2, !dbg !635
  %7 = alloca i16, i16 1, align 2, !dbg !636
  %8 = alloca i16, i16 1, align 2, !dbg !637
  %9 = alloca i16, i16 1, align 2, !dbg !638
  store i16 %0, i16* %9, align 2, !dbg !638
  store i16 %1, i16* %8, align 2, !dbg !637
  %10 = load i16, i16* %8, align 2, !dbg !639
  %11 = icmp ult i16 %10, -32768, !dbg !640
  br i1 %11, label %12, label %13, !dbg !641

12:                                               ; preds = %2
  br label %14, !dbg !641

13:                                               ; preds = %2
  call void asm sideeffect "hcf", ""(), !dbg !641
  br label %14, !dbg !641

14:                                               ; preds = %12, %13
  %15 = load i16, i16* %9, align 2, !dbg !642
  %16 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %15, i16 8), !dbg !643
  store i16 %16, i16* %7, align 2, !dbg !636
  %17 = load i16, i16* %8, align 2, !dbg !644
  %18 = mul i16 %17, 2, !dbg !645
  store i16 %18, i16* %6, align 2, !dbg !635
  %19 = load i16, i16* %6, align 2, !dbg !646
  %20 = load i16, i16* %7, align 2, !dbg !647
  %21 = icmp ugt i16 %19, %20, !dbg !648
  store i1 %21, i1* %5, align 1, !dbg !634
  %22 = load i16, i16* %9, align 2, !dbg !649
  %23 = load i1, i1* %5, align 1, !dbg !650
  %24 = zext i1 %23 to i16, !dbg !651
  %25 = shl i16 %24, 6, !dbg !652
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %22, i16 14, i16 %25), !dbg !653
  %26 = load i1, i1* %5, align 1, !dbg !654
  br i1 %26, label %27, label %32, !dbg !633

27:                                               ; preds = %14
  %28 = load i16, i16* %6, align 2, !dbg !655
  %29 = load i16, i16* %7, align 2, !dbg !656
  %30 = sub i16 %28, %29, !dbg !657
  %31 = add i16 %30, 1, !dbg !658
  store i16 %31, i16* %4, align 2, !dbg !633
  br label %34, !dbg !633

32:                                               ; preds = %14
  %33 = load i16, i16* %6, align 2, !dbg !659
  store i16 %33, i16* %4, align 2, !dbg !633
  br label %34, !dbg !633

34:                                               ; preds = %27, %32
  %35 = load i16, i16* %4, align 2, !dbg !633
  store i16 %35, i16* %3, align 2, !dbg !631
  %36 = load i16, i16* %9, align 2, !dbg !660
  %37 = load i16, i16* %3, align 2, !dbg !661
  call void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %36, i16 12, i16 %37), !dbg !662
  ret void, !dbg !633
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config(i16 %0, i16 %1, i16 %2) !dbg !663 {
  %4 = alloca i16, i16 1, align 2, !dbg !665
  %5 = alloca i16, i16 1, align 2, !dbg !667
  %6 = alloca i16, i16 1, align 2, !dbg !668
  store i16 %0, i16* %6, align 2, !dbg !668
  store i16 %1, i16* %5, align 2, !dbg !667
  store i16 %2, i16* %4, align 2, !dbg !665
  %7 = load i16, i16* %6, align 2, !dbg !669
  %8 = getelementptr [6 x i16], [6 x i16]* @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.filters, i16 0, i16 %7, !dbg !670
  %9 = load i16, i16* %8, align 2, !dbg !670
  %10 = load i16, i16* %5, align 2, !dbg !671
  %11 = add i16 %9, %10, !dbg !672
  %12 = lshr i16 %11, 1, !dbg !673
  %13 = load i16, i16* %4, align 2, !dbg !674
  %14 = shl i16 %12, 1, !dbg !675
  %15 = inttoptr i16 %14 to i16*, !dbg !675
  store volatile i16 %13, i16* %15, align 2, !dbg !675
  call void asm sideeffect "nop", ""(), !dbg !675
  call void asm sideeffect "nop", ""(), !dbg !675
  ret void, !dbg !676
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config(i16 %0, i16 %1) !dbg !677 {
  %3 = alloca i16, i16 1, align 2, !dbg !678
  %4 = alloca i16, i16 1, align 2, !dbg !680
  store i16 %0, i16* %4, align 2, !dbg !680
  store i16 %1, i16* %3, align 2, !dbg !678
  %5 = load i16, i16* %4, align 2, !dbg !681
  %6 = getelementptr [6 x i16], [6 x i16]* @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.filters, i16 0, i16 %5, !dbg !682
  %7 = load i16, i16* %6, align 2, !dbg !682
  %8 = load i16, i16* %3, align 2, !dbg !683
  %9 = add i16 %7, %8, !dbg !684
  %10 = lshr i16 %9, 1, !dbg !685
  %11 = shl i16 %10, 1, !dbg !686
  %12 = inttoptr i16 %11 to i16*, !dbg !686
  call void asm sideeffect "nop", ""(), !dbg !686
  call void asm sideeffect "nop", ""(), !dbg !686
  %13 = load volatile i16, i16* %12, align 2, !dbg !686
  ret i16 %13, !dbg !687
}

define internal void @sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit(i16 %0) !dbg !688 {
  %2 = alloca i16, i16 1, align 2, !dbg !690
  %3 = alloca i16, i16 1, align 2, !dbg !692
  %4 = alloca i16, i16 1, align 2, !dbg !693
  %5 = alloca i16, i16 1, align 2, !dbg !694
  store i16 %0, i16* %5, align 2, !dbg !694
  %6 = load i16, i16* %5, align 2, !dbg !695
  store i16 %6, i16* %4, align 2, !dbg !693
  %7 = load i16, i16* %4, align 2, !dbg !696
  %8 = add i16 %7, 31744, !dbg !697
  store i16 %8, i16* %3, align 2, !dbg !692
  %9 = load i16, i16* %3, align 2, !dbg !698
  %10 = shl i16 %9, 1, !dbg !699
  %11 = inttoptr i16 %10 to i16*, !dbg !699
  call void asm sideeffect "nop", ""(), !dbg !699
  call void asm sideeffect "nop", ""(), !dbg !699
  %12 = load volatile i16, i16* %11, align 2, !dbg !699
  store i16 %12, i16* %2, align 2, !dbg !690
  %13 = load i16, i16* %3, align 2, !dbg !700
  %14 = load i16, i16* %2, align 2, !dbg !701
  %15 = and i16 %14, 32767, !dbg !702
  %16 = shl i16 %13, 1, !dbg !703
  %17 = inttoptr i16 %16 to i16*, !dbg !703
  store volatile i16 %15, i16* %17, align 2, !dbg !703
  call void asm sideeffect "nop", ""(), !dbg !703
  call void asm sideeffect "nop", ""(), !dbg !703
  ret void, !dbg !704
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord() !dbg !705 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 2), !dbg !707
  %2 = sub i16 %1, 4, !dbg !709
  ret i16 %2, !dbg !710
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord() !dbg !711 {
  %1 = call i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 0), !dbg !712
  %2 = sub i16 %1, 1, !dbg !714
  ret i16 %2, !dbg !715
}

define internal i16 @sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord(i16 %0) !dbg !716 {
  %2 = alloca i16, i16 1, align 2, !dbg !718
  %3 = alloca i16, i16 1, align 2, !dbg !720
  store i16 %0, i16* %3, align 2, !dbg !720
  %4 = load i16, i16* %3, align 2, !dbg !721
  %5 = lshr i16 %4, 1, !dbg !722
  %6 = add i16 %5, 31813, !dbg !723
  %7 = shl i16 %6, 1, !dbg !724
  %8 = inttoptr i16 %7 to i16*, !dbg !724
  call void asm sideeffect "nop", ""(), !dbg !724
  call void asm sideeffect "nop", ""(), !dbg !724
  %9 = load volatile i16, i16* %8, align 2, !dbg !724
  store i16 %9, i16* %2, align 2, !dbg !718
  %10 = load i16, i16* %2, align 2, !dbg !725
  %11 = and i16 %10, 2047, !dbg !726
  ret i16 %11, !dbg !727
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord() !dbg !728 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord(), !dbg !730
  ret i16 %1, !dbg !732
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.get_y_coord() !dbg !733 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord(), !dbg !734
  ret i16 %1, !dbg !736
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval(i16 %0) !dbg !737 {
  %2 = alloca i16, i16 1, align 2, !dbg !738
  store i16 %0, i16* %2, align 2, !dbg !738
  %3 = load i16, i16* %2, align 2, !dbg !740
  %4 = icmp ult i16 %3, 24, !dbg !741
  br i1 %4, label %5, label %7, !dbg !742

5:                                                ; preds = %10, %11, %1
  %6 = phi i16 [ 0, %10 ], [ 0, %11 ], [ 1, %1 ]
  br label %12, !dbg !742

7:                                                ; preds = %1
  %8 = load i16, i16* %2, align 2, !dbg !743
  %9 = icmp eq i16 31, %8, !dbg !744
  br i1 %9, label %10, label %11, !dbg !745

10:                                               ; preds = %7
  br label %5, !dbg !745

11:                                               ; preds = %7
  call void asm sideeffect "hcf", ""(), !dbg !745
  br label %5, !dbg !745

12:                                               ; preds = %5
  %13 = phi i16 [ %6, %5 ]
  br label %14, !dbg !742

14:                                               ; preds = %12
  ret i16 %13, !dbg !742
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7) !dbg !746 {
  %9 = alloca i16, i16 1, align 2, !dbg !747
  %10 = alloca i16, i16 1, align 2, !dbg !749
  %11 = alloca i16, i16 1, align 2, !dbg !750
  %12 = alloca i16, i16 1, align 2, !dbg !751
  %13 = alloca i16, i16 1, align 2, !dbg !752
  %14 = alloca i16, i16 1, align 2, !dbg !753
  %15 = alloca i16, i16 1, align 2, !dbg !754
  %16 = alloca i16, i16 1, align 2, !dbg !755
  %17 = alloca i16, i16 1, align 2, !dbg !756
  store i16 %0, i16* %17, align 2, !dbg !756
  store i16 %1, i16* %16, align 2, !dbg !755
  store i16 %2, i16* %15, align 2, !dbg !754
  store i16 %3, i16* %14, align 2, !dbg !753
  store i16 %4, i16* %13, align 2, !dbg !752
  store i16 %5, i16* %12, align 2, !dbg !751
  store i16 %6, i16* %11, align 2, !dbg !750
  store i16 %7, i16* %10, align 2, !dbg !749
  %18 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !757
  store i16 %18, i16* %9, align 2, !dbg !747
  %19 = load i16, i16* %11, align 2, !dbg !758
  store i16 %19, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_c, align 2, !dbg !759
  %20 = load i16, i16* %10, align 2, !dbg !760
  store i16 %20, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_is_half, align 2, !dbg !761
  %21 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_c, align 2, !dbg !762
  %22 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval(i16 %21), !dbg !763
  store i16 %22, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !764
  store i16 0, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !765
  %23 = load i16, i16* %16, align 2, !dbg !766
  store i16 %23, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !767
  %24 = load i16, i16* %15, align 2, !dbg !768
  store i16 %24, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !769
  %25 = load i16, i16* %15, align 2, !dbg !770
  %26 = load i16, i16* %13, align 2, !dbg !771
  %27 = add i16 %25, %26, !dbg !772
  %28 = sub i16 %27, 1, !dbg !773
  store i16 %28, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_last, align 2, !dbg !774
  %29 = load i16, i16* %9, align 2, !dbg !775
  %30 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_last, align 2, !dbg !776
  %31 = icmp eq i16 %29, %30, !dbg !777
  br i1 %31, label %32, label %37, !dbg !778

32:                                               ; preds = %8
  %33 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !779
  %34 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !779
  %35 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !779
  store i16 %33, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !780
  store i16 lshr (i16 ptrtoint ([1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.ctrl_1 to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !780
  store i16 %34, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !780
  store i16 %35, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !780
  %36 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.ctrl_1, i16 0, i1 false), align 4, !dbg !781
  store i32 %36, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$8$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i1 false), align 4, !dbg !782
  br label %42, !dbg !778

37:                                               ; preds = %8
  %38 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !783
  %39 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !783
  %40 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !783
  store i16 %38, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !784
  store i16 lshr (i16 ptrtoint ([1 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11" to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !784
  store i16 %39, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !784
  store i16 %40, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !784
  %41 = load i32, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @"$$csl_base_address$$4$$sys_mod.sys_mod.memcpyd2h_mod.ctrl_11", i16 0, i1 false), align 4, !dbg !785
  store i32 %41, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$8$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i1 false), align 4, !dbg !786
  br label %42, !dbg !778

42:                                               ; preds = %32, %37
  store i32 165646921, i32* getelementptr inbounds ([2 x i32], [2 x i32]* @"$$csl_base_address$$8$$sys_mod.sys_mod.memcpyd2h_mod.sw_td", i16 0, i2 1), align 4, !dbg !787
  %43 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !788
  %44 = icmp eq i16 0, %43, !dbg !789
  br i1 %44, label %45, label %56, !dbg !790

45:                                               ; preds = %42
  %46 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !791
  %47 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !791
  %48 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !791
  %49 = load i16, i16* %17, align 2, !dbg !792
  %50 = call i16* @.get_tensor_ptr(i16 %49), !dbg !793
  %51 = ptrtoint i16* %50 to i16, !dbg !794
  %52 = lshr i16 %51, 1, !dbg !794
  store i16 %46, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !795
  store i16 %52, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !795
  store i16 %47, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !795
  store i16 %48, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !795
  %53 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !796
  %54 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !796
  %55 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !796
  store i16 1, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !797
  store i16 %53, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !797
  store i16 %54, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !797
  store i16 %55, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !797
  call void @llvm.sdr.actvt.r(i16 21), !dbg !798
  br label %63, !dbg !790

56:                                               ; preds = %42
  %57 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !799
  %58 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !799
  %59 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !799
  store i16 %57, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !800
  store i16 lshr (i16 ptrtoint ([1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.data_buf to i16), i16 1), i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !800
  store i16 %58, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !800
  store i16 %59, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !800
  %60 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !801
  %61 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !801
  %62 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !801
  store i16 1, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !802
  store i16 %60, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !802
  store i16 %61, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !802
  store i16 %62, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !802
  call void @llvm.sdr.ublk.r(i16 0), !dbg !803
  br label %63, !dbg !790

63:                                               ; preds = %45, %56
  ret void, !dbg !778
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x(i32 %0) #8 !dbg !804 {
  %2 = alloca i32, i16 1, align 4, !dbg !805
  store i32 %0, i32* %2, align 4, !dbg !805
  call void @llvm.sdr.blk.r(i16 0), !dbg !807
  %3 = load i32, i32* %2, align 4, !dbg !808
  store i32 %3, i32* getelementptr inbounds ([1 x i32], [1 x i32]* @sys_mod.sys_mod.memcpyd2h_mod.data_buf, i16 0, i1 false), align 4, !dbg !809
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__1 to i8*)), !dbg !810
  %4 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !811
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !811
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !811
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !811
  store volatile i16 %4, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !812
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !812
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !812
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !812
  call void asm sideeffect "nop", ""(), !dbg !812
  call void asm sideeffect "nop", ""(), !dbg !812
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !813
  %8 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !814
  %9 = add i16 %8, 1, !dbg !815
  store i16 %9, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !816
  ret void, !dbg !817
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_send_data() #9 !dbg !818 {
  %1 = alloca i16, i16 1, align 2, !dbg !819
  %2 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !821
  %3 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !822
  %4 = icmp ult i16 %2, %3, !dbg !823
  br i1 %4, label %5, label %27, !dbg !824

5:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__1 to i8*)), !dbg !825
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !826
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !826
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !826
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !826
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !827
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !827
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !827
  store volatile i16 %9, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !827
  call void asm sideeffect "nop", ""(), !dbg !827
  call void asm sideeffect "nop", ""(), !dbg !827
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.memcpyD2H_is_half, align 2, !dbg !828
  %11 = icmp ult i16 0, %10, !dbg !829
  br i1 %11, label %12, label %18, !dbg !830

12:                                               ; preds = %5
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !831
  %13 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !832
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !832
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !832
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !832
  %17 = add i16 %14, 1, !dbg !833
  store i16 %13, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !834
  store i16 %17, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !834
  store i16 %15, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !834
  store i16 %16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !834
  br label %24, !dbg !830

18:                                               ; preds = %5
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !835
  %19 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !836
  %20 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !836
  %21 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !836
  %22 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !836
  %23 = add i16 %20, 2, !dbg !837
  store i16 %19, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 0), align 2, !dbg !838
  store i16 %23, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 1), align 2, !dbg !838
  store i16 %21, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 2), align 2, !dbg !838
  store i16 %22, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_x_buf_dsd, i32 0, i32 3), align 2, !dbg !838
  br label %24, !dbg !830

24:                                               ; preds = %12, %18
  %25 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !839
  %26 = add i16 %25, 1, !dbg !840
  store i16 %26, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !841
  br label %34, !dbg !824

27:                                               ; preds = %0
  %28 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !842
  store i16 %28, i16* %1, align 2, !dbg !819
  %29 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !843
  %30 = load i16, i16* %1, align 2, !dbg !844
  %31 = icmp eq i16 %29, %30, !dbg !845
  br i1 %31, label %32, label %33, !dbg !846

32:                                               ; preds = %27
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__2 to i8*)), !dbg !847
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__3 to i8*)), !dbg !848
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !849
  br label %33, !dbg !846

33:                                               ; preds = %32, %27
  br label %34, !dbg !824

34:                                               ; preds = %24, %33
  ret void, !dbg !824
}

define void @sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl() #10 !dbg !850 {
  %1 = alloca i16, i16 1, align 2, !dbg !851
  %2 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.is_streaming, align 2, !dbg !853
  %3 = icmp eq i16 0, %2, !dbg !854
  br i1 %3, label %4, label %9, !dbg !855

4:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__4 to i8*)), !dbg !856
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !857
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !857
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !857
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !857
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !858
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !858
  store volatile i16 %7, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !858
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !858
  call void asm sideeffect "nop", ""(), !dbg !858
  call void asm sideeffect "nop", ""(), !dbg !858
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !859
  br label %31, !dbg !855

9:                                                ; preds = %0
  %10 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.j, align 2, !dbg !860
  %11 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.pe_length, align 2, !dbg !861
  %12 = icmp ult i16 %10, %11, !dbg !862
  br i1 %12, label %13, label %18, !dbg !863

13:                                               ; preds = %9
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__5 to i8*)), !dbg !864
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !865
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !865
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !865
  %17 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !865
  store volatile i16 %14, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !866
  store volatile i16 %15, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !866
  store volatile i16 %16, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !866
  store volatile i16 %17, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !866
  call void asm sideeffect "nop", ""(), !dbg !866
  call void asm sideeffect "nop", ""(), !dbg !866
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !867
  br label %30, !dbg !863

18:                                               ; preds = %9
  %19 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !868
  store i16 %19, i16* %1, align 2, !dbg !851
  %20 = load i16, i16* @sys_mod.sys_mod.memcpyd2h_mod.x_first, align 2, !dbg !869
  %21 = load i16, i16* %1, align 2, !dbg !870
  %22 = icmp eq i16 %20, %21, !dbg !871
  br i1 %22, label %23, label %24, !dbg !872

23:                                               ; preds = %18
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__6 to i8*)), !dbg !873
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__7 to i8*)), !dbg !874
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !875
  br label %29, !dbg !872

24:                                               ; preds = %18
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__2 to i8*)), !dbg !876
  %25 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 0), align 2, !dbg !877
  %26 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 1), align 2, !dbg !877
  %27 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 2), align 2, !dbg !877
  %28 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @sys_mod.sys_mod.memcpyd2h_mod.mem_ctrl_buf_dsd, i32 0, i32 3), align 2, !dbg !877
  store volatile i16 %25, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 0), align 2, !dbg !878
  store volatile i16 %26, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 1), align 2, !dbg !878
  store volatile i16 %27, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 2), align 2, !dbg !878
  store volatile i16 %28, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 0, i32 3), align 2, !dbg !878
  call void asm sideeffect "nop", ""(), !dbg !878
  call void asm sideeffect "nop", ""(), !dbg !878
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !879
  br label %29, !dbg !872

29:                                               ; preds = %23, %24
  br label %30, !dbg !863

30:                                               ; preds = %13, %29
  br label %31, !dbg !855

31:                                               ; preds = %4, %30
  ret void, !dbg !855
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.d2h_configure(i16 %0, i16 %1, i16 %2, i16 %3, i16 %4, i16 %5, i16 %6, i16 %7) !dbg !880 {
  %9 = alloca i1, i16 1, align 1, !dbg !881
  %10 = alloca i1, i16 1, align 1, !dbg !883
  %11 = alloca i1, i16 1, align 1, !dbg !884
  %12 = alloca i16, i16 1, align 2, !dbg !885
  %13 = alloca i16, i16 1, align 2, !dbg !886
  %14 = alloca i16, i16 1, align 2, !dbg !887
  %15 = alloca i16, i16 1, align 2, !dbg !888
  %16 = alloca i16, i16 1, align 2, !dbg !889
  %17 = alloca i16, i16 1, align 2, !dbg !890
  %18 = alloca i16, i16 1, align 2, !dbg !891
  %19 = alloca i16, i16 1, align 2, !dbg !892
  %20 = alloca i16, i16 1, align 2, !dbg !893
  %21 = alloca i16, i16 1, align 2, !dbg !894
  %22 = alloca i16, i16 1, align 2, !dbg !895
  %23 = alloca i16, i16 1, align 2, !dbg !896
  %24 = alloca i16, i16 1, align 2, !dbg !897
  %25 = alloca i16, i16 1, align 2, !dbg !898
  store i16 %0, i16* %25, align 2, !dbg !898
  store i16 %1, i16* %24, align 2, !dbg !897
  store i16 %2, i16* %23, align 2, !dbg !896
  store i16 %3, i16* %22, align 2, !dbg !895
  store i16 %4, i16* %21, align 2, !dbg !894
  store i16 %5, i16* %20, align 2, !dbg !893
  store i16 %6, i16* %19, align 2, !dbg !892
  store i16 %7, i16* %18, align 2, !dbg !891
  %26 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_x_coord(), !dbg !899
  store i16 %26, i16* %17, align 2, !dbg !890
  %27 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.get_y_coord(), !dbg !900
  store i16 %27, i16* %16, align 2, !dbg !889
  %28 = load i16, i16* %24, align 2, !dbg !901
  store i16 %28, i16* %15, align 2, !dbg !888
  %29 = load i16, i16* %24, align 2, !dbg !902
  %30 = load i16, i16* %22, align 2, !dbg !903
  %31 = add i16 %29, %30, !dbg !904
  %32 = sub i16 %31, 1, !dbg !905
  store i16 %32, i16* %14, align 2, !dbg !887
  %33 = load i16, i16* %23, align 2, !dbg !906
  store i16 %33, i16* %13, align 2, !dbg !886
  %34 = load i16, i16* %23, align 2, !dbg !907
  %35 = load i16, i16* %21, align 2, !dbg !908
  %36 = add i16 %34, %35, !dbg !909
  %37 = sub i16 %36, 1, !dbg !910
  store i16 %37, i16* %12, align 2, !dbg !885
  store i1 false, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !911
  %38 = load i16, i16* %17, align 2, !dbg !912
  %39 = load i16, i16* %15, align 2, !dbg !913
  %40 = icmp sge i16 %38, %39, !dbg !914
  br i1 %40, label %41, label %45, !dbg !884

41:                                               ; preds = %8
  %42 = load i16, i16* %16, align 2, !dbg !915
  %43 = load i16, i16* %12, align 2, !dbg !916
  %44 = icmp sle i16 %42, %43, !dbg !917
  store i1 %44, i1* %11, align 1, !dbg !884
  br label %46, !dbg !884

45:                                               ; preds = %8
  store i1 false, i1* %11, align 1, !dbg !884
  br label %46, !dbg !884

46:                                               ; preds = %41, %45
  %47 = load i1, i1* %11, align 1, !dbg !884
  br i1 %47, label %48, label %52, !dbg !883

48:                                               ; preds = %46
  %49 = load i16, i16* %16, align 2, !dbg !918
  %50 = load i16, i16* %13, align 2, !dbg !919
  %51 = icmp sge i16 %49, %50, !dbg !920
  store i1 %51, i1* %10, align 1, !dbg !883
  br label %53, !dbg !883

52:                                               ; preds = %46
  store i1 false, i1* %10, align 1, !dbg !883
  br label %53, !dbg !883

53:                                               ; preds = %48, %52
  %54 = load i1, i1* %10, align 1, !dbg !883
  br i1 %54, label %55, label %56, !dbg !921

55:                                               ; preds = %53
  store i1 true, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !922
  br label %56, !dbg !921

56:                                               ; preds = %55, %53
  store i1 false, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !923
  %57 = load i16, i16* %17, align 2, !dbg !924
  %58 = load i16, i16* %14, align 2, !dbg !925
  %59 = icmp sle i16 %57, %58, !dbg !926
  br i1 %59, label %60, label %62, !dbg !881

60:                                               ; preds = %56
  %61 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !927
  store i1 %61, i1* %9, align 1, !dbg !881
  br label %63, !dbg !881

62:                                               ; preds = %56
  store i1 false, i1* %9, align 1, !dbg !881
  br label %63, !dbg !881

63:                                               ; preds = %60, %62
  %64 = load i1, i1* %9, align 1, !dbg !881
  br i1 %64, label %65, label %66, !dbg !928

65:                                               ; preds = %63
  store i1 true, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !929
  br label %66, !dbg !928

66:                                               ; preds = %65, %63
  %67 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.routing_active, align 1, !dbg !930
  br i1 %67, label %68, label %86, !dbg !931

68:                                               ; preds = %66
  call void @__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position(i16 31959), !dbg !932
  %69 = load i16, i16* %15, align 2, !dbg !933
  %70 = load i16, i16* %17, align 2, !dbg !934
  %71 = icmp eq i16 %69, %70, !dbg !935
  br i1 %71, label %72, label %73, !dbg !936

72:                                               ; preds = %68
  call void @__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 31765), !dbg !937
  br label %74, !dbg !936

73:                                               ; preds = %68
  call void @__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 31765), !dbg !938
  br label %74, !dbg !936

74:                                               ; preds = %72, %73
  call void @sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit(i16 21), !dbg !939
  %75 = load i1, i1* @sys_mod.sys_mod.memcpyd2h_mod.is_active, align 1, !dbg !940
  br i1 %75, label %76, label %85, !dbg !941

76:                                               ; preds = %74
  %77 = load i16, i16* %20, align 2, !dbg !942
  %78 = load i16, i16* %19, align 2, !dbg !943
  %79 = load i16, i16* %24, align 2, !dbg !944
  %80 = load i16, i16* %23, align 2, !dbg !945
  %81 = load i16, i16* %22, align 2, !dbg !946
  %82 = load i16, i16* %21, align 2, !dbg !947
  %83 = load i16, i16* %25, align 2, !dbg !948
  %84 = load i16, i16* %18, align 2, !dbg !949
  call void @sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start(i16 %77, i16 %78, i16 %79, i16 %80, i16 %81, i16 %82, i16 %83, i16 %84), !dbg !950
  br label %85, !dbg !941

85:                                               ; preds = %76, %74
  br label %87, !dbg !931

86:                                               ; preds = %66
  call void @llvm.sdr.actvt.r(i16 28), !dbg !951
  br label %87, !dbg !931

87:                                               ; preds = %85, %86
  ret void, !dbg !884
}

define internal void @sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit(i16 %0) !dbg !952 {
  %2 = alloca i16, i16 1, align 2, !dbg !953
  %3 = alloca i16, i16 1, align 2, !dbg !955
  %4 = alloca i16, i16 1, align 2, !dbg !956
  %5 = alloca i16, i16 1, align 2, !dbg !957
  store i16 %0, i16* %5, align 2, !dbg !957
  %6 = load i16, i16* %5, align 2, !dbg !958
  store i16 %6, i16* %4, align 2, !dbg !956
  %7 = load i16, i16* %4, align 2, !dbg !959
  %8 = add i16 %7, 31744, !dbg !960
  store i16 %8, i16* %3, align 2, !dbg !955
  %9 = load i16, i16* %3, align 2, !dbg !961
  %10 = shl i16 %9, 1, !dbg !962
  %11 = inttoptr i16 %10 to i16*, !dbg !962
  call void asm sideeffect "nop", ""(), !dbg !962
  call void asm sideeffect "nop", ""(), !dbg !962
  %12 = load volatile i16, i16* %11, align 2, !dbg !962
  store i16 %12, i16* %2, align 2, !dbg !953
  %13 = load i16, i16* %3, align 2, !dbg !963
  %14 = load i16, i16* %2, align 2, !dbg !964
  %15 = and i16 %14, 32767, !dbg !965
  %16 = shl i16 %13, 1, !dbg !966
  %17 = inttoptr i16 %16 to i16*, !dbg !966
  store volatile i16 %15, i16* %17, align 2, !dbg !966
  call void asm sideeffect "nop", ""(), !dbg !966
  call void asm sideeffect "nop", ""(), !dbg !966
  ret void, !dbg !967
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord() !dbg !968 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 2), !dbg !969
  %2 = sub i16 %1, 4, !dbg !971
  ret i16 %2, !dbg !972
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord() !dbg !973 {
  %1 = call i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 0), !dbg !974
  %2 = sub i16 %1, 1, !dbg !976
  ret i16 %2, !dbg !977
}

define internal i16 @sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord(i16 %0) !dbg !978 {
  %2 = alloca i16, i16 1, align 2, !dbg !979
  %3 = alloca i16, i16 1, align 2, !dbg !981
  store i16 %0, i16* %3, align 2, !dbg !981
  %4 = load i16, i16* %3, align 2, !dbg !982
  %5 = lshr i16 %4, 1, !dbg !983
  %6 = add i16 %5, 31813, !dbg !984
  %7 = shl i16 %6, 1, !dbg !985
  %8 = inttoptr i16 %7 to i16*, !dbg !985
  call void asm sideeffect "nop", ""(), !dbg !985
  call void asm sideeffect "nop", ""(), !dbg !985
  %9 = load volatile i16, i16* %8, align 2, !dbg !985
  store i16 %9, i16* %2, align 2, !dbg !979
  %10 = load i16, i16* %2, align 2, !dbg !986
  %11 = and i16 %10, 2047, !dbg !987
  ret i16 %11, !dbg !988
}

define internal i16 @sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr(i16 %0) !dbg !989 {
  %2 = alloca i16, i16 1, align 2, !dbg !991
  store i16 %0, i16* %2, align 2, !dbg !991
  %3 = load i16, i16* %2, align 2, !dbg !993
  %4 = mul i16 %3, 2, !dbg !994
  %5 = add i16 %4, 31680, !dbg !995
  ret i16 %5, !dbg !996
}

define internal void @sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue(i16 %0, i16 %1, i1 %2) !dbg !997 {
  %4 = alloca i16, i16 1, align 2, !dbg !998
  %5 = alloca i16, i16 1, align 2, !dbg !1000
  %6 = alloca i1, i16 1, align 1, !dbg !1001
  %7 = alloca i16, i16 1, align 2, !dbg !1002
  %8 = alloca i16, i16 1, align 2, !dbg !1003
  store i16 %0, i16* %8, align 2, !dbg !1003
  store i16 %1, i16* %7, align 2, !dbg !1002
  store i1 %2, i1* %6, align 1, !dbg !1001
  %9 = load i16, i16* %8, align 2, !dbg !1004
  %10 = call i16 @sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr(i16 %9), !dbg !1005
  store i16 %10, i16* %5, align 2, !dbg !1000
  %11 = load i16, i16* %5, align 2, !dbg !1006
  %12 = shl i16 %11, 1, !dbg !1007
  %13 = inttoptr i16 %12 to i16*, !dbg !1007
  call void asm sideeffect "nop", ""(), !dbg !1007
  call void asm sideeffect "nop", ""(), !dbg !1007
  call void asm sideeffect "nop", ""(), !dbg !1007
  call void asm sideeffect "nop", ""(), !dbg !1007
  %14 = load volatile i16, i16* %13, align 2, !dbg !1007
  store i16 %14, i16* %4, align 2, !dbg !998
  %15 = load i1, i1* %6, align 1, !dbg !1008
  br i1 %15, label %16, label %19, !dbg !1009

16:                                               ; preds = %3
  %17 = load i16, i16* %4, align 2, !dbg !1010
  %18 = or i16 %17, 2048, !dbg !1011
  store i16 %18, i16* %4, align 2, !dbg !1012
  br label %22, !dbg !1009

19:                                               ; preds = %3
  %20 = load i16, i16* %4, align 2, !dbg !1013
  %21 = and i16 %20, -2049, !dbg !1014
  store i16 %21, i16* %4, align 2, !dbg !1015
  br label %22, !dbg !1009

22:                                               ; preds = %16, %19
  %23 = load i16, i16* %4, align 2, !dbg !1016
  %24 = and i16 %23, -32, !dbg !1017
  store i16 %24, i16* %4, align 2, !dbg !1018
  %25 = load i16, i16* %4, align 2, !dbg !1019
  %26 = load i16, i16* %7, align 2, !dbg !1020
  %27 = add i16 %25, %26, !dbg !1021
  store i16 %27, i16* %4, align 2, !dbg !1022
  %28 = load i16, i16* %5, align 2, !dbg !1023
  %29 = load i16, i16* %4, align 2, !dbg !1024
  %30 = shl i16 %28, 1, !dbg !1025
  %31 = inttoptr i16 %30 to i16*, !dbg !1025
  store volatile i16 %29, i16* %31, align 2, !dbg !1025
  call void asm sideeffect "nop", ""(), !dbg !1025
  call void asm sideeffect "nop", ""(), !dbg !1025
  call void asm sideeffect "nop", ""(), !dbg !1025
  call void asm sideeffect "nop", ""(), !dbg !1025
  ret void, !dbg !1009
}

define internal i16 @sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr(i16 %0) !dbg !1026 {
  %2 = alloca i16, i16 1, align 2, !dbg !1028
  store i16 %0, i16* %2, align 2, !dbg !1028
  %3 = load i16, i16* %2, align 2, !dbg !1030
  %4 = add i16 %3, 31616, !dbg !1031
  ret i16 %4, !dbg !1032
}

define internal void @sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue(i16 %0, i16 %1) !dbg !1033 {
  %3 = alloca i16, i16 1, align 2, !dbg !1034
  %4 = alloca i16, i16 1, align 2, !dbg !1036
  %5 = alloca i16, i16 1, align 2, !dbg !1037
  %6 = alloca i16, i16 1, align 2, !dbg !1038
  store i16 %0, i16* %6, align 2, !dbg !1038
  store i16 %1, i16* %5, align 2, !dbg !1037
  %7 = load i16, i16* %6, align 2, !dbg !1039
  %8 = call i16 @sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr(i16 %7), !dbg !1040
  store i16 %8, i16* %4, align 2, !dbg !1036
  %9 = load i16, i16* %4, align 2, !dbg !1041
  %10 = shl i16 %9, 1, !dbg !1042
  %11 = inttoptr i16 %10 to i16*, !dbg !1042
  call void asm sideeffect "nop", ""(), !dbg !1042
  call void asm sideeffect "nop", ""(), !dbg !1042
  call void asm sideeffect "nop", ""(), !dbg !1042
  call void asm sideeffect "nop", ""(), !dbg !1042
  %12 = load volatile i16, i16* %11, align 2, !dbg !1042
  store i16 %12, i16* %3, align 2, !dbg !1034
  %13 = load i16, i16* %3, align 2, !dbg !1043
  %14 = and i16 %13, -497, !dbg !1044
  store i16 %14, i16* %3, align 2, !dbg !1045
  %15 = load i16, i16* %3, align 2, !dbg !1046
  %16 = load i16, i16* %5, align 2, !dbg !1047
  %17 = add i16 %15, %16, !dbg !1048
  %18 = shl i16 %17, 4, !dbg !1049
  store i16 %18, i16* %3, align 2, !dbg !1050
  %19 = load i16, i16* %4, align 2, !dbg !1051
  %20 = load i16, i16* %3, align 2, !dbg !1052
  %21 = shl i16 %19, 1, !dbg !1053
  %22 = inttoptr i16 %21 to i16*, !dbg !1053
  store volatile i16 %20, i16* %22, align 2, !dbg !1053
  call void asm sideeffect "nop", ""(), !dbg !1053
  call void asm sideeffect "nop", ""(), !dbg !1053
  call void asm sideeffect "nop", ""(), !dbg !1053
  call void asm sideeffect "nop", ""(), !dbg !1053
  ret void, !dbg !1054
}

define internal i16* @.get_tensor_ptr(i16 %0) !dbg !1055 {
  %2 = alloca i16, i16 1, align 2, !dbg !1056
  store i16 %0, i16* %2, align 2, !dbg !1056
  %3 = load i16, i16* %2, align 2, !dbg !1056
  %4 = zext i16 %3 to i32, !dbg !1056
  switch i32 %4, label %5 [
    i32 1, label %9
    i32 2, label %11
    i32 3, label %13
    i32 4, label %15
    i32 5, label %17
    i32 6, label %20
    i32 7, label %23
    i32 8, label %26
    i32 9, label %29
    i32 10, label %32
    i32 11, label %35
    i32 12, label %38
  ], !dbg !1056

5:                                                ; preds = %1
  br i1 false, label %6, label %7, !dbg !1056

6:                                                ; preds = %5
  br label %8, !dbg !1056

7:                                                ; preds = %5
  call void asm sideeffect "hcf", ""(), !dbg !1056
  br label %8, !dbg !1056

8:                                                ; preds = %6, %7
  br label %40, !dbg !1056

9:                                                ; preds = %1
  %10 = load i16*, i16** @p_row_ptr, align 8, !dbg !1056
  br label %40, !dbg !1056

11:                                               ; preds = %1
  %12 = load i16*, i16** @p_col_idx, align 8, !dbg !1056
  br label %40, !dbg !1056

13:                                               ; preds = %1
  %14 = load i16*, i16** @p_col_start, align 8, !dbg !1056
  br label %40, !dbg !1056

15:                                               ; preds = %1
  %16 = load i16*, i16** @p_run_len, align 8, !dbg !1056
  br label %40, !dbg !1056

17:                                               ; preds = %1
  %18 = load float*, float** @p_val, align 8, !dbg !1056
  %19 = bitcast float* %18 to i16*, !dbg !1056
  br label %40, !dbg !1056

20:                                               ; preds = %1
  %21 = load float*, float** @p_x, align 8, !dbg !1056
  %22 = bitcast float* %21 to i16*, !dbg !1056
  br label %40, !dbg !1056

23:                                               ; preds = %1
  %24 = load float*, float** @p_adense, align 8, !dbg !1056
  %25 = bitcast float* %24 to i16*, !dbg !1056
  br label %40, !dbg !1056

26:                                               ; preds = %1
  %27 = load float*, float** @p_y_sc, align 8, !dbg !1056
  %28 = bitcast float* %27 to i16*, !dbg !1056
  br label %40, !dbg !1056

29:                                               ; preds = %1
  %30 = load float*, float** @p_y_ir, align 8, !dbg !1056
  %31 = bitcast float* %30 to i16*, !dbg !1056
  br label %40, !dbg !1056

32:                                               ; preds = %1
  %33 = load float*, float** @p_y_bk, align 8, !dbg !1056
  %34 = bitcast float* %33 to i16*, !dbg !1056
  br label %40, !dbg !1056

35:                                               ; preds = %1
  %36 = load float*, float** @p_y_dn, align 8, !dbg !1056
  %37 = bitcast float* %36 to i16*, !dbg !1056
  br label %40, !dbg !1056

38:                                               ; preds = %1
  %39 = load i16*, i16** @p_mark, align 8, !dbg !1056
  br label %40, !dbg !1056

40:                                               ; preds = %8, %9, %11, %13, %15, %17, %20, %23, %26, %29, %32, %35, %38
  %41 = phi i16 [ -2, %38 ], [ -2, %35 ], [ -2, %32 ], [ -2, %29 ], [ -2, %26 ], [ -2, %23 ], [ -2, %20 ], [ -2, %17 ], [ -2, %15 ], [ -2, %13 ], [ -2, %11 ], [ -2, %9 ], [ 0, %8 ]
  %42 = phi i16* [ %39, %38 ], [ %37, %35 ], [ %34, %32 ], [ %31, %29 ], [ %28, %26 ], [ %25, %23 ], [ %22, %20 ], [ %19, %17 ], [ %16, %15 ], [ %14, %13 ], [ %12, %11 ], [ %10, %9 ], [ undef, %8 ]
  br label %43, !dbg !1056

43:                                               ; preds = %40
  %44 = icmp ne i16 %41, 0, !dbg !1056
  br i1 %44, label %45, label %46, !dbg !1056

45:                                               ; preds = %43
  br label %48, !dbg !1056

46:                                               ; preds = %43
  %47 = load i16*, i16** @p_mark, align 8, !dbg !1056
  br label %48, !dbg !1056

48:                                               ; preds = %45, %46
  %49 = phi i16* [ %47, %46 ], [ %42, %45 ]
  br label %50, !dbg !1056

50:                                               ; preds = %48
  ret i16* %49, !dbg !1056
}

define internal void @__generic0sys_mod.sys_mod.tile_config.queue_flush.exit() !dbg !1058 {
  store volatile i16 1, i16* inttoptr (i16 -2268 to i16*), align 2, !dbg !1060
  call void asm sideeffect "nop", ""(), !dbg !1060
  call void asm sideeffect "nop", ""(), !dbg !1060
  ret void, !dbg !1062
}

define internal void @__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position(i16 %0) !dbg !1063 {
  %2 = alloca i16, i16 1, align 2, !dbg !1065
  %3 = alloca i16, i16 1, align 2, !dbg !1067
  %4 = alloca i16, i16 1, align 2, !dbg !1068
  store i16 %0, i16* %4, align 2, !dbg !1068
  %5 = load i16, i16* %4, align 2, !dbg !1069
  store i16 %5, i16* %3, align 2, !dbg !1067
  %6 = load i16, i16* %3, align 2, !dbg !1070
  %7 = shl i16 %6, 1, !dbg !1071
  %8 = inttoptr i16 %7 to i16*, !dbg !1071
  call void asm sideeffect "nop", ""(), !dbg !1071
  call void asm sideeffect "nop", ""(), !dbg !1071
  call void asm sideeffect "nop", ""(), !dbg !1071
  call void asm sideeffect "nop", ""(), !dbg !1071
  %9 = load volatile i16, i16* %8, align 2, !dbg !1071
  store i16 %9, i16* %2, align 2, !dbg !1065
  %10 = load i16, i16* %2, align 2, !dbg !1072
  %11 = and i16 %10, -16, !dbg !1073
  store i16 %11, i16* %2, align 2, !dbg !1073
  %12 = load i16, i16* %3, align 2, !dbg !1074
  %13 = load i16, i16* %2, align 2, !dbg !1075
  %14 = shl i16 %12, 1, !dbg !1076
  %15 = inttoptr i16 %14 to i16*, !dbg !1076
  store volatile i16 %13, i16* %15, align 2, !dbg !1076
  call void asm sideeffect "nop", ""(), !dbg !1076
  call void asm sideeffect "nop", ""(), !dbg !1076
  call void asm sideeffect "nop", ""(), !dbg !1076
  call void asm sideeffect "nop", ""(), !dbg !1076
  ret void, !dbg !1077
}

define internal void @__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 %0) !dbg !1078 {
  %2 = alloca i16, i16 1, align 2, !dbg !1080
  %3 = alloca i16, i16 1, align 2, !dbg !1082
  %4 = alloca i16, i16 1, align 2, !dbg !1083
  store i16 %0, i16* %4, align 2, !dbg !1083
  %5 = load i16, i16* %4, align 2, !dbg !1084
  store i16 %5, i16* %3, align 2, !dbg !1082
  %6 = load i16, i16* %3, align 2, !dbg !1085
  %7 = shl i16 %6, 1, !dbg !1086
  %8 = inttoptr i16 %7 to i16*, !dbg !1086
  call void asm sideeffect "nop", ""(), !dbg !1086
  call void asm sideeffect "nop", ""(), !dbg !1086
  %9 = load volatile i16, i16* %8, align 2, !dbg !1086
  store i16 %9, i16* %2, align 2, !dbg !1080
  %10 = load i16, i16* %2, align 2, !dbg !1087
  %11 = and i16 %10, -256, !dbg !1088
  store i16 %11, i16* %2, align 2, !dbg !1089
  %12 = load i16, i16* %2, align 2, !dbg !1090
  %13 = load i16, i16* %2, align 2, !dbg !1091
  %14 = call i16 @__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %13), !dbg !1092
  %15 = or i16 %12, %14, !dbg !1093
  store i16 %15, i16* %2, align 2, !dbg !1093
  %16 = load i16, i16* %2, align 2, !dbg !1094
  %17 = load i16, i16* %2, align 2, !dbg !1095
  %18 = call i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %17), !dbg !1096
  %19 = or i16 %16, %18, !dbg !1097
  store i16 %19, i16* %2, align 2, !dbg !1097
  %20 = load i16, i16* %3, align 2, !dbg !1098
  %21 = load i16, i16* %2, align 2, !dbg !1099
  %22 = shl i16 %20, 1, !dbg !1100
  %23 = inttoptr i16 %22 to i16*, !dbg !1100
  store volatile i16 %21, i16* %23, align 2, !dbg !1100
  call void asm sideeffect "nop", ""(), !dbg !1100
  call void asm sideeffect "nop", ""(), !dbg !1100
  ret void, !dbg !1101
}

define internal void @__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes(i16 %0) !dbg !1102 {
  %2 = alloca i16, i16 1, align 2, !dbg !1103
  %3 = alloca i16, i16 1, align 2, !dbg !1105
  %4 = alloca i16, i16 1, align 2, !dbg !1106
  store i16 %0, i16* %4, align 2, !dbg !1106
  %5 = load i16, i16* %4, align 2, !dbg !1107
  store i16 %5, i16* %3, align 2, !dbg !1105
  %6 = load i16, i16* %3, align 2, !dbg !1108
  %7 = shl i16 %6, 1, !dbg !1109
  %8 = inttoptr i16 %7 to i16*, !dbg !1109
  call void asm sideeffect "nop", ""(), !dbg !1109
  call void asm sideeffect "nop", ""(), !dbg !1109
  %9 = load volatile i16, i16* %8, align 2, !dbg !1109
  store i16 %9, i16* %2, align 2, !dbg !1103
  %10 = load i16, i16* %2, align 2, !dbg !1110
  %11 = and i16 %10, -256, !dbg !1111
  store i16 %11, i16* %2, align 2, !dbg !1112
  %12 = load i16, i16* %2, align 2, !dbg !1113
  %13 = load i16, i16* %2, align 2, !dbg !1114
  %14 = call i16 @__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %13), !dbg !1115
  %15 = or i16 %12, %14, !dbg !1116
  store i16 %15, i16* %2, align 2, !dbg !1116
  %16 = load i16, i16* %2, align 2, !dbg !1117
  %17 = load i16, i16* %2, align 2, !dbg !1118
  %18 = call i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %17), !dbg !1119
  %19 = or i16 %16, %18, !dbg !1120
  store i16 %19, i16* %2, align 2, !dbg !1120
  %20 = load i16, i16* %3, align 2, !dbg !1121
  %21 = load i16, i16* %2, align 2, !dbg !1122
  %22 = shl i16 %20, 1, !dbg !1123
  %23 = inttoptr i16 %22 to i16*, !dbg !1123
  store volatile i16 %21, i16* %23, align 2, !dbg !1123
  call void asm sideeffect "nop", ""(), !dbg !1123
  call void asm sideeffect "nop", ""(), !dbg !1123
  ret void, !dbg !1124
}

define internal i16 @__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %0) !dbg !1125 {
  %2 = alloca i16, i16 1, align 2, !dbg !1126
  %3 = alloca i16, i16 1, align 2, !dbg !1128
  store i16 %0, i16* %3, align 2, !dbg !1128
  %4 = load i16, i16* %3, align 2, !dbg !1129
  store i16 %4, i16* %2, align 2, !dbg !1126
  %5 = load i16, i16* %2, align 2, !dbg !1130
  store i16 %5, i16* %2, align 2, !dbg !1131
  %6 = load i16, i16* %2, align 2, !dbg !1132
  ret i16 %6, !dbg !1133
}

define internal i16 @__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes(i16 %0) !dbg !1134 {
  %2 = alloca i16, i16 1, align 2, !dbg !1135
  %3 = alloca i16, i16 1, align 2, !dbg !1137
  store i16 %0, i16* %3, align 2, !dbg !1137
  %4 = load i16, i16* %3, align 2, !dbg !1138
  store i16 %4, i16* %2, align 2, !dbg !1135
  %5 = load i16, i16* %2, align 2, !dbg !1139
  %6 = or i16 %5, 2, !dbg !1140
  store i16 %6, i16* %2, align 2, !dbg !1140
  %7 = load i16, i16* %2, align 2, !dbg !1141
  ret i16 %7, !dbg !1142
}

define internal i16 @__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes(i16 %0) !dbg !1143 {
  %2 = alloca i16, i16 1, align 2, !dbg !1144
  %3 = alloca i16, i16 1, align 2, !dbg !1146
  store i16 %0, i16* %3, align 2, !dbg !1146
  %4 = load i16, i16* %3, align 2, !dbg !1147
  store i16 %4, i16* %2, align 2, !dbg !1144
  %5 = load i16, i16* %2, align 2, !dbg !1148
  %6 = or i16 %5, 128, !dbg !1149
  store i16 %6, i16* %2, align 2, !dbg !1149
  %7 = load i16, i16* %2, align 2, !dbg !1150
  ret i16 %7, !dbg !1151
}

define internal void @__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction(i16 %0) !dbg !1152 {
  %2 = alloca i16, i16 1, align 2, !dbg !1153
  %3 = alloca i16, i16 1, align 2, !dbg !1155
  %4 = alloca i16, i16 1, align 2, !dbg !1156
  store i16 %0, i16* %4, align 2, !dbg !1156
  %5 = load i16, i16* %4, align 2, !dbg !1157
  store i16 %5, i16* %3, align 2, !dbg !1155
  %6 = load i16, i16* %3, align 2, !dbg !1158
  %7 = shl i16 %6, 1, !dbg !1159
  %8 = inttoptr i16 %7 to i16*, !dbg !1159
  call void asm sideeffect "nop", ""(), !dbg !1159
  call void asm sideeffect "nop", ""(), !dbg !1159
  %9 = load volatile i16, i16* %8, align 2, !dbg !1159
  store i16 %9, i16* %2, align 2, !dbg !1153
  %10 = load i16, i16* %2, align 2, !dbg !1160
  %11 = and i16 %10, -17, !dbg !1161
  store i16 %11, i16* %2, align 2, !dbg !1161
  %12 = load i16, i16* %3, align 2, !dbg !1162
  %13 = load i16, i16* %2, align 2, !dbg !1163
  %14 = shl i16 %12, 1, !dbg !1164
  %15 = inttoptr i16 %14 to i16*, !dbg !1164
  store volatile i16 %13, i16* %15, align 2, !dbg !1164
  call void asm sideeffect "nop", ""(), !dbg !1164
  call void asm sideeffect "nop", ""(), !dbg !1164
  ret void, !dbg !1165
}

define internal void @__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction(i16 %0) !dbg !1166 {
  %2 = alloca i16, i16 1, align 2, !dbg !1167
  %3 = alloca i16, i16 1, align 2, !dbg !1169
  %4 = alloca i16, i16 1, align 2, !dbg !1170
  store i16 %0, i16* %4, align 2, !dbg !1170
  %5 = load i16, i16* %4, align 2, !dbg !1171
  store i16 %5, i16* %3, align 2, !dbg !1169
  %6 = load i16, i16* %3, align 2, !dbg !1172
  %7 = shl i16 %6, 1, !dbg !1173
  %8 = inttoptr i16 %7 to i16*, !dbg !1173
  call void asm sideeffect "nop", ""(), !dbg !1173
  call void asm sideeffect "nop", ""(), !dbg !1173
  %9 = load volatile i16, i16* %8, align 2, !dbg !1173
  store i16 %9, i16* %2, align 2, !dbg !1167
  %10 = load i16, i16* %2, align 2, !dbg !1174
  %11 = or i16 %10, 16, !dbg !1175
  store i16 %11, i16* %2, align 2, !dbg !1175
  %12 = load i16, i16* %3, align 2, !dbg !1176
  %13 = load i16, i16* %2, align 2, !dbg !1177
  %14 = shl i16 %12, 1, !dbg !1178
  %15 = inttoptr i16 %14 to i16*, !dbg !1178
  store volatile i16 %13, i16* %15, align 2, !dbg !1178
  call void asm sideeffect "nop", ""(), !dbg !1178
  call void asm sideeffect "nop", ""(), !dbg !1178
  ret void, !dbg !1179
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
declare void @llvm.sdr.imov32.ds1(i16 immarg, i16 immarg) #12

; Function Attrs: nounwind
declare float @llvm.sdr.fadds.rrs1(float, i16 immarg) #12

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
!3 = distinct !DISubprogram(name: "spmv_scalar", linkageName: "spmv_scalar", scope: null, file: !4, line: 34, type: !5, scopeLine: 34, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!4 = !DIFile(filename: "./pe.csl", directory: "/home/USER/xkernel/studies/wse3-characterization/microbench/iremit")
!5 = !DISubroutineType(types: !6)
!6 = !{}
!7 = !DILocation(line: 43, column: 7, scope: !8)
!8 = !DILexicalBlockFile(scope: !3, file: !4, discriminator: 0)
!9 = !DILocation(line: 41, column: 5, scope: !8)
!10 = !DILocation(line: 40, column: 5, scope: !8)
!11 = !DILocation(line: 39, column: 5, scope: !8)
!12 = !DILocation(line: 38, column: 5, scope: !8)
!13 = !DILocation(line: 36, column: 3, scope: !8)
!14 = !DILocation(line: 35, column: 11, scope: !8)
!15 = !DILocation(line: 37, column: 3, scope: !8)
!16 = !DILocation(line: 37, column: 10, scope: !8)
!17 = !DILocation(line: 37, column: 12, scope: !8)
!18 = !DILocation(line: 38, column: 28, scope: !8)
!19 = !DILocation(line: 38, column: 27, scope: !8)
!20 = !DILocation(line: 39, column: 28, scope: !8)
!21 = !DILocation(line: 39, column: 30, scope: !8)
!22 = !DILocation(line: 39, column: 27, scope: !8)
!23 = !DILocation(line: 41, column: 18, scope: !8)
!24 = !DILocation(line: 42, column: 5, scope: !8)
!25 = !DILocation(line: 42, column: 12, scope: !8)
!26 = !DILocation(line: 42, column: 16, scope: !8)
!27 = !DILocation(line: 42, column: 14, scope: !8)
!28 = !DILocation(line: 43, column: 30, scope: !8)
!29 = !DILocation(line: 43, column: 29, scope: !8)
!30 = !DILocation(line: 44, column: 7, scope: !8)
!31 = !DILocation(line: 44, column: 18, scope: !8)
!32 = !DILocation(line: 44, column: 17, scope: !8)
!33 = !DILocation(line: 44, column: 25, scope: !8)
!34 = !DILocation(line: 44, column: 24, scope: !8)
!35 = !DILocation(line: 44, column: 21, scope: !8)
!36 = !DILocation(line: 44, column: 11, scope: !8)
!37 = !DILocation(line: 42, column: 22, scope: !8)
!38 = !DILocation(line: 42, column: 24, scope: !8)
!39 = !DILocation(line: 46, column: 15, scope: !8)
!40 = !DILocation(line: 46, column: 10, scope: !8)
!41 = !DILocation(line: 46, column: 9, scope: !8)
!42 = !DILocation(line: 46, column: 13, scope: !8)
!43 = !DILocation(line: 37, column: 24, scope: !8)
!44 = !DILocation(line: 37, column: 26, scope: !8)
!45 = !DILocation(line: 48, column: 11, scope: !8)
!46 = !DILocation(line: 49, column: 3, scope: !8)
!47 = distinct !DISubprogram(name: "spmv_ir", linkageName: "spmv_ir", scope: null, file: !4, line: 53, type: !5, scopeLine: 53, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!48 = !DILocation(line: 54, column: 11, scope: !49)
!49 = !DILexicalBlockFile(scope: !47, file: !4, discriminator: 0)
!50 = !DILocation(line: 55, column: 11, scope: !49)
!51 = !DILocation(line: 56, column: 11, scope: !49)
!52 = !DILocation(line: 57, column: 3, scope: !49)
!53 = !DILocation(line: 53, column: 1, scope: !49)
!54 = distinct !DISubprogram(name: "spmv_blk", linkageName: "spmv_blk", scope: null, file: !4, line: 61, type: !5, scopeLine: 61, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!55 = !DILocation(line: 74, column: 5, scope: !56)
!56 = !DILexicalBlockFile(scope: !54, file: !4, discriminator: 0)
!57 = !DILocation(line: 72, column: 5, scope: !56)
!58 = !DILocation(line: 70, column: 5, scope: !56)
!59 = !DILocation(line: 68, column: 5, scope: !56)
!60 = !DILocation(line: 67, column: 5, scope: !56)
!61 = !DILocation(line: 66, column: 5, scope: !56)
!62 = !DILocation(line: 65, column: 5, scope: !56)
!63 = !DILocation(line: 63, column: 3, scope: !56)
!64 = !DILocation(line: 62, column: 11, scope: !56)
!65 = !DILocation(line: 64, column: 3, scope: !56)
!66 = !DILocation(line: 64, column: 10, scope: !56)
!67 = !DILocation(line: 64, column: 12, scope: !56)
!68 = !DILocation(line: 65, column: 28, scope: !56)
!69 = !DILocation(line: 65, column: 27, scope: !56)
!70 = !DILocation(line: 66, column: 28, scope: !56)
!71 = !DILocation(line: 66, column: 27, scope: !56)
!72 = !DILocation(line: 67, column: 31, scope: !56)
!73 = !DILocation(line: 67, column: 30, scope: !56)
!74 = !DILocation(line: 68, column: 39, scope: !56)
!75 = !DILocation(line: 69, column: 32, scope: !56)
!76 = !DILocation(line: 69, column: 45, scope: !56)
!77 = !DILocation(line: 69, column: 10, scope: !56)
!78 = !DILocation(line: 69, column: 8, scope: !56)
!79 = !DILocation(line: 70, column: 37, scope: !56)
!80 = !DILocation(line: 71, column: 32, scope: !56)
!81 = !DILocation(line: 71, column: 45, scope: !56)
!82 = !DILocation(line: 71, column: 10, scope: !56)
!83 = !DILocation(line: 71, column: 8, scope: !56)
!84 = !DILocation(line: 72, column: 39, scope: !56)
!85 = !DILocation(line: 73, column: 12, scope: !56)
!86 = !DILocation(line: 73, column: 16, scope: !56)
!87 = !DILocation(line: 73, column: 20, scope: !56)
!88 = !DILocation(line: 73, column: 5, scope: !56)
!89 = !DILocation(line: 75, column: 18, scope: !56)
!90 = !DILocation(line: 75, column: 23, scope: !56)
!91 = !DILocation(line: 75, column: 5, scope: !56)
!92 = !DILocation(line: 76, column: 15, scope: !56)
!93 = !DILocation(line: 76, column: 10, scope: !56)
!94 = !DILocation(line: 76, column: 9, scope: !56)
!95 = !DILocation(line: 76, column: 13, scope: !56)
!96 = !DILocation(line: 64, column: 24, scope: !56)
!97 = !DILocation(line: 64, column: 26, scope: !56)
!98 = !DILocation(line: 78, column: 11, scope: !56)
!99 = !DILocation(line: 79, column: 3, scope: !56)
!100 = distinct !DISubprogram(name: "spmv_dense", linkageName: "spmv_dense", scope: null, file: !4, line: 83, type: !5, scopeLine: 83, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!101 = !DILocation(line: 89, column: 5, scope: !102)
!102 = !DILexicalBlockFile(scope: !100, file: !4, discriminator: 0)
!103 = !DILocation(line: 87, column: 5, scope: !102)
!104 = !DILocation(line: 85, column: 3, scope: !102)
!105 = !DILocation(line: 84, column: 11, scope: !102)
!106 = !DILocation(line: 86, column: 3, scope: !102)
!107 = !DILocation(line: 86, column: 10, scope: !102)
!108 = !DILocation(line: 86, column: 12, scope: !102)
!109 = !DILocation(line: 87, column: 53, scope: !102)
!110 = !DILocation(line: 87, column: 55, scope: !102)
!111 = !DILocation(line: 87, column: 14, scope: !102)
!112 = !DILocation(line: 88, column: 21, scope: !102)
!113 = !DILocation(line: 88, column: 5, scope: !102)
!114 = !DILocation(line: 90, column: 18, scope: !102)
!115 = !DILocation(line: 90, column: 5, scope: !102)
!116 = !DILocation(line: 91, column: 15, scope: !102)
!117 = !DILocation(line: 91, column: 10, scope: !102)
!118 = !DILocation(line: 91, column: 9, scope: !102)
!119 = !DILocation(line: 91, column: 13, scope: !102)
!120 = !DILocation(line: 86, column: 24, scope: !102)
!121 = !DILocation(line: 86, column: 26, scope: !102)
!122 = !DILocation(line: 93, column: 11, scope: !102)
!123 = !DILocation(line: 94, column: 3, scope: !102)
!124 = distinct !DISubprogram(name: "f_exit", linkageName: "f_exit", scope: null, file: !4, line: 97, type: !5, scopeLine: 97, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!125 = !DILocation(line: 97, column: 22, scope: !126)
!126 = !DILexicalBlockFile(scope: !124, file: !4, discriminator: 0)
!127 = !DILocation(line: 97, column: 1, scope: !126)
!128 = distinct !DISubprogram(name: "sys_mod.sys_nop", linkageName: "sys_mod.sys_nop", scope: null, file: !129, line: 90, type: !5, scopeLine: 90, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!129 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/memcpy.csl", directory: "")
!130 = !DILocation(line: 90, column: 1, scope: !131)
!131 = !DILexicalBlockFile(scope: !128, file: !129, discriminator: 0)
!132 = distinct !DISubprogram(name: "sys_mod.unblock_cmd_stream", linkageName: "sys_mod.unblock_cmd_stream", scope: null, file: !129, line: 102, type: !5, scopeLine: 102, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!133 = !DILocation(line: 103, column: 3, scope: !134)
!134 = !DILexicalBlockFile(scope: !132, file: !129, discriminator: 0)
!135 = !DILocation(line: 102, column: 1, scope: !134)
!136 = distinct !DISubprogram(name: "sys_mod.sys_mod.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.unblock_cmd_stream", scope: null, file: !137, line: 307, type: !5, scopeLine: 307, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!137 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpy.csl", directory: "")
!138 = !DILocation(line: 308, column: 5, scope: !139)
!139 = !DILexicalBlockFile(scope: !136, file: !137, discriminator: 0)
!140 = !DILocation(line: 307, column: 1, scope: !139)
!141 = distinct !DISubprogram(name: "sys_mod.sys_mod.teardown_h2d", linkageName: "sys_mod.sys_mod.teardown_h2d", scope: null, file: !137, line: 323, type: !5, scopeLine: 323, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!142 = !DILocation(line: 326, column: 5, scope: !143)
!143 = !DILexicalBlockFile(scope: !141, file: !137, discriminator: 0)
!144 = !DILocation(line: 323, column: 1, scope: !143)
!145 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_ublk_c22", linkageName: "sys_mod.sys_mod.f_ublk_c22", scope: null, file: !137, line: 335, type: !5, scopeLine: 335, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!146 = !DILocation(line: 336, column: 5, scope: !147)
!147 = !DILexicalBlockFile(scope: !145, file: !137, discriminator: 0)
!148 = !DILocation(line: 335, column: 1, scope: !147)
!149 = distinct !DISubprogram(name: "sys_mod.sys_mod.teardown_d2h", linkageName: "sys_mod.sys_mod.teardown_d2h", scope: null, file: !137, line: 344, type: !5, scopeLine: 344, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!150 = !DILocation(line: 355, column: 5, scope: !151)
!151 = !DILexicalBlockFile(scope: !149, file: !137, discriminator: 0)
!152 = !DILocation(line: 359, column: 5, scope: !151)
!153 = !DILocation(line: 344, column: 1, scope: !151)
!154 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_memcpyh2d", linkageName: "sys_mod.sys_mod.f_memcpyh2d", scope: null, file: !137, line: 460, type: !5, scopeLine: 460, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!155 = !DILocation(line: 477, column: 5, scope: !156)
!156 = !DILexicalBlockFile(scope: !154, file: !137, discriminator: 0)
!157 = !DILocation(line: 476, column: 5, scope: !156)
!158 = !DILocation(line: 475, column: 5, scope: !156)
!159 = !DILocation(line: 474, column: 5, scope: !156)
!160 = !DILocation(line: 473, column: 5, scope: !156)
!161 = !DILocation(line: 472, column: 5, scope: !156)
!162 = !DILocation(line: 471, column: 5, scope: !156)
!163 = !DILocation(line: 470, column: 5, scope: !156)
!164 = !DILocation(line: 469, column: 5, scope: !156)
!165 = !DILocation(line: 468, column: 5, scope: !156)
!166 = !DILocation(line: 467, column: 5, scope: !156)
!167 = !DILocation(line: 466, column: 5, scope: !156)
!168 = !DILocation(line: 465, column: 5, scope: !156)
!169 = !DILocation(line: 463, column: 5, scope: !156)
!170 = !DILocation(line: 462, column: 20, scope: !156)
!171 = !DILocation(line: 462, column: 32, scope: !156)
!172 = !DILocation(line: 462, column: 5, scope: !156)
!173 = !DILocation(line: 465, column: 33, scope: !156)
!174 = !DILocation(line: 465, column: 38, scope: !156)
!175 = !DILocation(line: 466, column: 34, scope: !156)
!176 = !DILocation(line: 466, column: 39, scope: !156)
!177 = !DILocation(line: 467, column: 34, scope: !156)
!178 = !DILocation(line: 467, column: 39, scope: !156)
!179 = !DILocation(line: 468, column: 33, scope: !156)
!180 = !DILocation(line: 468, column: 38, scope: !156)
!181 = !DILocation(line: 469, column: 33, scope: !156)
!182 = !DILocation(line: 469, column: 38, scope: !156)
!183 = !DILocation(line: 470, column: 35, scope: !156)
!184 = !DILocation(line: 470, column: 21, scope: !156)
!185 = !DILocation(line: 471, column: 41, scope: !156)
!186 = !DILocation(line: 471, column: 27, scope: !156)
!187 = !DILocation(line: 472, column: 39, scope: !156)
!188 = !DILocation(line: 472, column: 25, scope: !156)
!189 = !DILocation(line: 473, column: 44, scope: !156)
!190 = !DILocation(line: 473, column: 49, scope: !156)
!191 = !DILocation(line: 474, column: 41, scope: !156)
!192 = !DILocation(line: 474, column: 46, scope: !156)
!193 = !DILocation(line: 475, column: 41, scope: !156)
!194 = !DILocation(line: 475, column: 46, scope: !156)
!195 = !DILocation(line: 476, column: 59, scope: !156)
!196 = !DILocation(line: 476, column: 64, scope: !156)
!197 = !DILocation(line: 476, column: 50, scope: !156)
!198 = !DILocation(line: 476, column: 129, scope: !156)
!199 = !DILocation(line: 476, column: 134, scope: !156)
!200 = !DILocation(line: 476, column: 120, scope: !156)
!201 = !DILocation(line: 476, column: 118, scope: !156)
!202 = !DILocation(line: 476, column: 112, scope: !156)
!203 = !DILocation(line: 476, column: 36, scope: !156)
!204 = !DILocation(line: 477, column: 59, scope: !156)
!205 = !DILocation(line: 477, column: 64, scope: !156)
!206 = !DILocation(line: 477, column: 50, scope: !156)
!207 = !DILocation(line: 477, column: 129, scope: !156)
!208 = !DILocation(line: 477, column: 134, scope: !156)
!209 = !DILocation(line: 477, column: 120, scope: !156)
!210 = !DILocation(line: 477, column: 118, scope: !156)
!211 = !DILocation(line: 477, column: 112, scope: !156)
!212 = !DILocation(line: 477, column: 36, scope: !156)
!213 = !DILocation(line: 479, column: 24, scope: !156)
!214 = !DILocation(line: 481, column: 21, scope: !156)
!215 = !DILocation(line: 481, column: 19, scope: !156)
!216 = !DILocation(line: 482, column: 21, scope: !156)
!217 = !DILocation(line: 482, column: 19, scope: !156)
!218 = !DILocation(line: 483, column: 21, scope: !156)
!219 = !DILocation(line: 483, column: 19, scope: !156)
!220 = !DILocation(line: 484, column: 20, scope: !156)
!221 = !DILocation(line: 484, column: 18, scope: !156)
!222 = !DILocation(line: 485, column: 20, scope: !156)
!223 = !DILocation(line: 485, column: 18, scope: !156)
!224 = !DILocation(line: 486, column: 22, scope: !156)
!225 = !DILocation(line: 486, column: 20, scope: !156)
!226 = !DILocation(line: 487, column: 27, scope: !156)
!227 = !DILocation(line: 487, column: 25, scope: !156)
!228 = !DILocation(line: 488, column: 25, scope: !156)
!229 = !DILocation(line: 488, column: 23, scope: !156)
!230 = !DILocation(line: 489, column: 31, scope: !156)
!231 = !DILocation(line: 489, column: 29, scope: !156)
!232 = !DILocation(line: 490, column: 28, scope: !156)
!233 = !DILocation(line: 490, column: 26, scope: !156)
!234 = !DILocation(line: 491, column: 28, scope: !156)
!235 = !DILocation(line: 491, column: 26, scope: !156)
!236 = !DILocation(line: 492, column: 37, scope: !156)
!237 = !DILocation(line: 492, column: 35, scope: !156)
!238 = !DILocation(line: 493, column: 37, scope: !156)
!239 = !DILocation(line: 493, column: 35, scope: !156)
!240 = !DILocation(line: 495, column: 5, scope: !156)
!241 = !DILocation(line: 501, column: 5, scope: !156)
!242 = !DILocation(line: 506, column: 5, scope: !156)
!243 = !DILocation(line: 521, column: 5, scope: !156)
!244 = !DILocation(line: 522, column: 16, scope: !156)
!245 = !DILocation(line: 531, column: 5, scope: !156)
!246 = !DILocation(line: 460, column: 1, scope: !156)
!247 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_memcpyd2h", linkageName: "sys_mod.sys_mod.f_memcpyd2h", scope: null, file: !137, line: 556, type: !5, scopeLine: 556, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!248 = !DILocation(line: 568, column: 5, scope: !249)
!249 = !DILexicalBlockFile(scope: !247, file: !137, discriminator: 0)
!250 = !DILocation(line: 567, column: 5, scope: !249)
!251 = !DILocation(line: 566, column: 5, scope: !249)
!252 = !DILocation(line: 565, column: 5, scope: !249)
!253 = !DILocation(line: 564, column: 5, scope: !249)
!254 = !DILocation(line: 563, column: 5, scope: !249)
!255 = !DILocation(line: 562, column: 5, scope: !249)
!256 = !DILocation(line: 561, column: 5, scope: !249)
!257 = !DILocation(line: 559, column: 5, scope: !249)
!258 = !DILocation(line: 558, column: 20, scope: !249)
!259 = !DILocation(line: 558, column: 32, scope: !249)
!260 = !DILocation(line: 558, column: 5, scope: !249)
!261 = !DILocation(line: 561, column: 33, scope: !249)
!262 = !DILocation(line: 561, column: 38, scope: !249)
!263 = !DILocation(line: 562, column: 34, scope: !249)
!264 = !DILocation(line: 562, column: 39, scope: !249)
!265 = !DILocation(line: 563, column: 34, scope: !249)
!266 = !DILocation(line: 563, column: 39, scope: !249)
!267 = !DILocation(line: 564, column: 33, scope: !249)
!268 = !DILocation(line: 564, column: 38, scope: !249)
!269 = !DILocation(line: 565, column: 33, scope: !249)
!270 = !DILocation(line: 565, column: 38, scope: !249)
!271 = !DILocation(line: 566, column: 35, scope: !249)
!272 = !DILocation(line: 566, column: 21, scope: !249)
!273 = !DILocation(line: 567, column: 41, scope: !249)
!274 = !DILocation(line: 567, column: 27, scope: !249)
!275 = !DILocation(line: 568, column: 39, scope: !249)
!276 = !DILocation(line: 568, column: 25, scope: !249)
!277 = !DILocation(line: 570, column: 24, scope: !249)
!278 = !DILocation(line: 573, column: 21, scope: !249)
!279 = !DILocation(line: 573, column: 19, scope: !249)
!280 = !DILocation(line: 574, column: 21, scope: !249)
!281 = !DILocation(line: 574, column: 19, scope: !249)
!282 = !DILocation(line: 575, column: 21, scope: !249)
!283 = !DILocation(line: 575, column: 19, scope: !249)
!284 = !DILocation(line: 576, column: 20, scope: !249)
!285 = !DILocation(line: 576, column: 18, scope: !249)
!286 = !DILocation(line: 577, column: 20, scope: !249)
!287 = !DILocation(line: 577, column: 18, scope: !249)
!288 = !DILocation(line: 578, column: 22, scope: !249)
!289 = !DILocation(line: 578, column: 20, scope: !249)
!290 = !DILocation(line: 579, column: 27, scope: !249)
!291 = !DILocation(line: 579, column: 25, scope: !249)
!292 = !DILocation(line: 580, column: 25, scope: !249)
!293 = !DILocation(line: 580, column: 23, scope: !249)
!294 = !DILocation(line: 582, column: 5, scope: !249)
!295 = !DILocation(line: 588, column: 59, scope: !249)
!296 = !DILocation(line: 588, column: 5, scope: !249)
!297 = !DILocation(line: 608, column: 5, scope: !249)
!298 = !DILocation(line: 609, column: 16, scope: !249)
!299 = !DILocation(line: 556, column: 1, scope: !249)
!300 = distinct !DISubprogram(name: "sys_mod.sys_mod.oq0_teardow_handler", linkageName: "sys_mod.sys_mod.oq0_teardow_handler", scope: null, file: !137, line: 631, type: !5, scopeLine: 631, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!301 = !DILocation(line: 632, column: 9, scope: !302)
!302 = !DILexicalBlockFile(scope: !300, file: !137, discriminator: 0)
!303 = !DILocation(line: 632, column: 5, scope: !302)
!304 = !DILocation(line: 634, column: 66, scope: !302)
!305 = !DILocation(line: 634, column: 9, scope: !302)
!306 = !DILocation(line: 636, column: 13, scope: !302)
!307 = !DILocation(line: 637, column: 13, scope: !302)
!308 = !DILocation(line: 638, column: 13, scope: !302)
!309 = !DILocation(line: 639, column: 13, scope: !302)
!310 = !DILocation(line: 640, column: 13, scope: !302)
!311 = !DILocation(line: 641, column: 13, scope: !302)
!312 = !DILocation(line: 642, column: 13, scope: !302)
!313 = !DILocation(line: 643, column: 13, scope: !302)
!314 = !DILocation(line: 644, column: 13, scope: !302)
!315 = !DILocation(line: 645, column: 13, scope: !302)
!316 = !DILocation(line: 646, column: 13, scope: !302)
!317 = !DILocation(line: 647, column: 13, scope: !302)
!318 = !DILocation(line: 648, column: 13, scope: !302)
!319 = !DILocation(line: 635, column: 9, scope: !302)
!320 = !DILocation(line: 652, column: 9, scope: !302)
!321 = !DILocation(line: 654, column: 13, scope: !302)
!322 = !DILocation(line: 655, column: 13, scope: !302)
!323 = !DILocation(line: 656, column: 13, scope: !302)
!324 = !DILocation(line: 657, column: 13, scope: !302)
!325 = !DILocation(line: 658, column: 13, scope: !302)
!326 = !DILocation(line: 659, column: 13, scope: !302)
!327 = !DILocation(line: 660, column: 13, scope: !302)
!328 = !DILocation(line: 661, column: 13, scope: !302)
!329 = !DILocation(line: 653, column: 9, scope: !302)
!330 = !DILocation(line: 664, column: 5, scope: !302)
!331 = distinct !DISubprogram(name: "sys_mod.sys_mod.f_rpc", linkageName: "sys_mod.sys_mod.f_rpc", scope: null, file: !137, line: 694, type: !5, scopeLine: 694, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!332 = !DILocation(line: 694, column: 13, scope: !333)
!333 = !DILexicalBlockFile(scope: !331, file: !137, discriminator: 0)
!334 = !DILocation(line: 700, column: 5, scope: !333)
!335 = !DILocation(line: 706, column: 20, scope: !333)
!336 = !DILocation(line: 706, column: 32, scope: !333)
!337 = !DILocation(line: 706, column: 5, scope: !333)
!338 = !DILocation(line: 710, column: 5, scope: !333)
!339 = !DILocation(line: 712, column: 24, scope: !333)
!340 = !DILocation(line: 694, column: 1, scope: !333)
!341 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.stack_push", linkageName: "sys_mod.sys_mod.sys_mod.stack_push", scope: null, file: !342, line: 54, type: !5, scopeLine: 54, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!342 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/sys.csl", directory: "")
!343 = !DILocation(line: 60, column: 5, scope: !344)
!344 = !DILexicalBlockFile(scope: !341, file: !342, discriminator: 0)
!345 = !DILocation(line: 54, column: 16, scope: !344)
!346 = !DILocation(line: 59, column: 13, scope: !344)
!347 = !DILocation(line: 59, column: 24, scope: !344)
!348 = !DILocation(line: 59, column: 5, scope: !344)
!349 = !DILocation(line: 61, column: 25, scope: !344)
!350 = !DILocation(line: 61, column: 5, scope: !344)
!351 = !DILocation(line: 61, column: 11, scope: !344)
!352 = !DILocation(line: 61, column: 10, scope: !344)
!353 = !DILocation(line: 61, column: 23, scope: !344)
!354 = !DILocation(line: 62, column: 18, scope: !344)
!355 = !DILocation(line: 62, column: 29, scope: !344)
!356 = !DILocation(line: 62, column: 16, scope: !344)
!357 = !DILocation(line: 54, column: 1, scope: !344)
!358 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_push", linkageName: "sys_mod.sys_mod.sys_mod.f_push", scope: null, file: !342, line: 72, type: !5, scopeLine: 72, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!359 = !DILocation(line: 72, column: 25, scope: !360)
!360 = !DILexicalBlockFile(scope: !358, file: !342, discriminator: 0)
!361 = !DILocation(line: 72, column: 13, scope: !360)
!362 = !DILocation(line: 73, column: 16, scope: !360)
!363 = !DILocation(line: 73, column: 5, scope: !360)
!364 = !DILocation(line: 72, column: 1, scope: !360)
!365 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.block_cmd_stream", linkageName: "sys_mod.sys_mod.sys_mod.block_cmd_stream", scope: null, file: !342, line: 76, type: !5, scopeLine: 76, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!366 = !DILocation(line: 77, column: 5, scope: !367)
!367 = !DILexicalBlockFile(scope: !365, file: !342, discriminator: 0)
!368 = !DILocation(line: 76, column: 1, scope: !367)
!369 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.sys_mod.unblock_cmd_stream", scope: null, file: !342, line: 80, type: !5, scopeLine: 80, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!370 = !DILocation(line: 81, column: 5, scope: !371)
!371 = !DILexicalBlockFile(scope: !369, file: !342, discriminator: 0)
!372 = !DILocation(line: 80, column: 1, scope: !371)
!373 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_sys_exit", linkageName: "sys_mod.sys_mod.sys_mod.f_sys_exit", scope: null, file: !342, line: 85, type: !5, scopeLine: 85, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!374 = !DILocation(line: 86, column: 5, scope: !375)
!375 = !DILexicalBlockFile(scope: !373, file: !342, discriminator: 0)
!376 = !DILocation(line: 87, column: 5, scope: !375)
!377 = !DILocation(line: 85, column: 1, scope: !375)
!378 = distinct !DISubprogram(name: "sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore", linkageName: "sys_mod.sys_mod.sys_mod.f_sys_check_and_ignore", scope: null, file: !342, line: 90, type: !5, scopeLine: 90, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!379 = !DILocation(line: 90, column: 30, scope: !380)
!380 = !DILexicalBlockFile(scope: !378, file: !342, discriminator: 0)
!381 = !DILocation(line: 90, column: 1, scope: !380)
!382 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.get_x_coord", scope: null, file: !383, line: 131, type: !5, scopeLine: 131, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!383 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpyh2d.csl", directory: "")
!384 = !DILocation(line: 132, column: 12, scope: !385)
!385 = !DILexicalBlockFile(scope: !382, file: !383, discriminator: 0)
!386 = !DILocation(line: 132, column: 5, scope: !385)
!387 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.get_y_coord", scope: null, file: !383, line: 134, type: !5, scopeLine: 134, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!388 = !DILocation(line: 135, column: 12, scope: !389)
!389 = !DILexicalBlockFile(scope: !387, file: !383, discriminator: 0)
!390 = !DILocation(line: 135, column: 5, scope: !389)
!391 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.is_streaming_eval", scope: null, file: !383, line: 148, type: !5, scopeLine: 148, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!392 = !DILocation(line: 148, column: 23, scope: !393)
!393 = !DILexicalBlockFile(scope: !391, file: !383, discriminator: 0)
!394 = !DILocation(line: 149, column: 9, scope: !393)
!395 = !DILocation(line: 149, column: 20, scope: !393)
!396 = !DILocation(line: 149, column: 5, scope: !393)
!397 = !DILocation(line: 152, column: 23, scope: !393)
!398 = !DILocation(line: 152, column: 20, scope: !393)
!399 = !DILocation(line: 152, column: 9, scope: !393)
!400 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.memcpyh2d_start", scope: null, file: !383, line: 226, type: !5, scopeLine: 226, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!401 = !DILocation(line: 233, column: 5, scope: !402)
!402 = !DILexicalBlockFile(scope: !400, file: !383, discriminator: 0)
!403 = !DILocation(line: 226, column: 49, scope: !402)
!404 = !DILocation(line: 226, column: 32, scope: !402)
!405 = !DILocation(line: 226, column: 21, scope: !402)
!406 = !DILocation(line: 229, column: 37, scope: !402)
!407 = !DILocation(line: 229, column: 52, scope: !402)
!408 = !DILocation(line: 229, column: 19, scope: !402)
!409 = !DILocation(line: 233, column: 71, scope: !402)
!410 = !DILocation(line: 233, column: 55, scope: !402)
!411 = !DILocation(line: 233, column: 25, scope: !402)
!412 = !DILocation(line: 235, column: 37, scope: !402)
!413 = !DILocation(line: 235, column: 52, scope: !402)
!414 = !DILocation(line: 235, column: 19, scope: !402)
!415 = !DILocation(line: 236, column: 28, scope: !402)
!416 = !DILocation(line: 236, column: 5, scope: !402)
!417 = !DILocation(line: 237, column: 28, scope: !402)
!418 = !DILocation(line: 237, column: 5, scope: !402)
!419 = !DILocation(line: 238, column: 13, scope: !402)
!420 = !DILocation(line: 238, column: 11, scope: !402)
!421 = !DILocation(line: 238, column: 5, scope: !402)
!422 = !DILocation(line: 239, column: 9, scope: !402)
!423 = !DILocation(line: 241, column: 9, scope: !402)
!424 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.unblock_cmd_stream", scope: null, file: !383, line: 249, type: !5, scopeLine: 249, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!425 = !DILocation(line: 250, column: 5, scope: !426)
!426 = !DILexicalBlockFile(scope: !424, file: !383, discriminator: 0)
!427 = !DILocation(line: 249, column: 1, scope: !426)
!428 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.h2d_configure", scope: null, file: !383, line: 276, type: !5, scopeLine: 276, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!429 = !DILocation(line: 414, column: 13, scope: !430)
!430 = !DILexicalBlockFile(scope: !428, file: !383, discriminator: 0)
!431 = !DILocation(line: 413, column: 13, scope: !430)
!432 = !DILocation(line: 400, column: 17, scope: !430)
!433 = !DILocation(line: 340, column: 9, scope: !430)
!434 = !DILocation(line: 339, column: 9, scope: !430)
!435 = !DILocation(line: 337, column: 5, scope: !430)
!436 = !DILocation(line: 319, column: 9, scope: !430)
!437 = !DILocation(line: 318, column: 9, scope: !430)
!438 = !DILocation(line: 315, column: 5, scope: !430)
!439 = !DILocation(line: 292, column: 5, scope: !430)
!440 = !DILocation(line: 291, column: 5, scope: !430)
!441 = !DILocation(line: 289, column: 5, scope: !430)
!442 = !DILocation(line: 288, column: 5, scope: !430)
!443 = !DILocation(line: 287, column: 5, scope: !430)
!444 = !DILocation(line: 286, column: 5, scope: !430)
!445 = !DILocation(line: 285, column: 5, scope: !430)
!446 = !DILocation(line: 284, column: 5, scope: !430)
!447 = !DILocation(line: 283, column: 5, scope: !430)
!448 = !DILocation(line: 282, column: 5, scope: !430)
!449 = !DILocation(line: 281, column: 5, scope: !430)
!450 = !DILocation(line: 280, column: 5, scope: !430)
!451 = !DILocation(line: 279, column: 5, scope: !430)
!452 = !DILocation(line: 278, column: 5, scope: !430)
!453 = !DILocation(line: 277, column: 5, scope: !430)
!454 = !DILocation(line: 291, column: 26, scope: !430)
!455 = !DILocation(line: 292, column: 26, scope: !430)
!456 = !DILocation(line: 315, column: 25, scope: !430)
!457 = !DILocation(line: 315, column: 31, scope: !430)
!458 = !DILocation(line: 315, column: 29, scope: !430)
!459 = !DILocation(line: 316, column: 20, scope: !430)
!460 = !DILocation(line: 316, column: 18, scope: !430)
!461 = !DILocation(line: 317, column: 52, scope: !430)
!462 = !DILocation(line: 317, column: 49, scope: !430)
!463 = !DILocation(line: 317, column: 5, scope: !430)
!464 = !DILocation(line: 318, column: 42, scope: !430)
!465 = !DILocation(line: 318, column: 33, scope: !430)
!466 = !DILocation(line: 318, column: 49, scope: !430)
!467 = !DILocation(line: 318, column: 48, scope: !430)
!468 = !DILocation(line: 318, column: 24, scope: !430)
!469 = !DILocation(line: 319, column: 24, scope: !430)
!470 = !DILocation(line: 319, column: 32, scope: !430)
!471 = !DILocation(line: 319, column: 36, scope: !430)
!472 = !DILocation(line: 319, column: 34, scope: !430)
!473 = !DILocation(line: 319, column: 30, scope: !430)
!474 = !DILocation(line: 320, column: 18, scope: !430)
!475 = !DILocation(line: 320, column: 15, scope: !430)
!476 = !DILocation(line: 320, column: 9, scope: !430)
!477 = !DILocation(line: 321, column: 26, scope: !430)
!478 = !DILocation(line: 325, column: 28, scope: !430)
!479 = !DILocation(line: 325, column: 26, scope: !430)
!480 = !DILocation(line: 331, column: 9, scope: !430)
!481 = !DILocation(line: 331, column: 15, scope: !430)
!482 = !DILocation(line: 331, column: 5, scope: !430)
!483 = !DILocation(line: 332, column: 22, scope: !430)
!484 = !DILocation(line: 334, column: 9, scope: !430)
!485 = !DILocation(line: 334, column: 18, scope: !430)
!486 = !DILocation(line: 334, column: 15, scope: !430)
!487 = !DILocation(line: 334, column: 5, scope: !430)
!488 = !DILocation(line: 335, column: 22, scope: !430)
!489 = !DILocation(line: 338, column: 52, scope: !430)
!490 = !DILocation(line: 338, column: 49, scope: !430)
!491 = !DILocation(line: 338, column: 5, scope: !430)
!492 = !DILocation(line: 339, column: 42, scope: !430)
!493 = !DILocation(line: 339, column: 48, scope: !430)
!494 = !DILocation(line: 339, column: 46, scope: !430)
!495 = !DILocation(line: 339, column: 33, scope: !430)
!496 = !DILocation(line: 339, column: 52, scope: !430)
!497 = !DILocation(line: 339, column: 51, scope: !430)
!498 = !DILocation(line: 339, column: 24, scope: !430)
!499 = !DILocation(line: 340, column: 25, scope: !430)
!500 = !DILocation(line: 340, column: 31, scope: !430)
!501 = !DILocation(line: 340, column: 29, scope: !430)
!502 = !DILocation(line: 340, column: 37, scope: !430)
!503 = !DILocation(line: 340, column: 41, scope: !430)
!504 = !DILocation(line: 340, column: 39, scope: !430)
!505 = !DILocation(line: 340, column: 35, scope: !430)
!506 = !DILocation(line: 341, column: 18, scope: !430)
!507 = !DILocation(line: 341, column: 15, scope: !430)
!508 = !DILocation(line: 341, column: 9, scope: !430)
!509 = !DILocation(line: 342, column: 26, scope: !430)
!510 = !DILocation(line: 347, column: 10, scope: !430)
!511 = !DILocation(line: 347, column: 16, scope: !430)
!512 = !DILocation(line: 347, column: 14, scope: !430)
!513 = !DILocation(line: 347, column: 5, scope: !430)
!514 = !DILocation(line: 348, column: 22, scope: !430)
!515 = !DILocation(line: 350, column: 10, scope: !430)
!516 = !DILocation(line: 350, column: 18, scope: !430)
!517 = !DILocation(line: 350, column: 21, scope: !430)
!518 = !DILocation(line: 350, column: 20, scope: !430)
!519 = !DILocation(line: 350, column: 14, scope: !430)
!520 = !DILocation(line: 350, column: 5, scope: !430)
!521 = !DILocation(line: 351, column: 22, scope: !430)
!522 = !DILocation(line: 354, column: 9, scope: !430)
!523 = !DILocation(line: 354, column: 5, scope: !430)
!524 = !DILocation(line: 358, column: 9, scope: !430)
!525 = !DILocation(line: 361, column: 9, scope: !430)
!526 = !DILocation(line: 364, column: 20, scope: !430)
!527 = !DILocation(line: 364, column: 17, scope: !430)
!528 = !DILocation(line: 364, column: 9, scope: !430)
!529 = !DILocation(line: 368, column: 13, scope: !430)
!530 = !DILocation(line: 371, column: 13, scope: !430)
!531 = !DILocation(line: 375, column: 13, scope: !430)
!532 = !DILocation(line: 394, column: 13, scope: !430)
!533 = !DILocation(line: 396, column: 29, scope: !430)
!534 = !DILocation(line: 396, column: 27, scope: !430)
!535 = !DILocation(line: 397, column: 60, scope: !430)
!536 = !DILocation(line: 397, column: 57, scope: !430)
!537 = !DILocation(line: 397, column: 13, scope: !430)
!538 = !DILocation(line: 400, column: 54, scope: !430)
!539 = !DILocation(line: 400, column: 55, scope: !430)
!540 = !DILocation(line: 400, column: 46, scope: !430)
!541 = !DILocation(line: 400, column: 59, scope: !430)
!542 = !DILocation(line: 400, column: 58, scope: !430)
!543 = !DILocation(line: 400, column: 37, scope: !430)
!544 = !DILocation(line: 400, column: 35, scope: !430)
!545 = !DILocation(line: 401, column: 33, scope: !430)
!546 = !DILocation(line: 401, column: 31, scope: !430)
!547 = !DILocation(line: 402, column: 69, scope: !430)
!548 = !DILocation(line: 402, column: 66, scope: !430)
!549 = !DILocation(line: 402, column: 19, scope: !430)
!550 = !DILocation(line: 404, column: 31, scope: !430)
!551 = !DILocation(line: 408, column: 75, scope: !430)
!552 = !DILocation(line: 408, column: 88, scope: !430)
!553 = !DILocation(line: 408, column: 13, scope: !430)
!554 = !DILocation(line: 413, column: 31, scope: !430)
!555 = !DILocation(line: 414, column: 33, scope: !430)
!556 = !DILocation(line: 415, column: 21, scope: !430)
!557 = !DILocation(line: 415, column: 29, scope: !430)
!558 = !DILocation(line: 415, column: 27, scope: !430)
!559 = !DILocation(line: 415, column: 19, scope: !430)
!560 = !DILocation(line: 416, column: 22, scope: !430)
!561 = !DILocation(line: 416, column: 19, scope: !430)
!562 = !DILocation(line: 416, column: 13, scope: !430)
!563 = !DILocation(line: 417, column: 23, scope: !430)
!564 = !DILocation(line: 419, column: 63, scope: !430)
!565 = !DILocation(line: 419, column: 60, scope: !430)
!566 = !DILocation(line: 419, column: 13, scope: !430)
!567 = !DILocation(line: 421, column: 23, scope: !430)
!568 = !DILocation(line: 423, column: 69, scope: !430)
!569 = !DILocation(line: 423, column: 13, scope: !430)
!570 = !DILocation(line: 426, column: 13, scope: !430)
!571 = !DILocation(line: 430, column: 13, scope: !430)
!572 = !DILocation(line: 433, column: 48, scope: !430)
!573 = !DILocation(line: 433, column: 22, scope: !430)
!574 = !DILocation(line: 433, column: 19, scope: !430)
!575 = !DILocation(line: 433, column: 13, scope: !430)
!576 = !DILocation(line: 436, column: 34, scope: !430)
!577 = !DILocation(line: 436, column: 39, scope: !430)
!578 = !DILocation(line: 436, column: 50, scope: !430)
!579 = !DILocation(line: 436, column: 17, scope: !430)
!580 = !DILocation(line: 452, column: 49, scope: !430)
!581 = !DILocation(line: 452, column: 64, scope: !430)
!582 = !DILocation(line: 452, column: 31, scope: !430)
!583 = !DILocation(line: 453, column: 40, scope: !430)
!584 = !DILocation(line: 453, column: 17, scope: !430)
!585 = !DILocation(line: 454, column: 50, scope: !430)
!586 = !DILocation(line: 454, column: 66, scope: !430)
!587 = !DILocation(line: 454, column: 32, scope: !430)
!588 = !DILocation(line: 455, column: 40, scope: !430)
!589 = !DILocation(line: 455, column: 17, scope: !430)
!590 = !DILocation(line: 456, column: 17, scope: !430)
!591 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_active_limit", scope: null, file: !592, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!592 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/filters/wse3.csl", directory: "")
!593 = !DILocation(line: 24, column: 3, scope: !594)
!594 = !DILexicalBlockFile(scope: !591, file: !592, discriminator: 0)
!595 = !DILocation(line: 24, column: 22, scope: !594)
!596 = !DILocation(line: 23, column: 3, scope: !594)
!597 = !DILocation(line: 22, column: 3, scope: !594)
!598 = !DILocation(line: 20, column: 37, scope: !594)
!599 = !DILocation(line: 20, column: 21, scope: !594)
!600 = !DILocation(line: 21, column: 11, scope: !594)
!601 = !DILocation(line: 21, column: 17, scope: !594)
!602 = !DILocation(line: 21, column: 3, scope: !594)
!603 = !DILocation(line: 22, column: 24, scope: !594)
!604 = !DILocation(line: 22, column: 30, scope: !594)
!605 = !DILocation(line: 23, column: 40, scope: !594)
!606 = !DILocation(line: 23, column: 22, scope: !594)
!607 = !DILocation(line: 23, column: 67, scope: !594)
!608 = !DILocation(line: 24, column: 26, scope: !594)
!609 = !DILocation(line: 24, column: 41, scope: !594)
!610 = !DILocation(line: 24, column: 39, scope: !594)
!611 = !DILocation(line: 24, column: 61, scope: !594)
!612 = !DILocation(line: 24, column: 76, scope: !594)
!613 = !DILocation(line: 24, column: 74, scope: !594)
!614 = !DILocation(line: 25, column: 21, scope: !594)
!615 = !DILocation(line: 25, column: 50, scope: !594)
!616 = !DILocation(line: 25, column: 3, scope: !594)
!617 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_max_counter", scope: null, file: !592, line: 30, type: !5, scopeLine: 30, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!618 = !DILocation(line: 30, column: 36, scope: !619)
!619 = !DILexicalBlockFile(scope: !617, file: !592, discriminator: 0)
!620 = !DILocation(line: 30, column: 20, scope: !619)
!621 = !DILocation(line: 31, column: 11, scope: !619)
!622 = !DILocation(line: 31, column: 23, scope: !619)
!623 = !DILocation(line: 31, column: 3, scope: !619)
!624 = !DILocation(line: 32, column: 21, scope: !619)
!625 = !DILocation(line: 32, column: 48, scope: !619)
!626 = !DILocation(line: 32, column: 60, scope: !619)
!627 = !DILocation(line: 32, column: 64, scope: !619)
!628 = !DILocation(line: 32, column: 3, scope: !619)
!629 = !DILocation(line: 30, column: 1, scope: !619)
!630 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.set_counter", scope: null, file: !592, line: 40, type: !5, scopeLine: 40, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!631 = !DILocation(line: 47, column: 3, scope: !632)
!632 = !DILexicalBlockFile(scope: !630, file: !592, discriminator: 0)
!633 = !DILocation(line: 48, column: 7, scope: !632)
!634 = !DILocation(line: 44, column: 3, scope: !632)
!635 = !DILocation(line: 43, column: 3, scope: !632)
!636 = !DILocation(line: 42, column: 3, scope: !632)
!637 = !DILocation(line: 40, column: 32, scope: !632)
!638 = !DILocation(line: 40, column: 16, scope: !632)
!639 = !DILocation(line: 41, column: 11, scope: !632)
!640 = !DILocation(line: 41, column: 19, scope: !632)
!641 = !DILocation(line: 41, column: 3, scope: !632)
!642 = !DILocation(line: 42, column: 40, scope: !632)
!643 = !DILocation(line: 42, column: 22, scope: !632)
!644 = !DILocation(line: 43, column: 26, scope: !632)
!645 = !DILocation(line: 43, column: 34, scope: !632)
!646 = !DILocation(line: 44, column: 25, scope: !632)
!647 = !DILocation(line: 44, column: 42, scope: !632)
!648 = !DILocation(line: 44, column: 40, scope: !632)
!649 = !DILocation(line: 45, column: 21, scope: !632)
!650 = !DILocation(line: 46, column: 35, scope: !632)
!651 = !DILocation(line: 46, column: 21, scope: !632)
!652 = !DILocation(line: 46, column: 50, scope: !632)
!653 = !DILocation(line: 45, column: 3, scope: !632)
!654 = !DILocation(line: 48, column: 11, scope: !632)
!655 = !DILocation(line: 48, column: 26, scope: !632)
!656 = !DILocation(line: 48, column: 43, scope: !632)
!657 = !DILocation(line: 48, column: 41, scope: !632)
!658 = !DILocation(line: 48, column: 54, scope: !632)
!659 = !DILocation(line: 48, column: 63, scope: !632)
!660 = !DILocation(line: 49, column: 21, scope: !632)
!661 = !DILocation(line: 49, column: 47, scope: !632)
!662 = !DILocation(line: 49, column: 3, scope: !632)
!663 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.set_config", scope: null, file: !664, line: 33, type: !5, scopeLine: 33, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!664 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/filters/common.csl", directory: "")
!665 = !DILocation(line: 33, column: 46, scope: !666)
!666 = !DILexicalBlockFile(scope: !663, file: !664, discriminator: 0)
!667 = !DILocation(line: 33, column: 31, scope: !666)
!668 = !DILocation(line: 33, column: 15, scope: !666)
!669 = !DILocation(line: 34, column: 24, scope: !666)
!670 = !DILocation(line: 34, column: 23, scope: !666)
!671 = !DILocation(line: 34, column: 51, scope: !666)
!672 = !DILocation(line: 34, column: 35, scope: !666)
!673 = !DILocation(line: 34, column: 60, scope: !666)
!674 = !DILocation(line: 34, column: 73, scope: !666)
!675 = !DILocation(line: 34, column: 3, scope: !666)
!676 = !DILocation(line: 33, column: 1, scope: !666)
!677 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.filters.common.get_config", scope: null, file: !664, line: 38, type: !5, scopeLine: 38, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!678 = !DILocation(line: 38, column: 31, scope: !679)
!679 = !DILexicalBlockFile(scope: !677, file: !664, discriminator: 0)
!680 = !DILocation(line: 38, column: 15, scope: !679)
!681 = !DILocation(line: 39, column: 31, scope: !679)
!682 = !DILocation(line: 39, column: 30, scope: !679)
!683 = !DILocation(line: 39, column: 58, scope: !679)
!684 = !DILocation(line: 39, column: 42, scope: !679)
!685 = !DILocation(line: 39, column: 67, scope: !679)
!686 = !DILocation(line: 39, column: 10, scope: !679)
!687 = !DILocation(line: 39, column: 3, scope: !679)
!688 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.teardown.exit", scope: null, file: !689, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!689 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/teardown.csl", directory: "")
!690 = !DILocation(line: 43, column: 3, scope: !691)
!691 = !DILexicalBlockFile(scope: !688, file: !689, discriminator: 0)
!692 = !DILocation(line: 41, column: 3, scope: !691)
!693 = !DILocation(line: 40, column: 3, scope: !691)
!694 = !DILocation(line: 39, column: 9, scope: !691)
!695 = !DILocation(line: 40, column: 23, scope: !691)
!696 = !DILocation(line: 41, column: 70, scope: !691)
!697 = !DILocation(line: 41, column: 68, scope: !691)
!698 = !DILocation(line: 43, column: 27, scope: !691)
!699 = !DILocation(line: 43, column: 15, scope: !691)
!700 = !DILocation(line: 44, column: 15, scope: !691)
!701 = !DILocation(line: 44, column: 21, scope: !691)
!702 = !DILocation(line: 44, column: 27, scope: !691)
!703 = !DILocation(line: 44, column: 3, scope: !691)
!704 = !DILocation(line: 39, column: 1, scope: !691)
!705 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_x_coord", scope: null, file: !706, line: 4, type: !5, scopeLine: 4, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!706 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/layout.csl", directory: "")
!707 = !DILocation(line: 5, column: 10, scope: !708)
!708 = !DILexicalBlockFile(scope: !705, file: !706, discriminator: 0)
!709 = !DILocation(line: 5, column: 67, scope: !708)
!710 = !DILocation(line: 5, column: 3, scope: !708)
!711 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.get_y_coord", scope: null, file: !706, line: 8, type: !5, scopeLine: 8, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!712 = !DILocation(line: 9, column: 10, scope: !713)
!713 = !DILexicalBlockFile(scope: !711, file: !706, discriminator: 0)
!714 = !DILocation(line: 9, column: 67, scope: !713)
!715 = !DILocation(line: 9, column: 3, scope: !713)
!716 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord", linkageName: "sys_mod.sys_mod.memcpyh2d_mod_1.fabric.tile_config.get_fabric_coord", scope: null, file: !717, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!717 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config.csl", directory: "")
!718 = !DILocation(line: 50, column: 3, scope: !719)
!719 = !DILexicalBlockFile(scope: !716, file: !717, discriminator: 0)
!720 = !DILocation(line: 43, column: 21, scope: !719)
!721 = !DILocation(line: 50, column: 57, scope: !719)
!722 = !DILocation(line: 50, column: 68, scope: !719)
!723 = !DILocation(line: 50, column: 41, scope: !719)
!724 = !DILocation(line: 50, column: 19, scope: !719)
!725 = !DILocation(line: 52, column: 10, scope: !719)
!726 = !DILocation(line: 52, column: 18, scope: !719)
!727 = !DILocation(line: 48, column: 22, scope: !719)
!728 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.get_x_coord", scope: null, file: !729, line: 171, type: !5, scopeLine: 171, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!729 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/memcpy/wse3/memcpyd2h.csl", directory: "")
!730 = !DILocation(line: 172, column: 12, scope: !731)
!731 = !DILexicalBlockFile(scope: !728, file: !729, discriminator: 0)
!732 = !DILocation(line: 172, column: 5, scope: !731)
!733 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.get_y_coord", scope: null, file: !729, line: 174, type: !5, scopeLine: 174, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!734 = !DILocation(line: 175, column: 12, scope: !735)
!735 = !DILexicalBlockFile(scope: !733, file: !729, discriminator: 0)
!736 = !DILocation(line: 175, column: 5, scope: !735)
!737 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.is_streaming_eval", scope: null, file: !729, line: 187, type: !5, scopeLine: 187, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!738 = !DILocation(line: 187, column: 23, scope: !739)
!739 = !DILexicalBlockFile(scope: !737, file: !729, discriminator: 0)
!740 = !DILocation(line: 188, column: 9, scope: !739)
!741 = !DILocation(line: 188, column: 20, scope: !739)
!742 = !DILocation(line: 188, column: 5, scope: !739)
!743 = !DILocation(line: 191, column: 23, scope: !739)
!744 = !DILocation(line: 191, column: 20, scope: !739)
!745 = !DILocation(line: 191, column: 9, scope: !739)
!746 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.memcpyd2h_start", scope: null, file: !729, line: 383, type: !5, scopeLine: 383, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!747 = !DILocation(line: 386, column: 5, scope: !748)
!748 = !DILexicalBlockFile(scope: !746, file: !729, discriminator: 0)
!749 = !DILocation(line: 384, column: 72, scope: !748)
!750 = !DILocation(line: 384, column: 59, scope: !748)
!751 = !DILocation(line: 384, column: 46, scope: !748)
!752 = !DILocation(line: 384, column: 33, scope: !748)
!753 = !DILocation(line: 384, column: 19, scope: !748)
!754 = !DILocation(line: 384, column: 5, scope: !748)
!755 = !DILocation(line: 383, column: 32, scope: !748)
!756 = !DILocation(line: 383, column: 21, scope: !748)
!757 = !DILocation(line: 386, column: 26, scope: !748)
!758 = !DILocation(line: 388, column: 28, scope: !748)
!759 = !DILocation(line: 388, column: 17, scope: !748)
!760 = !DILocation(line: 389, column: 25, scope: !748)
!761 = !DILocation(line: 389, column: 23, scope: !748)
!762 = !DILocation(line: 391, column: 38, scope: !748)
!763 = !DILocation(line: 391, column: 20, scope: !748)
!764 = !DILocation(line: 391, column: 18, scope: !748)
!765 = !DILocation(line: 393, column: 7, scope: !748)
!766 = !DILocation(line: 395, column: 17, scope: !748)
!767 = !DILocation(line: 395, column: 15, scope: !748)
!768 = !DILocation(line: 397, column: 15, scope: !748)
!769 = !DILocation(line: 397, column: 13, scope: !748)
!770 = !DILocation(line: 398, column: 15, scope: !748)
!771 = !DILocation(line: 398, column: 25, scope: !748)
!772 = !DILocation(line: 398, column: 23, scope: !748)
!773 = !DILocation(line: 398, column: 31, scope: !748)
!774 = !DILocation(line: 398, column: 13, scope: !748)
!775 = !DILocation(line: 401, column: 10, scope: !748)
!776 = !DILocation(line: 401, column: 17, scope: !748)
!777 = !DILocation(line: 401, column: 14, scope: !748)
!778 = !DILocation(line: 401, column: 5, scope: !748)
!779 = !DILocation(line: 403, column: 48, scope: !748)
!780 = !DILocation(line: 403, column: 26, scope: !748)
!781 = !DILocation(line: 404, column: 26, scope: !748)
!782 = !DILocation(line: 404, column: 18, scope: !748)
!783 = !DILocation(line: 407, column: 48, scope: !748)
!784 = !DILocation(line: 407, column: 26, scope: !748)
!785 = !DILocation(line: 408, column: 27, scope: !748)
!786 = !DILocation(line: 408, column: 18, scope: !748)
!787 = !DILocation(line: 411, column: 14, scope: !748)
!788 = !DILocation(line: 414, column: 14, scope: !748)
!789 = !DILocation(line: 414, column: 11, scope: !748)
!790 = !DILocation(line: 414, column: 5, scope: !748)
!791 = !DILocation(line: 416, column: 44, scope: !748)
!792 = !DILocation(line: 416, column: 75, scope: !748)
!793 = !DILocation(line: 416, column: 59, scope: !748)
!794 = !DILocation(line: 416, column: 25, scope: !748)
!795 = !DILocation(line: 416, column: 23, scope: !748)
!796 = !DILocation(line: 418, column: 41, scope: !748)
!797 = !DILocation(line: 418, column: 23, scope: !748)
!798 = !DILocation(line: 419, column: 9, scope: !748)
!799 = !DILocation(line: 425, column: 44, scope: !748)
!800 = !DILocation(line: 425, column: 23, scope: !748)
!801 = !DILocation(line: 426, column: 41, scope: !748)
!802 = !DILocation(line: 426, column: 23, scope: !748)
!803 = !DILocation(line: 427, column: 9, scope: !748)
!804 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_user_memcpyd2h_data_x", scope: null, file: !729, line: 448, type: !5, scopeLine: 448, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!805 = !DILocation(line: 448, column: 31, scope: !806)
!806 = !DILexicalBlockFile(scope: !804, file: !729, discriminator: 0)
!807 = !DILocation(line: 453, column: 5, scope: !806)
!808 = !DILocation(line: 456, column: 19, scope: !806)
!809 = !DILocation(line: 456, column: 17, scope: !806)
!810 = !DILocation(line: 461, column: 5, scope: !806)
!811 = !DILocation(line: 462, column: 28, scope: !806)
!812 = !DILocation(line: 462, column: 5, scope: !806)
!813 = !DILocation(line: 463, column: 5, scope: !806)
!814 = !DILocation(line: 464, column: 9, scope: !806)
!815 = !DILocation(line: 464, column: 10, scope: !806)
!816 = !DILocation(line: 464, column: 7, scope: !806)
!817 = !DILocation(line: 448, column: 1, scope: !806)
!818 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_send_data", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_send_data", scope: null, file: !729, line: 476, type: !5, scopeLine: 476, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!819 = !DILocation(line: 494, column: 9, scope: !820)
!820 = !DILexicalBlockFile(scope: !818, file: !729, discriminator: 0)
!821 = !DILocation(line: 478, column: 9, scope: !820)
!822 = !DILocation(line: 478, column: 13, scope: !820)
!823 = !DILocation(line: 478, column: 11, scope: !820)
!824 = !DILocation(line: 478, column: 5, scope: !820)
!825 = !DILocation(line: 479, column: 9, scope: !820)
!826 = !DILocation(line: 480, column: 32, scope: !820)
!827 = !DILocation(line: 480, column: 9, scope: !820)
!828 = !DILocation(line: 481, column: 17, scope: !820)
!829 = !DILocation(line: 481, column: 15, scope: !820)
!830 = !DILocation(line: 481, column: 9, scope: !820)
!831 = !DILocation(line: 482, column: 13, scope: !820)
!832 = !DILocation(line: 483, column: 51, scope: !820)
!833 = !DILocation(line: 483, column: 29, scope: !820)
!834 = !DILocation(line: 483, column: 27, scope: !820)
!835 = !DILocation(line: 485, column: 13, scope: !820)
!836 = !DILocation(line: 486, column: 51, scope: !820)
!837 = !DILocation(line: 486, column: 29, scope: !820)
!838 = !DILocation(line: 486, column: 27, scope: !820)
!839 = !DILocation(line: 488, column: 13, scope: !820)
!840 = !DILocation(line: 488, column: 14, scope: !820)
!841 = !DILocation(line: 488, column: 11, scope: !820)
!842 = !DILocation(line: 494, column: 30, scope: !820)
!843 = !DILocation(line: 496, column: 14, scope: !820)
!844 = !DILocation(line: 496, column: 25, scope: !820)
!845 = !DILocation(line: 496, column: 22, scope: !820)
!846 = !DILocation(line: 496, column: 9, scope: !820)
!847 = !DILocation(line: 497, column: 13, scope: !820)
!848 = !DILocation(line: 498, column: 13, scope: !820)
!849 = !DILocation(line: 499, column: 13, scope: !820)
!850 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.f_send_ctrl", scope: null, file: !729, line: 505, type: !5, scopeLine: 505, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!851 = !DILocation(line: 524, column: 13, scope: !852)
!852 = !DILexicalBlockFile(scope: !850, file: !729, discriminator: 0)
!853 = !DILocation(line: 506, column: 14, scope: !852)
!854 = !DILocation(line: 506, column: 11, scope: !852)
!855 = !DILocation(line: 506, column: 5, scope: !852)
!856 = !DILocation(line: 508, column: 9, scope: !852)
!857 = !DILocation(line: 509, column: 32, scope: !852)
!858 = !DILocation(line: 509, column: 9, scope: !852)
!859 = !DILocation(line: 510, column: 9, scope: !852)
!860 = !DILocation(line: 514, column: 13, scope: !852)
!861 = !DILocation(line: 514, column: 17, scope: !852)
!862 = !DILocation(line: 514, column: 15, scope: !852)
!863 = !DILocation(line: 514, column: 9, scope: !852)
!864 = !DILocation(line: 518, column: 13, scope: !852)
!865 = !DILocation(line: 519, column: 36, scope: !852)
!866 = !DILocation(line: 519, column: 13, scope: !852)
!867 = !DILocation(line: 520, column: 13, scope: !852)
!868 = !DILocation(line: 524, column: 34, scope: !852)
!869 = !DILocation(line: 526, column: 18, scope: !852)
!870 = !DILocation(line: 526, column: 29, scope: !852)
!871 = !DILocation(line: 526, column: 26, scope: !852)
!872 = !DILocation(line: 526, column: 13, scope: !852)
!873 = !DILocation(line: 529, column: 17, scope: !852)
!874 = !DILocation(line: 530, column: 17, scope: !852)
!875 = !DILocation(line: 531, column: 17, scope: !852)
!876 = !DILocation(line: 534, column: 17, scope: !852)
!877 = !DILocation(line: 535, column: 40, scope: !852)
!878 = !DILocation(line: 535, column: 17, scope: !852)
!879 = !DILocation(line: 536, column: 17, scope: !852)
!880 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.d2h_configure", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.d2h_configure", scope: null, file: !729, line: 593, type: !5, scopeLine: 593, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!881 = !DILocation(line: 617, column: 26, scope: !882)
!882 = !DILexicalBlockFile(scope: !880, file: !729, discriminator: 0)
!883 = !DILocation(line: 612, column: 47, scope: !882)
!884 = !DILocation(line: 612, column: 27, scope: !882)
!885 = !DILocation(line: 602, column: 5, scope: !882)
!886 = !DILocation(line: 601, column: 5, scope: !882)
!887 = !DILocation(line: 599, column: 5, scope: !882)
!888 = !DILocation(line: 598, column: 5, scope: !882)
!889 = !DILocation(line: 596, column: 5, scope: !882)
!890 = !DILocation(line: 595, column: 5, scope: !882)
!891 = !DILocation(line: 593, column: 86, scope: !882)
!892 = !DILocation(line: 593, column: 70, scope: !882)
!893 = !DILocation(line: 593, column: 60, scope: !882)
!894 = !DILocation(line: 593, column: 52, scope: !882)
!895 = !DILocation(line: 593, column: 44, scope: !882)
!896 = !DILocation(line: 593, column: 35, scope: !882)
!897 = !DILocation(line: 593, column: 26, scope: !882)
!898 = !DILocation(line: 593, column: 18, scope: !882)
!899 = !DILocation(line: 595, column: 26, scope: !882)
!900 = !DILocation(line: 596, column: 26, scope: !882)
!901 = !DILocation(line: 598, column: 23, scope: !882)
!902 = !DILocation(line: 599, column: 23, scope: !882)
!903 = !DILocation(line: 599, column: 28, scope: !882)
!904 = !DILocation(line: 599, column: 26, scope: !882)
!905 = !DILocation(line: 599, column: 29, scope: !882)
!906 = !DILocation(line: 601, column: 24, scope: !882)
!907 = !DILocation(line: 602, column: 24, scope: !882)
!908 = !DILocation(line: 602, column: 29, scope: !882)
!909 = !DILocation(line: 602, column: 27, scope: !882)
!910 = !DILocation(line: 602, column: 30, scope: !882)
!911 = !DILocation(line: 611, column: 20, scope: !882)
!912 = !DILocation(line: 612, column: 11, scope: !882)
!913 = !DILocation(line: 612, column: 18, scope: !882)
!914 = !DILocation(line: 612, column: 15, scope: !882)
!915 = !DILocation(line: 612, column: 32, scope: !882)
!916 = !DILocation(line: 612, column: 39, scope: !882)
!917 = !DILocation(line: 612, column: 36, scope: !882)
!918 = !DILocation(line: 612, column: 52, scope: !882)
!919 = !DILocation(line: 612, column: 59, scope: !882)
!920 = !DILocation(line: 612, column: 56, scope: !882)
!921 = !DILocation(line: 612, column: 5, scope: !882)
!922 = !DILocation(line: 613, column: 24, scope: !882)
!923 = !DILocation(line: 616, column: 15, scope: !882)
!924 = !DILocation(line: 617, column: 11, scope: !882)
!925 = !DILocation(line: 617, column: 18, scope: !882)
!926 = !DILocation(line: 617, column: 15, scope: !882)
!927 = !DILocation(line: 617, column: 30, scope: !882)
!928 = !DILocation(line: 617, column: 5, scope: !882)
!929 = !DILocation(line: 618, column: 19, scope: !882)
!930 = !DILocation(line: 621, column: 9, scope: !882)
!931 = !DILocation(line: 621, column: 5, scope: !882)
!932 = !DILocation(line: 627, column: 9, scope: !882)
!933 = !DILocation(line: 629, column: 13, scope: !882)
!934 = !DILocation(line: 629, column: 25, scope: !882)
!935 = !DILocation(line: 629, column: 21, scope: !882)
!936 = !DILocation(line: 629, column: 9, scope: !882)
!937 = !DILocation(line: 632, column: 13, scope: !882)
!938 = !DILocation(line: 636, column: 13, scope: !882)
!939 = !DILocation(line: 641, column: 9, scope: !882)
!940 = !DILocation(line: 646, column: 13, scope: !882)
!941 = !DILocation(line: 646, column: 9, scope: !882)
!942 = !DILocation(line: 647, column: 30, scope: !882)
!943 = !DILocation(line: 647, column: 35, scope: !882)
!944 = !DILocation(line: 647, column: 46, scope: !882)
!945 = !DILocation(line: 647, column: 50, scope: !882)
!946 = !DILocation(line: 647, column: 54, scope: !882)
!947 = !DILocation(line: 647, column: 57, scope: !882)
!948 = !DILocation(line: 647, column: 60, scope: !882)
!949 = !DILocation(line: 647, column: 63, scope: !882)
!950 = !DILocation(line: 647, column: 13, scope: !882)
!951 = !DILocation(line: 661, column: 9, scope: !882)
!952 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.tile_config.teardown.exit", scope: null, file: !689, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!953 = !DILocation(line: 43, column: 3, scope: !954)
!954 = !DILexicalBlockFile(scope: !952, file: !689, discriminator: 0)
!955 = !DILocation(line: 41, column: 3, scope: !954)
!956 = !DILocation(line: 40, column: 3, scope: !954)
!957 = !DILocation(line: 39, column: 9, scope: !954)
!958 = !DILocation(line: 40, column: 23, scope: !954)
!959 = !DILocation(line: 41, column: 70, scope: !954)
!960 = !DILocation(line: 41, column: 68, scope: !954)
!961 = !DILocation(line: 43, column: 27, scope: !954)
!962 = !DILocation(line: 43, column: 15, scope: !954)
!963 = !DILocation(line: 44, column: 15, scope: !954)
!964 = !DILocation(line: 44, column: 21, scope: !954)
!965 = !DILocation(line: 44, column: 27, scope: !954)
!966 = !DILocation(line: 44, column: 3, scope: !954)
!967 = !DILocation(line: 39, column: 1, scope: !954)
!968 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_x_coord", scope: null, file: !706, line: 4, type: !5, scopeLine: 4, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!969 = !DILocation(line: 5, column: 10, scope: !970)
!970 = !DILexicalBlockFile(scope: !968, file: !706, discriminator: 0)
!971 = !DILocation(line: 5, column: 67, scope: !970)
!972 = !DILocation(line: 5, column: 3, scope: !970)
!973 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.get_y_coord", scope: null, file: !706, line: 8, type: !5, scopeLine: 8, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!974 = !DILocation(line: 9, column: 10, scope: !975)
!975 = !DILexicalBlockFile(scope: !973, file: !706, discriminator: 0)
!976 = !DILocation(line: 9, column: 67, scope: !975)
!977 = !DILocation(line: 9, column: 3, scope: !975)
!978 = distinct !DISubprogram(name: "sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord", linkageName: "sys_mod.sys_mod.memcpyd2h_mod.fabric.tile_config.get_fabric_coord", scope: null, file: !717, line: 43, type: !5, scopeLine: 43, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!979 = !DILocation(line: 50, column: 3, scope: !980)
!980 = !DILexicalBlockFile(scope: !978, file: !717, discriminator: 0)
!981 = !DILocation(line: 43, column: 21, scope: !980)
!982 = !DILocation(line: 50, column: 57, scope: !980)
!983 = !DILocation(line: 50, column: 68, scope: !980)
!984 = !DILocation(line: 50, column: 41, scope: !980)
!985 = !DILocation(line: 50, column: 19, scope: !980)
!986 = !DILocation(line: 52, column: 10, scope: !980)
!987 = !DILocation(line: 52, column: 18, scope: !980)
!988 = !DILocation(line: 48, column: 22, scope: !980)
!989 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr", linkageName: "sys_mod.sys_mod.tile_config.input_queue_config.get_input_queue_config_addr", scope: null, file: !990, line: 11, type: !5, scopeLine: 11, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!990 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/input_queue_config.csl", directory: "")
!991 = !DILocation(line: 11, column: 32, scope: !992)
!992 = !DILexicalBlockFile(scope: !989, file: !990, discriminator: 0)
!993 = !DILocation(line: 12, column: 80, scope: !992)
!994 = !DILocation(line: 12, column: 69, scope: !992)
!995 = !DILocation(line: 12, column: 39, scope: !992)
!996 = !DILocation(line: 12, column: 3, scope: !992)
!997 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue", linkageName: "sys_mod.sys_mod.tile_config.input_queue_config.encode_input_queue", scope: null, file: !990, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!998 = !DILocation(line: 46, column: 3, scope: !999)
!999 = !DILexicalBlockFile(scope: !997, file: !990, discriminator: 0)
!1000 = !DILocation(line: 45, column: 3, scope: !999)
!1001 = !DILocation(line: 39, column: 42, scope: !999)
!1002 = !DILocation(line: 39, column: 34, scope: !999)
!1003 = !DILocation(line: 39, column: 24, scope: !999)
!1004 = !DILocation(line: 45, column: 44, scope: !999)
!1005 = !DILocation(line: 45, column: 16, scope: !999)
!1006 = !DILocation(line: 46, column: 30, scope: !999)
!1007 = !DILocation(line: 46, column: 18, scope: !999)
!1008 = !DILocation(line: 56, column: 9, scope: !999)
!1009 = !DILocation(line: 56, column: 5, scope: !999)
!1010 = !DILocation(line: 58, column: 13, scope: !999)
!1011 = !DILocation(line: 58, column: 17, scope: !999)
!1012 = !DILocation(line: 58, column: 11, scope: !999)
!1013 = !DILocation(line: 61, column: 13, scope: !999)
!1014 = !DILocation(line: 61, column: 17, scope: !999)
!1015 = !DILocation(line: 61, column: 11, scope: !999)
!1016 = !DILocation(line: 66, column: 9, scope: !999)
!1017 = !DILocation(line: 66, column: 13, scope: !999)
!1018 = !DILocation(line: 66, column: 7, scope: !999)
!1019 = !DILocation(line: 68, column: 9, scope: !999)
!1020 = !DILocation(line: 68, column: 24, scope: !999)
!1021 = !DILocation(line: 68, column: 13, scope: !999)
!1022 = !DILocation(line: 68, column: 7, scope: !999)
!1023 = !DILocation(line: 70, column: 15, scope: !999)
!1024 = !DILocation(line: 70, column: 21, scope: !999)
!1025 = !DILocation(line: 70, column: 3, scope: !999)
!1026 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr", linkageName: "sys_mod.sys_mod.tile_config.output_queue_config.get_output_queue_config_addr", scope: null, file: !1027, line: 11, type: !5, scopeLine: 11, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1027 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/output_queue_config.csl", directory: "")
!1028 = !DILocation(line: 11, column: 33, scope: !1029)
!1029 = !DILexicalBlockFile(scope: !1026, file: !1027, discriminator: 0)
!1030 = !DILocation(line: 12, column: 82, scope: !1029)
!1031 = !DILocation(line: 12, column: 40, scope: !1029)
!1032 = !DILocation(line: 12, column: 3, scope: !1029)
!1033 = distinct !DISubprogram(name: "sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue", linkageName: "sys_mod.sys_mod.tile_config.output_queue_config.encode_output_queue", scope: null, file: !1027, line: 31, type: !5, scopeLine: 31, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1034 = !DILocation(line: 38, column: 3, scope: !1035)
!1035 = !DILexicalBlockFile(scope: !1033, file: !1027, discriminator: 0)
!1036 = !DILocation(line: 37, column: 3, scope: !1035)
!1037 = !DILocation(line: 31, column: 35, scope: !1035)
!1038 = !DILocation(line: 31, column: 25, scope: !1035)
!1039 = !DILocation(line: 37, column: 45, scope: !1035)
!1040 = !DILocation(line: 37, column: 16, scope: !1035)
!1041 = !DILocation(line: 38, column: 30, scope: !1035)
!1042 = !DILocation(line: 38, column: 18, scope: !1035)
!1043 = !DILocation(line: 41, column: 9, scope: !1035)
!1044 = !DILocation(line: 41, column: 13, scope: !1035)
!1045 = !DILocation(line: 41, column: 7, scope: !1035)
!1046 = !DILocation(line: 43, column: 9, scope: !1035)
!1047 = !DILocation(line: 43, column: 24, scope: !1035)
!1048 = !DILocation(line: 43, column: 13, scope: !1035)
!1049 = !DILocation(line: 43, column: 27, scope: !1035)
!1050 = !DILocation(line: 43, column: 7, scope: !1035)
!1051 = !DILocation(line: 45, column: 15, scope: !1035)
!1052 = !DILocation(line: 45, column: 21, scope: !1035)
!1053 = !DILocation(line: 45, column: 3, scope: !1035)
!1054 = !DILocation(line: 31, column: 1, scope: !1035)
!1055 = distinct !DISubprogram(name: ".get_tensor_ptr", linkageName: ".get_tensor_ptr", scope: null, file: !4, line: 1, type: !5, scopeLine: 1, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1056 = !DILocation(line: 1, column: 1, scope: !1057)
!1057 = !DILexicalBlockFile(scope: !1055, file: !4, discriminator: 0)
!1058 = distinct !DISubprogram(name: "__generic0sys_mod.sys_mod.tile_config.queue_flush.exit", linkageName: "__generic0sys_mod.sys_mod.tile_config.queue_flush.exit", scope: null, file: !1059, line: 12, type: !5, scopeLine: 12, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1059 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/queue_flush.csl", directory: "")
!1060 = !DILocation(line: 24, column: 3, scope: !1061)
!1061 = !DILexicalBlockFile(scope: !1058, file: !1059, discriminator: 0)
!1062 = !DILocation(line: 12, column: 1, scope: !1061)
!1063 = distinct !DISubprogram(name: "__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position", linkageName: "__generic3sys_mod.sys_mod.memcpyd2h_mod.tile_config.switch_config.clear_current_position", scope: null, file: !1064, line: 30, type: !5, scopeLine: 30, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1064 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/switch_config.csl", directory: "")
!1065 = !DILocation(line: 34, column: 3, scope: !1066)
!1066 = !DILexicalBlockFile(scope: !1063, file: !1064, discriminator: 0)
!1067 = !DILocation(line: 32, column: 3, scope: !1066)
!1068 = !DILocation(line: 30, column: 27, scope: !1066)
!1069 = !DILocation(line: 33, column: 7, scope: !1066)
!1070 = !DILocation(line: 34, column: 36, scope: !1066)
!1071 = !DILocation(line: 34, column: 24, scope: !1066)
!1072 = !DILocation(line: 35, column: 3, scope: !1066)
!1073 = !DILocation(line: 35, column: 18, scope: !1066)
!1074 = !DILocation(line: 36, column: 15, scope: !1066)
!1075 = !DILocation(line: 36, column: 21, scope: !1066)
!1076 = !DILocation(line: 36, column: 3, scope: !1066)
!1077 = !DILocation(line: 30, column: 1, scope: !1066)
!1078 = distinct !DISubprogram(name: "__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", linkageName: "__generic4sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", scope: null, file: !1079, line: 96, type: !5, scopeLine: 96, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1079 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/color_config.csl", directory: "")
!1080 = !DILocation(line: 99, column: 3, scope: !1081)
!1081 = !DILexicalBlockFile(scope: !1078, file: !1079, discriminator: 0)
!1082 = !DILocation(line: 98, column: 3, scope: !1081)
!1083 = !DILocation(line: 96, column: 17, scope: !1081)
!1084 = !DILocation(line: 98, column: 16, scope: !1081)
!1085 = !DILocation(line: 99, column: 29, scope: !1081)
!1086 = !DILocation(line: 99, column: 17, scope: !1081)
!1087 = !DILocation(line: 100, column: 13, scope: !1081)
!1088 = !DILocation(line: 100, column: 21, scope: !1081)
!1089 = !DILocation(line: 100, column: 11, scope: !1081)
!1090 = !DILocation(line: 104, column: 7, scope: !1081)
!1091 = !DILocation(line: 104, column: 50, scope: !1081)
!1092 = !DILocation(line: 104, column: 18, scope: !1081)
!1093 = !DILocation(line: 104, column: 15, scope: !1081)
!1094 = !DILocation(line: 121, column: 7, scope: !1081)
!1095 = !DILocation(line: 121, column: 50, scope: !1081)
!1096 = !DILocation(line: 121, column: 18, scope: !1081)
!1097 = !DILocation(line: 121, column: 15, scope: !1081)
!1098 = !DILocation(line: 128, column: 15, scope: !1081)
!1099 = !DILocation(line: 128, column: 21, scope: !1081)
!1100 = !DILocation(line: 128, column: 3, scope: !1081)
!1101 = !DILocation(line: 96, column: 1, scope: !1081)
!1102 = distinct !DISubprogram(name: "__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", linkageName: "__generic5sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.reset_routes", scope: null, file: !1079, line: 96, type: !5, scopeLine: 96, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1103 = !DILocation(line: 99, column: 3, scope: !1104)
!1104 = !DILexicalBlockFile(scope: !1102, file: !1079, discriminator: 0)
!1105 = !DILocation(line: 98, column: 3, scope: !1104)
!1106 = !DILocation(line: 96, column: 17, scope: !1104)
!1107 = !DILocation(line: 98, column: 16, scope: !1104)
!1108 = !DILocation(line: 99, column: 29, scope: !1104)
!1109 = !DILocation(line: 99, column: 17, scope: !1104)
!1110 = !DILocation(line: 100, column: 13, scope: !1104)
!1111 = !DILocation(line: 100, column: 21, scope: !1104)
!1112 = !DILocation(line: 100, column: 11, scope: !1104)
!1113 = !DILocation(line: 104, column: 7, scope: !1104)
!1114 = !DILocation(line: 104, column: 50, scope: !1104)
!1115 = !DILocation(line: 104, column: 18, scope: !1104)
!1116 = !DILocation(line: 104, column: 15, scope: !1104)
!1117 = !DILocation(line: 121, column: 7, scope: !1104)
!1118 = !DILocation(line: 121, column: 50, scope: !1104)
!1119 = !DILocation(line: 121, column: 18, scope: !1104)
!1120 = !DILocation(line: 121, column: 15, scope: !1104)
!1121 = !DILocation(line: 128, column: 15, scope: !1104)
!1122 = !DILocation(line: 128, column: 21, scope: !1104)
!1123 = !DILocation(line: 128, column: 3, scope: !1104)
!1124 = !DILocation(line: 96, column: 1, scope: !1104)
!1125 = distinct !DISubprogram(name: "__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", linkageName: "__generic6sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", scope: null, file: !1079, line: 60, type: !5, scopeLine: 60, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1126 = !DILocation(line: 61, column: 3, scope: !1127)
!1127 = !DILexicalBlockFile(scope: !1125, file: !1079, discriminator: 0)
!1128 = !DILocation(line: 60, column: 46, scope: !1127)
!1129 = !DILocation(line: 61, column: 16, scope: !1127)
!1130 = !DILocation(line: 72, column: 5, scope: !1127)
!1131 = !DILocation(line: 72, column: 12, scope: !1127)
!1132 = !DILocation(line: 74, column: 10, scope: !1127)
!1133 = !DILocation(line: 74, column: 3, scope: !1127)
!1134 = distinct !DISubprogram(name: "__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes", linkageName: "__generic7sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_tx_routes", scope: null, file: !1079, line: 77, type: !5, scopeLine: 77, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1135 = !DILocation(line: 78, column: 3, scope: !1136)
!1136 = !DILexicalBlockFile(scope: !1134, file: !1079, discriminator: 0)
!1137 = !DILocation(line: 77, column: 46, scope: !1136)
!1138 = !DILocation(line: 78, column: 16, scope: !1136)
!1139 = !DILocation(line: 86, column: 5, scope: !1136)
!1140 = !DILocation(line: 86, column: 12, scope: !1136)
!1141 = !DILocation(line: 91, column: 10, scope: !1136)
!1142 = !DILocation(line: 91, column: 3, scope: !1136)
!1143 = distinct !DISubprogram(name: "__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", linkageName: "__generic8sys_mod.sys_mod.memcpyd2h_mod.tile_config.color_config.encode_rx_routes", scope: null, file: !1079, line: 60, type: !5, scopeLine: 60, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1144 = !DILocation(line: 61, column: 3, scope: !1145)
!1145 = !DILexicalBlockFile(scope: !1143, file: !1079, discriminator: 0)
!1146 = !DILocation(line: 60, column: 46, scope: !1145)
!1147 = !DILocation(line: 61, column: 16, scope: !1145)
!1148 = !DILocation(line: 63, column: 5, scope: !1145)
!1149 = !DILocation(line: 63, column: 12, scope: !1145)
!1150 = !DILocation(line: 74, column: 10, scope: !1145)
!1151 = !DILocation(line: 74, column: 3, scope: !1145)
!1152 = distinct !DISubprogram(name: "__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction", linkageName: "__generic9sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.clear_io_direction", scope: null, file: !1079, line: 52, type: !5, scopeLine: 52, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1153 = !DILocation(line: 55, column: 3, scope: !1154)
!1154 = !DILexicalBlockFile(scope: !1152, file: !1079, discriminator: 0)
!1155 = !DILocation(line: 54, column: 3, scope: !1154)
!1156 = !DILocation(line: 52, column: 23, scope: !1154)
!1157 = !DILocation(line: 54, column: 16, scope: !1154)
!1158 = !DILocation(line: 55, column: 29, scope: !1154)
!1159 = !DILocation(line: 55, column: 17, scope: !1154)
!1160 = !DILocation(line: 56, column: 3, scope: !1154)
!1161 = !DILocation(line: 56, column: 11, scope: !1154)
!1162 = !DILocation(line: 57, column: 15, scope: !1154)
!1163 = !DILocation(line: 57, column: 21, scope: !1154)
!1164 = !DILocation(line: 57, column: 3, scope: !1154)
!1165 = !DILocation(line: 52, column: 1, scope: !1154)
!1166 = distinct !DISubprogram(name: "__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction", linkageName: "__generic10sys_mod.sys_mod.memcpyh2d_mod_1.tile_config.color_config.set_io_direction", scope: null, file: !1079, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!1167 = !DILocation(line: 23, column: 3, scope: !1168)
!1168 = !DILexicalBlockFile(scope: !1166, file: !1079, discriminator: 0)
!1169 = !DILocation(line: 22, column: 3, scope: !1168)
!1170 = !DILocation(line: 20, column: 21, scope: !1168)
!1171 = !DILocation(line: 22, column: 16, scope: !1168)
!1172 = !DILocation(line: 23, column: 29, scope: !1168)
!1173 = !DILocation(line: 23, column: 17, scope: !1168)
!1174 = !DILocation(line: 24, column: 3, scope: !1168)
!1175 = !DILocation(line: 24, column: 11, scope: !1168)
!1176 = !DILocation(line: 25, column: 15, scope: !1168)
!1177 = !DILocation(line: 25, column: 21, scope: !1168)
!1178 = !DILocation(line: 25, column: 3, scope: !1168)
!1179 = !DILocation(line: 20, column: 1, scope: !1168)
module asm ".section \22.pe_debug_info\22, \22\22"
module asm ".section \22.note\22, \22\22"
