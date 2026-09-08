`timescale 1ns/1ps

import ControlSignals_pkg::*;

interface RegisterFileTbInterface;
    logic rst_n;
    logic clk;

    logic [4:0] read_address_1;
    logic [4:0] read_address_2;
    logic [31:0] write_data;
    rdWrite write_enable;
    logic [4:0] write_address;

    logic [31:0] read_register_1_data;
    logic [31:0] read_register_2_data;
endinterface

program RegisterFileTbProgram (
    output logic rst_n = 1,
    output logic clk = 1,

    output logic [4:0] read_address_1 = 0,
    output logic [4:0] read_address_2 = 0,
    output logic [31:0] write_data = 0,
    output rdWrite write_enable = NO_RD_WRITE,
    output logic [4:0] write_address = 0,

    input logic [31:0] read_register_1_data,
    input logic [31:0] read_register_2_data
);
    initial begin
        clk = 1;
        forever #1ns clk = !clk;
    end
    initial begin
        // Writing section
        write_enable = RD_WRITE;
        for (int i = 0; i < 32; i = i + 1) begin
            write_data = i;
            write_address = i;
            @(posedge clk);
            @(negedge clk);
        end
        write_enable = NO_RD_WRITE;

        // Reading section
        for (int i = 0; i < 16; i = i + 1) begin
            read_address_1 = i * 2;
            read_address_2 = i * 2 + 1;
            #1;
            if (read_register_1_data != read_address_1 || read_register_2_data != read_address_2) $fatal(1, "Register File failed to record its value with its address.");
        end

        // Clearing section
        rst_n = 0;
        #1ns;
        rst_n = 1;
        for (int i = 0; i < 16; i = i + 1) begin
            read_address_1 = i * 2;
            read_address_2 = i * 2 + 1;
            #1;
            if (read_register_1_data != 0 || read_register_2_data != 0) $fatal(2, "Register File failed to cleared its register value(s).");
        end

        $finish;
    end
endprogram

module RegisterFile_tb;
    RegisterFileTbInterface intf();
    RegisterFile dut (
        .rst_n(intf.rst_n),
        .clk(intf.clk),
        .read_address_1(intf.read_address_1),
        .read_address_2(intf.read_address_2),
        .write_data(intf.write_data),
        .write_enable(intf.write_enable),
        .write_address(intf.write_address),
        .read_register_1_data(intf.read_register_1_data),
        .read_register_2_data(intf.read_register_2_data)
    );
    RegisterFileTbProgram test_env (
        .rst_n(intf.rst_n),
        .clk(intf.clk),
        .read_address_1(intf.read_address_1),
        .read_address_2(intf.read_address_2),
        .write_data(intf.write_data),
        .write_enable(intf.write_enable),
        .write_address(intf.write_address),
        .read_register_1_data(intf.read_register_1_data),
        .read_register_2_data(intf.read_register_2_data)
    );
endmodule