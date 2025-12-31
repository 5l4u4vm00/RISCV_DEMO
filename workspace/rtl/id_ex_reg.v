// ============================================================================
// ID/EX Pipeline Register
// ============================================================================
// Instruction Decode / Execute stage register
// ============================================================================

`timescale 1ns / 1ps

module id_ex_reg (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        stall,
    input  wire        flush,

    // Data path input
    input  wire [31:0] pc_in,
    input  wire [31:0] pc_plus_4_in,
    input  wire [31:0] rs1_data_in,
    input  wire [31:0] rs2_data_in,
    input  wire [31:0] immediate_in,
    input  wire [4:0]  rs1_addr_in,
    input  wire [4:0]  rs2_addr_in,
    input  wire [4:0]  rd_addr_in,
    input  wire [2:0]  funct3_in,
    input  wire [6:0]  funct7_in,

    // Control signal input
    input  wire        reg_write_in,
    input  wire        mem_read_in,
    input  wire        mem_write_in,
    input  wire        mem_to_reg_in,
    input  wire        alu_src_in,
    input  wire [3:0]  alu_op_in,
    input  wire        branch_in,
    input  wire        jump_in,
    input  wire [1:0]  wb_sel_in,
    input  wire [6:0]  opcode_in,

    // Data path output
    output reg  [31:0] pc_out,
    output reg  [31:0] pc_plus_4_out,
    output reg  [31:0] rs1_data_out,
    output reg  [31:0] rs2_data_out,
    output reg  [31:0] immediate_out,
    output reg  [4:0]  rs1_addr_out,
    output reg  [4:0]  rs2_addr_out,
    output reg  [4:0]  rd_addr_out,
    output reg  [2:0]  funct3_out,
    output reg  [6:0]  funct7_out,

    // Control signal output
    output reg         reg_write_out,
    output reg         mem_read_out,
    output reg         mem_write_out,
    output reg         mem_to_reg_out,
    output reg         alu_src_out,
    output reg  [3:0]  alu_op_out,
    output reg         branch_out,
    output reg         jump_out,
    output reg  [1:0]  wb_sel_out,
    output reg  [6:0]  opcode_out
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n || flush) begin
            // Reset or Flush: clear all signals
            pc_out          <= 32'b0;
            pc_plus_4_out   <= 32'b0;
            rs1_data_out    <= 32'b0;
            rs2_data_out    <= 32'b0;
            immediate_out   <= 32'b0;
            rs1_addr_out    <= 5'b0;
            rs2_addr_out    <= 5'b0;
            rd_addr_out     <= 5'b0;
            funct3_out      <= 3'b0;
            funct7_out      <= 7'b0;

            reg_write_out   <= 1'b0;
            mem_read_out    <= 1'b0;
            mem_write_out   <= 1'b0;
            mem_to_reg_out  <= 1'b0;
            alu_src_out     <= 1'b0;
            alu_op_out      <= 4'b0;
            branch_out      <= 1'b0;
            jump_out        <= 1'b0;
            wb_sel_out      <= 2'b0;
            opcode_out      <= 7'b0;
        end else if (stall) begin
            // Stall: insert bubble (clear control signals, keep data)
            reg_write_out   <= 1'b0;
            mem_read_out    <= 1'b0;
            mem_write_out   <= 1'b0;
            branch_out      <= 1'b0;
            jump_out        <= 1'b0;
        end else begin
            // Normal pass
            pc_out          <= pc_in;
            pc_plus_4_out   <= pc_plus_4_in;
            rs1_data_out    <= rs1_data_in;
            rs2_data_out    <= rs2_data_in;
            immediate_out   <= immediate_in;
            rs1_addr_out    <= rs1_addr_in;
            rs2_addr_out    <= rs2_addr_in;
            rd_addr_out     <= rd_addr_in;
            funct3_out      <= funct3_in;
            funct7_out      <= funct7_in;

            reg_write_out   <= reg_write_in;
            mem_read_out    <= mem_read_in;
            mem_write_out   <= mem_write_in;
            mem_to_reg_out  <= mem_to_reg_in;
            alu_src_out     <= alu_src_in;
            alu_op_out      <= alu_op_in;
            branch_out      <= branch_in;
            jump_out        <= jump_in;
            wb_sel_out      <= wb_sel_in;
            opcode_out      <= opcode_in;
        end
    end

endmodule
