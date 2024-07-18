module calculateChoquet
#(
    parameter n=4,                   
    parameter index_sum = 2**n       
)

(
    input                           clk             ,
    input                           rst_n           ,

    input           [19:0]          measure         , 
    input           [19:0]          s1              , 
    input                           measure_ready   ,    //和measure同时有效
    input                           s1_ready        ,    //s1_ready提前S1拉高一个时钟周期
   
    output  reg                     phase1          ,
    output  reg     [39:0]          result          ,
    output                          result_val      
);
     
      /* always@ (posedge clk) begin	
        measure_index_reg[0]  <= 11'd0;   
        measure_index_reg[1]  <= 11'd1;   
        measure_index_reg[2]  <= 11'd2;   
        measure_index_reg[3]  <= 11'd3;   
        measure_index_reg[4]  <= 11'd4;   
        measure_index_reg[5]  <= 11'd12;  
        measure_index_reg[6]  <= 11'd13;  
        measure_index_reg[7]  <= 11'd14;  
        measure_index_reg[8]  <= 11'd23;  
        measure_index_reg[9]  <= 11'd24;  
        measure_index_reg[10] <= 11'd34;  
        measure_index_reg[11] <= 11'd123; 
        measure_index_reg[12] <= 11'd124; 
        measure_index_reg[13] <= 11'd134; 
        measure_index_reg[14] <= 11'd234; 
        measure_index_reg[15] <= 11'd1234; 
    end */
    
    reg   [19:0] s2_reg[0:n]                      ;  //存放s2
    reg   [19:0] s1_reg[0:n]                      ;  //存放s1
    reg   [19:0] measure_reg[0:index_sum -1]      ;  //存放模糊测度
   
    reg [4:0]   k;    
    reg [3:0]   p;     
    //measure_reg
    always@(posedge clk ) 
        if(rst_n == 1'b0)
            k <= 5'd0;
        else if(measure_ready==1'b1) begin
            measure_reg[k] <= measure;
            k <= k+5'd1;
        end
        else k <= 5'd0;
        
    //s1
    reg  sort_flag;
    always@(posedge clk ) 
        if(rst_n == 1'b0) begin  
            p <= 4'd0;
            sort_flag <= 1'b0;
        end
        else if(s1_ready == 1)begin  
            s1_reg[p] <= s1;
            p <= p + 4'd1;
        end
        else if(p==n+1) begin
            sort_flag <= 1'b1;
            p <= 4'd0;
        end
        else begin
            sort_flag <= 1'b0;
            p <= 4'd0;
        end
    
 
    reg sort;
    reg [2:0]sort_state;
    reg flag_next1;

    reg [2:0] sort_index;
    always@(posedge clk ) 
        if(rst_n == 1'b0) begin  
            sort <= 1'b0;
            sort_state <= 3'b0;
            sort_index <= 3'd1;
            flag_next1 <= 1'b0;
        end
        else if(sort_flag == 1'b1) begin
            sort <= 1'b1;
            sort_state <= 3'b0;
            s2_reg[0] <= 20'd0;
            s2_reg[1] <= 20'hFFFFF;
            s2_reg[2] <= 20'hFFFFF;
            s2_reg[3] <= 20'hFFFFF;
            s2_reg[4] <= 20'hFFFFF;
        end
        else if(sort == 1'b1) begin           
            case(sort_state)  //排序四个数，且不能有重复的数               
                3'd0: begin
                        sort_index<=sort_index+1;                      
                        if(s1_reg[sort_index] < s2_reg[1]) begin
                            s2_reg[1] <= s1_reg[sort_index];
                        end
                        else if(sort_index == 3'd4 || sort_index == 3'd5) begin
                            sort_state <= 3'd1;
                            sort_index <= 3'd1;
                        end                     
                   end
                3'd1: begin
                       sort_index<=sort_index+3'd1;                      
                       if(s1_reg[sort_index] < s2_reg[2] && s1_reg[sort_index] > s2_reg[1] ) begin
                           s2_reg[2] <= s1_reg[sort_index];                        
                       end
                       else if(sort_index == 3'd4 || sort_index == 3'd5) begin
                           sort_state <= 3'd2;
                           sort_index <= 3'd1;
                       end
                  end            
                3'd2: begin
                     sort_index<=sort_index+1;                   
                     if(s1_reg[sort_index] < s2_reg[3] && s1_reg[sort_index] > s2_reg[1] && s1_reg[sort_index] > s2_reg[2] ) begin
                         s2_reg[3] <= s1_reg[sort_index];                       
                     end
                     else if(sort_index == 3'd4 || sort_index == 3'd5) begin
                         sort_state <= sort_state + 3'd1;
                         sort_index <= 3'd1;
                     end
                end
                3'd3: begin
                     sort_index<=sort_index+3'd1;                   
                     if(s1_reg[sort_index] < s2_reg[4] && s1_reg[sort_index] > s2_reg[1] && s1_reg[sort_index] > s2_reg[2] && s1_reg[sort_index] > s2_reg[3]) begin
                         s2_reg[4] <= s1_reg[sort_index];                         
                     end
                     else if(sort_index == 3'd4 || sort_index == 3'd5) begin
                         sort_state <= 3'd0;
                         sort_index <= 3'd1;
                         sort <= 1'b0;
                         flag_next1 <= 1'b1;
                     end
                end 
                default: begin
                end   
            endcase
        end
        else flag_next1 <= 1'b0;
        
    reg   [19:0] s_buf[0:n];  
    reg   [19:0] s_buf_u[0:n];
    reg   [19:0] measure_buf[0:index_sum -1]; 
   
//    reg   phase1;
    integer   buf_i;
    integer   buf_j;
    integer   buf_k;
   
    reg [2:0] con_state1;
    reg  flag;
    always@(posedge clk ) begin
        if(rst_n == 1'b0) begin
            phase1 <= 1'b0;
            flag <= 1'b0;
        end
        else if(flag_next1 == 1'b1)begin
            for(buf_i=0;buf_i<index_sum;buf_i=buf_i+1)begin
                measure_buf[buf_i] <= measure_reg[buf_i];
            end
            for(buf_j=0;buf_j<=n;buf_j=buf_j+1)begin
                s_buf[buf_j] <= s2_reg[buf_j];
            end
            for(buf_k=0;buf_k<=n;buf_k=buf_k+1)begin
                s_buf_u[buf_k] <= s1_reg[buf_k];
            end         
            flag <= 1'b1;
        end
        else if(con_state1 == 3'd0 &&  flag == 1'b1) begin
            phase1 <= 1'b1;
            flag <= 1'b0;
        end
        else   phase1 <= 1'b0;
    end
    
//**********************************************************//
        
    integer   i;   
    integer   j; 
    reg [3:0] index[1:n];
    
    reg [10:0] measure_index_buffer[1:n];   
    reg   [12:0] measure_index_reg[0:index_sum -1];  //存放模糊测度下标 
    reg   [2:0] m1;
   
    reg  [19:0] result_measure[1:n];
    reg  [39:0] result_buffer[1:n];
    
    reg [2:0] measure_index_1[1:4];
    reg [2:0] measure_index_2[1:4];
    reg [2:0] measure_index_3[1:4];
    reg [2:0] measure_index_4[1:4];
    reg [2:0] measure_index_5[1:4];
    reg [2:0] measure_index_6[1:4];
    reg [2:0] measure_index_7[1:4];
    reg [2:0] measure_index_8[1:4];
    reg [2:0] measure_index_9[1:4];
    reg [2:0] measure_index_10[1:4];
   
 
    integer   t;
    integer   r;
    integer   z;
    reg measure_index_start;
    reg flag_start;
    reg [2:0]state_measure;
    reg          flag_mul;
    reg          result_val1;
    assign result_val = result_val1;
      
    always@ (posedge clk) begin	
        if(rst_n == 1'b0) begin          
           measure_index_reg[5]  <= 13'd0;
           measure_index_reg[6]  <= 13'd0;
           measure_index_reg[7]  <= 13'd0;
           measure_index_reg[8]  <= 13'd0;
           measure_index_reg[9]  <= 13'd0;
           measure_index_reg[10] <= 13'd0;
           measure_index_reg[11] <= 13'd0;
           measure_index_reg[12] <= 13'd0;
           measure_index_reg[13] <= 13'd0;
           measure_index_reg[14] <= 13'd0; 
           flag_start <= 1'b0;
           state_measure <= 3'd0;
           flag_mul <= 1'b0;
        end
        else if(measure_index_start)begin
                measure_index_reg[0]  <= 13'd0;       //0
                measure_index_reg[1]  <= 13'd1;       //1
                measure_index_reg[2]  <= 13'd2;       //2 
                measure_index_reg[3]  <= 13'd3;       //3
                measure_index_reg[4]  <= 13'd4;       //4
                measure_index_reg[15] <= 13'd1234;    //1234              
                for(m1=1;m1<=n;m1=m1+1) begin
                    if(index[m1] == 1 || index[m1] == 2) 
                        measure_index_1[m1] <= index[m1];
                    else measure_index_1[m1] <= 0 ;
                    
                    if(index[m1] == 1 || index[m1] == 3) 
                        measure_index_2[m1] <= index[m1];
                    else measure_index_2[m1] <= 0 ;
                    
                    if(index[m1] == 1 || index[m1] == 4) 
                        measure_index_3[m1] <= index[m1];
                    else measure_index_3[m1] <= 0;
                    
                    if(index[m1] == 2 || index[m1] == 3) 
                        measure_index_4[m1] <= index[m1];
                    else measure_index_4[m1] <= 0;
                    
                    if(index[m1] == 2 || index[m1] == 4) 
                        measure_index_5[m1] <= index[m1];
                    else measure_index_5[m1] <= 0;
                    
                    if(index[m1] == 3 || index[m1] == 4) 
                        measure_index_6[m1] <= index[m1];
                    else measure_index_6[m1] <= 0;
                    
                    if(index[m1] == 1 || index[m1] == 2 || index[m1] == 3) 
                         measure_index_7[m1] <= index[m1];
                    else measure_index_7[m1] <= 0;
                    
                    if(index[m1] == 1 || index[m1] == 2 || index[m1] == 4) 
                         measure_index_8[m1] <= index[m1];
                    else measure_index_8[m1] <= 0;
                    
                    if(index[m1] == 1 || index[m1] == 3 || index[m1] == 4) 
                         measure_index_9[m1] <= index[m1];
                    else measure_index_9[m1] <= 0;
                    
                    if(index[m1] == 2 || index[m1] == 3 || index[m1] == 4) 
                         measure_index_10[m1] <= index[m1];
                    else measure_index_10[m1] <= 0;
                end
                flag_start <= 1'b1;
        end
        else if(flag_start) begin
            case(state_measure)
                3'd0:begin
                        measure_index_reg[5] <=  measure_index_1[1] ;
                        measure_index_reg[6] <=  measure_index_2[1] ;
                        measure_index_reg[7] <=  measure_index_3[1] ;
                        measure_index_reg[8] <=  measure_index_4[1] ;
                        measure_index_reg[9] <=  measure_index_5[1] ;
                        measure_index_reg[10] <= measure_index_6[1] ;
                        measure_index_reg[11] <= measure_index_7[1] ;
                        measure_index_reg[12] <= measure_index_8[1] ;
                        measure_index_reg[13] <= measure_index_9[1] ;
                        measure_index_reg[14] <= measure_index_10[1];
                        state_measure <= state_measure + 3'd1;
                     end
                3'd1: begin
                        if(measure_index_1[2] != 0) begin
                            measure_index_reg[5] <=  measure_index_reg[5]  * 10 + measure_index_1 [2];
                        end else;
                        if(measure_index_2[2] != 0) begin
                            measure_index_reg[6] <=  measure_index_reg[6]  * 10 + measure_index_2 [2];
                        end else;
                        if(measure_index_3[2] != 0) begin
                            measure_index_reg[7] <=  measure_index_reg[7]  * 10 + measure_index_3 [2];
                        end else;
                        if(measure_index_4[2] != 0) begin
                            measure_index_reg[8] <=  measure_index_reg[8]  * 10 + measure_index_4 [2];
                        end else;
                        if(measure_index_5[2] != 0) begin
                            measure_index_reg[9] <=  measure_index_reg[9]  * 10 + measure_index_5 [2];
                        end else;
                        if(measure_index_6[2] != 0) begin
                            measure_index_reg[10] <= measure_index_reg[10] * 10 + measure_index_6 [2];
                        end else;
                        if(measure_index_7[2] != 0) begin
                            measure_index_reg[11] <= measure_index_reg[11] * 10 + measure_index_7 [2];
                        end else;
                        if(measure_index_8[2] != 0) begin
                            measure_index_reg[12] <= measure_index_reg[12] * 10 + measure_index_8 [2];
                        end else;
                        if(measure_index_9[2] != 0) begin
                            measure_index_reg[13] <= measure_index_reg[13] * 10 + measure_index_9 [2];
                        end else;
                        if(measure_index_10[2] != 0) begin
                            measure_index_reg[14] <= measure_index_reg[14] * 10 + measure_index_10[2];
                        end else;
                        state_measure <= state_measure + 3'd1;
                      end
                3'd2: begin
                        if(measure_index_1[3] != 0) begin
                            measure_index_reg[5] <=  measure_index_reg[5]  * 10 + measure_index_1 [3];
                        end else;
                        if(measure_index_2[3] != 0) begin
                            measure_index_reg[6] <=  measure_index_reg[6]  * 10 + measure_index_2 [3];
                        end else;
                        if(measure_index_3[3] != 0) begin
                            measure_index_reg[7] <=  measure_index_reg[7]  * 10 + measure_index_3 [3];
                        end else;
                        if(measure_index_4[3] != 0) begin
                            measure_index_reg[8] <=  measure_index_reg[8]  * 10 + measure_index_4 [3];
                        end else;
                        if(measure_index_5[3] != 0) begin
                            measure_index_reg[9] <=  measure_index_reg[9]  * 10 + measure_index_5 [3];
                        end else;
                        if(measure_index_6[3] != 0) begin
                            measure_index_reg[10] <= measure_index_reg[10] * 10 + measure_index_6 [3];
                        end else;
                        if(measure_index_7[3] != 0) begin
                            measure_index_reg[11] <= measure_index_reg[11] * 10 + measure_index_7 [3];
                        end else;
                        if(measure_index_8[3] != 0) begin
                            measure_index_reg[12] <= measure_index_reg[12] * 10 + measure_index_8 [3];
                        end else;
                        if(measure_index_9[3] != 0) begin
                            measure_index_reg[13] <= measure_index_reg[13] * 10 + measure_index_9 [3];
                        end else;
                        if(measure_index_10[3] != 0) begin
                            measure_index_reg[14] <= measure_index_reg[14] * 10 + measure_index_10[3];
                        end else;
                        state_measure <= state_measure + 3'd1;
                    end
                3'd3: begin
                        if(measure_index_1[4] != 0) begin
                            measure_index_reg[5] <=  measure_index_reg[5]  * 10 + measure_index_1 [4];
                        end else;
                        if(measure_index_2[4] != 0) begin
                            measure_index_reg[6] <=  measure_index_reg[6]  * 10 + measure_index_2 [4];
                        end else;
                        if(measure_index_3[4] != 0) begin
                            measure_index_reg[7] <=  measure_index_reg[7]  * 10 + measure_index_3 [4];
                        end else;
                        if(measure_index_4[4] != 0) begin
                            measure_index_reg[8] <=  measure_index_reg[8]  * 10 + measure_index_4 [4];
                        end else;
                        if(measure_index_5[4] != 0) begin
                            measure_index_reg[9] <=  measure_index_reg[9]  * 10 + measure_index_5 [4];
                        end else;
                        if(measure_index_6[4] != 0) begin
                            measure_index_reg[10] <= measure_index_reg[10] * 10 + measure_index_6 [4];
                        end else;
                        if(measure_index_7[4] != 0) begin
                            measure_index_reg[11] <= measure_index_reg[11] * 10 + measure_index_7 [4];
                        end else;
                        if(measure_index_8[4] != 0) begin
                            measure_index_reg[12] <= measure_index_reg[12] * 10 + measure_index_8 [4];
                        end else;
                        if(measure_index_9[4] != 0) begin
                            measure_index_reg[13] <= measure_index_reg[13] * 10 + measure_index_9 [4];
                        end else;
                        if(measure_index_10[4] != 0) begin
                            measure_index_reg[14] <= measure_index_reg[14] * 10 + measure_index_10[4];
                        end else;
                        state_measure <= state_measure + 3'd1;
                    end
                3'd4:begin
                        state_measure <= 3'd0;
                        flag_start <= 1'b0;
                        flag_mul <= 1'b1;
                     end
                default:begin
                        end
                
            endcase
        end
        else  flag_mul <= 1'b0;
                
    end
    
    
    always@(posedge clk)  begin
        if(rst_n == 1'b0) begin              
            con_state1 <= 3'd0; 
            result_val1 <= 1'b0;   
            result <= 0;   
            z <= 1;
            measure_index_start <= 1'b0;
        end
        else if(phase1 == 1'b1 ) begin
            con_state1 <= 3'd1;
        end
		else begin         
            case(con_state1)
                3'd0:begin
                        result_val1 <= 1'b0; 
                        result<= 40'd0;
                        z <= 1;                        
                     end
                3'd1:begin //x和x'的对应关系，index的内容为x，下标为x'
                        for(i=1;i<n+1;i=i+1) begin
                            for(j=1;j<n+1;j=j+1)begin
                               if(s_buf_u[j] == s_buf[i])begin
                                    index[i] = j;	
                               end			
                            end   	
                        end
                        measure_index_start <= 1'b1;
                        con_state1 <= 3'd2;                                          
                   end
                3'd2:begin                                                                     
                        measure_index_start <= 1'b0;
                        if(flag_mul)begin
                            measure_index_buffer[1] <= 11'd1234;
                            measure_index_buffer[2] <= index[2]*100+index[3]*10+index[4];
                            measure_index_buffer[3] <= index[3]*10+index[4];
                            measure_index_buffer[4] <= index[4];                       
                            con_state1 <= 3'd3; 
                        end else ;
                    end
               
                3'd3:begin
                        result_measure[1] <= measure_buf[15];
                        for(t=2;t<=n;t=t+1) begin
                            for(r=1;r<index_sum-1;r=r+1) begin
                                if(measure_index_buffer[t] == measure_index_reg[r])
                                     result_measure[t] <= measure_buf[r];
                            end
                        end
                        con_state1 <= 3'd4;
                     end
                3'd4:begin
                        for(t=1;t<=n;t=t+1)begin
                            result_buffer[t] <= (s_buf[t] - s_buf[t-1])*result_measure[t];
                        end
                        con_state1 <= 3'd5;
                     end
                3'd5:begin
                        result <= result + result_buffer[z];  
                        z <= z+1;
	       			    if(z == n) begin
                            result_val1 <= 1'b1;
                            con_state1 <= 3'd0;
	       	            end 
	       	            else    con_state1 <= con_state1;           
                     end
                default: begin
	       			     end
            endcase   
        end
    end
 
 
//ila_0 your_instance_name (
//	.clk(clk), // input wire clk
	
//	.probe0(measure), // input wire [19:0]  probe0  
//	.probe1(measure_ready), // input wire [0:0]  probe1 
//	.probe2(s1), // input wire [19:0]  probe2 
//	.probe3(s1_ready), // input wire [0:0]  probe3 
//	.probe4(result_val), // input wire [0:0]  probe4 
//	.probe5(result) // input wire [39:0]  probe5
//);
    
endmodule