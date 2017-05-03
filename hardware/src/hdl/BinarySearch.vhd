-------------------------------------------------------------------------------
-- FILE NAME      : BinarySearch.vhd
-- MODULE NAME    : General Purpose module that implements the BinarySearch
--                  algorithm
-- AUTHOR         : Bogdan Ardelean
-- AUTHOR'S EMAIL : bogdan.ardelean@yahoo.com
-------------------------------------------------------------------------------
-- REVISION HISTORY
-- VERSION  DATE         AUTHOR            DESCRIPTION
-- 1.0      2016-05-03   Bogdan Ardelean   Created
-------------------------------------------------------------------------------
-- DESCRIPTION    : Module used for searching predicate and first argument
--                  label
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity BinarySearch is
      generic
      (
               kWordWidth          : natural := 16;
               kMemAddressWidth    : natural := 16
      );
      port
      (
               -- Common
               clk                 : in std_logic;
               rst                 : in std_logic;

               -- Search interface
               search_word         : in std_logic_vector(kWordWidth - 1 downto 0);
               low_address         : in std_logic_vector(kMemAddressWidth - 1 downto 0);
               high_address        : in std_logic_vector(kMemAddressWidth - 1 downto 0);
               start_search        : in std_logic;

               done                : out std_logic;
               found               : out std_logic;
               -- Memory interface
               memory_in           : in std_logic_vector(kWordWidth - 1 downto 0);
               memory_valid        : in std_logic;
               memory_address_out  : out std_logic_vector(kMemAddressWidth - 1 downto 0);
               memory_read         : out std_logic
      );
end BinarySearch;

architecture Behavioral of BinarySearch is

-- FSM
type state_t is (idle_t, decision_t, wait_mem_t, done_t);
signal cr_state, nx_state : state_t;

-- Registers
signal low_addr_reg        : std_logic_vector(kMemAddressWidth - 1 downto 0);
signal high_addr_reg       : std_logic_vector(kMemAddressWidth - 1 downto 0);
signal search_word_reg     : std_logic_vector(kWordWidth - 1 downto 0);
signal mem_word            : std_logic_vector(kWordWidth - 1 downto 0);

-- Control signals
signal wr_low              : std_logic;
signal wr_high             : std_logic;
signal wr_search_word      : std_logic;
signal wr_mem_word         : std_logic;
signal left_greater        : std_logic;

-- Combinatorial
signal low_addr_comb       : std_logic_vector(kAddressWidth - 1 downto 0);
signal high_addr_comb      : std_logic_vector(kAddressWidth - 1 downto 0);

begin

  LOWADDRREG: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
         low_addr_reg <= (others => '0');
      elsif wr_low = '1' then
         low_addr_reg <= low_addr_comb;
      end if;
    end if;
  end process LOWADDRREG;

  HIGHADDRREG: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
         high_addr_reg <= (others => '0');
      elsif wr_high = '1' then
         high_addr_reg <= high_addr_comb;
      end if;
    end if;
  end process HIGHADDRREG;

  SEARCHWORDREG: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        search_word_reg <= (others => '0');
      elsif wr_search_word = '1' then
        search_word_reg <= search_word;
      end if;
    end if;
  end process SEARCHWORDREG;

  MEMWORDREG: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        mem_word <= (others => '0');
      elsif wr_mem_word = '1' and memory_valid = '1' then
        mem_word <= memory_in;
      end if;
    end if;
  end process MEMWORDREG;

  FSM: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        cr_state <= idle_t;
      else
        cr_state <= nx_state;
      end if;
    end if;
  end process FSM;

  NEXT_STATE_DECODE: process(cr_state, start_search, memory_in, memory_valid)
  begin
    nx_state <= cr_state;
    case(cr_state) is
      when idle_t =>
        if start_search = '1' then
          nx_state <= wait_mem_t;
        else
          nx_state <= idle_t;
        end if;
      when wait_mem_t =>
        if memory_valid = '1' then
          nx_state <= decision_t;
        else
          nx_state <= wait_mem_t;
        end if;
      when decision_t =>
        if mem_word = search_word_reg or low_addr_reg >= high_addr_reg then
          nx_state <= done_t;
        else
          nx_state <= wait_mem_t;
        end if;
      when done_t =>
        nx_state <= idle_t;
      when others =>
        nx_state <= idle_t;
     end case;
   end process NEXT_STATE_DECODE;

  CONTROL_AND_OUTPUT: process(cr_state, start_search, memory_valid)
  begin

    wr_low             <= '0';
    wr_high            <= '0';
    wr_search_word     <= '0';
    wr_mem_word        <= '0';
    memory_read        <= '0';
    done               <= '0';
    found              <= '0';
    low_addr_comb      <= (others => '0');
    high_addr_comb     <= (others => '0');
    memory_address_out <= (low_addr_reg + high_addr_reg) / 2;

    case(cr_state) is
      when idle_t =>
        if start_search = '1' then
          wr_low         <= '1';
          wr_high        <= '1';
          wr_search_word <= '1';
          low_addr_comb  <= low_address;
          high_addr_comb <= high_address;
        end if;
      when wait_mem_t =>
        memory_read <= '1';
      when decision_t =>
        if search_word_reg < mem_word then
          low_addr_comb <= low_addr_reg;
          high_addr_comb <= (low_addr_reg + high_addr_reg) / 2 - 1;
        else
          high_addr_comb <= high_addr_reg;
          low_addr_comb <=  (low_addr_reg + high_addr_reg) / 2 + 1;
        end if;
      when done_t =>
        found <= to_std_logic(mem_word = search_word_reg);
        done <= '1';
      when others =>
        null;
    end case;
  end process CONTROL_AND_OUTPUT;

end Behavioral;
