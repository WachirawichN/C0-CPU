List for storing the changes made mid-way when writing the FPGA code. All the difference between the FPGA code and the document must be checked before pushing the main branch.

1. `ALUOp` remains 4-bits long but branching associated operations are now removed. Instead, it is moved to `ComOp` Control Signal.
    - Status: Unchecked
2. `MEMRead` Extended to 3-bits from 2 from the addition of 3 difference read width and signed/unsigned mode.
    - Status: Unchecked
3. `MEMWrite` Extended to 2-bits from 1 from the addition of 3 difference write width.
    - Status: Unchecked
4. `PCSrc` Extended the width from 1-bit to 2-bits, from the addition of the specific `jalr` jump address. This also make the PC have to go under diagram redrawn as well for mux having new input.
    - Status: Unchecked
5. `JmpOp` extended from 2-bits to 3-bits. This new addition bit makes it easier for computing the `PCSrc` by simply using `add` operation and support the new `jalr` specific signal.
    - Status: Unchecked
6. Added dedicated comparator to Jmp Handler. Jmp handler will now handle comparison by itself. Moving this comparator to decode stage will be beneficial in long term. The address of successful branching is still ALU's result.
    - Status: Unchecked
7. Added `ComOp` Control Signal for controlling that dedicated comparator.
    - Status: Unchecked
8. ALU will now be purely for math and logic no more comparison.
    - Status: Unchecked
9. PC's internal mux now have another input for having first 31-bits (MSB) of the jump address as a choice.
    - Status: Unchecked





High chance of having to re-evaluate most of the unit (probably all for safety lol).