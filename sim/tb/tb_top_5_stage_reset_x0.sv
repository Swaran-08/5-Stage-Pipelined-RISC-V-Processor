`timescale 1ns / 1ps

module tb_top_5_stage_reset_x0;

    logic clk;
    logic reset;
    integer errors;

    top_5_stage_pipeline dut (
        .clk   (clk),
        .reset (reset)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        reset = 1;
        errors = 0;

        // Initial reset
        repeat (3) @(posedge clk);
        reset = 0;

        // Run a few cycles, then reset the processor again
        repeat (5) @(posedge clk);
        reset = 1;

        repeat (3) @(posedge clk);
        reset = 0;

        // Allow the program to restart and execute
        repeat (25) @(posedge clk);
        #1;

        $display("");
        $display("==============================================");
        $display(" RESET / X0 VERIFICATION");
        $display("==============================================");

        check_reg(0, 32'd0);
        check_reg(1, 32'd7);
        check_reg(2, 32'd9);
        check_reg(3, 32'd11);
        check_reg(4, 32'd13);
        check_reg(5, 32'd15);
        check_reg(6, 32'd17);
        check_reg(7, 32'd19);
        check_reg(8, 32'd21);
        check_reg(9, 32'd23);

        $display("");
        $display("==============================================");

        if (errors == 0)
            $display("PASS: RESET / X0 CHECKS PASSED");
        else
            $display("FAIL: %0d CHECK(S) FAILED", errors);

        $display("==============================================");
        $finish;
    end

    task check_reg;
        input integer reg_num;
        input logic [31:0] expected;
        logic [31:0] actual;
        begin
            actual = dut.reg_file_inst.regs[reg_num];

            if (actual === expected)
                $display("PASS: x%0d = %08h", reg_num, actual);
            else begin
                $display("FAIL: x%0d expected %08h, got %08h",
                         reg_num, expected, actual);
                errors = errors + 1;
            end
        end
    endtask

endmodule