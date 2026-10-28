`timescale 1ns / 1ps

module tb_top_5_stage_forwarding_verify;

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


    // ---------------------------------------------------------
    // CHECK REGISTER TASK
    // ---------------------------------------------------------

    task check_reg(
        input integer reg_num,
        input logic [31:0] expected
    );

        begin
            if (dut.reg_file_inst.regs[reg_num] === expected) begin

                $display(
                    "PASS: x%0d = %08h",
                    reg_num,
                    expected
                );

            end
            else begin

                $display(
                    "FAIL: x%0d expected %08h, got %08h",
                    reg_num,
                    expected,
                    dut.reg_file_inst.regs[reg_num]
                );

                errors = errors + 1;

            end
        end

    endtask


    // ---------------------------------------------------------
    // TEST
    // ---------------------------------------------------------

    initial begin

        clk    = 0;
        reset  = 1;
        errors = 0;

        $display("");
        $display("==============================================");
        $display(" ALU DATA FORWARDING VERIFICATION");
        $display("==============================================");

        // Hold reset
        repeat (3) @(posedge clk);

        reset = 0;

        // Allow instructions to pass through the pipeline
        repeat (30) @(posedge clk);

        #1;

        $display("");
        $display("------ REGISTER CHECKS ------");

        check_reg(1, 32'd10);
        check_reg(2, 32'd15);
        check_reg(3, 32'd18);

        check_reg(4, 32'd7);
        check_reg(5, 32'd9);

        check_reg(6, 32'd16);
        check_reg(7, 32'd26);


        // -----------------------------------------------------
        // FINAL RESULT
        // -----------------------------------------------------

        $display("");
        $display("==============================================");

        if (errors == 0) begin

            $display("PASS: ALL ALU FORWARDING TESTS PASSED");

        end
        else begin

            $display(
                "FAIL: %0d CHECK(S) FAILED",
                errors
            );

        end

        $display("==============================================");

        $finish;

    end

endmodule