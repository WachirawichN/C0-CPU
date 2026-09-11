`timescale 1ns/1ps

module PeripheralController
    import ControlSignals_pkg::*;
(
    input logic         rst_n,
    input logic         clk,
    
    input logic [30:0]  address,
    input logic [31:0]  write_data,
    input MEMRead       mem_read,
    input MEMWrite      mem_write,

    output logic [31:0] data = 0
);

endmodule