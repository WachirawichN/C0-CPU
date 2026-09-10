`timescale 1ns/1ps

import ControlSignals_pkg::*;
import OtherSignals_pkg::*;

interface ExecutionUnitTbInterface;
    
endinterface

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
    logic [31:0] operand_1;
    logic [31:0] operand_2;
    logic [31:0] target_alu_result;

    initial begin
        // Normal Math Verification (R/I-type arithmetic and logic)
        repeat (1000000) begin
            assert (std::randomize(extended_imm) &&
                    std::randomize(rs2_data) &&
                    std::randomize(rs1_data) &&
                    std::randomize(alu_operand) with {alu_operand inside {2'b00, 2'b10};} &&
                    std::randomize(alu_op)
            ) else $fatal(4, "Unable to randomize new value(s).");
            operand_1 = rs1_data;
            case (alu_operand)
                2'b10: operand_2 = extended_imm;
                default: operand_2 = rs2_data;
            endcase
            case (alu_op)
                ADD: target_alu_result = operand_1 + operand_2;
                SUB: target_alu_result = operand_1 - operand_2;
                SLL: target_alu_result = operand_1 << operand_2;
                SLT: target_alu_result = $signed(operand_1) < $signed(operand_2);
                SLTU: target_alu_result = $unsigned(operand_1) < $unsigned(operand_2);
                XOR: target_alu_result = operand_1 ^ operand_2;
                SRL: target_alu_result = operand_1 >> operand_2;
                SRA: target_alu_result = operand_1 >>> operand_2;
                OR: target_alu_result = operand_1 | operand_2;
                AND: target_alu_result = operand_1 & operand_2;
            endcase
            #1ns;
            assert (target_alu_result == alu_result) else $fatal(1, "Mismatch value between target ALU result and its actual output.");
        end
        $display("Finished testing ALU normal math operation.");

        // +4 Verification
        repeat (1000000) begin
            assert (std::randomize(current_address)) else $fatal(4, "Unable to randomize new value(s).");
            #1ns;
            assert (next_address == current_address + 4) else $fatal(2, "Mismatch value between +4 unit's output and it testbench's computed value.");
        end
        $display("Finished testing +4 unit.");

        // Jumping Verification (both conditional and unconditional)
        alu_op = ADD;
        repeat (1000000) begin
            assert (std::randomize(extended_imm) &&
                    std::randomize(rs2_data) &&
                    std::randomize(current_address) &&
                    std::randomize(rs1_data) &&
                    std::randomize(com_op) &&
                    std::randomize(jmp_op) with {jmp_op != NO_JUMP;}
            ) else $fatal(4, "Unable to randomize new value(s).");
            case (jmp_op)
                BRANCH: 
                JAL: 
                JALR:
            endcase
        end
        $display("Finished testing EU's take on jump operation (both unconditional and conditional).");

        $finish;
    end
endprogram

module ExecutionUnit_tb;

endmodule