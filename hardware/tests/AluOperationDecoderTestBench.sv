`timescale 1ns/1ps


module AluOperationDecoderTestBench;
    import alu_operation_pkg::*;
    function void OutputValidator(input int func_3, input int func_7, input AluOperation_e decoder_output);
        case (func_3)
            3'b000  : begin
                if (func_7[5]) begin
                    if (decoder_output != ALU_SUB) begin
                        $fatal(1, " -  Error matching operation, expected: %s, output %s", ALU_SUB, decoder_output.name());
                    end
                end else begin
                    if (decoder_output != ALU_ADD) begin
                        $fatal(1, " -  Error matching operation, expected: %s, output %s", ALU_ADD, decoder_output.name());
                    end
                end
            end
            3'b001  : begin
                if (decoder_output != ALU_SLL) begin
                    $fatal(1, " -  Error matching operation, expected: %s, output %s", ALU_SLL, decoder_output.name());
                end
            end
            3'b010  : begin
                if (decoder_output != ALU_SLT) begin
                    $fatal(1, " -  Error matching operation, expected: %s, output %s", ALU_SLT, decoder_output.name());
                end
            end
            3'b011  : begin
                if (decoder_output != ALU_SLTU) begin
                    $fatal(1, " -  Error matching operation, expected: %s, output %s", ALU_SLTU, decoder_output.name());
                end
            end
            3'b100  : begin
                if (decoder_output != ALU_XOR) begin
                    $fatal(1, " -  Error matching operation, expected: %s, output %s", ALU_XOR, decoder_output.name());
                end
            end
            3'b101  : begin
                if (func_7[5]) begin
                    if (decoder_output != ALU_SRA) begin
                        $fatal(1, " -  Error matching operation, expected: %s, output %s", ALU_SRA, decoder_output.name());
                    end
                end else begin
                    if (decoder_output != ALU_SRL) begin
                        $fatal(1, " -  Error matching operation, expected: %s, output %s", ALU_SRL, decoder_output.name());
                    end
                end
            end
            3'b110  : begin
                if (decoder_output != ALU_OR) begin
                    $fatal(1, " -  Error matching operation, expected: %s, output %s", ALU_OR, decoder_output.name());
                end
            end
            3'b111  : begin
                if (decoder_output != ALU_AND) begin
                    $fatal(1, " -  Error matching operation, expected: %s, output %s", ALU_AND, decoder_output.name());
                end
            end
            default : begin
                if (decoder_output != ALU_NONE) begin
                    $fatal(1, " -  Error matching operation, expected: %s, output %s", ALU_NONE, decoder_output.name());
                end
            end
        endcase
        $display(" -  Pass, operation: %s, integer value: %d", decoder_output.name(), decoder_output);
    endfunction

    logic [2:0] func_3;
    logic [6:0] func_7;
    AluOperation_e result;

    AluOperationDecoder decoder_instance(
        .func_3(func_3),
        .func_7_b_5(func_7[5]),
        .result(result)
    );

    initial begin
        func_7 = 0;
        for (int i = 0; i < 2 ** 3; i = i) begin
            func_3 = i;

            $display("func 3: %b, func 7: %b", func_3, func_7);
            #1ns;
            OutputValidator(func_3, func_7, result);

            if (func_3 == 3'b000 || func_3 == 3'b101) begin
                if (func_7) begin
                    func_7 = 7'b0000000;
                    i = i + 1;
                end else begin
                    func_7 = 7'b0100000;
                end
            end else begin
                i = i + 1;
            end
        end

        $stop();
    end
endmodule