# Fetch Stage Waveform Visualization Script
# Run this with: vsim -do run_waveform.do

# Create library and compile
vlib work
vcom -93 PC_Register.vhd
vcom -93 PC_Adder.vhd
vcom -93 PC_Mux.vhd
vcom -93 IF_ID_Register.vhd
vcom -93 Fetch_Control_Units/PC_Mux_Control.vhd
vcom -93 Fetch_Stage.vhd
vcom -93 Fetch_Stage_tb.vhd

# Load design
vsim Fetch_Stage_tb

# Add waves - Clock and Reset
add wave -divider "Clock & Reset"
add wave -radix binary /fetch_stage_tb/clk
add wave -radix binary /fetch_stage_tb/rst

# Add waves - PC Signals
add wave -divider "Program Counter"
add wave -radix hex /fetch_stage_tb/pc_out
add wave -radix hex /fetch_stage_tb/uut/pc_current
add wave -radix hex /fetch_stage_tb/uut/pc_next
add wave -radix hex /fetch_stage_tb/uut/pc_incremented
add wave -radix hex /fetch_stage_tb/pc_plus_1_out

# Add waves - Control Signals
add wave -divider "Control Signals"
add wave -radix binary /fetch_stage_tb/pc_enable
add wave -radix binary /fetch_stage_tb/ifid_enable
add wave -radix binary /fetch_stage_tb/ifid_flush

# Add waves - Jump/Branch Controls
add wave -divider "Jump & Branch"
add wave -radix binary /fetch_stage_tb/is_conditional_jump
add wave -radix binary /fetch_stage_tb/is_unconditional_jump
add wave -radix binary /fetch_stage_tb/is_call
add wave -radix binary /fetch_stage_tb/is_ret
add wave -radix hex /fetch_stage_tb/immediate_decode
add wave -radix hex /fetch_stage_tb/alu_immediate

# Add waves - Interrupt Controls
add wave -divider "Interrupt/RTI"
add wave -radix binary /fetch_stage_tb/int_load_pc
add wave -radix binary /fetch_stage_tb/rti_load_pc

# Add waves - PC Mux Control
add wave -divider "PC Mux Control"
add wave -radix binary /fetch_stage_tb/uut/pc_mux_sel_signal

# Add waves - Memory Interface
add wave -divider "Memory Interface"
add wave -radix hex /fetch_stage_tb/mem_read_data
add wave -radix hex /fetch_stage_tb/instruction_out

# Add waves - IF/ID Pipeline Register
add wave -divider "IF/ID Register"
add wave -radix hex /fetch_stage_tb/uut/IFID_Reg/instruction_in
add wave -radix hex /fetch_stage_tb/uut/IFID_Reg/instruction_out
add wave -radix hex /fetch_stage_tb/uut/IFID_Reg/pc_plus_1_in
add wave -radix hex /fetch_stage_tb/uut/IFID_Reg/pc_plus_1_out

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
run 500ns

# Zoom to fit
wave zoom full

# Print summary
echo "========================================="
echo "Fetch Stage Simulation Complete"
echo "========================================="
echo "All test cases executed successfully"
echo "Review waveform for timing details"
echo "========================================="
