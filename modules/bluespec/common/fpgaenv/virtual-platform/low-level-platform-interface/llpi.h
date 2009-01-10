//
// Copyright (C) 2008 Intel Corporation
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

#ifndef __LLPI__
#define __LLPI__

#include "platforms-module.h"
#include "asim/provides/physical_platform.h"
#include "asim/provides/channelio.h"
#include "asim/provides/rrr.h"
#include "asim/provides/physical_platform_debugger.h"

// Low Level Platform Interface

// A convenient bundle of all ways to interact with the outside world.
typedef class LLPI_CLASS* LLPI;
class LLPI_CLASS: public PLATFORMS_MODULE_CLASS
{
  private:

    // LLPI stack layers
    PHYSICAL_DEVICES_CLASS           physicalDevices;
    CHANNELIO_CLASS                  channelio;
    RRR_CLIENT_CLASS                 rrrClient;
    RRR_SERVER_MONITOR_CLASS         rrrServer;

    // physical platform debugger
    PHYSICAL_PLATFORM_DEBUGGER_CLASS debugger;

  public:

    // constructor - destructor
    LLPI_CLASS();
    ~LLPI_CLASS();

    // Main
    void Main();
    
    // accessors
    PHYSICAL_DEVICES   GetPhysicalDevices() { return &physicalDevices; }
    CHANNELIO          GetChannelIO()       { return &channelio; }
    RRR_CLIENT         GetRRRClient()       { return &rrrClient; }
    RRR_SERVER_MONITOR GetRRRServer()       { return &rrrServer; }

    // poll
    void Poll();
};

#endif
