# Program 1: Simple test with external interrupt
# ================================================

.ORG 0
200             # Reset address - start at address 200

.ORG 1
300             # External Interrupt handler address

.ORG 200
# Main program
LDM R2, 10FE19  # R2 = 0x10FE19
LDM R3, 21FFFF  # R3 = 0x21FFFF
LDM R4, E5F320  # R4 = 0xE5F320
PUSH R2         # Push R2 to stack
PUSH R3         # Push R3 to stack  
PUSH R4         # Push R4 to stack
POP R5          # R5 = R4
POP R6          # R6 = R3
POP R7          # R7 = R2
STD R2, 50(R0)  # M[R0+50] = R2
STD R3, 51(R0)  # M[R0+51] = R3
LDD R1, 50(R0)  # R1 = M[R0+50]
ADD R1, R2, R3  # R1 = R2 + R3
HLT             # Halt processor

.ORG 300
# External Interrupt Handler
PUSH R1         # Save R1
LDM R1, FF      # R1 = 0xFF (indicator)
OUT R1          # Output indicator
POP R1          # Restore R1
RTI             # Return from interrupt
