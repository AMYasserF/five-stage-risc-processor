library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Memory Address Multiplexer
-- Selects the address to be sent to memory based on operation type
-- 
-- Selection encoding (3 bits):
-- 000: Reset address (0) - for PC initialization from M[0]
-- 001: INT address (alu_plus_2) - for interrupt vector M[index + 2]
-- 010: PC output - for instruction fetch
-- 011: SP output - for PUSH, CALL operations
-- 100: SP + 1 - for POP, RET, RTI operations
-- 101: ALU result - for calculated addresses (LDD, STD)

entity Memory_Address_Mux is
    Port (
        reset_address : in STD_LOGIC_VECTOR(31 downto 0);     -- 000: Always 0
        int_address : in STD_LOGIC_VECTOR(31 downto 0);       -- 001: ALU + 2
        pc_address : in STD_LOGIC_VECTOR(31 downto 0);        -- 010: PC
        sp_address : in STD_LOGIC_VECTOR(31 downto 0);        -- 011: SP
        sp_plus_1_address : in STD_LOGIC_VECTOR(31 downto 0); -- 100: SP + 1
        alu_address : in STD_LOGIC_VECTOR(31 downto 0);       -- 101: ALU result
        sel : in STD_LOGIC_VECTOR(2 downto 0);
        mem_address : out STD_LOGIC_VECTOR(31 downto 0)
    );
end Memory_Address_Mux;

architecture Behavioral of Memory_Address_Mux is
begin
    
    process(reset_address, int_address, pc_address, sp_address, 
            sp_plus_1_address, alu_address, sel)
    begin
        case sel is
            when "000" => mem_address <= reset_address;      -- Reset (0)
            when "001" => mem_address <= int_address;        -- ALU + 2 (INT)
            when "010" => mem_address <= pc_address;         -- PC
            when "011" => mem_address <= sp_address;         -- SP (PUSH, CALL)
            when "100" => mem_address <= sp_plus_1_address;  -- SP + 1 (POP, RET, RTI)
            when "101" => mem_address <= alu_address;        -- ALU result
            when others => mem_address <= (others => '0');
        end case;
    end process;
    
end Behavioral;
