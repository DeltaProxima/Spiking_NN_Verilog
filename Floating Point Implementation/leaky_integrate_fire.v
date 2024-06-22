`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.04.2024 12:35:06
// Design Name: 
// Module Name: leaky_integrate_fire
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

module leaky_integrate_fire(
    input               clk,
    input               reset_n,
    input               spike_in,
    input       [31:0]   weight,
    input       [31:0]   threshold,
    input       [31:0]   leak_value,
    input       [7:0]    tref,
    output reg  [31:0]   memb_potential_out,  
    output reg          spike_out,
  	output reg         [7:0]   tr
);

    reg         [31:0]  voltage = 0;

    wire        [31:0]  memb_potential_integrate;  
  wire        [31:0]  synaptic_integration;      
  wire        [31:0]  leaked_potential;           
    wire        [31:0]  effective_leak_value;
  wire exc,exb;
  wire compare_out;
  wire spike_gen;

    assign memb_potential_integrate = spike_in ? weight : 32'b0;
  Addition_Subtraction add( voltage , memb_potential_integrate,1'b0,exc,synaptic_integration);
  comparator c(leak_value,voltage,compare_out);
    assign effective_leak_value = ~compare_out ? voltage : leak_value;
  Addition_Subtraction sub(synaptic_integration,effective_leak_value,1'b1,exb,leaked_potential);
 comparator cs(leaked_potential,threshold,spike_gen);
  
  //  assign leaked_potential = synaptic_integration - effective_leak_value;

    always @(posedge clk or negedge reset_n)
    begin
        if (~reset_n) begin
            spike_out <= 0;
            voltage <= 0;
            memb_potential_out <= 0; 
            tr <= 0;
        end else if (tr > 0) begin
            // In the refractory period
            spike_out <= 0;
            tr <= tr - 1;
            voltage <= 0;  
            memb_potential_out <= 0;
        end else if (~spike_gen) begin
           
            spike_out <= 1;
            tr <= tref;
            voltage <= 0; 
            memb_potential_out <= 0; 
        end else begin
         
            spike_out <= 0;
            voltage <= leaked_potential;
            memb_potential_out <= leaked_potential; 
        end
    end
endmodule
