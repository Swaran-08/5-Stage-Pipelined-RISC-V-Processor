
`timescale 1ns / 1ps

module id_ex_reg (
    input  logic        clk,
    input  logic        reset,
    input  logic        flush,

    // =========================================================
    // DATA INPUTS
    // =========================================================

    input  logic [31:0] pc_in,
    input  logic [31:0] rs1_data_in,
    input  logic [31:0] rs2_data_in,
    input  logic [31:0] imm_in,

    // =========================================================
    // REGISTER ADDRESSES
    // =========================================================

    input  logic [4:0]  rs1_in,
    input  logic [4:0]  rs2_in,
    input  logic [4:0]  rd_in,

    // =========================================================
    // INSTRUCTION FIELDS
    // =========================================================

    input  logic [6:0]  opcode_in,
    input  logic [2:0]  funct3_in,
    input  logic [6:0]  funct7_in,

    // =========================================================
    // CONTROL SIGNALS
    // =========================================================

    input  logic        reg_write_in,
    input  logic        alu_src_in,
    input  logic        mem_write_in,
    input  logic        mem_read_in,
    input  logic        result_src_in,
    input  logic [1:0]  alu_op_in,
    input  logic        branch_in,
    input  logic        jump_in,
    input  logic        jalr_in,
    input  logic        lui_in,
    input  logic        auipc_in,

    // =========================================================
    // DATA OUTPUTS
    // =========================================================

    output logic [31:0] pc_out,
    output logic [31:0] rs1_data_out,
    output logic [31:0] rs2_data_out,
    output logic [31:0] imm_out,

    // =========================================================
    // REGISTER ADDRESS OUTPUTS
    // =========================================================

    output logic [4:0]  rs1_out,
    output logic [4:0]  rs2_out,
    output logic [4:0]  rd_out,

    // =========================================================
    // INSTRUCTION FIELD OUTPUTS
    // =========================================================

    output logic [6:0]  opcode_out,
    output logic [2:0]  funct3_out,
    output logic [6:0]  funct7_out,

    // =========================================================
    // CONTROL OUTPUTS
    // =========================================================

    output logic        reg_write_out,
    output logic        alu_src_out,
    output logic        mem_write_out,
    output logic        mem_read_out,
    output logic        result_src_out,
    output logic [1:0]  alu_op_out,
    output logic        branch_out,
    output logic        jump_out,
    output logic        jalr_out,
    output logic        lui_out,
    output logic        auipc_out
);

    // =========================================================
    // PIPELINE REGISTER
    // =========================================================

    always_ff @(posedge clk) begin

        // -----------------------------------------------------
        // RESET OR FLUSH
        // -----------------------------------------------------

        if (reset || flush) begin

            // Data
            pc_out          <= 32'b0;
            rs1_data_out    <= 32'b0;
            rs2_data_out    <= 32'b0;
            imm_out         <= 32'b0;

            // Register addresses
            rs1_out         <= 5'b0;
            rs2_out         <= 5'b0;
            rd_out          <= 5'b0;

            // Instruction fields
            opcode_out      <= 7'b0;
            funct3_out      <= 3'b0;
            funct7_out      <= 7'b0;

            // Control signals
            reg_write_out   <= 1'b0;
            alu_src_out     <= 1'b0;
            mem_write_out   <= 1'b0;
            mem_read_out    <= 1'b0;
            result_src_out  <= 1'b0;
            alu_op_out      <= 2'b0;
            branch_out      <= 1'b0;
            jump_out        <= 1'b0;
            jalr_out        <= 1'b0;
            lui_out         <= 1'b0;
            auipc_out       <= 1'b0;

        end

        // -----------------------------------------------------
        // NORMAL PIPELINE OPERATION
        // -----------------------------------------------------

        else begin

            // Data
            pc_out          <= pc_in;
            rs1_data_out    <= rs1_data_in;
            rs2_data_out    <= rs2_data_in;
            imm_out         <= imm_in;

            // Register addresses
            rs1_out         <= rs1_in;
            rs2_out         <= rs2_in;
            rd_out          <= rd_in;

            // Instruction fields
            opcode_out      <= opcode_in;
            funct3_out      <= funct3_in;
            funct7_out      <= funct7_in;

            // Control signals
            reg_write_out   <= reg_write_in;
            alu_src_out     <= alu_src_in;
            mem_write_out   <= mem_write_in;
            mem_read_out    <= mem_read_in;
            result_src_out  <= result_src_in;
            alu_op_out      <= alu_op_in;
            branch_out      <= branch_in;
            jump_out        <= jump_in;
            jalr_out        <= jalr_in;
            lui_out         <= lui_in;
            auipc_out       <= auipc_in;

        end
    end

endmodule
