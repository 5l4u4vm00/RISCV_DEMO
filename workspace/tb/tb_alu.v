// ============================================================================
// ALU Testbench
// ============================================================================

`timescale 1ns / 1ps

module tb_alu;

    // Test signals
    reg  [31:0] a;
    reg  [31:0] b;
    reg  [3:0]  alu_op;
    wire [31:0] result;
    wire        zero;

    // ALU operation codes (corresponding to alu.v)
    localparam ALU_ADD  = 4'b0000;
    localparam ALU_SUB  = 4'b0001;
    localparam ALU_AND  = 4'b0010;
    localparam ALU_OR   = 4'b0011;
    localparam ALU_XOR  = 4'b0100;
    localparam ALU_SLL  = 4'b0101;
    localparam ALU_SRL  = 4'b0110;
    localparam ALU_SRA  = 4'b0111;
    localparam ALU_SLT  = 4'b1000;
    localparam ALU_SLTU = 4'b1001;

    // Instantiate device under test
    alu uut (
        .a(a),
        .b(b),
        .alu_op(alu_op),
        .result(result),
        .zero(zero)
    );

    // Test counter
    integer pass_count = 0;
    integer fail_count = 0;

    // Task to check result
    task check_result;
        input [31:0] expected;
        input [127:0] test_name;
        begin
            if (result === expected) begin
                $display("[PASS] %s: a=%h, b=%h, result=%h",
                         test_name, a, b, result);
                pass_count = pass_count + 1;
            end else begin
                $display("[FAIL] %s: a=%h, b=%h, result=%h (expected=%h)",
                         test_name, a, b, result, expected);
                fail_count = fail_count + 1;
            end
        end
    endtask

    // Waveform output
    initial begin
        $dumpfile("sim/wave.vcd");
        $dumpvars(0, tb_alu);
    end

    // Test sequence
    initial begin
        $display("========================================");
        $display("ALU Testbench Start");
        $display("========================================");

        // Test ADD
        a = 32'd10; b = 32'd20; alu_op = ALU_ADD; #10;
        check_result(32'd30, "ADD");

        a = 32'hFFFFFFFF; b = 32'd1; alu_op = ALU_ADD; #10;
        check_result(32'd0, "ADD overflow");

        // Test SUB
        a = 32'd50; b = 32'd30; alu_op = ALU_SUB; #10;
        check_result(32'd20, "SUB");

        a = 32'd10; b = 32'd10; alu_op = ALU_SUB; #10;
        check_result(32'd0, "SUB zero");
        if (zero !== 1'b1) $display("[FAIL] Zero flag should be set");

        // Test AND
        a = 32'hFF00FF00; b = 32'h0F0F0F0F; alu_op = ALU_AND; #10;
        check_result(32'h0F000F00, "AND");

        // Test OR
        a = 32'hFF00FF00; b = 32'h0F0F0F0F; alu_op = ALU_OR; #10;
        check_result(32'hFF0FFF0F, "OR");

        // Test XOR
        a = 32'hFF00FF00; b = 32'h0F0F0F0F; alu_op = ALU_XOR; #10;
        check_result(32'hF00FF00F, "XOR");

        // Test SLL (logical left shift)
        a = 32'h00000001; b = 32'd4; alu_op = ALU_SLL; #10;
        check_result(32'h00000010, "SLL");

        // Test SRL (logical right shift)
        a = 32'h80000000; b = 32'd4; alu_op = ALU_SRL; #10;
        check_result(32'h08000000, "SRL");

        // Test SRA (arithmetic right shift)
        a = 32'h80000000; b = 32'd4; alu_op = ALU_SRA; #10;
        check_result(32'hF8000000, "SRA");

        // Test SLT (signed comparison)
        a = 32'hFFFFFFFF; b = 32'd1; alu_op = ALU_SLT; #10;  // -1 < 1
        check_result(32'd1, "SLT signed");

        // Test SLTU (unsigned comparison)
        a = 32'hFFFFFFFF; b = 32'd1; alu_op = ALU_SLTU; #10;  // large number > 1
        check_result(32'd0, "SLTU unsigned");

        // Display test results
        $display("========================================");
        $display("Test Complete: %0d passed, %0d failed", pass_count, fail_count);
        $display("========================================");

        $finish;
    end

endmodule
