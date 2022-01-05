`timescale 1ns / 1ps
`include "bus.v"

module Mux(
    input      [`DATA_BUS]          adder_result,
    input      [`DATA_BUS]          logic_reesult,
    input      [`DATA_BUS]          hilo_result,
    input      [`DOUBLE_DATA_BUS]   mult_result,
    input      [`DOUBLE_DATA_BUS]   div_result,
    input      [4:0]                select,
    output     reg [`DATA_BUS]          result,
    output     reg [`DOUBLE_DATA_BUS]   mult_div_result
);

    always @(*) begin
        case( select )
            5'b00001 : begin
               result <= adder_result;
               mult_div_result <= 0;                               
            end
            5'b00010 : begin
                result <= 0;
                mult_div_result <= mult_result;                
            end
            5'b00100 : begin
                result <= 0;
                mult_div_result <= div_result;                
            end
            5'b01000 : begin
                result <= logic_reesult;
                mult_div_result <= 0;                
            end
            5'b10000 : begin
                result <= hilo_result;
                mult_div_result <= 0;
            end
            default : begin
                result <= 0;
                mult_div_result <= 0;
            end
        endcase        
    end

endmodule