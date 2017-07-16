-------------------------------------------------------------------------------
-- FILE NAME      : ControlUnit.vhd
-- MODULE NAME    : ControlUnit
-- AUTHOR         : Bogdan Ardelean
-- AUTHOR'S EMAIL : bogdan.ardelean@yahoo.com
-------------------------------------------------------------------------------
-- REVISION HISTORY
-- VERSION  DATE         AUTHOR            DESCRIPTION
-- 1.0      2016-05-03   Bogdan Ardelean   Created
-------------------------------------------------------------------------------
-- DESCRIPTION    :
--
-------------------------------------------------------------------------------

library ieee;

use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.FpwamPkg.all;

entity ControlUnit is
  port
  (
    clk  : in std_logic;
    rsti : in std_logic;

    query_done : in std_logic;

    uart_in       : in std_logic_vector(7 downto 0);
    uart_in_valid : in std_logic;

    uart_out       : out std_logic_vector(7 downto 0);
    uart_out_str   : out std_logic;
    uart_out_ack   : in std_logic;
	
	mem_addr       : out std_logic_vector(kWamAddressWidth -1 downto 0);
	mem_in 		   : in std_logic_vector(kWamWordWidth -1 downto 0);
	mem_rd         : out std_logic;

    deref_start    : out std_logic;
    deref_out      : out std_logic_vector(kWamWordWidth - 1 downto 0);
    deref_in       : in  std_logic_vector(kWamWordWidth -1 downto 0);
    deref_done     : in std_logic;
    
    instruction_out   : out std_logic_vector(kWamInstructionWidth -1 downto 0);
    instruction_write : out std_logic;
    instruction_addr  : out std_logic_vector(kWamInstrMemWidth -1 downto 0);
    
    p_address      : out std_logic_vector(kWamInstrMemWidth -1 downto 0);
    p_wr           : out std_logic;
    
    cindex_out     : out std_logic_vector(kWamWordWidth -1 downto 0);
    cindex_addr    : out std_logic_vector(kWamInstrMemWidth -1 downto 0);
    cindex_wr      : out std_logic;
    
    proc_mode      : out proc_mode_t;
    sys_rst        : out std_logic;
    start_btn      : in std_Logic
  );
end ControlUnit;

architecture Behavioral of ControlUnit is
constant kPdlAddressWidth : integer := 10;
signal pdl_in_1     : std_logic_vector(kWamWordWidth -1 downto 0);
signal pdl_out_1    : std_logic_vector(kWamWordWidth -1 downto 0);
signal pdl_adr_1    : std_logic_vector(kPdlAddressWidth -1 downto 0);
signal wr_pdl       : std_logic;
signal rd_pdl       : std_logic;

signal pdl_addr_reg  : std_logic_vector(kPdlAddressWidth -1 downto 0);
signal pdl_addr_comb : std_logic_vector(kPdlAddressWidth -1 downto 0);
signal wr_pdl_reg    : std_logic;
signal pdl_empty     : boolean;

signal current_reg  : unsigned(kGPRAddressWidth downto 0);
signal wr_curr_reg  : std_logic;
signal rst_curr_reg : std_logic;

signal goal_reg     : unsigned(kGPRAddressWidth downto 0);
signal wr_goal_reg  : std_logic;
signal iterate_done : std_logic;

signal iterate : std_logic;

signal local_reset   : std_logic;
signal rst           : std_logic;
signal sys_rst_start : std_logic := '1';

signal var_to_read       : unsigned(kGPRAddressWidth downto 0) := to_unsigned(2, kGPRAddressWidth+1);
signal var_current_reg   : unsigned(kGPRAddressWidth downto 0);
signal var_curr_done     : boolean;
signal var_curr_wr       : std_logic;

signal to_write : std_logic_vector(kWamWordWidth -1 downto 0);
signal to_write_comb : std_logic_vector(kWamWordWidth -1 downto 0);
signal to_wr    : std_logic;

signal mem_reg : std_logic_vector(kWamWordWidth -1 downto 0);
signal mem_reg_wr: std_logic;

signal message : control_message_t; 

type state_t is (idle_t, 
                 add_cindex_t,
                 add_instruction_t, it_instruction_t, put_instruction_t, get_igoal_t, 
                 add_query_t, wait_query_t,
                 check_structure_t, check_structure_t2, 
                 uart_send_t, uart_send_t2, uart_send_t3, 
                 structure_iterate_t, iterate_t, check_stop_pop_t, deref_t, push_list_t, done_t);
signal cr_state, nx_state : state_t;
signal decoded_state : state_t;

signal recover_state : state_t;
signal recover_state_comb : state_t;
signal wr_rec_state  : std_logic;

signal instruction_count : std_logic_vector(kWamInstrMemWidth -1 downto 0);
signal instruction_wr    : std_logic;

signal instruction_goal    : std_logic_vector(kWamInstrMemWidth -1 downto 0);
signal instruction_goal_wr : std_logic;

signal rst_instr     : std_logic;

signal uart_sh_reg  : std_logic_vector(31 downto 0);
signal uart_sh_wr   : std_logic;
signal uart_sh_rst  : std_logic;

signal uart_recv_count : unsigned(kWamWordWidth -1 downto 0);
signal uart_recv_wr    : std_logic;
signal uart_count      : std_logic;
signal uart_recv_comb  : unsigned(kWamWordWidth -1 downto 0);
signal uart_cnt_done   : boolean;

begin

  uart_cnt_done <= uart_recv_count = 0;
  UARTCNT: process(clk)
  begin
    if rising_edge(clk) then
       if sys_rst_start = '1' then
          uart_recv_count <= (others => '0');
       elsif uart_recv_wr = '1' then
          uart_recv_count <= uart_recv_comb;
       elsif uart_count = '1' and uart_in_valid = '1' then
          uart_recv_count <= uart_recv_count - 1;
       end if;
    end if;
  end process;

  UARTSH: process(clk)
  begin
    if rising_edge(clk) then
        if sys_rst_start = '1' or uart_sh_rst = '1' then
            uart_sh_reg <= (others => '0');
        elsif uart_sh_wr = '1' and uart_in_valid = '1' then
            uart_sh_reg <= uart_sh_reg(23 downto 0)&uart_in;
        end if;
    end if;
  end process;

  ICNT: process(clk)
  begin
    if rising_edge(clk) then
       if sys_rst_start = '1' or rst_instr = '1' then
         instruction_count <= (others => '0');
       elsif instruction_wr = '1' then
         instruction_count <= std_logic_vector(unsigned(instruction_count)+1);
       end if;
   end if;
 end process;
 
 
 IGOAL: process(clk)
 begin
   if rising_edge(clk) then
      if sys_rst_start = '1' or rst_instr = '1' then
        instruction_goal <= (others => '0');
      elsif instruction_goal_wr = '1' then
        instruction_goal <= uart_sh_reg(kWamInstrMemWidth -1 downto 0);
      end if;
  end if;
end process;

  RECREG: process(clk)
  begin
    if rising_edge(clk) then
      if sys_rst_start = '1' then
        recover_state <= idle_t;
      elsif wr_rec_state = '1' then
        recover_state <= recover_state_comb;
      end if;
    end if;
  end process; 
  
  message <= fpwam_cm(uart_in);
  
  DECODE_STATE_FIRST: process(message)
    begin
      decoded_state <= idle_t;
        case message is
          when cm_query_t =>
            decoded_state <= add_query_t;
          when cm_instruction_t =>
            decoded_state <= add_instruction_t;
          when cm_cindex_t =>
            decoded_state <= add_cindex_t;
          when others =>
            decoded_state <= idle_t;
        end case;
    end process DECODE_STATE_FIRST;
  
  MMREG: process(clk)
  begin
    if rising_edge(clk) then
       if rsti = '1' then
          mem_reg <= (others => '0');
       elsif mem_reg_wr = '1' then
          mem_reg <= mem_in;
       end if;
   end if;
  end process;
           
  TOWRREG: process(clk)
  begin
	if rising_edge(clk) then
      if rst = '1' or local_reset = '1' then
		to_write <= (others => '0');
	  elsif to_wr = '1' then
		to_write <= to_write_comb;
	  end if;
	 end if;
  end process;
  sys_rst <= sys_rst_start or rsti or rst;
  pdl_empty <= unsigned(pdl_addr_reg) = 0;
  
  wr_pdl_reg <= wr_pdl or rd_pdl;
  PDLREG: process(clk)
  begin
    if rising_edge(clk) then
       if rst = '1' or local_reset = '1' then
        pdl_addr_reg <= (others => '0');
       elsif wr_pdl_reg = '1' then
        pdl_addr_reg <= pdl_addr_comb;
       end if;
    end if;
  end process;


  RSTPRC: process(clk)
  begin
      if rising_edge(clk) then
         sys_rst_start <= '0';
      end if;
  end process;

  pdl_adr_1 <= pdl_addr_reg when wr_pdl = '1' else
               std_logic_vector(unsigned(pdl_addr_reg)-1);
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

            ,addr_port_2   => (others => '0')
            ,word_port_2_o => open
            ,word_port_2_i => (others => '0')
            ,wr_port_2     => '0'
            ,rd_port_2     => '0'
          );

  CURRERG: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' or rst_curr_reg = '1' or local_reset = '1' then
        current_reg <= to_unsigned(1, kGPRAddressWidth+1);
      elsif wr_curr_reg = '1' then
        current_reg <= current_reg + 1;
      end if;
    end if;
  end process;

  GOALREG: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' or local_reset = '1' then
        goal_reg <= (others => '0');
      elsif wr_goal_reg = '1' then
        goal_reg <= "0" & unsigned(fpwam_arity(mem_in));
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

  VARCURREG: process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' or sys_rst_start = '1' then
        var_current_reg <= (others => '0');
      elsif var_curr_wr = '1' then
        var_current_reg <= var_current_reg + 1;
      end if;
    end if;
  end process;

  var_curr_done <= var_current_reg >= var_to_read;

  FSM: process(clk, rsti)
  begin
    if rising_edge(clk) then
      if rsti = '1' or sys_rst_start = '1' then
        cr_state <= idle_t;
      else
        cr_state <= nx_state;
      end if;
    end if;
  end process;


  NEXT_STATE_DECODE: process(cr_state, start_btn, uart_cnt_done, instruction_count, instruction_goal, deref_done, uart_in_valid, deref_in, uart_in, uart_in_valid, uart_out_ack, query_done, var_curr_done, pdl_empty, iterate_done)
  begin
    nx_state <= cr_state;
    case cr_state is
      when idle_t =>
        if uart_in_valid = '1' then
          nx_state <= decoded_state;
        end if;
      when wait_query_t =>
        if query_done = '1' and start_btn = '1' then
          nx_state <= iterate_t;
        end if;
      when add_instruction_t =>
         nx_state <= get_igoal_t;
      when get_igoal_t =>
         if uart_cnt_done then
            nx_state <= it_instruction_t;
         end if;
      when it_instruction_t =>
        if uart_cnt_done then
            nx_state <= put_instruction_t;
        end if;
      when put_instruction_t =>
        if unsigned(instruction_count) + 1 >= unsigned(instruction_goal) then
            nx_state <= wait_query_t;
        else
            nx_state <= it_instruction_t;
        end if;
      when iterate_t =>
        if not var_curr_done then
          nx_state <= check_stop_pop_t;
        else
          nx_state <= idle_t;
        end if;
      when check_stop_pop_t =>
        if not pdl_empty then
          nx_state <= deref_t;
        else
          nx_state <= iterate_t;
        end if;
      when deref_t =>
        if deref_done = '1' then
          case fpwam_tag(deref_in) is
            when tag_int_t =>
              nx_state <= uart_send_t;
            when tag_lis_t =>
              nx_state <= push_list_t;
            when tag_str_t =>
              nx_state <= check_structure_t;
            when others =>
              nx_state <= uart_send_t;
          end case;
        end if;
      when push_list_t =>
	  nx_state <= uart_send_t; 
--	  when check_structure_t =>
--        nx_state <= check_structure_t2;
	  when check_structure_t =>
	  	nx_state <= structure_iterate_t;
      when structure_iterate_t =>
        if iterate_done = '1' then
          nx_state <= uart_send_t;
        end if;
      when uart_send_t =>
        if uart_out_ack = '1' then
          nx_state <= uart_send_t2;
        end if;
      when uart_send_t2 =>
        if uart_out_ack = '1' then
          nx_state <= uart_send_t3;
        end if;
      when uart_send_t3 =>
        if uart_out_ack = '1' then
          nx_state <= check_stop_pop_t;
        end if;
      when others =>
        null;
    end case;
  end process;

  pdl_addr_comb <= std_logic_vector(unsigned(pdl_addr_reg)+1) when wr_pdl = '1' else
                   std_logic_vector(unsigned(pdl_addr_reg)-1) when rd_pdl = '1' else
                   pdl_addr_reg;

  OUTPUT_DECODE: process(cr_state, pdl_empty, deref_done, deref_in, uart_cnt_done, instruction_count, uart_sh_reg, instruction_goal, var_current_reg, pdl_out_1, iterate_done, mem_reg, current_reg, to_write)
  begin

    pdl_in_1       <= (others => '0');
    uart_out       <= (others => '0');
    uart_out_str   <= '0';
    deref_start    <= '0';
    deref_out      <= (others => '0');
    proc_mode      <= proc_control_t;
    wr_pdl         <= '0';
    rd_pdl         <= '0';
    rst_curr_reg   <= '0';

    wr_goal_reg    <= '0';

    iterate        <= '0';

    local_reset    <= '0';
    rst            <= '0';
    var_curr_wr    <= '0';
    
    to_write_comb <= (others => '0');
    to_wr         <= '0';
    mem_addr      <= (others => '0');
    mem_rd        <= '0';
    mem_reg_wr    <= '0';
   
    recover_state_comb <= idle_t;
    wr_rec_state <= '0';
    
    instruction_wr   <= '0';
    instruction_goal_wr  <= '0';
    rst_instr            <= '0';
  
    uart_sh_wr <= '0';
    uart_sh_rst <= '0';
    
    uart_recv_wr  <= '0';
    uart_count    <= '0';
    
    instruction_out   <= (others => '0');
    instruction_write <= '0';
    instruction_addr  <= (others => '0');
    
    uart_recv_comb  <= (others => '0');
    case cr_state is
      when idle_t =>
        local_reset <= '1';
      when add_instruction_t => 
        uart_recv_comb <= to_unsigned(2, uart_recv_comb'length);
        uart_recv_wr   <= '1';
        rst_instr      <= '1';
        uart_sh_rst <= '1';
        rst <= '1';
      when get_igoal_t =>
        uart_sh_wr <= '1';
        uart_count <= '1';
        if uart_cnt_done then
            instruction_goal_wr <= '1';
            uart_recv_comb <= to_unsigned(4, uart_recv_comb'length);
            uart_recv_wr   <= '1';
            uart_sh_rst <= '1';
        end if;
      when it_instruction_t =>
         uart_count <= '1';
         uart_sh_wr <= '1';
      when put_instruction_t =>
        instruction_write <= '1';
        instruction_addr  <= instruction_count;
        instruction_out   <= uart_sh_reg(kWamInstructionWidth -1 downto 0);
        uart_sh_rst <= '1';
        if not (unsigned(instruction_count) + 1 >= unsigned(instruction_goal)) then
            uart_recv_comb <= to_unsigned(4, uart_recv_comb'length);
            uart_recv_wr   <= '1';
            instruction_wr <= '1';
        end if;

      when wait_query_t =>
        proc_mode <= proc_exec_t;
      when iterate_t =>
        var_curr_wr   <= '1';
        wr_pdl        <= '1';
		rd_pdl        <= '1';
        pdl_in_1    <= fpwam_word(std_logic_vector(var_current_reg), tag_ref_t);
      when check_stop_pop_t =>
        if not pdl_empty then
          rd_pdl <= '1';
        end if;
      when deref_t =>
        if deref_done = '1' then
          case fpwam_tag(deref_in) is
            when tag_int_t =>
			to_wr <= '1';
			to_write_comb <= deref_in;
            when tag_lis_t =>
			wr_pdl <= '1';
			rd_pdl <= '1';
			pdl_in_1 <= fpwam_word(std_logic_vector(fpwam_value(deref_in)), tag_ref_t);
			to_wr <= '1';
			to_write_comb <= deref_in;
            when tag_str_t =>
			  mem_rd <= '1';
			  mem_addr <= std_logic_vector(fpwam_value(deref_in));
            when others =>
              null;
          end case;
        else
          deref_out <= pdl_out_1;
          deref_start <= '1';
        end if;
      when push_list_t =>
	  wr_pdl <= '1';
	  rd_pdl <= '1';
	  pdl_in_1  <= fpwam_word(std_logic_vector(unsigned(fpwam_value(deref_in))+1), tag_ref_t);
	  when check_structure_t =>
	  	 rst_curr_reg <= '1';
         wr_goal_reg  <= '1';
         mem_reg_wr <= '1';
      when structure_iterate_t =>
        iterate <= '1';
        if iterate_done /= '1' then
          pdl_in_1 <= fpwam_word(std_logic_vector(unsigned(fpwam_value(deref_in)) + (unsigned(fpwam_arity(mem_reg))+1 - current_reg)), tag_ref_t);
          wr_pdl <= '1'; 
		  rd_pdl <= '1';
        else
			to_wr <= '1';
			to_write_comb <= mem_reg;
		end if;
      when uart_send_t =>
        uart_out_str <= '1';
        uart_out <= "000000"&to_write(kWamWordWidth-1 downto kWamWordWidth-2);
      when uart_send_t2 =>
        uart_out_str <= '1';
        uart_out <= to_write(kWamWordWidth-3 downto kWamWordWidth -3 - 7);
      when uart_send_t3 =>
        uart_out_str <= '1';
        uart_out <= to_write(7 downto 0);
      when others =>
        null;
    end case;
  end process;

end Behavioral;

