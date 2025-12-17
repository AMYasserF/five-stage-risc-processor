library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Memory Write Data Control Unit
-- Generates selector signal for Memory Write Data Mux
-- Controls what data is written to memory during various operations
--
-- Priority-based selection:
-- 1. INT operation with CCR phase ? 10 (CCR register)
-- 2. INT operation with PC phase ? 00 (PC from ID/EX)
-- 3. CALL instruction ? 00 (PC from ID/EX)
-- 4. PUSH instruction ? 01 (Rsrc2)
-- 5. POP instruction ? 01 (Rsrc2)
-- 6. ALU address (STD) ? 01 (Rsrc2)
-- 7. Default ? 01 (Rsrc2)
--
-- Note: INT control unit manages FSM to store PC first, then CCR
--       int_write_pc and int_write_ccr signals indicate which phase

entity Memory_Write_Data_Control_Unit is
    Port (
        is_call : in STD_LOGIC;              -- CALL instruction
        is_push : in STD_LOGIC;              -- PUSH instruction
        is_pop : in STD_LOGIC;               -- POP instruction
        alu_address_enable : in STD_LOGIC;   -- STD instruction (ALU address)
        int_write_pc : in STD_LOGIC;         -- INT: write PC phase
        int_write_ccr : in STD_LOGIC;        -- INT: write CCR phase
        
        -- Output
        mem_write_data_sel : out STD_LOGIC_VECTOR(1 downto 0)  -- Mux selector
    );
end Memory_Write_Data_Control_Unit;

architecture Behavioral of Memory_Write_Data_Control_Unit is
begin
    
    process(is_call, is_push, is_pop, alu_address_enable, 
            int_write_pc, int_write_ccr)
    begin
        -- Priority-based selection
        if int_write_ccr = '1' then
            -- INT: storing CCR register
            mem_write_data_sel <= "10";
        elsif int_write_pc = '1' or is_call = '1' then
            -- INT (PC phase) or CALL: store PC
            mem_write_data_sel <= "00";
        elsif is_push = '1' or is_pop = '1' or alu_address_enable = '1' then
            -- PUSH, POP, or STD: store Rsrc2
            mem_write_data_sel <= "01";
        else
            -- Default: Rsrc2
            mem_write_data_sel <= "01";
        end if;
    end process;
    
end Behavioral;
