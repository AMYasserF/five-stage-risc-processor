library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Simple testbench for complete 5-stage processor
entity Processor_Top_TB is
end Processor_Top_TB;

architecture Behavioral of Processor_Top_TB is
    
    component Processor_Top is
        Port (
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            mem_address : out STD_LOGIC_VECTOR(31 downto 0);
            mem_read_data : in STD_LOGIC_VECTOR(31 downto 0);
            input_port : in STD_LOGIC_VECTOR(31 downto 0);
            output_port : out STD_LOGIC_VECTOR(31 downto 0);
            wb_write_enable : out STD_LOGIC;
            wb_write_reg : out STD_LOGIC_VECTOR(2 downto 0);
            wb_write_data : out STD_LOGIC_VECTOR(31 downto 0);
            ex_mem_rti_phase : out STD_LOGIC;
            ex_mem_int_phase : out STD_LOGIC;
            ex_mem_mem_write : out STD_LOGIC;
            ex_mem_mem_read : out STD_LOGIC;
            ex_mem_mem_to_reg : out STD_LOGIC;
            ex_mem_out_enable : out STD_LOGIC;
            ex_mem_is_swap : out STD_LOGIC;
            ex_mem_swap_phase : out STD_LOGIC;
            ex_mem_reg_write : out STD_LOGIC;
            ex_mem_is_call : out STD_LOGIC;
            ex_mem_is_ret : out STD_LOGIC;
            ex_mem_is_push : out STD_LOGIC;
            ex_mem_is_pop : out STD_LOGIC;
            ex_mem_is_in : out STD_LOGIC;
            ex_mem_is_int : out STD_LOGIC;
            ex_mem_is_rti : out STD_LOGIC;
            ex_mem_hlt : out STD_LOGIC;
            ex_mem_read_reg1 : out STD_LOGIC_VECTOR(2 downto 0);
            ex_mem_write_reg : out STD_LOGIC_VECTOR(2 downto 0);
            ex_mem_read_data2 : out STD_LOGIC_VECTOR(31 downto 0);
            ex_mem_alu_result : out STD_LOGIC_VECTOR(31 downto 0);
            conditional_jump : out STD_LOGIC;
            pc_plus_2 : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    -- Testbench signals
    signal clk : STD_LOGIC := '0';
    signal rst : STD_LOGIC := '1';
    
    signal mem_address : STD_LOGIC_VECTOR(31 downto 0);
    signal mem_read_data : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    
    signal input_port : STD_LOGIC_VECTOR(31 downto 0) := X"DEADBEEF";
    signal output_port : STD_LOGIC_VECTOR(31 downto 0);
    
    signal wb_write_enable : STD_LOGIC;
    signal wb_write_reg : STD_LOGIC_VECTOR(2 downto 0);
    signal wb_write_data : STD_LOGIC_VECTOR(31 downto 0);
    
    signal ex_mem_rti_phase : STD_LOGIC;
    signal ex_mem_int_phase : STD_LOGIC;
    signal ex_mem_mem_write : STD_LOGIC;
    signal ex_mem_mem_read : STD_LOGIC;
    signal ex_mem_mem_to_reg : STD_LOGIC;
    signal ex_mem_out_enable : STD_LOGIC;
    signal ex_mem_is_swap : STD_LOGIC;
    signal ex_mem_swap_phase : STD_LOGIC;
    signal ex_mem_reg_write : STD_LOGIC;
    signal ex_mem_is_call : STD_LOGIC;
    signal ex_mem_is_ret : STD_LOGIC;
    signal ex_mem_is_push : STD_LOGIC;
    signal ex_mem_is_pop : STD_LOGIC;
    signal ex_mem_is_in : STD_LOGIC;
    signal ex_mem_is_int : STD_LOGIC;
    signal ex_mem_is_rti : STD_LOGIC;
    signal ex_mem_hlt : STD_LOGIC;
    signal ex_mem_read_reg1 : STD_LOGIC_VECTOR(2 downto 0);
    signal ex_mem_write_reg : STD_LOGIC_VECTOR(2 downto 0);
    signal ex_mem_read_data2 : STD_LOGIC_VECTOR(31 downto 0);
    signal ex_mem_alu_result : STD_LOGIC_VECTOR(31 downto 0);
    signal conditional_jump : STD_LOGIC;
    signal pc_plus_2 : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Clock period
    constant clk_period : time := 10 ns;
    
    -- Instruction memory (LDD/STD test)
    type mem_array is array (0 to 127) of STD_LOGIC_VECTOR(31 downto 0);
    signal instruction_memory : mem_array := (
        -- Address 0: pointer to program start (address 2)
        0 => X"00000002",
        1 => X"00000000",

        -- Program starts at address 2
        -- Test LDD and STD operations
        
        -- LDM R1, #0xAAAA (load test value)
        2 => X"A4400000",  -- LDM R1
        3 => X"0000AAAA",
        
        -- 3 NOPs for pipeline settling
        4 => X"00000000",
        5 => X"00000000",
        6 => X"00000000",

        -- LDM R2, #0xBBBB (load second test value)
        7 => X"A4800000",  -- LDM R2
        8 => X"0000BBBB",
        
        -- 3 NOPs
        9 => X"00000000",
        10 => X"00000000",
        11 => X"00000000",

        -- LDM R3, #50 (load base address for memory operations)
        12 => X"A4C00000",  -- LDM R3
        13 => X"00000032",  -- Address 50
        
        -- 3 NOPs
        14 => X"00000000",
        15 => X"00000000",
        16 => X"00000000",

        -- STD R1, R3, #0 (store R1 to memory[R3+0] = memory[50])
        17 => X"A8190000",  --  
        18 => X"00000000",  -- offset = 0
        
        -- 3 NOPs
        19 => X"00000000",
        20 => X"00000000",
        21 => X"00000000",

        -- STD R2, R3, #2 (store R2 to memory[R3+2] = memory[52])
        22 => X"A81A0000",  -- STD R2, R3, offset
        23 => X"00000002",  -- offset = 2
        
        -- 3 NOPs
        24 => X"00000000",
        25 => X"00000000",
        26 => X"00000000",

        -- LDM R1, #0x0000 (clear R1)
        27 => X"A4400000",  -- LDM R1
        28 => X"00000000",
        
        -- 3 NOPs
        29 => X"00000000",
        30 => X"00000000",
        31 => X"00000000",

        -- LDM R2, #0x0000 (clear R2)
        32 => X"A4800000",  -- LDM R2
        33 => X"00000000",
        
        -- 3 NOPs
        34 => X"00000000",
        35 => X"00000000",
        36 => X"00000000",

        -- LDD R4, R3, #0 (load from memory[R3+0] to R4, should get 0xAAAA)
        37 => X"A7180000",  -- LDD R4, R3, offset
        38 => X"00000000",  -- offset = 0
        
        -- 3 NOPs
        39 => X"00000000",
        40 => X"00000000",
        41 => X"00000000",

        -- LDD R5, R3, #2 (load from memory[R3+2] to R5, should get 0xBBBB)
        42 => X"A7580000",  -- LDD R5, R3, offset
        43 => X"00000002",  -- offset = 2
        
        -- 5 NOPs to observe final values
        44 => X"00000000",
        45 => X"00000000",
        46 => X"00000000",
        47 => X"00000000",
        48 => X"00000000",

        others => X"00000000"
    );
    
begin
    
    -- Instantiate processor
    UUT: Processor_Top
        port map (
            clk => clk,
            rst => rst,
            mem_address => mem_address,
            mem_read_data => mem_read_data,
            input_port => input_port,
            output_port => output_port,
            wb_write_enable => wb_write_enable,
            wb_write_reg => wb_write_reg,
            wb_write_data => wb_write_data,
            ex_mem_rti_phase => ex_mem_rti_phase,
            ex_mem_int_phase => ex_mem_int_phase,
            ex_mem_mem_write => ex_mem_mem_write,
            ex_mem_mem_read => ex_mem_mem_read,
            ex_mem_mem_to_reg => ex_mem_mem_to_reg,
            ex_mem_out_enable => ex_mem_out_enable,
            ex_mem_is_swap => ex_mem_is_swap,
            ex_mem_swap_phase => ex_mem_swap_phase,
            ex_mem_reg_write => ex_mem_reg_write,
            ex_mem_is_call => ex_mem_is_call,
            ex_mem_is_ret => ex_mem_is_ret,
            ex_mem_is_push => ex_mem_is_push,
            ex_mem_is_pop => ex_mem_is_pop,
            ex_mem_is_in => ex_mem_is_in,
            ex_mem_is_int => ex_mem_is_int,
            ex_mem_is_rti => ex_mem_is_rti,
            ex_mem_hlt => ex_mem_hlt,
            ex_mem_read_reg1 => ex_mem_read_reg1,
            ex_mem_write_reg => ex_mem_write_reg,
            ex_mem_read_data2 => ex_mem_read_data2,
            ex_mem_alu_result => ex_mem_alu_result,
            conditional_jump => conditional_jump,
            pc_plus_2 => pc_plus_2
        );
    
    -- Clock generation
    clk_process: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
    -- Instruction memory read (use 7 bits to support addresses 0-127)
    mem_read_data <= instruction_memory(to_integer(unsigned(mem_address(6 downto 0))));
    
    -- Stimulus
    stimulus: process
    begin
        -- Hold reset for 2 cycles
        rst <= '1';
        wait for clk_period * 2;
        
        -- Release reset
        rst <= '0';
        
        -- Run for 300 cycles to allow LDD/STD test to complete
        wait for clk_period * 300;
        
        -- Stop simulation
        wait;
    end process;
    
end Behavioral;
