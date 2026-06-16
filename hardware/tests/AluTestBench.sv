`timescale 1ns/1ps

module AluTestBench;
    import alu_operation_pkg::*;

    logic [31:0] op_1 = 0;
    logic [31:0] op_2 = 0;
    logic [2:0] func_3 = 0;
    logic [6:0] func_7 = 0;
    logic [31:0] result;
    logic zero;

    ALU alu_instance(
        .operand_1(op_1),
        .operand_2(op_2),
        .func_3(func_3),
        .func_7_b_5(func_7[5]),
        .result(result),
        .zero(zero)
    );

    initial begin
        for (int i = 0; i < 2 ** 3; i = i) begin
            func_3 = i;
            $display("Func 3: %b, Func 7: %b", func_3, func_7);

            for (longint j = 0; j < 2 ** 32 - 1; j++) begin
                for (longint k = 0; k < 2 ** 32 - 1; k++) begin
                    op_2 = k;
                    k = k + $urandom_range(0, 100000000);
                    #1;
                end
                op_1 = j;
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