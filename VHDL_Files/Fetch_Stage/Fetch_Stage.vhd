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
        ifid_enable : in STD_LOGIC;
        ifid_flush : in STD_LOGIC;
        
        -- Control Signals to PC_CU
        int_load_pc : in STD_LOGIC;                         -- Load PC from memory
        is_ret : in STD_LOGIC;                         -- Load PC  return address from memory
        rti_load_pc : in STD_LOGIC;                      -- Load PC  return address from memory
        is_call : in STD_LOGIC;                             -- Call instruction
        is_conditional_jump : in STD_LOGIC;                  -- Conditional jump instruction
        is_unconditional_jump : in STD_LOGIC;               -- Unconditional jump instruction


        -- Immediate values from decode stage
        immediate_decode : in STD_LOGIC_VECTOR(31 downto 0); -- Immediate from decode (conditional jump)
        
        -- ALU/Immediate input
        alu_immediate : in STD_LOGIC_VECTOR(31 downto 0);   -- From ALU (for CALL)
        
        -- Memory System Interface (to unified memory)
        pc_out : out STD_LOGIC_VECTOR(31 downto 0);         -- PC to memory address mux
        mem_read_data : in STD_LOGIC_VECTOR(31 downto 0);   -- Data from memory
        
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
    
    component PC_Mux is
        Port (
            pc_plus_1 : in STD_LOGIC_VECTOR(31 downto 0);          -- 00: Normal increment
            immediate_ifid : in STD_LOGIC_VECTOR(31 downto 0);     -- 01: Conditional jump (from IF/ID)
            mem_data : in STD_LOGIC_VECTOR(31 downto 0);           -- 10: Memory (RET/Reset/INT/Uncond)
            alu_result : in STD_LOGIC_VECTOR(31 downto 0);         -- 11: ALU result (CALL from EX/MEM)
            sel : in STD_LOGIC_VECTOR(1 downto 0);
            pc_out : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component PC_Adder is
        Port (
            pc_in : in STD_LOGIC_VECTOR(31 downto 0);
            pc_plus_1 : out STD_LOGIC_VECTOR(31 downto 0)
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
    
    -- Control Unit Components
    component PC_Mux_Control is
        Port (
            int_load_pc : in STD_LOGIC;
            rti_load_pc : in STD_LOGIC;
            is_call : in STD_LOGIC;
            is_conditional_jump : in STD_LOGIC;
            is_ret : in STD_LOGIC;
            is_unconditional_jump : in STD_LOGIC;
            rst : in STD_LOGIC;
            
            -- Output
            pc_mux_sel : out STD_LOGIC_VECTOR(1 downto 0)
        );
    end component;
    
    -- Internal Signals
    signal pc_current : STD_LOGIC_VECTOR(31 downto 0);
    signal pc_next : STD_LOGIC_VECTOR(31 downto 0);
    signal pc_incremented : STD_LOGIC_VECTOR(31 downto 0);
    signal pc_mux_sel_signal : STD_LOGIC_VECTOR(1 downto 0);
    
begin
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
    -- Note: Memory is 32-bit word addressable, so PC + 1 means next word
    PC_Add: PC_Adder
        port map (
            pc_in => pc_current,
            pc_plus_1 => pc_incremented
        );
    
    -- PC Mux Control Unit
    -- Receives control signals from INT_CU, RET_CU, and main CU
    -- Selects appropriate PC source
    PC_Mux_Ctrl: PC_Mux_Control
        port map (
            int_load_pc => int_load_pc,
            rti_load_pc => rti_load_pc,
            is_call => is_call,
            is_conditional_jump => is_conditional_jump,
            is_ret => is_ret,
            is_unconditional_jump => is_unconditional_jump,
            rst => rst,
            pc_mux_sel => pc_mux_sel_signal
        );
    
    PC_Multiplexer: PC_Mux
        port map (
            pc_plus_1 => pc_incremented,
            immediate_ifid => immediate_decode,
            mem_data => mem_read_data,              -- Data from unified memory
            alu_result => alu_immediate,
            sel => pc_mux_sel_signal,
            pc_out => pc_next
        );
    
    -- ==================== Memory System Interface ====================
    -- Output PC to unified memory system
    -- The Memory_Address_Mux will decide when to use PC vs other addresses
    pc_out <= pc_current;
    
    -- ==================== IF/ID Pipeline Register ====================
    
    IFID_Reg: IF_ID_Register
        port map (
            clk => clk,
            rst => rst,
            enable => ifid_enable,
            flush => ifid_flush,
            instruction_in => mem_read_data,        -- Instruction from unified memory
            pc_plus_1_in => pc_incremented,         -- PC + 1 for next instruction
            instruction_out => instruction_out,
            pc_plus_1_out => pc_plus_1_out
        );
    
end Structural;
