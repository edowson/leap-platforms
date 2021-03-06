//
// Copyright (c) 2014, Intel Corporation
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// Redistributions of source code must retain the above copyright notice, this
// list of conditions and the following disclaimer.
//
// Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation
// and/or other materials provided with the distribution.
//
// Neither the name of the Intel Corporation nor the names of its contributors
// may be used to endorse or promote products derived from this software
// without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.
//

// This module interfaces to the SMA cables on the
// XUPV5. However only certain of the generated verilog and ucf files
// are needed to characterize this interface, and it can be used a model 
// for high-speed board to board serial on other development boards. The 
// device interface consists of a simple FIFO with guaranteed transport to
// the other device. This module is slightly complicated by the need to 
// instantiate dummy serial modules to route clock to the SMA GTP.


import Clocks::*;
import FIFOF::*;
import FIFOLevel::*;
import Connectable::*;
import GetPut::*;
import Vector::*;

`include "awb/provides/librl_bsv_base.bsh"
`include "awb/provides/librl_bsv_storage.bsh"


interface AURORA_WIRES;

    method Action aurora_clk_n((* port="AURORA_GREFCLK_N_IN" *) Bit#(1) clk_n);

    method Action aurora_clk_p((* port="AURORA_GREFCLK_P_IN" *) Bit#(1) clk_p);
   
    method Action aurora_rxn_in((* port="AURORA_RXN_IN" *) Bit#(1) rxn);

    method Action aurora_rxp_in((* port="AURORA_RXP_IN" *) Bit#(1) rxp);

    (* result = "AURORA_TXN_OUT" *)
    method Bit#(1) aurora_txn_out();

    (* result = "AURORA_TXP_OUT" *)
    method Bit#(1) aurora_txp_out();


    // Dummy GTP for clocking goodness

    method Action rxn_in_dummy0((* port="RXN_IN_dummy0" *) Bit#(1) rxn);
    method Action rxp_in_dummy0((* port="RXP_IN_dummy0" *) Bit#(1) rxp);

    (* result = "TXN_OUT_dummy0" *)
    method Bit#(1) txn_out_dummy0();

    (* result = "TXP_OUT_dummy0" *)
    method Bit#(1) txp_out_dummy0();

    method Action rxn_in_dummy1((* port="RXN_IN_dummy1" *) Bit#(1) rxn);
    method Action rxp_in_dummy1((* port="RXP_IN_dummy1" *) Bit#(1) rxp);

    (* result = "TXN_OUT_dummy1" *)
    method Bit#(1) txn_out_dummy1();

    (* result = "TXP_OUT_dummy1" *)
    method Bit#(1) txp_out_dummy1();

    method Action rxn_in_dummy2((* port="RXN_IN_dummy2" *) Bit#(1) rxn);
    method Action rxp_in_dummy2((* port="RXP_IN_dummy2" *) Bit#(1) rxp);

    (* result = "TXN_OUT_dummy2" *)
    method Bit#(1) txn_out_dummy2();

    (* result = "TXP_OUT_dummy2" *)
    method Bit#(1) txp_out_dummy2();
      
endinterface

// guarded interface
// Notice that we do a 4 to 1 vectorization here.  This is to exploit the high bandwidth of the link relative to our
// clock frequency.  Ideally, we would choose vectorization intelligently based on MODEL_CLOCK_FREQ and the link
// bandwidth, but I don't have time for that now, and making it a constant gets most of the performance. 
interface AURORA_DRIVER;
    method Action                 write(Bit#(63) tx_word); // txusrclk 
    method Bool                   write_ready(); // txusrclk 
    method Action                 deq(); // rxusrclk0     
    method Bit#(63)               first(); // rxusrclk0     


    // Debugging interface
    method Bit#(1) channel_up;
    method Bit#(1) lane_up;
    method Bit#(1) hard_err;
    method Bit#(1) soft_err;
    method Bit#(32) status;
    method Bit#(32) rx_count;
    method Bit#(32) tx_count;
    method Bit#(32) error_count;
    method UInt#(5) rx_fifo_count;
    method UInt#(5) tx_fifo_count;

endinterface

interface AURORA_DEVICE;
    (* prefix = "" *)      
    interface AURORA_WIRES wires;
    interface AURORA_DRIVER driver;
endinterface      

typedef 16 BufferSize;

module mkAuroraDevice#(Clock rawClock, Reset rawReset)
    // Interface:
    (AURORA_DEVICE);

    let ug_device <- mkAURORA_SINGLE_UG();

    // Repair the clock domain stuff down here...
    let aurora_rst <- mkAsyncReset(10, ug_device.aurora_rst, ug_device.aurora_clk);
    let clk <- exposeCurrentClock();
    let rst <- exposeCurrentReset();

    Bit#(16) handshakeWords[4] = {'hdead,'hbeef,'hcafe,'hfeed};

    Reg#(Bit#(16)) ccCycles  <- mkReg(maxBound, clocked_by(ug_device.aurora_clk), reset_by(aurora_rst)); 
    Reg#(Bit#(2)) handshakeRX <- mkReg(0, clocked_by(ug_device.aurora_clk), reset_by(aurora_rst)); 
    Reg#(Bit#(2)) handshakeTX <- mkReg(0, clocked_by(ug_device.aurora_clk), reset_by(aurora_rst)); 
    COUNTER#(TAdd#(1,TLog#(BufferSize))) txCredits   <- mkLCounter(fromInteger(valueof(BufferSize)), clocked_by(ug_device.aurora_clk), reset_by(aurora_rst)); 
    COUNTER#(TAdd#(1,TLog#(BufferSize))) rxCredits   <- mkLCounter(fromInteger(valueof(BufferSize)), clocked_by(ug_device.aurora_clk), reset_by(aurora_rst)); 
    Reg#(Bool) handshakeRXDone <- mkReg(False, clocked_by(ug_device.aurora_clk), reset_by(aurora_rst)); 
    Reg#(Bool) handshakeTXDone <- mkReg(False, clocked_by(ug_device.aurora_clk), reset_by(aurora_rst)); 
    Reg#(Bool) ccLast <- mkReg(False, clocked_by(ug_device.aurora_clk), reset_by(aurora_rst)); 

    SyncFIFOCountIfc#(Bit#(63),BufferSize) serdes_rxfifo <- mkSyncFIFOCount( ug_device.aurora_clk, aurora_rst, clk);
    SyncFIFOCountIfc#(Bit#(63),BufferSize) serdes_txfifo <- mkSyncFIFOCount( clk, rst, ug_device.aurora_clk);
    
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


    MARSHALLER#(Bit#(16), Bit#(64)) marshaller <- mkSimpleMarshaller(clocked_by(ug_device.aurora_clk), 
                                                                     reset_by(aurora_rst));

    rule tx (handshakeTXDone && txCredits.value > 0);
        marshaller.enq({1'b0,serdes_txfifo.first});
        serdes_txfifo.deq;
	txCredits.downBy(1);
    endrule

    // We stuffed BufferSize - rxCredits values into the fifo, and now there count values left.
    // We can send back BufferSize - rxCredits - count values safely.    
    let returnCount = fromInteger(valueof(BufferSize)) - rxCredits.value() - pack(serdes_rxfifo.sCount);
    let returnThreshold = fromInteger(valueof(BufferSize)) - 4;

    rule txFC(handshakeTXDone && ((returnCount > 0 && (!serdes_txfifo.dNotEmpty || txCredits.value == 0)) || returnCount > returnThreshold));
        rxCredits.upBy(returnCount);
        marshaller.enq({1'b1,zeroExtend(returnCount)});
    endrule

    rule txSend (handshakeTXDone);
        marshaller.deq;
        ug_device.send(marshaller.first);
    endrule

    DEMARSHALLER#(Bit#(16), Bit#(64)) demarshaller <- mkSimpleDemarshaller(clocked_by(ug_device.aurora_clk), 
                                                                           reset_by(aurora_rst));

    rule rxDemarsh (handshakeRXDone);  // We always need to receive.  Strong assumption that demarshaller has one element. 
        let data <- ug_device.receive;
        demarshaller.enq(data);
    endrule

    Bit#(1) flowcontrol = truncateLSB(demarshaller.first());

    rule rxDoneFC (handshakeRXDone && flowcontrol == 1);  // Strong assumption that demarshaller has one element. 
        demarshaller.deq;	
        txCredits.upBy(truncate(demarshaller.first()));
    endrule     

    rule rxDone (handshakeRXDone && flowcontrol == 0);  // Strong assumption that demarshaller has one element. 
        demarshaller.deq;
        rxCredits.downBy(1);
        serdes_rxfifo.enq(truncate(demarshaller.first()));
    endrule

    rule sendStats;
        ug_device.stats(?, handshakeRXDone, handshakeTXDone, ?, serdes_rxfifo.sNotEmpty, serdes_rxfifo.sNotFull);
    endrule
   
    interface AURORA_WIRES wires;
        method aurora_clk_n = ug_device.clk_n_in;
        method aurora_clk_p = ug_device.clk_p_in;
        method aurora_rxn_in = ug_device.rxn_in;
        method aurora_rxp_in = ug_device.rxp_in;
        method aurora_txn_out = ug_device.txn_out;
        method aurora_txp_out = ug_device.txp_out;

        method rxn_in_dummy0 = ug_device.rxn_in_dummy0;
        method rxp_in_dummy0 = ug_device.rxp_in_dummy0;
        method txn_out_dummy0 = ug_device.txn_out_dummy0;
        method txp_out_dummy0 = ug_device.txp_out_dummy0;

        method rxn_in_dummy1 = ug_device.rxn_in_dummy1;
        method rxp_in_dummy1 = ug_device.rxp_in_dummy1;
        method txn_out_dummy1 = ug_device.txn_out_dummy1;
        method txp_out_dummy1 = ug_device.txp_out_dummy1;

        method rxn_in_dummy2 = ug_device.rxn_in_dummy2;
        method rxp_in_dummy2 = ug_device.rxp_in_dummy2;
        method txn_out_dummy2 = ug_device.txn_out_dummy2;
        method txp_out_dummy2 = ug_device.txp_out_dummy2;

    endinterface
   
    interface AURORA_DRIVER driver;
        method write = serdes_txfifo.enq;

        method write_ready = serdes_txfifo.sNotFull();

        method deq = serdes_rxfifo.deq();

        method first = serdes_rxfifo.first();

        method channel_up = ug_device.channel_up;
        method lane_up = ug_device.lane_up;
        method hard_err = ug_device.hard_err;
        method soft_err = ug_device.soft_err;
 
        method status = ug_device.status;
        method rx_count = ug_device.rx_count;
        method tx_count = ug_device.tx_count;
        method error_count = ug_device.error_count;
        method rx_fifo_count = serdes_rxfifo.dCount;
        method tx_fifo_count = serdes_txfifo.sCount;
    endinterface
 
endmodule
