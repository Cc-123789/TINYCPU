
`include "bus.v"
`include "funct.v"

module Adder(
  input       [`FUNCT_BUS]    funct,
  input       add_en,
  input       [`DATA_BUS]     operand_1,
  input       [`DATA_BUS]     operand_2,
  output      [`DATA_BUS]     result,
  output                      overflow_flag
);

  wire overflow_flag = 
          // op1 & op2 is positive, op1 + op2 is negative
          ((!operand_1[31] && !operand_2[31] && result[31]) ||
          // op1 & op2 is negative, op1 + op2 is negative
          (operand_1[31] && operand_2[31] && !result[31])) ;

  always @(*) begin
      if (add_en) begin
        operand_2 = ( funct == `FUNCT_SUBU || funct == `FUNCT_SUB ) ? (~operand_2) + 1 : operand_2;
        result = operand_1 + operand_2;          
      end
      else begin
        result <= 0;
      end
  end  

endmodule