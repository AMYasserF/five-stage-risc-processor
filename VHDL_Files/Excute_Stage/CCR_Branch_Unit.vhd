LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- CCR Branch Unit
-- When a conditional branch is taken, this unit clears the corresponding flag
-- This prevents the same branch from being taken repeatedly

entity CCR_Branch_Unit is
    Port (
        -- Current CCR value
        current_ccr : in  STD_LOGIC_VECTOR(31 downto 0);
        
        -- Branch taken signals from Branch_Logic
        conditional_branchZ : in STD_LOGIC;  -- If 1, clear Z flag
        conditional_branchC : in STD_LOGIC;  -- If 1, clear C flag
        conditional_branchN : in STD_LOGIC;  -- If 1, clear N flag
        
        -- Output CCR with cleared flags
        ccr_out : out STD_LOGIC_VECTOR(31 downto 0)
    );
end CCR_Branch_Unit;

architecture Behavioral of CCR_Branch_Unit is
    signal ccr_modified : STD_LOGIC_VECTOR(31 downto 0);
begin
    
    process(current_ccr, conditional_branchZ, conditional_branchC, conditional_branchN)
    begin
        -- Start with current CCR value
        ccr_modified <= current_ccr;
        
        -- Clear Z flag (bit 0) if branch on Zero was taken
        if conditional_branchZ = '1' then
            ccr_modified(0) <= '0';
        end if;
        
        -- Clear C flag (bit 1) if branch on Carry was taken
        if conditional_branchC = '1' then
            ccr_modified(1) <= '0';
        end if;
        
        -- Clear N flag (bit 2) if branch on Negative was taken
        if conditional_branchN = '1' then
            ccr_modified(2) <= '0';
        end if;
        
    end process;
    
    -- Drive output
    ccr_out <= ccr_modified;
    
end Behavioral;
