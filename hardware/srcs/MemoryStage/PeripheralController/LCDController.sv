`timescale 1ns/1ps

module LCDController
    import ControlSignals_pkg::*;
(
    input logic rst_n,

    input logic [31:0] in_data,
    input MEMWrite mem_write,

    output logic [7:0] out_data,
    output logic rs,
    output logic e
);
    // The most barebone form it could be.
    // This just check if the write operation is valid or not (valid is 2 bytes write).
    // If not then nothing happen. If it is valid then the output are wired to their correspond bit in in_data.
    // Last 8-bits of the in_data is the d0 - d7 of the LCD.
    // Bit 9 of the in_data is the rs signal.
    // Bit 10 is the e signal.
    // 
    // Originally, I've planned this to fully controls the working of LCD, but I've a lot of fun driving the LCD by my own hand.
    // So, barebone it is.
    
    always_comb begin
        if (!rst_n) begin
            out_data = 0;
            rs = 0;
            e = 0;
        end else begin
            case (mem_write)
                MEM_WRITE_2_BYTES: begin
                    out_data = in_data[7:0];
                    rs = in_data[8];
                    e = in_data[9];
                end
            endcase
        end
    end
endmodule