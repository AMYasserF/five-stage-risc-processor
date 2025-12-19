LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

entity Hazard_Detection_Unit_tb is
end entity;

architecture a_Hazard_Detection_Unit_tb of Hazard_Detection_Unit_tb is
  
  component Hazard_Detection_Unit is
  port(
    mem_mem_read : in std_logic; --Fetch_Memory use
	 mem_mem_write : in std_logic; --Fetch_Memory use
	 mem_is_pop : in std_logic; --Pop load use
	 mem_rdst : in std_logic_vector(2 downto 0); --Pop load use
	 ex_rsrc1 : in std_logic_vector(2 downto 0); --Pop load use
	 ex_rsrc2 : in std_logic_vector(2 downto 0); --Pop load use
	 ex_is_conditional : in std_logic; --Conditional jump
	 ex_has_one_operand : in std_logic; --Pop load use 
	 ex_has_two_operands : in std_logic; --Pop load use
	 mem_is_int : in std_logic; --Interrupt
	 mem_is_ret : in std_logic; --Return
	 mem_is_rti : in std_logic; --Return interrupt
	 wb_is_swap : in std_logic; --Swap
	 wb_swap_phase : in std_logic; --Swap
	 mem_int_phase : in std_logic_vector(1 downto 0); --Interrupt
	 mem_rti_phase : in std_logic; --Return interrupt
	 if_flush : out std_logic; --Fetch_Memory use / Conditional jump / Return / Interrupt / Return interrupt
	 id_flush : out std_logic; --Return / Interrupt / Return interrupt
	 if_id_enable : out std_logic; --Swap
	 id_ex_enable : out std_logic; --Swap
	 ex_mem_enable : out std_logic; --Pop load use / Swap
	 pc_enable : out std_logic --Fetch_Memory use
  );
  end component;
  
   signal mem_mem_read_t : std_logic := '0'; 
	 signal mem_mem_write_t : std_logic := '0';
	 signal mem_is_pop_t : std_logic := '0';
	 signal mem_rdst_t : std_logic_vector(2 downto 0) := "000";
	 signal ex_rsrc1_t : std_logic_vector(2 downto 0) := "000"; 
	 signal ex_rsrc2_t : std_logic_vector(2 downto 0) := "000"; 
	 signal ex_is_conditional_t : std_logic := '0';
	 signal ex_has_one_operand_t : std_logic := '0';  
	 signal ex_has_two_operands_t : std_logic := '0';
	 signal mem_is_int_t : std_logic := '0'; 
	 signal mem_is_ret_t : std_logic := '0'; 
	 signal mem_is_rti_t : std_logic := '0'; 
	 signal wb_is_swap_t : std_logic := '0'; 
	 signal wb_swap_phase_t : std_logic := '0'; 
	 signal mem_int_phase_t : std_logic_vector(1 downto 0) := "00";
	 signal mem_rti_phase_t : std_logic := '0';
	 signal if_flush_t : std_logic := '0'; 
	 signal id_flush_t : std_logic := '0';
	 signal if_id_enable_t : std_logic := '0'; 
	 signal id_ex_enable_t : std_logic := '0'; 
	 signal ex_mem_enable_t : std_logic := '0'; 
	 signal pc_enable_t : std_logic := '0';
	 
begin
  HDU : Hazard_Detection_Unit port map(
    mem_mem_read_t, 
	 mem_mem_write_t,
	 mem_is_pop_t,
	 mem_rdst_t, 
	 ex_rsrc1_t,  
	 ex_rsrc2_t,  
	 ex_is_conditional_t, 
	 ex_has_one_operand_t,
	 ex_has_two_operands_t,
	 mem_is_int_t,  
	 mem_is_ret_t,  
	 mem_is_rti_t,  
	 wb_is_swap_t,  
	 wb_swap_phase_t, 
	 mem_int_phase_t, 
	 mem_rti_phase_t, 
	 if_flush_t,
	 id_flush_t, 
	 if_id_enable_t,
	 id_ex_enable_t,
	 ex_mem_enable_t, 
	 pc_enable_t
  );
  
  process
  begin
    --Testing fetch/memory structural hazard
    mem_mem_read_t <= '1';
    mem_mem_write_t <= '0';
    mem_is_pop_t <= '0';
    mem_rdst_t <= "000";
    ex_rsrc1_t <= "000";
    ex_rsrc2_t <= "000";
    ex_is_conditional_t <= '0';
    ex_has_one_operand_t <= '0';
    ex_has_two_operands_t <= '0';
    mem_is_ret_t <= '0';
    mem_is_int_t <= '0';
    mem_is_rti_t <= '0';
    wb_is_swap_t <= '0';
    wb_swap_phase_t <= '0';
    mem_int_phase_t <= "00";
    mem_rti_phase_t <= '0';
    wait for 50 ns;
    mem_mem_write_t <= '1';
    wait for 50 ns;
    mem_mem_read_t <= '0';
    wait for 50 ns;
    
    --Testing pop load use
    mem_mem_write_t <= '0';
    mem_is_pop_t <= '1';
    mem_rdst_t <= "101";
    ex_rsrc1_t <= "101";
    ex_rsrc2_t <= "011";
    ex_has_two_operands_t <= '1';
    ex_has_one_operand_t <= '1';
    wait for 50 ns;
    mem_rdst_t <= "011";
    wait for 50 ns;
    ex_has_two_operands_t <= '0';
    wait for 50 ns;
    mem_rdst_t <= "000";
    ex_rsrc1_t <= "000";
    ex_has_one_operand_t <= '0';
    wait for 50 ns;
    
    --Testing conditional jump
    mem_is_pop_t <= '0';
    ex_is_conditional_t <= '1';
    wait for 50 ns;
    
    --Testing interrupt
    ex_is_conditional_t <= '0';
    mem_is_int_t <= '1';
    mem_int_phase_t <= "00";
    wait for 50 ns;
    mem_int_phase_t <= "01";
    wait for 50 ns;
    mem_int_phase_t <= "10";
    wait for 50 ns;
    mem_int_phase_t <= "11";
    wait for 50 ns;
    
    --Testing return
    mem_is_int_t <= '0';
    mem_is_ret_t <= '1';
    wait for 50 ns;
    
    --Testing return interrupt
    mem_is_ret_t <= '0';
    mem_is_rti_t <= '1';
    mem_rti_phase_t <= '0';
    wait for 50 ns;
    mem_rti_phase_t <= '1';
    wait for 50 ns;
    
    --Testing swap
    mem_is_rti_t <= '0';
    wb_is_swap_t <= '1';
    wb_swap_phase_t <= '0';
    wait for 50 ns;
    wb_swap_phase_t <= '1';
    wait for 50 ns;
  end process;
  
end a_Hazard_Detection_Unit_tb;