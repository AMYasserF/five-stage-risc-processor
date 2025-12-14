# Fetch Stage Test Guide

## Overview
This guide explains how to test the fetch stage independently with simulated external components.

## Test Setup

### Files Required
1. `Fetch_Stage.vhd` - Main fetch stage module
2. `PC_Register.vhd` - Program counter register
3. `PC_Mux.vhd` - 6-to-1 multiplexer for PC source
4. `PC_Adder.vhd` - PC + 1 logic
5. `IF_ID_Register.vhd` - Pipeline register
6. `PC_Mux_Control.vhd` - PC source selection control
7. `Fetch_Stage_Complete_tb.vhd` - Comprehensive testbench

### Simulated Components
The testbench simulates:
- **Memory**: 256-word array with pre-loaded test data
- **Decode Stage**: Provides immediate values
- **ALU**: Provides computed addresses
- **Stack Pointer**: Simulated SP value for RET
- **Control Unit**: Test vectors for all control signals

## Running the Simulation

### Using ModelSim/QuestaSim
```bash
# Navigate to project directory
cd "D:/CMP/Architecture/project"

# Compile all files
vcom -2008 VHDL_Files/Fetch_Stage/PC_Register.vhd
vcom -2008 VHDL_Files/Fetch_Stage/PC_Adder.vhd
vcom -2008 VHDL_Files/Fetch_Stage/PC_Mux.vhd
vcom -2008 VHDL_Files/Fetch_Stage/IF_ID_Register.vhd
vcom -2008 VHDL_Files/Fetch_Stage/Fetch_Control_Units/PC_Mux_Control.vhd
vcom -2008 VHDL_Files/Fetch_Stage/Fetch_Stage.vhd
vcom -2008 VHDL_Files/Fetch_Stage/Fetch_Stage_Complete_tb.vhd

# Start simulation
vsim work.fetch_stage_tb

# Add waves
add wave -radix hex sim:/fetch_stage_tb/*
add wave -radix hex sim:/fetch_stage_tb/uut/*

# Run simulation
run 1000 ns
```

### Using GHDL (Open Source)
```bash
# Navigate to project directory
cd "D:/CMP/Architecture/project/VHDL_Files/Fetch_Stage"

# Analyze all files
ghdl -a --std=08 PC_Register.vhd
ghdl -a --std=08 PC_Adder.vhd
ghdl -a --std=08 PC_Mux.vhd
ghdl -a --std=08 IF_ID_Register.vhd
ghdl -a --std=08 Fetch_Control_Units/PC_Mux_Control.vhd
ghdl -a --std=08 Fetch_Stage.vhd
ghdl -a --std=08 Fetch_Stage_Complete_tb.vhd

# Elaborate
ghdl -e --std=08 fetch_stage_tb

# Run simulation with waveform output
ghdl -r --std=08 fetch_stage_tb --vcd=fetch_stage.vcd

# View waveform with GTKWave
gtkwave fetch_stage.vcd
```

### Using Vivado
```tcl
# Create project
create_project fetch_stage_test ./fetch_test -part xc7a35tcpg236-1

# Add source files
add_files {
    VHDL_Files/Fetch_Stage/PC_Register.vhd
    VHDL_Files/Fetch_Stage/PC_Adder.vhd
    VHDL_Files/Fetch_Stage/PC_Mux.vhd
    VHDL_Files/Fetch_Stage/IF_ID_Register.vhd
    VHDL_Files/Fetch_Stage/Fetch_Control_Units/PC_Mux_Control.vhd
    VHDL_Files/Fetch_Stage/Fetch_Stage.vhd
}

# Add testbench
add_files -fileset sim_1 VHDL_Files/Fetch_Stage/Fetch_Stage_Complete_tb.vhd

# Launch simulation
launch_simulation

# Run all
run all
```

## Test Cases

### Test 1: Reset
- **Input**: `rst = '1'`
- **Expected**: PC loads M[0] (0x12345678)
- **Duration**: 2 clock cycles

### Test 2: Normal Sequential Execution
- **Input**: No control signals active
- **Expected**: PC increments by 1 each cycle
- **Duration**: 5 clock cycles

### Test 3: Conditional Jump (Taken)
- **Input**: 
  - `is_conditional_jump = '1'`
  - `jump_condition_met = '1'`
  - `immediate_decode = 0x00000010`
- **Expected**: PC jumps to 0x10
- **Duration**: 1 clock cycle

### Test 4: Conditional Jump (Not Taken)
- **Input**: 
  - `is_conditional_jump = '1'`
  - `jump_condition_met = '0'`
- **Expected**: PC continues normally (PC + 1)
- **Duration**: 1 clock cycle

### Test 5: CALL Instruction
- **Input**: 
  - `is_call = '1'`
  - `alu_immediate = 0x00000020`
- **Expected**: PC jumps to 0x20
- **Duration**: 1 clock cycle

### Test 6: Unconditional Jump
- **Input**: `is_unconditional_jump = '1'`
- **Expected**: PC loads value from memory at current PC
- **Duration**: 1 clock cycle

### Test 7: RET Instruction (2 Cycles)
- **Input**: 
  - Cycle 1: `is_ret = '1'`, `ret_phase = "01"` (SP increment)
  - Cycle 2: `ret_phase = "10"` (PC load from M[SP])
  - `sp_value = 0x000000F0`
- **Expected**: PC loads from M[SP] = M[240] = 0x00000005
- **Duration**: 2 clock cycles

### Test 8: Interrupt INT 0
- **Input**: 
  - Cycle 1: `int_signal = '1'`, `int_index = '0'`, `int_phase = "01"`
  - Cycle 2: `int_phase = "10"`
- **Expected**: PC loads M[2] = 0x00000100
- **Duration**: 2 clock cycles

### Test 9: Interrupt INT 1
- **Input**: 
  - Cycle 1: `int_signal = '1'`, `int_index = '1'`, `int_phase = "01"`
  - Cycle 2: `int_phase = "10"`
- **Expected**: PC loads M[3] = 0x00000200
- **Duration**: 2 clock cycles

### Test 10: Pipeline Flush
- **Input**: `ifid_flush = '1'`
- **Expected**: IF/ID register outputs zeros
- **Duration**: 1 clock cycle

### Test 11: Pipeline Stall
- **Input**: `pc_enable = '0'`, `ifid_enable = '0'`
- **Expected**: PC and IF/ID register hold their values
- **Duration**: 3 clock cycles

## Expected Console Output

```
========================================
Test 1: Reset - PC should load M[0]
========================================
# Time: 30 ns

========================================
Test 2: Normal Execution (PC + 1)
========================================
PC incremented normally
# Time: 80 ns

========================================
Test 3: Conditional Jump (taken)
========================================
Conditional jump executed
# Time: 110 ns

...

========================================
All tests completed successfully!
========================================
```

## Verification Points

### Critical Signals to Monitor
1. **mem_fetch_address** - PC value being used
2. **pc_plus_1_out** - Next sequential address
3. **instruction_out** - Fetched instruction
4. **pc_mux_sel_signal** - PC source selection (internal)
5. **mem_fetch_read_data** - Data read from memory

### Waveform Analysis
- PC should increment smoothly during normal operation
- Jump/branch operations should show immediate PC change
- Multi-cycle operations (INT, RET) should show correct phasing
- Memory address should match PC value (except during special operations)

## Troubleshooting

### PC Not Incrementing
- Check `pc_enable` is '1'
- Verify PC_Adder is adding 1 correctly
- Confirm no control signals are active

### Wrong Jump Target
- Verify immediate values are correct
- Check PC_Mux selection signal
- Confirm PC_Mux_Control priority logic

### Memory Read Issues
- Ensure `mem_fetch_read_enable` is '1'
- Check memory simulation process
- Verify address is within bounds

## Memory Map (Test Data)

| Address | Value      | Description |
|---------|------------|-------------|
| 0x00    | 0x12345678 | Reset vector |
| 0x01    | 0xAABBCCDD | Instruction |
| 0x02    | 0x00000100 | INT 0 vector |
| 0x03    | 0x00000200 | INT 1 vector |
| 0x10    | 0x000000F0 | Jump target |
| 0x20    | 0x000000AA | CALL target |
| 0xF0    | 0x00000005 | Return address |

## Success Criteria

✅ All test cases pass
✅ No assertion failures
✅ PC transitions are correct
✅ Timing is appropriate
✅ No undefined signals (X or U)
