`timescale 1ns / 1ps
`include "bus.v"
module HILO(
    input clk,
    input rst,
    input write_en,
    input [`DATA_BUS] hi_write_data,
    input [`DATA_BUS] lo_write_data,
    output [`DATA_BUS] hi_read_data,
    output [`DATA_BUS] lo_read_data
);

    reg [`DATA_BUS] hi;
    reg [`DATA_BUS] lo;

    assign hi_read_data = hi;
    assign lo_read_data = lo;

    always @(posedge clk) begin
        if(rst) begin
            hi <= 0;
            lo <= 0;
        end 
        else if (write_en) begin
            hi <= hi_write_data;
            lo <= lo_write_data;
        end
    end
    
endmodule