`timescale 1ns/1ps

module AddressDecoder
    import ControlSignals_pkg::*;
(
    input logic [31:0]      address,
    input logic [31:0]      write_data,
    input MEMRead           mem_read,
    input MEMWrite          mem_write,

    MemoryBus.master        memory_bus,
    PeripheralBus.master    peripheral_bus,

    output DeviceDataSrc    device_data_src = DEVICE_DATA_SRC_DATA_MEM
);
    // Behavior of the processor try to read and write at the same time.
    MEMRead mem_read_validated;
    MEMWrite mem_write_validated;
    assign mem_read_validated = (mem_read != NO_MEM_READ && mem_write != NO_MEM_WRITE) ? NO_MEM_READ : mem_read;
    assign mem_write_validated = (mem_read != NO_MEM_READ && mem_write != NO_MEM_WRITE) ? NO_MEM_WRITE : mem_write;

    function void set_zero_data_bus();
        memory_bus.address      = 0;
        memory_bus.write_data   = 0;
        memory_bus.mem_read     = NO_MEM_READ;
        memory_bus.mem_write    = NO_MEM_WRITE;
    endfunction
    function void set_zero_peripheral_bus();
        peripheral_bus.cs           = 0;
        peripheral_bus.write_data   = 0;
        peripheral_bus.mem_read     = NO_MEM_READ;
        peripheral_bus.mem_write    = NO_MEM_WRITE;
    endfunction

    always_comb begin
        set_zero_data_bus();
        set_zero_peripheral_bus();

        case (address[31])
            1'b0: begin // Data Memory selected
                memory_bus.address      = address[30:0];
                memory_bus.write_data   = write_data;
                memory_bus.mem_read     = mem_read_validated;
                memory_bus.mem_write    = mem_write_validated;

                device_data_src         = DEVICE_DATA_SRC_DATA_MEM;
            end
            1'b1: begin // Peripheral selected
                peripheral_bus.cs                   = '0;
                peripheral_bus.cs[address[30:0]]    = 1'b1;
                peripheral_bus.write_data           = write_data;
                peripheral_bus.mem_read             = mem_read_validated;
                peripheral_bus.mem_write            = mem_write_validated;

                device_data_src                     = DeviceDataSrc'(address[30:0]);
            end
            default: begin // Unknown value
                device_data_src         = DEVICE_DATA_SRC_NONE;
            end
        endcase
    end


endmodule