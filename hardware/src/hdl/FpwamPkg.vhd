library ieee;
library xil_defaultlib;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package FpwamPkg is
  constant kWamAddressWidth    : natural := 16;
  constant kWamWordWidth       : natural := 18;
  constant kWamPdlAddressWidth : natural := 10;
  constant kGPRAddressWidth    : natural := 4;
  constant kFunctorWidth       : natural := 12;
  constant kArityWidth         : natural := kGPRAddressWidth;
  constant kInstructionWidth   : natural := 32;

  -- Possible address inputs for memory (eg: MA_H_t => Memory Address from register H)
  type mem_addr_input_t is (MA_H_t, MA_Hplus1_t, MA_deref_unit_t, MA_untag_deref_t, MA_bind_unit_1_t, MA_bind_unit_2_t,
                            MA_unify_unit_t, MA_stack_addr_t, MA_S_t);
  -- Possible input sources for memory
  type mem_port_input_t is ( MI_str_Hplus1_t, MI_constant_t, MI_GPR_t, MI_bind_unit_1_t, MI_bind_unit_2_t, MI_unify_unit_t,
                             MI_mem_port1_t, MI_mem_port2_t, MI_ref_H_t);
  -- Possible input sources for H register
  type h_input_t        is (HI_p1_t, HI_p2_t);
  -- Possible input sources for S register
  type s_input_t        is (SI_untag_deref_p1_t, SI_p1_t);
  -- Possible input sources for P register
  type p_input_t        is (PI_pinstr_size_t);
  -- Possible input sources for General Purpose Registers
  type GPR_input_t      is (GPRI_ref_H_t, GPRI_str_H_t, GPRI_mem_port1_t, GPRI_mem_port2_t);
  -- Possible input sources for deref unit
  type deref_input_t    is (DI_GPR_t, DI_unify_unit_t);
  -- Possible input sources for bind unit
  type bind_input_t     is (BI_deref_unit_t, BI_mem_port1_t, BI_unify_unit_t);
  -- Possible input sources for trail unit
  type trail_input_t    is (TI_bind_output_t);
  -- WAM execution modes
  type wam_mode_t       is (mode_write_t, mode_read_t);
  -- Types of objects supported in WAM
  type tag_t            is (tag_str_t, tag_ref_t, tag_int_t, tag_lis_t);
  -- Unify unit input
  type unify_input_t    is  (UI_GPR_t, UI_mem_port1_t, UI_mem_port2_t);
  -- Unify mem input
  type unify_mem_sel_t  is (sel_unify_t, sel_deref_t, sel_bind_t);

  -- Maybe shoud create for tag unit the same thing?
  -- Currently isn't necessary.

  -- useful functions
  function fpwam_tag     (word : std_logic_vector) return tag_t;
  function fpwam_value   (word : std_logic_vector) return std_logic_vector;
  function fpwam_word    (word : std_logic_vector; tag : tag_t) return std_logic_vector;
  function fpwam_functor (word : std_logic_vector(kWamWordWidth -1 downto 0)) return std_logic_vector;
  function fpwam_arity   (word : std_logic_vector(kWamWordWidth -1 downto 0)) return std_logic_vector;
end FpwamPkg;

package body FpwamPkg is

  function fpwam_tag   (word : std_logic_vector) return tag_t is
   variable result : integer;
   begin
      result := to_integer(unsigned(word(kWamWordWidth -1 downto kWamWordWidth -3)));
    return tag_t'val(result);
  end function;

  function fpwam_value (word: std_logic_vector) return std_logic_vector is
    begin
      return word(word'length - 3 downto 0);
  end function;

  function fpwam_word (word : std_logic_vector; tag : tag_t) return std_logic_vector is
    begin
      return std_logic_vector(to_unsigned(tag_t'pos(tag),2)) & word;
  end function;

  function fpwam_functor (word : std_logic_vector(kWamWordWidth -1 downto 0)) return std_logic_vector is
    begin
      return word(word'length-1 downto word'length - kFunctorWidth+1);
  end function;

  function fpwam_arity (word : std_logic_vector(kWamWordWidth -1 downto 0)) return std_logic_vector is
    begin
      return word(kArityWidth-1 downto 0);
  end function;

end package body;
