library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PC_Mux is
    Port (
        pc_plus_1 : in STD_LOGIC_VECTOR(31 downto 0);           -- PC + 1
        pc_plus_1_ifid : in STD_LOGIC_VECTOR(31 downto 0);      -- PC + 1 from IF/ID register
        pc_from_memory : in STD_LOGIC_VECTOR(31 downto 0);      -- From Memory
        pc_from_alu : in STD_LOGIC_VECTOR(31 downto 0);         -- From ALU
        sel : in STD_LOGIC_VECTOR(1 downto 0);                  -- Control signal
        pc_out : out STD_LOGIC_VECTOR(31 downto 0)
    );
end PC_Mux;

architecture Behavioral of PC_Mux is
begin
    process(pc_plus_1, pc_plus_1_ifid, pc_from_memory, pc_from_alu, sel)
    begin
        case sel is
            when "00" => pc_out <= pc_plus_1;           -- Normal increment
            when "01" => pc_out <= pc_plus_1_ifid;      -- From IF/ID register
            when "10" => pc_out <= pc_from_memory;      -- From Memory
            when "11" => pc_out <= pc_from_alu;         -- From ALU
            when others => pc_out <= pc_plus_1;
        end case;
    end process;
end Behavioral;
