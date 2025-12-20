-- vhdl-linter-disable type-resolved
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- ID/EX Pipeline Register
-- Passes control signals and data from Decode Stage to Execute Stage
-- Based on assembler.py encoding and control unit signals

entity ID_EX_register is
    Port (
        clk                   : in  STD_LOGIC;
        rst                   : in  STD_LOGIC;
        enable                : in  STD_LOGIC;  -- Enable signal
        flush                 : in  STD_LOGIC;  -- Flush signal
        hlt                   : in  STD_LOGIC;  -- Halt signal freezes pipeline
        
        -- Inputs from Decode Stage (ID)
        -- PC from IF/ID register
        pc_in_plus_1              : in  STD_LOGIC_VECTOR(31 downto 0);
        
        -- Register data
        read_data1_in         : in  STD_LOGIC_VECTOR(31 downto 0);  -- Rs1 data
        read_data2_in         : in  STD_LOGIC_VECTOR(31 downto 0);  -- Rs2 data
        
        -- Register addresses
        read_reg1_in          : in  STD_LOGIC_VECTOR(2 downto 0);   -- Rs1 address
        write_reg_in          : in  STD_LOGIC_VECTOR(2 downto 0);   -- Rd address
        
        -- Control Signals (ALL except unconditional_branch)
        mem_write_in          : in  STD_LOGIC;
        mem_read_in           : in  STD_LOGIC;
        mem_to_reg_in         : in  STD_LOGIC;
        alu_op_in             : in  STD_LOGIC_VECTOR(3 downto 0);
        out_enable_in         : in  STD_LOGIC;
        ccr_in_in             : in  STD_LOGIC_VECTOR(1 downto 0);
        is_swap_in            : in  STD_LOGIC;
        swap_phase_in         : in  STD_LOGIC;
        reg_write_in          : in  STD_LOGIC;
        is_immediate_in       : in  STD_LOGIC;
        is_call_in            : in  STD_LOGIC;
        hlt_in                : in  STD_LOGIC;
        is_int_in             : in  STD_LOGIC;
        is_in_in              : in  STD_LOGIC;
        is_pop_in             : in  STD_LOGIC;
        is_push_in            : in  STD_LOGIC;
        int_phase_in          : in  STD_LOGIC;
        is_rti_in             : in  STD_LOGIC;
        rti_phase_in          : in  STD_LOGIC;
        is_ret_in             : in  STD_LOGIC;
        branchZ_in            : in  STD_LOGIC;
        branchC_in            : in  STD_LOGIC;
        branchN_in            : in  STD_LOGIC;
        has_one_operand_in    : in  STD_LOGIC;
        has_two_operands_in   : in  STD_LOGIC;
        -- unconditional_branch is NOT passed (excluded as per requirement)
        
        -- Outputs to Execute Stage (EX)
        -- PC output
        pc_out_plus_1              : out STD_LOGIC_VECTOR(31 downto 0);
        
        -- Register data
        read_data1_out        : out STD_LOGIC_VECTOR(31 downto 0);  -- Rs1 data
        read_data2_out        : out STD_LOGIC_VECTOR(31 downto 0);  -- Rs2 data
        
        -- Register addresses
        read_reg1_out         : out STD_LOGIC_VECTOR(2 downto 0);   -- Rs1 address
        write_reg_out         : out STD_LOGIC_VECTOR(2 downto 0);   -- Rd address
        
        -- Control Signals
        mem_write_out         : out STD_LOGIC;
        mem_read_out          : out STD_LOGIC;
        mem_to_reg_out        : out STD_LOGIC;
        alu_op_out            : out STD_LOGIC_VECTOR(3 downto 0);
        out_enable_out        : out STD_LOGIC;
        ccr_in_out            : out STD_LOGIC_VECTOR(1 downto 0);
        is_swap_out           : out STD_LOGIC;
        swap_phase_out        : out STD_LOGIC;
        reg_write_out         : out STD_LOGIC;
        is_immediate_out      : out STD_LOGIC;
        is_call_out           : out STD_LOGIC;
        hlt_out               : out STD_LOGIC;
        is_int_out            : out STD_LOGIC;
        is_in_out             : out STD_LOGIC;
        is_pop_out            : out STD_LOGIC;
        is_push_out           : out STD_LOGIC;
        int_phase_out         : out STD_LOGIC;
        is_rti_out            : out STD_LOGIC;
        rti_phase_out         : out STD_LOGIC;
        is_ret_out            : out STD_LOGIC;
        branchZ_out           : out STD_LOGIC;
        branchC_out           : out STD_LOGIC;
        branchN_out           : out STD_LOGIC;
        has_one_operand_out   : out STD_LOGIC;
        has_two_operands_out  : out STD_LOGIC
    );
end ID_EX_register;

architecture Behavioral of ID_EX_register is
    
    -- Pipeline register storage
    signal pc_reg                : STD_LOGIC_VECTOR(31 downto 0);
    signal read_data1_reg        : STD_LOGIC_VECTOR(31 downto 0);
    signal read_data2_reg        : STD_LOGIC_VECTOR(31 downto 0);
    signal read_reg1_reg         : STD_LOGIC_VECTOR(2 downto 0);
    signal write_reg_reg         : STD_LOGIC_VECTOR(2 downto 0);
    
    -- Control signal registers
    signal mem_write_reg         : STD_LOGIC;
    signal mem_read_reg          : STD_LOGIC;
    signal mem_to_reg_reg        : STD_LOGIC;
    signal alu_op_reg            : STD_LOGIC_VECTOR(3 downto 0);
    signal out_enable_reg        : STD_LOGIC;
    signal ccr_in_reg            : STD_LOGIC_VECTOR(1 downto 0);
    signal is_swap_reg           : STD_LOGIC;
    signal swap_phase_reg        : STD_LOGIC;
    signal reg_write_reg         : STD_LOGIC;
    signal is_immediate_reg      : STD_LOGIC;
    signal is_call_reg           : STD_LOGIC;
    signal hlt_reg               : STD_LOGIC;
    signal is_int_reg            : STD_LOGIC;
    signal is_in_reg             : STD_LOGIC;
    signal is_pop_reg            : STD_LOGIC;
    signal is_push_reg           : STD_LOGIC;
    signal int_phase_reg         : STD_LOGIC;
    signal is_rti_reg            : STD_LOGIC;
    signal rti_phase_reg         : STD_LOGIC;
    signal is_ret_reg            : STD_LOGIC;
    signal branchZ_reg           : STD_LOGIC;
    signal branchC_reg           : STD_LOGIC;
    signal branchN_reg           : STD_LOGIC;
    signal has_one_operand_reg   : STD_LOGIC;
    signal has_two_operands_reg  : STD_LOGIC;
    
begin
    
    -- Synchronous pipeline register update
    process(clk, rst)
    begin
        if rst = '1' then
            -- Reset all pipeline registers
            pc_reg              <= (others => '0');
            read_data1_reg      <= (others => '0');
            read_data2_reg      <= (others => '0');
            read_data2_reg      <= (others => '0');
            read_reg1_reg       <= (others => '0');
            write_reg_reg       <= (others => '0');
            
            -- Reset control signals0';
            mem_read_reg        <= '0';
            mem_to_reg_reg      <= '0';
            alu_op_reg          <= (others => '0');
            out_enable_reg      <= '0';
            ccr_in_reg          <= (others => '0');
            is_swap_reg         <= '0';
            swap_phase_reg      <= '0';
            reg_write_reg       <= '0';
            is_immediate_reg    <= '0';
            is_call_reg         <= '0';
            hlt_reg             <= '0';
            is_int_reg          <= '0';
            is_in_reg           <= '0';
            is_pop_reg          <= '0';
            is_push_reg         <= '0';
            int_phase_reg       <= '0';
            is_rti_reg          <= '0';
            rti_phase_reg       <= '0';
            is_ret_reg          <= '0';
            branchZ_reg         <= '0';
            branchC_reg         <= '0';
            branchN_reg         <= '0';
            has_one_operand_reg <= '0';
            has_two_operands_reg <= '0';
            
        elsif rising_edge(clk) then
            if flush = '1' then
                -- Flush: Clear all registers (insert bubble/NOP)
                pc_reg              <= (others => '0');
                read_data1_reg      <= (others => '0');
                read_data2_reg      <= (others => '0');
                read_reg1_reg       <= (others => '0');
                write_reg_reg       <= (others => '0');
                mem_write_reg       <= '0';
                mem_read_reg        <= '0';
                mem_to_reg_reg      <= '0';
                alu_op_reg          <= (others => '0');
                out_enable_reg      <= '0';
                ccr_in_reg          <= (others => '0');
                is_swap_reg         <= '0';
                swap_phase_reg      <= '0';
                reg_write_reg       <= '0';
                is_immediate_reg    <= '0';
                is_call_reg         <= '0';
                hlt_reg             <= '0';
                is_int_reg          <= '0';
                is_in_reg           <= '0';
                is_pop_reg          <= '0';
                is_push_reg         <= '0';
                int_phase_reg       <= '0';
                is_rti_reg          <= '0';
                rti_phase_reg       <= '0';
                is_ret_reg          <= '0';
                branchZ_reg         <= '0';
                branchC_reg         <= '0';
                branchN_reg         <= '0';
                has_one_operand_reg <= '0';
                has_two_operands_reg <= '0';
            elsif enable = '1' and hlt = '0' then
                -- Update pipeline registers only if enabled and not halted
                pc_reg              <= pc_in_plus_1;
                read_data1_reg      <= read_data1_in;
                read_data2_reg      <= read_data2_in;
                read_reg1_reg       <= read_reg1_in;
                write_reg_reg       <= write_reg_in;
                
                -- Update control signals
                mem_write_reg       <= mem_write_in;
                mem_read_reg        <= mem_read_in;
                mem_to_reg_reg      <= mem_to_reg_in;
                alu_op_reg          <= alu_op_in;
                out_enable_reg      <= out_enable_in;
                ccr_in_reg          <= ccr_in_in;
                is_swap_reg         <= is_swap_in;
                swap_phase_reg      <= swap_phase_in;
                reg_write_reg       <= reg_write_in;
                is_immediate_reg    <= is_immediate_in;
                is_call_reg         <= is_call_in;
                hlt_reg             <= hlt_in;
                is_int_reg          <= is_int_in;
                is_in_reg           <= is_in_in;
                is_pop_reg          <= is_pop_in;
                is_push_reg         <= is_push_in;
                int_phase_reg       <= int_phase_in;
                is_rti_reg          <= is_rti_in;
                rti_phase_reg       <= rti_phase_in;
                is_ret_reg          <= is_ret_in;
                branchZ_reg         <= branchZ_in;
                branchC_reg         <= branchC_in;
                branchN_reg         <= branchN_in;
                has_one_operand_reg <= has_one_operand_in;
                has_two_operands_reg <= has_two_operands_in;
            end if;
            -- When hlt = '1' or enable = '0', all registers freeze (maintain current values)
        end if;
    end process;
    
    -- Assign outputs from internal registers
    pc_out_plus_1       <= pc_reg;
    read_data1_out      <= read_data1_reg;
    read_data2_out      <= read_data2_reg;
    read_reg1_out       <= read_reg1_reg;
    write_reg_out       <= write_reg_reg;
    
    -- Control signal outputs
    mem_write_out       <= mem_write_reg;
    mem_read_out        <= mem_read_reg;
    mem_to_reg_out      <= mem_to_reg_reg;
    alu_op_out          <= alu_op_reg;
    out_enable_out      <= out_enable_reg;
    ccr_in_out          <= ccr_in_reg;
    is_swap_out         <= is_swap_reg;
    swap_phase_out      <= swap_phase_reg;
    reg_write_out       <= reg_write_reg;
    is_immediate_out    <= is_immediate_reg;
    is_call_out         <= is_call_reg;
    hlt_out             <= hlt_reg;
    is_int_out          <= is_int_reg;
    is_in_out           <= is_in_reg;
    is_pop_out          <= is_pop_reg;
    is_push_out         <= is_push_reg;
    int_phase_out       <= int_phase_reg;
    is_rti_out          <= is_rti_reg;
    rti_phase_out       <= rti_phase_reg;
    is_ret_out          <= is_ret_reg;
    branchZ_out         <= branchZ_reg;
    branchC_out         <= branchC_reg;
    branchN_out         <= branchN_reg;
    has_one_operand_out <= has_one_operand_reg;
    has_two_operands_out <= has_two_operands_reg;
    
end Behavioral;
