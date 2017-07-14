//
// Created by Bogdan  Ardelean on 7/3/17.
//

#ifndef SOFTWARE_GPLCBRIDGE_H
#define SOFTWARE_GPLCBRIDGE_H

#ifdef __cplusplus
#define EXTERNC extern "C"
#else
#define EXTERNC
#endif


typedef void *CodeContextCPtr;
void setCodeContext(CodeContextCPtr codeCtx);

EXTERNC void predicate(const char* name, const int8_t arity);
EXTERNC void get_value(const int8_t XYn, const char c, const int8_t Ai);
EXTERNC void get_variable(const int8_t XYn, const char c, const int8_t Ai);
EXTERNC void get_constant(const char* atom, const int8_t Ai);
EXTERNC void get_list(const int8_t Ai);
EXTERNC void get_structure(const char* name, const int8_t arity, const int8_t Ai);
EXTERNC void put_variableX(const int8_t Xn, const int8_t Ai);
EXTERNC void put_variableY(const int8_t Yn, const int8_t Ai);
EXTERNC void put_value(const int8_t XYn, const char c, const int8_t Ai);
EXTERNC void put_unsafe_value(const int8_t Yn, const int8_t Ai);
EXTERNC void put_constant(const char* name, const int8_t Ai);
EXTERNC void put_list(const int8_t Ai);
EXTERNC void put_structure(const char* name, const int8_t arity, const int8_t Ai);
EXTERNC void unify_variable(const int8_t XYn, const char c);
EXTERNC void unify_void(const int8_t n);
EXTERNC void unify_value(const int8_t XYn, const char c);
EXTERNC void unify_local_value(const int8_t XYm, const char c);
EXTERNC void unify_constant(const char* name);
EXTERNC void unify_list();
EXTERNC void unify_structure(const char* name, const int8_t arity);
EXTERNC void allocate(const int8_t n);
EXTERNC void deallocate();
EXTERNC void call(const char* name, const int8_t arity);
EXTERNC void execute(const char* name, const int8_t arity);
EXTERNC void proceed();
EXTERNC void fail();
EXTERNC void label(int32_t l);
EXTERNC void switch_on_term(const int32_t v, const int32_t c, const int32_t l, const int32_t s);
EXTERNC void switch_on_con(char** constants, int32_t* labels, int32_t nr_constants);
EXTERNC void switch_on_str(char** str, int8_t *arity, int32_t* labels, int32_t nr_str);
EXTERNC void try_me_else(const int32_t label);
EXTERNC void retry_me_else(const int32_t label);
EXTERNC void trust_me_else_fail();
EXTERNC void ttry(const int32_t label);
EXTERNC void retry(const int32_t label);
EXTERNC void trust(const int32_t label);


#endif //SOFTWARE_GPLCBRIDGE_H
