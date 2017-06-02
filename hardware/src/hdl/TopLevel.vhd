-------------------------------------------------------------------------------
-- FILE NAME      : TopLevel.vhd
-- MODULE NAME    : TopLevel
-- AUTHOR         : Bogdan Ardelean
-- AUTHOR'S EMAIL : bogdan.ardelean@yahoo.com
-------------------------------------------------------------------------------
-- REVISION HISTORY
-- VERSION  DATE         AUTHOR            DESCRIPTION
-- 1.0      2016-05-2    Bogdan Ardelean   Created
-------------------------------------------------------------------------------
-- DESCRIPTION    : Unit that binds all other components to form the processor
--
-------------------------------------------------------------------------------
library ieee;
library xil_defaultlib;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.FpwamPkg.all;


entity TopLevel is
  port
  (
    clk : in std_logic;
    rst : in std_logic
  );
end TopLevel;

architecture Structural of TopLevel is

----- STACK AND HEAP MEMORY ----
signal mem_addr1     : std_logic_vector(kWamAddressWidth -1 downto 0);
signal mem_addr2     : std_logic_vector(kWamAddressWidth -1 downto 0);
signal mem_input_1   : std_logic_vector(kWamWordWidth -1 downto 0);
signal mem_input_2   : std_logic_vector(kWamWordWidth -1 downto 0);
signal mem_output_1  : std_logic_vector(kWamWordWidth -1 downto 0);
signal mem_output_2  : std_logic_vector(kWamWordWidth -1 downto 0);
signal mem_port1_rd  : std_logic;
signal mem_port2_rd  : std_logic;
signal mem_port1_rd  : std_logic;
signal mem_port2_rd  : std_logic;

----- GPRs -----
signal gpr_address : std_logic_vector(kGPRAddressWidth -1 downto 0);
signal gpr_input   : std_logic_vector(kWamWordWidth -1 downto 0);
signal gpr_output  : std_logic_vector(kWamWordWidth -1 downto 0);
signal gpr_wr      : std_logic;

----- BIND UNIT -----
signal bind_start        : std_logic;
signal bind_word1        : std_logic_vector(kWamWordWidth -1 downto 0);
signal bind_word2        : std_logic_vector(kWamWordWidth -1 downto 0);
signal bind_mem_addr1    : std_logic_vector(kWamAddressWidth -1 downto 0);
signal bind_mem_word1    : std_logic_vector(kWamWordWidth -1 downto 0);
signal bind_mem_port1_wr : std_logic;
signal bind_mem_addr2    : std_logic_vector(kWamAddressWidth -1 downto 0);
signal bind_mem_word2    : std_logic_vector(kWamWordWidth -1 downto 0);
signal bind_mem_port2_wr : std_logic;
signal bind_trai_input   : std_logic_vector(kWamAddressWidth -1 downto 0);
signal bind_trail        : std_logic;
signal bind_done         : std_logic;

----- TRAIL UNIT ----
signal trail         : std_logic;
signal trail_address : std_logic_vector(kWamAddressWidth -1 downto 0);
signal trail_H       : std_logic_vector(kWamAddressWidth -1 downto 0);
signal trail_HB      : std_logic_vector(kWamAddressWidth -1 downto 0);
signal trail_B       : std_logic_vector(kWamAddressWidth -1 downto 0);
signal trail_a       : std_logic_vector(kWamAddressWidth -1 downto 0);
signal trail_do      : std_logic;

----- DEREF UNIT1 ----
signal deref1_start        : std_logic;
signal deref1_word         : std_logic_vector(kWamWordWidth -1 downto 0);
signal deref1_mem_word1    : std_logic_vector(kWamWordWidth -1 downto 0);
signal deref1_mem_addr1    : std_logic_vector(kWamAddressWidth -1 downto 0);
signal deref1_mem_port1_rd : std_logic;
signal deref1_res_out      : std_logic_vector(kWamWordWidth -1 downto 0);
signal deref1_done         : std_logic;

----- DEREF UNIT2 ----
----- THIS IS USED JUST BY UNIFYUNIT ----
signal deref2_start        : std_logic;
signal deref2_word         : std_logic_vector(kWamWordWidth -1 downto 0);
signal deref2_mem_word2    : std_logic_vector(kWamWordWidth -1 downto 0);
signal deref2_mem_addr2    : std_logic_vector(kWamAddressWidth -1 downto 0);
signal deref2_mem_port2_rd : std_logic;
signal deref2_res_out      : std_logic_vector(kWamWordWidth -1 downto 0);
signal deref2_done         : std_logic;

----- UNIFY UNIT ----
signal unify_start         : std_logic;
signal unify_word1         : std_logic_vector(kWamWordWidth -1 downto 0);
signal unify_word2         : std_logic_vector(kWamWordWidth -1 downto 0);
signal unify_mem_word1     : std_logic_vector(kWamWordWidth -1 downto 0);
signal unify_mem_word2     : std_logic_vector(kWamWordWidth -1 downto 0);
signal unify_deref1_in     : std_logic_vector(kWamWordWidth -1 downto 0);
signal unify_deref1_done   : std_logic;
signal unify_deref2_in     : std_logic_vector(kWamWordWidth -1 downto 0);
signal unify_deref2_done   : std_logic;
signal unify_bind_done     : std_logic;
signal unify_done          : std_logic;
signal unify_fail          : std_logic;
signal unify_mem_addr1     : std_logic_vector(kWamAddressWidth -1 downto 0);
signal unify_mem_port1_rd  : std_logic;
signal unify_mem_addr2     : std_logic_vector(kWamAddressWidth -1 downto 0);
signal unify_mem_port2_rd  : std_logic;
signal unify_deref1_out    : std_logic_vector(kWamWordWidth -1 downto 0);
signal unify_deref1_start  : std_logic;
signal unify_deref2_out    : std_logic_vector(kWamWordWidth -1 downto 0);
signal unify_deref2_start  : std_logic;
signal unify_bind_word1    : std_logic_vector(kWamWordWidth -1 downto 0);
signal unify_bind_word2    : std_logic_vector(kWamWordWidth -1 downto 0);
signal unify_bind_start    : std_logic;
signal unify_mem_sel       : unify_mem_sel_t;

begin
end Structural;
