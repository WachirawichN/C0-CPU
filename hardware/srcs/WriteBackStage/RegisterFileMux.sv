`timescale 1ns/1ps

module RegisterFileMux
    import ControlSignals_pkg::*;
    import Types_pkg::*;
(
    input   Word    alu_result,
    input   Word    next_address,
    input   Word    extended_device_data,
    input   rdSrc   rd_src,

    output  Word    rd_write_data
);
    always_comb begin
        case (rd_src)
            RDSRC_ALU_RESULT:       rd_write_data = alu_result;
            RDSRC_NEXT_ADDRESS:     rd_write_data = next_address;
            RDSRC_DEVICE_READ_DATA: rd_write_data = extended_device_data;
            default:                rd_write_data = '0;
        endcase
    end
endmodule   