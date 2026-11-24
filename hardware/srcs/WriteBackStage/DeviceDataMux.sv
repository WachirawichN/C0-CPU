`timescale 1ns/1ps

module DeviceDataMux
    import ControlSignals_pkg::*;
    import Types_pkg::*;
(
    input   Word            data_mem_read_data,
    input   Word            lcd_read_data,
    input   Word            button_read_data,
    input   DeviceDataSrc   device_data_src,

    output  Word            device_data
);
    always_comb begin
        case (device_data_src)
            DEVICE_DATA_SRC_DATA_MEM:           device_data = data_mem_read_data;
            DEVICE_DATA_SRC_LCD_CONTROLLER:     device_data = lcd_read_data;
            DEVICE_DATA_SRC_BUTTON_CONTROLLER:  device_data = button_read_data;
            default:                            device_data = '0;
        endcase
    end
endmodule