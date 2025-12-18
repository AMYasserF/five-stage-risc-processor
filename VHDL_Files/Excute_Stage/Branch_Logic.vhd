-- vhdl-linter-disable type-resolved
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Branch Logic Unit
-- Determines if conditional branches should be taken based on CCR flags
-- branchZ: Branch if Zero flag is set
-- branchC: Branch if Carry flag is set
-- branchN: Branch if Negative flag is set

entity Branch_Logic is
    Port (
        -- Branch control signals from decode stage
        branchZ : in  STD_LOGIC;
        branchC : in  STD_LOGIC;
        branchN : in  STD_LOGIC;
        
        -- Condition Code Register flags
        ccrZ    : in  STD_LOGIC;  -- Zero flag
        ccrC    : in  STD_LOGIC;  -- Carry flag
        ccrN    : in  STD_LOGIC;  -- Negative flag
        
        -- Conditional branch outputs
        conditional_branchZ : out STD_LOGIC;  -- Branch on Zero taken
        conditional_branchC : out STD_LOGIC;  -- Branch on Carry taken
        conditional_branchN : out STD_LOGIC   -- Branch on Negative taken
    );
end Branch_Logic;

architecture Behavioral of Branch_Logic is
begin
    
    -- Branch on Zero: taken if branchZ=1 AND ccrZ=1
    conditional_branchZ <= branchZ and ccrZ;
    
    -- Branch on Carry: taken if branchC=1 AND ccrC=1
    conditional_branchC <= branchC and ccrC;
    
    -- Branch on Negative: taken if branchN=1 AND ccrN=1
    conditional_branchN <= branchN and ccrN;
    
end Behavioral;
