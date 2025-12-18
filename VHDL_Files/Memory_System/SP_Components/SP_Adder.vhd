library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- SP Adder
-- Generates both SP + 1 and SP - 1 for stack operations
-- SP + 1: Used for POP, RET, RTI operations
-- SP - 1: Used for PUSH, CALL, INT operations

entity SP_Adder is
    Port (
        sp_in : in STD_LOGIC_VECTOR(31 downto 0);
        sp_plus_1 : out STD_LOGIC_VECTOR(31 downto 0);
        sp_minus_1 : out STD_LOGIC_VECTOR(31 downto 0)
    );
end SP_Adder;

architecture Behavioral of SP_Adder is
begin
    sp_plus_1 <= std_logic_vector(unsigned(sp_in) + 1);
    sp_minus_1 <= std_logic_vector(unsigned(sp_in) - 1);
end Behavioral;
