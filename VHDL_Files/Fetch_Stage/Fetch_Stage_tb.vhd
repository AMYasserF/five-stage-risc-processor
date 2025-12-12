library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Fetch_Stage_tb is
end Fetch_Stage_tb;

architecture Behavioral of Fetch_Stage_tb is
    -- Component Declaration
    component Fetch_Stage is
        Port (
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            pc_enable : in STD_LOGIC;
            sp_enable : in STD_LOGIC;
            ifid_enable : in STD_LOGIC;
            ifid_flush : in STD_LOGIC;
            mem_write_enable : in STD_LOGIC;
            mem_read_enable : in STD_LOGIC;
            pc_plus_1_from_ifid : in STD_LOGIC_VECTOR(31 downto 0);
            pc_from_memory : in STD_LOGIC_VECTOR(31 downto 0);
            pc_from_alu : in STD_LOGIC_VECTOR(31 downto 0);
            alu_addr : in STD_LOGIC_VECTOR(31 downto 0);
            alu_plus_2_addr : in STD_LOGIC_VECTOR(31 downto 0);
            ccr_data : in STD_LOGIC_VECTOR(31 downto 0);
            pc_plus_1_from_idex : in STD_LOGIC_VECTOR(31 downto 0);
            regfile_data : in STD_LOGIC_VECTOR(31 downto 0);
            opcode : in STD_LOGIC_VECTOR(7 downto 0);
            branch_condition : in STD_LOGIC;
            push_signal : in STD_LOGIC;
            pop_signal : in STD_LOGIC;
            mem_operation : in STD_LOGIC_VECTOR(1 downto 0);
            is_stack_op : in STD_LOGIC;
            is_store : in STD_LOGIC;
            is_call : in STD_LOGIC;
            is_ccr_save : in STD_LOGIC;
            instruction_out : out STD_LOGIC_VECTOR(31 downto 0);
            pc_plus_1_out : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    -- Test Signals
    signal clk : STD_LOGIC := '0';
    signal rst : STD_LOGIC := '0';
    signal pc_enable : STD_LOGIC := '1';
    signal sp_enable : STD_LOGIC := '1';
    signal ifid_enable : STD_LOGIC := '1';
    signal ifid_flush : STD_LOGIC := '0';
    signal mem_write_enable : STD_LOGIC := '0';
    signal mem_read_enable : STD_LOGIC := '1';
    
    signal pc_plus_1_from_ifid : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal pc_from_memory : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal pc_from_alu : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal alu_addr : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal alu_plus_2_addr : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal ccr_data : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal pc_plus_1_from_idex : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal regfile_data : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    
    signal opcode : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal branch_condition : STD_LOGIC := '0';
    signal push_signal : STD_LOGIC := '0';
    signal pop_signal : STD_LOGIC := '0';
    signal mem_operation : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal is_stack_op : STD_LOGIC := '0';
    signal is_store : STD_LOGIC := '0';
    signal is_call : STD_LOGIC := '0';
    signal is_ccr_save : STD_LOGIC := '0';
    
    signal instruction_out : STD_LOGIC_VECTOR(31 downto 0);
    signal pc_plus_1_out : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Clock period
    constant clk_period : time := 10 ns;
    
begin
    -- Instantiate the Unit Under Test (UUT)
    uut: Fetch_Stage
        port map (
            clk => clk,
            rst => rst,
            pc_enable => pc_enable,
            sp_enable => sp_enable,
            ifid_enable => ifid_enable,
            ifid_flush => ifid_flush,
            mem_write_enable => mem_write_enable,
            mem_read_enable => mem_read_enable,
            pc_plus_1_from_ifid => pc_plus_1_from_ifid,
            pc_from_memory => pc_from_memory,
            pc_from_alu => pc_from_alu,
            alu_addr => alu_addr,
            alu_plus_2_addr => alu_plus_2_addr,
            ccr_data => ccr_data,
            pc_plus_1_from_idex => pc_plus_1_from_idex,
            regfile_data => regfile_data,
            opcode => opcode,
            branch_condition => branch_condition,
            push_signal => push_signal,
            pop_signal => pop_signal,
            mem_operation => mem_operation,
            is_stack_op => is_stack_op,
            is_store => is_store,
            is_call => is_call,
            is_ccr_save => is_ccr_save,
            instruction_out => instruction_out,
            pc_plus_1_out => pc_plus_1_out
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
        
        -- Test 1: Normal PC increment (instruction fetch)
        report "Test 1: Normal PC increment";
        mem_read_enable <= '1';
        wait for clk_period * 5;
        
        -- Test 2: Branch operation (PC from ALU)
        report "Test 2: Branch to address from ALU";
        pc_from_alu <= X"00000100";
        branch_condition <= '1';
        wait for clk_period * 2;
        branch_condition <= '0';
        wait for clk_period * 3;
        
        -- Test 3: Flush IF/ID register
        report "Test 3: Flush IF/ID register";
        ifid_flush <= '1';
        wait for clk_period;
        ifid_flush <= '0';
        wait for clk_period * 2;
        
        -- Test 4: Stack push operation
        report "Test 4: Stack push operation";
        push_signal <= '1';
        is_stack_op <= '1';
        wait for clk_period * 2;
        push_signal <= '0';
        is_stack_op <= '0';
        wait for clk_period * 2;
        
        -- Test 5: Stack pop operation
        report "Test 5: Stack pop operation";
        pop_signal <= '1';
        is_stack_op <= '1';
        wait for clk_period * 2;
        pop_signal <= '0';
        is_stack_op <= '0';
        wait for clk_period * 2;
        
        -- End simulation
        report "Testbench completed successfully";
        wait;
    end process;
    
end Behavioral;
