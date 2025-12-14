library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Control Unit for Memory Address Mux
-- This control unit decides which address to use for memory access
-- Part of the unified memory system (Harvard architecture with shared memory)
-- Selection options:
--   "000" - PC Register (instruction fetch)
--   "001" - SP Register (stack operations)
--   "010" - SP + 1 (some operations need this before updating SP)
--   "011" - ALU (computed address)
--   "100" - ALU + 2 (offset addressing)

entity Memory_Address_Mux_Control is
    Port (
        -- Control signals from different stages/CUs
        is_fetch : in STD_LOGIC;                    -- Fetch stage needs memory (instruction fetch)
        int_mem_access : in STD_LOGIC;              -- INT_CU needs memory access (read vector or save PC)
        ret_mem_access : in STD_LOGIC;              -- RET_CU needs memory access (read return address)
        mem_stage_access : in STD_LOGIC;            -- Memory stage needs access (load/store)
        
        -- Type of address for memory stage
        mem_use_sp : in STD_LOGIC;                  -- Use SP address
        mem_use_sp_plus_1 : in STD_LOGIC;           -- Use SP + 1
        mem_use_alu : in STD_LOGIC;                 -- Use ALU result
        mem_use_alu_plus_2 : in STD_LOGIC;          -- Use ALU + 2
        
        -- Output
        mem_addr_mux_sel : out STD_LOGIC_VECTOR(2 downto 0)
    );
end Memory_Address_Mux_Control;

architecture Behavioral of Memory_Address_Mux_Control is
begin
    process(is_fetch, int_mem_access, ret_mem_access, mem_stage_access,
            mem_use_sp, mem_use_sp_plus_1, mem_use_alu, mem_use_alu_plus_2)
    begin
        -- Priority order:
        -- 1. INT/RET operations (highest priority - they use SP or specific addresses)
        -- 2. Memory stage operations (load/store)
        -- 3. Fetch stage (instruction fetch using PC) - default
        
        if int_mem_access = '1' or ret_mem_access = '1' then
            -- INT or RET needs SP address
            mem_addr_mux_sel <= "001";  -- SP address
            
        elsif mem_stage_access = '1' then
            -- Memory stage access - determine which address
            if mem_use_sp = '1' then
                mem_addr_mux_sel <= "001";          -- SP
            elsif mem_use_sp_plus_1 = '1' then
                mem_addr_mux_sel <= "010";          -- SP + 1
            elsif mem_use_alu = '1' then
                mem_addr_mux_sel <= "011";          -- ALU
            elsif mem_use_alu_plus_2 = '1' then
                mem_addr_mux_sel <= "100";          -- ALU + 2
            else
                mem_addr_mux_sel <= "011";          -- Default to ALU
            end if;
            
        else
            -- Default: Fetch stage uses PC for instruction fetch
            mem_addr_mux_sel <= "000";  -- PC address
        end if;
    end process;
end Behavioral;
