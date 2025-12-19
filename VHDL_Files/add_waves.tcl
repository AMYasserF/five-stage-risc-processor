# TCL script to add comprehensive waveforms to an already-running simulation
# Usage: In ModelSim, after loading the simulation, type: do add_waves.tcl

# Configure wave window
configure wave -namecolwidth 250
configure wave -valuecolwidth 120
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -timelineunits ns

# Clear existing waves
quietly wave cursor active
quietly wave refresh

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
add wave -label "PC (Instruction Address)" -radix hex /Processor_Top_TB/mem_address
add wave -label "Instruction from Memory" -radix hex /Processor_Top_TB/mem_read_data

# Try to add internal Fetch signals (may fail if not visible)
if {[catch {
    add wave -label "PC Internal" -radix hex /Processor_Top_TB/UUT/Fetch/pc_current
    add wave -label "PC + 1" -radix hex /Processor_Top_TB/UUT/Fetch/pc_plus_1
}]} {
    puts "Note: Some internal Fetch signals not accessible"
}

# ========================================
# IF/ID PIPELINE REGISTER
# ========================================
add wave -divider -height 25 "========== IF/ID REGISTER =========="
add wave -label "IFID Enable" /Processor_Top_TB/ifid_enable
add wave -label "IFID Flush" /Processor_Top_TB/ifid_flush

# Try to add internal IF/ID signals
if {[catch {
    add wave -label "IFID Instruction Out" -radix hex /Processor_Top_TB/UUT/instruction_decode_signal
    add wave -label "IFID PC+1 Out" -radix hex /Processor_Top_TB/UUT/pc_plus_1_decode_signal
}]} {
    puts "Note: Some internal IF/ID signals not accessible"
}

# ========================================
# DECODE STAGE & REGISTER FILE
# ========================================
add wave -divider -height 25 "========== DECODE STAGE =========="

# Try to add decode signals
if {[catch {
    add wave -label "Instruction Being Decoded" -radix hex /Processor_Top_TB/UUT/instruction_decode_signal
    add wave -label "Read Data 1" -radix hex /Processor_Top_TB/UUT/read_data1_decode
    add wave -label "Read Data 2" -radix hex /Processor_Top_TB/UUT/read_data2_decode
    add wave -label "Rd (Destination Reg)" -radix unsigned /Processor_Top_TB/UUT/rd_decode
    add wave -label "Rs1 (Source Reg 1)" -radix unsigned /Processor_Top_TB/UUT/rs1_decode
    add wave -label "Reg Write Enable" /Processor_Top_TB/UUT/reg_write_decode
    add wave -label "Mem Write" /Processor_Top_TB/UUT/mem_write_decode
    add wave -label "Mem Read" /Processor_Top_TB/UUT/mem_read_decode
    add wave -label "Mem to Reg" /Processor_Top_TB/UUT/mem_to_reg_decode
    add wave -label "Is Immediate" /Processor_Top_TB/UUT/is_immediate_decode
    add wave -label "ALU Op" -radix hex /Processor_Top_TB/UUT/alu_op_decode
}]} {
    puts "Note: Some Decode stage signals not accessible"
}

# Register File Contents
add wave -divider "--- Register File ---"
if {[catch {
    add wave -label "R0" -radix hex /Processor_Top_TB/UUT/Decode/Reg_File/registers(0)
    add wave -label "R1" -radix hex /Processor_Top_TB/UUT/Decode/Reg_File/registers(1)
    add wave -label "R2" -radix hex /Processor_Top_TB/UUT/Decode/Reg_File/registers(2)
    add wave -label "R3" -radix hex /Processor_Top_TB/UUT/Decode/Reg_File/registers(3)
    add wave -label "R4" -radix hex /Processor_Top_TB/UUT/Decode/Reg_File/registers(4)
    add wave -label "R5" -radix hex /Processor_Top_TB/UUT/Decode/Reg_File/registers(5)
    add wave -label "R6" -radix hex /Processor_Top_TB/UUT/Decode/Reg_File/registers(6)
    add wave -label "R7" -radix hex /Processor_Top_TB/UUT/Decode/Reg_File/registers(7)
}]} {
    puts "Warning: Register File not accessible - will show writeback data instead"
}

# ========================================
# ID/EX PIPELINE REGISTER
# ========================================
add wave -divider -height 25 "========== ID/EX REGISTER =========="

if {[catch {
    add wave -label "IDEX PC+1" -radix hex /Processor_Top_TB/UUT/idex_pc_plus_1
    add wave -label "IDEX Read Data 1" -radix hex /Processor_Top_TB/UUT/idex_read_data1
    add wave -label "IDEX Read Data 2" -radix hex /Processor_Top_TB/UUT/idex_read_data2
    add wave -label "IDEX Write Reg" -radix unsigned /Processor_Top_TB/UUT/idex_write_reg
    add wave -label "IDEX ALU Op" -radix hex /Processor_Top_TB/UUT/idex_alu_op
    add wave -label "IDEX Reg Write" /Processor_Top_TB/UUT/idex_reg_write
    add wave -label "IDEX Mem Write" /Processor_Top_TB/UUT/idex_mem_write
    add wave -label "IDEX Mem Read" /Processor_Top_TB/UUT/idex_mem_read
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
    add wave -label "ALU Result" -radix hex /Processor_Top_TB/UUT/Execute/alu_result_internal
    add wave -label "Zero Flag" /Processor_Top_TB/UUT/Execute/zero_flag
    add wave -label "Carry Flag" /Processor_Top_TB/UUT/Execute/carry_flag
    add wave -label "Negative Flag" /Processor_Top_TB/UUT/Execute/negative_flag
}]} {
    puts "Note: Some Execute signals not accessible - using outputs"
    # Use output signals instead
    add wave -label "ALU Result (output)" -radix hex /Processor_Top_TB/ex_mem_alu_result
}

add wave -label "Conditional Jump" /Processor_Top_TB/conditional_jump

# ========================================
# EX/MEM PIPELINE REGISTER (FROM OUTPUTS)
# ========================================
add wave -divider -height 25 "========== EX/MEM REGISTER =========="
add wave -label "ALU Result" -radix hex /Processor_Top_TB/ex_mem_alu_result
add wave -label "Write Reg" -radix unsigned /Processor_Top_TB/ex_mem_write_reg
add wave -label "Read Data 2" -radix hex /Processor_Top_TB/ex_mem_read_data2
add wave -label "Reg Write" /Processor_Top_TB/ex_mem_reg_write
add wave -label "Mem Write" /Processor_Top_TB/ex_mem_mem_write
add wave -label "Mem Read" /Processor_Top_TB/ex_mem_mem_read
add wave -label "Mem to Reg" /Processor_Top_TB/ex_mem_mem_to_reg
add wave -label "HLT" /Processor_Top_TB/ex_mem_hlt

# ========================================
# MEMORY STAGE
# ========================================
add wave -divider -height 25 "========== MEMORY STAGE =========="

if {[catch {
    add wave -label "Memory Address" -radix hex /Processor_Top_TB/UUT/Memory/mem_address
    add wave -label "Memory Write Data" -radix hex /Processor_Top_TB/UUT/Memory/mem_write_data
    add wave -label "Memory Read Data" -radix hex /Processor_Top_TB/UUT/Memory/mem_read_data
    add wave -label "Stack Pointer (SP)" -radix hex /Processor_Top_TB/UUT/Memory/sp_current
    add wave -label "Actual Mem Write" /Processor_Top_TB/UUT/Memory/actual_mem_write
    add wave -label "Actual Mem Read" /Processor_Top_TB/UUT/Memory/actual_mem_read
}]} {
    puts "Note: Internal Memory signals not accessible"
}

# ========================================
# MEM/WB PIPELINE REGISTER
# ========================================
add wave -divider -height 25 "========== MEM/WB REGISTER =========="

if {[catch {
    add wave -label "MEMWB ALU Result" -radix hex /Processor_Top_TB/UUT/memwb_alu_result
    add wave -label "MEMWB Mem Data" -radix hex /Processor_Top_TB/UUT/memwb_mem_data
    add wave -label "MEMWB Write Reg" -radix unsigned /Processor_Top_TB/UUT/memwb_rdst
    add wave -label "MEMWB Reg Write" /Processor_Top_TB/UUT/memwb_reg_write
    add wave -label "MEMWB Mem to Reg" /Processor_Top_TB/UUT/memwb_mem_to_reg
}]} {
    puts "Note: MEM/WB signals not accessible - using writeback outputs"
}

# ========================================
# WRITEBACK STAGE
# ========================================
add wave -divider -height 25 "========== WRITEBACK STAGE =========="
add wave -label "WB Write Enable" /Processor_Top_TB/wb_write_enable
add wave -label "WB Write Reg" -radix unsigned /Processor_Top_TB/wb_write_reg
add wave -label "WB Write Data" -radix hex /Processor_Top_TB/wb_write_data

if {[catch {
    add wave -label "WB Mux Select" -radix binary /Processor_Top_TB/UUT/Writeback/WriteBackMuxSelect
}]} {
    puts "Note: Writeback internal signals not accessible"
}

# ========================================
# CONTROL SIGNALS
# ========================================
add wave -divider -height 25 "========== CONTROL SIGNALS =========="
add wave -label "CALL" /Processor_Top_TB/ex_mem_is_call
add wave -label "RET" /Processor_Top_TB/ex_mem_is_ret
add wave -label "PUSH" /Processor_Top_TB/ex_mem_is_push
add wave -label "POP" /Processor_Top_TB/ex_mem_is_pop
add wave -label "INT" /Processor_Top_TB/ex_mem_is_int
add wave -label "RTI" /Processor_Top_TB/ex_mem_is_rti
add wave -label "SWAP" /Processor_Top_TB/ex_mem_is_swap
add wave -label "IN" /Processor_Top_TB/ex_mem_is_in
add wave -label "OUT" /Processor_Top_TB/ex_mem_out_enable

# ========================================
# I/O PORTS
# ========================================
add wave -divider -height 25 "========== I/O PORTS =========="
add wave -label "Input Port" -radix hex /Processor_Top_TB/input_port
add wave -label "Output Port" -radix hex /Processor_Top_TB/output_port

# Zoom to fit all signals
wave zoom full

puts "========================================"
puts "Waveforms added successfully!"
puts "========================================"
puts "Note: Some internal signals may not be visible"
puts "      if +acc compilation option was not used."
puts ""
puts "To see all internal signals, recompile with:"
puts "  vsim -voptargs=+acc Processor_Top_TB"
puts "========================================"
