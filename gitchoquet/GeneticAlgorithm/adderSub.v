`timescale 1ns / 1ps
module adderSub
(
    input clk,
    
	input [15:0]A,
	input [15:0]B,
    input en,
	input C_in,
    
    output reg vail,
	output [15:0] Result,
	output  C_out
);

reg [16:0] result_buf;

assign C_out = result_buf[16] ? 1:0;
assign Result = result_buf[15:0];

always@(posedge clk) begin
    if(en) begin
        result_buf <= A + B + C_in;  
        vail <= 1'b1;
    end
    else begin
        vail <= 1'b0;
        result_buf <= 17'd0;
    end
end




endmodule
