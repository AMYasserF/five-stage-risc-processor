library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Control Unit for Memory Address Mux
-- This control unit decides which address to use for memory access
-- Part of the unified memory system (Harvard architecture with shared memory)
-- Selection options:
--   "000" - PC Register (instruction fetch)
--   "001" - SP Register (stack operations)
--   "010" - SP + 1 (some operations need this before updating SP)
--   "011" - ALU (computed address)
--   "100" - ALU + 2 (offset addressing)

entity Memory_Address_Mux_Control is
    Port (
        -- Input control signals (to be defined based on instruction decode)
        opcode : in STD_LOGIC_VECTOR(7 downto 0);
        mem_operation : in STD_LOGIC_VECTOR(1 downto 0);
        is_stack_op : in STD_LOGIC;
        -- Add other control signals as needed
        
        -- Output
        mem_addr_mux_sel : out STD_LOGIC_VECTOR(2 downto 0)
    );
end Memory_Address_Mux_Control;

architecture Behavioral of Memory_Address_Mux_Control is
begin
    -- TODO: Implement control logic
    -- For now, default to PC for instruction fetch
    process(opcode, mem_operation, is_stack_op)
    begin
        -- Placeholder logic - will be implemented later
        mem_addr_mux_sel <= "000";  -- Default: PC for instruction fetch
    end process;
end Behavioral;
