# ============================================================================
# RISC-V RV32I Test Program
# ============================================================================
# For verifying basic CPU instruction execution
# ============================================================================

.section .text.init
.global _start

_start:
    # ========================================
    # Initialize registers
    # ========================================
    li      x1, 0           # x1 = 0
    li      x2, 0           # x2 = 0
    li      x3, 0           # x3 = 0

    # ========================================
    # Test 1: Immediate load (LI/ADDI)
    # ========================================
    li      x1, 100         # x1 = 100
    li      x2, 200         # x2 = 200

    # ========================================
    # Test 2: Addition (ADD)
    # ========================================
    add     x3, x1, x2      # x3 = x1 + x2 = 300

    # ========================================
    # Test 3: Subtraction (SUB)
    # ========================================
    sub     x4, x2, x1      # x4 = x2 - x1 = 100

    # ========================================
    # Test 4: Logical operations (AND, OR, XOR)
    # ========================================
    li      x5, 0xFF
    li      x6, 0x0F
    and     x7, x5, x6      # x7 = 0x0F
    or      x8, x5, x6      # x8 = 0xFF
    xor     x9, x5, x6      # x9 = 0xF0

    # ========================================
    # Test 5: Shift operations (SLL, SRL, SRA)
    # ========================================
    li      x10, 0x01
    slli    x11, x10, 4     # x11 = 0x10 (left shift 4 bits)

    li      x12, 0x80
    srli    x13, x12, 2     # x13 = 0x20 (logical right shift)
    srai    x14, x12, 2     # x14 = 0x20 (arithmetic right shift, positive)

    # ========================================
    # Test 6: Comparison (SLT, SLTU)
    # ========================================
    li      x15, -1         # x15 = 0xFFFFFFFF (signed = -1)
    li      x16, 1
    slt     x17, x15, x16   # x17 = 1 (-1 < 1, signed comparison)
    sltu    x18, x15, x16   # x18 = 0 (0xFFFFFFFF > 1, unsigned comparison)

    # ========================================
    # Test 7: Branch instructions (BEQ, BNE, BLT)
    # ========================================
    li      x19, 5
    li      x20, 5
    li      x21, 10

    beq     x19, x20, branch_equal      # Should jump
    li      x22, 0                      # Should not execute
    j       test_loop

branch_equal:
    li      x22, 1                      # x22 = 1 means BEQ success

    bne     x19, x21, branch_not_equal  # Should jump
    li      x23, 0                      # Should not execute
    j       test_loop

branch_not_equal:
    li      x23, 1                      # x23 = 1 means BNE success

    blt     x19, x21, branch_less_than  # 5 < 10, should jump
    li      x24, 0                      # Should not execute
    j       test_loop

branch_less_than:
    li      x24, 1                      # x24 = 1 means BLT success

    # ========================================
    # Test 8: Simple loop
    # ========================================
test_loop:
    li      x25, 0          # Counter
    li      x26, 5          # Loop count

loop:
    addi    x25, x25, 1     # x25++
    bne     x25, x26, loop  # If x25 != 5, continue loop

    # x25 should now equal 5

    # ========================================
    # Test complete: infinite loop
    # ========================================
done:
    j       done            # Stop here

.section .data
    # Test data (if needed)
    test_data: .word 0x12345678
