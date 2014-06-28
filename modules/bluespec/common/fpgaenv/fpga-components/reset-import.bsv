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
// Two methods of importing reset.  Both accomplish the same thing, but
// use different interfaces.  The "put" version is newer and has the
// advantage of being always enabled, which eliminates the exposed
// ready wire at the top level.
//

interface RESET_FROM_PUT;
    // Incoming reset
    interface Put#(Bit#(1)) reset_wire;

    // Reset exposed to the model
    interface Reset reset;
endinterface

//
// mkResetFromPut --
//   Construct a reset using a put interface.  The interface also provides
//   a fictitious clock crossing, since that is typically needed to
//   convince Bluespec that the reset is in the domain of a generated
//   clock.
//
import "BVI" reset_import = module mkResetFromPut#(Clock dClock)
    // Interface:
    (RESET_FROM_PUT);

    default_reset no_reset;
    input_clock ddClock() = dClock;

    output_reset reset(reset_out) clocked_by(ddClock);

    interface Put reset_wire;
        method put(reset_in) enable(en0);
    endinterface

    schedule reset_wire_put CF reset_wire_put;
endmodule



interface RESET_IMPORTER;
    method Action reset_wire();
        
    interface Reset reset;
endinterface

import "BVI" reset_import = module mkResetImporter
    // Interface:
    (RESET_IMPORTER);

    default_reset no_reset;

    output_reset reset(reset_out);

    method reset_wire() enable(reset_in) clocked_by(no_clock);

    schedule reset_wire CF reset_wire;
endmodule
