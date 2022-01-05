`timescale 1ns / 1ps

`include "bus.v"
`include "pcdef.v"
`include "sim.v"

module ROM(
  input                       clk,
  input                       rst,
  input                       rom_en,
  input       [`MEM_SEL_BUS]  rom_write_en,
  input       [`ADDR_BUS]     rom_addr,
  input       [`DATA_BUS]     rom_write_data,
  output  reg [`DATA_BUS]     rom_read_data
);

  reg[7:0] inst_mem[`INST_MEM_BUS];
  // initialize with program
  always @(posedge clk) begin
	if (rst) begin
		{ inst_mem[3],inst_mem[2],inst_mem[1],inst_mem[0] } <= 32'h0000_0000;
		{ inst_mem[7],inst_mem[6],inst_mem[5],inst_mem[4] } <= 32'h0000_0000;
		{ inst_mem[11],inst_mem[10],inst_mem[9],inst_mem[8] } <= 32'h0000_0000;
		{ inst_mem[15],inst_mem[14],inst_mem[13],inst_mem[12] } <= 32'h0000_0000;
		{ inst_mem[19],inst_mem[18],inst_mem[17],inst_mem[16] } <= 32'h0000_0000;		
	end
  end

  wire[`ADDR_BUS] addr = rom_addr - `INIT_PC;

  always @(posedge clk) begin
    if (!rom_en) begin
      rom_read_data <= 0;
    end
    else begin
      rom_read_data <= {
        inst_mem[addr[`INST_MEM_ADDR_WIDTH - 1:0] + 0],
        inst_mem[addr[`INST_MEM_ADDR_WIDTH - 1:0] + 1],
        inst_mem[addr[`INST_MEM_ADDR_WIDTH - 1:0] + 2],
        inst_mem[addr[`INST_MEM_ADDR_WIDTH - 1:0] + 3]
      };
    end
  end

endmodule // ROM
