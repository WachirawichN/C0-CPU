`timescale 1ns/1ps

module IDEXInterstageRegisters
    import ControlSignals_pkg::*;
    import OtherSignals_pkg::*;
(
    input logic rst_n,
    input logic clk,

    input logic [31:0]  extended_imm,
    input logic [31:0]  rs2_data,
    input logic [31:0]  current_address,
    input logic [31:0]  rs1_data,
    input logic [1:0]   alu_operand,
    input ALUOp         alu_op,
    input JmpOp         jmp_op,
    input MEMRead       mem_read,
    input MEMWrite      mem_write,
    input rdSrc         rd_src,
    input logic [4:0]   rd_address,
    input rdWrite       rd_write,

    output logic [31:0] extended_imm_registe        = 0,
    output logic [31:0] rs2_data_register           = 0,
    output logic [31:0] current_address_register    = 0,
    output logic [31:0] rs1_data_register           = 0,
    output logic [1:0]  alu_operand_register        = 0,
    output ALUOp        alu_op_register             = ADD,
    output JmpOp        jmp_op_register             = NO_JUMP,
    output MEMRead      mem_read_register           = NO_MEM_READ,
    output MEMWrite     mem_write_register          = NO_MEM_WRITE,
    output rdSrc        rd_src_register             = RDSRC_ALU_RESULT,
    output logic [4:0]  rd_address_register         = 5'b00000,
    output rdWrite      rd_write_register           = NO_RD_WRITE
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (rst_n) begin
            extended_imm_registe        <= 0;
            rs2_data_register           <= 0;
            current_address_register    <= 0;
            rs1_data_register           <= 0;
            alu_operand_register        <= 0;
            alu_op_register             <= ADD;
            jmp_op_register             <= NO_JUMP;
            mem_read_register           <= NO_MEM_READ;
            mem_write_register          <= NO_MEM_WRITE;
            rd_src_register             <= RDSRC_ALU_RESULT;
            rd_address_register         <= 5'b00000;
            rd_write_register           <= NO_RD_WRITE;
        end else begin
            extended_imm_registe        <= extended_imm;
            rs2_data_register           <= rs2_data;
            current_address_register    <= current_address;
            rs1_data_register           <= rs1_data;
            alu_operand_register        <= alu_operand;
            alu_op_register             <= alu_op;
            jmp_op_register             <= jmp_op;
            mem_read_register           <= mem_read;
            mem_write_register          <= mem_write;
            rd_src_register             <= rd_src;
            rd_address_register         <= rd_address;
            rd_write_register           <= rd_write;
        end
    end
    
endmodule