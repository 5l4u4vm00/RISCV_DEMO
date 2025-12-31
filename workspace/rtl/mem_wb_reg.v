// ============================================================================
// MEM/WB Pipeline Register
// ============================================================================
// Memory Access / Write Back stage register
// ============================================================================

`timescale 1ns / 1ps

module mem_wb_reg (
    input  wire        clk,
    input  wire        rst_n,

    // Data path input
    input  wire [31:0] pc_plus_4_in,
    input  wire [31:0] alu_result_in,
    input  wire [31:0] mem_data_in,
    input  wire [4:0]  rd_addr_in,

    // Control signal input
    input  wire        reg_write_in,
    input  wire        mem_to_reg_in,
    input  wire [1:0]  wb_sel_in,

    // Data path output
    output reg  [31:0] pc_plus_4_out,
    output reg  [31:0] alu_result_out,
    output reg  [31:0] mem_data_out,
    output reg  [4:0]  rd_addr_out,

    // Control signal output
    output reg         reg_write_out,
    output reg         mem_to_reg_out,
    output reg  [1:0]  wb_sel_out
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_plus_4_out   <= 32'b0;
            alu_result_out  <= 32'b0;
            mem_data_out    <= 32'b0;
            rd_addr_out     <= 5'b0;

            reg_write_out   <= 1'b0;
            mem_to_reg_out  <= 1'b0;
            wb_sel_out      <= 2'b0;
        end else begin
            pc_plus_4_out   <= pc_plus_4_in;
            alu_result_out  <= alu_result_in;
            mem_data_out    <= mem_data_in;
            rd_addr_out     <= rd_addr_in;

            reg_write_out   <= reg_write_in;
            mem_to_reg_out  <= mem_to_reg_in;
            wb_sel_out      <= wb_sel_in;
        end
    end

endmodule
