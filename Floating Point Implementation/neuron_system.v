`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.04.2024 12:35:06
// Design Name: 
// Module Name: neuron_system
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


module neuron_system(
    input clk,
    input rst,
    input [15:0] pixel_value,
  input [31:0] weight1,
  input [31:0] weight2,
  input [31:0] threshold1,
  input [31:0] threshold2,
  input [31:0] leak_value1,
  input [31:0] leak_value2,
    input [7:0] tref1,
    input [7:0] tref2,
  output [31:0] memb_potential_out1,
  output [31:0] memb_potential_out2,
    output spike_out1, // Spike output for the first neuron
    output spike_out2, // Spike output for the second neuron
    output [7:0] tr1, // Refractory period for the first neuron
    output [7:0] tr2, // Refractory period for the second neuron
    output spike_train,
  	output [15:0] random_number
);

  wire [4:0] spike_train_array;

poisson_spike_generator #(
    .WIDTH(16),
  .WINDOW_SIZE(5)
) spike_generator (
    .clk(clk),
    .rst(rst),
    .pixel_value(pixel_value),
    .spike_train(spike_train),
    .spike_train_array(spike_train_array),
    .random_number(random_number)
);

 leaky_integrate_fire lif_neuron1 (
        .clk(clk),
        .reset_n(rst),
        .spike_in(spike_train),
        .weight(weight1),
        .threshold(threshold1),
        .leak_value(leak_value1),
        .tref(tref1),
        .memb_potential_out(memb_potential_out1),
        .spike_out(spike_out1),
        .tr(tr1)
    );

    leaky_integrate_fire lif_neuron2 (
        .clk(clk),
        .reset_n(rst),
        .spike_in(spike_out1), // Use spike output from the first neuron as input
        .weight(weight2),
        .threshold(threshold2),
        .leak_value(leak_value2),
        .tref(tref2),
        .memb_potential_out(memb_potential_out2),
        .spike_out(spike_out2),
        .tr(tr2)
    );


endmodule