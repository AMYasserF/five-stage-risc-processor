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
            pc_enable : in STD_LOGIC;
            ifid_enable : in STD_LOGIC;
            ifid_flush : in STD_LOGIC;
            mem_address : out STD_LOGIC_VECTOR(31 downto 0);
            mem_read_data : in STD_LOGIC_VECTOR(31 downto 0);
            immediate_decode : in STD_LOGIC_VECTOR(31 downto 0);
            alu_immediate : in STD_LOGIC_VECTOR(31 downto 0);
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
    signal pc_enable : STD_LOGIC := '1';
    signal ifid_enable : STD_LOGIC := '1';
    signal ifid_flush : STD_LOGIC := '0';
    
    signal mem_address : STD_LOGIC_VECTOR(31 downto 0);
    signal mem_read_data : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    
    signal immediate_decode : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal alu_immediate : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    
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
    
    -- Instruction memory (JUMP test)
    type mem_array is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
    signal instruction_memory : mem_array := (
        -- Address 0: pointer to program start (address 2)
        0 => X"00000002",
        1 => X"00000000",

        -- Program starts at address 2
        -- LDM R1, #5
        2 => X"A4400000",  -- LDM R1, #5
        3 => X"00000005",
        -- 5 NOPs
        4 => X"00000000",
        5 => X"00000000",
        6 => X"00000000",
        7 => X"00000000",
        8 => X"00000000",

        -- LDM R2, #5
        9 => X"A4800000",  -- LDM R2, #5
        10 => X"00000005",
        -- 5 NOPs
        11 => X"00000000",
        12 => X"00000000",
        13 => X"00000000",
        14 => X"00000000",
        15 => X"00000000",

        -- SUB R3, R1, R2  (should produce zero)
        16 => X"12CA0000",
        -- 5 NOPs
        17 => X"00000000",
        18 => X"00000000",
        19 => X"00000000",
        20 => X"00000000",
        21 => X"00000000",

        -- Conditional jump: JZ to address 28 (if zero)
        22 => X"C4000000",
        23 => X"0000001C",

        -- Unconditional jump: JMP to address 30
        24 => X"C2000000",
        25 => X"0000001E",

        26 => X"00000000",
        27 => X"00000000",

        -- Target 28: LDM R4, #DEADBEEF  (taken by JZ)
        28 => X"A5000000",
        29 => X"DEADBEEF",

        -- Target 30: LDM R5, #0xAA (taken by JMP)
        30 => X"A5400000",
        31 => X"000000AA",
        others => X"00000000"
    );
    
begin
    
    -- Instantiate processor
    UUT: Processor_Top
        port map (
            clk => clk,
            rst => rst,
            pc_enable => pc_enable,
            ifid_enable => ifid_enable,
            ifid_flush => ifid_flush,
            mem_address => mem_address,
            mem_read_data => mem_read_data,
            immediate_decode => immediate_decode,
            alu_immediate => alu_immediate,
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
    
    -- Instruction memory read (use 5 bits to support addresses 0-31)
    mem_read_data <= instruction_memory(to_integer(unsigned(mem_address(4 downto 0))));
    
    -- Stimulus
    stimulus: process
    begin
        -- Hold reset for 2 cycles
        rst <= '1';
        wait for clk_period * 2;
        
        -- Release reset
        rst <= '0';
        
    -- Run for 100 cycles to allow jump tests to complete
    wait for clk_period * 100;
        
        -- Stop simulation
        wait;
    end process;
    
end Behavioral;
