library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

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
begin
    process(clk, rst)
    begin
        if rst = '1' then
            -- Initialize SP to 2^18 - 1 (262143)
            sp_out <= std_logic_vector(to_unsigned(262143, 32));
        elsif rising_edge(clk) then
            if enable = '1' then
                sp_out <= sp_in;
            end if;
        end if;
    end process;
end Behavioral;
