# ==============================================================================
# ModelSim DO file for Branch Test Case
# ==============================================================================
# This script:
# 1. Runs the assembler on Branch.asm
# 2. Loads the generated machine code into memory
# 3. Compiles all VHDL files
# 4. Starts simulation with waveforms
# ==============================================================================

puts "========================================"
puts "Branch Test Case Simulation"
puts "========================================"

# Set working directory
cd "D:/CMP/Architecture/project"

# Step 1: Run the assembler
puts "\n=== Running Assembler on Branch.asm ==="
exec python spec/assembler.py "Test Cases/Branch.asm" mem.txt

# Step 2: Compile VHDL files
puts "\n=== Compiling VHDL Files ==="
cd VHDL_Files

# Create work library if it doesn't exist
vlib work

# Compile Memory System
puts "\n=== Compiling Memory System ==="
vcom -2008 Memory_System/Memory.vhd

# Compile Fetch Stage Components
puts "\n=== Compiling Fetch Stage Components ==="
vcom -2008 Fetch_Stage/PC_Register.vhd
vcom -2008 Fetch_Stage/PC_Adder.vhd
vcom -2008 Fetch_Stage/PC_Mux.vhd
vcom -2008 Fetch_Stage/Fetch_Control_Units/PC_Mux_Control.vhd
vcom -2008 Fetch_Stage/Fetch_Stage.vhd
vcom -2008 Fetch_Stage/IF_ID_Register.vhd

# Compile Decode Stage Components
puts "\n=== Compiling Decode Stage Components ==="
vcom -2008 Decode_Stage/register_file.vhd
vcom -2008 Decode_Stage/control_unit.vhd
vcom -2008 Decode_Stage/decode_stage.vhd
vcom -2008 Decode_Stage/ID_EX_register.vhd

# Compile Execute Stage Components
puts "\n=== Compiling Execute Stage Components ==="
vcom -2008 Excute_Stage/ALU.vhd
vcom -2008 Excute_Stage/CCR_Register.vhd
vcom -2008 Excute_Stage/Execute_Stage.vhd
vcom -2008 Excute_Stage/EX_MEM_Register.vhd

# Compile Memory Stage Components
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

# Compile Writeback Stage
puts "\n=== Compiling Writeback Stage ==="
vcom -2008 Writeback_Stage/Write_Back.vhd

# Compile Forwarding Unit
puts "\n=== Compiling Forwarding Unit ==="
vcom -2008 Forwarding_Unit.vhd

# Compile Hazard Detection Unit (if exists)
if {[file exists "Hazard_Detection_Unit/Hazard_Detection_Unit.vhd"]} {
    puts "\n=== Compiling Hazard Detection Unit ==="
    vcom -2008 Hazard_Detection_Unit/Hazard_Detection_Unit.vhd
}

# Compile IO Ports (if exists)
if {[file exists "IO_Ports/Input_Port.vhd"]} {
    puts "\n=== Compiling IO Ports ==="
    vcom -2008 IO_Ports/Input_Port.vhd
}
if {[file exists "IO_Ports/Output_Port.vhd"]} {
    vcom -2008 IO_Ports/Output_Port.vhd
}

# Compile Top-Level Processor
puts "\n=== Compiling Top-Level Processor ==="
vcom -2008 Processor_Top.vhd

# Step 3: Start simulation
puts "\n=== Starting Simulation ==="
vsim -voptargs=+acc work.Processor_Top

# Step 4: Load memory with assembled code
puts "\n=== Loading Memory ==="
mem load -i ../mem.txt -format binary /Processor_Top/memory_inst/ram

# Step 5: Add waveforms
puts "\n=== Adding Waveforms ==="

# Add clock and reset
add wave -divider "Clock and Reset"
add wave -color Yellow /Processor_Top/clk
add wave -color Red /Processor_Top/rst

# Add PC and instruction
add wave -divider "Fetch Stage"
add wave -radix hexadecimal /Processor_Top/pc_out
add wave -radix hexadecimal /Processor_Top/instruction

# Add register file
add wave -divider "Register File"
add wave -radix hexadecimal -r /Processor_Top/decode_stage_inst/reg_file_inst/registers

# Add ALU signals
add wave -divider "Execute Stage - ALU"
add wave -radix hexadecimal /Processor_Top/execute_stage_inst/alu_inst/operand1
add wave -radix hexadecimal /Processor_Top/execute_stage_inst/alu_inst/operand2
add wave -radix hexadecimal /Processor_Top/execute_stage_inst/alu_inst/result
add wave /Processor_Top/execute_stage_inst/alu_inst/alu_op

# Add CCR flags
add wave -divider "CCR Flags"
add wave /Processor_Top/execute_stage_inst/ccr_inst/zero_flag
add wave /Processor_Top/execute_stage_inst/ccr_inst/negative_flag
add wave /Processor_Top/execute_stage_inst/ccr_inst/carry_flag

# Add Memory signals
add wave -divider "Memory Stage"
add wave -radix hexadecimal /Processor_Top/memory_stage_inst/mem_address
add wave -radix hexadecimal /Processor_Top/memory_stage_inst/mem_write_data
add wave /Processor_Top/memory_stage_inst/mem_read
add wave /Processor_Top/memory_stage_inst/mem_write
add wave -radix hexadecimal /Processor_Top/memory_stage_inst/mem_read_data

# Add Stack Pointer
add wave -divider "Stack Pointer"
add wave -radix hexadecimal /Processor_Top/memory_stage_inst/sp_out

# Add Control Signals
add wave -divider "Control Signals"
add wave /Processor_Top/decode_stage_inst/control_unit_inst/reg_write
add wave /Processor_Top/decode_stage_inst/control_unit_inst/mem_read
add wave /Processor_Top/decode_stage_inst/control_unit_inst/mem_write
add wave /Processor_Top/decode_stage_inst/control_unit_inst/branch
add wave /Processor_Top/decode_stage_inst/control_unit_inst/jump

# Add Forwarding signals (if exists)
if {[info exists /Processor_Top/forwarding_unit_inst]} {
    add wave -divider "Forwarding Unit"
    add wave /Processor_Top/forwarding_unit_inst/forward_a
    add wave /Processor_Top/forwarding_unit_inst/forward_b
}

# Add Hazard Detection signals (if exists)
if {[info exists /Processor_Top/hazard_detection_inst]} {
    add wave -divider "Hazard Detection"
    add wave /Processor_Top/hazard_detection_inst/stall
    add wave /Processor_Top/hazard_detection_inst/flush
}

# Add IO Ports (if exists)
if {[info exists /Processor_Top/input_port]} {
    add wave -divider "IO Ports"
    add wave -radix hexadecimal /Processor_Top/input_port
    add wave -radix hexadecimal /Processor_Top/output_port
}

# Configure wave window
configure wave -namecolwidth 250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2

# Step 6: Run simulation
puts "\n=== Running Simulation ==="
puts "Running for 2000 ns..."
run 2000 ns

# Zoom to fit
wave zoom full

puts "\n========================================"
puts "Branch Test Case Simulation Complete!"
puts "========================================"
puts "\nInstructions:"
puts "  - Use 'run <time>' to continue simulation"
puts "  - Use 'restart' to restart simulation"
puts "  - Examine waveforms in the Wave window"
puts "========================================"
