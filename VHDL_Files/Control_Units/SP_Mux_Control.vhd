library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Control Unit Template for SP Mux
-- This control unit decides which input to select for the SP Mux
-- Selection options:
--   "00" - SP + 1 (push operation)
--   "01" - SP - 1 (pop operation)
--   "10" - 2^18 - 1 (initialization)

entity SP_Mux_Control is
    Port (
        -- Input control signals (to be defined based on instruction decode)
        opcode : in STD_LOGIC_VECTOR(7 downto 0);
        push_signal : in STD_LOGIC;
        pop_signal : in STD_LOGIC;
        reset_signal : in STD_LOGIC;
        -- Add other control signals as needed
        
        -- Output
        sp_mux_sel : out STD_LOGIC_VECTOR(1 downto 0)
    );
end SP_Mux_Control;

architecture Behavioral of SP_Mux_Control is
begin
    -- TODO: Implement control logic
    -- For now, maintain SP value
    process(opcode, push_signal, pop_signal, reset_signal)
    begin
        -- Placeholder logic - will be implemented later
        if reset_signal = '1' then
            sp_mux_sel <= "10";  -- Initialize
        else
            sp_mux_sel <= "00";  -- Default: maintain or increment
        end if;
    end process;
end Behavioral;
