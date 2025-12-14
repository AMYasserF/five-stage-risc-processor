library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Fetch_Stage is
    Port (
        -- Clock and Reset
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        
        -- Control Signals
        pc_enable : in STD_LOGIC;
        sp_enable : in STD_LOGIC;
        ifid_enable : in STD_LOGIC;
        ifid_flush : in STD_LOGIC;
        
        -- Inputs from later stages (feedback paths)
        pc_plus_1_from_ifid : in STD_LOGIC_VECTOR(31 downto 0);
        pc_from_memory : in STD_LOGIC_VECTOR(31 downto 0);
        pc_from_alu : in STD_LOGIC_VECTOR(31 downto 0);
        alu_addr : in STD_LOGIC_VECTOR(31 downto 0);
        alu_plus_2_addr : in STD_LOGIC_VECTOR(31 downto 0);
        ccr_data : in STD_LOGIC_VECTOR(31 downto 0);
        pc_plus_1_from_idex : in STD_LOGIC_VECTOR(31 downto 0);
        regfile_data : in STD_LOGIC_VECTOR(31 downto 0);
        
        -- Control inputs for control units (to be connected later)
        opcode : in STD_LOGIC_VECTOR(7 downto 0);
        branch_condition : in STD_LOGIC;
        push_signal : in STD_LOGIC;
        pop_signal : in STD_LOGIC;
        mem_operation : in STD_LOGIC_VECTOR(1 downto 0);
        is_stack_op : in STD_LOGIC;
        is_store : in STD_LOGIC;
        is_call : in STD_LOGIC;
        is_ccr_save : in STD_LOGIC;
        
        -- Memory System Interface (Fetch)
        mem_fetch_address : out STD_LOGIC_VECTOR(31 downto 0);
        mem_fetch_read_enable : out STD_LOGIC;
        mem_fetch_read_data : in STD_LOGIC_VECTOR(31 downto 0);
        
        -- Memory System Interface (Data - Write path from fetch stage)
        mem_data_address : out STD_LOGIC_VECTOR(31 downto 0);
        mem_data_write_data : out STD_LOGIC_VECTOR(31 downto 0);
        mem_data_write_enable : out STD_LOGIC;
        
        -- Outputs to IF/ID Register
        instruction_out : out STD_LOGIC_VECTOR(31 downto 0);
        pc_plus_1_out : out STD_LOGIC_VECTOR(31 downto 0)
    );
end Fetch_Stage;

architecture Structural of Fetch_Stage is
    -- Component Declarations
    component PC_Register is
        Port (
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            enable : in STD_LOGIC;
            pc_in : in STD_LOGIC_VECTOR(31 downto 0);
            pc_out : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component SP_Register is
        Port (
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            enable : in STD_LOGIC;
            sp_in : in STD_LOGIC_VECTOR(31 downto 0);
            sp_out : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component PC_Mux is
        Port (
            pc_plus_1 : in STD_LOGIC_VECTOR(31 downto 0);
            pc_plus_1_ifid : in STD_LOGIC_VECTOR(31 downto 0);
            pc_from_memory : in STD_LOGIC_VECTOR(31 downto 0);
            pc_from_alu : in STD_LOGIC_VECTOR(31 downto 0);
            sel : in STD_LOGIC_VECTOR(1 downto 0);
            pc_out : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component SP_Mux is
        Port (
            sp_plus_1 : in STD_LOGIC_VECTOR(31 downto 0);
            sp_minus_1 : in STD_LOGIC_VECTOR(31 downto 0);
            sp_init : in STD_LOGIC_VECTOR(31 downto 0);
            sel : in STD_LOGIC_VECTOR(1 downto 0);
            sp_out : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component Memory_Address_Mux is
        Port (
            pc_addr : in STD_LOGIC_VECTOR(31 downto 0);
            sp_addr : in STD_LOGIC_VECTOR(31 downto 0);
            sp_plus_1_addr : in STD_LOGIC_VECTOR(31 downto 0);
            alu_addr : in STD_LOGIC_VECTOR(31 downto 0);
            alu_plus_2_addr : in STD_LOGIC_VECTOR(31 downto 0);
            sel : in STD_LOGIC_VECTOR(2 downto 0);
            mem_addr_out : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component Memory_Write_Data_Mux is
        Port (
            ccr_data : in STD_LOGIC_VECTOR(31 downto 0);
            pc_plus_1_idex : in STD_LOGIC_VECTOR(31 downto 0);
            regfile_data : in STD_LOGIC_VECTOR(31 downto 0);
            sel : in STD_LOGIC_VECTOR(1 downto 0);
            write_data_out : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component PC_Adder is
        Port (
            pc_in : in STD_LOGIC_VECTOR(31 downto 0);
            pc_plus_1 : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component SP_Adder is
        Port (
            sp_in : in STD_LOGIC_VECTOR(31 downto 0);
            sp_plus_1 : out STD_LOGIC_VECTOR(31 downto 0);
            sp_minus_1 : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component IF_ID_Register is
        Port (
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            enable : in STD_LOGIC;
            flush : in STD_LOGIC;
            instruction_in : in STD_LOGIC_VECTOR(31 downto 0);
            pc_plus_1_in : in STD_LOGIC_VECTOR(31 downto 0);
            instruction_out : out STD_LOGIC_VECTOR(31 downto 0);
            pc_plus_1_out : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    -- Memory interface is now external - no memory component in fetch stage
    
    -- Control Unit Components
    component PC_Mux_Control is
        Port (
            opcode : in STD_LOGIC_VECTOR(7 downto 0);
            branch_condition : in STD_LOGIC;
            pc_mux_sel : out STD_LOGIC_VECTOR(1 downto 0)
        );
    end component;
    
    component SP_Mux_Control is
        Port (
            opcode : in STD_LOGIC_VECTOR(7 downto 0);
            push_signal : in STD_LOGIC;
            pop_signal : in STD_LOGIC;
            reset_signal : in STD_LOGIC;
            sp_mux_sel : out STD_LOGIC_VECTOR(1 downto 0)
        );
    end component;
    
    component Memory_Address_Mux_Control is
        Port (
            opcode : in STD_LOGIC_VECTOR(7 downto 0);
            mem_operation : in STD_LOGIC_VECTOR(1 downto 0);
            is_stack_op : in STD_LOGIC;
            mem_addr_mux_sel : out STD_LOGIC_VECTOR(2 downto 0)
        );
    end component;
    
    component Memory_Write_Data_Mux_Control is
        Port (
            opcode : in STD_LOGIC_VECTOR(7 downto 0);
            is_store : in STD_LOGIC;
            is_call : in STD_LOGIC;
            is_ccr_save : in STD_LOGIC;
            mem_write_data_mux_sel : out STD_LOGIC_VECTOR(1 downto 0)
        );
    end component;
    
    -- Internal Signals
    signal pc_current : STD_LOGIC_VECTOR(31 downto 0);
    signal pc_next : STD_LOGIC_VECTOR(31 downto 0);
    signal pc_incremented : STD_LOGIC_VECTOR(31 downto 0);
    
    signal sp_current : STD_LOGIC_VECTOR(31 downto 0);
    signal sp_next : STD_LOGIC_VECTOR(31 downto 0);
    signal sp_plus_1 : STD_LOGIC_VECTOR(31 downto 0);
    signal sp_minus_1 : STD_LOGIC_VECTOR(31 downto 0);
    signal sp_init_value : STD_LOGIC_VECTOR(31 downto 0);
    
    signal internal_mem_address : STD_LOGIC_VECTOR(31 downto 0);
    signal internal_mem_write_data : STD_LOGIC_VECTOR(31 downto 0);
    
    signal pc_mux_sel_signal : STD_LOGIC_VECTOR(1 downto 0);
    signal sp_mux_sel_signal : STD_LOGIC_VECTOR(1 downto 0);
    signal mem_addr_mux_sel_signal : STD_LOGIC_VECTOR(2 downto 0);
    signal mem_write_data_mux_sel_signal : STD_LOGIC_VECTOR(1 downto 0);
    
begin
    -- Constant for SP initialization
    sp_init_value <= std_logic_vector(to_unsigned(262143, 32));  -- 2^18 - 1
    
    -- ==================== PC Path ====================
    
    -- PC Register
    PC_Reg: PC_Register
        port map (
            clk => clk,
            rst => rst,
            enable => pc_enable,
            pc_in => pc_next,
            pc_out => pc_current
        );
    
    -- PC Adder (PC + 1)
    PC_Add: PC_Adder
        port map (
            pc_in => pc_current,
            pc_plus_1 => pc_incremented
        );
    
    -- PC Mux Control Unit
    PC_Mux_Ctrl: PC_Mux_Control
        port map (
            opcode => opcode,
            branch_condition => branch_condition,
            pc_mux_sel => pc_mux_sel_signal
        );
    
    -- PC Mux
    PC_Multiplexer: PC_Mux
        port map (
            pc_plus_1 => pc_incremented,
            pc_plus_1_ifid => pc_plus_1_from_ifid,
            pc_from_memory => pc_from_memory,
            pc_from_alu => pc_from_alu,
            sel => pc_mux_sel_signal,
            pc_out => pc_next
        );
    
    -- ==================== SP Path ====================
    
    -- SP Register
    SP_Reg: SP_Register
        port map (
            clk => clk,
            rst => rst,
            enable => sp_enable,
            sp_in => sp_next,
            sp_out => sp_current
        );
    
    -- SP Adder (SP + 1 and SP - 1)
    SP_Add: SP_Adder
        port map (
            sp_in => sp_current,
            sp_plus_1 => sp_plus_1,
            sp_minus_1 => sp_minus_1
        );
    
    -- SP Mux Control Unit
    SP_Mux_Ctrl: SP_Mux_Control
        port map (
            opcode => opcode,
            push_signal => push_signal,
            pop_signal => pop_signal,
            reset_signal => rst,
            sp_mux_sel => sp_mux_sel_signal
        );
    
    -- SP Mux
    SP_Multiplexer: SP_Mux
        port map (
            sp_plus_1 => sp_plus_1,
            sp_minus_1 => sp_minus_1,
            sp_init => sp_init_value,
            sel => sp_mux_sel_signal,
            sp_out => sp_next
        );
    
    -- ==================== Memory Path ====================
    
    -- Memory Address Mux Control Unit
    Mem_Addr_Mux_Ctrl: Memory_Address_Mux_Control
        port map (
            opcode => opcode,
            mem_operation => mem_operation,
            is_stack_op => is_stack_op,
            mem_addr_mux_sel => mem_addr_mux_sel_signal
        );
    
    -- Memory Address Mux
    Mem_Addr_Mux: Memory_Address_Mux
        port map (
            pc_addr => pc_current,
            sp_addr => sp_current,
            sp_plus_1_addr => sp_plus_1,
            alu_addr => alu_addr,
            alu_plus_2_addr => alu_plus_2_addr,
            sel => mem_addr_mux_sel_signal,
            mem_addr_out => internal_mem_address
        );
    
    -- Memory Write Data Mux Control Unit
    Mem_Write_Data_Mux_Ctrl: Memory_Write_Data_Mux_Control
        port map (
            opcode => opcode,
            is_store => is_store,
            is_call => is_call,
            is_ccr_save => is_ccr_save,
            mem_write_data_mux_sel => mem_write_data_mux_sel_signal
        );
    
    -- Memory Write Data Mux
    Mem_Write_Data_Mux: Memory_Write_Data_Mux
        port map (
            ccr_data => ccr_data,
            pc_plus_1_idex => pc_plus_1_from_idex,
            regfile_data => regfile_data,
            sel => mem_write_data_mux_sel_signal,
            write_data_out => internal_mem_write_data
        );
    
    -- ==================== Memory System Interface ====================
    -- Connect internal signals to memory system interface outputs
    
    -- Fetch interface: PC is used for instruction fetch
    mem_fetch_address <= pc_current;
    mem_fetch_read_enable <= '1';  -- Always reading instructions in fetch stage
    
    -- Data interface: Address and write data from muxes
    mem_data_address <= internal_mem_address;
    mem_data_write_data <= internal_mem_write_data;
    mem_data_write_enable <= '0';  -- Write enable controlled by memory stage, not fetch
    
    -- ==================== IF/ID Pipeline Register ====================
    
    IFID_Reg: IF_ID_Register
        port map (
            clk => clk,
            rst => rst,
            enable => ifid_enable,
            flush => ifid_flush,
            instruction_in => mem_fetch_read_data,  -- From memory system fetch interface
            pc_plus_1_in => pc_incremented,
            instruction_out => instruction_out,
            pc_plus_1_out => pc_plus_1_out
        );
    
end Structural;
