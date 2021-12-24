`timescale 1ns / 1ps

`include "bus.v"
`include "opcode.v"

module RegGen(
  input       [`INST_OP_BUS]  op,
  input       [`REG_ADDR_BUS] rs,
  input       [`REG_ADDR_BUS] rt,
  input       [`REG_ADDR_BUS] rd,
  output  reg                 reg_read_en_1,
  output  reg                 reg_read_en_2,
  output  reg [`REG_ADDR_BUS] reg_addr_1,
  output  reg [`REG_ADDR_BUS] reg_addr_2,
  output  reg                 reg_write_en,
  output  reg [`REG_ADDR_BUS] reg_write_addr
);

  // generate read address
  always @(*) begin
    case (op)
      // arithmetic & logic (immediate)
      `OP_ADDIU,`OP_ADDI,
      `OP_LUI,`OP_ORI,
      `OP_XORI,
      `OP_ANDI,
      // memory accessing
      `OP_LB, `OP_LW, `OP_LBU: begin
        reg_read_en_1 <= 1;
        reg_read_en_2 <= 0;
        reg_addr_1 <= rs;
        reg_addr_2 <= 0;
      end
      // branch
      `OP_BEQ, `OP_BNE,`OP_BGTZ,`OP_BLEZ,`OP_REGIMM,
      // memory accessing
      `OP_SB,`OP_SH,`OP_SW,`OP_LWL,`OP_LWR,`OP_SWL,`OP_SWR,
      // r-type
      `OP_SPECIAL,`OP_SPECIAL2: begin
        reg_read_en_1 <= 1;
        reg_read_en_2 <= 1;
        reg_addr_1 <= rs;
        reg_addr_2 <= rt;
      end
      default: begin  // OP_JAL, OP_LUI
        reg_read_en_1 <= 0;
        reg_read_en_2 <= 0;
        reg_addr_1 <= 0;
        reg_addr_2 <= 0;
      end
    endcase
  end

  // generate write address
  always @(*) begin
    case (op)
      // immediate
      `OP_ADDIU, `OP_ADDI,
      `OP_LUI,`OP_ORI,
      `OP_XORI,
      `OP_ANDI
      : begin
        reg_write_en <= 1;
        reg_write_addr <= rt;
      end
      `OP_SPECIAL,`OP_SPECIAL2: begin
        reg_write_en <= 1;
        reg_write_addr <= rd;
      end
      `OP_JAL: begin
        reg_write_en <= 1;
        reg_write_addr <= 31;   // $ra (return address)
      end
      `OP_LB,`OP_LH,`OP_LW,`OP_LBU,`OP_LHU: begin
        reg_write_en <= 1;
        reg_write_addr <= rt;
      end
      `OP_REGIMM:begin
        if ( rt == `FUNCT_BLTZAL || rt == `FUNCT_BGEZAL ) begin
          reg_write_en <= 1;
          reg_write_addr <= 31;   // $ra (return address)          
        end
      end
      default: begin
        reg_write_en <= 0;
        reg_write_addr <= 0;
      end
    endcase
  end

endmodule // RegGen
