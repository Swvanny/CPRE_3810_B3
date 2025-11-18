    .data
    .text
    .globl main
main:
    # clear registers
    add x5, x0, x0        # x5=0
    nop
    nop
    nop
    nop
    add x6, x0, x0        # x6=0
    nop
    nop
    nop
    nop
    # test case: adding when both are zero
    add x1, x0, x0        # x1=0+0=0
    nop
    nop
    nop
    nop
    # test case: adding a positive imm and zero
    addi x2, x0, 7        # x2=7
    nop
    nop
    nop
    nop
    add x3, x2, x0        # x3=7+0=7
    nop
    nop
    nop
    nop

    # test case: adding negative and positive immediates
    addi x4, x0, -3       # x4= 3
    nop
    nop
    nop
    nop
    add x5, x4, x2        # x5=(-3)+7=4
    nop
    nop
    nop
    nop

    # test case: commutativity
    add x6, x2, x4        # x6=7+(-3)=4
    nop
    nop
    nop
    nop

    addi a7, x0, 93
    nop
    nop
    nop
    nop
    #ecall
    wfi