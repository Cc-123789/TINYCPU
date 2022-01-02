`include "bus.v"
`include "funct.v"
 
 module Multiplier (
  input                           mul_en,
  input       [`DATA_BUS]         op1,
  input       [`DATA_BUS]         op2,
  output      reg                 done,
  output  reg [`DOUBLE_DATA_BUS]  result_mul  
 );

wire[`DATA_BUS] operand_1[`DATA_BUS];
wire[`DATA_BUS] operand_2[`DATA_BUS_WIDTH-1:0];
wire[`DATA_BUS] cout;
wire[`DATA_BUS] temp_1[`DATA_BUS];

wire[`DATA_BUS_WIDTH-1:0] temp_sum;

assign cout[0] = 0;
genvar i,j;

for ( i = 0 ;i < `DATA_BUS_WIDTH ; i=i+1 ) begin
	assign operand_1[i] = { cout[i] , temp_1[i][`DATA_BUS_WIDTH-1:1] };
end

for ( i = 0 ; i < `DATA_BUS_WIDTH -1 ; i = i + 1) begin
	for ( j= 0 ; j <`DATA_BUS_WIDTH ; j = j+1) begin
		assign operand_2[i][j] = op1[j] & op2[i+1];
	end
end 


for ( i = 0 ; i < `DATA_BUS_WIDTH ; i = i + 1) begin
	assign temp_1[0][i] = op1[i] & op2[0];
end 

for( i=0; i < `DATA_BUS_WIDTH - 1; i=i+1) begin
    rca u_rca(
		.op1( operand_1[i] ),
		.op2( operand_2[i] ),
		.sum( temp_1[i+1] ),
		.cout( cout[i+1] )
    );
end

for ( i = 0;i<`DATA_BUS_WIDTH-1;i=i+1) begin
	assign temp_sum[i] = temp_1[i][0];
end

assign result_mul = {cout[31],temp_1[31],temp_sum};

endmodule
 