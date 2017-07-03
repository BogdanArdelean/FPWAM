//
// Created by Bogdan  Ardelean on 7/3/17.
//

#include <iostream>
#include "GPLCBridge.h"
#include "CodeContext.h"

using namespace FPWAM;

static CodeContext* contextObj;

void setCodeContext(CodeContextCPtr codeCtx)
{
    contextObj = static_cast<CodeContext*>(codeCtx);
}


void predicate(const char *name, const int8_t arity)
{
    contextObj->predicate(name, arity);
}

void get_value(const int8_t XYn, const char c, const int8_t Ai)
{
    contextObj->get_value(XYn+1, c, Ai+1);
}

void get_variable(const int8_t XYn, const char c, const int8_t Ai)
{
    contextObj->get_variable(XYn+1, c, Ai+1);
}


void get_constant(const char *atom, const int8_t Ai)
{
    contextObj->get_constant(atom, Ai+1);
}

void get_list(const int8_t Ai)
{
    contextObj->get_list(Ai+1);
}

void get_structure(const char *name, const int8_t arity, const int8_t Ai)
{
    std::string s(name);
    int32_t found = s.find_first_of("/");
    contextObj->get_structure(s.substr(0, found), arity, Ai+1);
}

void put_variableX(const int8_t Xn, const int8_t Ai)
{
    contextObj->put_variableX(Xn+1, Ai+1);
}

void put_variableY(const int8_t Yn, const int8_t Ai)
{
    contextObj->put_variableY(Yn+1, Ai+1);
}

void put_value(const int8_t XYn, const char c, const int8_t Ai)
{
    contextObj->put_value(XYn+1, c, Ai+1);
}

void put_unsafe_value(const int8_t Yn, const int8_t Ai)
{
    contextObj->put_unsafe_value(Yn+1, Ai+1);
}

void put_constant(const char *name, const int8_t Ai)
{
    contextObj->put_constant(name, Ai+1);
}

void put_list(const int8_t Ai)
{
    contextObj->put_list(Ai+1);
}

void put_structure(const char *name, const int8_t arity, const int8_t Ai)
{
    std::string s(name);
    int32_t found = s.find_first_of("/");
    contextObj->put_structure(s.substr(0, found), arity, Ai+1);
}

void unify_variable(const int8_t XYn, const char c)
{
    contextObj->unify_variable(XYn+1, c);
}

void unify_void(const int8_t n)
{
    contextObj->unify_void(n);
}

void unify_value(const int8_t XYn, const char c)
{
    contextObj->unify_value(XYn+1, c);
}

void unify_local_value(const int8_t XYn, const char c)
{
    contextObj->unify_local_value(XYn+1, c);
}

void unify_constant(const char *name)
{
    contextObj->unify_constant(name);
}

void unify_list()
{
    contextObj->unify_list();
}

void unify_structure(const char *name, const int8_t arity)
{
    std::string s(name);
    int32_t found = s.find_first_of("/");
    contextObj->unify_structure(s.substr(0, found), arity);
}

void allocate(const int8_t n)
{
    contextObj->allocate(n);
}

void deallocate()
{
    contextObj->deallocate();
}

void call(const char *name, const int8_t arity)
{
    contextObj->call(name, arity);
}

void execute(const char *name, const int8_t arity)
{
    contextObj->execute(name, arity);
}

void proceed()
{
    contextObj->proceed();
}

void fail()
{
    contextObj->fail();
}

void label(int32_t l)
{
    contextObj->label(l);
}

void switch_on_term(const int32_t v, const int32_t c, const int32_t l, const int32_t s)
{
    contextObj->switch_on_term(v, c, l, s);
}

void switch_on_con(char **constants, int32_t *labels, int32_t nr_constants)
{
    std::vector<std::string> constVec;
    std::vector<int32_t> labelsVec;

    for(int i = 0; i < nr_constants; ++i)
    {
        constVec.push_back(std::string(constants[i]));
        labelsVec.push_back(labels[i]);
    }
    contextObj->switch_on_con(constVec, labelsVec);
}

void switch_on_str(char **str, int8_t *arity, int32_t *labels, int32_t nr_str)
{
    std::vector<std::string> strVec(nr_str);
    std::vector<int8_t> arityVec(nr_str);
    std::vector<int32_t> labelsVec(nr_str);

    for(int i = 0; i < nr_str; ++i)
    {
        strVec.push_back(std::string(str[i]));
        arityVec.push_back(arity[i]);
        labelsVec.push_back(labels[i]);
    }

    contextObj->switch_on_str(strVec, arityVec, labelsVec);
}

void try_me_else(const int32_t label)
{
    contextObj->try_me_else(label);
}

void retry_me_else(const int32_t label)
{
    contextObj->retry_me_else(label);
}

void trust_me_else_fail()
{
    contextObj->trust_me_else_fail();
}

void ttry(const int32_t label)
{
    contextObj->ttry(label);
}

void retry(const int32_t label)
{
    contextObj->retry(label);
}

void trust(const int32_t label)
{
    contextObj->trust(label);
}

