`timescale 1ns/1ps

module AluTestBench;
    import alu_operation_pkg::*;
    function void OutputValidator(input int operand_1, input int operand_2, input AluOperation_e operation, input int alu_output);
        case (operation)
            ALU_ADD  : begin
                if (alu_output != (operand_1 + operand_2)) begin
                    $fatal(1, " -  Operation: %s, Operand 1: %d, Operand 2: %d, Expected output: %d, Actual output: %d", operation.name(), operand_1, operand_2, operand_1 + operand_2, alu_output);
                end
            end
            ALU_SUB  : begin
                if (alu_output != (operand_1 - operand_2)) begin
                    $fatal(1, " -  Operation: %s, Operand 1: %d, Operand 2: %d, Expected output: %d, Actual output: %d", operation.name(), operand_1, operand_2, operand_1 - operand_2, alu_output);
                end
            end
            ALU_SLL  : begin
                if (alu_output != (operand_1 << operand_2)) begin
                    $fatal(1, " -  Operation: %s, Operand 1: %d, Operand 2: %d, Expected output: %b, Actual output: %b", operation.name(), operand_1, operand_2, operand_1 << operand_2, alu_output);
                end
            end
            ALU_SLT  : begin
                if (alu_output != (operand_1 < operand_2)) begin
                    $fatal(1, " -  Operation: %s, Operand 1: %d, Operand 2: %d, Expected output: %d, Actual output: %d", operation.name(), operand_1, operand_2, operand_1 < operand_2, alu_output);
                end
            end
            ALU_SLTU : begin
                if (alu_output != (unsigned'(operand_1) < unsigned'(operand_2))) begin
                    $fatal(1, " -  Operation: %s, Operand 1: %d, Operand 2: %d, Expected output: %d, Actual output: %d", operation.name(), unsigned'(operand_1), unsigned'(operand_2), unsigned'(operand_1) < unsigned'(operand_2), alu_output);
                end
            end
            ALU_XOR  : begin
                if (alu_output != (operand_1 ^ operand_2)) begin
                    $fatal(1, " -  Operation: %s, Operand 1: %b, Operand 2: %b, Expected output: %b, Actual output: %b", operation.name(), operand_1, operand_2, operand_1 ^ operand_2, alu_output);
                end
            end
            ALU_SRL  : begin
                if (alu_output != (operand_1 >> operand_2)) begin
                    $fatal(1, " -  Operation: %s, Operand 1: %b, Operand 2: %d, Expected output: %b, Actual output: %b", operation.name(), operand_1, operand_2, operand_1 >> operand_2, alu_output);
                end
            end
            ALU_SRA  : begin
                if (alu_output != (operand_1 >>> operand_2)) begin
                    $fatal(1, " -  Operation: %s, Operand 1: %b, Operand 2: %d, Expected output: %b, Actual output: %b", operation.name(), operand_1, operand_2, operand_1 >>> operand_2, alu_output);
                end
            end
            ALU_OR   : begin
                if (alu_output != (operand_1 | operand_2)) begin
                    $fatal(1, " -  Operation: %s, Operand 1: %b, Operand 2: %b, Expected output: %b, Actual output: %b", operation.name(), operand_1, operand_2, operand_1 | operand_2, alu_output);
                end
            end
            ALU_AND  : begin
                if (alu_output != (operand_1 & operand_2)) begin
                    $fatal(1, " -  Operation: %s, Operand 1: %b, Operand 2: %b, Expected output: %b, Actual output: %b", operation.name(), operand_1, operand_2, operand_1 & operand_2, alu_output);
                end
            end
        endcase
    endfunction

    logic [31:0] op_1;
    logic [31:0] op_2;
    logic [2:0] func_3;
    logic [6:0] func_7;
    logic [31:0] result;
    logic zero;

    AluOperation_e operation;
    AluOperationDecoder decoder_instance(
        .func_3(func_3),
        .func_7_b_5(func_7[5]),
        .result(operation)
    );
    ALU alu_instance(
        .operand_1(op_1),
        .operand_2(op_2),
        .func_3(func_3),
        .func_7_b_5(func_7[5]),
        .result(result),
        .zero(zero)
    );


    initial begin
        func_7 = 0;
        for (int i = 0; i < 2 ** 3; i = i) begin
            func_3 = i;

            for (longint j = 0; j < 2 ** 32 - 1; j++) begin
                op_1 = j;
                for (longint k = 0; k < 2 ** 32 - 1; k++) begin
                    op_2 = k;
                    k = k + $urandom_range(0, 100000000);
                    #1;
                    OutputValidator(op_1, op_2, operation, result);
                end
                j = j + $urandom_range(0, 100000000);
            end

            if (func_3 == 3'b000 || func_3 == 3'b101) begin
                if (!func_7) begin
                    func_7 = 7'b0100000;
                end else begin
                    func_7 = 7'b0000000;
                    i = i + 1;
                end
            end else begin
                i = i + 1;
            end
        end

        $stop();
    end
endmodule