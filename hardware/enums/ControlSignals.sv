package ControlSignals_pkg
    typedef enum logic [3:0] {
        ADD,
        SUB,
        SLL,
        SLT,
        SLTU,
        XOR,
        SRL,
        SRA,
        OR,
        AND,
        EQ,
        NEQ,
        LT,
        GE,
        LTU,
        GEU
    } ALUOp;
    typedef enum logic {
        NO_READ,
        READ,
    } MEMRead;
    typedef enum logic {
        NO_WRITE,
        WRITE,
    } MEMWrite;
    typedef enum logic [1:0] {
        ALU_RESULT,
        NEXT_ADDRESS,
        DEVICE_READ_DATA,
    } rdSrc;
    typedef enum logic {
        NO_WRITE,
        WRITE,
    } rdWrite;

    typedef enum logic {
        NEXT_ADDRESS,
        JUMP_ADDRESS
    } PCSrc;

    typedef enum logic {
        DATA_MEM,
        PERIPHERAL
    } DeviceDataSrc;
endpackage