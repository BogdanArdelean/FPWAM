-------------------------------------------------------------------------------
-- FILE NAME      : TrailUnit.vhd
-- MODULE NAME    : TrailUnit
-- AUTHOR         : Bogdan Ardelean
-- AUTHOR'S EMAIL : bogdan.ardelean@yahoo.com
-------------------------------------------------------------------------------
-- REVISION HISTORY
-- VERSION  DATE         AUTHOR            DESCRIPTION
-- 1.0      2016-05-2    Bogdan Ardelean   Created
-------------------------------------------------------------------------------
-- DESCRIPTION    : Unit that executes the trail(a) WAM ancillary operation
--
-------------------------------------------------------------------------------

library ieee;
library xil_defaultlib;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.FpwamPkg.all;

entity TrailUnit is
  generic
  (
    kAddressWidth : natural := kWamAddressWidth
  );
  port
  (
    trail          : in std_logic;
    trail_address  : in std_logic_vector(kAddressWidth -1 downto 0);
    H              : in std_logic_vector(kAddressWidth -1 downto 0);
    HB             : in std_logic_vector(kAddressWidth -1 downto 0);
    B              : in std_logic_vector(kAddressWidth -1 downto 0);

    a              : out std_logic_vector(kAddressWidth -1 downto 0);
    do_trail       : out std_logic
  );
end TrailUnit;

architecture Behavioral of TrailUnit is
begin

  a <= trail_address;
  DOTRAIL: process(trail, trail_address, H, HB, B)
  begin

    if trail = '1' then
      if (unsigned(trail_address) < unsigned(HB))
      or ((unsigned(H) < unsigned(trail_address)) and (unsigned(trail_address) < unsigned(B))) then
        do_trail <= '1';
      end if;
    end if;
  end process;

end Behavioral;
