; ModuleID = '/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/runtime/layout_west_demux_cmdfan_multi.csl'
source_filename = "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/runtime/layout_west_demux_cmdfan_multi.csl"
target datalayout = "e-ni:0-p:16:16-i1:16-i16:16-i32:32-i64:64-f32:32-f64:64"
target triple = "cs_sdr-cerebras-csos"

@"$$csl_base_address$$0$$config_buf_i32" = dso_local global [9 x i32] zeroinitializer, align 4
@num_receivers = internal global [1 x i16] zeroinitializer, align 4
@pes_per_receiver = internal global i16 0, align 4
@pe_length = internal global i16 0, align 4
@idx_send = internal global i16 0, align 4
@dsd_length = internal global i16 0, align 4
@num_send = internal global i16 0, align 4
@dsd_length_r = internal global i16 0, align 4
@is_odd = internal global i16 0, align 4
@memcpy_optype = internal global i16 0, align 4
@state = internal global i16 0, align 4
@gdsr_rxact_s1 = internal global <{ i16, i16, i16, i16 }> <{ i16 1, i16 3999, i16 -32562, i16 16 }>, align 4
@gdsr_txact_dst = internal global <{ i16, i16, i16, i16 }> <{ i16 1, i16 31, i16 -27954, i16 16 }>, align 4
@__dsr_lowmeminit_ = internal constant <{ i16, i16, i16, i16 }> <{ i16 4, i16 lshr (i16 ptrtoint ([9 x i32]* @"$$csl_base_address$$0$$config_buf_i32" to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__0 = internal constant <{ i16, i16, i16, i16 }> <{ i16 4, i16 4025, i16 -32626, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__1 = internal constant <{ i16, i16, i16, i16 }> <{ i16 5, i16 60, i16 4750, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__2 = internal constant <{ i16, i16, i16, i16 }> <{ i16 5, i16 lshr (i16 ptrtoint ([9 x i32]* @"$$csl_base_address$$0$$config_buf_i32" to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4

declare i8* @malloc(i64)

declare void @free(i8*)

define void @f_startup() #0 !dbg !3 {
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !7
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !7
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !7
  ret void, !dbg !9
}

define void @f_config() #1 !dbg !10 {
  %1 = alloca i16, i16 1, align 2, !dbg !11
  %2 = alloca i16, i16 1, align 2, !dbg !13
  %3 = alloca i16, i16 1, align 2, !dbg !14
  %4 = alloca i16, i16 1, align 2, !dbg !15
  %5 = alloca i16*, i16 1, align 8, !dbg !16
  store i16* bitcast ([9 x i32]* @"$$csl_base_address$$0$$config_buf_i32" to i16*), i16** %5, align 8, !dbg !16
  %6 = load i16*, i16** %5, align 8, !dbg !17
  %7 = getelementptr i16, i16* %6, i16 3, !dbg !18
  %8 = load i16, i16* %7, align 2, !dbg !18
  store i16 %8, i16* @dsd_length, align 2, !dbg !19
  %9 = load i16*, i16** %5, align 8, !dbg !20
  %10 = getelementptr i16, i16* %9, i16 4, !dbg !21
  %11 = load i16, i16* %10, align 2, !dbg !21
  store i16 %11, i16* @num_send, align 2, !dbg !22
  %12 = load i16*, i16** %5, align 8, !dbg !23
  %13 = getelementptr i16, i16* %12, i16 5, !dbg !24
  %14 = load i16, i16* %13, align 2, !dbg !24
  store i16 %14, i16* @dsd_length_r, align 2, !dbg !25
  %15 = load i16*, i16** %5, align 8, !dbg !26
  %16 = getelementptr i16, i16* %15, i16 6, !dbg !27
  %17 = load i16, i16* %16, align 2, !dbg !27
  store i16 %17, i16* @is_odd, align 2, !dbg !28
  %18 = load i16*, i16** %5, align 8, !dbg !29
  %19 = getelementptr i16, i16* %18, i16 7, !dbg !30
  %20 = load i16, i16* %19, align 2, !dbg !30
  store i16 %20, i16* @memcpy_optype, align 2, !dbg !31
  store i16 0, i16* %4, align 2, !dbg !15
  store i16 0, i16* %3, align 2, !dbg !14
  br label %21, !dbg !32

21:                                               ; preds = %47, %0
  %22 = phi i16 [ 0, %47 ], [ 0, %0 ]
  %23 = icmp sgt i16 %22, 0, !dbg !32
  br i1 %23, label %24, label %26, !dbg !32

24:                                               ; preds = %21
  %25 = sub i16 %22, 1, !dbg !32
  br label %27, !dbg !32

26:                                               ; preds = %21
  br label %27, !dbg !32

27:                                               ; preds = %24, %26
  %28 = phi i16 [ %22, %26 ], [ %25, %24 ]
  br label %29, !dbg !32

29:                                               ; preds = %27
  %30 = icmp ne i16 %22, 0, !dbg !32
  br i1 %30, label %31, label %32, !dbg !32

31:                                               ; preds = %29
  br label %35, !dbg !32

32:                                               ; preds = %29
  %33 = load i16, i16* %4, align 2, !dbg !33
  %34 = icmp slt i16 %33, 1, !dbg !34
  br label %35, !dbg !32

35:                                               ; preds = %31, %32
  %36 = phi i1 [ %34, %32 ], [ false, %31 ]
  br label %37, !dbg !32

37:                                               ; preds = %35
  br i1 %36, label %38, label %57, !dbg !32

38:                                               ; preds = %37
  %39 = load i16*, i16** %5, align 8, !dbg !35
  %40 = load i16, i16* %4, align 2, !dbg !36
  %41 = getelementptr i16, i16* %39, i16 %40, !dbg !37
  %42 = load i16, i16* %41, align 2, !dbg !37
  store i16 %42, i16* %2, align 2, !dbg !13
  %43 = load i16, i16* %3, align 2, !dbg !38
  store i16 %43, i16* %1, align 2, !dbg !11
  %44 = load i16, i16* %2, align 2, !dbg !39
  %45 = icmp eq i16 0, %44, !dbg !40
  br i1 %45, label %46, label %47, !dbg !41

46:                                               ; preds = %38
  store i16 -1, i16* %1, align 2, !dbg !42
  br label %47, !dbg !41

47:                                               ; preds = %46, %38
  %48 = load i16, i16* %1, align 2, !dbg !43
  %49 = load i16*, i16** %5, align 8, !dbg !44
  %50 = load i16, i16* %4, align 2, !dbg !45
  %51 = getelementptr i16, i16* %49, i16 %50, !dbg !46
  store i16 %48, i16* %51, align 2, !dbg !47
  %52 = load i16, i16* %3, align 2, !dbg !48
  %53 = load i16, i16* %2, align 2, !dbg !49
  %54 = add i16 %52, %53, !dbg !50
  store i16 %54, i16* %3, align 2, !dbg !51
  %55 = load i16, i16* %4, align 2, !dbg !52
  %56 = add i16 %55, 1, !dbg !53
  store i16 %56, i16* %4, align 2, !dbg !53
  br label %21, !dbg !32

57:                                               ; preds = %37
  %58 = icmp ne i16 %28, 0, !dbg !32
  br i1 %58, label %59, label %60, !dbg !32

59:                                               ; preds = %57
  br label %74, !dbg !32

60:                                               ; preds = %57
  %61 = load i16, i16* %3, align 2, !dbg !54
  store i16 %61, i16* getelementptr inbounds ([1 x i16], [1 x i16]* @num_receivers, i16 0, i1 false), align 2, !dbg !55
  %62 = load i16*, i16** %5, align 8, !dbg !56
  %63 = getelementptr i16, i16* %62, i16 1, !dbg !57
  %64 = load i16, i16* %63, align 2, !dbg !57
  store i16 %64, i16* @pes_per_receiver, align 2, !dbg !58
  %65 = load i16*, i16** %5, align 8, !dbg !59
  %66 = getelementptr i16, i16* %65, i16 2, !dbg !60
  %67 = load i16, i16* %66, align 2, !dbg !60
  store i16 %67, i16* @pe_length, align 2, !dbg !61
  %68 = load i16, i16* getelementptr inbounds ([1 x i16], [1 x i16]* @num_receivers, i16 0, i1 false), align 2, !dbg !62
  %69 = load i16*, i16** %5, align 8, !dbg !63
  %70 = getelementptr i16, i16* %69, i16 3, !dbg !64
  store i16 %68, i16* %70, align 2, !dbg !65
  %71 = load i16, i16* @memcpy_optype, align 2, !dbg !66
  %72 = load i16*, i16** %5, align 8, !dbg !67
  %73 = getelementptr i16, i16* %72, i16 4, !dbg !68
  store i16 %71, i16* %73, align 2, !dbg !69
  call void @llvm.sdr.actvt.r(i16 26), !dbg !70
  br label %74, !dbg !32

74:                                               ; preds = %59, %60
  ret void, !dbg !32
}

define void @f_txtd0_done() #2 !dbg !71 {
  call void @llvm.sdr.lddwds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__1 to i8*)), !dbg !72
  call void @llvm.sdr.lds1wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__2 to i8*)), !dbg !72
  call void @llvm.sdr.imov16.ds1(i16 1, i16 1), !dbg !72
  ret void, !dbg !74
}

define void @f_txtd1_done() #3 !dbg !75 {
  %1 = load i16, i16* getelementptr inbounds ([1 x i16], [1 x i16]* @num_receivers, i16 0, i1 false), align 2, !dbg !76
  %2 = icmp eq i16 0, %1, !dbg !78
  br i1 %2, label %3, label %4, !dbg !79

3:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !80
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !80
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !80
  br label %13, !dbg !79

4:                                                ; preds = %0
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 1), align 2, !dbg !81
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 2), align 2, !dbg !81
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 3), align 2, !dbg !81
  %8 = load i16, i16* @dsd_length, align 2, !dbg !82
  store i16 %8, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 0), align 2, !dbg !83
  store i16 %5, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 1), align 2, !dbg !83
  store i16 %6, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 2), align 2, !dbg !83
  store i16 %7, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 3), align 2, !dbg !83
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 1), align 2, !dbg !84
  %10 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 2), align 2, !dbg !84
  %11 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 3), align 2, !dbg !84
  %12 = load i16, i16* @dsd_length, align 2, !dbg !85
  store i16 %12, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 0), align 2, !dbg !86
  store i16 %9, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 1), align 2, !dbg !86
  store i16 %10, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 2), align 2, !dbg !86
  store i16 %11, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 3), align 2, !dbg !86
  store i16 0, i16* @idx_send, align 2, !dbg !87
  call void @llvm.sdr.actvt.r(i16 30), !dbg !88
  br label %13, !dbg !79

13:                                               ; preds = %3, %4
  ret void, !dbg !79
}

define void @f_rxdone() #4 !dbg !89 {
  %1 = load i16, i16* @idx_send, align 2, !dbg !90
  %2 = load i16, i16* @num_send, align 2, !dbg !92
  %3 = icmp uge i16 %1, %2, !dbg !93
  br i1 %3, label %4, label %39, !dbg !94

4:                                                ; preds = %0
  %5 = load i16, i16* @state, align 2, !dbg !95
  %6 = icmp eq i16 0, %5, !dbg !96
  br i1 %6, label %7, label %37, !dbg !97

7:                                                ; preds = %4
  %8 = load i16, i16* @dsd_length_r, align 2, !dbg !98
  %9 = icmp eq i16 0, %8, !dbg !99
  br i1 %9, label %10, label %11, !dbg !100

10:                                               ; preds = %7
  call void @llvm.sdr.actvt.r(i16 30), !dbg !101
  br label %36, !dbg !100

11:                                               ; preds = %7
  %12 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 1), align 2, !dbg !102
  %13 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 2), align 2, !dbg !102
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 3), align 2, !dbg !102
  %15 = load i16, i16* @dsd_length_r, align 2, !dbg !103
  store i16 %15, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 0), align 2, !dbg !104
  store i16 %12, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 1), align 2, !dbg !104
  store i16 %13, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 2), align 2, !dbg !104
  store i16 %14, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 3), align 2, !dbg !104
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 1), align 2, !dbg !105
  %17 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 2), align 2, !dbg !105
  %18 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 3), align 2, !dbg !105
  %19 = load i16, i16* @dsd_length_r, align 2, !dbg !106
  store i16 %19, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 0), align 2, !dbg !107
  store i16 %16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 1), align 2, !dbg !107
  store i16 %17, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 2), align 2, !dbg !107
  store i16 %18, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 3), align 2, !dbg !107
  %20 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 0), align 2, !dbg !108
  %21 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 1), align 2, !dbg !108
  %22 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 2), align 2, !dbg !108
  %23 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 3), align 2, !dbg !108
  %24 = and i16 %22, -193, !dbg !108
  %25 = or i16 %24, 128, !dbg !108
  %26 = and i16 %21, -64, !dbg !108
  %27 = or i16 %26, 62, !dbg !108
  %28 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 0), align 2, !dbg !109
  %29 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 1), align 2, !dbg !109
  %30 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 2), align 2, !dbg !109
  %31 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 3), align 2, !dbg !109
  %32 = and i16 %30, -193, !dbg !109
  %33 = or i16 %32, 128, !dbg !109
  %34 = and i16 %29, -64, !dbg !109
  %35 = or i16 %34, 62, !dbg !109
  store volatile i16 %28, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 2, i32 0), align 2, !dbg !110
  store volatile i16 %35, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 2, i32 1), align 2, !dbg !110
  store volatile i16 %33, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 2, i32 2), align 2, !dbg !110
  store volatile i16 %31, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 2, i32 3), align 2, !dbg !110
  call void asm sideeffect "nop", ""(), !dbg !110
  call void asm sideeffect "nop", ""(), !dbg !110
  store volatile i16 %20, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 2, i32 0), align 2, !dbg !110
  store volatile i16 %27, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 2, i32 1), align 2, !dbg !110
  store volatile i16 %25, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 2, i32 2), align 2, !dbg !110
  store volatile i16 %23, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 2, i32 3), align 2, !dbg !110
  call void asm sideeffect "nop", ""(), !dbg !110
  call void asm sideeffect "nop", ""(), !dbg !110
  call void @llvm.sdr.imov32.ds1(i16 2, i16 2), !dbg !110
  br label %36, !dbg !100

36:                                               ; preds = %10, %11
  store i16 1, i16* @state, align 2, !dbg !111
  br label %38, !dbg !97

37:                                               ; preds = %4
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !112
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !112
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !112
  store i16 0, i16* @state, align 2, !dbg !113
  br label %38, !dbg !97

38:                                               ; preds = %36, %37
  br label %58, !dbg !94

39:                                               ; preds = %0
  %40 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 0), align 2, !dbg !114
  %41 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 1), align 2, !dbg !114
  %42 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 2), align 2, !dbg !114
  %43 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 3), align 2, !dbg !114
  %44 = and i16 %42, -193, !dbg !114
  %45 = or i16 %44, 128, !dbg !114
  %46 = and i16 %41, -64, !dbg !114
  %47 = or i16 %46, 62, !dbg !114
  %48 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 0), align 2, !dbg !115
  %49 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 1), align 2, !dbg !115
  %50 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 2), align 2, !dbg !115
  %51 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 3), align 2, !dbg !115
  %52 = and i16 %50, -193, !dbg !115
  %53 = or i16 %52, 128, !dbg !115
  %54 = and i16 %49, -64, !dbg !115
  %55 = or i16 %54, 62, !dbg !115
  store volatile i16 %48, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 3, i32 0), align 2, !dbg !116
  store volatile i16 %55, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 3, i32 1), align 2, !dbg !116
  store volatile i16 %53, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 3, i32 2), align 2, !dbg !116
  store volatile i16 %51, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 3, i32 3), align 2, !dbg !116
  call void asm sideeffect "nop", ""(), !dbg !116
  call void asm sideeffect "nop", ""(), !dbg !116
  store volatile i16 %40, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 3, i32 0), align 2, !dbg !116
  store volatile i16 %47, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 3, i32 1), align 2, !dbg !116
  store volatile i16 %45, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 3, i32 2), align 2, !dbg !116
  store volatile i16 %43, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 3, i32 3), align 2, !dbg !116
  call void asm sideeffect "nop", ""(), !dbg !116
  call void asm sideeffect "nop", ""(), !dbg !116
  call void @llvm.sdr.imov32.ds1(i16 3, i16 3), !dbg !116
  %56 = load i16, i16* @idx_send, align 2, !dbg !117
  %57 = add i16 %56, 1, !dbg !118
  store i16 %57, i16* @idx_send, align 2, !dbg !119
  br label %58, !dbg !94

58:                                               ; preds = %38, %39
  ret void, !dbg !94
}

; Function Attrs: nounwind
declare void @llvm.sdr.actvt.r(i16) #5

; Function Attrs: nounwind
declare void @llvm.sdr.blk.r(i16) #5

; Function Attrs: nounwind
declare void @llvm.sdr.ublk.r(i16) #5

; Function Attrs: nounwind
declare i16 @llvm.sdr.read.lfsr() #5

; Function Attrs: nounwind
declare void @llvm.sdr.stprng.r(i16) #5

; Function Attrs: nounwind
declare void @llvm.sdr.lds0wds(i16 immarg, i8* readonly) #5

; Function Attrs: nounwind
declare void @llvm.sdr.lds1wds(i16 immarg, i8* readonly) #5

; Function Attrs: nounwind
declare void @llvm.sdr.lddwds(i16 immarg, i8* readonly) #5

; Function Attrs: nounwind
declare void @llvm.sdr.ldxds(i16 immarg, i8* readonly) #5

; Function Attrs: nounwind
declare void @llvm.sdr.ldsr(i16 immarg, i8* readonly) #5

; Function Attrs: nounwind writeonly
declare void @llvm.sdr.iqflush(i16) #6

; Function Attrs: nounwind writeonly
declare void @llvm.sdr.oqflush(i16) #6

; Function Attrs: nounwind
declare void @llvm.sdr.imov32.ds1(i16 immarg, i16 immarg) #5

; Function Attrs: nounwind
declare void @llvm.sdr.imov16.ds1(i16 immarg, i16 immarg) #5

declare i16 @csl.ss.read.16(i16, i1)

declare i32 @csl.ss.read.32(i16, i1)

declare void @csl.ss.write.16(i16, i16, i1)

declare void @csl.ss.write.32(i16, i32, i1)

declare i1 @csl.ss.set_jump_target()

declare i1 @csl.fifo.set_jump_target()

attributes #0 = { "entry-point"="24" "task" }
attributes #1 = { "entry-point"="25" "task" }
attributes #2 = { "entry-point"="26" "task" }
attributes #3 = { "entry-point"="28" "task" }
attributes #4 = { "entry-point"="30" "task" }
attributes #5 = { nounwind }
attributes #6 = { nounwind writeonly }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!2}

!0 = distinct !DICompileUnit(language: DW_LANG_C, file: !1, producer: "mlir", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug)
!1 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/runtime/layout_west_demux_cmdfan_multi.csl", directory: "/")
!2 = !{i32 2, !"Debug Info Version", i32 3}
!3 = distinct !DISubprogram(name: "f_startup", linkageName: "f_startup", scope: null, file: !4, line: 239, type: !5, scopeLine: 239, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!4 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/runtime/demux_adaptor_N1.csl", directory: "")
!5 = !DISubroutineType(types: !6)
!6 = !{}
!7 = !DILocation(line: 251, column: 5, scope: !8)
!8 = !DILexicalBlockFile(scope: !3, file: !4, discriminator: 0)
!9 = !DILocation(line: 239, column: 1, scope: !8)
!10 = distinct !DISubprogram(name: "f_config", linkageName: "f_config", scope: null, file: !4, line: 282, type: !5, scopeLine: 282, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!11 = !DILocation(line: 302, column: 9, scope: !12)
!12 = !DILexicalBlockFile(scope: !10, file: !4, discriminator: 0)
!13 = !DILocation(line: 301, column: 9, scope: !12)
!14 = !DILocation(line: 299, column: 5, scope: !12)
!15 = !DILocation(line: 298, column: 5, scope: !12)
!16 = !DILocation(line: 287, column: 5, scope: !12)
!17 = !DILocation(line: 289, column: 32, scope: !12)
!18 = !DILocation(line: 289, column: 42, scope: !12)
!19 = !DILocation(line: 289, column: 16, scope: !12)
!20 = !DILocation(line: 290, column: 30, scope: !12)
!21 = !DILocation(line: 290, column: 40, scope: !12)
!22 = !DILocation(line: 290, column: 14, scope: !12)
!23 = !DILocation(line: 291, column: 34, scope: !12)
!24 = !DILocation(line: 291, column: 44, scope: !12)
!25 = !DILocation(line: 291, column: 18, scope: !12)
!26 = !DILocation(line: 292, column: 28, scope: !12)
!27 = !DILocation(line: 292, column: 38, scope: !12)
!28 = !DILocation(line: 292, column: 12, scope: !12)
!29 = !DILocation(line: 293, column: 35, scope: !12)
!30 = !DILocation(line: 293, column: 45, scope: !12)
!31 = !DILocation(line: 293, column: 19, scope: !12)
!32 = !DILocation(line: 300, column: 5, scope: !12)
!33 = !DILocation(line: 300, column: 11, scope: !12)
!34 = !DILocation(line: 300, column: 15, scope: !12)
!35 = !DILocation(line: 301, column: 30, scope: !12)
!36 = !DILocation(line: 301, column: 41, scope: !12)
!37 = !DILocation(line: 301, column: 40, scope: !12)
!38 = !DILocation(line: 302, column: 29, scope: !12)
!39 = !DILocation(line: 303, column: 19, scope: !12)
!40 = !DILocation(line: 303, column: 16, scope: !12)
!41 = !DILocation(line: 303, column: 9, scope: !12)
!42 = !DILocation(line: 304, column: 21, scope: !12)
!43 = !DILocation(line: 306, column: 27, scope: !12)
!44 = !DILocation(line: 306, column: 9, scope: !12)
!45 = !DILocation(line: 306, column: 20, scope: !12)
!46 = !DILocation(line: 306, column: 19, scope: !12)
!47 = !DILocation(line: 306, column: 25, scope: !12)
!48 = !DILocation(line: 307, column: 20, scope: !12)
!49 = !DILocation(line: 307, column: 31, scope: !12)
!50 = !DILocation(line: 307, column: 29, scope: !12)
!51 = !DILocation(line: 307, column: 18, scope: !12)
!52 = !DILocation(line: 300, column: 23, scope: !12)
!53 = !DILocation(line: 300, column: 27, scope: !12)
!54 = !DILocation(line: 313, column: 24, scope: !12)
!55 = !DILocation(line: 313, column: 22, scope: !12)
!56 = !DILocation(line: 318, column: 24, scope: !12)
!57 = !DILocation(line: 318, column: 34, scope: !12)
!58 = !DILocation(line: 318, column: 22, scope: !12)
!59 = !DILocation(line: 319, column: 17, scope: !12)
!60 = !DILocation(line: 319, column: 27, scope: !12)
!61 = !DILocation(line: 319, column: 15, scope: !12)
!62 = !DILocation(line: 322, column: 36, scope: !12)
!63 = !DILocation(line: 322, column: 5, scope: !12)
!64 = !DILocation(line: 322, column: 15, scope: !12)
!65 = !DILocation(line: 322, column: 21, scope: !12)
!66 = !DILocation(line: 325, column: 37, scope: !12)
!67 = !DILocation(line: 325, column: 5, scope: !12)
!68 = !DILocation(line: 325, column: 15, scope: !12)
!69 = !DILocation(line: 325, column: 21, scope: !12)
!70 = !DILocation(line: 328, column: 5, scope: !12)
!71 = distinct !DISubprogram(name: "f_txtd0_done", linkageName: "f_txtd0_done", scope: null, file: !4, line: 336, type: !5, scopeLine: 336, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!72 = !DILocation(line: 338, column: 5, scope: !73)
!73 = !DILexicalBlockFile(scope: !71, file: !4, discriminator: 0)
!74 = !DILocation(line: 336, column: 1, scope: !73)
!75 = distinct !DISubprogram(name: "f_txtd1_done", linkageName: "f_txtd1_done", scope: null, file: !4, line: 341, type: !5, scopeLine: 341, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!76 = !DILocation(line: 343, column: 27, scope: !77)
!77 = !DILexicalBlockFile(scope: !75, file: !4, discriminator: 0)
!78 = !DILocation(line: 343, column: 11, scope: !77)
!79 = !DILocation(line: 343, column: 5, scope: !77)
!80 = !DILocation(line: 347, column: 9, scope: !77)
!81 = !DILocation(line: 349, column: 42, scope: !77)
!82 = !DILocation(line: 349, column: 58, scope: !77)
!83 = !DILocation(line: 349, column: 24, scope: !77)
!84 = !DILocation(line: 350, column: 42, scope: !77)
!85 = !DILocation(line: 350, column: 58, scope: !77)
!86 = !DILocation(line: 350, column: 24, scope: !77)
!87 = !DILocation(line: 352, column: 18, scope: !77)
!88 = !DILocation(line: 353, column: 9, scope: !77)
!89 = distinct !DISubprogram(name: "f_rxdone", linkageName: "f_rxdone", scope: null, file: !4, line: 363, type: !5, scopeLine: 363, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!90 = !DILocation(line: 364, column: 10, scope: !91)
!91 = !DILexicalBlockFile(scope: !89, file: !4, discriminator: 0)
!92 = !DILocation(line: 364, column: 22, scope: !91)
!93 = !DILocation(line: 364, column: 19, scope: !91)
!94 = !DILocation(line: 364, column: 5, scope: !91)
!95 = !DILocation(line: 365, column: 18, scope: !91)
!96 = !DILocation(line: 365, column: 15, scope: !91)
!97 = !DILocation(line: 365, column: 9, scope: !91)
!98 = !DILocation(line: 367, column: 23, scope: !91)
!99 = !DILocation(line: 367, column: 20, scope: !91)
!100 = !DILocation(line: 367, column: 13, scope: !91)
!101 = !DILocation(line: 368, column: 17, scope: !91)
!102 = !DILocation(line: 370, column: 50, scope: !91)
!103 = !DILocation(line: 370, column: 66, scope: !91)
!104 = !DILocation(line: 370, column: 32, scope: !91)
!105 = !DILocation(line: 371, column: 50, scope: !91)
!106 = !DILocation(line: 371, column: 66, scope: !91)
!107 = !DILocation(line: 371, column: 32, scope: !91)
!108 = !DILocation(line: 372, column: 24, scope: !91)
!109 = !DILocation(line: 372, column: 40, scope: !91)
!110 = !DILocation(line: 372, column: 17, scope: !91)
!111 = !DILocation(line: 374, column: 19, scope: !91)
!112 = !DILocation(line: 377, column: 13, scope: !91)
!113 = !DILocation(line: 378, column: 19, scope: !91)
!114 = !DILocation(line: 383, column: 16, scope: !91)
!115 = !DILocation(line: 383, column: 32, scope: !91)
!116 = !DILocation(line: 383, column: 9, scope: !91)
!117 = !DILocation(line: 384, column: 20, scope: !91)
!118 = !DILocation(line: 384, column: 29, scope: !91)
!119 = !DILocation(line: 384, column: 18, scope: !91)
module asm ".section \22.pe_debug_info\22, \22\22"
module asm ".section \22.note\22, \22\22"
