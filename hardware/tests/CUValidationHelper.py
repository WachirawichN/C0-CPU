def decodeFractionOfTheInst(instruction):
    opcode = instruction[-7:len(instruction)]
    if opcode == "0110011":
        # ALU R-type
        pass
    elif opcode == "0010011":
        # ALU I-type
        pass
    elif opcode == "0000011":
        # 
        pass
    elif opcode == "1100111":
        # 
        pass
    elif opcode == "0100011":
        # 
        pass
    elif opcode == "1100011":
        # 
        pass
    elif opcode == "1101111":
        # 
        pass
    elif opcode == "0110111":
        # 
        pass
    elif opcode == "0010111":
        # 
        pass
    else:
        raise ValueError(f"Unknown opcode: {opcode}")

    print()

instruction_dict = {
    "0110011" : {
        # ALU r type
    },
    "0010011" : {
        # ALU i type
    },
    "0000011" : {
        # Load i type
    },
    "1100111" : {
        # jalr i type
    },
    "0100011" : {
        # Store s type
    },
    "1100011" : {
        # Branch b type
    },
    "1101111" : {
        # jal j type
    },
    "0110111" : {
        # lui u type
    },
    "0010111" : {
        # auipc u type
    }
}
instruction_dict = {
    "0110011"
    "0010011"
    "0000011"
    "1100111"
    "0100011"
    "1100011"
    "1101111"
    "0110111"
    "0010111"
}

while True:
    instruction = input("Enter Instruction: ").strip("")
    opcode = instruction[-7:len(instruction)]
    print(opcode)