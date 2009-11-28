// The MIT License

// Copyright (c) 2009 Massachusetts Institute of Technology

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

// Author: Kermin Fleming kfleming@mit.edu


interface DDR_SDRAM_WIRES;
    //
    // wires from the mem controller to the DRAM device
    //
    
    (* always_ready *)
    method    Bit#(3)           ck_p;

    (* always_ready *)
    method    Bit#(3)           ck_n;
        
    (* always_ready *)
    method    Bit#(13)          a;
        
    (* always_ready *)
    method    Bit#(2)           ba;

    (* always_ready *)
    method    Bit#(1)           ras_n;

    (* always_ready *)
    method    Bit#(1)           cas_n;

    (* always_ready *)
    method    Bit#(1)           we_n;
        
    (* always_ready *)        
    method    Bit#(1)           cs_n;
        
    (* always_ready *)
    method    Bit#(1)           ce;

    (* always_ready *)
    method    Bit#(8)           dm;

    (* always_ready, always_enabled *)
    interface Inout#(Bit#(64))  dq;

    (* always_ready, always_enabled *)
    interface Inout#(Bit#(8))   dqs;

endinterface


// For now we use this typedef...
typedef NPIServer DDR_SDRAM_DRIVER;


//
// DDR_SDRAM_DEVICE --
//     By convention a device is both a driver and a wires interface.
//     Currently we use the original NPI Bluespec interface here, but 
//     this might change at some point.
//
interface DDR_SDRAM_DEVICE;
    interface DDR_SDRAM_DRIVER driver;
    interface DDR_SDRAM_WIRES  wires;
endinterface




// This device should be clocked at raw clock.  

module mkDDRSDRAMDevice#(Clock rawClock, Reset rawReset) (DDR_SDRAM_DEVICE);

  Clock systemClock <- exposeCurrentClock;
  Reset systemReset <- exposeCurrentReset;

  XILINX_MPMC_DDR_DRAM_CONTROLLER controller <- mkXilinxMPMCDDRDRAMController(clocked_by rawClock, reset_by rawReset);

  NPIMaster master <- mkNPIMaster(systemClock, systemReset, clocked_by controller.controller_clk, reset_by controller.controller_rst);

  rule driveAddrReq;
    controller.addrReq(master.npiMasterWires.addrReq());
  endrule

  rule driveMasteraddrAck;
    master.npiMasterWires.addrAck(controller.addrAck());
  endrule

  rule driveAddr;
    controller.addr(master.npiMasterWires.addr());
  endrule

  rule driveRNW;
    controller.rnw(master.npiMasterWires.rnw());
  endrule

  rule driveSize;
    controller.size(master.npiMasterWires.size());
  endrule

  rule driveRdModWr;
    controller.rdModWr(master.npiMasterWires.rdModWr());
  endrule

  rule driveMasterrdFIFO_Empty;
    master.npiMasterWires.rdFIFO_Empty(controller.rdFIFO_Empty());
  endrule

  rule driverdFIFO_Pop;
    controller.rdFIFO_Pop(master.npiMasterWires.rdFIFO_Pop());
  endrule

  rule driverdFIFO_Flush;
    controller.rdFIFO_Flush(master.npiMasterWires.rdFIFO_Flush());
  endrule

  rule driveMasterrdFIFO_Latency;
    master.npiMasterWires.rdFIFO_Latency(controller.rdFIFO_Latency());
  endrule

  rule driveMasterrdFIFO_Data;
    master.npiMasterWires.rdFIFO_Data(controller.rdFIFO_Data());
  endrule

  rule driveMasterrdFIFO_RdWdAddr;
    master.npiMasterWires.rdFIFO_RdWdAddr(controller.rdFIFO_RdWdAddr());
  endrule

  rule driveMasterwrFIFO_Empty;
    master.npiMasterWires.wrFIFO_Empty(controller.wrFIFO_Empty());
  endrule

  rule driveMasterwrFIFO_AlmostFull;
    master.npiMasterWires.wrFIFO_AlmostFull(controller.wrFIFO_AlmostFull());
  endrule

  rule drivewrFIFO_Push;
    controller.wrFIFO_Push(master.npiMasterWires.wrFIFO_Push());
  endrule

  rule drivewrFIFO_Flush;
    controller.wrFIFO_Flush(master.npiMasterWires.wrFIFO_Flush());
  endrule

  rule drivewrFIFO_Data;
    controller.wrFIFO_Data(master.npiMasterWires.wrFIFO_Data());
  endrule

  rule drivewrFIFO_BE;
    controller.wrFIFO_BE(master.npiMasterWires.wrFIFO_BE());
  endrule

  rule driveMasterinitDone;
    master.npiMasterWires.initDone(controller.initDone());
  endrule


  interface driver = master.npi_server; 

  interface DDR_SDRAM_WIRES wires;
    
    method  ck_p = controller.ck_p;

    method  ck_n = controller.ck_n;

    method  a = controller.a;

    method  ba = controller.ba;

    method  ras_n = controller.ras_n;

    method  cas_n = controller.cas_n;

    method  we_n = controller.we_n;

    method  cs_n = controller.cs_n;
        
    method  ce = controller.ce;

    method  dm = controller.dm;

    interface  dq = controller.dq;

    interface  dqs = controller.dqs;

  endinterface

endmodule