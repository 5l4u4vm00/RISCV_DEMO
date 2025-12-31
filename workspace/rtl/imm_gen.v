// ============================================================================
// Immediate Generator
// ============================================================================
// Select correct immediate according to instruction type
// ============================================================================

`timescale 1ns / 1ps
`include "riscv_defs.v"

module immediate_generator (
    input  wire [31:0] instruction,
    input  wire [6:0]  opcode,
    output reg  [31:0] immediate
);

    // Immediates of various types
    wire [31:0] imm_i, imm_s, imm_b, imm_u, imm_j;

    // I-type
    assign imm_i = {{20{instruction[31]}}, instruction[31:20]};

    // S-type
    assign imm_s = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};

    // B-type
    assign imm_b = {{19{instruction[31]}}, instruction[31], instruction[7],
                   instruction[30:25], instruction[11:8], 1'b0};

    // U-type
    assign imm_u = {instruction[31:12], 12'b0};

    // J-type
    assign imm_j = {{11{instruction[31]}}, instruction[31], instruction[19:12],
                   instruction[20], instruction[30:21], 1'b0};

    // Select immediate based on opcode
    always @(*) begin
        case (opcode)
            `OPCODE_OP_IMM,
            `OPCODE_LOAD,
            `OPCODE_JALR:   immediate = imm_i;

            `OPCODE_STORE:  immediate = imm_s;

            `OPCODE_BRANCH: immediate = imm_b;

            `OPCODE_LUI,
            `OPCODE_AUIPC:  immediate = imm_u;

            `OPCODE_JAL:    immediate = imm_j;

            default:        immediate = 32'b0;
        endcase
    end

endmodule
