LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

entity Hazard_Detection_Unit is
  port(
    mem_mem_read : in std_logic; --Fetch_Memory use
	 mem_mem_write : in std_logic; --Fetch_Memory use
	 mem_is_pop : in std_logic; --Pop load use
	 mem_rdst : in std_logic_vector(2 downto 0); --Pop load use
	 ex_rsrc1 : in std_logic_vector(2 downto 0); --Pop load use
	 ex_rsrc2 : in std_logic_vector(2 downto 0); --Pop load use
	 ex_is_conditional : in std_logic; --Conditional jump 
	 ex_has_two_operands : in std_logic; --Pop load use
	 mem_is_int : in std_logic; --Interrupt
	 mem_is_ret : in std_logic; --Return
	 mem_is_rti : in std_logic; --Return interrupt
	 wb_is_swap : in std_logic; --Swap
	 wb_swap_phase : in std_logic; --Swap
	 mem_int_phase : in std_logic_vector(1 downto 0); --Interrupt
	 mem_rti_phase : in std_logic; --Return interrupt
	 if_flush : out std_logic; --Fetch_Memory use / Conditional jump / Return / Interrupt / Return interrupt
	 id_flush : out std_logic; --Return / Interrupt / Return interrupt
	 if_id_enable : out std_logic; --Swap
	 id_ex_enable : out std_logic; --Swap
	 ex_mem_enable : out std_logic; --Pop load use / Swap
	 pc_enable : out std_logic --Fetch_Memory use
  );
end entity;

architecture a_Hazard_Detection_Unit of Hazard_Detection_Unit is
begin
  
  process(mem_mem_read, mem_mem_write, mem_is_pop, mem_rdst, ex_rsrc1, ex_rsrc2, ex_is_conditional, ex_has_two_operands, mem_is_int, mem_is_ret, mem_is_rti, wb_is_swap, wb_swap_phase, mem_int_phase, mem_rti_phase)
  begin
    if((mem_mem_read = '1' or mem_mem_write = '1') or ex_is_conditional = '1' or mem_is_ret = '1' or (mem_is_rti = '1' and mem_rti_phase = '0') or (mem_is_int = '1' and mem_int_phase(1) = '0')) then
	   if_flush <= '1';
	 else
	   if_flush <= '0';
	 end if;
	 
	 if(mem_is_ret = '1' or (mem_is_rti = '1' and mem_rti_phase = '0') or (mem_is_int = '1' and mem_int_phase(1) = '0')) then
	   id_flush <= '1';
	 else
	   id_flush <= '0';
	 end if;
	 
	 if((wb_is_swap = '1' and wb_swap_phase = '1') or (((mem_rdst = ex_rsrc1) or ((mem_rdst = ex_rsrc2) and ex_has_two_operands = '1')) and mem_is_pop = '1')) then
	   if_id_enable <= '0';
		id_ex_enable <= '0';
		ex_mem_enable <= '0';
	 else
	   if_id_enable <= '1';
		id_ex_enable <= '1';
		ex_mem_enable <= '1';
	 end if;
	 
	 if((mem_mem_read = '1' or mem_mem_write = '1') or (((mem_rdst = ex_rsrc1) or ((mem_rdst = ex_rsrc2) and ex_has_two_operands = '1')) and mem_is_pop = '1') or (wb_is_swap = '1' and wb_swap_phase = '1')) then
	   pc_enable <= '0';
	 else
	   pc_enable <= '1';
	 end if;
  end process;
  
end a_Hazard_Detection_Unit;