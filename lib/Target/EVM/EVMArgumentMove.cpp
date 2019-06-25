//===-- EVMArgumentMove.cpp - Argument instruction moving ---------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
///
/// \file
/// This file moves pSTACKARG instructions after ScheduleDAG scheduling.
///
/// This is copied from WebAssembly backend.
/// Another way to do it might be that  we create glues to bind stack arguments
/// to the beginning (EntryToken). But it is just a thought.
//===----------------------------------------------------------------------===//

#include "MCTargetDesc/EVMMCTargetDesc.h"
#include "EVM.h"
#include "EVMMachineFunctionInfo.h"
#include "EVMSubtarget.h"
#include "llvm/CodeGen/MachineBlockFrequencyInfo.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"
#include "llvm/CodeGen/Passes.h"
#include "llvm/Support/Debug.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/CodeGen/MachineInstrBuilder.h"
using namespace llvm;

#define DEBUG_TYPE "evm-argument-move"

namespace {
class EVMArgumentMove final : public MachineFunctionPass {
public:
  static char ID; // Pass identification, replacement for typeid
  EVMArgumentMove() : MachineFunctionPass(ID) {}

  StringRef getPassName() const override { return "EVM Argument Move"; }

  void getAnalysisUsage(AnalysisUsage &AU) const override {
    AU.setPreservesCFG();
    AU.addPreserved<MachineBlockFrequencyInfo>();
    AU.addPreservedID(MachineDominatorsID);
    MachineFunctionPass::getAnalysisUsage(AU);
  }

  bool runOnMachineFunction(MachineFunction &MF) override;

  static bool isStackArg(const MachineInstr &MI);
private:
  void arrangeStackArgs(MachineFunction &MF) const;
};
} // end anonymous namespace

char EVMArgumentMove::ID = 0;
INITIALIZE_PASS(EVMArgumentMove, DEBUG_TYPE,
                "Move function arguments for EVM", false, false)

FunctionPass *llvm::createEVMArgumentMove() {
  return new EVMArgumentMove();
}

bool EVMArgumentMove::isStackArg(const MachineInstr &MI) {
  unsigned opc = MI.getOpcode();

  return (opc == EVM::pSTACKARG_r);
}

void EVMArgumentMove::arrangeStackArgs(MachineFunction& MF) const {
  EVMMachineFunctionInfo *MFI = MF.getInfo<EVMMachineFunctionInfo>();
  const auto &TII = *MF.getSubtarget<EVMSubtarget>().getInstrInfo();
  MachineRegisterInfo &MRI = MF.getRegInfo();

  unsigned numStackArgs = MFI->getNumStackArgs();
  BitVector stackargs(numStackArgs, false);

  MachineBasicBlock &EntryMBB = MF.front();

  for (MachineInstr &MI : EntryMBB) {
    if (!EVMArgumentMove::isStackArg(MI)) {
      break;
    }

    MachineOperand &MO = MI.getOperand(1);
    unsigned index = MO.getImm();
    stackargs.set(index);
  }

  unsigned returnAddrReg = 0;

  for (unsigned i = 0; i < stackargs.size(); ++i) {
    // create the instruction, and insert it
    if (!stackargs[i]) {
      MachineBasicBlock::iterator insertPt = EntryMBB.begin();

      unsigned destReg = MRI.createVirtualRegister(&EVM::GPRRegClass);
      MachineInstr *MI = BuildMI(EntryMBB, insertPt, insertPt->getDebugLoc(),
                                 TII.get(EVM::pSTACKARG_r), destReg)
                             .addImm(i);

      if (i != 0) {
        EntryMBB.begin()->getOperand(0).setIsKill();
      } else {
        returnAddrReg = destReg;
      }

      LLVM_DEBUG({
        dbgs() << "Inserting Removed stackarg index:" << i << "\n";
      });
    }
  }

  // we have found the 0 stack arg, convert the RETURN sub:
  for (MachineBasicBlock &MBB : MF) {
    for (MachineBasicBlock::iterator I = MBB.begin(), E = MBB.end(); I != E;) {
      MachineInstr &MI = *I++;
      if (MI.getOpcode() == EVM::pRETURNSUB_TEMP_r) {
        BuildMI(*MI.getParent(), MI, MI.getDebugLoc(),
                TII.get(EVM::pRETURNSUB_r))
            .addReg(returnAddrReg)
            .addReg(MI.getOperand(0).getReg());
        MI.eraseFromParent();
      }
      if (MI.getOpcode() == EVM::pRETURNSUBVOID_TEMP_r) {
        BuildMI(*MI.getParent(), MI, MI.getDebugLoc(),
                TII.get(EVM::pRETURNSUBVOID_r))
            .addReg(returnAddrReg);
        MI.eraseFromParent();
      }
    }
  }
}

bool EVMArgumentMove::runOnMachineFunction(MachineFunction &MF) {
  LLVM_DEBUG({
    dbgs() << "********** Argument Move **********\n"
           << "********** Function: " << MF.getName() << '\n';
  });

  bool Changed = false;
  MachineBasicBlock &EntryMBB = MF.front();
  MachineBasicBlock::iterator InsertPt = EntryMBB.end();

  arrangeStackArgs(MF);

  // Look for the first NonArg instruction.
  for (MachineInstr &MI : EntryMBB) {
    if (!EVMArgumentMove::isStackArg(MI)) {
      InsertPt = MI;
      break;
    }
  }

  // Now move any argument instructions later in the block
  // to before our first NonArg instruction.
  for (MachineInstr &MI : llvm::make_range(InsertPt, EntryMBB.end())) {
    if (EVMArgumentMove::isStackArg(MI)) {
      EntryMBB.insert(InsertPt, MI.removeFromParent());
      Changed = true;
    }
  }

  return Changed;
}