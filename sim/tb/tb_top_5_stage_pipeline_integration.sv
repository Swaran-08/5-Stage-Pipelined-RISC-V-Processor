`timescale 1ns / 1ps

module tb_top_5_stage_combined;

    logic clk;
    logic reset;

    integer errors;

    // DUT
    top_5_stage_pipeline dut (
        .clk   (clk),
        .reset (reset)
    );

    // Clock: 10 ns period
    always #5 clk = ~clk;

    initial begin
        clk    = 0;
        reset  = 1;
        errors = 0;

        // Initialize data memory:
        // Word at address 0 = 42 (0x0000002A)
        dut.data_mem_inst.mem[0] = 8'h2A;
        dut.data_mem_inst.mem[1] = 8'h00;
        dut.data_mem_inst.mem[2] = 8'h00;
        dut.data_mem_inst.mem[3] = 8'h00;

        // Word at address 4 = 0
        dut.data_mem_inst.mem[4] = 8'h00;
        dut.data_mem_inst.mem[5] = 8'h00;
        dut.data_mem_inst.mem[6] = 8'h00;
        dut.data_mem_inst.mem[7] = 8'h00;

        // Reset
        repeat (3) @(posedge clk);
        reset = 0;

        // Allow the pipeline to execute
        repeat (35) @(posedge clk);
        #1;

        $display("");
        $display("==============================================");
        $display(" COMBINED PIPELINE VERIFICATION");
        $display("==============================================");

        // --------------------------------------------------
        // REGISTER CHECKS
        // --------------------------------------------------
        $display("");
        $display("------ REGISTER CHECKS ------");

        // Load-to-store forwarding
        check_reg(1, 32'd42);

        // Load from the value stored by SW
        check_reg(2, 32'd42);

        // Load-use hazard with independent instruction
        // x3 = x2 + x5 = 42 + 10 = 52
        check_reg(3, 32'd52);

        // Independent instruction
        check_reg(5, 32'd10);

        // Back-to-back ALU dependencies
        check_reg(6, 32'd5);
        check_reg(7, 32'd8);
        check_reg(8, 32'd13);
        check_reg(9, 32'd5);

        // Branch inputs
        check_reg(10, 32'd5);
        check_reg(11, 32'd5);

        // Branch must skip ADDI x12, x0, 99
        check_reg(12, 32'd0);

        // Target instruction executes
        check_reg(13, 32'd10);

        // --------------------------------------------------
        // MEMORY CHECKS
        // --------------------------------------------------
        $display("");
        $display("------ MEMORY CHECKS ------");

        check_mem_byte(0, 8'h2A);
        check_mem_byte(1, 8'h00);
        check_mem_byte(2, 8'h00);
        check_mem_byte(3, 8'h00);

        // SW x1, 4(x0) should store 42
        check_mem_byte(4, 8'h2A);
        check_mem_byte(5, 8'h00);
        check_mem_byte(6, 8'h00);
        check_mem_byte(7, 8'h00);

        // --------------------------------------------------
        // FINAL RESULT
        // --------------------------------------------------
        $display("");
        $display("==============================================");

        if (errors == 0) begin
            $display("PASS: ALL COMBINED PIPELINE TESTS PASSED");
        end
        else begin
            $display("FAIL: %0d CHECK(S) FAILED", errors);
        end

        $display("==============================================");
        $finish;
    end

    // --------------------------------------------------
    // Register check task
    // --------------------------------------------------
    task check_reg;
        input integer reg_num;
        input logic [31:0] expected;
        logic [31:0] actual;
        begin
            actual = dut.reg_file_inst.regs[reg_num];

            if (actual === expected) begin
                $display("PASS: x%0d = %08h", reg_num, actual);
            end
            else begin
                $display("FAIL: x%0d expected %08h, got %08h",
                         reg_num, expected, actual);
                errors = errors + 1;
            end
        end
    endtask

    // --------------------------------------------------
    // Memory byte check task
    // --------------------------------------------------
    task check_mem_byte;
        input integer byte_addr;
        input logic [7:0] expected;
        logic [7:0] actual;
        begin
            actual = dut.data_mem_inst.mem[byte_addr];

            if (actual === expected) begin
                $display("PASS: mem[%0d] = %02h", byte_addr, actual);
            end
            else begin
                $display("FAIL: mem[%0d] expected %02h, got %02h",
                         byte_addr, expected, actual);
                errors = errors + 1;
            end
        end
    endtask

endmodule