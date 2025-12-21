# Quick Start: Generic Program File Loading

## 3-Step Setup

### Step 1: Create Your Program File
Create a text file (e.g., `my_program.txt`) with 32-bit hex instructions, one per line:

```
00000002
00000000
A4400000
00001111
```

### Step 2: Place Program File in Project
Put the file in the project root directory or any accessible location:
```
five-stage-risc-processor/
├── program.txt          ← Your program here
├── VHDL_Files/
│   └── ...
└── spec/
```

### Step 3: Update Instantiation
In your testbench or Processor_Top.vhd, add generic map to Memory/Unified_Memory:

**For standalone Memory:**
```vhdl
Memory_Instance: Memory
  generic map (PROGRAM_FILE => "program.txt")
  port map (
    -- connections...
  );
```

**For Processor_Top (Unified_Memory):**
```vhdl
Unified_Mem: Unified_Memory
  generic map (PROGRAM_FILE => "program.txt")
  port map (
    -- connections...
  );
```

## File Format Details

| Feature | Details |
|---------|---------|
| Lines | One 32-bit hex per line |
| Format | `DEADBEEF` or `0xDEADBEEF` |
| Case | Case-insensitive |
| Blank Lines | Allowed (skipped) |
| Comments | Not supported |
| Max Size | 262,144 instructions |

## Path Examples

| Path | Behavior |
|------|----------|
| `"program.txt"` | Same directory as simulator |
| `"../program.txt"` | Parent directory |
| `"./programs/test.txt"` | Subdirectory |
| `"C:/full/path/prog.txt"` | Absolute path |
| `""` | No file (memory = 0) |

## Conversion from Assembly

If you have an assembly file, convert with the included assembler:

```bash
python spec/assembler.py input.asm > output.txt
```

Then use `output.txt` as your PROGRAM_FILE.

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "File not found" | Check path relative to simulator directory |
| All zeros in memory | Verify file path and format |
| Invalid hex error | Ensure each line has valid 32-bit hex |
| Empty PROGRAM_FILE param | Use `""` string to disable file loading |

## Files Created/Modified

| File | Status | Purpose |
|------|--------|---------|
| Memory.vhd | **Modified** | Added generic PROGRAM_FILE support |
| Unified_Memory.vhd | **Created** | Main memory with file loading & arbitration |
| Memory_Generic.vhd | **Created** | Alternative generic memory module |
| program.txt | **Created** | Example program file |
| PROGRAM_LOADING_GUIDE.md | **Created** | Detailed documentation |

## Running with Your Program

```tcl
# In compile_full_processor.tcl or similar:
# Make sure the PROGRAM_FILE path points to your file

# Run simulation
vsim -do run_processor_tb.tcl

# View waveforms
add wave /Processor_Top_TB/Processor/...
```

## Example Programs

Create different test files:

**test_swap.txt** - SWAP instructions
```
00000002
00000000
A4400000
00001111
```

**test_arithmetic.txt** - ADD/SUB operations
```
00000002
00000000
A4400000
00001111
```

**test_branch.txt** - Branch instructions
```
00000002
00000000
...
```

Then switch between them:
```vhdl
generic map (PROGRAM_FILE => "test_swap.txt")  -- Change filename
```

## Notes

✅ Changes are **backward compatible** - existing code still works
✅ Multiple programs tested by changing filename only
✅ No VHDL recompilation needed (simulation only)
✅ File loading happens during elaboration (instant)
✅ Maximum memory: 262K instructions (18-bit addressing)

## Support

See `PROGRAM_LOADING_GUIDE.md` for complete documentation.
