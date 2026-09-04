`timescale 1ns/1ps

module InstructionDecoder
    import OtherSignals_pkg::*;
(
    input logic  [31:0]                         instruction,

    output logic [19:0]                         raw_imm_value       = 0,
    output OtherSignals_pkg::InstructionFormat  instruction_format  = R_TYPE
    output logic [4:0]                          rs1_address         = 5'b00000,
    output logic [4:0]                          rs2_address         = 5'b00000,
    output logic [4:0]                          rd_address          = 5'b00000,

    output logic [6:0]                          opcode              = 7'b0000000,
    output logic [2:0]                          funct3              = 3'b000,
    output logic [6:0]                          funct7              = 7'b0000000,
);
    assign opcode = instruction[6:0];
    always_comb begin
        case (opcode)
            7'b0110011: begin
                // R-type
                raw_imm_value = 0;
                instruction_format = R_TYPE;

                rs1_address = instruction[19:15];
                rs2_address = instruction[24:20];
                rd_address = instruction[11:7];
                
                funct3 = instruction[14:12];
                funct7 = instruction[31:25];
            end
            7'b0010011, 7'b0000011, 7'b1100111: begin
                // I-type
                instruction_format = I_TYPE;

                rs1_address = instruction[19:15];
                rs2_address = 5'b00000;
                rd_address = instruction[11:7];
                
                funct3 = instruction[14:12];
                funct7 = 7'b0000000;

                case (funct3)
                    3'b001, 3'b101: raw_imm_value = 20'(instruction[24:20]);
                    default: raw_imm_value = 20'(instruction[31:20]);
                endcase
            end
            7'b0100011: begin
                // S-type
                raw_imm_value = 20'({instruction[31:25], instruction[11:7]});
                instruction_format = S_TYPE;

                rs1_address = instruction[19:15];
                rs2_address = instruction[24:20];
                rd_address = 5'b00000;
                
                funct3 = instruction[14:12];
                funct7 = 7'b0000000;
            end
            7'b1100011: begin
                // B-type
                raw_imm_value = 20'({instruction[31], instruction[7], instruction[30:25], instruction[11:8]});
                instruction_format = B_TYPE;

                rs1_address = instruction[19:15];
                rs2_address = instruction[24:20];
                rd_address = 5'b00000;
                
                funct3 = instruction[14:12];
                funct7 = 7'b0000000;
            end
            7'b1101111: begin
                // J-type
                raw_imm_value = instruction[31:12];
                instruction_format = J_TYPE;

                rs1_address = 5'b00000;
                rs2_address = 5'b00000;
                rd_address = instruction[11:7];
                
                funct3 = 3'b000;
                funct7 = 7'b0000000;
            end
            7'b0110111, 7'b0010111: begin
                // U-type
                raw_imm_value = {instruction[31], instruction[19:12], instruction[20], instruction[30:21]};
                instruction_format = U_TYPE;

                rs1_address = 5'b00000;
                rs2_address = 5'b00000;
                rd_address = instruction[11:7];
                
                funct3 = 3'b000;
                funct7 = 7'b0000000;
            end
            default: begin
                // Default to NOP operation (addi zero, zero, 0).
                // Need a bit of help from Operation Decoder in default statement
                raw_imm_value = 0;
                instruction_format = I_TYPE;

                rs1_address = 5'b00000;
                rs2_address = 5'b00000;
                rd_address = 5'b00000;
                
                funct3 = 3'b000;
                funct7 = 7'b0000000;
            end
        endcase
    end
    
endmodule