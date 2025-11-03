   .text
    .globl main

main:
    li   t0, 0            
    li   t1, 5            
    jal  ra, func1        
   
    li   a7, 10           
    ecall

func1:
    addi sp, sp, -4
    sw   ra, 0(sp)
    addi t0, t0, 1      
    jal  ra, func2
    lw   ra, 0(sp)
    addi sp, sp, 4
    jr   ra

func2:
    addi sp, sp, -4
    sw   ra, 0(sp)
    addi t0, t0, 1
    jal  ra, func3
    lw   ra, 0(sp)
    addi sp, sp, 4
    jr   ra

func3:
    addi sp, sp, -4
    sw   ra, 0(sp)
    addi t0, t0, 1


    li   t2, 0
    beq  t2, x0, branch_equal   
    addi t0, t0, 99             
branch_equal:
    li   t2, 1
    bne  t2, x0, branch_noteq   
    addi t0, t0, 99            
branch_noteq:
    li   t2, 2
    blt  x0, t2, branch_less   
    addi t0, t0, 99
branch_less:
    li   t2, -1
    bge  t2, x0, branch_ge      
    j    after_branches
branch_ge:
    addi t0, t0, 50             
after_branches:

    jal  ra, func4
    lw   ra, 0(sp)
    addi sp, sp, 4
    jr   ra

func4:
    addi sp, sp, -4
    sw   ra, 0(sp)
    addi t0, t0, 1
    jal  ra, func5
    lw   ra, 0(sp)
    addi sp, sp, 4
    jr   ra

func5:
    addi sp, sp, -4
    sw   ra, 0(sp)
    addi t0, t0, 1
    
    lw   ra, 0(sp)
    addi sp, sp, 4
    jr   ra