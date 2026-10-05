; ModuleID = '/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/runtime/layout_west_demux_cmdfan_multi.csl'
source_filename = "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/runtime/layout_west_demux_cmdfan_multi.csl"
target datalayout = "e-ni:0-p:16:16-i1:16-i16:16-i32:32-i64:64-f32:32-f64:64"
target triple = "cs_sdr-cerebras-csos"

@"$$csl_base_address$$0$$config_buf" = dso_local global [5 x i16] zeroinitializer, align 4
@receiver_idx = internal global i16 -1, align 4
@num_receivers = internal global i16 0, align 4
@memcpy_optype = internal global i16 0, align 4
@num_pes_save = internal global i16 0, align 4
@pe_len_save = internal global i16 0, align 4
@pes_per_receiver = internal global i16 0, align 4
@pe_length = internal global i16 0, align 4
@num_send = internal global i16 0, align 4
@idx_send = internal global i16 0, align 4
@fab_recv_wdsd = internal global <{ i16, i16, i16, i16 }> <{ i16 1, i16 3999, i16 -32562, i16 16 }>, align 4
@fab_trans_wdsd = internal global <{ i16, i16, i16, i16 }> <{ i16 1, i16 31, i16 -32562, i16 16 }>, align 4
@__dsr_lowmeminit_ = internal constant <{ i16, i16, i16, i16 }> <{ i16 5, i16 lshr (i16 ptrtoint ([5 x i16]* @"$$csl_base_address$$0$$config_buf" to i16), i16 1), i16 143, i16 16 }>, section ".data.lo", align 4
@__dsr_lowmeminit__0 = internal constant <{ i16, i16, i16, i16 }> <{ i16 5, i16 4026, i16 142, i16 16 }>, section ".data.lo", align 4

declare i8* @malloc(i64)

declare void @free(i8*)

define void @f_startup() #0 !dbg !3 {
  call void @llvm.sdr.lddwds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit_ to i8*)), !dbg !7
  call void @llvm.sdr.lds1wds(i16 0, i8* bitcast (<{ i16, i16, i16, i16 }>* @__dsr_lowmeminit__0 to i8*)), !dbg !7
  call void @llvm.sdr.imov16.ds1(i16 0, i16 0), !dbg !7
  ret void, !dbg !9
}

define void @f_config() #1 !dbg !10 {
  %1 = load i16, i16* getelementptr inbounds ([5 x i16], [5 x i16]* @"$$csl_base_address$$0$$config_buf", i16 0, i16 0), align 2, !dbg !11
  store i16 %1, i16* @receiver_idx, align 2, !dbg !13
  %2 = load i16, i16* getelementptr inbounds ([5 x i16], [5 x i16]* @"$$csl_base_address$$0$$config_buf", i16 0, i16 1), align 2, !dbg !14
  store i16 %2, i16* @pes_per_receiver, align 2, !dbg !15
  %3 = load i16, i16* @receiver_idx, align 2, !dbg !16
  %4 = icmp ne i16 -1, %3, !dbg !17
  br i1 %4, label %5, label %7, !dbg !18

5:                                                ; preds = %0
  %6 = load i16, i16* @pes_per_receiver, align 2, !dbg !19
  store i16 %6, i16* @num_pes_save, align 2, !dbg !20
  br label %8, !dbg !18

7:                                                ; preds = %0
  store i16 0, i16* @num_pes_save, align 2, !dbg !21
  br label %8, !dbg !18

8:                                                ; preds = %5, %7
  %9 = load i16, i16* getelementptr inbounds ([5 x i16], [5 x i16]* @"$$csl_base_address$$0$$config_buf", i16 0, i16 2), align 2, !dbg !22
  store i16 %9, i16* @pe_length, align 2, !dbg !23
  %10 = load i16, i16* @pe_length, align 2, !dbg !24
  store i16 %10, i16* @pe_len_save, align 2, !dbg !25
  %11 = load i16, i16* getelementptr inbounds ([5 x i16], [5 x i16]* @"$$csl_base_address$$0$$config_buf", i16 0, i16 3), align 2, !dbg !26
  store i16 %11, i16* @num_receivers, align 2, !dbg !27
  %12 = load i16, i16* getelementptr inbounds ([5 x i16], [5 x i16]* @"$$csl_base_address$$0$$config_buf", i16 0, i16 4), align 2, !dbg !28
  store i16 %12, i16* @memcpy_optype, align 2, !dbg !29
  call void @llvm.sdr.actvt.r(i16 27), !dbg !30
  ret void, !dbg !18
}

define void @f_txact_next_tensor() #2 !dbg !31 {
  call void @llvm.sdr.blk.r(i16 0), !dbg !32
  %1 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !34
  %2 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !34
  %3 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !34
  %4 = load i16, i16* @pe_length, align 2, !dbg !35
  store i16 %4, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !36
  store i16 %1, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !36
  store i16 %2, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !36
  store i16 %3, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !36
  %5 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !37
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !37
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !37
  %8 = load i16, i16* @pe_length, align 2, !dbg !38
  store i16 %8, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !39
  store i16 %5, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !39
  store i16 %6, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !39
  store i16 %7, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !39
  %9 = load i16, i16* @num_pes_save, align 2, !dbg !40
  store i16 %9, i16* @num_send, align 2, !dbg !41
  store i16 0, i16* @idx_send, align 2, !dbg !42
  call void @llvm.sdr.actvt.r(i16 28), !dbg !43
  ret void, !dbg !44
}

define void @f_txact_next_chunk() #3 !dbg !45 {
  %1 = load i16, i16* @idx_send, align 2, !dbg !46
  %2 = load i16, i16* @num_send, align 2, !dbg !48
  %3 = icmp sge i16 %1, %2, !dbg !49
  br i1 %3, label %4, label %5, !dbg !50

4:                                                ; preds = %0
  call void @llvm.sdr.actvt.r(i16 25), !dbg !51
  br label %24, !dbg !50

5:                                                ; preds = %0
  %6 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_wdsd, i32 0, i32 0), align 2, !dbg !52
  %7 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_wdsd, i32 0, i32 1), align 2, !dbg !52
  %8 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_wdsd, i32 0, i32 2), align 2, !dbg !52
  %9 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_trans_wdsd, i32 0, i32 3), align 2, !dbg !52
  %10 = and i16 %8, -193, !dbg !52
  %11 = or i16 %10, 128, !dbg !52
  %12 = and i16 %7, -64, !dbg !52
  %13 = or i16 %12, 60, !dbg !52
  %14 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_wdsd, i32 0, i32 0), align 2, !dbg !53
  %15 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_wdsd, i32 0, i32 1), align 2, !dbg !53
  %16 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_wdsd, i32 0, i32 2), align 2, !dbg !53
  %17 = load i16, i16* getelementptr inbounds (<{ i16, i16, i16, i16 }>, <{ i16, i16, i16, i16 }>* @fab_recv_wdsd, i32 0, i32 3), align 2, !dbg !53
  %18 = and i16 %16, -193, !dbg !53
  %19 = or i16 %18, 128, !dbg !53
  %20 = and i16 %15, -64, !dbg !53
  %21 = or i16 %20, 60, !dbg !53
  store volatile i16 %6, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 0), align 2, !dbg !54
  store volatile i16 %13, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 1), align 2, !dbg !54
  store volatile i16 %11, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 2), align 2, !dbg !54
  store volatile i16 %9, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -640 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 3), align 2, !dbg !54
  call void asm sideeffect "nop", ""(), !dbg !54
  call void asm sideeffect "nop", ""(), !dbg !54
  store volatile i16 %14, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 0), align 2, !dbg !54
  store volatile i16 %21, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 1), align 2, !dbg !54
  store volatile i16 %19, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 2), align 2, !dbg !54
  store volatile i16 %17, i16* getelementptr ([16 x <{ i16, i16, i16, i16 }>], [16 x <{ i16, i16, i16, i16 }>]* inttoptr (i16 -768 to [16 x <{ i16, i16, i16, i16 }>]*), i16 0, i16 1, i32 3), align 2, !dbg !54
  call void asm sideeffect "nop", ""(), !dbg !54
  call void asm sideeffect "nop", ""(), !dbg !54
  call void @llvm.sdr.imov32.ds1(i16 1, i16 1), !dbg !54
  %22 = load i16, i16* @idx_send, align 2, !dbg !55
  %23 = add i16 %22, 1, !dbg !56
  store i16 %23, i16* @idx_send, align 2, !dbg !57
  br label %24, !dbg !50

24:                                               ; preds = %4, %5
  ret void, !dbg !50
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

attributes #0 = { "entry-point"="25" "task" }
attributes #1 = { "entry-point"="26" "task" }
attributes #2 = { "entry-point"="27" "task" }
attributes #3 = { "entry-point"="28" "task" }
attributes #4 = { nounwind }
attributes #5 = { nounwind writeonly }

!llvm.dbg.cu = !{!0}
!llvm.module.flags = !{!2}

!0 = distinct !DICompileUnit(language: DW_LANG_C, file: !1, producer: "mlir", isOptimized: true, runtimeVersion: 0, emissionKind: FullDebug)
!1 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/runtime/layout_west_demux_cmdfan_multi.csl", directory: "/")
!2 = !{i32 2, !"Debug Info Version", i32 3}
!3 = distinct !DISubprogram(name: "f_startup", linkageName: "f_startup", scope: null, file: !4, line: 163, type: !5, scopeLine: 163, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!4 = !DIFile(filename: "/cb/toolchains/cslang/rel-sdk-2.10.0/202604012315-1813-1394a6ea/csl-libs/runtime/demux_N1.csl", directory: "")
!5 = !DISubroutineType(types: !6)
!6 = !{}
!7 = !DILocation(line: 165, column: 5, scope: !8)
!8 = !DILexicalBlockFile(scope: !3, file: !4, discriminator: 0)
!9 = !DILocation(line: 163, column: 1, scope: !8)
!10 = distinct !DISubprogram(name: "f_config", linkageName: "f_config", scope: null, file: !4, line: 176, type: !5, scopeLine: 176, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!11 = !DILocation(line: 180, column: 30, scope: !12)
!12 = !DILexicalBlockFile(scope: !10, file: !4, discriminator: 0)
!13 = !DILocation(line: 180, column: 18, scope: !12)
!14 = !DILocation(line: 185, column: 34, scope: !12)
!15 = !DILocation(line: 185, column: 22, scope: !12)
!16 = !DILocation(line: 186, column: 15, scope: !12)
!17 = !DILocation(line: 186, column: 12, scope: !12)
!18 = !DILocation(line: 186, column: 5, scope: !12)
!19 = !DILocation(line: 188, column: 23, scope: !12)
!20 = !DILocation(line: 188, column: 21, scope: !12)
!21 = !DILocation(line: 191, column: 21, scope: !12)
!22 = !DILocation(line: 196, column: 27, scope: !12)
!23 = !DILocation(line: 196, column: 15, scope: !12)
!24 = !DILocation(line: 197, column: 19, scope: !12)
!25 = !DILocation(line: 197, column: 17, scope: !12)
!26 = !DILocation(line: 201, column: 31, scope: !12)
!27 = !DILocation(line: 201, column: 19, scope: !12)
!28 = !DILocation(line: 205, column: 31, scope: !12)
!29 = !DILocation(line: 205, column: 19, scope: !12)
!30 = !DILocation(line: 208, column: 5, scope: !12)
!31 = distinct !DISubprogram(name: "f_txact_next_tensor", linkageName: "f_txact_next_tensor", scope: null, file: !4, line: 216, type: !5, scopeLine: 216, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!32 = !DILocation(line: 218, column: 5, scope: !33)
!33 = !DILexicalBlockFile(scope: !31, file: !4, discriminator: 0)
!34 = !DILocation(line: 222, column: 38, scope: !33)
!35 = !DILocation(line: 222, column: 62, scope: !33)
!36 = !DILocation(line: 222, column: 20, scope: !33)
!37 = !DILocation(line: 223, column: 38, scope: !33)
!38 = !DILocation(line: 223, column: 63, scope: !33)
!39 = !DILocation(line: 223, column: 20, scope: !33)
!40 = !DILocation(line: 224, column: 16, scope: !33)
!41 = !DILocation(line: 224, column: 14, scope: !33)
!42 = !DILocation(line: 225, column: 14, scope: !33)
!43 = !DILocation(line: 226, column: 5, scope: !33)
!44 = !DILocation(line: 216, column: 1, scope: !33)
!45 = distinct !DISubprogram(name: "f_txact_next_chunk", linkageName: "f_txact_next_chunk", scope: null, file: !4, line: 230, type: !5, scopeLine: 230, spFlags: DISPFlagDefinition | DISPFlagOptimized, unit: !0, retainedNodes: !6)
!46 = !DILocation(line: 231, column: 10, scope: !47)
!47 = !DILexicalBlockFile(scope: !45, file: !4, discriminator: 0)
!48 = !DILocation(line: 231, column: 22, scope: !47)
!49 = !DILocation(line: 231, column: 19, scope: !47)
!50 = !DILocation(line: 231, column: 5, scope: !47)
!51 = !DILocation(line: 235, column: 9, scope: !47)
!52 = !DILocation(line: 237, column: 16, scope: !47)
!53 = !DILocation(line: 237, column: 32, scope: !47)
!54 = !DILocation(line: 237, column: 9, scope: !47)
!55 = !DILocation(line: 238, column: 20, scope: !47)
!56 = !DILocation(line: 238, column: 28, scope: !47)
!57 = !DILocation(line: 238, column: 18, scope: !47)
module asm ".section \22.pe_debug_info\22, \22\22"
module asm ".section \22.note\22, \22\22"
