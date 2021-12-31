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
  output  reg [`DATA_BUS]     result,
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

  // calculate result
  always @(*) begin
    case (funct)
      // arithmetic
      `FUNCT_ADD,`FUNCT_ADDU, 
      `FUNCT_SUB,`FUNCT_SUBU: result <= result_sum;
      // HILO
      `FUNCT_MFHI: result <= hi_read_data;
      `FUNCT_MFLO: result <= hi_read_data;
      `FUNCT_MTHI: begin
        hi_write_data <= operand_1;
        lo_write_data <= lo_read_data;
        result <= 0;
      end
      `FUNCT_MTLO: begin
        hi_write_data <= hi_read_data;
        lo_write_data <= operand_1;
        result <= 0;
      end
      default: begin
        result <= 0;
      end
    endcase
  end



endmodule // EX
