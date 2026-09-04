# High Priority
## Memory
- Add some sort of way for the processor to distinguish between read/write size to the memory.
    - Add more enum/bit to the memory operation Control Signal into 2-bits.
- Add a way for the processor to extend the read data from a byte or two into 4 bytes value before writing to destination register.
    - Add a new bit to the read enum at the front, this bit is specifically for signifying the extending of the value.

## PC
- A way for the PC to know if to use the full jump address of the 31 MSB (`jalr`).
    - Extend the input of the PC's input mux.
    - Change the `JmpOp` value to be
        - `00` = not a branch/jump operation
        - `01` = a branch operation
        - `10` = `jal` operation
        - `11` = `jalr` operation
    - The `PCSrc` value would now be
        - `00` = next address
        - `01` = ALU full result
        - `10` = ALU first 31-bits result
    - Compute the `PCSrc` the same way as before just extend the width.
- Add a new bit to the second MSB to the `ALUOp` for specifying the alternative form of the operation.


# Medium Priority
## CU
- Re-draw the Control Unit and ID Stage to add some sort of component that could distinguish between normal I-type and special I-type format of the Arithmetic and Logic group.

# Low Priority
## Peripheral Controller
- Finalize how many peripheral there would be connected to the CPU, and added that information to the Peripheral Controller.