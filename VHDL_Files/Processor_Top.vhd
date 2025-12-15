library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Top-level processor integration
-- Integrates Fetch Stage, IF/ID Pipeline Register, Decode Stage, and ID/EX Pipeline Register
entity Processor_Top is
    Port (
        -- Clock and Reset
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        
        -- Control Signals
        pc_enable : in STD_LOGIC;
        ifid_enable : in STD_LOGIC;
        ifid_flush : in STD_LOGIC;
        
        -- Memory System Interface
        mem_address : out STD_LOGIC_VECTOR(31 downto 0);
        mem_read_data : in STD_LOGIC_VECTOR(31 downto 0);
        
        -- From Execute/Memory stages (for PC control)
        int_load_pc : in STD_LOGIC;
        is_ret : in STD_LOGIC;
        rti_load_pc : in STD_LOGIC;
        is_call : in STD_LOGIC;
        is_conditional_jump : in STD_LOGIC;
        is_unconditional_jump : in STD_LOGIC;
        immediate_decode : in STD_LOGIC_VECTOR(31 downto 0);
        alu_immediate : in STD_LOGIC_VECTOR(31 downto 0);
        
        -- From Writeback Stage
        wb_write_enable : in STD_LOGIC;
        wb_write_reg : in STD_LOGIC_VECTOR(2 downto 0);
        wb_write_data : in STD_LOGIC_VECTOR(31 downto 0);
        
        -- Pipeline control
        previous_is_immediate : in STD_LOGIC;
        
        -- ID/EX Stage Outputs (to Execute Stage)
        pc_ex : out STD_LOGIC_VECTOR(31 downto 0);
        read_data1_ex : out STD_LOGIC_VECTOR(31 downto 0);
        read_data2_ex : out STD_LOGIC_VECTOR(31 downto 0);
        read_reg1_ex : out STD_LOGIC_VECTOR(2 downto 0);
        write_reg_ex : out STD_LOGIC_VECTOR(2 downto 0);
        mem_write_ex : out STD_LOGIC;
        mem_read_ex : out STD_LOGIC;
        mem_to_reg_ex : out STD_LOGIC;
        alu_op_ex : out STD_LOGIC_VECTOR(3 downto 0);
        out_enable_ex : out STD_LOGIC;
        ccr_in_ex : out STD_LOGIC_VECTOR(1 downto 0);
        is_swap_ex : out STD_LOGIC;
        swap_phase_ex : out STD_LOGIC;
        reg_write_ex : out STD_LOGIC;
        is_immediate_ex : out STD_LOGIC;
        is_call_ex : out STD_LOGIC;
        hlt_ex : out STD_LOGIC;
        is_int_ex : out STD_LOGIC;
        is_in_ex : out STD_LOGIC;
        is_pop_ex : out STD_LOGIC;
        is_push_ex : out STD_LOGIC;
        int_phase_ex : out STD_LOGIC;
        is_rti_ex : out STD_LOGIC;
        rti_phase_ex : out STD_LOGIC;
        is_ret_ex : out STD_LOGIC;
        branchZ_ex : out STD_LOGIC;
        branchC_ex : out STD_LOGIC;
        branchN_ex : out STD_LOGIC
    );
end Processor_Top;

architecture Structural of Processor_Top is
    
    component Fetch_Stage is
        Port (
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            pc_enable : in STD_LOGIC;
            ifid_enable : in STD_LOGIC;
            ifid_flush : in STD_LOGIC;
            int_load_pc : in STD_LOGIC;
            is_ret : in STD_LOGIC;
            rti_load_pc : in STD_LOGIC;
            is_call : in STD_LOGIC;
            is_conditional_jump : in STD_LOGIC;
            is_unconditional_jump : in STD_LOGIC;
            immediate_decode : in STD_LOGIC_VECTOR(31 downto 0);
            alu_immediate : in STD_LOGIC_VECTOR(31 downto 0);
            pc_out : out STD_LOGIC_VECTOR(31 downto 0);
            mem_read_data : in STD_LOGIC_VECTOR(31 downto 0);
            instruction_fetch : out STD_LOGIC_VECTOR(31 downto 0);
            pc_plus_1_fetch : out STD_LOGIC_VECTOR(31 downto 0)
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
    
    component decode_stage is
        Port (
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            instruction : in STD_LOGIC_VECTOR(31 downto 0);
            pc_in_plus_1 : in STD_LOGIC_VECTOR(31 downto 0);
            wb_write_enable : in STD_LOGIC;
            wb_write_reg : in STD_LOGIC_VECTOR(2 downto 0);
            wb_write_data : in STD_LOGIC_VECTOR(31 downto 0);
            previous_is_immediate : in STD_LOGIC;
            read_data1 : out STD_LOGIC_VECTOR(31 downto 0);
            read_data2 : out STD_LOGIC_VECTOR(31 downto 0);
            opcode : out STD_LOGIC_VECTOR(6 downto 0);
            rd : out STD_LOGIC_VECTOR(2 downto 0);
            rs1 : out STD_LOGIC_VECTOR(2 downto 0);
            rs2 : out STD_LOGIC_VECTOR(2 downto 0);
            mem_write : out STD_LOGIC;
            mem_read : out STD_LOGIC;
            mem_to_reg : out STD_LOGIC;
            alu_op : out STD_LOGIC_VECTOR(3 downto 0);
            out_enable : out STD_LOGIC;
            ccr_in : out STD_LOGIC_VECTOR(1 downto 0);
            is_swap : out STD_LOGIC;
            swap_phase : out STD_LOGIC;
            reg_write : out STD_LOGIC;
            is_immediate : out STD_LOGIC;
            is_call : out STD_LOGIC;
            hlt : out STD_LOGIC;
            is_int : out STD_LOGIC;
            is_in : out STD_LOGIC;
            is_pop : out STD_LOGIC;
            is_push : out STD_LOGIC;
            int_phase : out STD_LOGIC;
            is_rti : out STD_LOGIC;
            rti_phase : out STD_LOGIC;
            is_ret : out STD_LOGIC;
            branchZ : out STD_LOGIC;
            branchC : out STD_LOGIC;
            branchN : out STD_LOGIC;
            unconditional_branch : out STD_LOGIC;
            pc_out_plus_1 : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component ID_EX_register is
        Port (
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            hlt : in STD_LOGIC;
            pc_in_plus_1 : in STD_LOGIC_VECTOR(31 downto 0);
            read_data1_in : in STD_LOGIC_VECTOR(31 downto 0);
            read_data2_in : in STD_LOGIC_VECTOR(31 downto 0);
            read_reg1_in : in STD_LOGIC_VECTOR(2 downto 0);
            write_reg_in : in STD_LOGIC_VECTOR(2 downto 0);
            mem_write_in : in STD_LOGIC;
            mem_read_in : in STD_LOGIC;
            mem_to_reg_in : in STD_LOGIC;
            alu_op_in : in STD_LOGIC_VECTOR(3 downto 0);
            out_enable_in : in STD_LOGIC;
            ccr_in_in : in STD_LOGIC_VECTOR(1 downto 0);
            is_swap_in : in STD_LOGIC;
            swap_phase_in : in STD_LOGIC;
            reg_write_in : in STD_LOGIC;
            is_immediate_in : in STD_LOGIC;
            is_call_in : in STD_LOGIC;
            hlt_in : in STD_LOGIC;
            is_int_in : in STD_LOGIC;
            is_in_in : in STD_LOGIC;
            is_pop_in : in STD_LOGIC;
            is_push_in : in STD_LOGIC;
            int_phase_in : in STD_LOGIC;
            is_rti_in : in STD_LOGIC;
            rti_phase_in : in STD_LOGIC;
            is_ret_in : in STD_LOGIC;
            branchZ_in : in STD_LOGIC;
            branchC_in : in STD_LOGIC;
            branchN_in : in STD_LOGIC;
            pc_out_plus_1 : out STD_LOGIC_VECTOR(31 downto 0);
            read_data1_out : out STD_LOGIC_VECTOR(31 downto 0);
            read_data2_out : out STD_LOGIC_VECTOR(31 downto 0);
            read_reg1_out : out STD_LOGIC_VECTOR(2 downto 0);
            write_reg_out : out STD_LOGIC_VECTOR(2 downto 0);
            mem_write_out : out STD_LOGIC;
            mem_read_out : out STD_LOGIC;
            mem_to_reg_out : out STD_LOGIC;
            alu_op_out : out STD_LOGIC_VECTOR(3 downto 0);
            out_enable_out : out STD_LOGIC;
            ccr_in_out : out STD_LOGIC_VECTOR(1 downto 0);
            is_swap_out : out STD_LOGIC;
            swap_phase_out : out STD_LOGIC;
            reg_write_out : out STD_LOGIC;
            is_immediate_out : out STD_LOGIC;
            is_call_out : out STD_LOGIC;
            hlt_out : out STD_LOGIC;
            is_int_out : out STD_LOGIC;
            is_in_out : out STD_LOGIC;
            is_pop_out : out STD_LOGIC;
            is_push_out : out STD_LOGIC;
            int_phase_out : out STD_LOGIC;
            is_rti_out : out STD_LOGIC;
            rti_phase_out : out STD_LOGIC;
            is_ret_out : out STD_LOGIC;
            branchZ_out : out STD_LOGIC;
            branchC_out : out STD_LOGIC;
            branchN_out : out STD_LOGIC
        );
    end component;
    
    -- Signals between Fetch and IF/ID
    signal instruction_fetch_signal : STD_LOGIC_VECTOR(31 downto 0);
    signal pc_plus_1_fetch_signal : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Signals between IF/ID and Decode
    signal instruction_decode_signal : STD_LOGIC_VECTOR(31 downto 0);
    signal pc_plus_1_decode_signal : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Signals between Decode and ID/EX (outputs from Decode Stage)
    signal read_data1_decode : STD_LOGIC_VECTOR(31 downto 0);
    signal read_data2_decode : STD_LOGIC_VECTOR(31 downto 0);
    signal opcode_decode : STD_LOGIC_VECTOR(6 downto 0);
    signal rd_decode : STD_LOGIC_VECTOR(2 downto 0);
    signal rs1_decode : STD_LOGIC_VECTOR(2 downto 0);
    signal rs2_decode : STD_LOGIC_VECTOR(2 downto 0);
    signal mem_write_decode : STD_LOGIC;
    signal mem_read_decode : STD_LOGIC;
    signal mem_to_reg_decode : STD_LOGIC;
    signal alu_op_decode : STD_LOGIC_VECTOR(3 downto 0);
    signal out_enable_decode : STD_LOGIC;
    signal ccr_in_decode : STD_LOGIC_VECTOR(1 downto 0);
    signal is_swap_decode : STD_LOGIC;
    signal swap_phase_decode : STD_LOGIC;
    signal reg_write_decode : STD_LOGIC;
    signal is_immediate_decode : STD_LOGIC;
    signal is_call_decode : STD_LOGIC;
    signal hlt_decode : STD_LOGIC;
    signal is_int_decode : STD_LOGIC;
    signal is_in_decode : STD_LOGIC;
    signal is_pop_decode : STD_LOGIC;
    signal is_push_decode : STD_LOGIC;
    signal int_phase_decode : STD_LOGIC;
    signal is_rti_decode : STD_LOGIC;
    signal rti_phase_decode : STD_LOGIC;
    signal is_ret_decode : STD_LOGIC;
    signal branchZ_decode : STD_LOGIC;
    signal branchC_decode : STD_LOGIC;
    signal branchN_decode : STD_LOGIC;
    signal unconditional_branch_decode : STD_LOGIC;
    signal pc_plus_1_from_decode : STD_LOGIC_VECTOR(31 downto 0);
    
begin
    
    Fetch: Fetch_Stage
        port map (
            clk => clk,
            rst => rst,
            pc_enable => pc_enable,
            ifid_enable => ifid_enable,
            ifid_flush => ifid_flush,
            int_load_pc => int_load_pc,
            is_ret => is_ret,
            rti_load_pc => rti_load_pc,
            is_call => is_call,
            is_conditional_jump => is_conditional_jump,
            is_unconditional_jump => is_unconditional_jump,
            immediate_decode => immediate_decode,
            alu_immediate => alu_immediate,
            pc_out => mem_address,
            mem_read_data => mem_read_data,
            instruction_fetch => instruction_fetch_signal,
            pc_plus_1_fetch => pc_plus_1_fetch_signal
        );
    
    IFID_Reg: IF_ID_Register
        port map (
            clk => clk,
            rst => rst,
            enable => ifid_enable,
            flush => ifid_flush,
            instruction_in => instruction_fetch_signal,
            pc_plus_1_in => pc_plus_1_fetch_signal,
            instruction_out => instruction_decode_signal,
            pc_plus_1_out => pc_plus_1_decode_signal
        );
    
    Decode: decode_stage
        port map (
            clk => clk,
            rst => rst,
            instruction => instruction_decode_signal,
            pc_in_plus_1 => pc_plus_1_decode_signal,
            wb_write_enable => wb_write_enable,
            wb_write_reg => wb_write_reg,
            wb_write_data => wb_write_data,
            previous_is_immediate => previous_is_immediate,
            read_data1 => read_data1_decode,
            read_data2 => read_data2_decode,
            opcode => opcode_decode,
            rd => rd_decode,
            rs1 => rs1_decode,
            rs2 => rs2_decode,
            mem_write => mem_write_decode,
            mem_read => mem_read_decode,
            mem_to_reg => mem_to_reg_decode,
            alu_op => alu_op_decode,
            out_enable => out_enable_decode,
            ccr_in => ccr_in_decode,
            is_swap => is_swap_decode,
            swap_phase => swap_phase_decode,
            reg_write => reg_write_decode,
            is_immediate => is_immediate_decode,
            is_call => is_call_decode,
            hlt => hlt_decode,
            is_int => is_int_decode,
            is_in => is_in_decode,
            is_pop => is_pop_decode,
            is_push => is_push_decode,
            int_phase => int_phase_decode,
            is_rti => is_rti_decode,
            rti_phase => rti_phase_decode,
            is_ret => is_ret_decode,
            branchZ => branchZ_decode,
            branchC => branchC_decode,
            branchN => branchN_decode,
            unconditional_branch => unconditional_branch_decode,
            pc_out_plus_1 => pc_plus_1_from_decode
        );
    
    -- ==================== ID/EX Pipeline Register ====================
    IDEX_Reg: ID_EX_register
        port map (
            clk => clk,
            rst => rst,
            hlt => hlt_decode,
            pc_in_plus_1 => pc_plus_1_from_decode,
            read_data1_in => read_data1_decode,
            read_data2_in => read_data2_decode,
            read_reg1_in => rs1_decode,
            write_reg_in => rd_decode,
            mem_write_in => mem_write_decode,
            mem_read_in => mem_read_decode,
            mem_to_reg_in => mem_to_reg_decode,
            alu_op_in => alu_op_decode,
            out_enable_in => out_enable_decode,
            ccr_in_in => ccr_in_decode,
            is_swap_in => is_swap_decode,
            swap_phase_in => swap_phase_decode,
            reg_write_in => reg_write_decode,
            is_immediate_in => is_immediate_decode,
            is_call_in => is_call_decode,
            hlt_in => hlt_decode,
            is_int_in => is_int_decode,
            is_in_in => is_in_decode,
            is_pop_in => is_pop_decode,
            is_push_in => is_push_decode,
            int_phase_in => int_phase_decode,
            is_rti_in => is_rti_decode,
            rti_phase_in => rti_phase_decode,
            is_ret_in => is_ret_decode,
            branchZ_in => branchZ_decode,
            branchC_in => branchC_decode,
            branchN_in => branchN_decode,
            pc_out_plus_1 => pc_ex,
            read_data1_out => read_data1_ex,
            read_data2_out => read_data2_ex,
            read_reg1_out => read_reg1_ex,
            write_reg_out => write_reg_ex,
            mem_write_out => mem_write_ex,
            mem_read_out => mem_read_ex,
            mem_to_reg_out => mem_to_reg_ex,
            alu_op_out => alu_op_ex,
            out_enable_out => out_enable_ex,
            ccr_in_out => ccr_in_ex,
            is_swap_out => is_swap_ex,
            swap_phase_out => swap_phase_ex,
            reg_write_out => reg_write_ex,
            is_immediate_out => is_immediate_ex,
            is_call_out => is_call_ex,
            hlt_out => hlt_ex,
            is_int_out => is_int_ex,
            is_in_out => is_in_ex,
            is_pop_out => is_pop_ex,
            is_push_out => is_push_ex,
            int_phase_out => int_phase_ex,
            is_rti_out => is_rti_ex,
            rti_phase_out => rti_phase_ex,
            is_ret_out => is_ret_ex,
            branchZ_out => branchZ_ex,
            branchC_out => branchC_ex,
            branchN_out => branchN_ex
        );
    
end Structural;
