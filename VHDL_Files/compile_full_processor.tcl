# TCL script to compile the complete 5-stage processor with all stages integrated

# Set working directory
cd "C:/Abdallah/CUFE/CMP/Third year/First Term/Computer Architecture/Project/five-stage-risc-processor - 2/VHDL_Files"

puts "======================================"
puts "Compiling Complete 5-Stage Processor"
puts "======================================"

# Create work library if it doesn't exist
vlib work

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

puts "\n======================================"
puts "Compilation Complete!"
puts "======================================"
puts ""
puts "To simulate, use:"
puts "  vsim Processor_Top"
puts "  # Add waves and run simulation"
