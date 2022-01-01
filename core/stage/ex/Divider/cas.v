module cas (
    input  add_sub_en_in,
    input  cin,
    input  op1,
    input  op2_in,
    output reg result,
    output op2_out,
    output reg cout,
    output add_sub_en_out
);

    assign op2_in = op2_out;
    assign result <= op1 ^ op2_in ^ cin ;  

    always @(*) begin
        if ( add_sub_en_in ) begin
            cout <= ( ~op1 & op2_in ) | ( ~op1 & cin ) | ( op2_in & cin );
        end
        else begin

            cout <=  op1 & op2_in | ( cin & ( op1 ^ op2_in ) );            
        end
    end
endmodule