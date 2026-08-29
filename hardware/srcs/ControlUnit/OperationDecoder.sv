`timescale 1ns/1ps

module OperationDecoder (
    input logic  [6:0]                  opcode,
    input logic  [2:0]                  funct3,
    input logic  [6:0]                  funct7,
    input logic  [19:0]                 imm_field_value,

    output logic [1:0]                  alu_operand         = 2'b00,
    output ControlSignals_pkg::ALUOp    alu_op              = ADD,
    output logic [1:0]                  jmp_op              = 2'b00,
    output ControlSignals_pkg::MEMRead  mem_read            = NO_READ,
    output ControlSignals_pkg::MEMWrite mem_write           = NO_WRITE,
    output ControlSignals_pkg::rdSrc    rd_src              = ALU_RESULT,
    output ControlSignals_pkg::rdWrite  rd_write            = NO_WRITE;
);
    
endmodule