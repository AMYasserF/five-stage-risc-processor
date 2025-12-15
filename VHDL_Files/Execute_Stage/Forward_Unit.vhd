library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity Forwarding_Unit is
  port (
    ID_EX_RegRs     : in  std_logic_vector(2 downto 0); -- Rsrc1 register address
    ID_EX_RegRt     : in  std_logic_vector(2 downto 0); -- Rsrc2/Rdst register address

    EX_MEM_RegWrite : in  std_logic;                    -- RegWrite signal
    EX_MEM_DestReg  : in  std_logic_vector(2 downto 0); -- Destination register address

    MEM_WB_RegWrite : in  std_logic;
    MEM_WB_DestReg  : in  std_logic_vector(2 downto 0);

    ForwardA        : out std_logic_vector(1 downto 0); -- Control for ALU Input A (Rsrc1)
    ForwardB        : out std_logic_vector(1 downto 0)  -- Control for ALU Input B (Rsrc2/Rdst)
  );
end entity;

architecture Behavioral of Forwarding_Unit is
begin

  process (ID_EX_RegRs, EX_MEM_RegWrite, EX_MEM_DestReg, MEM_WB_RegWrite, MEM_WB_DestReg)
  begin
    ForwardA <= "00";

    if (EX_MEM_RegWrite = '1') then
      if (EX_MEM_DestReg = ID_EX_RegRs) then
        ForwardA <= "01";
      end if;
    end if;

    if (MEM_WB_RegWrite = '1') then
      if (MEM_WB_DestReg = ID_EX_RegRs) then
        if not (EX_MEM_RegWrite = '1' and EX_MEM_DestReg = ID_EX_RegRs) then
          ForwardA <= "10";
        end if;
      end if;
    end if;
  end process;


  process (ID_EX_RegRt, EX_MEM_RegWrite, EX_MEM_DestReg, MEM_WB_RegWrite, MEM_WB_DestReg)
  begin
    ForwardB <= "00";

    if (EX_MEM_RegWrite = '1') then
      if (EX_MEM_DestReg = ID_EX_RegRt) then
        ForwardB <= "01";
      end if;
    end if;

    if (MEM_WB_RegWrite = '1') then
      if (MEM_WB_DestReg = ID_EX_RegRt) then
        if not (EX_MEM_RegWrite = '1' and EX_MEM_DestReg = ID_EX_RegRt) then
          ForwardB <= "10";
        end if;
      end if;
    end if;
  end process;

end architecture;
