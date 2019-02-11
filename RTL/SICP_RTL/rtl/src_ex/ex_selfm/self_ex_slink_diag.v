// +FHDR***********************************************************************
// Copyright        :   CNG
// Confidential     :   I LEVEL
// ============================================================================
// FILE NAME        :   SLINK_DIAG
// CREATE DATE      :   2017-12-12
// DEPARTMENT       :   R&D
// AUTHOR           :   TingtingGan
// AUTHOR'S EMAIL   :   gantingting@cng.com
// AUTHOR'S TEL     :   18280151291
// ============================================================================
// RELEASE  HISTORY
// VERSION  DATE        AUTHOR          DESCRIPTION
// V100     2017-12-12  TingtingGan     Original
// ============================================================================
// KEYWORDS         :
// PURPOSE          :   SLINK diagnose
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

module  SELF_EX_SLINK_DIAG
    (
    // clock & reset
    clk_12_5m                   ,   
    rst_12_5m                   ,   

    chn_enable                  ,   

    chn_slink_err               ,   
    slink_err                    
    );

/**********************************************************************************\
***************************** declare parameter ************************************
\**********************************************************************************/

/**********************************************************************************\
***************************** declare interface signal *****************************
\**********************************************************************************/
// declare input singal
input   wire                    clk_12_5m                           ;   
input   wire                    rst_12_5m                           ;   

input   wire                    chn_enable                          ;   
input   wire        [1:0]       chn_slink_err                       ;   

// declare output signal
output  reg                     slink_err                           ;   

// declare inout signal

/**********************************************************************************\
**************************** declare singal attribute ******************************
\**********************************************************************************/
// wire signal

// reg signal

/**********************************************************************************\
******************************** debug code ****************************************
\**********************************************************************************/

/**********************************************************************************\
********************************* main code ****************************************
\**********************************************************************************/

//----------------------------------------------------------------------------------
// slink error generator
//----------------------------------------------------------------------------------
always @ ( posedge clk_12_5m or negedge rst_12_5m ) begin
    if( rst_12_5m == 1'b0 ) begin
        slink_err  <=   1'b0 ;
    end
    else begin
        if ( chn_enable == 1'b1 ) begin
            slink_err  <=   | chn_slink_err ;
        end
        else begin
            slink_err  <=   ~ chn_slink_err[0] ;
        end
    end
end

endmodule

