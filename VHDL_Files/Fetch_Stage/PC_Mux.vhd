library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PC_Mux is
    Port (
        pc_plus_1 : in STD_LOGIC_VECTOR(31 downto 0);           -- 00: Normal increment
        immediate_ifid : in STD_LOGIC_VECTOR(31 downto 0);      -- 01: Conditional jump (from IF/ID)
        mem_data : in STD_LOGIC_VECTOR(31 downto 0);            -- 10: Memory (RET/Reset/INT/Uncond Jump)
        alu_result : in STD_LOGIC_VECTOR(31 downto 0);          -- 11: ALU result (CALL from EX/MEM)
        sel : in STD_LOGIC_VECTOR(1 downto 0);
        pc_out : out STD_LOGIC_VECTOR(31 downto 0)
    );
end PC_Mux;

architecture Behavioral of PC_Mux is
begin
    process(pc_plus_1, immediate_ifid, mem_data, alu_result, sel)
    begin
        case sel is
            when "00" => pc_out <= pc_plus_1;           -- Normal: PC + 1
            when "01" => pc_out <= immediate_ifid;      -- Conditional jump from IF/ID
            when "10" => pc_out <= mem_data;            -- From memory (RET/Reset/INT/Uncond)
            when "11" => pc_out <= alu_result;          -- CALL from ALU (EX/MEM)
            when others => pc_out <= pc_plus_1;         -- Default
        end case;
    end process;
end Behavioral;
