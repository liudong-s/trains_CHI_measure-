`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/12/25 10:19:28
// Design Name: 
// Module Name: ram_population
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ram_population
#(
    parameter           DATA_WDTH = 9'd320,      //输入数据的位宽
    parameter           COL = 200,				//RAM中数据个数
    parameter           COL_BITS = 8           //地址线位数
)
(
    input                       clk,			//时钟信号
    input   [COL_BITS-1:0]      addra,			//写入数据的地址
    input   [DATA_WDTH-1:0]     dina,			//写入的数据
    input                       wea,			//写有效信号
    
    input   [COL_BITS-1:0]      addrb,			//输出数据的地址
    output  [DATA_WDTH-1:0]     doutb			//输出的数据
);
 
reg     [DATA_WDTH-1:0]         mem[0:COL-1];	//定义RAM
 
assign doutb = mem[addrb + 0];
 
always @ ( posedge clk )
begin	
    if( wea == 1'b1 )							//写有效时候，把dina写入到addra处
    begin
        mem[addra] <= dina;
    end
    else
        ;
end
 
endmodule

