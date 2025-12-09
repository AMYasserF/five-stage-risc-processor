# Assembler Specification

This document defines the rules, formats, and behavior of the assembler used to translate assembly source code into machine code for the processor. The assembler outputs a memory image consisting of 32-bit words, where instructions may occupy one or two words depending on their opcode.

---

## 1. Overview

The assembler converts human-readable assembly instructions into machine-readable 32-bit instruction words. Instructions fall into two categories:

* **1-word instructions** — operations that do not require an immediate value.
* **2-word instructions** — operations that require a successor immediate word (opcode bit 6 = 1).

The assembler must also resolve labels, compute instruction addresses, and emit the correct number of words for each instruction.

---

## 2. Instruction Word Format (32-bit)

All instructions occupy exactly one 32-bit instruction word. Some instructions emit a second 32-bit word containing an immediate.

### 2.1 Instruction Word Layout

```
31           25 24    22 21    19 18    16 15               0
+---------------+--------+--------+--------+-----------------+
|   OPCODE(7)   |  Rdst  | Rsrc1  | Rsrc2  |    RESERVED     |
+---------------+--------+--------+--------+-----------------+
```

### 2.2 Opcode Structure

The 7-bit opcode is divided into:

* **Bit 6 — Immediate Flag**

  * `1` → instruction requires a successor immediate word.
  * `0` → instruction is a single-word instruction.
* **Bits 5–0 — Base Opcode**

  * Encodes the actual operation (ADD, LDM, JZ, etc.).

---

## 3. One-Word Instructions

Instructions with **opcode[6] = 0** produce a single instruction word.

Example:

```
ADD R1, R2, R3
```

Produces:

* Instruction word only.
* No successor immediate.

The assembler encodes:

* opcode (7 bits)
* Rdst, Rsrc1, Rsrc2 (each 3 bits)
* reserved bits set to zero

---

## 4. Two-Word Instructions

Instructions with **opcode[6] = 1** produce:

1. **Instruction word** (same format as above)
2. **Immediate word** — a 32-bit literal, offset, address, or label value

Examples include:

* `LDM R1, imm`
* `IADD R3, R2, imm`
* `LDD R4, [R2 + imm]`
* `STD R3, [R1 + imm]`
* `JZ label`
* `CALL func`
* `INT vector`

The assembler ensures that the immediate value occupies the memory location immediately following the instruction.

---

## 5. Label Addressing (Word-Addressed)

Labels map to **word addresses**, not byte addresses.

The assembler scans the program and calculates the address of each label based on the total number of words emitted so far.

Example program:

```
start:
    LDM R1, 5     ; 2 words
    JZ end        ; 2 words
loop:
    INC R1        ; 1 word
    JMP loop      ; 2 words
end:
    HLT           ; 1 word
```

Address assignments:

| Label | Word Address |
| ----- | ------------ |
| start | 0            |
| loop  | 4            |
| end   | 7            |

---

## 6. Encoding Examples

### 6.1 LDM Example

```
LDM R1, 5
```

Produces:

* Word 1: instruction word (opcode=1000001, Rdst=1)
* Word 2: immediate = 5

---

### 6.2 IADD Example

```
IADD R3, R2, -10
```

Produces:

* Word 1: opcode=1000000, Rdst=3, Rsrc1=2
* Word 2: 32-bit signed immediate −10

---

### 6.3 JZ label

```
JZ loop
```

Produces:

* Word 1: branch instruction
* Word 2: label address (word index of `loop`)

---

### 6.4 LDD Example

```
LDD R4, [R2 + 20]
```

Produces:

* Word 1: opcode=1000010, Rdst=4, Rsrc1=2
* Word 2: immediate=20

---

### 6.5 CALL Example

```
CALL func
```

Produces:

* Word 1: call instruction
* Word 2: address of `func`

---

## 7. Output Format

The assembler produces a memory image file containing 32-bit words in order. Each line corresponds to one memory word (word-addressed).

Example output:

```
0x82400000
0x00000005
0x80D00000
0xFFFFFFF6
...
```

---

## 8. Summary

The assembler:

* Encodes instructions according to the fixed 32-bit format.
* Emits successor immediate words whenever opcode[6] = 1.
* Computes label addresses based on word addressing.
* Supports symbolic immediates and register names.

This specification ensures consistent machine code generation compatible with the processor's decode and execution stages.
