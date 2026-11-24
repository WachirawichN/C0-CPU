`timescale 1ns/1ps

module BitExtender
    import ControlSignals_pkg::*;
    import Types_pkg::*;
(
    input   Word    device_data,
    input   ReadOp  validated_read_op,
    
    output  Word    extended_device_data
);
    always_comb begin
        case (validated_read_op)
            READ_OP_1_U_BYTE:   extended_device_data = $unsigned(device_data[7:0]);
            READ_OP_2_U_BYTES:  extended_device_data = $unsigned(device_data[15:0]);

            READ_OP_1_BYTE:     extended_device_data = $signed(device_data[7:0]);
            READ_OP_2_BYTES:    extended_device_data = $signed(device_data[15:0]);

            READ_OP_4_BYTES:    extended_device_data = device_data;

            default:            extended_device_data = '0;
        endcase
    end
endmodule