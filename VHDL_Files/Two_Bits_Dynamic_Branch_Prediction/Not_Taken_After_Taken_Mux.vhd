LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

entity Not_Taken_After_Taken_Mux is
    port(
        ex_alu_result : in std_logic_vector(31 downto 0);
        ex_pc_plus_one : in std_logic_vector(31 downto 0);
        ex_is_conditional_jump_taken : in std_logic;
        dbp_state_1 : in std_logic;
        mux_out : out std_logic_vector(31 downto 0) 
    );
end entity;

architecture a_Not_Taken_After_Taken_Mux of Not_Taken_After_Taken_Mux is
begin
  process(ex_alu_result, ex_pc_plus_one, ex_is_conditional_jump_taken, dbp_state_1) 
  begin
    if(dbp_state_1 = '0' and ex_is_conditional_jump_taken = '1') then
        mux_out <= ex_pc_plus_one;
    else
        mux_out <= ex_alu_result;
    end if;
  end process;
end a_Not_Taken_After_Taken_Mux;