LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity ALU is
    Port (
        A           : in  STD_LOGIC_VECTOR(31 downto 0); -- Operand A
        B           : in  STD_LOGIC_VECTOR(31 downto 0); -- Operand B
        ALU_Op      : in  STD_LOGIC_VECTOR(3 downto 0);  -- Operation Selector
        Result      : out STD_LOGIC_VECTOR(31 downto 0); -- ALU Output
        Zero_Flag   : out STD_LOGIC;                     -- Z Flag
        Carry_Flag  : out STD_LOGIC;                     -- C Flag
        Neg_Flag    : out STD_LOGIC                      -- N Flag
    );
end ALU;

architecture Behavioral of ALU is
    -- 33-bit signal to capture carry/borrow
    signal result_temp : unsigned(32 downto 0);
    signal a_uns       : unsigned(32 downto 0);
    signal b_uns       : unsigned(32 downto 0);
begin
    -- Extend inputs to 33 bits for carry calculation
    a_uns <= resize(unsigned(A), 33);
    b_uns <= resize(unsigned(B), 33);

    process(A, B, ALU_Op, a_uns, b_uns, result_temp)
    begin
        -- Default: Result is 0
        result_temp <= (others => '0');

        case ALU_Op is
            when "0000" => -- NOP
                result_temp <= (others => '0');

            when "0001" => -- SETC
                result_temp <= (others => '0'); 
                -- Note: Carry forced to '1' in flag process below

            when "0010" => -- PassA (MOV, OUT)
                result_temp <= a_uns;

            when "0011" => -- PassB (LDM, IN)
                result_temp <= b_uns;

            when "0100" => -- NOT (NotA)
                -- Perform bitwise NOT on 32 bits, then resize to clear bit 32
                result_temp <= resize(unsigned(not A), 33);

            when "0101" => -- INC (IncA)
                result_temp <= a_uns + 1;

            when "0110" => -- AND
                result_temp <= a_uns and b_uns;

            when "0111" => -- SWAP (PassA implementation)
                result_temp <= a_uns;

            when "1000" => -- ADD (ADD, IADD, LDD, STD)
                result_temp <= a_uns + b_uns;

            when "1001" => -- SUB
                result_temp <= a_uns - b_uns;

            when others =>
                result_temp <= (others => '0');
        end case;
    end process;

    -- Drive Result Output (lower 32 bits)
    Result <= std_logic_vector(result_temp(31 downto 0));

    -- Flag Generation Process
    process(result_temp, ALU_Op)
    begin
        -- Zero Flag
        if (result_temp(31 downto 0) = x"00000000") then
            Zero_Flag <= '1';
        else
            Zero_Flag <= '0';
        end if;

        -- Negative Flag
        Neg_Flag <= result_temp(31);

        -- Carry Flag
        if ALU_Op = "0001" then 
            -- SETC instruction explicitly sets Carry
            Carry_Flag <= '1';
        else
            -- For ADD: Bit 32 is Carry Out
            -- For SUB: Bit 32 is Borrow (1 if A < B)
            -- For Logical Ops: Bit 32 is 0 (Cleared)
            Carry_Flag <= result_temp(32);
        end if;
    end process;

end Behavioral;