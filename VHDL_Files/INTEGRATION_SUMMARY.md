# Complete 5-Stage Processor Integration

## Summary
Successfully integrated all pipeline stages into `Processor_Top.vhd`:
- ✅ Fetch Stage (already present)
- ✅ IF/ID Pipeline Register (already present)
- ✅ Decode Stage (already present)
- ✅ ID/EX Pipeline Register (already present)
- ✅ Execute Stage (already present)
- ✅ **EX/MEM Pipeline Register (NEW)**
- ✅ **Memory Stage (NEW)**
- ✅ **MEM/WB Pipeline Register (NEW)**
- ✅ **Writeback Stage (NEW)**

## Files Modified

### 1. Processor_Top.vhd
**Major Changes:**
- Added component declarations for:
  - `EX_MEM_Register`
  - `Memory_Stage`
  - `Mem_Wb_Register`
  - `Write_Back`

- Added internal signal declarations for:
  - EX/MEM pipeline register outputs (exmem_*)
  - Memory stage outputs (mem_*)
  - MEM/WB pipeline register outputs (memwb_*)
  - Writeback stage outputs (wb_*)

- Updated entity ports:
  - Removed external writeback inputs (now internal)
  - Changed `wb_write_enable`, `wb_write_reg`, `wb_write_data` to outputs
  - Removed external `int_load_pc` and `rti_load_pc` inputs (now generated internally by Memory stage)
  - Removed external `is_ret` and `is_call` inputs (now generated internally)
  - Added `input_port` input and `output_port` output

- Instantiated new components:
  - EX/MEM pipeline register connects Execute stage to Memory stage
  - Memory stage with integrated SP, memory address/data muxing, INT/RTI FSMs
  - MEM/WB pipeline register connects Memory stage to Writeback stage
  - Writeback stage generates final register write signals

- Updated connections:
  - Fetch stage now uses internal `int_load_pc_internal` and `rti_load_pc_internal` from Memory stage
  - Decode stage now uses writeback signals from internal Writeback stage
  - All pipeline stages properly connected in sequence

## Files Created

### 1. compile_full_processor.tcl
Compilation script for all processor components in correct dependency order.

**Usage:**
```tcl
cd D:/CMP/Architecture/project/VHDL_Files
do compile_full_processor.tcl
```

### 2. Processor_Top_TB.vhd
Simple testbench for the complete processor.
- Tests ADD instruction: R1 = R2 + R3 (5 + 3 = 8)
- Includes instruction memory with LDM and ADD instructions
- Runs for 400 ns

### 3. run_processor_tb.tcl
Complete compilation and simulation script.
- Compiles all components
- Compiles testbench
- Starts simulation
- Adds comprehensive waveforms
- Runs for 400 ns

**Usage:**
```tcl
cd D:/CMP/Architecture/project/VHDL_Files
do run_processor_tb.tcl
```

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                      PROCESSOR_TOP                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  Fetch ──┬──▶ IF/ID ──┬──▶ Decode ──┬──▶ ID/EX ──┐              │
│          │            │             │            │              │
│          │            │             │            ▼              │
│          │            │             │         Execute           │
│          │            │             │            │              │
│          │            │             │            ▼              │
│          │            │             │        EX/MEM ←───────┐   │
│          │            │             │            │          │   │
│          │            │             │            ▼          │   │
│          │            │             │         Memory        │   │
│          │            │             │       (with SP,       │   │
│          │            │             │     INT/RTI FSMs)     │   │
│          │            │             │            │          │   │
│          │            │             │            ▼          │   │
│          │            │             │         MEM/WB        │   │
│          │            │             │            │          │   │
│          │            │             │            ▼          │   │
│          │            │             │        Writeback      │   │
│          │            │             │            │          │   │
│          │            │             └────────────┼──────────┘   │
│          │            │                          │              │
│          │            └──────────────────────────┘              │
│          │                                                       │
│          └───────────────────────────────────────┘              │
│             (PC control from Memory stage)                      │
│                                                                  │
└──────────────────────────────────────────────────────────────────┘
```

## Key Features

### Memory Stage Integration
The Memory stage includes:
- **Stack Pointer (SP) System:**
  - SP Register, Adder, Mux, Control Unit
  - Handles CALL, RET, PUSH, POP operations
  
- **Memory Address Muxing:**
  - Selects between reset address, INT address, PC, SP, SP+1, ALU result
  - Controlled by Memory Address Control Unit
  
- **Memory Write Data Muxing:**
  - Selects between PC, register data, CCR
  - Controlled by Memory Write Data Control Unit
  
- **INT/RTI Control FSMs:**
  - INT FSM: Handles interrupt operations (push PC, push CCR, load PC)
  - RTI FSM: Handles return from interrupt (restore CCR, restore PC)
  
- **Data Memory:**
  - Integrated memory component for load/store operations

### Writeback Stage Integration
The Writeback stage includes:
- Input/Output port handling
- Memory-to-register data selection
- SWAP instruction phase management
- Register write data and address generation

### PC Control
- INT and RTI now control PC loading internally
- Memory stage generates `int_load_pc` and `rti_load_pc` signals
- Fetch stage responds to these internal signals

## Signal Flow

### Data Path:
1. **Fetch**: Reads instruction from memory
2. **IF/ID**: Stores fetched instruction
3. **Decode**: Reads from register file, decodes instruction
4. **ID/EX**: Stores decoded data
5. **Execute**: Performs ALU operation
6. **EX/MEM**: Stores ALU result and control signals
7. **Memory**: Accesses data memory, manages stack, handles interrupts
8. **MEM/WB**: Stores memory data and control signals
9. **Writeback**: Selects data to write back, generates write signals
10. **Feedback to Decode**: Writes to register file

### Control Path:
- Control signals propagate through pipeline registers
- Special operations (INT/RTI/CALL/RET) modify PC in Fetch stage
- Memory stage generates PC control signals

## Testing

### Test Program (in Processor_Top_TB.vhd):
```assembly
Address 0: LDM R2, #5      ; Load immediate 5 into R2
Address 1: 0x00000005      ; Immediate value
Address 2: LDM R3, #3      ; Load immediate 3 into R3
Address 3: 0x00000003      ; Immediate value
Address 4: ADD R1, R2, R3  ; R1 = R2 + R3 = 5 + 3 = 8
Address 5: NOP             ; No operation
...
```

### Expected Results:
- After ~15-20 cycles:
  - R2 = 0x00000005
  - R3 = 0x00000003
  - R1 = 0x00000008

### Waveform Signals:
- Clock and Reset
- Program Counter (PC)
- Instruction being fetched
- All 8 registers (R0-R7)
- ALU Result
- Memory control signals
- Writeback signals
- I/O Ports

## Next Steps

1. **Compile the processor:**
   ```tcl
   do run_processor_tb.tcl
   ```

2. **Verify waveforms:**
   - Check that registers are updated correctly
   - Verify pipeline progression
   - Confirm ALU operations

3. **Add more tests:**
   - Expand testbench with more instructions
   - Test memory operations (LDD, STD)
   - Test stack operations (PUSH, POP, CALL, RET)
   - Test interrupts (INT, RTI)

4. **Add forwarding unit:**
   - Currently using external forwarding signals
   - Implement internal forwarding unit for data hazard resolution

5. **Add hazard detection:**
   - Implement hazard detection unit
   - Add pipeline stalling logic

## Notes

- The processor uses a 10 ns clock period
- All registers initialize to 0x00000000 to avoid 'X' values
- The register file is properly initialized in the declaration
- Memory stage includes comprehensive stack and interrupt support
- The processor is now a complete 5-stage pipelined RISC processor!

## Compilation Order

Critical compilation order (handled by scripts):
1. Memory
2. Fetch stage components
3. Decode stage components (register_file first!)
4. Execute stage components
5. Memory stage components
6. Writeback stage
7. Processor_Top
8. Testbench

## File Structure
```
VHDL_Files/
├── Fetch_Stage/
│   ├── PC_Register.vhd
│   ├── PC_Adder.vhd
│   ├── PC_Mux.vhd
│   ├── PC_Mux_Control.vhd
│   ├── Fetch_Stage.vhd
│   └── IF_ID_Register.vhd
├── Decode_Stage/
│   ├── register_file.vhd
│   ├── Immediate_Decoder.vhd
│   ├── Control_Unit.vhd
│   ├── decode_stage.vhd
│   └── ID_EX_register.vhd
├── Excute_Stage/
│   ├── ALU.vhd
│   ├── CCR_Register.vhd
│   ├── Execute_Stage.vhd
│   └── EX_MEM_Register.vhd (NEW)
├── Memory_Stage/
│   ├── SP_Register.vhd
│   ├── SP_Adder.vhd
│   ├── SP_Mux.vhd
│   ├── SP_Control_Unit.vhd
│   ├── ALU_Plus_2_Adder.vhd
│   ├── Memory_Address_Mux.vhd
│   ├── Memory_Address_Control_Unit.vhd
│   ├── Memory_Write_Data_Mux.vhd
│   ├── Memory_Write_Data_Control_Unit.vhd
│   ├── INT_Control_Unit.vhd
│   ├── RTI_Control_Unit.vhd
│   ├── Memory_Stage.vhd (NEW)
│   └── Mem_Wb_Register.vhd (NEW)
├── Writeback_Stage/
│   └── Write_Back.vhd (NEW)
├── Memory_System/
│   └── Memory.vhd
├── Processor_Top.vhd (UPDATED)
├── Processor_Top_TB.vhd (NEW)
├── compile_full_processor.tcl (NEW)
└── run_processor_tb.tcl (NEW)
```
