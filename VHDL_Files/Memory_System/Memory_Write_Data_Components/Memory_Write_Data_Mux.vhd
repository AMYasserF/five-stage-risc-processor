library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Memory Write Data Multiplexer
-- Selects the data to be written to memory based on operation type
-- 
-- Selection encoding (2 bits):
-- 00: call_return_addr for CALL (from current ID/EX PC+1), PC+1 for INT
-- 01: Rsrc2 - for POP, STD operations  
-- 10: CCR - for INT operation (saving processor state)
-- 11: ALU Result - for PUSH operation (register value passed through ALU with PassA)

entity Memory_Write_Data_Mux is
    Port (
        pc_data : in STD_LOGIC_VECTOR(31 downto 0);           -- PC+1 from EX/MEM pipeline (for INT)
        call_return_addr : in STD_LOGIC_VECTOR(31 downto 0);  -- Return address for CALL (from ID/EX PC+1)
        rsrc2_data : in STD_LOGIC_VECTOR(31 downto 0);        -- 01: Rsrc2
        ccr_data : in STD_LOGIC_VECTOR(31 downto 0);          -- 10: CCR register
        alu_result : in STD_LOGIC_VECTOR(31 downto 0);        -- 11: ALU Result (for PUSH)
        is_call : in STD_LOGIC;                               -- CALL instruction flag
        sel : in STD_LOGIC_VECTOR(1 downto 0);
        mem_write_data : out STD_LOGIC_VECTOR(31 downto 0)
    );
end Memory_Write_Data_Mux;

architecture Behavioral of Memory_Write_Data_Mux is
begin
    
    process(pc_data, call_return_addr, rsrc2_data, ccr_data, alu_result, is_call, sel)
    begin
        case sel is
            when "00" => 
                -- For CALL, use call_return_addr (current ID/EX PC+1); for INT, use pc_data
                if is_call = '1' then
                    mem_write_data <= call_return_addr;
                else
                    mem_write_data <= pc_data;
                end if;
            when "01" => mem_write_data <= rsrc2_data; -- Rsrc2
            when "10" => mem_write_data <= ccr_data;   -- CCR
            when "11" => mem_write_data <= alu_result; -- ALU Result (for PUSH)
            when others => mem_write_data <= (others => '0');
        end case;
    end process;
    
end Behavioral;
