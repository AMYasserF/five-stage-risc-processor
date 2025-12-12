library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity IF_ID_Register is
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        enable : in STD_LOGIC;
        flush : in STD_LOGIC;
        -- Inputs
        instruction_in : in STD_LOGIC_VECTOR(31 downto 0);
        pc_plus_1_in : in STD_LOGIC_VECTOR(31 downto 0);
        -- Outputs
        instruction_out : out STD_LOGIC_VECTOR(31 downto 0);
        pc_plus_1_out : out STD_LOGIC_VECTOR(31 downto 0)
    );
end IF_ID_Register;

architecture Behavioral of IF_ID_Register is
begin
    process(clk, rst)
    begin
        if rst = '1' then
            instruction_out <= (others => '0');
            pc_plus_1_out <= (others => '0');
        elsif rising_edge(clk) then
            if flush = '1' then
                instruction_out <= (others => '0');
                pc_plus_1_out <= (others => '0');
            elsif enable = '1' then
                instruction_out <= instruction_in;
                pc_plus_1_out <= pc_plus_1_in;
            end if;
        end if;
    end process;
end Behavioral;
