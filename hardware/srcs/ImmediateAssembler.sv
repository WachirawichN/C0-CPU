`timescale 1ns/1ps

module ImmediateAssembler
    import OtherSignals_pkg::InstructionFormat;
(
    input logic signed [19:0] imm;
    input InstructionFormat format;
    output logic signed [31:0] extended_imm;
);
    always_ff begin
        // The default combine both I-type and S-type.
        case (format)
            R_TYPE: ; // Making sure R-type will not do something funny.
            B_TYPE: extended_imm = {imm[8:0], 1'b0};
            U_TYPE, J_TYPE: extended_imm = imm;
            default: extended_imm = imm[8:0]; 
        endcase
    end
    
endmodule