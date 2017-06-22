-------------------------------------------------------------------------------
-- FILE NAME      : GPR.vhd
-- MODULE NAME    : GPR
-- AUTHOR         : Bogdan Ardelean
-- AUTHOR'S EMAIL : bogdan.ardelean@yahoo.com
-------------------------------------------------------------------------------
-- REVISION HISTORY
-- VERSION  DATE         AUTHOR            DESCRIPTION
-- 1.0      2016-05-2    Bogdan Ardelean   Created
-------------------------------------------------------------------------------
-- DESCRIPTION    : General Purpose Registers
--
-------------------------------------------------------------------------------

library ieee;
library xil_defaultlib;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.FpwamPkg.all;

entity GPR is
  generic
  (
    kAddressWidth : natural := 4;
    kWordWidth    : natural := 16
  );
  port
  (
    --Common
    clk           : in std_logic;

    address1       : in std_logic_vector(kAddressWidth - 1 downto 0);
    wr1            : in std_logic;
    input_word1    : in std_logic_vector(kWordWidth - 1 downto 0);
    output_word1   : out std_logic_vector(kWordWidth - 1 downto 0);

    address2       : in std_logic_vector(kAddressWidth - 1 downto 0);
    wr2            : in std_logic;
    input_word2    : in std_logic_vector(kWordWidth - 1 downto 0);
    output_word2   : out std_logic_vector(kWordWidth - 1 downto 0)
  );
end GPR;


architecture Behavioral of GPR is
type sram is array (0 to 2**kAddressWidth) of std_logic_vector(kWordWidth - 1 downto 0);

signal RAM : sram;
begin

WRITE_PROCESS: process(clk)
begin
  if rising_edge(clk) then
    if wr1 = '1' then
      RAM(to_integer(unsigned(address1))) <= input_word1;
    end if;
    if wr2 = '1' then
      RAM(to_integer(unsigned(address2))) <= input_word2;
    end if;
  end if;
end process;

output_word1 <= RAM(to_integer(unsigned(address1)));
output_word2 <= RAM(to_integer(unsigned(address2)));

end Behavioral;
