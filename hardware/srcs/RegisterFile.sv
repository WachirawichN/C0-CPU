`timescale 1ns/1ps

module RegisterFile (
        input logic clk.
        input logic [31:0] write_data,
        input logic [4:0] write_address,
        output logic [31:0] read_data_1,
        input logic [4:0] read_address_1,
        output logic [31:0] read_data_2,
        input logic [4:0] read_address_2
    );

    logic [31:0] register_array [31:0];

endmodule