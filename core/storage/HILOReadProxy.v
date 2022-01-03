`include "bus.v"

module HILOReadProxy(
    input [`DATA_BUS] hi_input_data,
    input [`DATA_BUS] lo_input_data,
    input [`DATA_BUS] mem_hilo_write_en,
    input [`DATA_BUS] mem_hi_write_data,
    input [`DATA_BUS] mem_lo_write_data,
    input wb_hilo_write_en,
    input [`DATA_BUS] wb_hi_write_data,
    input [`DATA_BUS] wb_lo_write_data,
    output [`DATA_BUS] hi_output_data,
    output [`DATA_BUS] lo_output_data
);

    assign hi_output_data = mem_hilo_write_en ? mem_hi_write_data :
                        wb_hilo_write_en ? wb_hi_write_data :
                        hi_input_data;
    assign lo_output_data = mem_hilo_write_en ? mem_lo_write_data :
                        wb_hilo_write_en ? wb_lo_write_data :
                        lo_input_data;

endmodule