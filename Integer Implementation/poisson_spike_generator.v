//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.04.2024 11:15:42
// Design Name: 
// Module Name: poisson_spike_generator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module poisson_spike_generator #(
    parameter WIDTH = 16,
    parameter WINDOW_SIZE = 5
) (
    input clk,
    input rst,
    input [WIDTH-1:0] pixel_value,
    output reg spike_train,
    output reg [WINDOW_SIZE-1:0] spike_train_array,
    output reg [15:0] random_number
);
    wire next_spike_train;
    reg [15:0] lfsr_reg;
    wire [15:0] next_random_number;
    reg [WINDOW_SIZE-1:0] spike_train_array_next;
    localparam SEED = 16'h005A;
    assign next_random_number = {lfsr_reg[14:0], lfsr_reg[15] ^ lfsr_reg[13] ^ lfsr_reg[12] ^ lfsr_reg[7]};
    assign next_spike_train = (next_random_number < pixel_value) ? 1'b1 : 1'b0;

    always @(posedge clk or negedge rst) begin
        if (~rst) begin
            spike_train <= 0;
            spike_train_array <= 0;
            random_number <= 0;
            lfsr_reg <= SEED;
        end else begin
            random_number <= next_random_number;
            spike_train <= next_spike_train;
            lfsr_reg <= next_random_number;
            spike_train_array <= {spike_train_array[WINDOW_SIZE-2:0], next_spike_train};
        end
    end
endmodule

