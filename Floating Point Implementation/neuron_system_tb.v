`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.04.2024 12:57:12
// Design Name: 
// Module Name: neuron_system_tb
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


module neuron_system_tb;

// Test Bench Generated Signals
reg clk;
reg rst;
reg [15:0] pixel_value;
  reg [31:0] weight1;
  reg [31:0] threshold1;
  reg [31:0] leak_value1;
  reg [7:0] tref1;
  reg [31:0] weight2;
  reg [31:0] threshold2;
  reg [31:0] leak_value2;
  reg [7:0] tref2;

// Outputs being monitored
  wire [31:0] memb_potential_out1;
  wire [31:0] memb_potential_out2;
wire spike_out1,spike_out2;
  wire [7:0] tr1;
  wire [7:0] tr2;
wire spike_train;
  wire [15:0] random_number;

// Instantiate the Unit Under Test (UUT)
neuron_system uut (
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
    pixel_value = 16'd20000;
    weight1 = 32'h40800000;
    threshold1 = 32'h41400000;
    leak_value1 = 32'h3e4ccccd; //0.2
    tref1 = 8'd2;
	weight2 = 32'h40800000;
    threshold2 = 32'h40a00000;
    leak_value2 = 32'h3ca3d70a; //0.02
    tref2 = 8'd2;

    // Reset the system
    #50;
    rst = 0;
    #50 rst = 1;

    // Stimulus: Example pixel value sequence
   pixel_value = 16'd10000;
  #(5* 10) pixel_value = 16'd40000;
  #(5 * 10) pixel_value = 16'd50000;
    //#(5 * 20) pixel_value = 16'd65535;

    // Complete Simulation
    #(5 * 20);
    $finish;
end

// Monitor changes
initial begin
   $monitor("Time = %t, clk = %b, Pixel Value = %d, Random Number = %d, Spike Train = %b, Neuron 1: Membrane Potential = %d, Spike Out = %b, tr = %d, Neuron 2: Membrane Potential = %d, Spike Out = %b, tr = %d",
             $time, clk, pixel_value, random_number, spike_train, memb_potential_out1, spike_out1, tr1, memb_potential_out2, spike_out2, tr2);

end

endmodule
