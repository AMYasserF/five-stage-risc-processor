LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.all;

entity Memory is
  port(
    clk : in std_logic;
	 mem_read : in std_logic;
	 mem_write : in std_logic;
	 hlt : in std_logic;
	 address : in std_logic_vector(17 downto 0);
	 write_data : in std_logic_vector(31 downto 0);
	 read_data : out std_logic_vector(31 downto 0)
	 );
end entity;

architecture a_Memory of Memory is

  type memory_type is array(0 to 262143) of std_logic_vector(31 downto 0);
  signal memory : memory_type := (others => (others => '0'));
  
begin
  process(clk)
  begin
    if(rising_edge(clk) and hlt = '0') then
	   if(mem_write = '1') then
		  memory(to_integer(unsigned(address))) <= write_data;
		end if;
	 end if;
  end process;
  
  read_data <= memory(to_integer(unsigned(address)));
     
end a_Memory;