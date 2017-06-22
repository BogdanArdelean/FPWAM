-------------------------------------------------------------------------------
-- FILE NAME      : DataFlowControl.vhd
-- MODULE NAME    : DataFlowControl
-- AUTHOR         : Bogdan Ardelean
-- AUTHOR'S EMAIL : bogdan.ardelean@yahoo.com
-------------------------------------------------------------------------------
-- REVISION HISTORY
-- VERSION  DATE         AUTHOR            DESCRIPTION
-- 1.0      2016-05-03   Bogdan Ardelean   Created
-------------------------------------------------------------------------------
-- DESCRIPTION    : Module used for decoding WAM instructions and setting
--                  appropriate signals on dataflow path
-------------------------------------------------------------------------------

library ieee;
library xil_defaultlib;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.FpwamPkg.all;



entity DataFlowControl is
  port
  (
    -- Common
    clk               : in std_logic;
    rst               : in std_logic;

    -- interface
    instruction       : in std_logic_vector(kWamInstructionWidth -1 downto 0);
    instruction_valid : in std_logic;
    mem_obj           : in std_logic_vector(kWamWordWidth -1 downto 0);
    deref_done        : in std_logic;
    mode_reg          : in wam_mode_t;
    unify_done        : in std_logic;
    bind_done         : in std_logic;

    get_instruction   : out std_logic;

    start_deref       : out std_logic;
    deref_input       : out deref_input_t;

    wr_s_reg          : out std_logic;
    s_reg_input       : out s_input_t;

    wr_mode_reg       : out std_logic;
    mode_value        : out wam_mode_t; -- 1 = READ, 0 = WRITE; should define type

    rd_mem_port1      : out std_logic;
    wr_mem_port1      : out std_logic;
    mem_input1        : out mem_port_input_t;
    mem_addr_input1   : out mem_addr_input_t;

    rd_mem_port2      : out std_logic;
    wr_mem_port2      : out std_logic;
    mem_input2        : out mem_port_input_t;
    mem_addr_input2   : out mem_addr_input_t;

    bind              : out std_logic;
    bind_port1        : out bind_input_t;
    bind_port2        : out bind_input_t;

    trail_input       : out trail_input_t;

    wr_h_reg          : out std_logic;
    h_input           : out h_input_t;

    wr_gpr1            : out std_logic;
    gpr_input1         : out gpr_input_t;

    wr_gpr2            : out std_logic;
    gpr_input2         : out gpr_input_t;


    start_unify       : out std_logic;
    unify_input_a     : out unify_input_t;
    unify_input_b     : out unify_input_t;

    p_input           : out p_input_t;
    p_wr              : out std_logic;
    cp_wr             : out std_logic;
    nrargs_wr         : out std_logic
   );
end DataFlowControl;

architecture Behavioral of DataFlowControl is
-- FSM
type state_t is (idle_t, next_instr_t
                ,put_structure_t
                ,get_structure_t, get_structure_t2, get_structure_t3
                ,unify_variable_t, unify_variable_t2
                ,unify_value_t, unify_value_t2
                ,put_variable_X_t
                ,put_variable_Y_t
                ,put_value_t, put_value_t2
                ,get_variable_t
                ,get_value_t, get_value_t2
                ,call_t
                ,proceed_t
                ,fail_t
                );

signal cr_state, nx_state, decoded_state : state_t;

begin

  -- Decode the first state based on current instruction
  -- TO DO: maybe put in function?
  DECODE_STATE_FIRST: process(instruction, instruction_valid)
  begin
    decoded_state <= idle_t;
    if instruction_valid = '1' then
      case fpwam_instr(instruction) is
        when i_put_structure_t =>
          decoded_state <= put_structure_t;
        when i_get_structure_t =>
          decoded_state <= get_structure_t;
        when i_unify_variable_t =>
          decoded_state <= unify_variable_t;
        when i_unify_value_t =>
          decoded_state <= unify_value_t;
        when i_put_variable_X_t =>
          decoded_state <= put_variable_X_t;
        when i_put_variable_Y_t =>
          decoded_state <= put_variable_Y_t;
        when i_put_value_t =>
          decoded_state <= put_value_t;
        when i_get_variable_t =>
          decoded_state <= get_variable_t;
        when i_get_value_t =>
          decoded_state <= get_value_t;
        when i_call_t =>
          decoded_state <= call_t;
        when i_proceed_t =>
          decoded_state <= proceed_t;
        when others =>
          decoded_state <= idle_t;
      end case;
    end if;
  end process DECODE_STATE_FIRST;


  -- FSM
  FSM: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        cr_state <= next_instr_t;
      else
        cr_state <= nx_state;
      end if;
    end if;
  end process FSM;

  NEXT_STATE_DECODE: process(decoded_state, cr_state, deref_done, mem_obj, instruction, instruction_valid, bind_done, mode_reg, unify_done)
  begin
    nx_state <= cr_state;
    case cr_state is
      when next_instr_t =>
        if instruction_valid='1' then
          nx_state <= idle_t;
        end if;
      when idle_t =>
        nx_state <= decoded_state;
      when put_structure_t =>
        nx_state <= next_instr_t;
----- BEGIN  get_structure f, a(i) -----
      when get_structure_t =>
        if deref_done = '1' then
          nx_state <= get_structure_t2;
        end if;
      when get_structure_t2 =>
        if fpwam_tag(mem_obj) = tag_str_t and mem_obj = instruction(17 downto 0) then
          nx_state <= next_instr_t;
        elsif fpwam_tag(mem_obj) = tag_ref_t then
          nx_state <= get_structure_t3;
        else
          nx_state <= fail_t;
        end if;
      when get_structure_t3 => -- maybe should wait for trail and bind to finish?
        if bind_done = '1' then
        nx_state <= next_instr_t;
        end if;
----- END get_structure f, a(i) -----
      when unify_variable_t =>
        if mode_reg = mode_read_t then
          nx_state <= unify_variable_t2;
        else
          nx_state <= next_instr_t;
        end if;
      when unify_variable_t2 =>
        nx_state <= next_instr_t;
      when unify_value_t =>
        if mode_reg = mode_read_t then
          nx_state <= unify_value_t2;
        else
          if instruction(0) = '1' then -- on stack need 2 cycles
            nx_state <= unify_value_t2;
          else
            nx_state <= next_instr_t;
          end if;
        end if;
      when unify_value_t2 =>
        if mode_reg = mode_read_t then
          if unify_done = '1' then
            nx_state <= next_instr_t;
          end if;
        else
          nx_state <= next_instr_t;
        end if;
      when put_variable_X_t =>
        nx_state <= next_instr_t;
      when put_variable_Y_t =>
        nx_state <= next_instr_t;
      when put_value_t =>
        if instruction(0) = '1' then -- value on stack
          nx_state <= put_value_t2;
        else
          nx_state <= next_instr_t;
        end if;
      when put_value_t2 =>
        nx_state <= next_instr_t;
      when get_variable_t =>
        nx_state <= next_instr_t;
      when get_value_t =>
        nx_state <= get_value_t2;
      when get_value_t2 =>
        if unify_done = '1' then
          nx_state <= next_instr_t;
        end if;
      when call_t =>
        nx_state <= next_instr_t;
      when proceed_t =>
        nx_state <= next_instr_t;
      when others => null;
    end case;
  end process NEXT_STATE_DECODE;

  OUTPUT_DECODE: process(cr_state, deref_done, mem_obj, instruction, bind_done, mode_reg)
  begin
    --DEFAULT VALUES
    get_instruction  <= '0';
    start_deref      <= '0';
    deref_input      <= DI_GPR_t;
    wr_s_reg         <= '0';
    s_reg_input      <= SI_untag_deref_p1_t;
    wr_mode_reg      <= '0';
    mode_value       <= mode_write_t;
    rd_mem_port1     <= '0';
    rd_mem_port2     <= '0';
    wr_mem_port1     <= '0';
    wr_mem_port2     <= '0';
    mem_input1       <= MI_str_Hplus1_t;
    mem_input2       <= MI_str_Hplus1_t;
    mem_addr_input1  <= MA_H_t;
    mem_addr_input2  <= MA_H_t;
    bind             <= '0';
    bind_port1       <= BI_deref_unit_t;
    bind_port2       <= BI_deref_unit_t;
    trail_input      <= TI_bind_output_t;
    wr_h_reg         <= '0';
    h_input          <= HI_p1_t;
    wr_gpr1           <= '0';
    gpr_input1        <= GPRI_ref_H_t;
    wr_gpr2           <= '0';
    gpr_input2        <= GPRI_ref_H_t;
    start_unify      <= '0';
    unify_input_a    <= UI_GPR_t;
    unify_input_b    <= UI_GPR_t;
    p_input          <= PI_p1_t;
    p_wr             <= '0';
    cp_wr            <= '0';
    nrargs_wr        <= '0';
    case cr_state is
      when next_instr_t =>
        get_instruction <= '1';
        p_wr            <= '1';
        p_input         <= PI_p1_t;
      when idle_t =>
        null;
      when get_structure_t => -- deref(Ai)
        start_deref      <= '1';
        deref_input      <= DI_GPR_t;  -- mux => input for deref = A(i)
        mem_addr_input1  <= MA_deref_unit_t;  -- mux => mem input from deref module
        if deref_done = '1' then
          mem_addr_input2  <= MA_untag_deref_t;
          rd_mem_port2     <= '1';
        end if;
      when get_structure_t2 =>
        if fpwam_tag(mem_obj) = tag_str_t and mem_obj = instruction(17 downto 0) then

          -- S = a + 1
          wr_s_reg    <= '1';
          s_reg_input <= SI_untag_deref_p1_t;

          wr_mode_reg <= '1';
          mode_value  <= mode_read_t;
        elsif fpwam_tag(mem_obj) = tag_ref_t then -- need to refactor
          mem_addr_input1 <= MA_H_t;
          mem_input1      <= MI_str_Hplus1_t;
          mem_addr_input2 <= MA_Hplus1_t;
          mem_input2      <= MI_constant_t;

          rd_mem_port1 <= '1';
          rd_mem_port2 <= '1';
          wr_mem_port1 <= '1';
          wr_mem_port2 <= '1';

          wr_mode_reg <= '1';
          mode_value  <= mode_write_t;
        end if;
      when get_structure_t3 => -- refactor at bind input!!!
        bind       <= '1';             -- bind(
        bind_port1 <= BI_deref_unit_t; --    tag(STORE[addr])
        bind_port2 <= BI_mem_port1_t;          --     tag(STORE[H]))

        mem_addr_input1 <= MA_bind_unit_1_t;
        mem_input1      <= MI_bind_unit_1_t;
        mem_addr_input2 <= MA_bind_unit_2_t;
        mem_input2      <= MI_bind_unit_2_t;

        trail_input      <= TI_bind_output_t;
        if bind_done = '1' then
          wr_h_reg   <= '1';             -- H =
          h_input    <= HI_p2_t;           --    H+2
        end if;

     when put_structure_t =>
        wr_mem_port1    <= '1';
        mem_addr_input1 <= MA_H_t;
        mem_input1      <= MI_constant_t;

        wr_h_reg  <= '1';
        h_input   <= HI_p1_t;

        wr_gpr1    <= '1';
        gpr_input1 <= GPRI_str_H_t;

        wr_mode_reg <= '1';
        mode_value  <= mode_write_t;
     when unify_value_t =>
        case mode_reg is
          when mode_read_t =>
            mem_addr_input2   <= MA_S_t;
            rd_mem_port2      <= '1';
            wr_s_reg    <= '1';
            s_reg_input <= SI_p1_t;
            if instruction(0) = '1' then -- if value is on stack. Issue read.
              mem_addr_input1 <= MA_stack_addr_t;
              rd_mem_port1    <= '1';
            end if;
          when mode_write_t =>
            if instruction(0) = '1' then -- value on stack. Issue read.
              mem_addr_input1 <= MA_stack_addr_t;
              rd_mem_port1    <= '1';
            else
              mem_addr_input1 <= MA_H_t;
              mem_input1      <= MI_GPR_t;
              wr_mem_port1    <= '1';

              wr_h_reg        <= '1';
              h_input         <= HI_p1_t;
            end if;
        end case;
     when unify_value_t2 =>
        if mode_reg = mode_read_t then
          start_unify     <= '1';
          unify_input_a   <= UI_mem_port2_t;
          mem_addr_input1 <= MA_unify_unit_t;
          mem_addr_input2 <= MA_unify_unit_t;
          mem_input1      <= MI_unify_unit_t;
          mem_input2      <= MI_unify_unit_t;
          bind_port1      <= BI_unify_unit_t;
          bind_port2      <= BI_unify_unit_t;
          deref_input     <= DI_unify_unit_t;
          if instruction(0) = '1' then -- value on stack
            unify_input_b <= UI_mem_port1_t;
          else
            unify_input_b <= UI_GPR_t;
          end if;
        else
          mem_addr_input2 <= MA_H_t;
          mem_input2      <= MI_mem_port1_t;
          wr_mem_port2    <= '1';

          wr_h_reg        <= '1';
          h_input         <= HI_p1_t;
        end if;
     when unify_variable_t =>
        if mode_reg = mode_read_t then
          mem_addr_input1 <= MA_S_t;
          rd_mem_port1    <= '1';

          wr_s_reg    <= '1';
          s_reg_input <= SI_p1_t;
        else
          mem_addr_input1 <= MA_H_t;
          mem_input1      <= MI_ref_H_t;
          wr_mem_port1    <= '1';

          wr_h_reg        <= '1';
          h_input         <= HI_p1_t;

          if instruction(0) = '1' then --value on stack
            mem_addr_input2 <= MA_stack_addr_t;
            mem_input2      <= MI_ref_H_t;
            wr_mem_port2    <= '1';
          else
            wr_gpr1          <= '1';
            gpr_input1       <= GPRI_ref_H_t;
          end if;
        end if;
     when unify_variable_t2 =>
        if mode_reg = mode_read_t then
          if instruction(0) = '1' then
            mem_addr_input2 <= MA_stack_addr_t;
            mem_input2      <= MI_mem_port1_t;
            wr_mem_port2    <= '1';
          else
            gpr_input1       <= GPRI_mem_port1_t;
            wr_gpr1          <= '1';
          end if;
        end if;
      when put_variable_X_t =>
        wr_gpr1 <= '1';
        wr_gpr2 <= '1';

        gpr_input1 <= GPRI_ref_H_t;
        gpr_input2 <= GPRI_ref_H_t;

        wr_mem_port1    <= '1';
        mem_addr_input1 <= MA_H_t;
        mem_input1     <= MI_ref_H_t;

        wr_h_reg <= '1';
        h_input  <= HI_p1_t;
      when put_variable_Y_t => -- TODO: make addr logic in TopLevel
        wr_gpr1    <= '1';
        gpr_input1 <= GPRI_ref_addr_t;

        wr_mem_port1    <= '1';
        mem_input1     <= MI_ref_addr_t;
        mem_addr_input1 <= MA_addr_t;
      when put_value_t =>
        if instruction(0) = '1' then -- value on stack
          rd_mem_port1    <= '1';
          mem_addr_input1 <= MA_stack_addr_t;
        else
          wr_gpr1    <= '1';
          gpr_input1 <= GPRI_gpr2_t;
        end if;
      when put_value_t2 =>
        wr_gpr1    <= '1';
        gpr_input1 <= GPRI_mem_port1_t;
      when get_variable_t =>
        if instruction(0) = '1' then
          wr_mem_port1    <= '1';
          mem_input1     <= MI_GPR_t;
          mem_addr_input1 <= MA_stack_addr_t;
        else
          gpr_input1 <= GPRI_gpr2_t;
          wr_gpr1    <= '1';
        end if;
      when get_value_t =>
        if instruction(0) = '1' then
          rd_mem_port1    <= '1';
          mem_addr_input1 <= MA_stack_addr_t;
        end if;
      when get_value_t2 =>
        start_unify     <= '1';
        unify_input_a   <= UI_GPR_t;
        mem_addr_input1 <= MA_unify_unit_t;
        mem_addr_input2 <= MA_unify_unit_t;
        mem_input1      <= MI_unify_unit_t;
        mem_input2      <= MI_unify_unit_t;
        bind_port1      <= BI_unify_unit_t;
        bind_port2      <= BI_unify_unit_t;
        deref_input     <= DI_unify_unit_t;
        if instruction(0) = '1' then -- value on stack
          unify_input_b <= UI_mem_port1_t;
        else
          unify_input_b <= UI_GPR_t;
        end if;
      when call_t =>
        p_input   <= PI_instr_t;
        p_wr      <= '1';
        cp_wr     <= '1';
        nrargs_wr <= '1';
      when proceed_t =>
        p_input <= PI_CP_t;
        p_wr    <= '1';
     when others => null;
   end case;
 end process OUTPUT_DECODE;
end Behavioral;
