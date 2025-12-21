library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity ALU_OperandA_Mux is
    Port (
        read_data1      : in  STD_LOGIC_VECTOR(31 downto 0);
        ex_mem_alu      : in  STD_LOGIC_VECTOR(31 downto 0);
        ex_mem_r2       : in  STD_LOGIC_VECTOR(31 downto 0); -- For SWAP Rsrc1
        ex_mem_in       : in  STD_LOGIC_VECTOR(31 downto 0);
        mem_wb_alu      : in  STD_LOGIC_VECTOR(31 downto 0);
        mem_wb_mem      : in  STD_LOGIC_VECTOR(31 downto 0);
        mem_wb_in       : in  STD_LOGIC_VECTOR(31 downto 0);
        mem_wb_r2       : in  STD_LOGIC_VECTOR(31 downto 0); -- For SWAP Rsrc1
        select_sig      : in  STD_LOGIC_VECTOR(3 downto 0);
        operand_a       : out STD_LOGIC_VECTOR(31 downto 0)
    );
end ALU_OperandA_Mux;

architecture Behavioral of ALU_OperandA_Mux is
begin
    process(all) begin
        case select_sig is
            when "0000" => operand_a <= read_data1;
            when "0001" | "0011" => operand_a <= ex_mem_alu;
            when "0010" => operand_a <= ex_mem_r2;
            when "0100" => operand_a <= ex_mem_in;
            when "0101" => operand_a <= mem_wb_mem;
            when "0110" => operand_a <= mem_wb_r2;
            when "0111" | "1001" => operand_a <= mem_wb_alu;
            when "1000" => operand_a <= mem_wb_in;
            when others => operand_a <= read_data1;
        end case;
    end process;
end Behavioral;