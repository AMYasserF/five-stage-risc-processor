library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Control Unit Template for Memory Write Data Mux
-- This control unit decides which data to write to memory
-- Selection options:
--   "00" - CCR Register (saving condition codes)
--   "01" - PC + 1 from ID/EX register (for call/interrupt)
--   "10" - Data from Register File (normal store)

entity Memory_Write_Data_Mux_Control is
    Port (
        -- Input control signals (to be defined based on instruction decode)
        opcode : in STD_LOGIC_VECTOR(7 downto 0);
        is_store : in STD_LOGIC;
        is_call : in STD_LOGIC;
        is_ccr_save : in STD_LOGIC;
        -- Add other control signals as needed
        
        -- Output
        mem_write_data_mux_sel : out STD_LOGIC_VECTOR(1 downto 0)
    );
end Memory_Write_Data_Mux_Control;

architecture Behavioral of Memory_Write_Data_Mux_Control is
begin
    -- TODO: Implement control logic
    -- For now, default to register file data
    process(opcode, is_store, is_call, is_ccr_save)
    begin
        -- Placeholder logic - will be implemented later
        mem_write_data_mux_sel <= "10";  -- Default: Register File Data
    end process;
end Behavioral;
