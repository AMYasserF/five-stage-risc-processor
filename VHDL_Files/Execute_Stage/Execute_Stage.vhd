-- NOTES:
-- for unary instructions, ID must put: idex_rdata1 = Rdst_value idex_rdata2 = don't care This is
-- Unary instructions operate on opA, not opB.
-- | Instruction            | idex_rdata1 | idex_rdata2 |
-- | ADD, SUB, AND, SWAP    | Rsrc1 | Rsrc2 | 
-- | LOAD / STORE address   | Rsrc2 | Rsrc1 | 
-- | not                    | Rdst_value | don't care | 
-- | INC, IN, OUT           | Rdst_value | don't care |
-- any ccr ==> ZNC

library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

entity ex_stage is
  port (
    clk                : in  std_logic;
    rst                : in  std_logic;
    -- for ex_mem register
    ex_mem_reg_enable  : in  std_logic;
    ex_mem_reg_flush   : in  std_logic;

    -- Inputs from ID/EX pipeline register
    idex_rdata1        : in  std_logic_vector(31 downto 0);
    idex_rdata2        : in  std_logic_vector(31 downto 0);
    ifd_imm            : in  std_logic_vector(31 downto 0);
    in_port_in         : in  std_logic_vector(31 downto 0); -- for IN instruction
    idex_rd            : in  std_logic_vector(2 downto 0);  -- dest reg
    rsrc1_in           : in  std_logic_vector(2 downto 0);
    is_immediate       : in  std_logic;                     -- 1 => use immediate for operand B
    reg_write_in       : in  std_logic;                     -- register write enable (passed through)
    mem_read_in        : in  std_logic;                     -- mem read (LDD- passed through)
    mem_write_in       : in  std_logic;                     -- mem write (STD - passed through)
    alu_op             : in  std_logic_vector(3 downto 0);  -- ALU function code
    pc_plus_1_in       : in  std_logic_vector(31 downto 0); -- PC+1 for branch calculations
    is_hult_in         : in  std_logic;
    is_call_in         : in  std_logic;
    is_swap_in         : in  std_logic;
    is_in_in           : in  std_logic;
    swap_phase_in      : in  std_logic;
    out_enable_in      : in  std_logic;
    mem_to_reg_in      : in  std_logic;
    is_jumpz           : in  std_logic;
    is_jumpc           : in  std_logic;
    is_jumpn           : in  std_logic;
    previous_ccr       : in  std_logic_vector(2 downto 0);  -- ZNC from previous inst
    stack_ccr          : in  std_logic_vector(2 downto 0);  -- CCR from stack
    ccr_in             : in  std_logic;
    ccr_write          : in  std_logic;
    int_phase_previous : in  std_logic;
    int_phase_next     : in  std_logic;
    rti_phase_previous : in  std_logic;
    rti_phase_next     : in  std_logic;
    is_pop_in          : in  std_logic;
    is_push_in         : in  std_logic;
    alu_addr_in        : in  std_logic;
    is_int_in          : in  std_logic;
    is_ret_in          : in  std_logic;
    is_rti_in          : in  std_logic;
    -- Forwarding control inputs (from Forwarding Unit)
    -- 00 = use idex operand, 01 = forward from EX/MEM, 10 = forward from MEM/WB
    forwardA           : in  std_logic_vector(3 downto 0);
    forwardB           : in  std_logic_vector(3 downto 0);

    -- Values to forward from later stages
    exmem_alu_result   : in  std_logic_vector(31 downto 0); -- EX/MEM ALU result
    exmem_in_port     : in  std_logic_vector(31 downto 0); -- EX/MEM IN port value
    exmem_swap_rdata2  : in  std_logic_vector(31 downto 0); -- EX/MEM SWAP second operand
    memwb_result       : in  std_logic_vector(31 downto 0); -- MEM/WB result
    memwb_alu_result   : in  std_logic_vector(31 downto 0); -- MEM/WB ALU result
    memwb_in_port     : in  std_logic_vector(31 downto 0); -- MEM/WB IN port value
    memwb_swap_rdata2  : in  std_logic_vector(31 downto 0); -- MEM/WB SWAP second operand

    -- Outputs -> EX/MEM pipeline register
    exmem_alu_out      : out std_logic_vector(31 downto 0);
    exmem_rdata2       : out std_logic_vector(31 downto 0); -- data to store
    in_port_out        : out std_logic_vector(31 downto 0); -- for IN instruction
    exmem_rd           : out std_logic_vector(2 downto 0);
    reg_write_out      : out std_logic;
    mem_read_out       : out std_logic;
    mem_write_out      : out std_logic;
    pc_plus_1_out      : out std_logic_vector(31 downto 0);
    is_hult_out        : out std_logic;
    is_call_out        : out std_logic;
    is_swap_out        : out std_logic;
    is_in_out          : out std_logic;
    swap_phase_out     : out std_logic;
    out_enable_out     : out std_logic;
    mem_to_reg_out     : out std_logic;
    rsrc1_out          : out std_logic_vector(2 downto 0);
    conditional_jump   : out std_logic;                     -- indicates if jump taken
    next_ccr           : out std_logic_vector(2 downto 0);
    int_phase          : out std_logic;
    rti_phase          : out std_logic;
    exmem_immediate    : out std_logic_vector(31 downto 0); -- for LDM  Rdst, Imm

    -- flags to propagate
    ex_flags_z         : out std_logic;
    ex_flags_n         : out std_logic;
    ex_flags_c         : out std_logic
  );
end entity;

architecture rtl of ex_stage is

  component EX_MEM_Register is
    port (
      -- control signals
      clk            : in  std_logic;
      reset          : in  std_logic;
      enable         : in  STD_LOGIC;
      flush_seg      : in  STD_LOGIC;
      -- input data signals
      alu_result_in  : in  std_logic_vector(31 downto 0);
      rdata2_in      : in  std_logic_vector(31 downto 0);
      in_port_in     : in  std_logic_vector(31 downto 0);
      rsrc1_in       : in  std_logic_vector(2 downto 0);
      rdst_in        : in  std_logic_vector(2 downto 0);
      is_hult_in     : in  std_logic;
      is_call_in     : in  std_logic;
      reg_write_in   : in  std_logic;
      swap_phase_in  : in  std_logic;
      is_swap_in     : in  std_logic;
      is_in_in       : in  std_logic;
      out_enable_in  : in  std_logic;
      mem_to_reg_in  : in  std_logic;
      mem_read_in    : in  std_logic;
      meme_write_in  : in  std_logic;
      int_phase_in   : in  std_logic;
      rti_phase_in   : in  std_logic;
      is_pop_in      : in  std_logic;
      is_push_in     : in  std_logic;
      alu_addr_in    : in  std_logic;
      is_int_in      : in  std_logic;
      is_ret_in      : in  std_logic;
      is_rti_in      : in  std_logic;
      -- output data signals
      alu_result_out : out std_logic_vector(31 downto 0);
      rdata2_out     : out std_logic_vector(31 downto 0);
      in_port_out    : out std_logic_vector(31 downto 0);
      rsrc1_out      : out std_logic_vector(2 downto 0);
      rdst_out       : out std_logic_vector(2 downto 0);
      is_hult_out    : out std_logic;
      is_call_out    : out std_logic;
      reg_write_out  : out std_logic;
      swap_phase_out : out std_logic;
      is_swap_out    : out std_logic;
      is_in_out      : out std_logic;
      out_enable_out : out std_logic;
      mem_to_reg_out : out std_logic;
      mem_read_out   : out std_logic;
      mem_write_out  : out std_logic;
      int_phase_out  : out std_logic;
      rti_phase_out  : out std_logic;
      is_pop_out     : out std_logic;
      is_push_out    : out std_logic;
      alu_addr_out   : out std_logic;
      is_int_out     : out std_logic;
      is_ret_out     : out std_logic;
      is_rti_out     : out std_logic

    );
  end component;

  -- ALU op encoding (Match these with your control unit)
  constant ALU_ADD  : std_logic_vector(3 downto 0) := "0001";
  constant ALU_SUB  : std_logic_vector(3 downto 0) := "0010";
  constant ALU_AND  : std_logic_vector(3 downto 0) := "0011";
  constant ALU_SWAP : std_logic_vector(3 downto 0) := "0100";
  constant ALU_NOT  : std_logic_vector(3 downto 0) := "0110";
  constant ALU_INC  : std_logic_vector(3 downto 0) := "0111";
  constant ALU_IADD : std_logic_vector(3 downto 0) := "0001"; -- Same as ADD
  constant ALU_SETC : std_logic_vector(3 downto 0) := "1000";
  constant ALU_OUT  : std_logic_vector(3 downto 0) := "1001";
  constant ALU_IN   : std_logic_vector(3 downto 0) := "1010";
  constant ALU_MOV  : std_logic_vector(3 downto 0) := "1011";

  -- Internal signals
  signal opA, opB               : std_logic_vector(31 downto 0);
  signal alu_inB                : std_logic_vector(31 downto 0);
  signal alu_res_sig            : std_logic_vector(31 downto 0); -- Internal signal for result
  signal z_flag, n_flag, c_flag : std_logic;
  signal cond_jump              : std_logic;
  signal n_ccr                  : std_logic_vector(2 downto 0);
  signal int_phase_s : std_logic;
  signal rti_phase_s   : std_logic;

begin

  -- -------------------------------------------------------------------------
  -- Forwarding Unit Muxes
  -- -------------------------------------------------------------------------
  process (idex_rdata1, exmem_alu_result, memwb_result, forwardA, exmem_swap_rdata2,
           exmem_in_port, memwb_alu_result, memwb_swap_rdata2, memwb_in_port)
  begin
    case forwardA is
      when "0000" => opA <= idex_rdata1; -- No forwarding
      when "0001" => opA <= exmem_alu_result; -- Forward from EX/MEM
      when "0010" => opA <= exmem_alu_result;
      when "0011" => opA <= exmem_swap_rdata2; 
      when "0100" => opA <= exmem_in_port; 
        
      when "0101" => opA <= memwb_result; -- Forward from MEM/WB
      when "0110" => opA <= memwb_alu_result; 
      when "0111" => opA <= memwb_swap_rdata2; 
      when "1000" => opA <= memwb_in_port;
      when "1001" => opA <= memwb_alu_result;
      when others => opA <= idex_rdata1;
    end case;
  end process;

  process (idex_rdata2, exmem_alu_result, memwb_result, forwardB, exmem_swap_rdata2,
           exmem_in_port, memwb_alu_result, memwb_swap_rdata2, memwb_in_port)
  begin
    case forwardB is
      when "0000" => opB <= idex_rdata2;       -- No forwarding
      when "0001" => opB <= exmem_alu_result;  -- for alu result
      when "0010" => opB <= exmem_alu_result;  -- For SWAP
      when "0011" => opB <= exmem_swap_rdata2; -- For SWAP
      when "0100" => opB <= exmem_in_port;     -- For IN
        
      when "0101" => opB <= memwb_result;      -- for memory result
      when "0110" => opB <= memwb_alu_result;  -- for SWAP
      when "0111" => opB <= memwb_swap_rdata2; -- for SWAP
      when "1000" => opB <= memwb_in_port;     -- For IN (from ex stage)
      when "1001" => opB <= memwb_alu_result;  -- For ALU result (from ex stage)
      when others => opB <= idex_rdata2;
    end case;
  end process;

  -- -------------------------------------------------------------------------
  -- Branch Evaluation Logic (Based on Previous CCR)
  -- Note: Phase 1 Report suggests this should happen in ID, but implemented here per your request.

  -- -------------------------------------------------------------------------
  process (is_jumpz, is_jumpn, is_jumpc, previous_ccr)
  begin
    -- default
    cond_jump <= '0';
    if is_jumpz = '1' then
      if previous_ccr(2) = '1' then -- Check Z
        cond_jump <= '1';
      end if;
    elsif is_jumpn = '1' then
      if previous_ccr(1) = '1' then -- Check N
        cond_jump <= '1';
      end if;
    elsif is_jumpc = '1' then
      if previous_ccr(0) = '1' then -- Check C
        cond_jump <= '1';
      end if;
    end if;
  end process;

  -- -------------------------------------------------------------------------
  -- ALU Input Selection (Register/Forwarded vs Immediate)
  -- -------------------------------------------------------------------------
  alu_inB <= ifd_imm when is_immediate = '1' else opB;

  -- -------------------------------------------------------------------------
  -- ALU Process
  -- -------------------------------------------------------------------------
  alu_proc: process (opA, alu_inB, alu_op)
    variable v_a     : unsigned(31 downto 0);
    variable v_b     : unsigned(31 downto 0);
    variable v_res   : unsigned(31 downto 0);
    variable v_carry : std_logic;
  begin
    v_a := unsigned(opA);
    v_b := unsigned(alu_inB);

    -- Defaults
    v_res := (others => '0');
    v_carry := '0';

    case alu_op is
      when ALU_ADD =>
        v_res := v_a + v_b;
        -- Carry out logic for addition
        if v_res < v_a then
          v_carry := '1';
        else
          v_carry := '0';
        end if;

      when ALU_SUB =>
        v_res := v_a - v_b;
        -- Borrow logic: Set Carry=1 if A < B (Borrow occurred)
        if v_a < v_b then
          v_carry := '1';
        else
          v_carry := '0';
        end if;

      when ALU_AND =>
        v_res := v_a and v_b;
        v_carry := '0'; -- Logical ops clear carry usually, or preserve. Using 0 here.

      when ALU_SWAP =>
        v_res := v_a;
        v_carry := '0';

      when ALU_NOT =>
        -- Unary: operate on opA (Rdst value)
        v_res := not v_a;
        v_carry := '0';

      when ALU_INC =>
        if v_a = x"FFFFFFFF" then
          v_carry := '1';
        else
          v_carry := '0';
        end if;
        v_res := v_a + 1;

      when ALU_SETC =>
        v_res := (others => '0');
        v_carry := '1';

      when ALU_OUT =>
        v_res := v_a; -- Pass through
        v_carry := '0';

      when ALU_IN =>
        v_res := v_a; -- Pass through (Assuming IN data is on opA/opB bus)
        v_carry := '0';

      when ALU_MOV =>
        v_res := v_a; -- Pass through for Move
        v_carry := '0';

      when others =>
        v_res := v_a;
        v_carry := '0';
    end case;

    -- 1. Assign Result Signal
    alu_res_sig <= std_logic_vector(v_res);

    -- 2. Calculate Flags using the VARIABLE v_res (Correct way!)
    -- Zero Flag
    if v_res = 0 then
      z_flag <= '1';
    else
      z_flag <= '0';
    end if;

    -- Negative Flag (MSB)
    if v_res(31) = '1' then
      n_flag <= '1';
    else
      n_flag <= '0';
    end if;

    -- Carry Flag
    c_flag <= v_carry;

  end process;

  -- -------------------------------------------------------------------------
  -- CCR Update Logic

  -- -------------------------------------------------------------------------
  process (previous_ccr, stack_ccr, ccr_in, ccr_write, z_flag, n_flag, c_flag, cond_jump, is_jumpz, is_jumpn, is_jumpc)
  begin
    -- Default: hold CCR
    n_ccr <= previous_ccr;

    -- 1. RTI restores CCR (highest priority)
    if ccr_in = '1' then
      n_ccr <= stack_ccr;

      -- 2. Conditional jumps clear a single flag ONLY if jump is taken
    elsif cond_jump = '1' then
      n_ccr <= previous_ccr; -- start from previous

      if is_jumpz = '1' then
        n_ccr(2) <= '0'; -- clear Z
      elsif is_jumpn = '1' then
        n_ccr(1) <= '0'; -- clear N
      elsif is_jumpc = '1' then
        n_ccr(0) <= '0'; -- clear C
      end if;

      -- 3. ALU instructions update CCR when enabled
    elsif ccr_write = '1' then
      n_ccr(2) <= z_flag;
      n_ccr(1) <= n_flag;
      n_ccr(0) <= c_flag;

    end if;
  end process;

  -- -------------------------------------------------------------------------
  -- Output Assignments to Pipeline Register
  -- -------------------------------------------------------------------------
  exmem_alu_out <= alu_res_sig;

  exmem_rd      <= idex_rd;
  reg_write_out <= reg_write_in;
  mem_read_out  <= mem_read_in;
  mem_write_out <= mem_write_in;

  pc_plus_1_out  <= pc_plus_1_in;
  is_hult_out    <= is_hult_in;
  is_call_out    <= is_call_in;
  is_swap_out    <= is_swap_in;
  is_in_out      <= is_in_in;
  swap_phase_out <= swap_phase_in;
  out_enable_out <= out_enable_in;

  mem_to_reg_out <= mem_to_reg_in;
  rsrc1_out      <= rsrc1_in;
  exmem_rdata2   <= opB;

  conditional_jump <= cond_jump;
  next_ccr         <= n_ccr;

  int_phase_s        <= int_phase_previous or int_phase_next;
  rti_phase_s        <= rti_phase_previous or rti_phase_next;
  int_phase          <= int_phase_s;
  rti_phase          <= rti_phase_s;
  exmem_immediate  <= ifd_imm; -- for LDM  Rdst, Imm
  -- Flag outputs
  ex_flags_z       <= z_flag;
  ex_flags_n       <= n_flag;
  ex_flags_c       <= c_flag;

  -- ex_mem pipeline register instantiation
  ex_mem_reg_inst: EX_MEM_Register
    port map (
      clk            => clk,
      reset          => rst,
      enable         => ex_mem_reg_enable,
      flush_seg      => ex_mem_reg_flush,
      alu_result_in  => alu_res_sig,
      rdata2_in      => opB,
      rsrc1_in       => rsrc1_in,
      in_port_in     => in_port_in,
      rdst_in        => idex_rd,
      is_hult_in     => is_hult_in,
      is_call_in     => is_call_in,
      reg_write_in   => reg_write_in,
      swap_phase_in  => swap_phase_in,
      is_swap_in     => is_swap_in,
      is_in_in       => is_in_in,
      out_enable_in  => out_enable_in,
      mem_to_reg_in  => mem_to_reg_in,
      mem_read_in    => mem_read_in,
      meme_write_in  => mem_write_in,
      int_phase_in   => int_phase_s,
      rti_phase_in   => rti_phase_s,
      is_pop_in      => is_pop_in,
      is_push_in     => is_push_in,
      alu_addr_in    => alu_addr_in,
      is_int_in      => is_int_in,
      is_ret_in      => is_ret_in,
      is_rti_in      => is_rti_in,

      alu_result_out => open,
      rdata2_out     => open,
      rsrc1_out      => open,
      rdst_out       => open,
      in_port_out    => open,
      is_hult_out    => open,
      is_call_out    => open,
      reg_write_out  => open,
      swap_phase_out => open,
      is_swap_out    => open,
      is_in_out      => open,
      out_enable_out => open,
      mem_to_reg_out => open,
      mem_read_out   => open,
      mem_write_out  => open,
      int_phase_out  => open,
      rti_phase_out  => open,
      is_pop_out     => open,
      is_push_out    => open,
      alu_addr_out   => open,
      is_int_out     => open,
      is_ret_out     => open,
      is_rti_out     => open
    );
end architecture;
