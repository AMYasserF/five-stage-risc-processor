````yaml
# ============================================================
# Five-Stage RISC Processor Design
# ============================================================

project:
  title: "**Five-Stage RISC Processor Design**"

  overview: |
    ## 📌 Project Overview
    This project implements a **custom 32-bit RISC processor** utilizing a classic
    **five-stage pipeline architecture**:

    **Fetch → Decode → Execute → Memory → Writeback**

    The design emphasizes **hardware-native execution of complex system operations**
    such as **interrupt handling, stack manipulation, and atomic register swapping**,
    removing reliance on software macros or microcode.

    The processor is fully synthesized in **VHDL** and is paired with a
    **custom Python assembler** that converts human-readable assembly code into
    executable machine instructions.

  file_structure: |
    ## 📂 Project File Structure
    ```text
    spec/
    ├── assembler.py
    ├── mem.txt

    VHDL_Files/
    ├── Fetch_Stage/
    │   ├── Program Counter (PC) logic
    │   └── Instruction Memory interfaces
    ├── Decode_Stage/
    │   ├── Control Unit
    │   ├── Register File
    │   └── Hazard Detection Unit
    ├── Execute_Stage/
    │   ├── ALU
    │   ├── Forwarding Unit
    │   └── EX/MEM pipeline registers
    ├── Memory_Stage/
    │   ├── Data Memory
    │   ├── Interrupt FSM (INT)
    │   └── Stack FSMs
    ├── Writeback_Stage/
    │   └── Writeback multiplexers
    └── Memory_System/
        ├── SP_Control_Unit
        └── Memory addressing logic
    ```

  assembler:
    description: |
      ## 🛠️ Custom Assembler (`assembler.py`)
      The custom Python assembler translates assembly mnemonics into the
      **32-bit instruction format** required by the processor.

      ### 🔹 Bit Packing Logic
      ```text
      Opcode = (hasImm << 6) | (Type << 4) | Function_Code
      Instruction =
      (Opcode << 25) | (Rd << 22) | (Rs1 << 19) | (Rs2 << 16)
      ```

      ### 🔹 Immediate Handling (`hasImm`)
      - Automatically detects instructions requiring immediates
      - Sets the `hasImm` bit (bit 6 of opcode)
      - Appends a second 32-bit word containing the immediate value
      - Outputs a `mem.txt` file where complex instructions span **two memory lines**

  pipeline:
    description: |
      ## 🧩 Pipeline Architecture

      ### 🔹 Stage 1: Fetch
      - Fetches instructions from memory using the Program Counter (PC)
      - PC source selection:
        - `PC + 1` (normal execution)
        - Branch target (Execute stage)
        - Return address (`RET / RTI`)
        - Interrupt vector (`INT`)

      ### 🔹 Stage 2: Decode
      - **Control Unit:** Generates global control signals
      - **Hazard Detection:** Inserts pipeline stalls for load-use hazards
      - **Immediate Handling:** One-cycle stall to fetch immediate word

      ### 🔹 Stage 3: Execute
      - ALU performs arithmetic and logical operations
      - Forwarding unit bypasses data from later pipeline stages

      ### 🔹 Stage 4: Memory
      - Handles data memory access (`LDD / STD`)
      - FSM-driven multi-cycle system operations:
        - Interrupts
        - Stack manipulation
        - Context switching

      ### 🔹 Stage 5: Writeback
      - Writes final results to the register file
      - Data sources:
        - ALU result
        - Memory output
        - Input ports

  complex_instructions:
    description: |
      ## ⚙️ Hardware Support for Complex Instructions

      ### 🔹 SWAP Instruction
      - Performs atomic register swapping in a **single cycle**
      - Uses a parallel datapath alongside the ALU
      - Writes both registers in the same clock edge

      ### 🔹 Interrupt Handling (`INT`)
      **FSM Sequence:**
      1. Push `PC + 1` to stack
      2. Push Condition Code Register (CCR)
      3. Load interrupt vector into PC

      ### 🔹 Return from Interrupt (`RTI`)
      - Restores CCR from stack
      - Restores PC
      - Resumes execution seamlessly

      ### 🔹 Stack Operations
      **Shared SP Control Unit**
      - `SP - 1`: PUSH, CALL, INT
      - `SP + 1`: POP, RET, RTI

  control_signals:
    description: |
      ## 🎛️ Control Signals Reference

      | Signal        | Function                                   |
      |--------------|---------------------------------------------|
      | `is_swap`     | Enables register swap datapath              |
      | `is_immediate`| Stalls pipeline for immediate handling      |
      | `int_phase`   | Controls interrupt FSM transitions          |
      | `sp_enable`   | Enables Stack Pointer updates               |
      | `mem_to_reg`  | 0 = ALU result, 1 = Memory output            |
````
