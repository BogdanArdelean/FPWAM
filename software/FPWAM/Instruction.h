//
// Created by Bogdan  Ardelean on 7/2/17.
//

#ifndef SOFTWARE_FPWAMINSTRUCTION_H
#define SOFTWARE_FPWAMINSTRUCTION_H

#include <cstdint>
#include <string>
#include "FPWAMDefs.h"

namespace FPWAM
{

    class Instruction
    {
    public:

        Instruction(InstructionType m_instructionType, uint16_t number);

        int32_t get_label() const
        {
            return m_label;
        }

        const std::string& get_functor() const
        {
            return m_functor;
        }

        InstructionType get_instructionType() const
        {
            return m_instructionType;
        }

        int8_t get_reg1() const
        {
            return m_reg1;
        }

        int8_t get_reg2() const
        {
            return m_reg2;
        }

        int32_t get_constant() const
        {
            return m_constant;
        }

        uint32_t get_instruction() const
        {
            return m_instruction;
        }

        uint16_t get_number() const
        {
            return m_number;
        }

        void set_number(uint16_t number)
        {
            m_number = number;
        }

        void set_label(int32_t m_label);

        void set_functor(std::string& m_functor);

        void set_instructionType(InstructionType m_instructionType);

        void set_reg1(int8_t m_reg1);

        void set_reg2(int8_t m_reg2);

        void set_constant(int32_t m_constant);

        void set_instruction(uint32_t m_instruction);

        std::string to_string();

    private:

        int32_t m_label;
        std::string m_functor;
        uint16_t m_number;

        InstructionType m_instructionType;
        int8_t m_reg1;
        int8_t m_reg2;
        int32_t m_constant;

        uint32_t m_instruction;

        void compose();
    };
}

#endif //SOFTWARE_FPWAMINSTRUCTION_H
