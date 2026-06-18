`timescale 1ns/1ps

module ALU (
        input logic [2:0]   func_3,
    );
    import operation_pkg::*;

    LsuOperation_e operation;

    LsuOperationDecoder operation_decoder (
        .func_3(func_3),
        .result(operation)
    );
endmodule