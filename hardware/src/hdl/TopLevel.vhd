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
   ;led : out std_logic_vector(7 downto 0)
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
signal gpr_address1 : std_logic_vector(kGPRAddressWidth -1 downto 0);
signal gpr_input1   : std_logic_vector(kWamWordWidth -1 downto 0);
signal gpr_output1  : std_logic_vector(kWamWordWidth -1 downto 0);
signal gpr_wr1      : std_logic;
signal gpr_address2 : std_logic_vector(kGPRAddressWidth -1 downto 0);
signal gpr_input2   : std_logic_vector(kWamWordWidth -1 downto 0);
signal gpr_output2  : std_logic_vector(kWamWordWidth -1 downto 0);
signal gpr_wr2      : std_logic;


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
signal dfc_instruction_in     : std_logic_vector(kWamInstructionWidth-1 downto 0);
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
signal dfc_gpr_wr1            : std_logic;
signal dfc_gpr_input1         : gpr_input_t;
signal dfc_gpr_wr2            : std_logic;
signal dfc_gpr_input2         : gpr_input_t;
signal dfc_unify_start        : std_logic;
signal dfc_unify_input_a      : unify_input_t;
signal dfc_unify_input_b      : unify_input_t;
signal dfc_P_input            : p_input_t;
signal dfc_P_wr               : std_logic;
signal dfc_CP_wr              : std_logic;
signal dfc_nr_wr              : std_logic;
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
----- P REGISTER
signal P_reg    : std_logic_vector(kWamInstrMemWidth -1 downto 0);
signal P_comb   : std_logic_vector(kWamInstrMemWidth -1 downto 0);
signal P_wr     : std_logic;
----- CP REGISTER
signal CP_reg    : std_logic_vector(kWamInstrMemWidth -1 downto 0);
signal CP_comb   : std_logic_vector(kWamInstrMemWidth -1 downto 0);
signal CP_wr     : std_logic;

----- NRARGS REGISTER
signal NRARGS_reg : std_logic_vector(kGPRAddressWidth -1 downto 0);
signal NRARGS_wr  : std_logic;

-- TEMPORARYMEMORY
type instr_mem is array (-1 to 20) of std_logic_vector(kWamInstructionWidth - 1 downto 0);
signal mem : instr_mem :=
("11111100000000000000000000000000"
,B"0001_0000000100_00000000000000_0001"  -- put_variable x4, A1
,B"0000_0000000010_00000000000001_0010"  -- put_structure h/2, A2
,B"1000_0000000100_00000000000000_0000"  -- unify_value x4
,B"0111_0000000101_00000000000000_0000"  -- unify_variable x5
,B"0000_0000000011_00000000000010_0001"  -- put_structure f/1, A3
,B"1000_0000000101_00000000000000_0000"  -- unify_value x5
,B"1001_0000000000_00000000001000_0011"  -- call p/3
,"00000000000000000000000000000000"  -- block
,B"0100_0000000001_00000000000010_0001"  -- get_structure f/1, A1
,B"0111_0000000100_00000000000000_0000"  -- unify_variable x4
,B"0100_0000000010_00000000000001_0010"  -- get_structure h/2, A2
,B"0111_0000000101_00000000000000_0000"  -- unify_variable x5
,B"0111_0000000110_00000000000000_0000"  -- unify_variable x6
,B"0110_0000000101_00000000000000_0011"  -- get_value x5, A3
,B"0100_0000000110_00000000000010_0001"  -- get_structure f/1, x6
,B"0111_0000000111_00000000000000_0000"  -- unify_variable x7
,B"0100_0000000111_00000000000011_0000"  -- get_structure a/0, x7
,B"1010_0000000000_00000000000000_0000"  -- proceed
,"00000000000000000000000000000000"  -- block
,"00000000000000000000000000000000"  -- block
,"00000000000000000000000000000000"  -- block
);
signal instruction_counter : unsigned(7 downto 0);
signal instruction         : std_logic_vector(kWamInstructionWidth -1 downto 0);
signal instruction_valid   : std_logic;

signal instr_mem_addr : std_logic_vector(kWamInstrMemWidth -1 downto 0);
signal instr_mem_out  : std_logic_vector(kWamInstructionWidth -1 downto 0);
signal instr_mem_rd   : std_logic;
begin
led <= dfc_mem_word1(7 downto 0);
-- INSTRUCTION MEMORY
instr_mem_addr <= P_reg;
instr_mem_rd <= dfc_get_instruction;
instruction_valid <= '1';
dfc_instruction_in <= instr_mem_out;

-- TEMPORARYMEMORY
INSTCNT: process(clk)
begin
  if rising_edge(clk) then
    if instr_mem_rd = '1' then
      instr_mem_out <= mem(to_integer(unsigned(instr_mem_addr)));
    end if;
  end if;
end process;

-- INSTRMEM: entity work.Memory(Behavioral)
--  generic map
--  (
--    kMemAddressWidth => kWamInstrMemWidth
--   ,kWordWidth       => kWamInstructionWidth
--  )
--  port map
--  (
--   clk => clk
--
--   ,addr_port_1   => instr_mem_addr
--   ,word_port_1_o => instr_mem_out
--   ,word_port_1_i => open
--   ,wr_port_1     => open
--   ,rd_port_1     => instr_mem_rd
--
--   ,addr_port_2   => open
--   ,word_port_2_o => open
--   ,word_port_2_i => open
--   ,wr_port_2     => open
--   ,rd_port_2     => open
--  );

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

-- P REGISTER BEGIN
  PMUX: process(dfc_P_input, P_reg, CP_reg, instr_mem_out)
  begin
    case dfc_P_input is
      when PI_p1_t =>
        P_comb <= std_logic_vector(unsigned(P_reg)+1);
      when PI_CP_t =>
        P_comb <= CP_reg;
      when PI_instr_t =>
        P_comb <= fpwam_instr_addr(instr_mem_out);
      when others =>
        P_comb <= std_logic_vector(unsigned(P_reg)+1);
    end case;
  end process;

  P_wr <= dfc_P_wr;
  PREG: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        P_reg <= (others => '0');
      elsif P_wr = '1' then
        P_reg <= P_comb;
      end if;
    end if;
  end process;

  -- CP REGISTER BEGIN
  CP_wr <= dfc_CP_wr;
  CP_comb <= P_reg;
  CPREG: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        CP_reg <= (others => '0');
      elsif CP_wr = '1' then
        CP_reg <= CP_comb;
      end if;
    end if;
  end process;

-- NRARGS REGISTER BEGIN
  NRARGS_wr <= dfc_nr_wr;
  NRARGSREG: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        NRARGS_reg <= (others => '0');
      elsif NRARGS_wr = '1' then
        NRARGS_reg <= fpwam_instr_arity(instr_mem_out);
      end if;
    end if;
  end process;

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

  ADDR1MUX: process(deref1_res_out,dfc_mem_addr1, H_reg, deref1_mem_addr1, bind_mem_addr1, bind_mem_addr2, unifyComb_mem_addr1, S_reg)
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

  ADDR2MUX: process(deref1_res_out, dfc_mem_addr2, H_reg, deref1_mem_addr1, bind_mem_addr1, bind_mem_addr2, unifyComb_mem_addr2, S_reg)
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

  PORT1MUX: process(dfc_mem_input1, mem_output_2,H_reg, dfc_instruction_in, gpr_output1, bind_mem_word1, bind_mem_word2, unifyComb_mem_word1, mem_input_2)
  begin
    mem_input_1 <= (others => '0');
    case dfc_mem_input1 is
      when MI_str_Hplus1_t =>
        mem_input_1 <= fpwam_word(std_logic_vector(unsigned(H_reg)+1), tag_str_t);
      when MI_constant_t =>
        mem_input_1 <= dfc_instruction_in(kWamWordWidth -1 downto 0);
      when MI_GPR_t =>
        mem_input_1 <= gpr_output1;
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

  PORT2MUX: process(dfc_mem_input2, H_reg, mem_output_1, dfc_instruction_in, gpr_output1, bind_mem_word1, bind_mem_word2, unifyComb_mem_word2, mem_input_1)
  begin
    mem_input_2 <= (others => '0');
    case dfc_mem_input2 is
      when MI_str_Hplus1_t =>
        mem_input_2 <= fpwam_word(std_logic_vector(unsigned(H_reg)+1), tag_str_t);
      when MI_constant_t =>
        mem_input_2 <= dfc_instruction_in(kWamWordWidth -1 downto 0);
      when MI_GPR_t =>
        mem_input_2 <= gpr_output1;
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
  gpr_address1 <= dfc_instruction_in(kGPRAddressWidth-1 + kWamWordWidth downto kWamWordWidth);
  gpr_wr1      <= dfc_gpr_wr1;
  GPRINMUX: process(dfc_gpr_input1, H_reg, mem_output_1, mem_output_2)
  begin
    gpr_input1 <= (others => '0');
    case dfc_gpr_input1 is
      when GPRI_ref_H_t =>
        gpr_input1 <= fpwam_word(H_reg, tag_ref_t);
      when GPRI_mem_port1_t =>
        gpr_input1 <= mem_output_1;
      when GPRI_mem_port2_t =>
        gpr_input1 <= mem_output_2;
      when GPRI_str_H_t =>
        gpr_input1 <= fpwam_word(H_reg, tag_str_t);
      when others =>
        null;
    end case;
  end process;

  gpr_address2 <= dfc_instruction_in(kGPRAddressWidth-1 downto 0);
  gpr_wr2      <= dfc_gpr_wr2;
  GPRINMUX2: process(dfc_gpr_input2, H_reg, mem_output_1, mem_output_2)
  begin
    gpr_input2 <= (others => '0');
    case dfc_gpr_input2 is
      when GPRI_ref_H_t =>
        gpr_input2 <= fpwam_word(H_reg, tag_ref_t);
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
    ,address1     => gpr_address1
    ,wr1          => gpr_wr1
    ,input_word1  => gpr_input1
    ,output_word1 => gpr_output1

    ,address2     => gpr_address2
    ,wr2          => gpr_wr2
    ,input_word2  => gpr_input2
    ,output_word2 => gpr_output2
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
  DEREFINPUTMUX: process(dfc_deref1_input, gpr_output1, mem_output_1, mem_output_2, unify_deref1_out)
  begin
    deref1_word <= (others => '0');
    case dfc_deref1_input is
      when DI_GPR_t =>
        deref1_word <= gpr_output1;
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
  UNIFY1MUX: process(dfc_unify_input_a, gpr_output1, mem_output_1, mem_output_2)
  begin
    unify_word1 <= (others => '0');
    case dfc_unify_input_a is
      when UI_GPR_t =>
        unify_word1 <= gpr_output1;
      when UI_mem_port1_t =>
        unify_word1 <= mem_output_1;
      when UI_mem_port2_t =>
        unify_word1 <= mem_output_2;
      when others =>
        null;
    end case;
  end process;
  UNIFY2MUX: process(dfc_unify_input_b, gpr_output1, mem_output_1, mem_output_2)
  begin
    unify_word2 <= (others => '0');
    case dfc_unify_input_b is
      when UI_GPR_t =>
        unify_word2 <= gpr_output2;
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
    ,wr_gpr1            => dfc_gpr_wr1
    ,gpr_input1         => dfc_gpr_input1
    ,wr_gpr2            => dfc_gpr_wr2
    ,gpr_input2         => dfc_gpr_input2
    ,start_unify        => dfc_unify_start
    ,unify_input_a      => dfc_unify_input_a
    ,unify_input_b      => dfc_unify_input_b
    ,p_input            => dfc_P_input
    ,p_wr               => dfc_P_wr
    ,cp_wr              => dfc_CP_wr
    ,nrargs_wr          => dfc_nr_wr
   );
-- DFC END

end Structural;
