LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity CCR_Mux is
    Port (
        -- Selector from Control Unit
        -- 00: ALU Update
        -- 01: Hold (Branch)
        -- 10: Restore (RTI/Stack)
        selector            : in  STD_LOGIC_VECTOR(1 downto 0);
        
        -- Source 00: Individual ALU Flags
        alu_Z               : in  STD_LOGIC;
        alu_C               : in  STD_LOGIC;
        alu_N               : in  STD_LOGIC;
        
        -- Source 01: Current Register Value (Feedback)
        current_ccr_val     : in  STD_LOGIC_VECTOR(31 downto 0);
        
        -- Source 10: Stack/Memory Data (Full 32-bit)
        stack_data_in       : in  STD_LOGIC_VECTOR(31 downto 0);
        
        -- Conditional Branch Signals (Active High)
        -- Used to clear the corresponding flag if the branch is being executed
        conditional_branchZ : in STD_LOGIC;
        conditional_branchC : in STD_LOGIC;
        conditional_branchN : in STD_LOGIC;
        
        -- Output to CCR Register
        mux_out             : out STD_LOGIC_VECTOR(31 downto 0)
    );
end CCR_Mux;

architecture DataFlow of CCR_Mux is
    signal alu_constructed_word : STD_LOGIC_VECTOR(31 downto 0);
    signal held_val_with_clear  : STD_LOGIC_VECTOR(31 downto 0);
begin
    
    -- Construct 32-bit word from individual ALU flags
    -- Bit 0 = Z, Bit 1 = C, Bit 2 = N, Others = '0'
    alu_constructed_word(0)            <= alu_Z;
    alu_constructed_word(1)            <= alu_C;
    alu_constructed_word(2)            <= alu_N;
    alu_constructed_word(31 downto 3)  <= (others => '0');

    -- Logic for "01" Case: Hold current value but Clear flags if Branch signal is active
    process(current_ccr_val, conditional_branchZ, conditional_branchC, conditional_branchN)
    begin
        -- Default: Copy current value
        held_val_with_clear <= current_ccr_val;
        
        -- If Conditional Branch on Zero is active, Clear Z flag (Bit 0)
        if conditional_branchZ = '1' then
            held_val_with_clear(0) <= '0';
        end if;
        
        -- If Conditional Branch on Carry is active, Clear C flag (Bit 1)
        if conditional_branchC = '1' then
            held_val_with_clear(1) <= '0';
        end if;
        
        -- If Conditional Branch on Negative is active, Clear N flag (Bit 2)
        if conditional_branchN = '1' then
            held_val_with_clear(2) <= '0';
        end if;
    end process;

    -- Main Multiplexer Process
    process(selector, alu_constructed_word, held_val_with_clear, stack_data_in)
    begin
        case selector is
            when "00" => -- ALU Update
                mux_out <= alu_constructed_word;
                
            when "01" => -- Hold / Branch Logic (Returns held value with cleared flags)
                mux_out <= held_val_with_clear;
                
            when "10" => -- Restore from Stack (RTI)
                mux_out <= stack_data_in;
                
            when others => -- Default to Hold
                mux_out <= held_val_with_clear;
        end case;
    end process;

end DataFlow;