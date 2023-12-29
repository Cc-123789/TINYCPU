// 设置时间单位和时间精度为1皮秒
`timescale 1ps / 1ps

// 引入外部文件 "bus.v"，可能包含总线相关的定义和逻辑
`include "bus.v"

// Mycpu_top 模块的定义，包括输入和输出信号
module Mycpu_top (
    input clk,               // 时钟信号
    input rst,               // 复位信号
    input  [7:0]  switch,   // 开关输入信号
    input  [4:0]  btn,      // 按钮输入信号
    output [7:0] led,       // LED输出信号
    output [7:0] small_led, // 辅助LED输出信号
    output [7:0] pos,       // 位置输出信号
    output [7:0] seg_code_0, // 七段数码管段码输出信号
    output [7:0] seg_code_1
);

  wire                  stall;               // 阻塞信号
  // ROM 控制信号
  wire                  rom_en;              // ROM 使能信号
  wire  [`ADDR_BUS]     rom_addr;            // ROM 地址信号
  wire  [`DATA_BUS]     rom_read_data;       // 从 ROM 读取的数据信号
  // RAM 控制信号
  wire                  ram_en;              // RAM 使能信号
  wire  [`MEM_SEL_BUS]  ram_write_en;        // RAM 写使能信号
  wire  [`ADDR_BUS]     ram_addr;            // RAM 地址信号
  wire   [`DATA_BUS]    ram_read_data;       // 从 RAM 读取的数据信号
  wire  [`DATA_BUS]     ram_write_data;      // 写入 RAM 的数据信号
  // 调试信号
    wire [`DATA_BUS] debug_pc;               // 调试程序计数器
    wire [`DATA_BUS] debug_operand_1;       // 调试操作数1
    wire [`DATA_BUS] debug_operand_2;       // 调试操作数2
    wire [`DATA_BUS] debug_branch_addr;      // 调试分支地址
    wire [`DATA_BUS] debug_wb_result;       // 调试写回结果
    wire [`DATA_BUS] debug_hi_read_data;    // 调试高位读取数据
    wire [`DATA_BUS] debug_lo_read_data;    // 调试低位读取数据
    wire [`DATA_BUS] debug_ifid_inst;       // 调试指令存储器/译码器输出
    
    wire [`DATA_BUS] data;                  // 数据信号

    //reg[31:0] data;
            
    assign rst_not = ~rst;                  // 复位信号的反相
    assign small_led = { {3{1'b0}}, btn };   // 将按钮输入信号连接到辅助LED
    
    // 实例化数码管显示模块
    Digic_led digic_led(
        .clk   (clk),
        .rst   (rst_not),
        .data  (data),
        .seg_code_0 (seg_code_0),
        .seg_code_1 (seg_code_1),       
        .pos   (pos)
    );

    // 实例化开关与LED连接模块
    Switch_led switch_led(
        .clk        (clk),
        .rst        (rst_not),
        .switch     (switch),
        .led        (led)      
    );
    
    // 实例化阻塞按钮检测模块
    Stall_btn stall_btn(
        .clk        (clk),
        .rst        (rst_not),
        .btn2       (btn[1]),
        .stall      (stall)       
    );
    
    // 实例化 5:1 多路选择器，选择不同的调试信号
    mux_5to1 data_mux_5to1(
        .debug_pc(debug_pc),
        .debug_operand_1(debug_operand_1),
        .debug_operand_2(debug_operand_2),
        .debug_branch_addr(debug_branch_addr),
        .debug_wb_result(debug_wb_result),
        .debug_hi_read_data(debug_hi_read_data),
        .debug_lo_read_data(debug_lo_read_data),
        .debug_ifid_inst(debug_ifid_inst),
        .select (switch),
        .result (data)  
    );

assign rom_en = ~rst_not;                   // ROM 使能信号与复位信号反相

// 实例化 ROM 模块
ROM rom(
  .clk(clk),
  .rst(rst_not),
  .rom_en(rom_en),
  .rom_addr(rom_addr),
  .rom_read_data(rom_read_data)
);

// 实例化 RAM 模块
RAM ram(
  .clk(clk),
  .ram_en(ram_en),
  .ram_write_en(ram_write_en),
  .ram_addr(ram_addr),
  .ram_write_data(ram_write_data),
  .ram_read_data(ram_read_data)
);

// 实例化核心处理器模块
Core core(
    .clk(clk),
    .rst(rst_not),
    .stall(stall),
    // ROM 控制信号
    .rom_addr(rom_addr),
    .rom_read_data(rom_read_data),
    // RAM 控制信号
    .ram_en(ram_en),
    .ram_write_en(ram_write_en),
    .ram_addr(ram_addr),
    .ram_read_data(ram_read_data),
    .ram_write_data(ram_write_data),
    // 调试信号
    .debug_pc(debug_pc),
    .debug_operand_1(debug_operand_1),
    .debug_operand_2(debug_operand_2),
    .debug_branch_addr(debug_branch_addr),
    .debug_wb_result(debug_wb_result),
    .debug_hi_read_data(debug_hi_read_data),
    .debug_lo_read_data(debug_lo_read_data),
    .debug_ifid_inst(debug_ifid_inst)
);

endmodule
