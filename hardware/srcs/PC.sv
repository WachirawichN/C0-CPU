`timescale 1ns/1ps

module PC (
    input wire rst_n,
    input wire pc_src,
    input wire[31:0] jump_address,
    input wire clk,

    output reg[31:0] address
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (rst_n) begin
            address <= 0;
        end else begin
            case (pc_src)
                1'b1: address <= jump_address;
                default: address <= address + 4;
            endcase
        end
    end
endmodule