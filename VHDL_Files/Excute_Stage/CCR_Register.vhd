LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity CCR_Register is
    Port (
        clk       : in  STD_LOGIC;
        rst       : in  STD_LOGIC;
        wen       : in  STD_LOGIC;                     -- Write Enable
        
        -- 32-bit Input from Mux
        D_in      : in  STD_LOGIC_VECTOR(31 downto 0); 
        
        -- 32-bit Output (feedback to Mux or to Memory/Stack)
        Q_out     : out STD_LOGIC_VECTOR(31 downto 0);
        
        -- Individual Flag Outputs (Extracted from first 3 bits)
        Z_flag    : out STD_LOGIC; -- Bit 0
        C_flag    : out STD_LOGIC; -- Bit 1
        N_flag    : out STD_LOGIC  -- Bit 2
    );
end CCR_Register;

architecture Behavioral of CCR_Register is
    signal internal_reg : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
begin

    process(clk, rst)
    begin
        if rst = '1' then
            internal_reg <= (others => '0');
        elsif rising_edge(clk) then
            if wen = '1' then
                internal_reg <= D_in;
            end if;
        end if;
    end process;

    -- Assign full 32-bit output
    Q_out <= internal_reg;

    -- Extract specific flags from the first 3 bits
    -- Mapping: Bit 0 = Zero, Bit 1 = Carry, Bit 2 = Negative
    Z_flag <= internal_reg(0);
    C_flag <= internal_reg(1);
    N_flag <= internal_reg(2);

end Behavioral;