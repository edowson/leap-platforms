///////////////////////////////////////////////////////////////////////////////
//
// Project:  Aurora 64B/66B
// Version:  version 7.3
// Company:  Xilinx
//
//
//
// (c) Copyright 2008 - 2009 Xilinx, Inc. All rights reserved.
//
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
//
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
//
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
//
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.

//
//
////////////////////////////////////////////////////////////////////////////////
// Design Name: aurora_64b66b_v7_3_WRAPPER
//
// Module aurora_64b66b_v7_3_WRAPPER
// Generated by Xilinx Architecture Wizard
// Written for synthesis tool: XST


// No of quads in design 1

`timescale 1ns / 1ps
(* core_generation_info = "aurora_64b66b_v7_3,aurora_64b66b_v7_3,{c_aurora_lanes=1, c_column_used=right, c_gt_clock_1=GTXQ0, c_gt_clock_2=None, c_gt_loc_1=1, c_gt_loc_10=X, c_gt_loc_11=X, c_gt_loc_12=X, c_gt_loc_13=X, c_gt_loc_14=X, c_gt_loc_15=X, c_gt_loc_16=X, c_gt_loc_17=X, c_gt_loc_18=X, c_gt_loc_19=X, c_gt_loc_2=X, c_gt_loc_20=X, c_gt_loc_21=X, c_gt_loc_22=X, c_gt_loc_23=X, c_gt_loc_24=X, c_gt_loc_25=X, c_gt_loc_26=X, c_gt_loc_27=X, c_gt_loc_28=X, c_gt_loc_29=X, c_gt_loc_3=X, c_gt_loc_30=X, c_gt_loc_31=X, c_gt_loc_32=X, c_gt_loc_33=X, c_gt_loc_34=X, c_gt_loc_35=X, c_gt_loc_36=X, c_gt_loc_37=X, c_gt_loc_38=X, c_gt_loc_39=X, c_gt_loc_4=X, c_gt_loc_40=X, c_gt_loc_41=X, c_gt_loc_42=X, c_gt_loc_43=X, c_gt_loc_44=X, c_gt_loc_45=X, c_gt_loc_46=X, c_gt_loc_47=X, c_gt_loc_48=X, c_gt_loc_5=X, c_gt_loc_6=X, c_gt_loc_7=X, c_gt_loc_8=X, c_gt_loc_9=X, c_lane_width=4, c_line_rate=5.0, c_gt_type=gtx, c_qpll=false, c_nfc=false, c_nfc_mode=IMM, c_refclk_frequency=156.25, c_simplex=false, c_simplex_mode=TX, c_stream=true, c_ufc=false, c_user_k=false,flow_mode=None, interface_mode=Streaming, dataflow_config=Duplex,}" *)

module aurora_64b66b_v7_3_MULTI_GT #
(
    // Simulation attributes
    parameter   WRAPPER_SIM_GTRESET_SPEEDUP    =   "false",     // Set to "true" to speed up sim reset
    parameter   RX_DFE_KL_CFG2_IN              =   32'h3010D90C,
    parameter   PMA_RSV_IN                     =   32'h00018480,
    parameter   SIM_VERSION                    =   "4.0"
)
`define DLY #1
(
    //____________________________CHANNEL PORTS________________________________
    //-------------- Channel - Dynamic Reconfiguration Port (DRP) --------------
    input  [8:0]  GT0_DRPADDR_IN,
    input         GT0_DRP_CLK_IN,
    input  [15:0] GT0_DRPDI_IN,
    output [15:0] GT0_DRPDO_OUT,
    input         GT0_DRPEN_IN,
    output        GT0_DRPRDY_OUT,
    input         GT0_DRPWE_IN,
 
    //----------------------- Channel - Ref Clock Ports ------------------------
    input         GT0_GTREFCLK_IN,
    //------------------------------ Channel PLL -------------------------------
//    output        GT0_CPLLFBCLKLOST_OUT,
    output        GT0_CPLLLOCK_OUT,
//    input         GT0_CPLLLOCKDETCLK_IN,
//    output        GT0_CPLLREFCLKLOST_OUT,
    input         GT0_CPLLRESET_IN,
    //----------------------------- Eye Scan Ports -----------------------------
//    output        GT0_EYESCANDATAERROR_OUT,
    //---------------------- Loopback and Powerdown Ports ----------------------
    input  [2:0]  GT0_LOOPBACK_IN,
    //----------------------------- Receive Ports ------------------------------
    input         GT0_RXUSERRDY_IN,
    //------------ Receive Ports - 64b66b and 64b67b Gearbox Ports -------------
    output        GT0_RXDATAVALID_OUT,
    input         GT0_RXGEARBOXSLIP_IN,
    output [1:0]  GT0_RXHEADER_OUT,
    output        GT0_RXHEADERVALID_OUT,
            //--------------------- Receive Ports - PRBS Detection ---------------------
    input         GT0_RXPRBSCNTRESET_IN,
//    output        GT0_RXPRBSERR_OUT,
    input  [2:0]  GT0_RXPRBSSEL_IN_IN,
            //----------------- Receive Ports - RX Data Path interface -----------------
    input          GT0_GTRXRESET_IN,
    output  [31:0] GT0_RXDATA_OUT,
    output         GT0_RXOUTCLK_OUT,
    input          GT0_RXPCSRESET_IN,
    input          GT0_RXUSRCLK_IN,
    input          GT0_RXUSRCLK2_IN,
            //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    input         GT0_GTXRXN_IN,
    input         GT0_GTXRXP_IN,
//    output        GT0_RXCDRLOCK_OUT,
//    output        GT0_RXELECIDLE_OUT,
            //------ Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    input         GT0_RXBUFRESET_IN,
//    output  [2:0]   GT0_RXBUFSTATUS_OUT,
            //---------------------- Receive Ports - RX PLL Ports ----------------------
    output        GT0_RXRESETDONE_OUT,
            //------------ Transmit Ports - 64b66b and 64b67b Gearbox Ports ------------
    input         GT0_TXUSERRDY_IN,
    input  [1:0]  GT0_TXHEADER_IN,
    input  [6:0]  GT0_TXSEQUENCE_IN,
            //---------------- Transmit Ports - TX Data Path interface -----------------
    input         GT0_GTTXRESET_IN,
    input  [63:0] GT0_TXDATA_IN,
    output        GT0_TXOUTCLK_OUT,
//    output        GT0_TXOUTCLKFABRIC_OUT,
    input         GT0_TXPCSRESET_IN,
    input         GT0_TXUSRCLK_IN,
    input         GT0_TXUSRCLK2_IN,
            //-------------- Transmit Ports - TX Driver and OOB signaling --------------
    output        GT0_GTXTXN_OUT,
    output        GT0_GTXTXP_OUT,
            //--------------------- Transmit Ports - TX PLL Ports ----------------------
    output         GT0_TXRESETDONE_OUT,
            //------------------- Transmit Ports - TX PRBS Generator -------------------
    input  [2:0]  GT0_TXPRBSSEL_IN,
            //--------------- Transmit Ports - TX Ports for PCI Express ----------------
    input         GT0_TXELECIDLE_IN,

    //____________________________COMMON PORTS________________________________
    //-------------------- Common Block  - Ref Clock Ports ---------------------

    input           GT0_GTREFCLK0_COMMON_IN
);
//***************************** Wire Declarations *****************************
    // Ground and VCC signals
    wire                    tied_to_ground_i;
    wire    [63:0]          tied_to_ground_vec_i;
   wire                     gt_qpllclk_quad1_i;
   wire                     gt_qpllrefclk_quad1_i;
    wire                    tied_to_vcc_i;
//********************************* Main Body of Code**************************
    //-------------------------  Static signal Assigments ---------------------   
    assign tied_to_ground_i             = 1'b0;
    assign tied_to_ground_vec_i         = 64'h0000000000000000;
    assign tied_to_vcc_i             = 1'b1;


    //*************************************************************************************************    
    //----------------------------------------------  ------------------------------------------   
    //*************************************************************************************************    


 

    //*************************************************************************************************
    //-----------------------------------GT INSTANCE-----------------------------------------------
    //*************************************************************************************************
    AURORA_64B66B_V7_3_GTX # 
    (
        // Simulation attributes
        .GT_SIM_GTRESET_SPEEDUP   (WRAPPER_SIM_GTRESET_SPEEDUP),
        .SIM_VERSION              (SIM_VERSION),
        .RX_DFE_KL_CFG2_IN        (RX_DFE_KL_CFG2_IN),
        .PCS_RSVD_ATTR_IN         (48'h000000000000),
        .PMA_RSV_IN               (PMA_RSV_IN)

    ) 
    AURORA_64B66B_V7_3_GTX_INST
    (
        //_____________________________________________________________________
        //_____________________________________________________________________
// ACTIVE GT in Q1 1
// ACTIVE GT in Q2 0
// Calculated ACTIVE GT in Q2 0
// ACTIVE GT in Q3 0
// ACTIVE GT in Q4 0
// ACTIVE GT in Q5 0
// ACTIVE GT in Q6 0
// ACTIVE GT in Q7 0
// ACTIVE GT in Q8 0
// ACTIVE GT in Q9 0
        //-------------------------------- QPLL ---------------------------------

        .QPLLCLK_IN                     (gt_qpllclk_quad1_i),
        .QPLLREFCLK_IN                  (gt_qpllrefclk_quad1_i),
//GT_QUAD1 is 0

        //------------------------------ Channel PLL -------------------------------
//        .CPLLFBCLKLOST_OUT          (GT0_CPLLFBCLKLOST_OUT),
        .CPLLFBCLKLOST_OUT          (),
        .CPLLLOCK_OUT               (GT0_CPLLLOCK_OUT),
        .CPLLLOCKDETCLK_IN          (tied_to_ground_i),
//        .CPLLREFCLKLOST_OUT         (GT0_CPLLREFCLKLOST_OUT),
        .CPLLREFCLKLOST_OUT         (),
        .CPLLRESET_IN               (GT0_CPLLRESET_IN),
        .GTREFCLK0_IN               (GT0_GTREFCLK_IN),
        //-------------- Channel - Dynamic Reconfiguration Port (DRP) --------------
        .DRPADDR_IN                 (GT0_DRPADDR_IN),
        .DRPCLK_IN                  (GT0_DRP_CLK_IN),
        .DRPDI_IN                   (GT0_DRPDI_IN),
        .DRPDO_OUT                  (GT0_DRPDO_OUT),
        .DRPEN_IN                   (GT0_DRPEN_IN),
        .DRPRDY_OUT                 (GT0_DRPRDY_OUT),
        .DRPWE_IN                   (GT0_DRPWE_IN),
        //----------------------------- Eye Scan Ports -----------------------------
        .EYESCANDATAERROR_OUT       (),
        //---------------------- Loopback and Powerdown Ports ----------------------
        .LOOPBACK_IN                (GT0_LOOPBACK_IN),
        //----------------------------- Receive Ports ------------------------------
        .RXUSERRDY_IN               (GT0_RXUSERRDY_IN),
        //------------ Receive Ports - 64b66b and 64b67b Gearbox Ports -------------
        .RXDATAVALID_OUT            (GT0_RXDATAVALID_OUT),
        .RXGEARBOXSLIP_IN           (GT0_RXGEARBOXSLIP_IN),
        .RXHEADER_OUT               (GT0_RXHEADER_OUT),
        .RXHEADERVALID_OUT          (GT0_RXHEADERVALID_OUT),
        //--------------------- Receive Ports - PRBS Detection ---------------------
        .RXPRBSCNTRESET_IN          (GT0_RXPRBSCNTRESET_IN),
        .RXPRBSERR_OUT              (),
        .RXPRBSSEL_IN               (GT0_RXPRBSSEL_IN_IN),
        //----------------- Receive Ports - RX Data Path interface -----------------
        .GTRXRESET_IN               (GT0_GTRXRESET_IN),
        .RXDATA_OUT                 (GT0_RXDATA_OUT),
        .RXOUTCLK_OUT               (GT0_RXOUTCLK_OUT),
        .RXPCSRESET_IN              (GT0_RXPCSRESET_IN),
        .RXUSRCLK_IN                (GT0_RXUSRCLK_IN),
        .RXUSRCLK2_IN               (GT0_RXUSRCLK2_IN),
         
        //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        .GTXRXN_IN                  (GT0_GTXRXN_IN),
        .GTXRXP_IN                  (GT0_GTXRXP_IN),
        .RXELECIDLE_OUT              (), 
        .RXCDRLOCK_OUT              (),
        //------ Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
        .RXBUFRESET_IN              (GT0_RXBUFRESET_IN),
        .RXBUFSTATUS_OUT            (),
        //---------------------- Receive Ports - RX PLL Ports ----------------------
        .RXRESETDONE_OUT            (GT0_RXRESETDONE_OUT),
        //----------------------------- Transmit Ports -----------------------------
        .TXUSERRDY_IN               (GT0_TXUSERRDY_IN),
        //------------ Transmit Ports - 64b66b and 64b67b Gearbox Ports ------------
        .TXHEADER_IN                (GT0_TXHEADER_IN),
        .TXSEQUENCE_IN              (GT0_TXSEQUENCE_IN),
        //---------------- Transmit Ports - TX Data Path interface -----------------
        .GTTXRESET_IN               (GT0_GTTXRESET_IN),
        .TXDATA_IN                  (GT0_TXDATA_IN),
        .TXOUTCLK_OUT               (GT0_TXOUTCLK_OUT),
        .TXOUTCLKFABRIC_OUT         (),
        .TXOUTCLKPCS_OUT            (),
        .TXPCSRESET_IN              (GT0_TXPCSRESET_IN),
        .TXUSRCLK_IN                (GT0_TXUSRCLK_IN),
        .TXUSRCLK2_IN               (GT0_TXUSRCLK2_IN),
        //-------------- Transmit Ports - TX Driver and OOB signaling --------------
        .GTXTXN_OUT                 (GT0_GTXTXN_OUT),
        .GTXTXP_OUT                 (GT0_GTXTXP_OUT),
        //--------------------- Transmit Ports - TX PLL Ports ----------------------
        .TXRESETDONE_OUT            (GT0_TXRESETDONE_OUT),
        //------------------- Transmit Ports - TX PRBS Generator -------------------
        .TXPRBSSEL_IN               (GT0_TXPRBSSEL_IN),
        //--------------- Transmit Ports - TX Ports for PCI Express ----------------
        .TXELECIDLE_IN              (GT0_TXELECIDLE_IN)

    );


    //_________________________________________________________________________
    //_________________________________________________________________________
    //_________________________GTXE2_COMMON____________________________________

    GTXE2_COMMON #
    (
            // Simulation attributes
            .SIM_RESET_SPEEDUP                      (WRAPPER_SIM_GTRESET_SPEEDUP),
            .SIM_QPLLREFCLK_SEL                     (3'b001),
            .SIM_VERSION                            ("3.0"),


           //----------------COMMON BLOCK---------------
            .BIAS_CFG                               (64'h0000040000001000),
            .COMMON_CFG                             (32'h00000000),
            .QPLL_CFG                               (27'h0680181),
            .QPLL_CLKOUT_CFG                        (4'b0000),
            .QPLL_COARSE_FREQ_OVRD                  (6'b010000),
            .QPLL_COARSE_FREQ_OVRD_EN               (1'b0),
            .QPLL_CP                                (10'b0000011111),
            .QPLL_CP_MONITOR_EN                     (1'b0),
            .QPLL_DMONITOR_SEL                      (1'b0),
            .QPLL_FBDIV                             (10'b0000100000),
            .QPLL_FBDIV_MONITOR_EN                  (1'b0),
            .QPLL_FBDIV_RATIO                       (1'b1),
            .QPLL_INIT_CFG                          (24'h000006),
            .QPLL_LOCK_CFG                          (16'h21E8),
            .QPLL_LPF                               (4'b1111),
            .QPLL_REFCLK_DIV                        (1)

    )
    gtxe2_common_i
    (
        .DRPADDR                                    (tied_to_ground_vec_i[7:0]), 
        .DRPCLK                                     (tied_to_ground_i), 
        .DRPDI                                      (tied_to_ground_vec_i[15:0]), 
        .DRPDO                                      (), 
        .DRPEN                                      (tied_to_ground_i), 
        .DRPRDY                                     (), 
        .DRPWE                                      (tied_to_ground_i),
        //-------------------- Common Block  - Ref Clock Ports ---------------------
        .GTGREFCLK                                  (tied_to_ground_i),
        .GTNORTHREFCLK0                             (tied_to_ground_i),
        .GTNORTHREFCLK1                             (tied_to_ground_i),
        .GTREFCLK0                                  (GT0_GTREFCLK0_COMMON_IN),
        .GTREFCLK1                                  (tied_to_ground_i),
        .GTSOUTHREFCLK0                             (tied_to_ground_i),
        .GTSOUTHREFCLK1                             (tied_to_ground_i),
        //----------------------- Common Block - QPLL Ports ------------------------
        .QPLLFBCLKLOST                              (),
        .QPLLLOCK                                   (), 
        .QPLLLOCKDETCLK                             (tied_to_ground_i), 
        .QPLLLOCKEN                                 (tied_to_vcc_i),
        .QPLLOUTCLK                                 (gt_qpllclk_quad1_i),
        .QPLLOUTREFCLK                              (gt_qpllrefclk_quad1_i),
        .QPLLOUTRESET                               (tied_to_ground_i),
        .QPLLPD                                     (tied_to_ground_i),
        .QPLLREFCLKLOST                             (),
        .QPLLREFCLKSEL                              (3'b001),
        .QPLLRESET                                  (tied_to_ground_i),
 
        .QPLLRSVD1                                  (16'b0000000000000000),
        .QPLLRSVD2                                  (5'b11111),
        .RCALENB                                    (tied_to_ground_i),
        .REFCLKOUTMONITOR                           (),
        //--------------------------- Common Block Ports ---------------------------
        .BGBYPASSB                                  (tied_to_ground_i),
        .BGMONITORENB                               (tied_to_ground_i),
        .BGPDB                                      (tied_to_vcc_i),
        .BGRCALOVRD                                 (5'b00000),
        .PMARSVD                                    (8'b00000000),
        .QPLLDMONITOR                               ()

    );

endmodule

