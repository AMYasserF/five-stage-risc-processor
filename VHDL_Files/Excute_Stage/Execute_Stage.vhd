-- vhdl-linter-disable type-resolved
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- Execute Stage for Five-Stage RISC Processor
-- Performs ALU operations, handles forwarding, and determines branch conditions

entity Execute_Stage is
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        
        -- Inputs from ID/EX Pipeline Register
        id_ex_read_data1       : in  STD_LOGIC_VECTOR(31 downto 0);
        id_ex_read_data2       : in  STD_LOGIC_VECTOR(31 downto 0);
        id_ex_pc_plus_1        : in  STD_LOGIC_VECTOR(31 downto 0);
        id_ex_read_reg1        : in  STD_LOGIC_VECTOR(2 downto 0);
        id_ex_write_reg        : in  STD_LOGIC_VECTOR(2 downto 0);
        
        -- Control signals from ID/EX
        id_ex_mem_write        : in  STD_LOGIC;
        id_ex_mem_read         : in  STD_LOGIC;
        id_ex_mem_to_reg       : in  STD_LOGIC;
        id_ex_alu_op           : in  STD_LOGIC_VECTOR(3 downto 0);
        id_ex_out_enable       : in  STD_LOGIC;
        id_ex_ccr_in           : in  STD_LOGIC_VECTOR(1 downto 0);
        id_ex_is_swap          : in  STD_LOGIC;
        id_ex_swap_phase       : in  STD_LOGIC;
        id_ex_reg_write        : in  STD_LOGIC;
        id_ex_is_immediate     : in  STD_LOGIC;
        id_ex_is_call          : in  STD_LOGIC;
        id_ex_is_ret           : in  STD_LOGIC;
        id_ex_is_push          : in  STD_LOGIC;
        id_ex_is_pop           : in  STD_LOGIC;
        id_ex_is_in            : in  STD_LOGIC;
        id_ex_hlt              : in  STD_LOGIC;
        id_ex_is_int           : in  STD_LOGIC;
        id_ex_int_phase        : in  STD_LOGIC;
        id_ex_is_rti           : in  STD_LOGIC;
        id_ex_rti_phase        : in  STD_LOGIC;
        id_ex_branchZ          : in  STD_LOGIC;
        id_ex_branchC          : in  STD_LOGIC;
        id_ex_branchN          : in  STD_LOGIC;
        
        -- Immediate value from IF/ID Pipeline Register
        if_id_immediate        : in  STD_LOGIC_VECTOR(31 downto 0);
        
        -- Forwarding inputs (will be connected to forwarding unit later)
        forward_ex_mem         : in  STD_LOGIC_VECTOR(31 downto 0);
        forward_mem_wb         : in  STD_LOGIC_VECTOR(31 downto 0);
        forward_mux_a_sel      : in  STD_LOGIC_VECTOR(1 downto 0);  -- From forwarding unit
        forward_mux_b_sel      : in  STD_LOGIC_VECTOR(1 downto 0);  -- From forwarding unit (without immediate bit)
        
        -- Outputs to EX/MEM Pipeline Register
        ex_mem_rti_phase       : out STD_LOGIC;
        ex_mem_int_phase       : out STD_LOGIC;
        ex_mem_mem_write       : out STD_LOGIC;
        ex_mem_mem_read        : out STD_LOGIC;
        ex_mem_mem_to_reg      : out STD_LOGIC;
        ex_mem_out_enable      : out STD_LOGIC;
        ex_mem_is_swap         : out STD_LOGIC;
        ex_mem_swap_phase      : out STD_LOGIC;
        ex_mem_reg_write       : out STD_LOGIC;
        ex_mem_is_call         : out STD_LOGIC;
        ex_mem_is_ret          : out STD_LOGIC;
        ex_mem_is_push         : out STD_LOGIC;
        ex_mem_is_pop          : out STD_LOGIC;
        ex_mem_is_in           : out STD_LOGIC;
        ex_mem_is_int          : out STD_LOGIC;
        ex_mem_is_rti          : out STD_LOGIC;
        ex_mem_hlt             : out STD_LOGIC;
        ex_mem_read_reg1       : out STD_LOGIC_VECTOR(2 downto 0);
        ex_mem_write_reg       : out STD_LOGIC_VECTOR(2 downto 0);
        ex_mem_read_data2      : out STD_LOGIC_VECTOR(31 downto 0);
        ex_mem_alu_result      : out STD_LOGIC_VECTOR(31 downto 0);
        
        -- Direct outputs (not to EX/MEM register)
        conditional_jump       : out STD_LOGIC;  -- OR of all conditional branches
        pc_plus_2              : out STD_LOGIC_VECTOR(31 downto 0)  -- PC+1+1 for branches
    );
end Execute_Stage;

architecture Behavioral of Execute_Stage is
    
    -- Component Declarations
    component ALU_OperandA_Mux is
        Port (
            read_data1      : in  STD_LOGIC_VECTOR(31 downto 0);
            ex_mem_forward  : in  STD_LOGIC_VECTOR(31 downto 0);
            mem_wb_forward  : in  STD_LOGIC_VECTOR(31 downto 0);
            select_sig      : in  STD_LOGIC_VECTOR(1 downto 0);
            operand_a       : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component ALU_OperandB_Mux is
        Port (
            read_data2      : in  STD_LOGIC_VECTOR(31 downto 0);
            ex_mem_forward  : in  STD_LOGIC_VECTOR(31 downto 0);
            mem_wb_forward  : in  STD_LOGIC_VECTOR(31 downto 0);
            immediate       : in  STD_LOGIC_VECTOR(31 downto 0);
            select_sig      : in  STD_LOGIC_VECTOR(1 downto 0);
            operand_b       : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component ALU is
        Port (
            A          : in  STD_LOGIC_VECTOR(31 downto 0);
            B          : in  STD_LOGIC_VECTOR(31 downto 0);
            ALU_Op     : in  STD_LOGIC_VECTOR(3 downto 0);
            Result     : out STD_LOGIC_VECTOR(31 downto 0);
            Zero_Flag  : out STD_LOGIC;
            Carry_Flag : out STD_LOGIC;
            Neg_Flag   : out STD_LOGIC
        );
    end component;
    
    component CCR_Mux is
        Port (
            selector            : in  STD_LOGIC_VECTOR(1 downto 0);
            alu_Z               : in  STD_LOGIC;
            alu_C               : in  STD_LOGIC;
            alu_N               : in  STD_LOGIC;
            stack_data_in       : in  STD_LOGIC_VECTOR(31 downto 0);
            conditional_branchZ : in  STD_LOGIC;
            conditional_branchC : in  STD_LOGIC;
            conditional_branchN : in  STD_LOGIC;
            mux_out             : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component CCR_Register is
        Port (
            clk    : in  STD_LOGIC;
            rst    : in  STD_LOGIC;
            wen    : in  STD_LOGIC;
            D_in   : in  STD_LOGIC_VECTOR(31 downto 0);
            Q_out  : out STD_LOGIC_VECTOR(31 downto 0);
            Z_flag : out STD_LOGIC;
            C_flag : out STD_LOGIC;
            N_flag : out STD_LOGIC
        );
    end component;
    
    component Branch_Logic is
        Port (
            branchZ             : in  STD_LOGIC;
            branchC             : in  STD_LOGIC;
            branchN             : in  STD_LOGIC;
            ccrZ                : in  STD_LOGIC;
            ccrC                : in  STD_LOGIC;
            ccrN                : in  STD_LOGIC;
            conditional_branchZ : out STD_LOGIC;
            conditional_branchC : out STD_LOGIC;
            conditional_branchN : out STD_LOGIC
        );
    end component;
    
    -- Internal Signals
    signal alu_operand_a       : STD_LOGIC_VECTOR(31 downto 0);
    signal alu_operand_b       : STD_LOGIC_VECTOR(31 downto 0);
    signal alu_result_internal : STD_LOGIC_VECTOR(31 downto 0);
    signal alu_zero_flag       : STD_LOGIC;
    signal alu_carry_flag      : STD_LOGIC;
    signal alu_neg_flag        : STD_LOGIC;
    
    signal ccr_register_out    : STD_LOGIC_VECTOR(31 downto 0);
    signal ccr_mux_out         : STD_LOGIC_VECTOR(31 downto 0);
    signal ccr_z_flag          : STD_LOGIC;
    signal ccr_c_flag          : STD_LOGIC;
    signal ccr_n_flag          : STD_LOGIC;
    signal ccr_write_enable    : STD_LOGIC;
    
    signal cond_branchZ        : STD_LOGIC;
    signal cond_branchC        : STD_LOGIC;
    signal cond_branchN        : STD_LOGIC;
    
    signal mux_b_select        : STD_LOGIC_VECTOR(1 downto 0);
    
begin
    
    -- Operand A Multiplexer (forwarding only)
    mux_a: ALU_OperandA_Mux
        port map (
            read_data1     => id_ex_read_data1,
            ex_mem_forward => forward_ex_mem,
            mem_wb_forward => forward_mem_wb,
            select_sig     => forward_mux_a_sel,
            operand_a      => alu_operand_a
        );
    
    -- Operand B Multiplexer (forwarding + immediate)
    -- Select signal: MSB is is_immediate flag, LSB is from forwarding unit
    mux_b_select <= id_ex_is_immediate & forward_mux_b_sel(0) when id_ex_is_immediate = '1' else forward_mux_b_sel;
    
    mux_b: ALU_OperandB_Mux
        port map (
            read_data2     => id_ex_read_data2,
            ex_mem_forward => forward_ex_mem,
            mem_wb_forward => forward_mem_wb,
            immediate      => if_id_immediate,
            select_sig     => mux_b_select,
            operand_b      => alu_operand_b
        );
    
    -- ALU
    alu_unit: ALU
        port map (
            A          => alu_operand_a,
            B          => alu_operand_b,
            ALU_Op     => id_ex_alu_op,
            Result     => alu_result_internal,
            Zero_Flag  => alu_zero_flag,
            Carry_Flag => alu_carry_flag,
            Neg_Flag   => alu_neg_flag
        );
    
    -- CCR write enable: always enabled (mux selects what to write)
    ccr_write_enable <= '1';
    
    -- CCR Multiplexer
    ccr_mux_unit: CCR_Mux
        port map (
            selector            => id_ex_ccr_in,
            alu_Z               => alu_zero_flag,
            alu_C               => alu_carry_flag,
            alu_N               => alu_neg_flag,
            stack_data_in       => (others => '0'),  -- TODO: Connect to stack/memory data
            conditional_branchZ => cond_branchZ,
            conditional_branchC => cond_branchC,
            conditional_branchN => cond_branchN,
            mux_out             => ccr_mux_out
        );
    
    -- CCR Register
    ccr_reg: CCR_Register
        port map (
            clk    => clk,
            rst    => rst,
            wen    => ccr_write_enable,
            D_in   => ccr_mux_out,
            Q_out  => ccr_register_out,
            Z_flag => ccr_z_flag,
            C_flag => ccr_c_flag,
            N_flag => ccr_n_flag
        );
    
    -- Branch Logic
    branch_logic_unit: Branch_Logic
        port map (
            branchZ             => id_ex_branchZ,
            branchC             => id_ex_branchC,
            branchN             => id_ex_branchN,
            ccrZ                => ccr_z_flag,
            ccrC                => ccr_c_flag,
            ccrN                => ccr_n_flag,
            conditional_branchZ => cond_branchZ,
            conditional_branchC => cond_branchC,
            conditional_branchN => cond_branchN
        );
    
    -- Conditional jump signal (OR of all conditional branches)
    conditional_jump <= cond_branchZ or cond_branchC or cond_branchN;
    
    -- PC+2 calculation (PC+1 from ID/EX + 1)
    pc_plus_2 <=id_ex_pc_plus_1;
    
    -- Pass-through control signals to EX/MEM Pipeline Register
    ex_mem_rti_phase  <= id_ex_rti_phase;
    ex_mem_int_phase  <= id_ex_int_phase;
    ex_mem_mem_write  <= id_ex_mem_write;
    ex_mem_mem_read   <= id_ex_mem_read;
    ex_mem_mem_to_reg <= id_ex_mem_to_reg;
    ex_mem_out_enable <= id_ex_out_enable;
    ex_mem_is_swap    <= id_ex_is_swap;
    ex_mem_swap_phase <= id_ex_swap_phase;
    ex_mem_reg_write  <= id_ex_reg_write;
    ex_mem_is_call    <= id_ex_is_call;
    ex_mem_is_ret     <= id_ex_is_ret;
    ex_mem_is_push    <= id_ex_is_push;
    ex_mem_is_pop     <= id_ex_is_pop;
    ex_mem_is_in      <= id_ex_is_in;
    ex_mem_is_int     <= id_ex_is_int;
    ex_mem_is_rti     <= id_ex_is_rti;
    ex_mem_hlt        <= id_ex_hlt;
    
    -- Pass-through register addresses
    ex_mem_read_reg1  <= id_ex_read_reg1;
    ex_mem_write_reg  <= id_ex_write_reg;
    
    -- Pass-through data
    ex_mem_read_data2 <= id_ex_read_data2;  -- For store operations
  
    
    -- ALU result output
    ex_mem_alu_result <= alu_result_internal;
    
end Behavioral;
