 `include "bus.v"
`include "funct.v"
 
 module Multiplier (
  input       [`FUNCT_BUS]        funct,
  input                           mul_en,
  input       [`DATA_BUS]         operand_1,
  input       [`DATA_BUS]         operand_2,
  output      [`DATA_BUS]         result  
 );

  //if negative, complement of operand_1& operand_2
  wire[`DATA_BUS] op1_c = (~operand_1) + 1;
  wire[`DATA_BUS] op2_c = (~operand_2) + 1;

   //(mult)temporary product of operand_1 & operand_2
  wire[`DOUBLE_DATA_BUS] result_mul_temp = op_mul_1 * op_mul_2 ;
  
  wire[`DOUBLE_DATA_BUS] result_mul;
    /*****************
    ** MULT/MULTU   ***
    ******************/ 
  //乘数1：若为有符号乘法且该乘数为负数，则取其补码，否则不变
  wire[`DATA_BUS] op_mul_1 = 
          (funct == (`FUNCT_MULT) && operand_1[31])?
          op1_c : operand_1;
  //乘数2
  wire[`DATA_BUS] op_mul_2 = 
          (funct == (`FUNCT_MULT) && operand_2[31])?
          op2_c : operand_2;

  //correct the temporary product
  always @(*) begin
    result_mul = {32'h00000000,32'h00000000};
    if(funct == (`FUNCT_MULT) begin
      if(operand_1[31] ^ operand_2[31] == 1'b1) begin
          result_mul = ~result_mul_temp + 1'b1;
      end
      else begin
          result_mul = result_mul_temp;
      end
    end
    else begin
            result_mul = result_mul_temp;
    end
  end

 endmodule
 