`timescale 1ns/1ps

interface MemoryBus
    import ControlSignals_pkg::*;
(
    input logic clk,
    input logic rst_n
);
    logic [30:0] address;
    logic [31:0] write_data;
    MEMRead mem_read;
    MEMWrite mem_write;

    modport master (
        output address, write_data, mem_read, mem_write
    );
    modport slave (
        input clk, rst_n, address, write_data, mem_read, mem_write
    );
endinterface

interface PeripheralBus
    import ControlSignals_pkg::*;
#(
    parameter PERIPHERAL_COUNT = 2
) (
    input logic clk,
    input logic rst_n
);
    logic cs [PERIPHERAL_COUNT-1:0];
    logic [31:0] write_data;
    MEMRead mem_read;
    MEMWrite mem_write;

    modport master (
        output cs, write_data, mem_read, mem_write
    );
    modport slave (
        input clk, rst_n, cs, write_data, mem_read, mem_write
    );
endinterface

interface LCDBus;
    logic write_data;
    logic rs;
    logic e;

    modport master (
        output write_data, rs, e
    );
    modport slave (
        input write_data, rs, e
    );
endinterface

interface ButtonBus #(
    parameter ROWS = 5,
    parameter COLS = 4
);
    logic row_out [ROWS-1:0];
    logic col_in [COLS-1:0];

    modport master (
        input col_in,
        output row_out
    );
    modport slave (
        input row_out,
        output col_in
    );
endinterface