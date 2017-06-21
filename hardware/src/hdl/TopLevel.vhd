-------------------------------------------------------------------------------
-- FILE NAME      : TopLevel.vhd
-- MODULE NAME    : TopLevel
-- AUTHOR         : Bogdan Ardelean
-- AUTHOR'S EMAIL : bogdan.ardelean@yahoo.com
-------------------------------------------------------------------------------
-- REVISION HISTORY
-- VERSION  DATE         AUTHOR            DESCRIPTION
-- 1.0      2016-05-2    Bogdan Ardelean   Created
-------------------------------------------------------------------------------
-- DESCRIPTION    : Unit that binds all other components to form the processor
--
-------------------------------------------------------------------------------
library ieee;
library xil_defaultlib;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.FpwamPkg.all;


entity TopLevel is
  port
  (
    clk : in std_logic
   ;rst : in std_logic
  );
end TopLevel;

architecture Structural of TopLevel is

----- STACK AND HEAP MEMORY ----
signal mem_addr1     : std_logic_vector(kWamAddressWidth -1 downto 0);
signal mem_addr2     : std_logic_vector(kWamAddressWidth -1 downto 0);
signal mem_input_1   : std_logic_vector(kWamWordWidth -1 downto 0);
signal mem_input_2   : std_logic_vector(kWamWordWidth -1 downto 0);
signal mem_output_1  : std_logic_vector(kWamWordWidth -1 downto 0);
signal mem_output_2  : std_logic_vector(kWamWordWidth -1 downto 0);
signal mem_port1_rd  : std_logic;
signal mem_port2_rd  : std_logic;
signal mem_port1_wr  : std_logic;
signal mem_port2_wr  : std_logic;

----- GPRs -----
signal gpr_address : std_logic_vector(kGPRAddressWidth -1 downto 0);
signal gpr_input   : std_logic_vector(kWamWordWidth -1 downto 0);
signal gpr_output  : std_logic_vector(kWamWordWidth -1 downto 0);
signal gpr_wr      : std_logic;

----- BIND UNIT -----
signal bind_start        : std_logic;
signal bind_word1        : std_logic_vector(kWamWordWidth -1 downto 0);
signal bind_word2        : std_logic_vector(kWamWordWidth -1 downto 0);
signal bind_mem_addr1    : std_logic_vector(kWamAddressWidth -1 downto 0);
signal bind_mem_word1    : std_logic_vector(kWamWordWidth -1 downto 0);
signal bind_mem_port1_wr : std_logic;
signal bind_mem_addr2    : std_logic_vector(kWamAddressWidth -1 downto 0);
signal bind_mem_word2    : std_logic_vector(kWamWordWidth -1 downto 0);
signal bind_mem_port2_wr : std_logic;
signal bind_trail_input  : std_logic_vector(kWamAddressWidth -1 downto 0);
signal bind_trail        : std_logic;
signal bind_done         : std_logic;

----- TRAIL UNIT ----
signal trail         : std_logic;
signal trail_address : std_logic_vector(kWamAddressWidth -1 downto 0);
signal trail_H       : std_logic_vector(kWamAddressWidth -1 downto 0);
signal trail_HB      : std_logic_vector(kWamAddressWidth -1 downto 0);
signal trail_B       : std_logic_vector(kWamAddressWidth -1 downto 0);
signal trail_a       : std_logic_vector(kWamAddressWidth -1 downto 0);
signal trail_do      : std_logic;

----- DEREF UNIT1 ----
signal deref1_start        : std_logic;
signal deref1_word         : std_logic_vector(kWamWordWidth -1 downto 0);
signal deref1_mem_word1    : std_logic_vector(kWamWordWidth -1 downto 0);
signal deref1_mem_addr1    : std_logic_vector(kWamAddressWidth -1 downto 0);
signal deref1_mem_port1_rd : std_logic;
signal deref1_res_out      : std_logic_vector(kWamWordWidth -1 downto 0);
signal deref1_done         : std_logic;

----- DEREF UNIT2 ----
----- THIS IS USED JUST BY UNIFYUNIT ----
signal deref2_start        : std_logic;
signal deref2_word         : std_logic_vector(kWamWordWidth -1 downto 0);
signal deref2_mem_word2    : std_logic_vector(kWamWordWidth -1 downto 0);
signal deref2_mem_addr2    : std_logic_vector(kWamAddressWidth -1 downto 0);
signal deref2_mem_port2_rd : std_logic;
signal deref2_res_out      : std_logic_vector(kWamWordWidth -1 downto 0);
signal deref2_done         : std_logic;

----- UNIFY UNIT ----
signal unify_start         : std_logic;
signal unify_word1         : std_logic_vector(kWamWordWidth -1 downto 0);
signal unify_word2         : std_logic_vector(kWamWordWidth -1 downto 0);
signal unify_mem_word1     : std_logic_vector(kWamWordWidth -1 downto 0);
signal unify_mem_word2     : std_logic_vector(kWamWordWidth -1 downto 0);
signal unify_deref1_in     : std_logic_vector(kWamWordWidth -1 downto 0);
signal unify_deref1_done   : std_logic;
signal unify_deref2_in     : std_logic_vector(kWamWordWidth -1 downto 0);
signal unify_deref2_done   : std_logic;
signal unify_bind_done     : std_logic;
signal unify_done          : std_logic;
signal unify_fail          : std_logic;
signal unify_mem_addr1     : std_logic_vector(kWamAddressWidth -1 downto 0);
signal unify_mem_port1_rd  : std_logic;
signal unify_mem_addr2     : std_logic_vector(kWamAddressWidth -1 downto 0);
signal unify_mem_port2_rd  : std_logic;
signal unify_deref1_out    : std_logic_vector(kWamWordWidth -1 downto 0);
signal unify_deref1_start  : std_logic;
signal unify_deref2_out    : std_logic_vector(kWamWordWidth -1 downto 0);
signal unify_deref2_start  : std_logic;
signal unify_bind_word1    : std_logic_vector(kWamWordWidth -1 downto 0);
signal unify_bind_word2    : std_logic_vector(kWamWordWidth -1 downto 0);
signal unify_bind_start    : std_logic;
signal unify_mem_sel       : unify_mem_sel_t;

signal unifyComb_mem_addr1 : std_logic_vector(kWamAddressWidth -1 downto 0);
signal unifyComb_mem_addr2 : std_logic_vector(kWamAddressWidth -1 downto 0);
signal unifyComb_mem_word1 : std_logic_vector(kWamWordWidth -1 downto 0);
signal unifyComb_mem_word2 : std_logic_vector(kWamWordWidth -1 downto 0);

----- DATAFLOWCONTROL UNIT ----
signal dfc_instruction_in     : std_logic_vector(kInstructionWidth-1 downto 0);
signal dfc_instruction_valid  : std_logic;
signal dfc_mem_word1          : std_logic_vector(kWamWordWidth -1 downto 0);
signal dfc_deref1_done        : std_logic;
signal dfc_mode_reg           : wam_mode_t;
signal dfc_unify_done         : std_logic;
signal dfc_bind_done          : std_logic;
signal dfc_get_instruction    : std_logic;
signal dfc_deref1_start       : std_logic;
signal dfc_deref1_input       : deref_input_t;
signal dfc_S_wr               : std_logic;
signal dfc_S_input            : s_input_t;
signal dfc_mode_wr            : std_logic;
signal dfc_mode_value         : wam_mode_t;
signal dfc_mem_port1_rd       : std_logic;
signal dfc_mem_port1_wr       : std_logic;
signal dfc_mem_input1         : mem_port_input_t;
signal dfc_mem_addr1          : mem_addr_input_t;
signal dfc_mem_port2_rd       : std_logic;
signal dfc_mem_port2_wr       : std_logic;
signal dfc_mem_input2         : mem_port_input_t;
signal dfc_mem_addr2          : mem_addr_input_t;
signal dfc_bind_start         : std_logic;
signal dfc_bind_port1         : bind_input_t;
signal dfc_bind_port2         : bind_input_t;
signal dfc_trail_input        : trail_input_t;
signal dfc_H_wr               : std_logic;
signal dfc_H_input            : h_input_t;
signal dfc_gpr_wr             : std_logic;
signal dfc_gpr_input          : GPR_input_t;
signal dfc_unify_start        : std_logic;
signal dfc_unify_input_a      : unify_input_t;
signal dfc_unify_input_b      : unify_input_t;

----- REGISTERS ------

----- H REGISTER
signal H_reg    : std_logic_vector(kWamAddressWidth -1 downto 0);
signal H_comb   : std_logic_vector(kWamAddressWidth -1 downto 0);
signal H_wr     : std_logic;
----- S REGISTER
signal S_reg    : std_logic_vector(kWamAddressWidth -1 downto 0);
signal S_comb   : std_logic_vector(kWamAddressWidth -1 downto 0);
signal S_wr     : std_logic;
----- MODE REGISTER
signal M_reg    : wam_mode_t;
signal M_comb   : wam_mode_t;
signal M_wr     : std_logic;

-- TEMPORARYMEMORY
type instr_mem is array (-1 to 21) of std_logic_vector(kInstructionWidth - 1 downto 0);
signal mem : instr_mem :=
("00000000000000000000000000000000"
,"00000000000011000000000000010010"  -- put_structure h/2, x3
,"01000000000010000000000000000000"  -- unify_variable x2
,"01000000000101000000000000000000"  -- unify_variable x5
,"00000000000100000000000000100001"  -- put_structure f/1, x4
,"01100000000101000000000000000000"  -- unify_value x5
,"00000000000001000000000000110011"  -- put_structure p/3, x1
,"01100000000010000000000000000000"  -- unify_value x2
,"01100000000011000000000000000000"  -- unify_value x3
,"01100000000100000000000000000000"  -- unify_value x4
,"00100000000001000000000000110011"  -- get_structure p/3, x1
,"01000000000010000000000000000000"  -- unify_variable x2
,"01000000000011000000000000000000"  -- unify_variable x3
,"01000000000100000000000000000000"  -- unify_variable x4
,"00100000000010000000000000100001"  -- get_structure f/1, x2
,"01000000000101000000000000000000"  -- unify_variable x5
,"00100000000011000000000000010010"  -- get_structure h/2, x3
,"01100000000100000000000000000000"  -- unify_value x4
,"01000000000110000000000000000000"  -- unify_variable x6
,"00100000000110000000000000100001"  -- get_structure f/1, x6
,"01000000000111000000000000000000"  -- unify_variable x7
,"00100000000111000000000001000000"  -- get_structure a/0, x7
);
signal instruction_counter : unsigned(7 downto 0);
signal instruction         : std_logic_vector(kInstructionWidth -1 downto 0);
signal current_instruction : std_logic_vector(kInstructionWidth -1 downto 0);
signal instruction_valid   : std_logic;
begin

-- INSTRUCTIONS
  instruction         <= mem(to_integer(instruction_counter));
  current_instruction <= mem(to_integer(instruction_counter)-1);
  instruction_valid <= '1';
  INSTCNT: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        instruction_counter <= (others => '0');
        dfc_instruction_in <= instruction;
      elsif dfc_get_instruction = '1' then
        instruction_counter <= instruction_counter + 1;
        dfc_instruction_in <= instruction;
      end if;
    end if;
  end process;



-- MODE REGISTER BEGIN
  M_wr   <= dfc_mode_wr;
  M_comb <= dfc_mode_value;
  MREG: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        M_reg <= mode_read_t;
      elsif M_wr = '1' then
        M_reg <= M_comb;
      end if;
    end if;
  end process;

-- H REGISTER BEGIN
  H_wr <= dfc_H_wr;
  HMUX: process(dfc_H_input, H_reg)
  begin
    H_comb <= H_reg;
    case dfc_H_input is
      when HI_p1_t =>
        H_comb <= std_logic_vector(unsigned(H_reg) + 1);
      when HI_p2_t =>
        H_comb <= std_logic_vector(unsigned(H_reg) + 2);
      when others =>
        null;
    end case;
  end process;

  HREG: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        H_reg <= (others => '0');
      elsif H_wr = '1' then
        H_reg <= H_comb;
      end if;
    end if;
  end process;
-- H REGISTER END
-- S REGISTER START
  S_wr <= dfc_S_wr;
  SMUX: process(dfc_S_input, S_reg, deref1_res_out)
  begin
    S_comb <= S_reg;
    case dfc_S_input is
      when SI_untag_deref_p1_t =>
        S_comb <= std_logic_vector(unsigned(fpwam_value(deref1_res_out))+1);
      when SI_p1_t =>
        S_comb <= std_logic_vector(unsigned(S_reg)+1);
      when others =>
        null;
    end case;
  end process;

  SREG: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        S_reg <= (others => '0');
      elsif S_wr = '1' then
        S_reg <= S_comb;
      end if;
    end if;
  end process;
-- S REGISTER END

-- STACK AND HEAP MEMORY BEGIN
  mem_port1_rd <= deref1_mem_port1_rd
               or unify_mem_port1_rd
               or dfc_mem_port1_rd;

  mem_port2_rd <= deref2_mem_port2_rd
               or unify_mem_port2_rd
               or dfc_mem_port2_rd;

  mem_port1_wr <= bind_mem_port1_wr
               or dfc_mem_port1_wr;

  mem_port2_wr <= bind_mem_port2_wr
               or dfc_mem_port2_wr;

  ADDR1MUX: process(dfc_mem_addr1, H_reg, deref1_mem_addr1, bind_mem_addr1, bind_mem_addr2, unifyComb_mem_addr1, S_reg)
  begin
    mem_addr1 <= (others => '0');
    case dfc_mem_addr1 is
      when MA_H_t =>
        mem_addr1 <= H_reg;
      when MA_Hplus1_t =>
        mem_addr1 <= std_logic_vector(unsigned(H_reg)+1);
      when MA_deref_unit_t =>
        mem_addr1 <= deref1_mem_addr1;
      when MA_bind_unit_1_t =>
        mem_addr1 <= bind_mem_addr1;
      when MA_bind_unit_2_t =>
        mem_addr1 <= bind_mem_addr2;
      when MA_unify_unit_t =>
        mem_addr1 <= unifyComb_mem_addr1;
      when MA_stack_addr_t => -- TODO
        mem_addr1 <= (others => '0');
      when MA_S_t =>
        mem_addr1 <= S_reg;
      when MA_untag_deref_t =>
        mem_addr1 <= fpwam_value(deref1_res_out);
      when others =>
        null;
    end case;
  end process;

  ADDR2MUX: process(dfc_mem_addr2, H_reg, deref1_mem_addr1, bind_mem_addr1, bind_mem_addr2, unifyComb_mem_addr2, S_reg)
  begin
    mem_addr2 <= (others => '0');
    case dfc_mem_addr2 is
      when MA_H_t =>
        mem_addr2 <= H_reg;
      when MA_Hplus1_t =>
        mem_addr2 <= std_logic_vector(unsigned(H_reg)+1);
      when MA_deref_unit_t =>
        mem_addr2 <= deref1_mem_addr1;
      when MA_bind_unit_1_t =>
        mem_addr2 <= bind_mem_addr1;
      when MA_bind_unit_2_t =>
        mem_addr2 <= bind_mem_addr2;
      when MA_unify_unit_t =>
        mem_addr2 <= unifyComb_mem_addr2;
      when MA_stack_addr_t => -- TODO
        mem_addr2 <= (others => '0');
      when MA_S_t =>
        mem_addr2 <= S_reg;
      when MA_untag_deref_t =>
        mem_addr2 <= fpwam_value(deref1_res_out);
      when others =>
        null;
    end case;
  end process;

  PORT1MUX: process(dfc_mem_input1,mem_output_2,H_reg, current_instruction, gpr_output, bind_mem_word1, bind_mem_word2, unifyComb_mem_word1, mem_input_2)
  begin
    mem_input_1 <= (others => '0');
    case dfc_mem_input1 is
      when MI_str_Hplus1_t =>
        mem_input_1 <= fpwam_word(std_logic_vector(unsigned(H_reg)+1), tag_str_t);
      when MI_constant_t =>
        mem_input_1 <= current_instruction(kWamWordWidth -1 downto 0);
      when MI_GPR_t =>
        mem_input_1 <= gpr_output;
      when MI_bind_unit_1_t =>
        mem_input_1 <= bind_mem_word1;
      when MI_bind_unit_2_t =>
        mem_input_1 <= bind_mem_word2;
      when MI_unify_unit_t =>
        mem_input_1 <= unifyComb_mem_word1;
      when MI_ref_H_t =>
        mem_input_1 <= fpwam_word(H_reg, tag_ref_t);
      when MI_mem_port2_t =>
        mem_input_1 <= mem_output_2;
      when others =>
        null;
    end case;
  end process;

  PORT2MUX: process(dfc_mem_input2, H_reg, mem_output_1, current_instruction, gpr_output, bind_mem_word1, bind_mem_word2, unifyComb_mem_word2, mem_input_1)
  begin
    mem_input_2 <= (others => '0');
    case dfc_mem_input2 is
      when MI_str_Hplus1_t =>
        mem_input_2 <= fpwam_word(std_logic_vector(unsigned(H_reg)+1), tag_str_t);
      when MI_constant_t =>
        mem_input_2 <= current_instruction(kWamWordWidth -1 downto 0);
      when MI_GPR_t =>
        mem_input_2 <= gpr_output;
      when MI_bind_unit_1_t =>
        mem_input_2 <= bind_mem_word1;
      when MI_bind_unit_2_t =>
        mem_input_2 <= bind_mem_word2;
      when MI_unify_unit_t =>
        mem_input_2 <= unifyComb_mem_word2;
      when MI_ref_H_t =>
        mem_input_2 <= fpwam_word(H_reg, tag_ref_t);
      when MI_mem_port1_t =>
        mem_input_2 <= mem_output_1;
      when others =>
        null;
    end case;
  end process;

  HEAPSTACK: entity work.Memory(Behavioral)
   generic map
   (
     kMemAddressWidth => kWamAddressWidth
    ,kWordWidth       => kWamWordWidth
   )
   port map
   (
    clk => clk

    ,addr_port_1   => mem_addr1
    ,word_port_1_o => mem_output_1
    ,word_port_1_i => mem_input_1
    ,wr_port_1     => mem_port1_wr
    ,rd_port_1     => mem_port1_rd

    ,addr_port_2   => mem_addr2
    ,word_port_2_o => mem_output_2
    ,word_port_2_i => mem_input_2
    ,wr_port_2     => mem_port2_wr
    ,rd_port_2     => mem_port2_rd
   );
-- STACK AND HEAP MEMORY END

-- GPRs BEGIN
  gpr_address <= dfc_instruction_in(kGPRAddressWidth-1 + kWamWordWidth downto kWamWordWidth);
  gpr_wr    <= dfc_gpr_wr;
  GPRINMUX: process(dfc_gpr_input, H_reg, mem_output_1, mem_output_2)
  begin
    gpr_input <= (others => '0');
    case dfc_gpr_input is
      when GPRI_ref_H_t =>
        gpr_input <= fpwam_word(H_reg, tag_ref_t);
      when GPRI_mem_port1_t =>
        gpr_input <= mem_output_1;
      when GPRI_mem_port2_t =>
        gpr_input <= mem_output_2;
      when GPRI_str_H_t =>
        gpr_input <= fpwam_word(H_reg, tag_str_t);
      when others =>
        null;
    end case;
  end process;

  GPRS: entity work.GPR(Behavioral)
   generic map
   (
    kAddressWidth => kGPRAddressWidth
    ,kWordWidth    => kWamWordWidth
   )
   port map
   (
    clk         => clk
    ,address     => gpr_address
    ,wr          => gpr_wr
    ,input_word  => gpr_input
    ,output_word => gpr_output
   );
-- GPRs END

-- BIND START
  bind_start <= dfc_bind_start
             or unify_bind_start;
  BINDINPUT1MUX: process(dfc_bind_port1, deref1_res_out, mem_output_1, unify_bind_word1)
  begin
    bind_word1 <= (others => '0');
    case dfc_bind_port1 is
      when BI_deref_unit_t =>
        bind_word1 <= deref1_res_out;
      when BI_mem_port1_t =>
        bind_word1 <= mem_output_1;
      when BI_unify_unit_t =>
        bind_word1 <= unify_bind_word1;
      when others =>
        null;
    end case;
  end process;

  BINDINPUT2MUX: process(dfc_bind_port2, deref1_res_out, mem_output_1, unify_bind_word2)
  begin
    bind_word2 <= (others => '0');
    case dfc_bind_port2 is
      when BI_deref_unit_t =>
        bind_word2 <= deref1_res_out;
      when BI_mem_port1_t =>
        bind_word2 <= mem_output_1;
      when BI_unify_unit_t =>
        bind_word2 <= unify_bind_word2;
      when others =>
        null;
    end case;
  end process;

  BINDUNIT: entity work.BindUnit(Behavioral)
   generic map
   (
     kAddressWidth => kWamAddressWidth
    ,kWordWidth    => kWamWordWidth
   )
   port map
   (
     clk          => clk
    ,rst          => rst
    ,start_bind   => bind_start
    ,start_word1  => bind_word1
    ,start_word2  => bind_word2
    ,mem_addr1    => bind_mem_addr1
    ,mem_out1     => bind_mem_word1
    ,mem_wr_1     => bind_mem_port1_wr
    ,mem_addr2    => bind_mem_addr2
    ,mem_out2     => bind_mem_word2
    ,mem_wr_2     => bind_mem_port2_wr
    ,trail_input  => bind_trail_input
    ,trail        => bind_trail
    ,bind_done    => bind_done
   );
-- BIND end

-- TRAIL BEGIN
  -- TODO TRAIL
-- TRAIL END
-- DEREF1 START
  deref1_start <= dfc_deref1_start
               or unify_deref1_start;
  deref1_mem_word1 <= mem_output_1;
  DEREFINPUTMUX: process(dfc_deref1_input, gpr_output, mem_output_1, mem_output_2, unify_deref1_out)
  begin
    deref1_word <= (others => '0');
    case dfc_deref1_input is
      when DI_GPR_t =>
        deref1_word <= gpr_output;
      when DI_unify_unit_t =>
        deref1_word <= unify_deref1_out;
      when others =>
        null;
    end case;
  end process;

  DEREF1: entity work.DerefUnit(Behavioral)
   generic map
   (
     kAddressWidth => kWamAddressWidth
    ,kWordWidth    => kWamWordWidth
   )
   port map
   (
     clk         => clk
    ,rst         => rst
    ,start_deref => deref1_start
    ,start_word  => deref1_word
    ,memory_in   => deref1_mem_word1
    ,addr_out    => deref1_mem_addr1
    ,rd_mem      => deref1_mem_port1_rd
    ,res_out     => deref1_res_out
    ,done        => deref1_done
   );
-- DEREF1 END
-- DEREF2 START
  deref2_start     <= unify_deref2_start;
  deref2_mem_word2 <= mem_output_2;
  deref2_word      <= unify_deref2_out;
  DEREF2: entity work.DerefUnit(Behavioral)
   generic map
   (
     kAddressWidth => kWamAddressWidth
    ,kWordWidth    => kWamWordWidth
   )
   port map
   (
     clk         => clk
    ,rst         => rst
    ,start_deref => deref2_start
    ,start_word  => deref2_word
    ,memory_in   => deref2_mem_word2
    ,addr_out    => deref2_mem_addr2
    ,rd_mem      => deref2_mem_port2_rd
    ,res_out     => deref2_res_out
    ,done        => deref2_done
   );
-- DEREF2 END
-- UNIFYUNIT START
  unify_start <= dfc_unify_start;
  UNIFY1MUX: process(dfc_unify_input_a, gpr_output, mem_output_1, mem_output_2)
  begin
    unify_word1 <= (others => '0');
    case dfc_unify_input_a is
      when UI_GPR_t =>
        unify_word1 <= gpr_output;
      when UI_mem_port1_t =>
        unify_word1 <= mem_output_1;
      when UI_mem_port2_t =>
        unify_word1 <= mem_output_2;
      when others =>
        null;
    end case;
  end process;
  UNIFY2MUX: process(dfc_unify_input_b, gpr_output, mem_output_1, mem_output_2)
  begin
    unify_word2 <= (others => '0');
    case dfc_unify_input_b is
      when UI_GPR_t =>
        unify_word2 <= gpr_output;
      when UI_mem_port1_t =>
        unify_word2 <= mem_output_1;
      when UI_mem_port2_t =>
        unify_word2 <= mem_output_2;
      when others =>
        null;
    end case;
  end process;

  UNIFYMEMSEL: process(unify_mem_sel, unify_mem_addr1, unify_mem_addr2, deref1_mem_addr1, deref2_mem_addr2, deref1_mem_word1, deref2_mem_word2, bind_mem_word1, bind_mem_word2, bind_mem_addr1, bind_mem_addr2)
  begin

    unifyComb_mem_addr1 <= (others => '0');
    unifyComb_mem_addr2 <= (others => '0');
    unifyComb_mem_word1 <= (others => '0');
    unifyComb_mem_word2 <= (others => '0');

    case unify_mem_sel is
      when sel_unify_t =>
        unifyComb_mem_addr1 <= unify_mem_addr1;
        unifyComb_mem_addr2 <= unify_mem_addr2;
      when sel_deref_t =>
        unifyComb_mem_addr1 <= deref1_mem_addr1;
        unifyComb_mem_addr2 <= deref2_mem_addr2;
        unifyComb_mem_word1 <= deref1_mem_word1;
        unifyComb_mem_word2 <= deref2_mem_word2;
      when sel_bind_t  =>
        unifyComb_mem_addr1 <= bind_mem_addr1;
        unifyComb_mem_addr2 <= bind_mem_addr2;
        unifyComb_mem_word1 <= bind_mem_word1;
        unifyComb_mem_word2 <= bind_mem_word2;
      when others =>
        null;
    end case;
  end process;
  unify_mem_word1 <= mem_output_1;
  unify_mem_word2 <= mem_output_2;
  UNIFYU: entity work.UnifyUnit(Behavioral)
   generic map
   (
     kAddressWidth     => kWamAddressWidth
    ,kWordWidth        => kWamWordWidth
    ,kPdlAddressWidth  => kWamPdlAddressWidth
   )
   port map
   (
     clk            => clk
    ,rst            => rst
    ,start_unify    => unify_start
    ,word1          => unify_word1
    ,word2          => unify_word2
    ,mem1_input     => unify_mem_word1
    ,mem2_input     => unify_mem_word2
    ,deref1_input   => deref1_res_out
    ,deref1_done    => deref1_done
    ,deref2_input   => deref2_res_out
    ,deref2_done    => deref2_done
    ,bind_done      => bind_done
    ,unify_done     => unify_done
    ,fail           => unify_fail
    ,mem1_output    => unify_mem_addr1
    ,rd_mem_port1   => unify_mem_port1_rd
    ,mem2_output    => unify_mem_addr2
    ,rd_mem_port2   => unify_mem_port2_rd
    ,deref1_output  => unify_deref1_out
    ,deref1_start   => unify_deref1_start
    ,deref2_output  => unify_deref2_out
    ,deref2_start   => unify_deref2_start
    ,bind1_output   => unify_bind_word1
    ,bind2_output   => unify_bind_word2
    ,bind_start     => unify_bind_start
    ,mem_sel        => unify_mem_sel
   );
-- UNIFYUNIT END
-- DFC BEGIN
  dfc_instruction_valid  <= instruction_valid;
  dfc_mem_word1          <= mem_output_2;
  dfc_deref1_done        <= deref1_done;
  dfc_mode_reg           <= M_reg;
  dfc_unify_done         <= unify_done;
  dfc_bind_done          <= bind_done;
  DFC: entity work.DataFlowControl(Behavioral)
   port map
   (
     clk                => clk
    ,rst                => rst
    ,instruction        => dfc_instruction_in
    ,instruction_valid  => dfc_instruction_valid
    ,mem_obj            => dfc_mem_word1
    ,deref_done         => dfc_deref1_done
    ,mode_reg           => dfc_mode_reg
    ,unify_done         => dfc_unify_done
    ,bind_done          => dfc_bind_done
    ,get_instruction    => dfc_get_instruction
    ,start_deref        => dfc_deref1_start
    ,deref_input        => dfc_deref1_input
    ,wr_s_reg           => dfc_S_wr
    ,s_reg_input        => dfc_S_input
    ,wr_mode_reg        => dfc_mode_wr
    ,mode_value         => dfc_mode_value
    ,rd_mem_port1       => dfc_mem_port1_rd
    ,wr_mem_port1       => dfc_mem_port1_wr
    ,mem_input1         => dfc_mem_input1
    ,mem_addr_input1    => dfc_mem_addr1
    ,rd_mem_port2       => dfc_mem_port2_rd
    ,wr_mem_port2       => dfc_mem_port2_wr
    ,mem_input2         => dfc_mem_input2
    ,mem_addr_input2    => dfc_mem_addr2
    ,bind               => dfc_bind_start
    ,bind_port1         => dfc_bind_port1
    ,bind_port2         => dfc_bind_port2
    ,trail_input        => dfc_trail_input
    ,wr_h_reg           => dfc_H_wr
    ,h_input            => dfc_H_input
    ,wr_gpr             => dfc_gpr_wr
    ,gpr_input          => dfc_gpr_input
    ,start_unify        => dfc_unify_start
    ,unify_input_a      => dfc_unify_input_a
    ,unify_input_b      => dfc_unify_input_b
   );
-- DFC END

end Structural;
