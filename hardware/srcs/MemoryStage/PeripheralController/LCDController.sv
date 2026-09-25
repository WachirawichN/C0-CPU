`timescale 1ns/1ps

module LCDController
    import ControlSignals_pkg::*;
(
    input logic         rst_n,
    input logic         clk,

    input logic         enable,
    input logic [31:0]  write_data,
    input MEMRead       mem_read,
    input MEMWrite      mem_write,

    output logic [31:0] data = 0, // Just a place holder. I will not read from the LCD to prevent 5V LCD and 3.3V FPGA incident.

    output logic [7:0]  out_data,
    output logic        rs,
    output logic        e
);
    // The most barebone form it could be.
    // The write_data contains both data, rs and e signal for the LCD.
    // MEM_WRITE_1_BYTE is only for 4-bits write mode of the LCD, while the other two are available for both 4-bits and 8-bits mode.
    // 
    // In 4-bits mode, the last 4-bits of the write_data will goes into d0 - d3 of the LCD (LSB of write_data is d0, while MSB is d3).
    // The fifth bit (write_data[4]) is for rs signal, and the sixth bit (write_data[5]) is for e signal.
    // 
    // In 8-bits mode, it is similar to 4-bits mode. The last 8-bits of write_data will goes into d0 - d7 of the LCD. It is also
    // organzie the same way as the 4-bits mode. The ninth bit of the write_data is for rs signal, and tenth bit is for e signal.
    // 
    // Note: Every signals must be managed by the programmer because it is barebone. This include manually switching e signal.
    //       When changing the write mode, the programmer must also manually send the instruction to the LCD to switch the mode.
    // 
    // Originally, I've planned this to fully controls the working of LCD, but I've a lot of fun driving the LCD without I2C
    // or any libraries. So, barebone it is.
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            out_data <= 0;
            rs <= 0;
            e <= 0;
        end else begin
            if (enable && mem_write != NO_MEM_WRITE) begin    
                case (mem_write)
                    MEM_WRITE_1_BYTE: begin
                        out_data <= unsigned'(write_data[3:0]);
                        rs <= write_data[4];
                        e <= write_data[5];
                    end
                    MEM_WRITE_2_BYTES, MEM_READ_4_BYTES: begin
                        out_data <= write_data[7:0];
                        rs <= write_data[8];
                        e <= write_data[9];
                    end
                endcase
            end else begin
                out_data <= 0;
                rs <= 0;
                e <= 0;
            end
        end
    end
endmodule