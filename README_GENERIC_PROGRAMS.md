# Generic Program File Loading - README

## 📋 Summary

The RISC processor has been successfully enhanced to **read programs from text files** instead of hardcoded memory arrays. This allows you to:

- ✅ Load any program without modifying VHDL code
- ✅ Test multiple programs by changing filenames only
- ✅ Use the existing assembler output directly
- ✅ Maintain backward compatibility with existing code
- ✅ Simplify program development and testing workflows

## 🎯 What You Get

### New Modules
- **Unified_Memory.vhd** - Main memory module with file loading
- **Memory_Generic.vhd** - Alternative generic memory module
- **program.txt** - Example program file (SWAP test)

### Updated Files
- **Memory.vhd** - Enhanced with generic file loading support

### Documentation
- **PROGRAM_LOADING_GUIDE.md** - Comprehensive technical guide
- **QUICK_START_PROGRAMS.md** - Quick reference for users
- **TESTBENCH_INTEGRATION_EXAMPLE.vhd** - Code integration examples
- **IMPLEMENTATION_SUMMARY.md** - Detailed implementation notes
- **run_with_program.tcl** - Example simulation script
- **README.md** (this file) - Overview and quick start

## 🚀 Quick Start (3 Steps)

### Step 1: Create Your Program File

Create a text file (e.g., `my_program.txt`):
```
00000002
00000000
A4400000
00001111
00000000
```

**Format**: One 32-bit hex instruction per line

### Step 2: Place in Project

Put the file in your project root:
```
five-stage-risc-processor/
├── my_program.txt          ← Your program
├── VHDL_Files/
└── spec/
```

### Step 3: Update VHDL Instantiation

In your testbench or Processor_Top.vhd:

```vhdl
Unified_Mem: Unified_Memory
  generic map (PROGRAM_FILE => "my_program.txt")
  port map (
    clk => clk,
    rst => rst,
    -- ... other connections ...
  );
```

That's it! 🎉

## 📁 File Locations

### New Files Created
```
VHDL_Files/Memory_System/
├── Unified_Memory.vhd        ← Main unified memory module
├── Memory_Generic.vhd        ← Alternative generic memory
└── Memory.vhd                ← Enhanced (modified)

VHDL_Files/
└── run_with_program.tcl      ← Example simulation script

Project Root/
├── program.txt               ← Example program file
├── PROGRAM_LOADING_GUIDE.md
├── QUICK_START_PROGRAMS.md
├── TESTBENCH_INTEGRATION_EXAMPLE.vhd
├── IMPLEMENTATION_SUMMARY.md
└── README.md                 ← This file
```

## 📖 Documentation Guide

| Document | Purpose | Audience |
|----------|---------|----------|
| **QUICK_START_PROGRAMS.md** | Get started in 3 steps | All users |
| **PROGRAM_LOADING_GUIDE.md** | Complete technical reference | Advanced users |
| **TESTBENCH_INTEGRATION_EXAMPLE.vhd** | Code examples for integration | VHDL developers |
| **IMPLEMENTATION_SUMMARY.md** | Technical implementation details | System integrators |
| **run_with_program.tcl** | TCL script example | Simulation users |
| **README.md** | This overview | Everyone |

### Recommended Reading Order
1. **README.md** (this file) - 5 minutes
2. **QUICK_START_PROGRAMS.md** - 10 minutes
3. **TESTBENCH_INTEGRATION_EXAMPLE.vhd** - 10 minutes (if using code)
4. **PROGRAM_LOADING_GUIDE.md** - As needed for details

## 🔧 How It Works

### File Loading Process
```
VHDL Elaboration
    ↓
Load PROGRAM_FILE (if specified)
    ↓
Parse hex from each line
    ↓
Store in memory array
    ↓
Close file
    ↓
Simulation Begins (program ready to execute)
```

### Key Points
- ⚡ Loading happens during elaboration (before simulation)
- 🔒 Zero runtime overhead
- 📁 Supports relative and absolute paths
- 🛡️ Backward compatible (empty PROGRAM_FILE = no file loading)

## 💡 Use Cases

### Use Case 1: Test Multiple Programs
```bash
# Switch programs without recompilation
cp test_swap.txt program.txt
vsim -do run_processor_tb.tcl

cp test_arithmetic.txt program.txt
vsim -do run_processor_tb.tcl

cp test_branch.txt program.txt
vsim -do run_processor_tb.tcl
```

### Use Case 2: Integration with Assembler
```bash
# Generate hex from assembly
python spec/assembler.py my_asm_program.asm > program.txt

# Run simulation with generated program
vsim -do run_processor_tb.tcl
```

### Use Case 3: Automated Testing
```bash
# Test multiple programs programmatically
for prog in programs/*.txt; do
    cp $prog program.txt
    vsim -do run_processor_tb.tcl
done
```

### Use Case 4: Different Test Variants
```bash
# Create testbenches for different programs
# Each with different PROGRAM_FILE generic
test_swap_tb.vhd     → PROGRAM_FILE => "test_swap.txt"
test_arith_tb.vhd    → PROGRAM_FILE => "test_arith.txt"
test_branch_tb.vhd   → PROGRAM_FILE => "test_branch.txt"
```

## 📝 Program File Format

### Format Specification
| Aspect | Details |
|--------|---------|
| **Lines** | One 32-bit hex instruction per line |
| **Hex Format** | `DEADBEEF` or `0xDEADBEEF` |
| **Case** | Case-insensitive (deadbeef works) |
| **Blank Lines** | Allowed (skipped) |
| **Comments** | Not supported |
| **Max Instructions** | 262,144 (18-bit addressing) |

### Valid Examples
```
A4400000          ✅ Uppercase hex
A4400000          ✅ Uppercase hex with spaces
a4400000          ✅ Lowercase hex
0xA4400000        ✅ With 0x prefix
0xa4400000        ✅ With 0x prefix, lowercase

                  ✅ Blank lines (ignored)
A4400000          ✅ Mix of formats
0xa4400000        ✅ in same file
```

### Invalid Examples
```
A4400000 ; comment ❌ Inline comments not supported
A44 0000           ❌ Space in middle
0xA4400000 extra   ❌ Extra characters
```

## 🔗 Integration with Existing Code

### No Breaking Changes ✅
- Old testbenches continue to work unchanged
- Generic parameter is optional (defaults to `""`)
- Memory.vhd backward compatible
- Existing VHDL files don't need modification

### Optional Integration
```vhdl
-- Old style (still works)
Unified_Mem: Unified_Memory
  port map (clk => clk, ...);

-- New style (with file)
Unified_Mem: Unified_Memory
  generic map (PROGRAM_FILE => "program.txt")
  port map (clk => clk, ...);
```

## 📊 Memory Organization

```
Memory Address    Contents           Purpose
═══════════════════════════════════════════════════
0x00000 (0)       PC init value      Where to start execution
0x00001 (1)       Interrupt vector   Interrupt handler address
0x00002 (2)       Instruction 1      Program starts here
0x00003 (3)       Instruction 2
0x00004 (4)       Instruction 3
...
0x3FFFF (262143)  Last location      Max addressable memory

Max Memory: 262,144 words × 32 bits/word = 8 MB
```

## 🛠️ Common Tasks

### Task 1: Load a Program
```vhdl
-- In testbench
Unified_Mem: Unified_Memory
  generic map (PROGRAM_FILE => "my_program.txt")
  port map (...);
```

### Task 2: Switch Programs
```bash
# Before simulation
mv program_old.txt program_old.txt.bak
mv program_new.txt program.txt
vsim -do run_processor_tb.tcl
```

### Task 3: Generate Program from Assembly
```bash
python spec/assembler.py input.asm > program.txt
vsim -do run_processor_tb.tcl
```

### Task 4: Use Different Path
```vhdl
generic map (PROGRAM_FILE => "../programs/test1.txt")
generic map (PROGRAM_FILE => "C:/Projects/test2.txt")
generic map (PROGRAM_FILE => "./subdir/test3.txt")
```

### Task 5: Disable File Loading
```vhdl
generic map (PROGRAM_FILE => "")  -- Memory initialized to zeros
```

## ⚠️ Important Notes

### File Paths
- Relative to simulator working directory (usually VHDL_Files/)
- Use `..` to go up directories: `"../program.txt"`
- Absolute paths work but reduce portability

### Memory Size
- Maximum 262,144 instructions (18-bit addresses)
- Programs exceeding this size will be truncated
- Stack and data share memory space

### Error Handling
- Missing files don't crash (memory initialized to 0)
- Invalid hex causes simulation warnings
- No built-in validation or checksums

### Performance
- Zero impact on simulation speed
- File loading is elaboration-time only
- Memory acts identical to hardcoded arrays

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| "File not found" | Verify path relative to simulator directory |
| All zeros in memory | Check PROGRAM_FILE path and file exists |
| Simulation hangs | Ensure program terminates with HLT instruction |
| Hex parse error | Verify each line has valid 32-bit hex |
| Path with spaces | Use quotes and proper path separators |

See **PROGRAM_LOADING_GUIDE.md** for detailed troubleshooting.

## 📚 Additional Resources

- **Assembler**: `spec/assembler.py` - Convert ASM to hex format
- **Example Programs**: Various `.txt` files in project root
- **VHDL Source**: All memory modules in `VHDL_Files/Memory_System/`
- **Test Scripts**: `*.tcl` files in `VHDL_Files/`

## ✨ Key Features Summary

| Feature | Benefit |
|---------|---------|
| Generic file loading | Load any program without VHDL changes |
| Flexible paths | Works with relative and absolute paths |
| Hex format support | Direct output from assembler tools |
| Case insensitive | Any hex case works (DEAD, dead, DeAd) |
| Backward compatible | No impact on existing code |
| Simple API | Just one generic parameter |
| No overhead | Zero runtime performance impact |
| Error tolerant | Missing files don't crash simulation |
| Well documented | Multiple guides for different needs |

## 🎓 Learning Path

**Beginner** (New to system):
1. Read this README
2. Follow QUICK_START_PROGRAMS.md
3. Create first program.txt
4. Run example simulation

**Intermediate** (Using in project):
1. Read PROGRAM_LOADING_GUIDE.md
2. Review TESTBENCH_INTEGRATION_EXAMPLE.vhd
3. Integrate generic parameter into your testbench
4. Create custom program files
5. Automate testing with TCL scripts

**Advanced** (Extending system):
1. Study IMPLEMENTATION_SUMMARY.md
2. Review Unified_Memory.vhd source code
3. Understand file I/O implementation
4. Consider enhancements (validation, checksums, etc.)

## 📞 Support

For detailed information:
- **Quick questions**: Check QUICK_START_PROGRAMS.md
- **Technical details**: See PROGRAM_LOADING_GUIDE.md
- **Code examples**: Review TESTBENCH_INTEGRATION_EXAMPLE.vhd
- **Implementation**: Read IMPLEMENTATION_SUMMARY.md

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-12-21 | Initial implementation |

---

**Summary**: You now have a fully functional, generic program loading system. Start with QUICK_START_PROGRAMS.md and refer to other guides as needed. Happy simulating! 🚀
