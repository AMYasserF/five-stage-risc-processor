library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Stack Pointer Multiplexer
-- Selects next SP value based on operation
-- 0: SP + 1 (POP, RET, RTI)
-- 1: SP - 1 (PUSH, CALL, INT)

entity SP_Mux is
    Port (
        sp_plus_1 : in STD_LOGIC_VECTOR(31 downto 0);   -- SP + 1
        sp_minus_1 : in STD_LOGIC_VECTOR(31 downto 0);  -- SP - 1
        sel : in STD_LOGIC;                              -- 0: +1, 1: -1
        sp_next : out STD_LOGIC_VECTOR(31 downto 0)
    );
end SP_Mux;

architecture Behavioral of SP_Mux is
begin
    sp_next <= sp_plus_1 when sel = '0' else sp_minus_1;
end Behavioral;
