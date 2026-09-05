package ControlSignals_pkg;
    typedef enum logic [4:0] {
        // First bit = Separation Arithmetic/Logic and Branch function

        // Arithmetic/Logic
        // Second MSB bit signified if the operation is the funct7 variant of the funct3 operation.
        // The last three bits signified the operation.
        ADD     = 5'b00000,
        SUB     = 5'b01000,
        SLL     = 5'b00001,
        SLT     = 5'b00010,
        SLTU    = 5'b00011,
        XOR     = 5'b00100,
        SRL     = 5'b00101,
        SRA     = 5'b01101,
        OR      = 5'b00110,
        AND     = 5'b00111,

        // Branch
        // The last three bits are the funct3.
        // The second LSB bit signified the unsigned variant of the operation.
        // The first and third LSB bits signified the operation.
        EQ      = 5'b10000,
        NEQ     = 5'b10001,
        LT      = 5'b10100,
        GE      = 5'b10101,
        LTU     = 5'b10110,
        GEU     = 5'b10111
    } ALUOp;
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