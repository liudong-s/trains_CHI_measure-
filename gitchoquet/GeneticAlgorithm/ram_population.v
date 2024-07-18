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
    parameter           DATA_WDTH = 9'd320,      //�������ݵ�λ��
    parameter           COL = 200,				//RAM�����ݸ���
    parameter           COL_BITS = 8           //��ַ��λ��
)
(
    input                       clk,			//ʱ���ź�
    input   [COL_BITS-1:0]      addra,			//д�����ݵĵ�ַ
    input   [DATA_WDTH-1:0]     dina,			//д�������
    input                       wea,			//д��Ч�ź�
    
    input   [COL_BITS-1:0]      addrb,			//������ݵĵ�ַ
    output  [DATA_WDTH-1:0]     doutb			//���������
);
 
reg     [DATA_WDTH-1:0]         mem[0:COL-1];	//����RAM
 
assign doutb = mem[addrb + 0];
 
always @ ( posedge clk )
begin	
    if( wea == 1'b1 )							//д��Чʱ�򣬰�dinaд�뵽addra��
    begin
        mem[addra] <= dina;
    end
    else
        ;
end
 
endmodule

