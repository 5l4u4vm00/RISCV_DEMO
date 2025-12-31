// ============================================================================
// Program Counter (PC)
// ============================================================================
// Program counter, controls instruction execution flow
// ============================================================================

`timescale 1ns / 1ps

module program_counter (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        stall,       // Pause (hazard)
    input  wire        branch_taken,// Branch taken
    input  wire [31:0] branch_target,// Branch target address
    output reg  [31:0] pc,          // Current PC
    output wire [31:0] pc_plus_4    // PC + 4
);

    // PC + 4 calculation
    assign pc_plus_4 = pc + 32'd4;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc <= 32'h0000_0000;  // Reset to start address
        end else if (stall) begin
            pc <= pc;             // Keep unchanged when paused
        end else if (branch_taken) begin
            pc <= branch_target;  // Branch jump
        end else begin
            pc <= pc_plus_4;      // Normal execution, PC + 4
        end
    end

endmodule
