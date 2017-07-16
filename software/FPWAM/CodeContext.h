//
// Created by Bogdan  Ardelean on 7/2/17.
//

#ifndef SOFTWARE_CODECONTEXT_H
#define SOFTWARE_CODECONTEXT_H

#include "Predicate.h"

namespace FPWAM
{
    struct CodeContext
    {
        CodeContext();

        uint16_t m_currentInstruction;
        int32_t  m_predicateNr;
        int32_t  m_constantNr;

        uint16_t m_backupInstruction;
        int32_t  m_backupPredicateNr;
        int32_t  m_backupConstantNr;
        std::vector<Predicate> m_backupFacts;
        std::map<std::string, int32_t> m_backupPredicateNameToNr;
        std::map<int32_t, int32_t>     m_backupPredicateValueToIndex;

        std::vector<Predicate> m_facts;
        std::map<std::string, int32_t> m_predicateNameToNr;
        std::map<int32_t, std::string> m_predicateValueToName;
        std::map<int32_t, int32_t>     m_predicateValueToIndex;

        std::map<std::string, int32_t> m_constantNameToValue;
        std::map<int32_t, std::string> m_constantValueToName;

        void predicate(const std::string name, const int8_t arity);
        void get_value(const int8_t XYn, const char c, const int8_t Ai);
        void get_variable(const int8_t XYn, const char c, const int8_t Ai);
        void get_constant(const std::string atom, const int8_t Ai);
        void get_list(const int8_t Ai);
        void get_structure(const std::string name, const int8_t arity, const int8_t Ai);
        void put_variableX(const int8_t Xn, const int8_t Ai);
        void put_variableY(const int8_t Yn, const int8_t Ai);
        void put_value(const int8_t XYn, const char c, const int8_t Ai);
        void put_unsafe_value(const int8_t Yn, const int8_t Ai);
        void put_constant(const std::string name, const int8_t Ai);
        void put_list(const int8_t Ai);
        void put_structure(const std::string name, const int8_t arity, const int8_t Ai);
        void unify_variable(const int8_t XYn, const char c);
        void unify_void(const int8_t n);
        void unify_value(const int8_t XYn, const char c);
        void unify_local_value(const int8_t XYn, const char c);
        void unify_constant(const std::string name);
        void unify_list();
        void unify_structure(const std::string name, const int8_t arity);
        void allocate(const int8_t n);
        void deallocate();
        void call(const std::string name, const int8_t arity);
        void execute(const std::string name, const int8_t arity);
        void proceed();
        void fail();
        void label(int32_t l);
        void switch_on_term(const int32_t v, const int32_t c, const int32_t l, const int32_t s);
        void switch_on_con(std::vector<std::string>& constants, std::vector<int32_t>& labels);
        void switch_on_str(std::vector<std::string>& str, std::vector<int8_t> &arity, std::vector<int32_t>& labels);
        void try_me_else(const int32_t label);
        void retry_me_else(const int32_t label);
        void trust_me_else_fail();
        void ttry(const int32_t label);
        void retry(const int32_t label);
        void trust(const int32_t label);

        void resolve_instructions();
        void query();
        void end_query();
        void get_instructions(std::vector<Instruction>& instr);

    private:

        int32_t m_query_fact;
        int32_t m_current_predicate_index;
        void add_predicate(const std::string &name, const int8_t arity, int32_t number, int32_t predicateValue, bool resolved);
        Predicate& getCurrentPredicate()
        {
            return m_facts[m_current_predicate_index];
        }
    };
}


#endif //SOFTWARE_CODECONTEXT_H
