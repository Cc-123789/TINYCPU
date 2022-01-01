`include "bus.v"

module rca (
    input  [`DATA_BUS] op1,
    input  [`DATA_BUS] op2,
    output [`DATA_BUS] sum,
    output cout
);

wire [`DATA_BUS_WIDTH:0] temp;
assign temp[0] = 0;

genvar i;
for( i=0; i<`DATA_BUS_WIDTH; i=i+1) begin
    full_adder u_full_adder(
        .a      (   op1[i]     ),
        .b      (   op2[i]     ),
        .cin    (   temp[i]    ),
        .cout   (   temp[i+1]  ),
        .s      (   sum[i]     )
    );
end

assign cout = temp[`DATA_BUS_WIDTH];

endmodule
