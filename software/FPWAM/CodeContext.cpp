//
// Created by Bogdan  Ardelean on 7/2/17.
//

#include "CodeContext.h"
#include <iostream>
using namespace FPWAM;

#define FOUND(X, Y) X.find(Y) != X.end()

void FPWAM::CodeContext::predicate(const std::string name, const int8_t arity)
{
    m_currentInstruction++; // LEAVE ONE EMPTY INSTRUCTION
    int32_t number = FOUND(m_predicateNameToNr, name) ? m_predicateNameToNr[name] : m_predicateNr++;
    std::string fullName = name + "/" + std::to_string(arity);
    int32_t predicateValue = Predicate::composeValue(number, arity);

    if(FOUND(m_predicateValueToIndex, predicateValue))
    {
        m_currentPredicate = &m_facts[m_predicateValueToIndex[predicateValue]];
        m_currentPredicate->set_startInstrNumber(m_currentInstruction);
        return;
    }

    add_predicate(name, arity, number, predicateValue);
    m_currentPredicate = &m_facts.back();
}

void CodeContext::add_predicate(const std::string &name, const int8_t arity, int32_t number, int32_t predicateValue)
{
    m_predicateNameToNr[name] = number;
    m_facts.push_back(Predicate(name, arity, predicateValue, m_currentInstruction));
    m_predicateValueToIndex[predicateValue] = m_facts.size() - 1;
}

void FPWAM::CodeContext::get_value(const int8_t XYn, const char c, const int8_t Ai)
{
    Instruction instruction(i_get_value_t, m_currentInstruction++);
    instruction.set_reg1(c =='Y' ? stackVariable(XYn) : XYn);
    instruction.set_reg2(Ai);
    m_currentPredicate->add_instruction(instruction);
}

void FPWAM::CodeContext::get_constant(const std::string atom, const int8_t Ai)
{
    Instruction instruction(i_get_constant_t, m_currentInstruction++);
    instruction.set_constant(Ai);
    m_currentPredicate->add_instruction(instruction);
}

void FPWAM::CodeContext::get_list(const int8_t Ai)
{
    Instruction instruction(i_get_list_t, m_currentInstruction++);
    instruction.set_reg1(Ai);
    m_currentPredicate->add_instruction(instruction);
}

void FPWAM::CodeContext::get_structure(const std::string name, const int8_t arity, const int8_t Ai)
{
    Instruction instruction(i_get_structure_t, m_currentInstruction++);
    int32_t number = FOUND(m_predicateNameToNr, name) ? m_predicateNameToNr[name] : m_predicateNr++;
    std::string fullName = name + "/" + std::to_string(arity);
    int32_t predicateValue = Predicate::composeValue(number, arity);
    if((FOUND(m_predicateValueToIndex, predicateValue)))
    {
        int32_t index = m_predicateValueToIndex[predicateValue];
        instruction.set_constant(m_facts[index].get_value());
        m_currentPredicate->add_instruction(instruction);
        return;
    }

    add_predicate(name, arity, number, predicateValue);
    instruction.set_constant(predicateValue);
    instruction.set_reg1(Ai);
    m_currentPredicate->add_instruction(instruction);
}

void FPWAM::CodeContext::put_variableX(const int8_t Xn, const int8_t Ai)
{
    Instruction instruction(i_put_variable_X_t, m_currentInstruction++);
    instruction.set_reg1(Xn);
    instruction.set_reg2(Ai);
    m_currentPredicate->add_instruction(instruction);
}

void FPWAM::CodeContext::put_variableY(const int8_t Yn, const int8_t Ai)
{
    Instruction instruction(i_put_variable_Y_t, m_currentInstruction++);
    instruction.set_reg1(stackVariable(Yn));
    instruction.set_reg2(Ai);
    m_currentPredicate->add_instruction(instruction);
}

void FPWAM::CodeContext::put_value(const int8_t XYn, const char c, const int8_t Ai)
{
    Instruction instruction(i_put_value_t, m_currentInstruction++);
    instruction.set_reg1(c =='Y' ? stackVariable(XYn) : XYn);
    instruction.set_reg2(Ai);
    m_currentPredicate->add_instruction(instruction);
}

void FPWAM::CodeContext::put_unsafe_value(const int8_t Yn, const int8_t Ai)
{
    Instruction instruction(i_put_unsafe_value_t, m_currentInstruction++);
    instruction.set_reg1(stackVariable(Yn));;
    instruction.set_reg2(Ai);
    m_currentPredicate->add_instruction(instruction);
}

void FPWAM::CodeContext::put_constant(const std::string name, const int8_t Ai)
{
    Instruction instruction(i_put_constant_t, m_currentInstruction++);

    bool found;
    int32_t constant = (found = FOUND(m_constantNameToValue, name)) ? m_constantNameToValue[name] : fpwam_word(tag_int_t, m_constantNr++);
    if(!found)
        m_constantNameToValue[name] = constant;

    instruction.set_reg1(Ai);
    instruction.set_constant(constant);
    m_currentPredicate->add_instruction(instruction);
}

void FPWAM::CodeContext::put_list(const int8_t Ai)
{
    Instruction instruction(i_put_list_t, m_currentInstruction++);
    instruction.set_reg1(Ai);
    m_currentPredicate->add_instruction(instruction);
}

void FPWAM::CodeContext::put_structure(const std::string name, const int8_t arity, const int8_t Ai)
{
    Instruction instruction(i_put_structure_t, m_currentInstruction++);
    int32_t number = FOUND(m_predicateNameToNr, name) ? m_predicateNameToNr[name] : m_predicateNr++;
    std::string fullName = name + "/" + std::to_string(arity);
    int32_t predicateValue = Predicate::composeValue(number, arity);
    if((FOUND(m_predicateValueToIndex, predicateValue)))
    {
        int32_t index = m_predicateValueToIndex[predicateValue];
        instruction.set_constant(m_facts[index].get_value());
        m_currentPredicate->add_instruction(instruction);
        return;
    }

    add_predicate(name, arity, number, predicateValue);
    instruction.set_constant(predicateValue);
    instruction.set_reg1(Ai);
    m_currentPredicate->add_instruction(instruction);
}

void FPWAM::CodeContext::unify_variable(const int8_t XYn, const char c)
{
    Instruction instruction(i_unify_variable_t, m_currentInstruction++);
    instruction.set_reg1(c =='Y' ? stackVariable(XYn) : XYn);
    m_currentPredicate->add_instruction(instruction);
}

void FPWAM::CodeContext::unify_void(const int8_t n)
{
    Instruction instruction(i_unify_void, m_currentInstruction++);
    instruction.set_constant(n);
    m_currentPredicate->add_instruction(instruction);
}

void FPWAM::CodeContext::unify_value(const int8_t XYn, const char c)
{
    Instruction instruction(i_unify_value_t, m_currentInstruction++);
    instruction.set_reg1(c =='Y' ? stackVariable(XYn) : XYn);
    m_currentPredicate->add_instruction(instruction);
}

void FPWAM::CodeContext::unify_local_value(const int8_t XYn, const char c)
{
    Instruction instruction(i_unify_local_value_t, m_currentInstruction++);
    instruction.set_reg1(c =='Y' ? stackVariable(XYn) : XYn);
    m_currentPredicate->add_instruction(instruction);
}

void FPWAM::CodeContext::unify_constant(const std::string name)
{
    bool found;
    Instruction instruction(i_unify_constant_t, m_currentInstruction++);
    int32_t constant = (found = FOUND(m_constantNameToValue, name)) ? m_constantNameToValue[name] : fpwam_word(tag_int_t, m_constantNr++);

    if(!found)
        m_constantNameToValue[name] = constant;

    instruction.set_constant(constant);
    m_currentPredicate->add_instruction(instruction);
}

void FPWAM::CodeContext::unify_list()
{
    std::cerr << "Error UNIFY LIST NOT SUPPORTED" << std::endl;
    exit(-1);
}

void FPWAM::CodeContext::unify_structure(const std::string name, const int8_t arity)
{
    Instruction instruction(i_put_structure_t, m_currentInstruction++);
    int32_t number = FOUND(m_predicateNameToNr, name) ? m_predicateNameToNr[name] : m_predicateNr++;
    std::string fullName = name + "/" + std::to_string(arity);
    int32_t predicateValue = Predicate::composeValue(number, arity);
    if((FOUND(m_predicateValueToIndex, predicateValue)))
    {
        int32_t index = m_predicateValueToIndex[predicateValue];
        instruction.set_constant(m_facts[index].get_value());
        m_currentPredicate->add_instruction(instruction);
        return;
    }

    add_predicate(name, arity, number, predicateValue);
    instruction.set_constant(predicateValue);
    m_currentPredicate->add_instruction(instruction);
}

void FPWAM::CodeContext::allocate(const int8_t n)
{
    Instruction instruction(i_allocate_t, m_currentInstruction++);
    instruction.set_constant(n);
    m_currentPredicate->add_instruction(instruction);
}

void FPWAM::CodeContext::deallocate()
{
    Instruction instruction(i_deallocate_t, m_currentInstruction++);
    m_currentPredicate->add_instruction(instruction);
}

void FPWAM::CodeContext::call(const std::string name, const int8_t arity)
{
    Instruction instruction(i_call_t, m_currentInstruction++);
    int32_t number = FOUND(m_predicateNameToNr, name) ? m_predicateNameToNr[name] : m_predicateNr++;
    std::string fullName = name + "/" + std::to_string(arity);
    int32_t predicateValue = Predicate::composeValue(number, arity);
    if((FOUND(m_predicateValueToIndex, predicateValue)))
    {
        int32_t index = m_predicateValueToIndex[predicateValue];
        instruction.set_constant(m_facts[index].get_startInstrNumber());
        m_currentPredicate->add_instruction(instruction);
        return;
    }

    add_predicate(name, arity, number, predicateValue);
    instruction.set_functor(fullName);
    m_currentPredicate->add_instruction_unresolved(instruction);
}

void FPWAM::CodeContext::execute(const std::string name, const int8_t arity)
{
    Instruction instruction(i_execute_t, m_currentInstruction++);
    int32_t number = FOUND(m_predicateNameToNr, name) ? m_predicateNameToNr[name] : m_predicateNr++;
    std::string fullName = name + "/" + std::to_string(arity);
    int32_t predicateValue = Predicate::composeValue(number, arity);
    if((FOUND(m_predicateValueToIndex, predicateValue)))
    {
        int32_t index = m_predicateValueToIndex[predicateValue];
        instruction.set_constant(m_facts[index].get_startInstrNumber());
        m_currentPredicate->add_instruction(instruction);
        return;
    }

    add_predicate(name, arity, number, predicateValue);
    instruction.set_functor(fullName);
    m_currentPredicate->add_instruction_unresolved(instruction);
}

void FPWAM::CodeContext::proceed()
{
    Instruction instruction(i_proceed_t, m_currentInstruction++);
    m_currentPredicate->add_instruction(instruction);
}

void FPWAM::CodeContext::fail()
{
    Instruction instruction(i_fail_t, m_currentInstruction++);
    m_currentPredicate->add_instruction(instruction);
}

void FPWAM::CodeContext::label(int32_t l)
{
    m_currentPredicate->add_label(l, m_currentInstruction);
}

void FPWAM::CodeContext::switch_on_term(const int32_t v, const int32_t c, const int32_t l, const int32_t s)
{
    //add switch on term
    {
        Instruction instruction(i_switch_on_term_t, m_currentInstruction++);
        m_currentPredicate->add_instruction(instruction);
    }

    if(v > 0)
    {
        Instruction instruction(i_execute_t, m_currentInstruction++);
        instruction.set_label(v);
        m_currentPredicate->add_instruction_unresolved(instruction);
    }
    else
    {
        Instruction instruction(i_fail_t, m_currentInstruction++);
        m_currentPredicate->add_instruction(instruction);
    }

    if(c > 0)
    {
        Instruction instruction(i_execute_t, m_currentInstruction++);
        instruction.set_label(c);
        m_currentPredicate->add_instruction_unresolved(instruction);
    } else
    {
        Instruction instruction(i_fail_t, m_currentInstruction++);
        m_currentPredicate->add_instruction(instruction);
    }

    if(l > 0)
    {
        Instruction instruction(i_execute_t, m_currentInstruction++);
        instruction.set_label(l);
        m_currentPredicate->add_instruction_unresolved(instruction);
    } else
    {
        Instruction instruction(i_fail_t, m_currentInstruction++);
        m_currentPredicate->add_instruction(instruction);
    }

    if(s > 0)
    {
        Instruction instruction(i_execute_t, m_currentInstruction++);
        instruction.set_label(l);
        m_currentPredicate->add_instruction_unresolved(instruction);
    } else
    {
        Instruction instruction(i_fail_t, m_currentInstruction++);
        m_currentPredicate->add_instruction(instruction);
    }
}

void FPWAM::CodeContext::switch_on_con(std::vector<std::string> &constants, std::vector<int32_t> &labels)
{
    {
        Instruction instruction(i_switch_on_int_str_t, m_currentInstruction++);
        m_currentPredicate->add_instruction_unresolved(instruction);
    }
    {
        Instruction instruction(i_switch_on_int_str_t, m_currentInstruction++);
        m_currentPredicate->add_instruction(instruction);
    }

    std::map<int32_t, int16_t> constantToInstr;
    for(int32_t i = 0; i < constants.size(); ++i)
    {
        std::string& cnst_name = constants[i];
        int32_t label = labels[i];

        bool found;
        int32_t constant = (found = FOUND(m_constantNameToValue, cnst_name)) ? m_constantNameToValue[cnst_name] : fpwam_word(tag_int_t, m_constantNr++);
        if(!found)
            m_constantNameToValue[cnst_name] = constant;


        constantToInstr[constant] = label;
    }

    m_currentPredicate->get_switchValues().push_back(std::map<int32_t, int16_t>());
    m_currentPredicate->get_switchValues().back().swap(constantToInstr);
}

void FPWAM::CodeContext::try_me_else(const int32_t label)
{
    Instruction instruction(i_try_me_else_t, m_currentInstruction++);
    instruction.set_label(label);
    m_currentPredicate->add_instruction_unresolved(instruction);
}

void FPWAM::CodeContext::retry_me_else(const int32_t label)
{
    Instruction instruction(i_retry_me_else_t, m_currentInstruction++);
    instruction.set_label(label);
    m_currentPredicate->add_instruction_unresolved(instruction);
}

void FPWAM::CodeContext::trust_me_else_fail(const int32_t label)
{
    Instruction instruction(i_trust_me_t, m_currentInstruction++);
    instruction.set_label(label);
    m_currentPredicate->add_instruction_unresolved(instruction);
}

void FPWAM::CodeContext::ttry(const int32_t label)
{
    Instruction instruction(i_try_t, m_currentInstruction++);
    instruction.set_label(label);
    m_currentPredicate->add_instruction_unresolved(instruction);
}

void FPWAM::CodeContext::retry(const int32_t label)
{
    Instruction instruction(i_retry_t, m_currentInstruction++);
    instruction.set_label(label);
    m_currentPredicate->add_instruction_unresolved(instruction);
}

void FPWAM::CodeContext::trust(const int32_t label)
{
    Instruction instruction(i_trust_t, m_currentInstruction++);
    instruction.set_label(label);
    m_currentPredicate->add_instruction_unresolved(instruction);
}
