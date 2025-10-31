    .text
    .globl _start
_start:

    # --- Seed values ---
    addi x1,  x0, 5           # x1 = 5
    addi x2,  x0, -3          # x2 = -3 (0xFFFFFFFD)

    # --- Register ALU ops ---
    add  x3,  x1, x2          # x3 = 2
    sub  x4,  x1, x2          # x4 = 8
    and  x5,  x3, x4          # x5 = (2 & 8)  = 0
    or   x6,  x3, x4          # x6 = (2 | 8)  = 10
    xor  x7,  x3, x6          # x7 = (2 ^ 10) = 8

    # Shifts with register shift amount (uses low 5 bits of rs2)
    sll  x8,  x7, x1          # x8  = 8 << 5
    srl  x9,  x7, x1          # x9  = 8 >> 5 (logical)
    sra  x10, x2, x1          # x10 = -3 >> 5 (arithmetic, sign extends)

    # --- Immediate ALU ops ---
    addi x11, x7,  3          # x11 = 8 + 3  = 11
    andi x12, x6,  0x00F      # x12 = 10 & 0xF
    ori  x13, x5,  0x0A0      # x13 = 0 | 0xA0 = 0xA0
    xori x14, x11, -1         # x14 = ~x11

    # Shift-immediate
    slli x15, x7,  3          # x15 = 8 << 3 = 64
    srli x16, x7,  2          # x16 = 8 >> 2 = 2 (logical)
    srai x17, x2,  1          # x17 = -3 >> 1 (arithmetic)

    # Set-on-less-than (signed/unsigned), reg and imm
    slt  x18, x2,  x1         # x18 = (-3 < 5)  ? 1 : 0  (signed)
    sltu x19, x2,  x1         # x19 = (0xFFFFFFFD < 5) ? 0 : 0 (unsigned)
    slti x20, x2,  -1         # x20 = (-3 < -1) ? 1 : 0
    sltiu x21, x2,  -1        # x21 = (0xFFFFFFFD < 0xFFF)?? immediate is sign-ext’d; still covers path

    # Upper-immediate and PC-relative ALU
    lui  x22, 0x12345         # x22 = 0x12345000
    addi x22, x22, 0x678      # x22 = 0x12345678 (keeps imm within 12-bit)
    auipc x23, 0              # x23 = PC (tests AUIPC datapath)
    add  x24, x23, x1         # consume AUIPC result in following op
    