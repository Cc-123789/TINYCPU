`timescale 1ns / 1ps
`include "bus.v"

module Divider (
  input                           div_en,
  input       [`DATA_BUS]         operand_1,
  input       [`DATA_BUS]         operand_2,
  output                          done,
  output      [`DOUBLE_DATA_BUS]  result
);

wire[`DATA_BUS]                     op1[`DATA_BUS];
wire[`DATA_BUS]                     op2[`DATA_BUS];
wire[`DATA_BUS]                     cout;
wire[`DATA_BUS]                     add_sub_en_link;
wire[`DATA_BUS]                     quo;
wire[`DATA_BUS]                     rem[`DATA_BUS];
wire                                add_fix_flag;
wire                                sub_fix_flag;
wire[`DATA_BUS]                     temp_quo;
wire[`DATA_BUS]                     temp_rem;
wire[`DATA_BUS]                     temp_quo_fix;
wire[`DATA_BUS]                     temp_rem_fix;
wire                                div_flag;


Done_gate done_gate(
  .data_in(cout),
  .done(done)
);

assign op2[0] = operand_2;
assign add_sub_en_link[0] = ~ ( operand_1[`DATA_BUS_WIDTH-1] ^ operand_2[`DATA_BUS_WIDTH-1] );
assign op1[0] = { `DATA_BUS_WIDTH{ operand_1[`DATA_BUS_WIDTH-1] } };
assign add_fix_flag = ( temp_rem + operand_2 ) == 0 ? 1 :0;
assign sub_fix_flag = ( temp_rem - operand_2 ) == 0 ? 1 :0;
genvar i;

for ( i = 1; i< `DATA_BUS_WIDTH; i = i + 1 ) begin
  assign add_sub_en_link[i] = ~ ( rem[i-1][`DATA_BUS_WIDTH-1] ^ op2[i][`DATA_BUS_WIDTH-1] );
end

for ( i = 1; i < `DATA_BUS_WIDTH; i = i + 1) begin
  assign op1[i][`DATA_BUS_WIDTH-1:1] = rem[i-1][`DATA_BUS_WIDTH-2:0];
  assign op1[i][0] = operand_1[`DATA_BUS_WIDTH-1-i];   
end

for (i=0;i < `DATA_BUS_WIDTH; i = i + 1) begin
  assign quo[i] = ~(rem[`DATA_BUS_WIDTH-1-i][`DATA_BUS_WIDTH-1] ^ op2[i][`DATA_BUS_WIDTH-1]);  
end

for( i=0; i < `DATA_BUS_WIDTH ; i=i+1) begin
    cas_row u_cas_row(
      .op1( op1[i] ),
      .op2( op2[i] ),
      .add_sub_en_in( add_sub_en_link[i] ),
      .cout( cout[i] ),
      .divisor( op2[i+1] ),
      .rem( rem[i] )
    );
end

assign  temp_rem = ~( rem[`DATA_BUS_WIDTH-1][`DATA_BUS_WIDTH-1] ^  operand_1[`DATA_BUS_WIDTH-1] )
                    ? rem[`DATA_BUS_WIDTH-1] 
                    : ( operand_1[`DATA_BUS_WIDTH-1] ^ operand_2[`DATA_BUS_WIDTH-1] ) 
                    ? rem[`DATA_BUS_WIDTH-1] - operand_2
                    : rem[`DATA_BUS_WIDTH-1] + operand_2;

assign  temp_quo =  ( operand_1[`DATA_BUS_WIDTH-1] ^ operand_2[`DATA_BUS_WIDTH-1] ) ? quo + 1 : quo;

assign  temp_rem_fix = sub_fix_flag ?  0 :
                       add_fix_flag ?  0 : temp_rem;

assign  temp_quo_fix = sub_fix_flag ?  temp_quo + 1 :
                       add_fix_flag ?  temp_quo - 1 : temp_quo;

assign result = { temp_rem_fix,temp_quo_fix };

endmodule
