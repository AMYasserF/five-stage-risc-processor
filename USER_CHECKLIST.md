# User Checklist - Generic Program File Loading

## ✅ Quick Setup Checklist (5 minutes)

### Phase 1: Review (2 minutes)
- [ ] Read this file (you're doing it!)
- [ ] Skim **QUICK_START_PROGRAMS.md**

### Phase 2: Create Program (1 minute)
- [ ] Create `program.txt` in project root
- [ ] Add 32-bit hex instructions (one per line)
- [ ] Example format: `00000002` or `0xDEADBEEF`

### Phase 3: Update VHDL (1 minute)
- [ ] Open your testbench or Processor_Top.vhd
- [ ] Find memory instantiation (Unified_Memory or Memory)
- [ ] Add generic parameter:
  ```vhdl
  generic map (PROGRAM_FILE => "program.txt")
  ```

### Phase 4: Run Simulation (1 minute)
- [ ] Run your simulation script
- [ ] Verify program loads correctly
- [ ] Check waveforms

---

## ✅ Detailed Setup Checklist (20 minutes)

### Pre-Implementation
- [ ] Read **QUICK_START_PROGRAMS.md** (10 min)
- [ ] Review **TESTBENCH_INTEGRATION_EXAMPLE.vhd** (5 min)
- [ ] Understand file format (5 min)

### Implementation
- [ ] Create program file with your instructions
- [ ] Verify file format (hex, one per line)
- [ ] Locate memory instantiation in VHDL
- [ ] Add PROGRAM_FILE generic parameter
- [ ] Verify path is correct (relative to simulator)
- [ ] Save VHDL file

### Testing
- [ ] Compile VHDL (if needed)
- [ ] Run simulation
- [ ] Check memory[0] contains PC init value
- [ ] Verify first instruction loads correctly
- [ ] Monitor output/waveforms

### Verification
- [ ] Program runs as expected
- [ ] Results match expected behavior
- [ ] No errors in simulation log
- [ ] Waveforms show correct execution

---

## ✅ File Creation Checklist

### Create program.txt
- [ ] File created in project root
- [ ] Contains 32-bit hex instructions
- [ ] One instruction per line
- [ ] Format: `XXXXXXXX` (8 hex digits)
- [ ] Or format: `0xXXXXXXXX` (with 0x prefix)
- [ ] All lines contain valid hex
- [ ] Blank lines OK (will be skipped)
- [ ] No inline comments or text

### Example program.txt
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
00000000
00000000
00000000
0E8A0000
00000000
00000000
```

---

## ✅ VHDL Integration Checklist

### Locate Memory Instantiation
- [ ] Find Unified_Memory or Memory component instantiation
- [ ] Note the exact entity name
- [ ] Identify port map section

### Add Generic Parameter
- [ ] Insert `generic map (...)` before `port map`
- [ ] Add: `PROGRAM_FILE => "program.txt"`
- [ ] Ensure proper syntax and indentation
- [ ] Verify no syntax errors

### Example Before:
```vhdl
Unified_Mem: Unified_Memory
  port map (
    clk => clk,
    rst => rst,
    -- ... other ports ...
  );
```

### Example After:
```vhdl
Unified_Mem: Unified_Memory
  generic map (
    PROGRAM_FILE => "program.txt"
  )
  port map (
    clk => clk,
    rst => rst,
    -- ... other ports ...
  );
```

---

## ✅ Verification Checklist

### Before Running Simulation
- [ ] program.txt exists in expected location
- [ ] File contains valid hex instructions
- [ ] VHDL has PROGRAM_FILE generic parameter
- [ ] Path in PROGRAM_FILE matches file location
- [ ] VHDL compiles without errors

### During Simulation
- [ ] Simulation starts successfully
- [ ] No file-related errors in log
- [ ] Memory[0] contains expected PC init value
- [ ] Memory[1] contains expected interrupt vector
- [ ] Memory[2+] contains program instructions

### After Simulation
- [ ] Program executes as expected
- [ ] Output matches expected results
- [ ] No memory access errors
- [ ] Waveforms show correct values
- [ ] Register file updates as expected

---

## ✅ Troubleshooting Checklist

### Program Doesn't Load
- [ ] Verify program.txt exists
- [ ] Check file path in PROGRAM_FILE generic
- [ ] Confirm path is relative to simulator directory
- [ ] Use absolute path if relative doesn't work
- [ ] Check file has readable permissions

### All Memory is Zero
- [ ] Verify program.txt is not empty
- [ ] Check each line contains valid 32-bit hex
- [ ] Ensure no blank lines at start of file
- [ ] Verify PROGRAM_FILE path is correct
- [ ] Check file encoding (should be ASCII/UTF-8)

### Simulation Errors
- [ ] Check VHDL syntax around generic parameter
- [ ] Verify Memory/Unified_Memory entity supports PROGRAM_FILE
- [ ] Ensure closing parenthesis on generic map
- [ ] Check for extra commas or missing syntax

### Path Not Found
- [ ] Use absolute path (e.g., `C:/project/program.txt`)
- [ ] Use forward slashes (`/` not `\`)
- [ ] Try with `../` to go up directories
- [ ] Check current working directory of simulator
- [ ] Verify file actually exists in that location

---

## ✅ Common Tasks Checklist

### Task: Change Program
- [ ] Edit or replace program.txt
- [ ] Verify new file format is correct
- [ ] Re-run simulation (no recompilation needed)
- [ ] Verify new program loads

### Task: Use Different File Path
- [ ] Create new program file in desired location
- [ ] Update PROGRAM_FILE generic with new path
- [ ] Use relative path from simulator directory
- [ ] Or use absolute path (less portable)
- [ ] Re-run simulation

### Task: Test Multiple Programs
- [ ] Create test_1.txt, test_2.txt, test_3.txt
- [ ] For each test:
  - [ ] Update PROGRAM_FILE to test file
  - [ ] Run simulation
  - [ ] Record results
- [ ] Compare results across tests

### Task: Generate Program from Assembly
- [ ] Assemble your ASM file: `python spec/assembler.py input.asm`
- [ ] Redirect to file: `python spec/assembler.py input.asm > program.txt`
- [ ] Verify output format
- [ ] Run simulation with generated file

---

## ✅ Documentation Checklist

### First-Time Users
- [ ] Read README_GENERIC_PROGRAMS.md
- [ ] Read QUICK_START_PROGRAMS.md
- [ ] Review example program.txt
- [ ] Understand file format

### Before Integration
- [ ] Review TESTBENCH_INTEGRATION_EXAMPLE.vhd
- [ ] Understand generic parameter syntax
- [ ] Know where to add it in your code
- [ ] Plan your implementation

### For Detailed Information
- [ ] Read PROGRAM_LOADING_GUIDE.md (as needed)
- [ ] Review IMPLEMENTATION_SUMMARY.md (technical)
- [ ] Check DOCUMENTATION_INDEX.md (navigation)

---

## ✅ Final Verification Checklist

### Everything Ready?
- [ ] program.txt created and formatted correctly
- [ ] VHDL updated with PROGRAM_FILE generic
- [ ] Path in generic matches file location
- [ ] Simulation compiles without errors
- [ ] Memory loads program as expected
- [ ] Program executes correctly
- [ ] Results match expectations

### Ready for Production?
- [ ] All tests pass
- [ ] Program behavior verified
- [ ] Output correct
- [ ] No simulation errors
- [ ] Documentation reviewed
- [ ] Team aware of new system
- [ ] Process documented for others

---

## 📊 Progress Tracker

### Setup Progress
```
Start → Phase 1 → Phase 2 → Phase 3 → Phase 4 → Complete
 0%      25%      50%      75%      90%      100% ✅
```

### Time Estimates
| Phase | Time | Status |
|-------|------|--------|
| Review | 2 min | ⏱️ |
| Create | 1 min | ⏱️ |
| Update | 1 min | ⏱️ |
| Run | 1 min | ⏱️ |
| **Total** | **5 min** | **⏱️** |

---

## 🎯 Success Criteria

### ✅ Success When:
- [ ] program.txt loads without errors
- [ ] Memory[0] contains PC init value
- [ ] Memory[2+] contains program instructions
- [ ] Simulation runs without errors
- [ ] Program executes as expected
- [ ] Waveforms show correct behavior

### 🎉 You're Done When:
- [ ] Everything above is checked
- [ ] You've tested with at least one program
- [ ] Results match expectations
- [ ] No questions remain

---

## 💡 Pro Tips

### Tip 1: Path Management
- Use relative paths from simulator directory
- Use `../` to go up one level
- Use absolute paths if relative doesn't work
- Forward slashes work on all platforms (`/` not `\`)

### Tip 2: File Format
- Can mix hex formats: `DEAD`, `dead`, `0xDEAD`
- All formats case-insensitive
- Blank lines automatically skipped
- One instruction per line only

### Tip 3: Testing
- Test with example program first
- Then create your own program
- Change programs by editing PROGRAM_FILE only
- No VHDL recompilation needed for program changes

### Tip 4: Debugging
- Check memory[0] first (PC init value)
- Verify memory[2] has first instruction
- Monitor register file changes
- Use waveforms to trace execution

### Tip 5: Multiple Programs
- Keep different program files
- Switch between them by changing PROGRAM_FILE
- Document what each program tests
- Automate with TCL scripts for batch testing

---

## 🚀 Next Steps After Setup

1. **Immediate** (after first program works)
   - [ ] Test with 2-3 different programs
   - [ ] Verify each loads correctly
   - [ ] Document results

2. **Short Term** (first week)
   - [ ] Create library of test programs
   - [ ] Document test procedures
   - [ ] Share with team
   - [ ] Train others on new system

3. **Medium Term** (first month)
   - [ ] Automate test execution
   - [ ] Integrate with CI/CD if applicable
   - [ ] Gather feedback
   - [ ] Optimize process

---

## 📞 Help & Support

### For Quick Help
1. Check **QUICK_START_PROGRAMS.md**
2. Review your specific checklist above
3. Verify file format and paths

### For Integration Help
1. Read **TESTBENCH_INTEGRATION_EXAMPLE.vhd**
2. Compare with your VHDL code
3. Check syntax carefully

### For Technical Questions
1. Review **PROGRAM_LOADING_GUIDE.md**
2. Check **IMPLEMENTATION_SUMMARY.md**
3. See **DOCUMENTATION_INDEX.md** for navigation

---

## ✨ Final Notes

**Remember**:
- This is a simple 3-step process
- No VHDL knowledge needed for basic use
- File loading is automatic
- Zero overhead once loaded
- Fully backward compatible

**You've got this!** 🎉

---

## Checklist Version

| Item | Value |
|------|-------|
| Checklist Version | 1.0 |
| Date Created | December 21, 2025 |
| Last Updated | December 21, 2025 |
| Status | Ready ✅ |

---

**Print this page and check off items as you complete them!**
