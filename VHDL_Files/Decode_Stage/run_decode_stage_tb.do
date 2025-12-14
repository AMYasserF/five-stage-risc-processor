# ModelSim Compilation and Simulation Script for Decode Stage
# Run this script in ModelSim with: do run_decode_stage_tb.do

# Create work library if it doesn't exist
vlib work

# Compile all required files in dependency order
echo "Compiling Register File..."
vcom -2008 register_file.vhd

echo "Compiling Control Unit..."
vcom -2008 control_unit.vhd

echo "Compiling Decode Stage..."
vcom -2008 decode_stage.vhd

echo "Compiling Testbench..."
vcom -2008 decode_stage_tb.vhd

# Start simulation
echo "Starting simulation..."
vsim -voptargs=+acc work.decode_stage_tb

# Add waves to waveform viewer
echo "Adding signals to waveform..."

# Clock and Reset
add wave -divider "Clock and Reset"
add wave -color Yellow sim:/decode_stage_tb/clk
add wave -color Red sim:/decode_stage_tb/rst

# Instruction and PC
add wave -divider "Instruction Inputs"
add wave -radix hexadecimal sim:/decode_stage_tb/instruction
add wave -radix hexadecimal sim:/decode_stage_tb/pc_in
add wave -radix hexadecimal sim:/decode_stage_tb/pc_out
add wave sim:/decode_stage_tb/previous_is_immediate

# Decoded Instruction Fields
add wave -divider "Decoded Fields"
add wave -radix binary sim:/decode_stage_tb/opcode
add wave -radix unsigned sim:/decode_stage_tb/rd
add wave -radix unsigned sim:/decode_stage_tb/rs1
add wave -radix unsigned sim:/decode_stage_tb/rs2

# Register File Signals
add wave -divider "Register File"
add wave sim:/decode_stage_tb/wb_write_enable
add wave -radix unsigned sim:/decode_stage_tb/wb_write_reg
add wave -radix hexadecimal sim:/decode_stage_tb/wb_write_data
add wave -radix hexadecimal sim:/decode_stage_tb/read_data1
add wave -radix hexadecimal sim:/decode_stage_tb/read_data2

# Control Signals - Memory
add wave -divider "Memory Control"
add wave sim:/decode_stage_tb/mem_write
add wave sim:/decode_stage_tb/mem_read
add wave sim:/decode_stage_tb/mem_to_reg

# Control Signals - ALU
add wave -divider "ALU Control"
add wave -radix binary sim:/decode_stage_tb/alu_op
add wave -radix binary sim:/decode_stage_tb/ccr_in
add wave sim:/decode_stage_tb/reg_write

# Control Signals - Special Operations
add wave -divider "Special Operations"
add wave sim:/decode_stage_tb/is_immediate
add wave sim:/decode_stage_tb/is_swap
add wave sim:/decode_stage_tb/is_call
add wave sim:/decode_stage_tb/is_ret
add wave sim:/decode_stage_tb/is_push
add wave sim:/decode_stage_tb/is_pop
add wave sim:/decode_stage_tb/is_int
add wave sim:/decode_stage_tb/is_rti
add wave sim:/decode_stage_tb/is_in
add wave sim:/decode_stage_tb/out_enable
add wave sim:/decode_stage_tb/hlt

# Control Signals - Branch
add wave -divider "Branch Control"
add wave sim:/decode_stage_tb/branchZ
add wave sim:/decode_stage_tb/branchC
add wave sim:/decode_stage_tb/branchN
add wave sim:/decode_stage_tb/unconditional_branch

# Internal Register File State
add wave -divider "Register File Contents"
add wave -radix hexadecimal sim:/decode_stage_tb/uut/reg_file/registers

# Configure wave window
configure wave -namecolwidth 250
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2

# Run simulation
echo "Running simulation for 500ns..."
run 500ns

# Zoom to fit
wave zoom full

echo "Simulation complete! Check waveform for results."
echo "All assertion messages are shown in the transcript window."
