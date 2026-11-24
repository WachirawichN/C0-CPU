`timescale 1ns/1ps

module Top
    import ControlSignals_pkg::*;
    import OtherSignals_pkg::*;
    import Types_pkg::*;
#(
    localparam int      INSTRUCTION_MEM_ADDRESS_WIDTH   = 18,               // 2**18 (~256K) x 1 = 256KiB Byte addressable instruction memory
    localparam string   PROGRAM_NAME                    = "calculator.mem",
    
    localparam int      DATA_MEM_ADDRESS_WIDTH          = 18,               // 2**15 (~256K) x 1 = 256KiB Byte addressable data memory

    localparam int      BUTTON_ROWS                     = 5,
    localparam int      BUTTON_COLS                     = 4
) (
    input logic clk,
    input logic rst_n, // Reset button

    // LCD connection
    output logic [7:0] lcd_write_data,
    output logic lcd_rs,
    output logic lcd_e,

    // Buttons connection (Exclude reset button)
    input logic button_col_in [0:BUTTON_COLS-1],
    output logic button_row_out [0:BUTTON_ROWS-1],

    output logic [3:0] debug_led
);
    // Debugging stuff
    assign debug_led[0] = !rst_n;
    logic [2:0] clk_counter = 0;
    always_ff @(posedge clk) begin
        clk_counter <= clk_counter + 1;
        debug_led[3:1] <= ~clk_counter;
    end

    // ===================
    // Nets
    // ===================
    // Fetch
    Word address;
    Word selected_address;
    Word inst;

    // Decode
    Word                inst_if_id_reg;

    logic [19:0]        raw_imm;
    InstFormat          inst_format;
    RegAddr             rs1_addr;
    RegAddr             rs2_addr;
    RegAddr             rd_addr;

    logic [1:0]         alu_operand;
    ALUOp               alu_op;
    ComOp               com_op;
    JmpOp               jmp_op;
    ReadOp              read_op;
    WriteOp             write_op;
    rdSrc               rd_src;
    rdWrite             rd_write;

    Word                extended_imm;
    Word                rs1_data;
    Word                rs2_data;

    Word                address_if_id_reg;

    // Execute
    Word        extended_imm_id_ex_reg;
    Word        rs2_data_id_ex_reg;
    Word        address_id_ex_reg;
    Word        rs1_data_id_ex_reg;
    logic [1:0] alu_operand_id_ex_reg;
    ALUOp       alu_op_id_ex_reg;
    ComOp       com_op_id_ex_reg;
    JmpOp       jmp_op_id_ex_reg;

    PCSrc       pc_src;
    Word        alu_result;
    Word        next_address;

    ReadOp      read_op_id_ex_reg;
    WriteOp     write_op_id_ex_reg;
    rdSrc       rd_src_id_ex_reg;
    RegAddr     rd_addr_id_ex_reg;
    rdWrite     rd_write_id_ex_reg;

    // Memory
    Word            alu_result_ex_mem_reg;
    Word            rs2_data_ex_mem_reg;
    ReadOp          read_op_ex_mem_reg;
    WriteOp         write_op_ex_mem_reg;

    Word            data_mem_read_data;
    Word            lcd_read_data;
    Word            button_read_data;
    ReadOp          validated_read_op;
    DeviceDataSrc   device_data_src;

    PCSrc           pc_src_ex_mem_reg;
    Word            next_address_ex_mem_reg;
    rdSrc           rd_src_ex_mem_reg;
    RegAddr         rd_addr_ex_mem_reg;
    rdWrite         rd_write_ex_mem_reg;

    // Write Back
    Word            data_mem_read_data_mem_wb_reg;
    Word            lcd_read_data_mem_wb_reg;
    Word            button_read_data_mem_wb_reg;
    DeviceDataSrc   device_data_src_mem_wb_reg;

    Word            device_data;
    ReadOp          validated_read_op_mem_wb_reg;

    Word            extended_device_data;
    Word            alu_result_mem_wb_reg;
    Word            next_address_mem_wb_reg;
    rdSrc           rd_src_mem_wb_reg;

    Word            rd_write_data;

    PCSrc           pc_src_mem_wb_reg;
    RegAddr         rd_addr_mem_wb_reg;
    rdWrite         rd_write_mem_wb_reg;

    // ===================
    // Fetch Stage
    // ===================
    ProgramCounter program_counter (
        .clk(clk),
        .rst_n(rst_n),

        .pc_src(pc_src_mem_wb_reg),
        .alu_result(alu_result_mem_wb_reg),

        .address(address),
        .selected_address(selected_address)
    );
    InstructionMemoryController #(
        .ADDRESS_WIDTH(INSTRUCTION_MEM_ADDRESS_WIDTH),
        .PROGRAM_NAME(PROGRAM_NAME)
    ) instruction_memory_controller (
        .clk(clk),
        .selected_address(selected_address),
        .instruction(inst)
    );

    // ===================
    // Decode Stage
    // ===================
    ControlUnit control_unit (
        .instruction(inst_if_id_reg),

        .raw_imm(raw_imm),
        .inst_format(inst_format),
        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),
        .rd_addr(rd_addr),

        .alu_operand(alu_operand),
        .alu_op(alu_op),
        .com_op(com_op),
        .jmp_op(jmp_op),
        .read_op(read_op),
        .write_op(write_op),
        .rd_src(rd_src),
        .rd_write(rd_write)
    );
    ImmediateAssembler immediate_assembler (
        .raw_imm(raw_imm),
        .inst_format(inst_format),
        .extended_imm(extended_imm)
    );
    RegisterFile register_file (
        .clk(clk),
        .rst_n(rst_n),

        .rs1_addr(rs1_addr),
        .rs2_addr(rs2_addr),

        .rd_addr(rd_addr_mem_wb_reg),
        .rd_write(rd_write_mem_wb_reg),
        .rd_write_data(rd_write_data),

        .rs1_data(rs1_data),
        .rs2_data(rs2_data)
    );

    // ===================
    // Execute Stage
    // ===================
    ExecutionUnit execution_unit (
        .extended_imm(extended_imm_id_ex_reg),
        .rs2_data(rs2_data_id_ex_reg),
        .address(address_id_ex_reg),
        .rs1_data(rs1_data_id_ex_reg),

        .alu_operand(alu_operand_id_ex_reg),
        .alu_op(alu_op_id_ex_reg),
        .com_op(com_op_id_ex_reg),
        .jmp_op(jmp_op_id_ex_reg),

        .pc_src(pc_src),
        .alu_result(alu_result),
        .next_address(next_address)
    );

    // ===================
    // Memory Stage
    // ===================
    SystemBus #(
        .DATA_MEM_ADDRESS_WIDTH(DATA_MEM_ADDRESS_WIDTH),
        .BUTTON_ROWS(BUTTON_ROWS),
        .BUTTON_COLS(BUTTON_COLS)
    ) system_bus (
        .clk(clk),
        .rst_n(rst_n),

        .alu_result(alu_result_ex_mem_reg),
        .rs2_data(rs2_data_ex_mem_reg),
        .read_op(read_op_ex_mem_reg),
        .write_op(write_op_ex_mem_reg),

        .data_mem_read_data(data_mem_read_data),
        .lcd_read_data(lcd_read_data),
        .button_read_data(button_read_data),

        .validated_read_op(validated_read_op),
        .device_data_src(device_data_src),

        .lcd_write_data(lcd_write_data),
        .lcd_rs(lcd_rs),
        .lcd_e(lcd_e),

        .col_in(button_col_in),
        .row_out(button_row_out)
    );

    // ===================
    // Write Back Stage
    // ===================
    DeviceDataMux device_data_mux (
        .data_mem_read_data(data_mem_read_data_mem_wb_reg),
        .lcd_read_data(lcd_read_data_mem_wb_reg),
        .button_read_data(button_read_data_mem_wb_reg),
        .device_data_src(device_data_src_mem_wb_reg),

        .device_data(device_data)
    );
    BitExtender bit_extender (
        .device_data(device_data),
        .validated_read_op(validated_read_op_mem_wb_reg),

        .extended_device_data(extended_device_data)
    );
    RegisterFileMux register_file_mux (
        .alu_result(alu_result_mem_wb_reg),
        .next_address(next_address_mem_wb_reg),
        .extended_device_data(extended_device_data),
        .rd_src(rd_src_mem_wb_reg),

        .rd_write_data(rd_write_data)
    );

    // ===================
    // Interstage Registers
    // ===================
    IFIDReg if_id_reg (
        .instruction(inst),
        .address(address),
        .instruction_register(inst_if_id_reg),
        .address_register(address_if_id_reg)
    );
    IDEXReg id_ex_reg (
        .clk(clk),
        .rst_n(rst_n),

        .extended_imm(extended_imm),
        .rs2_data(rs2_data),
        .address(address_if_id_reg),
        .rs1_data(rs1_data),
        .alu_operand(alu_operand),
        .alu_op(alu_op),
        .com_op(com_op),
        .jmp_op(jmp_op),
        .read_op(read_op),
        .write_op(write_op),
        .rd_src(rd_src),
        .rd_addr(rd_addr),
        .rd_write(rd_write),

        .extended_imm_register(extended_imm_id_ex_reg),
        .rs2_data_register(rs2_data_id_ex_reg),
        .address_register(address_id_ex_reg),
        .rs1_data_register(rs1_data_id_ex_reg),
        .alu_operand_register(alu_operand_id_ex_reg),
        .alu_op_register(alu_op_id_ex_reg),
        .com_op_register(com_op_id_ex_reg),
        .jmp_op_register(jmp_op_id_ex_reg),
        .read_op_register(read_op_id_ex_reg),
        .write_op_register(write_op_id_ex_reg),
        .rd_src_register(rd_src_id_ex_reg),
        .rd_addr_register(rd_addr_id_ex_reg),
        .rd_write_register(rd_write_id_ex_reg)
    );
    EXMEMReg ex_mem_reg (
        .clk(clk),
        .rst_n(rst_n),

        .pc_src(pc_src),
        .alu_result(alu_result),
        .next_address(next_address),
        .rs2_data(rs2_data_id_ex_reg),
        .read_op(read_op_id_ex_reg),
        .write_op(write_op_id_ex_reg),
        .rd_src(rd_src_id_ex_reg),
        .rd_addr(rd_addr_id_ex_reg),
        .rd_write(rd_write_id_ex_reg),

        .pc_src_register(pc_src_ex_mem_reg),
        .alu_result_register(alu_result_ex_mem_reg),
        .next_address_register(next_address_ex_mem_reg),
        .rs2_data_register(rs2_data_ex_mem_reg),
        .read_op_register(read_op_ex_mem_reg),
        .write_op_register(write_op_ex_mem_reg),
        .rd_src_register(rd_src_ex_mem_reg),
        .rd_addr_register(rd_addr_ex_mem_reg),
        .rd_write_register(rd_write_ex_mem_reg)
    );
    MEMWBReg mem_wb_reg (
        .clk(clk),
        .rst_n(rst_n),

        .pc_src(pc_src_ex_mem_reg),
        .alu_result(alu_result_ex_mem_reg),
        .next_address(next_address_ex_mem_reg),
        .validated_read_op(validated_read_op),
        .data_mem_read_data(data_mem_read_data),
        .lcd_read_data(lcd_read_data),
        .button_read_data(button_read_data),
        .device_data_src(device_data_src),
        .rd_src(rd_src_ex_mem_reg),
        .rd_addr(rd_addr_ex_mem_reg),
        .rd_write(rd_write_ex_mem_reg),

        .pc_src_register(pc_src_mem_wb_reg),
        .alu_result_register(alu_result_mem_wb_reg),
        .next_address_register(next_address_mem_wb_reg),
        .validated_read_op_register(validated_read_op_mem_wb_reg),
        .data_mem_read_data_register(data_mem_read_data_mem_wb_reg),
        .lcd_read_data_register(lcd_read_data_mem_wb_reg),
        .button_read_data_register(button_read_data_mem_wb_reg),
        .device_data_src_register(device_data_src_mem_wb_reg),
        .rd_src_register(rd_src_mem_wb_reg),
        .rd_addr_register(rd_addr_mem_wb_reg),
        .rd_write_register(rd_write_mem_wb_reg)
    );
endmodule