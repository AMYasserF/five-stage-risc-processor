library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Interrupt Control Unit (FSM)
-- Manages multi-cycle INT instruction execution
--
-- INT Instruction Sequence:
-- Cycle 1: M[SP] ? PC + 1 (store return address)
--          SP ? SP - 1
-- Cycle 2: M[SP] ? CCR (store flags)
--          SP ? SP - 1
-- Cycle 3: PC ? M[index + 2] (load interrupt handler address)
--
-- States:
-- IDLE: Waiting for INT instruction
-- STORE_PC: Store PC + 1 to stack
-- STORE_CCR: Store CCR to stack
-- LOAD_VECTOR: Load interrupt vector from M[index + 2]

entity INT_Control_Unit is
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        is_int : in STD_LOGIC;              -- INT instruction active
        
        -- Outputs to control memory operations
        int_mem_operation : out STD_LOGIC;  -- Memory address = ALU + 2 (for vector)
        int_sp_operation : out STD_LOGIC;   -- SP operation (decrement)
        int_write_pc : out STD_LOGIC;       -- Write PC to memory
        int_write_ccr : out STD_LOGIC;      -- Write CCR to memory
        int_load_pc : out STD_LOGIC;        -- Load PC from memory
        int_mem_write : out STD_LOGIC;      -- Memory write enable
        int_mem_read : out STD_LOGIC;       -- Memory read enable
        int_active : out STD_LOGIC          -- INT operation in progress
    );
end INT_Control_Unit;

architecture Behavioral of INT_Control_Unit is
    
    type state_type is (IDLE, STORE_PC, STORE_CCR, LOAD_VECTOR);
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
    process(current_state, is_int)
    begin
        case current_state is
            when IDLE =>
                if is_int = '1' then
                    next_state <= STORE_PC;
                else
                    next_state <= IDLE;
                end if;
                
            when STORE_PC =>
                next_state <= STORE_CCR;
                
            when STORE_CCR =>
                next_state <= LOAD_VECTOR;
                
            when LOAD_VECTOR =>
                next_state <= IDLE;
                
            when others =>
                next_state <= IDLE;
        end case;
    end process;
    
    -- Output logic
    process(current_state)
    begin
        -- Default values
        int_mem_operation <= '0';
        int_sp_operation <= '0';
        int_write_pc <= '0';
        int_write_ccr <= '0';
        int_load_pc <= '0';
        int_mem_write <= '0';
        int_mem_read <= '0';
        int_active <= '0';
        
        case current_state is
            when IDLE =>
                -- No operation
                null;
                
            when STORE_PC =>
                -- M[SP] ? PC + 1, SP ? SP - 1
                int_write_pc <= '1';        -- Write PC data
                int_sp_operation <= '1';    -- SP decrement
                int_mem_write <= '1';       -- Memory write
                int_active <= '1';
                
            when STORE_CCR =>
                -- M[SP] ? CCR, SP ? SP - 1
                int_write_ccr <= '1';       -- Write CCR data
                int_sp_operation <= '1';    -- SP decrement
                int_mem_write <= '1';       -- Memory write
                int_active <= '1';
                
            when LOAD_VECTOR =>
                -- PC ? M[index + 2]
                int_mem_operation <= '1';   -- Address = ALU + 2
                int_load_pc <= '1';         -- Load PC from memory
                int_mem_read <= '1';        -- Memory read
                int_active <= '1';
                
            when others =>
                null;
        end case;
    end process;
    
end Behavioral;
