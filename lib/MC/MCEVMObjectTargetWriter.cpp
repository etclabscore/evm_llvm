//===-- MCEVMObjectTargetWriter.cpp - EVM Target Writer Subclass --------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "llvm/MC/MCEVMObjectWriter.h"

using namespace llvm;

MCEVMObjectTargetWriter::MCEVMObjectTargetWriter() {}

// Pin the vtable to this object file
MCEVMObjectTargetWriter::~MCEVMObjectTargetWriter() = default;
