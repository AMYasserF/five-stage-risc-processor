LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

entity Write_Back is
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
end entity;

architecture a_Write_Back of Write_Back is
  signal TwoRegsDataMux : std_logic_vector(31 downto 0) := (others => '0');
  signal WriteBackMuxSelect : std_logic_vector(1 downto 0) := "00";
begin
  Swap_Phase_Next <= Is_Swap and not Swap_Phase;
  WriteBackMuxSelect <= Is_Input & MemToReg;
  Output_Port_Data <= R_data2 when Is_Output='1';
  
  with Swap_Phase select
    Write_Back_Register <= 
	   Rdst when '0',
		Rsrc1 when '1',
		(others => '0') when others;
		
  with Swap_Phase select
    TwoRegsDataMux <= 
	   ALU_Result when '0',
		R_data2 when '1',
		(others => '0') when others;
  
  with WriteBackMuxSelect select
    Write_Back_Data <=
	   TwoRegsDataMux when "00",
		Mem_Result when "01",
		Input_Port_Data when "10",
		Input_Port_Data when "11",
		(others => '0') when others;
		
end a_Write_Back; 
	 