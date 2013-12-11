; RUN: llc  -mtriple=mipsel-linux-gnu -march=mipsel -mcpu=mips16 -relocation-model=static  < %s | FileCheck %s -check-prefix=NEG

; RUN: llc  -mtriple=mipsel-linux-gnu -march=mipsel -mcpu=mips16 -relocation-model=static  < %s | FileCheck %s 

@f = common global float 0.000000e+00, align 4

; Function Attrs: nounwind
define void @foo1() #0 {
entry:
  %c = alloca [10 x i8], align 1
  %arraydecay = getelementptr inbounds [10 x i8]* %c, i32 0, i32 0
  call void @x(i8* %arraydecay)
  %arraydecay1 = getelementptr inbounds [10 x i8]* %c, i32 0, i32 0
  call void @x(i8* %arraydecay1)
  ret void
; CHECK: 	.ent	foo1
; CHECK: 	save	$ra, $16, $17, [[FS:[0-9]+]] # 16 bit inst
; CHECK: 	restore	$ra, $16, $17, [[FS]]
; CHECK: 	.end	foo1
}

declare void @x(i8*) #1

; Function Attrs: nounwind
define void @foo2() #0 {
entry:
  %c = alloca [150 x i8], align 1
  %arraydecay = getelementptr inbounds [150 x i8]* %c, i32 0, i32 0
  call void @x(i8* %arraydecay)
  %arraydecay1 = getelementptr inbounds [150 x i8]* %c, i32 0, i32 0
  call void @x(i8* %arraydecay1)
  ret void
; CHECK: 	.ent	foo2
; CHECK: 	save	$ra, $16, $17, [[FS:[0-9]+]]
; CHECK: 	restore	$ra, $16, $17, [[FS]]
; CHECK: 	.end	foo2
; NEG: 	.ent	foo2
; NEG-NOT: 	save	$ra, $16, $17, [[FS:[0-9]+]]  # 16 bit inst
; NEG-NOT: 	restore	$ra, $16, $17, [[FS]]  # 16 bit inst
; NEG: 	.end	foo2
}

; Function Attrs: nounwind
define void @foo3() #0 {
entry:
  %call = call float @xf()
  store float %call, float* @f, align 4
  ret void
; CHECK: 	.ent	foo3
; CHECK: 	save	$ra, $16, $17, [[FS:[0-9]+]], $18
; CHECK: 	restore	$ra, $16, $17, [[FS]], $18
; CHECK: 	.end	foo3
; NEG: 	.ent	foo3
; NEG-NOT: 	save	$ra, $16, $17, [[FS:[0-9]+]], $18  # 16 bit inst
; NEG-NOT: 	restore	$ra, $16, $17, [[FS]], $18  # 16 bit inst
; NEG: 	.end	foo3
}

declare float @xf() #1

attributes #0 = { nounwind "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { "less-precise-fpmad"="false" "no-frame-pointer-elim"="true" "no-frame-pointer-elim-non-leaf" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "stack-protector-buffer-size"="8" "unsafe-fp-math"="false" "use-soft-float"="false" }


