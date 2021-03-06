// +FHDR***********************************************************************
// Copyright        :   CNG
// Confidential     :   I LEVEL
// ============================================================================
// FILE NAME        :
// CREATE DATE      :   2017-06-26
// DEPARTMENT       :   R&D
// AUTHOR           :   TingtingGan
// AUTHOR'S EMAIL   :   gantingting@cng.com
// AUTHOR'S TEL     :   18280151291
// ============================================================================
// RELEASE  HISTORY
// VERSION  DATE        AUTHOR          DESCRIPTION
// V100     2017-06-26  TingtingGan     Original
// ============================================================================
// KEYWORDS         :
// PURPOSE          :
// ============================================================================
// REUSE ISSUES
// Reset Strategy   :   Async clear, active hign
// Clock Domains    :   clk_125m
// Critical Timing  :   N/A
// Instantiations   :   N/A
// Ynthesizable     :   N/A
// Others           :
// -FHDR***********************************************************************

`timescale 1 ns / 1 ps
module FCS32(
    //input port
    clk_sys                     ,   
    rst_sys                     ,   

    crc_din                     ,   
    crc_cap                     ,   
    crc_sop                     ,   
    crc_din_vld                 ,   

    //output port
    crc_dout            

    );

/**********************************************************************************\
***************************** declare parameter ************************************
\**********************************************************************************/

/**********************************************************************************\
***************************** declare interface signal *****************************
\**********************************************************************************/
// declare input singal
input                           clk_sys                             ;   
input                           rst_sys                             ;   
input   [7:0]                   crc_din                             ;   
input                           crc_cap                             ;   
input                           crc_sop                             ;   
input                           crc_din_vld                         ;   

// declare output signal
output  [31:0]                  crc_dout                            ;   

// declare inout signal

/**********************************************************************************\
**************************** declare singal attribute ******************************
\**********************************************************************************/
// wire signal
wire    [31:0]                  new_crc                             ;   
wire    [31:0]                  crc_dout                            ;   
wire    [31:0]                  crc_dout_invs                       ;   
wire    [7:0]                   crc_din_tmp                         ;   

// reg signal
reg     [31:0]                  crc_tmp                             ;   
reg     [31:0]                  cap_data                            ;   

/**********************************************************************************\
******************************** debug code ****************************************
\**********************************************************************************/

/**********************************************************************************\
********************************* main code ****************************************
\**********************************************************************************/
//msb is bit 7
assign crc_din_tmp[7:0] = {crc_din[0] , crc_din[1] , crc_din[2] , crc_din[3] ,
                               crc_din[4] , crc_din[5] , crc_din[6] , crc_din[7]} ;  // byte-wise

assign crc_dout_invs    = ~cap_data ; // invert

assign crc_dout[15:8]   = {crc_dout_invs[8] , crc_dout_invs[9] , crc_dout_invs[10] , crc_dout_invs[11] , 
                           crc_dout_invs[12] , crc_dout_invs[13] , crc_dout_invs[14] , crc_dout_invs[15]} ; // byte-wise

assign crc_dout[7:0]    = {crc_dout_invs[0] , crc_dout_invs[1] , crc_dout_invs[2] , crc_dout_invs[3] , 
                           crc_dout_invs[4] , crc_dout_invs[5] , crc_dout_invs[6] , crc_dout_invs[7]} ; // byte-wise

assign crc_dout[31:24]  = {crc_dout_invs[24] , crc_dout_invs[25] , crc_dout_invs[26] , crc_dout_invs[27] , 
                           crc_dout_invs[28] , crc_dout_invs[29] , crc_dout_invs[30] , crc_dout_invs[31]} ; // byte-wise

assign crc_dout[23:16]  = {crc_dout_invs[16] , crc_dout_invs[17] , crc_dout_invs[18] , crc_dout_invs[19] , 
                           crc_dout_invs[20] , crc_dout_invs[21] , crc_dout_invs[22] , crc_dout_invs[23]} ; // byte-wise

always @( posedge clk_sys or posedge rst_sys ) begin
    if( rst_sys == 1'b1 ) begin
        crc_tmp <=  { 32{1'b1} };
    end
    else begin
        if( crc_sop == 1'b1 ) begin
            crc_tmp <=  { 32{1'b1} };
        end
        else if( crc_din_vld == 1'b1 ) begin
            crc_tmp <=  new_crc ;
        end
        else ;
    end
end


//cap_data
always @( posedge clk_sys or posedge rst_sys ) begin
    if( rst_sys == 1'b1 ) begin 
        cap_data <=   32'b0 ;
    end
    else begin 
        if( crc_cap == 1'b1 ) begin
            cap_data <=  new_crc ;
        end
        else ;
    end
end


assign new_crc[0]  = crc_din_tmp[6] ^ crc_din_tmp[0] ^ crc_tmp[24] ^ crc_tmp[30];

assign new_crc[1]  = crc_din_tmp[7] ^ crc_din_tmp[6] ^ crc_din_tmp[1] ^ crc_din_tmp[0] 
                      ^ crc_tmp[24] ^ crc_tmp[25] ^ crc_tmp[30] ^ crc_tmp[31];

assign new_crc[2]  = crc_din_tmp[7] ^ crc_din_tmp[6] ^ crc_din_tmp[2] ^ crc_din_tmp[1] 
                     ^ crc_din_tmp[0] ^ crc_tmp[24] ^ crc_tmp[25] ^ crc_tmp[26]
                     ^ crc_tmp[30] ^ crc_tmp[31];

assign new_crc[3]  = crc_din_tmp[7] ^ crc_din_tmp[3] ^ crc_din_tmp[2] ^ crc_din_tmp[1] 
              ^ crc_tmp[25] ^ crc_tmp[26] ^ crc_tmp[27] ^ crc_tmp[31];

assign new_crc[4]  = crc_din_tmp[6] ^ crc_din_tmp[4] ^ crc_din_tmp[3] ^ crc_din_tmp[2] 
                     ^ crc_din_tmp[0] ^ crc_tmp[24] ^ crc_tmp[26] ^ crc_tmp[27]
                     ^ crc_tmp[28] ^ crc_tmp[30];

assign new_crc[5]  = crc_din_tmp[7] ^ crc_din_tmp[6] ^ crc_din_tmp[5] ^ crc_din_tmp[4] 
                      ^ crc_din_tmp[3] ^ crc_din_tmp[1] ^ crc_din_tmp[0] ^ crc_tmp[24] 
                      ^ crc_tmp[25] ^ crc_tmp[27] ^ crc_tmp[28] ^ crc_tmp[29]
                      ^ crc_tmp[30] ^ crc_tmp[31];

assign new_crc[6]  = crc_din_tmp[7] ^ crc_din_tmp[6] ^ crc_din_tmp[5] ^ crc_din_tmp[4] 
                      ^ crc_din_tmp[2] ^ crc_din_tmp[1] ^ crc_tmp[25] ^ crc_tmp[26] 
                      ^ crc_tmp[28] ^ crc_tmp[29] ^ crc_tmp[30] ^ crc_tmp[31];

assign new_crc[7]  = crc_din_tmp[7] ^ crc_din_tmp[5] ^ crc_din_tmp[3] ^ crc_din_tmp[2] 
                      ^ crc_din_tmp[0] ^ crc_tmp[24] ^ crc_tmp[26] ^ crc_tmp[27]
                      ^ crc_tmp[29] ^ crc_tmp[31];

assign new_crc[8]  = crc_din_tmp[4] ^ crc_din_tmp[3] ^ crc_din_tmp[1] ^ crc_din_tmp[0] 
                     ^ crc_tmp[0] ^ crc_tmp[24] ^ crc_tmp[25] ^ crc_tmp[27] ^ crc_tmp[28];

assign new_crc[9]  = crc_din_tmp[5] ^ crc_din_tmp[4] ^ crc_din_tmp[2] ^ crc_din_tmp[1] 
                     ^ crc_tmp[1] ^ crc_tmp[25] ^ crc_tmp[26] ^ crc_tmp[28] ^ crc_tmp[29];

assign new_crc[10] = crc_din_tmp[5] ^ crc_din_tmp[3] ^ crc_din_tmp[2] ^ crc_din_tmp[0] 
                     ^ crc_tmp[2] ^ crc_tmp[24] ^ crc_tmp[26] ^ crc_tmp[27] ^ crc_tmp[29];

assign new_crc[11] = crc_din_tmp[4] ^ crc_din_tmp[3] ^ crc_din_tmp[1] ^ crc_din_tmp[0] 
                      ^ crc_tmp[3] ^ crc_tmp[24] ^ crc_tmp[25] ^ crc_tmp[27] ^ crc_tmp[28];

assign new_crc[12] = crc_din_tmp[6] ^ crc_din_tmp[5] ^ crc_din_tmp[4] ^ crc_din_tmp[2] 
                      ^ crc_din_tmp[1] ^ crc_din_tmp[0] ^ crc_tmp[4] ^ crc_tmp[24] 
                      ^ crc_tmp[25] ^ crc_tmp[26] ^ crc_tmp[28] ^ crc_tmp[29] ^ crc_tmp[30];

assign new_crc[13] = crc_din_tmp[7] ^ crc_din_tmp[6] ^ crc_din_tmp[5] ^ crc_din_tmp[3] 
                     ^ crc_din_tmp[2] ^ crc_din_tmp[1] ^ crc_tmp[5] ^ crc_tmp[25] 
                     ^ crc_tmp[26] ^ crc_tmp[27] ^ crc_tmp[29] ^ crc_tmp[30] ^ crc_tmp[31];

assign new_crc[14] = crc_din_tmp[7] ^ crc_din_tmp[6] ^ crc_din_tmp[4] ^ crc_din_tmp[3] 
                     ^ crc_din_tmp[2] ^ crc_tmp[6] ^ crc_tmp[26] ^ crc_tmp[27]
                     ^ crc_tmp[28] ^ crc_tmp[30] ^ crc_tmp[31];

assign new_crc[15] = crc_din_tmp[7] ^ crc_din_tmp[5] ^ crc_din_tmp[4] ^ crc_din_tmp[3]
                     ^ crc_tmp[7] ^ crc_tmp[27] ^ crc_tmp[28] ^ crc_tmp[29] ^ crc_tmp[31];

assign new_crc[16] = crc_din_tmp[5] ^ crc_din_tmp[4] ^ crc_din_tmp[0] ^ crc_tmp[8]
                     ^ crc_tmp[24] ^ crc_tmp[28] ^ crc_tmp[29];

assign new_crc[17] = crc_din_tmp[6] ^ crc_din_tmp[5] ^ crc_din_tmp[1] ^ crc_tmp[9]
                     ^ crc_tmp[25] ^ crc_tmp[29] ^ crc_tmp[30];

assign new_crc[18] = crc_din_tmp[7] ^ crc_din_tmp[6] ^ crc_din_tmp[2] ^ crc_tmp[10]
                     ^ crc_tmp[26] ^ crc_tmp[30] ^ crc_tmp[31];

assign new_crc[19] = crc_din_tmp[7] ^ crc_din_tmp[3] ^ crc_tmp[11] ^ crc_tmp[27] ^ crc_tmp[31];

assign new_crc[20] = crc_din_tmp[4] ^ crc_tmp[12] ^ crc_tmp[28];

assign new_crc[21] = crc_din_tmp[5] ^ crc_tmp[13] ^ crc_tmp[29];

assign new_crc[22] = crc_din_tmp[0] ^ crc_tmp[14] ^ crc_tmp[24];

assign new_crc[23] = crc_din_tmp[6] ^ crc_din_tmp[1] ^ crc_din_tmp[0] ^ crc_tmp[15]
                     ^ crc_tmp[24] ^ crc_tmp[25] ^ crc_tmp[30];

assign new_crc[24] = crc_din_tmp[7] ^ crc_din_tmp[2] ^ crc_din_tmp[1] ^ crc_tmp[16] 
                     ^ crc_tmp[25] ^ crc_tmp[26] ^ crc_tmp[31];

assign new_crc[25] = crc_din_tmp[3] ^ crc_din_tmp[2] ^ crc_tmp[17] ^ crc_tmp[26] ^ crc_tmp[27] ;

assign new_crc[26] = crc_din_tmp[6] ^ crc_din_tmp[4] ^ crc_din_tmp[3] ^ crc_din_tmp[0] 
                     ^ crc_tmp[18] ^ crc_tmp[24] ^ crc_tmp[27] ^ crc_tmp[28] ^ crc_tmp[30];

assign new_crc[27] = crc_din_tmp[7] ^ crc_din_tmp[5] ^ crc_din_tmp[4] ^ crc_din_tmp[1]
                     ^ crc_tmp[19] ^ crc_tmp[25] ^ crc_tmp[28] ^ crc_tmp[29] ^ crc_tmp[31];

assign new_crc[28] = crc_din_tmp[6] ^ crc_din_tmp[5] ^ crc_din_tmp[2] ^ crc_tmp[20]
                     ^ crc_tmp[26] ^ crc_tmp[29] ^ crc_tmp[30];

assign new_crc[29] = crc_din_tmp[7] ^ crc_din_tmp[6] ^ crc_din_tmp[3] ^ crc_tmp[21]
                     ^ crc_tmp[27] ^ crc_tmp[30] ^ crc_tmp[31];

assign new_crc[30] = crc_din_tmp[7] ^ crc_din_tmp[4] ^ crc_tmp[22] ^ crc_tmp[28] ^ crc_tmp[31];

assign new_crc[31] = crc_din_tmp[5] ^ crc_tmp[23] ^ crc_tmp[29];

endmodule


