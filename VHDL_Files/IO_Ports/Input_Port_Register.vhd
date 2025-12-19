library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Input Port Register: Always latches the external input
entity Input_Port_Register is
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        data_in : in STD_LOGIC_VECTOR(31 downto 0);
        data_out : out STD_LOGIC_VECTOR(31 downto 0)
    );
end Input_Port_Register;

architecture Behavioral of Input_Port_Register is
    signal input_reg : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
begin
    
    process(clk, rst)
    begin
        if rst = '1' then
            input_reg <= (others => '0');
        elsif rising_edge(clk) then
            -- Always latch the input (no enable needed)
            input_reg <= data_in;
        end if;
    end process;
    
    data_out <= input_reg;
    
end Behavioral;
