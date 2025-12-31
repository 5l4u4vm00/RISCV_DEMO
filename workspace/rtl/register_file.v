// ============================================================================
// RISC-V 32x32 Register File
// ============================================================================
// - 32 x 32-bit registers (x0-x31)
// - x0 hardwired to 0
// - 2 read ports, 1 write port
// - Write is synchronous (rising clock edge), read is asynchronous
// ============================================================================

`timescale 1ns / 1ps

module register_file (
    input  wire        clk,         // Clock
    input  wire        rst_n,       // Reset (active low)

    // Read port 1
    input  wire [4:0]  rs1_addr,    // Source register 1 address
    output wire [31:0] rs1_data,    // Source register 1 data

    // Read port 2
    input  wire [4:0]  rs2_addr,    // Source register 2 address
    output wire [31:0] rs2_data,    // Source register 2 data

    // Write port
    input  wire        wr_en,       // Write enable
    input  wire [4:0]  rd_addr,     // Destination register address
    input  wire [31:0] rd_data      // Write data
);

    // 32 x 32-bit registers
    reg [31:0] registers [0:31];

    integer i;

    // Write logic (synchronous)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Reset all registers
            for (i = 0; i < 32; i = i + 1) begin
                registers[i] <= 32'b0;
            end
        end else if (wr_en && rd_addr != 5'b0) begin
            // x0 cannot be written
            registers[rd_addr] <= rd_data;
        end
    end

    // Read logic (asynchronous, combinational)
    // x0 always returns 0
    assign rs1_data = (rs1_addr == 5'b0) ? 32'b0 : registers[rs1_addr];
    assign rs2_data = (rs2_addr == 5'b0) ? 32'b0 : registers[rs2_addr];

endmodule
