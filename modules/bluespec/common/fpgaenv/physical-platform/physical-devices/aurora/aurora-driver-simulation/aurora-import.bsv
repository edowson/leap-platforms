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
import FIFO::*;
import LevelFIFO::*;
import Connectable::*;
import GetPut::*;
import Vector::*;
import XilinxCells  :: *;

`include "awb/provides/ml605_aurora_device.bsh" 
`include "awb/provides/fpga_components.bsh"

interface AURORA_WIRES;
	method Action aurora_clk_n((* port="AURORA_GTXQ_IN" *) Bit#(1) clk_n);
	method Action aurora_clk_p((* port="AURORA_GTXQ_IN" *) Bit#(1) clk_p);

//	method Action gtxq_p();
//	method Action gtxq_n();

	method Action rxp_in(Bit#(1) i);
	method Action rxn_in(Bit#(1) i);
	method Bit#(1) txp_out();
	method Bit#(1) txn_out();
	interface Clock aurora_clk;
endinterface

interface AURORA_DRIVER;
	method ActionValue#(Bit#(16)) read;
	method Action write(Bit#(16) d);
    
		// Debugging interface
    method Bit#(1)  channel_up;
    method Bit#(1)  lane_up;
    method Bit#(1)  hard_err;
    method Bit#(1)  soft_err;
    method Bool     cc;
    method Bit#(32) status;
    method Bit#(32) rx_count;
    method Bit#(32) tx_count;
    method Bit#(32) error_count;
    method UInt#(5) rx_fifo_count;
    method UInt#(5) tx_fifo_count;
endinterface

interface AURORA_DEVICE;
    interface AURORA_WIRES wires;
    interface AURORA_DRIVER driver;
endinterface      

module mkAuroraDevice#(Clock rawClock, Reset rawReset)
    // Interface:
    (AURORA_DEVICE);

	let clk <- exposeCurrentClock();
	let rst <- exposeCurrentReset();


	Reg#(Bit#(32)) rx_fifo_count_r <- mkReg(0);
	Reg#(Bit#(32)) tx_fifo_count_r <- mkReg(0);

	let ug_device <- mkAURORA_SINGLE_UG(rawClock, rawReset);
	let aurora_clk = ug_device.aurora_clk;
	let aurora_rst = ug_device.aurora_rst;
	// 930 is norm <- _rst_n is asserted. _rst is not.
    
	SyncFIFOCountIfc#(Bit#(16),8) serdes_rxfifo <- mkSyncFIFOCount( aurora_clk, aurora_rst, clk);
	SyncFIFOCountIfc#(Bit#(16),8) serdes_txfifo <- mkSyncFIFOCount( clk, rst, aurora_clk);
	
	Reg#(Bit#(32)) rx_count_r <- mkReg(0, clocked_by aurora_clk, reset_by aurora_rst);
	Reg#(Bit#(32)) tx_count_r <- mkReg(0, clocked_by aurora_clk, reset_by aurora_rst);
	ReadOnly#(Bit#(32)) txCrossing <- mkNullCrossingWire(clk,tx_count_r, clocked_by aurora_clk, reset_by ug_device.aurora_rst);
	rule tx_move;
		ug_device.tx_data_out(serdes_txfifo.first());
		serdes_txfifo.deq();
		tx_count_r <= tx_count_r + 1;
	endrule
	rule rx_move;
		let rx_value <- ug_device.rx_data_in();
		serdes_rxfifo.enq(rx_value);
		rx_count_r <= rx_count_r + 1;
	endrule

/*
	ReadOnly#(Bool) resetAssertedCast <- isResetAsserted(clocked_by aurora_clk, reset_by ug_device.aurora_rst);
	ReadOnly#(Bool) resetAssertedCastN <- isResetAsserted(clocked_by aurora_clk, reset_by ug_device.aurora_rst_n);
//	pack(resetAssertedCast._read());
	 ReadOnly#(Bool) resetCrossing <- mkNullCrossingWire(clk,resetAssertedCast._read, clocked_by aurora_clk, reset_by ug_device.aurora_rst);
	 ReadOnly#(Bool) resetCrossing2 <- mkNullCrossingWire(clk,resetAssertedCast._read, clocked_by aurora_clk, reset_by ug_device.aurora_rst_n);
	 ReadOnly#(Bool) resetCrossingN <- mkNullCrossingWire(clk,resetAssertedCastN._read, clocked_by aurora_clk, reset_by ug_device.aurora_rst);
	 ReadOnly#(Bool) resetCrossingN2 <- mkNullCrossingWire(clk,resetAssertedCastN._read, clocked_by aurora_clk, reset_by ug_device.aurora_rst_n);
*/
	Reg#(Bit#(32)) debugint <- mkReg(0);
	FIFOF#(Bit#(16)) debugfifo <- mkFIFOF();
	rule debug_loop;
		if ( debugint >= 1024 * 1024*32 ) begin
			let debugv = { 
			tx_fifo_count_r[7:0],
			4'b0000,
			
			{ug_device.channel_up,
		ug_device.lane_up,
		ug_device.hard_err,
		ug_device.soft_err}};

			debugfifo.enq(debugv);
			debugint <= 0;
		end
		else begin
			debugint <= debugint + 1;
		end
	endrule
	
	/*
	Reg#(Bit#(32)) aurcnt <- mkReg(0, clocked_by aurora_clk, reset_by aurora_rst);
	rule aurcnt_rule;
		if ( aurcnt > 1024 * 1024 * 32 ) begin
			serdes_rxfifo.enq(16'hbeef);
			aurcnt <= 0;
		end else begin
			aurcnt <= aurcnt + 1;
		end
	endrule
	*/
/*
	let sys_rst <- mkAsyncReset(4, rst, sys_clk_buf);
	Reg#(Bit#(32)) aurcnt <- mkReg(0, clocked_by sys_clk_buf, reset_by sys_rst);
	SyncFIFOCountIfc#(Bit#(16),8) serdes_systorxfifo <- mkSyncFIFOCount( sys_clk_buf, sys_rst, clk);
	rule aurcnt_rule;
		if ( aurcnt > 1024 * 1024 ) begin
			serdes_systorxfifo.enq(16'hbeef);
			aurcnt <= 0;
		end else begin
			aurcnt <= aurcnt + 1;
		end
	endrule
	rule mvtodeeeee;
		debugfifo.enq(serdes_systorxfifo.first());
		serdes_systorxfifo.deq();
	endrule
*/


	interface AURORA_DRIVER driver;
	/*
		method ActionValue#(Bit#(16)) read(); // = ug_device.rx_data_in;
			return 88;
		endmethod
		method Action write(Bit#(16) d);// = ug_device.tx_data_out;
			noAction;
		endmethod

		method Bit#(1) channel_up();
			return 0;
		endmethod
		method Bit#(1) lane_up() ;
			return 0;
		endmethod
		method Bit#(1) hard_err();
			return 0;
		endmethod
		method Bit#(1) soft_err();
			return 0;
		endmethod
		*/

		method ActionValue#(Bit#(16)) read(); // = ug_device.rx_data_in;
			let rv = debugfifo.first();
			if ( !debugfifo.notEmpty() ) begin
				serdes_rxfifo.deq();
				rv = serdes_rxfifo.first();
				rx_fifo_count_r <= rx_fifo_count_r + 1;
			end else begin
				debugfifo.deq();
			end
			return rv;
		endmethod
		method Action write(Bit#(16) d);// = ug_device.tx_data_out;
			tx_fifo_count_r <= tx_fifo_count_r + 1;
			serdes_txfifo.enq(d);
		endmethod

		method channel_up = ug_device.channel_up;
		method lane_up = ug_device.lane_up;
		method hard_err = ug_device.hard_err;
		method soft_err = ug_device.soft_err;

		method Bit#(32) status(); //= ug_device.status;
			return  0;//zeroExtend(0);
		endmethod
		method Bit#(32) rx_count(); //= ug_device.rx_count;
			return 0;//zeroExtend(0);
		endmethod
		method Bit#(32) tx_count(); //= ug_device.tx_count;
			return 0;//zeroExtend(0);
		endmethod
		method Bit#(32) error_count(); //= ug_device.error_count;
			return 0;//zeroExtend(0);
		endmethod
		method UInt#(5) rx_fifo_count();
			return 0;//zeroExtend(0);
		endmethod
		method UInt#(5) tx_fifo_count();
			return 0;//zeroExtend(0);
		endmethod

	endinterface
endmodule



/*























*/
