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

//
// Author: Michael Adler
//

`include "awb/provides/librl_bsv_base.bsh"


//
// LUT-based storage that compiles more effeciently than a vector in a register.
//
// Ideally this module wouldn't exist and we would use RegFile directly.
// Unfortunately, some instances of RegFiles don't synthesize correctly using
// Xilinx tools.  The code here provides a single RegFile-style interface and
// constructor for LUT-based storage and uses the most efficient storage that
// works, given the size request.
//

import RegFile::*;
import Vector::*;
import GetPut::*;

interface LUTRAM#(type t_ADDR, type t_DATA);
    method Action upd(t_ADDR addr, t_DATA d);
    method t_DATA sub(t_ADDR addr);

    // For initialized storage, reinvokes the initialization method.
    method Action reset();
endinterface: LUTRAM

//
// Internal only --
//   RegFile version of mkLUTRAMU.  Uses LUT registers for storage.
//
module mkLUTRAMU_RegFile
    // interface:
        (LUTRAM#(t_ADDR, t_DATA))
    provisos(Bits#(t_DATA, t_DATA_SZ),
             Bits#(t_ADDR, t_ADDR_SZ),
             Bounded#(t_ADDR));

    RegFile#(t_ADDR, t_DATA) mem <- mkRegFileWCF(minBound, maxBound);

    //
    // Access methods
    //
    method Action upd(t_ADDR addr, t_DATA d) = mem.upd(addr, d);
    method t_DATA sub(t_ADDR addr) = mem.sub(addr);

    method Action reset();
        noAction;
    endmethod
endmodule


//
// Internal only --
//   LUTRAMU_Async is used when LUT registers don't work due to bugs.
//
//   Xilinx Xst seems to have bugs with Verilog registers that look almost like
//   block RAM but have readers needing results in the same cycle.  Before
//   Virtex-7 this never happened when the data size was only 1 bit.  On
//   Virtex-7 we now see the bug (using Xst) even in 1-bit data structures.
//
//   The failed Xst inference seems to happen only when the index source is a
//   register.  This function inverts the low bit of the index, guaranteeing
//   that the index source is logic.
//
module mkLUTRAMU_Async
    // interface:
        (LUTRAM#(t_ADDR, t_DATA))
    provisos(Bits#(t_DATA, t_DATA_SZ),
             Bits#(t_ADDR, t_ADDR_SZ),
             Bounded#(t_ADDR));

    RegFile#(t_ADDR, t_DATA) mem <- mkRegFileWCF(minBound, maxBound);

    function tweakAddr(t_ADDR addr);
        let t = pack(addr);
        t[0] = t[0] ^ 1;
        return unpack(t);
    endfunction

    method Action upd(t_ADDR addr, t_DATA d) = mem.upd(tweakAddr(addr), d);
    method t_DATA sub(t_ADDR addr) = mem.sub(tweakAddr(addr));

    method Action reset();
        noAction;
    endmethod
endmodule


//
// mkLUTRAMU -- pick either the hardware or the simulated version of LUTRAMU.
//
module mkLUTRAMU
    // interface:
        (LUTRAM#(t_ADDR, t_DATA))
    provisos(Bits#(t_DATA, t_DATA_SZ),
             Bits#(t_ADDR, t_ADDR_SZ),
             Bounded#(t_ADDR));

    LUTRAM#(t_ADDR, t_DATA) mem;

    //
    // RegFile and Async versions have the same timing, so we always use the
    // RegFile version for simulation since it compiles more quickly.
    //

    Bool use_regfile = True;

    `ifndef SYNTH_Z
    if (`BROKEN_REGFILE != 0)
    begin
        // There is a bug in some versions of Xilinx.  See the comment
        // on mkLUTRAMU_Async().
        use_regfile = False;
    end
    `endif

    mem <- use_regfile ? mkLUTRAMU_RegFile() : mkLUTRAMU_Async();

    return mem;

endmodule


//
// LUTRAM Initialized with a function :: idx -> data
//
module mkLUTRAMWith#(function t_DATA initfunc(t_ADDR idx))
    // interface:
        (LUTRAM#(t_ADDR, t_DATA))
    provisos(Bits#(t_DATA, t_DATA_SZ),
             Bits#(t_ADDR, t_ADDR_SZ),
             Bounded#(t_ADDR));

    LUTRAM#(t_ADDR, t_DATA) mem <- mkLUTRAMU();

    //
    // Initialize storage
    //

    Reg#(Bool) initialized_m <- mkReg(False);
    Reg#(t_ADDR) init_idx <- mkReg(minBound);
    Wire#(Tuple2#(t_ADDR, t_DATA)) writeW <- mkWire();
    PulseWire triggerReset <- mkPulseWire();

    rule initializing (! initialized_m && ! triggerReset);
        mem.upd(init_idx, initfunc(init_idx));

        // Hack to avoid needing Eq proviso for comparison
        t_ADDR max = maxBound;
        initialized_m <= (pack(init_idx) == pack(max));

        // Hack to avoid needing Arith proviso
        init_idx <= unpack(pack(init_idx) + 1);
    endrule

    (* fire_when_enabled, no_implicit_conditions *)
    (* descending_urgency = "newReset, initializing" *)
    rule newReset (triggerReset);
        init_idx <= minBound;
        initialized_m <= False;
    endrule

    
    (* fire_when_enabled *)
    rule doWrite (initialized_m && ! triggerReset);
        match {.addr, .d} = writeW;
        mem.upd(addr, d);
    endrule


    //
    // Access methods
    //

    method Action upd(t_ADDR addr, t_DATA d) if (initialized_m);
        // The Bluesec scheduler is having a really hard time with the
        // conflicting updates.  In order to make its life easier we use
        // a wire and clearly ME rules.
        writeW <= tuple2(addr, d);
    endmethod

    method t_DATA sub(t_ADDR addr) if (initialized_m);
        return mem.sub(addr);
    endmethod

    method Action reset() if (initialized_m);
        triggerReset.send();
    endmethod
endmodule


//
// LUTRAM Initialized with a Get source.  If the LUTRAM reset() is triggered
// the Get source must provide the full initialization again.
//
// initFunc returns a stream of initialization values, followed by a single
// Invalid to indicate the end of the stream.  The module can cope with
// streams shorter than the size of memory (initializes the rest with 0)
// and streams longer than the size of memory (consumes the full stream
// and drops extra entries.)
//
// This is identical to mkLUTRAMWith except for initialization.
//
module mkLUTRAMWithGet#(function Get#(Maybe#(t_DATA)) initFunc)
    // interface:
        (LUTRAM#(t_ADDR, t_DATA))
    provisos(Bits#(t_DATA, t_DATA_SZ),
             Bits#(t_ADDR, t_ADDR_SZ),
             Bounded#(t_ADDR));

    LUTRAM#(t_ADDR, t_DATA) mem <- mkLUTRAMU();

    Wire#(Tuple2#(t_ADDR, t_DATA)) writeW <- mkWire();
    PulseWire triggerReset <- mkPulseWire();

    // Are we initializing?
    Reg#(Bool) initialized_m <- mkReg(False);
    Reg#(Bool) finishInit <- mkReg(False);
    Reg#(Bool) sinkInit <- mkReg(False);
    Reg#(Bit#(t_ADDR_SZ)) init_idx <- mkReg(0);

    // initializing --
    //     When:   After a reset until every value is initialized.
    //     Effect: Update the RAM with the user-provided initial value.
    //
    rule initializing (! initialized_m && ! finishInit);
        let m_val <- initFunc.get;

        if (m_val matches tagged Valid .v)
        begin
            t_ADDR init_idx_a = unpack(init_idx);
            mem.upd(init_idx_a, v);

            if (init_idx == maxBound)
            begin
                initialized_m <= True;
                sinkInit <= True;
            end

            init_idx <= init_idx + 1;
        end
        else
        begin
            finishInit <= True;
        end
    endrule

    //
    // zeroRemainder --
    //     If init stream ends before the full memory is initialized then
    //     complete initialization by writing 0 to the remainder.
    //
    rule zeroRemainder (! initialized_m && finishInit);
        t_ADDR init_idx_a = unpack(init_idx);
        mem.upd(init_idx_a, unpack(0));

        if (init_idx == maxBound)
        begin
            initialized_m <= True;
            finishInit <= False;
        end

        init_idx <= init_idx + 1;
    endrule

    //
    // Sink any remaining initialization data, which is beyond the address
    // space.
    //
    rule sink (initialized_m && sinkInit);
        let m_val <- initFunc.get;
        sinkInit <= ! isValid(m_val);
    endrule


    (* fire_when_enabled, no_implicit_conditions *)
    (* descending_urgency = "newReset, initializing" *)
    rule newReset (triggerReset);
        initialized_m <= False;
        finishInit <= False;
        sinkInit <= False;
        init_idx <= 0;
    endrule

    
    (* fire_when_enabled *)
    rule doWrite (initialized_m && ! triggerReset);
        match {.addr, .d} = writeW;
        mem.upd(addr, d);
    endrule


    //
    // Access methods
    //

    method Action upd(t_ADDR addr, t_DATA d) if (initialized_m);
        // The Bluesec scheduler is having a really hard time with the
        // conflicting updates.  In order to make its life easier we use
        // a wire and clearly ME rules.
        writeW <= tuple2(addr, d);
    endmethod

    method t_DATA sub(t_ADDR addr) if (initialized_m);
        return mem.sub(addr);
    endmethod

    method Action reset() if (initialized_m);
        triggerReset.send();
    endmethod
endmodule


//
// Initialized LUTRAM
//
module mkLUTRAM#(t_DATA init)
    // interface:
        (LUTRAM#(t_ADDR, t_DATA))
    provisos(Bits#(t_DATA, t_DATA_SZ),
             Bits#(t_ADDR, t_ADDR_SZ),
             Bounded#(t_ADDR));


    // A dummy function which returns the same value for any index.
    function t_DATA const_func(t_ADDR idx);
        return init;
    endfunction

    LUTRAM#(t_ADDR, t_DATA) mem <- mkLUTRAMWith(const_func);

    return mem;

endmodule


// ========================================================================
//
// Convert LUTRAM interface to MEMORY_IFC for replacing a block RAM.
//
// ========================================================================

module mkLUTRAMIfcToMemIfc#(LUTRAM#(t_ADDR, t_DATA) lutram)
    // Interface:
    (MEMORY_IFC#(t_ADDR, t_DATA))
    provisos(Bits#(t_DATA, t_DATA_SZ),
             Bits#(t_ADDR, t_ADDR_SZ),
             Bounded#(t_ADDR));

    FIFOF#(t_DATA) readQ <- mkFIFOF();

    method Action readReq(t_ADDR addr);
        let v = lutram.sub(addr);
        readQ.enq(v);
    endmethod

    method ActionValue#(t_DATA) readRsp();
        let v = readQ.first();
        readQ.deq();
        return v;
    endmethod

    method t_DATA peek = readQ.first;
    method Bool notEmpty = readQ.notEmpty;
    method Bool notFull = readQ.notFull;

    method Action write(t_ADDR addr, t_DATA val) = lutram.upd(addr, val);
    method Bool writeNotFull() = True;
endmodule


// ========================================================================
//
// Multi-read-port LUTRAM.  Unlike RegFile, which has up to 5 compiler-
// managed read ports, the LUTRAM_MULTI_READ has user-managed read
// ports.  Unlike the compiler-managed RegFile, in which every instance
// of a reader is allocated a unique port, the user-managed implementation
// allows for sharing of read ports among non-conflicting rules.  Xilinx
// LUT usage increases linearly with the number of ports, so this can
// be a significant space savings.
//
// ========================================================================


// Read port interface (internal)
interface LUTRAM_READER_IFC#(type t_ADDR, type t_DATA);
    method t_DATA sub(t_ADDR addr);
endinterface: LUTRAM_READER_IFC

//
// Multi-reader interface.
//
interface LUTRAM_MULTI_READ#(numeric type n_READERS, type t_ADDR, type t_DATA);
    method Action upd(t_ADDR addr, t_DATA d);
    interface Vector#(n_READERS, LUTRAM_READER_IFC#(t_ADDR, t_DATA)) readPorts;

    // For initialized storage, reinvokes the initialization method.
    method Action reset();
endinterface: LUTRAM_MULTI_READ


//
// mkLUTRAMUSinglePort --
//     Wrapper for Verilog implementation of a dual ported LUT memory with
//     one reader and one writer.
//
import "BVI" LUTRAMUDualPort = module mkLUTRAMUDualPort
    // interface:
    (LUTRAM#(Bit#(t_ADDR_SZ), Bit#(t_DATA_SZ)));

    parameter addr_width = valueOf(t_ADDR_SZ);
    parameter data_width = valueOf(t_DATA_SZ);
    parameter lo = 0;
    parameter hi = valueOf(TSub#(TExp#(t_ADDR_SZ), 1));

    default_reset rst (RST_N);
    default_clock clk (CLK);

    method D_OUT_1 sub(ADDR_1);
    method upd(ADDR_IN, D_IN) enable(WE);
    method reset() enable (USER_RST);

    schedule upd C upd;
    schedule sub C sub;
    schedule upd CF sub;

    schedule reset C reset;
    schedule reset CF (sub, upd);
endmodule


//
// mkMultiReadLUTRAMU -- pick either the hardware or the simulated version
//     of a multi-reader LUTRAMU.
//
//     Note:  the simulator version uses a separate RegFile for each read
//     port.  This limits the number of unique readers of each port to 5.
//     The hardware version has no limit.
//
module mkMultiReadLUTRAMU
    // interface:
    (LUTRAM_MULTI_READ#(n_READERS, t_ADDR, t_DATA))
    provisos(Bits#(t_DATA, t_DATA_SZ),
             Bits#(t_ADDR, t_ADDR_SZ),
             Bounded#(t_ADDR));

    // Multiple ports are implemented by allocating a vector of memories, one
    // for each port.  This is basically what the hardware does, so there isn't
    // much cost.  At the cost of complexity here, it might be a good idea to
    // detect read ports in groups of 3 and add a quad-port version of the
    // Verilog primitive.  Quad port has 3 read ports per write port.
    Vector#(n_READERS, LUTRAM#(Bit#(t_ADDR_SZ), Bit#(t_DATA_SZ))) mem = newVector();

    //
    // RegFile and Async versions have the same timing, so we always use the
    // RegFile version for simulation since it compiles more quickly.
    //

    Bool use_regfile = True;
    `ifndef SYNTH_Z
        use_regfile = False;
    `endif

    for (Integer p = 0; p < valueOf(n_READERS); p = p + 1)
    begin
        mem[p] <- use_regfile ? mkLUTRAMU_RegFile() : mkLUTRAMUDualPort();
    end

    Vector#(n_READERS, LUTRAM_READER_IFC#(t_ADDR, t_DATA)) portsLocal = newVector();
    for (Integer p = 0; p < valueOf(n_READERS); p = p + 1)
    begin
        portsLocal[p] =
            interface LUTRAM_READER_IFC#(t_ADDR, t_DATA);
                method t_DATA sub(t_ADDR addr);
                    return unpack(mem[p].sub(pack(addr)));
                endmethod
            endinterface;
    end

    method Action upd(t_ADDR addr, t_DATA d);
        // Update writes all the ports
        for (Integer p = 0; p < valueOf(n_READERS); p = p + 1)
        begin
            mem[p].upd(pack(addr), pack(d));
        end
    endmethod

    interface readPorts = portsLocal;

    method Action reset();
        noAction;
    endmethod
endmodule




//
// LUTRAM Initialized with a function :: idx -> data
//
module mkMultiReadLUTRAMWith#(function t_DATA initFunc(t_ADDR idx))
    // interface:
    (LUTRAM_MULTI_READ#(n_READERS, t_ADDR, t_DATA))
    provisos(Bits#(t_DATA, t_DATA_SZ),
             Bits#(t_ADDR, t_ADDR_SZ),
             Bounded#(t_ADDR));

    LUTRAM_MULTI_READ#(n_READERS, t_ADDR, t_DATA) mem <- mkMultiReadLUTRAMU();

    //
    // Initialize storage
    //

    Reg#(Bool) initialized_m <- mkReg(False);
    Reg#(t_ADDR) init_idx <- mkReg(minBound);

    rule initializing (! initialized_m);
        mem.upd(init_idx, initFunc(init_idx));

        // Hack to avoid needing Eq proviso for comparison
        t_ADDR max = maxBound;
        initialized_m <= (pack(init_idx) == pack(max));

        // Hack to avoid needing Arith proviso
        init_idx <= unpack(pack(init_idx) + 1);
    endrule


    //
    // Access methods
    //

    Vector#(n_READERS, LUTRAM_READER_IFC#(t_ADDR, t_DATA)) portsLocal = newVector();
    for (Integer p = 0; p < valueOf(n_READERS); p = p + 1)
    begin
        portsLocal[p] =
            interface LUTRAM_READER_IFC#(t_ADDR, t_DATA);
                method t_DATA sub(t_ADDR addr) if (initialized_m);
                    return mem.readPorts[p].sub(addr);
                endmethod
            endinterface;
    end

    method Action upd(t_ADDR addr, t_DATA d) if (initialized_m);
        mem.upd(addr, d);
    endmethod

    interface readPorts = portsLocal;

    method Action reset() if (initialized_m);
        init_idx <= minBound;
        initialized_m <= False;
    endmethod
endmodule


//
// Initialized LUTRAM
//
module mkMultiReadLUTRAM#(t_DATA init)
    // interface:
    (LUTRAM_MULTI_READ#(n_READERS, t_ADDR, t_DATA))
    provisos(Bits#(t_DATA, t_DATA_SZ),
             Bits#(t_ADDR, t_ADDR_SZ),
             Bounded#(t_ADDR));

    // A dummy function which returns the same value for any index.
    function t_DATA const_func(t_ADDR idx);
        return init;
    endfunction

    LUTRAM_MULTI_READ#(n_READERS, t_ADDR, t_DATA) mem <-
        mkMultiReadLUTRAMWith(const_func);

    return mem;
endmodule
