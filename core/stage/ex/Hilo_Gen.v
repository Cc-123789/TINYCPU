module Hilo_Gen (
  input       [`FUNCT_BUS]    funct,
  input                       hilo_en,
  // from HILO stage
  input       [`DATA_BUS]     hi_read_data,
  input       [`DATA_BUS]     lo_read_data,
  input       [`DATA_BUS]     operand_1,
  // to HILO stage
  output      [`DATA_BUS]     hi_write_data,
  output      [`DATA_BUS]     lo_write_data,
  output                      hilo_write_en,
  output      [`DATA_BUS]     result
);

 // calculate result
  always @(*) begin
      if ( hilo_en ) begin
        case (funct)
            `FUNCT_MFHI: begin
                hilo_write_en <= 0;
                result <= hi_read_data;
            end
            `FUNCT_MFLO: begin:
                hilo_write_en <= 0;
                result <= lo_read_data;            
            end
            `FUNCT_MTHI: begin
                hilo_write_en <= 1;
                hi_write_data <= operand_1;
                lo_write_data <= lo_read_data;
                result <= 0;
            end
            `FUNCT_MTLO: begin
                hilo_write_en <= 1;
                hi_write_data <= hi_read_data;
                lo_write_data <= operand_1;
                result <= 0;
            end
        endcase
      end
      else begin
        hi_write_data <= 0;
        lo_write_data <= 0;
        hilo_write_en <= 0;
        result <= 0;
      end
  end
endmodule
