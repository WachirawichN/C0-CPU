package operation_pkg;
    // Zero will be reserve for none for all type of operation.
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
    typedef enum logic [3:0] {
        LSU_NONE,
        LSU_LB,
        LSU_LH,
        LSU_LW,
        LSU_LBU,
        LSU_LHU,
        LSU_SB,
        LSU_SH,
        LSU_SW
    } LsuOperation_e;
endpackage : operation_pkg