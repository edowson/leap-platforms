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

// Primitive Single-Ended Clock: Simply convert the top-level wires
// into a clock and reset signal

import Clocks::*;

interface PRIMITIVE_CLOCKS_DEVICE;

    // Wires to be sent to the top level

    method Action clock_wire();
    method Action reset_n_wire();

    // Drivers exposed to the model

    interface Clock clock;
    interface Reset reset;

endinterface

import "BVI" single_ended_clocks_device = module mkPrimitiveClocksDevice
    // interface:
                 (PRIMITIVE_CLOCKS_DEVICE);

    parameter RESET_ACTIVE_HIGH = `RESET_ACTIVE_HIGH;

    default_clock no_clock;
    default_reset no_reset;

    output_clock clock(clk_out);
    output_reset reset(rst_n_out) clocked_by(clock);

    method clock_wire() enable(clk);
    method reset_n_wire() enable(rst_n);

    schedule (clock_wire, reset_n_wire) CF (clock_wire, reset_n_wire);    

endmodule
