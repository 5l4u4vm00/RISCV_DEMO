// ============================================================================
// Control Unit
// ============================================================================
// Main control unit, generate control signals according to opcode
// ============================================================================

`timescale 1ns / 1ps
`include "riscv_defs.v"

module control_unit (
    input  wire [6:0]  opcode,
    input  wire [2:0]  funct3,
    input  wire [6:0]  funct7,

    // Control signals
    output reg         reg_write,    // Write to register
    output reg         mem_read,     // Read memory
    output reg         mem_write,    // Write memory
    output reg         mem_to_reg,   // Memory data write-back
    output reg         alu_src,      // ALU source selection (0:reg, 1:imm)
    output reg  [3:0]  alu_op,       // ALU operation
    output reg         branch,       // Branch instruction
    output reg         jump,         // Jump instruction (JAL/JALR)
    output reg  [1:0]  wb_sel        // Write-back source selection
);

    // Generate ALU operation code (based on funct3, funct7)
    reg [3:0] alu_op_r;
    reg [3:0] alu_op_i;

    // R-type ALU operation
    always @(*) begin
        case (funct3)
            `FUNCT3_ADD_SUB: alu_op_r = (funct7[5]) ? `ALU_SUB : `ALU_ADD;
            `FUNCT3_SLL:     alu_op_r = `ALU_SLL;
            `FUNCT3_SLT:     alu_op_r = `ALU_SLT;
            `FUNCT3_SLTU:    alu_op_r = `ALU_SLTU;
            `FUNCT3_XOR:     alu_op_r = `ALU_XOR;
            `FUNCT3_SRL_SRA: alu_op_r = (funct7[5]) ? `ALU_SRA : `ALU_SRL;
            `FUNCT3_OR:      alu_op_r = `ALU_OR;
            `FUNCT3_AND:     alu_op_r = `ALU_AND;
            default:         alu_op_r = `ALU_ADD;
        endcase
    end

    // I-type ALU operation
    always @(*) begin
        case (funct3)
            `FUNCT3_ADD_SUB: alu_op_i = `ALU_ADD;  // ADDI (no SUBI)
            `FUNCT3_SLL:     alu_op_i = `ALU_SLL;
            `FUNCT3_SLT:     alu_op_i = `ALU_SLT;
            `FUNCT3_SLTU:    alu_op_i = `ALU_SLTU;
            `FUNCT3_XOR:     alu_op_i = `ALU_XOR;
            `FUNCT3_SRL_SRA: alu_op_i = (funct7[5]) ? `ALU_SRA : `ALU_SRL;
            `FUNCT3_OR:      alu_op_i = `ALU_OR;
            `FUNCT3_AND:     alu_op_i = `ALU_AND;
            default:         alu_op_i = `ALU_ADD;
        endcase
    end

    // Main control logic
    always @(*) begin
        // Default values
        reg_write  = 1'b0;
        mem_read   = 1'b0;
        mem_write  = 1'b0;
        mem_to_reg = 1'b0;
        alu_src    = 1'b0;
        alu_op     = `ALU_ADD;
        branch     = 1'b0;
        jump       = 1'b0;
        wb_sel     = `WB_SRC_ALU;

        case (opcode)
            // R-type: ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU
            `OPCODE_OP: begin
                reg_write = 1'b1;
                alu_src   = 1'b0;      // Use rs2
                alu_op    = alu_op_r;
                wb_sel    = `WB_SRC_ALU;
            end

            // I-type ALU: ADDI, ANDI, ORI, XORI, SLTI, SLTIU, SLLI, SRLI, SRAI
            `OPCODE_OP_IMM: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;      // Use immediate
                alu_op    = alu_op_i;
                wb_sel    = `WB_SRC_ALU;
            end

            // Load: LB, LH, LW, LBU, LHU
            `OPCODE_LOAD: begin
                reg_write  = 1'b1;
                mem_read   = 1'b1;
                mem_to_reg = 1'b1;
                alu_src    = 1'b1;     // base + offset
                alu_op     = `ALU_ADD;
                wb_sel     = `WB_SRC_MEM;
            end

            // Store: SB, SH, SW
            `OPCODE_STORE: begin
                mem_write = 1'b1;
                alu_src   = 1'b1;      // base + offset
                alu_op    = `ALU_ADD;
            end

            // Branch: BEQ, BNE, BLT, BGE, BLTU, BGEU
            `OPCODE_BRANCH: begin
                branch  = 1'b1;
                alu_src = 1'b0;        // Compare two registers
                alu_op  = `ALU_SUB;    // Use subtraction to compare
            end

            // JAL
            `OPCODE_JAL: begin
                reg_write = 1'b1;
                jump      = 1'b1;
                wb_sel    = `WB_SRC_PC4;  // Save return address
            end

            // JALR
            `OPCODE_JALR: begin
                reg_write = 1'b1;
                jump      = 1'b1;
                alu_src   = 1'b1;
                alu_op    = `ALU_ADD;
                wb_sel    = `WB_SRC_PC4;
            end

            // LUI
            `OPCODE_LUI: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                alu_op    = `ALU_PASS_B;  // Direct output immediate
                wb_sel    = `WB_SRC_ALU;
            end

            // AUIPC
            `OPCODE_AUIPC: begin
                reg_write = 1'b1;
                alu_src   = 1'b1;
                alu_op    = `ALU_ADD;    // PC + imm
                wb_sel    = `WB_SRC_ALU;
            end

            default: begin
                // NOP or unknown instruction
            end
        endcase
    end

endmodule
