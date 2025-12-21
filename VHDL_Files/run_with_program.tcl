#!/usr/bin/tclsh
# Example: Modified TCL script for loading different programs
# This shows how to update your simulation scripts to use generic program files

# Usage: 
#   tclsh run_with_program.tcl
#   tclsh run_with_program.tcl test_swap.txt
#   tclsh run_with_program.tcl ../programs/my_test.txt

# ============================================
# Configuration
# ============================================

# Get program file from command line or use default
set program_file "program.txt"
if {[llength $argv] > 0} {
    set program_file [lindex $argv 0]
}

puts "======================================"
puts "RISC Processor Test with File Loading"
puts "======================================"
puts "Program file: $program_file"
puts "======================================"

# ============================================
# Compilation
# ============================================

puts "\n[info level 0]: Compiling design..."

# Standard compilation (as before)
vlib work
vmap work work

# Compile VHDL files with file I/O support
vcom -2008 -explicit \
    ../VHDL_Files/Fetch_Stage/PC_Register.vhd \
    ../VHDL_Files/Fetch_Stage/PC_Adder.vhd \
    ../VHDL_Files/Fetch_Stage/PC_Mux.vhd \
    ../VHDL_Files/Fetch_Stage/Fetch_Control_Units/PC_Mux_Control.vhd \
    ../VHDL_Files/Fetch_Stage/IF_ID_Register.vhd \
    ../VHDL_Files/Fetch_Stage/Fetch_Stage.vhd \
    \
    ../VHDL_Files/Decode_Stage/register_file.vhd \
    ../VHDL_Files/Decode_Stage/control_unit.vhd \
    ../VHDL_Files/Decode_Stage/ID_EX_register.vhd \
    ../VHDL_Files/Decode_Stage/decode_stage.vhd \
    \
    ../VHDL_Files/Excute_Stage/ALU.vhd \
    ../VHDL_Files/Excute_Stage/ALU_OperandA_Mux.vhd \
    ../VHDL_Files/Excute_Stage/ALU_OperandB_Mux.vhd \
    ../VHDL_Files/Excute_Stage/CCR_Register.vhd \
    ../VHDL_Files/Excute_Stage/CCR_Mux.vhd \
    ../VHDL_Files/Excute_Stage/CCR_Branch_Unit.vhd \
    ../VHDL_Files/Excute_Stage/Branch_Logic.vhd \
    ../VHDL_Files/Excute_Stage/EX_MEM_Register.vhd \
    ../VHDL_Files/Excute_Stage/Execute_Stage.vhd \
    \
    ../VHDL_Files/Memory_System/Memory.vhd \
    ../VHDL_Files/Memory_System/Unified_Memory.vhd \
    ../VHDL_Files/Memory_Stage/Mem_Wb_Register.vhd \
    ../VHDL_Files/Memory_Stage/Memory_Stage.vhd \
    \
    ../VHDL_Files/Writeback_Stage/Write_Back.vhd \
    \
    ../VHDL_Files/Hazard_Detection_Unit/Hazard_Detection_Unit.vhd \
    ../VHDL_Files/Forwarding_Unit.vhd \
    ../VHDL_Files/Two_Bits_Dynamic_Branch_Prediction/Two_Bits_Dynamic_Branch_Prediction.vhd \
    ../VHDL_Files/Two_Bits_Dynamic_Branch_Prediction/Not_Taken_After_Taken_Mux.vhd \
    ../VHDL_Files/IO_Ports/Input_Port_Register.vhd \
    ../VHDL_Files/IO_Ports/Output_Port_Register.vhd \
    ../VHDL_Files/Processor_Top.vhd \
    ../VHDL_Files/Processor_Top_TB.vhd

puts "Compilation complete."

# ============================================
# Simulation Setup
# ============================================

puts "\n[info level 0]: Setting up simulation..."

# Start simulation
vsim -t 1ps \
    -g PROGRAM_FILE=$program_file \
    Processor_Top_TB

puts "Simulation started with program: $program_file"

# ============================================
# Waveform Configuration
# ============================================

# Add waves for debugging
add wave -noupdate -group {Processor Top} \
    /Processor_Top_TB/clk \
    /Processor_Top_TB/rst \
    /Processor_Top_TB/interrupt

add wave -noupdate -group {Fetch Stage} \
    /Processor_Top_TB/Processor/fetch_address_signal \
    /Processor_Top_TB/Processor/instruction_fetch_signal \
    /Processor_Top_TB/Processor/pc_plus_1_fetch_signal

add wave -noupdate -group {Decode Stage} \
    /Processor_Top_TB/Processor/instruction_decode_signal \
    /Processor_Top_TB/Processor/read_data1_decode \
    /Processor_Top_TB/Processor/read_data2_decode

add wave -noupdate -group {Execute Stage} \
    /Processor_Top_TB/Processor/idex_alu_op \
    /Processor_Top_TB/Processor/exmem_alu_result \
    /Processor_Top_TB/Processor/conditional_jump_from_execute

add wave -noupdate -group {Memory Stage} \
    /Processor_Top_TB/Processor/mem_stage_address_signal \
    /Processor_Top_TB/Processor/mem_stage_write_data_signal \
    /Processor_Top_TB/Processor/mem_stage_data_signal

add wave -noupdate -group {Register File} \
    /Processor_Top_TB/Processor/Decode/reg_file/registers\[0\] \
    /Processor_Top_TB/Processor/Decode/reg_file/registers\[1\] \
    /Processor_Top_TB/Processor/Decode/reg_file/registers\[2\] \
    /Processor_Top_TB/Processor/Decode/reg_file/registers\[3\]

add wave -noupdate -group {Output Ports} \
    /Processor_Top_TB/output_port \
    /Processor_Top_TB/wb_write_data

puts "Waveforms configured."

# ============================================
# Execution
# ============================================

puts "\n[info level 0]: Running simulation..."
puts "Duration: 2000 ns (adjust as needed)"

# Run for specified time
run 2000ns

puts "\n[info level 0]: Simulation complete."
puts "======================================"
puts "Program '$program_file' execution finished"
puts "Check waveforms in wave viewer"
puts "======================================"

# ============================================
# Optional: Print Memory Contents
# ============================================

# Uncomment to dump memory to console
# puts "\nMemory contents (first 16 locations):"
# for {set i 0} {$i < 16} {incr i} {
#     set addr [format "0x%04x" $i]
#     set value [examine -radix hex /Processor_Top_TB/Processor/Unified_Mem/memory\[$i\]]
#     puts "  Memory\[$addr\] = $value"
# }

# Keep the waveform viewer open (for interactive use)
# quit  ; Uncomment to exit automatically

