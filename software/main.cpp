#include <iostream>
#include "FPWAM/Instruction.h"

#include "Wam2FPWAM/wam2FPWAM.h"


#include "FPWAM/CodeContext.h"
#include "FPWAM/GPLCBridge.h"

int main(int argc, char *argv[])
{
    FPWAM::CodeContext codeCtx;
    setCodeContext(&codeCtx);
    parse(argc, argv);
    codeCtx.resolve_instructions();

    std::vector<FPWAM::Instruction> instr;
    codeCtx.get_instructions(instr);

    std::cout << instr.size() << std::endl;
    for(auto& i : instr)
    {
        std::cout << ',' << "B\"" << i.to_string() << '"' << std::endl;
    }

    return 0;
}

//0: 0 000000_000000000_0000000000000_0000
//1: 1 011110_000000000_0000000000000_0000
//2: 2 011100_000000000_0000000000110_0001
//3: 3 011100_000000000_0000000000111_0001
//4: 4 011111_000000000_0000000000000_0000
//5: 5 011100_000000000_0000000001010_0001
//6: 6 001110_000000000_0000000000000_1001
//7: 7 010101_000000011_1000000000000_0001
//8: 8 001011_000000000_0000000000000_0000
//9: 9 010000_000000000_0000000000000_0000
//10: 10 000101_000000010_0000000000010_0001
//11: 11 010111_000000001_1000000000000_0010
//12: 12 011111_000000000_0000000000000_0000
//13: 13 000000_000000000_0000000000000_0000
//14: 14 010011_000000011_1000000000000_0001
//15: 15 011100_000000000_0000000000001_0001