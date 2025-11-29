
    .data
arr: .word 38, 27, 43, 3, 9    # Array to sort
n:   .word 5                   # Array size

.text
.globl main

main:
    lui sp, 0x7FFFF       # Load upper 20 bits of stack address
    nop
    nop
    nop
    nop
   addi sp, sp, -16      # Adjust to a valid alignment (creating 0x7FFFEFF0)
    nop
    nop
    nop
    nop
    # Setup arguments for merge_sort(arr_base, L, R)
    lasw   a0, arr          # a0 = base address of array
     lui a1, 0x00000     
    nop
    nop
    nop
    nop
   addi a1, a1, 0     
   nop
   nop
   nop
    addi a2  a2, 5            # a2 = array size (5)
    
    # --- Load-Use Hazard: a2 depends on lw a2, n ---
    nop
    nop
    nop
    addi a2, a2, -1        # a2 = R (right index: 4)
    
    jal  ra, merge_sort
    
    # --- Control Hazard: 3 NOPs after jal ---
    nop
    nop
    nop
    
    li   a7, 10           # Syscall exit code
    j end
    
    # --- Control Hazard: 3 NOPs after j ---
    nop
    nop
    nop

# --------------------------------------------------------------------------
# merge_sort(a0=base, a1=L, a2=R)
# --------------------------------------------------------------------------
merge_sort:
nop
nop
nop
    # Stack Frame Setup (24 bytes: a0, a1, a2, s0, ra, mid)
    addi sp, sp, -24
    
    # --- Stack Pointer Data Hazard (4 NOPs for sw to use new sp) ---
    nop
    nop
    nop
    nop
    
    sw   a0, 0(sp)
    sw   a1, 4(sp)
    sw   a2, 8(sp)
    sw   s0, 16(sp)
    sw   ra, 20(sp)
    
    addi s0, sp, 0        # s0 = frame pointer
    # --- Data Hazard: s0 used immediately after addi (1 NOP) ---
    nop
    nop
    nop
    
    # Base Case: if L >= R (t0 >= t1), return
    lw   t0, 4(s0)        # t0 = L
    # --- Load-Use Hazard: t0 depends on lw (3 NOPs) ---
    nop
    nop
    nop
    lw   t1, 8(s0)        # t1 = R
    # --- Load-Use Hazard: t1 depends on lw (3 NOPs) ---
    nop
    nop
    nop
    bge  t0, t1, ms_ret
    
    # --- Control Hazard: 3 NOPs after branch ---
    nop
    nop
    nop

    # Calculate mid: t2 = (L + R) / 2
    add  t2, t0, t1
    nop 
    nop 
    nop
     nop
    srai t2, t2, 1
    nop 
    nop 
    nop
    sw   t2, 12(s0)       # Store mid (M)

    # --- Recursive Call 1: merge_sort(base, L, M) ---
    lw   a0, 0(s0)        # a0 = base
    # --- Load-Use Hazard: a0 depends on lw (3 NOPs) ---
    nop
    nop
    nop
    lw   a1, 4(s0)        # a1 = L
    # --- Load-Use Hazard: a1 depends on lw (3 NOPs) ---
    nop
    nop
    nop
    lw   a2, 12(s0)       # a2 = M
    # --- Load-Use Hazard: a2 depends on lw (3 NOPs) ---
    nop
    nop
    nop
    
    jal  ra, merge_sort
    
    # --- Control Hazard: 3 NOPs after jal ---
    nop
    nop
    nop

    # --- Recursive Call 2: merge_sort(base, M+1, R) ---
    lw   t2, 12(s0)       # t2 = M
    # --- Load-Use Hazard: t2 depends on lw (3 NOPs) ---
    nop
    nop
    nop
    addi t2, t2, 1        # t2 = M + 1
    # --- Data Hazard: t2 used immediately after addi (1 NOP) ---
    nop
    
    lw   a0, 0(s0)        # a0 = base
    # --- Load-Use Hazard: a0 depends on lw (3 NOPs) ---
    nop
    nop
    nop
    mv   a1, t2           # a1 = M + 1
    
    lw   a2, 8(s0)        # a2 = R
    # --- Load-Use Hazard: a2 depends on lw (3 NOPs) ---
    nop
    nop
    nop
    
    jal  ra, merge_sort
    
    # --- Control Hazard: 3 NOPs after jal ---
    nop
    nop
    nop

    # --- Merge Call: merge(base, L, M, R) ---
    lw   a0, 0(s0)        # a0 = base
    # --- Load-Use Hazard: a0 depends on lw (3 NOPs) ---
    nop
    nop
    nop
    lw   a1, 4(s0)        # a1 = L
    # --- Load-Use Hazard: a1 depends on lw (3 NOPs) ---
    nop
    nop
    nop
    lw   a2, 12(s0)       # a2 = M
    # --- Load-Use Hazard: a2 depends on lw (3 NOPs) ---
    nop
    nop
    nop
    lw   a3, 8(s0)        # a3 = R
    # --- Load-Use Hazard: a3 depends on lw (3 NOPs) ---
    nop
    nop
    nop
    
    jal  ra, merge
    
    # --- Control Hazard: 3 NOPs after jal ---
    nop
    nop
    nop

ms_ret:
    # Stack Frame Cleanup
    lw   ra, 20(s0)
    # --- Load-Use Hazard: ra depends on lw (3 NOPs) ---
    nop
    nop
    nop
    lw   s0, 16(s0)
    # --- Load-Use Hazard: s0 depends on lw (3 NOPs) ---
    nop
    nop
    nop
    
    addi sp, sp, 24
    
    jr   ra
    
    # --- Control Hazard: 3 NOPs after jr ---
    nop
    nop
    nop

# --------------------------------------------------------------------------
# merge(a0=base, a1=L, a2=M, a3=R)
# --------------------------------------------------------------------------
merge:
    # Stack Frame Setup (44 bytes for a0-a3, s0-s3, ra)
    addi sp, sp, -44
    
    # --- Stack Pointer Data Hazard (4 NOPs for sw to use new sp) ---
    nop
    nop
    nop
    nop
    
    sw   a0, 0(sp)
    sw   a1, 4(sp)
    sw   a2, 8(sp)
    sw   a3, 12(sp)
    # 16(sp) is temp storage for left_len
    # 20(sp) is temp storage for right_len
    sw   s0, 24(sp)
    sw   ra, 28(sp)
    sw   s1, 32(sp)
    sw   s2, 36(sp)
    sw   s3, 40(sp)
    
    addi s0, sp, 0 # s0 = frame pointer
    # --- Data Hazard: s0 used immediately after addi (1 NOP) ---
    nop
    nop
    nop
    nop

    # Calculate left_len (M - L + 1)
    lw   t0, 8(s0)        # t0 = M
    # --- Load-Use Hazard (3 NOPs) ---
    nop
    nop
    nop
    lw   t1, 4(s0)        # t1 = L
    # --- Load-Use Hazard (3 NOPs) ---
    nop
    nop
    nop
    sub  t2, t0, t1
    nop
    nop
    nop
    addi t2, t2, 1        # t2 = left_len
    nop
    nop
    nop
    sw   t2, 16(s0)

    # Calculate right_len (R - (M + 1) + 1) = R - M
    lw   t3, 12(s0)       # t3 = R
    # --- Load-Use Hazard (3 NOPs) ---
    nop
    nop
    nop
    lw   t0, 8(s0)        # t0 = M
    # --- Load-Use Hazard (3 NOPs) ---
    nop
    nop
    nop
    sub  t4, t3, t0       # t4 = right_len
        nop
    nop
    nop
    sw   t4, 20(s0)

    nop
    nop
    nop
    # Dynamic Stack Allocation for Temp Arrays
    lw   t2, 16(s0)       # t2 = left_len
    # --- Load-Use Hazard (3 NOPs) ---
    nop
    nop
    nop
    lw   t4, 20(s0)       # t4 = right_len
    # --- Load-Use Hazard (3 NOPs) ---
    nop
    nop
    nop
    add  t5, t2, t4       # t5 = total_len
    nop
    nop
    nop

    slli t6, t5, 2        # t6 = total_bytes
    # --- Data Hazard: t6 depends on t5 (1 NOP) ---
    nop
        nop
    nop
    nop
    
    sub  sp, sp, t6       # Allocate space for temp arrays
    # --- Stack Pointer Data Hazard (4 NOPs for mv to use new sp) ---
    nop
    nop
    nop
    nop
    
    mv   s1, sp           # s1 = base address of left temp array
    
    slli t0, t2, 2        # t0 = left_len_bytes
    # --- Data Hazard: t0 depends on t2 (1 NOP) ---
    nop
    nop
    nop
    
    add  s2, s1, t0       # s2 = base address of right temp array
    # --- Data Hazard: s2 depends on s1, t0 (1 NOP) ---
    nop

    # ------------------------------------------------
    # 1. Copy Left Half to Temp Array (s1)
    # ------------------------------------------------
    li   s3, 0            # s3 = i = 0 (loop index)
    lw   t0, 0(s0)        # t0 = arr_base
    # --- Load-Use Hazard (3 NOPs) ---
    nop
    nop
    nop
    lw   t1, 4(s0)        # t1 = L (start index)
    # --- Load-Use Hazard (3 NOPs) ---
    nop
    nop
    nop
copy_left_loop:
    bge  s3, t2, copy_left_done # if i >= left_len, exit
    # --- Control Hazard: 3 NOPs after branch ---
    nop
    nop
    nop
    
    add  t3, t1, s3       # t3 = L + i (array index)
    nop
    nop
    nop
    slli t3, t3, 2        # t3 = (L + i) * 4 (byte offset)
    nop
    nop
    nop
    add  t4, t0, t3       # t4 = address of arr[L+i]
    nop
    nop
    nop
    lw   t5, 0(t4)        # t5 = arr[L+i] (data)
    # --- Load-Use Hazard: t5 depends on lw (3 NOPs) ---
    nop
    nop
    nop
    
    slli t6, s3, 2        # t6 = i * 4 (temp array offset)
    nop
    nop
    nop
    add  t4, s1, t6       # t4 = address of s1[i]
    nop
    nop
    nop
    sw   t5, 0(t4)
    
    addi s3, s3, 1        # i++
    # --- Data Hazard: s3 used in branch/jump (1 NOP) ---
    nop
    nop
    nop
    j    copy_left_loop
    # --- Control Hazard: 3 NOPs after jump ---
    nop
    nop
    nop
copy_left_done:

    # ------------------------------------------------
    # 2. Copy Right Half to Temp Array (s2)
    # ------------------------------------------------
    li   s3, 0            # s3 = j = 0 (loop index)
    lw   t0, 0(s0)        # t0 = arr_base
    # --- Load-Use Hazard (3 NOPs) ---
    nop
    nop
    nop
    lw   t1, 8(s0)        # t1 = M
    # --- Load-Use Hazard (3 NOPs) ---
    nop
    nop
    nop
    addi t1, t1, 1        # t1 = M + 1 (start index)
    
    lw   t4, 20(s0)       # t4 = right_len
    # --- Load-Use Hazard (3 NOPs) ---
    nop
    nop
    nop
copy_right_loop:
    bge  s3, t4, copy_right_done # if j >= right_len, exit
    # --- Control Hazard: 3 NOPs after branch ---
    nop
    nop
    nop
    
    add  t3, t1, s3       # t3 = (M + 1) + j (array index)
        nop
    nop
    nop
    slli t3, t3, 2        # t3 = index * 4 (byte offset)
        nop
    nop
    nop
    add  t5, t0, t3       # t5 = address of arr[(M+1)+j]
        nop
    nop
    nop
    lw   t6, 0(t5)        # t6 = arr[(M+1)+j] (data)
    # --- Load-Use Hazard: t6 depends on lw (3 NOPs) ---
    nop
    nop
    nop
    
    slli t3, s3, 2        # t3 = j * 4 (temp array offset)
        nop
    nop
    nop
    add  t5, s2, t3       # t5 = address of s2[j]
        nop
    nop
    nop
    sw   t6, 0(t5)
    
    addi s3, s3, 1        # j++
    # --- Data Hazard: s3 used in branch/jump (1 NOP) ---
    nop
        nop
    nop
    nop
    j    copy_right_loop
    # --- Control Hazard: 3 NOPs after jump ---
    nop
    nop
    nop
copy_right_done:

    # ------------------------------------------------
    # 3. Merge Back to Original Array
    # ------------------------------------------------
    li   t4, 0            # t4 = i = 0 (left temp index)
    li   t5, 0            # t5 = j = 0 (right temp index)
    lw   t6, 4(s0)        # t6 = k = L (original array index)
    # --- Load-Use Hazard (3 NOPs) ---
    nop
    nop
    nop
    lw   t0, 0(s0)        # t0 = arr_base
    # --- Load-Use Hazard (3 NOPs) ---
    nop
    nop
    nop
    lw   t2, 16(s0)       # t2 = left_len
    # --- Load-Use Hazard (3 NOPs) ---
    nop
    nop
    nop
    lw   t3, 20(s0)       # t3 = right_len
    # --- Load-Use Hazard (3 NOPs) ---
    nop
    nop
    nop
merge_loop:
    bge  t4, t2, merge_left_rem  # if i >= left_len, go to right remainder
    # --- Control Hazard: 3 NOPs after branch ---
    nop
    nop
    nop
    nop
    nop
    bge  t5, t3, merge_right_rem # if j >= right_len, go to left remainder
    # --- Control Hazard: 3 NOPs after branch ---
    nop
    nop
    nop

    # Load left temp element (a4)
    slli a4, t4, 2
        nop
    nop
    nop
    add  a4, s1, a4
        nop
    nop
    nop
    lw   a4, 0(a4)
    # --- Load-Use Hazard: a4 depends on lw (3 NOPs) ---
    nop
    nop
    nop
    
    # Load right temp element (a5)
    slli a5, t5, 2
        nop
    nop
    nop
    add  a5, s2, a5
        nop
    nop
    nop
    lw   a5, 0(a5)
    # --- Load-Use Hazard: a5 depends on lw (3 NOPs) ---
    nop
    nop
    nop

    ble  a4, a5, take_left
    # --- Control Hazard: 3 NOPs after branch ---
    nop
    nop
    nop

    # Branch Not Taken (Take Right Element)
    slli a0, t6, 2        # a0 = k * 4
        nop
    nop
    nop
    add  a0, t0, a0       # a0 = &arr[k]
        nop
    nop
    nop
    sw   a5, 0(a0)        # arr[k] = a5
    
    addi t5, t5, 1        # j++
    addi t6, t6, 1        # k++
    # --- Data Hazard: t5/t6 used in next loop check/store (1 NOP) ---
    nop
    j    merge_loop
    # --- Control Hazard: 3 NOPs after jump ---
    nop
    nop
    nop

take_left:
    slli a0, t6, 2        # a0 = k * 4
        nop
    nop
    nop
    add  a0, t0, a0       # a0 = &arr[k]
        nop
    nop
    nop
    sw   a4, 0(a0)        # arr[k] = a4
    
    addi t4, t4, 1        # i++
    addi t6, t6, 1        # k++
    # --- Data Hazard: t4/t6 used in next loop check/store (1 NOP) ---
    nop
    j    merge_loop
    # --- Control Hazard: 3 NOPs after jump ---
    nop
    nop
    nop

merge_right_rem:
    nop
    nop
    nop
    bge  t4, t2, merge_done # if i >= left_len, exit
    # --- Control Hazard: 3 NOPs after branch ---
    nop
    nop
    nop
    
    # Load left remainder (a4)
    slli a4, t4, 2
        nop
    nop
    nop
    add  a4, s1, a4
        nop
    nop
    nop
    lw   a4, 0(a4)
    # --- Load-Use Hazard: a4 depends on lw (3 NOPs) ---
    nop
    nop
    nop
    
    # Store remainder to original array
    slli a0, t6, 2
        nop
    nop
    nop
    add  a0, t0, a0
        nop
    nop
    nop
    sw   a4, 0(a0)
    
    addi t4, t4, 1
    addi t6, t6, 1
    # --- Data Hazard: t4/t6 used in next loop check/store (1 NOP) ---
    nop
    j    merge_right_rem
    # --- Control Hazard: 3 NOPs after jump ---
    nop
    nop
    nop

merge_left_rem:
    bge  t5, t3, merge_done # if j >= right_len, exit
    # --- Control Hazard: 3 NOPs after branch ---
    nop
    nop
    nop
    
    # Load right remainder (a5)
    slli a5, t5, 2
        nop
    nop
    nop
    add  a5, s2, a5
        nop
    nop
    nop
    lw   a5, 0(a5)
    # --- Load-Use Hazard: a5 depends on lw (3 NOPs) ---
    nop
    nop
    nop
    
    # Store remainder to original array
    slli a0, t6, 2
        nop
    nop
    nop
    add  a0, t0, a0
        nop
    nop
    nop
    sw   a5, 0(a0)
    
    addi t5, t5, 1
    addi t6, t6, 1
    # --- Data Hazard: t5/t6 used in next loop check/store (1 NOP) ---
    nop
    j    merge_left_rem
    # --- Control Hazard: 3 NOPs after jump ---
    nop
    nop
    nop

merge_done:
    # 4. Deallocate Dynamic Temp Arrays
    lw   t2, 16(s0)       # t2 = left_len
    # --- Load-Use Hazard (3 NOPs) ---
    nop
    nop
    nop
    lw   t3, 20(s0)       # t3 = right_len
    # --- Load-Use Hazard (3 NOPs) ---
    nop
    nop
    nop
    add  t5, t2, t3       # t5 = total_len
    nop
    nop
    nop
    slli t6, t5, 2        # t6 = total_bytes
    # --- Data Hazard: t6 depends on t5 (1 NOP) ---
    nop
        nop
    nop
    nop
    
    add  sp, sp, t6       # Deallocate temp array space
    # --- Stack Pointer Data Hazard (4 NOPs for lw to use new sp) ---
    nop
    nop
    nop
    nop
    
    # 5. Restore Registers and Cleanup Stack
    lw   ra, 28(s0)
    # --- Load-Use Hazard (3 NOPs) ---
    nop
    nop
    nop
    lw   s0, 24(s0)
    # --- Load-Use Hazard (3 NOPs) ---
    nop
    nop
    nop
    nop
    
    addi sp, sp, 24
        nop
    nop
    nop
    nop
    
    jr   ra
    
    # --- Control Hazard: 3 NOPs after jr ---
    nop
    nop
    nop
 
end:
    nop
    nop
    nop
    wfi # Exit the program

#Created with Copilot using ChatGPT-5, prompt "I need this C code
 #in Risc-v 32 code, could you make that for me"
 #it didn't work originally so I messed around with it.
 #I created merge sort in C code in VSCode at the start
