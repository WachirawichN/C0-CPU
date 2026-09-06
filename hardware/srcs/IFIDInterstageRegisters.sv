`timescale 1ns/1ps

module IFIDInterstageRegisters (
    input logic rst_n;
    input logic [31:0] instruction;
    input logic [31:0] address;
    input logic clk;

    output logic [31:0] instruction_register = 0;
    output logic [31:0] address_register = 0;
);
    always_ff @(posedge clk or negedge rst_n) begin : blockName
        if (!rst_n) begin
            instruction <= 0;
            address <= 0;
        end else begin
            instruction_register <= instruction;
            address_register <= address;
        end
    end
endmodule