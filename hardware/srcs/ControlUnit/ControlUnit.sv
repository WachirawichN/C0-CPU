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
    always_comb begin
        
    end
endmodule