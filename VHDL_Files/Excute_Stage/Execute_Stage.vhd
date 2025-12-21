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
        id_ex_has_one_operand  : in  STD_LOGIC;
        id_ex_has_two_operands : in  STD_LOGIC;
        id_ex_alu_address_enable: in STD_LOGIC;
        
        -- Immediate value from IF/ID Pipeline Register
        if_id_immediate        : in  STD_LOGIC_VECTOR(31 downto 0);
        
        -- Input Port (from top module)
        input_port             : in  STD_LOGIC_VECTOR(31 downto 0);
        
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
        ex_mem_alu_address_enable: out STD_LOGIC;
        ex_mem_read_reg1       : out STD_LOGIC_VECTOR(2 downto 0);
        ex_mem_write_reg       : out STD_LOGIC_VECTOR(2 downto 0);
        ex_mem_read_data2      : out STD_LOGIC_VECTOR(31 downto 0);
        ex_mem_alu_result      : out STD_LOGIC_VECTOR(31 downto 0);
        ex_mem_input_port_data : out STD_LOGIC_VECTOR(31 downto 0);
        ex_mem_has_one_operand : out STD_LOGIC;
        ex_mem_has_two_operands: out STD_LOGIC;
        
        -- Direct outputs (not to EX/MEM register)
        conditional_jump       : out STD_LOGIC;  -- OR of all conditional branches
        pc_plus_2              : out STD_LOGIC_VECTOR(31 downto 0)  -- PC+1+1 for branches
    );
end Execute_Stage;

architecture Behavioral of Execute_Stage is
    
    -- Component Declarations
    component ALU is
        Port (
            A          : in  STD_LOGIC_VECTOR(31 downto 0);
            B          : in  STD_LOGIC_VECTOR(31 downto 0);
            ALU_Op     : in  STD_LOGIC_VECTOR(3 downto 0);
            Result     : out STD_LOGIC_VECTOR(31 downto 0);
            Zero_Flag  : out STD_LOGIC;
            Carry_Flag : out STD_LOGIC;
            Neg_Flag   : out STD_LOGIC;
            CCR_Enable : out STD_LOGIC
        );
    end component;
    
    component CCR_Mux is
        Port (
            selector    : in  STD_LOGIC_VECTOR(1 downto 0);
            ccr_alu     : in  STD_LOGIC_VECTOR(31 downto 0);
            ccr_branch  : in  STD_LOGIC_VECTOR(31 downto 0);
            ccr_stack   : in  STD_LOGIC_VECTOR(31 downto 0);
            mux_out     : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component CCR_Branch_Unit is
        Port (
            current_ccr         : in  STD_LOGIC_VECTOR(31 downto 0);
            conditional_branchZ : in  STD_LOGIC;
            conditional_branchC : in  STD_LOGIC;
            conditional_branchN : in  STD_LOGIC;
            ccr_out             : out STD_LOGIC_VECTOR(31 downto 0)
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
    signal alu_zero_flag       : STD_LOGIC := '0';
    signal alu_carry_flag      : STD_LOGIC := '0';
    signal alu_neg_flag        : STD_LOGIC := '0';
    signal alu_ccr_enable      : STD_LOGIC := '0';
    
    signal ccr_register_out    : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal ccr_mux_out         : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal ccr_z_flag          : STD_LOGIC := '0';
    signal ccr_c_flag          : STD_LOGIC := '0';
    signal ccr_n_flag          : STD_LOGIC := '0';
    signal ccr_write_enable    : STD_LOGIC := '1';
    
    -- CCR source signals
    signal ccr_from_alu        : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal ccr_from_branch     : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal ccr_from_stack      : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    
    signal cond_branchZ        : STD_LOGIC := '0';
    signal cond_branchC        : STD_LOGIC := '0';
    signal cond_branchN        : STD_LOGIC := '0';
    
begin
    
    -- Operand A Selection Process (handles 2-bit forwarding from Processor_Top)
    -- forward_mux_a_sel: 00 = ID/EX, 01 = EX/MEM, 10 = MEM/WB
    process(id_ex_read_data1, forward_ex_mem, forward_mem_wb, forward_mux_a_sel)
    begin
        case forward_mux_a_sel is
            when "00" =>
                alu_operand_a <= id_ex_read_data1;  -- Normal path from ID/EX
            when "01" =>
                alu_operand_a <= forward_ex_mem;    -- Forward from EX/MEM
            when "10" =>
                alu_operand_a <= forward_mem_wb;    -- Forward from MEM/WB
            when others =>
                alu_operand_a <= id_ex_read_data1;  -- Default
        end case;
    end process;
    
    -- Operand B Selection Process (handles forwarding + immediate)
    -- Priority: Immediate value overrides forwarding
    -- forward_mux_b_sel: 00 = ID/EX, 01 = EX/MEM, 10 = MEM/WB
    process(id_ex_read_data2, forward_ex_mem, forward_mem_wb, 
            if_id_immediate, id_ex_is_immediate, forward_mux_b_sel)
    begin
        if id_ex_is_immediate = '1' then
            -- Immediate value has highest priority
            alu_operand_b <= if_id_immediate;
        else
            -- Use forwarding logic
            case forward_mux_b_sel is
                when "00" =>
                    alu_operand_b <= id_ex_read_data2;  -- Normal path from ID/EX
                when "01" =>
                    alu_operand_b <= forward_ex_mem;    -- Forward from EX/MEM
                when "10" =>
                    alu_operand_b <= forward_mem_wb;    -- Forward from MEM/WB
                when others =>
                    alu_operand_b <= id_ex_read_data2;  -- Default
            end case;
        end if;
    end process;
    
    -- ALU
    alu_unit: ALU
        port map (
            A          => alu_operand_a,
            B          => alu_operand_b,
            ALU_Op     => id_ex_alu_op,
            Result     => alu_result_internal,
            Zero_Flag  => alu_zero_flag,
            Carry_Flag => alu_carry_flag,
            Neg_Flag   => alu_neg_flag,
            CCR_Enable => alu_ccr_enable
        );
    
    -- ========================================
    -- CCR (Condition Code Register) Logic
    -- ========================================
    
    -- Build CCR from ALU flags (Source 00)
    -- Selectively update flags based on ALU operation
    -- Different instructions update different flags:
    --   SETC (0001): Updates C only
    --   NOT  (0100): Updates Z, N only (preserves C)
    --   INC  (0101): Updates Z, N, C
    --   AND  (0110): Updates Z, N only (preserves C)
    --   ADD  (1000): Updates Z, N, C
    --   SUB  (1001): Updates Z, N only (preserves C)
    process(alu_zero_flag, alu_carry_flag, alu_neg_flag, ccr_register_out, id_ex_alu_op)
        variable new_z : STD_LOGIC;
        variable new_c : STD_LOGIC;
        variable new_n : STD_LOGIC;
    begin
        -- Default: keep current CCR values
        new_z := ccr_register_out(0);  -- Current Z flag
        new_c := ccr_register_out(1);  -- Current C flag
        new_n := ccr_register_out(2);  -- Current N flag
        
        case id_ex_alu_op is
            when "0001" =>  -- SETC: Only update C flag
                new_c := alu_carry_flag;
                
            when "0100" =>  -- NOT: Update Z and N, preserve C
                new_z := alu_zero_flag;
                new_n := alu_neg_flag;
                
            when "0101" =>  -- INC: Update Z, N, and C
                new_z := alu_zero_flag;
                new_c := alu_carry_flag;
                new_n := alu_neg_flag;
                
            when "0110" =>  -- AND: Update Z and N, preserve C
                new_z := alu_zero_flag;
                new_n := alu_neg_flag;
                
            when "1000" =>  -- ADD/IADD: Update Z, N, and C
                new_z := alu_zero_flag;
                new_c := alu_carry_flag;
                new_n := alu_neg_flag;
                
            when "1001" =>  -- SUB: Update Z and N, preserve C
                new_z := alu_zero_flag;
                new_n := alu_neg_flag;
                
            when others =>
                -- For other operations, keep current values
                null;
        end case;
        
        -- Construct 32-bit CCR value
        ccr_from_alu <= "00000000000000000000000000000" & new_n & new_c & new_z;
    end process;
    
    -- Build CCR from stack (Source 10) - for RTI
    ccr_from_stack <= (others => '0');  -- TODO: Connect to actual stack data when available
    
    -- CCR Branch Unit (clears flags after conditional branch)
    ccr_branch_inst: CCR_Branch_Unit
        port map (
            current_ccr         => ccr_register_out,
            conditional_branchZ => cond_branchZ,
            conditional_branchC => cond_branchC,
            conditional_branchN => cond_branchN,
            ccr_out             => ccr_from_branch
        );
    
    -- CCR Multiplexer (selects which source to write to CCR)
    ccr_mux_unit: CCR_Mux
        port map (
            selector   => id_ex_ccr_in,
            ccr_alu    => ccr_from_alu,
            ccr_branch => ccr_from_branch,
            ccr_stack  => ccr_from_stack,
            mux_out    => ccr_mux_out
        );
    
    -- CCR write enable logic:
    -- Enable when: 
    --   - Selector = "00" AND ALU_CCR_Enable = '1' (ALU operations: NOT, INC, ADD, SUB, AND, SETC)
    --   - Selector = "01" (Branch flag clearing: JZ, JC, JN)
    --   - Selector = "10" (Stack restoration: RTI)
    ccr_write_enable <= '1' when (id_ex_ccr_in = "00" and alu_ccr_enable = '1') else
                        '1' when (id_ex_ccr_in = "01") else
                        '1' when (id_ex_ccr_in = "10") else
                        '0';
    
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
    pc_plus_2 <= std_logic_vector(unsigned(id_ex_pc_plus_1) + 1);
    
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
    ex_mem_alu_address_enable <= id_ex_alu_address_enable;
    
    -- Pass-through register addresses
    ex_mem_read_reg1  <= id_ex_read_reg1;
    ex_mem_write_reg  <= id_ex_write_reg;
    
    -- Pass-through data
    ex_mem_read_data2 <= id_ex_read_data2;  -- For store operations
  
    
    -- ALU result output
    ex_mem_alu_result <= alu_result_internal;
    
    -- Input port data output (for IN instruction)
    ex_mem_input_port_data <= input_port;
    
    -- Pass-through operand count signals
    ex_mem_has_one_operand <= id_ex_has_one_operand;
    ex_mem_has_two_operands <= id_ex_has_two_operands;
    
end Behavioral;
