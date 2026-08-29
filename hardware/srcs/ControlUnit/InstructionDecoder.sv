`timescale 1ns/1ps

module InstructionDecoder
    import InstructionFormat_pkg::*;
(
    input logic  [31:0]                             instruction,

    output logic [19:0]                             imm_field_value     = 0,
    output InstructionFormat_pkg::InstructionFormat instruction_format  = R_TYPE
    output logic [4:0]                              rs1_address         = 5'b00000,
    output logic [4:0]                              rs2_address         = 5'b00000,
    output logic [4:0]                              rd_address          = 5'b00000,

    output logic [6:0]                              opcode              = 0,
    output logic [2:0]                              funct3              = 0,
    output logic [6:0]                              funct7              = 0,
);
    assign opcode = instruction[6:0];
    always_comb begin
        case (opcode)
            7'b0110011: begin
                // R-type
            end
            7'b0010011, 7'b0000011, 7'b1100111: begin
                // I-type
            end
            7'b0100011: begin
                // S-type
            end
            7'b1100011: begin
                // B-type
            end
            7'b1101111: begin
                // J-type
            end
            7'b0110111, 7'b0010111: begin
                // U-type
            end
            default: begin
                
            end
        endcase
    end
    
endmodule