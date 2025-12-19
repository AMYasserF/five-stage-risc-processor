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

if {[catch {
    add wave -label "PC" -radix unsigned /Processor_Top_TB/UUT/Fetch/pc_out
    add wave -label "PC + 1" -radix unsigned /Processor_Top_TB/UUT/Fetch/pc_plus_1
    add wave -label "Instruction" -radix hex /Processor_Top_TB/UUT/Fetch/instruction
    add wave -label "Mem Address" -radix unsigned /Processor_Top_TB/UUT/Fetch/mem_address
    add wave -label "Mem Data" -radix hex /Processor_Top_TB/UUT/Fetch/mem_data
}]} {
    puts "Note: Some Fetch stage signals not accessible"
}

# ========================================
# IF/ID REGISTER
# ========================================
add wave -divider -height 25 "========== IF/ID REGISTER =========="

if {[catch {
    add wave -label "IFID Enable" /Processor_Top_TB/UUT/if_id_enable
    add wave -label "IFID Flush" /Processor_Top_TB/UUT/if_id_flush
    add wave -label "IFID Instruction Out" -radix hex /Processor_Top_TB/UUT/if_id_instruction_out
    add wave -label "IFID PC+1 Out" -radix unsigned /Processor_Top_TB/UUT/if_id_pc_plus_1_out
}]} {
    puts "Note: Some IF/ID signals not accessible"
}

# ========================================
# DECODE STAGE
# ========================================
add wave -divider -height 25 "========== DECODE STAGE =========="

if {[catch {
    add wave -label "Instruction" -radix hex /Processor_Top_TB/UUT/Decode/instruction
    add wave -label "Opcode" -radix hex /Processor_Top_TB/UUT/Decode/opcode
    add wave -label "Rd (Dest)" -radix unsigned /Processor_Top_TB/UUT/Decode/r_dst
    add wave -label "Rs1 (Src1)" -radix unsigned /Processor_Top_TB/UUT/Decode/r_src1
    add wave -label "Rs2 (Src2)" -radix unsigned /Processor_Top_TB/UUT/Decode/r_src2
    add wave -label "Read Data 1" -radix hex /Processor_Top_TB/UUT/Decode/read_data_1
    add wave -label "Read Data 2" -radix hex /Processor_Top_TB/UUT/Decode/read_data_2
    add wave -label "Control ALU Op" -radix hex /Processor_Top_TB/UUT/Decode/control_alu_op
    add wave -label "Reg Write Enable" /Processor_Top_TB/UUT/Decode/control_reg_write
    add wave -label "Mem Write" /Processor_Top_TB/UUT/Decode/control_mem_write
    add wave -label "Mem Read" /Processor_Top_TB/UUT/Decode/control_mem_read
}]} {
    puts "Note: Some Decode stage signals not accessible"
}

# ========================================
# REGISTER FILE (R0-R7)
# ========================================
add wave -divider -height 25 "========== REGISTER FILE =========="

if {[catch {
    add wave -label "R0" -radix hex /Processor_Top_TB/UUT/Decode/reg_file_inst/registers(0)
    add wave -label "R1" -radix hex /Processor_Top_TB/UUT/Decode/reg_file_inst/registers(1)
    add wave -label "R2" -radix hex /Processor_Top_TB/UUT/Decode/reg_file_inst/registers(2)
    add wave -label "R3" -radix hex /Processor_Top_TB/UUT/Decode/reg_file_inst/registers(3)
    add wave -label "R4" -radix hex /Processor_Top_TB/UUT/Decode/reg_file_inst/registers(4)
    add wave -label "R5" -radix hex /Processor_Top_TB/UUT/Decode/reg_file_inst/registers(5)
    add wave -label "R6" -radix hex /Processor_Top_TB/UUT/Decode/reg_file_inst/registers(6)
    add wave -label "R7" -radix hex /Processor_Top_TB/UUT/Decode/reg_file_inst/registers(7)
}]} {
    puts "Note: Register file not accessible"
}

# ========================================
# ID/EX REGISTER
# ========================================
add wave -divider -height 25 "========== ID/EX REGISTER =========="

if {[catch {
    add wave -label "IDEX PC+1" -radix unsigned /Processor_Top_TB/UUT/idex_pc_plus_1
    add wave -label "IDEX Read Data 1" -radix hex /Processor_Top_TB/UUT/idex_read_data1
    add wave -label "IDEX Read Data 2" -radix hex /Processor_Top_TB/UUT/idex_read_data2
    add wave -label "IDEX Write Reg" -radix unsigned /Processor_Top_TB/UUT/idex_write_reg
    add wave -label "IDEX ALU Op" -radix hex /Processor_Top_TB/UUT/idex_alu_op
    add wave -label "IDEX Reg Write" /Processor_Top_TB/UUT/idex_reg_write
    add wave -label "IDEX Mem Write" /Processor_Top_TB/UUT/idex_mem_write
    add wave -label "IDEX Mem Read" /Processor_Top_TB/UUT/idex_mem_read
    add wave -label "IDEX Mem to Reg" /Processor_Top_TB/UUT/idex_mem_to_reg
    add wave -label "IDEX Is Immediate" /Processor_Top_TB/UUT/idex_is_immediate
}]} {
    puts "Note: Some ID/EX signals not accessible"
}

# ========================================
# EXECUTE STAGE (with Forwarding)
# ========================================
add wave -divider -height 25 "========== EXECUTE STAGE =========="

if {[catch {
    add wave -label "Forward A Control" -radix binary /Processor_Top_TB/UUT/forward_a
    add wave -label "Forward B Control" -radix binary /Processor_Top_TB/UUT/forward_b
    add wave -label "Forward EX/MEM Data" -radix hex /Processor_Top_TB/UUT/forward_ex_mem_data
    add wave -label "Forward MEM/WB Data" -radix hex /Processor_Top_TB/UUT/forward_mem_wb_data
    add wave -label "ALU Operand A" -radix hex /Processor_Top_TB/UUT/Execute/alu_operand_a
    add wave -label "ALU Operand B" -radix hex /Processor_Top_TB/UUT/Execute/alu_operand_b
    add wave -label "ALU Operation" -radix hex /Processor_Top_TB/UUT/Execute/alu_operation
    add wave -label "ALU Result" -radix hex /Processor_Top_TB/UUT/Execute/alu_result_internal
    add wave -label "Zero Flag" /Processor_Top_TB/UUT/Execute/zero_flag
    add wave -label "Carry Flag" /Processor_Top_TB/UUT/Execute/carry_flag
    add wave -label "Negative Flag" /Processor_Top_TB/UUT/Execute/negative_flag
    add wave -label "Conditional Jump" /Processor_Top_TB/UUT/Execute/conditional_jump
}]} {
    puts "Note: Some Execute stage or Forwarding signals not accessible"
}

# ========================================
# EX/MEM REGISTER
# ========================================
add wave -divider -height 25 "========== EX/MEM REGISTER =========="

if {[catch {
    add wave -label "EXMEM ALU Result" -radix hex /Processor_Top_TB/UUT/exmem_alu_result
    add wave -label "EXMEM Write Reg" -radix unsigned /Processor_Top_TB/UUT/exmem_write_reg
    add wave -label "EXMEM Read Data 2" -radix hex /Processor_Top_TB/UUT/exmem_read_data2
    add wave -label "EXMEM Reg Write" /Processor_Top_TB/UUT/exmem_reg_write
    add wave -label "EXMEM Mem Write" /Processor_Top_TB/UUT/exmem_mem_write
    add wave -label "EXMEM Mem Read" /Processor_Top_TB/UUT/exmem_mem_read
    add wave -label "EXMEM Mem to Reg" /Processor_Top_TB/UUT/exmem_mem_to_reg
    add wave -label "EXMEM PC+1" -radix unsigned /Processor_Top_TB/UUT/exmem_pc_plus_1
}]} {
    puts "Note: Some EX/MEM signals not accessible"
}

# ========================================
# MEMORY STAGE
# ========================================
add wave -divider -height 25 "========== MEMORY STAGE =========="

if {[catch {
    add wave -label "Memory Address" -radix hex /Processor_Top_TB/UUT/Memory/memory_address
    add wave -label "Memory Write Data" -radix hex /Processor_Top_TB/UUT/Memory/memory_write_data
    add wave -label "Memory Read Data" -radix hex /Processor_Top_TB/UUT/Memory/memory_read_data
    add wave -label "Memory Write Enable" /Processor_Top_TB/UUT/Memory/memory_write_enable
    add wave -label "Memory Read Enable" /Processor_Top_TB/UUT/Memory/memory_read_enable
    add wave -label "Stack Pointer (SP)" -radix hex /Processor_Top_TB/UUT/Memory/sp_out
    add wave -label "INT PC Control" /Processor_Top_TB/UUT/Memory/int_pc_control
    add wave -label "RTI PC Control" /Processor_Top_TB/UUT/Memory/rti_pc_control
}]} {
    puts "Note: Some Memory stage signals not accessible"
}

# ========================================
# MEM/WB REGISTER
# ========================================
add wave -divider -height 25 "========== MEM/WB REGISTER =========="

if {[catch {
    add wave -label "MEMWB ALU Result" -radix hex /Processor_Top_TB/UUT/memwb_alu_result
    add wave -label "MEMWB Mem Data" -radix hex /Processor_Top_TB/UUT/memwb_mem_data
    add wave -label "MEMWB Write Reg" -radix unsigned /Processor_Top_TB/UUT/memwb_rdst
    add wave -label "MEMWB Reg Write" /Processor_Top_TB/UUT/memwb_reg_write
    add wave -label "MEMWB Mem to Reg" /Processor_Top_TB/UUT/memwb_mem_to_reg
}]} {
    puts "Note: Some MEM/WB signals not accessible"
}

# ========================================
# WRITEBACK STAGE
# ========================================
add wave -divider -height 25 "========== WRITEBACK STAGE =========="

if {[catch {
    add wave -label "WB Write Enable" /Processor_Top_TB/UUT/wb_write_enable
    add wave -label "WB Write Reg" -radix unsigned /Processor_Top_TB/UUT/wb_write_reg
    add wave -label "WB Write Data" -radix hex /Processor_Top_TB/UUT/wb_write_data
    add wave -label "WB Mux Select" /Processor_Top_TB/UUT/Writeback/mux_select
    add wave -label "Output Port" -radix hex /Processor_Top_TB/UUT/output_port
}]} {
    puts "Note: Some Writeback stage signals not accessible"
}

# ========================================
# CONTROL SIGNALS
# ========================================
add wave -divider -height 25 "========== CONTROL SIGNALS =========="

if {[catch {
    add wave -label "CALL" /Processor_Top_TB/UUT/exmem_is_call
    add wave -label "RET" /Processor_Top_TB/UUT/exmem_is_ret
    add wave -label "PUSH" /Processor_Top_TB/UUT/exmem_is_push
    add wave -label "POP" /Processor_Top_TB/UUT/exmem_is_pop
    add wave -label "INT" /Processor_Top_TB/UUT/exmem_is_int
    add wave -label "RTI" /Processor_Top_TB/UUT/exmem_is_rti
    add wave -label "SWAP" /Processor_Top_TB/UUT/exmem_is_swap
    add wave -label "IN" /Processor_Top_TB/UUT/exmem_is_in
    add wave -label "OUT Enable" /Processor_Top_TB/UUT/exmem_out_enable
}]} {
    puts "Note: Some control signals not accessible"
}

# ========================================
# I/O PORTS
# ========================================
add wave -divider -height 25 "========== I/O PORTS =========="
add wave -label "Input Port" -radix hex /Processor_Top_TB/input_port
add wave -label "Output Port" -radix hex /Processor_Top_TB/output_port

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
puts "\nWaveforms are organized by pipeline stages:"
puts "  - Clock & Reset"
puts "  - Fetch Stage"
puts "  - IF/ID Register"
puts "  - Decode Stage"
puts "  - Register File (R0-R7)"
puts "  - ID/EX Register"
puts "  - Execute Stage (with Forwarding signals)"
puts "  - EX/MEM Register"
puts "  - Memory Stage"
puts "  - MEM/WB Register"
puts "  - Writeback Stage"
puts "  - Control Signals"
puts "  - I/O Ports"
puts "\nForwarding Control Encoding:"
puts "  0000 = No forwarding"
puts "  0001 = Forward EX/MEM ALU result"
puts "  0010 = Forward EX/MEM Rsrc2 (SWAP)"
puts "  0101 = Forward MEM/WB memory data"
puts "  1001 = Forward MEM/WB ALU result"
puts "\nUse 'wave zoom full' to see entire simulation"
puts "Use 'do run_full_simulation.tcl' to re-run"
puts "======================================"

# Zoom to fit all signals
wave zoom full
