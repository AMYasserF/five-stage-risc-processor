library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Output_Port_Register is
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        enable : in STD_LOGIC;
        data_in : in STD_LOGIC_VECTOR(31 downto 0);
        data_out : out STD_LOGIC_VECTOR(31 downto 0)
    );
end Output_Port_Register;

architecture Behavioral of Output_Port_Register is
    signal output_reg : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
begin
    
    process(clk, rst)
    begin
        if rst = '1' then
            output_reg <= (others => '0');
        elsif rising_edge(clk) then
            if enable = '1' then
                output_reg <= data_in;
            end if;
        end if;
    end process;
    
    data_out <= output_reg;
    
end Behavioral;
