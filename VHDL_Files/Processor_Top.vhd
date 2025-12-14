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
			  is_ret : in STD_LOGIC;
			  is_rti : in STD_LOGIC;
			  rti_phase : in STD_LOGIC;
			  is_int : STD_LOGIC;
			  int_phase : STD_LOGIC;		  
			  mem_read : in STD_LOGIC;
			  mem_write : in STD_LOGIC;
			  is_push : in STD_LOGIC;
			  alu_address : in STD_LOGIC;
			  mem_to_reg : in STD_LOGIC;
			  is_pop : in STD_LOGIC;
			  out_enable : in STD_LOGIC;
			  is_swap : in STD_LOGIC;
			  swap_phase_previous : in STD_LOGIC;
			  swap_phase_next : in STD_LOGIC;
			  reg_write : in STD_LOGIC;
			  is_call : in STD_LOGIC;
			  is_input : in STD_LOGIC;
			  is_ret_out : out STD_LOGIC;
			  is_rti_out : out STD_LOGIC;
			  rti_phase_out : out STD_LOGIC;
			  is_int_out : out STD_LOGIC;
			  int_phase_out : out STD_LOGIC;		  
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
			  rdst : in STD_LOGIC_VECTOR(2 downto 0);
			  rsrc1 : in STD_LOGIC_VECTOR(2 downto 0);
			  r_data2 : in STD_LOGIC_VECTOR(31 downto 0);
			  alu_result : in STD_LOGIC_VECTOR(31 downto 0);
			  mem_read_data : in STD_LOGIC_VECTOR(31 downto 0);
			  input_port_data : in STD_LOGIC_VECTOR(31 downto 0);
			  rdst_out : out STD_LOGIC_VECTOR(2 downto 0);
			  rsrc1_out : out STD_LOGIC_VECTOR(2 downto 0);
			  r_data2_out : out STD_LOGIC_VECTOR(31 downto 0);
			  alu_result_out : out STD_LOGIC_VECTOR(31 downto 0);
			  mem_data_out : out STD_LOGIC_VECTOR(31 downto 0);
			  input_port_data_out : in STD_LOGIC_VECTOR(31 downto 0)
		 );
     end component;
	  
	  component Mem_Wb_Register is
		  port(
			 rst, clk : in std_logic;
			 mem_to_reg : in std_logic;
			 out_enable : in std_logic;
			 is_swap : in std_logic;
			 swap_phase : in std_logic;
			 reg_write : in std_logic;
			 is_input : in std_logic;
			 rdst : in std_logic_vector(2 downto 0);
			 rsrc1 : in std_logic_vector(2 downto 0);
			 r_data2 : in std_logic_vector(31 downto 0);
			 alu_result : in std_logic_vector(31 downto 0);
			 mem_data : in std_logic_vector(31 downto 0);
			 input_port_data : in STD_LOGIC_VECTOR(31 downto 0);
			 mem_to_reg_out : out std_logic;
			 out_enable_out : out std_logic;
			 is_swap_out : out std_logic;
			 swap_phase_out : out std_logic;
			 reg_write_out : out std_logic;
			 is_input_out : out std_logic;
			 rdst_out : out std_logic_vector(2 downto 0);
			 rsrc1_out : out std_logic_vector(2 downto 0);
			 r_data2_out : out std_logic_vector(31 downto 0);
			 alu_result_out : out std_logic_vector(31 downto 0);
			 mem_data_out : out std_logic_vector(31 downto 0);
			 input_port_data_out : out STD_LOGIC_VECTOR(31 downto 0)
		  );
	  end component;
	  
	  component Write_Back is
		  port(
			 MemToReg : in std_logic;
			 Is_Input : in std_logic;
			 Is_Output : in std_logic;
			 Is_Swap : in std_logic;
			 Swap_Phase : in std_logic;
			 Rdst : in std_logic_vector(2 downto 0);
			 Rsrc1 : in std_logic_vector(2 downto 0);
			 R_data2 : in std_logic_vector(31 downto 0);
			 ALU_Result : in std_logic_vector(31 downto 0);
			 Mem_Result : in std_logic_vector(31 downto 0);
			 Input_Port_Data : in std_logic_vector(31 downto 0);
			 Output_Port_Data : out std_logic_vector(31 downto 0);
			 Write_Back_Data : out std_logic_vector(31 downto 0);
			 Write_Back_Register : out std_logic_vector(2 downto 0);
			 Swap_Phase_Next : out std_logic
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
    signal is_ret_ex_mem2 : STD_LOGIC := '0';
	 signal is_rti_ex_mem2 : STD_LOGIC := '0';
	 signal rti_phase_ex_mem2 : STD_LOGIC := '0';
	 signal is_int_ex_mem2 : STD_LOGIC := '0';
	 signal int_phase_ex_mem2 : STD_LOGIC := '0';	  
	 signal mem_read_ex_mem2 : STD_LOGIC := '0';
	 signal mem_write_ex_mem2 : STD_LOGIC := '0';
	 signal is_push_ex_mem2 : STD_LOGIC := '0';
	 signal alu_address_ex_mem2 : STD_LOGIC := '0';
	 signal mem_to_reg_ex_mem2 : STD_LOGIC := '0';
	 signal is_pop_ex_mem2 : STD_LOGIC := '0';
	 signal out_enable_ex_mem2 : STD_LOGIC := '0';
	 signal is_swap_ex_mem2 : STD_LOGIC := '0';
	 signal swap_phase_previous_ex_mem2 : STD_LOGIC := '0';
	 signal swap_phase_next_ex_mem2 : STD_LOGIC := '0';
	 signal reg_write_ex_mem2 : STD_LOGIC := '0';
	 signal is_call_ex_mem2 : STD_LOGIC := '0';
	 signal is_input_ex_mem2 : STD_LOGIC := '0';	 
	 signal is_ret_mem_wb1 : STD_LOGIC := '0';
	 signal is_rti_mem_wb1 : STD_LOGIC := '0';
	 signal rti_phase_mem_wb1 : STD_LOGIC := '0';
	 signal is_int_mem_wb1 : STD_LOGIC := '0';
	 signal int_phase_mem_wb1 : STD_LOGIC := '0';	  
	 signal mem_read_mem_wb1 : STD_LOGIC := '0';
	 signal mem_write_mem_wb1 : STD_LOGIC := '0';
	 signal is_push_mem_wb1 : STD_LOGIC := '0';
	 signal alu_address_mem_wb1 : STD_LOGIC := '0';
	 signal mem_to_reg_mem_wb1 : STD_LOGIC := '0';
	 signal is_pop_mem_wb1 : STD_LOGIC := '0';
	 signal out_enable_mem_wb1 : STD_LOGIC := '0';
	 signal is_swap_mem_wb1 : STD_LOGIC := '0';
	 signal swap_phase_mem_wb1 : STD_LOGIC := '0';
	 signal reg_write_mem_wb1 : STD_LOGIC := '0';
	 signal is_call_mem_wb1 : STD_LOGIC := '0';
	 signal is_input_mem_wb1 : STD_LOGIC := '0';	
	 signal rdst_ex_mem2 : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
	 signal rsrc1_ex_mem2 : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
	 signal r_data2_ex_mem2 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
	 signal alu_result_ex_mem2 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
	 signal mem_read_data_ex_mem2 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
	 signal input_port_data_ex_mem2 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0'); 
	 signal rdst_mem_wb1 : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
	 signal rsrc1_mem_wb1 : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
	 signal r_data2_mem_wb1 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
	 signal alu_result_mem_wb1 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
	 signal mem_data_mem_wb1 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
	 signal input_port_data_mem_wb1 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
	
	 signal mem_stage_address : STD_LOGIC_VECTOR(31 downto 0);
    signal mem_stage_write_data : STD_LOGIC_VECTOR(31 downto 0);
    signal mem_stage_write_enable : STD_LOGIC;
    signal mem_stage_read_enable : STD_LOGIC;
    signal mem_stage_read_data : STD_LOGIC_VECTOR(31 downto 0);	
	 
	 --Write_Back register signals
	 signal mem_to_reg_mem_wb2 : std_logic := '0';
	 signal out_enable_mem_wb2 : std_logic := '0';
	 signal is_swap_mem_wb2 : std_logic := '0';
	 signal swap_phase_mem_wb2 : std_logic := '0';
	 signal reg_write_mem_wb2 : std_logic := '0';
	 signal is_input_mem_wb2 : std_logic := '0';
	 signal rdst_mem_wb2 : std_logic_vector(2 downto 0) := (others => '0');
	 signal rsrc1_mem_wb2 : std_logic_vector(2 downto 0) := (others => '0');
	 signal r_data2_mem_wb2 : std_logic_vector(31 downto 0) := (others => '0');
	 signal alu_result_mem_wb2 : std_logic_vector(31 downto 0) := (others => '0');
	 signal mem_data_mem_wb2 : std_logic_vector(31 downto 0) := (others => '0');
	 signal input_port_data_mem_wb2 : std_logic_vector(31 downto 0) := (others => '0');
	 signal output_port_data_wb_out : std_logic_vector(31 downto 0) := (others => '0');
	 signal write_back_data_wb_out : std_logic_vector(31 downto 0) := (others => '0');
	 signal write_back_register_wb_out : std_logic_vector(2 downto 0) := (others => '0');
	 signal swap_phase_next_wb_out : std_logic := '0'; 
    
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
            is_ret => is_ret_ex_mem2,
				is_rti => is_rti_ex_mem2,
				rti_phase => rti_phase_ex_mem2,
				is_int => is_int_ex_mem2,
				int_phase => int_phase_ex_mem2,
				mem_read => mem_read_ex_mem2,
				mem_write => mem_write_ex_mem2,
				is_push => is_push_ex_mem2,
				alu_address => alu_address_ex_mem2,
				mem_to_reg => mem_to_reg_ex_mem2,
				is_pop => is_pop_ex_mem2,
				out_enable => out_enable_ex_mem2,
				is_swap => is_swap_ex_mem2,
				swap_phase_previous => swap_phase_previous_ex_mem2,
				swap_phase_next => swap_phase_next_ex_mem2,
				reg_write => reg_write_ex_mem2,
				is_call => is_call_ex_mem2,
				is_input => is_input_ex_mem2,
				is_ret_out => is_ret_mem_wb1,
				is_rti_out => is_rti_mem_wb1,
				rti_phase_out => rti_phase_mem_wb1,
				is_int_out => is_int_mem_wb1,
				int_phase_out => int_phase_mem_wb1,
				mem_read_out => mem_read_mem_wb1,
				mem_write_out => mem_write_mem_wb1,
				is_push_out => is_push_mem_wb1,
				alu_address_out => alu_address_mem_wb1,
				mem_to_reg_out => mem_to_reg_mem_wb1,
				is_pop_out => is_pop_mem_wb1,
				out_enable_out => out_enable_mem_wb1,
				is_swap_out => is_swap_mem_wb1,
				swap_phase_out => swap_phase_mem_wb1,
				reg_write_out => reg_write_mem_wb1,
				is_call_out => is_call_mem_wb1,
				is_input_out => is_input_mem_wb1,
				rdst => rdst_ex_mem2,
				rsrc1 => rsrc1_ex_mem2,
				r_data2 => r_data2_ex_mem2,
				alu_result => alu_result_ex_mem2,
				mem_read_data => mem_read_data_ex_mem2,
				input_port_data => input_port_data_ex_mem2,
				rdst_out => rdst_mem_wb1,
				rsrc1_out => rsrc1_mem_wb1,
				r_data2_out => r_data2_mem_wb1,
				alu_result_out => alu_result_mem_wb1,
				mem_data_out => mem_data_mem_wb1,
				input_port_data_out => input_port_data_mem_wb1
        );
		  
	 Mem_Wb_Reg: Mem_Wb_Register
	   port map (
			rst => rst,
			clk => clk,
			mem_to_reg => mem_to_reg_mem_wb1,
			out_enable => out_enable_mem_wb1,
			is_swap => is_swap_mem_wb1,
			swap_phase => swap_phase_mem_wb1,
			reg_write => reg_write_mem_wb1,
			is_input => is_input_mem_wb1,
			rdst => rdst_mem_wb1,
			rsrc1 => rsrc1_mem_wb1,
			r_data2 => r_data2_mem_wb1,
			alu_result => alu_result_mem_wb1,
			mem_data => mem_data_mem_wb1,
			input_port_data => input_port_data_mem_wb1,
			mem_to_reg_out => mem_to_reg_mem_wb2,
			out_enable_out => out_enable_mem_wb2,
			is_swap_out => is_swap_mem_wb2,
			swap_phase_out => swap_phase_mem_wb2,
			reg_write_out => reg_write_mem_wb2,
			is_input_out => is_input_mem_wb2,
			rdst_out => rdst_mem_wb2,
			rsrc1_out => rsrc1_mem_wb2,
			r_data2_out => r_data2_mem_wb2,
			alu_result_out => alu_result_mem_wb2,
			mem_data_out => mem_data_mem_wb2,
			input_port_data_out => input_port_data_mem_wb2
		);
	
	 Wb_Stage: Write_Back
	   port map(
		   MemToReg => mem_to_reg_mem_wb2,
			Is_Input => is_input_mem_wb2,
		   Is_Output => out_enable_mem_wb2,
		   Is_Swap => is_swap_mem_wb2,
		   Swap_Phase => swap_phase_mem_wb2,
		   Rdst => rdst_mem_wb2,
		   Rsrc1 => rsrc1_mem_wb2,
		   R_data2 => r_data2_mem_wb2,
		   ALU_Result => alu_result_mem_wb2,
		   Mem_Result => mem_data_mem_wb2,
		   Input_Port_Data => input_port_data_mem_wb2,
		   Output_Port_Data => output_port_data_wb_out,
		   Write_Back_Data => write_back_data_wb_out,
		   Write_Back_Register => write_back_register_wb_out,
			Swap_Phase_Next => swap_phase_next_wb_out
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
