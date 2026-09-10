`timescale 1ns/1ps

import OtherSignals_pkg::*;

class RandomFormat;
    rand InstructionFormat value;
    constraint rule {
        value != R_TYPE;
    }
endclass

program ImmediateAssemblerTbProgram (
    output logic [19:0] imm = 0,
    output InstructionFormat format = I_TYPE,
    input logic [31:0] extended_imm
);
    RandomFormat random_format = new();
    logic [31:0] target_value;

    initial begin
        repeat(1000000) begin
            assert (random_format.randomize()) else $fatal(2, "Unable to randomize new format type.");
            format = random_format.value;
            case (random_format.value)
                I_TYPE, S_TYPE, B_TYPE: begin
                    // logic [11:0] random;
                    // if (!std::randomize(random)) $fatal(3, "Unable to randomize new target value.");
                    // imm = {8'b0, random};
                    if (!std::randomize(imm) with {imm inside {[0:2**12-1]};}) $fatal(3, "Unable to randomize new target value.");
                end
                U_TYPE, J_TYPE: begin
                    // logic [19:0] random; 
                    // if (!std::randomize(random)) $fatal(3, "Unable to randomize new target value.");
                    // imm = random;
                    if (!std::randomize(imm)) $fatal(3, "Unable to randomize new target value.");
                end
            endcase
            case (random_format.value)
                I_TYPE, S_TYPE: begin
                    target_value = imm[11:0];
                end 
                B_TYPE: begin
                    target_value = {imm[11:0], 1'b0};
                end
                U_TYPE: begin
                    target_value = {imm, 12'b0};
                end
                J_TYPE: begin
                    target_value = {imm, 1'b0};
                end
            endcase

            #1ns;
            if (extended_imm != target_value) begin
                $fatal(1, "Mismatch value between extended immediate value (%0d) and its target value(%0d).", extended_imm, target_value);
            end
        end
        $finish;
    end
endprogram

module ImmediateAssembler_tb;
    logic [19:0] imm;
    InstructionFormat format;
    logic [31:0] extended_imm;

    ImmediateAssembler dut (
        .imm(imm),
        .format(format),
        .extended_imm(extended_imm)
    );
    ImmediateAssemblerTbProgram test_env (
        .imm(imm),
        .format(format),
        .extended_imm(extended_imm)
    );
endmodule