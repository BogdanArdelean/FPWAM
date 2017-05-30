-------------------------------------------------------------------------------
-- FILE NAME      : UnifyUnit.vhd
-- MODULE NAME    : UnifyUnit
-- AUTHOR         : Bogdan Ardelean
-- AUTHOR'S EMAIL : bogdan.ardelean@yahoo.com
-------------------------------------------------------------------------------
-- REVISION HISTORY
-- VERSION  DATE         AUTHOR            DESCRIPTION
-- 1.0      2016-05-2    Bogdan Ardelean   Created
-------------------------------------------------------------------------------
-- DESCRIPTION    : Unit that executes the unify(a1, a2) WAM ancillary operation
--
-------------------------------------------------------------------------------
library ieee;
library xil_defaultlib;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.FpwamPkg.all;

entity UnifyUnit is
  generic
  (
    kAddressWidth    : natural := kWamAddressWidth;
    kWordWidth       : natural := kWamWordWidth;
    kPdlAddressWidth : natural := 10
  );
  port
  (
    clk            : in std_logic;
    rst            : in std_logic;

    start_unify    : in std_logic;

    word1          : in std_logic_vector(kWordWidth -1 downto 0);
    word2          : in std_logic_vector(kWordWidth -1 downto 0);

    mem1_input     : in std_logic_vector(kWordWidth -1 downto 0);
    mem2_input     : in std_logic_vector(kWordWidth -1 downto 0);

    deref1_input   : in std_logic_vector(kWordWidth -1 downto 0);
    deref1_done    : in std_logic;

    deref2_input   : in std_logic_vector(kWordWidth -1 downto 0);
    deref2_done    : in std_logic;

    bind_done      : in std_logic;

    unify_done     : out std_logic;
    fail           : out std_logic;

    mem1_output    : out std_logic_vector(kAddressWidth -1 downto 0);
    mem2_output    : out std_logic_vector(kAddressWidth -1 downto 0);

    deref1_output  : out std_logic_vector(kWordWidth -1 downto 0);
    deref1_start   : out std_logic;

    deref2_output  : out std_logic_vector(kWordWidth -1 downto 0);
    deref2_start   : out std_logic;

    bind1_output   : out std_logic_vector(kAddressWidth -1 downto 0);
    bind2_output   : out std_logic_vector(kAddressWidth -1 downto 0);
    bind_start     : out std_logic;

    mem_sel        : out unify_mem_sel_t
  );
end UnifyUnit;


architecture Behavioral of UnifyUnit is

type state_t is (idle_t);
signal cr_state, nx_state : state_t;

--Interface with PDL memory

signal pdl_in_1     : std_logic_vector(kWordWidth -1 downto 0);
signal pdl_in_2     : std_logic_vector(kWordWidth -1 downto 0);
signal pdl_out_1    : std_logic_vector(kWordWidth -1 downto 0);
signal pdl_out_2    : std_logic_vector(kWordWidth -1 downto 0);
signal wr_pdl       : std_logic;
signal rd_pdl       : std_logic;

signal pdl_addr_reg : std_logic_vector(kAddressWidth -1 downto 0);
signal wr_pdl_reg   : std_logic;
signal pdl_empty    : boolean;

signal fail_local   : std_logic;

signal deref1_done_reg : std_logic;
signal deref2_done_reg : std_logic;
signal reset_deref_reg : std_logic;

begin

  fail <= fail_local;

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


  NEXT_STATE: process(cr_state, start_unify, pdl_empty, fail, deref1_done_reg, deref2_done_reg)
  begin
    case cr_state is
      when idle_t =>
        if start_unify = '1' then
          nx_state <= check_stop_pop_t;
        end if;
      when check_stop_pop_t =>
        if not(pdl_empty and fail = '0') then
          nx_state <= deref_t;
        end if;
      when deref_t =>
        if deref1_done_reg = '1' and deref2_done_reg = '1' then
          nx_state <= check_equal_read_t;
        end if;
      when check_equal_read_t =>
        if fpwam_value(deref1_input) = fpwam_value(deref2_input) then
          nx_state <= check_stop_pop_t;
        else
          nx_state <=

  end process;
