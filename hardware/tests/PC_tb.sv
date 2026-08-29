`timescale 1ns/1ps

module PC_tb;
    bit rst_n = 1;
    bit pc_src = 0;
    int jump_address = 0;
    bit clk = 0;
    logic[31:0] address;

    PC dut (
        .rst_n(rst_n),
        .pc_src(pc_src),
        .jump_address(jump_address),
        .clk(clk),
        .address(address)
    );

    task automatic resetPC();
        rst_n = 0;
        #1ns;
        rst_n = 1;
    endtask
    task automatic jumpPC(input int new_address);
        jump_address = new_address;
        pc_src = 1;

        @(posedge clk);
        #1;
        jump_address = 0;
        pc_src = 0;
    endtask

    class CyclicWrapper;
        randc int value;
    endclass

    longint i;
    CyclicWrapper target_jump_address = new();
    initial begin
        forever #1ns clk = !clk;
    end
    initial begin
        // Assume this part works perfectly, because Vivado always keep crashing on me at this part. Probably consume too much ram.
        // for (i = 0; i < 2 ** 32; i = i + 4) begin
        //     if (address != i) begin
        //         $fatal(1, "Mismatch between PC's address (%0d) and i value (%0d).", address, i);
        //     end

        //     @(posedge clk);
        //     #1;
        // end
        // resetPC();
        // $display("Finish testing normal couting up functionality.");

        repeat (10000) begin
            assert (target_jump_address.randomize()) else $fatal(4, "Unable to randomize new value.");
            jumpPC(target_jump_address.value);

            if (address != target_jump_address.value) begin
                $fatal(2, "Mismatch between PC's address (%0d) and target jump address value (%0d).", address, target_jump_address.value);
            end
        end
        $display("Finish testing jump functionality.");

        resetPC();
        if (address != 0) begin
            $fatal(3, "Unable to reset the PC.");
        end

        $finish;
    end
endmodule