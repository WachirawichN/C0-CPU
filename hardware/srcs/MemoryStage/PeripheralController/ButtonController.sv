`timescale 1ns/1ps

module ButtonController
    import ControlSignals_pkg::*;
#(
    parameter               ROWS = 5,
    parameter               COLS = 4,
    parameter               TARGET_MS = 50, // ms for the same signal level to be to not count as bounce
    parameter               CLOCK_RATE = 50_000_000
) (
    input logic             clk,
    input logic             rst_n,

    input MEMRead           mem_read,

    input logic [COLS-1:0]  col_in, // Save a bit of pull down resistors.
    output logic [ROWS-1:0] row_out = 0, // Row scannings
    
    output logic [31:0]     data_out
);
    // Calculator button layout
    // Could be interpret as other button up to the program currently running.
    // col 0  1  2  3
    // row
    // 0   (  ) <-  c
    // 1   7  8  9  x
    // 2   4  5  6  -
    // 3   1  2  3  +
    // 4  00  0  .  =
    // CPU reset button doesn't included in this diagram.
    // 
    // How it works
    // 1. The 

    // Column synchronization
    localparam SYNC_STAGES = 2;
    logic [COLS-1:0] cols_sync [SYNC_STAGES-1:0] = '{default: 0};
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cols_sync <= '{default: 0};
        end else begin
            for (int stage = 0; stage < SYNC_STAGES - 1; stage = stage + 1) begin
                cols_sync[stage+1] <= cols_sync[stage];
            end
            cols_sync[0] <= col_in;
        end
    end

    // Dividing the clock down to 1000Hz (1ms per cycle)
    // Use the clk_counter directly. If the value is 0 then it finished counting.
    localparam CLOCK_PER_MS = CLOCK_RATE * 0.001;
    logic [$clog2(CLOCK_PER_MS)-1:0] clk_counter = 0;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            clk_counter <= 0;
        end else begin
            if (clk_counter >= CLOCK_PER_MS) clk_counter <= 0;
            else clk_counter <= clk_counter + 1;
        end
    end

    // Row scanning
    logic raw_input_matrix [ROWS-1:0][COLS-1:0] = '{default: 0};
    logic [$clog2(ROWS):0] current_row = 0;
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            current_row <= 0;
            row_out <= 0;
        end else begin
            // Row scanning
            if (current_row == ROWS) current_row <= 0;
            else current_row <= current_row + 1;

            row_out <= 1;
            row_out[current_row] <= 1'b0;

            raw_input_matrix[current_row] <= {>>{!cols_sync[SYNC_STAGES-1]}};
        end
    end

    // Debouncing each button
    logic [$clog2(TARGET_MS)-1:0] ms_timer_matrix [ROWS-1:0][COLS-1:0] = '{default: 0};
    logic previous_input_matrix [ROWS-1:0][COLS-1:0] = '{default: 0};
    logic debounced_input_matrix [ROWS-1:0][COLS-1:0] = '{default: 0};
    always_ff  @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ms_timer_matrix <= '{default: 0};
            debounced_input_matrix <= '{default: 0};
        end else begin
            for (int row = 0; row < ROWS; row = row + 1) begin
                for (int col = 0; col < COLS; col = col + 1) begin
                    // The debounce should finish after the state of a button in this and previous cycle is the same for long enough.
                    if (raw_input_matrix[row][col] == previous_input_matrix[row][col]) begin
                        if (ms_timer_matrix[row][col] >= TARGET_MS) begin
                            debounced_input_matrix[row][col] <= raw_input_matrix[row][col]; // Debounce complete
                            ms_timer_matrix[row][col] <= 0;
                        end else begin
                            ms_timer_matrix[row][col] <= ms_timer_matrix[row][col] + 1;
                        end
                    end else begin
                        ms_timer_matrix[row][col] <= 0;
                    end
                end
            end
        end
    end

    // Choosing the output
    always @(debounced_input_matrix) begin
        // case (mem_read)
        //     : 
        //     default: 
        // endcase
    end
endmodule