`timescale 1ns/1ps

module LCDController
    import ControlSignals_pkg::*;
#(
    parameter           CS_ADDRESS = 1
) (
    PeripheralBus.slave peripheral_bus,
    LCDBus.master lcd_bus,
    output logic [31:0] lcd_read_data = 0 // Just a place holder. I will not read from the LCD to prevent 5V LCD and 3.3V FPGA incident.
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
    
    always_ff @(posedge peripheral_bus.clk or negedge peripheral_bus.rst_n) begin
        if (!peripheral_bus.rst_n) begin
            lcd_bus.write_data <= 0;
            lcd_bus.rs <= 0;
            lcd_bus.e <= 0;
        end else begin
            if (peripheral_bus.cs[CS_ADDRESS] && peripheral_bus.mem_write != NO_MEM_WRITE) begin    
                case (peripheral_bus.mem_write)
                    MEM_WRITE_1_BYTE: begin
                        lcd_bus.write_data <= unsigned'(peripheral_bus.write_data[3:0]);
                        lcd_bus.rs <= peripheral_bus.write_data[4];
                        lcd_bus.e <= peripheral_bus.write_data[5];
                    end
                    MEM_WRITE_2_BYTES, MEM_READ_4_BYTES: begin
                        lcd_bus.write_data <= peripheral_bus.write_data[7:0];
                        lcd_bus.rs <= peripheral_bus.write_data[8];
                        lcd_bus.e <= peripheral_bus.write_data[9];
                    end
                endcase
            end else begin
                lcd_bus.write_data <= 0;
                lcd_bus.rs <= 0;
                lcd_bus.e <= 0;
            end
        end
    end
endmodule