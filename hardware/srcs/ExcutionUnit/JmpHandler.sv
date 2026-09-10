`timescale 1ns/1ps

module JmpHandler
    import ControlSignals_pkg::*;
    import OtherSignals_pkg::JmpOp;
(
    input logic [31:0] rs1_data,
    input logic [31:0] rs2_data,
    input ComOp com_op,
    input JmpOp jmp_op,

    output PCSrc pc_src
);
    logic logical_result;
    logic [2:0] sum_result;
    assign sum_result = jmp_op + logical_result;
    assign pc_src = PCSrc'(sum_result[2:1]);

    // Comparator
    always_comb begin
        case (com_op)
            EQ: logical_result = rs1_data == rs2_data;
            NE: logical_result = rs1_data != rs2_data;
            LT: logical_result = $signed(rs1_data) < $signed(rs2_data);
            GE: logical_result = $signed(rs1_data) > $signed(rs2_data);
            LTU: logical_result = $unsigned(rs1_data) < $unsigned(rs2_data);
            GEU: logical_result = $unsigned(rs1_data) > $unsigned(rs2_data);
            default: logical_result = 0;
        endcase
    end
endmodule