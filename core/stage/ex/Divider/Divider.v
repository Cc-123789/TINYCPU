`timescale 1ns / 1ps
`include "bus.v"

module Divider (
  input                           div_en,
  input       [`DATA_BUS]         operand_1,
  input       [`DATA_BUS]         operand_2,
  output      reg                 done,
  output      [`DOUBLE_DATA_BUS]  result
);

wire[`DATA_BUS]                     op1[`DATA_BUS_WIDTH:0];
wire[`DATA_BUS]                     op2[`DATA_BUS_WIDTH:0];
wire[`DATA_BUS_WIDTH:0]             cout;
wire[`DATA_BUS_WIDTH:0]             add_sub_en_link;
wire[`DATA_BUS]                     quo;
wire[`DATA_BUS]                     rem[`DATA_BUS_WIDTH:0];
wire[`DATA_BUS]                     temp_op1;
wire[`DATA_BUS]                     temp_op2;
wire[`DATA_BUS]                     temp_quo;
wire[`DATA_BUS]                     temp_rem;

assign temp_op1 = operand_1[`DATA_BUS_WIDTH-1] ? ~operand_1 + 1 : operand_1;
assign temp_op2 = operand_2[`DATA_BUS_WIDTH-1] ? ~operand_2 + 1 : operand_2;
assign op2[0] = temp_op2;
assign add_sub_en_link[0] = ~ ( temp_op1[`DATA_BUS_WIDTH-1] ^ temp_op2[`DATA_BUS_WIDTH-1] );
assign op1[0] = { `DATA_BUS_WIDTH{ temp_op1[`DATA_BUS_WIDTH-1] } };

genvar i,j;

for ( i = 1; i<= `DATA_BUS_WIDTH; i = i + 1 ) begin
  assign add_sub_en_link[i] = ~ ( rem[i-1][`DATA_BUS_WIDTH-1] ^ op2[i][`DATA_BUS_WIDTH-1] );
end

for ( i = 1; i < `DATA_BUS_WIDTH; i = i + 1) begin
  assign op1[i][`DATA_BUS_WIDTH-1:1] = rem[i-1][`DATA_BUS_WIDTH-2:0];
  assign op1[i][0] = temp_op1[`DATA_BUS_WIDTH-1-i];     
end

assign op1[`DATA_BUS_WIDTH] = rem[`DATA_BUS_WIDTH-1];

for (i=0;i < `DATA_BUS_WIDTH; i = i + 1) begin
  assign quo[i] = cout[`DATA_BUS_WIDTH-1-i] ^ add_sub_en_link[`DATA_BUS_WIDTH-1-i];  
end

for( i=0; i <= `DATA_BUS_WIDTH ; i=i+1) begin
    cas_row u_cas_row(
		.op1( op1[i] ),
		.op2( op2[i] ),
    .add_sub_en_in( add_sub_en_link[i] ),
    .cout( cout[i] ),
    .divisor( op2[i+1] ),
    .rem( rem[i] )
    );
end

//assign temp_rem = quo[0] ? rem[`DATA_BUS_WIDTH] + temp_op2 : rem[`DATA_BUS_WIDTH];
assign temp_quo = ( operand_1[`DATA_BUS_WIDTH-1] ^ operand_2[`DATA_BUS_WIDTH-1]) ? ~quo + 1 : quo;
assign temp_rem =   operand_1[`DATA_BUS_WIDTH-1] ? ~rem[`DATA_BUS_WIDTH] + 1 : rem[`DATA_BUS_WIDTH];

assign result = { temp_rem,temp_quo };

endmodule