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
    rd_mem_port1   : out std_logic;

    mem2_output    : out std_logic_vector(kAddressWidth -1 downto 0);
    rd_mem_port2   : out std_logic;

    deref1_output  : out std_logic_vector(kWordWidth -1 downto 0);
    deref1_start   : out std_logic;

    deref2_output  : out std_logic_vector(kWordWidth -1 downto 0);
    deref2_start   : out std_logic;

    bind1_output   : out std_logic_vector(kWordWidth -1 downto 0);
    bind2_output   : out std_logic_vector(kWordWidth -1 downto 0);
    bind_start     : out std_logic;

    mem_sel        : out unify_mem_sel_t
  );
end UnifyUnit;


architecture Behavioral of UnifyUnit is

type state_t is (idle_t, check_stop_pop_t, done_t, check_equal_read_t, deref_t, bind_t, push_list_t,
                 check_structure_t, check_structure_t2, structure_iterate_t);
signal cr_state, nx_state : state_t;

--Interface with PDL memory

signal pdl_in_1     : std_logic_vector(kWordWidth -1 downto 0);
signal pdl_in_2     : std_logic_vector(kWordWidth -1 downto 0);
signal pdl_out_1    : std_logic_vector(kWordWidth -1 downto 0);
signal pdl_out_2    : std_logic_vector(kWordWidth -1 downto 0);
signal pdl_adr_1    : std_logic_vector(kPdlAddressWidth -1 downto 0);
signal pdl_adr_2    : std_logic_vector(kPdlAddressWidth -1 downto 0);
signal wr_pdl       : std_logic;
signal rd_pdl       : std_logic;

signal pdl_addr_reg  : std_logic_vector(kPdlAddressWidth -1 downto 0);
signal pdl_addr_comb : std_logic_vector(kPdlAddressWidth -1 downto 0);
signal wr_pdl_reg    : std_logic;
signal pdl_empty     : boolean;

signal fail_reg       : std_logic;
signal fail_comb      : std_logic;
signal reset_fail_reg : std_logic;

signal deref1_done_reg : std_logic;
signal deref2_done_reg : std_logic;
signal reset_deref_reg : std_logic;

signal iterate      : std_logic;
signal iterate_done : std_logic;

signal current_reg  : unsigned(kGPRAddressWidth downto 0);
signal wr_curr_reg  : std_logic;
signal rst_curr_reg : std_logic;

signal goal_reg     : unsigned(kGPRAddressWidth downto 0);
signal wr_goal_reg  : std_logic;

signal mem1_input_reg : std_logic_vector(kWamWordWidth -1 downto 0);
signal mem2_input_reg : std_logic_vector(kWamWordWidth -1 downto 0);
signal mem_reg_wr    : std_logic;

begin

  fail <= fail_reg or fail_comb;
  pdl_empty <= unsigned(pdl_addr_reg) = 0;
  
  INPUTRGS: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        mem1_input_reg <= (others => '0');
        mem2_input_reg <= (others => '0');
      elsif mem_reg_wr = '1' then
        mem1_input_reg <= mem1_input;
        mem2_input_reg <= mem2_input;
      end if;
    end if;
  end process; 
  
  PDLREG: process(clk)
  begin
    if rising_edge(clk) then
       if rst = '1' then
        pdl_addr_reg <= (others => '0');
       elsif wr_pdl_reg = '1' then
        pdl_addr_reg <= pdl_addr_comb;
       end if;
    end if;
  end process;



  PDLIST: entity work.Memory(Behavioral)
          generic map
          (
             kMemAddressWidth => kPdlAddressWidth
            ,kWordWidth       => kWamWordWidth
          )
          port map
          (
             clk => clk

            ,addr_port_1   => pdl_adr_1
            ,word_port_1_o => pdl_out_1
            ,word_port_1_i => pdl_in_1
            ,wr_port_1     => wr_pdl
            ,rd_port_1     => rd_pdl

            ,addr_port_2   => pdl_adr_2
            ,word_port_2_o => pdl_out_2
            ,word_port_2_i => pdl_in_2
            ,wr_port_2     => wr_pdl
            ,rd_port_2     => rd_pdl
          );

  CURRERG: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' or rst_curr_reg = '1' then
        current_reg <= to_unsigned(1, kGPRAddressWidth+1);
      elsif wr_curr_reg = '1' then
        current_reg <= current_reg + 1;
      end if;
    end if;
  end process;

  GOALREG: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        goal_reg <= (others => '0');
      elsif wr_goal_reg = '1' then
        goal_reg <= "0" & unsigned(fpwam_arity(mem1_input_reg));
      end if;
    end if;
  end process;

  STR_IT: process(current_reg, goal_reg, iterate)
  begin
    iterate_done <= '0';
    wr_curr_reg  <= '0';
    if iterate = '1' then
      if current_reg > goal_reg then
        iterate_done <= '1';
      else
        wr_curr_reg <= '1';
      end if;
    end if;
  end process;



  DEREFREGS: process(clk)
  begin
    if rising_edge(clk) then
      if reset_deref_reg = '1' or rst = '1' then
        deref1_done_reg <= '0';
        deref2_done_reg <= '0';
      else
        deref1_done_reg <= deref1_done or deref1_done_reg;
        deref2_done_reg <= deref2_done or deref2_done_reg;
      end if;
    end if;
  end process;

  FAILREG: process(clk, rst)
  begin
    if rising_edge(clk) then
      if rst = '1' or reset_fail_reg = '1' then
        fail_reg <= '0';
      else
        fail_reg <= fail_comb or fail_reg;
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


  NEXT_STATE: process(cr_state, start_unify, pdl_empty, fail_reg, deref1_done_reg,
  deref2_done_reg, deref1_input, deref2_input, bind_done, mem1_input, mem2_input,
  iterate_done, mem1_input_reg, mem2_input_reg)
  begin
    nx_state <= cr_state;
    case cr_state is
      when idle_t =>
        if start_unify = '1' then
          nx_state <= check_stop_pop_t;
        end if;
      when check_stop_pop_t =>
        if not(pdl_empty and fail_reg = '0') then
          nx_state <= deref_t;
        else
          nx_state <= done_t;
        end if;
      when deref_t =>
        if deref1_done_reg = '1' and deref2_done_reg = '1' then
          nx_state <= check_equal_read_t;
        end if;
      when check_equal_read_t =>
        if fpwam_value(deref1_input) = fpwam_value(deref2_input) then
          nx_state <= check_stop_pop_t;
        else
          if fpwam_tag(deref1_input) = tag_ref_t or fpwam_tag(deref2_input) = tag_ref_t then
            nx_state <= bind_t;
          else
            case fpwam_tag(deref2_input) is
              when tag_int_t =>
                nx_state <= check_stop_pop_t;
              when tag_lis_t =>
                if fpwam_tag(deref1_input) /= tag_lis_t then
                  nx_state <= check_stop_pop_t; -- move directly to end?
                else
                  nx_state <= push_list_t;
                end if;
              when tag_str_t =>
                if fpwam_tag(deref1_input) /= tag_str_t then
                  nx_state <= check_stop_pop_t; -- move directly to end?
                else
                  nx_state <= check_structure_t;
                end if;
              when others =>
                null;
            end case;
          end if;
        end if;
      when bind_t =>
        if bind_done = '1' then
          nx_state <= check_stop_pop_t;
        end if;
      when push_list_t =>
        nx_state <= check_stop_pop_t;
      when check_structure_t =>
        nx_state <= check_structure_t2;
      when check_structure_t2 =>
        if fpwam_functor(mem1_input_reg) /= fpwam_functor(mem2_input_reg) or
           fpwam_arity(mem1_input_reg) /= fpwam_arity(mem2_input_reg) then
          nx_state <= check_stop_pop_t;
        else
          nx_state <= structure_iterate_t;
        end if;
      when structure_iterate_t =>
        if iterate_done = '1' then
          nx_state <= check_stop_pop_t;
        end if;
      when others =>
        null;
    end case;
  end process;


  OUTPUT_DECODE: process(cr_state, pdl_out_1, pdl_out_2, start_unify, word1, word2, pdl_addr_reg, pdl_empty, fail_reg, deref1_done_reg,
  deref2_done_reg, mem1_input, mem2_input, deref1_input, deref2_input, iterate_done, current_reg, mem1_input_reg, mem2_input_reg)
  begin
    -- Port outputs
    unify_done     <= '0';
    fail_comb      <= '0';
    mem1_output    <= (others => '0');
    rd_mem_port1   <= '0';
    mem2_output    <= (others => '0');
    rd_mem_port2   <= '0';
    deref1_output  <= (others => '0');
    deref1_start   <= '0';
    deref2_output  <= (others => '0');
    deref2_start   <= '0';
    bind1_output   <= (others => '0');
    bind2_output   <= (others => '0');
    bind_start     <= '0';
    mem_sel        <= sel_unify_t;
    -- Internal control signals
    pdl_in_1       <= (others => '0');
    pdl_in_2       <= (others => '0');
    wr_pdl         <= '0';
    rd_pdl         <= '0';
    pdl_addr_comb  <= (others => '0');
    pdl_adr_1      <= (others => '0');
    pdl_adr_2      <= (others => '0');
    wr_pdl_reg     <= '0';
    fail_comb      <= '0';
    reset_fail_reg <= '0';
    reset_deref_reg<= '1';
    iterate        <= '0';
    rst_curr_reg   <= '0';
    wr_goal_reg    <= '0';
    mem_reg_wr     <= '0';
    
    case cr_state is
      when idle_t =>
        if start_unify = '1' then
          pdl_in_1  <= word1;
          pdl_in_2  <= word2;
          pdl_adr_1 <= pdl_addr_reg;
          pdl_adr_2 <= std_logic_vector(unsigned(pdl_addr_reg) + 1);
          wr_pdl   <= '1';
          rd_pdl   <= '1';
          pdl_addr_comb <= std_logic_vector(unsigned(pdl_addr_reg) + 2);
          wr_pdl_reg <= '1';
          reset_fail_reg <= '1';
        end if;
      when check_stop_pop_t =>
        if not(pdl_empty and fail_reg = '0') then
          pdl_adr_1 <= std_logic_vector(unsigned(pdl_addr_reg) - 2);
          pdl_adr_2 <= std_logic_vector(unsigned(pdl_addr_reg) - 1);
          rd_pdl    <= '1';

          pdl_addr_comb <= std_logic_vector(unsigned(pdl_addr_reg) - 2);
          wr_pdl_reg   <= '1';
        end if;
      when deref_t =>
        reset_deref_reg <= '0';
        deref1_start  <= '1' and not deref1_done_reg;
        deref2_start  <= '1' and not deref2_done_reg;
        deref1_output <= pdl_out_1;
        deref2_output <= pdl_out_2;
        mem_sel <= sel_deref_t;
      when check_equal_read_t =>
        if (fpwam_tag(deref1_input) = tag_ref_t or fpwam_tag(deref2_input) = tag_ref_t)
        and not(fpwam_value(deref1_input) = fpwam_value(deref2_input)) then
          bind1_output <= deref1_input;
          bind2_output <= deref2_input;
          bind_start   <= '1';
          mem_sel      <= sel_bind_t;
        else
          case fpwam_tag(deref2_input) is
            when tag_int_t =>
             if fpwam_value(deref1_input) /= fpwam_value(deref2_input) then
              fail_comb <= '1';
             else
              fail_comb <= '0';
             end if;
            when tag_lis_t =>
              if fpwam_tag(deref1_input) /= tag_lis_t then
                fail_comb <= '1';
              else
                pdl_in_1  <= fpwam_word(std_logic_vector(fpwam_value(deref1_input)), tag_ref_t);
                pdl_in_2  <= fpwam_word(std_logic_vector(fpwam_value(deref2_input)), tag_ref_t);
                pdl_adr_1 <= pdl_addr_reg;
                pdl_adr_2 <= std_logic_vector(unsigned(pdl_addr_reg) + 1);
                wr_pdl   <= '1';
                rd_pdl   <= '1';
                pdl_addr_comb <= std_logic_vector(unsigned(pdl_addr_reg) + 2);
                wr_pdl_reg <= '1';
              end if;
            when tag_str_t =>
              if fpwam_tag(deref1_input) /= tag_str_t then
                fail_comb <= '1';
              else
                mem1_output  <= fpwam_value(deref1_input);
                rd_mem_port1 <= '1';
                mem2_output  <= fpwam_value(deref2_input);
                rd_mem_port2 <= '1';
                mem_sel      <= sel_unify_t;
              end if;
            when others =>
              null;
          end case;
        end if;
      when bind_t =>
        mem_sel <= sel_bind_t;
      when push_list_t =>
        pdl_in_1  <= fpwam_word(std_logic_vector(unsigned(fpwam_value(deref1_input))+1), tag_ref_t);
        pdl_in_2  <= fpwam_word(std_logic_vector(unsigned(fpwam_value(deref2_input))+1), tag_ref_t);
        pdl_adr_1 <= pdl_addr_reg;
        pdl_adr_2 <= std_logic_vector(unsigned(pdl_addr_reg) + 1);
        wr_pdl   <= '1';
        rd_pdl   <= '1';
        pdl_addr_comb <= std_logic_vector(unsigned(pdl_addr_reg) + 2);
        wr_pdl_reg <= '1';
      when check_structure_t =>
        mem_reg_wr <= '1';
      when check_structure_t2 =>
        if fpwam_functor(mem1_input_reg) /= fpwam_functor(mem2_input_reg) or
           fpwam_arity(mem1_input_reg) /= fpwam_arity(mem2_input_reg) then
          fail_comb <= '1';
        else
          rst_curr_reg <= '1';
          wr_goal_reg  <= '1';
          iterate <= '1';
        end if;
      when structure_iterate_t =>
        iterate  <= '1';
        if not iterate_done = '1' then
          pdl_in_1 <= fpwam_word(std_logic_vector(unsigned(fpwam_value(deref1_input))+current_reg), tag_ref_t);
          pdl_in_2 <= fpwam_word(std_logic_vector(unsigned(fpwam_value(deref2_input))+current_reg), tag_ref_t);
          pdl_adr_1 <= pdl_addr_reg;
          pdl_adr_2 <= std_logic_vector(unsigned(pdl_addr_reg) + 1);
          wr_pdl   <= '1';
          rd_pdl   <= '1';
          pdl_addr_comb <= std_logic_vector(unsigned(pdl_addr_reg) + 2);
          wr_pdl_reg <= '1';
        end if;
      when done_t =>
 	  	  unify_done <= '1';
      when others =>
        null;
    end case;
  end process;
end Behavioral;
