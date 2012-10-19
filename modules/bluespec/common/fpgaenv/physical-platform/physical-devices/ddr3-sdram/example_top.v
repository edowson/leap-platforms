//*****************************************************************************
// (c) Copyright 2009 - 2010 Xilinx, Inc. All rights reserved.
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
//*****************************************************************************
//   ____  ____
//  /   /\/   /
// /___/  \  /    Vendor             : Xilinx
// \   \   \/     Version            : 3.6.1
//  \   \         Application        : MIG
//  /   /         Filename           : example_top.v
// /___/   /\     Date Last Modified : $Date: 2010/10/27 17:40:42 $
// \   \  /  \    Date Created       : Mon Jun 23 2008
//  \___\/\___\
//
// Device           : Virtex-6
// Design Name      : DDR3 SDRAM
// Purpose          :
//                   Top-level  module. This module serves both as an example,
//                   and allows the user to synthesize a self-contained design,
//                   which they can use to test their hardware. In addition to
//                   the memory controller.
//                   instantiates:
//                     1. Clock generation/distribution, reset logic
//                     2. IDELAY control block
//                     3. Synthesizable testbench - used to model user's backend
//                        logic
// Reference        :
// Revision History :  Target ML605 
//    1. Add output ports for "pll_lock" and "heartbeat" LEDS
//    2. Comment out "sda" and "scl" ports and logic.
//    3. Add "pll_lock" port on module "infrastructure.v" connect to wire "locked"
//    4. Define active high system reset switch "RST_ACTIVE_LOW = 0"
//    5. Modify MMCM parameters to generate 400MHz clock using 200MHz input clock (versus default 400MHz)
//    6. Modify "iodelay_ctrl" module to provide clk_200 output to "infrastructure" MMCM CLKIN
//    7. Add counter and output assignment for "heartbeat" 
//    8. Add VIO control inputs to permit traffic generator update from VIO console
//*****************************************************************************

`timescale 1ps/1ps

module example_top #
  (
   parameter REFCLK_FREQ             = 200,
                                       // # = 200 when design frequency <= 533 MHz,
                                       //   = 300 when design frequency > 533 MHz.
   parameter IODELAY_GRP             = "IODELAY_MIG",
                                       // It is associated to a set of IODELAYs with
                                       // an IDELAYCTRL that have same IODELAY CONTROLLER
                                       // clock frequency.
   parameter MMCM_ADV_BANDWIDTH      = "OPTIMIZED",
                                       // MMCM programming algorithm 
   parameter CLKFBOUT_MULT_F         = 6,
                                       // write PLL VCO multiplier.
   parameter DIVCLK_DIVIDE           = 1,  // ML605 200MHz input clock (VCO = 1200MHz)use "2" for 400MHz SMA,
                                       // write PLL VCO divisor.
   parameter CLKOUT_DIVIDE           = 3,  //400MHz clock
                                       // VCO output divisor for fast (memory) clocks.
   parameter nCK_PER_CLK             = 2,
                                       // # of memory CKs per fabric clock.
                                       // # = 2, 1.
   parameter tCK                     = 2500,
                                       // memory tCK paramter.
                                       // # = Clock Period.
   parameter DEBUG_PORT              = "OFF",
                                       // # = "ON" Enable debug signals/controls.
                                       //   = "OFF" Disable debug signals/controls.
   parameter SIM_BYPASS_INIT_CAL     = "OFF",
                                       // # = "OFF" -  Complete memory init &
                                       //              calibration sequence
                                       // # = "SKIP" - Skip memory init &
                                       //              calibration sequence
                                       // # = "FAST" - Skip memory init & use
                                       //              abbreviated calib sequence
   parameter SIM_INIT_OPTION         = "NONE",
                                       // # = "SKIP_PU_DLY" - Skip the memory
                                       //                     initilization sequence,
                                       //   = "NONE" - Complete the memory
                                       //              initilization sequence.
   parameter SIM_CAL_OPTION          = "NONE",
                                       // # = "FAST_CAL" - Skip the delay
                                       //                  Calibration process,
                                       //   = "NONE" - Complete the delay
                                       //              Calibration process.
   parameter nCS_PER_RANK            = 1,
                                       // # of unique CS outputs per Rank for
                                       // phy.
   parameter DQS_CNT_WIDTH           = 3,
                                       // # = ceil(log2(DQS_WIDTH)).
   parameter RANK_WIDTH              = 1,
                                       // # = ceil(log2(RANKS)).
   parameter BANK_WIDTH              = 3,
                                       // # of memory Bank Address bits.
   parameter CK_WIDTH                = 1,
                                       // # of CK/CK# outputs to memory.
   parameter CKE_WIDTH               = 1,
                                       // # of CKE outputs to memory.
   parameter COL_WIDTH               = 10,
                                       // # of memory Column Address bits.
   parameter CS_WIDTH                = 1,
                                       // # of unique CS outputs to memory.
   parameter DM_WIDTH                = 8,
                                       // # of Data Mask bits.
   parameter DQ_WIDTH                = 64,
                                       // # of Data (DQ) bits.
   parameter DQS_WIDTH               = 8,
                                       // # of DQS/DQS# bits.
   parameter ROW_WIDTH               = 13,
                                       // # of memory Row Address bits.
   parameter BURST_MODE              = "8",
                                       // Burst Length (Mode Register 0).
                                       // # = "8", "4", "OTF".
   parameter BM_CNT_WIDTH            = 2,
                                       // # = ceil(log2(nBANK_MACHS)).
   parameter ADDR_CMD_MODE           = "1T" ,
                                       // # = "2T", "1T".
   parameter ORDERING                = "STRICT",
                                       // # = "NORM", "STRICT", "RELAXED".
   parameter WRLVL                   = "ON",
                                       // # = "ON" - DDR3 SDRAM
                                       //   = "OFF" - DDR2 SDRAM.
   parameter PHASE_DETECT            = "ON",
                                       // # = "ON", "OFF".
   parameter RTT_NOM                 = "60",
                                       // RTT_NOM (ODT) (Mode Register 1).
                                       // # = "DISABLED" - RTT_NOM disabled,
                                       //   = "120" - RZQ/2,
                                       //   = "60"  - RZQ/4,
                                       //   = "40"  - RZQ/6.
   parameter RTT_WR                  = "OFF",
                                       // RTT_WR (ODT) (Mode Register 2).
                                       // # = "OFF" - Dynamic ODT off,
                                       //   = "120" - RZQ/2,
                                       //   = "60"  - RZQ/4,
   parameter OUTPUT_DRV              = "HIGH",
                                       // Output Driver Impedance Control (Mode Register 1).
                                       // # = "HIGH" - RZQ/7,
                                       //   = "LOW" - RZQ/6.
   parameter REG_CTRL                = "OFF",
                                       // # = "ON" - RDIMMs,
                                       //   = "OFF" - Components, SODIMMs, UDIMMs.
   parameter nDQS_COL0               = 3,
                                       // Number of DQS groups in I/O column #1.
   parameter nDQS_COL1               = 5,
                                       // Number of DQS groups in I/O column #2.
   parameter nDQS_COL2               = 0,
                                       // Number of DQS groups in I/O column #3.
   parameter nDQS_COL3               = 0,
                                       // Number of DQS groups in I/O column #4.
   parameter DQS_LOC_COL0            = 24'h020100,
                                       // DQS groups in column #1.
   parameter DQS_LOC_COL1            = 40'h0706050403,
                                       // DQS groups in column #2.
   parameter DQS_LOC_COL2            = 0,
                                       // DQS groups in column #3.
   parameter DQS_LOC_COL3            = 0,
                                       // DQS groups in column #4.
   parameter tPRDI                   = 1_000_000,
                                       // memory tPRDI paramter.
   parameter tREFI                   = 7800000,
                                       // memory tREFI paramter.
   parameter tZQI                    = 128_000_000,
                                       // memory tZQI paramter.
   parameter ADDR_WIDTH              = 27,
                                       // # = RANK_WIDTH + BANK_WIDTH
                                       //     + ROW_WIDTH + COL_WIDTH;
   parameter ECC_TEST                = "OFF",
   parameter TCQ                     = 100,
   // Traffic Gen related parameters
   parameter EYE_TEST                = "FALSE",
                                       // set EYE_TEST = "TRUE" to probe memory
                                       // signals. Traffic Generator will only
                                       // write to one single location and no
                                       // read transactions will be generated.
   parameter DATA_PATTERN            = "DGEN_ALL",
                                        // "DGEN_HAMMER", "DGEN_WALKING1",
                                        // "DGEN_WALKING0","DGEN_ADDR","
                                        // "DGEN_NEIGHBOR","DGEN_PRBS","DGEN_ALL"
   parameter CMD_PATTERN             = "CGEN_ALL",
                                        // "CGEN_PRBS","CGEN_FIXED","CGEN_BRAM",
                                        // "CGEN_SEQUENTIAL", "CGEN_ALL"

   parameter BEGIN_ADDRESS           = 32'h00000000,
   parameter PRBS_SADDR_MASK_POS     = 32'h00000000,
   parameter END_ADDRESS             = 32'h00ffffff,
   parameter PRBS_EADDR_MASK_POS     = 32'hff000000,
   parameter SEL_VICTIM_LINE         = 11,
   parameter RST_ACT_LOW             = 1,              // ML605 reset active high
                                       // =1 for active low reset,
                                       // =0 for active high.
   parameter INPUT_CLK_TYPE          = "DIFFERENTIAL",
                                       // input clock type DIFFERENTIAL or SINGLE_ENDED
   parameter STARVE_LIMIT            = 2
                                       // # = 2,3,4.
   )
  (

//  input                             sys_clk_p,    //differential system clocks
//  input                             sys_clk_n,
  input                             sys_clk_diff,     //differential iodelayctrl clk

   inout  [DQ_WIDTH-1:0]                ddr3_dq,
   output [ROW_WIDTH-1:0]               ddr3_addr,
   output [BANK_WIDTH-1:0]              ddr3_ba,
   output                               ddr3_ras_n,
   output                               ddr3_cas_n,
   output                               ddr3_we_n,
   output                               ddr3_reset_n,
   output [(CS_WIDTH*nCS_PER_RANK)-1:0] ddr3_cs_n,
   output [(CS_WIDTH*nCS_PER_RANK)-1:0] ddr3_odt,
   output [CKE_WIDTH-1:0]               ddr3_cke,
   output [DM_WIDTH-1:0]                 ddr3_dm,
   inout  [DQS_WIDTH-1:0]               ddr3_dqs_p,
   inout  [DQS_WIDTH-1:0]               ddr3_dqs_n,
   output [CK_WIDTH-1:0]                ddr3_ck_p,
   output [CK_WIDTH-1:0]                ddr3_ck_n,
 //  inout                                sda,      // ML605
 //  output                               scl,      // ML605 
   output                               error,
   output                               phy_init_done,
   output                               pll_lock,   // ML605 GPIO LED
   output                               heartbeat,  // ML605 GPIO LED


   input                                sys_rst,   // System reset

   output [APP_DATA_WIDTH-1:0]        app_rd_data,
   output                             app_rd_data_end,
   output                             app_rd_data_valid,
   output                             app_rdy,
   output                             app_wdf_rdy,
   input [ADDR_WIDTH-1:0]             app_addr,
   input [2:0]                        app_cmd,
   input                              app_en,
   input [APP_DATA_WIDTH-1:0]         app_wdf_data,
   input                              app_wdf_end,
   input [APP_MASK_WIDTH-1:0]         app_wdf_mask,
   input                              app_wdf_wren,

   output                                 ram_clk,
   output                                 ram_rst
 
   );

   assign ram_clk = clk;
   assign ram_rst = ~rst; // still a high reset x_X
   

  function integer STR_TO_INT;
    input [7:0] in;
    begin
      if(in == "8")
        STR_TO_INT = 8;
      else if(in == "4")
        STR_TO_INT = 4;
      else
        STR_TO_INT = 0;
    end
  endfunction

  localparam SYSCLK_PERIOD          = tCK * nCK_PER_CLK;

  localparam DATA_WIDTH          = 64;
  localparam PAYLOAD_WIDTH       = (ECC_TEST == "OFF") ? DATA_WIDTH : DQ_WIDTH;
  localparam BURST_LENGTH        = STR_TO_INT(BURST_MODE);
  localparam APP_DATA_WIDTH      = PAYLOAD_WIDTH * 4;
  localparam APP_MASK_WIDTH      = APP_DATA_WIDTH / 8;

  wire                                clk_ref;
  wire                                sys_clk;
  wire                                mmcm_clk;
  wire                                iodelay_ctrl_rdy;
      
//  (* KEEP = "TRUE" *) wire            sda_i;
//  (* KEEP = "TRUE" *) wire            scl_i;
  wire                                rst;
  wire                                clk;
  wire                                clk_mem;
  wire                                clk_rd_base;
  wire                                pd_PSDONE;
  wire                                pd_PSEN;
  wire                                pd_PSINCDEC;
  wire  [(BM_CNT_WIDTH)-1:0]          bank_mach_next;
  wire                                ddr3_parity;
  wire                                app_hi_pri;
  wire                                dfi_init_complete;
  wire [3:0]                          app_ecc_multiple_err_i;
  wire [47:0]                         traffic_wr_data_counts;
  wire [47:0]                         traffic_rd_data_counts;
  wire                                modify_enable_sel;
  wire [2:0]                          data_mode_manual_sel;
  wire [2:0]                          addr_mode_manual_sel;
  wire                                t_gen_run_traffic;
  wire  [3:0]                         t_gen_instr_mode;
  wire [31:0]                         t_gen_start_addr;
  wire [31:0]                         t_gen_end_addr;
  wire [31:0]                         t_gen_cmd_seed;
  wire [31:0]                         t_gen_data_seed;
  wire                                t_gen_load_seed;
  wire [2:0]                          t_gen_addr_mode;
  wire [1:0]                          t_gen_bl_mode;
  wire [3:0]                          t_gen_data_mode;
  wire                                t_gen_mode_load;
  wire [5:0]                          t_gen_fixed_bl;
  wire [2:0]                          t_gen_fixed_instr;
  wire [31:0]                         t_gen_fixed_addr;
  wire                                manual_clear_error;
  wire [6:0]                          tg_wr_fifo_counts;
  wire [6:0]                          tg_rd_fifo_counts;


  wire [5*DQS_WIDTH-1:0]              dbg_cpt_first_edge_cnt;
  wire [5*DQS_WIDTH-1:0]              dbg_cpt_second_edge_cnt;
  wire [5*DQS_WIDTH-1:0]              dbg_cpt_tap_cnt;
  wire                                dbg_dec_cpt;
  wire                                dbg_dec_rd_dqs;
  wire                                dbg_dec_rd_fps;
  wire [5*DQS_WIDTH-1:0]              dbg_dq_tap_cnt;
  wire [5*DQS_WIDTH-1:0]              dbg_dqs_tap_cnt;
  wire                                dbg_inc_cpt;
  wire [DQS_CNT_WIDTH-1:0]            dbg_inc_dec_sel;
  wire                                dbg_inc_rd_dqs;
  wire                                dbg_inc_rd_fps;
  wire                                dbg_ocb_mon_off;
  wire                                dbg_pd_off;
  wire                                dbg_pd_maintain_off;
  wire                                dbg_pd_maintain_0_only;
  wire [4:0]                          dbg_rd_active_dly;
  wire [3*DQS_WIDTH-1:0]              dbg_rd_bitslip_cnt;
  wire [2*DQS_WIDTH-1:0]              dbg_rd_clkdly_cnt;
  wire [4*DQ_WIDTH-1:0]               dbg_rddata;
  wire [1:0]                          dbg_rdlvl_done;
  wire [1:0]                          dbg_rdlvl_err;
  wire [1:0]                          dbg_rdlvl_start;
  wire [DQS_WIDTH-1:0]                dbg_wl_dqs_inverted;
  wire [5*DQS_WIDTH-1:0]              dbg_wl_odelay_dq_tap_cnt;
  wire [5*DQS_WIDTH-1:0]              dbg_wl_odelay_dqs_tap_cnt;
  wire [2*DQS_WIDTH-1:0]              dbg_wr_calib_clk_delay;
  wire [5*DQS_WIDTH-1:0]              dbg_wr_dq_tap_set;
  wire [5*DQS_WIDTH-1:0]              dbg_wr_dqs_tap_set;
  wire                                dbg_wr_tap_set_en;
  wire 			                      dbg_idel_up_all; 
  wire 			                      dbg_idel_down_all; 
  wire 			                      dbg_idel_up_cpt; 
  wire 			                      dbg_idel_down_cpt; 
  wire 			                      dbg_idel_up_rsync; 
  wire 			                      dbg_idel_down_rsync; 
  wire 			                      dbg_sel_all_idel_cpt; 
  wire 			                      dbg_sel_all_idel_rsync; 
  wire 			                      dbg_pd_inc_cpt; 
  wire 			                      dbg_pd_dec_cpt; 
  wire 			                      dbg_pd_inc_dqs; 
  wire 			                      dbg_pd_dec_dqs; 
  wire 			                      dbg_pd_disab_hyst; 
  wire 			                      dbg_pd_disab_hyst_0; 
  wire                                dbg_wrlvl_done;
  wire                                dbg_wrlvl_err;
  wire                                dbg_wrlvl_start;
  wire [4:0]                          dbg_tap_cnt_during_wrlvl;  
  wire [19:0]                         dbg_rsync_tap_cnt;  
  wire [255:0]                        dbg_phy_pd;
  wire [255:0]                        dbg_phy_read;
  wire [255:0]                        dbg_phy_rdlvl;
  wire [255:0]                        dbg_phy_top;
  wire [3:0]                          dbg_pd_msb_sel;
  wire [DQS_WIDTH-1:0]                dbg_rd_data_edge_detect;
  wire [DQS_CNT_WIDTH-1:0]            dbg_sel_idel_cpt;
  wire [DQS_CNT_WIDTH-1:0]            dbg_sel_idel_rsync;
  wire [DQS_CNT_WIDTH-1:0]            dbg_pd_byte_sel;

  wire                                ddr3_cs0_clk;
  wire [35:0]                         ddr3_cs0_control;
  wire [383:0]                        ddr3_cs0_data;
  wire [7:0]                          ddr3_cs0_trig;
  wire [255:0]                        ddr3_cs1_async_in;
  wire [35:0]                         ddr3_cs1_control;
  wire [255:0]                        ddr3_cs2_async_in;
  wire [35:0]                         ddr3_cs2_control;
  wire [255:0]                        ddr3_cs3_async_in;
  wire [35:0]                         ddr3_cs3_control;
  wire                                ddr3_cs4_clk;
  wire [35:0]                         ddr3_cs4_control;
  wire [31:0]                         ddr3_cs4_sync_out;


  assign phy_init_done = dfi_init_complete;
  assign app_hi_pri = 1'b0;
//  assign app_wdf_mask = {APP_MASK_WIDTH{1'b0}};

// ML605 comment out the following signals to enable traffic generator control from VIO console:
// assign manual_clear_error     = 1'b0;
// assign modify_enable_sel      = 1'b1;
// assign data_mode_manual_sel   = 3'b010; // ADDR_DATA
// assign addr_mode_manual_sel   = 3'b011; //SEQUENTIAL_ADDR

  wire  locked; // ML605
  assign pll_lock = locked;  // ML605 

/*  MUXCY scl_inst
    (
     .O  (scl),
     .CI (scl_i),
     .DI (1'b0),
     .S  (1'b1)
     );

  MUXCY sda_inst
    (
     .O  (sda),
     .CI (sda_i),
     .DI (1'b0),
     .S  (1'b1)
     );
*/
  assign clk_ref = 1'b0;
//  assign sys_clk = 1'b0; 
// ML605 200MHz clock sourced from BUFG within "idelay_ctrl" module.
  wire clk_200;    
  //***************************************************************************


  iodelay_ctrl #
    (
     .TCQ            (TCQ),
     .IODELAY_GRP    (IODELAY_GRP),
     .INPUT_CLK_TYPE (INPUT_CLK_TYPE),
     .RST_ACT_LOW    (RST_ACT_LOW)
     )
    u_iodelay_ctrl
      (
       .sys_clk_diff     (sys_clk_diff),  // ML605 200MHz EPSON oscillator
       .clk_ref          (clk_ref),
       .sys_rst          (sys_rst),
       .clk_200          (clk_200),    // ML605 200MHz clock from BUFG to MMCM CLKIN1
       .iodelay_ctrl_rdy (iodelay_ctrl_rdy)
       );
/* ML605 comment out "clk_ibuf" module. MIG default requires 2 inputs clocks.

  clk_ibuf #
    (
     .INPUT_CLK_TYPE (INPUT_CLK_TYPE)
     )
    u_clk_ibuf
      (
       .sys_clk_p         (sys_clk_p),
       .sys_clk_n         (sys_clk_n),
       .sys_clk           (sys_clk),
       .mmcm_clk          (mmcm_clk)
       );
*/
 
  infrastructure #
    (
     .TCQ                (TCQ),
     .CLK_PERIOD         (SYSCLK_PERIOD),
     .nCK_PER_CLK        (nCK_PER_CLK),
     .MMCM_ADV_BANDWIDTH (MMCM_ADV_BANDWIDTH),
     .CLKFBOUT_MULT_F    (CLKFBOUT_MULT_F),
     .DIVCLK_DIVIDE      (DIVCLK_DIVIDE),
     .CLKOUT_DIVIDE      (CLKOUT_DIVIDE),
     .RST_ACT_LOW        (RST_ACT_LOW)
     )
    u_infrastructure
      (
       .clk_mem          (clk_mem),
       .clk              (clk),
       .clk_rd_base      (clk_rd_base),
       .pll_lock         (locked),     // ML605 GPIO LED output port
       .rstdiv0          (rst),
       .mmcm_clk         (clk_200),    // ML605 single input clock 200MHz from "iodelay_ctrl"
       .sys_rst          (sys_rst),
       .iodelay_ctrl_rdy (iodelay_ctrl_rdy),
       .PSDONE           (pd_PSDONE),
       .PSEN             (pd_PSEN),
       .PSINCDEC         (pd_PSINCDEC)
       );


  memc_ui_top #
  (
   .ADDR_CMD_MODE        (ADDR_CMD_MODE),
   .BANK_WIDTH           (BANK_WIDTH),
   .CK_WIDTH             (CK_WIDTH),
   .CKE_WIDTH            (CKE_WIDTH),
   .nCK_PER_CLK          (nCK_PER_CLK),
   .COL_WIDTH            (COL_WIDTH),
   .CS_WIDTH             (CS_WIDTH),
   .DM_WIDTH             (DM_WIDTH),
   .nCS_PER_RANK         (nCS_PER_RANK),
   .DEBUG_PORT           (DEBUG_PORT),
   .IODELAY_GRP          (IODELAY_GRP),
   .DQ_WIDTH             (DQ_WIDTH),
   .DQS_WIDTH            (DQS_WIDTH),
   .DQS_CNT_WIDTH        (DQS_CNT_WIDTH),
   .ORDERING             (ORDERING),
   .OUTPUT_DRV           (OUTPUT_DRV),
   .PHASE_DETECT         (PHASE_DETECT),
   .RANK_WIDTH           (RANK_WIDTH),
   .REFCLK_FREQ          (REFCLK_FREQ),
   .REG_CTRL             (REG_CTRL),
   .ROW_WIDTH            (ROW_WIDTH),
   .RTT_NOM              (RTT_NOM),
   .RTT_WR               (RTT_WR),
   .SIM_CAL_OPTION       (SIM_CAL_OPTION),
   .SIM_INIT_OPTION      (SIM_INIT_OPTION),
   .SIM_BYPASS_INIT_CAL  (SIM_BYPASS_INIT_CAL),
   .WRLVL                (WRLVL),
   .nDQS_COL0            (nDQS_COL0),
   .nDQS_COL1            (nDQS_COL1),
   .nDQS_COL2            (nDQS_COL2),
   .nDQS_COL3            (nDQS_COL3),
   .DQS_LOC_COL0         (DQS_LOC_COL0),
   .DQS_LOC_COL1         (DQS_LOC_COL1),
   .DQS_LOC_COL2         (DQS_LOC_COL2),
   .DQS_LOC_COL3         (DQS_LOC_COL3),
   .tPRDI                (tPRDI),
   .tREFI                (tREFI),
   .tZQI                 (tZQI),
   .BURST_MODE           (BURST_MODE),
   .BM_CNT_WIDTH         (BM_CNT_WIDTH),
   .tCK                  (tCK),
   .ADDR_WIDTH           (ADDR_WIDTH),
   .TCQ                  (TCQ),
   .ECC_TEST             (ECC_TEST),
   .PAYLOAD_WIDTH        (PAYLOAD_WIDTH)
   )
  u_memc_ui_top
  (
   .clk                              (clk),
   .clk_mem                          (clk_mem),
   .clk_rd_base                      (clk_rd_base),
   .rst                              (rst),
   .ddr_addr                         (ddr3_addr),
   .ddr_ba                           (ddr3_ba),
   .ddr_cas_n                        (ddr3_cas_n),
   .ddr_ck_n                         (ddr3_ck_n),
   .ddr_ck                           (ddr3_ck_p),
   .ddr_cke                          (ddr3_cke),
   .ddr_cs_n                         (ddr3_cs_n),
   .ddr_dm                           (ddr3_dm),
   .ddr_odt                          (ddr3_odt),
   .ddr_ras_n                        (ddr3_ras_n),
   .ddr_reset_n                      (ddr3_reset_n),
   .ddr_parity                       (ddr3_parity),
   .ddr_we_n                         (ddr3_we_n),
   .ddr_dq                           (ddr3_dq),
   .ddr_dqs_n                        (ddr3_dqs_n),
   .ddr_dqs                          (ddr3_dqs_p),
   .pd_PSEN                          (pd_PSEN),
   .pd_PSINCDEC                      (pd_PSINCDEC),
   .pd_PSDONE                        (pd_PSDONE),
   .dfi_init_complete                (dfi_init_complete),
   .bank_mach_next                   (bank_mach_next),
   .app_ecc_multiple_err             (app_ecc_multiple_err_i),
   .app_rd_data                      (app_rd_data),
   .app_rd_data_end                  (app_rd_data_end),
   .app_rd_data_valid                (app_rd_data_valid),
   .app_rdy                          (app_rdy),
   .app_wdf_rdy                      (app_wdf_rdy),
   .app_addr                         (app_addr),
   .app_cmd                          (app_cmd),
   .app_en                           (app_en),
   .app_hi_pri                       (app_hi_pri),
   .app_sz                           (1'b1),
   .app_wdf_data                     (app_wdf_data),
   .app_wdf_end                      (app_wdf_end),
   .app_wdf_mask                     (app_wdf_mask),
   .app_wdf_wren                     (app_wdf_wren),
   .dbg_wr_dqs_tap_set               (dbg_wr_dqs_tap_set),
   .dbg_wr_dq_tap_set                (dbg_wr_dq_tap_set),
   .dbg_wr_tap_set_en                (dbg_wr_tap_set_en),
   .dbg_wrlvl_start                  (dbg_wrlvl_start),
   .dbg_wrlvl_done                   (dbg_wrlvl_done),
   .dbg_wrlvl_err                    (dbg_wrlvl_err),
   .dbg_wl_dqs_inverted              (dbg_wl_dqs_inverted),
   .dbg_wr_calib_clk_delay           (dbg_wr_calib_clk_delay),
   .dbg_wl_odelay_dqs_tap_cnt        (dbg_wl_odelay_dqs_tap_cnt),
   .dbg_wl_odelay_dq_tap_cnt         (dbg_wl_odelay_dq_tap_cnt),
   .dbg_rdlvl_start                  (dbg_rdlvl_start),
   .dbg_rdlvl_done                   (dbg_rdlvl_done),
   .dbg_rdlvl_err                    (dbg_rdlvl_err),
   .dbg_cpt_tap_cnt                  (dbg_cpt_tap_cnt),
   .dbg_cpt_first_edge_cnt           (dbg_cpt_first_edge_cnt),
   .dbg_cpt_second_edge_cnt          (dbg_cpt_second_edge_cnt),
   .dbg_rd_bitslip_cnt               (dbg_rd_bitslip_cnt),
   .dbg_rd_clkdly_cnt                (dbg_rd_clkdly_cnt),
   .dbg_rd_active_dly                (dbg_rd_active_dly),
   .dbg_pd_off                       (dbg_pd_off),
   .dbg_pd_maintain_off              (dbg_pd_maintain_off),
   .dbg_pd_maintain_0_only           (dbg_pd_maintain_0_only),
   .dbg_inc_cpt                      (dbg_inc_cpt),
   .dbg_dec_cpt                      (dbg_dec_cpt),
   .dbg_inc_rd_dqs                   (dbg_inc_rd_dqs),
   .dbg_dec_rd_dqs                   (dbg_dec_rd_dqs),
   .dbg_inc_dec_sel                  (dbg_inc_dec_sel),
   .dbg_inc_rd_fps                   (dbg_inc_rd_fps),
   .dbg_dec_rd_fps                   (dbg_dec_rd_fps),
   .dbg_dqs_tap_cnt                  (dbg_dqs_tap_cnt),
   .dbg_dq_tap_cnt                   (dbg_dq_tap_cnt),
   .dbg_rddata                       (dbg_rddata)
   );


  // If debug port is not enabled, then make certain control input
  // to Debug Port are disabled
  generate
    if (DEBUG_PORT == "OFF") begin: gen_dbg_tie_off
      assign dbg_wr_dqs_tap_set     = 'b0;
      assign dbg_wr_dq_tap_set      = 'b0;
      assign dbg_wr_tap_set_en      = 1'b0;
      assign dbg_pd_off             = 1'b0;
      assign dbg_pd_maintain_off    = 1'b0;
      assign dbg_pd_maintain_0_only = 1'b0;
      assign dbg_ocb_mon_off        = 1'b0;
      assign dbg_inc_cpt            = 1'b0;
      assign dbg_dec_cpt            = 1'b0;
      assign dbg_inc_rd_dqs         = 1'b0;
      assign dbg_dec_rd_dqs         = 1'b0;
      assign dbg_inc_dec_sel        = 'b0;
      assign dbg_inc_rd_fps         = 1'b0;
      assign dbg_pd_msb_sel         = 'b0 ;
      assign dbg_sel_idel_cpt       = 'b0 ;	 
      assign dbg_sel_idel_rsync     = 'b0 ;
      assign dbg_pd_byte_sel        = 'b0 ;	
      assign dbg_dec_rd_fps         = 1'b0;
    end
  endgenerate

endmodule
