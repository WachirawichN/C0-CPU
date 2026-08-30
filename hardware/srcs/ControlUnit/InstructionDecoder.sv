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
                imm_field_value = 0;
                instruction_format = R_TYPE;

                rs1_address = instruction[19:15];
                rs2_address = instruction[24:20];
                rd_address = instruction[11:7];
                
                funct3 = instruction[14:12];
                funct7 = instruction[31:25];
            end
            7'b0010011, 7'b0000011, 7'b1100111: begin
                // I-type
                imm_field_value = 20'(instruction[31:20]);
                instruction_format = I_TYPE;

                rs1_address = instruction[19:15];
                rs2_address = 5'b00000;
                rd_address = instruction[11:7];
                
                funct3 = instruction[14:12];
                funct7 = 0;
            end
            7'b0100011: begin
                // S-type
                imm_field_value = 20'({instruction[31:25], instruction[11:7]});
                instruction_format = S_TYPE;

                rs1_address = instruction[19:15];
                rs2_address = instruction[24:20];
                rd_address = 5'b00000;
                
                funct3 = instruction[14:12];
                funct7 = 0;
            end
            7'b1100011: begin
                // B-type
                imm_field_value = 20'({instruction[31], instruction[7], instruction[30:25], instruction[11:8]});
                instruction_format = B_TYPE;

                rs1_address = instruction[19:15];
                rs2_address = instruction[24:20];
                rd_address = 5'b00000;
                
                funct3 = instruction[14:12];
                funct7 = 0;
            end
            7'b1101111: begin
                // J-type
                imm_field_value = instruction[31:12];
                instruction_format = J_TYPE;

                rs1_address = 5'b00000;
                rs2_address = 5'b00000;
                rd_address = instruction[11:7];
                
                funct3 = 0;
                funct7 = 0;
            end
            7'b0110111, 7'b0010111: begin
                // U-type
                imm_field_value = {instruction[31], instruction[19:12], instruction[20], instruction[30:21]};
                instruction_format = U_TYPE;

                rs1_address = 5'b00000;
                rs2_address = 5'b00000;
                rd_address = instruction[11:7];
                
                funct3 = 0;
                funct7 = 0;
            end
            default: begin
                imm_field_value = 0;
                instruction_format = R_TYPE;

                rs1_address = 5'b00000;
                rs2_address = 5'b00000;
                rd_address = 5'b00000;
                
                funct3 = 0;
                funct7 = 0;
            end
        endcase
    end
    
endmodule