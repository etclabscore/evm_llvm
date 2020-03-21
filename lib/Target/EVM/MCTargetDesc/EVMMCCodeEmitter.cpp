//===-- EVMMCCodeEmitter.cpp - Convert EVM code to machine code -----------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements the EVMMCCodeEmitter class.
//
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/EVMMCTargetDesc.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/IR/Constants.h"
#include "llvm/MC/MCCodeEmitter.h"
#include "llvm/MC/MCFixup.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCInstrInfo.h"
#include "llvm/MC/MCRegisterInfo.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/MCInstBuilder.h"
#include "llvm/Support/Endian.h"
#include "llvm/Support/EndianStream.h"
#include <cassert>
#include <cstdint>

using namespace llvm;

#define DEBUG_TYPE "mccodeemitter"

namespace {

class EVMMCCodeEmitter : public MCCodeEmitter {
  const MCInstrInfo &MCII;
  const MCRegisterInfo &MRI;
  bool IsLittleEndian;

public:
  EVMMCCodeEmitter(const MCInstrInfo &mcii, const MCRegisterInfo &mri,
                   bool IsLittleEndian)
      : MCII(mcii), MRI(mri), IsLittleEndian(IsLittleEndian) {}
  EVMMCCodeEmitter(const EVMMCCodeEmitter &) = delete;
  void operator=(const EVMMCCodeEmitter &) = delete;
  ~EVMMCCodeEmitter() override = default;

  // getBinaryCodeForInstr - TableGen'erated function for getting the
  // binary encoding for an instruction.
  uint64_t getBinaryCodeForInstr(const MCInst &MI,
                                 SmallVectorImpl<MCFixup> &Fixups,
                                 const MCSubtargetInfo &STI) const;

  // getMachineOpValue - Return binary encoding of operand. If the machine
  // operand requires relocation, record the relocation and return zero.
  unsigned getMachineOpValue(const MCInst &MI, const MCOperand &MO,
                             SmallVectorImpl<MCFixup> &Fixups,
                             const MCSubtargetInfo &STI) const;

  uint64_t getMemoryOpValue(const MCInst &MI, unsigned Op,
                            SmallVectorImpl<MCFixup> &Fixups,
                            const MCSubtargetInfo &STI) const;

  void encodeInstruction(const MCInst &MI, raw_ostream &OS,
                         SmallVectorImpl<MCFixup> &Fixups,
                         const MCSubtargetInfo &STI) const override;

  void
  verifyInstructionPredicates(const MCInst &MI,
                              const FeatureBitset &AvailableFeatures) const;

private:
  FeatureBitset computeAvailableFeatures(const FeatureBitset &FB) const;
  void verifyInstructionPredicates(const MCInst &MI,
                                   uint64_t AvailableFeatures) const;
  void encodeImmediate(raw_ostream &OS, const MCOperand& opnd, unsigned push_size) const;
  void encodeExpr(raw_ostream &OS, const MCOperand& opnd, unsigned push_size) const;
};

} // end anonymous namespace

MCCodeEmitter *llvm::createEVMMCCodeEmitter(const MCInstrInfo &MCII,
                                            const MCRegisterInfo &MRI,
                                            MCContext &Ctx) {
  return new EVMMCCodeEmitter(MCII, MRI, true);
}

unsigned EVMMCCodeEmitter::getMachineOpValue(const MCInst &MI,
                                             const MCOperand &MO,
                                             SmallVectorImpl<MCFixup> &Fixups,
                                             const MCSubtargetInfo &STI) const {
  llvm_unreachable("unimplemented.");
}

static bool is_PUSH(uint64_t binary) {
  if (binary >= 0x60 && binary <= 0x7F) {
    return true;
  }
  return false;
}

void EVMMCCodeEmitter::encodeExpr(raw_ostream &OS,
                                  const MCOperand& opnd,
                                  unsigned push_size) const {
    
}

void EVMMCCodeEmitter::encodeImmediate(raw_ostream &OS,
                                       const MCOperand& opnd,
                                       unsigned push_size) const {
  // ugly padding the top bits for now. We will have to properly support
  // 256 bit operands and remove this.
  if (opnd.isImm()) {
    int64_t imm = opnd.getImm();

    assert(push_size < 9 && "unimplemented push size");

    for (int i = push_size - 1; i >= 0; --i) {
      char byte = (uint64_t)(0x00FF) & (imm >> (i * 8));
      support::endian::write<char>(OS, byte, support::big);
    }
  } else if (opnd.isCImm()) {
    //if it is a CImmediate type, it is a value more than 64bit.
    const ConstantInt* ci = opnd.getCImm();
    const APInt& apint = ci->getValue();

    for (int i = push_size - 1; i >= 0; --i) {
      APInt apbyte = apint.lshr(i * 8).trunc(8);
      char byte = apbyte.getZExtValue();
      support::endian::write<char>(OS, byte, support::big);
    }
  } else {
    llvm_unreachable("MCOperand immediate should only be of imm or cimm type");
  }
}

void EVMMCCodeEmitter::encodeInstruction(const MCInst &MI, raw_ostream &OS,
                                         SmallVectorImpl<MCFixup> &Fixups,
                                         const MCSubtargetInfo &STI) const {
  uint64_t Binary;

  Binary = getBinaryCodeForInstr(MI, Fixups, STI);
  support::endian::write<char>(OS, Binary, support::big);

  // emit trailing immediate value for push.
  if (is_PUSH(Binary)) {
    assert(MI.getNumOperands() == 1);
    unsigned push_size = Binary - 0x60 + 1;
    if (push_size > 8 && push_size != 32) {
      // this is a reminder check for implementing proper encoding.
      llvm_unreachable("unimplemented encoding size for Push.");
    }

    auto &opnd = MI.getOperand(0);
    if (opnd.isImm() || opnd.isCImm()) {
      encodeImmediate(OS, opnd, push_size);
    } else {
      assert(push_size == 2 && "Static Jump operands are 2 bytes");
      assert(opnd.isExpr() && "PUSH operand should be either Imm or Expr");
      MCFixupKind Kind = MCFixupKind(FK_SecRel_2);
      // allocate space for fix up.
      support::endian::write<uint16_t>(OS, 0x0000, support::big);
      Fixups.push_back(MCFixup::create(1, opnd.getExpr(), Kind, MI.getLoc()));
    }
  }
}

// Encode EVM Memory Operand
uint64_t EVMMCCodeEmitter::getMemoryOpValue(const MCInst &MI, unsigned Op,
                                            SmallVectorImpl<MCFixup> &Fixups,
                                            const MCSubtargetInfo &STI) const {
  llvm_unreachable("unimplemented.");
}

#define ENABLE_INSTR_PREDICATE_VERIFIER
#include "EVMGenMCCodeEmitter.inc"
