-------------------------------------------------------------------------------
-- FILE NAME      : Memory.vhd
-- MODULE NAME    : Memory
-- AUTHOR         : Bogdan Ardelean
-- AUTHOR'S EMAIL : bogdan.ardelean@yahoo.com
-------------------------------------------------------------------------------
-- REVISION HISTORY
-- VERSION  DATE         AUTHOR            DESCRIPTION
-- 1.0      2016-05-2    Bogdan Ardelean   Created
-------------------------------------------------------------------------------
-- DESCRIPTION    : BRAM implementation of a memory unit with two ports.
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Memory is
  generic
  (
    kMemAddressWidth : natural := 16;
    kWordWidth       : natural := 18
  );
  port
  (
    clk            : in  std_logic;

    addr_port_1    : in  std_logic_vector(kMemAddressWidth -1 downto 0);
    word_port_1_o  : out std_logic_vector(kWordWidth -1 downto 0);
    word_port_1_i  : in  std_logic_vector(kWordWidth -1 downto 0);
    wr_port_1      : in  std_logic;
    rd_port_1      : in  std_logic;

    addr_port_2    : in  std_logic_vector(kMemAddressWidth -1 downto 0);
    word_port_2_o  : out std_logic_vector(kWordWidth -1 downto 0);
    word_port_2_i  : in  std_logic_vector(kWordWidth -1 downto 0);
    wr_port_2      : in  std_logic;
    rd_port_2      : in  std_logic
  );
end Memory;

architecture Behavioral of Memory is
type mem is array (0 to 2**kMemAddressWidth) of std_logic_vector(kWordWidth - 1 downto 0);
signal BRAM : mem := (others => (others => '0'));
begin

  PORT_1: process(clk)
  begin
    if rising_edge(clk) then
      word_port_1_o <= (others => '0');
      if wr_port_1 = '1' then
        BRAM(to_integer(unsigned(addr_port_1))) <= word_port_1_i;
      end if;
      if rd_port_1 = '1' then
        word_port_1_o <= BRAM(to_integer(unsigned(addr_port_1)));
      end if;
    end if;
  end process;

  PORT_2: process(clk)
  begin
    if rising_edge(clk) then
      word_port_2_o <= (others => '0');
      if wr_port_2 = '1' then
        BRAM(to_integer(unsigned(addr_port_2))) <= word_port_2_i;
      end if;
      if rd_port_2 = '1' then
        word_port_2_o <= BRAM(to_integer(unsigned(addr_port_2)));
      end if;
    end if;
  end process;

end Behavioral;

architecture Simulation of Memory is
type mem is array (0 to 2**kMemAddressWidth) of std_logic_vector(kWordWidth - 1 downto 0);
signal BRAM : mem := (others => (others => '0'));
signal reg_addr1 : std_logic_vector(kMemAddressWidth -1 downto 0) := (others =>'0');
signal reg_addr2 : std_logic_vector(kMemAddressWidth -1 downto 0) := (others =>'0');
begin

  word_port_1_o <= BRAM(to_integer(unsigned(reg_addr1)));
  word_port_2_o <= BRAM(to_integer(unsigned(reg_addr2)));

  WRITE: process(clk)
  begin
    if rising_edge(clk) then
      if wr_port_1 = '1' then
        BRAM(to_integer(unsigned(addr_port_1))) <= word_port_1_i;
      end if;
	    if wr_port_2 = '1' then
        BRAM(to_integer(unsigned(addr_port_2))) <= word_port_2_i;
      end if;
    end if;
  end process;

  READ: process(clk)
  begin
    if rising_edge(clk) then
	  if rd_port_1 = '1' then
	   reg_addr1 <= addr_port_1;
	  end if;
      if rd_port_2 = '1' then
       reg_addr2<= addr_port_2;
      end if;
    end if;
  end process;

end Simulation;
