`include "bus.v"

module cas_row (
    input [`DATA_BUS] op1,
    input [`DATA_BUS] op2,
    output cout,
    output divisor,
    output rem
);


wire [`DATA_BUS_WIDTH:0] temp;
assign temp[0] = 0;

genvar i;
for( i=0; i<width; i=i+1) begin
    cas u_cas(
    .add_sub_en_in (add_sub_en_in),
    .cin (cin),
    .op1 (op1),
    .op2_in (op2_in),
    .regresult (regresult),
    .op2_out (op2_out),
    .regcout (regcout),
    .add_sub_en_out (add_sub_en_out)
    );
end

assign cout = temp[`DATA_BUS_WIDTH];

endmodule