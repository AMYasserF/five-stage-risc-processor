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
        -- Test SWAP operation
        
        -- LDM R1, #0x1111 (load first test value)
        2 => X"A4400000",  -- LDM R1
        3 => X"00001111",
        
        -- 3 NOPs for pipeline settling
        4 => X"00000000",
        5 => X"00000000",
        6 => X"00000000",

        -- LDM R2, #0x2222 (load second test value)
        7 => X"A4800000",  -- LDM R2
        8 => X"00002222",
        
        -- 3 NOPs
        9 => X"00000000",
        10 => X"00000000",
        11 => X"00000000",

        -- SWAP R1, R2 (swap values of R1 and R2)
        -- Opcode: 0111 (R-type SWAP)
        -- Format: [31:25]=0001110, [24:22]=R2(010), [21:19]=R1(001), [18:16]=unused
        12 => X"0E8A0000",  -- SWAP R1, R2
        
        -- 5 NOPs to observe result
        -- After SWAP: R1 should have 0x2222, R2 should have 0x1111
        13 => X"00000000",
        14 => X"00000000",
        15 => X"00000000",
        16 => X"00000000",
        17 => X"00000000",

        -- LDM R3, #0x3333 (load third test value)
        18 => X"A4C00000",  -- LDM R3
        19 => X"00003333",
        
        -- 3 NOPs
        20 => X"00000000",
        21 => X"00000000",
        22 => X"00000000",

        -- LDM R4, #0x4444 (load fourth test value)
        23 => X"A5000000",  -- LDM R4
        24 => X"00004444",
        
        -- 3 NOPs
        25 => X"00000000",
        26 => X"00000000",
        27 => X"00000000",

        -- SWAP R3, R4 (swap values of R3 and R4)
        -- Format: [31:25]=0001110, [24:22]=R4(100), [21:19]=R3(011), [18:16]=unused
        28 => X"0E9C0000",  -- SWAP R3, R4
        
        -- 5 NOPs to observe result
        -- After SWAP: R3 should have 0x4444, R4 should have 0x3333
        29 => X"00000000",
        30 => X"00000000",
        31 => X"00000000",
        32 => X"00000000",
        33 => X"00000000",

        -- SWAP R1, R3 (swap R1 and R3)
        -- Format: [31:25]=0001110, [24:22]=R3(011), [21:19]=R1(001), [18:16]=unused
        34 => X"0E6C0000",  -- SWAP R1, R3
        
        -- 5 NOPs to observe final result
        -- After SWAP: R1 should have 0x4444, R3 should have 0x2222
        35 => X"00000000",
        36 => X"00000000",
        37 => X"00000000",
        38 => X"00000000",
        39 => X"00000000",

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
        
        -- Run for 250 cycles to allow SWAP test to complete
        wait for clk_period * 250;
        
        -- Stop simulation
        wait;
    end process;
    
end Behavioral;
