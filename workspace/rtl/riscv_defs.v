// ============================================================================
// RISC-V CPU Shared Definitions
// ============================================================================
// Include parameters and opcode definitions shared by all modules
// ============================================================================

`ifndef RISCV_DEFS_V
`define RISCV_DEFS_V

// ============================================================================
// Instruction Format Opcode (inst[6:0])
// ============================================================================
`define OPCODE_LUI      7'b0110111  // LUI
`define OPCODE_AUIPC    7'b0010111  // AUIPC
`define OPCODE_JAL      7'b1101111  // JAL
`define OPCODE_JALR     7'b1100111  // JALR
`define OPCODE_BRANCH   7'b1100011  // Branch (BEQ, BNE, BLT, BGE, BLTU, BGEU)
`define OPCODE_LOAD     7'b0000011  // Load (LB, LH, LW, LBU, LHU)
`define OPCODE_STORE    7'b0100011  // Store (SB, SH, SW)
`define OPCODE_OP_IMM   7'b0010011  // I-type ALU (ADDI, SLTI, etc.)
`define OPCODE_OP       7'b0110011  // R-type ALU (ADD, SUB, etc.)
`define OPCODE_SYSTEM   7'b1110011  // System (ECALL, EBREAK, CSR)

// ============================================================================
// ALU Operation Codes
// ============================================================================
`define ALU_ADD     4'b0000
`define ALU_SUB     4'b0001
`define ALU_AND     4'b0010
`define ALU_OR      4'b0011
`define ALU_XOR     4'b0100
`define ALU_SLL     4'b0101
`define ALU_SRL     4'b0110
`define ALU_SRA     4'b0111
`define ALU_SLT     4'b1000
`define ALU_SLTU    4'b1001
`define ALU_PASS_B  4'b1010  // Direct output B (for LUI)

// ============================================================================
// funct3 Definitions
// ============================================================================
// Branch
`define FUNCT3_BEQ      3'b000
`define FUNCT3_BNE      3'b001
`define FUNCT3_BLT      3'b100
`define FUNCT3_BGE      3'b101
`define FUNCT3_BLTU     3'b110
`define FUNCT3_BGEU     3'b111

// Load
`define FUNCT3_LB       3'b000
`define FUNCT3_LH       3'b001
`define FUNCT3_LW       3'b010
`define FUNCT3_LBU      3'b100
`define FUNCT3_LHU      3'b101

// Store
`define FUNCT3_SB       3'b000
`define FUNCT3_SH       3'b001
`define FUNCT3_SW       3'b010

// ALU I-type / R-type
`define FUNCT3_ADD_SUB  3'b000
`define FUNCT3_SLL      3'b001
`define FUNCT3_SLT      3'b010
`define FUNCT3_SLTU     3'b011
`define FUNCT3_XOR      3'b100
`define FUNCT3_SRL_SRA  3'b101
`define FUNCT3_OR       3'b110
`define FUNCT3_AND      3'b111

// ============================================================================
// Immediate Types
// ============================================================================
`define IMM_TYPE_I      3'b000  // I-type
`define IMM_TYPE_S      3'b001  // S-type
`define IMM_TYPE_B      3'b010  // B-type
`define IMM_TYPE_U      3'b011  // U-type
`define IMM_TYPE_J      3'b100  // J-type

// ============================================================================
// ALU Operand Source Selection
// ============================================================================
`define ALU_SRC_REG     1'b0    // From registers
`define ALU_SRC_IMM     1'b1    // From immediate

// ============================================================================
// Write-back Data Source Selection
// ============================================================================
`define WB_SRC_ALU      2'b00   // ALU result
`define WB_SRC_MEM      2'b01   // Memory read
`define WB_SRC_PC4      2'b10   // PC + 4 (for JAL/JALR)

// ============================================================================
// Forwarding Selection
// ============================================================================
`define FWD_NONE        2'b00   // No forwarding, use original value
`define FWD_EX_MEM      2'b01   // Forward from EX/MEM stage
`define FWD_MEM_WB      2'b10   // Forward from MEM/WB stage

// ============================================================================
// Memory Access Width
// ============================================================================
`define MEM_WIDTH_BYTE  2'b00
`define MEM_WIDTH_HALF  2'b01
`define MEM_WIDTH_WORD  2'b10

`endif
