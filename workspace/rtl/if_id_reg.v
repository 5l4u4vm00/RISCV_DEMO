// ============================================================================
// IF/ID Pipeline Register
// ============================================================================
// Instruction Fetch / Instruction Decode stage register
// ============================================================================

`timescale 1ns / 1ps

module if_id_reg (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        stall,        // Pause
    input  wire        flush,        // Clear (branch)

    // IF stage input
    input  wire [31:0] pc_in,
    input  wire [31:0] pc_plus_4_in,
    input  wire [31:0] instruction_in,

    // ID stage output
    output reg  [31:0] pc_out,
    output reg  [31:0] pc_plus_4_out,
    output reg  [31:0] instruction_out
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_out          <= 32'b0;
            pc_plus_4_out   <= 32'b0;
            instruction_out <= 32'h00000013;  // NOP
        end else if (flush) begin
            // Branch taken, insert NOP
            pc_out          <= 32'b0;
            pc_plus_4_out   <= 32'b0;
            instruction_out <= 32'h00000013;  // NOP
        end else if (stall) begin
            // Pause, keep unchanged
            pc_out          <= pc_out;
            pc_plus_4_out   <= pc_plus_4_out;
            instruction_out <= instruction_out;
        end else begin
            pc_out          <= pc_in;
            pc_plus_4_out   <= pc_plus_4_in;
            instruction_out <= instruction_in;
        end
    end

endmodule
