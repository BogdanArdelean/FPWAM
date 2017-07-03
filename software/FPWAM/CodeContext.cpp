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
        m_current_predicate_index = m_predicateValueToIndex[predicateValue];
        getCurrentPredicate().set_startInstrNumber(m_currentInstruction);
        return;
    }

    add_predicate(name, arity, number, predicateValue);
    m_current_predicate_index = m_facts.size()-1;
}

void FPWAM::CodeContext::add_predicate(const std::string &name, const int8_t arity, int32_t number, int32_t predicateValue)
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
    getCurrentPredicate().add_instruction(instruction);
}

void CodeContext::get_variable(const int8_t XYn, const char c, const int8_t Ai)
{
    Instruction instruction(i_get_variable_t, m_currentInstruction++);
    instruction.set_reg1(c =='Y' ? stackVariable(XYn) : XYn);
    instruction.set_reg2(Ai);
    getCurrentPredicate().add_instruction(instruction);
}

void FPWAM::CodeContext::get_constant(const std::string atom, const int8_t Ai)
{
    Instruction instruction(i_get_constant_t, m_currentInstruction++);
    bool found;
    int32_t constant = (found = FOUND(m_constantNameToValue, atom)) ? m_constantNameToValue[atom] : fpwam_word(tag_int_t, m_constantNr++);

    if(!found)
        m_constantNameToValue[atom] = constant;

    instruction.set_reg1(Ai);
    instruction.set_constant(constant);
    getCurrentPredicate().add_instruction(instruction);
}

void FPWAM::CodeContext::get_list(const int8_t Ai)
{
    Instruction instruction(i_get_list_t, m_currentInstruction++);
    instruction.set_reg1(Ai);
    getCurrentPredicate().add_instruction(instruction);
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
        getCurrentPredicate().add_instruction(instruction);
        return;
    }

    add_predicate(name, arity, number, predicateValue);
    instruction.set_constant(predicateValue);
    instruction.set_reg1(Ai);
    getCurrentPredicate().add_instruction(instruction);
}

void FPWAM::CodeContext::put_variableX(const int8_t Xn, const int8_t Ai)
{
    Instruction instruction(i_put_variable_X_t, m_currentInstruction++);
    instruction.set_reg1(Xn);
    instruction.set_reg2(Ai);
    getCurrentPredicate().add_instruction(instruction);
}

void FPWAM::CodeContext::put_variableY(const int8_t Yn, const int8_t Ai)
{
    Instruction instruction(i_put_variable_Y_t, m_currentInstruction++);
    instruction.set_reg1(stackVariable(Yn));
    instruction.set_reg2(Ai);
    getCurrentPredicate().add_instruction(instruction);
}

void FPWAM::CodeContext::put_value(const int8_t XYn, const char c, const int8_t Ai)
{
    Instruction instruction(i_put_value_t, m_currentInstruction++);
    instruction.set_reg1(c =='Y' ? stackVariable(XYn) : XYn);
    instruction.set_reg2(Ai);
    getCurrentPredicate().add_instruction(instruction);
}

void FPWAM::CodeContext::put_unsafe_value(const int8_t Yn, const int8_t Ai)
{
    Instruction instruction(i_put_unsafe_value_t, m_currentInstruction++);
    instruction.set_reg1(stackVariable(Yn));;
    instruction.set_reg2(Ai);
    getCurrentPredicate().add_instruction(instruction);
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
    getCurrentPredicate().add_instruction(instruction);
}

void FPWAM::CodeContext::put_list(const int8_t Ai)
{
    Instruction instruction(i_put_list_t, m_currentInstruction++);
    instruction.set_reg1(Ai);
    getCurrentPredicate().add_instruction(instruction);
}

void FPWAM::CodeContext::put_structure(const std::string name, const int8_t arity, const int8_t Ai)
{
    Instruction instruction(i_put_structure_t, m_currentInstruction++);
    int32_t number = FOUND(m_predicateNameToNr, name) ? m_predicateNameToNr[name] : m_predicateNr++;
    std::string fullName = name + "/" + std::to_string(arity);
    int32_t predicateValue = Predicate::composeValue(number, arity);
    instruction.set_reg1(Ai);
    if((FOUND(m_predicateValueToIndex, predicateValue)))
    {
        int32_t index = m_predicateValueToIndex[predicateValue];
        instruction.set_constant(m_facts[index].get_value());
        getCurrentPredicate().add_instruction(instruction);
        return;
    }

    add_predicate(name, arity, number, predicateValue);
    instruction.set_constant(predicateValue);
    getCurrentPredicate().add_instruction(instruction);
}

void FPWAM::CodeContext::unify_variable(const int8_t XYn, const char c)
{
    Instruction instruction(i_unify_variable_t, m_currentInstruction++);
    instruction.set_reg1(c =='Y' ? stackVariable(XYn) : XYn);
    getCurrentPredicate().add_instruction(instruction);
}

void FPWAM::CodeContext::unify_void(const int8_t n)
{
    Instruction instruction(i_unify_void, m_currentInstruction++);
    instruction.set_constant(n);
    getCurrentPredicate().add_instruction(instruction);
}

void FPWAM::CodeContext::unify_value(const int8_t XYn, const char c)
{
    Instruction instruction(i_unify_value_t, m_currentInstruction++);
    instruction.set_reg1(c =='Y' ? stackVariable(XYn) : XYn);
    getCurrentPredicate().add_instruction(instruction);
}

void FPWAM::CodeContext::unify_local_value(const int8_t XYn, const char c)
{
    Instruction instruction(i_unify_local_value_t, m_currentInstruction++);
    instruction.set_reg1(c =='Y' ? stackVariable(XYn) : XYn);
    getCurrentPredicate().add_instruction(instruction);
}

void FPWAM::CodeContext::unify_constant(const std::string name)
{
    bool found;
    Instruction instruction(i_unify_constant_t, m_currentInstruction++);
    int32_t constant = (found = FOUND(m_constantNameToValue, name)) ? m_constantNameToValue[name] : fpwam_word(tag_int_t, m_constantNr++);

    if(!found)
        m_constantNameToValue[name] = constant;

    instruction.set_constant(constant);
    getCurrentPredicate().add_instruction(instruction);
}

void FPWAM::CodeContext::unify_list()
{
    Instruction instruction(i_unify_list_t, m_currentInstruction++);
    getCurrentPredicate().add_instruction(instruction);
}

void FPWAM::CodeContext::unify_structure(const std::string name, const int8_t arity)
{
    Instruction instruction(i_unify_structure_t, m_currentInstruction++);
    int32_t number = FOUND(m_predicateNameToNr, name) ? m_predicateNameToNr[name] : m_predicateNr++;
    std::string fullName = name + "/" + std::to_string(arity);
    int32_t predicateValue = Predicate::composeValue(number, arity);
    if((FOUND(m_predicateValueToIndex, predicateValue)))
    {
        int32_t index = m_predicateValueToIndex[predicateValue];
        instruction.set_constant(m_facts[index].get_value());
        getCurrentPredicate().add_instruction(instruction);
        return;
    }

    add_predicate(name, arity, number, predicateValue);
    instruction.set_constant(predicateValue);
    getCurrentPredicate().add_instruction(instruction);
}

void FPWAM::CodeContext::allocate(const int8_t n)
{
    Instruction instruction(i_allocate_t, m_currentInstruction++);
    instruction.set_constant(n);
    getCurrentPredicate().add_instruction(instruction);
}

void FPWAM::CodeContext::deallocate()
{
    Instruction instruction(i_deallocate_t, m_currentInstruction++);
    getCurrentPredicate().add_instruction(instruction);
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
        instruction.set_constant(fpwam_call_execute(m_facts[index].get_startInstrNumber(), m_facts[index].get_arity()));
        getCurrentPredicate().add_instruction(instruction);
        return;
    }

    add_predicate(name, arity, number, predicateValue);
    instruction.set_functor(fullName);
    getCurrentPredicate().add_instruction_unresolved(instruction);
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
        instruction.set_constant(fpwam_call_execute(m_facts[index].get_startInstrNumber(), m_facts[index].get_arity()));
        getCurrentPredicate().add_instruction(instruction);
        return;
    }

    add_predicate(name, arity, number, predicateValue);
    instruction.set_functor(fullName);
    getCurrentPredicate().add_instruction_unresolved(instruction);
}

void FPWAM::CodeContext::proceed()
{
    Instruction instruction(i_proceed_t, m_currentInstruction++);
    getCurrentPredicate().add_instruction(instruction);
}

void FPWAM::CodeContext::fail()
{
    Instruction instruction(i_fail_t, m_currentInstruction++);
    getCurrentPredicate().add_instruction(instruction);
}

void FPWAM::CodeContext::label(int32_t l)
{
    getCurrentPredicate().add_label(l, m_currentInstruction);
}

void FPWAM::CodeContext::switch_on_term(const int32_t v, const int32_t c, const int32_t l, const int32_t s)
{
    //add switch on term
    {
        Instruction instruction(i_switch_on_term_t, m_currentInstruction++);
        getCurrentPredicate().add_instruction(instruction);
    }

    if(v > 0)
    {
        Instruction instruction(i_execute_t, m_currentInstruction++);
        instruction.set_label(v);
        getCurrentPredicate().add_instruction_unresolved(instruction);
    }
    else
    {
        Instruction instruction(i_fail_t, m_currentInstruction++);
        getCurrentPredicate().add_instruction(instruction);
    }

    if(c > 0)
    {
        Instruction instruction(i_execute_t, m_currentInstruction++);
        instruction.set_label(c);
        getCurrentPredicate().add_instruction_unresolved(instruction);
    } else
    {
        Instruction instruction(i_fail_t, m_currentInstruction++);
        getCurrentPredicate().add_instruction(instruction);
    }

    if(l > 0)
    {
        Instruction instruction(i_execute_t, m_currentInstruction++);
        instruction.set_label(l);
        getCurrentPredicate().add_instruction_unresolved(instruction);
    } else
    {
        Instruction instruction(i_fail_t, m_currentInstruction++);
        getCurrentPredicate().add_instruction(instruction);
    }

    if(s > 0)
    {
        Instruction instruction(i_execute_t, m_currentInstruction++);
        instruction.set_label(s);
        getCurrentPredicate().add_instruction_unresolved(instruction);
    } else
    {
        Instruction instruction(i_fail_t, m_currentInstruction++);
        getCurrentPredicate().add_instruction(instruction);
    }
}

void FPWAM::CodeContext::switch_on_con(std::vector<std::string> &constants, std::vector<int32_t> &labels)
{
    {
        Instruction instruction(i_switch_on_int_str_t, m_currentInstruction++);
        getCurrentPredicate().add_instruction_unresolved(instruction);
    }
    {
        Instruction instruction(i_switch_on_int_str_t, m_currentInstruction++);
        getCurrentPredicate().add_instruction(instruction);
    }

    std::map<int32_t, uint16_t> constantToInstr;
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

    getCurrentPredicate().get_switchValues().push_back(std::map<int32_t, uint16_t>());
    getCurrentPredicate().get_switchValues().back().swap(constantToInstr);
}

void CodeContext::switch_on_str(std::vector<std::string> &str, std::vector<int8_t> &arity, std::vector<int32_t> &labels)
{
    {
        Instruction instruction(i_switch_on_int_str_t, m_currentInstruction++);
        getCurrentPredicate().add_instruction_unresolved(instruction);
    }
    {
        Instruction instruction(i_switch_on_int_str_t, m_currentInstruction++);
        getCurrentPredicate().add_instruction(instruction);
    }

    std::map<int32_t, uint16_t> strToInstr;
    for(int32_t i = 0; i < str.size(); ++i)
    {
        std::string& strName = str[i];
        int32_t label = labels[i];
        int8_t ar = arity[i];

        int32_t number = FOUND(m_predicateNameToNr, strName) ? m_predicateNameToNr[strName] : m_predicateNr++;
        std::string fullName = strName + "/" + std::to_string(ar);
        int32_t predicateValue = Predicate::composeValue(number, ar);
        if(!(FOUND(m_predicateValueToIndex, predicateValue)))
        {
            add_predicate(strName, ar, number, predicateValue);
        }

        strToInstr[predicateValue] = label;
    }

    getCurrentPredicate().get_switchValues().push_back(std::map<int32_t, uint16_t>());
    getCurrentPredicate().get_switchValues().back().swap(strToInstr);
}

void FPWAM::CodeContext::try_me_else(const int32_t label)
{
    Instruction instruction(i_try_me_else_t, m_currentInstruction++);
    instruction.set_label(label);
    getCurrentPredicate().add_instruction_unresolved(instruction);
}

void FPWAM::CodeContext::retry_me_else(const int32_t label)
{
    Instruction instruction(i_retry_me_else_t, m_currentInstruction++);
    instruction.set_label(label);
    getCurrentPredicate().add_instruction_unresolved(instruction);
}

void FPWAM::CodeContext::trust_me_else_fail()
{
    Instruction instruction(i_trust_me_t, m_currentInstruction++);
    getCurrentPredicate().add_instruction(instruction);
}

void FPWAM::CodeContext::ttry(const int32_t label)
{
    Instruction instruction(i_try_t, m_currentInstruction++);
    instruction.set_label(label);
    getCurrentPredicate().add_instruction_unresolved(instruction);
}

void FPWAM::CodeContext::retry(const int32_t label)
{
    Instruction instruction(i_retry_t, m_currentInstruction++);
    instruction.set_label(label);
    getCurrentPredicate().add_instruction_unresolved(instruction);
}

void FPWAM::CodeContext::trust(const int32_t label)
{
    Instruction instruction(i_trust_t, m_currentInstruction++);
    instruction.set_label(label);
    getCurrentPredicate().add_instruction_unresolved(instruction);
}

void CodeContext::resolve_instructions()
{
    for(Predicate& predicate : m_facts)
    {
        int32_t switch_on_con_nr = 0;
        for(int32_t unresolvedIndex : predicate.get_unresolvedInstr())
        {
            Instruction& instruction = predicate.get_instructions()[unresolvedIndex];

            switch(instruction.get_instructionType())
            {
                case i_call_t:
                case i_execute_t:
                case i_try_me_else_t:
                case i_retry_me_else_t:
                case i_trust_me_t:
                case i_try_t:
                case i_retry_t:
                case i_trust_t:
                {
                    if(instruction.get_label() != -1)
                    {
                        int32_t label = instruction.get_label();
                        const auto &labelToInstrMap = predicate.get_labelToInstruction();
                        if (!(FOUND(labelToInstrMap, label)))
                        {
                            std::cerr << instruction.to_string() <<" ERROR " << predicate.get_name() << ": " << "Label " << label << " not found."
                                      << std::endl;
                            exit(-1);
                        }

                        uint16_t instrNumber = labelToInstrMap.find(label)->second;

                        if(instruction.get_instructionType() == i_execute_t)
                            instruction.set_constant(fpwam_call_execute(instrNumber, predicate.get_arity()));
                        else
                            instruction.set_constant(instrNumber);

                        break;
                    }
                    else if(instruction.get_functor().length())
                    {
                        const std::string& functor = instruction.get_functor();
                        const std::string  name = functor.substr(0, functor.find_first_of("/"));
                        const std::string  sarity = functor.substr(functor.find_first_of("/")+1, functor.length());
                        uint8_t  arity = stoi(sarity, nullptr,  10);

                        if(!(FOUND(m_predicateNameToNr, name)))
                        {
                            std::cerr << instruction.to_string() <<" ERROR " << predicate.get_name() << ": " << "Predicate " << functor << " not found."
                                      << std::endl;
                            exit(-1);
                        }

                        int32_t index = m_predicateValueToIndex[Predicate::composeValue(m_predicateNameToNr[name], arity)];
                        const Predicate& p = m_facts[index];
                        instruction.set_constant(fpwam_call_execute(p.get_startInstrNumber(), p.get_arity()));
                        break;
                    }

                    std::cerr << instruction.to_string() << " ERROR " << predicate.get_name() << ": " << "Couldn't be resolved" << std::endl;
                    exit(-1);
                }
                break;
                case i_switch_on_int_str_t:
                {
                    int32_t max = INT32_MIN;
                    int32_t min = INT32_MAX;

                    auto& valuesToInstructions = predicate.get_switchValues()[switch_on_con_nr];
                    const auto& labelsToInstr = predicate.get_labelToInstruction();

                    for(auto& vToI : valuesToInstructions)
                    {
                        uint16_t label = vToI.second;

                        if(!(FOUND(labelsToInstr, label)))
                        {
                            std::cerr << instruction.to_string() <<" ERROR " << predicate.get_name() << ": " << "Label " << label << " not found."
                                      << std::endl;
                            exit(-1);
                        }

                        uint16_t instrNumber = labelsToInstr.find(label)->second;
                        vToI.second = instrNumber;

                        if(max < instrNumber)
                        {
                            max = instrNumber;
                        }

                        if(min > instrNumber)
                        {
                            min = instrNumber;
                        }
                    }

                    //hack
                    int32_t nextIndex = instruction.get_constant();
                    instruction.set_constant(min);
                    predicate.get_instructions()[nextIndex].set_constant(max);
                }
                break;
                default:
                    std::cerr << "Unresolved What? " << instruction.get_instructionType() << std::endl;
                    break;
            }
        }
    }
}

void CodeContext::query()
{
    m_backupConstantNr = m_constantNr;
    m_backupFacts = m_facts;
    m_backupInstruction = m_currentInstruction;
    m_backupPredicateNameToNr = m_predicateNameToNr;
    m_backupPredicateNr = m_predicateNr;
    m_backupPredicateValueToIndex = m_predicateValueToIndex;

    m_query_fact = m_facts.size();
}

void CodeContext::end_query()
{
    m_constantNr = m_backupConstantNr;
    m_facts = m_backupFacts;
    m_currentInstruction = m_backupInstruction;
    m_predicateNameToNr = m_backupPredicateNameToNr;
    m_predicateNr = m_backupPredicateNr ;
    m_predicateValueToIndex = m_backupPredicateValueToIndex;

    m_query_fact = -1;
}

void CodeContext::get_instructions(std::vector<Instruction> &instrVec)
{
    uint16_t instructionCheck = 0;
    instrVec.clear();
    instrVec.reserve(m_currentInstruction);

    for(auto& predicate : m_facts)
    {
        if(predicate.get_instructions().size())
        {
            instrVec.push_back(Instruction(i_nop, instructionCheck++));

            for (auto &instruction : predicate.get_instructions())
            {
                instrVec.push_back(instruction);
                instructionCheck++;
            }
        }
    }

    std::sort(instrVec.begin(), instrVec.end(),
     [](const Instruction & a, const Instruction & b) -> bool
    {
        return a.get_number() < b.get_number();
    });

    return;
}

CodeContext::CodeContext()
: m_currentInstruction(0)
, m_predicateNr(1)
, m_constantNr(1)
{
    m_constantNameToValue["FPWAM_NIL_VALUE"] = -1;
}



