library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Control Unit Template for PC Mux
-- This control unit decides which input to select for the PC Mux
-- Selection options:
--   "00" - PC + 1 (normal increment)
--   "01" - PC + 1 from IF/ID register
--   "10" - From Memory
--   "11" - From ALU

entity PC_Mux_Control is
    Port (
        -- Input control signals (to be defined based on instruction decode)
        opcode : in STD_LOGIC_VECTOR(7 downto 0);
        branch_condition : in STD_LOGIC;
        -- Add other control signals as needed
        
        -- Output
        pc_mux_sel : out STD_LOGIC_VECTOR(1 downto 0)
    );
end PC_Mux_Control;

architecture Behavioral of PC_Mux_Control is
begin
    -- TODO: Implement control logic
    -- For now, default to normal PC increment
    process(opcode, branch_condition)
    begin
        -- Placeholder logic - will be implemented later
        pc_mux_sel <= "00";  -- Default: PC + 1
    end process;
end Behavioral;
