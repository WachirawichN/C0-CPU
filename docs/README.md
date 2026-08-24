# Architecture
This section will be about the ISA, which C0 is based on. Essentially, what the CPU does.<br>

C0's ISA is based on RISC-V ISA, specifically [rv32i](https://docs.riscv.org/reference/isa/unpriv/rv32.html) with no extensions or custom instructions.<br>
This architecture is more of a CPU understanding foundation for me rather than a fully functional CPU. So, I've decided to cut out most modern processor features and design techniques, resulting in only 37 instructions from rv32i's 40 unique instructions (replace `FENCE` and `SYSTEM` instruction group with `NOP`).<br>

## Registers
C0 have the same registers as the rv32i specification. In the rv32i, there are 32 registers, first one is constant zero register, and the other 31 are general purpose.<br>
The following section utilizes [RISC-V ABI document](https://docs.riscv.org/reference/abi/riscv-cc-register-convention.html) to determine the purpose for each register when programming the CPU, but feel free to read the following section if you're curious to.<br>

> [!NOTE]
> ABI is like a standard convention on how to write code for RISC-V CPU specified by RISC-V.

| Register  | ABI Mnemonic  | Description                               | Saved by  |
|-----------|---------------|-------------------------------------------|-----------|
| x0        | zero          | Constant zero                             | na        |
| x1        | ra            | Return address                            | Caller    |
| x2        | sp            | Stack pointer                             | Callee    |
| x3        | gp            | Global pointer                            | na        |
| x4        | tp            | Thread pointer                            | na        |
| x5 - x7   | t0 - t2       | Temporaries registers                     | Caller    |
| x8        | s0 / fp       | Callee-saved registers / Frame Pointer    | Callee    |
| x9        | s1            | Callee-saved register                     | Callee    |
| x10 - x17 | a0 - a7       | Argument registers                        | Caller    |
| x18 - x27 | s2 - s11      | Callee-saved registers                    | Callee    |
| x28 - x31 | t3 - t6       | Temporaries registers                     | Caller    |

The `Saved by` column have been taken from [Wikipedia](https://en.wikipedia.org/wiki/RISC-V#Register_sets). <br>

### Register types
1. Constant Zero Register
    - This type of register have it value always set to 0. This might sound useless, but this register enabled the functionality of `NOP` psuedoinstruction, which add 0 to 0 into register 0.
2. Return Address Register
    - This register hold the value of address to jump to after finish executing current function.
3. Stack Pointer Register
    - This register points to the very top of the stack.
4. Global Pointer Register
    - Global pointer points to the middle of all global variables live. The reason for pointing to the middle is so that there is no need to store full 32-bits address, instead it can access specific variable with a little bit of offset to global pointer.
5. Thread Pointer Register
    - Thread pointer points to current thread's thread-local storage. This register act as that pointer.
6. Frame Pointer Register
    - This register points to a specific place inside the stack. It always points to the very bottom of current function's frame.
7. Temporary Register
    - These register is free to use for anything, the only catch to these registers is that caller must save data from these registers to somewhere before calling a function.
8. Callee-Saved Register
    - This is similar to Temporary Register, but as the name imply, callee is now responsible for saving and restoring the original data on these register before jumping back to the parent function that called this function.
9. Argument Register
    - Argument Registers are used to pass function arguments, but sometimes, these registers are also used to pass return values from a function back to it caller.
### Saved by types
`Saved by` column referred to which part of the code is responsible for storing data from those register to somewhere else (usually the stack) before calling a function.<br>
1. Saved by Caller
    - This means the code that called a function is responsible for storing data from registers before calling a function.
2. Saved by Callee
    - This means the function being called is the one responsible for storing the data inside these registers, and restore the value back to being the same as before calling the function.

## Instruction Formats
There are a total of 6 instruction formats specified by RISC-V, the table below contains all those formats.<br>

> [!NOTE]
> If you're new to CPU architecture (just like me), instruction formats tell the CPU about where to find the operand, value it needs to use, what address it needs to jump to, etc...

![Instruction formats](./imgs/architecture/instruction_formats.png)<br>
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
For the `imm` field, value from this field is used directly for computation instead of value from a register. In the table, the `imm` is always followed by [...], this is to indicate the position in the final value that will be used by the processor.
After all the bits are in their position, the processor will automatically sign-extended the immediate value into 32-bits value.<br>
Some format with some instruction might do something before extending to 32-bits, like B-type which add 0 to the end before extending. This type of stuff will be explained in the next section of some instruction group.<br>

The table below shows how the processor position each immediate bit. imm[11] of I-type in the table is as the same as in the instruction format above, this also apply to all other imm[...]<br>
<table>
  <tr>
    <th rowspan="2">Instruction Format</th>
    <th colspan="32">Bit no.</th>
  </tr>
  <tr>
    <th>31</th>
    <th>30</th>
    <th>29</th>
    <th>28</th>
    <th>27</th>
    <th>26</th>
    <th>25</th>
    <th>24</th>
    <th>23</th>
    <th>22</th>
    <th>21</th>
    <th>20</th>
    <th>19</th>
    <th>18</th>
    <th>17</th>
    <th>16</th>
    <th>15</th>
    <th>14</th>
    <th>13</th>
    <th>12</th>
    <th>11</th>
    <th>10</th>
    <th>9</th>
    <th>8</th>
    <th>7</th>
    <th>6</th>
    <th>5</th>
    <th>4</th>
    <th>3</th>
    <th>2</th>
    <th>1</th>
    <th>0</th>
  </tr>
  <tr>
    <td>I-Type</td>
    <td colspan="20">Signed-extended into 32-bits</td>
    <td colspan="12">imm[11:0]</td>
  </tr>
  <tr>
    <td>S-Type</td>
    <td colspan="20">Signed-extended into 32-bits</td>
    <td colspan="7">imm[11:5]</td>
    <td colspan="5">imm[4:0]</td>
  </tr>
  <tr>
    <td>B-Type</td>
    <td colspan="19">Signed-extended into 32-bits</td>
    <td>imm[12]</td>
    <td>imm[11]</td>
    <td colspan="6">imm[10:5]</td>
    <td colspan="4">imm[4:1]</td>
    <td>0</td>
  </tr>
  <tr>
    <td>U-Type</td>
    <td colspan="20">imm[31:12]</td>
    <td>0</td>
    <td>0</td>
    <td>0</td>
    <td>0</td>
    <td>0</td>
    <td>0</td>
    <td>0</td>
    <td>0</td>
    <td>0</td>
    <td>0</td>
    <td>0</td>
    <td>0</td>
  </tr>
  <tr>
    <td>J-Type</td>
    <td colspan="11">Signed-extended into 32-bits</td>
    <td>imm[20]</td>
    <td colspan="8">imm[19:12]</td>
    <td>imm[11]</td>
    <td colspan="10">imm[10:1]</td>
    <td>0</td>
  </tr>
</table>

> [!NOTE]
> By the way, when programming on RISC-V, the assembler should handle the bit positioning for you, so don't worry about this stuff too much.

For example, let's say there is a B-type instruction, with this as their immediate field<br>
| 1 | 2 | 3 | 4 | 5 | 6 | 7 | ... | ... | ... | 8 | 9 | 0 | a | b | ... |
|---|---|---|---|---|---|---|-----|-----|-----|---|---|---|---|---|-----|

(`1` and `0` in this situation really means it in binary in this situation, but other value can be anything that is `1` or `0`. I just want to make it easier to identify each bit.)<br>

The product of swapping each bit to its correspond position would be `1b234567890a`.<br>
Next, because this is B-type format, 0 would be added to the back, resulting in `1b234567890a0` as a product.<br>
Finally, the sign will be extended to 32-bits, the final value will be `11111111111111111111b234567890a0`, because this is sign-extended the remainings 19-bits would be 1.<br>

## Instruction Groups
C0 instructions are grouped into multiple groups sorted by their function. This section will be going over all of them.<br>
Some groups may have multiple forms of the same instruction depend on the instruction format, or may have multiple subgroup that do completely difference thing with difference instruction format. But all in all, the opcode would be different, even though they belong to the same group<br>
### Arithmetic and Logic
> [!NOTE]
> The difference between logical and arithmetic shift is that arithmetic will shift while preserving the signed status, essentially just a true divided by 2^n instead of just divided by 2^n without caring about being signed or not.
#### R-type
The opcode for these instructions would be `0110011`<br>
| funct 7   | funct 3   | mnemonic  | operation                         | description                                           |
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
![Special I-type format](./imgs/architecture/special_i-type_format.png)<br>
Image taken from [RISC-V specification document](https://docs.riscv.org/reference/isa/_attachments/riscv-unprivileged.pdf).<br>
I love to think that immediate field ranging from bit 31 down to bit 25 in the special format are used like funct 7 field, while bit 20 up to bit 24 are use as normal immediate field for shifting values.<br>

In the table below, there would be either "imm" or "shamt" as a second operand.
"imm" implys that the instruction use full 12-bits immediate value as the second operand, while "shamt" means that the processor use only last 5-bits from the immediate value of the "special" I-type format as the second operand.<br>

| funct 7 (bit 31 - 25) | funct 3   | mnemonic  | operation                         | description                                       |
|-----------------------|-----------|-----------|-----------------------------------|---------------------------------------------------|
| -                     | 000       | ADDI      | rd = `rs1` + imm                  | add imm to `rs1`                                  |
| 0000000               | 001       | SLLI      | rd = `rs1` << shamt               | logical shift `rs1` left by shamt                 |
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
The effective address of that memory is calculated by adding value from `rs1` to immediate field that have been sign-extended, giving it an ability to offset ±2K addresses from `rs1`.<br>

For specific amount of bits that would be loaded, there will be a column for that in the table below called `load size` column.<br>

Opcode for these instructions would be `0000011`.<br>
| funct 3   | mnemonic  | load size | note                                    |
|-----------|-----------|-----------|-----------------------------------------|
| 000       | LB        | 8         | loaded data is sign-extended to 32-bits |
| 001       | LH        | 16        | loaded data is sign-extended to 32-bits |
| 010       | LW        | 32        | -                                       |
| 100       | LBU       | 8         | loaded data is zero extended to 32-bits |
| 101       | LHU       | 16        | loaded data is zero extended to 32-bits |
#### Store (S-type)
For store group, these instructions copy the last ... bits (specify in `store size` column) from `rs2` to memory.<br>
The effective address of the memory for these instructions use the same way of calculating as the load group, also giving it an ability to offset the address from `rs1` for ±2K addresses. The immediate field of S-type format mights be a bit wonky to look at, but it is the same as 12-bits field of I-type format, just placing differently.<br>

Opcode for these instructions would be `0100011`.<br>
| funct 3   | mnemonic  | store size |
|-----------|-----------|-----------|
| 000       | SB        | 8         |
| 001       | SH        | 16        |
| 010       | SW        | 32        |
### Jump
#### Conditional Jump (Branch, B-type)
This group of instructions will add specific number to the program counter of the processor to jump to new instruction address, when a condition of instruction is met. Effectively, an if-else instruction.<br>
Number of offset that would be added to program counter is within the range of ±4KiB. This offset is encoded in the 12-bits immediate field of B-type format. The reason for the 12-bits field to have a range of ±4KiB is that the immediate field will be left shift then sign-extended to 32-bits. This satisfied RISC-V's requirement for the offset to be multiples of 2.<br>

The opcode for this instruction group would be `1100011`.<br>
| funct 3   | mnemonic  | description                                               |
|-----------|-----------|-----------------------------------------------------------|
| 000       | BEQ       | branch if `rs1` and `rs2` are equal                       |
| 001       | BNE       | branch if `rs1` and `rs2` are not equal                   |
| 100       | BLT       | branch if `rs1` is less than `rs2` (signed version)       |
| 101       | BGE       | branch if `rs1` is greater than `rs2` (signed version)    |
| 110       | BLTU      | branch if `rs1` is less than `rs2` (unsigned version)     |
| 111       | BGEU      | branch if `rs1` is greater than `rs2` (unsigned version)  |
#### Unconditional Jump
This type of jump will also add specific number to the program counter, to jump to specific instruction. But, this type of jump will always occur, there is no check if a condition is met. This is use for something like returning from a function.<br>
This group of instructions contains two instructions, both use difference opcode and instruction format. They are listed down below.
##### JAL (J-type)
This instruction use J-type instruction format. Like the B-type instruction format, 0 is also added to the end of the immediate value and signed-extended.<br>
This immediate value is use as an offset to jump to from current address by adding the offset to the program counter. The range for the offset is ±1MiB. This instruction also saves next instruction address (current + 4 bytes) to any register specify in `rd`, but following ABI specification this should be x1 or return address register, or you can use x0 which is constant zero register if you want to discard the address.<br>
Opcode for `JAL` instruction is `1101111`.<br>
##### JALR (I-type)
`JALR` is I-type instruction format instead of J-type, and instead of using an offset to jump to specific instruction address, this instruction use fixed address obtain by adding the value from the immediate field that have been sign-extended to 32-bits to value from `rs1`, then the last bit's value will be set to 0 (not 0 added to the back). The program counter is then set to this value. The x1 register is also used by the instruction to save the next instruction address (current + 4 bytes), just like `JAL`.<br>
Opcode for `JALR` instruction is `1100111`, and it uses I-type instruction format.
### Upper Immediate
This group contains two instructions just like Unconditional Jump group. Job of this group's instructions is to load upper 20-bits of immediate value to target register.<br>
This instruction group use U-type format, but there are two difference opcodes for each of the instruction.<br>
#### LUI
`LUI` loads first 20-bits then left shift those 20-bits into 32-bits into `rd`. When shifting, zero will be added to the right.<br>
The opcode for this instruction is `0110111`.<br>
#### AUIPC
`AUIPC` pretty much does what `LUI` does, but added the current value from program counter before loading into `rd`.<br>
This instruction use `0010111` as its opcode.<br>


# Microarchitecture
For this section, I'll be talking a little bit more about the hardware now. It's now, how will the CPU do it.<br>
As I said in the first section, I've cut out most modern processor design feature and technique. This also includes hardware stuff, like I/O, interrupts, cache, being in-order execution and superscalar design. This will result in 1 instruction per clock cycles (and it should stuck at 1 instruction per cycle) from no instruction level parallelism, but this is why there is 0 in C0.<br>

## Instruction Cycle
Instruction cycle are processes the CPU have to take to complete the execution of an instruction. In C0, there are 5 stages of instruction cycle. They follow classic RISC style instruction cycle, there are<br>
1. Fetch (IF)
    * The processor fetches an instruction from a memory, the address of an instruction is taken from processor's [Program Counter](#program-counter-pc).
2. Decode (ID)
    * The instruction is decoded by the CPU. This process tells the CPU what is the instruction wanted to do to which part of the processor. After decoding the instruction, the processor will receive opcode and funct3/7, this is then used to generate the signal for controlling the flow of the data throughout the cycles.
3. Execute (EX)
    * Every math and logic related operations happen in this stage (including calculating the jump address or memory address). The Control Signal for controlling the [ALU](#arithmetic-and-logic-unit-alu) is sent from the previous stage. This stage also generates new Control Signal that decided whether the processor wanted to jump or not.
4. Memory (MEM)
    * This stage is exclusively made for Load and Store group. After address calculation have been done by the execution stage, this stage took that address to interact with the memory (if the operation is memory interaction).
5. Writeback (WB)
    * If required, the result will be written back to the designated register at this stage.

## Instruction Pipeline
Instruction pipeline is a technique use to increase execution speed of a processor, it is done by taking instruction cycle from section above then stack multiple instruction cycles on top of each other with an offset of 1 clock cycle. Doing this make every stage of the cycle (almost) always busy making performance much higher.<br>

Two tables below is the comparison between processor that didn't implement instruction pipeline and one that did.<br>
<table>
  <tr>
    <th rowspan="2">Instruction</th>
    <th colspan="15">Clock cycle no.</th>
  </tr>
  <tr>
    <th>1</th>
    <th>2</th>
    <th>3</th>
    <th>4</th>
    <th>5</th>
    <th>6</th>
    <th>7</th>
    <th>8</th>
    <th>9</th>
    <th>10</th>
    <th>11</th>
    <th>12</th>
    <th>13</th>
    <th>14</th>
    <th>15</th>
  </tr>
  <tr>
    <td>Instruction 1</td>
    <td>IF</td>
    <td>ID</td>
    <td>EX</td>
    <td>MEM</td>
    <td>WB</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>Instruction 2</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td>IF</td>
    <td>ID</td>
    <td>EX</td>
    <td>MEM</td>
    <td>WB</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>Instruction 3</td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td></td>
    <td>IF</td>
    <td>ID</td>
    <td>EX</td>
    <td>MEM</td>
    <td>WB</td>
  </tr>
</table>
Processor that didn't implement instruction pipeline.<br>
<table>
  <tr>
    <th rowspan="2">Instruction</th>
    <th colspan="7">Clock cycle no.</th>
  </tr>
  <tr>
    <th>1</th>
    <th>2</th>
    <th>3</th>
    <th>4</th>
    <th>5</th>
    <th>6</th>
    <th>7</th>
  </tr>
  <tr>
    <td>Instruction 1</td>
    <td>IF</td>
    <td>ID</td>
    <td>EX</td>
    <td>MEM</td>
    <td>WB</td>
    <td></td>
    <td></td>
  </tr>
  <tr>
    <td>Instruction 2</td>
    <td></td>
    <td>IF</td>
    <td>ID</td>
    <td>EX</td>
    <td>MEM</td>
    <td>WB</td>
    <td></td>
  </tr>
  <tr>
    <td>Instruction 3</td>
    <td></td>
    <td></td>
    <td>IF</td>
    <td>ID</td>
    <td>EX</td>
    <td>MEM</td>
    <td>WB</td>
  </tr>
</table>
Processor that did implement instruction pipeline.<br>

As you can see, processor with instruction pipeline complete all instruction execution in just 7 clock cycles, while the one that didn't need 15 clock cycles.<br>
### Hazards
But instruction pipeline comes with a catch, because pipeline fetch a new instruction before knowing the outcome of the instruction before this one. These type of situations are called "Hazard".<br>
Usually hazards are handled by dedicated hardware unit like branch predictor, or design technique like superscalar design. But, in my design, I've decided to push all the responsibility to the programmer to switch the execution to instruction that aren't data dependent on other instruction, or to just call multiple `NOP` instructions before continuing the execution to keep the design simple.<br>

There are multiple types of hazards. I've written a brief description about them down below, if you're interested.<br>
#### Structural Hazards
This type of hazard occur when there are multiple instructions tried to use the same component, this won't occur in C0 though. This hazard can be fixed by implement same component multiple times which is called superscalar design.<br>
#### Data Hazards
Data hazard occur when one instruction depend on the result of another instruction that hasn't finished execute yet.<br>
#### Control Hazards
Control hazard occur for every jump/branch instruction, this is due to new instructions are being fetched with old address before the instruction finally having an effect on the program counter.<br>

## Datapath
Datapath is a physical implementation of [Instruction Cycle](#instruction-cycle). The datapath is divided into 5 stages correspond for the stages specified in [Instruction Cycle](#instruction-cycle). As said before, the datapath is pipelined, meaning that, at every ending part of each stage (except the writeback stage) will have a set of registers to hold the data from that stage and forward those to the next at the edge of the next clock cycle, to give the capability of handling multiple stages at a time to the processor.<br>

![Entire datapath](./imgs/microarchitecture/entire_datapath.png)<br>
Image of entire datapath.<br>

### Fetch Stage (IF)
![Entire datapath of fetch stage](./imgs/microarchitecture/fetch_stage.png)<br>
In this stage, program counter (PC) do the job of remembering the current instruction address, that address is then used for accessing the instruction from the [Instruction Memory](#instruction-memory). The fetched instruction is then passed to [Instruction Register](#ifid-stage-registers) to be then decoded by the next stage.<br>

Every clock cycle, program counter either go up by 4 bytes which is the next instruction because 32-bits, or could use the target address and jump signal coming from writeback stage to jump to whole new address.<br>

The program counter's value is also pass to program counter register, in case the processor need to compute a jump address with an offset, or remembering the return address.<br>

### Decode Stage (ID)
![Entire datapath of decode stage](./imgs/microarchitecture/decode_stage.png)<br>
This stage is all about preparing all the required data for processing in the future.<br>
The instruction inside the [Instruction Register](#ifid-stage-registers) is then decoded by [Instruction Decoder](#instruction-decoder) into multiple part, which is then processed further to generate their usable form.<br>
The processed values are listed down below.<br>
1. Controls Signals
    - Control Signals are generated by [Control Signal Generator](#control-signal-generator). They're used for directing the flows of data throughout the pipeline. There are many Control Signals which are the following.<br>
      1. `ALUOperand`: Signifies the [ALU](#arithmetic-and-logic-unit-alu)'s multiplexer to choose the correct data as operands for the [ALU](#arithmetic-and-logic-unit-alu).
      2. `ALUOp`: Signifies which operation [ALU](#arithmetic-and-logic-unit-alu) have to choose. This Control Signal also required `imm` field value for processing the [I-Type arithmetic and logic instruction](#i-type).
      3. `MEMRead`: Signifies if the processor wanted to read from the data memory.
      4. `MEMWrite`: This is like `MEMRead`, but instead it signifies write operation.
      5. `rdSrc`: This signifies which data is chosen to write to the `rd`. (More information in [WB stage](#writeback-stage-wb))
      6. `rdWrite`: This signifies if the processor really wants to write to `rd`.
      7. `JmpOp`: This Control Signal signifies if the instruction's operation is a form of jump operation or not. This Control Signal is 2-bits long, which have the following possible combination:
          - `00`: Not a jump operation.
          - `01`: Is a conditional jump operation.
          - `10`: Is an unconditional jump operation.
2. 32-bits Immediate value
    - As specified in the instruction format, all format's `imm` field are not 32-bits long. The [Immediate Assembler](#immediate-assembler) took `imm` field value and the format of the instruction for calculating the 32-bits form of immediate value.
3. Source Register Data
    - The [Instruction Decoder](#instruction-decoder) extract the address of `rs1` and `rs2`, these addresses are then plugged into [Register File](#register-file) for retrieving the two's data.

After these three, there is also `rd` address, which after extracted by [Instruction Decoder](#instruction-decoder), it's then pass directly to stage's register.

> [!NOTE]
> [Immediate Assembler](#immediate-assembler) handles the job of extending immediate value into full 32-bits. It is usually called Sign-Extend / Zero-Extend Unit, but [Immediate Assembler](#immediate-assembler) sounds a lot cooler to me.

After processing, all those values are pass to the next stage using registers.<br>

### Execute Stage (EX)
![Entire datapath of execute stage](./imgs/microarchitecture/execute_stage.png)<br>
All the math and logic stuffs happen in this stage.<br>
The [ALU](#arithmetic-and-logic-unit-alu) computes all the math and logic related operations. The Control Signal which tell the [ALU](#arithmetic-and-logic-unit-alu) what to do, and what operands to choose are generated from [ID stage](#decode-stage-id). The signals are passed to this stage by registers.<br>
If the operation is jump operation, no matter if it is conditional or unconditional, the [ALU](#arithmetic-and-logic-unit-alu)'s flags and JmpOp Control Signal are passed to a unit called [Jmp Handler](#jmp-handler). The [Jmp Handler](#jmp-handler) generates new Control Signal called PCSrc, which specify if the [PC](#program-counter-pc) should jump or not.<br>

> [!NOTE]
> Modern processor move the [Jmp Handler](#jmp-handler)'s functionality to [ID stage](#decode-stage-id), which use dedicated comparator instead of [ALU](#arithmetic-and-logic-unit-alu)'s flags. This reduce the penalty of branch operation down to 1 cycle.

There is also an adder, which always add 4 to the [PC](#program-counter-pc), before passing to the next stage. This value is used for when the processor wanted to jump, but also wanted to remember the return address. This adder helps to achieve this functionality.<br>

This stage also ended with many registers to pass all sort of values to the next stage.<br>

### Memory Stage (MEM)
![Entire datapath of memory stage](./imgs/microarchitecture/memory_stage.png)<br>
After address calculation by the ALU, the processor put the 32-bits result into the [Address Decoder](#address-decoder) to find out the target device ([Data Memory](#data-memory) or any peripheral) then sent out the remaining 31-bits address, `rs2` data (write data) and the Control Signals (`MEMRead` and `MEMWrite`) to it correspond destination ([Data Memory](#data-memory) or [Peripheral Controller](#peripheral-controller) for any peripheral device).<br>
This stage use Control Signals to decided whether it wanted to read from, write to, or does nothing to the [Data Memory](#data-memory).<br>

If the target device is peripheral then the [Peripheral Controller](#peripheral-controller) will decode the remaining 31-bits to pinpoint the exact target peripheral, before passing `rs2` data (write data) and the Control Signals (`MEMRead` and `MEMWrite`) to that peripheral just like what [Address Decoder](#address-decoder) does.<br>

The [Address Decoder](#address-decoder) also generates new Control Signal that controls the behavior of a mux that switch the between data from [Data Memory](#data-memory) and the [Peripheral Controller](#peripheral-controller).<br>

Again, this stage passes some data to the next stage using multiple registers.<br>

### Writeback Stage (WB)
![Entire datapath of writeback stage](./imgs/microarchitecture/writeback_stage.png)<br>
This stage return all the data from all the previous stages back to their correspond destination. The write back data are the following.<br>
1. [Program Counter](#program-counter-pc)'s jump address.
    - The [Program Counter](#program-counter-pc) will have to either choose its value + 4 (calculated inside the [IF stage](#fetch-stage-if)) or the jump address, which is just an [ALU](#arithmetic-and-logic-unit-alu)'s result (calculated inside [EX stage](#execute-stage-ex)). The signal from [EX stage](#execute-stage-ex) that have been pass to this stage using register is used for choosing between the two.
2. `rd`'s write data.<br>
    - The processor use Control Signal from [ID stage](#decode-stage-id) to choose between PC + 4, [ALU](#arithmetic-and-logic-unit-alu)'s result or read data from the memory as a data writing into `rd` with an address it got from [ID stage](#decode-stage-id). There is also Control Signals that tell whether if the processor really wanted to write the data or not.

> [!NOTE]
> The write back of PCSrc Control Signal could be moved to [EX stage](#execute-stage-ex) after computing this Control Signal, this make the branch penalty goes down to 2 cycles. But, 4 cycles branch penalty look "insane" to me, so WB stage here I come.

# Hardware Design
This section covers each component inside the processor. This is difference from the [Microarchitecture](#microarchitecture) section in that, this section goes into inner working of each hardware unit, rather than how data flow through them.<br>

The order of each component is sorted by how early they are occurred in the instruction pipeline.<br>
## Program Counter (PC)
Program Counter keeps track of the current instruction address.<br>
Program Counter is a 32-bits register with input hook up to a multiplexer. The multiplexer choose between 2 source inputs for it 1 output, the source of it output is either value of the Program Counter + 4 bytes (essentially the next instruction address), or also the value of Program Counter with difference processing like + offset.<br>
The PCSrc Control Signal for controlling the source of the output is generated from the [Execution Unit](#execution-unit-eu).<br>

![Program Counter Diagram](./imgs/hardware_design/program_counter.png)<br>
Diagram of the inside of Program Counter<br>

## Instruction Memory
Instruction Memory holds all the instruction that the processor will use for processing. The processor uses 32-bits address from Program Counter to fetch an instruction from that specific address.<br>

C0's memory is similar to Harvard Architecture's memory, meaning that instruction and data lives in difference memory. They have their own memory space.<br>

## IF/ID Interstage Registers
Just like in the pipeline diagram, there are two registers, both are 32-bits long. They're the following.<br>
1. Instruction Register
    - Instruction Register temporary holds instruction from [Instruction Memory](#instruction-memory).<br>
    The processor took address value from Program Counter, which is called instruction address, and push the value to [Instruction Memory](#instruction-memory). The [Instruction Memory](#instruction-memory) should now give instruction at that specific address back to the processor. The processor is then put that instruction into Instruction Register.<br>
2. PC Register
    - This register only hold the value of the current instruction address, it's for further processing in the [EX Stage](#execute-stage-ex) of the pipeline, or by the [EU](#execution-unit-eu).<br>

## Control Unit (CU)
Control Unit is a stateless combinational logic that controls the flow of the data. It controls the flow of data by sending multiple Control Signals to multiple part of the processor.<br>
Being a stateless combinational logic means that the CU updates its Control Signals instantly after receiving new input values.<br>

Control Unit have about 2 subcomponents, which are the following.<br>
### Instruction Decoder
Instruction Decoder took the instruction currently hold inside the [Instruction Register](#ifid-stage-registers), and separate that instruction into multiple parts according to the [Instruction Format](#instruction-formats) of the instruction.
### Control Signals Generator
This unit generates all sort of Control Signals for the processor. It took opcode, funct3/7 and raw immediate value decoded by the [Instruction Decoder](#instruction-decoder) to generate the Control Signals.<br>
The Control Signals generate by this unit is the same as the one in the [ID Stage](#decode-stage-id) diagram.<br>

## Immediate Assembler
Immediate Assembler took raw immediate data and format type from [Instruction Decoder](#instruction-decoder), and assemble the immediate value into usable 32-bits length form.

## Register File
Register File is where all 32 registers of this processor live.<br>
![Register File Diagram](./imgs/hardware_design/register_file.png)
There are a total of 5 inputs for Register File (not counting reset data and clock line), each is either for writing data into one specific register, or it is for reading two specific register.<br>

For reading data from two registers, there are two specific 5-bits input, both are for selecting the source register. The design of this Register File support reading from 2 registers simultaneously.<br>

For writing data into the Register File, there is 1 input for enabling the write mode, another 5-bits input for selecting the destination register, and the other is the 32-bits data that would be writing into a register.<br>

## ID/EX Interstage Registers
This interstage contains 12 registers. From this point on, if there are no description for specific registers that would mean they are the same as previous interstage register.<br>
1. Immediate Value Register
    - This stage register holds the extended form of `imm` field value from the [Immediate Assembler](#immediate-assembler), this register is 32-bits long.
2. `rs1` Data Register
    - This register holds the value of `rs1`'s data, which have been read from the [Register File](#register-file), this register is 32-bits long.
3. `rs2` Data Register
    - This stage register is the same as `rs1`'s, but holds the data of `rs2` instead.
4. `rd` Address Register
    - This register holds the address of `rd`, this register is only 5-bits long.
5. [PC Register](#ifid-interstage-registers)
6. `ALUOp` Control Signal Register
    - This register is for passing the Control Signal that control [ALU](#arithmetic-and-logic-unit-alu)'s operation, this register is 4-bits wide.
7. `ALUOperand` Control Signal Register
    - This register holds the Control Signal that select the source of the [ALU](#arithmetic-and-logic-unit-alu)'s operands, this register is only 2-bits wide (two mux use two separate bit).
8. `MEMRead` Control Signal Register
    - This register holds Control Signal that signifies read operation to the [Data Memory](#data-memory), this register is also only 1-bit wide.
9. `MEMWrite` Control Signal Register
    - This stage register is similar to the `MEMRead`'s register, but instead this signifies write operation.
10. `rdSrc` Control Signal Register
    - This register holds the Control Signal that choose the source of the data written into `rd`. This register is 2-bits long for choosing between 3 sources.
11. `rdWrite` Control Signal Register
    - This stage register is only 1-bit long. The purpose of this register is to holds the Control Signal that choose if the processor wants to write to the `rd`.
12. `JmpOp` Control Signal Register
    - This register holds the type of jump operation what the instruction is. This register is 2-bits long.

More information on Control Signal [here](#decode-stage-id).

## Execution Unit (EU)
Execution Unit pack multiple components for handling the [EX Stage](#execute-stage-ex) of the pipeline into one component.<br>

All Execution Unit's subcomponent are listed down below.<br>
### Arithmetic and Logic Unit (ALU)
Arithmetic and Logic Unit handles most of the math and logic operation. The only math it doesn't handle is calculating the next instruction address, that would be the job of a [+ 4 Adder](#-4-adder).<br>
The ALU use Control Signal from the Control Unit to select it operation, this Control Signal is called `ALUOp`.<br>
### Operand Multiplexer
There are two Operand Multiplexers, each is for selecting the operand for the [ALU](#arithmetic-and-logic-unit-alu) between two source (between `PC` and `rs1`, `imm` and `rs2`). The [Control Signals Generator](#control-signals-generator) generates the signal for controlling these multiplexers. This Control Signal is called `ALUOperand`. Each of the mux use a difference bit of the Control Signal. The first operand use LSB bit, while the second use MSB bit.
### Jmp Handler
This unit handle the jump operation. It took `JmpOp` Control Signal from the [CU](#control-unit-cu), and added [ALU](#arithmetic-and-logic-unit-alu)'s branching associated flags. This will result in `1x` if the jump condition is met, and `0x` if the jump condition is not met (`x` could be `1` or `0`). The Jmp Handler will generate new Control Signal using the second bit of the result. This would mean that `1` means jump, while `0` means it would not.<br>
### + 4 Adder
All this adder do is took the value from [PC](#program-counter-pc), and you guess it, add four to it.<br>
This is specifically for handling jump instruction that link the return address, this is because the [ALU](#arithmetic-and-logic-unit-alu) will be occupied by address calculation. So, there is this small adder for calculating the next instruction address.<br>

## EX/MEM Interstage Registers
In this interstage, there will be 9 registers, mostly still Control Signal registers.<br>
1. PC + 4 Register
    - This register holds the next instruction address register. This is useful for jump and link instructions. This register is 32-bits wide.
2. [`rs2` Data Register](#idex-interstage-registers)
3. [ALU](#arithmetic-and-logic-unit-alu) Result Register
    - This register holds result from the [ALU](#arithmetic-and-logic-unit-alu), no matter if the result is integer or address calculation. This register is 32-bits long.
4. [`rd` Address Register](#idex-interstage-registers)
5. [`MEMRead` Control Signal Register](#idex-interstage-registers)
6. [`MEMWrite` Control Signal Register](#idex-interstage-registers)
7. [`rdSrc` Control Signal Register](#idex-interstage-registers)
8. [`rdWrite` Control Signal Register](#idex-interstage-registers)
9. `PCSrc` Control Signal Register
    - This interstage register holds the Control Signal that controls the source of [PC](#program-counter-pc) between the next instruction address, and the jump address calculated by the [ALU](#arithmetic-and-logic-unit-alu). This register is only 1-bit wide.

## Address Decoder
Address Decoder identify if the address is for [Data Memory](#data-memory) or for the peripheral device. After identifying the target, it then redirects the write data, [ALU](#arithmetic-and-logic-unit-alu)'s result and Control Signals into either the [Data Memory](#data-memory) or peripheral device.<br>

The Address Decoder identifies the target device by simply looking at the bit(s) for identifying the target device. Which for this case, I will use the MSB, `0` for Data Memory, and `1` for any peripheral device.<br>

If the target is peripheral device, the data will be redirected to [Peripheral Controller](#peripheral-controller) for further decoding to identify the exact device.<br>

## Data Memory
As said before in the [Instruction Memory](#instruction-memory) section, the data memory is separate from the [Instruction Memory](#instruction-memory). The processor use 31-bits address, `rs2` data and Control Flags that have been redirected from [Address Decoder](#address-decoder) for interaction with the Data Memory. This also make the largest possible data memory to be around 2GB (2GB for processor this bad? Damn).<br>

## Peripheral Controller
Peripheral Controller decodes the remaining 31-bits address even further to identify the exact target peripheral, and redirect the remaining data. Essentially it is the [Address Decoder](#address-decoder) for the peripherals.

## MEM/WB Interstage Registers
This interstage have 7 registers, most are not Control Signal now. They are the following.<br>
1. [PC + 4 Register](#exmem-interstage-registers)
2. [ALU Result Register](#exmem-interstage-registers)
3. Memory Data Register
    - This register hold the data that have been read from the [Data Memory](#data-memory).
4. [`rd` Address Register](#idex-interstage-registers)
5. [`rdSrc` Control Signal Register](#idex-interstage-registers)
6. [`rdWrite` Control Signal Register](#idex-interstage-registers)
7. [`PCSrc` Control Signal Register](#exmem-interstage-registers)

## Destination Register Multiplexer
This one is a simple 3 inputs multiplexer, it's for choosing between [ALU](#arithmetic-and-logic-unit-alu)'s result, [+ 4 Adder](#-4-adder)'s result or data read from the [Data Memory](#data-memory).<br>
This multiplexer is controlled by a Control Signal called `rdSrc`.<br>