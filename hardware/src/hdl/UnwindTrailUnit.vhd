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
  generic
  (
    kAddressWidth : natural := kWamAddressWidth
  );
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
  ; trail_port_2_rd : out std_logic;
  ; trail_addr_2    : out std_logic_vector(kWamTrailAddressWidth -1 downto 0)
  ; mem_port_1      : out std_logic_vector(kWamWordWidth -1 downto 0)
  ; mem_port_1_wr   : out std_logic
  ; mem_port_2      : out std_logic_vector(kWamWordWidth -1 downto 0)
  ; mem_port_2_wr   : out std_logic
  ; done            : out std_logic
  );
end UnwindTrailUnit;

architecture Behavioral of UnwindTrailUnit is
type state_t is (idle_t);
signal counter : unsigned(kWamTrailAddressWidth -1 downto 0);

begin
end Behavioral;
