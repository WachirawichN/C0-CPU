`timescale 1ns/1ps

module LsuOperationDecoder
        import operation_pkg::*;
    (
        input logic [2:0] func_3,
        output LsuOperation_e result
    );

    always_comb begin
        case (func_3)
            3'b000  : result = LSU_LB;
            default : result = LSU_NONE;
        endcase
    end
    
endmodule