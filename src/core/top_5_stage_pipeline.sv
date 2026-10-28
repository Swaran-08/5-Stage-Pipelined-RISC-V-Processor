
`timescale 1ns / 1ps

module top_5_stage_pipeline (
    input logic clk,
    input logic reset
);

    // =========================================================
    // PROGRAM COUNTER
    // =========================================================

    logic [31:0] pc_current;
    logic [31:0] pc_next;
    logic [31:0] pc_plus4;

    logic pc_write_en;
    logic pipeline_stall;
    logic flush_if_id;
    logic flush_id_ex;

    assign pc_plus4 = pc_current + 32'd4;

    program_counter PC (
        .clk         (clk),
        .reset       (reset),
        .pc_write_en (pc_write_en),
        .pc_next     (pc_next),
        .pc_current  (pc_current)
    );


    // =========================================================
    // INSTRUCTION FETCH
    // =========================================================

    logic [31:0] instr_if;

    instr_mem #(
        .DEPTH        (256),
        .PROGRAM_FILE("C:/Users/peesu/OneDrive/riscv_pipelined/program_branch.hex")
    ) IMEM (
        .addr  (pc_current),
        .instr (instr_if)
    );


    // =========================================================
    // IF/ID PIPELINE REGISTER
    // =========================================================

    logic [31:0] pc_id;
    logic [31:0] instr_id;

    if_id_reg IF_ID (
        .clk       (clk),
        .reset     (reset),
        .stall     (pipeline_stall),
        .flush     (flush_if),

        .pc_in     (pc_current),
        .instr_in  (instr_if),

        .pc_out    (pc_id),
        .instr_out (instr_id)
    );


    // =========================================================
    // INSTRUCTION DECODE
    // =========================================================

    logic [6:0] opcode_id;
    logic [4:0] rs1_id;
    logic [4:0] rs2_id;
    logic [4:0] rd_id;

    logic [2:0] funct3_id;
    logic [6:0] funct7_id;

    assign opcode_id = instr_id[6:0];
    assign rs1_id    = instr_id[19:15];
    assign rs2_id    = instr_id[24:20];
    assign rd_id     = instr_id[11:7];

    assign funct3_id = instr_id[14:12];
    assign funct7_id = instr_id[31:25];


    // =========================================================
    // REGISTER FILE
    // =========================================================

    logic [31:0] reg_data1_id;
    logic [31:0] reg_data2_id;

    logic [31:0] writeback_data;

    logic [4:0]  rd_wb;
    logic        reg_write_wb;

    reg_file reg_file_inst (
        .clk        (clk),
        .reset      (reset),

        .reg_write  (reg_write_wb),
        .rs1        (rs1_id),
        .rs2        (rs2_id),
        .rd         (rd_wb),
        .write_data (writeback_data),

        .read_data1 (reg_data1_id),
        .read_data2 (reg_data2_id)
    );


    // =========================================================
    // IMMEDIATE GENERATOR
    // =========================================================

    logic [31:0] imm_id;

    immediate_generator IMM_GEN (
        .instr   (instr_id),
        .imm_out (imm_id)
    );


    // =========================================================
    // CONTROL UNIT
    // =========================================================

    logic       reg_write_id;
    logic       alu_src_id;
    logic       mem_write_id;
    logic       mem_read_id;
    logic       result_src_id;

    logic [1:0] alu_op_id;

    logic       branch_id;
    logic       jump_id;
    logic       jalr_id;
    logic       lui_id;
    logic       auipc_id;

    control_unit CU (
        .opcode     (opcode_id),

        .reg_write  (reg_write_id),
        .alu_src    (alu_src_id),
        .mem_write  (mem_write_id),
        .mem_read   (mem_read_id),
        .result_src (result_src_id),
        .alu_op     (alu_op_id),

        .branch     (branch_id),
        .jump       (jump_id),
        .jalr       (jalr_id),
        .lui        (lui_id),
        .auipc      (auipc_id)
    );


    // =========================================================
    // HAZARD DETECTION
    // =========================================================

    logic [4:0] rd_ex;
    logic       mem_read_ex;

    hazard_detection_unit HAZARD (
        .rs1_id      (rs1_id),
        .rs2_id      (rs2_id),

        .rd_ex       (rd_ex),
        .mem_read_ex (mem_read_ex),

        .stall       (pipeline_stall)
    );

    assign pc_write_en = !pipeline_stall;

    assign flush_if = flush_id_ex;


    // =========================================================
    // ID/EX PIPELINE REGISTER
    // =========================================================

    logic [31:0] pc_ex;
    logic [31:0] reg_data1_ex;
    logic [31:0] reg_data2_ex;
    logic [31:0] imm_ex;

    logic [6:0] opcode_ex;

    logic [4:0] rs1_ex;
    logic [4:0] rs2_ex;

    logic [2:0] funct3_ex;
    logic [6:0] funct7_ex;

    logic       reg_write_ex;
    logic       alu_src_ex;
    logic       mem_write_ex;
    logic       mem_read_ex;
    logic       result_src_ex;

    logic [1:0] alu_op_ex;

    logic       branch_ex;
    logic       jump_ex;
    logic       jalr_ex;
    logic       lui_ex;
    logic       auipc_ex;

    id_ex_reg ID_EX (
        .clk             (clk),
        .reset           (reset),
        .flush           (flush_id_ex),

        .pc_in           (pc_id),
        .rs1_data_in     (reg_data1_id),
        .rs2_data_in     (reg_data2_id),
        .imm_in          (imm_id),

        .rs1_in          (rs1_id),
        .rs2_in          (rs2_id),
        .rd_in           (rd_id),

        .opcode_in       (opcode_id),
        .funct3_in       (funct3_id),
        .funct7_in       (funct7_id),

        .reg_write_in    (reg_write_id),
        .alu_src_in      (alu_src_id),
        .mem_write_in    (mem_write_id),
        .mem_read_in     (mem_read_id),
        .result_src_in   (result_src_id),
        .alu_op_in       (alu_op_id),

        .branch_in       (branch_id),
        .jump_in         (jump_id),
        .jalr_in         (jalr_id),
        .lui_in          (lui_id),
        .auipc_in        (auipc_id),

        .pc_out          (pc_ex),
        .rs1_data_out    (reg_data1_ex),
        .rs2_data_out    (reg_data2_ex),
        .imm_out         (imm_ex),

        .rs1_out         (rs1_ex),
        .rs2_out         (rs2_ex),
        .rd_out          (rd_ex),

        .opcode_out      (opcode_ex),
        .funct3_out     (funct3_ex),
        .funct7_out     (funct7_ex),

        .reg_write_out   (reg_write_ex),
        .alu_src_out     (alu_src_ex),
        .mem_write_out   (mem_write_ex),
        .mem_read_out    (mem_read_ex),
        .result_src_out  (result_src_ex),
        .alu_op_out      (alu_op_ex),

        .branch_out      (branch_ex),
        .jump_out        (jump_ex),
        .jalr_out        (jalr_ex),
        .lui_out         (lui_ex),
        .auipc_out       (auipc_ex)
    );


    // =========================================================
    // FORWARDING UNIT
    // =========================================================

    logic [1:0] forward_a;
    logic [1:0] forward_b;

    logic [4:0] rd_mem;
    logic       reg_write_mem;

    forwarding_unit FORWARD (
        .rs1_ex        (rs1_ex),
        .rs2_ex        (rs2_ex),

        .rd_mem        (rd_mem),
        .reg_write_mem (reg_write_mem),

        .rd_wb         (rd_wb),
        .reg_write_wb  (reg_write_wb),

        .forward_a     (forward_a),
        .forward_b     (forward_b)
    );


    // =========================================================
    // EX/MEM FORWARDING DATA
    // =========================================================

    logic [31:0] alu_result_mem;
    logic [31:0] mem_data_mem;
    logic [31:0] pc_plus4_mem;

    logic [31:0] forward_data_mem;

    assign forward_data_mem =
        result_src_mem ? mem_data_mem : alu_result_mem;


    // =========================================================
    // ALU INPUT MULTIPLEXERS
    // =========================================================

    logic [31:0] alu_operand_a;
    logic [31:0] alu_operand_b;

    logic [31:0] forwarded_rs1;
    logic [31:0] forwarded_rs2;

    always_comb begin

        case (forward_a)

            2'b00: forwarded_rs1 = reg_data1_ex;
            2'b01: forwarded_rs1 = writeback_data;
            2'b10: forwarded_rs1 = forward_data_mem;

            default: forwarded_rs1 = reg_data1_ex;

        endcase

        case (forward_b)

            2'b00: forwarded_rs2 = reg_data2_ex;
            2'b01: forwarded_rs2 = writeback_data;
            2'b10: forwarded_rs2 = forward_data_mem;

            default: forwarded_rs2 = reg_data2_ex;

        endcase

    end


    // ALU operand A selection
    always_comb begin

        if (lui_ex)
            alu_operand_a = 32'b0;

        else if (auipc_ex || jump_ex)
            alu_operand_a = pc_ex;

        else
            alu_operand_a = forwarded_rs1;

    end


    // ALU operand B selection
    always_comb begin

        if (jump_ex)
            alu_operand_b = 32'd4;

        else if (alu_src_ex || lui_ex || auipc_ex)
            alu_operand_b = imm_ex;

        else
            alu_operand_b = forwarded_rs2;

    end


    // =========================================================
    // ALU CONTROL
    // =========================================================

    logic [3:0] alu_control_signal;

    alu_control ALU_CTRL (
        .alu_op      (alu_op_ex),
        .opcode      (opcode_ex),
        .funct3      (funct3_ex),
        .funct7_5    (funct7_ex[5]),
        .funct7_0    (funct7_ex[0]),
        .alu_control (alu_control_signal)
    );


    // =========================================================
    // ALU
    // =========================================================

    logic [31:0] alu_result_ex;
    logic        alu_zero_ex;

    alu ALU (
        .a           (alu_operand_a),
        .b           (alu_operand_b),
        .alu_control  (alu_control_signal),

        .result       (alu_result_ex),
        .zero         (alu_zero_ex)
    );


    // =========================================================
    // BRANCH AND JUMP CONTROL
    // =========================================================

    logic branch_taken_ex;
    logic jump_taken_ex;

    logic [31:0] branch_target_ex;
    logic [31:0] jalr_target_ex;

    always_comb begin

        branch_taken_ex = 1'b0;

        case (funct3_ex)

            3'b000: branch_taken_ex =
                    (forwarded_rs1 == forwarded_rs2);

            3'b001: branch_taken_ex =
                    (forwarded_rs1 != forwarded_rs2);

            3'b100: branch_taken_ex =
                    ($signed(forwarded_rs1) < $signed(forwarded_rs2));

            3'b101: branch_taken_ex =
                    ($signed(forwarded_rs1) >= $signed(forwarded_rs2));

            3'b110: branch_taken_ex =
                    (forwarded_rs1 < forwarded_rs2);

            3'b111: branch_taken_ex =
                    (forwarded_rs1 >= forwarded_rs2);

            default: branch_taken_ex = 1'b0;

        endcase

    end

    assign branch_target_ex = pc_ex + imm_ex;

    assign jalr_target_ex =
        (forwarded_rs1 + imm_ex) & 32'hFFFFFFFE;

    assign jump_taken_ex =
        jump_ex || (branch_ex && branch_taken_ex);


    // =========================================================
    // NEXT PC SELECTION
    // =========================================================

    always_comb begin

        pc_next = pc_plus4;

        if (jump_ex && jalr_ex)
            pc_next = jalr_target_ex;

        else if (jump_ex)
            pc_next = branch_target_ex;

        else if (branch_ex && branch_taken_ex)
            pc_next = branch_target_ex;

    end

    assign flush_id_ex = jump_taken_ex;


    // =========================================================
    // EX/MEM PIPELINE REGISTER
    // =========================================================

    logic [31:0] rs2_data_mem;
    logic [2:0]  funct3_mem;

    logic        mem_write_mem;
    logic        mem_read_mem;
    logic        result_src_mem;

    ex_mem_reg EX_MEM (
        .clk             (clk),
        .reset           (reset),
        .flush           (1'b0),

        .alu_result_in   (alu_result_ex),
        .rs2_data_in     (forwarded_rs2),
        .pc_plus4_in     (pc_ex + 32'd4),

        .rd_in           (rd_ex),
        .funct3_in       (funct3_ex),

        .reg_write_in    (reg_write_ex),
        .mem_write_in    (mem_write_ex),
        .mem_read_in     (mem_read_ex),
        .result_src_in   (result_src_ex),

        .alu_result_out  (alu_result_mem),
        .rs2_data_out   (rs2_data_mem),
        .pc_plus4_out   (pc_plus4_mem),

        .rd_out          (rd_mem),
        .funct3_out      (funct3_mem),

        .reg_write_out   (reg_write_mem),
        .mem_write_out   (mem_write_mem),
        .mem_read_out    (mem_read_mem),
        .result_src_out  (result_src_mem)
    );


    // =========================================================
    // DATA MEMORY
    // =========================================================

    data_mem data_mem_inst (
        .clk        (clk),

        .mem_read   (mem_read_mem),
        .mem_write  (mem_write_mem),

        .funct3     (funct3_mem),
        .addr       (alu_result_mem),
        .write_data (rs2_data_mem),

        .read_data  (mem_data_mem)
    );


    // =========================================================
    // MEM/WB PIPELINE REGISTER
    // =========================================================

    logic [31:0] mem_data_wb;
    logic [31:0] alu_result_wb;
    logic [31:0] pc_plus4_wb;

    logic        result_src_wb;

    mem_wb_reg MEM_WB (
        .clk             (clk),
        .reset           (reset),
        .flush            (1'b0),

        .mem_data_in     (mem_data_mem),
        .alu_result_in   (alu_result_mem),
        .pc_plus4_in     (pc_plus4_mem),

        .rd_in           (rd_mem),

        .reg_write_in    (reg_write_mem),
        .result_src_in   (result_src_mem),

        .mem_data_out    (mem_data_wb),
        .alu_result_out  (alu_result_wb),
        .pc_plus4_out   (pc_plus4_wb),

        .rd_out           (rd_wb),

        .reg_write_out    (reg_write_wb),
        .result_src_out   (result_src_wb)
    );


    // =========================================================
    // WRITE BACK
    // =========================================================

    always_comb begin

        if (result_src_wb)
            writeback_data = mem_data_wb;

        else
            writeback_data = alu_result_wb;

    end

endmodule
