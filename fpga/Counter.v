`timescale 1ps / 1ps

module Counter(
	input clk,
  	input rst,
  	output clk_bps
 );	
    parameter OVER = 14'd100;
    
 	 	reg [13:0]cnt_first,cnt_second;
 	 	always @( posedge clk or posedge rst )
 	 	 	if( rst )
 	 			cnt_first <= 14'd0;
 	 		else if( cnt_first == OVER )
 	 			cnt_first <= 14'd0;
 	 		else
 	 			cnt_first <= cnt_first + 1'b1;
 	 	always @( posedge clk or posedge rst )
 	 		if( rst )
 	 			cnt_second <= 14'd0;
 	 		else if( cnt_second == OVER )
 	 			cnt_second <= 14'd0;
 	 		else if( cnt_first == OVER )
 	 			cnt_second <= cnt_second + 1'b1;
 	 	assign clk_bps = cnt_second == OVER ? 1'b1 : 1'b0;
endmodule