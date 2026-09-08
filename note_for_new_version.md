This note is for making the next CPU, it could be optimization or any idea.
1. ALU Optimization
    - The ALUOp Control Signal could cut all branch operation to instead use pure math operation. There would have to be a change to JmpHandler for interpreter the ALU's result, maybe adding additional bit to JmpOp Control Signal for signifying the branch operation condition could be one of the way.