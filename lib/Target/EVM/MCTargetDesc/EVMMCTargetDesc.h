//===-- EVMMCTargetDesc.h - EVM Target Descriptions -------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file provides EVM specific target descriptions.
//
//===----------------------------------------------------------------------===//

#ifndef LLVM_LIB_TARGET_EVM_MCTARGETDESC_EVMMCTARGETDESC_H
#define LLVM_LIB_TARGET_EVM_MCTARGETDESC_EVMMCTARGETDESC_H

#include "llvm/Config/config.h"
#include "llvm/Support/DataTypes.h"
#include "llvm/MC/MCStreamer.h"
#include "llvm/MC/MCSubtargetInfo.h"
#include "llvm/MC/MCObjectWriter.h"

#include <memory>

namespace llvm {
class MCAsmBackend;
class MCCodeEmitter;
class MCContext;
class MCInstrInfo;
class MCObjectTargetWriter;
class MCRegisterInfo;
class MCSubtargetInfo;
class MCTargetOptions;
class StringRef;
class Target;
class Triple;
class raw_ostream;
class raw_pwrite_stream;
class MCTargetStreamer;

Target &getTheEVMTarget();

MCCodeEmitter *createEVMMCCodeEmitter(const MCInstrInfo &MCII,
                                      const MCRegisterInfo &MRI,
                                      MCContext &Ctx);
MCCodeEmitter *createEVMbeMCCodeEmitter(const MCInstrInfo &MCII,
                                        const MCRegisterInfo &MRI,
                                        MCContext &Ctx);

MCAsmBackend *createEVMAsmBackend(const Target &T, const MCSubtargetInfo &STI,
                                  const MCRegisterInfo &MRI,
                                  const MCTargetOptions &Options);

std::unique_ptr<MCObjectTargetWriter> createEVMELFObjectWriter(uint8_t OSABI);
std::unique_ptr<MCObjectTargetWriter> createEVMBinaryObjectWriter();
std::unique_ptr<MCObjectTargetWriter> createEVMObjectWriter();

MCTargetStreamer *
createEVMObjectTargetStreamer(MCStreamer &S, const MCSubtargetInfo &STI);
}

// Defines symbolic names for EVM registers.  This defines a mapping from
// register name to register number.
//
#define GET_REGINFO_ENUM
#include "EVMGenRegisterInfo.inc"

// Defines symbolic names for the EVM instructions.
//
#define GET_INSTRINFO_ENUM
#include "EVMGenInstrInfo.inc"

#define GET_SUBTARGETINFO_ENUM
#include "EVMGenSubtargetInfo.inc"

#endif
