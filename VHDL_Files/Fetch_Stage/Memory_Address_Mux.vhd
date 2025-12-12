library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Memory_Address_Mux is
    Port (
        pc_addr : in STD_LOGIC_VECTOR(31 downto 0);             -- From PC Register
        sp_addr : in STD_LOGIC_VECTOR(31 downto 0);             -- From SP Register
        sp_plus_1_addr : in STD_LOGIC_VECTOR(31 downto 0);      -- SP + 1
        alu_addr : in STD_LOGIC_VECTOR(31 downto 0);            -- From ALU
        alu_plus_2_addr : in STD_LOGIC_VECTOR(31 downto 0);     -- ALU + 2
        sel : in STD_LOGIC_VECTOR(2 downto 0);                  -- Control signal
        mem_addr_out : out STD_LOGIC_VECTOR(31 downto 0)
    );
end Memory_Address_Mux;

architecture Behavioral of Memory_Address_Mux is
begin
    process(pc_addr, sp_addr, sp_plus_1_addr, alu_addr, alu_plus_2_addr, sel)
    begin
        case sel is
            when "000" => mem_addr_out <= pc_addr;          -- PC Register
            when "001" => mem_addr_out <= sp_addr;          -- SP Register
            when "010" => mem_addr_out <= sp_plus_1_addr;   -- SP + 1
            when "011" => mem_addr_out <= alu_addr;         -- ALU
            when "100" => mem_addr_out <= alu_plus_2_addr;  -- ALU + 2
            when others => mem_addr_out <= pc_addr;
        end case;
    end process;
end Behavioral;
