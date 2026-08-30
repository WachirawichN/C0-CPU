`timescale 1ns/1ps

module InstructionMemory #(
    parameter INSTRUCTION_COUNTS = 65536
) (
    input logic  [31:0] address,
    output logic [31:0] instruction
);
    // In byte, that would be INSTRUCTION_COUNTS * 4, which typically is 262KB.
    logic [7:0] memory_block [INSTRUCTION_COUNTS * 4 - 1:0] = '{default: 0};

    // Read a program from a file called program.mem using base 16.
    // Per line, there would be 8 hex values. Those values are group into 4 group (2 per group) separate by space.
    // Else the $readmemh will have a lot of trouble putting 32-bits value into 8-bits memory cell.
    // 
    // Example:
    // lui t0, 1
    // addi zero, zero, 0
    // addi zero, zero, 0
    // slli t0, t0, 10
    // For binary that would be
    // 00000000000000000001001010110111
    // 00000000000000000000000000010011
    // 00000000000000000000000000010011
    // 00000000101000101001001010010011
    // Converting into hex format that $readmemh could read would be
    // 00 00 12 B7
    // 00 00 00 13
    // 00 00 00 13
    // 00 A2 92 93
    initial $readmemh("program.mem", memory_block);

    always_comb begin
        // Return an instruction might be a bit weird because the $readmemh read the first column of the program file as LSB up to the last column as MSB.
        // But, we want that LSB to be our MSB, so we gotta reverse it.
        instruction = {
            memory_block[address],
            memory_block[address + 1],
            memory_block[address + 2],
            memory_block[address + 3]
        };
    end
    
endmodule