module HILOReadProxy(
    input hi_input_data,
    input lo_input_data,
    input mem_hilo_write_en,
    input mem_hi_write_data,
    input mem_lo_write_data,
    input wb_hilo_write_en,
    input wb_hi_write_data,
    input wb_lo_write_data，
    output hi_output_data,
    output lo_output_data
);

    assign hi_output_data = mem_hilo_write_en ? mem_hi_i :
                        wb_hilo_write_en ? wb_hi_i :
                        hi_input_data;
    assign lo_output_data = mem_hilo_write_en ? mem_lo_i :
                        wb_hilo_write_en ? wb_lo_i :
                        lo_input_data;

endmodule