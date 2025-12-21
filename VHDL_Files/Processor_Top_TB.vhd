library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Testbench for complete 5-stage processor with unified internal memory
-- Tests: CALL, RET, External Interrupt, and HLT instructions
entity Processor_Top_TB is
end Processor_Top_TB;

architecture Behavioral of Processor_Top_TB is
    
    component Processor_Top is
        Port (
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            interrupt : in STD_LOGIC;
            input_port : in STD_LOGIC_VECTOR(31 downto 0);
            output_port : out STD_LOGIC_VECTOR(31 downto 0);
            wb_write_enable : out STD_LOGIC;
            wb_write_reg : out STD_LOGIC_VECTOR(2 downto 0);
            wb_write_data : out STD_LOGIC_VECTOR(31 downto 0);
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
    
    -- Testbench signals
    signal clk : STD_LOGIC := '0';
    signal rst : STD_LOGIC := '1';
    signal interrupt : STD_LOGIC := '0';
    
    signal input_port : STD_LOGIC_VECTOR(31 downto 0) := X"DEADBEEF";
    signal output_port : STD_LOGIC_VECTOR(31 downto 0);
    
    signal wb_write_enable : STD_LOGIC;
    signal wb_write_reg : STD_LOGIC_VECTOR(2 downto 0);
    signal wb_write_data : STD_LOGIC_VECTOR(31 downto 0);
    
    signal ex_mem_rti_phase : STD_LOGIC;
    signal ex_mem_int_phase : STD_LOGIC;
    signal ex_mem_mem_write : STD_LOGIC;
    signal ex_mem_mem_read : STD_LOGIC;
    signal ex_mem_mem_to_reg : STD_LOGIC;
    signal ex_mem_out_enable : STD_LOGIC;
    signal ex_mem_is_swap : STD_LOGIC;
    signal ex_mem_swap_phase : STD_LOGIC;
    signal ex_mem_reg_write : STD_LOGIC;
    signal ex_mem_is_call : STD_LOGIC;
    signal ex_mem_is_ret : STD_LOGIC;
    signal ex_mem_is_push : STD_LOGIC;
    signal ex_mem_is_pop : STD_LOGIC;
    signal ex_mem_is_in : STD_LOGIC;
    signal ex_mem_is_int : STD_LOGIC;
    signal ex_mem_is_rti : STD_LOGIC;
    signal ex_mem_hlt : STD_LOGIC;
    signal ex_mem_read_reg1 : STD_LOGIC_VECTOR(2 downto 0);
    signal ex_mem_write_reg : STD_LOGIC_VECTOR(2 downto 0);
    signal ex_mem_read_data2 : STD_LOGIC_VECTOR(31 downto 0);
    signal ex_mem_alu_result : STD_LOGIC_VECTOR(31 downto 0);
    signal conditional_jump : STD_LOGIC;
    signal pc_plus_2 : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Clock period
    constant clk_period : time := 10 ns;
    
    -- Instruction memory (SWAP test)
    type mem_array is array (0 to 127) of STD_LOGIC_VECTOR(31 downto 0);
    signal instruction_memory : mem_array := (
        -- Address 0: pointer to program start (address 2)
        0 => X"00000002",
        1 => X"00000000",

        -- Program starts at address 2
        -- Test SWAP operation
        
        -- LDM R1, #0x1111 (load first test value)
        2 => X"A4400000",  -- LDM R1
        3 => X"00001111",
        
        -- 3 NOPs for pipeline settling
        4 => X"00000000",
        5 => X"00000000",
        6 => X"00000000",

        -- LDM R2, #0x2222 (load second test value)
        7 => X"A4800000",  -- LDM R2
        8 => X"00002222",
        
        -- 3 NOPs
        9 => X"00000000",
        10 => X"00000000",
        11 => X"00000000",

        -- SWAP R1, R2 (swap values of R1 and R2)
        -- Opcode: 0111 (R-type SWAP)
        -- Format: [31:25]=0001110, [24:22]=R2(010), [21:19]=R1(001), [18:16]=unused
        12 => X"0E8A0000",  -- SWAP R1, R2
        
        -- 5 NOPs to observe result
        -- After SWAP: R1 should have 0x2222, R2 should have 0x1111
        13 => X"00000000",
        14 => X"00000000",
        15 => X"00000000",
        16 => X"00000000",
        17 => X"00000000",

        -- LDM R3, #0x3333 (load third test value)
        18 => X"A4C00000",  -- LDM R3
        19 => X"00003333",
        
        -- 3 NOPs
        20 => X"00000000",
        21 => X"00000000",
        22 => X"00000000",

        -- LDM R4, #0x4444 (load fourth test value)
        23 => X"A5000000",  -- LDM R4
        24 => X"00004444",
        
        -- 3 NOPs
        25 => X"00000000",
        26 => X"00000000",
        27 => X"00000000",

        -- SWAP R3, R4 (swap values of R3 and R4)
        -- Format: [31:25]=0001110, [24:22]=R4(100), [21:19]=R3(011), [18:16]=unused
        28 => X"0E9C0000",  -- SWAP R3, R4
        
        -- 5 NOPs to observe result
        -- After SWAP: R3 should have 0x4444, R4 should have 0x3333
        29 => X"00000000",
        30 => X"00000000",
        31 => X"00000000",
        32 => X"00000000",
        33 => X"00000000",

        -- SWAP R1, R3 (swap R1 and R3)
        -- Format: [31:25]=0001110, [24:22]=R3(011), [21:19]=R1(001), [18:16]=unused
        34 => X"0E6C0000",  -- SWAP R1, R3
        
        -- 5 NOPs to observe final result
        -- After SWAP: R1 should have 0x4444, R3 should have 0x2222
        35 => X"00000000",
        36 => X"00000000",
        37 => X"00000000",
        38 => X"00000000",
        39 => X"00000000",

        40 => x"10530000",
    41 => x"13080000",
    42 => x"00000000",
    43 => x"00000000",
    44 => x"00000000",
    45 => x"0C680000",
    46 => x"00000000",
    47 => x"15AA0000",
    48 => x"00000000",
    49 => x"00000000",
    50 => x"00000000",
    51 => x"0BC00000",
    52 => x"10390000",
    53 => x"00000000",
    54 => x"00000000",
    55 => x"00000000",
    56 => x"A4400000",
    57 => x"0000000E", -- Immediate value for LDD (Address 14)
    58 => x"104A0000",
    59 => x"00000000",
    60 => x"A2D00000",
    61 => x"00000028", -- Immediate value for LDD (Address 40)
    62 => x"06D80000",
    63 => x"00000000",
    64 => x"00000000",
    65 => x"00000000",
    66 => x"0E8A0000",
    67 => x"104A0000",
    68 => x"00000000",
    69 => x"00000000",
    70 => x"00000000",
    71 => x"64000000",
    72 => x"13020000",
    73 => x"00000000",
    74 => x"00000000",
    75 => x"00000000",
    76 => x"04000000",
    77 => x"10810000",

        others => X"00000000"
    );
    
begin
    
    -- Instantiate processor (memory is now internal)
    UUT: Processor_Top
        port map (
            clk => clk,
            rst => rst,
            interrupt => interrupt,
            input_port => input_port,
            output_port => output_port,
            wb_write_enable => wb_write_enable,
            wb_write_reg => wb_write_reg,
            wb_write_data => wb_write_data,
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
    
    -- Clock generation
    clk_process: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
    
    -- Stimulus
    stimulus: process
    begin
        -- ========== Test 1: Reset and Initialization ==========
        report "========================================" severity note;
        report "TEST 1: Reset and Initialization" severity note;
        report "========================================" severity note;
        
        rst <= '1';
        interrupt <= '0';
        wait for clk_period * 3;
        
        rst <= '0';
        report "Reset released - processor starts from M[0]" severity note;
        
        -- Run program for a while
        wait for clk_period * 30;
        
        -- ========== Test 2: External Interrupt ==========
        report " " severity note;
        report "========================================" severity note;
        report "TEST 2: External Interrupt Signal" severity note;
        report "========================================" severity note;
        report "Asserting external interrupt signal..." severity note;
        
        -- Assert interrupt
        interrupt <= '1';
        wait for clk_period * 2;
        
        -- Deassert interrupt
        interrupt <= '0';
        report "Interrupt deasserted - handler should execute" severity note;
        report "Expected: PC saved to stack, jump to M[1]" severity note;
        
        -- Let interrupt handler execute and return
        wait for clk_period * 25;
        
        -- ========== Test 3: Another interrupt ==========
        report " " severity note;
        report "========================================" severity note;
        report "TEST 3: Second External Interrupt" severity note;
        report "========================================" severity note;
        
        interrupt <= '1';
        wait for clk_period;
        interrupt <= '0';
        
        wait for clk_period * 20;
        
        -- ========== Test 4: Check for HLT ==========
        report " " severity note;
        report "========================================" severity note;
        report "TEST 4: Monitor for HLT Instruction" severity note;
        report "========================================" severity note;
        report "Running until HLT or end of test..." severity note;
        
        -- Run for more cycles to potentially hit HLT
        wait for clk_period * 40;
        
        if ex_mem_hlt = '1' then
            report "HLT detected - processor should be frozen" severity note;
            
            -- Verify processor stays halted
            wait for clk_period * 5;
            report "Verifying processor remains halted..." severity note;
            
            -- ========== Test 5: Reset after HLT ==========
            report " " severity note;
            report "========================================" severity note;
            report "TEST 5: Reset After HLT" severity note;
            report "========================================" severity note;
            
            rst <= '1';
            wait for clk_period * 2;
            rst <= '0';
            report "Reset applied - processor should restart" severity note;
            
            wait for clk_period * 20;
        else
            report "HLT not reached in this test run" severity note;
        end if;
        
        -- ========== Test Complete ==========
        report " " severity note;
        report "========================================" severity note;
        report "ALL TESTS COMPLETED" severity note;
        report "========================================" severity note;
        report "Check waveforms for:" severity note;
        report "1. External interrupt saves PC to stack" severity note;
        report "2. Interrupt handler execution" severity note;
        report "3. Return from interrupt (RET)" severity note;
        report "4. HLT instruction freezes processor" severity note;
        report "5. Reset clears HLT state" severity note;
        
        wait;
    end process;
    
    -- Monitor process
    monitor: process(clk)
    begin
        if rising_edge(clk) then
            -- Monitor output port
            if ex_mem_out_enable = '1' then
                report "OUTPUT: " & integer'image(to_integer(unsigned(ex_mem_alu_result))) severity note;
            end if;
            
            -- Monitor HLT
            if ex_mem_hlt = '1' then
                report ">>> HLT instruction detected in EX/MEM stage <<<" severity warning;
            end if;
            
            -- Monitor interrupt-related signals
            if ex_mem_is_int = '1' then
                report "INT instruction in EX/MEM stage" severity note;
            end if;
            
            if ex_mem_is_rti = '1' then
                report "RTI instruction in EX/MEM stage" severity note;
            end if;
            
            if ex_mem_is_ret = '1' then
                report "RET instruction in EX/MEM stage" severity note;
            end if;
            
            -- Monitor register writes
            if wb_write_enable = '1' then
                report "Register R" & integer'image(to_integer(unsigned(wb_write_reg))) & 
                       " <= " & integer'image(to_integer(unsigned(wb_write_data))) severity note;
            end if;
        end if;
    end process;
    
end Behavioral;
