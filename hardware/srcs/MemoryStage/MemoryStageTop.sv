`timescale 1ns/1ps

module MemoryStageTop
    import ControlSignals_pkg::*;
(
    input logic rst_n,
    input logic clk,

    input logic [31:0]  address,
    input logic [31:0]  write_data,
    input MEMRead       mem_read,
    input MEMWrite      mem_write,

    output logic [31:0] read_data
);
    DeviceDataSrc device_data_src;
    logic [31:0] data_memory_data;
    logic [31:0] lcd_read_data;
    logic [31:0] button_read_data;
    logic [31:0] selected_data;

    MemoryBus memory_bus(
        .clk(clk),
        .rst_n(rst_n)
    );
    PeripheralBus peripheral_bus(
        .clk(clk),
        .rst_n(rst_n)
    );
    LCDBus lcd_bus;
    ButtonBus button_bus;

    AddressDecoder address_decoder (
        .address(address),
        .write_data(write_data),
        .mem_read(mem_read),
        .mem_write(mem_write),

        .memory_bus(memory_bus.master),
        .peripheral_bus(peripheral_bus.master),

        .device_data_src(device_data_src)
    );

    // Devices
    DataMemory data_memory (
        .bus(memory_bus.slave),
        .memory_read_data(data_memory_data)
    );
    LCDController lcd_controller (
        .bus(peripheral_bus.slave),
        .lcd_bus(lcd_bus.master),
        .lcd_read_data(lcd_read_data)
    );
    ButtonController button_controller (
        .peripheral_bus(peripheral_bus.slave),
        .button_bus(button_bus.master),
        .button_read_data(button_read_data)
    );


    BitExtender bit_extender (
        .data(selected_data),
        .mem_read(mem_read),
        .extended_data(read_data)
    );

    // Mux for choosing data into Bit Extender
    always @(device_data_src) begin
        case (device_data_src)
            DATA_MEM: selected_data = data_memory_data;
            LCD_CONTROLLER: selected_data = lcd_read_data;
            BUTTON_CONTROLLER: selected_data = button_read_data;
            default: selected_data = '0;
        endcase
    end

endmodule