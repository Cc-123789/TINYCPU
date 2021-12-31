`include "bus.v"

module mux(
    input      [`DATA_BUS]    adder_result,
    input      [`DATA_BUS]    Multiplier_result,
    input      [`DATA_BUS]    divider_reesult,
    input      [`DATA_BUS]    logic_reesult,
    input      [3:0]          select,
    output reg [`DATA_BUS]    result
);

    always @(*) begin
        case( select )
            4'b0001 : result <= adder_result;
            4'b0010 : result <= adder_result;
            4'b0100 : result <= divider_reesult;
            4'b1000 : result <= logic_reesult;
            default : begin
                result <= `DATA_BUS_WIDTH'b0;
            end
        endcase        
    end

endmodule