library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Memory Interface Controller
-- Manages access to shared memory from different pipeline stages
-- Handles address and data multiplexing

entity Memory_Interface is
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        
        -- Interface from Fetch Stage
        fetch_address : in STD_LOGIC_VECTOR(31 downto 0);
        fetch_read_enable : in STD_LOGIC;
        fetch_read_data : out STD_LOGIC_VECTOR(31 downto 0);
        
        -- Interface from Memory Stage (Load/Store operations)
        mem_address : in STD_LOGIC_VECTOR(31 downto 0);
        mem_write_data : in STD_LOGIC_VECTOR(31 downto 0);
        mem_write_enable : in STD_LOGIC;
        mem_read_enable : in STD_LOGIC;
        mem_read_data : out STD_LOGIC_VECTOR(31 downto 0);
        
        -- Control signals
        mem_stage_priority : in STD_LOGIC;  -- Give priority to memory stage over fetch
        
        -- Interface to Shared Memory
        memory_address : out STD_LOGIC_VECTOR(31 downto 0);
        memory_write_data : out STD_LOGIC_VECTOR(31 downto 0);
        memory_write_enable : out STD_LOGIC;
        memory_read_enable : out STD_LOGIC;
        memory_read_data : in STD_LOGIC_VECTOR(31 downto 0)
    );
end Memory_Interface;

architecture Behavioral of Memory_Interface is
    signal fetch_data_reg : STD_LOGIC_VECTOR(31 downto 0);
    signal mem_data_reg : STD_LOGIC_VECTOR(31 downto 0);
    signal last_access_was_mem : STD_LOGIC;
    
begin
    process(clk, rst)
    begin
        if rst = '1' then
            fetch_data_reg <= (others => '0');
            mem_data_reg <= (others => '0');
            last_access_was_mem <= '0';
            
        elsif rising_edge(clk) then
            -- Priority-based memory access arbitration
            -- Memory stage (Load/Store) has priority over Fetch when mem_stage_priority is set
            
            if mem_stage_priority = '1' and (mem_write_enable = '1' or mem_read_enable = '1') then
                -- Memory stage access
                memory_address <= mem_address;
                memory_write_data <= mem_write_data;
                memory_write_enable <= mem_write_enable;
                memory_read_enable <= mem_read_enable;
                last_access_was_mem <= '1';
                
                -- Store read data for memory stage
                if mem_read_enable = '1' then
                    mem_data_reg <= memory_read_data;
                end if;
                
            else
                -- Fetch stage access (default)
                memory_address <= fetch_address;
                memory_write_data <= (others => '0');
                memory_write_enable <= '0';
                memory_read_enable <= fetch_read_enable;
                last_access_was_mem <= '0';
                
                -- Store read data for fetch stage
                if fetch_read_enable = '1' then
                    fetch_data_reg <= memory_read_data;
                end if;
            end if;
        end if;
    end process;
    
    -- Output assignments
    fetch_read_data <= fetch_data_reg;
    mem_read_data <= mem_data_reg;
    
end Behavioral;
