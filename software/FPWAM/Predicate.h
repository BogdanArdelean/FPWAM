//
// Created by Bogdan  Ardelean on 7/2/17.
//

#ifndef SOFTWARE_PREDICATE_H
#define SOFTWARE_PREDICATE_H

#include <cstdint>
#include <string>
#include <vector>
#include <map>
#include "Instruction.h"

namespace FPWAM
{

    class Predicate
    {
    public:
        static int32_t composeValue(int32_t number, int8_t arity);

        Predicate(const std::string &m_name, int8_t m_arity, int32_t m_value, uint16_t instrNumber);

        const std::map<int32_t, int16_t> &get_labelToInstruction() const
        {
            return m_labelToInstruction;
        }

        const std::string &get_name() const
        {
            return m_name;
        }

        void set_name(const std::string &m_name)
        {
            Predicate::m_name = m_name;
        }

        int8_t get_arity() const
        {
            return m_arity;
        }

        void set_arity(int8_t m_arity)
        {
            Predicate::m_arity = m_arity;
        }

        int32_t get_value() const
        {
            return m_value;
        }

        void set_value(int32_t m_value)
        {
            Predicate::m_value = m_value;
        }

        const std::vector<Instruction> &get_instructions() const
        {
            return m_instructions;
        }

        const std::vector<int32_t> &get_unresolvedInstr() const
        {
            return m_unresolvedInstr;
        }

        std::vector<std::map<int32_t, int16_t> > &get_switchValues()
        {
            return m_switchValues;
        }

        uint16_t get_startInstrNumber() const
        {
            return m_startInstrNumber;
        }

        void set_startInstrNumber(uint16_t m_startInstrNumber)
        {
            Predicate::m_startInstrNumber = m_startInstrNumber;
        }

        void add_instruction(Instruction &instruction);
        void add_instruction_unresolved(Instruction &instruction);
        void add_label(int32_t label, uint16_t currInstr);
    private:
        std::map<int32_t, int16_t> m_labelToInstruction;
        std::vector<std::map<int32_t, int16_t> > m_switchValues;
        std::string m_name;
        int8_t m_arity;
        int32_t m_value;
        uint16_t m_startInstrNumber;
        std::vector<Instruction> m_instructions;
        std::vector<int32_t> m_unresolvedInstr;
    };
}

#endif //SOFTWARE_PREDICATE_H
