`timescale 1ns/1ps

module IDEXInterstageRegisters
    import ControlSignals_pkg::*;
    import OtherSignals_pkg::*;
(
    input logic rst_n,
    input logic clk,

    input PCSrc         pc_src,
    input logic [31:0]  alu_result,
    input logic [31:0]  next_address,
    input logic [31:0]  rs2_data,
    input MEMRead       mem_read,
    input MEMWrite      mem_write,
    input rdSrc         rd_src,
    input logic [4:0]   rd_address,
    input rdWrite       rd_write,

    output PCSrc        pc_src_register         = PCSRC_NEXT_ADDRESS,
    output logic [31:0] alu_result_register     = 0,
    output logic [31:0] next_address_register   = 0,
    output logic [31:0] rs2_data_register       = 0,
    output MEMRead      mem_read_register       = NO_MEM_READ,
    output MEMWrite     mem_write_register      = NO_MEM_WRITE,
    output rdSrc        rd_src_register         = RDSRC_ALU_RESULT,
    output logic [4:0]  rd_address_register     = 5'b00000,
    output rdWrite      rd_write_register       = NO_RD_WRITE
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (rst_n) begin
            pc_src_register         <= PCSRC_NEXT_ADDRESS;
            alu_result_register     <= 0;
            next_address_register   <= 0;
            rs2_data_register       <= 0;
            mem_read_register       <= NO_MEM_READ;
            mem_write_register      <= NO_MEM_WRITE;
            rd_src_register         <= RDSRC_ALU_RESULT;
            rd_address_register     <= 5'b00000;
            rd_write_register       <= NO_RD_WRITE;
        end else begin
            pc_src_register         <= pc_src;
            alu_result_register     <= alu_result;
            next_address_register   <= next_address;
            rs2_data_register       <= rs2_data;
            mem_read_register       <= mem_read;
            mem_write_register      <= mem_write;
            rd_src_register         <= rd_src;
            rd_address_register     <= rd_address;
            rd_write_register       <= rd_write;
        end
    end
    
endmodule