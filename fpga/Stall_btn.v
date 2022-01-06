`timescale 1ps / 1ps

module Stall_btn(
    input clk,
    input rst,
    input btn2,
    output reg stall
);

 wire btn2_out;
 
  btn_out btn_out_unit(
	.clk  (clk),
	.rst  (rst),
	.sw_in_n (btn2),
	.sw_out_n (btn2_out)
  );



    reg stall_sig;
    
    always @(posedge clk or posedge rst) begin
        if ( rst ) begin
            stall <= 1'b1;
            stall_sig <= 1'b1;         
        end
        else if ( ~btn2_out ) begin
            stall_sig <= 1'b1;
        end
        else if( ~stall_sig ) begin
            stall <= 1'b1;
        end
        else if ( btn2_out && stall_sig ) begin
            stall <= 1'b0;
            stall_sig <= 1'b0;
        end   
        else begin
            stall <= stall;
            stall_sig <= stall_sig;
        end
    end   
   
    
endmodule