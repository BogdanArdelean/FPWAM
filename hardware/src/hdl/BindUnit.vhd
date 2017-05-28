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

    address1    : in  std_logic_vector(kAddressWidth -1 downto 0);
    address2    : in  std_logic_vector(kAddressWidth -1 downto 0);

    mem_input1  : in  std_logic_vector(kWordWidth -1 downto 0);
    mem_input2  : in  std_logic_vector(kWordWidth -1 downto 0);

    mem_addr1   : out std_logic_vector(kAddressWidth -1 downto 0);
    mem_out1    : out std_logic_vector(kWordWidth -1 downto 0);
    mem_wr_1    : out std_logic;
    mem_rd_1    : out std_logic;

    mem_addr2   : out std_logic_vector(kAddressWidth -1 downto 0);
    mem_out2    : out std_logic_vector(kWordWidth -1 downto 0);
    mem_wr_2    : out std_logic;
    mem_rd_2    : out std_logic;

    trail_input : out std_logic_vector(kAddressWidth -1 downto 0);
    trail       : out std_logic;

    bind_done   : out std_logic
  );
end BindUnit;


architecture Behavioral of BindUnit is
type state_t is (idle_t, bind_t);
signal cr_state, nx_state : state_t;

signal address1_reg       : std_logic_vector(kAddressWidth -1 downto 0);
signal address2_reg       : std_logic_vector(kAddressWidth -1 downto 0);
signal register_input     : std_logic;

begin

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

  NEXT_STATE: process(cr_state)
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

  OUTPUT_DECODE: process(cr_state)
  begin
    mem_addr1   <= (others => '0');
    mem_out1    <= (others => '0');
    mem_wr_1    <= '0';
    mem_rd_1    <= '0';
    mem_addr2   <= (others => '0');
    mem_out2    <= (others => '0');
    mem_wr_2    <= '0';
    mem_rd_2    <= '0';
    trail_input <= (others => '0');
    trail       <= '0';
    bind_done   <= '0';

    case cr_state is
      when idle_t =>
        if start_bind = '1' then
          mem_addr1      <= address1;
          mem_rd_1       <= '1';
          mem_addr2      <= address2;
          mem_rd_2       <= '1';
          register_input <= '1';
        end if;
      when bind_t =>
        bind_done <= '1';
        trail     <= '1';
        if fpwam_tag(mem_input1) = tag_ref_t
        and ((fpwam_tag(mem_input2) /= tag_ref_t) or (unsigned(address2_reg) < unsigned(address1_reg))) then
          trail_input <= address1_reg;
          mem_addr1   <= address1_reg;
          mem_wr_1    <= '1';
          mem_out1    <= mem_input2;
        else
          trail_input <= address2_reg;
          mem_addr2   <= address2_reg;
          mem_wr_2    <= '1';
          mem_out2    <= mem_input1;
        end if;
      when others =>
        null;
    end case;
  end process;
end Behavioral;
