List for storing the changes made mid-way when writing the FPGA code. All the difference between the FPGA code and the document must be checked before pushing the main branch.

1. `ALUOp` remains 4-bits long but branching associated operations are now removed. Instead, it is moved to `ComOp` Control Signal.
    - Status: Unchecked
2. `MEMRead` got renamed to `ReadOp` to match the functionality to both data memory and peripherals, and extended to 3-bits from 2 from the addition of 3 difference read width and signed/unsigned mode.
    - Status: Unchecked
3. `MEMWrite` got renamed to `WriteOp` to match the functionality to both data memory and peripherals, and Extended to 2-bits from 1 from the addition of 3 difference write width.
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
9. PC's internal mux now have another input for having first 31-bits (MSB) of the jump address as a choice. The choice is also combinational now instead of sequential, so that the register that holds PC's internal address and Instruction Memory Controller which use BRAM could reference to the same thing.
    - Status: Unchecked
10. Memory/Peripheral (inst, data and peripheral) now use little-endian style (but the internal of the processor still use big-endian).
    - Status: Unchecked
11. Address Decoder now handles the conflict behavior from the `ReadOp` and `WriteOp` trying to interact with the target at the same time. It is more efficient to let the Address Decoder handles this.
    - Status: Unchecked
12. Add new Bits Extension Unit for handling signed/unsigned extending for the `ReadOp` operation that doesn't read the full word.
    - Status: Unchecked
13. Removed the big Peripheral Controller and leave out the controller for each peripheral.
    - Status: Unchecked
14. Unified the bus for communication between the processor, the Data Memory and the Peripherals into one bus (separate the data line from each device). When there is a read/write request from the processor, the Address Decoder now uses a few MSB bits (probably only 2, but the number goes up and down according to the peripheral counts) for generating a device_select signal to, ofc, selecting a device. The remaining LSB bits are also passed to the target device for accessing their internal contents like data at specific data memory address.
    - Status: Unchecked
15. `DeviceDataSrc` Control Signal now separates `PERIPHERAL` into `LCD_CONTROLLER` and `BUTTON_CONTROLLER` due to removal of the Peripheral Controller, and added value for reading from none. And, expand the size to 2-bits
    - Status: Unchecked
16. Renamed Data Memory to Data Memory Controller.
    - Status: Unchecked
17. Renamed Instruction Memory to Instruction Memory Controller.
    - Status: Unchecked
18. Major changes to MEM and WB stage due to BRAM implementation on Data Memory Controller, which cause the read operation have a delay of 1 clock cycle. Read operation mux and bit extender for that data are now moved to WB to accommodate for the delay of the Data Memory Controller. Result of read operation from LCD, button matrix, `DeviceDataSrc` and `ReadOp` are now part of MEM/WB interstage register.
    - Status: Unchecked
19. `BGE` and `BGEU` is greater or equal, not just greater. bruh
    - Status: Checked
20. `SLL`, `SRL` and `SRA` only use the lower 5-bits of the second operand.
    - Status: Checked


High chance of having to re-evaluate most of the unit (probably all for safety lol).