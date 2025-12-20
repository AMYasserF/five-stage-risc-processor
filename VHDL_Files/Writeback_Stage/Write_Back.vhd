LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

entity Write_Back is
  port(
	 clk : in std_logic;
	 rst : in std_logic;
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
	 Swap_Phase_Next : out std_logic;
	 Swap_Counter : out std_logic  -- Output counter for HDU
   );
end entity;

architecture a_Write_Back of Write_Back is
  signal TwoRegsDataMux : std_logic_vector(31 downto 0);
  signal WriteBackMuxSelect : std_logic_vector(1 downto 0);
  signal swap_counter_internal : std_logic := '0';  -- Internal counter for SWAP phase
  signal swap_cycle_count : integer := 0;  -- Track number of SWAP cycles completed
begin
  -- Use internal counter for swap_phase_next
  Swap_Phase_Next <= swap_counter_internal;
  
  -- Output counter to HDU
  Swap_Counter <= swap_counter_internal;
  
  -- Counter process: 0->1 after first cycle, then stops
  process(clk, rst)
  begin
    if rst = '1' then
      swap_counter_internal <= '0';
      swap_cycle_count <= 0;
    elsif rising_edge(clk) then
      if Is_Swap = '1' then
        -- Increment cycle counter
        swap_cycle_count <= swap_cycle_count + 1;
        
        -- Toggle counter after first cycle (0->1), then stay at 1
        if swap_cycle_count = 0 then
          swap_counter_internal <= '1';
        end if;
      else
        -- Reset when SWAP completes
        swap_counter_internal <= '0';
        swap_cycle_count <= 0;
      end if;
    end if;
  end process;
  WriteBackMuxSelect <= Is_Input & MemToReg;
  
  -- For OUT instruction, output the ALU result (which contains the register value passed through)
  Output_Port_Data <= ALU_Result when Is_Output='1'
  else (others => '0');
  
  -- Write Back Register selection using internal counter
  process(swap_counter_internal, Rdst, Rsrc1)
  begin
    if swap_counter_internal = '0' then
      Write_Back_Register <= Rdst;
    else  -- swap_counter_internal = '1'
      Write_Back_Register <= Rsrc1;
    end if;
  end process;
  
  -- Two Register Data Mux (for SWAP) using internal counter
  process(swap_counter_internal, ALU_Result, R_data2)
  begin
    if swap_counter_internal = '0' then
      TwoRegsDataMux <= ALU_Result;
    else  -- swap_counter_internal = '1'
      TwoRegsDataMux <= R_data2;
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