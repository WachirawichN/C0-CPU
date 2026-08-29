`timescale 1ns/1ps

module InstructionMemory_tb;
    logic [31:0] address = 0;
    logic [31:0] instruction;

    InstructionMemory dut (
        .address(address),
        .instruction(instruction)
    );

    initial begin
        for (shortint i = 0; i < 10; i = i + 1) begin
            #1;
            address = address + 4;
        end
        $finish;
    end
    
endmodule