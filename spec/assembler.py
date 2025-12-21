# =====================================
# FULL ISA ASSEMBLER
# R / I / J / SYSTEM-STACK
# Supports hex numbers, .ORG directive, comments
# =====================================

import re
import sys

# ------------ R TYPE -----------------
R_TYPE_FUNCS = {
    "NOP":0b0000, "SETC":0b0001, "NOT":0b0010, "INC":0b0011,
    "OUT":0b0100, "IN":0b0101, "MOV":0b0110, "SWAP":0b0111,
    "ADD":0b1000, "SUB":0b1001, "AND":0b1010
}

# ------------ I TYPE -----------------
I_TYPE_FUNCS = {
    "IADD":0b0001,"LDM":0b0010,"LDD":0b0011,"STD":0b0100
}

# ------------ J TYPE -----------------
J_TYPE_FUNCS = {
    "JMP":0b0001,"JZ":0b0010,"JN":0b0011,"JC":0b0100,"CALL":0b0101,"RET":0b0110
}

# ------------ SYSTEM STACK ----------
SYS_FUNCS = {
    "PUSH":0b0001,"POP":0b0010,
    "INT":0b0011,"RTI":0b0100,"HLT":0b0101
}

# ------------------------------------

def reg(r):
    """Parse register name like R0-R7"""
    r = r.upper().strip()
    if r.startswith("R"):
        n = int(r[1:])
        if 0 <= n <= 7:
            return n
    raise ValueError("Invalid Register: " + r)

def parse_hex(s):
    """Parse a hex number (without 0x prefix by default)"""
    s = s.strip()
    # Remove optional 0x prefix
    if s.lower().startswith("0x"):
        return int(s, 16)
    # Try to parse as hex first (since all numbers in hex format per spec)
    try:
        return int(s, 16)
    except ValueError:
        # Fallback to decimal if it looks decimal
        return int(s, 10)

def parse_offset_reg(operand):
    """
    Parse operand formats like:
    - "50(R0)" -> (50, "R0")
    - "0(R4)" -> (0, "R4")
    Returns (offset, register_name)
    """
    match = re.match(r'([0-9A-Fa-f]+)\((\w+)\)', operand.strip())
    if match:
        offset = parse_hex(match.group(1))
        reg_name = match.group(2)
        return offset, reg_name
    raise ValueError(f"Invalid offset(reg) format: {operand}")

# ------------------------------------

def build_opcode(hasImm, typ, func):
    return (hasImm << 6) | (typ << 4) | func

def inst_word(op, rd=0, rs1=0, rs2=0):
    return (op << 25) | (rd << 22) | (rs1 << 19) | (rs2 << 16)

# ------------------------------------

def assemble(lines):
    """
    Assemble source lines into memory image.
    Returns a dictionary: address -> value
    """
    mem = {}
    current_addr = 0

    for line_num, ln in enumerate(lines, 1):
        # Remove comments (both # and ; style)
        ln = ln.split('#')[0].split(';')[0].strip()
        
        # Skip empty lines
        if not ln:
            continue

        # Handle .ORG directive - address is in DECIMAL
        if ln.upper().startswith('.ORG'):
            parts = ln.split()
            if len(parts) >= 2:
                # .ORG addresses are decimal for ease of use
                current_addr = int(parts[1], 10)
            continue

        # Check if line is just a raw number (data value like reset address)
        # These are addresses/vectors - also interpreted as DECIMAL
        tokens = ln.replace(",", " ").split()
        if len(tokens) == 1:
            try:
                # Data values (like reset vector) are decimal addresses
                val = int(tokens[0], 10)
                mem[current_addr] = val & 0xffffffff
                current_addr += 1
                continue
            except ValueError:
                pass  # Not a number, continue to instruction parsing

        ins = tokens[0].upper()

        # ---------------- R TYPE ----------------
        if ins in R_TYPE_FUNCS:
            op = build_opcode(0, 0b00, R_TYPE_FUNCS[ins])

            if ins in ["NOP", "SETC"]:
                rd = rs1 = rs2 = 0

            elif ins in ["NOT", "INC"]:
                rd = reg(tokens[1])
                rs1 = rd
                rs2 = 0

            elif ins == "OUT":
                rd = 0
                rs1 = reg(tokens[1])
                rs2 = 0

            elif ins == "IN":
                rd = reg(tokens[1])
                rs1 = 0
                rs2 = 0

            elif ins == "MOV":
                rs1 = reg(tokens[1])
                rd = reg(tokens[2])
                rs2 = 0

            elif ins == "SWAP":
                rs1 = reg(tokens[1])
                rd = reg(tokens[2])
                rs2 = rd

            else:  # ADD, SUB, AND
                rd = reg(tokens[1])
                rs1 = reg(tokens[2])
                rs2 = reg(tokens[3])

            mem[current_addr] = inst_word(op, rd, rs1, rs2)
            current_addr += 1

        # ---------------- I TYPE ----------------
        elif ins in I_TYPE_FUNCS:
            op = build_opcode(1, 0b01, I_TYPE_FUNCS[ins])

            if ins == "IADD":
                # IADD R5, R3, 2 -> R5 = R3 + imm
                rd = reg(tokens[1])
                rs1 = reg(tokens[2])
                rs2 = 0
                imm = parse_hex(tokens[3])

            elif ins == "LDM":
                # LDM R2, 10FE19 -> R2 = imm
                rd = reg(tokens[1])
                rs1 = rs2 = 0
                imm = parse_hex(tokens[2])

            elif ins == "LDD":
                # LDD R3, 51(R0) -> R3 = M[R0 + 51]
                rd = reg(tokens[1])
                imm, base_reg = parse_offset_reg(tokens[2])
                rs1 = reg(base_reg)
                rs2 = 0

            elif ins == "STD":
                # STD R2, 50(R0) -> M[R0 + 50] = R2
                src_reg = reg(tokens[1])
                imm, base_reg = parse_offset_reg(tokens[2])
                rd = 0
                rs1 = src_reg
                rs2 = reg(base_reg)

            # Write instruction word
            if ins == "STD":
                # STD: swap so base register goes to rs1 position
                mem[current_addr] = inst_word(op, rd, rs2, rs1)
            else:
                mem[current_addr] = inst_word(op, rd, rs1, rs2)
            current_addr += 1
            
            # Write immediate value
            mem[current_addr] = imm & 0xffffffff
            current_addr += 1

        # ---------------- J TYPE ----------------
        elif ins in J_TYPE_FUNCS:
            if ins == "RET":
                op = build_opcode(0, 0b10, J_TYPE_FUNCS[ins])  # hasImm=0 for RET
                mem[current_addr] = inst_word(op)
                current_addr += 1
            else:
                op = build_opcode(1, 0b10, J_TYPE_FUNCS[ins])  # hasImm=1 for others
                target = parse_hex(tokens[1])
                mem[current_addr] = inst_word(op)
                current_addr += 1
                mem[current_addr] = target & 0xffffffff
                current_addr += 1

        # ---------------- SYSTEM STACK ----------
        elif ins in SYS_FUNCS:
            needImm = (ins == "INT")
            op = build_opcode(1 if needImm else 0, 0b11, SYS_FUNCS[ins])

            if ins in ["RTI", "HLT"]:
                rd = rs1 = rs2 = 0

            elif ins == "PUSH":
                rd = 0
                rs1 = reg(tokens[1])
                rs2 = 0

            elif ins == "POP":
                rd = reg(tokens[1])
                rs1 = 0
                rs2 = 0

            elif ins == "INT":
                rd = rs1 = rs2 = 0
                imm = parse_hex(tokens[1])

            mem[current_addr] = inst_word(op, rd, rs1, rs2)
            current_addr += 1

            if needImm:
                mem[current_addr] = imm & 0xffffffff
                current_addr += 1

        else:
            raise ValueError(f"Line {line_num}: Unknown instruction '{ins}'")

    return mem

# ------------------------------------

def write_mem(mem, filename="mem.txt"):
    """
    Write memory to file in binary format.
    Format: one 32-bit binary value per line
    Fills gaps with zeros
    """
    if not mem:
        print("Warning: Empty program!")
        return
    
    max_addr = max(mem.keys())
    
    with open(filename, "w") as f:
        for addr in range(max_addr + 1):
            val = mem.get(addr, 0)
            f.write(f"{val:032b}\n")

    print(f"✅ {filename} generated ({max_addr + 1} words)")

def write_mem_hex(mem, filename="mem_hex.txt"):
    """
    Write memory to file in hex format with addresses (for debugging)
    """
    if not mem:
        return
    
    max_addr = max(mem.keys())
    
    with open(filename, "w") as f:
        for addr in range(max_addr + 1):
            val = mem.get(addr, 0)
            f.write(f"{addr:04X}: {val:08X}\n")

    print(f"✅ {filename} generated (hex debug format)")

# ------------------------------------

if __name__ == "__main__":
    # Determine input file
    if len(sys.argv) > 1:
        input_file = sys.argv[1]
    else:
        input_file = "program.asm"
    
    print(f"Assembling: {input_file}")
    
    try:
        with open(input_file, encoding="utf8") as f:
            asm = f.readlines()
    except FileNotFoundError:
        print(f"Error: File '{input_file}' not found!")
        sys.exit(1)

    try:
        mc = assemble(asm)
        write_mem(mc)
        write_mem_hex(mc)
        
        print("✅ FULL ISA ASSEMBLE DONE")
        print(f"✅ TOTAL WORDS = {max(mc.keys()) + 1 if mc else 0}")
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)
