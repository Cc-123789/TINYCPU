`timescale 1ns / 1ps

`include "bus.v"
`include "funct.v"

module EX(
  // from HILO stage
  input       [`DATA_BUS]     hi_read_data,
  input       [`DATA_BUS]     lo_read_data,
  // to HILO stage
  output      [`DATA_BUS]     hi_write_data,
  output      [`DATA_BUS]     lo_write_data,
  output                      hilo_write_en,
  // from ID stage
  input       [`FUNCT_BUS]    funct,
  input       [`SHAMT_BUS]    shamt,
  input       [`DATA_BUS]     operand_1,
  input       [`DATA_BUS]     operand_2,
  input                       mem_read_flag_in,
  input                       mem_write_flag_in,
  input                       mem_sign_flag_in,
  input       [`MEM_SEL_BUS]  mem_sel_in,
  input       [`DATA_BUS]     mem_write_data_in,
  input                       reg_write_en_in,
  input       [`REG_ADDR_BUS] reg_write_addr_in,
  input       [`ADDR_BUS]     current_pc_addr_in,
  // to ID stage (solve data hazards)
  output                      ex_load_flag,
  // to MEM stage
  output                      mem_read_flag_out,
  output                      mem_write_flag_out,
  output                      mem_sign_flag_out,
  output      [`MEM_SEL_BUS]  mem_sel_out,
  output      [`DATA_BUS]     mem_write_data_out,
  // to WB stage
  output      [`DATA_BUS]     result,
  output                      reg_write_en_out,
  output      [`REG_ADDR_BUS] reg_write_addr_out,
  output      [`ADDR_BUS]     current_pc_addr_out
);

  // to ID stage
  assign ex_load_flag = mem_read_flag_in;

  // to MEM stage
  assign mem_read_flag_out = mem_read_flag_in;
  assign mem_write_flag_out = mem_write_flag_in;
  assign mem_sign_flag_out = mem_sign_flag_in;
  assign mem_sel_out = mem_sel_in;
  assign mem_write_data_out = mem_write_data_in;

  // to WB stage
  assign reg_write_en_out = reg_write_en_in && !mem_write_flag_in && !overflow_flag;
  assign reg_write_addr_out = reg_write_addr_in;
  assign current_pc_addr_out = current_pc_addr_in;


  // overflow flag of operand_1 +/- operand_2
  wire overflow_flag = 
        funct == (`FUNCT_ADD || `FUNCT_ADDI || `FUNCT_SUB)?
          // op1 & op2 is positive, op1 + op2 is negative
          ((!operand_1[31] && !operand_2[31] && result[31]) ||
          // op1 & op2 is negative, op1 + op2 is negative
          (operand_1[31] && operand_2[31] && !result[31])) :0;

  assign hilo_write_en = ( funct == `FUNCT_MTHI || funct == `FUNCT_MTLO ) ? 1 : 0;

  reg [4:0] select；

  initial begin
    select <= 5'b0;
  end

  MUX mux(
    .adder_result(adder_result),
    .multiplier_result(multiplier_result),
    .divider_reesult(divider_reesult),
    .logic_reesult(logic_reesult),
    .select(select),
    .result(result)
  );

  Adder adder(
    .funct(funct),
    .add_en(add_en),
    .operand_1(operand_1),
    .operand_2(operand_2),
    .result(adder_result)
  );


  Multiplier multiplier(
    .funct(funct),
    .mul_en(mul_en),
    .operand_1(operand_1),
    .operand_2(operand_2),
    .result(multiplier_result)
  );

  Divider divider(
    .funct(funct),
    .div_en(div_en),
    .operand_1(operand_1),
    .operand_2(operand_2),
    .result(divider_reesult)
  );

  Logic logic(
    .funct(funct)
    .logic_en(logic_en)
    .operand_1(operand_1)
    .operand_2(operand_2)
    .result(logic_reesult)
  );
 
 // calculate result
  always @(*) begin
    case (funct)
      // arithmetic
      `FUNCT_ADD,`FUNCT_ADDU, 
      `FUNCT_SUB,`FUNCT_SUBU:  select <= 5'b00001;
      // HILO
      `FUNCT_MFHI,`FUNCT_MFLO,
      `FUNCT_MTHI,`FUNCT_MTLO: select <= 5'b10000;
      default: begin
        result <= 0;
      end
    endcase
  end
  
endmodule // EX
