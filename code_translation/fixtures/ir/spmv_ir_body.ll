entry:
  store i16 28674, i16* getelementptr inbounds ([16 x i16], [16 x i16]* %%mark%%, i16 0, i16 2), align 2
  br label %row.head

row.head:
  %r = phi i16 [ 0, %entry ], [ %r.next, %row.tail ]
  %r.lt = icmp ult i16 %r, 16
  br i1 %r.lt, label %row.body, label %done

row.body:
  %sp = getelementptr [18 x i16], [18 x i16]* %%row_ptr%%, i16 0, i16 %r
  %s = load i16, i16* %sp, align 2
  %r.p1 = add i16 %r, 1
  %ep = getelementptr [18 x i16], [18 x i16]* %%row_ptr%%, i16 0, i16 %r.p1
  %e = load i16, i16* %ep, align 2
  br label %nz.head

nz.head:
  %j = phi i16 [ %s, %row.body ], [ %j.next, %nz.body ]
  %acc = phi float [ 0.000000e+00, %row.body ], [ %acc.next, %nz.body ]
  %j.lt = icmp ult i16 %j, %e
  br i1 %j.lt, label %nz.body, label %nz.done

nz.body:
  %cp = getelementptr [64 x i16], [64 x i16]* %%col_idx%%, i16 0, i16 %j
  %c = load i16, i16* %cp, align 2
  %vp = getelementptr [64 x float], [64 x float]* %%val%%, i16 0, i16 %j
  %v = load float, float* %vp, align 4
  %xp = getelementptr [16 x float], [16 x float]* %%x%%, i16 0, i16 %c
  %xv = load float, float* %xp, align 4
  %prod = fmul float %v, %xv
  %acc.next = fadd float %acc, %prod
  %j.next = add i16 %j, 1
  br label %nz.head

nz.done:
  %yp = getelementptr [16 x float], [16 x float]* %%y_ir%%, i16 0, i16 %r
  store float %acc, float* %yp, align 4
  br label %row.tail

row.tail:
  %r.next = add i16 %r, 1
  br label %row.head

done:
  store i16 28675, i16* getelementptr inbounds ([16 x i16], [16 x i16]* %%mark%%, i16 0, i16 3), align 2
  call void @llvm.sdr.actvt.r(i16 9)
  ret void
