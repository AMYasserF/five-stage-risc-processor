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
            is_conditional_jump : in STD_LOGIC;
            is_unconditional_jump : in STD_LOGIC;
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
    
    signal is_conditional_jump : STD_LOGIC := '0';
    signal is_unconditional_jump : STD_LOGIC := '0';
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
    
    -- Instruction memory (IN/OUT test)
    type mem_array is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
    signal instruction_memory : mem_array := (
        -- Address 0: Jump to program start location
        0 => X"00000002",  -- Jump to address 2 (program start)
        1 => X"00000000",  -- NOP (unused)
        
        -- Test PUSH and POP instructions
        -- First, load some values into registers
        2 => X"A4800000",  -- LDM R2, #0x1234 (opcode=0x52, rd=2)
        3 => X"00001234",  -- immediate 0x1234
        4 => X"00000000",  -- NOP
        5 => X"00000000",  -- NOP
        6 => X"00000000",  -- NOP
        7 => X"00000000",  -- NOP
        8 => X"00000000",  -- NOP
        
        9 => X"A4C00000",  -- LDM R3, #0x5678 (opcode=0x52, rd=3)
        10 => X"00005678", -- immediate 0x5678
        11 => X"00000000", -- NOP
        12 => X"00000000", -- NOP
        13 => X"00000000", -- NOP
        14 => X"00000000", -- NOP
        15 => X"00000000", -- NOP
        
        -- PUSH R2 onto stack
        16 => X"62100000", -- PUSH R2 (opcode=0x31, rs1=2)
        17 => X"00000000", -- NOP
        18 => X"00000000", -- NOP
        19 => X"00000000", -- NOP
        20 => X"00000000", -- NOP
        21 => X"00000000", -- NOP
        
        -- PUSH R3 onto stack
        22 => X"62180000", -- PUSH R3 (opcode=0x31, rs1=3)
        23 => X"00000000", -- NOP
        24 => X"00000000", -- NOP
        25 => X"00000000", -- NOP
        26 => X"00000000", -- NOP
        27 => X"00000000", -- NOP
        
        -- POP into R4 (should get R3's value: 0x5678)
        28 => X"65000000", -- POP R4 (opcode=0x32, rd=4)
        29 => X"00000000", -- NOP
        30 => X"00000000", -- NOP
        31 => X"00000000", -- NOP
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
            is_conditional_jump => is_conditional_jump,
            is_unconditional_jump => is_unconditional_jump,
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
        
        -- Run for 50 cycles to see all PUSH/POP instructions complete
        wait for clk_period * 50;
        
        -- Stop simulation
        wait;
    end process;
    
end Behavioral;
