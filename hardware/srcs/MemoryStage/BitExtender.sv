`timescale 1ns/1ps

module BitExtender
    import ControlSignals_pkg::*;
(
    input logic [31:0] data,
    input MEMRead mem_read,
    output logic [31:0] extended_data
);
    always_comb begin
        case (mem_read)
            MEM_READ_1_U_BYTE, MEM_READ_2_U_BYTES: extended_data = $unsigned(data);
            MEM_READ_1_BYTE, MEM_READ_2_BYTES: extended_data = $signed(data);
            MEM_READ_4_BYTES: extended_data = data;
            default: extended_data = 0;
        endcase
    end
endmodule