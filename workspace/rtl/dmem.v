// ============================================================================
// Data Memory
// ============================================================================
// Data memory, supports byte/halfword/word access
// ============================================================================

`timescale 1ns / 1ps
`include "riscv_defs.v"

module data_memory #(
    parameter MEM_SIZE = 16384,        // Memory size (words) = 64KB
    parameter BASE_ADDR = 32'h00010000 // Base address
)(
    input  wire        clk,
    input  wire [31:0] addr,           // Address
    input  wire [31:0] write_data,     // Write data
    input  wire        mem_read,       // Read enable
    input  wire        mem_write,      // Write enable
    input  wire [2:0]  funct3,         // Access type (byte/half/word, signed/unsigned)
    output reg  [31:0] read_data       // Read data
);

    // Memory array
    reg [7:0] mem [0:MEM_SIZE*4-1];  // byte-addressable

    // Relative address (subtract base address)
    wire [31:0] rel_addr = addr - BASE_ADDR;

    // Initialize
    integer i;
    initial begin
        for (i = 0; i < MEM_SIZE*4; i = i + 1) begin
            mem[i] = 8'b0;
        end
    end

    // Read logic
    always @(*) begin
        if (mem_read) begin
            case (funct3)
                `FUNCT3_LB: begin  // Load Byte (signed)
                    read_data = {{24{mem[rel_addr][7]}}, mem[rel_addr]};
                end
                `FUNCT3_LH: begin  // Load Halfword (signed)
                    read_data = {{16{mem[rel_addr+1][7]}},
                                mem[rel_addr+1], mem[rel_addr]};
                end
                `FUNCT3_LW: begin  // Load Word
                    read_data = {mem[rel_addr+3], mem[rel_addr+2],
                                mem[rel_addr+1], mem[rel_addr]};
                end
                `FUNCT3_LBU: begin // Load Byte Unsigned
                    read_data = {24'b0, mem[rel_addr]};
                end
                `FUNCT3_LHU: begin // Load Halfword Unsigned
                    read_data = {16'b0, mem[rel_addr+1], mem[rel_addr]};
                end
                default: begin
                    read_data = 32'b0;
                end
            endcase
        end else begin
            read_data = 32'b0;
        end
    end

    // Write logic
    always @(posedge clk) begin
        if (mem_write) begin
            case (funct3)
                `FUNCT3_SB: begin  // Store Byte
                    mem[rel_addr] <= write_data[7:0];
                end
                `FUNCT3_SH: begin  // Store Halfword
                    mem[rel_addr]   <= write_data[7:0];
                    mem[rel_addr+1] <= write_data[15:8];
                end
                `FUNCT3_SW: begin  // Store Word
                    mem[rel_addr]   <= write_data[7:0];
                    mem[rel_addr+1] <= write_data[15:8];
                    mem[rel_addr+2] <= write_data[23:16];
                    mem[rel_addr+3] <= write_data[31:24];
                end
                default: begin
                    // Do nothing
                end
            endcase
        end
    end

endmodule
