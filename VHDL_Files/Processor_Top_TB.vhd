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
