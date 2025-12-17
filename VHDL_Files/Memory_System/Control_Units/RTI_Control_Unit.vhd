library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Return from Interrupt Control Unit (FSM)
-- Manages multi-cycle RTI instruction execution
--
-- RTI Instruction Sequence:
-- Cycle 1: CCR ? M[SP] (restore flags)
--          SP ? SP + 1
-- Cycle 2: PC ? M[SP] (restore return address)
--          SP ? SP + 1
--
-- States:
-- IDLE: Waiting for RTI instruction
-- RESTORE_CCR: Load CCR from stack
-- RESTORE_PC: Load PC from stack

entity RTI_Control_Unit is
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        is_rti : in STD_LOGIC;              -- RTI instruction active
        
        -- Outputs to control memory operations
        rti_sp_operation : out STD_LOGIC;   -- SP operation (increment)
        rti_mem_operation : out STD_LOGIC;  -- Use SP + 1 for memory address
        rti_load_ccr : out STD_LOGIC;       -- Load CCR from memory
        rti_load_pc : out STD_LOGIC;        -- Load PC from memory
        rti_mem_read : out STD_LOGIC;       -- Memory read enable
        rti_active : out STD_LOGIC          -- RTI operation in progress
    );
end RTI_Control_Unit;

architecture Behavioral of RTI_Control_Unit is
    
    type state_type is (IDLE, RESTORE_CCR, RESTORE_PC);
    signal current_state, next_state : state_type;
    
begin
    
    -- State register
    process(clk, rst)
    begin
        if rst = '1' then
            current_state <= IDLE;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;
    
    -- Next state logic
    process(current_state, is_rti)
    begin
        case current_state is
            when IDLE =>
                if is_rti = '1' then
                    next_state <= RESTORE_CCR;
                else
                    next_state <= IDLE;
                end if;
                
            when RESTORE_CCR =>
                next_state <= RESTORE_PC;
                
            when RESTORE_PC =>
                next_state <= IDLE;
                
            when others =>
                next_state <= IDLE;
        end case;
    end process;
    
    -- Output logic
    process(current_state)
    begin
        -- Default values
        rti_sp_operation <= '0';
        rti_mem_operation <= '0';
        rti_load_ccr <= '0';
        rti_load_pc <= '0';
        rti_mem_read <= '0';
        rti_active <= '0';
        
        case current_state is
            when IDLE =>
                -- No operation
                null;
                
            when RESTORE_CCR =>
                -- CCR ? M[SP], SP ? SP + 1
                rti_mem_operation <= '1';   -- Use SP + 1 for address
                rti_load_ccr <= '1';        -- Load CCR from memory
                rti_sp_operation <= '1';    -- SP increment
                rti_mem_read <= '1';        -- Memory read
                rti_active <= '1';
                
            when RESTORE_PC =>
                -- PC ? M[SP], SP ? SP + 1
                rti_mem_operation <= '1';   -- Use SP + 1 for address
                rti_load_pc <= '1';         -- Load PC from memory
                rti_sp_operation <= '1';    -- SP increment
                rti_mem_read <= '1';        -- Memory read
                rti_active <= '1';
                
            when others =>
                null;
        end case;
    end process;
    
end Behavioral;
