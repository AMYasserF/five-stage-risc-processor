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
	 ex_has_one_operand : in std_logic; --Pop load use
	 ex_has_two_operands : in std_logic; --Pop load use
	 mem_is_int : in std_logic; --Interrupt
	 mem_is_call : in std_logic; --Call
	 mem_is_ret : in std_logic; --Return
	 mem_is_rti : in std_logic; --Return interrupt
	 wb_is_swap : in std_logic; --Swap
	 wb_swap_counter : in std_logic; --Swap counter (0=first cycle, 1=second cycle)
	 mem_int_phase : in std_logic_vector(1 downto 0); --INT counter: 00=STORE_PC, 01=STORE_CCR, 10=LOAD_VECTOR, 11=IDLE
	 mem_rti_phase : in std_logic_vector(1 downto 0); --RTI counter: 00=RESTORE_CCR, 01=RESTORE_PC, 11=IDLE
	 if_flush : out std_logic; --Fetch_Memory use / Conditional jump / Return / Interrupt / Return interrupt
	 id_flush : out std_logic; --Return / Interrupt / Return interrupt
	 ex_flush : out std_logic; --Return
	 if_id_enable : out std_logic; --Swap
	 id_ex_enable : out std_logic; --Swap
	 ex_mem_enable : out std_logic; --Pop load use / Swap
	 pc_enable : out std_logic; --Fetch_Memory use
	mem_wb_enable : out std_logic
  );
end entity;

architecture a_Hazard_Detection_Unit of Hazard_Detection_Unit is
begin
  
  process(mem_mem_read, mem_mem_write, mem_is_pop, mem_rdst, ex_rsrc1, ex_rsrc2, ex_is_conditional, ex_has_one_operand, ex_has_two_operands, mem_is_int, mem_is_call, mem_is_ret, mem_is_rti, wb_is_swap, wb_swap_counter, mem_int_phase, mem_rti_phase)
  begin
    -- IF_FLUSH: Flush fetch when memory operations, conditional jumps, or control flow changes
    -- RTI: flush on RESTORE_PC phase ("01")
    -- INT: flush on LOAD_VECTOR phase ("10")
    if((mem_mem_read = '1' or mem_mem_write = '1') or ex_is_conditional = '1' or mem_is_ret = '1' or (mem_rti_phase = "01") or (mem_int_phase = "10")) then
	   if_flush <= '1';
	 else
	   if_flush <= '0';
	 end if;
	 
	 -- ID_FLUSH and EX_FLUSH: Flush decode/execute on control flow changes
	 -- RTI: flush on RESTORE_PC phase ("01")
	 -- INT: flush on LOAD_VECTOR phase ("10")
	 if(mem_is_ret = '1' or (mem_rti_phase = "01") or (mem_int_phase = "10")) then
	   id_flush <= '1';
	   ex_flush <= '1';
	 else
	   id_flush <= '0';
	   ex_flush <= '0';
	 end if;
	 
	 -- Stall IF/ID and ID/EX during SWAP first cycle (counter=0) only
	 -- Stall during INT phases "00" and "01" (STORE_PC and STORE_CCR)
	 -- Stall during RTI phase "00" (RESTORE_CCR)
	 if((wb_is_swap = '1' and wb_swap_counter = '0') or ((((mem_rdst = ex_rsrc1) and (ex_has_one_operand = '1' or ex_has_two_operands = '1')) or ((mem_rdst = ex_rsrc2) and ex_has_two_operands = '1')) and mem_is_pop = '1') or (mem_int_phase = "00" or mem_int_phase = "01") or (mem_rti_phase = "00")) then
	   if_id_enable <= '0';
		id_ex_enable <= '0';
	 else
	   if_id_enable <= '1';
		id_ex_enable <= '1';
	 end if;

	 -- Stall EX/MEM during SWAP first cycle (counter=0) only
	 if((wb_is_swap = '1' and wb_swap_counter = '0') or ((((mem_rdst = ex_rsrc1) and (ex_has_one_operand = '1' or ex_has_two_operands = '1')) or ((mem_rdst = ex_rsrc2) and ex_has_two_operands = '1')) and mem_is_pop = '1')) then
		ex_mem_enable <= '0';
	 else
		ex_mem_enable <= '1';
	 end if;
	 
	 -- Stall PC during:
	 -- - SWAP first cycle (counter=0)
	 -- - INT phases "00" and "01" (STORE_PC and STORE_CCR)
	 -- - RTI phase "00" (RESTORE_CCR)
	 -- Enable PC when is_call or is_ret are active (allow them to proceed)
	 if(mem_is_call = '1' or mem_is_ret = '1') then
	   pc_enable <= '1';
	 elsif((mem_mem_read = '1' or mem_mem_write = '1') or ((((mem_rdst = ex_rsrc1) and (ex_has_one_operand = '1' or ex_has_two_operands = '1')) or ((mem_rdst = ex_rsrc2) and ex_has_two_operands = '1')) and mem_is_pop = '1') or (wb_is_swap = '1' and wb_swap_counter = '0') or (mem_int_phase = "00" or mem_int_phase = "01") or (mem_rti_phase = "00")) then
	   pc_enable <= '0';
	 else
	   pc_enable <= '1';
	 end if;

	 -- Stall MEM/WB during SWAP first cycle (counter=0) only
	 if(wb_is_swap = '1' and wb_swap_counter = '0') then
	  mem_wb_enable <= '0';
     else 
	  mem_wb_enable <= '1';
	  end if;
  end process;
  
end a_Hazard_Detection_Unit;