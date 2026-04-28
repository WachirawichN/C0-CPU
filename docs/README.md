# Architecture
C1's architecture is based on RISC-V ISA, specifically rv32i with no extensions or custom instructions.<br>
You can find more informations about rv32i on [RISC-V's rectified specification](https://riscv.atlassian.net/wiki/spaces/HOME/pages/16154769/RISC-V+Technical+Specifications)(Unprivileged Architecture) or [green card](https://www.cs.sfu.ca/~ashriram/Courses/CS295/assets/notebooks/RISCV/RISCV_CARD.pdf) widely available on the internet.<br>
But tl;dr, this architecture contains 32 total registers (+1 program counter and only the second to final registers are general purpose) and 40 instructions that can be use to program fully functions OS.

# Programming