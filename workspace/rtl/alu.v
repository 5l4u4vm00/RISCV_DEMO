// ============================================================================
// RISC-V 32-bit ALU
// ============================================================================
// Support RV32I basic integer operations
// ============================================================================

`timescale 1ns / 1ps

module alu (
    input  wire [31:0] a,           // Operand A
    input  wire [31:0] b,           // Operand B
    input  wire [3:0]  alu_op,      // ALU operation code
    output reg  [31:0] result,      // Operation result
    output wire        zero         // Zero flag
);

    // ALU operation code definitions
    localparam ALU_ADD  = 4'b0000;  // Addition
    localparam ALU_SUB  = 4'b0001;  // Subtraction
    localparam ALU_AND  = 4'b0010;  // AND
    localparam ALU_OR   = 4'b0011;  // OR
    localparam ALU_XOR  = 4'b0100;  // XOR
    localparam ALU_SLL  = 4'b0101;  // Logical left shift
    localparam ALU_SRL  = 4'b0110;  // Logical right shift
    localparam ALU_SRA  = 4'b0111;  // Arithmetic right shift
    localparam ALU_SLT  = 4'b1000;  // Signed less than comparison
    localparam ALU_SLTU = 4'b1001;  // Unsigned less than comparison
    localparam ALU_PASS_B = 4'b1010; // Direct output B (for LUI)

    // Zero flag: set when result is zero
    assign zero = (result == 32'b0);

    // ALU operation
    always @(*) begin
        case (alu_op)
            ALU_ADD:    result = a + b;
            ALU_SUB:    result = a - b;
            ALU_AND:    result = a & b;
            ALU_OR:     result = a | b;
            ALU_XOR:    result = a ^ b;
            ALU_SLL:    result = a << b[4:0];
            ALU_SRL:    result = a >> b[4:0];
            ALU_SRA:    result = $signed(a) >>> b[4:0];
            ALU_SLT:    result = ($signed(a) < $signed(b)) ? 32'd1 : 32'd0;
            ALU_SLTU:   result = (a < b) ? 32'd1 : 32'd0;
            ALU_PASS_B: result = b;  // Direct output B (for LUI)
            default:    result = 32'b0;
        endcase
    end

endmodule
