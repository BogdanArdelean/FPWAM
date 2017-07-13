-------------------------------------------------------------------------------
-- FILE NAME      : UnwindTrailUnit.vhd
-- MODULE NAME    : UnwindTrailUnit
-- AUTHOR         : Bogdan Ardelean
-- AUTHOR'S EMAIL : bogdan.ardelean@yahoo.com
-------------------------------------------------------------------------------
-- REVISION HISTORY
-- VERSION  DATE         AUTHOR            DESCRIPTION
-- 1.0      2016-05-2    Bogdan Ardelean   Created
-------------------------------------------------------------------------------
-- DESCRIPTION    : Unit that executes the unwind_trail(a1, a2) WAM ancillary
-- operation
-------------------------------------------------------------------------------
library ieee;
library xil_defaultlib;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.FpwamPkg.all;


entity UnwindTrailUnit is
  port
  (
    clk : in std_logic
  ; rst : in std_logic

  ; start_unwind    : in std_logic
  ; a1              : in std_logic_vector(kWamTrailAddressWidth -1 downto 0)
  ; a2              : in std_logic_vector(kWamTrailAddressWidth -1 downto 0)
  ; trail_port_1    : in std_logic_vector(kWamAddressWidth -1 downto 0)
  ; trail_port_1_rd : out std_logic
  ; trail_addr_1    : out std_logic_vector(kWamTrailAddressWidth -1 downto 0)
  ; trail_port_2    : in std_logic_vector(kWamAddressWidth -1 downto 0)
  ; trail_port_2_rd : out std_logic
  ; trail_addr_2    : out std_logic_vector(kWamTrailAddressWidth -1 downto 0)
  ; mem_port_1      : out std_logic_vector(kWamWordWidth -1 downto 0)
  ; mem_port_1_wr   : out std_logic
  ; mem_addr_1      : out std_logic_vector(kWamAddressWidth -1 downto 0)
  ; mem_port_2      : out std_logic_vector(kWamWordWidth -1 downto 0)
  ; mem_port_2_wr   : out std_logic
  ; mem_addr_2      : out std_logic_vector(kWamAddressWidth -1 downto 0)
  ; done            : out std_logic
  );
end UnwindTrailUnit;

architecture Behavioral of UnwindTrailUnit is
type state_t is (idle_t, first_read_t, read_write_t, done_t);
signal cr_state, nx_state : state_t;

signal counter : unsigned(kWamTrailAddressWidth -1 downto 0);
signal count   : std_logic;
signal goal    : unsigned(kWamTrailAddressWidth -1 downto 0);
begin

  CNTR: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        counter <= to_unsigned(0, counter'length);
      elsif start_unwind = '1' then
        counter <= unsigned(a1);
      elsif count = '1' then
        counter <= counter + 2;
      end if;
    end if;
  end process;

  GOALR: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        goal <= to_unsigned(0, goal'length);
      elsif start_unwind = '1' then
        goal <= unsigned(a2);
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

  NXSTATE: process(cr_state, start_unwind, counter, goal)
  begin
    nx_state <= cr_state;
    case cr_state is
      when idle_t =>
        if start_unwind = '1' then
          nx_state <= first_read_t;
        end if;
      when first_read_t =>
        nx_state <= read_write_t;
      when read_write_t =>
        if counter+1 > goal then
          nx_state <= done_t;
        end if;
      when done_t =>
        nx_state <= idle_t;
      when others =>
        nx_state <= idle_t;
    end case;
  end process;

  OUTPUT: process(cr_state, counter, goal, trail_port_1, trail_port_2)
  begin
    trail_port_1_rd <= '0';
    trail_addr_1    <= (others => '0');
    trail_port_2_rd <= '0';
    trail_addr_2    <= (others => '0');
    mem_port_1      <= (others => '0');
    mem_port_1_wr   <= '0';
    mem_addr_1      <= (others => '0');
    mem_port_2      <= (others => '0');
    mem_port_2_wr   <= '0';
    mem_addr_2      <= (others => '0');
    done            <= '0';
    count           <= '0';
    case cr_state is
      when idle_t =>
        null;
      when first_read_t =>
        trail_port_1_rd <= to_std_logic(counter < goal);
        trail_addr_1    <= std_logic_vector(counter);

        trail_port_2_rd <= to_std_logic(counter+1 < goal);
        trail_addr_2    <= std_logic_vector(counter+1);
      when read_write_t =>
        count <= '1';

        trail_port_1_rd <= to_std_logic(counter+2 < goal);
        trail_addr_1    <= std_logic_vector(counter+2);

        trail_port_2_rd <= to_std_logic(counter+3 < goal);
        trail_addr_2    <= std_logic_vector(counter+3);

        mem_port_1      <= fpwam_word(trail_port_1, tag_ref_t);
        mem_port_2      <= fpwam_word(trail_port_2, tag_ref_t);

        mem_port_1_wr   <= to_std_logic(counter < goal);
        mem_port_2_wr   <= to_std_logic(counter+1 < goal);

        mem_addr_1      <= trail_port_1;
        mem_addr_2      <= trail_port_2;
      when done_t =>
        done <= '1';
      when others =>
        null;
    end case;
  end process;
end Behavioral;
