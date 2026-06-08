# Architecture
C0's architecture is based on RISC-V ISA, specifically [rv32i](https://docs.riscv.org/reference/isa/unpriv/rv32.html) with no extensions or custom instructions.<br>
This architecture is more of a CPU understanding foundation for me rather than a fully functional CPU. So, I've decided to cut out most of modern Processor features and design techniques, resulting in only 38 instructions from rv32i's 40 unique instructions (replace `FENCE` and `SYSTEM` instruction group with `NOP`).<br>

The cut off modern Processor features and design techniques includes Cache, Superscalar design and Out of Order execution, resulting in at best 1 instruction per clock cycles.<br>

## Registers
Registers of C0 have the same registers as [rv32i](https://docs.riscv.org/reference/isa/unpriv/rv32.html) registers, meaning that in C0 there will be a total of 32 registers (not counting program counter, of course).<br>

The following table will list all 32 registers and its description from [RISC-V ABI doucment](https://docs.riscv.org/reference/abi/riscv-cc-register-convention.html).<br>
FYI, ABI is like a common agreement on how to write code for RISC-V. Which mean that, if you wanted to write an assembly for this processor, you can use ABI Mnemonic to refer to specific register, the compiler will handle which register you're trying to refer to.

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

**Note:** If you're new to CPU architecture (just like me), instruction formats tell the CPU about where to find the operand, value it needs to use, what address it need to jump to, etc...<br>

![Instruction formats](./imgs/instruction_formats.png)<br>
Image taken from [RISC-V specification document](https://docs.riscv.org/reference/isa/_attachments/riscv-unprivileged.pdf).<br>

The following are the full name of each types.
- R-type: Register / Register
- I-type: Immediate
- S-type: Store
- B-type: Branch
- U-type: Upper immediate
- J-type: Jump

`opcode` field is use determine the instruction group or whether the instruction is immediate or not, while the `funct3` and `funct7` are used to determine the specific function inside the group.<br>

`rs1` and `rs2` (source) is the register where the operand are located, while `rd` (destination) are used to specify the register where the output of that instruction will be save to.<br>

For `imm` (immediate) field, there are many use cases on this field. The use case of this field is up to the instruction the CPU is executing, there will be more information about this field on [Instruction Groups](#instruction-groups) section. But tldr, CPU will directly use value from this field.

## Instruction Groups
This section will be go over all the instructions that have been implemented on C0 architecture.
Some of the groups may have multiple forms of the instruction depend on the instruction format.<br>
### Arithmetic and Logic
#### R-type
The opcode for these instructions would be `0110011`
| funct 7   | funct 3   | mnemonic  | operation                 | description                                   |
|-----------|-----------|-----------|---------------------------|-----------------------------------------------|
| 0000000   | 000       | ADD       | rd = r1 + r2              | add r2 to r1                                  |
| 0100000   | 000       | SUB       | rd = r1 - r2              | subtract r2 from r1                           |
| 0000000   | 001       | SLL       | rd = r1 << r2             | logical shift r1 left by r2                   |
| 0000000   | 010       | SLT       | rd = r1 < r2 (signed)     | is r1 less than r2 (compare signed version)   |
| 0000000   | 011       | SLTU      | rd = r1 < r2 (unsigned)   | is r1 less than r2 (compare unsigned version) |
| 0000000   | 100       | XOR       | rd = r1 ^ r2              | bitwise xor                                   |
| 0000000   | 101       | SRL       | rd = r1 >> r2 (logical)   | logical shift r1 right by r2                  |
| 0100000   | 101       | SRA       | rd = r1 >> r2 (arithmetic)| arithmetic shift r1 right by r2               |
| 0000000   | 110       | OR        | rd = r1 \| r2             | bitwise or                                    |
| 0000000   | 111       | AND       | rd = r1 & r2              | bitwise and                                   |
#### I-type
### Load and Store
### Branch
### Address Constructor
### Jump