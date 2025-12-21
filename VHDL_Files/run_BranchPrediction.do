#!/usr/bin/tclsh
# Test Branch Instructions
# This script runs the Branch test program from spec/BranchPrediction.txt

puts "======================================"
puts "Testing Branch Instructions"
puts "======================================"

# Configuration - the program file to load
if {![info exists program_file]} {
    set program_file "../spec/BranchPrediction.txt"
}
puts "Program file: $program_file"
puts ""

# Ensure current working directory contains the source folders so vcom can find files
if {[file exists "Fetch_Stage/PC_Register.vhd"]} {
    # already in correct directory
} elseif {[file exists "VHDL_Files/Fetch_Stage/PC_Register.vhd"]} {
    cd VHDL_Files
} elseif {[file exists "../VHDL_Files/Fetch_Stage/PC_Register.vhd"]} {
    cd ../VHDL_Files
} elseif {[file exists "../Fetch_Stage/PC_Register.vhd"]} {
    cd ..
} else {
    puts "WARNING: could not find Fetch_Stage/PC_Register.vhd in common locations; vcom may fail"
}

# Setup work library
puts "Compiling..."
vlib work
catch {vmap work work}

# Compile VHDL files (using relative paths - run from VHDL_Files directory)
vcom -2008 -explicit \
    Fetch_Stage/PC_Register.vhd \
    Fetch_Stage/PC_Adder.vhd \
    Fetch_Stage/PC_Mux.vhd \
    Fetch_Stage/Fetch_Control_Units/PC_Mux_Control.vhd \
    Fetch_Stage/IF_ID_Register.vhd \
    Fetch_Stage/Fetch_Stage.vhd \
    Decode_Stage/register_file.vhd \
    Decode_Stage/control_unit.vhd \
    Decode_Stage/decode_stage.vhd \
    Decode_Stage/ID_EX_register.vhd \
    Excute_Stage/ALU.vhd \
    Excute_Stage/ALU_OperandA_Mux.vhd \
    Excute_Stage/ALU_OperandB_Mux.vhd \
    Excute_Stage/Branch_Logic.vhd \
    Excute_Stage/CCR_Register.vhd \
    Excute_Stage/CCR_Branch_Unit.vhd \
    Excute_Stage/CCR_Mux.vhd \
    Excute_Stage/Execute_Stage.vhd \
    Excute_Stage/EX_MEM_Register.vhd \
    Memory_System/Memory.vhd \
    Memory_System/Unified_Memory.vhd \
    Memory_System/SP_Components/SP_Register.vhd \
    Memory_System/SP_Components/SP_Adder.vhd \
    Memory_System/SP_Components/SP_Mux.vhd \
    Memory_System/SP_Components/SP_Control_Unit.vhd \
    Memory_System/Memory_Address_Components/ALU_Plus_2_Adder.vhd \
    Memory_System/Memory_Address_Components/Memory_Address_Mux.vhd \
    Memory_System/Memory_Address_Components/Memory_Address_Control_Unit.vhd \
    Memory_System/Memory_Write_Data_Components/Memory_Write_Data_Mux.vhd \
    Memory_System/Memory_Write_Data_Components/Memory_Write_Data_Control_Unit.vhd \
    Memory_System/Control_Units/INT_Control_Unit.vhd \
    Memory_System/Control_Units/RTI_Control_Unit.vhd \
    Memory_Stage/Memory_Stage.vhd \
    Memory_Stage/Mem_Wb_Register.vhd \
    Writeback_Stage/Write_Back.vhd \
    IO_Ports/Input_Port_Register.vhd \
    IO_Ports/Output_Port_Register.vhd \
    Forwarding_Unit.vhd \
    Hazard_Detection_Unit/Hazard_Detection_Unit.vhd \
    Two_Bits_Dynamic_Branch_Prediction/Two_Bits_Dynamic_Branch_Prediction.vhd \
    Two_Bits_Dynamic_Branch_Prediction/Not_Taken_After_Taken_Mux.vhd \
    Processor_Top.vhd \
    Processor_Top_TB.vhd

# Start simulation (pass program file via generic)
puts "Starting simulation..."
vsim -t 1ps -gPROGRAM_FILE=$program_file work.Processor_Top_TB

# Waveforms - organized by pipeline stages
add wave -divider -height 30 "========== SYSTEM =========="
add wave -label "Clock" -color Yellow /Processor_Top_TB/clk
add wave -label "Reset" -color Red /Processor_Top_TB/rst

add wave -divider -height 25 "========== FETCH STAGE =========="
add wave -label "PC Address" -hex /Processor_Top_TB/UUT/fetch_address_signal
add wave -label "Instruction" -hex /Processor_Top_TB/UUT/fetch_data_signal

add wave -divider -height 25 "========== DECODE STAGE =========="
add wave -label "Reg Read 1" -hex /Processor_Top_TB/UUT/Decode/read_data1
add wave -label "Reg Read 2" -hex /Processor_Top_TB/UUT/Decode/read_data2

add wave -divider -height 25 "========== REGISTER FILE =========="
add wave -label "Registers" -hex /Processor_Top_TB/UUT/Decode/reg_file/registers

add wave -divider -height 25 "========== EXECUTE STAGE =========="
add wave -label "ALU Result" -hex /Processor_Top_TB/UUT/ex_mem_alu_result
add wave -label "CCR Flags" -binary /Processor_Top_TB/UUT/Execute/ccr_register_out

add wave -divider -height 25 "========== MEMORY STAGE =========="
add wave -label "Mem Address" -hex /Processor_Top_TB/UUT/unified_mem_address
add wave -label "Mem Write Data" -hex /Processor_Top_TB/UUT/unified_mem_write_data
add wave -label "Mem Write En" /Processor_Top_TB/UUT/unified_mem_write

add wave -divider -height 25 "========== WRITEBACK STAGE =========="
add wave -label "WB Data" -hex /Processor_Top_TB/UUT/wb_write_data
add wave -label "WB Reg Index" -unsigned /Processor_Top_TB/UUT/wb_write_reg
add wave -label "WB Enable" /Processor_Top_TB/UUT/wb_write_enable

# Run simulation
run 5000ns
wave zoom full
puts "Simulation of $program_file finished."