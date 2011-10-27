///////////////////////////////////////////////////////////////////////////////
// (c) Copyright 2008 Xilinx, Inc. All rights reserved.
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
//   ____  ____ 
//  /   /\/   / 
// /___/  \  /    Vendor: Xilinx 
// \   \   \/     Version : 7.1i
//  \   \         Application : 
//  /   /         Filename : aurora_8b10b_v5_2_GTP_WRAPPER.v
// /___/   /\     Timestamp : 02/08/2005 09:12:43
// \   \  /  \ 
//  \___\/\___\ 
//
//Command: 
//Design Name: aurora_8b10b_v5_2_GTP_WRAPPER
//
// Module aurora_8b10b_v5_2_GTP_WRAPPER
// Generated by Xilinx Architecture Wizard
// Written for synthesis tool: XST
`timescale 1ns / 1ps
(* core_generation_info = "aurora_8b10b_v5_2,aurora_8b10b_v5_2,{backchannel_mode=Sidebands, c_aurora_lanes=1, c_column_used=left, c_gt_clock_1=GTPD3, c_gt_clock_2=None, c_gt_loc_1=X, c_gt_loc_10=X, c_gt_loc_11=X, c_gt_loc_12=X, c_gt_loc_13=X, c_gt_loc_14=X, c_gt_loc_15=X, c_gt_loc_16=X, c_gt_loc_17=X, c_gt_loc_18=X, c_gt_loc_19=X, c_gt_loc_2=X, c_gt_loc_20=X, c_gt_loc_21=X, c_gt_loc_22=X, c_gt_loc_23=X, c_gt_loc_24=X, c_gt_loc_25=X, c_gt_loc_26=X, c_gt_loc_27=X, c_gt_loc_28=X, c_gt_loc_29=X, c_gt_loc_3=X, c_gt_loc_30=X, c_gt_loc_31=X, c_gt_loc_32=X, c_gt_loc_33=X, c_gt_loc_34=X, c_gt_loc_35=X, c_gt_loc_36=X, c_gt_loc_37=X, c_gt_loc_38=X, c_gt_loc_39=X, c_gt_loc_4=X, c_gt_loc_40=X, c_gt_loc_41=X, c_gt_loc_42=X, c_gt_loc_43=X, c_gt_loc_44=X, c_gt_loc_45=X, c_gt_loc_46=X, c_gt_loc_47=X, c_gt_loc_48=X, c_gt_loc_5=X, c_gt_loc_6=X, c_gt_loc_7=X, c_gt_loc_8=1, c_gt_loc_9=X, c_lane_width=2, c_line_rate=3.0, c_nfc=false, c_nfc_mode=IMM, c_refclk_frequency=150.0, c_simplex=false, c_simplex_mode=TX, c_stream=true, c_ufc=false, flow_mode=None, interface_mode=Streaming, dataflow_config=Duplex}" *)
module aurora_8b10b_v5_2_GTP_TILE #
(
    // Simulation attributes
    parameter   TILE_SIM_MODE              =   "FAST",  // Set to Fast Functional Simulation Model
    parameter   TILE_SIM_GTPRESET_SPEEDUP  =   0,      // Set to 1 to speed up sim reset
    parameter   TILE_SIM_PLL_PERDIV2       =   9'h14d,    // Set to the VCO Unit Interval time
    
    // Channel bonding attributes
    parameter   TILE_CHAN_BOND_MODE_0      =   "OFF",  // "MASTER", "SLAVE", or "OFF"
    parameter   TILE_CHAN_BOND_LEVEL_0     =   0,      // 0 to 7. See UG for details
    
    parameter   TILE_CHAN_BOND_MODE_1      =   "OFF",  // "MASTER", "SLAVE", or "OFF"
    parameter   TILE_CHAN_BOND_LEVEL_1     =   0       // 0 to 7. See UG for details
)
(
    //---------------------- Loopback and Powerdown Ports ----------------------
    LOOPBACK0_IN,
    LOOPBACK1_IN,
    RXPOWERDOWN0_IN,
    RXPOWERDOWN1_IN,
    TXPOWERDOWN0_IN,
    TXPOWERDOWN1_IN,
    //--------------------- Receive Ports - 8b10b Decoder ----------------------
    RXCHARISCOMMA0_OUT,
    RXCHARISCOMMA1_OUT,
    RXCHARISK0_OUT,
    RXCHARISK1_OUT,
    RXDISPERR0_OUT,
    RXDISPERR1_OUT,
    RXNOTINTABLE0_OUT,
    RXNOTINTABLE1_OUT,
    //----------------- Receive Ports - Clock Correction Ports -----------------
    RXCLKCORCNT0_OUT,
    RXCLKCORCNT1_OUT,
    //------------- Receive Ports - Comma Detection and Alignment --------------
    RXBYTEREALIGN0_OUT,
    RXBYTEREALIGN1_OUT,
    RXENMCOMMAALIGN0_IN,
    RXENMCOMMAALIGN1_IN,
    RXENPCOMMAALIGN0_IN,
    RXENPCOMMAALIGN1_IN,
    //----------------- Receive Ports - RX Data Path interface -----------------
    RXDATA0_OUT,
    RXDATA1_OUT,
    RXDATAWIDTH0_IN,
    RXDATAWIDTH1_IN,
    RXRESET0_IN,
    RXRESET1_IN,
    RXUSRCLK0_IN,
    RXUSRCLK1_IN,
    RXUSRCLK20_IN,
    RXUSRCLK21_IN,
    //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    RXCDRRESET0_IN,
    RXCDRRESET1_IN,
    RXELECIDLE0_OUT,
    RXELECIDLE1_OUT,
    RXELECIDLERESET0_IN,
    RXELECIDLERESET1_IN,
    RXN0_IN,
    RXN1_IN,
    RXP0_IN,
    RXP1_IN,
    //------ Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    RXBUFRESET0_IN,
    RXBUFRESET1_IN,
    RXBUFSTATUS0_OUT,
    RXBUFSTATUS1_OUT,
    TXBUFSTATUS0_OUT,
    TXBUFSTATUS1_OUT,
    //--------------- Receive Ports - RX Polarity Control Ports ----------------
    RXENSAMPLEALIGN0_IN,
    RXENSAMPLEALIGN1_IN,
    RXPOLARITY0_IN,
    RXPOLARITY1_IN,
    //------------------- Shared Ports - Tile and PLL Ports --------------------
    CLKIN_IN,
    GTPRESET_IN,
    PLLLKDET_OUT,
    REFCLKOUT_OUT,
    RESETDONE0_OUT,
    RESETDONE1_OUT,
    RXENELECIDLERESETB_IN,
    TXENPMAPHASEALIGN_IN,
    TXPMASETPHASE_IN,
    //-------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    TXCHARISK0_IN,
    TXCHARISK1_IN,
    //---------------- Transmit Ports - TX Data Path interface -----------------
    TXDATA0_IN,
    TXDATA1_IN,
    TXOUTCLK0_OUT,
    TXOUTCLK1_OUT,
    TXRESET0_IN,
    TXRESET1_IN,
    TXUSRCLK0_IN,
    TXUSRCLK1_IN,
    TXUSRCLK20_IN,
    TXUSRCLK21_IN,
    //------------- Transmit Ports - TX Driver and OOB signalling --------------
    TXN0_OUT,
    TXN1_OUT,
    TXP0_OUT,
    TXP1_OUT


);
//***************************** Port Declarations *****************************
        

    //---------------------- Loopback and Powerdown Ports ----------------------

    input   [2:0]   LOOPBACK0_IN;
    input   [2:0]   LOOPBACK1_IN;
    input   [1:0]   RXPOWERDOWN0_IN;
    input   [1:0]   RXPOWERDOWN1_IN;
    input   [1:0]   TXPOWERDOWN0_IN;
    input   [1:0]   TXPOWERDOWN1_IN;
    //--------------------- Receive Ports - 8b10b Decoder ----------------------
    output  [1:0]   RXCHARISCOMMA0_OUT;
    output  [1:0]   RXCHARISCOMMA1_OUT;
    output  [1:0]   RXCHARISK0_OUT;
    output  [1:0]   RXCHARISK1_OUT;
    output  [1:0]   RXDISPERR0_OUT;
    output  [1:0]   RXDISPERR1_OUT;
    output  [1:0]   RXNOTINTABLE0_OUT;
    output  [1:0]   RXNOTINTABLE1_OUT;
    //----------------- Receive Ports - Clock Correction Ports -----------------
    output  [2:0]   RXCLKCORCNT0_OUT;
    output  [2:0]   RXCLKCORCNT1_OUT;
    //------------- Receive Ports - Comma Detection and Alignment --------------
    output          RXBYTEREALIGN0_OUT;
    output          RXBYTEREALIGN1_OUT;
    input           RXENMCOMMAALIGN0_IN;
    input           RXENMCOMMAALIGN1_IN;
    input           RXENPCOMMAALIGN0_IN;
    input           RXENPCOMMAALIGN1_IN;
    //----------------- Receive Ports - RX Data Path interface -----------------
    output  [15:0]  RXDATA0_OUT;
    output  [15:0]  RXDATA1_OUT;
    input           RXDATAWIDTH0_IN;
    input           RXDATAWIDTH1_IN;
    input           RXRESET0_IN;
    input           RXRESET1_IN;
    input           RXUSRCLK0_IN;
    input           RXUSRCLK1_IN;
    input           RXUSRCLK20_IN;
    input           RXUSRCLK21_IN;
    //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
    input           RXCDRRESET0_IN;
    input           RXCDRRESET1_IN;
    output          RXELECIDLE0_OUT;
    output          RXELECIDLE1_OUT;
    input          RXELECIDLERESET0_IN;
    input          RXELECIDLERESET1_IN;
    input           RXN0_IN;
    input           RXN1_IN;
    input           RXP0_IN;
    input           RXP1_IN;
    //------ Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
    input           RXBUFRESET0_IN;
    input           RXBUFRESET1_IN;
    output  [2:0]   RXBUFSTATUS0_OUT;
    output  [2:0]   RXBUFSTATUS1_OUT;
    output  [1:0]   TXBUFSTATUS0_OUT;
    output  [1:0]   TXBUFSTATUS1_OUT;
    input           RXENSAMPLEALIGN0_IN;
    input           RXENSAMPLEALIGN1_IN;

    //--------------- Receive Ports - RX Polarity Control Ports ----------------
    input           RXPOLARITY0_IN;
    input           RXPOLARITY1_IN;
    //------------------- Shared Ports - Tile and PLL Ports --------------------
    input           CLKIN_IN;
    input           GTPRESET_IN;
    output          PLLLKDET_OUT;
    output          REFCLKOUT_OUT;
    output          RESETDONE0_OUT;
    output          RESETDONE1_OUT;
    input           RXENELECIDLERESETB_IN;
    input           TXENPMAPHASEALIGN_IN;
    input           TXPMASETPHASE_IN;
    //-------------- Transmit Ports - 8b10b Encoder Control Ports --------------
    input   [1:0]   TXCHARISK0_IN;
    input   [1:0]   TXCHARISK1_IN;
    //---------------- Transmit Ports - TX Data Path interface -----------------
    input   [15:0]  TXDATA0_IN;
    input   [15:0]  TXDATA1_IN;
    output          TXOUTCLK0_OUT;
    output          TXOUTCLK1_OUT;
    input           TXRESET0_IN;
    input           TXRESET1_IN;
    input           TXUSRCLK0_IN;
    input           TXUSRCLK1_IN;
    input           TXUSRCLK20_IN;
    input           TXUSRCLK21_IN;
    //------------- Transmit Ports - TX Driver and OOB signalling --------------
    output          TXN0_OUT;
    output          TXN1_OUT;
    output          TXP0_OUT;
    output          TXP1_OUT;



//***************************** Wire Declarations *****************************

    // ground and vcc signals
    wire            tied_to_ground_i;
    wire    [63:0]  tied_to_ground_vec_i;
    wire            tied_to_vcc_i;
    wire    [63:0]  tied_to_vcc_vec_i;


   

    //RX Datapath signals

    wire    [15:0]  rxdata0_i;       

    //TX Datapath signals
    wire    [15:0]  txdata0_i;           

    //RX Datapath signals
    wire    [15:0]  rxdata1_i;       

    //TX Datapath signals
    wire    [15:0]  txdata1_i;           

    // Electrical idle reset logic signals
    wire    [2:0]   loopback0_i;
    wire            rxelecidle0_i;
    wire            resetdone0_i;
    wire            rxelecidlereset0_i;
    wire            serialloopback0_i;
                                                                                                                                                                                              
    // Electrical idle reset logic signals
    wire    [2:0]   loopback1_i;
    wire            rxelecidle1_i;
    wire            resetdone1_i;
    wire            rxelecidlereset1_i;
    wire            serialloopback1_i;
                                                                                                                                                                                              
    // Shared Electrical Idle Reset signal
    wire            rxenelecidleresetb_i;

//********************************* Main Body of Code**************************

    //-------------------------  Static signal Assigments ---------------------   

    assign tied_to_ground_i             = 1'b0;
    assign tied_to_ground_vec_i         = 64'h0000000000000000;
    assign tied_to_vcc_i                = 1'b1;
    assign tied_to_vcc_vec_i            = 64'hffffffffffffffff;

                                  
    //-------------------  GTX Datapath byte mapping  -----------------








    
    //------------------------- GTX Instantiations  --------------------------   

    GTP_DUAL # 
    (
        //_______________________ Simulation-Only Attributes __________________

        .SIM_RECEIVER_DETECT_PASS0   ("TRUE"),
        .SIM_RECEIVER_DETECT_PASS1   ("TRUE"),
        
        .SIM_MODE                    (TILE_SIM_MODE), 
        .SIM_GTPRESET_SPEEDUP        (TILE_SIM_GTPRESET_SPEEDUP),
        .SIM_PLL_PERDIV2             (TILE_SIM_PLL_PERDIV2),


        //___________________________ Shared Attributes _______________________

        //---------------------- Tile and PLL Attributes ----------------------

        .CLK25_DIVIDER               (6), 
        .CLKINDC_B                   ("TRUE"),
        .OOB_CLK_DIVIDER             (6),
        .OVERSAMPLE_MODE             ("FALSE"),
        .PLL_DIVSEL_FB               (2),
        .PLL_DIVSEL_REF              (1),
        .PLL_TXDIVSEL_COMM_OUT       (1),
        .TX_SYNC_FILTERB             (1),

        //______________________ Transmit Interface Attributes ________________


        //----------------- TX Buffering and Phase Alignment ------------------   

        .TX_BUFFER_USE_0            ("TRUE"),
        .TX_XCLK_SEL_0              ("TXOUT"),
        .TXRX_INVERT_0              (5'b00000),

        .TX_BUFFER_USE_1            ("TRUE"),
        .TX_XCLK_SEL_1              ("TXOUT"),
        .TXRX_INVERT_1              (5'b00000),

        //------------------- TX Serial Line Rate settings --------------------   

        .PLL_TXDIVSEL_OUT_0         (1),

        .PLL_TXDIVSEL_OUT_1         (1), 

        //------------------- TX Driver and OOB signalling --------------------  
       
         .TX_DIFF_BOOST_0           ("TRUE"),
         .TX_DIFF_BOOST_1           ("TRUE"),

        //---------------- TX Pipe Control for PCI Express/SATA ---------------

        .COM_BURST_VAL_0            (4'b1111),

        .COM_BURST_VAL_1            (4'b1111),

        //_______________________ Receive Interface Attributes ________________


        //---------- RX Driver,OOB signalling,Coupling and Eq.,CDR ------------  

        .AC_CAP_DIS_0               ("TRUE"),
        .OOBDETECT_THRESHOLD_0      (3'b001),
        .PMA_CDR_SCAN_0             (27'h6c07640), 
        .PMA_RX_CFG_0               (25'h09f0088),
        .RCV_TERM_GND_0             ("FALSE"),
        .RCV_TERM_MID_0             ("FALSE"),
        .RCV_TERM_VTTRX_0           ("FALSE"),
        .TERMINATION_IMP_0          (50),

        .AC_CAP_DIS_1               ("TRUE"),
        .OOBDETECT_THRESHOLD_1      (3'b001),
        .PMA_CDR_SCAN_1             (27'h6c07640), 
        .PMA_RX_CFG_1               (25'h09f0088),  
        .RCV_TERM_GND_1             ("FALSE"),
        .RCV_TERM_MID_1             ("FALSE"),
        .RCV_TERM_VTTRX_1           ("FALSE"),
        .TERMINATION_IMP_1          (50),

        .PCS_COM_CFG                (28'h1680a0e),  
        .TERMINATION_CTRL           (5'b10100),
        .TERMINATION_OVRD           ("FALSE"),

        //------------------- RX Serial Line Rate Settings --------------------   

        .PLL_RXDIVSEL_OUT_0         (1),
        .PLL_SATA_0                 ("FALSE"),

        .PLL_RXDIVSEL_OUT_1         (1),
        .PLL_SATA_1                 ("FALSE"),


        //------------------------- PRBS Detection ----------------------------  

        .PRBS_ERR_THRESHOLD_0       (32'h00000001),

        .PRBS_ERR_THRESHOLD_1       (32'h00000001),

        //------------------- Comma Detection and Alignment -------------------  

        .ALIGN_COMMA_WORD_0         (2),
        .COMMA_10B_ENABLE_0         (10'b1111111111),
        .COMMA_DOUBLE_0             ("FALSE"),
        .DEC_MCOMMA_DETECT_0        ("TRUE"),
        .DEC_PCOMMA_DETECT_0        ("TRUE"),
        .DEC_VALID_COMMA_ONLY_0     ("FALSE"),
        .MCOMMA_10B_VALUE_0         (10'b1010000011),
        .MCOMMA_DETECT_0            ("TRUE"),
        .PCOMMA_10B_VALUE_0         (10'b0101111100),
        .PCOMMA_DETECT_0            ("TRUE"),
        .RX_SLIDE_MODE_0            ("PCS"),

        .ALIGN_COMMA_WORD_1         (2),
        .COMMA_10B_ENABLE_1         (10'b1111111111),
        .COMMA_DOUBLE_1             ("FALSE"),
        .DEC_MCOMMA_DETECT_1        ("TRUE"),
        .DEC_PCOMMA_DETECT_1        ("TRUE"),
        .DEC_VALID_COMMA_ONLY_1     ("FALSE"),
        .MCOMMA_10B_VALUE_1         (10'b1010000011),
        .MCOMMA_DETECT_1            ("TRUE"),
        .PCOMMA_10B_VALUE_1         (10'b0101111100),
        .PCOMMA_DETECT_1            ("TRUE"),
        .RX_SLIDE_MODE_1            ("PCS"),


        //------------------- RX Loss-of-sync State Machine -------------------  

        .RX_LOSS_OF_SYNC_FSM_0      ("FALSE"),
        .RX_LOS_INVALID_INCR_0      (8),
        .RX_LOS_THRESHOLD_0         (128),

        .RX_LOSS_OF_SYNC_FSM_1      ("FALSE"),
        .RX_LOS_INVALID_INCR_1      (8),
        .RX_LOS_THRESHOLD_1         (128),

        //------------ RX Elastic Buffer and Phase alignment ports ------------   
        
        .RX_BUFFER_USE_0            ("TRUE"),
        .RX_XCLK_SEL_0              ("RXREC"),

        .RX_BUFFER_USE_1            ("TRUE"),
        .RX_XCLK_SEL_1              ("RXREC"),

        //--------------------- Clock Correction Attributes -------------------   

        .CLK_CORRECT_USE_0          ("TRUE"),
        .CLK_COR_ADJ_LEN_0          (2),
        .CLK_COR_DET_LEN_0          (2),
        .CLK_COR_INSERT_IDLE_FLAG_0 ("FALSE"),
        .CLK_COR_KEEP_IDLE_0        ("FALSE"),
        .CLK_COR_MAX_LAT_0          (32),
        .CLK_COR_MIN_LAT_0          (28),
        .CLK_COR_PRECEDENCE_0       ("TRUE"),
        .CLK_COR_REPEAT_WAIT_0      (0),
        .CLK_COR_SEQ_1_1_0          (10'b0111110111),
        .CLK_COR_SEQ_1_2_0          (10'b0111110111),
        .CLK_COR_SEQ_1_3_0          (10'b0100000000),
        .CLK_COR_SEQ_1_4_0          (10'b0100000000),
        .CLK_COR_SEQ_1_ENABLE_0     (4'b1111),
        .CLK_COR_SEQ_2_1_0          (10'b0100000000),
        .CLK_COR_SEQ_2_2_0          (10'b0100000000),
        .CLK_COR_SEQ_2_3_0          (10'b0100000000),
        .CLK_COR_SEQ_2_4_0          (10'b0100000000),
        .CLK_COR_SEQ_2_ENABLE_0     (4'b1111),
        .CLK_COR_SEQ_2_USE_0        ("FALSE"),
        .RX_DECODE_SEQ_MATCH_0      ("TRUE"),

        .CLK_CORRECT_USE_1          ("TRUE"),
        .CLK_COR_ADJ_LEN_1          (2),
        .CLK_COR_DET_LEN_1          (2),
        .CLK_COR_INSERT_IDLE_FLAG_1 ("FALSE"),
        .CLK_COR_KEEP_IDLE_1        ("FALSE"),
        .CLK_COR_MAX_LAT_1          (32),
        .CLK_COR_MIN_LAT_1          (28),
        .CLK_COR_PRECEDENCE_1       ("TRUE"),
        .CLK_COR_REPEAT_WAIT_1      (0),
        .CLK_COR_SEQ_1_1_1          (10'b0111110111),
        .CLK_COR_SEQ_1_2_1          (10'b0111110111),
        .CLK_COR_SEQ_1_3_1          (10'b0000000000),
        .CLK_COR_SEQ_1_4_1          (10'b0000000000),
        .CLK_COR_SEQ_1_ENABLE_1     (4'b0011),
        .CLK_COR_SEQ_2_1_1          (10'b0000000000),
        .CLK_COR_SEQ_2_2_1          (10'b0000000000),
        .CLK_COR_SEQ_2_3_1          (10'b0000000000),
        .CLK_COR_SEQ_2_4_1          (10'b0000000000),
        .CLK_COR_SEQ_2_ENABLE_1     (4'b0000),
        .CLK_COR_SEQ_2_USE_1        ("FALSE"),
        .RX_DECODE_SEQ_MATCH_1      ("TRUE"),

        //-------------------- Channel Bonding Attributes ---------------------   

        .CHAN_BOND_1_MAX_SKEW_0     (7),
        .CHAN_BOND_2_MAX_SKEW_0     (7),
        .CHAN_BOND_LEVEL_0          (TILE_CHAN_BOND_LEVEL_0),
        .CHAN_BOND_MODE_0           (TILE_CHAN_BOND_MODE_0),
        .CHAN_BOND_SEQ_1_1_0        (10'b0101111100),
        .CHAN_BOND_SEQ_1_2_0        (10'b0000000000),
        .CHAN_BOND_SEQ_1_3_0        (10'b0000000000),
        .CHAN_BOND_SEQ_1_4_0        (10'b0000000000),
        .CHAN_BOND_SEQ_1_ENABLE_0   (4'b0001),
        .CHAN_BOND_SEQ_2_1_0        (10'b0000000000),
        .CHAN_BOND_SEQ_2_2_0        (10'b0000000000),
        .CHAN_BOND_SEQ_2_3_0        (10'b0000000000),
        .CHAN_BOND_SEQ_2_4_0        (10'b0000000000),
        .CHAN_BOND_SEQ_2_ENABLE_0   (4'b0000),
        .CHAN_BOND_SEQ_2_USE_0      ("FALSE"),  
        .CHAN_BOND_SEQ_LEN_0        (1),
        .PCI_EXPRESS_MODE_0         ("FALSE"),     

        .CHAN_BOND_1_MAX_SKEW_1     (7),
        .CHAN_BOND_2_MAX_SKEW_1     (7),
        .CHAN_BOND_LEVEL_1          (TILE_CHAN_BOND_LEVEL_1),
        .CHAN_BOND_MODE_1           (TILE_CHAN_BOND_MODE_1),
        .CHAN_BOND_SEQ_1_1_1        (10'b0101111100),
        .CHAN_BOND_SEQ_1_2_1        (10'b0000000000),
        .CHAN_BOND_SEQ_1_3_1        (10'b0000000000),
        .CHAN_BOND_SEQ_1_4_1        (10'b0000000000),
        .CHAN_BOND_SEQ_1_ENABLE_1   (4'b0001),
        .CHAN_BOND_SEQ_2_1_1        (10'b0000000000),
        .CHAN_BOND_SEQ_2_2_1        (10'b0000000000),
        .CHAN_BOND_SEQ_2_3_1        (10'b0000000000),
        .CHAN_BOND_SEQ_2_4_1        (10'b0000000000),
        .CHAN_BOND_SEQ_2_ENABLE_1   (4'b0000),
        .CHAN_BOND_SEQ_2_USE_1      ("FALSE"),  
        .CHAN_BOND_SEQ_LEN_1        (1),
        .PCI_EXPRESS_MODE_1         ("FALSE"),

        //---------------- RX Attributes for PCI Express/SATA ---------------
        
        .RX_STATUS_FMT_0            ("PCIE"),
        .SATA_BURST_VAL_0           (3'b100),
        .SATA_IDLE_VAL_0            (3'b100),
        .SATA_MAX_BURST_0           (7),
        .SATA_MAX_INIT_0            (22),
        .SATA_MAX_WAKE_0            (7),
        .SATA_MIN_BURST_0           (4),
        .SATA_MIN_INIT_0            (12),
        .SATA_MIN_WAKE_0            (4),
        .TRANS_TIME_FROM_P2_0       (16'h003c),
        .TRANS_TIME_NON_P2_0        (16'h0019),
        .TRANS_TIME_TO_P2_0         (16'h0064),

        .RX_STATUS_FMT_1            ("PCIE"),
        .SATA_BURST_VAL_1           (3'b100),
        .SATA_IDLE_VAL_1            (3'b100),
        .SATA_MAX_BURST_1           (7),
        .SATA_MAX_INIT_1            (22),
        .SATA_MAX_WAKE_1            (7),
        .SATA_MIN_BURST_1           (4),
        .SATA_MIN_INIT_1            (12),
        .SATA_MIN_WAKE_1            (4),
        .TRANS_TIME_FROM_P2_1       (16'h003c),
        .TRANS_TIME_NON_P2_1        (16'h0019),
        .TRANS_TIME_TO_P2_1         (16'h0064)         
     ) 
     gtp_tile_i
     (
        //---------------------- Loopback and Powerdown Ports ----------------------
        .LOOPBACK0                      (LOOPBACK0_IN),
        .LOOPBACK1                      (LOOPBACK1_IN),
        .RXPOWERDOWN0                   (RXPOWERDOWN0_IN),
        .RXPOWERDOWN1                   (RXPOWERDOWN1_IN),
        .TXPOWERDOWN0                   (TXPOWERDOWN0_IN),
        .TXPOWERDOWN1                   (TXPOWERDOWN0_IN),
        //------------ Receive Ports - 64b66b and 64b67b Gearbox Ports -------------
        //--------------------- Receive Ports - 8b10b Decoder ----------------------
        .RXCHARISCOMMA0                 (RXCHARISCOMMA0_OUT),
        .RXCHARISCOMMA1                 (RXCHARISCOMMA1_OUT),
        .RXCHARISK0                     (RXCHARISK0_OUT),
        .RXCHARISK1                     (RXCHARISK1_OUT),
        .RXDEC8B10BUSE0                 (tied_to_vcc_i),
        .RXDEC8B10BUSE1                 (tied_to_vcc_i),
        .RXDISPERR0                     (RXDISPERR0_OUT),
        .RXDISPERR1                     (RXDISPERR1_OUT),
        .RXNOTINTABLE0                  (RXNOTINTABLE0_OUT),
        .RXNOTINTABLE1                  (RXNOTINTABLE1_OUT),
        .RXRUNDISP0                     (),
        .RXRUNDISP1                     (),
        //----------------- Receive Ports - Channel Bonding Ports ------------------
        .RXCHANBONDSEQ0                 (),
        .RXCHANBONDSEQ1                 (),
        .RXCHBONDI0                     (tied_to_ground_vec_i[2:0]),
        .RXCHBONDI1                     (tied_to_ground_vec_i[2:0]),
        .RXCHBONDO0                     (),
        .RXCHBONDO1                     (),
        .RXENCHANSYNC0                  (tied_to_ground_i),
        .RXENCHANSYNC1                  (tied_to_ground_i),
        //----------------- Receive Ports - Clock Correction Ports -----------------
        .RXCLKCORCNT0                   (RXCLKCORCNT0_OUT),
        .RXCLKCORCNT1                   (RXCLKCORCNT1_OUT),
        //------------- Receive Ports - Comma Detection and Alignment --------------
        .RXBYTEISALIGNED0               (),
        .RXBYTEISALIGNED1               (),
        .RXBYTEREALIGN0                 (RXBYTEREALIGN0_OUT),
        .RXBYTEREALIGN1                 (RXBYTEREALIGN1_OUT),
        .RXCOMMADET0                    (),
        .RXCOMMADET1                    (),
        .RXCOMMADETUSE0                 (tied_to_vcc_i),
        .RXCOMMADETUSE1                 (tied_to_vcc_i),
        .RXENMCOMMAALIGN0               (RXENMCOMMAALIGN0_IN),
        .RXENMCOMMAALIGN1               (RXENMCOMMAALIGN1_IN),
        .RXENPCOMMAALIGN0               (RXENPCOMMAALIGN0_IN),
        .RXENPCOMMAALIGN1               (RXENPCOMMAALIGN1_IN),
        .RXSLIDE0                       (tied_to_ground_i),
        .RXSLIDE1                       (tied_to_ground_i),
        //--------------------- Receive Ports - PRBS Detection ---------------------
        .PRBSCNTRESET0                  (tied_to_ground_i),
        .PRBSCNTRESET1                  (tied_to_ground_i),
        .RXENPRBSTST0                   (tied_to_ground_vec_i[1:0]),
        .RXENPRBSTST1                   (tied_to_ground_vec_i[1:0]),
        .RXPRBSERR0                     (),
        .RXPRBSERR1                     (),
        //----------------- Receive Ports - RX Data Path interface -----------------
        .RXDATA0                        (RXDATA0_OUT),
        .RXDATA1                        (RXDATA1_OUT),
        .RXDATAWIDTH0                   (RXDATAWIDTH0_IN),
        .RXDATAWIDTH1                   (RXDATAWIDTH1_IN),
        .RXRECCLK0                      (),
        .RXRECCLK1                      (),
        .RXRESET0                       (RXRESET0_IN),
        .RXRESET1                       (RXRESET1_IN),
        .RXUSRCLK0                      (RXUSRCLK0_IN),
        .RXUSRCLK1                      (RXUSRCLK1_IN),
        .RXUSRCLK20                     (RXUSRCLK20_IN),
        .RXUSRCLK21                     (RXUSRCLK21_IN),
        //----- Receive Ports - RX Driver,OOB signalling,Coupling and Eq.,CDR ------
        .RXCDRRESET0                    (RXCDRRESET0_IN),
        .RXCDRRESET1                    (RXCDRRESET1_IN),
        .RXELECIDLE0                    (RXELECIDLE0_OUT),
        .RXELECIDLE1                    (RXELECIDLE1_OUT),
        .RXELECIDLERESET0               (RXELECIDLERESET0_IN),
        .RXELECIDLERESET1               (RXELECIDLERESET1_IN),
        .RXENEQB0                       (tied_to_vcc_i),
        .RXENEQB1                       (tied_to_vcc_i),
        .RXEQMIX0                       (tied_to_ground_vec_i[1:0]),
        .RXEQMIX1                       (tied_to_ground_vec_i[1:0]),
        .RXEQPOLE0                      (tied_to_ground_vec_i[3:0]),
        .RXEQPOLE1                      (tied_to_ground_vec_i[3:0]),
        .RXN0                           (RXN0_IN),
        .RXN1                           (RXN1_IN),
        .RXP0                           (RXP0_IN),
        .RXP1                           (RXP1_IN),
        //------ Receive Ports - RX Elastic Buffer and Phase Alignment Ports -------
        .RXBUFRESET0                    (RXBUFRESET0_IN),
        .RXBUFRESET1                    (RXBUFRESET1_IN),
        .RXBUFSTATUS0                   (RXBUFSTATUS0_OUT),
        .RXBUFSTATUS1                   (RXBUFSTATUS1_OUT),
        .RXCHANISALIGNED0               (RXCHANISALIGNED0_OUT),
        .RXCHANISALIGNED1               (RXCHANISALIGNED1_OUT),
        .RXCHANREALIGN0                 (RXCHANREALIGN0_OUT),
        .RXCHANREALIGN1                 (RXCHANREALIGN1_OUT),
        .RXPMASETPHASE0                 (tied_to_ground_i),
        .RXPMASETPHASE1                 (tied_to_ground_i),
        .RXSTATUS0                      (),
        .RXSTATUS1                      (),
        //------------- Receive Ports - RX Loss-of-sync State Machine --------------
        .RXLOSSOFSYNC0                  (),
        .RXLOSSOFSYNC1                  (),
        //-------------------- Receive Ports - RX Oversampling ---------------------
        .RXENSAMPLEALIGN0               (RXENSAMPLEALIGN0_IN),
        .RXENSAMPLEALIGN1               (RXENSAMPLEALIGN1_IN),
        .RXOVERSAMPLEERR0               (),
        .RXOVERSAMPLEERR1               (),
        //------------ Receive Ports - RX Pipe Control for PCI Express -------------
        .PHYSTATUS0                     (),
        .PHYSTATUS1                     (),
        .RXVALID0                       (),
        .RXVALID1                       (),
        //--------------- Receive Ports - RX Polarity Control Ports ----------------
        .RXPOLARITY0                    (RXPOLARITY0_IN),
        .RXPOLARITY1                    (RXPOLARITY1_IN),
        //----------- Shared Ports - Dynamic Reconfiguration Port (DRP) ------------
        .DADDR                          (tied_to_ground_vec_i[6:0]),
        .DCLK                           (tied_to_ground_i),
        .DEN                            (tied_to_ground_i),
        .DI                             (tied_to_ground_vec_i[15:0]),
        .DO                             (),
        .DRDY                           (),
        .DWE                            (tied_to_ground_i),
        //------------------- Shared Ports - Tile and PLL Ports --------------------
        .CLKIN                          (CLKIN_IN),
        .GTPRESET                       (GTPRESET_IN),
        .GTPTEST                        (tied_to_ground_vec_i[3:0]),
        .INTDATAWIDTH                   (tied_to_vcc_i),
        .PLLLKDET                       (PLLLKDET_OUT),
        .PLLLKDETEN                     (tied_to_vcc_i),
        .PLLPOWERDOWN                   (tied_to_ground_i),
        .REFCLKOUT                      (REFCLKOUT_OUT),
        .REFCLKPWRDNB                   (tied_to_vcc_i),
        .RESETDONE0                     (RESETDONE0_OUT),
        .RESETDONE1                     (RESETDONE1_OUT),
        .RXENELECIDLERESETB             (RXENELECIDLERESETB_IN),
        .TXENPMAPHASEALIGN              (tied_to_ground_i),
        .TXPMASETPHASE                  (tied_to_ground_i),
        //-------------- Transmit Ports - 8b10b Encoder Control Ports --------------
        .TXBYPASS8B10B0                 (tied_to_ground_vec_i[1:0]),
        .TXBYPASS8B10B1                 (tied_to_ground_vec_i[1:0]),
        .TXCHARDISPMODE0                (tied_to_ground_vec_i[1:0]),
        .TXCHARDISPMODE1                (tied_to_ground_vec_i[1:0]),
        .TXCHARDISPVAL0                 (tied_to_ground_vec_i[1:0]),
        .TXCHARDISPVAL1                 (tied_to_ground_vec_i[1:0]),
        .TXCHARISK0                     (TXCHARISK0_IN),
        .TXCHARISK1                     (TXCHARISK1_IN),
        .TXENC8B10BUSE0                 (tied_to_vcc_i),
        .TXENC8B10BUSE1                 (tied_to_vcc_i),
        .TXKERR0                        (),
        .TXKERR1                        (),
        .TXRUNDISP0                     (),
        .TXRUNDISP1                     (),
        //----------- Transmit Ports - TX Buffering and Phase Alignment ------------
        .TXBUFSTATUS0                   (TXBUFSTATUS0_OUT),
        .TXBUFSTATUS1                   (TXBUFSTATUS1_OUT),
        //---------------- Transmit Ports - TX Data Path interface -----------------
        .TXDATA0                        (TXDATA0_IN),
        .TXDATA1                        (TXDATA1_IN),
        .TXDATAWIDTH0                   (tied_to_vcc_i),
        .TXDATAWIDTH1                   (tied_to_vcc_i),
        .TXOUTCLK0                      (TXOUTCLK0_OUT),
        .TXOUTCLK1                      (TXOUTCLK1_OUT),
        .TXRESET0                       (TXRESET0_IN),
        .TXRESET1                       (TXRESET1_IN),
        .TXUSRCLK0                      (TXUSRCLK0_IN),
        .TXUSRCLK1                      (TXUSRCLK1_IN),
        .TXUSRCLK20                     (TXUSRCLK20_IN),
        .TXUSRCLK21                     (TXUSRCLK21_IN),
        //------------- Transmit Ports - TX Driver and OOB signalling --------------
        .TXBUFDIFFCTRL0                 (3'b000),
        .TXBUFDIFFCTRL1                 (3'b000),
        .TXDIFFCTRL0                    (3'b000),
        .TXDIFFCTRL1                    (3'b000),
        .TXINHIBIT0                     (tied_to_ground_i),
        .TXINHIBIT1                     (tied_to_ground_i),
        .TXN0                           (TXN0_OUT),
        .TXN1                           (TXN1_OUT),
        .TXP0                           (TXP0_OUT),
        .TXP1                           (TXP1_OUT),
        .TXPREEMPHASIS0                 (3'b000),
        .TXPREEMPHASIS1                 (3'b000),
        //------------------- Transmit Ports - TX PRBS Generator -------------------
        .TXENPRBSTST0                   (tied_to_ground_vec_i[1:0]),
        .TXENPRBSTST1                   (tied_to_ground_vec_i[1:0]),
        //------------------ Transmit Ports - TX Polarity Control ------------------
        .TXPOLARITY0                    (tied_to_ground_i),
        .TXPOLARITY1                    (tied_to_ground_i),
        //--------------- Transmit Ports - TX Ports for PCI Express ----------------
        .TXDETECTRX0                    (tied_to_ground_i),
        .TXDETECTRX1                    (tied_to_ground_i),
        .TXELECIDLE0                    (tied_to_ground_i),
        .TXELECIDLE1                    (tied_to_ground_i),
        //------------------- Transmit Ports - TX Ports for SATA -------------------
        .TXCOMSTART0                    (tied_to_ground_i),
        .TXCOMSTART1                    (tied_to_ground_i),
        .TXCOMTYPE0                     (tied_to_ground_i),
        .TXCOMTYPE1                     (tied_to_ground_i)

     );
     
endmodule


