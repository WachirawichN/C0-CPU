ALU_INSTRUCTIONS = [
    ["ADD", "SUB"],
    "SLL",
    "SLT",
    "SLTU",
    "XOR",
    ["SRL", "SRA"],
    "OR",
    "AND"
]
LOAD_INSTRUCTIONS = [
    "LB",
    "LH",
    "LW",
    None,
    "LBU",
    "LHU"
]
STORE_INSTRUCTIONS = [
    "SB",
    "SH",
    "SW"
]
BRANCH_INSTRUCTIONS = [
    "BEQ",
    "BNE",
    None,
    None,
    "BLT",
    "BGE",
    "BLTU",
    "BGEU"
]

def decodeFractionOfTheInst(instruction):
    instruction_data = {
        "format": None,
        "operation": None,
        "rs1": None,
        "rs2": None,
        "imm": None,
        "rd": None,
    }
    opcode = instruction[-7:len(instruction)]
    if opcode == "0110011":
        # ALU R-type
        instruction_data["format"] = "R-type"

        instruction_data["operation"] = ALU_INSTRUCTIONS[int(instruction[-15:-12], base=2)]
        if isinstance(instruction_data["operation"], list):
            instruction_data["operation"] = instruction_data["operation"][int(instruction[-31], base=2)]

        instruction_data["rs1"] = int(instruction[-20:-15], base=2)
        instruction_data["rs2"] = int(instruction[-25:-20], base=2)
        instruction_data["rd"] = int(instruction[-12:-7], base=2)
    elif opcode == "0010011":
        # ALU I-type
        instruction_data["format"] = "I-type"

        instruction_data["operation"] = ALU_INSTRUCTIONS[int(instruction[-15:-12], base=2)]
        if isinstance(instruction_data["operation"], list):
            instruction_data["operation"] = instruction_data["operation"][int(instruction[-31], base=2)]

        instruction_data["rs1"] = int(instruction[-20:-15], base=2)
        instruction_data["imm"] = int(instruction[-32:-20], base=2)
        instruction_data["rd"] = int(instruction[-12:-7], base=2)
    elif opcode == "0000011":
        # Load I-type
        instruction_data["format"] = "I-type"

        instruction_data["operation"] = LOAD_INSTRUCTIONS[int(instruction[-15:-12], base=2)]

        instruction_data["rs1"] = int(instruction[-20:-15], base=2)
        instruction_data["imm"] = int(instruction[-32:-20], base=2)
        instruction_data["rd"] = int(instruction[-12:-7], base=2)
    elif opcode == "1100111":
        # jalr I-type
        instruction_data["format"] = "I-type"

        instruction_data["operation"] = "jalr"
        
        instruction_data["rs1"] = int(instruction[-20:-15], base=2)
        instruction_data["imm"] = int(instruction[-32:-20], base=2)
        instruction_data["rd"] = int(instruction[-12:-7], base=2)
    elif opcode == "0100011":
        # Store S-type
        instruction_data["format"] = "S-type"

        instruction_data["operation"] = STORE_INSTRUCTIONS[int(instruction[-15:-12], base=2)]
                
        instruction_data["rs1"] = int(instruction[-20:-15], base=2)
        instruction_data["rs2"] = int(instruction[-25:-20], base=2)
        instruction_data["imm"] = int(instruction[-32:-25] + instruction[-12:-7], base=2)
    elif opcode == "1100011":
        # Branch B-type
        instruction_data["format"] = "B-type"

        instruction_data["operation"] = BRANCH_INSTRUCTIONS[int(instruction[-15:-12], base=2)]
                        
        instruction_data["rs1"] = int(instruction[-20:-15], base=2)
        instruction_data["rs2"] = int(instruction[-25:-20], base=2)
        instruction_data["imm"] = int(instruction[-32:-25] + instruction[-12:-7], base=2)
    elif opcode == "1101111":
        # jal J-type
        instruction_data["format"] = "J-type"

        instruction_data["operation"] = "jal"
                                
        instruction_data["imm"] = int(instruction[-32:-12], base=2)
        instruction_data["rd"] = int(instruction[-12:-7], base=2)
    elif opcode == "0110111":
        # lui U-type
        instruction_data["format"] = "U-type"

        instruction_data["operation"] = "lui"
                                        
        instruction_data["imm"] = int(instruction[-32:-12], base=2)
        instruction_data["rd"] = int(instruction[-12:-7], base=2)
    elif opcode == "0010111":
        # auipc U-type
        instruction_data["format"] = "U-type"

        instruction_data["operation"] = "auipc"
                                                
        instruction_data["imm"] = int(instruction[-32:-12], base=2)
        instruction_data["rd"] = int(instruction[-12:-7], base=2)
    else:
        raise ValueError(f"Unknown opcode: {opcode}")

    print(f"Instruction: {instruction}")
    print(f"    - Instruction Format: {instruction_data["format"]}")
    print(f"    - Operation: {instruction_data["operation"]}")
    print(f"    - rs1: {instruction_data["rs1"]}")
    print(f"    - rs2: {instruction_data["rs2"]}")
    print(f"    - imm: {instruction_data["imm"]}")
    print(f"    - rd: {instruction_data["rd"]}")

# instruction_dict = {
#     "0110011"
#     "0010011"
#     "0000011"
#     "1100111"
#     "0100011"
#     "1100011"
#     "1101111"
#     "0110111"
#     "0010111"
# }

while True:
    instruction = input("Enter Instruction: ").strip("")
    decodeFractionOfTheInst(instruction)