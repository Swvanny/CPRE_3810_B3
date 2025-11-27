.data
result: .word 0         # 0 = not taken, 1 = taken

.text
.globl main
main:
    li t0, 2           # rs1 = 2
    li t1, 4           # rs2 = 4

    li t2, 0   
    nop        # default result = 0
    nop
    nop
    bge t0, t1, taken  # branch should NOT be taken because 2 < 4
    nop
    nop
    nop
    nop
    j done
    nop
    nop
    nop
    nop

taken:
    li t2, 1           # mark branch taken

done:
    nop
    nop
    nop
    wfi                 # wait for interrupt / end

