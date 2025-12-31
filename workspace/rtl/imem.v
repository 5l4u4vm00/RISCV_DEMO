// ============================================================================
// Instruction Memory
// ============================================================================
// Instruction memory (read-only), use $readmemh to load program
// ============================================================================

`timescale 1ns / 1ps

module instruction_memory #(
    parameter MEM_SIZE = 16384,         // Memory size (words) = 64KB
    parameter INIT_FILE = "program.hex" // Initialization file
)(
    input  wire [31:0] addr,            // Address (byte-addressed)
    output wire [31:0] instruction      // Output instruction
);

    // Memory array (word-addressed)
    reg [31:0] mem [0:MEM_SIZE-1];

    // Load program
    initial begin
        // Initialize to NOP (ADDI x0, x0, 0)
        integer i;
        for (i = 0; i < MEM_SIZE; i = i + 1) begin
            mem[i] = 32'h00000013;  // NOP
        end

        // Load from file (if exists)
        $readmemh(INIT_FILE, mem);
    end

    // Read instruction (combinational logic, word-aligned)
    // Address needs to be divided by 4 to convert to word index
    assign instruction = mem[addr[31:2]];

endmodule
