# TCL script to compile and run the complete 5-stage processor testbench

# Set working directory
cd D:/CMP/Architecture/project/VHDL_Files

puts "======================================"
puts "Compiling Complete 5-Stage Processor"
puts "======================================"

# Create work library if it doesn't exist
vlib work 2>@1

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

puts "\n======================================"
puts "Starting Simulation"
puts "======================================"

# Start simulation with full signal access
vsim -voptargs=+acc Processor_Top_TB

puts "\nSimulation loaded with full signal visibility"
puts "All internal signals are now accessible"

# Configure wave window
configure wave -namecolwidth 300
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2

# ========================================
# CLOCK AND RESET
# ========================================
add wave -divider -height 25 "========== CLOCK & RESET =========="
add wave -label "Clock" -color yellow /Processor_Top_TB/clk
add wave -label "Reset" -color red /Processor_Top_TB/rst

# ========================================
# FETCH STAGE
# ========================================
add wave -divider -height 25 "========== FETCH STAGE =========="
add wave -label "PC" -radix hex /Processor_Top_TB/UUT/Fetch/pc_current
add wave -label "PC + 1" -radix hex /Processor_Top_TB/UUT/Fetch/pc_plus_1
add wave -label "PC Enable" /Processor_Top_TB/pc_enable
add wave -label "Instruction Fetched" -radix hex /Processor_Top_TB/UUT/instruction_fetch_signal
add wave -label "Mem Address (PC Out)" -radix hex /Processor_Top_TB/mem_address
add wave -label "Mem Read Data" -radix hex /Processor_Top_TB/mem_read_data

# ========================================
# IF/ID PIPELINE REGISTER
# ========================================
add wave -divider -height 25 "========== IF/ID REGISTER =========="
add wave -label "IFID Enable" /Processor_Top_TB/ifid_enable
add wave -label "IFID Flush" /Processor_Top_TB/ifid_flush
add wave -label "IFID Instruction Out" -radix hex /Processor_Top_TB/UUT/instruction_decode_signal
add wave -label "IFID PC+1 Out" -radix hex /Processor_Top_TB/UUT/pc_plus_1_decode_signal

# ========================================
# DECODE STAGE
# ========================================
add wave -divider -height 25 "========== DECODE STAGE =========="
add wave -label "Instruction" -radix hex /Processor_Top_TB/UUT/instruction_decode_signal
add wave -label "Opcode [31:25]" -radix hex /Processor_Top_TB/UUT/Decode/opcode
add wave -label "Rd (Write Reg)" -radix unsigned /Processor_Top_TB/UUT/rd_decode
add wave -label "Rs1 (Read Reg 1)" -radix unsigned /Processor_Top_TB/UUT/rs1_decode
add wave -label "Read Data 1" -radix hex /Processor_Top_TB/UUT/read_data1_decode
add wave -label "Read Data 2" -radix hex /Processor_Top_TB/UUT/read_data2_decode
add wave -label "Is Immediate" /Processor_Top_TB/UUT/is_immediate_decode
add wave -label "Reg Write Enable" /Processor_Top_TB/UUT/reg_write_decode
add wave -label "Mem Write" /Processor_Top_TB/UUT/mem_write_decode
add wave -label "Mem Read" /Processor_Top_TB/UUT/mem_read_decode
add wave -label "Mem to Reg" /Processor_Top_TB/UUT/mem_to_reg_decode
add wave -label "ALU Op" -radix hex /Processor_Top_TB/UUT/alu_op_decode

# Register File Contents
add wave -divider "Register File"
add wave -label "R0" -radix hex /Processor_Top_TB/UUT/Decode/Reg_File/registers(0)
add wave -label "R1" -radix hex /Processor_Top_TB/UUT/Decode/Reg_File/registers(1)
add wave -label "R2" -radix hex /Processor_Top_TB/UUT/Decode/Reg_File/registers(2)
add wave -label "R3" -radix hex /Processor_Top_TB/UUT/Decode/Reg_File/registers(3)
add wave -label "R4" -radix hex /Processor_Top_TB/UUT/Decode/Reg_File/registers(4)
add wave -label "R5" -radix hex /Processor_Top_TB/UUT/Decode/Reg_File/registers(5)
add wave -label "R6" -radix hex /Processor_Top_TB/UUT/Decode/Reg_File/registers(6)
add wave -label "R7" -radix hex /Processor_Top_TB/UUT/Decode/Reg_File/registers(7)

# ========================================
# ID/EX PIPELINE REGISTER
# ========================================
add wave -divider -height 25 "========== ID/EX REGISTER =========="
add wave -label "IDEX PC+1" -radix hex /Processor_Top_TB/UUT/idex_pc_plus_1
add wave -label "IDEX Read Data 1" -radix hex /Processor_Top_TB/UUT/idex_read_data1
add wave -label "IDEX Read Data 2" -radix hex /Processor_Top_TB/UUT/idex_read_data2
add wave -label "IDEX Write Reg" -radix unsigned /Processor_Top_TB/UUT/idex_write_reg
add wave -label "IDEX ALU Op" -radix hex /Processor_Top_TB/UUT/idex_alu_op
add wave -label "IDEX Reg Write" /Processor_Top_TB/UUT/idex_reg_write
add wave -label "IDEX Mem Write" /Processor_Top_TB/UUT/idex_mem_write
add wave -label "IDEX Mem Read" /Processor_Top_TB/UUT/idex_mem_read
add wave -label "IDEX Mem to Reg" /Processor_Top_TB/UUT/idex_mem_to_reg
add wave -label "IDEX Is Immediate" /Processor_Top_TB/UUT/idex_is_immediate

# ========================================
# EXECUTE STAGE (with Forwarding)
# ========================================
add wave -divider -height 25 "========== EXECUTE STAGE =========="
add wave -label "Forward A Control" -radix binary /Processor_Top_TB/UUT/forward_a
add wave -label "Forward B Control" -radix binary /Processor_Top_TB/UUT/forward_b
add wave -label "Forward EX/MEM Data" -radix hex /Processor_Top_TB/UUT/forward_ex_mem_data
add wave -label "Forward MEM/WB Data" -radix hex /Processor_Top_TB/UUT/forward_mem_wb_data
add wave -label "ALU Operand A" -radix hex /Processor_Top_TB/UUT/Execute/alu_operand_a
add wave -label "ALU Operand B" -radix hex /Processor_Top_TB/UUT/Execute/alu_operand_b
add wave -label "ALU Operation" -radix hex /Processor_Top_TB/UUT/Execute/alu_operation
add wave -label "ALU Result" -radix hex /Processor_Top_TB/UUT/Execute/alu_result_internal
add wave -label "ALU Zero Flag" /Processor_Top_TB/UUT/Execute/zero_flag
add wave -label "ALU Carry Flag" /Processor_Top_TB/UUT/Execute/carry_flag
add wave -label "ALU Negative Flag" /Processor_Top_TB/UUT/Execute/negative_flag
add wave -label "Conditional Jump" /Processor_Top_TB/conditional_jump

# ========================================
# EX/MEM PIPELINE REGISTER
# ========================================
add wave -divider -height 25 "========== EX/MEM REGISTER =========="
add wave -label "EXMEM ALU Result" -radix hex /Processor_Top_TB/UUT/exmem_alu_result
add wave -label "EXMEM Write Reg" -radix unsigned /Processor_Top_TB/UUT/exmem_write_reg
add wave -label "EXMEM Read Data 2" -radix hex /Processor_Top_TB/UUT/exmem_read_data2
add wave -label "EXMEM Reg Write" /Processor_Top_TB/UUT/exmem_reg_write
add wave -label "EXMEM Mem Write" /Processor_Top_TB/UUT/exmem_mem_write
add wave -label "EXMEM Mem Read" /Processor_Top_TB/UUT/exmem_mem_read
add wave -label "EXMEM Mem to Reg" /Processor_Top_TB/UUT/exmem_mem_to_reg
add wave -label "EXMEM PC+1" -radix hex /Processor_Top_TB/UUT/exmem_pc_plus_1

# ========================================
# MEMORY STAGE
# ========================================
add wave -divider -height 25 "========== MEMORY STAGE =========="
add wave -label "Mem Address" -radix hex /Processor_Top_TB/UUT/Memory/mem_address
add wave -label "Mem Write Data" -radix hex /Processor_Top_TB/UUT/Memory/mem_write_data
add wave -label "Mem Read Data" -radix hex /Processor_Top_TB/UUT/Memory/mem_read_data
add wave -label "Mem Write Enable" /Processor_Top_TB/UUT/Memory/actual_mem_write
add wave -label "Mem Read Enable" /Processor_Top_TB/UUT/Memory/actual_mem_read
add wave -label "Stack Pointer (SP)" -radix hex /Processor_Top_TB/UUT/Memory/sp_current
add wave -label "INT Load PC" /Processor_Top_TB/UUT/int_load_pc_internal
add wave -label "RTI Load PC" /Processor_Top_TB/UUT/rti_load_pc_internal

# ========================================
# MEM/WB PIPELINE REGISTER
# ========================================
add wave -divider -height 25 "========== MEM/WB REGISTER =========="
add wave -label "MEMWB ALU Result" -radix hex /Processor_Top_TB/UUT/memwb_alu_result
add wave -label "MEMWB Mem Data" -radix hex /Processor_Top_TB/UUT/memwb_mem_data
add wave -label "MEMWB Write Reg" -radix unsigned /Processor_Top_TB/UUT/memwb_rdst
add wave -label "MEMWB Reg Write" /Processor_Top_TB/UUT/memwb_reg_write
add wave -label "MEMWB Mem to Reg" /Processor_Top_TB/UUT/memwb_mem_to_reg
add wave -label "MEMWB Is Input" /Processor_Top_TB/UUT/memwb_is_input
add wave -label "MEMWB Is Swap" /Processor_Top_TB/UUT/memwb_is_swap

# ========================================
# WRITEBACK STAGE
# ========================================
add wave -divider -height 25 "========== WRITEBACK STAGE =========="
add wave -label "WB Write Enable" /Processor_Top_TB/wb_write_enable
add wave -label "WB Write Reg" -radix unsigned /Processor_Top_TB/wb_write_reg
add wave -label "WB Write Data" -radix hex /Processor_Top_TB/wb_write_data
add wave -label "WB Data Select" -radix binary /Processor_Top_TB/UUT/Writeback/WriteBackMuxSelect
add wave -label "Output Port" -radix hex /Processor_Top_TB/output_port

# ========================================
# CONTROL SIGNALS
# ========================================
add wave -divider -height 25 "========== CONTROL SIGNALS =========="
add wave -label "HLT" /Processor_Top_TB/UUT/idex_hlt
add wave -label "Is CALL" /Processor_Top_TB/UUT/exmem_is_call
add wave -label "Is RET" /Processor_Top_TB/UUT/exmem_is_ret
add wave -label "Is PUSH" /Processor_Top_TB/UUT/exmem_is_push
add wave -label "Is POP" /Processor_Top_TB/UUT/exmem_is_pop
add wave -label "Is INT" /Processor_Top_TB/UUT/exmem_is_int
add wave -label "Is RTI" /Processor_Top_TB/UUT/exmem_is_rti
add wave -label "Is SWAP" /Processor_Top_TB/UUT/exmem_is_swap

# ========================================
# I/O PORTS
# ========================================
add wave -divider -height 25 "========== I/O PORTS =========="
add wave -label "Input Port" -radix hex /Processor_Top_TB/input_port
add wave -label "Output Port" -radix hex /Processor_Top_TB/output_port

# Zoom full
wave zoom full

puts "\n======================================"
puts "Running Simulation for 400 ns"
puts "======================================"
run 400 ns

puts "\nSimulation complete!"
puts "Expected Results:"
puts "  - R2 should contain 0x00000005"
puts "  - R3 should contain 0x00000003"
puts "  - R1 should contain 0x00000008 (5 + 3)"
puts "\nCheck the waveform to verify!"
