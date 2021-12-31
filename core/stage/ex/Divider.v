module Divider (
  input       [`FUNCT_BUS]        funct,
  input                           div_en,
  input       [`DATA_BUS]         operand_1,
  input       [`DATA_BUS]         operand_2,
  output      [`DATA_BUS]         result
);

  /** 函数pos：确定操作数有效位数   ***/
  function [4:0] pos;
    input [31:0] op_div_1;
    reg [15:0] sel1;
    reg [ 7:0] sel2;
    reg [ 3:0] sel3;
    reg [ 2:0] sel4;
    begin
    if(|op_div_1[31:16] == 0) begin
      pos[4] = 0;
      sel1 = op_div_1[15:0];
      end
    else begin
      pos[4] = 1;
      sel1 = op_div_1[31:16];
    end
    if(|sel1[15:8] == 1'b0) begin
      pos[3] = 0;
      sel2 = sel1[7:0];
    end
    else begin
      pos[3] = 1;
      sel2 = sel1[15:8];
    end
    if(|sel2[7:4] == 1'b0) begin
      pos[2] = 0;
      sel3 = sel2[3:0];
    end
    else begin
      pos[2] = 1;
      sel3 = sel2[7:4];
    end
    if(|sel3[3:2] == 1'b0) begin
      pos[1] = 0;
      sel4 = sel3[1:0];
    end
    else begin
      pos[1] = 1;
      sel4 = sel3[3:2];
    end
    if(|sel4[1] == 1'b0) begin
      pos[0] = 0;                             
    end
    else begin
      pos[0] = 1;
    end
  end
  endfunction

  //if negative, complement of operand_1& operand_2
  wire[`DATA_BUS] op1_c = (~operand_1) + 1;
  wire[`DATA_BUS] op2_c = (~operand_2) + 1;

  wire [`REG_ADDR_BUS] div_shift_cnt;//记录移位数
  wire [`DATA_BUS] div_quo = 0;//商，初值为0
  wire [`DATA_BUS] div_rem = op_div_1;//余数，初值为被除数
  wire [`DATA_BUS] div_temp = 0;//暂存中间结果
  wire[`REG_ADDR_BUS] n_1;
  wire[`REG_ADDR_BUS] n_2;

  //被除数：若为有符号乘法且该乘数为负数，则取其补码，否则不变
  wire[`DATA_BUS] op_div_1 = 
          (funct == `FUNCT_DIV && operand_1[31])?
          op1_c : operand_1;
  //除数
  wire[`DATA_BUS] op_div_2 = 
          (funct == `FUNCT_DIV && operand_2[31])?
          op2_c : operand_2;
          
  assign n_1 = pos(op_div_1);
  assign n_2 = pos(op_div_2);


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

endmodule
