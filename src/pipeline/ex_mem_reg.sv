
`timescale 1ns / 1ps

module ex_mem_reg (
    input  logic        clk,
    input  logic        reset,
    input  logic        flush,

    // Data inputs
    input  logic [31:0] alu_result_in,
    input  logic [31:0] rs2_data_in,
    input  logic [31:0] pc_plus4_in,

    // Register address
    input  logic [4:0]  rd_in,

    // Instruction field
    input  logic [2:0]  funct3_in,

    // Control inputs
    input  logic        reg_write_in,
    input  logic        mem_write_in,
    input  logic        mem_read_in,
    input  logic        result_src_in,

    // Data outputs
    output logic [31:0] alu_result_out,
    output logic [31:0] rs2_data_out,
    output logic [31:0] pc_plus4_out,

    // Register address
    output logic [4:0]  rd_out,

    // Instruction field
    output logic [2:0]  funct3_out,

    // Control outputs
    output logic        reg_write_out,
    output logic        mem_write_out,
    output logic        mem_read_out,
    output logic        result_src_out
);

    always_ff @(posedge clk) begin
        if (reset || flush) begin

            alu_result_out <= 32'b0;
            rs2_data_out   <= 32'b0;
            pc_plus4_out   <= 32'b0;

            rd_out         <= 5'b0;
            funct3_out     <= 3'b0;

            reg_write_out  <= 1'b0;
            mem_write_out  <= 1'b0;
            mem_read_out   <= 1'b0;
            result_src_out <= 1'b0;

        end
        else begin

            alu_result_out <= alu_result_in;
            rs2_data_out   <= rs2_data_in;
            pc_plus4_out  <= pc_plus4_in;

            rd_out         <= rd_in;
            funct3_out     <= funct3_in;

            reg_write_out  <= reg_write_in;
            mem_write_out  <= mem_write_in;
            mem_read_out   <= mem_read_in;
            result_src_out <= result_src_in;

        end
    end

endmodule
