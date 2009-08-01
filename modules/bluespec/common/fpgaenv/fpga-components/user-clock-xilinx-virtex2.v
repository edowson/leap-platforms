//Device: xc5vlx110-1ff1153
// Generated by Xilinx Architecture Wizard, then modified for Bluespec
// parameterization.
//

`timescale 1ns / 1ps


// ========================================================================
//
// CLK_FX -- Configurable multiple of base clock, taking three parameters:
//
//     1.  Incoming clock period (in ns)
//     2.  Multiplier to apply to incoming clock (integer 1-32)
//     3.  Divisor to apply to incoming clock (integer 2-32)
//
//   The outgoing clock is (M / D) * incoming clock frequency
//
// ========================================================================

module clk_fx(CLKIN_IN, 
              RST_IN, 
              CLK0_OUT, 
              CLKFX_OUT, 
              LOCKED_OUT);

   parameter FX_CLKIN_PERIOD = 20;
   parameter FX_CLKFX_MULTIPLY = 4;
   parameter FX_CLKFX_DIVIDE = 1;

    input CLKIN_IN;
    input RST_IN;
   output CLK0_OUT;
   output CLKFX_OUT;
   output LOCKED_OUT;
   
   wire CLKFB_IN;
   wire CLK0_BUF;
   wire CLKFX_BUF;
   wire GND_BIT;
   wire [6:0] GND_BUS_7;
   wire [15:0] GND_BUS_16;
   
   assign GND_BIT = 0;
   assign GND_BUS_7 = 7'b0000000;
   assign GND_BUS_16 = 16'b0000000000000000;
   assign CLK0_OUT = CLKFB_IN;
   BUFG CLK0_BUFG_INST (.I(CLK0_BUF), 
                        .O(CLKFB_IN));
   BUFG CLKFX_BUFG_INST (.I(CLKFX_BUF), 
                         .O(CLKFX_OUT));
   DCM DCM_ADV_INST_FX (.CLKFB(CLKFB_IN), 
                         .CLKIN(CLKIN_IN),
                         .PSCLK(GND_BIT), 
                         .PSEN(GND_BIT), 
                         .PSINCDEC(GND_BIT), 
                         .RST(RST_IN), 
                         .CLKDV(), 
                         .CLKFX(CLKFX_BUF), 
                         .CLKFX180(), 
                         .CLK0(CLK0_BUF), 
                         .CLK2X(), 
                         .CLK2X180(), 
                         .CLK90(), 
                         .CLK180(), 
                         .CLK270(), 
                         .LOCKED(LOCKED_OUT), 
                         .PSDONE());
   defparam DCM_ADV_INST_FX.CLK_FEEDBACK = "1X";
   defparam DCM_ADV_INST_FX.CLKDV_DIVIDE = 2.0;
   defparam DCM_ADV_INST_FX.CLKFX_DIVIDE = FX_CLKFX_DIVIDE;
   defparam DCM_ADV_INST_FX.CLKFX_MULTIPLY = FX_CLKFX_MULTIPLY;
   defparam DCM_ADV_INST_FX.CLKIN_DIVIDE_BY_2 = "FALSE";
   defparam DCM_ADV_INST_FX.CLKIN_PERIOD = FX_CLKIN_PERIOD;
   defparam DCM_ADV_INST_FX.CLKOUT_PHASE_SHIFT = "NONE";
   defparam DCM_ADV_INST_FX.DESKEW_ADJUST = "SYSTEM_SYNCHRONOUS";
   defparam DCM_ADV_INST_FX.DFS_FREQUENCY_MODE = "LOW";
   defparam DCM_ADV_INST_FX.DLL_FREQUENCY_MODE = "LOW";
   defparam DCM_ADV_INST_FX.DUTY_CYCLE_CORRECTION = "TRUE";
   defparam DCM_ADV_INST_FX.FACTORY_JF = 16'hF0F0;
   defparam DCM_ADV_INST_FX.PHASE_SHIFT = 0;
   defparam DCM_ADV_INST_FX.STARTUP_WAIT = "FALSE";
endmodule

//
// Bluespec interface
//
module mkUserClock_Ratio(CLK, RST_N, CLK_OUT, RST_N_OUT);

   parameter CR_CLKIN_PERIOD = 20;
   parameter CR_CLKFX_MULTIPLY = 4;
   parameter CR_CLKFX_DIVIDE = 1;

   input CLK;
   input RST_N;
   output CLK_OUT;
   output RST_N_OUT;
   
   wire   RST;
   
   assign RST = !RST_N;

   clk_fx#(CR_CLKIN_PERIOD,
           CR_CLKFX_MULTIPLY,
           CR_CLKFX_DIVIDE)
      x (.CLKIN_IN(CLK),
         .RST_IN(RST),
         .CLK0_OUT(),
         .CLKFX_OUT(CLK_OUT),
         .LOCKED_OUT(RST_N_OUT));

endmodule



// ========================================================================
//
// CLK_2X -- Special case:  2 * incoming clock frequency.  Incoming clock
//           period specified as parameter (ns).
//
// ========================================================================

module clk_2x(CLKIN_IN,
              RST_IN,
              CLK0_OUT,
              CLK2X_OUT,
              LOCKED_OUT);

   parameter C2X_CLKIN_PERIOD = 20;

   input CLKIN_IN;
   input RST_IN;
   output CLK0_OUT;
   output CLK2X_OUT;
   output LOCKED_OUT;

   wire CLKFB_IN;
   wire CLK0_BUF;
   wire CLK2X_BUF;
   wire GND_BIT;
   wire [6:0] GND_BUS_7;
   wire [15:0] GND_BUS_16;

   assign GND_BIT = 0;
   assign GND_BUS_7 = 7'b0000000;
   assign GND_BUS_16 = 16'b0000000000000000;
   assign CLK0_OUT = CLKFB_IN;
   BUFG CLK0_BUFG_INST (.I(CLK0_BUF),
                        .O(CLKFB_IN));
   BUFG CLK2X_BUFG_INST (.I(CLK2X_BUF),
                         .O(CLK2X_OUT));
   DCM_ADV DCM_ADV_INST_2X (.CLKFB(CLKFB_IN),
                         .CLKIN(CLKIN_IN),
                         .DADDR(GND_BUS_7[6:0]),
                         .DCLK(GND_BIT),
                         .DEN(GND_BIT),
                         .DI(GND_BUS_16[15:0]),
                         .DWE(GND_BIT),
                         .PSCLK(GND_BIT),
                         .PSEN(GND_BIT),
                         .PSINCDEC(GND_BIT),
                         .RST(RST_IN),
                         .CLKDV(),
                         .CLKFX(),
                         .CLKFX180(),
                         .CLK0(CLK0_BUF),
                         .CLK2X(CLK2X_BUF),
                         .CLK2X180(),
                         .CLK90(),
                         .CLK180(),
                         .CLK270(),
                         .DO(),
                         .DRDY(),
                         .LOCKED(LOCKED_OUT),
                         .PSDONE());
   defparam DCM_ADV_INST_2X.CLK_FEEDBACK = "1X";
   defparam DCM_ADV_INST_2X.CLKDV_DIVIDE = 2.0;
   defparam DCM_ADV_INST_2X.CLKFX_DIVIDE = 1;
   defparam DCM_ADV_INST_2X.CLKFX_MULTIPLY = 4;
   defparam DCM_ADV_INST_2X.CLKIN_DIVIDE_BY_2 = "FALSE";
   defparam DCM_ADV_INST_2X.CLKIN_PERIOD = C2X_CLKIN_PERIOD;
   defparam DCM_ADV_INST_2X.CLKOUT_PHASE_SHIFT = "NONE";
   defparam DCM_ADV_INST_2X.DCM_AUTOCALIBRATION = "TRUE";
   defparam DCM_ADV_INST_2X.DCM_PERFORMANCE_MODE = "MAX_SPEED";
   defparam DCM_ADV_INST_2X.DESKEW_ADJUST = "SYSTEM_SYNCHRONOUS";
   defparam DCM_ADV_INST_2X.DFS_FREQUENCY_MODE = "LOW";
   defparam DCM_ADV_INST_2X.DLL_FREQUENCY_MODE = "LOW";
   defparam DCM_ADV_INST_2X.DUTY_CYCLE_CORRECTION = "TRUE";
   defparam DCM_ADV_INST_2X.FACTORY_JF = 16'hF0F0;
   defparam DCM_ADV_INST_2X.PHASE_SHIFT = 0;
   defparam DCM_ADV_INST_2X.STARTUP_WAIT = "FALSE";
   defparam DCM_ADV_INST_2X.SIM_DEVICE = "VIRTEX5";
endmodule


//
// Bluespec interface
//
module mkUserClock_MultiplyByTwo(CLK, RST_N, CLK_OUT, RST_N_OUT);

   parameter C2_CLKIN_PERIOD = 20;

   input CLK;
   input RST_N;
   output CLK_OUT;
   output RST_N_OUT;
   
   wire   RST;
   
   assign RST = !RST_N;
   clk_2x#(C2_CLKIN_PERIOD)
      x (.CLKIN_IN(CLK),
         .RST_IN(RST),
         .CLK0_OUT(),
         .CLK2X_OUT(CLK_OUT),
         .LOCKED_OUT(RST_N_OUT));

endmodule
