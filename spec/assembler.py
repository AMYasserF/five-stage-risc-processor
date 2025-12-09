# =====================================
# FULL ISA ASSEMBLER
# R / I / J / SYSTEM-STACK
# =====================================

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
    "JMP":0b0001,"JZ":0b0010,"JN":0b0011,"JC":0b0100,"CALL":0b0101
}

# ------------ SYSTEM STACK ----------
SYS_FUNCS = {
    "RET":0b0001,"PUSH":0b0010,"POP":0b0011,
    "INT":0b0100,"RTI":0b0101,"HLT":0b0110
}

# ------------------------------------

def reg(r):
    r=r.upper()
    if r.startswith("R"):
        n=int(r[1:])
        if 0<=n<=7: return n
    raise ValueError("Invalid Register "+r)

# ------------------------------------

def build_opcode(hasImm, typ, func):
    return (hasImm<<6)|(typ<<4)|func

def inst_word(op, rd=0, rs1=0, rs2=0):
    return (op<<25)|(rd<<22)|(rs1<<19)|(rs2<<16)

# ------------------------------------

def assemble(lines):
    mem=[]

    for ln in lines:
        ln=ln.split(";")[0].strip()
        if not ln: continue

        t=ln.replace(","," ").split()
        ins=t[0].upper()

        # ---------------- R TYPE ----------------
        if ins in R_TYPE_FUNCS:

            op=build_opcode(0,0b00,R_TYPE_FUNCS[ins])

            if ins in ["NOP","SETC"]:
                rd=rs1=rs2=0

            elif ins in ["NOT","INC"]:
                rd=reg(t[1]); rs1=rd; rs2=0

            elif ins=="OUT":
                rd=0; rs1=reg(t[1]); rs2=0

            elif ins=="IN":
                rd=reg(t[1]); rs1=0; rs2=0

            elif ins=="MOV":
                rs1=reg(t[1]); rd=reg(t[2]); rs2=0

            elif ins=="SWAP":
                rs1=reg(t[1]); rd=reg(t[2]); rs2=rd

            else:
                rd=reg(t[1]); rs1=reg(t[2]); rs2=reg(t[3])

            mem.append(inst_word(op, rd, rs1, rs2))

        # ---------------- I TYPE ----------------
        elif ins in I_TYPE_FUNCS:

            op=build_opcode(1,0b01,I_TYPE_FUNCS[ins])

            if ins=="IADD":
                rd=reg(t[1]); rs1=reg(t[2]); rs2=0; imm=int(t[3],0)

            elif ins=="LDM":
                rd=reg(t[1]); rs1=rs2=0; imm=int(t[2],0)

            elif ins=="LDD":
                rd=reg(t[1]); rs1=reg(t[2]); rs2=0; imm=int(t[3],0)

            elif ins=="STD":
                rd=0; rs1=reg(t[1]); rs2=reg(t[2]); imm=int(t[3],0)

            mem.append(inst_word(op, rd, rs1, rs2))
            mem.append(imm & 0xffffffff)

        # ---------------- J TYPE ----------------
        elif ins in J_TYPE_FUNCS:

            op=build_opcode(1,0b10,J_TYPE_FUNCS[ins])
            target=int(t[1],0)

            mem.append(inst_word(op))
            mem.append(target & 0xffffffff)

        # ---------------- SYSTEM STACK ----------
        elif ins in SYS_FUNCS:

            needImm = ins=="INT"
            op=build_opcode(1 if needImm else 0,0b11,SYS_FUNCS[ins])

            if ins=="RET" or ins=="RTI" or ins=="HLT":
                rd=rs1=rs2=0

            elif ins=="PUSH":
                rd=0; rs1=reg(t[1]); rs2=0

            elif ins=="POP":
                rd=reg(t[1]); rs1=0; rs2=0

            elif ins=="INT":
                rd=rs1=rs2=0
                imm=int(t[1],0)

            mem.append(inst_word(op,rd,rs1,rs2))

            if needImm:
                mem.append(imm & 0xffffffff)

        else:
            raise ValueError("Unknown Instruction "+ins)

    return mem

# ------------------------------------

def write_mem(mem):
    with open("mem.txt","w") as f:
        for a,w in enumerate(mem):
            f.write(f"{a:04d}: {w:032b}\n")

    print("✅ mem.txt generated")

# ------------------------------------

if __name__=="__main__":

    with open("program.asm",encoding="utf8") as f:
        asm=f.readlines()

    mc=assemble(asm)
    write_mem(mc)

    print("✅ FULL ISA ASSEMBLE DONE")
    print("✅ TOTAL WORDS =",len(mc))
