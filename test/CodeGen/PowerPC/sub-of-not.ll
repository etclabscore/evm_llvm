; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=ppc32-unknown-unknown | FileCheck %s --check-prefixes=ALL,PPC32
; RUN: llc < %s -mtriple=powerpc64-unknown-unknown | FileCheck %s --check-prefixes=ALL,PPC64,PPC64BE
; RUN: llc < %s -mtriple=powerpc64le-unknown-unknown | FileCheck %s --check-prefixes=ALL,PPC64,PPC64LE

; These two forms are equivalent:
;   sub %y, (xor %x, -1)
;   add (add %x, 1), %y
; Some targets may prefer one to the other.

define i8 @scalar_i8(i8 %x, i8 %y) nounwind {
; ALL-LABEL: scalar_i8:
; ALL:       # %bb.0:
; ALL-NEXT:    nor 3, 3, 3
; ALL-NEXT:    subf 3, 3, 4
; ALL-NEXT:    blr
  %t0 = xor i8 %x, -1
  %t1 = sub i8 %y, %t0
  ret i8 %t1
}

define i16 @scalar_i16(i16 %x, i16 %y) nounwind {
; ALL-LABEL: scalar_i16:
; ALL:       # %bb.0:
; ALL-NEXT:    nor 3, 3, 3
; ALL-NEXT:    subf 3, 3, 4
; ALL-NEXT:    blr
  %t0 = xor i16 %x, -1
  %t1 = sub i16 %y, %t0
  ret i16 %t1
}

define i32 @scalar_i32(i32 %x, i32 %y) nounwind {
; ALL-LABEL: scalar_i32:
; ALL:       # %bb.0:
; ALL-NEXT:    nor 3, 3, 3
; ALL-NEXT:    subf 3, 3, 4
; ALL-NEXT:    blr
  %t0 = xor i32 %x, -1
  %t1 = sub i32 %y, %t0
  ret i32 %t1
}

define i64 @scalar_i64(i64 %x, i64 %y) nounwind {
; PPC32-LABEL: scalar_i64:
; PPC32:       # %bb.0:
; PPC32-NEXT:    nor 4, 4, 4
; PPC32-NEXT:    nor 3, 3, 3
; PPC32-NEXT:    subfc 4, 4, 6
; PPC32-NEXT:    subfe 3, 3, 5
; PPC32-NEXT:    blr
;
; PPC64-LABEL: scalar_i64:
; PPC64:       # %bb.0:
; PPC64-NEXT:    not 3, 3
; PPC64-NEXT:    sub 3, 4, 3
; PPC64-NEXT:    blr
  %t0 = xor i64 %x, -1
  %t1 = sub i64 %y, %t0
  ret i64 %t1
}

define <16 x i8> @vector_i128_i8(<16 x i8> %x, <16 x i8> %y) nounwind {
; PPC32-LABEL: vector_i128_i8:
; PPC32:       # %bb.0:
; PPC32-NEXT:    stwu 1, -48(1)
; PPC32-NEXT:    lbz 4, 99(1)
; PPC32-NEXT:    stw 23, 12(1) # 4-byte Folded Spill
; PPC32-NEXT:    nor 5, 5, 5
; PPC32-NEXT:    lbz 23, 103(1)
; PPC32-NEXT:    subf 4, 5, 4
; PPC32-NEXT:    lbz 5, 107(1)
; PPC32-NEXT:    nor 6, 6, 6
; PPC32-NEXT:    subf 6, 6, 23
; PPC32-NEXT:    lbz 23, 111(1)
; PPC32-NEXT:    nor 7, 7, 7
; PPC32-NEXT:    subf 5, 7, 5
; PPC32-NEXT:    lbz 7, 115(1)
; PPC32-NEXT:    nor 8, 8, 8
; PPC32-NEXT:    stw 24, 16(1) # 4-byte Folded Spill
; PPC32-NEXT:    subf 8, 8, 23
; PPC32-NEXT:    lbz 24, 119(1)
; PPC32-NEXT:    lbz 23, 59(1)
; PPC32-NEXT:    nor 9, 9, 9
; PPC32-NEXT:    stw 25, 20(1) # 4-byte Folded Spill
; PPC32-NEXT:    subf 7, 9, 7
; PPC32-NEXT:    lbz 25, 123(1)
; PPC32-NEXT:    lbz 9, 63(1)
; PPC32-NEXT:    stw 26, 24(1) # 4-byte Folded Spill
; PPC32-NEXT:    nor 10, 10, 10
; PPC32-NEXT:    lbz 26, 127(1)
; PPC32-NEXT:    subf 10, 10, 24
; PPC32-NEXT:    lbz 24, 67(1)
; PPC32-NEXT:    nor 23, 23, 23
; PPC32-NEXT:    stw 27, 28(1) # 4-byte Folded Spill
; PPC32-NEXT:    subf 25, 23, 25
; PPC32-NEXT:    lbz 27, 131(1)
; PPC32-NEXT:    lbz 23, 71(1)
; PPC32-NEXT:    nor 9, 9, 9
; PPC32-NEXT:    stw 28, 32(1) # 4-byte Folded Spill
; PPC32-NEXT:    subf 9, 9, 26
; PPC32-NEXT:    lbz 28, 135(1)
; PPC32-NEXT:    lbz 26, 75(1)
; PPC32-NEXT:    stw 29, 36(1) # 4-byte Folded Spill
; PPC32-NEXT:    nor 24, 24, 24
; PPC32-NEXT:    lbz 29, 139(1)
; PPC32-NEXT:    subf 27, 24, 27
; PPC32-NEXT:    lbz 24, 79(1)
; PPC32-NEXT:    nor 23, 23, 23
; PPC32-NEXT:    stw 30, 40(1) # 4-byte Folded Spill
; PPC32-NEXT:    subf 28, 23, 28
; PPC32-NEXT:    lbz 30, 143(1)
; PPC32-NEXT:    lbz 23, 83(1)
; PPC32-NEXT:    nor 26, 26, 26
; PPC32-NEXT:    lbz 0, 147(1)
; PPC32-NEXT:    subf 29, 26, 29
; PPC32-NEXT:    lbz 26, 87(1)
; PPC32-NEXT:    lbz 12, 151(1)
; PPC32-NEXT:    nor 24, 24, 24
; PPC32-NEXT:    subf 30, 24, 30
; PPC32-NEXT:    lbz 24, 91(1)
; PPC32-NEXT:    nor 23, 23, 23
; PPC32-NEXT:    lbz 11, 155(1)
; PPC32-NEXT:    subf 0, 23, 0
; PPC32-NEXT:    lbz 23, 95(1)
; PPC32-NEXT:    nor 26, 26, 26
; PPC32-NEXT:    subf 12, 26, 12
; PPC32-NEXT:    lbz 26, 159(1)
; PPC32-NEXT:    nor 24, 24, 24
; PPC32-NEXT:    subf 11, 24, 11
; PPC32-NEXT:    nor 24, 23, 23
; PPC32-NEXT:    subf 26, 24, 26
; PPC32-NEXT:    stb 10, 5(3)
; PPC32-NEXT:    stb 7, 4(3)
; PPC32-NEXT:    stb 8, 3(3)
; PPC32-NEXT:    stb 5, 2(3)
; PPC32-NEXT:    stb 6, 1(3)
; PPC32-NEXT:    stb 26, 15(3)
; PPC32-NEXT:    stb 11, 14(3)
; PPC32-NEXT:    stb 12, 13(3)
; PPC32-NEXT:    stb 0, 12(3)
; PPC32-NEXT:    stb 30, 11(3)
; PPC32-NEXT:    stb 29, 10(3)
; PPC32-NEXT:    stb 28, 9(3)
; PPC32-NEXT:    stb 27, 8(3)
; PPC32-NEXT:    stb 9, 7(3)
; PPC32-NEXT:    stb 25, 6(3)
; PPC32-NEXT:    stb 4, 0(3)
; PPC32-NEXT:    lwz 30, 40(1) # 4-byte Folded Reload
; PPC32-NEXT:    lwz 29, 36(1) # 4-byte Folded Reload
; PPC32-NEXT:    lwz 28, 32(1) # 4-byte Folded Reload
; PPC32-NEXT:    lwz 27, 28(1) # 4-byte Folded Reload
; PPC32-NEXT:    lwz 26, 24(1) # 4-byte Folded Reload
; PPC32-NEXT:    lwz 25, 20(1) # 4-byte Folded Reload
; PPC32-NEXT:    lwz 24, 16(1) # 4-byte Folded Reload
; PPC32-NEXT:    lwz 23, 12(1) # 4-byte Folded Reload
; PPC32-NEXT:    addi 1, 1, 48
; PPC32-NEXT:    blr
;
; PPC64BE-LABEL: vector_i128_i8:
; PPC64BE:       # %bb.0:
; PPC64BE-NEXT:    lbz 11, 191(1)
; PPC64BE-NEXT:    nor 4, 4, 4
; PPC64BE-NEXT:    std 23, -72(1) # 8-byte Folded Spill
; PPC64BE-NEXT:    lbz 23, 199(1)
; PPC64BE-NEXT:    nor 5, 5, 5
; PPC64BE-NEXT:    subf 4, 4, 11
; PPC64BE-NEXT:    lbz 11, 207(1)
; PPC64BE-NEXT:    nor 6, 6, 6
; PPC64BE-NEXT:    subf 5, 5, 23
; PPC64BE-NEXT:    lbz 23, 215(1)
; PPC64BE-NEXT:    subf 6, 6, 11
; PPC64BE-NEXT:    lbz 11, 223(1)
; PPC64BE-NEXT:    nor 7, 7, 7
; PPC64BE-NEXT:    nor 8, 8, 8
; PPC64BE-NEXT:    std 24, -64(1) # 8-byte Folded Spill
; PPC64BE-NEXT:    lbz 24, 239(1)
; PPC64BE-NEXT:    subf 7, 7, 23
; PPC64BE-NEXT:    lbz 23, 231(1)
; PPC64BE-NEXT:    subf 8, 8, 11
; PPC64BE-NEXT:    lbz 11, 119(1)
; PPC64BE-NEXT:    std 25, -56(1) # 8-byte Folded Spill
; PPC64BE-NEXT:    nor 9, 9, 9
; PPC64BE-NEXT:    lbz 25, 247(1)
; PPC64BE-NEXT:    nor 10, 10, 10
; PPC64BE-NEXT:    subf 9, 9, 23
; PPC64BE-NEXT:    lbz 23, 127(1)
; PPC64BE-NEXT:    subf 10, 10, 24
; PPC64BE-NEXT:    lbz 24, 135(1)
; PPC64BE-NEXT:    nor 11, 11, 11
; PPC64BE-NEXT:    std 26, -48(1) # 8-byte Folded Spill
; PPC64BE-NEXT:    std 27, -40(1) # 8-byte Folded Spill
; PPC64BE-NEXT:    lbz 27, 263(1)
; PPC64BE-NEXT:    lbz 26, 255(1)
; PPC64BE-NEXT:    subf 11, 11, 25
; PPC64BE-NEXT:    lbz 25, 143(1)
; PPC64BE-NEXT:    std 28, -32(1) # 8-byte Folded Spill
; PPC64BE-NEXT:    nor 23, 23, 23
; PPC64BE-NEXT:    lbz 28, 271(1)
; PPC64BE-NEXT:    nor 24, 24, 24
; PPC64BE-NEXT:    subf 26, 23, 26
; PPC64BE-NEXT:    lbz 23, 151(1)
; PPC64BE-NEXT:    subf 27, 24, 27
; PPC64BE-NEXT:    lbz 24, 159(1)
; PPC64BE-NEXT:    nor 25, 25, 25
; PPC64BE-NEXT:    std 29, -24(1) # 8-byte Folded Spill
; PPC64BE-NEXT:    std 30, -16(1) # 8-byte Folded Spill
; PPC64BE-NEXT:    lbz 30, 287(1)
; PPC64BE-NEXT:    lbz 29, 279(1)
; PPC64BE-NEXT:    subf 28, 25, 28
; PPC64BE-NEXT:    lbz 25, 167(1)
; PPC64BE-NEXT:    lbz 0, 295(1)
; PPC64BE-NEXT:    nor 23, 23, 23
; PPC64BE-NEXT:    nor 24, 24, 24
; PPC64BE-NEXT:    subf 29, 23, 29
; PPC64BE-NEXT:    lbz 23, 175(1)
; PPC64BE-NEXT:    subf 30, 24, 30
; PPC64BE-NEXT:    lbz 24, 183(1)
; PPC64BE-NEXT:    nor 25, 25, 25
; PPC64BE-NEXT:    lbz 12, 303(1)
; PPC64BE-NEXT:    subf 0, 25, 0
; PPC64BE-NEXT:    lbz 25, 311(1)
; PPC64BE-NEXT:    nor 23, 23, 23
; PPC64BE-NEXT:    nor 24, 24, 24
; PPC64BE-NEXT:    subf 12, 23, 12
; PPC64BE-NEXT:    subf 25, 24, 25
; PPC64BE-NEXT:    stb 10, 6(3)
; PPC64BE-NEXT:    stb 9, 5(3)
; PPC64BE-NEXT:    stb 8, 4(3)
; PPC64BE-NEXT:    stb 7, 3(3)
; PPC64BE-NEXT:    stb 6, 2(3)
; PPC64BE-NEXT:    stb 5, 1(3)
; PPC64BE-NEXT:    stb 25, 15(3)
; PPC64BE-NEXT:    stb 12, 14(3)
; PPC64BE-NEXT:    stb 0, 13(3)
; PPC64BE-NEXT:    stb 30, 12(3)
; PPC64BE-NEXT:    stb 29, 11(3)
; PPC64BE-NEXT:    stb 28, 10(3)
; PPC64BE-NEXT:    stb 27, 9(3)
; PPC64BE-NEXT:    stb 26, 8(3)
; PPC64BE-NEXT:    stb 11, 7(3)
; PPC64BE-NEXT:    stb 4, 0(3)
; PPC64BE-NEXT:    ld 30, -16(1) # 8-byte Folded Reload
; PPC64BE-NEXT:    ld 29, -24(1) # 8-byte Folded Reload
; PPC64BE-NEXT:    ld 28, -32(1) # 8-byte Folded Reload
; PPC64BE-NEXT:    ld 27, -40(1) # 8-byte Folded Reload
; PPC64BE-NEXT:    ld 26, -48(1) # 8-byte Folded Reload
; PPC64BE-NEXT:    ld 25, -56(1) # 8-byte Folded Reload
; PPC64BE-NEXT:    ld 24, -64(1) # 8-byte Folded Reload
; PPC64BE-NEXT:    ld 23, -72(1) # 8-byte Folded Reload
; PPC64BE-NEXT:    blr
;
; PPC64LE-LABEL: vector_i128_i8:
; PPC64LE:       # %bb.0:
; PPC64LE-NEXT:    xxlnor 34, 34, 34
; PPC64LE-NEXT:    vsububm 2, 3, 2
; PPC64LE-NEXT:    blr
  %t0 = xor <16 x i8> %x, <i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1, i8 -1>
  %t1 = sub <16 x i8> %y, %t0
  ret <16 x i8> %t1
}

define <8 x i16> @vector_i128_i16(<8 x i16> %x, <8 x i16> %y) nounwind {
; PPC32-LABEL: vector_i128_i16:
; PPC32:       # %bb.0:
; PPC32-NEXT:    stwu 1, -32(1)
; PPC32-NEXT:    stw 26, 8(1) # 4-byte Folded Spill
; PPC32-NEXT:    stw 27, 12(1) # 4-byte Folded Spill
; PPC32-NEXT:    stw 28, 16(1) # 4-byte Folded Spill
; PPC32-NEXT:    stw 29, 20(1) # 4-byte Folded Spill
; PPC32-NEXT:    stw 30, 24(1) # 4-byte Folded Spill
; PPC32-NEXT:    lhz 11, 70(1)
; PPC32-NEXT:    lhz 12, 66(1)
; PPC32-NEXT:    lhz 0, 62(1)
; PPC32-NEXT:    nor 10, 10, 10
; PPC32-NEXT:    lhz 30, 58(1)
; PPC32-NEXT:    lhz 29, 54(1)
; PPC32-NEXT:    lhz 28, 50(1)
; PPC32-NEXT:    lhz 27, 46(1)
; PPC32-NEXT:    lhz 26, 42(1)
; PPC32-NEXT:    nor 9, 9, 9
; PPC32-NEXT:    nor 8, 8, 8
; PPC32-NEXT:    nor 7, 7, 7
; PPC32-NEXT:    nor 6, 6, 6
; PPC32-NEXT:    nor 5, 5, 5
; PPC32-NEXT:    nor 4, 4, 4
; PPC32-NEXT:    nor 3, 3, 3
; PPC32-NEXT:    subf 3, 3, 26
; PPC32-NEXT:    subf 4, 4, 27
; PPC32-NEXT:    subf 5, 5, 28
; PPC32-NEXT:    subf 6, 6, 29
; PPC32-NEXT:    subf 7, 7, 30
; PPC32-NEXT:    subf 8, 8, 0
; PPC32-NEXT:    subf 9, 9, 12
; PPC32-NEXT:    subf 10, 10, 11
; PPC32-NEXT:    lwz 30, 24(1) # 4-byte Folded Reload
; PPC32-NEXT:    lwz 29, 20(1) # 4-byte Folded Reload
; PPC32-NEXT:    lwz 28, 16(1) # 4-byte Folded Reload
; PPC32-NEXT:    lwz 27, 12(1) # 4-byte Folded Reload
; PPC32-NEXT:    lwz 26, 8(1) # 4-byte Folded Reload
; PPC32-NEXT:    addi 1, 1, 32
; PPC32-NEXT:    blr
;
; PPC64BE-LABEL: vector_i128_i16:
; PPC64BE:       # %bb.0:
; PPC64BE-NEXT:    std 25, -56(1) # 8-byte Folded Spill
; PPC64BE-NEXT:    lhz 25, 118(1)
; PPC64BE-NEXT:    std 26, -48(1) # 8-byte Folded Spill
; PPC64BE-NEXT:    std 27, -40(1) # 8-byte Folded Spill
; PPC64BE-NEXT:    std 28, -32(1) # 8-byte Folded Spill
; PPC64BE-NEXT:    std 29, -24(1) # 8-byte Folded Spill
; PPC64BE-NEXT:    std 30, -16(1) # 8-byte Folded Spill
; PPC64BE-NEXT:    lhz 11, 182(1)
; PPC64BE-NEXT:    lhz 12, 174(1)
; PPC64BE-NEXT:    lhz 0, 166(1)
; PPC64BE-NEXT:    nor 10, 10, 10
; PPC64BE-NEXT:    lhz 30, 158(1)
; PPC64BE-NEXT:    lhz 29, 150(1)
; PPC64BE-NEXT:    lhz 28, 142(1)
; PPC64BE-NEXT:    lhz 27, 134(1)
; PPC64BE-NEXT:    lhz 26, 126(1)
; PPC64BE-NEXT:    nor 9, 9, 9
; PPC64BE-NEXT:    nor 8, 8, 8
; PPC64BE-NEXT:    nor 7, 7, 7
; PPC64BE-NEXT:    nor 6, 6, 6
; PPC64BE-NEXT:    nor 5, 5, 5
; PPC64BE-NEXT:    nor 4, 4, 4
; PPC64BE-NEXT:    nor 25, 25, 25
; PPC64BE-NEXT:    subf 4, 4, 26
; PPC64BE-NEXT:    subf 5, 5, 27
; PPC64BE-NEXT:    subf 6, 6, 28
; PPC64BE-NEXT:    subf 7, 7, 29
; PPC64BE-NEXT:    subf 8, 8, 30
; PPC64BE-NEXT:    subf 9, 9, 0
; PPC64BE-NEXT:    subf 10, 10, 12
; PPC64BE-NEXT:    subf 11, 25, 11
; PPC64BE-NEXT:    sth 10, 12(3)
; PPC64BE-NEXT:    sth 9, 10(3)
; PPC64BE-NEXT:    sth 8, 8(3)
; PPC64BE-NEXT:    sth 7, 6(3)
; PPC64BE-NEXT:    sth 6, 4(3)
; PPC64BE-NEXT:    sth 5, 2(3)
; PPC64BE-NEXT:    sth 11, 14(3)
; PPC64BE-NEXT:    sth 4, 0(3)
; PPC64BE-NEXT:    ld 30, -16(1) # 8-byte Folded Reload
; PPC64BE-NEXT:    ld 29, -24(1) # 8-byte Folded Reload
; PPC64BE-NEXT:    ld 28, -32(1) # 8-byte Folded Reload
; PPC64BE-NEXT:    ld 27, -40(1) # 8-byte Folded Reload
; PPC64BE-NEXT:    ld 26, -48(1) # 8-byte Folded Reload
; PPC64BE-NEXT:    ld 25, -56(1) # 8-byte Folded Reload
; PPC64BE-NEXT:    blr
;
; PPC64LE-LABEL: vector_i128_i16:
; PPC64LE:       # %bb.0:
; PPC64LE-NEXT:    xxlnor 34, 34, 34
; PPC64LE-NEXT:    vsubuhm 2, 3, 2
; PPC64LE-NEXT:    blr
  %t0 = xor <8 x i16> %x, <i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1, i16 -1>
  %t1 = sub <8 x i16> %y, %t0
  ret <8 x i16> %t1
}

define <4 x i32> @vector_i128_i32(<4 x i32> %x, <4 x i32> %y) nounwind {
; PPC32-LABEL: vector_i128_i32:
; PPC32:       # %bb.0:
; PPC32-NEXT:    nor 6, 6, 6
; PPC32-NEXT:    nor 5, 5, 5
; PPC32-NEXT:    nor 4, 4, 4
; PPC32-NEXT:    nor 3, 3, 3
; PPC32-NEXT:    subf 3, 3, 7
; PPC32-NEXT:    subf 4, 4, 8
; PPC32-NEXT:    subf 5, 5, 9
; PPC32-NEXT:    subf 6, 6, 10
; PPC32-NEXT:    blr
;
; PPC64BE-LABEL: vector_i128_i32:
; PPC64BE:       # %bb.0:
; PPC64BE-NEXT:    nor 3, 3, 3
; PPC64BE-NEXT:    nor 4, 4, 4
; PPC64BE-NEXT:    nor 5, 5, 5
; PPC64BE-NEXT:    nor 6, 6, 6
; PPC64BE-NEXT:    subf 6, 6, 10
; PPC64BE-NEXT:    subf 5, 5, 9
; PPC64BE-NEXT:    subf 4, 4, 8
; PPC64BE-NEXT:    subf 3, 3, 7
; PPC64BE-NEXT:    blr
;
; PPC64LE-LABEL: vector_i128_i32:
; PPC64LE:       # %bb.0:
; PPC64LE-NEXT:    xxlnor 34, 34, 34
; PPC64LE-NEXT:    vsubuwm 2, 3, 2
; PPC64LE-NEXT:    blr
  %t0 = xor <4 x i32> %x, <i32 -1, i32 -1, i32 -1, i32 -1>
  %t1 = sub <4 x i32> %y, %t0
  ret <4 x i32> %t1
}

define <2 x i64> @vector_i128_i64(<2 x i64> %x, <2 x i64> %y) nounwind {
; PPC32-LABEL: vector_i128_i64:
; PPC32:       # %bb.0:
; PPC32-NEXT:    nor 4, 4, 4
; PPC32-NEXT:    nor 3, 3, 3
; PPC32-NEXT:    subfc 4, 4, 8
; PPC32-NEXT:    nor 6, 6, 6
; PPC32-NEXT:    subfe 3, 3, 7
; PPC32-NEXT:    nor 5, 5, 5
; PPC32-NEXT:    subfc 6, 6, 10
; PPC32-NEXT:    subfe 5, 5, 9
; PPC32-NEXT:    blr
;
; PPC64BE-LABEL: vector_i128_i64:
; PPC64BE:       # %bb.0:
; PPC64BE-NEXT:    not 4, 4
; PPC64BE-NEXT:    not 3, 3
; PPC64BE-NEXT:    sub 3, 5, 3
; PPC64BE-NEXT:    sub 4, 6, 4
; PPC64BE-NEXT:    blr
;
; PPC64LE-LABEL: vector_i128_i64:
; PPC64LE:       # %bb.0:
; PPC64LE-NEXT:    xxlnor 34, 34, 34
; PPC64LE-NEXT:    vsubudm 2, 3, 2
; PPC64LE-NEXT:    blr
  %t0 = xor <2 x i64> %x, <i64 -1, i64 -1>
  %t1 = sub <2 x i64> %y, %t0
  ret <2 x i64> %t1
}