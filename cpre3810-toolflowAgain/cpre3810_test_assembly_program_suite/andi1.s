    .data
result:
    .word 0

    .text
    .globl main

main:
    # Test 1: basic mask with positive immediate
    # t0 <- 0xF0F0
    li   t0, 0xF0F0          # t0 = 0x0000F0F0
    nop
    nop
    nop
    nop
    
    # andi t1, t0, 0x00FF => expect 0x000000F0
    andi t1, t0, 0x00FF      # t1 = t0 & 0x00FF = 0x000000F0
    nop
    nop
    nop
    nop
    la   t2, result
    nop
    nop
    nop
    nop
    sw   t1, 0(t2)           # store result
    nop
    nop
    nop
    nop
    wfi

