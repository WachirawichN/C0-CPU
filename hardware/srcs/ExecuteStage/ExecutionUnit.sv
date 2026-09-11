`timescale 1ns/1ps

module ExecutionUnit
    import ControlSignals_pkg::*;
    import OtherSignals_pkg::*;
(
    input logic [31:0] extended_imm,
    input logic [31:0] rs2_data,
    input logic [31:0] current_address,
    input logic [31:0] rs1_data,
    input logic [1:0] alu_operand,
    input ALUOp alu_op,
    input ComOp com_op,
    input JmpOp jmp_op,

    output PCSrc pc_src,
    output logic [31:0] alu_result,
    output logic [31:0] next_address
);
    assign next_address = current_address + 4;

    logic [31:0] operand_1;
    logic [31:0] operand_2;

    ALU alu (
        .operand_1(operand_1),
        .operand_2(operand_2),
        .alu_op(alu_op),
        .result(alu_result)
    );
    JmpHandler jmp_handler (
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .com_op(com_op),
        .jmp_op(jmp_op),
        .pc_src(pc_src)
    );

    always_comb begin
        case (alu_operand[0])
            1'b0: operand_1 = rs1_data;
            1'b1: operand_1 = current_address;
        endcase
        case (alu_operand[1])
            1'b0: operand_2 = rs2_data;
            1'b1: operand_2 = extended_imm;
        endcase
    end
endmodule