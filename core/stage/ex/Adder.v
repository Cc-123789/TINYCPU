
`include "bus.v"
`include "funct.v"

module Adder(
  input       [`FUNCT_BUS]    funct,
  input       add_en,
  input       [`DATA_BUS]     operand_1,
  input       [`DATA_BUS]     operand_2,
  output  reg [`DATA_BUS]     result,
  output                      overflow_flag
);

 assign overflow_flag = 
          // op1 & op2 is positive, op1 + op2 is negative
          (!operand_1[31] && !operand_2[31] && result[31]) ||
          // op1 & op2 is negative, op1 + op2 is positive
          (operand_1[31] && operand_2[31] && !result[31]) ;

  wire op2;
  assign op2 = ( funct == `FUNCT_SUBU || funct == `FUNCT_SUB ) ? (~operand_2) + 1 : operand_2;
  
  always @(*) begin
      if (add_en) begin
        result = operand_1 + op2;          
      end
      else begin
        result <= 0;
      end
  end  

endmodule