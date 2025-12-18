library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Memory Write Data Multiplexer
-- Selects the data to be written to memory based on operation type
-- 
-- Selection encoding (2 bits):
-- 00: PC (from ID/EX register) - for CALL, INT operations
-- 01: Rsrc2 - for PUSH, POP, STD operations
-- 10: CCR - for INT operation (saving processor state)

entity Memory_Write_Data_Mux is
    Port (
        pc_data : in STD_LOGIC_VECTOR(31 downto 0);      -- 00: PC from ID/EX
        rsrc2_data : in STD_LOGIC_VECTOR(31 downto 0);   -- 01: Rsrc2
        ccr_data : in STD_LOGIC_VECTOR(31 downto 0);     -- 10: CCR register
        sel : in STD_LOGIC_VECTOR(1 downto 0);
        mem_write_data : out STD_LOGIC_VECTOR(31 downto 0)
    );
end Memory_Write_Data_Mux;

architecture Behavioral of Memory_Write_Data_Mux is
begin
    
    process(pc_data, rsrc2_data, ccr_data, sel)
    begin
        case sel is
            when "00" => mem_write_data <= pc_data;    -- PC
            when "01" => mem_write_data <= rsrc2_data; -- Rsrc2
            when "10" => mem_write_data <= ccr_data;   -- CCR
            when others => mem_write_data <= (others => '0');
        end case;
    end process;
    
end Behavioral;
