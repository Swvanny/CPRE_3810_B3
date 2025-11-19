.data
.text
.globl main
main:
# Test 1: Equal small positive values
# Tests basic beq functionality with common case values.
addi x1, x0, 5
nop
    nop
    nop
    nop
addi x2, x0, 5
nop
    nop
    nop
    nop
beq x1, x2, pass1
nop
    nop
    nop
    nop
addi x3, x0, -1
nop
    nop
    nop
    nop

pass1:
# Test 2: Unequal values (don't branch)
# Tests beq correctly falls through when values differ.
addi x4, x0, 3
nop
    nop
    nop
    nop
addi x5, x0, 9
nop
    nop
    nop
    nop
beq x4, x5, error
nop
    nop
    nop
    nop
addi x6, x0, 1
nop
    nop
    nop
    nop

# Test 3: Same register compared to itself
# Tests edge case of self-comparison (always equal).
addi x7, x0, 42
nop
    nop
    nop
    nop
beq x7, x7, pass2
nop
    nop
    nop
    nop
addi x8, x0, -1
nop
    nop
    nop
    nop

pass2:
    addi x9, x0, 1
    nop
    nop
    nop
    nop

end:
    wfi
   # j end

error:
    wfi
    #addi x31, x0, -1
    #j end
