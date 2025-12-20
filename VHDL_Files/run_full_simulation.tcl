# ============================================================================
# Complete Processor Simulation Script
# ============================================================================
# This script compiles all components, runs the testbench, and sets up waveforms
# Usage: vsim -do run_full_simulation.tcl
# ============================================================================

puts "======================================"
puts "Compiling Complete 5-Stage Processor"
puts "======================================"

# Create work library if it doesn't exist
vlib work

# ========================================
# COMPILE ALL COMPONENTS
# ========================================

puts "\n=== Compiling Memory System ==="
vcom -2008 Memory_System/Memory.vhd

puts "\n=== Compiling Fetch Stage Components ==="
vcom -2008 Fetch_Stage/PC_Register.vhd
vcom -2008 Fetch_Stage/PC_Adder.vhd
vcom -2008 Fetch_Stage/PC_Mux.vhd
vcom -2008 Fetch_Stage/Fetch_Control_Units/PC_Mux_Control.vhd
vcom -2008 Fetch_Stage/Fetch_Stage.vhd
vcom -2008 Fetch_Stage/IF_ID_Register.vhd

puts "\n=== Compiling Decode Stage Components ==="
vcom -2008 Decode_Stage/register_file.vhd
vcom -2008 Decode_Stage/control_unit.vhd
vcom -2008 Decode_Stage/decode_stage.vhd
vcom -2008 Decode_Stage/ID_EX_register.vhd

puts "\n=== Compiling Execute Stage Components ==="
vcom -2008 Excute_Stage/ALU.vhd
vcom -2008 Excute_Stage/ALU_OperandA_Mux.vhd
vcom -2008 Excute_Stage/ALU_OperandB_Mux.vhd
vcom -2008 Excute_Stage/Branch_Logic.vhd
vcom -2008 Excute_Stage/CCR_Register.vhd
vcom -2008 Excute_Stage/CCR_Branch_Unit.vhd
vcom -2008 Excute_Stage/CCR_Mux.vhd
vcom -2008 Excute_Stage/Execute_Stage.vhd
vcom -2008 Excute_Stage/EX_MEM_Register.vhd

puts "\n=== Compiling Memory Stage Components ==="
vcom -2008 Memory_System/SP_Components/SP_Register.vhd
vcom -2008 Memory_System/SP_Components/SP_Adder.vhd
vcom -2008 Memory_System/SP_Components/SP_Mux.vhd
vcom -2008 Memory_System/SP_Components/SP_Control_Unit.vhd
vcom -2008 Memory_System/Memory_Address_Components/ALU_Plus_2_Adder.vhd
vcom -2008 Memory_System/Memory_Address_Components/Memory_Address_Mux.vhd
vcom -2008 Memory_System/Memory_Address_Components/Memory_Address_Control_Unit.vhd
vcom -2008 Memory_System/Memory_Write_Data_Components/Memory_Write_Data_Mux.vhd
vcom -2008 Memory_System/Memory_Write_Data_Components/Memory_Write_Data_Control_Unit.vhd
vcom -2008 Memory_System/Control_Units/INT_Control_Unit.vhd
vcom -2008 Memory_System/Control_Units/RTI_Control_Unit.vhd
vcom -2008 Memory_Stage/Memory_Stage.vhd
vcom -2008 Memory_Stage/Mem_Wb_Register.vhd

puts "\n=== Compiling Writeback Stage ==="
vcom -2008 Writeback_Stage/Write_Back.vhd

puts "\n=== Compiling I/O Port Registers ==="
vcom -2008 IO_Ports/Input_Port_Register.vhd
vcom -2008 IO_Ports/Output_Port_Register.vhd

puts "\n=== Compiling Forwarding Unit ==="
vcom -2008 Forwarding_Unit.vhd

puts "\n=== Compiling Hazard Detection Unit ==="
vcom -2008 Hazard_Detection_Unit/Hazard_Detection_Unit.vhd

puts "\n=== Compiling Top-Level Processor ==="
vcom -2008 Processor_Top.vhd

puts "\n=== Compiling Testbench ==="
vcom -2008 Processor_Top_TB.vhd

# ========================================
# START SIMULATION
# ========================================

puts "\n======================================"
puts "Starting Simulation"
puts "======================================"

# Load simulation with full signal visibility
vsim -voptargs=+acc work.Processor_Top_TB

puts "\nSimulation loaded with full signal visibility"
puts "All internal signals are now accessible"

# ========================================
# ADD WAVEFORMS - ORGANIZED BY PIPELINE STAGES
# ========================================

puts "\n======================================"
puts "Adding Waveforms"
puts "======================================"

# ========================================
# CLOCK AND RESET
# ========================================
add wave -divider -height 30 "========== CLOCK & RESET =========="
add wave -label "Clock" -color Yellow /Processor_Top_TB/clk
add wave -label "Reset" -color Red /Processor_Top_TB/rst

# ========================================
# FETCH STAGE
# ========================================
add wave -divider -height 25 "========== FETCH STAGE =========="
puts "Adding Fetch signals..."
add wave -label "PC" -radix unsigned /Processor_Top_TB/UUT/Fetch/pc_current
add wave -label "PC Next" -radix unsigned /Processor_Top_TB/UUT/Fetch/pc_next
add wave -label "PC+1" -radix unsigned /Processor_Top_TB/UUT/Fetch/pc_incremented

# PC Mux Control and Inputs
#add wave -divider -height 20 "--- PC Mux Control ---"
add wave -label ">>> PC Mux Selector <<<" -radix binary /Processor_Top_TB/UUT/Fetch/pc_mux_sel_signal

# Jump Control Signals
#add wave -divider -height 20 "--- Jump Control ---"
add wave -label ">>> Conditional Jump (from Execute) <<<" /Processor_Top_TB/UUT/conditional_jump_from_execute
add wave -label ">>> Unconditional Branch (from Decode) <<<" /Processor_Top_TB/UUT/unconditional_branch_from_decode

# ========================================
# IF/ID REGISTER
# ========================================
#add wave -divider -height 25 "========== IF/ID REGISTER =========="
#puts "Adding IF/ID signals..."
#if {[catch {add wave -label "PC+1" -radix unsigned /Processor_Top_TB/UUT/#pc_plus_1_decode_signal}]} {puts "  Warning: PC+1 signal not found"}
#if {[catch {add wave -label "Instruction" -radix hex /Processor_Top_TB/UUT/#instruction_decode_signal}]} {puts "  Warning: Instruction signal not found"}

# ========================================
# DECODE STAGE
# ========================================
add wave -divider -height 25 "========== DECODE STAGE =========="
puts "Adding Decode signals..."
if {[catch {add wave -label "Read Data 1" -radix hex /Processor_Top_TB/UUT/read_data1_decode}]} {puts "  Warning: Read Data 1 not found"}
if {[catch {add wave -label "Read Data 2" -radix hex /Processor_Top_TB/UUT/read_data2_decode}]} {puts "  Warning: Read Data 2 not found"}

# ========================================
# CONTROL UNIT OUTPUTS
# ========================================
add wave -divider -height 25 "========== CONTROL UNIT =========="
puts "Adding Control Unit signals..."
if {[catch {add wave -label ">>> ALU Address Enable (Decode Output) <<<" -color Cyan /Processor_Top_TB/UUT/Decode/ctrl_unit/alu_address_enable}]} {puts "  Warning: ALU Address Enable from CU not found"}
if {[catch {add wave -label ">>> Is PUSH <<<" /Processor_Top_TB/UUT/Decode/ctrl_unit/is_push}]} {puts "  Warning: Is PUSH not found"}
if {[catch {add wave -label ">>> Is POP <<<" /Processor_Top_TB/UUT/Decode/ctrl_unit/is_pop}]} {puts "  Warning: Is POP not found"}
if {[catch {add wave -label ">>> Mem Write <<<" /Processor_Top_TB/UUT/Decode/ctrl_unit/mem_write}]} {puts "  Warning: Mem Write not found"}
if {[catch {add wave -label ">>> Mem Read <<<" /Processor_Top_TB/UUT/Decode/ctrl_unit/mem_read}]} {puts "  Warning: Mem Read not found"}
if {[catch {add wave -label "Mem to Reg" /Processor_Top_TB/UUT/Decode/ctrl_unit/mem_to_reg}]} {puts "  Warning: Mem to Reg not found"}
if {[catch {add wave -label "Reg Write" /Processor_Top_TB/UUT/Decode/ctrl_unit/reg_write}]} {puts "  Warning: Reg Write not found"}
if {[catch {add wave -label "ALU Op" -radix hex /Processor_Top_TB/UUT/Decode/ctrl_unit/alu_op}]} {puts "  Warning: ALU Op not found"}
if {[catch {add wave -label "Is Immediate" /Processor_Top_TB/UUT/Decode/ctrl_unit/is_immediate}]} {puts "  Warning: Is Immediate not found"}
if {[catch {add wave -label "Is Call" /Processor_Top_TB/UUT/Decode/ctrl_unit/is_call}]} {puts "  Warning: Is Call not found"}
if {[catch {add wave -label "Is Ret" /Processor_Top_TB/UUT/Decode/ctrl_unit/is_ret}]} {puts "  Warning: Is Ret not found"}
if {[catch {add wave -label "Out Enable" /Processor_Top_TB/UUT/Decode/ctrl_unit/out_enable}]} {puts "  Warning: Out Enable not found"}
if {[catch {add wave -label "Is Input" /Processor_Top_TB/UUT/Decode/ctrl_unit/is_in}]} {puts "  Warning: Is Input not found"}

# ========================================
# REGISTER FILE (R0-R7)
# ========================================
add wave -divider -height 25 "========== REGISTER FILE =========="
puts "Adding Register File signals..."
if {[catch {
    add wave -label "R0" -radix hex /Processor_Top_TB/UUT/Decode/reg_file/registers(0)
    add wave -label "R1" -radix hex /Processor_Top_TB/UUT/Decode/reg_file/registers(1)
    add wave -label "R2" -radix hex /Processor_Top_TB/UUT/Decode/reg_file/registers(2)
    add wave -label "R3" -radix hex /Processor_Top_TB/UUT/Decode/reg_file/registers(3)
    add wave -label "R4" -radix hex /Processor_Top_TB/UUT/Decode/reg_file/registers(4)
    add wave -label "R5" -radix hex /Processor_Top_TB/UUT/Decode/reg_file/registers(5)
    add wave -label "R6" -radix hex /Processor_Top_TB/UUT/Decode/reg_file/registers(6)
    add wave -label "R7" -radix hex /Processor_Top_TB/UUT/Decode/reg_file/registers(7)
}]} {puts "  Warning: Register file not accessible"}

# ========================================
# ID/EX REGISTER  
# ========================================
add wave -divider -height 25 "========== ID/EX REGISTER =========="
puts "Adding ID/EX signals..."
if {[catch {add wave -label ">>> ALU Address Enable IN <<<" -color Cyan /Processor_Top_TB/UUT/IDEX_Reg/alu_address_enable_in}]} {puts "  Warning: alu_address_enable_in not found"}
if {[catch {add wave -label ">>> ALU Address Enable OUT <<<" -color Cyan /Processor_Top_TB/UUT/IDEX_Reg/alu_address_enable_out}]} {puts "  Warning: alu_address_enable_out not found"}
if {[catch {add wave -label ">>> ALU Address Enable REG <<<" -color Cyan /Processor_Top_TB/UUT/IDEX_Reg/alu_address_enable_reg}]} {puts "  Warning: alu_address_enable_reg not found"}
if {[catch {add wave -label "Read Data 1" -radix hex /Processor_Top_TB/UUT/idex_read_data1}]} {puts "  Warning: Read Data 1 not found"}
if {[catch {add wave -label "Read Data 2" -radix hex /Processor_Top_TB/UUT/idex_read_data2}]} {puts "  Warning: Read Data 2 not found"}
if {[catch {add wave -label "Is Immediate" /Processor_Top_TB/UUT/idex_is_immediate}]} {puts "  Warning: Is Immediate not found"}

# ========================================
# EXECUTE STAGE (ALU)
# ========================================
add wave -divider -height 25 "========== EXECUTE STAGE (ALU) =========="
puts "Adding Execute signals..."
if {[catch {add wave -label ">>> ALU Address Enable IN (from ID/EX) <<<" -color Cyan /Processor_Top_TB/UUT/Execute/id_ex_alu_address_enable}]} {puts "  Warning: id_ex_alu_address_enable not found"}
if {[catch {add wave -label ">>> ALU Address Enable OUT (to EX/MEM) <<<" -color Cyan /Processor_Top_TB/UUT/Execute/ex_mem_alu_address_enable}]} {puts "  Warning: ex_mem_alu_address_enable not found"}
if {[catch {add wave -label "ALU Operand A (Input)" -radix hex /Processor_Top_TB/UUT/Execute/alu_operand_a}]} {puts "  Warning: ALU Operand A not found"}
if {[catch {add wave -label "ALU Operand B (Input)" -radix hex /Processor_Top_TB/UUT/Execute/alu_operand_b}]} {puts "  Warning: ALU Operand B not found"}
if {[catch {add wave -label "ALU Operation" -radix hex /Processor_Top_TB/UUT/Execute/id_ex_alu_op}]} {puts "  Warning: ALU Operation not found"}
if {[catch {add wave -label "ALU Result (Output)" -radix hex /Processor_Top_TB/UUT/Execute/alu_result_internal}]} {puts "  Warning: ALU Result not found"}
if {[catch {add wave -label "Zero Flag" /Processor_Top_TB/UUT/Execute/alu_zero_flag}]} {puts "  Warning: Zero Flag not found"}
if {[catch {add wave -label "Carry Flag" /Processor_Top_TB/UUT/Execute/alu_carry_flag}]} {puts "  Warning: Carry Flag not found"}
if {[catch {add wave -label "Negative Flag" /Processor_Top_TB/UUT/Execute/alu_neg_flag}]} {puts "  Warning: Negative Flag not found"}

# ========================================
# CCR (Condition Code Register)
# ========================================
add wave -divider -height 25 "========== CCR LOGIC =========="
puts "Adding CCR signals..."
if {[catch {add wave -label "CCR Selector (00=ALU,01=Branch,10=Stack)" -radix binary /Processor_Top_TB/UUT/Execute/id_ex_ccr_in}]} {puts "  Warning: CCR selector not found"}
if {[catch {add wave -label ">>> ALU CCR Enable <<<" /Processor_Top_TB/UUT/Execute/alu_ccr_enable}]} {puts "  Warning: ALU CCR Enable not found"}
if {[catch {add wave -label ">>> CCR Write Enable <<<" /Processor_Top_TB/UUT/Execute/ccr_write_enable}]} {puts "  Warning: CCR write enable not found"}
if {[catch {add wave -label "ALU Z Flag" /Processor_Top_TB/UUT/Execute/alu_zero_flag}]} {puts "  Warning: ALU Z flag not found"}
if {[catch {add wave -label "ALU C Flag" /Processor_Top_TB/UUT/Execute/alu_carry_flag}]} {puts "  Warning: ALU C flag not found"}
if {[catch {add wave -label "ALU N Flag" /Processor_Top_TB/UUT/Execute/alu_neg_flag}]} {puts "  Warning: ALU N flag not found"}
if {[catch {add wave -label ">>> CCR from ALU <<<" -radix hex /Processor_Top_TB/UUT/Execute/ccr_from_alu}]} {puts "  Warning: CCR from ALU not found"}
if {[catch {add wave -label "CCR from Branch" -radix hex /Processor_Top_TB/UUT/Execute/ccr_from_branch}]} {puts "  Warning: CCR from branch not found"}
if {[catch {add wave -label ">>> CCR Mux Output (to Reg) <<<" -radix hex /Processor_Top_TB/UUT/Execute/ccr_mux_out}]} {puts "  Warning: CCR Mux output not found"}
if {[catch {add wave -label "CCR Reg D_in" -radix hex /Processor_Top_TB/UUT/Execute/ccr_reg/D_in}]} {puts "  Warning: CCR Reg D_in not found"}
if {[catch {add wave -label "CCR Reg wen" /Processor_Top_TB/UUT/Execute/ccr_reg/wen}]} {puts "  Warning: CCR Reg wen not found"}
if {[catch {add wave -label "CCR Reg internal_reg" -radix hex /Processor_Top_TB/UUT/Execute/ccr_reg/internal_reg}]} {puts "  Warning: CCR Reg internal not found"}
if {[catch {add wave -label "CCR Reg Q_out" -radix hex /Processor_Top_TB/UUT/Execute/ccr_reg/Q_out}]} {puts "  Warning: CCR Reg Q_out not found"}
if {[catch {add wave -label "CCR Register Output" -radix hex /Processor_Top_TB/UUT/Execute/ccr_register_out}]} {puts "  Warning: CCR register output not found"}
if {[catch {add wave -label "CCR Z Flag Output" /Processor_Top_TB/UUT/Execute/ccr_z_flag}]} {puts "  Warning: CCR Z flag output not found"}
if {[catch {add wave -label "CCR C Flag Output" /Processor_Top_TB/UUT/Execute/ccr_c_flag}]} {puts "  Warning: CCR C flag output not found"}
if {[catch {add wave -label "CCR N Flag Output" /Processor_Top_TB/UUT/Execute/ccr_n_flag}]} {puts "  Warning: CCR N flag output not found"}

# ========================================
# EX/MEM REGISTER
# ========================================
add wave -divider -height 25 "========== EX/MEM REGISTER =========="
puts "Adding EX/MEM signals..."
if {[catch {add wave -label ">>> ALU Address Enable IN <<<" -color Cyan /Processor_Top_TB/UUT/EXMEM_Reg/ex_alu_address_enable}]} {puts "  Warning: ex_alu_address_enable not found"}
if {[catch {add wave -label ">>> ALU Address Enable OUT <<<" -color Cyan /Processor_Top_TB/UUT/EXMEM_Reg/mem_alu_address_enable}]} {puts "  Warning: mem_alu_address_enable not found"}
if {[catch {add wave -label "ALU Result" -radix hex /Processor_Top_TB/UUT/exmem_alu_result}]} {puts "  Warning: ALU Result not found"}
if {[catch {add wave -label "Write Reg" -radix unsigned /Processor_Top_TB/UUT/exmem_write_reg}]} {puts "  Warning: Write Reg not found"}
if {[catch {add wave -label "Reg Write Enable" /Processor_Top_TB/UUT/exmem_reg_write}]} {puts "  Warning: Reg Write Enable not found"}
if {[catch {add wave -label "Mem Write" /Processor_Top_TB/UUT/exmem_mem_write}]} {puts "  Warning: Mem Write not found"}
if {[catch {add wave -label "Mem Read" /Processor_Top_TB/UUT/exmem_mem_read}]} {puts "  Warning: Mem Read not found"}

# ========================================
# MEMORY STAGE
# ========================================
add wave -divider -height 25 "========== MEMORY STAGE =========="
puts "Adding Memory signals..."
if {[catch {add wave -label ">>> ALU Address Enable (to Control Unit) <<<" -color Cyan /Processor_Top_TB/UUT/Memory/alu_address_enable}]} {puts "  Warning: alu_address_enable not found"}
if {[catch {add wave -label ">>> Memory Address Control: ALU Enable Input <<<" -color Cyan /Processor_Top_TB/UUT/Memory/Mem_Addr_CU/alu_address_enable}]} {puts "  Warning: Mem_Addr_CU alu_address_enable not found"}
if {[catch {add wave -label "ALU Result (Input)" -radix hex /Processor_Top_TB/UUT/Memory/alu_result}]} {puts "  Warning: ALU Result not found"}
if {[catch {add wave -label ">>> ALU Address Enable (LDD/STD) <<<" -color Magenta /Processor_Top_TB/UUT/Memory/alu_address_enable}]} {puts "  Warning: ALU Address Enable not found"}
if {[catch {add wave -label "Memory Address" -radix hex /Processor_Top_TB/UUT/Memory/mem_address}]} {puts "  Warning: Memory Address not found"}
if {[catch {add wave -label ">>> Memory Address Mux Selector <<<" -radix binary -color Yellow /Processor_Top_TB/UUT/Memory/mem_addr_mux_sel}]} {puts "  Warning: Memory Address Mux Selector not found"}
if {[catch {add wave -label "Memory Address Mux - ALU Input" -radix hex /Processor_Top_TB/UUT/Memory/Mem_Addr_Mux/alu_address}]} {puts "  Warning: Mux ALU Input not found"}
if {[catch {add wave -label "Memory Address Mux - SP Input" -radix hex /Processor_Top_TB/UUT/Memory/Mem_Addr_Mux/sp_address}]} {puts "  Warning: Mux SP Input not found"}
if {[catch {add wave -label "Memory Address Mux - PC Input" -radix hex /Processor_Top_TB/UUT/Memory/Mem_Addr_Mux/pc_address}]} {puts "  Warning: Mux PC Input not found"}
if {[catch {add wave -label "Memory Write Data" -radix hex /Processor_Top_TB/UUT/Memory/mem_write_data}]} {puts "  Warning: Memory Write Data not found"}
if {[catch {add wave -label "Memory Data (Output)" -radix hex /Processor_Top_TB/UUT/Memory/mem_data_out}]} {puts "  Warning: Memory Data not found"}
if {[catch {add wave -label ">>> Memory Read Enable <<<" /Processor_Top_TB/UUT/Memory/actual_mem_read}]} {puts "  Warning: Memory Read not found"}
if {[catch {add wave -label ">>> Memory Write Enable <<<" /Processor_Top_TB/UUT/Memory/actual_mem_write}]} {puts "  Warning: Memory Write not found"}
if {[catch {add wave -label ">>> Stack Pointer (SP) <<<" -radix hex /Processor_Top_TB/UUT/Memory/sp_current}]} {puts "  Warning: Stack Pointer not found"}
if {[catch {add wave -label "SP Next" -radix hex /Processor_Top_TB/UUT/Memory/sp_next}]} {puts "  Warning: SP Next not found"}
if {[catch {add wave -label "SP Enable" /Processor_Top_TB/UUT/Memory/sp_enable}]} {puts "  Warning: SP Enable not found"}
if {[catch {add wave -label "SP Mux Sel" /Processor_Top_TB/UUT/Memory/sp_mux_sel}]} {puts "  Warning: SP Mux Sel not found"}
if {[catch {add wave -label "Is PUSH" /Processor_Top_TB/UUT/Memory/is_push}]} {puts "  Warning: Is PUSH not found"}
if {[catch {add wave -label "Is POP" /Processor_Top_TB/UUT/Memory/is_pop}]} {puts "  Warning: Is POP not found"}

# ========================================
# MEM/WB REGISTER
# ========================================
add wave -divider -height 25 "========== MEM/WB REGISTER =========="
puts "Adding MEM/WB signals..."
if {[catch {add wave -label "ALU Result" -radix hex /Processor_Top_TB/UUT/memwb_alu_result}]} {puts "  Warning: ALU Result not found"}
if {[catch {add wave -label "Memory Data" -radix hex /Processor_Top_TB/UUT/memwb_mem_data}]} {puts "  Warning: Memory Data not found"}
if {[catch {add wave -label "Write Reg" -radix unsigned /Processor_Top_TB/UUT/memwb_rdst}]} {puts "  Warning: Write Reg not found"}
if {[catch {add wave -label "Reg Write Enable" /Processor_Top_TB/UUT/memwb_reg_write}]} {puts "  Warning: Reg Write Enable not found"}
if {[catch {add wave -label "Mem to Reg" /Processor_Top_TB/UUT/memwb_mem_to_reg}]} {puts "  Warning: Mem to Reg not found"}

# ========================================
# WRITEBACK STAGE
# ========================================
add wave -divider -height 25 "========== WRITEBACK STAGE =========="
puts "Adding Writeback signals..."
if {[catch {add wave -label "Write Data (Mux Output)" -radix hex /Processor_Top_TB/UUT/wb_write_data}]} {puts "  Warning: Write Data not found"}
if {[catch {add wave -label "Write Register Address" -radix unsigned /Processor_Top_TB/UUT/wb_write_reg}]} {puts "  Warning: Write Register Address not found"}
if {[catch {add wave -label "Write Enable" /Processor_Top_TB/UUT/wb_write_enable}]} {puts "  Warning: Write Enable not found"}

# ========================================
# INPUT/OUTPUT PORTS
# ========================================
add wave -divider -height 30 "========== INPUT/OUTPUT PORTS =========="
puts "Adding I/O Port signals..."
if {[catch {add wave -label ">>> INPUT PORT (External) <<<" -radix hex /Processor_Top_TB/input_port}]} {puts "  Warning: input_port not found"}
if {[catch {add wave -label "Input Port -> Execute Stage" -radix hex /Processor_Top_TB/UUT/Execute/input_port}]} {puts "  Warning: input_port to Execute not found"}
if {[catch {add wave -label "Input Port Data (EX/MEM)" -radix hex /Processor_Top_TB/UUT/exmem_input_port_data}]} {puts "  Warning: exmem_input_port_data not found"}
if {[catch {add wave -label "Input Port Data (MEM)" -radix hex /Processor_Top_TB/UUT/Memory/input_port_data}]} {puts "  Warning: Memory input_port_data not found"}
if {[catch {add wave -label "Input Port Data (MEM/WB)" -radix hex /Processor_Top_TB/UUT/memwb_input_port_data}]} {puts "  Warning: memwb_input_port_data not found"}
if {[catch {add wave -label "Input Port Data (WB)" -radix hex /Processor_Top_TB/UUT/Writeback/Input_Port_Data}]} {puts "  Warning: WB Input_Port_Data not found"}
if {[catch {add wave -label "Is IN Instruction (MEM/WB)" /Processor_Top_TB/UUT/memwb_is_input}]} {puts "  Warning: memwb_is_input not found"}
if {[catch {add wave -label ">>> OUTPUT PORT (External) <<<" -radix hex /Processor_Top_TB/output_port}]} {puts "  Warning: output_port not found"}
if {[catch {add wave -label "Output Port Data (from WB)" -radix hex /Processor_Top_TB/UUT/wb_output_port_data}]} {puts "  Warning: wb_output_port_data not found"}
if {[catch {add wave -label "Is OUT Instruction (MEM/WB)" /Processor_Top_TB/UUT/memwb_out_enable}]} {puts "  Warning: memwb_out_enable not found"}



# ========================================
# RUN SIMULATION
# ========================================

puts "\n======================================"
puts "Running Simulation for 400ns"
puts "======================================"

# Run simulation
run 400ns

puts "\n======================================"
puts "Simulation Complete!"
puts "======================================"
puts "\nWaveforms showing key signals per stage:"
puts ""
puts "  FETCH:     PC, Instruction"
puts "  IF/ID:     PC+1, Instruction"  
puts "  DECODE:    Read Data 1 & 2"
puts "  REG FILE:  R0-R7 (all registers)"
puts "  ID/EX:     Read Data 1 & 2, Is Immediate"
puts "  EXECUTE:   ALU Inputs (A,B), Operation, Result, Flags"
puts "  CCR:       Selector, Mux Inputs/Output, Register I/O, Flags (Z,C,N)"
puts "  EX/MEM:    ALU Result, Write Reg, Control Signals"
puts "  MEMORY:    Address, Write Data, Read Data, Write/Read Enable, SP"
puts "  MEM/WB:    ALU Result, Memory Data, Write Reg, Control Signals"
puts "  WRITEBACK: Write Data, Write Address, Write Enable"
puts "  I/O PORTS: Input Port (through pipeline), Output Port, IN/OUT enables"
puts ""
puts "Use 'wave zoom full' to see entire simulation"
puts "Use 'do run_full_simulation.tcl' to re-run"
puts "======================================"

# Zoom to fit all signals
wave zoom full
