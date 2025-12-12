library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Top-Level Processor Integration
-- Connects all pipeline stages and the memory system

entity Processor_Top is
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        
        -- External interfaces (if needed)
        -- Add I/O ports here
        
        -- Debug outputs (optional)
        debug_pc : out STD_LOGIC_VECTOR(31 downto 0);
        debug_instruction : out STD_LOGIC_VECTOR(31 downto 0)
    );
end Processor_Top;

architecture Structural of Processor_Top is
    -- Component Declarations
    
    component Fetch_Stage is
        Port (
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            pc_enable : in STD_LOGIC;
            sp_enable : in STD_LOGIC;
            ifid_enable : in STD_LOGIC;
            ifid_flush : in STD_LOGIC;
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
            mem_fetch_address : out STD_LOGIC_VECTOR(31 downto 0);
            mem_fetch_read_enable : out STD_LOGIC;
            mem_fetch_read_data : in STD_LOGIC_VECTOR(31 downto 0);
            mem_data_address : out STD_LOGIC_VECTOR(31 downto 0);
            mem_data_write_data : out STD_LOGIC_VECTOR(31 downto 0);
            mem_data_write_enable : out STD_LOGIC;
            instruction_out : out STD_LOGIC_VECTOR(31 downto 0);
            pc_plus_1_out : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component Memory_Stage is
        Port (
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            mem_read : in STD_LOGIC;
            mem_write : in STD_LOGIC;
            alu_result : in STD_LOGIC_VECTOR(31 downto 0);
            write_data : in STD_LOGIC_VECTOR(31 downto 0);
            mem_address : out STD_LOGIC_VECTOR(31 downto 0);
            mem_write_data : out STD_LOGIC_VECTOR(31 downto 0);
            mem_write_enable : out STD_LOGIC;
            mem_read_enable : out STD_LOGIC;
            mem_read_data : in STD_LOGIC_VECTOR(31 downto 0);
            mem_data_out : out STD_LOGIC_VECTOR(31 downto 0);
            alu_result_out : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
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
    
    -- Internal Signals
    
    -- Fetch Stage signals
    signal fetch_instruction : STD_LOGIC_VECTOR(31 downto 0);
    signal fetch_pc_plus_1 : STD_LOGIC_VECTOR(31 downto 0);
    signal fetch_mem_address : STD_LOGIC_VECTOR(31 downto 0);
    signal fetch_mem_read_enable : STD_LOGIC;
    signal fetch_mem_read_data : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Memory Stage signals
    signal mem_stage_address : STD_LOGIC_VECTOR(31 downto 0);
    signal mem_stage_write_data : STD_LOGIC_VECTOR(31 downto 0);
    signal mem_stage_write_enable : STD_LOGIC;
    signal mem_stage_read_enable : STD_LOGIC;
    signal mem_stage_read_data : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Control signals (temporary defaults - to be connected to control unit)
    signal pc_enable : STD_LOGIC := '1';
    signal sp_enable : STD_LOGIC := '1';
    signal ifid_enable : STD_LOGIC := '1';
    signal ifid_flush : STD_LOGIC := '0';
    signal mem_stage_priority : STD_LOGIC := '0';
    
    -- Temporary signals for unconnected inputs
    signal temp_pc_plus_1_from_ifid : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal temp_pc_from_memory : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal temp_pc_from_alu : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal temp_alu_addr : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal temp_alu_plus_2_addr : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal temp_ccr_data : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal temp_pc_plus_1_from_idex : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal temp_regfile_data : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal temp_opcode : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal temp_branch_condition : STD_LOGIC := '0';
    signal temp_push_signal : STD_LOGIC := '0';
    signal temp_pop_signal : STD_LOGIC := '0';
    signal temp_mem_operation : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal temp_is_stack_op : STD_LOGIC := '0';
    signal temp_is_store : STD_LOGIC := '0';
    signal temp_is_call : STD_LOGIC := '0';
    signal temp_is_ccr_save : STD_LOGIC := '0';
    
    signal temp_mem_read : STD_LOGIC := '0';
    signal temp_mem_write : STD_LOGIC := '0';
    signal temp_alu_result : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal temp_write_data : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    
begin
    -- Fetch Stage Instantiation
    Fetch: Fetch_Stage
        port map (
            clk => clk,
            rst => rst,
            pc_enable => pc_enable,
            sp_enable => sp_enable,
            ifid_enable => ifid_enable,
            ifid_flush => ifid_flush,
            pc_plus_1_from_ifid => temp_pc_plus_1_from_ifid,
            pc_from_memory => temp_pc_from_memory,
            pc_from_alu => temp_pc_from_alu,
            alu_addr => temp_alu_addr,
            alu_plus_2_addr => temp_alu_plus_2_addr,
            ccr_data => temp_ccr_data,
            pc_plus_1_from_idex => temp_pc_plus_1_from_idex,
            regfile_data => temp_regfile_data,
            opcode => temp_opcode,
            branch_condition => temp_branch_condition,
            push_signal => temp_push_signal,
            pop_signal => temp_pop_signal,
            mem_operation => temp_mem_operation,
            is_stack_op => temp_is_stack_op,
            is_store => temp_is_store,
            is_call => temp_is_call,
            is_ccr_save => temp_is_ccr_save,
            mem_fetch_address => fetch_mem_address,
            mem_fetch_read_enable => fetch_mem_read_enable,
            mem_fetch_read_data => fetch_mem_read_data,
            mem_data_address => open,  -- Not used in current design
            mem_data_write_data => open,  -- Not used in current design
            mem_data_write_enable => open,  -- Not used in current design
            instruction_out => fetch_instruction,
            pc_plus_1_out => fetch_pc_plus_1
        );
    
    -- Memory Stage Instantiation
    Mem_Stage: Memory_Stage
        port map (
            clk => clk,
            rst => rst,
            mem_read => temp_mem_read,
            mem_write => temp_mem_write,
            alu_result => temp_alu_result,
            write_data => temp_write_data,
            mem_address => mem_stage_address,
            mem_write_data => mem_stage_write_data,
            mem_write_enable => mem_stage_write_enable,
            mem_read_enable => mem_stage_read_enable,
            mem_read_data => mem_stage_read_data,
            mem_data_out => open,  -- To be connected to MEM/WB register
            alu_result_out => open   -- To be connected to MEM/WB register
        );
    
    -- Memory System Instantiation
    Mem_Sys: Memory_System
        generic map (
            ADDR_WIDTH => 32,
            DATA_WIDTH => 32,
            MEM_SIZE => 1024
        )
        port map (
            clk => clk,
            rst => rst,
            fetch_address => fetch_mem_address,
            fetch_read_enable => fetch_mem_read_enable,
            fetch_read_data => fetch_mem_read_data,
            mem_address => mem_stage_address,
            mem_write_data => mem_stage_write_data,
            mem_write_enable => mem_stage_write_enable,
            mem_read_enable => mem_stage_read_enable,
            mem_read_data => mem_stage_read_data,
            mem_stage_priority => mem_stage_priority
        );
    
    -- Debug outputs
    debug_pc <= fetch_mem_address;
    debug_instruction <= fetch_instruction;
    
end Structural;
