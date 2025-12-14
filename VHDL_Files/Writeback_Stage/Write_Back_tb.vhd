LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

entity Write_Back_tb is
end entity;

architecture a_Write_Back_tb of Write_Back_tb is
  component Write_Back is
  port(
	 MemToReg : in std_logic;
	 Is_Input : in std_logic;
	 Is_Output : in std_logic;
	 Is_Swap : in std_logic;
	 Swap_Phase : in std_logic;
	 Rdst : in std_logic_vector(2 downto 0);
	 Rsrc1 : in std_logic_vector(2 downto 0);
	 R_data2 : in std_logic_vector(31 downto 0);
	 ALU_Result : in std_logic_vector(31 downto 0);
	 Mem_Result : in std_logic_vector(31 downto 0);
	 Input_Port_Data : in std_logic_vector(31 downto 0);
	 Output_Port_Data : out std_logic_vector(31 downto 0);
	 Write_Back_Data : out std_logic_vector(31 downto 0);
	 Write_Back_Register : out std_logic_vector(2 downto 0);
	 Swap_Phase_Next : out std_logic
   );
  end component;
  
  signal MemToReg_t, is_input_t, is_output_t, is_swap_t, swap_phase_t, swap_phase_next_t : std_logic := '0';
  signal rdst_t, rsrc1_t, write_back_register_t : std_logic_vector(2 downto 0) := (others => '0');
  signal r_data2_t, alu_result_t, mem_result_t, input_port_data_t, output_port_data_t, write_back_data_t : std_logic_vector(31 downto 0) := (others => '0');
   
begin
  wb : Write_Back port map(
    MemToReg => MemToReg_t,
    Is_Input => Is_Input_t,
    Is_Output => Is_Output_t,
    Is_Swap => Is_Swap_t,
    Swap_Phase => swap_phase_t,
    Rdst => rdst_t,
    Rsrc1 => rsrc1_t,
    R_data2 => R_data2_t,
    ALU_Result => alu_result_t,
    mem_result => mem_result_t,
    input_port_data => input_port_data_t,
    output_port_data => output_port_data_t,
    write_back_data => write_back_data_t,
    write_back_register => write_back_register_t,
    swap_phase_next => swap_phase_next_t
  );
  
  process
  begin
    
    --Testing write back from ALU result
    MemToReg_t <= '0'; Is_Input_t <= '0';
    Is_Output_t <= '0'; Is_Swap_t <= '0'; Swap_Phase_t <= '0';
    rdst_t <= std_logic_vector(to_unsigned(4 , 3));
    rsrc1_t <= std_logic_vector(to_unsigned(7 , 3));
    r_data2_t <= std_logic_vector(to_unsigned(50 , 32));
    alu_result_t <= std_logic_vector(to_unsigned(75 , 32));
    mem_result_t <= std_logic_vector(to_unsigned(100 , 32));
    input_port_data_t <= std_logic_vector(to_unsigned(125 , 32));
    wait for 50 ns;
    
    --Testing write back from memory result
    MemToReg_t <= '1';
    wait for 50 ns;
    
    --Testing write back from input port
    MemToReg_t <= '0';
    Is_Input_t <= '1';
    wait for 50 ns;
    
    --Simulating swapping
    Is_Input_t <= '0';
    Is_Swap_t <= '1';
    wait for 50 ns;
    Swap_Phase_t <= '1';
    wait for 50 ns;
    
    --Testing writing to output port
    Is_Swap_t <= '0';
    Swap_Phase_t <= '0';
    Is_Output_t <= '1';
    wait for 50 ns;
        
  end process;
end a_Write_Back_tb;