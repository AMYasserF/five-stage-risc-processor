LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- Decode Stage for Five-Stage RISC Processor
-- Based on assembler.py instruction encoding
-- Instruction format [31:0]:
--   [31:25] = Opcode (7 bits) - [6]=hasImm, [5:4]=Type, [3:0]=Function
--   [24:22] = Rd (3 bits) - destination register
--   [21:19] = Rs1 (3 bits) - source register 1
--   [18:16] = Rs2 (3 bits) - source register 2
--   [15:0]  = Reserved/Unused

entity decode_stage is
    Port (
        clk                   : in  STD_LOGIC;
        rst                   : in  STD_LOGIC;
        
        -- Input from Fetch Stage
        instruction           : in  STD_LOGIC_VECTOR(31 downto 0);  -- Full 32-bit instruction
        pc_in_plus_1          : in  STD_LOGIC_VECTOR(31 downto 0);  -- Program counter
        
        -- From Writeback Stage (for register write)
        wb_write_enable       : in  STD_LOGIC;
        wb_write_reg          : in  STD_LOGIC_VECTOR(2 downto 0);
        wb_write_data         : in  STD_LOGIC_VECTOR(31 downto 0);
        
        -- Previous instruction immediate flag (for pipeline control)
        previous_is_immediate : in  STD_LOGIC;
        
        -- Register file outputs
        read_data1            : out STD_LOGIC_VECTOR(31 downto 0);  -- Rs1 data
        read_data2            : out STD_LOGIC_VECTOR(31 downto 0);  -- Rs2 data
        
        -- Decoded fields
        opcode                : out STD_LOGIC_VECTOR(6 downto 0);   -- [31:25]
        rd                    : out STD_LOGIC_VECTOR(2 downto 0);   -- [24:22]
        rs1                   : out STD_LOGIC_VECTOR(2 downto 0);   -- [21:19]
        rs2                   : out STD_LOGIC_VECTOR(2 downto 0);   -- [18:16]
        
        -- Control signals from Control Unit
        mem_write             : out STD_LOGIC;
        mem_read              : out STD_LOGIC;
        mem_to_reg            : out STD_LOGIC;
        alu_op                : out STD_LOGIC_VECTOR(3 downto 0);
        out_enable            : out STD_LOGIC;
        ccr_in                : out STD_LOGIC_VECTOR(1 downto 0);
        is_swap               : out STD_LOGIC;
        swap_phase            : out STD_LOGIC;
        reg_write             : out STD_LOGIC;
        is_immediate          : out STD_LOGIC;
        is_call               : out STD_LOGIC;
        hlt                   : out STD_LOGIC;
        is_int                : out STD_LOGIC;
        is_in                 : out STD_LOGIC;
        is_pop                : out STD_LOGIC;
        is_push               : out STD_LOGIC;
        int_phase             : out STD_LOGIC;
        is_rti                : out STD_LOGIC;
        rti_phase             : out STD_LOGIC;
        is_ret                : out STD_LOGIC;
        branchZ               : out STD_LOGIC;
        branchC               : out STD_LOGIC;
        branchN               : out STD_LOGIC;
        unconditional_branch  : out STD_LOGIC;
        
        -- PC+1 to pass to Execute Stage
        pc_out_plus_1         : out STD_LOGIC_VECTOR(31 downto 0)
    );
end decode_stage;

architecture Behavioral of decode_stage is
    
    -- Component declarations
    component register_file is
        Port (
            clk           : in  STD_LOGIC;
            rst           : in  STD_LOGIC;
            hlt           : in  STD_LOGIC;
            read_reg1     : in  STD_LOGIC_VECTOR(2 downto 0);
            read_reg2     : in  STD_LOGIC_VECTOR(2 downto 0);
            read_data1    : out STD_LOGIC_VECTOR(31 downto 0);
            read_data2    : out STD_LOGIC_VECTOR(31 downto 0);
            write_enable  : in  STD_LOGIC;
            write_reg     : in  STD_LOGIC_VECTOR(2 downto 0);
            write_data    : in  STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component control_unit is
        Port (
            opcode                : in  STD_LOGIC_VECTOR(6 downto 0);
            previous_is_immediate : in  STD_LOGIC;
            mem_write             : out STD_LOGIC;
            mem_read              : out STD_LOGIC;
            mem_to_reg            : out STD_LOGIC;
            alu_op                : out STD_LOGIC_VECTOR(3 downto 0);
            out_enable            : out STD_LOGIC;
            ccr_in                : out STD_LOGIC_VECTOR(1 downto 0);
            is_swap               : out STD_LOGIC;
            swap_phase            : out STD_LOGIC;
            reg_write             : out STD_LOGIC;
            is_immediate          : out STD_LOGIC;
            is_call               : out STD_LOGIC;
            hlt                   : out STD_LOGIC;
            is_int                : out STD_LOGIC;
            is_in                 : out STD_LOGIC;
            is_pop                : out STD_LOGIC;
            is_push               : out STD_LOGIC;
            int_phase             : out STD_LOGIC;
            is_rti                : out STD_LOGIC;
            rti_phase             : out STD_LOGIC;
            is_ret                : out STD_LOGIC;
            branchZ               : out STD_LOGIC;
            branchC               : out STD_LOGIC;
            branchN               : out STD_LOGIC;
            unconditional_branch  : out STD_LOGIC
        );
    end component;
    
    -- Internal signals for instruction field extraction
    signal instruction_opcode : STD_LOGIC_VECTOR(6 downto 0);
    signal instruction_rd     : STD_LOGIC_VECTOR(2 downto 0);
    signal instruction_rs1    : STD_LOGIC_VECTOR(2 downto 0);
    signal instruction_rs2    : STD_LOGIC_VECTOR(2 downto 0);
    
    -- Internal halt signal from control unit
    signal hlt_signal         : STD_LOGIC;
    
    -- PC+1 calculation
begin
    
    -- Extract instruction fields based on assembler.py encoding
    -- inst_word(op, rd, rs1, rs2) = (op<<25)|(rd<<22)|(rs1<<19)|(rs2<<16)
    instruction_opcode <= instruction(31 downto 25);  -- Opcode [31:25]
    instruction_rd     <= instruction(24 downto 22);  -- Rd [24:22]
    instruction_rs1    <= instruction(21 downto 19);  -- Rs1 [21:19]
    instruction_rs2    <= instruction(18 downto 16);  -- Rs2 [18:16]
    
    -- Output decoded fields
    opcode <= instruction_opcode;
    rd     <= instruction_rd;
    rs1    <= instruction_rs1;
    rs2    <= instruction_rs2;
    
    -- Register File instantiation
    reg_file : register_file
        port map (
            clk          => clk,
            rst          => rst,
            hlt          => hlt_signal,          -- Halt signal from control unit
            read_reg1    => instruction_rs1,     -- Read Rs1
            read_reg2    => instruction_rs2,     -- Read Rs2
            read_data1   => read_data1,          -- Rs1 data output
            read_data2   => read_data2,          -- Rs2 data output
            write_enable => wb_write_enable,     -- Write enable from WB stage
            write_reg    => wb_write_reg,        -- Write register from WB stage
            write_data   => wb_write_data        -- Write data from WB stage
        );
    
    -- Control Unit instantiation
    ctrl_unit : control_unit
        port map (
            opcode                => instruction_opcode,
            previous_is_immediate => previous_is_immediate,
            mem_write             => mem_write,
            mem_read              => mem_read,
            mem_to_reg            => mem_to_reg,
            alu_op                => alu_op,
            out_enable            => out_enable,
            ccr_in                => ccr_in,
            is_swap               => is_swap,
            swap_phase            => swap_phase,
            reg_write             => reg_write,
            is_immediate          => is_immediate,
            is_call               => is_call,
            hlt                   => hlt_signal,
            is_int                => is_int,
            is_in                 => is_in,
            is_pop                => is_pop,
            is_push               => is_push,
            int_phase             => int_phase,
            is_rti                => is_rti,
            rti_phase             => rti_phase,
            is_ret                => is_ret,
            branchZ               => branchZ,
            branchC               => branchC,
            branchN               => branchN,
            unconditional_branch  => unconditional_branch
        );
    
    -- Output halt signal
    hlt <= hlt_signal;
    
    -- Calculate PC+1 for next instruction
   pc_out_plus_1 <= pc_in_plus_1;
    
end Behavioral;
