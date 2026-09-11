`timescale 1ns/1ps

module ImmediateAssembler
    // Bro, why does the SystemVerilog have to use wild card import for importing only one enum type and its value.
    import OtherSignals_pkg::*;
(
    input logic signed [19:0] imm,
    input InstructionFormat format,
    output logic signed [31:0] extended_imm
);
    always_comb begin
        // The default combine both I-type and S-type.
        case (format)
            I_TYPE, S_TYPE: extended_imm = imm[11:0];
            B_TYPE: extended_imm = {imm[11:0], 1'b0};
            U_TYPE: extended_imm = {imm, 12'b0};
            J_TYPE: extended_imm = {imm, 1'b0};
        endcase
    end
    
endmodule