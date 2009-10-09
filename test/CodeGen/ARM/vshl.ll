; RUN: llc < %s -march=arm -mattr=+neon | FileCheck %s

define <8 x i8> @vshls8(<8 x i8>* %A, <8 x i8>* %B) nounwind {
;CHECK: vshls8:
;CHECK: vshl.s8
	%tmp1 = load <8 x i8>* %A
	%tmp2 = load <8 x i8>* %B
	%tmp3 = call <8 x i8> @llvm.arm.neon.vshifts.v8i8(<8 x i8> %tmp1, <8 x i8> %tmp2)
	ret <8 x i8> %tmp3
}

define <4 x i16> @vshls16(<4 x i16>* %A, <4 x i16>* %B) nounwind {
;CHECK: vshls16:
;CHECK: vshl.s16
	%tmp1 = load <4 x i16>* %A
	%tmp2 = load <4 x i16>* %B
	%tmp3 = call <4 x i16> @llvm.arm.neon.vshifts.v4i16(<4 x i16> %tmp1, <4 x i16> %tmp2)
	ret <4 x i16> %tmp3
}

define <2 x i32> @vshls32(<2 x i32>* %A, <2 x i32>* %B) nounwind {
;CHECK: vshls32:
;CHECK: vshl.s32
	%tmp1 = load <2 x i32>* %A
	%tmp2 = load <2 x i32>* %B
	%tmp3 = call <2 x i32> @llvm.arm.neon.vshifts.v2i32(<2 x i32> %tmp1, <2 x i32> %tmp2)
	ret <2 x i32> %tmp3
}

define <1 x i64> @vshls64(<1 x i64>* %A, <1 x i64>* %B) nounwind {
;CHECK: vshls64:
;CHECK: vshl.s64
	%tmp1 = load <1 x i64>* %A
	%tmp2 = load <1 x i64>* %B
	%tmp3 = call <1 x i64> @llvm.arm.neon.vshifts.v1i64(<1 x i64> %tmp1, <1 x i64> %tmp2)
	ret <1 x i64> %tmp3
}

define <8 x i8> @vshlu8(<8 x i8>* %A, <8 x i8>* %B) nounwind {
;CHECK: vshlu8:
;CHECK: vshl.u8
	%tmp1 = load <8 x i8>* %A
	%tmp2 = load <8 x i8>* %B
	%tmp3 = call <8 x i8> @llvm.arm.neon.vshiftu.v8i8(<8 x i8> %tmp1, <8 x i8> %tmp2)
	ret <8 x i8> %tmp3
}

define <4 x i16> @vshlu16(<4 x i16>* %A, <4 x i16>* %B) nounwind {
;CHECK: vshlu16:
;CHECK: vshl.u16
	%tmp1 = load <4 x i16>* %A
	%tmp2 = load <4 x i16>* %B
	%tmp3 = call <4 x i16> @llvm.arm.neon.vshiftu.v4i16(<4 x i16> %tmp1, <4 x i16> %tmp2)
	ret <4 x i16> %tmp3
}

define <2 x i32> @vshlu32(<2 x i32>* %A, <2 x i32>* %B) nounwind {
;CHECK: vshlu32:
;CHECK: vshl.u32
	%tmp1 = load <2 x i32>* %A
	%tmp2 = load <2 x i32>* %B
	%tmp3 = call <2 x i32> @llvm.arm.neon.vshiftu.v2i32(<2 x i32> %tmp1, <2 x i32> %tmp2)
	ret <2 x i32> %tmp3
}

define <1 x i64> @vshlu64(<1 x i64>* %A, <1 x i64>* %B) nounwind {
;CHECK: vshlu64:
;CHECK: vshl.u64
	%tmp1 = load <1 x i64>* %A
	%tmp2 = load <1 x i64>* %B
	%tmp3 = call <1 x i64> @llvm.arm.neon.vshiftu.v1i64(<1 x i64> %tmp1, <1 x i64> %tmp2)
	ret <1 x i64> %tmp3
}

define <16 x i8> @vshlQs8(<16 x i8>* %A, <16 x i8>* %B) nounwind {
;CHECK: vshlQs8:
;CHECK: vshl.s8
	%tmp1 = load <16 x i8>* %A
	%tmp2 = load <16 x i8>* %B
	%tmp3 = call <16 x i8> @llvm.arm.neon.vshifts.v16i8(<16 x i8> %tmp1, <16 x i8> %tmp2)
	ret <16 x i8> %tmp3
}

define <8 x i16> @vshlQs16(<8 x i16>* %A, <8 x i16>* %B) nounwind {
;CHECK: vshlQs16:
;CHECK: vshl.s16
	%tmp1 = load <8 x i16>* %A
	%tmp2 = load <8 x i16>* %B
	%tmp3 = call <8 x i16> @llvm.arm.neon.vshifts.v8i16(<8 x i16> %tmp1, <8 x i16> %tmp2)
	ret <8 x i16> %tmp3
}

define <4 x i32> @vshlQs32(<4 x i32>* %A, <4 x i32>* %B) nounwind {
;CHECK: vshlQs32:
;CHECK: vshl.s32
	%tmp1 = load <4 x i32>* %A
	%tmp2 = load <4 x i32>* %B
	%tmp3 = call <4 x i32> @llvm.arm.neon.vshifts.v4i32(<4 x i32> %tmp1, <4 x i32> %tmp2)
	ret <4 x i32> %tmp3
}

define <2 x i64> @vshlQs64(<2 x i64>* %A, <2 x i64>* %B) nounwind {
;CHECK: vshlQs64:
;CHECK: vshl.s64
	%tmp1 = load <2 x i64>* %A
	%tmp2 = load <2 x i64>* %B
	%tmp3 = call <2 x i64> @llvm.arm.neon.vshifts.v2i64(<2 x i64> %tmp1, <2 x i64> %tmp2)
	ret <2 x i64> %tmp3
}

define <16 x i8> @vshlQu8(<16 x i8>* %A, <16 x i8>* %B) nounwind {
;CHECK: vshlQu8:
;CHECK: vshl.u8
	%tmp1 = load <16 x i8>* %A
	%tmp2 = load <16 x i8>* %B
	%tmp3 = call <16 x i8> @llvm.arm.neon.vshiftu.v16i8(<16 x i8> %tmp1, <16 x i8> %tmp2)
	ret <16 x i8> %tmp3
}

define <8 x i16> @vshlQu16(<8 x i16>* %A, <8 x i16>* %B) nounwind {
;CHECK: vshlQu16:
;CHECK: vshl.u16
	%tmp1 = load <8 x i16>* %A
	%tmp2 = load <8 x i16>* %B
	%tmp3 = call <8 x i16> @llvm.arm.neon.vshiftu.v8i16(<8 x i16> %tmp1, <8 x i16> %tmp2)
	ret <8 x i16> %tmp3
}

define <4 x i32> @vshlQu32(<4 x i32>* %A, <4 x i32>* %B) nounwind {
;CHECK: vshlQu32:
;CHECK: vshl.u32
	%tmp1 = load <4 x i32>* %A
	%tmp2 = load <4 x i32>* %B
	%tmp3 = call <4 x i32> @llvm.arm.neon.vshiftu.v4i32(<4 x i32> %tmp1, <4 x i32> %tmp2)
	ret <4 x i32> %tmp3
}

define <2 x i64> @vshlQu64(<2 x i64>* %A, <2 x i64>* %B) nounwind {
;CHECK: vshlQu64:
;CHECK: vshl.u64
	%tmp1 = load <2 x i64>* %A
	%tmp2 = load <2 x i64>* %B
	%tmp3 = call <2 x i64> @llvm.arm.neon.vshiftu.v2i64(<2 x i64> %tmp1, <2 x i64> %tmp2)
	ret <2 x i64> %tmp3
}

; For left shifts by immediates, the signedness is irrelevant.
; Test a mix of both signed and unsigned intrinsics.

define <8 x i8> @vshli8(<8 x i8>* %A) nounwind {
;CHECK: vshli8:
;CHECK: vshl.i8
	%tmp1 = load <8 x i8>* %A
	%tmp2 = call <8 x i8> @llvm.arm.neon.vshifts.v8i8(<8 x i8> %tmp1, <8 x i8> < i8 7, i8 7, i8 7, i8 7, i8 7, i8 7, i8 7, i8 7 >)
	ret <8 x i8> %tmp2
}

define <4 x i16> @vshli16(<4 x i16>* %A) nounwind {
;CHECK: vshli16:
;CHECK: vshl.i16
	%tmp1 = load <4 x i16>* %A
	%tmp2 = call <4 x i16> @llvm.arm.neon.vshiftu.v4i16(<4 x i16> %tmp1, <4 x i16> < i16 15, i16 15, i16 15, i16 15 >)
	ret <4 x i16> %tmp2
}

define <2 x i32> @vshli32(<2 x i32>* %A) nounwind {
;CHECK: vshli32:
;CHECK: vshl.i32
	%tmp1 = load <2 x i32>* %A
	%tmp2 = call <2 x i32> @llvm.arm.neon.vshifts.v2i32(<2 x i32> %tmp1, <2 x i32> < i32 31, i32 31 >)
	ret <2 x i32> %tmp2
}

define <1 x i64> @vshli64(<1 x i64>* %A) nounwind {
;CHECK: vshli64:
;CHECK: vshl.i64
	%tmp1 = load <1 x i64>* %A
	%tmp2 = call <1 x i64> @llvm.arm.neon.vshiftu.v1i64(<1 x i64> %tmp1, <1 x i64> < i64 63 >)
	ret <1 x i64> %tmp2
}

define <16 x i8> @vshlQi8(<16 x i8>* %A) nounwind {
;CHECK: vshlQi8:
;CHECK: vshl.i8
	%tmp1 = load <16 x i8>* %A
	%tmp2 = call <16 x i8> @llvm.arm.neon.vshifts.v16i8(<16 x i8> %tmp1, <16 x i8> < i8 7, i8 7, i8 7, i8 7, i8 7, i8 7, i8 7, i8 7, i8 7, i8 7, i8 7, i8 7, i8 7, i8 7, i8 7, i8 7 >)
	ret <16 x i8> %tmp2
}

define <8 x i16> @vshlQi16(<8 x i16>* %A) nounwind {
;CHECK: vshlQi16:
;CHECK: vshl.i16
	%tmp1 = load <8 x i16>* %A
	%tmp2 = call <8 x i16> @llvm.arm.neon.vshiftu.v8i16(<8 x i16> %tmp1, <8 x i16> < i16 15, i16 15, i16 15, i16 15, i16 15, i16 15, i16 15, i16 15 >)
	ret <8 x i16> %tmp2
}

define <4 x i32> @vshlQi32(<4 x i32>* %A) nounwind {
;CHECK: vshlQi32:
;CHECK: vshl.i32
	%tmp1 = load <4 x i32>* %A
	%tmp2 = call <4 x i32> @llvm.arm.neon.vshifts.v4i32(<4 x i32> %tmp1, <4 x i32> < i32 31, i32 31, i32 31, i32 31 >)
	ret <4 x i32> %tmp2
}

define <2 x i64> @vshlQi64(<2 x i64>* %A) nounwind {
;CHECK: vshlQi64:
;CHECK: vshl.i64
	%tmp1 = load <2 x i64>* %A
	%tmp2 = call <2 x i64> @llvm.arm.neon.vshiftu.v2i64(<2 x i64> %tmp1, <2 x i64> < i64 63, i64 63 >)
	ret <2 x i64> %tmp2
}

; Right shift by immediate:

define <8 x i8> @vshrs8(<8 x i8>* %A) nounwind {
;CHECK: vshrs8:
;CHECK: vshr.s8
	%tmp1 = load <8 x i8>* %A
	%tmp2 = call <8 x i8> @llvm.arm.neon.vshifts.v8i8(<8 x i8> %tmp1, <8 x i8> < i8 -8, i8 -8, i8 -8, i8 -8, i8 -8, i8 -8, i8 -8, i8 -8 >)
	ret <8 x i8> %tmp2
}

define <4 x i16> @vshrs16(<4 x i16>* %A) nounwind {
;CHECK: vshrs16:
;CHECK: vshr.s16
	%tmp1 = load <4 x i16>* %A
	%tmp2 = call <4 x i16> @llvm.arm.neon.vshifts.v4i16(<4 x i16> %tmp1, <4 x i16> < i16 -16, i16 -16, i16 -16, i16 -16 >)
	ret <4 x i16> %tmp2
}

define <2 x i32> @vshrs32(<2 x i32>* %A) nounwind {
;CHECK: vshrs32:
;CHECK: vshr.s32
	%tmp1 = load <2 x i32>* %A
	%tmp2 = call <2 x i32> @llvm.arm.neon.vshifts.v2i32(<2 x i32> %tmp1, <2 x i32> < i32 -32, i32 -32 >)
	ret <2 x i32> %tmp2
}

define <1 x i64> @vshrs64(<1 x i64>* %A) nounwind {
;CHECK: vshrs64:
;CHECK: vshr.s64
	%tmp1 = load <1 x i64>* %A
	%tmp2 = call <1 x i64> @llvm.arm.neon.vshifts.v1i64(<1 x i64> %tmp1, <1 x i64> < i64 -64 >)
	ret <1 x i64> %tmp2
}

define <8 x i8> @vshru8(<8 x i8>* %A) nounwind {
;CHECK: vshru8:
;CHECK: vshr.u8
	%tmp1 = load <8 x i8>* %A
	%tmp2 = call <8 x i8> @llvm.arm.neon.vshiftu.v8i8(<8 x i8> %tmp1, <8 x i8> < i8 -8, i8 -8, i8 -8, i8 -8, i8 -8, i8 -8, i8 -8, i8 -8 >)
	ret <8 x i8> %tmp2
}

define <4 x i16> @vshru16(<4 x i16>* %A) nounwind {
;CHECK: vshru16:
;CHECK: vshr.u16
	%tmp1 = load <4 x i16>* %A
	%tmp2 = call <4 x i16> @llvm.arm.neon.vshiftu.v4i16(<4 x i16> %tmp1, <4 x i16> < i16 -16, i16 -16, i16 -16, i16 -16 >)
	ret <4 x i16> %tmp2
}

define <2 x i32> @vshru32(<2 x i32>* %A) nounwind {
;CHECK: vshru32:
;CHECK: vshr.u32
	%tmp1 = load <2 x i32>* %A
	%tmp2 = call <2 x i32> @llvm.arm.neon.vshiftu.v2i32(<2 x i32> %tmp1, <2 x i32> < i32 -32, i32 -32 >)
	ret <2 x i32> %tmp2
}

define <1 x i64> @vshru64(<1 x i64>* %A) nounwind {
;CHECK: vshru64:
;CHECK: vshr.u64
	%tmp1 = load <1 x i64>* %A
	%tmp2 = call <1 x i64> @llvm.arm.neon.vshiftu.v1i64(<1 x i64> %tmp1, <1 x i64> < i64 -64 >)
	ret <1 x i64> %tmp2
}

define <16 x i8> @vshrQs8(<16 x i8>* %A) nounwind {
;CHECK: vshrQs8:
;CHECK: vshr.s8
	%tmp1 = load <16 x i8>* %A
	%tmp2 = call <16 x i8> @llvm.arm.neon.vshifts.v16i8(<16 x i8> %tmp1, <16 x i8> < i8 -8, i8 -8, i8 -8, i8 -8, i8 -8, i8 -8, i8 -8, i8 -8, i8 -8, i8 -8, i8 -8, i8 -8, i8 -8, i8 -8, i8 -8, i8 -8 >)
	ret <16 x i8> %tmp2
}

define <8 x i16> @vshrQs16(<8 x i16>* %A) nounwind {
;CHECK: vshrQs16:
;CHECK: vshr.s16
	%tmp1 = load <8 x i16>* %A
	%tmp2 = call <8 x i16> @llvm.arm.neon.vshifts.v8i16(<8 x i16> %tmp1, <8 x i16> < i16 -16, i16 -16, i16 -16, i16 -16, i16 -16, i16 -16, i16 -16, i16 -16 >)
	ret <8 x i16> %tmp2
}

define <4 x i32> @vshrQs32(<4 x i32>* %A) nounwind {
;CHECK: vshrQs32:
;CHECK: vshr.s32
	%tmp1 = load <4 x i32>* %A
	%tmp2 = call <4 x i32> @llvm.arm.neon.vshifts.v4i32(<4 x i32> %tmp1, <4 x i32> < i32 -32, i32 -32, i32 -32, i32 -32 >)
	ret <4 x i32> %tmp2
}

define <2 x i64> @vshrQs64(<2 x i64>* %A) nounwind {
;CHECK: vshrQs64:
;CHECK: vshr.s64
	%tmp1 = load <2 x i64>* %A
	%tmp2 = call <2 x i64> @llvm.arm.neon.vshifts.v2i64(<2 x i64> %tmp1, <2 x i64> < i64 -64, i64 -64 >)
	ret <2 x i64> %tmp2
}

define <16 x i8> @vshrQu8(<16 x i8>* %A) nounwind {
;CHECK: vshrQu8:
;CHECK: vshr.u8
	%tmp1 = load <16 x i8>* %A
	%tmp2 = call <16 x i8> @llvm.arm.neon.vshiftu.v16i8(<16 x i8> %tmp1, <16 x i8> < i8 -8, i8 -8, i8 -8, i8 -8, i8 -8, i8 -8, i8 -8, i8 -8, i8 -8, i8 -8, i8 -8, i8 -8, i8 -8, i8 -8, i8 -8, i8 -8 >)
	ret <16 x i8> %tmp2
}

define <8 x i16> @vshrQu16(<8 x i16>* %A) nounwind {
;CHECK: vshrQu16:
;CHECK: vshr.u16
	%tmp1 = load <8 x i16>* %A
	%tmp2 = call <8 x i16> @llvm.arm.neon.vshiftu.v8i16(<8 x i16> %tmp1, <8 x i16> < i16 -16, i16 -16, i16 -16, i16 -16, i16 -16, i16 -16, i16 -16, i16 -16 >)
	ret <8 x i16> %tmp2
}

define <4 x i32> @vshrQu32(<4 x i32>* %A) nounwind {
;CHECK: vshrQu32:
;CHECK: vshr.u32
	%tmp1 = load <4 x i32>* %A
	%tmp2 = call <4 x i32> @llvm.arm.neon.vshiftu.v4i32(<4 x i32> %tmp1, <4 x i32> < i32 -32, i32 -32, i32 -32, i32 -32 >)
	ret <4 x i32> %tmp2
}

define <2 x i64> @vshrQu64(<2 x i64>* %A) nounwind {
;CHECK: vshrQu64:
;CHECK: vshr.u64
	%tmp1 = load <2 x i64>* %A
	%tmp2 = call <2 x i64> @llvm.arm.neon.vshiftu.v2i64(<2 x i64> %tmp1, <2 x i64> < i64 -64, i64 -64 >)
	ret <2 x i64> %tmp2
}

declare <8 x i8>  @llvm.arm.neon.vshifts.v8i8(<8 x i8>, <8 x i8>) nounwind readnone
declare <4 x i16> @llvm.arm.neon.vshifts.v4i16(<4 x i16>, <4 x i16>) nounwind readnone
declare <2 x i32> @llvm.arm.neon.vshifts.v2i32(<2 x i32>, <2 x i32>) nounwind readnone
declare <1 x i64> @llvm.arm.neon.vshifts.v1i64(<1 x i64>, <1 x i64>) nounwind readnone

declare <8 x i8>  @llvm.arm.neon.vshiftu.v8i8(<8 x i8>, <8 x i8>) nounwind readnone
declare <4 x i16> @llvm.arm.neon.vshiftu.v4i16(<4 x i16>, <4 x i16>) nounwind readnone
declare <2 x i32> @llvm.arm.neon.vshiftu.v2i32(<2 x i32>, <2 x i32>) nounwind readnone
declare <1 x i64> @llvm.arm.neon.vshiftu.v1i64(<1 x i64>, <1 x i64>) nounwind readnone

declare <16 x i8> @llvm.arm.neon.vshifts.v16i8(<16 x i8>, <16 x i8>) nounwind readnone
declare <8 x i16> @llvm.arm.neon.vshifts.v8i16(<8 x i16>, <8 x i16>) nounwind readnone
declare <4 x i32> @llvm.arm.neon.vshifts.v4i32(<4 x i32>, <4 x i32>) nounwind readnone
declare <2 x i64> @llvm.arm.neon.vshifts.v2i64(<2 x i64>, <2 x i64>) nounwind readnone

declare <16 x i8> @llvm.arm.neon.vshiftu.v16i8(<16 x i8>, <16 x i8>) nounwind readnone
declare <8 x i16> @llvm.arm.neon.vshiftu.v8i16(<8 x i16>, <8 x i16>) nounwind readnone
declare <4 x i32> @llvm.arm.neon.vshiftu.v4i32(<4 x i32>, <4 x i32>) nounwind readnone
declare <2 x i64> @llvm.arm.neon.vshiftu.v2i64(<2 x i64>, <2 x i64>) nounwind readnone
