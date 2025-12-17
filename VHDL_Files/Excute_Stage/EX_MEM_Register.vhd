LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- EX/MEM Pipeline Register
-- Stores outputs from Execute stage to pass to Memory stage

entity EX_MEM_Register is
    Port (
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        
        -- Control signals from Execute stage
        ex_rti_phase       : in  STD_LOGIC;
        ex_int_phase       : in  STD_LOGIC;
        ex_mem_write       : in  STD_LOGIC;
        ex_mem_read        : in  STD_LOGIC;
        ex_mem_to_reg      : in  STD_LOGIC;
        ex_alu_op          : in  STD_LOGIC_VECTOR(3 downto 0);
        ex_out_enable      : in  STD_LOGIC;
        ex_is_swap         : in  STD_LOGIC;
        ex_swap_phase      : in  STD_LOGIC;
        ex_reg_write       : in  STD_LOGIC;
        ex_is_call         : in  STD_LOGIC;
        ex_is_ret          : in  STD_LOGIC;
        ex_is_push         : in  STD_LOGIC;
        ex_is_pop          : in  STD_LOGIC;
        ex_hlt             : in  STD_LOGIC;
        ex_is_in           : in  STD_LOGIC;
        ex_is_int          : in  STD_LOGIC;
        ex_is_rti          : in  STD_LOGIC;
        
        -- Data from Execute stage
        ex_read_reg1       : in  STD_LOGIC_VECTOR(2 downto 0);
        ex_write_reg       : in  STD_LOGIC_VECTOR(2 downto 0);
        ex_read_data2      : in  STD_LOGIC_VECTOR(31 downto 0);
        ex_alu_result      : in  STD_LOGIC_VECTOR(31 downto 0);
        ex_pc_plus_1       : in  STD_LOGIC_VECTOR(31 downto 0);
        
        -- Registered outputs to Memory stage
        mem_rti_phase      : out STD_LOGIC;
        mem_int_phase      : out STD_LOGIC;
        mem_mem_write      : out STD_LOGIC;
        mem_mem_read       : out STD_LOGIC;
        mem_mem_to_reg     : out STD_LOGIC;
        mem_alu_op         : out STD_LOGIC_VECTOR(3 downto 0);
        mem_out_enable     : out STD_LOGIC;
        mem_is_swap        : out STD_LOGIC;
        mem_swap_phase     : out STD_LOGIC;
        mem_reg_write      : out STD_LOGIC;
        mem_is_call        : out STD_LOGIC;
        mem_is_ret         : out STD_LOGIC;
        mem_is_push        : out STD_LOGIC;
        mem_is_pop         : out STD_LOGIC;
        mem_hlt            : out STD_LOGIC;
        mem_is_in          : out STD_LOGIC;
        mem_is_int         : out STD_LOGIC;
        mem_is_rti         : out STD_LOGIC;
        
        -- Data outputs
        mem_read_reg1      : out STD_LOGIC_VECTOR(2 downto 0);
        mem_write_reg      : out STD_LOGIC_VECTOR(2 downto 0);
        mem_read_data2     : out STD_LOGIC_VECTOR(31 downto 0);
        mem_alu_result     : out STD_LOGIC_VECTOR(31 downto 0);
        mem_pc_plus_1      : out STD_LOGIC_VECTOR(31 downto 0)
    );
end EX_MEM_Register;

architecture Behavioral of EX_MEM_Register is
begin
    
    process(clk, rst)
    begin
        if rst = '1' then
            -- Reset all control signals
            mem_rti_phase  <= '0';
            mem_int_phase  <= '0';
            mem_mem_write  <= '0';
            mem_mem_read   <= '0';
            mem_mem_to_reg <= '0';
            mem_alu_op     <= (others => '0');
            mem_out_enable <= '0';
            mem_is_swap    <= '0';
            mem_swap_phase <= '0';
            mem_reg_write  <= '0';
            mem_is_call    <= '0';
            mem_is_ret     <= '0';
            mem_is_push    <= '0';
            mem_is_pop     <= '0';
            mem_hlt        <= '0';
            mem_is_in      <= '0';
            mem_is_int     <= '0';
            mem_is_rti     <= '0';
            
            -- Reset data
            mem_read_reg1  <= (others => '0');
            mem_write_reg  <= (others => '0');
            mem_read_data2 <= (others => '0');
            mem_alu_result <= (others => '0');
            mem_pc_plus_1  <= (others => '0');
            
        elsif rising_edge(clk) then
            -- Register control signals
            mem_rti_phase  <= ex_rti_phase;
            mem_int_phase  <= ex_int_phase;
            mem_mem_write  <= ex_mem_write;
            mem_mem_read   <= ex_mem_read;
            mem_mem_to_reg <= ex_mem_to_reg;
            mem_alu_op     <= ex_alu_op;
            mem_out_enable <= ex_out_enable;
            mem_is_swap    <= ex_is_swap;
            mem_swap_phase <= ex_swap_phase;
            mem_reg_write  <= ex_reg_write;
            mem_is_call    <= ex_is_call;
            mem_is_ret     <= ex_is_ret;
            mem_is_push    <= ex_is_push;
            mem_is_pop     <= ex_is_pop;
            mem_hlt        <= ex_hlt;
            mem_is_in      <= ex_is_in;
            mem_is_int     <= ex_is_int;
            mem_is_rti     <= ex_is_rti;
            
            -- Register data
            mem_read_reg1  <= ex_read_reg1;
            mem_write_reg  <= ex_write_reg;
            mem_read_data2 <= ex_read_data2;
            mem_alu_result <= ex_alu_result;
            mem_pc_plus_1  <= ex_pc_plus_1;
        end if;
    end process;
    
end Behavioral;
