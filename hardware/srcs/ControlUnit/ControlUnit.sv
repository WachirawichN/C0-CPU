`timescale 1ns/1ps

module ControlUnit
    import ControlSignals_pkg::*;
    import InstructionFormat_pkg::*;
(
    input logic  [31:0]                             instruction,

    output logic [19:0]                             imm_field_value,
    output InstructionFormat_pkg::InstructionFormat instruction_format,
    output logic [4:0]                              rs1_address,
    output logic [4:0]                              rs2_address,

    output logic [1:0]                              alu_operand,
    output ControlSignals_pkg::ALUOp                alu_op,
    output logic [1:0]                              jmp_op,
    output ControlSignals_pkg::MEMRead              mem_read,
    output ControlSignals_pkg::MEMWrite             mem_write,
    output ControlSignals_pkg::rdSrc                rd_src,
    output logic [4:0]                              rd_address,
    output ControlSignals_pkg::rdWrite              rd_write;
);
    logic [19:0] imm;
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    assign imm_field_value = imm;

    InstructionDecoder inst_decoder (
        .instruction(instruction),
        .raw_imm_value(imm),
        .instruction_format(instruction_format),
        .rs1_address(rs1_address),
        .rs2_address(rs2_address),
        .rd_address(rd_address),
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7)
    );
    OperationDecoder op_decoder (
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .raw_imm_value(imm),
        .alu_operand(alu_operand),
        .alu_op(alu_op),
        .jmp_op(jmp_op),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .rd_src(rd_src),
        .rd_write(rdWrite)
    );
endmodule