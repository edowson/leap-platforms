interface PCIE_BURY;

    // Wires to be sent to the top level

    (* always_enabled, always_ready *)
    method Action rxn_wire(Bit#(8) i);
    (* always_enabled, always_ready *)
    method Action rxp_wire(Bit#(8) i);
    method    Bit#(8) txp_wire;
    method    Bit#(8) txn_wire;
//    method    Bit#(1) pin_wire;

    (* always_enabled, always_ready *)
    method Bit#(8) rxn_bsv();
    (* always_enabled, always_ready *)
    method Bit#(8) rxp_bsv();
    (* always_enabled, always_ready *)
    method Action txp_bsv(Bit#(8) i);
    (* always_enabled, always_ready *)
    method Action txn_bsv(Bit#(8) i);

    interface Clock clock;
endinterface

import "BVI" pcie_bury = module mkPCIE_BURY
    // interface:
                 (PCIE_BURY);
    //default_clock no_clock;
    //default_reset no_reset;
  
    output_clock clock(CLK_OUT); 

    method rxn_wire(rxn_in)  enable((*inhigh*)en0) reset_by(no_reset) clocked_by(clock);
    method rxp_wire(rxp_in)  enable((*inhigh*)en1) reset_by(no_reset) clocked_by(clock);
    method txp_out txp_wire   reset_by(no_reset) clocked_by(clock);
    method txn_out txn_wire   reset_by(no_reset) clocked_by(clock);
//    method pin_out pin_wire   reset_by(no_reset) clocked_by(no_clock);
 

    method rxn_out rxn_bsv();
    method rxp_out rxp_bsv();
    method txp_bsv(txp_in) enable((*inhigh*)en2);
    method txn_bsv(txn_in) enable((*inhigh*)en3);   
   
    schedule (txp_bsv,txn_bsv,rxp_bsv,rxn_bsv, //pin_wire,
              txp_wire,txn_wire,rxp_wire,rxn_wire) CF 
              (txp_bsv,txn_bsv,rxp_bsv,rxn_bsv, //pin_wire,
              txp_wire,txn_wire,rxp_wire,rxn_wire);

endmodule
