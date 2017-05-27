-------------------------------------------------------------------------------
-- FILE NAME      : DerefUnit.vhd
-- MODULE NAME    : DerefUnit
-- AUTHOR         : Bogdan Ardelean
-- AUTHOR'S EMAIL : bogdan.ardelean@yahoo.com
-------------------------------------------------------------------------------
-- REVISION HISTORY
-- VERSION  DATE         AUTHOR            DESCRIPTION
-- 1.0      2016-05-2    Bogdan Ardelean   Created
-------------------------------------------------------------------------------
-- DESCRIPTION    : Unit that executes the deref(x) WAM ancillary operation
--
-------------------------------------------------------------------------------
library ieee;
library xil_defaultlib;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.FpwamPkg.all;

entity DerefUnit is
  generic
  (
    kAddressWidth : natural := kWamAddressWidth; -- 16
    kWordWidth    : natural := kWamWordWidth     -- 18
  );
  port
  (
     clk         : in  std_logic;
     rst         : in  std_logic;
     start_deref : in  std_logic;
     start_addr  : in  std_logic_vector(kAddressWidth -1 downto 0);
     memory_in   : in  std_logic_vector(kWordWidth -1 downto 0);

     addr_out    : out std_logic_vector(kAddressWidth -1 downto 0);
     rd_mem      : out std_logic;

     res_out     : out std_logic_vector(kAddressWidth -1 downto 0);
     done        : out std_logic
  );
end DerefUnit;

architecture Behavioral of DerefUnit is

type state_t is (idle_t, read_t, check_t);
signal cr_state, nx_state : state_t;

signal addr_reg  : std_logic_vector(kAddressWidth);
signal addr_comb : std_logic_vector(kAddressWidth);
signal wr_adr    : std_logic;

begin

  ADDR_REG: process(clk, rst)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        addr_reg <= (others => '0');
      elsif wr_adr = '1' then
        addr_reg <= addr_comb;
      end if;
    end if;
  end process;

  FSM: process(clk, rst)
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
        if start_deref = '1' then
          nx_state <= read_t;
        end if;
      when read_t  =>
        nx_state <= check_t;
      when check_t =>
        if fpwam_tag(memory_in) <> tag_ref_t and fpwam_value(memory_in) <> addr_reg then
          nx_state <= read_t;
        else
          nx_state <= idle_t;
        end if;
      when others =>
        null;
    end case;
 end process;

 OUTPUT_DECODE: process(cr_state, rst)
 begin
   wr_adr     <= '0';
   addr_out   <= addr_reg;
   addr_comb  <= (others => '0');
   rd_mem     <= '0';
   res_out    <= (others => '0');
   done       <= '0';
   stop_deref <= '0';

   case cr_state is
     when idle_t =>
      if start_deref = '1' then
        wr_adr    <= '1';
        addr_comb <= start_addr;
      end if;
     when read_t =>
      rd_mem <= '1';
     when check_t =>
      if fpwam_tag(memory_in) <> tag_ref_t and fpwam_value(memory_in) <> addr_reg then
        addr_comb <= fpwam_value(memory_in);
        wr_adr    <= '1';
      else
        res_out    <= fpwam_value(memory_in);
        done       <= '1';
      end if;
    when others =>
      null;
    end case;
  end process;

end Behavioral;
