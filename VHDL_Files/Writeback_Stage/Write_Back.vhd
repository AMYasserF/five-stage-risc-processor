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
  signal TwoRegsDataMux : std_logic_vector(31 downto 0);
  signal WriteBackMuxSelect : std_logic_vector(1 downto 0);
begin
  Swap_Phase_Next <= Is_Swap and not Swap_Phase;
  WriteBackMuxSelect <= Is_Input & MemToReg;
  
  -- For OUT instruction, output the ALU result (which contains the register value passed through)
  Output_Port_Data <= ALU_Result when Is_Output='1'
  else (others => '0');
  
  -- Write Back Register selection
  process(Swap_Phase, Rdst, Rsrc1)
  begin
    if Swap_Phase = '0' then
      Write_Back_Register <= Rdst;
    elsif Swap_Phase = '1' then
      Write_Back_Register <= Rsrc1;
    else
      Write_Back_Register <= (others => '0');
    end if;
  end process;
  
  -- Two Register Data Mux (for SWAP)
  process(Swap_Phase, ALU_Result, R_data2)
  begin
    if Swap_Phase = '0' then
      TwoRegsDataMux <= ALU_Result;
    elsif Swap_Phase = '1' then
      TwoRegsDataMux <= R_data2;
    else
      TwoRegsDataMux <= (others => '0');
    end if;
  end process;
  
  -- Writeback Data Mux
  process(WriteBackMuxSelect, TwoRegsDataMux, Mem_Result, Input_Port_Data)
  begin
    case WriteBackMuxSelect is
      when "00" => Write_Back_Data <= TwoRegsDataMux;
      when "01" => Write_Back_Data <= Mem_Result;
      when "10" => Write_Back_Data <= Input_Port_Data;
      when "11" => Write_Back_Data <= Input_Port_Data;
      when others => Write_Back_Data <= (others => '0');
    end case;
  end process;
		
end a_Write_Back;