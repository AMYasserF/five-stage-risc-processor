-- vhdl-linter-disable type-resolved
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
        
        -- Immediate value from IF/ID for Execute Stage
        if_id_immediate : in STD_LOGIC_VECTOR(31 downto 0);
        
        -- Forwarding Unit inputs (external until forwarding unit is created)
        forward_ex_mem : in STD_LOGIC_VECTOR(31 downto 0);
        forward_mem_wb : in STD_LOGIC_VECTOR(31 downto 0);
        forward_mux_a_sel : in STD_LOGIC_VECTOR(1 downto 0);
        forward_mux_b_sel : in STD_LOGIC_VECTOR(1 downto 0);
        
        -- Outputs from Execute Stage to EX/MEM
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
        
        -- Direct outputs from Execute Stage
        conditional_jump : out STD_LOGIC;
        pc_plus_2 : out STD_LOGIC_VECTOR(31 downto 0)
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
            rd : out STD_LOGIC_VECTOR(2 downto 0);
            rs1 : out STD_LOGIC_VECTOR(2 downto 0);
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
    
    component Execute_Stage is
        Port (
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            id_ex_read_data1 : in STD_LOGIC_VECTOR(31 downto 0);
            id_ex_read_data2 : in STD_LOGIC_VECTOR(31 downto 0);
            id_ex_pc_plus_1 : in STD_LOGIC_VECTOR(31 downto 0);
            id_ex_read_reg1 : in STD_LOGIC_VECTOR(2 downto 0);
            id_ex_write_reg : in STD_LOGIC_VECTOR(2 downto 0);
            id_ex_mem_write : in STD_LOGIC;
            id_ex_mem_read : in STD_LOGIC;
            id_ex_mem_to_reg : in STD_LOGIC;
            id_ex_alu_op : in STD_LOGIC_VECTOR(3 downto 0);
            id_ex_out_enable : in STD_LOGIC;
            id_ex_ccr_in : in STD_LOGIC_VECTOR(1 downto 0);
            id_ex_is_swap : in STD_LOGIC;
            id_ex_swap_phase : in STD_LOGIC;
            id_ex_reg_write : in STD_LOGIC;
            id_ex_is_immediate : in STD_LOGIC;
            id_ex_is_call : in STD_LOGIC;
            id_ex_is_ret : in STD_LOGIC;
            id_ex_is_push : in STD_LOGIC;
            id_ex_is_pop : in STD_LOGIC;
            id_ex_is_in : in STD_LOGIC;
            id_ex_hlt : in STD_LOGIC;
            id_ex_is_int : in STD_LOGIC;
            id_ex_int_phase : in STD_LOGIC;
            id_ex_is_rti : in STD_LOGIC;
            id_ex_rti_phase : in STD_LOGIC;
            id_ex_branchZ : in STD_LOGIC;
            id_ex_branchC : in STD_LOGIC;
            id_ex_branchN : in STD_LOGIC;
            if_id_immediate : in STD_LOGIC_VECTOR(31 downto 0);
            forward_ex_mem : in STD_LOGIC_VECTOR(31 downto 0);
            forward_mem_wb : in STD_LOGIC_VECTOR(31 downto 0);
            forward_mux_a_sel : in STD_LOGIC_VECTOR(1 downto 0);
            forward_mux_b_sel : in STD_LOGIC_VECTOR(1 downto 0);
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
    
    -- Signals between Fetch and IF/ID
    signal instruction_fetch_signal : STD_LOGIC_VECTOR(31 downto 0);
    signal pc_plus_1_fetch_signal : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Signals between IF/ID and Decode
    signal instruction_decode_signal : STD_LOGIC_VECTOR(31 downto 0);
    signal pc_plus_1_decode_signal : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Signals between Decode and ID/EX (outputs from Decode Stage)
    signal read_data1_decode : STD_LOGIC_VECTOR(31 downto 0);
    signal read_data2_decode : STD_LOGIC_VECTOR(31 downto 0);
    signal rd_decode : STD_LOGIC_VECTOR(2 downto 0);
    signal rs1_decode : STD_LOGIC_VECTOR(2 downto 0);
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
    
    -- Signals from ID/EX to Execute Stage
    signal idex_pc_plus_1 : STD_LOGIC_VECTOR(31 downto 0);
    signal idex_read_data1 : STD_LOGIC_VECTOR(31 downto 0);
    signal idex_read_data2 : STD_LOGIC_VECTOR(31 downto 0);
    signal idex_read_reg1 : STD_LOGIC_VECTOR(2 downto 0);
    signal idex_write_reg : STD_LOGIC_VECTOR(2 downto 0);
    signal idex_mem_write : STD_LOGIC;
    signal idex_mem_read : STD_LOGIC;
    signal idex_mem_to_reg : STD_LOGIC;
    signal idex_alu_op : STD_LOGIC_VECTOR(3 downto 0);
    signal idex_out_enable : STD_LOGIC;
    signal idex_ccr_in : STD_LOGIC_VECTOR(1 downto 0);
    signal idex_is_swap : STD_LOGIC;
    signal idex_swap_phase : STD_LOGIC;
    signal idex_reg_write : STD_LOGIC;
    signal idex_is_immediate : STD_LOGIC;
    signal idex_is_call : STD_LOGIC;
    signal idex_hlt : STD_LOGIC;
    signal idex_is_int : STD_LOGIC;
    signal idex_is_in : STD_LOGIC;
    signal idex_is_pop : STD_LOGIC;
    signal idex_is_push : STD_LOGIC;
    signal idex_int_phase : STD_LOGIC;
    signal idex_is_rti : STD_LOGIC;
    signal idex_rti_phase : STD_LOGIC;
    signal idex_is_ret : STD_LOGIC;
    signal idex_branchZ : STD_LOGIC;
    signal idex_branchC : STD_LOGIC;
    signal idex_branchN : STD_LOGIC;
    
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
            previous_is_immediate => idex_is_immediate,  -- Feedback from ID/EX register
            read_data1 => read_data1_decode,
            read_data2 => read_data2_decode,
            rd => rd_decode,
            rs1 => rs1_decode,
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
            pc_out_plus_1 => idex_pc_plus_1,
            read_data1_out => idex_read_data1,
            read_data2_out => idex_read_data2,
            read_reg1_out => idex_read_reg1,
            write_reg_out => idex_write_reg,
            mem_write_out => idex_mem_write,
            mem_read_out => idex_mem_read,
            mem_to_reg_out => idex_mem_to_reg,
            alu_op_out => idex_alu_op,
            out_enable_out => idex_out_enable,
            ccr_in_out => idex_ccr_in,
            is_swap_out => idex_is_swap,
            swap_phase_out => idex_swap_phase,
            reg_write_out => idex_reg_write,
            is_immediate_out => idex_is_immediate,
            is_call_out => idex_is_call,
            hlt_out => idex_hlt,
            is_int_out => idex_is_int,
            is_in_out => idex_is_in,
            is_pop_out => idex_is_pop,
            is_push_out => idex_is_push,
            int_phase_out => idex_int_phase,
            is_rti_out => idex_is_rti,
            rti_phase_out => idex_rti_phase,
            is_ret_out => idex_is_ret,
            branchZ_out => idex_branchZ,
            branchC_out => idex_branchC,
            branchN_out => idex_branchN
        );
    
    -- ==================== Execute Stage ====================
    Execute: Execute_Stage
        port map (
            clk => clk,
            rst => rst,
            id_ex_read_data1 => idex_read_data1,
            id_ex_read_data2 => idex_read_data2,
            id_ex_pc_plus_1 => idex_pc_plus_1,
            id_ex_read_reg1 => idex_read_reg1,
            id_ex_write_reg => idex_write_reg,
            id_ex_mem_write => idex_mem_write,
            id_ex_mem_read => idex_mem_read,
            id_ex_mem_to_reg => idex_mem_to_reg,
            id_ex_alu_op => idex_alu_op,
            id_ex_out_enable => idex_out_enable,
            id_ex_ccr_in => idex_ccr_in,
            id_ex_is_swap => idex_is_swap,
            id_ex_swap_phase => idex_swap_phase,
            id_ex_reg_write => idex_reg_write,
            id_ex_is_immediate => idex_is_immediate,
            id_ex_is_call => idex_is_call,
            id_ex_is_ret => idex_is_ret,
            id_ex_is_push => idex_is_push,
            id_ex_is_pop => idex_is_pop,
            id_ex_is_in => idex_is_in,
            id_ex_hlt => idex_hlt,
            id_ex_is_int => idex_is_int,
            id_ex_int_phase => idex_int_phase,
            id_ex_is_rti => idex_is_rti,
            id_ex_rti_phase => idex_rti_phase,
            id_ex_branchZ => idex_branchZ,
            id_ex_branchC => idex_branchC,
            id_ex_branchN => idex_branchN,
            if_id_immediate => if_id_immediate,
            forward_ex_mem => forward_ex_mem,
            forward_mem_wb => forward_mem_wb,
            forward_mux_a_sel => forward_mux_a_sel,
            forward_mux_b_sel => forward_mux_b_sel,
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
    
end Structural;
