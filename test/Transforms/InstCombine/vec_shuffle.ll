; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s

define <4 x float> @test1(<4 x float> %v1) {
; CHECK-LABEL: @test1(
; CHECK-NEXT:    ret <4 x float> [[V1:%.*]]
;
  %v2 = shufflevector <4 x float> %v1, <4 x float> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  ret <4 x float> %v2
}

define <4 x float> @test2(<4 x float> %v1) {
; CHECK-LABEL: @test2(
; CHECK-NEXT:    ret <4 x float> [[V1:%.*]]
;
  %v2 = shufflevector <4 x float> %v1, <4 x float> %v1, <4 x i32> <i32 0, i32 5, i32 2, i32 7>
  ret <4 x float> %v2
}

define float @test3(<4 x float> %A, <4 x float> %B, float %f) {
; CHECK-LABEL: @test3(
; CHECK-NEXT:    ret float [[F:%.*]]
;
  %C = insertelement <4 x float> %A, float %f, i32 0
  %D = shufflevector <4 x float> %C, <4 x float> %B, <4 x i32> <i32 5, i32 0, i32 2, i32 7>
  %E = extractelement <4 x float> %D, i32 1
  ret float %E
}

define i32 @test4(<4 x i32> %X) {
; CHECK-LABEL: @test4(
; CHECK-NEXT:    [[R:%.*]] = extractelement <4 x i32> [[X:%.*]], i32 0
; CHECK-NEXT:    ret i32 [[R]]
;
  %t = shufflevector <4 x i32> %X, <4 x i32> undef, <4 x i32> zeroinitializer
  %r = extractelement <4 x i32> %t, i32 0
  ret i32 %r
}

define i32 @test5(<4 x i32> %X) {
; CHECK-LABEL: @test5(
; CHECK-NEXT:    [[R:%.*]] = extractelement <4 x i32> [[X:%.*]], i32 3
; CHECK-NEXT:    ret i32 [[R]]
;
  %t = shufflevector <4 x i32> %X, <4 x i32> undef, <4 x i32> <i32 3, i32 2, i32 undef, i32 undef>
  %r = extractelement <4 x i32> %t, i32 0
  ret i32 %r
}

define float @test6(<4 x float> %X) {
; CHECK-LABEL: @test6(
; CHECK-NEXT:    [[R:%.*]] = extractelement <4 x float> [[X:%.*]], i32 0
; CHECK-NEXT:    ret float [[R]]
;
  %X1 = bitcast <4 x float> %X to <4 x i32>
  %t = shufflevector <4 x i32> %X1, <4 x i32> undef, <4 x i32> zeroinitializer
  %t2 = bitcast <4 x i32> %t to <4 x float>
  %r = extractelement <4 x float> %t2, i32 0
  ret float %r
}

define <4 x float> @test7(<4 x float> %x) {
; CHECK-LABEL: @test7(
; CHECK-NEXT:    ret <4 x float> [[X:%.*]]
;
  %r = shufflevector <4 x float> %x, <4 x float> undef, <4 x i32> < i32 0, i32 1, i32 6, i32 7 >
  ret <4 x float> %r
}

; This should turn into a single shuffle.
define <4 x float> @test8(<4 x float> %x, <4 x float> %y) {
; CHECK-LABEL: @test8(
; CHECK-NEXT:    [[T134:%.*]] = shufflevector <4 x float> [[X:%.*]], <4 x float> [[Y:%.*]], <4 x i32> <i32 1, i32 undef, i32 3, i32 4>
; CHECK-NEXT:    ret <4 x float> [[T134]]
;
  %t4 = extractelement <4 x float> %x, i32 1
  %t2 = extractelement <4 x float> %x, i32 3
  %t1 = extractelement <4 x float> %y, i32 0
  %t128 = insertelement <4 x float> undef, float %t4, i32 0
  %t130 = insertelement <4 x float> %t128, float undef, i32 1
  %t132 = insertelement <4 x float> %t130, float %t2, i32 2
  %t134 = insertelement <4 x float> %t132, float %t1, i32 3
  ret <4 x float> %t134
}

; Test fold of two shuffles where the first shuffle vectors inputs are a
; different length then the second.
define <4 x i8> @test9(<16 x i8> %t6) {
; CHECK-LABEL: @test9(
; CHECK-NEXT:    [[T9:%.*]] = shufflevector <16 x i8> [[T6:%.*]], <16 x i8> undef, <4 x i32> <i32 13, i32 9, i32 4, i32 13>
; CHECK-NEXT:    ret <4 x i8> [[T9]]
;
  %t7 = shufflevector <16 x i8> %t6, <16 x i8> undef, <4 x i32> < i32 13, i32 9, i32 4, i32 13 >
  %t9 = shufflevector <4 x i8> %t7, <4 x i8> undef, <4 x i32> < i32 3, i32 1, i32 2, i32 0 >
  ret <4 x i8> %t9
}

; Same as test9, but make sure that "undef" mask values are not confused with
; mask values of 2*N, where N is the mask length.  These shuffles should not
; be folded (because [8,9,4,8] may not be a mask supported by the target).

define <4 x i8> @test9a(<16 x i8> %t6) {
; CHECK-LABEL: @test9a(
; CHECK-NEXT:    [[T7:%.*]] = shufflevector <16 x i8> [[T6:%.*]], <16 x i8> undef, <4 x i32> <i32 undef, i32 9, i32 4, i32 8>
; CHECK-NEXT:    [[T9:%.*]] = shufflevector <4 x i8> [[T7]], <4 x i8> undef, <4 x i32> <i32 3, i32 1, i32 2, i32 undef>
; CHECK-NEXT:    ret <4 x i8> [[T9]]
;
  %t7 = shufflevector <16 x i8> %t6, <16 x i8> undef, <4 x i32> < i32 undef, i32 9, i32 4, i32 8 >
  %t9 = shufflevector <4 x i8> %t7, <4 x i8> undef, <4 x i32> < i32 3, i32 1, i32 2, i32 0 >
  ret <4 x i8> %t9
}

; Test fold of two shuffles where the first shuffle vectors inputs are a
; different length then the second.
define <4 x i8> @test9b(<4 x i8> %t6, <4 x i8> %t7) {
; CHECK-LABEL: @test9b(
; CHECK-NEXT:    [[T9:%.*]] = shufflevector <4 x i8> [[T6:%.*]], <4 x i8> [[T7:%.*]], <4 x i32> <i32 0, i32 1, i32 4, i32 5>
; CHECK-NEXT:    ret <4 x i8> [[T9]]
;
  %t1 = shufflevector <4 x i8> %t6, <4 x i8> %t7, <8 x i32> <i32 0, i32 1, i32 4, i32 5, i32 4, i32 5, i32 2, i32 3>
  %t9 = shufflevector <8 x i8> %t1, <8 x i8> undef, <4 x i32> <i32 0, i32 1, i32 4, i32 5>
  ret <4 x i8> %t9
}

; Redundant vector splats should be removed.  Radar 8597790.
define <4 x i32> @test10(<4 x i32> %t5) {
; CHECK-LABEL: @test10(
; CHECK-NEXT:    [[T7:%.*]] = shufflevector <4 x i32> [[T5:%.*]], <4 x i32> undef, <4 x i32> <i32 1, i32 1, i32 1, i32 1>
; CHECK-NEXT:    ret <4 x i32> [[T7]]
;
  %t6 = shufflevector <4 x i32> %t5, <4 x i32> undef, <4 x i32> <i32 1, i32 undef, i32 undef, i32 undef>
  %t7 = shufflevector <4 x i32> %t6, <4 x i32> undef, <4 x i32> zeroinitializer
  ret <4 x i32> %t7
}

; Test fold of two shuffles where the two shufflevector inputs's op1 are
; the same
define <8 x i8> @test11(<16 x i8> %t6) {
; CHECK-LABEL: @test11(
; CHECK-NEXT:    [[T3:%.*]] = shufflevector <16 x i8> [[T6:%.*]], <16 x i8> undef, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
; CHECK-NEXT:    ret <8 x i8> [[T3]]
;
  %t1 = shufflevector <16 x i8> %t6, <16 x i8> undef, <4 x i32> <i32 0, i32 1, i32 2, i32 3>
  %t2 = shufflevector <16 x i8> %t6, <16 x i8> undef, <4 x i32> <i32 4, i32 5, i32 6, i32 7>
  %t3 = shufflevector <4 x i8> %t1, <4 x i8> %t2, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 4, i32 5, i32 6, i32 7>
  ret <8 x i8> %t3
}

; Test fold of two shuffles where the first shufflevector's inputs are
; the same as the second
define <8 x i8> @test12(<8 x i8> %t6, <8 x i8> %t2) {
; CHECK-LABEL: @test12(
; CHECK-NEXT:    [[T3:%.*]] = shufflevector <8 x i8> [[T6:%.*]], <8 x i8> [[T2:%.*]], <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 9, i32 8, i32 11, i32 12>
; CHECK-NEXT:    ret <8 x i8> [[T3]]
;
  %t1 = shufflevector <8 x i8> %t6, <8 x i8> undef, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 5, i32 4, i32 undef, i32 7>
  %t3 = shufflevector <8 x i8> %t1, <8 x i8> %t2, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 9, i32 8, i32 11, i32 12>
  ret <8 x i8> %t3
}

; Test fold of two shuffles where the first shufflevector's inputs are
; the same as the second
define <8 x i8> @test12a(<8 x i8> %t6, <8 x i8> %t2) {
; CHECK-LABEL: @test12a(
; CHECK-NEXT:    [[T3:%.*]] = shufflevector <8 x i8> [[T2:%.*]], <8 x i8> [[T6:%.*]], <8 x i32> <i32 0, i32 3, i32 1, i32 4, i32 8, i32 9, i32 10, i32 11>
; CHECK-NEXT:    ret <8 x i8> [[T3]]
;
  %t1 = shufflevector <8 x i8> %t6, <8 x i8> undef, <8 x i32> <i32 0, i32 1, i32 2, i32 3, i32 5, i32 4, i32 undef, i32 7>
  %t3 = shufflevector <8 x i8> %t2, <8 x i8> %t1, <8 x i32> <i32 0, i32 3, i32 1, i32 4, i32 8, i32 9, i32 10, i32 11>
  ret <8 x i8> %t3
}

define <2 x i8> @test13a(i8 %x1, i8 %x2) {
; CHECK-LABEL: @test13a(
; CHECK-NEXT:    [[TMP1:%.*]] = insertelement <2 x i8> undef, i8 [[X1:%.*]], i32 1
; CHECK-NEXT:    [[TMP2:%.*]] = insertelement <2 x i8> [[TMP1]], i8 [[X2:%.*]], i32 0
; CHECK-NEXT:    [[TMP3:%.*]] = add <2 x i8> [[TMP2]], <i8 7, i8 5>
; CHECK-NEXT:    ret <2 x i8> [[TMP3]]
;
  %A = insertelement <2 x i8> undef, i8 %x1, i32 0
  %B = insertelement <2 x i8> %A, i8 %x2, i32 1
  %C = add <2 x i8> %B, <i8 5, i8 7>
  %D = shufflevector <2 x i8> %C, <2 x i8> undef, <2 x i32> <i32 1, i32 0>
  ret <2 x i8> %D
}

define <2 x i8> @test13b(i8 %x) {
; CHECK-LABEL: @test13b(
; CHECK-NEXT:    [[TMP1:%.*]] = insertelement <2 x i8> undef, i8 [[X:%.*]], i32 1
; CHECK-NEXT:    ret <2 x i8> [[TMP1]]
;
  %A = insertelement <2 x i8> undef, i8 %x, i32 0
  %B = shufflevector <2 x i8> %A, <2 x i8> undef, <2 x i32> <i32 undef, i32 0>
  ret <2 x i8> %B
}

define <2 x i8> @test13c(i8 %x1, i8 %x2) {
; CHECK-LABEL: @test13c(
; CHECK-NEXT:    [[TMP1:%.*]] = insertelement <2 x i8> undef, i8 [[X1:%.*]], i32 0
; CHECK-NEXT:    [[TMP2:%.*]] = insertelement <2 x i8> [[TMP1]], i8 [[X2:%.*]], i32 1
; CHECK-NEXT:    ret <2 x i8> [[TMP2]]
;
  %A = insertelement <4 x i8> undef, i8 %x1, i32 0
  %B = insertelement <4 x i8> %A, i8 %x2, i32 2
  %C = shufflevector <4 x i8> %B, <4 x i8> undef, <2 x i32> <i32 0, i32 2>
  ret <2 x i8> %C
}

define void @test14(i16 %conv10) {
; CHECK-LABEL: @test14(
; CHECK-NEXT:    store <4 x i16> <i16 undef, i16 undef, i16 undef, i16 23>, <4 x i16>* undef, align 8
; CHECK-NEXT:    ret void
;
  %t = alloca <4 x i16>, align 8
  %vecinit6 = insertelement <4 x i16> undef, i16 23, i32 3
  store <4 x i16> %vecinit6, <4 x i16>* undef
  %t1 = load <4 x i16>, <4 x i16>* undef
  %vecinit11 = insertelement <4 x i16> undef, i16 %conv10, i32 3
  %div = udiv <4 x i16> %t1, %vecinit11
  store <4 x i16> %div, <4 x i16>* %t
  %t4 = load <4 x i16>, <4 x i16>* %t
  %t5 = shufflevector <4 x i16> %t4, <4 x i16> undef, <2 x i32> <i32 2, i32 0>
  %cmp = icmp ule <2 x i16> %t5, undef
  %sext = sext <2 x i1> %cmp to <2 x i16>
  ret void
}

; Check that sequences of insert/extract element are
; collapsed into valid shuffle instruction with correct shuffle indexes.

define <4 x float> @test15a(<4 x float> %LHS, <4 x float> %RHS) {
; CHECK-LABEL: @test15a(
; CHECK-NEXT:    [[T4:%.*]] = shufflevector <4 x float> [[LHS:%.*]], <4 x float> [[RHS:%.*]], <4 x i32> <i32 4, i32 0, i32 6, i32 6>
; CHECK-NEXT:    ret <4 x float> [[T4]]
;
  %t1 = extractelement <4 x float> %LHS, i32 0
  %t2 = insertelement <4 x float> %RHS, float %t1, i32 1
  %t3 = extractelement <4 x float> %RHS, i32 2
  %t4 = insertelement <4 x float> %t2, float %t3, i32 3
  ret <4 x float> %t4
}

define <4 x float> @test15b(<4 x float> %LHS, <4 x float> %RHS) {
; CHECK-LABEL: @test15b(
; CHECK-NEXT:    [[T5:%.*]] = shufflevector <4 x float> [[LHS:%.*]], <4 x float> [[RHS:%.*]], <4 x i32> <i32 4, i32 3, i32 6, i32 6>
; CHECK-NEXT:    ret <4 x float> [[T5]]
;
  %t0 = extractelement <4 x float> %LHS, i32 3
  %t1 = insertelement <4 x float> %RHS, float %t0, i32 0
  %t2 = extractelement <4 x float> %t1, i32 0
  %t3 = insertelement <4 x float> %RHS, float %t2, i32 1
  %t4 = extractelement <4 x float> %RHS, i32 2
  %t5 = insertelement <4 x float> %t3, float %t4, i32 3
  ret <4 x float> %t5
}

define <1 x i32> @test16a(i32 %ele) {
; CHECK-LABEL: @test16a(
; CHECK-NEXT:    ret <1 x i32> <i32 2>
;
  %t0 = insertelement <2 x i32> <i32 1, i32 undef>, i32 %ele, i32 1
  %t1 = shl <2 x i32> %t0, <i32 1, i32 1>
  %t2 = shufflevector <2 x i32> %t1, <2 x i32> undef, <1 x i32> <i32 0>
  ret <1 x i32> %t2
}

define <4 x i8> @test16b(i8 %ele) {
; CHECK-LABEL: @test16b(
; CHECK-NEXT:    ret <4 x i8> <i8 2, i8 2, i8 2, i8 2>
;
  %t0 = insertelement <8 x i8> <i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 undef, i8 1>, i8 %ele, i32 6
  %t1 = shl <8 x i8> %t0, <i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1, i8 1>
  %t2 = shufflevector <8 x i8> %t1, <8 x i8> undef, <4 x i32> <i32 1, i32 2, i32 3, i32 4>
  ret <4 x i8> %t2
}

; If composition of two shuffles is identity, shuffles can be removed.
define <4 x i32> @shuffle_17ident(<4 x i32> %v) {
; CHECK-LABEL: @shuffle_17ident(
; CHECK-NEXT:    ret <4 x i32> [[V:%.*]]
;
  %shuffle = shufflevector <4 x i32> %v, <4 x i32> zeroinitializer, <4 x i32> <i32 1, i32 2, i32 3, i32 0>
  %shuffle2 = shufflevector <4 x i32> %shuffle, <4 x i32> zeroinitializer, <4 x i32> <i32 3, i32 0, i32 1, i32 2>
  ret <4 x i32> %shuffle2
}

; swizzle can be put after operation
define <4 x i32> @shuffle_17and(<4 x i32> %v1, <4 x i32> %v2) {
; CHECK-LABEL: @shuffle_17and(
; CHECK-NEXT:    [[TMP1:%.*]] = and <4 x i32> [[V1:%.*]], [[V2:%.*]]
; CHECK-NEXT:    [[TMP2:%.*]] = shufflevector <4 x i32> [[TMP1]], <4 x i32> undef, <4 x i32> <i32 1, i32 2, i32 3, i32 0>
; CHECK-NEXT:    ret <4 x i32> [[TMP2]]
;
  %t1 = shufflevector <4 x i32> %v1, <4 x i32> zeroinitializer, <4 x i32> <i32 1, i32 2, i32 3, i32 0>
  %t2 = shufflevector <4 x i32> %v2, <4 x i32> zeroinitializer, <4 x i32> <i32 1, i32 2, i32 3, i32 0>
  %r = and <4 x i32> %t1, %t2
  ret <4 x i32> %r
}

declare void @use(<2 x float>)

; One extra use is ok to transform.

define <2 x float> @shuffle_fadd_multiuse(<2 x float> %v1, <2 x float> %v2) {
; CHECK-LABEL: @shuffle_fadd_multiuse(
; CHECK-NEXT:    [[T1:%.*]] = shufflevector <2 x float> [[V1:%.*]], <2 x float> undef, <2 x i32> <i32 1, i32 0>
; CHECK-NEXT:    [[TMP1:%.*]] = fadd <2 x float> [[V1]], [[V2:%.*]]
; CHECK-NEXT:    [[TMP2:%.*]] = shufflevector <2 x float> [[TMP1]], <2 x float> undef, <2 x i32> <i32 1, i32 0>
; CHECK-NEXT:    call void @use(<2 x float> [[T1]])
; CHECK-NEXT:    ret <2 x float> [[TMP2]]
;
  %t1 = shufflevector <2 x float> %v1, <2 x float> undef, <2 x i32> <i32 1, i32 0>
  %t2 = shufflevector <2 x float> %v2, <2 x float> undef, <2 x i32> <i32 1, i32 0>
  %r = fadd <2 x float> %t1, %t2
  call void @use(<2 x float> %t1)
  ret <2 x float> %r
}

define <2 x float> @shuffle_fdiv_multiuse(<2 x float> %v1, <2 x float> %v2) {
; CHECK-LABEL: @shuffle_fdiv_multiuse(
; CHECK-NEXT:    [[T2:%.*]] = shufflevector <2 x float> [[V2:%.*]], <2 x float> undef, <2 x i32> <i32 1, i32 0>
; CHECK-NEXT:    [[TMP1:%.*]] = fdiv <2 x float> [[V1:%.*]], [[V2]]
; CHECK-NEXT:    [[TMP2:%.*]] = shufflevector <2 x float> [[TMP1]], <2 x float> undef, <2 x i32> <i32 1, i32 0>
; CHECK-NEXT:    call void @use(<2 x float> [[T2]])
; CHECK-NEXT:    ret <2 x float> [[TMP2]]
;
  %t1 = shufflevector <2 x float> %v1, <2 x float> undef, <2 x i32> <i32 1, i32 0>
  %t2 = shufflevector <2 x float> %v2, <2 x float> undef, <2 x i32> <i32 1, i32 0>
  %r = fdiv <2 x float> %t1, %t2
  call void @use(<2 x float> %t2)
  ret <2 x float> %r
}

; But 2 extra uses would require an extra instruction.

define <2 x float> @shuffle_fsub_multiuse(<2 x float> %v1, <2 x float> %v2) {
; CHECK-LABEL: @shuffle_fsub_multiuse(
; CHECK-NEXT:    [[T1:%.*]] = shufflevector <2 x float> [[V1:%.*]], <2 x float> undef, <2 x i32> <i32 1, i32 0>
; CHECK-NEXT:    [[T2:%.*]] = shufflevector <2 x float> [[V2:%.*]], <2 x float> undef, <2 x i32> <i32 1, i32 0>
; CHECK-NEXT:    [[R:%.*]] = fsub <2 x float> [[T1]], [[T2]]
; CHECK-NEXT:    call void @use(<2 x float> [[T1]])
; CHECK-NEXT:    call void @use(<2 x float> [[T2]])
; CHECK-NEXT:    ret <2 x float> [[R]]
;
  %t1 = shufflevector <2 x float> %v1, <2 x float> undef, <2 x i32> <i32 1, i32 0>
  %t2 = shufflevector <2 x float> %v2, <2 x float> undef, <2 x i32> <i32 1, i32 0>
  %r = fsub <2 x float> %t1, %t2
  call void @use(<2 x float> %t1)
  call void @use(<2 x float> %t2)
  ret <2 x float> %r
}

define <4 x i32> @shuffle_17add(<4 x i32> %v1, <4 x i32> %v2) {
; CHECK-LABEL: @shuffle_17add(
; CHECK-NEXT:    [[TMP1:%.*]] = add <4 x i32> [[V1:%.*]], [[V2:%.*]]
; CHECK-NEXT:    [[TMP2:%.*]] = shufflevector <4 x i32> [[TMP1]], <4 x i32> undef, <4 x i32> <i32 1, i32 2, i32 3, i32 0>
; CHECK-NEXT:    ret <4 x i32> [[TMP2]]
;
  %t1 = shufflevector <4 x i32> %v1, <4 x i32> zeroinitializer, <4 x i32> <i32 1, i32 2, i32 3, i32 0>
  %t2 = shufflevector <4 x i32> %v2, <4 x i32> zeroinitializer, <4 x i32> <i32 1, i32 2, i32 3, i32 0>
  %r = add <4 x i32> %t1, %t2
  ret <4 x i32> %r
}

define <4 x i32> @shuffle_17addnsw(<4 x i32> %v1, <4 x i32> %v2) {
; CHECK-LABEL: @shuffle_17addnsw(
; CHECK-NEXT:    [[TMP1:%.*]] = add nsw <4 x i32> [[V1:%.*]], [[V2:%.*]]
; CHECK-NEXT:    [[TMP2:%.*]] = shufflevector <4 x i32> [[TMP1]], <4 x i32> undef, <4 x i32> <i32 1, i32 2, i32 3, i32 0>
; CHECK-NEXT:    ret <4 x i32> [[TMP2]]
;
  %t1 = shufflevector <4 x i32> %v1, <4 x i32> zeroinitializer, <4 x i32> <i32 1, i32 2, i32 3, i32 0>
  %t2 = shufflevector <4 x i32> %v2, <4 x i32> zeroinitializer, <4 x i32> <i32 1, i32 2, i32 3, i32 0>
  %r = add nsw <4 x i32> %t1, %t2
  ret <4 x i32> %r
}

define <4 x i32> @shuffle_17addnuw(<4 x i32> %v1, <4 x i32> %v2) {
; CHECK-LABEL: @shuffle_17addnuw(
; CHECK-NEXT:    [[TMP1:%.*]] = add nuw <4 x i32> [[V1:%.*]], [[V2:%.*]]
; CHECK-NEXT:    [[TMP2:%.*]] = shufflevector <4 x i32> [[TMP1]], <4 x i32> undef, <4 x i32> <i32 1, i32 2, i32 3, i32 0>
; CHECK-NEXT:    ret <4 x i32> [[TMP2]]
;
  %t1 = shufflevector <4 x i32> %v1, <4 x i32> zeroinitializer, <4 x i32> <i32 1, i32 2, i32 3, i32 0>
  %t2 = shufflevector <4 x i32> %v2, <4 x i32> zeroinitializer, <4 x i32> <i32 1, i32 2, i32 3, i32 0>
  %r = add nuw <4 x i32> %t1, %t2
  ret <4 x i32> %r
}

define <4 x float> @shuffle_17fsub_fast(<4 x float> %v1, <4 x float> %v2) {
; CHECK-LABEL: @shuffle_17fsub_fast(
; CHECK-NEXT:    [[TMP1:%.*]] = fsub fast <4 x float> [[V1:%.*]], [[V2:%.*]]
; CHECK-NEXT:    [[TMP2:%.*]] = shufflevector <4 x float> [[TMP1]], <4 x float> undef, <4 x i32> <i32 1, i32 2, i32 3, i32 0>
; CHECK-NEXT:    ret <4 x float> [[TMP2]]
;
  %t1 = shufflevector <4 x float> %v1, <4 x float> zeroinitializer, <4 x i32> <i32 1, i32 2, i32 3, i32 0>
  %t2 = shufflevector <4 x float> %v2, <4 x float> zeroinitializer, <4 x i32> <i32 1, i32 2, i32 3, i32 0>
  %r = fsub fast <4 x float> %t1, %t2
  ret <4 x float> %r
}

define <4 x i32> @add_const(<4 x i32> %v) {
; CHECK-LABEL: @add_const(
; CHECK-NEXT:    [[TMP1:%.*]] = add <4 x i32> [[V:%.*]], <i32 44, i32 41, i32 42, i32 43>
; CHECK-NEXT:    [[TMP2:%.*]] = shufflevector <4 x i32> [[TMP1]], <4 x i32> undef, <4 x i32> <i32 1, i32 2, i32 3, i32 0>
; CHECK-NEXT:    ret <4 x i32> [[TMP2]]
;
  %t1 = shufflevector <4 x i32> %v, <4 x i32> undef, <4 x i32> <i32 1, i32 2, i32 3, i32 0>
  %r = add <4 x i32> %t1, <i32 41, i32 42, i32 43, i32 44>
  ret <4 x i32> %r
}

define <4 x i32> @sub_const(<4 x i32> %v) {
; CHECK-LABEL: @sub_const(
; CHECK-NEXT:    [[TMP1:%.*]] = sub <4 x i32> <i32 44, i32 43, i32 42, i32 41>, [[V:%.*]]
; CHECK-NEXT:    [[TMP2:%.*]] = shufflevector <4 x i32> [[TMP1]], <4 x i32> undef, <4 x i32> <i32 3, i32 2, i32 1, i32 0>
; CHECK-NEXT:    ret <4 x i32> [[TMP2]]
;
  %t1 = shufflevector <4 x i32> %v, <4 x i32> undef, <4 x i32> <i32 3, i32 2, i32 1, i32 0>
  %r = sub <4 x i32> <i32 41, i32 42, i32 43, i32 44>, %t1
  ret <4 x i32> %r
}

; Math before shuffle requires an extra shuffle.

define <2 x float> @fadd_const_multiuse(<2 x float> %v) {
; CHECK-LABEL: @fadd_const_multiuse(
; CHECK-NEXT:    [[T1:%.*]] = shufflevector <2 x float> [[V:%.*]], <2 x float> undef, <2 x i32> <i32 1, i32 0>
; CHECK-NEXT:    [[R:%.*]] = fadd <2 x float> [[T1]], <float 4.100000e+01, float 4.200000e+01>
; CHECK-NEXT:    call void @use(<2 x float> [[T1]])
; CHECK-NEXT:    ret <2 x float> [[R]]
;
  %t1 = shufflevector <2 x float> %v, <2 x float> undef, <2 x i32> <i32 1, i32 0>
  %r = fadd <2 x float> %t1, <float 41.0, float 42.0>
  call void @use(<2 x float> %t1)
  ret <2 x float> %r
}

; Math before splat allows replacing constant elements with undef lanes.

define <4 x i32> @mul_const_splat(<4 x i32> %v) {
; CHECK-LABEL: @mul_const_splat(
; CHECK-NEXT:    [[T1:%.*]] = shufflevector <4 x i32> [[V:%.*]], <4 x i32> undef, <4 x i32> <i32 1, i32 1, i32 1, i32 1>
; CHECK-NEXT:    [[R:%.*]] = mul <4 x i32> [[T1]], <i32 42, i32 42, i32 42, i32 42>
; CHECK-NEXT:    ret <4 x i32> [[R]]
;
  %t1 = shufflevector <4 x i32> %v, <4 x i32> undef, <4 x i32> <i32 1, i32 1, i32 1, i32 1>
  %r = mul <4 x i32> <i32 42, i32 42, i32 42, i32 42>, %t1
  ret <4 x i32> %r
}

; Take 2 elements of a vector and shift each of those by a different amount

define <4 x i32> @lshr_const_half_splat(<4 x i32> %v) {
; CHECK-LABEL: @lshr_const_half_splat(
; CHECK-NEXT:    [[T1:%.*]] = shufflevector <4 x i32> [[V:%.*]], <4 x i32> undef, <4 x i32> <i32 1, i32 1, i32 2, i32 2>
; CHECK-NEXT:    [[R:%.*]] = lshr <4 x i32> <i32 8, i32 8, i32 9, i32 9>, [[T1]]
; CHECK-NEXT:    ret <4 x i32> [[R]]
;
  %t1 = shufflevector <4 x i32> %v, <4 x i32> undef, <4 x i32> <i32 1, i32 1, i32 2, i32 2>
  %r = lshr <4 x i32> <i32 8, i32 8, i32 9, i32 9>, %t1
  ret <4 x i32> %r
}

define <4 x i32> @shuffle_17add2(<4 x i32> %v) {
; CHECK-LABEL: @shuffle_17add2(
; CHECK-NEXT:    [[TMP1:%.*]] = shl <4 x i32> [[V:%.*]], <i32 1, i32 1, i32 1, i32 1>
; CHECK-NEXT:    ret <4 x i32> [[TMP1]]
;
  %t1 = shufflevector <4 x i32> %v, <4 x i32> zeroinitializer, <4 x i32> <i32 3, i32 2, i32 1, i32 0>
  %t2 = add <4 x i32> %t1, %t1
  %r = shufflevector <4 x i32> %t2, <4 x i32> zeroinitializer, <4 x i32> <i32 3, i32 2, i32 1, i32 0>
  ret <4 x i32> %r
}

define <4 x i32> @shuffle_17mulsplat(<4 x i32> %v) {
; CHECK-LABEL: @shuffle_17mulsplat(
; CHECK-NEXT:    [[TMP1:%.*]] = mul <4 x i32> [[V:%.*]], [[V]]
; CHECK-NEXT:    [[TMP2:%.*]] = shufflevector <4 x i32> [[TMP1]], <4 x i32> undef, <4 x i32> zeroinitializer
; CHECK-NEXT:    ret <4 x i32> [[TMP2]]
;
  %s1 = shufflevector <4 x i32> %v, <4 x i32> zeroinitializer, <4 x i32> zeroinitializer
  %m1 = mul <4 x i32> %s1, %s1
  %s2 = shufflevector <4 x i32> %m1, <4 x i32> zeroinitializer, <4 x i32> <i32 1, i32 1, i32 1, i32 1>
  ret <4 x i32> %s2
}

; Do not reorder shuffle and binop if LHS of shuffles are of different size
define <2 x i32> @pr19717(<4 x i32> %in0, <2 x i32> %in1) {
; CHECK-LABEL: @pr19717(
; CHECK-NEXT:    [[SHUFFLE:%.*]] = shufflevector <4 x i32> [[IN0:%.*]], <4 x i32> undef, <2 x i32> zeroinitializer
; CHECK-NEXT:    [[SHUFFLE4:%.*]] = shufflevector <2 x i32> [[IN1:%.*]], <2 x i32> undef, <2 x i32> zeroinitializer
; CHECK-NEXT:    [[MUL:%.*]] = mul <2 x i32> [[SHUFFLE]], [[SHUFFLE4]]
; CHECK-NEXT:    ret <2 x i32> [[MUL]]
;
  %shuffle = shufflevector <4 x i32> %in0, <4 x i32> %in0, <2 x i32> zeroinitializer
  %shuffle4 = shufflevector <2 x i32> %in1, <2 x i32> %in1, <2 x i32> zeroinitializer
  %mul = mul <2 x i32> %shuffle, %shuffle4
  ret <2 x i32> %mul
}

define <4 x i16> @pr19717a(<8 x i16> %in0, <8 x i16> %in1) {
; CHECK-LABEL: @pr19717a(
; CHECK-NEXT:    [[TMP1:%.*]] = mul <8 x i16> [[IN0:%.*]], [[IN1:%.*]]
; CHECK-NEXT:    [[TMP2:%.*]] = shufflevector <8 x i16> [[TMP1]], <8 x i16> undef, <4 x i32> <i32 5, i32 5, i32 5, i32 5>
; CHECK-NEXT:    ret <4 x i16> [[TMP2]]
;
  %shuffle = shufflevector <8 x i16> %in0, <8 x i16> %in0, <4 x i32> <i32 5, i32 5, i32 5, i32 5>
  %shuffle1 = shufflevector <8 x i16> %in1, <8 x i16> %in1, <4 x i32> <i32 5, i32 5, i32 5, i32 5>
  %mul = mul <4 x i16> %shuffle, %shuffle1
  ret <4 x i16> %mul
}

define <8 x i8> @pr19730(<16 x i8> %in0) {
; CHECK-LABEL: @pr19730(
; CHECK-NEXT:    [[SHUFFLE:%.*]] = shufflevector <16 x i8> [[IN0:%.*]], <16 x i8> undef, <8 x i32> <i32 7, i32 6, i32 5, i32 4, i32 3, i32 2, i32 1, i32 0>
; CHECK-NEXT:    [[SHUFFLE1:%.*]] = shufflevector <8 x i8> [[SHUFFLE]], <8 x i8> undef, <8 x i32> <i32 7, i32 6, i32 5, i32 4, i32 3, i32 2, i32 1, i32 0>
; CHECK-NEXT:    ret <8 x i8> [[SHUFFLE1]]
;
  %shuffle = shufflevector <16 x i8> %in0, <16 x i8> undef, <8 x i32> <i32 7, i32 6, i32 5, i32 4, i32 3, i32 2, i32 1, i32 0>
  %shuffle1 = shufflevector <8 x i8> %shuffle, <8 x i8> undef, <8 x i32> <i32 7, i32 6, i32 5, i32 4, i32 3, i32 2, i32 1, i32 0>
  ret <8 x i8> %shuffle1
}

define i32 @pr19737(<4 x i32> %in0) {
; CHECK-LABEL: @pr19737(
; CHECK-NEXT:    [[RV_RHS:%.*]] = extractelement <4 x i32> [[IN0:%.*]], i32 0
; CHECK-NEXT:    ret i32 [[RV_RHS]]
;
  %shuffle.i = shufflevector <4 x i32> zeroinitializer, <4 x i32> %in0, <4 x i32> <i32 0, i32 4, i32 2, i32 6>
  %neg.i = xor <4 x i32> %shuffle.i, <i32 -1, i32 -1, i32 -1, i32 -1>
  %and.i = and <4 x i32> %in0, %neg.i
  %rv = extractelement <4 x i32> %and.i, i32 0
  ret i32 %rv
}

; In PR20059 ( http://llvm.org/pr20059 ), shufflevector operations are reordered/removed
; for an srem operation. This is not a valid optimization because it may cause a trap
; on div-by-zero.

define <4 x i32> @pr20059(<4 x i32> %p1, <4 x i32> %p2) {
; CHECK-LABEL: @pr20059(
; CHECK-NEXT:    [[SPLAT1:%.*]] = shufflevector <4 x i32> [[P1:%.*]], <4 x i32> undef, <4 x i32> zeroinitializer
; CHECK-NEXT:    [[SPLAT2:%.*]] = shufflevector <4 x i32> [[P2:%.*]], <4 x i32> undef, <4 x i32> zeroinitializer
; CHECK-NEXT:    [[RETVAL:%.*]] = srem <4 x i32> [[SPLAT1]], [[SPLAT2]]
; CHECK-NEXT:    ret <4 x i32> [[RETVAL]]
;
  %splat1 = shufflevector <4 x i32> %p1, <4 x i32> undef, <4 x i32> zeroinitializer
  %splat2 = shufflevector <4 x i32> %p2, <4 x i32> undef, <4 x i32> zeroinitializer
  %retval = srem <4 x i32> %splat1, %splat2
  ret <4 x i32> %retval
}

define <4 x i32> @pr20114(<4 x i32> %__mask) {
; CHECK-LABEL: @pr20114(
; CHECK-NEXT:    [[MASK01_I:%.*]] = shufflevector <4 x i32> [[__MASK:%.*]], <4 x i32> undef, <4 x i32> <i32 0, i32 0, i32 1, i32 1>
; CHECK-NEXT:    [[MASKED_NEW_I_I_I:%.*]] = and <4 x i32> [[MASK01_I]], bitcast (<2 x i64> <i64 ptrtoint (<4 x i32> (<4 x i32>)* @pr20114 to i64), i64 ptrtoint (<4 x i32> (<4 x i32>)* @pr20114 to i64)> to <4 x i32>)
; CHECK-NEXT:    ret <4 x i32> [[MASKED_NEW_I_I_I]]
;
  %mask01.i = shufflevector <4 x i32> %__mask, <4 x i32> undef, <4 x i32> <i32 0, i32 0, i32 1, i32 1>
  %masked_new.i.i.i = and <4 x i32> bitcast (<2 x i64> <i64 ptrtoint (<4 x i32> (<4 x i32>)* @pr20114 to i64), i64 ptrtoint (<4 x i32> (<4 x i32>)* @pr20114 to i64)> to <4 x i32>), %mask01.i
  ret <4 x i32> %masked_new.i.i.i
}

define <2 x i32*> @pr23113(<4 x i32*> %A) {
; CHECK-LABEL: @pr23113(
; CHECK-NEXT:    [[TMP1:%.*]] = shufflevector <4 x i32*> [[A:%.*]], <4 x i32*> undef, <2 x i32> <i32 0, i32 1>
; CHECK-NEXT:    ret <2 x i32*> [[TMP1]]
;
  %1 = shufflevector <4 x i32*> %A, <4 x i32*> undef, <2 x i32> <i32 0, i32 1>
  ret <2 x i32*> %1
}
