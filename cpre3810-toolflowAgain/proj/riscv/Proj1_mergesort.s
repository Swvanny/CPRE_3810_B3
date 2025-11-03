
    .data
arr: .word 38, 27, 43, 3, 9, 82, 10   
n:   .word 7

    .text
    .globl main

main:
    la   a0, arr          
    li   a1, 0        
    lw   a2, n           
    addi a2, a2, -1
    jal  ra, merge_sort
    
    li   a7, 10
    ecall

merge_sort:
    addi sp, sp, -24      
    sw   a0, 0(sp)
    sw   a1, 4(sp)
    sw   a2, 8(sp)
    sw   s0, 16(sp)
    sw   ra, 20(sp)
    addi s0, sp, 0        

   
    lw   t0, 4(s0)        
    lw   t1, 8(s0)        
    bge  t0, t1, ms_ret

    
    add  t2, t0, t1
    srai t2, t2, 1
    sw   t2, 12(s0)

    
    lw   a0, 0(s0)        
    lw   a1, 4(s0)        
    lw   a2, 12(s0)       
    jal  ra, merge_sort

    
    lw   t2, 12(s0)      
    addi t2, t2, 1        
    lw   a0, 0(s0)        
    mv   a1, t2           
    lw   a2, 8(s0)        
    jal  ra, merge_sort

    
    lw   a0, 0(s0)        
    lw   a1, 4(s0)        
    lw   a2, 12(s0)       
    lw   a3, 8(s0)        
    jal  ra, merge

ms_ret:
    lw   ra, 20(s0)
    lw   s0, 16(s0)
    addi sp, sp, 24
    jr   ra

merge:
    
    addi sp, sp, -44
    sw   a0, 0(sp)
    sw   a1, 4(sp)
    sw   a2, 8(sp)
    sw   a3, 12(sp)
    sw   s0, 24(sp)
    sw   ra, 28(sp)
    sw   s1, 32(sp)
    sw   s2, 36(sp)
    sw   s3, 40(sp)
    addi s0, sp, 0


    lw   t0, 8(s0)        
    lw   t1, 4(s0)        
    sub  t2, t0, t1
    addi t2, t2, 1
    sw   t2, 16(s0)

    
    lw   t3, 12(s0)       
    lw   t0, 8(s0)        
    sub  t4, t3, t0
    sw   t4, 20(s0)

   
    lw   t2, 16(s0)
    lw   t4, 20(s0)
    add  t5, t2, t4
    slli t6, t5, 2


    sub  sp, sp, t6
    mv   s1, sp        
    slli t0, t2, 2
    add  s2, s1, t0       

    
    li   s3, 0
    lw   t0, 0(s0)        
    lw   t1, 4(s0)      
copy_left_loop:
    bge  s3, t2, copy_left_done
    add  t3, t1, s3
    slli t3, t3, 2
    add  t4, t0, t3
    lw   t5, 0(t4)
    slli t6, s3, 2
    add  t4, s1, t6
    sw   t5, 0(t4)
    addi s3, s3, 1
    j    copy_left_loop
copy_left_done:

    
    li   s3, 0
    lw   t0, 0(s0)
    lw   t1, 8(s0)
    addi t1, t1, 1
    lw   t4, 20(s0)
copy_right_loop:
    bge  s3, t4, copy_right_done
    add  t3, t1, s3
    slli t3, t3, 2
    add  t5, t0, t3
    lw   t6, 0(t5)
    slli t3, s3, 2
    add  t5, s2, t3
    sw   t6, 0(t5)
    addi s3, s3, 1
    j    copy_right_loop
copy_right_done:

    
    li   t4, 0            
    li   t5, 0            
    lw   t6, 4(s0)        
    lw   t0, 0(s0)        
    lw   t2, 16(s0)      
    lw   t3, 20(s0)       
merge_loop:
    bge  t4, t2, merge_left_rem
    bge  t5, t3, merge_right_rem

    slli a4, t4, 2
    add  a4, s1, a4
    lw   a4, 0(a4)
    slli a5, t5, 2
    add  a5, s2, a5
    lw   a5, 0(a5)

    ble  a4, a5, take_left

    slli a0, t6, 2
    add  a0, t0, a0
    sw   a5, 0(a0)
    addi t5, t5, 1
    addi t6, t6, 1
    j    merge_loop

take_left:
    slli a0, t6, 2
    add  a0, t0, a0
    sw   a4, 0(a0)
    addi t4, t4, 1
    addi t6, t6, 1
    j    merge_loop

merge_right_rem:
    bge  t4, t2, merge_done
    slli a4, t4, 2
    add  a4, s1, a4
    lw   a4, 0(a4)
    slli a0, t6, 2
    add  a0, t0, a0
    sw   a4, 0(a0)
    addi t4, t4, 1
    addi t6, t6, 1
    j    merge_right_rem

merge_left_rem:
    bge  t5, t3, merge_done
    slli a5, t5, 2
    add  a5, s2, a5
    lw   a5, 0(a5)
    slli a0, t6, 2
    add  a0, t0, a0
    sw   a5, 0(a0)
    addi t5, t5, 1
    addi t6, t6, 1
    j    merge_left_rem

merge_done:
    
    lw   t2, 16(s0)
    lw   t3, 20(s0)
    add  t5, t2, t3
    slli t6, t5, 2
    add  sp, sp, t6

   
    lw   ra, 28(s0)
    lw   s0, 24(s0)
    lw   s1, 32(s0)
    lw   s2, 36(s0)
    lw   s3, 40(s0)
    addi sp, sp, 44
    jr   ra

#Created with Copilot using ChatGPT-5, prompt "I need this C code
 #in Risc-v 32 code, could you make that for me"
 #it didn't work originally so I messed around with it.
 #I created merge sort in C code in VSCode at the start
