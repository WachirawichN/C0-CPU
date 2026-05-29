# Architecture
C0's architecture is based on RISC-V ISA, specifically [rv32i](https://docs.riscv.org/reference/isa/unpriv/rv32.html) with no extensions or custom instructions.<br>
This architecture is more of a CPU understanding foundation for me rather than a fully functional CPU. So, I've decided to cut out most of modern Processor features and design techniques, resulting in only 38 instructions from rv32i's 40 unique instructions (replace FENCE instruction with NOP and shrink SYSTEM instruction group into one instruction).<br>

The cut off modern Processor features and design techniques includes Cache, Superscalar design, Out of Order execution and even Instruction Pipelining, resulting in measly 1 instruction per 3 clock cycles (I hope).<br>

## Registers
Registers of C0 have the same registers as [rv32i](https://docs.riscv.org/reference/isa/unpriv/rv32.html) registers, meaning that in C0 there will be a total of 32 registers (not counting program counter, of course).<br>
The following table will list all 32 registers and its description from [RISC-V ABI](https://docs.riscv.org/reference/abi/riscv-cc-register-convention.html) doucment.<br>
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

## Instruction Groups
As said before, C0 architecture contains only 40 unique instructions, Thinks of this CPU as a "calculator" CPU. Which making this architecture (almost) impossible to implement OS on.<br>
This section will describe all the instructions that have been implemented on C0 architecture.
### Aritchmetic and Logic
### Load and Store
### Branch
### Address Constructor
### Jump