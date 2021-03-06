`timescale 1ns / 1ps

`include "bus.v"
`include "funct.v"

module EX(
  // from HILO stage
  input       [`DATA_BUS]         hi_read_data,
  input       [`DATA_BUS]         lo_read_data,
  // to HILO stage
  output      [`DATA_BUS]         hi_write_data,
  output      [`DATA_BUS]         lo_write_data,
  output                          hilo_write_en,
  // from ID stage
  input       [`FUNCT_BUS]        funct,
  input       [`SHAMT_BUS]        shamt,
  input       [`DATA_BUS]         operand_1,
  input       [`DATA_BUS]         operand_2,
  input                           mem_read_flag_in,
  input                           mem_write_flag_in,
  input                           mem_sign_flag_in,
  input       [`MEM_SEL_BUS]      mem_sel_in,
  input       [`DATA_BUS]         mem_write_data_in,
  input                           reg_write_en_in,
  input       [`REG_ADDR_BUS]     reg_write_addr_in,
  input       [`ADDR_BUS]         current_pc_addr_in,

  output                          stall_request,
  // cp0 signal
  input                           cp0_write_en_in,
  input                           cp0_read_en_in,
  input       [`CP0_ADDR_BUS]     cp0_addr_in,
  input       [`DATA_BUS]         cp0_write_data_in,
  input       [`DATA_BUS]         cp0_read_data_in,
  // exception signal
  input                           eret_flag_in,
  input                           syscall_flag_in,
  input                           break_flag_in,
  input                           delayslot_flag_in,

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
  output      [`ADDR_BUS]     current_pc_addr_out,
    // cp0 signal
  output                          cp0_write_en_out,
  output      [`DATA_BUS]         cp0_write_data_out,
  output      [`CP0_ADDR_BUS]     cp0_addr_out,
  // exception signal
  output                          eret_flag_out,
  output                          syscall_flag_out,
  output                          break_flag_out,
  output                          delayslot_flag_out
);

  wire mult_done , div_done;
  wire overflow_flag;
  wire add_en,mul_en,div_en,logic_en,hilo_en;
  wire[`DOUBLE_DATA_BUS] mult_result,div_result,mult_div_result;
  wire[`DATA_BUS] adder_result,logic_result,hilo_result;
  wire mult_div_done;
  reg [4:0] select;
  
  // to ID stage
  assign ex_load_flag = mem_read_flag_in;

  // to MEM stage
  assign mem_read_flag_out = mem_read_flag_in;
  assign mem_write_flag_out = mem_write_flag_in;
  assign mem_sign_flag_out = mem_sign_flag_in;
  assign mem_sel_out = mem_sel_in;
  assign mem_write_data_out = mem_write_data_in;

  // to WB stage
  assign reg_write_en_out = reg_write_en_in && ~mem_write_flag_in && ~overflow_flag ;
  assign reg_write_addr_out = reg_write_addr_in;
  assign current_pc_addr_out = current_pc_addr_in;

  assign stall_request = ~mult_div_done && ( div_en || mul_en );
  assign mult_div_done = ( div_en || mul_en ) && ( mult_done || div_done );
  
  // to cp0
  assign cp0_write_en_out = cp0_write_en_in;
  assign cp0_write_data_out = cp0_write_data_in;
  assign cp0_addr_out = cp0_addr_in;
  // exception
  assign eret_flag_out = eret_flag_in;
  assign syscall_flag_out = syscall_flag_in;
  assign break_flag_out = break_flag_in;
  assign delayslot_flag_out = delayslot_flag_in;

  initial begin
    select <= 5'b0;
  end


  assign { hilo_en,logic_en,div_en,mul_en,add_en } = select;

  Mux mux(
    .adder_result(adder_result),
    .mult_result(mult_result),
    .div_result(div_result),
    .hilo_result(hilo_result),
    .logic_reesult(logic_result),
    .select(select),
    .result(result),
    .mult_div_result(mult_div_result)
  );

  Adder adder(
    .funct(funct),
    .add_en(add_en),
    .operand_1(operand_1),
    .operand_2(operand_2),
    .result(adder_result),
    .overflow_flag(overflow_flag)
  );


  Multiplier multiplier(
    .mul_en(mul_en),
    .op1(operand_1),
    .op2(operand_2),
    .done(mult_done),
    .result_mul(mult_result)
  );

  Divider divider(
    .div_en(div_en),
    .operand_1(operand_1),
    .operand_2(operand_2),
    .done(div_done),
    .result(div_result)
  );

  Logic logic(
    .funct(funct),
    .shamt(shamt),
    .logic_en(logic_en),
    .operand_1(operand_1),
    .operand_2(operand_2),
    .result(logic_result)
  );

  Hilo_Gen hilo_gen(
    .funct(funct),
    .hilo_en(hilo_en),
    .mult_div_done(mult_div_done),
    .mult_div_result(mult_div_result),
    .hi_read_data(hi_read_data),
    .lo_read_data(lo_read_data),
    .operand_1(operand_1),
    .hi_write_data(hi_write_data),
    .lo_write_data(lo_write_data),
    .hilo_write_en(hilo_write_en),
    .result(hilo_result)
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
        // logic 
        `FUNCT_JALR, 
        `FUNCT_OR,`FUNCT_AND,`FUNCT_XOR,
        `FUNCT_SLT,`FUNCT_SLL ,`FUNCT_SLLV,`FUNCT_SRLV,`FUNCT_SRAV: select <= 5'b01000;
        // multiplier
        `FUNCT_MULT : select <= 5'b00010;
        // divider
        `FUNCT_DIV  : select <= 5'b00100;
        default: begin
          select <= 0;
        end
      endcase
  end

endmodule // EX
