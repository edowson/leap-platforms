`include "asim/provides/virtual_platform.bsh"
`include "asim/provides/virtual_devices.bsh"
`include "asim/provides/physical_platform.bsh"
`include "asim/provides/jtag_device.bsh"
`include "asim/provides/low_level_platform_interface.bsh"

`include "asim/rrr/service_ids.bsh"
`include "asim/rrr/server_stub_JTAGDEBUG.bsh"
`include "asim/rrr/client_stub_JTAGDEBUG.bsh"


// mkApplication

module mkApplication#(VIRTUAL_PLATFORM vp)();

    LowLevelPlatformInterface llpi = vp.llpint;
    
    // instantiate stubs
    ServerStub_JTAGDEBUG serverStub <- mkServerStub_JTAGDEBUG(llpi.rrrServer);
    ClientStub_JTAGDEBUG clientStub <- mkServerStub_JTAGDEBUG(llpi.rrrClient);

    //Instantiate Jtag
    JTAGDevice jtag <- mkJTAGDevice();

    rule handleGetChar;
      let char <- serverStub.acceptRequest_GetChar();
      //Only have 4 bits here
      let txChar = {4'h4,truncate(char)}; 
      jtag.send(txChar);
      serverStub.sendResponse_GetChar(txChar);
    endrule

    rule handlePutChar;
      let char <- jtag.receive();
      clientStub.makeRequest_PutChar(char);
    endrule

endmodule