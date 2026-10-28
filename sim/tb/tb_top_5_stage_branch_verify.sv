
`timescale 1ns / 1ps

module tb_top_5_stage_branch_verify;

    logic clk;
    logic reset;

    integer branch_count;
    integer error_count;
    integer i;

    // Expected branch funct3 values:
    // BEQ  = 000
    // BNE  = 001
    // BLT  = 100
    // BGE  = 101
    // BLTU = 110
    // BGEU = 111

    logic [2:0] expected_funct3 [0:12];
    logic       expected_taken  [0:12];

    // DUT
    top_5_stage_pipeline dut (
        .clk   (clk),
        .reset (reset)
    );

    // Clock: 10 ns period
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // Expected branch results
    initial begin
        // BEQ
        expected_funct3[0]  = 3'b000;
        expected_taken[0]   = 1'b1;

        expected_funct3[1]  = 3'b000;
        expected_taken[1]   = 1'b1;

        expected_funct3[2]  = 3'b000;
        expected_taken[2]   = 1'b0;

        // BNE
        expected_funct3[3]  = 3'b001;
        expected_taken[3]   = 1'b1;

        expected_funct3[4]  = 3'b001;
        expected_taken[4]   = 1'b0;

        // BLT
        expected_funct3[5]  = 3'b100;
        expected_taken[5]   = 1'b1;

        expected_funct3[6]  = 3'b100;
        expected_taken[6]   = 1'b0;

        // BGE
        expected_funct3[7]  = 3'b101;
        expected_taken[7]   = 1'b1;

        expected_funct3[8]  = 3'b101;
        expected_taken[8]   = 1'b0;

        // BLTU
        expected_funct3[9]  = 3'b110;
        expected_taken[9]   = 1'b1;

        expected_funct3[10] = 3'b110;
        expected_taken[10]  = 1'b0;

        // BGEU
        expected_funct3[11] = 3'b111;
        expected_taken[11]  = 1'b1;

        expected_funct3[12] = 3'b111;
        expected_taken[12]  = 1'b0;
    end

    // Reset and simulation
    initial begin
        reset        = 1'b1;
        branch_count = 0;
        error_count  = 0;

        repeat (5) @(posedge clk);

        @(negedge clk);
        reset = 1'b0;

        $display("");
        $display("==============================================");
        $display("   5-STAGE PIPELINE BRANCH VERIFICATION");
        $display("==============================================");
        $display("");

        // Allow processor to execute the program
        repeat (100) @(posedge clk);

        $display("");
        $display("==============================================");

        $display("Total branches checked : %0d", branch_count);
        $display("Total errors          : %0d", error_count);

        if (branch_count != 13) begin
            $display("FAIL: Expected 13 branch instructions, got %0d",
                     branch_count);
            error_count = error_count + 1;
        end

        if (error_count == 0) begin
            $display("PASS: ALL BRANCH TESTS PASSED");
        end
        else begin
            $display("FAIL: BRANCH VERIFICATION FAILED");
        end

        $display("==============================================");
        $finish;
    end

    // Branch verification monitor
    always @(posedge clk) begin
        if (!reset && dut.branch_ex) begin

            $display(
    "BRANCH %0d | funct3=%b | taken=%b | PC=%h",
    branch_count,
    dut.funct3_ex,
    dut.branch_taken_ex,
    dut.pc_ex
);

            if (branch_count < 13) begin

                if (dut.funct3_ex !== expected_funct3[branch_count]) begin
                    $display(
                        "ERROR: Branch %0d funct3 mismatch. Expected %b, got %b",
                        branch_count,
                        expected_funct3[branch_count],
                        dut.funct3_ex
                    );

                    error_count = error_count + 1;
                end

                if (dut.branch_taken_ex !== expected_taken[branch_count]) begin
                    $display(
                        "ERROR: Branch %0d result mismatch. Expected taken=%b, got taken=%b",
                        branch_count,
                        expected_taken[branch_count],
                        dut.branch_taken_ex
                    );

                    error_count = error_count + 1;
                end

                if ((dut.funct3_ex === expected_funct3[branch_count]) &&
                    (dut.branch_taken_ex === expected_taken[branch_count])) begin

                    $display("PASS: Branch %0d", branch_count);
                end

            end
            else begin
                $display("ERROR: Unexpected additional branch!");
                error_count = error_count + 1;
            end

            branch_count = branch_count + 1;
        end
    end

    // Debug monitor for ADDI x15, x0, -1
    // Instruction encoding: FFF00793
    always @(posedge clk) begin
        if (!reset &&
            dut.rd_ex == 5'd15 &&
            dut.rs1_ex == 5'd0 &&
            dut.imm_ex == 32'hFFFFFFFF &&
            dut.alu_src_ex) begin

            $display("");
            $display("------ DEBUG ADDI x15, x0, -1 ------");
            $display("opcode_ex          = %b", dut.opcode_ex);
            $display("rd_ex              = %d", dut.rd_ex);
            $display("rs1_ex             = %d", dut.rs1_ex);
            $display("forwarded_rs1       = %h", dut.forwarded_rs1);
            $display("imm_ex             = %h", dut.imm_ex);
            $display("alu_src_ex         = %b", dut.alu_src_ex);
            $display("alu_operand_a      = %h", dut.alu_operand_a);
            $display("alu_operand_b      = %h", dut.alu_operand_b);
            $display("alu_control_signal = %b", dut.alu_control_signal);
            $display("alu_result_ex      = %h", dut.alu_result_ex);
            $display("-----------------------------------");
            $display("");
        end
    end

    // Debug monitor for writeback to x15
    always @(posedge clk) begin
        if (!reset && dut.reg_write_wb && dut.rd_wb == 5'd15) begin
            $display(
                "WB DEBUG: x15 <= %h",
                dut.writeback_data
            );
        end
    end

endmodule
