// ============================================================================
// Instruction Decoder
// ============================================================================
// Decode RISC-V instruction, extract each field
// ============================================================================

`timescale 1ns / 1ps
`include "riscv_defs.v"

module decoder (
    input  wire [31:0] instruction,

    // Instruction fields
    output wire [6:0]  opcode,
    output wire [4:0]  rd,
    output wire [4:0]  rs1,
    output wire [4:0]  rs2,
    output wire [2:0]  funct3,
    output wire [6:0]  funct7,

    // Immediates (various types)
    output wire [31:0] imm_i,   // I-type
    output wire [31:0] imm_s,   // S-type
    output wire [31:0] imm_b,   // B-type
    output wire [31:0] imm_u,   // U-type
    output wire [31:0] imm_j    // J-type
);

    // ========================================
    // Instruction field extraction
    // ========================================
    assign opcode = instruction[6:0];
    assign rd     = instruction[11:7];
    assign funct3 = instruction[14:12];
    assign rs1    = instruction[19:15];
    assign rs2    = instruction[24:20];
    assign funct7 = instruction[31:25];

    // ========================================
    // Immediate extension (sign extension)
    // ========================================

    // I-type: inst[31:20]
    assign imm_i = {{20{instruction[31]}}, instruction[31:20]};

    // S-type: inst[31:25] | inst[11:7]
    assign imm_s = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};

    // B-type: inst[31] | inst[7] | inst[30:25] | inst[11:8] | 0
    assign imm_b = {{19{instruction[31]}}, instruction[31], instruction[7],
                   instruction[30:25], instruction[11:8], 1'b0};

    // U-type: inst[31:12] | 0[11:0]
    assign imm_u = {instruction[31:12], 12'b0};

    // J-type: inst[31] | inst[19:12] | inst[20] | inst[30:21] | 0
    assign imm_j = {{11{instruction[31]}}, instruction[31], instruction[19:12],
                   instruction[20], instruction[30:21], 1'b0};

endmodule
