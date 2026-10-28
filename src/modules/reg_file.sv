
`timescale 1ns / 1ps

module reg_file (
    input  logic        clk,
    input  logic        reset,

    input  logic        reg_write,
    input  logic [4:0]  rs1,
    input  logic [4:0]  rs2,
    input  logic [4:0]  rd,
    input  logic [31:0] write_data,

    output logic [31:0] read_data1,
    output logic [31:0] read_data2
);

    logic [31:0] regs [0:31];

    integer i;

    // Initialize registers
    always_ff @(posedge clk) begin
        if (reset) begin
            for (i = 0; i < 32; i = i + 1)
                regs[i] <= 32'b0;
        end
        else if (reg_write && (rd != 5'd0)) begin
            regs[rd] <= write_data;
        end
    end

    // Read registers
    always_comb begin
        read_data1 = (rs1 == 5'd0) ? 32'b0 : regs[rs1];
        read_data2 = (rs2 == 5'd0) ? 32'b0 : regs[rs2];
    end

endmodule
