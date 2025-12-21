library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Interrupt Control Unit (Counter-based)
-- Manages multi-cycle INT instruction execution using a counter like SWAP
--
-- INT Instruction Sequence:
-- Counter 0: M[SP] ← PC + 1 (store return address), SP ← SP - 1
-- Counter 1: M[SP] ← CCR (store flags), SP ← SP - 1
-- Counter 2: PC ← M[index + 2] (load interrupt handler address)
--
-- int_counter values:
-- "00" = Cycle 0: STORE_PC
-- "01" = Cycle 1: STORE_CCR
-- "10" = Cycle 2: LOAD_VECTOR
-- "11" = Idle/Done
--
-- IMPORTANT: This unit latches PC+1 and CCR values when INT starts,
-- because the pipeline gets flushed after counter="00"

entity INT_Control_Unit is
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        is_int : in STD_LOGIC;              -- INT instruction active
        
        -- Input data to latch (must be valid when is_int first arrives)
        pc_plus_1_in : in STD_LOGIC_VECTOR(31 downto 0);  -- PC+1 to save
        ccr_in : in STD_LOGIC_VECTOR(31 downto 0);         -- CCR to save
        
        -- Outputs to control memory operations
        int_mem_operation : out STD_LOGIC;  -- Memory address = ALU + 2 (for vector)
        int_sp_operation : out STD_LOGIC;   -- SP operation (decrement)
        int_write_pc : out STD_LOGIC;       -- Write PC to memory
        int_write_ccr : out STD_LOGIC;      -- Write CCR to memory
        int_load_pc : out STD_LOGIC;        -- Load PC from memory
        int_mem_write : out STD_LOGIC;      -- Memory write enable
        int_mem_read : out STD_LOGIC;       -- Memory read enable
        int_active : out STD_LOGIC;         -- INT operation in progress
        int_counter : out STD_LOGIC_VECTOR(1 downto 0); -- Current counter: 00=STORE_PC, 01=STORE_CCR, 10=LOAD_VECTOR, 11=IDLE
        
        -- Latched data outputs
        latched_pc_plus_1 : out STD_LOGIC_VECTOR(31 downto 0);  -- Latched PC+1
        latched_ccr : out STD_LOGIC_VECTOR(31 downto 0)          -- Latched CCR
    );
end INT_Control_Unit;

architecture Behavioral of INT_Control_Unit is
    signal counter_reg : unsigned(1 downto 0) := "11";  -- Start at IDLE
    
    -- Latched values - stored when INT first arrives (before pipeline flush)
    signal pc_plus_1_latched : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal ccr_latched : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
begin
    
    -- Counter register process
    -- IMPORTANT: Once started, counter must complete the full sequence
    -- independently of is_int signal (which gets flushed by hazard unit)
    process(clk, rst)
    begin
        if rst = '1' then
            counter_reg <= "11";  -- IDLE
            pc_plus_1_latched <= (others => '0');
            ccr_latched <= (others => '0');
        elsif rising_edge(clk) then
            if counter_reg = "11" then
                -- IDLE state: start sequence only when is_int is asserted
                if is_int = '1' then
                    counter_reg <= "00";  -- Start at STORE_PC
                    -- LATCH the PC+1 and CCR values NOW, before pipeline flushes!
                    pc_plus_1_latched <= pc_plus_1_in;
                    ccr_latched <= ccr_in;
                end if;
                -- Otherwise stay in IDLE
            else
                -- Active state (00, 01, 10): continue incrementing until done
                -- Do NOT depend on is_int here - it will be flushed!
                counter_reg <= counter_reg + 1;  -- 00->01->10->11(done)
            end if;
        end if;
    end process;
    
    -- Output latched values
    latched_pc_plus_1 <= pc_plus_1_latched;
    latched_ccr <= ccr_latched;
    
    -- Output counter value
    int_counter <= std_logic_vector(counter_reg);
    
    -- Output logic based on counter value (combinational)
    -- IMPORTANT: Output logic only depends on counter_reg, NOT on is_int
    -- This ensures outputs remain active even after is_int is flushed
    process(counter_reg)
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
        
        case counter_reg is
            when "00" =>
                -- Counter 0: M[SP] ← PC + 1, SP ← SP - 1
                int_write_pc <= '1';        -- Write PC data
                int_sp_operation <= '1';    -- SP decrement
                int_mem_write <= '1';       -- Memory write
                int_active <= '1';
                
            when "01" =>
                -- Counter 1: M[SP] ← CCR, SP ← SP - 1
                int_write_ccr <= '1';       -- Write CCR data
                int_sp_operation <= '1';    -- SP decrement
                int_mem_write <= '1';       -- Memory write
                int_active <= '1';
                
            when "10" =>
                -- Counter 2: PC ← M[index + 2]
                int_mem_operation <= '1';   -- Address = ALU + 2
                int_load_pc <= '1';         -- Load PC from memory
                int_mem_read <= '1';        -- Memory read
                int_active <= '1';
                
            when others =>
                -- "11" = IDLE, no operation
                null;
        end case;
    end process;
    
end Behavioral;
