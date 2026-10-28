`timescale 1ns / 1ps

module tb_top_5_stage_load_alu_forwarding_verify;

    logic clk;
    logic reset;

    integer errors;

    // DUT
    top_5_stage_pipeline dut (
        .clk   (clk),
        .reset (reset)
    );

    // Clock
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
        $display(" LOAD-TO-ALU FORWARDING VERIFICATION");
        $display("==============================================");

        // Reset
        repeat (3) @(posedge clk);

        reset = 0;

        // Initialize memory word 0 = 42
        dut.data_mem_inst.mem[0] = 8'h2A;
        dut.data_mem_inst.mem[1] = 8'h00;
        dut.data_mem_inst.mem[2] = 8'h00;
        dut.data_mem_inst.mem[3] = 8'h00;

        // Let pipeline execute
        repeat (30) @(posedge clk);

        #1;

        $display("");
        $display("------ REGISTER CHECKS ------");

        check_reg(1, 32'd42);
        check_reg(2, 32'd47);


        // -----------------------------------------------------
        // FINAL RESULT
        // -----------------------------------------------------

        $display("");
        $display("==============================================");

        if (errors == 0) begin

            $display("PASS: ALL LOAD-TO-ALU FORWARDING TESTS PASSED");

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