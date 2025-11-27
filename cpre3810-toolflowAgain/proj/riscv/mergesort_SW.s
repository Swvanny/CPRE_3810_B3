.data
array:      .word 64, 34, 25, 12, 22, 11, 90, 88, 45, 50, 23, 36, 18, 77, 30, 40
array_size: .word 16
temp:       .space 64          # Temporary array for merging (16 * 4 bytes)

.text
.globl main

main:
    lui  a1, 0x10010
    lui  a0, 0x10010 
    nop
    nop
    addi a1, a1, 0x040
    addi a0, a0, 0x000
    nop
    
    addi a2, x0, 0
    lw   a3, 0(a1)
    nop
    nop
    nop
    addi a3, a3, -1 
    
    nop
    nop
    nop
    jal mergeSort
    nop
    
    nop
    nop
    nop
    j   program_end


mergeSort:
    nop
    nop
    nop
    sub  t0, a3, a2
    bge  a2, a3, mergeSortEnd
    nop
    nop 
    nop 

    addi sp, sp, -16
    nop
    nop
    nop
    sw   ra, 12(sp)
    sw   a3, 8(sp)
    sw   a2, 4(sp)
    
    srli t0, t0, 1
    nop
    nop
    nop
    add  t0, t0, a2
    nop
    nop
    nop
    sw   t0, 0(sp)
    mv   a3, t0    
    jal  mergeSort
    nop
    
    lw   t0, 0(sp)
    lw   a3, 8(sp)
    nop
    nop
    addi a2, t0, 1
    jal  mergeSort
    nop
    
    lw   a2, 4(sp)
    lw   a4, 0(sp)
    lw   a3, 8(sp)
    jal  merge
    nop
    
    lw   ra, 12(sp)
    addi sp, sp, 16
    
    mergeSortEnd:
    nop
    nop
    nop
    ret             # Return to main or recursive function hits the snap-back

merge:
    nop
    nop
    nop
    addi sp, sp, -40
    nop
    nop
    nop
    sw   ra, 36(sp)
    sw   s8, 32(sp)
    sw   s7, 28(sp)
    sw   s6, 24(sp)    
    sw   s5, 20(sp)    
    sw   s4, 16(sp)
    sw   s3, 12(sp)
    sw   s2, 8(sp)
    sw   s1, 4(sp)
    sw   s0, 0(sp)
    
    lui  s8, 0x10010
    addi s5, a2, 0
    addi s6, a4, 0
    addi s7, a3, 0
    addi s8, s8, 0x044
    nop
    
    sub  s3, s6, s5	# Setup for n1
    slli t0, s5, 2	# Base Address Precomputing
    sub  s4, s7, s6	# s4 = n2
    addi s0, x0, 0	# Copy left subarray (s0 = i = 0)
    addi s3, s3, 1	# s3 = n1
    add  t0, t0, a0	# t0 = &arr[left]
    nop
    nop

    addi t2, s8, 0	# t2 = current dest address
    addi t1, t0, 0	# t1 = current source address
    
    copyLeft:
    nop
    nop
    nop
    bge  s0, s3, copyRightInit
    nop
    nop
    nop
    
    lw   t3, 0(t1)
    addi s0, s0, 1
    nop
    nop
    sw   t3, 0(t2)
    addi t1, t1, 4
    addi t2, t2, 4
    
    j copyLeft
    nop
    
        
    copyRightInit:
    addi t0, s6, 1
    nop
    nop
    nop
    slli t0, t0, 2
    nop
    nop
    nop
    add  t1, a0, t0	# t1 = &arr[mid + 1]
    
    slli t0, s3, 2
    nop
    nop
    nop
    add  t2, s8, t0	# t2 = &temp[n1]
    
    addi s1, x0, 0
    
    copyRight:    
    nop
    nop
    nop
    bge  s1, s4, mergeArraysInit
    nop
    nop
    nop


    lw   t3, 0(t1)
    addi s1, s1, 1
    nop
    nop
    sw   t3, 0(t2)
    addi t1, t1, 4
    addi t2, t2, 4
    j copyRight
    nop
    
    mergeArraysInit:
    slli t5, s3, 2
    slli t6, s5, 2
       
    addi s0, x0, 0
    addi s1, x0, 0
    addi s2, s5, 0
    addi t4, s8, 0

    add  t5, s8, t5
    add  t6, a0, t6
    
    
    mergeLoop:
    nop
    nop
    nop
    bge  s0, s3, copyRemainingLeft
    nop
    nop
    nop
    nop
    bge  s1, s4, copyRemainingLeft
    nop
    nop
    nop
    nop

    
    lw   t0, 0(t4)
    lw   t1, 0(t5)
    nop
    nop
    nop
    
    blt t1, t0, useRight
    nop
    nop
    nop
    
    useLeft:
    sw   t0, 0(t6)
    addi t4, t4, 4
    addi s0, s0, 1
    j mergeContinue
    nop
    
    useRight:
    sw   t1, 0(t6)
    addi t5, t5, 4
    addi s1, s1, 1    
    
    mergeContinue:
    addi t6, t6, 4
    addi s2, s2, 1
    j mergeLoop
    nop
    
    copyRemainingLeft:
    nop
    nop
    nop
    bge s0, s3, copyRemainingRight
    nop
    nop
    nop

    
    lw   t0, 0(t4)
    addi s0, s0, 1
    addi t4, t4, 4
    addi s2, s2, 1
    sw	 t0, 0(t6)    
    addi t6, t6, 4
    j copyRemainingLeft
    nop
    
    copyRemainingRight:
    nop
    nop
    nop
    bge  s1, s4, mergeDone
    nop
    nop
    nop

    
    lw   t0, 0(t5)
    addi s1, s1, 1
    addi t5, t5, 4
    addi s2, s2, 1
    sw	 t0, 0(t6)
    addi t6, t6, 4
    j copyRemainingRight
    nop
    
    
    mergeDone:
    lw ra, 36(sp)
    lw s8, 32(sp)
    lw s7, 28(sp)
    lw s6, 24(sp)
    lw s5, 20(sp)
    lw s4, 16(sp)
    lw s3, 12(sp)
    lw s2, 8(sp)
    lw s1, 4(sp)
    lw s0, 0(sp)
    addi sp, sp, 40
    nop
    nop
    nop
    ret    
    
    
program_end:
    wfi
