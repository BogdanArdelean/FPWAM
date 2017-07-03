#include <iostream>
#include "FPWAM/Instruction.h"

#include "Wam2FPWAM/wam2FPWAM.h"


#include "FPWAM/CodeContext.h"
#include "FPWAM/GPLCBridge.h"

int main(int argc, char *argv[])
{
    FPWAM::CodeContext codeCtx;
    codeCtx.m_backupConstantNr = 100;

    setCodeContext(&codeCtx);
    parse(argc, argv);

}