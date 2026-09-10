package ControlSignals_pkg;
    typedef enum logic [3:0] {
        // Arithmetic/Logic
        // MSB bit signified if the operation is the funct7/special imm variant of the funct3 operation.
        // The last three bits signified the operation.
        ADD     = 4'b0000,
        SUB     = 4'b1000,
        SLL     = 4'b0001,
        SLT     = 4'b0010,
        SLTU    = 4'b0011,
        XOR     = 4'b0100,
        SRL     = 4'b0101,
        SRA     = 4'b1101,
        OR      = 4'b0110,
        AND     = 4'b0111,
    } ALUOp;
    typedef enum logic [2:0] {
        EQ  = 3'b000,
        NE  = 3'b001,
        LT  = 3'b100,
        GE  = 3'b101,
        LTU = 3'b110,
        GEU = 3'b111
    } ComOp;
    typedef enum logic [2:0] {
        // First bit or the MSB signify if the read is will be signed or unsigned extended
        MEM_READ_1_U_BYTE   = 3'b000,
        MEM_READ_2_U_BYTES  = 3'b001,
        MEM_READ_4_BYTES    = 3'b010,
        MEM_READ_1_BYTE     = 3'b100,
        MEM_READ_2_BYTES    = 3'b101,
        NO_MEM_READ         = 3'b111
    } MEMRead;
    typedef enum logic [1:0] {
        MEM_WRITE_1_BYTE,
        MEM_WRITE_2_BYTES,
        MEM_WRITE_4_BYTES,
        NO_MEM_WRITE
    } MEMWrite;
    typedef enum logic [1:0] {
        RDSRC_ALU_RESULT,
        RDSRC_NEXT_ADDRESS,
        RDSRC_DEVICE_READ_DATA
    } rdSrc;
    typedef enum logic {
        NO_RD_WRITE,
        RD_WRITE
    } rdWrite;

    typedef enum logic[1:0] {
        PCSRC_NEXT_ADDRESS,
        PCSRC_JUMP_ADDRESS,
        PCSRC_JUMP_JALR_ADDRESS
    } PCSrc;

    typedef enum logic {
        DATA_MEM,
        PERIPHERAL
    } DeviceDataSrc;
endpackage