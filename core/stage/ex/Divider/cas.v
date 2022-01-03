`timescale 1ns / 1ps
module cas (
    input  add_sub_en_in,
    input  cin,
    input  op1,
    input  op2,
    output result,
    output cout
);

    assign   result = op1 ^ op2 ^ cin ; 
    assign   cout = add_sub_en_in ? 
                    ( ~op1 & op2 ) | ( ~op1 & cin ) | ( op2 & cin ) 
                    : op1 & op2 | ( cin & ( op1 ^ op2 ) );
                    
endmodule