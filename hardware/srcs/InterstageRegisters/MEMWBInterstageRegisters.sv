`timescale 1ns/1ps

module MEMWBInterstageRegisters
    import ControlSignals_pkg::*;
(
    input logic clk,
    input logic rst_n,

    input PCSrc         pc_src,
    input logic [31:0]  alu_result,
    input logic [31:0]  next_address,
    input logic [31:0]  device_read_data,
    input rdSrc         rd_src,
    input logic [4:0]   rd_address,
    input rdWrite       rd_write,

    output PCSrc         pc_src_register = PCSRC_NEXT_ADDRESS,
    output logic [31:0]  alu_result_register = 0,
    output logic [31:0]  next_address_register = 0,
    output logic [31:0]  device_read_data_register = 0,
    output rdSrc         rd_src_register = RDSRC_ALU_RESULT,
    output logic [4:0]   rd_address_register = 0,
    output rdWrite       rd_write_register = NO_RD_WRITE
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (rst_n) begin
            pc_src_register <= PCSRC_NEXT_ADDRESS;
            alu_result_register <= 0;
            next_address_register <= 0;
            device_read_data_register <= 0;
            rd_src_register <= RDSRC_ALU_RESULT;
            rd_address_register <= 0;
            rd_write_register <= NO_RD_WRITE;
        end else begin
            pc_src_register <= pc_src;
            alu_result_register <= alu_result;
            next_address_register <= next_address;
            device_read_data_register <= device_read_data;
            rd_src_register <= rd_src;
            rd_address_register <= rd_address;
            rd_write_register <= rd_write;
        end
    end
endmodule