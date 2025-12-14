library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Memory_Write_Data_Mux is
    Port (
        ccr_data : in STD_LOGIC_VECTOR(31 downto 0);            -- CCR Register
        pc_plus_1_idex : in STD_LOGIC_VECTOR(31 downto 0);      -- PC + 1 from ID/EX register
        regfile_data : in STD_LOGIC_VECTOR(31 downto 0);        -- Data from Register File
        sel : in STD_LOGIC_VECTOR(1 downto 0);                  -- Control signal
        write_data_out : out STD_LOGIC_VECTOR(31 downto 0)
    );
end Memory_Write_Data_Mux;

architecture Behavioral of Memory_Write_Data_Mux is
begin
    process(ccr_data, pc_plus_1_idex, regfile_data, sel)
    begin
        case sel is
            when "00" => write_data_out <= ccr_data;            -- CCR Register
            when "01" => write_data_out <= pc_plus_1_idex;      -- PC + 1 from ID/EX
            when "10" => write_data_out <= regfile_data;        -- Register File Data
            when others => write_data_out <= regfile_data;
        end case;
    end process;
end Behavioral;
