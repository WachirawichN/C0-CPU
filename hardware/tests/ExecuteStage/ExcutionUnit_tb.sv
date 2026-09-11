`timescale 1ns/1ps

import ControlSignals_pkg::*;
import OtherSignals_pkg::*;

interface ExecutionUnitTbInterface;
    logic [31:0] extended_imm;
    logic [31:0] rs2_data;
    logic [31:0] current_address;
    logic [31:0] rs1_data;
    logic [1:0] alu_operand;
    ALUOp alu_op;
    ComOp com_op;
    JmpOp jmp_op;
    PCSrc pc_src;
    logic [31:0] alu_result;
    logic [31:0] next_address;
endinterface

program ExecutionunitTbProgram (
    output logic [31:0] extended_imm    = 0,
    output logic [31:0] rs2_data        = 0,
    output logic [31:0] current_address = 0,
    output logic [31:0] rs1_data        = 0,
    output logic [1:0] alu_operand      = 0,
    output ALUOp alu_op                 = ADD,
    output ComOp com_op                 = EQ,
    output JmpOp jmp_op                 = NO_JUMP,

    input PCSrc pc_src,
    input logic [31:0] alu_result,
    input logic [31:0] next_address
);
    logic [31:0] operand_1;
    logic [31:0] operand_2;
    logic [31:0] target_alu_result;
    PCSrc target_pc_src;

    initial begin
        // Pure Math and Logic verification (R/I-type arithmetic and logic)
        com_op = EQ;
        jmp_op = NO_JUMP;
        repeat (1000000) begin
            // Input randomization
            assert (std::randomize(extended_imm) &&
                    std::randomize(rs2_data) &&
                    std::randomize(rs1_data) &&
                    std::randomize(alu_operand) with {alu_operand inside {2'b00, 2'b10};} &&
                    std::randomize(alu_op)
            ) else $fatal(5, "Unable to randomize new value(s).");

            // ALU operand setup
            operand_1 = rs1_data;
            case (alu_operand)
                2'b10: operand_2 = extended_imm;
                default: operand_2 = rs2_data;
            endcase

            // Expected ALU's result
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
            assert (std::randomize(current_address)) else $fatal(5, "Unable to randomize new value(s).");
            #1ns;
            assert (next_address == current_address + 4) else $fatal(2, "Mismatch value between +4 unit's output and it testbench's computed value.");
        end
        $display("Finished testing +4 unit.");


        // Jumping Verification (both conditional and unconditional)
        alu_op = ADD;
        repeat (1000000) begin
            // Input randomization
            assert (std::randomize(extended_imm) &&
                    std::randomize(rs2_data) &&
                    std::randomize(current_address) &&
                    std::randomize(rs1_data) &&
                    std::randomize(com_op) &&
                    std::randomize(jmp_op) with {jmp_op != NO_JUMP;}
            ) else $fatal(5, "Unable to randomize new value(s).");

            // Expected PCSrc
            case (jmp_op)
                BRANCH: begin
                    case (com_op)
                        EQ: target_pc_src = PCSrc'(rs1_data == rs2_data);
                        NE: target_pc_src = PCSrc'(rs1_data != rs2_data);
                        LT: target_pc_src = PCSrc'($signed(rs1_data) < $signed(rs2_data));
                        GE: target_pc_src = PCSrc'($signed(rs1_data) > $signed(rs2_data));
                        LTU: target_pc_src = PCSrc'($unsigned(rs1_data) < $unsigned(rs2_data));
                        GEU: target_pc_src = PCSrc'($unsigned(rs1_data) > $unsigned(rs2_data));
                    endcase
                    alu_operand = 2'b11;
                end
                JAL: begin
                    alu_operand = 2'b11;
                    target_pc_src = PCSRC_JUMP_ADDRESS;
                end
                JALR: begin
                    alu_operand = 2'b10;
                    target_pc_src = PCSRC_JUMP_JALR_ADDRESS;
                end
            endcase

            // Operand setup
            operand_2 = extended_imm;
            case (alu_operand)
                2'b10: operand_1 = rs1_data;
                default: operand_1 = current_address;
            endcase

            // Expected target address
            target_alu_result = operand_1 + operand_2;

            #1ns;
            assert (target_pc_src == pc_src) else $fatal(3, "Mismatch between expected PCSrc and the actual PCSrc.");
            assert (target_alu_result == alu_result) else $fatal(4, "Mismatch between expected target address and the actual address.");
        end
        $display("Finished testing EU's take on jump operation (both unconditional and conditional).");

        $finish;
    end
endprogram

module ExecutionUnit_tb;
    ExecutionUnitTbInterface intf();
    ExecutionUnit dut (
        .extended_imm(intf.extended_imm),
        .rs2_data(intf.rs2_data),
        .current_address(intf.current_address),
        .rs1_data(intf.rs1_data),
        .alu_operand(intf.alu_operand),
        .alu_op(intf.alu_op),
        .com_op(intf.com_op),
        .jmp_op(intf.jmp_op),
        .pc_src(intf.pc_src),
        .alu_result(intf.alu_result),
        .next_address(intf.next_address)
    );
    ExecutionunitTbProgram test_env (
        .extended_imm(intf.extended_imm),
        .rs2_data(intf.rs2_data),
        .current_address(intf.current_address),
        .rs1_data(intf.rs1_data),
        .alu_operand(intf.alu_operand),
        .alu_op(intf.alu_op),
        .com_op(intf.com_op),
        .jmp_op(intf.jmp_op),
        .pc_src(intf.pc_src),
        .alu_result(intf.alu_result),
        .next_address(intf.next_address)
    );
endmodule