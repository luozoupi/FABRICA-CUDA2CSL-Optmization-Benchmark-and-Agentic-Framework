; ModuleID = '/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/runtime/layout_east_mux_multi.csl'
source_filename = "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/runtime/layout_east_mux_multi.csl"
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
@state = internal global i16 0, align 4
@"$$csl_base_address$$1$$zero_padding" = dso_local global [1 x i32] zeroinitializer, align 4
@gdsr_rxact_s1 = internal global <{ i16, i16, i16, i16 }> <{ i16 1, i16 3999, i16 -32562, i16 16 }>, align 4
@gdsr_txact_dst = internal global <{ i16, i16, i16, i16 }> <{ i16 1, i16 31, i16 -27954, i16 16 }>, align 4
@__dsr_lowmeminit_ = internal constant <{ i16, i16, i16, i16 }> <{ i16 4, i16 lshr (i16 ptrtoint ([9 x i32]* @"$$csl_base_address$$0$$config_buf_i32" to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__0 = internal constant <{ i16, i16, i16, i16 }> <{ i16 4, i16 4026, i16 -30322, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__1 = internal constant <{ i16, i16, i16, i16 }> <{ i16 4, i16 60, i16 9358, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__2 = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 lshr (i16 ptrtoint ([1 x i32]* @"$$csl_base_address$$1$$zero_padding" to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__3 = internal constant <{ i16, i16, i16, i16 }> <{ i16 1, i16 56, i16 -28018, i16 16 }>, section ".data.lo", align 4

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
  store i16 0, i16* %4, align 2, !dbg !15
  store i16 0, i16* %3, align 2, !dbg !14
  br label %18, !dbg !29

18:                                               ; preds = %44, %0
  %19 = phi i16 [ 0, %44 ], [ 0, %0 ]
  %20 = icmp sgt i16 %19, 0, !dbg !29
  br i1 %20, label %21, label %23, !dbg !29

21:                                               ; preds = %18
  %22 = sub i16 %19, 1, !dbg !29
  br label %24, !dbg !29

23:                                               ; preds = %18
  br label %24, !dbg !29

24:                                               ; preds = %21, %23
  %25 = phi i16 [ %19, %23 ], [ %22, %21 ]
  br label %26, !dbg !29

26:                                               ; preds = %24
  %27 = icmp ne i16 %19, 0, !dbg !29
  br i1 %27, label %28, label %29, !dbg !29

28:                                               ; preds = %26
  br label %32, !dbg !29

29:                                               ; preds = %26
  %30 = load i16, i16* %4, align 2, !dbg !30
  %31 = icmp slt i16 %30, 1, !dbg !31
  br label %32, !dbg !29

32:                                               ; preds = %28, %29
  %33 = phi i1 [ %31, %29 ], [ false, %28 ]
  br label %34, !dbg !29

34:                                               ; preds = %32
  br i1 %33, label %35, label %54, !dbg !29

35:                                               ; preds = %34
  %36 = load i16*, i16** %5, align 8, !dbg !32
  %37 = load i16, i16* %4, align 2, !dbg !33
  %38 = getelementptr i16, i16* %36, i16 %37, !dbg !34
  %39 = load i16, i16* %38, align 2, !dbg !34
  store i16 %39, i16* %2, align 2, !dbg !13
  %40 = load i16, i16* %3, align 2, !dbg !35
  store i16 %40, i16* %1, align 2, !dbg !11
  %41 = load i16, i16* %2, align 2, !dbg !36
  %42 = icmp eq i16 0, %41, !dbg !37
  br i1 %42, label %43, label %44, !dbg !38

43:                                               ; preds = %35
  store i16 -1, i16* %1, align 2, !dbg !39
  br label %44, !dbg !38

44:                                               ; preds = %43, %35
  %45 = load i16, i16* %1, align 2, !dbg !40
  %46 = load i16*, i16** %5, align 8, !dbg !41
  %47 = load i16, i16* %4, align 2, !dbg !42
  %48 = getelementptr i16, i16* %46, i16 %47, !dbg !43
  store i16 %45, i16* %48, align 2, !dbg !44
  %49 = load i16, i16* %3, align 2, !dbg !45
  %50 = load i16, i16* %2, align 2, !dbg !46
  %51 = add i16 %49, %50, !dbg !47
  store i16 %51, i16* %3, align 2, !dbg !48
  %52 = load i16, i16* %4, align 2, !dbg !49
  %53 = add i16 %52, 1, !dbg !50
  store i16 %53, i16* %4, align 2, !dbg !50
  br label %18, !dbg !29

54:                                               ; preds = %34
  %55 = icmp ne i16 %25, 0, !dbg !29
  br i1 %55, label %56, label %57, !dbg !29

56:                                               ; preds = %54
  br label %68, !dbg !29

57:                                               ; preds = %54
  %58 = load i16, i16* %3, align 2, !dbg !51
  store i16 %58, i16* getelementptr inbounds ([1 x i16], [1 x i16]* @num_receivers, i16 0, i1 false), align 2, !dbg !52
  %59 = load i16*, i16** %5, align 8, !dbg !53
  %60 = getelementptr i16, i16* %59, i16 1, !dbg !54
  %61 = load i16, i16* %60, align 2, !dbg !54
  store i16 %61, i16* @pes_per_receiver, align 2, !dbg !55
  %62 = load i16*, i16** %5, align 8, !dbg !56
  %63 = getelementptr i16, i16* %62, i16 2, !dbg !57
  %64 = load i16, i16* %63, align 2, !dbg !57
  store i16 %64, i16* @pe_length, align 2, !dbg !58
  %65 = load i16, i16* getelementptr inbounds ([1 x i16], [1 x i16]* @num_receivers, i16 0, i1 false), align 2, !dbg !59
  %66 = load i16*, i16** %5, align 8, !dbg !60
  %67 = getelementptr i16, i16* %66, i16 3, !dbg !61
  store i16 %65, i16* %67, align 2, !dbg !62
  call void @llvm.sdr.actvt.r(i16 27), !dbg !63
  br label %68, !dbg !29

68:                                               ; preds = %56, %57
  ret void, !dbg !29
}

define void @f_txtd0_done() #2 !dbg !64 {
  call void @llvm.sdr.lddwds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__1 to i8*)), !dbg !65
  call void @llvm.sdr.lds1wds(i16 1, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !65
  call void @llvm.sdr.imov16.ds1(i16 1, i16 1), !dbg !65
  ret void, !dbg !67
}

define void @f_txtd1_done() #3 !dbg !68 {
  %1 = load i16, i16* getelementptr inbounds ([1 x i16], [1 x i16]* @num_receivers, i16 0, i1 false), align 2, !dbg !69
  %2 = icmp eq i16 0, %1, !dbg !71
  br i1 %2, label %3, label %4, !dbg !72

3:                                                ; preds = %0
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !73
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !73
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !73
  br label %13, !dbg !72

4:                                                ; preds = %0
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 1), align 2, !dbg !74
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 2), align 2, !dbg !74
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 3), align 2, !dbg !74
  %8 = load i16, i16* @dsd_length, align 2, !dbg !75
  store i16 %8, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 0), align 2, !dbg !76
  store i16 %5, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 1), align 2, !dbg !76
  store i16 %6, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 2), align 2, !dbg !76
  store i16 %7, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 3), align 2, !dbg !76
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 1), align 2, !dbg !77
  %10 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 2), align 2, !dbg !77
  %11 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 3), align 2, !dbg !77
  %12 = load i16, i16* @dsd_length, align 2, !dbg !78
  store i16 %12, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 0), align 2, !dbg !79
  store i16 %9, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 1), align 2, !dbg !79
  store i16 %10, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 2), align 2, !dbg !79
  store i16 %11, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 3), align 2, !dbg !79
  store i16 0, i16* @idx_send, align 2, !dbg !80
  call void @llvm.sdr.actvt.r(i16 30), !dbg !81
  br label %13, !dbg !72

13:                                               ; preds = %3, %4
  ret void, !dbg !72
}

define void @f_rxdone() #4 !dbg !82 {
  %1 = load i16, i16* @idx_send, align 2, !dbg !83
  %2 = load i16, i16* @num_send, align 2, !dbg !85
  %3 = icmp uge i16 %1, %2, !dbg !86
  br i1 %3, label %4, label %44, !dbg !87

4:                                                ; preds = %0
  %5 = load i16, i16* @state, align 2, !dbg !88
  %6 = icmp eq i16 0, %5, !dbg !89
  br i1 %6, label %7, label %38, !dbg !90

7:                                                ; preds = %4
  %8 = load i16, i16* @dsd_length_r, align 2, !dbg !91
  %9 = icmp eq i16 0, %8, !dbg !92
  br i1 %9, label %10, label %11, !dbg !93

10:                                               ; preds = %7
  call void @llvm.sdr.actvt.r(i16 30), !dbg !94
  br label %36, !dbg !93

11:                                               ; preds = %7
  %12 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 1), align 2, !dbg !95
  %13 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 2), align 2, !dbg !95
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 3), align 2, !dbg !95
  %15 = load i16, i16* @dsd_length_r, align 2, !dbg !96
  store i16 %15, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 0), align 2, !dbg !97
  store i16 %12, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 1), align 2, !dbg !97
  store i16 %13, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 2), align 2, !dbg !97
  store i16 %14, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 3), align 2, !dbg !97
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 1), align 2, !dbg !98
  %17 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 2), align 2, !dbg !98
  %18 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 3), align 2, !dbg !98
  %19 = load i16, i16* @dsd_length_r, align 2, !dbg !99
  store i16 %19, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 0), align 2, !dbg !100
  store i16 %16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 1), align 2, !dbg !100
  store i16 %17, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 2), align 2, !dbg !100
  store i16 %18, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 3), align 2, !dbg !100
  %20 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 0), align 2, !dbg !101
  %21 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 1), align 2, !dbg !101
  %22 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 2), align 2, !dbg !101
  %23 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 3), align 2, !dbg !101
  %24 = and i16 %22, -193, !dbg !101
  %25 = or i16 %24, 128, !dbg !101
  %26 = and i16 %21, -64, !dbg !101
  %27 = or i16 %26, 62, !dbg !101
  %28 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 0), align 2, !dbg !102
  %29 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 1), align 2, !dbg !102
  %30 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 2), align 2, !dbg !102
  %31 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 3), align 2, !dbg !102
  %32 = and i16 %30, -193, !dbg !102
  %33 = or i16 %32, 128, !dbg !102
  %34 = and i16 %29, -64, !dbg !102
  %35 = or i16 %34, 62, !dbg !102
  store volatile i16 %28, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 2, i32 0), align 2, !dbg !103
  store volatile i16 %35, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 2, i32 1), align 2, !dbg !103
  store volatile i16 %33, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 2, i32 2), align 2, !dbg !103
  store volatile i16 %31, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 2, i32 3), align 2, !dbg !103
  call void asm sideeffect "nop", ""(), !dbg !103
  call void asm sideeffect "nop", ""(), !dbg !103
  store volatile i16 %20, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 2, i32 0), align 2, !dbg !103
  store volatile i16 %27, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 2, i32 1), align 2, !dbg !103
  store volatile i16 %25, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 2, i32 2), align 2, !dbg !103
  store volatile i16 %23, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 2, i32 3), align 2, !dbg !103
  call void asm sideeffect "nop", ""(), !dbg !103
  call void asm sideeffect "nop", ""(), !dbg !103
  call void @llvm.sdr.imov32.ds1(i16 2, i16 2), !dbg !103
  br label %36, !dbg !93

36:                                               ; preds = %10, %11, %41, %42
  %37 = phi i16 [ 0, %41 ], [ 0, %42 ], [ 1, %11 ], [ 1, %10 ]
  store i16 %37, i16* @state, align 2, !dbg !104
  br label %43, !dbg !90

38:                                               ; preds = %4
  %39 = load i16, i16* @is_odd, align 2, !dbg !105
  %40 = icmp ult i16 0, %39, !dbg !106
  br i1 %40, label %41, label %42, !dbg !107

41:                                               ; preds = %38
  call void @llvm.sdr.lds1wds(i16 3, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__2 to i8*)), !dbg !108
  call void @llvm.sdr.lddwds(i16 3, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__3 to i8*)), !dbg !108
  call void @llvm.sdr.imov32.ds1(i16 3, i16 3), !dbg !108
  br label %36, !dbg !107

42:                                               ; preds = %38
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !109
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !109
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !109
  br label %36, !dbg !107

43:                                               ; preds = %36
  br label %63, !dbg !87

44:                                               ; preds = %0
  %45 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 0), align 2, !dbg !110
  %46 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 1), align 2, !dbg !110
  %47 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 2), align 2, !dbg !110
  %48 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_txact_dst, i32 0, i32 3), align 2, !dbg !110
  %49 = and i16 %47, -193, !dbg !110
  %50 = or i16 %49, 128, !dbg !110
  %51 = and i16 %46, -64, !dbg !110
  %52 = or i16 %51, 62, !dbg !110
  %53 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 0), align 2, !dbg !111
  %54 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 1), align 2, !dbg !111
  %55 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 2), align 2, !dbg !111
  %56 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @gdsr_rxact_s1, i32 0, i32 3), align 2, !dbg !111
  %57 = and i16 %55, -193, !dbg !111
  %58 = or i16 %57, 128, !dbg !111
  %59 = and i16 %54, -64, !dbg !111
  %60 = or i16 %59, 62, !dbg !111
  store volatile i16 %53, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 4, i32 0), align 2, !dbg !112
  store volatile i16 %60, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 4, i32 1), align 2, !dbg !112
  store volatile i16 %58, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 4, i32 2), align 2, !dbg !112
  store volatile i16 %56, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 4, i32 3), align 2, !dbg !112
  call void asm sideeffect "nop", ""(), !dbg !112
  call void asm sideeffect "nop", ""(), !dbg !112
  store volatile i16 %45, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 4, i32 0), align 2, !dbg !112
  store volatile i16 %52, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 4, i32 1), align 2, !dbg !112
  store volatile i16 %50, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 4, i32 2), align 2, !dbg !112
  store volatile i16 %48, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 4, i32 3), align 2, !dbg !112
  call void asm sideeffect "nop", ""(), !dbg !112
  call void asm sideeffect "nop", ""(), !dbg !112
  call void @llvm.sdr.imov32.ds1(i16 4, i16 4), !dbg !112
  %61 = load i16, i16* @idx_send, align 2, !dbg !113
  %62 = add i16 %61, 1, !dbg !114
  store i16 %62, i16* @idx_send, align 2, !dbg !115
  br label %63, !dbg !87

63:                                               ; preds = %43, %44
  ret void, !dbg !87
}

define void @f_padding_done() #5 !dbg !116 {
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !117
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !117
  call void @llvm.sdr.imov32.ds1(i16 0, i16 0), !dbg !117
  ret void, !dbg !119
}

define void @f_teardown() #6 !dbg !120 {
  %1 = alloca i32, i16 1, align 4, !dbg !121
  %2 = call i32 @tile_config.teardown.get_pending(), !dbg !123
  store i32 %2, i32* %1, align 4, !dbg !121
  call void @tile_config.teardown.exit(i16 1), !dbg !124
  ret void, !dbg !125
}

define internal i32 @tile_config.teardown.get_pending() !dbg !126 {
  %1 = alloca i16, i16 1, align 2, !dbg !128
  %2 = alloca i16, i16 1, align 2, !dbg !130
  call void asm sideeffect "nop", ""(), !dbg !131
  call void asm sideeffect "nop", ""(), !dbg !131
  %3 = load volatile i16, i16* inttoptr (i16 -1916 to i16*), align 2, !dbg !131
  store i16 %3, i16* %2, align 2, !dbg !130
  %4 = load volatile i16, i16* inttoptr (i16 -1914 to i16*), align 2, !dbg !132
  store i16 %4, i16* %1, align 2, !dbg !128
  %5 = load i16, i16* %1, align 2, !dbg !133
  %6 = zext i16 %5 to i32, !dbg !134
  %7 = shl i32 %6, 16, !dbg !135
  %8 = load i16, i16* %2, align 2, !dbg !136
  %9 = zext i16 %8 to i32, !dbg !137
  %10 = or i32 %7, %9, !dbg !138
  ret i32 %10, !dbg !139
}

define internal void @tile_config.teardown.exit(i16 %0) !dbg !140 {
  %2 = alloca i16, i16 1, align 2, !dbg !141
  %3 = alloca i16, i16 1, align 2, !dbg !143
  %4 = alloca i16, i16 1, align 2, !dbg !144
  %5 = alloca i16, i16 1, align 2, !dbg !145
  store i16 %0, i16* %5, align 2, !dbg !145
  %6 = load i16, i16* %5, align 2, !dbg !146
  store i16 %6, i16* %4, align 2, !dbg !144
  %7 = load i16, i16* %4, align 2, !dbg !147
  %8 = add i16 %7, 31744, !dbg !148
  store i16 %8, i16* %3, align 2, !dbg !143
  %9 = load i16, i16* %3, align 2, !dbg !149
  %10 = shl i16 %9, 1, !dbg !150
  %11 = inttoptr i16 %10 to i16*, !dbg !150
  call void asm sideeffect "nop", ""(), !dbg !150
  call void asm sideeffect "nop", ""(), !dbg !150
  %12 = load volatile i16, i16* %11, align 2, !dbg !150
  store i16 %12, i16* %2, align 2, !dbg !141
  %13 = load i16, i16* %3, align 2, !dbg !151
  %14 = load i16, i16* %2, align 2, !dbg !152
  %15 = and i16 %14, 32767, !dbg !153
  %16 = shl i16 %13, 1, !dbg !154
  %17 = inttoptr i16 %16 to i16*, !dbg !154
  store volatile i16 %15, i16* %17, align 2, !dbg !154
  call void asm sideeffect "nop", ""(), !dbg !154
  call void asm sideeffect "nop", ""(), !dbg !154
  ret void, !dbg !155
}

; Function Attrs: nounwind
declare void @llvm.sdr.actvt.r(i16) #7

; Function Attrs: nounwind
declare void @llvm.sdr.blk.r(i16) #7

; Function Attrs: nounwind
declare void @llvm.sdr.ublk.r(i16) #7

; Function Attrs: nounwind
declare i16 @llvm.sdr.read.lfsr() #7

; Function Attrs: nounwind
declare void @llvm.sdr.stprng.r(i16) #7

; Function Attrs: nounwind
declare void @llvm.sdr.lds0wds(i16 immarg, i8* readonly) #7

; Function Attrs: nounwind
declare void @llvm.sdr.lds1wds(i16 immarg, i8* readonly) #7

; Function Attrs: nounwind
declare void @llvm.sdr.lddwds(i16 immarg, i8* readonly) #7

; Function Attrs: nounwind
declare void @llvm.sdr.ldxds(i16 immarg, i8* readonly) #7

; Function Attrs: nounwind
declare void @llvm.sdr.ldsr(i16 immarg, i8* readonly) #7

; Function Attrs: nounwind writeonly
declare void @llvm.sdr.iqflush(i16) #8

; Function Attrs: nounwind writeonly
declare void @llvm.sdr.oqflush(i16) #8

; Function Attrs: nounwind
declare void @llvm.sdr.imov32.ds1(i16 immarg, i16 immarg) #7

; Function Attrs: nounwind
declare void @llvm.sdr.imov16.ds1(i16 immarg, i16 immarg) #7

declare i16 @csl.ss.read.16(i16, i1)

declare i32 @csl.ss.read.32(i16, i1)

declare void @csl.ss.write.16(i16, i16, i1)

declare void @csl.ss.write.32(i16, i32, i1)

declare i1 @csl.ss.set_jump_target()

declare i1 @csl.fifo.set_jump_target()

attributes #0 = { "entry-point"="25" "task" }
attributes #1 = { "entry-point"="26" "task" }
attributes #2 = { "entry-point"="27" "task" }
attributes #3 = { "entry-point"="28" "task" }
attributes #4 = { "entry-point"="30" "task" }
attributes #5 = { "entry-point"="24" "task" }
attributes #6 = { "entry-point"="29" "task" }
attributes #7 = { nounwind }
attributes #8 = { nounwind writeonly }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!2}

!0 = distinct !DICompileUnit(language: DW_LANG_C, file: !1, producer: "mlir", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug)
!1 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/runtime/layout_east_mux_multi.csl", directory: "/")
!2 = !{i32 2, !"Debug Info Version", i32 3}
!3 = distinct !DISubprogram(name: "f_startup", linkageName: "f_startup", scope: null, file: !4, line: 238, type: !5, scopeLine: 238, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!4 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/runtime/mux_adaptor_N1.csl", directory: "")
!5 = !DISubroutineType(types: !6)
!6 = !{}
!7 = !DILocation(line: 245, column: 5, scope: !8)
!8 = !DILexicalBlockFile(scope: !3, file: !4, discriminator: 0)
!9 = !DILocation(line: 238, column: 1, scope: !8)
!10 = distinct !DISubprogram(name: "f_config", linkageName: "f_config", scope: null, file: !4, line: 250, type: !5, scopeLine: 250, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!11 = !DILocation(line: 269, column: 9, scope: !12)
!12 = !DILexicalBlockFile(scope: !10, file: !4, discriminator: 0)
!13 = !DILocation(line: 268, column: 9, scope: !12)
!14 = !DILocation(line: 266, column: 5, scope: !12)
!15 = !DILocation(line: 265, column: 5, scope: !12)
!16 = !DILocation(line: 255, column: 5, scope: !12)
!17 = !DILocation(line: 257, column: 32, scope: !12)
!18 = !DILocation(line: 257, column: 42, scope: !12)
!19 = !DILocation(line: 257, column: 16, scope: !12)
!20 = !DILocation(line: 258, column: 30, scope: !12)
!21 = !DILocation(line: 258, column: 40, scope: !12)
!22 = !DILocation(line: 258, column: 14, scope: !12)
!23 = !DILocation(line: 259, column: 34, scope: !12)
!24 = !DILocation(line: 259, column: 44, scope: !12)
!25 = !DILocation(line: 259, column: 18, scope: !12)
!26 = !DILocation(line: 260, column: 28, scope: !12)
!27 = !DILocation(line: 260, column: 38, scope: !12)
!28 = !DILocation(line: 260, column: 12, scope: !12)
!29 = !DILocation(line: 267, column: 5, scope: !12)
!30 = !DILocation(line: 267, column: 11, scope: !12)
!31 = !DILocation(line: 267, column: 15, scope: !12)
!32 = !DILocation(line: 268, column: 30, scope: !12)
!33 = !DILocation(line: 268, column: 41, scope: !12)
!34 = !DILocation(line: 268, column: 40, scope: !12)
!35 = !DILocation(line: 269, column: 29, scope: !12)
!36 = !DILocation(line: 270, column: 19, scope: !12)
!37 = !DILocation(line: 270, column: 16, scope: !12)
!38 = !DILocation(line: 270, column: 9, scope: !12)
!39 = !DILocation(line: 271, column: 21, scope: !12)
!40 = !DILocation(line: 273, column: 27, scope: !12)
!41 = !DILocation(line: 273, column: 9, scope: !12)
!42 = !DILocation(line: 273, column: 20, scope: !12)
!43 = !DILocation(line: 273, column: 19, scope: !12)
!44 = !DILocation(line: 273, column: 25, scope: !12)
!45 = !DILocation(line: 274, column: 20, scope: !12)
!46 = !DILocation(line: 274, column: 31, scope: !12)
!47 = !DILocation(line: 274, column: 29, scope: !12)
!48 = !DILocation(line: 274, column: 18, scope: !12)
!49 = !DILocation(line: 267, column: 23, scope: !12)
!50 = !DILocation(line: 267, column: 27, scope: !12)
!51 = !DILocation(line: 280, column: 24, scope: !12)
!52 = !DILocation(line: 280, column: 22, scope: !12)
!53 = !DILocation(line: 285, column: 24, scope: !12)
!54 = !DILocation(line: 285, column: 34, scope: !12)
!55 = !DILocation(line: 285, column: 22, scope: !12)
!56 = !DILocation(line: 286, column: 17, scope: !12)
!57 = !DILocation(line: 286, column: 27, scope: !12)
!58 = !DILocation(line: 286, column: 15, scope: !12)
!59 = !DILocation(line: 289, column: 36, scope: !12)
!60 = !DILocation(line: 289, column: 5, scope: !12)
!61 = !DILocation(line: 289, column: 15, scope: !12)
!62 = !DILocation(line: 289, column: 21, scope: !12)
!63 = !DILocation(line: 292, column: 5, scope: !12)
!64 = distinct !DISubprogram(name: "f_txtd0_done", linkageName: "f_txtd0_done", scope: null, file: !4, line: 299, type: !5, scopeLine: 299, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!65 = !DILocation(line: 301, column: 5, scope: !66)
!66 = !DILexicalBlockFile(scope: !64, file: !4, discriminator: 0)
!67 = !DILocation(line: 299, column: 1, scope: !66)
!68 = distinct !DISubprogram(name: "f_txtd1_done", linkageName: "f_txtd1_done", scope: null, file: !4, line: 307, type: !5, scopeLine: 307, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!69 = !DILocation(line: 309, column: 27, scope: !70)
!70 = !DILexicalBlockFile(scope: !68, file: !4, discriminator: 0)
!71 = !DILocation(line: 309, column: 11, scope: !70)
!72 = !DILocation(line: 309, column: 5, scope: !70)
!73 = !DILocation(line: 313, column: 9, scope: !70)
!74 = !DILocation(line: 315, column: 42, scope: !70)
!75 = !DILocation(line: 315, column: 58, scope: !70)
!76 = !DILocation(line: 315, column: 24, scope: !70)
!77 = !DILocation(line: 316, column: 42, scope: !70)
!78 = !DILocation(line: 316, column: 58, scope: !70)
!79 = !DILocation(line: 316, column: 24, scope: !70)
!80 = !DILocation(line: 318, column: 18, scope: !70)
!81 = !DILocation(line: 319, column: 9, scope: !70)
!82 = distinct !DISubprogram(name: "f_rxdone", linkageName: "f_rxdone", scope: null, file: !4, line: 330, type: !5, scopeLine: 330, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!83 = !DILocation(line: 331, column: 10, scope: !84)
!84 = !DILexicalBlockFile(scope: !82, file: !4, discriminator: 0)
!85 = !DILocation(line: 331, column: 22, scope: !84)
!86 = !DILocation(line: 331, column: 19, scope: !84)
!87 = !DILocation(line: 331, column: 5, scope: !84)
!88 = !DILocation(line: 332, column: 18, scope: !84)
!89 = !DILocation(line: 332, column: 15, scope: !84)
!90 = !DILocation(line: 332, column: 9, scope: !84)
!91 = !DILocation(line: 334, column: 23, scope: !84)
!92 = !DILocation(line: 334, column: 20, scope: !84)
!93 = !DILocation(line: 334, column: 13, scope: !84)
!94 = !DILocation(line: 335, column: 17, scope: !84)
!95 = !DILocation(line: 337, column: 50, scope: !84)
!96 = !DILocation(line: 337, column: 66, scope: !84)
!97 = !DILocation(line: 337, column: 32, scope: !84)
!98 = !DILocation(line: 338, column: 50, scope: !84)
!99 = !DILocation(line: 338, column: 66, scope: !84)
!100 = !DILocation(line: 338, column: 32, scope: !84)
!101 = !DILocation(line: 339, column: 24, scope: !84)
!102 = !DILocation(line: 339, column: 40, scope: !84)
!103 = !DILocation(line: 339, column: 17, scope: !84)
!104 = !DILocation(line: 341, column: 19, scope: !84)
!105 = !DILocation(line: 344, column: 22, scope: !84)
!106 = !DILocation(line: 344, column: 20, scope: !84)
!107 = !DILocation(line: 344, column: 13, scope: !84)
!108 = !DILocation(line: 346, column: 17, scope: !84)
!109 = !DILocation(line: 349, column: 17, scope: !84)
!110 = !DILocation(line: 356, column: 16, scope: !84)
!111 = !DILocation(line: 356, column: 32, scope: !84)
!112 = !DILocation(line: 356, column: 9, scope: !84)
!113 = !DILocation(line: 357, column: 20, scope: !84)
!114 = !DILocation(line: 357, column: 29, scope: !84)
!115 = !DILocation(line: 357, column: 18, scope: !84)
!116 = distinct !DISubprogram(name: "f_padding_done", linkageName: "f_padding_done", scope: null, file: !4, line: 362, type: !5, scopeLine: 362, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!117 = !DILocation(line: 363, column: 5, scope: !118)
!118 = !DILexicalBlockFile(scope: !116, file: !4, discriminator: 0)
!119 = !DILocation(line: 362, column: 1, scope: !118)
!120 = distinct !DISubprogram(name: "f_teardown", linkageName: "f_teardown", scope: null, file: !4, line: 370, type: !5, scopeLine: 370, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!121 = !DILocation(line: 373, column: 5, scope: !122)
!122 = !DILexicalBlockFile(scope: !120, file: !4, discriminator: 0)
!123 = !DILocation(line: 373, column: 21, scope: !122)
!124 = !DILocation(line: 377, column: 5, scope: !122)
!125 = !DILocation(line: 370, column: 1, scope: !122)
!126 = distinct !DISubprogram(name: "tile_config.teardown.get_pending", linkageName: "tile_config.teardown.get_pending", scope: null, file: !127, line: 20, type: !5, scopeLine: 20, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!127 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/tile_config/teardown.csl", directory: "")
!128 = !DILocation(line: 23, column: 3, scope: !129)
!129 = !DILexicalBlockFile(scope: !126, file: !127, discriminator: 0)
!130 = !DILocation(line: 21, column: 3, scope: !129)
!131 = !DILocation(line: 22, column: 7, scope: !129)
!132 = !DILocation(line: 24, column: 7, scope: !129)
!133 = !DILocation(line: 25, column: 32, scope: !129)
!134 = !DILocation(line: 25, column: 11, scope: !129)
!135 = !DILocation(line: 25, column: 41, scope: !129)
!136 = !DILocation(line: 26, column: 32, scope: !129)
!137 = !DILocation(line: 26, column: 11, scope: !129)
!138 = !DILocation(line: 25, column: 61, scope: !129)
!139 = !DILocation(line: 25, column: 3, scope: !129)
!140 = distinct !DISubprogram(name: "tile_config.teardown.exit", linkageName: "tile_config.teardown.exit", scope: null, file: !127, line: 39, type: !5, scopeLine: 39, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!141 = !DILocation(line: 43, column: 3, scope: !142)
!142 = !DILexicalBlockFile(scope: !140, file: !127, discriminator: 0)
!143 = !DILocation(line: 41, column: 3, scope: !142)
!144 = !DILocation(line: 40, column: 3, scope: !142)
!145 = !DILocation(line: 39, column: 9, scope: !142)
!146 = !DILocation(line: 40, column: 23, scope: !142)
!147 = !DILocation(line: 41, column: 70, scope: !142)
!148 = !DILocation(line: 41, column: 68, scope: !142)
!149 = !DILocation(line: 43, column: 27, scope: !142)
!150 = !DILocation(line: 43, column: 15, scope: !142)
!151 = !DILocation(line: 44, column: 15, scope: !142)
!152 = !DILocation(line: 44, column: 21, scope: !142)
!153 = !DILocation(line: 44, column: 27, scope: !142)
!154 = !DILocation(line: 44, column: 3, scope: !142)
!155 = !DILocation(line: 39, column: 1, scope: !142)
module asm ".section \22.pe_debug_info\22, \22\22"
module asm ".section \22.note\22, \22\22"
