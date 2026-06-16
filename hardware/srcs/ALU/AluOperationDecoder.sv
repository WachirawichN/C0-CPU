`timescale 1ns/1ps

import alu_operation_pkg::*;

module AluOperationDecoder (
        input logic [2:0] func_3,
        input logic func_7_b_5, // Only use sixth bit of func 7
        output AluOperation_e result
    );

    always_comb begin
        case (func_3)
            3'b000  : result = (func_7_b_5) ? ALU_SUB : ALU_ADD; 
            3'b001  : result = ALU_SLL; 
            3'b010  : result = ALU_SLT; 
            3'b011  : result = ALU_SLTU; 
            3'b100  : result = ALU_XOR; 
            3'b101  : result = (func_7_b_5) ?  ALU_SRA : ALU_SRL; 
            3'b110  : result = ALU_OR; 
            3'b111  : result = ALU_AND; 
            default : result = ALU_NONE;
        endcase
    end
    
endmodule