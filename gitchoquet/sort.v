module sort
#(
    parameter N=250,
    parameter length = 32
)
(
    input                               clk,
    input                             rst_n,
    input           [length-1:0]    data_in,
    input                                en,      //排序信号 拉高一个时钟周期
                        
    output    reg       [31:0]       result,
    output    reg                 result_val,   //输出有效信号  
    output    reg       [8:0]   result_index,
    output    reg              done_complate 
);

localparam DIV = 5;
localparam SEG = N/DIV;
reg [8:0] ram_cnt;      //排序个数 
reg [length-1:0] array [1:N];
reg reg_done;
reg done;
 
//************排序数据保存在array中 reg_cnt中保存了排序元素个数**************//
//integer i;
reg [9:0] loop_num;
always@(posedge clk ) begin
    if(rst_n == 1'b0) begin	
        ram_cnt <= 9'd1;
        loop_num <= 10'd0;
        reg_done <= 1'b0;
        done_complate <= 1'b0;
//        for(i=1;i<=N;i=i+1) begin
//            array[i] <= 0;  
//        end
    end 
	else if(en) begin 
         array[ram_cnt] <= data_in;
         ram_cnt <= ram_cnt + 9'd1;
         if(ram_cnt == N) begin
            reg_done <= 1'b1;
            ram_cnt <= 9'd1;
         end
    end
    else if(done == 1'b1) begin
        loop_num <= loop_num + 10'd1;
        if(loop_num == 999)begin
            reg_done <= 1'b0;
            loop_num <= 10'd0;
            done_complate <= 1'b1;
        end else if(loop_num == 0) begin
             reg_done <= 1'b1;
 //            done_complate <= 1'b1;
        end
        else reg_done <= 1'b1;
    end
    else  begin
        reg_done <= 1'b0;
        done_complate <= 1'b0;
    end
end

          
        

//sort
reg [N:1] temp;
reg [N:1] temp_buf;
reg [N:1] select;
reg [N:1] flag;
reg [N:1] buffer[length-1:0];
reg [8:0] index[0:N-1];
reg [2:0] con;
reg signal;
reg is_0;

integer col;
integer row;
integer l1;
integer l2;
integer l3;
integer l4;
integer l5;
integer p;
reg [SEG:1]temp1;
reg [SEG*2:SEG+1]temp2;
reg [SEG*3:SEG*2+1]temp3;
reg [SEG*4:SEG*3+1]temp4;
reg [SEG*5:SEG*4+1]temp5;
reg [3:0] cou;
reg [length-1:0] result1;
reg [length-1:0] result2;
reg [length-1:0] result3;
reg [length-1:0] result4;
reg [length-1:0] result5;

reg       [8:0]   result_index1;
reg       [8:0]   result_index2;
reg       [8:0]   result_index3;
reg       [8:0]   result_index4;
reg       [8:0]   result_index5;






always@(posedge clk ) begin
    if(rst_n == 1'b0) begin
        temp <= 0;
        select <= 0;
        flag <= 0;
        col <= length-1;     
        con <= 3'd0; 
        signal <= 1'b0;   
        done <= 1'b0;
//        result_index <= 9'd0;
        is_0  <= 1'b0;
//        result_val <= 1'b0;
        cou <= 4'd0;
        
        result1<=0;
        result2<=0;
        result3<=0;
        result4<=0;
        result5<=0;
        result_index1<=9'd0;
        result_index2<=9'd0;
        result_index3<=9'd0;
        result_index4<=9'd0;
        result_index5<=9'd0;
    end
    else if(reg_done == 1'b1)begin
        con <= 3'd1;
        signal <= 1'b1;
    end
    else if(flag != {N{1'b1}}) begin
 //       result_val <= 1'b0;
        done <= 1'b0;
 //       cou <= 3'd0;
        if(signal == 1'b1) begin
            case(con)            
            3'd1:begin
                signal <= 1'b1;
                cou <= 3'd0;
                if((temp | flag) == {N{1'b1}}) begin  //处理回溯
                    signal <= 1'b0;
                end else ;
                
                for(p=1;p <=N;p=p+1) begin      //清空select
                    select[p] <= 1'b0;
                end
                
                if(col != length) begin
                    for(row=1;row<=N;row=row+1) begin 
                        if(array[row][col] == 1)
                            select[row] <= 1'b1;
                    end
                end else ;
                
                if(col != 0 && col != length) begin
                    col <= col - 1;  
                end
                else if(col == 0) begin
                    col <= length;
                end
                else if(col == length) begin
                    signal <= 1'b0;
                end
                else ;
                con <= 3'd2;
              end
            3'd2:begin
                if(col == length) buffer[0] <= temp;
                else buffer[col + 1] <= temp;      //buffer的第i行保存的是下标为i+1的temp值
                temp <= temp | select | flag;     
                con <= 3'd3;
              end
            3'd3:begin
                if(temp == {N{1'b1}} && col < length) begin
                    if(flag == {N{1'b1}}) begin
                        con <= 3'd0;
                    end
                    else ;
                    temp <= buffer[col + 1];
                    con <= 3'd1;
                end 
                else if(temp == {N{1'b1}} && col == length)begin
                    con <= 3'd4;
                    temp <= buffer[0];
                end
                else begin
                    con <= 3'd4;
                end
                temp_buf <= ~temp;
              end
            3'd4:begin
                  if((temp_buf & (temp_buf-1))==0) begin
                        is_0 <= 1'b1;
                  end 
                  else is_0 <= 1'b0;                  
                  con <= con + 1;                                                             
              end
            3'd5:begin
                    if(is_0 == 1 || col == length) begin                      
                         con <= con + 3'd1;
                         is_0 <= 1'b0;
                         temp1 <= temp[SEG:1];
                         temp2 <= temp[SEG*2:SEG+1];
                         temp3 <= temp[SEG*3:SEG*2+1];
                         temp4 <= temp[SEG*4:SEG*3+1];
                         temp5 <= temp[SEG*5:SEG*4+1];
                         
                    end                  
                    else con <= 3'd1;
                 end           
            3'd6:begin 
                    for(l1=1;l1<=SEG;l1=l1+1)begin
                        if(temp1[l1] == 1'b0)begin
                            flag[l1] <= 1'b1; 
                            cou <= 3'd1;
                            result1 <= array[l1];
                            result_index1 <= l1;                    
                        end                        
                    end  
                    
                    for(l2=SEG+1;l2<=SEG*2;l2=l2+1)begin
                        if(temp2[l2] == 1'b0)begin
                            flag[l2] <= 1'b1;
                            cou <= 3'd2;
                            result2 <= array[l2]; 
                            result_index2 <= l2;
//                            result <= array[l];
//                            result_index <= l;
//                            result_val <= 1'b1;
                        end                        
                    end  
                    
                    for(l3=SEG*2+1;l3<=SEG*3;l3=l3+1)begin
                        if(temp3[l3] == 1'b0)begin
                            flag[l3] <= 1'b1; 
                            cou <= 3'd3;
                            result3 <= array[l3]; 
                            result_index3 <= l3;                        
                        end                        
                    end 
                    
                    for(l4=SEG*3+1;l4<=SEG*4;l4=l4+1)begin
                        if(temp4[l4] == 1'b0)begin
                            flag[l4] <= 1'b1;
                            cou <= 3'd4;
                            result4 <= array[l4];  
                            result_index4 <= l4;                         
                        end                        
                    end  
                    
                    for(l5=SEG*4+1;l5<=N;l5=l5+1)begin
                        if(temp5[l5] == 1'b0)begin
                            flag[l5] <= 1'b1; 
                            cou <= 3'd5;
                            result5 <= array[l5];  
                            result_index5 <= l5;                          
                        end                        
                    end   
                    
                                                
                    if(col != length) begin    
                        if(col+2 == length) temp <= 0;
                        else temp <= buffer[col+2];
                        col <= col + 2;  
                    end
                    else ;
                    con <= 3'd1;
              end
            default:begin
                    end
            endcase 
        end
        else if(col == length || (temp | flag) == {N{1'b1}}) begin
            col<=length-1;
            con <= 3'd1;
            temp <=0;
            select <= 0;
            signal <= 1'b1;
            for(p=0;p<length;p=p+1)begin  //清空buffer
                buffer[p] <= 0;
            end
        end
        else ;
    end
    else begin
        cou <= 3'd0;
        temp <= 0;
        select <= 0;
        flag <= 0;
        signal <= 1'b0;
        col <= length-1;
        con <= 3'd0;
//        result_val <= 1'b0;
        done <= 1'b1;       
    end
end

always@(posedge clk ) begin
    if(rst_n == 1'b0)begin
        result_val <= 1'b0;
        result_index  <= 9'd0;
    end
    else begin
        result_val <= 1'b0;
        case(cou)
            3'd0:begin
                    result_val <= 1'b0;
                 end
            3'd1:begin
                    result_val <= 1'b1;
                    result_index <= result_index1;
                    result <= result1;
                 end
           3'd2:begin
                    result_val <= 1'b1;
                    result_index <= result_index2;
                    result <= result2;
                 end
           3'd3:begin
                    result_val <= 1'b1;
                    result_index <= result_index3;
                    result <= result3;
                 end
          3'd4:begin
                    result_val <= 1'b1;
                    result_index <= result_index4;
                    result <= result4;
                 end
         3'd5:begin
                    result_val <= 1'b1;
                    result_index <= result_index5;
                    result <= result5;
                 end
         default:begin
                 end
        endcase
    end
end



ila_0 my_lia0 (
	.clk(clk), // input wire clk

	.probe0(done_complate), // input wire [0:0]  probe0  
	.probe1(col), // input wire [31:0]  probe1 
	.probe2(array[1]), // input wire [31:0]  probe2 
	.probe3(result), // input wire [31:0]  probe3 
	.probe4(loop_num), // input wire [8:0]  probe4 
	.probe5(result_val) // input wire [0:0]  probe5
);



endmodule
