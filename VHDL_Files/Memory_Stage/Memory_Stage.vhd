library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Memory Stage with Integrated Memory System
-- Includes: SP management, Memory Address/Write Data muxing, INT/RTI FSMs

entity Memory_Stage is
    Port (
        -- Clock and Reset
        clk : in STD_LOGIC;
        rst : in STD_LOGIC;
        hlt : in STD_LOGIC;
        
        -- Control signals from EX/MEM pipeline register
        is_ret : in STD_LOGIC;
        is_rti : in STD_LOGIC;
        is_int : in STD_LOGIC;
        mem_read : in STD_LOGIC;
        mem_write : in STD_LOGIC;
        is_push : in STD_LOGIC;
        alu_address_enable : in STD_LOGIC;
        mem_to_reg : in STD_LOGIC;
        is_pop : in STD_LOGIC;
        out_enable : in STD_LOGIC;
        is_swap : in STD_LOGIC;
        swap_phase_previous : in STD_LOGIC;
        swap_phase_next : in STD_LOGIC;
        reg_write : in STD_LOGIC;
        is_call : in STD_LOGIC;
        is_input : in STD_LOGIC;
        
        -- Data from EX/MEM pipeline register
        rdst : in STD_LOGIC_VECTOR(2 downto 0);
        rsrc1 : in STD_LOGIC_VECTOR(2 downto 0);
        rsrc2_data : in STD_LOGIC_VECTOR(31 downto 0);
        alu_result : in STD_LOGIC_VECTOR(31 downto 0);
        pc_data : in STD_LOGIC_VECTOR(31 downto 0);       -- PC from ID/EX
        ccr_data : in STD_LOGIC_VECTOR(31 downto 0);      -- CCR register
        input_port_data : in STD_LOGIC_VECTOR(31 downto 0);
        
        -- Outputs to Fetch Stage (PC control)
        int_load_pc_out : out STD_LOGIC;
        rti_load_pc_out : out STD_LOGIC;
        
        -- Outputs to MEM/WB pipeline register
        is_ret_out : out STD_LOGIC;
        is_rti_out : out STD_LOGIC;
        is_int_out : out STD_LOGIC;
        mem_read_out : out STD_LOGIC;
        mem_write_out : out STD_LOGIC;
        is_push_out : out STD_LOGIC;
        alu_address_out : out STD_LOGIC;
        mem_to_reg_out : out STD_LOGIC;
        is_pop_out : out STD_LOGIC;
        out_enable_out : out STD_LOGIC;
        is_swap_out : out STD_LOGIC;
        swap_phase_out : out STD_LOGIC;
        reg_write_out : out STD_LOGIC;
        is_call_out : out STD_LOGIC;
        is_input_out : out STD_LOGIC;
        rdst_out : out STD_LOGIC_VECTOR(2 downto 0);
        rsrc1_out : out STD_LOGIC_VECTOR(2 downto 0);
        rsrc2_data_out : out STD_LOGIC_VECTOR(31 downto 0);
        alu_result_out : out STD_LOGIC_VECTOR(31 downto 0);
        mem_data_out : out STD_LOGIC_VECTOR(31 downto 0);
        input_port_data_out : out STD_LOGIC_VECTOR(31 downto 0)
    );
end Memory_Stage;

architecture Structural of Memory_Stage is
    
    -- Component Declarations
    component SP_Register is
        Port (
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            enable : in STD_LOGIC;
            sp_in : in STD_LOGIC_VECTOR(31 downto 0);
            sp_out : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component SP_Adder is
        Port (
            sp_in : in STD_LOGIC_VECTOR(31 downto 0);
            sp_plus_1 : out STD_LOGIC_VECTOR(31 downto 0);
            sp_minus_1 : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component SP_Mux is
        Port (
            sp_plus_1 : in STD_LOGIC_VECTOR(31 downto 0);
            sp_minus_1 : in STD_LOGIC_VECTOR(31 downto 0);
            sel : in STD_LOGIC;
            sp_next : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component SP_Control_Unit is
        Port (
            is_call : in STD_LOGIC;
            is_push : in STD_LOGIC;
            is_pop : in STD_LOGIC;
            is_ret : in STD_LOGIC;
            int_sp_operation : in STD_LOGIC;
            rti_sp_operation : in STD_LOGIC;
            rst : in STD_LOGIC;
            sp_mux_sel : out STD_LOGIC;
            sp_enable : out STD_LOGIC
        );
    end component;
    
    component ALU_Plus_2_Adder is
        Port (
            alu_result : in STD_LOGIC_VECTOR(31 downto 0);
            alu_plus_2 : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component Memory_Address_Mux is
        Port (
            reset_address : in STD_LOGIC_VECTOR(31 downto 0);
            int_address : in STD_LOGIC_VECTOR(31 downto 0);
            pc_address : in STD_LOGIC_VECTOR(31 downto 0);
            sp_address : in STD_LOGIC_VECTOR(31 downto 0);
            sp_plus_1_address : in STD_LOGIC_VECTOR(31 downto 0);
            alu_address : in STD_LOGIC_VECTOR(31 downto 0);
            sel : in STD_LOGIC_VECTOR(2 downto 0);
            mem_address : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component Memory_Address_Control_Unit is
        Port (
            rst : in STD_LOGIC;
            int_mem_operation : in STD_LOGIC;
            is_push : in STD_LOGIC;
            is_call : in STD_LOGIC;
            is_pop : in STD_LOGIC;
            is_ret : in STD_LOGIC;
            rti_mem_operation : in STD_LOGIC;
            alu_address_enable : in STD_LOGIC;
            mem_addr_mux_sel : out STD_LOGIC_VECTOR(2 downto 0)
        );
    end component;
    
    component Memory_Write_Data_Mux is
        Port (
            pc_data : in STD_LOGIC_VECTOR(31 downto 0);
            rsrc2_data : in STD_LOGIC_VECTOR(31 downto 0);
            ccr_data : in STD_LOGIC_VECTOR(31 downto 0);
            sel : in STD_LOGIC_VECTOR(1 downto 0);
            mem_write_data : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    component Memory_Write_Data_Control_Unit is
        Port (
            is_call : in STD_LOGIC;
            is_push : in STD_LOGIC;
            is_pop : in STD_LOGIC;
            alu_address_enable : in STD_LOGIC;
            int_write_pc : in STD_LOGIC;
            int_write_ccr : in STD_LOGIC;
            mem_write_data_sel : out STD_LOGIC_VECTOR(1 downto 0)
        );
    end component;
    
    component INT_Control_Unit is
        Port (
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            is_int : in STD_LOGIC;
            int_mem_operation : out STD_LOGIC;
            int_sp_operation : out STD_LOGIC;
            int_write_pc : out STD_LOGIC;
            int_write_ccr : out STD_LOGIC;
            int_load_pc : out STD_LOGIC;
            int_mem_write : out STD_LOGIC;
            int_mem_read : out STD_LOGIC;
            int_active : out STD_LOGIC
        );
    end component;
    
    component RTI_Control_Unit is
        Port (
            clk : in STD_LOGIC;
            rst : in STD_LOGIC;
            is_rti : in STD_LOGIC;
            rti_sp_operation : out STD_LOGIC;
            rti_mem_operation : out STD_LOGIC;
            rti_load_ccr : out STD_LOGIC;
            rti_load_pc : out STD_LOGIC;
            rti_mem_read : out STD_LOGIC;
            rti_active : out STD_LOGIC
        );
    end component;
    
    component Memory is
        Port (
            clk : in STD_LOGIC;
            mem_read : in STD_LOGIC;
            mem_write : in STD_LOGIC;
            hlt : in STD_LOGIC;
            address : in STD_LOGIC_VECTOR(17 downto 0);
            write_data : in STD_LOGIC_VECTOR(31 downto 0);
            read_data : out STD_LOGIC_VECTOR(31 downto 0)
        );
    end component;
    
    -- Internal Signals
    -- SP signals
    signal sp_current : STD_LOGIC_VECTOR(31 downto 0);
    signal sp_next : STD_LOGIC_VECTOR(31 downto 0);
    signal sp_plus_1 : STD_LOGIC_VECTOR(31 downto 0);
    signal sp_minus_1 : STD_LOGIC_VECTOR(31 downto 0);
    signal sp_mux_sel : STD_LOGIC;
    signal sp_enable : STD_LOGIC;
    
    -- INT/RTI control signals
    signal int_mem_operation : STD_LOGIC;
    signal int_sp_operation : STD_LOGIC;
    signal int_write_pc : STD_LOGIC;
    signal int_write_ccr : STD_LOGIC;
    signal int_load_pc : STD_LOGIC;
    signal int_mem_write : STD_LOGIC;
    signal int_mem_read : STD_LOGIC;
    signal int_active : STD_LOGIC;
    
    signal rti_sp_operation : STD_LOGIC;
    signal rti_mem_operation : STD_LOGIC;
    signal rti_load_ccr : STD_LOGIC;
    signal rti_load_pc : STD_LOGIC;
    signal rti_mem_read : STD_LOGIC;
    signal rti_active : STD_LOGIC;
    
    -- Memory address signals
    signal alu_plus_2 : STD_LOGIC_VECTOR(31 downto 0);
    signal mem_address : STD_LOGIC_VECTOR(31 downto 0);
    signal mem_addr_mux_sel : STD_LOGIC_VECTOR(2 downto 0);
    signal reset_address : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal pc_address : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');  -- TODO: Connect to PC
    
    -- Memory write data signals
    signal mem_write_data : STD_LOGIC_VECTOR(31 downto 0);
    signal mem_write_data_sel : STD_LOGIC_VECTOR(1 downto 0);
    
    -- Memory control signals
    signal actual_mem_write : STD_LOGIC;
    signal actual_mem_read : STD_LOGIC;
    signal mem_read_data : STD_LOGIC_VECTOR(31 downto 0);
    
begin
    
    -- ==================== Stack Pointer System ====================
    SP_Reg: SP_Register
        port map (
            clk => clk,
            rst => rst,
            enable => sp_enable,
            sp_in => sp_next,
            sp_out => sp_current
        );
    
    SP_Add: SP_Adder
        port map (
            sp_in => sp_current,
            sp_plus_1 => sp_plus_1,
            sp_minus_1 => sp_minus_1
        );
    
    SP_Multiplexer: SP_Mux
        port map (
            sp_plus_1 => sp_plus_1,
            sp_minus_1 => sp_minus_1,
            sel => sp_mux_sel,
            sp_next => sp_next
        );
    
    SP_CU: SP_Control_Unit
        port map (
            is_call => is_call,
            is_push => is_push,
            is_pop => is_pop,
            is_ret => is_ret,
            int_sp_operation => int_sp_operation,
            rti_sp_operation => rti_sp_operation,
            rst => rst,
            sp_mux_sel => sp_mux_sel,
            sp_enable => sp_enable
        );
    
    -- ==================== INT/RTI Control Units ====================
    INT_CU: INT_Control_Unit
        port map (
            clk => clk,
            rst => rst,
            is_int => is_int,
            int_mem_operation => int_mem_operation,
            int_sp_operation => int_sp_operation,
            int_write_pc => int_write_pc,
            int_write_ccr => int_write_ccr,
            int_load_pc => int_load_pc,
            int_mem_write => int_mem_write,
            int_mem_read => int_mem_read,
            int_active => int_active
        );
    
    RTI_CU: RTI_Control_Unit
        port map (
            clk => clk,
            rst => rst,
            is_rti => is_rti,
            rti_sp_operation => rti_sp_operation,
            rti_mem_operation => rti_mem_operation,
            rti_load_ccr => rti_load_ccr,
            rti_load_pc => rti_load_pc,
            rti_mem_read => rti_mem_read,
            rti_active => rti_active
        );
    
    -- ==================== Memory Address System ====================
    ALU_Add_2: ALU_Plus_2_Adder
        port map (
            alu_result => alu_result,
            alu_plus_2 => alu_plus_2
        );
    
    Mem_Addr_Mux: Memory_Address_Mux
        port map (
            reset_address => reset_address,
            int_address => alu_plus_2,
            pc_address => pc_address,
            sp_address => sp_current,
            sp_plus_1_address => sp_plus_1,
            alu_address => alu_result,
            sel => mem_addr_mux_sel,
            mem_address => mem_address
        );
    
    Mem_Addr_CU: Memory_Address_Control_Unit
        port map (
            rst => rst,
            int_mem_operation => int_mem_operation,
            is_push => is_push,
            is_call => is_call,
            is_pop => is_pop,
            is_ret => is_ret,
            rti_mem_operation => rti_mem_operation,
            alu_address_enable => alu_address_enable,
            mem_addr_mux_sel => mem_addr_mux_sel
        );
    
    -- ==================== Memory Write Data System ====================
    Mem_Write_Mux: Memory_Write_Data_Mux
        port map (
            pc_data => pc_data,
            rsrc2_data => rsrc2_data,
            ccr_data => ccr_data,
            sel => mem_write_data_sel,
            mem_write_data => mem_write_data
        );
    
    Mem_Write_CU: Memory_Write_Data_Control_Unit
        port map (
            is_call => is_call,
            is_push => is_push,
            is_pop => is_pop,
            alu_address_enable => alu_address_enable,
            int_write_pc => int_write_pc,
            int_write_ccr => int_write_ccr,
            mem_write_data_sel => mem_write_data_sel
        );
    
    -- ==================== Memory ====================
    -- Combine memory control signals
    actual_mem_write <= mem_write or int_mem_write;
    actual_mem_read <= mem_read or int_mem_read or rti_mem_read;
    
    Mem: Memory
        port map (
            clk => clk,
            mem_read => actual_mem_read,
            mem_write => actual_mem_write,
            hlt => hlt,
            address => mem_address(17 downto 0),
            write_data => mem_write_data,
            read_data => mem_read_data
        );
    
    -- ==================== Outputs ====================
    -- Pass through control signals to MEM/WB
    is_ret_out <= is_ret;
    is_rti_out <= is_rti;
    is_int_out <= is_int;
    mem_read_out <= mem_read;
    mem_write_out <= mem_write;
    is_push_out <= is_push;
    alu_address_out <= alu_address_enable;
    mem_to_reg_out <= mem_to_reg;
    is_pop_out <= is_pop;
    out_enable_out <= out_enable;
    is_swap_out <= is_swap;
    swap_phase_out <= swap_phase_next or swap_phase_previous;
    reg_write_out <= reg_write;
    is_call_out <= is_call;
    is_input_out <= is_input;
    
    -- Pass through data to MEM/WB
    rdst_out <= rdst;
    rsrc1_out <= rsrc1;
    rsrc2_data_out <= rsrc2_data;
    alu_result_out <= alu_result;
    mem_data_out <= mem_read_data;
    input_port_data_out <= input_port_data;
    
    -- PC control outputs to Fetch Stage
    int_load_pc_out <= int_load_pc;
    rti_load_pc_out <= rti_load_pc;
    
end Structural;
