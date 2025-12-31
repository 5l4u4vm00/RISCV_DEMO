// ============================================================================
// RISC-V Pipeline CPU Testbench
// ============================================================================

`timescale 1ns / 1ps

module tb_cpu;

    // ========================================
    // Parameters
    // ========================================
    parameter CLK_PERIOD = 10;  // 10ns = 100MHz
    parameter MAX_CYCLES = 500;

    // ========================================
    // Signals
    // ========================================
    reg clk;
    reg rst_n;

    // Test count
    integer cycle_count;
    integer test_pass;
    integer test_fail;

    // ========================================
    // DUT Instantiation
    // ========================================
    cpu_top #(
        .IMEM_SIZE(4096),
        .DMEM_SIZE(4096),
        .IMEM_INIT("test_program.hex")
    ) dut (
        .clk  (clk),
        .rst_n(rst_n)
    );

    // ========================================
    // Clock Generation
    // ========================================
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // ========================================
    // Waveform Output
    // ========================================
    initial begin
        $dumpfile("sim/wave.vcd");
        $dumpvars(0, tb_cpu);
    end

    // ========================================
    // Main Test Flow
    // ========================================
    initial begin
        // Initialize
        rst_n = 0;
        cycle_count = 0;
        test_pass = 0;
        test_fail = 0;

        $display("========================================");
        $display("RISC-V Pipeline CPU Testbench");
        $display("========================================");

        // Reset
        repeat(5) @(posedge clk);
        rst_n = 1;
        $display("[%0t] Reset released", $time);

        // Execute program
        while (cycle_count < MAX_CYCLES) begin
            @(posedge clk);
            cycle_count = cycle_count + 1;

            // Display pipeline status (every 10 cycles)
            if (cycle_count % 10 == 0) begin
                display_pipeline_status();
            end

            // Check if entering infinite loop (program end)
            if (dut.pc == dut.u_if_id.pc_out &&
                dut.instruction_if == 32'h0000006F) begin  // j . (infinite loop)
                $display("[%0t] Program completed (infinite loop detected)", $time);
                break;
            end
        end

        // Display final register state
        $display("");
        $display("========================================");
        $display("Final Register State");
        $display("========================================");
        display_registers();

        // Verify results
        verify_results();

        // End
        $display("");
        $display("========================================");
        $display("Test Summary: %0d passed, %0d failed", test_pass, test_fail);
        $display("Total cycles: %0d", cycle_count);
        $display("========================================");

        #100;
        $finish;
    end

    // ========================================
    // Display Pipeline Status
    // ========================================
    task display_pipeline_status;
        begin
            $display("[Cycle %0d] PC=%h IF=%h",
                    cycle_count, dut.pc, dut.instruction_if);
        end
    endtask

    // ========================================
    // Display Register Contents
    // ========================================
    task display_registers;
        integer i;
        begin
            for (i = 0; i < 32; i = i + 4) begin
                $display("x%02d=%08h  x%02d=%08h  x%02d=%08h  x%02d=%08h",
                        i,   dut.u_regfile.registers[i],
                        i+1, dut.u_regfile.registers[i+1],
                        i+2, dut.u_regfile.registers[i+2],
                        i+3, dut.u_regfile.registers[i+3]);
            end
        end
    endtask

    // ========================================
    // Verify Test Results
    // ========================================
    task verify_results;
        begin
            // Verify based on expected results of test_program.hex
            // These values need to be adjusted according to actual test program

            // Verify x1 = 100
            check_register(1, 32'd100, "LI x1, 100");

            // Verify x2 = 200
            check_register(2, 32'd200, "LI x2, 200");

            // Verify x3 = 300 (x1 + x2)
            check_register(3, 32'd300, "ADD x3, x1, x2");

            // Verify x4 = 100 (x2 - x1)
            check_register(4, 32'd100, "SUB x4, x2, x1");
        end
    endtask

    // ========================================
    // Check Register Value
    // ========================================
    task check_register;
        input [4:0]  reg_num;
        input [31:0] expected;
        input [255:0] test_name;
        begin
            if (dut.u_regfile.registers[reg_num] === expected) begin
                $display("[PASS] %s: x%0d = %0d", test_name, reg_num, expected);
                test_pass = test_pass + 1;
            end else begin
                $display("[FAIL] %s: x%0d = %0d (expected %0d)",
                        test_name, reg_num,
                        dut.u_regfile.registers[reg_num], expected);
                test_fail = test_fail + 1;
            end
        end
    endtask

    // ========================================
    // Timeout Protection
    // ========================================
    initial begin
        #(CLK_PERIOD * MAX_CYCLES * 2);
        $display("[ERROR] Simulation timeout!");
        $finish;
    end

endmodule
