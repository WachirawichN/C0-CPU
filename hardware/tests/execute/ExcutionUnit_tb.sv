`timescale 1ns/1ps

import ControlSignals_pkg::*;
import OtherSignals_pkg::*;

interface ExecutionUnitTbInterface;
    
endinterface

class RandomALUOp;
    rand ALUOp value;
endclass

program ExecutionunitTbProgram (
    output logic [31:0] extended_imm = 0,
    output logic [31:0] rs2_data = 0,
    output logic [31:0] current_address = 0,
    output logic [31:0] rs1_data = 0,
    output logic [1:0] alu_operand = 0,
    output ALUOp alu_op = ADD,
    output JmpOp jmp_op = NO_JUMP,

    input PCSrc pc_src,
    input logic [31:0] alu_result,
    input logic [31:0] next_address
);

    initial begin
        repeat (1000000) begin
            if (!std::randomize(extended_imm) || !std::randomize(rs2_data) || !std::randomize(current_address) || !std::randomize(rs1_data)) begin
                $fatal(2, "Unable to randomize new operand values.");
            end

            #1ns;

            if (next_address != current_address + 4) $fatal(, "Failed to compute next instruction address.")

        end
        $finish;
    end
endprogram

module ExecutionUnit_tb;

endmodule