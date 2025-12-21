-- Example: How to Update Processor_Top_TB.vhd for Generic Program Loading
-- 
-- BEFORE: Programs were hardcoded in instruction_memory array
-- AFTER: Programs are loaded from text files using Unified_Memory generic

-- Key Changes:

-- 1. REMOVE hardcoded instruction memory signal:
--    (Old) signal instruction_memory : mem_array := (0 => X"00000002", ...);
--
--    (New) -- No longer needed; Unified_Memory handles file loading


-- 2. REMOVE instruction memory instantiation from architecture:
--    (Old) -- Read instructions from instruction_memory array in testbench
--
--    (New) -- Memory is instantiated with PROGRAM_FILE generic


-- 3. UPDATE Unified_Memory instantiation to include generic:

--    BEFORE:
--    Unified_Mem: Unified_Memory
--        port map (
--            clk => clk,
--            rst => rst,
--            ...
--        );
--
--    AFTER:
--    Unified_Mem: Unified_Memory
--        generic map (
--            PROGRAM_FILE => "program.txt"  -- <-- Add this generic
--        )
--        port map (
--            clk => clk,
--            rst => rst,
--            ...
--        );


-- Example Updated Testbench Fragment:

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Processor_Top_TB_Updated is
end Processor_Top_TB_Updated;

architecture Behavioral of Processor_Top_TB_Updated is
    
    component Processor_Top is
        Port (
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            interrupt : in STD_LOGIC;
            input_port : in STD_LOGIC_VECTOR(31 downto 0);
            output_port : out STD_LOGIC_VECTOR(31 downto 0);
            -- ... other ports ...
        );
    end component;
    
    -- Testbench signals (same as before)
    signal clk : STD_LOGIC := '0';
    signal rst : STD_LOGIC := '1';
    signal interrupt : STD_LOGIC := '0';
    signal input_port : STD_LOGIC_VECTOR(31 downto 0) := X"DEADBEEF";
    signal output_port : STD_LOGIC_VECTOR(31 downto 0);
    
    constant clk_period : time := 10 ns;
    
    -- NO MORE instruction_memory array!
    -- Memory is now loaded from program.txt by Unified_Memory
    
begin
    
    -- Instantiate Processor_Top (unchanged)
    DUT: Processor_Top
        port map (
            clk => clk,
            rst => rst,
            interrupt => interrupt,
            input_port => input_port,
            output_port => output_port,
            -- ... connect other ports ...
        );
    
    -- Clock generation (unchanged)
    clk <= not clk after clk_period / 2;
    
    -- Reset and stimulus (unchanged)
    process
    begin
        -- Reset phase
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        
        -- Run simulation
        wait for 1000 ns;
        
        -- Can generate input stimulus here
        -- input_port <= X"11111111";
        -- wait for 50 ns;
        
        std.env.finish;
    end process;
    
    -- Optional: Monitor output
    process
    begin
        wait until rising_edge(clk);
        -- Can capture output_port here for analysis
        -- report "Output: " & to_hstring(output_port);
    end process;

end Behavioral;


-- Procedure to Add Generic to Existing Processor_Top.vhd:

-- 1. In architecture declarative part, find the Unified_Memory component instantiation:
--
--    Unified_Mem: Unified_Memory
--        port map (
--
-- 2. Add generic map before port map:
--
--    Unified_Mem: Unified_Memory
--        generic map (
--            PROGRAM_FILE => "program.txt"  -- <-- INSERT THIS LINE
--        )
--        port map (
--
-- 3. If you need to make the path configurable, add to Processor_Top generic:
--
--    entity Processor_Top is
--        generic (
--            PROGRAM_FILE : string := "program.txt"
--        );
--        port (
--            ...
--        );
--    end entity;
--
-- 4. Then use that generic in the instantiation:
--
--    Unified_Mem: Unified_Memory
--        generic map (
--            PROGRAM_FILE => PROGRAM_FILE  -- Use top-level generic
--        )
--        port map (
--            ...
--        );


-- Usage Examples:

-- Example 1: Default program file
-- No changes needed; uses "program.txt" from project root

-- Example 2: Different program for testing
-- Modify testbench:
--    DUT: Processor_Top
--        generic map (
--            PROGRAM_FILE => "test_arithmetic.txt"
--        )
--        port map (
--            ...
--        );

-- Example 3: Relative paths for nested directories
--    PROGRAM_FILE => "../programs/my_test.txt"

-- Example 4: Multiple testbenches, each with different program
--    Copy this template and change PROGRAM_FILE for each variant


-- Important Notes:

-- 1. File paths are relative to simulator working directory
--    Usually the VHDL_Files/ directory when running from TCL scripts
--    Adjust paths accordingly (use ../ to go up directories)

-- 2. The file must exist and contain valid hex instructions
--    One 32-bit hex per line (e.g., "DEADBEEF" or "0xDEADBEEF")

-- 3. No VHDL recompilation needed to change programs
--    Only change the generic and re-run simulation

-- 4. If PROGRAM_FILE is empty string "", memory initializes to all zeros
--    Useful for testing memory write operations without a program

-- 5. Backward compatibility: Old testbenches still work without generic
--    They will use default program.txt file
