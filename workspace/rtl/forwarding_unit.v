// ============================================================================
// Forwarding Unit
// ============================================================================
// Data forwarding unit, resolve RAW (Read After Write) data hazard
// ============================================================================

`timescale 1ns / 1ps
`include "riscv_defs.v"

module forwarding_unit (
    // EX stage source registers
    input  wire [4:0]  ex_rs1,
    input  wire [4:0]  ex_rs2,

    // MEM stage information
    input  wire [4:0]  mem_rd,
    input  wire        mem_reg_write,

    // WB stage information
    input  wire [4:0]  wb_rd,
    input  wire        wb_reg_write,

    // Forwarding selection signal
    output reg  [1:0]  forward_a,    // rs1 source selection
    output reg  [1:0]  forward_b     // rs2 source selection
);

    // ========================================
    // Forward A (rs1) Logic
    // ========================================
    always @(*) begin
        if (mem_reg_write && (mem_rd != 5'b0) && (mem_rd == ex_rs1)) begin
            // EX/MEM -> EX forwarding (higher priority)
            forward_a = `FWD_EX_MEM;
        end else if (wb_reg_write && (wb_rd != 5'b0) && (wb_rd == ex_rs1)) begin
            // MEM/WB -> EX forwarding
            forward_a = `FWD_MEM_WB;
        end else begin
            // No forwarding
            forward_a = `FWD_NONE;
        end
    end

    // ========================================
    // Forward B (rs2) Logic
    // ========================================
    always @(*) begin
        if (mem_reg_write && (mem_rd != 5'b0) && (mem_rd == ex_rs2)) begin
            // EX/MEM -> EX forwarding
            forward_b = `FWD_EX_MEM;
        end else if (wb_reg_write && (wb_rd != 5'b0) && (wb_rd == ex_rs2)) begin
            // MEM/WB -> EX forwarding
            forward_b = `FWD_MEM_WB;
        end else begin
            // No forwarding
            forward_b = `FWD_NONE;
        end
    end

endmodule
