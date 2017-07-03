//
// Created by Bogdan  Ardelean on 7/2/17.
//

#include "Predicate.h"
using namespace FPWAM;

int32_t Predicate::composeValue(int32_t number, int8_t arity)
{
    return ((int32_t)tag_str_t << 16) | (number << kRegWidth | arity);
}

Predicate::Predicate(const std::string &m_name, int8_t m_arity, int32_t m_value, uint16_t instrNumber) : m_name(m_name), m_arity(m_arity),
                                                                                   m_value(m_value), m_startInstrNumber(instrNumber)
{}

void Predicate::add_instruction(Instruction &instruction)
{
   this->m_instructions.push_back(instruction);
}

void Predicate::add_instruction_unresolved(Instruction &instruction)
{
    //HACK
    instruction.set_constant(this->m_instructions.size()+1);
    this->add_instruction(instruction);
    this->m_unresolvedInstr.push_back(this->m_instructions.size()-1);
}

void Predicate::add_label(int32_t label, uint16_t currInstr)
{
    m_labelToInstruction[label] = currInstr;
}

