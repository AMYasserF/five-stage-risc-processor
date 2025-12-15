library IEEE;
  use IEEE.STD_LOGIC_1164.all;
  use IEEE.NUMERIC_STD.all;

entity EX_MEM_Register is
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
end entity;

architecture Behavioral of EX_MEM_Register is
begin
  process (clk, reset)
  begin
    if reset = '1' then
      alu_result_out <= (others => '0');
      rdata2_out <= (others => '0');
      rsrc1_out <= (others => '0');
      rdst_out <= (others => '0');
      in_port_out <= (others => '0');
      is_hult_out <= '0';
      is_call_out <= '0';
      reg_write_out <= '0';
      swap_phase_out <= '0';
      is_swap_out <= '0';
      is_in_out <= '0';
      out_enable_out <= '0';
      mem_to_reg_out <= '0';
      mem_read_out <= '0';
      mem_write_out <= '0';
      int_phase_out <= '0';
      rti_phase_out <= '0';
      is_pop_out <= '0';
      is_push_out <= '0';
      alu_addr_out <= '0';
      is_int_out <= '0';
      is_ret_out <= '0';
      is_rti_out <= '0';
    elsif rising_edge(clk) then
      if flush_seg = '1' then
        alu_result_out <= (others => '0');
        rdata2_out <= (others => '0');
        rsrc1_out <= (others => '0');
        rdst_out <= (others => '0');
        in_port_out <= (others => '0');
        is_hult_out <= '0';
        is_call_out <= '0';
        reg_write_out <= '0';
        swap_phase_out <= '0';
        is_swap_out <= '0';
        is_in_out <= '0';
        out_enable_out <= '0';
        mem_to_reg_out <= '0';
        mem_read_out <= '0';
        mem_write_out <= '0';
        int_phase_out <= '0';
        rti_phase_out <= '0';
        is_pop_out <= '0';
        is_push_out <= '0';
        alu_addr_out <= '0';
        is_int_out <= '0';
        is_ret_out <= '0';
        is_rti_out <= '0';
      elsif enable = '1' then
        alu_result_out <= alu_result_in;
        rdata2_out <= rdata2_in;
        rsrc1_out <= rsrc1_in;
        rdst_out <= rdst_in;
        in_port_out <= in_port_in;
        is_hult_out <= is_hult_in;
        is_call_out <= is_call_in;
        reg_write_out <= reg_write_in;
        swap_phase_out <= swap_phase_in;
        is_in_out <= is_in_in;
        is_swap_out <= is_swap_in;
        out_enable_out <= out_enable_in;
        mem_to_reg_out <= mem_to_reg_in;
        mem_read_out <= mem_read_in;
        mem_write_out <= meme_write_in;
        int_phase_out <= int_phase_in;
        rti_phase_out <= rti_phase_in;
        is_pop_out <= is_pop_in;
        is_push_out <= is_push_in;
        alu_addr_out <= alu_addr_in;
        is_int_out <= is_int_in;
        is_ret_out <= is_ret_in;
        is_rti_out <= is_rti_in;
      end if;
    end if;
  end process;
end architecture;
