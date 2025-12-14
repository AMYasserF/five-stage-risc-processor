LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- Testbench for Decode Stage
entity decode_stage_tb is
end decode_stage_tb;

architecture Behavioral of decode_stage_tb is
    
    -- Component Declaration
    component decode_stage is
        Port (
            clk                   : in  STD_LOGIC;
            rst                   : in  STD_LOGIC;
            instruction           : in  STD_LOGIC_VECTOR(31 downto 0);
            pc_in_plus_1          : in  STD_LOGIC_VECTOR(31 downto 0);
            wb_write_enable       : in  STD_LOGIC;
            wb_write_reg          : in  STD_LOGIC_VECTOR(2 downto 0);
            wb_write_data         : in  STD_LOGIC_VECTOR(31 downto 0);
            previous_is_immediate : in  STD_LOGIC;
            read_data1            : out STD_LOGIC_VECTOR(31 downto 0);
            read_data2            : out STD_LOGIC_VECTOR(31 downto 0);
            opcode                : out STD_LOGIC_VECTOR(6 downto 0);
            rd                    : out STD_LOGIC_VECTOR(2 downto 0);
            rs1                   : out STD_LOGIC_VECTOR(2 downto 0);
            rs2                   : out STD_LOGIC_VECTOR(2 downto 0);
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
            pc_out_plus_1         : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    -- Test Signals
    signal clk                   : STD_LOGIC := '0';
    signal rst                   : STD_LOGIC := '0';
    signal instruction           : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal pc_in                 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal wb_write_enable       : STD_LOGIC := '0';
    signal wb_write_reg          : STD_LOGIC_VECTOR(2 downto 0) := (others => '0');
    signal wb_write_data         : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal previous_is_immediate : STD_LOGIC := '0';
    signal read_data1            : STD_LOGIC_VECTOR(31 downto 0);
    signal read_data2            : STD_LOGIC_VECTOR(31 downto 0);
    signal opcode                : STD_LOGIC_VECTOR(6 downto 0);
    signal rd                    : STD_LOGIC_VECTOR(2 downto 0);
    signal rs1                   : STD_LOGIC_VECTOR(2 downto 0);
    signal rs2                   : STD_LOGIC_VECTOR(2 downto 0);
    signal mem_write             : STD_LOGIC;
    signal mem_read              : STD_LOGIC;
    signal mem_to_reg            : STD_LOGIC;
    signal alu_op                : STD_LOGIC_VECTOR(3 downto 0);
    signal out_enable            : STD_LOGIC;
    signal ccr_in                : STD_LOGIC_VECTOR(1 downto 0);
    signal is_swap               : STD_LOGIC;
    signal swap_phase            : STD_LOGIC;
    signal reg_write             : STD_LOGIC;
    signal is_immediate          : STD_LOGIC;
    signal is_call               : STD_LOGIC;
    signal hlt                   : STD_LOGIC;
    signal is_int                : STD_LOGIC;
    signal is_in                 : STD_LOGIC;
    signal is_pop                : STD_LOGIC;
    signal is_push               : STD_LOGIC;
    signal int_phase             : STD_LOGIC;
    signal is_rti                : STD_LOGIC;
    signal rti_phase             : STD_LOGIC;
    signal is_ret                : STD_LOGIC;
    signal branchZ               : STD_LOGIC;
    signal branchC               : STD_LOGIC;
    signal branchN               : STD_LOGIC;
    signal unconditional_branch  : STD_LOGIC;
    signal pc_out                : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Clock period definition
    constant clk_period : time := 10 ns;
    
    -- Helper function to build instruction based on assembler.py encoding
    function build_instruction(
        opcode : std_logic_vector(6 downto 0);
        rd     : std_logic_vector(2 downto 0);
        rs1    : std_logic_vector(2 downto 0);
        rs2    : std_logic_vector(2 downto 0)
    ) return std_logic_vector is
    begin
        -- inst_word(op, rd, rs1, rs2) = (op<<25)|(rd<<22)|(rs1<<19)|(rs2<<16)
        return opcode & rd & rs1 & rs2 & x"0000";
    end function;
    
begin
    
    -- Instantiate the Unit Under Test (UUT)
    uut: decode_stage
        port map (
            clk                   => clk,
            rst                   => rst,
            instruction           => instruction,
            pc_in_plus_1          => pc_in,
            wb_write_enable       => wb_write_enable,
            wb_write_reg          => wb_write_reg,
            wb_write_data         => wb_write_data,
            previous_is_immediate => previous_is_immediate,
            read_data1            => read_data1,
            read_data2            => read_data2,
            opcode                => opcode,
            rd                    => rd,
            rs1                   => rs1,
            rs2                   => rs2,
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
            hlt                   => hlt,
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
            unconditional_branch  => unconditional_branch,
            pc_out_plus_1         => pc_out
        );
    
    -- Clock process
    clk_process: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
    -- Stimulus process
    stim_proc: process
    begin
        -- Test 1: Reset
        report "Test 1: Reset";
        rst <= '1';
        wait for clk_period * 2;
        rst <= '0';
        wait for clk_period;
        
        -- Test 2: Write to registers (R1 = 100, R2 = 200)
        report "Test 2: Write to R1 and R2";
        wb_write_enable <= '1';
        wb_write_reg <= "001";  -- R1
        wb_write_data <= x"00000064";  -- 100
        wait for clk_period;
        
        wb_write_reg <= "010";  -- R2
        wb_write_data <= x"000000C8";  -- 200
        wait for clk_period;
        wb_write_enable <= '0';
        wait for clk_period;
        
        -- Test 3: R-Type ADD instruction (ADD R3, R1, R2)
        -- Opcode: 0001000 (Type=00, Func=1000)
        report "Test 3: ADD R3, R1, R2";
        pc_in <= x"00000010";
        instruction <= build_instruction("0001000", "011", "001", "010");
        wait for clk_period;
        assert opcode = "0001000" report "Opcode mismatch for ADD" severity error;
        assert rd = "011" report "Rd mismatch" severity error;
        assert rs1 = "001" report "Rs1 mismatch" severity error;
        assert rs2 = "010" report "Rs2 mismatch" severity error;
        assert read_data1 = x"00000064" report "Read_data1 incorrect (expected 100)" severity error;
        assert read_data2 = x"000000C8" report "Read_data2 incorrect (expected 200)" severity error;
        assert alu_op = "1000" report "ALU_OP should be 1000 for ADD" severity error;
        assert reg_write = '1' report "Reg_write should be 1 for ADD" severity error;
        assert pc_out = pc_in report "PC_out should pass through PC_in (already PC+1 from fetch)" severity error;
        
        -- Test 4: I-Type LDM instruction (LDM R4, 99)
        -- Opcode: 1010010 (hasImm=1, Type=01, Func=0010)
        report "Test 4: LDM R4, 99";
        pc_in <= x"00000020";
        instruction <= build_instruction("1010010", "100", "000", "000");
        wait for clk_period;
        assert opcode = "1010010" report "Opcode mismatch for LDM" severity error;
        assert is_immediate = '1' report "is_immediate should be 1 for LDM" severity error;
        assert alu_op = "0011" report "ALU_OP should be 0011 (PassB) for LDM" severity error;
        assert reg_write = '1' report "Reg_write should be 1 for LDM" severity error;
        
        -- Test 5: J-Type JZ instruction
        -- Opcode: 1100010 (hasImm=1, Type=10, Func=0010)
        report "Test 5: JZ target";
        pc_in <= x"00000030";
        instruction <= build_instruction("1100010", "000", "000", "000");
        wait for clk_period;
        assert branchZ = '1' report "branchZ should be 1 for JZ" severity error;
        assert ccr_in = "01" report "ccr_in should be 01 for conditional branch" severity error;
        assert is_immediate = '1' report "is_immediate should be 1 for JZ" severity error;
        
        -- Test 6: System instruction PUSH R7
        -- Opcode: 0110001 (hasImm=0, Type=11, Func=0001)
        report "Test 6: PUSH R7";
        pc_in <= x"00000040";
        -- First write to R7
        wb_write_enable <= '1';
        wb_write_reg <= "111";  -- R7
        wb_write_data <= x"0000ABCD";
        wait for clk_period;
        wb_write_enable <= '0';
        
        instruction <= build_instruction("0110001", "000", "111", "000");
        wait for clk_period;
        assert is_push = '1' report "is_push should be 1 for PUSH" severity error;
        assert mem_write = '1' report "mem_write should be 1 for PUSH" severity error;
        assert read_data1 = x"0000ABCD" report "Read_data1 should contain R7 value" severity error;
        
        -- Test 7: HLT instruction
        -- Opcode: 0110101 (hasImm=0, Type=11, Func=0101)
        report "Test 7: HLT";
        pc_in <= x"00000050";
        instruction <= build_instruction("0110101", "000", "000", "000");
        wait for clk_period;
        assert hlt = '1' report "hlt should be 1 for HLT" severity error;
        
        -- Test 8: Test halt functionality - register writes should be blocked
        report "Test 8: Verify halt blocks register writes";
        wb_write_enable <= '1';
        wb_write_reg <= "011";  -- R3
        wb_write_data <= x"DEADBEEF";
        wait for clk_period;
        wb_write_enable <= '0';
        
        -- Try to read R3 - should still have old value (0)
        instruction <= build_instruction("0001000", "100", "011", "000");
        wait for clk_period;
        assert read_data1 = x"00000000" report "R3 should still be 0 (write blocked by halt)" severity error;
        
        -- Test 9: Reset to clear halt
        report "Test 9: Reset to clear halt";
        rst <= '1';
        wait for clk_period * 2;
        rst <= '0';
        wait for clk_period;
        
        -- Test 10: MOV instruction (MOV R1, R5)
        -- Opcode: 0000110 (Type=00, Func=0110)
        report "Test 10: MOV R1, R5";
        -- First write to R1
        wb_write_enable <= '1';
        wb_write_reg <= "001";  -- R1
        wb_write_data <= x"12345678";
        wait for clk_period;
        wb_write_enable <= '0';
        
        instruction <= build_instruction("0000110", "101", "001", "000");
        wait for clk_period;
        assert alu_op = "0010" report "ALU_OP should be 0010 (PassA) for MOV" severity error;
        assert read_data1 = x"12345678" report "Read_data1 should contain R1 value" severity error;
        assert reg_write = '1' report "Reg_write should be 1 for MOV" severity error;
        
        -- Test 11: Previous instruction immediate flag
        report "Test 11: Test previous_is_immediate flag";
        previous_is_immediate <= '1';
        instruction <= x"0000002C";  -- Immediate value (44)
        wait for clk_period;
        assert reg_write = '0' report "All control signals should be 0 when previous_is_immediate=1" severity error;
        previous_is_immediate <= '0';
        
        -- End of tests
        wait for clk_period * 5;
        report "========================================";
        report "All tests completed successfully!";
        report "========================================";
        wait;
    end process;
    
end Behavioral;
