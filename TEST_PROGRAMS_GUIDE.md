# TCL Do Files for Test Programs

## Overview

Five TCL do files have been created in `VHDL_Files/` directory to run the test programs from the `spec/` folder. Each file compiles the design and runs a specific test with appropriate simulation duration and waveform configuration.

---

## Available Test Programs

### 1. run_OneOperand.do
- **Tests**: OneOperand instruction set
- **Program File**: `spec/OneOperand.txt`
- **Duration**: 5000 ns
- **Focus**: Single-operand instructions (NOP, SETC, NOT, INC, OUT, IN, MOV, SWAP)
- **Usage**:
  ```bash
  cd VHDL_Files
  vsim -do run_OneOperand.do
  ```

### 2. run_TwoOperand.do
- **Tests**: TwoOperand instruction set
- **Program File**: `spec/TwoOperand.txt`
- **Duration**: 5000 ns
- **Focus**: Two-operand instructions (ADD, SUB, AND)
- **Usage**:
  ```bash
  cd VHDL_Files
  vsim -do run_TwoOperand.do
  ```

### 3. run_Branch.do
- **Tests**: Branch and jump instructions
- **Program File**: `spec/Branch.txt`
- **Duration**: 20000 ns
- **Focus**: JMP, JZ, JN, JC instructions
- **Special Monitoring**: Conditional jump signals
- **Usage**:
  ```bash
  cd VHDL_Files
  vsim -do run_Branch.do
  ```

### 4. run_Memory.do
- **Tests**: Memory access instructions
- **Program File**: `spec/Memory.txt`
- **Duration**: 10000 ns
- **Focus**: LDD, STD (load/store from data memory)
- **Special Monitoring**: Memory address, write data, read data signals
- **Usage**:
  ```bash
  cd VHDL_Files
  vsim -do run_Memory.do
  ```

### 5. run_BranchPrediction.do
- **Tests**: Dynamic branch prediction
- **Program File**: `spec/BranchPrediction.txt`
- **Duration**: 30000 ns
- **Focus**: Two-bit branch prediction state machine behavior
- **Special Monitoring**: Prediction state signals, branch outcomes
- **Usage**:
  ```bash
  cd VHDL_Files
  vsim -do run_BranchPrediction.do
  ```

---

## File Structure

Each do file contains:

```
1. Header and Description
2. Configuration (program file path)
3. Library Setup
   - vlib work
   - vmap work work
4. VHDL Compilation
   - Compiles all necessary VHDL files
   - Uses -2008 standard
   - Explicit compilation mode
5. Simulation Start
   - vsim -t 1ps Processor_Top_TB
6. Waveform Configuration
   - Adds waves for:
     * Processor signals
     * Pipeline stages
     * Test-specific signals (branches, memory, etc.)
     * Register file
7. Simulation Execution
   - run <duration>
8. Completion Message
```

---

## Features

### ✅ Each File Includes:
- Complete VHDL compilation
- Automatic waveform setup
- Test-specific signal monitoring
- Proper simulation duration
- Status messages

### ✅ Test-Specific Monitoring:
- **Branch test**: Includes conditional jump signals
- **Memory test**: Includes memory address/data signals
- **BranchPrediction test**: Includes prediction state signals

---

## Usage Instructions

### Method 1: Run from ModelSim GUI
```bash
# Open ModelSim from VHDL_Files directory
cd VHDL_Files
vsim

# In ModelSim console:
do run_OneOperand.do
do run_TwoOperand.do
do run_Branch.do
do run_Memory.do
do run_BranchPrediction.do
```

### Method 2: Run from Command Line
```bash
cd VHDL_Files

# Run single test
vsim -do run_OneOperand.do

# Run with options
vsim -do run_OneOperand.do -wlf waveform.wlf
```

### Method 3: Run All Tests
```bash
cd VHDL_Files
vsim -do "do run_OneOperand.do; quit"
vsim -do "do run_TwoOperand.do; quit"
vsim -do "do run_Branch.do; quit"
vsim -do "do run_Memory.do; quit"
vsim -do "do run_BranchPrediction.do; quit"
```

---

## Program File Locations

| Test | Program File | Size |
|------|-------------|------|
| OneOperand | `spec/OneOperand.txt` | ~525 lines |
| TwoOperand | `spec/TwoOperand.txt` | ~527 lines |
| Branch | `spec/Branch.txt` | ~2564 lines |
| Memory | `spec/Memory.txt` | ? lines |
| BranchPrediction | `spec/BranchPrediction.txt` | ? lines |

---

## Waveform Configuration

Each test file configures waveforms for:

### Common Signals
- Clock, Reset, Output Port
- Instruction signals (Fetch, Decode, Execute)
- Register file contents

### Test-Specific Signals

**Branch Test**:
- Conditional jump signal
- Branch execution status

**Memory Test**:
- Memory address output
- Write data signals
- Read data signals

**BranchPrediction Test**:
- Branch prediction state (2-bit)
- Actual branch outcomes
- Jump signals

---

## Customization

### Change Simulation Duration
Edit the `run` command:
```tcl
run 5000ns   # Change to desired duration
```

### Change Waveforms
Add/remove wave commands:
```tcl
add wave -noupdate /Processor_Top_TB/signal_name
```

### Change Program File
Modify the PROGRAM_FILE generic in testbench instantiation or update path references.

---

## Example Output

Running `run_OneOperand.do`:
```
======================================
Testing OneOperand Instructions
======================================
Program file: ../spec/OneOperand.txt

Compiling design...
Compilation complete.

Starting simulation...
Waveforms configured.

Running simulation for 5000 ns...

======================================
OneOperand test execution complete
======================================
```

---

## Tips

### Tip 1: Check Compilation
If compilation fails, verify:
- All VHDL files exist
- File paths are correct relative to VHDL_Files/
- No syntax errors in source files

### Tip 2: Review Waveforms
After running:
- Use Wave Viewer to analyze behavior
- Compare outputs with expected results
- Monitor signals of interest for your test

### Tip 3: Debug Issues
If test fails:
- Check program file path
- Verify program format (binary)
- Look for errors in simulation log
- Compare waveforms with expected behavior

### Tip 4: Batch Testing
Create a script to run all tests:
```bash
#!/bin/bash
cd VHDL_Files
for test in run_*.do; do
  echo "Running $test..."
  vsim -do "$test" -wlf "${test%.do}.wlf"
done
```

---

## Program Format

All test programs are in **binary format** (32-bit binary strings):
```
00000000000000000000001000000000
00000000000000000000000000000000
...
```

---

## File Locations

```
VHDL_Files/
├── run_OneOperand.do           ← Test 1
├── run_TwoOperand.do           ← Test 2
├── run_Branch.do               ← Test 3
├── run_Memory.do               ← Test 4
├── run_BranchPrediction.do     ← Test 5
└── Processor_Top_TB.vhd        (testbench)

spec/
├── OneOperand.txt              ← Program 1
├── TwoOperand.txt              ← Program 2
├── Branch.txt                  ← Program 3
├── Memory.txt                  ← Program 4
└── BranchPrediction.txt        ← Program 5
```

---

## Success Criteria

✅ Each test should:
- Compile without errors
- Start simulation successfully
- Run for specified duration
- Generate waveforms
- Complete without crashing

---

## Summary

Five comprehensive do files are ready to test all major instruction types and features:
- OneOperand instructions
- TwoOperand instructions
- Branch instructions
- Memory operations
- Dynamic branch prediction

Simply run: `vsim -do run_<TestName>.do`
