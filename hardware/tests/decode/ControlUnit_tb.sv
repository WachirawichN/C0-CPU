`timescale 1ns/1ps

import ControlSignals_pkg::*;
import OtherSignals_pkg::*;

interface ControlUnitTbInterface;
    logic [31:0]                             instruction;

    logic [19:0]                             imm_field_value;
    OtherSignals_pkg::InstructionFormat      instruction_format;
    logic [4:0]                              rs1_address;
    logic [4:0]                              rs2_address;

    logic [1:0]                              alu_operand;
    ControlSignals_pkg::ALUOp                alu_op;
    OtherSignals_pkg::JmpOp                  jmp_op;
    ControlSignals_pkg::MEMRead              mem_read;
    ControlSignals_pkg::MEMWrite             mem_write;
    ControlSignals_pkg::rdSrc                rd_src;
    logic [4:0]                              rd_address;
    ControlSignals_pkg::rdWrite              rd_write;
endinterface

program ControlUnitTbProgram (
    output logic [31:0]                            instruction,

    input logic [19:0]                             imm_field_value,
    input OtherSignals_pkg::InstructionFormat      instruction_format,
    input logic [4:0]                              rs1_address,
    input logic [4:0]                              rs2_address,

    input logic [1:0]                              alu_operand,
    input ControlSignals_pkg::ALUOp                alu_op,
    input OtherSignals_pkg::JmpOp                  jmp_op,
    input ControlSignals_pkg::MEMRead              mem_read,
    input ControlSignals_pkg::MEMWrite             mem_write,
    input ControlSignals_pkg::rdSrc                rd_src,
    input logic [4:0]                              rd_address,
    input ControlSignals_pkg::rdWrite              rd_write
);
    logic [6:0] possible_opcodes [8:0] = {
        7'b0110011,
        7'b0010011,
        7'b0000011,
        7'b1100111,
        7'b0100011,
        7'b1100011,
        7'b1101111,
        7'b0110111,
        7'b0010111
    };

    initial begin

        for (int i = 0; i <  100; i = i + 1) begin
            // 0 will be use for verifying the immediate value exclusively.
            instruction = 'b0;

            // opcode
            instruction[6:0] = possible_opcodes[$urandom_range($size(possible_opcodes)-1)];

            // rd
            if (instruction[6:0] inside {7'b0110011, 7'b0010011, 7'b0000011, 7'b1100111, 7'b0110111, 7'b0010111, 7'b1101111}) begin
                instruction[11:7] = $urandom_range(2**5-1, 1);
            end

            // funct3 / rs1
            if (instruction[6:0] inside {7'b0110011, 7'b0010011, 7'b0000011, 7'b1100111, 7'b0100011, 7'b1100011}) begin
                logic [2:0] funct3;
                case (instruction[6:0])
                    7'b0110011, 7'b0010011: funct3 = $urandom_range(3'b111, 3'b000); // Arithmetic/Logic
                    7'b0000011: begin
                        // Load
                        if (!std::randomize(funct3) with {funct3 inside {3'b000, 3'b001, 3'b010, 3'b100, 3'b101};}) $fatal(1, "Failed to generate random value.");
                    end
                    7'b0100011: begin
                        // Store
                        if (!std::randomize(funct3) with {funct3 inside {3'b000, 3'b001, 3'b010};}) $fatal(1, "Failed to generate random value.");
                    end
                    7'b1100011: begin
                        // Branch
                        if (!std::randomize(funct3) with {funct3 inside {3'b000, 3'b001, 3'b100, 3'b101, 3'b110, 3'b111};}) $fatal(1, "Failed to generate random value.");
                    end
                    default: funct3 = 3'b000; // jalr
                endcase
                instruction[14:12] = funct3;
                instruction[19:15] = $urandom_range(2**5-1, 1);
            end

            // rs2
            if (instruction[6:0] inside {7'b0110011, 7'b0100011, 7'b1100011}) begin
                instruction[24:20] = $urandom_range(2**5-1, 1);
            end

            // funct7
            // R-type before I-type, only 101 of the I-type have funct7 variant
            if ((instruction[6:0] == 7'b0110011 && instruction[14:12] inside {3'b000, 3'b101}) ||
                (instruction[6:0] == 7'b0010011 && instruction[14:12] == 3'b101)) begin
                logic [6:0] funct7;
                if (!std::randomize(funct7) with {funct7 inside {7'b0000000, 7'b0100000};}) $fatal(1, "Failed to generate random value.");
                instruction[31:25] = funct7;
            end

            #1ns;
        end
        $finish;
    end
endprogram

module ControlUnit_tb;
    ControlUnitTbInterface intf();
    ControlUnit dut (
        .instruction(intf.instruction),
        .imm_field_value(intf.imm_field_value),
        .instruction_format(intf.instruction_format),
        .rs1_address(intf.rs1_address),
        .rs2_address(intf.rs2_address),
        .alu_operand(intf.alu_operand),
        .alu_op(intf.alu_op),
        .jmp_op(intf.jmp_op),
        .mem_read(intf.mem_read),
        .mem_write(intf.mem_write),
        .rd_src(intf.rd_src),
        .rd_address(intf.rd_address),
        .rd_write(intf.rd_write)
    );
    ControlUnitTbProgram test_env (
        .instruction(intf.instruction),
        .imm_field_value(intf.imm_field_value),
        .instruction_format(intf.instruction_format),
        .rs1_address(intf.rs1_address),
        .rs2_address(intf.rs2_address),
        .alu_operand(intf.alu_operand),
        .alu_op(intf.alu_op),
        .jmp_op(intf.jmp_op),
        .mem_read(intf.mem_read),
        .mem_write(intf.mem_write),
        .rd_src(intf.rd_src),
        .rd_address(intf.rd_address),
        .rd_write(intf.rd_write)
    );
endmodule