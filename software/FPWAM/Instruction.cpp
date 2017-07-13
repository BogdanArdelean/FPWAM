//
// Created by Bogdan  Ardelean on 7/2/17.
//

#include "Instruction.h"


using namespace FPWAM;

void Instruction::set_label(int32_t m_label)
{
    Instruction::m_label = m_label;
}

void Instruction::set_functor(std::string& m_functor)
{
    Instruction::m_functor = m_functor;
}

void Instruction::set_instructionType(InstructionType m_instructionType)
{
    Instruction::m_instructionType = m_instructionType;
    compose();
}

void Instruction::set_reg1(int8_t m_reg1)
{
    Instruction::m_reg1 = m_reg1;
    compose();
}

void Instruction::set_reg2(int8_t m_reg2)
{
    Instruction::m_reg2 = m_reg2;
    compose();
}

void Instruction::set_constant(int32_t m_constant)
{
    Instruction::m_constant = m_constant;
    compose();
}

void Instruction::set_instruction(uint32_t m_instruction)
{
    Instruction::m_instruction = m_instruction;
    compose();
}

std::string Instruction::to_string()
{
    static int32_t separator[36];
    separator[34 - kInstructionTypeWidth] = 1;
    separator[kRegWidth] = 1;
    separator[kWamWordWidth+1] = 1;

    char str[36];
    str[35] = 0;
    int32_t instrI = 0;
    for(int32_t i = 0; i < 36; ++i)
    {
        if(!separator[i])
            str[34 - i] = ((m_instruction & (1 << instrI++)) ? '1' : '0');
        else
            str[34 - i] = '_';
    }

    return std::string(str);
}

void Instruction::compose()
{
     m_instruction = ((uint32_t)m_instructionType << (32 - kInstructionTypeWidth))
                     | ((uint32_t)m_reg1 << kWamWordWidth)
                     | ((uint32_t)m_reg2) | ((uint32_t)m_constant & ((1 << kWamWordWidth)-1));
}

Instruction::Instruction(InstructionType m_instructionType, uint16_t number)
: m_instructionType(m_instructionType)
, m_number(number)
, m_constant(0)
, m_reg1(0)
, m_reg2(0)
, m_instruction(0)
, m_label(-1)
{
    compose();
}
