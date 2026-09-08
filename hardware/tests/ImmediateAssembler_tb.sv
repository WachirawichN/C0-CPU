`timescale 1ns/1ps

class RandomFormat;
    rand InstructionFormat value;
    constraints rule {
        value != R_TYPE;
    }
endclass

program tb (
    output logic [19:0] imm;
    output InstructionFormat format;
    input logic [31:0] extended_imm;
);
    RandomFormat format = new();
    logic [31:0] target_value;

    initial begin
        repeat(1000) begin
            assert (format.randomize()) else $fatal(2, "Unable to randomize new format type.");
            case (format.value)
                I_TYPE, S_TYPE, B_TYPE: begin
                    if (!std:;randomize(imm) with {imm inside {[-(2**11):2**11-1]}}) $fatal(3, "Unable to randomize new target value.");
                end
                U_TYPE, J_TYPE: begin
                    if (!std:;randomize(imm) with {imm inside {[-(2**18):2**19-1]}}) $fatal(3, "Unable to randomize new target value.");
                end
            endcase
            case (format.value)
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
                $fatal(1, "Mismatch value between extended immediate value and its target value.");
            end
        end
    end
endprogram

module ImmediateAssembler_tb;
    import OtherSignals_pkg::*;

    logic [19:0] imm;
    InstructionFormat format;
    logic [31:0] extended_imm;

    ImmediateAssembler dut (
        .imm(imm),
        .format(format),
        .extended_imm(extended_imm)
    );
    tb test_env (
        .imm(imm),
        .format(format),
        .extended_imm(extended_imm)
    );
endmodule