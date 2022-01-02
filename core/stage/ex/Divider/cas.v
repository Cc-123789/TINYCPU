`timescale 1ns / 1ps
module cas (
    input  add_sub_en_in,
    input  cin,
    input  op1,
    input  op2,
    output reg result,
    output reg cout
);
//    assign 
   

    always @(*) begin
     result = op1 ^ op2 ^ cin ; 
        if ( add_sub_en_in ) begin
            cout <= ( ~op1 & op2 ) | ( ~op1 & cin ) | ( op2 & cin );
        end
        else begin
            cout <=  op1 & op2 | ( cin & ( op1 ^ op2 ) );            
        end
    end
endmodule