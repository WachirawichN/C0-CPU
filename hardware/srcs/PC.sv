`timescale 1ns/1ps

module PC (
    input logic         rst_n,
    input logic         pc_src,
    input logic [31:0]  jump_address,
    input logic         clk,

    output logic [31:0] address = 0
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            address <= 0;
        end else begin
            case (pc_src)
                1'b1: address <= jump_address;
                default: address <= address + 4;
            endcase
        end
    end
endmodule