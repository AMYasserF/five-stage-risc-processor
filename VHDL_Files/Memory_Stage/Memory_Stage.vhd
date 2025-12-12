library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Memory Stage (MEM)
-- Handles load/store operations
-- Interfaces with the shared memory system

entity Memory_Stage is
    Port (
        -- Clock and Reset
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        
        -- Control signals from control unit
        mem_read : in STD_LOGIC;
        mem_write : in STD_LOGIC;
        
        -- Data from EX/MEM pipeline register
        alu_result : in STD_LOGIC_VECTOR(31 downto 0);
        write_data : in STD_LOGIC_VECTOR(31 downto 0);
        
        -- Interface to Memory System
        mem_address : out STD_LOGIC_VECTOR(31 downto 0);
        mem_write_data : out STD_LOGIC_VECTOR(31 downto 0);
        mem_write_enable : out STD_LOGIC;
        mem_read_enable : out STD_LOGIC;
        mem_read_data : in STD_LOGIC_VECTOR(31 downto 0);
        
        -- Outputs to MEM/WB pipeline register
        mem_data_out : out STD_LOGIC_VECTOR(31 downto 0);
        alu_result_out : out STD_LOGIC_VECTOR(31 downto 0)
    );
end Memory_Stage;

architecture Behavioral of Memory_Stage is
begin
    process(clk, rst)
    begin
        if rst = '1' then
            mem_data_out <= (others => '0');
            alu_result_out <= (others => '0');
            
        elsif rising_edge(clk) then
            -- Pass through ALU result
            alu_result_out <= alu_result;
            
            -- Handle load operation
            if mem_read = '1' then
                mem_data_out <= mem_read_data;
            else
                mem_data_out <= (others => '0');
            end if;
        end if;
    end process;
    
    -- Memory interface connections (combinational)
    mem_address <= alu_result;
    mem_write_data <= write_data;
    mem_write_enable <= mem_write;
    mem_read_enable <= mem_read;
    
end Behavioral;
