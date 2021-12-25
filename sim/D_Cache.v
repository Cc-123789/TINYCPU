//直接相联cache，cache大小为32块，主存大小为1024块，1块=4字，1字=32bit
//主存地址为12位，其中[1:0]是块内偏移，[6:2]是索引，[11:7]是Tag
//change 主存地址32位
//cache V+D+Tag+Data=1+1+5+128=135

module cache(
input clk,
input rst,
//cpu<->cache
input [11:0]cpu_req_addr,
input cpu_req_rw,
input cpu_req_valid,
input [31:0]cpu_data_write,
output reg [31:0]cpu_data_read,
output reg cpu_ready,
//cache<->memory
output reg [11:0]mem_req_addr,
output reg mem_req_rw,
output reg mem_req_valid,
output reg [127:0]mem_data_write,
input [127:0]mem_data_read,
input mem_ready
);

parameter V = 134;
parameter D = 133;
parameter TagMSB = 132;
parameter TagLSB = 128;
parameter BlockMSB = 127;
parameter BlockLSB = 0 ;

parameter IDLE=0;
parameter CompareTag=1;
parameter Allocate=2;
parameter WriteBack=3;

reg [134:0] cache_data[0:31];           //134:V,133:D,[132:128]:TAG,[127:0]DATA
reg [1:0]state,next_state;
reg hit;

wire [4:0]cpu_req_index;
wire [4:0]cpu_req_tag;
wire [1:0]cpu_req_offset;

assign cpu_req_offset=cpu_req_addr[1:0];
assign cpu_req_index=cpu_req_addr[6:2];
assign cpu_req_tag=cpu_req_addr[11:7];

integer i;
//初始化cache
initial
begin
    for(i=0;i<32;i=i+1)
        cache_data[i]=135'd0;
end

always@(posedge clk,posedge rst)
if(rst)
    state<=IDLE;
else
    state<=next_state;
//
always@(*)
case(state)
    IDLE:if(cpu_req_valid)
            next_state=CompareTag;
         else
            next_state=IDLE;
    CompareTag:if(hit)
                   next_state=IDLE;
               else if(cache_data[cpu_req_index][V:D]==2'b11)               //if the block is valid and dirty then go to WriteBack
                   next_state=WriteBack;
               else 
                   next_state=Allocate;
    Allocate:if(mem_ready)
                   next_state=CompareTag;
             else
                   next_state=Allocate;
    WriteBack:if(mem_ready)
                   next_state=Allocate;
              else
                   next_state=WriteBack;
      default:next_state=IDLE;
endcase

always@(*)
if(state==CompareTag)
    if(cache_data[cpu_req_index][134]&&cache_data[cpu_req_index][TagMSB:TagLSB]==cpu_req_tag)
        hit=1'b1;
    else
        hit=1'b0;

always@(posedge clk)
if(state==Allocate)                 //read new block from memory to cache
    if(!mem_ready)
    begin
        mem_req_addr<={cpu_req_addr[11:2],2'b00};
        mem_req_rw<=1'b0;
        mem_req_valid<=1'b1; 
    end
    else
    begin
        mem_req_valid<=1'b0;
        cache_data[cpu_req_index][BlockMSB:BlockLSB]<=mem_data_read;
        cache_data[cpu_req_index][V:D]<=2'b10;
        cache_data[cpu_req_index][TagMSB:TagLSB]<=cpu_req_tag;
    end
else if(state==WriteBack)                          //write dirty block to memory
    if(!mem_ready)
    begin
        mem_req_addr<={cache_data[cpu_req_index][TagMSB:TagLSB],cpu_req_index,2'b00};
        mem_req_rw<=1'b1;
        mem_data_write<=cache_data[cpu_req_index][BlockMSB:BlockLSB];
        mem_req_valid<=1'b1;
    end
    else
    begin
        mem_req_valid<=1'b0;
    end
else
begin
    mem_req_valid=1'b0;
end

always@(posedge clk)
if(state==CompareTag&&hit)
    if(cpu_req_rw==1'b0)              //read hit
    begin
        cpu_ready<=1'b1;
        cpu_data_read<=cache_data[cpu_req_index][cpu_req_offset*32 +:32];
    end
    else                               //write hit,置脏位为1
    begin
        cpu_ready<=1'b1;
        cache_data[cpu_req_index][cpu_req_offset*32 +:32]=cpu_data_write;
        cache_data[cpu_req_index][D]=1'b1;
    end
else
    cpu_ready<=1'b0;

endmodule

