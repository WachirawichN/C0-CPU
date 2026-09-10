package OtherSignals_pkg;
    typedef enum logic [2:0] {
        R_TYPE,
        I_TYPE,
        S_TYPE,
        B_TYPE,
        U_TYPE,
        J_TYPE
    } InstructionFormat;
    typedef enum logic [2:0] {
        NO_JUMP = 3'b000,
        BRANCH  = 3'b001,
        JAL     = 3'b010,
        JALR    = 3'b100
    } JmpOp;
endpackage