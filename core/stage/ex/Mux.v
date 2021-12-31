`include "bus.v"

module mux(
    input      [`DATA_BUS]    adder_result,
    input      [`DATA_BUS]    multiplier_result,
    input      [`DATA_BUS]    divider_reesult,
    input      [`DATA_BUS]    logic_reesult,
    input      [4:0]          select,
    output     [`DATA_BUS]    result
);

    always @(*) begin
        case( select )
            5'b00001 : result <= adder_result;
            5'b00010 : result <= multiplier_result;
            5'b00100 : result <= divider_reesult;
            5'b01000 : result <= logic_reesult;
            default : begin
                result <= `DATA_BUS_WIDTH'b0;
            end
        endcase        
    end

endmodule