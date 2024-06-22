`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 28.04.2024 12:35:06
// Design Name: 
// Module Name: Addition_Subtraction
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


module Addition_Subtraction(input [31:0] a,b,
    input add_sub_signal,
    output exc,
    output [31:0] res );
    
    wire operation_add_sub_signal;
    wire enable;
    wire output_sign;
    wire [31:0] op_a,op_b;
    wire [23:0] significand_a,significand_b;
    wire [7:0] exp_diff;
    wire [23:0] significand_b_add_sub;
    wire [7:0] exp_b_add_sub;
    wire [24:0] significand_add;
    wire [30:0] add_sum;
    wire [23:0] significand_sub_complement;
    wire [24:0] significand_sub;
    wire [30:0] sub_diff;
    wire [24:0] subtraction_diff; 
    wire [7:0] exp_sub;
    wire exp_a,exp_b, perform ;
    assign {enable,op_a,op_b} = (a[30:0] < b[30:0]) ? {1'b1,b,a} : {1'b0,a,b};
    assign exp_a = op_a[30:23];
    assign exp_b = op_b[30:23];
    assign exc = (&op_a[30:23]) | (&op_b[30:23]);
    assign output_sign = add_sub_signal ? enable ? !op_a[31] : op_a[31] : op_a[31] ;
    assign operation_add_sub_signal = add_sub_signal ? op_a[31] ^ op_b[31] : ~(op_a[31] ^ op_b[31]);
    assign significand_a = (|op_a[30:23]) ? {1'b1,op_a[22:0]} : {1'b0,op_a[22:0]};
    assign significand_b = (|op_b[30:23]) ? {1'b1,op_b[22:0]} : {1'b0,op_b[22:0]};
    assign exp_diff = op_a[30:23] - op_b[30:23];
    assign significand_b_add_sub = significand_b >> exp_diff;
    assign exp_b_add_sub = op_b[30:23] + exp_diff; 
    assign perform = (op_a[30:23] == exp_b_add_sub);
    
    assign significand_add = (perform & operation_add_sub_signal) ? (significand_a + significand_b_add_sub) : 25'd0; 
    assign add_sum[22:0] = significand_add[24] ? significand_add[23:1] : significand_add[22:0];
    assign add_sum[30:23] = significand_add[24] ? (1'b1 + op_a[30:23]) : op_a[30:23];
    
    assign significand_sub_complement = (perform & !operation_add_sub_signal) ? ~(significand_b_add_sub) + 24'd1 : 24'd0 ; 
    assign significand_sub = perform ? (significand_a + significand_sub_complement) : 25'd0;
    
    priority_encoder pe(significand_sub,op_a[30:23],subtraction_diff,exp_sub);
    
    assign sub_diff[30:23] = exp_sub;
    assign sub_diff[22:0] = subtraction_diff[22:0];
    
    assign res = exc ? 32'b0 : ((!operation_add_sub_signal) ? {output_sign,sub_diff} : {output_sign,add_sum});

endmodule
