library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PC_Register is
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        enable : in STD_LOGIC;
        pc_in : in STD_LOGIC_VECTOR(31 downto 0);
        pc_out : out STD_LOGIC_VECTOR(31 downto 0)
    );
end PC_Register;

architecture Behavioral of PC_Register is
begin
    process(clk, rst)
    begin
        if rst = '1' then
            pc_out <= (others => '0');
        elsif rising_edge(clk) then
            if enable = '1' then
                pc_out <= pc_in;
            end if;
        end if;
    end process;
end Behavioral;
