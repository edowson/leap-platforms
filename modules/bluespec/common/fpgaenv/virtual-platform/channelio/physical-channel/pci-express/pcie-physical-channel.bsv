import FIFOF::*;

`include "hasim_common.bsh"
`include "physical_platform.bsh"
`include "pci_express_device.bsh"
`include "led_device.bsh"
`include "umf.bsh"

// types
typedef enum
{
    READ_STATE_ready,
    READ_STATE_busy_data,
    READ_STATE_busy_f2hHead,
    READ_STATE_busy_h2fTail,
    READ_STATE_dm
}
READ_STATE
    deriving (Bits, Eq);

// === DEBUG machine ===
typedef enum
{
    DMSTATE_ready,
    DMSTATE_doReadCSR,
    DMSTATE_doWriteCSR
}
DMSTATE
    deriving (Bits, Eq);

typedef Bit#(`PCIE_CSR_DATA_SIZE) CSR_DATA;
typedef Bit#(`PCIE_CSR_IDX_SIZE)  CSR_INDEX;

// ============== Physical Channel ===============

// interface
interface PhysicalChannel;
    method ActionValue#(UMF_CHUNK) read();
    method Action                  write(UMF_CHUNK chunk);
endinterface

// module
module mkPhysicalChannel#(PHYSICAL_DRIVERS drivers)
    // interface
        (PhysicalChannel);

    // ============= State ==============

    // buffers
    FIFOF#(CSR_DATA) readBuffer  <- mkFIFOF();
    FIFOF#(CSR_DATA) writeBuffer <- mkFIFOF();

    // states
    Reg#(READ_STATE) readState <- mkReg(READ_STATE_ready);
    Reg#(Bit#(4))    initStage <- mkReg(0);
    Reg#(Bool)       start     <- mkReg(False);

    // pointers
    Reg#(CSR_INDEX) f2hHead <- mkReg(`CSR_F2H_BUF_START);
    Reg#(CSR_INDEX) f2hTail <- mkReg(`CSR_F2H_BUF_START);
    Reg#(CSR_INDEX) h2fHead <- mkReg(`CSR_H2F_BUF_START);
    Reg#(CSR_INDEX) h2fTail <- mkReg(`CSR_H2F_BUF_START);

    // dirty/valid bits
    Reg#(Bool) h2fHeadDirty <- mkReg(False);
    Reg#(Bool) h2fTailValid <- mkReg(True);
    Reg#(Bool) f2hHeadValid <- mkReg(True);
    Reg#(Bool) f2hTailDirty <- mkReg(False);

    // =========== Helper Wires =========
    CSR_INDEX f2hHeadPlusOne = (f2hHead == `CSR_F2H_BUF_END) ? `CSR_F2H_BUF_START : (f2hHead + 1);
    CSR_INDEX f2hTailPlusOne = (f2hTail == `CSR_F2H_BUF_END) ? `CSR_F2H_BUF_START : (f2hTail + 1);
    CSR_INDEX h2fHeadPlusOne = (h2fHead == `CSR_H2F_BUF_END) ? `CSR_H2F_BUF_START : (h2fHead + 1);
    CSR_INDEX h2fTailPlusOne = (h2fTail == `CSR_H2F_BUF_END) ? `CSR_H2F_BUF_START : (h2fTail + 1);

    Bool f2hEmpty = (f2hHead == f2hTail);
    Bool f2hFull  = (f2hHead == f2hTailPlusOne);
    Bool h2fEmpty = (h2fHead == h2fTail);
    Bool h2fFull  = (h2fHead == h2fTailPlusOne);

    // ============== Rules =============

    // DEBUG regs
    Reg#(Bit#(32)) counter <- mkReg(0);

    Bit#(32) status_flags;
    Bit#(32) status_pointers;
    Bit#(32) status_vhdl;

    // status flags
    status_flags[0]  = h2fEmpty ? 1 : 0;
    status_flags[1]  = h2fFull  ? 1 : 0;
    status_flags[2]  = f2hEmpty ? 1 : 0;
    status_flags[3]  = f2hFull  ? 1 : 0;

    status_flags[4]  = h2fHeadDirty ? 1 : 0;
    status_flags[5]  = h2fTailValid ? 1 : 0;
    status_flags[6]  = f2hHeadValid ? 1 : 0;
    status_flags[7]  = f2hTailDirty ? 1 : 0;

    status_flags[8]  = readState == READ_STATE_ready        ? 1 : 0;
    status_flags[9]  = readState == READ_STATE_busy_h2fTail ? 1 : 0;
    status_flags[10] = readState == READ_STATE_busy_f2hHead ? 1 : 0;
    status_flags[11] = readState == READ_STATE_busy_data    ? 1 : 0;

    status_flags[12] = initStage[0];
    status_flags[13] = initStage[1];
    status_flags[14] = initStage[2];
    status_flags[15] = initStage[3];

    // status pointers
    status_pointers[7:0]   = f2hTail;
    status_pointers[15:8]  = f2hHead;
    status_pointers[23:16] = h2fTail;
    status_pointers[31:24] = h2fHead;

    // vhdl/synchronizer status
    status_vhdl[15:0] = drivers.pciExpressDriver.read_data()[15:0];

    status_vhdl[16] = drivers.pciExpressDriver.read_req_ready();
    status_vhdl[17] = drivers.pciExpressDriver.read_resp_ready();
    status_vhdl[18] = drivers.pciExpressDriver.write_ready();
    status_vhdl[19] = 0;

    status_vhdl[21:20] = drivers.pciExpressDriver.write_sync_depth_bsv();
    status_vhdl[23:22] = '0; // drivers.pciExpressDriver.write_sync_depth_vhdl();
    status_vhdl[27:24] = '0; // drivers.pciExpressDriver.write_sync_enq_count();
    status_vhdl[31:28] = '0; // drivers.pciExpressDriver.write_sync_deq_count();

    // === debugging state machine ===
    
    // 32-bit instruction format:
    //
    // field:   [IID]  [OPCODE]  [INDEX] [IMMEDIATE]
    // bits :   31-24   23-16     15-8      7-0
    //
    // opcode 00: NOP
    //        01: LEDs       := immediate
    //        02: LEDs       := CSR[index]
    //        03: CSR[index] := immediate
    //        04: LEDs       := status
    //        05: start
    //        06: invalidate h2fTail
    //        07: invalidate f2hHead
    //        08: CSR[sys]   := status (flags)
    //        09: CSR[sys]   := status (pointers)
    //        0A: CSR[sys]   := status (VHDL)

    Reg#(DMSTATE) dmstate <- mkReg(DMSTATE_ready);

    Reg#(Bit#(8)) lastIID <- mkReg(0);
    Reg#(Bit#(8)) leds    <- mkReg(0);
    Reg#(Bit#(8)) index   <- mkReg(7);
    Reg#(Bit#(8)) data    <- mkReg(0);

    // process a new instruction
    rule process_inst (dmstate == DMSTATE_ready);

        // read instruction
        PCIE_CSR_Data inst = drivers.pciExpressDriver.csr_h2f_reg0_read();

        // decode partially
        Bit#(8) iid    = inst[31:24];
        Bit#(8) opcode = inst[23:16];

        // make sure this is a new instruction
        if (iid != lastIID)
        begin

            lastIID <= iid;

            case (opcode)
                'h01   : leds <= inst[7:0];
                'h02   : begin
                             index   <= inst[15:8];
                             dmstate <= DMSTATE_doReadCSR;
                         end
                'h03   : begin
                             index   <= inst[15:8];
                             data    <= inst[7:0];
                             dmstate <= DMSTATE_doWriteCSR;
                         end
                'h04   : leds <= truncate(status_flags);
                'h05   : start <= True;
                'h06   : h2fTailValid <= False;
                'h07   : f2hHeadValid <= False;
                'h08   : drivers.pciExpressDriver.csr_f2h_reg0_write(status_flags);
                'h09   : drivers.pciExpressDriver.csr_f2h_reg0_write(status_pointers);
                'h0A   : drivers.pciExpressDriver.csr_f2h_reg0_write(status_vhdl);
                default: noAction;
            endcase

        end

    endrule

    // debug sm: leds := CSR[index]
    rule read_csr_req (dmstate == DMSTATE_doReadCSR && readState == READ_STATE_ready);
        drivers.pciExpressDriver.csr_read_req(index);
        readState <= READ_STATE_dm;
    endrule

    rule read_csr_resp (readState == READ_STATE_dm);
        PCIE_CSR_Data data <- drivers.pciExpressDriver.csr_read_resp();
        leds <= truncate(data);
        readState <= READ_STATE_ready;
        dmstate <= DMSTATE_ready;
    endrule

    // debug sm: CSR[index] := immediate
    rule write_csr (dmstate == DMSTATE_doWriteCSR && readState == READ_STATE_ready);
        drivers.pciExpressDriver.csr_write(index, zeroExtend(data));
        dmstate <= DMSTATE_ready;
    endrule

    // debug sm: set leds
    rule set_leds (True);
        drivers.ledsDriver.setLEDs(leds);
    endrule

    // === initialization stages ===

    // trigger initialization sequence
    rule init_stage0 (start && initStage == 0);
        initStage <= initStage + 1;
    endrule

    // stage 1: write indices that we control
    rule init_stage1 (initStage == 1 && readState == READ_STATE_ready);
        drivers.pciExpressDriver.csr_write(`CSR_F2H_TAIL, zeroExtend(f2hTail));
        initStage <= initStage + 1;
    endrule

    // stage 2: write indices that we control
    rule init_stage2 (initStage == 2 && readState == READ_STATE_ready);
        drivers.pciExpressDriver.csr_write(`CSR_H2F_HEAD, zeroExtend(h2fHead));
        initStage <= initStage + 1;
    endrule

    // stage 3: give green signal to software
    rule init_stage3 (initStage == 3);
        drivers.pciExpressDriver.csr_f2h_reg0_write(`SIGNAL_GREEN);
        initStage <= initStage + 1;
    endrule

    // === ready bit =============
    Bool ready = (initStage == 4);
    // ===========================

    // === pointer updates: READ ===

    // read f2hHead pointer
    rule make_f2hHead_read_req (ready && !f2hHeadValid && readState == READ_STATE_ready);
        drivers.pciExpressDriver.csr_read_req(`CSR_F2H_HEAD);
        readState <= READ_STATE_busy_f2hHead;
        f2hHeadValid <= True; // need this here, not at resp
    endrule

    // accept response for f2hHead request
    rule recv_f2hHead_read_resp (ready && readState == READ_STATE_busy_f2hHead);
        CSR_DATA data <- drivers.pciExpressDriver.csr_read_resp();
        f2hHead <= truncate(data);
        readState <= READ_STATE_ready;
    endrule

    // read h2fTail pointer
    rule make_h2fTail_read_req (ready && !h2fTailValid && readState == READ_STATE_ready);
        drivers.pciExpressDriver.csr_read_req(`CSR_H2F_TAIL);
        readState <= READ_STATE_busy_h2fTail;
        h2fTailValid <= True; // need this here, not at resp
    endrule

    // accept response for h2fTail request
    rule recv_h2fTail_read_resp (ready && readState == READ_STATE_busy_h2fTail);
        CSR_DATA data <- drivers.pciExpressDriver.csr_read_resp();
        h2fTail <= truncate(data);
        readState <= READ_STATE_ready;
    endrule

    // === pointer updates: WRITE ===

    // NOTE: all write rules are gated by READ_STATE_ready

    // write f2hTail state
    rule make_f2hTail_write_req (ready && f2hTailDirty && readState == READ_STATE_ready);
        drivers.pciExpressDriver.csr_write(`CSR_F2H_TAIL, zeroExtend(f2hTail));
        f2hTailDirty <= False;
    endrule

    // write h2fHead state
    rule make_h2fHead_write_req (ready && h2fHeadDirty && readState == READ_STATE_ready);
        drivers.pciExpressDriver.csr_write(`CSR_H2F_HEAD, zeroExtend(h2fHead));
        h2fHeadDirty <= False;
    endrule

    // === data ===

    // send data read request
    rule make_data_read_req (ready && !h2fEmpty && readState == READ_STATE_ready);
        drivers.pciExpressDriver.csr_read_req(h2fHead);
        readState <= READ_STATE_busy_data;
    endrule

    // receive read response from CSR
    rule recv_read_resp (ready && readState == READ_STATE_busy_data);
        CSR_DATA data <- drivers.pciExpressDriver.csr_read_resp();
        readBuffer.enq(data);

        // advance head
        h2fHead <= h2fHeadPlusOne;
        h2fHeadDirty <= True;

        readState <= READ_STATE_ready;
    endrule

    // send data write request
    rule make_data_write_req (ready && !f2hFull && readState == READ_STATE_ready);
        CSR_DATA data = writeBuffer.first();
        writeBuffer.deq();
        drivers.pciExpressDriver.csr_write(f2hTail, data);

        // advance tail
        f2hTail <= f2hTailPlusOne;
        f2hTailDirty <= True;
    endrule

    // ============= Methods =============

    // read
    method ActionValue#(UMF_CHUNK) read() if (ready);
        CSR_DATA data = readBuffer.first();
        readBuffer.deq();
        UMF_CHUNK chunk = truncate(data);
        return chunk;
    endmethod

    // write
    method Action write(UMF_CHUNK chunk) if (ready);
        CSR_DATA data = zeroExtend(chunk);
        writeBuffer.enq(data);
    endmethod

endmodule