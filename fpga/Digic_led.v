// 设置时间单位和时间精度为1皮秒
`timescale 1ps / 1ps

// Digic_led 模块的定义，用于控制数码管显示
module Digic_led(
    input clk,                 // 输入时钟信号
    input rst,                 // 输入复位信号
    input [31:0] data,         // 输入数据信号（32位）
    output [7:0] seg_code_0,   // 输出数码管0的段码
    output [7:0] seg_code_1,   // 输出数码管1的段码
    output reg [7:0] pos       // 输出位置信号
);

    reg digic_sig;             // 数码管信号
    wire clk_bps;              // 时钟信号的1/2倍频率
    reg[7:0] next_pos;         // 下一个位置信号

    reg[3:0]  temp_data_0, temp_data_1;  // 临时数据信号

    // 实例化数码管段控制模块（两个数码管）
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

    // 实例化计数器模块
    Counter counter(
        .clk        (clk),
        .rst        (rst),
        .clk_bps    (clk_bps)
    );

	// 时序逻辑：根据时钟和复位信号更新数码管控制信号和位置信号
    always @( posedge clk or posedge rst )
        if( rst ) begin
            pos <= 8'hff;             // 复位时，位置信号设置为最大值
            next_pos <= 8'hff;         // 下一个位置信号也设置为最大值
            digic_sig <= 1'b1;         // 数码管信号设置为1
            temp_data_0 <= 4'hf;       // 临时数据信号设置为高电平
            temp_data_1 <= 4'hf;       // 临时数据信号设置为高电平
        end
        else if ( digic_sig ) begin
            pos <= 8'h11;             // 复位后，位置信号设置为初始值
            next_pos <= 8'h22;        // 下一个位置信号设置为初始值
            temp_data_0 <= data[31:28]; // 临时数据信号从输入数据的高位获取
            temp_data_1 <= data[15:12]; // 临时数据信号从输入数据的中高位获取
            digic_sig <= 1'b0;         // 数码管信号设置为0
        end
        else if ( clk_bps ) begin
            pos <= pos << 1'b1;        // 位置信号左移1位
            next_pos <= next_pos << 1'b1; // 下一个位置信号左移1位
            case( next_pos )
                8'h11:begin
                    temp_data_0 <= data[31:28]; // 根据位置信号选择相应的数据位
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
                    temp_data_0 <= 4'hf;       // 默认情况下，临时数据信号设置为高电平
                    temp_data_1 <= 4'hf;                        
                end
            endcase                
        end
        else if ( next_pos == 8'h10) begin
            next_pos <= 8'h11;        // 当下一个位置信号达到10时，将其设置为11
        end
        else if ( pos == 8'h10 ) begin
            pos <= 8'h11;             // 当位置信号达到10时，将其设置为11
        end
        else begin
            temp_data_0 <= temp_data_0; // 其他情况下，临时数据信号不变
            temp_data_1 <= temp_data_1;
        end  

endmodule
