# Decode Stage Documentation

## Overview

The Decode Stage is responsible for decoding instructions, reading register values, and generating control signals for the RISC processor pipeline. It follows the instruction encoding defined in `assembler.py`.

## Components

### 1. Register File (`register_file.vhd`)

**Description**: 8 general-purpose 32-bit registers (R0-R7)

**Ports**:

- **Inputs**:

  - `clk`: Clock signal
  - `rst`: Reset signal (synchronous)
  - `read_reg1[2:0]`: Rs1 register address (bits [21:19] from instruction)
  - `read_reg2[2:0]`: Rs2 register address (bits [18:16] from instruction)
  - `write_enable`: Enable register write from writeback stage
  - `write_reg[2:0]`: Rd register address for write
  - `write_data[31:0]`: Data to write to register

- **Outputs**:
  - `read_data1[31:0]`: Data from Rs1 (asynchronous read)
  - `read_data2[31:0]`: Data from Rs2 (asynchronous read)

**Features**:

- Asynchronous read (combinational)
- Synchronous write on rising clock edge
- All registers reset to 0 on reset
- Supports simultaneous read and write operations

### 2. Decode Stage (`decode_stage.vhd`)

**Description**: Top-level decode stage integrating register file and control unit

**Instruction Format** (from `assembler.py`):

```
[31:25] - Opcode (7 bits)
  [6]   - hasImm flag (1 = immediate in next word)
  [5:4] - Type (00=R, 01=I, 10=J, 11=System)
  [3:0] - Function code
[24:22] - Rd (destination register, 3 bits)
[21:19] - Rs1 (source register 1, 3 bits)
[18:16] - Rs2 (source register 2, 3 bits)
[15:0]  - Reserved/Unused
```

**Encoding Function** (from `assembler.py`):

```python
def inst_word(op, rd=0, rs1=0, rs2=0):
    return (op<<25)|(rd<<22)|(rs1<<19)|(rs2<<16)
```

## Signal Flow

### Inputs

- **From Fetch Stage**:

  - `instruction[31:0]`: Current instruction
  - `pc_in[31:0]`: Program counter value

- **From Writeback Stage**:

  - `wb_write_enable`: Register write enable
  - `wb_write_reg[2:0]`: Destination register address
  - `wb_write_data[31:0]`: Data to write back

- **Pipeline Control**:
  - `previous_is_immediate`: Flag indicating previous instruction had immediate
  - `immediate_value[31:0]`: Immediate value from instruction memory

### Outputs

#### Decoded Instruction Fields

- `opcode[6:0]`: Extracted opcode (bits [31:25])
- `rd[2:0]`: Destination register (bits [24:22])
- `rs1[2:0]`: Source register 1 (bits [21:19])
- `rs2[2:0]`: Source register 2 (bits [18:16])

#### Register Data

- `read_data1[31:0]`: Data from Rs1
- `read_data2[31:0]`: Data from Rs2

#### Control Signals (from Control Unit)

See `control_signals.md` for detailed signal descriptions:

- Memory control: `mem_write`, `mem_read`, `mem_to_reg`
- ALU control: `alu_op[3:0]`
- Special operations: `is_swap`, `is_call`, `is_ret`, `is_int`, `is_rti`, `is_push`, `is_pop`, `is_in`
- Branch control: `branchZ`, `branchC`, `branchN`, `unconditional_branch`
- CCR control: `ccr_in[1:0]`
- Other: `out_enable`, `reg_write`, `is_immediate`, `hlt`

#### Pass-through Signals

- `pc_out[31:0]`: PC passed to next stage
- `immediate_out[31:0]`: Immediate value passed to next stage

## Register Addressing

Based on `assembler.py`:

- **8 registers total**: R0, R1, R2, R3, R4, R5, R6, R7
- **3-bit addressing**: 000 (R0) to 111 (R7)

```python
def reg(r):
    r=r.upper()
    if r.startswith("R"):
        n=int(r[1:])
        if 0<=n<=7: return n
    raise ValueError("Invalid Register "+r)
```

## Instruction Examples

### R-Type (ADD R0, R1, R2)

```
Opcode: 0001000 (Type=00, Func=1000)
Rd:     000     (R0)
Rs1:    001     (R1)
Rs2:    010     (R2)
```

- Register file reads R1 → read_data1, R2 → read_data2
- Control unit generates: alu_op=1000 (ADD), reg_write=1

### I-Type (LDM R4, 99)

```
Instruction word:
Opcode: 1010010 (hasImm=1, Type=01, Func=0010)
Rd:     100     (R4)
Rs1:    000
Rs2:    000

Next word: 0x00000063 (99 decimal)
```

- Control unit generates: is_immediate=1, alu_op=0011 (PassB), reg_write=1
- Immediate value passed to execution stage

### J-Type (JZ 44)

```
Instruction word:
Opcode: 1100010 (hasImm=1, Type=10, Func=0010)
Rd:     000
Rs1:    000
Rs2:    000

Next word: 0x0000002C (44 decimal)
```

- Control unit generates: branchZ=1, ccr_in=01, is_immediate=1

## Pipeline Integration

### Data Hazards

The decode stage reads registers asynchronously, so data hazards must be handled by:

1. Forwarding logic in later stages
2. Pipeline stalls when necessary
3. Previous instruction immediate flag to handle multi-word instructions

### Control Hazards

Branch instructions set branch control signals that must be resolved in the execution stage.

### Immediate Handling

When `is_immediate=1`:

- Current instruction + immediate value span 2 memory words
- Next cycle processes immediate as data (control signals = 0)
- `previous_is_immediate` flag prevents immediate from being decoded as instruction

## Reset Behavior

- All registers reset to 0x00000000
- Control signals reset to default values
- Pipeline can be flushed by asserting reset

## Timing

- **Read**: Combinational (same cycle)
- **Write**: Registered (next rising clock edge)
- **Control signals**: Combinational from opcode decode

## Files

- `register_file.vhd`: 8-register file with dual read, single write
- `decode_stage.vhd`: Top-level decode stage integrating register file and control unit
- `control_unit.vhd`: Control signal generator (already exists)
- `README.md`: This documentation file
