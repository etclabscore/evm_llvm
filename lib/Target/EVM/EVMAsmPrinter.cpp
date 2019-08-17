//===-- EVMAsmPrinter.cpp - EVM LLVM assembly writer ------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains a printer that converts from our internal representation
// of machine-dependent LLVM code to the EVM assembly language.
//
//===----------------------------------------------------------------------===//

#include "EVM.h"
#include "EVMMCInstLower.h"
#include "InstPrinter/EVMInstPrinter.h"
#include "EVMTargetMachine.h"
#include "llvm/CodeGen/AsmPrinter.h"
#include "llvm/CodeGen/MachineConstantPool.h"
#include "llvm/CodeGen/MachineFunctionPass.h"
#include "llvm/CodeGen/MachineInstr.h"
#include "llvm/CodeGen/MachineModuleInfo.h"
#include "llvm/MC/MCAsmInfo.h"
#include "llvm/MC/MCInst.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSymbol.h"
#include "llvm/Support/TargetRegistry.h"
#include "llvm/Support/raw_ostream.h"
#include "llvm/CodeGen/TargetLoweringObjectFileImpl.h"

#include "llvm/MC/MCInstBuilder.h"

using namespace llvm;

#define DEBUG_TYPE "evm-asm-printer"

namespace {
class EVMAsmPrinter : public AsmPrinter {
public:
  explicit EVMAsmPrinter(TargetMachine &TM,
                           std::unique_ptr<MCStreamer> Streamer)
      : AsmPrinter(TM, std::move(Streamer)) {}

  void EmitStartOfAsmFile(Module &M) override;
  //void EmitEndOfAsmFile(Module &M) override;

  //void EmitFunctionEntryLabel() override;

  StringRef getPassName() const override { return "EVM Assembly Printer"; }

  void EmitInstruction(const MachineInstr *MI) override;

  void printOperand(const MachineInstr *MI, unsigned OpNo, raw_ostream &OS);

  bool PrintAsmOperand(const MachineInstr *MI, unsigned OpNo,
                       const char *ExtraCode, raw_ostream &OS) override;
  bool PrintAsmMemoryOperand(const MachineInstr *MI, unsigned OpNo,
                             const char *ExtraCode, raw_ostream &OS) override;

  // void EmitToStreamer(MCStreamer &S, const MCInst &Inst);
  bool emitPseudoExpansionLowering(MCStreamer &OutStreamer,
                                   const MachineInstr *MI);

  // Wrapper needed for tblgenned pseudo lowering.
  bool lowerOperand(const MachineOperand &MO, MCOperand &MCOp) const {
    return LowerEVMMachineOperandToMCOperand(MO, MCOp, *this);
    }
  //bool runOnMachineFunction(MachineFunction &MF) override;

private:
  void emitFreeMemoryPointer() const;
  void emitNonPayableCheck(const Function &F, MCSymbol *CallDataUnpackerLabel) const;
  void emitRetrieveConstructorParameters() const;
  void emitConstructorBody() const;
  void emitCopyRuntimeCodeToMemory() const;
  void emitReturnRuntimeCode() const;
  void emitContractParameters() const;
  void emitShortCalldataCheck() const;
  void emitFunctionSelector(Module &M);

  void emitFunctionWrapper(const Function &F);
  void emitCallDataUnpacker(const Function &F,
                            MCSymbol *CallDataUnpackerLabel);
  void emitMemoryReturner(const Function &F) const;
  void genearteFunctionBodyLabels(Module &M);

  DenseMap<const Function*, MCSymbol *> funcWrapperMap;
  DenseMap<const Function*, MCSymbol *> funcBodyMap;
  std::unique_ptr<MCSubtargetInfo> STI;
};
}

/*
bool EVMAsmPrinter::runOnMachineFunction(MachineFunction &MF) {
  // emit the function body label before we emit the function.
  MCSymbol* funcBodySymbol = this->funcBodyMap[&MF.getFunction()];
  OutStreamer->EmitLabel(funcBodySymbol);

  return AsmPrinter::runOnMachineFunction(MF);
}
*/

void EVMAsmPrinter::emitMemoryReturner(const Function &F) const {
  // if the function does not return anything, skip.
  Type* retType = F.getReturnType();
  if (retType->isVoidTy()) {
    return;
  }

  OutStreamer->EmitInstruction(MCInstBuilder(EVM::JUMPDEST), *STI);

  emitFreeMemoryPointer();

  // TODO:

  OutStreamer->EmitInstruction(MCInstBuilder(EVM::SWAP1), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::SUB), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::PUSH1).addImm(0x20), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::ADD), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::SWAP1), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::RETURN), *STI);
}

void EVMAsmPrinter::genearteFunctionBodyLabels(Module &M) {
  for (const auto &F : M) {
    MCSymbol *funcBodyLabel =
      MMI->getContext().getOrCreateSymbol(F.getName() + "_funcbody");
    this->funcBodyMap.insert(
        std::pair<const Function *, MCSymbol *>(&F, funcBodyLabel));
  }
}

void EVMAsmPrinter::emitFreeMemoryPointer() const {
  OutStreamer->AddComment("Free memory pointer");
  // Initialize the Free memory pointer
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::PUSH1).addImm(0x80), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::PUSH1).addImm(0x40), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::MSTORE), *STI);
}

void EVMAsmPrinter::emitNonPayableCheck(const Function &F,
                                        MCSymbol *CallDataUnpackerLabel) const {
  OutStreamer->AddComment("non-payable check");

  // Non-payable check
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::CALLVALUE), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::DUP1), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::ISZERO), *STI);

  const MCExpr *cdulabel =
      MCSymbolRefExpr::create(CallDataUnpackerLabel,MMI->getContext());

  OutStreamer->EmitInstruction(MCInstBuilder(EVM::PUSH2).addExpr(cdulabel), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::JUMPI), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::PUSH1).addImm(0x00), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::DUP1), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::REVERT), *STI);
}

void EVMAsmPrinter::emitShortCalldataCheck() const {
  OutStreamer->AddComment("short call data check");
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::PUSH1).addImm(0x04), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::CALLDATASIZE), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::LT), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::PUSH2).addImm(0x0056), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::JUMPI), *STI);
}

void EVMAsmPrinter::emitRetrieveConstructorParameters() const {
  // this reads 
  OutStreamer->AddComment("Retrieve constructor parameters");
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::JUMPDEST), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::POP), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::PUSH1).addImm(0x40), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::MLOAD), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::PUSH1).addImm(0x20), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::DUP1), *STI);

  // this PUSH2 should read in the beginning of data section (data section is
  // after text section) and in data section we store contract operands
  // TODO:
  
  // TODO: enable PUSH2
  //OutStreamer->AddComment("Parameter");
  //MCExpr* params; // TODO
  //OutStreamer->EmitInstruction(MCInstBuilder(EVM::PUSH2).addExpr(params), *STI);

  OutStreamer->EmitInstruction(MCInstBuilder(EVM::DUP4), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::CODECOPY), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::DUP2), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::ADD), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::PUSH1).addImm(0x40), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::SWAP1), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::DUP2), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::MSTORE), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::SWAP1), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::MLOAD), *STI);
}

void EVMAsmPrinter::emitConstructorBody() const {
  OutStreamer->AddComment("Constructor body");
  // TODO: fill in Constructor Body
  // we might want to look for the constructor body in the function list. 
}

void EVMAsmPrinter::emitFunctionSelector(Module &M) {
  genearteFunctionBodyLabels(M);

  OutStreamer->AddComment("Function Selector");
  // extract first 4 bytes of calldata
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::PUSH4).addImm(0xffffffff), *STI);
  ConstantInt *cimm = ConstantInt::get(
      M.getContext(), APInt(29 * 8, "10000000000000000000000000000", 16));
  OutStreamer->EmitInstruction(
      MCInstBuilder(EVM::PUSH29).addOperand(MCOperand::createCImm(cimm)), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::PUSH1).addImm(0x00), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::CALLDATALOAD), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::DIV), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::AND), *STI);

  // Try to match function name
  unsigned index = 0;
  for (const auto &F : M) {
    if (index != 0) {
      OutStreamer->EmitInstruction(MCInstBuilder(EVM::DUP1), *STI);
    }

    // TODO: enable signature
    //unsigned signature; // TODO
    //OutStreamer->EmitInstruction(MCInstBuilder(EVM::PUSH4).addImm(signature), *STI);

    OutStreamer->EmitInstruction(MCInstBuilder(EVM::DUP2), *STI);
    OutStreamer->EmitInstruction(MCInstBuilder(EVM::EQ), *STI);

    // create a symbol for each function wrapper
    MCSymbol *funcWrapperLabel =
      MMI->getContext().getOrCreateSymbol(F.getName() + "_wrapper");
    const MCExpr* funcWrapperLabelExpr = 
      MCSymbolRefExpr::create(funcWrapperLabel, MMI->getContext());

    this->funcWrapperMap.insert(
        std::pair<const Function *, MCSymbol *>(&F, funcWrapperLabel));

    OutStreamer->EmitInstruction(
        MCInstBuilder(EVM::PUSH2).addExpr(funcWrapperLabelExpr), *STI);
    OutStreamer->EmitInstruction(MCInstBuilder(EVM::JUMPI), *STI);

    ++ index;
  }

  // No match
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::JUMPDEST), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::PUSH1).addImm(0x00), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::DUP1), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::REVERT), *STI);
}

void EVMAsmPrinter::emitCopyRuntimeCodeToMemory() const {
  OutStreamer->AddComment("Copy runtime Code to memory");
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::PUSH2).addImm(0x01d1), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::DUP1), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::PUSH2).addImm(0x0046), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::PUSH1).addImm(0x00), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::CODECOPY), *STI);
}

void EVMAsmPrinter::emitReturnRuntimeCode() const {
  OutStreamer->AddComment("Return from runtime code");
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::PUSH1).addImm(0x00), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::RETURN), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::STOP), *STI);
}

void EVMAsmPrinter::emitContractParameters() const {
  OutStreamer->AddComment("Contract parameters");
  // TODO
}

void EVMAsmPrinter::emitCallDataUnpacker(const Function &F,
                                         MCSymbol *CallDataUnpackerLabel) {
  OutStreamer->AddComment("Call data unpacker");
  OutStreamer->EmitLabel(CallDataUnpackerLabel);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::JUMPDEST), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::POP), *STI);

  // Call data unpacker needs to push parameters on to stack
  for (auto &arg : F.args()) {
    // TODO: special handling for addres types (masking out unnecessary bits)
    OutStreamer->EmitInstruction(MCInstBuilder(EVM::PUSH1).addImm(0x04), *STI);
    OutStreamer->EmitInstruction(MCInstBuilder(EVM::CALLDATALOAD), *STI);
  }
  
  MCSymbol *funcBodyLabel = this->funcBodyMap[&F];
  const MCExpr* funcBodyTag =
      MCSymbolRefExpr::create(funcBodyLabel, MMI->getContext());

  OutStreamer->EmitInstruction(MCInstBuilder(EVM::PUSH2).addExpr(funcBodyTag), *STI);
  OutStreamer->EmitInstruction(MCInstBuilder(EVM::JUMP), *STI);
}

void EVMAsmPrinter::emitFunctionWrapper(const Function &F) {
  OutStreamer->AddComment("Function wrapper(s)");

  MCSymbol *funcWrapperLabel = this->funcWrapperMap[&F];
  OutStreamer->EmitLabel(funcWrapperLabel);

  // This is used for inner jumping (between nonpayable check and unpacker)
  MCSymbol *S =
      MMI->getContext().getOrCreateSymbol(F.getName() + "_calldataunpacker");

  emitNonPayableCheck(F, S);
  emitCallDataUnpacker(F, S);
}

void EVMAsmPrinter::EmitStartOfAsmFile(Module &M) {
  STI = std::unique_ptr<MCSubtargetInfo>(TM.getTarget().createMCSubtargetInfo(
      TM.getTargetTriple().str(), TM.getTargetCPU(),
      TM.getTargetFeatureString()));
  //AsmPrinter::EmitStartOfAsmFile(M);
  //return;
  // Emit the skeleton of the asm file in text section.
  OutStreamer->SwitchSection(getObjFileLowering().getTextSection());

  emitFreeMemoryPointer();

  //emitNonPayableCheck();
  
  emitRetrieveConstructorParameters();

  emitConstructorBody();

  emitCopyRuntimeCodeToMemory();

  emitReturnRuntimeCode();

  emitFunctionSelector(M);

  for (const auto &F : M) {
    emitFunctionWrapper(F);
  }
}

//void EVMAsmPrinter::EmitEndOfAsmFile(Module &M) { }

void EVMAsmPrinter::EmitInstruction(const MachineInstr *MI) {
  EVMMCInstLower MCInstLowering(OutContext, *this);
  MCInst TmpInst;
  MCInstLowering.Lower(MI, TmpInst);
  EmitToStreamer(*OutStreamer, TmpInst);
}

void EVMAsmPrinter::printOperand(const MachineInstr *MI, unsigned OpNo,
                                 raw_ostream &OS) {
  const MachineOperand &MO = MI->getOperand(OpNo);

  switch (MO.getType()) {
  case MachineOperand::MO_Register:
    break;
  case MachineOperand::MO_Immediate:
    OS << MO.getImm();
    break;
  case MachineOperand::MO_CImmediate:
    OS << MO.getCImm();
    break;
  case MachineOperand::MO_MachineBasicBlock:
    OS << *MO.getMBB()->getSymbol();
    break;
  case MachineOperand::MO_BlockAddress: {
    MCSymbol *Sym = GetBlockAddressSymbol(MO.getBlockAddress());
    Sym->print(OS, MAI);
    break;
  }
  default:
    llvm_unreachable("Not implemented yet!");
  }
}

bool EVMAsmPrinter::PrintAsmOperand(const MachineInstr *MI, unsigned OpNo,
                                    const char *ExtraCode, raw_ostream &OS) {
  printOperand(MI, OpNo, OS);
  return true;
}

bool EVMAsmPrinter::PrintAsmMemoryOperand(const MachineInstr *MI,
                                            unsigned OpNo,
                                            const char *ExtraCode,
                                            raw_ostream &OS) {

  return AsmPrinter::PrintAsmMemoryOperand(MI, OpNo, ExtraCode, OS);
}

// Force static initialization.
extern "C" void LLVMInitializeEVMAsmPrinter() {
  RegisterAsmPrinter<EVMAsmPrinter> Y(getTheEVMTarget());
}
