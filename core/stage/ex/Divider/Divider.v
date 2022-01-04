`timescale 1ns / 1ps
`include "bus.v"

module Divider (
  input                           div_en,
  input       [`DATA_BUS]         operand_1,
  input       [`DATA_BUS]         operand_2,
  output      reg                 done,
  output      [`DOUBLE_DATA_BUS]  result
);

wire[`DATA_BUS]                     op1[`DATA_BUS];
wire[`DATA_BUS]                     op2[`DATA_BUS];
wire[`DATA_BUS]                     cout;
wire[`DATA_BUS]                     add_sub_en_link;
wire[`DATA_BUS]                     quo;
wire[`DATA_BUS]                     rem[`DATA_BUS];
wire[`DATA_BUS]                     temp_quo;
wire[`DATA_BUS]                     temp_rem;


assign op2[0] = op2;
assign add_sub_en_link[0] = ~ ( operand_1[`DATA_BUS_WIDTH-1] ^ operand_2[`DATA_BUS_WIDTH-1] );
assign op1[0] = { `DATA_BUS_WIDTH{ operand_1[`DATA_BUS_WIDTH-1] } };

genvar i;

for ( i = 1; i< `DATA_BUS_WIDTH; i = i + 1 ) begin
  assign add_sub_en_link[i] = ~ ( rem[i-1][`DATA_BUS_WIDTH-1] ^ op2[i][`DATA_BUS_WIDTH-1] );
end

for ( i = 1; i < `DATA_BUS_WIDTH; i = i + 1) begin
  assign begin
    op1[i][`DATA_BUS_WIDTH-1:1] = rem[i-1][`DATA_BUS_WIDTH-2:0];
    op1[i][0] = operand_1[`DATA_BUS_WIDTH-1-i];   
  end
end

for (i=0;i < `DATA_BUS_WIDTH; i = i + 1) begin
  assign quo[i] = cout[`DATA_BUS_WIDTH-1-i] ^ add_sub_en_link[`DATA_BUS_WIDTH-1-i];  
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

//修正余数：如果余数和被除数同号，不需要修正，否则，如果被除数和除数同号，余数加上被除数，否则余数减去被除数。
assign begin
  if ( rem[`DATA_BUS_WIDTH-1][`DATA_BUS_WIDTH-1] ^  operand_1[`DATA_BUS_WIDTH-1]) begin
    temp_rem = rem[`DATA_BUS_WIDTH-1];
  end
  else begin
    if ( operand_1[`DATA_BUS_WIDTH-1] ^ operand_2[`DATA_BUS_WIDTH-1] ) begin
      temp_rem = rem[`DATA_BUS_WIDTH-1] - operand_2;   
    end
    else begin
      temp_rem = rem[`DATA_BUS_WIDTH-1] + operand_2;       
    end 
  end
end

//修正商：如果被除数和除数异号，商加一。
assign begin
    if ( operand_1[`DATA_BUS_WIDTH-1] ^ operand_2[`DATA_BUS_WIDTH-1] ) begin
      temp_quo = quo + 1;   
    end
    else begin
      temp_quo = quo;       
    end 
end

assign result = { temp_rem,temp_rem };

endmodule
