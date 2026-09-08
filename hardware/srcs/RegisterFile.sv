`timescale 1ns/1ps

module RegisterFile
    import ControlSignals_pkg::rdWrite;
(
    input logic rst_n,
    input logic clk,

    input logic [4:0] read_address_1,
    input logic [4:0] read_address_2,
    input logic [31:0] write_data,
    input rdWrite write_enable, 
    input logic [4:0] write_address,

    output logic [31:0] read_register_1_data,
    output logic [31:0] read_register_2_data
);
    logic [31:0] register_array [31:0] = '{default: 0};

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            register_array <= '{default: 0};
        end else begin
            if (write_enable && write_address != 5'b00000) begin
                register_array[write_address] <= write_data;
            end
        end
    end
    always @(read_address_1, read_address_2) begin
        read_register_1_data = register_array[read_address_1];
        read_register_2_data = register_array[read_address_2];
    end
endmodule