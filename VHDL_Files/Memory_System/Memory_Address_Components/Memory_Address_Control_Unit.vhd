library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Memory Address Control Unit
-- Generates selector signal for Memory Address Mux
-- Priority-based selection of memory address source
--
-- Priority (highest to lowest):
-- 1. Reset (rst = '1') → 000 (address 0 for PC initialization)
-- 2. INT vector load (int_mem_operation='1') → 001 (ALU + 2 for interrupt vector)
-- 3. INT write operations (int_write_pc or int_write_ccr) → 011 (SP for stack push)
-- 4. PUSH operation → 011 (SP for stack push)
-- 5. CALL operation → 011 (SP for call stack)
-- 6. POP operation → 100 (SP + 1 for stack pop)
-- 7. RET operation → 100 (SP + 1 for return)
-- 8. RTI operation → 100 (SP + 1 for return from interrupt)
-- 9. ALU address → 101 (calculated address)
-- 10. Default (PC) → 010 (instruction fetch)

entity Memory_Address_Control_Unit is
    Port (
        rst : in STD_LOGIC;                    -- Reset signal
        int_mem_operation : in STD_LOGIC;      -- INT: read vector from M[index+2]
        int_write_pc : in STD_LOGIC;           -- INT: writing PC to stack
        int_write_ccr : in STD_LOGIC;          -- INT: writing CCR to stack
        is_push : in STD_LOGIC;                -- PUSH instruction
        is_call : in STD_LOGIC;                -- CALL instruction
        is_pop : in STD_LOGIC;                 -- POP instruction
        is_ret : in STD_LOGIC;                 -- RET instruction
        rti_mem_operation : in STD_LOGIC;      -- RTI control unit signal
        alu_address_enable : in STD_LOGIC;     -- Use ALU address (LDD, STD)
        
        -- Output
        mem_addr_mux_sel : out STD_LOGIC_VECTOR(2 downto 0)  -- Mux selector
    );
end Memory_Address_Control_Unit;

architecture Behavioral of Memory_Address_Control_Unit is
begin
    
    process(rst, int_mem_operation, int_write_pc, int_write_ccr, is_push, is_call, is_pop, 
            is_ret, rti_mem_operation, alu_address_enable)
    begin
        -- Priority-based selection
        if rst = '1' then
            -- Reset: address 0 for PC initialization
            mem_addr_mux_sel <= "000";
        elsif int_mem_operation = '1' then
            -- INT: ALU + 2 for interrupt vector load
            mem_addr_mux_sel <= "001";
        elsif int_write_pc = '1' or int_write_ccr = '1' then
            -- INT: writing PC or CCR to stack - use SP
            mem_addr_mux_sel <= "011";
        elsif is_push = '1' or is_call = '1' then
            -- PUSH or CALL: use SP
            mem_addr_mux_sel <= "011";
        elsif is_pop = '1' or is_ret = '1' or rti_mem_operation = '1' then
            -- POP, RET, or RTI: use SP + 1
            mem_addr_mux_sel <= "100";
        elsif alu_address_enable = '1' then
            -- ALU address for calculated addresses (LDD, STD)
            mem_addr_mux_sel <= "101";
        else
            -- Default: PC for instruction fetch
            mem_addr_mux_sel <= "010";
        end if;
    end process;
    
end Behavioral;
