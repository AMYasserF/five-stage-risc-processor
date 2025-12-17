library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- ALU Plus 2 Adder
-- Adds 2 to ALU result for INT index instruction
-- Used to calculate M[index + 2] for interrupt vector

entity ALU_Plus_2_Adder is
    Port (
        alu_result : in STD_LOGIC_VECTOR(31 downto 0);
        alu_plus_2 : out STD_LOGIC_VECTOR(31 downto 0)
    );
end ALU_Plus_2_Adder;

architecture Behavioral of ALU_Plus_2_Adder is
begin
    alu_plus_2 <= std_logic_vector(unsigned(alu_result) + 2);
end Behavioral;
