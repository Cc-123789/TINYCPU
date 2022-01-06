`timescale 1ps / 1ps

module testbench;
    reg clk,rst;
    reg[4:0] btn;
    reg[7:0] switch;
    wire[7:0] seg_code_0,seg_code_1,pos;
    initial begin
        clk <= 1'b0;
        rst <= 1'b0;
        btn <= 5'b00000;
        #20 rst = 1'b1;
        btn <= 5'b00010;
        #20 
        btn <= 5'b00000;
        #20 
        btn <= 5'b00010;
    end
    always #5 clk <= ~clk;   

    Mycpu_top mycpu_top(
        .clk  (clk),
        .rst  (rst),
        .btn  (btn),
        .switch (switch),
        .seg_code_0 (seg_code_0),
        .seg_code_1 (seg_code_1),
        .pos  (pos)
    );
    
endmodule