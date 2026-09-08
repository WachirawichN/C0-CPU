`timescale 1ns/1ps

module JmpHandler
    import ControlSignals_pkg::*;
    import OtherSignals_pkg::JmpOp;
(
    input logic branching_flag,
    input JmpOp jmp_op,
    output PCSrc pc_src
);
    logic [2:0] sum_result;
    assign sum_result = jmp_op + branching_flag;
    assign pc_src = PCSrc'(sum_result[2:1]);
endmodule