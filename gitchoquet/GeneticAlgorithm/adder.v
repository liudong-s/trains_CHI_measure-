module adder (
    input   clk,
    
    input [47:0] operand1,
    input [47:0] operand2,
    input         adder_en,
    
    output        [47:0] sum,
    output  reg      sum_vail
);

reg start;
reg [47:0] sum_out;
reg [47:0] operand1_buf;
reg [47:0] operand2_buf;

reg [15:0] operand1_1;
reg [15:0] operand2_1;
reg en1;
reg c_in1;
wire   vail1;
wire [15:0] result1;
wire c_out1;
reg [15:0] result1_buf;

reg [15:0] operand1_2;
reg [15:0] operand2_2;
reg en2;
reg c_in2;
wire vail2;
wire [15:0] result2;
wire c_out2;
reg [15:0] result2_buf;

reg [15:0] operand1_3;
reg [15:0] operand2_3;
reg en3;
reg c_in3;
wire vail3;
wire [15:0] result3;
wire c_out3;
//reg [15:0] result3_buf;

assign sum = sum_out;

always@(posedge clk) begin
    if(adder_en)begin   
        operand1_buf  <= operand1;
        operand2_buf  <= operand2;  
        start <= 1'b1;
    end
    else start <= 1'b0;
end

always@(posedge clk) begin
    if(start) begin
        en1 <= 1'b1;
        operand1_1 <= operand1_buf[15:0];
        operand2_1 <= operand2_buf[15:0];
        c_in1 <= 1'b0;
    end
    else en1 <= 1'b0;
end

always@(posedge clk) begin
    if(vail1) begin
        result1_buf <= result1;
        en2 <= 1'b1;
        operand1_2 <= operand1_buf[31:16];
        operand2_2 <= operand2_buf[31:16];
        c_in2 <= c_out1;
    end
    else en2 <= 1'b0;
end

always@(posedge clk) begin
    if(vail2) begin
        result2_buf <= result2;
        en3 <= 1'b1;
        operand1_3 <= operand1_buf[47:32];
        operand2_3 <= operand2_buf[47:32];
        c_in3 <= c_out2;
    end
    else en3 <= 1'b0;
end

always@(posedge clk) begin
    if(vail3) begin
        sum_vail <= 1'b1;
        sum_out <= {result3,result2_buf,result1_buf};
    end
    else sum_vail <= 1'b0;
end


adderSub adderSub_i1
(
    .clk    (clk),
    
	.A      (operand1_1),
	.B      (operand2_1),      
    .en     (en1       ),
	.C_in   (c_in1     ),
    
    .vail   (vail1  ),
	.Result (result1),
	.C_out  (c_out1 )
);  

adderSub adderSub_i2
(
    .clk    (clk),
    
	.A      (operand1_2),
	.B      (operand2_2),      
    .en     (en2       ),
	.C_in   (c_in2     ),
    
    .vail   (vail2  ),
	.Result (result2),
	.C_out  (c_out2 )
); 

adderSub adderSub_i3
(
    .clk    (clk),
    
	.A      (operand1_3),
	.B      (operand2_3),      
    .en     (en3       ),
	.C_in   (c_in3     ),
    
    .vail   (vail3  ),
	.Result (result3),
	.C_out  (c_out3 )
);  

endmodule