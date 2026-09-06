List for storing the changes made mid-way when writing the FPGA code. All the difference between the FPGA code and the document must be checked before pushing the main branch.

1. `ALUOp` Extended from 4-bits to 5-bits due to the new arrangement which make constructing this Control Signal easier (can now use the `funct3`, `funct7` and `imm` directly without having to process anything).
    - Status: Checked
2. `MEMRead` Extended to 3-bits from 2 from the addition of 3 difference read width and signed/unsigned mode.
    - Status: Unchecked
3. `MEMWrite` Extended to 2-bits from 1 from the addition of 3 difference write width.
    - Status: Unchecked
4. `PCSrc` Extended the width from 1-bit to 2-bits, from the addition of the specific `jalr` jump address. This also make the PC have to go under diagram redrawn as well for mux having new input.
    - Status: Unchecked
5. `JmpOp` Maintain the same width, but have an additional value from separating the unconditional jump into `jal` and `jalr`.
    - Status: Unchecked