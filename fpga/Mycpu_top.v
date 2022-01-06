`timescale 1ps / 1ps

`include "bus.v"

module Mycpu_top (
    input clk,
    input rst,
 	input  [7:0]  switch,
 	input  [4:0]  btn,
 	output [7:0] led,
 	output [7:0] small_led,
    output [7:0] pos,
    output [7:0] seg_code_0,
    output [7:0] seg_code_1
);

  wire                  stall;
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
    wire [`DATA_BUS] debug_pc;
    wire [`DATA_BUS] debug_operand_1;
    wire [`DATA_BUS] debug_operand_2;
    wire [`DATA_BUS] debug_branch_addr;
    wire [`DATA_BUS] debug_wb_result;
    wire [`DATA_BUS] debug_hi_read_data;
    wire [`DATA_BUS] debug_lo_read_data;
    wire [`DATA_BUS] debug_ifid_inst;
    
    wire [`DATA_BUS] data;

    //reg[31:0] data;
            
    assign rst_not = ~rst;
    assign small_led = { {3{1'b0}},btn};
    
    Digic_led digic_led(
        .clk   (clk),
        .rst   (rst_not),
        .data  (data),
        .seg_code_0 (seg_code_0),
        .seg_code_1 (seg_code_1),       
        .pos   (pos)
    );

    Switch_led switch_led(
        .clk        (clk),
        .rst        (rst_not),
        .switch     (switch),
        .led        (led)      
    );
    
    Stall_btn stall_btn(
        .clk        (clk),
        .rst        (rst_not),
        .btn2       (btn[1]),
        .stall      (stall)       
    );
    
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

assign rom_en = ~rst_not;

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