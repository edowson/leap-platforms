//
// Copyright (C) 2011 Massachusetts Institute of Technology
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//

// This module interfaces to the sata cable slot SATA HOST 0 on the
// XUPV5. However only certain of the generated verilog and ucf files
// are needed to characterize this interface, and it can be used a model 
// for high-speed board to board serial on other development boards. The 
// device interface consists of a simple FIFO with guaranteed transport to
// the other device. 

import Clocks::*;
import FIFOF::*;
import FIFOLevel::*;
import Connectable::*;
import GetPut::*;

interface AURORA_WIRES;
    (* prefix = "" *)
    method Action serdes_clk_n((* port="AURORA_GREFCLK_N_IN" *) Bit#(1) clk_n);

    (* prefix = "" *)      
    method Action serdes_clk_p((* port="AURORA_GREFCLK_P_IN" *) Bit#(1) clk_p);
   
    (* prefix = "" *)      
    method Action rxn_in((* port="RXN_IN" *) Bit#(1) rxn);

    (* prefix = "" *)      
    method Action rxp_in((* port="RXP_IN" *) Bit#(1) rxp);

    (* always_ready *)
    (* result = "TXN_OUT" *)
    method Bit#(1) txn_out();

    (* always_ready *)
    (* result = "TXP_OUT" *)
    method Bit#(1) txp_out();
      
endinterface

// guard interface
interface AURORA_DRIVER;
    method Action                 write(Bit#(16) tx_word); // txusrclk 
    method Bool                   write_ready(); // txusrclk 
    method Action                 deq(); // rxusrclk0     
    method Bit#(16)               first(); // rxusrclk0     

    // These methods are a basic debugging interface
    method Bit#(1) channel_up;
    method Bit#(1) lane_up;
    method Bit#(1) hard_err;
    method Bit#(1) soft_err;
    method Bit#(32) status;
    method Bit#(32) rx_count;
    method Bit#(32) tx_count;
    method UInt#(5) rx_fifo_count;
    method UInt#(5) tx_fifo_count;

endinterface

interface AURORA_DEVICE;
    (* prefix = "" *)      
    interface AURORA_WIRES wires;
    interface AURORA_DRIVER driver;
endinterface      

module mkAURORA_DEVICE (AURORA_DEVICE);

    let ug_device <- mkAURORA_SINGLE_UG();

    // Repair the clock domain stuff down here...
    let aurora_rst <- mkAsyncReset(10, ug_device.aurora_rst, ug_device.aurora_clk);
    let clk <- exposeCurrentClock();
    let rst <- exposeCurrentReset();

    Bit#(16) handshakeWords[4] = {'hdead,'hbeef,'hcafe,'hfeed};

    Reg#(Bit#(16)) ccCycles  <- mkReg(maxBound, clocked_by(ug_device.aurora_clk), reset_by(aurora_rst)); 
    Reg#(Bit#(2)) handshakeRX <- mkReg(0, clocked_by(ug_device.aurora_clk), reset_by(aurora_rst)); 
    Reg#(Bit#(2)) handshakeTX <- mkReg(0, clocked_by(ug_device.aurora_clk), reset_by(aurora_rst)); 
    Reg#(Bool) handshakeRXDone <- mkReg(False, clocked_by(ug_device.aurora_clk), reset_by(aurora_rst)); 
    Reg#(Bool) handshakeTXDone <- mkReg(False, clocked_by(ug_device.aurora_clk), reset_by(aurora_rst)); 
    Reg#(Bool) ccLast <- mkReg(False, clocked_by(ug_device.aurora_clk), reset_by(aurora_rst)); 

    SyncFIFOCountIfc#(Bit#(16),16) serdes_rxfifo <- mkSyncFIFOCount( ug_device.aurora_clk, aurora_rst, clk);
    SyncFIFOCountIfc#(Bit#(16),16) serdes_txfifo <- mkSyncFIFOCount( clk, rst, ug_device.aurora_clk);

    rule updateCCLast;
        ccLast <= ug_device.cc;
    endrule

    rule tickCC(ccCycles > 0 && ug_device.cc  && !ccLast);
        ccCycles <= ccCycles - 1;
    endrule

    rule txHandshake (ccCycles == 0 && !handshakeTXDone);
        handshakeTX <= handshakeTX + 1;
        if(handshakeTX + 1 == 0)
        begin
            handshakeTXDone <= True;
        end
        ug_device.send(handshakeWords[handshakeTX]);
    endrule

    rule rxHandshake (!handshakeRXDone);
        let data <- ug_device.receive;
        Bool handshakeMatch = handshakeWords[handshakeRX] == data;
        if(handshakeMatch)
        begin
            handshakeRX <= handshakeRX + 1;
        end
        else 
        begin
            handshakeRX <= 0;
        end

        if(handshakeRX + 1 == 0 && handshakeMatch)
        begin
            handshakeRXDone <= True;
        end
    endrule


    rule tx (handshakeTXDone);
        serdes_txfifo.deq;
        ug_device.send(serdes_txfifo.first);
    endrule

    rule rx (handshakeRXDone);  // we always need to receive.  We may want to send a sync word here...
        let data <- ug_device.receive;
        serdes_rxfifo.enq(data);
    endrule

    rule sendStats;
        ug_device.stats(serdes_txfifo.dCount, serdes_txfifo.dNotEmpty, serdes_txfifo.dNotFull, serdes_rxfifo.sCount, serdes_rxfifo.sNotEmpty, serdes_rxfifo.sNotFull);
    endrule
  
    interface AURORA_WIRES wires;
        method serdes_clk_n = ug_device.clk_n_in;
        method serdes_clk_p = ug_device.clk_p_in;
        method rxn_in = ug_device.rxn_in;
        method rxp_in = ug_device.rxp_in;
        method txn_out = ug_device.txn_out;
        method txp_out = ug_device.txp_out;
    endinterface
   
    interface AURORA_DRIVER driver;
        method write = serdes_txfifo.enq;

        method write_ready = serdes_txfifo.sNotFull();

        method Action deq = serdes_rxfifo.deq();

        method Bit#(16) first = serdes_rxfifo.first();

        method channel_up = ug_device.channel_up;
        method lane_up = ug_device.lane_up;
        method hard_err = ug_device.hard_err;
        method soft_err = ug_device.soft_err;
 
        method status = ug_device.status;
        method rx_count = ug_device.rx_count;
        method tx_count = ug_device.tx_count;
        method rx_fifo_count = serdes_rxfifo.dCount;
        method tx_fifo_count = serdes_txfifo.sCount;
    endinterface
 
endmodule
