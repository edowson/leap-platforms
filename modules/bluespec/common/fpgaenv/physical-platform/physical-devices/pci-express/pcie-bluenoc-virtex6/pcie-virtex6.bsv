//
// Copyright (C) 2012 Intel Corporation
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

//
// Expose a Virtex-6 PCIe endpoint as a BlueNoC node.
//

import Clocks::*;
import GetPut::*;
import Connectable::*;
import DefaultValue::*;
import TieOff::*;
import ByteCompactor::*;
import MsgFormat::*;
import BlueNoC::*;
import XilinxCells::*;
import XilinxPCIE::*;

`include "awb/provides/pcie_bluenoc_ifc.bsh"
`include "awb/provides/pcie_bluenoc_device.bsh"


module mkPCIEBlueNoCDevice#(Clock sysClkBuf, Reset pciSysRstN)
    // Interface:
    (BNOC_PCIE_DEV#(n_BPB));

    // access clock and reset
    Clock fpga_clk  <- exposeCurrentClock();
    Reset fpga_rst  <- exposeCurrentReset();

    // Instantiate a PCIE endpoint
    PCIEParams pcie_params = defaultValue();
    PCIExpressV6#(8) ep <- mkPCIExpressEndpointV6(pcie_params,
                                                  clocked_by sysClkBuf,
                                                  reset_by pciSysRstN);

    // Extract the clocks and resets from the endpoint.
    Clock epClock250  = ep.trn.clk;
    Reset epReset250 <- mkAsyncReset(4, ep.trn.reset_n, epClock250);

    Clock epClock125  = ep.trn.clk2;
    Reset epReset125 <- mkAsyncReset(4, ep.trn.reset_n, epClock125);

    // Tie off some portions of the endpoint interface.
    mkTieOff(ep.cfg);
    mkTieOff(ep.cfg_err);
    mkTieOff(ep.pl);

    // Note our PCI ID
    PciId myID = PciId { bus:  ep.cfg.bus_number(),
                         dev:  ep.cfg.device_number(),
                         func: ep.cfg.function_number()
                       };

    // Extract some status info from the PCIE endpoint.  These values are
    // all in the epClock250 domain, so we have to cross them into the
    // epClock125 domain.
    UInt#(13) max_read_req_bytes_250       = 128 << ep.cfg.dcommand[14:12];
    UInt#(13) max_payload_bytes_250        = 128 << ep.cfg.dcommand[7:5];
    UInt#(8)  read_completion_boundary_250 = 64 << ep.cfg.lcommand[3];
    Bool      msix_enable_250              = (ep.cfg_interrupt.msixenable() == 1);
    Bool      msix_masked_250              = (ep.cfg_interrupt.msixfm()     == 1);

    CrossingReg#(UInt#(13)) max_rd_req_cr  <- mkNullCrossingReg(epClock125, 128,   clocked_by epClock250, reset_by epReset250);
    CrossingReg#(UInt#(13)) max_payload_cr <- mkNullCrossingReg(epClock125, 128,   clocked_by epClock250, reset_by epReset250);
    CrossingReg#(UInt#(8))  rcb_cr         <- mkNullCrossingReg(epClock125, 128,   clocked_by epClock250, reset_by epReset250);
    CrossingReg#(Bool)      msix_enable_cr <- mkNullCrossingReg(epClock125, False, clocked_by epClock250, reset_by epReset250);
    CrossingReg#(Bool)      msix_masked_cr <- mkNullCrossingReg(epClock125, True,  clocked_by epClock250, reset_by epReset250);

    Reg#(UInt#(13)) max_read_req_bytes <- mkReg(128,   clocked_by epClock125, reset_by epReset125);
    Reg#(UInt#(13)) max_payload_bytes  <- mkReg(128,   clocked_by epClock125, reset_by epReset125);
    Reg#(Bit#(7))   rcb_mask           <- mkReg(7'h3f, clocked_by epClock125, reset_by epReset125);
    Reg#(Bool)      msix_enable        <- mkReg(False, clocked_by epClock125, reset_by epReset125);
    Reg#(Bool)      msix_masked        <- mkReg(True,  clocked_by epClock125, reset_by epReset125);

    (* fire_when_enabled, no_implicit_conditions *)
    rule cross_config_values;
        max_rd_req_cr  <= max_read_req_bytes_250;
        max_payload_cr <= max_payload_bytes_250;
        rcb_cr         <= read_completion_boundary_250;
        msix_enable_cr <= msix_enable_250;
        msix_masked_cr <= msix_masked_250;
    endrule

    (* fire_when_enabled, no_implicit_conditions *)
    rule register_config_values;
        max_read_req_bytes <= max_rd_req_cr.crossed();
        max_payload_bytes  <= max_payload_cr.crossed();
        rcb_mask           <= (rcb_cr.crossed() == 64) ? 7'h3f : 7'h7f;
        msix_enable        <= msix_enable_cr.crossed();
        msix_masked        <= msix_masked_cr.crossed();
    endrule

    // monitor PCIe interrupt status (MSI-X only)
    CrossingReg#(Bool) intr_on <- mkNullCrossingReg(epClock125,
                                                    False,
                                                    clocked_by epClock250,
                                                    reset_by epReset250);

    // this rule executes in the epClock250 domain
    (* fire_when_enabled, no_implicit_conditions *)
    rule intr_ifc_ctl;
        ep.cfg_interrupt.di('0);        // tied off for MSI-X
        ep.cfg_interrupt.assert_n('1);  // tied off for MSI-X
        ep.cfg_interrupt.req_n(1);      // tied off for MSI-X
        intr_on <= (ep.cfg_interrupt.msienable()  == 0) &&
                   (ep.cfg_interrupt.msixenable() == 1) &&
                   (ep.cfg_interrupt.msixfm()     == 0);
    endrule: intr_ifc_ctl

    // This value is in the epClock125 domain and indicates that the
    // interrupt interface is properly configured to send interrupts.
    Bool intr_ok = intr_on.crossed();

    // Instantiate the TLP-to-BNoC bridge and connect the PCIe endpoint to it.
    PCIEtoBNoC#(PCIE_BYTES_PER_BEAT) bridge <-
        mkPCIEtoBNoC(64'hc001_1eaf_c0de_d00d,
                     myID,
                     max_read_req_bytes,
                     max_payload_bytes,
                     rcb_mask,
                     msix_enable,
                     msix_masked,
                     False, // use MSI-X, not MSI on the ML605
                     clocked_by epClock125, reset_by epReset125);

    // Connect the BlueNoC bridge to the PCIe device.
    mkConnectionWithClocks(ep.trn_rx, tpl_2(bridge.tlps),
                           epClock250, epReset250, epClock125, epReset125);
    mkConnectionWithClocks(tpl_1(bridge.tlps), ep.trn_tx,
                           epClock250, epReset250, epClock125, epReset125);


    // Create a reset for the NoC design which incorporates soft reset through
    // the bridge.
    MakeResetIfc soft_reset <- mkReset(4, True,
                                       epClock125, clocked_by epClock125,
                                       reset_by epReset125);

    (* fire_when_enabled, no_implicit_conditions *)
    rule do_soft_reset if (! bridge.is_activated());
        soft_reset.assertReset();
    endrule


    interface PCIE_DRIVER driver;
        interface MsgPort noc = bridge.noc;

        interface Clock clock = epClock125;
        interface Reset reset = soft_reset.new_rst;
    endinterface

    // FPGA pin interface
    interface PCIE_EXP pcie_exp = ep.pcie;
      
endmodule