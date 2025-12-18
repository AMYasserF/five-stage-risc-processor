-- vhdl-linter-disable type-resolved
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- ALU Operand A Multiplexer
-- Selects source for ALU operand A based on forwarding logic
-- Options:
--   00: read_data1 from ID/EX pipeline register (normal path)
--   01: forwarded data from EX/MEM pipeline register
--   10: forwarded data from MEM/WB pipeline register

entity ALU_OperandA_Mux is
    Port (
        -- Input sources
        read_data1      : in  STD_LOGIC_VECTOR(31 downto 0);  -- From ID/EX register
        ex_mem_forward  : in  STD_LOGIC_VECTOR(31 downto 0);  -- Forward from EX/MEM
        mem_wb_forward  : in  STD_LOGIC_VECTOR(31 downto 0);  -- Forward from MEM/WB
        
        -- Selection signal
        select_sig      : in  STD_LOGIC_VECTOR(1 downto 0);
        
        -- Output
        operand_a       : out STD_LOGIC_VECTOR(31 downto 0)
    );
end ALU_OperandA_Mux;

architecture Behavioral of ALU_OperandA_Mux is
begin
    
    process(read_data1, ex_mem_forward, mem_wb_forward, select_sig)
    begin
        case select_sig is
            when "00" =>
                operand_a <= read_data1;      -- Normal path from register file
            when "01" =>
                operand_a <= ex_mem_forward;  -- Forward from EX/MEM
            when "10" =>
                operand_a <= mem_wb_forward;  -- Forward from MEM/WB
            when others =>
                operand_a <= read_data1;      -- Default to normal path
        end case;
    end process;
    
end Behavioral;
