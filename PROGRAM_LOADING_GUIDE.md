# Generic Program File Loading System

## Overview
The RISC processor has been enhanced to support generic program loading from text files instead of hardcoded instructions. This allows you to run different programs without modifying VHDL code.

## File Format

### Program File (`.txt`)
- **Format**: One 32-bit hexadecimal instruction per line
- **Encoding**: Either `DEADBEEF` or `0xDEADBEEF` format (both accepted)
- **Case**: Case-insensitive (deadbeef, DEADBEEF, DeAdBeEf all work)
- **Blank lines**: Ignored automatically
- **Comments**: Not supported; each line must contain a valid instruction

### Example Program File
```
00000002
00000000
A4400000
00001111
00000000
00000000
00000000
A4800000
00002222
```

## Components Modified/Created

### 1. **Memory.vhd** (Enhanced)
- **Location**: `VHDL_Files/Memory_System/Memory.vhd`
- **Change**: Added generic parameter `PROGRAM_FILE` (optional)
- **Feature**: Loads program from text file if `PROGRAM_FILE` is specified
- **Backward Compatible**: If `PROGRAM_FILE` is empty or not specified, memory initializes to zeros (original behavior)

### 2. **Memory_Generic.vhd** (New)
- **Location**: `VHDL_Files/Memory_System/Memory_Generic.vhd`
- **Purpose**: Alternative Memory module with explicit file loading focus
- **Usage**: Use when you want file loading to be mandatory/clear in configuration

### 3. **Unified_Memory.vhd** (New)
- **Location**: `VHDL_Files/Memory_System/Unified_Memory.vhd`
- **Purpose**: Unified instruction/data memory with file loading support
- **Features**:
  - Loads program from file on initialization
  - Handles memory access arbitration between Fetch and Memory stages
  - Provides PC initialization from memory[0]

### 4. **program.txt** (Example)
- **Location**: Root of the project
- **Contents**: Example SWAP test program (64 lines of hex instructions)

## How to Use

### Option 1: Using Generic Parameter in Testbench
```vhdl
-- In your testbench, instantiate Memory with generic:
Memory_Instance: Memory
  generic map (
    PROGRAM_FILE => "path/to/program.txt"  -- Relative or absolute path
  )
  port map (
    clk => clk,
    mem_read => mem_read,
    mem_write => mem_write,
    hlt => hlt,
    address => address,
    write_data => write_data,
    read_data => read_data
  );
```

### Option 2: Using Unified_Memory (Recommended)
If using the full processor (Processor_Top.vhd), modify the instantiation:
```vhdl
Unified_Mem: Unified_Memory
  generic map (
    PROGRAM_FILE => "../program.txt"  -- Path relative to simulation directory
  )
  port map (
    -- ... port connections ...
  );
```

### Option 3: Creating a Custom Program
1. Create a text file with your program (one 32-bit hex instruction per line)
2. Save it in the project root or a known location
3. Specify the path in the generic parameter when instantiating the memory module

## Path Handling

### Relative Paths
- Relative to the directory where simulation is running
- Usually `VHDL_Files/` directory when running from `compile_full_processor.tcl`
- Use `../program.txt` to go up one directory level

### Absolute Paths
- Full path from root, e.g., `C:/Project/program.txt`
- Works from any location but less portable

### Examples:
```
PROGRAM_FILE => "program.txt"           -- Same directory as executable
PROGRAM_FILE => "../program.txt"        -- One level up
PROGRAM_FILE => "./subdir/prog.txt"     -- In subdirectory
PROGRAM_FILE => ""                      -- No file (memory initializes to 0)
```

## Memory Layout

Memory is organized as:
- **Total Size**: 262,144 words (18-bit address space = 2^18)
- **Word Size**: 32 bits
- **Address Range**: 0x00000 to 0x3FFFF

### Typical Program Layout:
- **Address 0**: PC initialization value (usually points to program start)
- **Address 1**: Interrupt vector (address to jump to on external interrupt)
- **Address 2+**: Program instructions

Example:
```
Memory[0] = 0x00000002  ; PC starts at address 2
Memory[1] = 0x00000100  ; Interrupt vector (optional)
Memory[2] = 0xA4400000  ; First instruction (LDM R1, #0x1111)
Memory[3] = 0x00001111  ; Immediate operand
...
```

## File I/O Implementation Details

### VHDL File Operations Used
- `STD.textio` library for file handling
- `IEEE.std_logic_textio` for `hread()` function
- File opening in read mode during initialization
- Automatic file closing after loading

### Error Handling
- Non-existent files are silently ignored (memory remains zero-initialized)
- Invalid hex values cause synthesis/simulation warnings
- Empty PROGRAM_FILE parameter disables file loading

### Simulation Note
- File loading occurs during elaboration (before simulation starts)
- File paths are resolved relative to the simulator's working directory
- When using ModelSim/Questa, simulate from VHDL_Files directory or adjust paths accordingly

## Advantages

✅ **Flexibility**: Load any program without recompiling VHDL
✅ **Portability**: Easy to share programs between team members
✅ **Development**: Quickly test multiple programs
✅ **Debugging**: Program text is human-readable and editable
✅ **Automation**: Can generate program files from Python/scripting tools
✅ **Backward Compatible**: Existing code still works without changes

## Example Workflow

1. **Generate program with assembler.py**:
   ```bash
   python spec/assembler.py my_program.asm > program.txt
   ```

2. **Update testbench generic** (if needed):
   ```vhdl
   PROGRAM_FILE => "program.txt"
   ```

3. **Run simulation**:
   ```tcl
   vsim -do run_processor_tb.tcl
   ```

4. **Observe results** in waveform viewer

## Architecture Integration

The file loading system integrates with:
- **Fetch Stage**: Reads instructions from memory at program counter addresses
- **Memory Stage**: Reads/writes data; both share unified memory
- **Interrupt Handling**: Reads interrupt vector from memory[1]
- **Stack Operations**: PUSH/POP/CALL/RET use memory for stack

## Testing

Example test with multiple programs:
```bash
# Test 1: SWAP operations
cp test1.txt program.txt
vsim -do run_processor_tb.tcl

# Test 2: Arithmetic operations
cp test2.txt program.txt
vsim -do run_processor_tb.tcl

# Test 3: Branch predictions
cp test3.txt program.txt
vsim -do run_processor_tb.tcl
```

## Limitations

- One program per simulation run
- File must contain valid hex values
- Maximum 262,144 instructions (memory size constraint)
- No built-in checksum or validation
- Comments not supported in program files

## Future Enhancements

- [ ] Support for program labels/symbols in files
- [ ] Inline comments in program files
- [ ] Multiple file sections (code, data, stack)
- [ ] Program validation before loading
- [ ] Memory dump functionality for debugging
