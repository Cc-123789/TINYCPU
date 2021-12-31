module Hilo_Gen (
  input       [`FUNCT_BUS]    funct,
  input                       hilo_en,
  // from HILO stage
  input       [`DATA_BUS]     hi_read_data,
  input       [`DATA_BUS]     lo_read_data,
  // to HILO stage
  output      [`DATA_BUS]     hi_write_data,
  output      [`DATA_BUS]     lo_write_data,
  output                      hilo_write_en
);

 // calculate result
  always @(*) begin
      if ( hilo_en ) begin
        case (funct)
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
        endcase
      end
      else begin
          result <= 0;
      end
  end
endmodule
