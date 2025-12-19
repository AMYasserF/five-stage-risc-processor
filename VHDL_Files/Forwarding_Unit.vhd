library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Forwarding Unit for Data Hazard Detection and Resolution
-- Generates forwarding control signals for ALU operand muxes
entity Forwarding_Unit is
    Port (
        -- ID/EX source registers (currently in Execute stage)
        ID_EX_RegRs     : in  STD_LOGIC_VECTOR(2 downto 0);  -- Source register 1
        ID_EX_RegRt     : in  STD_LOGIC_VECTOR(2 downto 0);  -- Source register 2 / Destination for SWAP

        -- EX/MEM stage info (previous instruction in Memory stage)
        EX_MEM_RegWrite : in  STD_LOGIC;
        EX_MEM_DestReg  : in  STD_LOGIC_VECTOR(2 downto 0);
        EX_MEM_Rsrc1    : in  STD_LOGIC_VECTOR(2 downto 0);
        EX_MEM_is_swap  : in  STD_LOGIC;
        EX_MEM_is_in    : in  STD_LOGIC;

        -- MEM/WB stage info (instruction in Writeback stage)
        MEM_WB_RegWrite : in  STD_LOGIC;
        MEM_WB_DestReg  : in  STD_LOGIC_VECTOR(2 downto 0);
        MEM_WB_Rsrc1    : in  STD_LOGIC_VECTOR(2 downto 0);
        MEM_WB_is_swap  : in  STD_LOGIC;
        MEM_WB_is_in    : in  STD_LOGIC;
        MEM_WB_mem_to_reg: in STD_LOGIC;

        -- Forwarding control outputs
        -- 0000: No forwarding (use ID/EX data)
        -- 0001: Forward from EX/MEM ALU result
        -- 0010: Forward from EX/MEM Rsrc2 (for SWAP)
        -- 0011: Forward from EX/MEM ALU result (SWAP destination)
        -- 0100: Forward from EX/MEM input port
        -- 0101: Forward from MEM/WB memory data
        -- 0110: Forward from MEM/WB Rsrc2 (for SWAP)
        -- 0111: Forward from MEM/WB ALU result (SWAP destination)
        -- 1000: Forward from MEM/WB input port
        -- 1001: Forward from MEM/WB ALU result
        ForwardA        : out STD_LOGIC_VECTOR(3 downto 0);
        ForwardB        : out STD_LOGIC_VECTOR(3 downto 0)
    );
end Forwarding_Unit;

architecture Behavioral of Forwarding_Unit is
begin

    --------------------------------------------------------------------
    -- Forward A (for Rsrc1 / ALU Operand A)
    --------------------------------------------------------------------
    process (ID_EX_RegRs, EX_MEM_RegWrite, EX_MEM_DestReg, EX_MEM_Rsrc1,
             EX_MEM_is_swap, EX_MEM_is_in, MEM_WB_RegWrite, MEM_WB_DestReg,
             MEM_WB_Rsrc1, MEM_WB_is_swap, MEM_WB_is_in, MEM_WB_mem_to_reg)
    begin
        -- Default: No forwarding
        ForwardA <= "0000";

        -- Priority 1: Check EX/MEM stage for most recent data
        if EX_MEM_RegWrite = '1' and
           (EX_MEM_DestReg = ID_EX_RegRs or
            (EX_MEM_is_swap = '1' and EX_MEM_Rsrc1 = ID_EX_RegRs)) then

            if EX_MEM_DestReg = ID_EX_RegRs then
                if EX_MEM_is_swap = '1' then
                    ForwardA <= "0011";  -- Forward EX/MEM ALU result (SWAP dest)
                elsif EX_MEM_is_in = '1' then
                    ForwardA <= "0100";  -- Forward EX/MEM input port
                else
                    ForwardA <= "0001";  -- Forward EX/MEM ALU result
                end if;
            else
                -- SWAP Rsrc1 match
                ForwardA <= "0010";  -- Forward EX/MEM Rsrc2 data
            end if;

        -- Priority 2: Check MEM/WB stage for older data
        elsif MEM_WB_RegWrite = '1' and
              (MEM_WB_DestReg = ID_EX_RegRs or
               (MEM_WB_is_swap = '1' and MEM_WB_Rsrc1 = ID_EX_RegRs)) then

            if MEM_WB_DestReg = ID_EX_RegRs then
                if MEM_WB_is_swap = '1' then
                    ForwardA <= "0111";  -- Forward MEM/WB ALU result (SWAP dest)
                elsif MEM_WB_is_in = '1' then
                    ForwardA <= "1000";  -- Forward MEM/WB input port
                elsif MEM_WB_mem_to_reg = '1' then
                    ForwardA <= "0101";  -- Forward MEM/WB memory data
                else
                    ForwardA <= "1001";  -- Forward MEM/WB ALU result
                end if;
            else
                -- SWAP Rsrc1 match
                ForwardA <= "0110";  -- Forward MEM/WB Rsrc2 data
            end if;
        end if;

    end process;

    --------------------------------------------------------------------
    -- Forward B (for Rsrc2 / Rdst / ALU Operand B)
    --------------------------------------------------------------------
    process (ID_EX_RegRt, EX_MEM_RegWrite, EX_MEM_DestReg, EX_MEM_Rsrc1,
             EX_MEM_is_swap, EX_MEM_is_in, MEM_WB_RegWrite, MEM_WB_DestReg,
             MEM_WB_Rsrc1, MEM_WB_is_swap, MEM_WB_is_in, MEM_WB_mem_to_reg)
    begin
        -- Default: No forwarding
        ForwardB <= "0000";

        -- Priority 1: Check EX/MEM stage for most recent data
        if EX_MEM_RegWrite = '1' and
           (EX_MEM_DestReg = ID_EX_RegRt or
            (EX_MEM_is_swap = '1' and EX_MEM_Rsrc1 = ID_EX_RegRt)) then

            if EX_MEM_DestReg = ID_EX_RegRt then
                if EX_MEM_is_swap = '1' then
                    ForwardB <= "0011";  -- Forward EX/MEM ALU result (SWAP dest)
                elsif EX_MEM_is_in = '1' then
                    ForwardB <= "0100";  -- Forward EX/MEM input port
                else
                    ForwardB <= "0001";  -- Forward EX/MEM ALU result
                end if;
            else
                -- SWAP Rsrc1 match
                ForwardB <= "0010";  -- Forward EX/MEM Rsrc2 data
            end if;

        -- Priority 2: Check MEM/WB stage for older data
        elsif MEM_WB_RegWrite = '1' and
              (MEM_WB_DestReg = ID_EX_RegRt or
               (MEM_WB_is_swap = '1' and MEM_WB_Rsrc1 = ID_EX_RegRt)) then

            if MEM_WB_DestReg = ID_EX_RegRt then
                if MEM_WB_is_swap = '1' then
                    ForwardB <= "0111";  -- Forward MEM/WB ALU result (SWAP dest)
                elsif MEM_WB_is_in = '1' then
                    ForwardB <= "1000";  -- Forward MEM/WB input port
                elsif MEM_WB_mem_to_reg = '1' then
                    ForwardB <= "0101";  -- Forward MEM/WB memory data
                else
                    ForwardB <= "1001";  -- Forward MEM/WB ALU result
                end if;
            else
                -- SWAP Rsrc1 match
                ForwardB <= "0110";  -- Forward MEM/WB Rsrc2 data
            end if;
        end if;

    end process;

end Behavioral;
