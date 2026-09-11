`timescale 1ns/1ps

module InstructionMemory #(
    parameter INSTRUCTION_COUNTS = 65536,
    parameter PROGRAM_NAME = "program.mem"
) (
    input logic  [31:0] address,
    output logic [31:0] instruction
);
    // In byte, that would be INSTRUCTION_COUNTS * 4, which typically is 262KB.
    logic [7:0] memory_block [INSTRUCTION_COUNTS * 4 - 1:0] = '{default: 0};

    // Read a program from a file with the name of PROGRAM_NAME using base 16.
    // Per line, there would be 8 hex values. Those values are group into 4 group (2 per group) separate by space.
    // Else the $readmemh will have a lot of trouble putting 32-bits value into 8-bits memory cell.
    // 
    // Example:
    // lui t0, 1
    // addi zero, zero, 0
    // addi zero, zero, 0
    // slli t0, t0, 10
    // For binary that would be (same bit organization as the instruction format table)
    // 00000000000000000001001010110111
    // 00000000000000000000000000010011
    // 00000000000000000000000000010011
    // 00000000101000101001001010010011
    // Converting into hex format that $readmemh could read would be
    // 00 00 12 B7
    // 00 00 00 13
    // 00 00 00 13
    // 00 A2 92 93
    // Now we have to reverse the order because of the RISC-V specification did specify that memory should use little-endian (LSB is in the front, MSB in the back).
    // B7 12 00 00
    // 13 00 00 00
    // 13 00 00 00
    // 00 A2 92 93

    initial $readmemh(PROGRAM_NAME, memory_block);

    always_comb begin
        // Convert the little-endian in to big-endian instruction because I already design most of the processor to be big-endian before knowing the little-endian thing. lol
        instruction = {
            memory_block[address + 3],
            memory_block[address + 2],
            memory_block[address + 1],
            memory_block[address]
        };
    end
    
endmodule