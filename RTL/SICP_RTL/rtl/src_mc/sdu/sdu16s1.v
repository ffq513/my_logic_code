// +FHDR***********************************************************************
// Copyright        :   CNG
// Confidential     :   I LEVEL
// ============================================================================
// FILE NAME        :   SDU16S1
// CREATE DATE      :   2017-08-23
// DEPARTMENT       :   R&D
// AUTHOR           :   TingtingGan
// AUTHOR'S EMAIL   :   gantingting@cng.com
// AUTHOR'S TEL     :   18280151291
// ============================================================================
// RELEASE  HISTORY
// VERSION  DATE        AUTHOR          DESCRIPTION
// V100     2017-08-23  TingtingGan     Original
// ============================================================================
// KEYWORDS         :
// PURPOSE          :   16 select 1 schedule machine
// ============================================================================
// REUSE ISSUES
// Reset Strategy   :   Async clear, active hign
// Clock Domains    :   clk_125m
// Critical Timing  :   N/A
// Instantiations   :   N/A
// Ynthesizable     :   N/A
// Others           :
// -FHDR***********************************************************************
`include "DEFINES.v"

module SDU16S1
    (
    clk_sys                     ,   
    rst_sys                     ,   
   
    chn_sdu_dval                ,    
    chn_sdu_data                ,    
    chn_sdu_empty               ,  
    sdu_chn_rden                ,

    fifo_rdreq                  ,   
    fifo_empty                  ,   
    fifo_rd_dval                ,   
    fifo_rd_data                 
    );

/**********************************************************************************\
***************************** declare parameter ************************************
\**********************************************************************************/
parameter   CHN_NUM         =   16 ; // 16 - 1 schedule
parameter   CHN_NUM_WIDTH   =   4  ;
parameter   DATA_WIDTH      =   18 ; // [17] : sop [16] : eop [15:0] : data  
/**********************************************************************************\
***************************** declare interface signal *****************************
\**********************************************************************************/
// declare input singal
input   wire                    clk_sys                             ;   
input   wire                    rst_sys                             ;   
input   wire    [CHN_NUM-1:0]   chn_sdu_dval  	                    ;   
input   wire    [DATA_WIDTH-1:0]chn_sdu_data    	                ;   
input   wire    [CHN_NUM-1:0]   chn_sdu_empty  	                    ;  
input   wire                    fifo_rdreq                          ;   

// declare output signal
output  wire    [CHN_NUM-1:0]   sdu_chn_rden   	                    ;   
output  reg                     fifo_empty                          ;   
output  wire                    fifo_rd_dval                        ;   
output  wire    [DATA_WIDTH-1:0]fifo_rd_data    	                ;   

// declare inout signal

/**********************************************************************************\
**************************** declare singal attribute ******************************
\**********************************************************************************/
// wire signal
wire        [CHN_NUM-1:0]       chn_eop_flag                        ;   
wire                            eop_flag                            ;   
wire                            rden_act                            ;   
wire                            rd_req                              ;   
wire        [CHN_NUM-1:0]       chn_rden   	                        ;   
wire        [CHN_NUM-1:0]       sdu_turn_empty  	                ;  
wire        [17:0]              rd_data                             ;  
wire                            rd_en                               ; 
wire                            wr_en                               ;   
wire        [17:0]              wr_data                             ;   

// reg signal
reg         [CHN_NUM_WIDTH-1:0] sdu_num                             ;   
reg                             eop_all_empty                       ;   
reg                             all_empty                           ;   
reg         [CHN_NUM-1:0]       sdu_empty                           ;  
reg                             rd_en_d1                            ;  
reg         [9:0]               memwaddr                            ;   
reg         [9:0]               memraddr                            ;  

/**********************************************************************************\
******************************** debug code ****************************************
\**********************************************************************************/

/**********************************************************************************\
********************************* main code ****************************************
\**********************************************************************************/

assign  sdu_turn_empty =   { chn_sdu_empty[0] , chn_sdu_empty[1] , chn_sdu_empty[2] , chn_sdu_empty[3] , 
                             chn_sdu_empty[4] , chn_sdu_empty[5] , chn_sdu_empty[6] , chn_sdu_empty[7] , 
                             chn_sdu_empty[8] , chn_sdu_empty[9] , chn_sdu_empty[10] , chn_sdu_empty[11] , 
                             chn_sdu_empty[12] , chn_sdu_empty[13] , chn_sdu_empty[14] , chn_sdu_empty[15]  };
genvar i;
generate
for( i = 0 ; i < CHN_NUM ; i = i+1 ) 
begin : nCHN

assign  chn_eop_flag[i] = ( chn_sdu_dval[i] == 1'b1 && chn_sdu_data[DATA_WIDTH-2] == 1'b1 ) ? 1'b1 : 1'b0 ;
assign  sdu_chn_rden[i] = ( chn_sdu_empty[i] == 1'b0 && sdu_num == i && rd_req == 1'b1 ) ? 1'b1 : 1'b0 ;
assign  chn_rden[i] = ( chn_sdu_empty[i] == 1'b0 && sdu_num == i ) ? 1'b1 : 1'b0 ;

end
endgenerate

always @( posedge clk_sys or negedge rst_sys ) begin
    if( rst_sys == 1'b0 ) begin
        sdu_num <=   4'h0 ;
    end
    else if( all_empty == 1'b1 ) begin
        if( chn_sdu_empty[0] == 1'b0 ) begin
            sdu_num <=   4'h0 ;
        end
        else if( chn_sdu_empty[1] == 1'b0 ) begin
            sdu_num <=   4'h1 ;
        end
        else if( chn_sdu_empty[2] == 1'b0 ) begin
            sdu_num <=   4'h2 ;
        end
        else if( chn_sdu_empty[3] == 1'b0 ) begin
            sdu_num <=   4'h3 ;
        end
        else if( chn_sdu_empty[4] == 1'b0 ) begin
            sdu_num <=   4'h4 ;
        end
        else if( chn_sdu_empty[5] == 1'b0 ) begin
            sdu_num <=   4'h5 ;
        end
        else if( chn_sdu_empty[6] == 1'b0 ) begin
            sdu_num <=   4'h6 ;
        end
        else if( chn_sdu_empty[7] == 1'b0 ) begin
            sdu_num <=   4'h7 ;
        end
        else if( chn_sdu_empty[8] == 1'b0 ) begin
            sdu_num <=   4'h8 ;
        end
        else if( chn_sdu_empty[9] == 1'b0 ) begin
            sdu_num <=   4'h9 ;
        end
        else if( chn_sdu_empty[10] == 1'b0 ) begin
            sdu_num <=   4'ha ;
        end
        else if( chn_sdu_empty[11] == 1'b0 ) begin
            sdu_num <=   4'hb ;
        end
        else if( chn_sdu_empty[12] == 1'b0 ) begin
            sdu_num <=   4'hc ;
        end
        else if( chn_sdu_empty[13] == 1'b0 ) begin
            sdu_num <=   4'hd ;
        end
        else if( chn_sdu_empty[14] == 1'b0 ) begin
            sdu_num <=   4'he ;
        end
        else if( chn_sdu_empty[15] == 1'b0 ) begin
            sdu_num <=   4'hf ;
        end
    end
    else if( eop_flag == 1'b1 ||( eop_all_empty == 1'b1 && rden_act == 1'b0 ) ) begin
        if( sdu_empty[15] == 1'b0 ) begin
            sdu_num <=   sdu_num + 4'h1 ;
        end
        else if( sdu_empty[14] == 1'b0 ) begin
            sdu_num <=   sdu_num + 4'h2 ;
        end
        else if( sdu_empty[13] == 1'b0 ) begin
            sdu_num <=   sdu_num + 4'h3 ;
        end
        else if( sdu_empty[12] == 1'b0 ) begin
            sdu_num <=   sdu_num + 4'h4 ;
        end
        else if( sdu_empty[11] == 1'b0 ) begin
            sdu_num <=   sdu_num + 4'h5 ;
        end
        else if( sdu_empty[10] == 1'b0 ) begin
            sdu_num <=   sdu_num + 4'h6 ;
        end
        else if( sdu_empty[9] == 1'b0 ) begin
            sdu_num <=   sdu_num + 4'h7 ;
        end
        else if( sdu_empty[8] == 1'b0 ) begin
            sdu_num <=   sdu_num + 4'h8 ;
        end
        else if( sdu_empty[7] == 1'b0 ) begin
            sdu_num <=   sdu_num + 4'h9 ;
        end
        else if( sdu_empty[6] == 1'b0 ) begin
            sdu_num <=   sdu_num + 4'ha ;
        end
        else if( sdu_empty[5] == 1'b0 ) begin
            sdu_num <=   sdu_num + 4'hb ;
        end
        else if( sdu_empty[4] == 1'b0 ) begin
            sdu_num <=   sdu_num + 4'hc ;
        end
        else if( sdu_empty[3] == 1'b0 ) begin
            sdu_num <=   sdu_num + 4'hd ;
        end
        else if( sdu_empty[2] == 1'b0 ) begin
            sdu_num <=   sdu_num + 4'he ;
        end
        else if( sdu_empty[1] == 1'b0 ) begin
            sdu_num <=   sdu_num + 4'hf ;
        end
        else begin
            sdu_num <=   sdu_num ;
        end
    end 
end

always @( * ) begin
    case( sdu_num )
        4'h0    :   sdu_empty    =  { sdu_turn_empty[14:0], sdu_turn_empty[15] } ;
        4'h1    :   sdu_empty    =  { sdu_turn_empty[13:0], sdu_turn_empty[15:14] } ;
        4'h2    :   sdu_empty    =  { sdu_turn_empty[12:0], sdu_turn_empty[15:13] } ;
        4'h3    :   sdu_empty    =  { sdu_turn_empty[11:0], sdu_turn_empty[15:12] } ;
        4'h4    :   sdu_empty    =  { sdu_turn_empty[10:0], sdu_turn_empty[15:11] } ;
        4'h5    :   sdu_empty    =  { sdu_turn_empty[9:0] , sdu_turn_empty[15:10] } ;
        4'h6    :   sdu_empty    =  { sdu_turn_empty[8:0] , sdu_turn_empty[15:9] } ;
        4'h7    :   sdu_empty    =  { sdu_turn_empty[7:0] , sdu_turn_empty[15:8] } ;
        4'h8    :   sdu_empty    =  { sdu_turn_empty[6:0] , sdu_turn_empty[15:7] } ;
        4'h9    :   sdu_empty    =  { sdu_turn_empty[5:0] , sdu_turn_empty[15:6] } ;
        4'ha    :   sdu_empty    =  { sdu_turn_empty[4:0] , sdu_turn_empty[15:5] } ;
        4'hb    :   sdu_empty    =  { sdu_turn_empty[3:0] , sdu_turn_empty[15:4] } ;
        4'hc    :   sdu_empty    =  { sdu_turn_empty[2:0] , sdu_turn_empty[15:3] } ;
        4'hd    :   sdu_empty    =  { sdu_turn_empty[1:0] , sdu_turn_empty[15:2] } ;
        4'he    :   sdu_empty    =  { sdu_turn_empty[0], sdu_turn_empty[15:1] } ;
        4'hf    :   sdu_empty    =  sdu_turn_empty ;
        default :   sdu_empty    =  sdu_turn_empty ;
    endcase
end

assign  eop_flag = | chn_eop_flag ;
assign  rden_act = | chn_rden ;
assign  rd_req   = ( fifo_empty == 1'b1 && all_empty == 1'b0 ) ? 1'b1 : 1'b0 ;

always @( posedge clk_sys or negedge rst_sys ) begin
    if( rst_sys == 1'b0 ) begin
        all_empty   <=   1'b0 ;
    end
    else if( & chn_sdu_empty == 1'b1 ) begin
        all_empty   <=   1'b1 ;   
    end
    else begin
        all_empty   <=   1'b0 ;
    end
end

always @( posedge clk_sys or negedge rst_sys ) begin
    if( rst_sys == 1'b0 ) begin
        eop_all_empty   <=   1'b0 ;   
    end
    else begin
        if( eop_all_empty == 1'b1 && all_empty == 1'b0 ) begin
            eop_all_empty   <=   1'b0 ;
        end
        else if( eop_flag == 1'b1 && ( & sdu_empty[CHN_NUM-1:1] == 1'b1 ) ) begin
            eop_all_empty   <=   1'b1 ;
        end
        else ;
    end
end

//----------------------------------------------------------------------------------
// fifo
//----------------------------------------------------------------------------------
assign  wr_en   =   | chn_sdu_dval ;
assign  wr_data =   chn_sdu_data ;

always @( posedge clk_sys or negedge rst_sys ) begin
    if( rst_sys == 1'b0 ) begin
        rd_en_d1   <=   1'b0 ;
    end
    else begin
        rd_en_d1   <=   rd_en ;
    end
end

always @( posedge clk_sys or negedge rst_sys ) begin
    if( rst_sys == 1'b0 ) begin
        fifo_empty   <=   1'b1 ;
    end
    else begin
        if( rd_en == 1'b1 && rd_data[16] == 1'b1 ) begin
            fifo_empty   <=   1'b1 ;  
        end
        else if( wr_en == 1'b1 && wr_data[16] == 1'b1 ) begin
            fifo_empty   <=   1'b0 ;  
        end
    end
end

assign  rd_en = ( fifo_empty == 1'b0 && fifo_rdreq == 1'b1 ) ? 1'b1 : 1'b0 ;
assign  fifo_rd_dval = ( rd_en_d1 == 1'b1 && fifo_empty == 1'b0 ) ? 1'b1 : 1'b0 ;
assign  fifo_rd_data = rd_data ;

//----------------------------------------------------------------------------------
// read & write address generator
//----------------------------------------------------------------------------------
always @( posedge clk_sys or negedge rst_sys ) begin
    if( rst_sys == 1'b0 ) begin
        memwaddr <= 10'h00 ;
    end
    else begin
        if( wr_en == 1'b1 ) begin
            if( memwaddr == 1023 ) begin 
                memwaddr <= 10'h00 ;
            end
            else begin
                memwaddr <= memwaddr + 1'b1 ;
            end
        end
    end
end

always @( posedge clk_sys or negedge rst_sys ) begin
    if( rst_sys == 1'b0 ) begin
        memraddr <= 10'h00 ;
    end
    else begin
        if( rd_en == 1'b1 ) begin
            if( memraddr == 1023 ) begin 
                memraddr <= 10'h00 ;
            end
            else if( rd_en == 1'b1 && rd_data[16] == 1'b1 ) begin
                memraddr <= memraddr ;
            end
            else begin
                memraddr <= memraddr + 1'b1 ;
            end
        end
    end
end

    RAM1K18                     U_LSRAM_W10D1024 
    (
    .A_DOUT                     ( rd_data                           ), 
    .B_DOUT                     (                                   ), 
    .BUSY                       (                                   ), 
    .A_CLK                      ( clk_sys                           ), 
    .A_DOUT_CLK                 ( 1'b1                              ), 
    .A_ARST_N                   ( 1'b1                              ), 
    .A_DOUT_EN                  ( 1'b1                              ), // 0 : register holds previous data ; 1 : normal register operation 
    .A_BLK                      ( 3'b111                            ), // 111 : perform read or write operation on port A 
    .A_DOUT_ARST_N              ( 1'b1                              ), 
    .A_DOUT_SRST_N              ( 1'b1                              ), 
    .A_DIN                      ( 18'h00                            ),  
    .A_ADDR                     ( { memraddr , 4'h0 }               ), // used bits [13:4] , [3:0] to be grounded 
    .A_WEN                      ( 2'b00                             ), // 00 : read operation
    .B_CLK                      ( clk_sys                           ), 
    .B_DOUT_CLK                 ( 1'b1                              ), 
    .B_ARST_N                   ( 1'b1                              ), 
    .B_DOUT_EN                  ( 1'b1                              ), // 0 : register holds previous data ; 1 : normal register operation
    .B_BLK                      ( { wr_en , 2'b11 }                 ), // 011 : no operation ; 111 : read or write operation 
    .B_DOUT_ARST_N              ( 1'b0                              ), 
    .B_DOUT_SRST_N              ( 1'b1                              ), 
    .B_DIN                      ( wr_data                           ), 
    .B_ADDR                     ( { memwaddr, 4'h0 }                ), // used bits [13:4] , [3:0] to be grounded  
    .B_WEN                      ( 2'b11                             ), // 11 : write[15:0]
    .A_EN                       ( 1'b1                              ), // power down , active low
    .A_DOUT_LAT                 ( 1'b1                              ), // 0 : register operation ; 1 : latch operation 
    .A_WIDTH                    ( 3'b100                            ), // 100: 1k*18 / 1k*16
    .A_WMODE                    ( 1'b1                              ), // 0 : output data port holds the previous value ; 1 : feed-through 
    .B_EN                       ( 1'b1                              ), // power down , active low
    .B_DOUT_LAT                 ( 1'b1                              ), // 0 : register operation ; 1 : latch operation
    .B_WIDTH                    ( 3'b100                            ), // 100: 1k*18 / 1k*16 
    .B_WMODE                    ( 1'b1                              ), // 0 : output data port holds the previous value ; 1 : feed-through 
    .SII_LOCK                   ( 1'b0                              )
    );


endmodule
