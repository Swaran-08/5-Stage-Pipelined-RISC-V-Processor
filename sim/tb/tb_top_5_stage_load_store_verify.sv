
`timescale 1ns / 1ps

module tb_top_5_stage_load_store_verify;

    logic clk;
    logic reset;

    integer error_count;

    // =========================================================
    // DUT
    // =========================================================

    top_5_stage_pipeline dut (
        .clk   (clk),
        .reset (reset)
    );

    // =========================================================
    // CLOCK: 10 ns period
    // =========================================================

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // =========================================================
    // TEST
    // =========================================================

    initial begin

        reset      = 1'b1;
        error_count = 0;

        $display("");
        $display("==============================================");
        $display(" LOAD / STORE + LOAD-USE HAZARD VERIFICATION");
        $display("==============================================");

        // Reset the processor
        repeat (5) @(posedge clk);

        @(negedge clk);
        reset = 1'b0;

        // Allow the program to finish
        repeat (40) @(posedge clk);

        // Wait for final updates
        #1;

        $display("");
        $display("------ REGISTER CHECKS ------");

        // x1 = 42
        if (dut.reg_file_inst.regs[1] === 32'd42) begin
            $display("PASS: x1 = 42");
        end
        else begin
            $display("FAIL: x1 expected 42, got %h",
                     dut.reg_file_inst.regs[1]);
            error_count = error_count + 1;
        end

        // x2 = mem[0] = 42
        if (dut.reg_file_inst.regs[2] === 32'd42) begin
            $display("PASS: x2 = 42 (LW)");
        end
        else begin
            $display("FAIL: x2 expected 42, got %h",
                     dut.reg_file_inst.regs[2]);
            error_count = error_count + 1;
        end

        // x3 = x2 + 1 = 43
        if (dut.reg_file_inst.regs[3] === 32'd43) begin
            $display("PASS: x3 = 43 (load-use hazard)");
        end
        else begin
            $display("FAIL: x3 expected 43, got %h",
                     dut.reg_file_inst.regs[3]);
            error_count = error_count + 1;
        end

        $display("");
        $display("------ MEMORY CHECKS ------");

        // mem[0] is the lowest byte of word 0
        // mem[1] is the next byte
        // mem[2] is the next byte
        // mem[3] is the highest byte
        //
        // Stored value = 42 = 32'h0000002A
        // Expected bytes: 2A 00 00 00

        if (dut.data_mem_inst.mem[0] === 8'h2A) begin
            $display("PASS: memory byte 0 = 2A");
        end
        else begin
            $display("FAIL: memory byte 0 expected 2A, got %h",
                     dut.data_mem_inst.mem[0]);
            error_count = error_count + 1;
        end

        if (dut.data_mem_inst.mem[1] === 8'h00) begin
            $display("PASS: memory byte 1 = 00");
        end
        else begin
            $display("FAIL: memory byte 1 expected 00, got %h",
                     dut.data_mem_inst.mem[1]);
            error_count = error_count + 1;
        end

        if (dut.data_mem_inst.mem[2] === 8'h00) begin
            $display("PASS: memory byte 2 = 00");
        end
        else begin
            $display("FAIL: memory byte 2 expected 00, got %h",
                     dut.data_mem_inst.mem[2]);
            error_count = error_count + 1;
        end

        if (dut.data_mem_inst.mem[3] === 8'h00) begin
            $display("PASS: memory byte 3 = 00");
        end
        else begin
            $display("FAIL: memory byte 3 expected 00, got %h",
                     dut.data_mem_inst.mem[3]);
            error_count = error_count + 1;
        end

        $display("");
        $display("==============================================");

        if (error_count == 0) begin
            $display("PASS: ALL LOAD/STORE TESTS PASSED");
        end
        else begin
            $display("FAIL: %0d CHECK(S) FAILED", error_count);
        end

        $display("==============================================");

        $finish;

    end

    // =========================================================
    // DEBUG: LOAD/STORE CONTROL SIGNALS
    // =========================================================

    always @(posedge clk) begin

        if (!reset) begin

            if (dut.mem_write_mem) begin
                $display(
                    "STORE DEBUG: addr=%h data=%h funct3=%b",
                    dut.alu_result_mem,
                    dut.rs2_data_mem,
                    dut.funct3_mem
                );
            end

            if (dut.mem_read_mem) begin
                $display(
                    "LOAD DEBUG: addr=%h read_data=%h funct3=%b",
                    dut.alu_result_mem,
                    dut.mem_data_mem,
                    dut.funct3_mem
                );
            end

        end

    end

endmodule
