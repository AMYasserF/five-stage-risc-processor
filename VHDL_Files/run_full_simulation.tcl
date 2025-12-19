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
vcom -2008 Excute_Stage/CCR_Register.vhd
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

puts "\n=== Compiling Forwarding Unit ==="
vcom -2008 Forwarding_Unit.vhd

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
if {[catch {add wave -label "PC" -radix unsigned /Processor_Top_TB/UUT/Fetch/pc_out}]} {puts "  Warning: PC signal not found"}
if {[catch {add wave -label "Instruction" -radix hex /Processor_Top_TB/UUT/Fetch/instruction_fetch}]} {puts "  Warning: Instruction signal not found"}

# ========================================
# IF/ID REGISTER
# ========================================
add wave -divider -height 25 "========== IF/ID REGISTER =========="
puts "Adding IF/ID signals..."
if {[catch {add wave -label "PC+1" -radix unsigned /Processor_Top_TB/UUT/pc_plus_1_decode_signal}]} {puts "  Warning: PC+1 signal not found"}
if {[catch {add wave -label "Instruction" -radix hex /Processor_Top_TB/UUT/instruction_decode_signal}]} {puts "  Warning: Instruction signal not found"}

# ========================================
# DECODE STAGE
# ========================================
add wave -divider -height 25 "========== DECODE STAGE =========="
puts "Adding Decode signals..."
if {[catch {add wave -label "Read Data 1" -radix hex /Processor_Top_TB/UUT/read_data1_decode}]} {puts "  Warning: Read Data 1 not found"}
if {[catch {add wave -label "Read Data 2" -radix hex /Processor_Top_TB/UUT/read_data2_decode}]} {puts "  Warning: Read Data 2 not found"}

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
if {[catch {add wave -label "Read Data 1" -radix hex /Processor_Top_TB/UUT/idex_read_data1}]} {puts "  Warning: Read Data 1 not found"}
if {[catch {add wave -label "Read Data 2" -radix hex /Processor_Top_TB/UUT/idex_read_data2}]} {puts "  Warning: Read Data 2 not found"}
if {[catch {add wave -label "Is Immediate" /Processor_Top_TB/UUT/idex_is_immediate}]} {puts "  Warning: Is Immediate not found"}

# ========================================
# EXECUTE STAGE (ALU)
# ========================================
add wave -divider -height 25 "========== EXECUTE STAGE (ALU) =========="
puts "Adding Execute signals..."
if {[catch {add wave -label "ALU Operand A (Input)" -radix hex /Processor_Top_TB/UUT/Execute/alu_operand_a}]} {puts "  Warning: ALU Operand A not found"}
if {[catch {add wave -label "ALU Operand B (Input)" -radix hex /Processor_Top_TB/UUT/Execute/alu_operand_b}]} {puts "  Warning: ALU Operand B not found"}
if {[catch {add wave -label "ALU Operation" -radix hex /Processor_Top_TB/UUT/Execute/id_ex_alu_op}]} {puts "  Warning: ALU Operation not found"}
if {[catch {add wave -label "ALU Result (Output)" -radix hex /Processor_Top_TB/UUT/Execute/alu_result_internal}]} {puts "  Warning: ALU Result not found"}
if {[catch {add wave -label "Zero Flag" /Processor_Top_TB/UUT/Execute/alu_zero_flag}]} {puts "  Warning: Zero Flag not found"}
if {[catch {add wave -label "Carry Flag" /Processor_Top_TB/UUT/Execute/alu_carry_flag}]} {puts "  Warning: Carry Flag not found"}
if {[catch {add wave -label "Negative Flag" /Processor_Top_TB/UUT/Execute/alu_neg_flag}]} {puts "  Warning: Negative Flag not found"}

# ========================================
# EX/MEM REGISTER
# ========================================
add wave -divider -height 25 "========== EX/MEM REGISTER =========="
puts "Adding EX/MEM signals..."
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
if {[catch {add wave -label "ALU Result (Input)" -radix hex /Processor_Top_TB/UUT/Memory/alu_result}]} {puts "  Warning: ALU Result not found"}
if {[catch {add wave -label "Memory Data (Output)" -radix hex /Processor_Top_TB/UUT/Memory/mem_data_out}]} {puts "  Warning: Memory Data not found"}
if {[catch {add wave -label "Memory Read" /Processor_Top_TB/UUT/Memory/mem_read}]} {puts "  Warning: Memory Read not found"}
if {[catch {add wave -label "Memory Write" /Processor_Top_TB/UUT/Memory/mem_write}]} {puts "  Warning: Memory Write not found"}
if {[catch {add wave -label "Stack Pointer (SP)" -radix hex /Processor_Top_TB/UUT/Memory/sp_current}]} {puts "  Warning: Stack Pointer not found"}

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
puts "  EX/MEM:    ALU Result, Write Reg, Control Signals"
puts "  MEMORY:    Address, Write Data, Read Data, Write/Read Enable, SP"
puts "  MEM/WB:    ALU Result, Memory Data, Write Reg, Control Signals"
puts "  WRITEBACK: Write Data, Write Address, Write Enable"
puts ""
puts "Use 'wave zoom full' to see entire simulation"
puts "Use 'do run_full_simulation.tcl' to re-run"
puts "======================================"

# Zoom to fit all signals
wave zoom full
