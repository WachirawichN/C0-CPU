package alu_operation_pkg;
    // Zero will be reserve for none.
    typedef enum logic [3:0] {
        ALU_NONE,
        ALU_ADD,
        ALU_SUB,
        ALU_SLL,
        ALU_SLT,
        ALU_SLTU,
        ALU_XOR,
        ALU_SRL,
        ALU_SRA,
        ALU_OR,
        ALU_AND
    } AluOperation_e;
endpackage : alu_operation_pkg