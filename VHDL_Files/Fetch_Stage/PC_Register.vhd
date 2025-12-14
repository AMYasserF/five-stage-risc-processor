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
    signal pc_reg : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');  -- Initialize to 0
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if enable = '1' then
                pc_reg <= pc_in;
            end if;
        end if;
    end process;
    
    -- Output PC value, or 0 during reset (so memory reads from address 0)
    pc_out <= (others => '0') when rst = '1' else pc_reg;
    
end Behavioral;
