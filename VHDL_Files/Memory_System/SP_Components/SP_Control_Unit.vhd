library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Stack Pointer Control Unit
-- Controls SP mux selector based on operation type
-- 
-- SP decrements (sel = '1') for:
--   - CALL instruction
--   - PUSH instruction
--   - INT (interrupt) operation
--
-- SP increments (sel = '0') for:
--   - POP instruction
--   - RET instruction
--   - RTI (return from interrupt) operation

entity SP_Control_Unit is
    Port (
        is_call : in STD_LOGIC;      -- CALL instruction
        is_push : in STD_LOGIC;      -- PUSH instruction
        is_pop : in STD_LOGIC;       -- POP instruction
        is_ret : in STD_LOGIC;       -- RET instruction
        int_sp_operation : in STD_LOGIC;  -- INT operation (from interrupt control unit)
        rti_sp_operation : in STD_LOGIC;  -- RTI operation (from RTI control unit)
        rst : in STD_LOGIC;          -- Reset signal
        
        -- Output
        sp_mux_sel : out STD_LOGIC;  -- 0: SP+1, 1: SP-1
        sp_enable : out STD_LOGIC    -- Enable SP register update
    );
end SP_Control_Unit;

architecture Behavioral of SP_Control_Unit is
begin
    
    process(is_call, is_push, is_pop, is_ret, int_sp_operation, rti_sp_operation, rst)
    begin
        if rst = '1' then
            sp_mux_sel <= '0';
            sp_enable <= '0';
        else
            -- Determine if any SP-modifying operation is active
            if is_call = '1' or is_push = '1' or int_sp_operation = '1' then
                -- SP - 1 operations
                sp_mux_sel <= '1';
                sp_enable <= '1';
            elsif is_pop = '1' or is_ret = '1' or rti_sp_operation = '1' then
                -- SP + 1 operations
                sp_mux_sel <= '0';
                sp_enable <= '1';
            else
                -- No SP operation
                sp_mux_sel <= '0';
                sp_enable <= '0';
            end if;
        end if;
    end process;
    
end Behavioral;
