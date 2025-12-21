LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;
USE STD.textio.all;
USE IEEE.std_logic_textio.all;

entity Memory is
    -- Added generic to allow different programs via .do files
    generic (
        FILE_NAME : string := "mem.txt" 
    );
    port(
        clk        : in std_logic;
        mem_read   : in std_logic;
        mem_write  : in std_logic;
        hlt        : in std_logic;
        address    : in std_logic_vector(17 downto 0);
        write_data : in std_logic_vector(31 downto 0);
        read_data  : out std_logic_vector(31 downto 0)
    );
end entity;

architecture a_Memory of Memory is

    type memory_type is array(0 to 262143) of std_logic_vector(31 downto 0);

    -- Impure function to load the memory array from the assembler output file
    impure function InitMemoryFromFile (FileName : in string) return memory_type is
        file n_file       : text open read_mode is FileName;
        variable n_line   : line;
        variable temp_bv  : std_logic_vector(31 downto 0);
        variable temp_mem : memory_type := (others => (others => '0'));
    begin
        for i in memory_type'range loop
            if not endfile(n_file) then
                readline(n_file, n_line);
                read(n_line, temp_bv); -- Reads the binary string from the line
                temp_mem(i) := temp_bv;
            else
                exit; -- Exit loop if file is shorter than memory size
            end if;
        end loop;
        return temp_mem;
    end function;

    -- Initialize the signal using the function
    signal memory_signal : memory_type := InitMemoryFromFile(FILE_NAME);

begin

    process(clk)
    begin
        if(rising_edge(clk) and hlt = '0') then
            if(mem_write = '1') then
                memory_signal(to_integer(unsigned(address))) <= write_data;
            end if;
        end if;
    end process;
  
    -- Asynchronous read logic
    read_data <= memory_signal(to_integer(unsigned(address)));
     
end a_Memory;