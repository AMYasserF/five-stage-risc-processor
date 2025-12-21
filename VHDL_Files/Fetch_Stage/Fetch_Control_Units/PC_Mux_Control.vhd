library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Selection options:
--   "00" - PC + 1 (normal increment)
--   "01" - Immediate from IF/ID register (conditional jump when condition met)
--   "10" - Memory data (reset/interrupt/return/unconditional jump)
--   "11" - ALU result from EX/MEM (CALL instruction)

entity PC_Mux_Control is
    Port (
      
        int_load_pc : in STD_LOGIC;          
        rti_load_pc : in STD_LOGIC;
                
        -- Control signals from main control unit
        is_ret : in std_logic; 
        is_call : in STD_LOGIC;               -- CALL instruction
        is_conditional_jump : in STD_LOGIC;   -- Conditional jump instruction
        is_unconditional_jump : in STD_LOGIC; -- Unconditional jump instruction
        
        -- Reset (system-level signal)
        rst : in STD_LOGIC;
        
        -- Output
        pc_mux_sel : out STD_LOGIC_VECTOR(1 downto 0)
    );
end PC_Mux_Control;

architecture Behavioral of PC_Mux_Control is
begin
    process(int_load_pc, rti_load_pc, is_ret, is_call, 
            is_conditional_jump, is_unconditional_jump, rst)
    begin
       
        if rst = '1' then
            pc_mux_sel <= "10";  -- Reset: PC ← M[0] from memory
        elsif int_load_pc = '1' then
            pc_mux_sel <= "10";  -- INT: PC ← M[int_index + 2] from memory
        elsif rti_load_pc = '1' then
            pc_mux_sel <= "10";  -- RTI: PC ← M[SP] from memory (restored PC)
        elsif is_ret= '1' then
            pc_mux_sel <= "10";  -- RET: PC ← M[SP] from memory
        elsif is_call = '1' then
            pc_mux_sel <= "11";  -- CALL: PC ← ALU result (from EX/MEM)
        elsif is_conditional_jump = '1' then
            pc_mux_sel <= "01";  -- Conditional jump: PC ← if/id.immediate
        elsif is_unconditional_jump = '1' then
            pc_mux_sel <= "10";  -- Unconditional jump: PC ← memory output
        else
            pc_mux_sel <= "00";  -- Normal: PC ← PC + 1
        end if;
    end process;
end Behavioral;
