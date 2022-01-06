`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/05/2022 10:12:10 PM
// Design Name: 
// Module Name: digic_led
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


module digic_led(
    input clk,
    input rst,
    input [3:0] btn,
	output reg[7:0] seg_code,
    output [3:0] pos
);

    wire rst_not;
    
    assign rst_not = ~rst;
    assign pos = 4'b0001;

    parameter _0 = 8'hc0,_1 = 8'hf9,_2 = 8'ha4,_3 = 8'hb0,
	               _4 = 8'h99,_5 = 8'h92,_6 = 8'h82,_7 = 8'hf8,
	               _8 = 8'h80,_9 = 8'h90;
	always @( posedge clk or posedge rst_not )
        if( rst_not )
            seg_code <= 8'hff;
        else
            case( btn )
                4'd0:seg_code <= ~_0;
                4'd1:seg_code <= ~_1;
                4'd2:seg_code <= ~_2;
                4'd3:seg_code <= ~_3;
                4'd4:seg_code <= ~_4;
                4'd5:seg_code <= ~_5;
                4'd6:seg_code <= ~_6;
                4'd7:seg_code <= ~_7;
                4'd8:seg_code <= ~_8;
                4'd9:seg_code <= ~_9;
                default:
                    seg_code <= 8'hff;
            endcase    
endmodule