library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Stack Pointer Register
-- Initializes to 2^18 - 1 (262143) on reset
-- 32-bit register for stack pointer management

entity SP_Register is
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        enable : in STD_LOGIC;
        sp_in : in STD_LOGIC_VECTOR(31 downto 0);
        sp_out : out STD_LOGIC_VECTOR(31 downto 0)
    );
end SP_Register;

architecture Behavioral of SP_Register is
    -- Initialize to 2^18 - 1 = 262143 = 0x0003FFFF
    constant SP_RESET_VALUE : STD_LOGIC_VECTOR(31 downto 0) := X"0003FFFF";
    signal sp_internal : STD_LOGIC_VECTOR(31 downto 0) := SP_RESET_VALUE;
begin
    
    process(clk, rst)
    begin
        if rst = '1' then
            sp_internal <= SP_RESET_VALUE;
        elsif rising_edge(clk) then
            if enable = '1' then
                sp_internal <= sp_in;
            end if;
        end if;
    end process;
    
    sp_out <= sp_internal;
    
end Behavioral;
