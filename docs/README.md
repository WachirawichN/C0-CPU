# Architecture
C0's architecture is based on RISC-V ISA, specifically [rv32i](https://docs.riscv.org/reference/isa/unpriv/rv32.html) with no extensions or custom instructions.<br>
This architecture is more of a CPU understanding foundation for me rather than a fully functional CPU. So, I've decided to cut out most modern Processor features and design techniques, resulting in only 37 instructions from rv32i's 40 unique instructions (replace `FENCE` and `SYSTEM` instruction group with `NOP`).<br>

The cut-off modern Processor features and design techniques includes Cache, Superscalar design and Out of Order execution, resulting in at best 1 instruction per clock cycles.<br>

## Registers
Registers of C0 have the same registers as [rv32i](https://docs.riscv.org/reference/isa/unpriv/rv32.html) registers, meaning that in C0 there will be a total of 32 registers (not counting program counter, of course).<br>

The following table will list all 32 registers and its description from [RISC-V ABI document](https://docs.riscv.org/reference/abi/riscv-cc-register-convention.html).<br>

> [!NOTE]
> RISC-V actually specified that all 32 registers are actually a general purpose register, meaning you could use all registers for anything you like. But, ABI (which is also specified by RISC-V) is like a common agreement on how to write codes for RISC-V, and it specifies the purpose of each register, so it is probably better to ABI instead of using all 32 registers for whatever you want.

| Register  | ABI Mnemonic  | Description                               | Saved by  |
|-----------|---------------|-------------------------------------------|-----------|
| x0        | zero          | Constant zero register                    |           |
| x1        | ra            | Return address                            | Caller    |
| x2        | sp            | Stack pointer                             | Callee    |
| x3        | gp            | Global pointer                            |           |
| x4        | tp            | Thread pointer                            |           |
| x5 - x7   | t0 - t2       | Temporaries registers                     | Caller    |
| x8        | s0 - s1       | Callee-saved registers / Frame Pointer    | Callee    |
| x9        | s0 - s1       | Callee-saved registers                    | Callee    |
| x10 - x17 | a0 - a7       | Argument registers                        | Caller    |
| x18 - x27 | s2 - s11      | Callee-saved registers                    | Callee    |
| x28 - x31 | t3 - t6       | Temporaries registers                     | Caller    |

`Saved by` column referred to which part of the code is responsible for storing data from those register to somewhere else (usually the stack) before calling any function.<br>
`Saved by Caller` means the code that called the function is responsible for storing data from registers before calling a function, this is due to the freedom of being able to overwrite data given to the function.<br>
While `Saved by Callee` means the function is the one responsible for storing the data inside registers before overwriting anyone of them, and also restore the value back to being the same as before.<br>
The `Saved by` column have been taken from [Wikipedia](https://en.wikipedia.org/wiki/RISC-V#Register_sets). 

## Instruction Formats
There are a total of 6 instruction formats specified by RISC-V, the table below contains all those formats.<br>

> [!NOTE]
> If you're new to CPU architecture (just like me), instruction formats tell the CPU about where to find the operand, value it needs to use, what address it needs to jump to, etc...

![Instruction formats](./imgs/instruction_formats.png)<br>
Image taken from [RISC-V specification document](https://docs.riscv.org/reference/isa/_attachments/riscv-unprivileged.pdf).<br>

The following are the full name of each format.
- R-type: Register / Register
- I-type: Immediate
- S-type: Store
- B-type: Branch
- U-type: Upper immediate
- J-type: Jump

### Opcode field
`opcode` field is use determine the instruction group or whether the instruction is immediate or not, while the `funct3` and `funct7` are used to determine the specific function inside the group.<br>

### Register field
`rs1` and `rs2` (source) is the register where the operand are located, while `rd` (destination) are used to specify the register where the output of that instruction will be saved to.<br>

### Immediate field
For the `imm` field, this field is use as a direct value use for computation instead of value in a register. In the table, the `imm` is always followed by [...], this is to indicate the position in the final value that will be used by the processor. After all the bits are in their position, the processor will automatically sign-extended the data to become 32-bits.<br>
Some format with some instruction might do something before extending to 32-bits, like B-type which add 0 to the end before extending. This type of stuff will be explained in the next section of some instruction group.<br>
> [!NOTE]
> By the way, when programming on RISC-V, the assembler should handle the bit positioning for you, so don't worry about this stuff too much.

For example, lets says there is a B-type instruction, which is<br>
| 1 | 2 | 3 | 4 | 5 | 6 | 7 | ... | ... | ... | 8 | 9 | 0 | a | b | ... |
|---|---|---|---|---|---|---|-----|-----|-----|---|---|---|---|---|-----|
(`1` and `0` in this situation really means it in binary in this situation, but other value can be anything. I just want to make it easier to identify each bit.)<br>

The product of swapping each bit to its correspond position would be `1b234567890a`.
Next, because this is B-type format, 0 would be added to the back, resulting in `1b234567890a0` as a product.
Finally, the sign will be extended to 32-bits, the final value will be `11111111111111111111b234567890a0`, because this is sign-extended the remainings 19-bits would be 1.<br>


## Instruction Groups
C0 instructions are grouped into multiple groups sorted by their function. This section will be going over all of them.<br>
Some groups may have multiple forms of the same instruction depend on the instruction format, or may have multiple subgroup that do completely difference thing with difference instruction format. But all in all, the opcode would be different, even though they belong to the same group<br>
### Arithmetic and Logic
> [!NOTE]
> The difference between logical and arithmetic shift is that arithmetic will shift while preserving the signed status, essentially just a true divided by 2^n instead of just divided by 2^n without caring about being signed or not.
#### R-type
The opcode for these instructions would be `0110011`<br>
| func 7    | func 3    | mnemonic  | operation                         | description                                           |
|-----------|-----------|-----------|-----------------------------------|-------------------------------------------------------|
| 0000000   | 000       | ADD       | rd = `rs1` + `rs2`                | add `rs2` to `rs1`                                    |
| 0100000   | 000       | SUB       | rd = `rs1` - `rs2`                | subtract `rs2` from `rs1`                             |
| -         | 001       | SLL       | rd = `rs1` << `rs2`               | logical shift `rs1` left by `rs2`                     |
| -         | 010       | SLT       | rd = `rs1` < `rs2` (signed)       | is `rs1` less than `rs2` (compare signed version)     |
| -         | 011       | SLTU      | rd = `rs1` < `rs2` (unsigned)     | is `rs1` less than `rs2` (compare unsigned version)   |
| -         | 100       | XOR       | rd = `rs1` ^ `rs2`                | bitwise xor                                           |
| 0000000   | 101       | SRL       | rd = `rs1` >> `rs2` (logical)     | logical shift `rs1` right by `rs2`                    |
| 0100000   | 101       | SRA       | rd = `rs1` >>> `rs2` (arithmetic) | arithmetic shift `rs1` right by `rs2`                 |
| -         | 110       | OR        | rd = `rs1` \| `rs2`               | bitwise or                                            |
| -         | 111       | AND       | rd = `rs1` & `rs2`                | bitwise and                                           |
#### I-type
The opcode for these instructions would be `0010011`<br>

For SLLI, SRLI and SRAI, the encoding of the I-type format is a little bit different from the normal I-type. The image below is how the "special" I-type format are encoded.<br>
![Special I-type format](./imgs/special_i-type_format.png)<br>
Image taken from [RISC-V specification document](https://docs.riscv.org/reference/isa/_attachments/riscv-unprivileged.pdf).<br>
I love to think that field of bits ranging from bit 25 to 31 are used like func 7 field from R-type format, while bit 20 to 24 are use as normal immediate field for shifting values. This field is called shamt in the official RISC-V specification, I would also be using those in the table.<br>

In the table, the "imm" would be referring to the entire 12 bits immediate filed.<br>
| func 7 (bit 25 - 31)  | func 3    | mnemonic  | operation                         | description                                       |
|-----------------------|-----------|-----------|-----------------------------------|---------------------------------------------------|
| -                     | 000       | ADDI      | rd = `rs1` + imm                  | add imm to `rs1`                                  |
| -                     | 001       | SLLI      | rd = `rs1` << shamt               | logical shift `rs1` left by shamt                 |
| -                     | 010       | SLTI      | rd = `rs1` < imm (signed)         | is `rs1` less than imm (compare signed version)   |
| -                     | 011       | SLTUI     | rd = `rs1` < imm (unsigned)       | is `rs1` less than imm (compare unsigned version) |
| -                     | 100       | XORI      | rd = `rs1` ^ imm                  | bitwise xor                                       |
| 0000000               | 101       | SRLI      | rd = `rs1` >> shamt (logical)     | logical shift `rs1` right by shamt                |
| 0100000               | 101       | SRAI      | rd = `rs1` >>> shamt (arithmetic) | arithmetic shift `rs1` right by shamt             |
| -                     | 110       | ORI       | rd = `rs1` \| imm                 | bitwise or                                        |
| -                     | 111       | ANDI      | rd = `rs1` & imm                  | bitwise and                                       |
### Load and Store
#### Load (I-type)
For these operations, they're used for loading some amount of bits from memory to `rd`.<br>
The effective address of that memory is calculated by adding value from `rs1` to immediate field that have been sign-extended.<br>

For specific amount of bits that would be loaded, there will be a column for that in the table below called `load size` column.<br>

Opcode for these instructions would be `0000011`.<br>
| func 3    | mnemonic  | load size | note                      |
|-----------|-----------|-----------|---------------------------|
| 000       | LB        | 8         | sign-extended to 32-bits  |
| 001       | LH        | 16        | sign-extended to 32-bits  |
| 010       | LW        | 32        | -                         |
| 100       | LBU       | 8         | zero extended to 32-bits  |
| 101       | LHU       | 16        | zero extended to 32-bits  |
#### Store (S-type)
For store group, these instructions copy the last ... bits (specify in `store size` column) from `rs2` to memory.<br>
The effective address of the memory for these instructions use the same way of calculating as the load group. The immediate field of S-type format mights be a bit wonky to look at.<br>

Opcode for these instructions would be `0100011`.<br>
| func 3    | mnemonic  | store size |
|-----------|-----------|-----------|
| 000       | SB        | 8         |
| 001       | SH        | 16        |
| 010       | SW        | 32        |
### Jump
#### Conditional Jump (Branch, B-type)
This group of instructions will add specific number to the program counter of the processor, when a condition of instruction is met. Effectively, an if-else instruction.<br>
Number of offset that would be added to program counter is within the range of ±4KiB. This offset is encoded in the 12-bits immediate field of B-type format. The reason for the 12-bits field to have a range of ±4KiB is that the immediate field will be left shift then sign-extended to 32-bits. This satisfied RISC-V's requirement for the offset to be multiples of 2.<br>

The opcode for this instruction group would be `1100011`.<br>
| func 3    | mnemonic  | description                                               |
|-----------|-----------|-----------------------------------------------------------|
| 000       | BEQ       | branch if `rs1` and `rs2` are equal                       |
| 001       | BNE       | branch if `rs1` and `rs2` are not equal                   |
| 100       | BLT       | branch if `rs1` is less than `rs2` (signed version)       |
| 101       | BGE       | branch if `rs1` is greater than `rs2` (signed version)    |
| 110       | BLTU      | branch if `rs1` is less than `rs2` (unsigned version)     |
| 111       | BGEU      | branch if `rs1` is greater than `rs2` (unsigned version)  |
#### Unconditional Jump

### Other