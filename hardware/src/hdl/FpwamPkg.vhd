library ieee;
library xil_defaultlib;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package FpwamPkg is
  constant kWamAddressWidth      : natural := 16;
  constant kWamWordWidth         : natural := 18;
  constant kWamPdlAddressWidth   : natural := 10;
  constant kWamTrailAddressWidth : natural := 10;
  constant kGPRAddressWidth      : natural := 4;
  constant kFunctorWidth         : natural := 12;
  constant kArityWidth           : natural := kGPRAddressWidth;
  constant kWamInstructionWidth  : natural := 32;
  constant kWamInstrMemWidth     : natural := 10;
  constant kWamHeapStart         : std_logic_vector(kWamAddressWidth -1 downto 0) := (others=>'0');
  constant kWamStackStart        : std_logic_vector(kWamAddressWidth -1 downto 0) := std_logic_vector(to_unsigned(2**(kWamAddressWidth-1)+1, kWamAddressWidth));

  -- Possible address inputs for memory (eg: MA_H_t => Memory Address from register H)
  type mem_addr_input_t is (MA_H_t, MA_Hplus1_t, MA_deref_unit_t, MA_untag_deref_t, MA_bind_unit_1_t, MA_bind_unit_2_t,
                            MA_unify_unit_t, MA_stack_addr_t, MA_S_t, MA_addr_t, MA_Ep2orB_t, MA_newE_t, MA_newEp1_t,
                            MA_newEp2_t, MA_E_t, MA_Ep1_t, MA_newB_t, MA_newBNRi_t, MA_newBNRip1_t, MA_newBI_t, MA_newBIp1_t,
                            MA_B_t, MA_BI_t, MA_BIp1_t, MA_BNRI_t, MA_BNRIp1_t, MA_unwind_trail_t, MA_BImem_port1_t, MA_DFC_t);
  -- Possible input sources for memory
  type mem_port_input_t is ( MI_str_Hplus1_t, MI_constant_t, MI_GPR_t, MI_GPR2_t, MI_bind_unit_1_t, MI_bind_unit_2_t, MI_unify_unit_t,
                             MI_mem_port1_t, MI_mem_port2_t, MI_ref_H_t, MI_ref_addr_t, MI_E_t, MI_CP_t, MI_B_t, MI_TR_t, MI_NRAGRGS_t, MI_unwind_trail_t, MI_H_t);
  -- Possible input sources for H register
  type h_input_t        is (HI_p1_t, HI_p2_t, HI_HB_t, HI_mem_port1_t, HI_mem_port2_t);
  -- Possible input sources for S register
  type s_input_t        is (SI_untag_deref_p1_t, SI_p1_t);
  -- Possible input sources for P register
  type p_input_t        is (PI_pinstr_size_t, PI_p1_t, PI_CP_t, PI_instr_t, PI_mem_port1_t, PI_mem_port2_t);
  -- Possible input sources for E register
  type e_input_t        is (EI_newE_t, EI_mem_port1_t, EI_mem_port2_t);
  -- Possible input sources for CP register
  type cp_input_t       is (CPI_P_t, CPI_mem_port1_t, CPI_mem_port2_t);
  -- Possible input sources for B Register
  type b_input_t        is (BRI_newB_t, BRI_mem_port1_t, BRI_mem_port2_t);
  -- Possible input sources for TR Register
  type tr_input_t       is (TRI_Trp1_t, TRI_mem_port1_t, TRI_mem_port2_t);
  -- Possible input sources for HB Register
  type hb_input_t       is (HBI_H_t, HBI_mem_port1_t, HBI_mem_port2_t);
  -- Possible input sources for NRARGS register
  type nrargs_input_t   is (NRARGSI_instr_t, NRARGSI_mem_port1_t, NRARGSI_mem_port2_t);
  -- Possible input sources for General Purpose Registers
  type GPR_input_t      is (GPRI_ref_H_t, GPRI_str_H_t, GPRI_mem_port1_t, GPRI_mem_port2_t, GPRI_ref_addr_t, GPRI_gpr2_t);
  -- Possible input sources for General Purpose Registers address
  type GPR_addr_input_t is (GPRA_instr_t, GPRA_I_t, GPRA_Ip1_t);
  -- Possible input sources for deref unit
  type deref_input_t    is (DI_GPR_t, DI_unify_unit_t);
  -- Possible input sources for bind unit
  type bind_input_t     is (BI_deref_unit_t, BI_mem_port1_t, BI_unify_unit_t);
  -- Possible input sources for trail unit
  type trail_input_t    is (TI_bind_output_t, TI_unwind_trail_t);
  -- WAM execution modes
  type wam_mode_t       is (mode_write_t, mode_read_t);
  -- Types of objects supported in WAM
  type tag_t            is (tag_str_t, tag_ref_t, tag_int_t, tag_lis_t);
  -- Unify unit input
  type unify_input_t    is  (UI_GPR_t, UI_mem_port1_t, UI_mem_port2_t);
  -- Unify mem input
  type unify_mem_sel_t  is (sel_unify_t, sel_deref_t, sel_bind_t);

  type instruction_t    is (i_nop               -- 00000
                           ,i_put_structure_t   -- 00001 put_structure p/n, Xm -> [INSTRNUM][Xm][p][n]
                           ,i_put_variable_X_t  -- 00010
                           ,i_put_variable_Y_t  -- 00011
                           ,i_put_value_t       -- 00100
                           ,i_get_structure_t   -- 00101
                           ,i_get_variable_t    -- 00110
                           ,i_get_value_t       -- 00111
                           ,i_unify_variable_t  -- 01000
                           ,i_unify_value_t     -- 01001
                           ,i_call_t            -- 01010
                           ,i_proceed_t         -- 01011
                           ,i_allocate_t        -- 01100
                           ,i_deallocate_t      -- 01101
                           ,i_try_me_else_t     -- 01110
                           ,i_retry_me_else_t   -- 01111
                           ,i_trust_me_t        -- 10000
                           );
  constant kInstrDecodeWidth : integer := 5;


  function fpwam_tag           (word : std_logic_vector) return tag_t;
  function fpwam_value         (word : std_logic_vector) return std_logic_vector;
  function fpwam_word          (word : std_logic_vector; tag : tag_t) return std_logic_vector;
  function fpwam_functor       (word : std_logic_vector(kWamWordWidth -1 downto 0)) return std_logic_vector;
  function fpwam_arity         (word : std_logic_vector(kWamWordWidth -1 downto 0)) return std_logic_vector;
  function fpwam_instr         (word : std_logic_vector(31 downto 0)) return instruction_t;
  function fpwam_instr_addr    (word : std_logic_vector) return std_logic_vector;
  function fpwam_instr_arity   (word : std_logic_vector) return std_logic_vector;
  function fpwam_var_on_stack  (word : std_logic_vector) return boolean;
  function fpwam_var_stack_addr(instr : std_logic_vector; E : std_logic_vector) return std_logic_vector;
  function to_std_logic        (bool : boolean) return std_logic;
end FpwamPkg;

package body FpwamPkg is

  function fpwam_tag   (word : std_logic_vector) return tag_t is
   variable result : integer;
   begin
      result := to_integer(unsigned(word(kWamWordWidth -1 downto kWamWordWidth -2)));
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

  function fpwam_instr   (word : std_logic_vector(31 downto 0)) return instruction_t is
    variable result : integer;
    begin
      result := to_integer(unsigned(word(kWamInstructionWidth -1 downto kWamInstructionWidth - kInstrDecodeWidth)));
      return instruction_t'val(result);
  end function;

  function fpwam_instr_addr (word : std_logic_vector) return std_logic_vector is
    begin
      return word(kWamInstrMemWidth + kGPRAddressWidth -1 downto kGPRAddressWidth);
  end function;

  function fpwam_instr_arity (word : std_logic_vector) return std_logic_vector is
    begin
      return word(kGPRAddressWidth -1 downto 0);
  end function;

  function fpwam_var_on_stack(word : std_logic_vector) return boolean is
    begin
      return word(22) = '1';
  end function;

  function fpwam_var_stack_addr(instr : std_logic_vector; E : std_logic_vector) return std_logic_vector is
    variable result : std_logic_vector(kWamAddressWidth -1 downto 0);
    begin
      result := std_logic_vector(unsigned(instr(kGPRAddressWidth + kWamWordWidth - 1 downto kWamWordWidth)) + unsigned(E) + 2);
      return result;
  end function;

  function to_std_logic(bool : boolean) return std_logic is
    begin
      if bool then
        return('1');
      else
        return('0');
      end if;
  end function;

end package body;
