
`timescale 1ns / 1ps

module program_counter (
    input  logic        clk,
    input  logic        reset,
    input  logic        pc_write_en,
    input  logic [31:0] pc_next,

    output logic [31:0] pc_current
);

    always_ff @(posedge clk) begin
        if (reset)
            pc_current <= 32'b0;
        else if (pc_write_en)
            pc_current <= pc_next;
    end

endmodule
