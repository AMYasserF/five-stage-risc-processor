LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- ALU Operand B Multiplexer
-- Selects source for ALU operand B based on forwarding logic and immediate flag
-- Options:
--   00: read_data2 from ID/EX pipeline register (normal path)
--   01: forwarded data from EX/MEM pipeline register
--   10: forwarded data from MEM/WB pipeline register
--   11: immediate value from IF/ID pipeline register

entity ALU_OperandB_Mux is
    Port (
        -- Input sources
        read_data2      : in  STD_LOGIC_VECTOR(31 downto 0);  -- From ID/EX register
        ex_mem_forward  : in  STD_LOGIC_VECTOR(31 downto 0);  -- Forward from EX/MEM
        mem_wb_forward  : in  STD_LOGIC_VECTOR(31 downto 0);  -- Forward from MEM/WB
        immediate       : in  STD_LOGIC_VECTOR(31 downto 0);  -- Immediate from IF/ID
        
        -- Selection signal
        select_sig      : in  STD_LOGIC_VECTOR(1 downto 0);
        
        -- Output
        operand_b       : out STD_LOGIC_VECTOR(31 downto 0)
    );
end ALU_OperandB_Mux;

architecture Behavioral of ALU_OperandB_Mux is
begin
    
    process(read_data2, ex_mem_forward, mem_wb_forward, immediate, select_sig)
    begin
        case select_sig is
            when "00" =>
                operand_b <= read_data2;      -- Normal path from register file
            when "01" =>
                operand_b <= ex_mem_forward;  -- Forward from EX/MEM
            when "10" =>
                operand_b <= mem_wb_forward;  -- Forward from MEM/WB
            when "11" =>
                operand_b <= immediate;       -- Immediate value
            when others =>
                operand_b <= read_data2;      -- Default to normal path
        end case;
    end process;
    
end Behavioral;
