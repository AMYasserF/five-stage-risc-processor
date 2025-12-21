# =====================================
# FULL ISA ASSEMBLER (FIXED)
# Supports: R / I / J / SYSTEM-STACK
# Fixed: Instruction priority and INTx shorthand
# =====================================

import re
import sys

# ------------ Opcode Map (Opcodes preserved per requirement) ------------
R_TYPE_FUNCS = {
    "NOP":0b0000, "SETC":0b0001, "NOT":0b0010, "INC":0b0011,
    "OUT":0b0100, "IN":0b0101, "MOV":0b0110, "SWAP":0b0111,
    "ADD":0b1000, "SUB":0b1001, "AND":0b1010
}

I_TYPE_FUNCS = {
    "IADD":0b0001,"LDM":0b0010,"LDD":0b0011,"STD":0b0100
}

J_TYPE_FUNCS = {
    "JMP":0b0001,"JZ":0b0010,"JN":0b0011,"JC":0b0100,"CALL":0b0101,"RET":0b0110
}

SYS_FUNCS = {
    "PUSH":0b0001,"POP":0b0010,
    "INT":0b0011,"RTI":0b0100,"HLT":0b0101
}

# ---------------- Helper Functions ----------------

def reg(r):
    """Parses register strings like 'R1' to integer index 1."""
    r = r.upper().strip().replace(",", "")
    if r.startswith("R"):
        try:
            n = int(r[1:])
            if 0 <= n <= 7:
                return n
        except ValueError:
            pass
    raise ValueError(f"Invalid Register format: {r}")

def parse_hex(s):
    """Parses hex strings to integers. All numbers are hex per spec."""
    s = s.strip().lower()
    if s.startswith("0x"):
        return int(s, 16)
    return int(s, 16)

def build_opcode(hasImm, typ, func):
    """Builds the 7-bit opcode field: [hasImm(1 bit) | Type(2 bits) | Func(4 bits)]."""
    return (hasImm << 6) | (typ << 4) | func

def inst_word(op, rd=0, rs1=0, rs2=0):
    """Constructs the first 32-bit instruction word (upper 16 bits used)."""
    return (op << 25) | (rd << 22) | (rs1 << 19) | (rs2 << 16)

# ---------------- Main Assembler Logic ----------------

def assemble(lines):
    mem = {}
    current_addr = 0

    for line_num, ln in enumerate(lines, 1):
        # 1. Pre-process: Strip comments and whitespace
        ln = ln.split('#')[0].split('//')[0].split(';')[0].strip()
        if not ln:
            continue

        # 2. Handle .ORG directive
        if ln.upper().startswith('.ORG'):
            parts = ln.split()
            if len(parts) < 2:
                raise ValueError(f"Line {line_num}: Missing .ORG address")
            current_addr = parse_hex(parts[1])
            continue

        # 3. Tokenize
        tokens = ln.replace(",", " ").split()
        ins = tokens[0].upper()

        # 4. Handle INTx Shorthand (e.g., INT0 -> INT 0)
        if ins.startswith("INT") and len(ins) > 3:
            val = ins[3:]
            ins = "INT"
            tokens = ["INT", val]

        # 5. Process Instructions (Prioritized over raw data)
        processed = False

        # --- R TYPE ---
        if ins in R_TYPE_FUNCS:
            op = build_opcode(0, 0b00, R_TYPE_FUNCS[ins])
            rd = rs1 = rs2 = 0
            if ins in ["NOT", "INC"]:
                rd = reg(tokens[1]); rs1 = rd
            elif ins == "OUT":
                rs1 = reg(tokens[1])
            elif ins == "IN":
                rd = reg(tokens[1])
            elif ins == "MOV":
                rs1 = reg(tokens[1]); rd = reg(tokens[2])
            elif ins == "SWAP":
                rs1 = reg(tokens[1]); rd = reg(tokens[2]); rs2 = rd
            elif ins in ["ADD", "SUB", "AND"]:
                rd = reg(tokens[1]); rs1 = reg(tokens[2]); rs2 = reg(tokens[3])
            
            mem[current_addr] = inst_word(op, rd, rs1, rs2)
            current_addr += 1
            processed = True

        # --- I TYPE ---
        elif ins in I_TYPE_FUNCS:
            op = build_opcode(1, 0b01, I_TYPE_FUNCS[ins])
            rd = rs1 = rs2 = 0
            if ins == "IADD":
                rd = reg(tokens[1]); rs1 = reg(tokens[2]); imm = parse_hex(tokens[3])
            elif ins == "LDM":
                rd = reg(tokens[1]); imm = parse_hex(tokens[2])
            elif ins == "LDD":
                rd = reg(tokens[1])
                m = re.match(r'([0-9A-Fa-f]+)\((\w+)\)', tokens[2].strip())
                imm = parse_hex(m.group(1)); rs1 = reg(m.group(2))
            elif ins == "STD":
                src = reg(tokens[1])
                m = re.match(r'([0-9A-Fa-f]+)\((\w+)\)', tokens[2].strip())
                imm = parse_hex(m.group(1)); rs1 = src; rs2 = reg(m.group(2))

            mem[current_addr] = inst_word(op, rd, rs1, rs2)
            current_addr += 1
            mem[current_addr] = imm & 0xffffffff
            current_addr += 1
            processed = True

        # --- J TYPE ---
        elif ins in J_TYPE_FUNCS:
            if ins == "RET":
                op = build_opcode(0, 0b10, J_TYPE_FUNCS[ins])
                mem[current_addr] = inst_word(op)
                current_addr += 1
            else:
                op = build_opcode(1, 0b10, J_TYPE_FUNCS[ins])
                target = parse_hex(tokens[1])
                mem[current_addr] = inst_word(op)
                current_addr += 1
                mem[current_addr] = target & 0xffffffff
                current_addr += 1
            processed = True

        # --- SYSTEM STACK ---
        elif ins in SYS_FUNCS:
            needImm = (ins == "INT")
            op = build_opcode(1 if needImm else 0, 0b11, SYS_FUNCS[ins])
            rd = rs1 = rs2 = 0
            if ins == "PUSH": 
                rs1 = reg(tokens[1])
            elif ins == "POP": 
                rd = reg(tokens[1])
            elif ins == "INT": 
                imm = parse_hex(tokens[1])

            mem[current_addr] = inst_word(op, rd, rs1, rs2)
            current_addr += 1
            if needImm:
                mem[current_addr] = imm & 0xffffffff
                current_addr += 1
            processed = True

        if processed:
            continue

        # 6. Fallback: Raw Data Word (Used for reset/interrupt vectors)
        try:
            val = parse_hex(tokens[0])
            mem[current_addr] = val & 0xffffffff
            current_addr += 1
        except ValueError:
            raise ValueError(f"Line {line_num}: Unrecognized instruction or invalid hex '{tokens[0]}'")

    return mem

def write_mem(mem, filename="mem.txt"):
    """Generates the 32-bit binary memory image."""
    max_addr = max(mem.keys(), default=0)
    with open(filename, "w") as f:
        for addr in range(max_addr + 1):
            f.write(f"{mem.get(addr, 0):032b}\n")
    print(f"✅ Assembly complete. {filename} generated (Max Addr: {max_addr:X}h)")

if __name__ == "__main__":
    input_file = sys.argv[1] if len(sys.argv) > 1 else "program.asm"
    try:
        with open(input_file) as f:
            asm_content = f.readlines()
        memory_map = assemble(asm_content)
        write_mem(memory_map)
    except Exception as e:
        print(f"❌ ERROR: {e}")