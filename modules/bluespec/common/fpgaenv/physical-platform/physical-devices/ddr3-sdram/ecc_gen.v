//*****************************************************************************
// (c) Copyright 2008-2009 Xilinx, Inc. All rights reserved.
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
// /___/  \  /    Vendor                : Xilinx
// \   \   \/     Version               : 3.9
//  \   \         Application           : MIG
//  /   /         Filename              : ecc_gen.v
// /___/   /\     Date Last Modified    : $date$
// \   \  /  \    Date Created          : Tue Jun 30 2009
//  \___\/\___\
//
//Device            : Virtex-6
//Design Name       : DDR3 SDRAM
//Purpose           :
//Reference         :
//Revision History  :
//*****************************************************************************

`timescale 1ps/1ps

// Generate the ecc code.  Note that the synthesizer should
// generate this as a static logic.  Code in this block should
// never run during simulation phase, or directly impact timing.
//
// The code generated is a single correct, double detect code.
// It is the classic Hamming code.  Instead, the code is
// optimized for minimal/balanced tree depth and size.  See
// Hsiao IBM Technial Journal 1970.
//
// The code is returned as a single bit vector, h_rows.  This was
// the only way to "subroutinize" this with the restrictions of
// disallowed include files and that matrices cannot be passed
// in ports.
//
// Factorial and the combos functions are defined.  Combos
// simply computes the number of combinations from the set
// size and elements at a time.
//
// The function next_combo computes the next combination in
// lexicographical order given the "current" combination.  Its
// output is undefined if given the last combination in the 
// lexicographical order. 
// 
// next_combo is insensitive to the number of elements in the
// combinations.
//
// An H transpose matrix is generated because that's the easiest
// way to do it. The H transpose matrix is generated by taking
// the one at a time combinations, then the 3 at a time, then
// the 5 at a time.  The number combinations used is equal to
// the width of the code (CODE_WIDTH).  The boundaries between
// the 1, 3 and 5 groups are hardcoded in the for loop.
//
// At the same time the h_rows vector is generated from the
// H transpose matrix.

module ecc_gen 
  #(
    parameter CODE_WIDTH        = 72,
    parameter ECC_WIDTH         = 8,
    parameter DATA_WIDTH        = 64
   )
   (
     /*AUTOARG*/
  // Outputs
  h_rows
  );
 

  function integer factorial (input integer i);
    integer index;
    if (i == 1) factorial = 1;
    else begin
      factorial = 1;
      for (index=2; index<=i; index=index+1)
        factorial = factorial * index;
    end
  endfunction // factorial

  function integer combos (input integer n, k);
    combos = factorial(n)/(factorial(k)*factorial(n-k));
  endfunction // combinations
  
  // function next_combo
  // Given a combination, return the next combo in lexicographical
  // order.  Scans from right to left.  Assumes the first combination
  // is k ones all of the way to the left.
  //
  // Upon entry, initialize seen0, trig1, and ones.  "seen0" means
  // that a zero has been observed while scanning from right to left.
  // "trig1" means that a one have been observed _after_ seen0 is set.
  // "ones" counts the number of ones observed while scanning the input.
  //
  // If trig1 is one, just copy the input bit to the output and increment
  // to the next bit.  Otherwise  set the the output bit to zero, if the 
  // input is a one, increment ones.  If the input bit is a one and seen0
  // is true, dump out the accumulated ones.  Set seen0 to the complement
  // of the input bit.  Note that seen0 is not used subsequent to trig1 
  // getting set.
  function [ECC_WIDTH-1:0] next_combo (input [ECC_WIDTH-1:0] i);
    integer index;
    integer dump_index;
    reg seen0;
    reg trig1;
//    integer ones;
    reg [ECC_WIDTH-1:0] ones;
    begin
      seen0 = 1'b0;
      trig1 = 1'b0;
      ones = 0;
      for (index=0; index<ECC_WIDTH; index=index+1)
        begin
          // The "== 1'bx" is so this will converge at time zero.
          // XST assumes false, which should be OK.
          if ((&i == 1'bx) || trig1) next_combo[index] = i[index];
          else begin
            next_combo[index] = 1'b0;
            ones = ones + i[index];
            if (i[index] && seen0) begin
              trig1 = 1'b1;
              for (dump_index=index-1; dump_index>=0;dump_index=dump_index-1)
                if (dump_index>=index-ones) next_combo[dump_index] = 1'b1;  
            end               
            seen0 = ~i[index];
          end // else: !if(trig1)
        end            
    end // function
  endfunction // next_combo

  wire [ECC_WIDTH-1:0] ht_matrix [CODE_WIDTH-1:0];
  output wire [CODE_WIDTH*ECC_WIDTH-1:0] h_rows;

  localparam COMBOS_3 = combos(ECC_WIDTH, 3);
  localparam COMBOS_5 = combos(ECC_WIDTH, 5);
  genvar n;
  genvar s;
  generate
    for (n=0; n<CODE_WIDTH; n=n+1) begin : ht
      if (n == 0)                
         assign ht_matrix[n] = {{3{1'b1}}, {ECC_WIDTH-3{1'b0}}};
      else if (n == COMBOS_3 && n < DATA_WIDTH)    
         assign ht_matrix[n] = {{5{1'b1}}, {ECC_WIDTH-5{1'b0}}};
      else if ((n == COMBOS_3+COMBOS_5) && n < DATA_WIDTH)    
         assign ht_matrix[n] = {{7{1'b1}}, {ECC_WIDTH-7{1'b0}}};
      else if (n == DATA_WIDTH)   
         assign ht_matrix[n] = {{1{1'b1}}, {ECC_WIDTH-1{1'b0}}};
      else assign ht_matrix[n] = next_combo(ht_matrix[n-1]);
      
      for (s=0; s<ECC_WIDTH; s=s+1) begin : h_row
        assign h_rows[s*CODE_WIDTH+n] = ht_matrix[n][s];
      end
    end
  endgenerate 
  
endmodule // ecc_gen
