
`timescale 1ns / 1ps

module instr_mem #(
    parameter DEPTH = 256,
    parameter PROGRAM_FILE =
"C:/Users/peesu/OneDrive/riscv_pipelined/program_branch.hex"
) (
    input  logic [31:0] addr,
    output logic [31:0] instr
);

    logic [31:0] mem [0:DEPTH-1];

    integer i;

    initial begin
        // Initialize memory with NOP instructions
        for (i = 0; i < DEPTH; i = i + 1)
            mem[i] = 32'h00000013;

        // Load instructions from hex file
        $readmemh(PROGRAM_FILE, mem);
    end

    // Word-aligned instruction fetch
    always_comb begin
        instr = mem[addr[9:2]];
    end

endmodule
