//=- EVMMachineFunctionInfo.h - EVM machine function info -----*- C++ -*-=//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file declares EVM-specific per-machine-function information.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_EVM_EVMMACHINEFUNCTIONINFO_H
#define LLVM_LIB_TARGET_EVM_EVMMACHINEFUNCTIONINFO_H

#include "llvm/CodeGen/MachineFrameInfo.h"
#include "llvm/CodeGen/MachineFunction.h"
#include "llvm/CodeGen/MachineRegisterInfo.h"

namespace llvm {

/// EVMMachineFunctionInfo - This class is derived from MachineFunctionInfo
/// and contains private EVM-specific information for each MachineFunction.
class EVMMachineFunctionInfo : public MachineFunctionInfo {
private:
  MachineFunction &MF;
  /// FrameIndex for start of varargs area
  int VarArgsFrameIndex = 0;
  /// Size of the save area used for varargs
  int VarArgsSaveSize = 0;

  unsigned NumStackArgs = 0;

  /// Copied from WebAssembly backend.
  /// A mapping from CodeGen vreg index to a boolean value indicating whether
  /// the given register is considered to be "stackified", meaning it has been
  /// determined or made to meet the stack requirements:
  ///   - single use (per path)
  ///   - single def (per path)
  ///   - defined and used in LIFO order with other stack registers
  BitVector VRegStackified;

  unsigned FrameIndexSize;

public:
  EVMMachineFunctionInfo(MachineFunction &MF)
    : MF(MF), FrameIndexSize(0)
  {}

  void setNumStackArgs(unsigned size) { NumStackArgs = size; }
  unsigned getNumStackArgs() {return NumStackArgs; }

  int getVarArgsFrameIndex() const { return VarArgsFrameIndex; }
  void setVarArgsFrameIndex(int Index) { VarArgsFrameIndex = Index; }

  unsigned getVarArgsSaveSize() const { return VarArgsSaveSize; }
  void setVarArgsSaveSize(int Size) { VarArgsSaveSize = Size; }

  unsigned getFrameIndexSize() const { return FrameIndexSize; }
  void setFrameIndexSize(unsigned newFI) {
    assert(newFI > FrameIndexSize
           && "new frameindex should be greater than previous one.");
    FrameIndexSize = newFI;
  }

  void stackifyVReg(unsigned VReg) {
    assert(MF.getRegInfo().getUniqueVRegDef(VReg));
    auto I = TargetRegisterInfo::virtReg2Index(VReg);
    if (I >= VRegStackified.size())
      VRegStackified.resize(I + 1);
    VRegStackified.set(I);
  }

  bool isVRegStackified(unsigned VReg) const {
    auto I = TargetRegisterInfo::virtReg2Index(VReg);
    if (I >= VRegStackified.size())
      return false;
    return VRegStackified.test(I);
  }
};

} // end namespace llvm

#endif // LLVM_LIB_TARGET_EVM_EVMMACHINEFUNCTIONINFO_H