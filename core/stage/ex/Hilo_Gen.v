`include "bus.v"
`include "funct.v"

module Hilo_Gen (
  input       [`FUNCT_BUS]    funct,
  input                       hilo_en,
  input                       mult_div_done,
  // from HILO stage
  input       [`DOUBLE_DATA_BUS]  mult_div_result,
  input       [`DATA_BUS]     hi_read_data,
  input       [`DATA_BUS]     lo_read_data,
  input       [`DATA_BUS]     operand_1,
  // to HILO stage
  output  reg    [`DATA_BUS]     hi_write_data,
  output  reg    [`DATA_BUS]     lo_write_data,
  output  reg                    hilo_write_en,
  output  reg    [`DATA_BUS]     result
);

 // calculate result
  always @(*) begin
      if ( hilo_en ) begin
        case (funct)
            `FUNCT_MFHI: begin
                hilo_write_en <= 0;
                result <= hi_read_data;
            end
            `FUNCT_MFLO: begin
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
      else if ( mult_div_done ) begin
      hilo_write_en <= 1;
      hi_write_data <= mult_div_result[63:32];
      lo_write_data <= mult_div_result[31:0];
    end
      else begin
        hilo_write_en <= 0;
        hi_write_data <= 0;
        lo_write_data <= 0;
        result <= 0;
      end
  end
endmodule
