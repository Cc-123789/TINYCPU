`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/06/2022 02:32:00 AM
// Design Name: 
// Module Name: Switch_led
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


module Switch_led(
        input         clk,
 	 	input         rst,
 	 	input  [7:0]  switch,
 	 	output reg [7:0] led
);

	always @( posedge clk or posedge rst )
	    if (rst)
	       led = 8'h80;
	    else
		   led = switch;
endmodule