//
// Created by Bogdan  Ardelean on 7/16/17.
//

#include "FPWAMReader.h"
#include "FPWAMDefs.h"

using namespace FPWAM;

FPWAMReader::FPWAMReader(const std::string &portName)
:m_serialWrapper(portName)
{
}

bool FPWAMReader::open()
{
    return m_serialWrapper.open();
}

bool FPWAMReader::read(int32_t variables, std::vector<std::vector<int32_t>> &vars)
{
    vars.resize(variables);
    for(int32_t i = 0; i < variables; ++i)
    {
        read(1, vars[i]);
    }
    return true;
}

void FPWAMReader::read(int32_t variables, std::vector<int32_t> &var)
{
    bool eol = true;
    while(variables || !eol)
    {
        if(eol) --variables;

        int32_t wamWord = m_serialWrapper.read24();
        var.push_back(wamWord);
        switch(getFpwamTag(wamWord))
        {
            case tag_int_t:
                if(wamWord == kNilConstant)
                {
                    eol = true;
                }
                break;
            case tag_str_t:
            {
                uint8_t arity = getFpwamArity(wamWord);
                read(arity, var);
                break;
            }
            case tag_lis_t:
            {
                if (!eol)
                {
                    read(1, var);
                    break;
                }
                eol = false;
                break;
            }
            default:
                break;
        }
    }
}
