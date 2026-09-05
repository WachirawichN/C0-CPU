package OtherSignals_pkg;
    typedef enum logic [2:0] {
        R_TYPE,
        I_TYPE,
        S_TYPE,
        B_TYPE,
        U_TYPE,
        J_TYPE
    } InstructionFormat;
    typedef enum logic [1:0] {
        NO_JUMP,
        BRANCH,
        JAL,
        JALR
    } JmpOp;
endpackage