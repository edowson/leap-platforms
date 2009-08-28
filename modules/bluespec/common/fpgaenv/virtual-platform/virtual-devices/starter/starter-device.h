#ifndef _STARTER_
#define _STARTER_

#include <stdio.h>
#include <sys/time.h>
#include <pthread.h>

#include "asim/provides/low_level_platform_interface.h"
#include "asim/provides/rrr.h"
#include "asim/provides/starter_device.h"
#include "asim/rrr/client_stub_STARTER_DEVICE.h"
#include "hardware-done.h"

// this module provides both client and server functionalities


//
// STARTER_SERVER_CLASS --
//
//

typedef class STARTER_DEVICE_SERVER_CLASS* STARTER_DEVICE_SERVER;

class STARTER_DEVICE_SERVER_CLASS: public RRR_SERVER_CLASS,
                            public PLATFORMS_MODULE_CLASS
{
  private:
    // self-instantiation
    static STARTER_DEVICE_SERVER_CLASS instance;

    // stubs
    STARTER_DEVICE_CLIENT_STUB clientStub;
    RRR_SERVER_STUB     serverStub;

  public:
    STARTER_DEVICE_SERVER_CLASS();
    ~STARTER_DEVICE_SERVER_CLASS();

    // static methods
    static STARTER_DEVICE_SERVER GetInstance() { return &instance; }

    // required RRR methods
    void Init(PLATFORMS_MODULE);
    void Uninit();
    void Cleanup();
    void Poll();

    //
    // RRR server methods
    //
    void End(UINT8 success);
    void Heartbeat(UINT64 fpga_cycles);

    // client methods
    void Start();
  

};


// server stub
#include "asim/rrr/server_stub_STARTER_DEVICE.h"

// our STARTER_DEVICE_SERVER class is itself the main STARTER class
typedef STARTER_DEVICE_SERVER_CLASS STARTER_DEVICE_CLASS;

#endif