library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Complete Memory System
-- Integrates shared memory with interface controller
-- This is the top-level memory module that connects to all pipeline stages

entity Memory_System is
    Generic (
        ADDR_WIDTH : integer := 32;
        DATA_WIDTH : integer := 32;
        MEM_SIZE : integer := 1024
    );
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
        mem_stage_priority : in STD_LOGIC
    );
end Memory_System;

architecture Structural of Memory_System is
    -- Component declarations
    component Shared_Memory is
        Generic (
            ADDR_WIDTH : integer := 32;
            DATA_WIDTH : integer := 32;
            MEM_SIZE : integer := 1024
        );
        Port (
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            address : in STD_LOGIC_VECTOR(ADDR_WIDTH-1 downto 0);
            write_data : in STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0);
            write_enable : in STD_LOGIC;
            read_enable : in STD_LOGIC;
            read_data : out STD_LOGIC_VECTOR(DATA_WIDTH-1 downto 0)
        );
    end component;
    
    component Memory_Interface is
        Port (
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            fetch_address : in STD_LOGIC_VECTOR(31 downto 0);
            fetch_read_enable : in STD_LOGIC;
            fetch_read_data : out STD_LOGIC_VECTOR(31 downto 0);
            mem_address : in STD_LOGIC_VECTOR(31 downto 0);
            mem_write_data : in STD_LOGIC_VECTOR(31 downto 0);
            mem_write_enable : in STD_LOGIC;
            mem_read_enable : in STD_LOGIC;
            mem_read_data : out STD_LOGIC_VECTOR(31 downto 0);
            mem_stage_priority : in STD_LOGIC;
            memory_address : out STD_LOGIC_VECTOR(31 downto 0);
            memory_write_data : out STD_LOGIC_VECTOR(31 downto 0);
            memory_write_enable : out STD_LOGIC;
            memory_read_enable : out STD_LOGIC;
            memory_read_data : in STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    -- Internal signals connecting interface to memory
    signal internal_address : STD_LOGIC_VECTOR(31 downto 0);
    signal internal_write_data : STD_LOGIC_VECTOR(31 downto 0);
    signal internal_write_enable : STD_LOGIC;
    signal internal_read_enable : STD_LOGIC;
    signal internal_read_data : STD_LOGIC_VECTOR(31 downto 0);
    
begin
    -- Memory Interface Controller
    mem_interface: Memory_Interface
        port map (
            clk => clk,
            rst => rst,
            fetch_address => fetch_address,
            fetch_read_enable => fetch_read_enable,
            fetch_read_data => fetch_read_data,
            mem_address => mem_address,
            mem_write_data => mem_write_data,
            mem_write_enable => mem_write_enable,
            mem_read_enable => mem_read_enable,
            mem_read_data => mem_read_data,
            mem_stage_priority => mem_stage_priority,
            memory_address => internal_address,
            memory_write_data => internal_write_data,
            memory_write_enable => internal_write_enable,
            memory_read_enable => internal_read_enable,
            memory_read_data => internal_read_data
        );
    
    -- Shared Memory
    shared_mem: Shared_Memory
        generic map (
            ADDR_WIDTH => ADDR_WIDTH,
            DATA_WIDTH => DATA_WIDTH,
            MEM_SIZE => MEM_SIZE
        )
        port map (
            clk => clk,
            rst => rst,
            address => internal_address,
            write_data => internal_write_data,
            write_enable => internal_write_enable,
            read_enable => internal_read_enable,
            read_data => internal_read_data
        );
    
end Structural;
