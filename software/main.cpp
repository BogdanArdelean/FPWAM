#include <iostream>
#include <fstream>
#include <unistd.h>
#include "FPWAM/Instruction.h"

#include "Wam2FPWAM/wam2FPWAM.h"


#include "FPWAM/CodeContext.h"
#include "FPWAM/GPLCBridge.h"
#include "FPWAM/FPWAMBridge.h"

#define die(e) do { fprintf(stderr, "%s\n", e); exit(EXIT_FAILURE); } while (0);


int main(int argc, char *argv[])
{
    FPWAM::CodeContext codeCtx;
    setCodeContext(&codeCtx);
    parse(argc, argv);
    codeCtx.resolve_instructions();
    std::vector<FPWAM::Instruction> instr;
    codeCtx.get_instructions(instr);

    FPWAM::FPWAMBridge reader("/dev/ttyUSB2");
    if(reader.open())
    {
        std::cout<<"Opened" << std::endl;

        reader.sendProgram(instr);
        
        std::vector<std::vector<int32_t>> vars;
        reader.read(2, vars);

        for(const auto& var : vars)
        {
	    std::cout<<"Res: ";
            for(const int32_t& val : var)
            {
                switch(FPWAM::getFpwamTag(val))
                {
                    case FPWAM::tag_int_t:
                        if(val == FPWAM::kNilConstant)
                        {
                            std::cout<<"]";
                        }else
                        std::cout<<codeCtx.m_constantValueToName[val] << ", ";
                        break;
                    case FPWAM::tag_lis_t:
                        std::cout<<"[";
                        break;
                    case FPWAM::tag_str_t:
                        std::cout<<codeCtx.m_predicateValueToName[val] << "(";
                        break;
                    default:
                        std::cout << " WHA?";
                        break;
                }
            }
            std::cout << std::endl;
        }
    }else
    {
      std::cout << "FUUUCKING SHIT" << std::endl;
    }


//    std::vector<FPWAM::Instruction> instr;
//    codeCtx.get_instructions(instr);


//    std::fstream f("code.out", std::ios::out);
//    f << instr.size() << std::endl;
//    for(auto& i : instr)
//   {
//        f << ',' << "B\"" << i.to_string() << '"' << '\n';
//    }
//    f.close();
//
//    if(fork()==0)
//    {
//        chdir("/Users/bogdana/Personal/licenta/FPWAM/software");
//        execlp("gplc", "/Users/bogdana/Personal/licenta/FPWAM/software/test.pl");
//        execlp("gplc", "gplc", "/Users/bogdana/Personal/licenta/FPWAM/software/test.pl");
//        die("execl");
//    }
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
