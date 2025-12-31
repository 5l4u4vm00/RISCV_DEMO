// ============================================================================
// RISC-V 5-Stage Pipeline CPU Top Module
// ============================================================================
// RV32I instruction set implementation
// ============================================================================

`timescale 1ns / 1ps
`include "riscv_defs.v"

module cpu_top #(
    parameter IMEM_SIZE = 16384,
    parameter DMEM_SIZE = 16384,
    parameter IMEM_INIT = "program.hex"
)(
    input  wire        clk,
    input  wire        rst_n
);

    // ========================================
    // Internal Connection Declaration
    // ========================================

    // IF stage
    wire [31:0] pc;
    wire [31:0] pc_plus_4;
    wire [31:0] instruction_if;

    // IF/ID register output
    wire [31:0] pc_id;
    wire [31:0] pc_plus_4_id;
    wire [31:0] instruction_id;

    // ID stage
    wire [6:0]  opcode;
    wire [4:0]  rd_id;
    wire [4:0]  rs1_addr;
    wire [4:0]  rs2_addr;
    wire [2:0]  funct3_id;
    wire [6:0]  funct7_id;
    wire [31:0] rs1_data_id;
    wire [31:0] rs2_data_id;
    wire [31:0] immediate_id;

    // Control signals (ID)
    wire        reg_write_id;
    wire        mem_read_id;
    wire        mem_write_id;
    wire        mem_to_reg_id;
    wire        alu_src_id;
    wire [3:0]  alu_op_id;
    wire        branch_id;
    wire        jump_id;
    wire [1:0]  wb_sel_id;

    // ID/EX register output
    wire [31:0] pc_ex;
    wire [31:0] pc_plus_4_ex;
    wire [31:0] rs1_data_ex;
    wire [31:0] rs2_data_ex;
    wire [31:0] immediate_ex;
    wire [4:0]  rs1_addr_ex;
    wire [4:0]  rs2_addr_ex;
    wire [4:0]  rd_addr_ex;
    wire [2:0]  funct3_ex;
    wire [6:0]  funct7_ex;
    wire [6:0]  opcode_ex;

    // Control signals (EX)
    wire        reg_write_ex;
    wire        mem_read_ex;
    wire        mem_write_ex;
    wire        mem_to_reg_ex;
    wire        alu_src_ex;
    wire [3:0]  alu_op_ex;
    wire        branch_ex;
    wire        jump_ex;
    wire [1:0]  wb_sel_ex;

    // EX stage
    wire [31:0] alu_operand_a;
    wire [31:0] alu_operand_b;
    wire [31:0] alu_result;
    wire        alu_zero;
    wire        branch_taken;
    wire [31:0] branch_target;
    wire [31:0] forwarded_rs1;
    wire [31:0] forwarded_rs2;

    // Forwarding control
    wire [1:0]  forward_a;
    wire [1:0]  forward_b;

    // EX/MEM register output
    wire [31:0] pc_plus_4_mem;
    wire [31:0] alu_result_mem;
    wire [31:0] rs2_data_mem;
    wire [4:0]  rd_addr_mem;
    wire [2:0]  funct3_mem;

    // Control signals (MEM)
    wire        reg_write_mem;
    wire        mem_read_mem;
    wire        mem_write_mem;
    wire        mem_to_reg_mem;
    wire [1:0]  wb_sel_mem;

    // MEM stage
    wire [31:0] mem_read_data;

    // MEM/WB register output
    wire [31:0] pc_plus_4_wb;
    wire [31:0] alu_result_wb;
    wire [31:0] mem_data_wb;
    wire [4:0]  rd_addr_wb;

    // Control signals (WB)
    wire        reg_write_wb;
    wire        mem_to_reg_wb;
    wire [1:0]  wb_sel_wb;

    // WB stage
    wire [31:0] wb_data;

    // Hazard control
    wire        stall_if;
    wire        stall_id;
    wire        flush_if_id;
    wire        flush_id_ex;

    // ========================================
    // IF Stage: Instruction Fetch
    // ========================================

    program_counter u_pc (
        .clk          (clk),
        .rst_n        (rst_n),
        .stall        (stall_if),
        .branch_taken (branch_taken),
        .branch_target(branch_target),
        .pc           (pc),
        .pc_plus_4    (pc_plus_4)
    );

    instruction_memory #(
        .MEM_SIZE  (IMEM_SIZE),
        .INIT_FILE (IMEM_INIT)
    ) u_imem (
        .addr       (pc),
        .instruction(instruction_if)
    );

    // ========================================
    // IF/ID Pipeline Register
    // ========================================

    if_id_reg u_if_id (
        .clk            (clk),
        .rst_n          (rst_n),
        .stall          (stall_id),
        .flush          (flush_if_id),
        .pc_in          (pc),
        .pc_plus_4_in   (pc_plus_4),
        .instruction_in (instruction_if),
        .pc_out         (pc_id),
        .pc_plus_4_out  (pc_plus_4_id),
        .instruction_out(instruction_id)
    );

    // ========================================
    // ID Stage: Instruction Decode
    // ========================================

    decoder u_decoder (
        .instruction(instruction_id),
        .opcode     (opcode),
        .rd         (rd_id),
        .rs1        (rs1_addr),
        .rs2        (rs2_addr),
        .funct3     (funct3_id),
        .funct7     (funct7_id),
        .imm_i      (),  // Use immediate_generator
        .imm_s      (),
        .imm_b      (),
        .imm_u      (),
        .imm_j      ()
    );

    immediate_generator u_imm_gen (
        .instruction(instruction_id),
        .opcode     (opcode),
        .immediate  (immediate_id)
    );

    register_file u_regfile (
        .clk     (clk),
        .rst_n   (rst_n),
        .rs1_addr(rs1_addr),
        .rs1_data(rs1_data_id),
        .rs2_addr(rs2_addr),
        .rs2_data(rs2_data_id),
        .wr_en   (reg_write_wb),
        .rd_addr (rd_addr_wb),
        .rd_data (wb_data)
    );

    control_unit u_control (
        .opcode    (opcode),
        .funct3    (funct3_id),
        .funct7    (funct7_id),
        .reg_write (reg_write_id),
        .mem_read  (mem_read_id),
        .mem_write (mem_write_id),
        .mem_to_reg(mem_to_reg_id),
        .alu_src   (alu_src_id),
        .alu_op    (alu_op_id),
        .branch    (branch_id),
        .jump      (jump_id),
        .wb_sel    (wb_sel_id)
    );

    // ========================================
    // ID/EX Pipeline Register
    // ========================================

    id_ex_reg u_id_ex (
        .clk           (clk),
        .rst_n         (rst_n),
        .stall         (1'b0),
        .flush         (flush_id_ex),
        // Data input
        .pc_in         (pc_id),
        .pc_plus_4_in  (pc_plus_4_id),
        .rs1_data_in   (rs1_data_id),
        .rs2_data_in   (rs2_data_id),
        .immediate_in  (immediate_id),
        .rs1_addr_in   (rs1_addr),
        .rs2_addr_in   (rs2_addr),
        .rd_addr_in    (rd_id),
        .funct3_in     (funct3_id),
        .funct7_in     (funct7_id),
        // Control signal input
        .reg_write_in  (reg_write_id),
        .mem_read_in   (mem_read_id),
        .mem_write_in  (mem_write_id),
        .mem_to_reg_in (mem_to_reg_id),
        .alu_src_in    (alu_src_id),
        .alu_op_in     (alu_op_id),
        .branch_in     (branch_id),
        .jump_in       (jump_id),
        .wb_sel_in     (wb_sel_id),
        .opcode_in     (opcode),
        // Data output
        .pc_out        (pc_ex),
        .pc_plus_4_out (pc_plus_4_ex),
        .rs1_data_out  (rs1_data_ex),
        .rs2_data_out  (rs2_data_ex),
        .immediate_out (immediate_ex),
        .rs1_addr_out  (rs1_addr_ex),
        .rs2_addr_out  (rs2_addr_ex),
        .rd_addr_out   (rd_addr_ex),
        .funct3_out    (funct3_ex),
        .funct7_out    (funct7_ex),
        // Control signal output
        .reg_write_out (reg_write_ex),
        .mem_read_out  (mem_read_ex),
        .mem_write_out (mem_write_ex),
        .mem_to_reg_out(mem_to_reg_ex),
        .alu_src_out   (alu_src_ex),
        .alu_op_out    (alu_op_ex),
        .branch_out    (branch_ex),
        .jump_out      (jump_ex),
        .wb_sel_out    (wb_sel_ex),
        .opcode_out    (opcode_ex)
    );

    // ========================================
    // EX Stage: Execute
    // ========================================

    // Forwarding Unit
    forwarding_unit u_forwarding (
        .ex_rs1       (rs1_addr_ex),
        .ex_rs2       (rs2_addr_ex),
        .mem_rd       (rd_addr_mem),
        .mem_reg_write(reg_write_mem),
        .wb_rd        (rd_addr_wb),
        .wb_reg_write (reg_write_wb),
        .forward_a    (forward_a),
        .forward_b    (forward_b)
    );

    // Forwarding MUX for rs1
    assign forwarded_rs1 = (forward_a == `FWD_EX_MEM) ? alu_result_mem :
                          (forward_a == `FWD_MEM_WB) ? wb_data :
                          rs1_data_ex;

    // Forwarding MUX for rs2
    assign forwarded_rs2 = (forward_b == `FWD_EX_MEM) ? alu_result_mem :
                          (forward_b == `FWD_MEM_WB) ? wb_data :
                          rs2_data_ex;

    // ALU operand selection
    // For AUIPC, operand A should use PC
    assign alu_operand_a = (opcode_ex == `OPCODE_AUIPC) ? pc_ex : forwarded_rs1;
    assign alu_operand_b = alu_src_ex ? immediate_ex : forwarded_rs2;

    alu u_alu (
        .a     (alu_operand_a),
        .b     (alu_operand_b),
        .alu_op(alu_op_ex),
        .result(alu_result),
        .zero  (alu_zero)
    );

    // Branch Unit
    branch_unit u_branch (
        .rs1_data    (forwarded_rs1),
        .rs2_data    (forwarded_rs2),
        .funct3      (funct3_ex),
        .branch      (branch_ex),
        .jump        (jump_ex),
        .branch_taken(branch_taken)
    );

    // Branch target calculation
    // JAL: PC + imm
    // JALR: (rs1 + imm) & ~1
    // Branch: PC + imm
    assign branch_target = (opcode_ex == `OPCODE_JALR) ?
                          (forwarded_rs1 + immediate_ex) & 32'hFFFFFFFE :
                          pc_ex + immediate_ex;

    // ========================================
    // EX/MEM Pipeline Register
    // ========================================

    ex_mem_reg u_ex_mem (
        .clk           (clk),
        .rst_n         (rst_n),
        .flush         (1'b0),
        // Data input
        .pc_plus_4_in  (pc_plus_4_ex),
        .alu_result_in (alu_result),
        .rs2_data_in   (forwarded_rs2),
        .rd_addr_in    (rd_addr_ex),
        .funct3_in     (funct3_ex),
        // Control signal input
        .reg_write_in  (reg_write_ex),
        .mem_read_in   (mem_read_ex),
        .mem_write_in  (mem_write_ex),
        .mem_to_reg_in (mem_to_reg_ex),
        .wb_sel_in     (wb_sel_ex),
        // Data output
        .pc_plus_4_out (pc_plus_4_mem),
        .alu_result_out(alu_result_mem),
        .rs2_data_out  (rs2_data_mem),
        .rd_addr_out   (rd_addr_mem),
        .funct3_out    (funct3_mem),
        // Control signal output
        .reg_write_out (reg_write_mem),
        .mem_read_out  (mem_read_mem),
        .mem_write_out (mem_write_mem),
        .mem_to_reg_out(mem_to_reg_mem),
        .wb_sel_out    (wb_sel_mem)
    );

    // ========================================
    // MEM Stage: Memory Access
    // ========================================

    data_memory #(
        .MEM_SIZE (DMEM_SIZE),
        .BASE_ADDR(32'h00010000)
    ) u_dmem (
        .clk       (clk),
        .addr      (alu_result_mem),
        .write_data(rs2_data_mem),
        .mem_read  (mem_read_mem),
        .mem_write (mem_write_mem),
        .funct3    (funct3_mem),
        .read_data (mem_read_data)
    );

    // ========================================
    // MEM/WB Pipeline Register
    // ========================================

    mem_wb_reg u_mem_wb (
        .clk           (clk),
        .rst_n         (rst_n),
        // Data input
        .pc_plus_4_in  (pc_plus_4_mem),
        .alu_result_in (alu_result_mem),
        .mem_data_in   (mem_read_data),
        .rd_addr_in    (rd_addr_mem),
        // Control signal input
        .reg_write_in  (reg_write_mem),
        .mem_to_reg_in (mem_to_reg_mem),
        .wb_sel_in     (wb_sel_mem),
        // Data output
        .pc_plus_4_out (pc_plus_4_wb),
        .alu_result_out(alu_result_wb),
        .mem_data_out  (mem_data_wb),
        .rd_addr_out   (rd_addr_wb),
        // Control signal output
        .reg_write_out (reg_write_wb),
        .mem_to_reg_out(mem_to_reg_wb),
        .wb_sel_out    (wb_sel_wb)
    );

    // ========================================
    // WB Stage: Write Back
    // ========================================

    // Write-back data selection
    assign wb_data = (wb_sel_wb == `WB_SRC_MEM)  ? mem_data_wb :
                    (wb_sel_wb == `WB_SRC_PC4)  ? pc_plus_4_wb :
                    alu_result_wb;

    // ========================================
    // Hazard Detection Unit
    // ========================================

    hazard_unit u_hazard (
        .id_rs1       (rs1_addr),
        .id_rs2       (rs2_addr),
        .ex_rd        (rd_addr_ex),
        .ex_mem_read  (mem_read_ex),
        .branch_taken (branch_taken),
        .stall_if     (stall_if),
        .stall_id     (stall_id),
        .flush_if_id  (flush_if_id),
        .flush_id_ex  (flush_id_ex)
    );

endmodule
