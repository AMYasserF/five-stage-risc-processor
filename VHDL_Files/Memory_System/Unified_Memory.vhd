LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
USE STD.textio.all;
USE IEEE.std_logic_textio.all;

entity Unified_Memory is
  generic(
    PROGRAM_FILE : string := "mem.txt"
  );
  port(
    clk : in std_logic;
    rst : in std_logic;
    hlt : in std_logic;
    fetch_address : in std_logic_vector(31 downto 0);
    fetch_data_out : out std_logic_vector(31 downto 0);
    mem_stage_address : in std_logic_vector(31 downto 0);
    mem_stage_write_data : in std_logic_vector(31 downto 0);
    mem_stage_read : in std_logic;
    mem_stage_write : in std_logic;
    mem_stage_data_out : out std_logic_vector(31 downto 0);
    mem_stage_active : in std_logic;
    pc_init_value : out std_logic_vector(31 downto 0);
    pc_init_valid : out std_logic
  );
end entity Unified_Memory;

architecture a_Unified_Memory of Unified_Memory is
  type memory_type is array(0 to 262143) of std_logic_vector(31 downto 0);

  impure function load_program_from_file(filename : string) return memory_type is
    file program_file : text;
    variable line_var : line;
    variable memory_init : memory_type := (others => (others => '0'));
    variable address_counter : integer := 0;
    variable token : string(1 to 256);
    variable token_len : natural;
    variable char_val : character;
    variable slv_value : std_logic_vector(31 downto 0);
    variable first_idx, last_idx, bin_start, hx_start : integer;
    variable is_binary : boolean;

    function char_to_sl(c : character) return std_logic is
    begin
      if c = '1' then return '1'; else return '0'; end if;
    end function;

    function hex_digit_to_nibble(c : character) return std_logic_vector is
    begin
      case c is
        when '0' => return "0000"; when '1' => return "0001"; when '2' => return "0010";
        when '3' => return "0011"; when '4' => return "0100"; when '5' => return "0101";
        when '6' => return "0110"; when '7' => return "0111"; when '8' => return "1000";
        when '9' => return "1001"; when 'A'|'a' => return "1010"; when 'B'|'b' => return "1011";
        when 'C'|'c' => return "1100"; when 'D'|'d' => return "1101"; when 'E'|'e' => return "1110";
        when 'F'|'f' => return "1111"; when others => return "0000";
      end case;
    end function;

  begin
    if filename'length > 0 then
      file_open(program_file, filename, read_mode);
      while not endfile(program_file) and address_counter < 262144 loop
        readline(program_file, line_var);
        token := (others => ' '); token_len := 0;
        while (line_var'length > 0) and (token_len < 256) loop
            token_len := token_len + 1;
            read(line_var, char_val);
            token(token_len) := char_val;
        end loop;
        first_idx := 1; last_idx := 0;
        for j in 1 to token_len loop
          if token(j) /= ' ' then
            if last_idx = 0 then first_idx := j; end if;
            last_idx := j;
          end if;
        end loop;
        if last_idx /= 0 then
          slv_value := (others => '0');
          bin_start := first_idx;
          if (last_idx-first_idx+1) > 2 and token(first_idx)='0' and (token(first_idx+1)='b' or token(first_idx+1)='B') then
            bin_start := first_idx + 2;
          end if;
          is_binary := true;
          for j in bin_start to last_idx loop
            if not (token(j) = '0' or token(j) = '1') then is_binary := false; exit; end if;
          end loop;
          if is_binary then
            for k in 0 to (last_idx - bin_start) loop
              if k < 32 then slv_value(k) := char_to_sl(token(last_idx - k)); end if;
            end loop;
          else
            hx_start := first_idx;
            if (last_idx-first_idx+1) > 2 and token(first_idx)='0' and (token(first_idx+1)='x' or token(first_idx+1)='X') then
              hx_start := first_idx + 2;
            end if;
            for k in 0 to 7 loop
              if (last_idx - k) >= hx_start then
                slv_value(k*4+3 downto k*4) := hex_digit_to_nibble(token(last_idx - k));
              end if;
            end loop;
          end if;
          memory_init(address_counter) := slv_value;
          address_counter := address_counter + 1;
        end if;
      end loop;
      file_close(program_file);
    end if;
    return memory_init;
  end function;

  signal memory : memory_type := load_program_from_file(PROGRAM_FILE);
begin
  fetch_data_out <= memory(to_integer(unsigned(fetch_address)));
  mem_stage_data_out <= memory(to_integer(unsigned(mem_stage_address)));
  pc_init_value <= memory(0);
  pc_init_valid <= '1';

  process(clk)
  begin
    if rising_edge(clk) and hlt = '0' then
      if mem_stage_active = '1' and mem_stage_write = '1' then
        memory(to_integer(unsigned(mem_stage_address))) <= mem_stage_write_data;
      end if;
    end if;
  end process;
end a_Unified_Memory;