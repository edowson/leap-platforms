//
// Generated by Bluespec Compiler, version 2010.02.beta4 (build 19725, 2010-02-26)
//
// On Wed Apr  7 13:40:40 EDT 2010
//
//
// Ports:
// Name                         I/O  size props
// masterWires_read               O     1
// masterWires_write              O     1
// masterWires_address            O    32
// masterWires_writedata          O    32
// masterInverseWires_readdata    O    32
// masterInverseWires_waitrequest  O     1
// masterInverseWires_readdatavalid  O     1
// CLK                            I     1 unused
// RST_N                          I     1 unused
// masterWires_readdata           I    32
// masterWires_waitrequest        I     1
// masterWires_readdatavalid      I     1
// masterInverseWires_read        I     1
// masterInverseWires_write       I     1
// masterInverseWires_address     I    32
// masterInverseWires_writedata   I    32
//
// Combinational paths from inputs to outputs:
//   masterWires_readdata -> masterInverseWires_readdata
//   masterWires_waitrequest -> masterInverseWires_waitrequest
//   masterWires_readdatavalid -> masterInverseWires_readdatavalid
//   masterInverseWires_read -> masterWires_read
//   masterInverseWires_write -> masterWires_write
//   masterInverseWires_address -> masterWires_address
//   masterInverseWires_writedata -> masterWires_writedata
//
//

`ifdef BSV_ASSIGNMENT_DELAY
`else
`define BSV_ASSIGNMENT_DELAY
`endif

module mkAvalonWrapperInstance(CLK,
			       RST_N,

			       masterWires_read,

			       masterWires_write,

			       masterWires_address,

			       masterWires_writedata,

			       masterWires_readdata,

			       masterWires_waitrequest,

			       masterWires_readdatavalid,

			       masterInverseWires_read,

			       masterInverseWires_write,

			       masterInverseWires_address,

			       masterInverseWires_writedata,

			       masterInverseWires_readdata,

			       masterInverseWires_waitrequest,

			       masterInverseWires_readdatavalid);
  input  CLK;
  input  RST_N;

  // value method masterWires_read
  output masterWires_read;

  // value method masterWires_write
  output masterWires_write;

  // value method masterWires_address
  output [31 : 0] masterWires_address;

  // value method masterWires_writedata
  output [31 : 0] masterWires_writedata;

  // action method masterWires_readdata
  input  [31 : 0] masterWires_readdata;

  // action method masterWires_waitrequest
  input  masterWires_waitrequest;

  // action method masterWires_readdatavalid
  input  masterWires_readdatavalid;

  // action method masterInverseWires_read
  input  masterInverseWires_read;

  // action method masterInverseWires_write
  input  masterInverseWires_write;

  // action method masterInverseWires_address
  input  [31 : 0] masterInverseWires_address;

  // action method masterInverseWires_writedata
  input  [31 : 0] masterInverseWires_writedata;

  // value method masterInverseWires_readdata
  output [31 : 0] masterInverseWires_readdata;

  // value method masterInverseWires_waitrequest
  output masterInverseWires_waitrequest;

  // value method masterInverseWires_readdatavalid
  output masterInverseWires_readdatavalid;

  // signals for module outputs
  wire [31 : 0] masterInverseWires_readdata,
		masterWires_address,
		masterWires_writedata;
  wire masterInverseWires_readdatavalid,
       masterInverseWires_waitrequest,
       masterWires_read,
       masterWires_write;

  // rule scheduling signals
  wire CAN_FIRE_masterInverseWires_address,
       CAN_FIRE_masterInverseWires_read,
       CAN_FIRE_masterInverseWires_write,
       CAN_FIRE_masterInverseWires_writedata,
       CAN_FIRE_masterWires_readdata,
       CAN_FIRE_masterWires_readdatavalid,
       CAN_FIRE_masterWires_waitrequest,
       WILL_FIRE_masterInverseWires_address,
       WILL_FIRE_masterInverseWires_read,
       WILL_FIRE_masterInverseWires_write,
       WILL_FIRE_masterInverseWires_writedata,
       WILL_FIRE_masterWires_readdata,
       WILL_FIRE_masterWires_readdatavalid,
       WILL_FIRE_masterWires_waitrequest;

  // value method masterWires_read
  assign masterWires_read = masterInverseWires_read ;

  // value method masterWires_write
  assign masterWires_write = masterInverseWires_write ;

  // value method masterWires_address
  assign masterWires_address = masterInverseWires_address ;

  // value method masterWires_writedata
  assign masterWires_writedata = masterInverseWires_writedata ;

  // action method masterWires_readdata
  assign CAN_FIRE_masterWires_readdata = 1'd1 ;
  assign WILL_FIRE_masterWires_readdata = 1'd1 ;

  // action method masterWires_waitrequest
  assign CAN_FIRE_masterWires_waitrequest = 1'd1 ;
  assign WILL_FIRE_masterWires_waitrequest = 1'd1 ;

  // action method masterWires_readdatavalid
  assign CAN_FIRE_masterWires_readdatavalid = 1'd1 ;
  assign WILL_FIRE_masterWires_readdatavalid = 1'd1 ;

  // action method masterInverseWires_read
  assign CAN_FIRE_masterInverseWires_read = 1'd1 ;
  assign WILL_FIRE_masterInverseWires_read = 1'd1 ;

  // action method masterInverseWires_write
  assign CAN_FIRE_masterInverseWires_write = 1'd1 ;
  assign WILL_FIRE_masterInverseWires_write = 1'd1 ;

  // action method masterInverseWires_address
  assign CAN_FIRE_masterInverseWires_address = 1'd1 ;
  assign WILL_FIRE_masterInverseWires_address = 1'd1 ;

  // action method masterInverseWires_writedata
  assign CAN_FIRE_masterInverseWires_writedata = 1'd1 ;
  assign WILL_FIRE_masterInverseWires_writedata = 1'd1 ;

  // value method masterInverseWires_readdata
  assign masterInverseWires_readdata = masterWires_readdata ;

  // value method masterInverseWires_waitrequest
  assign masterInverseWires_waitrequest = masterWires_waitrequest ;

  // value method masterInverseWires_readdatavalid
  assign masterInverseWires_readdatavalid = masterWires_readdatavalid ;
endmodule  // mkAvalonWrapperInstance

