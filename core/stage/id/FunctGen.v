`timescale 1ns / 1ps

`include "bus.v"
`include "opcode.v"
`include "funct.v"

module FunctGen(
  input       [`INST_OP_BUS]  op,
  input       [`FUNCT_BUS]    funct_in,
  output  reg [`FUNCT_BUS]    funct
);

  // generating FUNCT signal in order for the ALU to perform operations
  always @(*) begin
    case (op)
      `OP_SPECIAL,`OP_SPECIAL2: funct <= funct_in;
      `OP_LUI,`OP_ORI: funct <= `FUNCT_OR;
      `OP_XORI: funct <= `FUNCT_XOR;
      `OP_ANDI: funct <= `FUNCT_AND;
      `OP_SB, `OP_SW, `OP_ADDIU, `OP_ADDI
      `OP_LBU, `OP_LHU, 
      `OP_LB, `OP_LH, `OP_LW : funct <= `FUNCT_ADDU;
      `OP_JAL,`OP_J,`OP_BEQ,`OP_BNE,`OP_BGTZ,`OP_BLEZ,`OP_REGIMM: funct <= `FUNCT_OR;
      default: funct <= `FUNCT_NOP;
    endcase
  end

endmodule // FunctGen
