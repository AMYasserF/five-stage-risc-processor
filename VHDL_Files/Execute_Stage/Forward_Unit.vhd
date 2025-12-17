library ieee;
  use ieee.std_logic_1164.all;

entity Forwarding_Unit is
  port (
    -- ID/EX source registers
    ID_EX_RegRs     : in  std_logic_vector(2 downto 0);
    ID_EX_RegRt     : in  std_logic_vector(2 downto 0);

    -- EX/MEM stage info
    EX_MEM_RegWrite : in  std_logic;
    EX_MEM_DestReg  : in  std_logic_vector(2 downto 0);
    EX_MEM_Rsrc1    : in  std_logic_vector(2 downto 0);
    EX_MEM_is_swap  : in  std_logic;
    EX_MEM_is_in    : in  std_logic;

    -- MEM/WB stage info
    MEM_WB_RegWrite : in  std_logic;
    MEM_WB_DestReg  : in  std_logic_vector(2 downto 0);
    MEM_WB_Rsrc1    : in  std_logic_vector(2 downto 0);
    MEM_WB_is_swap  : in  std_logic;
    MEM_WB_is_in    : in  std_logic;
    MEM_WB_mem_to_reg: in std_logic;

    -- Forwarding controls
    ForwardA        : out std_logic_vector(3 downto 0);
    ForwardB        : out std_logic_vector(3 downto 0)
  );
end entity;

architecture Behavioral of Forwarding_Unit is
begin

  --------------------------------------------------------------------
  -- Forward A (Rsrc1)
  --------------------------------------------------------------------
  process (ID_EX_RegRs, EX_MEM_RegWrite, EX_MEM_DestReg, EX_MEM_Rsrc1,
    EX_MEM_is_swap, EX_MEM_is_in, MEM_WB_RegWrite, MEM_WB_DestReg,
    MEM_WB_Rsrc1, MEM_WB_is_swap, MEM_WB_is_in, MEM_WB_mem_to_reg)
  begin
    -- Default
ForwardA <= "0000";

-- EX/MEM match?
    if EX_MEM_RegWrite = '1' and
       (EX_MEM_DestReg = ID_EX_RegRs or
         (EX_MEM_is_swap = '1' and EX_MEM_Rsrc1 = ID_EX_RegRs)) then

      if EX_MEM_DestReg = ID_EX_RegRs then
        if EX_MEM_is_swap = '1' then
          ForwardA <= "0011";
        elsif EX_MEM_is_in = '1' then
          ForwardA <= "0100";
        else
          ForwardA <= "0001";
        end if;
      else
        -- swap Rsrc1 match
        ForwardA <= "0010";
      end if;

      -- MEM/WB match?
    elsif MEM_WB_RegWrite = '1' and (MEM_WB_DestReg = ID_EX_RegRs or (MEM_WB_is_swap = '1' and MEM_WB_Rsrc1 = ID_EX_RegRs)) then

      if MEM_WB_DestReg = ID_EX_RegRs then
        if MEM_WB_is_swap = '1' then
          ForwardA <= "0111";
        elsif MEM_WB_is_in = '1' then
          ForwardA <= "1000";
        elsif MEM_WB_mem_to_reg = '1' then
          ForwardA <= "0101";
        else
          ForwardA <= "1001";
        end if;
      else
        -- swap Rsrc1 match
        ForwardA <= "0110";
      end if;
    end if;

  end process;

  --------------------------------------------------------------------
  -- Forward B (Rsrc2 / Rdst)

  --------------------------------------------------------------------
  process (ID_EX_RegRt, EX_MEM_RegWrite, EX_MEM_DestReg, EX_MEM_Rsrc1,
    EX_MEM_is_swap, EX_MEM_is_in, MEM_WB_RegWrite, MEM_WB_DestReg,
    MEM_WB_Rsrc1, MEM_WB_is_swap, MEM_WB_is_in, MEM_WB_mem_to_reg)
  begin
    -- Default
ForwardB <= "0000";

-- EX/MEM match?
    if EX_MEM_RegWrite = '1' and
       (EX_MEM_DestReg = ID_EX_RegRt or
         (EX_MEM_is_swap = '1' and EX_MEM_Rsrc1 = ID_EX_RegRt)) then

      if EX_MEM_DestReg = ID_EX_RegRt then
        if EX_MEM_is_swap = '1' then
          ForwardB <= "0011";
        elsif EX_MEM_is_in = '1' then
          ForwardB <= "0100";
        else
          ForwardB <= "0001";
        end if;
      else
        ForwardB <= "0010";
      end if;

      -- MEM/WB match?
    elsif MEM_WB_RegWrite = '1' and (MEM_WB_DestReg = ID_EX_RegRt or (MEM_WB_is_swap = '1' and MEM_WB_Rsrc1 = ID_EX_RegRt)) then

      if MEM_WB_DestReg = ID_EX_RegRt then
        if MEM_WB_is_swap = '1' then
          ForwardB <= "0111";
        elsif MEM_WB_is_in = '1' then
          ForwardB <= "1000";
        elsif MEM_WB_mem_to_reg = '1' then
          ForwardB <= "0101";
        else
          ForwardB <= "1001";
        end if;
      else
        ForwardB <= "0110";
      end if;
    end if;

  end process;

end architecture;
