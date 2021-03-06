`timescale 1ns / 1ps

`include "bus.v"

module RegFile(
  input                       clk,
  input                       rst,
  // read channel #1
  input                       read_en_1,
  input       [`REG_ADDR_BUS] read_addr_1,
  output  reg [`DATA_BUS]     read_data_1,
  // read channel #2
  input                       read_en_2,
  input       [`REG_ADDR_BUS] read_addr_2,
  output  reg [`DATA_BUS]     read_data_2,
  // write channel
  input                       write_en,
  input       [`REG_ADDR_BUS] write_addr,
  input       [`DATA_BUS]     write_data
);

  (*dont_touch = "true"*) reg[`DATA_BUS] registers[0:31];
  wire forward_flag;
  assign forward_flag = ( write_addr != 0 );
 
  integer i;

  // writing
  always @(posedge clk) begin
    if (rst) begin
      for (i = 0; i < 32; i = i + 1) begin
        registers[i] <= 0;
        //reg_flag <= 0;
      end
    end
    else if ( write_en && |write_addr && write_addr!=5'b11000) begin
      registers[write_addr] <= write_data;
    end
  end

  // reading #1
  always @(*) begin
    if (rst) begin
      read_data_1 <= 0;
    end
    else if (read_addr_1 == write_addr && write_en && read_en_1 && forward_flag) begin
      // forward data to output
      read_data_1 <= write_data;
    end
    else if (read_en_1) begin
      read_data_1 <= registers[read_addr_1];
    end
    else begin
      read_data_1 <= 0;
    end
  end

  // reading @2
  always @(*) begin
    if (rst) begin
      read_data_2 <= 0;
    end
    else if (read_addr_2 == write_addr && write_en && read_en_2 && forward_flag) begin
      // forward data to output
      read_data_2 <= write_data;
    end
    else if (read_en_2) begin
      read_data_2 <= registers[read_addr_2];
    end
    else begin
      read_data_2 <= 0;
    end
  end

endmodule // RegFile
