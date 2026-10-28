`timescale 1ns / 1ps

module tb_top_5_stage_load_store_edge_cases;

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
    // REGISTER CHECK TASK
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
    // MEMORY BYTE CHECK TASK
    // ---------------------------------------------------------

    task check_mem_byte(
        input integer byte_addr,
        input logic [7:0] expected
    );
        begin
            if (dut.data_mem_inst.mem[byte_addr] === expected) begin
                $display(
                    "PASS: mem[%0d] = %02h",
                    byte_addr,
                    expected
                );
            end
            else begin
                $display(
                    "FAIL: mem[%0d] expected %02h, got %02h",
                    byte_addr,
                    expected,
                    dut.data_mem_inst.mem[byte_addr]
                );

                errors = errors + 1;
            end
        end
    endtask


    // ---------------------------------------------------------
    // MAIN TEST
    // ---------------------------------------------------------

    initial begin

        clk    = 0;
        reset  = 1;
        errors = 0;

        $display("");
        $display("==============================================");
        $display(" LOAD / STORE EDGE CASE VERIFICATION");
        $display("==============================================");

        // Reset
        repeat (3) @(posedge clk);

        reset = 0;

        // Allow pipeline to finish
        repeat (40) @(posedge clk);

        #1;

        // -----------------------------------------------------
        // REGISTER CHECKS
        // -----------------------------------------------------

        $display("");
        $display("------ REGISTER CHECKS ------");

        // Source values
        check_reg(1, 32'h00000080);
        check_reg(2, 32'h00001234);
        check_reg(3, 32'h89ABCDEF);

        // Load checks
        check_reg(4, 32'hFFFFFF80); // LB sign extension
        check_reg(5, 32'h00000080); // LBU zero extension

        check_reg(6, 32'h00001234); // LH
        check_reg(7, 32'h00001234); // LHU

        check_reg(8, 32'h89ABCDEF); // LW

        // Load-to-ALU dependency
        check_reg(9, 32'h89ABCDF0);


        // -----------------------------------------------------
        // MEMORY CHECKS
        // -----------------------------------------------------

        $display("");
        $display("------ MEMORY BYTE CHECKS ------");

        // SB x1, 0(x0)
        check_mem_byte(0, 8'h80);

        // SH x2, 2(x0)
        check_mem_byte(1, 8'h00);
        check_mem_byte(2, 8'h34);
        check_mem_byte(3, 8'h12);

        // SW x3, 4(x0)
        check_mem_byte(4, 8'hEF);
        check_mem_byte(5, 8'hCD);
        check_mem_byte(6, 8'hAB);
        check_mem_byte(7, 8'h89);


        // -----------------------------------------------------
        // FINAL RESULT
        // -----------------------------------------------------

        $display("");
        $display("==============================================");

        if (errors == 0) begin
            $display(
                "PASS: ALL LOAD/STORE EDGE CASES PASSED"
            );
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