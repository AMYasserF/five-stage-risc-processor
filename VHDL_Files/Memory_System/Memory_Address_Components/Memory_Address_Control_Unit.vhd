library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Memory Address Control Unit
-- Generates selector signal for Memory Address Mux
-- Priority-based selection of memory address source
--
-- Priority (highest to lowest):
-- 1. Reset (rst = '1') ? 000 (address 0 for PC initialization)
-- 2. INT operation ? 001 (ALU + 2 for interrupt vector)
-- 3. PUSH operation ? 011 (SP for stack push)
-- 4. CALL operation ? 011 (SP for call stack)
-- 5. POP operation ? 100 (SP + 1 for stack pop)
-- 6. RET operation ? 100 (SP + 1 for return)
-- 7. RTI operation ? 100 (SP + 1 for return from interrupt)
-- 8. ALU address ? 101 (calculated address)
-- 9. Default (PC) ? 010 (instruction fetch)

entity Memory_Address_Control_Unit is
    Port (
        rst : in STD_LOGIC;                    -- Reset signal
        int_mem_operation : in STD_LOGIC;      -- INT control unit signal
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
    
    process(rst, int_mem_operation, is_push, is_call, is_pop, 
            is_ret, rti_mem_operation, alu_address_enable)
    begin
        -- Priority-based selection
        if rst = '1' then
            -- Reset: address 0 for PC initialization
            mem_addr_mux_sel <= "000";
        elsif int_mem_operation = '1' then
            -- INT: ALU + 2 for interrupt vector
            mem_addr_mux_sel <= "001";
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
