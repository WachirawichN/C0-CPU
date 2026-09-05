`timescale 1ns/1ps

module OperationDecoder
    import ControlSignals_pkg::*;
    import OtherSignals_pkg::*;
(
    input logic  [6:0]                  opcode,
    input logic  [2:0]                  funct3,
    input logic  [6:0]                  funct7,
    input logic  [19:0]                 raw_imm_value,

    output logic [1:0]                  alu_operand         = 2'b00,
    output ControlSignals_pkg::ALUOp    alu_op              = ADD,
    output logic [1:0]                  jmp_op              = 2'b00,
    output ControlSignals_pkg::MEMRead  mem_read            = NO_MEM_READ,
    output ControlSignals_pkg::MEMWrite mem_write           = NO_MEM_WRITE,
    output ControlSignals_pkg::rdSrc    rd_src              = RDSRC_ALU_RESULT,
    output ControlSignals_pkg::rdWrite  rd_write            = NO_RD_WRITE
);
    logic funct7_bit;
    logic special_imm_bit;
    assign funct7_bit = funct7[5];
    assign special_imm_bit = raw_imm_value[5];

    always_comb begin
        case (opcode)
            7'b0110011: begin
                // R-type Arithmetic and Logic
                alu_operand = 2'b00;
                alu_op      = ALUOp'({1'b0, funct7_bit, funct3});
                jmp_op      = NO_JUMP;
                mem_read    = NO_MEM_READ;
                mem_write   = NO_MEM_WRITE;
                rd_src      = RDSRC_ALU_RESULT;
                rd_write    = RD_WRITE;
            end
            7'b0010011: begin
                // I-type Arithmetic and Logic
                alu_operand = 2'b10;
                case (funct3)
                    3'b101: alu_op = ALUOp'({1'b0, special_imm_bit, funct3});
                    default: alu_op = ALUOp'(5'(funct3));
                endcase
                jmp_op      = NO_JUMP;
                mem_read    = NO_MEM_READ;
                mem_write   = NO_MEM_WRITE;
                rd_src      = RDSRC_ALU_RESULT;
                rd_write    = RD_WRITE;
            end
            7'b0000011: begin
                // Load
                alu_operand = 2'b10;
                alu_op      = ADD;
                jmp_op      = NO_JUMP;
                mem_read    = MEMRead'(funct3);
                mem_write   = NO_MEM_WRITE;
                rd_src      = RDSRC_DEVICE_READ_DATA;
                rd_write    = RD_WRITE;
            end
            7'b0100011: begin
                // Store
                alu_operand = 2'b10;
                alu_op      = ADD;
                jmp_op      = NO_JUMP;
                mem_read    = NO_MEM_READ;
                mem_write   = MEMWrite'(funct3[1:0]);
                rd_src      = RDSRC_ALU_RESULT;
                rd_write    = NO_RD_WRITE;
            end
            7'b1100011: begin
                // Branch
                alu_operand = 2'b00;
                alu_op      = ALUOp'({2'b10, funct3});
                jmp_op      = BRANCH;
                mem_read    = NO_MEM_READ;
                mem_write   = NO_MEM_WRITE;
                rd_src      = RDSRC_ALU_RESULT;
                rd_write    = NO_RD_WRITE;
            end
            7'b1101111: begin
                // JAL
                alu_operand = 2'b11;
                alu_op      = ADD;
                jmp_op      = JAL;
                mem_read    = NO_MEM_READ;
                mem_write   = NO_MEM_WRITE;
                rd_src      = RDSRC_NEXT_ADDRESS;
                rd_write    = RD_WRITE;
            end
            7'b1100111: begin
                // JALR
                alu_operand = 2'b10;
                alu_op      = ADD;
                jmp_op      = JALR;
                mem_read    = NO_MEM_READ;
                mem_write   = NO_MEM_WRITE;
                rd_src      = RDSRC_NEXT_ADDRESS;
                rd_write    = RD_WRITE;
            end
            7'b0110111: begin
                // LUI
                alu_operand = 2'b10;
                alu_op      = ADD;
                jmp_op      = NO_JUMP;
                mem_read    = NO_MEM_READ;
                mem_write   = NO_MEM_WRITE;
                rd_src      = RDSRC_ALU_RESULT;
                rd_write    = RD_WRITE;
            end
            7'b0010111: begin
                // AUIPC
                alu_operand = 2'b11;
                alu_op      = ADD;
                jmp_op      = NO_JUMP;
                mem_read    = NO_MEM_READ;
                mem_write   = NO_MEM_WRITE;
                rd_src      = RDSRC_ALU_RESULT;
                rd_write    = RD_WRITE;
            end
            default: begin
                // Default to NOP operation (addi zero, zero, 0)
                alu_operand = 2'b00;
                alu_op      = ADD;
                jmp_op      = 2'b00;
                mem_read    = NO_MEM_READ;
                mem_write   = NO_MEM_WRITE;
                rd_src      = RDSRC_ALU_RESULT;
                rd_write    = NO_RD_WRITE;
            end
        endcase
    end
    
endmodule