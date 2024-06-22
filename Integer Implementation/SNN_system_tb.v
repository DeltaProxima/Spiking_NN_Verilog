`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.04.2024 11:21:36
// Design Name: 
// Module Name: SNN_system_tb
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


`timescale 1ns / 1ps

module SNN_system_tb;

// Test Bench Generated Signals
reg clk;
reg rst;
reg [15:0] pixel_value;
reg [15:0] weight1;
reg [15:0] weight2;
reg [15:0] threshold1;
reg [15:0] threshold2;
reg [15:0] leak_value1;
reg [15:0] leak_value2;
reg [7:0] tref1;
reg [7:0] tref2;

// Parameters
parameter WIDTH = 16;
parameter WINDOW_SIZE = 5;

// Outputs being monitored
wire [15:0] memb_potential_out1;
wire [15:0] memb_potential_out2;
wire spike_out1;
wire spike_out2;
wire [7:0] tr1; // Refractory period for the first neuron
wire [7:0] tr2; // Refractory period for the second neuron
wire spike_train; // Spike input from the Poisson encoder
wire [15:0] random_number;

// Instantiate the Unit Under Test (UUT)
SNN_system uut (
    .clk(clk),
    .rst(rst),
    .pixel_value(pixel_value),
    .weight1(weight1),
    .weight2(weight2),
    .threshold1(threshold1),
    .threshold2(threshold2),
    .leak_value1(leak_value1),
    .leak_value2(leak_value2),
    .tref1(tref1),
    .tref2(tref2),
    .memb_potential_out1(memb_potential_out1),
    .memb_potential_out2(memb_potential_out2),
    .spike_out1(spike_out1),
    .spike_out2(spike_out2),
    .tr1(tr1),
    .tr2(tr2),
    .spike_train(spike_train),
    .random_number(random_number)
);

// Clock Generation
always #5 clk = ~clk; // Generate a clock with a period of 10 ns

initial begin
    // Initialize Inputs
    $dumpfile("dump.vcd");
    $dumpvars;
    clk = 0;
    rst = 1;
    pixel_value = 16'd00000;
    weight1 = 16'h0003; 
    weight2 = 16'h0004; 
    threshold1 = 16'h0005; 
    threshold2 = 16'h0005; 
    leak_value1 = 16'd1; 
    leak_value2 = 16'd1; 
    tref1 = 8'd1; 
    tref2 = 8'd1; 

    #20;
    rst = 0;
    #20 rst = 1;


  #(WINDOW_SIZE * 20) pixel_value = 16'd03240;
  #(WINDOW_SIZE * 20) pixel_value = 16'd42127;
    #(WINDOW_SIZE * 20) pixel_value = 16'd50458;
    #(WINDOW_SIZE * 20) pixel_value = 16'd65535;

    // Complete Simulation
    #100;
    $finish;
end

// Monitor changes
initial begin
   $monitor("Time = %t, clk = %b, Pixel Value = %d, Random Number = %d, Spike Train = %b, Neuron 1: Membrane Potential = %d, Spike Out = %b, tr = %d, Neuron 2: Membrane Potential = %d, Spike Out = %b, tr = %d",
             $time, clk, pixel_value, random_number, spike_train, memb_potential_out1, spike_out1, tr1, memb_potential_out2, spike_out2, tr2);

end

endmodule