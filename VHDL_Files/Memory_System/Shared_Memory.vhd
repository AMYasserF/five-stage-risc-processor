library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Shared Memory Module (Harvard Architecture with unified memory)
-- This memory is shared between instruction fetch and data access
-- It does not belong to any specific pipeline stage

entity Shared_Memory is
    Generic (
        ADDR_WIDTH : integer := 32;
        DATA_WIDTH : integer := 32;
        MEM_SIZE : integer := 1024  -- Number of words
    );
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        
        -- Memory interface signals
        address : in STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0);
        write_data : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
        write_enable : in STD_LOGIC;
        read_enable : in STD_LOGIC;
        read_data : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0)
    );
end Shared_Memory;

architecture Behavioral of Shared_Memory is
    -- Memory array
    type memory_array is array (0 to MEM_SIZE-1) of STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
    signal mem : memory_array := (others => (others => '0'));
    
begin
    -- Memory read/write process
    process(clk, rst)
    begin
        if rst = '1' then
            -- Optional: Initialize memory with program
            read_data <= (others => '0');
        elsif rising_edge(clk) then
            -- Write operation
            if write_enable = '1' then
                mem(to_integer(unsigned(address(9 downto 0)))) <= write_data;
            end if;
            
            -- Read operation
            if read_enable = '1' then
                read_data <= mem(to_integer(unsigned(address(9 downto 0))));
            end if;
        end if;
    end process;
    
end Behavioral;
