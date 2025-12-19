# Forwarding Unit Reference

## Overview
The Forwarding Unit automatically detects and resolves Read-After-Write (RAW) data hazards in the 5-stage pipeline without requiring stalls. It monitors the pipeline registers and generates control signals to forward data from later stages back to the Execute stage when needed.

## Forwarding Control Signals

### ForwardA & ForwardB (4-bit each)
These signals control which data source is selected for ALU operands A and B.

**Note:** The current Execute_Stage uses only the lower 2 bits (1 downto 0) of these 4-bit signals.

### Encoding Table

| Binary | Hex | Source | Description |
|--------|-----|--------|-------------|
| 0000   | 0x0 | No forwarding | Use ID/EX data (normal pipeline flow) |
| 0001   | 0x1 | EX/MEM ALU result | Forward ALU output from Memory stage |
| 0010   | 0x2 | EX/MEM Rsrc2 | Forward Rsrc2 for SWAP instruction |
| 0011   | 0x3 | EX/MEM ALU result (SWAP dest) | Forward ALU result when SWAP uses dest reg |
| 0100   | 0x4 | EX/MEM input port | Forward input port data |
| 0101   | 0x5 | MEM/WB memory data | Forward loaded memory data |
| 0110   | 0x6 | MEM/WB Rsrc2 (SWAP) | Forward Rsrc2 from Writeback (SWAP) |
| 0111   | 0x7 | MEM/WB ALU result (SWAP dest) | Forward ALU result from Writeback (SWAP) |
| 1000   | 0x8 | MEM/WB input port | Forward input port from Writeback |
| 1001   | 0x9 | MEM/WB ALU result | Forward ALU result from Writeback |

## Priority System

The Forwarding Unit checks for hazards in this order:

1. **EX/MEM Stage (Priority 1)** - Most recent data
   - If the instruction in EX/MEM writes to a register that the current instruction needs, forward from EX/MEM
   
2. **MEM/WB Stage (Priority 2)** - Older data
   - If no EX/MEM hazard but MEM/WB writes to a needed register, forward from MEM/WB

3. **No Hazard** - Use ID/EX data normally

## Special Cases

### SWAP Instruction
The SWAP instruction writes to two registers:
- **DestReg**: Gets the ALU result (swapped value)
- **Rsrc1**: Gets Rsrc2 data directly

The Forwarding Unit checks both register writes when SWAP is in the pipeline.

### IN Instruction
The IN instruction reads from an input port rather than computing an ALU result. The Forwarding Unit detects this and forwards the input port data instead of the ALU result.

### Memory-to-Register Operations (LDM, POP)
When loading from memory, the data isn't available until the Memory stage completes. The Forwarding Unit detects `mem_to_reg` signals and forwards the memory data instead of the ALU result.

## Waveform Signals to Monitor

### Forwarding Control
- `forward_a` - 4-bit control for operand A
- `forward_b` - 4-bit control for operand B

### Forwarding Data Paths
- `forward_ex_mem_data` - 32-bit data from EX/MEM stage
- `forward_mem_wb_data` - 32-bit data from MEM/WB stage

### Execute Stage Inputs (uses lower 2 bits)
- `forward_mux_a_sel` - Lower 2 bits of forward_a
- `forward_mux_b_sel` - Lower 2 bits of forward_b

## Example Hazard Scenarios

### Scenario 1: EX/MEM Forwarding (Most Common)
```assembly
ADD R1, R2, R3    # R1 = R2 + R3 (in EX/MEM stage)
ADD R4, R1, R5    # R4 = R1 + R5 (in Execute stage, needs R1)
```
**Result:** `forward_a = 0001` (forward EX/MEM ALU result to operand A)

### Scenario 2: MEM/WB Forwarding
```assembly
ADD R1, R2, R3    # R1 = R2 + R3 (in MEM/WB stage)
NOP               # (in EX/MEM stage)
ADD R4, R1, R5    # R4 = R1 + R5 (in Execute stage, needs R1)
```
**Result:** `forward_a = 1001` (forward MEM/WB ALU result to operand A)

### Scenario 3: Load-Use Hazard
```assembly
LDM R1, [R2]      # Load R1 from memory (in MEM/WB stage)
ADD R3, R1, R4    # R3 = R1 + R4 (in Execute stage, needs R1)
```
**Result:** `forward_a = 0101` (forward MEM/WB memory data to operand A)

### Scenario 4: SWAP Forwarding
```assembly
SWAP R1, R2       # Swap R1 and R2 (in EX/MEM stage)
ADD R3, R1, R4    # R3 = R1 + R4 (needs new R1 value)
```
**Result:** `forward_a = 0010` (forward EX/MEM Rsrc2 data, which is the new R1 value)

## Testing the Forwarding Unit

### What to Look For in Waveforms

1. **No Hazard (forward_a = 0000, forward_b = 0000)**
   - Normal operation, no data dependencies
   
2. **EX/MEM Forwarding (forward_a/b = 0001-0100)**
   - Data forwarded from the Memory stage
   - Most recent data available
   
3. **MEM/WB Forwarding (forward_a/b = 0101-1001)**
   - Data forwarded from the Writeback stage
   - Older data (2 cycles old)

### Verification Checklist

- [ ] Consecutive dependent instructions forward correctly
- [ ] ForwardA activates when EX/MEM writes to ID/EX's first source register
- [ ] ForwardB activates when EX/MEM writes to ID/EX's second source register
- [ ] EX/MEM forwarding takes priority over MEM/WB forwarding
- [ ] No forwarding occurs when register addresses don't match
- [ ] No forwarding occurs when the instruction doesn't write to a register
- [ ] SWAP instruction forwards both values correctly
- [ ] IN instruction forwards input port data
- [ ] LDM/POP forwards memory data instead of ALU result

## Current Implementation Notes

### Simplified Data Selection
The current `Processor_Top.vhd` has simplified forwarding data selection logic that uses only the lower 2 bits of the control signals:

```vhdl
forward_ex_mem_data <= exmem_alu_result when forward_a(1 downto 0) = "01" or forward_b(1 downto 0) = "01" else
                       exmem_read_data2 when forward_a(1 downto 0) = "10" or forward_b(1 downto 0) = "10" else
                       (others => '0');
```

### Future Enhancement
For full 10-scenario support, the data selection logic can be enhanced to use all 4 bits and properly handle:
- Input port forwarding (0100, 1000)
- Memory data forwarding (0101)
- Full SWAP support (0010, 0011, 0110, 0111)

### Execute Stage Limitation
The `Execute_Stage.vhd` currently uses 2-bit mux selects. To fully utilize the 4-bit forwarding controls, the Execute stage ALU input muxes would need to be updated to handle more input sources.

## Files Modified for Forwarding Integration

1. **Forwarding_Unit.vhd** - New file, implements hazard detection
2. **Processor_Top.vhd** - Integrated Forwarding_Unit, added internal signals
3. **Processor_Top_TB.vhd** - Removed external forwarding inputs
4. **compile_full_processor.tcl** - Added Forwarding_Unit compilation
5. **run_processor_tb.tcl** - Added forwarding signals to waveforms
6. **add_waves.tcl** - Added forwarding signals to waveforms
