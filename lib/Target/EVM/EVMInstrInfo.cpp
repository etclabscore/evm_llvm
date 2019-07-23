//===-- EVMInstrInfo.cpp - EVM Instruction Information ------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains the EVM implementation of the TargetInstrInfo class.
//
//===----------------------------------------------------------------------===//

#include "EVMInstrInfo.h"
#include "EVM.h"
#include "EVMSubtarget.h"
#include "EVMTargetMachine.h"
#include "llvm/ADT/STLExtras.h"
#include "llvm/ADT/SmallVector.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/RegisterScavenging.h"
#include "llvm/Support/ErrorHandling.h"
#include "llvm/Support/TargetRegistry.h"

#define GET_INSTRINFO_CTOR_DTOR
#include "EVMGenInstrInfo.inc"

using namespace llvm;

EVMInstrInfo::EVMInstrInfo()
    : EVMGenInstrInfo(EVM::ADJCALLSTACKDOWN, EVM::ADJCALLSTACKUP), RI() {
}

void EVMInstrInfo::copyPhysReg(MachineBasicBlock &MBB, MachineBasicBlock::iterator I,
                   const DebugLoc &DL, unsigned DestReg, unsigned SrcReg,
                   bool KillSrc) const {
  // replace the copy with pMOVE_r
  BuildMI(MBB, I, DL, get(EVM::pMOVE_r), DestReg)
        .addReg(SrcReg, getKillRegState(KillSrc));
}

void EVMInstrInfo::storeRegToStackSlot(MachineBasicBlock &MBB,
                                       MachineBasicBlock::iterator I,
                                       unsigned SrcReg, bool IsKill, int FI,
                                       const TargetRegisterClass *RC,
                                       const TargetRegisterInfo *TRI) const {
  // Load the frame index and then store it using the FI offset.
  // fr = MLOAD FR
  // fo = ADD fr FI
  // ch = MSTORE fo SrcReg

  llvm_unreachable("unimplemented");
}
void EVMInstrInfo::loadRegFromStackSlot(MachineBasicBlock &MBB,
                        MachineBasicBlock::iterator MI, unsigned DestReg,
                        int FrameIndex, const TargetRegisterClass *RC,
                        const TargetRegisterInfo *TRI) const {
  // fr = MLOAD FR
  // pos = ADD fr FrameIndex
  // MLOAD pos
  DebugLoc DL;
  if (MI != MBB.end())
    DL = MI->getDebugLoc();

  assert(RC == &EVM::GPRRegClass && "Invalid register class");

  llvm_unreachable("unimplemented");
}

bool EVMInstrInfo::expandPostRAPseudo(MachineInstr &MI) const {
  // We do not use this phase. Instead we use ExpandPseudos pass.
  return false;
}

MachineBasicBlock *EVMInstrInfo::findJumpTarget(MachineInstr &MI) const {
  MachineBasicBlock* MBB = MI.getParent();
  MachineFunction *MF = MBB->getParent();
  MachineRegisterInfo &MRI = MF->getRegInfo();

  unsigned reg = MI.getOperand(0).getReg();

  // make sure we only ahve one def, otherwise we bailout.
  if (!MRI.hasOneDef(reg)) {
    return nullptr;
  }
  MachineInstr *DefMI = MRI.getUniqueVRegDef(reg);

  assert(DefMI->getOpcode() == EVM::PUSH32_r);
  MachineOperand &MO = DefMI->getOperand(1);

  // We do not do indirect jump as well.
  if (!MO.isBlockAddress()) {
    return nullptr;
  }

  // we are going to use a very naive way to map BasicBlock to MachineBasicBlock
  // -- let me know if you can find a better way
  const BasicBlock* bb = MO.getBlockAddress()->getBasicBlock();

  for (MachineFunction::iterator i = MF->begin(); i != MF->end(); ++i) {
    MachineBasicBlock &MBBB = *i;
    const BasicBlock* bbb = MBBB.getBasicBlock();
    if (bb == bbb) {
      return &MBBB;
    }
  }

  return nullptr;
}

// We copied it from BPF backend. It seems to be quite incompleted,
// but let's bear with it for now.
bool EVMInstrInfo::analyzeBranch(MachineBasicBlock &MBB,
                                 MachineBasicBlock *&TBB,
                                 MachineBasicBlock *&FBB,
                                 SmallVectorImpl<MachineOperand> &Cond,
                                 bool AllowModify) const {

  MachineFunction *MF = MBB.getParent();
  MachineRegisterInfo &MRI = MF->getRegInfo();
  
  bool HaveCond = false;
  bool lastJump = false;
  MachineBasicBlock::iterator I = MBB.terminators().begin();
  while (I != MBB.terminators().end()) {
    MachineInstr &MI = *I++;
    
    if (AllowModify && lastJump) {
      MI.eraseFromParent();
      continue;
    }

    switch (MI.getOpcode()) {
    default:
      // Unhandled instruction; bail out.
      return true;
    case EVM::JUMP_r: {
      MachineBasicBlock *TMBB;
      assert(MI.getOperand(0).isReg());

      MachineBasicBlock *jumpTarget = findJumpTarget(MI);

      // bailout if we cannot find it.
      if (jumpTarget) {
        TMBB = jumpTarget;
      } else {
        return true;
      }

      if (!HaveCond) TBB = TMBB;
      else           FBB = TMBB;
      lastJump = true;
      break;
      }
    case EVM::JUMPI_r: {
      if (HaveCond) return true;
      Cond.push_back(MachineOperand::CreateImm(true));
      Cond.push_back(MI.getOperand(0));

      assert(MI.getOperand(1).isReg());
      MachineBasicBlock *jumpTarget = findJumpTarget(MI);
      if (jumpTarget) {
        TBB = jumpTarget;
      } else {
        return true;
      }
      HaveCond = true;
      break;
      }
    }
  }

  return false;
}

unsigned EVMInstrInfo::insertBranch(MachineBasicBlock &MBB,
                                    MachineBasicBlock *TBB,
                                    MachineBasicBlock *FBB,
                                    ArrayRef<MachineOperand> Cond,
                                    const DebugLoc &DL,
                                    int *BytesAdded) const {
  assert(!BytesAdded && "code size not handled");

  // Shouldn't be a fall through.
  assert(TBB && "insertBranch must not be told to insert a fallthrough");

  if (Cond.empty()) {
    assert(!FBB && "Unconditional branch with multiple successors!");
    BuildMI(&MBB, DL, get(EVM::JUMP_r)).addMBB(TBB);
    return 1;
  }

  assert(Cond.size() == 2 && "Expected a flag and a successor block");

  assert(Cond[0].getImm() && "insertBranch does not accept false parameter");

  BuildMI(&MBB, DL, get(EVM::JUMPI_r)).add(Cond[1]).addMBB(TBB);

  if (!FBB)
    return 1;

  BuildMI(&MBB, DL, get(EVM::JUMP_r)).addMBB(FBB);
  return 2;
}

unsigned EVMInstrInfo::removeBranch(MachineBasicBlock &MBB,
                                    int *BytesRemoved) const {
  assert(!BytesRemoved && "code size not handled");

  unsigned Count = 0;

  MachineBasicBlock::iterator I = MBB.terminators().begin();
  while (I != MBB.terminators().end()) {
    MachineInstr &MI = *I++;
    if (MI.isDebugInstr())
      continue;

    if (MI.getOpcode() == EVM::JUMP_r ||
        MI.getOpcode() == EVM::JUMPI_r) {
      MI.eraseFromParent();
      I = MBB.terminators().begin();
      ++Count;
    }
  }

  return Count;
}
