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
    clk : in std_logic;
    rst : in std_logic
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
signal S_comb   : std_logic;
signal S_wr     : std_logic;
----- MODE REGISTER
signal M_reg    : wam_mode_t;
signal M_comb   : wam_mode_t;
signal M_wr     : std_logic;

begin

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
  HMUX: process(dfc_H_input)
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
  SMUX: process(dfc_S_input)
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

  ADDR1MUX: process(dfc_mem_addr1)
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
      when others =>
        null;
    end case;
  end process;

  ADDR2MUX: process(dfc_mem_addr2)
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
      when others =>
        null;
    end case;
  end process;

  PORT1MUX: process(dfc_mem_input1)
  begin
    mem_input_1 <= (others => '0');
    case dfc_mem_input1 is
      when MI_str_Hplus1_t =>
        mem_input_1 <= fpwam_word(std_logic_vector(unsigned(H_reg)+1), tag_str_t);
      when MI_constant_t =>
        mem_input_1 <= dfc_instruction_in(kWamWordWidth -1 downto 0);
      when MI_GPR_t =>
        mem_input_1 <= gpr_output;
      when MI_bind_unit_1_t =>
        mem_input_1 <= bind_mem_word1;
      when MI_bind_unit_2_t =>
        mem_input_1 <= bind_mem_word2;
      when MI_unify_unit_t =>
        mem_input_1 <= unifyComb_mem_word1;
      when MI_mem_port2_t =>
        mem_input_1 <= mem_input_2;
      when others =>
        null;
    end case;
  end process;

  PORT2MUX: process(dfc_mem_input2)
  begin
    mem_input_2 <= (others => '0');
    case dfc_mem_input2 is
      when MI_str_Hplus1_t =>
        mem_input_2 <= fpwam_word(std_logic_vector(unsigned(H_reg)+1), tag_str_t);
      when MI_constant_t =>
        mem_input_2 <= dfc_instruction_in(kWamWordWidth -1 downto 0);
      when MI_GPR_t =>
        mem_input_2 <= gpr_output;
      when MI_bind_unit_1_t =>
        mem_input_2 <= bind_mem_word1;
      when MI_bind_unit_2_t =>
        mem_input_2 <= bind_mem_word2;
      when MI_unify_unit_t =>
        mem_input_2 <= unifyComb_mem_word2;
      when MI_mem_port1_t =>
        mem_input_2 <= mem_input_1;
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
  GPRINMUX: process(dfc_gpr_input)
  begin
    gpr_input <= (others => '0');
    case dfc_gpr_input is
      when GPRI_ref_H_t =>
        gpr_input <= fpwam_word(H_reg, tag_ref_t);
      when GPRI_mem_port1_t =>
        gpr_input <= mem_output_1;
      when GPRI_mem_port2_t =>
        gpr_input <= mem_output_2;
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
  BINDINPUT1MUX: process(dfc_bind_port1)
  begin
    bind_word1 <= (others => '0');
    case dfc_bind_port1 is
      when BI_deref_unit_t =>
        bind_word1 <= deref1_output;
      when BI_mem_port1_t =>
        bind_word1 <= mem_output_1;
      when BI_unify_unit_t =>
        bind_word1 <= unify_bind_word1;
      when others =>
        null;
    end case;
  end process;

  BINDINPUT2MUX: process(dfc_bind_port2)
  begin
    bind_word2 <= (others => '0');
    case dfc_bind_port2 is
      when BI_deref_unit_t =>
        bind_word2 <= deref1_output;
      when BI_mem_port1_t =>
        bind_word2 <= mem_output_21;
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
    ,done_t      => deref1_done
   );

end Structural;
