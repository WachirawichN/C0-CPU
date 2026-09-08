`timescale 1ns/1ps

module ALU
    import ControlSignals_pkg::*;
(
    input logic [31:0] operand_1,
    input logic [31:0] operand_2,
    input ALUOp alu_op,

    output logic [31:0] result = 0,
    output logic branching_flag = 0
);
    always_comb begin
        result = 0;
        branching_flag = 0;
        case (alu_op)
            ADD: begin
               result = operand_1 + operand_2;
            end
            SUB: begin
               result = operand_1 - operand_2;
            end
            SLL: begin
               result = operand_1 << operand_2;
            end
            SLT: begin
               result = $signed(operand_1) < $signed(operand_2);
            end
            SLTU: begin
               result = $unsigned(operand_1) < $unsigned(operand_2);
            end
            XOR: begin
               result = operand_1 ^ operand_2;
            end
            SRL: begin
               result = operand_1 >> operand_2;
            end
            SRA: begin
               result = operand_1 >>> operand_2;
            end
            OR: begin
               result = operand_1 | operand_2;
            end
            AND: begin
               result = operand_1 & operand_2;
            end

            EQ: begin
               branching_flag = operand_1 == operand_2;
            end
            NEQ: begin
               branching_flag = operand_1 != operand_2;
            end
            LT: begin
               branching_flag = $signed(operand_1) < $signed(operand_2);
            end
            GE: begin
               branching_flag = $signed(operand_1) > $signed(operand_2);
            end
            LTU: begin
               branching_flag = $unsigned(operand_1) < $unsigned(operand_2);
            end
            GEU: begin
               branching_flag = $unsigned(operand_1) > $unsigned(operand_2);
            end
        endcase
    end
endmodule