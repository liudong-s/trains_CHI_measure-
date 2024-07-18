module  GeneticAlgorithm#(
    parameter              Mov = 6,
    parameter              Po_Size = 100,
    parameter              Ev_Algebra = 250,
    parameter              length = 20,
    parameter              De_Variable=16,
    parameter              Tran_Size=64
)
(
    input   wire            clk_100     ,   
    input   wire            rst_n   ,   
    
    input   [length*De_Variable-1:0]  chromosome,
    input                             chromosomeEn,
    input     [8:0]                   addr_measure,
    input   [length*5-1:0]            setin,
    input                             setinEn,
    input     [8:0]                   addr_set,
    input   [39:0]                    lable,
    input                             lableEn,
    input [8:0]                       addr_lable,
    
    output reg   [39:0]               minFitness,
    output reg                        result_fit_done,
    output reg [length*De_Variable-1:0]  result_chor,
    output reg                      result_chor_done

   
);
      
//(*ram_style = "block"*)reg [length*De_Variable-1:0] nowpopulation[0:Po_Size-1];
reg [length*De_Variable-1:0] midpopulation1[0:Po_Size/2-1];
reg [length*De_Variable-1:0] midpopulation2[0:Po_Size/2-1];
(*ram_style = "block"*)reg [39:0] unFitness[0:Po_Size-1];
(*ram_style = "block"*)reg [39:0] unFitness_temp[0:Po_Size-1];
(*ram_style = "block"*)reg [length*5-1:0] set[0:Tran_Size-1];
(*ram_style = "block"*)reg [39:0]lables[0:Tran_Size-1];
reg genetic_flag;

reg        [19:0]          measure; 
reg                        measure_ready; 
reg        [19:0]          s1; 
reg                        s1_ready;  
wire         [8:0]          result_index;   

wire          [39:0]          result;
wire                         result_val;
wire                         phase1 ;            

//reg quit;
//reg lock;
reg result_val_con;
reg [length*De_Variable-1:0] measure_temp;
reg [length*5-1:0] set_temp;
reg receive_chro_done;
reg corss_done;
reg update_now;
//reg update_now2;
reg [8:0] update_index;
reg fit_done_next;

//reg select_start;
//(*ram_style = "block"*)reg [39:0] unFitness_mid[Po_Size-1:0];
reg select_done;

reg  [8:0]index_now; 
reg  [8:0] index_set;
reg  [2:0] con;
reg  [4:0] measure_temp_i;
reg  [2:0] set_temp_i;

reg [9:0] iteration_num;
reg genetic_done;

reg  [8:0]  index_result;
reg  [39:0] result_buf;
reg   dispose_result;
reg   [2:0]con_result;
reg   [47:0] fit_buf;
//reg   [47:0] fit_buf_temp;
reg   [47:0] unFitness_buf;

// reg   [16:0] fit_buf;
// reg   [16:0] fit_buf_temp;
// reg   [16:0] unFitness_buf;


reg   [8:0]  index_fit;
reg    fit_done;

reg  [8:0]                        addra;
reg  [length*De_Variable-1:0]     dina;	
reg                                wea;		                         
reg   [8:0]       addrb1;
reg   [8:0]       addrb2;
wire   [8:0]       addrb3;
reg   [8:0]       addrb4;
wire   [8:0]       addrb;
wire  [length*De_Variable-1:0]   doutb;
reg result_val_sort1;

reg[47:0] operand1;
reg[47:0] operand2;
reg      adder_en;
    
wire[47:0] sum;
wire   sum_vail;
reg add_start;


//接收chromosome
always@(posedge clk_100 ) begin
   if(rst_n == 1'b0)begin
        update_now <= 1'b0;
        select_done <= 1'b0;
        update_index <= 9'd0;
        
        index_result <= 9'd0;
        dispose_result <= 1'b0;
        con_result <= 3'd0;
       
        index_fit <= 9'd0;
        fit_done <= 1'b0;
        fit_done_next <= 1'b0;
        wea <= 1'b0;
        
       fit_buf <= 48'd0;
       unFitness_buf<=48'd0;
       adder_en <= 1'b0;
       add_start <= 1'b0;
   end
   else if(chromosomeEn == 1'b1) begin
        wea <= 1'b1;
        addra <= addr_measure;
        dina <= chromosome;         
        if(addr_measure == Po_Size-1)begin
            receive_chro_done <= 1'b1;          
        end
    end 
    else if(result_val == 1'b1  ||  dispose_result == 1'b1 )begin
        adder_en <= 1'b0; 
        case(con_result)
            3'd0:begin
                    dispose_result <= 1'b1;                   
                    if(result_val == 1'b1) begin
                        result_buf <= result;
                        con_result <= con_result + 3'd1;
                    end else ;                  
                   end
            3'd1:begin 
                    con_result <= con_result + 3'd1; 
                    if(result_buf >= lables[index_result])begin
                        unFitness_buf <= result_buf - lables[index_result];                       
                    end else begin
                        unFitness_buf <= lables[index_result] - result_buf;                         
                        end                   
                  end
           3'd2:begin                   
                        operand1 <= fit_buf;
                        operand2 <= unFitness_buf;
                        adder_en <= 1'b1;
                        add_start <= 1'b1;
                        con_result <= con_result + 3'd1;
                end 
            3'd3:begin
                    if(sum_vail == 1'b1) begin
                        fit_buf <= sum;
                        index_result <= index_result + 9'd1;
                        con_result <= 3'd0;
                        add_start <= 1'b0;
                        if(index_result == Tran_Size-1) begin
                            index_result <= 9'd0;
                            con_result <= con_result + 3'd1;
                        end else ; 
                    end
                    else con_result <= con_result;
                 end             
            3'd4:begin
                    if(result_val_con == 1'b0) begin
                        unFitness[index_fit] <= fit_buf >> Mov;
                    end
                    else  begin
                            unFitness_temp[index_fit] <= fit_buf >> Mov;
                    end
                      con_result <= con_result + 3'd1;
//                      index_fit <= index_fit+9'd1;
//                      fit_buf <= 48'd0;                    
//                      con_result <= 3'd0;                  
//                      if(index_fit == Po_Size-1) begin
//                        dispose_result <= 1'b0;                       
//                        index_fit <= 9'd0;
//                        if(result_val_con == 1'b0) begin
//                           fit_done <= 1'b1;
//                        end
//                      else fit_done_next <= 1'b1;
//                   end
//                   else ;                
              end
            3'd5:begin
                     index_fit <= index_fit+9'd1;
                     fit_buf <= 48'd0;
                     con_result <= 3'd0;
                     if(index_fit == Po_Size-1) begin
                         dispose_result <= 1'b0;                       
                         index_fit <= 9'd0;
                         if(result_val_con == 1'b0) begin
                             fit_done <= 1'b1;
                         end
                         else fit_done_next <= 1'b1;
                     end
                     else ;              
              end  
           default:begin
                   end
        endcase  
    end
    else if(fit_done_next == 1) begin  //更新nowpopulation
        fit_done_next <= 1'b0;
        update_now <= 1'b1;
    end
     else  if(update_now == 1'b1) begin
        wea <= 1'b0;
        if(unFitness_temp[update_index] < unFitness[update_index] ) begin
            wea <= 1'b1;
            addra <= update_index;          
            if(update_index<Po_Size/2)begin
               dina <= midpopulation1[update_index];
            end
            else begin
                dina <= midpopulation2[update_index-Po_Size/2];
            end           
            unFitness[update_index] <= unFitness_temp[update_index];
        end else ;  
        if(update_index == Po_Size-1)begin
            update_now <= 1'b0; 
            select_done <= 1'b1;            
        end
        else begin
            update_index <= update_index + 1;   
        end            
    end
    else begin
        receive_chro_done <= 1'b0;
        select_done <= 1'b0;
        fit_done <= 1'b0;
        fit_done_next <= 1'b0;
        wea <= 1'b0;
        update_index <= 9'd0;
    end
end

//接收set
always@(posedge clk_100) begin
    if(setinEn == 1'b1) begin
        set[addr_set] = setin;
    end
    else   ; 
end

//接收labels
always@(posedge clk_100 ) 
    if(lableEn == 1'b1) begin
        lables[addr_lable] <= lable;
    end
    else ;


always@(posedge clk_100 or negedge rst_n) begin      //控制迭代次数
    if(rst_n == 1'b0) begin 
        genetic_flag <= 1'b0;
        genetic_done <= 1'b0;
        iteration_num <= 10'd0;
    end
    else if(fit_done == 1'b1) begin
        genetic_flag <= 1'b1;
    end
    else if(select_done==1'b1 )begin
        if(iteration_num == Ev_Algebra-1)  begin
            iteration_num <= 10'd0;
            genetic_flag <= 1'b0;
            genetic_done <= 1'b1;                    
        end
        else begin
            iteration_num <= iteration_num + 10'd1;
            genetic_flag <= 1'b1;
           
        end      
    end
    else begin
            genetic_flag <= 1'b0;
            genetic_done <= 1'b0;
    end
end

reg receive_chro_done1;
always@(posedge clk_100) receive_chro_done1 <= receive_chro_done;
always@(posedge clk_100) begin          //计算适应度
    if(rst_n == 1'b0) begin
        index_now <= 9'd0;
        index_set <= 9'd0;
        con <= 3'd0;
        measure_temp_i <= 5'd0;
        measure <= 20'd0;
        measure_ready <= 1'b0;
        s1 <= 20'd0;
        s1_ready <= 1'b0;
        set_temp_i <= 3'd0;
    end
    else if(receive_chro_done1 == 1'b1 ||corss_done == 1'b1 )begin
        con <= 3'd1;       
    end
    else begin
        case(con)
            3'd0:begin
                    index_now <= 9'd0;
                    index_set <= 9'd0;
                    measure_temp_i <= 5'd0;
                    set_temp_i <= 3'd0;
              end
            3'd1:begin
                    if(result_val_con==1'b0) begin
                        addrb1 <= index_now;                                           
                    end  
                    else ;                   
                    con <= 3'd2;
                 end
            3'd2: begin 
                    if(result_val_con==1'b1)begin
                        if(index_now < Po_Size/2)begin
                            measure_temp <= midpopulation1[index_now];
                        end
                        else if(index_now >= Po_Size/2)begin
                             measure_temp <= midpopulation2[index_now-Po_Size/2];
                        end
                    end 
                    else measure_temp <= doutb;  
                    set_temp <= set[index_set];
                    index_set <= index_set + 9'd1;
                    con <= 3'd3;
                    if(index_set == Tran_Size -1)begin
                        index_now <= index_now + 9'd1;
                        index_set <= 9'd0;
                    end else ;               
               end
            3'd3: begin  //传送参数
                    if(measure_temp_i == 5'd16)  begin
                        measure_temp_i <= 5'd0;
                        set_temp_i <= 3'd0;
                        measure_ready <= 1'b0;
                        con <= con + 3'd1;
                    end 
                    else begin
                        measure_temp <= measure_temp >> 20;
                        measure <= measure_temp[19:0];
                        measure_temp_i <= measure_temp_i + 5'd1; 
                        measure_ready <= 1'b1;
                        
                        if(set_temp_i == 3'd5)begin
                            s1_ready <= 1'b0;
                        end 
                        else begin
                            set_temp <= set_temp >> 20;
                            s1 <= set_temp[19:0];
                            set_temp_i <= set_temp_i + 3'd1;
                            s1_ready <= 1'b1;
                        end
                    end                
                    // if(measure_temp_i <= 5'd15)begin
                        // measure_temp <= measure_temp >> 20;
                        // measure <= measure_temp[19:0];
                        // measure_temp_i <= measure_temp_i + 5'd1; 
                        // measure_ready <= 1'b1;
                    // end
                    // if(set_temp_i < 3'd5) begin
                        // set_temp <= set_temp >> 20;
                        // s1 <= set_temp[19:0];
                        // set_temp_i <= set_temp_i + 3'd1;
                        // s1_ready <= 1'b1;
                    // end 
                    // if(set_temp_i == 3'd5)begin
                        // s1_ready <= 1'b0;
                    // end
                    // if(measure_temp_i == 5'd16)  begin
                        // measure_temp_i <= 5'd0;
                        // set_temp_i <= 3'd0;
                        // measure_ready <= 1'b0;
                        // con <= con + 3'd1;
                    // end                  
               end
            3'd4: begin
                    if(phase1 == 1'b1) begin
                        con <= 3'd1;
                    end 
                    else if(index_set == 0 && index_now == Po_Size) begin
                        con <= 3'd0;
                    end
                    else con <= 3'd4; 
               end
            default:begin
                    end
        endcase
    end																
end

//***********************************************种群进化*****************************************//

reg [39:0]       data_in; 
reg [8:0]     ram_cnt_in;            
reg                en; 
           
wire [39:0]        result_sort;
wire          result_val_sort;
wire                done_sort;

reg start_sort;
reg [8:0] fit_i;
reg stop_sort;
reg [8:0] copy_i;
reg copy_done;
//integer copy_j;


reg [4:0] localx1;
reg [4:0] localx2; 
//wire [4:0] corss_start;
//wire [4:0] corss_end;
reg [4:0] corss_start;
reg [4:0] corss_end;
reg [4:0] corss_point;
reg [4:0] ponit_num;
reg [8:0] corss_number;
reg start_corss;
//reg corss_go;
reg [3:0] corss_con;
reg [7:0] seed;
//integer corss_i;
reg [8:0] new_j;
reg [4:0] local_variate;
reg [4:0] local_variate2;
reg [length*De_Variable-1:0] evolve;
reg [length*De_Variable-1:0] evolve2;
//reg [length*De_Variable-1:0] buffer;
reg [7:0] rand_num;
reg load;
reg next_flag1;
reg next_flag2;


//适应度排序
always@(posedge clk_100) begin
    if(rst_n == 1'b0)begin
        seed <= 8'd0;
    end
    else seed <= seed + 8'd1;
end


always@(posedge clk_100 or negedge rst_n)
begin
    if(!rst_n)
        rand_num    <=8'b0;
    else if(load)
        rand_num <=seed;    
    else
        begin
            rand_num[0] <= rand_num[7];
            rand_num[1] <= rand_num[0];
            rand_num[2] <= rand_num[1];
            rand_num[3] <= rand_num[2];
            rand_num[4] <= rand_num[3]^rand_num[7];
            rand_num[5] <= rand_num[4]^rand_num[7];
            rand_num[6] <= rand_num[5]^rand_num[7];
            rand_num[7] <= rand_num[6];
        end
            
end

always@(posedge clk_100) begin
    if(rst_n == 1'b0) begin 
        data_in <= 40'd0;
        ram_cnt_in <= 9'd0;
        start_sort <= 1'b0;
        fit_i <= 9'd0;   
        en <= 1'b0;
    end
    else if(genetic_flag == 1'b1 ) begin
        start_sort <= 1'b1;
    end
    else if(start_sort == 1'b1) begin
        data_in <= unFitness[fit_i];
        fit_i <= fit_i + 9'd1;
        en <= 1'b1;
        if(fit_i == Po_Size-1) begin
            start_sort <= 1'b0;
            fit_i <= 9'd0;
        end
    end
    else begin
         start_sort <= 1'b0; 
         en <= 1'b0;
    end  
end

reg done_sort1;
always@(posedge clk_100) result_val_sort1<=result_val_sort;
always@(posedge clk_100) done_sort1 <= done_sort;

//assign corss_start = (localx1 <= localx2) ? localx1:localx2;
//assign corss_end = (localx2 >= localx1) ? localx2:localx1;

always@(posedge clk_100) begin
    if(rst_n == 1'b0) begin
        stop_sort <= 1'b0;
        copy_i <= 9'b0;
        copy_done <= 1'b0;
        start_corss <= 1'b0;
        corss_number <= 9'd0;
        corss_con <= 4'd0; 
        load  <= 1'b0;   
        next_flag1 <= 1'b0;
        next_flag2 <= 1'b0;
        localx1 <= 5'd0;
        localx2 <= 5'd0;
        ponit_num <= 5'd0;
        corss_point <= 5'd0;     
    end
    //种群复制 unFitness midpopulation
    else if((result_val_sort == 1'b1 || result_val_sort1 == 1'b1) && stop_sort == 0 ) begin 
        if(result_val_sort == 1'b1)begin
            addrb2 <= result_index-1;
        end
        else begin
            midpopulation1[copy_i] <= doutb;
            midpopulation2[copy_i] <= doutb;          
            copy_i <= copy_i + 9'd1;
            if(copy_i == (Po_Size-1)/2 || done_sort1) begin
                copy_i <= 9'd0;              
                copy_done <= 1'b1;
                if(done_sort1 == 1'b0)begin
                    stop_sort <= 1'b1;
                end
            end else ;
        end
    end
    // else if(copy_i > 0 && done_sort)begin
            // copy_i <= 9'd0;
            //stop_sort <= 1'b1;
            // copy_done <= 1'b1;
    // end
    //种群杂交和变异 midpopulation
    else if(copy_done == 1'b1)begin
        start_corss <= 1'b1;
        copy_done <= 1'b0;
        load  <= 1'b1; 
    end
    else if(start_corss == 1'b1) begin
        if(done_sort1 == 1) begin
            stop_sort <= 1'b0;
        end   else ;
        load  <= 1'b0; 
        case(corss_con)
            4'd0:begin
                    corss_con <= corss_con+4'd1;
                    corss_number <= 9'd0;
              end
            4'd1:begin
                    if(corss_number % 2 == 0)begin
                         evolve <= midpopulation1[corss_number];
                         evolve2 <= midpopulation2[corss_number+1];
                    end
                    else if(corss_number % 2 == 1)begin
                        evolve <= midpopulation1[corss_number];
                        evolve2 <= midpopulation2[corss_number-1];
                    end 
                    else ;
                    localx1 <= rand_num % 19;
                    corss_con  <= corss_con+4'd1;
              end
            4'd2:begin
                    localx2 <= rand_num % 19;
                    ponit_num <= 5'd0;
                    corss_point <= 5'd0;   
                    corss_con  <= corss_con+4'd1;
                 end
            4'd3:begin
                    if(localx1<localx2)begin
                        corss_start <= localx1;
                        corss_end <= localx2;
                    end else begin
                        corss_start <= localx2;
                        corss_end <= localx1;
                    end                           
                    corss_con  <= corss_con+4'd1;           
                 end
            4'd4:begin
                       corss_point <= corss_start+ponit_num;
                       if(corss_point == corss_end) begin
                             corss_con  <= 4'd6;
                             local_variate<= rand_num % 19;
                       end
                       else begin
                            corss_con  <= corss_con+4'd1;
                       end
                 end
            4'd5:begin //杂交                  
                    for(new_j=1;new_j<De_Variable-1;new_j=new_j+1)begin
                         if(evolve[new_j*length+corss_point] != evolve2[new_j*length+corss_point] ) begin
                              evolve[new_j*length+corss_point] <= ~evolve[new_j*length+corss_point];
                              evolve2[new_j*length+corss_point] <= ~evolve2[new_j*length+corss_point];
                         end  else ;                                                    
                    end                  
                    ponit_num <= ponit_num + 5'd1;
                    local_variate2<= rand_num % 19;
                    corss_con  <= 4'd4;
              end
            4'd6:begin //变异  nextpopulation
                    for(new_j=1;new_j<De_Variable-1;new_j=new_j+1)begin                                       
                        evolve[new_j*length+local_variate] <= ~evolve[new_j*length+local_variate];  
                        evolve2[new_j*length+local_variate2] <= ~evolve2[new_j*length+local_variate2]; 
                        // evolve[new_j*length+localx1] <= ~evolve[new_j*length+localx1];  
                        // evolve2[new_j*length+localx1] <= ~evolve2[new_j*length+localx1];    
                    end
                     corss_con  <= corss_con+4'd1;
              end
            4'd7:begin
                    for(new_j=1;new_j<De_Variable-1;new_j=new_j+1)begin
                        if(evolve[new_j*length+:20] >= 1000000) begin  
                            next_flag1 <= 1'b1;                         
                        end else ;
                        if(evolve2[new_j*length+:20] >= 1000000) begin
                            next_flag2 <= 1'b1;                           
                        end else ;
                    end
                    corss_con <= corss_con+4'd1;
             end 
            4'd8:begin
                    if(next_flag1 == 0) begin
                        midpopulation1[corss_number] <= evolve;
                    end else ;
                    if(next_flag2 == 0) begin
                        if(corss_number % 2 == 0)begin                     
                             midpopulation2[corss_number+1] <= evolve2;
                        end  
                        else begin                    
                             midpopulation2[corss_number-1] <= evolve2;
                        end                       
                    end else ;
                    corss_con <= corss_con+4'd1;
              end
            4'd9:begin               
                    if(corss_number==Po_Size/2-1) begin
                       corss_con <= corss_con+4'd1;                     
                    end
                    else begin
                       corss_con <= 4'd1; 
                       corss_number <= corss_number+9'd1;
                       next_flag1 <= 1'b0;
                       next_flag2 <= 1'b0;
                    end
              end
          
            4'd10:begin    //结束
                start_corss  <= 1'b0;
                corss_done <= 1'b1;
                corss_con <= 4'd0;
                corss_number <= 9'd0;
                next_flag1 <= 1'b0;
                next_flag2 <= 1'b0;
              end
            default:begin
                    end
        endcase
    end
    else begin
        if(done_sort1 == 1) begin
            stop_sort <= 1'b0;
        end   
        copy_done <= 1'b0;
        corss_done <= 1'b0;       
    end
end

//**********************************result_val输出控制***********************************//

always@(posedge clk_100) begin
    if(rst_n == 1'b0) begin
        result_val_con <= 1'b0;
    end
    else if(fit_done == 1'b1) begin
        result_val_con <= 1'b1;
    end
    else if(genetic_done == 1'b1) begin
        result_val_con <= 1'b0;
    end
    else result_val_con <= result_val_con;
end

//*****************************输出结果***************************************************//

reg result_fit_start;
reg [8:0]loop;
reg [8:0] chor_index;
reg result_fit_done1;

always@(posedge clk_100) begin
    if(rst_n == 1'b0) begin
        result_fit_start <= 1'b0;
        loop <= 9'd0;
        result_fit_done <= 1'b0;
        chor_index <= 9'd0;
        minFitness = {40{1'b1}};     
    end  
    else if(genetic_done==1)begin
        result_fit_start <= 1'b1;
    end
    else if(result_fit_start == 1'b1)begin
        if(unFitness[loop] < minFitness) begin
            minFitness <= unFitness[loop];
            chor_index <= loop;
        end else ;            
        
        if(loop == Po_Size-1)begin
           loop <= 9'd0;
           result_fit_start <= 1'b0;
           result_fit_done <= 1'b1;
           //lock <= 1'b0;
        end
        else begin       
           loop <= loop + 9'd1; 
        end           
    end
    else begin
        result_fit_done <= 1'b0;  
    end
end  
  
always@(posedge clk_100) result_fit_done1 <= result_fit_done;
always@(posedge clk_100) begin
    if(rst_n == 1'b0) begin
        result_chor_done <= 1'b0;
    end
    else if(result_fit_done) begin
        addrb4 <= chor_index;
    end
    else if(result_fit_done1 == 1'b1)begin
        result_chor <= doutb;
        result_chor_done <= 1'b1;
    end
    else result_chor_done <= 1'b0;
end

assign addrb3=result_val_sort1  ? addrb2:addrb1;
assign addrb = result_fit_done1 ? addrb4 :addrb3; 
//assign nowpopulation_temp =  nowpopulation[result_index];

calculateChoquet
#(
    .n(4)
)
calculateChoquet_i
(
    .clk                 (clk_100          ),
    .rst_n               (rst_n        ),
   
    .measure             (measure      ), 
    .s1                  (s1           ),   
                                    
    .result              (result       ),
    .result_val          (result_val   ),
    
    .measure_ready       (measure_ready      ),
    .s1_ready            (s1_ready           ),
    .phase1              (phase1             )
    
);

 
sort 
#(
    .N(Po_Size)
)
sort_i
(
    .       clk (       clk_100 ),
    .     rst_n (     rst_n ),
    .   data_in (   data_in ),   
    .     en (     en       ),      //排序信号 拉高一个时钟周期
                            
    .   result(   result_sort),
    .   result_val(   result_val_sort),     //输出有效信号
    .  result_index ( result_index),
    .done(done_sort)
);  

ram_population
#(
    .DATA_WDTH(length*De_Variable),      //输入数据的位宽
    .COL(Po_Size),				//RAM中数据个数
    .COL_BITS(9)           //地址线位数
)
my_ram_population(
    .clk  (clk_100  ) ,			//时钟信号
    .addra(addra) ,			//写入数据的地址
    .dina (dina ) ,			//写入的数据
    .wea  (wea  ) ,			//写有效信号
          
    .addrb(addrb) ,			//输出数据的地址
    .doutb(doutb)			//输出的数据
);


ila_0 my_lia0(
	.clk(clk_100), // input wire clk


	.probe0(result_fit_done), // input wire [0:0]  probe0  
	.probe1(minFitness), // input wire [39:0]  probe1 
	.probe2(select_done), // input wire [0:0]  probe2
	.probe3(iteration_num) // input wire [9:0]  probe3
);


adder adder_i(
    .clk     (clk_100),
    
    .operand1(operand1),
    .operand2(operand2),
    .adder_en(adder_en),
    
    .sum      (sum     ),
    .sum_vail (sum_vail)
);

endmodule