`timescale 1ns / 1ps

module tb_top_5_stage_pipeline;

    logic clk;
    logic reset;

    integer errors;

    top_5_stage_pipeline dut (
        .clk   (clk),
        .reset (reset)
    );

    always #5 clk = ~clk;

    task check_reg(
        input integer reg_num,
        input logic [31:0] expected
    );
        begin
            if (dut.reg_file_inst.regs[reg_num] === expected) begin
                $display("PASS: x%0d = %0d",
                         reg_num,
                         dut.reg_file_inst.regs[reg_num]);
            end
            else begin
                $display("FAIL: x%0d expected %0d, got %0d",
                         reg_num,
                         expected,
                         dut.reg_file_inst.regs[reg_num]);
                errors = errors + 1;
            end
        end
    endtask

    initial begin
        clk    = 0;
        reset  = 1;
        errors = 0;

        // Initial reset
        repeat (4) @(posedge clk);
        reset = 0;

        // Let program execute
        repeat (100) @(posedge clk);

        $display("");
        $display("===== BRANCH INSTRUCTION CHECKS =====");

        check_reg(3,  32'd1);  // BEQ taken
        check_reg(4,  32'd2);  // BEQ not taken

        check_reg(5,  32'd3);  // BNE taken
        check_reg(6,  32'd4);  // BNE not taken

        check_reg(7,  32'd5);  // BLT taken
        check_reg(8,  32'd6);  // BLT not taken

        check_reg(9,  32'd7);  // BGE taken
        check_reg(10, 32'd8);  // BGE not taken

        check_reg(11, 32'd9);  // BLTU taken
        check_reg(12, 32'd10); // BLTU not taken

        check_reg(13, 32'd11); // BGEU taken
        check_reg(14, 32'd12); // BGEU not taken

        $display("");
        $display("===== LOAD-USE BRANCH HAZARD =====");

        check_reg(16, 32'd5);  // Loaded value
        check_reg(17, 32'd13); // Branch result marker

        $display("");
        $display("===== JALR ALIGNMENT =====");

        check_reg(19, 32'd136); // JALR link value
        check_reg(20, 32'd15);  // Target instruction marker

        $display("");
        $display("===== INITIAL TEST SUMMARY =====");

        if (errors == 0)
            $display("PASS: ALL EDGE CASE CHECKS");
        else
            $display("FAIL: %0d CHECK(S)", errors);

        // Reset CPU
        $display("");
        $display("===== RESET CHECK =====");

        reset = 1;
        repeat (3) @(posedge clk);

        // Check reset state
        check_reg(1,  32'd0);
        check_reg(3,  32'd0);
        check_reg(16, 32'd0);
        check_reg(19, 32'd0);

        reset = 0;

        // Let program restart after reset
        repeat (100) @(posedge clk);

        check_reg(1,  32'd5);
        check_reg(3,  32'd1);
        check_reg(16, 32'd5);

        if (errors == 0) begin
            $display("");
            $display("==================================");
            $display(" PASS: ALL EDGE CASE TESTS");
            $display("==================================");
        end
        else begin
            $display("");
            $display("==================================");
            $display(" FAIL: %0d CHECK(S)", errors);
            $display("==================================");
        end

        $finish;
    end

endmodule