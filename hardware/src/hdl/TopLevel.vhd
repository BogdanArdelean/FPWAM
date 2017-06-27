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
signal dfc_nr_args            : std_logic_vector(kGPRAddressWidth -1 downto 0);
signal dfc_unwind_done        : std_logic;
signal dfc_local_fail         : std_logic;
signal dfc_global_fail        : std_logic;
signal dfc_b_reg              : std_logic_vector(kWamAddressWidth -1 downto 0);
signal dfc_local_fail_rst     : std_logic;
signal dfc_global_fail_out    : std_logic;
signal dfc_global_fail_rst    : std_logic;
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
signal dfc_gpr_addr1          : GPR_addr_input_t;
signal dfc_gpr_input1         : gpr_input_t;
signal dfc_gpr_wr2            : std_logic;
signal dfc_gpr_addr2          : GPR_addr_input_t;
signal dfc_gpr_input2         : gpr_input_t;
signal dfc_unify_start        : std_logic;
signal dfc_unify_input_a      : unify_input_t;
signal dfc_unify_input_b      : unify_input_t;
signal dfc_P_input            : p_input_t;
signal dfc_P_wr               : std_logic;
signal dfc_CP_wr              : std_logic;
signal dfc_CP_input           : cp_input_t;
signal dfc_nr_wr              : std_logic;
signal dfc_nr_input           : nrargs_input_t;
signal dfc_newE_wr            : std_logic;
signal dfc_E_wr               : std_logic;
signal dfc_E_input            : e_input_t;
signal dfc_B_input            : b_input_t;
signal dfc_b_wr               : std_logic;
signal dfc_newB_wr            : std_logic;
signal dfc_tr_wr              : std_logic;
signal dfc_tr_input           : tr_input_t;
signal dfc_hb_wr              : std_logic;
signal dfc_hb_input           : hb_input_t;
signal dfc_i                  : unsigned(kWamAddressWidth -1 downto 0);
signal dfc_start_unwind       : std_logic;
----- TRAIL -----
signal trail_start            : std_logic;
signal trail_address          : std_logic_vector(kWamAddressWidth -1 downto 0);
signal trail_H                : std_logic_vector(kWamAddressWidth -1 downto 0);
signal trail_HB               : std_logic_vector(kWamAddressWidth -1 downto 0);
signal trail_B                : std_logic_vector(kWamAddressWidth -1 downto 0);
signal trail_a                : std_logic_vector(kWamAddressWidth -1 downto 0);
signal trail_do               : std_logic;

signal trailm_addr_1          : std_logic_vector(kWamTrailAddressWidth -1 downto 0);
signal trailm_output_1        : std_logic_vector(kWamAddressWidth -1 downto 0);
signal trailm_input_1         : std_logic_vector(kWamAddressWidth -1 downto 0);
signal trailm_wr_1            : std_logic;
signal trailm_rd_1            : std_logic;
signal trailm_addr_2          : std_logic_vector(kWamTrailAddressWidth -1 downto 0);
signal trailm_output_2        : std_logic_vector(kWamAddressWidth -1 downto 0);
signal trailm_input_2         : std_logic_vector(kWamAddressWidth -1 downto 0);
signal trailm_wr_2            : std_logic;
signal trailm_rd_2            : std_logic;
----- UNWIND TRAIL ----
signal untrail_start          : std_logic;
signal untrail_a1             : std_logic_vector(kWamTrailAddressWidth -1 downto 0);
signal untrail_a2             : std_logic_vector(kWamTrailAddressWidth -1 downto 0);
signal untrail_port_1         : std_logic_vector(kWamAddressWidth -1 downto 0);
signal untrail_port_1_rd      : std_logic;
signal untrail_addr_1         : std_logic_vector(kWamTrailAddressWidth -1 downto 0);
signal untrail_port_2         : std_logic_vector(kWamAddressWidth -1 downto 0);
signal untrail_port_2_rd      : std_logic;
signal untrail_addr_2         : std_logic_vector(kWamTrailAddressWidth -1 downto 0);
signal untrail_mem_port_1     : std_logic_vector(kWamWordWidth -1 downto 0);
signal untrail_mem_port_1_wr  : std_logic;
signal untrail_mem_addr_1     : std_logic_vector(kWamAddressWidth -1 downto 0);
signal untrail_mem_port_2     : std_logic_vector(kWamWordWidth -1 downto 0);
signal untrail_mem_port_2_wr  : std_logic;
signal untrail_mem_addr_2     : std_logic_vector(kWamAddressWidth -1 downto 0);
signal untrail_done           : std_logic;
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
signal NRARGS_reg  : std_logic_vector(kGPRAddressWidth -1 downto 0);
signal NRARGS_comb : std_logic_vector(kGPRAddressWidth -1 downto 0);
signal NRARGS_wr   : std_logic;
----- E REGISTER
signal E_reg  : std_logic_vector(kWamAddressWidth -1 downto 0);
signal E_comb : std_logic_vector(kWamAddressWidth -1 downto 0);
signal E_wr   : std_logic;
----- NewE REGISTER
signal NewE_reg  : std_logic_vector(kWamAddressWidth -1 downto 0);
signal NewE_comb : std_logic_vector(kWamAddressWidth -1 downto 0);
signal NewE_wr   : std_logic;
----- B REGISTER
signal B_reg  : std_logic_vector(kWamAddressWidth -1 downto 0);
signal B_comb : std_logic_vector(kWamAddressWidth -1 downto 0);
signal B_wr   : std_logic;
----- NewB REGISTER
signal NewB_reg  : std_logic_vector(kWamAddressWidth -1 downto 0);
signal NewB_comb : std_logic_vector(kWamAddressWidth -1 downto 0);
signal NewB_wr   : std_logic;
------ TR REGISTER
signal TR_reg   : std_logic_vector(kWamTrailAddressWidth -1 downto 0);
signal TR_comb  : std_logic_vector(kWamTrailAddressWidth -1 downto 0);
signal TR_wr    : std_logic;
------ HB register
signal HB_reg  : std_logic_vector(kWamAddressWidth -1 downto 0);
signal HB_comb : std_logic_vector(kWamAddressWidth -1 downto 0);
signal HB_wr   : std_logic;
------ LOCALFAIL register
signal LCLFAIL_reg  : std_logic;
signal LCLFAIL_comb : std_logic;
signal LCLFAIL_rst  : std_logic;
------ GLOBALFAIL register
signal GLBFAIL_reg  : std_logic;
signal GLBFAIL_comb : std_logic;
signal GLBFAIL_rst  : std_logic;

-- TEMPORARYMEMORY
type instr_mem is array (-1 to 25) of std_logic_vector(kWamInstructionWidth - 1 downto 0);
signal mem : instr_mem :=
("00000000000000000000000000000000"  -- block
,B"00001_000000001_00000000000001_0000"  -- put_structure c/0, A1
,B"00001_000000010_00000000000010_0000"  -- put_structure d/0, A2
,B"01010_000000000_00000000000100_0010"  -- call p/2
,"00000000000000000000000000000000"  -- block
,B"01110_000000000_00000000000000_1001"  -- try_me_else 9    p(X,a).
,B"00110_000000011_00000000000000_0001"  -- get_variable x3,   A1
,B"00101_000000010_00000000000011_0000"  -- get_structure a/0, A2
,B"01011_000000000_00000000000000_0000"  -- proceed.
,"00000000000000000000000000000000"  -- block
,B"01111_000000000_00000000000000_1110"  -- retry_me_else 14    p(b,X)
,B"00101_000000001_00000000000100_0000"  -- get_structure b/0, A1
,B"00110_000000011_00000000000000_0010"  -- get_variable x3,   A2
,B"01011_000000000_00000000000000_0000"  -- proceed.
,"00000000000000000000000000000000"  -- block
,B"10000_000000000_00000000000000_0000"  -- trust_me    p(X,Y) :- p(X, a), p(b, Y).
,B"01100_000000000_00000000000000_0001"  -- allocate 1
,B"00110_000000011_00000000000000_0001"  -- get_variable x3, A1
,B"00110_000010001_00000000000000_0001"  -- get_variable y1, A2
,B"00100_000000011_00000000000000_0001"  -- put_value X3, A1
,B"00001_000000010_00000000000011_0000"  -- put_structure a/0, A2
,B"01010_000000000_00000000000100_0010"  -- call p/2
,B"00001_000000001_00000000000100_0000"  -- put_structure a/0, A1
,B"00100_000010001_00000000000000_0010"  -- put_value Y1, A2
,B"01010_000000000_00000000000100_0010"  -- call p/2
,B"01101_000000000_00000000000100_0000"  -- deallocate
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
      when HI_HB_t =>
        H_comb <= HB_reg;
      when HI_mem_port1_t =>
        H_comb <= mem_output_1(kWamAddressWidth -1 downto 0);
      when HI_mem_port2_t =>
        H_comb <= mem_output_2(kWamAddressWidth -1 downto 0);
      when others =>
        null;
    end case;
  end process;

  HREG: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        H_reg <= kWamHeapStart;
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
      when PI_mem_port1_t =>
        P_comb <= mem_output_1(kWamInstrMemWidth -1 downto 0);
      when PI_mem_port2_t =>
  	  	P_comb <= mem_output_2(kWamInstrMemWidth -1 downto 0);
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
  CP_comb <= P_reg                                       when dfc_CP_input = CPI_P_t else
             mem_output_1(kWamInstrMemWidth -1 downto 0) when dfc_CP_input = CPI_mem_port1_t else
             mem_output_2(kWamInstrMemWidth -1 downto 0);

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
  NRARGS_wr   <= dfc_nr_wr;
  NRARGS_comb <= fpwam_instr_arity(dfc_instruction_in)      when dfc_nr_input = NRARGSI_instr_t else
                 mem_output_1(kGPRAddressWidth -1 downto 0) when dfc_nr_input = NRARGSI_mem_port1_t else
                 mem_output_2(kGPRAddressWidth -1 downto 0);
  NRARGSREG: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        NRARGS_reg <= (others => '0');
      elsif NRARGS_wr = '1' then
        NRARGS_reg <= NRARGS_comb;
      end if;
    end if;
  end process;

-- E REGISTER BEGIN
  E_wr   <= dfc_E_wr;
  E_comb <=   NewE_reg     when dfc_E_input = EI_newE_t else
              mem_output_1(kWamAddressWidth -1 downto 0) when dfc_E_input = EI_mem_port1_t else
              mem_output_2(kWamAddressWidth -1 downto 0);
  EREG: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        E_reg <= kWamStackStart;
      elsif E_wr = '1' then
        E_reg <= E_comb;
      end if;
    end if;
  end process;

-- NewE REGISTER BEGIN
  NewE_wr <= dfc_newE_wr;
  NewE_comb  <=   std_logic_vector(unsigned(mem_output_1(kWamAddressWidth -1 downto 0)) + unsigned(E_reg) + 3) when E_reg > B_reg else
                  std_logic_vector(unsigned(mem_output_1(kWamAddressWidth -1 downto 0)) + unsigned(B_reg) + 7);
  NEWEREG: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        NewE_reg <= kWamStackStart;
      elsif NewE_wr = '1' then
        NewE_reg <= NewE_comb;
      end if;
    end if;
  end process;

-- B REGISTER BEGIN
  B_wr   <= dfc_B_wr;
  B_comb <= NewB_reg when dfc_B_input = BRI_newB_t else
            mem_output_1(kWamAddressWidth -1 downto 0) when dfc_B_input = BRI_mem_port1_t else
            mem_output_2(kWamAddressWidth -1 downto 0);
  BREG: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        B_reg <= kWamStackStart;
      elsif B_wr = '1' then
        B_reg <= B_comb;
      end if;
    end if;
  end process;

-- NewB REGISTER BEGIN
  NewB_wr   <= dfc_newB_wr;
  NewB_comb <= std_logic_vector(unsigned(mem_output_1(kWamAddressWidth -1 downto 0)) + unsigned(E_reg) + 3) when E_reg > B_reg else
               std_logic_vector(unsigned(mem_output_1(kWamAddressWidth -1 downto 0)) + unsigned(B_reg) + 7);
  NEWBREG: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        NewB_reg <= kWamStackStart;
      elsif NewB_wr = '1' then
        NewB_reg <= NewB_comb;
      end if;
    end if;
  end process;

  HB_comb <= H_reg                                       when dfc_hb_input = HBI_H_t else
             mem_output_1(kWamAddressWidth -1 downto 0)  when dfc_hb_input = HBI_mem_port1_t else
             mem_output_2(kWamAddressWidth -1 downto 0);
  HB_wr <= dfc_hb_wr;
  HBREG: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        HB_reg <= kWamStackStart;
      elsif HB_wr = '1' then
        HB_reg <= HB_comb;
      end if;
    end if;
  end process;
-- TR REGISTER
  TR_wr   <= trail_do or dfc_tr_wr;
  TR_comb <= std_logic_vector(unsigned(TR_reg)+1) when dfc_tr_input = TRI_Trp1_t else
             mem_output_1(kWamTrailAddressWidth -1 downto 0) when dfc_tr_input = TRI_mem_port1_t else
             mem_output_2(kWamTrailAddressWidth -1 downto 0);
  TRREG: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        TR_reg <= (others => '0');
      elsif TR_wr = '1' then
        TR_reg <= TR_comb;
      end if;
    end if;
  end process;

  LCLFAIL_comb <= unify_fail;
  LCLFAIL_rst <= dfc_local_fail_rst;
  LCLFAIL: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' or LCLFAIL_rst = '1' then
        LCLFAIL_reg <= '0';
      else
        LCLFAIL_reg <= LCLFAIL_reg or LCLFAIL_comb;
      end if;
    end if;
  end process;

  GLBFAIL_comb <= dfc_global_fail_out;
  GLBFAIL_rst  <= dfc_global_fail_rst;
  GLBFAIL: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' or GLBFAIL_rst = '1' then
        GLBFAIL_reg <= '0';
      else
        GLBFAIL_reg <= GLBFAIL_reg or GLBFAIL_comb;
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
               or dfc_mem_port1_wr
               or untrail_mem_port_1_wr;

  mem_port2_wr <= bind_mem_port2_wr
               or dfc_mem_port2_wr
               or untrail_mem_port_2_wr;

  ADDR1MUX: process(deref1_res_out,dfc_mem_addr1, H_reg, deref1_mem_addr1, bind_mem_addr1, bind_mem_addr2, unifyComb_mem_addr1, S_reg,
                   E_reg, dfc_instruction_in, B_reg, NewE_reg, NewB_reg, NRARGS_reg, dfc_i, untrail_mem_addr_1, mem_output_1)
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
        mem_addr1 <= fpwam_var_stack_addr(dfc_instruction_in, E_reg);
      when MA_S_t =>
        mem_addr1 <= S_reg;
      when MA_untag_deref_t =>
        mem_addr1 <= fpwam_value(deref1_res_out);
      when MA_Ep2orB_t =>
        if E_reg > B_reg then
          mem_addr1 <= std_logic_vector(unsigned(E_reg)+2);
        else
          mem_addr1 <= B_reg;
        end if;
      when MA_newE_t =>
        mem_addr1 <= NewE_reg;
      when MA_newEp1_t =>
        mem_addr1 <= std_logic_vector(unsigned(NewE_reg)+1);
      when MA_newEp2_t =>
        mem_addr1 <= std_logic_vector(unsigned(NewE_reg)+2);
      when MA_E_t =>
        mem_addr1 <= E_reg;
      when MA_Ep1_t =>
        mem_addr1 <= std_logic_vector(unsigned(E_reg)+1);
      when MA_newB_t =>
        mem_addr1 <= NewB_reg;
      when MA_newBNRi_t =>
        mem_addr1 <= std_logic_vector(unsigned(NewB_reg) + unsigned(NRARGS_reg) + dfc_i);
      when MA_newBNRip1_t =>
        mem_addr1 <= std_logic_vector(unsigned(NewB_reg) + unsigned(NRARGS_reg) + dfc_i + 1);
      when MA_newBI_t =>
        mem_addr1 <= std_logic_vector(unsigned(NewB_reg) + dfc_i);
      when MA_newBIp1_t =>
        mem_addr1 <= std_logic_vector(unsigned(NewB_reg) + dfc_i + 1);
      when MA_B_t =>
        mem_addr1 <= B_reg;
      when MA_BI_t =>
        mem_addr1 <= std_logic_vector(unsigned(B_reg) + dfc_i);
      when MA_BIp1_t =>
        mem_addr1 <= std_logic_vector(unsigned(B_reg) + dfc_i + 1);
      when MA_BNRI_t =>
        mem_addr1 <= std_logic_vector(unsigned(B_reg) + unsigned(NRARGS_reg) + dfc_i);
      when MA_BNRIp1_t =>
        mem_addr1 <= std_logic_vector(unsigned(B_reg) + unsigned(NRARGS_reg) + dfc_i + 1);
      when MA_unwind_trail_t =>
        mem_addr1 <= untrail_mem_addr_1;
      when MA_BImem_port1_t =>
        mem_addr1 <= std_logic_vector(unsigned(fpwam_value(mem_output_1)) + unsigned(B_reg) + dfc_i);
      when others =>
        null;
    end case;
  end process;

  ADDR2MUX: process(deref1_res_out, dfc_mem_addr2, H_reg, deref1_mem_addr1, bind_mem_addr1, bind_mem_addr2, unifyComb_mem_addr2, S_reg,
                    E_reg, dfc_instruction_in, B_reg, NewE_reg, NewB_reg, NRARGS_reg, dfc_i, untrail_mem_addr_2)
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
        mem_addr2 <= fpwam_var_stack_addr(dfc_instruction_in, E_reg);
      when MA_S_t =>
        mem_addr2 <= S_reg;
      when MA_untag_deref_t =>
        mem_addr2 <= fpwam_value(deref1_res_out);
        when MA_Ep2orB_t =>
          if E_reg > B_reg then
            mem_addr2 <= std_logic_vector(unsigned(E_reg)+2);
          else
            mem_addr2 <= B_reg;
          end if;
        when MA_newE_t =>
          mem_addr2 <= NewE_reg;
        when MA_newEp1_t =>
          mem_addr2 <= std_logic_vector(unsigned(NewE_reg)+1);
        when MA_newEp2_t =>
          mem_addr2 <= std_logic_vector(unsigned(NewE_reg)+2);
        when MA_E_t =>
          mem_addr2 <= E_reg;
        when MA_Ep1_t =>
          mem_addr2 <= std_logic_vector(unsigned(E_reg)+1);
        when MA_newB_t =>
          mem_addr2 <= NewB_reg;
        when MA_newBNRi_t =>
          mem_addr2 <= std_logic_vector(unsigned(NewB_reg) + unsigned(NRARGS_reg) + dfc_i);
        when MA_newBNRip1_t =>
          mem_addr2 <= std_logic_vector(unsigned(NewB_reg) + unsigned(NRARGS_reg) + dfc_i + 1);
        when MA_newBI_t =>
          mem_addr2 <= std_logic_vector(unsigned(NewB_reg) + dfc_i);
        when MA_newBIp1_t =>
          mem_addr2 <= std_logic_vector(unsigned(NewB_reg) + dfc_i + 1);
        when MA_B_t =>
          mem_addr2 <= B_reg;
        when MA_BI_t =>
          mem_addr2 <= std_logic_vector(unsigned(B_reg) + dfc_i);
        when MA_BIp1_t =>
          mem_addr2 <= std_logic_vector(unsigned(B_reg) + dfc_i + 1);
        when MA_BNRI_t =>
          mem_addr2 <= std_logic_vector(unsigned(B_reg) + unsigned(NRARGS_reg) + dfc_i);
        when MA_BNRIp1_t =>
          mem_addr2 <= std_logic_vector(unsigned(B_reg) + unsigned(NRARGS_reg) + dfc_i + 1);
        when MA_unwind_trail_t =>
          mem_addr2 <= untrail_mem_addr_2;
      when others =>
        null;
    end case;
  end process;

  PORT1MUX: process(dfc_mem_input1, mem_output_2,H_reg, dfc_instruction_in, gpr_output1, bind_mem_word1, bind_mem_word2, unifyComb_mem_word1, mem_input_2,
                  gpr_output1, gpr_output2, E_reg, CP_reg, B_reg, TR_reg, NRARGS_reg, untrail_mem_port_1)
  begin
    mem_input_1 <= (others => '0');
    case dfc_mem_input1 is
      when MI_str_Hplus1_t =>
        mem_input_1 <= fpwam_word(std_logic_vector(unsigned(H_reg)+1), tag_str_t);
      when MI_constant_t =>
        mem_input_1 <= dfc_instruction_in(kWamWordWidth -1 downto 0);
      when MI_GPR_t =>
        mem_input_1 <= gpr_output1;
      when MI_GPR2_t =>
  	  	mem_input_1 <= gpr_output2;
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
      when MI_E_t =>
        mem_input_1 <= "00"&E_reg; -- TEMPORARY FIX
      when MI_CP_t =>
        mem_input_1 <= "00000000"&CP_reg; -- TEMPORARY FIX
      when MI_ref_addr_t =>
  	  	mem_input_1 <= fpwam_word(fpwam_var_stack_addr(dfc_instruction_in, E_reg), tag_ref_t);
      when MI_B_t =>
        mem_input_1 <= "00"&B_reg; -- TEMPORARY FIX
      when MI_TR_t =>
        mem_input_1 <= "00000000"&TR_reg; -- TEMPORARY FIX
      when MI_NRAGRGS_t =>
        mem_input_1 <= "00000000000000"&NRARGS_reg; -- TEMPORARY FIX
      when MI_unwind_trail_t =>
        mem_input_1 <= untrail_mem_port_1;
      when MI_H_t =>
        mem_input_1 <= "00"&H_reg;

      when others =>
        null;
    end case;
  end process;

  PORT2MUX: process(dfc_mem_input2, H_reg, mem_output_1, dfc_instruction_in, gpr_output1, bind_mem_word1, bind_mem_word2, unifyComb_mem_word2, mem_input_1,
                   gpr_output1, gpr_output2, E_reg, CP_reg, B_reg, TR_reg, NRARGS_reg, untrail_mem_port_2)
  begin
    mem_input_2 <= (others => '0');
    case dfc_mem_input2 is
      when MI_str_Hplus1_t =>
        mem_input_2 <= fpwam_word(std_logic_vector(unsigned(H_reg)+1), tag_str_t);
      when MI_constant_t =>
        mem_input_2 <= dfc_instruction_in(kWamWordWidth -1 downto 0);
      when MI_GPR_t =>
        mem_input_2 <= gpr_output1;
      when MI_GPR2_t =>
  	  	mem_input_2 <= gpr_output2;
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
      when MI_E_t =>
        mem_input_2 <= "00"&E_reg; -- TEMPORARY FIX
      when MI_CP_t =>
        mem_input_2 <= "00000000"&CP_reg; -- TEMPORARY FIX
      when MI_ref_addr_t =>
  	  	mem_input_2 <= fpwam_word(fpwam_var_stack_addr(dfc_instruction_in, E_reg), tag_ref_t);
      when MI_B_t =>
        mem_input_2 <= "00"&B_reg; -- TEMPORARY FIX
      when MI_TR_t =>
        mem_input_2 <= "00000000"&TR_reg; -- TEMPORARY FIX
      when MI_NRAGRGS_t =>
        mem_input_2 <= "00000000000000"&NRARGS_reg; -- TEMPORARY FIX
      when MI_unwind_trail_t =>
        mem_input_2 <= untrail_mem_port_2;
      when MI_H_t =>
        mem_input_2 <= "00"&H_reg;

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
  gpr_address1 <= dfc_instruction_in(kGPRAddressWidth-1 + kWamWordWidth downto kWamWordWidth) when dfc_gpr_addr1 = GPRA_instr_t else
                  std_logic_vector(dfc_i(kGPRAddressWidth-1 downto 0)) when dfc_gpr_addr1 = GPRA_I_t else
                  std_logic_vector(dfc_i(kGPRAddressWidth-1 downto 0) + 1);
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
      when GPRI_ref_addr_t =>
  	  	gpr_input1 <= fpwam_word(fpwam_var_stack_addr(dfc_instruction_in, E_reg), tag_ref_t);
      when others =>
        null;
    end case;
  end process;

  gpr_address2 <= dfc_instruction_in(kGPRAddressWidth-1 downto 0) when dfc_gpr_addr2 = GPRA_instr_t else
                  std_logic_vector(dfc_i(kGPRAddressWidth-1 downto 0)) when dfc_gpr_addr2 = GPRA_I_t else
                  std_logic_vector(dfc_i(kGPRAddressWidth-1 downto 0) + 1);
  gpr_wr2      <= dfc_gpr_wr2;
  GPRINMUX2: process(dfc_gpr_input2, H_reg, mem_output_1, mem_output_2)
  begin
    gpr_input2 <= (others => '0');
    case dfc_gpr_input2 is
      when GPRI_ref_H_t =>
        gpr_input2 <= fpwam_word(H_reg, tag_ref_t);
      when GPRI_mem_port1_t =>
          gpr_input2 <= mem_output_1;
      when GPRI_ref_addr_t =>
  	  	gpr_input2 <= fpwam_word(fpwam_var_stack_addr(dfc_instruction_in, E_reg), tag_ref_t);
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
  dfc_nr_args            <= NRARGS_reg;
  dfc_unify_done         <= unify_done;
  dfc_bind_done          <= bind_done;
  dfc_local_fail         <= LCLFAIL_reg;
  dfc_global_fail        <= GLBFAIL_reg;
  dfc_b_reg              <= B_reg;
  dfc_unwind_done        <= untrail_done;
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
    ,nr_args            => dfc_nr_args
    ,unwind_done        => dfc_unwind_done
    ,local_fail         => dfc_local_fail
    ,global_fail        => dfc_global_fail
    ,b_reg              => dfc_b_reg
    ,local_fail_rst     => dfc_local_fail_rst
    ,global_fail_out    => dfc_global_fail_out
    ,global_fail_rst    => dfc_global_fail_rst
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
    ,gpr_addr1          => dfc_gpr_addr1
    ,gpr_input1         => dfc_gpr_input1
    ,wr_gpr2            => dfc_gpr_wr2
    ,gpr_addr2          => dfc_gpr_addr2
    ,gpr_input2         => dfc_gpr_input2
    ,start_unify        => dfc_unify_start
    ,unify_input_a      => dfc_unify_input_a
    ,unify_input_b      => dfc_unify_input_b
    ,p_input            => dfc_P_input
    ,p_wr               => dfc_P_wr
    ,cp_wr              => dfc_CP_wr
    ,cp_input           => dfc_CP_input
    ,nrargs_wr          => dfc_nr_wr
    ,nrargs_input       => dfc_nr_input
    ,newE_wr            => dfc_newE_wr
    ,E_wr               => dfc_E_wr
    ,e_input            => dfc_E_input
    ,b_input            => dfc_B_input
    ,b_wr               => dfc_B_wr
    ,newB_wr            => dfc_newB_wr
    ,tr_wr              => dfc_tr_wr
    ,tr_input           => dfc_tr_input
    ,hb_wr              => dfc_hb_wr
    ,hb_input           => dfc_hb_input
    ,i                  => dfc_i
    ,start_unwind       => dfc_start_unwind
   );
-- DFC END
-- TRAIL BEGIN
trail_start   <= bind_trail;
trail_address <= TR_reg;
trail_H       <= H_reg;
trail_HB      <= HB_reg;
trail_B       <= B_reg;
TRAILUNIT: entity work.TrailUnit(Behavioral)
 generic map
 (
   kAddressWidth => kWamAddressWidth
 )
 port map
 (
   trail          => trail_start
  ,trail_address  => trail_address
  ,H              => trail_H
  ,HB             => trail_HB
  ,B              => trail_B

  ,a              => trail_a
  ,do_trail       => trail_do
 );

trailm_addr_1  <= TR_reg when dfc_trail_input = TI_bind_output_t else
                  untrail_addr_1;
trailm_input_1  <= bind_trail_input;
trailm_wr_1     <= trail_do;
trailm_rd_1     <= untrail_port_1_rd;

trailm_addr_2  <= untrail_addr_2;
trailm_wr_2    <= '0';
trailm_rd_2    <= untrail_port_2_rd;
TRAIL: entity work.Memory(Behavioral)
 generic map
 (
   kMemAddressWidth => kWamTrailAddressWidth
  ,kWordWidth       => kWamAddressWidth
 )
 port map
 (
   clk => clk
  ,addr_port_1   => trailm_addr_1
  ,word_port_1_o => trailm_output_1
  ,word_port_1_i => trailm_input_1
  ,wr_port_1     => trailm_wr_1
  ,rd_port_1     => trailm_rd_1

  ,addr_port_2   => trailm_addr_2
  ,word_port_2_o => trailm_output_2
  ,word_port_2_i => trailm_input_2
  ,wr_port_2     => trailm_wr_2
  ,rd_port_2     => trailm_rd_2
 );

 untrail_start     <= dfc_start_unwind;
 untrail_a1        <= mem_output_1(kWamTrailAddressWidth -1 downto 0);
 untrail_a2        <= TR_reg;
 untrail_port_1    <= trailm_output_1;
 untrail_port_2    <= trailm_output_2;
 UNWINDTRAIL: entity work.UnwindTrailUnit(Behavioral)
  port map
  (
    clk => clk
   ,rst => rst

   ,start_unwind     => untrail_start
   ,a1               => untrail_a1
   ,a2               => untrail_a2
   ,trail_port_1     => untrail_port_1
   ,trail_port_1_rd  => untrail_port_1_rd
   ,trail_addr_1     => untrail_addr_1
   ,trail_port_2     => untrail_port_2
   ,trail_port_2_rd  => untrail_port_2_rd
   ,trail_addr_2     => untrail_addr_2
   ,mem_port_1       => untrail_mem_port_1
   ,mem_port_1_wr    => untrail_mem_port_1_wr
   ,mem_addr_1       => untrail_mem_addr_1
   ,mem_port_2       => untrail_mem_port_2
   ,mem_port_2_wr    => untrail_mem_port_2_wr
   ,mem_addr_2       => untrail_mem_addr_2
   ,done             => untrail_done
  );

end Structural;
