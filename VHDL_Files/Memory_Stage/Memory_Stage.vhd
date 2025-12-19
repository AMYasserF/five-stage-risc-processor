library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Memory_Stage is
    Port (       
        -- Control signals from control unit
		  is_ret : in STD_LOGIC;
		  is_rti : in STD_LOGIC;
		  rti_phase : in STD_LOGIC;
		  is_int : STD_LOGIC;
		  int_phase : STD_LOGIC;		  
        mem_read : in STD_LOGIC;
        mem_write : in STD_LOGIC;
		  is_push : in STD_LOGIC;
		  alu_address : in STD_LOGIC;
		  mem_to_reg : in STD_LOGIC;
		  is_pop : in STD_LOGIC;
		  out_enable : in STD_LOGIC;
		  is_swap : in STD_LOGIC;
		  swap_phase_previous : in STD_LOGIC;
		  swap_phase_next : in STD_LOGIC;
		  reg_write : in STD_LOGIC;
		  is_call : in STD_LOGIC;
		  is_input : in STD_LOGIC;
		  
		  is_ret_out : out STD_LOGIC;
		  is_rti_out : out STD_LOGIC;
		  rti_phase_out : out STD_LOGIC;
		  is_int_out : out STD_LOGIC;
		  int_phase_out : out STD_LOGIC;		  
        mem_read_out : out STD_LOGIC;
        mem_write_out : out STD_LOGIC;
		  is_push_out : out STD_LOGIC;
		  alu_address_out : out STD_LOGIC;
		  mem_to_reg_out : out STD_LOGIC;
		  is_pop_out : out STD_LOGIC;
		  out_enable_out : out STD_LOGIC;
		  is_swap_out : out STD_LOGIC;
		  swap_phase_out : out STD_LOGIC;
		  reg_write_out : out STD_LOGIC;
		  is_call_out : out STD_LOGIC;
		  is_input_out : out STD_LOGIC;
        
        -- Data from EX/MEM pipeline register
		  rdst : in STD_LOGIC_VECTOR(2 downto 0);
		  rsrc1 : in STD_LOGIC_VECTOR(2 downto 0);
		  r_data2 : in STD_LOGIC_VECTOR(31 downto 0);
        alu_result : in STD_LOGIC_VECTOR(31 downto 0);
		  input_port_data : in STD_LOGIC_VECTOR(31 downto 0);

        
        -- Interface to Memory System
		  mem_read_data : in STD_LOGIC_VECTOR(31 downto 0);
            
        -- Outputs to MEM/WB pipeline register
		  rdst_out : out STD_LOGIC_VECTOR(2 downto 0);
		  rsrc1_out : out STD_LOGIC_VECTOR(2 downto 0);
		  r_data2_out : out STD_LOGIC_VECTOR(31 downto 0);
		  alu_result_out : out STD_LOGIC_VECTOR(31 downto 0);
        mem_data_out : out STD_LOGIC_VECTOR(31 downto 0);
		  input_port_data_out : out STD_LOGIC_VECTOR(31 downto 0)
    );
end Memory_Stage;

architecture a_Memory_Stage of Memory_Stage is
begin
  is_ret_out <= is_ret;
  is_rti_out <= is_rti;
  rti_phase_out <= rti_phase;
  is_int_out <= is_int;
  int_phase_out <= int_phase;
  mem_read_out <= mem_read;
  mem_write_out <= mem_write;
  is_push_out <= is_push;
  alu_address_out <= alu_address;
  mem_to_reg_out <= mem_to_reg;
  is_pop_out <= is_pop;
  out_enable_out <= out_enable;
  is_swap_out <= is_swap;
  swap_phase_out <= swap_phase_next or swap_phase_previous;
  reg_write_out <= reg_write;
  is_call_out <= is_call;
  is_input_out <= is_input;
  rdst_out <= rdst;
  rsrc1_out <= rsrc1;
  r_data2_out <= r_data2;
  alu_result_out <= alu_result;
  mem_data_out <= mem_read_data;
  input_port_data_out <= input_port_data;
end a_Memory_Stage;