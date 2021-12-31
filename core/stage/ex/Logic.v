module Logic (
  input       [`FUNCT_BUS]        funct,
  input                           logic_en,
  input       [`DATA_BUS]         operand_1,
  input       [`DATA_BUS]         operand_2,
  output      [`DATA_BUS]         result
);

  wire sub_result = operand_1 - operand_2;

  // flag of operand_1 < operand_2
  wire operand_1_lt_operand_2 = funct == `FUNCT_SLT ?
        // op1 is negative & op2 is positive
        ((operand_1[31] && !operand_2[31]) ||
          // op1 & op2 is positive, op1 - op2 is negative
          (!operand_1[31] && !operand_2[31] && sub_result [31]) ||
          // op1 & op2 is negative, op1 - op2 is negative
          (operand_1[31] && operand_2[31] && sub_result [31]))
          : (operand_1 < operand_2);

  always @(*) begin
    if ( logic_en ) begin
        case (funct)
            // jump with link & logic
            `FUNCT_JALR, `FUNCT_OR: result <= operand_1 | operand_2;
            `FUNCT_AND: result <= operand_1 & operand_2;
            `FUNCT_XOR: result <= operand_1 ^ operand_2;
            // comparison
            `FUNCT_SLT, `FUNCT_SLTU: result <= {31'b0, operand_1_lt_operand_2};
                // shift
            `FUNCT_SLL: result <= operand_2 << shamt;
            `FUNCT_SLLV: result <= operand_2 << operand_1[4:0];
            `FUNCT_SRLV: result <= operand_2 >> operand_1[4:0];
            `FUNCT_SRAV: result <= ({32{operand_2[31]}} << (6'd32 - {1'b0, operand_1[4:0]})) | operand_2 >> operand_1[4:0];
        endcase
    end
    else begin
        result <= 0;
    end
  end

endmodule
