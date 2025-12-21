library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Forwarding_Unit is
    Port (
        ID_EX_RegRs     : in  STD_LOGIC_VECTOR(2 downto 0);
        ID_EX_RegRt     : in  STD_LOGIC_VECTOR(2 downto 0);
        EX_MEM_RegWrite : in  STD_LOGIC;
        EX_MEM_DestReg  : in  STD_LOGIC_VECTOR(2 downto 0);
        EX_MEM_Rsrc1    : in  STD_LOGIC_VECTOR(2 downto 0);
        EX_MEM_is_swap  : in  STD_LOGIC;
        EX_MEM_is_in    : in  STD_LOGIC;
        MEM_WB_RegWrite : in  STD_LOGIC;
        MEM_WB_DestReg  : in  STD_LOGIC_VECTOR(2 downto 0);
        MEM_WB_Rsrc1    : in  STD_LOGIC_VECTOR(2 downto 0);
        MEM_WB_is_swap  : in  STD_LOGIC;
        MEM_WB_is_in    : in  STD_LOGIC;
        MEM_WB_mem_to_reg: in STD_LOGIC;
        ForwardA        : out STD_LOGIC_VECTOR(3 downto 0);
        ForwardB        : out STD_LOGIC_VECTOR(3 downto 0)
    );
end Forwarding_Unit;

architecture Behavioral of Forwarding_Unit is
begin
    process(all)
    begin
        -- Default: No forwarding
        ForwardA <= "0000";
        ForwardB <= "0000";

        -- Forwarding for Operand A
        if EX_MEM_RegWrite = '1' and (EX_MEM_DestReg = ID_EX_RegRs or (EX_MEM_is_swap = '1' and EX_MEM_Rsrc1 = ID_EX_RegRs)) then
            if EX_MEM_DestReg = ID_EX_RegRs then
                if EX_MEM_is_in = '1' then ForwardA <= "0100"; else ForwardA <= "0001"; end if;
            else ForwardA <= "0010"; end if;
        elsif MEM_WB_RegWrite = '1' and (MEM_WB_DestReg = ID_EX_RegRs or (MEM_WB_is_swap = '1' and MEM_WB_Rsrc1 = ID_EX_RegRs)) then
            if MEM_WB_DestReg = ID_EX_RegRs then
                if MEM_WB_is_in = '1' then ForwardA <= "1000";
                elsif MEM_WB_mem_to_reg = '1' then ForwardA <= "0101";
                else ForwardA <= "1001"; end if;
            else ForwardA <= "0110"; end if;
        end if;

        -- Forwarding for Operand B
        if EX_MEM_RegWrite = '1' and (EX_MEM_DestReg = ID_EX_RegRt or (EX_MEM_is_swap = '1' and EX_MEM_Rsrc1 = ID_EX_RegRt)) then
            if EX_MEM_DestReg = ID_EX_RegRt then
                if EX_MEM_is_in = '1' then ForwardB <= "0100"; else ForwardB <= "0001"; end if;
            else ForwardB <= "0010"; end if;
        elsif MEM_WB_RegWrite = '1' and (MEM_WB_DestReg = ID_EX_RegRt or (MEM_WB_is_swap = '1' and MEM_WB_Rsrc1 = ID_EX_RegRt)) then
            if MEM_WB_DestReg = ID_EX_RegRt then
                if MEM_WB_is_in = '1' then ForwardB <= "1000";
                elsif MEM_WB_mem_to_reg = '1' then ForwardB <= "0101";
                else ForwardB <= "1001"; end if;
            else ForwardB <= "0110"; end if;
        end if;
    end process;
end Behavioral;