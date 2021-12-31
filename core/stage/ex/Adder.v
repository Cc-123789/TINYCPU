
`include "bus.v"
`include "funct.v"

module Adder(
  input       [`FUNCT_BUS]    funct,
  input       add_en,
  input       [`DATA_BUS]     operand_1,
  input       [`DATA_BUS]     operand_2,
  output      reg [`DATA_BUS]     result,
);


  always @(*) begin
      if (add_en) begin
        operand_2 = (funct == `FUNCT_SUBU || funct == `FUNCT_SUB ) ? (~operand_2) + 1 : operand_2;
        result = operand_1 + operand_2;          
      end
      else begin
        result <= `DATA_BUS_WIDTH'b0;
      end
  end  

endmodule