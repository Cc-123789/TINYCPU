`timescale 1ps / 1ps

module Digic_seg (
    input clk,
    input rst,
    input [3:0] data,
    output reg [7:0] seg_code
);

    parameter _0 = 8'hc0,_1 = 8'hf9,_2 = 8'ha4,_3 = 8'hb0,
	               _4 = 8'h99,_5 = 8'h92,_6 = 8'h82,_7 = 8'hf8,
	               _8 = 8'h80,_9 = 8'h90,_A = 8'h88,_B = 8'h83,
	               _C = 8'hc6,_D = 8'ha1 , _E = 8'h86 , _F = 8'h8e;
                   
    always @(posedge clk or posedge rst)
        if (rst)
            seg_code <= 8'hff;
        else
            case (data)
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
                4'd10:seg_code <= ~_A;
                4'd11:seg_code <= ~_B;
                4'd12:seg_code <= ~_C;
                4'd13:seg_code <= ~_D;
                4'd14:seg_code <= ~_E;
                4'd15:seg_code <= ~_F;                
                default:seg_code <= 8'hff;
            endcase        
    
endmodule