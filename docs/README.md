# Architecture
This section will be about the ISA, which C0 is based on. Essentially, what the CPU could do.<br>
C0's ISA is based on RISC-V ISA, specifically [rv32i](https://docs.riscv.org/reference/isa/unpriv/rv32.html) with no extensions or custom instructions, but with a few modifications of how the CPU handles stuff (more on [Microarchitecture Section](#microarchitecture)), and some instructions are removed (`FENCE` group and `ECALL`/`EBREAK`).<br>
So, it isn't quite ready for modern operating system like what RISC-V said for this CPU. It is intended for bare-metal testing only, but you could try running operating system on it. No one is stopping you.<br>

## Registers
In the rv32i, there are 32 32-bits registers, first one is constant zero register, and the other 31 are general purpose. For modern CPU, there would be hundred of physical registers serving purpose of those 32 registers,
but for C0, there would be only 32 physical registers, which directly ties to each register specify in rv32i document.<br>

> [!NOTE]
> Physical register is a register that actually exist in the hardware, which will be used by the CPU to serve a specific purpose under the process of register renaming.<br>
> I don't want to get into register renaming yet, so here is the [link for more information](https://en.wikipedia.org/wiki/Register_renaming).<br>

### Register Purpose
rv32i did specify that 31 registers of those 32 are general purpose, but in the [RISC-V ABI document](https://docs.riscv.org/reference/abi/riscv-cc-register-convention.html), each register is assigned to one specific purpose which are the following.<br>

> [!NOTE]
> ABI is like a standard convention on how to write code for RISC-V CPU specified by RISC-V.<br>

<table>
    <tr>
        <th colspan="1">Register</th>
        <th colspan="1">ABI Mnemonic</th>
        <th colspan="1">Description</th>
        <th colspan="1">Saved by</th>
    </tr>
    <tr>
        <td>x0</td>
        <td>zero</td>
        <td>Constant Zero</td>
        <td>N/A</td>
    </tr>
    <tr>
        <td>x1</td>
        <td>ra</td>
        <td>Return Address</td>
        <td>Caller</td>
    </tr>
    <tr>
        <td>x2</td>
        <td>sp</td>
        <td>Stack Pointer</td>
        <td>Callee</td>
    </tr>
    <tr>
        <td>x3</td>
        <td>gp</td>
        <td>Global Pointer</td>
        <td>N/A</td>
    </tr>
    <tr>
        <td>x4</td>
        <td>tp</td>
        <td>Thread Pointer</td>
        <td>N/A</td>
    </tr>
    <tr>
        <td>x5 - x7</td>
        <td>t0 - t2</td>
        <td>Temporary Register</td>
        <td>Caller</td>
    </tr>
    <tr>
        <td>x8</td>
        <td>s0 / fp</td>
        <td>Callee-Saved Register / Frame Pointer</td>
        <td>Callee</td>
    </tr>
    <tr>
        <td>x9</td>
        <td>s1</td>
        <td>Callee-Saved Register</td>
        <td>Callee</td>
    </tr>
    <tr>
        <td>x10 - x17</td>
        <td>a0 - a7</td>
        <td>Argument Register</td>
        <td>Caller</td>
    </tr>
    <tr>
        <td>x18 - x27</td>
        <td>s2 - s11</td>
        <td>Callee-Saved Register</td>
        <td>Callee</td>
    </tr>
    <tr>
        <td>x28 - x31</td>
        <td>t3 - t6</td>
        <td>Temporary Register</td>
        <td>Caller</td>
    </tr>
</table>
The `Saved by` column have been taken from [Wikipedia](https://en.wikipedia.org/wiki/RISC-V#Register_sets).<br>

1. Constant Zero Register
    - This register have it value always set to 0. This might sound useless, but this register enabled the functionality of `NOP` psuedoinstruction, which add 0 to 0 into register 0. Or, `mv` instruction.
2. Return Address Register
    - This register hold the value of the address to jump to after finish executing current function.
3. Stack Pointer Register
    - This register points to the very top of the stack.
    - Stack in RISC-V grow down from the top by 16 address each time it was push.
4. Global Pointer Register
    - Global pointer points to the middle of where all global variables live. The reason for pointing to the middle is so that there is no need to store full 32-bits address, instead it can access specific variable with a little bit of offset to global pointer.
5. Thread Pointer Register
    - Thread pointer points to current thread's thread-local storage. This register act as that pointer.
    - I don't see use for this register in C0, so might as well use it for what ever you want.
6. Frame Pointer Register
    - This register points to the top of current function's frame inside the stack.
    - The frame pointer changes when the program goes into new function.
    - This register could be used as another Callee-Saved Register instead.
7. Temporary Register
    - These register is free to use for anything, the only catch to these registers is that caller must save data from these registers to somewhere before calling a function, or the data might be overwritten by the function it is calling.
8. Callee-Saved Register
    - This is similar to Temporary Register, but as the name imply, the callee (the function that is getting called) is now responsible for saving and restoring the original data on these register before jumping back to the parent function that called this function.
9. Argument Register
    - Argument Registers are used to pass function arguments, but sometimes, these registers are also used to pass return values from a function back to it caller.
    - If there is more than 8 arguments, then the extra arguments will be passed by the stack instead. The same apply to the return values.
#### Saved by types
`Saved by` column referred to which part of the code is responsible for storing data from those register to somewhere else (usually the stack) before calling a function.<br>
1. Saved by Caller
    - This means the code that called a function is responsible for storing data from registers before calling a function.
2. Saved by Callee
    - This means the function being called is the one responsible for storing the data inside these registers, and restore the value back to being the same as before calling the function.

## Instruction Formats
There are a total of 6 instruction formats specified by RISC-V, the table below contains all those formats.<br>
![Instruction formats](./imgs/architecture/instruction_formats.png)<br>
Image taken from [RISC-V specification document](https://docs.riscv.org/reference/isa/_attachments/riscv-unprivileged.pdf).<br>

> [!NOTE]
> If you're new to CPU architecture (like me), instruction formats tell the CPU about where to find the operand, value it needs to use, what address it needs to jump to, etc...

### Opcode and funct3/7 field
`opcode` field is used to determine the instruction group of current instruction. This field can also be used to determine the format of the instruction.<br>
Some `opcode` maybe directly tie to an instruction, but for most, `funct3` (some with `funct7`) must be used to determine the exact instruction.

In the [I-Type form of Arithmetic and Logic instruction group](#i-type), some instruction may use `imm` field as `funct7` instead.

### Register field
There are two type of the register field. One is for specifying the source register for computer, and the other for destination register where result of the instruction will be save into.
`rs1` and `rs2` are the source register, while `rd` is the destination register.

### Immediate field
For the `imm` field, value from this field is used directly for computation instead of value from a register.<br>
In the instruction format table, the `imm` is always followed by [...:...], this is to indicate each immediate field bit's position in the final 32-bits value that will be used by the processor.
After all the bits are in their position, the processor will automatically sign-extended the immediate value into 32-bits value.<br>

Some format with some instruction might do something before extending to 32-bits, like B-type which add 0 to the end before extending. This type of stuff will be explained in the next section of some instruction group.<br>

The table below shows how the processor position each immediate field bit.
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
        <td>I-type</td>
        <td colspan="20">Signed-extended into 32-bits</td>
        <td colspan="12">imm[11:0]</td>
    </tr>
    <tr>
        <td>S-type</td>
        <td colspan="20">Signed-extended into 32-bits</td>
        <td colspan="7">imm[11:5]</td>
        <td colspan="5">imm[4:0]</td>
    </tr>
    <tr>
        <td>B-type</td>
        <td colspan="19">Signed-extended into 32-bits</td>
        <td>imm[12]</td>
        <td>imm[11]</td>
        <td colspan="6">imm[10:5]</td>
        <td colspan="4">imm[4:1]</td>
        <td>0</td>
    </tr>
    <tr>
        <td>U-type</td>
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
        <td>J-type</td>
        <td colspan="11">Signed-extended into 32-bits</td>
        <td>imm[20]</td>
        <td colspan="8">imm[19:12]</td>
        <td>imm[11]</td>
        <td colspan="10">imm[10:1]</td>
        <td>0</td>
    </tr>
</table>

> [!NOTE]
> When programming on RISC-V, the assembler/compiler should handle the bit positioning for you, so don't worry about this stuff too much.

Suppose we have this B-type instruction, with this as their immediate field<br>
<table>
    <tr>
        <th colspan="7">imm[12|10:5]</th>
        <th colspan="1">rs2</th>
        <th colspan="1">rs1</th>
        <th colspan="1">funct3</th>
        <th colspan="5">imm[4:1|11]</th>
        <th colspan="1">opcode</th>
    </tr>
    <tr>
        <td>1</td>
        <td>2</td>
        <td>3</td>
        <td>4</td>
        <td>5</td>
        <td>6</td>
        <td>7</td>
        <td>?</td>
        <td>?</td>
        <td>?</td>
        <td>8</td>
        <td>9</td>
        <td>0</td>
        <td>a</td>
        <td>b</td>
        <td>?</td>
    </tr>
</table>

`1` and `0` in this situation really means `1` and `0` in binary, but other value can be anything that is `1` or `0`. I just want to make it easier to identify each bit.<br>

The product of swapping each bit to its correspond position would be `1b234567890a`.<br>
Next, because this is B-type format, 0 would be added to the back, resulting in `1b234567890a0` as a product.<br>
Finally, the sign will be extended to 32-bits, the final value will be `11111111111111111111b234567890a0`, because this is sign-extended the remainings 19-bits would be 1.<br>

## Instruction Groups
### Arithmetic and Logic
#### R-type
The `opcode` for these instructions is `0110011`<br>
<table>
    <tr>
        <th colspan="1">funct7</th>
        <th colspan="1">funct3</th>
        <th colspan="1">Mnemonic</th>
        <th colspan="1">Operation</th>
        <th colspan="1">Description</th>
    </tr>
    <tr>
        <td>0000000</td>
        <td>000</td>
        <td>ADD</td>
        <td>rd = rs1 + rs2</td>
        <td>Add rs2 to rs1</td>
    </tr>
    <tr>
        <td>0100000</td>
        <td>000</td>
        <td>SUB</td>
        <td>rd = rs1 - rs2</td>
        <td>Subtract rs2 from rs1</td>
    </tr>
    <tr>
        <td>-</td>
        <td>001</td>
        <td>SLL</td>
        <td>rd = rs1 << rs2</td>
        <td>Left shift the rs1 by the lower 5-bits of rs2</td>
    </tr>
    <tr>
        <td>-</td>
        <td>010</td>
        <td>SLT</td>
        <td>rd = rs1 < rs2</td>
        <td>Is rs1 less than rs2 (signed version)</td>
    </tr>
    <tr>
        <td>-</td>
        <td>011</td>
        <td>SLTU</td>
        <td>rd = rs1 < rs2 (unsigned)</td>
        <td>Is rs1 less than rs2 (unsigned version)</td>
    </tr>
    <tr>
        <td>-</td>
        <td>100</td>
        <td>XOR</td>
        <td>rd = rs1 ^ rs2</td>
        <td>rs1 bitwise xor with rs2</td>
    </tr>
    <tr>
        <td>0000000</td>
        <td>101</td>
        <td>SRL</td>
        <td>rd = rs1 >> rs2</td>
        <td>Logical right shift the rs1 by the lower 5-bits of rs2</td>
    </tr>
    <tr>
        <td>0100000</td>
        <td>101</td>
        <td>SRA</td>
        <td>rd = rs1 >>> rs2</td>
        <td>Arithmetic right shift the rs1 by the lower 5-bits of rs2</td>
    </tr>
    <tr>
        <td>-</td>
        <td>110</td>
        <td>OR</td>
        <td>rd = rs1 | rs2</td>
        <td>rs1 bitwise or with rs2</td>
    </tr>
    <tr>
        <td>-</td>
        <td>111</td>
        <td>AND</td>
        <td>rd = rs1 & rs2</td>
        <td>rs1 bitwise and with rs2</td>
    </tr>
</table>

> [!NOTE]
> The difference between logical and arithmetic shift is that arithmetic will preserve the signed status, essentially just a true divided by 2^n instead of just divided by 2^n without caring about being signed or not.
#### I-type
The `opcode` for these instructions is `0010011`<br>

For `SLLI`, `SRLI` and `SRAI`, the encoding of the I-type format is a little bit different from the normal I-type. The image below is how the "special" I-type format are encoded.<br>
![Special I-type format](./imgs/architecture/special_i-type_format.png)<br>
Image taken from [RISC-V specification document](https://docs.riscv.org/reference/isa/_attachments/riscv-unprivileged.pdf).<br>
I love to think that immediate field ranging from bit 31 down to bit 25 in the special format instruction are used like `funct7` field for some instructions, while bit 20 up to bit 24 are use as normal immediate field for shifting values.<br>

In the table below, there would be either `imm` or `shamt` as a second operand.
`imm` implies that the instruction use the full 32-bits extended of the 12-bits immediate value as the second operand, while `shamt` means that the processor use only the last 5-bits from the immediate value (bit 20 to bit 24) of the "special" I-type format as the second operand.<br>

<table>
    <tr>
        <th colspan="1">funct7 (bit 31 - bit 25)</th>
        <th colspan="1">funct3</th>
        <th colspan="1">Mnemonic</th>
        <th colspan="1">Operation</th>
        <th colspan="1">Description</th>
    </tr>
    <tr>
        <td>-</td>
        <td>000</td>
        <td>ADDI</td>
        <td>rd = rs1 + imm</td>
        <td>Add imm to rs1</td>
    </tr>
    <tr>
        <td>0000000</td>
        <td>001</td>
        <td>SLLI</td>
        <td>rd = rs1 << shamt</td>
        <td>Left shift the rs1 by shamt amount</td>
    </tr>
    <tr>
        <td>-</td>
        <td>010</td>
        <td>SLTI</td>
        <td>rd = rs1 < imm</td>
        <td>Is rs1 less than imm (signed version)</td>
    </tr>
    <tr>
        <td>-</td>
        <td>011</td>
        <td>SLTUI</td>
        <td>rd = rs1 < imm (unsigned)</td>
        <td>Is rs1 less than imm (unsigned version)</td>
    </tr>
    <tr>
        <td>-</td>
        <td>100</td>
        <td>XORI</td>
        <td>rd = rs1 ^ imm</td>
        <td>rs1 bitwise xor with imm</td>
    </tr>
    <tr>
        <td>0000000</td>
        <td>101</td>
        <td>SRLI</td>
        <td>rd = rs1 >> shamt</td>
        <td>Logical right shift the rs1 by shamt amount</td>
    </tr>
    <tr>
        <td>0100000</td>
        <td>101</td>
        <td>SRAI</td>
        <td>rd = rs1 >>> shamt</td>
        <td>Arithmetic right shift the rs1 by shamt amount</td>
    </tr>
    <tr>
        <td>-</td>
        <td>110</td>
        <td>ORI</td>
        <td>rd = rs1 | imm</td>
        <td>rs1 bitwise or with imm</td>
    </tr>
    <tr>
        <td>-</td>
        <td>111</td>
        <td>ANDI</td>
        <td>rd = rs1 & imm</td>
        <td>rs1 bitwise and with imm</td>
    </tr>
</table>

### Load and Store
#### Load (I-type)
For these operations, they're used for loading some amount of bits from memory or any peripheral to `rd`.<br>
The effective address of the target is calculated by adding value from `rs1` to immediate field that have been sign-extended, giving it an ability to offset ±2K addresses from `rs1`.<br>
For specific amount of bits that would be loaded, there will be a column for that in the table below called `load size` column.<br>

`opcode` for these instructions would be `0000011`.<br>

<table>
    <tr>
        <th colspan="1">funct3</th>
        <th colspan="1">Mnemonic</th>
        <th colspan="1">Load Size</th>
        <th colspan="1">Note</th>
    </tr>
    <tr>
        <td>000</td>
        <td>ADDI</td>
        <td>rd = rs1 + imm</td>
        <td>Add imm to rs1</td>
    </tr>
    <tr>
        <td>001</td>
        <td>SLLI</td>
        <td>rd = rs1 << shamt</td>
        <td>Left shift the rs1 by shamt amount</td>
    </tr>
    <tr>
        <td>010</td>
        <td>SLTI</td>
        <td>rd = rs1 < imm</td>
        <td>Is rs1 less than imm (signed version)</td>
    </tr>
    <tr>
        <td>100</td>
        <td>SLTUI</td>
        <td>rd = rs1 < imm (unsigned)</td>
        <td>Is rs1 less than imm (unsigned version)</td>
    </tr>
    <tr>
        <td>101</td>
        <td>XORI</td>
        <td>rd = rs1 ^ imm</td>
        <td>rs1 bitwise xor with imm</td>
    </tr>
</table>

| `funct3`  | mnemonic  | load size | note                                    |
|-----------|-----------|-----------|-----------------------------------------|
| 000       | LB        | 8         | loaded data is sign-extended to 32-bits |
| 001       | LH        | 16        | loaded data is sign-extended to 32-bits |
| 010       | LW        | 32        | -                                       |
| 100       | LBU       | 8         | loaded data is zero extended to 32-bits |
| 101       | LHU       | 16        | loaded data is zero extended to 32-bits |

> [!NOTE]
> I'll be using MMIO for C0. This make all the memory and peripheral live on the same address space making all devices accessible by the load and store operation.
#### Store (S-type)
For store group, these instructions copy the last few bits (specify in store size column) from `rs2` to memory.<br>
The effective address of the target for these instructions use the same way of calculating as the load group, also giving it an ability to offset the address from `rs1` by ±2K addresses. The immediate field of S-type format mights be a bit wonky to look at, but it is the same as 12-bits field of I-type format, just placing differently.<br>

`opcode` for these instructions would be `0100011`.<br>
| `funct3`  | mnemonic  | store size (bits) |
|-----------|-----------|-------------------|
| 000       | SB        | 8                 |
| 001       | SH        | 16                |
| 010       | SW        | 32                |
### Jump
#### Branch / Conditional Jump (B-type)
This group of instructions will add specific number to the program counter of the processor to jump to new instruction address when a condition of instruction is met. Effectively, an if-else instruction.<br>
Number of offset that would be added to program counter is within the range of ±4KiB encoded in the 12-bits immediate field of B-type format. The reason for the 12-bits field to have a range of ±4KiB is that the immediate field will be left shift then sign-extended to 32-bits. This satisfied RISC-V's requirement for the offset to be multiples of 2.<br>

The `opcode` for this instruction group would be `1100011`.<br>
| `funct3`  | mnemonic  | description                                                           |
|-----------|-----------|-----------------------------------------------------------------------|
| 000       | BEQ       | branch if `rs1` and `rs2` are equal                                   |
| 001       | BNE       | branch if `rs1` and `rs2` are not equal                               |
| 100       | BLT       | branch if `rs1` is less than `rs2` (signed version)                   |
| 101       | BGE       | branch if `rs1` is greater than or equal to `rs2` (signed version)    |
| 110       | BLTU      | branch if `rs1` is less than `rs2` (unsigned version)                 |
| 111       | BGEU      | branch if `rs1` is greater than or equal to `rs2` (unsigned version)  |
#### Unconditional Jump
This type of jump will also add specific number to the program counter, to jump to specific instruction. But, this type of jump will always occur, there is no check if a condition is met. This is use for something like returning from a function.<br>
This group of instructions contains two instructions, both use difference `opcode` and instruction format. They are listed down below.
##### JAL (J-type)
This instruction use J-type instruction format. Like the B-type instruction format, 0 is also added to the end of the immediate value and signed-extended.<br>
This immediate value is use as an offset to jump to from current address by adding the offset to the program counter. The range for the offset is ±1MiB. This instruction also saves next instruction address (current + 4 bytes) to any register specify in `rd`, but following ABI specification this should be x1 or return address register, or you can use x0 which is constant zero register if you want to discard the address.<br>
`opcode` for `JAL` instruction is `1101111`.<br>
##### JALR (I-type)
`JALR` is I-type instruction format instead of J-type, and instead of using an offset to jump to specific instruction address, this instruction use fixed address obtain by adding the value from the immediate field that have been sign-extended to 32-bits to value from `rs1`, then the last bit's value will be set to 0 (not 0 added to the back). The program counter is then set to this value. The x1 register is also used by the instruction to save the next instruction address (current + 4 bytes), just like `JAL`.<br>
`opcode` for `JALR` instruction is `1100111`, and it uses I-type instruction format.
### Upper Immediate
This group contains two instructions just like Unconditional Jump group. Job of this group's instructions is to load upper 20-bits of immediate value to target register.<br>
This instruction group use U-type format, but there are two difference opcodes for each of the instruction.<br>
#### LUI
`LUI` loads first 20-bits then left shift those 20-bits into 32-bits into `rd`. When shifting, zero will be added to the right.<br>
The `opcode` for this instruction is `0110111`.<br>
#### AUIPC
`AUIPC` pretty much does what `LUI` does, but added the current value from program counter before loading into `rd`.<br>
This instruction use `0010111` as its `opcode`.<br>


# Microarchitecture
For this section, I'll be talking a little bit more about the hardware now. It's now, how will the CPU do it.<br>
As I said in the first section, I've cut out most modern processor design feature and technique. This also includes hardware stuff, like I/O, interrupts, cache, being in-order execution and superscalar design. This will result in 1 instruction per clock cycles (and it should stuck at 1 instruction per cycle) from no instruction level parallelism, but this is why there is 0 in C0.<br>

## Instruction Cycle
Instruction cycle are processes the CPU have to take to complete the execution of an instruction. In C0, there are 5 stages of instruction cycle. They follow classic RISC style instruction cycle, there are<br>
1. Fetch (IF)
    * The processor fetches an instruction from a memory, the address of an instruction is taken from processor's [Program Counter](#program-counter-pc).
2. Decode (ID)
    * The instruction is decoded by the CPU. This process tells the CPU what is the instruction wanted to do to which part of the processor. After decoding the instruction, the processor will receive `opcode` and `funct3/7`, this is then used to generate the signal for controlling the flow of the data throughout the cycles.
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
Datapath is an implementation of [Instruction Cycle](#instruction-cycle). The datapath is divided into 5 stages correspond for the stages specified in [Instruction Cycle](#instruction-cycle). As said before, the datapath is pipelined, meaning that, at every ending part of each stage (except the writeback stage) will have a set of registers to hold the data from that stage and forward those to the next at the edge of the next clock cycle, to give the capability of handling multiple stages at a time to the processor.<br>

![Entire datapath](./imgs/microarchitecture/entire_datapath.png)<br>
Image of entire datapath.<br>

### Fetch Stage (IF)
![Entire datapath of fetch Stage](./imgs/microarchitecture/fetch_stage.png)<br>
In this stage, [Program Counter](#program-counter-pc) (PC) do the job of remembering the current instruction address, that address is then used for accessing the instruction from the [Instruction Memory](#instruction-memory). The fetched instruction is then passed to [Instruction Register](#ifid-stage-registers) to be then decoded by the next stage.<br>

Every clock cycle, [Program Counter](#program-counter-pc) either go up by 4 bytes which is the next instruction (because one instruction is 32-bits or 4 bytes long), or could use the target address and jump signal coming from [Writeback Stage](#writeback-stage-wb) to jump to whole new address.<br>

The [Program Counter](#program-counter-pc)'s value is also pass to [Program Counter](#program-counter-pc) register, in case the processor need to compute a jump address with an offset to current address, or remembering the return address.<br>

### Decode Stage (ID)
![Entire datapath of decode Stage](./imgs/microarchitecture/decode_stage.png)<br>
This stage is all about preparing all the required data for processing in the further stages.<br>
The instruction inside the [Instruction Register](#ifid-stage-registers) is decoded by [Instruction Decoder](#instruction-decoder) into multiple part, which is then processed further to generate their usable form.<br>
The processed values are listed down below.<br>
1. 32-bits Immediate value
    - As specified in the instruction format, all format's `imm` field is not 32-bits long. The [Immediate Assembler](#immediate-assembler) took `imm` field value and the format of the instruction for calculating the 32-bits form of immediate value.
2. Source Register Data
    - The [Instruction Decoder](#instruction-decoder) extract the address of `rs1` and `rs2`, these addresses are then plugged into [Register File](#register-file) for retrieving the two's data.
3. `rd` Address
    - The [Instruction Decoder](#instruction-decoder) extract the address of `rd`, but instead of processing further, the processor pushes the address directly to the next stage. This will later be used by the [Writeback Stage](#writeback-stage-wb).
3. Operation Values
    - Operation Values are generated by [Operation Decoder](#operation-decoder). They're used for both controlling the behavior of their destination unit, this type is called Control Signal, or for further processing by their destination unit. Most are Control Signals, only `JmpOp` will be process further.<br>
    There are following Operation Values generated in this stage.
      1. `ALUOperand`
          - Signifies the [ALU](#arithmetic-and-logic-unit-alu)'s multiplexer to choose the correct data as operands for the [ALU](#arithmetic-and-logic-unit-alu).
      2. `ALUOp`
          - Signifies which operation [ALU](#arithmetic-and-logic-unit-alu) have to choose. This Control Signal also required `imm` field value for processing the [I-type arithmetic and logic instruction](#i-type).
      3. `JmpOp`
          - This value signifies the type of jump operation the instruction is trying to do. This is not a Control Signal, but it is for further processing inside [EX Stage](#execute-stage-ex).
      4. `MEMRead`
          - Signifies how many byte(s) the processor wanted to read from the [Data Memory](#data-memory) or any peripheral, and how to extend that value.
      5. `MEMWrite`
          - This is like `MEMRead`, but instead it signifies write operation.
      6. `rdSrc`
          - This signifies which data is chosen to write to the `rd`. (More information in [WB Stage](#writeback-stage-wb)).
      7. `rdWrite`
          - This signifies if the processor really wants to write to `rd`.

> [!NOTE]
> [Immediate Assembler](#immediate-assembler) handles the job of extending immediate value into full 32-bits. It is usually called Sign-Extend / Zero-Extend Unit, but [Immediate Assembler](#immediate-assembler) sounds a lot cooler to me.

After processing, all those values are pass to the next stage using registers.<br>

### Execute Stage (EX)
![Entire datapath of execute Stage](./imgs/microarchitecture/execute_stage.png)<br>
All the math and logic stuffs happen in this stage.<br>
The [ALU](#arithmetic-and-logic-unit-alu) computes all the math and logic related operations. The Control Signal which tell the [ALU](#arithmetic-and-logic-unit-alu) what to do, and what operands to choose are generated from [ID Stage](#decode-stage-id).<br>
If the operation is jump operation, no matter if it is conditional or unconditional, the [ALU](#arithmetic-and-logic-unit-alu)'s flags and `JmpOp` value are passed to a unit called [Jmp Handler](#jmp-handler). The [Jmp Handler](#jmp-handler) generates new Control Signal called `PCSrc`, which specify if the [PC](#program-counter-pc) should jump or not.<br>

> [!NOTE]
> Modern processor move the [Jmp Handler](#jmp-handler)'s functionality to [ID Stage](#decode-stage-id), which use dedicated comparator instead of [ALU](#arithmetic-and-logic-unit-alu)'s flags. This reduces the penalty of branch operation down to 1 cycle.

There is also an adder, which always add 4 to the [PC](#program-counter-pc), before passing to the next stage. This value is used for when the processor wanted to jump, but also wanted to remember the return address. This adder helps to achieve this functionality.<br>

This stage also ended with many registers to pass all sort of values to the next stage.<br>

### Memory Stage (MEM)
![Entire datapath of memory Stage](./imgs/microarchitecture/memory_stage.png)<br>
After address calculation done by the ALU, the processor put the 32-bits result into the [Address Decoder](#address-decoder) to find out the target device ([Data Memory](#data-memory) or any peripheral) then sent out the remaining 31-bits address, `rs2` data (write data) and the Control Signals (`MEMRead` and `MEMWrite`) to it correspond destination ([Data Memory](#data-memory) or [Peripheral Controller](#peripheral-controller) for any peripheral device).<br>

If the target device is peripheral then the [Peripheral Controller](#peripheral-controller) will decode the remaining 31-bits to pinpoint the exact target peripheral, before passing `rs2` data (write data) and the Control Signals (`MEMRead` and `MEMWrite`) to that peripheral just like what [Address Decoder](#address-decoder) does.<br>

The [Address Decoder](#address-decoder) also generates new Control Signal that controls the behavior of a mux that switches between data read from [Data Memory](#data-memory) and the [Peripheral Controller](#peripheral-controller), before passing the read data to the interstage register.<br>

Again, this stage passes some data to the next stage using multiple registers.<br>

### Writeback Stage (WB)
![Entire datapath of writeback Stage](./imgs/microarchitecture/writeback_stage.png)<br>
This stage return all the data from all the previous stages back to their correspond destination. The write back data are the following.<br>
1. [Program Counter](#program-counter-pc)'s jump address.
    - The [PC](#program-counter-pc) will have to either choose its value + 4 (the one calculated inside the [IF Stage](#fetch-stage-if)) or the jump address, which is just an [ALU](#arithmetic-and-logic-unit-alu)'s result (calculated inside [EX Stage](#execute-stage-ex)). The `PCSrc` signal from [EX Stage](#execute-stage-ex) that have been pass to this stage using register is used for choosing between the two.
2. `rd`'s write data.<br>
    - The processor use `rdSrc` Control Signal from [ID Stage](#decode-stage-id) to choose between next instruction address, [ALU](#arithmetic-and-logic-unit-alu)'s result or read data from the device as a data writing into `rd` with an address it got from [ID Stage](#decode-stage-id). There is also `rdWrite` Control Signal that tell whether if the processor really wanted to write the data or not.

> [!NOTE]
> The write back of `PCSrc` Control Signal could be moved to [EX Stage](#execute-stage-ex) after computing this Control Signal, this make the branch penalty goes down to 2 cycles, or even better, the [ID Stage](#decode-stage-id). But, 4 cycles branch penalty look "insane" to me, so WB stage here I come. Just thinks about that 4 instructions wasted.

# Hardware Design
This section covers each component inside the processor. This is difference from the [Microarchitecture](#microarchitecture) section in that, this section goes into inner working of each hardware unit that make the [Microarchitecture](#microarchitecture) possible, rather than how data flow through them.<br>

![Processor Diagram](./imgs/hardware_design/processor.png)<br>
Entire diagram of the processor.<br>

The order of each component is sorted by how early they are occurred in the instruction pipeline.<br>
> [!NOTE]
> Reset input of any component is active at falling edge, while clk input actives at rising edge.<br>
## Program Counter (PC)
![Program Counter Diagram](./imgs/hardware_design/program_counter.png)<br>
Program Counter keeps track of the current instruction address.<br>
Program Counter is a 32-bits register with input hook up to a multiplexer. This multiplexer chooses between 2 source inputs for it 1 output, the source of it output is either value of the Program Counter + 4 bytes (essentially the next instruction address, this is calculated locally inside the PC itself not by [+ 4 adder](#-4-adder)), or also the value of the Program Counter with difference processing like + offset. How the multiplexer choose is to use the `PCSrc` Control Signal for controlling the source of the output, which is generated from the [Jmp Handler](#jmp-handler) inside the [Execution Unit](#execution-unit-eu).<br>
There is also a reset input connect to the register. When this input goes low (falling edge), the register's value will be set back to 0.<br>

## Instruction Memory
Instruction Memory holds all the instructions that the processor will use for processing. The processor uses 32-bits address from the [PC](#program-counter-pc) to fetches an instruction from that specific address.<br>
In the diagram of the processor, I've designed the Instruction Memory to be a Read-Only Memory. This also means that it doesn't require clock signal, because there is no write operation. Which is why in the diagram, the Instruction Memory may look a bit weird to have no clock input.<br>

C0's memory is similar to Harvard Architecture's memory, meaning that instruction and data lives in difference memory space. This is because of [structural hazard](#structural-hazards), when [IF Stage](#fetch-stage-if) and [MEM Stage](#memory-stage-mem) is clashing to access from the same memory.<br>

## IF/ID Interstage Registers
![IF/ID Interstage Registers Diagram](./imgs/hardware_design/if-id_interstage_registers.png)<br>
Just like in the pipeline diagram, there are two registers for this interstage, both are 32-bits long. They're the following.<br>
1. Instruction Register
    - Instruction Register temporary holds an instruction from the [Instruction Memory](#instruction-memory), after it has been fetched.<br>
2. Current Address Register
    - This register only hold the value of the current instruction address, it's for further processing in the [EX Stage](#execute-stage-ex) of the pipeline, or by the [EU](#execution-unit-eu).<br>

There is also a reset input connect to both registers, which does the same thing as [PC](#program-counter-pc)'s.<br>

## Control Unit (CU)
![Control Unit Diagram](./imgs/hardware_design/control_unit.png)<br>
Control Unit is a stateless combinational logic that controls the flow of the data by sending multiple Control Signals to multiple part of the processor.<br>
Being a stateless combinational logic means that the CU updates its Control Signals instantly after receiving new input values, which is an instruction from the [Instruction Register](#ifid-stage-registers).<br>

> [!NOTE]
> Combinational logic means that the logic doesn't hold any value (no memory), making the output of this logic update instantly when the input changes.

CU has several outputs which are the following.<br>
1. `imm` Field Value
2. Instruction Format
3. `rs1` Address
4. `rs2` Address
5. `ALUOperand` Control Signal
6. `ALUOp` Control Signal
7. `JmpOp` Value
8. `MEMRead` Control Signal
9. `MEMWrite` Control Signal
10. `rdSrc` Control Signal
11. `rd` Address
12. `rdWrite` Control Signal

There will be a description on each output in the following 2 sections.<br>
### Instruction Decoder
Instruction Decoder took the instruction currently holds inside the [Instruction Register](#ifid-stage-registers), and separate that instruction into multiple parts according to the [format](#instruction-formats) of the instruction. But, the output of Instruction Decoder are.<br>
1. `imm` Field value
    - This is an incomplete form of immediate value that have been directly extract from the instruction.
    - Length of this output can range from 12-bits to 20-bits.
    - If the `imm` value from the instruction is shorter than 20-bits then it will be zero-extended into 20-bits.
2. Instruction Format
    - Instruction Decoder identifies the [format](#instruction-formats) of current instruction, this will later be used by the [Immediate Assembler](#immediate-assembler) with the raw `imm` value.
    - The [format](#instruction-formats) can be identifies by looking at the `opcode` field because one `opcode` hook to one specific [format](#instruction-formats).
    - This output is 3-bits long, with the following possible values.<br>
    `000` for R-type instruction.<br>
    `001` for I-type instruction.<br>
    `010` for S-type instruction.<br>
    `011` for B-type instruction.<br>
    `100` for U-type instruction.<br>
    `101` for J-type instruction.<br>
3. `rs1` Address
    - This is just the address of the first source register.
    - Length of this output is only 5-bits.
4. `rs2` Address
    - Similar to `rs1`'s, but this is for the second source register.
5. `rd` Address
    - Similar to two previous output, but this time it is for the destination register.
6. `opcode` Field value
    - This is for specifying the group of operation the instruction is trying to do. This value with `funct3/7` and `imm` will be used by [Operation Decoder](#operation-decoder) to then generate many Control Signals specific to the operation.
    - This output is 7-bits long.
7. `funct3` Field value
    - This is for pinpointing the operation.
    - This output is 3-bits long.
8. `funct7` Field value
    - Like `funct3`, but for pinpointing even further.
    - This output is 7-bits long.
### Operation Decoder
This unit generates all sort values from `opcode`, `funct3/7` and `imm`. It took those values decoded by the [Instruction Decoder](#instruction-decoder) to generates values, most are Control Signals.<br>
All the operation values generated by Operation Decoder are the following.<br>
1. `ALUOperand`
    - This is a 2-bits Control Signal is for controlling which data is the operand for the [ALU](#arithmetic-and-logic-unit-alu) by [Operand Multiplexers](#operand-multiplexer).<br>
    The first operand (`rs1`/[`PC`](#program-counter-pc)) mux uses the LSB of the Control Signal, while the other mux (`rs2`/`imm`) uses MSB.
    - If the bit value is `0`, this would mean it will use `rs1` or `rs2` as the operand depending on the input of the mux, while `1` is for the other input of the mux, which is current address or extended immediate.
2. `ALUOp`
    - This is a 5-bits Control Signal for controlling the operation performed by the [ALU](#arithmetic-and-logic-unit-alu).
    - The first bit (MSB) is for letting the processor knows if the operation is normal math/logic or for branch operation. (0 = math/logic, 1 = branch)
    - The second bit from the MSB is for specifying the alternative `funct7` form of math/logic operation.
    - The last three bits of the Control Signals are taken directly from the `funct3` field of both math/logic and branch operation. This also means the processor use the second LSB bit for identifying unsigned comparison form of the branch operation.
    - The possible values are.<br>
    `00000` for `ADD` operation.<br>
    `01000` for `SUB` operation.<br>
    `00001` for `SLL` operation.<br>
    `00010` for `SLT` operation.<br>
    `00011` for `SLTU` operation.<br>
    `00100` for `XOR` operation.<br>
    `00101` for `SRL` operation.<br>
    `01101` for `SRA` operation.<br>
    `00110` for `OR` operation.<br>
    `00111` for `AND` operation.<br>
    `10000` for `EQ` operation.<br>
    `10001` for `NEQ` operation.<br>
    `10100` for `LT` operation.<br>
    `10101` for `GE` operation.<br>
    `10110` for `LTU` operation.<br>
    `10111` for `GEU` operation.<br>
3. `JmpOp`
    - This 2-bits value signifies the type of jump operation the instruction is trying to do. This is not a Control Signal, but it will be further process into a Control Signal by the [Jmp Handler](#jmp-handler).
    - The possible values are.<br>
    `00` for not a jump operation.<br>
    `01` for conditional jump (branch) operation.<br>
    `10` for `jal` operation.<br>
    `11` for `jalr` operation.<br>
4. `MEMRead`
    - This 3-bit Control Signal signifies if the processor wanted to read from the [Data Memory](#data-memory) or any peripheral.
    - The possible values and the meaning of each value is the same as `funct3` and its operations, which are already specified in the [Load Instruction Group](#load-i-type) section, but there is an addition of `111` value which means this instruction is not a read operation.
    - The processor can use the first bit for identifying if the read value should be zero or signed extended.
    - The possible values are the following.<br>
    `000` for read 1 byte operation and zero-extended to 32-bits.<br>
    `001` for read 2 bytes operation and zero-extended to 32-bits.<br>
    `010` for read 4 bytes operation.<br>
    `100` for read 1 byte operation and signed-extended to 32-bits.<br>
    `101` for read 2 bytes operation and signed-extended to 32-bits.<br>
    `111` for not a read operation.<br>
5. `MEMWrite`
    - This 2-bit Control Signal is like `MEMRead`, but instead it signifies write operation. The possible value and its operations are also the same as `funct3` and its operations specified in [Store Instruction Group](#store-s-type), and also an addition of `111` which means not a write operation the same as `MEMRead`.
    - The possible values are the following.<br>
    `000` for write 1 byte operation.<br>
    `001` for write 2 bytes operation.<br>
    `010` for write 4 bytes operation.<br>
    `111` for not a write operation.<br>
6. `rdSrc`
    - This 2-bits Control Signal chooses between 3 sources of the data written into `rd`.
    - The possible values are.<br>
    `00` for [ALU](#arithmetic-and-logic-unit-alu)'s result.<br>
    `01` for next instruction address from [+ 4 Adder](#-4-adder).<br>
    `10` for Device Read Data from [Device Data Read Multiplexer](#device-data-read-multiplexer).<br>
7. `rdWrite`: This signifies if the processor really wants to write to `rd`.
    - The purpose of this 1-bit Control Signal is to choose if the processor wants to write to the `rd`.
    - `1` for it did want to write, while `0` means it did not.

## Immediate Assembler
Immediate Assembler took raw `imm` data and [Instruction Format Type](#instruction-formats) from the [Instruction Decoder](#instruction-decoder), and assemble the immediate value into its usable 32-bits length form.<br>
For reference, there is a table for visualizing how the `imm` is extended in [Immediate Field](#immediate-field) section.

## Register File
![Register File Diagram](./imgs/hardware_design/register_file.png)<br>
Register File is where all 32 registers of this processor live.<br>
There are a total of 5 inputs for Register File (not counting reset data and clock line), each is either for writing data into one specific register, or it is for reading two specific registers.<br>

For reading data from two registers, there are two specific 5-bits inputs, both are for selecting the source register. The design of this Register File support reading from 2 registers simultaneously.<br>

For writing data into the Register File, there are 1-bit input for enabling the write mode (Write Enable), another 5-bits input for selecting the destination register (Write Address), and the other is the 32-bits data that would be writing into a register (Write Data). The Write Address is plugged into a mux for selecting the destination for Write Enable input, but the Write Data input is directly connect to all registers (except x0).<br>
x0 register or constant zero register doesn't have any input plug to it (except reset input), making it impossible to write to this register.<br>
When writing to any registers (except x0), two condition must be met. First, the Write Enable of target register must be high. Second, the clock must be at the edge of the trigger, which would be low to high in this design.<br>

Just like other 2 sequential unit, there is also a reset input that does the same thing.<br>

> [!NOTE]
> Sequential logic means that the logic did hold some form of value, or it did have a memory. This makes this type of logic require a clock source so that it could sync up with other sequential logic. This also make the logic have to wait for the next clock edge to update its output.

## ID/EX Interstage Registers
![ID/EX Interstage Registers Diagram](./imgs/hardware_design/id-ex_interstage_registers.png)<br>
This interstage contains 12 registers. From this point on, if there are no description for specific registers that would mean the description of the value holds inside that register has been described in other section before.<br>
1. [Extended `imm` Register](#immediate-assembler)
2. `rs2` Data Register
    - This register holds the value of `rs2`'s data, which have been read from the [Register File](#register-file) using Read Address 2 input, this register is 32-bits long.
3. [Current Address Register](#ifid-interstage-registers)
4. `rs1` Data Register
    - This stage register is the same as `rs2`'s, but holds the data of `rs1` instead.
5. [`ALUOperand` Control Signal Register](#operation-decoder)
6. [`ALUOp` Control Signal Register](#operation-decoder)
7. [`JmpOp` Register](#operation-decoder)
8. [`MEMRead` Control Signal Register](#operation-decoder)
9. [`MEMWrite` Control Signal Register](#operation-decoder)
10. [`rdSrc` Control Signal Register](#operation-decoder)
11. [`rd` Address Register](#instruction-decoder)
12. [`rdWrite` Control Signal Register](#operation-decoder)

This also have a reset input to reset all register's values back to zero.<br>

## Execution Unit (EU)
![Execution Unit Diagram](./imgs/hardware_design/execution_unit.png)<br>
What it does is pure math and logic.<br>
Execution Unit packs multiple components for handling the [EX Stage](#execute-stage-ex) of the pipeline into one component.<br>

There are 7 inputs and only 3 outputs for EU, the description for each will be in their correspond unit below.<br>
### Operand Multiplexer
There are two Operand Multiplexers, each is for selecting the operand for the [ALU](#arithmetic-and-logic-unit-alu) between two source (between `PC` and `rs1`, `imm` and `rs2`). The [Operation Decoder](#operation-decoder) generates the signal for controlling these multiplexers. This Control Signal is called [`ALUOperand`](#operation-decoder). Each of the mux use a difference bit of the Control Signal. The first operand use LSB bit, while the second use MSB bit of the Control Signal.
### Arithmetic and Logic Unit (ALU)
Arithmetic and Logic Unit handles most of the math and logic operation. The only math it doesn't handle are calculating the next instruction address, and for the [PC](#program-counter-pc) to jump or not, that would be the job of a [+ 4 Adder](#-4-adder) and [Jmp Handler](#jmp-handler) respectively.<br>
The ALU use Control Signal from the [Control Unit](#control-unit-cu) to select it operation, this Control Signal is called [`ALUOp`](#operation-decoder). The operands for calculation will be selected by two [Operand Multiplexer](#operand-multiplexer). And, the result of the calculation is, of course, 32-bits.<br>
### Jmp Handler
This unit handle the jump operation. It took [`JmpOp`](#operation-decoder) from the [CU](#control-unit-cu), and added [ALU](#arithmetic-and-logic-unit-alu)'s branching flag to it. Essentially, a 2-bits adder. Now, the result of the adder will be 3-bits (this includes carry out).<br>
Now, the possible output of the operation is either the following<br>
1. `00x` if the jump is unsuccessful.
2. `01x` if the jump is successful, the new address would be the full 32-bits result from the [ALU](#arithmetic-and-logic-unit-alu).
3. `10x` if the jump is successful, but the operation is `jalr`, so the new address is the first 31-bits from the [ALU](#arithmetic-and-logic-unit-alu) that have been zero extended at the back to 32-bits.<br>

The Jmp Handler then took the first 2 MSB bits from the result and name it `PCSrc` Control Signal.<br>
### + 4 Adder
All this adder do is took the value from [PC](#program-counter-pc), and you guess it, add four to it.<br>
This is specifically for handling jump instruction that needs to remember the return address (next instruction address from the current one), this is because the [ALU](#arithmetic-and-logic-unit-alu) will be occupied by jump address calculation. So, there is this small adder for calculating the next instruction address.<br>
The result will be 32-bits long.<br>

## EX/MEM Interstage Registers
![EX/MEM Interstage Registers Diagram](./imgs/hardware_design/ex-mem_interstage_registers.png)<br>
In this interstage, there will be 9 registers, mostly still Control Signal registers.<br>
1. [`PCSrc` Control Signal Register](#jmp-handler)
2. [ALU Result Register](#arithmetic-and-logic-unit-alu)
3. [Next Address Register](#-4-adder)
4. [`rs2` Data Register](#idex-interstage-registers)
5. [`MEMRead` Control Signal Register](#idex-interstage-registers)
6. [`MEMWrite` Control Signal Register](#idex-interstage-registers)
7. [`rdSrc` Control Signal Register](#idex-interstage-registers)
8. [`rd` Address Register](#idex-interstage-registers)
9. [`rdWrite` Control Signal Register](#idex-interstage-registers)

Again, this will also have a reset input for resetting the register's values to zero.

## Address Decoder
![Address Decoder Diagram](./imgs/hardware_design/address_decoder.png)<br>
Address Decoder identify if the address is for [Data Memory](#data-memory) or for any peripheral device. After identifying the target, it then redirects the remaining address bits, write data and Control Signals into either the [Data Memory](#data-memory) or [Peripheral Controller](#peripheral-controller) for peripheral device.<br>

The Address Decoder identifies the type of target device by simply looking at the bit(s) inside the address that is for identifying the type of target device. Which for this case, I will use only the MSB bit, which is `0` for [Data Memory](#data-memory), and `1` for any peripheral device.<br>

Address Decoder also generates a 1-bit Control Signal called `DeviceDataSrc`. That will be used by the [Device Data Read Multiplexer](#device-data-read-multiplexer).<br>
This Control Signal is linked directly to the MSB bit of the original 32-bits address, meaning that if it is a `0` it will choose data from [Data Memory](#data-memory), while `1` if data from [Peripheral Controller](#peripheral-controller).<br>

## Data Memory
As said before in the [Instruction Memory](#instruction-memory) section, the Data Memory is separate from the [Instruction Memory](#instruction-memory). The processor use the remainings 31-bits address, `rs2` data (write data) and Control Signals that have been redirected from [Address Decoder](#address-decoder) for interaction with the Data Memory. This also make the largest possible memory capacity to be around 2GB (2GB for processor this bad? Damn).<br>

If both Control Signals are somehow trying to read and write at the same times, the default behavior of the Data Memory should be to not go into either read or write mode.<br>

Data Memory also have a reset input for resetting the entire memory.<br>

## Peripheral Controller
Peripheral Controller decodes the remaining 31-bits address even further to identifies the exact target peripheral, and redirect the 3 remaining data (`rs2` data, `MEMRead` and `MEMWrite` Control Signals) into that peripheral. Essentially it is the [Address Decoder](#address-decoder) for the peripherals.

For Control Signals behavior, the Peripheral Controller behaves the same ways as the [Data Memory](#data-memory).<br>

This also have a reset input.<br>

## Device Data Read Multiplexer
This multiplexer handles choosing between data from [Data Memory](#data-memory) and [Peripheral Controller](#peripheral-controller) by using the [`DeviceDataSrc` Control Signal](#address-decoder) generated by the [Address Decoder](#address-decoder).<br>
If [`DeviceDataSrc`](#address-decoder) is a `1` then it will forward the data from [Peripheral Controller](#peripheral-controller), or else it would choose [Data Memory](#data-memory).

## MEM/WB Interstage Registers
![MEM/WB Interstage Registers Diagram](./imgs/hardware_design/mem-wb_interstage_registers.png)<br>
This interstage have 7 registers, half are not Control Signal now. They are the following.<br>
1. [`PCSrc` Control Signal Register](#exmem-interstage-registers)
2. [ALU Result Register](#exmem-interstage-registers)
3. [Next Address Register](#exmem-interstage-registers)
4. [Device Read Data Register](#device-data-read-multiplexer)
5. [`rdSrc` Control Signal Register](#idex-interstage-registers)
6. [`rd` Address Register](#idex-interstage-registers)
7. [`rdWrite` Control Signal Register](#idex-interstage-registers)

This also have a reset input for resetting all register's values back to 0.<br>

## Destination Register Multiplexer
This one is a simple 3 inputs multiplexer, it's for choosing between [ALU](#arithmetic-and-logic-unit-alu)'s result, [+ 4 Adder](#-4-adder)'s result, or read data that have been given by [Device Data Read Multiplexer](#device-data-read-multiplexer).<br>
This multiplexer is controlled by a 2-bits Control Signal called [`rdSrc`](#operation-decoder).<br>