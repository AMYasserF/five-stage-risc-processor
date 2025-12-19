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
        
        -- Memory System Interface (for instruction fetch)
        mem_address : out STD_LOGIC_VECTOR(31 downto 0);
        mem_read_data : in STD_LOGIC_VECTOR(31 downto 0);
        
        -- External control signals (for testing/control)
        is_conditional_jump : in STD_LOGIC;
        is_unconditional_jump : in STD_LOGIC;
        immediate_decode : in STD_LOGIC_VECTOR(31 downto 0);
        alu_immediate : in STD_LOGIC_VECTOR(31 downto 0);
        
        -- Input/Output Ports
        input_port : in STD_LOGIC_VECTOR(31 downto 0);
        output_port : out STD_LOGIC_VECTOR(31 downto 0);
        
        -- Writeback outputs (for testing/debugging)
        wb_write_enable : out STD_LOGIC;
        wb_write_reg : out STD_LOGIC_VECTOR(2 downto 0);
        wb_write_data : out STD_LOGIC_VECTOR(31 downto 0);
        
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
            input_port : in STD_LOGIC_VECTOR(31 downto 0);
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
            ex_mem_input_port_data : out STD_LOGIC_VECTOR(31 downto 0);
            conditional_jump : out STD_LOGIC;
            pc_plus_2 : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component Forwarding_Unit is
        Port (
            ID_EX_RegRs     : in  STD_LOGIC_VECTOR(2 downto 0);
            ID_EX_RegRt     : in  STD_LOGIC_VECTOR(2 downto 0);
            EX_MEM_RegWrite : in  STD_LOGIC;
            EX_MEM_DestReg  : in  STD_LOGIC_VECTOR(2 downto 0);
            EX_MEM_Rsrc1    : in  STD_LOGIC_VECTOR(2 downto 0);
            EX_MEM_is_swap  : in  STD_LOGIC;
            EX_MEM_is_in    : in  STD_LOGIC;
            MEM_WB_RegWrite : in  STD_LOGIC;
            MEM_WB_DestReg  : in  STD_LOGIC_VECTOR(2 downto 0);
            MEM_WB_Rsrc1    : in  STD_LOGIC_VECTOR(2 downto 0);
            MEM_WB_is_swap  : in  STD_LOGIC;
            MEM_WB_is_in    : in  STD_LOGIC;
            MEM_WB_mem_to_reg: in STD_LOGIC;
            ForwardA        : out STD_LOGIC_VECTOR(3 downto 0);
            ForwardB        : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    component Hazard_Detection_Unit is
    port(
        mem_mem_read : in std_logic; --Fetch_Memory use
	    mem_mem_write : in std_logic; --Fetch_Memory use
	    mem_is_pop : in std_logic; --Pop load use
	    mem_rdst : in std_logic_vector(2 downto 0); --Pop load use
	    ex_rsrc1 : in std_logic_vector(2 downto 0); --Pop load use
	    ex_rsrc2 : in std_logic_vector(2 downto 0); --Pop load use
	    ex_is_conditional : in std_logic; --Conditional jump 
	    ex_has_one_operand : in std_logic; --Pop load use
	    ex_has_two_operands : in std_logic; --Pop load use
	    mem_is_int : in std_logic; --Interrupt
	    mem_is_ret : in std_logic; --Return
	    mem_is_rti : in std_logic; --Return interrupt
	    wb_is_swap : in std_logic; --Swap
	    wb_swap_phase : in std_logic; --Swap
	    mem_int_phase : in std_logic_vector(1 downto 0); --Interrupt
	    mem_rti_phase : in std_logic; --Return interrupt
	    if_flush : out std_logic; --Fetch_Memory use / Conditional jump / Return / Interrupt / Return interrupt
	    id_flush : out std_logic; --Return / Interrupt / Return interrupt
	    ex_flush : out std_logic; --Return
	    if_id_enable : out std_logic; --Swap
	    id_ex_enable : out std_logic; --Swap
	    ex_mem_enable : out std_logic; --Pop load use / Swap
	    pc_enable : out std_logic --Fetch_Memory use
    );
    end component;
    
    component EX_MEM_Register is
        Port (
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            ex_rti_phase : in STD_LOGIC;
            ex_int_phase : in STD_LOGIC;
            ex_mem_write : in STD_LOGIC;
            ex_mem_read : in STD_LOGIC;
            ex_mem_to_reg : in STD_LOGIC;
            ex_alu_op : in STD_LOGIC_VECTOR(3 downto 0);
            ex_out_enable : in STD_LOGIC;
            ex_is_swap : in STD_LOGIC;
            ex_swap_phase : in STD_LOGIC;
            ex_reg_write : in STD_LOGIC;
            ex_is_call : in STD_LOGIC;
            ex_is_ret : in STD_LOGIC;
            ex_is_push : in STD_LOGIC;
            ex_is_pop : in STD_LOGIC;
            ex_hlt : in STD_LOGIC;
            ex_is_in : in STD_LOGIC;
            ex_is_int : in STD_LOGIC;
            ex_is_rti : in STD_LOGIC;
            ex_read_reg1 : in STD_LOGIC_VECTOR(2 downto 0);
            ex_write_reg : in STD_LOGIC_VECTOR(2 downto 0);
            ex_read_data2 : in STD_LOGIC_VECTOR(31 downto 0);
            ex_alu_result : in STD_LOGIC_VECTOR(31 downto 0);
            ex_input_port_data : in STD_LOGIC_VECTOR(31 downto 0);
            ex_pc_plus_1 : in STD_LOGIC_VECTOR(31 downto 0);
            mem_rti_phase : out STD_LOGIC;
            mem_int_phase : out STD_LOGIC;
            mem_mem_write : out STD_LOGIC;
            mem_mem_read : out STD_LOGIC;
            mem_mem_to_reg : out STD_LOGIC;
            mem_alu_op : out STD_LOGIC_VECTOR(3 downto 0);
            mem_out_enable : out STD_LOGIC;
            mem_is_swap : out STD_LOGIC;
            mem_swap_phase : out STD_LOGIC;
            mem_reg_write : out STD_LOGIC;
            mem_is_call : out STD_LOGIC;
            mem_is_ret : out STD_LOGIC;
            mem_is_push : out STD_LOGIC;
            mem_is_pop : out STD_LOGIC;
            mem_hlt : out STD_LOGIC;
            mem_is_in : out STD_LOGIC;
            mem_is_int : out STD_LOGIC;
            mem_is_rti : out STD_LOGIC;
            mem_read_reg1 : out STD_LOGIC_VECTOR(2 downto 0);
            mem_write_reg : out STD_LOGIC_VECTOR(2 downto 0);
            mem_read_data2 : out STD_LOGIC_VECTOR(31 downto 0);
            mem_alu_result : out STD_LOGIC_VECTOR(31 downto 0);
            mem_input_port_data : out STD_LOGIC_VECTOR(31 downto 0);
            mem_pc_plus_1 : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component Memory_Stage is
        Port (
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            hlt : in STD_LOGIC;
            is_ret : in STD_LOGIC;
            is_rti : in STD_LOGIC;
            is_int : in STD_LOGIC;
            mem_read : in STD_LOGIC;
            mem_write : in STD_LOGIC;
            is_push : in STD_LOGIC;
            alu_address_enable : in STD_LOGIC;
            mem_to_reg : in STD_LOGIC;
            is_pop : in STD_LOGIC;
            out_enable : in STD_LOGIC;
            is_swap : in STD_LOGIC;
            swap_phase_previous : in STD_LOGIC;
            swap_phase_next : in STD_LOGIC;
            reg_write : in STD_LOGIC;
            is_call : in STD_LOGIC;
            is_input : in STD_LOGIC;
            rdst : in STD_LOGIC_VECTOR(2 downto 0);
            rsrc1 : in STD_LOGIC_VECTOR(2 downto 0);
            rsrc2_data : in STD_LOGIC_VECTOR(31 downto 0);
            alu_result : in STD_LOGIC_VECTOR(31 downto 0);
            pc_data : in STD_LOGIC_VECTOR(31 downto 0);
            ccr_data : in STD_LOGIC_VECTOR(31 downto 0);
            input_port_data : in STD_LOGIC_VECTOR(31 downto 0);
            int_load_pc_out : out STD_LOGIC;
            rti_load_pc_out : out STD_LOGIC;
            is_ret_out : out STD_LOGIC;
            is_rti_out : out STD_LOGIC;
            is_int_out : out STD_LOGIC;
            mem_read_out : out STD_LOGIC;
            mem_write_out : out STD_LOGIC;
            is_push_out : out STD_LOGIC;
            alu_address_out : out STD_LOGIC;
            mem_to_reg_out : out STD_LOGIC;
            is_pop_out : out STD_LOGIC;
            out_enable_out : out STD_LOGIC;
            is_swap_out : out STD_LOGIC;
            swap_phase_out : out STD_LOGIC;
            reg_write_out : out STD_LOGIC;
            is_call_out : out STD_LOGIC;
            is_input_out : out STD_LOGIC;
            rdst_out : out STD_LOGIC_VECTOR(2 downto 0);
            rsrc1_out : out STD_LOGIC_VECTOR(2 downto 0);
            rsrc2_data_out : out STD_LOGIC_VECTOR(31 downto 0);
            alu_result_out : out STD_LOGIC_VECTOR(31 downto 0);
            mem_data_out : out STD_LOGIC_VECTOR(31 downto 0);
            input_port_data_out : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component Mem_Wb_Register is
        Port (
            rst : in STD_LOGIC;
            clk : in STD_LOGIC;
            mem_to_reg : in STD_LOGIC;
            out_enable : in STD_LOGIC;
            is_swap : in STD_LOGIC;
            swap_phase : in STD_LOGIC;
            reg_write : in STD_LOGIC;
            is_input : in STD_LOGIC;
            rdst : in STD_LOGIC_VECTOR(2 downto 0);
            rsrc1 : in STD_LOGIC_VECTOR(2 downto 0);
            r_data2 : in STD_LOGIC_VECTOR(31 downto 0);
            alu_result : in STD_LOGIC_VECTOR(31 downto 0);
            mem_data : in STD_LOGIC_VECTOR(31 downto 0);
            input_port_data : in STD_LOGIC_VECTOR(31 downto 0);
            mem_to_reg_out : out STD_LOGIC;
            out_enable_out : out STD_LOGIC;
            is_swap_out : out STD_LOGIC;
            swap_phase_out : out STD_LOGIC;
            reg_write_out : out STD_LOGIC;
            is_input_out : out STD_LOGIC;
            rdst_out : out STD_LOGIC_VECTOR(2 downto 0);
            rsrc1_out : out STD_LOGIC_VECTOR(2 downto 0);
            r_data2_out : out STD_LOGIC_VECTOR(31 downto 0);
            alu_result_out : out STD_LOGIC_VECTOR(31 downto 0);
            mem_data_out : out STD_LOGIC_VECTOR(31 downto 0);
            input_port_data_out : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component Write_Back is
        Port (
            MemToReg : in STD_LOGIC;
            Is_Input : in STD_LOGIC;
            Is_Output : in STD_LOGIC;
            Is_Swap : in STD_LOGIC;
            Swap_Phase : in STD_LOGIC;
            Rdst : in STD_LOGIC_VECTOR(2 downto 0);
            Rsrc1 : in STD_LOGIC_VECTOR(2 downto 0);
            R_data2 : in STD_LOGIC_VECTOR(31 downto 0);
            ALU_Result : in STD_LOGIC_VECTOR(31 downto 0);
            Mem_Result : in STD_LOGIC_VECTOR(31 downto 0);
            Input_Port_Data : in STD_LOGIC_VECTOR(31 downto 0);
            Output_Port_Data : out STD_LOGIC_VECTOR(31 downto 0);
            Write_Back_Data : out STD_LOGIC_VECTOR(31 downto 0);
            Write_Back_Register : out STD_LOGIC_VECTOR(2 downto 0);
            Swap_Phase_Next : out STD_LOGIC
        );
    end component;
    
    component Input_Port_Register is
        Port (
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            data_in : in STD_LOGIC_VECTOR(31 downto 0);
            data_out : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component Output_Port_Register is
        Port (
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            enable : in STD_LOGIC;
            data_in : in STD_LOGIC_VECTOR(31 downto 0);
            data_out : out STD_LOGIC_VECTOR(31 downto 0)
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
    
    -- Signals from EX/MEM to Memory Stage
    signal exmem_rti_phase : STD_LOGIC;
    signal exmem_int_phase : STD_LOGIC;
    signal exmem_mem_write : STD_LOGIC;
    signal exmem_mem_read : STD_LOGIC;
    signal exmem_mem_to_reg : STD_LOGIC;
    signal exmem_alu_op : STD_LOGIC_VECTOR(3 downto 0);
    signal exmem_out_enable : STD_LOGIC;
    signal exmem_is_swap : STD_LOGIC;
    signal exmem_swap_phase : STD_LOGIC;
    signal exmem_reg_write : STD_LOGIC;
    signal exmem_is_call : STD_LOGIC;
    signal exmem_is_ret : STD_LOGIC;
    signal exmem_is_push : STD_LOGIC;
    signal exmem_is_pop : STD_LOGIC;
    signal exmem_hlt : STD_LOGIC;
    signal exmem_is_in : STD_LOGIC;
    signal exmem_is_int : STD_LOGIC;
    signal exmem_is_rti : STD_LOGIC;
    signal exmem_read_reg1 : STD_LOGIC_VECTOR(2 downto 0);
    signal exmem_write_reg : STD_LOGIC_VECTOR(2 downto 0);
    signal exmem_read_data2 : STD_LOGIC_VECTOR(31 downto 0);
    signal exmem_alu_result : STD_LOGIC_VECTOR(31 downto 0);
    signal exmem_input_port_data : STD_LOGIC_VECTOR(31 downto 0);
    signal exmem_pc_plus_1 : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Signals from Execute Stage outputs (before EX/MEM register)
    signal execute_input_port_data : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Signals from Memory Stage to MEM/WB
    signal mem_is_ret : STD_LOGIC;
    signal mem_is_rti : STD_LOGIC;
    signal mem_is_int : STD_LOGIC;
    signal mem_mem_read : STD_LOGIC;
    signal mem_mem_write : STD_LOGIC;
    signal mem_is_push : STD_LOGIC;
    signal mem_alu_address : STD_LOGIC;
    signal mem_mem_to_reg : STD_LOGIC;
    signal mem_is_pop : STD_LOGIC;
    signal mem_out_enable : STD_LOGIC;
    signal mem_is_swap : STD_LOGIC;
    signal mem_swap_phase : STD_LOGIC;
    signal mem_reg_write : STD_LOGIC;
    signal mem_is_call : STD_LOGIC;
    signal mem_is_input : STD_LOGIC;
    signal mem_rdst : STD_LOGIC_VECTOR(2 downto 0);
    signal mem_rsrc1 : STD_LOGIC_VECTOR(2 downto 0);
    signal mem_rsrc2_data : STD_LOGIC_VECTOR(31 downto 0);
    signal mem_alu_result : STD_LOGIC_VECTOR(31 downto 0);
    signal mem_data : STD_LOGIC_VECTOR(31 downto 0);
    signal mem_input_port_data : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Signals from MEM/WB to Writeback Stage
    signal memwb_mem_to_reg : STD_LOGIC;
    signal memwb_out_enable : STD_LOGIC;
    signal memwb_is_swap : STD_LOGIC;
    signal memwb_swap_phase : STD_LOGIC;
    signal memwb_reg_write : STD_LOGIC;
    signal memwb_is_input : STD_LOGIC;
    signal memwb_rdst : STD_LOGIC_VECTOR(2 downto 0);
    signal memwb_rsrc1 : STD_LOGIC_VECTOR(2 downto 0);
    signal memwb_r_data2 : STD_LOGIC_VECTOR(31 downto 0);
    signal memwb_alu_result : STD_LOGIC_VECTOR(31 downto 0);
    signal memwb_mem_data : STD_LOGIC_VECTOR(31 downto 0);
    signal memwb_input_port_data : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Signals from Writeback Stage
    signal wb_output_port_data : STD_LOGIC_VECTOR(31 downto 0);
    signal wb_write_back_data : STD_LOGIC_VECTOR(31 downto 0);
    signal wb_write_back_register : STD_LOGIC_VECTOR(2 downto 0);
    signal wb_swap_phase_next : STD_LOGIC;
    
    -- Additional signals needed
    signal ccr_register : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');  -- CCR register placeholder
    signal int_load_pc_internal : STD_LOGIC;
    signal rti_load_pc_internal : STD_LOGIC;
    
    -- Forwarding Unit signals
    signal forward_a : STD_LOGIC_VECTOR(3 downto 0);
    signal forward_b : STD_LOGIC_VECTOR(3 downto 0);
    signal forward_ex_mem_data : STD_LOGIC_VECTOR(31 downto 0);
    signal forward_mem_wb_data : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Input/Output Port signals
    signal input_port_registered : STD_LOGIC_VECTOR(31 downto 0);  -- Registered input
    signal output_port_registered : STD_LOGIC_VECTOR(31 downto 0); -- Registered output
    signal output_port_enable : STD_LOGIC; -- Enable for output register
    
    signal unused : STD_LOGIC := '0';
    signal unused_2bits : STD_LOGIC := "00";
    signal unused_3bits : STD_LOGIC_VECTOR(2 downto 0) := "000";
    
begin
    
    -- Connect writeback outputs
    wb_write_enable <= memwb_reg_write;
    wb_write_reg <= wb_write_back_register;
    wb_write_data <= wb_write_back_data;
    
    -- Output port gets value from output register
    output_port <= output_port_registered;
    
    -- Output port enable when OUT instruction reaches writeback
    output_port_enable <= memwb_out_enable;
    
    -- Forwarding data selection for EX/MEM stage
    -- Select appropriate data based on forwarding control signals
    process(forward_a, forward_b, exmem_alu_result, exmem_read_data2, exmem_input_port_data)
    begin
        -- Default to ALU result for EX/MEM forwarding
        forward_ex_mem_data <= exmem_alu_result;
        
        -- Check if any forwarding from EX/MEM is needed (codes 0001-0100)
        if (forward_a = "0001" or forward_b = "0001") then
            -- 0001: Forward EX/MEM ALU result
            forward_ex_mem_data <= exmem_alu_result;
        elsif (forward_a = "0010" or forward_b = "0010") then
            -- 0010: Forward EX/MEM Rsrc2 (for SWAP)
            forward_ex_mem_data <= exmem_read_data2;
        elsif (forward_a = "0011" or forward_b = "0011") then
            -- 0011: Forward EX/MEM ALU result (SWAP destination)
            forward_ex_mem_data <= exmem_alu_result;
        elsif (forward_a = "0100" or forward_b = "0100") then
            -- 0100: Forward EX/MEM input port
            forward_ex_mem_data <= exmem_input_port_data;
        else
            forward_ex_mem_data <= exmem_alu_result;
        end if;
    end process;
    
    -- Forwarding data selection for MEM/WB stage
    -- Select appropriate data based on forwarding control signals
    process(forward_a, forward_b, memwb_mem_data, memwb_r_data2, 
            memwb_alu_result, memwb_input_port_data, wb_write_back_data)
    begin
        -- Default to writeback data
        forward_mem_wb_data <= wb_write_back_data;
        
        -- Check if any forwarding from MEM/WB is needed (codes 0101-1001)
        if (forward_a = "0101" or forward_b = "0101") then
            -- 0101: Forward MEM/WB memory data
            forward_mem_wb_data <= memwb_mem_data;
        elsif (forward_a = "0110" or forward_b = "0110") then
            -- 0110: Forward MEM/WB Rsrc2 (for SWAP)
            forward_mem_wb_data <= memwb_r_data2;
        elsif (forward_a = "0111" or forward_b = "0111") then
            -- 0111: Forward MEM/WB ALU result (SWAP destination)
            forward_mem_wb_data <= memwb_alu_result;
        elsif (forward_a = "1000" or forward_b = "1000") then
            -- 1000: Forward MEM/WB input port
            forward_mem_wb_data <= memwb_input_port_data;
        elsif (forward_a = "1001" or forward_b = "1001") then
            -- 1001: Forward MEM/WB ALU result
            forward_mem_wb_data <= memwb_alu_result;
        else
            forward_mem_wb_data <= wb_write_back_data;
        end if;
    end process;
    
    -- ==================== Forwarding Unit ====================
    Forward_Unit: Forwarding_Unit
        port map (
            ID_EX_RegRs     => idex_read_reg1,
            ID_EX_RegRt     => idex_write_reg,
            EX_MEM_RegWrite => exmem_reg_write,
            EX_MEM_DestReg  => exmem_write_reg,
            EX_MEM_Rsrc1    => exmem_read_reg1,
            EX_MEM_is_swap  => exmem_is_swap,
            EX_MEM_is_in    => exmem_is_in,
            MEM_WB_RegWrite => memwb_reg_write,
            MEM_WB_DestReg  => memwb_rdst,
            MEM_WB_Rsrc1    => memwb_rsrc1,
            MEM_WB_is_swap  => memwb_is_swap,
            MEM_WB_is_in    => memwb_is_input,
            MEM_WB_mem_to_reg => memwb_mem_to_reg,
            ForwardA        => forward_a,
            ForwardB        => forward_b
        );

    HDU: Hazard_Detection_Unit
       port map (
            mem_mem_read => exmem_mem_read,
	        mem_mem_write => exmem_mem_write,
	        mem_is_pop => exmem_is_pop,
	        mem_rdst => exmem_write_reg,
	        ex_rsrc1 => idex_read_reg1,
	        ex_rsrc2 => unused_3bits,
	        ex_is_conditional => conditional_jump,
	        ex_has_one_operand => unused,
	        ex_has_two_operands => unused,
	        mem_is_int => exmem_is_int,
	        mem_is_ret => exmem_is_ret,
	        mem_is_rti => exmem_is_rti,
	        wb_is_swap => memwb_is_swap,
	        wb_swap_phase => memwb_swap_phase,
	        mem_int_phase => unused_2bits
	        mem_rti_phase => exmem_rti_phase,
	        if_flush => ifid_flush,
	        id_flush => unused,
	        ex_flush => unused,
	        if_id_enable => ifid_enable,
	        id_ex_enable => unused,
	        ex_mem_enable => unused,
	        pc_enable => pc_enable
       );
    
    Fetch: Fetch_Stage
        port map (
            clk => clk,
            rst => rst,
            pc_enable => pc_enable,
            ifid_enable => ifid_enable,
            ifid_flush => ifid_flush,
            int_load_pc => int_load_pc_internal,
            is_ret => exmem_is_ret,
            rti_load_pc => rti_load_pc_internal,
            is_call => exmem_is_call,
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
            wb_write_enable => memwb_reg_write,
            wb_write_reg => wb_write_back_register,
            wb_write_data => wb_write_back_data,
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
            if_id_immediate => instruction_decode_signal,
            forward_ex_mem => forward_ex_mem_data,
            forward_mem_wb => forward_mem_wb_data,
            forward_mux_a_sel => forward_a(1 downto 0),
            forward_mux_b_sel => forward_b(1 downto 0),
            input_port => input_port_registered,
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
            ex_mem_input_port_data => execute_input_port_data,
            conditional_jump => conditional_jump,
            pc_plus_2 => pc_plus_2
        );
    
    -- ==================== EX/MEM Pipeline Register ====================
    EXMEM_Reg: EX_MEM_Register
        port map (
            clk => clk,
            rst => rst,
            ex_rti_phase => ex_mem_rti_phase,
            ex_int_phase => ex_mem_int_phase,
            ex_mem_write => ex_mem_mem_write,
            ex_mem_read => ex_mem_mem_read,
            ex_mem_to_reg => ex_mem_mem_to_reg,
            ex_alu_op => (others => '0'),  -- Not used in attached files, set to 0
            ex_out_enable => ex_mem_out_enable,
            ex_is_swap => ex_mem_is_swap,
            ex_swap_phase => ex_mem_swap_phase,
            ex_reg_write => ex_mem_reg_write,
            ex_is_call => ex_mem_is_call,
            ex_is_ret => ex_mem_is_ret,
            ex_is_push => ex_mem_is_push,
            ex_is_pop => ex_mem_is_pop,
            ex_hlt => ex_mem_hlt,
            ex_is_in => ex_mem_is_in,
            ex_is_int => ex_mem_is_int,
            ex_is_rti => ex_mem_is_rti,
            ex_read_reg1 => ex_mem_read_reg1,
            ex_write_reg => ex_mem_write_reg,
            ex_read_data2 => ex_mem_read_data2,
            ex_alu_result => ex_mem_alu_result,
            ex_input_port_data => execute_input_port_data,
            ex_pc_plus_1 => idex_pc_plus_1,  -- Pass through PC+1
            mem_rti_phase => exmem_rti_phase,
            mem_int_phase => exmem_int_phase,
            mem_mem_write => exmem_mem_write,
            mem_mem_read => exmem_mem_read,
            mem_mem_to_reg => exmem_mem_to_reg,
            mem_alu_op => exmem_alu_op,
            mem_out_enable => exmem_out_enable,
            mem_is_swap => exmem_is_swap,
            mem_swap_phase => exmem_swap_phase,
            mem_reg_write => exmem_reg_write,
            mem_is_call => exmem_is_call,
            mem_is_ret => exmem_is_ret,
            mem_is_push => exmem_is_push,
            mem_is_pop => exmem_is_pop,
            mem_hlt => exmem_hlt,
            mem_is_in => exmem_is_in,
            mem_is_int => exmem_is_int,
            mem_is_rti => exmem_is_rti,
            mem_read_reg1 => exmem_read_reg1,
            mem_write_reg => exmem_write_reg,
            mem_read_data2 => exmem_read_data2,
            mem_alu_result => exmem_alu_result,
            mem_input_port_data => exmem_input_port_data,
            mem_pc_plus_1 => exmem_pc_plus_1
        );
    
    -- ==================== Memory Stage ====================
    Memory: Memory_Stage
        port map (
            clk => clk,
            rst => rst,
            hlt => exmem_hlt,
            is_ret => exmem_is_ret,
            is_rti => exmem_is_rti,
            is_int => exmem_is_int,
            mem_read => exmem_mem_read,
            mem_write => exmem_mem_write,
            is_push => exmem_is_push,
            alu_address_enable => '1',  -- Assuming ALU result is always used for address when needed
            mem_to_reg => exmem_mem_to_reg,
            is_pop => exmem_is_pop,
            out_enable => exmem_out_enable,
            is_swap => exmem_is_swap,
            swap_phase_previous => exmem_swap_phase,
            swap_phase_next => wb_swap_phase_next,  -- Feedback from WB stage
            reg_write => exmem_reg_write,
            is_call => exmem_is_call,
            is_input => exmem_is_in,
            rdst => exmem_write_reg,
            rsrc1 => exmem_read_reg1,
            rsrc2_data => exmem_read_data2,
            alu_result => exmem_alu_result,
            pc_data => exmem_pc_plus_1,
            ccr_data => ccr_register,
            input_port_data => exmem_input_port_data,
            int_load_pc_out => int_load_pc_internal,
            rti_load_pc_out => rti_load_pc_internal,
            is_ret_out => mem_is_ret,
            is_rti_out => mem_is_rti,
            is_int_out => mem_is_int,
            mem_read_out => mem_mem_read,
            mem_write_out => mem_mem_write,
            is_push_out => mem_is_push,
            alu_address_out => mem_alu_address,
            mem_to_reg_out => mem_mem_to_reg,
            is_pop_out => mem_is_pop,
            out_enable_out => mem_out_enable,
            is_swap_out => mem_is_swap,
            swap_phase_out => mem_swap_phase,
            reg_write_out => mem_reg_write,
            is_call_out => mem_is_call,
            is_input_out => mem_is_input,
            rdst_out => mem_rdst,
            rsrc1_out => mem_rsrc1,
            rsrc2_data_out => mem_rsrc2_data,
            alu_result_out => mem_alu_result,
            mem_data_out => mem_data,
            input_port_data_out => mem_input_port_data
        );
    
    -- ==================== MEM/WB Pipeline Register ====================
    MEMWB_Reg: Mem_Wb_Register
        port map (
            rst => rst,
            clk => clk,
            mem_to_reg => mem_mem_to_reg,
            out_enable => mem_out_enable,
            is_swap => mem_is_swap,
            swap_phase => mem_swap_phase,
            reg_write => mem_reg_write,
            is_input => mem_is_input,
            rdst => mem_rdst,
            rsrc1 => mem_rsrc1,
            r_data2 => mem_rsrc2_data,
            alu_result => mem_alu_result,
            mem_data => mem_data,
            input_port_data => mem_input_port_data,
            mem_to_reg_out => memwb_mem_to_reg,
            out_enable_out => memwb_out_enable,
            is_swap_out => memwb_is_swap,
            swap_phase_out => memwb_swap_phase,
            reg_write_out => memwb_reg_write,
            is_input_out => memwb_is_input,
            rdst_out => memwb_rdst,
            rsrc1_out => memwb_rsrc1,
            r_data2_out => memwb_r_data2,
            alu_result_out => memwb_alu_result,
            mem_data_out => memwb_mem_data,
            input_port_data_out => memwb_input_port_data
        );
    
    -- ==================== Writeback Stage ====================
    Writeback: Write_Back
        port map (
            MemToReg => memwb_mem_to_reg,
            Is_Input => memwb_is_input,
            Is_Output => memwb_out_enable,
            Is_Swap => memwb_is_swap,
            Swap_Phase => memwb_swap_phase,
            Rdst => memwb_rdst,
            Rsrc1 => memwb_rsrc1,
            R_data2 => memwb_r_data2,
            ALU_Result => memwb_alu_result,
            Mem_Result => memwb_mem_data,
            Input_Port_Data => memwb_input_port_data,
            Output_Port_Data => wb_output_port_data,
            Write_Back_Data => wb_write_back_data,
            Write_Back_Register => wb_write_back_register,
            Swap_Phase_Next => wb_swap_phase_next
        );
    
    -- ==================== Input Port Register ====================
    -- Always latches external input port
    Input_Port_Reg: Input_Port_Register
        port map (
            clk => clk,
            rst => rst,
            data_in => input_port,
            data_out => input_port_registered
        );
    
    -- ==================== Output Port Register ====================
    -- Latches ALU result when OUT instruction reaches writeback
    Output_Port_Reg: Output_Port_Register
        port map (
            clk => clk,
            rst => rst,
            enable => output_port_enable,
            data_in => wb_output_port_data,
            data_out => output_port_registered
        );
    
end Structural;
