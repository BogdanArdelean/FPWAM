//
// Created by Bogdan  Ardelean on 7/2/17.
//

#ifndef SOFTWARE_FPWAMDEFS_H
#define SOFTWARE_FPWAMDEFS_H
#include <cstdint>

namespace FPWAM
{
    const int32_t kRegWidth             = 4;
    const int32_t kInstructionTypeWidth = 6;
    const int32_t kWamWordWidth         = 18;

    enum InstructionType
    {
        i_nop = UINT8_C(0)                // 000000
        , i_put_structure_t     // 000001 put_structure p/n, Xm -> [INSTRNUM][Xm][p][n]
        , i_put_variable_X_t    // 000010
        , i_put_variable_Y_t    // 000011
        , i_put_value_t         // 000100
        , i_get_structure_t     // 000101
        , i_get_variable_t      // 000110
        , i_get_value_t         // 000111
        , i_unify_variable_t    // 001000
        , i_unify_value_t       // 001001
        , i_call_t              // 001010
        , i_proceed_t           // 001011
        , i_allocate_t          // 001100
        , i_deallocate_t        // 001101
        , i_try_me_else_t       // 001110
        , i_retry_me_else_t     // 001111
        , i_trust_me_t          // 010000
        , i_put_unsafe_value_t  // 010001
        , i_put_list_t          // 010010
        , i_put_constant_t      // 010011
        , i_get_list_t          // 010100
        , i_get_constant_t      // 010101
        , i_unify_local_value_t // 010110
        , i_unify_constant_t    // 010111
        , i_unify_void          // 011000
        , i_try_t               // 011001
        , i_retry_t             // 011010
        , i_trust_t             // 011011
        , i_execute_t           // 011100
        , i_unify_structure_t   // 011101
        , i_switch_on_term_t    // 011110
        , i_fail_t              // 011111
        , i_switch_on_int_str_t // 100000
    };

    enum fpwam_tag
    {
         tag_str_t
        ,tag_ref_t
        ,tag_lis_t
        ,tag_int_t
    };

    static int8_t stackVariable(int8_t i)
    {
        return (1 << kRegWidth) | i;
    }

    static int32_t fpwam_word(fpwam_tag tag, int32_t word)
    {
        return ((int32_t)tag << 16) | word;
    }

    static int32_t fpwam_call_execute(uint16_t number, int8_t arity)
    {
        return ((int32_t)number << kRegWidth) | arity;
    }
}
#endif //SOFTWARE_FPWAMDEFS_H
