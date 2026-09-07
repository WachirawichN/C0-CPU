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
    logic [19:0] target_value = 0;
    logic [19:0] scrambled_imm = 0;

    initial begin
        repeat(1000) begin
            
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