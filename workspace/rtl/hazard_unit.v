// ============================================================================
// Hazard Detection Unit
// ============================================================================
// Detect data hazard and control hazard, generate stall and flush signals
// ============================================================================

`timescale 1ns / 1ps

module hazard_unit (
    // ID stage information
    input  wire [4:0]  id_rs1,
    input  wire [4:0]  id_rs2,

    // EX stage information
    input  wire [4:0]  ex_rd,
    input  wire        ex_mem_read,      // Load instruction

    // Branch signal
    input  wire        branch_taken,

    // Output control signals
    output wire        stall_if,         // Pause IF stage
    output wire        stall_id,         // Pause ID stage
    output wire        flush_if_id,      // Clear IF/ID register
    output wire        flush_id_ex       // Clear ID/EX register
);

    // ========================================
    // Load-Use Hazard Detection
    // ========================================
    // When EX stage has Load instruction and ID stage needs to use its result
    // Need to pause for one cycle
    wire load_use_hazard;

    assign load_use_hazard = ex_mem_read &&
                            (ex_rd != 5'b0) &&
                            ((ex_rd == id_rs1) || (ex_rd == id_rs2));

    // ========================================
    // Stall Control
    // ========================================
    // Need to pause when load-use hazard
    assign stall_if = load_use_hazard;
    assign stall_id = load_use_hazard;

    // ========================================
    // Flush Control
    // ========================================
    // Need to flush when branch taken
    // Need to insert bubble (flush ID/EX) when load-use hazard
    assign flush_if_id = branch_taken;
    assign flush_id_ex = branch_taken || load_use_hazard;

endmodule
