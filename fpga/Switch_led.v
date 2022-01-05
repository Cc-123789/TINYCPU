`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/07/16 17:23:43
// Design Name: 
// Module Name: flash_led_ctl
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

