LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- Register File with 8 general-purpose registers (R0-R7)
-- Based on assembler.py encoding:
-- Instruction format [31:0]:
--   [31:25] = Opcode (7 bits)
--   [24:22] = Rd (3 bits) - destination register
--   [21:19] = Rs1 (3 bits) - source register 1
--   [18:16] = Rs2 (3 bits) - source register 2
--   [15:0]  = Reserved/Unused

entity register_file is
    Port (
        clk           : in  STD_LOGIC;
        rst           : in  STD_LOGIC;
        hlt           : in  STD_LOGIC;                     -- Halt signal (freezes all writes)
        
        -- Read ports (from instruction decode)
        read_reg1     : in  STD_LOGIC_VECTOR(2 downto 0);  -- Rs1 address [21:19]
        read_reg2     : in  STD_LOGIC_VECTOR(2 downto 0);  -- Rs2 address [18:16]
        read_data1    : out STD_LOGIC_VECTOR(31 downto 0); -- Rs1 data
        read_data2    : out STD_LOGIC_VECTOR(31 downto 0); -- Rs2 data
        
        -- Write port (from writeback stage)
        write_enable  : in  STD_LOGIC;
        write_reg     : in  STD_LOGIC_VECTOR(2 downto 0);  -- Rd address [24:22]
        write_data    : in  STD_LOGIC_VECTOR(31 downto 0)  -- Data to write
    );
end register_file;

architecture Behavioral of register_file is
    -- 8 x 32-bit registers (R0 to R7)
    type reg_array is array (0 to 7) of STD_LOGIC_VECTOR(31 downto 0);
    signal registers : reg_array;
    
begin
    -- Read process (asynchronous read)
    read_data1 <= registers(to_integer(unsigned(read_reg1)));
    read_data2 <= registers(to_integer(unsigned(read_reg2)));
    
    -- Write process (synchronous write on rising edge)
    -- Halt signal freezes all register writes until reset
    process(clk, rst)
    begin
        if rst = '1' then
            -- Reset all registers to zero
            for i in 0 to 7 loop
                registers(i) <= (others => '0');
            end loop;
        elsif rising_edge(clk) then
            if hlt = '0' and write_enable = '1' then
                -- Write data to the specified register only if not halted
                registers(to_integer(unsigned(write_reg))) <= write_data;
            end if;
            -- When hlt = '1', freeze all registers (no writes occur)
        end if;
    end process;
    
end Behavioral;
