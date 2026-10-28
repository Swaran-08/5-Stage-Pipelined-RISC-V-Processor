
`timescale 1ns / 1ps

module mem_wb_reg (
    input  logic        clk,
    input  logic        reset,
    input  logic        flush,

    // Data inputs
    input  logic [31:0] mem_data_in,
    input  logic [31:0] alu_result_in,
    input  logic [31:0] pc_plus4_in,

    // Register address
    input  logic [4:0]  rd_in,

    // Control inputs
    input  logic        reg_write_in,
    input  logic        result_src_in,

    // Data outputs
    output logic [31:0] mem_data_out,
    output logic [31:0] alu_result_out,
    output logic [31:0] pc_plus4_out,

    // Register address
    output logic [4:0]  rd_out,

    // Control outputs
    output logic        reg_write_out,
    output logic        result_src_out
);

    always_ff @(posedge clk) begin
        if (reset || flush) begin

            mem_data_out   <= 32'b0;
            alu_result_out <= 32'b0;
            pc_plus4_out   <= 32'b0;

            rd_out         <= 5'b0;

            reg_write_out  <= 1'b0;
            result_src_out <= 1'b0;

        end
        else begin

            mem_data_out   <= mem_data_in;
            alu_result_out <= alu_result_in;
            pc_plus4_out  <= pc_plus4_in;

            rd_out         <= rd_in;

            reg_write_out  <= reg_write_in;
            result_src_out <= result_src_in;

        end
    end

endmodule
