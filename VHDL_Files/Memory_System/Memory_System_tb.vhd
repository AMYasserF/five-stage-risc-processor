library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Memory_System_tb is
end Memory_System_tb;

architecture Behavioral of Memory_System_tb is
    -- Component Declaration
    component Memory_System is
        Generic (
            ADDR_WIDTH : integer := 32;
            DATA_WIDTH : integer := 32;
            MEM_SIZE : integer := 1024
        );
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
            mem_stage_priority : in STD_LOGIC
        );
    end component;
    
    -- Test Signals
    signal clk : STD_LOGIC := '0';
    signal rst : STD_LOGIC := '0';
    
    -- Fetch interface
    signal fetch_address : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal fetch_read_enable : STD_LOGIC := '0';
    signal fetch_read_data : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Memory stage interface
    signal mem_address : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal mem_write_data : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal mem_write_enable : STD_LOGIC := '0';
    signal mem_read_enable : STD_LOGIC := '0';
    signal mem_read_data : STD_LOGIC_VECTOR(31 downto 0);
    
    signal mem_stage_priority : STD_LOGIC := '0';
    
    -- Clock period
    constant clk_period : time := 10 ns;
    
begin
    -- Instantiate the Unit Under Test (UUT)
    uut: Memory_System
        generic map (
            ADDR_WIDTH => 32,
            DATA_WIDTH => 32,
            MEM_SIZE => 1024
        )
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
            mem_stage_priority => mem_stage_priority
        );
    
    -- Clock process
    clk_process: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
    -- Stimulus process
    stim_proc: process
    begin
        -- Reset the system
        rst <= '1';
        wait for clk_period * 2;
        rst <= '0';
        wait for clk_period;
        
        -- Test 1: Fetch-only access (instruction fetch)
        report "Test 1: Fetch-only access";
        fetch_read_enable <= '1';
        fetch_address <= X"00000000";
        wait for clk_period;
        fetch_address <= X"00000001";
        wait for clk_period;
        fetch_address <= X"00000002";
        wait for clk_period * 2;
        
        -- Test 2: Memory stage write (store operation)
        report "Test 2: Memory stage write";
        mem_stage_priority <= '1';
        mem_write_enable <= '1';
        mem_address <= X"00000100";
        mem_write_data <= X"DEADBEEF";
        wait for clk_period;
        mem_write_enable <= '0';
        mem_stage_priority <= '0';
        wait for clk_period * 2;
        
        -- Test 3: Memory stage read (load operation)
        report "Test 3: Memory stage read";
        mem_stage_priority <= '1';
        mem_read_enable <= '1';
        mem_address <= X"00000100";
        wait for clk_period * 2;
        mem_read_enable <= '0';
        mem_stage_priority <= '0';
        wait for clk_period * 2;
        
        -- Test 4: Write multiple locations
        report "Test 4: Write multiple locations";
        mem_stage_priority <= '1';
        mem_write_enable <= '1';
        
        mem_address <= X"00000000";
        mem_write_data <= X"11111111";
        wait for clk_period;
        
        mem_address <= X"00000001";
        mem_write_data <= X"22222222";
        wait for clk_period;
        
        mem_address <= X"00000002";
        mem_write_data <= X"33333333";
        wait for clk_period;
        
        mem_write_enable <= '0';
        mem_stage_priority <= '0';
        wait for clk_period * 2;
        
        -- Test 5: Read back the written values via fetch
        report "Test 5: Read written values";
        fetch_read_enable <= '1';
        fetch_address <= X"00000000";
        wait for clk_period * 2;
        fetch_address <= X"00000001";
        wait for clk_period * 2;
        fetch_address <= X"00000002";
        wait for clk_period * 2;
        
        -- Test 6: Priority - memory stage overrides fetch
        report "Test 6: Priority test";
        fetch_read_enable <= '1';
        fetch_address <= X"00000010";
        mem_stage_priority <= '1';
        mem_read_enable <= '1';
        mem_address <= X"00000100";
        wait for clk_period * 2;
        mem_read_enable <= '0';
        mem_stage_priority <= '0';
        wait for clk_period * 2;
        
        -- End simulation
        report "Testbench completed successfully";
        fetch_read_enable <= '0';
        wait;
    end process;
    
end Behavioral;
