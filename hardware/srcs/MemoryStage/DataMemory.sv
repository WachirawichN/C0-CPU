`timescale 1ns/1ps

module DataMemory
    import ControlSignals_pkg::*;
#(
    parameter BYTE_COUNT = 262144
) (
    MemoryBus.slave bus,
    output logic [31:0] memory_read_data = 0
);
    logic [7:0] memory_block [BYTE_COUNT-1:0] = '{default: 0};

    // Read operation
    always @(bus.mem_read) begin
        if (bus.mem_read == NO_MEM_READ) begin
            memory_read_data = 0;
        end else begin
            case (bus.mem_read[1:0])
                2'b00: memory_read_data = memory_block[bus.address];
                2'b01: memory_read_data = {memory_block[bus.address + 1], memory_block[bus.address]};
                2'b10: memory_read_data = {memory_block[bus.address + 3], memory_block[bus.address + 2], memory_block[bus.address + 1], memory_block[bus.address]};
                default: memory_read_data = '0;
            endcase
        end
    end
    always_ff @(posedge bus.clk or negedge bus.rst_n) begin
        if (!bus.rst_n) begin
            memory_block <= '{default: 0};
        end else begin
            case (bus.mem_write)
                MEM_WRITE_1_BYTE: memory_block[bus.address] <= bus.write_data[7:0];
                MEM_WRITE_2_BYTES: begin
                    memory_block[bus.address] <= bus.write_data[7:0];
                    memory_block[bus.address + 1] <= bus.write_data[15:8];
                end
                MEM_WRITE_4_BYTES: begin
                    memory_block[bus.address] <= bus.write_data[7:0];
                    memory_block[bus.address + 1] <= bus.write_data[15:8];
                    memory_block[bus.address + 2] <= bus.write_data[23:16];
                    memory_block[bus.address + 3] <= bus.write_data[31:24];
                end
            endcase
        end
    end

endmodule