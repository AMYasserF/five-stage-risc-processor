library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ALU_OperandB_Mux is
    Port (
        read_data2      : in  STD_LOGIC_VECTOR(31 downto 0);
        ex_mem_alu      : in  STD_LOGIC_VECTOR(31 downto 0);
        ex_mem_r2       : in  STD_LOGIC_VECTOR(31 downto 0);
        ex_mem_in       : in  STD_LOGIC_VECTOR(31 downto 0);
        mem_wb_alu      : in  STD_LOGIC_VECTOR(31 downto 0);
        mem_wb_mem      : in  STD_LOGIC_VECTOR(31 downto 0);
        mem_wb_in       : in  STD_LOGIC_VECTOR(31 downto 0);
        mem_wb_r2       : in  STD_LOGIC_VECTOR(31 downto 0);
        immediate       : in  STD_LOGIC_VECTOR(31 downto 0);
        select_sig      : in  STD_LOGIC_VECTOR(3 downto 0);
        operand_b       : out STD_LOGIC_VECTOR(31 downto 0)
    );
end ALU_OperandB_Mux;

architecture Behavioral of ALU_OperandB_Mux is
begin
    process(all) begin
        case select_sig is
            when "1111" => operand_b <= immediate;
            when "0000" => operand_b <= read_data2;
            when "0001" | "0011" => operand_b <= ex_mem_alu;
            when "0010" => operand_b <= ex_mem_r2;
            when "0100" => operand_b <= ex_mem_in;
            when "0101" => operand_b <= mem_wb_mem;
            when "0110" => operand_b <= mem_wb_r2;
            when "0111" | "1001" => operand_b <= mem_wb_alu;
            when "1000" => operand_b <= mem_wb_in;
            when others => operand_b <= read_data2;
        end case;
    end process;
end Behavioral;