-------------------------------------------------------------------------------
-- FILE NAME      : BindUnit.vhd
-- MODULE NAME    : BindUnit
-- AUTHOR         : Bogdan Ardelean
-- AUTHOR'S EMAIL : bogdan.ardelean@yahoo.com
-------------------------------------------------------------------------------
-- REVISION HISTORY
-- VERSION  DATE         AUTHOR            DESCRIPTION
-- 1.0      2016-05-2    Bogdan Ardelean   Created
-------------------------------------------------------------------------------
-- DESCRIPTION    : Unit that executes the bind(a1, a2) WAM ancillary operation
--
-------------------------------------------------------------------------------
library ieee;
library xil_defaultlib;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.FpwamPkg.all;

entity BindUnit is
  generic
  (
    kAddressWidth : natural := kWamAddressWidth; -- 16
    kWordWidth    : natural := kWamWordWidth     -- 18
  );
  port
  (
    clk         : in  std_logic;
    rst         : in  std_logic;

    start_bind  : in  std_logic;

    start_word1 : in  std_logic_vector(kWordWidth -1 downto 0);
    start_word2 : in  std_logic_vector(kWordWidth -1 downto 0);

    mem_addr1   : out std_logic_vector(kAddressWidth -1 downto 0);
    mem_out1    : out std_logic_vector(kWordWidth -1 downto 0);
    mem_wr_1    : out std_logic;

    mem_addr2   : out std_logic_vector(kAddressWidth -1 downto 0);
    mem_out2    : out std_logic_vector(kWordWidth -1 downto 0);
    mem_wr_2    : out std_logic;

    trail_input : out std_logic_vector(kAddressWidth -1 downto 0);
    trail       : out std_logic;

    bind_done   : out std_logic
  );
end BindUnit;


architecture Behavioral of BindUnit is
type state_t is (idle_t, bind_t);
signal cr_state, nx_state : state_t;

signal word1_reg       : std_logic_vector(kWordWidth -1 downto 0);
signal word2_reg       : std_logic_vector(kWordWidth -1 downto 0);
signal register_input  : std_logic;

begin

  REGINPUT: process(clk, rst)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        word1_reg <= (others => '0');
        word2_reg <= (others => '0');
      elsif register_input = '1' then
        word1_reg <= start_word1;
        word2_reg <= start_word2;
      end if;
    end if;
  end process;

  FSM: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        cr_state <= idle_t;
      else
        cr_state <= nx_state;
      end if;
    end if;
  end process;

  NEXT_STATE: process(cr_state, start_bind)
  begin
    nx_state <= cr_state;
    case cr_state is
      when idle_t =>
        if start_bind = '1' then
          nx_state <= bind_t;
        end if;
      when bind_t =>
          nx_state <= idle_t;
      when others =>
          null;
    end case;
  end process;

  OUTPUT_DECODE: process(cr_state, start_bind, word1_reg, word2_reg)
  begin
    mem_addr1   <= (others => '0');
    mem_out1    <= (others => '0');
    mem_wr_1    <= '0';
    mem_addr2   <= (others => '0');
    mem_out2    <= (others => '0');
    mem_wr_2    <= '0';
    trail_input <= (others => '0');
    trail       <= '0';
    bind_done   <= '0';
    register_input <= '0';
    case cr_state is
      when idle_t =>
        if start_bind = '1' then
          register_input <= '1';
        end if;
      when bind_t =>
        bind_done <= '1';
        trail     <= '1';
        if fpwam_tag(word1_reg) = tag_ref_t
        and ((fpwam_tag(word2_reg) /= tag_ref_t) or (unsigned(fpwam_value(word2_reg)) < unsigned(fpwam_value(word1_reg)))) then
          trail_input <= fpwam_value(word1_reg);
          mem_addr1   <= fpwam_value(word1_reg);
          mem_wr_1    <= '1';
          mem_out1    <= word2_reg;
        else
          trail_input <= fpwam_value(word2_reg);
          mem_addr2   <= fpwam_value(word2_reg);
          mem_wr_2    <= '1';
          mem_out2    <= word1_reg;
        end if;
      when others =>
        null;
    end case;
  end process;
end Behavioral;
