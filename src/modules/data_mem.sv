
`timescale 1ns / 1ps

module data_mem #(
    parameter DEPTH = 256
) (
    input  logic        clk,
    input  logic        mem_read,
    input  logic        mem_write,
    input  logic [2:0]  funct3,
    input  logic [31:0] addr,
    input  logic [31:0] write_data,

    output logic [31:0] read_data
);

    logic [7:0] mem [0:DEPTH*4-1];

    integer i;

    // Initialize data memory
    initial begin
        for (i = 0; i < DEPTH*4; i = i + 1)
            mem[i] = 8'b0;
    end

    // Memory write
    always_ff @(posedge clk) begin
        if (mem_write) begin
            case (funct3)

                // Store byte
                3'b000: begin
                    mem[addr] <= write_data[7:0];
                end

                // Store halfword
                3'b001: begin
                    mem[addr]   <= write_data[7:0];
                    mem[addr+1] <= write_data[15:8];
                end

                // Store word
                3'b010: begin
                    mem[addr]   <= write_data[7:0];
                    mem[addr+1] <= write_data[15:8];
                    mem[addr+2] <= write_data[23:16];
                    mem[addr+3] <= write_data[31:24];
                end

                default: begin
                end

            endcase
        end
    end

    // Memory read
    always_comb begin
        read_data = 32'b0;

        if (mem_read) begin
            case (funct3)

                // Load byte (signed)
                3'b000: begin
                    read_data = {{24{mem[addr][7]}}, mem[addr]};
                end

                // Load halfword (signed)
                3'b001: begin
                    read_data = {{16{mem[addr+1][7]}},
                                mem[addr+1], mem[addr]};
                end

                // Load word
                3'b010: begin
                    read_data = {mem[addr+3],
                                mem[addr+2],
                                mem[addr+1],
                                mem[addr]};
                end

                // Load byte (unsigned)
                3'b100: begin
                    read_data = {24'b0, mem[addr]};
                end

                // Load halfword (unsigned)
                3'b101: begin
                    read_data = {16'b0,
                                mem[addr+1], mem[addr]};
                end

                default: begin
                    read_data = 32'b0;
                end

            endcase
        end
    end

endmodule
