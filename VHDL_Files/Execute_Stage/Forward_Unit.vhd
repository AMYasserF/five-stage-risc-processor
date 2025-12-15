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
    MEM_WB_Rsrc1, MEM_WB_is_swap, MEM_WB_is_in)
  begin
    ForwardA <= "0000"; -- default: no forwarding

    -- EX/MEM has highest priority
    if EX_MEM_RegWrite = '1' then
      if EX_MEM_is_swap = '1' then
        if EX_MEM_Rsrc1 = ID_EX_RegRs then
          ForwardA <= "0010";
        elsif EX_MEM_DestReg = ID_EX_RegRs then
          ForwardA <= "0011";
        end if;
      elsif EX_MEM_is_in = '1' then
        if EX_MEM_DestReg = ID_EX_RegRs then
          ForwardA <= "0100";
        end if;
      else
        if EX_MEM_DestReg = ID_EX_RegRs then
          ForwardA <= "0001";
        end if;
      end if;

      -- MEM/WB (only if EX/MEM didn't match)
    elsif MEM_WB_RegWrite = '1' then
      if MEM_WB_is_swap = '1' then
        if MEM_WB_Rsrc1 = ID_EX_RegRs then
          ForwardA <= "0110";
        elsif MEM_WB_DestReg = ID_EX_RegRs then
          ForwardA <= "0111";
        end if;
      elsif MEM_WB_is_in = '1' then
        if MEM_WB_DestReg = ID_EX_RegRs then
          ForwardA <= "1000";
        end if;
      else
        if MEM_WB_DestReg = ID_EX_RegRs then
          ForwardA <= "0101";
        end if;
      end if;
    end if;
  end process;

  --------------------------------------------------------------------
  -- Forward B (Rsrc2 / Rdst)

  --------------------------------------------------------------------
  process (ID_EX_RegRt, EX_MEM_RegWrite, EX_MEM_DestReg, EX_MEM_Rsrc1,
    EX_MEM_is_swap, EX_MEM_is_in, MEM_WB_RegWrite, MEM_WB_DestReg,
    MEM_WB_Rsrc1, MEM_WB_is_swap, MEM_WB_is_in)
  begin
    ForwardB <= "0000"; -- default

    -- EX/MEM priority
    if EX_MEM_RegWrite = '1' then
      if EX_MEM_is_swap = '1' then
        if EX_MEM_Rsrc1 = ID_EX_RegRt then
          ForwardB <= "0010";
        elsif EX_MEM_DestReg = ID_EX_RegRt then
          ForwardB <= "0011";
        end if;
      elsif EX_MEM_is_in = '1' then
        if EX_MEM_DestReg = ID_EX_RegRt then
          ForwardB <= "0100";
        end if;
      else
        if EX_MEM_DestReg = ID_EX_RegRt then
          ForwardB <= "0001";
        end if;
      end if;

      -- MEM/WB
    elsif MEM_WB_RegWrite = '1' then
      if MEM_WB_is_swap = '1' then
        if MEM_WB_Rsrc1 = ID_EX_RegRt then
          ForwardB <= "0110";
        elsif MEM_WB_DestReg = ID_EX_RegRt then
          ForwardB <= "0111";
        end if;
      elsif MEM_WB_is_in = '1' then
        if MEM_WB_DestReg = ID_EX_RegRt then
          ForwardB <= "1000";
        end if;
      else
        if MEM_WB_DestReg = ID_EX_RegRt then
          ForwardB <= "0101";
        end if;
      end if;
    end if;
  end process;

end architecture;
