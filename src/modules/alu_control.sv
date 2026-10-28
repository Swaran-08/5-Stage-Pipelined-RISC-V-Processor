
`timescale 1ns / 1ps

module alu_control (
    input  logic [1:0] alu_op,
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic       funct7_5,
    input  logic       funct7_0,
    output logic [3:0] alu_control
);

    always_comb begin
        case (alu_op)

            // Load, Store, and AUIPC
            2'b00: alu_control = 4'b0000; // ADD

            // Branch instructions
            2'b01: begin
                case (funct3)
                    3'b000: alu_control = 4'b0001; // BEQ
                    3'b001: alu_control = 4'b0001; // BNE
                    3'b100: alu_control = 4'b0101; // BLT
                    3'b101: alu_control = 4'b0101; // BGE
                    3'b110: alu_control = 4'b0110; // BLTU
                    3'b111: alu_control = 4'b0110; // BGEU
                    default: alu_control = 4'b0001;
                endcase
            end

            // R-type and I-type arithmetic
            2'b10: begin
                case (funct3)

                    // ADD, ADDI, SUB
                    3'b000: begin
                        if (opcode == 7'b0110011 &&
                            funct7_5 &&
                            !funct7_0)
                            alu_control = 4'b0001; // SUB
                        else
                            alu_control = 4'b0000; // ADD / ADDI
                    end

                    3'b001: alu_control = 4'b0111; // SLL / SLLI
                    3'b010: alu_control = 4'b0101; // SLT / SLTI
                    3'b011: alu_control = 4'b0110; // SLTU / SLTIU
                    3'b100: alu_control = 4'b0100; // XOR / XORI

                    3'b101: begin
                        if (funct7_5)
                            alu_control = 4'b1001; // SRA / SRAI
                        else
                            alu_control = 4'b1000; // SRL / SRLI
                    end

                    3'b110: alu_control = 4'b0011; // OR / ORI
                    3'b111: alu_control = 4'b0010; // AND / ANDI

                    default: alu_control = 4'b0000;
                endcase
            end

            default: alu_control = 4'b0000;

        endcase
    end

endmodule
