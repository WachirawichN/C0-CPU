`timescale 1ns/1ps

module ALU (
        input logic [31:0]  operand_1,
        input logic [31:0]  operand_2,
        input logic [2:0]   func_3,
        input logic         func_7_b_5,
        output logic [31:0] result,
        output logic zero
    );
    import operation_pkg::*;

    AluOperation_e operation;

    AluOperationDecoder operation_decoder (
        .func_3(func_3),
        .func_7_b_5(func_7_b_5),
        .result(operation)
    );

    always_comb begin
        case (operation)
            ALU_ADD  : result = operand_1 + operand_2;
            ALU_SUB  : result = operand_1 - operand_2;
            ALU_SLL  : result = operand_1 << operand_2;
            ALU_SLT  : result = signed'(operand_1) < signed'(operand_2);
            ALU_SLTU : result = operand_1 < operand_2;
            ALU_XOR  : result = operand_1 ^ operand_2;
            ALU_SRL  : result = operand_1 >> operand_2;
            ALU_SRA  : result = signed'(operand_1) >>> operand_2;
            ALU_OR   : result = operand_1 | operand_2;
            ALU_AND  : result = operand_1 & operand_2;
            default  : result = 0;
        endcase
    end

    assign zero = result == 0;
endmodule