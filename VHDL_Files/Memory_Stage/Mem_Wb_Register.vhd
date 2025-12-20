library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Mem_Wb_Register is
  port(
    rst, clk : in std_logic;
	 enable : in std_logic;
	 mem_to_reg : in std_logic;
	 out_enable : in std_logic;
	 is_swap : in std_logic;
	 swap_phase : in std_logic;
	 reg_write : in std_logic;
	 is_input : in std_logic;
	 rdst : in std_logic_vector(2 downto 0);
	 rsrc1 : in std_logic_vector(2 downto 0);
	 r_data2 : in std_logic_vector(31 downto 0);
	 alu_result : in std_logic_vector(31 downto 0);
	 mem_data : in std_logic_vector(31 downto 0);
	 input_port_data : in std_logic_vector(31 downto 0);
	 mem_to_reg_out : out std_logic;
	 out_enable_out : out std_logic;
	 is_swap_out : out std_logic;
	 swap_phase_out : out std_logic;
	 reg_write_out : out std_logic;
	 is_input_out : out std_logic;
	 rdst_out : out std_logic_vector(2 downto 0);
	 rsrc1_out : out std_logic_vector(2 downto 0);
	 r_data2_out : out std_logic_vector(31 downto 0);
	 alu_result_out : out std_logic_vector(31 downto 0);
	 mem_data_out : out std_logic_vector(31 downto 0);
	 input_port_data_out : out std_logic_vector(31 downto 0)
  );
end entity;

architecture a_Mem_Wb_Register of Mem_Wb_Register is
begin 
  process(rst, clk)
  begin
    if(rst = '1')
	 then
		mem_to_reg_out <= '0';
		out_enable_out <= '0';
		is_swap_out <= '0';
		swap_phase_out <= '0';
		reg_write_out <= '0';
		is_input_out <= '0';
		rdst_out <= "000";
		rsrc1_out <= "000";
		r_data2_out <= (others => '0');
		alu_result_out <= (others => '0');
		mem_data_out <= (others => '0');
		input_port_data_out <= (others => '0');
	 elsif(rising_edge(clk) and enable = '1')
	 then
	   mem_to_reg_out <= mem_to_reg;
		out_enable_out <= out_enable;
		is_swap_out <= is_swap;
		swap_phase_out <= swap_phase;
		reg_write_out <= reg_write;
		is_input_out <= is_input;
		rdst_out <= rdst;
		rsrc1_out <= rsrc1;
		r_data2_out <= r_data2;
		alu_result_out <= alu_result;
		mem_data_out <= mem_data;
		input_port_data_out <= input_port_data;
	 end if;
  end process;
end a_Mem_Wb_Register;