library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PC_Adder is
    Port (
        pc_in : in STD_LOGIC_VECTOR(31 downto 0);
        pc_plus_1 : out STD_LOGIC_VECTOR(31 downto 0)
    );
end PC_Adder;

architecture Behavioral of PC_Adder is
begin
    pc_plus_1 <= std_logic_vector(unsigned(pc_in) + 1);
end Behavioral;
