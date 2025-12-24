library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Top-Level Processor Integration
-- Connects all pipeline stages and the memory system

entity Processor_Top is
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        
        -- External interfaces
        in_port : in STD_LOGIC_VECTOR(31 downto 0);  -- Input port for IN instruction
        
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

    -- excute stage
    component ex_stage is
    port (
		clk                : in  std_logic;
		rst                : in  std_logic;

		-- Inputs from ID/EX pipeline register
		idex_rdata1        : in  std_logic_vector(31 downto 0);
		idex_rdata2        : in  std_logic_vector(31 downto 0);
		ifd_imm            : in  std_logic_vector(31 downto 0);
		in_port_in         : in  std_logic_vector(31 downto 0); -- for IN instruction
		idex_rd            : in  std_logic_vector(2 downto 0);  -- dest reg
		rsrc1_in           : in  std_logic_vector(2 downto 0);
		is_immediate       : in  std_logic;                     -- 1 => use immediate for operand B
		reg_write_in       : in  std_logic;                     -- register write enable (passed through)
		mem_read_in        : in  std_logic;                     -- mem read (LDD- passed through)
		mem_write_in       : in  std_logic;                     -- mem write (STD - passed through)
		alu_op             : in  std_logic_vector(3 downto 0);  -- ALU function code
		pc_plus_1_in       : in  std_logic_vector(31 downto 0); -- PC+1 for branch calculations
		is_hult_in         : in  std_logic;
		is_call_in         : in  std_logic;
		is_swap_in         : in  std_logic;
		is_in_in           : in  std_logic;
		swap_phase_in      : in  std_logic;
		out_enable_in      : in  std_logic;
		mem_to_reg_in      : in  std_logic;
		is_jumpz           : in  std_logic;
		is_jumpc           : in  std_logic;
		is_jumpn           : in  std_logic;
		previous_ccr       : in  std_logic_vector(2 downto 0);  -- ZNC from previous inst
		stack_ccr          : in  std_logic_vector(2 downto 0);  -- CCR from stack
		ccr_in             : in  std_logic;
		ccr_write          : in  std_logic;
		int_phase_previous : in  std_logic;
		int_phase_next     : in  std_logic;
		rti_phase_previous : in  std_logic;
		rti_phase_next     : in  std_logic;
		is_pop_in          : in  std_logic;
		is_push_in         : in  std_logic;
		alu_addr_in        : in  std_logic;
		is_int_in          : in  std_logic;
		is_ret_in          : in  std_logic;
		is_rti_in          : in  std_logic;
		-- Forwarding control inputs (from Forwarding Unit)
		-- 00 = use idex operand, 01 = forward from EX/MEM, 10 = forward from MEM/WB
		forwardA           : in  std_logic_vector(3 downto 0);
		forwardB           : in  std_logic_vector(3 downto 0);

		-- Values to forward from later stages
		exmem_alu_result   : in  std_logic_vector(31 downto 0); -- EX/MEM ALU result
		exmem_in_port     : in  std_logic_vector(31 downto 0); -- EX/MEM IN port value
		exmem_swap_rdata2  : in  std_logic_vector(31 downto 0); -- EX/MEM SWAP second operand
		memwb_result       : in  std_logic_vector(31 downto 0); -- MEM/WB result
		memwb_alu_result   : in  std_logic_vector(31 downto 0); -- MEM/WB ALU result
		memwb_in_port     : in  std_logic_vector(31 downto 0); -- MEM/WB IN port value
		memwb_swap_rdata2  : in  std_logic_vector(31 downto 0); -- MEM/WB SWAP second operand

		-- Outputs -> EX/MEM pipeline register
		exmem_alu_out      : out std_logic_vector(31 downto 0);
		exmem_rdata2       : out std_logic_vector(31 downto 0); -- data to store
		in_port_out        : out std_logic_vector(31 downto 0); -- for IN instruction
		exmem_rd           : out std_logic_vector(2 downto 0);
		reg_write_out      : out std_logic;
		mem_read_out       : out std_logic;
		mem_write_out      : out std_logic;
		pc_plus_1_out      : out std_logic_vector(31 downto 0);
		is_hult_out        : out std_logic;
		is_call_out        : out std_logic;
		is_swap_out        : out std_logic;
		is_in_out          : out std_logic;
		is_pop_out         : out std_logic;
		is_push_out        : out std_logic;

		swap_phase_out     : out std_logic;
		out_enable_out     : out std_logic;
		mem_to_reg_out     : out std_logic;
		rsrc1_out          : out std_logic_vector(2 downto 0);
		conditional_jump   : out std_logic;                     -- indicates if jump taken
		next_ccr           : out std_logic_vector(2 downto 0);
		int_phase          : out std_logic;
		rti_phase          : out std_logic;
		exmem_immediate    : out std_logic_vector(31 downto 0); -- for LDM  Rdst, Imm
		alu_addr_out      : out std_logic;
		is_int_out         : out std_logic;
		is_ret_out         : out std_logic;
		is_rti_out         : out std_logic;

		-- flags to propagate
		ex_flags_z         : out std_logic;
		ex_flags_n         : out std_logic;
		ex_flags_c         : out std_logic
	);
	end component;

    -- forward unit
 component Forwarding_Unit is
      port (
        -- ID/EX source registers
        ID_EX_RegRs       : in  std_logic_vector(2 downto 0);
        ID_EX_RegRt       : in  std_logic_vector(2 downto 0);

        -- EX/MEM stage info
        EX_MEM_RegWrite   : in  std_logic;
        EX_MEM_DestReg    : in  std_logic_vector(2 downto 0);
        EX_MEM_Rsrc1      : in  std_logic_vector(2 downto 0);
        EX_MEM_is_swap    : in  std_logic;
        EX_MEM_is_in      : in  std_logic;

        -- MEM/WB stage info
        MEM_WB_RegWrite   : in  std_logic;
        MEM_WB_DestReg    : in  std_logic_vector(2 downto 0);
        MEM_WB_Rsrc1      : in  std_logic_vector(2 downto 0);
        MEM_WB_is_swap    : in  std_logic;
        MEM_WB_is_in      : in  std_logic;
        MEM_WB_mem_to_reg : in  std_logic;

        -- Forwarding controls
        ForwardA          : out std_logic_vector(3 downto 0);
        ForwardB          : out std_logic_vector(3 downto 0)
      );
    end component;
    
    -- NOTE: Memory_Stage component commented out - incorrect port declaration
    -- component Memory_Stage is
	-- 	 Port (       
	-- 		  is_ret : in STD_LOGIC;
	-- 		  is_rti : in STD_LOGIC;
	-- 		  rti_phase : in STD_LOGIC;
	-- 		  is_int : STD_LOGIC;
	-- 		  int_phase : STD_LOGIC;		  
	-- 		  mem_read : in STD_LOGIC;
	-- 		  mem_write : in STD_LOGIC;
	-- 		  is_push : in STD_LOGIC;
	-- 		  alu_address : in STD_LOGIC;
	-- 		  mem_to_reg : in STD_LOGIC;
	-- 		  is_pop : in STD_LOGIC;
	-- 		  out_enable : in STD_LOGIC;
	-- 		  is_swap : in STD_LOGIC;
	-- 		  swap_phase_previous : in STD_LOGIC;
	-- 		  swap_phase_next : in STD_LOGIC;
	-- 		  reg_write : in STD_LOGIC;
	-- 		  is_call : in STD_LOGIC;
	-- 		  is_input : in STD_LOGIC;
	-- 		  is_ret_out : out STD_LOGIC;
	-- 		  is_rti_out : out STD_LOGIC;
	-- 		  rti_phase_out : out STD_LOGIC;
	-- 		  is_int_out : out STD_LOGIC;
	-- 		  int_phase_out : out STD_LOGIC;		  
	-- 		  mem_read_out : out STD_LOGIC;
	-- 		  mem_write_out : out STD_LOGIC;
	-- 		  is_push_out : out STD_LOGIC;
	-- 		  alu_address_out : out STD_LOGIC;
	-- 		  mem_to_reg_out : out STD_LOGIC;
	-- 		  is_pop_out : out STD_LOGIC;
	-- 		  out_enable_out : out STD_LOGIC;
	-- 		  is_swap_out : out STD_LOGIC;
	-- 		  swap_phase_out : out STD_LOGIC;
	-- 		  reg_write_out : out STD_LOGIC;
	-- 		  is_call_out : out STD_LOGIC;
	-- 		  is_input_out : out STD_LOGIC;
	-- 		  rdst : in STD_LOGIC_VECTOR(2 downto 0);
	-- 		  rsrc1 : in STD_LOGIC_VECTOR(2 downto 0);
	-- 		  r_data2 : in STD_LOGIC_VECTOR(31 downto 0);
	-- 		  alu_result : in STD_LOGIC_VECTOR(31 downto 0);
	-- 		  mem_read_data : in STD_LOGIC_VECTOR(31 downto 0);
	-- 		  input_port_data : in STD_LOGIC_VECTOR(31 downto 0);
	-- 		  rdst_out : out STD_LOGIC_VECTOR(2 downto 0);
	-- 		  rsrc1_out : out STD_LOGIC_VECTOR(2 downto 0);
	-- 		  r_data2_out : out STD_LOGIC_VECTOR(31 downto 0);
	-- 		  alu_result_out : out STD_LOGIC_VECTOR(31 downto 0);
	-- 		  mem_data_out : out STD_LOGIC_VECTOR(31 downto 0);
	-- 		  input_port_data_out : in STD_LOGIC_VECTOR(31 downto 0)
	-- 	 );
    -- end component;

     component EX_MEM_Register is
       port (
         -- control signals
         clk            : in  std_logic;
         reset          : in  std_logic;
         enable         : in  STD_LOGIC;
         flush_seg      : in  STD_LOGIC;
         -- input data signals
         alu_result_in  : in  std_logic_vector(31 downto 0);
         rdata2_in      : in  std_logic_vector(31 downto 0);
         in_port_in     : in  std_logic_vector(31 downto 0);
         rsrc1_in       : in  std_logic_vector(2 downto 0);
         rdst_in        : in  std_logic_vector(2 downto 0);
         is_hult_in     : in  std_logic;
         is_call_in     : in  std_logic;
         reg_write_in   : in  std_logic;
         swap_phase_in  : in  std_logic;
         is_swap_in     : in  std_logic;
         is_in_in       : in  std_logic;
         out_enable_in  : in  std_logic;
         mem_to_reg_in  : in  std_logic;
         mem_read_in    : in  std_logic;
         mem_write_in  : in  std_logic;
         int_phase_in   : in  std_logic;
         rti_phase_in   : in  std_logic;
         is_pop_in      : in  std_logic;
         is_push_in     : in  std_logic;
         alu_addr_in    : in  std_logic;
         is_int_in      : in  std_logic;
         is_ret_in      : in  std_logic;
         is_rti_in      : in  std_logic;
         -- output data signals
         alu_result_out : out std_logic_vector(31 downto 0);
         rdata2_out     : out std_logic_vector(31 downto 0);
         in_port_out    : out std_logic_vector(31 downto 0);
         rsrc1_out      : out std_logic_vector(2 downto 0);
         rdst_out       : out std_logic_vector(2 downto 0);
         is_hult_out    : out std_logic;
         is_call_out    : out std_logic;
         reg_write_out  : out std_logic;
         swap_phase_out : out std_logic;
         is_swap_out    : out std_logic;
         is_in_out      : out std_logic;
         out_enable_out : out std_logic;
         mem_to_reg_out : out std_logic;
         mem_read_out   : out std_logic;
         mem_write_out  : out std_logic;
         int_phase_out  : out std_logic;
         rti_phase_out  : out std_logic;
         is_pop_out     : out std_logic;
         is_push_out    : out std_logic;
         alu_addr_out   : out std_logic;
         is_int_out     : out std_logic;
         is_ret_out     : out std_logic;
         is_rti_out     : out std_logic

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
    
    -- NOTE: Memory_System component commented out - entity file not yet created
    -- component Memory_System is
    --     Generic (
    --         ADDR_WIDTH : integer := 32;
    --         DATA_WIDTH : integer := 32;
    --         MEM_SIZE : integer := 1024
    --     );
    --     Port (
    --         clk : in STD_LOGIC;
    --         rst : in STD_LOGIC;
    --         fetch_address : in STD_LOGIC_VECTOR(31 downto 0);
    --         fetch_read_enable : in STD_LOGIC;
    --         fetch_read_data : out STD_LOGIC_VECTOR(31 downto 0);
    --         mem_address : in STD_LOGIC_VECTOR(31 downto 0);
    --         mem_write_data : in STD_LOGIC_VECTOR(31 downto 0);
    --         mem_write_enable : in STD_LOGIC;
    --         mem_read_enable : in STD_LOGIC;
    --         mem_read_data : out STD_LOGIC_VECTOR(31 downto 0);
    --         mem_stage_priority : in STD_LOGIC
    --     );
    -- end component;
    
    -- Internal Signals

    -- Execute Stage signals
    -- inputs
    signal es_ex_mem_reg_enable : STD_LOGIC := '1';
    signal es_ex_mem_reg_flush : STD_LOGIC := '0';
    signal es_idex_rdata1 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal es_idex_rdata2 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal es_ifd_imm : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal es_in_port_in : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal es_idex_rd : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
    signal es_rsrc1_in : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
    signal es_rsrc2_in : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');  	 
    signal es_is_immediate : STD_LOGIC := '0';
    signal es_reg_write_in : STD_LOGIC := '0';
    signal es_mem_read_in : STD_LOGIC := '0';
    signal es_mem_write_in : STD_LOGIC := '0';
    signal es_alu_op : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal es_pc_plus_1_in : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal es_is_hult_in : STD_LOGIC := '0';
    signal es_is_call_in : STD_LOGIC := '0';
    signal es_is_swap_in : STD_LOGIC := '0';
    signal es_is_in_in : STD_LOGIC := '0';
    signal es_swap_phase_in : STD_LOGIC := '0';
    signal es_out_enable_in : STD_LOGIC := '0';
    signal es_mem_to_reg_in : STD_LOGIC := '0';
    signal es_is_jumpz : STD_LOGIC := '0';
    signal es_is_jumpc : STD_LOGIC := '0';
    signal es_is_jumpn : STD_LOGIC := '0';
    signal es_previous_ccr : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
    signal es_stack_ccr : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
    signal es_ccr_in : STD_LOGIC := '0';
    signal es_ccr_write : STD_LOGIC := '0';
    signal es_int_phase_previous : STD_LOGIC := '0';
    signal es_int_phase_next : STD_LOGIC := '0';
    signal es_rti_phase_previous : STD_LOGIC := '0';
    signal es_rti_phase_next : STD_LOGIC := '0';
    signal es_is_pop_in : STD_LOGIC := '0';
    signal es_is_push_in : STD_LOGIC := '0';
    signal es_alu_addr_in : STD_LOGIC := '0';
    signal es_is_int_in : STD_LOGIC := '0';
    signal es_is_ret_in : STD_LOGIC := '0';
    signal es_is_rti_in : STD_LOGIC := '0';
    signal es_forwardA : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal es_forwardB : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal es_exmem_alu_result : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal es_exmem_in_port : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal es_exmem_swap_rdata2 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal es_memwb_result : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal es_memwb_alu_result : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal es_memwb_in_port : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal es_memwb_swap_rdata2 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    -- outputs
    signal es_exmem_alu_out : STD_LOGIC_VECTOR(31 downto 0);
    signal es_exmem_rdata2 : STD_LOGIC_VECTOR(31 downto 0);
    signal es_in_port_out : STD_LOGIC_VECTOR(31 downto 0);
    signal es_exmem_rd : STD_LOGIC_VECTOR(2 downto 0);
    signal es_reg_write_out : STD_LOGIC;
    signal es_mem_read_out : STD_LOGIC;
    signal es_mem_write_out : STD_LOGIC;
    signal es_pc_plus_1_out : STD_LOGIC_VECTOR(31 downto 0);
    signal es_is_hult_out : STD_LOGIC;
    signal es_is_call_out : STD_LOGIC;
    signal es_is_swap_out : STD_LOGIC;
    signal es_is_in_out : STD_LOGIC;
    signal es_is_pop_out : STD_LOGIC;
    signal es_is_push_out : STD_LOGIC;
    signal es_swap_phase_out : STD_LOGIC;
    signal es_out_enable_out : STD_LOGIC;
    signal es_mem_to_reg_out : STD_LOGIC;
    signal es_rsrc1_out : STD_LOGIC_VECTOR(2 downto 0);
    signal es_conditional_jump : STD_LOGIC;
    signal es_next_ccr : STD_LOGIC_VECTOR(2 downto 0);
    signal es_int_phase : STD_LOGIC;
    signal es_rti_phase : STD_LOGIC;
    signal es_exmem_immediate : STD_LOGIC_VECTOR(31 downto 0);
    signal es_ex_flags_z : STD_LOGIC;
    signal es_ex_flags_n : STD_LOGIC;
    signal es_ex_flags_c : STD_LOGIC;
    signal es_alu_addr_out : STD_LOGIC;
    signal es_is_int_out : STD_LOGIC;
    signal es_is_ret_out : STD_LOGIC;
    signal es_is_rti_out : STD_LOGIC;

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
	 signal is_hlt_ex_mem2 : STD_LOGIC := '0'; 
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
    
    -- ========== Fetch → IF/ID → Decode → ID/EX Signals ==========
    -- Fetch Stage outputs
    signal fetch_instruction : STD_LOGIC_VECTOR(31 downto 0);
    signal fetch_pc_plus_1 : STD_LOGIC_VECTOR(31 downto 0);
    signal fetch_pc_out : STD_LOGIC_VECTOR(31 downto 0);
    
    -- IF/ID Register outputs
    signal ifid_instruction : STD_LOGIC_VECTOR(31 downto 0);
    signal ifid_pc_plus_1 : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Decode Stage outputs
    signal decode_read_data1 : STD_LOGIC_VECTOR(31 downto 0);
    signal decode_read_data2 : STD_LOGIC_VECTOR(31 downto 0);
    signal decode_rd : STD_LOGIC_VECTOR(2 downto 0);
    signal decode_rs1 : STD_LOGIC_VECTOR(2 downto 0);
    signal decode_rs2 : STD_LOGIC_VECTOR(2 downto 0);
    signal decode_mem_write : STD_LOGIC;
    signal decode_mem_read : STD_LOGIC;
    signal decode_mem_to_reg : STD_LOGIC;
    signal decode_alu_op : STD_LOGIC_VECTOR(3 downto 0);
    signal decode_out_enable : STD_LOGIC;
    signal decode_ccr_in : STD_LOGIC_VECTOR(1 downto 0);
    signal decode_is_swap : STD_LOGIC;
    signal decode_swap_phase : STD_LOGIC;
    signal decode_reg_write : STD_LOGIC;
    signal decode_is_immediate : STD_LOGIC;
    signal decode_is_call : STD_LOGIC;
    signal decode_hlt : STD_LOGIC;
    signal decode_is_int : STD_LOGIC;
    signal decode_is_in : STD_LOGIC;
    signal decode_is_pop : STD_LOGIC;
    signal decode_is_push : STD_LOGIC;
    signal decode_int_phase : STD_LOGIC;
    signal decode_is_rti : STD_LOGIC;
    signal decode_rti_phase : STD_LOGIC;
    signal decode_is_ret : STD_LOGIC;
    signal decode_branchZ : STD_LOGIC;
    signal decode_branchC : STD_LOGIC;
    signal decode_branchN : STD_LOGIC;
    signal decode_unconditional : STD_LOGIC;
    signal decode_pc_plus_1 : STD_LOGIC_VECTOR(31 downto 0);
    
    -- ID/EX Register outputs
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
    
    -- Writeback signals (placeholder)
    signal wb_write_enable : STD_LOGIC := '0';
    signal wb_write_reg : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
    signal wb_write_data : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    
    -- Memory interface
    signal mem_read_data : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    
    -- Control signals for Fetch (placeholders)
    signal int_load_pc : STD_LOGIC := '0';
    signal is_ret_fetch : STD_LOGIC := '0';
    signal rti_load_pc : STD_LOGIC := '0';
    signal is_call_fetch : STD_LOGIC := '0';
    signal is_conditional_jump : STD_LOGIC := '0';
    signal is_unconditional_jump : STD_LOGIC := '0';
    signal immediate_decode_fetch : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal alu_immediate_fetch : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    
    -- Memory interface signals (for Memory_System component)
    signal fetch_mem_address : STD_LOGIC_VECTOR(31 downto 0);
    signal fetch_mem_read_enable : STD_LOGIC;
    signal fetch_mem_read_data : STD_LOGIC_VECTOR(31 downto 0);
    
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
    -- ========== Fetch → IF/ID → Decode → ID/EX Pipeline ==========
    
    -- Fetch Stage
    Fetch: Fetch_Stage
        port map (
            clk => clk,
            rst => rst,
            pc_enable => pc_enable,
            ifid_enable => ifid_enable,
            ifid_flush => ifid_flush,
            int_load_pc => int_load_pc,
            is_ret => is_ret_fetch,
            rti_load_pc => rti_load_pc,
            is_call => is_call_fetch,
            is_conditional_jump => is_conditional_jump,
            is_unconditional_jump => is_unconditional_jump,
            immediate_decode => immediate_decode_fetch,
            alu_immediate => alu_immediate_fetch,
            pc_out => fetch_pc_out,
            mem_read_data => mem_read_data,
            instruction_fetch => fetch_instruction,
            pc_plus_1_fetch => fetch_pc_plus_1
        );
    
    -- IF/ID Pipeline Register
    IF_ID: IF_ID_Register
        port map (
            clk => clk,
            rst => rst,
            enable => ifid_enable,
            flush => ifid_flush,
            instruction_in => fetch_instruction,
            pc_plus_1_in => fetch_pc_plus_1,
            instruction_out => ifid_instruction,
            pc_plus_1_out => ifid_pc_plus_1
        );
    
    -- Decode Stage
    Decode: decode_stage
        port map (
            clk => clk,
            rst => rst,
            instruction => ifid_instruction,
            pc_in_plus_1 => ifid_pc_plus_1,
            wb_write_enable => wb_write_enable,
            wb_write_reg => wb_write_reg,
            wb_write_data => wb_write_data,
            previous_is_immediate => idex_is_immediate,  -- Feedback from ID/EX
            read_data1 => decode_read_data1,
            read_data2 => decode_read_data2,
            rd => decode_rd,
            rs1 => decode_rs1,
            rs2 => decode_rs2,
            mem_write => decode_mem_write,
            mem_read => decode_mem_read,
            mem_to_reg => decode_mem_to_reg,
            alu_op => decode_alu_op,
            out_enable => decode_out_enable,
            ccr_in => decode_ccr_in,
            is_swap => decode_is_swap,
            swap_phase => decode_swap_phase,
            reg_write => decode_reg_write,
            is_immediate => decode_is_immediate,
            is_call => decode_is_call,
            hlt => decode_hlt,
            is_int => decode_is_int,
            is_in => decode_is_in,
            is_pop => decode_is_pop,
            is_push => decode_is_push,
            int_phase => decode_int_phase,
            is_rti => decode_is_rti,
            rti_phase => decode_rti_phase,
            is_ret => decode_is_ret,
            branchZ => decode_branchZ,
            branchC => decode_branchC,
            branchN => decode_branchN,
            unconditional_branch => decode_unconditional,
            pc_out_plus_1 => decode_pc_plus_1
        );
    
    -- ID/EX Pipeline Register
    ID_EX: ID_EX_register
        port map (
            clk => clk,
            rst => rst,
            hlt => decode_hlt,
            pc_in_plus_1 => decode_pc_plus_1,
            read_data1_in => decode_read_data1,
            read_data2_in => decode_read_data2,
            read_reg1_in => decode_rs1,
            write_reg_in => decode_rd,
            mem_write_in => decode_mem_write,
            mem_read_in => decode_mem_read,
            mem_to_reg_in => decode_mem_to_reg,
            alu_op_in => decode_alu_op,
            out_enable_in => decode_out_enable,
            ccr_in_in => decode_ccr_in,
            is_swap_in => decode_is_swap,
            swap_phase_in => decode_swap_phase,
            reg_write_in => decode_reg_write,
            is_immediate_in => decode_is_immediate,
            is_call_in => decode_is_call,
            hlt_in => decode_hlt,
            is_int_in => decode_is_int,
            is_in_in => decode_is_in,
            is_pop_in => decode_is_pop,
            is_push_in => decode_is_push,
            int_phase_in => decode_int_phase,
            is_rti_in => decode_is_rti,
            rti_phase_in => decode_rti_phase,
            is_ret_in => decode_is_ret,
            branchZ_in => decode_branchZ,
            branchC_in => decode_branchC,
            branchN_in => decode_branchN,
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
    
    -- Execute Stage and Forwarding Unit Instantiation
    Execute_Stage: ex_stage
      port map(
        clk => clk,
        rst => rst,
        idex_rdata1 => idex_read_data1,
        idex_rdata2 => idex_read_data2,
        ifd_imm => ifid_instruction,  -- Immediate from instruction
        in_port_in => in_port,
        idex_rd => idex_write_reg,
        rsrc1_in => idex_read_reg1,
        is_immediate => idex_is_immediate,
        reg_write_in => idex_reg_write,
        mem_read_in => idex_mem_read,
        mem_write_in => idex_mem_write,
        alu_op => idex_alu_op,
        pc_plus_1_in => idex_pc_plus_1,
        is_hult_in => idex_hlt,
        is_call_in => idex_is_call,
        is_swap_in => idex_is_swap,
        is_in_in => idex_is_in,
        swap_phase_in => idex_swap_phase,
        out_enable_in => idex_out_enable,
        mem_to_reg_in => idex_mem_to_reg,
        is_jumpz => idex_branchZ,
        is_jumpc => idex_branchC,
        is_jumpn => idex_branchN,
        previous_ccr => es_previous_ccr,
        stack_ccr => es_stack_ccr,
        ccr_in => idex_ccr_in,
        ccr_write => es_ccr_write,
        int_phase_previous => idex_int_phase,
        int_phase_next => es_int_phase_next,
        rti_phase_previous => idex_rti_phase,
        rti_phase_next => es_rti_phase_next,
        is_pop_in => idex_is_pop,
        is_push_in => idex_is_push,
        alu_addr_in => es_alu_addr_in,
        is_int_in => idex_is_int,
        is_ret_in => idex_is_ret,
        is_rti_in => idex_is_rti,
        forwardA => es_forwardA,
        forwardB => es_forwardB,
        exmem_alu_result => es_exmem_alu_result,
        exmem_in_port => es_exmem_in_port,
        exmem_swap_rdata2 => es_exmem_swap_rdata2,
        memwb_result => es_memwb_result,
        memwb_alu_result => es_memwb_alu_result,
        memwb_in_port => es_memwb_in_port,
        memwb_swap_rdata2 => es_memwb_swap_rdata2,
        exmem_alu_out => es_exmem_alu_out,
        exmem_rdata2 => es_exmem_rdata2,
        in_port_out => es_in_port_out,
        exmem_rd => es_exmem_rd,
        reg_write_out => es_reg_write_out,
        mem_read_out => es_mem_read_out,
        mem_write_out => es_mem_write_out,
        pc_plus_1_out => es_pc_plus_1_out,
        is_hult_out => es_is_hult_out,
        is_call_out => es_is_call_out,
        is_swap_out => es_is_swap_out,
        is_pop_out => es_is_pop_out,
        is_push_out => es_is_push_out,
        is_in_out => es_is_in_out,
        is_int_out => es_is_int_out,
        is_ret_out => es_is_ret_out,
        is_rti_out => es_is_rti_out,
        alu_addr_out => es_alu_addr_out,
        swap_phase_out => es_swap_phase_out,
        out_enable_out => es_out_enable_out,
        mem_to_reg_out => es_mem_to_reg_out,
        rsrc1_out => es_rsrc1_out,
        conditional_jump => es_conditional_jump,
        next_ccr => es_next_ccr,
        int_phase => es_int_phase,
        rti_phase => es_rti_phase,
        exmem_immediate => es_exmem_immediate,
        ex_flags_z => es_ex_flags_z,
        ex_flags_n => es_ex_flags_n,
        ex_flags_c => es_ex_flags_c
      );

    EX_MEM_Reg: EX_MEM_Register
      port map (
        clk => clk,
        reset => rst,
        enable => es_ex_mem_reg_enable,
        flush_seg => es_ex_mem_reg_flush,
        alu_result_in => es_exmem_alu_out,
        rdata2_in => es_exmem_rdata2,
        in_port_in => es_in_port_out,
        rsrc1_in => es_rsrc1_out,
        rdst_in => es_exmem_rd,
        is_hult_in => es_is_hult_out,
        is_call_in => es_is_call_out,
        reg_write_in => es_reg_write_out,
        swap_phase_in => es_swap_phase_out,
        is_swap_in => es_is_swap_out,
        is_in_in => es_is_in_out,
        out_enable_in => es_out_enable_out,
        mem_to_reg_in => es_mem_to_reg_out,
        mem_read_in => es_mem_read_out,
        mem_write_in => es_mem_write_out,
        int_phase_in => es_int_phase,
        rti_phase_in => es_rti_phase,
        is_pop_in => es_is_pop_out,
        is_push_in => es_is_push_out,
        alu_addr_in => es_alu_addr_out,
        is_int_in => es_is_int_out,
        is_ret_in => es_is_ret_out,
        is_rti_in => es_is_rti_out,
		  alu_result_out => alu_result_ex_mem2,
        rdata2_out => r_data2_ex_mem2,
        in_port_out => input_port_data_ex_mem2,
        rsrc1_out => rsrc1_ex_mem2,
        rdst_out => rdst_ex_mem2,
        is_hult_out => is_hlt_ex_mem2,
        is_call_out => is_call_ex_mem2,
        reg_write_out => reg_write_ex_mem2,
        swap_phase_out => swap_phase_previous_ex_mem2,
        is_swap_out => is_swap_ex_mem2,
        is_in_out => is_input_ex_mem2,
        out_enable_out => out_enable_ex_mem2,
        mem_to_reg_out => mem_to_reg_ex_mem2,
        mem_read_out => mem_read_ex_mem2,
        mem_write_out => mem_write_ex_mem2,
        int_phase_out => int_phase_ex_mem2,
        rti_phase_out => rti_phase_ex_mem2,
        is_pop_out => is_pop_ex_mem2,
        is_push_out => is_push_ex_mem2,
        alu_addr_out => alu_address_ex_mem2,
        is_int_out => is_int_ex_mem2,
        is_ret_out => is_ret_ex_mem2,
        is_rti_out => is_rti_ex_mem2
      );
		
	 Forward_Unit: Forwarding_Unit 
      port map (
        ID_EX_RegRs => es_rsrc1_in,
        ID_EX_RegRt => es_rsrc2_in,
        EX_MEM_RegWrite => reg_write_ex_mem2,
        EX_MEM_DestReg => rdst_ex_mem2,
        EX_MEM_Rsrc1 => rsrc1_ex_mem2,
        EX_MEM_is_swap => is_swap_ex_mem2,
        EX_MEM_is_in => is_input_ex_mem2,
        MEM_WB_RegWrite => reg_write_mem_wb2,
        MEM_WB_DestReg => rdst_mem_wb2,
        MEM_WB_Rsrc1 => rsrc1_mem_wb2,
        MEM_WB_is_swap => is_swap_mem_wb2,
        MEM_WB_is_in => is_input_mem_wb2,
        MEM_WB_mem_to_reg => mem_to_reg_mem_wb2,
        ForwardA => es_forwardA,
        ForwardB => es_forwardB
      );
    
    -- Memory Stage Instantiation (commented out - component declaration missing)\n    -- Mem_Stage: Memory_Stage\n    --     port map (\n    --         is_ret => is_ret_ex_mem2,\n\t\t-- \t\tis_rti => is_rti_ex_mem2,\n\t\t-- \t\trti_phase => rti_phase_ex_mem2,\n\t\t-- \t\tis_int => is_int_ex_mem2,\n\t\t-- \t\tint_phase => int_phase_ex_mem2,\n\t\t-- \t\tmem_read => mem_read_ex_mem2,\n\t\t-- \t\tmem_write => mem_write_ex_mem2,\n\t\t-- \t\tis_push => is_push_ex_mem2,\n\t\t-- \t\talu_address => alu_address_ex_mem2,\n\t\t-- \t\tmem_to_reg => mem_to_reg_ex_mem2,\n\t\t-- \t\tis_pop => is_pop_ex_mem2,\n\t\t-- \t\tout_enable => out_enable_ex_mem2,\n\t\t-- \t\tis_swap => is_swap_ex_mem2,\n\t\t-- \t\tswap_phase_previous => swap_phase_previous_ex_mem2,\n\t\t-- \t\tswap_phase_next => swap_phase_next_ex_mem2,\n\t\t-- \t\treg_write => reg_write_ex_mem2,\n\t\t-- \t\tis_call => is_call_ex_mem2,\n\t\t-- \t\tis_input => is_input_ex_mem2,\n\t\t-- \t\tis_ret_out => is_ret_mem_wb1,\n\t\t-- \t\tis_rti_out => is_rti_mem_wb1,\n\t\t-- \t\trti_phase_out => rti_phase_mem_wb1,\n\t\t-- \t\tis_int_out => is_int_mem_wb1,\n\t\t-- \t\tint_phase_out => int_phase_mem_wb1,\n\t\t-- \t\tmem_read_out => mem_read_mem_wb1,\n\t\t-- \t\tmem_write_out => mem_write_mem_wb1,\n\t\t-- \t\tis_push_out => is_push_mem_wb1,\n\t\t-- \t\talu_address_out => alu_address_mem_wb1,\n\t\t-- \t\tmem_to_reg_out => mem_to_reg_mem_wb1,\n\t\t-- \t\tis_pop_out => is_pop_mem_wb1,\n\t\t-- \t\tout_enable_out => out_enable_mem_wb1,\n\t\t-- \t\tis_swap_out => is_swap_mem_wb1,\n\t\t-- \t\tswap_phase_out => swap_phase_mem_wb1,\n\t\t-- \t\treg_write_out => reg_write_mem_wb1,\n\t\t-- \t\tis_call_out => is_call_mem_wb1,\n\t\t-- \t\tis_input_out => is_input_mem_wb1,\n\t\t-- \t\trdst => rdst_ex_mem2,\n\t\t-- \t\trsrc1 => rsrc1_ex_mem2,\n\t\t-- \t\tr_data2 => r_data2_ex_mem2,\n\t\t-- \t\talu_result => alu_result_ex_mem2,\n\t\t-- \t\tmem_read_data => mem_read_data_ex_mem2,\n\t\t-- \t\tinput_port_data => input_port_data_ex_mem2,\n\t\t-- \t\trdst_out => rdst_mem_wb1,\n\t\t-- \t\trsrc1_out => rsrc1_mem_wb1,\n\t\t-- \t\tr_data2_out => r_data2_mem_wb1,\n\t\t-- \t\talu_result_out => alu_result_mem_wb1,\n\t\t-- \t\tmem_data_out => mem_data_mem_wb1,\n\t\t-- \t\tinput_port_data_out => input_port_data_mem_wb1\n    --     );
		  
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
    
    -- Memory System Instantiation (commented out - entity not yet created)
    -- Mem_Sys: Memory_System
    --     generic map (
    --         ADDR_WIDTH => 32,
    --         DATA_WIDTH => 32,
    --         MEM_SIZE => 1024
    --     )
    --     port map (
    --         clk => clk,
    --         rst => rst,
    --         fetch_address => fetch_mem_address,
    --         fetch_read_enable => fetch_mem_read_enable,
    --         fetch_read_data => fetch_mem_read_data,
    --         mem_address => mem_stage_address,
    --         mem_write_data => mem_stage_write_data,
    --         mem_write_enable => mem_stage_write_enable,
    --         mem_read_enable => mem_stage_read_enable,
    --         mem_read_data => mem_stage_read_data,
    --         mem_stage_priority => mem_stage_priority
    --     );
    
    -- Temporary assignments for memory signals
    fetch_mem_address <= fetch_pc_out;
    fetch_mem_read_enable <= '1';
    fetch_mem_read_data <= (others => '0');  -- Default
    
    -- Debug outputs
    debug_pc <= fetch_mem_address;
    debug_instruction <= fetch_instruction;
    
end Structural;
