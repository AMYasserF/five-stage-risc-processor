# RISC Processor Assembler

A Python-based assembler for a custom RISC processor with support for R-type, I-type, J-type, and System/Stack instructions.

## Overview

This assembler converts assembly language instructions into 32-bit machine code for a five-stage RISC processor. It supports a full Instruction Set Architecture (ISA) with 4 instruction types and generates memory initialization files for processor simulation.

## Features

- **4 Instruction Types**: R-type, I-type, J-type, and System/Stack operations
- **8 General-Purpose Registers**: R0 through R7
- **32-bit Instructions**: Fixed-width instruction format
- **Memory Output**: Generates `mem.txt` with binary machine code

## Instruction Set Architecture

### R-Type Instructions (Register Operations)

No immediate values, operates on registers only.

| Instruction        | Opcode | Description          |
| ------------------ | ------ | -------------------- |
| `NOP`              | 0000   | No operation         |
| `SETC`             | 0001   | Set carry flag       |
| `NOT Rd`           | 0010   | Bitwise NOT of Rd    |
| `INC Rd`           | 0011   | Increment Rd by 1    |
| `OUT Rs1`          | 0100   | Output Rs1 to I/O    |
| `IN Rd`            | 0101   | Input from I/O to Rd |
| `MOV Rs1, Rd`      | 0110   | Move Rs1 to Rd       |
| `SWAP Rs1, Rd`     | 0111   | Swap Rs1 and Rd      |
| `ADD Rd, Rs1, Rs2` | 1000   | Rd = Rs1 + Rs2       |
| `SUB Rd, Rs1, Rs2` | 1001   | Rd = Rs1 - Rs2       |
| `AND Rd, Rs1, Rs2` | 1010   | Rd = Rs1 & Rs2       |

### I-Type Instructions (Immediate Operations)

Include a 32-bit immediate value (second word).

| Instruction            | Opcode | Description                          |
| ---------------------- | ------ | ------------------------------------ |
| `IADD Rd, Rs1, imm`    | 0001   | Rd = Rs1 + imm                       |
| `LDM Rd, imm`          | 0010   | Load immediate value to Rd           |
| `LDD Rd, Rs1, offset`  | 0011   | Load from memory[Rs1 + offset] to Rd |
| `STD Rs1, Rs2, offset` | 0100   | Store Rs1 to memory[Rs2 + offset]    |

### J-Type Instructions (Jump/Branch)

Include a 32-bit target address (second word).

| Instruction   | Opcode | Description               |
| ------------- | ------ | ------------------------- |
| `JMP target`  | 0001   | Unconditional jump        |
| `JZ target`   | 0010   | Jump if zero flag set     |
| `JN target`   | 0011   | Jump if negative flag set |
| `JC target`   | 0100   | Jump if carry flag set    |
| `CALL target` | 0101   | Call subroutine           |
| `RET`         | 0110   | Return from subroutine    |

### System/Stack Instructions

| Instruction | Opcode | Description           |
| ----------- | ------ | --------------------- |
| `PUSH Rs1`  | 0001   | Push Rs1 onto stack   |
| `POP Rd`    | 0010   | Pop from stack to Rd  |
| `INT imm`   | 0011   | Software interrupt    |
| `RTI`       | 0100   | Return from interrupt |
| `HLT`       | 0101   | Halt processor        |

## Instruction Format

### 32-bit Instruction Word Structure

```
[31:25] - Opcode (7 bits)
[24:22] - Rd (3 bits)
[21:19] - Rs1 (3 bits)
[18:16] - Rs2 (3 bits)
[15:0]  - Reserved/Unused
```

### Opcode Encoding

```
[6]   - hasImm flag (1 = has immediate/address in next word)
[5:4] - Type (00=R, 01=I, 10=J, 11=System)
[3:0] - Function code
```

## Usage

### Basic Usage

```bash
python assembler.py
```

The assembler reads `program.asm` and generates `mem.txt`.

### Assembly File Format

Create a `.asm` file with assembly instructions:

```assembly
; Comments start with semicolon

NOP
SETC
LDM R1, 100        ; Load immediate
ADD R2, R1, R0     ; Add registers
IADD R3, R2, 50    ; Add immediate
STD R1, R2, 10     ; Store to memory
JMP 100            ; Jump to address
CALL 200           ; Call subroutine
PUSH R3            ; Push register
POP R4             ; Pop to register
RET                ; Return
HLT                ; Halt
```

### Register Naming

Registers must be specified as `R0` through `R7` (case-insensitive).

### Immediate Values

Immediate values support multiple formats:

- Decimal: `100`, `255`
- Hexadecimal: `0x64`, `0xFF`
- Octal: `0o144`
- Binary: `0b11111111`

## Output Format

The assembler generates `mem.txt` with the following format:

```
0000: 00000000000000000000000000000000
0001: 00000001000000000000000000000000
0002: 00000010000000000000000000000000
...
```

Each line contains:

- **Address** (4 digits): Memory location
- **Colon separator**
- **Binary value** (32 bits): Machine code instruction

## Example

### Input (`program.asm`)

```assembly
; Simple program
LDM R1, 10         ; Load 10 into R1
LDM R2, 20         ; Load 20 into R2
ADD R3, R1, R2     ; R3 = R1 + R2 = 30
OUT R3             ; Output result
HLT                ; Stop
```

### Output (`mem.txt`)

```
0000: 01000100010000000000000000000000
0001: 00000000000000000000000000001010
0002: 01000100100000000000000000000000
0003: 00000000000000000000000000010100
0004: 00100000110000100100000000000000
0005: 00010000000011000000000000000000
0006: 00001100000000000000000000000000
```

## Implementation Details

### Assembler Functions

- **`reg(r)`**: Converts register string (e.g., "R1") to 3-bit register number
- **`build_opcode(hasImm, typ, func)`**: Constructs 7-bit opcode from components
- **`inst_word(op, rd, rs1, rs2)`**: Builds 32-bit instruction word
- **`assemble(lines)`**: Main assembly function, processes all instructions
- **`write_mem(mem)`**: Writes machine code to `mem.txt`

### Error Handling

The assembler will raise errors for:

- Invalid register names (must be R0-R7)
- Unknown instructions
- Malformed instruction syntax

## Requirements

- Python 3.x
- No external dependencies

## File Structure

```
spec/
├── assembler.py    # Main assembler script
├── program.asm     # Assembly source file
├── mem.txt         # Generated machine code (output)
└── README.md       # This file
```

## Notes

- Comments in assembly files start with `;`
- Instructions and registers are case-insensitive
- Each I-type, J-type, and INT instruction uses 2 memory words (instruction + immediate/address)
- R-type and most System instructions use 1 memory word
- Memory addresses are word-addressed (each address contains 32 bits)

## License

Part of the Five-Stage RISC Processor project.
