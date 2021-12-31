`include "bus.v"

module mux(
    input      [`DATA_BUS]          adder_result,
    input      [`DATA_BUS]          logic_reesult,
    input      [`DATA_BUS]          hilo_result,
    input      [`DOUBLE_DATA_BUS]   mult_result,
    input      [`DOUBLE_DATA_BUS]   div_result,
    input      [4:0]                select,
    output     [`DATA_BUS]          result,
    output     [`DOUBLE_DATA_BUS]   mult_div_result
);

    always @(*) begin
        case( select )
            5'b00001 : result <= adder_result;
            5'b00010 : mult_div_result <= mult_result;
            5'b00100 : mult_div_result <= div_result;
            5'b01000 : result <= logic_reesult;
            5'b10000 : result <= hilo_result;
            default : begin
                result <= 0;
                mult_div_result <= 0;
            end
        endcase        
    end

endmodule