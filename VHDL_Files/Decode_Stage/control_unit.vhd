-- vhdl-linter-disable type-resolved
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;


entity control_unit is
    Port ( opcode                : in STD_LOGIC_VECTOR(6 downto 0); -- 7-bit opcode input
           previous_is_immediate : in STD_LOGIC;                 -- Input from EX stage (previous_is_immediate)
           mem_write             : out STD_LOGIC;                 -- Output: MemWrite signal
           mem_read              : out STD_LOGIC;                 -- Output: MemRead signal
           mem_to_reg            : out STD_LOGIC;                 -- Output: MemToReg signal
           alu_op                : out STD_LOGIC_VECTOR(3 downto 0); -- Output: ALU operation code
           out_enable            : out STD_LOGIC;                 -- Output: OutEnable signal
           ccr_in                : out STD_LOGIC_VECTOR(1 downto 0);--Output: ccr_in to determine the input to CCR
           is_swap               : out STD_LOGIC;                 -- Output: IsSwap signal
           swap_phase            : out STD_LOGIC;                 -- Output: SwapPhase signal
           reg_write             : out STD_LOGIC;                 -- Output: RegWrite control signal
           is_immediate          : out STD_LOGIC;                 -- Output: IsImmediate flag
           is_call               : out STD_LOGIC;                 -- Output: IsCall signal
           hlt                   : out STD_LOGIC;                 -- Output: Halt signal
           is_int                : out STD_LOGIC;                 -- Output: IsInt signal
           is_in                 : out STD_lOGIC;                 -- Output: in in signal
           is_pop                : out STD_LOGIC;                 -- Output: IsPop signal
           is_push               : out STD_LOGIC;                 -- Output: IsPush signal
           int_phase             : out STD_LOGIC;                 -- Output: IntPhase signal
           is_rti                : out STD_LOGIC;                 -- Output: IsRTI signal
           rti_phase             : out STD_LOGIC;                 -- Output: RTIPhase signal
           is_ret                : out STD_LOGIC;                 -- Output: IsRet signal
           branchZ               : out STD_LOGIC;                 -- Output: Branch if Zero flag (Z)
           branchC               : out STD_LOGIC;                 -- Output: Branch if Carry flag (C)
           branchN               : out STD_LOGIC;                 -- Output: Branch if Negative flag (N)
           unconditional_branch  : out STD_LOGIC                  -- Output: Unconditional Branch (JMP)
           );
end control_unit;

architecture Behavioral of control_unit is
begin
    process(opcode, previous_is_immediate)
    begin
        -- Default Values (Set all signals to zero initially)
        mem_write             <= '0';
        mem_read              <= '0';
        mem_to_reg            <= '0';
        alu_op                <= "0000";  -- Default ALU operation (NOP)
        out_enable            <= '0';
        ccr_in                <= "00";    -- Default: CCR from ALU output
        is_swap               <= '0';
        swap_phase            <= '0';
        reg_write             <= '0';
        is_immediate          <= '0';
        is_call               <= '0';
        hlt                   <= '0';
        is_int                <= '0';
        is_pop                <= '0';
        is_push               <= '0';
        int_phase             <= '0';
        is_rti                <= '0';
        rti_phase             <= '0';
        is_ret                <= '0';
        branchZ               <= '0';
        branchC               <= '0';
        branchN               <= '0';
        unconditional_branch  <= '0';
        is_in                 <= '0';
        -- If previous_is_immediate is '1', set all control signals to '0' and ignore opcode
        if previous_is_immediate = '1' then
            -- All control signals are set to '0' by default (already done)
            -- We can ignore the opcode here because previous_is_immediate is active
        else
            -- Extracting the type and opcode part of the instruction
            -- opcode(6) = hasImm flag (1 = has immediate/address in next word)
            -- opcode(5 downto 4) = Type (00=R, 01=I, 10=J, 11=System)
            -- opcode(3 downto 0) = Function code
            
            -- Set is_immediate based on opcode(6)
            is_immediate <= opcode(6);
            
            case opcode(5 downto 4) is
                when "00" =>  -- R-Type Instruction (hasImm=0)
                    case opcode(3 downto 0) is
                        when "0000" =>  -- NOP
                            alu_op <= "0000";  -- NOP
                            reg_write <= '0';
                        when "0001" =>  -- SETC
                            alu_op <= "0001";  -- SETC
                            reg_write <= '0';
                        when "0010" =>  -- NOT
                            alu_op <= "0100";  -- NotA
                            reg_write <= '1';
                        when "0011" =>  -- INC
                            alu_op <= "0101";  -- IncA
                            reg_write <= '1';
                        when "0100" =>  -- OUT
                            alu_op <= "0010";  -- PassA
                            out_enable <= '1';
                            reg_write <= '0';
                        when "0101" =>  -- IN
                            is_in <= '1';
                            alu_op <= "0011";  -- PassB (from input port)
                            reg_write <= '1';
                        when "0110" =>  -- MOV
                            alu_op <= "0010";  -- PassA
                            reg_write <= '1';
                        when "0111" =>  -- SWAP
                            alu_op <= "0111";  -- SWAP
                            is_swap <= '1';
                            reg_write <= '1';
                        when "1000" =>  -- ADD
                            alu_op <= "1000";  -- ADD
                            reg_write <= '1';
                        when "1001" =>  -- SUB
                            alu_op <= "1001";  -- SUB
                            reg_write <= '1';
                        when "1010" =>  -- AND
                            alu_op <= "0110";  -- AND
                            reg_write <= '1';
                        when others =>
                            alu_op <= "0000";  -- Default NOP
                    end case;

                when "01" =>  -- I-Type Instruction (hasImm=1)
                    case opcode(3 downto 0) is
                        when "0001" =>  -- IADD
                            alu_op <= "1000";  -- ADD
                            reg_write <= '1';
                            mem_to_reg <= '0';
                        when "0010" =>  -- LDM
                            alu_op <= "0011";  -- PassB (immediate)
                            reg_write <= '1';
                            mem_to_reg <= '0';
                        when "0011" =>  -- LDD
                            alu_op <= "1000";  -- ADD (Rs1 + offset)
                            reg_write <= '1';
                            mem_read <= '1';
                            mem_to_reg <= '1';
                        when "0100" =>  -- STD
                            alu_op <= "1000";  -- ADD (Rs2 + offset)
                            mem_write <= '1';
                            reg_write <= '0';
                        when others =>
                            alu_op <= "0000";  -- Default NOP
                    end case;

                when "10" =>  -- J-Type Instruction
                    case opcode(3 downto 0) is
                        when "0001" =>  -- JMP (hasImm=1)
                            unconditional_branch <= '1';
                            alu_op <= "0000";
                        when "0010" =>  -- JZ (hasImm=1)
                            branchZ <= '1';
                            ccr_in <= "01";  -- CCR from conditional branch logic
                            alu_op <= "0000";
                        when "0011" =>  -- JN (hasImm=1)
                            branchN <= '1';
                            ccr_in <= "01";  -- CCR from conditional branch logic
                            alu_op <= "0000";
                        when "0100" =>  -- JC (hasImm=1)
                            branchC <= '1';
                            ccr_in <= "01";  -- CCR from conditional branch logic
                            alu_op <= "0000";
                        when "0101" =>  -- CALL (hasImm=1)
                            is_call <= '1';
                            alu_op <= "0000";
                        when "0110" =>  -- RET (hasImm=0)
                            is_ret <= '1';
                            alu_op <= "0000";
                        when others =>
                            alu_op <= "0000";  -- Default NOP
                    end case;

                when "11" =>  -- System/Stack Instructions
                    case opcode(3 downto 0) is
                        when "0001" =>  -- PUSH (hasImm=0)
                            is_push <= '1';
                            mem_write <= '1';
                            alu_op <= "0000";
                        when "0010" =>  -- POP (hasImm=0)
                            is_pop <= '1';
                            mem_read <= '1';
                            mem_to_reg <= '1';
                            reg_write <= '1';
                            alu_op <= "0000";
                        when "0011" =>  -- INT (hasImm=1)
                            is_int <= '1';
                            int_phase <= '0';
                            alu_op <= "0000";
                        when "0100" =>  -- RTI (hasImm=0)
                            is_rti <= '1';
                            rti_phase <= '0';
                            ccr_in <= "10";  -- CCR from stack/memory
                            alu_op <= "0000";
                        when "0101" =>  -- HLT (hasImm=0)
                            hlt <= '1';
                            alu_op <= "0000";
                        when others =>
                            alu_op <= "0000";  -- Default NOP
                    end case;

                when others =>
                    null;  -- Default case for unknown opcodes
            end case;
        end if;  -- End of previous_is_immediate check
    end process;
end Behavioral;
