# Fetch Stage - Five-Stage RISC Processor

## Overview
This directory contains all VHDL files for the Instruction Fetch (IF) stage of the processor.

## Architecture Description

### PC (Program Counter) Path
- **PC Register**: Holds the current program counter value
- **PC Adder**: Computes PC + 1 for sequential instruction fetch
- **PC Mux**: Selects the next PC value from:
  - PC + 1 (normal increment)
  - PC + 1 from IF/ID register
  - Value from Memory
  - Value from ALU (for branches/jumps)

### SP (Stack Pointer) Path
- **SP Register**: Holds the current stack pointer value (initialized to 2^18 - 1)
- **SP Adder**: Computes SP + 1 and SP - 1 for stack operations
- **SP Mux**: Selects the next SP value from:
  - SP + 1 (push operation)
  - SP - 1 (pop operation)
  - 2^18 - 1 (initialization value)

### Memory Access
- **Memory Address Mux**: Selects memory address from:
  - PC Register (instruction fetch)
  - SP Register (stack access)
  - SP + 1 (pre-increment stack operations)
  - ALU (computed addresses)
  - ALU + 2 (offset addressing)

- **Memory Write Data Mux**: Selects data to write to memory from:
  - CCR Register (saving condition codes)
  - PC + 1 from ID/EX register (for CALL/interrupt)
  - Register File data (normal store operations)

### Pipeline Register
- **IF/ID Register**: Stores:
  - Fetched instruction
  - PC + 1 value
  - Supports flush for branch mispredictions

## Control Units
The following control units are implemented as templates (logic to be completed later):
1. **PC_Mux_Control**: Controls PC source selection
2. **SP_Mux_Control**: Controls SP update selection
3. **Memory_Address_Mux_Control**: Controls memory address source
4. **Memory_Write_Data_Mux_Control**: Controls memory write data source

## File Structure

### Core Components
- `PC_Register.vhd` - Program Counter register
- `SP_Register.vhd` - Stack Pointer register
- `PC_Mux.vhd` - PC source multiplexer
- `SP_Mux.vhd` - SP source multiplexer
- `Memory_Address_Mux.vhd` - Memory address multiplexer
- `Memory_Write_Data_Mux.vhd` - Memory write data multiplexer
- `PC_Adder.vhd` - PC increment logic
- `SP_Adder.vhd` - SP increment/decrement logic
- `IF_ID_Register.vhd` - IF/ID pipeline register

### Top-Level Module
- `Fetch_Stage.vhd` - Complete fetch stage integration

### Testbench
- `Fetch_Stage_tb.vhd` - Testbench for fetch stage

## Control Signals

### Input Control Signals
- `pc_enable`: Enable PC register update
- `sp_enable`: Enable SP register update
- `ifid_enable`: Enable IF/ID register update
- `ifid_flush`: Flush IF/ID register (for branch mispredictions)
- `mem_write_enable`: Enable memory write
- `mem_read_enable`: Enable memory read

### Feedback Signals from Later Stages
- `pc_plus_1_from_ifid`: PC + 1 from IF/ID register
- `pc_from_memory`: PC value from memory (for returns)
- `pc_from_alu`: PC value from ALU (for branches)
- `alu_addr`: Address computed by ALU
- `alu_plus_2_addr`: ALU address + 2
- `ccr_data`: Condition code register data
- `pc_plus_1_from_idex`: PC + 1 from ID/EX register
- `regfile_data`: Data from register file

### Control Inputs for Control Units
- `opcode`: Instruction opcode
- `branch_condition`: Branch condition flag
- `push_signal`: Stack push signal
- `pop_signal`: Stack pop signal
- `mem_operation`: Memory operation type
- `is_stack_op`: Stack operation flag
- `is_store`: Store operation flag
- `is_call`: Call instruction flag
- `is_ccr_save`: CCR save flag

## Usage Notes

1. **Memory Component**: The fetch stage expects a Memory component with the interface defined in the existing `Memory.vhd` file. Make sure it's compatible.

2. **Control Units**: The control unit templates are provided with placeholder logic. They currently output default values and need to be implemented based on your instruction set architecture.

3. **Harvard Architecture**: Although described as Harvard architecture, the implementation uses a single shared memory with address multiplexing to support both instruction fetch and data access.

4. **Simulation**: Use the provided testbench (`Fetch_Stage_tb.vhd`) to verify the fetch stage functionality.

## Next Steps

1. Implement the control unit logic based on your ISA specification
2. Integrate the Memory module from the existing `Memory.vhd` file
3. Connect the fetch stage to the decode stage
4. Test with actual instruction patterns

## Dependencies

- IEEE.STD_LOGIC_1164
- IEEE.NUMERIC_STD
- Memory.vhd (existing memory module)
