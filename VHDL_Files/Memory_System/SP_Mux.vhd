library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SP_Mux is
    Port (
        sp_plus_1 : in STD_LOGIC_VECTOR(31 downto 0);           -- SP + 1
        sp_minus_1 : in STD_LOGIC_VECTOR(31 downto 0);          -- SP - 1
        sp_init : in STD_LOGIC_VECTOR(31 downto 0);             -- 2^18 - 1 for initialization
        sel : in STD_LOGIC_VECTOR(1 downto 0);                  -- Control signal
        sp_out : out STD_LOGIC_VECTOR(31 downto 0)
    );
end SP_Mux;

architecture Behavioral of SP_Mux is
begin
    process(sp_plus_1, sp_minus_1, sp_init, sel)
    begin
        case sel is
            when "00" => sp_out <= sp_plus_1;           -- Increment SP
            when "01" => sp_out <= sp_minus_1;          -- Decrement SP
            when "10" => sp_out <= sp_init;             -- Initialize SP
            when others => sp_out <= sp_plus_1;
        end case;
    end process;
end Behavioral;
