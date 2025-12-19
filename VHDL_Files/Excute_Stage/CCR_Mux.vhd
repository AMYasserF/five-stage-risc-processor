LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity CCR_Mux is
    Port (
        -- Selector from Control Unit
        -- 00: ALU Update (from ALU flags)
        -- 01: Branch Update (clear flag that caused branch)
        -- 10: Stack Restore (from RTI)
        selector            : in  STD_LOGIC_VECTOR(1 downto 0);
        
        -- Source 00: CCR from ALU Flags
        ccr_alu             : in  STD_LOGIC_VECTOR(31 downto 0);
        
        -- Source 01: CCR from Branch Logic (flags cleared after branch)
        ccr_branch          : in  STD_LOGIC_VECTOR(31 downto 0);
        
        -- Source 10: CCR from Stack (RTI restoration)
        ccr_stack           : in  STD_LOGIC_VECTOR(31 downto 0);
        
        -- Output to CCR Register
        mux_out             : out STD_LOGIC_VECTOR(31 downto 0)
    );
end CCR_Mux;

architecture DataFlow of CCR_Mux is
begin
    
    -- 3-way multiplexer
    -- 00: ALU flags -> CCR
    -- 01: Branch logic clears flag -> CCR
    -- 10: Stack restoration -> CCR
    mux_out <= ccr_alu when selector = "00" else
               ccr_branch when selector = "01" else
               ccr_stack;

end DataFlow;