`timescale 1ns/1ps

module MemoryStageTop (
    input logic rst_n,
    input logic clk,

    input logic [31:0]  address,
    input logic [31:0]  write_data,
    input MEMRead       mem_read,
    input MEMWrite      mem_write,

    output logic [31:0] data,
);
    DeviceDataSrc device_data_src;
    logic [31:0] data_memory_data;
    logic [31:0] peripheral_controller_data;
    logic [31:0] selected_data;

    interface AddressDecodedBus;
        logic [30:0]    address;
        logic [31:0]    write_data;
        MEMRead         mem_read;
        MEMWrite        mem_write;
    endinterface
    AddressDecodedBus data_memory_bus ();
    AddressDecodedBus peripheral_controller_bus ();

    AddressDecoder address_decoder (
        .address(address),
        .write_data(write_data),
        .mem_read(mem_read),
        .mem_write(mem_write),

        .data_memory_address(data_memory_bus.address),
        .data_memory_write_data(data_memory_bus.write_data),
        .data_memory_mem_read(data_memory_bus.mem_read),
        .data_memory_mem_write(data_memory_bus.mem_write),

        .peripheral_address(peripheral_controller_bus.address),
        .peripheral_write_data(peripheral_controller_bus.write_data),
        .peripheral_mem_read(peripheral_controller_bus.mem_read),
        .peripheral_mem_write(peripheral_controller_bus.mem_write),

        .device_data_src(device_data_src)
    );
    DataMemory data_memory (
        .rst_n(rst_n),
        .clk(clk),

        .address(data_memory_bus.address),
        .write_data(data_memory_bus.write_data),
        .mem_read(data_memory_bus.mem_read),
        .mem_write(data_memory_bus.mem_write),

        .data(data_memory_data)
    );
    PeripheralController peripheral_controller (
        .rst_n(rst_n),
        .clk(clk),

        .address(peripheral_controller_bus.address),
        .write_data(peripheral_controller_bus.write_data),
        .mem_read(peripheral_controller_bus.mem_read),
        .mem_write(peripheral_controller_bus.mem_write),

        .data(peripheral_controller_data)
    );
    BitExtender bit_extender (
        .data(selected_data)
        .mem_read(mem_read)
        extended_data(data)
    );

    // Mux for choosing data into Bit Extender
    always @(device_data_src) begin
        case (device_data_src)
            PERIPHERAL: selected_data = peripheral_controller_data;
            default: selected_data = data_memory_data;
        endcase
    end

endmodule