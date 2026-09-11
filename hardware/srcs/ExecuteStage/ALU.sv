`timescale 1ns/1ps

module ALU
    import ControlSignals_pkg::*;
(
    input logic [31:0] operand_1,
    input logic [31:0] operand_2,
    input ALUOp alu_op,

    output logic [31:0] result = 0
);
    always_comb begin
        case (alu_op)
            ADD: result = operand_1 + operand_2;
            SUB: result = operand_1 - operand_2;
            SLL: result = operand_1 << operand_2;
            SLT: result = $signed(operand_1) < $signed(operand_2);
            SLTU: result = $unsigned(operand_1) < $unsigned(operand_2);
            XOR: result = operand_1 ^ operand_2;
            SRL: result = operand_1 >> operand_2;
            SRA: result = operand_1 >>> operand_2;
            OR: result = operand_1 | operand_2;
            AND: result = operand_1 & operand_2;
            default: result = 0;
        endcase
    end
endmodule