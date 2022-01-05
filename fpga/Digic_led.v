`timescale 1ps / 1ps

module Digic_led(
    input clk,
    input rst,
    input [31:0] data,
	output [7:0] seg_code_0,
	output [7:0] seg_code_1,
    output reg [7:0] pos
);

    reg digic_sig;
    wire clk_bps;
    reg[7:0] next_pos;

    reg[3:0]  temp_data_0,temp_data_1;

    Digic_seg digic_seg_0(
        .clk        (clk),
        .rst        (rst),
        .data       (temp_data_0),
        .seg_code   (seg_code_0)
    );
    
    Digic_seg digic_seg_1(
        .clk        (clk),
        .rst        (rst),
        .data       (temp_data_1),
        .seg_code   (seg_code_1)
    );

    Counter counter(
        .clk        (clk),
        .rst        (rst),
        .clk_bps    (clk_bps)
    );

	always @( posedge clk or posedge rst )
        if( rst ) begin
            pos <= 8'hff;
            next_pos <= 8'hff;
            digic_sig <= 1'b1; 
            temp_data_0 <= 4'hf;
            temp_data_1 <= 4'hf;           
        end
        else if ( digic_sig ) begin
            pos <= 8'h11;
            next_pos <= 8'h22;
            temp_data_0 <= data[31:28];
            temp_data_1 <= data[15:12];
            digic_sig <= 1'b0;            
        end
        else if ( clk_bps ) begin
            pos <= pos << 1'b1;
            next_pos <= next_pos << 1'b1;
            case( next_pos )
                8'h11:begin
                    temp_data_0 <= data[31:28];
                    temp_data_1 <= data[15:12];
                end
                8'h22:begin 
                    temp_data_0 <= data[27:24];
                    temp_data_1 <= data[11:8];
                end                    
                8'h44: begin
                    temp_data_0 <= data[23:20];
                    temp_data_1 <= data[7:4];
                end
                8'h88:begin
                    temp_data_0 <= data[19:16];
                    temp_data_1 <= data[3:0];                        
                end                   
                default:begin
                    temp_data_0 <= 4'hf;
                    temp_data_1 <= 4'hf;                        
                end
            endcase                
        end
        else if ( next_pos == 8'h10) begin
            next_pos <= 8'h11;
        end
        else if ( pos == 8'h10 ) begin
            pos <= 8'h11;
        end
        else begin
            temp_data_0 <= temp_data_0;
            temp_data_1 <= temp_data_1;
        end  


endmodule