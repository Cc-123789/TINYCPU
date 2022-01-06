`timescale 1ps / 1ps

`include "bus.v"


module mux_5to1(
    input      [31:0]          debug_pc,
    input      [31:0]          debug_operand_1,
    input      [31:0]          debug_operand_2,
    input      [31:0]  		   debug_branch_addr,
    input      [31:0]   	   debug_wb_result,
    input      [31:0]   	   debug_hi_read_data,
    input      [31:0]   	   debug_lo_read_data,
    input      [31:0]          debug_ifid_inst,
    input      [7:0]           select,
    output     reg [31:0]      result
);


    always @(*) begin
        case( select )
            8'b0000_0000 : begin
               result <= debug_pc;                             
            end
            8'b0000_0001 : begin
                result <= debug_operand_1;              
            end
            8'b0000_0010 : begin
                result <= debug_operand_2;               
            end
            8'b0000_0100 : begin
                result <= debug_branch_addr;               
            end
            8'b0000_1000 : begin
                result <= debug_wb_result;
            end
            8'b0001_0000 : begin
                result <= debug_hi_read_data;
            end
            8'b0010_0000 : begin
                result <= debug_lo_read_data;
            end
            8'b0100_0000 : begin
                result <= debug_ifid_inst;
            end
            default : begin
                result <= 0;
            end
        endcase        
    end

endmodule