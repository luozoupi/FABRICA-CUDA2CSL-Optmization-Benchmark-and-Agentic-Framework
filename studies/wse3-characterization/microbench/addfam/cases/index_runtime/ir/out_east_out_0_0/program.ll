; ModuleID = '/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/runtime/layout_east_mux_multi.csl'
source_filename = "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/runtime/layout_east_mux_multi.csl"
target datalayout = "e-ni:0-p:16:16-i1:16-i16:16-i32:32-i64:64-f32:32-f64:64"
target triple = "cs_sdr-cerebras-csos"

@"$$csl_base_address$$0$$config_buf" = dso_local global [4 x i16] zeroinitializer, align 4
@receiver_idx = internal global i16 -1, align 4
@num_receivers = internal global i16 0, align 4
@pes_per_receiver = internal global i16 0, align 4
@pe_length = internal global i16 0, align 4
@num_send = internal global i16 0, align 4
@idx_send = internal global i16 0, align 4
@fab_recv_wdsd = internal global <{ i16, i16, i16, i16 }> <{ i16 1, i16 3999, i16 -32562, i16 16 }>, align 4
@fab_trans_wdsd = internal global <{ i16, i16, i16, i16 }> <{ i16 1, i16 31, i16 -30258, i16 16 }>, align 4
@__dsr_lowmeminit_ = internal constant <{ i16, i16, i16, i16 }> <{ i16 4, i16 lshr (i16 ptrtoint ([4 x i16]* @"$$csl_base_address$$0$$config_buf" to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__0 = internal constant <{ i16, i16, i16, i16 }> <{ i16 4, i16 4025, i16 4750, i16 16 }>, section ".data.lo", align 4

declare i8* @malloc(i64)

declare void @free(i8*)

define void @f_startup() #0 !dbg !3 {
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !7
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !7
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !7
  ret void, !dbg !9
}

define void @f_config() #1 !dbg !10 {
  %1 = load i16, i16* getelementptr inbounds ([4 x i16], [4 x i16]* @"$$csl_base_address$$0$$config_buf", i16 0, i16 0), align 2, !dbg !11
  store i16 %1, i16* @receiver_idx, align 2, !dbg !13
  %2 = load i16, i16* getelementptr inbounds ([4 x i16], [4 x i16]* @"$$csl_base_address$$0$$config_buf", i16 0, i16 1), align 2, !dbg !14
  store i16 %2, i16* @pes_per_receiver, align 2, !dbg !15
  %3 = load i16, i16* getelementptr inbounds ([4 x i16], [4 x i16]* @"$$csl_base_address$$0$$config_buf", i16 0, i16 2), align 2, !dbg !16
  store i16 %3, i16* @pe_length, align 2, !dbg !17
  %4 = load i16, i16* getelementptr inbounds ([4 x i16], [4 x i16]* @"$$csl_base_address$$0$$config_buf", i16 0, i16 3), align 2, !dbg !18
  store i16 %4, i16* @num_receivers, align 2, !dbg !19
  call void @llvm.sdr.actvt.r(i16 28), !dbg !20
  ret void, !dbg !21
}

define void @f_txact_next_tensor() #2 !dbg !22 {
  %1 = load i16, i16* @pe_length, align 2, !dbg !23
  store i16 %1, i16* @num_send, align 2, !dbg !25
  store i16 0, i16* @idx_send, align 2, !dbg !26
  %2 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !27
  %3 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !27
  %4 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !27
  %5 = load i16, i16* @pes_per_receiver, align 2, !dbg !28
  store i16 %5, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !29
  store i16 %2, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !29
  store i16 %3, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !29
  store i16 %4, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !29
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !30
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !30
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !30
  %9 = load i16, i16* @pes_per_receiver, align 2, !dbg !31
  store i16 %9, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !32
  store i16 %6, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !32
  store i16 %7, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !32
  store i16 %8, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !32
  call void @llvm.sdr.actvt.r(i16 30), !dbg !33
  ret void, !dbg !34
}

define void @f_txact_next_chunk() #3 !dbg !35 {
  %1 = load i16, i16* @idx_send, align 2, !dbg !36
  %2 = load i16, i16* @num_send, align 2, !dbg !38
  %3 = icmp slt i16 %1, %2, !dbg !39
  br i1 %3, label %4, label %23, !dbg !40

4:                                                ; preds = %0
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !41
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !41
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !41
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !41
  %9 = and i16 %7, -193, !dbg !41
  %10 = or i16 %9, 128, !dbg !41
  %11 = and i16 %6, -64, !dbg !41
  %12 = or i16 %11, 62, !dbg !41
  %13 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !42
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !42
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !42
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !42
  %17 = and i16 %15, -193, !dbg !42
  %18 = or i16 %17, 128, !dbg !42
  %19 = and i16 %14, -64, !dbg !42
  %20 = or i16 %19, 62, !dbg !42
  store volatile i16 %5, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 0), align 2, !dbg !43
  store volatile i16 %12, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 1), align 2, !dbg !43
  store volatile i16 %10, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 2), align 2, !dbg !43
  store volatile i16 %8, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 3), align 2, !dbg !43
  call void asm sideeffect "nop", ""(), !dbg !43
  call void asm sideeffect "nop", ""(), !dbg !43
  store volatile i16 %13, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 0), align 2, !dbg !43
  store volatile i16 %20, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 1), align 2, !dbg !43
  store volatile i16 %18, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 2), align 2, !dbg !43
  store volatile i16 %16, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 3), align 2, !dbg !43
  call void asm sideeffect "nop", ""(), !dbg !43
  call void asm sideeffect "nop", ""(), !dbg !43
  call void @llvm.sdr.imov32.ds1(i16 1, i16 1), !dbg !43
  %21 = load i16, i16* @idx_send, align 2, !dbg !44
  %22 = add i16 %21, 1, !dbg !45
  store i16 %22, i16* @idx_send, align 2, !dbg !46
  br label %24, !dbg !40

23:                                               ; preds = %0
  call void @llvm.sdr.actvt.r(i16 24), !dbg !47
  br label %24, !dbg !40

24:                                               ; preds = %4, %23
  ret void, !dbg !40
}

; Function Attrs: nounwind
declare void @llvm.sdr.actvt.r(i16) #4

; Function Attrs: nounwind
declare void @llvm.sdr.blk.r(i16) #4

; Function Attrs: nounwind
declare void @llvm.sdr.ublk.r(i16) #4

; Function Attrs: nounwind
declare i16 @llvm.sdr.read.lfsr() #4

; Function Attrs: nounwind
declare void @llvm.sdr.stprng.r(i16) #4

; Function Attrs: nounwind
declare void @llvm.sdr.lds0wds(i16 immarg, i8* readonly) #4

; Function Attrs: nounwind
declare void @llvm.sdr.lds1wds(i16 immarg, i8* readonly) #4

; Function Attrs: nounwind
declare void @llvm.sdr.lddwds(i16 immarg, i8* readonly) #4

; Function Attrs: nounwind
declare void @llvm.sdr.ldxds(i16 immarg, i8* readonly) #4

; Function Attrs: nounwind
declare void @llvm.sdr.ldsr(i16 immarg, i8* readonly) #4

; Function Attrs: nounwind writeonly
declare void @llvm.sdr.iqflush(i16) #5

; Function Attrs: nounwind writeonly
declare void @llvm.sdr.oqflush(i16) #5

; Function Attrs: nounwind
declare void @llvm.sdr.imov32.ds1(i16 immarg, i16 immarg) #4

; Function Attrs: nounwind
declare void @llvm.sdr.imov16.ds1(i16 immarg, i16 immarg) #4

declare i16 @csl.ss.read.16(i16, i1)

declare i32 @csl.ss.read.32(i16, i1)

declare void @csl.ss.write.16(i16, i16, i1)

declare void @csl.ss.write.32(i16, i32, i1)

declare i1 @csl.ss.set_jump_target()

declare i1 @csl.fifo.set_jump_target()

attributes #0 = { "entry-point"="24" "task" }
attributes #1 = { "entry-point"="25" "task" }
attributes #2 = { "entry-point"="28" "task" }
attributes #3 = { "entry-point"="30" "task" }
attributes #4 = { nounwind }
attributes #5 = { nounwind writeonly }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!2}

!0 = distinct !DICompileUnit(language: DW_LANG_C, file: !1, producer: "mlir", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug)
!1 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/runtime/layout_east_mux_multi.csl", directory: "/")
!2 = !{i32 2, !"Debug Info Version", i32 3}
!3 = distinct !DISubprogram(name: "f_startup", linkageName: "f_startup", scope: null, file: !4, line: 186, type: !5, scopeLine: 186, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!4 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/runtime/mux_N1.csl", directory: "")
!5 = !DISubroutineType(types: !6)
!6 = !{}
!7 = !DILocation(line: 188, column: 5, scope: !8)
!8 = !DILexicalBlockFile(scope: !3, file: !4, discriminator: 0)
!9 = !DILocation(line: 186, column: 1, scope: !8)
!10 = distinct !DISubprogram(name: "f_config", linkageName: "f_config", scope: null, file: !4, line: 201, type: !5, scopeLine: 201, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!11 = !DILocation(line: 205, column: 30, scope: !12)
!12 = !DILexicalBlockFile(scope: !10, file: !4, discriminator: 0)
!13 = !DILocation(line: 205, column: 18, scope: !12)
!14 = !DILocation(line: 209, column: 34, scope: !12)
!15 = !DILocation(line: 209, column: 22, scope: !12)
!16 = !DILocation(line: 212, column: 27, scope: !12)
!17 = !DILocation(line: 212, column: 15, scope: !12)
!18 = !DILocation(line: 216, column: 31, scope: !12)
!19 = !DILocation(line: 216, column: 19, scope: !12)
!20 = !DILocation(line: 219, column: 5, scope: !12)
!21 = !DILocation(line: 201, column: 1, scope: !12)
!22 = distinct !DISubprogram(name: "f_txact_next_tensor", linkageName: "f_txact_next_tensor", scope: null, file: !4, line: 230, type: !5, scopeLine: 230, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!23 = !DILocation(line: 233, column: 16, scope: !24)
!24 = !DILexicalBlockFile(scope: !22, file: !4, discriminator: 0)
!25 = !DILocation(line: 233, column: 14, scope: !24)
!26 = !DILocation(line: 234, column: 14, scope: !24)
!27 = !DILocation(line: 237, column: 38, scope: !24)
!28 = !DILocation(line: 237, column: 62, scope: !24)
!29 = !DILocation(line: 237, column: 20, scope: !24)
!30 = !DILocation(line: 238, column: 38, scope: !24)
!31 = !DILocation(line: 238, column: 63, scope: !24)
!32 = !DILocation(line: 238, column: 20, scope: !24)
!33 = !DILocation(line: 240, column: 5, scope: !24)
!34 = !DILocation(line: 230, column: 1, scope: !24)
!35 = distinct !DISubprogram(name: "f_txact_next_chunk", linkageName: "f_txact_next_chunk", scope: null, file: !4, line: 254, type: !5, scopeLine: 254, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!36 = !DILocation(line: 255, column: 10, scope: !37)
!37 = !DILexicalBlockFile(scope: !35, file: !4, discriminator: 0)
!38 = !DILocation(line: 255, column: 21, scope: !37)
!39 = !DILocation(line: 255, column: 19, scope: !37)
!40 = !DILocation(line: 255, column: 5, scope: !37)
!41 = !DILocation(line: 256, column: 16, scope: !37)
!42 = !DILocation(line: 256, column: 32, scope: !37)
!43 = !DILocation(line: 256, column: 9, scope: !37)
!44 = !DILocation(line: 257, column: 20, scope: !37)
!45 = !DILocation(line: 257, column: 29, scope: !37)
!46 = !DILocation(line: 257, column: 18, scope: !37)
!47 = !DILocation(line: 260, column: 9, scope: !37)
module asm ".section \22.pe_debug_info\22, \22\22"
module asm ".section \22.note\22, \22\22"
