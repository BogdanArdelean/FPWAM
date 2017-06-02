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
     start_word  : in  std_logic_vector(kWordWidth -1 downto 0);
     memory_in   : in  std_logic_vector(kWordWidth -1 downto 0);

     addr_out    : out std_logic_vector(kAddressWidth -1 downto 0);
     rd_mem      : out std_logic;

     res_out     : out std_logic_vector(kWordWidth -1 downto 0);
     done        : out std_logic
  );
end DerefUnit;

architecture Behavioral of DerefUnit is

type state_t is (idle_t, read_t, check_t);
signal cr_state, nx_state : state_t;

signal word_reg  : std_logic_vector(kWordWidth -1 downto 0);
signal word_comb : std_logic_vector(kWordWidth -1 downto 0);
signal wr_word    : std_logic;

begin

  WORDREG: process(clk, rst)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        word_reg <= (others => '0');
      elsif wr_word = '1' then
        word_reg <= word_comb;
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

  NEXT_STATE: process(cr_state, start_deref, start_word, memory_in, word_reg, rst)
  begin
    nx_state <= cr_state;
    case cr_state is
      when idle_t =>
        if start_deref = '1' and fpwam_tag(start_word) = tag_ref_t then
          nx_state <= read_t;
        end if;
      when read_t  =>
        nx_state <= check_t;
      when check_t =>
        if fpwam_tag(memory_in) = tag_ref_t and fpwam_value(memory_in) /= fpwam_value(word_reg) then
          nx_state <= read_t;
        else
          nx_state <= idle_t;
        end if;
      when others =>
        null;
    end case;
 end process;

 OUTPUT_DECODE: process(cr_state, start_deref, start_word, memory_in, word_reg, rst)
 begin
   wr_adr     <= '0';
   addr_out   <= fpwam_value(word_reg);
   word_comb  <= (others => '0');
   rd_mem     <= '0';
   res_out    <= word_reg;
   done       <= '0';

   case cr_state is
     when idle_t =>
      if start_deref = '1' then
        if fpwam_tag(start_word) /= tag_ref_t then
          done <= '1';
          res_out <= start_word;
        end if;
        wr_word    <= '1';
        word_comb  <= start_word;
      end if;
     when read_t  =>
      rd_mem <= '1';
     when check_t =>
      word_comb  <= memory_in;
      if not(fpwam_tag(memory_in) = tag_ref_t and fpwam_value(memory_in) /= fpwam_value(word_reg)) then
        res_out    <= fpwam_value(memory_in);
        done       <= '1';
      else
        wr_word    <= '1';
      end if;
    when others =>
      null;
    end case;
  end process;

end Behavioral;
