module leaky_integrate_fire(
    input               clk,
    input               reset_n,
    input               spike_in,
    input       [15:0]   weight,
    input       [15:0]   threshold,
    input       [15:0]   leak_value,
    input       [7:0]    tref,
    output reg  [15:0]   memb_potential_out,  
    output reg          spike_out,
  	output reg         [7:0]   tr
);

    reg         [15:0]  voltage = 0;

    wire        [15:0]  memb_potential_integrate;  
    wire        [15:0]  synaptic_integration;      
  wire        [15:0]  leaked_potential;           
    wire        [15:0]  effective_leak_value;

    assign memb_potential_integrate = spike_in ? weight : 16'b0;
    assign synaptic_integration = voltage + memb_potential_integrate;
    assign effective_leak_value = (leak_value > voltage) ? voltage : leak_value;
    assign leaked_potential = synaptic_integration - effective_leak_value;

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
            voltage <= 16'b1;  
            memb_potential_out <= 16'b1;
        end else if (leaked_potential >= threshold) begin
           
            spike_out <= 1;
            tr <= tref;
            voltage <= 16'b1; 
            memb_potential_out <= 16'b1; 
        end else begin
         
            spike_out <= 0;
            voltage <= leaked_potential;
            memb_potential_out <= leaked_potential; 
        end
    end
endmodule
