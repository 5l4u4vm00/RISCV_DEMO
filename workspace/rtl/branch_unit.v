// ============================================================================
// Branch Unit
// ============================================================================
// Determine if branch condition is met
// ============================================================================

`timescale 1ns / 1ps
`include "riscv_defs.v"

module branch_unit (
    input  wire [31:0] rs1_data,     // Operand 1
    input  wire [31:0] rs2_data,     // Operand 2
    input  wire [2:0]  funct3,       // Branch type
    input  wire        branch,       // Is it a branch instruction
    input  wire        jump,         // Is it a jump instruction
    output reg         branch_taken  // Branch/jump taken
);

    // Comparison result
    wire equal;
    wire signed_lt;
    wire unsigned_lt;

    assign equal       = (rs1_data == rs2_data);
    assign signed_lt   = ($signed(rs1_data) < $signed(rs2_data));
    assign unsigned_lt = (rs1_data < rs2_data);

    always @(*) begin
        if (jump) begin
            // JAL, JALR always jump
            branch_taken = 1'b1;
        end else if (branch) begin
            case (funct3)
                `FUNCT3_BEQ:  branch_taken = equal;
                `FUNCT3_BNE:  branch_taken = ~equal;
                `FUNCT3_BLT:  branch_taken = signed_lt;
                `FUNCT3_BGE:  branch_taken = ~signed_lt;
                `FUNCT3_BLTU: branch_taken = unsigned_lt;
                `FUNCT3_BGEU: branch_taken = ~unsigned_lt;
                default:      branch_taken = 1'b0;
            endcase
        end else begin
            branch_taken = 1'b0;
        end
    end

endmodule
