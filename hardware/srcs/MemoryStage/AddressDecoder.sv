`timescale 1ns/1ps

module AddressDecoder
    import ControlSignals_pkg::*;
(
    input logic [31:0]      address,
    input logic [31:0]      write_data,
    input MEMRead           mem_read,
    input MEMWrite          mem_write

    output logic [30:0]     data_memory_address     = 0,
    output logic [31:0]     data_memory_write_data  = 0,
    output MEMRead          data_memory_mem_read    = NO_MEM_READ,
    output MEMWrite         data_memory_mem_write   = NO_MEM_WRITE,

    output logic [30:0]     peripheral_address      = 0,
    output logic [31:0]     peripheral_write_data   = 0,
    output MEMRead          peripheral_mem_read     = NO_MEM_READ,
    output MEMWrite         peripheral_mem_write    = NO_MEM_WRITE,

    output DeviceDataSrc    device_data_src         = DATA_MEM
);
    // Behavior of the processor try to read and write at the same time.
    MEMRead mem_read_validated;
    MEMWrite mem_write_validated;
    assign mem_read_validated = (mem_read != NO_MEM_READ && mem_write != NO_MEM_WRITE) ? NO_MEM_READ : mem_read;
    assign mem_write_validated = (mem_read != NO_MEM_READ && mem_write != NO_MEM_WRITE) ? NO_MEM_READ : mem_read;

    always_comb begin
        case (address[31])
            1'b1: begin
                data_memory_address     = 0;
                data_memory_write_data  = 0;
                data_memory_mem_read    = NO_MEM_READ;
                data_memory_mem_write   = NO_MEM_WRITE;

                peripheral_address      = address[30:0];
                peripheral_write_data   = write_data;
                peripheral_mem_read     = mem_read_validated;
                peripheral_mem_write    = mem_write_validated;

                device_data_src         = PERIPHERAL;
            end
            default: begin
                data_memory_address     = address[30:0];
                data_memory_write_data  = write_data;
                data_memory_mem_read    = mem_read_validated;
                data_memory_mem_write   = mem_write_validated;

                peripheral_address      = 0;
                peripheral_write_data   = 0;
                peripheral_mem_read     = NO_MEM_READ;
                peripheral_mem_write    = NO_MEM_WRITE;

                device_data_src         = DATA_MEM;
            end
        endcase
    end


endmodule