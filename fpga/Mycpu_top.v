`timescale 1ps / 1ps

`include "bus.v"

module Mycpu_top (
    input clk,
    input rst,
 	input  [7:0]  switch,
 	output [7:0] led,
    output [7:0] pos,
    output [7:0] seg_code_0,
    output [7:0] seg_code_1
);

    //测试数据
    reg[31:0] data;
    always @(posedge clk or posedge rst)
        if (rst) 
            data <= 32'habcd_ef12;
        else
            data <= 32'h0000_0010;
            
    assign rst_not = ~rst;
    
	//数码管显示数据，可以显示三十二位数据，data必须为32位
    Digic_led digic_led(
        .clk   (clk),
        .rst   (rst_not),
        .data  (data),
        .seg_code_0 (seg_code_0),
        .seg_code_1 (seg_code_1),       
        .pos   (pos)
    );

	//拨码开关,一开灯就亮
    Switch_led switch_led(
        .clk        (clk),
        .rst        (rst_not),
        .switch     (switch),
        .led        (led)      
    );
    

  reg                   stall;
  // ROM control
  wire                  rom_en;
  wire  [`ADDR_BUS]     rom_addr;
  wire  [`DATA_BUS]     rom_read_data;
  // RAM control
  wire                  ram_en;
  wire  [`MEM_SEL_BUS]  ram_write_en;
  wire  [`ADDR_BUS]     ram_addr;
  wire   [`DATA_BUS]    ram_read_data;
  wire  [`DATA_BUS]     ram_write_data;
  // debug signals
  wire                  debug_reg_write_en;
  wire  [`REG_ADDR_BUS] debug_reg_write_addr;
  wire  [`DATA_BUS]     debug_reg_write_data;
  wire  [`ADDR_BUS]     debug_pc_addr;

assign rom_en = ~rst;

ROM rom(
  .clk(clk),
  .rst(rst_not),
  .rom_en(rom_en),
  .rom_addr(rom_addr),
  .rom_read_data(rom_read_data)
);


RAM ram(
  .clk(clk),
  .ram_en(ram_en),
  .ram_write_en(ram_write_en),
  .ram_addr(ram_addr),
  .ram_write_data(ram_write_data),
  .ram_read_data(ram_read_data)
);

Core core(
    .clk(clk),
    .rst(rst_not),
    .stall(stall),
    //ROMcontrol
    .rom_addr(rom_addr),
    .rom_read_data(rom_read_data),
    //RAMcontrol
    .ram_en(ram_en),
    .ram_write_en(ram_write_en),
    .ram_addr(ram_addr),
    .ram_read_data(ram_read_data),
    .ram_write_data(ram_write_data),
    //debugsignals
    .debug_reg_write_en(debug_reg_write_en),
    .debug_reg_write_addr(debug_reg_write_addr),
    .debug_reg_write_data(debug_reg_write_data),
    .debug_pc_addr(debug_pc_addr)
);
endmodule