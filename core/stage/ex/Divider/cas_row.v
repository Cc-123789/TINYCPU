`include "bus.v"

module cas_row (
    input [`DATA_BUS] op1,
    input [`DATA_BUS] op2,
    input add_sub_en_in,
    output cout,
    output [`DATA_BUS] divisor,
    output [`DATA_BUS] rem
);


wire[`DATA_BUS_WIDTH:0] temp_cout;
wire[`DATA_BUS] add_sub_en_link;

assign divisor = op2;
assign cout = temp_cout[0];

genvar i;

for( i=0; i<`DATA_BUS_WIDTH; i=i+1) begin
    cas u_cas(
    .add_sub_en_in ( add_sub_en_link[i] ),
    .cin (temp_cout[i+1]),
    .op1 (op1[i]),
    .op2 (op2[i]),
    .result (rem[i]),
    .cout (temp_cout[i])
    );
end

endmodule