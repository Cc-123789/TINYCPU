`timescale 1ns / 1ps

`include "bus.v"
`include "funct.v"

module EX(
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

  reg[`DATA_BUS] HI;
  reg[`DATA_BUS] LO;
  initial begin
      HI <= 0;
      LO <= 0;
  end
  // calculate the complement of operand_2
  wire[`DATA_BUS] operand_2_mux =
      (funct == `FUNCT_SUBU || funct == `FUNCT_SLT || funct == `FUNCT_SUB)
        ? (~operand_2) + 1 : operand_2;

  //if negative, complement of operand_1& operand_2
  wire[`DATA_BUS] op1_c = (~operand_1) + 1;
  wire[`DATA_BUS] op2_c = (~operand_2) + 1;

  // sum of operand_1 & operand_2
  wire[`DATA_BUS] result_sum = operand_1 + operand_2_mux;

  // overflow flag of operand_1 +/- operand_2
  wire overflow_flag = 
        funct == (`FUNCT_ADD || `FUNCT_ADDI || `FUNCT_SUB)?
          // op1 & op2 is positive, op1 + op2 is negative
          ((!operand_1[31] && !operand_2[31] && result_sum[31]) ||
          // op1 & op2 is negative, op1 + op2 is negative
          (operand_1[31] && operand_2[31] && !result_sum[31])) :0;

  // flag of operand_1 < operand_2
  wire operand_1_lt_operand_2 = funct == `FUNCT_SLT ?
        // op1 is negative & op2 is positive
        ((operand_1[31] && !operand_2[31]) ||
          // op1 & op2 is positive, op1 - op2 is negative
          (!operand_1[31] && !operand_2[31] && result_sum[31]) ||
          // op1 & op2 is negative, op1 - op2 is negative
          (operand_1[31] && operand_2[31] && result_sum[31]))
      : (operand_1 < operand_2);

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

  //(mult)temporary product of operand_1 & operand_2
  wire[`DOUBLE_DATA_BUS] result_mul_temp = op_mul_1 * op_mul_2 ;
  
  wire[`DOUBLE_DATA_BUS] result_mul;
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

    /*****************
    ** DIV/DIVU   ***
    ******************/

  wire [`REG_ADDR_BUS] div_shift_cnt;//记录移位数
  wire [`DATA_BUS] div_quo = 0;//商，初值为0
  wire [`DATA_BUS] div_rem = op_div_1;//余数，初值为被除数
  wire [`DATA_BUS] div_temp = 0;//暂存中间结果
  
  //被除数：若为有符号乘法且该乘数为负数，则取其补码，否则不变
  wire[`DATA_BUS] op_div_1 = 
          (funct == `FUNCT_DIV && operand_1[31])?
          op1_c : operand_1;
  //除数
  wire[`DATA_BUS] op_div_2 = 
          (funct == `FUNCT_DIV && operand_2[31])?
          op2_c : operand_2;

  always @(*) begin
    wire[`REG_ADDR_BUS] n_1 = 32'h11111111;
    wire[`REG_ADDR_BUS] n_2 = 32'h11111111;
    while (!op_div_1[n_1]) begin
      n_1 = n_1-1;
    end
    while (!op_div_2[n_2]) begin
      n_2 = n_2-1;
    end
  end

  div_shift_cnt = n_1 - n_2;

always @(*) begin
  if (op_div_1 < op_div_2) begin
    div_quo = 0;
    div_rem = op_div_2;
  end
  else if (op_div_1 == op_div_2) begin
    div_quo = 1;
    div_rem = 0;
  end
  //除法移位实现
  else begin
    if (n_1 == n_2)begin
      div_quo = 1;
      div_rem = op_div_1 - op_div_2;
    end
    else 
      while (n_1 > n_2)begin
        div_temp = div_rem - (op_div_2 << div_shift_cnt)
        //余数 > 移位后的数
        if (!div_temp[31]) begin
            div_quo = div_quo + (1 << div_shift_cnt);
            div_rem = div_temp;
            div_shift_cnt = div_shift_cnt - 1;
        end
        else begin
          break;
        end
    end
  end
end

  //correct
always @(*) begin
    if(funct == (`FUNCT_DIV) begin
      if(operand_1[31] ^ operand_2[31] == 1'b1) begin
          div_quo = ~div_quo + 1'b1;
      end
      else begin
          div_quo = div_quo;
      end
      if(operand_2[31])begin
        div_rem = ~div_rem + 1'b1;
      end
      else begin
        div_rem = div_rem;
      end
    end
    else begin
        div_quo = div_quo;
        div_rem = div_rem;
    end
  end

 /*****************
    ** 结束乘除运算   ***
    ******************/

  // calculate result
  always @(*) begin
    case (funct)
      // jump with link & logic
      `FUNCT_JALR, `FUNCT_OR: result <= operand_1 | operand_2;
      `FUNCT_AND: result <= operand_1 & operand_2;
      `FUNCT_XOR: result <= operand_1 ^ operand_2;
      // comparison
      `FUNCT_SLT, `FUNCT_SLTU: result <= {31'b0, operand_1_lt_operand_2};
      // arithmetic
      `FUNCT_ADD,`FUNCT_ADDU, 
      `FUNCT_SUB,`FUNCT_SUBU: result <= result_sum;
      `FUNCT_MULT,`FUNCT_MULTU: 
          HI <= result_mul[63:32];
          LO <= result_mul[31:0];
      `FUNCT_DIV,`FUNCT_DIVU: 
          HI <= div_rem;
          LO <= div_quo;
      // shift
      `FUNCT_SLL: result <= operand_2 << shamt;
      `FUNCT_SLLV: result <= operand_2 << operand_1[4:0];
      `FUNCT_SRLV: result <= operand_2 >> operand_1[4:0];
      `FUNCT_SRAV: result <= ({32{operand_2[31]}} << (6'd32 - {1'b0, operand_1[4:0]})) | operand_2 >> operand_1[4:0];
      default: result <= 0;
    endcase
  end

endmodule // EX
