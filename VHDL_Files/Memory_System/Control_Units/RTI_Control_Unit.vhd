library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Return from Interrupt Control Unit (Counter-based like INT)
-- Manages multi-cycle RTI instruction execution
--
-- RTI Instruction Sequence (reverses INT):
-- INT stored: M[SP] ← PC+1, SP--, M[SP] ← CCR, SP--
-- Stack after INT: [SP+2]=PC+1, [SP+1]=CCR, [SP]=empty
--
-- RTI restores:
-- Counter 0: SP ← SP + 1, CCR ← M[SP]  (restore flags from SP+1)
-- Counter 1: SP ← SP + 1, PC ← M[SP]   (restore PC from SP+1)
--
-- rti_counter values:
-- "00" = Cycle 0: RESTORE_CCR
-- "01" = Cycle 1: RESTORE_PC
-- "11" = Idle/Done

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
        rti_active : out STD_LOGIC;         -- RTI operation in progress
        rti_counter : out STD_LOGIC_VECTOR(1 downto 0)  -- Counter output for hazard unit
    );
end RTI_Control_Unit;

architecture Behavioral of RTI_Control_Unit is
    signal counter_reg : unsigned(1 downto 0) := "11";  -- Start at IDLE
begin
    
    -- Counter register process
    -- IMPORTANT: Once started, counter must complete the full sequence
    -- independently of is_rti signal (which gets flushed by hazard unit)
    process(clk, rst)
    begin
        if rst = '1' then
            counter_reg <= "11";  -- IDLE
        elsif rising_edge(clk) then
            if counter_reg = "11" then
                -- IDLE state: start sequence only when is_rti is asserted
                if is_rti = '1' then
                    counter_reg <= "00";  -- Start at RESTORE_CCR
                end if;
            elsif counter_reg = "00" then
                -- RESTORE_CCR done, go to RESTORE_PC
                counter_reg <= "01";
            else
                -- RESTORE_PC done, go to IDLE
                counter_reg <= "11";
            end if;
        end if;
    end process;
    
    -- Output counter value
    rti_counter <= std_logic_vector(counter_reg);
    
    -- Output logic based on counter value (combinational)
    process(counter_reg)
    begin
        -- Default values
        rti_sp_operation <= '0';
        rti_mem_operation <= '0';
        rti_load_ccr <= '0';
        rti_load_pc <= '0';
        rti_mem_read <= '0';
        rti_active <= '0';
        
        case counter_reg is
            when "00" =>
                -- Counter 0: SP ← SP + 1, CCR ← M[SP+1]
                rti_sp_operation <= '1';    -- SP increment
                rti_mem_operation <= '1';   -- Use SP + 1 for address
                rti_load_ccr <= '1';        -- Load CCR from memory
                rti_mem_read <= '1';        -- Memory read
                rti_active <= '1';
                
            when "01" =>
                -- Counter 1: SP ← SP + 1, PC ← M[SP+1]
                rti_sp_operation <= '1';    -- SP increment
                rti_mem_operation <= '1';   -- Use SP + 1 for address
                rti_load_pc <= '1';         -- Load PC from memory
                rti_mem_read <= '1';        -- Memory read
                rti_active <= '1';
                
            when others =>
                -- "11" or "10" = IDLE, no operation
                null;
        end case;
    end process;
    
end Behavioral;
